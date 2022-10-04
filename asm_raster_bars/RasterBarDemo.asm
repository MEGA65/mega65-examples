; ********************************************************
; * Example of how to display raster colour bars on the Mega65
; * we expand the screen row size by 4 characters to allow eliminating the side border
; * which avoids timing differences between $d020 being updated and $d021 with the raster buffer
; * George Kirkham (Geehaf) September 2022
; ********************************************************
!cpu M65

       * = $2001
      !BASIC
      sei
      lda #65     ; Enable 40 MHz
      sta $00
      lda #$00    ; Enable VIC IV
      tax 
      tay 
      taz 
      map
      eom
      lda #$47    
      sta $d02f
      lda #$53
      sta $d02f
      eom

      lda #0            ; side border size = 0
      sta $d05c
      lda $d05d
      and #%11000000
      sta $d05d

      lda #84           ; screen row size 84 chars
      sta $d05e
loop:
      ldx #$00
-     lda $d011
      bmi -
      lda #49
-     cmp $d012
      bne -
mod1:
      ldy #$00
nextRasBar:      
      lda $d012
-     cmp $d012
      beq -
-     lda $d051
      and #%00111111
      beq -             ; branch if XPOSMSB is zero (avoids mid screen flicker)
      
      lda barcols,y
      sta $d021
      iny
      tya
      and #63
      tay
      inx
      cpx #200
      bne nextRasBar
      lda #$06
      sta $d021
      dec mod1+1
-     lda $d011
      bpl -
      jmp loop 
barcols:
      !BYTE $00,$06,$0e,$03,$0d,$07,$01,$01,$01,$07,$0d,$0d,$03,$0e,$06,$00
      !BYTE $00,$06,$0e,$03,$0d,$07,$01,$01,$01,$07,$0d,$0d,$03,$0e,$06,$00
      !BYTE $00,$06,$0e,$03,$0d,$07,$01,$01,$01,$07,$0d,$0d,$03,$0e,$06,$00
      !BYTE $00,$06,$0e,$03,$0d,$07,$01,$01,$01,$07,$0d,$0d,$03,$0e,$06,$06

      