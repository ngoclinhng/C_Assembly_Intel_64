; Open the file and output its contents to stdout
; ===============================================

; Constants
; =========
%define O_RDONLY    0x0000          ; 2nd for syscall open
%define PROT_READ   0x01            ; mapped area is readonly
%define MAP_PRIVATE 0x0002          ; mapped eare is private

section .data
; test file name
fname:  db  "test.txt", 0

section .text
global start

; strlen helper function.
; Given a pointer null-terminated string, computes its length.
; the first and only argument will be stored in the register rdi
strlen:
    xor rax, rax    ; zero out rax, equivalent to mov rax, 0 but less expensive
.iterate:
    cmp byte [rdi + rax], 0
    je .end
    inc rax
    jmp .iterate
.end:
    ret

; print_string
; Given a pointer null-terminated string, outputs its contents to stdout.
; NOTE:
; - the write syscall identifier in MAC OSX is 4 instead of 1 like in Linux
print_string:
    push rdi                ; Save argument
    call strlen             ; Determine string's length
    mov rdx, rax            ; #bytes to be writen
    mov rax, 0x2000004      ; write syscall identifier
    mov rdi, 1              ; stdout
    pop rsi                 ; buffer
    syscall
    ret

; main
start:
    ; call open(file name, flags, mode). Note that the open syscall has 
    ; identifier of 5 on MAC OSX instead of 2 (like in linux).
    ; The return value (int) is the file descriptor.
    mov rax, 0x2000005  ; open syscall identifier
    mov rdi, fname      ; file name
    mov rsi, O_RDONLY   ; readonly flags
    mov rdx, 0
    syscall             ; file descriptor will be stored in rax

    ; mmap
    mov r8, rax                 ; rax holds opened file descriptor
    mov rax, 0x20000c5          ; mmap syscall identifier on MAC OSX.
    mov rdi, 0                  ; Operating system will choose mapping destination.
    mov rsi, 4096               ; page size in bytes.
    mov rdx, PROT_READ          ; new memory region will be marked as readonly
    mov r10, MAP_PRIVATE        ; pages will not be shared
    mov r9, 0                   ; offset inside text.txt
    syscall                     ; now rax will point to mapped location

    mov rdi, rax
    call print_string

    mov rax, 0x2000001      ; exit syscall on MAC OSX
    xor rdi, rdi            ; exit status
    syscall
