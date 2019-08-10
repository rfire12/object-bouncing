
.model small

.stack 256

.data

;========================Variables declaradas aqui===========================
mensaje2 db 13,10,"Columna de inicio (Ej. 05): ", "$"
mensaje3 db "Fila de inicio (Ej. 10): ", "$"
objeto db "*", "$"            ;Caracter a mostrar
espacio db " ", "$"           ;Espacio en blanco para borrar posicion anterior (Simular movimiento)
count24 db 1                  ;Contador movimientos verticales 
count80 db 1                  ;Contador de movimientos horizontales
counter db 0                  ;Contador auxiliar
temp1 db 0                    ;Variable temporal (Guardar parte alta de bx)
temp2 db 0                    ;Variable temporal (Guardar parte baja de bx)
color db 13                   ;Almacenar colores (Inicia en blanco)

;============================================================================

   
    
mensajePantalla macro texto
    mov ah, 09h                 ;Permite realizar la operacion de mostrar un mensaje
    mov dx, offset texto        ;Se muestra el mensaje para pedir una cadena
    int 21h                     ;Ejecutar la instruccion anterior
    endm
    
.code

main:   
    mov ax,@data
    mov ds,ax
    mov es, ax                          ;set segment register
    and sp, not 3                       ;align stack to avoid AC fault

    
;====================================C?digo==================================  
    call imprimir
    
;============================================================================
.exit
;================================Funciones aqui==============================

imprimir:
        mov ax,0b800h
        mov es,ax                   ;segmento dir. de mem de video.
        xor bx,bx                   ;puntero para video
        xor di,di                   ;puntero letrero
        call filaInicio
        call columnaInicio
        call limpiarPantalla
        xor cx, cx      
        xor ax, ax
        mov dx, 162
    ok:
        mov al, count24
        cmp cl, 0                   ;Sumar al contador posiciones verticales
        je add1
        cmp cl, 1                   ;Restar al contador posiciones verticales
        je sub1
        continuar:
        mov count24, al             ;Guardar posicion movida
        
        mov al, count80 
        cmp ah, 0                   ;Sumar al contador posiciones horizontales
        je add2                    
        cmp ah, 1                   ;Restar al contador posiciones horizontales
        je sub2
        continuar2:
        mov count80, al             ;Guardar posicion movida
         
         
        mov al, objeto              ;Caracter a imprimir (asterisco)
        mov es:[bx],al              ;Imprimir caracter
        mov al, color               ;Color a utilizar
        mov es:[bx+1], al           ;Cambiar color
        call delay                  ;Crear un retraso
        call delay                  ;Crear otro retraso 
        mov al, espacio             ;Caracter a imprimir (Espacio en blanco)
        mov es:[bx],al              ;borrar caracter de la posicion anterior
        call condicionesRebotar24   ;Verificar si se ha chocado con las pared superior o infereior
        call condicionesRebotar80   ;Verificar si se ha chocado con las paredes izquierda y derecha
        add bx, dx                  ;Mover caracter a la siguiente posicion
        jmp ok
        ;Sumar y restar de 24
        add1:
            inc al                  ;Aumentar en 1 la posicion de impresion vertical
            jmp continuar
        sub1:
            dec al                  ;Disminuir en 1 la posicion de impresion vertical
            jmp continuar
            
        ;Sumar y restar de 80    
        add2:
            inc al                  ;Aumentar en 1 la posicion de impresion horizontal
            jmp continuar2
        sub2:
            dec al                  ;Disminuir en 1 la posicion de impresion horizontal
            jmp continuar2    
   ret

condicionesRebotar24:
    mov al, count24
    cmp al, 26                      ;Si la pelota va bajando (choca con el borde inferior)
    je rebotar24a
    cmp al, 2                       ;Si la pelota va subiendo (choca con el borde superior)
    je rebotar24b
    jmp fin
    rebotar24a: 
        call cambiarColor           ;Cambiar color del caracter
        cmp ah, 0                   ;Si la pelota va bajando de izquierda a derecha y choca
        je rebotaraArribaDerecha
        cmp ah, 1                   ;Si la pelota va bajando de derecha a izquierda y choca
        je rebotaraArribaIzquierda
        
    rebotar24b:
        call cambiarColor           ;Cambiar color del caracter
        cmp ah, 0                   ;Si la pelota va subiendo de izquierda a derecha y choca
        je rebotaraAbajoDerecha
        cmp ah, 1                   ;Si la pelota va subiendo de derecha a izquierda y choca
        je rebotaraAbajoIzquierda
        
        
    rebotaraArribaDerecha:
        mov dx, -158                ;Cambiar orientacion del moviento del caracter (Hacia la derecha)
        mov cl, 1                   ;Mover caracter hacia arriba
        jmp fin  
      
    rebotaraArribaIzquierda:
        mov dx, -162                ;Cambiar orientacion del moviento del caracter (Hacia la izquierda)
        mov cl, 1                   ;Mover caracter hacia arriba
        jmp fin   
        
        
    rebotaraAbajoDerecha:    
        mov dx, 162                 ;Cambiar orientacion del moviento del caracter (Hacia la derecha)
        mov cl, 0                   ;Mover caracter hacia abajo
        jmp fin
        
    rebotaraAbajoIzquierda:    
        mov dx, 158                 ;Cambiar orientacion del moviento del caracter (Hacia la izquierda)
        mov cl, 0                   ;Mover caracter hacia abajo
        jmp fin
        
    fin:
        ret

condicionesRebotar80:               ;Choques con los bordes laterales
    mov al, count80                 ;Pasar el contador de posiciones horizontales a un registro
    cmp al, 81                      ;Si la pelota choca con el borde derecho 
    je rebotar80a
    cmp al, 2                       ;Si la pelota choca con el borde izquierdo 
    je rebotar80b
    jmp fin1
    
    rebotar80a:
        call cambiarColor           ;Cambiar color del caracter
        cmp cl, 0                   ;Si la pelota viene bajando 
        je rebotaraaIzquierdaAbajo
        cmp cl, 1                   ;Si la pelota viene subiendo
        je rebotaraaIzquierdaArriba
        
    rebotar80b:
        call cambiarColor           ;Cambiar color del caracter
        cmp cl, 0                   ;Si la pelota viene bajando 
        je rebotaraaDerechaAbajo
        cmp cl, 1                   ;Si la pelota viene subiendo
        je rebotaraaDerechaArriba
        
    rebotaraaIzquierdaAbajo:     
        mov dx, 158                 ;Cambiar orientacion del moviento del caracter (Hacia arriba)
        mov ah, 1                   ;Mover caracter hacia la izquierda
        jmp fin1
        
    rebotaraaIzquierdaArriba:
        mov dx, -162                ;Cambiar orientacion del moviento del caracter (Hacia abajo)
        mov ah, 1                   ;Mover caracter hacia la izquierda
        jmp fin1
        
    rebotaraaDerechaAbajo:    
        mov dx, 162                 ;Cambiar orientacion del moviento del caracter (Hacia abajo)
        mov ah, 0                   ;Mover caracter hacia la derecha
        jmp fin1
        
     rebotaraaDerechaArriba:    
        mov dx, -158                ;Cambiar orientacion del moviento del caracter (Hacia arriba)
        mov ah, 0                   ;Mover caracter hacia la derecha
        jmp fin1
        
    fin1:
        ret                         ;Regresar
    
        
           
delay:                              
    xor si, si                      ;Reiniciar contador
    ciclo:                      
    inc si                          ;Aumentar contador 
        cmp si, 50000
        jne ciclo                   ;Ejecutar el ciclo nuevamente
    ret
    
limpiarPantalla:
    mov ax,03H                      ;Instruccion para limpiar la pantalla
    int 10h                         ;Ejecutar la instruccion
    ret

    

    
filaInicio:
    mensajePantalla mensaje3 
    xor cx,cx                   ;Inicializar en 0 la posicion de inicio
    call read                   ;Leer primer posicion de inicio relativa (decena)
    call obtenerDecena
    mov dx, 1600                ;Hay 1600 caracteres cada 10 lineas    
    call obtenerPosicion        ;Obtener fila de inicio (decena)
    mov dx, 160                 ;Hay 160 caracteres cada 10 lineas 
    call read                   ;Leer primer posicion de inicio relativa (unidad)
    
    call obtenerUnidad          ;Para el contador
    mov al, counter             ;Asignar contador a una variable de tranasicion
    mov count24, al             ;Punto de inicio del objeto (En Y)
    mov al, bl                  ;Regresar valor leido a su registro
    
    call obtenerPosicion        ;Obtener fila de inicio (unidad)
    mov bx, cx                  ;Asignar el punto de inicio en la pantalla (En este momento solo respecto a las filas)
    ret   

columnaInicio:
    mensajePantalla mensaje2 
    mov temp1, bh               ;Copia de la parte alta de bx
    mov temp2, bl               ;Copia de la parte baja de bx
    xor cx,cx                   ;Inicializar en 0 la posicion de inicio
    mov counter, cl             ;Inciar en 0 el contador
    call read                   ;Leer primer posicion de inicio relativa (decena)
    call obtenerDecena          ;Para el contador
    mov dx, 20                  ;Para moverse 10 posiciones, hay que aumentar de 20 en 20  
    call obtenerPosicion        ;Obtener fila de inicio (decena)
    mov dx, 2                   ;Para moverse 1 posicion hay que aumentar de 2 en 2
    call read                   ;Leer primer posicion de inicio relativa (unidad)
    
    call obtenerUnidad          ;Para el contador
    mov al, counter             ;Asignar contador a una variable de tranasicion
    mov count80, al             ;Punto de inicio del objeto (En X)
    mov al, bl                  ;Regresar valor leido a su registro
    
    call obtenerPosicion        ;Obtener fila de inicio (unidad)
    mov bh, temp1               ;Regresar valores
    mov bl, temp2               ;Regresar valores
    add bx, cx                  ;Aumentar el punto de inicio en la pantalla 
    ret 
    
read:
    mov ah, 01                  ;Leer caracter. Este se guardara en el buffer
    int 21h                     ;Ejecutar instruccion anterior
    ret    
    
obtenerPosicion:
    sub al, 48                  ;Convertir valor leido a entero       
    mov ah, 00                  ;Borrar la parte alta del registro ax
    mul dx                      ;Multiplicar 1600 o 160 (dependiendo) por el valor leido
    add cx, ax                  ;Guargar el resultado en un acumulador
    ret 
  
obtenerDecena:
    mov bl, al                  ;Copia del valor leido
    sub al, 48                  ;Convertir valor leido a entero
    mov ah, 10                  ;Se multiplicara el valor leido por 10 (Decena)
    mul ah                      ;Multiplicar el valor leido
    add counter, al             ;Asignar resultado a un acumulador
    mov al, bl                  ;Regresar valor leido al registro de origen
    ret
    
obtenerUnidad:
    mov bl, al                  ;Copia del valor leido
    sub al, 48                  ;Convertir valor leido a entero
    add al, 1                   ;Anadir 1 a la posicion de inicio
    add counter, al             ;Anadir valor leido a un contador
    ret
    
cambiarColor:
    mov al, color               ;Color actual
    cmp al, 15                  ;Si no es el ultimo color
    jne change                  ;Cambiar al siguente color
    cmp al, 15                  ;Si es el ultimo color
    je restart                  ;Reiniciar colores
    change:     
    inc al                      ;Cambiar color
    mov color, al               ;Guardar color
    jmp termi                   ;Terminar
    restart:    
    mov al, 0                   ;Se reinicia el color
    mov color, 0                ;Guardar color
    termi:
    cmp al, 0                   ;Si el color es negro, cambiarlo (El fondo es negro y el asterisco se difumina)
    je change                   ;Cambiar el color
    ret
;============================================================================
end main


