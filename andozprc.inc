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
		mov [speed],8
		mov [head_x],23 
		mov [head_y],12
		mov [head_x_temp],22;Inicialmente, el borrado de la cabeza está en un lugar diferente
		mov [head_y_temp],12
		mov [tail_conta], 2  	;contador para la longitud de la cola
		mov [direccion],0 	; No se dirige a ningún lado
		mov [contempo],10 	;contempo en un inicio es 10 (la velocidad más baja)

		xor si,si
		mov tail[si],0001010100001100b	;Primer elemento de la cola
		add si,2
		mov tail[si],0001011000001100b  ;Segundo elemento de la cola

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
		call BORRA_PLAYER
		xor si,si
		mov si,[tail_conta]; SI = ultimo elemento de la cola (de izquierda a derecha)
		dec si
		shl si,1
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
			sub si,2
			cmp si,0
			jge mueveSerpiente
			
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
		borraCola:
			lea bx, [tail]		;posición de la cadena en el registro ds
			loop_tail2:
				push bx 			;se guarda en la pila dado que algunos porcedimientos modifican bx
				mov ax,[bx]
				mov [ren_aux], al
				mov [col_aux], ah

				posiciona_cursor [ren_aux],[col_aux]
				imprime_caracter_color 254,cNegro,bgNegro

				pop bx 					;se recupera el valor de bx
				add bx, 2 				;se avanza al siguiente elemento
				cmp word ptr [bx], 0 	;se compara hasta encontrar un valor igual a 0 (no inicializado de la viborita)
				jne loop_tail2
		ret
	endp

	;Imprime objeto en pantalla
	IMPRIME_ITEM proc
		intento:
			;columna [21d - 78d]
			numero_aleatorio left, right
			mov [item_col], cl 	;se asigna la posición de columna del item

			;fila [1 - 23d]
			numero_aleatorio top, bottom
			mov [item_ren], cl 	;se asigna la posición de renglon del item

			detectar_colision [item_ren], [item_col]
			cmp colision, 2h 
			je intento

		posiciona_cursor [item_ren], [item_col]
		imprime_caracter_color 3, cRojoClaro, bgNegro
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