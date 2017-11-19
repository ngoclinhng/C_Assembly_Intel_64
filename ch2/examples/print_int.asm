; Output a signed 8-byte integer in decimal format
; ================================================
;
; nasm -f macho64 print_int.asm
; ld -macosx_version_min 10.7.0 -lSystem -o print_int print_int.o
; ./print_int

global start

section .data
test_num:	dq	-1234567890
negsign:	db	0x2d

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

; print_negsign
; Outputs negative sign to the stdout
print_negsign:
	mov rax, 0x2000004		; write syscall
	mov rdi, 1			; stdout
	mov rsi, negsign		; address of '-'
	mov rdx, 1			; write 1 byte
	syscall
	ret

; main
start:
	; could have been mov rdi, [test_num] but turns out
	; this is an error when compile on Mac OSX. So we use
	; a litle hack here to get 8 consecutive bytes starting
	; at the address stored in test_num into rdi
	mov rsi, test_num
	mov rdi, [rsi]
	
	; compare rdi with 0
	cmp rdi, 0

	; if it is less than 0, go to .less
	jl .less

	; else, outputs it as if it was unsigned 8-byte integer
	call print_uint
.less:
	; save current value in rdi and print negative sign
	push rdi
	call print_negsign

	; retrieve rdi, negate it and output the unsigned version
	pop rdi	
	neg rdi
	call print_uint

	; exit
	mov rax, 0x2000001
	xor rdi, rdi
	syscall	
