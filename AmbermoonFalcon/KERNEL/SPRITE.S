; Falcon kernel : the mouse pointer in the screen format of the Falcon
; (POINTER.S : when the pointer is drawn and erased. Replaces SPRITE.S of the
; ST kernel.)

	SECTION	Program,code

;*****************************************************************************
; [ Convert the graphics of the mouse pointer ]
;   IN : a0 - Pointer to 16 lines of 3 planes (the colours 24-31) (.l)
; All registers are restored
; NOTE :
;   - [ Falcon_pointer_gfx ] : mask and 8 planes per line. The colours are
;     the UI colours 24-31 of bank 0 (the same in all palettes) : the planes
;     3 and 4 are the mask, 5-7 are 0.
;*****************************************************************************
Convert_pointer_gfx:
	movem.l	d0-d3/d7/a0/a1,-(sp)
	lea.l	Falcon_pointer_gfx,a1
	moveq.l	#16-1,d7
.Loop:	movem.w	(a0)+,d0-d2		; Planes 0-2
	move.w	d0,d3			; Mask
	or.w	d1,d3
	or.w	d2,d3
	move.w	d3,(a1)+
	move.w	d0,(a1)+			; Planes 0-2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+			; Planes 3 & 4 (colour 24)
	move.w	d3,(a1)+
	clr.w	(a1)+			; Planes 5-7 (bank 0)
	clr.w	(a1)+
	clr.w	(a1)+
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
	movem.l	d0-d7/a0-a4,-(sp)
	move.w	d0,Rec_X(a2)
	move.w	d1,Rec_Y(a2)
	lea.l	Falcon_pointer_gfx,a1
	moveq.l	#16,d7			; Clip vertically
	tst.w	d1
	bpl.s	.Top
	add.w	d1,d7
	ble	.Exit
	neg.w	d1
	mulu.w	#9*2,d1
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
.Right:	mulu.w	#Screen_bytes_per_line,d1	; Offset in the screen
	move.w	d0,d2
	lsr.w	#4,d2
	lsl.w	#4,d2			; (16 bytes per chunk)
	add.w	d2,d1
	move.l	d1,Rec_offset(a2)
	move.w	d7,Rec_height(a2)
	st	Rec_drawn(a2)
	lea.l	Rec_data(a2),a2
	move.l	a3,a0
	add.l	d1,a0
	andi.w	#15,d0			; Shift
	subq.w	#1,d7
.Line:	movem.l	(a0),d1-d6/a3/a4		; Save background (2 chunks)
	movem.l	d1-d6/a3/a4,(a2)
	lea.l	32(a2),a2
	moveq.l	#0,d1			; Mask
	move.w	(a1)+,d1
	swap	d1
	lsr.l	d0,d1
	not.l	d1
	moveq.l	#8-1,d6			; 8 planes
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
	move.w	Chunk_bytes(a0),d3		; Right chunk
	swap	d1
	and.w	d1,d3
	swap	d2
	or.w	d2,d3
	move.w	d3,Chunk_bytes(a0)
	addq.l	#2,a0
	dbra	d6,.Plane
	lea.l	Screen_bytes_per_line-Chunk_bytes(a0),a0
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Put the saved background of the pointer into a screen ]
;   IN : a0 - Pointer to screen (.l)
;        a2 - Pointer to the save record (.l)
; All registers are restored
;*****************************************************************************
Put_pointer_background:
	movem.l	d0-d7/a0/a1/a3/a4,-(sp)
	add.l	Rec_offset(a2),a0
	move.w	Rec_height(a2),d7
	lea.l	Rec_data(a2),a1
	subq.w	#1,d7
.Line:	movem.l	(a1)+,d0-d6/a3		; (2 chunks : 8 longs)
	movem.l	d0-d6/a3,(a0)
	lea.l	Screen_bytes_per_line(a0),a0
	dbra	d7,.Line
	movem.l	(sp)+,d0-d7/a0/a1/a3/a4
	rts

	SECTION	Fast_BSS,bss
Falcon_pointer_gfx:			; Mask, 8 planes * 16 lines
	ds.w	16*9
