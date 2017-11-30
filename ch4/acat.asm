; acat.asm - a clone of UNIX cat command
; Compile: make
; Usage: ./acat <filename>
; =======================================================================================

%define MAXBUF  1024            ; Max I/O buffer

section .data
file_not_found: db  'file not found', 0

section .text
global start

; HELPER ROUTINES
; ===============
;
; read_char - reads a single character (1 byte) from stdin
; and returns it.
; =======================================================================================
read_char:
    push 0                      ; Allocate 8 bytes on the stack
                                ; for new character
    mov rsi, rsp                ; 2nd argument of the read system call
                                ; which is the buffer to store the new character
    mov rax, 0x2000003          ; read syscall identifier
    mov rdi, 0                  ; stdin
    mov rdx, 1                  ; how many bytes to read?
    syscall
    pop rax                     ; Returns that character
    ret

; read_word - takes as inputs a buffer address and a size, and
; reads next word from stdin(skipping whitespaces). Stops and returns
; if the word is too big compared to the given size, otherwise returns
; the buffer address.
; the buffer size must be greater than 1 since we need to reserve one byte
; for the null-character at the end of the word.
; ======================================================================================
read_word:
    ; First of all, we need to save callee-saved registers that
    ; we're about to change.
    push r14
    push r15

    ; r14 serves as index into buffer, whereas r15 as buffer size
    ; so, wee need to zero out r14 and copy rsi into r15
    xor r14, r14
    mov r15, rsi

    ; If buffer size is less than or equal to 1, return 0
    cmp r15, 1
    jle .D

    ; else
    dec r15

    ; Read first char, ignore all leading whitespaces
    .A:
    push rdi                    ; Save buffer address
    call read_char
    pop rdi                     ; Restore buffer address

    ; At this point the newly read character is stored in register rax
    ; if it is whitespace, go back to .A and try again.
    ; To figure out all kinds of whitespaces, use man ascii and look
    ; at the decimal set.
    cmp al, ' '
    je .A
    cmp al, 9
    je .A
    cmp al, 10
    je .A
    cmp al, 13
    je .A

    ; Not a whitespace but a null-character?
    test al, al
    jz .C

    ; None of the above?
    .B:
    mov byte [rdi + r14], al                ; Save the newly read character into buffer
    inc r14                                 ; next char index

    push rdi                                ; save buffer address
    call read_char                          ; next char
    pop rdi                                 ; restore buffer address

    ; If next char is either whitespace or null
    ; go to .C
    cmp al, ' '
    je .C
    cmp al, 9
    je .C
    cmp al, 10
    je .C
    cmp al, 13
    je .C
    test al, al
    jz .C

    ; else if char index is the last index into buffer
    cmp r14, r15
    je .D

    ; else, go to .B
    jmp .B

    .C:
    mov byte [rdi + r14], 0                 ; Append null character at the end of word
    mov rax, rdi                            ; store buffer address into rax
                                            ; to be returned.
    mov rdx, r14                            ; second return value must be stored
                                            ; in rdx
    pop r15                                 ; Restore callee-saveds
    pop r14
    ret

    ; the word is too big compared to the given buffer size
    ; so, return 0.
    .D:
    xor rax, rax                            ; return value
    pop r15                                 ; restore callee-saveds
    pop r14     
    ret

; strlen - given a pointer to a null-terminated string,
; returns its length.
; ========================================================================================
strlen:
    xor rax, rax

    ; loop
    .iterate:
    cmp byte [rdi + rax], 0
    je .end
    inc rax
    jmp .iterate

    ; end
    .end:
    ret

; print_string - output null-terminated string to stdout
; rdi - pointer to null-terminated string
; ========================================================================================
print_string:
    mov rsi, rdi                            ; buffer 
    call strlen
    mov rdx, rax                            ; #bytes to be written
    mov rax, 0x2000004                      ; write syscall
    mov rdi, 1                              ; stdout
    syscall
    ret

; main
; ========================================================================================
start:
    ; TODO: argc, argv, open, stat, write file size and content
    
    .end:
    pop rdi                                 ; restore stack state
    xor rdi, rdi                            ; exit status code
    mov rax, 0x2000001                      ; exit syscall
    syscall
    
