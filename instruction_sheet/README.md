# Instruction Sheet for 8086, 64-BIT HMOS MICROPROCESSOR

## Registers

<!-- this table is in HTML because it has 2 header rows, which are not supported in markdown -->
<table>
  <tr>
    <th></th>
    <th>Monikers</th>
    <th></th>
    <th></th>
    <th></th>
    <th></th>
    <th>Description</th>
    <th>Caller-saved by convention</th>
  </tr>
  <tr>
    <th>bitwidth</th>
    <th><code>64</code></th>
    <th><code>32</code></th>
    <th><code>16</code></th>
    <th><code>8</code> high of <code>16</code> low</th>
    <th><code>8</code> low  of <code>16</code> low</th>
    <th></th>
    <th></th>
  </tr>
    <td></td>
    <td><code>RAX</code></td>
    <td><code>EAX</code></td>
    <td><code>AX</code></td>
    <td><code>AH</code></td>
    <td><code>AL</code></td>
    <td>Accumulator</td>
    <td>Yes</td>
  </tr>
  <tr>
    <td></td>
    <td><code>RBX</code></td>
    <td><code>EBX</code></td>
    <td><code>BX</code></td>
    <td><code>BH</code></td>
    <td><code>BL</code></td>
    <td>Base</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>RCX</code></td>
    <td><code>ECX</code></td>
    <td><code>CX</code></td>
    <td><code>CH</code></td>
    <td><code>CL</code></td>
    <td>Counter</td>
    <td>Yes</td>
  </tr>
  <tr>
    <td></td>
    <td><code>RDX</code></td>
    <td><code>EDX</code></td>
    <td><code>DX</code></td>
    <td><code>DH</code></td>
    <td><code>DL</code></td>
    <td>Data (may extend accumulator, as in <code>div</code>)</td>
    <td>Yes</td>
  </tr>
  <tr>
    <td></td>
    <td><code>RSI</code></td>
    <td><code>ESI</code></td>
    <td><code>SI</code></td>
    <td></td>
    <td><code>SIL</code></td>
    <td>Source index in buffers</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>RDI</code></td>
    <td><code>EDI</code></td>
    <td><code>DI</code></td>
    <td></td>
    <td><code>DIL</code></td>
    <td>Destination index in buffers</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>RSP</code></td>
    <td><code>ESP</code></td>
    <td><code>SP</code></td>
    <td></td>
    <td><code>SPL</code></td>
    <td>Stack pointer</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>RBP</code></td>
    <td><code>EBP</code></td>
    <td><code>BP</code></td>
    <td></td>
    <td><code>BPL</code></td>
    <td>Stack base pointer</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R8</code></td>
    <td><code>R8D</code></td>
    <td><code>R8W</code></td>
    <td></td>
    <td><code>R8</code></td>
    <td>Register #8</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R9</code></td>
    <td><code>R9D</code></td>
    <td><code>R9W</code></td>
    <td></td>
    <td><code>R9</code></td>
    <td>Register #9</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R10</code></td>
    <td><code>R10D</code></td>
    <td><code>R10W</code></td>
    <td></td>
    <td><code>R10</code></td>
    <td>Register #10</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R11</code></td>
    <td><code>R11D</code></td>
    <td><code>R11W</code></td>
    <td></td>
    <td><code>R11</code></td>
    <td>Register #11</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R12</code></td>
    <td><code>R12D</code></td>
    <td><code>R12W</code></td>
    <td></td>
    <td><code>R12</code></td>
    <td>Register #12</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R13</code></td>
    <td><code>R13D</code></td>
    <td><code>R13W</code></td>
    <td></td>
    <td><code>R13</code></td>
    <td>Register #13</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R14</code></td>
    <td><code>R14D</code></td>
    <td><code>R14W</code></td>
    <td></td>
    <td><code>R14</code></td>
    <td>Register #14</td>
    <td>No</td>
  </tr>
  <tr>
    <td></td>
    <td><code>R15</code></td>
    <td><code>R15D</code></td>
    <td><code>R15W</code></td>
    <td></td>
    <td><code>R15</code></td>
    <td>Register #15</td>
    <td>No</td>
  </tr>
</table>

These registers may be operated on directly using Data transfer and arithmetic operations such as `mov` and `add` respectively. 
There are other registers such as the flag register `rflags` and the instruction pointer `rip` which are not accessed this way. 

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
| `mov`    | Memory to Register   | Load contents of an address in memory into a register  | `mov <register-out>, [<address-in>]` | `mov r8, rsi[0]` | `register-out` | the register to which to write | N/A
|          |                          |                              |                           |                      | `address-in`    | address containing the value to write into the register |
| `mov`    | Memory from Register | Store contents of a register into an address in memory | `mov [<address-out>], <register-in>` | `mov rsi[0], r8` | `address-out` | the address at which to write | N/A
|          |                          |                              |                           |                      | `register-in`    | register containing the value to write |
| `mov`    | Intermediate to Register | Move a constant into a register | `mov <register-out>, <constant-in>` | `mov rax, sys_write` | `register-out` | the register to which to write | N/A
|          |                          |                              |                           |                      | `constant-in`    | the constant to write
| `push` | from Register | Push a value from a register unto the stack | `push <register-in>` | `push rdx` | `register-in` | the register whose value to push onto the stack | `rsp -= ??` |
| `pop` | to Register | Pop a value from the stack into a register | `pop <register-out>` | `pop r13` | `register-out` | the register into which to pop the stack | `rsp += ??` |
| **ARITHMETIC**
| `add` | Immediate to Register | Add the given constant to the value of the register | `add <register-out>, <constant-in>` | `add r8, '0'` | `register-out` | the register to which to add | N/A
|       |                       |                                                  |                                  |               | `constant-in`     | the constant to add | N/A
| `inc` | to/from Register | Increment the value of a register | `inc <register>` | `inc r8` | `register` | the register whose value to increment | N/A |
| `cmp` | Register with Immediate | Compare the value in the register with the constant | `cmp <register-in>, <constant-in>` | `cmp rax, 0` | `register-in` | register containing one of the values to compare | 
|       |                         |                                                      |                                    |              | `constant-in` | the other value to compare
| `div` | from Register | Divide (unsigned) by an integer | `div <divisor>` | `div r10` | `divisor` | register containing the divisor | `rax R rdx <- (rdx:rax / divisor)`  |
| **CONTROL TRANSFER**
| `call` | from Memory | Jump to an subroutine address | `call <address>` | `call WRITELN` |`address`| the address to which to jump | `[rsp] <- rip` |
|        |             |                               |                  |                ||| ` rsp -= ??` |
| `ret`  | from Memory | Return to the location at `[rsp]` (from last `call`) | `ret` | `ret` | N/A | N/A | `rsp += ??`
| `jne`/`jnz` | N/A         | Jump if the previous operation did not result in zero. For `cmp` this is the equivalent of inequation | `jne <address>` | `jne DUTOA_DIVIDE_INT_LOOP` | `address` | the address to which to jump
| `loop` | N/A | Loop until `rcx == 0` | `loop <address>` | `loop STRREV_POP_LOOP` | `address` | the address of the start of the loop | `rcx -= 1`
| `int` | N/A | Perform an interrupt. | `int <code>` | `int 80h` | `code` | the code of the interrupt to perform | [^ int-side_effect] |
| `syscall` | N/A | Perform a system call interrupt. | `syscall` | `syscall` | N/A | N/A | `rcx <- rip` |
|           |  |                                  |           |           |  |  | `r11 <- rflags` |

[^int-side_effect]: Interrupts may affect specific registers.  Please see the documentation for that specific interrupt.
