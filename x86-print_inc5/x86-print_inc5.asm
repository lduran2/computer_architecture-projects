;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/blob/master/x86-print_inc5/x86-print_inc5.asm
; Stores 5 in a register, increments the value and prints the result.
; This implementation uses the DUTOA procedure that we implemented.
;
; Additionally, this implementation prints the string directly from the
; stack.
; Leaving the string on the stack is risky because it risks the string
; being overwritten.  It's a useful optimization if the string will
; be used immediately.
;

; For this implementation, DUTOA was based off of DITOA, but optimized
; for unsigned integers.  Thus, the sign bit is assumed to be 0, which
; means that SIGN128 will not be needed.
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
;   outputs
;       at rcx, copies the instruction pointer rip
;       at r11, copies the flag register rflags
;
; sys_write
;   requires
;       rax for sys_write
;       rdi for the file descriptor of the stream to which to write
;       rsi for the address of character 0 of the string to write
;       rdx for the length of the string to write
;   see syscall
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
; rbp
;       as a convention, the base pointer register rbp is often used to
;       back up and restore the stack pointer register rsp in
;       procedures
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
;               size_t const INT_STR_REP_LEN;
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
;           after DUTOA / for WRITELN:
;               /* the address of the first qword of the string
;                * representation on stack.  Since the purpose is to
;                * print this string representation, this is also the
;                * address of the string to write.
;                *
;                * The type is a qword string.
;                * This works by placing a character every 8 bytes.
;                * Each intermediate byte is filled with a null
;                * character 0h.  Since sys_write requires a size in
;                * bytes, the whole string is printed, rather than
;                * being null-terminated.  This works in C as well.
;                */
;               int *int_str_rep;
;           after first syscall in WRITELN:
;               /* stores the line feed character */
;               char const *const ENDL = "\n";
;       rbp:
;               /* backs up the stack pointer */
;               /* (no C equivalent) */
;

; In this example, to convert and print the integer, we follow this diagram:
;
;                                         +-------+                +---------+
;                                         |       |                |         |
;                                         |       | ---> rsi ----->|         |
;                                         |       |       string   |         |
;                                         |       |       to print |         |
;            +-----+                      | DUTOA |       on stack | WRITELN |
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
    mov  r8,215                 ; store the value 5 in the register
    inc  r8                     ; increment the value
    ; convert to an ASCII character string
    mov  rax,r8                 ; copy r8 into rax
    ; now rax is ready for DUTOA
    call DUTOA                  ; perform Decimal Integer TO Ascii
    ; print the string representation on a line
    ; As a result of DUTOA,
    ;   rsi already points to the string on the stack.
    ;   rdx already contains its length.
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
; of storing it in a buffer because the stacks is last-in--first-out.
;
; @regist rsi : out char * = string converted from integer on stack
; @regist rdx : out int = length of string converted from integer
; @regist rax : int = lower quad word of integer to convert
DUTOA:
    mov  r9,0           ; initialize digit count
                        ; the # of digits extracted from the integer
    mov  r10,10         ; set up deciaml base for division
    mov  rbp,rsp        ; backup the stack pointer
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
    ; The digits in ASCII are in order and represented by the numbers
    ; 30h ('0') to 39h ('9').  Thus, adding '0' to the remainder will
    ; convert to an ASCII character.
    add  rdx,'0'                ; convert remainder to ASCII numeric digit
    push rdx                    ; store the digit at the top of the stack
    inc  r9                     ; count digits so far
    cmp  rax,0                  ; if (quotient != 0)
    jne  DUTOA_DIVIDE_INT_LOOP  ;       then repeat
DUTOA_DIVIDE_INT_LOOP_END:
    mov  rsi,rsp    ; store the current stack pointer in rsi
    mov  rsp,rbp    ; restore the stack pointer
    mov  rdx,r9     ; store string length (digit count) for sys_write
    ; the stack contains qwords
    imul rdx,QWORD_SIZE     ; so convert length to bytes
    ret
; end DUTOA


; WRITELN(void const *rsi, size_t rdx)
; Writes the given string followed by a newline character.
; @regist rsi : void const * = string to write on remainder of current line
; @regist rdx : size_t = length of the string `rsi`
WRITELN:
    ; C equivalent: write(FD_STDOUT, rsi, rdx);
    ; print the string in rsi
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, ENDL, 1u);
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
;   each integer is a quad word = 8 bytes.
;   This is used because each address in x86-64 is
;   64-bits = 8 bytes = 1 quad word.
QWORD_SIZE:     equ 8

