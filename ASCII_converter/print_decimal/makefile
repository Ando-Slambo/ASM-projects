converter: converter.o
	ld -m elf_i386 -o converter converter.o

converter.o: converter.asm
	nasm -f elf32 -g -F stabs converter.asm
