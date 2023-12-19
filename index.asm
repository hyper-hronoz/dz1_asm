.486
model use16 small
.stack 100h
.data
		b dw 175

		ticks dw ?
    prescaler dw 20000  

		k1 dw 1 
		k2 dw 2

    x dw ?
    y dw ?
    axis dw ? ;задаѐм ось

    ky dw 50
    kx dw 1 

    scr_width equ 639

    f1_begin equ -319
    f1_end equ 0

    f2_begin equ 0
    f2_end equ 60

    f3_begin equ 60
    f3_end equ 320

    f1_clr equ 4
    f2_clr equ 1
    f3_clr equ 6


    v_1 dw 1
    v_5 dw 5
    v_3 dw 3
    v_6 dw 6

    v_0d6 dd 0.6

    left_offst dw 319
    top_offst dw 174
    PI dw 180 ;задаѐм число пи в радианах

    temp dw ?
.code

init_pit proc
    push ax
    push bx

    mov al, 34h         ; Control word for channel 0, low byte, mode 2 (rate generator)
    out 43h, al         ; Send control word to PIT

    mov ax, [prescaler] ; Load prescaler value
    out 40h, al         ; Send low byte of prescaler to PIT
    mov al, ah          ; Send high byte of prescaler to PIT
    out 40h, al         ; 

    pop bx
    pop ax
    ret
init_pit endp

delay proc
  push ax
  push bx
  push dx
  push cx

  mov ah, 00h    
  int 1Ah         
  mov [ticks], dx 

delay_loop:
  mov ah, 00h    
  int 1Ah         
  sub dx, [ticks] 
  cmp dx, 1      
  jl delay_loop 

  pop cx
  pop dx
  pop bx
  pop ax

  ret
delay endp

ftransfer proc
	push ax
	push bx
	push cx
	push dx

	fldpi
	fmul
	fild pi
	fdiv
	fild k2
	fdiv

 	pop dx
 	pop cx
 	pop bx
 	pop ax
ftransfer endp

fprint_dot proc
	push ax
	push bx
	push cx
	push dx

  mov ah, 0Ch 
  mov bh, 0h 
  mov dx, y 
  add dx, top_offst
  push cx
  add cx, left_offst
  int 10h
  pop cx

  pop dx
  pop cx
	pop bx
	pop ax

	ret
fprint_dot endp

fexit proc
  mov ah, 8h
  int 21h
  mov ax, 4c00h
  int 21h
  ret
fexit endp

ffill_background proc
	push ax
	push bx
	push cx
	push dx


  mov ax, 0600h ; ah = 06 - прокрутка вверх
  mov bh, 15 ;белый
  mov cx, 0000b ; ah = 00 - строка верхнуго левого угла
  mov dx, 184Fh
  int 10h

  pop cx
  pop cx
  pop bx
  pop ax

  ret
ffill_background endp

fdraw_vertical_line proc
	push ax
	push bx
	push cx
	push dx

  mov ah, 0Ch ;установка графической точки
  mov al, 13 ;загружаем зелѐный цвет для
  ;вертикальной линии
  mov bh, 0h ;установка номера видеостраницы
  mov cx, 400 ;количество итераций сверху вниз
  ;для вертикальной линии
  @metka1: ;прорисовка вертикальной линии
  push cx
  mov axis, cx ;в начало оси записываем 0
  mov dx, axis ;установка курсора
  mov cx, left_offst ;вывод вертикальной оси, со
  ;сдвигом на 319 вправо
  int 10h
  pop cx ;400 итераций, ставит в 400
  ;колонку, и идѐт до 0
  loop @metka1

  pop dx
  pop cx
  pop bx
  pop ax
  ret
fdraw_vertical_line endp

fdraw_horizontal_line proc
	push ax
	push bx
	push cx
	push dx

  mov ah, 0ch ;установка графической точки
  mov al, 13 ;зелѐный цвет
  mov cx, scr_width ;639 итераций, ставит в 639
  ;колонку, и идѐт до 0
  mov bh, 0h ;установка номера видеостраницы
  mov dx, top_offst ;ставит в 174 строку
  @metka2: ;цикл вывода горизонтальной оси
  int 10h ;вывод горизонтальной линии
  loop @metka2

  pop dx
  pop cx
  pop bx
  pop ax
  ret
fdraw_horizontal_line endp

fdraw_chart1 proc
	push ax
	push bx
	push cx
	push dx

  mov cx, f1_begin ;начинаем рассчитывать функцию
chart_loop1: 
  mov x, cx 

	fild x
	call ftransfer

	fild v_5
	fmul

	fild v_1
	fadd

	fild x
	call ftransfer

	fmul st(0), st(0)
	fild v_3
	fadd 
	fdiv

	fimul ky
	fchs
	frndint
	fistp y

  mov al, f1_clr
	call fprint_dot
  
  cmp cx, f1_end
  je finish_chart_loop1

  call delay
	inc cx
  jmp chart_loop1 ;уменьшаем сx

finish_chart_loop1:
  pop dx
  pop cx
  pop bx
  pop ax
  ret
fdraw_chart1 endp

fdraw_chart2 proc
	push ax
	push bx
	push cx
	push dx

  mov cx, f2_begin ;начинаем рассчитывать функцию
chart_loop2: 
  mov x, cx 

	fild x
	call ftransfer
	fsin
	fmul st(0), st(0)

	fild v_5
	fild x
	call ftransfer
	fadd
	fsqrt

	fmul

	fimul ky
	fchs
	frndint
	fistp y
  mov al, f2_clr ;цвет черный
  call fprint_dot
  
  cmp cx, f2_end
  je finish_chart_loop2

  call delay
	inc cx
  jmp chart_loop2 ;уменьшаем сx

finish_chart_loop2:
  pop dx
  pop cx
  pop bx
  pop ax
  ret
fdraw_chart2 endp

fdraw_chart3 proc
	push ax
	push bx
	push cx
	push dx

  mov cx, f3_begin ;начинаем рассчитывать функцию
chart_loop3: 
  mov x, cx 

	fild x
	call ftransfer
	fild v_1
	fadd
	fsin

	fmul st(0), st(0)

	fild x
	call ftransfer
	fild v_1
	fadd
	fsin

	fmul

  fild x
  call ftransfer
  fld v_0d6
  fmul
  fldl2e
  fmul
  fld st
  frndint
  fsub st(1), st
  fxch st(1)
  f2xm1
  fld1
  fadd
  fscale

  fmul st(0), st(2)

	fimul ky
	fchs
	frndint
	fistp y

  mov al, f3_clr
  call fprint_dot
  
  cmp cx, f3_end
  je finish_chart_loop3

  call delay
	inc cx
  jmp chart_loop3 ;уменьшаем сx

finish_chart_loop3:
  pop dx
  pop cx
  pop bx
  pop ax
  ret
fdraw_chart3 endp

start:
    mov ax, @data
    mov ds, ax
    xor ax, ax

  	mov al, 10h
  	int 10h

    call ffill_background

    call fdraw_vertical_line

    call fdraw_horizontal_line

    call init_pit

		call fdraw_chart1
		call fdraw_chart2
		call fdraw_chart3

    call fexit

end Start
end
