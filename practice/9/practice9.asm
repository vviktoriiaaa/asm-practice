; practice9.asm - LCG Random Generator & Histogram
; I/O: sys_read/sys_write (int 80h)
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_input  db "Enter n (100-1000): ", 0
    in_len     equ $ - msg_input
    msg_sep    db ": ", 0
    char_bar   db "#", 0
    char_nl    db 10
    ; LCG constants
    l_a        dd 1103515245
    l_c        dd 12345
    l_m        dd 0x7FFFFFFF

SECTION .bss
    raw_in     resb 16
    freq_map   resd 10      ; Масив частот для цифр 0-9
    n_val      resd 1
    current_x  resd 1
    out_buf    resb 32

SECTION .text
_start:

; ---------------- I/O (Request N) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, in_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, raw_in
    mov edx, 16
    int 0x80

; ---------------- parse (String to Int) ----------------
    call parse_int
    mov [n_val], eax
    
    ; Початкове значення (seed)
    mov dword [current_x], 123456789

; ---------------- loops (Generation) ----------------
    mov ecx, [n_val]
generate_data:
    push ecx
    
    ; math: LCG algorithm x = (a*x + c) % m
    mov eax, [current_x]
    mul dword [l_a]
    add eax, [l_c]
    and eax, 0x7FFFFFFF
    mov [current_x], eax
    
    ; logic: Get index (0-9)
    xor edx, edx
    mov ebx, 10
    div ebx             ; залишок у edx (0..9)
    
    ; Оновлення частоти
    inc dword [freq_map + edx*4]
    
    pop ecx
    loop generate_data

; ---------------- loops (Outer: Rows 0-9) ----------------
    xor esi, esi        ; i = 0
draw_rows:
    cmp esi, 10
    jge program_done

    ; Вивід префікса "i: "
    mov eax, esi
    add al, '0'
    mov [out_buf], al
    mov eax, 4
    mov ebx, 1
    mov ecx, out_buf
    mov edx, 1
    int 0x80
    
    mov eax, 4
    mov ecx, msg_sep
    mov edx, 2
    int 0x80

; ---------------- loops (Inner: Bar drawing) ----------------
    mov edi, [freq_map + esi*4]
draw_bar:
    test edi, edi
    jz row_finished
    
    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, char_bar
    mov edx, 1
    int 0x80
    pop esi
    
    dec edi
    jmp draw_bar

row_finished:
    mov eax, 4
    mov ebx, 1
    mov ecx, char_nl
    mov edx, 1
    int 0x80
    
    inc esi
    jmp draw_rows

; ---------------- memory (Exit) ----------------
program_done:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Subroutines ---

parse_int:
    xor eax, eax
    mov ebx, raw_in
.next_digit:
    movzx edx, byte [ebx]
    cmp dl, '0'
    jb .done
    cmp dl, '9'
    ja .done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc ebx
    jmp .next_digit
.done:
    ret