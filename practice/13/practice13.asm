BITS 32
GLOBAL _start

SECTION .data
    msg_n    db "Count (5-200): ", 0
    msg_v    db "Val: ", 0
    msg_a    db "Array: ", 0
    msg_r    db 10, "Reverse: ", 0
    msg_p    db 10, "Palindrome? ", 0
    txt_y    db "YES", 10, 0
    txt_n    db "NO", 10, 0
    gap      db " ", 0

SECTION .bss
    n_val    resd 1
    arr1     resd 210
    arr2     resd 210
    buf      resb 64
    tmp      resb 16
    idx      resd 1

SECTION .text
_start:
    ; --- 1. Читаємо N ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 15
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 60
    int 0x80

    xor eax, eax
    mov esi, buf
.parse_n:
    movzx edx, byte [esi]
    cmp dl, 10
    je .done_n
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .parse_n
.done_n:
    mov [n_val], eax

    ; --- 2. Заповнюємо масив ---
    mov dword [idx], 0
.fill:
    mov eax, [idx]
    cmp eax, [n_val]
    jae .do_rev

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_v
    mov edx, 5
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 60
    int 0x80

    xor eax, eax
    mov esi, buf
.parse_v:
    movzx edx, byte [esi]
    cmp dl, 10
    je .done_v
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .parse_v
.done_v:
    mov ebx, [idx]
    mov [arr1 + ebx*4], eax
    inc dword [idx]
    jmp .fill

.do_rev:
    ; --- 3. Робимо Реверс ---
    mov ecx, [n_val]
    xor esi, esi
.rev_loop:
    mov eax, [arr1 + esi*4]
    mov edx, [n_val]
    dec edx
    sub edx, esi
    mov [arr2 + edx*4], eax
    inc esi
    loop .rev_loop

    ; --- 4. Вивід Оригіналу ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_a
    mov edx, 7
    int 0x80
    mov dword [idx], 0
.out1:
    mov eax, [idx]
    cmp eax, [n_val]
    jae .out2_msg
    mov eax, [arr1 + eax*4]
    ; Друк числа без call
    mov ebx, 10
    xor ecx, ecx
.d1:xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .d1
.s1:pop edx
    add dl, '0'
    mov [tmp], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp
    mov edx, 1
    int 0x80
    pop ecx
    loop .s1
    mov eax, 4
    mov ebx, 1
    mov ecx, gap
    mov edx, 1
    int 0x80
    inc dword [idx]
    jmp .out1

.out2_msg:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_r
    mov edx, 10
    int 0x80
    mov dword [idx], 0
.out2:
    mov eax, [idx]
    cmp eax, [n_val]
    jae .pal
    mov eax, [arr2 + eax*4]
    mov ebx, 10
    xor ecx, ecx
.d2:xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .d2
.s2:pop edx
    add dl, '0'
    mov [tmp], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp
    mov edx, 1
    int 0x80
    pop ecx
    loop .s2
    mov eax, 4
    mov ebx, 1
    mov ecx, gap
    mov edx, 1
    int 0x80
    inc dword [idx]
    jmp .out2

.pal:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_p
    mov edx, 13
    int 0x80
    xor esi, esi
    mov ecx, [n_val]
.c_p:
    mov eax, [arr1 + esi*4]
    mov ebx, [arr2 + esi*4]
    cmp eax, ebx
    jne .no
    inc esi
    loop .c_p
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_y
    mov edx, 4
    int 0x80
    jmp .end
.no:
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_n
    mov edx, 3
    int 0x80

.end:
    mov eax, 1
    xor ebx, ebx
    int 0x80