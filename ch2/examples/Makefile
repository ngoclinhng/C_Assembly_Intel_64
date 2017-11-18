NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: strlen print_string

strlen: strlen.o
	$(LD) -o $@ $^
strlen.o: strlen.asm
	$(NASM) $<

print_string: print_string.o
	$(LD) -o $@ $^
print_string.o: print_string.asm
	$(NASM) $<

run: strlen print_string
	./strlen
	./print_string

clean:
	$(RM) *.o strlen print_string
