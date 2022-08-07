# Projects in Computer Architecture
###### by Leomar Durán

## [Hello World][hw] (in x86 Assembly) (in C)

Example program for printing a greeting.
Included are the original in x86-64 Assembly
and a C equivalent program.

## [x86 `equ` vs `d*` instructions][x86-eqvd]

Demonstration that compares
all defines (`db`, `dw`, `dd`, `dq`, `dt`) and equate (`equ`)
by showing the size in memory that each occupies.

## [Print increase from 5][x86-pi5] (in x86 Assembly)

Stores `5` in a register, increments the value and prints the result.
This implementation uses the `DUTOA` procedure
(**D**ecimal **U**nsigned integer **to A**SCII),
modified from the `DITOA`
(**D**ecimal **I**nteger **to A**SCII),
that we implemented in [x86 Calculator][x86-calc].
As a result this program can handle
a full 64-bit unsigned integer of
up to 20 digits
`[0,  9,223,372,036,854,775,808]`
for input.

## [x86 Calculator][x86-calc] (in x86 Assembly)

Addition calculator program.
This calculator
1. reads in user input,
1. converts it from ASCII to an integer,
1. performs the addition operation,
1. converts the result from an integer to ASCII, and
1. prints the resulting string.

This can be modified to perform other operations.

[hw]: ./helloworld#readme
[x86-calc]: ./x86-calc#readme
[x86-pi5]: ./x86-print_inc5#readme
[x86-eqvd]: ./x86-equ_vs_dx#readme
