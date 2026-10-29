; Falcon kernel : the colours on the screen (VIDEL, 256 colours)
; The hardware part of the colours (COLOURS.S : the fading of the Amiga
; version). (Replaces RASTER.S of the ST kernel.)
;
; Every palette of a raster list gets a bank of 32 colours : the first
; palette (from the top of the screen) bank 0 (colours 0-31), the second
; bank 1 (32-63) and so on. A pixel is bank * 32 + Amiga colour, the graphics
; routines set the planes 5-7 to the bank of the line. So the original
; colours are shown, without raster interrupts.
; A colour range (one Amiga colour changed in every line, e.g. the gradient
; behind the portraits) gets one colour per line, from the end of the 256
; colours downwards : on these lines the graphics routines draw the pixels
; of that Amiga colour in the colour of the line.
; [ Get_line_banks ] gives the bank, the range colour and its colour on the
; screen for every line (from the raster list of the module), [ Render_raster ]
; puts the (faded) colours of [ Current_RL ] at the same places of the shadow
; palette and copies it into the VIDEL at once (it runs in the vertical blank :
; the colours change with the same frame as a screen switch, see there).

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
	jsr	Copy_palette
	move.l	#-1,Banks_RL
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
; [ Where the colours of the entries of a raster list go ]
;   IN : d0 - Entry type (0 = palette, 1 = range) (.b)
;        d1 - Number of colours of a range (.w)
;        d6 - Number of palettes so far (.w)
;        d5 - First colour of the ranges so far (256 : none) (.w)
;  OUT : d2 - First colour on the screen (-1 : no room) (.w)
;        d5, d6 - Updated (.w)
; Changed registers : d2, d5, d6
; NOTE :
;   - The same for [ Get_line_banks ] (the raster list of the module) and
;     [ Render_raster ] (Current_RL) : the colours meet.
;*****************************************************************************
Place_RL_entry:
	tst.b	d0
	bne.s	.Range
	move.w	d6,d2			; Palette : the next bank
	lsl.w	#5,d2
	addq.w	#1,d6
	move.w	d2,-(sp)			; Room below the ranges ?
	addi.w	#32,d2
	cmp.w	d5,d2
	movem.w	(sp)+,d2			; (flags unchanged)
	bls.s	.Exit
	moveq.l	#-1,d2
	rts
.Range:	move.w	d5,d2			; Range : below the last range
	sub.w	d1,d2
	move.w	d6,-(sp)			; Room above the palettes ?
	lsl.w	#5,d6
	cmp.w	d6,d2
	movem.w	(sp)+,d6
	bge.s	.Ok
	moveq.l	#-1,d2
	rts
.Ok:	move.w	d2,d5
.Exit:	rts

;*****************************************************************************
; [ Make the colours of the banks from Current_RL ]
; All registers are restored
; NOTE :
;   - Called by [ Colour_handler ] in the vertical blank. The colours go into
;     the VIDEL at once : a fade starts like [ Fade_in_bottom ] (set the fade,
;     wait for the vertical blank, switch the screens), the new screen must
;     not be shown with the colours of the old one for a frame.
;*****************************************************************************
Render_raster:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Current_RL,a0
	lea.l	Nibble_to_videl,a2
	moveq.l	#0,d6			; Number of palettes
	move.w	#256,d5			; (no ranges yet)
.Loop:	move.b	(a0)+,d0			; Get entry type
	cmp.b	#-1,d0
	beq.s	.End
	addq.l	#1,a0			; (line)
	moveq.l	#32,d1			; Number of colours
	tst.b	d0
	beq.s	.Place
	addq.l	#1,a0			; (Amiga colour of the range)
	moveq.l	#0,d1
	move.b	(a0)+,d1
.Place:	movem.w	d0/d1,-(sp)
	jsr	Place_RL_entry
	movem.w	(sp)+,d0/d1
	tst.w	d2
	bmi.s	.Skip
	lea.l	Shadow_palette,a1		; Colours
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a1
	move.w	d1,d7
	bra.s	.Next
.Colour:	move.w	(a0)+,d0			; Amiga colour $0RGB
	jsr	Amiga_to_videl
	move.l	d1,(a1)+
.Next:	dbra	d7,.Colour
	bra.s	.Loop
.Skip:	add.w	d1,d1			; (no room)
	add.w	d1,a0
	bra.s	.Loop
.End:	jsr	Copy_palette
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Convert an Amiga colour into a VIDEL colour ]
;   IN : d0 - Amiga colour $0RGB (.w)
;        a2 - Pointer to [ Nibble_to_videl ] (.l)
;  OUT : d1 - VIDEL colour (.l)
; Changed registers : d1, d2
Amiga_to_videl:
	moveq.l	#0,d1
	moveq.l	#$f,d2			; Blue
	and.w	d0,d2
	move.b	0(a2,d2.w),d1		; (bits 0-7)
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
	andi.l	#$ff000000,d2
	or.l	d2,d1
	rts

;*****************************************************************************
; [ Raster handling in the vertical blank ]
; NOTE :
;   - Nothing to do : [ Render_raster ] sets the colours.
;*****************************************************************************
Raster_VBL:
	rts

;*****************************************************************************
; [ Copy the shadow palette into the VIDEL ]
; All registers are restored
;*****************************************************************************
Copy_palette:
	movem.l	d7/a0/a1,-(sp)
	lea.l	Shadow_palette,a0
	lea.l	Videl_palette,a1
	move.w	#256/4-1,d7
.Loop:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0/a1
	rts

;*****************************************************************************
; [ Get the colour of the screen for an Amiga colour ]
;   IN : d1 - Y-coordinate (.w)
;        d4 - Amiga colour number (.w)
;  OUT : d4 - Colour of the screen (.w)
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
.Bottom:	add.w	d1,a0
	cmp.b	Line_range_colour-Line_banks(a0),d4	; The colour of a range ?
	bne.s	.Bank
	moveq.l	#0,d4
	move.b	Line_range_index-Line_banks(a0),d4
	bra.s	.Exit
.Bank:	moveq.l	#0,d1			; Bank
	move.b	(a0),d1
	lsl.w	#5,d1
	or.w	d1,d4
.Exit:	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Get the banks of the lines ]
;  OUT : a0 - Pointer to [ Line_banks ] (.l)
; Changed registers : a0
; NOTE :
;   - [ Line_banks ] : the bank of every line (200 bytes), followed by
;     [ Line_range_colour ] (the Amiga colour of a range on the line, -1 :
;     none) and [ Line_range_index ] (its colour on the screen).
;   - From the raster list of the current module (the screen of a module is
;     drawn before its colours are set), else the current one. The tables are
;     made again only when the raster list is another one.
;*****************************************************************************
Get_line_banks:
	movem.l	d0-d7/a1,-(sp)
	move.l	Module_Sp,d0		; Raster list of the module
	beq.s	.Current
	move.l	d0,a0
	move.l	Raster_list_ptr(a0),d0
	bne.s	.Got
.Current:	move.l	Fade_RL_ptr,d0
.Got:	cmp.l	Banks_RL,d0		; The same as last time ?
	beq	.Exit
	move.l	d0,Banks_RL
	lea.l	Line_banks,a1		; All bank 0, no ranges
	move.w	#Screen_height/4-1,d7
.Clear:	clr.l	(a1)+
	move.l	#-1,Line_range_colour-Line_banks-4(a1)
	dbra	d7,.Clear
	tst.l	d0
	beq	.Exit
	move.l	d0,a0
	moveq.l	#0,d6			; Number of palettes
	move.w	#256,d5			; (no ranges yet)
	moveq.l	#0,d4			; Bank of the palette
.Loop:	move.b	(a0)+,d0			; Get entry type
	bmi	.Exit
	moveq.l	#0,d3			; Get line
	move.b	(a0)+,d3
	moveq.l	#32,d1			; Number of colours
	tst.b	d0
	beq.s	.Place
	moveq.l	#0,d7			; Range : Amiga colour & number
	move.b	(a0)+,d7
	move.b	(a0)+,d1
.Place:	addq.l	#4,a0			; (pointer to the colours)
	jsr	Place_RL_entry
	tst.w	d2
	bmi.s	.Loop
	tst.b	d0
	bne.s	.Range
	move.w	d2,d4			; Palette : its bank from this line on
	lsr.w	#5,d4
	lea.l	Line_banks,a1
	move.w	#Screen_height,d7
	sub.w	d3,d7
	ble.s	.Loop
	add.w	d3,a1
	subq.w	#1,d7
.Fill:	move.b	d4,(a1)+
	dbra	d7,.Fill
	bra.s	.Loop
.Range:	lea.l	Line_range_colour,a1	; Range : the colour of every line
	add.w	d3,a1
	subq.w	#1,d1
.Line:	cmp.w	#Screen_height,d3
	bcc.s	.Loop
	move.b	d7,(a1)
	move.b	d2,Line_range_index-Line_range_colour(a1)
	addq.l	#1,a1
	addq.w	#1,d2
	addq.w	#1,d3
	dbra	d1,.Line
	bra	.Loop
.Exit:	lea.l	Line_banks,a0
	movem.l	(sp)+,d0-d7/a1
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
Line_banks:	ds.b Screen_height		; (these three one after the other)
Line_range_colour:	ds.b Screen_height
Line_range_index:	ds.b Screen_height
	even
Shadow_palette:	ds.l 256
