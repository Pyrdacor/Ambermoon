; 2D City map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 25-6-1992

	SECTION	Program,code
;*****************************************************************************
; [ 2D city map ModInit ] MAP TYPE 0
; No registers are restored
;*****************************************************************************
C2_ModInit:
	jsr	Load_2D_map_data		; Load
	jsr	Load_map_palette
	move.w	Map_nr,d7			; Make map modifications
	jsr	Make_modifications
	move.w	Travel_mode,d0		; Set initial travelmode
	jsr	Set_new_travel_mode
	sf	Float_up			; Not in 2D
	sf	Float_down
	move.w	Map_Xcoord,d0		; Get first status
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	move.l	d0,Current_location_status
	move.b	#C2_animspeed,Anim_speed	; Set animation parameters
	move.b	#C2_animspeed,Anim_count
	move.w	#C2_animbias,Anim_bias
	jsr	Recalc_mapbuf_coords	; Set map	buffer coordinates
	jsr	Init_persons_2D		; Initialize persons
	jsr	Init_display		; Initialize display
	jsr	Save_coordinates		; First time
	jmp	After_move		; Handle first step

;*****************************************************************************
; [ 2D city map ModExit ] MAP TYPE 0
; No registers are restored
;*****************************************************************************
C2_ModExit:
	move.b	Mapdata_handle,d0		; Free memory
	jsr	Free_memory
	moveq.l	#0,d0			; Stop music
	jsr	Set_music
	jsr	Exit_travelmode		; Free memory
	jmp	Remove_2D_map_data

;*****************************************************************************
; [ Recalculate map buffer coordinates ]
; All registers are restored
;*****************************************************************************
Recalc_mapbuf_coords:    
	movem.l	d0/d1,-(sp)
	move.w	#Mapbuf_centreX,Mapbuf_X	; Reset map buffer coordinates
	move.w	#Mapbuf_centreY,Mapbuf_Y
	move.w	Map_Xcoord,d0		; Load party coordinates
	move.w	Map_Ycoord,d1
	cmpi.w	#Mapbuf_centreX+1,d0	; Left boundary check
	bpl.s	.Skip1
	opt	o5-				; (not optimized by the original assembler)
	subi.w	#Mapbuf_centreX+1,d0
	opt	o5+
	add.w	d0,Mapbuf_X
	bra.s	.Go_on1
.Skip1:	sub.w	Width_of_map,d0		; Right boundary check
	cmpi.w	#-Mapbuf_centreX+1,d0
	bmi.s	.Go_on1
	opt	o5-				; (not optimized by the original assembler)
	addi.w	#Mapbuf_centreX,d0
	opt	o5+
	add.w	d0,Mapbuf_X
.Go_on1:	cmpi.w	#Mapbuf_centreY+1,d1	; Top boundary check
	bpl.s	.Skip2
	opt	o5-				; (not optimized by the original assembler)
	subi.w	#Mapbuf_centreY+1,d1
	opt	o5+
	add.w	d1,Mapbuf_Y
	bra.s	.Go_on2
.Skip2:	sub.w	Height_of_map,d1		; Bottom boundary check
	cmpi.w	#-Mapbuf_centreY+1,d1
	bmi.s	.Go_on2
	opt	o5-				; (not optimized by the original assembler)
	addi.w	#Mapbuf_centreY,d1
	opt	o5+
	add.w	d1,Mapbuf_Y
.Go_on2:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ 2D city - DisUpd ] MAP TYPE 0
; No registers are restored
;*****************************************************************************
C2_DisUpd:    
	jsr	Clear_persons_buffer
	tst.b	Show_trans		; Show transports ?
	beq.s	.No_trans
	jsr	Clear_trans_buffer
; ---------- Copy map part to buffers -------------
.No_trans:	jsr	Recalc_mapbuf_coords	; Set map	buffer coordinates
	Get	Mapdata_handle,a1		; Calculate map address
	lea.l	Map_data(a1),a1
	move.w	Map_Ycoord,d0
	subq.w	#1,d0
	sub.w	Mapbuf_Y,d0
	move.w	Width_of_map,d1
	mulu.w	d1,d0
	add.w	Map_Xcoord,d0
	subq.w	#1,d0
	sub.w	Mapbuf_X,d0
	lsl.l	#2,d0
	adda.l	d0,a1
	subi.w	#Mapbuf_width,d1		; Calculate offset
	lsl.w	#2,d1
	lea.l	Underlay_buffer,a2		; Copy maps to buffer
	lea.l	Overlay_buffer,a3
	moveq.l	#1,d0
	moveq.l	#Mapbuf_height-1,d7
.Loop1:	moveq.l	#Mapbuf_width-1,d6
.Loop2:	move.b	(a1)+,(a2)+		; Copy underlay
	addq.l	#1,a1			; Skip event
	move.w	(a1)+,(a3)+		; Copy overlay
	dbra	d6,.Loop2
	adda.w	d1,a1
	dbra	d7,.Loop1
	Free	Mapdata_handle
	move.w	Map_Xcoord,d0		; Insert transports
	move.w	Map_Ycoord,d1
	sub.w	Mapbuf_X,d0
	sub.w	Mapbuf_Y,d1
	subq.w	#1,d0
	subq.w	#1,d1
	move.w	Map_nr,d2
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#Mapbuf_width-1,d6
	moveq.l	#Mapbuf_height-1,d7
	jsr	Insert_transports
	jsr	NPC_manager_2D		; Handle persons
; --------- Get current location status -----------
	move.w	Map_Xcoord,d0
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	move.l	d0,Current_location_status
; ---------- Update display -----------------------
	jsr	Display_2D_map
	jmp	Map_DisUpd
