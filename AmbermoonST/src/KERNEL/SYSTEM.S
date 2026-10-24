; Taking over and restoring the system, screens, vertical blank (Atari ST)
; Replaces KERNEL/SYSTEM.S of the Amiga version.
; The routine names and parameters are the same as in the Amiga version.

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the system ]
; All registers are restored
; NOTE :
;   - Must be called in supervisor mode while TOS is still active.
;   - Switches to low resolution, installs the VBL, Timer B (raster
;     interrupts) and ACIA (keyboard & mouse) handlers.
;*****************************************************************************
Init_system:
	movem.l	d0-d7/a0-a6,-(sp)
; ---------- Save TOS state -----------------------
	move.w	#Getrez,-(sp)
	trap	#XBIOS
	addq.l	#2,sp
	move.w	d0,Old_rez
	move.w	#Physbase,-(sp)
	trap	#XBIOS
	addq.l	#2,sp
	move.l	d0,Old_physbase
	move.w	#Logbase,-(sp)
	trap	#XBIOS
	addq.l	#2,sp
	move.l	d0,Old_logbase
	movem.l	Palette_regs,d0-d7
	movem.l	d0-d7,Old_palette
	dc.w	$a00a			; Line-A : hide mouse
; ---------- Screens ------------------------------
	jsr	Init_screens
	clr.w	-(sp)			; Low resolution
	move.l	On_screen,-(sp)
	move.l	On_screen,-(sp)
	move.w	#Setscreen,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	lea.l	Palette_regs,a0		; Black
	moveq.l	#8-1,d7
.Loop:	clr.l	(a0)+
	dbra	d7,.Loop
	jsr	Reset_CA_stack
	jsr	Init_raster
; ---------- Take over interrupts -----------------
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.l	Vec_VBL.w,Old_VBL
	move.l	Vec_ACIA.w,Old_ACIA
	move.l	Vec_Timer_B.w,Old_Timer_B
	move.b	MFP_IERA,Old_IERA
	move.b	MFP_IERB,Old_IERB
	move.b	MFP_IMRA,Old_IMRA
	move.b	MFP_IMRB,Old_IMRB
	move.b	MFP_TBCR,Old_TBCR
	move.b	MFP_VR,Old_VR
	clr.b	MFP_TBCR
	move.l	#Vbl_interrupt,Vec_VBL.w
	move.l	#ACIA_interrupt,Vec_ACIA.w
	move.l	#Timer_B_interrupt,Vec_Timer_B.w
	move.b	#$01,MFP_IERA		; Only Timer B
	move.b	#$01,MFP_IMRA
	move.b	#$40,MFP_IERB		; Only ACIA (no Timer C)
	move.b	#$40,MFP_IMRB
	bset	#3,MFP_VR			; Software end of interrupt
	move.w	(sp)+,sr
	jsr	My_vsync
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Restore the system ]
; All registers are restored
;*****************************************************************************
Restore_system:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	sr,-(sp)
	move.w	#$2700,sr
	clr.b	MFP_TBCR
	move.l	Old_VBL,Vec_VBL.w
	move.l	Old_ACIA,Vec_ACIA.w
	move.l	Old_Timer_B,Vec_Timer_B.w
	move.b	Old_IERA,MFP_IERA
	move.b	Old_IERB,MFP_IERB
	move.b	Old_IMRA,MFP_IMRA
	move.b	Old_IMRB,MFP_IMRB
	move.b	Old_VR,MFP_VR
	move.b	Old_TBCR,MFP_TBCR
	move.w	(sp)+,sr
	movem.l	Old_palette,d0-d7
	movem.l	d0-d7,Palette_regs
	move.w	Old_rez,-(sp)
	move.l	Old_physbase,-(sp)
	move.l	Old_logbase,-(sp)
	move.w	#Setscreen,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	dc.w	$a009			; Line-A : show mouse
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Vertical blank interrupt ]
;*****************************************************************************
Vbl_interrupt:
	movem.l	d0-d7/a0-a6,-(sp)
	addq.w	#1,VBL_counter
	jsr	Raster_VBL
	jsr	Vbl_handler
	movem.l	(sp)+,d0-d7/a0-a6
	rte

;*****************************************************************************
; [ Vertical blank handler ]
; Called every frame by the vertical blank interrupt.
;*****************************************************************************
Vbl_handler:
	jsr	Random
	move.l	VblQ_ptr_ST,d0		; Frame hook of the program
	beq.s	.Exit
	move.l	d0,a0
	jsr	(a0)
.Exit:	rts

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
	add.l	#ST_screen_size,a1
	move.l	a0,On_screen
	move.l	a1,Off_screen
	move.l	a1,Work_screen
	move.l	a0,Shown_screen
	jsr	Clear_screen
	move.l	a1,a0
	jsr	Clear_screen
	clr.w	Vertical_screen_offset
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Show the work screen ]
; The mouse pointer is drawn, the screens are switched and the new work
; screen is updated with the contents of the shown screen.
; All registers are restored
;*****************************************************************************
Update_screen:
	jsr	Switch_screens
	jmp	Copy_screen

;*****************************************************************************
; [ Switch screens ]
; Like [ Update_screen ], but the new work screen is not updated.
; All registers are restored
;*****************************************************************************
Switch_screens:
	move.l	a0,-(sp)
	jsr	Draw_mouse_pointer
	move.l	Off_screen,a0
	move.l	On_screen,Off_screen
	move.l	a0,On_screen
	jsr	Show_screen
	move.l	Off_screen,Work_screen
	not.b	Screen_flag
	jsr	Erase_mouse_pointer
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
	move.l	d0,-(sp)
	move.l	a0,Shown_screen
	move.l	a0,d0
	lsr.l	#8,d0
	move.b	d0,Video_base_mid
	lsr.w	#8,d0
	move.b	d0,Video_base_high
	move.l	(sp)+,d0
	jmp	My_vsync

;*****************************************************************************
; [ Copy the shown screen to the work screen ]
; All registers are restored
;*****************************************************************************
Copy_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	On_screen,a0
	move.l	Off_screen,a1
	move.w	#ST_screen_size/48-1,d7
.Loop:	movem.l	(a0)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a1)
	lea.l	48(a1),a1
	dbra	d7,.Loop
	movem.l	(a0)+,d0-d7		; Rest (32000 = 666 * 48 + 32)
	movem.l	d0-d7,(a1)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Clear a screen ]
;   IN : a0 - Pointer to screen (.l)
; All registers are restored
;*****************************************************************************
Clear_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	ST_screen_size(a0),a0
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
	move.w	#ST_screen_size/48-1,d7
.Loop:	movem.l	d0-d6/a1-a5,-(a0)
	dbra	d7,.Loop
	movem.l	d0-d6/a1,-(a0)		; Rest (32 bytes)
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
Old_rez:	ds.w 1
Old_physbase:	ds.l 1
Old_logbase:	ds.l 1
Old_palette:	ds.w 16
Old_VBL:	ds.l 1
Old_ACIA:	ds.l 1
Old_Timer_B:	ds.l 1
Old_IERA:	ds.b 1
Old_IERB:	ds.b 1
Old_IMRA:	ds.b 1
Old_IMRB:	ds.b 1
Old_TBCR:	ds.b 1
Old_VR:	ds.b 1
Screen_flag:	ds.b 1
	even
VBL_counter:	ds.w 1
VblQ_ptr_ST:	ds.l 1			; Frame hook (called in the VBL)
On_screen:	ds.l 1
Off_screen:	ds.l 1
Work_screen:	ds.l 1
Shown_screen:	ds.l 1
Vertical_screen_offset:	ds.w 1
Screen_buffers:	ds.b 2*ST_screen_size+256
