; takes as input a buffer address and a size. reads next word from stdin
; (skipping whitespaces). stops and returns 0 if the word is too big
; compared to buffer size; otherwise returns the buffer address
; =========================================================================
;
; nasm -f macho64 read_word.asm
; ld -macosx_version_min 10.7.0 -lSystem -o read_word read_word.o
; ./read_word
; =========================================================================

global start

section .text
; helper function: read_char
; reads a single character from stdin and returns it
; ==================================================
read_char:
	; allocate space for new character on stack
	push 0

	mov rsi, rsp		; buffer to store character
	mov rax, 0x2000003	; read syscall
	mov rdi, 0		; stdin
	mov rdx, 1		; 1 byte
	syscall
	pop rax			; store character in rax
	ret

; read_word
; takes as inputs a buffer address(rdi) and a size(rsi) and reads next word
; from stdin(skipping whitespaces). Stops and returns 0 if the word is too big
; compared to the buffer size; otherwise, returns the buffer address.
; =============================================================================
read_word:
	; save callee-saved registers r14, r15
	push r14
	push r15

	; r14 serves as a counter, whereas r15 is the input size
	; we need to prepare them first
	xor r14, r14		; first read character is at index 0
	mov r15, rsi

	; if buffer size is less than or equal 1
	cmp r15, 1
	jle .D

	dec r15

	.A:			; read first char
	push rdi		; store buffer address
	call read_char		
	pop rdi			; restore buffer address
	
	; ignore all kinds of whitespaces
	cmp al, ' '
	je .A
	cmp al, 10
	je .A
	cmp al, 13
	je .A
	cmp al, 9
	je .A

	; not whitespace but a null character
	test al, al
	jz .C

	.B:
	; save the character read from .A
	mov byte [rdi + r14], al
	; increment index
	inc r14

	; read next char
	push rdi
	call read_char
	pop rdi

	; if it is whitespace or null
	; go to .C
	cmp al, ' '
	je .C
	cmp al, 10
	je .C
	cmp al, 13
	je .C
	cmp al, 9
	je .C
	test al, al
	jz .C

	cmp r14, r15
	je .D

	; else go to .B
	jmp .B

	.C:
	; add null character to the end of the buffer
	mov byte [rdi + r14], 0
	; store buffer address in rax to be returned
	mov rax, rdi

	; the second return value must be stored in rdx
	mov rdx, r14

	; restore callee-saveds
	pop r15
	pop r14
	
	ret

	.D:
	; the word is too big compared to buffer size
	; return 0
	xor rax, rax
	
	; restore callee-saveds
	pop r15
	pop r14

	ret

; strlen
; takes as input a pointer to a null-terminated string and returns its
; length.
; ====================================================================
strlen:
	xor rax, rax
.iterate:
	cmp byte [rdi + rax], 0
	je .end
	inc rax
	jmp .iterate
.end:
	ret

; print_string
; accepts a pointer to a null-terminated string and outputs it
; to the stdout
; ============================================================
print_string:
	mov rsi, rdi
	call strlen
	mov rdx, rax
	mov rax, 0x2000004
	mov rdi, 1
	syscall
	ret

; main
; test read_word
start:
	push 0
	mov rdi, rsp		; buffer at most 8 bytes
	mov rsi, 4		; buffer size

	call read_word

	test rax, rax
	jz .end

	mov rdi, rax
	call print_string
.end:
	pop rdi
	xor rdi, rdi
	mov rax, 0x2000001
	syscall
