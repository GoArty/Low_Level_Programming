assume CS: code, DS: data

data segment
	str1 db 25, ?, 25 dup ('$') 	; текст
	char_first db 0 		; символ, который заменяем
	char_second db 0 		; указанный новый символ
	size_ db 0
	msg_1 db 0ah, 0dh, "Enter text: $"
	msg_2 db 0ah, 0dh, "Enter the char that you want to replace: $"
	msg_3 db 0ah, 0dh, "Enter new char: $"
	msg_4 db 0ah, 0dh, "Result: $"
	line db 0ah, 0dh, '$'
data ends

code segment

include macro.asm
	
start:	
	mov ax, data
	mov ds, ax
	
	stdn msg_1
	mov dx, offset str1
	mov ah, 0ah
	int 21h		
	
	input_char msg_2, char_first
	
	input_char msg_3, char_second
	
	mov si,offset str1
	inc si
	mov al,[si]
	mov [size_],al
 
	xor cx,cx
	mov cl,[size_]

	replace char_first, char_second	
	
	cld
	mov di,offset str1
	xor bx,bx
	mov bl,[size_]
	add di,bx
	add di,2
	mov si,offset line
	mov cx,3
	rep movsb				
 
	stdn msg_4
	stdn str1+2		
	exit_app

code ends
end start