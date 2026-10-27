; Blocks, icons, boxes, clip areas (Atari ST)
; Replaces KERNEL/GRAPHICS.S of the Amiga version.
;
; The routines have the same names and parameters as in the Amiga version.
; The graphics are converted in advance (see tools/st_convert.py) into the ST
; format : per line and per 16 pixels ("trunc") 4 words (planes 0...3), with
; the final ST colours. So the parameters base colour (d4) and number of
; planes (d5) are not needed and ignored. Colour 0 is transparent for masked
; graphics.

	SECTION	Program,code

;*****************************************************************************
; [ Calculate offset of a pixel in a screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : d2 - Byte offset in screen (.l)
;        d3 - X-coordinate & 15 (.w)
;*****************************************************************************
Get_screen_offset:
	move.l	d0,-(sp)
	move.w	d1,d2
	mulu.w	#ST_bytes_per_line,d2
	moveq.l	#15,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0			; 8 bytes per 16 pixels
	add.w	d0,d2
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Put an unmasked 16x16 icon on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w) (ignored)
;        d5 - Number of planes (.w) (ignored)
;        a0 - Pointer to icon graphics (.l)
; All registers are restored
;*****************************************************************************
Put_unmasked_icon:
	movem.l	d0-d3/d7/a0/a1,-(sp)
	move.l	Work_screen,a1
	andi.w	#-$10,d0
	jsr	Get_screen_offset
	add.l	d2,a1
	moveq.l	#16-1,d7
.Loop:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)
	lea.l	ST_bytes_per_line-4(a1),a1
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d3/d7/a0/a1
	rts

;*****************************************************************************
; [ Put a masked 16x16 icon on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w) (ignored)
;        d5 - Number of planes (.w) (ignored)
;        a0 - Pointer to icon graphics (.l)
; All registers are restored
;*****************************************************************************
Put_masked_icon:
	movem.l	d0-d7/a0/a1,-(sp)
	move.l	Work_screen,a1
	andi.w	#-$10,d0
	jsr	Get_screen_offset
	add.l	d2,a1
	moveq.l	#16-1,d7
.Loop:	movem.w	(a0)+,d0-d3		; Get planes
	move.w	d0,d4			; Make mask
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	not.w	d4
	and.w	d4,(a1)			; Put
	or.w	d0,(a1)+
	and.w	d4,(a1)
	or.w	d1,(a1)+
	and.w	d4,(a1)
	or.w	d2,(a1)+
	and.w	d4,(a1)
	or.w	d3,(a1)
	lea.l	ST_bytes_per_line-6(a1),a1
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d7/a0/a1
	rts

;*****************************************************************************
; [ Put an unmasked block on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w) (ignored)
;        d5 - Number of planes (.w) (ignored)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
; NOTE :
;   - The X-coordinate is rounded down to a multiple of 16.
;*****************************************************************************
Put_unmasked_block:
	movem.l	d0-d7/a0-a2,-(sp)
	tst.w	d6
	ble.s	.Exit
	tst.w	d7
	ble.s	.Exit
	move.l	Work_screen,a1
	andi.w	#-$10,d0
	jsr	Get_screen_offset
	add.l	d2,a1
	subq.w	#1,d6
	subq.w	#1,d7
.Loop:	move.l	a1,a2
	move.w	d6,d5
.Loop2:	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbra	d5,.Loop2
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Get a block from the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d5 - Number of planes (.w) (ignored)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to buffer (.l)
; All registers are restored
; NOTE :
;   - The X-coordinate is rounded down to a multiple of 16. The block can be
;     put back with [ Put_unmasked_block ].
;*****************************************************************************
Get_block:
	movem.l	d0-d7/a0-a2,-(sp)
	tst.w	d6
	ble.s	.Exit
	tst.w	d7
	ble.s	.Exit
	move.l	Work_screen,a1
	andi.w	#-$10,d0
	jsr	Get_screen_offset
	add.l	d2,a1
	subq.w	#1,d6
	subq.w	#1,d7
.Loop:	move.l	a1,a2
	move.w	d6,d5
.Loop2:	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	dbra	d5,.Loop2
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Put a masked block on the work screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w) (ignored)
;        d5 - Number of planes (.w) (ignored)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
; NOTE :
;   - The block is clipped against the current clip area.
;   - Any X-coordinate >= 0 is possible.
;*****************************************************************************
Put_masked_block:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	d6
	ble	.Exit
	tst.w	d7
	ble	.Exit
	move.l	CA_Sp,a2			; Get clip area
	move.l	(a2),a2
	move.w	d6,d2			; Source bytes per line
	lsl.w	#3,d2
	move.w	d2,a3
; ---------- Clip top & bottom --------------------
	move.w	CA_Y1(a2),d3		; Top
	sub.w	d1,d3
	ble.s	.No_top
	sub.w	d3,d7
	ble	.Exit
	add.w	d3,d1
	mulu.w	d2,d3
	add.l	d3,a0
.No_top:	move.w	d1,d3			; Bottom
	add.w	d7,d3
	subq.w	#1,d3
	sub.w	CA_Y2(a2),d3
	ble.s	.No_bottom
	sub.w	d3,d7
	ble	.Exit
.No_bottom:	jsr	Make_clip_table
; ---------- Prepare ------------------------------
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	move.l	Clip_table_ptr,a6		; Clip mask of first trunc
	move.w	d0,d2
	lsr.w	#4,d2
	add.w	d2,d2
	add.w	d2,a6
	move.l	a6,Clip_start
	move.w	d3,Block_shift
	move.w	d6,d5			; Number of truncs
	subq.w	#1,d5
	move.w	d5,Block_truncs
	move.w	d7,d6			; Number of lines
	subq.w	#1,d6
	move.w	Block_shift,d7
	beq	.Aligned
; ---------- Draw ---------------------------------
.Line:	move.l	a0,a4
	move.l	a1,a5
	move.l	Clip_start,a6
	move.w	Block_truncs,d5
.Trunc:	moveq.l	#0,d0			; Get planes
	move.w	(a4)+,d0
	moveq.l	#0,d1
	move.w	(a4)+,d1
	moveq.l	#0,d2
	move.w	(a4)+,d2
	moveq.l	#0,d3
	move.w	(a4)+,d3
	move.l	d0,d4			; Make mask
	or.l	d1,d4
	or.l	d2,d4
	or.l	d3,d4
	beq.s	.Next			; Nothing to do
	swap	d0			; Shift
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	lsr.l	d7,d0
	lsr.l	d7,d1
	lsr.l	d7,d2
	lsr.l	d7,d3
	lsr.l	d7,d4
	and.l	(a6),d4			; Clip
	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	not.l	d4
	swap	d0			; Left trunc
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	and.w	d4,(a5)
	or.w	d0,(a5)
	and.w	d4,2(a5)
	or.w	d1,2(a5)
	and.w	d4,4(a5)
	or.w	d2,4(a5)
	and.w	d4,6(a5)
	or.w	d3,6(a5)
	tst.w	d7			; Right trunc
	beq.s	.Next
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	and.w	d4,8(a5)
	or.w	d0,8(a5)
	and.w	d4,10(a5)
	or.w	d1,10(a5)
	and.w	d4,12(a5)
	or.w	d2,12(a5)
	and.w	d4,14(a5)
	or.w	d3,14(a5)
.Next:	addq.l	#8,a5
	addq.l	#2,a6
	dbra	d5,.Trunc
	add.l	a3,a0			; Next line
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d6,.Line
	bra	.Exit
; ---------- Draw (X is a multiple of 16) ---------
.Aligned:	move.l	a0,a4
	move.l	a1,a5
	move.l	Clip_start,a6
	move.w	Block_truncs,d5
.Trunc2:	movem.w	(a4)+,d0-d3		; Get planes
	move.w	d0,d4			; Make mask
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	and.w	(a6)+,d4			; Clip
	beq.s	.Next3
	and.w	d4,d0
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3
	not.w	d4
	and.w	d4,(a5)
	or.w	d0,(a5)+
	and.w	d4,(a5)
	or.w	d1,(a5)+
	and.w	d4,(a5)
	or.w	d2,(a5)+
	and.w	d4,(a5)
	or.w	d3,(a5)+
	dbra	d5,.Trunc2
	bra.s	.Next4
.Next3:	addq.l	#8,a5
	dbra	d5,.Trunc2
.Next4:	add.l	a3,a0			; Next line
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d6,.Aligned
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Make the horizontal clip masks of the current clip area ]
; All registers are restored
; NOTE :
;   - A clip table contains one mask word for each trunc of a line (+ 2
;     extra words, which are always 0). The last two tables are kept.
;   - OUT : [ Clip_table_ptr ] - Pointer to the clip table.
;*****************************************************************************
Make_clip_table:
	movem.l	d0-d4/a0-a2,-(sp)
	move.l	CA_Sp,a1
	move.l	(a1),a1
	lea.l	Clip_tables,a2		; Already made ? (2 tables)
	moveq.l	#2-1,d4
.Find:	move.l	CA_X1(a1),d0
	cmp.l	(a2),d0
	beq.s	.Found
	lea.l	4+24*2(a2),a2
	dbra	d4,.Find
	lea.l	Clip_tables,a2		; No -> replace the older one
	tst.b	Clip_table_next
	beq.s	.First
	lea.l	4+24*2(a2),a2
.First:	not.b	Clip_table_next
	move.l	CA_X1(a1),(a2)
	lea.l	4(a2),a0
	moveq.l	#0,d0			; X of trunc
.Loop:	move.w	CA_X1(a1),d1		; Left
	sub.w	d0,d1
	move.w	CA_X2(a1),d2		; Right
	sub.w	d0,d2
	bmi.s	.Zero
	cmp.w	#15,d1
	bgt.s	.Zero
	tst.w	d1
	bpl.s	.Ok1
	moveq.l	#0,d1
.Ok1:	cmp.w	#15,d2
	ble.s	.Ok2
	moveq.l	#15,d2
.Ok2:	move.w	#$ffff,d3			; Left mask
	lsr.w	d1,d3
	move.w	#$ffff,d1			; Right mask
	moveq.l	#15,d4
	sub.w	d2,d4
	lsl.w	d4,d1
	and.w	d1,d3
	move.w	d3,(a0)+
	bra.s	.Next
.Zero:	clr.w	(a0)+
.Next:	addi.w	#16,d0
	cmp.w	#22*16,d0
	bmi.s	.Loop
	clr.l	(a0)			; 2 extra words
.Found:	lea.l	4(a2),a2
	move.l	a2,Clip_table_ptr
	movem.l	(sp)+,d0-d4/a0-a2
	rts

;*****************************************************************************
; [ Draw a filled box ]
;   IN : d0 - Left X (.w)
;        d1 - Top Y (.w)
;        d2 - Right X (.w)
;        d3 - Bottom Y (.w)
;        d4 - Colour (Amiga colour number) (.w)
; All registers are restored
; NOTE :
;   - The box is clipped against the current clip area.
;   - The colour is translated with the palette of the top line.
;*****************************************************************************
Draw_box:
	movem.l	d0-d7/a0-a3,-(sp)
	cmp.w	d0,d2
	bpl.s	.Skip
	exg	d0,d2
.Skip:	cmp.w	d1,d3
	bpl.s	.Skip2
	exg	d1,d3
.Skip2:	move.l	CA_Sp,a0			; Clip
	move.l	(a0),a0
	cmp.w	CA_X1(a0),d0
	bpl.s	.C1
	move.w	CA_X1(a0),d0
.C1:	cmp.w	CA_X2(a0),d2
	ble.s	.C2
	move.w	CA_X2(a0),d2
.C2:	cmp.w	CA_Y1(a0),d1
	bpl.s	.C3
	move.w	CA_Y1(a0),d1
.C3:	cmp.w	CA_Y2(a0),d3
	ble.s	.C4
	move.w	CA_Y2(a0),d3
.C4:	cmp.w	d0,d2
	bmi	.Exit
	cmp.w	d1,d3
	bmi	.Exit
	jsr	Get_ST_colour		; Translate colour
	lea.l	Box_pattern,a1		; Make plane patterns
	moveq.l	#4-1,d7
.Loop0:	lsr.w	#1,d4
	scs	d5
	ext.w	d5
	move.w	d5,(a1)+
	dbra	d7,.Loop0
	move.w	d3,d7			; Number of lines
	sub.w	d1,d7
	move.l	Work_screen,a1
	jsr	Get_screen_offset_d0d1	; a1 += offset of (d0,d1)
	move.w	d0,d5			; Masks of first & last trunc
	andi.w	#15,d5
	move.w	#$ffff,d4
	lsr.w	d5,d4			; Left mask
	move.w	d2,d5
	andi.w	#15,d5
	moveq.l	#15,d6
	sub.w	d5,d6
	move.w	#$ffff,d5
	lsl.w	d6,d5			; Right mask
	move.w	d2,d6			; Number of truncs - 1
	lsr.w	#4,d6
	move.w	d0,d3
	lsr.w	#4,d3
	sub.w	d3,d6
	bne.s	.Multi
	and.w	d5,d4			; Only one trunc
.Multi:	lea.l	Box_pattern,a3
.Line:	move.l	a1,a2
	move.w	d6,d3
	move.w	d4,d0			; First mask
.Trunc:	tst.w	d3			; Last trunc ?
	bne.s	.Not_last
	tst.w	d6
	beq.s	.Not_last
	move.w	d5,d0
.Not_last:	move.w	d0,d1			; screen = (screen & ~mask) | (pattern & mask)
	not.w	d1
	move.w	(a3),d2
	and.w	d0,d2
	and.w	d1,(a2)
	or.w	d2,(a2)+
	move.w	2(a3),d2
	and.w	d0,d2
	and.w	d1,(a2)
	or.w	d2,(a2)+
	move.w	4(a3),d2
	and.w	d0,d2
	and.w	d1,(a2)
	or.w	d2,(a2)+
	move.w	6(a3),d2
	and.w	d0,d2
	and.w	d1,(a2)
	or.w	d2,(a2)+
	moveq.l	#-1,d0			; Middle truncs
	dbra	d3,.Trunc
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d7,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Add the screen offset of a pixel to a pointer ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a1 - Pointer to screen (.l)
;  OUT : a1 - Pointer to the trunc of the pixel (.l)
; Changed registers : a1
;*****************************************************************************
Get_screen_offset_d0d1:
	movem.l	d2/d3,-(sp)
	jsr	Get_screen_offset
	add.l	d2,a1
	movem.l	(sp)+,d2/d3
	rts

;*****************************************************************************
; [ Push a clip area on the stack ]
;   IN : a0 - Pointer to CA (.l)
; All registers are restored
;*****************************************************************************
Push_CA:
	move.l	a1,-(sp)
	move.l	CA_Sp,a1
	addq.l	#4,a1
	cmp.l	#CA_stack_end,a1
	beq.s	.Exit
	move.l	a0,(a1)
	move.l	a1,CA_Sp
.Exit:	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Pop a clip area from the stack ]
; All registers are restored
;*****************************************************************************
Pop_CA:
	move.l	a0,-(sp)
	move.l	CA_Sp,a0
	cmp.l	#CA_Sp+4,a0
	beq.s	.Exit
	subq.l	#4,a0
	move.l	a0,CA_Sp
.Exit:	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Reset the clip area stack ]
; All registers are restored
;*****************************************************************************
Reset_CA_stack:
	move.l	a0,-(sp)
	lea.l	CA_Sp+4,a0
	move.l	a0,CA_Sp
	move.l	#Default_CA,(a0)
	move.l	(sp)+,a0
	rts

	SECTION	Fast_DATA,data
Default_CA:
	dc.w	0,319,0,199

	SECTION	Fast_BSS,bss
Box_pattern:	ds.w 4
Block_shift:	ds.w 1
Block_truncs:	ds.w 1
Clip_start:	ds.l 1
Clip_table_ptr:	ds.l 1
Clip_table_next:	ds.b 1
	even
Clip_tables:	ds.b 2*(4+24*2)		; CA X1 & X2 (.l), 24 masks
CA_Sp:	ds.l 1
	ds.l	12			; CA stack
CA_stack_end:
