assume CS:code, DS:data

data segment
    max dw 0
    index dw 0
    res dw ?
    array dw 34, 100, 36, 37, 96, 65,'$'
    len dw 4
    result_str db '000', 0ah, '$' ; 000\n$
data ends

code segment
start:
    mov ax, data
    mov ds, ax       ; инициализация сегмента данных
    
    xor si, sim4
    mov cx, len

    loop_start:
        mov ax, array[si]
        cmp max, ax
        jg less
        
	mov max, ax
	mov index, si
	
	less:
	inc si
	inc si
	
	loop loop_start

    mov bx, index
    mov res, bx      ; сохранение результата в переменной res
    
    ;Вывод в десятичном формате
    xor ah, ah
    mov ax, res

    xor si, si
    mov dl, 100
    div dl       ; ah = mod 100, al = div 100
    
    mov dl, al   ; использовать часть div
    add dl, 48
    mov result_str[si], dl
    inc si

    mov dl, 10   ; использовать часть mod
    mov al, ah
    xor ah, ah
    div dl       ; ah = mod 10, al = div 100 mod 10
    mov dl, al   ; использовать часть div
    add dl, 48
    mov result_str[si], dl
    inc si

    mov dl, ah
    add dl, 48
    mov result_str[si], dl
    
    ;Вывод результата
    mov ah, 09h    ; вывод десятичного числа 
    mov dx, offset result_str
    int 21h
	
    ;Вывод в шестнадцатеричном формате
    xor ah, ah
    mov ax, res
    xor si, si

    mov dl, 16
    div dl ; ah = mod, al = div

    mov dl, al ; использовать часть div
        
    hex_out:
        cmp dl, 10
        jl jump1

        sub dl, 10
        add dl, 65
        jmp jump2

        jump1:
        add dl, 48

        jump2:
        mov result_str[si], dl
        inc si
        mov dl, ah     ; использовать часть mod
        cmp si, 2
        jl hex_out

    mov al, 'h'
    mov result_str[si], al

    ;Вывод результата
    mov ah, 09h    ; вывод шестнадцатеричного числа
    mov dx, offset result_str
    int 21h

    mov ah, 4Ch ; завершение программы
    int 21h
code ends
end start