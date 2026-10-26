; Atari ST/STE hardware registers and system vectors

; ---------- Video (Shifter) -------------------------
Video_base_high	EQU	$ffff8201
Video_base_mid	EQU	$ffff8203
Video_resolution	EQU	$ffff8260
Palette_regs	EQU	$ffff8240

; ---------- MFP 68901 -------------------------------
MFP_IERA	EQU	$fffffa07	; Interrupt enable A (bit 0 = Timer B)
MFP_IERB	EQU	$fffffa09	; Interrupt enable B (bit 6 = ACIA, bit 5 = Timer C)
MFP_ISRA	EQU	$fffffa0f	; In service A
MFP_ISRB	EQU	$fffffa11	; In service B
MFP_IMRA	EQU	$fffffa13	; Interrupt mask A
MFP_IMRB	EQU	$fffffa15	; Interrupt mask B
MFP_VR	EQU	$fffffa17	; Vector register
MFP_TBCR	EQU	$fffffa1b	; Timer B control (8 = event count mode)
MFP_TBDR	EQU	$fffffa21	; Timer B data

; ---------- ACIAs -----------------------------------
ACIA_kbd_ctrl	EQU	$fffffc00
ACIA_kbd_data	EQU	$fffffc02
ACIA_midi_ctrl	EQU	$fffffc04
ACIA_midi_data	EQU	$fffffc06

; ---------- Exception vectors -----------------------
Vec_VBL	EQU	$70
Vec_ACIA	EQU	$118
Vec_Timer_B	EQU	$120

; ---------- Screen ----------------------------------
ST_bytes_per_line	EQU	160
ST_screen_size	EQU	32000

; ---------- GEMDOS / BIOS / XBIOS -------------------
GEMDOS	EQU	1
BIOS	EQU	13
XBIOS	EQU	14
Pterm0	EQU	$00
Super	EQU	$20
Fopen	EQU	$3d
Fclose	EQU	$3e
Fread	EQU	$3f
Mshrink	EQU	$4a
Fsetdta	EQU	$1a
Fcreate	EQU	$3c
Fwrite	EQU	$40
Fseek	EQU	$42
Malloc	EQU	$48
Mfree	EQU	$49
Fsfirst	EQU	$4e
Physbase	EQU	2
Logbase	EQU	3
Getrez	EQU	4
Setscreen	EQU	5
Keytbl	EQU	16
