title "Proyecto: Snake" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos

	include andozgfx.inc    ; Archivo con variables de los gráficos

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
colision 		dw 		0 		;indicador de colisión
contempo		db 		?		;Contador de ciclos en temporizador
contempo_aux 	db 		?					

;Variables para el juego
score 			dw 		0000h
hi_score	 	dw 		0000h
speed 			db 		?

f_cabeza db 0 	;estas dos variables se deben cambiar 
c_cabeza db 0 	;por las que uses para indicar la coordenada de la cabeza

direccion dw 0 	;y estás dos ya están en el código



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
perdiste		db 	'PERDISTE  $'
nada			db 	'          $'



	include andozmac.inc    ; Archivo con macros

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
			xor cx,cx
			mov cx,score
			mov [hi_score],cx
			jmp inicio

		START:
			;Se cumplieron todas las condiciones de play
			posiciona_cursor 11,120
			imprime_cadena_color nada,10,cGrisClaro,bgNegro

		PLAY:	
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

			jmp PLAY

			derecha:
				;posiciona_cursor 11,120
				;imprime_cadena_color der,10,cGrisClaro,bgNegro
				mov [direccion],1
				jmp START

			izquierda:
				;posiciona_cursor 11,120
				;imprime_cadena_color izq,10,cGrisClaro,bgNegro
				mov [direccion],2
				jmp PLAY

			arriba:
				;posiciona_cursor 11,120
				;imprime_cadena_color arribita,10,cGrisClaro,bgNegro
				mov [direccion],3
				jmp PLAY

			abajo:
				;posiciona_cursor 11,120
				;imprime_cadena_color abajito,10,cGrisClaro,bgNegro
				mov [direccion],4
				jmp PLAY

			sigue:
				call IMPRIME_ITEM
				inc tail_conta
				inc score
				call IMPRIME_SCORE
				jmp PLAY

			FAIL:
				posiciona_cursor 11,120
				imprime_cadena_color perdiste,8,cBlanco,bgRojoClaro
				call BORRA_PLAYER

				xor si,si
				add si,4; Omite los dos primeros elementos
				xor cx,cx
				mov cx,tail_conta
				sub cx,2
				loopReinicio:
					mov tail[si],0000h
					cmp tail[si+2],0
					add si,2
					loop loopReinicio

				mov contempo,30
				temporizador

				mov cx,score
				cmp cx,hi_score; SI el nuevo score es mayor que hi-score
				jge STOP

				jmp inicio

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




		include andozprc.inc     ; Archivo con procedimientos



	end inicio			;fin de etiqueta inicio, fin de programa