;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/x86-calc/x86-calc.asm
; Addition calculator program.
;
; CHANGELOG :
;   v0.1.0 - 2022-06-15t22:00Q
;       counters for reverse push, pop loops
;
;   v0.0.0 - 2022-06-15t01:29Q
;       "Hello world" implementation
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
    ; export the symbol _start
    global _start

; Beginning of the program to print a greeting.
_start:
    ; C equivalent: STRREV(REV_TEST, REV_LEN);
    mov rsi, REV_TEST   ; reversed string to print
    mov rdx, REV_LEN    ; length of the string to print
    call STRREV         ; reverse the string
    ; C equivalent: write(1, REV_TEST, REV_LEN);
    ; print the reversed string to standard output
    mov rax, 1          ; system call to perform: sys_write
    mov rdi, 1          ; file descriptor to which to print, namely:
                        ; STDOUT (standard output)
    syscall     ; execute the system call
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov rax, 60         ; system call to perform: sys_exit
    mov rdi, 0          ; errorlevel (0 = EXIT_SUCCESS)
    syscall     ; execute the system call
; end _start


; Reverses a string using the stack, storing the result in the address
; of the original string.
STRREV:
    push rcx            ; backup counter
    mov rcx,rdx         ; set counter to rdx
; push loop
STRREV_PUSH_LOOP:
    dec rcx                 ; count down
    cmp rcx,0               ; if (rcx==0)
    jne STRREV_PUSH_LOOP    ; then repeat
STRREV_PUSH_END:
    mov rcx,rdx         ; set counter to rdx
STRREV_POP_LOOP:
    dec rcx                 ; count down
    cmp rcx,0               ; if (rcx==0)
    jne STRREV_POP_LOOP    ; then repeat
STRREV_POP_END:
    pop rcx             ; restore counter
    ret
; end STRREV


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data

; string to be reversed
REV_TEST:     db "Hello world!", 0ah
; length of REV_TEST
REV_LEN:        equ $ - REV_TEST

