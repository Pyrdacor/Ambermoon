; Raster lists, palettes & colours (Atari ST)
; Replaces KERNEL/COLOURS.S of the Amiga version (copper list).
;
; The raster lists have the same format as in the Amiga version (macros
; R_palette, R_range, R_end in MACROS.I), but R_palette points to an ST
; palette block instead of 32 Amiga colours:
;   16 words  STE colour registers
;   32 bytes  lookup table : Amiga colour number -> ST colour (slot)
; R_range still points to Amiga colour words ($0RGB), they are converted.
;
; A raster list is compiled into a list of raster events, which are executed
; by the VBL (events on line 0) and the Timer B interrupt (event count mode,
; counts the displayed lines). An event is 8 bytes :
;   .w  number of displayed lines before the event (fires at the end of
;       the previous line)
;   .w  colour register (0...15) or -1 for a complete palette
;   .l  colour value (low word) or pointer to the 16 palette words
; Like the copper list of the Amiga version, a palette is set at the start
; of the line BEFORE its line (that line is always empty), a colour of a
; range exactly at its line. Only a colour on line 1 is set in the VBL : the
; Timer B interrupt at the end of line 0 can come too late (while the CPU
; finishes a long instruction), then the left part of line 1 would still
; show the old colour (e.g. the purple colour 25 above the first portrait).
; Line 0 does not use the colours of the ranges.

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the raster events ]
; All registers are restored
;*****************************************************************************
Init_raster:
	move.l	a0,-(sp)
	lea.l	Raster_events1,a0
	move.w	#$7fff,(a0)
	move.l	a0,Active_raster
	clr.l	Next_raster
	clr.l	Current_RL_ptr
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Set a new raster list ]
;   IN : a0 - Pointer to raster list (.l)
; All registers are restored
; NOTE :
;   - The new raster list becomes active with the next frame.
;*****************************************************************************
Set_raster_list:
	movem.l	d0-d7/a0-a4,-(sp)
	move.l	a0,Current_RL_ptr
	lea.l	Raster_events1,a1		; Use the inactive buffer
	cmp.l	Active_raster,a1
	bne.s	.Go
	lea.l	Raster_events2,a1
.Go:	move.l	a1,a3
	sub.l	a2,a2			; No palette yet
.Loop:	move.b	(a0)+,d0			; Get entry type
	bmi.s	.End
	moveq.l	#0,d1			; Get line
	move.b	(a0)+,d1
	tst.b	d0
	bne.s	.Range
; ---------- Complete palette ---------------------
	move.b	(a0)+,d2			; Get pointer (unaligned)
	lsl.w	#8,d2
	move.b	(a0)+,d2
	swap	d2
	move.b	(a0)+,d2
	lsl.w	#8,d2
	move.b	(a0)+,d2
	move.l	d2,a2			; Current palette block
	subq.w	#1,d1			; One line earlier
	bpl.s	.Ok
	moveq.l	#0,d1
.Ok:	move.w	d1,(a1)+
	move.w	#-1,(a1)+
	move.l	d2,(a1)+
	bra.s	.Loop
; ---------- Colour range -------------------------
.Range:	moveq.l	#0,d2			; Get colour number
	move.b	(a0)+,d2
	moveq.l	#0,d3			; Get number of lines
	move.b	(a0)+,d3
	move.b	(a0)+,d4			; Get pointer (unaligned)
	lsl.w	#8,d4
	move.b	(a0)+,d4
	swap	d4
	move.b	(a0)+,d4
	lsl.w	#8,d4
	move.b	(a0)+,d4
	move.l	d4,a4
	move.l	a2,d5			; Any palette ?
	beq.s	.Loop
	andi.w	#31,d2			; Translate colour number
	moveq.l	#0,d5
	move.b	16*2(a2,d2.w),d5
	bra.s	.Next
.Loop2:	move.w	(a4)+,d0			; Convert colour
	jsr	Amiga_to_STE_colour
	move.w	d1,(a1)+
	cmp.w	#1,d1			; Line 1 ?
	bne.s	.Not1
	clr.w	-2(a1)			; Yes -> in the VBL
.Not1:
	move.w	d5,(a1)+
	clr.w	(a1)+
	move.w	d0,(a1)+
	addq.w	#1,d1
.Next:	dbra	d3,.Loop2
	bra.s	.Loop
; ---------- End : sort by line ------------------
.End:	move.w	#$7fff,(a1)+
	move.l	a3,a0
	jsr	Sort_raster_events
	move.l	a3,Next_raster
	movem.l	(sp)+,d0-d7/a0-a4
	rts

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

;*****************************************************************************
; [ Get the ST colour of an Amiga colour number ]
;   IN : d1 - Y-coordinate (.w)
;        d4 - Amiga colour number (.w)
;  OUT : d4 - ST colour (0...15) (.w)
; Changed registers : d4
; NOTE :
;   - The lookup table of the palette which is active on the line is used.
;*****************************************************************************
Get_ST_colour:
	movem.l	d0/d2/a0/a1,-(sp)
	move.l	Current_RL_ptr,d0
	beq.s	.None
	move.l	d0,a0
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
	beq.s	.None
	andi.w	#31,d4
	move.b	16*2(a1,d4.w),d4
	ext.w	d4
	bra.s	.Exit
.None:	andi.w	#15,d4
.Exit:	movem.l	(sp)+,d0/d2/a0/a1
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
	move.w	6(a0),d0
	jsr	Fade_colour
	move.w	d0,0(a1,d1.w)
	addq.l	#8,a0
	bra.s	.Loop
.Full:	move.l	4(a0),a2
	movem.l	(a2),d0-d7
	jsr	Fade_palette_regs
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
	tst.w	Fade_level
	bne.s	.Fade1
	move.w	6(a0),0(a1,d0.w)
	bra.s	.Next
.Fade1:	move.l	d1,-(sp)
	move.w	d0,d1
	move.w	6(a0),d0
	jsr	Fade_colour
	move.w	d0,0(a1,d1.w)
	move.l	(sp)+,d1
	bra.s	.Next
.Full:	move.l	4(a0),a2			; Complete palette
	tst.w	Fade_level
	bne.s	.Fade
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	lea.l	Palette_regs,a1
	bra.s	.Next
.Fade:	movem.l	d1-d7,-(sp)
	movem.l	(a2),d0-d7
	jsr	Fade_palette_regs
	movem.l	d0-d7,(a1)
	movem.l	(sp)+,d1-d7
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
; [ Fade 16 colours towards black ]
;   IN : d0-d7 - 16 STE colours (2 per register) (.l)
;  OUT : d0-d7 - faded colours (.l)
; All other registers are restored
; NOTE :
;   - [ Fade_level ] is 0 (full colours) ... 15 (black). The colours are
;     scaled, unlike the Amiga version, which counts every component down.
;*****************************************************************************
Fade_palette_regs:
	tst.w	Fade_level
	beq.s	.Exit
	movem.l	d0-d7,Fade_buffer
	movem.l	a0/a1/d0-d3,-(sp)
	move.w	Fade_level,d0		; Table offset
	lsl.w	#4,d0
	move.w	d0,Fade_offset
	lea.l	Fade_buffer,a0
	lea.l	STE_to_linear,a1
	moveq.l	#16-1,d3
.Loop:	move.w	(a0),d0
	moveq.l	#0,d1
	rol.w	#4,d0			; Skip the unused top nibble
	moveq.l	#3-1,d2
.Loop2:	rol.w	#4,d1
	rol.w	#4,d0
	move.w	d0,-(sp)
	andi.w	#$f,d0
	move.b	0(a1,d0.w),d0		; 0...15
	add.w	Fade_offset,d0		; Scale & convert
	move.b	Fade_scale(pc,d0.w),d0
	or.b	d0,d1
	move.w	(sp)+,d0
	dbra	d2,.Loop2
	move.w	d1,(a0)+
	dbra	d3,.Loop
	movem.l	(sp)+,a0/a1/d0-d3
	movem.l	Fade_buffer,d0-d7
.Exit:	rts

;*****************************************************************************
; [ Fade one colour towards black ]
;   IN : d0 - STE colour (.w)
;  OUT : d0 - faded colour (.w)
; All other registers are restored
; NOTE :
;   - Like [ Fade_palette_regs ], for the colours of the ranges.
;*****************************************************************************
Fade_colour:
	tst.w	Fade_level
	beq.s	.Exit
	movem.l	d1-d3/a1/a2,-(sp)
	move.w	Fade_level,d3		; Table offset
	lsl.w	#4,d3
	lea.l	STE_to_linear,a1
	lea.l	Fade_scale,a2
	moveq.l	#0,d1
	rol.w	#4,d0			; Skip the unused top nibble
	moveq.l	#3-1,d2
.Loop:	rol.w	#4,d1
	rol.w	#4,d0
	move.w	d0,-(sp)
	andi.w	#$f,d0
	move.b	0(a1,d0.w),d0		; 0...15
	add.w	d3,d0			; Scale & convert
	move.b	0(a2,d0.w),d0
	or.b	d0,d1
	move.w	(sp)+,d0
	dbra	d2,.Loop
	move.w	d1,d0
	movem.l	(sp)+,d1-d3/a1/a2
.Exit:	rts

; Amiga nibble (0...15) -> STE nibble (bit 3 is the lowest bit)
STE_nibbles:
	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
; Fade level (0...15) x linear value (0...15) -> STE nibble of value * (15 - level) / 15
; (all colour components are scaled, so the colours keep their hue while fading)
Fade_scale:
	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$b,$4,$c,$5,$d,$6,$e,$7
	dc.b	$0,$8,$1,$9,$9,$2,$a,$3,$b,$4,$c,$5,$5,$d,$6,$e
	dc.b	$0,$8,$1,$1,$9,$2,$a,$3,$3,$b,$4,$c,$5,$5,$d,$6
	dc.b	$0,$8,$8,$1,$9,$2,$2,$a,$3,$b,$b,$4,$c,$5,$5,$d
	dc.b	$0,$8,$8,$1,$9,$9,$2,$a,$a,$3,$b,$b,$4,$c,$c,$5
	dc.b	$0,$8,$8,$1,$1,$9,$2,$2,$a,$a,$3,$b,$b,$4,$4,$c
	dc.b	$0,$8,$8,$1,$1,$9,$9,$2,$2,$a,$a,$3,$3,$b,$b,$4
	dc.b	$0,$0,$8,$8,$1,$1,$9,$9,$2,$2,$a,$a,$3,$3,$b,$b
	dc.b	$0,$0,$8,$8,$1,$1,$1,$9,$9,$2,$2,$2,$a,$a,$3,$3
	dc.b	$0,$0,$8,$8,$8,$1,$1,$1,$9,$9,$9,$2,$2,$2,$a,$a
	dc.b	$0,$0,$8,$8,$8,$8,$1,$1,$1,$1,$9,$9,$9,$9,$2,$2
	dc.b	$0,$0,$0,$8,$8,$8,$8,$8,$1,$1,$1,$1,$1,$9,$9,$9
	dc.b	$0,$0,$0,$0,$8,$8,$8,$8,$8,$8,$8,$8,$1,$1,$1,$1
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$8,$8,$8,$8,$8,$8,$8,$8
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
; STE nibble -> linear value (0...15)
STE_to_linear:
	dc.b	0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
	even

;*****************************************************************************
; [ Fade in / out (whole screen) ]
;   IN : d0 - 0 = fade in, 1 = fade out (.w)
; All registers are restored
;*****************************************************************************
Fade_screen:
	move.l	d1,-(sp)
	tst.w	d0
	bne.s	.Out
	moveq.l	#15,d1
.Loop1:	move.w	d1,Fade_level
	jsr	My_vsync
	jsr	My_vsync
	dbra	d1,.Loop1
	clr.w	Fade_level
	bra.s	.Exit
.Out:	moveq.l	#0,d1
.Loop2:	move.w	d1,Fade_level
	jsr	My_vsync
	jsr	My_vsync
	addq.w	#1,d1
	cmp.w	#16,d1
	bmi.s	.Loop2
.Exit:	move.l	(sp)+,d1
	rts

	SECTION	Fast_BSS,bss
Active_raster:	ds.l 1
Next_raster:	ds.l 1
Raster_event_ptr:	ds.l 1
Current_RL_ptr:	ds.l 1
Fade_level:	ds.w 1
Fade_offset:	ds.w 1
Fade_buffer:	ds.w 16
Raster_events1:	ds.b 8*256
Raster_events2:	ds.b 8*256
