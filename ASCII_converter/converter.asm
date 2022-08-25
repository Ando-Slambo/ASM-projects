;   Executable name :   converter  
;   Version         :   0.2
;   Created Date    :   2022-08-22
;   Last Update     :   2022-08-25
;   Author          :   Colton Thiede
;   License         ;   GNU GPLv3.0
;   Description     :   Converts a decimal or hexadecimal number to it's ASCII equivalent 
;                       and prints it to terminal. This currently does not have an input.
;
;   Build using these commands:
;       nasm -f elf32 -g -F stabs converter.asm
;       ld -m elf_i386 -o converter converter.o
;

SECTION .data
    output: db 0                    ;must initialize the beginning of our string with an empty value so the .data section actually exists

SECTION .bss

SECTION .text
global _start
_start:
    nop
    
    ;setup registers
    mov eax, 139					;put the number to be converted into eax
    mov ebp, output					;put output string into pointer
    xor ecx, ecx					;zero-out ecx to use as offset for ebp
    mov ebx, 10						;put divisor into ebx
    
    converter:
		xor edx, edx				;zero out edx so it doesn't mess with division
		div ebx						;eax / ebx -> quotient in eax, remainder in edx
		
		;convert to ASCII and push to stack
		add edx, 30h				;convert remainder to it's ASCII char
		push edx					;push char onto the stack
		inc ecx						;inc ecx to keep track of the length of the string (at the end ecx will be one less than the length of the string)
		
		cmp eax, 9					;compare eax to 9
		jg converter				;restart conversion loop if eax is greater than 9 else fall through to append quotient to string
		
		;convert to ASCII and append to string
		add eax, 30h				;convert to ASCII char 
		mov [ebp], eax				;put char into the beginning of the char array
	
	;pop pushed chars off the stack into our string
	mov edx, 1					;use edx as our pointer offset (string starts with 1 char in it so we must start with 1 in edx) 	
	string_constructor:
		pop eax						;pop char to eax
		mov [ebp+edx], eax			;mov char to pointer+offset
		inc edx						;inc edx to write to the next byte next iteration
		loop string_constructor		;will repeat loop until ecx is 0 then fall through to print
		mov byte [ebp+edx], 10		;append \n to string
		inc edx						;inc edx to keep track of length of string
		
	;print
	mov eax, 4					;sys_write
	mov ebx, 1					;stdout
	mov ecx, ebp				;put pointer to string in ecx
	int 80h						;system interrupt to call service dispatcher

    ;terminate program
    mov eax, 1					;sys_exit
    mov ebx, 0					;return value
    int 80h						;system interrupt to call service dispatcher
