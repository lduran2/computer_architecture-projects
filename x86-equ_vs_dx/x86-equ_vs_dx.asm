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
    call PRINT_DB
    call PRINT_DW
    call PRINT_DD
    call PRINT_DQ
    call PRINT_DT
    call PRINT_EQU
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov rax,sys_exit        ; system call to perform: sys_exit
    mov rdi,EXIT_SUCCESS    ; errorlevel (0 = EXIT_SUCCESS)
    syscall     ; execute the system call
; end _start


; Prints the "define byte" string, and its length in a statement.
PRINT_DB:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, DB_LBL, DB_LBL.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DB_LBL          ; byte string to write
    mov rdx,DB_LBL.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DB_STRING, DB_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DB_STRING       ; byte string to write
    mov rdx,DB_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DB_END, DB_END.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DB_END          ; byte string to write
    mov rdx,DB_END.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; return now
    ret
; end PRINT_DB


; Prints the "define word" string, and its length in a statement.
PRINT_DW:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, LBL_X1, LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,LBL_X1          ; label beginning to write
    mov rdx,LBL_X1.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DW_STRING, DW_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DW_STRING       ; word string to write
    mov rdx,DW_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DW_END, DW_END.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DW_END          ; ending to write
    mov rdx,DW_END.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; return now
    ret
; end PRINT_DW


; Prints the "define doubleword" string, and its length in a statement.
PRINT_DD:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, LBL_X1, LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,LBL_X1          ; label beginning to write
    mov rdx,LBL_X1.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DD_STRING, DD_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DD_STRING       ; doubleword string to write
    mov rdx,DD_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DD_END, DD_END.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DD_END          ; ending to write
    mov rdx,DD_END.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; return now
    ret
; end PRINT_DD


; Prints the "define quadword" string, and its length in a statement.
PRINT_DQ:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, LBL_X1, LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,LBL_X1          ; label beginning to write
    mov rdx,LBL_X1.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DQ_STRING, DQ_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DQ_STRING       ; quadword string to write
    mov rdx,DQ_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DQ_END, DQ_END.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DQ_END          ; ending to write
    mov rdx,DQ_END.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; return now
    ret
; end PRINT_DQ


; Prints the "define ten bytes" string, and its length in a statement.
PRINT_DT:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, LBL_X1, LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,LBL_X1          ; label beginning to write
    mov rdx,LBL_X1.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DT_STRING, DT_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DT_STRING       ; ten-byte string to write
    mov rdx,DT_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DT_END, DT_END.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DT_END          ; ending to write
    mov rdx,DT_END.LEN      ; length of the string to write
    syscall     ; execute the system call
    ; return now
    ret
; end PRINT_DT


; Prints the length of the "equate" in a statement.
PRINT_EQU:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, LBL_X1, LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,EQU_LBL         ; label beginning to write
    mov rdx,EQU_LBL.LEN     ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, EQU_END, EQU_END.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,EQU_END         ; ending to write
    mov rdx,EQU_END.LEN     ; length of the string to write
    syscall     ; execute the system call
    ; return now
    ret
; end PRINT_EQU


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
;       STRING:   db "Hello world!"
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
DB_STRING:      db "Hello world!"
DB_STRING.LEN:  equ ($ - DB_STRING)

; example of string defined in words
;       dw      define word       =  2 bytes = 16 bits
DW_STRING:      dw "Hello world!"
DW_STRING.LEN:  equ ($ - DW_STRING)

; example of string defined in doublewords
;       dd      define doubleword =  4 bytes = 32 bits
DD_STRING:      dd "Hello world!"
DD_STRING.LEN:  equ ($ - DD_STRING)

; example of string defined in quadwords
;       dq      define quadword   =  8 bytes = 64 bits
DQ_STRING:      dq "Hello world!"
DQ_STRING.LEN:  equ ($ - DQ_STRING)

; example of string defined in ten bytes
;       dt      define ten bytes  = 10 bytes = 80 bits
; Note that character escaping (e.g., 0ah) would not work with dt.
DT_STRING:      dt "Hello world!"
DT_STRING.LEN:  equ ($ - DT_STRING)

; example of an equated value
EQU.LEN:        equ ($ - DQ_STRING.LEN)

; labels for the strings
; first string label beginning
DB_LBL:         db 22h
DB_LBL.LEN:     equ ($ - DB_LBL)
; all following strings label beginning
LBL_X1:         db " bytes.", 0ah, 22h
LBL_X1.LEN:     equ ($ - LBL_X1)
; labels endings
DB_END:         db 22h, " in bytes occupies "
DB_END.LEN:     equ ($ - DB_END)
DW_END:         db 22h, " in words occupies "
DW_END.LEN:     equ ($ - DW_END)
DD_END:         db 22h, " in doublewords occupies "
DD_END.LEN:     equ ($ - DD_END)
DQ_END:         db 22h, " in quadwords occupies "
DQ_END.LEN:     equ ($ - DQ_END)
DT_END:         db 22h, " in ten bytes occupies "
DT_END.LEN:     equ ($ - DT_END)
; label beginning and ending for equate
EQU_LBL:        db " bytes.", 0ah, "An equated value occupies ",
EQU_LBL.LEN:    equ ($ - EQU_LBL)
EQU_END:        db " bytes."
EQU_END.LEN:    equ ($ - EQU_END)

