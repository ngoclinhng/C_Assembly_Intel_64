NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: mmap

mmap: mmap.o
	$(LD) -o $@ $^
mmap.o: mmap.asm
	$(NASM) $<

run: mmap
	./mmap

clean:
	$(RM) *.o mmap
