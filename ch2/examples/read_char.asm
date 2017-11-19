; Reads one character from stdin and returs it.
; ==============================================================
;
; nasm -f macho64 read_char.asm
; ld -macosx_version_min 10.7.0 -lSystem -o read_char read_char.o
; ./read_char a
; ===============================================================

global start

section .text
; read_char
; reads one character from stdin and returns it
; =============================================
read_char:
	; allocate space on the stack for new character
	push 0

	mov rax, 0x2000003		; read syscall
	mov rdi, 0			; stdin
	mov rsi, rsp		
	mov rdx, 1			; read one byte
	syscall
	pop rax				; return value in rax
	ret

; helper func: print_char
; takes input as a character and outputs it to stdout
; ===================================================
print_char:
	push rdi
	mov rsi, rsp
	mov rax, 0x2000004		; write syscall
	mov rdi, 1			; stdout
	mov rdx, 1			; write 1 byte
	syscall
	pop rdi
	ret

; main
start:
	; read one character from stdin
	call read_char

	; outputs it to stdout
	mov rdi, rax
	call print_char

	; exit program
	mov rax, 0x2000001		; exit syscall
	xor rdi, rdi			; 0 as exit status code
	syscall	
	
	
