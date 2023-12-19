.486
model use16 small
.stack 100h
.data
b dw 175
k1 dw 1 
x dw ?
pi dw 180 
y dw ?
axis dw ?
k2 dw 70
two dw 2
one dw 1
oldY dw 174
raznitsa dw 180
minus dw -1
dvak dw 22
sto dw 100
pyatdesyat dw 50
koefF2 dw 300
koefF1 dw 200
koefF3 dw 399
.code
Start:
 mov ax, @data
 mov ds, ax
 xor ax, ax
 mov al, 10h
 int 10h
 mov ax, 0600h 
 mov bh, 15 
 mov cx, 0000b 
 mov dx, 184Fh
 int 10h
 mov ah, 0Ch
 mov al, 10 
 mov bh, 0h
 mov cx, 400
@metka1: 
 push cx
 mov axis, cx
 mov dx, axis 
 mov cx, koefF2
 int 10h
 pop cx 
 loop @metka1
 mov ah, 0ch
 mov al, 30
 mov cx, 639 
 mov bh, 0h 
 mov dx, 174
@metka2:
 int 10h
 loop @metka2
 mov si, 0 
@metka3: 
 mov al,0
 mov ah,86h
 xor cx,cx
 mov dx,10000   
 int 15h

 mov x, si 
 cmp si,200
 jb fun1
 cmp si,400
 jb fun2
 jmp fun3
 fun2:
    mov al, 9
    fild koefF2
    fild x
    fsub st(0),st(1)
    fild two
    fdivr st(0),st(1)
   	 fild two
   	 fmul st(0),st(1)
   	 jmp perevod
 fun1:
    mov al, 4
    fild x
    fild koefF1
    fsub st(0),st(1)
    fmul st(0),st(0)
    fild one
    fadd st(0),st(1)
    fild x
    fild koefF1
    fsub st(0),st(1)
    fdivr st(0),st(2)
    fild minus
    fmul st(0),st(1)
    fild pyatdesyat
    fsubr st(0),st(1)
    jmp perevod
 
 fun3:
     mov al, 3
     fild koefF3
     fild x
     fsub st(0),st(1)
     fild dvak
     fdivr st(0),st(1)
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
     fild x
     fdivr st(0),st(1)
     fild two
     fadd st(0),st(1)
     jmp perevod
    
 perevod:
    fldpi 
    fmul 
    fild pi 
    fdiv 
    fild k1 
    fdiv
    fimul k2 
    fchs 
    fiadd b 
    frndint
    fistp y 
 mov ah, 0Ch 
 mov bh, 0h 
 mov cx,si
 mov dx, y
 int 10h
 inc si
 cmp si,639
 jb @metka3
mov ah, 8h 
 int 21h
mov ax, 4c00h
 int 21h
end Start
end
