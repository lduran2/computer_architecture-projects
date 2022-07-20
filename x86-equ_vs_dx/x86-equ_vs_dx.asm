;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; x86-equ_vs_dx.asm
; Comparison of all defines (db, dw, dd, dq, dt) and equate (equ).
; Date: 2022-07-20t17:00
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the program.
section .text
    ; export the symbol _start
    ; _start is used for the start of the program in x86-64 assembly.
    global _start

; Beginning of the program to print a greeting.
_start:
    ; C equivalent: write(FD_STDOUT, DB_STRING, DB_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    mov rsi,DB_STRING       ; byte string to write
    mov rdx,DB_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DW_STRING, DW_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    mov rsi,DW_STRING       ; word string to write
    mov rdx,DW_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DD_STRING, DD_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    mov rsi,DD_STRING       ; word string to write
    mov rdx,DD_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DQ_STRING, DQ_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    mov rsi,DQ_STRING       ; word string to write
    mov rdx,DQ_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; ; C equivalent: write(FD_STDOUT, DT_STRING, DT_STRING.LEN);
    ; ; print the greeting to standard output
    ; mov rax,sys_write       ; system call to perform: sys_write
    ; mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; mov rsi,DT_STRING       ; word string to write
    ; mov rdx,DT_STRING.LEN   ; length of the string to write
    ; syscall     ; execute the system call
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov rax,sys_exit        ; system call to perform: sys_exit
    mov rdi,EXIT_SUCCESS    ; errorlevel (0 = EXIT_SUCCESS)
    syscall     ; execute the system call
; end _start


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the data to be used in the program.
section .data

;   This example compares all defines, as well as equ.
;
;   Note that db will provide the best fit because strings are defined
;   as arrays of characters, and an ASCII character will fit in 1 byte.
;
;   Note that while "define" allocates space, "equate" loads a symbol
;   into the symbol table.  Thus, after "equate", the address is the
;   same as before it, whereas after "define", the address is moved
;   forward as much as the definition required;  e.g.,
;       STRING:   db "Hello world!", 0ah
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

; example of string defined in bytes
;       db      define byte       =  1 byte  =  8 bits
DB_STRING:      db "Hello world!", 0ah
DB_STRING.LEN:  equ ($ - DB_STRING)

; example of string defined in words
;       dw      define word       =  2 bytes = 16 bits
DW_STRING:      dw "Hello world!", 0ah
DW_STRING.LEN:  equ ($ - DW_STRING)

; example of string defined in doublewords
;       dd      define doubleword =  4 bytes = 32 bits
DD_STRING:      dd "Hello world!", 0ah
DD_STRING.LEN:  equ ($ - DD_STRING)

; example of string defined in quadwords
;       dq      define quadword   =  8 bytes = 64 bits
DQ_STRING:      dq "Hello world!", 0ah
DQ_STRING.LEN:  equ ($ - DQ_STRING)

; ; example of string defined in ten bytes
; ;       dt      define ten bytes  = 10 bytes = 80 bits
; DT_STRING:      dt "Hello world!", 0ah
; DT_STRING.LEN:  equ ($ - DT_STRING)

; example of an equated value
EQU.LEN:        equ ($ - DQ_STRING.LEN)

; labels for the strings
DB_LBL:         db 22h, "Hello world!", 22h, " in bytes occupies "
DB_LBL.LEN:     equ ($ - DB_LBL)
DW_LBL:         db " bytes.", 0ah, 22h, "Hello world!", 22h, " in words occupies "
DW_LBL.LEN:     equ ($ - DW_LBL)
DD_LBL:         db " bytes.", 0ah, 22h, "Hello world!", 22h, " in doublewords occupies "
DD_LBL.LEN:     equ ($ - DD_LBL)
DQ_LBL:         db " bytes.", 0ah, 22h, "Hello world!", 22h, " in quadwords occupies "
DQ_LBL.LEN:     equ ($ - DQ_LBL)
DT_LBL:         db " bytes.", 0ah, 22h, "Hello world!", 22h, " in ten bytes occupies "
DT_LBL.LEN:     equ ($ - DT_LBL)
EQU_LBL:        db " bytes.", 0ah, "An equated value occupies ",
EQU_LBL.LEN:    equ ($ - EQU_LBL)
END_LBL:        db " bytes."
END_LBL.LEN:    equ ($ - END_LBL)

