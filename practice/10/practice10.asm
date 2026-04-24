BITS 32
GLOBAL _start

SECTION .data
    msg_input  db "Enter number: ", 0
    msg_bin    db "Binary: ", 0
    msg_pop    db 10, "Popcount: ", 0
    msg_mod    db 10, "Modified (set 0,4 clear 7): ", 0
    msg_nl     db 10
    space      db " ", 0

SECTION .bss
    in_raw     resb 32
    x_val      resd 1
    tmp_char   resb 2

SECTION .text
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, 14
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, in_raw
    mov edx, 30
    int 0x80

    xor eax, eax
    mov esi, in_raw
.p_loop:
    movzx edx, byte [esi]
    cmp dl, 10
    je .p_end
    cmp dl, '0'
    jb .p_end
    cmp dl, '9'
    ja .p_end
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .p_loop
.p_end:
    mov [x_val], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bin
    mov edx, 8
    int 0x80

    mov ebp, [x_val]
    mov esi, 32
.bin_loop:
    rol ebp, 1
    mov byte [tmp_char], '0'
    jnc .print_now
    mov byte [tmp_char], '1'
.print_now:
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_char
    mov edx, 1
    int 0x80
    dec esi
    jz .bin_done
    mov eax, esi
    test eax, 3
    jnz .bin_loop
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    jmp .bin_loop
.bin_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pop
    mov edx, 11
    int 0x80
    mov eax, [x_val]
    xor edi, edi
.pop_loop:
    test eax, eax
    jz .pop_show
    shr eax, 1
    adc edi, 0
    jmp .pop_loop
.pop_show:
    mov eax, edi
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_mod
    mov edx, 29
    int 0x80
    mov eax, [x_val]
    or eax, 17
    and eax, 0xFFFFFF7F
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_nl
    mov edx, 1
    int 0x80
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
    pushad
    mov ebx, 10
    xor ecx, ecx
.c1:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .c1
.c2:
    pop edx
    add dl, '0'
    mov [tmp_char], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_char
    mov edx, 1
    int 0x80
    pop ecx
    loop .c2
    popad
    ret