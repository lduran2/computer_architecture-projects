;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/blob/master/x86-print_inc5/x86-print_inc5.asm
; Stores 5 in a register, increments the value and prints the result.
; This implementation uses the DUTOA procedure that we implemented.
;

; For this implementation, DUTOA was based off of DITOA, but optimized
; for unsigned integers.  Thus, the sign bit is assumed to be 0, which
; means that SIGN128 will not be needed.  However, since DITOA also
; depends on STRREV_POP_INIT, we will also need this.
; DUTOA also accepts a character buffer in rsi, which we will need to
; allocate in the .bss section.
;
; We also included WRITELN to make printing easier.
;

; Since 16 registers are available, different system calls and procedures
; will expect a value to be at a specific register before the call.
; As a result, we must expect registers to be repurposed,
; but we will avoid this as much as possible.

;;;;;;;;;;;;;;;;;;;;;;;;;
; Required register use ;
;;;;;;;;;;;;;;;;;;;;;;;;;
;
; We are required to use these registers for these purposes.
; We will be using each of the following instructions.
;
; syscall requires
;       rax for the system call to perform
;
; sys_write
;   requires
;       rax for sys_write
;       rdi for the file descriptor of the stream to which to write
;       rsi for the address of character 0 of the string to write
;       rdx for the length of the string to write
;   outputs
;       at rcx, copies the instruction pointer rip
;       at r11, copies the flag register rflags
;
; sys_exit
;   requires
;       rax for sys_exit
;       rdi for the exit call (e.g., EXIT_SUCCESS)
;
; idiv
;   requires
;       rax for the  lower quad word (64-bits) of the 128-bit dividend
;       rdx for the higher quad word (64-bits) of the 128-bit dividend
;   outputs
;       at rax, the quotient
;       at rdx, the remainder
;
; push
;   output
;       at rsp, when a new value is added, the stack pointer moves back
;
; pop
;   output
;       at rsp, when a value is remove, the stack pointer moves forward
;
; call
;   output
;       at rsp, the address of the next instruction after call is
;           pushed onto stack
;
; ret
;   output
;       at rsp, pops the current value off the stack, then jumps to it
;
; loop
;   requires
;       rcx for the count down counter
;

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register->Variable map ;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; General-purpose registers:
;       r8 :
;           int to_print;   /* the original storage of 5,
;                            * also used for arithmetic */
;       r9 :
;           size_t tmp_n_digits;    /* temporary location for digit count */
;       r10:
;           enum { base = 10 }; /* the literal 10,
;                                * used for the base of decimal numbers */
;       r11:
;           /* unused because syscall stores rflags there */
;       r12:
;           size_t i_char;  /* index of current digit
;                            * in buffer INT_STR_REP */
;       r13:
;           char c; /* the current digit popped from the stack */
;
; Special-purpose registers:
;
; For rdx:rax, let's say that we have a structure
;       struct {
;           int hi_qword;
;           int lo_qword;
;       } dividend;
; then:
;       rdx:
;           in DUTOA_DIVIDE_INT_LOOP:
;               before idiv :
;                   /* the higher 64-bits of the dividend (rdx:rax),
;                    * always 0 since we expect a 64-bit unsigned
;                    * integer from input */
;                   dividend.hi_qword = 0;
;               after  idiv :
;                   /* the quotient of the division of dividend by 10 */
;                   int i_remainder;
;               after and/or:
;                   /* the ASCII digit converted from the remainder */
;                   char c_remainder;
;           after DUTOA_DIVIDE_INT_LOOP_END / for WRITELN :
;               /* the length of the string representation of the
;                * integer.  Since the purpose is to print this string
;                * representation, this is also the length of the string
;                * to write for WRITELN. */
;               size_t const N_DIGITS;
;           after first syscall in WRITELN:
;               /* stores the length of ENDL (1) */
;               enum { ENDL_LEN = 1 };
;       rax:
;           in DUTOA_DIVIDE_INT_LOOP:
;               before idiv :
;                   /* the  lower 64-bits of the dividend (rdx:rax) */
;                   dividend.lo_qword
;               after  idiv :
;                   /* the quotient of the division of dividend by 10 */
;                   int quotient;
;           for any syscall:
;               /* the system call to perform */
;               /* (no C equivalent) */
;       rdi:
;           for sys_write:
;               /* the file descriptor of the stream to which to write */
;               int fd = FD_STDOUT;
;           for sys_exit:
;               /* the exit code to return to shell */
;               int exit_status;
;       rsi:
;           for DUTOA / for WRITELN:
;               /* the address of the buffer for the string
;                * representation INT_STR_REP.  Since the purpose is to
;                * print this string representation, this is also the
;                * address of the string to write. */
;               char *int_str_rep;
;           after first syscall in WRITELN:
;               /* stores the line feed character */
;               char const *const ENDL = "\n";
;       rcx:
;           size_t k;  /* digit countdown counter in STRREV_POP_LOOP */
;

; In this example, to convert and print the integer, we follow this diagram:
;
;                                                                  +---------+
;                                      +-------------+             |         |
;                                      |             |             |         |
;                                      ^  +-------+  |             |         |
;                                      |  |       |  |             |         |
; INT_STR_REP --------> rsi -----------+->|       | -+-> rsi ----->|         |
;  buffer                                 |       |                | WRITELN |
;                                         |       |                |         |
;            +-----+                      | DUTOA |                |         |
; (5)-> r8 ->| inc | -> r8 -------> rax ->|       |                |         |
;            +-----+     ìnteger          |       |                |         |
;                        to print         |       | ---> rdx ----->|         |
;                        (64-bit)         |       |       length   |         |
;                                         +-------+                +---------+
;
;         Figure 1. Converting and printing an unsigned integer.
; 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
    ; export the symbol _start
    global _start
    ; Reminder that _start is the symbol that the shell expects to go
    ; to for the beginning of the program, and it must have global
    ; access to allow the shell access to it.
    ; myCompiler.io will give a warning if that is not the case.


; Beginning of the program.
_start:
    ; change the value of the register to print, r8
    mov  r8,5                   ; store the value 5 in the register
    inc  r8                     ; increment the value
    ; convert to an ASCII character string
    mov  rax,r8                 ; copy r8 into rax
    ; now rax is ready for DUTOA
    mov  rsi,INT_STR_REP        ; set rsi to address of the string buffer
    call DUTOA                  ; perform Decimal Integer TO Ascii
    ; print the string representation on a line
    ; rsi already contains the buffer from earlier.
    ; And as a result of DUTOA, rdx already contains its length.
    call WRITELN
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    ; the following 3 lines end the program
    mov  rax,sys_exit       ; system call to perform
    mov  rdi,EXIT_SUCCESS   ; exit with no errors
    syscall     ; execute the system call
; end _start


; DUTOA(out char *rsi, out int rdx, int rax)
; Decimal Unsigned integer TO Ascii
; converts an unsigned integer into a decimal ASCII string
; representation.
; This implementation is optimized for decimal unsigned integers.
;
; Digits are obtained from the remainder of the repeated division of
; the unsigned integer by 10.
;
; E.g.) Retrieving the digits from 214.
;   10 ) 214
;      -----
;    10 ) 21 R (4)->--+
;       ----          |
;     10 ) 2 R (1)->--)--+
;        ---          |  |
;          0 R (2)->--)--)--+
;                     |  |  |
;                     v  v  v
; Digits in memory: { 4, 1, 2 }.
;
; As a result the digits will be backwards.
; The plan is to push each digit of the integer onto the stack instead
; of storing it in the buffer because the stacks is last-in--first-out.
; Then inline STRREV_POP_INIT from a string reversing procedure to
; revert the digits to the proper order.
; This implementation has STRREV_POP_INIT directly after the
; DUTOA_DIVIDE_INT_LOOP_END.
;
; @regist rsi : char * = string converted from integer
; @regist rdx : out int = length of string converted from integer
; @regist rax : int = lower quad word of integer to convert
DUTOA:
    mov  r9,0           ; initialize digit count
                        ; the # of digits extracted from the integer
    mov  r10,10         ; set up deciaml base for division
; loop while dividing (rdx:rax) by base (10)
; and pushing each digit onto the stack
DUTOA_DIVIDE_INT_LOOP:
    ; Since idiv operates on 128-bit (rdx:rax), rdx must be assigned.
    ; rdx must be reassigned at the beginning of each iteration because
    ; at the end, it will contain the remainder of the last division
    mov  rdx,0                  ; assign 0 because rax is unsigned
    ; Divide (rdx:rax) by 10.
    ; idiv will store the quotient in rax, and the remainder in rdx.
    idiv r10                    ; perform the division
    ; To convert the remainder to a digit, perform an OR operation
    ; with '0'.  An ASCII character is 7-bits, the higher 3 bits
    ; categorize the character.
    ; These categories, their higher 3 bits and the ASCII equivalent of
    ; the lower bound are:
    ;   control characters : 000-001    00h (null character)
    ;   symbols            : 010        20h (space character)
    ;   numbers            : 011        '0' (zero)
    ;   uppercase letters  : 100-101    '@' (at symbol)
    ;   lowercase letters  : 110-111    '`' (backtick)
    ; Masking for the lower 4 bits (or lower byte) and setting the
    ; higher 3 bits with an OR with '0' will convert to a digit. 
    ; Although the masking is unnecessary in this case because the
    ; digits are all modulo 10 as a remainder of a positive number and
    ; 10, which is also positive.
    ;
    ; convert remainder to numeric digit
    and  rdx,0fh                ; mask the lower byte
    or   rdx,'0'                ; OR with '0' sets higher 3 bits to 011
    push rdx                    ; store the digit at the top of the stack
    inc  r9                     ; count digits so far
    cmp  rax,0                  ; if (quotient != 0)
    jne  DUTOA_DIVIDE_INT_LOOP  ;       then repeat
DUTOA_DIVIDE_INT_LOOP_END:
    mov  rdx,r9     ; store string length (digit count) for sys_write
; reverse the string of digits
STRREV_POP_INIT:
    mov  rcx,rdx        ; set counter to string length (digit count)
    mov  r12,0          ; index of the current character (digit) in the
                        ; destination
    ; Reminder: We skip register r11 because it is used by syscall.
; pop each character (digit) off the stack
STRREV_POP_LOOP:
    ; The loop instruction performs a countdown to 0, which always uses
    ; rcx as the loop variable.
    ; So the C equivalent to loop <any label>:
    ;   for (; (rcx != 0); --rcx) { <...> }
    ;
    ; loop invariant:
    ; At this point in this loop it's always the case that
    ;       rcx + r12 = rdx.
    pop  r13                ; pop the next character (digit) from the stack
                            ; and store it in register r13
    mov  rsi[r12], r13      ; place the character (digit) at the index.
    ; This rsi[r12] syntax is very similar to a C array.
    ; An alternative syntax is [rsi+r12], used in DITOA, which treats
    ; the operand of the brackets [] as a pointer. 
    ; The C equivalent would be *(rsi+r12).
    inc  r12                ; next index of character in destination
    loop STRREV_POP_LOOP    ; repeat (rdx) times using loop rcx as variable
STRREV_POP_LOOP_END:
    ret
; end DUTOA


; WRITELN(char const *rsi, int rdx)
; Writes the given string followed by a newline character.
; @regist rsi : char const * = string to write on remainder of current line
; @regist rdx : int = length of the string `rsi`
WRITELN:
    ; C equivalent: write(FD_STDOUT, rsi, rdx);
    ; print the string in rsi
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, ENDL, 1);
    ; print the newline
    mov  rax,sys_write  ; system call to perform
    mov  rsi,ENDL       ; newline to print
    mov  rdx,1          ; 1 character (newline) to print
    syscall     ; execute the system call
    ret
; end WRITELN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data

; System Call Constants:
;   system calls
sys_write:      equ 1
sys_exit:       equ 60
;   file descriptor for STDOUT
FD_STDOUT:      equ 1
;   exit with no errors
EXIT_SUCCESS:   equ 0

; Constants:
;   newline character
ENDL:           db 0ah  ; C equivalent: char const *const ENDL = "\n";
;   character length of a decimal integer (20 digits + sign)
INT_LEN:        equ (20 + 1)

; INT_LEN will be used as the length to allocate the buffer
; INT_STR_REP.
;
; Reminder that INT_LEN above is like a C language macro.  In C,
; macros are expanded in the preprocessing step of the compilation
; process;  in Assembly, it is a similar process, but the label
; (e.g., INT_LEN) instead becomes a synonym for the given value
; (e.g., (20 + 1)) in the symbol table used to assemble the program.
; Thus, it would not be possible to wait until runtime to define a size
; INT_LEN for INT_STR_REP using a register.  By then it would be too
; late!  So instead, we give INT_LEN a maximum value (20 digits + sign)
; that we can expect for a 64-bit number.
;
; Also reminder that equ (equations) like INT_LEN do not take up space
; in memory during runtime.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; allocate space for string representations of integers
INT_STR_REP:    resb INT_LEN    ; C equivalent:
                                ; char int_str_rep[(size_t)INT_LEN];

; Note that db (define bytes, e.g., ENDL) makes the label a pointer to
; an array of bytes having the given value, whereas resb (reserve
; bytes, e.g., INT_STR_REP) creates an array of the given size at the label.
;

