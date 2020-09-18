; 18 446 744 073 709 551 616    64 bit (8 Byte)   R#X      QWORD   DQ      RESQ
; 4 294 967 295                 32 bit (4 Byte)   E#X      DWORD   DD      RESD
; 65536                         16 bit (2 Byte)   #X       WORD    DW      RESW
; 256                           8 bit  (1 Byte)   #H       BYTE    DB      RESW
; 256                           8 bit  (1 Byte)   #L       BYTE    DB      RESB
    
;push -> 4 3 2 1 -> pop
    
%macro pushd 0
    push edx
    push ecx
    push ebx
    push eax
%endmacro

%macro popd 0
    pop eax
    pop ebx
    pop ecx
    pop edx
%endmacro

%macro print 2
    pushd
    mov edx, %1
    mov ecx, %2
    mov ebx, 1
    mov eax, 4
    int 0x80
    popd
%endmacro

%macro nl 0
    print nlen, newline
%endmacro

%macro avg_array 2
    pushd
    
    ; Обнуляем переменные для подсчётов
    mov eax, 0
    mov bx, 0
    
    ; Суммируем элементы
    %%_loop:
        add eax, [%1+ebx]   ;eax -> сумма
        add bx, 4           ;bx -> индекс
    cmp bx, alen 
    jne %%_loop

    ; Сохраняем сумму в память
    mov [%2], eax
    
    ; Считаем кол-во элементов массива (с размерностью ;))
    mov eax, alen
    mov ecx, 4
    mov edx, 0
    div ecx
    
    ; Считаем среднее
    mov ecx, eax
    mov eax, [%2]
    mov edx, 0
    div ecx
    
    ; Сохраняем среднее в память
    mov [%2], eax
    
    popd
%endmacro

%macro dprint 0
    pushd
    
    mov ecx, 10
    mov bx, 0   
    
    %%_divide:
        mov edx, 0
        div ecx
        push dx
        inc bx
    test eax, eax
    jnz %%_divide 
        
    mov cx, bx
        
    %%_digit:
        pop ax
        add ax, '0'
        mov [count], ax
        print 1, count
        dec cx
        mov ax, cx
    cmp cx, 0
    jg %%_digit
    
    popd
%endmacro

section .text

global _start

_start:

    ; Считаем среднее по x
    avg_array x, temp1
    mov eax, [temp1]
    dprint
    
    nl
    
    ; Считаем среднее по y
    avg_array y, temp2
    mov eax, [temp2]
    dprint
    
    nl
    
    ; Вычитаем из x y
    mov eax, [temp1]
    mov ecx, [temp2]
    
    sub eax, ecx
    
    ; Проверка флага CF (знак минус)
    cmp eax, 0
    jge _NOT_NEGATIVE ;     5-4 -> _NOT_NEGATIVE      4-5 -> _NEGATIVE
    
    _NEGATIVE:
        print len, message 
        mov eax, [temp2]
        mov ecx, [temp1]
    
        sub eax, ecx
    _NOT_NEGATIVE:
        dprint
    
    mov eax, 1
    int 0x80

section .data
    x dd 5, 3, 2, 6, 1, 7, 4
    alen equ $ - x
    y dd 0, 10, 1, 9, 2, 8, 5
    
    message db "-"
    len equ $ - message
    newline db 0xA, 0xD
    nlen equ $ - newline

section .bss
    count resd 1
    temp1 resd 1
    temp2 resd 1
    