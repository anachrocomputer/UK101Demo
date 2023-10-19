# Makefile for Compukit UK101 demo program

CC=gcc
CFLAGS=

all: pbm2fcb UK101.asm
.PHONY: all

pbm2fcb: pbm2fcb.c
	$(CC) $(CFLAGS) -o pbm2fcb pbm2fcb.c

UK101.asm: UK101.pbm
	./pbm2fcb UK101.pbm >UK101.asm

# Target 'clean' will delete all object files and HEX files
clean:
	-rm -f *.o *.obj *.hex pbm2fcb UK101.asm

.PHONY: clean
