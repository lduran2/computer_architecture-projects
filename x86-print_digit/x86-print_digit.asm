;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/blob/master/x86-print_digit/x86-print_digit.asm
; Stores 5 in a register, increments the value and prints the result.
; This implementation shows how to print a single digit by adding '0'
; to the result.
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
;
; Special-purpose registers:
;       rdx:
;           for WRITELN :
;               /* the length of the string representation of the
;                * integer.  Since the purpose is to print this string
;                * representation, this is also the length of the string
;                * to write for WRITELN.
;                * We have exactly 1 digit, so length is 1.
;                */
;               enum { N_DIGITS = 1 };
;           after first syscall in WRITELN:
;               /* stores the length of ENDL (1) */
;               enum { ENDL_LEN = 1};
;       rax:
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
;           for WRITELN:
;               /* the address of the buffer for the string
;                * representation DIGIT_CBUF.  Since the purpose is to
;                * print this string representation, this is also the
;                * address of the string to write. */
;               char *digit_cbuf;
;           after first syscall in WRITELN:
;               /* stores the line feed character */
;               char const *const ENDL;
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
    mov  rsi,DIGIT_CBUF         ; set rsi to address of the string buffer
    ; convert to an ASCII character string
    ; The digits in ASCII are in order and represented by the numbers
    ; 30h ('0') to 39h ('9').  Thus, adding '0' to the r8 will convert
    ; to an ASCII character.
    add  r8,'0'                 ; convert to an ASCII character string
    mov  rsi[0],r8              ; place the digit in the buffer
    mov  rdx,1                  ; print 1 digit (1 character)
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


; WRITELN(char const *rsi, int rdx)
; Writes the given string followed by a newline character.
; @regist rsi : char const * = string to write on remainder of current
;       line
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; allocate space for string representations of integers
DIGIT_CBUF:    resb 1           ; C equivalent: char digit_cbuf[1L];

; Note that db (define bytes, e.g., ENDL) makes the label a pointer to
; an array of bytes having the given value, whereas resb (reserve
; bytes, e.g., DIGIT_CBUF) creates an array of the given size at the label.
;

