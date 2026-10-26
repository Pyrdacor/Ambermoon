; ST kernel : raster lists, colours & fading
; Replaces KERNEL/COLOURS.S of the Amiga version.
;
; The raster lists are the same as in the Amiga version : R_palette sets the
; 32 colours of an Amiga palette from a line on, R_range one colour per line.
; The fading works like in the Amiga version on [ Current_RL ] (a copy of the
; raster list with the colours, every component is counted towards the
; target). Instead of the copper list, raster events for the ST are made from
; it ([ Render_raster ]), which the VBL and the Timer B interrupt execute :
;   - An Amiga palette (32 colours) is shown with a static ST palette of 16
;     colours, which was made in advance (port/tools/port_palettes.py,
;     [ ST_palettes ]) : found by the colours of the Amiga palette. The fade
;     state of the Amiga colours is applied to the ST colours.
;   - A colour of a range is set exactly in its line, in the ST colour which
;     the palette above it uses for this Amiga colour.
; [ Get_ST_colour ] gives the ST colour of an Amiga colour in a line (with
; the raster list of the current module), the graphics routines use it.
;
; A raster event is 8 bytes :
;   .w  number of displayed lines before the event (fires at the end of the
;       previous line)
;   .w  colour register (0...15) or -1 for a complete palette
;   .l  colour value (low word) or pointer to the 16 palette words
; Like the copper list of the Amiga version, a palette is set at the start
; of the line BEFORE its line (that line is always empty), a colour of a
; range exactly at its line. A colour on line 1 is set in the VBL : the
; Timer B interrupt at the end of line 0 can come too late. Line 0 does not
; use the colours of the ranges.

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the colours ]
; All registers are restored
;*****************************************************************************
Init_copper:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Raster_events1,a0		; No events
	move.w	#$7fff,(a0)
	move.l	a0,Active_raster
	clr.l	Next_raster
	move.w	#1,d0
	moveq.l	#0,d1
	move.w	#199,d2
	lea.l	Copper_init_data,a0
	jsr	Set_fade
	jsr	Colour_handler
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Start a fade / colour change ]
;   IN : d0 - Command (1 = Set_new, 2 = Start_fade_in, 3 = Fade_out) (.w)
;        d1 - Top Y (.w)
;        d2 - Bottom Y (.w)
;        a0 - Pointer to raster list (.l)
; NOTE :
;   - The command is executed by [ Colour_handler ] during the next frames.
;*****************************************************************************
Set_fade:
	clr.w	Fade_command
	move.w	d1,Fade_top
	move.w	d2,Fade_bottom
	move.l	a0,Fade_RL_ptr
	move.w	d0,Fade_command
	rts

;*****************************************************************************
; [ Handle colour changes (fading) ]
; Executes the current fade command (see [ Set_fade ]) once per frame.
; All registers are restored
; NOTE :
;   - The same as in the Amiga version, but [ Render_raster ] makes the
;     raster events instead of the copper list. (The drug effect wobbles the
;     screen with the copper list : not on the ST.)
;*****************************************************************************
Colour_handler:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	Fade_command,d0
	beq.s	.Exit
	lea.l	.Commands-4(pc),a0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),a0
	jsr	(a0)
.Exit:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.Commands:	dc.l	.Skip3,.Skip4,.Skip9,.Skip6
.Skip3:
	move.l	Fade_RL_ptr,a0
	lea.l	Current_RL,a1
.Loop:
	move.b	(a0)+,d0
	move.b	d0,(a1)+
	cmp.b	#-1,d0
	beq.s	.Exit2
	jsr	Copy_RL_entry
	bra.s	.Loop
.Exit2:
	jsr	Render_raster
	clr.w	Fade_command
	rts
.Skip4:
	move.l	Fade_RL_ptr,a0
	lea.l	Current_RL,a1
	move.w	Fade_top,d4
	move.w	Fade_bottom,d5
.Loop2:
	move.b	(a0)+,d0
	move.b	d0,(a1)+
	cmp.b	#-1,d0
	beq.s	.Exit3
	moveq.l	#0,d1
	move.b	(a0),d1
	cmp.w	d4,d1
	bpl.s	.Skip5
.Loop3:
	jsr	Copy_RL_entry
	bra.s	.Loop2
.Skip5:
	cmp.w	d5,d1
	bhi.s	.Loop3
	jsr	Clear_RL_entry
	bra.s	.Loop2
.Exit3:
	jsr	Render_raster
	move.w	#4,Fade_command
	rts
.Skip6:
	move.l	Fade_RL_ptr,a0
	lea.l	Current_RL,a1
	move.w	Fade_top,d4
	move.w	Fade_bottom,d5
	moveq.l	#0,d6
.Loop4:
	move.b	(a0)+,d0
	addq.l	#1,a1
	cmp.b	#-1,d0
	beq.s	.Skip8
	moveq.l	#0,d1
	move.b	(a0),d1
	cmp.w	d4,d1
	bpl.s	.Skip7
.Loop5:
	jsr	Copy_RL_entry
	bra.s	.Loop4
.Skip7:
	cmp.w	d5,d1
	bhi.s	.Loop5
	jsr	Fade_RL_entry_in
	bra.s	.Loop4
.Skip8:
	jsr	Render_raster
	tst.w	d6
	bne.s	.Exit4
	clr.w	Fade_command
.Exit4:
	rts
.Skip9:
	lea.l	Current_RL,a1
	move.w	Fade_top,d4
	move.w	Fade_bottom,d5
	moveq.l	#0,d6
.Loop6:
	move.b	(a1)+,d0
	cmp.b	#-1,d0
	beq.s	.Skip11
	moveq.l	#0,d1
	move.b	(a1),d1
	cmp.w	d4,d1
	bpl.s	.Skip10
.Loop7:
	jsr	Skip_RL_entry
	bra.s	.Loop6
.Skip10:
	cmp.w	d5,d1
	bhi.s	.Loop7
	jsr	Fade_RL_entry_out
	bra.s	.Loop6
.Skip11:
	jsr	Render_raster
	tst.w	d6
	bne.s	.Exit5
	clr.w	Fade_command
.Exit5:
	rts

;*****************************************************************************
; [ Copy the colours of one raster list entry ]
;   IN : d0 - Entry type (0 = full palette) (.b)
;        a0 - Pointer to source raster list entry (.l)
;        a1 - Pointer to target raster list entry (.l)
; NOTE :
;   - ST: the target colours of a palette are kept in [ Current_RL_targets ].
;*****************************************************************************
Copy_RL_entry:
	tst.b	d0
	bne.s	.Skip
	move.b	(a0)+,(a1)+
	move.l	(a0)+,a2
	jsr	Store_RL_source
	moveq.l	#31,d7
.Loop:
	move.w	(a2)+,(a1)+
	dbra	d7,.Loop
	bra.s	.Exit
.Skip:
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	moveq.l	#0,d7
	move.b	(a0)+,d7
	move.b	d7,(a1)+
	move.l	(a0)+,a2
	bra.s	.Skip2
.Loop2:
	move.w	(a2)+,(a1)+
.Skip2:
	dbra	d7,.Loop2
.Exit:
	rts

;*****************************************************************************
; [ Clear the colours of one raster list entry ]
;   IN : d0 - Entry type (0 = full palette) (.b)
;        a0 - Pointer to source raster list entry (.l)
;        a1 - Pointer to target raster list entry (.l)
;*****************************************************************************
Clear_RL_entry:
	tst.b	d0
	bne.s	.Skip
	move.b	(a0)+,(a1)+
	move.l	(a0)+,a2			; ST: keep the source
	jsr	Store_RL_source
	moveq.l	#31,d7
.Loop:
	clr.w	(a1)+
	dbra	d7,.Loop
	bra.s	.Exit
.Skip:
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	moveq.l	#0,d7
	move.b	(a0)+,d7
	move.b	d7,(a1)+
	addq.l	#4,a0
	bra.s	.Skip2
.Loop2:
	clr.w	(a1)+
.Skip2:
	dbra	d7,.Loop2
.Exit:
	rts

; [ Remember the target colours of a palette entry of Current_RL ]
;   IN : a1 - Pointer to the colours of the entry in Current_RL (.l)
;        a2 - Pointer to the source palette (.l)
; Changed registers : d7
; NOTE :
;   - The colours are copied : the source can change later (e.g. Batch).
Store_RL_source:
	move.l	a1,d7			; Index = offset / 66
	sub.l	#Current_RL+2,d7
	divu.w	#66,d7
	cmp.w	#Max_RL_palettes,d7
	bcc.s	.Exit
	movem.l	a0/a2,-(sp)
	lsl.w	#6,d7
	lea.l	Current_RL_targets,a0
	add.w	d7,a0
	moveq.l	#32/2-1,d7
.Copy:	move.l	(a2)+,(a0)+
	dbra	d7,.Copy
	movem.l	(sp)+,a0/a2
.Exit:	rts

;*****************************************************************************
; [ Fade the colours of one raster list entry towards the target colours ]
;   IN : d0 - Entry type (.b)
;        a0 - Pointer to target raster list entry (.l)
;        a1 - Pointer to current raster list entry (.l)
;  OUT : d6 - Increased if anything changed (.w)
;*****************************************************************************
Fade_RL_entry_in:
	tst.b	d0
	bne.s	.Skip2
	addq.l	#1,a0
	addq.l	#1,a1
	move.l	(a0)+,a2
	moveq.l	#31,d7
.Loop:
	move.w	(a1),d0
	move.w	(a2)+,d1
	cmp.w	d0,d1
	beq.s	.Skip
	jsr	Fade_colour
	addq.w	#1,d6
.Skip:
	move.w	d0,(a1)+
	dbra	d7,.Loop
	bra.s	.Exit
.Skip2:
	addq.l	#2,a0
	addq.l	#2,a1
	moveq.l	#0,d7
	move.b	(a0)+,d7
	addq.l	#1,a1
	move.l	(a0)+,a2
	bra.s	.Skip4
.Loop2:
	move.w	(a1),d0
	move.w	(a2)+,d1
	cmp.w	d0,d1
	beq.s	.Skip3
	jsr	Fade_colour
	addq.w	#1,d6
.Skip3:
	move.w	d0,(a1)+
.Skip4:
	dbra	d7,.Loop2
.Exit:
	rts

;*****************************************************************************
; [ Fade the colours of one raster list entry towards black ]
;   IN : d0 - Entry type (.b)
;        a1 - Pointer to current raster list entry (.l)
;  OUT : d6 - Increased if anything changed (.w)
;*****************************************************************************
Fade_RL_entry_out:
	tst.b	d0
	bne.s	.Skip2
	addq.l	#1,a1
	moveq.l	#0,d1
	moveq.l	#31,d7
.Loop:
	move.w	(a1),d0
	beq.s	.Skip
	jsr	Fade_colour
	addq.w	#1,d6
.Skip:
	move.w	d0,(a1)+
	dbra	d7,.Loop
	bra.s	.Exit
.Skip2:
	addq.l	#2,a1
	moveq.l	#0,d7
	move.b	(a1)+,d7
	moveq.l	#0,d1
	bra.s	.Skip4
.Loop2:
	move.w	(a1),d0
	beq.s	.Skip3
	jsr	Fade_colour
	addq.w	#1,d6
.Skip3:
	move.w	d0,(a1)+
.Skip4:
	dbra	d7,.Loop2
.Exit:
	rts

;*****************************************************************************
; [ Skip one raster list entry ]
;   IN : d0 - Entry type (.b)
;        a1 - Pointer to raster list entry (.l)
;*****************************************************************************
Skip_RL_entry:
	tst.b	d0
	bne.s	.Skip
	lea.l	65(a1),a1
	bra.s	.Exit
.Skip:
	addq.l	#2,a1
	moveq.l	#0,d7
	move.b	(a1)+,d7
	add.w	d7,d7
	add.w	d7,a1
.Exit:
	rts

;*****************************************************************************
; [ Fade a colour one step towards another ]
;   IN : d0 - Current colour (.w)
;        d1 - Target colour (.w)
;  OUT : d0 - New colour (.w)
;*****************************************************************************
Fade_colour:
	movem.l	d2/d3,-(sp)
	move.w	#3840,d2
	move.w	d2,d3
	and.w	d0,d2
	and.w	d1,d3
	cmp.w	d2,d3
	beq.s	.Skip2
	bpl.s	.Skip
	subi.w	#256,d0
	bra.s	.Skip2
.Skip:
	addi.w	#256,d0
.Skip2:
	move.w	#240,d2
	move.w	d2,d3
	and.w	d0,d2
	and.w	d1,d3
	cmp.w	d2,d3
	beq.s	.Skip4
	bpl.s	.Skip3
	subi.w	#16,d0
	bra.s	.Skip4
.Skip3:
	addi.w	#16,d0
.Skip4:
	move.w	#15,d2
	move.w	d2,d3
	and.w	d0,d2
	and.w	d1,d3
	cmp.w	d2,d3
	beq.s	.Exit
	bpl.s	.Skip5
	subi.w	#1,d0
	bra.s	.Exit
.Skip5:
	addi.w	#1,d0
.Exit:
	movem.l	(sp)+,d2/d3
	rts

;*****************************************************************************
; [ Wait until the current fade has finished ]
;*****************************************************************************
Wait_4_fade:
	tst.w	Fade_command
	beq.s	.Exit
	jsr	My_vsync
	bra.s	Wait_4_fade
.Exit:
	rts

;*****************************************************************************
; [ Make the raster events from Current_RL ]
; All registers are restored
; NOTE :
;   - Called by [ Colour_handler ] in the vertical blank. The events are
;     made in the inactive buffer and become active with the next frame.
;*****************************************************************************
Render_raster:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Raster_events1,a1		; Use the inactive buffer
	lea.l	Raster_palettes1,a5
	cmp.l	Active_raster,a1
	bne.s	.Go
	lea.l	Raster_events2,a1
	lea.l	Raster_palettes2,a5
.Go:	move.l	a1,a6
	lea.l	Current_RL,a0
	moveq.l	#0,d6			; Palette entry index
	sub.l	a3,a3			; LUT of the palette above (none)
.Loop:	move.b	(a0)+,d0			; Get entry type
	cmp.b	#-1,d0
	beq	.End
	moveq.l	#0,d1			; Get line
	move.b	(a0)+,d1
	tst.b	d0
	bne	.Range
; ---------- Palette ------------------------------
	cmp.w	#Max_RL_palettes,d6
	bcc	.Skip_pal
	move.w	d6,d2			; Target colours
	lsl.w	#6,d2
	lea.l	Current_RL_targets,a2
	add.w	d2,a2
	movem.l	a0/a1,-(sp)
	move.l	a2,a0
	jsr	Find_ST_palette
	move.l	a0,a4			; ST palette & LUT
	movem.l	(sp)+,a0/a1
	lea.l	32(a4),a3			; LUT
	move.l	a5,a2			; Fade the ST colours like the Amiga colours
	jsr	Fade_ST_palette
	subq.w	#1,d1			; One line earlier
	bpl.s	.Ok
	moveq.l	#0,d1
.Ok:	move.w	d1,(a1)+
	move.w	#-1,(a1)+
	move.l	a5,(a1)+
	lea.l	32(a5),a5
	addq.w	#1,d6
	lea.l	64(a0),a0
	bra	.Loop
.Skip_pal:	lea.l	64(a0),a0
	bra	.Loop
; ---------- Colour range -------------------------
.Range:	moveq.l	#0,d2			; Get colour number
	move.b	(a0)+,d2
	moveq.l	#0,d3			; Get number of lines
	move.b	(a0)+,d3
	move.l	a3,d5			; Any palette ?
	bne.s	.Lut
	add.w	d3,d3			; No -> skip
	add.w	d3,a0
	bra	.Loop
.Lut:	andi.w	#31,d2			; Translate colour number
	moveq.l	#0,d5
	move.b	0(a3,d2.w),d5
	bra.s	.Next
.Loop2:	move.w	(a0)+,d0			; Convert colour
	jsr	Amiga_to_STE_colour
	move.w	d1,(a1)
	cmp.w	#1,d1			; Line 1 -> in the VBL
	bne.s	.Not1
	clr.w	(a1)
.Not1:	addq.l	#2,a1
	move.w	d5,(a1)+
	clr.w	(a1)+
	move.w	d0,(a1)+
	addq.w	#1,d1
.Next:	dbra	d3,.Loop2
	bra	.Loop
; ---------- End : sort by line ------------------
.End:	move.w	#$7fff,(a1)+
	move.l	a6,a0
	jsr	Sort_raster_events
	move.l	a6,Next_raster
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Max_RL_palettes	EQU	8

;*****************************************************************************
; [ Fade the colours of an ST palette like the Amiga colours ]
;   IN : a0 - Pointer to the current Amiga colours (32 words) (.l)
;        a2 - Pointer to target buffer (16 words) (.l)
;        a4 - Pointer to the ST palette (16 STE words) (.l)
;        [ Current_RL_targets ] - target Amiga colours
; All registers are restored
; NOTE :
;   - The Amiga version counts every component of the colours towards the
;     target. While fading in, a component is min(target, steps), while
;     fading out max(0, target - steps). The number of steps is found from
;     the brightest component of the current and the target colours and
;     applied to the ST colours in the same way.
;*****************************************************************************
Fade_ST_palette:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d6,d0			; Target colours
	lsl.w	#6,d0
	lea.l	Current_RL_targets,a1
	add.w	d0,a1
	jsr	Max_component		; Current maximum
	move.w	d0,d4
	move.l	a1,a0			; Target maximum
	jsr	Max_component
	move.w	d0,d5
	lea.l	STE_to_linear,a3
	lea.l	STE_nibbles,a5
	moveq.l	#16-1,d7
	cmp.w	#4,Fade_command		; Fading in ?
	beq.s	.In
; ---------- Out / static : max(0, c - (target - current)) ---------
	sub.w	d4,d5			; Steps
.Loop:	move.w	(a4)+,d0
	moveq.l	#0,d1
	moveq.l	#3-1,d6
	rol.w	#4,d0			; Skip the unused top nibble
.Comp:	rol.w	#4,d0
	moveq.l	#$f,d2
	and.w	d0,d2
	move.b	0(a3,d2.w),d2		; 0...15
	sub.w	d5,d2
	bpl.s	.Pos
	moveq.l	#0,d2
.Pos:	move.b	0(a5,d2.w),d2		; STE nibble
	lsl.w	#4,d1
	or.w	d2,d1
	dbra	d6,.Comp
	move.w	d1,(a2)+
	dbra	d7,.Loop
	bra.s	.Exit
; ---------- In : min(c, current) ---------
.In:	move.w	(a4)+,d0
	moveq.l	#0,d1
	moveq.l	#3-1,d6
	rol.w	#4,d0
.Comp2:	rol.w	#4,d0
	moveq.l	#$f,d2
	and.w	d0,d2
	move.b	0(a3,d2.w),d2
	cmp.w	d4,d2
	ble.s	.Min
	move.w	d4,d2
.Min:	move.b	0(a5,d2.w),d2
	lsl.w	#4,d1
	or.w	d2,d1
	dbra	d6,.Comp2
	move.w	d1,(a2)+
	dbra	d7,.In
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Get the brightest component of 32 Amiga colours ]
;   IN : a0 - Pointer to colours (.l)
;  OUT : d0 - Maximum component (0...15) (.w)
; Changed registers : d0
Max_component:
	movem.l	d1-d3/d7/a0,-(sp)
	moveq.l	#0,d0
	moveq.l	#32-1,d7
.Loop:	move.w	(a0)+,d1
	moveq.l	#3-1,d3
.Comp:	moveq.l	#$f,d2
	and.w	d1,d2
	cmp.w	d0,d2
	ble.s	.No
	move.w	d2,d0
.No:	lsr.w	#4,d1
	dbra	d3,.Comp
	dbra	d7,.Loop
	movem.l	(sp)+,d1-d3/d7/a0
	rts

;*****************************************************************************
; [ Find the ST palette of an Amiga palette ]
;   IN : a0 - Pointer to Amiga palette (32 colours) (.l)
;  OUT : a0 - Pointer to ST palette (16 STE words, 32 bytes LUT) (.l)
; Changed registers : a0
; NOTE :
;   - The ST palettes are made in advance ([ ST_palettes ]). If the colours
;     are not found, the palette with the nearest colours is taken.
;*****************************************************************************
Find_ST_palette:
	movem.l	d0-d7/a1-a3,-(sp)
	move.l	a0,a2
	lea.l	ST_palettes,a1
	sub.l	a3,a3			; Best so far
	move.l	#$7fffffff,d6
.Loop:	tst.w	(a1)			; End ? (colour 0 is always black,
	bmi.s	.Done			;  the end is marked with -1)
	move.l	a1,d0			; Compare
	move.l	a2,a0
	moveq.l	#0,d5			; Distance
	moveq.l	#32-1,d7
.Colour:	move.w	(a0)+,d0
	move.w	(a1)+,d1
	cmp.w	d0,d1
	beq.s	.Same
	moveq.l	#3-1,d4
.Comp:	moveq.l	#$f,d2
	and.w	d0,d2
	moveq.l	#$f,d3
	and.w	d1,d3
	sub.w	d3,d2
	bpl.s	.Abs
	neg.w	d2
.Abs:	add.w	d2,d5
	lsr.w	#4,d0
	lsr.w	#4,d1
	dbra	d4,.Comp
.Same:	dbra	d7,.Colour
	tst.l	d5			; Exact ?
	bne.s	.Not
	move.l	a1,a3
	bra.s	.Found
.Not:	cmp.l	d6,d5			; Nearer ?
	bge.s	.Next
	move.l	d5,d6
	move.l	a1,a3
.Next:	lea.l	64(a1),a1			; Next entry
	bra.s	.Loop
.Done:	move.l	a3,d0			; Any ?
	bne.s	.Found
	lea.l	ST_palettes+64,a3		; (cannot happen)
.Found:	move.l	a3,a0
	movem.l	(sp)+,d0-d7/a1-a3
	rts

;*****************************************************************************
; [ Get the ST colour of an Amiga colour ]
;   IN : d1 - Y-coordinate (.w)
;        d4 - Amiga colour number (.w)
;  OUT : d4 - ST colour (0...15) (.w)
; Changed registers : d4
; NOTE :
;   - The raster list of the current module is used (the screen of a module
;     is drawn before its colours are set), else the current one.
;*****************************************************************************
Get_ST_colour:
	move.l	a0,-(sp)
	jsr	Get_ST_LUT
	andi.w	#31,d4
	move.b	0(a0,d4.w),d4
	ext.w	d4
	move.l	(sp)+,a0
	rts

; [ Get the colour lookup table of a line ]
;   IN : d1 - Y-coordinate (.w)
;  OUT : a0 - Pointer to lookup table (Amiga colour -> ST colour) (.l)
; Changed registers : a0
Get_ST_LUT:
	movem.l	d0/d2/a1,-(sp)
	move.l	Module_Sp,d0		; Raster list of the module
	beq.s	.Current
	move.l	d0,a0
	move.l	Raster_list_ptr(a0),d0
	bne.s	.Got
.Current:	move.l	Fade_RL_ptr,d0
	beq.s	.Default
.Got:	move.l	d0,a0
	sub.l	a1,a1
.Loop:	move.b	(a0)+,d0			; Get entry type
	bmi.s	.Done
	moveq.l	#0,d2			; Get line
	move.b	(a0)+,d2
	tst.b	d0
	bne.s	.Range
	cmp.w	d2,d1			; Palette active ?
	bmi.s	.Done
	move.b	(a0)+,d0			; Get pointer (unaligned)
	lsl.w	#8,d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	move.l	d0,a1
	bra.s	.Loop
.Range:	addq.l	#6,a0
	bra.s	.Loop
.Done:	move.l	a1,d0
	beq.s	.Default
	move.l	a1,a0			; Same palette and colours as last time ?
	jsr	Palette_checksum
	cmp.l	LUT_cache_source,a0
	bne.s	.Find
	cmp.l	LUT_cache_checksum,d0
	bne.s	.Find
	move.l	LUT_cache_LUT,a0
	bra.s	.Exit
.Find:	move.l	a0,LUT_cache_source
	move.l	d0,LUT_cache_checksum
	jsr	Find_ST_palette
	lea.l	32(a0),a0
	move.l	a0,LUT_cache_LUT
	bra.s	.Exit
.Default:	lea.l	Default_LUT,a0
.Exit:	movem.l	(sp)+,d0/d2/a1
	rts

; [ Checksum of an Amiga palette ]
;   IN : a0 - Pointer to 32 colours (.l)
;  OUT : d0 - Checksum (.l)
; Changed registers : d0
Palette_checksum:
	movem.l	d1/d7/a0,-(sp)
	moveq.l	#0,d0
	moveq.l	#16-1,d7
.Loop:	move.l	(a0)+,d1
	rol.l	#3,d0
	add.l	d1,d0
	dbra	d7,.Loop
	movem.l	(sp)+,d1/d7/a0
	rts

;*****************************************************************************
; [ Raster handling in the vertical blank ]
; Executes the events on line 0 and starts Timer B for the others.
;*****************************************************************************
Raster_VBL:
	clr.b	MFP_TBCR
	move.l	Next_raster,d0		; New raster list ?
	beq.s	.No
	move.l	d0,Active_raster
	clr.l	Next_raster
.No:	move.l	Active_raster,a0
	lea.l	Palette_regs,a1
.Loop:	move.w	(a0),d0			; Line 0 ?
	bne.s	.Arm
	move.w	2(a0),d1			; Execute event
	bmi.s	.Full
	add.w	d1,d1
	move.w	6(a0),0(a1,d1.w)
	addq.l	#8,a0
	bra.s	.Loop
.Full:	move.l	4(a0),a2
	movem.l	(a2),d0-d7
	movem.l	d0-d7,(a1)
	addq.l	#8,a0
	bra.s	.Loop
.Arm:	cmp.w	#$7fff,d0			; Any more events ?
	beq.s	.Exit
	move.l	a0,Raster_event_ptr
	move.b	d0,MFP_TBDR
	move.b	#8,MFP_TBCR		; Event count mode
.Exit:	rts

;*****************************************************************************
; [ Timer B interrupt (raster events) ]
;*****************************************************************************
Timer_B_interrupt:
	movem.l	d0/d1/a0-a2,-(sp)
	move.l	Raster_event_ptr,a0
	lea.l	Palette_regs,a1
	move.w	(a0),d1			; Line of this event
.Loop:	move.w	2(a0),d0
	bmi.s	.Full
	add.w	d0,d0			; One colour
	move.w	6(a0),0(a1,d0.w)
	bra.s	.Next
.Full:	move.l	4(a0),a2			; Complete palette
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	lea.l	Palette_regs,a1
.Next:	addq.l	#8,a0
	move.w	(a0),d0			; Next event on the same line ?
	cmp.w	d1,d0
	beq.s	.Loop
	clr.b	MFP_TBCR
	cmp.w	#$7fff,d0			; Any more events ?
	beq.s	.Exit
	sub.w	d1,d0			; Start Timer B for the next one
	move.b	d0,MFP_TBDR
	move.b	#8,MFP_TBCR
	move.l	a0,Raster_event_ptr
.Exit:	bclr	#0,MFP_ISRA
	movem.l	(sp)+,d0/d1/a0-a2
	rte

;*****************************************************************************
; [ Sort raster events by line (insertion sort, stable) ]
;   IN : a0 - Pointer to raster events (.l)
; All registers are restored
;*****************************************************************************
Sort_raster_events:
	movem.l	d0-d3/a0-a2,-(sp)
	lea.l	8(a0),a1
.Loop:	cmp.w	#$7fff,(a1)		; End ?
	beq.s	.Exit
	move.l	a1,a2			; Insert (a1) into sorted part
.Back:	cmp.l	a0,a2
	beq.s	.Next
	move.w	-8(a2),d0
	cmp.w	(a2),d0
	ble.s	.Next
	movem.l	-8(a2),d0-d1		; Swap
	movem.l	(a2),d2-d3
	movem.l	d2-d3,-8(a2)
	movem.l	d0-d1,(a2)
	subq.l	#8,a2
	bra.s	.Back
.Next:	addq.l	#8,a1
	bra.s	.Loop
.Exit:	movem.l	(sp)+,d0-d3/a0-a2
	rts

;*****************************************************************************
; [ Convert an Amiga colour to STE format ]
;   IN : d0 - Amiga colour $0RGB (.w)
;  OUT : d0 - STE colour (.w)
; Changed registers : d0
;*****************************************************************************
Amiga_to_STE_colour:
	movem.l	d1/d2/a0,-(sp)
	lea.l	STE_nibbles,a0
	moveq.l	#0,d1
	rol.w	#4,d0			; Skip the unused top nibble
	moveq.l	#3-1,d2
.Loop:	rol.w	#4,d1
	rol.w	#4,d0
	move.w	d0,-(sp)
	andi.w	#$f,d0
	or.b	0(a0,d0.w),d1
	move.w	(sp)+,d0
	dbra	d2,.Loop
	move.w	d1,d0
	movem.l	(sp)+,d1/d2/a0
	rts

	SECTION	Fast_DATA,data
; Intensity 0...15 -> STE nibble (bit 3 = lowest bit)
STE_nibbles:
	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
; STE nibble -> intensity 0...15
STE_to_linear:
	dc.b	0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
; Before any palette : Amiga colour -> ST colour 0...15 and 24...31 -> 8...15
Default_LUT:
	dc.b	0,1,2,3,4,5,6,7,1,2,3,4,5,6,7,1
	dc.b	2,3,4,5,6,7,1,2,8,9,10,11,12,13,14,15
Copper_init_data:
	dc.b	0,0
	dc.l	Init_palette
	dc.b	$ff,0
	even

	include	ST_KERNEL/STPALS.I		; [ ST_palettes ] (made by build.sh)

	SECTION	Fast_BSS,bss
Init_palette:	ds.w 32
Fade_command:	ds.w 1
Fade_top:	ds.w 1
Fade_bottom:	ds.w 1
Fade_RL_ptr:	ds.l 1
Active_raster:	ds.l 1
Next_raster:	ds.l 1
Raster_event_ptr:	ds.l 1
LUT_cache_source:	ds.l 1
LUT_cache_checksum:	ds.l 1
Current_RL_targets:	ds.w 32*Max_RL_palettes
LUT_cache_LUT:	ds.l 1
Raster_events1:	ds.b 8*256
Raster_events2:	ds.b 8*256
Raster_palettes1:	ds.w 16*Max_RL_palettes
Raster_palettes2:	ds.w 16*Max_RL_palettes
Current_RL:	ds.b 2048
