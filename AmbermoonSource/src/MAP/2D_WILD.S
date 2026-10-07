; 2D Wilderness map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 25-6-1992

	SECTION	Program,code
;*****************************************************************************
; [ Initialize 2D wilderness map ] MAP TYPE 1
; No registers are restored
;*****************************************************************************
W2_ModInit:   
; ---------- Wilderness initialization ------------
	jsr	Clear_persons_buffer	; No persons
	sf	Big_brother_flag
	moveq.l	#0,d2			; Get current map number
	move.w	Map_nr,d2
	sub.w	First_world_map_nr,d2	; Subtract number of first map
	divu.w	World_width,d2		; Calculate world coordinates
	move.w	d2,World_Y
	swap.w	d2
	move.w	d2,World_X
	move.w	Map_Xcoord,d0		; Load party coordinates
	move.w	Map_Ycoord,d1
	moveq.l	#0,d2			; Calculate quad-index
	move.w	Submap_width,d3		;  & quad-coordinates
	lsr.w	#1,d3
	addq.w	#1,d3
	cmp.w	d3,d0
	bpl.s	.Skip_X
	add.w	Submap_width,d0
	bset	#0,d2
.Skip_X:	move.w	Submap_height,d3
	lsr.w	#1,d3
	addq.w	#1,d3
	cmp.w	d3,d1
	bpl.s	.Skip_Y
	add.w	Submap_height,d1
	bset	#1,d2
.Skip_Y:	move.w	d0,Quad_X			; Store
	move.w	d1,Quad_Y
	move.w	d2,Quad_index
	move.w	World_X,d0		; Initialize registers
	move.w	World_Y,d1
	lea.l	Quadmap_0,a2
	lea.l	Quadmap_1,a3
	lea.l	Quadmap_2,a4
	lea.l	Quadmap_3,a5
	lea.l	Load_table,a0		; Get routine address
	lsl.w	#2,d2	
	move.l	0(a0,d2.w),a0
	jsr	(a0)			; Execute load routine
	LOCAL
; ---------- Rest of initialization ---------------
	jsr	Load_2D_map_data		; Load
	jsr	Load_map_palette
	move.w	Travel_mode,d0		; Set initial travelmode
	jsr	Set_new_travel_mode
	sf	Float_up			; Not in 2D
	sf	Float_down
	move.w	Map_Xcoord,d0		; Get first status
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	move.l	d0,Current_location_status
	move.b	#W2_animspeed,Anim_speed	; Set animation parameters
	move.b	#W2_animspeed,Anim_count
	move.w	#W2_animbias,Anim_bias
	move.w	#Mapbuf_centreX,Mapbuf_X	; Set map buffer coordinates
	move.w	#Mapbuf_centreY,Mapbuf_Y
	lea.l	Quad_map,a0		; Modify all maps
	moveq.l	#4-1,d0
.Loop:	move.w	Quad_mapnr(a0),d7
	jsr	Make_modifications
	addq.w	#Quad_mapsize,a0
	dbra	d0,.Loop
	jsr	Init_display		; Initialize display
	jsr	Save_coordinates		; First time
	jmp	After_move		; Handle first step

Load_table:
	dc.l Load_0,Load_1,Load_2,Load_3

; [ Map load routines ]
;   IN : d0 - World X (.w)
;        d1 - World Y (.w)
;        a2 - Pointer to quad-map 0 (.l)
;        a3 - Pointer to quad-map 1 (.l)
;        a4 - Pointer to quad-map 2 (.l)
;        a5 - Pointer to quad-map 3 (.l)
; Changed registers : d0,d1,d2,a0,a1

Load_0:	lea.l	Batch,a0			; Make batches
	jsr	Get_world_map_number	; Map 0 (just map texts)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a2)
	move.b	Mapdata_handle,Quad_map_handle(a2)
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a3)
	addq.w	#1,d1			; Map 3
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a5)
	subq.w	#1,d0			; Map 2
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+6(a0)
	move.w	d2,Quad_mapnr(a4)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0			; Load maps
	moveq.l	#Map_data_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a3)
	move.b	1(a1),Quad_map_handle(a5)
	move.b	2(a1),Quad_map_handle(a4)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#4,d0
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a2)
	move.b	1(a1),Quad_maptext_handle(a3)
	move.b	2(a1),Quad_maptext_handle(a5)
	move.b	3(a1),Quad_maptext_handle(a4)
	rts

Load_1:	lea.l	Batch,a0			; Make batches
	jsr	Get_world_map_number	; Map 1 (just map texts)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a3)
	move.b	Mapdata_handle,Quad_map_handle(a3)
	addq.w	#1,d1			; Map 3
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a5)
	subq.w	#1,d0			; Map 2
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a4)
	subq.w	#1,d1			; Map 0
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+6(a0)
	move.w	d2,Quad_mapnr(a2)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0			; Load maps
	moveq.l	#Map_data_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a5)
	move.b	1(a1),Quad_map_handle(a4)
	move.b	2(a1),Quad_map_handle(a2)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#4,d0
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a3)
	move.b	1(a1),Quad_maptext_handle(a5)
	move.b	2(a1),Quad_maptext_handle(a4)
	move.b	3(a1),Quad_maptext_handle(a2)
	rts

Load_2:	lea.l	Batch,a0			; Make batches
	jsr	Get_world_map_number	; Map 2 (just map texts)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a4)
	move.b	Mapdata_handle,Quad_map_handle(a4)
	subq.w	#1,d1			; Map 0
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a2)
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a3)
	addq.w	#1,d1			; Map 3
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+6(a0)
	move.w	d2,Quad_mapnr(a5)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0			; Load maps
	moveq.l	#Map_data_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a2)
	move.b	1(a1),Quad_map_handle(a3)
	move.b	2(a1),Quad_map_handle(a5)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#4,d0
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a4)
	move.b	1(a1),Quad_maptext_handle(a2)
	move.b	2(a1),Quad_maptext_handle(a3)
	move.b	3(a1),Quad_maptext_handle(a5)
	rts

Load_3:	lea.l	Batch,a0			; Make batches
	jsr	Get_world_map_number	; Map 3 (just map texts)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a5)
	move.b	Mapdata_handle,Quad_map_handle(a5)
	subq.w	#1,d0			; Map 2
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a4)
	subq.w	#1,d1			; Map 0
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a2)
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+6(a0)
	move.w	d2,Quad_mapnr(a3)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0			; Load maps
	moveq.l	#Map_data_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a4)
	move.b	1(a1),Quad_map_handle(a2)
	move.b	2(a1),Quad_map_handle(a3)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#4,d0
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a5)
	move.b	1(a1),Quad_maptext_handle(a4)
	move.b	2(a1),Quad_maptext_handle(a2)
	move.b	3(a1),Quad_maptext_handle(a3)
	rts

;*****************************************************************************
; [ Get world map number ]
;   IN : d0 - World X (.w)
;        d1 - World Y (.w)
;  OUT : d2 - World map number (.w)
; Changed registers : d2
;*****************************************************************************
Get_world_map_number:
	movem.l	d0/d1,-(sp)
	tst.w	d0			; Wrap X
	bpl.s	.Skip_X
	add.w	World_width,d0
	bra.s	.Check_Y
.Skip_X:	cmp.w	World_width,d0
	bmi.s	.Check_Y
	sub.w	World_width,d0
.Check_Y:	tst.w	d1			; Wrap Y
	bpl.s	.Skip_Y
	add.w	World_height,d1
	bra.s	.Cont
.Skip_Y:	cmp.w	World_height,d1
	bmi.s	.Cont
	sub.w	World_height,d1
.Cont:	mulu.w	World_width,d1
	move.w	d1,d2
	add.w	d0,d2
	add.w	First_world_map_nr,d2	; Add number of first map
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Re-evaluate quad-map ]
; All registers are restored
;*****************************************************************************
Quad_evaluate:           
	movem.l	d0-d4/d7/a0-a5,-(sp)
	move.w	Map_Xcoord,d0		; Get party coordinates
	move.w	Map_Ycoord,d1
	move.w	World_X,d2		; Get world coordinates
	move.w	World_Y,d3
	move.w	Quad_index,d4		; Get quad index
	cmpi.w	#1,d0			; X < 1 ?
	bpl.s	.Skip_X
	add.w	Submap_width,d0		; X = X + {width}
	bclr	#0,d4			; Clear bit 0 of quad index
	subq.w	#1,d2			; Decrease & wrap world X
	bpl.s	.Check_Y
	move.w	World_width,d2
	subq.w	#1,d2
	bra.s	.Check_Y
.Skip_X:	cmp.w	Submap_width,d0		; X > {width} ?
	bls.s	.Check_Y
	sub.w	Submap_width,d0		; X = X - {width}
	bset	#0,d4			; Set bit 0 of quad index
	addq.w	#1,d2			; Increase & wrap world X
	cmp.w	World_width,d2
	bmi.s	.Check_Y
	moveq.l	#0,d2
.Check_Y:	cmpi.w	#1,d1			; Y < 1 ?
	bpl.s	.Skip_Y
	add.w	Submap_height,d1		; Y = Y + {height}
	bclr	#1,d4			; Clear bit 1 of quad index
	subq.w	#1,d3			; Decrease & wrap world Y
	bpl.s	.Continue
	move.w	World_height,d3
	subq.w	#1,d3
	bra.s	.Continue
.Skip_Y:	cmp.w	Submap_height,d1		; Y >= {height} ?
	bls.s	.Continue
	sub.w	Submap_height,d1		; Y = Y - {height}
	bset	#1,d4			; Set bit 1 of quad index
	addq.w	#1,d3			; Increase & wrap world Y
	cmp.w	World_height,d3
	bmi.s	.Continue
	moveq.l	#0,d3
.Continue:	move.w	d0,Map_Xcoord		; Store new values
	move.w	d1,Map_Ycoord
	move.w	d2,World_X
	move.w	d3,World_Y
	move.w	d4,Quad_index
	mulu.w	World_width,d3		; Calculate new map number
	add.w	d2,d3
	add.w	First_world_map_nr,d3
	move.w	d3,Map_nr			; Store
	LOCAL
	moveq.l	#0,d2			; Get 1/10ths of dimensions
	move.w	Submap_width,d2
	divu.w	#10/2,d2
	moveq.l	#0,d3
	move.w	Submap_height,d3
	divu.w	#10/2,d3
	moveq.l	#0,d0			; Get quad coordinates
	move.w	Quad_X,d0
	moveq.l	#0,d1
	move.w	Quad_Y,d1
	lea.l	.Area_table,a0		; Get shift area number
	divu.w	d2,d0
	divu.w	d3,d1
	mulu.w	#10,d1
	add.w	d1,d0
	moveq.l	#0,d3
	move.b	0(a0,d0.w),d3
	move.w	World_X,d0		; Initialize registers
	move.w	World_Y,d1
	move.w	Quad_index,d2
	lea.l	Quadmap_0,a2
	lea.l	Quadmap_1,a3
	lea.l	Quadmap_2,a4
	lea.l	Quadmap_3,a5
	lsl.w	#2,d3			; Get routine address
	move.l	.Shift_table(pc,d3.w),d3
	beq.s	.Skip
	movea.l	d3,a0			; Execute shift routine
	jsr	(a0)
	move.w	d2,Quad_index		; Store new quad-index
.Skip:	lea.l	Quad_map,a0		; Set new map pointer
	mulu.w	#Quad_mapsize,d2		;  & text pointer
	adda.w	d2,a0
	move.b	(a0),Mapdata_handle
	move.b	Quad_maptext_handle(a0),Maptext_handle
	movem.l	(sp)+,d0-d4/d7/a0-a5
	rts

.Shift_table:	
	dc.l Shift_UL,Shift_U,Shift_UR
	dc.l Shift_L,0,Shift_R
	dc.l Shift_DL,Shift_D,Shift_DR

.Area_table:
	dc.b 0,0,1,1,1,1,1,1,2,2
	dc.b 0,0,4,4,4,4,4,4,2,2
	dc.b 3,4,4,4,4,4,4,4,4,5
	dc.b 3,4,4,4,4,4,4,4,4,5
	dc.b 3,4,4,4,4,4,4,4,4,5
	dc.b 3,4,4,4,4,4,4,4,4,5
	dc.b 3,4,4,4,4,4,4,4,4,5
	dc.b 3,4,4,4,4,4,4,4,4,5
	dc.b 6,6,4,4,4,4,4,4,8,8
	dc.b 6,6,7,7,7,7,7,7,8,8
	even

; [ Free quad-map ]
;   IN : a0 - Pointer to quad-map (.l)
; All registers are restored
Free_quadmap: 
	move.l	d0,-(sp)
	move.b	Quad_map_handle(a0),d0	; Free map memory
	jsr	Free_memory
	move.b	Quad_maptext_handle(a0),d0	; Free map text memory
	jsr	Free_memory
	move.l	(sp)+,d0
	rts

; [ Move quad-map ]
;   IN : a0 - Pointer to source quad-map (.l)
;        a1 - Pointer to destination quad-map (.l)
; Changed registers : d7,a0,a1
Move_quadmap: 
	moveq.l	#Quad_mapsize/2-1,d7
.Loop:	move.w	(a0)+,(a1)+
	dbra	d7,.Loop
	rts

Free_quad	macro
	lea.l	Quadmap_\1,a0
	jsr	Free_quadmap
	endm

Move_quad	macro
	lea.l	Quadmap_\1,a0
	lea.l	Quadmap_\2,a1
	jsr	Move_quadmap
	endm

; [ Quad-map shift routines ]
;   IN : d0 - World X (.w)
;        d1 - World Y (.w)
;        d2 - Quad index (.w)
;        a2 - Pointer to 1st quad-map (.l)
;        a3 - Pointer to 2nd quad-map (.l)
;        a4 - Pointer to 3rd quad-map (.l)
;        a5 - Pointer to 4th quad-map (.l)
;  OUT : d2 - Quad index (.w)
; Changed registers : d0,d1,d2,d7,a0,a1

; Up-left - Load maps 2,0 & 1
Shift_UL:	Free_quad 1
	Free_quad 2
	Free_quad 3
	Move_quad 0,3
	lea.l	Batch,a0			; Make batches
	subq.w	#1,d0			; Map 2
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a4)
	subq.w	#1,d1			; Map 0
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a2)
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a3)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a4)
	move.b	1(a1),Quad_map_handle(a2)
	move.b	2(a1),Quad_map_handle(a3)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a4)
	move.b	1(a1),Quad_maptext_handle(a2)
	move.b	2(a1),Quad_maptext_handle(a3)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	4(a0),d7
	jsr	Make_modifications
	move.w	Submap_width,d0		; Update quad coordinates
	add.w	d0,Quad_X
	move.w	Submap_height,d0
	add.w	d0,Quad_Y
	moveq.l	#3,d2			; Adjust quad-index
	rts

; Up - Load maps 0 & 1
Shift_U:	Free_quad 2
	Free_quad 3
	Move_quad 0,2
	Move_quad 1,3
	btst	#0,d2			; Adapt X
	beq.s	.Skip
	subq.w	#1,d0
.Skip:	lea.l	Batch,a0			; Make batches
	subq.w	#1,d1			; Map 0
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a2)
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a3)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#2,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a2)
	move.b	1(a1),Quad_map_handle(a3)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a2)
	move.b	1(a1),Quad_maptext_handle(a3)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	Submap_height,d0		; Update quad coordinate
	add.w	d0,Quad_Y
	move.w	Quad_index,d2		; Adjust quad-index
	bset	#1,d2
	rts

; Up-right - Load maps 0,1 & 3
Shift_UR:	Free_quad 0
	Free_quad 2
	Free_quad 3
	Move_quad 1,2
	lea.l	Batch,a0			; Make batches
	subq.w	#1,d1			; Map 0
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a2)
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a3)
	addq.w	#1,d1			; Map 3
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a5)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a2)
	move.b	1(a1),Quad_map_handle(a3)
	move.b	2(a1),Quad_map_handle(a5)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a2)
	move.b	1(a1),Quad_maptext_handle(a3)
	move.b	2(a1),Quad_maptext_handle(a5)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	4(a0),d7
	jsr	Make_modifications
	move.w	Submap_width,d0		; Update quad coordinates
	sub.w	d0,Quad_X
	move.w	Submap_height,d0
	add.w	d0,Quad_Y
	moveq.l	#2,d2			; Adjust quad-index
	rts

; Left - Load maps 0 & 2
Shift_L:	Free_quad 1
	Free_quad 3
	Move_quad 0,1
	Move_quad 2,3
	btst	#1,d2			; Adapt Y
	beq.s	.Skip
	subq.w	#1,d1
.Skip:	lea.l	Batch,a0			; Make batches
	subq.w	#1,d0			; Map 0
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a2)
	addq.w	#1,d1			; Map 2
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a4)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#2,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a2)
	move.b	1(a1),Quad_map_handle(a4)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a2)
	move.b	1(a1),Quad_maptext_handle(a4)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	Submap_width,d0		; Update quad coordinate
	add.w	d0,Quad_X
	move.w	Quad_index,d2		; Adjust quad-index
	bset	#0,d2
	rts

; Right - Load maps 1 & 3
Shift_R:	Free_quad 0
	Free_quad 2
	Move_quad 1,0
	Move_quad 3,2
	btst	#1,d2			; Adapt Y
	beq.s	.Skip
	subq.w	#1,d1
.Skip:	lea.l	Batch,a0			; Make batches
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a3)
	addq.w	#1,d1			; Map 3
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a5)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#2,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a3)
	move.b	1(a1),Quad_map_handle(a5)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a3)
	move.b	1(a1),Quad_maptext_handle(a5)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	Submap_width,d0		; Update quad coordinate
	sub.w	d0,Quad_X
	move.w	Quad_index,d2		; Adjust quad-index
	bclr	#0,d2
	rts

; Down-left - Load maps 3,2 & 0
Shift_DL:	Free_quad 0
	Free_quad 1
	Free_quad 3
	Move_quad 2,1
	lea.l	Batch,a0			; Make batches
	addq.w	#1,d1			; Map 3
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a5)
	subq.w	#1,d0			; Map 2
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a4)
	subq.w	#1,d1			; Map 0
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a2)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a5)
	move.b	1(a1),Quad_map_handle(a4)
	move.b	2(a1),Quad_map_handle(a2)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a5)
	move.b	1(a1),Quad_maptext_handle(a4)
	move.b	2(a1),Quad_maptext_handle(a2)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	4(a0),d7
	jsr	Make_modifications
	move.w	Submap_width,d0		; Update quad coordinates
	add.w	d0,Quad_X
	move.w	Submap_height,d0
	sub.w	d0,Quad_Y
	moveq.l	#1,d2			; Adjust quad-index
	rts

; Down - Load maps 2 & 3
Shift_D:	Free_quad 0
	Free_quad 1
	Move_quad 2,0
	Move_quad 3,1
	btst	#0,d2			; Adapt X
	beq.s	.Skip
	subq.w	#1,d0
.Skip:	lea.l	Batch,a0			; Make batches
	addq.w	#1,d1			; Map 2
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a4)
	addq.w	#1,d0			; Map 3
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a5)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#2,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a4)
	move.b	1(a1),Quad_map_handle(a5)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a4)
	move.b	1(a1),Quad_maptext_handle(a5)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	Submap_height,d0		; Update quad coordinate
	sub.w	d0,Quad_Y
	move.w	Quad_index,d2		; Adjust quad-index
	bclr	#1,d2
	rts

; Down-right - Load maps 1,2 & 3
Shift_DR:	Free_quad 0			; Move quad-maps
	Free_quad 1
	Free_quad 2
	Move_quad 3,0
	lea.l	Batch,a0			; Make batches
	addq.w	#1,d0			; Map 1
	jsr	Get_world_map_number
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,Quad_mapnr(a3)
	addq.w	#1,d1			; Map 3
	jsr	Get_world_map_number
	move.w	d2,2(a0)
	move.w	d2,8+2(a0)
	move.w	d2,Quad_mapnr(a5)
	subq.w	#1,d0			; Map 2
	jsr	Get_world_map_number
	move.w	d2,4(a0)
	move.w	d2,8+4(a0)
	move.w	d2,Quad_mapnr(a4)
	lea.l	Submap_handles,a1		; Load files
	moveq.l	#3,d0
	moveq.l	#Map_data_file,d1		; Load maps
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_map_handle(a3)
	move.b	1(a1),Quad_map_handle(a5)
	move.b	2(a1),Quad_map_handle(a4)
	lea.l	Batch+8,a0		; Load map texts
	moveq.l	#Map_text_file,d1
	jsr	Load_batch_of_subfiles
	move.b	(a1),Quad_maptext_handle(a3)
	move.b	1(a1),Quad_maptext_handle(a5)
	move.b	2(a1),Quad_maptext_handle(a4)
	move.w	(a0),d7			; Modify maps
	jsr	Make_modifications
	move.w	2(a0),d7
	jsr	Make_modifications
	move.w	4(a0),d7
	jsr	Make_modifications
	move.w	Submap_width,d0		; Update quad coordinates
	sub.w	d0,Quad_X
	move.w	Submap_height,d0
	sub.w	d0,Quad_Y
	moveq.l	#0,d2			; Adjust quad-index
	rts

;*****************************************************************************
; [ 2D wilderness map ModExit ] MAP TYPE 1
; No registers are restored
;*****************************************************************************
W2_ModExit:
	lea.l	Quad_map,a0		; Free memory
	moveq.l	#4-1,d7
.Loop:	move.b	Quad_map_handle(a0),d0
	jsr	Free_memory
	move.b	Quad_maptext_handle(a0),d0
	jsr	Free_memory
	addq.w	#Quad_mapsize,a0
	dbra	d7,.Loop
	moveq.l	#0,d0			; Stop music
	jsr	Set_music
	jsr	Exit_travelmode		; Free memory
	jmp	Remove_2D_map_data

;*****************************************************************************
; [ 2D wilderness - DisUpd ] MAP TYPE 1
; No registers are restored
;*****************************************************************************
W2_DisUpd:    
	tst.b	Show_trans		; Show transports ?
	beq.s	.No_trans
	jsr	Clear_trans_buffer
; ---------- Copy map part to buffers -------------
.No_trans:	move.w	Quad_X,d0			; Get quad-map coordinates
	move.w	Quad_Y,d1
	opt	o5-				; (not optimized by the original assembler)
	subi.w	#Mapbuf_centreX+1,d0	; Adjust
	opt	o5+
	opt	o5-				; (not optimized by the original assembler)
	subi.w	#Mapbuf_centreY+1,d1
	opt	o5+
	move.w	Quad_index,d2		; Calculate cut index
	add.w	d2,d2
	add.w	d2,d2
	move.w	Submap_width,d3
	subi.w	#Mapbuf_width-1,d3
	cmp.w	d3,d0
	bmi.s	.Check_Y
	cmp.w	Submap_width,d0
	bpl.s	.Check_Y
	bset	#4,d2
.Check_Y:	move.w	Submap_height,d3
	opt	o5-				; (not optimized by the original assembler)
	subi.w	#Mapbuf_height-1,d3
	opt	o5+
	cmp.w	d3,d1
	bmi.s	.Go_on
	cmp.w	Submap_height,d1
	bpl.s	.Go_on
	bset	#5,d2
.Go_on:	lea.l	Multimap_table,a0		; Execute cut routine
	movea.l	0(a0,d2.w),a0
	jsr	(a0)
; --------- Get current location status -----------
.Continue:	move.w	Map_Xcoord,d0
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	move.l	d0,Current_location_status
; ---------- Update display -----------------------
	jsr	Display_2D_map
	jsr	Map_DisUpd
	rts

Multimap_table:          
	dc.l Cut_A,Cut_A,Cut_A,Cut_A
	dc.l Cut_B,Cut_B,Cut_E,Cut_E
	dc.l Cut_C,Cut_D,Cut_C,Cut_D
	dc.l Cut_F,Cut_F,Cut_F,Cut_F

; [ Multi-map cut routines ]
;   IN : d0 - Quad X (.w)
;        d1 - Quad Y (.w)
; Changed registers : d0,d1,a0

Cut_A:	move.w	Map_Xcoord,d0		; Get party coordinates
	move.w	Map_Ycoord,d1
	opt	o5-				; (not optimized by the original assembler)
	subi.w	#Mapbuf_centreX+1,d0	; Adjust coordinates
	opt	o5+
	opt	o5-				; (not optimized by the original assembler)
	subi.w	#Mapbuf_centreY+1,d1
	opt	o5+
	lea.l	Quadmap_0,a0		; Cut from current map
	move.w	Quad_index,d2
	mulu.w	#Quad_mapsize,d2
	adda.w	d2,a0
	jmp	Copy_map_part

Cut_B:	lea.l	Quadmap_0,a0		; Cut from map 0
	jsr	Copy_map_part
	sub.w	Submap_width,d0		; Cut from map 1
	lea.l	Quadmap_1,a0
	jmp	Copy_map_part

Cut_C:	lea.l	Quadmap_0,a0		; Cut from map 0
	jsr	Copy_map_part
	sub.w	Submap_height,d1		; Cut from map 2
	lea.l	Quadmap_2,a0
	jmp	Copy_map_part

Cut_D:	sub.w	Submap_width,d0		; Cut from map 1
	lea.l	Quadmap_1,a0
	jsr	Copy_map_part
	sub.w	Submap_height,d1		; Cut from map 3
	lea.l	Quadmap_3,a0
	jmp	Copy_map_part

Cut_E:	sub.w	Submap_height,d1		; Cut from map 2
	lea.l	Quadmap_2,a0
	jsr	Copy_map_part
	sub.w	Submap_width,d0		; Cut from map 3
	lea.l	Quadmap_3,a0
	jmp	Copy_map_part

Cut_F:	lea.l	Quadmap_0,a0		; Cut from map 0
	jsr	Copy_map_part
	sub.w	Submap_width,d0		; Cut from map 1
	lea.l	Quadmap_1,a0
	jsr	Copy_map_part
	sub.w	Submap_height,d1		; Cut from map 3
	lea.l	Quadmap_3,a0
	jsr	Copy_map_part
	add.w	Submap_width,d0		; Cut from map 2
	lea.l	Quadmap_2,a0
	jmp	Copy_map_part

; [ Copy part of map ]
;   IN : d0 - X-coordinate {0...submap_width-1} (.w)
;        d1 - Y-coordinate {0...submap_height-1} (.w)
;        a0 - Pointer to quad-map (.l)
; All registers are restored
Copy_map_part:           
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	a0,a6			; Save pointer to quad-map
	Get	(a6),a0			; Get pointer to map data
	lea.l	Map_data(a0),a0
; ---------- Clip cut size ------------------------
	moveq.l	#0,d4			; Clear offset coordinates
	moveq.l	#0,d5
	moveq.l	#Mapbuf_width-1,d6		; Load counters
	moveq.l	#Mapbuf_height-1,d7
	tst.w	d0			; X < 0 ?
	bpl.s	.X_pos
	add.w	d0,d6			; Adjust width
	neg.w	d0			; Set offset X
	move.w	d0,d4
	moveq.l	#0,d0			; X = 0
	bra.s	.Y_check
.X_pos:	move.w	Submap_width,d3		; X > submap width
	subi.w	#Mapbuf_width,d3		;  - (buffer width - 1) ?
	cmp.w	d3,d0
	bmi.s	.Y_check
	move.w	Submap_width,d3		; Adjust width
	sub.w	d0,d3
	move.w	d3,d6
	subq.w	#1,d6
.Y_check:	tst.w	d1			; Y < 0 ?
	bpl.s	.Y_pos
	add.w	d1,d7			; Adjust height
	neg.w	d1			; Set offset Y
	move.w	d1,d5
	moveq.l	#0,d1			; Y = 0
	bra.s	.Cont
.Y_pos:	move.w	Submap_height,d3		; Y > submap height
	subi.w	#Mapbuf_height,d3		;  - (buffer height - 1) ?
	cmp.w	d3,d1
	bmi.s	.Cont
	move.w	Submap_height,d3		; Adjust height
	sub.w	d1,d3
	move.w	d3,d7
	subq.w	#1,d7
.Cont:	tst.w	d6			; Width or height = 0 ?
	bmi.s	.Exit			; Yes -> exit
	tst.w	d7
	bmi.s	.Exit
; ---------- Insert transports --------------------
	move.w	Quad_mapnr(a6),d2
	jsr	Insert_transports
; ---------- Cut underlays & overlays -------------
	move.w	Width_of_map,d2		; Get width of map
	lsl.w	#2,d2
	mulu.w	d2,d1			; Calculate map offset
	lsl.w	#2,d0
	ext.l	d0
	add.l	d0,d1
	lea.l	Underlay_buffer,a1		; Calculate pointers
	lea.l	Overlay_buffer,a2
	adda.l	d1,a0
	mulu.w	#Mapbuf_width,d5
	add.w	d5,d4
	add.w	d4,a1
	add.w	d4,d4
	add.w	d4,a2
.Loop1:	movea.l	a0,a3			; Duplicate variables
	movea.l	a1,a4
	movea.l	a2,a5
	move.w	d6,d5
.Loop2:	move.b	(a3),(a4)+		; Copy
	addq.l	#2,a3
	move.w	(a3)+,(a5)+
	dbra	d5,.Loop2			; Next column
	adda.w	d2,a0			; Next line
	lea.l	Mapbuf_width(a1),a1
	lea.l	Mapbuf_width*2(a2),a2
	dbra	d7,.Loop1
.Exit:	Free	(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
