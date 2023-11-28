[org 0x7c00]

section .bss
    buffer resb 256

section .text
global main

main:
    mov ax, 0
    mov ds, ax  ; data segment
    mov es, ax  ; extra segment
    mov ss, ax  ; stack segment
    call input_string
    call write_string
    jmp main

; procedures ;

input_string:
    call print_prompt
    mov ecx, 0          ; clear ecx
    mov bx, buffer      ; load buffer into bx
    input_loop:
        ; read character input
        mov ah, 0
        int 16h

        cmp al, 0x08    ; if backspace pressed
        je backspace

        cmp al, 0x0d    ; if 'enter' pressed  
        je exit_input   ; exit procedure

        cmp ecx, 256    ; if character count is 256
        je input_loop   ; restart input

        ; display the read character
        mov ah, 0eh     ; tty output
        int 10h         ; al already contains the input

        mov [bx], al    ; store al character into buffer
        inc bx          ; increment buffer index
        inc ecx         ; increment character count
        jmp input_loop

    backspace:
        cmp bx, buffer  ; if buffer index is 0
        je input_loop  ; restart input

        push ecx        ; save character count
        push bx         ; save buffer index

        mov ah, 03h     ; get cursor position
        mov bh, 0       ; page number
        int 10h

        cmp dl, 0       ; if column is 0
        jne not_first_column
        mov dl, 80      ; set column to 79
        dec dh          ; decrement row
        not_first_column:

        mov ah, 02h     ; set cursor position
        dec dl          ; decrement column
        int 10h

        mov ah, 0ah     ; write character at cursor
        mov al, ' '     ; space
        mov cx, 1       ; one character
        int 10h

        pop bx         ; restore buffer index
        pop ecx        ; restore character count

        mov al, 0
        dec bx          ; decrement buffer index
        dec ecx         ; decrement character count
        mov [bx], al    ; set buffer index to null byte
        jmp input_loop

    exit_input:
        call new_line
    ret

write_string:
    cmp bx, buffer  ; if buffer is empty
    je no_string    ; exit procedure

    mov ah, 0x0e    ; prepare tty output
    mov bx, buffer  ; load buffer into bx

    write_loop:
        mov al, [bx]    ; load charcter from buffer
        
        cmp al, 0       ; if null byte exit
        je write_end

        int 10h         ; print character
        inc bx          ; increment buffer index
        jmp write_loop

    write_end:
        call clear_buffer
        call new_line
    no_string:
    ret

new_line:
    mov ah, 0eh     ; tty output
    mov al, 0x0a    ; new line
    int 0x10
    mov al, 0x0d    ; 'enter' key
    int 10h
    ret

print_prompt:
    mov ah, 0x0e    ; tty output
    mov al, '>'     ; character to print
    int 0x10        ; print it
    ret

clear_buffer:
    mov ecx, 0      ; clear counter
    mov bx, buffer  ; load buffer into bx
    mov al, 0       ; set al to null byte
    clear_start:
        mov [bx], al    ; set buffer index to null byte
        inc bx          ; increment buffer index
        inc ecx         ; increment counter
        cmp ecx, 256    ; if counter is 256
        jne clear_start ; restart loop
    ret

; makes 512 bytes and signals that
; this is boot sector
times 510-($-$$) db 0
db 0x55, 0xaa