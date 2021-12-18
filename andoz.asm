title "Proyecto: Snake" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definición de constantes
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h

;Número de columnas para el área de controles
area_controles_ancho 		equ 	20d

;Área de juego
top 			db		1d
bottom			db		23d
left			db		21d 
right			db		78d

;Definicion de variables
;Títulos
nameStr			db 		"SNAKE"
recordStr 		db 		"HI-SCORE"
scoreStr 		db 		"SCORE"
levelStr 		db 		"LEVEL"
speedStr 		db 		"SPEED"

;Variables auxiliares para posicionar cursor al imprimir en pantalla
col_aux  		db 		0
ren_aux 		db 		0

conta 			db 		0 		;contador auxiliar
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;dato de valor decimal 1000 para operación DIV entre 1000
diez 			dw 		10  	;dato de valor decimal 10 para operación DIV entre 10
sesenta			db 		60 		;dato de valor decimal 60 para operación DIV entre 60
novNueve		db 		99      ;dato de valor decimal 90 para controlar velocidad
status 			db 		0 		;0 stop-pause, 1 activo
colision 		db 		0 		;indicador de colisión
direccion		db 		?		;Indicador de la dirección de la serpiente; 
contempo		db 		?		;Contador de ciclos en temporizador
contempo_aux 	db 		?					

;Variables para el juego
score 			dw 		?
hi_score	 	dw 		?
speed 			db 		?

;Variable 'head' de 16 bits. Datos de la cabeza de la serpiente
;Valor inicial: 00 00 0010111 01100b
head_x 			db 		?
head_y			db		?
head_x_temp		db 		?
head_y_temp		db 		?
;Bits 0-4: Posición del renglón (0-24d)
;Bits 5-11: Posición de la columna (0-79d)
;Bits 12-13: Dirección del siguiente movimiento
	;00: derecha
	;01: arriba
	;10: izquierda
	;11: abajo
;Bits 14-15: No definidos
;Posición inicial: renglón 12, columna 23, dirección derecha

;Datos de la cola de la serpiente
;los primeros dos valores son fijos y se imprimen al inicio del juego
;el resto se deben calcular conforme avanza el juego
;El primer elemento del arreglo 'tail' es el extremo de la cola, el siguiente es el más cercano a la cola, y así sucesivamente.
tail 			dw 		0001010100001100b,0001011000001100b,1355 dup(0)
tail_x_temp		db 		?
tail_y_temp		db 		?
tail_conta 		dw 		?  	;contador para la longitud de la cola
tail_conta_aux	dw		?	;contador auxiliar

;variables para las coordenadas del objeto actual en pantalla
item_col 		db 		25  	;columna [21 - 78d]
item_ren 		db 		16 		;renglon [1 - 23d]
;agregar método para que se de un número pseudoaleatorio

;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0 		;caracter a imprimir
boton_renglon 	db 		0 		;renglon de la posicion inicial del boton
boton_columna 	db 		0 		;columna de la posicion inicial del boton
boton_color		db 		0  		;color del caracter a imprimir dentro del boton
boton_bg_color	db 		0 		;color del fondo del boton

;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8
;Cuando el driver del mouse no esta disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'
pausita			db 	'PAUSA     $'
termina			db 	'STOP      $'
jugar			db 	'PLAY      $'
arribita		db 	'ARRIBA    $'
abajito			db 	'ABAJO     $'
izq				db 	'IZQUIERDA $'
der				db 	'DERECHA   $'
perdiste		db 	'PERDISTE$'
nada			db 	'          $'




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
	xor bx, bx 			;BX = 0
	mov ah, 2Ch			;Opción '2C': obtener hora del sistema
	int 21h
	;dl: centésimas de segundo [0 - 99]
	xor ah, ah
	mov al, dl 			;AL = random
	mov bh, [lim_sup]	;BH = lim_sup
	mov bl, [lim_inf]	;BL = lim_inf

	inc bh 				;BH = lim_sup + 1
	sub bh, bl			;BH = lim_sup - lim_inf + 1
	div bh 				;AH = random % (lim_sup - lim_inf + 1)
	add bl, ah 			;BL = lim_inf + random % (lim_sup - lim_inf + 1)
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
			push bx 			;se guarda en la pila dado que algunos porcedimientos modifican bx
			mov ax, [bx]
		
			cmp fila, al 
			je verif_colum_coda
			jmp condicion_loop

			verif_colum_coda:
				cmp columna, ah 
				je colision_Coda

			condicion_loop:
				pop bx 					;se recupera el valor de bx
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
endm


;======================================================================================================================
;======================================================================================================================
;FIN DE MACROS
;======================================================================================================================
;======================================================================================================================







	.code
		inicio:					;etiqueta inicio
			inicializa_ds_es 	;inicializa registros DS y ES
			comprueba_mouse		;macro para revisar driver de mouse
			xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
			jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
			;Si no existe el driver del mouse entonces se muestra un mensaje
			lea dx,[no_mouse]
			mov ax,0900h	;opcion 9 para interrupcion 21h
			int 21h			;interrupcion 21h. Imprime cadena.
			jmp fin			;salta a 'fin'

		imprime_ui:
			clear 					;limpia pantalla y establece modo video en AX
			oculta_cursor_teclado	;oculta cursor del mouse
			apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
			call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz
			muestra_cursor_mouse 	;hace visible el cursor del mouse
			posiciona_cursor_mouse 10d,0d	;establece la posición del mouse en la posición
		;Revisar que el boton izquierdo del mouse no esté presionado
		;Si el botón no está suelto, no continúa

		mouse_no_clic:
			lee_mouse
			test bx,0001h
			jnz mouse_no_clic
			;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo

		mouse:
			lee_mouse

		conversion_mouse:
			;Leer la posicion del mouse y hacer la conversion a resolucion
			;80x25 (columnas x renglones) en modo texto
			mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
			div [ocho] 			;Division de 8 bits
								;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
								;para obtener el valor correspondiente en resolucion 80x25
			xor ah,ah 			;Descartar el residuo de la division anterior
			mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

			mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
			div [ocho] 			;Division de 8 bits
								;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
								;para obtener el valor correspondiente en resolucion 80x25
			xor ah,ah 			;Descartar el residuo de la division anterior
			mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

			test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
			jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;Aqui va la lógica de la posicion del mouse;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			;Si se presiona SALIR
			cmp dx,0
			je boton_x
			

			;Si se da clic sobre botones de speed
			cmp dx,11; Filas de botones
			je vel
			cmp dx,12
			je vel
			cmp dx,13
			je vel

			;Si se da clic sobre botones de pausa,stop,play
			cmp dx,19 ; Filas de botones
			je flujo
			cmp dx,20
			je flujo
			cmp dx,21
			je flujo

			jmp mouse_no_clic


		;Lógica para revisar si el mouse fue presionado en [SALIR]
		;[SALIR] se encuentra en renglon 0 y entre columnas 13 y 19
		boton_x:
			jmp boton_x1

		boton_x1:
			cmp cx,13
			jge boton_x2
			jmp mouse_no_clic

		boton_x2:
			cmp cx,19
			jbe boton_x3
			jmp mouse_no_clic

		boton_x3:
			;Se cumplieron todas las condiciones
			jmp salir

		;Lógica para revisar si el mouse presiona flechas
		;Ambos botones están en los renglones 11 - 13
		vel:
			jmp vel1

		vel1:
			cmp cx,12; Columnas
			jge vel2
			cmp cx,15
			jge vel2
			jmp mouse_no_clic

		vel2:
			cmp cx,15; Columnas
			jz	mouse_no_clic
			cmp cx,14
			jbe velAbajo
			cmp cx,18
			jbe velArriba
			jmp mouse_no_clic

		velAbajo:
			;Se cumplieron todas las condiciones de izquierda
			;Si speed es 0
			cmp [speed],1
			jz mouse_no_clic
			dec [speed]
			inc [contempo]
			call IMPRIME_SPEED
			jmp mouse_no_clic

		velArriba:
			;Se cumplieron todas las condiciones de derecha
			inc [speed]
			dec [contempo]
			call IMPRIME_SPEED
			jmp mouse_no_clic

		;Lógica para revisar botones de control (pausa, stop y play)
		;Ambos botones están en los renglones 19 - 21
		flujo:
			jmp flujo1

		flujo1: ;COLUMNAS DE PLAY EN ADELANTE
			cmp cx,3
			jge flujo2
			cmp cx,9
			jge flujo2
			cmp cx,15
			jge flujo2
			jmp mouse_no_clic

		flujo2:	
			cmp cx,6
			jz	mouse_no_clic
			cmp cx,7
			jz	mouse_no_clic
			cmp cx,8
			jz	mouse_no_clic; SI ES EL ESPACIO DE EN MEDIO NO HACE NADA
			cmp cx,12
			jz	mouse_no_clic
			cmp cx,13
			jz	mouse_no_clic
			cmp cx,14
			jz	mouse_no_clic

			cmp cx,6
			jbe PAUSA
			cmp cx,12
			jbe STOP
			cmp cx,17
			jbe PLAY
			jmp mouse_no_clic


		PAUSA: 
			;Se cumplieron todas las condiciones de pausa
			;Si speed es 0
			posiciona_cursor 11,120
			imprime_cadena_color pausita,10,cGrisClaro,bgNegro
			jmp mouse_no_clic

		STOP:
			;Se cumplieron todas las condiciones de stop
			;posiciona_cursor 11,120
			;imprime_cadena_color termina,10,cGrisClaro,bgNegro
			jmp inicio

		PLAY:
			;Se cumplieron todas las condiciones de play
			posiciona_cursor 11,120
			imprime_cadena_color nada,10,cGrisClaro,bgNegro

		PLAY2:
			call IMPRIME_PLAYER
			detectar_colision [head_y],[head_x]
			cmp colision,1 ; colisión con el marco
			jz FAIL
			cmp colision,2 ;colisión con cola de viborita
			jz FAIL

			detectar_colision [head_y],[head_x]
			cmp colision,4; Colisión con la fruta
			jz sigue		;Si se colisiona con fruta, se imprime un nuevo item

            call lee_teclado
            ;Una vez leído el teclado, se evalúa la tecla presionada
			cmp bp,32; Tecla derecha
			jz derecha
			cmp bp,30; Tecla izquierda
			jz izquierda
			cmp bp,17; Tecla arriba
			jz arriba
			cmp bp,31; Tecla abajo
			jz abajo
			cmp bp,25; La tecla "p" pausa el juego. Se deja de leer teclado y se lee mouse
			jz PAUSA

			jmp PLAY2

			derecha:
				;posiciona_cursor 11,120
				;imprime_cadena_color der,10,cGrisClaro,bgNegro
				mov [direccion],1
				jmp PLAY

			izquierda:
				;posiciona_cursor 11,120
				;imprime_cadena_color izq,10,cGrisClaro,bgNegro
				mov [direccion],2
				jmp PLAY2

			arriba:
				;posiciona_cursor 11,120
				;imprime_cadena_color arribita,10,cGrisClaro,bgNegro
				mov [direccion],3
				jmp PLAY2

			abajo:
				;posiciona_cursor 11,120
				;imprime_cadena_color abajito,10,cGrisClaro,bgNegro
				mov [direccion],4
				jmp PLAY2

			sigue:
				call IMPRIME_ITEM
				inc tail_conta
				inc score
				call IMPRIME_SCORE
				jmp PLAY2

			FAIL:
				posiciona_cursor 11,120
				imprime_cadena_color perdiste,8,cBlanco,bgRojoClaro

				mov contempo,30
				temporizador
				jmp STOP

		;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
		fin:
			mov ah,08h
			int 21h 		;opción 08h int 21h. Lee carácter del teclado sin eco
			cmp al,0Dh		;compara la entrada de teclado si fue [enter]
			jnz fin 		;Sale del ciclo hasta que presiona la tecla [enter]

		salir:				;inicia etiqueta salir
			clear 			;limpia pantalla
			mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
			int 21h			;señal 21h de interrupción, pasa el control al sistema operativo






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	lee_teclado proc 
		push ax
	    push bx
	    push es

	    mov ax, 40h                
	    mov es, ax                  ;access keyboard data area via segment 40h
	    mov WORD PTR es:[1ah], 1eh  ;set the kbd buff head to start of buff
	    mov WORD PTR es:[1ch], 1eh  ;set the kbd buff tail to same as buff head
	                                ;the keyboard typehead buffer is now cleared
	    xor ah, ah
	    in al, 60h                  ;al -> scancode
	    test al, 80h                ;Is a break code in al?
	    jz ACCEPT_KEY               ;If not, accept it. 
	                                ;If so, check to see if it's the break code
	                                ;that corresponds with the make code in bp.
	    mov bx, bp                  ;bx -> make code   
	    or bl, 80h                  ;change make code into it's break code  
	    cmp bl, al                  ;Do the new and old break codes match?
	    je ACCEPT_KEY               ;If so, accept the break code.
	    pop es                      ;If not, bp retains old make code.
	    pop bx
	    pop ax
	    ret

	ACCEPT_KEY: 
	    mov bp, ax                  ;bp -> scancode, accessible globally

	    pop es
	    pop bx
	    pop ax
	    ret
	endp


	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cAzulClaro,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cAzulClaro,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cAzulClaro,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cAzulClaro,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 

		marcos_horizontales:;Imprime de derecha a izquierda y alternadamente el =
			mov [col_aux],cl
			;Superior
			posiciona_cursor 0,[col_aux]
			imprime_caracter_color marcoHor,cAzulClaro,bgNegro
			;Inferior
			posiciona_cursor 24,[col_aux]
			imprime_caracter_color marcoHor,cAzulClaro,bgNegro
			mov cl,[col_aux]
			loop marcos_horizontales

			;imprimir marcos verticales, derecho e izquierdo
			mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 

		marcos_verticales:;Imprime de abajo a arriba a y alternadamente el ||.
			mov [ren_aux],cl
			;Izquierdo
			posiciona_cursor [ren_aux],0
			imprime_caracter_color marcoVer,cAzulClaro,bgNegro
			;Inferior
			posiciona_cursor [ren_aux],79
			imprime_caracter_color marcoVer,cAzulClaro,bgNegro
			
			;Interno
			posiciona_cursor [ren_aux],area_controles_ancho
			imprime_caracter_color marcoVer,cAzulClaro,bgNegro
			mov cl,[ren_aux]
			loop marcos_verticales

			;imprimir marcos horizontales internos
			mov cx,area_controles_ancho 		;CX = 0014h => CH = 00h, CL = 14h 

		marcos_horizontales_internos:
			mov [col_aux],cl

			;Interno izquierdo (marcador player 1)
			posiciona_cursor 4,[col_aux]
			imprime_caracter_color marcoHor,cAzulClaro,bgNegro

			;Interno izquierdo (marcador player 1)
			posiciona_cursor 8,[col_aux]
			imprime_caracter_color marcoHor,cAzulClaro,bgNegro

			;Interno derecho (marcador player 2)
			posiciona_cursor 16,[col_aux]
			imprime_caracter_color marcoHor,cAzulClaro,bgNegro

			mov cl,[col_aux]
			loop marcos_horizontales_internos

			;imprime intersecciones internas	
			posiciona_cursor 0,area_controles_ancho
			imprime_caracter_color marcoCruceVerSup,cAzulClaro,bgNegro
			posiciona_cursor 24,area_controles_ancho
			imprime_caracter_color marcoCruceVerInf,cAzulClaro,bgNegro

			posiciona_cursor 4,0
			imprime_caracter_color marcoCruceHorIzq,cAzulClaro,bgNegro
			posiciona_cursor 4,area_controles_ancho
			imprime_caracter_color marcoCruceHorDer,cAzulClaro,bgNegro

			posiciona_cursor 8,0
			imprime_caracter_color marcoCruceHorIzq,cAzulClaro,bgNegro
			posiciona_cursor 8,area_controles_ancho
			imprime_caracter_color marcoCruceHorDer,cAzulClaro,bgNegro

			posiciona_cursor 16,0
			imprime_caracter_color marcoCruceHorIzq,cAzulClaro,bgNegro
			posiciona_cursor 16,area_controles_ancho
			imprime_caracter_color marcoCruceHorDer,cAzulClaro,bgNegro

			;imprimir [X] para cerrar programa
			posiciona_cursor 0,13
			imprime_caracter_color '[',cAzulClaro,bgNegro
			posiciona_cursor 0,14
			imprime_caracter_color 'S',cRojoClaro,bgNegro
			posiciona_cursor 0,15
			imprime_caracter_color 'A',cRojoClaro,bgNegro
			posiciona_cursor 0,16
			imprime_caracter_color 'L',cRojoClaro,bgNegro
			posiciona_cursor 0,17
			imprime_caracter_color 'I',cRojoClaro,bgNegro
			posiciona_cursor 0,18
			imprime_caracter_color 'R',cRojoClaro,bgNegro
			posiciona_cursor 0,19
			imprime_caracter_color ']',cAzulClaro,bgNegro

			;imprimir título
			posiciona_cursor 0,38
			imprime_cadena_color [nameStr],5,cCyanClaro,bgNegro

		call IMPRIME_DATOS_INICIALES
		ret
	endp

	;Reinicia scores y speed, e imprime
	DATOS_INICIALES proc
		mov [score],0
		mov [hi_score],0
		mov [speed],1
		mov [head_x],23 
		mov [head_y],12
		mov [head_x_temp],1;Inicialmente, el borrado de la cabeza está en un lugar diferente
		mov [head_y_temp],1
		mov [tail_conta], 2  	;contador para la longitud de la cola
		mov [direccion],0 	; No se dirige a ningún lado
		mov [contempo],10 	;contempo en un inicio es 10 (la velocidad más baja)

		call IMPRIME_SCORE
		call IMPRIME_HISCORE
		call IMPRIME_SPEED
		ret
	endp

	;Imprime la información inicial del programa
	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES

		;imprime cadena 'HI-SCORE'
		posiciona_cursor 2,3
		imprime_cadena_color recordStr,8,cGrisClaro,bgNegro

		;imprime cadena 'SCORE'
		posiciona_cursor 6,5
		imprime_cadena_color scoreStr,5,cGrisClaro,bgNegro

		;imprime cadena 'SPEED'
		posiciona_cursor 12,3
		imprime_cadena_color speedStr,5,cGrisClaro,bgNegro
		
		;imprime viborita
		call IMPRIME_PLAYER

		;imprime ítem
		call IMPRIME_ITEM

		;Botón Speed down
		mov [boton_caracter],31 		;▼
		mov [boton_color],bgAmarillo
		mov [boton_renglon],11
		mov [boton_columna],12
		call IMPRIME_BOTON

		;Botón Speed UP
		mov [boton_caracter],30 		;▲
		mov [boton_color],bgAmarillo
		mov [boton_renglon],11
		mov [boton_columna],16
		call IMPRIME_BOTON

		;Botón Pause
		mov [boton_caracter],186 		;║
		mov [boton_color],bgAmarillo
		mov [boton_renglon],19
		mov [boton_columna],3
		call IMPRIME_BOTON

		;Botón Stop
		mov [boton_caracter],254d 		;■
		mov [boton_color],bgAmarillo
		mov [boton_renglon],19
		mov [boton_columna],9
		call IMPRIME_BOTON

		;Botón Start
		mov [boton_caracter],16d 		;►
		mov [boton_color],bgAmarillo
		mov [boton_renglon],19
		mov [boton_columna],15
		call IMPRIME_BOTON

		ret
	endp

	;Procedimiento utilizado para imprimir el score actual
	;Establece las coordenadas en variables auxiliares en donde comienza a imprimir.
	;Pone el valor en BX que se imprime con el procedimiento IMPRIME_SCORE_BX
	IMPRIME_SCORE proc
		mov [ren_aux],6
		mov [col_aux],12
		mov bx,[score]
		call IMPRIME_SCORE_BX
		ret
	endp

	;Procedimiento utilizado para imprimir el score global HI-SCORE
	;Establece las coordenadas en variables auxiliares en donde comienza a imprimir.
	;Pone el valor en BX que se imprime con el procedimiento IMPRIME_SCORE_BX
	IMPRIME_HISCORE proc
		mov [ren_aux],2
		mov [col_aux],12
		mov bx,[hi_score]
		call IMPRIME_SCORE_BX
		ret
	endp

	;Imprime el valor contenido en BX. El score tiene que estar en BX.
	;Se imprime un valor de 5 dígitos. Si el número es menor a 10000, se completan los 5 dígitos con ceros a la izquierda
	IMPRIME_SCORE_BX proc
		mov ax,bx 		;AX = BX
		mov cx,5 		;CX = 5. Se realizan 5 divisiones entre 10 para obtener los 5 dígitos
		;En el bloque div10, se obtiene los dígitos del número haciendo divisiones entre 10 y se almacenan en la pila
		div10:
			xor dx,dx
			div [diez]
			push dx
			loop div10
			mov cx,5
		;En el bloque imprime_digito, se recuperan los dígitos anteriores calculados para imprimirse en pantalla.
		imprime_digito:
			mov [conta],cl
			posiciona_cursor [ren_aux],[col_aux]
			pop dx
			or dl,30h
			imprime_caracter_color dl,cBlanco,bgNegro
			xor ch,ch
			mov cl,[conta]
			inc [col_aux]
			loop imprime_digito
			ret
	endp

	;Procedimiento para imprimir el valor de SPEED en pantalla
	;Se imprime en dos caracteres.
	;La variable speed es de tipo byte, su valor puede ser hasta 255d, pero solo se requieren dos dígitos
	;si speed es mayor a igual a 100d, se limita a establecerse en 99d
	IMPRIME_SPEED proc
		;Coordenadas en donde se imprime el valor de speed
		mov [ren_aux],12
		mov [col_aux],9
		;Si speed es mayor o igual a 100, se limita a 99
		cmp [speed],11d
		jb continua
		mov [speed],10d
		mov [contempo],1d
		continua:
			;posiciona el cursor en la posición a imprimir
			posiciona_cursor [ren_aux],[col_aux]
			;Se convierte el valor de 'speed' a ASCII
			xor ah,ah 		;AH = 00h
			mov al,[speed] 	;AL = [speed]
			aam 			;AH: Decenas, AL: Unidades
			push ax 		;guarda AX temporalmente
			mov dl,ah 		;Decenas en DL
			or dl,30h 		;Convierte BCD a su ASCII
			imprime_caracter_color dl,cBlanco,bgNegro
			inc [col_aux] 	;Desplaza la columna a la derecha
			posiciona_cursor [ren_aux],[col_aux]
			pop dx 			;recupera valor de la pila
			or dl,30h  	 	;Convierte BCD a su ASCII, DL están las unidades
			imprime_caracter_color dl,cBlanco,bgNegro
		ret
	endp

	;Imprime viborita
	IMPRIME_PLAYER proc
		call IMPRIME_HEAD 
		call IMPRIME_TAIL
		;call BORRA_PLAYER; Se borra la posición anterior de PLAYER
		ret
	endp

	;Imprime la cabeza de la serpiente
	IMPRIME_HEAD proc
		cmp [direccion],0; No se dirige
		jz imprime
		cmp [direccion],1; DERECHA
		jz dirDerecha
		cmp [direccion],2; IZQUIERDA
		jz dirIzquierda
		cmp [direccion],3; ARRIBA
		jz dirArriba
		cmp [direccion],4; ABAJO
		jz dirAbajo

		dirDerecha:
			;Se guarda la posición original antes de cambiar
			mov ah,head_x
			mov [head_x_temp],ah
			mov ah,head_y
			mov [head_y_temp],ah
			inc head_x; DERECHA
			jmp imprime 

		dirIzquierda:
			;Se guarda la posición original antes de cambiar
			mov ah,head_x
			mov [head_x_temp],ah
			mov ah,head_y
			mov [head_y_temp],ah
			dec head_x; IZQUIERDA
			jmp imprime

		dirArriba:
			;Se guarda la posición original antes de cambiar
			mov ah,head_x
			mov [head_x_temp],ah
			mov ah,head_y
			mov [head_y_temp],ah
			dec head_y; SUBE
			jmp imprime

		dirAbajo:
			;Se guarda la posición original antes de cambiar
			mov ah,head_x
			mov [head_x_temp],ah
			mov ah,head_y
			mov [head_y_temp],ah
			inc head_y; BAJA
			jmp imprime

		imprime:
			posiciona_cursor [head_y],[head_x]
			imprime_caracter_color 2,cVerdeClaro,bgNegro
			posiciona_cursor [head_y_temp],[head_x_temp]
			imprime_caracter_color 254,cVerdeClaro,bgNegro
			temporizador

		ret
	endp

	;Imprime el cuerpo/cola de la serpiente
	;Cada valor del arreglo 'tail' iniciando en el primer elemento es un elemento del cuerpo/cola
	;Los valores establecidos en 0 son espacios reservados para el resto de los elementos.
	;Se imprimen todos los elementos iniciando en el primero, hasta que se encuentre un 0 
	IMPRIME_TAIL proc
		cmp [direccion],0; Si no se mueve la serpiente
		jz imprimeCola

		xor cx,cx
		mov cx,[tail_conta]
		mov [tail_conta_aux],cx
		xor si,si
		mov si,[tail_conta]; SI = ultimo elemento de la cola (de izquierda a derecha)
		;Se revisan los elementos de la cola derecha a izquierda
		;tail bits,bits,bits,bits,bits,1555dup(0)
		mueveSerpiente:
			;SE GUARDA LA POSICIÓN DE LA COLA
			xor cx,cx
			mov cx,tail[si]; Posición anterior a la cabeza (última posición de la cadena)
			;CH -> coordenada x
			;CL -> coordenada y
			mov [tail_x_temp],ch
			mov [tail_y_temp],cl

			xor cx,cx
			mov ch,[head_x_temp]
			mov cl,[head_y_temp]
			;CX ahora tiene la direccion de la cabeza
			mov tail[si],cx; El último elemento de la cadena se sobreescribe con
							; las direcciones de la cabeza

			;Se pasa la dirección del elemento revisado como "cabeza"
			mov ch,[tail_x_temp]
			mov cl,[tail_y_temp]
			mov [head_x_temp],ch
			mov [head_y_temp],cl
			dec si; Se revisa elemento que sigue (de derecha a izquierda) 
			cmp si,0
			jge mueveSerpiente
			call BORRA_PLAYER
			
		imprimeCola:
			lea bx, [tail]		;posición de la cadena en el registro ds
			loop_tail:
				push bx 			;se guarda en la pila dado que algunos porcedimientos modifican bx
				mov ax,[bx]
				mov [ren_aux], al
				mov [col_aux], ah

				posiciona_cursor [ren_aux],[col_aux]
				imprime_caracter_color 254,cVerdeClaro,bgNegro

				pop bx 					;se recupera el valor de bx
				add bx, 2 				;se avanza al siguiente elemento
				cmp word ptr [bx], 0 	;se compara hasta encontrar un valor igual a 0 (no inicializado de la viborita)
				jne loop_tail
	ret
	endp

	;Borra la serpiente para reimprimirla en una posición actualizada
	BORRA_PLAYER proc
		mov si,0001h
		mov cx,tail[si]
		mov [ren_aux], cl
		mov [col_aux], ch
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 254,cNegro,bgNegro

		pop bx 					;se recupera el valor de bx
		ret
	endp

	;Imprime objeto en pantalla
	IMPRIME_ITEM proc
		push bx
		intento:
			;columna [21d - 78d]
			numero_aleatorio left, right
			mov [item_col], bl 	;se asigna la posición de columna del item

			;fila [1 - 23d]
			numero_aleatorio top, bottom
			mov [item_ren], bl 	;se asigna la posición de renglon del item

			detectar_colision [item_ren], [item_col]
			cmp colision, 2h 
			je intento

		posiciona_cursor [item_ren], [item_col]
		imprime_caracter_color 3, cRojoClaro, bgNegro
		pop bx
		ret
	endp

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	end inicio			;fin de etiqueta inicio, fin de programa