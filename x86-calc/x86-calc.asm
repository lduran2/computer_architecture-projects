;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/x86-calc/x86-calc.asm
; Addition calculator program.
;
; CHANGELOG :
;   v1.2.3 - 2022-06-20t11:51Q
;       ITOA 128-bit test
;
;   v1.2.2 - 2022-06-17t01:59Q
;       documentation: ITOA, STRREV
;
;   v1.2.1 - 2022-06-17t01:49Q
;       loading ITOA demos
;
;   v1.2.0 - 2022-06-16t17:42Q
;       ready to print ITOA demos
;
;   v1.1.1 - 2022-06-16t02:31Q
;       demos for ITOA
;
;   v1.1.0 - 2022-06-16t01:57Q
;       added program modes
;
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


; Beginning calculator program.
_start:
    ; perform the appropriate mode based on PROGRAM_MODE
    call CHOOSE_MODE
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov  rax,60         ; system call to perform: sys_exit
    mov  rdi,0          ; errorlevel (0 = EXIT_SUCCESS)
    syscall     ; execute the system call
; end _start


; Call according to program mode.
CHOOSE_MODE:
    push r8             ; backup general purpose r8 for string address
    mov  r8,PROGRAM_MODE            ; load the program mode
    cmp  r8,0                       ; if (PROGRAM_MODE != 0)
    jne  CHOOSE_MODE_SKIP_CALC      ;   skip
    call CALC                       ; else run CALC
CHOOSE_MODE_SKIP_CALC:
    cmp  r8,1                       ; if (PROGRAM_MODE != 1)
    jne  CHOOSE_MODE_SKIP_STRREV    ;   skip
    call TEST_STRREV                ; else run TEST_STRREV
CHOOSE_MODE_SKIP_STRREV:
    pop  r8             ; restore general purpose
    ret
; end CHOOSE_MODE


; Perform the calc program.
CALC:
    ret
; end CALC


; Test the ITOA function on ITOA_TEST
TEST_ITOA:
    mov  rcx,ITOA_LEN   ; number of integers to test
    mov  r8,ITOA_TEST   ; initialize the integer address
; run each test
TEST_ITOA_TEST_LOOP:
    mov  rsi,[r8]       ; get the current number
    call ITOA           ; convert to a string
    ; C equivalent: write(1, rsi, rdx);
    ; print the last number converted
    mov  rax,1          ; system call to perform: sys_write
    mov  rdi,1          ; file descriptor to which to print,
                        ; namely: STDOUT (standard output)
    syscall             ; execute the system call
    inc  r8             ; next integer
    loop TEST_ITOA_TEST_LOOP    ; repeat
TEST_ITOA_TEST_END:
    ret
; end TEST_ITOA


; Test the STRREV function on REV_TEST.
TEST_STRREV:
    ; C equivalent: STRREV(REV_TEST, REV_LEN);
    mov  rsi,REV_TEST   ; reversed string to print
    mov  rdx,REV_LEN    ; length of the string to print
    call STRREV         ; reverse the string
    ; C equivalent: write(1, REV_TEST, REV_LEN);
    ; print the reversed string to standard output
    mov  rax,1          ; system call to perform: sys_write
    mov  rdi,1          ; file descriptor to which to print, namely:
                        ; STDOUT (standard output)
    syscall     ; execute the system call
    ; C equivalent: write(1, ENDL, 1);
    mov  rsi,ENDL       ; newline to print
    mov  rdx,1          ; 1 character to print
    syscall     ; execute the system call
    ret
; end TEST_STRREV


; ITOA(char *rsi, union { int i; char *s; } *rdx)
; Converts an integer to ASCII.
; @param
;   rsi  : int = integer to convert
; @param
;   rdi  : out char * = string converted from integer
; @param
;   rdx  : out int * = pointer to length of string converted from integer
ITOA:
    mov  rdx,0          ; set rdx to 0
    ret
; end ITOA


; STRREV(char *rsi, int rsi)
; Reverses a string using the stack in place.
; @param
;   rsi : 
;       in  char * = the string to reverse
;       out char * = the reversed string
; @param
;   rsi : int = length of string to reverse
STRREV:
    push rcx            ; backup counter
    push r8             ; backup general purpose r8 for string address
    push r9             ; backup general purpose r9 for character
    mov  rcx,rdx        ; set counter to rdx
    mov  r8,rsi         ; initialize the string address
; push each character onto the stack
STRREV_PUSH_LOOP:
    mov  r9,[r8]            ; copy the character
    push r9                 ; push it onto stack
    inc  r8                 ; next character
    loop STRREV_PUSH_LOOP   ; repeat
STRREV_PUSH_END:
    mov  rcx,rdx        ; set counter to rdx
    mov  r8,rsi         ; initialize the string address
; pop each character off the stack
STRREV_POP_LOOP:
    pop  r9                 ; pop the character
    mov  [r8],r9            ; place the character in the string
    inc  r8                 ; next character
    loop STRREV_POP_LOOP    ; repeat
STRREV_POP_END:
    pop  r9             ; restore general purpose
    pop  r8             ; restore general purpose
    pop  rcx            ; restore counter
    ret
; end STRREV


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data
; Program modes:
;   0 - calculator
;   1 - test STRREV string reverser
;   2 - test itoa (integer to ASCII) for printing integers
PROGRAM_MODE:   equ 2
; string to be reversed
REV_TEST:       db "Hello world!"
; length of REV_TEST
REV_LEN:        equ $ - REV_TEST
; newline character
ENDL:           db 0ah
; array of integers to print
; (quad word, 64-bits)
ITOA_TEST:      dq 365,42,-1760
; oct word, 128-bit test
ITOA_TEST2:     dq (1 << (64 - 1)),365
; number of integers to print
ITOA_LEN:       equ $ - ITOA_TEST

