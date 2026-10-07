; 3D renderer : walls, objects, floor & ceiling (CPU)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Insert the horizon into the 3D view (CPU version) ]
;   IN : a0 - Pointer to horizon graphics (.l)
;        a1 - Pointer to MOVEP screen position (.l)
;*****************************************************************************
CPU_insert_horizon:
	movem.l	d0-d7/a0-a3,-(sp)
	moveq.l	#19,d7
.Loop:
	movem.l	(a0)+,d0-d6/a2/a3
	movem.l	d0-d6/a2/a3,(a1)
	movem.l	(a0)+,d0-d6/a2/a3
	movem.l	d0-d6/a2/a3,36(a1)
	lea.l	72(a0),a0
	lea.l	72(a1),a1
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Initialize the blitter usage (CPU version: nothing to do) ]
;*****************************************************************************
CPU_init_blitter:
	rts

;*****************************************************************************
; [ Draw a distorted wall polygon (CPU version) ]
;   IN : a0 - Pointer to wall graphics (.l)
;*****************************************************************************
CPU_put_dpoly:
	move.w	#128,Wall_texture_width
	move.l	a0,Currently_rendered_wall_data
	lea.l	dpoly_koos3d,a0
	bsr.w	CPU_clip_wall
	tst.w	d0
	bmi.w	.Exit
	bsr.w	CPU_project_wall
	bsr.w	CPU_wall_edges
	tst.w	d0
	bmi.w	.Exit
	moveq.l	#0,d0
	move.w	Wall_texture_width,d0
	asl.l	#7,d0
	moveq.l	#0,d6
	movem.w	Wall_Z_values,d4/d5
	tst.w	d4
	bpl.s	.Skip
	neg.w	d4
	move.w	d5,d3
	add.w	d4,d3
	move.w	Wall_texture_width,d6
	muls.w	d4,d6
	asl.l	#7,d6
	divs.w	d3,d6
	ext.l	d6
	sub.w	d6,d0
	moveq.l	#9,d7
	asl.l	d7,d6
	addi.l	#$8000,d6
	move.l	d6,d5
	bra.w	.Skip3
.Skip:
	tst.w	d5
	bpl.s	.Skip2
	neg.w	d5
	move.w	d5,d3
	add.w	d4,d3
	move.w	Wall_texture_width,d6
	muls.w	d5,d6
	asl.l	#7,d6
	divs.w	d3,d6
	ext.l	d6
	sub.w	d6,d0
.Skip2:
	move.l	#$8000,d5
.Skip3:
	move.w	Wall_right_X,d7
	sub.w	Wall_left_X,d7
	addq.w	#1,d7
	divu.w	d7,d0
	subq.w	#1,d7
	move.w	d0,d6
	moveq.l	#9,d2
	move.w	cx2,d0
	sub.w	Wall_right_X,d0
	bge.s	.Skip4
	add.w	d0,d7
	bmi.w	.Exit
.Skip4:
	move.w	Wall_left_X,d0
	sub.w	cx1,d0
	bge.s	.Skip5
	add.w	d0,d7
	bmi.w	.Exit
	move.w	cx1,Wall_left_X
	neg.w	d0
	muls.w	d6,d0
	asl.l	d2,d0
	add.l	d0,d5
.Skip5:
	ext.l	d6
	asl.l	d2,d6
	tst.w	seethru_flag
	bne.w	.Skip16
	move.l	Currently_rendered_wall_data,a0
	move.l	MOVEP_ptr,a1
	moveq.l	#0,d3
	move.w	Wall_left_X,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.b	d4,d0
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lea.l	Wall_column_table,a3
	tst.l	Wall_clip_flags
	beq.w	.Loop5
.Loop:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	move.l	d0,a5
	eori.w	#7,d1
	sub.w	d3,d1
	bpl.s	.Skip6
	neg.w	d1
	bset.l	#$1f,d1
.Skip6:
	move.l	d1,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	bmi.w	.Skip10
	cmp.w	#319,d7
	ble.s	.Skip7
	move.w	#319,d7
.Skip7:
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	cmp.w	cy2,d1
	bgt.w	.Skip10
	move.w	d1,d7
	sub.w	cy1,d7
	bge.s	.Skip8
	moveq.l	#0,d1
	neg.w	d7
	subq.w	#1,d7
.Loop2:
	add.w	(a2)+,d1
	dbra	d7,.Loop2
	add.l	d1,a5
	move.w	cy1,d1
.Skip8:
	cmp.w	cy1,d2
	blt.w	.Skip10
	cmp.w	cy2,d2
	ble.s	.Skip9
	move.w	cy2,d2
.Skip9:
	sub.w	d1,d2
	mulu.w	#72,d1
	add.l	a1,d1
	move.l	d1,a4
	move.l	d0,d1
	move.w	d2,d0
	move.l	d4,d2
	not.l	d2
	move.w	d0,d7
	bclr.l	#$1f,d1
	bne.w	.Loop4
.Loop3:
	move.l	(a5),d0
	lsr.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop3
	bra.w	.Skip10
.Loop4:
	move.l	(a5),d0
	lsl.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop4
.Skip10:
	add.l	d6,d5
	subq.w	#1,d3
	ror.l	#1,d4
	bcc.s	.Skip11
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip11:
	swap	d7
	dbra	d7,.Loop
.Exit:
	rts
.Loop5:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	move.l	d0,a5
	eori.w	#7,d1
	sub.w	d3,d1
	bpl.s	.Skip12
	neg.w	d1
	bset.l	#$1f,d1
.Skip12:
	move.l	d1,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	bmi.w	.Skip14
	cmp.w	#319,d7
	ble.s	.Skip13
	move.w	#319,d7
.Skip13:
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	sub.w	d1,d2
	mulu.w	#72,d1
	add.l	a1,d1
	move.l	d1,a4
	move.l	d0,d1
	move.w	d2,d0
	move.l	d4,d2
	not.l	d2
	move.w	d0,d7
	bclr.l	#$1f,d1
	bne.w	.Loop7
.Loop6:
	move.l	(a5),d0
	lsr.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop6
	bra.w	.Skip14
.Loop7:
	move.l	(a5),d0
	lsl.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop7
.Skip14:
	add.l	d6,d5
	subq.w	#1,d3
	ror.l	#1,d4
	bcc.s	.Skip15
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip15:
	swap	d7
	dbra	d7,.Loop5
	rts
.Skip16:
	move.l	Currently_rendered_wall_data,a0
	move.l	MOVEP_ptr,a1
	moveq.l	#0,d3
	move.w	Wall_left_X,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.b	d4,d0
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lea.l	Wall_column_table,a3
.Loop8:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	move.l	d0,a5
	eori.w	#7,d1
	move.w	d1,d4
	lsl.w	#2,d4
	lea.l	CPU_zoom_masks,a4
	move.l	0(a4,d4.w),d4
	sub.w	d3,d1
	bpl.s	.Skip17
	neg.w	d1
	bset.l	#$1f,d1
.Skip17:
	move.l	d1,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	cmp.w	#319,d7
	ble.s	.Skip18
	move.w	#319,d7
.Skip18:
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	cmp.w	cy2,d1
	bgt.w	.Skip23
	move.w	d1,d7
	sub.w	cy1,d7
	bge.s	.Skip19
	moveq.l	#0,d1
	neg.w	d7
	subq.w	#1,d7
.Loop9:
	add.w	(a2)+,d1
	dbra	d7,.Loop9
	add.l	d1,a5
	move.w	cy1,d1
.Skip19:
	cmp.w	cy1,d2
	blt.w	.Skip23
	cmp.w	cy2,d2
	ble.s	.Skip20
	move.w	cy2,d2
.Skip20:
	sub.w	d1,d2
	mulu.w	#72,d1
	add.l	a1,d1
	move.l	d1,a4
	move.l	d0,d1
	move.w	d2,d0
	move.w	d3,d2
	lsl.w	#2,d2
	lea.l	CPU_zoom_masks,a6
	move.l	0(a6,d2.w),d2
	not.l	d2
	move.w	d0,d7
	bclr.l	#$1f,d1
	bne.w	.Loop11
.Loop10:
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip21
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip21:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop10
	bra.w	.Skip23
.Loop11:
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip22
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip22:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop11
.Skip23:
	add.l	d6,d5
	subq.w	#1,d3
	bpl.s	.Skip24
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip24:
	swap	d7
	dbra	d7,.Loop8
	rts

CPU_zoom_masks:
	dc.l	$1010101,$2020202,$4040404,$8080808
	dc.l	$10101010,$20202020,$40404040,$80808080

;*****************************************************************************
; [ Project the 3D coordinates of a wall to the screen (CPU version) ]
;   IN : a0 - Pointer to 3D wall coordinates (.l)
;*****************************************************************************
CPU_project_wall:
	lea.l	Projected_wall,a1
	move.w	scrx,d4
	move.w	scry,d5
	move.w	8(a0),d0
	addi.w	#256,d0
	move.w	(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	add.w	d4,d2
	move.w	d2,(a1)+
	move.w	4(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy2,d2
	sgt	Wall_clip_flags
	move.w	6(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy1,d2
	slt	Wall_clip_flag2
	move.w	10(a0),d0
	addi.w	#256,d0
	move.w	2(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	add.w	d4,d2
	move.w	d2,(a1)+
	move.w	4(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy2,d2
	sgt	Wall_clip_flag3
	move.w	6(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy1,d2
	slt	Wall_clip_flag4
	rts

;*****************************************************************************
; [ Clip a wall against the front plane (CPU version) ]
;   IN : a0 - Pointer to 3D wall coordinates (.l)
;  OUT : d0 - 0 = visible, -1 = invisible (.w)
;*****************************************************************************
CPU_clip_wall:
	move.l	8(a0),Wall_Z_values
	move.w	8(a0),d5
	bmi.w	.Skip
	move.w	10(a0),d6
	bpl.w	.Exit
	clr.w	10(a0)
	sub.w	d6,d5
	move.w	2(a0),d0
	sub.w	(a0),d0
	muls.w	8(a0),d0
	divs.w	d5,d0
	add.w	(a0),d0
	move.w	d0,2(a0)
	bra.w	.Exit
.Skip:
	move.w	10(a0),d6
	bmi.w	.Exit2
	clr.w	8(a0)
	sub.w	d5,d6
	move.w	(a0),d0
	sub.w	2(a0),d0
	muls.w	10(a0),d0
	divs.w	d6,d0
	add.w	2(a0),d0
	move.w	d0,(a0)
.Exit:
	moveq.l	#0,d0
	rts
.Exit2:
	moveq.l	#-1,d0
	rts

;*****************************************************************************
; [ Calculate the top & bottom edges of a projected wall (CPU version) ]
;  OUT : d0 - 0 = visible, -1 = invisible (.w)
;*****************************************************************************
CPU_wall_edges:
	movem.w	Projected_wall,d0-d5
	cmp.w	d0,d3
	bge.s	.Skip
	exg	d0,d3
	exg	d1,d4
	exg	d2,d5
.Skip:
	move.w	d0,Wall_left_X
	move.w	d3,Wall_right_X
	lea.l	Wall_column_table,a0
	sub.w	d0,d3
	addq.w	#1,d3
	move.w	d3,d7
	sub.w	d1,d4
	ext.l	d4
	asl.l	#7,d4
	divs.w	d3,d4
	sub.w	d2,d5
	ext.l	d5
	asl.l	#7,d5
	divs.w	d3,d5
	ext.l	d4
	ext.l	d5
	move.w	d1,d0
	move.w	d2,d1
	move.w	#-$8000,d2
	move.w	#-$8000,d3
	move.w	cx2,d6
	sub.w	Wall_right_X,d6
	bge.s	.Skip2
	add.w	d6,d7
	bmi.w	.Exit2
.Skip2:
	move.w	Wall_left_X,d6
	sub.w	cx1,d6
	bge.s	.Skip3
	add.w	d6,d7
	bmi.w	.Exit2
	neg.w	d6
	move.w	d7,-(sp)
	move.w	d6,-(sp)
	moveq.l	#9,d7
	muls.w	d4,d6
	asl.l	d7,d6
	add.w	d6,d2
	swap	d6
	addx.w	d6,d0
	move.w	(sp)+,d6
	muls.w	d5,d6
	asl.l	d7,d6
	add.w	d6,d3
	swap	d6
	addx.w	d6,d1
	move.w	(sp)+,d7
.Skip3:
	moveq.l	#9,d6
	asl.l	d6,d4
	asl.l	d6,d5
	move.w	d4,a2
	move.w	d5,a3
	swap	d4
	swap	d5
	tst.b	Blitter_or_CPU		; NOTE: This branch is no longer necessary
					; as the whole function is only called
					; for AM2_CPU dependent on the flag. But to
					; keep all in place, I leave it as it is.
	beq.s	.Exit
	jmp	CPU_edge_loop
.Exit:
	jsr	Blit_edge_loop
	rts
.Exit2:
	moveq.l	#-1,d0
	rts

;*****************************************************************************
; [ Draw a zoomed 3D object (CPU version) ]
;   (see [ draw_zoomshape ] for parameters)
;*****************************************************************************
CPU_draw_zoomshape:
	move.w	d0,Zoomshape_X
	move.w	d1,Zoomshape_Y
	move.w	d2,Zoomshape_mask
	move.w	d4,Zoomshape_source_width
	move.w	d5,Zoomshape_source_height
	move.l	a0,Zoomshape_gfx_ptr
	move.w	d7,d0
	move.w	d6,d7
	move.w	d0,Zoomshape_target_width
	move.w	d7,Zoomshape_target_height
	clr.w	Zoomshape_skip_lines
	clr.w	Zoomshape_skip_columns
	move.w	Zoomshape_X,d2
	sub.w	cx1,d2
	bpl.s	.Skip
	add.w	d2,d7
	ble.w	CPU_zoomshape_exit
	move.w	cx1,Zoomshape_X
	neg.w	d2
	mulu.w	Zoomshape_source_width,d2
	divu.w	Zoomshape_target_height,d2
	andi.w	#-$10,d2
	move.w	d2,Zoomshape_skip_lines
.Skip:
	move.w	Zoomshape_Y,d2
	add.w	d0,d2
	subq.w	#1,d2
	sub.w	cy2,d2
	ble.s	.Skip2
	sub.w	d2,d0
	ble.w	CPU_zoomshape_exit
	mulu.w	Zoomshape_source_height,d2
	divu.w	Zoomshape_target_width,d2
	move.w	d2,Zoomshape_skip_columns
.Skip2:
	clr.w	Zoomshape_clip_left
	clr.w	Zoomshape_clip_top
	move.w	Zoomshape_Y,d2
	sub.w	cy1,d2
	bpl.s	.Skip3
	add.w	d2,d0
	ble.w	CPU_zoomshape_exit
	neg.w	d2
	move.w	d2,Zoomshape_clip_top
	clr.w	Zoomshape_Y
.Skip3:
	move.w	Zoomshape_X,d2
	add.w	d7,d2
	subq.w	#1,d2
	sub.w	cx2,d2
	ble.s	.Skip4
	sub.w	d2,d7
	ble.w	CPU_zoomshape_exit
	move.w	d2,Zoomshape_clip_left
.Skip4:
	move.w	d0,Zoomshape_visible_height
	move.w	d7,Zoomshape_visible_width
	move.w	Zoomshape_target_width,d0
	cmp.w	Zoomshape_source_height,d0
	bgt.w	CPU_zoomshape_draw
	move.w	Zoomshape_source_width,d0
	andi.w	#-$7,d0
	lsr.w	#1,d0
	move.w	d0,Zoomshape_line_size
	bsr.w	CPU_zoomshape_tables
	move.l	Zoomshape_gfx_ptr,a0
	move.l	MOVEP_ptr,a1
	lea.l	Zoomshape_X_table,a2
	move.w	Zoomshape_source_width,d5
	andi.w	#-$7,d5
	lsr.w	#1,d5
	mulu.w	Zoomshape_source_Y_offset,d5
	add.w	d5,a0
	moveq.l	#0,d3
	move.w	Zoomshape_X,d0
	add.w	Zoomshape_visible_width,d0
	subq.w	#1,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	move.w	Zoomshape_Y,d1
	mulu.w	#72,d1
	add.w	d1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.w	d4,d0
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	move.w	Zoomshape_visible_height,d5
	moveq.l	#0,d6
	move.w	Zoomshape_source_width,d6
	subq.w	#1,d6
	sub.w	Zoomshape_source_X_offset,d6
	lea.l	Zoomshape_X_table,a2
	move.w	Zoomshape_visible_width,d7
	subq.w	#1,d7
	tst.w	Zoomshape_mask
	bne.w	.Skip7
	subq.w	#1,d5
.Loop:
	move.w	d5,-(sp)
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
	lea.l	Zoomshape_Y_table,a5
	move.l	d0,a3
	move.l	d4,d2
	not.l	d2
	move.l	a1,a4
	sub.w	d3,d1
	bpl.w	.Loop3
	neg.w	d1
.Loop2:
	move.l	(a3),d0
	lsl.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a5)+,a3
	lea.l	72(a4),a4
	dbra	d5,.Loop2
	bra.w	.Skip5
.Loop3:
	move.l	(a3),d0
	lsr.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a5)+,a3
	lea.l	72(a4),a4
	dbra	d5,.Loop3
.Skip5:
	addq.w	#1,d3
	add.l	d4,d4
	bcc.s	.Skip6
	move.l	#16843009,d4
	moveq.l	#0,d3
	subq.l	#4,a1
.Skip6:
	move.w	(sp)+,d5
	dbra	d7,.Loop
	rts
.Skip7:
	subq.w	#1,d5
.Loop4:
	move.w	d5,-(sp)
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
	lea.l	Zoomshape_Y_table,a5
	move.l	d0,a3
	move.l	d4,d2
	not.l	d2
	move.l	a1,a4
	sub.w	d3,d1
	bpl.w	.Loop6
	neg.w	d1
.Loop5:
	move.l	(a3),d0
	lsl.l	d1,d0
	and.l	d4,d0
	beq.s	.Skip8
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip8:
	add.w	(a5)+,a3
	lea.l	72(a4),a4
	dbra	d5,.Loop5
	bra.w	.Skip10
.Loop6:
	move.l	(a3),d0
	lsr.l	d1,d0
	and.l	d4,d0
	beq.s	.Skip9
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip9:
	add.w	(a5)+,a3
	lea.l	72(a4),a4
	dbra	d5,.Loop6
.Skip10:
	addq.w	#1,d3
	add.l	d4,d4
	bcc.s	.Skip11
	move.l	#16843009,d4
	moveq.l	#0,d3
	subq.l	#4,a1
.Skip11:
	move.w	(sp)+,d5
	dbra	d7,.Loop4
	rts

;*****************************************************************************
; [ Draw the zoomed columns of a 3D object (CPU version) ]
;*****************************************************************************
CPU_zoom_columns:
	lea.l	Zoomshape_X_table,a2
	move.w	Zoomshape_visible_width,d7
	subq.w	#1,d7
	subq.w	#1,d5
.Loop:
	move.w	d5,-(sp)
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
	move.l	d0,a3
	move.l	d4,d2
	not.l	d2
	move.l	a1,a4
	sub.w	d3,d1
	bpl.w	.Loop3
	neg.w	d1
.Loop2:
	move.l	(a3),d0
	lsl.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	a5,a3
	lea.l	72(a4),a4
	dbra	d5,.Loop2
	bra.w	.Skip
.Loop3:
	move.l	(a3),d0
	lsr.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	a5,a3
	lea.l	72(a4),a4
	dbra	d5,.Loop3
.Skip:
	addq.w	#1,d3
	add.l	d4,d4
	bcc.s	.Skip2
	move.l	#16843009,d4
	moveq.l	#0,d3
	subq.l	#4,a1
.Skip2:
	move.w	(sp)+,d5
	dbra	d7,.Loop
CPU_zoomshape_exit:
	rts
CPU_zoomshape_draw:
	move.w	#72,Zoomshape_line_size
	bsr.w	CPU_zoomshape_tables
	move.l	Zoomshape_gfx_ptr,a0
	move.l	zoom_screen,a1
	lea.l	Zoomshape_X_table,a2
	move.w	Zoomshape_source_width,d5
	andi.w	#-$10,d5
	lsr.w	#1,d5
	move.w	d5,a5
	mulu.w	Zoomshape_source_Y_offset,d5
	add.w	d5,a0
	moveq.l	#0,d3
	move.w	Zoomshape_X,d0
	andi.w	#7,d0
	add.w	Zoomshape_visible_width,d0
	subq.w	#1,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.w	d4,d0
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	move.w	Zoomshape_source_height,d5
	sub.w	Zoomshape_source_Y_offset,d5
	sub.w	Zoomshape_skip_columns,d5
	moveq.l	#0,d6
	move.w	Zoomshape_source_width,d6
	subq.w	#1,d6
	sub.w	Zoomshape_source_X_offset,d6
	bsr.w	CPU_zoom_columns
	tst.w	Zoomshape_mask
	beq.w	.Skip3
	move.w	Zoomshape_X,d0
	andi.w	#7,d0
	move.w	Zoomshape_visible_width,d4
	addq.w	#7,d4
	add.w	d0,d4
	lsr.w	#3,d4
	move.w	Zoomshape_source_height,d5
	sub.w	Zoomshape_source_Y_offset,d5
	sub.w	Zoomshape_skip_columns,d5
	bsr.w	CPU_make_zoom_mask
	move.l	zoom_screen2,a3
.Skip3:
	move.l	zoom_screen,a0
	lea.l	Zoomshape_Y_table,a2
	move.l	MOVEP_ptr,a1
	move.w	Zoomshape_Y,d0
	mulu.w	#72,d0
	add.l	d0,a1
	move.w	Zoomshape_X,d0
	moveq.l	#7,d5
	and.w	d0,d5
	sub.w	d5,d0
	lsr.w	#1,d0
	add.w	d0,a1
	move.w	Zoomshape_visible_width,d0
	addq.w	#7,d0
	add.w	d5,d0
	lsr.w	#3,d0
	move.w	d0,d6
	lea.l	Floor_masks1,a4
	move.w	d5,d0
	lsl.w	#2,d5
	move.l	0(a4,d5.w),d4
	add.w	Zoomshape_visible_width,d0
	subq.w	#1,d0
	andi.w	#7,d0
	lsl.w	#2,d0
	move.l	32(a4,d0.w),d5
	tst.w	Zoomshape_mask
	bne.w	.Skip6
	subq.w	#2,d6
	bmi.w	.Skip5
	subq.w	#1,d6
	bmi.w	.Skip4
	move.l	d4,d2
	move.l	d5,d3
	not.l	d2
	not.l	d3
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
.Loop4:
	move.l	a0,a3
	move.l	a1,a4
	move.l	(a3)+,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)+
	move.w	d6,d0
.Loop5:
	move.l	(a3)+,(a4)+
	dbra	d0,.Loop5
	move.l	(a3)+,d0
	and.l	d5,d0
	and.l	d3,(a4)
	or.l	d0,(a4)+
	move.w	(a2)+,d0
	add.w	d0,a0
	lea.l	72(a1),a1
	dbra	d7,.Loop4
	rts
.Skip4:
	move.l	d4,d2
	move.l	d5,d3
	not.l	d2
	not.l	d3
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
.Loop6:
	move.l	a0,a3
	move.l	a1,a4
	move.l	(a3)+,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)+
	move.l	(a3)+,d0
	and.l	d5,d0
	and.l	d3,(a4)
	or.l	d0,(a4)+
	move.w	(a2)+,d0
	add.w	d0,a0
	lea.l	72(a1),a1
	dbra	d7,.Loop6
	rts
.Skip5:
	and.l	d5,d4
	move.l	d4,d5
	not.l	d5
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
.Loop7:
	move.l	(a0),d0
	and.l	d4,d0
	and.l	d5,(a1)
	or.l	d0,(a1)
	move.w	(a2)+,d0
	add.w	d0,a0
	lea.l	72(a1),a1
	dbra	d7,.Loop7
	rts
.Skip6:
	subq.w	#2,d6
	bmi.w	.Skip7
	subq.w	#1,d6
	bmi.w	.Skip8
	move.l	d4,d2
	move.l	d5,d3
	not.l	d2
	not.l	d3
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
.Loop8:
	move.l	a0,a4
	move.l	a1,a5
	move.l	a3,a6
	move.l	(a4)+,d0
	move.l	(a6)+,d1
	and.l	d4,d0
	and.l	d4,d1
	not.l	d1
	and.l	d1,(a5)
	or.l	d0,(a5)+
	move.w	d6,-(sp)
.Loop9:
	move.l	(a4)+,d0
	move.l	(a6)+,d1
	not.l	d1
	and.l	d1,(a5)
	or.l	d0,(a5)+
	dbra	d6,.Loop9
	move.l	(a4)+,d0
	move.l	(a6)+,d1
	and.l	d5,d0
	and.l	d5,d1
	not.l	d1
	and.l	d1,(a5)
	or.l	d0,(a5)+
	move.w	(sp)+,d6
	move.w	(a2)+,d0
	add.w	d0,a0
	add.w	d0,a3
	lea.l	72(a1),a1
	dbra	d7,.Loop8
	rts
.Skip7:
	and.l	d4,d5
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
.Loop10:
	move.l	(a0),d0
	move.l	(a3),d1
	and.l	d5,d0
	and.l	d5,d1
	not.l	d1
	and.l	d1,(a1)
	or.l	d0,(a1)
	move.w	(a2)+,d0
	add.w	d0,a0
	add.w	d0,a3
	lea.l	72(a1),a1
	dbra	d7,.Loop10
	rts
.Skip8:
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
.Loop11:
	move.l	(a0),d0
	move.l	(a3),d1
	and.l	d4,d0
	and.l	d4,d1
	not.l	d1
	and.l	d1,(a1)
	or.l	d0,(a1)
	move.l	4(a0),d0
	move.l	4(a3),d1
	and.l	d5,d0
	and.l	d5,d1
	not.l	d1
	and.l	d1,4(a1)
	or.l	d0,4(a1)
	move.w	(a2)+,d0
	add.w	d0,a0
	add.w	d0,a3
	lea.l	72(a1),a1
	dbra	d7,.Loop11
	rts

;*****************************************************************************
; [ Create the mask for the zoom screen (CPU version) ]
;   IN : d4 - Width in bytes / 4 (.w)
;        d5 - Height (.w)
;*****************************************************************************
CPU_make_zoom_mask:
	move.l	zoom_screen,a0
	move.l	zoom_screen2,a1
	subq.w	#1,d4
	subq.w	#1,d5
.Loop:
	move.w	d4,d7
	pea	72(a0)
	pea	72(a1)
.Loop2:
	move.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	dbra	d7,.Loop2
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	dbra	d5,.Loop
	rts

;*****************************************************************************
; [ Calculate the X and Y step tables for a 3D object (CPU version) ]
;*****************************************************************************
CPU_zoomshape_tables:
	move.w	Zoomshape_target_width,d7
	lea.l	Zoomshape_Y_table,a0
	move.w	Zoomshape_source_height,d0
	subq.w	#1,d0
	ext.l	d0
	divs.w	d7,d0
	move.w	d0,d4
	swap	d0
	move.w	d7,d1
	move.w	d1,d2
	addq.w	#1,d0
	moveq.l	#0,d3
	move.w	Zoomshape_clip_top,d6
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
	move.w	d3,Zoomshape_source_Y_offset
	move.w	Zoomshape_line_size,d3
	mulu.w	d3,d4
	move.w	Zoomshape_visible_height,d6
	subq.w	#1,d6
.Loop:
	move.w	d4,d5
	sub.w	d0,d2
	bpl.s	.Skip2
	add.w	d1,d2
	add.w	d3,d5
.Skip2:
	move.w	d5,(a0)+
	dbra	d6,.Loop
	move.w	Zoomshape_target_height,d7
	lea.l	Zoomshape_X_table,a0
	move.w	Zoomshape_source_width,d0
	subq.w	#1,d0
	ext.l	d0
	divs.w	d7,d0
	move.w	d0,d4
	swap	d0
	move.w	d7,d1
	move.w	d1,d2
	addq.w	#1,d0
	moveq.l	#0,d3
	move.w	Zoomshape_clip_left,d6
	beq.s	.Skip3
	move.w	d4,d3
	mulu.w	d6,d3
	move.w	d0,d7
	mulu.w	d6,d7
	divu.w	d2,d7
	add.w	d7,d3
	swap	d7
	sub.w	d7,d2
.Skip3:
	subq.w	#1,d2
	move.w	d3,Zoomshape_source_X_offset
	move.w	Zoomshape_visible_width,d6
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
	rts

Floor_masks1:
	dc.b	$ff,$ff,$ff,$ff,$7f,$7f,$7f,$7f,$3f,$3f,$3f,$3f,$1f,$1f,$1f,$1f
	dc.b	$f,$f,$f,$f,7,7,7,7,3,3,3,3,1,1,1,1

Floor_masks2:
	dc.b	$80,$80,$80,$80,$c0,$c0,$c0,$c0,$e0,$e0,$e0,$e0,$f0,$f0,$f0,$f0
	dc.b	$f8,$f8,$f8,$f8,$fc,$fc,$fc,$fc,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff

;*****************************************************************************
; [ Draw the ceiling of a 3D map ]
;   IN : Floor_source_gfx - Pointer to ceiling graphics
;*****************************************************************************
Draw_ceiling:
	movem.l	d0-d7/a0-a6,-(sp)
	st	Floor_ceiling_flag
	move.w	#170,d0
	sub.w	head_height,d0
	move.w	d0,Floor_Y
	ext.l	d0
	asl.l	#8,d0
	divs.w	#16256,d0
	neg.w	d0
	add.w	scry,d0
	move.w	#0,Floor_Y_step
	move.w	d0,Floor_height
	move.w	d0,cls_top
	move.w	Floor_Y_step,d6
	move.w	Floor_height,d7
	sub.w	d6,d7
	sub.w	scry,d6
	add.w	Floor_Y,d6
	move.w	d6,Floor_lines
	move.w	#1,Floor_direction
	bra.w	Draw_floor_ceiling

;*****************************************************************************
; [ Draw the floor of a 3D map ]
;   IN : Floor_source_gfx - Pointer to floor graphics
;*****************************************************************************
Draw_floor:
	movem.l	d0-d7/a0-a6,-(sp)
	sf	Floor_ceiling_flag
	move.w	head_height,d0
	addi.w	#170,d0
	move.w	d0,Floor_Y
	ext.l	d0
	asl.l	#8,d0
	divs.w	#16256,d0
	add.w	scry,d0
	move.w	d0,Floor_Y_step
	move.w	#143,Floor_height
	move.w	d0,cls_bottom
	move.w	Floor_Y_step,d6
	move.w	Floor_height,d7
	sub.w	d6,d7
	sub.w	scry,d6
	neg.w	d6
	add.w	Floor_Y,d6
	move.w	d6,Floor_lines
	move.w	#-1,Floor_direction
Draw_floor_ceiling:
	lea.l	Floor_table2,a0
	lea.l	Floor_table1,a4
	andi.w	#$3ff,Y_angle
	move.w	Y_angle,d0		; Some value v
	neg.w	d0
	andi.w	#$3ff,d0
	move.w	#256,d1
	add.w	d0,d1
	andi.w	#$3ff,d1		; D0 = 1024 - v (min 0, max 1023)
					; D1 = 256 - v (maps to range 0-1023 even if negative)
	lea.l	Sinus_table,a2		; 101, 201, 302, 402, 503, 603, ...
	move.l	a2,a3
	add.w	d0,d0		; D0 *= 2
	add.w	d1,d1		; D1 *= 2
	add.w	d0,a2
	add.w	d1,a3
	move.w	(a2),d1
	ext.l	d1
	neg.l	d1
	asr.l	#6,d1		; D1 = -word / 64
	move.w	(a3),d2
	ext.l	d2
	neg.l	d2
	asr.l	#6,d2		; D2 = -word / 64
	move.w	#-72,d0		; -72
	move.w	d0,d3
	muls.w	(a2),d3
	neg.l	d3
	asl.l	#2,d3
	swap	d3		; D3 = swap(-(word * -72) / 4)
	muls.w	(a3),d0
	asl.l	#2,d0
	swap	d0		; D0 = swap((word * -72) / 4)
	movem.l	d0-d3,(a4)		; Store D0-D3 in 0x261210
	move.w	#71,d0		; 71
	move.w	d0,d3
	muls.w	(a2),d3
	neg.l	d3
	asl.l	#2,d3
	swap	d3		; D3 = swap(-(word * 71) / 4)
	muls.w	(a3),d0
	asl.l	#2,d0
	swap	d0		; D0 = swap((word * 71) / 4)
	movem.l	d0-d3,16(a4)		; Store D0-D3 in 0x261220
.Loop:
	move.w	Floor_lines,d5
	move.w	Floor_Y,d6
	sub.w	d6,d5
	bne.w	.Skip2
	tst.b	Floor_ceiling_flag
	bne.s	.Skip
	move.w	#144,cls_bottom		; 144 (3D screen width or height?)
	bra.w	.Exit
.Skip:
	move.w	#-1,cls_top
	bra.w	.Exit
.Skip2:
	ext.l	d5
	moveq.l	#1,d4
	movem.l	(a4),d0-d3		; Get first 4 calculated values
.Loop2:
	sub.w	d1,d0
	muls.w	d6,d0
	asl.l	#8,d0
	divsl.l	d5,d0
	asl.l	#8,d0
	neg.l	d0
	swap	d1
	add.l	d1,d0
	add.l	Floor_X,d0
	asr.l	#1,d0
	move.l	d0,(a0)+
	move.w	d3,d0
	sub.w	d2,d0
	muls.w	d6,d0
	asl.l	#8,d0
	divsl.l	d5,d0
	asl.l	#8,d0
	neg.l	d0
	swap	d2
	add.l	d2,d0
	sub.l	Floor_Z,d0
	asr.l	#1,d0
	move.l	d0,(a0)+
	movem.l	16(a4),d0-d3
	dbra	d4,.Loop2
	move.w	Floor_direction,d0
	add.w	d0,Floor_lines
	dbra	d7,.Loop
	move.l	MPB_ptr,a3
	move.l	a3,a4
	add.l	#$8000,a4
	move.l	Floor_source_gfx,a0
	move.l	MOVEP_ptr,a5
	lea.l	Floor_table2,a6
	move.w	Floor_Y_step,d6
	move.w	Floor_height,d7
	sub.w	d6,d7
	move.w	d6,d0
	mulu.w	#72,d0
	add.l	d0,a5
.Loop3:
	move.l	(a6)+,d2
	move.l	(a6)+,d4
	move.l	(a6)+,d3
	move.l	(a6)+,d5
	sub.l	d2,d3
	sub.l	d4,d5
	move.l	#144,d1
	divsl.l	d1,d3
	divsl.l	d1,d5
	move.l	d2,d0
	move.l	d3,a2
	move.w	d4,d0
	asl.w	#8,d0
	move.w	d5,d3
	asl.w	#8,d3
	swap	d0
	swap	d3
	asr.l	#8,d4
	asr.l	#8,d5
	moveq.l	#23,d1
	lea.l	Floor_table3,a1
	moveq.l	#0,d6
.Loop4:
	move.w	d4,d6
	move.b	d0,d6
	move.b	0(a0,d6.l),(a1)+
	add.w	a2,d2
	addx.l	d3,d0
	addx.w	d5,d4
	move.w	d4,d6
	move.b	d0,d6
	move.b	0(a0,d6.l),(a1)+
	add.w	a2,d2
	addx.l	d3,d0
	addx.w	d5,d4
	move.w	d4,d6
	move.b	d0,d6
	move.b	0(a0,d6.l),(a1)+
	add.w	a2,d2
	addx.l	d3,d0
	addx.w	d5,d4
	move.w	d4,d6
	move.b	d0,d6
	move.b	0(a0,d6.l),(a1)+
	add.w	a2,d2
	addx.l	d3,d0
	addx.w	d5,d4
	move.w	d4,d6
	move.b	d0,d6
	move.b	0(a0,d6.l),(a1)+
	add.w	a2,d2
	addx.l	d3,d0
	addx.w	d5,d4
	move.w	d4,d6
	move.b	d0,d6
	move.b	0(a0,d6.l),(a1)+
	add.w	a2,d2
	addx.l	d3,d0
	addx.w	d5,d4
	dbra	d1,.Loop4
	lea.l	Floor_table3,a1
	moveq.l	#5,d6
.Loop5:
	move.l	(a1)+,d0
	move.l	0(a3,d0.w),d1
	swap	d0
	or.l	4(a3,d0.w),d1
	move.l	(a1)+,d0
	or.l	0(a4,d0.w),d1
	swap	d0
	or.l	4(a4,d0.w),d1
	move.l	d1,(a5)+
	move.l	(a1)+,d0
	move.l	0(a3,d0.w),d1
	swap	d0
	or.l	4(a3,d0.w),d1
	move.l	(a1)+,d0
	or.l	0(a4,d0.w),d1
	swap	d0
	or.l	4(a4,d0.w),d1
	move.l	d1,(a5)+
	move.l	(a1)+,d0
	move.l	0(a3,d0.w),d1
	swap	d0
	or.l	4(a3,d0.w),d1
	move.l	(a1)+,d0
	or.l	0(a4,d0.w),d1
	swap	d0
	or.l	4(a4,d0.w),d1
	move.l	d1,(a5)+
	dbra	d6,.Loop5
	dbra	d7,.Loop3
.Exit:
	movem.l	(sp)+,d0-d7/a0-a6
	rts


	SECTION	Longword_BSS,bss
Floor_source_gfx:
	ds.l	1
Floor_table1:
	ds.l	8
Floor_table2:
	ds.l	8
	ds.b	2272
Floor_table3:
	ds.b	8
	ds.l	10
	ds.b	96

	SECTION	Fast_BSS,bss
Zoomshape_X:
	ds.w	1
Zoomshape_Y:
	ds.w	1
Zoomshape_source_width:
	ds.w	1
Zoomshape_source_height:
	ds.w	1
Zoomshape_target_width:
	ds.w	1
Zoomshape_target_height:
	ds.w	1
Zoomshape_visible_height:
	ds.w	1
Zoomshape_visible_width:
	ds.w	1
Zoomshape_clip_top:
	ds.w	1
Zoomshape_source_Y_offset:
	ds.w	1
Zoomshape_clip_left:
	ds.w	1
Zoomshape_source_X_offset:
	ds.w	1
Zoomshape_skip_columns:
	ds.w	1
Zoomshape_skip_lines:
	ds.w	1
Zoomshape_mask:
	ds.w	1
Zoomshape_line_size:
	ds.w	1
Zoomshape_gfx_ptr:
	ds.l	1
Zoomshape_X_table:
	ds.w	2
	ds.b	634
	ds.w	1
Zoomshape_Y_table:
	ds.w	2
	ds.b	396
zoom_screen:
	ds.l	1
zoom_screen2:
	ds.l	1
Floor_ceiling_flag:
	ds.b	2
Floor_X:
	ds.b	4
Floor_Z:
	ds.b	4
Floor_Y:
	ds.w	1
Floor_Y_step:
	ds.w	1
Floor_height:
	ds.w	1
Floor_lines:
	ds.w	1
Floor_direction:
	ds.w	1
cls_top:
	ds.w	1
cls_bottom:
	ds.w	1
dpoly_koos3d:
	ds.b	12
Projected_wall:
	ds.w	6
Wall_Z_values:
	ds.w	2
Wall_column_table:
	ds.w	4
	ds.b	2
	ds.w	2
	ds.b	546
	ds.w	1
	ds.b	14
Wall_left_X:
	ds.w	1
Wall_right_X:
	ds.w	1
Wall_texture_width:
	ds.w	1
	ds.b	2
Currently_rendered_wall_data:
	ds.l	1
Wall_clip_flags:
	ds.b	1
Wall_clip_flag2:
	ds.b	1
Wall_clip_flag3:
	ds.b	1
Wall_clip_flag4:
	ds.b	1
