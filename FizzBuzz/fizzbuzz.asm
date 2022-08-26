;   Executable name     :       fizzbuzz
;   Created date        :       2022-08-25
;   Updated date        :       2022-08-25
;   Author              :       Colton Thiede 
;   License             :       GNU GPLv3.0
;   Description         :       Takes 2 numbers and cycles through a specified amount of numbers,
;                               printing "Fizz" for numbers divisible by the first, "Buzz" for
;                               numbers divisible by the second, "FizzBuzz" for numbers divisible
;                               by both, or the number itself if neither are divisible. Can only
;                               print up to 9999 numbers.
;
;   Build with these commands:
;       nasm -f elf32 -g -F stabs fizzbuzz.asm
;       ld -m elf_i386 -o fizzbuzz fizzbuzz.o
;
SECTION .bss
	string_len: resb msg_len		;create a buffer 4 bytes long for storing the string length
	string: resb msg_len			;create a buffer 4 bytes long for storing the string

SECTION .data
    ;setup numbers for generating fizzbuzz
    num_one equ 3					;first number
    num_two equ 5					;second number
    print_len equ 100				;print 100 numbers
    
    ;setup strings
    FIZZ equ 5A5A4946h				;'FIZZ'
    BUZZ equ 5A5A5542h				;'BUZZ'
    msg_len equ 4					;length of fizz and buzz
    
    ;setup for printing
    num_last: db 0					;current number the loop is working on
    ;string_len: db 0				;empty value that will hold the length of the string
    ;string: db 0					;empty string for writing ASCII chars to
    
SECTION .text
global _start
_start:
	xor eax, eax					;zero-out eax
	mov ebp, string					;put start of string into pointer
    
    Loop:
		xor ecx, ecx					;zero-out ecx to use as offset for pointer
        mov eax, [num_last]				;mov last number processed into eax
        inc eax							;increment to next number
        mov [num_last], eax				;mov new number to memory to be incremented next iteration
        cmp eax, print_len				;compare eax to the max number we want to print
        ja Done							;jump to Done if we've crossed the max  
        
	;test if divisible by first number
	mov ebx, num_one				;put divisor into ebx
	xor edx, edx					;zero-out edx so it doesn't mess with division
	div ebx							;eax / ebx
	cmp edx, 0						;compare remainder to 0
	jnz Num2						;jump to next test if remainder is non-zero, else add FIZZ to string
	mov dword [ebp+ecx], FIZZ		;append 'FIZZ' to string
	add ecx, 4						;add 4 to offset
	
	;test if divisible by second number
	Num2:
		mov eax, [num_last]				;num_last is actually the currently working number, load into eax
		mov ebx, num_two				;put divisor into ebx
		xor edx, edx					;zero-out edx so it doesn't mess with division
		div ebx							;eax / ebx
		cmp edx, 0						;compare remainder to 0
		jnz Print_String				;jump to print string if remainder is non-zero, else add BUSS to string
		mov dword [ebp+ecx], BUZZ		;append 'BUZZ' to string
		add ecx, 4						;add 4 to offset
		
	Print_String:
		cmp ecx, 0						;compare ecx to 0. 
		je Print_Num					;if 0 we did not write any chars, jump to print num else fall through to print strings
		mov byte [ebp+ecx], 10			;append \n
		inc ecx							;inc ecx to have accurate string length
		mov edx, ecx					;mov string length into edx
		mov eax, 4						;sys_write
		mov ebx, 1						;stdout
		mov ecx, ebp					;pointer to string in ecx
		int 80h
		jmp Loop						;start next iteration
		
	Print_Num:
		;setup registers for converting number to ASCII
		mov eax, [num_last]				;num_last is actually the currently working number, load into eax 
		xor ecx, ecx					;zero-out ecx to use as offset for ebp
		mov ebx, 10						;put divisor into ebx
		xor edx, edx					;zero out edx so it doesn't mess with division
		
		div ebx							;eax / ebx = quotient in eax, remainder in edx
		
		;convert to ASCII and push to stack
		add edx, 30h					;convert remainder to it's ASCII char
		push edx						;push char onto the stack
		inc ecx							;inc ecx to keep track of the length of the string (at the end ecx will be one less than the length of the string)
		
		cmp eax, 9						;compare eax to 9
		jg Print_Num					;restart conversion loop if eax is greater than 9 else fall through to append quotient to string
		
		;convert to ASCII and append to string
		add eax, 30h					;convert to ASCII char 
		mov [ebp], eax					;put char into the beginning of the char array
	
		;pop pushed chars off the stack into our string
		mov edx, 1					;use edx as our pointer offset (string starts with 1 char in it so we must start with 1 in edx) 	
		string_constructor:
			pop eax							;pop char to eax
			mov [ebp+edx], eax				;mov char to pointer+offset
			inc edx							;inc edx to write to the next byte next iteration
			loop string_constructor			;will repeat loop until ecx is 0 then fall through to print
			mov byte [ebp+edx], 10			;append \n to string
			inc edx							;inc edx to keep track of length of string
			
		;print number
		mov eax, 4					;sys_write
		mov ebx, 1					;stdout
		mov ecx, ebp				;beginning of string
		int 80h
		
		jmp Loop					;restart loop to print next number
        
	Done:
		mov eax, 1
		mov ebx, 0
		int 80h
