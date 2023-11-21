.model small
.stack 100h

.data

max_rows equ 100
max_columns equ 100

rows dw ?
columns dw ?

matrix  dw max_rows * max_columns dup(?)

message db 'Enter a number of any length: $'


msg_menu db '1. print matrix',           0, 10
         db '2. move zeros',             0, 10
         db '3. compare row and column', 0, 10
         db '4. find max',               0, 10
         db '5. exit',                   0, 10
         db '>>', '$'

msg_not_equal_second db 'Not equal in second task', 13, 10, '$'
msg_equal_second db 'Equal in second task', 13, 10, '$'
msg_maximal db 'Maximal value: ', '$'
msg_input_index db 'Input index>>', '$'
msg_input_rows db 'Input rows>>', '$'
msg_input_columns db 'Input columns>>', '$'

matrix_maximal dw 0


index dw 0
offst equ 2
tdgt equ add dx, 30h

buffer_size equ 255
input_buffer db buffer_size dup('$')
result dw 0

newline db 0dh, 0ah, '$'
.code

mput_msg macro msg
  mov dx, offset msg
endm


fexit proc
  mov ax, 4c00h
	int 21h
fexit endp

fprint_ln proc
  push ax
  push dx

  mov dl, 10
  mov ah, 02h
  int 21h

  mov dl, 13
  mov ah, 02h
  int 21h

  pop dx
  pop ax
  ret
fprint_ln endp

; as an argument mov dx, [matrix + 2]
fprint_char_by_addr proc
  push ax
  push dx

  mov ah, 02h
  int 21h

  pop dx
  pop ax
  ret
fprint_char_by_addr endp

fprint_matrix proc
  push ax
  push cx
  push bx
  push dx
  push si
  push di

  mov cx, 0 ; rows counter
  mov bx, rows

  print_matrix_iloop:
    cmp cx, bx
    je print_matrix_iloop_end
    
    xor ax, ax

    mov ax, cx

    push ax
    push bx

    mov ax, offst
    mov bx, columns
    mul bx
    mov dx, ax

    pop bx
    pop ax

    mul dx
    mov si, ax

    mov di, ax 

    push ax
    push bx
    mov ax, offst
    mov bx, columns
    mul bx
    add di, ax
    pop bx
    pop ax

    xor ax, ax
    print_matrix_jloop:
      cmp si, di
      je print_matrix_jloop_end

      mov dx, [matrix + si]
      tdgt
      call fprint_char_by_addr

      mov dx, ' '
      call fprint_char_by_addr

      add si, offst 
      jmp print_matrix_jloop
    print_matrix_jloop_end:
      inc cx

      mov dx, 10
      call fprint_char_by_addr

      jmp print_matrix_iloop
  print_matrix_iloop_end:
      pop ax
      pop cx
      pop bx
      pop dx
      pop si
      pop di
      ret

fprint_matrix endp

fmove_zeros proc
  push ax
  push cx
  push bx
  push dx
  push si
  push di

  mov ax, 0
  move_zeros_iloop:
    cmp ax, rows
    je move_zeros_iloop_end

    mov cx, 0
    move_zeros_jloop:
      push ax
      mov ax, rows
      dec ax
      cmp cx, ax
      pop ax
      je move_zeros_jloop_end

      push ax

      ; mov si, columns * offst * ax
      push ax
      push bx
      mov ax, offst
      mov bx, columns
      mul bx
      mov si, ax
      pop bx
      pop ax
      mul si
      mov si, ax

      ; mov di, columns * offst * ax + columns * offst
      mov di, ax
      push ax
      push bx
      mov ax, offst
      mov bx, columns
      mul bx
      add di, ax
      pop bx
      pop ax
      sub di, offst

      pop ax
      move_zeros_kloop:
        cmp si, di
        je move_zeros_kloop_end
          
        mov dx, [matrix + si]
        cmp dx, 0
        je swap

        add si, offst
        jmp move_zeros_kloop

        swap:
          ; tdgt
          ; call fprint_char_by_addr
          push ax
          mov ax, [matrix + si + offst]
          mov [matrix + si], ax
          mov [matrix + si + offst], 0
          pop ax
          add si, offst
          jmp move_zeros_kloop
      move_zeros_kloop_end:
        inc cx
        jmp move_zeros_jloop
    move_zeros_jloop_end:
      inc ax
        jmp move_zeros_iloop
  move_zeros_iloop_end:
    pop ax
    pop cx
    pop bx
    pop dx
    pop si
    pop di
    ret

fmove_zeros endp

; dx argument required
fprint_message proc
  mov ah, 09h
  int 21h
  ret
fprint_message endp

fcompare_rows_columns proc
  push ax
  push bx
  push cx
  push dx

  ; danger bug is possible
  xor ax, ax
  mput_msg msg_input_index
  call fprint_message
  call finput
  xor ah, ah
  sub al, 30h
  cmp ax, rows  
  jge fcompare_rows_columns_exit
  mov index, ax
  call fprint_ln

  mov ax, index
  push ax
  mov ax, columns
  mov bx, offst
  mul bx
  mov bx, ax
  pop ax
  mul bx
  mov si, ax

  push ax
  push bx
  mov ax, offst
  mov bx, columns
  mul bx
  sub ax, offst
  add si, ax
  pop bx
  pop ax
  mov di, columns
  dec di
  jmp compare_rows_columns_loop
  fcompare_rows_columns_exit:
    call fprint_message
    pop dx
    pop cx
    pop bx
    pop ax
    ret
  compare_rows_columns_loop:
    mov ax, index
    push ax
    mov ax, offst
    mov bx, columns
    mul bx
    mov bx, ax
    pop ax
    mul bx
    sub ax, offst
    cmp si, ax
    je compare_rows_columns_loop_end 

    cmp di, -1
    je compare_rows_columns_loop_end 

    ; column item
    push ax
    push bx
    push cx

    ; mov dx, [matrix + 2 * columns * offst + index * offst] 
    mov dx, [matrix] 
    mov ax, di

    push ax 
    mov ax, offst
    mov bx, columns
    mul bx
    mov bx, ax
    pop ax

    mul bx
    push ax
    mov ax, index
    mov bx, offst
    mul bx
    mov bx, ax
    pop ax
    add ax, bx

    mov bx, ax
    mov dx, [bx]

    pop cx
    pop bx
    pop ax

    ; push dx
    ; tdgt
    ; call fprint_char_by_addr
    ; pop dx

    ; row item
    mov bx, [matrix + si]
    ; push dx
    ; mov dx, bx
    ; tdgt
    ; call fprint_char_by_addr
    ; pop dx
    
    cmp bx, dx
    jne compare_rows_columns_not_equal

    sub si, offst
    dec di
    jmp compare_rows_columns_loop
  compare_rows_columns_loop_end:
    mput_msg msg_equal_second
    jmp fcompare_rows_columns_exit
  compare_rows_columns_not_equal:
    mput_msg msg_not_equal_second
    jmp fcompare_rows_columns_exit

fcompare_rows_columns endp

ffind_maximal proc
  push ax
  push cx
  push bx
  push dx
  push si
  push di

  mov cx, 0 ; rows counter
  mov bx, rows

  find_maximal_iloop:
    cmp cx, bx
    je find_maximal_iloop_end
    
    xor ax, ax

    mov ax, cx

    push ax
    push bx
    mov ax, rows
    mov bx, offst
    mul bx
    mov dx, ax
    pop bx
    pop ax

    mul dx
    mov si, ax

    mov di, ax 

    push ax
    push bx
    mov ax, offst
    mov bx, columns
    mul bx
    add di, ax
    pop bx
    pop ax

    xor ax, ax
    find_maximal_jloop:
      cmp si, di
      je find_maximal_jloop_end

      ; i in cx
      ; mov dx, cx
      ; tdgt
      ; call fprint_char_by_addr

      ; blows makes ax: 0123
      push ax
      push bx
      mov ax, si
      mov bx, offst
      cwd
      div bx
      mov bx, columns
      div bx
      ; mov dx, ax
      pop bx
      pop ax

      ; j in dx
      ; tdgt
      ; call fprint_char_by_addr

      cmp dx, cx
      jg find_maximal_grt_mn_dgnl

      find_maximal_jloop_ret:

      add si, offst 
      jmp find_maximal_jloop
    find_maximal_jloop_end:
      inc cx

      call fprint_ln

      jmp find_maximal_iloop
  find_maximal_iloop_end:
    jmp ffind_maximal_exit

  find_maximal_set_new:
    mov [matrix_maximal], dx 
    jmp find_maximal_jloop_ret

  find_maximal_grt_sd_dgnl:
    mov dx, [matrix + si]
    tdgt
    call fprint_char_by_addr
    mov dx, ' '
    call fprint_char_by_addr

    mov dx, [matrix + si]
    cmp dx, matrix_maximal
    jg find_maximal_set_new
    jmp find_maximal_jloop_ret

  find_maximal_grt_mn_dgnl:
    push ax
    mov ax, columns
    sub ax, cx
    dec ax
    cmp dx, ax 
    pop ax
    jl find_maximal_grt_sd_dgnl

  ffind_maximal_exit:
    call fprint_ln
    mput_msg msg_maximal
    call fprint_message
    mov dx, matrix_maximal
    tdgt
    call fprint_char_by_addr
    pop ax
    pop cx
    pop bx
    pop dx
    pop si
    pop di
    ret
      
ffind_maximal endp

finput proc
  mov ah, 1     
  int 21h
  ret
finput endp

fshow_menu proc
  mput_msg msg_menu
  call fprint_message
  
  call finput

  cmp al, '1'  
  je option1
  cmp al, '2'
  je option2
  cmp al, '3'
  je option3
  cmp al, '4'
  je option4
  cmp al, '5'
  je fshow_menu_exit

  jmp fshow_menu

  option1:
    call fprint_ln
    call fprint_matrix
    call fprint_ln
    jmp fshow_menu

  option2:
    call fprint_ln
    call fmove_zeros
    call fprint_ln
    jmp fshow_menu

  option3:
    call fprint_ln
    call fcompare_rows_columns
    call fprint_ln
    jmp fshow_menu

  option4:
    call fprint_ln
    call ffind_maximal
    call fprint_ln
    jmp fshow_menu

  fshow_menu_exit:
    ret

fshow_menu endp

ffill_matrix proc
  push ax
  push cx
  push bx
  push dx
  push si
  push di

  mov cx, 0 ; rows counter
  mov bx, rows

  fill_matrix_iloop:
    cmp cx, bx
    je fill_matrix_iloop_end
    
    xor ax, ax

    mov ax, cx

    push ax
    push bx

    mov ax, offst
    mov bx, columns
    mul bx
    mov dx, ax

    pop bx
    pop ax

    mul dx
    mov si, ax

    mov di, ax 

    push ax
    push bx
    mov ax, offst
    mov bx, columns
    mul bx
    add di, ax
    pop bx
    pop ax

    xor ax, ax
    fill_matrix_jloop:
      cmp si, di
      je fill_matrix_jloop_end

      push ax
      call finput
      sub al, 30h
      xor ah, ah
      mov [matrix + si], ax
      pop ax

      mov dx, ' '
      call fprint_char_by_addr

      add si, offst 
      jmp fill_matrix_jloop
    fill_matrix_jloop_end:
      inc cx

      mov dx, 10
      call fprint_char_by_addr

      jmp fill_matrix_iloop
  fill_matrix_iloop_end:
      pop ax
      pop cx
      pop bx
      pop dx
      pop si
      pop di
      ret

ffill_matrix endp

start:
  mov ax, @data
  mov ds, ax

  mput_msg msg_input_rows
  call fprint_message
  call finput
  call fprint_ln
  sub al, 30h
  mov ah, 0
  mov rows, ax

  mput_msg msg_input_columns
  call fprint_message
  call finput
  call fprint_ln
  sub al, 30h
  mov ah, 0
  mov columns, ax

  call ffill_matrix

  call fshow_menu
  call fexit

end start
