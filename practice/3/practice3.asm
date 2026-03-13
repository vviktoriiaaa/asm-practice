; [memory]
section .bss
    buffer resb 12              ; Резервуємо місце для 10 цифр, '\n' та залишку

section .text
    global _start

_start:
    ; [logic]
    ; Вхідне число в діапазоні 0...999999 завантажуємо в EAX
    mov eax, 999999             

    lea edi, [buffer + 11]      ; Ставимо вказівник на кінець буфера
    mov byte [edi], 0xA         ; [I/O] Записуємо символ нового рядка (ASCII 10)
    mov ebx, 10                 ; База системи числення
    mov ecx, 1                  ; Початкова довжина рядка (тільки \n)

convert_loop:
    ; [math]
    xor edx, edx                ; Обнуляємо EDX перед діленням
    div ebx                     ; EAX / 10 -> Частка в EAX, остача в EDX
    
    ; [parse]
    add dl, '0'                 ; Перетворюємо цифру в символ '0'-'9'
    dec edi                     ; Зсуваємо вказівник вліво
    mov [edi], dl               ; Записуємо символ у буфер
    inc ecx                     ; Збільшуємо лічильник символів
    
    ; [loops]
    test eax, eax               ; Перевіряємо, чи є ще цифри
    jnz convert_loop            ; Якщо EAX не 0, продовжуємо поділ

    ; [I/O]
    ; Виклик sys_write (eax=4) для друку результату
    mov edx, ecx                ; EDX = кількість байт для запису
    mov ecx, edi                ; ECX = адреса початку рядка в буфері
    mov ebx, 1                  ; EBX = 1 (stdout)
    mov eax, 4                  ; EAX = 4 (sys_write)
    int 0x80                    ; Виклик ядра

exit:
    ; [logic]
    mov eax, 1                  ; sys_exit
    xor ebx, ebx                ; код повернення 0
    int 0x80