; Falcon kernel : the colours on the screen (VIDEL, 256 colours)
; The hardware part of the colours (COLOURS.S : the fading of the Amiga
; version). (Replaces RASTER.S of the ST kernel.)
;
; Every palette of a raster list gets a bank of 32 colours : the first
; palette (from the top of the screen) bank 0 (colours 0-31), the second
; bank 1 (32-63) and so on, at most 8. A pixel is bank * 32 + Amiga colour,
; the graphics routines set the planes 5-7 to the bank of the line
; ([ Get_line_banks ]). So the original colours are shown, without raster
; interrupts.
; [ Render_raster ] puts the (faded) colours of [ Current_RL ] into the
; shadow palette, the next vertical blank copies it into the VIDEL
; ([ Raster_VBL ]).
; Not yet : the colour ranges (one colour changed in every line, e.g. the
; gradient behind the portraits).

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the colours ]
; All registers are restored
;*****************************************************************************
Init_raster:
	movem.l	d7/a0,-(sp)
	lea.l	Shadow_palette,a0
	move.w	#256-1,d7
.Loop:	clr.l	(a0)+
	dbra	d7,.Loop
	move.w	#8,Shadow_banks
	st	Palette_dirty
	clr.l	Banks_RL
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Install / remove the raster interrupt ]
; NOTE :
;   - The Falcon needs none.
;*****************************************************************************
Install_raster:
Remove_raster:
	rts

;*****************************************************************************
; [ Remember the target colours of a palette entry of Current_RL ]
; NOTE :
;   - Nothing to do : the colours of Current_RL are shown as they are.
;*****************************************************************************
Store_RL_source:
	rts

;*****************************************************************************
; [ Make the colours of the banks from Current_RL ]
; All registers are restored
; NOTE :
;   - Called by [ Colour_handler ] in the vertical blank. The next vertical
;     blank shows them.
;*****************************************************************************
Render_raster:
	movem.l	d0-d7/a0-a2,-(sp)
	lea.l	Current_RL,a0
	lea.l	Shadow_palette,a1
	lea.l	Nibble_to_videl,a2
	moveq.l	#0,d6			; Number of banks
.Loop:	move.b	(a0)+,d0			; Get entry type
	cmp.b	#-1,d0
	beq.s	.End
	addq.l	#1,a0			; (line)
	tst.b	d0
	bne.s	.Range
	cmp.w	#8,d6			; Bank left ?
	bcc.s	.Skip
	moveq.l	#32-1,d7
.Colour:	move.w	(a0)+,d0			; Amiga colour $0RGB
	jsr	Amiga_to_videl
	move.l	d1,(a1)+
	dbra	d7,.Colour
	addq.w	#1,d6
	bra.s	.Loop
.Skip:	lea.l	64(a0),a0
	bra.s	.Loop
.Range:	addq.l	#1,a0			; (colour : not yet)
	moveq.l	#0,d1			; Skip the colours
	move.b	(a0)+,d1
	add.w	d1,d1
	add.w	d1,a0
	bra.s	.Loop
.End:	move.w	d6,Shadow_banks
	st	Palette_dirty
	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Convert an Amiga colour into a VIDEL colour ]
;   IN : d0 - Amiga colour $0RGB (.w)
;        a2 - Pointer to [ Nibble_to_videl ] (.l)
;  OUT : d1 - VIDEL colour (.l)
; Changed registers : d1, d2
Amiga_to_videl:
	moveq.l	#0,d1
	moveq.l	#$f,d2			; Red
	and.w	d0,d2
	move.b	0(a2,d2.w),d1		; (blue : bits 0-7)
	move.w	d0,d2			; Green
	lsr.w	#4,d2
	andi.w	#$f,d2
	move.b	0(a2,d2.w),d2
	swap	d2
	clr.w	d2
	or.l	d2,d1
	move.w	d0,d2			; Red
	lsr.w	#8,d2
	andi.w	#$f,d2
	move.b	0(a2,d2.w),d2
	ror.l	#8,d2
	clr.w	d2
	andi.l	#$ff000000,d2
	or.l	d2,d1
	rts

;*****************************************************************************
; [ Raster handling in the vertical blank ]
; The colours made by [ Render_raster ] are copied into the VIDEL.
;*****************************************************************************
Raster_VBL:
	tst.b	Palette_dirty
	beq.s	.Exit
	sf	Palette_dirty
	movem.l	d7/a0/a1,-(sp)
	lea.l	Shadow_palette,a0
	lea.l	Videl_palette,a1
	move.w	Shadow_banks,d7
	lsl.w	#5,d7			; 32 colours per bank
	bra.s	.Next
.Loop:	move.l	(a0)+,(a1)+
.Next:	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0/a1
.Exit:	rts

;*****************************************************************************
; [ Get the colour of the screen for an Amiga colour ]
;   IN : d1 - Y-coordinate (.w)
;        d4 - Amiga colour number (.w)
;  OUT : d4 - Colour of the screen (bank * 32 + colour) (.w)
; Changed registers : d4
;*****************************************************************************
Get_screen_colour:
	movem.l	d1/a0,-(sp)
	jsr	Get_line_banks
	andi.w	#31,d4
	tst.w	d1
	bpl.s	.Top
	moveq.l	#0,d1
.Top:	cmp.w	#Screen_height-1,d1
	ble.s	.Bottom
	move.w	#Screen_height-1,d1
.Bottom:	move.b	0(a0,d1.w),d1		; Bank
	lsl.w	#5,d1
	or.w	d1,d4
	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Get the banks of the lines ]
;  OUT : a0 - Pointer to the bank of every line (200 bytes) (.l)
; Changed registers : a0
; NOTE :
;   - From the raster list of the current module (the screen of a module is
;     drawn before its colours are set), else the current one. The table is
;     made again only when the raster list is another one.
;*****************************************************************************
Get_line_banks:
	movem.l	d0-d3/d7/a1,-(sp)
	move.l	Module_Sp,d0		; Raster list of the module
	beq.s	.Current
	move.l	d0,a0
	move.l	Raster_list_ptr(a0),d0
	bne.s	.Got
.Current:	move.l	Fade_RL_ptr,d0
.Got:	cmp.l	Banks_RL,d0		; The same as last time ?
	beq.s	.Exit
	move.l	d0,Banks_RL
	lea.l	Line_banks,a1		; All bank 0
	move.w	#Screen_height/4-1,d7
.Clear:	clr.l	(a1)+
	dbra	d7,.Clear
	tst.l	d0
	beq.s	.Exit
	move.l	d0,a0
	moveq.l	#0,d3			; Bank
.Loop:	move.b	(a0)+,d0			; Get entry type
	bmi.s	.Exit
	moveq.l	#0,d2			; Get line
	move.b	(a0)+,d2
	tst.b	d0
	bne.s	.Range
	addq.l	#4,a0			; (pointer to the colours)
	cmp.w	#8,d3			; Bank left ?
	bcc.s	.Loop
	lea.l	Line_banks,a1		; From this line on
	move.w	#Screen_height,d7
	sub.w	d2,d7
	ble.s	.Next
	add.w	d2,a1
	subq.w	#1,d7
.Fill:	move.b	d3,(a1)+
	dbra	d7,.Fill
.Next:	addq.w	#1,d3
	bra.s	.Loop
.Range:	addq.l	#6,a0
	bra.s	.Loop
.Exit:	lea.l	Line_banks,a0
	movem.l	(sp)+,d0-d3/d7/a1
	rts

	SECTION	Fast_DATA,data
; Intensity 0...15 -> 6 bits of the VIDEL (in bits 2-7)
Nibble_to_videl:
	dc.b	0*4*4+0,1*4*4+0,2*4*4+0,3*4*4+0
	dc.b	4*4*4+4,5*4*4+4,6*4*4+4,7*4*4+4
	dc.b	8*4*4+8,9*4*4+8,10*4*4+8,11*4*4+8
	dc.b	12*4*4+12,13*4*4+12,14*4*4+12,15*4*4+12

	SECTION	Fast_BSS,bss
Banks_RL:	ds.l 1
Shadow_banks:	ds.w 1
Palette_dirty:	ds.b 1
	even
Line_banks:	ds.b Screen_height
Shadow_palette:	ds.l 256
