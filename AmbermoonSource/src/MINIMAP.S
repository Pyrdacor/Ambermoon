; Minimap
; Written by J.Horneman (In Tune With The Universe)
; Start : 25-6-1993

	SECTION	Program,code
;*****************************************************************************
; [ Minimap ]
;*****************************************************************************
Minimap_ModInit:
	Push	Mptr,Zzz_Mptr		; Z!
	move.w	#Minimap_window_X+Minimap_window_width/2,Mouse_X		; Centre mouse
	move.w	#Minimap_window_Y+Minimap_window_height/2,Mouse_Y
	clr.w	Minimap_X			; Clear variables
	clr.w	Minimap_Y
	clr.w	Minimap_centre_X
	clr.w	Minimap_centre_Y
	move.b	Current_map_type,d0		; What kind of map ?
	cmp.b	#Map_3D,d0		; 2D or 3D ?
	bpl	.3D
	cmp.b	#World_2D,Current_map_type	; 2D world map ?
	beq	.World
; ---------- 2D city map --------------------------
	lea.l	C2_colour_converter,a5
	move.w	Width_of_map,d0		; Set minimap dimensions
	move.w	Height_of_map,d1
	move.w	d0,Minimap_width
	move.w	d1,Minimap_height
	jsr	Create_minimap		; Make buffer
	moveq.l	#0,d0			; Build minimap
	moveq.l	#0,d1
	move.b	Mapdata_handle,d7
	jsr	Insert_2D_in_minimap
	bra	.Done
; ---------- 2D world map -------------------------
.World:	lea.l	W2_colour_converter,a5
	move.w	Submap_width,d0		; Set minimap dimensions
	add.w	d0,d0
	move.w	Submap_height,d1
	add.w	d1,d1
	move.w	d0,Minimap_width
	move.w	d1,Minimap_height
	jsr	Create_minimap		; Make buffer
	moveq.l	#0,d0			; Build minimap of map 0
	moveq.l	#0,d1
	move.b	Quadmap_0+Quad_map_handle,d7
	jsr	Insert_2D_in_minimap
	add.w	Submap_width,d0		; Build minimap of map 1
	move.b	Quadmap_1+Quad_map_handle,d7
	jsr	Insert_2D_in_minimap
	move.w	Submap_height,d1		; Build minimap of map 2
	move.b	Quadmap_3+Quad_map_handle,d7
	jsr	Insert_2D_in_minimap
	sub.w	Submap_width,d0		; Build minimap of map 3
	move.b	Quadmap_2+Quad_map_handle,d7
	jsr	Insert_2D_in_minimap
	bra	.Done
; ---------- 3D map -------------------------------
.3D:	lea.l	M3_colour_converter,a5
	move.w	Width_of_map,d0		; Set minimap dimensions
	move.w	Height_of_map,d1
	move.w	d0,Minimap_width
	move.w	d1,Minimap_height
	jsr	Create_minimap		; Make buffer
	moveq.l	#0,d0			; Build minimap
	moveq.l	#0,d1
	move.b	Mapdata_handle,d7
	jsr	Insert_3D_in_minimap
; ---------- The rest -----------------------------
.Done:	Pop	Mptr
	move.w	Minimap_width,d0		; Scroll horizontally ?
	cmp.w	#Minimap_window_width/2+1,d0
	spl	Automap_scroll_X
	bpl.s	.Skip_X
	move.w	#Minimap_window_width,d0	; No -> Centre
	sub.w	Width_of_map,d0
	sub.w	Width_of_map,d0
	lsr.w	#1,d0
	move.w	d0,Minimap_centre_X
.Skip_X:	move.w	Minimap_height,d0		; Scroll vertically ?
	cmp.w	#Minimap_window_height/2+1,d0
	spl	Automap_scroll_Y
	bpl.s	.Skip_Y
	move.w	#Minimap_window_height,d0	; No -> Centre
	sub.w	Height_of_map,d0
	sub.w	Height_of_map,d0
	lsr.w	#1,d0
	move.w	d0,Minimap_centre_Y
.Skip_Y:	jmp	Minimap_DisInit		; Build screen

Minimap_ModExit:
	move.b	Minimap_handle,d0		; Free memory
	jsr	Free_memory
	jsr	Wait_4_unclick		; Wait
	jmp	Close_window

Minimap_DisInit:
	move.w	#Minimap_window_X-16,d0	; Open window
	move.w	#Minimap_window_Y-16,d1
	moveq.l	#Minimap_window_width/16+2,d2
	moveq.l	#Minimap_window_height/16+2,d3
	lea.l	Minimap_L1,a0
	jsr	Open_window
	jsr	Minimap_DisUpd		; Display minimap
	jmp	Update_screen

Minimap_DisUpd:
	Push	CA,Minimap_CA
	move.w	#Minimap_window_X,d0	; Draw black box
	move.w	#Minimap_window_Y,d1
	move.w	#Minimap_window_X+Minimap_window_width-1,d2
	move.w	#Minimap_window_Y+Minimap_window_height-1,d3
	moveq.l	#0,d4
	jsr	Draw_box
; ---------- Display minimap ----------------------
	move.w	Minimap_X,d0		; Get coordinates
	move.w	Minimap_Y,d1
	add.w	d0,d0
	add.w	d1,d1
	neg.w	d0
	neg.w	d1
	add.w	Minimap_centre_X,d0
	add.w	Minimap_centre_Y,d1
	addi.w	#Minimap_window_X,d0
	addi.w	#Minimap_window_Y,d1
	move.w	Minimap_width,d6		; Get dimensions
	addq.w	#7,d6
	lsr.w	#3,d6
	move.w	Minimap_height,d7
	add.w	d7,d7
	moveq.l	#Screen_depth,d5		; Display minimap
	Get	Minimap_handle,a0
	jsr	Put_masked_block
	Free	Minimap_handle
; ---------- Display party's position -------------
	move.w	Map_Xcoord,d0		; Get party coordinates
	move.w	Map_Ycoord,d1
	cmpi.b	#1,Current_map_type		; 2D world map ?
	bne.s	.No
	move.w	Quad_index,d2		; Yes -> Adapt coordinates
	btst	#0,d2
	beq.s	.Zero
	add.w	Submap_width,d0
.Zero:	btst	#1,d2
	beq.s	.No
	add.w	Submap_height,d1
.No:	subq.w	#1,d0			; BASE 0
	subq.w	#1,d1
	sub.w	Minimap_X,d0		; Adjust for scrolling
	sub.w	Minimap_Y,d1
	add.w	d0,d0
	add.w	d1,d1
	add.w	Minimap_centre_X,d0		; Adjust for centering
	add.w	Minimap_centre_Y,d1
	addi.w	#Minimap_window_X-4,d0
	addi.w	#Minimap_window_Y-4,d1
	move.w	Minimap_frame,d2		; Animate
	addq.w	#1,d2
	andi.w	#$000f,d2
	move.w	d2,Minimap_frame
	lea.l	Magic8_stars,a0		; Get frame address
	lsr.w	#2,d2
	mulu.w	#10*3*2,d2
	add.w	d2,a0
	moveq.l	#24,d4			; Display
	moveq.l	#3,d5
	moveq.l	#1,d6
	moveq.l	#10,d7
	jsr	Put_masked_block
	Pop	CA
	rts

;*****************************************************************************
; [ Minimap controls ]
;*****************************************************************************
Move_minimap:
	lsr.w	#8,d0			; In bump area ?
	tst.b	d0
	beq	.Exit
	andi.w	#$000f,d0			; Get bump area number
	subq.w	#1,d0
	move.w	d0,d1
	andi.w	#$0006,d1			; Execute first movement
	add.w	d1,d1
	move.l	.Ptrs(pc,d1.w),a0
	movem.w	d0/d1,-(sp)
	jsr	(a0)
	movem.w	(sp)+,d0/d1
	btst	#0,d0			; Diagonal ?
	beq.s	.Exit
	move.l	.Ptrs+4(pc,d1.w),a0		; Yes -> Execute second
	jsr	(a0)
.Exit:	rts

.Ptrs:	dc.l Minimap_up
	dc.l Minimap_right
	dc.l Minimap_down
	dc.l Minimap_left
	dc.l Minimap_up

Minimap_up:
	tst.b	Automap_scroll_Y		; Scroll ?
	beq.s	.Exit
	move.w	Minimap_Y,d0		; Yes
	subq.w	#2,d0
	bmi.s	.Exit
	move.w	d0,Minimap_Y
.Exit:	rts

Minimap_left:
	tst.b	Automap_scroll_Y		; Scroll ?
	beq.s	.Exit
	move.w	Minimap_X,d0		; Yes
	subq.w	#2,d0
	bmi.s	.Exit
	move.w	d0,Minimap_X
.Exit:	rts

Minimap_right:
	tst.b	Automap_scroll_Y		; Scroll ?
	beq.s	.Exit
	move.w	Minimap_X,d0		; Yes
	addq.w	#2,d0
	move.w	Minimap_width,d1
	subi.w	#Minimap_window_width/2-1,d1
	cmp.w	d1,d0
	bpl.s	.Exit
	move.w	d0,Minimap_X
.Exit:	rts

Minimap_down:
	tst.b	Automap_scroll_Y		; Scroll ?
	beq.s	.Exit
	move.w	Minimap_Y,d0		; Yes
	addq.w	#2,d0
	move.w	Minimap_height,d1
	subi.w	#Minimap_window_height/2-1,d1
	cmp.w	d1,d0
	bpl.s	.Exit
	move.w	d0,Minimap_Y
.Exit:	rts

;*****************************************************************************
; [ Insert 2D map in minimap ]
;   IN : d0 - Start X-coordinate in minimap (.w)
;        d1 - Start Y-coordinate in minimap (.w)
;        d7 - Map data handle (.b)
; All registers are restored
;*****************************************************************************
Insert_2D_in_minimap:
	movem.l	d0-d2/d5-d7/a0/a1,-(sp)
	move.w	d0,d5			; Save
	move.w	d7,-(sp)
	Get	d7,a0
	lea.l	Map_data(a0),a0
	Get	Icondata_handle,a1
	subq.l	#8-2,a1			; !
	move.w	Height_of_map,d7		; Do map
	subq.w	#1,d7
.Loop_Y:	move.w	d5,d0			; Do one line of map
	move.w	Width_of_map,d6
	subq.w	#1,d6
.Loop_X:	moveq.l	#0,d2			; Display underlay
	move.b	(a0),d2
	lsl.w	#3,d2
	move.b	Icon_minimap_colour(a1,d2.w),d2
	jsr	Set_full_minimap_element
	move.w	2(a0),d2			; Display overlay
	beq.s	.Next_X
	lsl.w	#3,d2
	move.b	Icon_minimap_colour(a1,d2.w),d2
	jsr	Set_half_minimap_element
.Next_X:	addq.l	#4,a0			; Next X
	addq.w	#1,d0
	dbra	d6,.Loop_X
	addq.w	#1,d1			; Next Y
	dbra	d7,.Loop_Y
	Free	Icondata_handle
	move.w	(sp)+,d0
	jsr	Free_pointer
	movem.l	(sp)+,d0-d2/d5-d7/a0/a1
	rts

;*****************************************************************************
; [ Insert 3D map in minimap ]
;   IN : d0 - Start X-coordinate in minimap (.w)
;        d1 - Start Y-coordinate in minimap (.w)
;        d7 - Map data handle (.b)
; All registers are restored
;*****************************************************************************
Insert_3D_in_minimap:
	movem.l	d0-d2/d5-d7/a0-a2,-(sp)
	move.w	d0,d5			; Save
	move.w	d7,-(sp)
	Get	d7,a0
	lea.l	Map_data(a0),a0
	Get	Labdata_handle,a1
	lea.l	Wall_data_offsets,a2
	move.w	Height_of_map,d7		; Do map
	subq.w	#1,d7
.Loop_Y:	move.w	d5,d0			; Do one line of map
	move.w	Width_of_map,d6
	subq.w	#1,d6
.Loop_X:	moveq.l	#0,d2			; Get map byte
	move.b	(a0),d2
	cmp.b	#-1,d2			; -1 ?
	beq.s	.Next_X
	cmp.w	#First_wall,d2		; Wall ?
	bmi.s	.Next_X
	subi.w	#First_wall,d2		; Display
	lsl.w	#2,d2
	move.l	0(a2,d2.w),d2
	move.b	Wall_minimap_colour(a1,d2.l),d2
	jsr	Set_full_minimap_element
.Next_X:	addq.l	#2,a0			; Next X
	addq.w	#1,d0
	dbra	d6,.Loop_X
	addq.w	#1,d1			; Next Y
	dbra	d7,.Loop_Y
	Free	Labdata_handle
	move.w	(sp)+,d0
	jsr	Free_pointer
	movem.l	(sp)+,d0-d2/d5-d7/a0-a2
	rts

;*****************************************************************************
; [ Set full minimap element in minimap graphics buffer ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Colour index {0...15} (.w)
;        a5 - Pointer to colour conversion table (.l)
; All registers are restored
;*****************************************************************************
Set_full_minimap_element:
	movem.l	d0-d2/d5-d7/a0,-(sp)
	andi.w	#$000f,d2			; Convert colour
	move.b	0(a5,d2.w),d2
	move.w	Minimap_width,d6		; Calculate size of one line
	addq.w	#7,d6
	andi.w	#$fff8,d6
	lsr.w	#2,d6
	move.w	d6,d5
	mulu.w	#Screen_depth,d6
	Get	Minimap_handle,a0		; Get minimap address
	mulu.w	d6,d1
	add.w	d1,d1
	adda.w	d1,a0
	move.w	d0,d1
	andi.w	#$fff8,d1
	lsr.w	#2,d1
	add.w	d1,a0
	andi.w	#$0007,d0			; Calculate shift value
	add.w	d0,d0
	move.w	#$c000,d1			; Calculate graphic masks
	lsr.w	d0,d1
	move.w	d1,d0
	not.w	d1
	moveq.l	#Screen_depth-1,d7		; Do
.Loop:	ror.b	#1,d2			; Test colour
	bcc.s	.Clear
	or.w	d0,0(a0,d6.w)		; Set plane
	or.w	d0,(a0)
	bra.s	.Next
.Clear:	and.w	d1,0(a0,d6.w)		; Clear plane
	and.w	d1,(a0)
.Next:	add.w	d5,a0			; Next plane
	dbra	d7,.Loop
	Free	Minimap_handle
	movem.l	(sp)+,d0-d2/d5-d7/a0
	rts

;*****************************************************************************
; [ Set half minimap element in minimap graphics buffer ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Colour index {0...15} (.w)
;        a5 - Pointer to colour conversion table (.l)
; All registers are restored
;*****************************************************************************
Set_half_minimap_element:
	movem.l	d0-d2/d5-d7/a0,-(sp)
	andi.w	#$000f,d2			; Convert colour
	move.b	0(a5,d2.w),d2
	move.w	Minimap_width,d6		; Calculate size of one line
	addq.w	#7,d6
	andi.w	#$fff8,d6
	lsr.w	#2,d6
	move.w	d6,d5
	mulu.w	#Screen_depth,d6
	Get	Minimap_handle,a0		; Get minimap address
	mulu.w	d6,d1
	add.w	d1,d1
	adda.w	d1,a0
	move.w	d0,d1
	andi.w	#$fff8,d1
	lsr.w	#2,d1
	add.w	d1,a0
	andi.w	#$0007,d0			; Calculate shift value
	add.w	d0,d0
	move.w	#$8000,d1			; Calculate graphic masks
	lsr.w	d0,d1
	move.w	d1,d0
	not.w	d1
	moveq.l	#Screen_depth-1,d7		; Do
.Loop:	ror.b	#1,d2			; Shift colour
	bcc.s	.Clear
	or.w	d0,0(a0,d6.w)		; Set plane
	ror.w	#1,d0
	or.w	d0,(a0)
	rol.w	#1,d0
	bra.s	.Next
.Clear:	and.w	d1,0(a0,d6.w)		; Clear plane
	ror.w	#1,d1
	and.w	d1,(a0)
	rol.w	#1,d1
.Next:	add.w	d5,a0			; Next plane
	dbra	d7,.Loop
	Free	Minimap_handle
	movem.l	(sp)+,d0-d2/d5-d7/a0
	rts

;*****************************************************************************
; [ Create minimap ]
; All registers are restored
;*****************************************************************************
Create_minimap:
	move.l	d0,-(sp)
	move.w	Minimap_width,d0		; Calculate size
	addq.w	#7,d0
	lsr.w	#3,d0
	mulu.w	#Screen_depth*2,d0
	mulu.w	Minimap_height,d0
	add.l	d0,d0
	jsr	Allocate_CHIP
	jsr	Clear_memory		; !!!
	move.b	d0,Minimap_handle
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Minimap_CA:
	dc.w Minimap_window_X
	dc.w Minimap_window_X+Minimap_window_width-1
	dc.w Minimap_window_Y
	dc.w Minimap_window_Y+Minimap_window_height-1

; *** MINIMAP : 1st layer ***
Minimap_L1:
	dc.w Minimap_window_X,Minimap_window_Y
	dc.w 0,Minimap_window_width-1,0,Minimap_window_height-1	; Minimap area
	dc.b 1
	even
	dc.l 0,Minimap_L2

; *** MINIMAP : 2nd layer ***
Minimap_L2:
	dc.w 0,15,0,15			; Top-left
	dc.b 8
	even
	dc.l .C2,0
.C2:	dc.w 16,Minimap_window_width-17,0,15	; Top
	dc.b 1
	even
	dc.l .C3,0
.C3:	dc.w Minimap_window_width-16,Minimap_window_width-1,0,15	; Top-right
	dc.b 2
	even
	dc.l .C4,0
.C4:	dc.w 0,15,16,Minimap_window_height-17	; Left
	dc.b 7
	even
	dc.l .C6,0

;.C5:	dc.w 16,Minimap_window_width-17,16,Minimap_window_height-17	; MIDDLE
;	dc.b 9
;	even
;	dc.l .C6,0

.C6:	dc.w Minimap_window_width-16,Minimap_window_width-1,16,Minimap_window_height-17		; Right
	dc.b 3
	even
	dc.l .C7,0
.C7:	dc.w 0,15,Minimap_window_height-16,Minimap_window_height-1	; Bottom-left
	dc.b 6
	even
	dc.l .C8,0
.C8:	dc.w 16,Minimap_window_width-17,Minimap_window_height-16,Minimap_window_height-1		; Bottom
	dc.b 5
	even
	dc.l .C9,0
.C9:	dc.w Minimap_window_width-16,Minimap_window_width-1,Minimap_window_height-16,Minimap_window_height-1		; Bottom-right
	dc.b 4
	even
	dc.l 0,0

C2_colour_converter:
	dc.b 0,31,30,29,28,27,26,18,19,20,17,16,9,10,24,23
W2_colour_converter:
	dc.b 0,1,31,18,28,20,21,6,8,10,4,2,14,12,19,16
M3_colour_converter:
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	even
