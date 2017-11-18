# Compile, link, run asm codes in Mac OS X

```
nasm -f macho64 prog.asm
ld -macosx_version_min 10.7.0 -lSystem -o prog prog.o
./prog
```


# Differences between `Linux` and `Mac OSX`

1. system call numbers
The system call numbers supplied in `rax` before `syscall` instruction is executed 
_are different_ on Mac OS X. To find them:
  * Find the kernel version:

```
machine:~ user$ uname -v
Darwin Kernel Version 16.7.0: Thu Jun 15 17:36:27 PDT 2017; root:xnu-3789.70.16~2/RELEASE_X86_64
```
The kernel version part is `xnu-3789.70.16`
  * Go to the sources at: [https://opensource.apple.com/source/xnu/{KERNEL_VERSION}/bsd/kern/syscalls.master.auto.html](https://opensource.apple.com/source/xnu/{KERNEL_VERSION}/bsd/kern/syscalls.master.auto.html)

  * There we have syscall numbers in the first column. To make it work we need to add
0x2000000 to that number. E.g. for `write` call we need to pass not just `0x4` but `0x2000004` to the register `rax`



