fibonacci: fibonacci.o
	ld -m elf_i386 -o fibonacci fibonacci.o

fibonacci.o: fibonacci.asm
	nasm -f elf32 -g -F stabs fibonacci.asm
