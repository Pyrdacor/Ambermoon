; 2D map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 16-6-1992

	SECTION	Program,code
;*****************************************************************************
; [ Load 2D map data ]
; All registers are restored
;*****************************************************************************
Load_2D_map_data:
	movem.l	d0/d1/d5-d7/a0,-(sp)
	Get	Mapdata_handle,a0
	moveq.l	#0,d5			; Get icon graphics number
	move.b	Icondat_filenr(a0),d5
	moveq.l	#0,d6			; Get NPC graphics number
	move.b	Npcgfx_filenr(a0),d6
	Free	Mapdata_handle
	move.w	d5,d0			; Load icon data
	moveq.l	#Icon_data_file,d1
	jsr	Load_subfile
	move.b	d0,Icondata_handle
	move.w	d5,d0			; Load icon graphics
	moveq.l	#Icon_gfx_file,d1
	jsr	Load_subfile
	move.b	d0,Icongfx_handle
	jsr	Load_map_texts		; Load map texts
	tst.b	Show_trans		; Show travelmodes ?
	bne.s	.Show
	move.w	Current_world_nr,d0		; No
	move.b	.Table(pc,d0.w),d0
	moveq.l	#Party_gfx_file,d1		; Load party graphics
	jsr	Load_subfile
	move.b	d0,Transgfx_handle
	bra.s	.Go_on
.Table:	dc.b 1,2,3
	even
.Show:	moveq.l	#Stationary_file,d0		; Load stationary transports
	jsr	Load_file
	move.b	d0,Stationary_handle
.Go_on:	cmp.b	#World_2D,Current_map_type	; World map ?
	beq.s	.Skip
	move.w	d6,d0			; Load NPC graphics
	moveq.l	#NPC_gfx_file,d1
	jsr	Load_subfile
	move.b	d0,NPCgfx_handle
.Skip:	movem.l	(sp)+,d0/d1/d5-d7/a0
	rts

;*****************************************************************************
; [ Remove 2D map data ]
; All registers are restored
;*****************************************************************************
Remove_2D_map_data:
	move.l	d0,-(sp)
	move.b	Icondata_handle,d0		; Free memory
	jsr	Free_memory
	move.b	Icongfx_handle,d0
	jsr	Free_memory
	tst.b	Show_trans		; Show travelmodes ?
	bne.s	.Show
	move.b	Transgfx_handle,d0		; No -> Free party graphics
	jsr	Free_memory
	bra.s	.Go_on
.Show:	move.b	Stationary_handle,d0	; Yes -> Free stationary graphics
	jsr	Free_memory
.Go_on:	cmp.b	#World_2D,Current_map_type	; World map ?
	beq.s	.Skip
	move.b	NPCgfx_handle,d0		; No -> Free NPC graphics
	jsr	Free_memory
	move.b	Maptext_handle,d0		; Free map texts
	jsr	Free_memory
.Skip:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ 2D map DisInit ]
; No registers are restored
;*****************************************************************************
M2_DisInit:
	jsr	Set_spell_area		; Reset variables
	moveq.l	#Map2D_layout,d0		; Show 2D map layout
	jsr	Show_layout
	jsr	Print_headline
	move.l	#M2_CIL,First_CIL_ptr	; Display control icons
	jsr	Init_map_CIL
	jsr	Update_light_status		; Update light
	move.w	#-1,Previous_SIF_changes	; Update all special items
	st	NPCs_off			; Display 2D map
	jsr	Update_display
	sf	NPCs_off
	jsr	Fade_in_bottom		; Fade in
	jsr	Set_map_music		; Start the music
	sf	Time_lock			; Start the clock
	rts

;*****************************************************************************
; [ Display 2D map ]
; All registers are restored
;*****************************************************************************
Display_2D_map:
	movem.l	d0-d7/a0-a6,-(sp)
	Push	CA,Map2D_L2
; ---------- Test for complete darkness -----------
	jsr	Evaluate_2D_light		; Re-evaluate light
	tst.b	Stygian			; Complete darkness ?
	beq.s	.See
	move.w	#Map2D_X,d0		; Erase map area
	move.w	#Map2D_Y,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#Mapbuf_width*16-1,d2
	addi.w	#Mapbuf_height*16-1,d3
	moveq.l	#0,d4
	jsr	Draw_box
	jsr	Display_2D_party		; Display party
	bra	.Cont
.See:	Get	Icongfx_handle,a0
	Get	Icondata_handle,a5
; ---------- Display under- & overlays ------------
	lea.l	Underlay_buffer,a1
	lea.l	Overlay_buffer,a2
	jsr	Get_hashable_number
	move.w	#Map2D_Y,d1
	moveq.l	#Mapbuf_height-1,d7
.Loop1:	move.w	#Map2D_X,d0
	moveq.l	#Mapbuf_width-1,d6
.Loop2:	moveq.l	#0,d2			; Get underlay icon number
	move.b	(a1)+,d2
	jsr	Display_2D_underlay		; Display underlay
	move.w	(a2),d2			; Get overlay icon number
	beq.s	.Next2
	move.w	d2,d3			; Get icon status bits
	lsl.w	#3,d3
	move.l	-8+2(a5,d3.w),d3
	btst	#Overlay_in_sky_bit,d3	; Ground overlay ?
	bne.s	.Next2
	jsr	Display_2D_overlay		; Yes -> Display overlay
.Next2:	addq.l	#2,a2			; Next X
	addi.w	#16,d0
	addq.w	#1,d5
	dbra	d6,.Loop2
	addi.w	#16,d1			; Next Y
	subi.w	#Mapbuf_width,d5
	add.w	Width_of_map,d5
	dbra	d7,.Loop1
; ---------- Display transports -------------------
	tst.b	Show_trans		; Show travelmodes ?
	beq	.No_trans
	lea.l	Trans_buffer,a1		; Yes
	jsr	Get_hashable_number
	move.w	#Map2D_Y-16,d1
	moveq.l	#Mapbuf_height+2-1,d7
.Loop3:	move.w	#Map2D_X-16,d0
	moveq.l	#Mapbuf_width+2-1,d6
.Loop4:	moveq.l	#0,d2			; Get transport number
	move.b	(a1)+,d2
	beq.s	.Next4
	jsr	Display_2D_transport	; Display transport
.Next4:	addi.w	#16,d0			; Next X
	dbra	d6,.Loop4
	addi.w	#16,d1			; Next Y
	dbra	d7,.Loop3
; ---------- Display persons ----------------------
.No_trans:	lea.l	Persons_buffer,a1		; Prepare
	jsr	Get_hashable_number
	move.w	#Map2D_Y,d1
	moveq.l	#Mapbuf_height,d7		; +1 !
	move.w	Travel_mode,d0		; Above or below ?
	move.w	#Above_mask,d3
	btst	d0,d3
	bne.s	.Loop7
	move.w	Mapbuf_Y,d3		; Get party offset
	mulu.w	#Mapbuf_width,d3
	add.w	Mapbuf_X,d3
.Loop5:	move.w	#Map2D_X,d0		; Do one row
	moveq.l	#Mapbuf_width-1,d6
.Loop6:	move.b	(a1)+,d2			; Get person number
	beq.s	.No_NPC
	jsr	Display_2D_person		; Display person
.No_NPC:	tst.w	d3			; Party time ?
	bne.s	.Next6
	move.l	Current_location_status,d3	; Party invisible ?
	btst	#Party_invisible_bit,d3
	bne.s	.Next8
	jsr	Display_2D_party		; Yeah!
	bra.s	.Next8			; Other loop !
.Next6:	addi.w	#16,d0			; Next X
	subq.w	#1,d3
	addq.w	#1,d5
	dbra	d6,.Loop6
	addi.w	#16,d1			; Next Y
	subi.w	#Mapbuf_width,d5
	add.w	Width_of_map,d5
	dbra	d7,.Loop5
	bra.s	.Skip1			; (should never happen)
.Loop7:	move.w	#Map2D_X,d0		; Do one row
	moveq.l	#Mapbuf_width-1,d6
.Loop8:	move.b	(a1)+,d2			; Get person number
	beq.s	.Next8
	jsr	Display_2D_person		; Display person
.Next8:	addi.w	#16,d0			; Next X
	addq.w	#1,d5
	dbra	d6,.Loop8
	addi.w	#16,d1			; Next Y
	subi.w	#Mapbuf_width,d5
	add.w	Width_of_map,d5
	dbra	d7,.Loop7
; ---------- Display party & sky overlays ---------
.Skip1:	jsr	Display_2D_sky		; Display in-sky icons
	move.w	Travel_mode,d0		; Above or below ?
	move.w	#Above_mask,d1
	btst	d0,d1
	beq.s	.Skip2
	jsr	Display_2D_party		; Display party in sky
.Skip2:	jsr	Display_2D_night		; Display night circle
	Free	Icondata_handle
	Free	Icongfx_handle
.Cont:	subq.b	#1,Anim_count		; Time for an update ?
	bne.s	.No
	jsr	Update_animation		; Update animation
	move.b	Anim_speed,Anim_count	; Reset counter
; ---------- Display "OUCH!" when necessary -------
.No:	tst.b	Bumped			; Ouch ?
	beq.s	.Exit
	move.w	Mapbuf_X,d0		; Calculate screen coordinates
	move.w	Mapbuf_Y,d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	addi.w	#Map2D_X+14,d0
	addi.w	#Map2D_Y-24,d1
	lea.l	Ouch,a0			; Display OUCH!
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#23,d7
	jsr	Put_masked_block
	sf	Bumped			; Clear flag
.Exit:	Pop	CA
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Display 2D sky overlays ]
;   IN : a0 - Pointer to icon graphics (.l)
;        a5 - Pointer to icon info (.l)
; All registers are restored
;*****************************************************************************
Display_2D_sky:
	movem.l	d0-d3/d5-d7/a1,-(sp)
	lea.l	Overlay_buffer,a1
	jsr	Get_hashable_number
	move.w	#Map2D_Y,d1
	moveq.l	#Mapbuf_height-1,d7
.Loop1:	move.w	#Map2D_X,d0
	moveq.l	#Mapbuf_width-1,d6
.Loop2:	move.w	(a1)+,d2			; Get overlay icon number
	beq.s	.Next
	move.w	d2,d3			; Get icon status bits
	lsl.w	#3,d3
	move.l	-8+2(a5,d3.w),d3
	btst	#Overlay_in_sky_bit,d3	; Ground overlay ?
	beq.s	.Next
	jsr	Display_2D_overlay		; Display overlay
.Next:	addi.w	#16,d0			; Next X
	addq.w	#1,d5
	dbra	d6,.Loop2
	addi.w	#16,d1			; Next Y
	subi.w	#Mapbuf_width,d5
	add.w	Width_of_map,d5
	dbra	d7,.Loop1
	movem.l	(sp)+,d0-d3/d5-d7/a1
	rts

;*****************************************************************************
; [ Timer for frame-rate-independent movement ]
; All registers are restored
;*****************************************************************************
Time_2D:
	addq.l	#1,Timer			; Count for movement
	rts

;*****************************************************************************
; [ Get hashable number ]
;  OUT : d5 - Hashable number (.w)
; Changed registers : d5
;*****************************************************************************
Get_hashable_number:
	move.w	Map_Ycoord,d5		; Calculate hashable number
	sub.w	Mapbuf_Y,d5
	subq.w	#1,d5
	mulu.w	Width_of_map,d5
	add.w	Map_Xcoord,d5
	sub.w	Mapbuf_X,d5
	subq.w	#1,d5
	rts

;*****************************************************************************
; [ Display party ]
; All registers are restored
;*****************************************************************************
Display_2D_party:
	movem.l	d0/d1/d5-d7/a0,-(sp)
	tst.b	Show_trans		; Show travel-modes in this
	beq	.No_trans			;  map ?
	Get	Transgfx_handle,a0		; Seek graphics
	move.w	View_direction,d7
	bra.s	.Entry
.Loop:	move.w	(a0)+,d0			; Skip frame
	mulu.w	(a0)+,d0
	mulu.w	#Screen_depth*2,d0
	lea.l	4(a0,d0.l),a0
.Entry:	dbra	d7,.Loop
	move.w	(a0)+,d6			; Get dimensions
	move.w	(a0)+,d7
	move.w	Mapbuf_X,d0		; Get coordinates
	lsl.w	#4,d0
	addi.w	#Map2D_X-16,d0
	move.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y-16,d1
	add.w	(a0)+,d0
	add.w	(a0)+,d1
	moveq.l	#5,d5			; Display transport
	jsr	Put_masked_block
	Free	Transgfx_handle
	bra	.Exit
.No_trans:	Get	Transgfx_handle,a0		; Seek graphics
	move.l	Current_location_status,d0	; Get sit/sleep status
	andi.l	#Sit_sleep_mask,d0
	rol.l	#8,d0
	rol.l	#1,d0
	tst.w	d0			; Just standing ?
	bne	.No
	move.w	View_direction,d0		; Yes -> Choose direction
	mulu.w	#Party_frames,d0
;	tst.b	Animate_party_flag		; Animate ?
;	bne.s	.Anim
;	addq.w	#1,d0			;     No -> Central frame
;	bra.s	.Do
.Anim:	add.w	Party_frame,d0		;     Yes -> Animate
	bra.s	.Do
.No:	addi.w	#4*Party_frames-1,d0	; No -> Choose special frame
.Do:	mulu.w	#Icon_size*2,d0
	add.l	d0,a0
	move.w	Mapbuf_X,d0		; Get coordinates
	lsl.w	#4,d0
	addi.w	#Map2D_X,d0
	move.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y-16,d1
	moveq.l	#5,d5			; Display party
	moveq.l	#1,d6
	moveq.l	#32,d7
	jsr	Put_masked_block
	Free	Transgfx_handle
.Exit:	movem.l	(sp)+,d0/d1/d5-d7/a0
	rts

;*****************************************************************************
; [ Display 2D underlay ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number (.b)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon graphics (.l)
;        a5 - Pointer to icon info (.l)
; All registers are restored
;*****************************************************************************
Display_2D_underlay:
	movem.l	d5/a0,-(sp)
	cmp.b	#1,d2			; Underlay ?
	bne.s	.Yes
	movem.l	d2-d4,-(sp)		; No
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#0,d4
	jsr	Draw_box
	movem.l	(sp)+,d2-d4
	bra.s	.Exit
.Yes:	andi.w	#$00ff,d2			; Yes
	jsr	Get_icon_frame_address
	moveq.l	#5,d5
	jsr	Put_unmasked_icon
.Exit:	movem.l	(sp)+,d5/a0
	rts

;*****************************************************************************
; [ Display 2D overlay ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number (.w)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon data (.l)
; All registers are restored
;*****************************************************************************
Display_2D_overlay:
	movem.l	d5/a0,-(sp)
	jsr	Get_icon_frame_address
	moveq.l	#5,d5
	jsr	Put_masked_icon
	movem.l	(sp)+,d5/a0
	rts

;*****************************************************************************
; [ Display 2D person ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - NPC index + 1 (.b)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon data (.l)
;        a5 - Pointer to icon info (.l)
; All registers are restored
; Note :
;  - This routine assumes the proper CA has been installed.
;*****************************************************************************
Display_2D_person:
	movem.l	d0-d7/a0-a2,-(sp)
	lea.l	VNPC_data,a1		; Get NPC data
	andi.w	#$00ff,d2			; !
	subq.w	#1,d2			; !
	move.w	d2,Current_NPC		; Set
	mulu.w	#VNPC_data_size,d2
	add.w	d2,a1
	bclr	#NPC_sleeping,VFlags(a1)	; Clear flag
	move.w	NPC_icon_nr(a1),d2		; Get icon number
	move.l	NPC_icon_status(a1),d4	; Get icon status bits
	btst	#3,NPC_status_bits(a1)	; NPC or map graphics ?
	beq.s	.NPC
; ---------- Map graphics -------------------------
	cmp.w	#Map2D_Y+Mapbuf_height*16,d1	; Out of window ?
	bpl	.Exit
	btst	#Underlay_bit,d4		; Under- or overlay ?
	bne.s	.Over
	jsr	Display_2D_underlay		; Show underlay
	bra	.Exit
.Over:	jsr	Display_2D_overlay		; Show overlay
	bra	.Exit
; ---------- NPC graphics -------------------------
.NPC:	move.w	d0,d6			; Save coordinates
	move.w	d1,d7
	move.w	VMap_X(a1),d0		; Get location status
	move.w	VMap_Y(a1),d1
	jsr	Get_location_status
	btst	#Party_invisible_bit,d0	; Invisible ?
	bne	.Exit
	andi.l	#Sit_sleep_mask,d0		; Get sit/sleep status
	rol.l	#8,d0
	rol.l	#1,d0
	tst.w	d0			; Just standing ?
	bne	.No
; ---------- Just standing ------------------------
	move.w	d6,d0			; Restore coordinates
	move.w	d7,d1
	Get	NPCgfx_handle,a0		; Seek graphics
	bra.s	.Entry
.Loop:	moveq.l	#0,d7			; Get number of frames
	move.b	(a0),d7
	addq.l	#2,a0
	mulu.w	#Icon_size*2,d7		; Skip graphics
	add.l	d7,a0
.Entry:	dbra	d2,.Loop
	moveq.l	#0,d3			; Default frame
	moveq.l	#0,d2			; Get number of frames
	move.b	(a0),d2
	addq.l	#2,a0
	cmp.w	#1,d2			; Any animation ?
	beq.s	.No_anim
	lea.l	Circle_anim-4,a2		; Circle or wave ?
	btst	#Circle_wave_bit,d4
	beq.s	.Circle
	lea.l	Wave_anim-4,a2		; Wave
.Circle:	lsl.w	#2,d2			; Add number of frames
	adda.w	d2,a2
	btst	#Random_anim_bit,d4		; Random animation ?
	beq.s	.No_random
	moveq.l	#0,d2			; Random hash
	move.b	1(a2),d2
	add.w	d2,d5	
	andi.w	#$000f,d5
	move.w	2(a2),d2			; Test
	btst	d5,d2
	beq.s	.No_anim
.No_random:
	add.b	(a2),d3			; Get current frame
.No_anim:	mulu.w	#Icon_size*2,d3		; Calculate frame address
	adda.l	d3,a0
	subi.w	#16,d1			; Display NPC
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#32,d7
 	jsr	Put_masked_block
	Free	NPCgfx_handle
	bra	.Exit
; ---------- Sitting or sleeping ------------------
.No:	cmp.w	#Sleeping,d0		; Sleeping ?
	bne.s	.Awake
	bset	#NPC_sleeping,VFlags(a1)	; Yup
.Awake:	Get	Transgfx_handle,a0		; Seek graphics
	addi.w	#4*Party_frames-1,d0
	mulu.w	#Icon_size*2,d0
	add.l	d0,a0
	move.w	d6,d0			; Restore coordinates
	move.w	d7,d1
	subi.w	#16,d1
	moveq.l	#5,d5			; Display party
	moveq.l	#1,d6
	moveq.l	#32,d7
	jsr	Put_masked_block
	Free	Transgfx_handle
.Exit:	move.w	#-1,Current_NPC		; Clear
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Display 2D transport ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Transport type (.b)
;        d5 - Hashable number (.w)
;        a5 - Pointer to icon info (.l)
; All registers are restored
; Note :
;  - This routine assumes the proper CA has been installed.
;*****************************************************************************
Display_2D_transport:
	movem.l	d0-d2/d5-d7/a0/a1,-(sp)
	lea.l	Stationary_table,a0		; Which graphics ?
	move.b	0(a0,d2.w),d2
	ext.w	d2
	bmi	.Exit
	Get	Stationary_handle,a0	; Seek graphics
	lea.l	Stationary_dimensions,a1
	bra.s	.Entry
.Loop:	move.w	(a1)+,d5			; Skip graphics
	lsr.w	#4,d5
	mulu.w	(a1)+,d5
	mulu.w	#Screen_depth*2,d5
	add.l	d5,a0
.Entry:	dbra	d2,.Loop
	move.w	(a1)+,d6			; Get dimensions
	move.w	(a1)+,d7
	addq.w	#7,d0			; Centre coordinates
	addq.w	#6,d1
	move.w	d6,d2
	lsr.w	#1,d2
	sub.w	d2,d0
	move.w	d7,d2
	lsr.w	#1,d2
	sub.w	d2,d1
	lsr.w	#4,d6			; Display transport
	moveq.l	#5,d5
	jsr	Put_masked_block
	Free	Stationary_handle
.Exit:	movem.l	(sp)+,d0-d2/d5-d7/a0/a1
	rts

;*****************************************************************************
; [ Get icon frame address ]
;   IN : d2 - Icon number (.w)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon graphics (.l)
;        a5 - Pointer to icon info (.l)
;  OUT : a0 - Icon frame address (.l)
; Changed registers : a0
;*****************************************************************************
Get_icon_frame_address:
	movem.l	d2-d5/a1/a2,-(sp)
	lsl.w	#3,d2			; Get pointer to icon info
	lea.l	-8+2(a5,d2.w),a1
	move.l	Icon_bits(a1),d2		; Get icon status
	moveq.l	#0,d3			; Get number of first frame
	move.w	Icon_1st_frame(a1),d3
	moveq.l	#0,d4			; Get number of frames
	move.b	Icon_nr_frames(a1),d4
	cmp.w	#1,d4			; Any animation ?
	beq.s	.No_anim
	lea.l	Circle_anim-4,a2		; Circle or wave ?
	btst	#Circle_wave_bit,d2
	beq.s	.Circle
	lea.l	Wave_anim-4,a2		; Wave
.Circle:	lsl.w	#2,d4			; Add number of frames
	adda.w	d4,a2
	btst	#Random_anim_bit,d2		; Random animation ?
	beq.s	.No_random
	moveq.l	#0,d4			; Random hash
	move.b	1(a2),d4
	add.w	d4,d5	
	andi.w	#$000f,d5
	move.w	2(a2),d4			; Test
	btst	d5,d4
	beq.s	.No_anim
.No_random:	
	moveq.l	#0,d4			; Get current frame
	move.b	(a2),d4
	add.w	d4,d3
.No_anim:	subq.w	#1,d3			; Calculate frame address
	mulu.w	#Icon_size,d3
	adda.l	d3,a0
	movem.l	(sp)+,d2-d5/a1/a2
	rts

;*****************************************************************************
; [ Display night circle ]
; All registers are restored
;*****************************************************************************
Display_2D_night:
	movem.l	d0-d7,-(sp)
	cmpi.w	#Super_chicken,Travel_mode	; Superchicken mode ?
	beq	.Exit
; ---------- Change radius if necessary -----------
	move.w	Current_light_level,d4		; Circle on ?
	bne.s	.Ok
	tst.w	New_light_level
	beq	.Exit
.Ok:	cmp.w	New_light_level,d4		; New radius ?
	beq.s	.Continue
	bmi.s	.Up
	subq.w	#4,d4			; Count down
	bra.s	.Store
.Up:	addq.w	#4,d4			; Count up
	cmpi.w	#Max_radius,d4		; Check
	bhi	.Exit
.Store:	move.w	d4,Current_light_level		; Store new radius
.Continue:	move.w	Mapbuf_X,d6		; Calculate centre coordinates
	move.w	Mapbuf_Y,d7
	lsl.w	#4,d6
	lsl.w	#4,d7
	addq.w	#8,d6
	addq.w	#8,d7
; ---------- Erase area above circle --------------
	move.w	d7,d3			; Calculate Y at top of circle
	sub.w	d4,d3
	cmpi.w	#Mapbuf_height*16-1,d3	; Out of range ?
	bhi.s	.Clipped1
	move.w	#Map2D_X,d0		; Erase area above circle
	move.w	#Map2D_Y,d1
	move.w	d0,d2
	addi.w	#Mapbuf_width*16-1,d2
	addi.w	#Map2D_Y,d3
	move.l	d4,-(sp)
	moveq.l	#0,d4
	jsr	Draw_box
	move.l	(sp)+,d4
; ---------- Erase area below circle --------------
.Clipped1:	move.w	d7,d1			; Calculate Y at bottom of circle
	add.w	d4,d1
	cmpi.w	#Mapbuf_height*16-1,d1	; Out of range ?
	bhi.s	.Clipped2
	move.w	#Map2D_X,d0		; Erase area below circle
	addi.w	#Map2D_Y,d1
	move.w	#Map2D_X+Mapbuf_width*16-1,d2
	move.w	#Map2D_Y+Mapbuf_height*16-1,d3
	move.l	d4,-(sp)
	moveq.l	#0,d4
	jsr	Draw_box
	move.l	(sp)+,d4
; ---------- Draw circle --------------------------
.Clipped2:	moveq.l	#0,d0			; Initialize registers
	move.w	d4,d1
	moveq.l	#0,d2
	move.w	d4,d3
	subq.w	#1,d3
	add.w	d3,d3
.Again:	exg.l	d0,d1			; Draw lines
	jsr	Draw_four_lines
	exg.l	d0,d1
	addq.w	#1,d0			; x = x + 1
	add.w	d2,d4			; xy2 = xy2 + dx
	addq.w	#2,d2			; dx = dx + 2
	tst.w	d4			; xy2 >= 0 ?
	bmi.s	.Skip
	jsr	Draw_four_lines		; Draw lines
	subq.w	#1,d1			; y = y - 1
	sub.w	d3,d4			; xy2 = xy2 - dy
	subq.w	#2,d3			; dy = dy - 2
.Skip:	cmp.w	d1,d0			; UNTIL x > y
	bls.s	.Again
.Exit:	movem.l	(sp)+,d0-d7
	rts

; [ Draw four horizontal lines ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Centre X-coordinate (.w)
;        d7 - Centre Y-coordinate (.w)
; All registers are restored
; NOTE : All coordinates are relative to the top-left corner of the map window
Draw_four_lines:
	movem.l	d1/d3/d4,-(sp)
	move.w	d6,d3			; Calculate coordinates
	add.w	d0,d3
	move.w	d6,d4
	sub.w	d0,d4
	add.w	d7,d1
	jsr	Draw_two_lines		; Draw top
	sub.w	d7,d1
	neg.w	d1
	add.w	d7,d1
	jsr	Draw_two_lines		; Draw bottom
	movem.l	(sp)+,d1/d3/d4
	rts

; [ Draw two horizontal lines ]
;   IN : d1 - Y-coordinate (.w)
;        d3 - Left X-coordinate of right H-line (.w)
;        d4 - Right X-coordinate of left H-line (.w)
; All registers are restored
Draw_two_lines:
	movem.l	d0-d2/d4,-(sp)
	cmpi.w	#Mapbuf_height*16-1,d1	; Y out of range ?
	bhi.s	.Exit
	addi.w	#Map2D_Y,d1
	cmpi.w	#Mapbuf_width*16-1,d3	; Right H-line out of range ?
	bhi.s	.Clipped
	move.w	d3,d0			; Draw right H-line
	addi.w	#Map2D_X,d0
	move.w	#Map2D_X+Mapbuf_width*16-1,d2
	move.l	d4,-(sp)
	moveq.l	#0,d4
	jsr	Draw_hline
	move.l	(sp)+,d4
.Clipped:	cmpi.w	#Mapbuf_width*16-1,d4	; Left H-line out of range ?
	bhi.s	.Exit
	move.w	#Map2D_X,d0		; Draw left H-line
	move.w	d4,d2
	addi.w	#Map2D_X,d2
	moveq.l	#0,d4
	jsr	Draw_hline
.Exit:	movem.l	(sp)+,d0-d2/d4
	rts

;*****************************************************************************
; [ Check if movement is possible (2D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : eq - Movement possible
;        ne - Movement impossible
; All registers are restored
;*****************************************************************************
Movement_check_2D:
	movem.l	d0-d2,-(sp)
	moveq.l	#-1,d2			; Zero flag off
	cmp.b	#World_2D,Current_map_type	; 2D city map ?
	beq.s	.World
	cmp.w	#1,d0			; X too low ?
	blt.s	.Exit
	cmp.w	Width_of_map,d0		; X too high ?
	bgt.s	.Exit
	cmp.w	#1,d1			; Y too low ?
	blt.s	.Exit
	cmp.w	Height_of_map,d1		; Y too high ?
	bgt.s	.Exit
.World:	cmpi.w	#Super_chicken,Travel_mode	; Cheat mode ?
	bne.s	.Normal
	moveq.l	#0,d2			; Force zero
	bra	.Exit
.Normal:	jsr	Get_location_status		; Get location status
	moveq.l	#0,d1
	tst.b	Show_trans		; Travelmodes ?
	beq.s	.Skip
	move.w	Travel_mode,d1		; Get travel mode
	cmp.w	#Swimming,d1		; Swimming ?
	bne.s	.Skip
	moveq.l	#On_foot,d1		; Yes -> Equals on foot
.Skip:	add.w	#Blocked_foot_bit,d1
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Exit
	btst.l	d1,d0			; Way possible for current
	seq	d2			;  travel mode ?
.Exit:	tst.b	d2			; Get zero flag
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Make a 2D map move ]
;   IN : d7 - Movement direction {0...7} (.w)
; All registers are restored
;*****************************************************************************
Make_2D_move:
	movem.l	d2/d3/d6/d7,-(sp)
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq.s	.Skip
	move.l	Timer,d2			; No -> Is it time ?
	move.w	#M2_movement_speed,d3
	sub.w	Time_warp,d3
	cmp.w	d3,d2
	bmi.s	.Exit
.Skip:	sf	Bumped			; Clear flags
	sf	Moved
	jsr	Before_move		; Before move logic
	bne	.Exit			; Move allowed ?
	move.w	Map_Xcoord,d2		; Get party coordinates
	move.w	Map_Ycoord,d3
	move.w	d7,d6			; Store
	jsr	Try_2D_move		; Try original direction
	tst.b	Moved			; Possible ?
	bne.s	.Exit
	btst	#0,d6			; Orthogonal ?
	beq.s	.Ouch
	move.b	.2nd_try(pc,d6.w),d7	; No
	jsr	Try_2D_move		; Try vertical
	tst.b	Moved			; Possible ?
	bne.s	.Exit
	move.b	.3rd_try(pc,d6.w),d7	; No
	jsr	Try_2D_move		; Try diagonal
	tst.b	Moved			; Possible ?
	bne.s	.Exit
.Ouch:	st	Bumped			; Bump !
.Exit:	movem.l	(sp)+,d2/d3/d6/d7
	rts

.2nd_try:	dc.b 0,0,2,4,4,4,6,0
.3rd_try:	dc.b 0,2,2,2,4,6,6,6
	even

;*****************************************************************************
; [ Try a 2D map move ]
;   IN : d2 - X-coordinate of party (.w)
;        d3 - Y-coordinate of party (.w)
;        d7 - Movement direction {0...7} (.w)
; All registers are restored
;*****************************************************************************
Try_2D_move:
	movem.l	d0-d3/d7,-(sp)
	move.b	.View(pc,d7.w),d0		; Set view direction
	ext.w	d0
	move.w	d0,View_direction
	move.w	d2,d0			; Get party coordinates
	move.w	d3,d1
	add.w	d7,d7			; Get coordinate offsets
	move.b	.Offsets(pc,d7.w),d2
	move.b	.Offsets+1(pc,d7.w),d3
	ext.w	d2
	ext.w	d3
	add.w	d2,d0			; Move
	add.w	d3,d1
	jsr	Movement_check_2D
	bne.s	.Exit			; Possible ?
	move.w	d0,Map_Xcoord		; Yes -> store new coordinates
	move.w	d1,Map_Ycoord
	cmp.b	#World_2D,Current_map_type	; World map ?
	bne.s	.Skip
	add.w	d2,Quad_X			; Update quad-map coordinates
	add.w	d3,Quad_Y
	jsr	Quad_evaluate		; Re-evaluate world map
.Skip:	st	Moved			; Yay!
	jsr	Animate_party
	jsr	After_move
	clr.l	Timer			; Reset clock
.Exit:	movem.l	(sp)+,d0-d3/d7
	rts

.View:	dc.b 0,0,1,2,2,2,3,0
.Offsets:	dc.b 0,-1,1,-1,1,0,1,1,0,1,-1,1,-1,0,-1,-1
	even

;*****************************************************************************
; [ Animate 2D party graphics ]
; All registers are restored
;*****************************************************************************
Animate_party:
	move.l	d0,-(sp)
	move.w	Party_frame,d0		; Get current frame
	tst.b	Party_animate_state		; Back or forth ?
	bne.s	.Back
	addq.w	#1,d0			; Forth
	cmp.w	#Party_frames,d0		; Last ?
	bmi.s	.Store
	subq.w	#2,d0			; Yes -> Reverse
	st	Party_animate_state
	bra.s	.Store
.Back:	subq.w	#1,d0			; Back
	bpl.s	.Store			; First ?
	addq.w	#2,d0			; Yes -> Reverse
	sf	Party_animate_state
.Store:	move.w	d0,Party_frame		; Store new frame
;	st	Animate_party_flag		; Signal
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ 2D map - Move down/right ]
; All registers are restored
;*****************************************************************************
M2_downright:
	moveq.l	#3,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ 2D map - Move up/right ]
; All registers are restored
;*****************************************************************************
M2_upright:
	moveq.l	#1,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ 2D map - Move down/left ]
; All registers are restored
;*****************************************************************************
M2_downleft:
	moveq.l	#5,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ 2D map - Move up/left ]
; All registers are restored
;*****************************************************************************
M2_upleft:
	moveq.l	#7,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ 2D map - Move up ]
; All registers are restored
;*****************************************************************************
M2_up:
	moveq.l	#0,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ 2D map - Move down ]
; All registers are restored
;*****************************************************************************
M2_down:
	moveq.l	#4,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ 2D map - Move right ]
; All registers are restored
;*****************************************************************************
M2_right:
	moveq.l	#2,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ 2D map - Move left ]
; All registers are restored
;*****************************************************************************
M2_left:
	moveq.l	#6,d7
	jmp	Make_2D_move

;*****************************************************************************
; [ Insert transports in map buffer ]
;   IN : d0 - Top-left X-coordinate of map window (.w)
;        d1 - Top-left Y-coordinate of map window(.w)
;        d2 - Map number (.w)
;        d4 - Map buffer offset X {0...Mapbuf_width-1} (.w)
;        d5 - Map buffer offset Y {0...Mapbuf_height-1} (.w)
;        d6 - Width of area - 1 (.w)
;        d7 - Height of area - 1 (.w)
; All registers are restored
;*****************************************************************************
Insert_transports:
	movem.l	d0-d7/a0/a1,-(sp)
	tst.b	Show_trans		; Show ?
	beq	.Exit
	lea.l	Trans_buffer,a1		; Calculate buffer pointer
	mulu.w	#Mapbuf_width+2,d5
	add.w	d5,d4
	add.w	d4,a1
	subq.w	#1,d0			; Calculate clip edges
	subq.w	#1,d1
	move.w	d0,d4
	move.w	d1,d5
	add.w	d0,d6
	add.w	d1,d7
	addq.w	#3-1,d6
	addq.w	#3-1,d7
	lea.l	Trans_data,a0
	moveq.l	#Max_transports-1,d3
.Loop:	tst.b	Trans_type(a0)		; Anything there ?
	beq.s	.Next
	cmp.w	Trans_map_nr(a0),d2		; Current map ?
	bne.s	.Next
	moveq.l	#0,d0			; Get coordinates
	move.b	Trans_X(a0),d0
	subq.w	#1,d0
	moveq.l	#0,d1
	move.b	Trans_Y(a0),d1
	subq.w	#1,d1
	cmp.w	d4,d0			; X too low ?
	bmi.s	.Next
	cmp.w	d0,d6			; X too high ?
	bmi.s	.Next
	cmp.w	d5,d1			; Y too low ?
	bmi.s	.Next
	cmp.w	d1,d7			; Y too high ?
	bmi.s	.Next
	sub.w	d4,d0			; Calculate buffer coordinates
	sub.w	d5,d1
	muls.w	#Mapbuf_width+2,d1		; Calculate buffer offset
	add.w	d0,d1
	move.b	Trans_type(a0),d0		; Insert transport
	move.b	d0,0(a1,d1.w)
.Next:	addq.w	#Trans_data_size,a0	; Next transport
	dbra	d3,.Loop
.Exit:	movem.l	(sp)+,d0-d7/a0/a1
	rts

;*****************************************************************************
; [ Clear persons buffer ]
; All registers are restored
;*****************************************************************************
Clear_persons_buffer:
	movem.l	d0/d7/a0,-(sp)
	lea.l	Persons_buffer,a0
	moveq.l	#0,d0
	move.w	#((Mapbuf_height+1)*Mapbuf_width)/2-1,d7
.Loop:	move.w	d0,(a0)+
	dbra	d7,.Loop
	clr.b	(a0)+
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Clear transport buffer ]
; All registers are restored
;*****************************************************************************
Clear_trans_buffer:
	movem.l	d0/d7/a0,-(sp)
	lea.l	Trans_buffer,a0
	moveq.l	#0,d0
	move.w	#((Mapbuf_height+2)*(Mapbuf_width+2))/2-1,d7
.Loop:	move.w	d0,(a0)+
	dbra	d7,.Loop
	clr.b	(a0)+
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Re-evaluate light in 2D maps ]
; All registers are restored
;*****************************************************************************
Evaluate_2D_light:
	movem.l	d0/d1/a0,-(sp)
; ---------- Check if active character is blind ---
	Get	Active_handle,a0		; Well ?
	move.w	Body_conditions(a0),d0
	Free	Active_handle
	btst	#Blind,d0
	sne	Stygian			; Darkness !
	bne	.Exit
; ---------- Check map status bits ----------------
	Get	Mapdata_handle,a0		; Get map status bits
	move.w	Map_special(a0),d0
	Free	Mapdata_handle
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
	tst.w	Spell_1_duration		; Any light spell active ?
	beq.s	.No
	move.w	Spell_1_data,d0		; Add light spell's effect
	lsl.w	#4,d0
	add.w	d0,d1
.No:	move.w	d1,New_light_level		; Store
	bra	.Exit
.Radius:	dc.b 16,16,16,16,16,16,40,64
	dcb.b 9,200
	dc.b 64,64,40,16,16,16,16,16
	even
.No_change:
	btst	#Dark_bit,d0		; Always dark ?
	beq.s	.Exit
	cmpi.w	#Super_chicken,Travel_mode	; Superchicken mode ?
	beq.s	.Exit
	tst.w	Spell_1_duration		; Any light spell active ?
	seq	Stygian
	beq.s	.Exit
	move.w	Spell_1_data,d1		; Get light spell's effect
	lsl.w	#4,d1
	addi.w	#32,d1
	move.w	d1,New_light_level		; Store
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Initialize travelmode ]
; All registers are restored
;*****************************************************************************
Init_travelmode:
	movem.l	d0/d1,-(sp)
	tst.b	Travelmode_present		; Already loaded ?
	beq.s	.No
	jsr	Exit_travelmode		; Yes -> Remove
.No:	move.w	Travel_mode,d0		; Load graphics
	addq.w	#1,d0			; !!!
	moveq.l	#Trans_gfx_file,d1
	jsr	Load_subfile
	move.b	d0,Transgfx_handle
	st	Travelmode_present		; Set
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Exit travelmode ]
; All registers are restored
;*****************************************************************************
Exit_travelmode:
	move.l	d0,-(sp)
	tst.b	Travelmode_present		; Any loaded ?
	beq.s	.Exit
	move.b	Transgfx_handle,d0		; Yes -> Remove
	jsr	Free_memory
	sf	Travelmode_present		; Clear
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Stationary_table:
	dc.b -1,0,1,2,-1,-1,-1,-1,-1,3,4
	even

; *** 2D MAP LAYOUT : 2nd layer ***
Map2D_L2:
	dc.w Map2D_X,Map2D_X+176-1,Map2D_Y,Map2D_Y+144-1	; Map area
	dc.b 2
	even
	dc.l Control_area,0

M2_CIL:	dc.w Cont+Upleft_2D_cicon,Cont+Up_2D_cicon,Cont+Upright_2D_cicon
	dc.w Cont+Left_2D_cicon,Hourglass_cicon,Cont+Right_2D_cicon
	dc.w Cont+Downleft_2D_cicon,Cont+Down_2D_cicon,Cont+Downright_2D_cicon
	dc.l M2_upleft,M2_up,M2_upright
	dc.l M2_left,Hourglass,M2_right
	dc.l M2_downleft,M2_down,M2_downright
	dc.l Map_CIL_evaluate
