# Instruction Sheet for 8086, 64-BIT HMOS MICROPROCESSOR

## Registers

## Flags in `rflags`

| Bit N<sup><ins>o</ins></sup>. | Code | Name          | Description                                                  | Meaning when set (`1`) | Meaning when clear (`0`)
|:-----------------------------:|:----:|---------------|--------------------------------------------------------------|------------------------|-------------------------
|                            64 | `X`  | Reserved
|                             ⋮
|                            32 | 〃   | 〃
|                            31 | `X`  | Reserved
|                             ⋮
|                            22 | 〃   | 〃
|                            21 | `ID` | Identification flag
|                            20 | `VIP` | Virtual interrupt pending flag
|                            19 | `VIF` | Virtual interrupt flag
|                            18 | `AC` | Alignment check
|                            17 | `VM` | Virtual-8086 mode flag |                                                          | Virtual-8086 mode | Protected mode
|                            16 | `RF` | Resume flag    | For debug exceptions
|                            15 | `X`  | Reserved
|                            14 | `NT` | Nested task flag
|                            13 | `IOPL` | I/O priviledge level
|                            12 | 〃     | 〃
|                            11 | `OF` | Overflow flag  | Whether previous operation resulted in an overflow [^ overflow]
|                            10 | `DF` | Direction flag | Determines the start of the strings for processing          | Strings' lowest address | Strings' highest address
|                      &numsp;9 | `IF` | Interrupt enable flag | Enables interrupt handling                           | Set interrupt          | Clear interrupt
|                      &numsp;8 | `TF` | Trap flag      | Sets single step mode
|                      &numsp;7 | `SF` | Sign flag      | Whether previous operation resulted in a negative number        | Negative               | Not negative
|                      &numsp;6 | `ZF` | Zero flag      | Whether previous operation resulted in zero                     | Zero                   | Not zero
|                      &numsp;5 | `X`  | Reserved
|                      &numsp;4 | `AF` | Auxiliary flag | Carry of the `4` least significant bits                           | Auxiliary carry | No Auxiliary carry
|                      &numsp;3 | `X`  | Reserved
|                      &numsp;2 | `PF` | Parity flag    | Whether previous operation resulted in an even number of set bits | Parity even            | Parity odd
|                      &numsp;1 | `X`  | Reserved
|                      &numsp;0 | `CF` | Carry flag     | Whether previous operation resulted in a carry                    | Carry                  | No carry

[^overflow]: An overflow is occurs when adding two numbers of the same sign results in a sum of the opposite sign (by its sign bit), or the equivalent subtraction occurs.

## Instruction Set

| Mnemonic | Addressing Mode | Instruction | Syntax | Example | Operand   | Operand Description  | Side effect |
|----------|-------------|-----------------|--------|---------|-----------|----------------------|-------------|
| **DATA TRANSFER**
| `mov`    | Register to Register   | Copy contents of a register into another register  | `mov <register-out>, [<register-in>]` | `mov rax, r8` | `register-out` | the register to which to write | N/A
|          |                          |                              |                           |                      | `register-in`    | register containing the value to write into the other register |
| `mov`    | Memory to Register   | Loads contents of an address in memory into a register  | `mov <register-out>, [<address-in>]` | `mov r8, rsi[0]` | `register-out` | the register to which to write | N/A
|          |                          |                              |                           |                      | `address-in`    | address containing the value to write into the register |
| `mov`    | Memory from Register | Stores contents of a register into an address in memory | `mov [<address-out>], <register-in>` | `mov rsi[0], r8` | `address-out` | the address at which to write | N/A
|          |                          |                              |                           |                      | `register-in`    | register containing the value to write |
| `mov`    | Intermediate to Register | Move a constant into a register | `mov <register-out>, <constant-in>` | `mov rax, sys_write` | `register-out` | the register to which to write | N/A
|          |                          |                              |                           |                      | `constant-in`    | the constant to write
| `push` | from Register | Push a value from a register unto the stack | `push <register-in>` | `push rdx` | `register-in` | the register whose value to push onto the stack | `rsp -= ??` |
| `pop` | to Register | Pop a value from the stack into a register | `pop <register-out>` | `pop r13` | `register-out` | the register into which to pop the stack | `rsp += ??` |
| **ARITHMETIC**
| `add` | Immediate to Register | Add the given constant to the value of the register | `add <register-out>, <constant-in>` | `add r8, '0'` | `register-out` | the register to which to add | N/A
|       |                       |                                                  |                                  |               | `constant-in`     | the constant to add | N/A
| `inc` | to/from Register | Increment the value of a register | `inc <register>` | `inc r8` | `register` | the register whose value to increment | N/A |
| `cmp` | Register with Immediate | Compares the value in the register with the constant | `cmp <register-in>, <constant-in>` | `cmp rax, 0` | `register-in` | register containing one of the values to compare | 
|       |                         |                                                      |                                    |              | `constant-in` | the other value to compare
| `div` | from Register | Divide (unsigned) by an integer | `div <divisor>` | `div r10` | `divisor` | register containing the divisor | `rax R rdx <- (rdx:rax / divisor)`  |
| **CONTROL TRANSFER**
| `call` | from Memory | Jump to an subroutine address | `call <address>` | `call WRITELN` |`address`| the address to which to jump | `[rsp] <- rip` |
|        |             |                               |                  |                ||| ` rsp -= ??` |
| `ret`  | from Memory | Return to the location at `[rsp]` (from last `call`) | `ret` | `ret` | N/A | N/A | `rsp += ??`
| `int` | N/A | Perform an interrupt. | `int <code>` | `int 80h` | `code` | the code of the interrupt to perform | [^ int-side_effect] |
| `syscall` | N/A | Perform a system call interrupt. | `syscall` | `syscall` | N/A | N/A | `rcx <- rip` |
|           |  |                                  |           |           |  |  | `r11 <- rflags` |

[^int-side_effect]: Interrupts may affect specific registers.  Please see the documentation for that specific interrupt.
