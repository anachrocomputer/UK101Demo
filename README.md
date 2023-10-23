# UK101Demo #

Assembly-language routines for the Compukit UK101,
making a demo program for the machine.
Repository set up in October 2023 for RetroChallenge.

## Assembler ##

The code assembles with a 6502 assembler of my own design called 'as6502'.
It's available in another repo: [https://github.com/anachrocomputer/6502]

## Building the Program ##

We will need the C compiler, linker and libraries:

`sudo apt-get install build-essential`

Once those are installed, along with 'as6502', we can simply:

`make`

The Makefile will compile a small C program that converts ASCII Portable Bitmap
files into assembly language, run it a few times, and then run the assembler.

## Loading and Running ##

The assembler generates a HEX file in MOS Technology checksum format.
The UK101 Extended Monitor can load this file from the ACIA at 300 baud.
My own modified UK101 has a checksum loader in EPROM and can load
the file at 1200 baud.

Once loaded, execute the program at address $0300.


