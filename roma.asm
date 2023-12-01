.model small
.386
;=========================================Helpers
pushAll macro
	push ax
	push bx
	push cx
	push dx
endm pushAll ; DONE

popAll macro
	pop dx
	pop cx
	pop bx
	pop ax
endm popAll ; DONE

setCursor macro row:req, column:req
	pushAll

	mov ah, 02h
	mov dh, byte ptr row
	mov dl, byte ptr column
	mov bh, 0
	int 10h

	popAll
endm setCursor

pressToContinue macro
	setCursor 20, 0
	outputString pressToContinueMessage
	mov ah, 01h    
    int 21h 
endm pressToContinue

clearScreen macro
	pushAll

	mov ax, 0600h
	mov bh, 07h
	xor cx, cx
	mov dx, 184fh
	int 10h

	setCursor 0, 0

	popAll
endm clearScreen

clearStroke macro y:req
	pushAll
	setCursor y, 0
	outputString toClearString
	popAll
	setCursor y, 0
endm clearStroke

clearSection macro y:req, x:req, len:req
local prin, exit
	pushAll
	mov al, x
	mov cx, len
	cmp cx, 0
	jle exit
prin:
	setCursor y, al
	outputSymbol ' '
	inc ax
	dec cx
	cmp cx, 0
	jg prin
exit:
	popAll
endm clearSection
;=========================================Input
inputSymbol macro symbol
	pushAll
	mov ah, 01h
	int 21h
	mov symbol, al
	popAll
endm inputSymbol

inputString macro string
	pushAll
	mov ah, 0ah
	lea dx, string
	mov al, 4
	int 21h
	popAll
endm inputString

inputNumber macro y:req, x:req
local check, positive, exit, movToMem, negative, calc, startInput
	pushAll
	push si
	push di
	mov si, 0
startInput:
	clearSection y, x, 4
	mov inputBufferNum, 0
	setCursor y, x

	inputString inputBufferStr

	mov si, 2
    mov cl, inputBufferStr[si]
	cmp cl, 0dh
	je startInput

	mov si, 2
	mov cl, inputBufferStr[si]
	cmp cl, '-'
	jne check
	setCursor y, x
	outputSymbol '-'
	inc si
check:
	mov bl, inputBufferStr[si]
	cmp bl, '0'
	jl exit
	cmp bl, '9'
	jg exit

	push ax
	mov al, x
	add ax, si
	sub ax, 2
	setCursor y, al
	pop ax

	outputSymbol bl
calc:
	and bx, 0fh
	mov ax, inputBufferNum
	mov cx, 10
	imul cx
	xor cx, cx
	mov cl, inputBufferStr[2]
	cmp cx, '-'
	je negative
	jne positive
negative:
	sub ax, bx
	jmp movToMem
positive:
	add ax, bx
movToMem:
	mov inputBufferNum, ax
	inc si
	jmp check
exit:
	cmp bx, 0dh
	jne startInput
	pop di
	pop si
	popAll
endm inputNumber ; DONE
;========================================= Output
outputEndl macro
	mov ah, 02h
	mov dx, 13
	int 21h
	mov dx, 10
	int 21h
endm outputEndl ; DONE

outputSymbol macro symbol:req
	pushAll
	mov ah, 02h
	mov dl, symbol
	int 21h
	popAll
endm outputSymbol ; DONE

outputString macro string:req
	pushAll
	mov ah, 09h
	mov dx, offset string
	int 21h
	popAll
endm outputString ; DONE

outputNumber macro
local exit, positive, popping, notprintZero
	pushAll
	mov ax, inputBufferNum
	cmp ax, 0
	jne notprintZero
	outputSymbol '0'
	je exit
notprintZero:
	mov cx, 0
	cmp ax, 0
	jge positive
	outputSymbol '-'
	neg ax
positive:
	xor dx, dx
	cmp ax, 0
	je popping
	mov bx, 10
	div bx
	add dl, '0'
	push dx
	inc cx
	jmp positive

popping:
	pop dx
	outputSymbol dl
loop popping

exit:
	popAll
endm outputNumber ; DONE

; ======================================= Menu
showMenu macro
	clearScreen
	outputString menuInterface
endm showMenu

inputOption macro
local wrongOption, start, exit
	pushAll
start:
	mov inputBufferNum, 0
	inputNumber 7, 14
	cmp inputBufferNum, 0
	jl wrongOption
	cmp inputBufferNum, 5
	jg wrongOption
	jmp exit
wrongOption:
	clearStroke 7
	outputString wrongOptionMessage
	setCursor 7, 32
	mov inputBufferNum, 0
	inputNumber 7, 32
	cmp inputBufferNum, 0
	jl wrongOption
	cmp inputBufferNum, 5
	jg wrongOption
exit:
	mov dx, inputBufferNum
	mov chosenOption, dx
	popAll
endm inputOption

runMenu macro
local exit, start, inputMatrixChosen, showMatrixChosen, task1Chosen, task2Chosen, task3Chosen
	pushAll
start:
	showMenu
	inputOption

	mov ax, chosenOption
	cmp ax, 1
	je inputMatrixChosen
	cmp ax, 2
	je far ptr showMatrixChosen
	cmp ax, 3
	je far ptr transposedMatrixChosen
	cmp ax, 4
	je task1Chosen
	cmp ax, 5
	je task2Chosen
	cmp ax, 6
	je task3Chosen
	cmp ax, 0
	je exit
	clearScreen
	jmp start
inputMatrixChosen:
	inputMatrix
	jmp start
showMatrixChosen:
	showMatrix
	jmp start
transposedMatrixChosen:
	transposedMatrix
	jmp start
task1Chosen:
	task1
	jmp start
task2Chosen:
	task2
	jmp start
task3Chosen:
	task3
	jmp start
exit:
	popAll
endm runMenu
; ======================================= [1] Input matrix
inputMatrix macro
local wrongRows, wrongCols, inputRowP, inputColsP, inputMatrixP, forSI, forDI
	pushAll
	push si
	push di
	clearScreen
	outputString numberOfRowsMessage
inputRowP:
	mov inputBufferNum, 0
	inputNumber 0, 29
	cmp inputBufferNum, 1
	jl wrongRows
	cmp inputBufferNum, 10
	jg wrongRows
	xor cx, cx
	mov cx, inputBufferNum
	mov rowsNumber, cx
	jmp inputColsP
wrongRows:
	setCursor 1, 0
	outputString wrongRowsMessage
	mov inputBufferNum, 0
	inputNumber 1, 33
	cmp inputBufferNum, 1
	jl wrongRows
	cmp inputBufferNum, 10
	jg wrongRows
	xor cx, cx
	mov cx, inputBufferNum
	mov rowsNumber, cx
inputColsP:
	setCursor 2, 0
	outputString numberOfColsMessage
	mov inputBufferNum, 0
	inputNumber 2, 32
	cmp inputBufferNum, 1
	jl wrongCols
	cmp inputBufferNum, 10
	jg wrongCols
	xor cx, cx
	mov cx, inputBufferNum
	mov colsNumber, cx
	jmp inputMatrixP
wrongCols:
	setCursor 3, 0
	outputString wrongRowsMessage
	mov inputBufferNum, 0
	inputNumber 3, 33
	cmp inputBufferNum, 1
	jl wrongCols
	cmp inputBufferNum, 10
	jg wrongCols
	xor cx, cx 
	mov cx, inputBufferNum
	mov colsNumber, cx
inputMatrixP:
	clearScreen
	setCursor 0, 0
	outputString enterMatrixMesage
	mov si, 0
	mov di, 0
forSI:
	mov bx, si
	add bx, 1
	mov di, 0
	forDI:		
		mov ax, di
		mov cx, 6
		mul cx
		mov inputBufferNum, 0
		inputNumber bl, al
		mov ax, si
		add ax, si

		push cx
		push dx
		mov cx, colsNumber
		mul cx
		pop dx
		pop cx

		add ax, di
		add ax, di

		push si
		mov si, ax
		mov dx, inputBufferNum
		mov matrix[si], dx
		pop si
	inc di
	cmp di, colsNumber
	jl forDI

inc si
cmp si, rowsNumber
jl forSI

	pop di
	pop si
	popAll
endm inputMatrix
; ======================================= [2] Show matrix
showMatrix macro
local forI, forJ
	pushAll
	clearScreen
	outputString showMatrixMessage
	mov cx, 0
	mov dx, 0
forI:
	xor dx, dx
	forJ:
		xor ax, ax
		xor bx, bx
		mov bx, 1
		add bx, cx
		mov ax, dx
		push bx
		mov bx, 6
		push cx
		push dx
		mul bx
		pop dx
		pop cx
		pop bx
		setCursor bl, al
		
		mov ax, cx
		add ax, cx

		push cx
		push dx
		mov cx, colsNumber
		mul cx
		pop dx
		pop cx

		add ax, dx
		add ax, dx

		mov si, ax
		mov ax, matrix[si]
		xor si, si
		mov inputBufferNum, ax
		outputNumber
	inc dx
	cmp dx, colsNumber
	jl forJ
inc cx
cmp cx, rowsNumber
jl forI
	pressToContinue
	popAll
endm showMatrix

transposedMatrix macro
	pushAll
	outputString transposedMatrixMessage

	pressToContinue
	popAll
endm transposedMatrix
; ======================================= [3] Task 1
task1 macro
local forI, forJ, noNegativeNumber, nextJ, nextI, found
	pushAll
	clearScreen
	outputString task1Header
	mov cx, 0
	mov dx, 0
forI:
	mov ax, cx
	inc ax
	setCursor al, 0
	xor dx, dx
	forJ:
		mov ax, cx
		add ax, cx

		push cx
		push dx
		mov cx, colsNumber
		mul cx
		pop dx
		pop cx

		add ax, dx
		add ax, dx

		mov si, ax
		mov ax, matrix[si]
		xor si, si
;      ---------------------
		mov bx, colsNumber
		dec bx
		cmp ax, 0
		jl found
		cmp dx, bx
		je noNegativeNumber
		jmp nextJ

	noNegativeNumber:
		mov ax, cx
		inc ax
		add ax, '0'
		outputSymbol al
		outputSymbol '.'
		outputSymbol ' '
		outputString noNegativeNumberMessage
		jmp nextJ
	found:
		mov ax, colsNumber
		sub ax, dx
		dec ax
		mov inputBufferNum, 0
		mov inputBufferNum, ax
		mov ax, cx
		inc ax
		add ax, '0'
		outputSymbol al
		outputSymbol '.'
		outputSymbol ' '
		outputString countAfterNegative
		outputNumber
		jmp nextI

	nextJ:
	inc dx
	cmp dx, colsNumber
	jl forJ

nextI:
inc cx
cmp cx, rowsNumber
jl forI

pressToContinue
popAll
endm task1
; ======================================= [4] Task 2
task2 macro
local forI, forJ, nextI, nextJ, notEqual, symmetric
	pushAll
	clearScreen
	outputString task2Header
	mov cx, 0
	mov dx, 0
forI:
	mov ax, colsNumber
	mov dx, 0
	mov bx, 2
	div bx
	mov dx, ax
	dec dx
	forJ:
		xor ax, ax
		xor bx, bx

		mov ax, cx
		add ax, cx

		push cx
		push dx
		mov cx, colsNumber
		mul cx
		pop dx
		pop cx

		add ax, dx
		add ax, dx

		mov si, ax
		mov ax, matrix[si]
		push ax
; ------------------------
		mov ax, cx
		add ax, cx

		push cx
		push dx
		mov cx, colsNumber
		mul cx
		pop dx
		pop cx

		add ax, colsNumber
		add ax, colsNumber

		dec ax
		dec ax
		sub ax, dx
		sub ax, dx

		mov si, ax
		mov ax, matrix[si]
; ------------------------
		mov bx, ax
		pop ax
		cmp ax, bx
		jne notEqual
		cmp dx, 0
		je symmetric
		jmp nextJ

	notEqual:
		mov ax, cx
		inc ax
		setCursor al, 0
		add ax, '0'
		outputSymbol al
		outputSymbol '.'
		outputSymbol ' '
		outputString notSymmetricMessage
		jmp nextI

	symmetric:
		mov ax, cx
		inc ax
		setCursor al, 0
		add ax, '0'
		outputSymbol al
		outputSymbol '.'
		outputSymbol ' '
		outputString symmetricMessage
		jmp nextI

	nextJ:
	dec dx
	cmp dx, 0
	jge forJ

nextI:
inc cx
cmp cx, rowsNumber
jl forI
pressToContinue
popAll
endm task2
; ======================================= [5] Task 3
task3 macro
local exit, notSquare, agree
	pushAll
	clearScreen
	outputString task3Header
	mov ax, colsNumber
	mov bx, rowsNumber
	cmp ax, bx
	jne notSquare
	jmp agree

notSquare:
	setCursor 1, 0
	outputString task3Warning
	inputNumber 4, 14
	mov ax, inputBufferNum
	cmp ax, 1
	je agree
	jmp exit
agree:

	
	pressToContinue
exit:
	popAll
endm task3

.stack 100h
.data
;=======================================Matrix data
	widthOfMatrix equ 10
	matrix dw widthOfMatrix dup(widthOfMatrix dup(0))

	; Input number memory
	inputBufferStr db 8 dup('$')
	inputBufferNum dw 0 
	isInputCorrect db 1

	; Matrix memory
	rowsNumber dw 0
	colsNumber dw 0

	; Menu memory
	chosenOption dw 0

	; Interface
	menuInterface db 'Home work var 26', 13, 10
				db '[1] Enter the matrix', 13, 10
				db '[2] Show matrix', 13, 10
				db '[3] View transposed matrix, 13, 10
				db '[4] Task 1', 13, 10
				db '[5] Task 2', 13, 10
				db '[6] Task 3', 13, 10
				db '[0] Exit', 13, 10
				db 'Enter option: ', '$'
	wrongOptionMessage db 'Wrong option number. Try again: ', '$'
	wrongRowsMessage db 'Wrong number of rows. Try again: ', '$'
	wrongColsMessage db 'Wrong number of columns. Try again: ', '$'
	emtryNumberInput db 'You typed empty number. Try again: ', '$'
	toClearString db '                                                   ', '$'
	numberOfRowsMessage db 'Enter number of rows [1-10]: ', '$'
	numberOfColsMessage db 'Enter number of columns [1-10]: ', '$'
	enterMatrixMesage db 'Enter the matrix:', '$'
	showMatrixMessage db 'Current matrix:', '$'
	transposedMatrixMessage db 'Transposed matrix:', '$'
	task1Header db 'Task #1', '$'
	task2Header db 'Task #2', '$'
	task3Header db 'Task #3', '$'
	task3Warning db 'Current matrix is not square. It will be cut. Is it okay?', 13, 10
				db '[1] Yes', 13, 10
				db '[Other] No', 13, 10
				db 'Enter option: ', '$'
	noNegativeNumberMessage db 'No negative number in the row', '$'
	countAfterNegative db 'Count of numbers after first negative element: ', '$'
	pressToContinueMessage db 'Press any key to continue...', '$'
	notSymmetricMessage db 'The stroke is not symmetric', '$'
	symmetricMessage db 'The stroke is symmetric', '$'
	errorMessage db 'Error!!!', '$'
	log db 'log', 13, 10, '$'
    mes1 db 'Enter N:' , '$'
    mes4 db 'Enter sequence:', 13, 10, '$'

.code
start:
	mov ax, @data
	mov ds, ax

menu:
	runMenu
exit:
	mov ax, 4c00h
	int 21h
end start
end
