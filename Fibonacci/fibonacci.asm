;   Executable name :   fibonacci  
;   Created Date    :   2022-08-30
;   Last Update     :   2022-08-30
;   Author          :   Colton Thiede
;   License         ;   GNU GPLv3.0
;   Description     :   Prints n numbers of the fibonnaci sequence until n=49 due to numbers being too damn high
;
;   Build using these commands:
;       nasm -f elf32 -g -F stabs fibonacci.asm
;       ld -m elf_i386 -o fibonacci fibonacci.o
;

SECTION .data
	output_desired equ 49		;number of numbers to print
	output_current: dd 0		;number of numbers we've printed
	error_msg: db "Error, number cannot fit into 32 bits.", 10
	error_msg_len equ $-error_msg

SECTION .bss
    output: resb 11				;reserve 11 bytes for printing strings (11 bytes is enough for max 32-bit integer + \n) 

SECTION .text
global _start
_start:
    ;setup and print first numbers
    mov eax, 0
    call Print					;jump to print with 0 in eax
    mov eax, 1
    call Print					;jump to print with 1 in eax
    mov eax, 1
    mov ebx, 0
    
    Begin:
		push eax					;save the sum of the last addition (will go into ebx next addition) 
		add eax, ebx				;eax + ebx, sum in eax
		jc error					;jump to error when carry flag is set (bit is carried beyond 32 bits) 
		;save eax and ebx values
		push eax					;save the sum of the current addition
		call Print
		pop eax						;load sum of the current addition into eax
		pop ebx						;lead the sum of the last addition into ebx
		jmp Begin					;start next iteration
    
    Print:
    ;setup registers (number to be printed must be in eax) 
    mov ebp, output				;put output string into pointer
    xor ecx, ecx				;zero-out ecx to use as offset for ebp
    mov ebx, 10					;put divisor into ebx
    
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
	
	mov ecx, [output_current]	;load the amount of numbers we've printed into ecx
	inc ecx						;increment by one (Print in previous line will print a number) 
	cmp ecx, output_desired		;compare numbers we've printed to numbers we want to print
	je Done
	mov [output_current], ecx	;save new printed numbers value
	ret
	
	error:
		mov eax, 4
		mov ebx, 1
		mov ecx, error_msg
		mov edx, error_msg_len
		int 80h
	
	Done:
		mov eax, 1					;sys_exit
		mov ebx, 0					;return value
		int 80h
		
