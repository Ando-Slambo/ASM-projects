hex: hex.o
	ld -m elf_i386 -o hex hex.o

hex.o: hex.asm
	nasm -f elf32 -g -F stabs hex.asm
