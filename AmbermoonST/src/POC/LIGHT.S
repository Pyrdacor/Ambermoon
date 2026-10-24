; Proof of concept : light on 2D maps (Atari ST)
;
; Taken from MAP/2D_MAP.S ([ Evaluate_2D_light ], [ Display_2D_night ]) and
; TIME.S ([ Update_light_status ]). Outdoor maps get a light circle around
; the party which depends on the time of day; in dark maps (dungeons) only
; the party is visible (no light spells yet).
;
; The Amiga version erases the area outside the circle every frame with
; boxes and lines. On the ST the map window is drawn with a tile cache, so
; the positions of the map window are classified when the circle changes :
; positions completely outside the circle are drawn black once, positions on
; the edge of the circle are redrawn every frame and the part outside the
; circle is erased line by line.

	SECTION	Program,code

;*****************************************************************************
; [ Re-evaluate light in 2D maps ]
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S (without blindness and light spells).
;*****************************************************************************
Evaluate_2D_light:
	movem.l	d0/d1/a0,-(sp)
	sf	Stygian
	lea.l	Map_data_buffer,a0		; Get map status bits
	move.w	Map_special(a0),d0
	btst	#Light_bit,d0		; Always light ?
	beq.s	.No_light
	move.w	#0,Current_light_level	; No circle
	move.w	#0,New_light_level
	bra	.Exit
.No_light:	btst	#Change_bit,d0		; Changing light ?
	beq.s	.No_change
	move.w	Hour,d0			; Get current hour
	moveq.l	#0,d1			; Get radius
	move.b	.Radius(pc,d0.w),d1
	move.w	d1,New_light_level		; Store
	bra	.Exit
.Radius:	dc.b 16,16,16,16,16,16,40,64
	dcb.b 9,200
	dc.b 64,64,40,16,16,16,16,16
	even
.No_change:	btst	#Dark_bit,d0		; Always dark ?
	sne	Stygian			; (no light spells yet)
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Update light status ]
; All registers are restored
; NOTE :
;   - From TIME.S : no slow change of the radius (when entering a map).
;*****************************************************************************
Update_light_status:
	jsr	Evaluate_2D_light
	move.w	New_light_level,Current_light_level
	move.w	#-1,Light_classified	; Classify again
	rts

;*****************************************************************************
; [ Change the radius of the light circle & classify the map positions ]
; All registers are restored
; NOTE :
;   - The radius is changed like in [ Display_2D_night ] (MAP/2D_MAP.S).
;   - OUT : [ Cell_light ] - per map buffer position : 0 = inside the circle
;           (or no circle), 1 = on the edge, 2 = outside (black)
;*****************************************************************************
Prepare_light:
	movem.l	d0-d7/a0-a4,-(sp)
	jsr	Evaluate_2D_light
	moveq.l	#0,d4			; No circle
	tst.b	Stygian			; Complete darkness ?
	bne	.Dark
	move.w	Current_light_level,d4	; Circle on ?
	bne.s	.Ok
	tst.w	New_light_level
	beq.s	.Store
.Ok:	cmp.w	New_light_level,d4		; New radius ?
	beq.s	.Store
	bmi.s	.Up
	subq.w	#4,d4			; Count down
	bra.s	.Store
.Up:	addq.w	#4,d4			; Count up
.Store:	move.w	d4,Current_light_level	; Store new radius
	cmpi.w	#Max_radius,d4		; Circle visible ?
	bls.s	.Circle
	moveq.l	#0,d4			; No
; ---------- Classify (only when changed) ---------
.Circle:	move.w	Mapbuf_X,d6		; Centre coordinates
	move.w	Mapbuf_Y,d7		;  (in the map window)
	lsl.w	#4,d6
	lsl.w	#4,d7
	addq.w	#8,d6
	addq.w	#8,d7
	cmp.w	Light_classified,d4		; Changed ?
	bne.s	.Do
	cmp.w	Light_centre_X,d6
	bne.s	.Do
	cmp.w	Light_centre_Y,d7
	beq	.Exit
.Do:	move.w	d4,Light_classified
	move.w	d6,Light_centre_X
	move.w	d7,Light_centre_Y
	lea.l	Cell_light,a0
	tst.w	d4			; No circle ?
	bne.s	.Spans
	moveq.l	#Mapbuf_size-1,d0		; Everything is inside
.Clear:	clr.b	(a0)+
	dbra	d0,.Clear
	bra	.Exit
; ---------- Half widths of the circle ------------
.Spans:	lea.l	Circle_span,a1		; -1 = no circle on this line
	moveq.l	#Mapbuf_height*16-1,d0
.Clr:	move.w	#-1,(a1)+
	dbra	d0,.Clr
	lea.l	Circle_span,a1
	move.w	d4,d5			; x = radius
	move.w	d4,d3			; r^2
	mulu.w	d4,d3
	moveq.l	#0,d0			; dy = 0
.Line:	move.w	d0,d1			; x^2 + dy^2 > r^2 ?
	mulu.w	d0,d1
.Shrink:	move.w	d5,d2
	mulu.w	d5,d2
	add.l	d1,d2
	cmp.l	d3,d2
	ble.s	.Fits
	subq.w	#1,d5
	bra.s	.Shrink
.Fits:	move.w	d7,d1			; Store for centre +/- dy
	add.w	d0,d1
	cmp.w	#Mapbuf_height*16,d1
	bcc.s	.No1
	add.w	d1,d1
	move.w	d5,0(a1,d1.w)
.No1:	move.w	d7,d1
	sub.w	d0,d1
	cmp.w	#Mapbuf_height*16,d1
	bcc.s	.No2
	add.w	d1,d1
	move.w	d5,0(a1,d1.w)
.No2:	addq.w	#1,d0
	cmp.w	d4,d0
	ble.s	.Line
; ---------- Classify the positions ---------------
	move.w	Light_centre_X,a3
	moveq.l	#0,d1			; Y of position
	moveq.l	#Mapbuf_height-1,d7
.Loop_Y:	moveq.l	#0,d0			; X of position
	moveq.l	#Mapbuf_width-1,d6
.Loop_X:	moveq.l	#0,d2			; Lines inside / outside
	moveq.l	#0,d3
	move.w	d0,a2			; Right end of position
	addq.w	#8,a2
	addq.w	#7,a2
	move.w	d1,d5			; First line
	add.w	d5,d5
	lea.l	0(a1,d5.w),a0
	move.w	#16,a4
.Loop_L:	move.w	(a0)+,d4			; Half width
	bmi.s	.Out
	move.w	a3,d5			; Left edge
	sub.w	d4,d5
	add.w	a3,d4			; Right edge
	cmp.w	d0,d5			; Line completely inside ?
	bgt.s	.Not_in_l
	cmp.w	a2,d4
	blt.s	.Not_in_l
	addq.w	#1,d2			; Inside
	bra.s	.Next_L
.Not_in_l:	cmp.w	d0,d4			; Line completely outside ?
	blt.s	.Out
	cmp.w	a2,d5
	bgt.s	.Out
	bra.s	.Next_L			; Partly
.Out:	addq.w	#1,d3			; Outside
.Next_L:	subq.w	#1,a4
	cmp.w	#0,a4
	bne.s	.Loop_L
	moveq.l	#1,d4			; Edge
	cmp.w	#16,d2
	bne.s	.Not_in
	moveq.l	#0,d4			; Inside
.Not_in:	cmp.w	#16,d3
	bne.s	.Not_out
	moveq.l	#2,d4			; Outside
.Not_out:	move.w	d1,d5			; Store
	lsr.w	#4,d5
	mulu.w	#Mapbuf_width,d5
	move.w	d0,d2
	lsr.w	#4,d2
	add.w	d2,d5
	lea.l	Cell_light,a0
	move.b	d4,0(a0,d5.w)
	addi.w	#16,d0
	dbra	d6,.Loop_X
	addi.w	#16,d1
	dbra	d7,.Loop_Y
	bra.s	.Exit
; ---------- Complete darkness --------------------
.Dark:	move.w	#-2,Light_classified
	lea.l	Cell_light,a0
	moveq.l	#Mapbuf_size-1,d0
.Black:	move.b	#2,(a0)+
	dbra	d0,.Black
.Exit:	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Erase the parts outside the light circle ]
; All registers are restored
; NOTE :
;   - Called after all graphics of the map window have been drawn. Erases
;     the edge positions outside the circle and the dark positions which
;     have persons on them. In complete darkness the party stays visible.
;*****************************************************************************
Display_2D_night:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Cell_light,a2
	lea.l	Sprite_cells,a3
	moveq.l	#0,d1			; Y of position
	moveq.l	#0,d2			; Position
	moveq.l	#Mapbuf_height-1,d7
.Loop_Y:	moveq.l	#0,d0			; X of position
	moveq.l	#Mapbuf_width-1,d6
.Loop_X:	move.b	0(a2,d2.w),d3
	beq.s	.Next			; Inside ?
	cmp.b	#1,d3			; Edge ?
	beq.s	.Edge
	tst.b	0(a3,d2.w)		; Dark : any sprite here ?
	beq.s	.Next
	tst.b	Stygian			; Complete darkness :
	beq.s	.Black			;  the party stays visible
	cmp.w	Party_cell,d2
	beq.s	.Next
	move.w	Party_cell,d3
	subi.w	#Mapbuf_width,d3
	cmp.w	d3,d2
	beq.s	.Next
.Black:	jsr	Erase_position
	bra.s	.Next
.Edge:	jsr	Erase_edge_position
.Next:	addi.w	#16,d0
	addq.w	#1,d2
	dbra	d6,.Loop_X
	addi.w	#16,d1
	dbra	d7,.Loop_Y
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Erase a map buffer position completely ]
;   IN : d0 - X in the map window (.w)
;        d1 - Y in the map window (.w)
; All registers are restored
;*****************************************************************************
Erase_position:
	movem.l	d0/d1,-(sp)
	addi.w	#Map2D_X,d0
	addi.w	#Map2D_Y,d1
	jsr	Clear_icon
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Erase the part of an edge position outside the circle ]
;   IN : d0 - X in the map window (multiple of 16) (.w)
;        d1 - Y in the map window (.w)
; All registers are restored
;*****************************************************************************
Erase_edge_position:
	movem.l	d0-d7/a0/a1,-(sp)
	move.l	Work_screen,a1		; Screen address of position
	movem.w	d0/d1,-(sp)
	addi.w	#Map2D_X,d0
	addi.w	#Map2D_Y,d1
	jsr	Get_screen_offset_d0d1
	movem.w	(sp)+,d0/d1
	lea.l	Circle_span,a0
	add.w	d1,d1
	add.w	d1,a0
	move.w	Light_centre_X,d6
	moveq.l	#16-1,d7
.Line:	move.w	(a0)+,d4			; Half width
	bmi.s	.All
	move.w	d6,d2			; Visible pixels : d2 ... d3
	sub.w	d4,d2
	move.w	d6,d3
	add.w	d4,d3
	sub.w	d0,d2			; Relative to the position
	sub.w	d0,d3
	moveq.l	#-1,d5			; Mask of visible pixels
	tst.w	d2
	ble.s	.L_ok
	cmp.w	#16,d2
	bge.s	.All
	lsr.w	d2,d5
.L_ok:	tst.w	d3
	bmi.s	.All
	cmp.w	#15,d3
	bge.s	.Do
	moveq.l	#15,d4
	sub.w	d3,d4
	move.w	#$ffff,d3
	lsl.w	d4,d3
	and.w	d3,d5
	bra.s	.Do
.All:	moveq.l	#0,d5			; Nothing visible
.Do:	and.w	d5,(a1)			; Erase the rest
	and.w	d5,2(a1)
	and.w	d5,4(a1)
	and.w	d5,6(a1)
	lea.l	ST_bytes_per_line(a1),a1
	dbra	d7,.Line
	movem.l	(sp)+,d0-d7/a0/a1
	rts

	SECTION	Fast_BSS,bss
Current_light_level:	ds.w 1
New_light_level:	ds.w 1
Light_classified:	ds.w 1
Light_centre_X:	ds.w 1
Light_centre_Y:	ds.w 1
Stygian:	ds.b 1
	even
Cell_light:	ds.b Mapbuf_size
	even
Circle_span:	ds.w Mapbuf_height*16
