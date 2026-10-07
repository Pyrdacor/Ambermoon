; Copper list, colours, fading & drug effect
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the copper list and the colours ]
; All registers are restored
;*****************************************************************************
Init_copper:
	movem.l	d0-d7/a0-a6,-(sp)
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	move.w	#1,d0
	moveq.l	#0,d1
	move.w	#199,d2
	lea.l	Copper_init_data,a0
	jsr	Set_fade
	jsr	Colour_handler
	jsr	Update_copper_list
	move.l	#Copper_list,Custom+cop1lc
	jsr	My_vsync
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
; [ Handle colour changes (fading, drug effect) ]
; Executes the current fade command (see [ Set_fade ]) once per frame.
; All registers are restored
;*****************************************************************************
Colour_handler:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	Fade_command,d0
	bne.s	.Skip2
	tst.b	Drugged_FX
	bne.s	.Skip
	move.w	Vertical_screen_offset,d0
	cmp.w	Last_screen_offset,d0
	beq.s	.Exit
	move.w	d0,Last_screen_offset
.Skip:
	jsr	Render_drug_effect
	bra.s	.Exit
.Skip2:
	lea.l	.Exit+2,a0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),a0
	jsr	(a0)
.Exit:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	dc.l	.Skip3,.Skip4,.Skip9,.Skip6
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
	jsr	Render_drug_effect
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
	jsr	Render_drug_effect
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
	jsr	Render_drug_effect
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
	jsr	Render_drug_effect
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
;*****************************************************************************
Copy_RL_entry:
	tst.b	d0
	bne.s	.Skip
	move.b	(a0)+,(a1)+
	move.l	(a0)+,a2
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
	addq.l	#4,a0
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

;*****************************************************************************
; [ Copper interrupt routine ]
; Updates the copper list and the colours and calls the vertical blank handler.
; All registers are restored
;*****************************************************************************
Run_copper:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Update_copper_list
	jsr	Colour_handler
	jsr	Vbl_handler
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Create the copper list for the drug effect (wobbling screen) ]
; All registers are restored
;*****************************************************************************
Render_drug_effect:
	movem.l	d0-d3/d6/d7/a0-a2,-(sp)
	tst.b	Drugged_FX
	beq.w	.Skip8
	move.w	Drug_copper_data,d0
	addq.w	#4,d0
	andi.w	#$7c,d0
	move.w	d0,Drug_copper_data
	tst.w	d0
	beq.s	.Skip2
	lea.l	Drug_copper_list,a0
	add.w	d0,a0
	jsr	Random
	andi.w	#1,d0
	move.w	d0,(a0)
	jsr	Random
	andi.w	#$f,d0
	subi.w	#9,d0
	tst.w	(a0)+
	beq.s	.Skip
	asl.w	#8,d0
.Skip:
	move.w	d0,(a0)+
.Skip2:
	move.l	Drug_copper_ptr,a0
	move.w	#130,d0
	move.l	#Copper_list,d1
	jsr	Insert_copper_move
	move.w	#128,d0
	swap	d1
	jsr	Insert_copper_move
	lea.l	Current_RL,a1
.Loop:
	move.b	(a1)+,d0
	cmp.b	#-1,d0
	beq.w	.Skip11
	tst.b	d0
	bne.w	.Skip6
	moveq.l	#9,d0
	moveq.l	#0,d1
	move.b	(a1)+,d1
	addi.w	#47,d1
	add.w	Vertical_screen_offset,d1
	jsr	Insert_copper_wait
	move.w	#384,d0
	move.w	(a1)+,d1
	jsr	Insert_copper_move
	addq.w	#2,d0
	lea.l	Drug_copper_data2,a2
	moveq.l	#30,d7
.Loop2:
	move.w	(a1)+,d1
	tst.w	(a2)+
	bne.s	.Skip3
	moveq.l	#15,d2
	and.w	d1,d2
	sub.w	d2,d1
	add.w	(a2)+,d2
	bmi.s	.Skip5
	cmp.w	#16,d2
	bmi.s	.Skip4
	moveq.l	#15,d2
	bra.s	.Skip4
.Skip3:
	move.w	d1,d2
	andi.w	#$f00,d2
	sub.w	d2,d1
	add.w	(a2)+,d2
	bmi.s	.Skip5
	cmp.w	#$1000,d2
	bmi.s	.Skip4
	move.w	#3840,d2
.Skip4:
	or.w	d2,d1
.Skip5:
	jsr	Insert_copper_move
	addq.w	#2,d0
	dbra	d7,.Loop2
	bra.s	.Loop
.Skip6:
	moveq.l	#0,d2
	move.b	(a1)+,d2
	addi.w	#48,d2
	add.w	Vertical_screen_offset,d2
	moveq.l	#0,d3
	move.b	(a1)+,d3
	andi.b	#$1f,d3
	add.w	d3,d3
	addi.w	#384,d3
	moveq.l	#0,d7
	move.b	(a1)+,d7
	bra.s	.Skip7
.Loop3:
	moveq.l	#9,d0
	move.w	d2,d1
	jsr	Insert_copper_wait
	move.w	d3,d0
	move.w	(a1)+,d1
	jsr	Insert_copper_move
	addq.w	#1,d2
.Skip7:
	dbra	d7,.Loop3
	bra.w	.Loop
.Skip8:
	move.l	Drug_copper_ptr,a0
	move.w	#130,d0
	move.l	#Copper_list,d1
	jsr	Insert_copper_move
	move.w	#128,d0
	swap	d1
	jsr	Insert_copper_move
	lea.l	Current_RL,a1
.Loop4:
	move.b	(a1)+,d0
	cmp.b	#-1,d0
	beq.w	.Skip11
	tst.b	d0
	bne.w	.Skip9
	moveq.l	#9,d0
	moveq.l	#0,d1
	move.b	(a1)+,d1
	addi.w	#47,d1
	add.w	Vertical_screen_offset,d1
	jsr	Insert_copper_wait
	move.w	#384,d0
	moveq.l	#31,d7
.Loop5:
	move.w	(a1)+,d1
	jsr	Insert_copper_move
	addq.w	#2,d0
	dbra	d7,.Loop5
	bra.s	.Loop4
.Skip9:
	moveq.l	#0,d2
	move.b	(a1)+,d2
	addi.w	#48,d2
	add.w	Vertical_screen_offset,d2
	moveq.l	#0,d3
	move.b	(a1)+,d3
	andi.b	#$1f,d3
	add.w	d3,d3
	addi.w	#384,d3
	moveq.l	#0,d7
	move.b	(a1)+,d7
	bra.s	.Skip10
.Loop6:
	moveq.l	#9,d0
	move.w	d2,d1
	jsr	Insert_copper_wait
	move.w	d3,d0
	move.w	(a1)+,d1
	jsr	Insert_copper_move
	addq.w	#1,d2
.Skip10:
	dbra	d7,.Loop6
	bra.s	.Loop4
.Skip11:
	move.w	#9,d0
	move.w	#249,d1
	jsr	Insert_copper_wait
	move.w	#156,d0
	move.w	#-32752,d1
	jsr	Insert_copper_move
	move.l	#-2,(a0)
	move.l	Drug_copper_ptr,a0
	move.l	Copper_list2_ptr,Drug_copper_ptr
	move.l	a0,Copper_list2_ptr
	movem.l	(sp)+,d0-d3/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Insert a copper MOVE instruction ]
;   IN : d0 - Register offset (.w)
;        d1 - Value (.w)
;        a0 - Pointer to copper list (.l)
;  OUT : a0 - Updated pointer (.l)
;*****************************************************************************
Insert_copper_move:
	move.l	d0,-(sp)
	andi.w	#$1fe,d0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Insert a copper WAIT instruction ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to copper list (.l)
;  OUT : a0 - Updated pointer (.l)
;*****************************************************************************
Insert_copper_wait:
	movem.l	d0/d1,-(sp)
	lsl.w	#8,d1
	add.w	d0,d0
	or.w	d0,d1
	ori.w	#1,d1
	move.w	d1,(a0)+
	move.w	#-2,(a0)+
	movem.l	(sp)+,d0/d1
	rts


	SECTION	Chip_DATA,data_c
Copper_list:
	dc.w	$1013		; Wait for x=9, y=16
	dc.w	$fffe
	dc.w	$8e		; Move data to upper-left window position reg

	SECTION	Fast_DATA,data
	dc.w	$4000
	dc.b	$20,0,$10,0,8,0,4,0,2,0,1,0,0,$80,0,$40
	dc.b	0,$20,0,$10,0,8,0,4,0,2,0,1
Copper_list2_ptr:
	dc.l	Copper_list2
Drug_copper_ptr:
	dc.l	Custom_copper_command_area
Copper_init_data:
	dc.b	0,0
	dc.l	Init_palette
	dc.b	$ff,0

	SECTION	Fast_BSS,bss
Init_palette:
	ds.b	62
Drug_copper_list:
	ds.b	2
Drug_copper_data:
	ds.w	1
Drug_copper_data2:
	ds.w	3
	ds.b	118
Fade_command:
	ds.w	1
Fade_top:
	ds.w	1
Fade_bottom:
	ds.w	1
Fade_RL_ptr:
	ds.l	1
Current_RL:
	ds.b	1
