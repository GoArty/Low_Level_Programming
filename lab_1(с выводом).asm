assume CS:code, DS:data

data segment
    a db 1
    b db 4
    c db 2
    d db 5
    res db ?
    result_str db '000', 0ah, '$' ; 000\n$
data ends

code segment
start:
    mov ax, data
    mov ds, ax       ; инициализация сегмента данных

    ;вар 2
    ;( a + b/c ) * d - 4 = ( 1 + 4/2 ) * 3 - 4 = 5
    
    ;Вычисление ( a + b/c ) * d - 4
    mov al, a
    mov bl, b
    mov cl, c 
    mov dl, d
    
    mul cl
    add al, bl       ; al = a + b
    div cl           ; al = (a + b) / c
    mul dl           ; al = ( (a + b) / c ) * d
    sub al, 4        ; al = ( (a + b) / c ) * d - 4
    
    mov res, al      ; сохранение результата в переменной res
    
    ;Вывод в десятичном формате
    xor ah, ah
    mov al, res

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
    mov al, res
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