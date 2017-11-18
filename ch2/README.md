# Compile, link, run asm codes in Mac OS X
```
nasm -f macho64 prog.asm
ld -macosx_version_min 10.7.0 -lSystem -o prog prog.o
./prog
```
