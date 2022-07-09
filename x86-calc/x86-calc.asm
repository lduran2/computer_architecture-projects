;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/blob/master/x86-calc/x86-calc.asm
; Addition calculator program.
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
    ; export the symbol _start
    global _start


; Beginning calculator program.
_start:
    ; initialize buffer state
    mov  rsi,IP_CBUF            ; running address to starting address
    mov  rcx,IP_CBUF.LEN        ; remaining length to maximum acceptable
    ; C equivalent: PROMPT_AND_GET_OPERANDS(&rsi, &rcx, &rdx, &rax);
    call PROMPT_AND_GET_OPERANDS    ; get user input for calculator
    ; perform the arithmetic operation
    mov  rcx,rax                ; backup operand 0 for printing
    add  rax,rdx                ; perform addition
    ; C equivalent: TO_STRING_AND_PRINT(rcx, rdx, rax);
    call TO_STRING_AND_PRINT    ; output the results
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov  rax,sys_exit       ; system call to perform
    mov  rdi,EXIT_SUCCESS   ; exit with no errors
    syscall     ; execute the system call
; end _start


; Handles when the end of the input is reached.
EXIT_END_OF_INPUT:
    ; C equivalent: write(FD_STDERR, END_OF_INPUT, END_OF_INPUT.LEN);
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    mov  rsi,END_OF_INPUT           ; move end label to print
    mov  rdx,END_OF_INPUT.LEN       ; length of end label
    syscall     ; execute the system call
    ; C equivalent: exit(-SIGHUP);
    ; exit without error
    mov  rax,sys_exit       ; system call to perform
    mov  rdi,-SIGHUP        ; exit with hang up signal
    syscall     ; execute the system call
; end EXIT_END_OF_INPUT


; PROMPT_AND_GET_OPERANDS(char **rsi, int *rcx, int *rdx, int *rax)
; Asks for and accepts the input for the calculator.
; @param
;   rsi : char **= running address in input buffer
; @param
;   rcx : int *= remaining length of the buffer
; @param
;   rdx : int *= address to store operand 1
; @param
;   rax : int *= address to store operand 0
PROMPT_AND_GET_OPERANDS:
    push r8                     ; backup general purpose for temp operand 0
    push r9                     ; backup general purpose for temp operand 1
    push rdi                    ; backup destination index for address buffer
    ; initialize buffer state
    mov  rdi,rsi                ; running address
    mov  rdx,rcx                ; remaining length
    ; accept operand 0
    ; PROMPT_INT_INPUT(&rdi, PROMPT_0, rcx, PROMPT_0.LEN, &rax);
    mov  rsi,PROMPT_0           ; prompt to print
    mov  rcx,PROMPT_0.LEN       ; #characters in prompt
    call PROMPT_INT_INPUT       ; print the prompt and accept user input
    mov  r8,rax                 ; temporarily store operand 0
    ; print blank line
    ; C equivalent: WRITELN(rdi, 0);
    push rdx                    ; backup running length for 0 characters
    mov  rdx,0                  ; 0 characters to print
    call WRITELN                ; print blank line
    pop  rdx                    ; restore running length
    ; accept operand 1
    ; PROMPT_INT_INPUT(&rdi, PROMPT_1, IP_CBUF.LEN, PROMPT_1.LEN, &rax);
    mov  rsi,PROMPT_1           ; prompt to print
    mov  rcx,PROMPT_1.LEN       ; #characters in prompt
    call PROMPT_INT_INPUT       ; print the prompt and accept user input
    mov  r9,rax                 ; temporarily store operand 1
    ; store buffer state
    mov  rsi,rdi                ; running address
    mov  rcx,rdx                ; remaining length
    ; wait to store operand 1 because rdx will be used for 0 characters
    ; print blank line
    ; C equivalent: WRITELN(rdi, 0);
    mov  rdx,0                  ; 0 characters to print
    call WRITELN                ; print blank line
    ; permanently each store operand
    mov  rax,r8                 ; operand 0
    mov  rdx,r9                 ; operand 1
    ; cleanup
    pop  rdi                    ; restore destination index
    pop  r9                     ; restore general purpose
    pop  r8                     ; restore general purpose
    ret
; end PROMPT_AND_GET_OPERANDS


; TO_STRING_AND_PRINT(int rcx, int rdx, int rax)
; Prints the statement of the operation.
; @param
;   rcx : int = operand 0
; @param
;   rdx : int = operand 1
; @param
;   rax : int = result of operation
TO_STRING_AND_PRINT:
    push r8                     ; backup for label array address
    push r9                     ; backup for label length array address
    push rdi                    ; backup for result address
    push rsi                    ; backup for radix
    ; we push the parameters in reverse
    push rax                    ; backup result
    push rdx                    ; backup operand 1 for sign
    push rcx                    ; backup operand 0
    ; initialize for loop
    mov  r8,OP_LBLS             ; initialize the label array address
    mov  r9,OP_LBL_LENS         ; initialize the label length array address
    mov  rcx,N_OPS              ; number of outputs
; loop through zipped labels and outputs
TO_STRING_AND_PRINT_LOOP:
    push rcx            ; guard from write changing rcx
    ; first print the label
    ; C equivalent: write(FD_STDOUT, *r8, *r9);
    ; print the prompt to standard output
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    mov  rsi,[r8]       ; ready label to print
    mov  rdx,[r9]       ; number of characters to print
    syscall     ; execute the system call
    pop  rcx            ; restore rcx
    ; next print the output
    pop  rax                    ; pop next output
    ; C equivalent: SIGN128(&rdx, rax);
    ; rax already set
    call SIGN128                ; extend the sign bit
    ; C equivalent: ITOA(INT_STR_REP, OP_RADIX, &rdx, rax);
    mov  rdi,INT_STR_REP        ; set the result address
    mov  rsi,OP_RADIX           ; set radix
    call ITOA                   ; convert to a string
    ; C equivalent: write(FD_STDOUT, rdi, rdx);
    push rcx            ; guard from write changing rcx
    mov  rsi,rdi        ; print the string representation
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    ; length rdx already set
    syscall     ; execute the system call
    pop  rcx            ; restore rcx
    ; iterate
    add  r8,QWORD_SIZE          ; next label
    add  r9,QWORD_SIZE          ; next length
    loop TO_STRING_AND_PRINT_LOOP       ; loop until no next output
TO_STRING_AND_PRINT_LOOP_END:
    ; end the printed statement
    ; C equivalent: WRITELN(OP_END_LBL, OP_END_LBL.LEN);
    mov  rsi,OP_END_LBL        ; move end label to print
    mov  rdx,OP_END_LBL.LEN    ; length of end label
    call WRITELN                    ; print end label
    ; cleanup
    pop  rsi                    ; restore source index
    pop  rdi                    ; restore destination index
    pop  r9                     ; restore general purpose
    pop  r8                     ; restore general purpose
    ret
; end TO_STRING_AND_PRINT


; PROMPT_INT_INPUT(int **rdi, char *rsi, int rdx, int rcx, int *rax)
; Displays a prompt, then accepts integer for input.
; The new value of rdi will be the new 
; @param
;   rdi : out int ** = address to buffer accepting integer input
; @param
;   rsi : in  char * = address to prompt to print
; @param
;   rdx : int = maximum length of input
; @param
;   rcx : int = exact length of output
; @param
;   rax : out int * = the integer read from standard input
PROMPT_INT_INPUT:
    push rsi            ; backup prompt to be replaced by current character
    ; print the prompt and get the input as a string
    ; C equivalent:
    ; PROMPT_INPUT(rdi, rsi, rdx, rcx);
    call PROMPT_INPUT           ; print the prompt
    ; seek for next none-space character
    ; C equivalent: SEEKNE(&rdi, &ISSPACE);
    mov  rax,ISSPACE            ; use ISSPACE for seeking
    call SEEKNE                 ; find first non-space character
    ; check if the current character is null
    mov  rsi,[rdi]          ; get the current character
    test rsi,7fh            ; check if null character
    jz   EXIT_END_OF_INPUT  ; if null, exit from end of input
    ; C equivalent: ATOI_SEEK(&rdi, IP_RADIX, INT_LEN, rdi);
    mov  rsi,IP_RADIX           ; set radix
    mov  rax,rdi                ; parse from rdi
    call ATOI_SEEK              ; convert to integer,
                                ;   changing address in buffer
    ; At this point: running address is in rax; integer is in rdi.
    ; So we use XOR to swap them.
    xor  rdi,rax
    xor  rax,rdi                ; rax now correct
    xor  rdi,rax                ; rdi now correct
    ; clean up
    pop  rsi            ; restore prompt
    ret
; end PROMPT_INT_INPUT


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
    ; C equivalent: write(FD_STDOUT, rsi, rdx);
    ; print the string in rsi
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, ENDL, 1);
    ; print the newline
    mov  rax,sys_write  ; system call to perform
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
    ; C equivalent: write(FD_STDOUT, rsi, rcx);
    ; print the prompt to standard output
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    ; prompt is alread at rsi
    mov  rdx,rcx        ; length of the prompt
    syscall     ; execute the system call
    ; C equivalent: read(FD_STDIN, r8, r9);
    ; accept user input into r8
    mov  rax,sys_read   ; system call to perform
    mov  rdi,FD_STDIN   ; file descriptor from which to read
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
    and  rsi,7fh            ; ignore all non-ASCII bits
    call rax                ; check if a space
    jne  SEEKNE_LOOP_END    ; if not, then use as a digit
    inc  rdi                ; otherwise, move to the next character
    jmp  SEEKNE_LOOP        ; repeat until not ZF
SEEKNE_LOOP_END:
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
    push rdx            ; backup the string length
    push rax            ; backup address of string representation
    call ATOI_SEEK      ; all the seeking algorithm
    pop  rax            ; restore the address of string representation
    pop  rdx            ; restore the string length
    ret

; ATOI_SEEK(int *rdi, int rsi, int *rdx, char **rax)
; Seeking implementation of ATOI.
; After this runs, *rax will be the address of the next whitespace or
; null character, and *rdx will represent the remaining length of the
; string.
; @see #ATOI
ATOI_SEEK:
    push rcx            ; backup counter
    push r8             ; flags a negative integer
    push r9             ; backup general purpose r9 for radix
    mov  rdi,0          ; initialize the integer
    mov  rcx,rdx        ; set counter to rdx
    mov  r8,0           ; reset negative flag
    mov  r9,rsi         ; free rsi for use as the current character
                        ; this makes isspace easier to use
ATOI_SIGN_CHAR:
    mov  rsi,[rax]          ; copy the character
    and  rsi,7fh            ; ignore all non-ASCII bits
    cmp  rsi,'-'            ; check if minus sign
    jne  ATOI_STR_LOOP      ; if not, skip to loop
    mov  r8,-1              ; otherwise, set negative integer flag
    inc  rax                ; next character
; loop through digits until whitespace or null
ATOI_STR_LOOP:
    mov  rsi,[rax]          ; copy the character
    test rsi,7fh            ; check if null character
    je   ATOI_STR_LOOP_END  ; break if all 0 ASCII bits
    and  rsi,7fh            ; ignore all non-ASCII bits
    call ISSPACE            ; if (space character),
    je   ATOI_STR_LOOP_END  ; then finish the loop
    ; otherwise
    test rsi,'@'            ; can the character be a single numeric digit?
    je   ATOI_NUMERIC       ; if so, go to numeric
ATOI_ALPHA:
    and  rsi,~'@'               ; disable '@' bits for integer value
    add  rsi,9                  ; all alpha characters after '9'
    jmp  ATOI_ACC_DIGIT         ; skip numeric
ATOI_NUMERIC:
    and  rsi,~'0'               ; disable '0' bits for integer value
; accumulate the next digit
ATOI_ACC_DIGIT:
    imul rdi,r9                 ; multiply the sum by the radix
    add  rdi,rsi                ; add the digit to the sum so far
    inc  rax                ; next character in source
    loop ATOI_STR_LOOP      ; repeat
ATOI_STR_LOOP_END:
; set the sign of the number
ATOI_INT_SIGN:
    test r8,-1              ; check (negative integer flag)
    je   ATOI_CLEANUP       ; if reset, skip to cleanup
    neg  rdi                ; otherwise, negate the integer
ATOI_CLEANUP:
    mov  rsi,r9         ; restore radix
    mov  rdx,rcx        ; update the remaining length
    pop  r9             ; restore general purpose
    pop  r8             ; restore general purpose
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
    je   ITOA_DIVIDE_INT_LOOP_END   ; then break
    ; C equivalent: SIGN128(&rdx, rax);
    call SIGN128                ; extend sign bit
    jmp  ITOA_DIVIDE_INT_LOOP   ; repeat
ITOA_DIVIDE_INT_LOOP_END:
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
STRREV_PUSH_LOOP_END:
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
STRREV_POP_LOOP_END:
    pop  r10            ; restore general purpose
    pop  r9             ; restore general purpose
    pop  r8             ; restore general purpose
    pop  rcx            ; restore counter
    ret
; end STRREV


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data

; System Call Constants:
;   system calls
sys_read:       equ 0
sys_write:      equ 1
sys_exit:       equ 60
;   file descriptor for STDIN
FD_STDIN:       equ 0
;   file descriptor for STDOUT
FD_STDOUT:      equ 1
;   file descriptor for STDERR
FD_STDERR:      equ 2
;   exit with no errors
EXIT_SUCCESS:   equ 0
;   hangup signal (end of input)
SIGHUP:         equ 1

; Constants:
;   newline character
ENDL:           db 0ah
;   each integer is a quad word = 8 bytes.
;   This is used because each address in x86-64 is
;   64-bits = 8 bytes = 1 quad word.
QWORD_SIZE:     equ 8
;   character length of a decimal integer (20 digits + sign)
INT_LEN:        equ 21
; radix for  input (defaults to decimal numbers)
IP_RADIX:       equ 10
; radix for output (defaults to decimal numbers)
OP_RADIX:       equ 10

; Error strings:
END_OF_INPUT:   db 0ah, "End of input was reached while parsing.", 0ah
END_OF_INPUT.LEN:   equ ($ - END_OF_INPUT)

; Calculator input:
;   prompt for user input for operand 1
PROMPT_0:       db "Please enter the augend.", 0ah, "> "
;   length of operand 1 prompt
PROMPT_0.LEN:   equ ($ - PROMPT_0)
;   prompt for user input for operand 2
PROMPT_1:       db "Please enter the addend.", 0ah, "> "
;   length of operand 2 prompt
PROMPT_1.LEN:   equ ($ - PROMPT_1)
;   array of calculator prompts
PROMPTS:        dq PROMPT_0, PROMPT_1
;   array of calculator prompt lengths
PROMPT_LENS:    dq PROMPT_0.LEN, PROMPT_1.LEN
;   #calculator prompts
N_PROMPTS:      equ (($ - PROMPT_LENS)/QWORD_SIZE)

; Calculator output:
;   label for operand 0
OP_LBL_0:       db ""
;   length of label for operand 0
OP_LBL_0.LEN:   equ ($ - OP_LBL_0)
;   label for operand 1
OP_LBL_1:       db " + "
;   length of label for operand 1
OP_LBL_1.LEN:   equ ($ - OP_LBL_1)
;   label for result
OP_LBL_2:       db " = "
;   length of label for result
OP_LBL_2.LEN:   equ ($ - OP_LBL_2)
;   array of output labels
OP_LBLS:        dq OP_LBL_0, OP_LBL_1, OP_LBL_2
;   array of output label lengths
OP_LBL_LENS:    dq OP_LBL_0.LEN, OP_LBL_1.LEN, OP_LBL_2.LEN
;   #calculator outputs
N_OPS:          equ (($ - OP_LBL_LENS)/QWORD_SIZE)
;   ending label of calculator outputs
OP_END_LBL:     db "."
;   length of calculator output ending label
OP_END_LBL.LEN:    equ ($ - OP_END_LBL)

; related to general user I/O
;   number of operations to allow
N_OPERATIONS:   equ 1
;   length of input buffer (2 space-separated integers/operation)
IP_CBUF.LEN:    equ (N_OPERATIONS * (2 * (INT_LEN + 1)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; character buffer for input
IP_CBUF:        resb IP_CBUF.LEN
; allocate space for string representations of integers
INT_STR_REP:    resb INT_LEN

