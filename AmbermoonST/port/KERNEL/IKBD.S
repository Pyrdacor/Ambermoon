; ST kernel : keyboard & mouse (IKBD through the keyboard ACIA)
;
; Replaces the input.device handler of the Amiga version ([ Run_input_handler ]
; in KERNEL/INPUT.S, which stays unused). A key press is stored with
; [ Store_Kev ] in the format of the Amiga version :
;   bits 0-7   ASCII (Latin-1, from the TOS keyboard tables)
;   bits 16-23 Amiga raw key code
;   bits 24-28 qualifiers (Input_event_buffer in KERNEL/INPUT.S) : 24 shift,
;              25 control, 26 alternate, 27 caps lock, 28 Amiga (Help is
;              the Amiga key on the ST)
; The mouse movement and the buttons are collected here and read by
; [ Update_mouse ] (MOUSE.S) in the vertical blank, like the hardware
; registers of the Amiga.

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the keyboard tables ]
; All registers are restored
; NOTE :
;   - Must be called while the TOS is active.
;*****************************************************************************
Init_IKBD:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	#-1,-(sp)			; Keytbl(-1, -1, -1)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#Keytbl,-(sp)
	trap	#XBIOS
	lea.l	14(sp),sp
	move.l	d0,a0
	move.l	(a0)+,Keytable_normal
	move.l	(a0)+,Keytable_shift
	move.l	(a0)+,Keytable_caps
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;*****************************************************************************
; [ ACIA interrupt (keyboard & mouse) ]
;*****************************************************************************
ACIA_interrupt:
	movem.l	d0-d2/a0/a1,-(sp)
.Again:	move.b	ACIA_kbd_ctrl,d0		; Keyboard ACIA
	bpl.s	.Midi			; Interrupt request ?
	btst	#0,d0			; Receive buffer full ?
	beq.s	.Midi
	move.b	ACIA_kbd_data,d0
	jsr	IKBD_byte
	bra.s	.Again
.Midi:	move.b	ACIA_midi_ctrl,d0		; MIDI ACIA (ignore data)
	bpl.s	.Exit
	move.b	ACIA_midi_data,d0
	bra.s	.Again
.Exit:	bclr	#6,MFP_ISRB
	movem.l	(sp)+,d0-d2/a0/a1
	rte

;*****************************************************************************
; [ Handle one byte from the IKBD ]
;   IN : d0 - Byte (.b)
; Changed registers : d0,d1,d2,a0,a1
;*****************************************************************************
IKBD_byte:
	move.w	IKBD_count,d1		; Inside a packet ?
	beq.s	.Header
	lea.l	IKBD_packet,a0		; Store byte
	move.w	IKBD_index,d1
	move.b	d0,0(a0,d1.w)
	addq.w	#1,IKBD_index
	subq.w	#1,IKBD_count
	bne.s	.Exit
	move.b	(a0),d0			; Complete : mouse packet ?
	cmp.b	#$f8,d0
	bcs.s	.Exit
	cmp.b	#$fb,d0
	bhi.s	.Exit
	move.b	d0,ST_mouse_buttons		; Yes (bit 1 left, bit 0 right)
	move.b	1(a0),d0			; Collect the movement
	ext.w	d0
	add.w	d0,ST_mouse_dx
	move.b	2(a0),d0
	ext.w	d0
	add.w	d0,ST_mouse_dy
.Exit:	rts
.Header:	cmpi.b	#$f6,d0			; Packet header ?
	bcs.s	Key_code
	moveq.l	#0,d1
	move.b	d0,d1
	subi.w	#$f6,d1
	move.b	.Sizes(pc,d1.w),d1
	move.w	d1,IKBD_count
	move.w	#1,IKBD_index
	move.b	d0,IKBD_packet
	rts
.Sizes:	dc.b	7,5,2,2,2,2,6,2,1,1	; $f6 ... $ff
	even

;*****************************************************************************
; [ Handle a key code ]
;   IN : d0 - ST scan code (bit 7 = released) (.b)
; Changed registers : d0,d1,d2,a0,a1
;*****************************************************************************
Key_code:
	moveq.l	#0,d1
	move.b	d0,d1
	bclr	#7,d1
	lea.l	Qualifier_keys(pc),a0	; Qualifier ?
.Find:	move.b	(a0)+,d2
	beq.s	.Normal
	cmp.b	d2,d1
	beq.s	.Qualifier
	addq.l	#1,a0
	bra.s	.Find
.Qualifier:	move.b	(a0),d2			; Bit
	cmp.b	#$3a,d1			; Caps lock toggles
	bne.s	.Hold
	tst.b	d0
	bmi.s	.Rts
	bchg	d2,ST_qualifiers
.Rts:	rts
.Hold:	tst.b	d0
	bmi.s	.Up
	bset	d2,ST_qualifiers
	rts
.Up:	bclr	d2,ST_qualifiers
	rts
.Normal:	tst.b	d0			; Released ?
	bmi.s	.Exit
	move.b	d1,IKBD_last_key
	lea.l	ST_to_Amiga_keys(pc),a0	; Amiga raw key code
	move.b	0(a0,d1.w),d0
	cmp.b	#$ff,d0			; Unknown ?
	beq.s	.Exit
	andi.l	#$ff,d0
	swap	d0
	move.b	ST_qualifiers,d2		; Qualifiers
	moveq.l	#0,d1
	move.b	d2,d1
	ror.l	#8,d1
	or.l	d1,d0
	move.l	Keytable_normal,a1		; ASCII
	btst	#0,d2			; (shift)
	beq.s	.No_shift
	move.l	Keytable_shift,a1
	bra.s	.Table
.No_shift:	btst	#3,d2			; (caps lock)
	beq.s	.Table
	move.l	Keytable_caps,a1
.Table:	moveq.l	#0,d1
	move.b	IKBD_last_key,d1
	move.b	0(a1,d1.w),d1
	lea.l	Atari_to_Latin1(pc),a0	; Umlauts
.Umlaut:	move.b	(a0)+,d2
	beq.s	.Ascii
	cmp.b	d2,d1
	beq.s	.Convert
	addq.l	#1,a0
	bra.s	.Umlaut
.Convert:	move.b	(a0),d1
.Ascii:	move.b	d1,d0
	jmp	Store_Kev
.Exit:	rts

; ST scan code, qualifier bit (in byte 3 of the key event)
Qualifier_keys:
	dc.b	$2a,0,$36,0		; Shift
	dc.b	$1d,1			; Control
	dc.b	$38,2			; Alternate
	dc.b	$3a,3			; Caps lock
	dc.b	$62,4			; Help = Amiga key
	dc.b	0
	even

; Atari character, Latin-1 character
Atari_to_Latin1:
	dc.b	$84,$e4,$94,$f6,$81,$fc	; ä ö ü
	dc.b	$8e,$c4,$99,$d6,$9a,$dc	; Ä Ö Ü
	dc.b	$9e,$df,0			; ß
	even

; ST scan code -> Amiga raw key code ($ff = none)
ST_to_Amiga_keys:
	dc.b	$ff,$45,$01,$02,$03,$04,$05,$06	; $00 : -, ESC, 1-6
	dc.b	$07,$08,$09,$0a,$0b,$0c,$41,$42	; $08 : 7-0, ß, ´, BS, TAB
	dc.b	$10,$11,$12,$13,$14,$15,$16,$17	; $10 : Q-I
	dc.b	$18,$19,$1a,$1b,$44,$63,$20,$21	; $18 : O, P, ü, +, RETURN, CTRL, A, S
	dc.b	$22,$23,$24,$25,$26,$27,$28,$29	; $20 : D-L, ö
	dc.b	$2a,$2b,$60,$00,$31,$32,$33,$34	; $28 : ä, #, LSHIFT, ~, Y, X, C, V
	dc.b	$35,$36,$37,$38,$39,$3a,$61,$5d	; $30 : B, N, M, ',', '.', '-', RSHIFT, -
	dc.b	$64,$40,$62,$50,$51,$52,$53,$54	; $38 : ALT, SPACE, CAPS, F1-F5
	dc.b	$55,$56,$57,$58,$59,$ff,$ff,$ff	; $40 : F6-F10, -, -, HOME
	dc.b	$4c,$ff,$4a,$4f,$ff,$4e,$5e,$ff	; $48 : UP, -, KP-, LEFT, -, RIGHT, KP+, -
	dc.b	$4d,$ff,$ff,$46,$ff,$ff,$ff,$ff	; $50 : DOWN, -, INSERT, DELETE
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	; $58
	dc.b	$30,$45,$5f,$5a,$5b,$5c,$5d,$3d	; $60 : <, UNDO (= ESC), HELP, KP( ) / *, KP7
	dc.b	$3e,$3f,$2d,$2e,$2f,$1d,$1e,$1f	; $68 : KP8, KP9, KP4-6, KP1-3
	dc.b	$0f,$3c,$43,$ff,$ff,$ff,$ff,$ff	; $70 : KP0, KP., KP ENTER
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	; $78
	even

	SECTION	Fast_BSS,bss
Keytable_normal:	ds.l 1
Keytable_shift:	ds.l 1
Keytable_caps:	ds.l 1
ST_mouse_dx:	ds.w 1
ST_mouse_dy:	ds.w 1
IKBD_count:	ds.w 1
IKBD_index:	ds.w 1
IKBD_packet:	ds.b 8
ST_mouse_buttons:	ds.b 1
ST_qualifiers:	ds.b 1			; Bits 0-4 : shift, ctrl, alt, caps, Amiga
IKBD_last_key:	ds.b 1
	even
