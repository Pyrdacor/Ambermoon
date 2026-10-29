; Atari hardware registers and system vectors (ST, STE and Falcon)
; The video hardware is in VIDEO.I (the Falcon version has its own).

	include	ST_KERNEL/VIDEO.I

; ---------- MFP 68901 -------------------------------
MFP_IERA	EQU	$fffffa07	; Interrupt enable A (bit 0 = Timer B)
MFP_IERB	EQU	$fffffa09	; Interrupt enable B (bit 6 = ACIA, bit 5 = Timer C)
MFP_IPRA	EQU	$fffffa0b	; Interrupt pending A
MFP_ISRA	EQU	$fffffa0f	; In service A
MFP_ISRB	EQU	$fffffa11	; In service B
MFP_IMRA	EQU	$fffffa13	; Interrupt mask A
MFP_IMRB	EQU	$fffffa15	; Interrupt mask B
MFP_VR	EQU	$fffffa17	; Vector register
MFP_TBCR	EQU	$fffffa1b	; Timer B control (8 = event count mode)
MFP_TBDR	EQU	$fffffa21	; Timer B data
MFP_TCDCR	EQU	$fffffa1d	; Timer C / D control (C : bits 4-6, D : bits 0-2)

; ---------- ACIAs -----------------------------------
ACIA_kbd_ctrl	EQU	$fffffc00
ACIA_kbd_data	EQU	$fffffc02
ACIA_midi_ctrl	EQU	$fffffc04
ACIA_midi_data	EQU	$fffffc06

; ---------- Exception vectors -----------------------
Vec_VBL	EQU	$70
Vec_ACIA	EQU	$118
Vec_Timer_B	EQU	$120

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
