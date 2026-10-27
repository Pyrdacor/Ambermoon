; Recolour_block of the Amiga version (KERNEL/GRAPHICS.S, plain CPU code) :
; recolours Amiga graphics in memory.

;*****************************************************************************
; [ Recolour a block of graphics ]
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (5 planes) (.l)
;        a1 - Pointer to recolouring table (.l)
; All registers are restored
;*****************************************************************************
Recolour_block:
	movem.l	d0/d5-d7/a0-a5,-(sp)
	tst.w	d6
	beq.w	.Exit
	tst.w	d7
	beq.w	.Exit
	subq.w	#1,d7
	move.l	a1,a5
	move.w	d6,d0
	add.w	d0,d0
	lea.l	0(a0,d0.w),a1
	lea.l	0(a1,d0.w),a2
	lea.l	0(a2,d0.w),a3
	lea.l	0(a3,d0.w),a4
	mulu.w	#4,d0
	btst.l	#0,d6
	bne.w	.Loop3
.Loop:
	move.w	d6,d5
.Loop2:
	jsr	Recolour_32_pixels
	subq.w	#2,d5
	bne.s	.Loop2
	add.w	d0,a0
	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a3
	add.w	d0,a4
	dbra	d7,.Loop
	bra.w	.Exit
.Loop3:
	move.w	d6,d5
	jsr	Recolour_16_pixels
	subq.w	#1,d5
	beq.s	.Skip
.Loop4:
	jsr	Recolour_32_pixels
	subq.w	#2,d5
	bne.s	.Loop4
.Skip:
	add.w	d0,a0
	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a3
	add.w	d0,a4
	dbra	d7,.Loop3
.Exit:
	movem.l	(sp)+,d0/d5-d7/a0-a5
	rts

;*****************************************************************************
; [ Recolour 16 pixels ]
;   IN : a0-a4 - Pointers to planes (.l)
;        a5 - Pointer to recolouring table (.l)
; All registers are restored
;*****************************************************************************
Recolour_16_pixels:
	movem.l	d0-d7,-(sp)
	move.w	(a0),d0
	move.w	(a1),d1
	move.w	(a2),d2
	move.w	(a3),d3
	move.w	(a4),d4
	moveq.l	#0,d6
	moveq.l	#7,d7
.Loop:
	moveq.l	#0,d5
	add.b	d6,d6
	addx.w	d4,d4
	addx.w	d5,d5
	add.b	d6,d6
	addx.w	d3,d3
	addx.w	d5,d5
	add.b	d6,d6
	addx.w	d2,d2
	addx.w	d5,d5
	add.b	d6,d6
	addx.w	d1,d1
	addx.w	d5,d5
	add.b	d6,d6
	addx.w	d0,d0
	addx.w	d5,d5
	move.b	0(a5,d5.w),d5
	lsl.b	#3,d5
	moveq.l	#0,d6
	add.b	d5,d5
	addx.w	d4,d4
	addx.w	d6,d6
	add.b	d5,d5
	addx.w	d3,d3
	addx.w	d6,d6
	add.b	d5,d5
	addx.w	d2,d2
	addx.w	d6,d6
	add.b	d5,d5
	addx.w	d1,d1
	addx.w	d6,d6
	add.b	d5,d5
	addx.w	d0,d0
	addx.w	d6,d6
	move.b	0(a5,d6.w),d6
	lsl.b	#3,d6
	dbra	d7,.Loop
	add.b	d6,d6
	addx.w	d4,d4
	add.b	d6,d6
	addx.w	d3,d3
	add.b	d6,d6
	addx.w	d2,d2
	add.b	d6,d6
	addx.w	d1,d1
	add.b	d6,d6
	addx.w	d0,d0
	move.w	d0,(a0)+
	move.w	d1,(a1)+
	move.w	d2,(a2)+
	move.w	d3,(a3)+
	move.w	d4,(a4)+
	movem.l	(sp)+,d0-d7
	rts

;*****************************************************************************
; [ Recolour 32 pixels ]
;   IN : a0-a4 - Pointers to planes (.l)
;        a5 - Pointer to recolouring table (.l)
; All registers are restored
;*****************************************************************************
Recolour_32_pixels:
	movem.l	d0-d7,-(sp)
	move.l	(a0),d0
	move.l	(a1),d1
	move.l	(a2),d2
	move.l	(a3),d3
	move.l	(a4),d4
	moveq.l	#0,d6
	moveq.l	#15,d7
.Loop:
	moveq.l	#0,d5
	add.b	d6,d6
	addx.l	d4,d4
	addx.w	d5,d5
	add.b	d6,d6
	addx.l	d3,d3
	addx.w	d5,d5
	add.b	d6,d6
	addx.l	d2,d2
	addx.w	d5,d5
	add.b	d6,d6
	addx.l	d1,d1
	addx.w	d5,d5
	add.b	d6,d6
	addx.l	d0,d0
	addx.w	d5,d5
	move.b	0(a5,d5.w),d5
	lsl.b	#3,d5
	moveq.l	#0,d6
	add.b	d5,d5
	addx.l	d4,d4
	addx.w	d6,d6
	add.b	d5,d5
	addx.l	d3,d3
	addx.w	d6,d6
	add.b	d5,d5
	addx.l	d2,d2
	addx.w	d6,d6
	add.b	d5,d5
	addx.l	d1,d1
	addx.w	d6,d6
	add.b	d5,d5
	addx.l	d0,d0
	addx.w	d6,d6
	move.b	0(a5,d6.w),d6
	lsl.b	#3,d6
	dbra	d7,.Loop
	add.b	d6,d6
	addx.l	d4,d4
	add.b	d6,d6
	addx.l	d3,d3
	add.b	d6,d6
	addx.l	d2,d2
	add.b	d6,d6
	addx.l	d1,d1
	add.b	d6,d6
	addx.l	d0,d0
	move.l	d0,(a0)+
	move.l	d1,(a1)+
	move.l	d2,(a2)+
	move.l	d3,(a3)+
	move.l	d4,(a4)+
	movem.l	(sp)+,d0-d7
	rts
