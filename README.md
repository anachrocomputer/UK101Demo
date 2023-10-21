# UK101Demo #

Assembly-language routines for the Compukit UK101,
making a demo program for the machine.
Repository set up in October 2023 for RetroChallenge.

## Assembler ##

The code assembles with a 6502 assembler of my own design.
I should probably make another repo for that code so that
people can compile it for their chosen host computer.

## Loading and Running ##

The assembler generates a HEX file in MOS Technology checksum format.
The UK101 Extended Monitor can load this file from the ACIA at 300 baud.
My own modified UK101 has a checksum loader in EPROM and can load
the file at 1200 baud.

Once loaded, execute the program at address $0300.


