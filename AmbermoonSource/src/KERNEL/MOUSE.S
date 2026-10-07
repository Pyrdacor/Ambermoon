; Mouse pointer, mouse areas & mouse events
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Switch the mouse pointer on (decrease the off counter) ]
;*****************************************************************************
Mouse_on:
	tst.b	Mouse_off_flag
	beq.s	.Exit
	subq.b	#1,Mouse_off_flag
.Exit:
	rts

;*****************************************************************************
; [ Switch the mouse pointer off (increase the off counter) ]
;*****************************************************************************
Mouse_off:
	cmpi.b	#-1,Mouse_off_flag
	beq.s	.Exit
	addq.b	#1,Mouse_off_flag
.Exit:
	rts

;*****************************************************************************
; [ Allow the mouse pointer sprite to be displayed ]
; NOTE :
;   - Clears [ Mouse_off_flag ].
;*****************************************************************************
Show_mouse_pointer:
	clr.b	Mouse_off_flag
	rts

;*****************************************************************************
; [ Push a mouse area on the stack ]
;   IN : a0 - Pointer to MA (.l)
; All registers are restored
; NOTE :
;   - The mouse is trapped inside the new area.
; NOTE (disassembly) :
;   This also pushes the trap area
;   onto the stack.
;*****************************************************************************
Push_MA:
	move.l	a1,-(sp)
	move.l	MA_Sp,a1
	addq.l	#4,a1
	cmp.l	#Last_mouse_x,a1
	beq.s	.Exit
	move.l	a0,(a1)
	move.l	a1,MA_Sp
	jsr	Trap_mouse		; Trap to new area.
.Exit:
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Pop a mouse area from the stack ]
; All registers are restored
; NOTE (disassembly) :
;   This also pops the trap area
;   from the stack.
;*****************************************************************************
Pop_MA:
	move.l	a0,-(sp)
	move.l	MA_Sp,a0
	cmp.l	#MA_Sp+4,a0
	beq.s	.Exit
	subq.l	#4,a0
	move.l	a0,MA_Sp
	move.l	(a0),a0
	jsr	Trap_mouse		; Trap to previous area.
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Reset the mouse area stack ]
; All registers are restored
;*****************************************************************************
Reset_MA_stack:
	movem.l	a0/a1,-(sp)
	lea.l	Default_MA,a0
	lea.l	MA_Sp+4,a1
	move.l	a1,MA_Sp
	move.l	a0,(a1)
	jsr	Trap_mouse
	movem.l	(sp)+,a0/a1
	rts

;*****************************************************************************
; [ Keep the mouse inside a mouse area ]
;   IN : a0 - Pointer to MA (.l)
; All registers are restored
;*****************************************************************************
Trap_mouse:
	movem.l	d0/d1,-(sp)		; This just ensures that the cursor
					; position is inside the given area.
					; The area might be the whole screen.
	move.w	Mouse_X,d0
	move.w	Mouse_Y,d1
	cmp.w	(a0),d0
	bpl.s	.Skip
	move.w	(a0),d0
	bra.s	.Skip2
.Skip:
	cmp.w	MA_X2(a0),d0
	blt.s	.Skip2
	move.w	MA_X2(a0),d0
.Skip2:
	cmp.w	MA_Y1(a0),d1
	bpl.s	.Skip3
	move.w	MA_Y1(a0),d1
	bra.s	.Exit
.Skip3:
	cmp.w	MA_Y2(a0),d1
	blt.s	.Exit
	move.w	MA_Y2(a0),d1
.Exit:
	move.w	d0,Mouse_X
	move.w	d1,Mouse_Y
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Change the current mouse pointer ]
;   IN : a0 - Pointer to mouse pointer (.l)
; All registers are restored
;*****************************************************************************
Change_Mptr:
	move.l	a1,-(sp)
	move.l	Mptr_Sp,a1
	cmp.l	(a1),a0
	beq.s	.Exit
	move.l	a0,(a1)
	jsr	Set_mouse_pointer_gfx
.Exit:
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Push a mouse pointer on the stack ]
;   IN : a0 - Pointer to mouse pointer (.l)
; All registers are restored
;*****************************************************************************
Push_Mptr:
	move.l	a1,-(sp)
	move.l	Mptr_Sp,a1
	addq.l	#4,a1
	cmp.l	#MA_Sp,a1
	beq.s	.Exit
	move.l	a0,(a1)
	move.l	a1,Mptr_Sp
	jsr	Set_mouse_pointer_gfx
.Exit:
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Pop a mouse pointer from the stack ]
; All registers are restored
;*****************************************************************************
Pop_Mptr:
	move.l	a0,-(sp)
	move.l	Mptr_Sp,a0
	cmp.l	#Mptr_Sp+4,a0
	beq.s	.Exit
	subq.l	#4,a0
	move.l	a0,Mptr_Sp
	move.l	(a0),a0
	jsr	Set_mouse_pointer_gfx
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Reset the mouse pointer stack ]
; All registers are restored
;*****************************************************************************
Reset_Mptr_stack:
	movem.l	a0/a1,-(sp)
	lea.l	Default_Mptr,a0
	lea.l	Mptr_Sp+4,a1
	move.l	a0,(a1)
	move.l	a1,Mptr_Sp
	jsr	Set_mouse_pointer_gfx
	movem.l	(sp)+,a0/a1
	rts

;*****************************************************************************
; [ Set the graphics of the mouse pointer sprite ]
;   IN : a0 - Pointer to mouse pointer data (hotspot X & Y, 16 lines of 3 planes) (.l)
; All registers are restored
; NOTE :
;   - The sprite data is double buffered.
;*****************************************************************************
Set_mouse_pointer_gfx:
	movem.l	d0-d2/d7/a0-a2,-(sp)
	move.w	(a0)+,Mouse_hotspot_X
	move.w	(a0)+,Mouse_hotspot_Y
	move.l	Mouse_sprite_buffer_ptr,a1
	addq.l	#4,a1
	lea.l	72(a1),a2
	moveq.l	#15,d7
.Loop:
	movem.w	(a0)+,d0-d2
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a2)+
	or.w	d1,d0
	or.w	d2,d0
	move.w	d0,(a2)+
	dbra	d7,.Loop
	move.l	Mouse_sprite_buffer_ptr,a0
	move.l	Mouse_sprite_ptr,Mouse_sprite_buffer_ptr
	move.l	a0,Mouse_sprite_ptr
	movem.l	(sp)+,d0-d2/d7/a0-a2
	rts

;*****************************************************************************
; [ Update the position of the mouse pointer sprite ]
; NOTE :
;   - Called by the vertical blank handler.
;*****************************************************************************
Update_mouse_sprite:
	tst.b	Mouse_off_flag
	beq.s	.Skip
	lea.l	Empty_sprite,a0
	move.l	a0,a1
	bra.s	.Exit
.Skip:
	move.l	Mouse_sprite_ptr,a0
	move.w	Mouse_X,d0
	move.w	Mouse_Y,d1
	sub.w	Mouse_hotspot_X,d0
	sub.w	Mouse_hotspot_Y,d1
	addi.w	#128,d0
	addi.w	#48,d1
	move.w	d1,d2
	addi.w	#16,d2
	rol.w	#7,d2
	lsl.w	#8,d1
	addx.w	d2,d2
	addx.b	d2,d2
	lsr.w	#1,d0
	addx.b	d2,d2
	ori.b	#-$80,d2
	move.b	d0,d1
	move.w	d1,(a0)
	move.w	d2,2(a0)
	lea.l	72(a0),a1
	move.w	d1,(a1)
	move.w	d2,2(a1)
.Exit:
	move.l	a0,Sprite0_ptr
	move.l	a1,Sprite1_ptr
	rts

;*****************************************************************************
; [ Read the mouse and update the mouse position & buttons ]
; NOTE :
;   - Called by the vertical blank handler. Mouse events are stored with [ Store_Mev ].
;*****************************************************************************
Update_mouse:
	tst.l	MA_Sp
	beq.w	.Exit
	move.w	Custom+joy0dat,d1		; Read mouse position
	moveq.l	#0,d0
	move.b	d1,d0
	lsr.w	#8,d1
	move.w	d0,d2
	move.w	d1,d3
	sub.w	Last_mouse_x,d0		; DO now has the X change
	sub.w	Last_mouse_y,d1		; D1 now has the Y change
	move.w	d2,Last_mouse_x
	move.w	d3,Last_mouse_y
	cmp.w	#127,d0		; Limit mouse pos changes to -127 to +127.
					; If exceeding, add/sub 256.
	ble.s	.Skip
	subi.w	#256,d0
.Skip:
	cmp.w	#-127,d0
	bge.s	.Skip2
	addi.w	#256,d0
.Skip2:
	cmp.w	#127,d1
	ble.s	.Skip3
	subi.w	#256,d1
.Skip3:
	cmp.w	#-127,d1
	bge.s	.Skip4
	addi.w	#256,d1
.Skip4:
	add.w	Mouse_X,d0		; Add change to cursor X
	add.w	Mouse_Y,d1		; Add change to cursor Y
	tst.b	Drugged_FX
	beq.s	.Skip5
	move.w	d0,d2		; If drugged add random offset
					; in range -3 to 4.
	jsr	Random
	andi.w	#7,d0
	subq.w	#3,d0
	add.w	d0,d1
	jsr	Random
	andi.w	#7,d0
	subq.w	#3,d0
	add.w	d2,d0
.Skip5:
	move.l	MA_Sp,a0		; If the cursor is trapped, ensure
					; the cursor is inside the trap area.
	move.l	(a0),a0		; Get current mouse trap area
					; from the stack.
	cmp.w	(a0),d0
	bpl.s	.Skip6
	move.w	(a0),d0
	bra.s	.Skip7
.Skip6:
	cmp.w	MA_X2(a0),d0
	blt.s	.Skip7
	move.w	MA_X2(a0),d0
.Skip7:
	cmp.w	MA_Y1(a0),d1
	bpl.s	.Skip8
	move.w	MA_Y1(a0),d1
	bra.s	.Skip9
.Skip8:
	cmp.w	MA_Y2(a0),d1
	blt.s	.Skip9
	move.w	MA_Y2(a0),d1
.Skip9:
	move.w	d0,Mouse_X		; Update new cursor X
	move.w	d1,Mouse_Y		; Update new cursor Y
	move.b	Button_state,d0
	moveq.l	#0,d1
	btst.b	#6,$bfe001		; Left mouse pressed?
	bne.w	.Skip10
	bset.l	#0,d1		; If not, set bit 0 in D1
.Skip10:
	btst.b	#2,Custom+potinp		; Right mouse pressed?
	bne.w	.Skip11
	bset.l	#4,d1		; If not, set bit 4 in D1
.Skip11:
	move.b	d0,d2		; After this code:
					; D0 holds the last D1 (last state info)
					; D1 holds current mouse buttons state (inverted)
					; D2 holds last mouse buttons state (inverted)
					; D3 holds the info if the button is hold
					; (a 1 means last time active and still active)
					; 
					; These are bitflags and they are shifted in this way:
					; %0HLC0HLC
					; H: Hold flag (1 = hold, 0 = not)
					; L: Last state (0 = pressed, 1 = released)
					; C: Current state (0 = pressed, 1 = released)
					; Upper nibble: Right mouse
					; Lower nibble: Left mouse
	not.b	d2
	andi.b	#$11,d2
	and.b	d1,d2
	move.b	d1,d3
	not.b	d3
	andi.b	#$11,d3
	and.b	d0,d3
	lsl.w	#1,d2
	lsl.w	#2,d3
	or.b	d2,d1
	or.b	d3,d1
	move.b	d1,Button_state
	moveq.l	#0,d2
	move.b	d1,d2
	move.w	Mouse_X,d0
	move.w	Mouse_Y,d1
	jsr	Store_Mev
.Exit:
	rts

;*****************************************************************************
; [ Read the next mouse event ]
;  OUT : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Button state / 0 = no event (.w)
;*****************************************************************************
Read_Mev:
	move.l	a0,-(sp)
	move.l	Mev_read_ptr,a0		; Pointer to current something data
	cmp.l	Mev_write_ptr,a0		; Pointer to last something data
	bne.s	.Skip
	moveq.l	#0,d2		; End of list marker / invalid marker
	bra.s	.Exit
.Skip:
	move.w	(a0)+,d0		; Read 3 words from that data
					; - Cursor X
					; - Cursor Y
					; - Mouse button state
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	cmp.l	#Mouse_buffer_end,a0		; There is space for 150 words
					; (50 * 3 words). 0x28499c is the
					; end of the list.
	blt.s	.Skip2
	lea.l	Mev_buffer,a0		; If end reached, next time
					; start at front.
.Skip2:
	move.l	a0,Mev_read_ptr		; Update the pointer to point
					; to after the 3 read words.
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Store a mouse event ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Button state (.w)
; All registers are restored
;*****************************************************************************
Store_Mev:
	movem.l	a0/a1,-(sp)		; This is called with:
					; D0: Cursor X
					; D1: Cursor Y
					; D2: Current mouse button states
					; If bit 0 is 0, left mouse is down
					; If bit 1 is 0, last time left mouse was down
					; If bit 2 is 1, left mouse is hold
					; Bit 3 is always 0
					; If bit 4 is 0, right mouse is down
					; If bit 5 is 0, last time right mouse was down
					; If bit 6 is 1, rght mouse is hold
					; Bit 7 is always 0
					; D2 can never be 0 in a valid way because then
					; the button was down, is still down but the hold
					; flag is not set, which is not possible. Thus I
					; guess a value of 0 is an invalid marker.
	tst.w	d2
	beq.s	.Exit
	move.l	Mev_write_ptr,a0		; Get queue end
	move.l	a0,a1
	addq.l	#6,a1
	cmp.l	#Mouse_buffer_end,a1		; If it exceeds the queue end,
					; begin at front.
	blt.s	.Skip
	lea.l	Mev_buffer,a1
.Skip:
	cmp.l	Mev_read_ptr,a1
	beq.s	.Exit
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.l	a1,Mev_write_ptr
.Exit:
	movem.l	(sp)+,a0/a1
	rts


	SECTION	Chip_BSS,bss_c
Copper_list2:
	ds.b	2048
Custom_copper_command_area:
	ds.b	2048
Empty_sprite:
	ds.b	4

	SECTION	Fast_DATA,data
Mev_read_ptr:
	dc.l	Mev_buffer
Mev_write_ptr:
	dc.l	Mev_buffer
Mouse_X:
	dc.w	$a0		; Initial this is half the screen
Mouse_Y:
	dc.w	$64		; Initial this is half the screen
Mouse_sprite_ptr:
	dc.l	Mouse_sprite1
Mouse_sprite_buffer_ptr:
	dc.l	Mouse_sprite2
Sprite0_ptr:
	dc.l	Empty_sprite
Sprite1_ptr:
	dc.l	Empty_sprite
Default_MA:
	dc.b	0,0,1,$3f,0,0,0,$c7

	SECTION	Fast_BSS,bss
	ds.b	1
	ds.w	2
	ds.b	506
Mouse_off_flag:
	ds.b	1
Button_state:
	ds.b	1
Mouse_hotspot_X:
	ds.b	2
Mouse_hotspot_Y:
	ds.b	2
Mptr_Sp:
	ds.b	52
MA_Sp:
	ds.b	52
Last_mouse_x:
	ds.w	1
Last_mouse_y:
	ds.w	1
Mev_buffer:
	ds.b	300
