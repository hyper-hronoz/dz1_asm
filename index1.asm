.486
.model small
.stack 100h
.data
    ticks dw 0       ; Variable to store timer ticks

.code
    main proc
        mov ax, 4C00h   ; Exit program
        int 21h

    main endp

    delay proc
        mov ah, 00h     ; Set up timer interrupt function
        int 1Ah         ; Get timer ticks
        mov [ticks], dx ; Save the current ticks

    delay_loop:
        mov ah, 00h     ; Set up timer interrupt function
        int 1Ah         ; Get timer ticks again
        sub dx, [ticks] ; Calculate the difference
        cmp dx, 18      ; Adjust the delay time as needed (18 ticks ≈ 1 second)
        jl delay_loop   ; Continue looping if not enough time has passed

        ret
    delay endp

    start:
        mov ax, @data   ; Initialize DS
        mov ds, ax

        ; Your code here

        call delay      ; Call the delay procedure

        ; Your code continues here

        mov ax, 4C00h   ; Exit program
        int 21h
end start
