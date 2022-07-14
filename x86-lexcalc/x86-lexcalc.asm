;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/blob/master/x86-calc/x86-calc.asm
; Lexical addition calculator program.
;
; This implementation adds two numbers without first converting to
; integers.  So it is optimized for addition, and it is easily possible
; to modify for subtraction.
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
    ; export the symbol _start
    global _start


; Beginning calculator program.
_start:
    ; get the first 
    ; initialize buffer state
    mov  rsi,IP_CBUF            ; running address to starting address
    mov  rcx,IP_CBUF.LEN        ; remaining length to maximum acceptable
    ; C equivalent: PROMPT_AND_GET_STRINGS(&rsi, &rcx, &rdx, &rax);
    call PROMPT_AND_GET_STRINGS    ; get user input for calculator

    push rdx
    mov  rsi,r8
    mov  rdx,rax
    call WRITELN
    pop  rdx
    mov  rsi,rdi
    call WRITELN
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov  rax,sys_exit       ; system call to perform
    mov  rdi,EXIT_SUCCESS   ; exit with no errors
    syscall     ; execute the system call
; end _start


; PROMPT_AND_GET_STRINGS(char **rsi, int *rcx, char **rdi, int *rdx, char **r8, int *rax)
; Asks for and accepts the input, and returns it with its length and
; reverse.
; @param
;   rsi : char ** = running address in input buffer
; @param
;   rcx : int * = remaining length of the buffer
; @param
;   rdi : char ** = address to store operand 1
; @param
;   rdx : int * = length of operand 1
; @param
;   r8  : char ** = address to store operand 0
; @param
;   rax : int * = length of operand 0
PROMPT_AND_GET_STRINGS:
    push r9                     ; backup for temp operand 0 length
    push r13                    ; backup for temp operand 1 address
    push r14                    ; backup for temp operand 1 length
    ; initialize buffer state
    mov  rdi,rsi                ; running address
    mov  rdx,rcx                ; remaining length
    ; accept operand 0
    ; PROMPT_STR_INPUT(&rdi, PROMPT_0, &rcx, PROMPT_0.LEN, &rax);
    mov  rsi,PROMPT_0           ; prompt to print
    mov  rcx,PROMPT_0.LEN       ; #characters in prompt
    call PROMPT_STR_INPUT       ; print the prompt and accept user input
    ; temporarily store operand 0
    mov  r8,rax                 ; address
    mov  r9,rcx                 ; length
    ; print blank line
    ; C equivalent: WRITELN(rdi, 0);
    mov  rdx,0                  ; 0 characters to print
    call WRITELN                ; print blank line
    ; accept operand 1
    ; PROMPT_STR_INPUT(&rdi, PROMPT_1, &rcx, PROMPT_1.LEN, &rax);
    mov  rsi,PROMPT_1           ; prompt to print
    mov  rcx,PROMPT_1.LEN       ; #characters in prompt
    call PROMPT_STR_INPUT       ; print the prompt and accept user input
    ; temporarily store operand 1
    mov  r13,rax                ; address
    mov  r14,rcx                ; length
    ; print blank line
    ; C equivalent: WRITELN(rdi, 0);
    mov  rdx,0                  ; 0 characters to print
    call WRITELN                ; print blank line
    ; permanently store operand 0
    ; r8 already holds address
    mov  rax,r9                 ; length
    ; permanently store operand 1
    mov  rdi,r13                ; address
    mov  rdx,r14                ; length
    pop  r14                    ; restore general purpose
    pop  r13                    ; restore general purpose
    pop  r9                     ; restore general purpose
    ret
; end PROMPT_AND_GET_STRINGS


; PROMPT_STR_INPUT(char **rdi, char *rsi, int rdx, int *rcx, char *rax)
; Displays a prompt, then accepts a string for input.
; @param
;   rdi : out char ** = address to buffer accepting input
; @param
;   rsi : in  char * = address to prompt to print
; @param
;   rdx : int = maximum length of input
; @param
;   rcx : in  int * = exact length of prompt
;       : out int * = exact length of string token found
; @param
;   rax : char * = address of the string
PROMPT_STR_INPUT:
    ; print the prompt and get the input as a string
    ; C equivalent:
    ; PROMPT_INPUT(rdi, rsi, rdx, rcx);
    call PROMPT_INPUT           ; print the prompt
    ; find the next token in the input
    ; NEXT_TOKEN(rdi, rcx, rax);
    call NEXT_TOKEN
    ; output the string found
    ret
; end PROMPT_STR_INPUT


; NEXT_TOKEN(char **rdi, int *rcx, char *rax)
; Finds the next space-separated token  in the input buffer rdi.
; @param
;   rdi : out char ** = address to buffer accepting input
; @param
;   rcx : out int * = exact length of string token found
; @param
;   rax : char * = address of the string
NEXT_TOKEN:
    push rsi                ; backup source index for current character
    ; seek for next none-space character
    ; C equivalent: SEEKNE(&rdi, &ISSPACE);
    mov  rax,ISSPACE            ; use ISSPACE for seeking
    call SEEKNE                 ; find first non-space character
    ; check if the current character is null
    mov  rsi,[rdi]          ; get the current character
    test rsi,7fh            ; check if null character
    jz   EXIT_END_OF_INPUT  ; if null, exit from end of input
    mov  rax,rdi            ; store the current address
    mov  rcx,0              ; initialize length
    ; find the length of the input
NEXT_TOKEN_LEN_LOOP:
    inc  rdi                            ; next character
    inc  rcx                            ; increment length
    mov  rsi,[rdi]                      ; copy the character
    test rsi,7fh                        ; check if null character
    jz   NEXT_TOKEN__LEN_LOOP_END       ; break if all 0 ASCII bits
    and  rsi,7fh                        ; ignore all non-ASCII bits
    call ISSPACE                        ; if (space character),
    jz   NEXT_TOKEN__LEN_LOOP_END       ; then finish the loop
    jmp  NEXT_TOKEN_LEN_LOOP            ; repeat
NEXT_TOKEN__LEN_LOOP_END:
    pop  rsi                ; backup source index for current character
    ret
; end NEXT_TOKEN


; WRITELN(char *rsi, int rdx)
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


; Handles when the end of the input is reached.
EXIT_END_OF_INPUT:
    ; C equivalent: write(FD_STDOUT, END_OF_INPUT, END_OF_INPUT.LEN);
    ; Note: We use STDOUT here, instead of STDERR because the
    ;   compiler may be inconsistent.
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
;   Although the compiler may be inconsistent, so we will stick
;       to STDOUT.
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
;   maximum length for input
MAX_IP_LEN:     equ 255

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
IP_CBUF.LEN:    equ (N_OPERATIONS * (2 * (MAX_IP_LEN + 1)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; character buffer for input
IP_CBUF:        resb IP_CBUF.LEN
; the result of the operation to output
OP_RESULT:      resb MAX_IP_LEN

