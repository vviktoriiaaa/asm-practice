; practice8.asm - Linear search & occurrence counting
; I/O: sys_read/sys_write via int 0x80
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    none_msg   db "-1", 10, 0
    spacer     db " ", 0
    end_line   db 10

SECTION .bss
    in_buffer  resb 1024    ; буфер для вводу даних
    data_arr   resd 100     ; основне сховище чисел
    idx_arr    resd 100     ; масив для збереження знайдених позицій
    num_count  resd 1
    find_val   resd 1
    found_hits resd 1
    idx_first  resd 1
    str_conv   resb 16
    scan_ptr   resd 1       ; вказівник на поточну позицію в буфері

SECTION .text
_start:

; ---------------- I/O (Reading input stream) ----------------
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, in_buffer
    mov edx, 1024
    int 0x80

    mov dword [scan_ptr], in_buffer

; ---------------- parse (Header: size n) ----------------
    call get_next_int
    mov [num_count], eax

; ---------------- loops (Populate data array) ----------------
    xor ecx, ecx
read_data_loop:
    push ecx
    call get_next_int
    pop ecx
    mov [data_arr + ecx*4], eax
    inc ecx
    cmp ecx, [num_count]
    jl read_data_loop

; ---------------- parse (Target value) ----------------
    call get_next_int
    mov [find_val], eax

; ---------------- logic (Linear search execution) ----------------
    mov dword [idx_first], -1
    mov dword [found_hits], 0
    xor esi, esi        ; i = 0
    xor edi, edi        ; counter for idx_arr

process_search:
    mov eax, [data_arr + esi*4]
    cmp eax, [find_val]
    jne no_match_found

    ; logic: match identified
    inc dword [found_hits]
    mov [idx_arr + edi*4], esi
    inc edi

    ; logic: track first occurrence
    cmp dword [idx_first], -1
    jne no_match_found
    mov [idx_first], esi

no_match_found:
    inc esi
    cmp esi, [num_count]
    jl process_search

; ---------------- I/O (Result: First index) ----------------
    mov eax, [idx_first]
    cmp eax, -1
    jne display_f_idx

    mov eax, 4
    mov ebx, 1
    mov ecx, none_msg
    mov edx, 3
    int 0x80
    jmp skip_f_idx

display_f_idx:
    call write_int
    call write_nl

skip_f_idx:

; ---------------- I/O (Result: Count) ----------------
    mov eax, [found_hits]
    call write_int
    call write_nl

; ---------------- loops (Result: All indices) ----------------
    xor esi, esi
list_indices:
    cmp esi, [found_hits]
    jge finish_all

    push esi
    mov eax, [idx_arr + esi*4]
    call write_int

    ; check: space padding
    pop esi
    mov eax, esi
    inc eax
    cmp eax, [found_hits]
    jge no_extra_space

    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, spacer
    mov edx, 1
    int 0x80
    pop esi

no_extra_space:
    inc esi
    jmp list_indices

finish_all:
    call write_nl

; ---------------- memory (Shutdown) ----------------
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ---------------- parse (Numeric extraction) ----------------
get_next_int:
    push ebx
    push esi
    mov esi, [scan_ptr]
    xor eax, eax
    xor ebx, ebx

.find_digit:
    mov bl, [esi]
    test bl, bl
    jz .exit_parse
    cmp bl, '0'
    jb .skip_char
    cmp bl, '9'
    jbe .start_calc
.skip_char:
    inc esi
    jmp .find_digit

.start_calc:
.calc_loop:
    mov bl, [esi]
    cmp bl, '0'
    jb .exit_parse
    cmp bl, '9'
    ja .exit_parse
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .calc_loop

.exit_parse:
    mov [scan_ptr], esi
    pop esi
    pop ebx
    ret

; ---------------- I/O (Write integer to screen) ----------------
write_int:
    pushad
    mov ecx, str_conv + 15
    mov byte [ecx], 0
    mov ebx, 10

    test eax, eax
    jnz .convert_step
    dec ecx
    mov byte [ecx], '0'
    jmp .send_to_stdout

.convert_step:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz .convert_step

.send_to_stdout:
    mov edx, str_conv + 15
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    popad
    ret

; ---------------- I/O (Line feed utility) ----------------
write_nl:
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, end_line
    mov edx, 1
    int 0x80
    pop eax
    ret