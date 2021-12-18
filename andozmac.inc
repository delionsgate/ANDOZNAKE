;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video. 80x25 px
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
posiciona_cursor_mouse	macro columna,renglon
	mov dx,renglon
	mov cx,columna
	mov ax,4		;opcion 0004h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter

imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm


;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	local continuar
	mov ax, 0003h
	int 33h

	cmp cx, 160d
	jle continuar

	mov cx, 0d
	mov dx, 160d

	mov ax, 0007h
	int 33h

	continuar:
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

temporizador macro; Se espera un tiempo para seguir el proceso
    local iniciaTemp
    local espera
    local cambio
    	;contempo se modifica en donde sea necesario
    	xor cl,cl
    	mov cl,[contempo]
    	mov contempo_aux,cl
	    espera:
	    	;Se limpia el buffer
	    	mov ah,0Ch
	    	xor al,al
	    	int 21h

	        mov ah,2ch
	        int 21h
	        mov [conta],dl            ;Obtiene el primer tick

	        cambio:
	            mov ah,2ch
	            int 21h
	            cmp dl,[conta]        	;Si el cronómetro cambia
	            jz cambio               ;Si no, regresa hasta que cambie.
	    dec contempo_aux
	    cmp contempo_aux,0
	    jg espera
endm

;Devuelve un número pseudoaleatorio entre 0 y 99 en elk registro DX
numero_aleatorio macro lim_inf, lim_sup
	; n = lim_inf + random % (lim_sup - lim_inf + 1)
	xor cx, cx 			;BX = 0
	mov ah, 2Ch			;Opción '2C': obtener hora del sistema
	int 21h
	;dl: centésimas de segundo [0 - 99]
	xor ah, ah
	mov al, dl 			;AL = random
	mov ch, [lim_sup]	;BH = lim_sup
	mov cl, [lim_inf]	;BL = lim_inf

	inc ch 				;BH = lim_sup + 1
	sub ch, cl			;BH = lim_sup - lim_inf + 1
	div ch 				;AH = random % (lim_sup - lim_inf + 1)
	add cl, ah 			;BL = lim_inf + random % (lim_sup - lim_inf + 1)
endm


detectar_colision macro fila, columna
	local verif_colision_head
	local verif_colum_head
	local verif_colision_item
	local verif_colum_item
	local verif_colision_coda
	local loop_coda
	local verif_colum_coda
	local condicion_loop
	local sin_colision
	local colision_bSup
	local colision_bInf
	local colision_pIzq
	local colision_pDer
	local colision_Coda
	local colision_Head
	local colision_Item
	local fin_colision

	; 0 : sin colisión
	; 1 : colisión con el marco
	; 2 : colisión con cola de viborita
	; 3 : colisión con cabeza de viborita
	; 4 : colisión con item

	;se salvan los actuales de los registros que se ocuparán
	push ax 
	push bx
	push dx

	xor dx, dx
	mov dh,head_x
	mov dl,head_y

	;Se verifica si se le pasaron las coordenadas de la Cabeza o de un Item
	lea ax, [fila]				;desplazamiento en memoria de la fila que les pasas a la macro
	lea bx, [item_ren]			;desplazamiento en memoria de la fila del último Item posicionado
	cmp ax, bx   				;se comparan las "direciones de memoria"
	jne verif_colision_item 	;si son diferentes, se trata de la Cabeza y, por lo tanto, no es necesario evaluar colisión con ella
								;si no, se trata del Item y hay que evaluar colisión con la Cabeza
	
	;Colisión con cabeza
	verif_colision_head:
		;lea dx, [head]
		cmp fila, dl 
		je verif_colum_head
		jmp verif_colision_coda

		verif_colum_head:
			cmp columna, dh 
			je colision_Head
		jmp verif_colision_coda

	;colisión/comerser un item
	verif_colision_item:
		cmp dl, [item_ren]
		je verif_colum_item
		jmp verif_colision_coda

		verif_colum_item:
			cmp dh, [item_col]
			je colision_Item

	;Colisión con cuerpo viborita
	verif_colision_coda:
		xor bx, bx
		lea bx, [tail]		;posición de la cadena en el registro ds
							;posición del segmento de cola con el cual se puede chocar
		loop_coda:
			;push bx 			;se guarda en la pila dado que algunos porcedimientos modifican bx
			mov ax, [bx]
		
			cmp fila, al 
			je verif_colum_coda
			jmp condicion_loop

			verif_colum_coda:
				cmp columna, ah 
				je colision_Coda

			condicion_loop:
				;pop bx 					;se recupera el valor de bx
				add bx, 2 				;se avanza al siguiente elemento
				cmp word ptr [bx], 0 	;se compara hasta encontrar un valor igual a 0 (no inicializado de la viborita)
				jne loop_coda

	;Colisión con el marco del juego
	;Colisión con fila : fuera de [1 - 23d]
	cmp fila, 1d
	jl colision_bSup

	cmp fila, 23d
	jg colision_bInf

	;Colisión con columna : fuera de [21 - 78d]
	cmp columna, 21d
	jl colision_pIzq

	cmp columna, 78d
	jg colision_pDer
	jmp sin_colision

	sin_colision:
		mov colision, 0h
		jmp fin_colision
	colision_bSup:
		mov colision, 1h
		jmp fin_colision
		;jmp colision_columna
	colision_bInf:
		mov colision, 1h
		jmp fin_colision
		;jmp colision_columna
	colision_pIzq:
		mov colision, 1h
		jmp fin_colision
	colision_pDer:
		mov colision, 1h
		jmp fin_colision
	colision_Coda:
		mov colision, 2h
		jmp fin_colision
	colision_Head:
		mov colision, 3h 
		jmp fin_colision
	colision_Item:
		mov colision, 4h 
		jmp fin_colision

	fin_colision:
	pop dx 
	pop bx 
	pop ax 
endm


; detectar_colision macro fila, columna
; 	local colision_obstaculo
; 	local colision_cuerpo
; 	local colision_fruta
; 	local fin_detectar_colision

; 	; 0 : sin colisión
; 	; 1 : colisión con el obstáculo
; 	; 2 : colisión con cola de viborita
; 	; 3 : colisión con fruta

; 	xor cx, cx
; 	xor dx, dx

; 	mov ah, 0Dh				;te da el color de un pixel
; 	mov dl, fila
; 	mov cl, columna
; 	int 10h					;AH = color del pixel

; 	;si es obstaculo
; 	cmp ah, cAzulClaro		;cAzulClaro equ 09h - obstáculo
; 	je colision_obstaculo

; 	;si es cuerpo
; 	cmp ah, cVerdeClaro		;cVerdeClaro equ 0Ah - cuerpo
; 	je colision_cuerpo

; 	;si es fruta
; 	cmp ah, cRojo			;cRojo equ 04h - fruta
; 	je colision_fruta

; 	;sin_colision:
; 		mov [colision], 0h
; 		jmp fin_detectar_colision
; 	colision_obstaculo:
; 		mov [colision], 01h
; 		jmp fin_detectar_colision
; 	colision_cuerpo:
; 		mov [colision], 02h
; 		jmp fin_detectar_colision
; 	colision_fruta:
; 		mov [colision], 03h
; 	fin_detectar_colision:
; endm



; ;se recibe dirección
; ;se incrementa/decrementa columna/renglon segun la direccion
; ;evalua colision
; ;si se da un putazo
; 	;no se actualiza viborita
; 	;fin del juego
; ;si come fruta
; 	;se actualiza viborita
; 	;se continua
; ;otro
; 	;se actualiza viborita
; 	;sigue el juego


; ;DESDE AQUÍ LO RELATIVO AL AVANCE DE LA VIBORA
; ; 18-12-2021 07:02 am - No tengo sueño, pero tampoco ganas... de vivir



; avance_snake macro		;puede cambiarse por un procedimiento o una etiqueta
; 	xor bx, bx
; 	xor dx, dx
; 	xor ax, ax
; 	mov al, [f_cabeza]
; 	mov ah, [c_cabeza]
; 	mov dx, [direccion]
	
; 	;00: derecha
; 	;01: arriba
; 	;10: izquierda
; 	;11: abajo

; 	;si va a la derecha
; 	cmp dx, 00h
; 	je a_la_derecha

; 	;si va a la izquierda
; 	cmp dx, 01h
; 	je a_la_izquierda

; 	;si va hacia abajo
; 	cmp dx, 10h
; 	je para_abajo

; 	;si va hacia arriba
; 	cmp dx, 11h
; 	je para_arriba

; 	a_la_derecha:
; 		inc ah
; 		jmp evaluar_colision
; 	a_la_izquierda:
; 		dec ah
; 		jmp evaluar_colision
; 	para_abajo:
; 		inc al
; 		jmp evaluar_colision
; 	para_arriba:
; 		dec al

; 	evaluar_colision:
; 		detectar_colision ah, al
; 		; 0 : sin colisión
; 		; 1 : colisión con el obstáculo
; 		; 2 : colisión con cola de viborita
; 		; 3 : colisión con fruta

; 		mov cx, [colision]
; 		;putazo con obstáculo
; 		cmp cx, 01h
; 		je FAIL 	;esto hay que implemetarlo xD

; 		;putazo con cuerpo
; 		cmp cx, 02h
; 		je FAIL

; 		;sin putazo
; 		cmp cx, 00h
; 		je actualizar_viborita

; 		;comer fruta
; 		inc tail_conta

; 		actualizar_viborita:
; 			update_snake
; 			jmp fin_avance_viborita
; 		crecer_viborita:
; 			rise_snake

; 	fin_avance_viborita:
; endm

; ;si no se aumenta el tamaño de la viborita
; update_snake macro
; 	mov si, [tail_conta]

; 	;En este punto:
; 	;- f_cabeza y c_cabeza : valores anteriores de cabeza
; 	;- AL y AH : valores nuevos de cabeza
; 	;- SI : valor de la cola
	
; 	;actualizacion de viborita en pantalla
; 	push ax		;se guarda el valor de ax
; 	;actualiza cabeza
; 	posiciona_cursor al, ah
; 	imprime_caracter_color 2, cVerdeClaro, bgNegro		;2 = cabeza maniaca

; 	;actualiza cuello
; 	posiciona_cursor [f_cabeza], [c_cabeza]
; 	imprime_caracter_color 254, cVerdeClaro, bgNegro	;254 = segmento de cuerpo

; 	;elimina cola
; 	mov bx, tail[0]
; 	posiciona_cursor bl, bh
; 	imprime_caracter_color 32d, cNegro, bgNegro		;32 = espacio en ASCII

; 	;actualización interna de la viborita
; 	;consideracion: el primer elemento del arreglo es el más alejado de la cabeza
; 	pop ax		;se recupera el valor de ax
; 	mov cx, si 	;contador = tamaño de cola
	
; 	;dado que [tail] es de tamaño word nos debemos mover en él de 2 en 2
; 	shl si, 2 		;corrimiento a la izquierda = si * 2

; 	xor bx, bx
; 	xor dx, dx
; 	mov dl, [f_cabeza]
; 	mov dh, [c_cabeza]

; 	mov bx, tail[si]
; 	mov tail[si], dx

; 	sub si, 02h
; 	dec cx

; 	loop_cola:	;revisar si este loop es correcto para la última iteración
; 		mov dx, tail[si]
; 		mov tail[si], bx
; 		mov bx, dx
; 		sub si, 02h
; 		loop loop_cola

; 	;actualizacion de la cabeza
; 	mov [f_cabeza], al 
; 	mov [c_cabeza], ah
; endm


; ;si se aumenta el tamaño de la viborita
; rise_snake macro
; 	mov si, [tail_conta]

; 	;En este punto:
; 	;- f_cabeza y c_cabeza : valores anteriores de cabeza
; 	;- AL y AH : valores nuevos de cabeza
; 	;- SI : valor de la cola
	
; 	;actualizacion de viborita en pantalla
; 	push ax		;se guarda el valor de ax
; 	;actualiza cabeza
; 	posiciona_cursor al, ah
; 	imprime_caracter_color 2, cVerdeClaro, bgNegro		;2 = cabeza maniaca

; 	;actualiza cuello
; 	posiciona_cursor [f_cabeza], [c_cabeza]
; 	imprime_caracter_color 254, cVerdeClaro, bgNegro	;254 = segmento de cuerpo

; 	;no se elimina la punta de la cola

; 	;actualización interna de la viborita
; 	;consideracion: el primer elemento del arreglo es el más alejado de la cabeza
; 	;más consideraciones:
; 	;- en este caso el primer elemento debe permanecer intacto


; 	pop ax		;se recupera el valor de ax
; 	mov cx, si 	;contador = tamaño de cola
	
; 	;dado que [tail] es de tamaño word nos debemos mover en él de 2 en 2
; 	shl si, 2 		;corrimiento a la izquierda = si * 2

; 	xor bx, bx
; 	xor dx, dx
; 	mov dl, [f_cabeza]
; 	mov dh, [c_cabeza]

; 	mov bx, tail[si-2]		;necesito el desplazamiento «-2» donde lo uso, pero no sé si es correcta la sintaxis
; 	mov tail[si], dx		;se ignora el espacio sin "coordenadas" del segmento agregado

; 	sub si, 02h		;para lo que quiero hacer no estoy seguro si debe ser 02h o 04h
; 	sub cx, 02h		;esto es para que ignore la punta de la cola

; 	loop_cola_end:	;revisar si este loop es correcto para la última iteración
; 		mov dx, tail[si-2]
; 		mov tail[si], bx
; 		mov bx, dx
; 		sub si, 02h
; 		loop loop_cola_end

; 	;actualizacion de la cabeza
; 	mov [f_cabeza], al 
; 	mov [c_cabeza], ah
; endm

;NOTAS IMPORTANTES del funcionamiento - idea
	;pisición 0 es la mas alejada de la cabeza
	;si no se come fruta, se actualizan los valores
		;en impresion: se borra la punta de la cola y se actualiza el cuello

	;si se come fruta, no se actualizan los valores y se agrega un elemento al frente de la cola
		;en impresión: sólo se actualiza el cuello

	;para borrar, gráficamente la punta de la cola se usan las coordenadas de esta (anteriores) y se mata lo que halla ahí

	;usas la funcion de colocar item para cuello, punta y cabeza

	;actualizar cabeza al final


;======================================================================================================================
;======================================================================================================================
;FIN DE MACROS
;======================================================================================================================
;======================================================================================================================

