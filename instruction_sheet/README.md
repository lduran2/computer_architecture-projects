# Instruction Sheet for 8086, 64-BIT HMOS MICROPROCESSOR

## Registers

## Instruction Set

| Mnemonic | Addressing Mode | Instruction | Syntax | Example | Argument  | Argument Description | Side effect |
|----------|-------------|-----------------|--------|---------|-----------|----------------------|-------------|
| `mov`    | Intermediate to Register | Move a value into a register | `mov <register-out>, <value-in>` | `mov rax, sys_write` | `register-out` | the register to which to write | N/A
|          |                          |                              |                           |                      | `value-in`    | the value to write into the register |
| `push` | from Register | Push a value from a register unto the stack | `push <register-in>` | `push rdx` | `register-in` | the register whose value to push onto the stack | `rsp` is decreased by ?? |
| `pop` | to Register | Pop a value from the stack into a register | `pop <register-out>` | `pop r13` | `register-out` | the register into which to pop | `rsp` is increased by ?? |
| `int` | N/A | Perform an interrupt. | `int <code>` | `int 80h` | `code` | the code of the interrupt to perform | `[1]` |
| `syscall` | N/A | Perform a system call interrupt. | `syscall` | `syscall` | N/A | N/A | `rcx <- rip` |
|           |  |                                  |           |           |  |  | `r11 <- rflags` |

`[1]` Interrupts may affect specific registers.  Please see the documentation for that specific interrupt.
