; 3D map routines
; Written by Michael Bittner
; Modified for Amberstar 2 by J.Horneman (In Tune With The Universe)
; Start : 17-11-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Load 3D map data ]
; All registers are restored
;*****************************************************************************
Load_3D_map_data:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Load_map_texts
; ---------- Load labyrinth data ------------------
	Get	Mapdata_handle,a0
	moveq.l	#0,d0
	move.b	Icondat_filenr(a0),d0
	Free	Mapdata_handle
	moveq.l	#Lab_data_file,d1
	jsr	Load_subfile
	move.b	d0,Labdata_handle
; ---------- Load objects -------------------------
	Get	Labdata_handle,a2
	addq.w	#Lab_data,a2		; Skip object groups
	move.w	(a2)+,d0
	move.w	d0,Nr_of_groups
	mulu.w	#Objectgroup3D_data_size,d0
	add.l	d0,a2
	move.w	(a2)+,d7			; Get number of objects
	move.w	d7,Nr_of_objects
	beq.s	.Exit
	lea.l	Batch,a0			; Build batch
	bra.s	.Entry
.Loop:	move.w	Object_graphics_nr(a2),(a0)+
	lea.l	Object3D_data_size(a2),a2
.Entry:	dbra	d7,.Loop
	Free	Labdata_handle
	tst.b	Blitter_or_CPU		; Blitter or CPU ?
	bne.s	.CPU
	moveq.l	#Object_3D_CHIP_file,d1
	bra.s	.Go_on
.CPU:	moveq.l	#Object_3D_FAST_file,d1
.Go_on:	lea.l	Batch,a0			; Load batch
	lea.l	Object_handles,a1
	move.w	Nr_of_objects,d0
	jsr	Load_batch_of_subfiles
.Exit:	LOCAL
; ---------- Load walls ---------------------------
	Get	Labdata_handle,a2
	addq.w	#Lab_data,a2		; Skip object groups...
	move.w	(a2)+,d0
	mulu.w	#Objectgroup3D_data_size,d0
	add.l	d0,a2
	move.w	(a2)+,d0			; ...and objects
	mulu.w	#Object3D_data_size,d0
	add.l	d0,a2
	move.w	(a2)+,d7                      ; Get number of walls
	move.w	d7,Nr_of_walls
	move.l	a2,-(sp)			; Save
	lea.l	Batch,a0			; Make batch
	moveq.l	#0,d0
	move.w	#Overlay_data_size,d1
	bra	.Entry
.Loop:	move.b	Wall_graphics_nr(a2),d0	; Get wall graphics number
	moveq.l	#0,d2			; Get number of overlays
	move.b	Wall_nr_overlays(a2),d2
	beq.s	.Store			; Any ?
	bset	#15,d0			; Yes -> Unique
.Store:	move.w	d0,(a0)+			; Store
	mulu.w	d1,d2			; Next wall
	lea.l	Wall_data_size(a2,d2.w),a2
.Entry:	dbra	d7,.Loop
	tst.b	Blitter_or_CPU		; Blitter or CPU ?
	bne.s	.CPU
	moveq.l	#Wall_3D_CHIP_file,d1
	bra.s	.Go_on
.CPU:	moveq.l	#Wall_3D_FAST_file,d1
.Go_on:	lea.l	Batch,a0			; Load walls
	lea.l	Wall_handles,a1
	move.w	Nr_of_walls,d0
	jsr	Load_batch_of_unique_subfiles
	move.l	(sp)+,a2
	LOCAL
; ---------- Load & insert overlays ---------------
	lea.l	Wall_handles,a3
	move.w	Nr_of_walls,d4
	bra	.Entry1
.Loop1:	moveq.l	#0,d5			; Get number of overlays
	move.b	Wall_nr_overlays(a2),d5
	addq.w	#Wall_data_size,a2	; Skip
	tst.w	d5			; Any overlays ?
	beq	.Next1
	move.b	(a3),d0			; Yes -> Invalidate
	jsr	Invalidate_memory
	jsr	Claim_pointer		; Get wall address
	move.l	d0,a1
	bra	.Entry2
.Loop2:	moveq.l	#0,d0			; Load overlay graphics
	move.b	Overlay_graphics_nr(a2),d0
	moveq.l	#Overlay_3D_file,d1
	jsr	Load_subfile
	move.b	d0,d2
	jsr	Claim_pointer		; Put overlay on wall
	move.l	d0,a0
	moveq.l	#0,d0
	move.b	Overlay_X(a2),d0
	moveq.l	#0,d1
	move.b	Overlay_Y(a2),d1
	moveq.l	#0,d6
	move.b	Overlay_width(a2),d6
	moveq.l	#0,d7
	move.b	Overlay_height(a2),d7
	tst.b	Overlay_mask_flag(a2)	; Block or mask ?
	bne.s	.Mask
	jsr	Put_unmasked_MOVEP_block	; Block
	bra.s	.Done
.Mask:	jsr	Put_masked_MOVEP_block	; Mask
.Done:	move.b	d2,d0			; Remove overlay
	jsr	Free_pointer
	jsr	Free_memory
	addq.w	#Overlay_data_size,a2	; Next overlay
.Entry2:	dbra	d5,.Loop2
	move.b	(a3),d0			; Free
	jsr	Free_pointer
.Next1:	addq.l	#1,a3			; Next wall
.Entry1:	dbra	d4,.Loop1
	Free	Labdata_handle
	LOCAL
; ---------- Prepare horizon ----------------------
	Get	Mapdata_handle,a0		; Get background number
	moveq.l	#0,d0
	move.b	Background_filenr(a0),d0
	Free	Mapdata_handle
	tst.w	d0			; Any ?
	sne	Horizon_flag
	beq	.No
	moveq.l	#Lab_background_file,d1	; Load
	jsr	Load_subfile
	move.b	d0,Horizon_gfx_handle
	move.l	#Horizon_height*144*16,d0	; Make buffer
	tst.b	Blitter_or_CPU		; Blitter or CPU ?
	bne.s	.CPU
	jsr	Allocate_CHIP		; CHIP !!
	bra.s	.Go_on
.CPU:	jsr	Allocate_memory		; Normal
.Go_on:	move.b	d0,Horizon_preshift_handle
	Get	Horizon_gfx_handle,a1	; Initialize pointers
	lea.l	18(a1),a2
	lea.l	18(a2),a3
	lea.l	18(a3),a4
	lea.l	Eight_bytes,a5		; (8-byte buffer)
	Get	Horizon_preshift_handle,a6
	moveq.l	#Horizon_height-1,d7	; Preshift horizon
.Loop1:	moveq.l	#8-1,d6
.Loop2:	move.l	(a1),d1			; Load one trunc
	move.l	(a2),d2
	move.l	(a3),d3
	move.l	(a4),d4
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	move.l	a6,-(sp)
	moveq.l	#16-1,d5			; Shift 16 times
	bra.s	.Entry3
.Loop3:	rol.l	#1,d1			; Rotate
	rol.l	#1,d2
	rol.l	#1,d3
	rol.l	#1,d4
.Entry3:	movem.w	d1-d4,(a5)		; Store in 8 byte buffer
	movep.l	0(a5),d0			; Convert to MOVEP
	move.l	d0,72(a6)
	move.l	d0,(a6)+
	movep.l	1(a5),d0
	move.l	d0,72(a6)
	move.l	d0,(a6)
	lea.l	Horizon_height*144-4(a6),a6	; Next shift
	dbra	d5,.Loop3
	addq.l	#2,a1			; Next trunc
	addq.l	#2,a2
	addq.l	#2,a3
	addq.l	#2,a4
	move.l	(sp)+,a6
	addq.l	#8,a6
	dbra	d6,.Loop2
	move.w	-18+2(a1),d1		; Load last trunc
	move.w	-18+2(a2),d2
	move.w	-18+2(a3),d3
	move.w	-18+2(a4),d4
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	move.w	(a1),d1
	move.w	(a2),d2
	move.w	(a3),d3
	move.w	(a4),d4
	move.l	a6,-(sp)
	moveq.l	#16-1,d5			; Shift 16 times
	bra.s	.Entry4
.Loop4:	rol.l	#1,d1			; Rotate
	rol.l	#1,d2
	rol.l	#1,d3
	rol.l	#1,d4
.Entry4:	movem.w	d1-d4,(a5)		; Store in 8 byte buffer
	movep.l	0(a5),d0			; Convert to MOVEP
	move.l	d0,72(a6)
	move.l	d0,(a6)+
	movep.l	1(a5),d0
	move.l	d0,72(a6)
	move.l	d0,(a6)
	lea.l	Horizon_height*144-4(a6),a6	; Next shift
	dbra	d5,.Loop4
	move.l	(sp)+,a6			; Next trunc
	lea.l	72+8(a6),a6
	lea.l	3*18+2(a1),a1		; Next line
	lea.l	3*18+2(a2),a2
	lea.l	3*18+2(a3),a3
	lea.l	3*18+2(a4),a4
	dbra	d7,.Loop1
	Free	Horizon_preshift_handle
	move.b	Horizon_gfx_handle,d0	; Remove background
	jsr	Free_pointer
	jsr	Free_memory
.No:	LOCAL
; ---------- Determine floor/ceiling status -------
	moveq.l	#0,d0			; Determine potential
	tst.b	CPU_68020_plus		; Right processor ?
	beq.s	.Done
	moveq.l	#3,d0			; Yes
	cmp.b	#City_3D,Current_map_type	; City ?
	bne.s	.Ok1
	bclr	#1,d0			; Yes -> No ceiling
.Ok1:	Get	Labdata_handle,a0		; Floor given ?
	tst.b	Floor_graphics_nr(a0)
	bne.s	.Ok2
	bclr	#0,d0			; No -> No floor
.Ok2:	tst.b	Ceiling_graphics_nr(a0)	; Ceiling given ?
	bne.s	.Ok3
	bclr	#1,d0			; No -> No ceiling
.Ok3:	Free	Labdata_handle
.Done:	move.b	d0,Floor_ceiling_potential	; Store
	move.w	Internal_flags,d1		; Determine status
	andi.w	#$0018,d1
	lsr.w	#3,d1
	and.b	d0,d1
	move.b	d1,Floor_ceiling_status	; Store
	LOCAL
; ---------- Initialize floor & ceiling -----------
	move.b	Floor_ceiling_status,d7	; Any ?
	beq	.No
	btst	#0,d7			; Floor ?
	beq.s	.No_floor
	jsr	Load_floor
.No_floor:	btst	#1,d7			; Ceiling ?
	beq.s	.No_ceiling
	jsr	Load_ceiling
.No_ceiling:
	jsr	Create_MPB_table		; Make MPB table
.No:	LOCAL
; ---------- Initialize buffers & tables ----------
	tst.b	Blitter_or_CPU		; Blitter or CPU ?
	bne.s	.CPU
	move.l	#144*144,d0		; Allocate CHIP buffers
	jsr	Allocate_CHIP
	move.b	d0,Zoomscreen_handle
	move.l	#(144*144)/2+100,d0
	jsr	Allocate_CHIP
	jsr	Clear_memory
	move.b	d0,MOVEP_handle
	bra.s	.Go_on
.CPU:	move.l	#144*144,d0		; Allocate FAST buffers
	jsr	Allocate_FAST
	move.b	d0,Zoomscreen_handle
	move.l	#(144*144)/2+100,d0
	jsr	Allocate_FAST
	jsr	Clear_memory
	move.b	d0,MOVEP_handle
.Go_on:	moveq.l	#0,d0			; Already	present ?
	moveq.l	#Zoombuffer_file,d1
	jsr	Reallocate_memory
	tst.b	d0
	beq.s	.Load
	move.b	d0,Zoombuffer_handle	; Yes
	bra.s	.Skip
.Load:	move.l	#Max_zoom*(Max_zoom+2),d0	; No -> Allocate zoombuffer
	moveq.l	#0,d2
	jsr	File_allocate
	move.b	d0,Zoombuffer_handle
	Get	Zoombuffer_handle,a0	; Initialize
	jsr	Init_zoom_table
	Free	Zoombuffer_handle
.Skip:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Remove 3D map data ]
; All registers are restored
;*****************************************************************************
Remove_3D_map_data:
	movem.l	d0/d7/a0/a1,-(sp)
	move.b	Zoomscreen_handle,d0	; Free buffers
	jsr	Free_memory
	move.b	MOVEP_handle,d0
	jsr	Free_memory
	move.b	Zoombuffer_handle,d0
	jsr	Free_memory
	move.b	Floor_ceiling_status,d7	; Any ?
	beq	.No1
	btst	#0,d7			; Floor ?
	beq.s	.No_floor
	move.b	Floor_buffer_handle,d0	; Free floor
	jsr	Free_memory
.No_floor:	btst	#1,d7			; Ceiling ?
	beq.s	.No_ceiling
	move.b	Ceiling_buffer_handle,d0	; Free ceiling
	jsr	Free_memory
.No_ceiling:
	move.b	MPB_buffer_handle,d0	; Free MPB buffer
	jsr	Free_memory
.No1:	lea.l	Object_handles,a1		; Free object memory
	move.w	Nr_of_objects,d7
	bra.s	.Entry1
.Loop1:	move.b	(a1)+,d0
	jsr	Free_memory
.Entry1:	dbra	d7,.Loop1
	lea.l	Wall_handles,a1		; Free wall memory
	move.w	Nr_of_walls,d7
	bra.s	.Entry2
.Loop2:	move.b	(a1)+,d0
	jsr	Free_memory
.Entry2:	dbra	d7,.Loop2
	move.b	Labdata_handle,d0		; Free labyrinth data
	jsr	Free_memory
	move.b	Maptext_handle,d0		; Free map texts
	jsr	Free_memory
	tst.b	Horizon_flag		; Horizon ?
	beq.s	.No2
	move.b	Horizon_preshift_handle,d0	; Yes -> Free horizon data
	jsr	Free_memory
.No2:	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ 3D map ModInit ]
; No registers are restored
;*****************************************************************************
M3_ModInit:
	jsr	Load_3D_map_data
	jsr	Load_map_palette
	move.w	Map_nr,d7			; Make map modifications
	jsr	Make_modifications
	clr.w	FX_camera_height		; Clear
	clr.w	Current_sky_level
	clr.w	Current_light_level
; ---------- Initialize 3D stuff ------------------
	jsr	Calculate_labdata_offsets
	moveq.l	#psize_log,d7		; Initialize dimensions
	move.w	Width_of_map,d0
	move.w	d0,dsizex
	asl.w	d7,d0
	move.w	d0,dsizex2
	move.w	Height_of_map,d0
	move.w	d0,dsizey
	asl.w	d7,d0
	move.w	d0,dsizey2
	jsr	Initialize_3D_position
	move.w	#6*16,Dungeon_speed		; Set speed
	Get	Labdata_handle,a0		; Set sky & floor colour
	move.b	Sky_colour_nr(a0),d0
	moveq.l	#4-1,d7
.Loop1:	btst	d7,d0
	sne	d1
	ror.l	#8,d1
	dbra	d7,.Loop1
	move.l	d1,Sky_colour
	move.b	Floor_colour_nr(a0),d0
	moveq.l	#4-1,d7
.Loop2:	btst	d7,d0
	sne	d1
	ror.l	#8,d1
	dbra	d7,.Loop2
	move.l	d1,Floor_colour
	Free	Labdata_handle
	jsr	Calculate_camera_height
	LOCAL
; ---------- Do city/dungeon specifics ------------
	cmp.b	#City_3D,Current_map_type
	beq.s	.City
	move.w	#D3_horizon,scry		; Set horizon
	move.b	#D3_animspeed,Anim_speed	; Set animation parameters
	move.b	#D3_animspeed,Anim_count
	move.w	#D3_animbias,Anim_bias
	jsr	Update_light_status		; Update light
	bra	.Done
.City:	move.w	#C3_horizon,scry		; Set horizon
	move.b	#C3_animspeed,Anim_speed	; Set animation parameters
	move.b	#C3_animspeed,Anim_count
	move.w	#C3_animbias,Anim_bias
	move.w	Hour,d0			; Get current hour
	move.w	d0,d2			; Save
	subq.w	#1,d0			; Back in time
	bpl.s	.Ok
	moveq.l	#23,d0
.Ok:	move.w	d0,Hour
	jsr	Evaluate_C3_light		; Get old light level
	move.w	New_sky_level,d0
	move.w	New_light_level,d1
	move.w	d2,Hour			; Restore time
	jsr	Evaluate_C3_light		; Get current light level
	cmp.w	New_sky_level,d0		; Fade sky ?
	bne.s	.Yes
	cmp.w	New_light_level,d1		; Fade light ?
	bne.s	.Yes
	jsr	Update_light_status		; No -> Update
	bra.s	.Done
.Yes:	move.w	d0,Current_sky_level	; Yes
	move.w	d1,Current_light_level
	move.w	Minute,d0			; Adjust fade
	divu.w	#Minutes_per_step,d0
	bra.s	.Entry
.Loop:	jsr	Update_M3_light_level
.Entry:	dbra	d0,.Loop
.Done:	LOCAL
; ---------- Check wall transparencies ------------
	lea.l	Wall_data_offsets,a0
	lea.l	Wall_transparencies,a1
	Get	Labdata_handle,a2
	move.w	Nr_of_walls,d7
	bra.s	.Entry
.Loop:	move.l	a2,a3			; Get wall data address
	add.l	(a0)+,a3
	move.l	Wall_bits(a3),d0
	btst	#Transparent_wall_bit,d0	; Transparent ?
	sne	(a1)+
.Entry:	dbra	d7,.Loop
	Free	Labdata_handle
	LOCAL
; ---------- More initialization ------------------
	jsr	Init_persons_3D		; Initialize persons
	move.w	Map_Xcoord,d0		; Get first status
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	move.l	d0,Current_location_status
; ---------- Float up/down ------------------------
	tst.b	Float_up			; Up ?
	beq	.Not_up
	move.w	#-wall_height+16,d0		; Yes -> Set first height
	move.w	d0,FX_camera_height
	jsr	Init_display		; Initialize display
	jsr	Update_screen		; Go
	moveq.l	#2,d1
.Again1:	cmp.w	#0,d0			; In the middle ?
	bge.s	.Done1
	move.w	d0,FX_camera_height		; No -> Set new height
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	add.w	d1,d0			; Move up
	addq.w	#2,d1			; Faster
	bra.s	.Again1
.Done1:	jsr	Copy_screen		; The end
	clr.w	FX_camera_height
	bra	.Go_on
.Not_up:	tst.b	Float_down		; Down ?
	beq.s	.Not_down
	Get	Labdata_handle,a0		; Yes -> Set first height
	move.w	Wall_in_cm(a0),d0
	Free	Labdata_handle
	lsr.w	#1,d0
	sub.w	head_height,d0
	move.w	d0,FX_camera_height
	jsr	Init_display		; Initialize display
	jsr	Update_screen		; Go
	moveq.l	#-2,d1
.Again2:	tst.w	d0			; In the middle ?
	ble.s	.Done2
	move.w	d0,FX_camera_height		; No -> Set new height
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	add.w	d1,d0			; Move down
	subq.w	#2,d1			; Faster
	bra.s	.Again2
.Done2:	jsr	Copy_screen		; The end
	clr.w	FX_camera_height
	bra.s	.Go_on
.Not_down:	jsr	Init_display		; Initialize display
.Go_on:	sf	Float_up			; Clear
	sf	Float_down
	jsr	Init_automap		; Initialize automap
	jsr	Update_automap
	jsr	Save_coordinates		; First time
	jmp	After_move		; Handle first step

;*****************************************************************************
; [ 3D map ModExit ]
; No registers are restored
;*****************************************************************************
M3_ModExit:
	jsr	Exit_automap		; Save automap
	move.b	Mapdata_handle,d0		; Free memory
	jsr	Free_memory
	moveq.l	#0,d0			; Stop music
	jsr	Set_music
	jmp	Remove_3D_map_data

;*****************************************************************************
; [ Adjust 3D position ]
; All registers are restored
; Notes :
;   - This routine will not do anything if called in a 2D map.
;*****************************************************************************
Jumped:
	cmpi.b	#Map_3D,Current_map_type	; 3D map ?
	bmi.s	.No_3D
	jsr	Update_automap		; Update !
	jsr	Initialize_3D_position
.No_3D:	rts

;*****************************************************************************
; [ Initialize 3D position ]
; All registers are restored
;*****************************************************************************
Initialize_3D_position:
	movem.l	d0-d2/d5-d7/a0,-(sp)
	moveq.l	#0,d0			; Get dungeon position
	moveq.l	#0,d1
	move.w	Map_Xcoord,d0
	move.w	Map_Ycoord,d1
	jsr	Map_to_dungeon
	andi.w	#-patt_size,d0		; Set to bottom-left corner
	andi.w	#-patt_size,d1
	move.l	d0,d5			; Save clean position
	move.l	d1,d6
	lea.l	Alternate_positions,a0	; Try positions in map square
	moveq.l	#9-1,d7
.Loop:	move.l	d5,d0			; Add offset
	move.l	d6,d1
	add.w	(a0)+,d0
	add.w	(a0)+,d1
	swap	d0
	swap	d1
	jsr	Movement_check_3D		; Possible ?
	beq.s	.Store
	dbra	d7,.Loop			; No -> Next
	move.l	d5,d0			; Centre anyway
	move.l	d6,d1
	addi.w	#patt_size/2,d0
	addi.w	#patt_size/2,d1
	swap	d0
	swap	d1
.Store:	move.l	d0,Player_X		; Store
	move.l	d1,Player_Y
	moveq.l	#0,d0			; Initialize direction
	move.w	View_direction,d0
	mulu.w	#slang/4,d0
	neg.w	d0
	andi.w	#slang-1,d0
	swap	d0
	move.l	d0,Y_angle
	movem.l	(sp)+,d0-d2/d5-d7/a0
	rts

;*****************************************************************************
; [ Calculate lab-data offsets ]
; All registers are restored
;*****************************************************************************
Calculate_labdata_offsets:
	movem.l	d0/d1/d7/a2/a3,-(sp)
	Get	Labdata_handle,a2
	move.l	a2,d1
	addq.w	#Lab_data,a2
	move.w	(a2)+,d0			; Skip object groups
	mulu.w	#Objectgroup3D_data_size,d0
	add.l	d0,a2
	move.w	(a2)+,d7			; Get number of objects
	move.l	a2,d0			; Store offset
	sub.l	d1,d0
	move.l	d0,Object_data_offset
	mulu.w	#Object3D_data_size,d7	; Skip objects
	add.l	d7,a2
	lea.l	Wall_data_offsets,a3	; Calculate wall offsets
	move.w	(a2)+,d7
	bra.s	.Entry
.Loop:	move.l	a2,d0			; Store offset
	sub.l	d1,d0
	move.l	d0,(a3)+
	moveq.l	#0,d0			; Skip overlay data
	move.b	Wall_nr_overlays(a2),d0
	mulu.w	#Overlay_data_size,d0
	add.l	d0,a2
	addq.w	#Wall_data_size,a2	; Next wall
.Entry:	dbra	d7,.Loop
	Free	Labdata_handle
	movem.l	(sp)+,d0/d1/d7/a2/a3
	rts

;*****************************************************************************
; [ 3D map DisInit ]
; No registers are restored
;*****************************************************************************
M3_DisInit:
	jsr	Set_spell_area		; Reset variables
	moveq.l	#Map3D_layout,d0		; Show 3D map layout
	jsr	Show_layout
	jsr	Print_headline
	move.l	#M3_CIL,First_CIL_ptr	; Display control icons
	jsr	Init_map_CIL
	move.w	#-1,Previous_SIF_changes	; Update all special items
	st	NPCs_off			; Display 3D map
	jsr	Update_display
	sf	NPCs_off
	jsr	Fade_in_bottom		; Fade in
	jsr	Set_map_music		; Start the music
	sf	Time_lock			; Start the clock
	rts

;*****************************************************************************
; [ 3D map DisUpd ]
; All registers are restored
;*****************************************************************************
Map3D_DisUpd:
	cmp.b	#City_3D,Current_map_type	; City or dungeon ?
	beq.s	.City
	jsr	Evaluate_D3_light		; Dungeon
	bra.s	.Done
.City:	jsr	Evaluate_C3_light		; City
.Done:	jsr	NPC_manager_3D		; Handle persons
	jsr	M3_DisUpd			; Display map
	jmp	Map_DisUpd		; The usual

;*****************************************************************************
; [ Display 3D map ]
; All registers are restored
;*****************************************************************************
M3_DisUpd:
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	Timer			; Reset time
	Push	CA,Map3D_L2
	move.w	Y_angle,d0		; Set view direction
	neg.w	d0
	subi.w	#slang/8,d0
	andi.w	#slang-1,d0
	ext.l	d0
	divu.w	#slang/4,d0
	addq.w	#1,d0
	andi.w	#$0003,d0
	move.w	d0,View_direction
; ---------- Test for complete darkness -----------
	tst.b	Stygian			; Complete darkness ?
	beq.s	.See
	move.w	#Map3D_X,d0		; Erase map area
	move.w	#Map3D_Y,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#144-1,d2
	addi.w	#144-1,d3
	moveq.l	#0,d4
	jsr	Draw_box
	bra	.Done
; ---------- Pre-calculate addresses --------------
.See:	move.b	MOVEP_handle,d0		; Set MOVEP-screen pointer
	jsr	Claim_pointer
	move.l	d0,MOVEP_ptr
	Get	Zoomscreen_handle,a0	; Set zoom-screen pointers
	move.l	a0,zoom_screen
	lea.l	144*144/2(a0),a0
	move.l	a0,zoom_screen2
	lea.l	Wall_handles,a0		; Set wall pointers
	lea.l	Wall_ptrs,a1
	move.w	Nr_of_walls,d7
	bra.s	.Entry1	
.Loop1:	move.b	(a0)+,d0
	jsr	Claim_pointer
	move.l	d0,(a1)+
.Entry1:	dbra	d7,.Loop1
	move.b	Labdata_handle,d0		; Set LAB-data pointer
	jsr	Claim_pointer
	move.l	d0,Labdata_ptr
; ---------- Draw & display dungeon ---------------
	jsr	Calculate_camera_height
	move.w	#-1,cls_top		; Set defaults
	move.w	#144,cls_bottom
	move.b	Floor_ceiling_status,d7	; Any floor or ceiling ?
	beq	.Draw
	move.w	Player_X,d0		; Set coordinates
	andi.w	#512-1,d0
	move.w	d0,Floor_X
	move.w	Player_Y,d0
	neg.w	d0
	andi.w	#512-1,d0
	move.w	d0,Floor_Z
	Get	MPB_buffer_handle,MPB_ptr	; Get pointer
	Free	MPB_buffer_handle
	btst	#0,d7			; Floor ?
	beq.s	.No_floor
	Get	Floor_buffer_handle,Floor_source_gfx
	Free	Floor_buffer_handle
	jsr	Draw_floor
.No_floor:	btst	#1,d7			; Ceiling ?
	beq.s	.Draw
	Get	Ceiling_buffer_handle,Floor_source_gfx
	Free	Ceiling_buffer_handle
	jsr	Draw_ceiling
.Draw:	move.w	cls_top,d0		; How much ceiling ?
	addq.w	#1,d0
	cmp.w	scry,d0
	bpl	.Done_top
	move.w	cls_bottom,d7
	cmp.w	scry,d7
	bls.s	.Top_OK
	move.w	scry,d7
.Top_OK:	sub.w	d0,d7
	bmi	.Done_top
	move.l	MOVEP_ptr,a0		; Erase ceiling
	mulu.w	#144/2,d0
	add.l	d0,a0
	move.l	Sky_colour,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a1
	move.l	d0,a2
	add.w	d7,d7
	subq.w	#1,d7
.Loop2:	movem.l	d0-d6/a1/a2,(a0)
	lea.l	9*4(a0),a0
	dbra	d7,.Loop2
.Done_top:	move.w	scry,d0			; How much floor ?
	move.w	cls_bottom,d7
	sub.w	d0,d7
	bmi	.Done_bottom
	move.l	MOVEP_ptr,a0		; Erase floor
	mulu.w	#144/2,d0
	add.l	d0,a0
	move.l	Floor_colour,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a1
	move.l	d0,a2
	add.w	d7,d7
	subq.w	#1,d7
.Loop3:	movem.l	d0-d6/a1/a2,(a0)
	lea.l	9*4(a0),a0
	dbra	d7,.Loop3
.Done_bottom:
	tst.b	Horizon_flag		; Horizon ?
	beq.s	.No_hor
	jsr	Draw_horizon		; Yes -> Draw
.No_hor:	jsr	Draw_dungeon		; Do IT
	move.w	#Map3D_X,d0		; Show IT
	move.w	#Map3D_Y,d1
	moveq.l	#9,d6
	move.w	#144,d7
	move.l	MOVEP_ptr,a0
	jsr	Show_MOVEP_screen
	moveq.l	#4,d5			; Clear 5th plane
	moveq.l	#72-Horizon_height,d7
	jsr	Clear_1plane_block
	jsr	Draw_stars		; Draw stars
; ---------- Free pointers ------------------------
	Free	Labdata_handle
	Free	MOVEP_handle
	Free	Zoomscreen_handle
	lea.l	Wall_handles,a0
	move.w	Nr_of_walls,d7
	bra.s	.Entry4
.Loop4:	move.b	(a0)+,d0
	jsr	Free_pointer
.Entry4:	dbra	d7,.Loop4
; ---------- Display "OUCH!" when necessary -------
.Done:	LOCAL
	tst.b	Bumped			; Ouch ?
	beq.s	.No_bump
	lea.l	Ouch,a0			; Display OUCH!
	move.w	#Map3D_X+72-16,d0
	move.w	#Map3D_Y+16,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#23,d7
	jsr	Put_masked_block
	sf	Bumped			; Clear flag
.No_bump:	Pop	CA
	subq.b	#1,Anim_count		; Time for an update ?
	beq.s	.Update
	cmp.w	#10,Anim_update		; Not too slow ?
	bmi.s	.Go_on
	bra.s	.Do
.Update:	cmp.w	#5,Anim_update		; Not too fast ?
	bpl.s	.Do
	move.b	#1,Anim_count		; Yes -> try again next time
	bra.s	.Go_on
.Do:	jsr	Update_animation		; Update
	move.b	Anim_speed,Anim_count	; Reset counters
	clr.w	Anim_update
.Go_on:	move.l	Timer,d0			; Update speed
	addq.l	#1,d0			; Current VBL as well !
	cmp.w	#Max_3D_VBLs,d0		; Clip
	bmi.s	.Vbl_Ok
	move.w	#Max_3D_VBLs,d0
.Vbl_Ok:	mulu.w	#25,d0			; Store
	move.w	d0,Dungeon_speed
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Timer for frame-rate-independent movement ]
; All registers are restored
;*****************************************************************************
Time_3D:
	addq.l	#1,Timer			; Count for movement
	addq.w	#1,Anim_update		; Count for animation
	rts

;*****************************************************************************
; [ Try a 3D map move ]
;   IN : d0 - New dungeon X-coordinate of party (.l)
;        d1 - New dungeon Y-coordinate of party (.l)
; All registers are restored
;*****************************************************************************
Try_3D_move:
	movem.l	d0-d2/d6/d7,-(sp)
	sf	Bumped			; Clear flags
	sf	Moved
	jsr	Before_move		; Possible at all ?
	bne	.Exit
	move.l	d0,d6			; Save dungeon coordinates
	move.l	d1,d7
	jsr	Movement_check_3D		; Try
	bne.s	.Block_XY
	move.l	d6,Player_X		; New X & Y are OK
	move.l	d7,Player_Y
	bra.s	.Done
.Block_XY:	move.l	d6,d0			; Try horizontal
	move.l	Player_Y,d1
	jsr	Movement_check_3D
	bne.s	.Block_X
	move.l	d6,Player_X		; New X is OK
	bra.s	.Done
.Block_X:	move.l	Player_X,d0		; Try vertical
	move.l	d7,d1
	jsr	Movement_check_3D
	beq.s	.Y_OK
.Bump:	st	Bumped			; Blocked !
	bra.s	.Exit
.Y_OK:	move.l	d7,Player_Y		; New Y is OK
.Done:	move.l	Player_X,d0		; Get dungeon coordinates
	move.l	Player_Y,d1
	swap	d0			; Calculate map coordinates
	swap	d1
	jsr	Dungeon_to_map
	cmp.w	Map_Xcoord,d0		; Any change ?
	bne.s	.Change
	cmp.w	Map_Ycoord,d1
	beq.s	.Exit
.Change:	move.w	d0,Map_Xcoord		; Store new coordinates
	move.w	d1,Map_Ycoord
	jsr	Update_automap		; Update
	jsr	After_move
.Exit:	movem.l	(sp)+,d0-d2/d6/d7
	rts

;*****************************************************************************
; [ Check if movement is possible (3D map) ]
;   IN : d0 - New dungeon X-coordinate of party (.l)
;        d1 - New dungeon Y-coordinate of party (.l)
;  OUT : eq - Move possible
;        ne - Move impossible
; All registers are restored
;*****************************************************************************
Movement_check_3D:
	movem.l	d0-d7/a0-a5,-(sp)
	st	Collision			; Default
	move.l	d0,d6			; Save dungeon coordinates
	move.l	d1,d7
	swap	d0			; Calculate map coordinates
	swap	d1
	moveq.l	#psize_log,d3
	lsr.w	d3,d0
	lsr.w	d3,d1
	addq.w	#1,d0
	sub.w	Height_of_map,d1
	neg.w	d1
	move.w	d0,d4			; Save map coordinates
	move.w	d1,d5
	Get	Mapdata_handle,a0		; Get pointer to map &
	lea.l	Map_data(a0),a0		;  labyrinth data
	Get	Labdata_handle,a1
	lea.l	Wall_data_offsets,a2
	move.l	a0,a4
	move.l	a1,a5
; ---------- Check out-of-map collision -----------
	tst.w	d0			; X too low ?
	ble	.Exit
	cmp.w	Width_of_map,d0		; X too high ?
	bgt	.Exit
	tst	d1			; Y too low ?
	ble	.Exit
	cmp.w	Height_of_map,d1		; Y too high ?
	bgt	.Exit
; ---------- Check cheat mode ---------------------
	cmpi.w	#Super_chicken,Travel_mode	; Cheat mode ?
	bne.s	.Normal
	sf	Collision			; No collision
	bra	.Exit
; ---------- Check if target square is blocked ----
.Normal:	subq.w	#1,d0			; Calculate map pointer
	add.w	d0,d0
	add.w	d0,a0
	subq.w	#1,d1
	mulu.w	Width_of_map,d1
	add.l	d1,d1
	add.l	d1,a0
	moveq.l	#0,d0			; Get map byte
	move.b	(a0),d0
	move.w	d0,Current_map_byte
	beq.s	.Free			; Anything ?
	cmp.b	#-1,d0			; Dummy wall ?
	beq	.Exit
	cmp.b	#First_wall,d0		; Wall or object ?
	bcs.s	.Free
	subi.w	#First_wall,d0		; Get wall status bits
	lsl.w	#2,d0
	add.l	0(a2,d0.w),a1
	move.l	Wall_bits(a1),d0
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne	.Exit
	btst.l	#Blocked_foot_bit,d0	; Way possible for current
	beq	.Exit			;  travel mode ?
; ---------- Build edge bit-list ------------------
.Free:	lea.l	Collision_table,a3		; Build bit-list
	moveq.l	#0,d2
	moveq.l	#0,d3
.Loop1:	tst.w	(a3)			; Centre ?
	beq.s	.Next1			; Yes -> skip
	move.b	(a3),d0			; No -> get vector
	move.b	1(a3),d1
	ext.w	d0
	ext.w	d1
	add.w	d4,d0			; Get real coordinates
	add.w	d5,d1
	move.l	a4,a0			; Calculate map pointer
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,a0
	subq.w	#1,d1
	mulu.w	Width_of_map,d1
	add.l	d1,d1
	add.l	d1,a0
	moveq.l	#0,d0			; Get map byte
	move.b	(a0),d0
	beq.s	.Next1			; Anything ?
	cmp.b	#-1,d0			; Dummy wall ?
	beq.s	.Blocked
	cmp.b	#First_wall,d0		; Wall or object ?
	bcs.s	.Next1
	subi.w	#First_wall,d0		; Get wall status bits
	lsl.w	#2,d0
	move.l	a5,a1
	add.l	0(a2,d0.w),a1
	move.l	Wall_bits(a1),d0
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Blocked
	btst.l	#Blocked_foot_bit,d0	; Way possible for current
	bne.s	.Next1			;  travel mode ?
.Blocked:	or.w	2(a3),d3			; Blocked !
.Next1:	addq.l	#4,a3			; Next edge
	addq.w	#1,d2
	cmp.w	#9,d2
	bmi.s	.Loop1
; ---------- Determine the edge area --------------
	move.l	d6,d0			; Get coordinates within
	move.l	d7,d1			;  dungeon square
	swap	d0
	swap	d1
	andi.w	#patt_size-1,d0
	andi.w	#patt_size-1,d1
	moveq.l	#0,d2			; Default
	cmp.w	#Dungeon_edge,d0		; Left ?
	bmi.s	.Check_Y
	cmp.w	#patt_size-Dungeon_edge,d0	; Right ?
	bpl.s	.Right
	moveq.l	#1,d2			; Middle !
	bra.s	.Check_Y
.Right:	moveq.l	#2,d2			; Right !
.Check_Y:	cmp.w	#patt_size-Dungeon_edge,d1	; Top ?
	bpl.s	.Done
	cmp.w	#Dungeon_edge,d1		; Bottom ?
	bmi.s	.Bottom
	addq.w	#1*3,d2			; Middle !
	bra.s	.Done
.Bottom:	addq.w	#2*3,d2			; Bottom !
.Done:	btst	d2,d3			; Blocked ?
	sne	Collision
	bne	.Exit
; ---------- Check collision with objects ---------
	move.w	Current_map_byte,d0		; Get current map byte
	beq	.No_obj			; Anything ?
	cmp.w	#First_wall,d0		; Wall or object ?
	bpl	.No_obj
	movem.l	d6/d7,-(sp)
	swap	d6			; Get dungeon coordinates
	swap	d7			;  within map square
	andi.w	#patt_size-1,d6
	andi.w	#patt_size-1,d7
	subq.w	#1,d0			; Get object group data
	mulu.w	#Objectgroup3D_data_size,d0
	lea.l	Lab_data+4(a5,d0.w),a0
	moveq.l	#Objects_per_group-1,d3	; Do each object in group
.Loop2:	move.w	Object_nr(a0),d0		; Anything there ?
	beq.s	.Next2
	move.l	a5,a1			; Get object data
	adda.l	Object_data_offset,a1
	subq.w	#1,d0
	mulu.w	#Object3D_data_size,d0
	add.l	d0,a1
	move.l	Object_bits(a1),d0		; Get object bits
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Try1
	btst.l	#Blocked_foot_bit,d0	; Way possible for current
	bne.s	.Next2			;  travel mode ?
.Try1:	move.w	Object_X(a0),d0		; Get object coordinates
	move.w	Object_Y(a0),d1
	move.w	Object_dungeon_width(a1),d2	; Get top-left corner
	lsr.w	#1,d2
	sub.w	d2,d0
	sub.w	d2,d1
	cmp.w	d0,d6			; Below/right of top-left ?
	bmi.s	.Next2
	cmp.w	d1,d7
	bmi.s	.Next2
	move.w	Object_dungeon_width(a1),d2	; Get bottom-right corner
	add.w	d2,d0
	add.w	d2,d1
	cmp.w	d0,d6			; Above/left of bottom-right ?
	bpl.s	.Next2
	cmp.w	d1,d7
	bpl.s	.Next2
	st	Collision			; Collision !
	movem.l	(sp)+,d6/d7
	bra	.Exit
.Next2:	addq.w	#Objectingroup_data_size,a0	; Next object in
	dbra	d3,.Loop2				;  group
	movem.l	(sp)+,d6/d7
; ---------- Check for NPC's ----------------------
.No_obj:	lea.l	VNPC_data,a0		; Check NPC's
	move.l	CD_value,d2
	moveq.l	#0,d3
.Loop3:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq.s	.Next3
	btst	d3,d2			; Deleted	?
	bne.s	.Next3
	cmp.w	VMap_X(a0),d4		; Right coordinates	?
	bne.s	.Next3
	cmp.w	VMap_Y(a0),d5
	bne.s	.Next3
	btst	#NPC_blocks,VFlags(a0)	; Blocks ?
	bne.s	.Found
	bra	.Exit
.Next3:	lea.l	VNPC_data_size(a0),a0	; Next NPC
	addq.w	#1,d3
	cmpi.w	#Max_chars,d3
	bmi.s	.Loop3
	bra	.Exit
; ---------- Check NPC collision ------------------
.Found:	movem.l	d6/d7,-(sp)
	swap	d6			; Get dungeon coordinates
	swap	d7			;  within map square
	andi.w	#patt_size-1,d6
	andi.w	#patt_size-1,d7
	move.w	NPC_icon_nr(a0),d0		; Get object group data
	subq.w	#1,d0
	mulu.w	#Objectgroup3D_data_size,d0
	lea.l	Lab_data+4(a5,d0.w),a0
	moveq.l	#Objects_per_group-1,d3	; Do each object in group
.Loop4:	move.w	Object_nr(a0),d0		; Anything there ?
	beq.s	.Next4
	move.l	a5,a1			; Get object data
	adda.l	Object_data_offset,a1
	subq.w	#1,d0
	mulu.w	#Object3D_data_size,d0
	add.l	d0,a1
	move.l	Object_bits(a1),d0		; Get object bits
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne	.Try2
	btst.l	#Blocked_foot_bit,d0	; Way possible for current
	bne	.Next4			;  travel mode ?
.Try2:	move.w	Object_X(a0),d0		; Get object coordinates
	move.w	Object_Y(a0),d1
	move.w	Object_dungeon_width(a1),d2	; Get top-left corner
	lsr.w	#2,d2
	add.w	d2,d0
	add.w	d2,d1
	cmp.w	d0,d6			; Below/right of top-left ?
	bmi.s	.Next4
	cmp.w	d1,d7
	bmi.s	.Next4
	move.w	Object_dungeon_width(a1),d2	; Get bottom-right corner
	lsr.w	#1,d2
	add.w	d2,d0
	add.w	d2,d1
	cmp.w	d0,d6			; Above/left of bottom-right ?
	bpl.s	.Next4
	cmp.w	d1,d7
	bpl.s	.Next4
	st	Collision			; Collision !
	movem.l	(sp)+,d6/d7
	bra	.Exit
.Next4:	addq.w	#Objectingroup_data_size,a0	; Next object in
	dbra	d3,.Loop4				;  group
	movem.l	(sp)+,d6/d7
; ---------- Exit & test collision ----------------
.Exit:	Free	Labdata_handle
	Free	Mapdata_handle
	tst.b	Collision			; Get zero flag
	movem.l	(sp)+,d0-d7/a0-a5
	rts

;*****************************************************************************
; [ 3D map - Move forward ]
; All registers are restored
;*****************************************************************************
Forward_3D:
	movem.l	d0-d3,-(sp)
	jsr	Get_3D_direction		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	sub.l	d0,d2
	add.l	d1,d3
	move.l	d2,d0
	move.l	d3,d1
	jsr	Try_3D_move		; Try
	movem.l	(sp)+,d0-d3
	rts

;*****************************************************************************
; [ 3D map - Move backward ]
; All registers are restored
;*****************************************************************************
Backward_3D:
	movem.l	d0-d3,-(sp)
	jsr	Get_3D_direction		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	asr.l	#1,d0
	asr.l	#1,d1
	add.l	d0,d2
	sub.l	d1,d3
	move.l	d2,d0
	move.l	d3,d1
	jsr	Try_3D_move		; Try
	movem.l	(sp)+,d0-d3
	rts

;*****************************************************************************
; [ 3D map - Move left ]
; All registers are restored
;*****************************************************************************
Left_3D:
	movem.l	d0-d3,-(sp)
	jsr	Get_3D_direction		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	asr.l	#1,d0
	asr.l	#1,d1
	sub.l	d1,d2
	sub.l	d0,d3
	move.l	d2,d0
	move.l	d3,d1
	jsr	Try_3D_move		; Try
	movem.l	(sp)+,d0-d3
	rts

;*****************************************************************************
; [ 3D map - Move right ]
; All registers are restored
;*****************************************************************************
Right_3D:
	movem.l	d0-d3,-(sp)
	jsr	Get_3D_direction		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	asr.l	#1,d0
	asr.l	#1,d1
	add.l	d1,d2
	add.l	d0,d3
	move.l	d2,d0
	move.l	d3,d1
	jsr	Try_3D_move		; Try
	movem.l	(sp)+,d0-d3
	rts

;*****************************************************************************
; [ 3D map - Turn left ]
; All registers are restored
;*****************************************************************************
Turnleft_3D:
	movem.l	d0/d1,-(sp)
	move.w	Dungeon_speed,d0		; Increase angle by speed
	ext.l	d0
	moveq.l	#13,d1
	lsl.l	d1,d0
	add.l	d0,Y_angle
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ 3D map - Turn right ]
; All registers are restored
;*****************************************************************************
Turnright_3D:
	movem.l	d0/d1,-(sp)
	move.w	Dungeon_speed,d0		; Decrease angle by speed
	ext.l	d0
	moveq.l	#13,d1
	lsl.l	d1,d0
	sub.l	d0,Y_angle
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ 3D map - 180 degrees left ]
; All registers are restored
;*****************************************************************************
Left180_3D:
	move.l	d7,-(sp)
	jsr	Update_screen
	moveq.l	#Fullturn_steps-1,d7
.Loop:	add.l	#slang*32768/Fullturn_steps,Y_angle	; Rotate
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	dbra	d7,.Loop
	jsr	Copy_screen
	move.l	(sp)+,d7
	rts

;*****************************************************************************
; [ 3D map - 180 degrees right ]
; All registers are restored
;*****************************************************************************
Right180_3D:
	move.l	d7,-(sp)
	jsr	Update_screen
	moveq.l	#Fullturn_steps-1,d7
.Loop:	sub.l	#slang*32768/Fullturn_steps,Y_angle	; Rotate
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	dbra	d7,.Loop
	jsr	Copy_screen
	move.l	(sp)+,d7
	rts

;*****************************************************************************
; [ 3D map - 90 degrees left ]
; All registers are restored
;*****************************************************************************
Left90_3D:
	move.l	d7,-(sp)
	jsr	Update_screen
	moveq.l	#Fullturn_steps/2-1,d7
.Loop:	add.l	#slang*32768/Fullturn_steps,Y_angle	; Rotate
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	dbra	d7,.Loop
	jsr	Copy_screen
	move.l	(sp)+,d7
	rts

;*****************************************************************************
; [ 3D map - 90 degrees right ]
; All registers are restored
;*****************************************************************************
Right90_3D:
	move.l	d7,-(sp)
	jsr	Update_screen
	moveq.l	#Fullturn_steps/2-1,d7
.Loop:	sub.l	#slang*32768/Fullturn_steps,Y_angle	; Rotate
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	dbra	d7,.Loop
	jsr	Copy_screen
	move.l	(sp)+,d7
	rts

;*****************************************************************************
; [ Get direction vector from current angle ]
;  OUT : d0 - Vector X-component (.l)
;        d1 - Vector Y-component (.l)
; Changed registers : d0,d1
;*****************************************************************************
Get_3D_direction:
	move.l	a0,-(sp)
	lea.l	Sinus_table,a0
	move.w	Y_angle,d1
	andi.w	#slang-1,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d0		; Sine
	addi.w	#slang/2,d1
	andi.w	#slang*2-1,d1
	move.w	0(a0,d1.w),d1		; Cosine
	muls.w	Dungeon_speed,d0
	muls.w	Dungeon_speed,d1
	asl.l	#2,d0			; 16 bit nachkomma !
	asl.l	#2,d1
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Relocate zoom buffer ]
;   IN : d0 - Size of memory block (.l)
;        a0 - Source address (.l)
;        a1 - Target address (.l)
; All registers are	restored
;*****************************************************************************
Relocate_zoom_buffer:
	movem.l	d0/d7/a2,-(sp)
	jsr	Copy_memory		; Copy
	move.l	a1,d0			; Calculate difference
	sub.l	a0,d0
	lea.l	zoom_ptrbuff,a2		; Adjust pointer table
	move.w	#Max_zoom-1,d7
.Loop:	add.l	d0,(a2)+
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d7/a2
	rts

;*****************************************************************************
; [ Initialize zooming table (using Bresenham) ]
;   IN : a0 - Pointer to zoom buffer (.l)
; All registers are restored
;*****************************************************************************
Init_zoom_table:
	movem.l	d0-d7/a0/a1,-(sp)
	lea	zoom_ptrbuff,a1
	move.w	#1,d7			; start-size
.Loop1:	move.l	a0,(a1)+			; save pointer
;--- init parameter ---
	move.w	#80-1,d0			; height of wall
	ext.l	d0
	divs	d7,d0
	move.w	d0,d4			; -> add always
	mulu.w	#16*4,d4			; -> add always
	swap.w	d0			; -> kdelta
	move.w	d7,d1			; -> gdelta
;--- calc it ---
	move.w	d1,d2			; -> gdelta2
	addq.w	#1,d0
;	lsr.w	#1,d2
	move.w	d7,d6
	subq.w	#1,d6
.Loop2:	move.w	d4,d5			; add always
	sub.w	d0,d2			; gdelta2-kdelta
	bpl.s	.bresen
	add.w	d1,d2			; gdelta2+gdelta
	addi.w	#16*4,d5			; x'step
.bresen:	move.w	d5,(a0)+			; save step's
	dbra	d6,.Loop2
	addq.w	#1,d7			; Next
	cmp.w	#Max_zoom,d7
	ble.s	.Loop1
	movem.l	(sp)+,d0-d7/a0/a1
	rts

;*****************************************************************************
; [ Draw dungeon in MOVEP-screen ]
; No registers are restored
;*****************************************************************************
Draw_dungeon:
	clr.w	dface_anz			; Reset counters
	clr.w	dobj_anz
	move.w	#0,cx1			; Reset clipping variables
	move.w	#0,cy1
	move.w	#143,cx2
	move.w	#143,cy2
	jsr	Get_draw_size		; Get view rectangle
	movem.w	d0-d3,dminx
	jsr	Rotate_points		; Create point grid
	jsr	Insert_NPCs		; Insert NPCs
	jsr	Get_faces			; Create faces
	lea	wall_list0,a0		; Sort faces
	moveq.l	#8,d6
	move.w	dface_anz,d7
	cmp.w	#1,d7			; Any ?
	ble.s	.No
	jsr	Quicksort
.No:	jsr	Draw_faces		; Draw faces
	rts

;*****************************************************************************
; [ Insert NPC objects ]
; No registers are restored
;*****************************************************************************
Insert_NPCs:
	movem.l	d0-d7/a0-a3/a6,-(sp)
	move.l	Labdata_ptr,a1		; Labyrinth data
	lea.l	VNPC_data,a2		; Extended NPC data
	lea.l	wall_list0,a3		; Addresses & distances
	lea.l	wall_list2,a6		; Object definitions
	move.l	CD_value,d2
	moveq.l	#0,d3
.Loop1:	tst.b	NPC_char_nr(a2)		; Anyone there ?
	beq	.Next1
	btst	d3,d2			; Deleted	?
	bne	.Next1
	move.w	NPC_icon_nr(a2),d0		; Get object group number
	subq.w	#1,d0			; Get object group data
	mulu.w	#Objectgroup3D_data_size,d0
	lea.l	Lab_data+4(a1,d0.w),a0
	move.b	NPC_status_bits(a2),d0	; What kind of NPC ?
	andi.b	#$03,d0
	cmp.b	#Object_type,d0		; An object ?
	bne.s	.No
	st	.Animate			; Yes -> Animate always
	bra.s	.Skip
.No:	btst	#Movement_ended,VFlags(a2)	; No -> Moving ?
	seq	.Animate
.Skip:	move.w	VSource_X(a2),d5		; Get coordinates
	move.w	VSource_Y(a2),d6
	tst.w	d5			; Visible ?
	bne.s	.Do
	tst.w	d6
	beq	.Next1
.Do:	subi.w	#patt_size/2,d5		; Correction
	subi.w	#patt_size/2,d6
	movem.l	d2/d3,-(sp)
	moveq.l	#Objects_per_group-1,d7	; Do each object in group
.Loop2:	move.w	Object_nr(a0),d4		; Anything there ?
	beq	.Next2
	move.w	Object_X(a0),d0		; Get coordinates in map
	move.w	Object_Z(a0),d1		;  square
	move.w	Object_Y(a0),d2
	add.w	d5,d0			; Translate to dungeon
	add.w	d6,d2
	move.w	dminx,d3			; Check minimum X
	subi.w	#patt_size,d3
	cmp.w	d3,d0
	blt	.Next2
	move.w	dminx+2,d3		; Check minimum Y
	subi.w	#patt_size,d3
	cmp.w	d3,d2
	blt	.Next2
	move.w	dminx+4,d3		; Check maximum X
	addi.w	#patt_size,d3
	cmp.w	d3,d0
	bgt.s	.Next2
	move.w	dminx+6,d3		; Check maximum Y
	addi.w	#patt_size,d3
	cmp.w	d3,d2
	bgt.s	.Next2
	sub.w	Player_X,d0		; Adapt coordinates
	sub.w	head_height,d1		;  to camera position
	subi.w	#wall_height,d1
	sub.w	Player_Y,d2
	move.w	Y_angle,d3		; Rotate
	jsr	rotate_y1
	tst.w	d2			; Behind camera ?
	bmi.s	.Next2			; Yes -> exit !
	move.l	d2,(a3)+			; Save data in sort list
	move.l	a6,(a3)+
	addq.w	#1,dobj_anz		; Count up !!!
	move.w	#$abed,(a6)+		; Save object data
	move.w	d0,(a6)+
	move.w	d1,(a6)+
	move.w	d2,(a6)+
	move.w	d4,(a6)+
	move.b	#1,(a6)+			; Is NPC object
	move.b	.Animate,(a6)+		; Animation flag
	cmp	#Max_visible_objects,dobj_anz	; Too much objects ?
	bmi.s	.Next2
	movem.l	(sp)+,d2/d3		; Yes -> Break
	bra.s	.Exit
.Next2:	addq.w	#Objectingroup_data_size,a0	; Next object in
	dbra	d7,.Loop2				;  group
	movem.l	(sp)+,d2/d3
.Next1:	lea.l	VNPC_data_size(a2),a2	; Next NPC
	addq.w	#1,d3
	cmpi.w	#Max_chars,d3
	bmi	.Loop1
.Exit:	movem.l	(sp)+,d0-d7/a0-a3/a6
	rts

.Animate:	dc.b 0
	even

;*****************************************************************************
; [ Get view rectangle ]
;  OUT : d0-d3 - View rectangle (.w)
; No registers are restored
;*****************************************************************************
Get_draw_size:
;--- sin und cos holen ---
	lea	Sinus_table,a0
	move	Y_angle,d1
	andi.w	#slang-1,d1
	add	d1,d1
	move.w	(a0,d1.w),d0		; sin(yw)
	addi.w	#slang/2,d1
	andi.w	#slang*2-1,d1
	move.w	(a0,d1.w),d1		; cos(yw)
;--- vorderen punkte erzeugen ---
	lea	view_points,a0
	move	d0,d2
	move	d1,d3
	muls	#144/2,d2			; sin(yw)*x (mulu vorlaeufig)
	muls	#144/2,d3			; cos(yw)*x (144 -> breite des screens)
	asl.l	#2,d2
	swap	d2
	asl.l	#2,d3
	swap	d3
	move	d0,d4
	move	d1,d5
	muls	#proj_faktor,d4		; sin(yw)*zp
	muls	#proj_faktor,d5		; cos(yw)*zp
	asl.l	#2,d4
	swap	d4
	asl.l	#2,d5
	swap	d5
	neg.w	d5			; -cos(yw)*zp
;-- punkt #1
	neg.w	d2
	move	d3,(a0)+			; cos(yw)*x
	move	d2,(a0)+			; -sin(yw)*x
;-- punkt #2
	move	d3,d6
	move	d2,d7
	sub	d4,d6			; deltax
	sub	d5,d7			; deltay
	muls	#patt_size/20,d6		; pattsize-abhaengig
	muls	#patt_size/20,d7
	add	d4,d6
	add	d5,d7
	move	d6,(a0)+
	move	d7,(a0)+
;-- punkt #3
	neg.w	d2
	neg.w	d3
	move	d3,(a0)+			; -cos(yw)*x
	move	d2,(a0)+			; sin(yw)*x
;-- punkt #4
	move	d3,d6
	move	d2,d7
	sub	d4,d6			; deltax
	sub	d5,d7			; deltay
	muls	#patt_size/20,d6		; pattsize-abhaengig
	muls	#patt_size/20,d7		; pattsize-abhaengig
	add	d4,d6
	add	d5,d7
	move	d6,(a0)+
	move	d7,(a0)+
;--- minx,miny,maxx,maxy suchen ---
	lea	view_points,a0
	move	#$7fff,d0			; minx
	move	#$7fff,d1			; miny
	moveq	#0,d2			; maxx
	moveq	#0,d3			; maxy
	moveq	#4-1,d7
.gv_loop:	movem.w	(a0)+,d4-d5
;-- minx
	cmp	d4,d0
	ble.s	.new0
	move	d4,d0
;-- miny
.new0:	cmp	d5,d1
	ble.s	.new1
	move	d5,d1
;-- maxx
.new1:	cmp	d4,d2
	bge.s	.new2
	move	d4,d2
;-- maxy
.new2:	cmp	d5,d3
	bge.s	.new3
	move	d5,d3
.new3:	dbra	d7,.gv_loop
	addi.w	#patt_size-1,d2		; runden
	addi.w	#patt_size-1,d3
	add	Player_X,d0		; minx
	add	Player_Y,d1		; miny
	add	Player_X,d2		; maxx
	add	Player_Y,d3		; maxy
;--- bereich clippen ---
	tst	d0
	bpl.s	.clip1
	moveq	#0,d0
.clip1:	tst	d1
	bpl.s	.clip2
	moveq	#0,d1
.clip2:	cmp	dsizex2,d2
	ble.s	.clip3
	move	dsizex2,d2
.clip3:	cmp	dsizey2,d3
	ble.s	.clip4
	move	dsizey2,d3
.clip4:	rts

;*****************************************************************************
; [ Rotate points of view rectangle ]
;   IN : d0-d3 - View rectangle (.w)
; No registers are restored
;*****************************************************************************
Rotate_points:
	andi.w	#-patt_size,d0
	andi.w	#-patt_size,d1
	andi.w	#-patt_size,d2		; ?
	andi.w	#-patt_size,d3		; ?
	move	d0,d4			; minx -> startx
	move	d1,d5			; miny -> starty
	sub	d0,d2
	sub	d1,d3
	moveq	#psize_log,d6
	lsr	d6,d2
	lsr	d6,d3
;	addq	#1,d2			; einschliesslich !!
;	addq	#1,d3
	move	d2,drawsizex
	move	d3,drawsizey
	lsr	d6,d4
	lsr	d6,d5
	move	d4,drawstartx
	move	d5,drawstarty
	sub	Player_X,d0
	sub	Player_Y,d1
;d0-d1 -> relative start-koo im dungeon
;d2-d3 -> anzahl punkte
;--- punkte-array fuellen ---
	move	d3,d6
	move	d2,d7
	addq	#1,d6
	addq	#1,d7
	mulu	d6,d7			; anzahl punkte
	lea	rot_points,a2
.yloop:	move	d0,d4
	move	d2,d6			; zaehler
.xloop:	move	d4,(a2)+
	move	d1,(a2)+
	addi.w	#patt_size,d4
	dbra	d6,.xloop
	addi.w	#patt_size,d1
	dbra	d3,.yloop
;--- punkte-array rotieren ---
	lea	rot_points,a0
	move.l	a0,a1
	clr.w	xoffset
	clr.w	zoffset
	move	d7,-(sp)
	jsr	rotate_y
	move	(sp)+,d7
;--- punkte-array projezieren ---
	lea	rot_points,a0
	lea	proj_points,a1
	subq	#1,d7
.proj_loop:
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	bmi	.aga
	ext.l	d0
	asl.l	#proj_log,d0		; x*zp
	addi.w	#proj_faktor,d1		; z+zp
	beq.s	.aga
	divs	d1,d0
.aga:	add	scrx,d0
	move.w	d0,(a1)+
	clr.l	(a1)+
	clr.w	(a1)+
	dbra	d7,.proj_loop
	rts

;*****************************************************************************
; [ Get visible dungeon faces ]
; No registers are restored
;*****************************************************************************
Get_faces:
	Get	Mapdata_handle,a0
	lea.l	Map_data(a0),a0
; ---------- Do trick for non-blocking walls ------
	move.l	a0,-(sp)
	move.w	Map_Xcoord,d0		; Get byte at player's
	subq.w	#1,d0			;  position
	add.w	d0,d0
	add.w	d0,a0
	move.w	Map_Ycoord,d0
	subq.w	#1,d0
	mulu.w	dsizex,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq.l	#0,d0			; Get
	move.b	(a0),d0
	move.b	d0,Saved_map_byte		; Save
	move.l	a0,Saved_map_ptr
	cmp.w	#First_wall,d0		; Is it a wall ?
	bmi.s	.Done
	clr.b	(a0)			; Trick
.Done:	move.l	(sp)+,a0
; ---------- Do -----------------------------------
	cmp	#Max_visible_objects,dobj_anz	; Too much objects already ?
	bpl	.Exit
	move.w	drawstartx,d0		; Get map address
	add.w	d0,d0
	add.w	d0,a0
	move.w	drawstarty,d0
	neg.w	d0
	add.w	dsizey,d0
	subq.w	#1,d0
	mulu.w	dsizex,d0
	add.l	d0,d0
	add.l	d0,a0
	lea.l	proj_points,a1
	lea.l	rot_points,a2
	lea.l	wall_list0,a3		; Addresses & distances
	move.w	dobj_anz,d0		;  (skip NPC objects)
	lsl.w	#3,d0
	add.w	d0,a3
	lea.l	wall_list1,a4		; Wall definitions
	lea.l	Wall_transparencies,a5	; Transparency flags
	lea.l	wall_list2,a6		; Object definitions
	move.w	dobj_anz,d0		;  (skip NPC objects)
	mulu.w	#12,d0			; !!!
	add.w	d0,a6
	move.w	drawstarty,d0		; Set yoghurt coordinate
	addq.w	#1,d0
	move.w	d0,Yoghurt_Y
	move	drawsizey,d6
	subq	#1,d6
.Loop1:	move	d6,-(sp)
	move.w	drawstartx,d0
	addq.w	#1,d0
	move.w	d0,Yoghurt_X
	move	drawsizex,d7
	subq	#1,d7
.Loop2:	move	d7,-(sp)
	moveq	#0,d0			; Get byte from map
	move.b	(a0),d0
	beq	.Next2
	cmp.b	#-1,d0			; Dummy wall ?
	beq	.Next2
	jsr	Convert_map_byte		; Convert map byte
	cmp.b	#First_wall,d0		; Wall or object ?
	bcs	.Next2
;-> alle 4 mauern checken !
;--- oben ---
	move	dsizex,d1			;  16
	add.w	d1,d1			;   4
	neg.w	d1			;   4
	moveq.l	#0,d0			;   4
	move.b	0(a0,d1.w),d0		;  14
	cmp.b	#-1,d0
	beq	.blocko
	subi.w	#First_wall,d0		;   8
	bcs.s	.do_o			;   8/10 (9)
	tst.b	0(a5,d0.w)		;  14
	beq	.blocko			;   8/10 (10)
					;  83
;--- 2d-koos laden ---
.do_o:	move	drawsizex,d7
	addq	#1,d7
	asl	#3,d7
	move	8(a1,d7.w),d0		; x1
	move	(a1,d7.w),d1		; x2
;-- 3d-koos laden (hi = x , lo = y)
	asr	#1,d7			; 3d-koos holen
	move.l	4(a2,d7.w),d6
	move.l	(a2,d7.w),d7
	tst.w	d6
	bpl.s	.ok3d1
	tst.w	d7
	bmi	.blocko
.ok3d1:
;-- sichtbar ?
	cmp	d0,d1
	ble	.blocko			; -> hidden
	cmp	cx1,d1
	blt	.blocko			; links ausserhalb
	cmp	cx2,d0
	bgt	.blocko			; rechts ausserhalb
;-- sichtbar !
	move.l	a4,4(a3)			; adresse speichern
	addq	#1,dface_anz
	move.w	#$face,(a4)+		; flag fuer wand
	move.w	color,(a4)+		; farbe
	move.l	d6,(a4)+			; 3d-koos speichern
	move.l	d7,(a4)+
	move	d0,(a4)+			; x1
	move	d1,(a4)+			; x2
	add	d7,d6
	asr	#1,d6
	ext.l	d6
	move.l	d6,(a3)			; entfernung speichern
	addq.l	#8,a3
	bra	.blocku			; gegenueberliegende flaeche ueberspringen
.blocko:
;--- unten ---
	move	dsizex,d1
	add.w	d1,d1
	moveq.l	#0,d0
	move.b	0(a0,d1.w),d0
	cmp.b	#-1,d0
	beq	.blocku
	subi.w	#First_wall,d0
	bcs.s	.do_u
	tst.b	0(a5,d0.w)
	beq	.blocku
;--- 2d-koos laden ---
.do_u:	move	(a1),d0			; x1
	move	8(a1),d1			; x2
;-- 3d-koos laden
	move.l	(a2),d6
	move.l	4(a2),d7
	tst.w	d6
	bpl.s	.ok3d2
	tst.w	d7
	bmi	.blocku
.ok3d2:
;-- sichtbar ?
	cmp	d0,d1
	ble	.blocku			; -> hidden
	cmp	cx1,d1
	blt	.blocku			; links ausserhalb
	cmp	cx2,d0
	bgt	.blocku			; rechts ausserhalb
;-- sichtbar !
	move.l	a4,4(a3)			; adresse speichern
	addq	#1,dface_anz
	move.w	#$face,(a4)+		; flag fuer wand
	move.w	color,(a4)+		; farbe
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	move	d0,(a4)+			; x1
	move	d1,(a4)+			; x2
	add	d7,d6
	asr	#1,d6
	ext.l	d6
	move.l	d6,(a3)			; entfernung speichern
	addq.l	#8,a3
.blocku:
;--- links ---
	moveq.l	#0,d0
	move.b	-2(a0),d0
	cmp.b	#-1,d0
	beq	.blockl
	subi.w	#First_wall,d0
	bcs.s	.do_l
	tst.b	0(a5,d0.w)
	beq	.blockl
;--- 2d-koos laden ---
.do_l:	move	drawsizex,d7
	addq	#1,d7
	asl	#3,d7
	move	(a1,d7.w),d0		; x1
	move	(a1),d1	; x2
;-- 3d-koos laden
	asr	#1,d7			; 3d-koos holen
	move.l	(a2,d7.w),d6
	move.l	(a2),d7
	tst.w	d6
	bpl.s	.ok3d3
	tst.w	d7
	bmi	.blockl
.ok3d3:
;-- sichtbar ?
	cmp	d0,d1
	ble	.blockl			; -> hidden
	cmp	cx1,d1
	blt	.blockl			; links ausserhalb
	cmp	cx2,d0
	bgt	.blockl			; rechts ausserhalb
;-- sichtbar !
	move.l	a4,4(a3)			; adresse speichern
	addq	#1,dface_anz
	move.w	#$face,(a4)+		; flag fuer wand
	move.w	color,(a4)+		; farbe
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	move	d0,(a4)+			; x1
	move	d1,(a4)+			; x2
	add	d7,d6
	asr	#1,d6
	ext.l	d6
	move.l	d6,(a3)			; entfernung speichern
	addq.l	#8,a3
	bra	.blockr			; gegenueberliegende flaeche ueberspringen
.blockl:
;--- rechts ---
	moveq.l	#0,d0
	move.b	2(a0),d0
	cmp.b	#-1,d0
	beq	.blockr
	subi.w	#First_wall,d0
	bcs.s	.do_r
	tst.b	0(a5,d0.w)
	beq	.blockr
;--- 2d-koos laden ---
.do_r:	move	drawsizex,d7
	addq	#1,d7
	asl	#3,d7
	move	8(a1),d0		; x1
	move	8(a1,d7.w),d1	; x2
;-- 3d-koos laden
	asr	#1,d7			; 3d-koos holen
	move.l	4(a2),d6
	move.l	4(a2,d7.w),d7
	tst.w	d6
	bpl.s	.ok3d4
	tst.w	d7
	bmi	.blockr
.ok3d4:
;-- sichtbar ?
	cmp	d0,d1
	ble	.blockr			; -> hidden
	cmp	cx1,d1
	blt	.blockr			; links ausserhalb
	cmp	cx2,d0
	bgt	.blockr			; rechts ausserhalb
;-- sichtbar !
	move.l	a4,4(a3)			; adresse speichern
	addq	#1,dface_anz
	move.w	#$face,(a4)+		; flag fuer wand
	move.w	color,(a4)+		; farbe
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	move	d0,(a4)+			; x1
	move	d1,(a4)+			; x2
	add	d7,d6
	asr	#1,d6
	ext.l	d6
	move.l	d6,(a3)			; entfernung speichern
	addq.l	#8,a3
.blockr:
.Next2:	move	(sp)+,d7
	cmp	#Max_visible_walls,dface_anz	; Too much faces ?
	bmi.s	.No1
	move.w	(sp)+,d6			; Yes -> break
	bra.s	.Exit
.No1:	cmp	#Max_visible_objects,dobj_anz	; Too much objects ?
	bmi.s	.No2
	move.w	(sp)+,d6			; Yes -> break
	bra.s	.Exit
.No2:	addq.w	#1,Yoghurt_X		; Next X
	addq.l	#8,a1
	addq.l	#4,a2
	addq.l	#2,a0
	dbra	d7,.Loop2
	addq.w	#1,Yoghurt_Y		; Next Y
	addq.l	#8,a1
	addq.l	#4,a2
	move.w	drawsizex,d0
	add.w	dsizex,d0
	add.w	d0,d0
	sub.w	d0,a0
	move.w	(sp)+,d6
	dbra	d6,.Loop1
.Exit:	move.w	dobj_anz,d0		; Add
	add.w	d0,dface_anz
	Free	Mapdata_handle
; ---------- Reverse trick ------------------------
	move.l	Saved_map_ptr,a0		; Reset
	move.b	Saved_map_byte,(a0)
	rts

;*****************************************************************************
; [ Quicksort ]
;   IN : d6 - Length of entry (.w)
;        d7 - Number of values (.l)
;        a0 - Pointer to table (.l)
; No registers are restored
; Note :
;  - Quick-sort is not actually executed.
;  - The order of elements with the same value may not be changed !
;*****************************************************************************
Quicksort:
	move.l	a0,a1
	move	d7,d0
	subq	#1,d0
	mulu	d6,d0
	add.w	d0,a1			;-> letzter eintrag

	move	d6,d4
;	mulu	#9,d4			; ab 9 werte
	mulu	d7,d4			; immer bubblesort
; d4.l = differenz ab der bubble-sort aktiv wird

quicksort_call:
	cmp.l	a0,a1
	ble	quicksort_leave
	move.l	a1,d0
	sub.l	a0,d0
	cmp.l	d4,d0
	ble	qs_bubbleit
	move.l	a0,a2
	move.l	a1,a3
	move.l	(a0),d7
	add.l	(a1),d7
	move.l	d7,d5
	addq.l	#1,d5
	lsr.l	#1,d5
	lsr.l	#1,d7			; -> mittelwert
quicksort_loop0:
quicksort_loop1:
	cmp.l	(a0),d5
	ble.s	qs_get1
	add.l	d6,a0
	bra.s	quicksort_loop1
qs_get1:
quicksort_loop2:
	cmp.l	(a1),d7
	bge.s	qs_get2
	sub.l	d6,a1
	bra.s	quicksort_loop2
qs_get2:
	cmp.l	a1,a0
	bge	quicksort_part
;--- vertauschen ---
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	move.l	4(a0),d0
	move.l	4(a1),4(a0)
	move.l	d0,4(a1)
	add.l	d6,a0
	sub.l	d6,a1
	cmp.l	a0,a1
	bgt.s	quicksort_loop0
quicksort_part:
;--- rekursionen durchfuehren ---
;a2 - a1
	movem.l a0-a3,-(sp)
	move.l	a2,a0
	jsr	quicksort_call
	movem.l (sp)+,a0-a3
;a0 - a3
;	movem.l a0-a3,-(sp)
;	move.l	a1,a0
	move.l	a3,a1
	jsr	quicksort_call
;	movem.l (sp)+,a0-a3
quicksort_leave:
	rts
 
;(einfuege-sort)
;*******************
;*** bubble-sort ***
;*******************
qs_bubbleit:
;a0 = start
;a1 = ende (inc.)
	move.l	a0,a2
qsb_loop0:
;*** 2 zahlen suchen die falsch sind ***
qsb_loop1:
	move.l	(a0),d0
	add.l	d6,a0
	cmp.l	(a0),d0
	bgt.s	qsb_toobig
	cmp.l	a0,a1
	bne.s	qsb_loop1
	bra	qsb_ready
qsb_toobig:
	move.l	(a0),d0
	move.l	4(a0),d1
	move.l	a0,a3
;*** solange zurueckgehen bis kleinere zahl gefunden ***
qsb_loop2:
	sub.l	d6,a0
	cmp.l	a2,a0
	blt.s	qsb_next
	move.l	(a0),(a0,d6.l)
	move.l	4(a0),4(a0,d6.l)
	cmp.l	(a0),d0
	blt.s	qsb_loop2	
qsb_next:
	move.l	d0,(a0,d6.l)
	move.l	d1,4(a0,d6.l)
	move.l	a3,a0
	cmp.l	a0,a1
	bne.s	qsb_loop0
qsb_ready:
	rts

;*****************************************************************************
; [ Draw dungeon faces ]
; No registers are restored
;*****************************************************************************
Draw_faces:
;****** clipping setzen ******
	move	#0,cx1
	move	#0,cy1
	move	#143,cx2
	move	#143,cy2

	lea	wall_list0,a0
	lea	wall_cliptab,a4
	move	#-1,clip_tab		; tabelle leer
	move	dface_anz,d7
	beq	dd_nowalls
;****** PASS 1,NUR CLIPPING CHECKEN ******
	subq	#1,d7
gdfaces_loop:
	movem.l	d7/a0,-(sp)
	move.l	4(a0),a0
	cmp.w	#$face,(a0)
	beq	.do_face
;--- objekt checken ---
	movem.w	2(a0),d0-d4		; !!!
	jsr	make_3dzoom0
	bra	.no_face
;--- wand checken ---
.do_face:	tst.b	2(a0)			; durchsichtig ?
	beq	.normal			; -> flaeche nicht durchsichtig !
	lea	12(a0),a0
	move	(a0),d0			; xlinks
	move	2(a0),d4			; xrechts
	jsr	check_vfclip
	move	d2,(a4)+
	move	d3,(a4)+
	bra.s	.no_face
.normal:	lea	12(a0),a0			; diese infos ueberspringen
	jsr	check_vface
	tst	d7
	bmi.s	.out
	move.w	cx1,(a4)+
	move.w	cx2,(a4)+
	bra.s	.no_face
.out:	move.l	#-1,(a4)+
.no_face:	movem.l	(sp)+,d7/a0
	addq.l	#8,a0
	cmp.l	#end_of_wallcliptab,a4	; Buffer overflow ?
	bmi.s	.Ok
	XX	$ff0
	sub.w	d7,dface_anz		; Yes -> correction
	bra.s	.Continue
.Ok:	dbra	d7,gdfaces_loop
;****** PASS 2, JETZT ZEICHNEN ******
.Continue:	move.l	a0,a1
	move	dface_anz,d7
	beq	dd_nowalls
	subq	#1,d7
ddfaces_loop:
	subq.l	#8,a1
	move.l	4(a1),a0			; -> adresse der def
	move.w	(a0)+,d0			; flag
	cmp	#$face,d0
	beq	.draw_dface
	cmp	#$abed,d0
	bne	.skip
;*** objekt zeichnen ***
	movem.l	d7/a1,-(sp)		; Used to be a1 !!!
	jsr	make_3dzoom2
	movem.l	(sp)+,d7/a1
	bra	.skip
;*** wand zeichnen ***
.draw_dface:
	move.w	-(a4),d1
	move.w	-(a4),d0
	bmi	.skip			; -> flaeche draussen
	move.w	d0,cx1			; clipping setzen
	move.w	d1,cx2	
	movem.l	d7/a1/a4,-(sp)
	move.w	(a0)+,color
	lea	dpoly_koos3d,a1
	movem.w	(a0)+,d0-d3
	move.w	d0,(a1)+			; x1_3d
	move.w	d2,(a1)+			; x2_3d

	move.w	#-wall_height,d4
	sub	head_height,d4
	move	d4,(a1)+			; y1_3d
	move.w	#wall_height,d4
	sub	head_height,d4
	move.w	d4,(a1)+			; y2_3d

	move.w	d1,(a1)+			; z1_3d
	move.w	d3,(a1)+			; z2_3d

	move.w	color,d0			; Get wall address
	jsr	Get_wall_address

	jsr	put_dpoly
	movem.l	(sp)+,d7/a1/a4
.skip:	dbra	d7,ddfaces_loop
dd_nowalls:
	rts

;*****************************************************************************
; [ Rotate around Y-axis ]
;   IN : d7 - Number of coordinates (.w)
;        a0 - Pointer to input coordinate list (.l)
;        a1 - Pointer to output coordinate list (.l)
; No registers are restored
;*****************************************************************************
rotate_y:
	subq	#1,d7
	bmi	.Exit
	lea	Sinus_table,a2
	and	#slang-1,Y_angle
	move	Y_angle,d6
	neg.w	d6
	addi.w	#slang,d6
	andi.w	#slang-1,d6
	add	d6,d6
	move.w	(a2,d6.w),d0		;sin(yw)
	addi.w	#slang/2,d6
	andi.w	#slang*2-1,d6
	move.w	(a2,d6.w),d1		;cos(yw)
	move.w	xoffset,a2
	move.w	zoffset,a3
.Loop:	move.w	(a0)+,d2			;x
	move.w	(a0)+,d3			;y
	move	d2,d4
	move	d3,d5
	muls	d0,d2			; x*sin(yw)
	muls	d0,d3			; y*sin(yw)
	muls	d1,d4			; x*cos(yw)
	muls	d1,d5			; y*cos(yw)
	sub.l	d3,d4
	add.l	d2,d5
	asl.l	#2,d4
	asl.l	#2,d5
	swap	d4
	swap	d5
	add.w	a2,d4			; +xoffset
	add.w	a3,d5			; +zoffset
	move.w	d4,(a1)+
	move.w	d5,(a1)+
	dbra	d7,.Loop
.Exit:	rts

;*****************************************************************************
; [ Rotate single point around Y-axis ]
;   IN : d0-d2 - 3D coordinates (.w)
;        d3 - Angle (.w)
;  OUT : d0-d2 - Rotated 3D coordinates (.w)
; Changed registers : d0-d2
;*****************************************************************************
rotate_y1:
	movem.l	d3-d6/a2,-(sp)
	lea	Sinus_table,a2
	move	d3,d6
	neg.w	d6
	addi.w	#slang,d6
	andi.w	#slang-1,d6
	add	d6,d6
	move.w	(a2,d6.w),d3		; sin(yw)
	addi.w	#slang/2,d6
	andi.w	#slang*2-1,d6
	move.w	(a2,d6.w),d4		; cos(yw)
	move	d0,d5
	move	d2,d6
	muls	d3,d5			; x*sin(yw)
	muls	d3,d6			; y*sin(yw)
	muls	d4,d0			; x*cos(yw)
	muls	d4,d2			; y*cos(yw)
	sub.l	d6,d0
	add.l	d5,d2
	asl.l	#2,d0
	asl.l	#2,d2
	swap	d0
	swap	d2
	ext.l	d0
	ext.l	d1
	ext.l	d2
	movem.l	(sp)+,d3-d6/a2
	rts

;*****************************************************************************
; [ Draw zoom object ]
; No registers are restored
;*****************************************************************************
make_3dzoom2:
	move.w	-(a4),cx1
	bmi.s	.Exit
	move.w	-(a4),cx2
	move.l	-(a4),a0			; Graphics address
	move.w	-(a4),d7			; New height
	move.w	-(a4),d6			; New width
	move.w	-(a4),d5			; Source height
	move.w	-(a4),d4			; Source width
	move.w	-(a4),d1			; Y-position
	move.w	-(a4),d0			; X-position
	tst.w	d6			; Too small ?
	beq.s	.Exit
	tst.w	d7
	beq.s	.Exit
	moveq	#-1,d2			; Mask
	move.l	a4,-(sp)			; Draw zoom object
	jsr	draw_zoomshape
	move.l	(sp)+,a4
.Exit:	rts

;*****************************************************************************
; [ Check overlaps ]
;   IN : a0 - Pointer to coordinates (.w)
; No registers are restored
;*****************************************************************************
check_vface:
	move	(a0),d0			; x1
	move	2(a0),d1			; x2
	subq	#1,d0			; nachfolgende flaeche soll
	addq	#1,d1			; nur angrenzen, nicht 1
					; pixel ueberlappen
;--- grob clippen
	tst	d0
	bpl.s	.ok0
	moveq	#0,d0
.ok0:
	cmp	#143,d1
	ble.s	.ok1
	move	#143,d1
.ok1:
;--
	lea	clip_tab,a1
	sub.l	a2,a2
	sub.l	a3,a3
vcheck_loop:
	move.w	(a1)+,d2			; vx1
	bmi	vschulz
	move.w	(a1)+,d3			; vx2
;--- x1 innerhalb ? ---
	cmp	d2,d0
	blt	.out1
	cmp	d3,d0
	bgt	.out1
;-> x1 ist innerhalb dieser flaeche
	lea	-4(a1),a2
.out1:
;--- x2 innerhalb ? ---
	cmp	d2,d1
	blt	.out2
	cmp	d3,d1
	bgt	.out2
;-> x2 ist innerhalb dieser flaeche
	lea	-4(a1),a3
.out2:
	bra.s	vcheck_loop
vschulz:
;******************************
	move.l	a2,d2
	move.l	a3,d3
	cmp.l	d2,d3
	beq	.insame

	tst.l	d2
	beq	.first_out
	tst.l	d3
	beq	.second_out
;*** diese 2 flaechen zusammenhaengen ***
	move	2(a2),cx1
	move	(a3),cx2
	move.w	(a2),(a3)
.move_loop:
	move.l	(a3)+,(a2)+		; flaeche ausfuegen
	bpl.s	.move_loop
	moveq	#0,d7
	rts
;*** erster punkt ausserhalb ***
.first_out:
	move	#0,cx1
	move	(a3),cx2
	move	d0,(a3)			; an x1 des naechsten anhaengen
	moveq	#0,d7
	rts
;*** zweiter punkt ausserhalb ***
.second_out:
	move	#143,cx2
	move	2(a2),cx1
	move	d1,2(a2)			; an x1 des naechsten anhaengen
	moveq	#0,d7
	rts

;*** beide punkte ausserhalb oder in gleicher flaeche ***
.insame:
	tst.l	d2
	bne	v_out			; -> beide punkte in der gleichen flaeche
;*** flaeche hat nirgends geschnitten ***
	move	#0,cx1			; also normal clippen
	move	#143,cx2
;--- einsortieren ---
	lea	clip_tab,a1
.is_loop:
	tst.w	(a1)			; ende erreicht ?
	bmi.s	.begin			; -> ja !
	cmp.w	(a1),d1
	blt.s	.begin
	beq.s	.replace
	addq.l	#4,a1
	bra.s	.is_loop
.replace:
	move	d0,(a1)+
	move	d1,(a1)+
	bra.s	.quit
.begin:
	move.l	(a1),d2
	move.w	d0,(a1)+
	move.w	d1,(a1)+
.iloop:
	move.l	(a1),d3
	move.l	d2,(a1)+
	bmi.s	.quit
	move.l	d3,d2
	bra.s	.iloop
.quit:
	moveq	#0,d7
	rts
;*** flaeche ganz ausserhalb ***
v_out:
	moveq	#-1,d7
	rts

;*****************************************************************************
; [ Check object clipping ]
;   IN : d0 - Left X-coordinate (.w)
;        d1 - Right X-coordinate (.w)
; Changed registers : d2,d3,d4
;*****************************************************************************
check_vfclip:
	move.l	a5,-(sp)
;--- clipping checken ---
	movem.w	d0/d6/d7,-(sp)
;-- grob clippen
	tst	d4
	bmi.s	.mega_out
	cmp	#143,d0
	bgt.s	.mega_out
	tst	d0
	bpl.s	.cok1
	moveq	#0,d0
.cok1:	cmp	#143,d4
	ble.s	.cok2
	move	#143,d4
.cok2:	lea	clip_tab,a5
	move	#0,d2			; default-clipping
	move	#143,d3
.clip_loop:
	move.w	(a5)+,d6			; clip_links
	bmi.s	.clipped			; -> ende der tabelle
	move.w	(a5)+,d7			; clip_rechts
;xlinks drin ?
	cmp	d6,d0
	blt.s	.not_first		; -> x1 links von clip
	cmp	d7,d0
	bgt.s	.clip_loop		; -> aber rechts davon
	move	d7,d2			; x1 also im clip
	cmp	d7,d4
	bgt.s	.clip_loop		; -> x2 nicht im clip
.mega_out:	moveq	#-1,d2			; -> beide im clip !
	moveq	#-1,d3			; also wech damit !
	bra.s	.clipped
;xrechts drin ?
.not_first:
	cmp	d6,d4
	blt.s	.clip_loop		; beide links davon
	move	d6,d3			; rechts geclipt !
.clipped:	movem.w	(sp)+,d0/d6/d7
	move.l	(sp)+,a5
	rts

;*****************************************************************************
; [ Convert map byte ]
;   IN : d0 - Byte from map (.b)
;        a3 - Pointer to {wall_list0} (.l)
;        a5 - Pointer to wall transparency list (.l)
;        a6 - Pointer to {wall_list2} (.l)
; Changed registers : a3,a6
; Notes :
;  - This routine assumes d0 is not zero.
;*****************************************************************************
Convert_map_byte:
	move.l	d0,-(sp)
	andi.w	#$00ff,d0			; Wall or object ?
	cmp.w	#First_wall,d0
	bmi	.Object
	subi.w	#First_wall,d0		; Wall !
	cmp.w	Nr_of_walls,d0		; Legal ?
	bpl	.Exit
	tst.b	0(a5,d0.w)		; Transparent ?
	sne	color
	move.b	d0,color+1		; Set wall number
	bra	.Exit
.Object:	cmp.w	Nr_of_groups,d0		; Legal ?
	bgt	.Exit
	movem.l	d1-d7/a0,-(sp)
	move.l	Labdata_ptr,a0		; Get object group data
	subq.w	#1,d0
	mulu.w	#Objectgroup3D_data_size,d0
	lea.l	Lab_data+4(a0,d0.w),a0
	move.w	Yoghurt_X,d5		; Get map square coordinates
	move.w	Yoghurt_Y,d6
	move.w	d6,d0			; Make hash number
	mulu.w	Width_of_map,d0		; FIX: Was "mulu.w Map_width,d0" which read
					;  absolute address 4 instead of the map width (#127)
	add.w	d5,d0
	move.b	d0,.Hash_nr
	moveq.l	#psize_log,d0		; Convert to dungeon coordinates
	subq.w	#1,d5
	subq.w	#1,d6
	lsl.w	d0,d5
	lsl.w	d0,d6
	moveq.l	#Objects_per_group-1,d7	; Do each object in group
.Loop:	move.w	Object_nr(a0),d4		; Anything there ?
	beq.s	.Next
	move.w	Object_X(a0),d0		; Get coordinates in map
	move.w	Object_Z(a0),d1		;  square
	move.w	Object_Y(a0),d2
	add.w	d5,d0			; Translate to dungeon
	add.w	d6,d2
	sub.w	Player_X,d0		; Adapt coordinates
	sub.w	head_height,d1		;  to camera position
	subi.w	#wall_height,d1
	sub.w	Player_Y,d2
	move.w	Y_angle,d3		; Rotate
	jsr	rotate_y1
	tst.w	d2			; Behind camera ?
	bmi.s	.Next			; Yes -> exit !
	move.l	d2,(a3)+			; Save data in sort list
	move.l	a6,(a3)+
	addq.w	#1,dobj_anz		; Count up !!!
	move.w	#$abed,(a6)+		; Save object data
	move.w	d0,(a6)+
	move.w	d1,(a6)+
	move.w	d2,(a6)+
	move.w	d4,(a6)+
	clr.b	(a6)+			; Is normal object
	add.w	d1,d0			; Hash number
	add.w	d2,d0
	add.b	.Hash_nr,d0
	move.b	d0,(a6)+
	cmp	#Max_visible_objects,dobj_anz	; Too much objects ?
	bpl.s	.Done
.Next:	addq.w	#Objectingroup_data_size,a0	; Next object in
	dbra	d7,.Loop				;  group
.Done:	movem.l	(sp)+,d1-d7/a0
.Exit:	move.l	(sp)+,d0
	rts

.Hash_nr:	dc.b 0
	even

;*****************************************************************************
; [ Convert {color}-variable to wall address ]
;   IN : d0 - {Color}-variable (.w)
;  OUT : a0 - Wall address (.l)
; Changed registers : d0,a0
; Note :
;  - {color} contains {seethru_flag} in the high byte and the memory handle
;     in the low byte.
;  - Three-dimensional shading can be inserted here. Choose the right wall
;    depending on 3D coordinates.
;*****************************************************************************
Get_wall_address:
	cmp.w	#256,d0			; Transparent ?
	shi	seethru_flag
	lea.l	Wall_ptrs,a0		; Get wall address
	andi.w	#$00ff,d0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),a0
	rts

;*****************************************************************************
; [ Handle 3D zoom object ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Z-coordinate (.w)
;        d3 - Object number (.w)
;        d4 - Extra value (.w)
;        a4 - Pointer to {wall_cliptab} (.l)
; No registers are restored
;*****************************************************************************
make_3dzoom0:
	subq.w	#1,d3
	cmp.w	Nr_of_objects,d3		; Legal ?
	bmi.s	.Ok1
	moveq.l	#-1,d2			; Exit
	bra	.Done
.Ok1:	move.w	d3,d5			; Save
	move.l	Labdata_ptr,a0		; Get object data
	adda.l	Object_data_offset,a0
	mulu.w	#Object3D_data_size,d3
	add.l	d3,a0
	lea.l	Object_handles,a1		; Get graphics address
	move.b	0(a1,d5.w),d5
	Get	d5,a1
	Free	d5
	move.l	Object_bits(a0),d6		; Get status bits
	moveq.l	#0,d3			; Default frame
	moveq.l	#0,d5			; Get number of frames
	move.b	Object_nr_frames(a0),d5
	cmp.w	#1,d5			; Any animation ?
	beq.s	.No_anim
	cmp.w	#256,d4			; Is NPC ?
	bmi.s	.Normal
	tst.b	d4			; Animate ?
	bne.s	.Anim
	moveq.l	#1,d3			; No -> Take second frame
	bra.s	.No_anim
.Anim:	bclr	#Random_anim_bit,d6		; To fool those suckers
.Normal:	lea.l	Circle_anim-4,a2		; Circle or wave ?
	btst	#Circle_wave_bit,d6
	beq.s	.Circle
	lea.l	Wave_anim-4,a2		; Wave
.Circle:	lsl.w	#2,d5			; Add number of frames
	adda.w	d5,a2
	btst	#Random_anim_bit,d6		; Random animation ?
	beq.s	.No_random
	moveq.l	#0,d5			; Yes -> Random hash
	move.b	1(a2),d5
	add.w	d5,d4
	andi.w	#$000f,d4
	move.w	2(a2),d5			; Test
	btst	d4,d5
	beq.s	.No_anim
.No_random:
	add.b	(a2),d3			; Get current frame
.No_anim:	moveq.l	#0,d4			; Get width & height
	move.b	Object_width(a0),d4
	moveq.l	#0,d5
	move.b	Object_height(a0),d5
	move.w	d4,-(sp)			; Save
	move.w	d5,-(sp)
	andi.w	#$fff0,d4			; Calculate size of one block
	lsr.w	#1,d4
	mulu.w	d5,d4
	mulu.w	d4,d3			; Calculate frame address
	adda.l	d3,a1
;	move.w	(sp),d5			; Do it
;	move.w	2(sp),d4
	ext.l	d0
	ext.l	d1
	move	d2,d5
	addi.w	#proj_faktor,d5		; z+zp
	asl.l	#proj_log,d0		; x*zp
	asl.l	#proj_log,d1		; y*zp
	move.l	d1,d4
	divs	d5,d0
	divs	d5,d1
	neg.w	d1
	add.w	scrx,d0			; -> screen_x
	add.w	scry,d1			; -> screen_y
;d2 = z
;d4 = y*zp
	btst	#Distort_bit,d6		; verzerr_flag
	beq	.normal_3dzoom
;****** ysize perspektivisch erzeugen ******
	moveq.l	#0,d6
	move.w	Object_dungeon_width(a0),d6
	moveq.l	#0,d7
	move.w	Object_dungeon_height(a0),d7
;-- xsize
	asl.l	#proj_log,d6		; xs*zp
	divs	d5,d6			; -> xsize
;-- ysize
	asr	#1,d7

; REGISTER CONTENTS :
;  d0 - Screen X
;  d1 - Screen Y
;  d2 - Z
;  d4 - Y x Zp
;  d5 - Projection factor (Z + Zp)
;  d6 - Projected width
;  d7 - Height in dungeon / 2

	add	d7,d2			; -> z1
	addi.w	#proj_faktor,d2		; z1+zp
	bne.s	.Ok2
	moveq.l	#-1,d2			; Exit
	bra	.Done
.Ok2:	divs	d2,d4
;  d4 = y2
	move	d4,d7
	neg	d7
	add	scry,d7
	sub	d1,d7			; ysize / 2
	bpl.s	.ysok
	neg.w	d7
.ysok:
;x zentrieren
	move	d6,d2
	lsr	#1,d2
	sub	d2,d0
;y zentrieren
	sub	d7,d1			; ytop = midy-ysize/2
	add	d7,d7			; real ysize

	cmp.w	#2,d7			; Never less than 2
	bpl.s	.Not_too_small
	moveq.l	#2,d7
.Not_too_small:
	bra	.do_zoomclip
;****** einfach nur 3d-zooming ******
.normal_3dzoom:
	moveq.l	#0,d6
	move.w	Object_dungeon_width(a0),d6
	moveq.l	#0,d7
	move.w	Object_dungeon_height(a0),d7
	asl.l	#proj_log,d6		; xs*zp
	asl.l	#proj_log,d7		; ys*zp
	divs	d5,d6			; -> xsize
	divs	d5,d7			; -> ysize
	sub	d7,d1			; hotspot nach unten
	move	d6,d2
	lsr	#1,d2
	sub	d2,d0			; mitte
.do_zoomclip:
	move	d0,d4
	add	d6,d4
	jsr	check_vfclip
;--- speichern ---
.Done:	move	(sp)+,d5
	move	(sp)+,d4
.Done2:	tst.w	d2
	bmi.s	.skip
	move.w	d0,(a4)+			; x
	move.w	d1,(a4)+			; y
	move.w	d4,(a4)+			; old_sizex
	move.w	d5,(a4)+			; old_sizey
	move.w	d6,(a4)+			; xsize
	move.w	d7,(a4)+			; ysize
	move.l	a1,(a4)+			; source_gfx
	move.w	d3,(a4)+			; clip_rechts
.skip:	move.w	d2,(a4)+			; clip_links
.Exit:	rts

;*****************************************************************************
; [ Put unmasked block on 3D wall (MOVEP - format) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in pixels (.w)
;        d7 - Height in pixels (.w)
;        a0 - Source graphics (.l)
;        a1 - Destination graphics (.l)
; All registers are restored
;*****************************************************************************
Put_unmasked_MOVEP_block:
	movem.l	d0/d1/d5-d7/a0-a2,-(sp)
	mulu.w	#Wall_width/2,d1		; Calculate position in wall
	add.w	d1,a1
	andi.w	#$fff8,d0
	lsr.w	#1,d0
	add.w	d0,a1
	lsr.w	#3,d6			; Calculate counters
	subq.w	#1,d6
	subq.w	#1,d7
.Loop1:	move.l	a1,a2
	move.w	d6,d5
.Loop2:	move.l	(a0)+,(a2)+
	dbra	d5,.Loop2			; Next half-trunc
	lea.l	Wall_width/2(a1),a1		; Next line
	dbra	d7,.Loop1
	movem.l	(sp)+,d0/d1/d5-d7/a0-a2
	rts

;*****************************************************************************
; [ Put masked block on 3D wall (MOVEP - format) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in pixels (.w)
;        d7 - Height in pixels (.w)
;        a0 - Source graphics (.l)
;        a1 - Destination graphics (.l)
; All registers are restored
;*****************************************************************************
Put_masked_MOVEP_block:
	movem.l	d0/d1/d5-d7/a0-a2,-(sp)
	mulu.w	#Wall_width/2,d1		; Calculate position in wall
	add.w	d1,a1
	andi.w	#$fff8,d0
	lsr.w	#1,d0
	add.w	d0,a1
	lsr.w	#3,d6			; Calculate counters
	subq.w	#1,d6
	subq.w	#1,d7
.Loop1:	move.l	a1,a2
	move.w	d6,d5
.Loop2:	move.l	(a0),d1			; Load 8 pixels
	move.l	d1,d0			; Calculate mask
	ror.l	#8,d1
	or.l	d1,d0
	ror.l	#8,d1
	or.l	d1,d0
	ror.l	#8,d1
	or.l	d1,d0
	not.l	d0
	and.l	(a2),d0			; Mask 8 pixels
	or.l	(a0)+,d0
	move.l	d0,(a2)+
	dbra	d5,.Loop2			; Next half-trunc
	lea.l	Wall_width/2(a1),a1		; Next line
	dbra	d7,.Loop1
	movem.l	(sp)+,d0/d1/d5-d7/a0-a2
	rts

;*****************************************************************************
; [ Convert map coordinates to dungeon coordinates ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : d0 - Dungeon X-coordinate (.w)
;        d1 - Dungeon Y-coordinate (.w)
; Changed registers : d0,d1
; Notes :
;  - The dungeon coordinates are given for the centre of the map square.
;*****************************************************************************
Map_to_dungeon:
	move.l	d2,-(sp)
	tst.w	d0			; Both zero ?
	bne.s	.Notzero
	tst.w	d1
	beq.s	.Exit
.Notzero:	subq.w	#1,d0			; Move to base 0
	sub.w	Height_of_map,d1		; Vertical flip
	neg.w	d1
	moveq.l	#psize_log,d2		; Scale up
	lsl.w	d2,d0
	lsl.w	d2,d1
	addi.w	#patt_size/2,d0		; Move to centre
	addi.w	#patt_size/2,d1
.Exit:	move.l	(sp)+,d2
	rts

;*****************************************************************************
; [ Convert dungeon coordinates to map coordinates ]
;   IN : d0 - Dungeon X-coordinate (.w)
;        d1 - Dungeon Y-coordinate (.w)
;  OUT : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
; Changed registers : d0,d1
;*****************************************************************************
Dungeon_to_map:
	move.l	d2,-(sp)
	moveq.l	#psize_log,d2		; Scale down
	lsr.w	d2,d0
	lsr.w	d2,d1
	addq.w	#1,d0			; Move to base 1
	sub.w	Height_of_map,d1		; Vertical flip
	neg.w	d1
	move.l	(sp)+,d2
	rts

;*****************************************************************************
; [ Convert floor/ceiling graphics ]
;   IN : a0 - Pointer to graphics (.l)
;        a1 - Pointer to byte buffer (.l)
; All registers are restored
; Notes :
;   64*64 -> 256*256 (zooms times 4 !!)
;*****************************************************************************
Convert_floor_graphics:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	#64-1,d7
.Loop1:	moveq.l	#64/16-1,d6
.Loop2:	move.w	(a0)+,d0			; Load 4 planes
	move.w	8-2(a0),d1
	move.w	16-2(a0),d2
	move.w	24-2(a0),d3
	rept	16
	moveq.l	#0,d4
	add.w	d3,d3
	addx.w	d4,d4
	add.w	d2,d2
	addx.w	d4,d4
	add.w	d1,d1
	addx.w	d4,d4
	add.w	d0,d0
	addx.w	d4,d4
	lsl.w	#3,d4
	move.l	a1,a2
	moveq.l	#4-1,d5			; Do 4 lines
	move.b	d4,(a2)+			; Save 4 times
	move.b	d4,(a2)+
	move.b	d4,(a2)+
	move.b	d4,(a2)+
	lea.l	256-4(a2),a2
	dbra	d5,*-12
	addq.l	#4,a1
	endr
	dbra	d6,.Loop2
	lea.l	3*8(a0),a0
	lea.l	256*3(a1),a1
	dbra	d7,.Loop1
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Create MPB table for floor/ceiling ]
; All registers are restored
; Notes :
;         fedcba9876543210    fedcba9876543210fedcba9876543210
; Convert x7654xxxx3210xxx to 40--xxxx51--xxxx62--xxxx73--xxxx
;*****************************************************************************
Create_MPB_table:
	movem.l	d0-d2/d6/d7/a0-a3,-(sp)
	opt	o4-				; (not optimized by the original assembler)
	move.l	#65536,d0			; Make MPB buffer
	opt	o4+
	jsr	Allocate_FAST
	move.b	d0,MPB_buffer_handle
	jsr	Claim_pointer		; Fill it
	move.l	d0,a0
	move.l	a0,a1
	add.l	#32768,a1
	lea	.conv_tab,a2
	moveq	#0,d7
.mainloop:	moveq	#0,d0
	move.l	a2,a3
	moveq	#8-1,d6
.bitloop:	move.b	(a3)+,d1
	move.b	(a3)+,d2
	btst	d1,d7		;copy bit from here
	beq.s	.not_set
	bset	d2,d0		;to there !
.not_set:	dbra	d6,.bitloop

	move.l	d0,d1
	lsr.l	#2,d0
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	lsr.l	#2,d0
	move.l	d0,d1
	lsr.l	#2,d0	
	move.l	d0,(a1)+
	move.l	d1,(a1)+

	addq.w	#8,d7		;lowest 3 bit empty !
	cmp	#32768,d7	;end reached ?
	bne.s	.mainloop	;-> NO !

	Free	MPB_buffer_handle
	movem.l	(sp)+,d0-d2/d6/d7/a0-a3
	rts

;where to copy which bit ...
.conv_tab:
	dc.b $3,$1e
	dc.b $4,$16
	dc.b $5,$0e
	dc.b $6,$06
	dc.b $b,$1f
	dc.b $c,$17
	dc.b $d,$0f
	dc.b $e,$07
	even

;*****************************************************************************
; [ Re-evaluate light in 3D dungeon maps ]
; All registers are restored
;*****************************************************************************
Evaluate_D3_light:
	movem.l	d0/d1/a0,-(sp)
	sf	Stygian			; Default
; ---------- Check for cheat mode -----------------
	cmpi.w	#Super_chicken,Travel_mode	; Superchicken mode ?
	bne.s	.No_cheat
	moveq.l	#15,d0			; Yes -> Light!
	bra	.Exit
; ---------- Check if active character is blind ---
.No_cheat:	Get	Active_handle,a0		; Get conditions
	move.w	Body_conditions(a0),d0
	Free	Active_handle
	btst	#Blind,d0			; Blind ?
	beq	.Seeing
	st	Stygian			; Yes -> Darkness
	bra	.Leave
; ---------- Check map status bits ----------------
.Seeing:	Get	Mapdata_handle,a0
	move.w	Map_special(a0),d0
	Free	Mapdata_handle
; ---------- Handle LIGHT maps --------------------
	btst	#Light_bit,d0		; Always light ?
	beq.s	.No_light
	moveq.l	#15,d0			; Yes -> Light
	bra	.Exit
; ---------- Handle CHANGE maps -------------------
.No_light:
	btst	#Change_bit,d0		; Changing light ?
	beq.s	.No_change
	move.w	Hour,d0			; Get time light level
	moveq.l	#0,d1
	move.b	.Time_level(pc,d0.w),d1
	jsr	.Get_light_level		; Get spell effect
	add.w	d1,d0
	bra	.Exit
.Time_level:
	dc.b 0,0,0,0,0,3			;  0 - 5
	dc.b 7,11,15,15,15,15		;  6 - 11
	dc.b 15,15,15,15,15,15		; 12 - 17
	dc.b 11,7,3,0,0,0			; 18 - 23
	even
; ---------- Handle DARK maps ---------------------
.No_change:
	jsr	.Get_light_level		; Get spell effect
; ---------- Store new light level ----------------
.Exit:	cmp.w	#16,d0			; Clip light level
	bmi.s	.No
	moveq.l	#15,d0
.No:	move.w	d0,New_light_level		; Store
	tst.w	Current_light_level		; Dark ?
	bne.s	.Leave
	cmp.b	#Dungeon_3D,Current_map_type	; Dungeon ?
	bne.s	.Leave
	st	Stygian			; Yes !
.Leave:	movem.l	(sp)+,d0/d1/a0
	rts

; [ Get light level from current light spell ]
;  OUT : d0 - Light level {0...15} (.w)
; Changed registers : d0
.Get_light_level:
	move.l	d1,-(sp)
	moveq.l	#0,d0			; Default is zero
	tst.w	Spell_1_duration		; Any light spell active ?
	beq.s	.Exit2
	move.w	Spell_1_data,d1		; Get level
	move.b	.Spell_level-1(pc,d1.w),d0
.Exit2:	move.l	(sp)+,d1
	rts

.Spell_level:
	dc.b 13,14,15
	even

;*****************************************************************************
; [ Re-evaluate sky in 3D city maps ]
; All registers are restored
;*****************************************************************************
Evaluate_C3_light:
	movem.l	d0/d1/a0,-(sp)
; ---------- Check if active character is blind ---
	Get	Active_handle,a0		; Get conditions
	move.w	Body_conditions(a0),d0
	Free	Active_handle
	btst	#Blind,d0			; Blind ?
	sne	Stygian
; ---------- Check map status bits ----------------
	Get	Mapdata_handle,a0
	move.w	Map_special(a0),d0
	Free	Mapdata_handle
; ---------- Handle LIGHT maps --------------------
	btst	#Light_bit,d0		; Always light ?
	beq.s	.No_light
	moveq.l	#32,d0			; Yes
	moveq.l	#32,d1
	bra.s	.Store
; ---------- Handle CHANGE maps -------------------
.No_light:	btst	#Change_bit,d0		; Changing light ?
	beq.s	.No_change
	move.w	Hour,d1			; Yes -> Get sky level
	moveq.l	#0,d0
	move.b	.Time_level(pc,d1.w),d0
	jsr	.Get_light_level		; Get spell effect
	add.w	d0,d1			; Add to light level
	cmp.w	#32,d1			; Clip
	bmi.s	.Store
	moveq.l	#32,d1
	bra.s	.Store
; ---------- Handle DARK maps ---------------------
.No_change:
	jsr	.Get_light_level		; Get spell effect
; ---------- Store new light levels ---------------
.Store:	move.w	d0,New_sky_level		; Store
	move.w	d1,New_light_level
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

.Time_level:
	dc.b 0,0,0,0,0,4			;  0 - 5
	dc.b 12,20,28,32,32,32		;  6 - 11
	dc.b 32,32,32,32,32,28		; 12 - 17
	dc.b 20,12,4,0,0,0			; 18 - 23
	even

; [ Get light level from current light spell ]
;  OUT : d1 - Light level {0...32} (.w)
; Changed registers : d0
.Get_light_level:
	move.l	d0,-(sp)
	moveq.l	#0,d1			; Default is zero
	tst.w	Spell_1_duration		; Any light spell active ?
	beq.s	.Exit2
	move.w	Spell_1_data,d0		; Get level
	move.b	.Spell_level-1(pc,d0.w),d1
.Exit2:	move.l	(sp)+,d0
	rts

.Spell_level:
	dc.b 8,12,16
	even

;*****************************************************************************
; [ Set 3D dungeon palette light level ]
; All registers are restored
;*****************************************************************************
Set_D3_light_level:
	movem.l	d0/d1/d5-d7/a0/a1,-(sp)
	lea.l	Backup_pal,a0
	lea.l	Current_pal,a1
	move.w	Current_light_level,d0	; Get current level
	bne.s	.Not_dark			; See anything ?
	st	Stygian			; No
	bra.s	.Exit
.Not_dark:	cmp.w	#15,d0			; Fade at all ?
	bne.s	.Yes
	moveq.l	#16-1,d7			; No
.Loop1:	move.w	(a0)+,(a1)+
	dbra	d7,.Loop1
	bra.s	.Done
.Yes:	moveq.l	#0,d1			; Fade
	moveq.l	#15-1,d7			; How many steps ?
	sub.w	d0,d7
	moveq.l	#16-1,d6
.Loop2:	move.w	(a0)+,d0			; Load original colour
	move.w	d7,d5			; Fade down x times
.Loop3:	jsr	Fade_colour
	dbra	d5,.Loop3
	move.w	d0,(a1)+			; Store
	dbra	d6,.Loop2			; Next colour
.Done:	jsr	Reset_current_RL		; Reset
.Exit:	movem.l	(sp)+,d0/d1/d5-d7/a0/a1
	rts

;*****************************************************************************
; [ Set 3D city sky colour range & palette level ]
; All registers are restored
;*****************************************************************************
Set_C3_light_level:
	movem.l	d0/d1/d6/d7/a0-a2,-(sp)
; ---------- Fade sky colour range ----------------
	lea.l	Sky_ranges,a0		; Get pointer to ranges
	move.w	Current_world_nr,d0
	mulu.w	#C3_horizon*6,d0
	add.w	d0,a0
	lea.l	Current_sky,a2		; Destination
	move.w	Current_sky_level,d0	; Get current range &
	move.w	d0,d1			;  level
	andi.w	#$000f,d0
	lsr.w	#4,d1
	mulu.w	#C3_horizon*2,d1		; Get ranges
	add.w	d1,a0
	lea.l	C3_horizon*2(a0),a1
	move.w	d0,d6			; Fade
	moveq.l	#C3_horizon,d7
	jsr	Dim_colours
; ---------- Fade palette -------------------------
	lea.l	C3_palettes,a0		; Get pointer to palettes
	move.w	Current_world_nr,d0
	mulu.w	#2*Pal_size,d0
	add.w	d0,a0
	lea.l	Current_pal,a2		; Destination
	move.w	Current_light_level,d0	; Get current range &
	move.w	d0,d1			;  level
	andi.w	#$000f,d0
	lsr.w	#4,d1
	tst.w	d1			; 0 ?
	bne.s	.Not_0
	lea.l	Pal_size(a0),a1
	bra.s	.Do
.Not_0:	cmp.w	#1,d1			; 1 ?
	bne.s	.Not_1
	lea.l	Pal_size(a0),a0
	lea.l	Backup_pal,a1
	bra.s	.Do
.Not_1:	lea.l	Backup_pal,a0
.Do:	move.w	d0,d6			; Fade
	moveq.l	#Pal_size/2,d7
	jsr	Dim_colours
	jsr	Reset_current_RL		; Reset
	movem.l	(sp)+,d0/d1/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Update 3D map light level ]
; All registers are restored
;*****************************************************************************
Update_M3_light_level:
	movem.l	d0/d1,-(sp)
	cmp.b	#City_3D,Current_map_type	; City or dungeon ?
	beq.s	.City
; ---------- Do 3D dungeon light level ------------
	move.w	Current_light_level,d0	; New light level ?
	cmp.w	New_light_level,d0
	beq	.Exit
	bmi.s	.Up1			; Yes -> Up or down ?
	subq.w	#1,d0			; Count down
	bra.s	.Store1
.Up1:	addq.w	#1,d0			; Count up
.Store1:	move.w	d0,Current_light_level	; Set new light level
	jsr	Set_D3_light_level
	bra.s	.Exit
; ---------- Do 3D city light level ---------------
.City:	moveq.l	#0,d1
	move.w	Current_sky_level,d0	; Update sky level
	cmp.w	New_sky_level,d0
	beq	.Done2
	bmi.s	.Up2
	subq.w	#1,d0
	bra.s	.Store2
.Up2:	addq.w	#1,d0
.Store2:	move.w	d0,Current_sky_level	; Store
	addq.w	#1,d1			; Mark
.Done2:	move.w	Current_light_level,d0	; Update light level
	cmp.w	New_light_level,d0
	beq	.Done3
	bmi.s	.Up3
	subq.w	#1,d0
	bra.s	.Store3
.Up3:	addq.w	#1,d0
.Store3:	move.w	d0,Current_light_level	; Store
	addq.w	#1,d1			; Mark
.Done3:	tst.w	d1			; Update ?
	beq.s	.Exit
	jsr	Set_C3_light_level		; Yes
.Exit:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Calculate camera height ]
; All registers are restored
;*****************************************************************************
Calculate_camera_height:
	movem.l	d0-d2/a0,-(sp)
	Get	Labdata_handle,a0		; Get height of wall in cm
	move.w	Wall_in_cm(a0),d0
	Free	Labdata_handle
	subi.w	#15,d0			; - 15 cm
	Get	Active_handle,a0		; Get race of active
	moveq.l	#0,d1			;  character
	move.b	Char_race(a0),d1
	Free	Active_handle
	lea.l	Race_heights,a0		; Get height of race
	add.w	d1,d1
	move.w	0(a0,d1.w),d1		; !!!
	cmp.w	d0,d1			; Too high ?
	bmi.s	.Ok
	move.w	d0,d1
.Ok:	move.w	#wall_height*2+1,d2		; Calculate camera height
	mulu.w	d1,d2
	divu.w	d0,d2
	subi.w	#wall_height,d2
	add.w	FX_camera_height,d2		; Add for effect
	move.w	d2,head_height		; Store
	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Draw horizon in MOVEP-screen ]
; All registers are restored
; Notes :
;   - This routine assumes [ MOVEP_ptr ] has been set.
;*****************************************************************************
Draw_horizon:
	movem.l	d0/d1/a0/a1,-(sp)
	move.w	Y_angle,d0		; Get X-coordinate
	neg.w	d0
	andi.w	#$007f,d0
	mulu.w	#144,d0
	lsr.l	#7,d0
	Get	Horizon_preshift_handle,a0	; Get graphics address
	move.w	d0,d1
	andi.w	#$fff0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	andi.w	#$000f,d0
	mulu.w	#Horizon_height*144,d0
	add.l	d0,a0
	move.l	MOVEP_ptr,a1		; Get MOVEP address
	move.w	scry,d0
	subi.w	#Horizon_height,d0
	mulu.w	#72,d0
	add.l	d0,a1
	jsr	Insert_horizon		; Insert
	Free	Horizon_preshift_handle
	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Draw stars ]
; All registers are restored
;*****************************************************************************
Draw_stars:
	movem.l	d0-d4/d7/a0,-(sp)
	cmp.b	#City_3D,Current_map_type	; City ?
	bne	.Exit
	lea.l	.Star_intensity,a0		; How intense ?
	move.w	Hour,d0
	move.b	0(a0,d0.w),d0
	beq	.Exit			; If at all
	lea.l	.Star_colours-4,a0		; Which colours ?
	lsl.w	#2,d0
	add.w	d0,a0
	move.w	Y_angle,d2		; Get angle
	move.w	Current_world_nr,d3		; Get seed
	lsl.w	#5,d3
	moveq.l	#40-1,d7			; Draw stars
.Loop:	move.w	d2,d0			; Calculate X-coordinate
	add.w	d3,d0
	andi.w	#1023,d0
	cmp.w	#144-1,d0			; In range ?
	bhi.s	.Next
	addi.w	#Map3D_X,d0		; Yes
	move.w	d3,d1			; Calculate Y-coordinate
	andi.w	#$001f,d1
	addi.w	#Map3D_Y+4,d1
	jsr	Get_pixel			; OK to plot here ?
	cmp.w	#C3_raster_colour,d4
	bne.s	.Next
	move.w	d3,d4			; Yes -> Get colour
	andi.w	#$0003,d4
	move.b	0(a0,d4.w),d4
	jsr	Plot_pixel		; Plot
.Next:	move.w	d3,d0			; Next pseudo-random number
	lsl.w	#4,d3
	add.w	d0,d3
	addi.w	#17,d3
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d0-d4/d7/a0
	rts

.Star_intensity:
	dc.b 3,3,3,3,3,2			;  0 - 5
	dc.b 1,0,0,0,0,0			;  6 - 11
	dc.b 0,0,0,0,0,0			; 12 - 17
	dc.b 0,1,2,3,3,3			; 18 - 23
.Star_colours:
	dc.b 28,29,29,30
	dc.b 29,29,30,30
	dc.b 29,30,31,31
	even

;*****************************************************************************
; [ Load 3D floor ]
; All registers are restored
;*****************************************************************************
Load_floor:
	movem.l	d0/d1/d6/a0/a1,-(sp)
	Get	Labdata_handle,a0		; Get floor number
	moveq.l	#0,d0
	move.b	Floor_graphics_nr(a0),d0
	Free	Labdata_handle
	moveq.l	#Floor_file,d1		; Load floor graphics
	jsr	Load_subfile
	move.b	d0,d6
	opt	o4-				; (not optimized by the original assembler)
	move.l	#65536,d0			; Make floor buffer
	opt	o4+
	jsr	Allocate_FAST
	move.b	d0,Floor_buffer_handle
	jsr	Claim_pointer		; Convert graphics
	move.l	d0,a1
	Get	d6,a0
	jsr	Convert_floor_graphics
	Free	Floor_buffer_handle
	move.b	d6,d0			; Remove source graphics
	jsr	Free_pointer
	jsr	Free_memory
	movem.l	(sp)+,d0/d1/d6/a0/a1
	rts

;*****************************************************************************
; [ Load 3D ceiling ]
; All registers are restored
;*****************************************************************************
Load_ceiling:
	movem.l	d0/d1/d6/a0/a1,-(sp)
	Get	Labdata_handle,a0		; Get ceiling number
	moveq.l	#0,d0
	move.b	Ceiling_graphics_nr(a0),d0
	Free	Labdata_handle
	moveq.l	#Floor_file,d1		; Load ceiling graphics
	jsr	Load_subfile
	move.b	d0,d6
	opt	o4-				; (not optimized by the original assembler)
	move.l	#65536,d0			; Make ceiling buffer
	opt	o4+
	jsr	Allocate_FAST
	move.b	d0,Ceiling_buffer_handle
	jsr	Claim_pointer		; Convert graphics
	move.l	d0,a1
	Get	d6,a0
	jsr	Convert_floor_graphics
	Free	Ceiling_buffer_handle
	move.b	d6,d0			; Remove source graphics
	jsr	Free_pointer
	jsr	Free_memory
	movem.l	(sp)+,d0/d1/d6/a0/a1
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Horizon_CA:	dc.w 0,143,0,15
Collision_table:
;   Edge areas : 876543210
	dc.b -1,-1
	dc.w %000000001
	dc.b 0,-1
	dc.w %000000111
	dc.b 1,-1
	dc.w %000000100
	dc.b -1,0
	dc.w %001001001
	dc.b 0,0
	dc.w %111111111
	dc.b 1,0
	dc.w %100100100
	dc.b -1,1
	dc.w %001000000
	dc.b 0,1
	dc.w %111000000
	dc.b 1,1
	dc.w %100000000

scrx:	dc.w 144/2			; Constant value
Alternate_positions:
	dc.w patt_size/2,patt_size/2			; Middle
	dc.w Dungeon_edge,Dungeon_edge		; Top-left
	dc.w patt_size/2,Dungeon_edge		; Top
	dc.w patt_size-Dungeon_edge,Dungeon_edge	; Top-right
	dc.w Dungeon_edge,patt_size/2		; Left
	dc.w patt_size-Dungeon_edge,patt_size/2	; Right
	dc.w Dungeon_edge,patt_size-Dungeon_edge	; Bottom-left
	dc.w patt_size/2,patt_size-Dungeon_edge	; Bottom
	dc.w patt_size-Dungeon_edge,patt_size-Dungeon_edge	; Bottom-right

; *** 3D MAP LAYOUT : 2nd layer ***
Map3D_L2:
	dc.w Map3D_X,Map3D_X+144-1,Map3D_Y,Map3D_Y+144-1	; Map area
	dc.b 2
	even
	dc.l Control_area,0

M3_CIL:	dc.w Cont+Turnleft_3D_cicon,Cont+Forward_3D_cicon,Cont+Turnright_3D_cicon
	dc.w Cont+Left_3D_cicon,Hourglass_cicon,Cont+Right_3D_cicon
	dc.w Turn180_left_cicon,Cont+Back_3D_cicon,Turn180_right_cicon
	dc.l Turnleft_3D,Forward_3D,Turnright_3D
	dc.l Left_3D,Hourglass,Right_3D
	dc.l Left180_3D,Backward_3D,Right180_3D
	dc.l Map_CIL_evaluate
