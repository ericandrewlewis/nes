; INES header setup
  ; Specify a single (1) 16kb PRG bank.
  .inesprg 1
  ; Specity a single (1) 8kb CHR bank.
  .ineschr 1
  ; Specify the NES mapper. mapper 0 = NROM, no bank swapping, no mapper.
  .inesmap 0
  ; Specify VRAM background mirroring of the banks. vertical mirroring.
  .inesmir 1

  .org $8000
  .bank 0

Start:
  ; PPU Control Register #1 configuration
  ;    D7: Execute NMI on VBlank
  ;           0 = Disabled
  ;           1 = Enabled
  ;    D6: PPU Master/Slave Selection --+
  ;           0 = Master                +-- UNUSED
  ;           1 = Slave               --+
  ;    D5: Sprite Size
  ;           0 = 8x8
  ;           1 = 8x16
  ;    D4: Background Pattern Table Address
  ;           0 = $0000 (VRAM)
  ;           1 = $1000 (VRAM)
  ;    D3: Sprite Pattern Table Address
  ;           0 = $0000 (VRAM)
  ;           1 = $1000 (VRAM)
  ;    D2: PPU Address Increment
  ;           0 = Increment by 1
  ;           1 = Increment by 32
  ; D1-D0: Name Table Address
  ;         00 = $2000 (VRAM)
  ;         01 = $2400 (VRAM)
  ;         10 = $2800 (VRAM)
  ;         11 = $2C00 (VRAM)
  ;     76543210 <-- bit digit identifiers
  lda #%00001000
  sta $2000


  ; PPU Control Register #2 configuration
  ; D7-D5: Full Background Color (when D0 == 1)
  ;        000 = None  +------------+
  ;        001 = Green              | NOTE: Do not use more
  ;        010 = Blue               |       than one type
  ;        100 = Red   +------------+
  ; D7-D5: Color Intensity (when D0 == 0)
  ;        000 = None            +--+
  ;        001 = Intensify green    | NOTE: Do not use more
  ;        010 = Intensify blue     |       than one type
  ;        100 = Intensify red   +--+
  ;    D4: Sprite Visibility
  ;          0 = Sprites not displayed
  ;          1 = Sprites visible
  ;    D3: Background Visibility
  ;          0 = Background not displayed
  ;          1 = Background visible
  ;    D2: Sprite Clipping
  ;          0 = Sprites invisible in left 8-pixel column
  ;          1 = No clipping
  ;    D1: Background Clipping
  ;          0 = BG invisible in left 8-pixel column
  ;          1 = No clipping
  ;    D0: Display Type
  ;          0 = Color display
  ;          1 = Monochrome display
  ;
  ;     76543210 <-- bit digit identifier
  lda #%00011110
  sta $2001

  ; Prepare to write the palette data.
  ; Set the PPU VRAM to $3F00, where the palette data starts.
  lda #$3F
  sta $2006
  lda #$00
  sta $2006

  ; Write the background palette, $3F00 - $3F0F
  ; $3F00 - Universal background color
  lda #$01
  sta $2007
  ; $3F01 - $3F03 - Background palette 0
  lda #$02
  sta $2007
  lda #$03
  sta $2007
  lda #$04
  sta $2007
  ; $3F04 - Universal background color (repeat)
  lda #$05
  sta $2007
  ; $3F05 - $3F07 - Background palette 1
  lda #$06
  sta $2007
  lda #$07
  sta $2007
  lda #$08
  sta $2007
  ; $3F08 - Universal background color (repeat)
  lda #$01
  sta $2007
  ; $3F09 - $3F0B - Background palette 2
  lda #$08
  sta $2007
  lda #$09
  sta $2007
  lda #$0A
  sta $2007
  ; $3F0C - Universal background color (repeat)
  lda #$01
  sta $2007
  ; $3F0D - $3F0F - Background palette 3
  lda #$11
  sta $2007
  lda #$15
  sta $2007
  lda #$19
  sta $2007
  ; Write Sprite Palette, $3F10 - $3f1f
  ; $3F10 - Universal background color (repeat)
  lda #$01
  sta $2007
  ; $3F11 - $3F13 - Sprite palette 0
  lda #$0D
  sta $2007
  lda #$08
  sta $2007
  lda #$2B
  sta $2007
  ; $3F14 - Universal background color (repeat)
  lda #$01
  sta $2007
  ; $3F15 - $3F17 - Sprite palette 1
  lda #$05
  sta $2007
  lda #$06
  sta $2007
  lda #$07
  sta $2007
  ; $3F18 - Universal background color (repeat)
  lda #$01
  sta $2007
  ; $3F19 - $3F1C - Sprite palette 2
  lda #$08
  sta $2007
  lda #$09
  sta $2007
  lda #$0A
  sta $2007
  ; $3F1C - Universal background color (repeat)
  lda #$01
  sta $2007
  ; $3F1D - $3F1F - Sprite palette 3
  lda #$0B
  sta $2007
  lda #$0C
  sta $2007
  lda #$0D
  sta $2007

; Loop until VBlank is done.
vwait:
  ; Reset the address latch
  lda $2002
  ; Hmm I'm commenting this out and it's working better? I wonder where I got this from?
  ; bpl vwait

  ; Prepare to write nametables.
  ; Set PPU to the start of VRAM at $2000, the beginning of the nametable.
  ; see https://wiki.nesdev.com/w/index.php/PPU_nametables
  lda #$21
  sta $2006
  lda #$00
  sta $2006

  ; a = the index of the inner loop to write to the nametable
  lda #$00
  ; x = the index of the top-level loop
  ldx #$00
  ; y = the index of the pattern table to write to the nametable
  ldy #$00

;
LoadBackgroundLoop:
  ; write a tile to PPU
  sty $2007
  ; increment the pattern tile index
  adc #$01
  ; break when we've gone through 256 tile writes
  cmp #$ff
  bne LoadBackgroundLoop
  inx
  cpx #$04
  bne LoadBackgroundLoop

Loop:
  jmp Loop

; Write the "Vector table," which starts at $FFFA.
  .bank 1
  .org $FFFA

  ; Set the routine to handle Non-Maskable Interrupt (NMI).
  ; NMI is called on every screen refresh (vblank).
  .dw 0

  ; Set the routine to handle reset.
  .dw Start

  ; Set the routine to handle IRQ (when a BRK instruction is hit).
  .dw 0 ; 0 is basically off

  ;
  .bank 2
  .org    $0000
  .incbin "mario.chr"  ;gotta be 8192 bytes long
