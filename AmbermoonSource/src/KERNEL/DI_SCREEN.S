; Diagnostic screen
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Initialize the diagnostic screen ]
; All registers are restored
;*****************************************************************************
Init_diagnostic_screen:
	move.l	a0,-(sp)
	move.l	On_screen,a0
	jsr	Clear_screen
	move.l	a0,Work_screen
	jsr	DI_Home
	lea.l	Default_PA,a0
	jsr	Push_PA
	lea.l	Default_CA,a0
	jsr	Push_CA
	move.w	#31,Ink_colour
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Wait for the user and leave the diagnostic screen ]
;*****************************************************************************
Exit_diagnostic_screen:
	jsr	Pop_PA
	jsr	Pop_CA
	jsr	Wait_4_click
	jmp	Update_screen

;*****************************************************************************
; [ Print a list of texts on the diagnostic screen ]
;   IN : a1 - Pointer to text list (.l)
; NOTE (disassembly) :
;   This prints lines of text. Each
;   line must be terminated by 00.
;   Empty lines only have a single 00.
;   The end marker is FF. The text is
;   scrolled if necessary and for the
;   click is waited. There is also a
;   wait for a click at the end which
;   closes the window.
;*****************************************************************************
DI_Print_text:
	movem.l	d0/a0/a1,-(sp)
.Loop:
	cmpi.b	#-1,(a1)
	beq.s	.Exit
	jsr	DI_Print
	jsr	DI_CR
	move.l	a1,a0
	jsr	Strlen
	lea.l	1(a1,d0.w),a1
	bra.s	.Loop
.Exit:
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Print a text on the diagnostic screen ]
;   IN : a0 - Pointer to text (.l)
;*****************************************************************************
DI_Print:
	movem.l	d0/d1/d7/a0,-(sp)
	move.l	a1,a0
	jsr	Strlen
	move.w	d0,d7
	move.w	DI_X,d0
	move.w	DI_Y,d1
	mulu.w	#6,d0
	mulu.w	#7,d1
	jsr	Put_text_line
	add.w	d7,DI_X
	movem.l	(sp)+,d0/d1/d7/a0
	rts
	movem.l	d0/d1/d6/d7/a0,-(sp)
	andi.w	#$ff,d0
	lea.l	Hull_number,a0
	moveq.l	#32,d6
	moveq.l	#3,d7
	jsr	DecR_convert
	lea.l	Hull_number,a0
	move.w	DI_X,d0
	move.w	DI_Y,d1
	mulu.w	#6,d0
	mulu.w	#7,d1
	jsr	Put_text_line
	addq.w	#4,DI_X
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

;*****************************************************************************
; [ Print a 5 digit number on the diagnostic screen ]
;   IN : d0 - Number (.w)
; All registers are restored
;*****************************************************************************
DI_Print_number:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	andi.l	#$ffff,d0
	lea.l	Hull_number,a0
	moveq.l	#32,d6
	moveq.l	#5,d7
	jsr	DecR_convert
	lea.l	Hull_number,a0
	move.w	DI_X,d0
	move.w	DI_Y,d1
	mulu.w	#6,d0
	mulu.w	#7,d1
	jsr	Put_text_line
	addq.w	#6,DI_X
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

;*****************************************************************************
; [ Print a 7 digit number on the diagnostic screen ]
;   IN : d0 - Number (.l)
; All registers are restored
;*****************************************************************************
DI_Print_long:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	lea.l	Hull_number,a0
	moveq.l	#32,d6
	moveq.l	#7,d7
	jsr	DecR_convert
	lea.l	Hull_number,a0
	move.w	DI_X,d0
	move.w	DI_Y,d1
	mulu.w	#6,d0
	mulu.w	#7,d1
	jsr	Put_text_line
	addq.w	#8,DI_X
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

;*****************************************************************************
; [ Next line on the diagnostic screen ]
; NOTE :
;   - Waits for a click when the screen is full.
;*****************************************************************************
DI_CR:
	move.l	a0,-(sp)
	clr.w	DI_X
	addq.w	#1,DI_Y
	cmpi.w	#28,DI_Y
	bmi.s	.Exit
	clr.w	DI_Y
	jsr	Wait_4_click
	move.l	Work_screen,a0
	jsr	Clear_screen
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Move the diagnostic screen cursor home ]
;*****************************************************************************
DI_Home:
	clr.w	DI_X
	clr.w	DI_Y
	rts


	SECTION	Fast_BSS,bss
DI_X:
	ds.w	1
DI_Y:
	ds.w	1
