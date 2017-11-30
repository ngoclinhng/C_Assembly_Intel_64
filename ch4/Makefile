NASM=nasm -f macho64
LD=ld -macosx_version_min 10.7.0 -lSystem

all: mmap acat print_argc print_argv

mmap: mmap.o
	$(LD) -o $@ $^
mmap.o: mmap.asm
	$(NASM) $<

acat: acat.o
	$(LD) -o $@ $^
acat.o: acat.asm
	$(NASM) $<

print_argc: print_argc.o
	$(LD) -o $@ $^
print_argc.o: print_argc.asm
	$(NASM) $<

print_argv: print_argv.o
	$(LD) -o $@ $^
print_argv.o: print_argv.asm
	$(NASM) $<

clean:
	$(RM) *.o mmap acat print_argc print_argv
