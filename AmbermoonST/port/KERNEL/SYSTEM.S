; ST kernel : taking over the system, screens, vertical blank
; Replaces KERNEL/SYSTEM.S of the Amiga version (same routines and variables).
; The video hardware is in VIDEO.S, the raster interrupts in RASTER.S (the
; Falcon version has its own).

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the system ]
; All registers are restored
; NOTE :
;   - Called in supervisor mode while the TOS is still active.
;   - Switches the video mode at 50 Hz (like the PAL Amiga : the timing of
;     the game and the music, [ Init_video ]), installs the VBL, the raster
;     interrupts ([ Install_raster ]) and the ACIA (keyboard & mouse)
;     handlers.
;*****************************************************************************
Init_system:
	movem.l	d0-d7/a0-a6,-(sp)
	dc.w	$a00a			; Line-A : hide mouse
; ---------- Screens ------------------------------
	jsr	Init_screens
	jsr	Init_video
	jsr	Init_copper
; ---------- Take over interrupts -----------------
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.l	Vec_VBL.w,Old_VBL
	move.l	Vec_ACIA.w,Old_ACIA
	move.b	MFP_IERA,Old_IERA
	move.b	MFP_IERB,Old_IERB
	move.b	MFP_IMRA,Old_IMRA
	move.b	MFP_IMRB,Old_IMRB
	move.b	MFP_VR,Old_VR
	move.l	#Vbl_interrupt,Vec_VBL.w
	move.l	#ACIA_interrupt,Vec_ACIA.w
	clr.b	MFP_IERA			; (the raster interrupts : below)
	clr.b	MFP_IMRA
	move.b	#$40,MFP_IERB		; Only ACIA (no Timer C)
	move.b	#$40,MFP_IMRB
	bset	#3,MFP_VR			; Software end of interrupt
	jsr	Install_raster
	st	System_active
	move.w	(sp)+,sr
	jsr	My_vsync
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Restore the system ]
; All registers are restored
;*****************************************************************************
Exit_system:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	sr,-(sp)
	move.w	#$2700,sr
	sf	System_active
	jsr	Remove_raster
	move.l	Old_VBL,Vec_VBL.w
	move.l	Old_ACIA,Vec_ACIA.w
	move.b	Old_IERA,MFP_IERA
	move.b	Old_IERB,MFP_IERB
	move.b	Old_IMRA,MFP_IMRA
	move.b	Old_IMRB,MFP_IMRB
	move.b	Old_VR,MFP_VR
	move.w	(sp)+,sr
	jsr	Exit_video
	dc.w	$a009			; Line-A : show mouse
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Vertical blank interrupt ]
; NOTE :
;   - Like [ Run_copper ] (COLOURS.S) of the Amiga version : the colours are
;     set (raster events), the fades are handled, then the vertical blank
;     handler.
;*****************************************************************************
Vbl_interrupt:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Raster_VBL
	jsr	Colour_handler
	jsr	Vbl_handler
	movem.l	(sp)+,d0-d7/a0-a6
	rte

;*****************************************************************************
; [ Vertical blank handler ]
;*****************************************************************************
Vbl_handler:
	addq.w	#1,VBL_counter
	jsr	Update_mouse
	jsr	Update_mouse_sprite
	jsr	Random
	jsr	VblQ_handler
	tst.b	Music_flag
	beq.s	.Exit
	jsr	_SA_IrqLowLevel
.Exit:
	rts

;*****************************************************************************
; [ Initialize the screen buffers ]
; All registers are restored
;*****************************************************************************
Init_screens:
	movem.l	d0/a0/a1,-(sp)
	move.l	#Screen_buffers+255,d0	; Align to 256 bytes
	andi.w	#$ff00,d0
	move.l	d0,a0
	move.l	a0,a1
	add.l	#Screen_size,a1
	move.l	a0,On_screen
	move.l	a1,Off_screen
	move.l	a1,Work_screen
	jsr	Clear_screen
	exg	a0,a1
	jsr	Clear_screen
	exg	a0,a1
	move.l	a0,Shown_screen		; (shown by Setscreen, the VBL is
	clr.w	Vertical_screen_offset	;  not installed yet)
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Show the work screen ]
; The HDOBs and the mouse pointer are drawn, the screens are switched and
; the new work screen is updated with the contents of the shown screen.
; All registers are restored
;*****************************************************************************
Update_screen:
	move.l	a0,-(sp)
	jsr	Draw_HDOBs
	jsr	Pointer_into_work		; ST: no sprites (see POINTER.S)
	move.l	Off_screen,a0
	move.l	On_screen,Off_screen
	move.l	a0,On_screen
	jsr	Show_screen
	move.l	Off_screen,Work_screen
	not.b	Screen_flag
	jsr	Erase_HDOBs
	jsr	Copy_screen
	jsr	Pointer_out_of_work
	jsr	ScrQ_handler
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Switch screens ]
; Like [ Update_screen ], but the new work screen is not updated.
; All registers are restored
;*****************************************************************************
Switch_screens:
	move.l	a0,-(sp)
	jsr	Draw_HDOBs
	jsr	Pointer_into_work		; ST: no sprites (see POINTER.S)
	move.l	Off_screen,a0
	move.l	On_screen,Off_screen
	move.l	a0,On_screen
	jsr	Show_screen
	move.l	Off_screen,Work_screen
	not.b	Screen_flag
	jsr	Pointer_out_of_work		; (drawn after the HDOBs)
	jsr	Erase_HDOBs
	jsr	ScrQ_handler
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Show a screen buffer ]
;   IN : a0 - Pointer to screen (.l)
; NOTE :
;   - The video base is latched at the start of the next frame, so it is
;     written now and then the next vertical blank is awaited.
;*****************************************************************************
Show_screen:
	move.l	a0,Shown_screen
	jsr	Set_video_base
	jmp	My_vsync

;*****************************************************************************
; [ Copy the shown screen to the work screen ]
; All registers are restored
; NOTE :
;   - Like the Amiga version, the HDOBs (and the mouse pointer) of the shown
;     screen are erased from the copy.
;*****************************************************************************
Copy_screen:
	addq.b	#1,Pointer_frozen		; (the pointer stays where it is)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	On_screen,a0
	move.l	Off_screen,a1
	move.w	#Screen_size/48-1,d7
.Loop:	movem.l	(a0)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a1)
	lea.l	48(a1),a1
	dbra	d7,.Loop
	REPT	(Screen_size-Screen_size/48*48)/4	; Rest
	move.l	(a0)+,(a1)+
	ENDR
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	Pointer_out_of_copy		; (drawn after the HDOBs)
	not.b	Screen_flag
	jsr	Erase_HDOBs
	not.b	Screen_flag
	subq.b	#1,Pointer_frozen
	rts

;*****************************************************************************
; [ Clear a screen ]
;   IN : a0 - Pointer to screen (.l)
; All registers are restored
;*****************************************************************************
Clear_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Screen_size(a0),a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.w	#Screen_size/48-1,d7
.Loop:	movem.l	d0-d6/a1-a5,-(a0)
	dbra	d7,.Loop
	REPT	(Screen_size-Screen_size/48*48)/4	; Rest
	move.l	d0,-(a0)
	ENDR
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Wait for the next vertical blank ]
; All registers are restored
;*****************************************************************************
My_vsync:
	move.l	d0,-(sp)
	move.w	VBL_counter,d0
.Loop:	cmp.w	VBL_counter,d0
	beq.s	.Loop
	move.l	(sp)+,d0
	rts

	SECTION	Fast_BSS,bss
	ds.b	8188			; Stack (see Start_program)
	ds.l	1
Return_value:	ds.l 1
Return_address:	ds.l 1
Stack_pointer:	ds.l 1
CPU_68020_plus:	ds.b 1
System_active:	ds.b 1
VBL_counter:	ds.w 1
Library_dos:	ds.l 1
Library_graphics:	ds.l 1
Console_device_pointer:	ds.l 1
Screen_flag:	ds.b 2
Vertical_screen_offset:	ds.w 1
Last_screen_offset:	ds.w 1
On_screen:	ds.l 1
Off_screen:	ds.l 1
Work_screen:	ds.l 1
Shown_screen:	ds.l 1
Old_VBL:	ds.l 1
Old_ACIA:	ds.l 1
Old_IERA:	ds.b 1
Old_IERB:	ds.b 1
Old_IMRA:	ds.b 1
Old_IMRB:	ds.b 1
Old_VR:	ds.b 1
	even
Screen_buffers:	ds.b 2*Screen_size+256
