!cpu M65
; ********************************************************
; * "Comic Border"
; * A demo showing how to use the borders to create a simple screen transition effect
; * George Kirkham (Geehaf) September 2022
; ********************************************************
* = $2001

initMusic = $7f00
playMusic = $7f03
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
      
      lda #$35
      sta $01
      lda #$7f
      sta $dc0d
      sta $dd0d
      lda $dc0d
      lda $dd0d
      
      lda #$00
      jsr initMusic

      lda #$00
      sta $d020
      lda #$00
      sta $d5

loop: 
      lda $d06f
      and #%01111111    ; force PAL each frame just in case somebody changes it in the Freezer menu :)
      ;ora #%10000000   ; force NTSC
      sta $d06f      

      lda $d610   ; read the keyboard
      beq NoKey   ; branch if no keys pressed
      sta $d610   ; reset keyboard register
      cmp #$31    ; has user pressed keys 1 - 5?
      bcc NoKey
      cmp #$3a
      bcs NoKey
      sec
      sbc #$31
      sta $d020
      jsr initMusic     ; select tune based upon key pressed
      
NoKey:      
      
      lda #51           ; 51 is are starting raster line
      sta $d0
      
-     lda $d011
      bmi -       ; Let's wait for the start of the frame, i.e. high bit of VIC II raster is 0

transitionIndex:
      ldy #0
      ldx lineStepCount,y     ; set  x to number of raster splits we will have
      lda lineStepDELTA,y     ; set raster step amount
      sta $d4

      lda $d0
sinusIndex:
      ldy #$00
nextLine:
      lda $d0
-     cmp $d012
      bne -                   ; wait for the line held in $D0
      lda sinus,y
      clc
mod1:      
      adc #00
      sta $d2
mod2:
      lda #$00
      bpl +       ; branch if we are +IVE 
      lda #$00
      sta $d2
      sta $d3
      bra setSBord
      
+      
      adc #$00
      sta $d3

setSBord:
      lda $d2
      sta $d05c
      lda $d05d
      and #%11000000    ; top 2 bits are not related to side border width, keep them entact
      ora $d3
      sta $d05d
      clc
      lda $d0
      adc $d4
      sta $d0           ; next raster line to wait for
      tya
      clc
dir:      
      adc #$01
      and #$3f
      tay               ; out index into the sinus table 
      
      dex
      bpl nextLine      ; do for the full screen
      
      lda #252    ; Wait until line 247
-     cmp $d012
      bne -
      lda #80
      sta $d05c   ; reset border

      ; next piece determines if we need to move the top / bottom borders
doTopBrd:
      ldx #$00          ; this is sel mod code - adjusted by the message routine
      beq noTop

      lda $d5
      bpl +
      lda topAdder
      neg
      sta topAdder
      lda #$00
      sta $d5
      
+     lda $d5
      cmp #85
      bcc +
      lda topAdder
      neg
      sta topAdder
+
      clc
      lda $d5
      adc topAdder
      sta $d5
      
      lda #104    ; our starting point for the Top Border
      ldy sinusIndex+1
      clc
      adc sinus,y
      clc
      adc $d5
      sta $d048
doBotBrd:
      ldx #$00          ; this is sel mod code - adjusted by the message routine
      beq noTop
      lda #248          ; bottom border start point
      sec
      sbc sinus,y
      sec
      sbc $d5
      sta $d04a
noTop:      
      jsr playMusic

-     lda $d011
      bpl -

      ;inc sinusIndex+1
      lda sinusIndex+1
      inc
      and #$3f
      sta sinusIndex+1
      
      lda mod2+1
      bmi here    ; if -IVE reverse the direction for border movement
      cmp #1
      bne +
      lda mod1+1
      cmp #$a0
      bcc +
      lda $d021
      inc
      and #$1f
      cmp #$07
      bne notYellow
      inc
notYellow:
      sta $d021
      jsr showmsg

      ldy transitionIndex+1
      dey
      tya
      and #7
      sta transitionIndex+1
here:
      lda adder1
      neg
      sta adder1
      lda adder2
      eor #$ff
      sta adder2
      dec dir+1
+      
      clc
      lda mod1+1
      adc adder1
      sta mod1+1
      lda mod2+1
      adc adder2
      sta mod2+1
      inc framecounter
      jmp loop

framecounter:     !BYTE 0      

adder1:      !BYTE 8
adder2:      !BYTE 0
topAdder:    !BYTE 1
lineCount = 200

lineStepCount:    
!FOR i = 1 to 8
!BYTE lineCount/(i*2)
!END

lineStepDELTA:
!FOR i = 1 to 8
!BYTE (i*2)
!END

showmsg:
      ldy #$00
restartMsgs:
      lda msgNum
      asl
      tax
      lda msgs,x
      sta $a0
      lda msgs+1,x
      bpl +
      lda #$00
      sta msgNum
      beq restartMsgs
+
      sta $a1

      ldy #$00
-     lda ($a0),y
      beq countDone
      iny
      bne -
countDone:
      tya
      sec
      sbc #80
      neg
      lsr
      tax
      ldy #79
      lda #32
-     sta $0800+(12*80),y
      dey
      bpl -
      

      ldy #$00
-     lda ($a0),y
      beq msgDone
      cmp #$fe
      bne +
      sta doTopBrd+1
      bra nextchar
+
      cmp #$ff
      bne +
      sta doBotBrd+1
      bra nextchar
+      
      sta $0800+(12*80),x
      inx
nextchar:
      iny
      bne -
msgDone:
      
      inc msgNum
      rts
      
msgNum      !BYTE 0
      
msgs: !WORD t1,t9,t2,t9,t3,t9,t4,t9,t5,t9,t6,t9,t7,t9,t7a,t8,t9,t9,t9,t9,t10,t9,t9,t9,t9,t9,t11,t9,t99,$ffff


t1:   !SCR "hello and welcome to comic border",0
t2:   !SCR "a very simple demo by geehaf for the mega65",0
t3:   !SCR "experimenting using the side border",0
t4:   !SCR "for screen transitions",0
t5:   !SCR "nothing too technical",0
t6:   !SCR "but i think looks interesting and a bit of fun",0
t7:   !SCR "sid music arrangement from comic bakery",0
t7a:  !SCR "by martin galway in 1986",0
t8:   !SCR "use keys 1 - 9 to change the music",0
t9:   !SCR " ",0
t10:  !SCR "let's add some top border moves",$fe,0
;t9c:   !SCR " ",0
;t9d:   !SCR " ",0
t11:  !SCR "now the bottom border",$ff,0
;t9e:   !SCR " ",0
t99:   !SCR "(geehaf / september 2022)",0

sinus:   !BYTE $20,$23,$26,$29,$2C,$2F,$31,$34 ; A part of a sinus table
        !BYTE $36,$38,$3A,$3C,$3D,$3E,$3F,$3F
        !BYTE $3F,$3F,$3F,$3E,$3D,$3C,$3A,$38
        !BYTE $36,$34,$31,$2F,$2C,$29,$26,$23
        !BYTE $20,$1C,$19,$16,$13,$10,$E,$B
        !BYTE 9,7,5,3,2,1,0,0,0,0,0,1,2,3,5,7
        !BYTE 9,$B,$E,$10,$13,$16,$19,$1C      
* = $7f00-2
music:
!BIN ".\comic_bakery.dat"      
end:

