# UK101Demo #

Assembly-language routines for the Compukit UK101,
making a demo program for the machine.
Repository set up in October 2023 for RetroChallenge.

The program displays a sequence of screen images from 48x32 pixel
bitmaps loaded as part of the checksum hex file.
It also saves complete VDU images into RAM and loads them back using
video wipe effects (top-to-bottom and bottom-to-top so far).

Some of the demo displays include colour,
which will only work on my modified UK101
(with a colour monitor connected of course).
But the colour effects should not prevent the code from running on a
standard machine.
The timings of the video wipes are also set up for my 2MHz machine,
whereas the standard 1MHz Compukit will be only half as fast.

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

Note that the code now requires more than 4k of RAM and will not run
on an unexpanded UK101.
8k machines should be fine though.

However, the Extended Monitor that was supplied on cassette with the
original UK101 kit occupies addresses in the 4k RAM area that we'll
overwrite when loading this code.
I've moved the Extended Monitor up to $C000 and put it in an EPROM,
so my machine can load into any part of RAM.
I'm not sure the best way to fix this issue,
so if any UK101 users have some good suggestions,
please let me know.

Once loaded, execute the program at address $0300.


