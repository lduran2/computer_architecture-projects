;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/x86-calc/x86-calc.asm
; Addition calculator program.
;
; CHANGELOG :
;   v2.6.0 - 2022-06-21t20:58Q
;       handling sign of integers
;
;   v2.5.0 - 2022-06-21t20:58Q
;       backwards ITOA for ints{+}
;
;   v2.4.0 - 2022-06-21t19:40Q
;       optimized ITOA_DIVIDE_INT_LOOP: test quotient, not cmp
;
;   v2.3.2 - 2022-06-21t19:44Q
;       proper handling of sign bit in ITOA
;
;   v2.3.1 - 2022-06-21t04:39Q
;       counting digits (< 10)
;       fixed ITOA choose
;       ITOA test call
;
;   v2.3.0 - 2022-06-21t03:18Q
;       ITOA division loop conditions
;
;   v2.1.1 - 2022-06-17t01:59Q
;       documentation: ITOA, STRREV
;
;   v2.1.0 - 2022-06-17t01:49Q
;       loading ITOA demos
;
;   v2.0.0 - 2022-06-16t17:42Q
;       ready to print ITOA demos
;
;   v1.2.0 - 2022-06-16t02:31Q
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
    mov  r8,PROGRAM_MODE        ; load the program mode
CHOOSE_MODE_CALC:
    cmp  r8,0                   ; if (PROGRAM_MODE != 0)
    jne  CHOOSE_MODE_STRREV     ;   check for STRREV
    call CALC                   ; else run CALC
CHOOSE_MODE_STRREV:
    cmp  r8,1                   ; if (PROGRAM_MODE != 1)
    jne  CHOOSE_MODE_ITOA       ;   check for ITOA
    call TEST_STRREV            ; else run TEST_STRREV
CHOOSE_MODE_ITOA:
    cmp  r8,2                   ; if (PROGRAM_MODE != 2)
    jne  CHOOSE_MODE_DEFAULT    ;   default
    call TEST_ITOA              ; else run TEST_ITOA
CHOOSE_MODE_DEFAULT:
    pop  r8             ; restore general purpose
    ret
; end CHOOSE_MODE


; Perform the calc program.
CALC:
    ret
; end CALC


; Test the ITOA function on ITOA_TEST
TEST_ITOA:
    mov  r8,ITOA_TEST   ; initialize the integer address
    mov  rcx,ITOA_LEN   ; number of integers to test
; run each test
TEST_ITOA_TEST_LOOP:
    mov  rdi,ITOA_TEST_DST      ; set result address
    mov  rsi,RADIX              ; set radix
    mov  rax,[r8]               ; get the current number
    call SIGN128                ; extend sign bit
    call ITOA                   ; convert to a string
    ; C equivalent: write(1, ITOA_TEST_DST, rdx);
    ; print the last number converted
    mov  rsi,rdi                ; move result string address to print
    ; the length is already ready from ITOA
    mov  rax,1                  ; system call to perform: sys_write
    mov  rdi,1                  ; file descriptor to which to print,
                                ; namely: STDOUT (standard output)
    push rcx            ; guard from write changing rcx
    syscall             ; execute the system call
    ; C equivalent: write(1, ENDL, 1);
    mov  rsi,ENDL       ; newline to print
    mov  rdx,1          ; 1 character to print
    mov  rax,1          ; system call to perform: sys_write
    syscall             ; execute the system call
    pop  rcx            ; restore rcx
    add  r8,8                   ; next integer
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


; ITOA(char *rdi, int rsi, int128_t (rdx:rax))
; Converts an integer to ASCII.
; @param
;   rdi : out char * = string converted from integer
; @param
;   rsi : out int = radix of the integer
; @param
;   (rdx:rax) : in  int128_t = integer to convert
;   rdx       : out int      = length of string converted from integer
ITOA:
    push r8             ; backup general purpose r8 for digit count
    push r9             ; backup general purpose r9 for current address
    push r10            ; backup general purpose r10 for sign register
    mov  r8,0           ; clear digit count
    mov  r9,rdi         ; initialize the destination address
    mov  r10,rax            ; copy low bits into sign register
    sar  r10,63             ; shift sign bit through sign register
    test r10,-1             ; test sign bit
    je   ITOA_NOW_POSITIVE  ; if not set, then already positive
    ; otherwise
    not  rax                ; flip low  quad words (1s' complement)
    not  rdx                ; flip high quad words (1s' complement)
    add  rax,1              ; increment for 2s' complement
    adc  rdx,0              ; carry     for 2s' complement
; upon reaching this label, (rdx:rax) is positive, with sign in r10
ITOA_NOW_POSITIVE:
; loop while dividing (rdx:rax) by radix (rsi)
ITOA_DIVIDE_INT_LOOP:
    ; (rax, rdx) = divmod((rdx:rax), rsi);
    idiv rsi                    ; divide (rdx:rax) by radix
    or   rdx,'0'                ; convert modulo to digit character
    mov  [r9],rdx               ; store the digit
    inc  r8                     ; count digits so far
    inc  r9                     ; next destination address
    test rax,-1                 ; if (!quotient)
    je   ITOA_DIVIDE_INT_END    ; then break
    call SIGN128                ; extend sign bit
    jmp  ITOA_DIVIDE_INT_LOOP   ; repeat
ITOA_DIVIDE_INT_END:
    test r10,-1             ; test sign bit
    je   ITOA_CLEANUP       ; if not set, skip adding '-'
    inc  r8                 ; extra character for '-'
    mov  rdx,'-'            ; set the '-'
    mov  [r9],rdx           ; append '-'
ITOA_CLEANUP:
    mov  rdx,r8         ; store string length
    pop  r10            ; restore general purpose
    pop  r9             ; restore general purpose
    pop  r8             ; restore general purpose
    ret
; end ITOA


; SIGN128(int *rdx, int rax)
; Copy the sign bit bit from rax over to rdx.
; @param
;   rdx : int * = pointer to higher quad word
; @param
;   rax : int   = lower  quad word
SIGN128:
    mov  rdx,rax                ; copy low bits into high bits
    sar  rdx,63                 ; shift sign bit through rdx
    ; done copying sign bit
    ret
; end SIGN128


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
REV_LEN:        equ ($ - REV_TEST)
; newline character
ENDL:           db 0ah
; radix (default decimal numbers)
RADIX:          equ 10
; array of integers to print
; (quad word, 64-bits)
ITOA_TEST:      dq 365,42,250,-1760
; number of integers to print
; ($ - ITOA_TEST) gives bytes,
; but each integer is a quad word = 8 bytes
ITOA_LEN:       equ (($ - ITOA_TEST)/8)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; allow 21 bytes for result of ITOA test (20 digits + sign)
ITOA_TEST_DST:  resb 21

