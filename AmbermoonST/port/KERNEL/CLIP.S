; ST kernel : clip areas, clip masks, lines and pixels
; (common to all screen formats : the screen is 20 chunks of 16 pixels wide;
; the drawing is in GRAPHICS.S)

	SECTION	Program,code

;*****************************************************************************
; [ Clip area stack ]
;*****************************************************************************
; [ Push a clip area on the stack ]
;   IN : a0 - Pointer to CA (.l)
; All registers are restored
Push_CA:
	move.l	a1,-(sp)
	move.l	CA_Sp,a1
	addq.l	#4,a1
	cmp.l	#CA_stack_end,a1
	beq.s	.Exit
	move.l	a0,(a1)
	move.l	a1,CA_Sp
.Exit:
	move.l	(sp)+,a1
	rts

; [ Pop a clip area from the stack ]
; All registers are restored
Pop_CA:
	move.l	a0,-(sp)
	move.l	CA_Sp,a0
	cmp.l	#CA_Sp+4,a0
	beq.s	.Exit
	subq.l	#4,a0
	move.l	a0,CA_Sp
.Exit:
	move.l	(sp)+,a0
	rts

; [ Reset the clip area stack ]
; All registers are restored
Reset_CA_stack:
	move.l	a0,-(sp)
	lea.l	CA_Sp+4,a0
	move.l	a0,CA_Sp
	move.l	#Default_CA,(a0)
	move.l	(sp)+,a0
	rts

; [ Make the clip masks of the 20 chunks of a line ]
;   IN : current CA
; All registers are restored
; NOTE :
;   - [ Clip_masks ] : per chunk the visible pixels, [ Clip_Y1 ] / [ Clip_Y2 ].
Make_clip_masks:
	movem.l	d0-d5/d7/a0/a1,-(sp)
	move.l	CA_Sp,a0
	move.l	(a0),a0
	move.w	CA_Y1(a0),Clip_Y1
	move.w	CA_Y2(a0),Clip_Y2
	move.w	CA_X1(a0),d0
	move.w	CA_X2(a0),d1
	cmp.w	Clip_X1_masks,d0		; Masks of these edges made already ?
	bne.s	.New
	cmp.w	Clip_X2_masks,d1
	beq.s	.Done
.New:	move.w	d0,Clip_X1_masks
	move.w	d1,Clip_X2_masks
	lea.l	Clip_masks,a1
	moveq.l	#0,d2			; Left X of the chunk
	moveq.l	#20-1,d7
.Loop:	moveq.l	#0,d3			; Invisible ?
	move.w	d2,d4
	addi.w	#15,d4
	cmp.w	d0,d4
	blt.s	.Store
	cmp.w	d1,d2
	bgt.s	.Store
	moveq.l	#-1,d3			; Left edge inside ?
	move.w	d0,d4
	sub.w	d2,d4
	ble.s	.No_left
	lsr.w	d4,d3
.No_left:	move.w	d1,d4			; Right edge inside ?
	sub.w	d2,d4
	cmp.w	#15,d4
	bge.s	.Store
	addq.w	#1,d4			; (visible pixels from the left)
	moveq.l	#-1,d5
	lsr.w	d4,d5
	not.w	d5
	and.w	d5,d3
.Store:	move.w	d3,(a1)+
	addi.w	#16,d2
	dbra	d7,.Loop
.Done:	movem.l	(sp)+,d0-d5/d7/a0/a1
	rts

;*****************************************************************************
; [ Draw a horizontal / vertical line, plot a pixel ]
;*****************************************************************************
; [ Draw a horizontal line ]
;   IN : d0 - Left X, d1 - Y, d2 - Right X, d4 - Colour (.w)
Draw_hline:
	move.l	d3,-(sp)
	move.w	d1,d3
	jsr	Draw_box
	move.l	(sp)+,d3
	rts

; [ Draw a vertical line ]
;   IN : d0 - X, d1 - Top Y, d3 - Bottom Y, d4 - Colour (.w)
Draw_vline:
	move.l	d2,-(sp)
	move.w	d0,d2
	jsr	Draw_box
	move.l	(sp)+,d2
	rts

; [ Plot a pixel ]
;   IN : d0 - X, d1 - Y, d4 - Colour (.w)
Plot_pixel:
	movem.l	d2/d3,-(sp)
	move.w	d0,d2
	move.w	d1,d3
	jsr	Draw_box
	movem.l	(sp)+,d2/d3
	rts

	SECTION	Fast_DATA,data
Clip_X1_masks:	dc.w -1			; (the edges of Clip_masks : none yet)
Clip_X2_masks:	dc.w -1
Default_CA:
	dc.w	0		; Rect.Left
	dc.w	$13f		; Rect.Right
	dc.w	0		; Rect.Top
	dc.w	$c7		; Rect.Bottom

	SECTION	Fast_BSS,bss
CA_Sp:	ds.b 52
CA_stack_end:
Pixel_buffer:	ds.b 16			; (HULL/EFFECTS.S)
Clip_masks:	ds.w 20
Clip_Y1:	ds.w 1
Clip_Y2:	ds.w 1
