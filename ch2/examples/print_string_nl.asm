; nasm -f macho64 print_string_nl.asm
; ld -macosx_version_min 10.7.0 -lSystem -o print_string_nl print_string_nl.o
; ./print_string_nl

global start

section .data
newline_char:	db	10
test_string:	db	"Hello, world", 0

section .text
; strlen
; Accepts a pointer to a null-terminated string and outputs
; its length
strlen:
	; Since the return value will be stored in rax
	; and we also use rax as index into string, we need to zero out it first
	xor rax, rax			; equivalent to mov rax, 0 but less expensive

.iterate:
	; Is the current char null?
	cmp byte [rdi + rax], 0

	; If it is null, go to .end
	je .end

	; else, increment rax and go to the next interation
	inc rax
	jmp .iterate
.end:
	ret

; print_string
; Accepts a pointer to a null-terminated string and outputs it
; to the stdout
print_string:
	; first, call strlen to get the length of the input string.
	; but a call to strlen could posibly change rdi, we need to save it
	; first
	push rdi
	call strlen

	; at this point, rax contains the length of the input string
	; we want this to be the third argument to system write
	; function
	mov rdx, rax

	; pop stack and store value into rsi which is the 2nd
	; argument to system write routine
	pop rsi

	mov rax, 0x2000004		; write syscall
	mov rdi, 1			; first argument is stdout

	; invoke system write(rdi, rsi, rdx)
	; where rdi is stdout, rsi is char *, rdx is
	; the number of bytes to be written
	syscall

	; exit
	ret

; print_newline
; Prints new line character to stdout
print_newline:
	mov rax, 0x2000004		; write syscall
	mov rdi, 1			; stdout has file descriptor of 1
	mov rsi, newline_char
	mov rdx, 1			; #bytes to be written
	syscall
	ret	
; main
start:
	mov rdi, test_string
	call print_string
	call print_newline

	; exit
	mov rax, 0x2000001		; exit syscall
	xor rdi, rdi			; status code is 0
	syscall
