;   Executable name     :       fizzbuzz2
;   Created date        :       2022-08-29
;   Updated date        :       2022-08-29
;   Author              :       Colton Thiede 
;   License             :       GNU GPLv3.0
;   Description         :       An attempt at writing FizzBuzz without dividing the numbers except for ASCII conversion. It's a bit of a mess
;				and it's about 30% slower than the original FizzBuzz but I'm still glad I wrote it. It took a considerable
;				amount of brain power to plan and an incredible amount to debug and at the end of the day it works as intended.
;				Lesson learned: it's better to use slower instructions than to juggle data to and from memory.
;
;   Build with these commands:
;       nasm -f elf32 -g -F stabs fizzbuzz2.asm
;       ld -m elf_i386 -o fizzbuzz2 fizzbuzz2.o
;
SECTION .bss
	buffer_strings: resd length				;buffer to hold the strings
	buffer_nums: resd length				;buffer to hold the numbers
	buffer_string_length: resd length		;buffer to hold the length of the strings
	buffer_print: resb 11					;buffer for writing to print to the terminal - 11 is the maximum amount of characters we can print

SECTION .data
	dword_bytes equ 4
	num_one equ 3							;number that will be replaced with Fizz
	num_two equ 5							;number that will be replaced with Buzz
	length equ num_one * num_two			;length of the repeating pattern to use for printing
	Fizz: db "Fizz"
	Buzz: db "Buzz"
	newline: db 10
	num_printed: dd 0						;number of times we've printed to terminal
	num_to_print: dd 1000000				;number of times we want to print to terminal
    
SECTION .text
global _start
_start:
	;setup pointers
	mov ebp, buffer_strings					;save pointer to the strings buffer in ebp
	mov eax, buffer_string_length			;save pointer to the string's length buffer in eax
	mov ebx, buffer_nums					;save pointer to the number buffer is ebx
	;decrement pointers to fix off-by-one error
	dec ebp
	dec eax
	dec ebx
	
	mov ecx, length*dword_bytes						;save length of the pattern * 4 (4 bytes per char) in ecx to use as offset
	
	;zero-out buffers
	zero_out:
		mov dword [ebp+ecx], 0					;zero-out strings buffer
		mov dword [eax+ecx], 0					;zero-out string's length buffer - probably not neccessary but whatever
		mov dword [ebx+ecx], 0					;zero-out number buffer
		sub ecx, dword_bytes					;decrease ecx by dword length
		cmp ecx, 0								;compare offset to 0
		ja zero_out								;continue to next iteration if above 0
	
	;ecx starts at beginning of buffer
	generate_fizz:
		add ecx, num_one*dword_bytes			;increase the offset to overwrite memory address n+num_one*4 where n starts at 0
		cmp ecx, length*dword_bytes				;compare ecx to length*4
		je generate_buzz						;jump to generate_buzz if =length
		mov dword [ebp+ecx], Fizz				;overwrite dword at buffer+offset with 'Fizz'
		mov dword [eax+ecx], dword_bytes		;save length of string at this offset
		jmp generate_fizz						;continue to next iteration
		
	;ecx starts at beginning of buffer
	generate_buzz:
		xor ecx, ecx
		loop:
			add ecx, num_two*dword_bytes			;increase the offset to overwrite memory address n+num_two*4 where n starts at 0
			cmp ecx, length*dword_bytes				;compare ecx to length*4
			je generate_fizzbuzz					;jump to fizzbuzz when ecx=length*4
			mov dword [ebp+ecx], Buzz				;overwrite dword at buffer+offset with 'Buzz'
			mov dword [eax+ecx], dword_bytes		;save length of string at this offset
			jmp loop								;continue to next iteration
	
	;ecx now = end of buffer, overwrite this dword with FizzBuzz because the end is always =(num_one * num_two)
	generate_fizzbuzz:
		mov dword [ebp+ecx], Fizz				;overwrite last element of pattern (num_one * num_two) with Fizz
		mov dword [eax+ecx], 8						;since Buzz comes immediately after Fizz we save the pointer to Fizz but save length 8 to write Buzz as well
	
	;work backwards through the loop generating the list of numbers that will be printed
	Process:
		sub ecx, dword_bytes					;decrease ecx by 4 bytes to work backwards from end of buffer
		cmp ecx, 0								;cmp ecx to 0
		je Print
		cmp dword [ebp+ecx], 0					;compare the dword at offset to 0 (see if it's empty) 
		jne Process								;if the dword is not empty (if it contains a string), jump to next iteration
		;mov dword [ebx+ecx], ecx				;else if it is empty write the offset/4 to the numbers buffer
			;write the offset/4 to the numbers buffer
			write:
				;save values in registers
				push eax
				push edx
				push ebx
				
				;setup registers for division
				xor edx, edx						;zero-out edx so it doesn't mess with division
				mov eax, ecx						;put the offset into eax to be divided
				mov ebx, dword_bytes				;put divisor into ebx
				div ebx								;eax / ebx (offset / 4) = quotient in eax, remainder in edx
				pop ebx								;pop saved pointer back into ebx
				mov dword [ebx+ecx], eax			;put quotient of offset/4 into buffer at offset
				pop edx								;pop saved edx back into register
				pop eax								;pop saved eax back into register
				
		jmp Process								;repeat until ecx=0
	
	Print:
		mov edx, [num_printed]
		cmp edx, [num_to_print]					;compare number of times we printed to how many we want to print
		je Done									;jump to terminate program if equal
		add ecx, 4								;increase offset to look at next dword
		cmp ecx, length*dword_bytes				;compare ecx to length of pattern in dwords
		ja reset_ecx							;need to reset ecx back to 0 if it is above
		return:
		cmp dword [ebx+ecx], 0					;check if there is a number in the number buffer at this offset
		je String								;if there is no number there is a string, jump to string printer
		jmp Number								;else there is a number, jump to the number printer (does conversion to ASCII) 
		
	;print the string at the current offset
	String:
		inc edx									;keep track of the times we've printed
		mov dword [num_printed], edx			;save incremented value
		
		;save pointers and offset to the stack
		push eax
		push ebx
		push ecx
		
		mov edx, [eax+ecx]						;put string length into edx
		mov ecx, [ebp+ecx]						;put pointer to string into ecx
		mov eax, 4								;sys_write
		mov ebx, 1								;stdout
		int 80h
		
		;print \n
		mov eax, 4
		mov ebx, 1
		mov ecx, newline
		mov edx, 1
		int 80h
		
		;load previously saved pointers and offset from the stack in reverse order
		pop ecx
		pop ebx
		pop eax
		jmp Print								;restart loop to print next element in list


	;convert hex to decimal to ASCII and print to terminal
	Number:
		inc edx									;keep track of the times we've printed
		mov dword [num_printed], edx			;save incremented value
		
		;save pointers and offset to the stack
		push eax
		push ebx
		push ecx
		
		;setup registers for converting number to ASCII
		mov eax, [ebx+ecx]						;put the number in the buffer at the current offset into eax for conversion
		add dword [ebx+ecx], length				;add length to the number so next iteration it will be in the next set
		mov ebx, 10								;put divisor into ebx
		
		converter:
			xor ecx, ecx							;zero out ecx to have accurate string length
			conv_loop:
			xor edx, edx							;zero out edx so it doesn't mess with division
			div ebx									;eax / ebx = quotient in eax, remainder in edx
		
			;convert to ASCII and push to stack
			add edx, 30h							;convert remainder to it's ASCII char
			push edx								;push char onto the stack
			inc ecx									;inc ecx to keep track of the length of the string (at the end ecx will be one less than the length of the string)
			cmp eax, 9								;compare eax to 9
			ja conv_loop							;restart conversion loop if eax is greater than 9 else fall through to append quotient to string
		
			;convert to ASCII and append to string
			add eax, 30h							;convert to ASCII char 
			mov [ebp], eax							;put char into the beginning of the char array
	
			;pop pushed chars off the stack into the string
			mov edx, 1								;use edx as our pointer offset (string starts with 1 char in it so we must start with 1 in edx) 	
			string_constructor:
				pop eax									;pop char to eax
				mov [ebp+edx], eax						;mov char to pointer+offset
				inc edx									;inc edx to write to the next byte next iteration
				loop string_constructor					;will repeat loop until ecx is 0 then fall through to print
				mov byte [ebp+edx], 10					;append \n to string
				inc edx									;inc edx to keep track of length of string
			
			;print number
			mov eax, 4								;sys_write
			mov ebx, 1								;stdout
			mov ecx, ebp							;beginning of string
			int 80h
		
		;load previously saved pointers and offset from the stack in reverse order
		pop ecx
		pop ebx
		pop eax
		jmp Print								;restart loop to print next element in list
		
	;terminate program
	Done:
		mov eax, 1								;sys_exit
		mov ebx, 0								;return value
		int 80h
		
	reset_ecx:
		mov dword ecx, 4
		jmp return
