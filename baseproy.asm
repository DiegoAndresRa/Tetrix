title "Proyecto: Tetris" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 512 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		30
;Valores de referencia para la posición inicial de la primera pieza
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	1

;Valores para la posición de los controles e indicadores dentro del juego
;Next
next_col 		equ  	lim_derecho+7
next_ren 		equ  	4

;Data
hiscore_ren	 	equ 	10
hiscore_col 	equ 	lim_derecho+7
level_ren	 	equ 	12
level_col 		equ 	lim_derecho+7
lines_ren	 	equ 	14
lines_col 		equ 	lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+15
stop_ren 		equ 	lim_inferior-4
stop_izq 		equ 	stop_col
stop_der 		equ 	stop_col+2
stop_sup 		equ 	stop_ren
stop_inf 		equ 	stop_ren+2

;Botón PAUSE
pause_col 		equ 	lim_derecho+25
pause_ren 		equ 	lim_inferior-4
pause_izq 		equ 	pause_col
pause_der 		equ 	pause_col+2
pause_sup 		equ 	pause_ren
pause_inf 		equ 	pause_ren+2

;Botón PLAY
play_col 		equ 	lim_derecho+35
play_ren 		equ 	lim_inferior-4
play_izq 		equ 	play_col
play_der 		equ 	play_col+2
play_sup 		equ 	play_ren
play_inf 		equ 	play_ren+2

;Piezas
linea 			equ 	0
cuadro 			equ 	1
lnormal 		equ 	2
linvertida	 	equ 	3
tnormal 		equ 	4
snormal 		equ 	5
sinvertida 		equ 	6
linea_g1		equ		7
lnormal_g1		equ 	8
lnormal_g2		equ		9
lnormal_g3		equ		10
linv_g1			equ 	11
linv_g2			equ		12
linv_g3			equ		13
t_g1			equ 	14
t_g2			equ		15
t_g3			equ		16
sn_g1 			equ		17
sinv_g1 		equ		18
cuadro_g1 		equ		19

;Invertir
uno_neg			equ 	-1

;status
paro 			equ 	0
activo 			equ 	1
pausa			equ 	2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;////////////////////////////////////////////////////
;Definición de variables
;////////////////////////////////////////////////////
titulo 			db 		"TETRIS"
finTitulo 		db 		""
levelStr 		db 		"LEVEL"
finLevelStr 	db 		""
linesStr 		db 		"LINES"
finLinesStr 	db 		""
hiscoreStr		db 		"HI-SCORE"
finHiscoreStr 	db 		""
nextStr			db 		"NEXT"
finNextStr 		db 		""
blank			db 		"     "
lines_score 	dw 		0
hiscore 		dw 		0
speed 			dw 		4
next 			db 		2

;Coordenadas de la posición de referencia para la pieza en el área de juego
pieza_col		db 		ini_columna
pieza_ren		db 		ini_renglon
;Coordenadas de los pixeles correspondientes a la pieza en el área de juego
;El arreglo cols guarda las columnas, y rens los renglones
pieza_cols 		db 		0,0,0,0
pieza_rens 		db 		0,0,0,0
;Valor de la pieza actual correspondiente a las constantes Piezas
pieza_actual 	db 		linvertida
;Color de la pieza actual, correspondiente a los colores del carácter
actual_color 	db 		0
;Coordenadas de los pixeles correspondientes a la pieza siguiente
next_cols 		db 		0,0,0,0
next_rens 		db 		0,0,0,0
;Color de la pieza siguiente, correspondiente con los colores del carácter
next_color 		db 		0
;Valor de la pieza siguiente correspondiente a Piezas
pieza_aux		db 		0
pieza_next 		db 		linea
;A continuación se tienen algunas variables auxiliares
;Variables min y max para almacenar los extremos izquierdo, derecho, inferior y superior, para detectar colisiones
pieza_col_max 	db 		0
pieza_col_min 	db 		0
pieza_ren_max 	db 		0
pieza_ren_min 	db 		0
;Variable para pasar como parámetro al imprimir una pieza
pieza_color 	db 		0
;Variables auxiliares de uso general
aux1	 		db 		0
aux2 			db 		0

;Variables auxiliares para el manejo de posiciones
col_aux 		db 		0
ren_aux 		db 		0
col_inv			db 		0
ren_inv			db 		0
despla_vert		db 		0
despla_hor		db 		0

;variables para manejo del reloj del sistema
t_inicial		dw 		0,0		;guarda números de ticks inicial
ticks 			dw		0 		;contador de ticks
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;dato de valor decimal 1000 para operación DIV entre 1000
diez 			dw 		10
cien 			db 		100 	;dato de valor decimal 100 para operación DIV entre 100
sesenta 		db 		60		;dato de valor decimal 60 para operación DIV entre 60
contador 		dw		0		;variable contador
segundos 		db 		0 		;Variable para ver los segundos
delay_def		db 		1 		;Cada segundo se muestra la siguiente pieza
delay_fin		db 		0 		;Para comparar el delay inicial (por si es igual)

status 			db 		0 		;Status de juegos: 0 stop, 1 active, 2 pause
conta 			db 		0 		;Contador auxiliar para algunas operaciones

;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0


;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 		'No se encuentra driver de mouse. Presione [enter] para salir$'
;Indicador entre las funciones colisión y chequo_colicion
estado			db 		0
caracter_a_evaluar 	db 	0
;Para ver el estado del recuadro donde se ubica el cursor a la hora de dibujas
estado_localidad 	db  0
tope_inferior 		db 	0
datote		dw   		0
milisegundos dw 		0
level 		dw 			0
;Para tener de referencia cuando llegamos a la cima y no es posible 
;escribir más
fin_juego	db 			0
;////////////////////////////////////////////////////

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
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
;Mediante la opción 08h y la int 10h obtenemos el caracter (en al)
;de donde esta posicionado el cursor
leer_cursor_posicion macro
	mov ah,08h
	mov bx,0
	int 10h
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
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;Ejemplo: Si la int 33h devuelve la posición (400,120) 
;Al convertir a resolución => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => (50,15)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

;delimita_mouse_h - Delimita la posición del mouse horizontalmente dependiendo los valores 'minimo' y 'maximo'
delimita_mouse_h 	macro minimo,maximo
	mov cx,minimo  	;establece el valor mínimo horizontal en CX
	mov dx,maximo  	;establece el valor máximo horizontal en CX
	mov ax,7		;opcion 7
	int 33h			;llama interrupcion 33h para manejo del mouse
endm

inicio_crono macro
	mov ah,00h 				;Tomando un tiempo inicial de referencia
	int 1Ah
	mov [t_inicial],dx
endm
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.
	jmp salir_enter		;salta a 'salir_enter'
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse
	posiciona_cursor_mouse 320d,16d	;establece la posición del mouse
	call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz de usuario


;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
salir_enter:
	mov ah,08h
	int 21h 			;int 21h opción 08h: recibe entrada de teclado sin eco y guarda en AL
	cmp al,0Dh			;compara la entrada de teclado si fue [enter]
	jnz salir_enter 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	USO_MOUSE proc
	push ax 
	push bx 
	push cx 
	push dx 
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

		;Aquí se revisa si se hizo clic en el botón izquierdo
		test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
		jz salida_lect_mouse 			;Si el boton izquierdo no fue presionado, sale del procedimiento sin generar alguna  acción

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Aqui va la lógica de la posicion del mouse;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;Si el mouse fue presionado en el renglon 0
		;se va a revisar si fue dentro del boton [X]
		cmp dx,0
		je boton_x
		;Si el mouse fue presionado en el centro de los botones
		cmp dx,lim_inferior-3
		je boton_amarillo

		;No se presionó dentro de un límite
		jmp salida_lect_mouse
	boton_x:
		jmp boton_x1
	boton_amarillo:

		;Para el botón de stop
		cmp cx,stop_col
		jb salida_lect_mouse
		cmp cx, stop_der
		jbe boton_stop1

		;Para el botón pause
		cmp cx,pause_col
		jb salida_lect_mouse
		cmp cx, pause_der
		jbe boton_pause1

		;Para el botón play
		cmp cx,play_col
		jb salida_lect_mouse
		cmp cx, play_der
		jbe boton_play1

	;Lógica para revisar si el mouse fue presionado en [X]
	;[X] se encuentra en renglon 0 y entre columnas 76 y 78
	boton_x1:
		cmp cx,76
		jge boton_x2
		jmp salida_lect_mouse
	boton_x2:
		cmp cx,78
		jbe boton_x3
		jmp salida_lect_mouse
	boton_x3:
		;Se cumplieron todas las condiciones
		jmp salir

	;Lógica para calcular la posición del botón STOP dentro de los límites como variables
	;Funciona para un renglón
	boton_stop1:
		cmp cx,stop_col
		jge boton_stop2
		jmp salida_lect_mouse
	boton_stop2:
		cmp cx,stop_der
		jbe boton_stop3
		jmp salida_lect_mouse
	boton_stop3:
		cmp dx,stop_sup
		jge boton_stop4
		jmp salida_lect_mouse
	boton_stop4:
		cmp dx,stop_inf
		jbe boton_stop5
		jmp salida_lect_mouse
	boton_stop5:
		mov aux1,0
		mov despla_vert,0
		mov despla_hor,0
		call ACTUALIZA_FIGURA
		jmp inicio

	;Lógica para calcular la posición del botón PAUSE dentro de los límites como variables
	;Funciona para un renglón
	boton_pause1:
		cmp cx,pause_col
		jge boton_pause2
		jmp salida_lect_mouse
	boton_pause2:
		cmp cx,pause_der
		jbe boton_pause3
		jmp salida_lect_mouse
	boton_pause3:
		cmp dx,pause_sup
		jge boton_pause4
		jmp salida_lect_mouse
	boton_pause4:
		cmp dx,pause_inf
		jbe boton_pause5
		jmp salida_lect_mouse
	boton_pause5:
		mov [status],1d
		inicio_crono
		jmp salida_lect_mouse

	;Lógica para calcular la posición del botón PLAY dentro de los límites como variables
	;Funciona para un renglón
	boton_play1:
		cmp cx,play_col
		jge boton_play2
		jmp salida_lect_mouse
	boton_play2:
		cmp cx,play_der
		jbe boton_play3
		jmp salida_lect_mouse
	boton_play3:
		cmp dx,play_sup
		jge boton_play4
		jmp salida_lect_mouse
	boton_play4:
		cmp dx,play_inf
		jbe boton_play5
		jmp salida_lect_mouse
	boton_play5:
		mov [status],2d
		jmp salida_lect_mouse
	salida_lect_mouse:
		pop dx 
		pop cx
		pop bx 
		pop ax
		ret
	endp
	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cGrisClaro,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cGrisClaro,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cGrisClaro,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cGrisClaro,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro
		
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro
		;Derecho
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro
		;Interno
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1 		
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior 
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cGrisClaro,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cGrisClaro,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cGrisClaro,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cGrisClaro,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cGrisClaro,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cGrisClaro,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cGrisClaro,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cGrisClaro,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],finTitulo-titulo,cBlanco,bgNegro
		call IMPRIME_TEXTOS
		call IMPRIME_BOTONES
	inicio_juego:
		call IMPRIME_DATOS_INICIALES   
		ret
	endp

	IMPRIME_TEXTOS proc
		;Imprime cadena "NEXT"
		posiciona_cursor next_ren,next_col
		imprime_cadena_color nextStr,finNextStr-nextStr,cGrisClaro,bgNegro

		;Imprime cadena "LEVEL"
		posiciona_cursor level_ren,level_col
		imprime_cadena_color levelStr,finlevelStr-levelStr,cGrisClaro,bgNegro

		;Imprime cadena "LINES"
		posiciona_cursor lines_ren,lines_col
		imprime_cadena_color linesStr,finLinesStr-linesStr,cGrisClaro,bgNegro

		;Imprime cadena "HI-SCORE"
		posiciona_cursor hiscore_ren,hiscore_col
		imprime_cadena_color hiscoreStr,finHiscoreStr-hiscoreStr,cGrisClaro,bgNegro
		ret
	endp

	IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],stop_ren
		mov [boton_columna],stop_col
		call IMPRIME_BOTON
		;Botón PAUSE
		mov [boton_caracter],19d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],pause_ren
		mov [boton_columna],pause_col
		call IMPRIME_BOTON
		;Botón PLAY
		mov [boton_caracter],16d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],play_ren
		mov [boton_columna],play_col
		call IMPRIME_BOTON
		ret
	endp

	IMPRIME_SCORES proc
		call IMPRIME_LINES
		call IMPRIME_HISCORE
		call IMPRIME_LEVEL
		ret
	endp

	IMPRIME_LINES proc
		mov [ren_aux],lines_ren
		mov [col_aux],lines_col+20
		mov bx,[lines_score]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_HISCORE proc
		mov [ren_aux],hiscore_ren
		mov [col_aux],hiscore_col+20
		mov bx,[hiscore]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_LEVEL proc
		mov [ren_aux],level_ren
		mov [col_aux],level_col+20
		mov bx,[level]
		call IMPRIME_BX
		ret
	endp

	;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
	BORRA_SCORES proc
		call BORRA_SCORE
		call BORRA_HISCORE
		ret
	endp

	BORRA_SCORE proc
		posiciona_cursor lines_ren,lines_col+20 		;posiciona el cursor relativo a lines_ren y score_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	BORRA_HISCORE proc
		posiciona_cursor hiscore_ren,hiscore_col+20 	;posiciona el cursor relativo a hiscore_ren y hiscore_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp
	
	get_level_with_lines proc
		cmp lines_score,5
		ja level2
		mov level,1
		jmp salir_get
		level2:
		cmp lines_score,10
		ja level3
		mov level,2
		jmp salir_get
		level3:
		cmp lines_score,15
		ja level4
		mov level,3
		jmp salir_get
		level4:
		cmp lines_score,20
		mov level,5
		salir_get:
		ret
	endp
	
	;Imprime el valor del registro BX como entero sin signo (positivo)
	;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
	;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
	IMPRIME_BX proc
		mov ax,bx
		mov cx,5
	div10:
		xor dx,dx
		div [diez]
		push dx
		loop div10
		mov cx,5
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

	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		call IMPRIME_SCORES
		call DIBUJA_NEXT
		push cx
		push ax  
		push bx
		push dx 
			
		inicio_crono

			loopstart:
				
				no_borra:
				call USO_MOUSE
				
				;loop que contiene las funcionalidades principales del movimiento
			    call Desplazamiento_horizontal		;se habilitan los movimientos horizontales

			    push cx
			    	call crono 					;Llamada al uso de los ticks
			    pop cx
				
				push cx
					call DIBUJA_ACTUAL				
				pop cx
				;Si llegamos a la cima, termina el juego.
				cmp fin_juego,1
				je salir
				;Para cuando colisiona con los bordes laterales
				cmp estado_localidad,1
				je no_borra
				;Para cuando colisiona con el borde inferior 
				;ya sea marco o pieza
				cmp tope_inferior,1
				je actualiza_ciclo

			    push cx
			    	call BORRA_PIEZA_ACTUAL		;borra la pieza anterior a la actual

				pop cx
				;Si no hay colisión vertical debemos seguir el flujo 
				;donde no se actualiza fijura o nos evita movernos
				jmp loopstart
				;Si colisionamos verticalmente, actualizamos pieza
				;yreiniciamos reloj para con ello el movimiento 
				;vertical
				actualiza_ciclo:
				call ACTUALIZA_FIGURA
			    jmp loopstart
		game_over:

 		pop dx
 		pop bx
		pop ax
		pop cx
		
		;implementar
		ret
	endp

	;Inicializa variables del juego
	DATOS_INICIALES proc
		mov [lines_score],0
		mov [hiscore],0
		call get_level_with_lines
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
	endp	 			;Indica fin de procedimiento IMPRIME_BOTON para el ensamblador
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Los siguientes procedimientos se utilizan para dibujar piezas y utilizan los mismos parámetros
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Como parámetros se utilizan:
	;col_aux y ren_aux: Toma como referencia los valores establecidos en ren_aux y en col_aux
	;esas coordenadas son la referencia (esquina superior izquierda) de una matriz 4x4
	;si - apuntador al arreglo de renglones en donde se van a guardar esas posiciones
	;di - apuntador al arreglo de columnas en donde se van a guardar esas posiciones
	;si y di están parametrizados porque se puede dibujar la pieza actual o la pieza next
	;Se calculan las posiciones y se almacenan en los arreglos correspondientes
	;posteriormente se llama al procedimiento DIBUJA_PIEZA que hace uso de esas posiciones para imprimir la pieza en pantalla

	;Procedimiento para dibujar una pieza de cuadro
	DIBUJA_CUADRO proc
		mov [pieza_color],cAmarillo
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		dec al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp
	DIBUJA_CUADRO_G1 proc
		mov [pieza_color],cAmarillo
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		dec al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de línea
	DIBUJA_LINEA proc
		mov [pieza_color],cCyanClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar línea derecha
	DIBUJA_LINEA_G1 proc
		mov [pieza_color],cCyanClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L
	DIBUJA_L proc
		mov [pieza_color],cCafe
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		dec al
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L Giro
	DIBUJA_L_G1 proc
		mov [pieza_color],cCafe
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L 
	DIBUJA_L_G2 proc
		mov [pieza_color],cCafe
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah 
		inc ah 
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		dec ah 
		mov [si+2],al
		mov [di+2],ah
		dec ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L 
	DIBUJA_L_G3 proc
		mov [pieza_color],cCafe
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc al 
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	DIBUJA_L_INVERTIDA proc
		mov [pieza_color],cAzul
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	DIBUJA_L_INVERTIDA_G1 proc
		mov [pieza_color],cAzul
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		dec ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	DIBUJA_L_INVERTIDA_G2 proc
		mov [pieza_color],cAzul
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	DIBUJA_L_INVERTIDA_G3 proc
		mov [pieza_color],cAzul
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		dec ah
		dec ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	DIBUJA_T proc
		mov [pieza_color],cMagenta
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		dec al
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	DIBUJA_T_G1 proc
		mov [pieza_color],cMagenta
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al 
		dec ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al 
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	DIBUJA_T_G2 proc
		mov [pieza_color],cMagenta
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al 
		dec ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah 
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	DIBUJA_T_G3 proc
		mov [pieza_color],cMagenta
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al 
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		dec ah 
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp


	;Procedimiento para dibujar una pieza de S
	DIBUJA_S proc
		mov [pieza_color],cVerdeClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		add al,2
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		dec al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar s girada
	DIBUJA_S_G1 proc
		mov [pieza_color],cVerdeClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de S invertida
	DIBUJA_S_INVERTIDA proc
		mov [pieza_color],cRojoClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar s invertida girada
	DIBUJA_S_INVERTIDA_G1 proc
		mov [pieza_color],cRojoClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al 
		mov [si+1],al
		mov [di+1],ah
		dec ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Revisa los arreglos columna y renglon para posicionar el cursor allí
	;y realizar comparaciones ocn simbolos que definen 
	;si es posible o no dibujar la pieza allí.
	;En caso de no poderse dibujar, se decrementa el desplazamiento horizontal
	;y vuelve al ciclo principal (DIBUJA_DATOS_INICIALES) para repasar el proceso
	;con un nuevo desplazamiento.
	checa_localidades proc
		mov cx,4
		push si
		push di
		chequeo_colicion:
			mov estado_localidad,0
			mov tope_inferior,0
			posiciona_cursor [si],[di]
			leer_cursor_posicion				;al = caracter
			call closion
			cmp estado,1
			je marca_ocupado
			inc di
			inc si
			loop chequeo_colicion
			jmp salir_chequeo
			marca_ocupado:
			mov estado_localidad,1 				;marca de ocuopado
			salir_chequeo:
			pop di
			pop si
			ret
	endp
	;Revisa los arreglos columna y renglon para posicionar el cursor allí
	;y realizar comparaciones ocn simbolos que definen 
	;si es posible o no dibujar la pieza allí.
	;En caso de no poderse dibujar, se decrementa el desplazamiento vertical
	;y vuelve al ciclo principal (DIBUJA_DATOS_INICIALES) para repasar el proceso
	;con un nuevo desplazamiento.
	checa_localidadesV proc
		mov cx,4
		push si
		push di
	chequeo_colicionV:
		mov tope_inferior,0
		posiciona_cursor [si],[di]
		leer_cursor_posicion				;al = caracter
		call closionV
		cmp estado,1
		je marca_ocupadoV
		inc di
		inc si
		loop chequeo_colicionV

		jmp salir_chequeoV
		marca_ocupadoV:
		mov tope_inferior,1 				;marca de ocuopado
		;Dado ciertos conflictos con un delay, la pieza al colicionar de 
		;forma vertical tendía a borrar la pieza y seguir dejando la siguiente
		;por lo que se dibuja la pieza en las localidades
		;donde esta se borra por causa del delay.
		;================
		xor ax,ax
		mov al,tope_inferior
		push ax
		;Ya no tiene problema dado que el movimiento vertical que ocasionaba que
		;no se permitiera dibujar se decremento en una unidad.
		call DIBUJA_ACTUAL
		pop ax
		;===============
		mov tope_inferior,al
		;Si topamos con un borde pero se trata del 
		;borde superiror, es decir, desplazamiento vertical
		;es 0
		cmp despla_vert,0
		jne salir_chequeoV
		mov fin_juego,1
		salir_chequeoV:
		pop di
		pop si
		ret
	endp

	;Dado que para toda impresión siempre se manda llamar este procedimiento
	;aqui se inserta la validación de si es o no posible desplazar la pieza es 
	;decir, dibujar.
	;Cuando se manda llamar este procedimiento, si e di son apuntadores 
	;a los arreglos que gurdan tanto columnas y renglones de la 
	;la pieza futura a dibujar.
	DIBUJA_PIEZA proc
	;================
	;Colisión 
	;Tope inferior
	mov caracter_a_evaluar,0CDh
	call checa_localidadesV				;escaneamos los arreglos	
	cmp tope_inferior,1					;si es 1, no podemos dibujar
	je no_dibuja

	;Tope con figura
	mov caracter_a_evaluar,0FEh
	call checa_localidadesV				;escaneamos los arreglos
	cmp tope_inferior,1					;si es 1, no podemos dibujar
	je no_dibuja

	;Marcos laterlas 
	mov aux1,0
	mov aux2,28
	mov caracter_a_evaluar,0BAh
	call checa_localidades				;escaneamos los arreglos
	cmp estado_localidad,1				;si es 1, no podemos dibujar
	je no_dibuja
	;Intersecciones internas (laterales)
	mov caracter_a_evaluar,0CCh
	call checa_localidades				;escaneamos los arreglos
	cmp estado_localidad,1				;si es 1, no podemos dibujar
	je no_dibuja

	;================
		mov cx,4
	loop_dibuja_pieza:
		push cx
		push si
		push di
		posiciona_cursor [si],[di]
		imprime_caracter_color 254,[pieza_color],bgGrisOscuro
		pop di
		pop si
		pop cx
		inc di
		inc si
		loop loop_dibuja_pieza
		no_dibuja:
		ret
	endp

	;DIBUJA_NEXT - se usa para imprimir la pieza siguiente en pantalla
	;Primero se debe calcular qué pieza se va a dibujar
	;Dentro del procedimiento se utilizan variables referentes a la pieza siguiente
	DIBUJA_NEXT proc
		push cx
		lea di,[next_cols]
		lea si,[next_rens]
		mov [col_aux],next_col+10
		mov [ren_aux],next_ren-1
		
		;Genera números aleatorios entre 0-99
		;La interrupción devuelve centesimas en el registro DL (0-99)
		
		mov cx,milisegundos
		mov pieza_aux,cl		;Se mueve el valor obtenido, para ser comparado

		cmp pieza_aux,14		
		jbe next_cuadro			;En caso de ser dl <= 14, dibuja cuadro
		cmp pieza_aux,28
		jbe next_linea 			;En caso de ser 14 < dl <= 28, dibuja linea
		cmp pieza_aux,42
		jbe next_l_invertida	;En caso de ser 28 < dl <= 42, dibuja l invertida
		cmp pieza_aux,56
		jbe next_l 				;En caso de ser 42 < dl <= 56, dibuja l
		cmp pieza_aux,70
		jbe next_s 				;En caso de ser 56 < dl <= 70, dibuja s
		cmp pieza_aux,84
		jbe next_s_invertida 	;En caso de ser 70 < dl <= 84, dibuja s invertida
		cmp pieza_aux,99
		jbe next_t 				;En caso de ser 84 < dl <= 99, dibuja T

	next_cuadro:
		mov [pieza_next],cuadro
		mov [next_color],cAmarillo
		call DIBUJA_CUADRO
		jmp salir_dibuja_next
	next_linea:
		mov [pieza_next],linea
		mov [next_color],cCyanClaro
		call DIBUJA_LINEA
		jmp salir_dibuja_next
	next_l:
		mov [pieza_next],lnormal
		mov [next_color],cCafe
		call DIBUJA_L
		jmp salir_dibuja_next
	next_l_invertida:
		mov [pieza_next],linvertida
		mov [next_color],cAzul
		call DIBUJA_L_INVERTIDA
		jmp salir_dibuja_next
	next_t:
		mov [pieza_next],tnormal
		mov [next_color],cMagenta
		call DIBUJA_T
		jmp salir_dibuja_next
	next_s:
		mov [pieza_next],snormal
		mov [next_color],cVerdeClaro
		call DIBUJA_S
		jmp salir_dibuja_next
	next_s_invertida:
		mov [pieza_next],sinvertida
		mov [next_color],cRojoClaro
		call DIBUJA_S_INVERTIDA
	salir_dibuja_next:
	pop cx
		ret
	endp

	ACTUALIZA_FIGURA proc 
		mov al,[pieza_next]
		mov [pieza_actual],al 
		mov [despla_hor],0
		mov [despla_vert],0
		call BORRA_NEXT
		call DIBUJA_NEXT
		inicio_crono
		ret 
	endp
	;DIBUJA_ACTUAL - se usa para imprimir la pieza actual en pantalla
	;Primero se debe calcular qué pieza se va a dibujar
	;Dentro del procedimiento se utilizan variables referentes a la pieza actual
	DIBUJA_ACTUAL proc
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		mov al,ini_columna
		mov ah,ini_renglon
		add al, [despla_hor]
		add ah, [despla_vert]
		mov [col_aux],al
		mov [ren_aux],ah
		mov [pieza_col],al
		mov [pieza_ren],ah
		cmp [pieza_actual],cuadro
		je inicia_actual_cuadro
		cmp [pieza_actual],cuadro_g1
		je inicia_actual_cuadro_g1

		cmp [pieza_actual],linea
		je inicia_actual_linea
		cmp [pieza_actual],linea_g1
		je inicia_actual_linea_g1

		cmp [pieza_actual],lnormal
		je inicia_actual_l
		cmp [pieza_actual],lnormal_g1
		je inicia_actual_l_g1
		cmp [pieza_actual],lnormal_g2
		je inicia_actual_l_g2
		cmp [pieza_actual],lnormal_g3
		je inicia_actual_l_g3

		cmp [pieza_actual],linvertida
		je inicia_actual_l_invertida
		cmp [pieza_actual],linv_g1
		je inicia_actual_l_invertida_g1
		cmp [pieza_actual],linv_g2
		je inicia_actual_l_invertida_g2
		cmp [pieza_actual],linv_g3
		je inicia_actual_l_invertida_g3

		cmp [pieza_actual],tnormal
		je inicia_actual_t
		cmp [pieza_actual],t_g1
		je inicia_actual_t_g1
		cmp [pieza_actual],t_g2
		je inicia_actual_t_g2
		cmp [pieza_actual],t_g3
		je inicia_actual_t_g3

		cmp [pieza_actual],snormal
		je inicia_actual_s
		cmp [pieza_actual],sn_g1
		je inicia_actual_s_g1

		cmp [pieza_actual],sinvertida
		je inicia_actual_s_invertida
		cmp [pieza_actual],sinv_g1
		je inicia_actual_s_invertida_g1


	inicia_actual_cuadro:
		mov [actual_color],cAmarillo
		call DIBUJA_CUADRO
		jmp salir_inicia_actual
	inicia_actual_cuadro_g1:
		mov [actual_color],cAmarillo
		call DIBUJA_CUADRO
		jmp salir_inicia_actual

	inicia_actual_linea:
		mov [actual_color],cCyanClaro
		call DIBUJA_LINEA
		jmp salir_inicia_actual
	inicia_actual_linea_g1:
		mov [actual_color],cCyanClaro
		call DIBUJA_LINEA_G1
		jmp salir_inicia_actual

	inicia_actual_l:
		mov [actual_color],cCafe
		call DIBUJA_L
		jmp salir_inicia_actual
	inicia_actual_l_g1:
		mov [actual_color],cCafe
		call DIBUJA_L_G1
		jmp salir_inicia_actual
	inicia_actual_l_g2:
		mov [actual_color],cCafe
		call DIBUJA_L_G2
		jmp salir_inicia_actual
	inicia_actual_l_g3:
		mov [actual_color],cCafe
		call DIBUJA_L_G3
		jmp salir_inicia_actual

	inicia_actual_t:
		mov [actual_color],cMagenta
		call DIBUJA_T
		jmp salir_inicia_actual
	inicia_actual_t_g1:
		mov [actual_color],cMagenta
		call DIBUJA_T_G1
		jmp salir_inicia_actual
	inicia_actual_t_g2:
		mov [actual_color],cMagenta
		call DIBUJA_T_G2
		jmp salir_inicia_actual
	inicia_actual_t_g3:
		mov [actual_color],cMagenta
		call DIBUJA_T_G3
		jmp salir_inicia_actual

	inicia_actual_s:
		mov [actual_color],cVerdeClaro
		call DIBUJA_S
		jmp salir_inicia_actual
	inicia_actual_s_g1:
		mov [actual_color],cVerdeClaro
		call DIBUJA_S_G1
		jmp salir_inicia_actual

	inicia_actual_s_invertida:
		mov [actual_color],cRojoClaro
		call DIBUJA_S_INVERTIDA
		jmp salir_inicia_actual
	inicia_actual_s_invertida_g1:
		mov [actual_color],cRojoClaro
		call DIBUJA_S_INVERTIDA_G1
		jmp salir_inicia_actual

	inicia_actual_l_invertida:
		mov [actual_color],cAzul
		call DIBUJA_L_INVERTIDA
		jmp salir_inicia_actual
	inicia_actual_l_invertida_g1:
		mov [actual_color],cAzul
		call DIBUJA_L_INVERTIDA_G1
		jmp salir_inicia_actual
	inicia_actual_l_invertida_g2:
		mov [actual_color],cAzul
		call DIBUJA_L_INVERTIDA_G2
		jmp salir_inicia_actual
	inicia_actual_l_invertida_g3:
		mov [actual_color],cAzul
		call DIBUJA_L_INVERTIDA_G3
		jmp salir_inicia_actual
	salir_inicia_actual:
		ret
	endp

	BORRA_PIEZA_ACTUAL proc
		call delay
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		mov al,ini_columna
		mov ah,ini_renglon
		; call checa_localidadesV
		; cmp tope_inferior,1
		; je salir_borra_actual
		add al, [despla_hor]
		add ah, [despla_vert]
		mov [col_aux],al
		mov [ren_aux],ah
		mov [pieza_col],al
		mov [pieza_ren],ah
		cmp [pieza_actual],cuadro
		je borra_actual_cuadro
		cmp [pieza_actual],cuadro_g1
		je borra_actual_cuadro


		cmp [pieza_actual],linea
		je borra_actual_linea
		cmp [pieza_actual],linea_g1
		je borra_actual_linea_g1

		cmp [pieza_actual],lnormal
		je borra_actual_l
		cmp [pieza_actual],lnormal_g1
		je borra_actual_l_g1
		cmp [pieza_actual],lnormal_g2
		je borra_actual_l_g2
		cmp [pieza_actual],lnormal_g3
		je borra_actual_l_g3

		cmp [pieza_actual],linvertida
		je borra_actual_l_invertida
		cmp [pieza_actual],linv_g1
		je borra_actual_l_invertida_g1
		cmp [pieza_actual],linv_g2
		je borra_actual_l_invertida_g2
		cmp [pieza_actual],linv_g3
		je borra_actual_l_invertida_g3

		cmp [pieza_actual],tnormal
		je borra_actual_t
		cmp [pieza_actual],t_g1
		je borra_actual_t_g1
		cmp [pieza_actual],t_g2
		je borra_actual_t_g2
		cmp [pieza_actual],t_g3
		je borra_actual_t_g3

		cmp [pieza_actual],snormal
		je borra_actual_s
		cmp [pieza_actual],sn_g1
		je borra_actual_s_g1

		cmp [pieza_actual],sinvertida
		je borra_actual_s_invertida
		cmp [pieza_actual],sinv_g1
		je borra_actual_s_invertida_g1

	borra_actual_cuadro:
		call BORRA_CUADRO
		jmp salir_borra_actual

	borra_actual_linea:
		call BORRA_LINEA
		jmp salir_borra_actual
	borra_actual_linea_g1:
		mov [actual_color],cCyanClaro
		call BORRA_LINEA_G1
		jmp salir_inicia_actual

	borra_actual_l:
		call BORRA_L
		jmp salir_borra_actual
	borra_actual_l_g1:
		mov [actual_color],cCafe
		call BORRA_L_G1 
		jmp salir_inicia_actual
	borra_actual_l_g2:
		mov [actual_color],cCafe
		call BORRA_L_G2
		jmp salir_inicia_actual
	borra_actual_l_g3:
		mov [actual_color],cCafe
		call BORRA_L_G3
		jmp salir_inicia_actual

	borra_actual_t:
		call BORRA_T
		jmp salir_borra_actual
	borra_actual_t_g1:
		call BORRA_T_G1
		jmp salir_borra_actual
	borra_actual_t_g2:
		call BORRA_T_G2
		jmp salir_borra_actual
	borra_actual_t_g3:
		call BORRA_T_G3
		jmp salir_borra_actual

	borra_actual_s:
		call BORRA_S
		jmp salir_borra_actual
	borra_actual_s_g1:
		call BORRA_S_G1
		jmp salir_borra_actual

	borra_actual_s_invertida:
		call BORRA_S_INVERTIDA
		jmp salir_borra_actual
	borra_actual_s_invertida_g1:
		call BORRA_S_INVERTIDA_G1
		jmp salir_borra_actual

	borra_actual_l_invertida:
		call BORRA_L_INVERTIDA
		jmp salir_borra_actual
	borra_actual_l_invertida_g1:
		call BORRA_L_INVERTIDA_G1
		jmp salir_borra_actual
	borra_actual_l_invertida_g2:
		call BORRA_L_INVERTIDA_G2
		jmp salir_borra_actual
	borra_actual_l_invertida_g3:
		call BORRA_L_INVERTIDA_G3
		jmp salir_borra_actual
	salir_borra_actual:
		ret
	endp


	;Procedimiento para borrar una pieza de cuadro
	BORRA_CUADRO proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		dec al
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para BORRAr una pieza de línea
	BORRA_LINEA proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar línea derecha
	BORRA_LINEA_G1 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para BORRAr una pieza de L
	BORRA_L proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		dec al
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L Giro
	BORRA_L_G1 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L 
	BORRA_L_G2 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah 
		inc ah 
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		dec ah 
		mov [si+2],al
		mov [di+2],ah
		dec ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L 
	BORRA_L_G3 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc al 
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp	

	;Procedimiento para BORRAr una pieza de L invertida
	BORRA_L_INVERTIDA proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	BORRA_L_INVERTIDA_G1 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		dec ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	BORRA_L_INVERTIDA_G2 proc
		mov [pieza_color],cAzul
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	BORRA_L_INVERTIDA_G3 proc
		mov [pieza_color],cAzul
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		dec ah
		dec ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para BORRAr una pieza de T
	BORRA_T proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		dec al
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	BORRA_T_G1 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al 
		dec ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al 
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	BORRA_T_G2 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al 
		dec ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah 
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	BORRA_T_G3 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al 
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		dec ah 
		inc al
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para BORRAr una pieza de S
	BORRA_S proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		add al,2
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		dec al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar s girada
	BORRA_S_G1 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para BORRAr una pieza de S invertida
	BORRA_S_INVERTIDA proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	;Procedimiento para dibujar s invertida girada
	BORRA_S_INVERTIDA_G1 proc
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al 
		mov [si+1],al
		mov [di+1],ah
		dec ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call BORRA_PIEZA
		ret
	endp

	BORRA_NEXT proc
		lea di,[next_cols]
		lea si,[next_rens]
		mov [col_aux],next_col+10
		mov [ren_aux],next_ren-1

		cmp [pieza_next],cuadro	
		je bnext_cuadro			;En caso de ser dl <= 14, dibuja cuadro
		cmp [pieza_next],linea
		je bnext_linea 			;En caso de ser 14 < dl <= 28, dibuja linea
		cmp [pieza_next],linvertida
		je bnext_l_invertida	;En caso de ser 28 < dl <= 42, dibuja l invertida
		cmp [pieza_next],lnormal
		je bnext_l 				;En caso de ser 42 < dl <= 56, dibuja l
		cmp [pieza_next],snormal
		je bnext_s 				;En caso de ser 56 < dl <= 70, dibuja s
		cmp [pieza_next],sinvertida
		je bnext_s_invertida 	;En caso de ser 70 < dl <= 84, dibuja s invertida
		cmp [pieza_next],tnormal
		je bnext_t 				;En caso de ser 84 < dl <= 99, dibuja T

		bnext_cuadro:
			call BORRA_CUADRO
			jmp salir_borra_next
		bnext_linea:
			call BORRA_LINEA
			jmp salir_borra_next
		bnext_l:
			call BORRA_L
			jmp salir_borra_next
		bnext_l_invertida:
			call BORRA_L_INVERTIDA
			jmp salir_borra_next
		bnext_t:
			call BORRA_T
			jmp salir_borra_next
		bnext_s:
			call BORRA_S
			jmp salir_borra_next
		bnext_s_invertida:
			call BORRA_S_INVERTIDA
			jmp salir_borra_next
		salir_borra_next:
			ret
	endp

	BORRA_PIEZA proc
		mov cx,4
	loop_borra_pieza:
		push cx
		push si
		push di
		posiciona_cursor [si],[di]
			mov ah,09h				;preparar AH para interrupcion, opcion 09h
			mov al,00h 		;AL = caracter a imprimir
			mov cx,1				;CX = numero de veces que se imprime el caracter
			int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
		pop di
		pop si
		pop cx
		inc di
		inc si
		loop loop_borra_pieza
		ret
	endp

		
	;Se realiza la multiplicación por matriz para rotar
	GIRO_DER proc
		cmp [pieza_actual],cuadro
		je giro_cuadro
		cmp [pieza_actual],linea
		je giro_linea
		cmp [pieza_actual],linea_g1
		je giro_linea2
		cmp [pieza_actual],lnormal
		je giro_l
		cmp [pieza_actual],lnormal_g1
		je giro_l2
		cmp [pieza_actual],lnormal_g2
		je giro_l3
		cmp [pieza_actual],lnormal_g3
		je giro_l4
		cmp [pieza_actual],linvertida
		je giro_J
		cmp [pieza_actual],linv_g1
		je giro_J2
		cmp [pieza_actual],linv_g2
		je giro_J3
		cmp [pieza_actual],linv_g3
		je giro_J4
		cmp [pieza_actual],tnormal
		je giro_T
		cmp [pieza_actual],t_g1
		je giro_T2
		cmp [pieza_actual],t_g2
		je giro_T3
		cmp [pieza_actual],t_g3
		je giro_T4
		cmp [pieza_actual],snormal
		je giro_s
		cmp [pieza_actual],sn_g1
		je giro_s2
		cmp [pieza_actual],sinvertida
		je giro_Z
		cmp [pieza_actual],sinv_g1
		je giro_Z2

		giro_cuadro:
			mov [pieza_actual],cuadro
			jmp salida_giro
		giro_linea:
			mov [pieza_actual],linea_g1
			jmp salida_giro
		giro_linea2:
			mov [pieza_actual],linea
			jmp salida_giro
		giro_l:
			mov [pieza_actual],lnormal_g1
			jmp salida_giro
		giro_l2:
			mov [pieza_actual],lnormal_g2
			jmp salida_giro
		giro_l3:
			mov [pieza_actual],lnormal_g3
			jmp salida_giro
		giro_l4:
			mov [pieza_actual],lnormal
			jmp salida_giro
		giro_J:
			mov [pieza_actual],linv_g1
			jmp salida_giro
		giro_J2:
			mov [pieza_actual],linv_g2
			jmp salida_giro
		giro_J3:
			mov [pieza_actual],linv_g3
			jmp salida_giro
		giro_J4:
			mov [pieza_actual],linvertida
			jmp salida_giro
		giro_T:
			mov [pieza_actual],t_g1
			jmp salida_giro
		giro_T2:
			mov [pieza_actual],t_g2
			jmp salida_giro
		giro_T3:
			mov [pieza_actual],t_g3
			jmp salida_giro
		giro_T4:
			mov [pieza_actual],tnormal
			jmp salida_giro
		giro_s:
			mov [pieza_actual],sn_g1
			jmp salida_giro
		giro_s2:
			mov [pieza_actual],snormal
			jmp salida_giro
		giro_Z:
			mov [pieza_actual],sinv_g1
			jmp salida_giro
		giro_Z2:
			mov [pieza_actual],sinvertida
			jmp salida_giro
		
		salida_giro:
			ret 
	endp

	GIRO_IZQ proc
		cmp [pieza_actual],cuadro
		je giroI_cuadro
		cmp [pieza_actual],linea
		je giroI_linea
		cmp [pieza_actual],linea_g1
		je giroI_linea2
		cmp [pieza_actual],lnormal
		je giroI_l
		cmp [pieza_actual],lnormal_g3
		je giroI_l2
		cmp [pieza_actual],lnormal_g2
		je giroI_l3
		cmp [pieza_actual],lnormal_g1
		je giroI_l4
		cmp [pieza_actual],linvertida
		je giroI_J
		cmp [pieza_actual],linv_g3
		je giroI_J2
		cmp [pieza_actual],linv_g2
		je giroI_J3
		cmp [pieza_actual],linv_g1
		je giroI_J4
		cmp [pieza_actual],tnormal
		je giroI_T
		cmp [pieza_actual],t_g3
		je giroI_T2
		cmp [pieza_actual],t_g2
		je giroI_T3
		cmp [pieza_actual],t_g1
		je giroI_T4
		cmp [pieza_actual],snormal
		je giroI_s
		cmp [pieza_actual],sn_g1
		je giroI_s2
		cmp [pieza_actual],sinvertida
		je giroI_Z
		cmp [pieza_actual],sinv_g1
		je giroI_Z2

		giroI_cuadro:
			mov [pieza_actual],cuadro
			jmp salida_giroI
		giroI_linea:
			mov [pieza_actual],linea_g1
			jmp salida_giroI
		giroI_linea2:
			mov [pieza_actual],linea
			jmp salida_giroI
		giroI_l:
			mov [pieza_actual],lnormal_g3
			jmp salida_giroI
		giroI_l2:
			mov [pieza_actual],lnormal_g2
			jmp salida_giroI
		giroI_l3:
			mov [pieza_actual],lnormal_g1
			jmp salida_giroI
		giroI_l4:
			mov [pieza_actual],lnormal
			jmp salida_giroI
		giroI_J:
			mov [pieza_actual],linv_g3
			jmp salida_giroI
		giroI_J2:
			mov [pieza_actual],linv_g2
			jmp salida_giroI
		giroI_J3:
			mov [pieza_actual],linv_g1
			jmp salida_giroI
		giroI_J4:
			mov [pieza_actual],linvertida
			jmp salida_giroI
		giroI_T:
			mov [pieza_actual],t_g3
			jmp salida_giroI
		giroI_T2:
			mov [pieza_actual],t_g2
			jmp salida_giroI
		giroI_T3:
			mov [pieza_actual],t_g1
			jmp salida_giroI
		giroI_T4:
			mov [pieza_actual],tnormal
			jmp salida_giroI
		giroI_s:
			mov [pieza_actual],sn_g1
			jmp salida_giroI
		giroI_s2:
			mov [pieza_actual],snormal
			jmp salida_giroI
		giroI_Z:
			mov [pieza_actual],sinv_g1
			jmp salida_giroI
		giroI_Z2:
			mov [pieza_actual],sinvertida
			jmp salida_giroI
		salida_giroI:
			ret
	endp
	
	crono proc
		cmp status,1
		je salida_crono

		mov ah,00h
		int 1Ah
		mov ax,[t_inicial]
		sub dx,ax  				;DX = DX - AX = t_final - t_inicial, DX guarda la parte baja del contador de ticks
		mov ax,dx

		mul [tick_ms]
		div [mil]
		mov[milisegundos],dx
		div [sesenta]
	
		
		flujo_tiempo:
			mov [segundos],ah
			mov dl,[segundos]
			mov despla_vert,dl
		;inc despla_vert
		xor dx,dx
		salida_crono:

		ret
	crono endp


	Desplazamiento_horizontal proc
		mov ah,06h 						;Opción para entrada por teclado sin espera
		mov dl,0FFh						;Es necesario parametrizar dl con FFh
		int 21h
		jz salir_hor					;Si el registro z es 1 no se registro entrada por teclado
		cmp al,4Bh						;Si se presiona tecla flecha izquierda decrementamos 
		je decremento
		cmp al,4Dh						;Si se presiona tecla flecha derecha incrementamos 
		je incremento
		cmp al,64h
		je derecha
		cmp al,61h
		je izquierda
		jmp salir_hor					;Si se presiona otra tecla la ignoramos
		incremento:
			inc despla_hor
			jmp salir_hor
		decremento:
			dec despla_hor
			jmp salir_hor
		derecha:
			call GIRO_DER
			jmp salir_hor
		izquierda:
			call GIRO_IZQ
			jmp salir_hor
		salir_hor:
			ret 
	endp

	delay proc 
	    push ax
	    push bx
	    push cx
	    push dx

	    ;Leyendo el tiempo actual
	    xor bl,bl
	    mov ah,2Ch
	    int 21h

	    ;Almacenando los segundos
	    mov [segundos],dh

	    add dl,[delay_def]      		;Calculando el tiempo de parada
	    cmp dl,100
	    jb ajuste_delay
 
	    sub dl,100 						;Ajustando los segundos
	    mov bl,1

	    ajuste_delay:
	    mov [delay_fin],dl

	    lect_tiempo:
	    mov ah,2Ch
	    int 21h

	    cmp bl,0h 							;Comparando por si son los segundos iguales
	    je segs_iguales

	    cmp dh,[segundos]
	    je lect_tiempo
	    push dx
		    sub dh,[segundos] 				;not in the same second, so stop
		    cmp dh,2
	    pop dx
	    jae fin_delay_proc
	    jmp delay_atrasado

	    segs_iguales:
	    cmp dh,[segundos] 					;Considerando el caso cuando sea falso
	    jne fin_delay_proc

	    delay_atrasado:
	    cmp dl,[delay_fin]					;Cada que DL esté por debajo del tiempo actual, se vuelve a leer
	    jb lect_tiempo

	    fin_delay_proc:
	    pop dx
	    pop cx
	    pop bx
	    pop ax
	    ret
	endp delay
	;Checando si el caracter de donde esta el cursor
	;ya no nos permite avanzar hace los lados
	closion proc
		cmp al,[caracter_a_evaluar]			;al = '║' ?
		je positivo
		jmp negativo
		positivo:
			mov estado,1				;indicador para marcar que si es un caracter del marco
			;Para cuando nos acercamos mucho al marco izquierdo
			;Horizontal : 0
			cmp dl,aux1				
			jbe Dnegativo
			;Para cuando nos acercamos mucho al marco derecho
			;Horizontal : 28
			;Vetical : 22
			cmp dl,aux2
			jae	Dpositivo
			Dnegativo:
			inc despla_hor
			jmp avisa
			Dpositivo:
			dec despla_hor
			jmp avisa					;Para evitar errores de casos excepcionales
		negativo:
		mov estado,0
		avisa:
		ret
	endp
	;Checando si el caracter de donde esta el cursor
	;ya no nos permite avanzar hace abajo
	closionV proc
		cmp al,[caracter_a_evaluar]			;al = '═' o '■' ?
		je positivoV
		jmp negativoV
		positivoV:
			mov estado,1				;indicador para marcar que si es un caracter del marco
			dec despla_vert
			jmp avisaV					;Para evitar errores de casos excepcionales
		negativoV:
		mov estado,0
		avisaV:
		ret
	endp




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	end inicio			;fin de etiqueta inicio, fin de programa