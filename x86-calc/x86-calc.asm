;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/x86-calc/x86-calc.asm
; Addition calculator program.
;
; CHANGELOG :
;   v1.3.2 - 2022-06-24t01:20Q
;       fixed syscall, pop, ret in WRITELN
;
;   v1.3.1 - 2022-06-24t01:02Q
;       abstracted WRITELN
;
;   v1.3.0 - 2022-06-22t00:28Q
;       reverser can now be out of place
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
    push r8                     ; backup general purpose r8 for string address
    mov  r8,PROGRAM_MODE        ; load the program mode
    cmp  r8,0                   ; if (PROGRAM_MODE != 0)
    jne  CHOOSE_MODE_SKIP_CALC  ;   skip
    call CALC                   ; else run CALC
CHOOSE_MODE_SKIP_CALC:
    cmp  r8,1                   ; if (PROGRAM_MODE != 1)
    jne  CHOOSE_MODE_STRREV     ;   skip
    call TEST_STRREV            ; else run TEST_STRREV
CHOOSE_MODE_STRREV:
    pop  r8             ; restore general purpose
    ret
; end CHOOSE_MODE


; Perform the calc program.
CALC:
    ret
; end CALC


; Test the STRREV function on REV_TEST.
TEST_STRREV:
    ; C equivalent: STRREV(REV_TEST, REV_LEN);
    mov  rdi,REV_TEST_DST   ; addres to place reversed string
    mov  rsi,REV_TEST   ; string to reverse
    mov  rdx,REV_LEN    ; length of the string to print
    call STRREV         ; reverse the string
    ; C equivalent: WRITELN(REV_TEST, REV_LEN);
    ; print the reversed string to standard output
    mov  rsi,REV_TEST_DST   ; set to print the reversed string
    call WRITELN            ; print the string with a newline
    ret
; end TEST_STRREV


; WRITELN(char *rsi, int rdx)
; Writes the given string followed by a newline character.
; @param
;   rsi : char *= string to write, followed by a newline
; @param
;   rdx : int = length of the string rsi
WRITELN:
    ; set up
    push rsi            ; backup the string to print
    push rdx            ; backup the size of the string
    push rax            ; backup to hold the system call
    push rdi            ; backup to hold the file descriptor
    ; C equivalent: write(1, rsi, rdx);
    ; print the string in rsi
    mov  rax,1          ; system call to perform: sys_write
    mov  rdi,1          ; file descriptor to which to print, namely:
                        ; STDOUT (standard output)
    syscall     ; execute the system call
    ; C equivalent: write(1, ENDL, 1);
    ; print the newline
    mov  rax,1          ; system call to perform: sys_write
    mov  rsi,ENDL       ; newline to print
    mov  rdx,1          ; 1 character to print
    syscall     ; execute the system call
    ; clean up
    pop  rdi            ; restore rdi
    pop  rax            ; restore rax
    pop  rdx            ; restore the size of the string
    pop  rsi            ; restore the string to print
    ret
; end WRITE_LINE


; STRREV(char *rdi, char *rsi, int rdx)
; Reverses a string in rsi using the stack and places it in rdi.
;
; It can be that (rdi==rsi), in which case this is an in-place
; operation.
;
; @param
;   rdi : out char * = the reversed string
; @param
;   rsi : in  char * = the string to reverse
; @param
;   rdx : int = length of string to reverse
STRREV:
    push rcx            ; backup counter
    push r8             ; backup general purpose r8 for source address
    push r9             ; backup general purpose r9 for character
    push r10            ; backup general purpose r10 for sink address
    mov  rcx,rdx        ; set counter to rdx
    mov  r8,rsi         ; initialize the source address
    mov  r10,rdi        ; initialize the sink address
; push loop
STRREV_PUSH_LOOP:
    mov  r9,[r8]            ; copy the character
    push r9                 ; push it onto stack
    inc  r8                 ; next character in source
    loop STRREV_PUSH_LOOP   ; repeat
STRREV_PUSH_END:
    mov  rcx,rdx        ; set counter to rdx
STRREV_POP_LOOP:
    pop  r9                 ; pop the character
    mov  [r10],r9           ; place the character in the sink
    inc  r10                ; next character in sink
    loop STRREV_POP_LOOP    ; repeat
STRREV_POP_END:
    pop  r10            ; restore general purpose
    pop  r9             ; restore general purpose
    pop  r8             ; restore general purpose
    pop  rcx            ; restore counter
    ret
; end STRREV


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data
; newline character
ENDL:           db 0ah
; Program modes:
;   0 - calculator
;   1 - test STRREV string reverser
PROGRAM_MODE:   equ 1
; string to be reversed
REV_TEST:       db "Hello world!"
; length of REV_TEST
REV_LEN:        equ $ - REV_TEST

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; allocate space for reverser test results
REV_TEST_DST:  times REV_LEN resb 0

