global start

section .data
msg:	db	'Hello, world!', 10
.len:	equ	$ - msg

section .text
start:
	mov	rax, 0x2000004		; write
	mov	rdi, 1			; stdout
	mov	rsi, msg
	mov	rdx, msg.len
	syscall

	mov	rax, 0x2000001		; exit
	xor	rdi, rdi
	syscall	
