; ST kernel : the mouse pointer in the ST screen format
; (POINTER.S : when the pointer is drawn and erased. The Falcon version has
; its own SPRITE.S.)

	SECTION	Program,code

;*****************************************************************************
; [ Convert the graphics of the mouse pointer ]
;   IN : a0 - Pointer to 16 lines of 3 planes (the colours 24-31) (.l)
; All registers are restored
; NOTE :
;   - [ ST_pointer_gfx ] : mask and 4 planes per line, the ST colours of the
;     UI colours (p0 = a0 & ~a2, p1 = a1, p2 = a2, p3 = mask, see GRAPHICS.S).
;*****************************************************************************
Convert_pointer_gfx:
	movem.l	d0-d3/d7/a0/a1,-(sp)
	lea.l	ST_pointer_gfx,a1		; Mask, 4 planes per line
	moveq.l	#16-1,d7
.Loop:	movem.w	(a0)+,d0-d2		; Planes 0-2 (colours 24-31)
	move.w	d0,d3			; Mask = plane 3
	or.w	d1,d3
	or.w	d2,d3
	move.w	d3,(a1)+
	move.w	d2,-(sp)			; Plane 0 = a0 & ~a2 (the ST colours
	not.w	(sp)			;  of the UI colours, see GRAPHICS.S)
	and.w	(sp)+,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d3/d7/a0/a1
	rts

;*****************************************************************************
; [ Draw the mouse pointer ]
;   IN : d0 - Left X (.w)
;        d1 - Top Y (.w)
;        a2 - Pointer to the save record of the screen (.l)
;        a3 - Pointer to screen (.l)
; All registers are restored
;*****************************************************************************
Draw_pointer:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	d0,Rec_X(a2)
	move.w	d1,Rec_Y(a2)
	lea.l	ST_pointer_gfx,a1
	moveq.l	#16,d7			; Clip vertically
	tst.w	d1
	bpl.s	.Top
	add.w	d1,d7
	ble	.Exit
	neg.w	d1
	mulu.w	#10,d1
	add.w	d1,a1
	moveq.l	#0,d1
.Top:	move.w	#Screen_height,d2
	sub.w	d1,d2
	ble	.Exit
	cmp.w	d2,d7
	ble.s	.Height
	move.w	d2,d7
.Height:	tst.w	d0			; Clip horizontally (whole chunks)
	bpl.s	.Left
	moveq.l	#0,d0
.Left:	cmp.w	#320-32,d0
	ble.s	.Right
	move.w	#320-32,d0
.Right:	mulu.w	#ST_bytes_per_line,d1	; Offset in the screen
	move.w	d0,d2
	lsr.w	#4,d2
	lsl.w	#3,d2
	add.w	d2,d1
	move.l	d1,Rec_offset(a2)
	move.w	d7,Rec_height(a2)
	st	Rec_drawn(a2)
	lea.l	Rec_data(a2),a2
	move.l	a3,a0
	add.l	d1,a0
	andi.w	#15,d0			; Shift
	subq.w	#1,d7
.Line:	movem.l	(a0),d1-d4		; Save background (2 chunks)
	movem.l	d1-d4,(a2)
	lea.l	16(a2),a2
	moveq.l	#0,d1			; Mask
	move.w	(a1)+,d1
	swap	d1
	lsr.l	d0,d1
	not.l	d1
	moveq.l	#4-1,d6			; 4 planes
.Plane:	moveq.l	#0,d2
	move.w	(a1)+,d2
	swap	d2
	lsr.l	d0,d2
	move.w	(a0),d3			; Left chunk
	swap	d1
	and.w	d1,d3
	swap	d2
	or.w	d2,d3
	move.w	d3,(a0)
	move.w	8(a0),d3			; Right chunk
	swap	d1
	and.w	d1,d3
	swap	d2
	or.w	d2,d3
	move.w	d3,8(a0)
	addq.l	#2,a0
	dbra	d6,.Plane
	lea.l	ST_bytes_per_line-8(a0),a0
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Put the saved background of the pointer into a screen ]
;   IN : a0 - Pointer to screen (.l)
;        a2 - Pointer to the save record (.l)
; All registers are restored
;*****************************************************************************
Put_pointer_background:
	movem.l	d0-d3/d7/a0/a1,-(sp)
	add.l	Rec_offset(a2),a0
	move.w	Rec_height(a2),d7
	lea.l	Rec_data(a2),a1
	subq.w	#1,d7
.Line:	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,(a0)
	lea.l	ST_bytes_per_line(a0),a0
	dbra	d7,.Line
	movem.l	(sp)+,d0-d3/d7/a0/a1
	rts

	SECTION	Fast_BSS,bss
ST_pointer_gfx:			; Mask, 4 planes * 16 lines
	ds.w	16*5
