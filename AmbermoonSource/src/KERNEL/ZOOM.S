; Zoomed graphics for combat (Draw_zoom_shape)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Draw a zoomed graphic ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Mask (.w)
;        d4 - Source width (.w)
;        d5 - Source height (.w)
;        d6 - New width (.w)
;        d7 - New height (.w)
;        a0 - Pointer to graphics (.l)
;*****************************************************************************
Draw_zoom_shape:
	movem.l	d0-d7/a0-a6,-(sp)
	btst.l	#0,d3
	sne	Zoom_mirror_X
	btst.l	#1,d3
	sne	Zoom_mirror_Y
	move.w	d4,Zoom_source_width
	move.w	d5,Zoom_source_height
	move.l	a0,Zoom_gfx_ptr
	jsr	Prepare_zoom_shape
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Clip and prepare a zoomed combat graphic ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Target width (.w)
;        d7 - Target height (.w)
;*****************************************************************************
Prepare_zoom_shape:
	move.w	d0,Zoom_X
	move.w	d1,Zoom_Y
	move.w	d7,d0
	move.w	d6,d7
	move.w	d0,Zoom_target_height
	move.w	d7,Zoom_target_width
	move.l	CA_Sp,a0
	move.l	(a0),a0
	clr.w	Zoom_clip_left
	clr.w	Zoom_clip_bottom
	move.w	Zoom_X,d2
	sub.w	(a0),d2
	bpl.s	.Skip
	add.w	d2,d7
	ble.w	Zoom_shape_exit
	move.w	(a0),Zoom_X
	neg.w	d2
	mulu.w	Zoom_source_width,d2
	divu.w	Zoom_target_width,d2
	andi.w	#-$10,d2
	move.w	d2,Zoom_clip_left
.Skip:
	move.w	Zoom_Y,d2
	add.w	d0,d2
	subq.w	#1,d2
	sub.w	CA_Y2(a0),d2
	ble.s	.Skip2
	sub.w	d2,d0
	ble.w	Zoom_shape_exit
	mulu.w	Zoom_source_height,d2
	divu.w	Zoom_target_height,d2
	move.w	d2,Zoom_clip_bottom
.Skip2:
	clr.w	Zoom_clip_top2
	clr.w	Zoom_clip_top
	move.w	Zoom_Y,d2
	sub.w	CA_Y1(a0),d2
	bpl.s	.Skip3
	add.w	d2,d0
	ble.w	Zoom_shape_exit
	neg.w	d2
	move.w	d2,Zoom_clip_top
	move.w	CA_Y1(a0),Zoom_Y
.Skip3:
	move.w	Zoom_X,d2
	add.w	d7,d2
	subq.w	#1,d2
	sub.w	CA_X2(a0),d2
	ble.s	.Skip4
	sub.w	d2,d7
	ble.w	Zoom_shape_exit
	move.w	d2,Zoom_clip_top2
.Skip4:
	move.w	d0,Zoom_visible_height
	move.w	d7,Zoom_visible_width
	jsr	Make_zoom_tables
	lea.l	Custom,a6
	tst.b	Zoom_mirror_X
	bne.s	.Skip5
	tst.b	Zoom_mirror_Y
	bne.s	.Skip5
	move.w	Zoom_target_height,d0
	cmp.w	Zoom_source_height,d0
	bgt.w	Zoom_shape_draw
.Skip5:
	move.l	Zoom_gfx_ptr,a0
	move.w	Zoom_source_width,d6
	sub.w	Zoom_source_X_offset,d6
	sub.w	Zoom_clip_left,d6
	addi.w	#15,d6
	lsr.w	#4,d6
	move.w	d6,d5
	addi.w	#320,d6
	move.w	Zoom_source_width,d0
	andi.w	#-$10,d0
	move.w	d0,d4
	lsr.w	#1,d0
	move.w	d0,d1
	lsr.w	#2,d1
	add.w	d1,d0
	move.w	d0,d1
	tst.b	Zoom_mirror_Y
	beq.s	.Skip6
	move.w	Zoom_source_height,d7
	subq.w	#1,d7
	sub.w	Zoom_source_Y_offset,d7
	mulu.w	d7,d0
	bra.s	.Skip7
.Skip6:
	mulu.w	Zoom_source_Y_offset,d0
.Skip7:
	add.w	d0,a0
	tst.b	Zoom_mirror_X
	beq.s	.Skip8
	move.w	Zoom_clip_top2,d0
	mulu.w	Zoom_source_width,d0
	divu.w	Zoom_target_width,d0
	andi.w	#-$10,d0
	bra.s	.Skip9
.Skip8:
	move.w	Zoom_clip_left,d0
.Skip9:
	lsr.w	#3,d0
	add.w	d0,a0
	add.w	d5,d5
	lsr.w	#3,d4
	sub.w	d5,d4
	neg.w	d5
	addi.w	#40,d5
	move.l	Zoomscreen1_ptr,a1
	lea.l	Zoom_Y_table,a2
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	a1,bltdpt(a6)
	move.w	d4,bltamod(a6)
	move.w	d5,bltdmod(a6)
	move.l	#$9f00000,bltcon0(a6)
	move.l	#-$1,bltafwm(a6)
	lea.l	bltapt(a6),a4
	lea.l	bltsize(a6),a5
	move.w	Zoom_visible_height,d7
	subq.w	#1,d7
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	a0,(a4)
	move.w	d6,(a5)
	move.w	(a2)+,d0
	muls.w	d1,d0
	add.w	d0,a0
	dbra	d7,.Wait2
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	move.w	Zoom_source_width,d4
	sub.w	Zoom_source_X_offset,d4
	sub.w	Zoom_clip_left,d4
	addi.w	#15,d4
	lsr.w	#4,d4
	move.w	Zoom_visible_height,d5
	moveq.l	#-1,d6
	jsr	Merge_zoom_screen
	move.l	Zoomscreen2_ptr,a3
	move.l	Zoomscreen1_ptr,a0
	move.l	Work_screen,a1
	move.w	Zoom_Y,d0
	mulu.w	#200,d0
	add.l	d0,a1
	move.w	Zoom_X,d0
	add.w	Zoom_visible_width,d0
	subq.w	#1,d0
	moveq.l	#15,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#3,d0
	add.w	d0,a1
	eori.w	#$f,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.w	Zoom_visible_height,d5
	mulu.w	#320,d5
	addq.w	#1,d5
	moveq.l	#0,d6
	tst.b	Zoom_mirror_X
	beq.s	.Skip10
	move.w	Zoom_source_X_offset,d6
	andi.w	#$f,d6
	bra.s	.Skip11
.Skip10:
	move.w	Zoom_source_width,d6
	subq.w	#1,d6
	sub.w	Zoom_source_X_offset,d6
	sub.w	Zoom_clip_left,d6
.Skip11:
	move.w	#38,a4
	move.w	#-42,a5
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	move.w	a4,bltcmod(a6)
	move.w	a4,bltdmod(a6)
	move.w	a4,bltamod(a6)
	move.w	a4,bltbmod(a6)
	move.l	#-$1,bltafwm(a6)
	lea.l	Zoom_X_table,a2
	move.w	Zoom_visible_width,d7
	subq.w	#1,d7
Zoom_column_loop:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#15,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	move.l	d0,d2
	add.l	a0,d0
	add.l	a3,d2
	move.w	d1,d4
	eori.w	#$f,d1
.Wait5:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait5
	add.w	d4,d4
	move.w	Zoom_shift_table(pc,d4.w),bltafwm(a6)
	move.l	a1,bltcpt(a6)
	move.l	a1,bltdpt(a6)
	move.l	d0,bltbpt(a6)
	move.l	d2,bltapt(a6)
	sub.w	d3,d1
	bmi.s	Zoom_shape_next
Zoom_shape_loop:
	ror.w	#4,d1
	move.w	d1,bltcon1(a6)
	ori.w	#$fca,d1
	move.w	d1,bltcon0(a6)
	move.w	d5,bltsize(a6)
	addq.w	#1,d3
	andi.w	#$f,d3
	bne.s	.Skip12
	subq.l	#2,a1
.Skip12:
	dbra	d7,Zoom_column_loop
	rts

;*****************************************************************************
; [ Zoom_shift_table ]
;*****************************************************************************
Zoom_shift_table:
	dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100
	dc.w	$80,$40,$20,$10,8,4,2,1
Zoom_shape_next:
	move.w	a5,96(a6)
	move.w	a5,102(a6)
	move.w	a5,100(a6)
	move.w	a5,98(a6)
	bra.w	.Skip2
.Loop:
	move.w	a4,96(a6)
	move.w	a4,102(a6)
	move.w	a4,100(a6)
	move.w	a4,98(a6)
	bra.s	Zoom_shape_loop
.Loop2:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#15,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	move.l	d0,d2
	add.l	a0,d0
	add.l	a3,d2
	move.w	d1,d4
	eori.w	#$f,d1
.Wait:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait
	add.w	d4,d4
	move.w	Zoom_mask_table(pc,d4.w),68(a6)
	move.l	a1,72(a6)
	move.l	a1,84(a6)
	move.l	d0,76(a6)
	move.l	d2,80(a6)
	sub.w	d3,d1
	bpl.s	.Loop
.Skip2:
	neg.w	d1
	ror.w	#4,d1
	moveq.l	#2,d2
	or.w	d1,d2
	ori.w	#$fca,d1
	move.w	d1,64(a6)
	move.w	d2,66(a6)
	move.w	d5,88(a6)
	addq.w	#1,d3
	andi.w	#$f,d3
	bne.s	.Skip3
	subq.l	#2,a1
.Skip3:
	dbra	d7,.Loop2
	rts

Zoom_mask_table:
	dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100
	dc.w	$80,$40,$20,$10,8,4,2,1

;*****************************************************************************
; [ Draw the zoomed columns with the blitter ]
;   IN : a6 - Custom (.l)
;*****************************************************************************
Zoom_columns:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	Zoom_columns
	move.w	#0,66(a6)
	move.w	#38,96(a6)
	move.w	#38,102(a6)
	move.w	a4,100(a6)
	move.l	#-1,68(a6)
	lea.l	Zoom_X_table,a2
	move.w	Zoom_visible_width,d7
	subq.w	#1,d7
.Loop:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#15,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.l	a0,d0
	eori.w	#$f,d1
.Wait:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait
	move.w	d4,114(a6)
	move.l	a1,72(a6)
	move.l	a1,84(a6)
	move.l	d0,80(a6)
	sub.w	d3,d1
	bmi.s	.Skip2
.Loop2:
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,64(a6)
	move.w	d5,88(a6)
	addq.w	#1,d3
	add.w	d4,d4
	bcc.s	.Skip
	moveq.l	#1,d4
	moveq.l	#0,d3
	subq.l	#2,a1
.Skip:
	dbra	d7,.Loop
	rts
.Skip2:
	move.w	#2,66(a6)
	move.w	#-42,96(a6)
	move.w	#-42,102(a6)
	move.w	a5,100(a6)
	bra.w	.Skip3
.Loop3:
	move.w	#0,66(a6)
	move.w	#38,96(a6)
	move.w	#38,102(a6)
	move.w	a4,100(a6)
	bra.s	.Loop2
.Loop4:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#15,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.l	a0,d0
	eori.w	#$f,d1
.Wait2:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait2
	move.w	d4,114(a6)
	move.l	d0,80(a6)
	move.l	a1,72(a6)
	move.l	a1,84(a6)
	sub.w	d3,d1
	bpl.s	.Loop3
.Skip3:
	neg.w	d1
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,64(a6)
	move.w	d5,88(a6)
	addq.w	#1,d3
	add.w	d4,d4
	bcc.s	.Skip4
	moveq.l	#1,d4
	moveq.l	#0,d3
	subq.l	#2,a1
.Skip4:
	dbra	d7,.Loop4
Zoom_shape_exit:
	rts
Zoom_shape_draw:
	move.l	Zoom_gfx_ptr,a0
	move.l	Zoomscreen1_ptr,a1
	lea.l	Zoom_X_table,a2
	move.w	Zoom_source_width,d5
	andi.w	#-$10,d5
	lsr.w	#1,d5
	move.w	d5,d0
	lsr.w	#2,d5
	add.w	d0,d5
	mulu.w	Zoom_source_Y_offset,d5
	add.w	d5,a0
	moveq.l	#0,d3
	move.w	Zoom_X,d0
	andi.w	#$f,d0
	add.w	Zoom_visible_width,d0
	subq.w	#1,d0
	moveq.l	#15,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#3,d0
	add.w	d0,a1
	eori.w	#$f,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.w	Zoom_source_height,d5
	sub.w	Zoom_source_Y_offset,d5
	sub.w	Zoom_clip_bottom,d5
	lsl.w	#6,d5
	move.w	d5,d0
	lsl.w	#2,d0
	add.w	d0,d5
	addq.w	#1,d5
	moveq.l	#0,d6
	move.w	Zoom_source_width,d6
	subq.w	#1,d6
	sub.w	Zoom_source_X_offset,d6
	move.w	Zoom_source_width,d0
	lsr.w	#4,d0
	add.w	d0,d0
	move.w	d0,d1
	neg.w	d1
	subq.w	#2,d0
	subq.w	#2,d1
	move.w	d0,a4
	move.w	d1,a5
	bsr.w	Zoom_columns
	move.w	Zoom_X,d0
	andi.w	#$f,d0
	move.w	Zoom_visible_width,d4
	addi.w	#15,d4
	add.w	d0,d4
	lsr.w	#4,d4
	move.w	Zoom_source_height,d5
	sub.w	Zoom_source_Y_offset,d5
	sub.w	Zoom_clip_bottom,d5
	moveq.l	#0,d6
	bsr.w	Merge_zoom_screen
	move.l	Zoomscreen2_ptr,a3
	move.l	Zoomscreen1_ptr,a0
	lea.l	Zoom_Y_table,a2
	move.l	Work_screen,a1
	move.w	Zoom_Y,d0
	mulu.w	#200,d0
	add.l	d0,a1
	move.w	Zoom_X,d0
	moveq.l	#15,d5
	and.w	d0,d5
	sub.w	d5,d0
	lsr.w	#3,d0
	add.w	d0,a1
	move.w	Zoom_visible_width,d0
	addi.w	#15,d0
	add.w	d5,d0
	lsr.w	#4,d0
	move.w	d0,d6
	add.w	d0,d0
	neg.w	d0
	move.w	d0,d1
	addi.w	#40,d0
	addi.w	#320,d6
.Wait3:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait3
	move.l	a1,72(a6)
	move.l	a1,84(a6)
	move.w	d1,100(a6)
	move.w	d0,98(a6)
	move.w	d0,96(a6)
	move.w	d0,102(a6)
	move.w	#0,66(a6)
	move.w	d5,d4
	add.w	d5,d5
	lea.l	Blitter_masks,a1
	move.w	0(a1,d5.w),68(a6)
	add.w	Zoom_visible_width,d4
	subq.w	#1,d4
	andi.w	#$f,d4
	add.w	d4,d4
	move.w	32(a1,d4.w),70(a6)
	move.w	#-1,116(a6)
	lea.l	76(a6),a4
	lea.l	88(a6),a5
	lea.l	2(a6),a1
	move.w	#4042,64(a6)
	move.w	Zoom_visible_height,d7
	subq.w	#1,d7
.Loop5:
	btst.b	#$e,(a1)
	bne.s	.Loop5
	move.l	a3,4(a4)
	move.l	a0,(a4)
	move.w	d6,(a5)
	move.w	(a2)+,d0
	mulu.w	#40,d0
	add.w	d0,a3
	mulu.w	#5,d0
	add.w	d0,a0
	dbra	d7,.Loop5
	rts

;*****************************************************************************
; [ Combine the zoom screens into the mask ]
;   IN : a6 - Custom (.l)
;*****************************************************************************
Merge_zoom_screen:
	move.w	d4,d3
	add.w	d3,d3
	move.w	#200,d0
	move.w	#40,d1
	sub.w	d3,d0
	sub.w	d3,d1
	tst.w	d6
	beq.s	.Skip
	move.w	d0,d1
.Skip:
	move.l	Zoomscreen1_ptr,a0
	move.l	Zoomscreen2_ptr,a1
	move.w	d5,d3
	lsl.w	#6,d3
	add.w	d4,d3
.Wait:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait
	move.l	#-1,68(a6)
	move.w	d1,102(a6)
	move.w	d0,100(a6)
	move.w	d0,98(a6)
	move.w	d0,96(a6)
	move.l	a0,80(a6)
	lea.l	40(a0),a0
	move.l	a0,76(a6)
	lea.l	40(a0),a0
	move.l	a0,72(a6)
	lea.l	40(a0),a0
	move.l	a1,84(a6)
	move.w	#4094,64(a6)
	move.w	#0,66(a6)
	move.w	d3,88(a6)
.Wait2:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait2
	move.w	d1,102(a6)
	move.w	d0,100(a6)
	move.w	d0,98(a6)
	move.w	d1,96(a6)
	move.l	a0,80(a6)
	lea.l	40(a0),a0
	move.l	a0,76(a6)
	move.l	a1,72(a6)
	move.l	a1,84(a6)
	move.w	#4094,64(a6)
	move.w	d3,88(a6)
	tst.w	d6
	beq.s	.Exit
.Wait3:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait3
	move.w	#2544,64(a6)
	move.l	Zoomscreen2_ptr,a0
	lea.l	40(a0),a1
	moveq.l	#3,d7
.Wait4:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait4
	move.l	a0,80(a6)
	move.l	a1,84(a6)
	move.w	d3,88(a6)
	lea.l	40(a1),a1
	dbra	d7,.Wait4
.Exit:
	rts

;*****************************************************************************
; [ Calculate the X and Y step tables for a zoomed combat graphic ]
;*****************************************************************************
Make_zoom_tables:
	lea.l	Zoom_Y_table,a0
	move.w	Zoom_target_height,d7
	move.w	Zoom_source_height,d0
	subq.w	#1,d0
	ext.l	d0
	divs.w	d7,d0
	move.w	d0,d4
	swap	d0
	move.w	d7,d1
	move.w	d1,d2
	addq.w	#1,d0
	moveq.l	#0,d3
	move.w	Zoom_clip_top,d6
	beq.s	.Skip
	move.w	d4,d3
	mulu.w	d6,d3
	move.w	d0,d7
	mulu.w	d6,d7
	divu.w	d2,d7
	add.w	d7,d3
	swap	d7
	sub.w	d7,d2
.Skip:
	subq.w	#1,d2
	move.w	d3,Zoom_source_Y_offset
	tst.b	Zoom_mirror_Y
	beq.s	.Skip3
	neg.w	d4
	move.w	Zoom_visible_height,d6
	subq.w	#1,d6
.Loop:
	move.w	d4,d5
	sub.w	d0,d2
	bpl.s	.Skip2
	add.w	d1,d2
	subq.w	#1,d5
.Skip2:
	move.w	d5,(a0)+
	dbra	d6,.Loop
	bra.s	.Skip5
.Skip3:
	move.w	Zoom_visible_height,d6
	subq.w	#1,d6
.Loop2:
	move.w	d4,d5
	sub.w	d0,d2
	bpl.s	.Skip4
	add.w	d1,d2
	addq.w	#1,d5
.Skip4:
	move.w	d5,(a0)+
	dbra	d6,.Loop2
.Skip5:
	lea.l	Zoom_X_table,a0
	move.w	Zoom_target_width,d7
	move.w	Zoom_source_width,d0
	subq.w	#1,d0
	ext.l	d0
	divs.w	d7,d0
	move.w	d0,d4
	swap	d0
	move.w	d7,d1
	move.w	d1,d2
	addq.w	#1,d0
	moveq.l	#0,d3
	move.w	Zoom_clip_top2,d6
	beq.s	.Skip6
	move.w	d4,d3
	mulu.w	d6,d3
	move.w	d0,d7
	mulu.w	d6,d7
	divu.w	d2,d7
	add.w	d7,d3
	swap	d7
	sub.w	d7,d2
.Skip6:
	subq.w	#1,d2
	move.w	d3,Zoom_source_X_offset
	tst.b	Zoom_mirror_X
	beq.s	.Skip8
	neg.w	d4
	move.w	Zoom_visible_width,d6
	subq.w	#1,d6
.Loop3:
	move.w	d4,d5
	sub.w	d0,d2
	bpl.s	.Skip7
	add.w	d1,d2
	subq.w	#1,d5
.Skip7:
	move.w	d5,(a0)+
	dbra	d6,.Loop3
	bra.s	.Exit
.Skip8:
	move.w	Zoom_visible_width,d6
	subq.w	#1,d6
.Loop4:
	move.w	d4,d5
	sub.w	d0,d2
	bpl.s	.Skip9
	add.w	d1,d2
	addq.w	#1,d5
.Skip9:
	move.w	d5,(a0)+
	dbra	d6,.Loop4
.Exit:
	rts

;*****************************************************************************
; [ Draw a zoomed silhouette ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Colour (.w)
;        d4 - Source width (.w)
;        d5 - Source height (.w)
;        d6 - New width (.w)
;        d7 - New height (.w)
;        a0 - Pointer to graphics (.l)
;*****************************************************************************
Draw_zoom_silhouette:
	movem.l	d0-d7/a0-a6,-(sp)
	btst.l	#0,d3
	sne	Zoom_mirror_X
	btst.l	#1,d3
	sne	Zoom_mirror_Y
	move.w	d2,Zoom_colour
	move.w	d4,Zoom_source_width
	move.w	d5,Zoom_source_height
	move.l	a0,Zoom_gfx_ptr
	jsr	Prepare_zoom_silhouette
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Clip and prepare a zoomed combat silhouette ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Target width (.w)
;        d7 - Target height (.w)
;*****************************************************************************
Prepare_zoom_silhouette:
	move.w	d0,Zoom_X
	move.w	d1,Zoom_Y
	move.w	d7,d0
	move.w	d6,d7
	move.w	d0,Zoom_target_height
	move.w	d7,Zoom_target_width
	move.l	CA_Sp,a0
	move.l	(a0),a0
	clr.w	Zoom_clip_left
	clr.w	Zoom_clip_bottom
	move.w	Zoom_X,d2
	sub.w	(a0),d2
	bpl.s	.Skip
	add.w	d2,d7
	ble.w	.Exit
	move.w	(a0),Zoom_X
	neg.w	d2
	mulu.w	Zoom_source_width,d2
	divu.w	Zoom_target_width,d2
	andi.w	#-$10,d2
	move.w	d2,Zoom_clip_left
.Skip:
	move.w	Zoom_Y,d2
	add.w	d0,d2
	subq.w	#1,d2
	sub.w	CA_Y2(a0),d2
	ble.s	.Skip2
	sub.w	d2,d0
	ble.w	.Exit
	mulu.w	Zoom_source_height,d2
	divu.w	Zoom_target_height,d2
	move.w	d2,Zoom_clip_bottom
.Skip2:
	clr.w	Zoom_clip_top2
	clr.w	Zoom_clip_top
	move.w	Zoom_Y,d2
	sub.w	CA_Y1(a0),d2
	bpl.s	.Skip3
	add.w	d2,d0
	ble.w	.Exit
	neg.w	d2
	move.w	d2,Zoom_clip_top
	move.w	CA_Y1(a0),Zoom_Y
.Skip3:
	move.w	Zoom_X,d2
	add.w	d7,d2
	subq.w	#1,d2
	sub.w	CA_X2(a0),d2
	ble.s	.Skip4
	sub.w	d2,d7
	ble.w	.Exit
	move.w	d2,Zoom_clip_top2
.Skip4:
	move.w	d0,Zoom_visible_height
	move.w	d7,Zoom_visible_width
	lea.l	Custom,a6
	move.l	Zoom_gfx_ptr,a0
	move.l	Zoomscreen2_ptr,a1
	move.w	Zoom_source_width,d6
	addi.w	#15,d6
	lsr.w	#4,d6
	move.w	Zoom_source_height,d7
	lsl.w	#6,d7
	add.w	d6,d7
	add.w	d6,d6
	move.w	d6,d0
	lsl.w	#2,d0
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.w	d0,bltamod(a6)
	move.w	d0,bltbmod(a6)
	move.w	d0,bltcmod(a6)
	clr.w	bltdmod(a6)
	move.l	a0,bltapt(a6)
	add.w	d6,a0
	move.l	a0,bltbpt(a6)
	add.w	d6,a0
	move.l	a0,bltcpt(a6)
	add.w	d6,a0
	move.l	a1,bltdpt(a6)
	move.l	#$ffe0000,bltcon0(a6)
	move.w	d7,bltsize(a6)
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	clr.w	bltcmod(a6)
	move.l	a0,bltapt(a6)
	add.w	d6,a0
	move.l	a0,bltbpt(a6)
	move.l	a1,bltcpt(a6)
	move.l	a1,bltdpt(a6)
	move.w	#$ffe,bltcon0(a6)
	move.w	d7,bltsize(a6)
	jsr	Make_zoom_tables
	move.l	Zoomscreen2_ptr,a0
	move.w	Zoom_source_width,d6
	sub.w	Zoom_source_X_offset,d6
	sub.w	Zoom_clip_left,d6
	addi.w	#15,d6
	lsr.w	#4,d6
	move.w	d6,d5
	addi.w	#64,d6
	move.w	Zoom_source_width,d0
	andi.w	#-$10,d0
	move.w	d0,d4
	lsr.w	#3,d0
	move.w	d0,d1
	tst.b	Zoom_mirror_Y
	beq.s	.Skip5
	move.w	Zoom_source_height,d7
	subq.w	#1,d7
	sub.w	Zoom_source_Y_offset,d7
	mulu.w	d7,d0
	bra.s	.Skip6
.Skip5:
	mulu.w	Zoom_source_Y_offset,d0
.Skip6:
	add.w	d0,a0
	tst.b	Zoom_mirror_X
	beq.s	.Skip7
	move.w	Zoom_clip_top2,d0
	mulu.w	Zoom_source_width,d0
	divu.w	Zoom_target_width,d0
	andi.w	#-$10,d0
	bra.s	.Skip8
.Skip7:
	move.w	Zoom_clip_left,d0
.Skip8:
	lsr.w	#3,d0
	add.w	d0,a0
	add.w	d5,d5
	lsr.w	#3,d4
	sub.w	d5,d4
	neg.w	d5
	addi.w	#200,d5
	move.l	Zoomscreen1_ptr,a1
	lea.l	Zoom_Y_table,a2
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	move.l	a1,bltdpt(a6)
	move.w	d4,bltamod(a6)
	move.w	d5,bltdmod(a6)
	move.l	#$9f00000,bltcon0(a6)
	move.l	#-$1,bltafwm(a6)
	lea.l	bltapt(a6),a4
	lea.l	bltsize(a6),a5
	move.w	Zoom_visible_height,d7
	subq.w	#1,d7
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	move.l	a0,(a4)
	move.w	d6,(a5)
	move.w	(a2)+,d0
	mulu.w	d1,d0
	add.w	d0,a0
	dbra	d7,.Wait4
	move.l	Zoomscreen1_ptr,a0
	move.l	Zoomscreen2_ptr,a1
	move.w	Zoom_X,d0
	andi.w	#$f,d0
	add.w	Zoom_visible_width,d0
	subq.w	#1,d0
	moveq.l	#15,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#3,d0
	add.w	d0,a1
	eori.w	#$f,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.w	Zoom_visible_height,d5
	lsl.w	#6,d5
	addq.w	#1,d5
	moveq.l	#0,d6
	tst.b	Zoom_mirror_X
	beq.s	.Skip9
	move.w	Zoom_source_X_offset,d6
	andi.w	#$f,d6
	bra.s	.Skip10
.Skip9:
	move.w	Zoom_source_width,d6
	subq.w	#1,d6
	sub.w	Zoom_source_X_offset,d6
	sub.w	Zoom_clip_left,d6
.Skip10:
	move.w	#198,a4
	move.w	#-202,a5
.Wait5:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait5
	clr.w	bltcon1(a6)
	move.w	a4,bltcmod(a6)
	move.w	a4,bltdmod(a6)
	move.w	a4,bltamod(a6)
	move.l	#-$1,bltafwm(a6)
	lea.l	Zoom_X_table,a2
	move.w	Zoom_visible_width,d7
	subq.w	#1,d7
.Loop:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#15,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.l	a0,d0
	eori.w	#$f,d1
.Wait6:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait6
	move.w	d4,bltbdat(a6)
	move.l	d0,bltapt(a6)
	move.l	a1,bltcpt(a6)
	move.l	a1,bltdpt(a6)
	sub.w	d3,d1
	bmi.s	.Skip12
.Loop2:
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	d5,bltsize(a6)
	addq.w	#1,d3
	add.w	d4,d4
	bcc.s	.Skip11
	moveq.l	#1,d4
	moveq.l	#0,d3
	subq.l	#2,a1
.Skip11:
	dbra	d7,.Loop
	bra.w	.Skip15
.Skip12:
	move.w	#2,bltcon1(a6)
	move.w	a5,bltcmod(a6)
	move.w	a5,bltdmod(a6)
	move.w	a5,bltamod(a6)
	bra.w	.Skip13
.Loop3:
	move.w	#0,bltcon1(a6)
	move.w	a4,bltcmod(a6)
	move.w	a4,bltdmod(a6)
	move.w	a4,bltamod(a6)
	bra.s	.Loop2
.Loop4:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#15,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.l	a0,d0
	eori.w	#$f,d1
.Wait7:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait7
	move.w	d4,bltbdat(a6)
	move.l	d0,bltapt(a6)
	move.l	a1,bltcpt(a6)
	move.l	a1,bltdpt(a6)
	sub.w	d3,d1
	bpl.s	.Loop3
.Skip13:
	neg.w	d1
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	d5,bltsize(a6)
	addq.w	#1,d3
	add.w	d4,d4
	bcc.s	.Skip14
	moveq.l	#1,d4
	moveq.l	#0,d3
	subq.l	#2,a1
.Skip14:
	dbra	d7,.Loop4
.Skip15:
	move.l	Zoomscreen2_ptr,a0
	move.l	Work_screen,a1
	move.w	Zoom_X,d0
	move.w	Zoom_Y,d1
	jsr	Get_screen_offset
	add.l	d2,a1
	move.w	Zoom_X,d6
	andi.w	#$f,d6
	add.w	Zoom_visible_width,d6
	addi.w	#15,d6
	lsr.w	#4,d6
	move.w	Zoom_visible_height,d7
	move.w	Zoom_X,d0
	andi.w	#$f,d0
	move.w	#-1,d1
	lsr.w	d0,d1
	move.w	Zoom_X,d0
	add.w	Zoom_visible_width,d0
	subq.w	#1,d0
	andi.w	#$f,d0
	move.l	#-$8000,d2
	lsr.l	d0,d2
.Wait8:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait8
	move.w	d1,bltafwm(a6)
	move.w	d2,bltalwm(a6)
	lsl.w	#6,d7
	add.w	d6,d7
	move.w	#200,d0
	add.w	d6,d6
	sub.w	d6,d0
	move.w	d0,bltamod(a6)
	move.w	d0,bltbmod(a6)
	move.w	d0,bltdmod(a6)
	clr.w	bltcon1(a6)
	move.w	Zoom_colour,d0
	move.w	#3328,d1
	moveq.l	#4,d5
.Loop5:
	ror.b	#1,d0
	bcc.s	.Skip16
	move.b	#-4,d1
	bra.s	.Wait9
.Skip16:
	move.b	#12,d1
.Wait9:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait9
	move.w	d1,bltcon0(a6)
	move.l	a0,bltapt(a6)
	move.l	a1,bltbpt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	lea.l	40(a1),a1
	dbra	d5,.Loop5
.Exit:
	rts
	dc.b	0,0


	SECTION	Fast_BSS,bss
Zoom_mirror_X:
	ds.b	1
Zoom_mirror_Y:
	ds.b	1
Zoom_colour:
	ds.w	1
Zoom_X:
	ds.w	1
Zoom_Y:
	ds.w	1
Zoom_source_width:
	ds.w	1
Zoom_source_height:
	ds.w	1
Zoom_target_height:
	ds.w	1
Zoom_target_width:
	ds.w	1
Zoom_visible_height:
	ds.w	1
Zoom_visible_width:
	ds.w	1
Zoom_clip_top:
	ds.w	1
Zoom_source_Y_offset:
	ds.w	1
Zoom_clip_top2:
	ds.w	1
Zoom_source_X_offset:
	ds.w	1
Zoom_clip_bottom:
	ds.b	2
Zoom_clip_left:
	ds.w	1
Zoom_gfx_ptr:
	ds.l	1
Zoom_X_table:
	ds.w	2
	ds.b	636
Zoom_Y_table:
	ds.w	1
	ds.b	398
Zoomscreen1_ptr:
	ds.l	1
Zoomscreen2_ptr:
	ds.l	1
