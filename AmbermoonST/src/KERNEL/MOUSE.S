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
; NOTE :
;   - Also draws the objects which are attached to the mouse, like the HDOBs
;     of the Amiga version : a text above the mouse ([ Ghost_text ], e.g. the
;     name of the item under the mouse, like the ghosts of DISPLAY.S) and a
;     dragged item ([ Drag_graphic ], 16x24, top-left corner at the mouse
;     position). The background of the rectangle around all of them is saved
;     for each screen.
;*****************************************************************************
Draw_mouse_pointer:
	movem.l	d0-d7/a0-a3,-(sp)
	tst.b	Drag_fixed		; Moving item ?
	bne.s	.Select
	tst.b	Mouse_off_flag
	bne	.Exit
	move.l	Current_Mptr,d0
	beq	.Exit
	move.l	d0,a3
.Select:	lea.l	Pointer_save1,a2		; Select save area
	move.l	Work_screen,d0
	cmp.l	(a2),d0			; Screen 1 ?
	beq.s	.Set
	lea.l	Pointer_save2,a2
	cmp.l	(a2),d0			; Screen 2 ?
	beq.s	.Set
	move.l	On_screen,d1		; New screen : replace the area
	lea.l	Pointer_save1,a2		;  that does not belong to the
	cmp.l	(a2),d1			;  shown screen
	bne.s	.Set
	lea.l	Pointer_save2,a2
.Set:	move.l	d0,(a2)
	tst.b	Drag_fixed		; Moving item ?
	beq.s	.Found
	movem.w	Drag_pos,d0/d1		; Yes -> only the item
	move.w	d0,d2
	addi.w	#16,d2
	move.w	d1,d3
	addi.w	#16,d3
	movem.w	d0-d3,Overlay_rect
	bra	.No_text
; ---------- Mouse pointer ------------------------
.Found:	move.w	Mouse_X,d0		; Get position
	sub.w	(a3),d0
	bpl.s	.X
	moveq.l	#0,d0
.X:	move.w	Mouse_Y,d1
	sub.w	2(a3),d1
	bpl.s	.Y
	moveq.l	#0,d1
.Y:	movem.w	d0/d1,Pointer_XY
	move.w	d0,d2
	addi.w	#16,d2
	move.w	d1,d3
	addi.w	#16,d3
	movem.w	d0-d3,Overlay_rect
; ---------- Dragged item -------------------------
	tst.l	Drag_graphic
	beq.s	.No_drag
	move.w	Mouse_X,d0
	move.w	Mouse_Y,d1
	move.w	d0,d2
	addi.w	#16,d2
	move.w	d1,d3
	addi.w	#24,d3
	jsr	Add_overlay_rect
; ---------- Text ---------------------------------
.No_drag:	move.l	Ghost_text,d0
	beq.s	.No_text
	move.l	d0,a0
	moveq.l	#0,d2			; Get width
.Len:	tst.b	(a0)+
	beq.s	.Len_done
	addq.w	#Char_width+1,d2
	bra.s	.Len
.Len_done:	move.w	Mouse_X,d0		; Centre above the mouse
	move.w	d2,d3
	lsr.w	#1,d3
	sub.w	d3,d0
	bpl.s	.Left
	moveq.l	#0,d0
.Left:	move.w	#320-1,d3			; Not beyond the right edge
	sub.w	d2,d3
	cmp.w	d3,d0
	ble.s	.Right
	move.w	d3,d0
.Right:	move.w	Mouse_Y,d1
	subi.w	#Char_height+2,d1
	bpl.s	.Top
	moveq.l	#0,d1
.Top:	movem.w	d0/d1,Ghost_XY
	add.w	d0,d2
	addq.w	#1,d2			; (shadow)
	move.w	d1,d3
	addi.w	#Char_height+1,d3
	jsr	Add_overlay_rect
; ---------- Save background ----------------------
.No_text:	movem.w	Overlay_rect,d0-d3
	andi.w	#-$10,d0			; Whole truncs
	addi.w	#15,d2
	andi.w	#-$10,d2
	cmp.w	#320,d2
	ble.s	.W
	move.w	#320,d2
.W:	cmp.w	#200,d3
	ble.s	.H
	move.w	#200,d3
.H:	sub.w	d0,d2			; Number of truncs
	lsr.w	#4,d2
	sub.w	d1,d3			; Number of lines
	cmp.w	#Overlay_max_lines,d3
	ble.s	.H2
	moveq.l	#Overlay_max_lines,d3
.H2:	move.l	Work_screen,a1
	jsr	Get_screen_offset_d0d1
	move.l	a1,4(a2)
	move.w	d3,8(a2)
	move.w	d2,10(a2)
	lea.l	12(a2),a0
	subq.w	#1,d3
	bmi.s	.Draw
	subq.w	#1,d2
.Loop:	move.l	a1,-(sp)
	move.w	d2,d4
.Loop2:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d4,.Loop2
	move.l	(sp)+,a1
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d3,.Loop
; ---------- Draw ---------------------------------
.Draw:	lea.l	Default_CA,a0
	jsr	Push_CA
	tst.b	Drag_fixed		; Moving item ?
	beq.s	.Normal
	move.l	Drag_graphic,a0		; Yes
	movem.w	Drag_pos,d0/d1
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block
	bra.s	.Done
.Normal:
	move.l	Ghost_text,d0		; Text
	beq.s	.No_text2
	move.l	d0,a0
	move.w	Ink_colour,-(sp)
	move.w	Shadow_colour,-(sp)
	move.w	Ghost_ink,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	movem.w	Ghost_XY,d0/d1
	jsr	Put_text_line
	move.w	(sp)+,Shadow_colour
	move.w	(sp)+,Ink_colour
.No_text2:	move.l	Drag_graphic,d0		; Dragged item
	beq.s	.No_drag2
	move.l	d0,a0
	move.w	Mouse_X,d0
	move.w	Mouse_Y,d1
	moveq.l	#1,d6
	moveq.l	#24,d7
	jsr	Put_masked_block
.No_drag2:	movem.w	Pointer_XY,d0/d1		; Mouse pointer
	lea.l	4(a3),a0
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block
.Done:	jsr	Pop_CA
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Add a rectangle to the overlay rectangle ]
;   IN : d0/d1 - Top-left corner, d2/d3 - Bottom-right corner + 1 (.w)
; All registers are restored
Add_overlay_rect:
	cmp.w	Overlay_rect,d0
	bge.s	.1
	move.w	d0,Overlay_rect
.1:	cmp.w	Overlay_rect+2,d1
	bge.s	.2
	move.w	d1,Overlay_rect+2
.2:	cmp.w	Overlay_rect+4,d2
	ble.s	.3
	move.w	d2,Overlay_rect+4
.3:	cmp.w	Overlay_rect+6,d3
	ble.s	.4
	move.w	d3,Overlay_rect+6
.4:	rts

;*****************************************************************************
; [ Forget the saved background of the shown screen ]
; All registers are restored
; NOTE :
;   - Called when the work screen (without mouse pointer) has been copied to
;     the shown screen : the saved background is no longer valid there.
;*****************************************************************************
Forget_mouse_pointer:
	move.l	d0,-(sp)
	move.l	On_screen,d0
	cmp.l	Pointer_save1,d0
	bne.s	.No1
	clr.w	Pointer_save1+8
.No1:	cmp.l	Pointer_save2,d0
	bne.s	.No2
	clr.w	Pointer_save2+8
.No2:	move.l	(sp)+,d0
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
	move.w	10(a2),d6
	subq.w	#1,d6
	move.l	4(a2),a1
	lea.l	12(a2),a0
	subq.w	#1,d7
.Loop:	move.l	a1,d3
	move.w	d6,d5
.Loop2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d5,.Loop2
	move.l	d3,a1
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d2-d7/a0-a2
	rts

	SECTION	Fast_BSS,bss
Mouse_X:	ds.w 1
Mouse_Y:	ds.w 1
Drag_pos:	ds.w 2			; Position of the moved item
Mouse_buttons:	ds.b 1
Mouse_clicks:	ds.b 1
Mouse_off_flag:	ds.b 1
Drag_fixed:	ds.b 1			; Item moved by the program
	even
Current_Mptr:	ds.l 1
Drag_graphic:	ds.l 1			; Dragged item (16x24) / 0
Ghost_text:	ds.l 1			; Text above the mouse / 0
Ghost_ink:	ds.w 1			; Its colour
Pointer_XY:	ds.w 2
Ghost_XY:	ds.w 2
Overlay_rect:	ds.w 4
; Save areas : screen (.l), address (.l), lines (.w), truncs (.w), data
Overlay_max_lines	EQU	48
Pointer_save1:	ds.b 12+Overlay_max_lines*20*8
Pointer_save2:	ds.b 12+Overlay_max_lines*20*8
