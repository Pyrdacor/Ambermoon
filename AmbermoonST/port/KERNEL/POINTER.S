; ST kernel : software mouse pointer
;
; The Amiga version shows the mouse pointer with sprites, which follow the
; mouse in every frame. On the ST the vertical blank handler draws it into
; the shown screen ([ VBL_pointer ], called by [ Update_mouse_sprite ]),
; with the saved background, whenever the mouse moved : the pointer moves
; smoothly also when the game shows a new screen only a few times a second.
; Before the screens are switched or the shown screen is copied the pointer
; is taken away ([ Hide_pointer ] / [ Show_pointer ]). The graphic comes
; from [ Set_mouse_pointer_gfx ] (MOUSE.S) : mask and 4 planes per line, the
; colours are the Amiga colours 24-31 (their fixed ST colours, see GRAPHICS.S).

	SECTION	Program,code

;*****************************************************************************
; [ Draw the mouse pointer into the shown screen ]
; All registers are restored
; NOTE :
;   - Called by the vertical blank handler.
;*****************************************************************************
VBL_pointer:
	tst.b	Pointer_hidden		; Taken away ?
	bne.s	.Exit
	movem.l	d0-d7/a0-a3,-(sp)
	move.w	Mouse_X,d0		; Top-left corner
	sub.w	Mouse_hotspot_X,d0
	move.w	Mouse_Y,d1
	sub.w	Mouse_hotspot_Y,d1
	tst.b	Pointer_drawn		; Drawn at this position already ?
	beq.s	.Draw
	tst.b	Pointer_changed
	bne.s	.Restore
	cmp.w	Pointer_drawn_X,d0
	bne.s	.Restore
	cmp.w	Pointer_drawn_Y,d1
	beq.s	.Done
.Restore:	jsr	Restore_pointer
.Draw:	tst.b	Mouse_off_flag		; Pointer off ?
	bne.s	.Done
	move.w	d0,Pointer_drawn_X
	move.w	d1,Pointer_drawn_Y
	sf	Pointer_changed
	move.l	On_screen,a3
	jsr	Draw_pointer
.Done:	movem.l	(sp)+,d0-d7/a0-a3
.Exit:	rts

;*****************************************************************************
; [ Take the mouse pointer away / show it again ]
; All registers are restored
; NOTE :
;   - Calls can be nested. While the pointer is away the vertical blank
;     handler does not draw it.
;*****************************************************************************
Hide_pointer:
	move.w	sr,-(sp)
	ori.w	#$0700,sr
	addq.b	#1,Pointer_hidden
	jsr	Restore_pointer
	move.w	(sp)+,sr
	rts

Show_pointer:
	subq.b	#1,Pointer_hidden
	rts

;*****************************************************************************
; [ Draw the mouse pointer ]
;   IN : d0 - Left X (.w)
;        d1 - Top Y (.w)
;        a3 - Pointer to screen (.l)
; All registers are restored
; NOTE :
;   - The background is saved in [ Pointer_save ] (offset, height, lines).
;*****************************************************************************
Draw_pointer:
	movem.l	d0-d7/a0-a2,-(sp)
	lea.l	Pointer_save,a2
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
	move.l	a3,(a2)+			; Save screen, offset & height
	move.l	d1,(a2)+
	move.w	d7,(a2)+
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
	st	Pointer_drawn
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Restore the background of the mouse pointer ]
; All registers are restored
;*****************************************************************************
Restore_pointer:
	tst.b	Pointer_drawn		; Drawn ?
	beq.s	.Exit
	movem.l	d0-d7/a0/a1,-(sp)
	sf	Pointer_drawn
	lea.l	Pointer_save,a1
	move.l	(a1)+,a0			; Screen + offset
	add.l	(a1)+,a0
	move.w	(a1)+,d7
	subq.w	#1,d7
.Line:	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,(a0)
	lea.l	ST_bytes_per_line(a0),a0
	dbra	d7,.Line
	movem.l	(sp)+,d0-d7/a0/a1
.Exit:	rts

	SECTION	Fast_BSS,bss
Pointer_save:	ds.b 10+16*16		; Screen, offset, height, 16 lines * 2 chunks
	even
Pointer_drawn_X:	ds.w 1
Pointer_drawn_Y:	ds.w 1
Pointer_drawn:	ds.b 1			; The pointer is in the shown screen
Pointer_hidden:	ds.b 1			; (Hide_pointer / Show_pointer)
Pointer_changed:	ds.b 1			; Another graphic (Set_mouse_pointer_gfx)
	even
