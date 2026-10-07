; Windows routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 7-9-1992

	XREF	Window_icons

; These are the offsets for the Window structure
	rsreset
Window_X:	rs.w 1
Window_Y:	rs.w 1
Window_width:	rs.w 1
Window_height:	rs.w 1
Window_area:	rs.w PA_data_size
Window_tree:	rs.l 1
Window_background:          rs.b 0

	XDEF	Open_window
	XDEF	Close_window
	XDEF	Reset_windows

	XREF	Window_icons

	SECTION	Program,code
;*****************************************************************************
; [ Open a window ]
;   IN : d0 - Top left X-coordinate (on trunc boundary) (.w)
;        d1 - Top left Y-coordinate (.w)
;        d2 - Width of window (in truncs) (.w)
;        d3 - Height of window (in truncs) (.w)
;        a0 - Pointer to object tree / 0 (.l)
; All registers are restored
; NOTE :
;  - a PA and MA are automatically generated and pushed.
;  - an object tree is automatically translated and pushed (if not zero).
;*****************************************************************************
Open_window:
	movem.l	d0-d7/a0-a6,-(sp)
; --------- Allocate memory for window data -------
	move.l	d0,-(sp)
	move.w	d2,d0			; Calculate size of	window
	mulu.w	d3,d0			; data
	mulu.w	#16*2*Screen_depth,d0
	addi.l	#Window_background,d0
	jsr	Allocate_CHIP		; Make buffer
	movea.l	Window_Sp,a1		; Push memory handle
	addq.l	#1,a1
	move.b	d0,(a1)
	move.l	a1,Window_Sp
	jsr	Claim_pointer		; Get actual address
	move.l	d0,a4
	move.l	(sp)+,d0
; --------- Insert window data --------------------
	move.w	d0,Window_X(a4)		; Insert input
	move.w	d1,Window_Y(a4)
	move.w	d2,Window_width(a4)
	move.w	d3,Window_height(a4)
	move.l	a0,Window_tree(a4)
	move.w	d0,d4			; Calculate window area
	addi.w	#16,d4
	move.w	d4,Window_area+PA_X1(a4)
	move.w	d2,d5
	subq.w	#2,d5
	lsl.w	#4,d5
	add.w	d5,d4
	subq.w	#1,d4
	move.w	d4,Window_area+PA_X2(a4)
	move.w	d1,d4
	addi.w	#16,d4
	move.w	d4,Window_area+PA_Y1(a4)
	move.w	d3,d5
	subq.w	#2,d5
	lsl.w	#4,d5
	add.w	d5,d4
	subq.w	#1,d4
	move.w	d4,Window_area+PA_Y2(a4)
	move.w	#Default_ink,Window_area+PA_Ink(a4)
	move.w	#Default_shadow,Window_area+PA_Shadow(a4)
	move.w	#Window_colour,Window_area+PA_Paper(a4)
; --------- Save background -----------------------
	lea.l	Window_background(a4),a0
	moveq.l	#Screen_depth,d5
	move.w	d2,d6
	move.w	d3,d7
	lsl.w	#4,d7
	jsr	Get_block
; --------- Draw border of window -----------------
	subq.w	#2,d2			; Adjust counters
	subq.w	#2,d3
	moveq.l	#0,d4			; Top-left corner
	jsr	Put_window_part
	moveq.l	#1,d4			; Left column
	move.w	d3,d7
	bra.s	.Entry1
.Loop1:	jsr	Put_window_part
.Entry1:	addi.w	#16,d1
	dbra	d7,.Loop1
	moveq.l	#2,d4			; Bottom-left corner
	jsr	Put_window_part
	moveq.l	#4,d4			; Bottom row
	move.w	d2,d7
	bra.s	.Entry2
.Loop2:	jsr	Put_window_part
.Entry2:	addi.w	#16,d0
	dbra	d7,.Loop2
	moveq.l	#7,d4			; Bottom-right corner
	jsr	Put_window_part
	moveq.l	#6,d4			; Right column
	move.w	d3,d7
	bra.s	.Entry3
.Loop3:	jsr	Put_window_part
.Entry3:	subi.w	#16,d1
	dbra	d7,.Loop3
	moveq.l	#5,d4			; Top-right corner
	jsr	Put_window_part
	moveq.l	#3,d4			; Top row
	move.w	d2,d7
	bra.s	.Entry4
.Loop4:	jsr	Put_window_part
.Entry4:	subi.w	#16,d0
	dbra	d7,.Loop4
; --------- Fill window ---------------------------
	move.w	Window_area+PA_X1(a4),d0	; Get first coordinate pair
	move.w	Window_area+PA_Y1(a4),d1
	move.w	Window_area+PA_X2(a4),d2	; Get second coordinate pair
	move.w	Window_area+PA_Y2(a4),d3
	move.w	#Window_colour,d4
	jsr	Draw_box
;	jsr	Update_screen
; --------- Various installations -----------------
	lea.l	Window_area(a4),a0		; Push MA, PA & CA
	jsr	Push_MA
	jsr	Push_PA
	;jsr	Push_CA
	move.l	Window_tree(a4),d0		; Translate & push tree
	beq.s	.Zero			;  (if any)
	movea.l	d0,a0
	move.w	Window_X(a4),d0
	move.w	Window_Y(a4),d1
	addi.w	#16,d0
	addi.w	#16,d1
	move.w	d0,(a0)
	move.w	d1,2(a0)
	jsr	Push_Tree
.Zero:	move.l	Window_Sp,a0		; Free pointer
	move.b	(a0),d0
	jsr	Free_pointer
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Put part of a window on the screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Part number (0-8) (.w)
; All registers are restored
Put_window_part:
	movem.l	d3-d5/a0,-(sp)
	lea.l	Window_icons,a0
	mulu.w	#3*2*16,d4
	add.l	d4,a0
	moveq.l	#24,d4
	moveq.l	#3,d5
	jsr	Put_masked_icon
	movem.l	(sp)+,d3-d5/a0
	rts

;*****************************************************************************
; [ Close	window ]
; All registers are	restored
;*****************************************************************************
Close_window:
	movem.l	d0/d1/d5-d7/a0/a4,-(sp)
	movea.l	Window_Sp,a0		; Pop memory handle
	move.b	(a0),d0
	subq.l	#1,a0
	move.l	a0,Window_Sp
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Get actual address
	move.l	d0,a4
; --------- Various de-installations --------------
	Pop	MA			; Pop MA, PA & CA
	Pop	PA
	;Pop	CA
	tst.l	Window_tree(a4)		; Remove object tree
	beq.s	.Zero			;  (if any)
	Pop	Tree
; --------- Restore background --------------------
.Zero:	lea.l	Window_background(a4),a0
	move.w	Window_X(a4),d0
	move.w	Window_Y(a4),d1
	moveq.l	#Screen_depth,d5
	move.w	Window_width(a4),d6
	move.w	Window_height(a4),d7
	lsl.w	#4,d7
	jsr	Put_unmasked_block
	jsr	Update_screen
; --------- Free memory ---------------------------
	move.w	(sp)+,d0
	jsr	Free_pointer
	jsr	Free_memory
	movem.l	(sp)+,d0/d1/d5-d7/a0/a4
	rts

;*****************************************************************************
; [ Reset all windows ]
; All registers are	restored
;*****************************************************************************
Reset_windows:
	movem.l	d0/a0/a1,-(sp)
	move.l	Window_Sp,a0
	lea.l	Window_stack,a1
.Again:	cmp.l	a1,a0			; Back at the start ?
	bmi.s	.End
	move.b	(a0),d0			; Pop memory handle
	subq.l	#1,a0
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Get actual address
	move.l	d0,a0
	Pop	MA			; Pop MA, PA & CA
	Pop	PA
;	Pop	CA
	tst.l	Window_tree(a0)		; Remove object tree
	beq.s	.Zero			;  (if any)
	Pop	Tree
.Zero:	move.w	(sp)+,d0			; Free memory
	jsr	Free_pointer
	jsr	Free_memory
	bra.s	.Again
.End:	move.l	a0,Window_Sp		; Store sp
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Window_Sp:	dc.l Window_stack

	SECTION	Fast_BSS,bss
Window_stack:	ds.b Max_windows
	even
