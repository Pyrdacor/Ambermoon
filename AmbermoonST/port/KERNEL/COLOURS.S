; ST kernel : raster lists, colours & fading
; Replaces KERNEL/COLOURS.S of the Amiga version.
;
; The raster lists are the same as in the Amiga version : R_palette sets the
; 32 colours of an Amiga palette from a line on, R_range one colour per line.
; The fading works like in the Amiga version on [ Current_RL ] (a copy of the
; raster list with the colours, every component is counted towards the
; target). Instead of the copper list, [ Render_raster ] shows the colours
; of [ Current_RL ] with the hardware (RASTER.S : the ST shows every palette
; with 16 colours and raster interrupts, the Falcon with its own colours).
; [ Store_RL_source ] (RASTER.S) learns about the palettes when their target
; colours change.

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the colours ]
; All registers are restored
;*****************************************************************************
Init_copper:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Init_raster
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

	SECTION	Fast_DATA,data
Copper_init_data:
	dc.b	0,0
	dc.l	Init_palette
	dc.b	$ff,0
	even

	SECTION	Fast_BSS,bss
Init_palette:	ds.w 32
Fade_command:	ds.w 1
Fade_top:	ds.w 1
Fade_bottom:	ds.w 1
Fade_RL_ptr:	ds.l 1
Current_RL:	ds.b 2048
