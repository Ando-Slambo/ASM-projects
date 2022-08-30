fizzbuzz2: fizzbuzz2.o
	ld -m elf_i386 -o fizzbuzz2 fizzbuzz2.o
fizzbuzz2.o: fizzbuzz2.asm
	nasm -f elf32 -g -F stabs fizzbuzz2.asm
