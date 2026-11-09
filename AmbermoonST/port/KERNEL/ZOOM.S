; ST kernel - the zoom of the combat monsters (KERNEL/ZOOM.S of the Amiga
; version draws with the blitter, column by column; the Falcon version :
; AmbermoonFalcon/KERNEL/ZOOM.S).
;
; The graphics of the monsters are ST chunks (5 planes : port/tools/port_gfx.py,
; per line and 16 pixels the mask and 4 planes). The visible part of the
; zoomed graphic (clipped against the current clip area) is made in
; [ Zoom_buffer ] as ST chunks (every target pixel is the source pixel at
; target * source size / target size, mirrored if wanted), then
; [ Put_masked_block ] or [ Put_masked_silhouette ] draws it with 5 planes
; (the chunks as they are).

	SECTION	Program,code

;*****************************************************************************
; [ Draw a zoomed graphic ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d3 - Mirror (bit 0 : X, bit 1 : Y) (.w)
;        d4 - Source width (.w)
;        d5 - Source height (.w)
;        d6 - New width (.w)
;        d7 - New height (.w)
;        a0 - Pointer to graphics (5 planes : ST chunks) (.l)
; All registers are restored
;*****************************************************************************
Draw_zoom_shape:
	move.w	#-1,Zoom_colour
	bra.s	Zoom_graphic

;*****************************************************************************
; [ Draw a zoomed silhouette ]
;   IN : like [ Draw_zoom_shape ], d2 - Colour (.w)
; All registers are restored
;*****************************************************************************
Draw_zoom_silhouette:
	move.w	d2,Zoom_colour

; [ Zoom & draw ] (see above)
Zoom_graphic:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	d4			; Anything ?
	ble	.Exit
	tst.w	d5
	ble	.Exit
	tst.w	d6
	ble	.Exit
	tst.w	d7
	ble	.Exit
	move.w	d4,Zoom_source_width
	move.w	d5,Zoom_source_height
	move.w	d6,Zoom_target_width
	move.w	d7,Zoom_target_height
	btst	#0,d3
	sne	Zoom_mirror_X
	btst	#1,d3
	sne	Zoom_mirror_Y
	move.l	a0,Zoom_gfx_ptr
; ---------- Clip ---------------------------------
	move.l	CA_Sp,a1			; Current clip area
	move.l	(a1),a1
	move.w	CA_X1(a1),d2		; Left : first visible column
	sub.w	d0,d2
	bpl.s	.Left
	moveq.l	#0,d2
.Left:	move.w	CA_X2(a1),d3		; Right : last visible column + 1
	sub.w	d0,d3
	addq.w	#1,d3
	cmp.w	d6,d3
	ble.s	.Right
	move.w	d6,d3
.Right:	sub.w	d2,d3			; Visible width
	ble	.Exit
	cmp.w	#Zoom_max_width,d3
	ble.s	.Width_ok
	move.w	#Zoom_max_width,d3
.Width_ok:	move.w	d2,Zoom_first_column
	move.w	d3,Zoom_visible_width
	add.w	d2,d0
	move.w	d0,Zoom_X
	move.w	CA_Y1(a1),d2		; Top : first visible line
	sub.w	d1,d2
	bpl.s	.Top
	moveq.l	#0,d2
.Top:	move.w	CA_Y2(a1),d3		; Bottom : last visible line + 1
	sub.w	d1,d3
	addq.w	#1,d3
	cmp.w	d7,d3
	ble.s	.Bottom
	move.w	d7,d3
.Bottom:	sub.w	d2,d3			; Visible height
	ble	.Exit
	cmp.w	#Zoom_max_height,d3
	ble.s	.Height_ok
	move.w	#Zoom_max_height,d3
.Height_ok:	move.w	d2,Zoom_line
	move.w	d3,Zoom_visible_height
	add.w	d2,d1
	move.w	d1,Zoom_Y
; ---------- Columns : source chunk & bit ---------
	lea.l	Zoom_X_table,a2
	move.w	Zoom_first_column,d0
	move.w	Zoom_visible_width,d7
	subq.w	#1,d7
.Column:	move.w	d0,d1			; Source X
	mulu.w	Zoom_source_width,d1
	divu.w	Zoom_target_width,d1
	tst.b	Zoom_mirror_X
	beq.s	.Not_mirrored_X
	neg.w	d1
	add.w	Zoom_source_width,d1
	subq.w	#1,d1
.Not_mirrored_X:
	move.w	d1,d2			; Offset of the chunk
	lsr.w	#4,d2
	mulu.w	#10,d2
	move.w	d2,(a2)+
	andi.w	#15,d1			; Bit
	move.w	#$8000,d2
	lsr.w	d1,d2
	move.w	d2,(a2)+
	addq.w	#1,d0
	dbra	d7,.Column
; ---------- Lines --------------------------------
	move.w	Zoom_source_width,d0	; Bytes per source line
	addi.w	#15,d0
	lsr.w	#4,d0
	mulu.w	#10,d0
	move.w	d0,Zoom_source_bpl
	move.w	Zoom_visible_width,d0	; Chunks per buffer line
	addi.w	#15,d0
	lsr.w	#4,d0
	move.w	d0,Zoom_chunks
	mulu.w	#10,d0
	move.w	d0,Zoom_buffer_bpl
	lea.l	Zoom_buffer,a1
	move.w	#-1,Zoom_previous_line
	move.w	Zoom_visible_height,Zoom_lines_left
.Line:	move.w	Zoom_line,d0		; Source Y
	mulu.w	Zoom_source_height,d0
	divu.w	Zoom_target_height,d0
	tst.b	Zoom_mirror_Y
	beq.s	.Not_mirrored_Y
	neg.w	d0
	add.w	Zoom_source_height,d0
	subq.w	#1,d0
.Not_mirrored_Y:
	cmp.w	Zoom_previous_line,d0	; The same source line ?
	bne.s	.New
	move.l	a1,a4			; Yes -> copy the buffer line
	sub.w	Zoom_buffer_bpl,a4
	move.w	Zoom_chunks,d7
	subq.w	#1,d7
.Copy:	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	dbra	d7,.Copy
	bra	.Next_line
.New:	move.w	d0,Zoom_previous_line	; No
	mulu.w	Zoom_source_bpl,d0		; Source line
	move.l	Zoom_gfx_ptr,a3
	add.l	d0,a3
	lea.l	Zoom_X_table,a2
	move.w	Zoom_visible_width,d7
	subq.w	#1,d7
	move.l	#$8000,d0			; (mask : bit 15 marks the 16 pixels
	moveq.l	#0,d1			;  of a chunk, it is in bit 31 then)
	moveq.l	#0,d2			; (the 4 planes)
	moveq.l	#0,d3
	moveq.l	#0,d4
.Pixel:	move.w	(a2)+,d5			; Source chunk & bit
	lea.l	0(a3,d5.w),a4
	move.w	(a2)+,d6
	add.l	d0,d0			; Next pixel
	add.w	d1,d1
	add.w	d2,d2
	add.w	d3,d3
	add.w	d4,d4
	move.w	(a4)+,d5			; Mask
	and.w	d6,d5
	beq.s	.Next_pixel
	addq.w	#1,d0
	move.w	(a4)+,d5			; Planes
	and.w	d6,d5
	beq.s	.Plane1
	addq.w	#1,d1
.Plane1:	move.w	(a4)+,d5
	and.w	d6,d5
	beq.s	.Plane2
	addq.w	#1,d2
.Plane2:	move.w	(a4)+,d5
	and.w	d6,d5
	beq.s	.Plane3
	addq.w	#1,d3
.Plane3:	move.w	(a4),d5
	and.w	d6,d5
	beq.s	.Next_pixel
	addq.w	#1,d4
.Next_pixel:
	tst.l	d0			; 16 pixels ?
	bpl.s	.Same_chunk
	move.w	d0,(a1)+			; Yes -> store the chunk
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	move.l	#$8000,d0
.Same_chunk:	dbra	d7,.Pixel
	cmp.l	#$8000,d0			; The rest of the last chunk ?
	beq.s	.Next_line
.Rest:	add.w	d1,d1			; Yes -> transparent
	add.w	d2,d2
	add.w	d3,d3
	add.w	d4,d4
	add.l	d0,d0
	bpl.s	.Rest
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
.Next_line:	addq.w	#1,Zoom_line		; Next line
	subq.w	#1,Zoom_lines_left
	bne	.Line
; ---------- Draw ---------------------------------
	move.w	Zoom_X,d0
	move.w	Zoom_Y,d1
	moveq.l	#5,d5
	move.w	Zoom_chunks,d6
	move.w	Zoom_visible_height,d7
	lea.l	Zoom_buffer,a0
	move.w	Zoom_colour,d4
	bmi.s	.Masked
	jsr	Put_masked_silhouette
	bra.s	.Exit
.Masked:	moveq.l	#0,d4
	jsr	Put_masked_block
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

Zoom_max_width	EQU	320		; (the clip areas are on the screen)
Zoom_max_height	EQU	Screen_height

	SECTION	Fast_BSS,bss
Zoom_gfx_ptr:	ds.l 1
Zoomscreen1_ptr:	ds.l 1		; (set by the combat, not used)
Zoomscreen2_ptr:	ds.l 1
Zoom_colour:	ds.w 1			; (-1 : not a silhouette)
Zoom_X:	ds.w 1
Zoom_Y:	ds.w 1
Zoom_source_width:	ds.w 1
Zoom_source_height:	ds.w 1
Zoom_target_width:	ds.w 1
Zoom_target_height:	ds.w 1
Zoom_first_column:	ds.w 1
Zoom_line:	ds.w 1
Zoom_visible_width:	ds.w 1
Zoom_visible_height:	ds.w 1
Zoom_previous_line:	ds.w 1
Zoom_lines_left:	ds.w 1
Zoom_source_bpl:	ds.w 1
Zoom_buffer_bpl:	ds.w 1
Zoom_chunks:	ds.w 1
Zoom_mirror_X:	ds.b 1
Zoom_mirror_Y:	ds.b 1
	even
Zoom_X_table:	ds.l Zoom_max_width
Zoom_buffer:	ds.b Zoom_max_width/16*10*Zoom_max_height
