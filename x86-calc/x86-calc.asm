;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/x86-calc/x86-calc.asm
; Addition calculator program.
;
; CHANGELOG :
;   v1.0.0 - 2022-06-16t01:29Q
;       reversing strings successfully
;
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
    ; C equivalent: write(1, ENDL, 1);
    mov rsi, ENDL       ; newline to print
    mov rdx, 1          ; 1 character to print
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
    push r8             ; backup general purpose r8 for string address
    push r9             ; backup general purpose r9 for character
    mov rcx,rdx         ; set counter to rdx
    mov r8,rsi          ; initialize the 
; push loop
STRREV_PUSH_LOOP:
    mov r9,[r8]             ; copy the character
    push r9                 ; push it onto stack
    inc r8                  ; next character
    loop STRREV_PUSH_LOOP   ; repeat
STRREV_PUSH_END:
    mov rcx,rdx         ; set counter to rdx
    mov r8,rsi          ; initialize the 
STRREV_POP_LOOP:
    pop r9                  ; pop the character
    mov [r8],r9             ; place the character in the string
    inc r8                  ; next character
    loop STRREV_POP_LOOP    ; repeat
STRREV_POP_END:
    pop r9              ; restore general purpose
    pop r8              ; restore general purpose
    pop rcx             ; restore counter
    ret
; end STRREV


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data

; string to be reversed
REV_TEST:       db "Hello world!"
; length of REV_TEST
REV_LEN:        equ $ - REV_TEST
; newline character
ENDL:           db 0ah

