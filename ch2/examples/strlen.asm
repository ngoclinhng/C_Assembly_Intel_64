; nams -f macho64 strlen.asm --> strlen.o
; ld -macosx_version_min 10.7.0 -lSystem -o strlen
; ./strlen
; echo $?: exit status code of the last process, in our case
; the length of the string in .data section

global start

section	.data
test_string:	db	"abcdef", 0

section .text
; strlen
; Accepts a pointer to a null-terminated string and
; outputs its length (i.e the number of characters in that string
; excluding null-terminator)
strlen:
	; since we use rax for return value, we need to zero out
	; it first
	xor rax, rax			; equivalent to mov rax, 0 but less expensive
.iterate:				; main loop
	; compare the current character with null
	cmp byte [rdi + rax], 0

	; if it is equal, go to .end
	je .end

	; else, increment rax and go to the next interation
	inc rax
	jmp .iterate
.end:
	ret

; test
; after run ./strlen or make run strlen
; echo $? to see the output. Note that $? is the variable
; contains the exit status code of the last process
start:
	; copy pointer test_string into rdi. rdi will become the
	; first and only argument to strlen
	mov rdi, test_string

	; call strlen
	call strlen;

	; now, rax contains the length of the string pointed to
	; by test_string pointer. In order to test it on the terminal
	; we choose to return it as exit status code
	mov rdi, rax
	mov rax, 0x2000001			; exit syscall
	syscall
