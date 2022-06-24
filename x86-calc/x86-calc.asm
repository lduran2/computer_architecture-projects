;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/x86-calc/x86-calc.asm
; Addition calculator program.
;
; CHANGELOG :
;   v3.2.4 - 2022-06-24t18:34Q
;       implemented character seeking
;
;   v3.2.3 - 2022-06-24t15:57Q
;       running input address for ATOI
;
;   v3.2.2 - 2022-06-24t02:06Q
;       updated TEST_ATOI to use WRITELN
;
;   v3.2.1 - 2022-06-23t21:01Q
;       abstracted ATOI_SEEK, PROMPT_INPUT
;
;   v3.2.0 - 2022-06-23t19:35Q
;       ATOI stops at first space character
;
;   v3.1.6 - 2022-06-22t19:10Q
;       different radix for I/P, O/P
;
;   v3.1.5 - 2022-06-22t19:10Q
;       ATOI digit placing
;
;   v3.1.4 - 2022-06-22t18:40Q
;       ATOI = sum of digits
;       filtering out digits
;
;   v3.1.3 - 2022-06-22t17:36Q
;       ATOI = last digit
;
;   v3.1.2 - 2022-06-22t13:37Q
;       mock ATOI=0, fixed string rep to print
;
;   v3.1.1 - 2022-06-22t13:21Q
;       setting up calls needed for TEST_ATOI
;
;   v3.1.0 - 2022-06-22t03:26Q
;       just printing input with no processing
;
;   v3.0.0 - 2022-06-22t03:17Q
;       prompt for parse and echo (ATOI test)
;
;   v2.9.2 - 2022-06-24t01:38Q
;       updated TEST_ITOA to use WRITELN
;
;   v2.9.1 - 2022-06-22t13:47Q
;       just use high quad word for sign flag
;
;   v2.9.0 - 2022-06-22t02:28Q
;       ITOA pushes digits, inlines STRREV_POP_INIT
;
;   v2.8.0 - 2022-06-22t01:50Q
;       any positive radix for ITOA
;
;   v2.7.0 - 2022-06-22t01:24Q
;       fixed ITOA string order
;
;   v2.6.0 - 2022-06-21t23:13Q
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
;   v1.3.2 - 2022-06-24t01:20Q
;       fixed syscall, pop, ret in WRITELN
;
;   v1.3.1 - 2022-06-24t01:02Q
;       abstracted WRITELN
;
;   v1.3.0 - 2022-06-22t00:28Q
;       reverser can now be out of place
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
    jne  CHOOSE_MODE_ECHO       ;   check for ECHO
    call TEST_ITOA              ; else run TEST_ITOA
CHOOSE_MODE_ECHO:
    cmp  r8,3                   ; if (PROGRAM_MODE != 3)
    jne  CHOOSE_MODE_DEFAULT    ;   default
    call TEST_ATOI              ; else run TEST_ATOI
CHOOSE_MODE_DEFAULT:
    pop  r8             ; restore general purpose
    ret
; end CHOOSE_MODE


; Perform the calc program.
CALC:
    ret
; end CALC


; Test the ATOI function by parse and echo
TEST_ATOI:
    mov  rcx,2          ; count 2 times
    mov  r8,ECHO_IN     ; initialize running address of ECHO_IN
TEST_ATOI_LOOP:
    ; seek for the next digit
    mov  rsi,[r8]               ; get the next character
    call ISSPACE                ; check if a space
    jne  TEST_ATOI_LOOP_DIGIT   ; if not, then use as a digit
    inc  r8                     ; otherwise, move to the next character
    jmp  TEST_ATOI_LOOP         ; repeat until not a space
TEST_ATOI_LOOP_DIGIT:
    ; C equivalent:
    ;   PROMPT_INPUT(rdi, ECHO_PROMPT, INT_LEN, ECHO_PROMPT_LEN);
    push rcx            ; guard from write changing rcx
    mov  rdi,r8                 ; buffer address for storage
    mov  rdx,INT_LEN            ; acceptable buffer length
    mov  rsi,ECHO_PROMPT        ; prompt to print
    mov  rcx,ECHO_PROMPT_LEN    ; length of the prompt
    call PROMPT_INPUT           ; prompt for and accept integer to echo
    pop  rcx            ; restore rcx
    ; C equivalent: SEEKNE(&rdi, &ISSPACE);
    mov  rax,ISSPACE            ; use ISSPACE for seeking
    call SEEKNE                 ; find first non-space character
    ; C equivalent: ATOI_SEEK(&rdi, IP_RADIX, INT_LEN, rdi);
    mov  rsi,IP_RADIX           ; set radix
    mov  rax,rdi                ; parse from ECHO_IN
    call ATOI_SEEK
    ; update running address
    mov  r8,rax
    ; C equivalent: SIGN128(&rdx, rdi);
    mov  rax,rdi                ; copy the parsed integer into rax
    call SIGN128                ; extend the sign bit
    ; C equivalent: ITOA(ECHO_DST, OP_RADIX, &rdx, rax);
    mov  rdi,ECHO_DST           ; set the result address
    mov  rsi,OP_RADIX           ; set radix
    call ITOA                   ; convert to a string
    ; C equivalent: WRITELN(ECHO_DST, rdx);
    ; print the string representation of the integer
    mov  rsi,rdi        ; move the string representation to print
    call WRITELN        ; print the string representation of the integer
    loop TEST_ATOI_LOOP ; repeat until (rcx==0)
;    jmp  TEST_ATOI      ; repeat infinitely
    ret
; end TEST_ATOI


; Test the ITOA function on ITOA_TEST
TEST_ITOA:
    mov  r8,ITOA_TEST   ; initialize the integer address
    mov  rcx,ITOA_LEN   ; number of integers to test
; run each test
TEST_ITOA_TEST_LOOP:
    ; C equivalent: SIGN128(&rdx, *r8);
    mov  rax,[r8]               ; get the current number
    call SIGN128                ; extend sign bit
    ; C equivalent: ITOA(ITOA_TEST_DST, IP_RADIX, &rdx, *r8);
    mov  rdi,ITOA_TEST_DST      ; set result address
    mov  rsi,IP_RADIX           ; set radix
    call ITOA                   ; convert to a string
    ; C equivalent: WRITELN(ITOA_TEST_DST, rdx);
    ; print the last integer converted
    mov  rsi,rdi                ; move result string address to print
    ; the length is already ready from ITOA
    call WRITELN            ; print the string representation of the integer
    add  r8,QWORD_SIZE          ; next integer
    loop TEST_ITOA_TEST_LOOP    ; repeat
TEST_ITOA_TEST_END:
    ret
; end TEST_ITOA


; Test the STRREV function on REV_TEST.
TEST_STRREV:
    ; C equivalent: STRREV(REV_TEST_DST, REV_TEST, REV_LEN);
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


; WRITELN(char *rdi, int rdx)
; Writes the given string followed by a newline character.
; @param
;   rsi : char *= string to write, followed by a newline
; @param
;   rdx : int = length of the string rsi
WRITELN:
    ; set up
    push rcx            ; guard from write changing rcx
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
    pop  rcx            ; restore rcx
    ret
; end WRITE_LINE


; PROMPT_INPUT(char *rdi, char *rsi, int rdx, int rcx)
; Displays a prompt, then accepts input.
; @param
;   rdi : out char * = address to buffer accepting input
; @param
;   rsi : in  char * = address to prompt to print
; @param
;   rdx : int = maximum length of input
; @param
;   rcx : int = exact length of output
PROMPT_INPUT:
    ; preparation
    push rcx            ; guard from syscall changing rcx
    push rax            ; backup to hold the system call
    push rsi            ; backup to be replaced by rdi
    push r8             ; backup general purpose r8 for input buffer
    push r9             ; backup general purpose r9 for input length
    mov  r8,rdi         ; backup input buffer address
    mov  r9,rdx         ; backup input buffer length
    ; C equivalent: write(1, rsi, rcx);
    ; print the prompt to standard output
    mov  rax,1          ; system call to perform: sys_write
    mov  rdi,1          ; file descriptor to which to print, namely:
                        ; STDOUT (standard output)
    ; prompt is alread at rsi
    mov  rdx,rcx        ; length of the prompt
    syscall     ; execute the system call
    ; C equivalent: read(0, r8, r9);
    ; accept user input into r8
    mov  rax,0          ; system call to perform: sys_read
    mov  rdi,0          ; file descriptor to which to print, namely:
                        ; STDOUT (standard output)
    mov  rsi,r8         ; buffer address for storage
    mov  rdx,r9         ; acceptable buffer length
    syscall     ; execute the system call
    ; clean up
    mov  rdi,r8         ; restore input buffer address
    mov  rdx,r9         ; restore input buffer length
    pop  r9             ; restore general purpose
    pop  r8             ; restore general purpose
    pop  rsi            ; restore prompt address
    pop  rax            ; restore rax
    pop  rcx            ; guard from syscall changing rcx
    ret
; end PROMPT_INPUT


; SEEKNE(char **rdi, void (*rax)(char rsi))
; SEEK Not Equal
; seeks in the string *rdi until the function rax does not set ZF.
; @param
;   rdi : char **= pointer to string to search
; @param
;   rax : void (*)(char rsi) = pointer to address of 
SEEKNE:
    push rsi            ; backup rsi for current character
SEEKNE_LOOP:
    mov  rsi,[rdi]          ; get the next character
    and  rsi,0x7F           ; ignore all non-ASCII data
    call rax                ; check if a space
    jne  SEEKNE_END         ; if not, then use as a digit
    inc  rdi                ; otherwise, move to the next character
    jmp  SEEKNE_LOOP        ; repeat until not ZF
SEEKNE_END:
    pop  rsi            ; restore rsi
    ret
; end SEEKNE


; ATOI(int *rdi, int rsi, int rdx, char *rax)
; Ascii TO Integer
; parses an integer from its ASCII string representation.
; @param
;   rdi : out int * = pointer to the integer
; @param
;   rsi : int = radix of the integer
; @param
;   rdx : int = length of string to parse
; @param
;   rax : in  char * = string representation of the integer to parse
ATOI:
    push rax            ; backup address of string representation
    call ATOI_SEEK      ; all the seeking algorithm
    pop  rax            ; restore the address of string representation
    ret
; end ATOI


; ATOI_SEEK(int *rdi, int rsi, int rdx, char *rax)
; Seeking implementation of ATOI.
; After this runs, rax will be the address of the next whitespace or
; null character.
; @see #ATOI
ATOI_SEEK:
    push rcx            ; backup counter
    push r9             ; backup general purpose r9 for radix
    mov  rdi,0          ; initialize the integer
    mov  rcx,rdx        ; set counter to rdx
    mov  r9,rsi         ; free rsi for use as the current character
                        ; this makes isspace easier to use
ATOI_STR_LOOP:
    mov  rsi,[rax]          ; copy the character
    and  rsi,0x7F           ; ignore all non-ASCII data
    test rsi,-1             ; if (null character, all bits reset),
    je  ATOI_STR_END        ; then finish the loop
    call ISSPACE            ; if (space character),
    je  ATOI_STR_END        ; then finish the loop
    ; otherwise
    test rsi,'@'            ; can the character be a single numeric digit?
    je   ATOI_NUMERIC       ; if so, go to numeric
ATOI_ALPHA:
    and  rsi,~'@'               ; disable '@' bits for integer value
    add  rsi,9                  ; all alpha characters after '9'
    jmp  ATOI_ACC_DIGIT         ; skip numeric
ATOI_NUMERIC:
    and  rsi,~'0'               ; disable '0' bits for integer value
ATOI_ACC_DIGIT:
    imul rdi,r9                 ; multiply the sum by the radix
    add  rdi,rsi                ; add the digit to the sum so far
    inc  rax                ; next character in source
    loop ATOI_STR_LOOP      ; repeat
ATOI_STR_END:
    mov  rsi,r9         ; restore radix
    pop  r9             ; restore general purpose
    pop  rcx            ; restore counter
    ret
; end ATOI_SEEK


; ISSPACE(char rsi)
; Sets the equals/zero flag ZF if rsi is a whitespace character.
;
; These are any of: space (20h), form-feed ('\f' or 0ch), newline ('\n'
; or 0ah), carriage return ('\r' or 0dh), horizontal tab ('\t' or 09h),
; and vertical tab ('\v' or 0bh), i.e. the range [09h, 0dh].
;
; @param
;   rsi : char = character to test
; @see https://linux.die.net/man/3/isspace
ISSPACE:
    push r8             ; backup general purpose r8 for inverse flag
    cmp  rsi,0dh        ; check upper bound
    jg   ISSPACE_GT     ; if greater, check for 20h
    cmp  rsi,09h        ; check lower bound
    jl   ISSPACE_FALSE  ; not whitespace if less
ISSPACE_TRUE:
    mov  r8,0           ; set inverse to false
    jmp  ISSPACE_CHECKED    ; finished checking
ISSPACE_GT:
    cmp  rsi,20h        ; if (space),
    je  ISSPACE_TRUE    ; then space character
ISSPACE_FALSE:
    mov  r8,-1          ; set inverse to true
ISSPACE_CHECKED:
    test r8,-1          ; test the inverse, setting ZF accordingly
    pop  r8             ; restore general purpose
    ret
; end ISSPACE


; ITOA(char *rdi, int rsi, int *rdx, int rax)
; Integer TO Ascii
; converts an integer into an ASCII string representation.
; @param
;   rdi : out char * = string converted from integer
; @param
;   rsi : int = radix of the integer
; @param
;   rdx :
;       in  int * = upper quad word of integer to convert
;       out int * = length of string converted from integer
; @param
;   rax : int = lower quad word of integer to convert
ITOA:
    ; safeguard the radix
    push rsi            ; backup radix (replaced in ITOA_PUSH)
    call ITOA_IMPL      ; call the implementation
    pop  rsi            ; restore radix
    ret
; push the digits of the integer onto stack
; The digits will be backwards.
; Then inline STRREV_POP_INIT.
ITOA_IMPL:
    push rcx            ; for STRREV: backup counter
    push r8             ; backup general purpose r8 for digit count
    push r9             ; for STRREV: backup general purpose r9
                        ; for character
    push r10            ; backup general purpose r10 for sign register
    mov  r8,0           ; clear digit count
    mov  r10,rdx            ; copy high quad word into sign flag
    test r10,-1             ; test sign bit
    je   ITOA_NOW_POSITIVE  ; if not set, then already positive
    ; otherwise
    not  rax                ; flip low  quad word (1s' complement)
    not  rdx                ; flip high quad word (1s' complement)
    add  rax,1              ; increment for 2s' complement
    adc  rdx,0              ; carry     for 2s' complement
; upon reaching this label, (rdx:rax) is positive, with sign in r10
ITOA_NOW_POSITIVE:
; loop while dividing (rdx:rax) by radix (rsi)
; and pushing each digit onto the stack
ITOA_DIVIDE_INT_LOOP:
    ; (rax, rdx) = divmod((rdx:rax), rsi);
    idiv rsi                    ; divide (rdx:rax) by radix
    cmp  rdx,9                  ; can modulo be a single numeric digit?
    jle  ITOA_NUMERIC           ; if so, go to numeric
ITOA_ALPHA:
    sub  rdx,9                  ; how many digits after 9?
    or   rdx,'@'                ; set modulo to alpha digit
    jmp  ITOA_STORE_DIGIT       ; skip numeric
ITOA_NUMERIC:
    or   rdx,'0'                ; convert modulo to numeric digit
ITOA_STORE_DIGIT:
    push rdx                    ; store the digit
    inc  r8                     ; count digits so far
    test rax,-1                 ; if (!quotient)
    je   ITOA_DIVIDE_INT_END    ; then break
    ; C equivalent: SIGN128(&rdx, rax);
    call SIGN128                ; extend sign bit
    jmp  ITOA_DIVIDE_INT_LOOP   ; repeat
ITOA_DIVIDE_INT_END:
    test r10,-1             ; test sign bit
    je   ITOA_CLEANUP       ; if not set, skip adding '-'
    inc  r8                 ; extra character for '-'
    mov  rdx,'-'            ; set the '-'
    push rdx                ; append '-'
; reverse the string of digits
ITOA_CLEANUP:
    mov  rsi,rdi        ; use the string so far as the source
    mov  rdx,r8         ; store string length
    jmp  STRREV_POP_INIT    ; pop digits off the stack onto rdi
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
; push each character onto the stack
STRREV_PUSH_LOOP:
    mov  r9,[r8]            ; copy the character
    push r9                 ; push it onto stack
    inc  r8                 ; next character in source
    loop STRREV_PUSH_LOOP   ; repeat
STRREV_PUSH_END:
; initialize for popping each character
STRREV_POP_INIT:
    mov  rcx,rdx        ; set counter to rdx
    mov  r10,rdi        ; initialize the sink address
; pop each character off the stack
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
; Program modes:
;   0 - calculator
;   1 - test STRREV string reverser
;   2 - test itoa (integer to ASCII) for printing integers
;   3 - test atoi (ASCII to integer) for parse and echo
PROGRAM_MODE:   equ 3
; string to be reversed
REV_TEST:       db "Hello world!"
; length of REV_TEST
REV_LEN:        equ ($ - REV_TEST)
; newline character
ENDL:           db 0ah
; radix for  input (defaults to decimal numbers)
IP_RADIX:          equ 10
; radix for output (defaults to decimal numbers)
OP_RADIX:          equ 10
; each integer is a quad word = 8 bytes
QWORD_SIZE:     equ 8
; array of integers to print
; (quad word, 64-bits)
ITOA_TEST:      dq 365,42,250,-1760
; number of integers to print
; ($ - ITOA_TEST) gives #bytes,
; convert to #quad words
ITOA_LEN:       equ (($ - ITOA_TEST)/QWORD_SIZE)
; character length of a decimal integer (20 digits + sign)
INT_LEN:        equ 21
; prompt for user to enter integer
ECHO_PROMPT:    db "Please enter an integer in [-2^63, (2^63 - 1)].", 0ah, "> "
; length of prompt
ECHO_PROMPT_LEN:    equ ($ - ECHO_PROMPT)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; allocate space for reverser test results
REV_TEST_DST:   times REV_LEN resb 0
; allow 21 bytes for result of ITOA test
ITOA_TEST_DST:  resb INT_LEN
; buffer for input
ECHO_IN:        resb INT_LEN
; resulting string from echo
ECHO_DST:       resb INT_LEN

