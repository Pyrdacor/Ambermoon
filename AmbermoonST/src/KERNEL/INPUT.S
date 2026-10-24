; Keyboard & mouse input (Atari ST)
; Replaces KERNEL/INPUT.S of the Amiga version (input.device handler).
; The IKBD sends key codes and mouse packets through the keyboard ACIA.

	SECTION	Program,code

Key_buffer_size	EQU	32

;*****************************************************************************
; [ ACIA interrupt (keyboard & mouse) ]
;*****************************************************************************
ACIA_interrupt:
	movem.l	d0/d1/a0,-(sp)
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
	movem.l	(sp)+,d0/d1/a0
	rte

;*****************************************************************************
; [ Handle one byte from the IKBD ]
;   IN : d0 - Byte (.b)
; Changed registers : d0,d1,a0
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
	cmpi.b	#$f8,(a0)			; Complete : mouse packet ?
	bcs.s	.Exit
	cmpi.b	#$fb,(a0)
	bhi.s	.Exit
	jmp	Mouse_packet
.Header:	cmpi.b	#$f6,d0			; Packet header ?
	bcs.s	.Key
	moveq.l	#0,d1
	move.b	d0,d1
	subi.w	#$f6,d1
	move.b	.Sizes(pc,d1.w),d1
	move.w	d1,IKBD_count
	move.w	#1,IKBD_index
	move.b	d0,IKBD_packet
.Exit:	rts
.Sizes:	dc.b	7,5,2,2,2,2,6,2,1,1	; $f6 ... $ff
	even
; ---------- Key code -----------------------------
.Key:	moveq.l	#0,d1
	move.b	d0,d1
	bclr	#7,d1			; Key up ?
	lea.l	Key_state,a0
	sne	0(a0,d1.w)
	not.b	0(a0,d1.w)
	tst.b	d0
	bmi.s	.Exit
	move.w	Key_write,d1		; Store key event
	lea.l	Key_buffer,a0
	move.b	d0,0(a0,d1.w)
	addq.w	#1,d1
	andi.w	#Key_buffer_size-1,d1
	cmp.w	Key_read,d1		; Buffer full ?
	beq.s	.Exit
	move.w	d1,Key_write
	rts

;*****************************************************************************
; [ Read the next key event ]
;  OUT : d0 - Key code (scan code) / 0 = no key (.w)
; Changed registers : d0
;*****************************************************************************
Read_key:
	move.l	a0,-(sp)
	moveq.l	#0,d0
	move.w	Key_read,d0
	cmp.w	Key_write,d0
	beq.s	.None
	lea.l	Key_buffer,a0
	move.b	0(a0,d0.w),d0
	move.w	d0,-(sp)
	move.w	Key_read,d0
	addq.w	#1,d0
	andi.w	#Key_buffer_size-1,d0
	move.w	d0,Key_read
	move.w	(sp)+,d0
	andi.w	#$ff,d0
	bra.s	.Exit
.None:	moveq.l	#0,d0
.Exit:	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Clear the keyboard state and the key buffer ]
; All registers are restored
; NOTE :
;   - When the ACIA handler is installed in the middle of an IKBD packet,
;     a data byte may be taken for a key code, so this is called once
;     after the start.
;*****************************************************************************
Clear_keyboard:
	movem.l	d7/a0,-(sp)
	move.w	sr,-(sp)
	move.w	#$2700,sr
	lea.l	Key_state,a0
	moveq.l	#128/4-1,d7
.Loop:	clr.l	(a0)+
	dbra	d7,.Loop
	clr.w	Key_read
	clr.w	Key_write
	move.w	(sp)+,sr
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Check if a key is pressed ]
;   IN : d0 - Key code (scan code) (.w)
;  OUT : ne - pressed, eq - not pressed
; All registers are restored
;*****************************************************************************
Key_pressed:
	move.l	a0,-(sp)
	lea.l	Key_state,a0
	tst.b	0(a0,d0.w)
	move.l	(sp)+,a0
	rts

	SECTION	Fast_BSS,bss
IKBD_count:	ds.w 1
IKBD_index:	ds.w 1
IKBD_packet:	ds.b 8
Key_state:	ds.b 128
Key_buffer:	ds.b Key_buffer_size
Key_read:	ds.w 1
Key_write:	ds.w 1
