; practice11.asm - Christmas Tree (Nested Loops & Buffering)
; I/O: sys_read/sys_write (int 80h)
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_prompt db "Enter height (5-25): ", 0
    prompt_len equ $ - msg_prompt
    char_star  equ '*'
    char_space equ ' '
    char_nl    equ 10

SECTION .bss
    in_buf     resb 10
    line_buf   resb 128     ; Буфер для формування рядка
    h_val      resd 1

SECTION .text
_start:

; ---------------- I/O (Read height) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 10
    int 0x80

; ---------------- parse (String to Int) ----------------
    xor eax, eax
    mov esi, in_buf
.p_loop:
    movzx edx, byte [esi]
    cmp dl, 10
    je .p_done
    cmp dl, '0'
    jb .p_done
    cmp dl, '9'
    ja .p_done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .p_loop
.p_done:
    mov [h_val], eax

; ---------------- loops (Outer: Rows) ----------------
    mov esi, 1          ; Поточний рівень (від 1 до h)
draw_tree:
    mov eax, [h_val]
    cmp esi, eax
    jg program_exit

    ; Очищення/підготовка буфера
    mov edi, line_buf   ; EDI вказує на початок буфера рядка

; ---------------- math & logic (Spaces) ----------------
    ; Кількість пробілів = h - esi
    mov ecx, [h_val]
    sub ecx, esi
    jz .stars_start     ; якщо пробілів 0, переходимо до зірочок
.space_loop:
    mov byte [edi], char_space
    inc edi
    loop .space_loop

; ---------------- math & logic (Stars) ----------------
.stars_start:
    ; Кількість зірочок = 2 * esi - 1
    mov eax, esi
    lea ecx, [eax*2 - 1]
.star_loop:
    mov byte [edi], char_star
    inc edi
    loop .star_loop

; ---------------- logic (Finalizing Line) ----------------
    mov byte [edi], char_nl
    inc edi
    
    ; Розрахунок довжини рядка для виводу
    mov edx, edi
    sub edx, line_buf   ; довжина = поточний EDI - початок буфера
    mov ecx, line_buf
    call print_line

    inc esi             ; наступний рядок
    jmp draw_tree

; ---------------- memory (Exit) ----------------
program_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Subroutine: print_line ---
; Вхід: ECX = адреса буфера, EDX = довжина
print_line:
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    pop eax
    ret