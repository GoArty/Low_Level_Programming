assume cs: code, ds: data

data segment
    newline db 0Ah, "$"
    string db 100, 99 dup ('$')
    string1 db 100, 99 dup ('$')
    max_len dw 16
    num_a db 100, 99 dup (0) 
    num_b db 100, 99 dup (0) 
    num_c db 100, 99 dup (0) 
    notation db 10 ; decimal or hex
    cmpres db 0
    error_wrong_symbol db 100, " error: non-numerical symbol $"
data ends

include macro.asm

code segment

tohex proc
    mov cl, 60h
    ifless cl, ch, tohexendif
        sub ch, 'a'
        add ch, ':'
    tohexendif:
    ret
tohex endp

fromhex proc
    mov cl, '9'
    ifless cl, ch, fromhexendif
        sub ch, ':'
        add ch, 'a'
    fromhexendif:
    ret
fromhex endp

numtostring proc
    mov bp, sp
    mov si, [bp + 2] ; num offset in di
    mov ax, max_len
    xor di, di ; di for indexing

    add si, max_len
    mov bl, [si]
    cmp bx, 0
    je plus
        printchar '-'
        jmp endsign
    plus:
        printchar '+'
    endsign:
    sub si, max_len

    mov bx, 2
    loop_numtostring:
        mov ch, [si]
        add ch, '0'
        call fromhex
        mov string[bx], ch

        inc si
        inc di
        inc bx
        ifless di, ax, break_numtostring
            jmp loop_numtostring
        break_numtostring:
    ret
numtostring endp

tonum proc
    mov bp, sp
    mov di, [bp + 2] 
    strlen string, a 
    mov bx, max_len
    sub bx, ax  
    add ax, 2
    mov si, 2 
    xor dx, dx
    mov [di], dx 
    loop_tonum:
        mov ch, string[si]
        call tohex
        ifnotnumber ch, ok_it_is_number
        ifnotminus ch, minus_case
            error_symbol error_wrong_symbol, ch
        ok_it_is_number:


        jmp number_case
        minus_case:
            push ax
            add di, max_len
            mov ax, [di]
            not ax
            mov [di], ax
            sub di, max_len
            pop ax
            jmp endcase
        number_case:
            sub ch, '0'
            mov [di + bx], ch
        endcase:

        inc si
        inc bx
        ifless si, ax, break_tonum
            jmp loop_tonum
        break_tonum:
    ret
tonum endp

swap_nums proc
    push si
    push ax
    push bx
    mov si, max_len 
    dec si
    loop_swap:
        mov al, num_a[si]
        mov bl, num_b[si]
        mov num_a[si], bl
        mov num_b[si], al

        dec si
        cmp si, 0
        je break_swap
        jmp loop_swap
    break_swap:    
    pop bx
    pop ax
    pop si
    ret
swap_nums endp

compare_nums proc
    push di
    push ax
    push bx    
    xor ax, ax
    xor bx, bx
    xor si, si

    mov di, max_len
    mov al, num_a[di]
    mov bl, num_b[di]

    cmp ax, bx
    je loop_comp
    jl sign_less
        mov cmpres, 2        
        jmp endcompare_nums
    sign_less:
        mov cmpres, 1
        jmp endcompare_nums
    
    loop_comp:
        mov al, num_a[si]
        mov bl, num_b[si]
        cmp ax, bx
        je cmp_equal
        jl equal_less
            mov cmpres, 1
            jmp break_comp
        equal_less:
            mov cmpres, 2
            jmp break_comp
        cmp_equal:

        inc si
        cmp si, max_len
        jge break_comp
        jmp loop_comp
    break_comp:

    endcompare_nums:
    pop bx
    pop ax
    pop di
    ret
compare_nums endp

calc_signed_mul proc
    mov di, max_len
    sub di, 1
    xor bx, bx
    loop_sumprod:
        mov si, max_len
        sub si, 1
        loop_prod:
            xor ax, ax
            xor cx, cx
            xor dx, dx
            mov al, num_a[si]
            mov dl, num_b[di]
            mul dx
            mov cl, notation
            div cl
            sub si, bx
            add num_c[si - 1], al
            add num_c[si], ah
            add si, bx
            dec si
            cmp si, 0
            jl break_prod
            jmp loop_prod
        break_prod:
        inc bx
        dec di
        cmp di, 0
        jl break_sumprod
        jmp loop_sumprod
    break_sumprod:

    mov di, max_len
    sub di, 1
    loop_fix:
        ; reminder in ch
        xor ax, ax
        mov cl, notation
        mov al, num_c[di]
        div cl
        add num_c[di - 1], al
        mov num_c[di], ah
        dec di
        cmp di, 0
        jl break_fix
        jmp loop_fix
    break_fix:
    mov di, max_len
    push ax
    push bx
    mov al, num_a[di]
    mov bl, num_b[di]
    xor al, bl
    mov num_c[di], al
    pop bx
    pop ax
    ret
calc_signed_mul endp

start:
    mov ax, data
    mov ds, ax

    scannum num_a
    scannum num_b
    xor dx, dx
    mov num_c[0], dh

    call calc_signed_mul

    printnum num_a
    printnum num_b    
    printnum num_c
    
    mov ah, 4ch
    int 21h
code ends
end start