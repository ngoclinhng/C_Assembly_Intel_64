NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: hello_world

hello_world: hello_world.o
	$(LD) -o $@ $^
hello_world.o: hello_world.asm
	$(NASM) $<

run: hello_world
	./hello_world

clean:
	$(RM) *.o hello_world
