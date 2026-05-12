; practice14.asm - Selection Sort & Median Logic
; blocks: I/O, parse, loops, math, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_n      db "Enter count (10-100): ", 0
    msg_v      db "Value: ", 0
    msg_raw    db "Raw array:", 10, 0
    msg_sort   db 10, "Sorted array:", 10, 0
    msg_med    db 10, "Median value: ", 0
    space      db " ", 0
    newline    db 10

SECTION .bss
    n_count    resd 1
    array      resd 100
    idx_i      resd 1
    idx_j      resd 1
    idx_min    resd 1
    in_buf     resb 64
    out_buf    resb 16

SECTION .text
_start:
; ---------------- I/O (Input N) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 22
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 60
    int 0x80
    
    ; parse N
    xor eax, eax
    mov esi, in_buf
.p_n:
    movzx edx, byte [esi]
    cmp dl, 10
    je .p_n_done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .p_n
.p_n_done:
    mov [n_count], eax

; ---------------- loops (Input array) ----------------
    mov dword [idx_i], 0
fill_loop:
    mov eax, [idx_i]
    cmp eax, [n_count]
    jae print_raw

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_v
    mov edx, 7
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 60
    int 0x80
    
    ; parse Value
    xor eax, eax
    mov esi, in_buf
.p_v:
    movzx edx, byte [esi]
    cmp dl, 10
    je .p_v_done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .p_v
.p_v_done:
    mov ebx, [idx_i]
    mov [array + ebx*4], eax
    inc dword [idx_i]
    jmp fill_loop

print_raw:
; ---------------- I/O (Show original) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_raw
    mov edx, 11
    int 0x80
    
    mov dword [idx_i], 0
.show_raw_loop:
    mov eax, [idx_i]
    cmp eax, [n_count]
    jae start_sort
    mov eax, [array + eax*4]
    call write_number
    inc dword [idx_i]
    jmp .show_raw_loop

; ---------------- logic (Selection Sort) ----------------
start_sort:
    mov dword [idx_i], 0
outer_loop:
    mov eax, [n_count]
    dec eax
    cmp [idx_i], eax
    jae print_sorted

    mov eax, [idx_i]
    mov [idx_min], eax
    
    inc eax
    mov [idx_j], eax

inner_loop:
    mov eax, [idx_j]
    cmp eax, [n_count]
    jae swap_elements

    mov ebx, [idx_min]
    mov ecx, [array + eax*4] ; array[j]
    mov edx, [array + ebx*4] ; array[min]
    cmp ecx, edx
    jge next_j
    mov [idx_min], eax
next_j:
    inc dword [idx_j]
    jmp inner_loop

swap_elements:
    mov eax, [idx_i]
    mov ebx, [idx_min]
    mov ecx, [array + eax*4]
    mov edx, [array + ebx*4]
    mov [array + eax*4], edx
    mov [array + ebx*4], ecx
    
    inc dword [idx_i]
    jmp outer_loop

print_sorted:
; ---------------- I/O (Show sorted) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_sort
    mov edx, 15
    int 0x80
    
    mov dword [idx_i], 0
.show_sort_loop:
    mov eax, [idx_i]
    cmp eax, [n_count]
    jae print_median
    mov eax, [array + eax*4]
    call write_number
    inc dword [idx_i]
    jmp .show_sort_loop

print_median:
; ---------------- math (Median) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_med
    mov edx, 14
    int 0x80

    mov eax, [n_count]
    dec eax
    shr eax, 1              ; (n-1) / 2
    mov eax, [array + eax*4]
    call write_number

; ---------------- memory (Exit) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Subroutine: write_number ---
write_number:
    pushad
    mov ebx, 10
    xor ecx, ecx
    test eax, eax
    jnz .div_loop
    push 0
    inc ecx
    jmp .disp_loop
.div_loop:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .div_loop
.disp_loop:
    pop edx
    add dl, '0'
    mov [out_buf], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, out_buf
    mov edx, 1
    int 0x80
    pop ecx
    loop .disp_loop
    
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    popad
    ret