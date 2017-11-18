# Low Level Programming

Learning Assembly, C in the Intel 64 Architechture from the book
[low level programming](https://www.amazon.com/Low-Level-Programming-Assembly-Execution-Architecture/dp/1484224027/ref=sr_1_1?ie=UTF8&qid=1510976772&sr=8-1&keywords=low+level+programming)


# Compile, link, run asm codes in Mac OS X

```
nasm -f macho64 prog.asm
ld -macosx_version_min 10.7.0 -lSystem -o prog prog.o
./prog
```
If the `nasm` comes with Mac OSX system doesn't support `macho64` format, use [homebrew](https://brew.sh) to install latest version of `nasm`: `brew install nasm`

A few `nasm` related commands will come in handy:

Version:		`nasm -v`
Available formats:	`nasm -hf`
Help:			`nasm -h`

# Differences between `Linux` and `Mac OSX`

## System call numbers

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

## Don't underscore global labels!

In linux system we can declare global label such as `global _start`, etc...But things
are a little diffrent with Mac OSX. If we underscore global variables the linker will fail(still don't quit understand why the hell is that)


# `lldb` helpful commands for debugging

To enable Intel assembly syntax, add this line `settings set target.x86-disassembly-flavor intel` to `~/.lldbinit` file.

Let's assume that we have a executable file named `prog`. We can start looking around by invoke the command `lldb prog`

## helpful commands with explanations:
  1. `b some_label`. For example `b start`: set break point at start label.
  2. `run`: run until hit the breakpoint.
  3. `n`: execute the next instruction.
  4. `register read some_register`. For example, `register read rax`: reads content currently in `rax`.
  5. `p $some_register`. For example, `p $rdi`. Similar to the 4. above but instead of
outputting contents in hexadecimal format, this command will output it in a human
readable format, e.g `(unsigned long) $0 = 6`.
  6. `memory read --size [sz] --format [x|a|i|c|s] --count cnt $register_name`: reads cnt consecutive memory cells, each cell has size of sz (1 for 1 byte, etc...) starting at the address stored in `register_name`(must be prefixed with `$` sign, i.e `$rdi`), and outputs it in either `x`(hexadecimal format), `a`(address), `i`(instruction), `c`(char) and `s`(null-terminated string).

     Example 1:
     ```
     (lldb) register read rdi
     	rdi = 0x0000000000002000  test_string
     (lldb) memory read --format s $rdi
        0x00002000: "abcdef"
     ```
     In C term, test_string is char * and it points to "abcdef"
