;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/x86-calc/x86-calc.asm
; Example program for printing a greeting in x86-64 assembly.
; When      : 2022-06-15t01:29
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
    ; export the symbol _start
    global _start

; Beginning of the program to print a greeting.
_start:
    ; C equivalent: write(1, TO_REVERSE, REV_LEN);
    ; print the reversed string to standard output
    mov rax, 1          ; system call to perform: sys_write
    mov rdi, 1          ; file descriptor to which to print, namely:
                        ; STDOUT (standard output)
    mov rsi, TO_REVERSE ; reversed string to print
    mov rdx, REV_LEN    ; length of the string to print
    syscall     ; execute the system call
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov rax, 60         ; system call to perform: sys_exit
    mov rdi, 0          ; errorlevel (0 = EXIT_SUCCESS)
    syscall     ; execute the system call
; label for end of the program
END:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data

; string to be reversed
TO_REVERSE:     db "Hello world!", 0ah
; length of TO_REVERSE
REV_LEN:        equ $ - TO_REVERSE

