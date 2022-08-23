;   Executable name :   reverser
;   Version         :   0.1
;   Created Date    :   2022-08-18
;   Last Update     :   2022-08-18
;   Author          :   Colton Thiede
;   License         :   MIT
;   Description     :   Takes the specified string in source, print it to terminal
;                       along with it's reversed string.
;
;   Build using these commands:
;       nasm -f elf32 -g -F stabs reverser.asm
;       ld -m elf_i386 -o reverser reverser.o
;

SECTION .data
    msg: db "Hello world!", 10      ;the string we will be reversing
    msg_len: equ $-msg              ;defines the length of the msg
    msg_rev: db ""                  ;creates a label for us to add characters to later    

SECTION .bss

SECTION .text
global _start
_start:
    nop                             ;makes the debugger happy
    
    ;setup pointer and offset registers for scanning the input string
    mov ebp, msg                    ;move the beginning of the char array into a pointer register
    dec ebp                         ;decrement pointer to avoid off-by-one error
    mov ecx, msg_len                ;put the length of the string into ecx to decrement and end loop
    dec ecx                         ;decrement ecx to avoid the new-line character at the end of the string
    
    ;setup pointer and offset registers for appending to the new string
    mov ebx, msg_rev                ;using ebx as a pointer to add characters to msg_rev
    mov edx, 0                      ;move 0 into edx to increment to add characters
    
    ;iterate through the input string and append each character to the new string
    reverser:
        mov eax, [ebp+ecx]          ;move the character at [ebp+ecx] into eax
        mov [ebx+edx], eax          ;move the character to [ebx+edx] because we cannot move mem to mem
        inc edx                     ;increment edx so next iteration will look at next address
        loop reverser               ;loop will decrement ecx and jump to the label until ecx is 0
        
    mov byte [ebx+edx], 10          ;append a new-line character to the end of the new string
    
    ;print the original string
    mov eax, 4                      ;move 4 into eax to specify sys_write service
    mov ebx, 1                      ;move 1 into ebx to specify to write to stdin
    mov ecx, msg                    ;move beginning of string into ecx
    mov edx, msg_len                ;move the length of the string into edx
    int 80h                         ;system interrupt
    
    ;print the reversed string
    mov eax, 4                      ;the previous int 80h changed eax so we must change it back
    mov ecx, msg_rev                ;move beginning of reversed string into ecx
    int 80h                         ;system interrupt
    
    ;terminate program
    mov eax, 1                      ;move 1 into eax to specify sys_exit service
    mov ebx, 0                      ;move 0 into ebx as our return value
    int 80h                         ;system interrupt

    
