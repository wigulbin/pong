;Not my code Start (setup stuff, edited some variables)
  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;
  .rsset $0000  ;;start variables at ram location 0
  
gamestate  .rs 1  ; .rs 1 means reserve one byte of space
ballx      .rs 1  ; ball horizontal position
bally      .rs 1  ; ball vertical position
ballup     .rs 1  ; 1 = ball moving up
balldown   .rs 1  ; 1 = ball moving down
ballleft   .rs 1  ; 1 = ball moving left
ballright  .rs 1  ; 1 = ball moving right
ballspeedx .rs 1  ; ball horizontal speed per frame
ballspeedy .rs 1  ; ball vertical speed per frame
paddle1ytop   .rs 1  ; player 1 paddle top vertical position
paddle2ytop   .rs 1  ; player 2 paddle top vertical position
buttons1   .rs 1  ; player 1 gamepad buttons, one bit per button
buttons2   .rs 1  ; player 2 gamepad buttons, one bit per button
score1     .rs 1  ; player 1 score, 0-9
score2     .rs 1  ; player 2 score, 0-9

RIGHTWALL      = $F4  ; when ball reaches one of these, do something
TOPWALL        = $20
BOTTOMWALL     = $E0
LEFTWALL       = $04

  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x    ;move all sprites off screen
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2

LoadPalettes:
  LDA $2002    ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006    ; write the high byte of $3F00 address
  LDA #$00
  STA $2006    ; write the low byte of $3F00 address
  LDX #$00
LoadPalettesLoop:
  LDA palette, x        ;load palette byte
  STA $2007             ;write to PPU
  INX                   ;set index to next byte
  CPX #$20            
  BNE LoadPalettesLoop  ;if x = $20, 32 bytes copied, all done

LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$FF             ; Compare X to hex $20, decimal 32
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

  LDA #%10010000   ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites
  STA $2001
;Not my code End


INITSPRITES:
  LDA #$01
  STA balldown
  STA ballright
  LDA #$00
  STA ballup
  STA ballleft
  LDA #$80
  STA ballx
  STA bally
  LDA #$21
  STA paddle1ytop
  LDA #$21
  STA paddle2ytop
  LDA #$01
  STA gamestate
  LDA #$00
  STA gamestate




;SPRITES


;Not my code start
Forever:  
  JMP Forever     ;jump back to Forever, infinite loop

NMI:
  LDA #$00
  STA $2003  ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014  ; set the high byte (02) of the RAM address, start the transfer
  
;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
;Not my code end


  LDX #$00
  LDA #$01
  CMP gamestate
  BEQ GAMESTART
  BCC ENDNMI
  JMP STARTSCREEN


ENDNMI:
  RTI

GAMESTART:
  LDA #$07
  CLC
  ADC score1
  STA $022D
  LDA #$07
  CLC
  ADC score2
  STA $0231
  JMP ReadUP1

STARTSCREEN:
  LDA #$60
  STA $0234
  LDA #$55
  STA $0237
  
  LDA #$60
  STA $0238
  LDA #$65
  STA $023B

  LDA #$60
  STA $023C
  LDA #$75
  STA $023F

  LDA #$60
  STA $0240
  LDA #$85
  STA $0243

  LDA #$60
  STA $0244
  LDA #$95
  STA $0247

WAITFORSTART:
  LDA $4016
  LDA $4016
  LDA $4016
  LDA $4016
  AND #%00000001
  BEQ ENDNMI
  LDA #$01
  STA gamestate

  LDA #$FF
  STA $0234
  STA $0237
  
  STA $0238
  STA $023B

  STA $023C
  STA $023F

  STA $0240
  STA $0243

  STA $0244
  STA $0247


ReadUP1:
  LDA $4016
  LDA $4016
  LDA $4016
  LDA $4016
  LDA $4016
  AND #%00000001
  BEQ ReadDown1

  LDX paddle1ytop
  DEX
  STX paddle1ytop

  LDA $0200
  SEC
  SBC #$01
  STA $0200

  LDA $0204
  SBC #$01
  STA $0204

  LDA $0208
  SBC #$01
  STA $0208

  LDA $020C
  SBC #$01
  STA $020C

  LDA $0210
  SBC #$01
  STA $0210

  LDA $0214
  SBC #$01
  STA $0214


ReadDown1:
  LDA $4016
  AND #%00000001
  BEQ ReadUP2

  LDX paddle1ytop
  INX
  STX paddle1ytop

  LDA $0200
  CLC
  ADC #$01
  STA $0200

  LDA $0204
  ADC #$01
  STA $0204

  LDA $0208
  ADC #$01
  STA $0208

  LDA $020C
  ADC #$01
  STA $020C

  LDA $0210
  ADC #$01
  STA $0210

  LDA $0214
  ADC #$01
  STA $0214

ReadUP2:
  LDA $4017
  LDA $4017
  LDA $4017
  LDA $4017
  LDA $4017
  AND #%00000001
  BEQ ReadDown2

  LDX paddle2ytop
  DEX
  STX paddle2ytop

  LDA $0218
  SEC
  SBC #$01
  STA $0218

  LDA $021C
  SBC #$01
  STA $021C

  LDA $0220
  SBC #$01
  STA $0220

  LDA $0224
  SBC #$01
  STA $0224

  LDA $0228
  SBC #$01
  STA $0228

  ; LDA $022C
  ; SBC #$01
  ; STA $022C

ReadDown2:
  LDA $4017
  AND #%00000001
GOHORIZONTAL:
  BEQ HORIZONTAL

  LDX paddle2ytop
  INX
  STX paddle2ytop

  LDA $0218
  CLC
  ADC #$01
  STA $0218

  LDA $021C
  ADC #$01
  STA $021C

  LDA $0220
  ADC #$01
  STA $0220

  LDA $0224
  ADC #$01
  STA $0224

  LDA $0228
  ADC #$01
  STA $0228

  ; LDA $022C
  ; ADC #$01
  ; STA $022C

HORIZONTAL:
  LDA ballx
  CMP #$20
  BEQ ALIGNLEFTPADDLE
  CMP #$D0
  BEQ ALIGNRIGHTPADDLE
  JMP CHECKWALL

ALIGNLEFTPADDLE:
  LDA bally
  CMP paddle1ytop
  BCS GORIGHT
  BCC MVLEFT
  ;JMP MVRIGHT

ALIGNRIGHTPADDLE:
  LDA bally
  CMP paddle2ytop
  BCS GOLEFT
  JMP MVRIGHT


GORIGHT:
  LDA bally
  SEC
  SBC #$20
  CMP paddle1ytop
  BCS CHECKWALL
  BCC MVRIGHT
  JMP MVRIGHT

GOLEFT:
  LDA bally
  SEC
  SBC #$20
  CMP paddle2ytop
  BCS CHECKWALL
  BCC MVLEFT
  JMP MVLEFT

CHECKWALL:
  LDA ballx
  CMP #RIGHTWALL
  BCS RESETLEFT

  CMP #LEFTWALL
  BCC RESETRIGHT
  BEQ RESETRIGHT

  JMP NEXTMV

RESETLEFT:
  LDA #$80
  STA ballx
  LDA #$20
  STA bally
  LDX score2
  INX
  STX score2

MVLEFT:
  LDA #$01
  STA ballleft
  LDA #$00
  STA ballright
  JMP NEXTMV

RESETRIGHT
  LDA #$80
  STA ballx
  LDA #$20
  STA bally
  LDX score1
  INX
  STX score1

MVRIGHT:
  LDA #$01
  STA ballright
  LDA #$00
  STA ballleft
  JMP NEXTMV

NEXTMV:
  LDX ballright
  CPX #$01
  BCS RIGHT
  BCC LEFT

RIGHT:
  LDX ballx
  INX
  STX ballx
  JMP VERTICAL

LEFT:
  LDX ballx
  DEX
  STX ballx
  JMP VERTICAL

VERTICAL:
  LDA bally
  
  CMP #TOPWALL
  BCC MVUP
  BEQ MVUP

  CMP #BOTTOMWALL
  BCS MVDOWN

  JMP NEXTVERTMV

MVDOWN:
  LDA #$01
  STA balldown
  LDA #$00
  STA ballup
  JMP NEXTVERTMV

MVUP:
  LDA #$01
  STA ballup
  LDA #$00
  STA balldown
  JMP NEXTVERTMV

NEXTVERTMV:
  LDY ballup
  CPY #$01
  BCS UP
  JMP DOWN

UP:
  LDY bally
  INY
  STY bally
  JMP CONTINUE

DOWN:
  LDY bally
  DEY
  STY bally
  JMP CONTINUE


CONTINUE:
  LDX ballx
  STX $0203
  LDY bally
  STY $0200
  
  LDA score1
  CMP #$09
  BCS ENDGAME

  LDA score2
  CMP #$09
  BCS ENDGAME

  JMP RTILABEL 

ENDGAME:
  LDX #$00
  LDA #$03
  STA gamestate

  LDA #$07
  CLC
  ADC score1
  STA $022D
  LDA #$07
  CLC
  ADC score2
  STA $0231

ENDSCREEN:
  LDA #$00
  STA $0200, x
  INX
  CPX #$29
  BNE ENDSCREEN

  LDX #$00
PRINTGAME:  
  LDA #$60
  STA $0248
  LDA #$70
  STA $024B

  LDA #$60
  STA $024C
  LDA #$80
  STA $024F

  LDA #$60
  STA $0250
  LDA #$90
  STA $0253

  LDA #$60
  STA $0254
  LDA #$A0
  STA $0257

  LDA #$70
  STA $0258
  LDA #$70
  STA $025B

  LDA #$70
  STA $025C
  LDA #$80
  STA $025F

  LDA #$70
  STA $0260
  LDA #$90
  STA $0263

  LDA #$70
  STA $0264
  LDA #$A0
  STA $0267

ENDLOOP:
  JMP ENDLOOP
 

RTILABEL:  
  RTI        ; return from interrupt
;;;;;;;;;;;;;;  
  
  
;Not my code Start   
  .bank 1
  .org $E000
palette:
  .db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F
  .db $0F,$31,$30,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C

sprites:
     ;vert tile attr horiz
  .db $80, $00, $02, $80   ;ball    00

  .db $20, $02, $02, $20   ;paddle1 04
  .db $25, $02, $02, $20   ;paddle1 08
  .db $29, $02, $02, $20   ;paddle1 0C
  .db $30, $02, $02, $20   ;paddle1 0F
  .db $36, $02, $02, $20   ;paddle1 10

  .db $20, $02, $02, $D0   ;paddle2 14
  .db $25, $02, $02, $D0   ;paddle2 18
  .db $29, $02, $02, $D0   ;paddle2 1C
  .db $30, $02, $02, $D0   ;paddle2 1F
  .db $36, $02, $02, $D0   ;paddle2 20

  .db $10, $07, $02, $90   ;p1score 24
  .db $10, $07, $02, $70   ;p2score 28

  .db $00, $2D, $01, $FF   ;S
  .db $00, $2E, $01, $FF   ;T
  .db $00, $1B, $01, $FF   ;A
  .db $00, $2C, $01, $FF   ;R
  .db $00, $2E, $01, $FF   ;T

  .db $00, $21, $01, $FF   ;G
  .db $00, $1B, $01, $FF   ;A
  .db $00, $27, $01, $FF   ;M
  .db $00, $1F, $01, $FF   ;E

  .db $00, $29, $01, $FF   ;O
  .db $00, $30, $01, $FF   ;V
  .db $00, $1F, $01, $FF   ;E
  .db $00, $2C, $01, $FF   ;R


  ; $1B p2score A
  ; $1C p2score B
  ; $1D p2score C
  ; $1E p2score D
  ; $1F p2score E
  ; $20 p2score F
  ; $21 p2score G
  ; $22 p2score H
  ; $23 p2score I
  ; $24 p2score J
  ; $25 p2score k
  ; $26 p2score L
  ; $27 p2score M
  ; $28 p2score N
  ; $29 p2score O
  ; $2A p2score P
  ; $2B p2score Q
  ; $2C p2score R
  ; $2D p2score S
  ; $2E p2score T
  ; $2F p2score U
  ; $30 p2score V
  ; $31 p2score W
  ; $32 p2score X
  ; $33 p2score Y
  ; $34 p2score Z

  ; .db $88, $08, $02, $50
  ; .db $88, $09, $02, $40
  ; .db $88, $0A, $02, $30
  ; .db $88, $0B, $02, $20
  ; .db $88, $0C, $02, $10
  ; .db $88, $0D, $02, $00
  ; .db $80, $0E, $02, $30
  ; .db $70, $0F, $02, $30

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used
  


;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
;Not my code END   
  .incbin "pongchr.nes"   ;includes 8KB graphics file, created file myself using YY-CHR.NET