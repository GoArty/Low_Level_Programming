stdn macro msg			;ввести строку
	mov ax, 0
	mov dx, offset msg
	mov ah, 09h
	int 21h		
endm

input_char macro msg, char	;ввод символа
	stdn msg
	symbol		
	mov [char], al
endm

symbol macro			;ввод символа
	mov ah, 01h
	int 21h		
endm

replace macro sa, sb		;замена символа [c_f] на [c_s]
	rep1:
		inc si
		mov al,[si]
		cmp al,[c_f]
		jne rep2
		mov al,[c_s]
		mov [si],al
		
	rep2:
		loop rep1
endm	

exit_app macro			;завершение программы
	mov ah, 4ch
	int 21h
endm
