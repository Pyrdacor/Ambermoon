; Fade routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 5-9-1992

	XREF	Main_RL

	XDEF	Fade_in_all
	XDEF	Fade_out_all
	XDEF	Fade_in_bottom
	XDEF	Fade_out_bottom
	XDEF	Reset_current_RL
	XDEF	Dim_colours
	XDEF	Faded_flag

	SECTION	Program,code
;***************************************************************************
; [ Fade top + bottom in ]
; All registers are restored
; NOTE :
;  - This routine assumes the current module's [ Raster_list_ptr ] entry
;    has been set.
;***************************************************************************
Fade_in_all:
	movem.l	d0-d2/a0,-(sp)
	move.l	Module_Sp,d0		; Get RL address
	beq.s	.Exit
	move.l	d0,a0
	move.l	Raster_list_ptr(a0),d0
	beq.s	.Exit
	move.l	d0,a0
	jsr	Wait_4_fade		; Wait
	st	Faded_flag
	move.w	#Start_fade_in,d0		; Do
	moveq.l	#0,d1
	move.w	#Screen_height-1,d2
	jsr	Set_fade
	jsr	My_vsync			; Wait for effect
	jsr	Update_screen		; Show screen
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;***************************************************************************
; [ Fade top + bottom out ]
; All registers are restored
;***************************************************************************
Fade_out_all:
	movem.l	d0-d2/a0,-(sp)
	jsr	Wait_4_fade		; Wait
	move.w	#Fade_out,d0		; Do
	moveq.l	#0,d1
	move.w	#Screen_height-1,d2
	jsr	Set_fade
	jsr	Wait_4_fade		; Wait
	sf	Faded_flag
	move.l	Off_screen,a0		; Clear screen
	jsr	Clear_screen
	jsr	Update_screen
	move.w	#Set_new,d0		; Set new palette
	moveq.l	#-1,d1
	move.w	#Screen_height-1,d2
	lea.l	Main_RL,a0
	jsr	Set_fade
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;***************************************************************************
; [ Fade bottom of screen in ]
; All registers are restored
;***************************************************************************
Fade_in_bottom:
	movem.l	d0-d2/a0,-(sp)
	move.l	Module_Sp,d0		; Get RL address
	beq.s	.Exit
	move.l	d0,a0
	move.l	Raster_list_ptr(a0),d0
	beq.s	.Exit
	move.l	d0,a0
	jsr	Wait_4_fade		; Wait
	st	Faded_flag
	move.w	#Start_fade_in,d0		; Fade in
	move.w	#Middle_Y,d1
	move.w	#Screen_height-1,d2
	jsr	Set_fade
	jsr	My_vsync			; Wait for effect
	jsr	Update_screen		; Show screen
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;***************************************************************************
; [ Fade bottom of screen out ]
; All registers are restored
;***************************************************************************
Fade_out_bottom:
	movem.l	d0-d4/a0,-(sp)
	jsr	Wait_4_fade		; Wait
	move.w	#Fade_out,d0		; Fade out
	move.w	#Middle_Y,d1
	move.w	#Screen_height-1,d2
	jsr	Set_fade
	jsr	Wait_4_fade		; Wait
	sf	Faded_flag
	moveq.l	#0,d0			; Clear bottom of screen
	move.w	#Middle_Y,d1
	move.w	#319,d2
	move.w	#199,d3
	moveq.l	#0,d4
	jsr	Draw_box
	jsr	Update_screen
	move.w	#Set_new,d0		; Set new palette
	moveq.l	#-1,d1
	move.w	#Screen_height-1,d2
	lea.l	Main_RL,a0
	jsr	Set_fade
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

;***************************************************************************
; [ Reset current RL ]
; All registers are restored
;***************************************************************************
Reset_current_RL:
	movem.l	d0-d2/a0,-(sp)
	move.l	Module_Sp,d0		; Get RL address
	beq.s	.Exit
	move.l	d0,a0
	move.l	Raster_list_ptr(a0),d0
	beq.s	.Exit
	move.l	d0,a0
	move.w	#Set_new,d0		; Set new palette
	moveq.l	#-1,d1
	move.w	#Screen_height-1,d2
	jsr	Set_fade
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Dim colour range ]
;   IN : d6 - Number of fade passes (.w)
;        d7 - Number of colours (.w)
;        a0 - Source colours (.l)
;        a1 - Target colours (.l)
;        a2 - Destination (.l)
; All registers are restored
;*****************************************************************************
Dim_colours:
	movem.l	d0-d3/d7/a0-a2,-(sp)
.Loop:	move.w	(a0)+,d0			; Get source & target colour
	move.w	(a1)+,d1
	tst.w	d6			; Fade at all ?
	beq	.Next
; ---------- Do RED -------------------------------
	move.w	#$0f00,d2			; Isolate nibbles
	move.w	d2,d3
	and.w	d0,d2
	and.w	d1,d3
	lsr.w	#8,d2
	lsr.w	#8,d3
	sub.w	d2,d3			; Calculate difference
	beq.s	.R_done
	bpl.s	.R_up
	neg.w	d3			; Clip
	cmp.w	d6,d3
	bmi.s	.R_OK1
	move.w	d6,d3
.R_OK1:	lsl.w	#8,d3			; Fade down
	sub.w	d3,d0
	bra.s	.R_done
.R_up:	cmp.w	d6,d3			; Clip
	bmi.s	.R_OK2
	move.w	d6,d3
.R_OK2:	lsl.w	#8,d3			; Fade up
	add.w	d3,d0
; ---------- Do GREEN -----------------------------
.R_done:	move.w	#$00f0,d2			; Isolate nibbles
	move.w	d2,d3
	and.w	d0,d2
	and.w	d1,d3
	lsr.w	#4,d2
	lsr.w	#4,d3
	sub.w	d2,d3			; Calculate difference
	beq.s	.G_done
	bpl.s	.G_up
	neg.w	d3			; Clip
	cmp.w	d6,d3
	bmi.s	.G_OK1
	move.w	d6,d3
.G_OK1:	lsl.w	#4,d3			; Fade down
	sub.w	d3,d0
	bra.s	.G_done
.G_up:	cmp.w	d6,d3			; Clip
	bmi.s	.G_OK2
	move.w	d6,d3
.G_OK2:	lsl.w	#4,d3			; Fade up
	add.w	d3,d0
; ---------- Do BLUE ------------------------------
.G_done:	move.w	#$000f,d2			; Isolate nibbles
	move.w	d2,d3
	and.w	d0,d2
	and.w	d1,d3
	sub.w	d2,d3			; Calculate difference
	beq.s	.B_done
	bpl.s	.B_up
	neg.w	d3			; Clip
	cmp.w	d6,d3
	bmi.s	.B_OK1
	move.w	d6,d3
.B_OK1:	sub.w	d3,d0			; Fade down
	bra.s	.B_done
.B_up:	cmp.w	d6,d3			; Clip
	bmi.s	.B_OK2
	move.w	d6,d3
.B_OK2:	add.w	d3,d0			; Fade up
.B_done:
.Next:	move.w	d0,(a2)+			; Store new colour
	dbra	d7,.Loop			; Next
.Exit:	movem.l	(sp)+,d0-d3/d7/a0-a2
	rts

;***************************************************************************	
; The DATA & BSS segments	
;***************************************************************************	
	SECTION	Fast_BSS,bss
Faded_flag:	ds.b 1		; 0 = Out , 1 = In
	even
