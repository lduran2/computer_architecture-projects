# Instruction Sheet for 8086, 64-BIT HMOS MICROPROCESSOR

## Registers

## Instruction Set

| Mnemonic | Addressing Mode | Instruction | Syntax | Example | Argument  | Argument Description | Side effect |
|----------|-------------|-----------------|--------|---------|-----------|----------------------|-------------|
| **DATA TRANSFER**
| `mov`    | Intermediate to Register | Move a value into a register | `mov <register-out>, <value-in>` | `mov rax, sys_write` | `register-out` | the register to which to write | N/A
|          |                          |                              |                           |                      | `value-in`    | the value to write
| `mov`    | Memory from Register | Stores contents of a register into RAM | `mov [<address-out>], <register-in>` | `mov rsi[0], r8` | `address-out` | the address at which to write | N/A
|          |                          |                              |                           |                      | `register-in`    | register containing the value to write into memory |
| `push` | from Register | Push a value from a register unto the stack | `push <register-in>` | `push rdx` | `register-in` | the register whose value to push onto the stack | `rsp -= ??` |
| `pop` | to Register | Pop a value from the stack into a register | `pop <register-out>` | `pop r13` | `register-out` | the register into which to pop | `rsp += ??` |
| **ARITHMETIC**
| `add` | Immediate to Register | Add the given value to the value of the register | `add <register-out>, <value-in>` | `add r8, '0'` | `register-out` | the register to which to add | N/A
|       |                       |                                                  |                                  |               | `value-in`     | the value to add | N/A
| `inc` | to/from Register | Increment the value of a register | `inc <register>` | `inc r8` | `register` | the register whose value to increment | N/A |
| **CONTROL TRANSFER**
| `call` | from Memory | Jump to an subroutine address | `call <address>` | `call WRITELN` |`address`| the address to which to jump | `[rsp] <- rip` |
|        |             |                               |                  |                ||| ` rsp -= ??` |
| `ret`  | from Memory | Return to the location at `[rsp]` (from last `call`) | `ret` | `ret` | N/A | N/A | `rsp += ??`
| `int` | N/A | Perform an interrupt. | `int <code>` | `int 80h` | `code` | the code of the interrupt to perform | [\[1\]](#int-side_effect) |
| `syscall` | N/A | Perform a system call interrupt. | `syscall` | `syscall` | N/A | N/A | `rcx <- rip` |
|           |  |                                  |           |           |  |  | `r11 <- rflags` |

1. <a id="int-side_effect"></a> Interrupts may affect specific registers.  Please see the documentation for that specific interrupt.
