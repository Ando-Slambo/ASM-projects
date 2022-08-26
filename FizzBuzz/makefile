fizzbuzz: fizzbuzz.o
	ld -m elf_i386 -o fizzbuzz fizzbuzz.o
fizzbuzz.o: fizzbuzz.asm
	nasm -f elf32 -g -F stabs fizzbuzz.asm
