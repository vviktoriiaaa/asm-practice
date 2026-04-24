; practice12.asm - Substring search (Fixed & Stable)
; I/O: sys_read/sys_write (int 80h)
; blocks: I/O, parse, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_text   db "Enter text: ", 0
    msg_pat    db "Enter pattern: ", 0
    msg_first  db "First position: ", 0
    msg_count  db 10, "Total count: ", 0
    msg_nl     db 10
    
    first_pos  dd -1
    match_cnt  dd 0

SECTION .bss
    text_buf   resb 256
    pat_buf    resb 64
    text_len   resd 1
    pat_len    resd 1
    tmp_char   resb 16

SECTION .text
_start:

; ---------------- I/O (Input Data) ----------------
    ; Читаємо основний текст
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_text
    mov edx, 12
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, text_buf
    mov edx, 255
    int 0x80
    
    mov edi, text_buf
    call sanitize
    mov [text_len], eax

    ; Читаємо патерн (що шукаємо)
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pat
    mov edx, 15
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pat_buf
    mov edx, 63
    int 0x80
    
    mov edi, pat_buf
    call sanitize
    mov [pat_len], eax

; ---------------- logic (Validation) ----------------
    mov eax, [pat_len]
    test eax, eax
    jz print_results    ; якщо патерн порожній - виходимо
    
    mov ebx, [text_len]
    cmp eax, ebx
    jg print_results    ; якщо патерн довше тексту - нічого не знайдемо

; ---------------- loops (Search Engine) ----------------
    xor esi, esi        ; i = 0 (зовнішній цикл)
.outer:
    mov eax, esi
    add eax, [pat_len]
    cmp eax, [text_len] ; перевірка, чи не вийшли ми за межі тексту
    jg print_results

    ; Вкладений цикл перевірки
    xor ecx, ecx        ; j = 0
.inner:
    mov edx, [pat_len]
    cmp ecx, edx
    je .found           ; якщо j == pat_len, значить знайшли!

    mov al, [text_buf + esi + ecx]
    mov bl, [pat_buf + ecx]
    cmp al, bl
    jne .next_iter      ; якщо символи не рівні - на наступну спробу

    inc ecx
    jmp .inner

.found:
    ; Записуємо першу позицію, якщо ще не записали
    cmp dword [first_pos], -1
    jne .inc_only
    mov [first_pos], esi

.inc_only:
    inc dword [match_cnt]
    add esi, [pat_len]  ; Стрибаємо вперед (без перекриття)
    jmp .outer

.next_iter:
    inc esi
    jmp .outer

; ---------------- I/O (Output Results) ----------------
print_results:
    ; Друк першої позиції
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_first
    mov edx, 16
    int 0x80
    mov eax, [first_pos]
    call print_val

    ; Друк кількості
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, 14
    int 0x80
    mov eax, [match_cnt]
    call print_val

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_nl
    mov edx, 1
    int 0x80

; ---------------- memory (Exit) ----------------
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Підпрограми ---

sanitize:
    ; Очищує буфер від '\n' та повертає довжину в EAX
    xor ecx, ecx
.s_loop:
    cmp byte [edi + ecx], 10 ; Шукаємо Enter
    je .s_end
    cmp byte [edi + ecx], 0
    je .s_end
    inc ecx
    cmp ecx, 255
    jne .s_loop
.s_end:
    mov byte [edi + ecx], 0 ; Ставимо нуль-термінатор
    mov eax, ecx
    ret

print_val:
    ; Вивід числа (обробка -1 окремо)
    cmp eax, -1
    jne .pos
    push eax
    mov byte [tmp_char], '-'
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_char
    mov edx, 1
    int 0x80
    pop eax
    mov eax, 1
.pos:
    mov ebx, 10
    xor ecx, ecx
.c1: xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .c1
.c2: pop edx
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
    ret