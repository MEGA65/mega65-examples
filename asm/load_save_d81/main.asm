.cpu _45gs02

*=$02 "zero page" virtual
    .label SaveAddress = $04


BasicUpstart65(Start)

*=$2016 "Program"
Start:
{
    jsr DemoLoadFile
    jsr DemoSaveFile

    rts
}

DemoLoadFile:
{
    // Loads file PAL0.BIN to $40000
    // File is 768 bytes large (palette file 3x255 rgb)
    lda #$04
    sta lfBank
    lda #$00
    sta lfBank+1
    lda #<$0000
    sta lfAddr
    lda #>$0000
    sta lfAddr+1

    lda #8
    ldx #<PaletteFileName
    ldy #>PaletteFileName

    jsr LoadFile
    rts
}

DemoSaveFile:
{
    // saves data from $40000 - $40300 to file TEST.BIN
    lda #$04
    sta lfBank
    lda #$00
    sta lfBank+1

    lda #<$0000
    sta $04
    lda #>$0000
    sta $05

    lda #<$0300
    sta lfAddr
    lda #>$0300
    sta lfAddr+1

    lda #8
    ldx #<SaveFileName
    ldy #>SaveFileName

    jsr SaveFile
    rts
}

PaletteFileName:
    .text "PAL0.BIN"

SaveFileName:
    .text "TEST.BIN"

// ------------------------------------------------------------
//
.macro BasicUpstart65(addr) {
* = $2001 "BasicUpstart65"

	.var addrStr = toIntString(addr)

	.byte $09,$20 //End of command marker (first byte after the 00 terminator)
	.byte $0a,$00 //10
	.byte $fe,$02,$30,$00 //BANK 0
	.byte <end, >end //End of command marker (first byte after the 00 terminator)
	.byte $14,$00 //20
	.byte $9e //SYS
	.text addrStr
	.byte $00
end:
	.byte $00,$00	//End of basic terminators
}

/************************************************************************ Routines for loading and saving */
lfBank:
    .word $0000
lfAddr:
    .word $0000


LoadFile:
{
        sei
        
		jsr $FFBD
		
		lda lfBank	// bank for loading
		ldx #$00	// bank for filename
		jsr $ff6b
		
		lda #$00
		ldx #$08
		ldy #$00
		jsr $FFBA
		
		// set 32bit load address
		
		lda lfBank+1
		sta $b0
		lda lfBank
		sta $af

		lda #$00
		ldx lfAddr
		ldy lfAddr+1
		jsr $FFD5
		bcs !derror+
		jmp !goexit+
	!derror:
		inc $d020
		jmp !derror-
		
	!goexit:
		cli
        rts
}


SaveFile:
{
		jsr $FFBD
		
		lda lfBank	// bank for save
		ldx #$00	// bank for filename
		jsr $ff6b
		
		lda #$00
		ldx #$08
		ldy #$00
		jsr $FFBA
		
		// set 32bit save address
		
		// for start address
		lda lfBank+1
		sta $b0
		lda lfBank
		sta $af
		// for end address
		lda lfBank+1
		sta $ac
		lda lfBank
		sta $ab

		
		ldx lfAddr
		ldy lfAddr+1
		lda #SaveAddress
		jsr $FFD8
		bcs !derror+
		jmp !goexit+
	!derror:
		inc $d021
		jmp !derror-
		
	!goexit:
        rts
}

