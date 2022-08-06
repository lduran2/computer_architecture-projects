;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/blob/master/x86-input_digit/x86-input_digit.asm
; Stores a digit read from standard input in a register, increments the
; value and prints the result.
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
;   requires
;       rax for the system call to perform
;   outputs
;       at rcx, copies the instruction pointer rip
;       at r11, copies the flag register rflags
;
; sys_read
;   requires
;       rax for sys_read
;       rdi for the file descriptor of the stream from which to read
;       rsi for the address of the buffer in which to store the string
;           read from the input stream
;       rdx for the capacity of the buffer
;   see syscall
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
;               enum { ENDL_LEN = 1 };
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
;                * representation OUTPUT_CBUF.  Since the purpose is to
;                * print this string representation, this is also the
;                * address of the string to write. */
;               char *output_cbuf;
;           after first syscall in WRITELN:
;               /* stores the line feed character */
;               char const *const ENDL = "\n";
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
    ; read in the digit from standard input
    ; C equivalent: read(FD_STDIN, INPUT_CBUF, 1u);
    mov  rax,sys_read           ; system call to perform
    mov  rdi,FD_STDIN           ; file descriptor from which to read
    mov  rsi,INPUT_CBUF         ; set rsi to address of the output buffer
    mov  rdx,1                  ; set to read 1 digit (1 character)
    syscall     ; execute the system call
    ; change the value of the register to print, r8
    mov  r8,rsi[0]              ; copy the digit from the input buffer
    inc  r8                     ; increment the value
    ; output
    mov  rsi,OUTPUT_CBUF        ; set rsi to address of the output buffer
    mov  rsi[0],r8              ; place the digit in the buffer
    mov  rdx,1                  ; set to print 1 digit (1 character)
    call WRITELN                ; print the string representation on a line
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    ; the following 3 lines end the program
    mov  rax,sys_exit       ; system call to perform
    mov  rdi,EXIT_SUCCESS   ; exit with no errors
    syscall     ; execute the system call
; end _start


; WRITELN(char const *rsi, size_t rdx)
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
sys_read:       equ 0
sys_write:      equ 1
sys_exit:       equ 60
;   file descriptor for STDIN
FD_STDIN:       equ 0
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
; allocate space for input
INPUT_CBUF:     resb 1          ; C equivalent: char input_cbuf[1u];
; allocate space for string representations of integers
OUTPUT_CBUF:    resb 1          ; C equivalent: char output_cbuf[1u];

; Note that db (define bytes, e.g., ENDL) makes the label a pointer to
; an array of bytes having the given value, whereas resb (reserve
; bytes, e.g., OUTPUT_CBUF) creates an array of the given size at the
; label.
;

