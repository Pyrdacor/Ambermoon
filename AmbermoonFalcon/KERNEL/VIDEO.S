; Falcon kernel : video hardware (VIDEL)
; The video mode, the video base. (Replaces VIDEO.S of the ST kernel.)

	SECTION	Program,code

;*****************************************************************************
; [ Switch to the video mode of the game ]
; All registers are restored
; NOTE :
;   - Called by [ Init_system ] while the TOS is active, after the screens
;     were made ([ On_screen ]).
;   - 320 x 200 with 256 colours, all colours black. On an RGB monitor or a
;     TV at 50 Hz (like the PAL Amiga). A VGA monitor has no 50 Hz modes :
;     60 Hz with every line twice, the game runs at 50 Hz with Timer C
;     ([ Tick_timer ], SYSTEM.S). That mode has 240 lines : the VIDEL shows
;     only the middle 200 (VDB / VDE, black above and below).
;*****************************************************************************
Init_video:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	#Physbase,-(sp)		; Save the TOS state
	trap	#XBIOS
	addq.l	#2,sp
	move.l	d0,Old_physbase
	move.w	#Logbase,-(sp)
	trap	#XBIOS
	addq.l	#2,sp
	move.l	d0,Old_logbase
	move.w	#-1,-(sp)			; (-1 : only get the mode)
	move.w	#Vsetmode,-(sp)
	trap	#XBIOS
	addq.l	#4,sp
	move.w	d0,Old_mode
	lea.l	Videl_palette,a0		; The colours of the TOS
	lea.l	Old_palette,a1
	move.w	#256-1,d7
.Save:	move.l	(a0)+,(a1)+
	dbra	d7,.Save
	movem.l	ST_palette_regs,d0-d7
	movem.l	d0-d7,Old_ST_palette
	move.w	#VgetMonitor,-(sp)		; Which monitor ?
	trap	#XBIOS
	addq.l	#2,sp
	move.w	#Mode_BPS8+Mode_PAL,d1	; 320 x 200, 256 colours, 50 Hz
	cmp.w	#Monitor_VGA,d0
	bne.s	.Mode
	move.w	#Mode_BPS8+Mode_VGA+Mode_VERTFLAG,d1	; VGA : 60 Hz, lines twice
	st	Tick_timer
.Mode:	move.w	d1,-(sp)
	move.w	#3,-(sp)
	move.l	On_screen,-(sp)
	move.l	On_screen,-(sp)
	move.w	#Vsetscreen,-(sp)
	trap	#XBIOS
	lea.l	14(sp),sp
	tst.b	Tick_timer		; VGA : 200 of the 240 lines
	beq.s	.Lines_ok
	move.w	Videl_VDE,d0		; (the display in half lines)
	sub.w	Videl_VDB,d0
	ext.l	d0
	divu.w	#12,d0			; (20 of the 240 lines)
	add.w	d0,Videl_VDB
	sub.w	d0,Videl_VDE
.Lines_ok:	lea.l	Videl_palette,a0		; Black
	move.w	#256-1,d7
.Black:	clr.l	(a0)+
	dbra	d7,.Black
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Restore the video mode of the TOS ]
; All registers are restored
;*****************************************************************************
Exit_video:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	Old_mode,-(sp)
	move.w	#3,-(sp)
	move.l	Old_physbase,-(sp)
	move.l	Old_logbase,-(sp)
	move.w	#Vsetscreen,-(sp)
	trap	#XBIOS
	lea.l	14(sp),sp
	lea.l	Old_palette,a0
	lea.l	Videl_palette,a1
	move.w	#256-1,d7
.Loop:	move.l	(a0)+,(a1)+
	dbra	d7,.Loop
	movem.l	Old_ST_palette,d0-d7
	movem.l	d0-d7,ST_palette_regs
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
	move.l	a0,d0			; (the low byte after the others)
	move.b	d0,Video_base_low
	move.l	(sp)+,d0
	rts

	SECTION	Fast_BSS,bss
Old_physbase:	ds.l 1
Old_logbase:	ds.l 1
Old_mode:	ds.w 1
Old_ST_palette:	ds.w 16
Old_palette:	ds.l 256
