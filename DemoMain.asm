; UK101Demo --- demo program for Compukit UK101            2023-10-19
; Copyright (c) 2023 John Honniball

WARMJMP     EQU $0000     ; Location of JMP instruction for UK101 Warm Start
WARMVEC     EQU $0001     ; Location of vector for UK101 Warm Start
JMP_ABS     EQU $4C       ; 6502 jump absolute opcode

BLANK       EQU $20
EOS         EQU 0
CR          EQU 13
LF          EQU 10
CTRL_L      EQU 12

VDUSTRIDE   EQU 64        ; Each VDU row occupies 64 bytes
VDUROWS     EQU 16        ; UK101 VDU is 16 rows...
VDUCOLS     EQU 48        ; ...of 48 characters

SCRLWID     EQU $0207     ; Width of VDU RAM to scroll, 0-64 cols

GETKEY      EQU $FD00     ; Read ASCII code from keyboard
DELAY       EQU $FA95
OUTCHAR     EQU $FFEE     ; VDU output routine in monitor ROM

; VDU RAM addresses
VDURAM0     EQU $d000     ; Video memory start address
COLRAM0     EQU $d400     ; Colour memory start address
VDULM       EQU 13        ; VDU left margin = 13 cols
VDUHOME     EQU VDURAM0+VDULM  ; VDU address of top left-hand corner
COLHOME     EQU COLRAM0+VDULM
VDURAM1     EQU $d100     ; Second page of video memory
VDURAM2     EQU $d200     ; third...
VDURAM3     EQU $d300     ; fourth
BOTROW      EQU $d3c0     ; Address of bottom row of VDU
COLRAM1     EQU $d500     ; Second page of colour memory
COLRAM2     EQU $d600     ; third...
COLRAM3     EQU $d700     ; fourth

; Precompute VDU row addresses for unrolled scrolling loop
; (working around duff assembler, too)
VDUOFF0     EQU 0
VDUOFF1     EQU VDUSTRIDE
VDUOFF2     EQU VDUSTRIDE*2 
VDUOFF3     EQU VDUSTRIDE*3
VDUOFF4     EQU VDUSTRIDE*4
VDUOFF5     EQU VDUSTRIDE*5
VDUOFF6     EQU VDUSTRIDE*6
VDUOFF7     EQU VDUSTRIDE*7
VDUOFF8     EQU VDUSTRIDE*8
VDUOFF9     EQU VDUSTRIDE*9
VDUOFF10    EQU VDUSTRIDE*10
VDUOFF11    EQU VDUSTRIDE*11
VDUOFF12    EQU VDUSTRIDE*12
VDUOFF13    EQU VDUSTRIDE*13
VDUOFF14    EQU VDUSTRIDE*14
VDUOFF15    EQU VDUSTRIDE*15

VDUROW0     EQU VDUHOME+VDUOFF0
VDUROW1     EQU VDUHOME+VDUOFF1
VDUROW2     EQU VDUHOME+VDUOFF2
VDUROW3     EQU VDUHOME+VDUOFF3
VDUROW4     EQU VDUHOME+VDUOFF4
VDUROW5     EQU VDUHOME+VDUOFF5
VDUROW6     EQU VDUHOME+VDUOFF6
VDUROW7     EQU VDUHOME+VDUOFF7
VDUROW8     EQU VDUHOME+VDUOFF8
VDUROW9     EQU VDUHOME+VDUOFF9 
VDUROW10    EQU VDUHOME+VDUOFF10
VDUROW11    EQU VDUHOME+VDUOFF11
VDUROW12    EQU VDUHOME+VDUOFF12
VDUROW13    EQU VDUHOME+VDUOFF13
VDUROW14    EQU VDUHOME+VDUOFF14
VDUROW15    EQU VDUHOME+VDUOFF15

COLROW0     EQU COLHOME+VDUOFF0
COLROW1     EQU COLHOME+VDUOFF1
COLROW2     EQU COLHOME+VDUOFF2
COLROW3     EQU COLHOME+VDUOFF3
COLROW4     EQU COLHOME+VDUOFF4
COLROW5     EQU COLHOME+VDUOFF5
COLROW6     EQU COLHOME+VDUOFF6
COLROW7     EQU COLHOME+VDUOFF7
COLROW8     EQU COLHOME+VDUOFF8
COLROW9     EQU COLHOME+VDUOFF9 
COLROW10    EQU COLHOME+VDUOFF10
COLROW11    EQU COLHOME+VDUOFF11
COLROW12    EQU COLHOME+VDUOFF12
COLROW13    EQU COLHOME+VDUOFF13
COLROW14    EQU COLHOME+VDUOFF14
COLROW15    EQU COLHOME+VDUOFF15

BLUE            equ 128+1                 ; Colour blue and standard UK101 character set
RED             equ 128+2
GREEN           equ 128+4
YELLOW          equ RED|GREEN
MAGENTA         equ RED|BLUE
CYAN            equ GREEN|BLUE
WHITE           equ RED|CYAN
COLOUR          equ $0202                 ; Location where UK101 monitor keeps the current colour

map0            equ $d0                   ; Vector to bit-map data
map1            equ $d2                   ; Vector to bit-map data
vdu             equ $d4                   ; Vector to VDU RAM
colvec          equ $d6                   ; Vector to colour RAM
row             equ $d8                   ; Row counter 15..0
col             equ $d9
byt             equ $da                   ; Byte counter 5..0
mapb            equ $db
mask            equ $dc
rowdelay        equ $dd

                org $0300
main            lda #JMP_ABS              ; Jump absolute opcode
                sta WARMJMP
                lda #<main                ; Vector for UK101 Warm Start
                sta WARMVEC
                lda #>main
                sta WARMVEC+1
                
                lda #WHITE                ; Select white text on black
                sta COLOUR
                lda #<UK101
                ldy #>UK101
                ldx #0
                jsr showbitmap            ; Show first bitmap
                
                lda #<uk101save           ; Save entire screen into RAM
                ldy #>uk101save
                jsr vdusave
                
                jsr GETKEY
                lda #CYAN                 ; Select cyan text on black
                sta COLOUR
                lda #<m6502
                ldy #>m6502
                ldx #128                  ; Display more slowly
                jsr showbitmap            ; Show first bitmap
                nop
                jsr GETKEY
                lda #GREEN                ; Select green text on black
                sta COLOUR
                lda #<graphic1
                ldy #>graphic1
                ldx #0
                jsr showbitmap            ; Show second bitmap
                nop
                jsr GETKEY
                lda #YELLOW               ; Select yellow text on black
                sta COLOUR
                lda #<UK101
                ldy #>UK101
                ldx #0  
                jsr showbitmap            ; Show third bitmap
                nop
                jsr GETKEY
                
                ldx #VDUCOLS              ; Scroll 48 times to clear screen
loop            lda #255
                jsr delay2
                jsr scroll1r              ; Scroll VDU to the right
                dex
                bne loop
                
                lda #WHITE                ; Select white text on black
                sta COLOUR
                lda #<BASICSPLASH
                ldy #>BASICSPLASH
                jsr prtmsg
                
                lda #<splashsave          ; Save entire screen into RAM
                ldy #>splashsave
                jsr vdusave
                jsr GETKEY
                
                lda #<uk101save           ; Re-load earlier saved screen into VDU
                ldy #>uk101save
                jsr vduload
                jsr GETKEY
                
                brk
                
; showbitmap
; Display a 48x32 pixel bitmap on UK101 text screen
; Entry: A,Y -> bitmap, X = delay (for each row)
showbitmap      sta map0                  ; Set up vector to bit-map
                sty map0+1
                stx rowdelay              ; Save delay factor
                clc
                adc #6
                sta map1                  ; Vector to next row of bit-map
                bcc mapnc
                iny
mapnc           sty map1+1
                lda #<VDUHOME             ; Set up vector to VDU RAM
                ldy #>VDUHOME
                sta vdu
                sty vdu+1
                
                lda #0
                sta mapb
                
                lda #VDUROWS-1            ; Set up row counter
                sta row

shrow           lda #0                    ; Start at column 0 on VDU
                sta col
                lda vdu                   ; Make colour vector point
                ldy vdu+1                 ; to colour RAM, 1k above
                iny                       ; VDU RAM
                iny
                iny
                iny
                sta colvec
                sty colvec+1

                lda #5                    ; Loop over 6 bytes in bit-map
                sta byt
                
shbyte          lda #$80                  ; Set up bit mask: 10000000
                sta mask
                
shbit           ldy mapb
                lda (map0),y              ; Fetch byte from bit-map
                and mask
                beq iszer
                lda (map1),y              ; Fetch byte from next row
                and mask
                beq is10
                lda #161                  ; Entire cell one
                bne done
is10            lda #155                  ; Top half of cell
                bne done
iszer           lda (map1),y              ; Fetch byte from next row
                and mask
                beq is00
                lda #154
                bne done
is00            lda #32                   ; Entire cell zero
done            ldy col
                sta (vdu),y               ; Store into VDU RAM
                lda COLOUR
                sta (colvec),y            ; Store into colour RAM
                iny
                sty col
                
                lsr mask                  ; Shift the mask bit until
                bcc shbit                 ; the '1' pops out into carry

                inc mapb
                dec byt
                bpl shbyte
                
                lda mapb
                clc
                adc #6
                sta mapb

                lda vdu                   ; Point 'vdu' to next row down
                clc
                adc #VDUSTRIDE
                sta vdu
                bcc shnc
                inc vdu+1
                
                lda rowdelay
                jsr delay2                ; Delay for each row drawn

shnc            dec row
                bpl shrow
                rts
                
; scroll1r
; Scroll UK101 text screen 1 column to the right
; Entry:
; Exit: registers unchanged
scroll1r        pha
                txa
                pha
                tya
                pha
                
                ldy SCRLWID
                dey
                dey
scrlr1          lda VDUROW0,Y     ; Fetch a byte...
                sta VDUROW0+1,Y   ; ...store it back one column right
                lda VDUROW1,Y
                sta VDUROW1+1,Y
                lda VDUROW2,Y
                sta VDUROW2+1,Y
                lda VDUROW3,Y
                sta VDUROW3+1,Y
                lda VDUROW4,Y
                sta VDUROW4+1,Y
                lda VDUROW5,Y
                sta VDUROW5+1,Y
                lda VDUROW6,Y
                sta VDUROW6+1,Y
                lda VDUROW7,Y
                sta VDUROW7+1,Y
                lda VDUROW8,Y
                sta VDUROW8+1,Y
                lda VDUROW9,Y
                sta VDUROW9+1,Y
                lda VDUROW10,Y
                sta VDUROW10+1,Y
                lda VDUROW11,Y
                sta VDUROW11+1,Y
                lda VDUROW12,Y
                sta VDUROW12+1,Y
                lda VDUROW13,Y
                sta VDUROW13+1,Y
                lda VDUROW14,Y
                sta VDUROW14+1,Y
                lda VDUROW15,Y
                sta VDUROW15+1,Y
                dey
                bpl scrlr1
                
                lda #BLANK
                sta VDUROW0
                sta VDUROW1
                sta VDUROW2
                sta VDUROW3
                sta VDUROW4
                sta VDUROW5
                sta VDUROW6
                sta VDUROW7
                sta VDUROW8
                sta VDUROW9
                sta VDUROW10
                sta VDUROW11
                sta VDUROW12
                sta VDUROW13
                sta VDUROW14
                sta VDUROW15

                pla
                tay
                pla
                tax
                pla
                rts
                
; vdusave
; Copy VDU RAM into a buffer pointed to by A and Y
; Entry: A=LO, Y=HI pointer to save area in main RAM (destination)
; Exit: registers unchanged
vdusave         sta map0                  ; 'map0' vector points to save area in main RAM
                sty map0+1
                pha
                txa
                pha
                tya
                pha
                lda #<VDUHOME             ; 'vdu' vector points to VDU RAM
                sta vdu
                lda #>VDUHOME
                sta vdu+1
                ldx #VDUROWS-1            ; X is row counter, 15..0
rowsave         ldy #VDUCOLS-1            ; Y is column counter, 47..0
colsave         lda (vdu),y               ; Load from VDU RAM
                sta (map0),y              ; Store into buffer in main RAM
                dey
                bpl colsave               ; Loop over columns
                clc                       ; Add VDUSTRIDE to 'vdu' vector
                lda vdu
                adc #VDUSTRIDE
                sta vdu
                bcc nocarry1
                inc vdu+1
nocarry1        clc                       ; Add VDUCOLS to 'map0' vector
                lda map0
                adc #VDUCOLS
                sta map0
                bcc nocarry2
                inc map0+1
nocarry2        dex
                bpl rowsave               ; Loop over rows
                pla
                tay
                pla
                tax
                pla
                rts
                
; vduload
; Copy a buffer pointed to by A and Y into VDU RAM
; Entry: A=LO, Y=HI pointer to save area in main RAM (source)
; Exit: registers unchanged
vduload         sta map0                  ; 'map0' vector points to save area in main RAM
                sty map0+1
                pha
                txa
                pha
                tya
                pha
                lda #<VDUHOME             ; 'vdu' vector points to VDU RAM
                sta vdu
                lda #>VDUHOME
                sta vdu+1
                ldx #VDUROWS-1            ; X is row counter, 15..0
rowload         ldy #VDUCOLS-1            ; Y is column counter, 47..0
colload         lda (map0),y              ; Load from buffer in main RAM
                sta (vdu),y               ; Store into VDU
                dey
                bpl colload               ; Loop over columns
                clc                       ; Add VDUSTRIDE to 'vdu' vector
                lda vdu
                adc #VDUSTRIDE
                sta vdu
                bcc nocarry3
                inc vdu+1
nocarry3        clc                       ; Add VDUCOLS to 'map0' vector
                lda map0
                adc #VDUCOLS
                sta map0
                bcc nocarry4
                inc map0+1
nocarry4        dex
                bpl rowload               ; Loop over rows
                pla
                tay
                pla
                tax
                pla
                rts
                
; prtmsg
; Print a message pointed to by A and Y
; Entry: A=LO, Y=HI
; Exit: registers unchanged. Uses vector 'vdu'
prtmsg          sta vdu
                sty vdu+1
                pha
                tya
                pha
                ldy #0            ; Y is loop counter
prtloop         lda (vdu),y       ; Get char from string
                beq prtdone       ; End of string?
                jsr OUTCHAR       ; Print it via the monitor ROM routine
                iny               ; Next char
                bne prtloop       ; Go round again
prtdone         pla
                tay
                pla
                rts
                
; delay2
; Spin-loop delay routine
; Entry: A=delay
; Exit:  X and Y changed
delay2          sta dly4          ; Save A
                pha
                txa
                pha
                tya
                pha
                ldx dly4          ; Recover delay into X
                beq dly3          ; Check for zero delay
dly2            ldy #0            ; Y is inner loop counter
dly1            dey
                bne dly1
                dex
                bne dly2
dly3            pla
                tay
                pla
                tax
                pla
                rts
dly4            fcb 0

BASICSPLASH     FCB CTRL_L                ; Clear screen
                TEX "D/C/W/M ?"           ; Original UK101 monitor
                FCB CR,LF
                TEX "MEMORY SIZE?"
                FCB CR,LF
                TEX "TERMINAL WIDTH?"
                FCB CR,LF
                FCB CR,LF
                TEX " 7423 BYTES FREE"    ; Fully expanded 8k machine
                FCB CR,LF
                FCB CR,LF
                TEX "C O M P U K I T  U K 1 0 1"
                FCB CR,LF
                FCB CR,LF
                TEX "Personal Computer"
                FCB CR,LF
                FCB CR,LF
                TEX "8K Basic Copyright1979"
                FCB CR,LF
                TEX "OK"
                FCB CR,LF
                FCB 150                   ; Original UK101 cursor
                FCB EOS
                
splashsave      RMB VDUCOLS*VDUROWS       ; Save area for complete pre-drawn screen image
uk101save       RMB VDUCOLS*VDUROWS       ; Save area for complete UK101 graphic

                
