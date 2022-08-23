reverser: reverser.o
	ld -m elf_i386 -o reverser reverser.o
	
reverser.o: reverser.asm
	nasm -f elf32 -g -F stabs reverser.asm
