; ST kernel : video hardware (Shifter)
; The video mode, the video base. (The Falcon version has its own VIDEO.S.)

	SECTION	Program,code

;*****************************************************************************
; [ Switch to the video mode of the game ]
; All registers are restored
; NOTE :
;   - Called by [ Init_system ] while the TOS is active, after the screens
;     were made ([ On_screen ]).
;   - Low resolution, 50 Hz (like the PAL Amiga), all colours black.
;*****************************************************************************
Init_video:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	#Getrez,-(sp)		; Save the TOS state
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
	clr.w	-(sp)			; Low resolution
	move.l	On_screen,-(sp)
	move.l	On_screen,-(sp)
	move.w	#Setscreen,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	move.b	Video_sync,Old_sync		; 50 Hz
	bset	#1,Video_sync
	lea.l	Palette_regs,a0		; Black
	moveq.l	#8-1,d7
.Loop:	clr.l	(a0)+
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Restore the video mode of the TOS ]
; All registers are restored
;*****************************************************************************
Exit_video:
	movem.l	d0-d7/a0-a2,-(sp)
	movem.l	Old_palette,d0-d7
	movem.l	d0-d7,Palette_regs
	move.b	Old_sync,Video_sync
	move.w	Old_rez,-(sp)
	move.l	Old_physbase,-(sp)
	move.l	Old_logbase,-(sp)
	move.w	#Setscreen,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Set the video base ]
;   IN : a0 - Pointer to screen (aligned to 256 bytes) (.l)
; All registers are restored
; NOTE :
;   - Latched at the start of the next frame.
;*****************************************************************************
Set_video_base:
	move.l	d0,-(sp)
	move.l	a0,d0
	lsr.l	#8,d0
	move.b	d0,Video_base_mid
	lsr.w	#8,d0
	move.b	d0,Video_base_high
	move.l	(sp)+,d0
	rts

	SECTION	Fast_BSS,bss
Old_rez:	ds.w 1
Old_physbase:	ds.l 1
Old_logbase:	ds.l 1
Old_palette:	ds.w 16
Old_sync:	ds.b 1
	even
