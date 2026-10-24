; Text output (Atari ST)
; Replaces KERNEL/TEXT.S of the Amiga version.
; The glyphs are drawn into a 1 bit line buffer like in the Amiga version
; (Draw_glyphs and Render_glyph are taken from it, without the blitter),
; then the buffer is put on the screen with the shadow and ink colours.
; The font (Glyph_mapping and Glyph_data of KERNEL/TEXTS.S) is loaded from
; FONT.BIN.

	SECTION	Program,code

Glyph_mapping	EQU	Font_data
Glyph_data	EQU	Font_data+224

;*****************************************************************************
; [ Print a text line ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to text (.l)
;  OUT : a0 - Pointer behind the text (.l)
; All other registers are restored
; NOTE :
;   - Uses [ Ink_colour ] and [ Shadow_colour ] (Amiga colour numbers,
;     shadow : -1 = none, drawn 1 pixel right and down).
;*****************************************************************************
Put_text_line:
	movem.l	d0-d7/a1-a4,-(sp)
	move.w	d0,-(sp)
	andi.w	#$f,d0
	jsr	Draw_glyphs
	move.l	a0,a4
	move.w	d0,d6			; Number of truncs
	addi.w	#15,d6
	lsr.w	#4,d6
	move.w	(sp)+,d0
	andi.w	#-$10,d0
	move.w	Shadow_colour,d4		; Shadow
	bmi.s	.No_shadow
	addq.w	#1,d1
	jsr	Get_ST_colour
	moveq.l	#1,d5
	jsr	Put_text_buffer
	subq.w	#1,d1
.No_shadow:	move.w	Ink_colour,d4		; Ink
	jsr	Get_ST_colour
	moveq.l	#0,d5
	jsr	Put_text_buffer
	move.l	a4,a0
	movem.l	(sp)+,d0-d7/a1-a4
	rts

;*****************************************************************************
; [ Put the text line buffer on the work screen ]
;   IN : d0 - X-coordinate (multiple of 16) (.w)
;        d1 - Y-coordinate (.w)
;        d4 - ST colour (.w)
;        d5 - Shift to the right (0 or 1) (.w)
;        d6 - Number of truncs (.w)
; All registers are restored
;*****************************************************************************
Put_text_buffer:
	movem.l	d0-d7/a0-a3/a6,-(sp)
	move.l	Work_screen,a1
	jsr	Get_screen_offset_d0d1
	lea.l	Text_line_buffer,a0
	move.w	d6,d7			; Truncs to draw
	add.w	d5,d7
	lsr.w	#4,d0			; Not more than the screen
	moveq.l	#20,d2
	sub.w	d0,d2
	cmp.w	d2,d7
	ble.s	.Ok
	move.w	d2,d7
.Ok:	subq.w	#1,d7
	bmi	.Exit
	move.w	#200,d3			; Lines
	sub.w	d1,d3
	ble	.Exit
	cmp.w	#Char_height,d3
	ble.s	.Ok2
	moveq.l	#Char_height,d3
.Ok2:	subq.w	#1,d3
.Line:	move.l	a0,a2
	move.l	a1,a3
	moveq.l	#0,d2			; Previous word
	move.w	d7,d0
	move.w	d6,a6			; Words left in the buffer line
.Trunc:	swap	d2			; Previous word -> high word
	clr.w	d2
	cmp.w	#0,a6
	ble.s	.Empty
	move.w	(a2)+,d2
	subq.w	#1,a6
.Empty:	move.l	d2,d1			; Mask
	lsr.l	d5,d1
	btst	#0,d4			; Plane 0
	beq.s	.C0
	or.w	d1,(a3)+
	bra.s	.P1
.C0:	not.w	d1
	and.w	d1,(a3)+
	not.w	d1
.P1:	btst	#1,d4			; Plane 1
	beq.s	.C1
	or.w	d1,(a3)+
	bra.s	.P2
.C1:	not.w	d1
	and.w	d1,(a3)+
	not.w	d1
.P2:	btst	#2,d4			; Plane 2
	beq.s	.C2
	or.w	d1,(a3)+
	bra.s	.P3
.C2:	not.w	d1
	and.w	d1,(a3)+
	not.w	d1
.P3:	btst	#3,d4			; Plane 3
	beq.s	.C3
	or.w	d1,(a3)+
	bra.s	.Next
.C3:	not.w	d1
	and.w	d1,(a3)+
.Next:	dbra	d0,.Trunc
	lea.l	40(a0),a0			; Next line
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d3,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a3/a6
	rts

;*****************************************************************************
; [ Draw the glyphs of a text line into the text line buffer ]
;   IN : d0 - X-offset (0...15) (.w)
;        a0 - Pointer to text (.l)
;  OUT : d0 - Width in pixels (.w)
;        a0 - Pointer behind the text (.l)
; NOTE :
;   - Taken from the Amiga version. Text commands (~XXXX~) are skipped.
;*****************************************************************************
Draw_glyphs:
	movem.l	d1/a1-a3,-(sp)
	move.l	a0,a2
	lea.l	Text_line_buffer,a1	; Clear buffer
	moveq.l	#200/4-1,d1
.Clear:	clr.l	(a1)+
	dbra	d1,.Clear
	lea.l	Text_line_buffer,a1
	lea.l	Glyph_data,a0
	lea.l	Glyph_mapping,a3
.Loop:	move.b	(a2)+,d1			; Get next character
	beq.s	.Exit
	cmp.b	#Command_char,d1		; Text command ?
	bne.s	.No_command
.Skip_command:
	move.b	(a2)+,d1
	beq.s	.Exit
	cmp.b	#Command_char,d1
	bne.s	.Skip_command
	bra.s	.Loop
.No_command:
	cmp.b	#32,d1			; Space ?
	beq.s	.Space
	cmp.b	#36,d1			; Hard space ?
	beq.s	.Space
	cmp.b	#32,d1			; Control character ?
	bcs.s	.Loop
	andi.w	#$ff,d1
	move.b	-32(a3,d1.w),d1		; Get glyph
	bmi.s	.Loop
	jsr	Render_glyph
.Space:	addq.w	#6,d0			; Next position
	cmp.w	#314,d0
	bmi.s	.Loop
.Loop2:	tst.b	(a2)+			; Skip the rest
	bne.s	.Loop2
.Exit:	move.l	a2,a0
	movem.l	(sp)+,d1/a1-a3
	rts

;*****************************************************************************
; [ Draw one glyph into the text line buffer ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Glyph index (.w)
;        a0 - Pointer to font (.l)
;        a1 - Pointer to text line buffer (.l)
; All registers are restored
; NOTE :
;   - Taken from the Amiga version.
;*****************************************************************************
Render_glyph:
	movem.l	d0/d1/d7/a0/a1,-(sp)
	andi.w	#$ff,d1
	mulu.w	#5,d1
	lea.l	0(a0,d1.w),a0
	moveq.l	#7,d1
	and.w	d0,d1
	lsr.w	#3,d0
	add.w	d0,a1
	moveq.l	#4,d7
.Loop:	moveq.l	#0,d0
	move.b	(a0)+,d0
	ror.w	d1,d0
	or.b	d0,(a1)+
	lsr.w	#8,d0
	or.b	d0,(a1)
	lea.l	39(a1),a1
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d1/d7/a0/a1
	rts

	SECTION	Fast_BSS,bss
Ink_colour:	ds.w 1
Shadow_colour:	ds.w 1
Text_line_buffer:	ds.b 200
