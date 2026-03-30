BITS 32
GLOBAL _start

SECTION .data
    prompt1 db "Enter first number: ", 0
    prompt1_len equ $ - prompt1
    prompt2 db "Enter second number: ", 0
    prompt2_len equ $ - prompt2
    
    msg_signed_less    db "Signed: A < B", 10, 0
    msg_signed_more    db "Signed: A > B", 10, 0
    msg_unsigned_less  db "Unsigned: A < B", 10, 0
    msg_unsigned_more  db "Unsigned: A > B", 10, 0
    msg_equal          db "Numbers are equal", 10, 0

SECTION .bss
    buf resb 16
    num1 resd 1
    num2 resd 1

SECTION .text
_start:
    ; --- Ввід першого числа ---
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt1
    mov edx, prompt1_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 16
    int 0x80
    call str_to_int
    mov [num1], eax

    ; --- Ввід другого числа ---
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt2
    mov edx, prompt2_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 16
    int 0x80
    call str_to_int
    mov [num2], eax

    ; --- ПОРІВНЯННЯ ---
    mov eax, [num1]
    mov ebx, [num2]
    cmp eax, ebx
    je .equal

    ; 1. Signed comparison (JL/JG)
    jl .s_less
    mov ecx, msg_signed_more
    mov edx, 14
    jmp .print_signed
.s_less:
    mov ecx, msg_signed_less
    mov edx, 14
.print_signed:
    push ebx ; зберігаємо ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx  ; відновлюємо ebx

    ; 2. Unsigned comparison (JB/JA)
    mov eax, [num1] ; знову завантажуємо
    cmp eax, ebx
    jb .u_less
    mov ecx, msg_unsigned_more
    mov edx, 16
    jmp .print_unsigned
.u_less:
    mov ecx, msg_unsigned_less
    mov edx, 16
.print_unsigned:
    mov eax, 4
    mov ebx, 1
    int 0x80
    jmp .exit

.equal:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_equal
    mov edx, 18
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Функція конвертації рядка в число (проста) ---
str_to_int:
    xor eax, eax
    xor edx, edx
    mov esi, ecx
.loop:
    mov dl, [esi]
    cmp dl, 10 ; перевірка на Enter
    je .done
    cmp dl, '0'
    jb .done
    cmp dl, '9'
    ja .done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .loop
.done:
    ret