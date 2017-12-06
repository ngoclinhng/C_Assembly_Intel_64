; lib.asm - utilities for dictionary
; =======================================================================================
section .text
global string_length
global print_char
global print_newline
global print_string
global print_error
global print_uint
global print_int
global string_equals
global parse_uint
global parse_int
global read_word
global string_copy
global exit

; string_length - returns the length of a null-terminated string
; rdi - a pointer to a null-terminated string.
; rax - the length of the string (excluding terminating character '\0')
; =====================================================================
string_length:
    xor rax, rax                ; equivalent to mov rax, 0 but less expensive
    .iterate:
    cmp byte [rdi + rax], 0
    je .end
    inc rax
    jmp .iterate
    .end
    ret

; print_char - prints the input character to stdout.
; rdi - the character to be printed
; behind the scenes: write(int fd, const void *buf, size_t nbyte)
; ===============================================================
print_char:
    push rdi
    mov rsi, rsp                ; buf
    mov rdi, 1                  ; stdout file descriptor
    mov rdx, 1                  ; nbyte
    mov rax, 0x2000004          ; write syscall number
    syscall
    pop rdi
    ret

; print_string - prints the given null-terminated string to stdout.
; rdi - the pointer to null-terminated string.
; Behind the scenes: write(int fd, const void *buf, size_t nbyte)
; =================================================================
print_string:
    push rdi
    call string_length
    pop rsi                     ; buf
    mov rdx, rax                ; nbyte
    mov rdi, 1                  ; stdout
    mov rax, 0x2000004          ; write syscall number
    syscall
    ret
    

; print_newline - prints new line character (0xA or 10) to stdout.
; behind the scenes: call print_char
; ================================================================
print_newline:
    mov rdi, 10
    jmp print_char

; print_error - prints an error message to stderr
; rdi - the pointer to error message
; Behind the scenes: write(stderr, error, nbytes)
; ===============================================
print_error:
    push rdi
    call string_length
    pop rsi                     ; error message buffer
    mov rdx, rax                ; nbyte
    mov rdi, 2                  ; stderr file descriptor
    mov rax, 0x2000004          ; write syscall number
    syscall
    ret

; print_uint - outputs the given 8-byte unsigned integer to stdout
; rdi - the 8-byte unsigned integer to be printed.
; IMPORTANT INSTRUCTION: div r8 ~ {rax = rax / r8 and dl = rax % r8}
; say rax = 123 and r8 = 10 then after the instruction div r8, we would have:
; rax = 12 and dl = 3
; dl is the smallest part (1 byte) of rdx.
; ================================================================
print_uint:
    mov rax, rdi                ; the input 8-byte unsigned integer
    
    ; allocate space on stack to store decimal digits
    ; image:
    ;           --------
    ;           xxxxxxxx
    ; rdi -->   --------
    ;           00000000 
    ;           --------
    ;           xxxxxxxx
    ;           --------
    ;           xxxxxxxx
    ; rsp -->   --------
    ; ========================
    mov rdi, rsp
    push 0
    sub rsp 16

    dec rdi
    mov r8, 10
    
    .iterate:
    xor rdx, rdx                ; the remainder of rax/r8 will be stored in rdx
    div r8                      ; rax = rax / r8 and rdx = rax % r8
    or dl, 0x30                 ; convert dl to hex
    dec rdi
    mov byte [rdi], dl
    test rax, rax   
    jnz .iterate

    call print_string           ; rdi now is pointing to a null-terminated string
    add rsp, 24                 ; restore stack states
    ret

; print_int - outputs an 8-byte signed integer to stdout
; rdi - the input 8-byte integer
; Behind the scenes: if the given number is non-negative, it calls print_uint
; otherwise, it calls print_char for negative sign, then print_uint for
; the negate.
; ===========================================================================
print_int:
    test rdi, rdi
    jns print_uint              ; if non-negative, calls print_uint
    push rdi                    ; save the number before print_char
    mov rdi, '-'                ; argument for print_char
    call print_char
    pop rid
    neg rdi
    jmp print_uint

 
; string_equals - alphabetically compares two strings, returns
; 1 if they're equal, 0 if not.
; rdi - pointer to the first null-terminated string.
; rsi - pointer to the second null-terminated string.
; @returns 1 if two strings are equal, 0 otherwise.
; ==========================================================================
string_equals:
    mov al, byte [rdi]
    cmp al, byte [rsi]
    jne .no
    inc rdi
    inc rsi
    test al, al
    jnz string_equals
    mov rax, 1
    ret
    .no:
    xor rax, rax
    ret

; parse_uint - parses an unsigned number from the start
; of the given null-terminated string and returns
; the parsed number in rax, its digits count in rdx.
; rdi - the input null-terminated string.
; @returns the parsed number in rax, its digits count in rdx.
; =========================================================================
parse_uint:
    mov r8, 10
    xor rax, rax            
    xor rcx, rcx                ; index of the next character in the input string

    .iterate:
    ; next character
    movzx r9, byte [rdi + rcx]  ; equivalent to xor r9, r9 and mov r9, byte [rdi + rcx]

    ; is it not in the range '0' - '9'?
    cmp r9b, '0'
    jb .end
    cmp r9b, '9'
    ja .end
    
    ; yes it is in the range '0' - '9'
    ; rax = rax * 10 + this-character
    xor rdx, rdx                ; ???
    mul r8                      ; rax = rax * 10
    and r9b, 0x0f        
    add rax, r9                 ; plus digit
    
    ; repeat
    inc rcx
    jmp .iterate

    .end:
    mov rdx, rcx
    ret
   
; parse_int - parses a signed integer from the start of the input
; string. Returns the number in rax, its characters count in rdx
; (including sign if any).
; No spaces between sign and digits are allowed.
; rdi - the input null-terminated string.
; ==================================================================
parse_int:
    ; examine the first character 
    mov al, byte [rdi]
    cmp al, '-'                 ; is it a negative sign?
    je .signed                  ; if yes, go to .signed
    jmp parse_uint              ; otherwise calls parse_uint

    ; so, first character is a negative sign
    .signed:
    inc rdi                     ; skip the sign character
    call parse_uint             
    neg rax
    test rdx, rdx               ; is number of digits after parse_uint zero?
    jz .error                   ; if yes, go to .error
    inc rdx                     ; otherwise, plus 1 for the sign character
    ret
    
    ; failed to parse
    .error:
    xor rax, rax
    ret

; read_word - reads at most rsi-1 bytes from stdint into buffer rdi.
; When it reaches rsi - 1 characters or encounters a whitespace
; it stops reading and appends the null character '\0' right
; after the last read character.
; rdi - the buffer address
; rsi - the buffer size
; ========================================================================
read_word:
    ; is the given buffer size valid?
    cmp rsi, 1
    jle .invalid_bufsize
    
    push r14
    push r15
    xor r14, r14                ; index of next character
    mov r15, rsi
    dec r15                     ; maximum number of characters

    ; ignore leading whitespaces
    .A:
    push rdi
    call read_char
    pop rdi
    cmp al, ' ' 
    je .A
    cmp al, 10
    je .A
    cmp al, 13
    je .A
    cmp al, 9
    je .A
    test al, al
    jmz .end

    .B:
    ; save the valid chaaracter into buffer and increment index
    ; for the next read.
    mov byte [rdi + r14], al
    inc r14

    ; read next character
    push rdi
    call read_char
    pop rdi

    ; if it is one of ht, nl, cr or ' ', stops reading
    cmp al, ' '
    je .end
    cmp al, 10
    je .end
    cmp al, 13
    je .end
    cmp al, 9
    je .end
    test al, al
    jz .end

    ; we have a valid character but do we still have enough space?
    cmp r14, r15
    je .end

    ; yes, we do have enough space for this new character
    jmp .B
 
    .end:
    mov byte [rdi + r14], 0
    mov rax, rdi
    mov rdx, r14
    pop r15
    pop r14
    ret
    
    .invalid_bufsize:
    xor rax, rax
    ret

; string_copy - copies the string from source (rdi) to the
; destination (rsi). Returns the destination address if 
; the source fits the buffer, otherwise zero is returned.
; rdi - pointer to a null-terminated string
; rsi - pointer to the buffer address.
; rdx - the buffer size.
; ==========================================================================
string_copy:
    ; first and foremost we compare the length
    ; if the input string with the given buffer size
    push rdi
    call string_length
    pop rdi
    cmp rax, rdx

    ; if the string's length is greater than or equal to
    ; buffer size, go to .error
    jge .error

    ; So, we have enough space
    push r14
    xor r14, r14

    .iterate:
    mov dl, byte [rdi + r14]            ; next character from source
    test dl, dl                         ; is it null?
    jz .end                             ; if it is null, go to .end
    mov byte [rsi + r14], dl            ; othrwise, move it to destination
    inc r14                             ; next character index
    jmp .iterate                        ; repeat

    .end:
    mov byte [rsi + r14], 0             ; append null character at the end
    mov rax, rsi                        ; return buffer address
    pop r14                             ; restore stack states
    ret

    .error:
    xor rax, rax
    ret

; exit - terminates the calling process.
; rdi - the exit status code
; ======================================
exit:
    mov rax, 0x2000001
    syscall


