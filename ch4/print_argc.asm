; print_argc - outputs value of argc to stdout.
; =======================================================================================
global start

section .data
newline_char:   db  10
section .text
; helper functions
; =======================================================================================
; strlen
; Takes as input a pointer to a null-terminated string and outputs
; its length.
strlen:
    ; The returned length will be stored in rax, so first of all
    ; we need to zero out rax
    xor rax, rax
.iterate:
    cmp byte [rdi + rax], 0                 ; Compare the current character
                                            ; with null character(i.e 0)
    je .end                                 ; go to .end if equal
    inc rax                                 ; otherwise, increment rax by 1
    jmp .iterate                            ; and move on to next iteration
.end:
    ret                                     ; returned value will be in rax.

; print_string
; Takes as input a pointer to a null-terminated string and outouts
; its content to stdout.
print_string:
    mov rsi, rdi                            ; char *
    call strlen
    mov rdx, rax                            ; length in bytes
    mov rax, 0x2000004                      ; syscall write
    mov rdi, 1                              ; stdout
    syscall 
    ret

; print_uint
; Takes as input an unsigned 8-byte integer and outputs
; it to stdout in decimal format
print_uint:
    ; The idea is that we employ the instruction
    ; div r8. What this instruction does is that
    ; it performs rax/r8 and stores the remainder in dl and quotient in rax
    mov rax, rdi                            ; copy rdi which is 8 byte unsigned int
                                            ; into rax
    mov rdi, rsp                            ; store current stack pointer
    push 0                                  ; allocate 8 bytes, all zero-initialized
    sub rsp, 16                             ; and 16 more bytes on the stack.

    dec rdi                                 ; we leave the least byte on the allocated
                                            ; block zero (null-terminated string)
    mov r8, 10                              ; each time we put the least digit into
                                            ; rdi
    
.iterate:
    xor rdx, rdx                            ; since the remainder after each division
                                            ; will be stored in rdx
    div r8                                  ; i.e rax = rax/10 and dl = rax%10
    or dl, 0x30                             ; convert remainder to hex
    dec rdi                                 ; Where to write dl?
    mov [rdi], dl                           

    test rax, rax                           ; is rax/quotient zero?
    jnz .iterate                            ; if not move on to next iteration
    
    call print_string                       ; otherwise, output it to stdout.

    add rsp, 24                             ; Restore stack states to the original.
    ret

; print_newline
;
print_newline:
    mov rax, 0x2000004                      ; write syscall
    mov rdi, 1                              ; stdout file descriptor
    mov rsi, newline_char                   ; where do we take data from?
    mov rdx, 1                              ; the amount of bytes to write
    syscall
    ret

; main
;
start:
    mov rdi, [rsp]                          ; argc is now in rdi
    call print_uint                         
    call print_newline
    
    ; exit
    mov rax, 0x2000001                      ; exit syscall
    xor rdi, rdi                            ; exit status
    syscall
