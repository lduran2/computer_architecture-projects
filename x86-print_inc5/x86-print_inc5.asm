;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonical : https://github.com/lduran2/computer_architecture-projects/blob/master/x86-print_inc5/x86-print_inc5.asm
; Stores 5 in a register, increments the value and prints the result.
; This implementation uses the DITOA procedure that we implemented.
;

; For this implementation, we need DITOA.  Since DITOA depends on
; SIGN128 and STRREV, we will also need these.
; DITOA accepts a character buffer in rdi, which we will need to
; allocate in the .bss section.

; Since there are 16 characters, different system calls and procedures
; will expect a value to be at a specific register before the call.
; As a result, we must expect registers to be repurposed.

; In this example, we follow this diagram:
;
;                                                                                        +---------+
; sys_write --------------------------------------------------------------> rax -------->|         |
;  system call to perform                                                                |         |
;                                                                                        |         |
; FD_STDOUT --------------------------------------------------------------> rdi -------->|         |
;  file descriptor                                                                       |         |
;                                                         +-------------+                |         |
;                                                         |             |                |         |
;                                                         |  +-------+  |                | syscall |
;                                                         |  |       |  |                |         |
; INT_STR_REP ----------------------------------> rdi ----+->|       | -+-> rdi -> rsi ->|         |
;  buffer                          +---------+               |       |                   |         |
;                                  |         |               |       |                   |         |
;           +-----+                |         |               | DITOA |                   |         |
; 5 -> r8 ->| inc | -> r8 -> rax ->| SIGN128 | -> rdx:rax -->|       |                   |         |
;           +-----+     ìnteger    |         |     integer   |       |                   |         |
;                       to print   |         |     to print  |       | ---> rdx -------->|         |
;                       (64-bit)   |         |     (128-bit) |       |       length      |         |
;                                  +---------+               +-------+                   +---------+
; 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
    ; export the symbol _start
    global _start


; Beginning of the program.
_start:
    ; mutate the register
    mov  r8,5                   ; store the value 5 in the register
    inc  r8                     ; increment the value
    ; convert to an ASCII character string
    mov  rax,r8                 ; copy r8 into rax
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
    ; print a blank line
    ; C equivalent: write(FD_STDOUT, ENDL, 1);
    mov  rsi,ENDL               ; string to write
    mov  rdx,1                  ; 1 character to write
    syscall                     ; execute the system call
; label for end of the program
END:
    ; C equivalent: exit(EXIT_SUCCESS);
    ; exit without error
    mov  rax,sys_exit       ; system call to perform
    mov  rdi,EXIT_SUCCESS   ; exit with no errors
    syscall     ; execute the system call
; end _start


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
ENDL:           db 0ah
;   character length of a decimal integer (20 digits + sign)
INT_LEN:        equ 21


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This segment allocates memory to which to write.
section .bss
; allocate space for string representations of integers
INT_STR_REP:    resb INT_LEN

