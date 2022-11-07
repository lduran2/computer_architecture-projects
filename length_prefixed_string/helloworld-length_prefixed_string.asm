;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; helloworld-length_prefixed_string.asm
; Example program for printing a greeting in x86-64 assembly optimized
; for length-prefixed strings.  It includes a second test string.
;
; Length-prefixed strings are strings that include the length of the
; string as their first byte, so one finds the end of the string at
; address S with length S[0] at the address (S + 1 + S[0]). 
; They are also known as Pascal strings.
;
; This is in contrast with null-terminated strings or "C strings",
; which end in '\0' and where you would find the end of the string as
; the first null character.  This is also in contrast with
; (string, length) pairs, where the string and length are stored in two
; registers.
;
; The advantage of length-prefixed strings is that their address can be
; stored in one register, and there is no need to find the null
; terminator to find the end of the string.
;
; However, the disadvantages are that this will only work for strings
; that have at most ((2**8) - 1) = 255 characters because 255 is the
; maximum value that can be stored in a byte, and that each length-prefixed
; string requires 1 extra contiguous byte to store compared to
; (string, length) pairs.
;
; Date: 2022-10-23t17:36
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment stores the program.
section .text
    ; export the symbol _start
    ; _start is used for the start of the program in x86-64 assembly.
    global _start

; Beginning of the program to print a greeting.
_start:
    ; C equivalent: WRITE_LPS(GREETING);
    mov  rsi,GREETING       ; greeting length-prefixed string to print
    call WRITE_LPS          ; print the length-prefixed string
    ; C equivalent: WRITE_LPS(QUERY);
    mov  rsi,QUERY          ; query length-prefixed string to print
    call WRITE_LPS          ; print the length-prefixed string
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov  rax,sys_exit       ; system call to perform: sys_exit
    mov  rdi,EXIT_SUCCESS   ; errorlevel (0 = EXIT_SUCCESS)
    syscall     ; execute the system call
; end _start


; WRITE_LPS(void const *ref rsi)
; Writes the given length-prefixed string to STDOUT.
;
; LP.BUF_LEN is called.
; Additionally a system call is executed, resulting in
;       rcx <- rip,
;       r11 <- rflags.
;
; @regist rsi : void const *ref = string to write
; @see LP.BUF_LEN
WRITE_LPS:
    ; C equivalent: write(FD_STDOUT, &rsi[1], *rsi);
    call LP.BUF_LEN     ; separate the string and its length
    ; print the string now in rsi of length rdx
    mov  rax,sys_write  ; system call to perform
    mov  rdi,FD_STDOUT  ; file descriptor to which to write
    syscall     ; execute the system call
    ret
; end WRITE_LPS


; LP.BUF_LEN(void const *ref rsi, size_t const out rdx)
; Separate the given byte buffer and its length.
; Since the address at rsi is overwritten, it is important to keep another
; reference to it.
; @regist rsi : void const *ref = the byte buffer
; @regist rdx : size_t const out = length of the byte buffer
; @precondition:
;       rsi points to the length-prefix byte of the buffer
; @postcondition:
;       rsi will point to the first non-length byte in the buffer
;       rdx will contain the length of the byte buffer
LP.BUF_LEN:
    mov  rdx,[rsi]      ; get length of the byte buffer
    and  rdx,LSBYTE     ; ignore all but least significant byte
    inc  rsi            ; move to first byte in buffer
    ret
; end LP.BUF_LEN


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
;       GREETING:    db GREETING.LEN, "Hello world!", 0ah
;   moves the address forward 14 bytes:
;       + the byte defined by GREETING.LEN
;       + the length of "Hello world!"
;       + a newline character.
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
;   bitmask for least significant byte
LSBYTE:         equ 0ffh

; define bytes at GREETING as
;   + prefix of the string's total length
;   + the string "Good morning, world!"
;   + followed by the newline character '\x0a'
GREETING:       db GREETING.LEN, "Good morning, world!", 0ah
; calculate the length of GREETING giving GREETING.LEN.
; $ refers to the last byte of GREETING.
; Subtract (GREETING + 1) because the length is at GREETING[0]
GREETING.LEN:   equ ($ - (GREETING + 1))

; define bytes at QUERY as
;   + prefix of the string's total length
;   + the string "How are you?"
;   + followed by the newline character '\x0a'
QUERY:      db QUERY.LEN, "How are you?", 0ah
; calculate the length of QUERY giving QUERY.LEN.
QUERY.LEN:  equ ($ - (QUERY + 1))

