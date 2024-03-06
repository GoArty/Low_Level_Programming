assume cs: code, ds: data

data segment
	string1_10 db 25, ?, 25 dup (0) ;число 1 в 10
	string1_16 db 25, ?, 25 dup (0) ;число 1 в 16

	string2_10 db 25, ?, 25 dup (0) ; число 2 в 10
	string2_16 db 25, ?, 25 dup (0) ; число 2 в 16

	string_ans_10 db 50, 50 dup (0)    
	string_ans_16 db 50, 50 dup (0)    

	msg1 db 0ah, 0dh, "Enter first numebr: $"
	msg2 db 0ah, 0dh, "Enter second number: $"
	
	msg_ans_10 db 0ah, 0dh, "Result of addition in dec: $"
	msg_ans_16 db 0ah, 0dh, "Result of addition in hex: $"

	msg_sis_10 db 0ah, 0dh, "The basis of the sistem is 10 $"
	msg_sis_16 db 0ah, 0dh, "The basis of the sistem is 16 $"
	
	line db 0ah, 0dh, '$'
data ends

code segment
stdn macro m, buf	;реализация ввода числа
	mov ax, 0
	mov dx, offset m
	mov ah, 09h
	int 21h		
	
	mov dx, offset buf
	mov ah, 0ah
	int 21h		
endm

fromString proc ;перевод из ascii и проверка корректности ввода
	pop bp 
	pop di 
	mov cx, 0
	mov cl, [di] 
	add di, 1
	cycle:
		cmp byte ptr [di], 48
		jb exit				
		cmp byte ptr [di], 57
		ja inhex				
		sub byte ptr [di], 30h		
		jmp incr
		inhex: 	
			cmp byte ptr [di], 65
			jb exit				 
			cmp byte ptr [di], 70			
			ja lower			
			sub byte ptr [di], 55	
			jmp incr
		lower: 	
			cmp byte ptr [di], 97
			jb exit				
			cmp byte ptr [di], 102
			ja exit				
			sub byte ptr [di], 87	
		incr: 
			inc di			
			dec cx
			or cx, cx
			jne cycle
			jmp next
	exit: 
		mov ah, 4ch
		int 21h
	next: 
	mov byte ptr [di], '$'	
	push bp
	ret	
fromString endp

toString proc ;перевод в ascii 
	pop bp
	pop di
	mov cx, 0
	mov cl, [di]
	add di, 1
	mov dx, di
	makeStr:
		cmp byte ptr [di], 9		
		ja letter
		add byte ptr [di], 48 		
		jmp nxt
		letter:
			add byte ptr [di], 55 	
		nxt:
			inc di				
			dec cx				
			or cx, cx
			jne makeStr
	mov byte ptr [di], '$'			
	mov ah, 09h
	int 21h	
	mov dx, offset line
	int 21h
	push bp
	ret
toString endp

substraction proc		;процедура вычитания чисел
	push bp			
	mov bp, sp		
	
	mov di, [bp+4]		
	mov si, [bp+6]		
	mov bx, [bp+8]		

	mov cx, 0
	mov dx, 0
	mov cl, [di]		
	mov dl, [si]		
	add di, cx 		
	add si, dx		
	
	sub cx, dx		 
	add bx, [bx]		
	
	push cx
	xor ax, ax		
	xor cx, cx		
	subcycle:
		or dx, dx	
		je thensub
		mov al, byte ptr [di]	
		cmp al, cl
		jnb subelse
		add al, [bp+10]
		dec al
		jmp subt
		subelse:
			sub al, cl
			xor cx, cx
		subt:
			cmp al, byte ptr [si]
			jnb ssub
			add al, [bp+10]
			mov cx, 1
		ssub:
			sub al, byte ptr [si]
		mov byte ptr [bx], al 
		dec di		
		dec si
		dec dx
		dec bx
		jmp subcycle
	thensub: 
		pop dx
	sublast:	
		xor ah, ah
		or dx, dx
		je subexit
		mov al, byte ptr [di]
		cmp al, cl
		jnb subb
		add al, [bp+10]
		dec al
		jmp subs
		subb:
			sub al, cl
			xor cx, cx
		subs:	
			mov byte ptr [bx], al
			xor ah, ah		
			dec di
			dec dx
			dec bx
		jmp sublast
	subexit: 
	mov sp, bp 		 
	pop bp     		
	ret 6	   		
substraction endp

start:	
	mov ax, data
	mov ds, ax
	
	;10-тичная система счисления
	lea dx, msg_sis_10 	
	mov ah, 09h
	int 21h
	
	stdn msg1, string1_10 	;ввод числа 1 
	stdn msg2, string2_10 	;ввод числа 2
	
	mov dx, offset string1_10 + 1
	push dx		
	call fromString		;преобразование числа 1 из ascii 
	mov dx, offset string2_10 + 1
	push dx		
	call fromString		;преобразование числа 2 из ascii 

	;вычитание
	push 10
	push offset string_ans_10 
	push offset string2_10 + 1
	push offset string1_10  + 1
	call substraction	;вычитание чисел
	
	lea dx, msg_ans_10 
	mov ah, 09h
	int 21h	
	push offset string_ans_10 
	call toString		;вывод результата
	
	;16-тиричная система счисления
	lea dx, msg_sis_16 
	mov ah, 09h
	int 21h
	
	stdn msg1, string1_16 	;ввод числа 1 
	stdn msg2, string2_16 	;ввод числа 2
	
	mov dx, offset string1_16 + 1
	push dx		
	call fromString		;преобразование числа 1 из ascii 
		
	mov dx, offset string2_16 + 1
	push dx		
	call fromString		;преобразование числа 2 из ascii 

	push 16
	push offset string_ans_16 
	push offset string2_16 + 1
	push offset string1_16 + 1
	call substraction	;вычитание чисел
	
	lea dx, msg_ans_16 
	mov ah, 09h
	int 21h	
	push offset string_ans_16 
	call toString		;вывод результата
	
mov ah, 4ch
int 21h
code ends
end start