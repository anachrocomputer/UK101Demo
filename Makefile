# Makefile for Compukit UK101 demo program

AS65=as6502

CC=gcc
CFLAGS=

all: UK101Demo.hex
.PHONY: all

pbm2fcb: pbm2fcb.c
	$(CC) $(CFLAGS) -o pbm2fcb pbm2fcb.c

UK101.asm: UK101.pbm pbm2fcb
	./pbm2fcb UK101.pbm >UK101.asm

graphic1.asm: graphic1.pbm pbm2fcb
	./pbm2fcb graphic1.pbm >graphic1.asm
	
UK101Demo.asm: DemoMain.asm UK101.asm graphic1.asm
	cat DemoMain.asm UK101.asm graphic1.asm >UK101Demo.asm

UK101Demo.hex: UK101Demo.asm UK101.asm
	$(AS65) UK101Demo.asm UK101Demo.hex UK101Demo.lst

# Target 'clean' will delete all object files and HEX files
clean:
	-rm -f *.o *.obj *.hex pbm2fcb UK101Demo.asm UK101.asm graphic1.asm

.PHONY: clean
