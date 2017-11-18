NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: strlen print_string print_string_nl

strlen: strlen.o
	$(LD) -o $@ $^
strlen.o: strlen.asm
	$(NASM) $<

print_string: print_string.o
	$(LD) -o $@ $^
print_string.o: print_string.asm
	$(NASM) $<

print_string_nl: print_string_nl.o
	$(LD) -o $@ $^
print_string_nl.o: print_string_nl.asm
	$(NASM) $<

run: strlen print_string print_string_nl
	./strlen
	./print_string
	./print_string_nl

clean:
	$(RM) *.o strlen print_string print_string_nl
