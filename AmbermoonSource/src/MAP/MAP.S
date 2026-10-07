; General map handling routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 25-6-1992

	SECTION	Program,code
;*****************************************************************************
; [ Initialize map ]
; All registers are	restored
;*****************************************************************************
Init_map:
	movem.l	d0/d1/d7/a0,-(sp)
; ---------- Load map -----------------------------
	move.w	Map_nr,d0
	moveq.l	#Map_data_file,d1
	jsr	Load_subfile
	move.b	d0,Mapdata_handle		; Store handle
; ---------- Determine map type -------------------
	jsr	Claim_pointer		; Get info
	move.l	d0,a0
	move.w	Map_special(a0),d0
	move.b	Map_type(a0),d1
	Free	Mapdata_handle
	cmp.b	#2,d1			; 2D or 3D map ?
	beq.s	.2D
	sf	Show_trans		; 3D
	btst	#City_bit,d0		; 3D city or dungeon ?
	bne.s	.3DCity
	moveq.l	#Dungeon_3D,d0
	bra.s	.Cont
.3DCity:	moveq.l	#City_3D,d0
	bra.s	.Cont
.2D:	btst	#Show_trans_bit,d0		; 2D -> Show transports ?
	sne	Show_trans
	btst	#World_map_bit,d0		; 2D city or world map ?
	bne.s	.2DWild
	moveq.l	#City_2D,d0
	bra.s	.Cont
.2DWild:	moveq.l	#World_2D,d0
.Cont:	move.b	d0,Current_map_type		; Set map	type
	LOCAL
; ---------- Initialize ---------------------------
	sf	Bumped			; Reset flags
	sf	Combat_req
	sf	Big_brother_flag
	clr.w	Current_map_music
	move.w	#-1,Current_NPC		; !
	Get	Mapdata_handle,a0	
	moveq.l	#0,d0			; Store map's width
	move.b	Map_width(a0),d0
	move.w	d0,Width_of_map
	moveq.l	#0,d1			; Store map's height
	move.b	Map_height(a0),d1
	move.w	d1,Height_of_map
	Free	Mapdata_handle
	mulu.w	d0,d1			; Calculate map size
	move.w	d1,Size_of_map
	move.b	Mapdata_handle,d0		; Calculate map offsets
	jsr	Calculate_map_data_offsets
	jsr	Init_world		; Set world parameters
; ---------- Start map ----------------------------
	lea.l	.Map_modules(pc),a0		; Get pointer to module
	move.b	Current_map_type,d0
	ext.w	d0
	lsl.w	#2,d0
	movea.l	0(a0,d0.w),a0
	jsr	Push_Module		; Push it
	movem.l	(sp)+,d0/d1/d7/a0
	rts

.Map_modules:	dc.l C2Map_Mod,W2Map_Mod,D3Map_Mod,C3Map_Mod

;*****************************************************************************
; [ Exit map ]
; All registers are	restored
;*****************************************************************************
Exit_map:
	tst.b	Continuous_flag		; Continuous icon ?
	beq.s	.Skip
	Pop	Module			; Yes -> Stop
.Skip:	st	Time_lock
	jsr	Exit_display		; Leave map
	jmp	Pop_Module

;*****************************************************************************
; [ Standard map DisExit ]
; No registers are restored
;*****************************************************************************
Map_DisExit:
	st	Time_lock			; Stop time
	jmp	Fade_out_bottom

;*****************************************************************************
; [ Standard map DisUpd ]
; All registers are restored
; NOTE :
;  - This routine will be called from each map's DisUpd-routine.
;*****************************************************************************
Map_DisUpd:
	movem.l	d0-d7/a0-a6,-(sp)
; --------- Update standard display elements ------
	jsr	Basic_DisUpd
	jsr	Display_special_items
	jsr	Display_spells
	jsr	Check_overweight
; --------- Real-time step made ? -----------------
	move.w	Realtime_step,d0		; Repeat
	bra.s	.Entry
.Loop:	move.w	d0,Realtime_step
	jsr	Zzz			; Pause
.Entry:	dbra	d0,.Loop
.Exit:	jsr	Combat_check		; Check for combat
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Calculate offsets to map data ]
;   IN : d0 - Map data handle (.b)
; All registers are restored
;*****************************************************************************
Calculate_map_data_offsets:
	movem.l	d0-d3/d7/a0/a1,-(sp)
	jsr	Claim_pointer		; Get pointer to map data
	movea.l	d0,a0
; ---------- Skip map layers ----------------------
	move.l	#Map_data,d0		; Start at underlay	layer
	moveq.l	#0,d1
	move.w	Size_of_map,d1
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl.s	.3D_map
	lsl.l	#2,d1			; 2D -> 4 bytes/square
	add.l	d1,d0
	bra.s	.Go_on
.3D_map:	add.l	d1,d0			; 3D -> 2 bytes/square
	add.l	d1,d0
; ---------- Skip event entries -------------------
.Go_on:	moveq.l	#0,d1			; Get number of event entries
	move.w	0(a0,d0.l),d1
	addq.l	#2,d0			; Skip number
	move.l	d0,Event_entry_offset	; Store offset
	add.l	d1,d1			; Skip event entry list
	add.l	d1,d0
; ---------- Skip event data ----------------------
	move.w	0(a0,d0.l),d1		; Get number of events
	addq.l	#2,d0			; Skip number
	move.l	d0,Event_data_offset	; Store offset
	mulu.w	#Event_data_size,d1		; Skip event data
	add.l	d1,d0
; ---------- Skip NPC path data -------------------
	move.l	d0,NPC_path_base_offset	; Store offset
	move.l	a0,a1			; Skip NPC path data
	lea.l	NPC_data(a1),a1
	move.l	#Max_steps*2,d1
	moveq.l	#Max_chars-1,d7
.Loop:	tst.b	NPC_char_nr(a1)		; Anyone there ?
	beq.s	.Next
	move.b	NPC_status_bits(a1),d2	; Get bits
	move.b	d2,d3			; Monster ?
	andi.b	#$03,d3
	cmp.b	#2,d3
	beq.s	.No_path
	btst	#2,d2			; Path ?
	bne.s	.No_path
	add.l	d1,d0			; Path !
	bra.s	.Next
.No_path:	addq.l	#2,d0			; No path !
.Next:	lea.l	NPC_data_size(a1),a1	; Next NPC
	dbra	d7,.Loop
; ---------- Skip Goto-point data -----------------
	move.w	0(a0,d0.l),d1		; Get number of goto points
	move.w	d1,Nr_goto_points
	addq.l	#2,d0			; Skip number
	move.l	d0,Goto_point_offset	; Store
	mulu.w	#Goto_pnt_data_size,d1	; Skip goto point data
	add.l	d1,d0
; ---------- Skip event automap data --------------
	cmp.b	#Map_3D,Current_map_type	; 3D map ?
	bmi	.Exit
	move.l	d0,Event_automap_offset	; Store
.Exit:	movem.l	(sp)+,d0-d3/d7/a0/a1
	jmp	Free_pointer

;*****************************************************************************
; [ Save coordinates ]
; All registers are restored
;*****************************************************************************
Save_coordinates:
	move.w	Map_Xcoord,Old_Xcoord	; Save coordinates
	move.w	Map_Ycoord,Old_Ycoord
	tst.b	Current_map_type		; 2D city ?
	bne.s	.No_2DC
	move.w	Mapbuf_X,Old_mapbufX	; Additional variables
	move.w	Mapbuf_Y,Old_mapbufY
	bra.s	.Exit
.No_2DC:	cmpi.b	#World_2D,Current_map_type	; 2D wilderness ?
	bne.s	.No_2DW
	move.w	Quad_X,Old_QuadX		; Additional variables
	move.w	Quad_Y,Old_QuadY
	move.w	Quad_index,Old_quadindex
	bra.s	.Exit
.No_2DW:	move.l	Player_X,Old_playerX	; Additional variables
	move.l	Player_Y,Old_playerY
	move.l	Y_angle,Old_Yangle
.Exit:	rts

;*****************************************************************************
; [ Restore coordinates after event ]
; All registers are restored
;*****************************************************************************
Restore_coordinates:
	move.w	Old_Xcoord,Map_Xcoord
	move.w	Old_Ycoord,Map_Ycoord
	tst.b	Current_map_type		; 2D city ?
	bne.s	.No_2DC
	move.w	Old_mapbufX,Mapbuf_X	; Additional variables
	move.w	Old_mapbufY,Mapbuf_Y
	bra.s	.Exit
.No_2DC:	cmpi.b	#World_2D,Current_map_type	; 2D wilderniss ?
	bne.s	.No_2DW
	move.w	Old_QuadX,Quad_X		; Additional variables
	move.w	Old_QuadY,Quad_Y
	move.w	Old_quadindex,Quad_index
	bra.s	.Exit
.No_2DW:	move.l	Old_playerX,Player_X	; Additional variables
	move.l	Old_playerY,Player_Y
	move.l	Old_Yangle,Y_angle
.Exit:	rts

;*****************************************************************************
; [ Before movement logic ]
;  OUT : eq - Movement possible
;        ne - Movement not possible
; All registers are restored
;*****************************************************************************
Before_move:
	move.l	d7,-(sp)
	jsr	Save_coordinates		; Save coordinates
	moveq.l	#0,d7			; Default is OK
	tst.b	Overweight		; Too heavy or lamed ?
	beq.s	.Exit
	move.w	Travel_mode,d0		; Yes -> Can you still move ?
	move.w	#Move_exhausted_mask,d1
	btst	d0,d1
	seq	d7
.Exit:	tst.w	d7			; Well ?
	movem.l	(sp)+,d7
	rts

;*****************************************************************************
; [ After movement logic ]
; All registers are restored
; Note : this routine can/should also be called after every non-player move,
;        (e.g. map exits, teleports, etc.) and after the player has waited
;        (by action or by time-out.)
;*****************************************************************************
After_move:
	jsr	Time_after_move
	jmp	Game_after_move

;*****************************************************************************
; [ Time logic after movement ]
; All registers are restored
;*****************************************************************************
Time_after_move:
	move.l	d0,-(sp)
	st	New_move			; New move for NPC's
	clr.w	Frame			; Reset real-time step counter
	move.w	Move_count,d0		; Count down
	dbra	d0,.Count
	jsr	Update_time		; 1 step pro {x} moves
	tst.b	Show_trans		; Show travel-modes ?
	beq.s	.No
	move.w	Time_warp,d0		; Reset counter
	bra.s	.Count
.No:	moveq.l	#Moves_per_step,d0
.Count:	move.w	d0,Move_count		; Store counter
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Game logic after movement ]
; All registers are restored
;*****************************************************************************
Game_after_move:
	movem.l	d0-d7/a0-a6,-(sp)
; ---------- Get current location status ----------
	move.w	Map_Xcoord,d0
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	move.l	d0,Current_location_status
; --------- Check for Goto-points -----------------
	cmp.b	#Map_3D,Current_map_type	; 3D map ?
	bmi	.No_Goto
	move.w	Nr_goto_points,d7		; Any Goto-points ?
	beq	.No_Goto
	move.w	Map_Xcoord,d0		; Get coordinates
	move.w	Map_Ycoord,d1
	Get	Mapdata_handle,a0		; Search Goto-points
	add.l	Goto_point_offset,a0
	bra.s	.Entry
.Loop:	cmp.b	Goto_X(a0),d0		; The right spot ?
	bne.s	.Next
	cmp.b	Goto_Y(a0),d1
	bne.s	.Next
	moveq.l	#0,d0			; Known ?
	move.b	Goto_bit_nr(a0),d0
	moveq.l	#Goto_point_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	bne.s	.Done			; Yes -> Done
	moveq.l	#1,d2			; No -> Set !
	jsr	Access_bit_array
	move.w	#144,d0			; Yay!
	jsr	Do_prompt_window
	bra.s	.Done
.Next:	lea.l	Goto_pnt_data_size(a0),a0	; Next Goto-point
.Entry:	dbra	d7,.Loop
.Done:	Free	Mapdata_handle
.No_Goto:	LOCAL
; --------- Check for poison field ----------------
	move.w	Travel_mode,d0		; Correct travel-mode ?
	move.w	#Poison_mask,d1
	btst	d0,d1
	beq	.No
	move.l	Current_location_status,d0	; Poisoned ?
	btst	#Poison_field_bit,d0
	beq	.No
	lea.l	Party_handles,a0		; Poison party
	moveq.l	#1,d7
.Loop:	move.b	(a0)+,d0			; Anyone there ?
	beq.s	.Next
	jsr	Claim_pointer
	movea.l	d0,a1
	move.w	Body_conditions(a1),d0	; Alive and kicking ?
	andi.w	#Alive_mask,d0
	bne.s	.Done
	move.w	ALuck(a1),d0		; Probe luck
	add.w	ALuck+Magic(a1),d0
	jsr	Probe_100
	bpl.s	.Done
	move.w	Body_conditions(a1),d0	; Poisoned!
	bset	#Poisoned,d0
	move.w	d0,Body_conditions(a1)
	moveq.l	#0,d0			; Show empty damage star
	jsr	Do_damage
.Done:	Free	-1(a0)
.Next:	addq.w	#1,d7			; Next character
	cmpi.w	#6+1,d7
	bmi.s	.Loop
.No:	LOCAL
; --------- Check for swimming field --------------
	cmp.b	#Map_3D,Current_map_type	; 2D map ?
	bpl	.No_swim
	move.l	Current_location_status,d0	; Swimmable ?
	btst	#Blocked_swimming_bit,d0
	sne	Swim_status
	beq.s	.Skip
	jsr	Seek_transport_HERE		; Ship or raft present ?
	tst.w	d0
	beq.s	.Skip
	move.w	#Swim_mask,d1
	btst	d0,d1
	beq.s	.Skip
	sf	Swim_status		; Yes
.Skip:	tst.w	Travel_mode		; Walking ?
	bne	.No_walk
	tst.b	Swim_status		; Can one still walk here ?
	beq.s	.Done1
	moveq.l	#Swimming,d0		; Swim !
	jsr	Set_new_travel_mode
	bra	.Done1
.No_walk:	cmpi.w	#Swimming,Travel_mode	; Swimming ?
	bne.s	.Done1
	tst.b	Swim_status		; Can one still swim here ?
	bne.s	.Done1
	moveq.l	#On_foot,d0		; Walk !
	jsr	Set_new_travel_mode
; --------- Let the party swim --------------------
.Done1:	cmpi.w	#Swimming,Travel_mode	; Swimming ?
	bne	.No_swim
	lea.l	Party_handles,a0		; Swim !
	moveq.l	#0,d1
	moveq.l	#1,d7
.Loop:	move.b	(a0)+,d0			; Anyone there ?
	beq.s	.Next
	jsr	Claim_pointer
	movea.l	d0,a1
	move.w	#Alive_mask,d0		; Alive and kicking ?
	and.w	Body_conditions(a1),d0
	bne.s	.Done2
	move.w	SSwimming(a1),d1		; Get swimming skill
	add.w	SSwimming+Magic(a1),d1
	cmp.w	#100,d1
	bpl.s	.Done2
	subi.w	#100,d1			; Damage percentage 50%
	neg.w	d1
	asr.w	#1,d1
	tst.w	d1			; Any ?
	bls.s	.Done2
	moveq.l	#0,d0			; Do damage !
	move.w	Life_points(a1),d0
	mulu.w	d1,d0
	divu.w	#100,d0
	bne.s	.Not_zero
	moveq.l	#1,d0
.Not_zero:	jsr	Do_damage
.Done2:	Free	-1(a0)
.Next:	addq.w	#1,d7			; Next character
	cmpi.w	#6+1,d7
	bmi.s	.Loop
.No_swim:	LOCAL
; --------- Clairvoyance check --------------------
	tst.w	Spell_5_duration		; Spell on ?
	beq	.No_clair
	move.w	Travel_mode,d0		; Correct travel-mode ?
	move.w	#Clairv_mask,d1
	btst	d0,d1
	beq	.No_clair
	jsr	Get_coordinates_in_front	; Get
	jsr	Find_event		; Find event
	bmi	.No_clair			; Any there ?
	jsr	Check_event_save_status	; Already saved ?
	bne	.No_clair
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get event type
	move.b	(a5),d0
	cmpi.b	#Item_found_type,d0		; [ Item found ] event ?
	bne.s	.No_chest
	tst.b	Event_b2(a5)		; Hidden chest ?
	beq.s	.No_clair
	jsr	Update_screen		; Do chest
	st	Clairvoyant
	jsr	Handle_event_chain
	sf	Clairvoyant
	bra	.No_clair
.No_chest:	jsr	Print_visible_event		; Print event
.No_clair:	LOCAL
; --------- Handle events -------------------------
	jsr	Event_handler
; --------- World map movement delay --------------
	cmpi.b	#World_2D,Current_map_type	; Wilderniss ?
	bne.s	.No_delay
	lea.l	World_move_delay,a0		; Get delay value
	move.w	Travel_mode,d0
	move.b	0(a0,d0.w),d0
	beq.s	.No_delay
	ext.w	d0			; Delay
	jsr	Delay
.No_delay:	LOCAL
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Check immobility status (overweight/lamed) ]
; All registers are restored
;*****************************************************************************
Check_overweight:
	movem.l	d0/d1/d6/d7/a0/a1,-(sp)
	moveq.l	#0,d6			; Default
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq	.End
; --------- Check for overweight ------------------
	lea.l	Party_handles,a0
	moveq.l	#1,d7
.Loop1:	move.b	(a0)+,d0			; Anyone there ?
	beq	.Next1
	jsr	Claim_pointer		; Get pointer to character data
	movea.l	d0,a1
	move.l	Weight_normal(a1),d0	; Get current weight
	divu.w	#1000,d0
	move.w	AStrength(a1),d1		; Get maximum weight
	add.w	AStrength+Magic(a1),d1
	cmp.w	d0,d1			; Too heavy ?
	bpl.s	.Done1
	bset	d7,d6			; Overweight !
.Done1:	Free	-1(a0)
.Next1:	addq.w	#1,d7			; Next member
	cmpi.w	#6+1,d7
	bmi.s	.Loop1
; --------- Check if entire party is lamed --------
	lea.l	Party_handles,a0
	bset	#7,d6
	moveq.l	#6-1,d7
.Loop2:	move.b	(a0)+,d0			; Anyone there ?
	beq.s	.Next2
	jsr	Claim_pointer		; Get pointer to character data
	movea.l	d0,a1
	move.w	Body_conditions(a1),d0	; Alive and kicking	?
	move.w	d0,d1
	andi.w	#Alive_mask,d0
	bne.s	.Done2
	btst	#Lamed,d1			; Lamer ?
	bne.s	.Done2
	bclr	#7,d6			; You can	walk
	Free	-1(a0)
	bra.s	.End
.Done2:	Free	-1(a0)
.Next2:	dbra	d7,.Loop2
.End:	move.b	d6,Overweight		; Store bitlist
	movem.l	(sp)+,d0/d1/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Get status of location ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : d0 - Location status (.l)
; Changed registers : d0
; Notes :
;   - The routine assumes no two NPC's can be in the same place.
;   - In 2D wilderness, the coordinates may fall outside the map, but	must
;     refer to the current map. They may not fall	outside the quad-map !
;   - The routine will output :
;     	the NPC icon status when
;		an NPC is present,
;		it's icon status <> 0 and
;		the {Underlay priority}-bit is cleared.
;     Otherwise it will output  :
;	the overlay icon status when
;		an overlay is present and
;		the {Underlay priority}-bit is cleared.
;   - The routine doesn't check 3D objects.
;*****************************************************************************
Get_location_status:
	movem.l	d1-d7/a0/a1,-(sp)
	move.w	d0,d4			; Save coordinates
	move.w	d1,d5
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl	.3D_map
	tst.b	Current_map_type		; City or	wilderness ?
	bne	.2D_wild
; --------- Get 2D city map handle ----------------
	move.b	Mapdata_handle,d7
	bra	.Go_on
; --------- Get 2D wilderness map handle ----------
.2D_wild:	move.w	Quad_index,d2		; Get quad index
	cmp.w	#1,d0			; Out of range left ?
	bpl.s	.Left_OK
	bclr	#0,d2			; Map to the left
	add.w	Submap_width,d4
	bra.s	.Check_Y
.Left_OK:	cmp.w	Submap_width,d0		; Out of range right ?
	bls.s	.Check_Y
	bset	#0,d2			; Map to the right
	sub.w	Submap_width,d4
.Check_Y:	cmp.w	#1,d1			; Out of range top ?
	bpl.s	.Top_OK
	bclr	#1,d2			; Map to the top
	add.w	Submap_height,d5
	bra.s	.Done1
.Top_OK:	cmp.w	Submap_height,d1		; Out of range bottom ?
	bls.s	.Done1
	bset	#1,d2			; Map to the bottom
	sub.w	Submap_height,d5
.Done1:	lea.l	Quad_map,a1		; Get map	handle
	mulu.w	#Quad_mapsize,d2
	move.b	0(a1,d2.w),d7
; --------- Get 2D map icon status ----------------
.Go_on:	move.b	d7,d0			; Get pointer to map data
	jsr	Claim_pointer
	movea.l	d0,a1
	lea.l	Map_data(a1),a1
	Get	Icondata_handle,a0		; Get pointer to icon data
	move.w	d5,d0			; Calculate map pointer
	subq.w	#1,d0
	mulu.w	Width_of_map,d0
	lsl.l	#2,d0
	adda.l	d0,a1
	move.w	d4,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a1
	moveq.l	#0,d0			; Get underlay icon number
	move.b	(a1),d0
	beq.s	.No_under
	lsl.w	#3,d0			; Get underlay icon status
	move.l	-8+2(a0,d0.w),d0
.No_under:	moveq.l	#0,d1			; Get overlay icon number
	move.w	2(a1),d1
	beq.s	.No_over			; Is there an overlay ?
	lsl.w	#3,d1			; Get overlay icon status
	move.l	-8+2(a0,d1.w),d1
.No_over:	Free	d7
	Free	Icondata_handle
	bra	.Check_NPC
; --------- Get 3D map wall status ----------------
.3D_map:	Get	Mapdata_handle,a0		; Get pointer to map &
	lea.l	Map_data(a0),a0		;  labyrinth data
	Get	Labdata_handle,a1
	move.w	d4,d0			; Calculate map pointer
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,a0
	move.w	d5,d0
	subq.w	#1,d0
	mulu.w	Width_of_map,d0
	add.w	d0,d0
	add.w	d0,a0
	moveq.l	#0,d0			; Get map byte
	move.b	(a0),d0
	beq.s	.Empty			; Anything ?
	cmp.b	#-1,d0			; Dummy wall ?
	beq.s	.Empty
	cmp.b	#First_wall,d0		; Wall or object ?
	bcc.s	.Wall
.Empty:	moveq.l	#0,d0			; Default combat background
	move.w	Default_combat_bg_nr(a1),d0
	andi.w	#$000f,d0
	ror.l	#4,d0
	ori.l	#Default_icon_bits,d0
	bra.s	.Done
.Wall:	lea.l	Wall_data_offsets,a0	; Get wall status bits
	subi.w	#First_wall,d0
	cmp.w	Nr_of_walls,d0		; Legal ?
	bmi.s	.Wall_OK
	moveq.l	#0,d0			; No
	bra.s	.Done
.Wall_OK:	lsl.w	#2,d0			; Yes
	add.l	0(a0,d0.w),a1
	move.l	Wall_bits(a1),d0
.Done:	Free	Labdata_handle
	Free	Mapdata_handle
	moveq.l	#0,d1			; No overlay
; --------- Check NPC status ----------------------
.Check_NPC:
	moveq.l	#0,d2			; No NPC icon status
	cmpi.b	#World_2D,Current_map_type	; 2D wilderness ?
	beq.s	.End
	lea.l	VNPC_data,a0		; Check NPC's
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq.s	.Next
	btst	d7,d6			; Deleted	?
	bne.s	.Next
	cmp.w	Current_NPC,d7		; Is self ?
	beq.s	.Next
	cmp.w	VMap_X(a0),d4		; Right coordinates	?
	bne.s	.Next
	cmp.w	VMap_Y(a0),d5
	bne.s	.Next
	move.l	NPC_icon_status(a0),d2	; Get icon status
	bra.s	.End
.Next:	lea.l	VNPC_data_size(a0),a0	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop
; ---------- Merge location status ----------------
.End:	tst.l	d2			; Any NPC ?
	beq.s	.No
	btst	#Underlay_priority_bit,d2	; Overlay priority ?
	bne.s	.No
	move.l	d2,d0			; Yes -> Use NPC status
	bra.s	.Exit
.No:	tst.l	d1			; Any overlay ?
	beq.s	.Exit
	btst	#Underlay_priority_bit,d1	; Underlay priority ?
	bne.s	.Exit
	move.l	d1,d0			; No -> Use overlay status
.Exit:	movem.l	(sp)+,d1-d7/a0/a1
	rts

;*****************************************************************************
; [ Initialize world data ]
; All registers are restored
;*****************************************************************************
Init_world:
	movem.l	d0/a0/a1,-(sp)
	Get	Mapdata_handle,a0		; Get world number
	moveq.l	#0,d0
	move.b	World_number(a0),d0
	Free	Mapdata_handle
	move.w	d0,Current_world_nr		; Store
	lea.l	World_data,a0		; Get new	world data
	mulu.w	#World_data_size,d0
	adda.w	d0,a0
	lea.l	Current_world,a1
	moveq.l	#World_data_size/2-1,d0
.Loop:	move.w	(a0)+,(a1)+
	dbra	d0,.Loop
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Initialize map CIL ]
; No registers are restored
;*****************************************************************************
Init_map_CIL:
	tst.b	Which_CIL			; Which ?
	beq.s	.First
	lea.l	Second_CIL,a0		; Second CIL
	bra.s	.Do
.First:	movea.l	First_CIL_ptr,a0		; First CIL
.Do:	jmp	Display_control_icons

;*****************************************************************************
; [ Switch map CIL ]
; No registers are restored
;*****************************************************************************
Switch_map_CIL:
	jsr	Wait_4_unclick
	not.b	Which_CIL			; Switch
	jsr	Init_map_CIL
	jmp	Update_screen

;*****************************************************************************
; [ Re-evaluate map CIL ]
;   IN : a0 - Pointer to CIL (.l)
; No registers are restored
;*****************************************************************************
Map_CIL_evaluate:
; --------- Anyone overweight ? -------------------
	tst.b	Overweight
	beq.s	.Exit
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl.s	.3D_map
	bset	#7,(a0)			; Disable	all movement
	bset	#7,2(a0)
	bset	#7,4(a0)
	bset	#7,6(a0)
	bset	#7,10(a0)
	bset	#7,12(a0)
	bset	#7,14(a0)
	bset	#7,16(a0)
	bra.s	.Exit
.3D_map:	bset	#7,2(a0)			; Disable	all movement
	bset	#7,6(a0)
	bset	#7,10(a0)
	bset	#7,14(a0)
.Exit:	rts

;*****************************************************************************
; [ Move according to mouse pointer ]
; No registers are restored
;*****************************************************************************
Move_mouse:
	jsr	Change_mouse		; Change
	move.w	Mouse_direction,d0
	cmp.w	#4,d0			; Wait ?
	bne.s	.No_wait
	jsr	Zzz			; Yes
	bra.s	.Exit
.No_wait:	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bmi.s	.Normal
	Push	Module,Mousemove_3D_Mod	; No
	bra	.Exit
.Normal:	lsl.w	#2,d0			; Get routine address
	movea.l	First_CIL_ptr,a0
	move.l	Icon_vectors(a0,d0.w),d0
	beq	.Exit			; Any ?
	move.l	d0,a0			; Execute
	jsr	(a0)
.Exit:	rts

;*****************************************************************************
; [ Moving with mouse in 3D map ]
; No registers are restored
;*****************************************************************************
Mousemove_ModInit:
	st	Mouse_moving
	jmp	Moving_mouse

Mousemove_ModExit:
	sf	Mouse_moving
	rts

MouseMove_DisExit:
	Pop	Module
	jmp	Exit_display

Moving_mouse:
	jsr	Change_mouse		; Change
	move.w	Mouse_direction,d0
	lea.l	.Vectors,a0		; Get routine address
	lsl.w	#2,d0
	move.l	0(a0,d0.w),d0
	beq	.Exit			; Any ?
	move.l	d0,a0			; Execute
	jsr	(a0)
.Exit:	rts

.Vectors:	dc.l .Turnleft,.Forward,.Turnright
	dc.l .Left,0,.Right
	dc.l .Backleft,.Back,.Backright

.Turnleft:
	move.w	Mouse_X,d0		; Get mouse X
	subi.w	#Map3D_X,d0
	subi.w	#48-1,d0			; Negate
	neg.w	d0
	jsr	.Clip			; Clip and scale
	mulu.w	Dungeon_speed,d0		; Increase angle
	lsr.l	#4,d0
	moveq.l	#13,d1
	lsl.l	d1,d0
	add.l	d0,Y_angle
	jmp	.Slowforward

.Forward:
	move.w	Mouse_Y,d0		; Get mouse Y
	subi.w	#Map3D_Y,d0
	subi.w	#48-1,d0			; Negate
	neg.w	d0
	jsr	.Clip			; Clip and scale
	jsr	.Get_scaled_vector		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	sub.l	d0,d2
	add.l	d1,d3
	move.l	d2,d0
	move.l	d3,d1
	jmp	Try_3D_move		; Try

.Slowforward:
	move.w	Mouse_Y,d0		; Get mouse Y
	subi.w	#Map3D_Y,d0
	subi.w	#48-1,d0			; Negate
	neg.w	d0
	subi.w	#16,d0
	jsr	.Clip			; Clip and scale
	jsr	.Get_scaled_vector		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	sub.l	d0,d2
	add.l	d1,d3
	move.l	d2,d0
	move.l	d3,d1
	jmp	Try_3D_move		; Try

.Turnright:
	move.w	Mouse_X,d0		; Get mouse X
	subi.w	#Map3D_X+96,d0
	jsr	.Clip			; Clip and scale
	mulu.w	Dungeon_speed,d0		; Decrease angle
	lsr.l	#4,d0
	moveq.l	#13,d1
	lsl.l	d1,d0
	sub.l	d0,Y_angle
	jmp	.Slowforward

.Left:
	move.w	Mouse_X,d0		; Get mouse X
	subi.w	#Map3D_X,d0
	subi.w	#48-1,d0			; Negate
	neg.w	d0
	lsr.w	#2,d0
	jsr	.Clip			; Clip and scale
	jsr	.Get_scaled_vector		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	sub.l	d1,d2
	sub.l	d0,d3
	move.l	d2,d0
	move.l	d3,d1
	jmp	Try_3D_move		; Try

.Right:
	move.w	Mouse_X,d0		; Get mouse X
	subi.w	#Map3D_X+96,d0
	lsr.w	#2,d0
	jsr	.Clip			; Clip and scale
	jsr	.Get_scaled_vector		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	add.l	d1,d2
	add.l	d0,d3
	move.l	d2,d0
	move.l	d3,d1
	jmp	Try_3D_move		; Try

.Back:
	move.w	Mouse_Y,d0		; Get mouse Y
	subi.w	#Map3D_Y+96,d0
	lsr.w	#1,d0
	jsr	.Clip			; Clip and scale
	jsr	.Get_scaled_vector		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	add.l	d0,d2
	sub.l	d1,d3
	move.l	d2,d0
	move.l	d3,d1
	jmp	Try_3D_move		; Try

.Slowback:
	move.w	Mouse_Y,d0		; Get mouse Y
	subi.w	#Map3D_Y+96+16,d0
	asr.w	#1,d0
	jsr	.Clip			; Clip and scale
	jsr	.Get_scaled_vector		; Get vector
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	add.l	d0,d2
	sub.l	d1,d3
	move.l	d2,d0
	move.l	d3,d1
	jmp	Try_3D_move		; Try

.Backright:
	move.w	Mouse_X,d0		; Get mouse X
	subi.w	#Map3D_X+96,d0
	lsr.w	#1,d0
	jsr	.Clip			; Clip and scale
	mulu.w	Dungeon_speed,d0		; Decrease angle
	lsr.l	#4,d0
	moveq.l	#13,d1
	lsl.l	d1,d0
	sub.l	d0,Y_angle
	jmp	.Slowback

.Backleft:
	move.w	Mouse_X,d0		; Get mouse X
	subi.w	#Map3D_X,d0
	subi.w	#48-1,d0			; Negate
	neg.w	d0
	lsr.w	#1,d0
	jsr	.Clip			; Clip and scale
	mulu.w	Dungeon_speed,d0		; Increase angle
	lsr.l	#4,d0
	moveq.l	#13,d1
	lsl.l	d1,d0
	add.l	d0,Y_angle
	jmp	.Slowback

.Clip:
	tst.w	d0			; Clip bottom
	bpl.s	.Ok1
	moveq.l	#0,d0
	bra.s	.Ok2
.Ok1:	cmp.w	#48,d0			; Clip top
	bmi.s	.Ok2
	moveq.l	#47,d0
.Ok2:	lsr.w	#1,d0			; Divide
	addq.w	#1,d0
	rts

.Get_scaled_vector:
	mulu.w	Dungeon_speed,d0		; Scale
	lsr.l	#4,d0
	move.w	d0,d2
	lea.l	Sinus_table,a0
	move.w	Y_angle,d1
	andi.w	#slang-1,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d0		; Sine
	addi.w	#slang/2,d1
	andi.w	#slang*2-1,d1
	move.w	0(a0,d1.w),d1		; Cosine
	muls.w	d2,d0
	muls.w	d2,d1
	asl.l	#2,d0			; 16 bit nachkomma !
	asl.l	#2,d1
	rts

;*****************************************************************************
; [ Change mouse pointer ]
; All registers are restored
;*****************************************************************************
Change_mouse:
	movem.l	d0-d2/a0,-(sp)
	move.w	Mouse_X,d0		; Still in map area ?
	move.w	Mouse_Y,d1
	jsr	Find_object
	andi.l	#$00ffff00,d2
	cmpi.l	#$00020200,d2
	bne	.Exit
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl	.3D_map
; --------- Calculate index for 2D map ------------
	lea.l	Mousetab_2D,a0
	subi.w	#Map2D_X,d0		; Translate to (0,0)
	subi.w	#Map2D_Y,d1
	lsr.w	#4,d0			; Divide by 16
	lsr.w	#4,d1
	sub.w	Mapbuf_X,d0		; Calculate dX
	sub.w	Mapbuf_Y,d1		; Calculate dY
	ext.l	d0			; Mega SGN function
	beq.s	.Zero1
	swap.w	d0
	bmi.s	.Zero1
	moveq.l	#1,d0
.Zero1:	addq.w	#1,d0			; Translate to {0,1,2}
	ext.l	d1			; Mega SGN function
	beq.s	.Zero2
	swap.w	d1
	bmi.s	.Zero2
	moveq.l	#1,d1
.Zero2:	addq.w	#1,d1			; Translate to {0,1,2}
	add.w	d1,d0			; Multiply by 3 & add
	add.w	d1,d1
	add.w	d1,d0
	move.w	d0,d2
	bra.s	.Continue
; --------- Calculate index for 3D map ------------
.3D_map:	lea.l	Mousetab_3D,a0
	subi.w	#Map3D_X,d0		; Translate
	subi.w	#Map3D_Y,d1
	ext.l	d0
	ext.l	d1
	divu.w	#48,d0
	divu.w	#48,d1
	add.w	d1,d0			; Calculate index
	add.w	d1,d1
	add.w	d0,d1
	move.w	d1,d2
; --------- Set new mouse pointer -----------------
.Continue:	move.w	d2,Mouse_direction		; Store number
	lsl.w	#2,d2			; Get number of new	pointer
	move.l	0(a0,d2.w),a0
	jsr	Change_Mptr		; Set new	mouse pointer
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Right mouse button in 3D map window ]
; No registers are restored
;*****************************************************************************
Right_mouse:
	move.w	Mouse_X,d0		; Still in map area ?
	move.w	Mouse_Y,d1
	jsr	Find_object
	andi.l	#$00ffff00,d2
	cmpi.l	#$00020200,d2
	bne	.Exit
	jsr	Change_mouse		; Yes
	subi.w	#Map3D_X,d0		; Translate
	subi.w	#Map3D_Y,d1
	ext.l	d0
	ext.l	d1
	divu.w	#48,d0
	divu.w	#48,d1
	add.w	d1,d0			; Calculate index
	add.w	d1,d1
	add.w	d1,d0
	lsl.w	#2,d0			; Get routine address
	move.l	.Vectors(pc,d0.w),d0
	beq.s	.Exit
	move.l	d0,a0			; Execute
	jsr	(a0)
.Exit:	rts

.Vectors:	dc.l Left90_3D,0,Right90_3D
	dc.l 0,.Action,0
	dc.l Left180_3D,0,Right180_3D

.Action:
	Push	Mptr,EyeMouth_Mptr		; Wait
	jsr	Wait_4_unclick
	Pop	Mptr
	move.w	Map_Xcoord,d0		; Try current coordinates
	move.w	Map_Ycoord,d1
	jsr	Talk			; Talk ?
	bne.s	.Exit2
	jsr	Look			; Look ?
	bne.s	.Exit2
	jsr	Get_coordinates_in_front	; No
	jsr	Talk			; Talk ?
	bne.s	.Exit2
	jsr	Look			; Look ?
.Exit2:	rts

;*****************************************************************************
; [ Reset mouse pointer when not in map area ]
; No registers are restored
;*****************************************************************************
Reset_map_mouse:
	move.w	Mouse_X,d0		; In map area ?
	move.w	Mouse_Y,d1
	jsr	Find_object
	andi.l	#$00ffff00,d2
	cmpi.l	#$00020200,d2
	beq.s	.Exit
	lea.l	Default_Mptr,a0		; Default	pointer
	jsr	Change_Mptr
.Exit:	rts

;*****************************************************************************
; [ Load map texts ]
; All registers are restored
;*****************************************************************************
Load_map_texts:
	movem.l	d0/d1,-(sp)
	move.w	Map_nr,d0			; Load map text file
	moveq.l	#Map_text_file,d1
	jsr	Load_subfile
	move.b	d0,Maptext_handle
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Load map palette ]
; All registers are restored
;*****************************************************************************
Load_map_palette:
	movem.l	d0/d1/d6/d7/a0-a2,-(sp)
	Get	Mapdata_handle,a0		; Get palette number
	moveq.l	#0,d0
	move.b	Colourpal_filenr(a0),d0
	Free	Mapdata_handle
	moveq.l	#Palette_file,d1		; Load palette
	jsr	Load_subfile
	move.b	d0,d7
	jsr	Claim_pointer
	move.l	d0,a0
	cmp.b	#Map_3D,Current_map_type	; 2D or 3D ?
	bpl.s	.3D_map
	lea.l	Current_pal,a1		; Copy palette
	moveq.l	#Pal_size-1,d6
.Loop1:	move.w	(a0)+,(a1)+
	dbra	d6,.Loop1
	bra.s	.Go_on
.3D_map:	lea.l	Current_pal,a1		; Copy palette
	lea.l	Backup_pal,a2		;  & duplicate first half
	moveq.l	#Pal_size/2-1,d6
.Loop2:	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbra	d6,.Loop2
	moveq.l	#Pal_size/2-1,d6
.Loop3:	move.w	(a0)+,(a1)+
	dbra	d6,.Loop3
.Go_on:	move.b	d7,d0			; Destroy palette
	jsr	Free_pointer
	jsr	Free_memory
	movem.l	(sp)+,d0/d1/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Set spell area ]
; All registers are restored
;*****************************************************************************
Set_spell_area:
	movem.l	d0/a0,-(sp)
	Get	Mapdata_handle,a0
	move.w	Map_special(a0),d0
	Free	Mapdata_handle
	btst	#Wilderness_bit,d0		; Wilderness ?
	beq.s	.No_wild
	moveq.l	#Wilderness_spell_area,d0	; Yes
	bra	.Exit
.No_wild:	btst	#City_bit,d0		; City ?
	beq.s	.No_city
	moveq.l	#City_spell_area,d0		; Yes
	bra	.Exit
.No_city:	moveq.l	#Dungeon_spell_area,d0	; Dungeon	!
.Exit:	move.w	d0,Spell_area_type
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Set map music ]
; All registers are restored
;*****************************************************************************
Set_map_music:
	movem.l	d0/d1/a0,-(sp)
	tst.b	Show_trans		; Show transports ?
	beq.s	.No_trans
	lea.l	Travel_music,a0		; Set music according to
	move.w	Travel_mode,d0		;  travel-mode
	move.b	0(a0,d0.w),d0
	bne.s	.Do
.No_trans:	move.w	Current_map_music,d0	; Use current map music
	bne.s	.Do			; If any
	Get	Mapdata_handle,a0		; Get music from map
	moveq.l	#0,d0
	move.b	Map_music(a0),d0
	Free	Mapdata_handle
	move.w	d0,Current_map_music	; !
.Do:	moveq.l	#0,d1			; Do it
	jsr	Set_music
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Print map headline ]
; All registers are restored
;*****************************************************************************
Print_headline:
	movem.l	d0-d2/a0,-(sp)
	cmp.b	#World_2D,Current_map_type	; World map ?
	beq.s	.Yes
	Get	Maptext_handle,a0		; No -> Get map name
	moveq.l	#0,d0
	jsr	Find_large_text
	Free	Maptext_handle
	bra.s	.Print
.Yes:	Get	Mapdata_handle,a0		; Get world number
	moveq.l	#0,d0
	move.b	World_number(a0),d0
	Free	Mapdata_handle
	lea.l	World_map_names,a0		; Get world string address
	lsl.w	#2,d0
	move.l	0(a0,d0.w),a0
.Print:	move.w	#31,Ink_colour		; Set ink
	moveq.l	#13,d0			; Print
	moveq.l	#40,d1
	move.w	#180,d2
	jsr	Print_centered_string
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Update animation ]
; All registers are restored
;*****************************************************************************
Update_animation:
	movem.l	d0/d7/a0/a1,-(sp)
; --------- Update circle animation ---------------
	lea.l	Circle_anim+4,a0
	moveq.l	#2,d7
.Loop1:	move.b	(a0),d0			; Increase frame
	addq.b	#1,d0
	cmp.b	d0,d7			; Last frame ?
	bne.s	.Skip1
	jsr	.Recalc_random
	moveq.l	#0,d0			; Reset frame
.Skip1:	move.b	d0,(a0)			; Store frame
	addq.l	#4,a0			; Next animation length
	addq.w	#1,d7
	cmpi.w	#8+1,d7
	bmi.s	.Loop1
; --------- Update wave animation -----------------
	lea.l	Wave_anim+8,a0
	lea.l	32-8(a0),a1
	moveq.l	#3,d7
.Loop2:	move.b	(a0),d0
	tst.b	(a1)+			; Up or down ?
	bne.s	.Down
	addq.b	#1,d0			; Increase
	cmp.b	d0,d7			; Last frame ?
	bne.s	.Skip2
	subq.b	#2,d0			; Reverse	direction
	not.b	-1(a1)
	bra.s	.Skip2
.Down:	subq.b	#1,d0			; Decrease
	bne.s	.Skip2
	not.b	-1(a1)			; Reverse	direction
	jsr	.Recalc_random
.Skip2:	move.b	d0,(a0)			; Store frame
	addq.l	#4,a0			; Next animation length
	addq.w	#1,d7
	cmpi.w	#8+1,d7
	bmi.s	.Loop2
.Exit:	movem.l	(sp)+,d0/d7/a0/a1
	rts

; [ Re-calculate random animation factors ]
;   IN : a0 - Pointer to animation table (.l)
; All registers are restored
.Recalc_random:
	movem.l	d0/d1/d7,-(sp)
	moveq.l	#0,d1			; Re-calculate random
	move.w	Anim_bias,d7
	subq.w	#1,d7
.Loop:	jsr	Random
	lsr.w	#1,d0
	andi.w	#$000f,d0
	bset	d0,d1
	dbra	d7,.Loop
	move.w	d1,2(a0)			; Store
	jsr	Random			; Re-calculate offset
	lsr.w	#1,d0
	move.b	d0,1(a0)
	movem.l	(sp)+,d0/d1/d7
	rts

;*****************************************************************************
; [ Seek transport on current location ]
;  OUT : d0 - Travel mode number / 0 (.w)
;        d1 - Index (.w)
; Changed registers : d0,d1
;*****************************************************************************
Seek_transport_HERE:
	move.l	d2,-(sp)
	move.w	Map_Xcoord,d0		; Get current location
	move.w	Map_Ycoord,d1
	move.w	Map_nr,d2
	jsr	Seek_transport
	move.l	(sp)+,d2
	rts

;*****************************************************************************
; [ Seek transport ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Map number (.w)
;  OUT : d0 - Travel mode number / 0 (.w)
;        d1 - Index (.w)
; Changed registers : d0,d1
;*****************************************************************************
Seek_transport:
	movem.l	d3/d7/a0,-(sp)
	lea.l	Trans_data,a0
	moveq.l	#0,d3
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a0)		; Any there ?
	beq.s	.Next
	cmp.w	Trans_map_nr(a0),d2		; Same map ?
	bne.s	.Next
	cmp.b	Trans_X(a0),d0		; Same position ?
	bne.s	.Next
	cmp.b	Trans_Y(a0),d1
	bne.s	.Next
	moveq.l	#0,d0			; Get travel mode
	move.b	Trans_type(a0),d0
	move.w	d3,d1
	bra.s	.Exit
.Next:	addq.w	#1,d3			; Next transport
	addq.w	#Trans_data_size,a0
	dbra	d7,.Loop
	moveq.l	#0,d0			; No success
.Exit:	movem.l	(sp)+,d3/d7/a0
	rts

;*****************************************************************************
; [ Remove map data if in combat ]
; All registers are restored
;*****************************************************************************
Remove_map_data:
	tst.b	Battling			; In combat ?
	beq.s	.Exit
	st	Reload_map_data		; Yes -> Dump
	cmp.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl.s	.3D_map
	jsr	Remove_2D_map_data
	bra.s	.Exit
.3D_map:	jsr	Remove_3D_map_data
.Exit:	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Mousetab_2D:
	dc.l Upleft_2D_Mptr,Up_2D_Mptr,Upright_2D_Mptr
	dc.l Left_2D_Mptr,Zzz_Mptr,Right_2D_Mptr
	dc.l Downleft_2D_Mptr,Down_2D_Mptr,Downright_2D_Mptr
Mousetab_3D:
	dc.l Turnleft_3D_Mptr,Forward_3D_Mptr,Turnright_3D_Mptr
	dc.l Left_3D_Mptr,Zzz_Mptr,Right_3D_Mptr
	dc.l Turn180_left_Mptr,Back_3D_Mptr,Turn180_right_Mptr
