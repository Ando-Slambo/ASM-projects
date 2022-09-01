;   Executable name :   hex
;   Created Date    :   2022-08-31
;   Last Update     :   2022-08-31
;   Author          :   Colton Thiede
;   License         ;   GNU GPLv3.0
;   Description     :   Converts hexadecimal to ASCII and prints the number. Max FFFFFFFF (output is unsigned). Input decimal number for decimal
;						to hexadecimal converter
;
;   Build using these commands:
;       nasm -f elf32 -g -F stabs hex.asm
;       ld -m elf_i386 -o hex hex.o
;

SECTION .data

SECTION .bss
	output: resb 9				;reserve a buffer 9 bytes long - the longest string a 32-bit number can be plus \n

SECTION .text
global _start
_start:
    ;setup registers
    mov eax, 4294967295			;put the number to be converted into eax
    mov ebp, output				;put output string into pointer
    xor ecx, ecx				;zero-out ecx to use as offset for ebp
    mov ebx, 0x10				;put divisor into ebx
    
    converter:
		xor edx, edx				;zero out edx so it doesn't mess with division
		div ebx						;eax / ebx -> quotient in eax, remainder in edx
		
		;convert remainder to ASCII and append to string
		call digit_convert			;call the convert_digit function
		push edx					;the convert functions replace edx with the ASCII char, push it to the stack for later
		inc ecx						;inc ecx to keep track of the length of the string
		
		cmp eax, 0					;compare quotient to 0
		jne converter				;restart conversion loop if eax is not 0
	
	;pop pushed chars off the stack into the buffer
	xor edx, edx				;zero-out edx to use as offset (will equal the length of the string at the end of the constructor) 	
	string_constructor:
		pop eax						;pop char to eax
		mov [ebp+edx], eax			;mov char to pointer+offset
		inc edx						;inc edx to write to the next byte next iteration
		loop string_constructor		;will repeat loop until ecx is 0 then fall through to print
		mov byte [ebp+edx], 0xA		;append \n to string
		inc edx						;inc edx to keep track of length of string
		
	;print
	mov eax, 4					;sys_write
	mov ebx, 1					;stdout
	mov ecx, ebp				;put pointer to string in ecx
	int 80h

    ;terminate program
    mov eax, 1					;sys_exit
	mov ebx, 0					;return value
	int 80h
		
	digit_convert:
		cmp edx, 9					;compare remainder to 9
		jg digit_convert_letter		;if remainder is greater than 9 it is a letter else fall through to convert number
		
		add edx, 30h				;add 30h to convert to ASCII
		ret
		
	digit_convert_letter:
		add edx, 37h				;add 37h to convert to ASCII
		ret
