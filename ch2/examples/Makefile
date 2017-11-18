NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: strlen print_string print_string_nl print_uint

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

print_uint: print_uint.o
	$(LD) -o $@ $^
print_uint.o: print_uint.asm
	$(NASM) $<

run: strlen print_string print_string_nl print_uint
	./strlen
	./print_string
	./print_string_nl
	./print_uint

clean:
	$(RM) *.o strlen print_string print_string_nl print_uint
