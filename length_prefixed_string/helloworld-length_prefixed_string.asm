;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; helloworld-length_prefixed_string.asm
; Example program for printing a greeting in x86-64 assembly.
; This implementation is optimized for length-prefixed strings, and
; includes a second test string.
; Date: 2022-10-23t17:00
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the program.
section .text
    ; export the symbol _start
    ; _start is used for the start of the program in x86-64 assembly.
    global _start

; Beginning of the program to print a greeting.
_start:
    ; C equivalent: PRINT_LPS(GREETING);
    mov  rsi,GREETING       ; greeting string to write
    call PRINT_LPS          ;
    ; C equivalent: PRINT_LPS(QUERY);
    mov  rsi,QUERY          ; greeting string to write
    call PRINT_LPS          ;
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov  rax,sys_exit       ; system call to perform: sys_exit
    mov  rdi,EXIT_SUCCESS   ; errorlevel (0 = EXIT_SUCCESS)
    syscall     ; execute the system call
; end _start


; PRINT_LPS(char const *rsi)
; Writes the given length prefixed string.
; @regist rsi : char const * = string to write
PRINT_LPS:
    ; C equivalent: write(FD_STDOUT, &rsi[1], rsi[0]);
    ; separate the string and its length
    mov  rdx,[rsi]      ; get length of the string to write
    and  rdx,LSBYTE     ; ignore all but least significant byte
    inc  rsi            ; move to first byte in greeting
    ; print the string in rsi
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    syscall     ; execute the system call
    ret
; end PRINT_LPS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data

; Keywords used in the data section.
;   equ "equate" is the equivalent of a C macro;  e.g.,
;       sys_write:  equ 1
;   is equivalent to
;       #define sys_write (1)
;
;   db "define byte" allocates 1 byte.
;   It is the equivalent of a C character pointer;  e.g.,
;       GREETING:   db "Hello world!", 0ah
;   is equivalent to
;       const char *GREETING = "Hello world!\x0a";
;
;   including db for bytes, there are
;       db      define byte       =  1 byte  =  8 bits
;       dw      define word       =  2 bytes = 16 bits
;       dd      define doubleword =  4 bytes = 32 bits
;       dq      define quadword   =  8 bytes = 64 bits
;       dt      define ten bytes  = 10 bytes = 80 bits
;   Of these, db is important for strings because strings are defined
;   as arrays of characters, and an ASCII character will fit in 1 byte.
;   And dq is important for an array of pointers, because pointers in
;   x86-64 are 64 bits = 1 quadword.
;
;   Note that while "define" allocates space, "equate" loads a symbol
;   into the symbol table.  Thus, after "equate", the address is the
;   same as before it, whereas after "define", the address is moved
;   forward as much as the definition required;  e.g.,
;       GREETING:   db "Hello world!", 0ah
;   moves the address forward 13 bytes, the length of "Hello world!" +
;   a newline character.
;

; System Call Constants:
;   system calls
sys_write:      equ 1
sys_exit:       equ 60
;   file descriptor for STDOUT
FD_STDOUT:      equ 1
;   exit with no errors
EXIT_SUCCESS:   equ 0

; Constants used in program:
;   bitmask for least significant byte
LSBYTE:         equ 0ffh

; define bytes at GREETING as
;   - the string "Good morning, world!"
;   - followed by the newline character '\x0a'
;   - prefixed by its total length
GREETING:    db GREET_LEN, "Good morning, world!", 0ah
; calculate the length of GREETING giving GREET_LEN.
; $ refers to the last byte of GREETING.
; Subtract (GREETING + 1) because the length is at GREETING
GREET_LEN:   equ ($ - (GREETING + 1))

; define bytes at QUERY as
;   - the string "How are you?"
;   - followed by the newline character '\x0a'
;   - prefixed by its total length
QUERY:       db QUERY_LEN, "How are you?", 0ah
; calculate the length of QUERY giving QUERY_LEN.
QUERY_LEN:   equ ($ - (QUERY + 1))

