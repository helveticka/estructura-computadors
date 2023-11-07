*-----------------------------------------------------------
* Title      : PRAREC23
* Written by : Harpo Joan Alberola, Daniel Llufriu Roman
* Date       : 30/06/2023
* Description: Emulador de la SAL9000
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $2882,$289B,$28B4,$281D,$C026,$0060,$C037,$0071,$1900
        DC.W $1910,$0816,$E046,$27FD,$4008,$77A8,$8000,$0001
        DC.W $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
ET0:    DC.W 0 ;eregistro T0
ET1:    DC.W 0 ;eregistro T1
EX2:    DC.W 0 ;eregistro X2
EX3:    DC.W 0 ;eregistro X3
EX4:    DC.W 0 ;eregistro X4
EX5:    DC.W 0 ;eregistro X5
EX6:    DC.W 0 ;eregistro X6
EX7:    DC.W 0 ;eregistro X7
ESR:    DC.W 0 ;eregistro de estado (00000000 00000ZCN)

START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	        ; ESCRIBID VUESTRO CODIGO AQUI	

    MOVE.W  EPC,D0          ; movemos el contador a D0
    MULU.W  #2,D0           ; multiplicamos x2 D0
    
    LEA.L   EMEM,A0         ; cogemos la dirección de la memoria
    ADD.W   D0,A0           ; sumamos D0 (PC) a A0 para tener la dirección de
                            ; la instrucción a ejecutar
    ADD.W   #1,EPC          ; sumamos 1 al EPC para ya apuntar a la siguiente
    MOVE.W  (A0),EIR        ; movemos la instrucción al eregistro
                            ; de instrucción    
        
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	    ; ESCRIBID VUESTRO CODIGO AQUI
      
    MOVE.W  #0,-(A7)        ; preparamos la pila
    MOVE.W  (EIR),-(A7)     ; metemos la instrucción en la pila
    
    JSR     DECOD           ; saltamos a la subrutina de librería
                            ; de decodificación                           
    ADDQ.W  #2,A7           ; sumamos 2 a A7
    MOVE.W  (A7)+,D1        ; en D1 tenemos la instrucción a ejecutar
  	    
        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP ELSH
    JMP EADQ
    JMP ESET
    JMP EOR
    JMP ENOT
    JMP EGOZ
    JMP EGOC
    JMP EGON
    JMP EGOI
    JMP EEXIT
    JMP ELOIP
    JMP ELOA
    JMP ESTIP
    JMP ESTO
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
	
ECOPY:      
    MOVE.W  EIR,D5              ; Movemos la dirección de Rb en el registro de 
    JSR     Bring_B             ; direcciones A2
    MOVE.W  A5,A2
    
    MOVE.W  EIR,D5              ; Movemos la dirección de Rc en el registro de
                                ; direcciones A1
    JSR     Bring_C
    MOVE.W  A5,A1
    
    MOVE.W  (A2),(A1)           ; Ponemos la dirección que esta en Rb en Rc
    
    MOVE.W  SR,D2               ; Hacemos una copia de los flags, guardamos los flags N y Z 
    CLR.W   D4                  ; y limpiamos D4
    JSR     FLAGS_NZ
    
    BRA FETCH

EADD:      
    MOVE.W  EIR,D5              ; Ponemos la dirección de Ra en el registro de direcciones A1
    JSR     Bring_A

    MOVE.W  A5,A2
    
    MOVE.W  EIR,D5              ;  Ponemos la dirección de Rb en el registro de direcciones A2

    JSR     Bring_B
    MOVE.W  A5,A1
    
    MOVE.W  EIR,D5              ;  Ponemos la dirección de Rc en el registro de direcciones A3

    JSR     Bring_C
    MOVE.W  A5,A3
    
    CLR.W   D6                  ; Limpiamos D6, le sumamos el contenido de  Ra y el de Rb
    ADD.W   (A1),D6                 
    ADD.W   (A2),D6
    
    MOVE.W  SR,D2               ; Hacemos una copia de los flags, guardamos los flags C, N y Z y limpiamos D4
    CLR.W   D4                     
    JSR     FLAGS_CNZ
    
    MOVE.W  D6,(A3)             ; Por último guardamos el resultado la suma en Rc
    
    BRA FETCH

ESUB:       
    MOVE.W  EIR,D5              ; Guardamos la dirección de Ra en A1
    JSR     Bring_A

    MOVE.W  A5,A2
    
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rb en A2
    JSR     Bring_B
    MOVE.W  A5,A1
    
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rc en A3
    JSR     Bring_C
    MOVE.W  A5,A3
    
    CLR.W   D6                  ; Limpiamos D6, le sumamos el contenido de
    ADD.W   (A2),D6                 ; Ra, lo negamos para hacer la resta,
    NOT.W   D6                      ; y finalmente le sumamos el de Rb
    ADDQ.W  #1,D6
    ADD.W   (A1),D6
    
    MOVE.W  SR,D2               ; Hacemos una copia de los flags, limpiamos D4
    CLR.W   D4                      ; y guardamos los flags C, N y Z
    JSR     FLAGS_CNZ
    
    MOVE.W  D6,(A3)             ; Finalmente guardamos la suma en Rc
    
    BRA FETCH

ELSH:       
    MOVE.W  EIR,D5              ; Guardamos P en D6, usando "Bring_A"
    JSR     Bring_A

    MOVE.W  D5,D6
    
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rb en A2, y
    JSR     Bring_B                  ; copiamos su contenido en D7
    MOVE.W  A5,A2
    MOVE.W  (A2),D7
    
    MOVE.W  EIR,D5              ; Guardamos N en D4, usando "Bring_I"
    JSR     Bring_I
    MOVE.W  D5,D4
    
    CMP.W   #0,D4               ; Si N es 0, seguimos
    BNE     N1_ELSH
    
    LSL.L   D6,D7               ; Desplazamos el contenido de Rb P posiciones
    MOVE.W  SR,D2                   ; a la izquierda, hacemos una copia de los
    JMP     FINAL_ELSH              ; flags, y saltamos al final
    
   N1_ELSH:
    LSR.L   D6,D7               ; Desplazamos el contenido de Rb P posiciones
    MOVE.W  SR,D2                   ; a la izquierda, hacemos una copia de los
                                    ; flags, y seguimos
   FINAL_ELSH:
    CLR.W   D4                  ; Limpiamos D4 y guardamos los flags C, N y Z
    JSR     FLAGS_CNZ
    
    MOVE.W  D7,(A2)             ; Finalmente guardamos D7 en el contenido de Rb
    
    BRA FETCH
    
EADQ:       
    MOVE.W  EIR,D5              ; Guardamos K en D6
    JSR     Bring_K
    MOVE.W  D5,D6
    
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rc en A1
    JSR     Bring_C
    MOVE.W  A5,A1
    
    ADD.W   (A1),D6             ; Sumamos el contenido de Rc a K

    MOVE.W  SR,D2               ; Hacemos una copia de los flags, limpiamos D4
    CLR.W   D4                      ; y guardamos los flags C, N y Z
    JSR     FLAGS_CNZ
    
    MOVE.W  D6,(A1)             ; Finalmente guardamos la suma en el contenido
                                    ; de Rc
    BRA FETCH

ESET:       
    MOVE.W  EIR,D5              ; Guardamos K en D6
    JSR     Bring_K
    MOVE.W  D5,D6
    
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rc en A1
    JSR     Bring_C
    MOVE.W  A5,A1
    
    MOVE.W  D6,(A1)             ; Copiamos K en el contenido de Rc

    MOVE.W  SR,D2               ; Hacemos una copia de los flags, limpiamos D4
    CLR.W   D4                      ; y guardamos los flags N y Z
    JSR     FLAGS_NZ
    
    BRA FETCH

EOR:      
    MOVE.W  EIR,D5              ; Definimos la ubicación de Ra en A1
    JSR     Bring_A

    MOVE.W  A5,A1
    
    MOVE.W  EIR,D5              ; Configuramos la dirección de Rb en A2
    JSR     Bring_B
    MOVE.W  A5,A2
    
    MOVE.W  EIR,D5              ; Establecemos la dirección de Rc en A3
    JSR     Bring_C
    MOVE.W  A5,A3
    
    MOVE.W  (A1),D6             ; Asignamos el contenido de Ra a D6, el de
    MOVE.W  (A2),D7             ; Rb a D7, y ejecutamos la operación OR
    OR.W   D6,D7
             
    MOVE.W  SR,D2               ; Realizamos un respaldo de los flags, limpiamos D4
    CLR.W   D4                  ; y definimos los flags N y Z
    JSR     FLAGS_NZ
    
    MOVE.W  D7,(A3)             ; Finalmente, almacenamos el resultado de OR en Rc
    
    BRA FETCH
    
ENOT:
    MOVE.W  (A1),D6             ; Tomamos el contenido de Rc y lo colocamos en D6
                                ; Luego, ejecutamos la operación NOT
    NOT.W    D6

    MOVE.W  SR,D2               ; Creamos un respaldo de los flags, y después vaciamos D4
    CLR.W   D4                  ; Ahora, establecemos los flags N y Z
    JSR     FLAGS_NZ

    MOVE.W  D6,(A1)             ; Al final, el resultado de NOT se guarda en Rc

    BRA FETCH


EGOZ:       
    MOVE.W  ESR,D2              ; Guardamos los Eflags en D2
    BTST    #0,D2               ; Solo seguimos si Z es 1 seguimos
    BEQ     Z_0

    MOVE.W  EIR,D5              ; Movemos el valor de M al EPC
    JSR     Bring_K
    ADD.W   D5,EPC
    
   Z_0:                         ; Y si Z es 0, terminamos
    BRA FETCH

EGOC:       
    MOVE.W  ESR,D2              ; Guardamos los Eflags en D2 
    BTST    #2,D2               ; Si el Eflag C es 1 seguimos
    BEQ     C_0

    MOVE.W  EIR,D5              ; Copiamos al EPC el valor de M
    JSR     Bring_K
    ADD.W   D5,EPC
    
   C_0:                         ; Y si C es 0, terminamos
    BRA FETCH
    
EGON:       
    MOVE.W  ESR,D2               ; Guardamos los Eflags en D2 

    BTST    #1,D2               ; Si N es 1 continuamos
    BEQ     N_0

    MOVE.W  EIR,D5              ; Movemos K al EPC
    JSR     Bring_K
    ADD.W   D5,EPC
    
   N_0:                         ; Y si N es 0, terminamos
    BRA FETCH

EGOI:       
    MOVE.W  EIR,D5             ; Movemos M al EPC

    JSR     Bring_K
    ADD.W   D5,EPC
    
    BRA FETCH

EEXIT:      
    SIMHALT

ELOIP:      

    MOVE.W  EIR,D5              ; Guardamos la dirección de Rb en A1, copiamos
    JSR     Bring_B              ; el contenido de la dirección de este en
    MOVE.W  A5,A2               ; A2, y lo multiplicamos por 2
    MOVE.W  (A2),A3
    ADD.W   A3,A3
    
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rc en A1
    JSR     Bring_C
    MOVE.W  A5,A1
    
    MOVE.W  EMEM(A3),(A1)        ; Guardamos en ET0 el contenido apuntado por A2
    MOVE.W  SR,D2               ; Hacemos una copia de los flags e                                  
                                ; Incrementamos en 1 la dirección que guarda Rb
    CLR.W   D4                          ; Limpiamos D4 y guardamos los flags N y Z
    JSR     FLAGS_NZ

    ADDQ.W  #1,(A2) 
    
    BRA FETCH

ELOA:       
    MOVE.W  EIR,D5              ; Buscamos el valor de M, lo guardamos en A1, 
    JSR     Bring_M              ; y lo multiplicamos por 2
    MOVE.W  D5,A1
    ADD.W   A1,A1
    
    MOVE.W  EIR,D5              ; Buscamos el valor de I y lo guardamos en D6
    JSR     Bring_C
    MOVE.W  A5,A6
    
    
    MOVE.W  EMEM(A1),(A6)        ; Guardamos en ET0 el contenido apuntado por A1
    MOVE.W  SR,D2               ; Hacemos una copia de los flags y
    
    CLR.W   D4                  ; Limpiamos D4 y guardamos los flags N y Z
    JSR     FLAGS_NZ
        
    BRA     FETCH


ESTIP: 
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rb en A1, copiamos
    JSR     Bring_B              ; el contenido de la dirección de este en
    MOVE.W  A5,A2               ; A2, y lo multiplicamos por 2
    MOVE.W  (A2),A3
    ADD.W   A3,A3
    
    MOVE.W  EIR,D5              ; Guardamos la dirección de Rc en A1
    JSR     Bring_C
    MOVE.W  A5,A1
    
    MOVE.W  (A1),EMEM(A3)        ; Guardamos en Xb el contenido apuntado por A2
    MOVE.W  SR,D2               ; Hacemos una copia de los flags e                                  
                                ; Incrementamos en 1 la dirección que guarda Rb
    CLR.W   D4                          ; Limpiamos D4 y guardamos los flags N y Z
    JSR     FLAGS_NZ

    ADDQ.W  #1,(A2) 
    
    BRA FETCH

    
ESTO:
    MOVE.W  EIR,D5              ; Buscamos el valor de M, lo guardamos en A1, 
    JSR     Bring_M              ; y lo multiplicamos por 2
    MOVE.W  D5,A1
    ADD.W   A1,A1
    
    MOVE.W  EIR,D5              ; Buscamos el valor de I y lo guardamos en D6
    JSR     Bring_C
    MOVE.W  A5,A6
    
    
    MOVE.W  (A6),EMEM(A1)        ; Guardamos en ET0 el contenido apuntado por A1
    MOVE.W  SR,D2               ; Hacemos una copia de los flags y
    
    CLR.W   D4                  ; Limpiamos D4 y guardamos los flags N y Z
    JSR     FLAGS_NZ
        
    BRA     FETCH

    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
Bring_A:
    LSR.L #4,D5             ; movemos D5 4 posiciones a la derecha
    
Bring_B:

    LSR.L #4,D5             ; movemos D5 4 posiciones a la derecha

Bring_C:

    AND.W #$0007,D5         ; con una máscara, cogemos el valor de A/B/C
    JSR REGISTROS             ; y miramos a qué registro se corresponde
    
    RTS
   
Bring_I:
    AND.W #0001,D5          ; con una máscara, cogemos el valor de I
    
    RTS
    
Bring_M:
    LSR.L #3,D5             ; movemos D5 1 posición a la derecha
    AND.W #$00FF,D5         ; con una máscara, cogemos el valor de M (mmmmmmmm)
    
    RTS
   
Bring_K:
    LSR.L #3,D5             ; movemos D5 3 posiciones a la derecha
    AND.W #$00FF,D5         ; con una máscara, cogemos el valor de K (kkkkkkkk)
    EXT.W D5                ; hacemos una extensión de signo (byte -> word)
    
    RTS

*--------------------------------------

REGISTROS:
    BTST.L #2,D5            ; miramos el tercer bit del registro
    BNE REGISTROS_1XX       ; si no es 0, saltamos para mirar el registro 1XX
    
   ;0XX
    BTST.L #1,D5            ; miramos el segundo bit del registro
    BNE REGISTROS_01X       ; si no es 0, saltamos para mirar el registro 01X
    
        ;00X
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_T0    ; si es 0, el registro es T0
         JMP REGISTRO_T1    ; si es 1, el registro es T1
    
        REGISTROS_01X:
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_X2    ; si es 0, el registro es X2
         JMP REGISTRO_X3    ; si es 1, el registro es X3
    
   REGISTROS_1XX:
    BTST.L #1,D5            ; miramos el segundo bit del registro
    BNE REGISTROS_11X       ; si no es 0, saltamos para mirar el registro 11X
    
        ;10X
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_X4    ; si es 0, el registro es X4
         JMP REGISTRO_X5    ; si es 1, el registro es X5
    
        REGISTROS_11X:
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_X6    ; si es 0, el registro es X6
         JMP REGISTRO_X7    ; si es 1, el registro es X7
    

  ; A partir de aquí guardamos las direcciones y salimos de la subrutina 
   REGISTRO_T0:
    LEA.L ET0,A5
    RTS
    
   REGISTRO_T1:
    LEA.L ET1,A5
    RTS
    
   REGISTRO_X2:
    LEA.L EX2,A5
    RTS
    
   REGISTRO_X3:
    LEA.L EX3,A5
    RTS
    
   REGISTRO_X4:
    LEA.L EX4,A5
    RTS
    
   REGISTRO_X5:
    LEA.L EX5,A5
    RTS
    
   REGISTRO_X6:
    LEA.L EX6,A5
    RTS
    
   REGISTRO_X7:
    LEA.L EX7,A5
    RTS

*--------------------------------------    

FLAGS_CNZ:
    MOVE D2,D3              ; copiamos los flags para poder manipularlos
    BTST #0,D3              ; miramos C
    BEQ FLAGS_NZ            ; si C es 0, saltamos a mirar el flag Z
    
    BSET #2,D4              ; si no es 0, pondremos a 1 el valor de C en D4
    
FLAGS_NZ:
    MOVE.W D2,D3            ; copiamos los flags para poder manipularlos
    BTST #3,D3              ; miramos N
    BEQ Z                   ; si Z es 0, saltamos a mirar el siguiente flag
    
    BSET #1,D4              ; si no es 0, pondremos a 1 el valor de N en D4
    
   Z:
    MOVE.W D2,D3            ; copiamos los flags para poder manipularlos
    BTST #2,D3              ; miramos Z
    BEQ FINAL_FLAGS         ; si N es 0, saltamos al final de los flags
    
    BSET #0,D4              ; si no es 0, pondremos a 1 el valor de Z en D4
    
   FINAL_FLAGS:
    MOVE.W D4,ESR           ; movemos D4 (flags finales) a ESR, los eflags
    RTS
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	        ; ESCRIBID VUESTRO CODIGO AQUI

    MOVE.W D0, -(A7)         ; guardamos D0 en la pila
    MOVE.W D1, -(A7)         ; guardamos D1 en la pila
    MOVE.W 8(A7), D0         ; pasamos la instrucción a D0
    
    MOVE.W #0, D1            ; ponemos a 0 D1 (número de instrucción)
    BTST.L #15, D0           ; miramos el 16º bit de la instrucción
    BNE DECOD_1XXXX          ; si no es 0, saltamos para mirar la instr. 1XXX

    ;0XXXX:
    BTST.L #14, D0           ; miramos el 15º bit de la instrucción
    BNE DECOD_01XXX          ; si no es 0, saltamos para mirar la instr. 01XX

        ;00XXX:
        BTST.L #13,D0            ; miramos el 14º bit de la instrucción
        BNE DECOD_001XX          ; si no es 0, saltamos para mirar la instr. 001X   

            ;000XX:
            BTST.L #12, D0
            BNE DECOD_0001X
    
                ;0000X:
                BTST.L #11, D0
                BNE FINAL_AUX
                JMP FINAL
                
                DECOD_0001X:
                ;0001
                ADDQ.W #2, D1
                BTST.L #11, D0
                BNE FINAL_AUX
                JMP FINAL
                
            DECOD_001XX:
            ;001XX
            BTST.L #12, D0
            BNE DECOD_0011X
            
                ;0010X
                ADDQ.W #4, D1
                BTST.L #11, D0
                BNE FINAL_AUX
                JMP FINAL
            
                DECOD_0011X:
                ;0011X
                ADDQ.W #6, D1
                BTST.L #11, D0
                BNE FINAL_AUX
                JMP FINAL
                
        DECOD_01XXX:
        ;01XXX
        BTST.L  #13, D0
        BNE DECOD_011XX

            ;010XX
            ADDQ.W #8, D1
            BTST.L #12, D0
            BNE FINAL_AUX
            JMP FINAL
            
            DECOD_011XX:
            ;011XX
            ADD.W #10, D1
            BTST.L #12, D0
            BNE FINAL_AUX
            JMP FINAL
            
    DECOD_1XXXX:
    ;1XXXX
    ADD.W #12, D1
    BTST.L #14, D0
    BNE DECOD_11XXX
    
        ;10XXX
        JMP FINAL
        
        DECOD_11XXX:
        ;11XXX
        BTST.L #13, D0
        BNE DECOD_111XX
        
            ;110XX
            ADDQ.W #1, D1
            BTST.L #12, D0
            BNE FINAL_AUX
            JMP FINAL
            
            DECOD_111XX:
            ;111XX
            ADDQ.W #3, D1
            BTST.L #12, D0
            BNE FINAL_AUX
            JMP FINAL
    
    FINAL_AUX:
    ADDQ.W #1, D1
    
    FINAL:
    MOVE.W D1,10(A7)        ; guardamos el número de instrucción en la pila
    MOVE.W (A7)+,D1         ; sacamos D1 de la pila
    MOVE.W (A7)+,D0         ; sacamos D0 de la pila
	
	RTS
    
    ;--- FDECOD: FIN DECOD
    END    START
