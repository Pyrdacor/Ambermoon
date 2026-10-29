; Falcon kernel : graphics
; Replaces KERNEL/GRAPHICS.S of the Amiga version (same routines and
; parameters). (Replaces GRAPHICS.S of the ST kernel; the clip areas are in
; CLIP.S.)
;
; The game uses Amiga graphics : planar, the planes of a line one after the
; other (line interleaved), 1 to 5 planes and a base colour. Pixel value 0 is
; transparent (masked) or colour 0 (unmasked : the base colour only sets the
; planes above the depth of the graphic, where the pixel is not 0, like
; [ Make_mask_blitter ] of the Amiga version).
; The Falcon screen has 8 planes (word interleaved, 16 bytes per chunk of 16
; pixels) : the planes 0-4 get the Amiga colour, the planes 5-7 the bank of
; the line (the palette of the line, RASTER.S). So the graphics are drawn as
; they are, all 32 colours, nothing is converted or cached.
; A line of a block is decoded into "Falcon chunks" (the pixels to draw and
; the 8 planes, [ Decode_line ]), then put on the screen with the shift and
; the clip masks ([ Draw_chunk_line ]).

	SECTION	Program,code

;*****************************************************************************
; [ Calculate offset of a pixel in a screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : d2 - Byte offset in screen (.l)
;        d3 - X-coordinate & 15 (.w)
;*****************************************************************************
Get_screen_offset:
	move.w	d1,d2
	mulu.w	#Screen_bytes_per_line,d2
	move.w	d0,d3
	lsr.w	#4,d3
	lsl.w	#4,d3
	add.w	d3,d2
	moveq.l	#15,d3
	and.w	d0,d3
	rts

;*****************************************************************************
; [ Draw a filled box ]
;   IN : d0 - Left X (.w)
;        d1 - Top Y (.w)
;        d2 - Right X (.w)
;        d3 - Bottom Y (.w)
;        d4 - Colour (.w)
; All registers are restored
; NOTE :
;   - The box is clipped against the current clip area.
;   - Every line gets the colour in the bank of the line.
;*****************************************************************************
Draw_box:
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	CA_Sp,a0			; Clip
	move.l	(a0),a0
	cmp.w	CA_X1(a0),d0
	bge.s	.X1
	move.w	CA_X1(a0),d0
.X1:	cmp.w	CA_X2(a0),d2
	ble.s	.X2
	move.w	CA_X2(a0),d2
.X2:	cmp.w	CA_Y1(a0),d1
	bge.s	.Y1
	move.w	CA_Y1(a0),d1
.Y1:	cmp.w	CA_Y2(a0),d3
	ble.s	.Y2
	move.w	CA_Y2(a0),d3
.Y2:	cmp.w	d0,d2
	blt	.Exit
	cmp.w	d1,d3
	blt	.Exit
	andi.w	#31,d4			; Amiga colour
	jsr	Get_line_banks
	move.l	a0,a2
	add.w	d1,a2			; (bank of the first line)
	sub.w	d1,d3			; Height - 1
	move.l	Work_screen,a0
	move.w	d1,d5
	mulu.w	#Screen_bytes_per_line,d5
	add.l	d5,a0
	move.w	d0,d5			; First & last chunk
	lsr.w	#4,d5
	move.w	d2,d6
	lsr.w	#4,d6
	lsl.w	#4,d5
	add.w	d5,a0
	lsr.w	#4,d5
	sub.w	d5,d6			; Number of chunks - 1
	moveq.l	#15,d5			; Left mask
	and.w	d0,d5
	moveq.l	#-1,d0
	lsr.w	d5,d0
	moveq.l	#15,d5			; Right mask
	and.w	d2,d5
	move.w	#$8000,d2
	asr.w	d5,d2
	tst.w	d6			; One chunk only ?
	bne.s	.Lines
	and.w	d2,d0
	moveq.l	#-1,d2
.Lines:	move.l	a0,a1
	moveq.l	#0,d1			; Colour of the screen
	move.b	(a2)+,d1
	lsl.w	#5,d1
	or.w	d4,d1
	move.w	d0,d7			; First chunk
	jsr	Fill_chunk
	move.w	d6,d5
	subq.w	#1,d5
	bmi.s	.Next
	beq.s	.Last
	subq.w	#1,d5
.Middle:	moveq.l	#-1,d7
	jsr	Fill_chunk
	dbra	d5,.Middle
.Last:	move.w	d2,d7
	jsr	Fill_chunk
.Next:	lea.l	Screen_bytes_per_line(a0),a0
	dbra	d3,.Lines
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Fill the pixels of a chunk ]
;   IN : d1 - Colour of the screen (0...255) (.w)
;        d7 - Mask (.w)
;        a1 - Pointer to chunk (.l)
;  OUT : a1 - Pointer to next chunk (.l)
; Changed registers : a1
Fill_chunk:
	movem.l	d1/d2/d6,-(sp)
	move.w	d7,d2
	not.w	d2
	moveq.l	#8-1,d6
.Plane:	lsr.w	#1,d1
	bcc.s	.Clear
	or.w	d7,(a1)+
	dbra	d6,.Plane
	bra.s	.Exit
.Clear:	and.w	d2,(a1)+
	dbra	d6,.Plane
.Exit:	movem.l	(sp)+,d1/d2/d6
	rts

;*****************************************************************************
; [ Get the colour of a pixel ]
;   IN : d0 - X, d1 - Y (.w)
;  OUT : d4 - Colour (Amiga colour number) (.w)
;*****************************************************************************
Get_pixel:
	movem.l	d0-d3/d5/a0,-(sp)
	move.l	Work_screen,a0
	jsr	Get_screen_offset
	add.l	d2,a0
	move.w	#$8000,d2
	lsr.w	d3,d2
	moveq.l	#0,d4
	moveq.l	#5-1,d5			; Planes 0-4 (5-7 : the bank)
.Plane:	ror.b	#1,d4
	move.w	(a0)+,d3
	and.w	d2,d3
	beq.s	.Zero
	bset	#7,d4
.Zero:	dbra	d5,.Plane
	lsr.b	#3,d4			; (bits 3-7 -> 0-4)
	andi.w	#31,d4
	movem.l	(sp)+,d0-d3/d5/a0
	rts

;*****************************************************************************
; [ Put blocks & icons ]
;*****************************************************************************
; [ Put an unmasked block on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
Put_unmasked_block:
	move.w	#Blit_unmasked,Blit_mode
	bra	Put_block

; [ Put a masked block on the work screen ]
;   IN : like [ Put_unmasked_block ]
Put_masked_block:
Put_masked_block2:
	move.w	#Blit_masked,Blit_mode
	bra	Put_block

; [ Put the silhouette of a masked block on the work screen ]
;   IN : like [ Put_unmasked_block ], d4 - Silhouette colour (.w)
Put_masked_silhouette:
	move.w	#Blit_silhouette,Blit_mode
	bra	Put_block

; [ Put a 16x16 icon on the work screen ]
;   IN : d0 - X, d1 - Y, d4 - Base colour, d5 - Number of planes (.w)
;        a0 - Pointer to icon graphics (.l)
Put_masked_icon:
	move.w	#Blit_masked,Blit_mode
	bra.s	Put_icon
Put_unmasked_icon:
	move.w	#Blit_unmasked,Blit_mode
Put_icon:
	movem.l	d6/d7,-(sp)
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_block
	movem.l	(sp)+,d6/d7
	rts

Blit_unmasked	EQU	0
Blit_masked	EQU	1
Blit_silhouette	EQU	2

;*****************************************************************************
; [ Put a block on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour / silhouette colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
;        [ Blit_mode ] - Mode (.w)
; All registers are restored
;*****************************************************************************
Put_block:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	d6
	ble	.Exit
	tst.w	d7
	ble	.Exit
	tst.w	d5
	ble	.Exit
	cmp.w	#5,d5
	bhi	.Exit
	cmp.w	#Max_chunks,d6
	bhi	.Exit
	cmp.w	#Blit_unmasked,Blit_mode	; Unmasked blocks start at
	bne.s	.Go			;  a multiple of 16
	andi.w	#-16,d0
.Go:	move.w	d0,Blit_X
	move.w	d1,Blit_Y
	move.w	d4,Blit_colour
	move.w	d5,Blit_planes
	move.w	d6,Blit_width
	move.w	d7,Blit_height
	move.l	a0,Blit_source
	jsr	Make_clip_masks
	jsr	Get_line_banks
	move.l	a0,Blit_banks
	jsr	Draw_block
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw a block ]
;   IN : [ Blit_... ] variables
; All registers are restored
;*****************************************************************************
Draw_block:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	Blit_Y,d1			; First visible line
	moveq.l	#0,d6			; (source line)
	cmp.w	Clip_Y1,d1
	bge.s	.Top_ok
	move.w	Clip_Y1,d6
	sub.w	d1,d6
	move.w	Clip_Y1,d1
.Top_ok:	move.w	Blit_Y,d7			; Last line + 1
	add.w	Blit_height,d7
	move.w	Clip_Y2,d0
	addq.w	#1,d0
	cmp.w	d0,d7
	ble.s	.Bottom_ok
	move.w	d0,d7
.Bottom_ok:	sub.w	d1,d7			; Number of lines
	ble	.Exit
	subq.w	#1,d7
	move.l	Work_screen,a5		; Screen line
	move.w	d1,d0
	mulu.w	#Screen_bytes_per_line,d0
	add.l	d0,a5
	move.l	Blit_banks,a6		; Bank of the line
	add.w	d1,a6
	move.w	Blit_planes,d0		; Source line
	add.w	d0,d0
	mulu.w	Blit_width,d0
	move.l	d0,a3			; (bytes per source line)
	mulu.w	d6,d0
	move.l	Blit_source,a4
	add.l	d0,a4
	move.w	Blit_X,d5			; Shift & first chunk
	move.w	d5,d4
	asr.w	#4,d4
	andi.w	#15,d5
.Line:	lea.l	Line_chunks,a0		; Decode the source line
	move.b	(a6)+,d0
	jsr	Decode_line
	jsr	Draw_chunk_line
	add.l	a3,a4
	lea.l	Screen_bytes_per_line(a5),a5
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Decode a line of Amiga graphics into Falcon chunks ]
;   IN : d0 - Bank of the screen line (.b)
;        a0 - Pointer to line buffer (.l)
;        a4 - Pointer to the source line (.l)
;        [ Blit_... ] variables
; All registers are restored
; NOTE :
;   - A Falcon chunk : the pixels to draw, the 8 planes (9 words).
;*****************************************************************************
Decode_line:
	movem.l	d0-d7/a0-a5,-(sp)
	moveq.l	#0,d5			; Planes 5-7 : the bank (in the
	moveq.l	#0,d6			;  high words : planes 5 & 6, low :
	lsr.b	#1,d0			;  plane 7)
	bcc.s	.B5
	move.w	#-1,d5
.B5:	swap	d5
	lsr.b	#1,d0
	bcc.s	.B6
	move.w	#-1,d5
.B6:	lsr.b	#1,d0
	bcc.s	.B7
	moveq.l	#-1,d6
.B7:	move.w	Blit_width,d7
	add.w	d7,d7
	move.w	d7,a2			; (offset of the next plane)
	move.w	Blit_width,d7
	subq.w	#1,d7
	move.w	Blit_planes,a5
	move.w	Blit_mode,d4
.Chunk:	move.l	a4,a1			; Get the planes
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	(a1),d0
	cmp.w	#2,a5
	bmi.s	.Got
	add.w	a2,a1
	move.w	(a1),d1
	cmp.w	#3,a5
	bmi.s	.Got
	add.w	a2,a1
	move.w	(a1),d2
	cmp.w	#4,a5
	bmi.s	.Got
	add.w	a2,a1
	swap	d0			; (plane 3 : low word of d0)
	move.w	(a1),d0
	swap	d0
	cmp.w	#5,a5
	bmi.s	.Got
	add.w	a2,a1
	swap	d1			; (plane 4 : low word of d1)
	move.w	(a1),d1
	swap	d1
.Got:	addq.l	#2,a4
	move.l	d0,d3			; Mask : the pixels which are not 0
	swap	d3
	or.w	d0,d3
	or.w	d1,d3
	move.l	d1,a1
	swap	d1
	or.w	d1,d3
	move.l	a1,d1
	or.w	d2,d3
	cmp.w	#5,a5			; Planes above the depth : the base
	beq.s	.Base_done		;  colour (where the pixel is not 0)
	jsr	.Base
.Base_done:
	cmp.w	#Blit_silhouette,d4
	beq.s	.Silhouette
	cmp.w	#Blit_unmasked,d4
	bne.s	.Masked
	move.w	#-1,(a0)+			; Unmasked : all pixels
	bra.s	.Store
.Masked:	move.w	d3,(a0)+			; Masked : the pixels which are not 0
.Store:	move.w	d0,(a0)+			; Plane 0
	move.w	d1,(a0)+			; Plane 1
	move.w	d2,(a0)+			; Plane 2
	swap	d0
	move.w	d0,(a0)+			; Plane 3
	swap	d1
	move.w	d1,(a0)+			; Plane 4
	move.l	d5,(a0)+			; Planes 5 & 6
	move.w	d6,(a0)+			; Plane 7
	dbra	d7,.Chunk
	movem.l	(sp)+,d0-d7/a0-a5
	rts
.Silhouette:	move.w	d3,(a0)+			; The pixels which are not 0, in the
	move.w	Blit_colour,d0		;  silhouette colour
	moveq.l	#5-1,d1
.Sil:	lsr.w	#1,d0
	scs	d2
	ext.w	d2
	move.w	d2,(a0)+
	dbra	d1,.Sil
	move.l	d5,(a0)+			; Planes 5-7 : the bank
	move.w	d6,(a0)+
	dbra	d7,.Chunk
	movem.l	(sp)+,d0-d7/a0-a5
	rts
; Planes from the depth on : the bits of the base colour (d3 : the mask)
.Base:	move.w	Blit_colour,d4
	move.w	a5,-(sp)
	cmp.w	#2,a5			; Plane 1
	bpl.s	.P2
	btst	#1,d4
	beq.s	.P2
	move.w	d3,d1
.P2:	cmp.w	#3,a5			; Plane 2
	bpl.s	.P3
	btst	#2,d4
	beq.s	.P3
	move.w	d3,d2
.P3:	cmp.w	#4,a5			; Plane 3
	bpl.s	.P4
	btst	#3,d4
	beq.s	.P4
	swap	d0
	move.w	d3,d0
	swap	d0
.P4:	btst	#4,d4			; Plane 4
	beq.s	.Done
	swap	d1
	move.w	d3,d1
	swap	d1
.Done:	move.w	(sp)+,a5
	move.w	Blit_mode,d4
	rts

;*****************************************************************************
; [ Draw one line of Falcon chunks ]
;   IN : d4 - First chunk X (may be negative) (.w)
;        d5 - Shift (.w)
;        a0 - Pointer to Falcon chunks (pixels to draw & 8 planes) (.l)
;        a5 - Pointer to screen line (.l)
;        [ Blit_width ], [ Clip_masks ]
; All registers are restored
;*****************************************************************************
Draw_chunk_line:
	movem.l	d0-d7/a0-a4,-(sp)
	lea.l	Clip_masks,a2
	move.w	Blit_width,d7
	subq.w	#1,d7
	tst.w	d5			; Fast : at a multiple of 16
	bne.s	.Chunk
.Fast:	move.w	(a0)+,d2			; Pixels to draw
	cmp.w	#20,d4			; (unsigned : also negative)
	bcc.s	.Fast_next
	move.w	d4,d6
	add.w	d6,d6
	and.w	0(a2,d6.w),d2		; Clip
	beq.s	.Fast_next
	move.w	d4,d6
	lsl.w	#4,d6
	lea.l	0(a5,d6.w),a1
	cmp.w	#-1,d2			; All pixels ?
	bne.s	.Fast_masked
	move.l	(a0)+,(a1)+		; Yes -> copy
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	bra.s	.Fast_done
.Fast_masked:	move.w	d2,d3
	not.w	d3
	moveq.l	#8-1,d6
.Fast_plane:	move.w	(a0)+,d0
	and.w	d2,d0
	move.w	(a1),d1
	and.w	d3,d1
	or.w	d0,d1
	move.w	d1,(a1)+
	dbra	d6,.Fast_plane
	bra.s	.Fast_done
.Fast_next:	lea.l	16(a0),a0
.Fast_done:	addq.w	#1,d4
	dbra	d7,.Fast
	bra.s	.Exit
.Chunk:	moveq.l	#0,d0			; Pixels to draw
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d5,d0			; High word : left chunk, low : right
	move.w	d4,d1			; Left destination chunk
	moveq.l	#0,d3
	move.l	d0,d2
	swap	d2
	jsr	.Put
	addq.w	#1,d1			; Right destination chunk
	moveq.l	#1,d3
	move.w	d0,d2
	jsr	.Put
	lea.l	16(a0),a0
	addq.w	#1,d4
	dbra	d7,.Chunk
.Exit:	movem.l	(sp)+,d0-d7/a0-a4
	rts
; Set the pixels d2 (part d3 of the shifted words) in chunk d1
.Put:	cmp.w	#20,d1			; (unsigned : also negative)
	bcc.s	.Out
	move.w	d1,d6
	add.w	d6,d6
	and.w	0(a2,d6.w),d2		; Clip
	beq.s	.Out
	move.w	d1,d6
	lsl.w	#4,d6
	lea.l	0(a5,d6.w),a1
	movem.l	d0/d1/d4/d6/a0,-(sp)
	move.w	d2,d4
	not.w	d4
	moveq.l	#8-1,d6
.Plane:	moveq.l	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d5,d0
	tst.w	d3
	bne.s	.Low
	swap	d0
.Low:	and.w	d2,d0
	move.w	(a1),d1
	and.w	d4,d1
	or.w	d0,d1
	move.w	d1,(a1)+
	dbra	d6,.Plane
	movem.l	(sp)+,d0/d1/d4/d6/a0
.Out:	rts

;*****************************************************************************
; [ Put the text line buffer on the work screen ]
;   IN : d0 - X-coordinate (multiple of 16) (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Colour of the screen ([ Get_screen_colour ]) (.w)
;        d5 - Shift to the right (0 or 1) (.w)
;        d6 - Number of truncs (.w)
; All registers are restored
;*****************************************************************************
Put_text_buffer:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Make_clip_masks		; (clipped like the Amiga version)
	move.w	d6,Blit_text_truncs
	move.w	d1,a4			; Y
	move.w	d0,d2
	lsr.w	#3,d2			; (chunk * 2)
	lea.l	Clip_masks,a5
	add.w	d2,a5
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	lea.l	Text_line_bit_plane_buffer,a0
	move.w	d6,d7			; Truncs to draw
	add.w	d5,d7
	lsr.w	#4,d0			; Not more than the screen
	moveq.l	#20,d2
	sub.w	d0,d2
	cmp.w	d2,d7
	ble.s	.Ok
	move.w	d2,d7
.Ok:	subq.w	#1,d7
	bmi	.Exit
	move.w	#Screen_height,d3		; Lines
	sub.w	d1,d3
	ble	.Exit
	cmp.w	#Char_height,d3
	ble.s	.Ok2
	moveq.l	#Char_height,d3
.Ok2:	subq.w	#1,d3
.Line:	cmpa.w	Clip_Y1,a4		; Line visible ?
	blt	.Skip_line
	cmpa.w	Clip_Y2,a4
	bgt	.Skip_line
	move.l	a0,a2
	move.l	a1,a3
	move.l	a5,-(sp)
	moveq.l	#0,d2			; Previous word
	move.w	d7,d0
	move.w	Blit_text_truncs,a6		; Words left in the buffer line
.Trunc:	swap	d2			; Previous word -> high word
	clr.w	d2
	cmp.w	#0,a6
	ble.s	.Empty
	move.w	(a2)+,d2
	subq.w	#1,a6
.Empty:	move.l	d2,d1			; Mask
	lsr.l	d5,d1
	and.w	(a5)+,d1			; Clip
	move.w	d1,d6			; (inverted mask)
	not.w	d6
	move.w	d4,-(sp)
	REPT	8			; 8 planes
	lsr.w	#1,d4
	bcc.s	*+6
	or.w	d1,(a3)+
	bra.s	*+4
	and.w	d6,(a3)+
	ENDR
	move.w	(sp)+,d4
	dbra	d0,.Trunc
	move.l	(sp)+,a5
.Skip_line:	lea.l	40(a0),a0			; Next line
	lea.l	Screen_bytes_per_line(a1),a1
	addq.w	#1,a4
	dbra	d3,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Get a block from the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to buffer (.l)
; All registers are restored
; NOTE :
;   - The buffer gets Amiga graphics (the planes 0 to d5 - 1 of the screen,
;     line interleaved) : the Put routines draw them like any other graphic.
;*****************************************************************************
Get_block:
	movem.l	d0-d7/a0-a2,-(sp)
	tst.w	d6
	ble.s	.Exit
	tst.w	d7
	ble.s	.Exit
	tst.w	d5
	ble.s	.Exit
	cmp.w	#5,d5
	ble.s	.Planes
	moveq.l	#5,d5
.Planes:	move.l	Work_screen,a1
	andi.w	#-16,d0
	jsr	Get_screen_offset
	add.l	d2,a1
	subq.w	#1,d7
.Line:	moveq.l	#0,d3			; Plane
.Plane:	move.l	a1,a2
	add.w	d3,a2
	add.w	d3,a2
	move.w	d6,d2
	subq.w	#1,d2
.Chunk:	move.w	(a2),(a0)+
	lea.l	Chunk_bytes(a2),a2
	dbra	d2,.Chunk
	addq.w	#1,d3
	cmp.w	d5,d3
	bmi.s	.Plane
	lea.l	Screen_bytes_per_line(a1),a1
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Other routines ]
;*****************************************************************************
; [ Copy a block of the shown screen to the work screen ]
;   IN : d0 - X, d1 - Y, d5 - Number of planes, d6 - Width in truncs,
;        d7 - Height (.w)
Duplicate_block:
	jsr	Hide_pointer		; (the pointer is in the shown screen)
	movem.l	d0-d7/a0-a2,-(sp)
	tst.w	d6
	ble.s	.Exit
	tst.w	d7
	ble.s	.Exit
	andi.w	#-16,d0
	jsr	Get_screen_offset
	move.l	On_screen,a0
	add.l	d2,a0
	move.l	Work_screen,a1
	add.l	d2,a1
	subq.w	#1,d7
.Line:	movem.l	a0/a1,-(sp)
	move.w	d6,d2
	subq.w	#1,d2
.Chunk:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d2,.Chunk
	movem.l	(sp)+,a0/a1
	lea.l	Screen_bytes_per_line(a0),a0
	lea.l	Screen_bytes_per_line(a1),a1
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	jsr	Show_pointer
	rts

; [ Clear a block in one plane of the work screen ] (3D map)
Clear_1plane_block:
	rts

; [ Show a MOVEP screen ] (3D map)
Show_MOVEP_screen:
	rts

Max_chunks	EQU	32			; (widest block, in truncs)

	SECTION	Fast_BSS,bss
Blit_mode:	ds.w 1
Blit_X:	ds.w 1
Blit_Y:	ds.w 1
Blit_colour:	ds.w 1
Blit_planes:	ds.w 1
Blit_width:	ds.w 1
Blit_height:	ds.w 1
Blit_text_truncs:	ds.w 1
Blit_source:	ds.l 1
Blit_banks:	ds.l 1
Line_chunks:	ds.w 9*Max_chunks
