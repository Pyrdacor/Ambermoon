; ST/STE video hardware (Shifter) and the screen format
; (The Falcon version has its own VIDEO.I.)

; ---------- Video (Shifter) -------------------------
Video_base_high	EQU	$ffff8201
Video_base_mid	EQU	$ffff8203
Video_resolution	EQU	$ffff8260
Video_sync	EQU	$ffff820a	; Bit 1 : 50 Hz
Palette_regs	EQU	$ffff8240

; ---------- Screen ----------------------------------
; Low resolution : 4 planes, word interleaved (a chunk of 16 pixels is 4
; words)
Screen_bytes_per_line	EQU	160
Screen_size	EQU	32000
ST_bytes_per_line	EQU	Screen_bytes_per_line
ST_screen_size	EQU	Screen_size

; ---------- Mouse pointer ---------------------------
Pointer_save_size	EQU	16*16		; Background : 16 lines * 2 chunks
