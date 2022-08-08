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
    ; C equivalent: write(FD_STDOUT, DB_STR_LBL, DB_STR_LBL.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DB_STR_LBL      ; byte string to write
    mov rdx,DB_STR_LBL.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DB_STRING, DB_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DB_STRING       ; byte string to write
    mov rdx,DB_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DB_LEN_LBL, DB_LEN_LBL.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DB_LEN_LBL      ; byte string to write
    mov rdx,DB_LEN_LBL.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; convert length to an ASCII character string
    mov  rax,DB_STRING.LEN  ; move length into rax
    ; since r8 is 64-bit, we can sign extend to fill the higher 64-bits
    call SIGN128                ; perform sign extension
    ; now rdx:rax is ready for DITOA
    mov  rdi,INT_STR_REP        ; set rdi to address of the string buffer
    call DITOA                  ; perform Decimal Integer TO Ascii
    ; set up for the print statement . . .
    ; C equivalent: write(FD_STDOUT, rdi, rdx);
    ; we move rdi to rsi now because we will need rdi for FD_STDOUT
    mov  rsi,rdi                ; move the buffer to rsi for sys_write
    ; rdx already contains the length of the buffer
    ; as a result of DITOA
    mov  rax,sys_write          ; system call to perform
    mov  rdi,FD_STDOUT          ; file descriptor to which to write
    syscall                     ; execute the system call
    ; return
    ret
; end PRINT_DB


; Prints the "define word" string, and its length in a statement.
PRINT_DW:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, STR_LBL_X1, STR_LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,STR_LBL_X1      ; label beginning to write
    mov rdx,STR_LBL_X1.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DW_STRING, DW_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DW_STRING       ; word string to write
    mov rdx,DW_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DW_LEN_LBL, DW_LEN_LBL.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DW_LEN_LBL      ; ending to write
    mov rdx,DW_LEN_LBL.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; convert length to an ASCII character string
    mov  rax,DW_STRING.LEN  ; move length into rax
    ; since r8 is 64-bit, we can sign extend to fill the higher 64-bits
    call SIGN128                ; perform sign extension
    ; now rdx:rax is ready for DITOA
    mov  rdi,INT_STR_REP        ; set rdi to address of the string buffer
    call DITOA                  ; perform Decimal Integer TO Ascii
    ; set up for the print statement . . .
    ; C equivalent: write(FD_STDOUT, rdi, rdx);
    ; we move rdi to rsi now because we will need rdi for FD_STDOUT
    mov  rsi,rdi                ; move the buffer to rsi for sys_write
    ; rdx already contains the length of the buffer
    ; as a result of DITOA
    mov  rax,sys_write          ; system call to perform
    mov  rdi,FD_STDOUT          ; file descriptor to which to write
    syscall                     ; execute the system call
    ; return
    ret
; end PRINT_DW


; Prints the "define doubleword" string, and its length in a statement.
PRINT_DD:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, STR_LBL_X1, STR_LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,STR_LBL_X1      ; label beginning to write
    mov rdx,STR_LBL_X1.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DD_STRING, DD_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DD_STRING       ; doubleword string to write
    mov rdx,DD_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DD_LEN_LBL, DD_LEN_LBL.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DD_LEN_LBL      ; ending to write
    mov rdx,DD_LEN_LBL.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; convert length to an ASCII character string
    mov  rax,DD_STRING.LEN  ; move length into rax
    ; since r8 is 64-bit, we can sign extend to fill the higher 64-bits
    call SIGN128                ; perform sign extension
    ; now rdx:rax is ready for DITOA
    mov  rdi,INT_STR_REP        ; set rdi to address of the string buffer
    call DITOA                  ; perform Decimal Integer TO Ascii
    ; set up for the print statement . . .
    ; C equivalent: write(FD_STDOUT, rdi, rdx);
    ; we move rdi to rsi now because we will need rdi for FD_STDOUT
    mov  rsi,rdi                ; move the buffer to rsi for sys_write
    ; rdx already contains the length of the buffer
    ; as a result of DITOA
    mov  rax,sys_write          ; system call to perform
    mov  rdi,FD_STDOUT          ; file descriptor to which to write
    syscall                     ; execute the system call
    ; return
    ret
; end PRINT_DD


; Prints the "define quadword" string, and its length in a statement.
PRINT_DQ:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, STR_LBL_X1, STR_LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,STR_LBL_X1      ; label beginning to write
    mov rdx,STR_LBL_X1.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DQ_STRING, DQ_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DQ_STRING       ; quadword string to write
    mov rdx,DQ_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DQ_LEN_LBL, DQ_LEN_LBL.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DQ_LEN_LBL      ; ending to write
    mov rdx,DQ_LEN_LBL.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; convert length to an ASCII character string
    mov  rax,DQ_STRING.LEN  ; move length into rax
    ; since r8 is 64-bit, we can sign extend to fill the higher 64-bits
    call SIGN128                ; perform sign extension
    ; now rdx:rax is ready for DITOA
    mov  rdi,INT_STR_REP        ; set rdi to address of the string buffer
    call DITOA                  ; perform Decimal Integer TO Ascii
    ; set up for the print statement . . .
    ; C equivalent: write(FD_STDOUT, rdi, rdx);
    ; we move rdi to rsi now because we will need rdi for FD_STDOUT
    mov  rsi,rdi                ; move the buffer to rsi for sys_write
    ; rdx already contains the length of the buffer
    ; as a result of DITOA
    mov  rax,sys_write          ; system call to perform
    mov  rdi,FD_STDOUT          ; file descriptor to which to write
    syscall                     ; execute the system call
    ; return
    ret
; end PRINT_DQ


; Prints the "define ten bytes" string, and its length in a statement.
PRINT_DT:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, STR_LBL_X1, STR_LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,STR_LBL_X1      ; label beginning to write
    mov rdx,STR_LBL_X1.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DT_STRING, DT_STRING.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DT_STRING       ; ten-byte string to write
    mov rdx,DT_STRING.LEN   ; length of the string to write
    syscall     ; execute the system call
    ; C equivalent: write(FD_STDOUT, DT_LEN_LBL, DT_LEN_LBL.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,DT_LEN_LBL      ; ending to write
    mov rdx,DT_LEN_LBL.LEN  ; length of the string to write
    syscall     ; execute the system call
    ; convert length to an ASCII character string
    mov  rax,DT_STRING.LEN  ; move length into rax
    ; since r8 is 64-bit, we can sign extend to fill the higher 64-bits
    call SIGN128                ; perform sign extension
    ; now rdx:rax is ready for DITOA
    mov  rdi,INT_STR_REP        ; set rdi to address of the string buffer
    call DITOA                  ; perform Decimal Integer TO Ascii
    ; set up for the print statement . . .
    ; C equivalent: write(FD_STDOUT, rdi, rdx);
    ; we move rdi to rsi now because we will need rdi for FD_STDOUT
    mov  rsi,rdi                ; move the buffer to rsi for sys_write
    ; rdx already contains the length of the buffer
    ; as a result of DITOA
    mov  rax,sys_write          ; system call to perform
    mov  rdi,FD_STDOUT          ; file descriptor to which to write
    syscall                     ; execute the system call
    ; return
    ret
; end PRINT_DT


; Prints the length of the "equate" in a statement.
PRINT_EQU:
    mov rdi,FD_STDOUT       ; file descriptor to which to write
    ; C equivalent: write(FD_STDOUT, STR_LBL_X1, STR_LBL_X1.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,EQU_LBL         ; label beginning to write
    mov rdx,EQU_LBL.LEN     ; length of the string to write
    syscall     ; execute the system call
    ; convert equate length to an ASCII character string
    mov  rax,EQU_LEN        ; move length into rax
    ; since r8 is 64-bit, we can sign extend to fill the higher 64-bits
    call SIGN128                ; perform sign extension
    ; now rdx:rax is ready for DITOA
    mov  rdi,INT_STR_REP        ; set rdi to address of the string buffer
    call DITOA                  ; perform Decimal Integer TO Ascii
    ; set up for the print statement . . .
    ; C equivalent: write(FD_STDOUT, rdi, rdx);
    ; we move rdi to rsi now because we will need rdi for FD_STDOUT
    mov  rsi,rdi                ; move the buffer to rsi for sys_write
    ; rdx already contains the length of the buffer
    ; as a result of DITOA
    mov  rax,sys_write          ; system call to perform
    mov  rdi,FD_STDOUT          ; file descriptor to which to write
    syscall                     ; execute the system call
    ; C equivalent: write(FD_STDOUT, EQU_END, EQU_END.LEN);
    ; print the greeting to standard output
    mov rax,sys_write       ; system call to perform: sys_write
    mov rsi,EQU_END         ; ending to write
    mov rdx,EQU_END.LEN     ; length of the string to write
    syscall     ; execute the system call
    ; return
    ret
; end PRINT_EQU


; DITOA(char *rdi, int *rdx, int rax)
; Decimal Integer TO Ascii
; converts an integer into an ASCII string representation.
; This implementation is optimized for decimal integers.
; @param
;   rdi : out char * = string converted from integer
; @param
;   rdx :
;       in  int * = upper quad word of integer to convert
;       out int * = length of string converted from integer
; @param
;   rax : int = lower quad word of integer to convert
DITOA:
    push rsi            ; backup source index for reverse source
    call DITOA_IMPL     ; call the implementation
    pop  rsi            ; restore source index
    ret
; push the digits of the integer onto stack
; The digits will be backwards.
; Then inline STRREV_POP_INIT.
DITOA_IMPL:
    push rcx            ; for STRREV: backup counter
    push r8             ; backup general purpose r8 for digit count
    push r9             ; backup general purpose r9 for radix and
                        ; for character in STRREV
    push r10            ; backup general purpose r10 for sign register
    mov  r8,0           ; clear digit count
    mov  r9,10          ; set up radix for division
    mov  r10,rdx            ; copy high quad word into sign flag
    ; handle sign
    test r10,-1             ; test sign bit
    jz   DITOA_NOW_POSITIVE ; if reset, then already positive
    ; otherwise
    not  rax                ; flip low  quad word (1s' complement)
    not  rdx                ; flip high quad word (1s' complement)
    add  rax,1              ; increment for 2s' complement
    adc  rdx,0              ; carry     for 2s' complement
; upon reaching this label, (rdx:rax) is positive, with sign in r10
DITOA_NOW_POSITIVE:
; loop while dividing (rdx:rax) by radix (10)
; and pushing each digit onto the stack
DITOA_DIVIDE_INT_LOOP:
    ; (rax, rdx) = divmod((rdx:rax), 10);
    idiv r9                     ; divide (rdx:rax) by radix
    or   rdx,'0'                ; convert modulo to numeric digit
    push rdx                    ; store the digit
    inc  r8                     ; count digits so far
    test rax,-1                 ; if (!quotient)
    jz   DITOA_DIVIDE_INT_LOOP_END  ; then break
    ; C equivalent: SIGN128(&rdx, rax);
    call SIGN128                ; extend sign bit
    jmp  DITOA_DIVIDE_INT_LOOP  ; repeat
DITOA_DIVIDE_INT_LOOP_END:
    test r10,-1             ; test sign bit
    jz   DITOA_CLEANUP      ; if reset, skip adding '-'
    inc  r8                 ; extra character for '-'
    mov  rdx,'-'            ; set the '-'
    push rdx                ; append '-'
; reverse the string of digits
DITOA_CLEANUP:
    mov  rsi,rdi        ; use the string so far as the source
    mov  rdx,r8         ; store string length
    jmp  STRREV_POP_INIT    ; pop digits off the stack onto rdi
; end DITOA


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

; Constants:
;   character length of a decimal integer (20 digits + sign)
INT_LEN:        equ 21

; example of string defined in bytes
;       db      define byte       =  1 byte  =  8 bits
DB_STRING:      db "Hello, world!"
DB_STRING.LEN:  equ ($ - DB_STRING)

; example of string defined in words
;       dw      define word       =  2 bytes = 16 bits
DW_STRING:      dw "Hello, world!"
DW_STRING.LEN:  equ ($ - DW_STRING)

; example of string defined in doublewords
;       dd      define doubleword =  4 bytes = 32 bits
DD_STRING:      dd "Hello, world!"
DD_STRING.LEN:  equ ($ - DD_STRING)

; example of string defined in quadwords
;       dq      define quadword   =  8 bytes = 64 bits
DQ_STRING:      dq "Hello, world!"
DQ_STRING.LEN:  equ ($ - DQ_STRING)

; example of string defined in ten bytes
;       dt      define ten bytes  = 10 bytes = 80 bits
; Note that character escaping (e.g., 0ah) would not work with dt.
DT_STRING:      dt "Hello, world!"
DT_STRING.LEN:  equ ($ - DT_STRING)

; example of an equated value
; BEFORE_EQU must contain at least 1 byte
; so we give it 1 byte
BEFORE_EQU:     db 0
EQU_TEST:       equ 1000000
; since equ contains one byte, we measure from after that byte
EQU_LEN:        equ ($ - (BEFORE_EQU + 1))

; labels for the strings
; first string
DB_STR_LBL:     db 22h
DB_STR_LBL.LEN: equ ($ - DB_STR_LBL)
; all following strings label
STR_LBL_X1:     db " byte(s).", 0ah, 22h
STR_LBL_X1.LEN: equ ($ - STR_LBL_X1)

; labels for lengths
DB_LEN_LBL:     db 22h, " in bytes occupies "
DB_LEN_LBL.LEN: equ ($ - DB_LEN_LBL)
DW_LEN_LBL:     db 22h, " in 2-byte words occupies "
DW_LEN_LBL.LEN: equ ($ - DW_LEN_LBL)
DD_LEN_LBL:     db 22h, " in 4-byte doublewords occupies "
DD_LEN_LBL.LEN: equ ($ - DD_LEN_LBL)
DQ_LEN_LBL:     db 22h, " in 8-byte quadwords occupies "
DQ_LEN_LBL.LEN: equ ($ - DQ_LEN_LBL)
DT_LEN_LBL:     db 22h, " in ten bytes occupies "
DT_LEN_LBL.LEN: equ ($ - DT_LEN_LBL)

; label beginning and ending for equate
EQU_LBL:        db " byte(s).", 0ah, "An equated value occupies ",
EQU_LBL.LEN:    equ ($ - EQU_LBL)
EQU_END:        db " byte(s)."
EQU_END.LEN:    equ ($ - EQU_END)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; allocate space for string representations of integers
INT_STR_REP:    resb INT_LEN

