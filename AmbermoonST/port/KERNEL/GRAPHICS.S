; ST kernel : graphics
; Replaces KERNEL/GRAPHICS.S of the Amiga version (same routines and
; parameters).
;
; The game uses Amiga graphics : planar, the planes of a line one after the
; other (line interleaved), 1 to 5 planes and a base colour. Pixel value 0 is
; transparent (masked) or colour 0 (unmasked : the base colour is only set
; where the pixel is not 0, [ Make_mask_blitter ] of the Amiga version). The
; ST screen has 4 planes (word interleaved) and 16 colours : an Amiga colour
; becomes the ST colour of the palette of the line ([ Get_ST_LUT ]).
;
; A block is converted into "ST chunks" : per line and 16 pixels the mask and
; the 4 planes (5 words, the same size as 5 Amiga planes). The conversion :
;   - 3 planes with base colour 24 (layouts, buttons, windows) : the Amiga
;     colours 25-31 have fixed ST colours in every palette (25 -> 9, 26 -> 10,
;     27 -> 11, 28/29 -> 12, 30/31 -> 14, port/tools/port_palettes.py), so the
;     ST planes are p0 = a0 & ~a2, p1 = a1, p2 = a2 and p3 = the mask (fast,
;     done line by line).
;   - else every pixel goes through the lookup table, and the converted block
;     is kept in a cache (key : address, size, planes, base colour, lookup
;     table and a checksum of the data), so tiles, icons and portraits are
;     converted only once.
; [ Get_block ] stores ST data (4 planes, or 3 for 3 planes). Such buffers are
; registered (address and checksum), so the Put routines recognize them.

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
	mulu.w	#ST_bytes_per_line,d2
	move.w	d0,d3
	lsr.w	#4,d3
	lsl.w	#3,d3
	add.w	d3,d2
	moveq.l	#15,d3
	and.w	d0,d3
	rts

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
	movem.l	(sp)+,d0-d5/d7/a0/a1
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
;*****************************************************************************
Draw_box:
	movem.l	d0-d7/a0-a2,-(sp)
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
	jsr	Get_ST_colour		; ST colour
	sub.w	d1,d3			; Height - 1
	move.l	Work_screen,a0
	move.w	d1,d5
	mulu.w	#ST_bytes_per_line,d5
	add.l	d5,a0
	move.w	d0,d5			; First & last chunk
	lsr.w	#4,d5
	move.w	d2,d6
	lsr.w	#4,d6
	lsl.w	#3,d5
	add.w	d5,a0
	lsr.w	#3,d5
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
.Next:	lea.l	ST_bytes_per_line(a0),a0
	dbra	d3,.Lines
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Fill the pixels of a chunk ]
;   IN : d4 - ST colour (.w)
;        d7 - Mask (.w)
;        a1 - Pointer to chunk (.l)
;  OUT : a1 - Pointer to next chunk (.l)
; Changed registers : a1
Fill_chunk:
	move.l	d1,-(sp)
	move.w	d7,d1
	not.w	d1
	btst	#0,d4
	beq.s	.C0
	or.w	d7,(a1)+
	bra.s	.P1
.C0:	and.w	d1,(a1)+
.P1:	btst	#1,d4
	beq.s	.C1
	or.w	d7,(a1)+
	bra.s	.P2
.C1:	and.w	d1,(a1)+
.P2:	btst	#2,d4
	beq.s	.C2
	or.w	d7,(a1)+
	bra.s	.P3
.C2:	and.w	d1,(a1)+
.P3:	btst	#3,d4
	beq.s	.C3
	or.w	d7,(a1)+
	bra.s	.Exit
.C3:	and.w	d1,(a1)+
.Exit:	move.l	(sp)+,d1
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

; [ Get the colour of a pixel ]
;   IN : d0 - X, d1 - Y (.w)
;  OUT : d4 - Colour (Amiga colour number) (.w)
; NOTE :
;   - The ST colour is read and the first Amiga colour with this ST colour in
;     the palette of the line is returned.
Get_pixel:
	movem.l	d0-d3/d5/a0,-(sp)
	move.l	Work_screen,a0
	jsr	Get_screen_offset
	add.l	d2,a0
	move.w	#$8000,d2
	lsr.w	d3,d2
	moveq.l	#0,d4
	moveq.l	#4-1,d5
.Plane:	ror.b	#1,d4
	move.w	(a0)+,d3
	and.w	d2,d3
	beq.s	.Zero
	bset	#7,d4
.Zero:	dbra	d5,.Plane
	rol.b	#4,d4			; (bits 4-7 -> 0-3)
	andi.w	#15,d4
	jsr	Get_ST_LUT		; Back to an Amiga colour
	moveq.l	#0,d5
.Find:	cmp.b	0(a0,d5.w),d4
	beq.s	.Found
	addq.w	#1,d5
	cmp.w	#32,d5
	bmi.s	.Find
	moveq.l	#0,d5
.Found:	move.w	d5,d4
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
	cmp.w	#5,d5
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
	cmp.w	#Blit_silhouette,Blit_mode	; Silhouette : ST colour
	bne.s	.No_sil
	jsr	Get_ST_colour
	move.w	d4,Blit_silhouette_colour
.No_sil:
; ---------- ST data of Get_block ? --------------
	jsr	Find_raw_buffer
	bmi.s	.Amiga
	move.w	d0,Blit_raw_planes		; Yes
	move.w	#Decode_raw,Blit_decoder
	bra	.Draw
; ---------- Amiga graphics -----------------------
.Amiga:	move.w	Blit_Y,d1			; Lookup table
	jsr	Get_ST_LUT
	move.l	a0,Blit_LUT
	lea.l	Blit_table,a1		; Colours of the pixel values
	clr.b	(a1)+
	moveq.l	#1,d2
.Table:	move.w	d2,d3
	cmp.w	#5,Blit_planes
	beq.s	.Full
	add.w	Blit_colour,d3
.Full:	andi.w	#31,d3
	move.b	0(a0,d3.w),(a1)+
	addq.w	#1,d2
	cmp.w	#32,d2
	bmi.s	.Table
	cmp.w	#3,Blit_planes		; 3 planes, base colour 24 ?
	bne.s	.Slow
	lea.l	Blit_table+1,a1
	lea.l	UI_ST_colours,a2
	moveq.l	#7-1,d2
.Check:	cmpm.b	(a1)+,(a2)+
	bne.s	.Slow
	dbra	d2,.Check
	move.w	#Decode_3planes,Blit_decoder	; Yes -> fast
	bra.s	.Draw
.Slow:	jsr	Convert_block		; Convert (or from the cache)
	bmi.s	.Lines
	move.w	#Decode_cache,Blit_decoder
	bra.s	.Draw
.Lines:	move.w	#Decode_pixels,Blit_decoder	; (too large : line by line)
; ---------- Draw ---------------------------------
.Draw:	jsr	Draw_block
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw a block ]
;   IN : [ Blit_... ] variables
; All registers are restored
; NOTE :
;   - The decoder gives the ST chunks of a line, they are drawn with the
;     clip masks.
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
	mulu.w	#ST_bytes_per_line,d0
	add.l	d0,a5
	move.w	Blit_X,d5			; Shift & first chunk
	move.w	d5,d4
	asr.w	#4,d4
	andi.w	#15,d5
.Line:	move.w	d6,d0			; Decode source line
	lea.l	Line_chunks,a0
	move.w	Blit_decoder,d2
	jsr	.Decoders(pc,d2.w)
	jsr	Draw_chunk_line
	addq.w	#1,d6
	lea.l	ST_bytes_per_line(a5),a5
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts
.Decoders:
	bra.w	Line_raw
	bra.w	Line_3planes
	bra.w	Line_cache
	bra.w	Line_pixels

Decode_raw	EQU	0
Decode_3planes	EQU	4
Decode_cache	EQU	8
Decode_pixels	EQU	12

; ST colours of the Amiga colours 25-31 (the UI colours, port_palettes.py)
UI_ST_colours:
	dc.b	9,10,11,12,12,14,14
	even

; [ Draw one line of ST chunks ]
;   IN : d4 - First chunk X (may be negative) (.w)
;        d5 - Shift (.w)
;        a0 - Pointer to ST chunks (mask & 4 planes) (.l)
;        a5 - Pointer to screen line (.l)
; All registers are restored
Draw_chunk_line:
	movem.l	d0-d7/a0-a4,-(sp)
	lea.l	Clip_masks,a2
	move.w	Blit_width,d7
	subq.w	#1,d7
.Chunk:	moveq.l	#0,d0			; Mask
	move.w	(a0)+,d0
	cmp.w	#Blit_unmasked,Blit_mode
	bne.s	.Masked
	move.w	#$ffff,d0
.Masked:	swap	d0
	lsr.l	d5,d0			; High word : left chunk, low : right
	move.w	d4,d1			; Left destination chunk
	moveq.l	#0,d3
	move.l	d0,d2
	swap	d2
	jsr	.Put
	tst.w	d5			; Right destination chunk
	beq.s	.Next
	addq.w	#1,d1
	moveq.l	#1,d3
	move.w	d0,d2
	jsr	.Put
.Next:	addq.l	#8,a0
	addq.w	#1,d4
	dbra	d7,.Chunk
	movem.l	(sp)+,d0-d7/a0-a4
	rts
; Set the pixels d2 (mask part) of the planes part d3 in chunk d1
.Put:	cmp.w	#20,d1			; (unsigned : also negative)
	bcc.s	.Out
	move.w	d1,d6
	add.w	d6,d6
	and.w	0(a2,d6.w),d2		; Clip
	beq.s	.Out
	move.w	d1,d6
	lsl.w	#3,d6
	lea.l	0(a5,d6.w),a1
	jsr	Put_planes
.Out:	rts

; [ Set the pixels of a chunk ]
;   IN : d2 - Pixels to set (.w)
;        d3 - 0 = high word, 1 = low word of the shifted planes (.w)
;        d5 - Shift (.w)
;        a0 - Pointer to the 4 plane words of the source chunk (.l)
;        a1 - Pointer to screen chunk (.l)
; Changed registers : d3
Put_planes:
	movem.l	d0/d1/d4/d6/a0,-(sp)
	move.w	d2,d4
	not.w	d4
	moveq.l	#4-1,d6
	cmp.w	#Blit_silhouette,Blit_mode
	beq.s	.Silhouette
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
	bra.s	.Exit
.Silhouette:	move.w	Blit_silhouette_colour,d0
.Plane2:	move.w	(a1),d1
	and.w	d4,d1
	lsr.w	#1,d0
	bcc.s	.Off
	or.w	d2,d1
.Off:	move.w	d1,(a1)+
	dbra	d6,.Plane2
.Exit:	movem.l	(sp)+,d0/d1/d4/d6/a0
	rts

;*****************************************************************************
; [ Line decoders ]
;   IN : d0 - Source line (.w)
;        a0 - Pointer to line buffer (ST chunks) (.l)
;  OUT : a0 - Pointer to the ST chunks of the line (.l)
; Changed registers : a0 (and d0-d3, a1, a3, a4)
;*****************************************************************************
; [ ST data of Get_block ]
Line_raw:
	movem.l	d1-d4/d6/d7/a1,-(sp)
	move.l	Blit_source,a1		; Line address
	move.w	Blit_raw_planes,d1
	add.w	d1,d1			; (bytes per chunk)
	mulu.w	Blit_width,d1
	mulu.w	d0,d1
	add.l	d1,a1
	move.l	a0,-(sp)
	move.w	Blit_width,d7
	subq.w	#1,d7
.Chunk:	movem.w	(a1)+,d1-d3		; Planes 0-2
	moveq.l	#0,d4
	cmp.w	#3,Blit_raw_planes
	beq.s	.Three
	move.w	(a1)+,d4			; Plane 3
	move.w	d1,d6			; Mask
	or.w	d2,d6
	or.w	d3,d6
	or.w	d4,d6
	bra.s	.Store
.Three:	move.w	d1,d6			; 3 planes : plane 3 = mask
	or.w	d2,d6
	or.w	d3,d6
	move.w	d6,d4
.Store:	move.w	d6,(a0)+
	movem.w	d1-d4,(a0)
	addq.l	#8,a0
	dbra	d7,.Chunk
	move.l	(sp)+,a0
	movem.l	(sp)+,d1-d4/d6/d7/a1
	rts

; [ 3 planes with base colour 24 ]
Line_3planes:
	movem.l	d1-d7/a1,-(sp)
	move.l	Blit_source,a1
	move.w	Blit_width,d1
	mulu.w	#6,d1
	mulu.w	d0,d1
	add.l	d1,a1
	move.l	a0,-(sp)
	move.w	Blit_width,d6		; (offset of the next plane)
	add.w	d6,d6
	move.w	Blit_width,d7
	subq.w	#1,d7
.Chunk:	move.w	(a1),d1
	move.w	0(a1,d6.w),d2
	add.w	d6,a1
	move.w	0(a1,d6.w),d3
	sub.w	d6,a1
	addq.l	#2,a1
	move.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	move.w	d4,(a0)+			; Mask
	move.w	d3,d5			; p0 = a0 & ~a2 (the UI colours of
	not.w	d5			;  port_palettes.py)
	and.w	d5,d1
	movem.w	d1-d4,(a0)
	addq.l	#8,a0
	dbra	d7,.Chunk
	move.l	(sp)+,a0
	movem.l	(sp)+,d1-d7/a1
	rts

; [ Converted block in the cache ]
Line_cache:
	move.l	d1,-(sp)
	move.w	Blit_width,d1
	mulu.w	#10,d1
	mulu.w	d0,d1
	move.l	Blit_cached,a0
	add.l	d1,a0
	move.l	(sp)+,d1
	rts

; [ Convert the pixels of a line ]
Line_pixels:
	movem.l	d0-d7/a1-a4,-(sp)
	move.l	a0,-(sp)
	move.l	a0,a1
	move.l	Blit_source,a0
	move.w	Blit_planes,d1
	add.w	d1,d1
	mulu.w	Blit_width,d1
	mulu.w	d0,d1
	add.l	d1,a0
	moveq.l	#1,d7			; One line
	jsr	Convert_lines
	move.l	(sp)+,a0
	movem.l	(sp)+,d0-d7/a1-a4
	rts

;*****************************************************************************
; [ Convert a block (through the cache) ]
;   IN : [ Blit_... ] variables, [ Blit_table ]
;  OUT : [ Blit_cached ] - Pointer to the ST chunks (.l)
;        pl - Ok, mi - Too large for the cache
; All registers are restored
;*****************************************************************************
Convert_block:
	movem.l	d0-d7/a0-a4,-(sp)
	move.w	Blit_planes,d0		; Size of the source
	add.w	d0,d0
	mulu.w	Blit_width,d0
	mulu.w	Blit_height,d0
	move.l	d0,d5
	move.w	Blit_width,d0		; Size of the ST chunks
	mulu.w	#10,d0
	mulu.w	Blit_height,d0
	move.l	d0,d6
	cmp.l	#Cache_size/4,d6		; Too large ?
	bhi	.Too_large
	move.l	Blit_source,a0		; Checksum
	move.l	d5,d0
	jsr	Checksum
	move.l	d0,d4
	move.w	Blit_planes,d1		; Key : planes, width, height, colour
	lsl.w	#8,d1
	or.b	Blit_width+1,d1
	swap	d1
	move.b	Blit_height+1,d1
	lsl.w	#8,d1
	or.b	Blit_colour+1,d1
	move.l	Blit_source,d0		; Hash
	move.l	d0,d2
	lsr.l	#5,d2
	eor.w	d2,d0
	andi.w	#Cache_entries-1,d0
	mulu.w	#Cache_entry_size,d0
	lea.l	Cache_index,a2
	add.l	d0,a2
	move.l	Blit_source,d0		; Same ?
	cmp.l	(a2),d0
	bne.s	.New
	cmp.l	4(a2),d1
	bne.s	.New
	move.l	Blit_LUT,d0
	cmp.l	8(a2),d0
	bne.s	.New
	cmp.l	12(a2),d4
	bne.s	.New
	cmp.l	#Cache_pool,16(a2)		; (still valid ?)
	bcs.s	.New
	move.l	16(a2),Blit_cached		; Yes
	bra	.Ok
.New:	move.l	Cache_free,a3		; Room in the pool ?
	move.l	a3,d0
	add.l	d6,d0
	cmp.l	#Cache_pool+Cache_size,d0
	bls.s	.Room
	jsr	Clear_cache		; No -> start again
	move.l	Cache_free,a3
.Room:	move.l	a3,d0
	add.l	d6,d0
	move.l	d0,Cache_free
	move.l	Blit_source,(a2)		; Store entry
	move.l	d1,4(a2)
	move.l	Blit_LUT,8(a2)
	move.l	d4,12(a2)
	move.l	a3,16(a2)
	move.l	a3,Blit_cached
	move.l	Blit_source,a0		; Convert
	move.l	a3,a1
	move.w	Blit_height,d7
	jsr	Convert_lines
.Ok:	moveq.l	#0,d0
	bra.s	.Exit
.Too_large:	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d0-d7/a0-a4
	rts

; [ Clear the conversion cache ]
; All registers are restored
Clear_cache:
	movem.l	d7/a0,-(sp)
	move.l	#Cache_pool,Cache_free
	lea.l	Cache_index,a0
	move.w	#Cache_entries*Cache_entry_size/4-1,d7
.Loop:	clr.l	(a0)+
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

; [ Checksum of data ]
;   IN : d0 - Length (bytes, even) (.l)
;        a0 - Pointer to data (.l)
;  OUT : d0 - Checksum (.l)
; Changed registers : d0
Checksum:
	movem.l	d1/d2/a0,-(sp)
	move.l	d0,d2
	moveq.l	#0,d0
	lsr.l	#1,d2
	bra.s	.Next
.Loop:	rol.l	#3,d0
	add.w	(a0)+,d0
.Next:	subq.l	#1,d2
	bpl.s	.Loop
	movem.l	(sp)+,d1/d2/a0
	rts

;*****************************************************************************
; [ Convert lines of Amiga graphics to ST chunks ]
;   IN : d7 - Number of lines (.w)
;        a0 - Pointer to Amiga graphics (line interleaved) (.l)
;        a1 - Pointer to target (.l)
;        [ Blit_planes ], [ Blit_width ], [ Blit_table ]
; Changed registers : d0-d7, a0-a4
; NOTE :
;   - Every pixel : value -> [ Blit_table ] -> ST colour.
;*****************************************************************************
Convert_lines:
	lea.l	Blit_table,a2
	move.w	Blit_width,d6		; Plane offset
	add.w	d6,d6
	move.w	Blit_planes,a4
	subq.w	#1,d7
.Line:	move.w	Blit_width,a3
.Chunk:	moveq.l	#0,d0			; Get the planes
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	move.l	a0,-(sp)
	move.w	a4,d5
	subq.w	#1,d5
	bmi.s	.Got
	move.w	(a0),d0
	subq.w	#1,d5
	bmi.s	.Got
	add.w	d6,a0
	move.w	(a0),d1
	subq.w	#1,d5
	bmi.s	.Got
	add.w	d6,a0
	move.w	(a0),d2
	subq.w	#1,d5
	bmi.s	.Got
	add.w	d6,a0
	move.w	(a0),d3
	subq.w	#1,d5
	bmi.s	.Got
	add.w	d6,a0
	move.w	(a0),d4
.Got:	move.l	(sp)+,a0
	addq.l	#2,a0
	move.w	d0,d5			; Mask
	or.w	d1,d5
	or.w	d2,d5
	or.w	d3,d5
	or.w	d4,d5
	move.w	d5,(a1)+
	movem.l	d6/d7,-(sp)
	moveq.l	#0,d6			; Planes 0 & 1
	moveq.l	#0,d7			; Planes 2 & 3
	rept	16
	moveq.l	#0,d5			; Pixel value
	add.w	d4,d4
	addx.w	d5,d5
	add.w	d3,d3
	addx.w	d5,d5
	add.w	d2,d2
	addx.w	d5,d5
	add.w	d1,d1
	addx.w	d5,d5
	add.w	d0,d0
	addx.w	d5,d5
	move.b	0(a2,d5.w),d5		; ST colour
	lsr.b	#1,d5
	addx.w	d6,d6
	swap	d6
	lsr.b	#1,d5
	addx.w	d6,d6
	swap	d6
	lsr.b	#1,d5
	addx.w	d7,d7
	swap	d7
	lsr.b	#1,d5
	addx.w	d7,d7
	swap	d7
	endr
	move.w	d6,(a1)+			; Plane 0
	swap	d6
	move.w	d6,(a1)+			; Plane 1
	move.w	d7,(a1)+			; Plane 2
	swap	d7
	move.w	d7,(a1)+			; Plane 3
	movem.l	(sp)+,d6/d7
	subq.w	#1,a3
	cmp.w	#0,a3
	bne	.Chunk
	move.w	a4,d0			; Next line
	subq.w	#1,d0
	mulu.w	d6,d0
	add.l	d0,a0
	dbra	d7,.Line
	rts

;*****************************************************************************
; [ ST data of Get_block ]
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
;   - The buffer gets ST data : 4 planes (3 for 3 planes, the colours 24-31)
;     per chunk, and is registered for the Put routines.
Get_block:
	movem.l	d0-d7/a0-a2,-(sp)
	tst.w	d6
	ble	.Exit
	tst.w	d7
	ble	.Exit
	moveq.l	#4,d4			; Planes to store
	cmp.w	#4,d5
	bge.s	.Four
	moveq.l	#3,d4
.Four:	move.l	a0,a2
	move.l	Work_screen,a1
	andi.w	#-16,d0
	jsr	Get_screen_offset
	add.l	d2,a1
	move.w	d7,d3
	subq.w	#1,d3
.Line:	move.l	a1,-(sp)
	move.w	d6,d2
	subq.w	#1,d2
.Chunk:	move.w	(a1)+,(a2)+
	move.w	(a1)+,(a2)+
	move.w	(a1)+,(a2)+
	cmp.w	#3,d4
	beq.s	.Three
	move.w	(a1)+,(a2)+
	bra.s	.Next
.Three:	addq.l	#2,a1
.Next:	dbra	d2,.Chunk
	move.l	(sp)+,a1
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d3,.Line
	move.w	d4,d5			; Register
	add.w	d5,d5
	mulu.w	d6,d5
	mulu.w	d7,d5
	move.l	d5,d0
	jsr	Checksum
	move.l	d0,d1
	lea.l	Raw_buffers,a1		; Same address or free entry
	moveq.l	#Max_raw_buffers-1,d2
.Find:	cmp.l	(a1),a0
	beq.s	.Store
	lea.l	Raw_entry_size(a1),a1
	dbra	d2,.Find
	move.w	Raw_next,d2		; New entry (round robin)
	addq.w	#1,Raw_next
	andi.w	#Max_raw_buffers-1,d2
	mulu.w	#Raw_entry_size,d2
	lea.l	Raw_buffers,a1
	add.w	d2,a1
.Store:	move.l	a0,(a1)+
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	move.w	d4,(a1)+
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Is a buffer ST data of Get_block ? ]
;   IN : a0 - Pointer to graphics (.l)
;  OUT : d0 - Number of planes (.w)
;        pl - Yes, mi - No
; Changed registers : d0
Find_raw_buffer:
	movem.l	d1/d2/a1,-(sp)
	lea.l	Raw_buffers,a1
	moveq.l	#Max_raw_buffers-1,d2
.Find:	cmp.l	(a1),a0
	beq.s	.Found
	lea.l	Raw_entry_size(a1),a1
	dbra	d2,.Find
	bra.s	.No
.Found:	move.l	8(a1),d0			; Same data ?
	jsr	Checksum
	cmp.l	4(a1),d0
	bne.s	.Gone
	moveq.l	#0,d0
	move.w	12(a1),d0
	bra.s	.Exit
.Gone:	clr.l	(a1)			; (other data now)
.No:	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d1/d2/a1
	rts

;*****************************************************************************
; [ Other routines ]
;*****************************************************************************
; [ Copy a block of the shown screen to the work screen ]
;   IN : d0 - X, d1 - Y, d5 - Number of planes, d6 - Width in truncs,
;        d7 - Height (.w)
Duplicate_block:
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
	dbra	d2,.Chunk
	movem.l	(sp)+,a0/a1
	lea.l	ST_bytes_per_line(a0),a0
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Clear a block in one plane of the work screen ] (3D map)
Clear_1plane_block:
	rts

; [ Show a MOVEP screen ] (3D map)
Show_MOVEP_screen:
	rts

	include	ST_KERNEL/RECOLOUR.S	; (Recolour_block of the Amiga version)

	SECTION	Fast_DATA,data
Default_CA:
	dc.w	0		; Rect.Left
	dc.w	$13f		; Rect.Right
	dc.w	0		; Rect.Top
	dc.w	$c7		; Rect.Bottom
Cache_free:	dc.l Cache_pool

	SECTION	Fast_BSS,bss
CA_Sp:	ds.b 52
CA_stack_end:
Pixel_buffer:	ds.b 16
Clip_masks:	ds.w 20
Clip_Y1:	ds.w 1
Clip_Y2:	ds.w 1
Blit_mode:	ds.w 1
Blit_X:	ds.w 1
Blit_Y:	ds.w 1
Blit_colour:	ds.w 1
Blit_silhouette_colour:	ds.w 1
Blit_planes:	ds.w 1
Blit_width:	ds.w 1
Blit_height:	ds.w 1
Blit_decoder:	ds.w 1
Blit_raw_planes:	ds.w 1
Blit_source:	ds.l 1
Blit_LUT:	ds.l 1
Blit_cached:	ds.l 1
Blit_table:	ds.b 32
Line_chunks:	ds.w 5*21
Max_raw_buffers	EQU	16
Raw_entry_size	EQU	14
Raw_buffers:	ds.b Max_raw_buffers*Raw_entry_size
Raw_next:	ds.w 1
Cache_entries	EQU	512
Cache_entry_size	EQU	20
Cache_index:	ds.b Cache_entries*Cache_entry_size
Cache_size	EQU	96*1024
Cache_pool:	ds.b Cache_size
