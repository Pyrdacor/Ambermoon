; Mouse position, buttons & mouse pointer (Atari ST)
; Replaces KERNEL/MOUSE.S of the Amiga version.
; The ST has no sprites, so the mouse pointer is drawn into the work screen
; before the screens are switched (like the HDOBs of the Amiga version) and
; erased after the switch.

	SECTION	Program,code

;*****************************************************************************
; [ Handle a relative mouse packet of the IKBD ]
; Called by the ACIA interrupt.
; Changed registers : d0,d1,a0
;*****************************************************************************
Mouse_packet:
	lea.l	IKBD_packet,a0
	move.b	(a0),d0			; Buttons
	moveq.l	#0,d1
	btst	#1,d0			; Left ?
	beq.s	.No_left
	bset	#Left_pressed,d1
.No_left:	btst	#0,d0			; Right ?
	beq.s	.No_right
	bset	#Right_pressed,d1
.No_right:	move.b	Mouse_buttons,d0		; Clicks
	not.b	d0
	and.b	d1,d0
	or.b	d0,Mouse_clicks
	move.b	d1,Mouse_buttons
	move.b	1(a0),d0			; X
	ext.w	d0
	add.w	Mouse_X,d0
	bpl.s	.X1
	moveq.l	#0,d0
.X1:	cmp.w	#319,d0
	ble.s	.X2
	move.w	#319,d0
.X2:	move.w	d0,Mouse_X
	move.b	2(a0),d0			; Y
	ext.w	d0
	add.w	Mouse_Y,d0
	bpl.s	.Y1
	moveq.l	#0,d0
.Y1:	cmp.w	#199,d0
	ble.s	.Y2
	move.w	#199,d0
.Y2:	move.w	d0,Mouse_Y
	rts

;*****************************************************************************
; [ Read the mouse clicks since the last call ]
;  OUT : d0 - Clicks (bit Left_pressed / Right_pressed) (.w)
; Changed registers : d0
;*****************************************************************************
Read_mouse_clicks:
	move.w	sr,-(sp)
	move.w	#$2700,sr
	moveq.l	#0,d0
	move.b	Mouse_clicks,d0
	clr.b	Mouse_clicks
	move.w	(sp)+,sr
	rts

;*****************************************************************************
; [ Switch the mouse pointer on / off ]
; All registers are restored
;*****************************************************************************
Mouse_on:
	sf	Mouse_off_flag
	rts
Mouse_off:
	st	Mouse_off_flag
	rts

;*****************************************************************************
; [ Change the current mouse pointer ]
;   IN : a0 - Pointer to mouse pointer (hotspot X & Y, 16x16 ST graphic) (.l)
; All registers are restored
;*****************************************************************************
Change_Mptr:
	move.l	a0,Current_Mptr
	rts

;*****************************************************************************
; [ Draw the mouse pointer into the work screen ]
; All registers are restored
;*****************************************************************************
Draw_mouse_pointer:
	movem.l	d0-d7/a0-a3,-(sp)
	tst.b	Mouse_off_flag
	bne	.Exit
	move.l	Current_Mptr,d0
	beq	.Exit
	move.l	d0,a3
	lea.l	Pointer_save1,a2		; Select save area
	move.l	Work_screen,d0
	tst.l	(a2)
	beq.s	.Set
	cmp.l	(a2),d0
	beq.s	.Found
	lea.l	Pointer_save2,a2
.Set:	move.l	d0,(a2)
.Found:	move.w	Mouse_X,d0		; Get position
	sub.w	(a3),d0
	bpl.s	.X
	moveq.l	#0,d0
.X:	move.w	Mouse_Y,d1
	sub.w	2(a3),d1
	bpl.s	.Y
	moveq.l	#0,d1
.Y:	move.w	#200,d7			; Number of lines
	sub.w	d1,d7
	cmp.w	#16,d7
	ble.s	.Lines
	moveq.l	#16,d7
.Lines:	move.l	Work_screen,a1		; Save background
	jsr	Get_screen_offset_d0d1
	move.l	a1,4(a2)
	move.w	d7,8(a2)
	lea.l	10(a2),a0
	move.w	d7,d6
	subq.w	#1,d6
.Loop:	movem.l	(a1),d2-d5
	movem.l	d2-d5,(a0)
	lea.l	16(a0),a0
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d6,.Loop
	lea.l	Default_CA,a0		; Draw
	jsr	Push_CA
	lea.l	4(a3),a0
	moveq.l	#1,d6
	jsr	Put_masked_block
	jsr	Pop_CA
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Erase the mouse pointer from the work screen ]
; All registers are restored
;*****************************************************************************
Erase_mouse_pointer:
	movem.l	d2-d7/a0-a2,-(sp)
	lea.l	Pointer_save1,a2
	move.l	Work_screen,d2
	cmp.l	(a2),d2
	beq.s	.Found
	lea.l	Pointer_save2,a2
	cmp.l	(a2),d2
	bne.s	.Exit
.Found:	move.w	8(a2),d7			; Anything saved ?
	beq.s	.Exit
	clr.w	8(a2)
	move.l	4(a2),a1
	lea.l	10(a2),a0
	subq.w	#1,d7
.Loop:	movem.l	(a0)+,d2-d5
	movem.l	d2-d5,(a1)
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d2-d7/a0-a2
	rts

	SECTION	Fast_BSS,bss
Mouse_X:	ds.w 1
Mouse_Y:	ds.w 1
Mouse_buttons:	ds.b 1
Mouse_clicks:	ds.b 1
Mouse_off_flag:	ds.b 1
	even
Current_Mptr:	ds.l 1
; Save areas : screen (.l), address (.l), lines (.w), 16 lines x 16 bytes
Pointer_save1:	ds.b 10+16*16
Pointer_save2:	ds.b 10+16*16
