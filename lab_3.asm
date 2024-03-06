assume cs:code, ds:data

data segment
    enterN db 'Enter n: $'
    enterSource db 'Enter source: $'
    printRes db 'Destination: $'
    dummy db 0Dh, 0Ah, '$'
    
    nameparN label byte
    maxlenN db 4
    actlenN db ?
    namefldN db 4 dup('$')

    source db 32, 99 dup (0)           ; Буфер для строки-источника
    destination db 100 dup (0)        ; Буфер для строки-получателя
data ends

code segment

copy_string proc
    push bp
    mov bp, sp
    mov cx, [bp+6]
    mov di, cx
    mov destination[di], '$'

    mov bx, offset [bp+4]  
    mov si, 2
    mov di, 0

    xor ax, ax
start_loop:
    mov al, bx[si]
    mov destination[di], al
    cmp bx, '$'       
    je copy_done            ; Если достигнут, завершение процедуры
    inc si
    inc di
    loop start_loop       ; Рекурсивный вызов процедуры для следующего байта
    
copy_done:
    pop bp
    pop bx
    
    push offset destination 
    push bx 
    ret
copy_string endp

start:
    mov ax, data
    mov ds, ax

    ; Ввод числа n 
    mov dx, offset enterN
    mov ah, 09h
    int 21h

    mov dx, offset nameparN
    mov ah, 0Ah
    int 21h

    xor ax, ax
    mov al, namefldN
    sub al, 48
    
    cmp ax, 0
    je zero_ax
    push ax

    xor ax, ax
    mov dx, offset dummy ; перевод строки
    mov ah, 09h
    int 21h

    ; Ввод строки-источника
    mov dx, offset enterSource 
    mov ah, 09h
    int 21h

    mov dx, offset source         
    xor ax, ax
    mov ah, 0Ah            ; Функция DOS для ввода строки
    int 21h                ; Вызов DOS-прерывания для ввода


    push dx
    call copy_string	    ; Вызов процедуры для копирования строки
    
    xor ax,ax
    mov dx, offset dummy ; перевод строки
    mov ah, 09h
    int 21h


    mov dx, offset printRes
    mov ah, 09h
    int 21h
    
    xor ax, ax
    pop dx                 ; Загрузка адреса строки-получателя в DX
    mov ah, 09h            ; Функция DOS для вывода строки
    int 21h                ; Вызов DOS-прерывания для вывода
    
    zero_ax: 
mov ah, 4Ch
int 21h
code ends
end start