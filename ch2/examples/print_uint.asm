; nasm -f macho64 print_uint.asm
; ld -macosx_version_min 10.7.0 -lSystem -o print_uint print_uint.o
; ./print_uint
; Outputs an unsigned 8-byte integer in decimal format

global start

section .data
test_num:	dq	1234567890

section	.text
; helper func: strlen
; Takes as input a pointer to a null-terminated string and 
; outputs its length
strlen:
	xor rax, rax
.iterate:
	cmp byte [rdi + rax], 0
	je .end
	inc rax
	jmp .iterate
.end:
	ret

; helper func: print_string
; Takes as input a pointer to a null-terminated string and outputs its
; contents to stdout
print_string:
	push rdi
	call strlen
	mov rdx, rax
	mov rax, 0x2000004
	pop rsi
	mov rdi, 1
	syscall
	ret

; func: print_uint
; Takes as input an unsigned 8-byte integer and outputs it
; to the stdout in decimal format
print_uint:
	mov rax, rdi
	mov rdi, rsp
	push 0
	sub rsp, 16

	dec rdi
	mov r8, 10
.iterate:
	xor rdx, rdx
	div r8
	or dl, 0x30
	dec rdi
	mov [rdi], dl
	test rax, rax
	jnz .iterate

	call print_string

	add rsp, 24
	ret

; main
start:
	mov rsi, test_num
	mov rdi, [rsi]
	call print_uint

	; exit
	mov rax, 0x2000001
	xor rdi, rdi
	syscall	
