; Graphics primitives (blocks, lines, boxes, pixels)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Clear a block in one plane of the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d5 - Plane number (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
; All registers are restored
;*****************************************************************************
Clear_1plane_block:
	movem.l	d2/d3/a0/a6,-(sp)
	lea.l	Custom,a6
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	Work_screen,a0
	jsr	Get_screen_offset
	add.l	d2,a0
	move.w	d5,d2
	mulu.w	#40,d2
	add.w	d2,a0
	move.l	a0,bltdpt(a6)
	move.w	#200,d2
	sub.w	d6,d2
	sub.w	d6,d2
	move.w	d2,bltdmod(a6)
	move.l	#-$1,bltafwm(a6)
	move.l	#$1000000,bltcon0(a6)
	move.w	d7,d2
	lsl.w	#6,d2
	add.w	d6,d2
	move.w	d2,bltsize(a6)
	movem.l	(sp)+,d2/d3/a0/a6
	rts

;*****************************************************************************
; [ Copy a block of the shown screen to the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
; All registers are restored
; NOTE :
;   - The block is clipped against the current clip area.
;*****************************************************************************
Duplicate_block:
	movem.l	d0-d7/a0/a1/a6,-(sp)
	lea.l	Custom,a6
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	tst.w	d5
	ble.w	.Exit
	cmp.w	#5,d5
	bgt.w	.Exit
	andi.w	#-$10,d0
	move.l	CA_Sp,a1
	move.l	(a1),a1
	cmp.w	CA_X2(a1),d0
	bgt.w	.Exit
	cmp.w	CA_Y2(a1),d1
	bgt.w	.Exit
	move.w	d6,d2
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	cmp.w	(a1),d2
	bmi.w	.Exit
	move.w	d1,d3
	add.w	d7,d3
	subq.w	#1,d3
	cmp.w	CA_Y1(a1),d3
	bmi.w	.Exit
	cmp.w	CA_Y1(a1),d1
	bpl.s	.Skip
	move.w	CA_Y1(a1),d4
	sub.w	d1,d4
	sub.w	d4,d7
	move.w	CA_Y1(a1),d1
.Skip:
	cmp.w	CA_Y2(a1),d3
	bmi.s	.Skip2
	sub.w	CA_Y2(a1),d3
	sub.w	d3,d7
.Skip2:
	move.w	d6,d3
	cmp.w	(a1),d0
	bpl.s	.Skip3
	move.w	(a1),d4
	sub.w	d0,d4
	lsr.w	#4,d4
	sub.w	d4,d6
	move.w	(a1),d0
.Skip3:
	cmp.w	CA_X2(a1),d2
	ble.s	.Skip4
	sub.w	CA_X2(a1),d2
	lsr.w	#4,d2
	sub.w	d2,d6
.Skip4:
	tst.w	d6
	bne.w	.Skip5
	moveq.l	#1,d6
.Skip5:
	tst.w	d7
	ble.w	.Exit
	move.l	d3,-(sp)
	move.l	Off_screen,a0
	move.l	On_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a0
	add.l	d2,a1
	move.l	(sp)+,d3
	move.l	#-$1,bltafwm(a6)
	move.l	#$9f00000,bltcon0(a6)
	lsl.w	#6,d7
	add.w	d6,d7
	move.w	#200,d2
	add.w	d6,d6
	sub.w	d6,d2
	move.w	d2,bltamod(a6)
	add.w	d3,d3
	move.w	d3,d2
	mulu.w	d5,d2
	sub.w	d6,d2
	move.w	d2,bltdmod(a6)
	subq.w	#1,d5
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	a1,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d7,bltsize(a6)
	add.w	d3,a0
	lea.l	40(a1),a1
	dbra	d5,.Wait2
.Exit:
	movem.l	(sp)+,d0-d7/a0/a1/a6
	rts

;*****************************************************************************
; [ Plot a pixel ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Colour (.w)
; All registers are restored
; NOTE :
;   - The pixel is clipped against the current clip area.
;*****************************************************************************
Plot_pixel:
	movem.l	d0-d3/a0/a1,-(sp)
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	move.l	CA_Sp,a0
	move.l	(a0),a0
	cmp.w	(a0),d0
	bmi.w	.Exit
	cmp.w	CA_Y1(a0),d1
	bmi.w	.Exit
	cmp.w	CA_X2(a0),d0
	bgt.w	.Exit
	cmp.w	CA_Y2(a0),d1
	bgt.w	.Exit
	move.l	Work_screen,a0
	jsr	Get_screen_offset
	add.l	d2,a0
	btst.l	#3,d3
	beq.s	.Skip
	addq.l	#1,a0
.Skip:
	andi.w	#7,d3
	eori.w	#7,d3
	lea.l	Plot_pixel_table,a1
	move.w	d4,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	0(a1,d2.w),a1
	jsr	(a1)
.Exit:
	movem.l	(sp)+,d0-d3/a0/a1
	rts

; Plot routines for the 32 colours
Plot_pixel_table:
	dc.l	Plot_colour_0,Plot_colour_1,Plot_colour_2,Plot_colour_3
	dc.l	Plot_colour_4,Plot_colour_5,Plot_colour_6,Plot_colour_7
	dc.l	Plot_colour_8,Plot_colour_9,Plot_colour_10,Plot_colour_11
	dc.l	Plot_colour_12,Plot_colour_13,Plot_colour_14,Plot_colour_15
	dc.l	Plot_colour_16,Plot_colour_17,Plot_colour_18,Plot_colour_19
	dc.l	Plot_colour_20,Plot_colour_21,Plot_colour_22,Plot_colour_23
	dc.l	Plot_colour_24,Plot_colour_25,Plot_colour_26,Plot_colour_27
	dc.l	Plot_colour_28,Plot_colour_29,Plot_colour_30,Plot_colour_31

;*****************************************************************************
; [ Set a pixel to colour 0 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_0:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 1 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_1:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 2 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_2:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 3 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_3:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 4 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_4:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 5 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_5:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 6 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_6:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 7 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_7:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 8 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_8:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 9 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_9:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 10 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_10:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 11 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_11:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 12 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_12:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 13 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_13:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 14 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_14:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 15 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_15:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bclr.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 16 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_16:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 17 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_17:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 18 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_18:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 19 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_19:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 20 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_20:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 21 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_21:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 22 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_22:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 23 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_23:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bclr.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 24 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_24:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 25 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_25:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 26 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_26:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 27 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_27:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bclr.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 28 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_28:
	bclr.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 29 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_29:
	bset.b	d3,(a0)
	bclr.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 30 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_30:
	bclr.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Set a pixel to colour 31 ]
;   IN : d3 - Bit number (.w)
;        a0 - Pointer to byte in plane 0 (.l)
;*****************************************************************************
Plot_colour_31:
	bset.b	d3,(a0)
	bset.b	d3,40(a0)
	bset.b	d3,80(a0)
	bset.b	d3,120(a0)
	bset.b	d3,160(a0)
	rts

;*****************************************************************************
; [ Get the colour of a pixel ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : d4 - Colour (.w)
; All registers are restored
;*****************************************************************************
Get_pixel:
	movem.l	d0-d3/a0,-(sp)
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	moveq.l	#0,d4
	move.l	CA_Sp,a0
	move.l	(a0),a0
	cmp.w	(a0),d0
	bmi.w	.Exit
	cmp.w	CA_Y1(a0),d1
	bmi.w	.Exit
	cmp.w	CA_X2(a0),d0
	bgt.w	.Exit
	cmp.w	CA_Y2(a0),d1
	bgt.w	.Exit
	move.l	Work_screen,a0
	jsr	Get_screen_offset
	add.l	d2,a0
	btst.l	#3,d3
	beq.s	.Skip
	addq.l	#1,a0
.Skip:
	andi.w	#7,d3
	eori.w	#7,d3
	btst.b	d3,(a0)
	beq.s	.Skip2
	moveq.l	#1,d4
.Skip2:
	btst.b	d3,40(a0)
	beq.s	.Skip3
	addq.w	#2,d4
.Skip3:
	btst.b	d3,80(a0)
	beq.s	.Skip4
	addq.w	#4,d4
.Skip4:
	btst.b	d3,120(a0)
	beq.s	.Skip5
	addq.w	#8,d4
.Skip5:
	btst.b	d3,160(a0)
	beq.s	.Exit
	bset.l	#4,d4
.Exit:
	movem.l	(sp)+,d0-d3/a0
	rts

;*****************************************************************************
; [ Copy MOVEP graphics to the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to MOVEP graphics (.l)
; All registers are restored
; NOTE :
;   - MOVEP graphics store 4 planes interleaved per byte.
; NOTE (disassembly) :
;   D0: X
;   D1: Y
;   D6: Width (in 16 bit chunks)
;   D7: Height
;*****************************************************************************
Show_MOVEP_screen:
	movem.l	d0-d3/d6/d7/a0-a4,-(sp)
.Wait:
	btst.b	#6,Custom+dmaconr		; Wait for blitter
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	jsr	Get_screen_offset		; D2 = byte index to pixel at x,y
	move.l	Work_screen,a1
	add.l	d2,a1		; Add position offset
	lea.l	40(a1),a2		; +40 bytes
	lea.l	40(a2),a3		; +40 bytes
	lea.l	40(a3),a4		; +40 bytes
	move.w	d6,d2
	add.w	d2,d2
	neg.w	d2
	addi.w	#200,d2		; D2 = 200 - 2 * D6
					; So D2 is the byte offset
					; inside one screen line.
	subq.w	#1,d6
	subq.w	#1,d7
.Loop:
	move.w	d6,d3		; Move wall pixels to screen buffer
.Loop2:
	move.b	(a0)+,(a1)+		; Move bytes to target,
					; target + 40, target + 80
					; and then target + 120.
	move.b	(a0)+,(a2)+		; 8 bytes = 8*8 bits = 64 bits
					; 4bits per pixel -> 16 pixels
	move.b	(a0)+,(a3)+		; Objects and walls store
					; bitplanes for every 8
					; pixels. So they are copied
					; this way here.
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a3)+
	move.b	(a0)+,(a4)+
	dbra	d3,.Loop2		; For each 16 pixel chunk in width
	add.w	d2,a1
	add.w	d2,a2
	add.w	d2,a3
	add.w	d2,a4
	dbra	d7,.Loop		; For each row in height
	movem.l	(sp)+,d0-d3/d6/d7/a0-a4
	rts

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

;*****************************************************************************
; [ Push a clip area on the stack ]
;   IN : a0 - Pointer to CA (.l)
; All registers are restored
;*****************************************************************************
Push_CA:
	move.l	a1,-(sp)
	move.l	CA_Sp,a1
	addq.l	#4,a1
	cmp.l	#CA_stack_end,a1
	beq.s	.Exit
	move.l	a0,(a1)
	move.l	a1,CA_Sp
.Exit:
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Pop a clip area from the stack ]
; All registers are restored
;*****************************************************************************
Pop_CA:
	move.l	a0,-(sp)
	move.l	CA_Sp,a0
	cmp.l	#CA_Sp+4,a0
	beq.s	.Exit
	subq.l	#4,a0
	move.l	a0,CA_Sp
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Reset the clip area stack ]
; All registers are restored
;*****************************************************************************
Reset_CA_stack:
	move.l	a0,-(sp)
	lea.l	CA_Sp+4,a0
	move.l	a0,CA_Sp
	move.l	#Default_CA,(a0)
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Get a block from the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to buffer (.l)
; All registers are restored
;*****************************************************************************
Get_block:
	movem.l	d0-d7/a0/a1/a6,-(sp)
	lea.l	Custom,a6
	tst.w	d5
	ble.w	.Exit
	cmp.w	#5,d5
	bgt.w	.Exit
	andi.w	#-$10,d0
	move.l	CA_Sp,a1
	move.l	(a1),a1
	cmp.w	CA_X2(a1),d0
	bgt.w	.Exit
	cmp.w	CA_Y2(a1),d1
	bgt.w	.Exit
	move.w	d6,d2
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	cmp.w	(a1),d2
	bmi.w	.Exit
	move.w	d1,d3
	add.w	d7,d3
	subq.w	#1,d3
	cmp.w	CA_Y1(a1),d3
	bmi.w	.Exit
	cmp.w	CA_Y1(a1),d1
	bpl.s	.Skip
	move.w	CA_Y1(a1),d4
	sub.w	d1,d4
	sub.w	d4,d7
	add.w	d4,d4
	mulu.w	d5,d4
	mulu.w	d6,d4
	add.l	d4,a0
	move.w	CA_Y1(a1),d1
.Skip:
	cmp.w	CA_Y2(a1),d3
	bmi.s	.Skip2
	sub.w	CA_Y2(a1),d3
	sub.w	d3,d7
.Skip2:
	move.w	d6,d3
	cmp.w	(a1),d0
	bpl.s	.Skip3
	move.w	(a1),d4
	sub.w	d0,d4
	lsr.w	#4,d4
	sub.w	d4,d6
	add.w	d4,d4
	add.w	d4,a0
	move.w	(a1),d0
.Skip3:
	cmp.w	CA_X2(a1),d2
	ble.s	.Skip4
	sub.w	CA_X2(a1),d2
	lsr.w	#4,d2
	sub.w	d2,d6
.Skip4:
	tst.w	d6
	bne.w	.Skip5
	moveq.l	#1,d6
.Skip5:
	tst.w	d7
	ble.w	.Exit
	move.l	d3,-(sp)
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	move.l	(sp)+,d3
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.l	#$9f00000,bltcon0(a6)
	lsl.w	#6,d7
	add.w	d6,d7
	move.w	#200,d2
	add.w	d6,d6
	sub.w	d6,d2
	move.w	d2,bltamod(a6)
	add.w	d3,d3
	move.w	d3,d2
	mulu.w	d5,d2
	sub.w	d6,d2
	move.w	d2,bltdmod(a6)
	subq.w	#1,d5
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	a1,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d7,bltsize(a6)
	add.w	d3,a0
	lea.l	40(a1),a1
	dbra	d5,.Wait2
.Exit:
	movem.l	(sp)+,d0-d7/a0/a1/a6
	rts

;*****************************************************************************
; [ Draw a filled box ]
;   IN : d0 - Left X (.w)
;        d1 - Top Y (.w)
;        d2 - Right X (.w)
;        d3 - Bottom Y (.w)
;        d4 - Colour (.w)
; All registers are restored
; NOTE :
;   - The box is clipped against the current clip area.
;*****************************************************************************
Draw_box:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	-14(sp),sp
	move.l	sp,a5
	lea.l	Custom,a6
	cmp.w	d0,d2
	bpl.s	.Skip
	exg	d0,d2
.Skip:
	cmp.w	d1,d3
	bpl.s	.Skip2
	exg	d1,d3
.Skip2:
	move.l	CA_Sp,a0
	move.l	(a0),a0
	cmp.w	CA_X2(a0),d0
	bgt.w	.Exit
	cmp.w	CA_Y2(a0),d1
	bgt.w	.Exit
	cmp.w	(a0),d2
	bmi.w	.Exit
	cmp.w	CA_Y1(a0),d3
	bmi.w	.Exit
	cmp.w	(a0),d0
	bpl.s	.Skip3
	move.w	(a0),d0
.Skip3:
	cmp.w	CA_Y1(a0),d1
	bpl.s	.Skip4
	move.w	CA_Y1(a0),d1
.Skip4:
	cmp.w	CA_X2(a0),d2
	ble.s	.Skip5
	move.w	CA_X2(a0),d2
.Skip5:
	cmp.w	CA_Y2(a0),d3
	bmi.s	.Skip6
	move.w	CA_Y2(a0),d3
.Skip6:
	move.w	d0,0(a5)
	move.w	d1,2(a5)
	move.w	d2,4(a5)
	move.w	d3,6(a5)
	move.w	d4,8(a5)
	sub.w	d0,d2
	addq.w	#1,d2
	move.w	d2,10(a5)
	sub.w	d1,d3
	addq.w	#1,d3
	move.w	d3,12(a5)
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.w	0(a5),d0
	lsr.w	#4,d0
	move.w	4(a5),d1
	lsr.w	#4,d1
	cmp.w	d0,d1
	bne.w	.Skip7
	move.l	Work_screen,a0
	move.w	0(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	lea.l	Left_edge_masks,a1
	add.w	d3,d3
	move.w	0(a1,d3.w),d0
	lea.l	Right_edge_masks,a1
	move.w	4(a5),d3
	andi.w	#$f,d3
	add.w	d3,d3
	and.w	0(a1,d3.w),d0
	move.w	d0,bltadat(a6)
	jsr	Draw_box_part
	bra.w	.Exit
.Skip7:
	move.w	4(a5),d0
	andi.w	#$f,d0
	sub.w	d0,10(a5)
	move.w	0(a5),d0
	andi.w	#$f,d0
	beq.w	.Skip8
	subi.w	#16,d0
	add.w	d0,10(a5)
	move.l	Work_screen,a0
	move.w	0(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	lea.l	Left_edge_masks,a1
	add.w	d3,d3
	move.w	0(a1,d3.w),bltadat(a6)
	jsr	Draw_box_part
	move.w	0(a5),d0
	andi.w	#-$10,d0
	addi.w	#16,d0
	move.w	d0,0(a5)
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
.Skip8:
	move.l	Work_screen,a0
	move.w	0(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	move.w	4(a5),d0
	andi.w	#$f,d0
	cmp.w	#15,d0
	bne.s	.Skip9
	addi.w	#16,10(a5)
.Skip9:
	move.w	12(a5),d6
	lsl.w	#6,d6
	move.w	10(a5),d5
	lsr.w	#4,d5
	beq.w	.Skip10
	add.w	d5,d6
	move.w	8(a5),d5
	move.w	10(a5),d4
	andi.w	#-$10,d4
	lsr.w	#3,d4
	subi.w	#200,d4
	neg.w	d4
	move.w	d4,bltdmod(a6)
	move.w	#0,bltcon1(a6)
	move.w	#256,d4
	moveq.l	#4,d7
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	ror.b	#1,d5
	scs	d4
	move.w	d4,bltcon0(a6)
	move.l	a0,bltdpt(a6)
	move.w	d6,bltsize(a6)
	lea.l	40(a0),a0
	dbra	d7,.Wait3
.Skip10:
	move.w	4(a5),d0
	andi.w	#$f,d0
	cmp.w	#15,d0
	beq.w	.Exit
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	move.l	Work_screen,a0
	move.w	4(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	lea.l	Right_edge_masks,a1
	add.w	d3,d3
	move.w	0(a1,d3.w),bltadat(a6)
	jsr	Draw_box_part
.Exit:
	lea.l	14(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw one 16 pixel wide part of a box (all planes) ]
;   IN : a0 - Screen pointer (.l)
;        a5 - Pointer to Box_LDS (.l)
;*****************************************************************************
Draw_box_part:
	move.w	12(a5),d6
	lsl.w	#6,d6
	addq.w	#1,d6
	move.w	8(a5),d5
	move.w	#198,98(a6)
	move.w	#198,102(a6)
	move.w	#0,66(a6)
	moveq.l	#4,d7
.Wait:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait
	ror.b	#1,d5
	bcc.s	.Skip
	move.w	#1532,64(a6)
	bra.s	.Skip2
.Skip:
	move.w	#1292,64(a6)
.Skip2:
	move.l	a0,76(a6)
	move.l	a0,84(a6)
	move.w	d6,88(a6)
	lea.l	40(a0),a0
	dbra	d7,.Wait
	rts

;*****************************************************************************
; [ Draw a vertical line ]
;   IN : d0 - X (.w)
;        d1 - Top Y (.w)
;        d3 - Bottom Y (.w)
;        d4 - Colour (.w)
; All registers are restored
;*****************************************************************************
Draw_vline:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	-14(sp),sp
	move.l	sp,a5
	lea.l	Custom,a6
	cmp.w	d1,d3
	bpl.s	.Skip
	exg	d1,d3
.Skip:
	move.l	CA_Sp,a0
	move.l	(a0),a0
	cmp.w	CA_X2(a0),d0
	bgt.w	.Exit
	cmp.w	CA_Y2(a0),d1
	bgt.w	.Exit
	cmp.w	(a0),d0
	bmi.w	.Exit
	cmp.w	CA_Y1(a0),d3
	bmi.w	.Exit
	cmp.w	(a0),d0
	bpl.s	.Skip2
	move.w	(a0),d0
.Skip2:
	cmp.w	CA_Y1(a0),d1
	bpl.s	.Skip3
	move.w	CA_Y1(a0),d1
.Skip3:
	cmp.w	CA_X2(a0),d0
	ble.s	.Skip4
	move.w	CA_X2(a0),d0
.Skip4:
	cmp.w	CA_Y2(a0),d3
	bmi.s	.Skip5
	move.w	CA_Y2(a0),d3
.Skip5:
	move.w	d0,(a5)
	move.w	d1,2(a5)
	move.w	d3,6(a5)
	move.w	d4,8(a5)
	sub.w	d1,d3
	addq.w	#1,d3
	move.w	d3,12(a5)
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.l	Work_screen,a0
	move.w	(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	lea.l	Pixel_masks,a1
	add.w	d3,d3
	move.w	0(a1,d3.w),d0
	move.w	d0,bltadat(a6)
	move.w	12(a5),d6
	lsl.w	#6,d6
	addq.w	#1,d6
	move.w	8(a5),d5
	move.w	#$c6,bltbmod(a6)
	move.w	#$c6,bltdmod(a6)
	move.w	#0,bltcon1(a6)
	moveq.l	#4,d7
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	ror.b	#1,d5
	bcc.s	.Skip6
	move.w	#$5fc,bltcon0(a6)
	bra.s	.Skip7
.Skip6:
	move.w	#$50c,bltcon0(a6)
.Skip7:
	move.l	a0,bltbpt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d6,bltsize(a6)
	lea.l	40(a0),a0
	dbra	d7,.Wait2
.Exit:
	lea.l	14(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw a horizontal line ]
;   IN : d0 - Left X (.w)
;        d1 - Y (.w)
;        d2 - Right X (.w)
;        d4 - Colour (.w)
; All registers are restored
;*****************************************************************************
Draw_hline:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	-14(sp),sp
	move.l	sp,a5
	lea.l	Custom,a6
	cmp.w	d0,d2
	bpl.s	.Skip
	exg	d0,d2
.Skip:
	move.w	d0,(a5)
	move.w	d1,2(a5)
	move.w	d2,4(a5)
	move.w	d4,8(a5)
	sub.w	d0,d2
	addq.w	#1,d2
	move.w	d2,10(a5)
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.w	(a5),d0
	lsr.w	#4,d0
	move.w	4(a5),d1
	lsr.w	#4,d1
	cmp.w	d0,d1
	bne.w	.Skip2
	move.l	Work_screen,a0
	move.w	(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	lea.l	Left_edge_masks,a1
	add.w	d3,d3
	move.w	0(a1,d3.w),d0
	lea.l	Right_edge_masks,a1
	move.w	4(a5),d3
	andi.w	#$f,d3
	add.w	d3,d3
	and.w	0(a1,d3.w),d0
	move.w	d0,bltadat(a6)
	jsr	Draw_hline_part
	bra.w	.Exit
.Skip2:
	move.w	4(a5),d0
	andi.w	#$f,d0
	sub.w	d0,10(a5)
	move.w	(a5),d0
	andi.w	#$f,d0
	beq.w	.Skip3
	subi.w	#16,d0
	add.w	d0,10(a5)
	move.l	Work_screen,a0
	move.w	(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	lea.l	Left_edge_masks,a1
	add.w	d3,d3
	move.w	0(a1,d3.w),bltadat(a6)
	jsr	Draw_hline_part
	move.w	(a5),d0
	andi.w	#-$10,d0
	addi.w	#16,d0
	move.w	d0,(a5)
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
.Skip3:
	move.l	Work_screen,a0
	move.w	(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	move.w	4(a5),d0
	andi.w	#$f,d0
	cmp.w	#15,d0
	bne.s	.Skip4
	addi.w	#16,10(a5)
.Skip4:
	moveq.l	#64,d6
	move.w	10(a5),d5
	lsr.w	#4,d5
	beq.w	.Skip5
	add.w	d5,d6
	move.w	8(a5),d5
	move.w	10(a5),d4
	andi.w	#-$10,d4
	lsr.w	#3,d4
	subi.w	#200,d4
	neg.w	d4
	move.w	d4,bltdmod(a6)
	move.w	#0,bltcon1(a6)
	move.w	#256,d4
	moveq.l	#4,d7
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	ror.b	#1,d5
	scs	d4
	move.w	d4,bltcon0(a6)
	move.l	a0,bltdpt(a6)
	move.w	d6,bltsize(a6)
	lea.l	40(a0),a0
	dbra	d7,.Wait3
.Skip5:
	move.w	4(a5),d0
	andi.w	#$f,d0
	cmp.w	#15,d0
	beq.w	.Exit
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	move.l	Work_screen,a0
	move.w	4(a5),d0
	move.w	2(a5),d1
	jsr	Get_screen_offset
	add.l	d2,a0
	lea.l	Right_edge_masks,a1
	add.w	d3,d3
	move.w	0(a1,d3.w),bltadat(a6)
	jsr	Draw_hline_part
.Exit:
	lea.l	14(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw one 16 pixel wide part of a horizontal line ]
;   IN : a0 - Screen pointer (.l)
;        a5 - Pointer to Box_LDS (.l)
;*****************************************************************************
Draw_hline_part:
	moveq.l	#65,d6
	move.w	8(a5),d5
	move.w	#198,98(a6)
	move.w	#198,102(a6)
	move.w	#0,66(a6)
	moveq.l	#4,d7
.Wait:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait
	ror.b	#1,d5
	bcc.s	.Skip
	move.w	#1532,64(a6)
	bra.s	.Skip2
.Skip:
	move.w	#1292,64(a6)
.Skip2:
	move.l	a0,76(a6)
	move.l	a0,84(a6)
	move.w	d6,88(a6)
	lea.l	40(a0),a0
	dbra	d7,.Wait
	rts

;*****************************************************************************
; [ Put a masked 16x16 icon on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        a0 - Pointer to icon graphics (.l)
; All registers are restored
;*****************************************************************************
Put_masked_icon:
	movem.l	d0-d7/a0-a2/a6,-(sp)
	lea.l	Custom,a6
	tst.w	d5
	blt.w	.Exit
	cmp.w	#5,d5
	bgt.w	.Exit
	jsr	Make_icon_mask
	move.l	Work_screen,a1
	andi.w	#-$10,d0
	jsr	Get_screen_offset
	add.l	d2,a1
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.l	#$fca0000,bltcon0(a6)
	move.w	#1025,d7
	move.w	#0,bltamod(a6)
	move.w	d5,d2
	subq.w	#1,d2
	add.w	d2,d2
	move.w	d2,bltbmod(a6)
	move.w	#198,d2
	move.w	d2,bltcmod(a6)
	move.w	d2,bltdmod(a6)
	move.w	d5,-(sp)
	bra.s	.Skip
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	a2,bltapt(a6)
	move.l	a0,bltbpt(a6)
	move.l	a1,bltcpt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	addq.l	#2,a0
	lea.l	40(a1),a1
.Skip:
	dbra	d5,.Wait2
	move.w	(sp)+,d0
	cmp.w	#5,d0
	beq.w	.Exit
	ror.b	d0,d4
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	move.w	d2,bltbmod(a6)
	clr.w	bltcon1(a6)
	moveq.l	#5,d5
	sub.w	d0,d5
	bra.s	.Skip4
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	ror.b	#1,d4
	bcc.s	.Skip2
	move.w	#$dfc,bltcon0(a6)
	bra.s	.Skip3
.Skip2:
	ori.w	#$d0c,bltcon0(a6)
.Skip3:
	move.l	a2,bltapt(a6)
	move.l	a1,bltbpt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	lea.l	40(a1),a1
.Skip4:
	dbra	d5,.Wait4
.Exit:
	movem.l	(sp)+,d0-d7/a0-a2/a6
	rts

;*****************************************************************************
; [ Put an unmasked 16x16 icon on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        a0 - Pointer to icon graphics (.l)
; All registers are restored
;*****************************************************************************
Put_unmasked_icon:
	movem.l	d0-d5/d7/a0-a2/a6,-(sp)
	lea.l	Custom,a6
	tst.w	d5
	blt.w	.Exit
	cmp.w	#5,d5
	bgt.w	.Exit
	move.l	Work_screen,a1
	andi.w	#-$10,d0
	jsr	Get_screen_offset
	add.l	d2,a1
	cmp.w	#5,d5
	bne.w	.Skip
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.l	#$9f00000,bltcon0(a6)
	move.w	#0,bltamod(a6)
	move.w	#$26,bltdmod(a6)
	move.l	a0,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	#$1401,bltsize(a6)
	bra.w	.Exit
.Skip:
	jsr	Make_icon_mask
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	#-$1,bltafwm(a6)
	move.l	#$9f00000,bltcon0(a6)
	move.w	#1025,d7
	move.w	#$c6,bltdmod(a6)
	move.w	d5,d2
	subq.w	#1,d2
	add.w	d2,d2
	move.w	d2,bltamod(a6)
	move.w	d5,-(sp)
	bra.s	.Skip2
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	move.l	a0,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	addq.l	#2,a0
	lea.l	40(a1),a1
.Skip2:
	dbra	d5,.Wait3
	move.w	(sp)+,d0
	cmp.w	#5,d0
	beq.w	.Exit
	ror.b	d0,d4
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	move.w	#0,bltamod(a6)
	moveq.l	#5,d5
	sub.w	d0,d5
	bra.s	.Skip5
.Wait5:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait5
	ror.b	#1,d4
	bcc.s	.Skip3
	move.w	#$9f0,bltcon0(a6)
	bra.s	.Skip4
.Skip3:
	move.w	#$900,bltcon0(a6)
.Skip4:
	move.l	a2,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	lea.l	40(a1),a1
.Skip5:
	dbra	d5,.Wait5
.Exit:
	movem.l	(sp)+,d0-d5/d7/a0-a2/a6
	rts

;*****************************************************************************
; [ Put a masked block on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
; NOTE :
;   - Calls the CPU or the blitter version depending on [ Blitter_or_CPU ].
;*****************************************************************************
Put_masked_block:
	tst.b	Blitter_or_CPU
	bne.w	Put_masked_block2

;*****************************************************************************
; [ Put a masked block (blitter version) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
;*****************************************************************************
Put_masked_block_blitter:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
	lea.l	-6(sp),sp
	move.l	sp,a5
	lea.l	Custom,a6
	move.w	d0,0(a5)
	move.w	d6,d2
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d2,2(a5)
	move.w	d4,4(a5)
	moveq.l	#0,d4
	jsr	Make_mask_blitter
	tst.w	d5
	blt.w	.Skip12
	cmp.w	#5,d5
	bgt.w	.Skip12
	andi.w	#-$10,d0
	move.l	CA_Sp,a1
	move.l	(a1),a1
	cmp.w	CA_X2(a1),d0
	bgt.w	.Skip12
	cmp.w	CA_Y2(a1),d1
	bgt.w	.Skip12
	move.w	2(a5),d2
	cmp.w	(a1),d2
	bmi.w	.Skip12
	move.w	d1,d3
	add.w	d7,d3
	subq.w	#1,d3
	cmp.w	CA_Y1(a1),d3
	bmi.w	.Skip12
	cmp.w	CA_Y1(a1),d1
	bpl.s	.Skip
	move.l	d4,-(sp)
	move.w	CA_Y1(a1),d4
	sub.w	d1,d4
	sub.w	d4,d7
	add.w	d4,d4
	mulu.w	d6,d4
	add.l	d4,a2
	mulu.w	d5,d4
	add.l	d4,a0
	move.l	(sp)+,d4
	move.w	CA_Y1(a1),d1
.Skip:
	cmp.w	CA_Y2(a1),d3
	bmi.s	.Skip2
	sub.w	CA_Y2(a1),d3
	sub.w	d3,d7
.Skip2:
	move.w	d6,d3
	cmp.w	(a1),d0
	bpl.s	.Skip3
	bset.l	#0,d4
	move.l	d4,-(sp)
	move.w	(a1),d4
	sub.w	d0,d4
	lsr.w	#4,d4
	sub.w	d4,d6
	add.w	d4,d4
	add.w	d4,a0
	add.w	d4,a2
	move.l	(sp)+,d4
	move.w	(a1),d0
.Skip3:
	cmp.w	CA_X2(a1),d2
	ble.s	.Skip4
	bset.l	#1,d4
	sub.w	CA_X2(a1),d2
	lsr.w	#4,d2
	sub.w	d2,d6
.Skip4:
	tst.w	d7
	ble.w	.Skip12
	move.l	d3,-(sp)
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	move.l	(sp)+,d3
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	moveq.l	#-1,d0
	btst.l	#0,d4
	beq.s	.Skip5
	lea.l	Left_edge_masks2,a3
	move.w	0(a5),d0
	andi.w	#$f,d0
	eori.w	#$f,d0
	add.w	d0,d0
	move.w	0(a3,d0.w),d0
.Skip5:
	move.w	d0,bltafwm(a6)
	moveq.l	#0,d0
	btst.l	#1,d4
	beq.s	.Skip6
	lea.l	Right_edge_masks,a3
	move.w	2(a5),d0
	addq.w	#1,d0
	andi.w	#$f,d0
	eori.w	#$f,d0
	add.w	d0,d0
	move.w	0(a3,d0.w),d0
.Skip6:
	move.w	d0,bltalwm(a6)
	move.w	0(a5),d2
	andi.w	#$f,d2
	ror.w	#4,d2
	move.w	d2,bltcon1(a6)
	ori.w	#$fca,d2
	move.w	d2,bltcon0(a6)
	lsl.w	#6,d7
	add.w	d6,d7
	add.w	d3,d3
	add.w	d6,d6
	move.w	d3,d0
	sub.w	d6,d0
	move.w	d3,d1
	mulu.w	d5,d1
	sub.w	d6,d1
	move.w	#200,d2
	sub.w	d6,d2
	btst.l	#0,d4
	beq.s	.Skip7
	subq.w	#2,d0
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#1,d7
	subq.l	#2,a0
	subq.l	#2,a1
	subq.l	#2,a2
.Skip7:
	btst.l	#1,d4
	bne.s	.Skip8
	subq.w	#2,d0
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#1,d7
.Skip8:
	move.w	d0,bltamod(a6)
	move.w	d1,bltbmod(a6)
	move.w	d2,bltcmod(a6)
	move.w	d2,bltdmod(a6)
	move.w	d5,-(sp)
	bra.s	.Skip9
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	a2,bltapt(a6)
	move.l	a0,bltbpt(a6)
	move.l	a1,bltcpt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	add.w	d3,a0
	lea.l	40(a1),a1
.Skip9:
	dbra	d5,.Wait2
	move.w	(sp)+,d0
	cmp.w	#5,d0
	beq.w	.Skip12
	move.w	4(a5),d4
	ror.b	d0,d4
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	move.w	d2,bltbmod(a6)
	clr.w	bltcon1(a6)
	move.w	0(a5),d2
	andi.w	#$f,d2
	ror.w	#4,d2
	ori.w	#$d00,d2
	moveq.l	#5,d5
	sub.w	d0,d5
	bra.s	.Skip11
.Loop:
	ror.b	#1,d4
	bcc.s	.Skip10
	move.b	#-4,d2
	bra.s	.Wait4
.Skip10:
	move.b	#12,d2
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	move.w	d2,bltcon0(a6)
	move.l	a2,bltapt(a6)
	move.l	a1,bltbpt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	lea.l	40(a1),a1
.Skip11:
	dbra	d5,.Loop
.Skip12:
	move.b	Mask_handle,d0
	beq.s	.Exit
	jsr	Free_pointer
	jsr	Free_memory
.Exit:
	clr.b	Mask_handle
	lea.l	6(sp),sp
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts

;*****************************************************************************
; [ Put a masked block on the work screen (CPU version) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
; NOTE (disassembly) :
;   D0 = X
;   D1 = Y
;   D5 = bpp (3, 4 or 5)
;   D6 = image width (in 16px blocks)
;   D7 = image height
;   A0 = image data address
;*****************************************************************************
Put_masked_block2:
	movem.l	d0-d7/a0-a6,-(sp)		; D0 = X
					; D1 = Y
					; D5 = bpp (3, 4 or 5)
					; D6 = image width (in 16px blocks)
					; D7 = image height
					; A0 = image data address
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	lea.l	-14(sp),sp
	move.l	sp,a6
	move.w	d0,(a6)
	move.w	d6,d2
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d2,2(a6)
	move.w	d4,4(a6)
	move.w	d5,8(a6)
	clr.w	12(a6)
	jsr	Make_mask_CPU
	tst.w	d5
	blt.w	.Skip15
	cmp.w	#5,d5
	bgt.w	.Skip15
	andi.w	#-$10,d0
	move.l	CA_Sp,a1
	move.l	(a1),a1
	cmp.w	CA_X2(a1),d0
	bgt.w	.Skip15
	cmp.w	CA_Y2(a1),d1
	bgt.w	.Skip15
	move.w	2(a6),d2
	cmp.w	(a1),d2
	bmi.w	.Skip15
	move.w	d1,d3
	add.w	d7,d3
	subq.w	#1,d3
	cmp.w	CA_Y1(a1),d3
	bmi.w	.Skip15
	cmp.w	CA_Y1(a1),d1
	bpl.s	.Skip
	move.w	CA_Y1(a1),d4
	sub.w	d1,d4
	sub.w	d4,d7
	add.w	d4,d4
	mulu.w	d6,d4
	add.l	d4,a2
	mulu.w	d5,d4
	add.l	d4,a0
	move.w	CA_Y1(a1),d1
.Skip:
	cmp.w	CA_Y2(a1),d3
	bmi.s	.Skip2
	sub.w	CA_Y2(a1),d3
	sub.w	d3,d7
.Skip2:
	move.w	d6,d3
	cmp.w	(a1),d0
	bpl.s	.Skip3
	st	12(a6)
	move.w	(a1),d4
	sub.w	d0,d4
	lsr.w	#4,d4
	sub.w	d4,d6
	add.w	d4,d4
	add.w	d4,a0
	add.w	d4,a2
	move.w	(a1),d0
.Skip3:
	cmp.w	CA_X2(a1),d2
	ble.s	.Skip4
	st	13(a6)
	sub.w	CA_X2(a1),d2
	lsr.w	#4,d2
	sub.w	d2,d6
.Skip4:
	tst.w	d7
	ble.w	.Skip15
	add.w	d3,d3
	move.w	d3,6(a6)
	move.w	d6,10(a6)
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	move.w	(a6),d0
	andi.w	#$f,d0
	subq.w	#1,d7
.Loop:
	move.w	8(a6),d6
	bra.s	.Skip8
.Loop2:
	move.l	a0,a3
	move.l	a1,a4
	move.l	a2,a5
	moveq.l	#0,d3
	moveq.l	#0,d4
	tst.b	12(a6)
	beq.s	.Skip5
	moveq.l	#0,d1
	move.w	-2(a5),d1
	ror.l	d0,d1
	swap	d1
	move.w	d1,d4
	moveq.l	#0,d1
	move.w	-2(a3),d1
	ror.l	d0,d1
	swap	d1
	move.w	d1,d3
.Skip5:
	move.w	10(a6),d5
	bra.s	.Skip6
.Loop3:
	moveq.l	#0,d1
	move.w	(a5)+,d1
	ror.l	d0,d1
	move.l	d1,d2
	swap	d2
	or.w	d4,d1
	move.w	d2,d4
	not.w	d1
	and.w	d1,(a4)
	moveq.l	#0,d1
	move.w	(a3)+,d1
	ror.l	d0,d1
	move.l	d1,d2
	swap	d2
	or.w	d3,d1
	move.w	d2,d3
	or.w	d1,(a4)+
.Skip6:
	dbra	d5,.Loop3
	tst.b	13(a6)
	bne.s	.Skip7
	not.w	d4
	and.w	d4,(a4)
	or.w	d3,(a4)
.Skip7:
	add.w	6(a6),a0
	lea.l	40(a1),a1
.Skip8:
	dbra	d6,.Loop2
	move.w	8(a6),d1
	cmp.w	#5,d1
	beq.w	.Skip14
	move.w	4(a6),d5
	ror.b	d1,d5
	moveq.l	#5,d6
	sub.w	d1,d6
	subq.w	#1,d6
.Loop4:
	move.l	a1,a4
	move.l	a2,a5
	moveq.l	#0,d4
	tst.b	12(a6)
	beq.s	.Skip9
	moveq.l	#0,d1
	move.w	-2(a5),d1
	ror.l	d0,d1
	swap	d1
	move.w	d1,d4
.Skip9:
	ror.b	#1,d5
	bcs.s	.Skip11
	move.w	d5,-(sp)
	move.w	10(a6),d5
	bra.s	.Skip10
.Loop5:
	moveq.l	#0,d1
	move.w	(a5)+,d1
	ror.l	d0,d1
	move.l	d1,d2
	swap	d2
	or.w	d4,d1
	move.w	d2,d4
	not.w	d1
	and.w	d1,(a4)+
.Skip10:
	dbra	d5,.Loop5
	tst.b	13(a6)
	bne.s	.Skip13
	not.w	d4
	and.w	d4,(a4)
	bra.s	.Skip13
.Skip11:
	move.w	d5,-(sp)
	move.w	10(a6),d5
	bra.s	.Skip12
.Loop6:
	moveq.l	#0,d1
	move.w	(a5)+,d1
	ror.l	d0,d1
	move.l	d1,d2
	swap	d2
	or.w	d4,d1
	move.w	d2,d4
	or.w	d1,(a4)+
.Skip12:
	dbra	d5,.Loop6
	tst.b	13(a6)
	bne.s	.Skip13
	or.w	d4,(a4)
.Skip13:
	move.w	(sp)+,d5
	lea.l	40(a1),a1
	dbra	d6,.Loop4
.Skip14:
	add.w	6(a6),a2
	dbra	d7,.Loop
.Skip15:
	move.b	Mask_handle,d0
	beq.s	.Exit
	jsr	Free_pointer
	jsr	Free_memory
.Exit:
	clr.b	Mask_handle
	lea.l	14(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Put the silhouette of a masked block on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Silhouette colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
;*****************************************************************************
Put_masked_silhouette:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
	subq.w	#6,sp
	move.l	sp,a5
	lea.l	Custom,a6
	move.w	d0,(a5)
	move.w	d6,d2
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d2,2(a5)
	move.w	d4,4(a5)
	moveq.l	#0,d4
	jsr	Make_mask_blitter
	tst.w	d5
	blt.w	.Skip11
	cmp.w	#5,d5
	bgt.w	.Skip11
	andi.w	#-$10,d0
	move.l	CA_Sp,a1
	move.l	(a1),a1
	cmp.w	CA_X2(a1),d0
	bgt.w	.Skip11
	cmp.w	CA_Y2(a1),d1
	bgt.w	.Skip11
	move.w	2(a5),d2
	cmp.w	(a1),d2
	bmi.w	.Skip11
	move.w	d1,d3
	add.w	d7,d3
	subq.w	#1,d3
	cmp.w	CA_Y1(a1),d3
	bmi.w	.Skip11
	cmp.w	CA_Y1(a1),d1
	bpl.s	.Skip
	move.l	d4,-(sp)
	move.w	CA_Y1(a1),d4
	sub.w	d1,d4
	sub.w	d4,d7
	add.w	d4,d4
	mulu.w	d6,d4
	add.l	d4,a2
	mulu.w	d5,d4
	add.l	d4,a0
	move.l	(sp)+,d4
	move.w	CA_Y1(a1),d1
.Skip:
	cmp.w	CA_Y2(a1),d3
	bmi.s	.Skip2
	sub.w	CA_Y2(a1),d3
	sub.w	d3,d7
.Skip2:
	move.w	d6,d3
	cmp.w	(a1),d0
	bpl.s	.Skip3
	bset.l	#0,d4
	move.l	d4,-(sp)
	move.w	(a1),d4
	sub.w	d0,d4
	lsr.w	#4,d4
	sub.w	d4,d6
	add.w	d4,d4
	add.w	d4,a0
	add.w	d4,a2
	move.l	(sp)+,d4
	move.w	(a1),d0
.Skip3:
	cmp.w	CA_X2(a1),d2
	ble.s	.Skip4
	bset.l	#1,d4
	sub.w	CA_X2(a1),d2
	lsr.w	#4,d2
	sub.w	d2,d6
.Skip4:
	tst.w	d7
	ble.w	.Skip11
	move.l	d3,-(sp)
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	move.l	(sp)+,d3
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	moveq.l	#-1,d0
	btst.l	#0,d4
	beq.s	.Skip5
	lea.l	Left_edge_masks2,a3
	move.w	(a5),d0
	andi.w	#$f,d0
	eori.w	#$f,d0
	add.w	d0,d0
	move.w	0(a3,d0.w),d0
.Skip5:
	move.w	d0,bltafwm(a6)
	moveq.l	#0,d0
	btst.l	#1,d4
	beq.s	.Skip6
	lea.l	Right_edge_masks,a3
	move.w	2(a5),d0
	addq.w	#1,d0
	andi.w	#$f,d0
	eori.w	#$f,d0
	add.w	d0,d0
	move.w	0(a3,d0.w),d0
.Skip6:
	move.w	d0,bltalwm(a6)
	lsl.w	#6,d7
	add.w	d6,d7
	add.w	d3,d3
	add.w	d6,d6
	move.w	d3,d0
	sub.w	d6,d0
	move.w	d3,d1
	mulu.w	d5,d1
	sub.w	d6,d1
	move.w	#200,d2
	sub.w	d6,d2
	btst.l	#0,d4
	beq.s	.Skip7
	subq.w	#2,d0
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#1,d7
	subq.l	#2,a0
	subq.l	#2,a1
	subq.l	#2,a2
.Skip7:
	btst.l	#1,d4
	bne.s	.Skip8
	subq.w	#2,d0
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#1,d7
.Skip8:
	move.w	d0,bltamod(a6)
	move.w	d2,bltbmod(a6)
	move.w	d2,bltdmod(a6)
	clr.w	bltcon1(a6)
	move.w	(a5),d2
	andi.w	#$f,d2
	ror.w	#4,d2
	ori.w	#$d00,d2
	move.w	4(a5),d4
	moveq.l	#5,d5
	bra.s	.Skip10
.Loop:
	ror.b	#1,d4
	bcc.s	.Skip9
	move.b	#-4,d2
	bra.s	.Wait2
.Skip9:
	move.b	#12,d2
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.w	d2,bltcon0(a6)
	move.l	a2,bltapt(a6)
	move.l	a1,bltbpt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	lea.l	40(a1),a1
.Skip10:
	dbra	d5,.Loop
.Skip11:
	move.b	Mask_handle,d0
	beq.s	.Exit
	jsr	Free_pointer
	jsr	Free_memory
.Exit:
	clr.b	Mask_handle
	addq.w	#6,sp
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts

;*****************************************************************************
; [ Put an unmasked block on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
; NOTE (disassembly) :
;   D0 = X
;   D1 = Y
;   D4 = palette offset (e.g. 24)
;   D5 = bpp (3, 4 or 5)
;   D6 = image width (in 16px blocks)
;   D7 = image height
;   A0 = image data address
;*****************************************************************************
Put_unmasked_block:
	movem.l	d0-d7/a0-a2/a5/a6,-(sp)		; D0 = X
					; D1 = Y
					; D5 = bpp (3, 4 or 5)
					; D6 = image width (in 16px blocks)
					; D7 = image height
					; A0 = image data address
	subq.w	#6,sp
	move.l	sp,a5
	lea.l	Custom,a6
	move.w	d4,4(a5)
	cmp.w	#5,d5
	beq.s	.Skip
	jsr	Make_mask_blitter
.Skip:
	tst.w	d5
	blt.w	.Skip11
	cmp.w	#5,d5
	bgt.w	.Skip11
	andi.w	#-$10,d0
	move.l	CA_Sp,a1
	move.l	(a1),a1
	cmp.w	CA_X2(a1),d0
	bgt.w	.Skip11
	cmp.w	CA_Y2(a1),d1
	bgt.w	.Skip11
	move.w	d6,d2
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	cmp.w	(a1),d2
	bmi.w	.Skip11
	move.w	d1,d3
	add.w	d7,d3
	subq.w	#1,d3
	cmp.w	CA_Y1(a1),d3
	bmi.w	.Skip11
	cmp.w	CA_Y1(a1),d1
	bpl.s	.Skip2
	move.w	CA_Y1(a1),d4
	sub.w	d1,d4
	sub.w	d4,d7
	add.w	d4,d4
	mulu.w	d6,d4
	add.w	d4,a2
	mulu.w	d5,d4
	add.l	d4,a0
	move.w	CA_Y1(a1),d1
.Skip2:
	cmp.w	CA_Y2(a1),d3
	bmi.s	.Skip3
	sub.w	CA_Y2(a1),d3
	sub.w	d3,d7
.Skip3:
	move.w	d6,d3
	cmp.w	(a1),d0
	bpl.s	.Skip4
	move.w	(a1),d4
	sub.w	d0,d4
	lsr.w	#4,d4
	sub.w	d4,d6
	add.w	d4,d4
	add.w	d4,a0
	add.w	d4,a2
	move.w	(a1),d0
.Skip4:
	cmp.w	CA_X2(a1),d2
	ble.s	.Skip5
	sub.w	CA_X2(a1),d2
	lsr.w	#4,d2
	sub.w	d2,d6
.Skip5:
	tst.w	d6
	bne.w	.Skip6
	moveq.l	#1,d6
.Skip6:
	tst.w	d7
	ble.w	.Skip11
	move.l	d3,-(sp)
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	move.l	(sp)+,d3
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	move.l	#$9f00000,bltcon0(a6)
	lsl.w	#6,d7
	add.w	d6,d7
	move.w	#200,d2
	add.w	d6,d6
	sub.w	d6,d2
	move.w	d2,bltdmod(a6)
	add.w	d3,d3
	move.w	d3,d1
	sub.w	d6,d1
	move.w	d3,d2
	mulu.w	d5,d2
	sub.w	d6,d2
	move.w	d2,bltamod(a6)
	move.w	d5,-(sp)
	bra.s	.Skip7
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	a0,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	add.w	d3,a0
	lea.l	40(a1),a1
.Skip7:
	dbra	d5,.Wait2
	move.w	(sp)+,d0
	cmp.w	#5,d0
	beq.w	.Skip11
	move.w	4(a5),d4
	ror.b	d0,d4
.Wait3:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait3
	move.w	d1,bltamod(a6)
	moveq.l	#5,d5
	sub.w	d0,d5
	bra.s	.Skip10
.Wait4:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait4
	ror.b	#1,d4
	bcc.s	.Skip8
	move.w	#$9f0,bltcon0(a6)
	bra.s	.Skip9
.Skip8:
	move.w	#$900,bltcon0(a6)
.Skip9:
	move.l	a2,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d7,bltsize(a6)
	lea.l	40(a1),a1
.Skip10:
	dbra	d5,.Wait4
.Skip11:
	move.b	Mask_handle,d0
	beq.s	.Exit
	jsr	Free_pointer
	jsr	Free_memory
.Exit:
	clr.b	Mask_handle
	addq.w	#6,sp
	movem.l	(sp)+,d0-d7/a0-a2/a5/a6
	rts

;*****************************************************************************
; [ Calculate offset of a pixel in a screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : d2 - Byte offset in screen (.l)
;        d3 - X-coordinate & 15 (.w)
;*****************************************************************************
Get_screen_offset:
	move.l	d0,-(sp)
	move.w	d1,d2
	mulu.w	#200,d2		; 200 bytes per 320pixel row (5bpp)
	moveq.l	#15,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#3,d0
	add.w	d0,d2		; byte offset for pixel at
					; x + y * 320. x is rounded
					; down to full 16 pixels.
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Create the mask of a graphic with the blitter ]
;   IN : d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height (.w)
;        a0 - Pointer to graphics (.l)
;        a6 - Custom (.l)
;  OUT : a2 - Pointer to mask (.l)
; NOTE :
;   - Small masks are created in [ Mask_buffer ], bigger ones in allocated
;     CHIP memory (handle in [ Mask_handle ]).
;*****************************************************************************
Make_mask_blitter:
	movem.l	d0/d1/d5-d7/a0/a6,-(sp)
	move.w	d6,d0
	add.w	d0,d0
	mulu.w	d7,d0
	cmp.l	#128,d0
	bmi.s	.Skip
	jsr	Allocate_CHIP
	move.b	d0,Mask_handle
	jsr	Claim_pointer
	move.l	d0,a2
	bra.s	.Wait
.Skip:
	lea.l	Mask_buffer,a2
	clr.b	Mask_handle
.Wait:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait
	move.l	#-1,68(a6)
	move.w	#0,66(a6)
	lsl.w	#6,d7
	add.w	d6,d7
	add.w	d6,d6
	move.w	d6,d0
	mulu.w	d5,d0
	sub.w	d6,d0
	move.w	d0,100(a6)
	move.w	#0,98(a6)
	move.w	#0,102(a6)
	move.w	#2544,64(a6)
	move.l	a0,80(a6)
	move.l	a2,84(a6)
	move.w	d7,88(a6)
	add.w	d6,a0
	subq.w	#2,d5
	bmi.s	.Exit
.Wait2:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait2
	move.w	#3580,64(a6)
.Wait3:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait3
	move.l	a0,80(a6)
	move.l	a2,76(a6)
	move.l	a2,84(a6)
	move.w	d7,88(a6)
	add.w	d6,a0
	dbra	d5,.Wait3
.Exit:
	movem.l	(sp)+,d0/d1/d5-d7/a0/a6
	rts

;*****************************************************************************
; [ Create the mask of a graphic with the CPU ]
;   IN : d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height (.w)
;        a0 - Pointer to graphics (.l)
;  OUT : a2 - Pointer to mask (.l)
;*****************************************************************************
Make_mask_CPU:
	movem.l	d0-d7/a0/a1,-(sp)
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	move.w	d6,d0
	add.w	d0,d0
	mulu.w	d7,d0
	cmp.l	#128,d0
	bmi.s	.Skip
	jsr	Allocate_memory
	move.b	d0,Mask_handle
	jsr	Claim_pointer
	move.l	d0,a2
	bra.s	.Skip2
.Skip:
	lea.l	Mask_buffer,a2
	clr.b	Mask_handle
.Skip2:
	move.l	a2,-(sp)
	move.w	d6,d2
	add.w	d2,d2
	move.w	d5,d3
	subq.w	#1,d3
	mulu.w	d2,d3
	subq.w	#1,d5
	subq.w	#1,d6
	subq.w	#1,d7
.Loop:
	move.w	d6,d4
.Loop2:
	move.l	a0,a1
	move.w	(a0)+,d0
	move.w	d5,d1
	bra.s	.Skip3
.Loop3:
	add.w	d2,a1
	or.w	(a1),d0
.Skip3:
	dbra	d1,.Loop3
	move.w	d0,(a2)+
	dbra	d4,.Loop2
	add.w	d3,a0
	dbra	d7,.Loop
	move.l	(sp)+,a2
	movem.l	(sp)+,d0-d7/a0/a1
	rts

;*****************************************************************************
; [ Create the mask of a 16x16 icon ]
;   IN : d5 - Number of planes (.w)
;        a0 - Pointer to icon graphics (.l)
;        a6 - Custom (.l)
;  OUT : a2 - Pointer to mask in [ Mask_buffer ] (.l)
;*****************************************************************************
Make_icon_mask:
	movem.l	d0/d5/d7/a0,-(sp)
	lea.l	Mask_buffer,a2
.Wait:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait
	move.l	#-1,68(a6)
	move.w	#0,66(a6)
	move.w	#1025,d7
	move.w	d5,d0
	subq.w	#1,d0
	add.w	d0,d0
	move.w	d0,100(a6)
	move.w	#0,98(a6)
	move.w	#0,102(a6)
	move.w	#2544,64(a6)
.Wait2:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait2
	move.l	a0,80(a6)
	move.l	a2,84(a6)
	move.w	d7,88(a6)
	subq.w	#2,d5
	bmi.s	.Exit
.Wait3:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait3
	addq.l	#2,a0
	move.w	#3580,64(a6)
	bra.s	.Skip
.Wait4:
	btst.b	#6,2(a6)
	btst.b	#6,2(a6)
	bne.s	.Wait4
.Skip:
	move.l	a0,80(a6)
	move.l	a2,76(a6)
	move.l	a2,84(a6)
	move.w	d7,88(a6)
	addq.l	#2,a0
	dbra	d5,.Wait4
.Exit:
	movem.l	(sp)+,d0/d5/d7/a0
	rts


	SECTION	Chip_BSS,bss_c
	ds.b	72464
Mask_buffer:
	ds.b	128

	SECTION	Fast_DATA,data
Default_CA:
	dc.w	0		; Rect.Left
	dc.w	$13f		; Rect.Right
	dc.w	0		; Rect.Top
	dc.w	$c7		; Rect.Bottom
Left_edge_masks:
	dc.b	$ff,$ff
Left_edge_masks2:
	dc.w	$7fff
	dc.b	$3f,$ff,$1f,$ff,$f,$ff,7,$ff,3,$ff,1,$ff,0,$ff,0,$7f
	dc.b	0,$3f,0,$1f,0,$f,0,7,0,3,0,1,0,0
Right_edge_masks:
	dc.b	$80,0,$c0,0
	dc.w	$e000
	dc.b	$f0,0,$f8,0,$fc,0,$fe,0,$ff,0,$ff,$80,$ff,$c0,$ff,$e0
	dc.b	$ff,$f0,$ff,$f8,$ff,$fc,$ff,$fe,$ff,$ff
Pixel_masks:
	dc.b	$80,0

	SECTION	Fast_BSS,bss
Work_screen:
	ds.l	1
Shown_screen:
	ds.l	1
Mask_handle:
	ds.b	2
CA_Sp:
	ds.b	52
CA_stack_end:
Pixel_buffer:
	ds.b	16
