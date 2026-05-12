; practice15.asm - Recursive Factorial and Call Counter
; blocks: I/O, parse, math, logic, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_input  db "Enter n (0-12): ", 0
    msg_res    db "Factorial: ", 0
    msg_calls  db 10, "Total calls: ", 0
    msg_nl     db 10

SECTION .bss
    n_number   resd 1
    call_sum   resd 1
    in_buffer  resb 64
    out_char   resb 16

SECTION .text
_start:
; ---------------- I/O (Read N) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, 17
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, in_buffer
    mov edx, 60
    int 0x80

; ---------------- parse (String to Int) ----------------
    xor eax, eax
    mov esi, in_buffer
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
    mov [n_number], eax
    mov dword [call_sum], 0

; ---------------- math (Recursion) ----------------
    mov eax, [n_number]
    call factorial_proc
    push eax            ; Зберігаємо результат

; ---------------- I/O (Show Results) ----------------
    ; Результат факторіала
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_res
    mov edx, 11
    int 0x80
    pop eax
    call write_val

    ; Кількість викликів
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_calls
    mov edx, 13
    int 0x80
    mov eax, [call_sum]
    call write_val

; ---------------- memory (Exit) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_nl
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

; ---------------- logic (Recursive Function) ----------------
factorial_proc:
    inc dword [call_sum] ; Лічильник calls++
    
    ; Пролог
    push ebp
    mov ebp, esp

    cmp eax, 1
    jbe .base

    push eax            ; Зберігаємо n
    dec eax
    call factorial_proc ; fact(n-1)
    pop ebx             ; Дістаємо n
    mul ebx             ; eax = eax * ebx
    jmp .exit

.base:
    mov eax, 1          ; fact(0) = 1, fact(1) = 1

.exit:
    ; Епілог
    mov esp, ebp
    pop ebp
    ret

; --- Підпрограма виводу (Стабільна) ---
write_val:
    pushad
    mov ebx, 10
    xor ecx, ecx
    test eax, eax
    jnz .div_l
    push 0
    inc ecx
    jmp .pr_l
.div_l:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .div_l
.pr_l:
    pop edx
    add dl, '0'
    mov [out_char], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, out_char
    mov edx, 1
    int 0x80
    pop ecx
    loop .pr_l
    popad
    ret