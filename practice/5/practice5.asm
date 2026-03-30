; ПРАКТИЧНА РОБОТА 5: Обчислення суми цифр (Unsigned)
; Виконано: vviktoriiaaa
; ОС: Debian Linux (i386)

section .data
    lbl_sum  db "Digit Sum: ", 0
    sz_sum   equ $ - lbl_sum
    lbl_len  db "Digits Count: ", 0
    sz_len   equ $ - lbl_len
    endl     db 0xA

section .bss
    in_data  resb 32    ; Буфер для вводу числа
    out_data resb 32    ; Буфер для перетворення числа в рядок
    v_num    resd 1     ; Число x
    v_sum    resd 1     ; Результат суми
    v_len    resd 1     ; Результат довжини

section .text
    global _start

_start:
    ; --- I/O: Зчитування числа з клавіатури ---
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, in_data
    mov edx, 32
    int 0x80

    ; --- parse: Конвертація рядка в число (atoi) ---
    lea esi, [in_data]
    xor eax, eax
    xor ebx, ebx
.loop_parse:
    movzx ebx, byte [esi]
    cmp bl, 10          ; Перевірка на '\n'
    je .done_parse
    cmp bl, '0'
    jb .done_parse
    cmp bl, '9'
    ja .done_parse
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .loop_parse
.done_parse:
    mov [v_num], eax

    ; --- math: Основна логіка (цикл ділення) ---
    xor ecx, ecx        ; Лічильник довжини
    xor ebx, ebx        ; Акумулятор суми
    mov eax, [v_num]
    mov edi, 10         ; Константа для ділення

.math_cycle:
    test eax, eax
    jz .math_end
    xor edx, edx        ; ВАЖЛИВО: обнуляємо залишок перед div
    div edi             ; EDX:EAX / 10 -> EAX (частка), EDX (залишок)
    add ebx, edx        ; Додаємо цифру до суми
    inc ecx             ; Рахуємо кількість цифр
    jmp .math_cycle

.math_end:
    mov [v_sum], ebx
    mov [v_len], ecx

    ; --- logic: Вивід результатів ---
    ; 1. Вивід "Digit Sum: "
    push lbl_sum
    push sz_sum
    call sys_out_str

    mov eax, [v_sum]
    call sys_out_num

    ; 2. Вивід "Digits Count: "
    push lbl_len
    push sz_len
    call sys_out_str

    mov eax, [v_len]
    call sys_out_num

    ; --- sys_exit ---
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- memory/logic: Підпрограма itoa (число -> рядок) ---
sys_out_num:
    lea edi, [out_data + 31]
    mov byte [edi], 0xA ; Додаємо перенос рядка
    mov ebx, 10
.itoa_loop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .itoa_loop

    lea ecx, [edi]
    lea edx, [out_data + 32]
    sub edx, ecx
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    ret

; --- I/O підпрограма ---
sys_out_str:
    pop ebp             ; Адреса повернення
    pop edx             ; Довжина рядка
    pop ecx             ; Адреса рядка
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    push ebp
    ret