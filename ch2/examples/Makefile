NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: strlen print_string print_string_nl print_uint print_int \
	read_char read_word

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

print_int: print_int.o
	$(LD) -o $@ $^
print_int.o: print_int.asm
	$(NASM) $<

read_char: read_char.o
	$(LD) -o $@ $^
read_char.o: read_char.asm
	$(NASM) $<

read_word: read_word.o
	$(LD) -o $@ $^
read_word.o: read_word.asm
	$(NASM) $<

run: strlen print_string print_string_nl print_uint print_int \
read_char read_word
	./strlen
	./print_string
	./print_string_nl
	./print_uint
	./print_int
	./read_char
	./read_word

clean:
	$(RM) *.o strlen print_string print_string_nl print_uint \
	print_int read_char read_word
