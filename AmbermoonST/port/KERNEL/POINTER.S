; ST kernel : software mouse pointer
;
; The Amiga version shows the mouse pointer with sprites, which follow the
; mouse in every frame. On the ST the vertical blank handler draws it into
; the shown screen ([ VBL_pointer ], called by [ Update_mouse_sprite ]),
; with the saved background, whenever the mouse moved : the pointer moves
; smoothly also when the game shows a new screen only a few times a second.
;
; Every screen buffer has its own save record (background of the pointer in
; that screen), so the pointer never disappears :
;   - before the screens are switched the pointer is drawn into the work
;     screen too ([ Pointer_into_work ]), the screen shown next has it
;     already; afterwards it is erased from the new work screen
;     ([ Pointer_out_of_work ]),
;   - when the shown screen is copied to the work screen the pointer stays
;     where it is and is erased from the copy afterwards ([ Copy_screen ]).
; Meanwhile the vertical blank handler leaves the pointer alone
; ([ Pointer_frozen ]). The graphic comes from [ Set_mouse_pointer_gfx ]
; (MOUSE.S, the colours are the Amiga colours 24-31). Drawing the pointer and
; its background is done by SPRITE.S (the screen format).

	SECTION	Program,code

;*****************************************************************************
; [ Draw the mouse pointer into the shown screen ]
; All registers are restored
; NOTE :
;   - Called by the vertical blank handler.
;*****************************************************************************
VBL_pointer:
	tst.b	Pointer_frozen		; Left alone ?
	bne.s	.Exit
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	On_screen,a3
	jsr	Pointer_record
	jsr	Pointer_position
	tst.b	Rec_drawn(a2)		; Drawn at this position already ?
	beq.s	.Draw
	tst.b	Pointer_changed
	bne.s	.Restore
	cmp.w	Rec_X(a2),d0
	bne.s	.Restore
	cmp.w	Rec_Y(a2),d1
	beq.s	.Done
.Restore:	jsr	Restore_pointer
.Draw:	tst.b	Mouse_off_flag		; Pointer off ?
	bne.s	.Done
	sf	Pointer_changed
	jsr	Draw_pointer
.Done:	movem.l	(sp)+,d0-d7/a0-a3
.Exit:	rts

;*****************************************************************************
; [ Before / after the screens are switched ]
; All registers are restored
; NOTE :
;   - [ Pointer_into_work ] stops the vertical blank handler and draws the
;     pointer into the work screen, [ Pointer_out_of_work ] erases it from
;     the (new) work screen and lets the vertical blank handler go on.
;*****************************************************************************
Pointer_into_work:
	movem.l	d0/d1/a2/a3,-(sp)
	addq.b	#1,Pointer_frozen
	move.l	Work_screen,a3
	jsr	Pointer_record
	jsr	Restore_pointer
	tst.b	Mouse_off_flag
	bne.s	.Exit
	jsr	Pointer_position
	jsr	Draw_pointer
.Exit:	movem.l	(sp)+,d0/d1/a2/a3
	rts

Pointer_out_of_work:
	movem.l	d0/a2/a3,-(sp)
	move.l	Work_screen,a3
	jsr	Pointer_record
	jsr	Restore_pointer
	subq.b	#1,Pointer_frozen
	movem.l	(sp)+,d0/a2/a3
	rts

;*****************************************************************************
; [ Take the mouse pointer away / show it again ]
; All registers are restored
; NOTE :
;   - For routines which copy parts of the shown screen. Calls can be
;     nested.
;   - [ Show_pointer ] draws the pointer again at once (not in the next
;     vertical blank) : the combat copies its window every frame
;     ([ Duplicate_block ]), the pointer must not be missing when the frame
;     is shown (the Falcon shows the whole frame from the memory at the
;     vertical blank).
;*****************************************************************************
Hide_pointer:
	movem.l	d0/a2/a3,-(sp)
	move.w	sr,-(sp)
	ori.w	#$0700,sr
	addq.b	#1,Pointer_frozen
	move.l	On_screen,a3
	jsr	Pointer_record
	jsr	Restore_pointer
	move.w	(sp)+,sr
	movem.l	(sp)+,d0/a2/a3
	rts

Show_pointer:
	move.w	sr,-(sp)
	ori.w	#$0700,sr
	subq.b	#1,Pointer_frozen
	bne.s	.Exit
	jsr	VBL_pointer		; (draws it into the shown screen)
.Exit:	move.w	(sp)+,sr
	rts

;*****************************************************************************
; [ Erase the pointer of the shown screen from its copy ]
; All registers are restored
; NOTE :
;   - Called by [ Copy_screen ] after the shown screen was copied to the
;     work screen : the background of the pointer in the shown screen goes
;     into the work screen, the save record of the work screen is empty.
;*****************************************************************************
Pointer_out_of_copy:
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	Work_screen,a3		; (the old contents are gone)
	jsr	Pointer_record
	sf	Rec_drawn(a2)
	move.l	On_screen,a3
	jsr	Pointer_record
	tst.b	Rec_drawn(a2)
	beq.s	.Exit
	move.l	Work_screen,a0
	jsr	Put_pointer_background
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Get the save record of a screen ]
;   IN : a3 - Pointer to screen (.l)
;  OUT : a2 - Pointer to save record (.l)
; Changed registers : a2
;*****************************************************************************
Pointer_record:
	lea.l	Pointer_records,a2
	cmp.l	Rec_screen(a2),a3
	beq.s	.Exit
	lea.l	Rec_size(a2),a2
	cmp.l	Rec_screen(a2),a3
	beq.s	.Exit
	lea.l	Pointer_records,a2		; New : a record which belongs to
	move.l	Rec_screen(a2),d0		;  none of the two screens
	cmp.l	On_screen,d0
	beq.s	.Second
	cmp.l	Off_screen,d0
	bne.s	.Take
.Second:	lea.l	Rec_size(a2),a2
.Take:	move.l	a3,Rec_screen(a2)
	sf	Rec_drawn(a2)
.Exit:	rts

;*****************************************************************************
; [ Position of the pointer ]
;  OUT : d0 - Left X (.w)
;        d1 - Top Y (.w)
; Changed registers : d0, d1
;*****************************************************************************
Pointer_position:
	move.w	Mouse_X,d0
	sub.w	Mouse_hotspot_X,d0
	move.w	Mouse_Y,d1
	sub.w	Mouse_hotspot_Y,d1
	rts

;*****************************************************************************
; [ Restore the background of the mouse pointer ]
;   IN : a2 - Pointer to the save record of the screen (.l)
; All registers are restored
;*****************************************************************************
Restore_pointer:
	tst.b	Rec_drawn(a2)		; Drawn ?
	beq.s	.Exit
	move.l	a0,-(sp)
	sf	Rec_drawn(a2)
	move.l	Rec_screen(a2),a0
	jsr	Put_pointer_background
	move.l	(sp)+,a0
.Exit:	rts

; Save record of a screen
	rsreset
Rec_screen:	rs.l 1			; Screen buffer
Rec_offset:	rs.l 1			; Offset in the screen
Rec_height:	rs.w 1
Rec_X:	rs.w 1			; Position of the pointer
Rec_Y:	rs.w 1
Rec_drawn:	rs.b 1			; The pointer is in this screen
	rseven
Rec_data:	rs.b Pointer_save_size		; (VIDEO.I)
Rec_size:	rs.b 0

	SECTION	Fast_BSS,bss
Pointer_records:	ds.b 2*Rec_size
Pointer_frozen:	ds.b 1			; The VBL leaves the pointer alone
Pointer_changed:	ds.b 1			; Another graphic (Set_mouse_pointer_gfx)
	even
