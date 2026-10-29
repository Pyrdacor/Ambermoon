; Falcon video hardware (VIDEL) and the screen format
; (Replaces VIDEO.I of the ST kernel.)

; ---------- Video (VIDEL) ---------------------------
Video_base_high	EQU	$ffff8201
Video_base_mid	EQU	$ffff8203
Video_base_low	EQU	$ffff820d
Videl_palette	EQU	$ffff9800	; 256 colours : RRRRRRxx GGGGGGxx 00000000 BBBBBBxx
ST_palette_regs	EQU	$ffff8240	; (the 16 colours of the ST modes)

; ---------- XBIOS (Falcon) --------------------------
Vsetscreen	EQU	5		; = Setscreen, with the mode (resolution 3)
Vsetmode	EQU	88
VgetMonitor	EQU	89

; Video modes of Vsetmode
Mode_BPS8	EQU	$0003		; 8 planes (256 colours)
Mode_VGA	EQU	$0010
Mode_PAL	EQU	$0020		; 50 Hz
Mode_VERTFLAG	EQU	$0100		; (VGA : every line twice)

; ---------- Screen ----------------------------------
; 320 x 200, 8 planes, word interleaved (a chunk of 16 pixels is 8 words).
; The colour of a pixel is the bank of its line (planes 5-7, RASTER.S) and
; the Amiga colour (planes 0-4).
Screen_bytes_per_line	EQU	320
Screen_size	EQU	64000
Chunk_bytes	EQU	16
; The dummy screens of the original (text, items and combat are drawn there
; and taken with Get_block) : the line of the Falcon is longer than the
; Amiga line.
Dummy_bytes_per_line	EQU	Screen_bytes_per_line

; ---------- Mouse pointer ---------------------------
Pointer_save_size	EQU	16*32		; Background : 16 lines * 2 chunks
