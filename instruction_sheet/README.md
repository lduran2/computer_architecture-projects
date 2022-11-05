# Instruction Sheet for 8086, 64-BIT HMOS MICROPROCESSOR

## Registers

## Instruction Set

| Mnemonic | Addressing Mode | Instruction | Syntax | Example | Argument  | Argument Description |
|----------|-------------|-----------------|--------|---------|-----------|----------------------|
| `mov`    | Intermediate to Register | Move a value into a register | `mov <register>, <value>` | `mov rax, sys_write` | `register` | the register to which to write |
|          |                          |                              |                           |                      | `value`    | the value to write into the register |
| `syscall` |  | Perform a system call. | `syscall` | `syscall` |  |  |
