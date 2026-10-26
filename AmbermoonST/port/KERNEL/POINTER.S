; ST kernel : software mouse pointer
;
; The Amiga version shows the mouse pointer with sprites. On the ST it is
; drawn into the work screen before the screens are switched, and erased
; afterwards with the saved background (like the HDOBs). The graphic comes
; from [ Set_mouse_pointer_gfx ] (MOUSE.S) : mask and 4 planes per line, the
; colours are the Amiga colours 24-31 (ST colours 8-15).

	SECTION	Program,code

;*****************************************************************************
; [ Draw the mouse pointer into the work screen ]
; All registers are restored
;*****************************************************************************
Draw_mouse_pointer:
	movem.l	d0-d7/a0-a2,-(sp)
	lea.l	Pointer_save1,a2		; Save area of this screen
	tst.b	Screen_flag
	beq.s	.Save
	lea.l	Pointer_save2,a2
.Save:	clr.w	4(a2)			; (nothing saved)
	tst.b	Mouse_off_flag		; Pointer off ?
	bne	.Exit
	move.w	Mouse_X,d0		; Top-left corner
	sub.w	Mouse_hotspot_X,d0
	move.w	Mouse_Y,d1
	sub.w	Mouse_hotspot_Y,d1
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
	move.l	d1,(a2)+			; Save offset & height
	move.w	d7,(a2)+
	move.l	Work_screen,a0
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
; [ Erase the mouse pointer from the work screen ]
; All registers are restored
; NOTE :
;   - [ Erase_mouse_pointer ] uses the background which was saved when the
;     work screen was drawn. [ Copy_mouse_pointer ] is called after the shown
;     screen was copied to the work screen (with [ Screen_flag ] inverted
;     like for [ Erase_HDOBs ]) : it erases the pointer of the shown screen
;     from the copy and keeps the saved background for the shown screen.
;*****************************************************************************
Erase_mouse_pointer:
	movem.l	d0-d7/a0/a1,-(sp)
	moveq.l	#-1,d6			; Forget
	bra.s	Erase_pointer
Copy_mouse_pointer:
	movem.l	d0-d7/a0/a1,-(sp)
	moveq.l	#0,d6			; Keep
Erase_pointer:
	lea.l	Pointer_save1,a1
	tst.b	Screen_flag
	beq.s	.Do
	lea.l	Pointer_save2,a1
.Do:	move.w	4(a1),d7			; Anything saved ?
	beq.s	.Exit
	move.l	Work_screen,a0
	add.l	(a1),a0
	tst.w	d6
	beq.s	.Keep
	clr.w	4(a1)
.Keep:	addq.l	#6,a1
	subq.w	#1,d7
.Line:	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,(a0)
	lea.l	ST_bytes_per_line(a0),a0
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0/a1
	rts

	SECTION	Fast_BSS,bss
Pointer_save1:	ds.b 6+16*16		; Address, height, 16 lines * 2 chunks
	even
Pointer_save2:	ds.b 6+16*16
	even
