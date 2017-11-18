NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: strlen

strlen: strlen.o
	$(LD) -o $@ $^
strlen.o: strlen.asm
	$(NASM) $<

run: strlen
	./strlen

clean:
	$(RM) *.o strlen
