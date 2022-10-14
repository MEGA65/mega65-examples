; ********************************************************
; * Example of how to play Audio sample on the Mega65
; * George Kirkham (Geehaf) September 2022
; ********************************************************

!cpu M65
;!cpu 4502
;freq = $23ae ; sample frequency playback @ 22050
;freq = $1a56
freq = $d88


      * = $2001
      !BASIC
      ;rts
      sei
      lda #$00
      tax 
      tay 
      taz 
      map
      eom

      lda #$47    ;Enable VIC IV
      sta $d02f
      lda #$53
      sta $d02f
      eom      

      
      ; @gardners:
      ; so 44K1 = ( 44100 x 2^24 ) / ( 40.5 x 10^6 )
      ; = 18269
      ; = $00475D, assuming I got it right.

      lda #$00    ; stop playback
      sta $d720
      lda #$80    ; enable Audio DMA playback
      sta $d711

SCREEN_BASE = $0800+(10*80)  
      ldy #$00
-     lda stext,y
      beq +
      sta SCREEN_BASE,y
      iny
      bne -
+      
      lda #$31
      jsr processkey
      
mainLoop:
      ldy #22+17
      lda $d72b
      jsr printHex
      lda $d72a
      sta $d020
      jsr printHex

      ldy #80+10+18
      lda volume+1
      jsr printHex
      
      lda $d610
      beq mainLoop
      sta $d610
      cmp #122
      bne +
      dec volume+1
+
      cmp #120
      bne +
      inc volume+1
      
+
      cmp #$31
      bcc mainLoop
      cmp #$36
      bcs mainLoop

      jsr processkey
      
      inc $d020
      jmp mainLoop
      
processkey:
      ; translate key press to new sample location
      sec
      sbc #$31
      asl
      tay
      lda sample_start,y
      sta $d0
      
      lda sample_end,y
      sta $d2
      iny
      
      lda sample_start,y
      sta $d1
      
      lda sample_end,y
      sta $d3

      jsr playSample
      jmp mainLoop
stext:
      !SCR "current play address (use keys 1 - 5) $            /geehaf (sept 2022)          "
      !SCR "volume (adjust with z/x) : $"
      !BYTE 0
            
playSample:
      ; play sample through channels 0 & 2
      lda #$00    ; stop playback
      sta $d720

      ; play sample located at an address in memory
      ; load this into base and current for channel C0 & C2
      lda $d0
      sta $d721
      sta $d72a
      
      sta $d721+$20
      sta $d72a+$20
      
      lda $d1
      sta $d722
      sta $d72b
      
      sta $d722+$20
      sta $d72b+$20
      
      
      lda #$00
      sta $d723
      sta $d72c
      
      sta $d723+$20
      sta $d72c+$20

      ; play up to the end/top address of "top_addr", n.b. this is 16 bit address
      lda $d2
      sta $d727
      
      sta $d727+$20
      lda $d3
      sta $d728

      sta $d728+$20
volume:
      lda #$ff/8    ; volume
      sta $d729
      sta $d729+$20
      
      ;sta $d71c
      
      lda #<freq  ; set frequency for C0 & C2
      sta $d724
      sta $d724+$20
      lda #>freq
      sta $d725
      sta $d725+$20
      lda #$00
      sta $d726
      sta $d726+$20
      
      lda #%10100010    ; start sample 
      sta $d720
      sta $d720+$20
      rts 

printHex:
      pha
      lsr
      lsr
      lsr
      lsr
      bsr PrintNyb
      pla
      and #$0f
PrintNyb:
      ora #$30
      cmp #$3a
      bcc +
      sbc #$39
+     sta SCREEN_BASE,y
      iny
      rts
      
sample_start:
      !WORD sYodel,sMagic,sYeah,sBeug,sFlute
sample_end:
      !WORD _sYodel,_sMagic,_sYeah,_sBeug,_sFlute
      
addr:      
sYodel:
!BIN ".\yodel.fssd"
_sYodel:

sMagic:
!BIN ".\magic.fssd"
_sMagic:

sYeah:
!BIN ".\yeah.fssd"
_sYeah:

sBeug:
!BIN ".\Beug.fssd"
_sBeug:

sFlute:
!BIN ".\Panflute.fssd"
_sFlute:
top_addr:











