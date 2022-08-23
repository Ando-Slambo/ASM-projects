;   Executable name :   converter  
;   Version         :   0.1
;   Created Date    :   2022-08-19
;   Last Update     :   2022-08-19
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
    output: db 0                    ;must initialize the beginning of our string with
                                    ;an empty value so the .data section actually exists

SECTION .bss

SECTION .text
global _start
_start:
    nop
    
    ;setup registers
    mov eax, 40h                    ;put the number to be converted into eax
    mov ebp, output                 ;put output string into pointer
    xor ecx, ecx                    ;zero-out ecx to use as offset for ebp
    mov ebx, 10                     ;put divisor into ebx
    
    converter:
        xor edx, edx                ;zero-out edx so it doesnt mess with division
        cmp eax, 10                 ;compare eax to 10
        jl print                    ;jump to print label if eax is less than 10
        div ebx                     ;divide eax by 10
        add al, 30h                 ;convert decimal number to it's ASCII equivalent
        mov byte [ebp+ecx], al      ;append quotient (inside eax) to string
        inc ecx                     ;increment offset
        mov eax, edx                ;put remainder (inside edx) into eax
        jmp converter               ;repeat conversion operation
        
    print:
        add al, 30h                 ;convert decimal number to it's ASCII equivalent
        mov byte [ebp+ecx], al      ;append the character to string
        inc ecx                     ;increment offset
        mov byte [ebp+ecx], 10      ;append \n to string
        inc ecx                     ;increment offset
        
        mov edx, ecx                ;edx now holds the length of the string
        mov eax, 4                  ;4 into eax for sys_write
        mov ebx, 1                  ;1 into ebx for stdin
        mov ecx, ebp                ;put beginning of string into ecx
        int 80h                     ;system interrupt
    

    ;terminate program
    mov eax, 1
    mov ebx, 0
    int 80h
