; Proof of concept : transports and travel modes (Atari ST)
;
; From ACTIONS.S ([ Change_travel_mode ]), MAIN.S ([ Set_new_travel_mode ]),
; MAP/MAP.S ([ Seek_transport ], swimming in [ Game_after_move ]),
; MAP/2D_MAP.S (the stationary transports, [ Init_travelmode ]) and PLACES.S
; (the transport merchants). The transports are in the savegame
; ([ Trans_data ] : type, position and map of the parked horses, rafts and
; ships). On the world maps the party is shown with the graphics of the
; current travel mode, and the travel mode decides which tiles can be
; entered, the speed and whether monsters attack and events happen.

	SECTION	Program,code

Trans_data	EQU	Savegame+$44		; (in Party_data)
Travel_mode	EQU	Savegame+$3c

;*****************************************************************************
; [ Set new travel mode ]
;   IN : d0 - New travel mode (.w)
; All registers are restored
; NOTE :
;   - From MAIN.S.
;*****************************************************************************
Set_new_travel_mode:
	movem.l	d0-d3/a0/a1,-(sp)
	cmp.w	#Max_travelmodes,d0		; Legal ?
	bpl.s	.Exit
	move.w	d0,Travel_mode		; Yes -> Store
	clr.w	Time_warp			; Clear
	tst.b	World_map			; Show travel-modes ?
	beq.s	.Exit
	lea.l	Travel_speed,a0		; Set new movement speed
	move.b	0(a0,d0.w),d0
	ext.w	d0
	move.w	d0,Time_warp
	clr.w	Move_count		; Reset counter
	jsr	Load_travel_graphics	; Load new graphics
.Exit:	movem.l	(sp)+,d0-d3/a0/a1
	rts

; [ Load the graphics of the travel mode ]
; All registers are restored
Load_travel_graphics:
	movem.l	d0-d3/a1,-(sp)
	move.w	Travel_mode,d0		; "T<mode>_<tileset>"
	move.w	Current_tileset,d1
	moveq.l	#'T',d2
	move.l	#Max_travel_graphics,d3
	lea.l	Travel_graphics,a1
	jsr	Load_sprite_file
	movem.l	(sp)+,d0-d3/a1
	rts

; [ Load the graphics of the stationary transports ]
; All registers are restored
Load_stationary_graphics:
	movem.l	d0-d2/a1,-(sp)
	move.w	Current_tileset,d0		; "STA<tileset>"
	move.l	#Stationary_size,d1
	move.l	#'STA_',d2
	lea.l	Stationary_graphics,a1
	jsr	Load_person_file
	movem.l	(sp)+,d0-d2/a1
	rts

;*****************************************************************************
; [ Change travel-mode ] (control icon)
; NOTE :
;   - From [ Change_travel_mode ] (ACTIONS.S).
;*****************************************************************************
Change_travel_mode:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Travel_mode_possible	; Possible ?
	beq	.Exit
	move.w	Travel_mode,d0		; Get travel mode
	cmp.w	#On_foot,d0		; On foot now ?
	beq	.Up
	cmp.w	#Swimming,d0		; Or swimming ?
	beq	.Up
	move.w	#Stationary_mask,d1		; Leave transport ?
	btst	d0,d1
	beq.s	.No
	lea.l	Trans_data,a0		; Seek free slot
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a0)		; Anything there ?
	bne.s	.Next
	move.w	Map_nr,Trans_map_nr(a0)	; Set map number
	move.w	Map_Xcoord,d1		; Set coordinates
	move.b	d1,Trans_X(a0)
	move.w	Map_Ycoord,d1
	move.b	d1,Trans_Y(a0)
	move.b	d0,Trans_type(a0)		; Set transport type
	bra.s	.No
.Next:	addq.w	#Trans_data_size,a0	; Next transport
	dbra	d7,.Loop
.No:	moveq.l	#On_foot,d0		; Back on foot
	jsr	Set_new_travel_mode
	jsr	Check_swimming		; Maybe something happens
	st	Pending_events
	bra.s	.Done
.Up:	jsr	Seek_transport_HERE		; Get on what ?
	tst.w	d0			; Nothing ?!
	beq.s	.Exit			;  (shouldn't occur)
	lea.l	Trans_data,a0		; Remove transport
	mulu.w	#Trans_data_size,d1
	clr.b	Trans_type(a0,d1.w)
	jsr	Set_new_travel_mode		; Do it !
.Done:	move.w	#2,Icons_redraw		; (icons may change)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Can the party change the travel mode here ? ]
;  OUT : ne - Yes, eq - No
; All registers are restored
; NOTE :
;   - From [ Second_CIL_evaluate ] (ACTIONS.S).
Travel_mode_possible:
	movem.l	d0-d2,-(sp)
	moveq.l	#0,d2			; Default is no
	tst.b	World_map			; Show travel-modes ?
	beq.s	.Exit
	move.w	Travel_mode,d0		; Up or off ?
	move.w	#Get_off_mask,d1
	btst	d0,d1
	bne.s	.Get_up
	move.w	Map_Xcoord,d0		; Blocked ?
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	btst	#Way_blocked_bit,d0
	bne.s	.Exit
	btst	#Blocked_foot_bit,d0	; Blocked for foot ?
	bne.s	.On
	btst	#Blocked_swimming_bit,d0	; Blocked for swimming ?
	beq.s	.Exit
.On:	jsr	Seek_transport_HERE		; Already a transport here ?
	tst.w	d0
	seq	d2
	bra.s	.Exit
.Get_up:	jsr	Seek_transport_HERE		; Any transport here ?
	tst.w	d0
	sne	d2
.Exit:	tst.b	d2
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Seek transport ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Map number (.w)
;  OUT : d0 - Travel mode number / 0 (.w)
;        d1 - Index (.w)
; Changed registers : d0,d1
; NOTE :
;   - From MAP/MAP.S.
;*****************************************************************************
Seek_transport_HERE:
	move.l	d2,-(sp)
	move.w	Map_Xcoord,d0		; Get current location
	move.w	Map_Ycoord,d1
	move.w	Map_nr,d2
	jsr	Seek_transport
	move.l	(sp)+,d2
	rts

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
; [ Check for swimming after a move ]
; All registers are restored
; NOTE :
;   - From [ Game_after_move ] (MAP/MAP.S) : on foot the party swims in
;     the water, and members with a low swimming skill lose LP.
;*****************************************************************************
Check_swimming:
	movem.l	d0-d2/d7/a1,-(sp)
	tst.b	World_map			; 2D world map ?
	beq	.Exit
	move.w	Map_Xcoord,d0		; Swimmable ?
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
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
	bne.s	.No_walk
	tst.b	Swim_status		; Can one still walk here ?
	beq.s	.Done1
	moveq.l	#Swimming,d0		; Swim !
	jsr	Set_new_travel_mode
	bra.s	.Done1
.No_walk:	cmpi.w	#Swimming,Travel_mode	; Swimming ?
	bne.s	.Done1
	tst.b	Swim_status		; Can one still swim here ?
	bne.s	.Done1
	moveq.l	#On_foot,d0		; Walk !
	jsr	Set_new_travel_mode
; ---------- Let the party swim -------------------
.Done1:	cmpi.w	#Swimming,Travel_mode	; Swimming ?
	bne.s	.Exit
	moveq.l	#1,d7
.Loop:	jsr	Get_char_data
	move.w	#Alive_mask,d0		; Alive and kicking ?
	and.w	Body_conditions(a1),d0
	bne.s	.Next
	move.w	SSwimming(a1),d1		; Get swimming skill
	add.w	SSwimming+Magic(a1),d1
	cmp.w	#100,d1
	bpl.s	.Next
	subi.w	#100,d1			; Damage percentage 50%
	neg.w	d1
	asr.w	#1,d1
	tst.w	d1			; Any ?
	bls.s	.Next
	moveq.l	#0,d0			; Do damage !
	move.w	Life_points(a1),d0
	mulu.w	d1,d0
	divu.w	#100,d0
	bne.s	.Not_zero
	moveq.l	#1,d0
.Not_zero:	jsr	Do_damage
.Next:	addq.w	#1,d7			; Next character
	cmpi.w	#6+1,d7
	bmi.s	.Loop
.Exit:	movem.l	(sp)+,d0-d2/d7/a1
	rts

;*****************************************************************************
; [ Display the stationary transports ]
; All registers are restored
; NOTE :
;   - Like [ Display_2D_transport ] (MAP/2D_MAP.S) : the transports of the
;     3x3 submaps around the party which are inside the map window.
;*****************************************************************************
Display_2D_transports:
	movem.l	d0-d7/a0-a2,-(sp)
	tst.b	World_map			; Show transports ?
	beq	.Exit
	lea.l	Trans_data,a2
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a2)		; Anything there ?
	beq.s	.Next
	jsr	Get_transport_cell		; In the map window ?
	bmi.s	.Next
	lsl.w	#4,d0			; Screen coordinates
	addi.w	#Map2D_X,d0
	lsl.w	#4,d1
	addi.w	#Map2D_Y,d1
	moveq.l	#0,d2			; Which graphics ?
	move.b	Trans_type(a2),d2
	lea.l	Stationary_table,a0
	move.b	0(a0,d2.w),d2
	ext.w	d2
	bmi.s	.Next
	lea.l	Stationary_graphics,a0	; Seek graphics
	lea.l	Stationary_dimensions,a1
	bra.s	.Entry
.Skip:	move.w	(a1)+,d5			; Skip graphics
	lsr.w	#4,d5
	mulu.w	(a1)+,d5
	lsl.l	#3,d5
	add.l	d5,a0
.Entry:	dbra	d2,.Skip
	move.w	(a1)+,d6			; Get dimensions
	move.w	(a1)+,d5
	addq.w	#7,d0			; Centre coordinates
	addq.w	#6,d1
	move.w	d6,d2
	lsr.w	#1,d2
	sub.w	d2,d0
	move.w	d5,d2
	lsr.w	#1,d2
	sub.w	d2,d1
	lsr.w	#4,d6			; Display transport
	move.w	d7,-(sp)
	move.w	d5,d7
	jsr	Put_masked_block
	move.w	(sp)+,d7
.Next:	addq.w	#Trans_data_size,a2	; Next transport
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Get the map buffer position of a transport ]
;   IN : a2 - Pointer to transport data (.l)
;  OUT : d0/d1 - Map buffer coordinates (.w)
;        mi - Not in the map window
; Changed registers : d0,d1
Get_transport_cell:
	movem.l	d2-d5,-(sp)
	moveq.l	#-1,d4			; Find submap
.Loop_Y:	moveq.l	#-1,d3
.Loop_X:	move.w	World_X,d0
	add.w	d3,d0
	move.w	World_Y,d1
	add.w	d4,d1
	jsr	Get_world_map_number
	cmp.w	Trans_map_nr(a2),d2		; This one ?
	beq.s	.Found
	addq.w	#1,d3
	cmp.w	#2,d3
	bmi.s	.Loop_X
	addq.w	#1,d4
	cmp.w	#2,d4
	bmi.s	.Loop_Y
	bra.s	.Out
.Found:	moveq.l	#0,d0			; Relative to the party
	move.b	Trans_X(a2),d0
	muls.w	#Submap_size,d3
	add.w	d3,d0
	sub.w	Map_Xcoord,d0
	add.w	Mapbuf_X,d0
	moveq.l	#0,d1
	move.b	Trans_Y(a2),d1
	muls.w	#Submap_size,d4
	add.w	d4,d1
	sub.w	Map_Ycoord,d1
	add.w	Mapbuf_Y,d1
	cmp.w	#Mapbuf_width,d0		; In the window ?
	bcc.s	.Out
	cmp.w	#Mapbuf_height,d1
	bcc.s	.Out
	moveq.l	#0,d2
	bra.s	.Exit
.Out:	moveq.l	#-1,d2
.Exit:	tst.w	d2
	movem.l	(sp)+,d2-d5
	rts

; [ Mark the map buffer positions of the transports and the party ]
;   IN : a0 - Pointer to the sprite cells (.l)
; All registers are restored
; NOTE :
;   - The transports are up to 48x39 pixels, so the 3x4 positions around
;     them are redrawn.
Mark_transport_cells:
	movem.l	d0-d2/d7/a2,-(sp)
	tst.b	World_map
	beq.s	.Exit
	tst.w	Travel_mode		; Party on a transport ?
	beq.s	.No_party
	move.w	Mapbuf_X,d0
	move.w	Mapbuf_Y,d1
	jsr	.Area
.No_party:	lea.l	Trans_data,a2
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a2)
	beq.s	.Next
	jsr	Get_transport_cell
	bmi.s	.Next
	jsr	.Area
.Next:	addq.w	#Trans_data_size,a2
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d0-d2/d7/a2
	rts

; Mark the positions around d0/d1
.Area:	movem.l	d0-d3,-(sp)
	move.w	d1,d3
	subq.w	#2,d1
.Row:	cmp.w	#Mapbuf_height,d1		; (inside ?)
	bcc.s	.Next_row
	move.w	d0,d2
	subq.w	#1,d2
.Col:	cmp.w	#Mapbuf_width,d2
	bcc.s	.Next_col
	move.w	d1,-(sp)
	mulu.w	#Mapbuf_width,d1
	add.w	d2,d1
	st	0(a0,d1.w)
	move.w	(sp)+,d1
.Next_col:	addq.w	#1,d2
	move.w	d0,-(sp)
	addq.w	#1,(sp)
	cmp.w	(sp)+,d2
	ble.s	.Col
.Next_row:	addq.w	#1,d1
	cmp.w	d3,d1
	ble.s	.Row
	movem.l	(sp)+,d0-d3
	rts

;*****************************************************************************
; [ Transport merchant ]
; NOTE :
;   - From [ MerchTRANS_ModInit ], [ MerchTRANS_CIL_evaluate ] and
;     [ Buy_transport ] (PLACES.S).
;*****************************************************************************
MerchTRANS_place_init:
	move.l	Place_ptr,a0		; Get transport price/type
	move.w	Trans_price(a0),d1
	move.w	Newtrans_X(a0),d2
	move.w	Newtrans_Y(a0),d3
	move.w	Newtrans_map_nr(a0),d4
	move.w	Newtrans_type(a0),d5
	move.w	#One_or_many_mask,d0	; One or many ?
	btst	d5,d0
	beq.s	.One
	jsr	Count_members		; But how many ?
	mulu.w	d0,d1			; Calculate total price
.One:	move.w	d1,Total_price		; Store
	move.w	d2,d0			; Already a transport ?
	move.w	d3,d1
	move.w	d4,d2
	jsr	Seek_transport
	tst.w	d0			; Well ?
	sne	Transport_created
	lea.l	Trans_data,a0		; Seek free slot
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a0)		; Anything there ?
	beq.s	.Done
	addq.w	#Trans_data_size,a0	; Next transport
	dbra	d7,.Loop
	st	Transport_created		; Prohibit !
.Done:	lea.l	MerchTRANS_icon_table,a0	; Insert control icon
	add.w	Current_place_type,a0
	moveq.l	#0,d0
	move.b	(a0),d0
	lea.l	MerchTRANS_CIL,a0
	move.w	d0,6(a0)
	jmp	Enter_place

MerchTRANS_CIL_evaluate:
	tst.b	Transport_created		; Already full ?
	bne.s	.Off
	move.w	Current_gold,d0		; Enough dough ?
	cmp.w	Total_price,d0
	bpl.s	.Ok
.Off:	bset	#7,6(a0)			; Disable {Buy transport}
.Ok:	rts

Buy_transport:
	lea.l	MerchTRANS_prompt_table,a0	; Get prompt number
	add.w	Current_place_type,a0
	moveq.l	#0,d0
	move.b	(a0),d0
	move.w	Total_price,d1		; Are you sure ?
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq	.Exit
	st	Success			; Success !
	lea.l	Current_event_data,a5	; Get sold text number
	moveq.l	#0,d0
	move.b	Event_b5(a5),d0
	cmp.b	#-1,d0			; Any ?
	beq.s	.None
	jsr	Lay3_text			; Yes -> Show
.None:	move.l	Place_ptr,a0		; Get transport data
	move.w	Newtrans_X(a0),d0
	move.w	Newtrans_Y(a0),d1
	move.w	Newtrans_map_nr(a0),d2
	move.w	Newtrans_type(a0),d3
	lea.l	Trans_data,a0		; Seek free slot
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a0)		; Anything there ?
	bne.s	.Next
	move.b	d0,Trans_X(a0)		; Set coordinates
	move.b	d1,Trans_Y(a0)
	move.w	d2,Trans_map_nr(a0)		; Set map number
	move.b	d3,Trans_type(a0)		; Set transport type
	bra.s	.No
.Next:	addq.w	#Trans_data_size,a0	; Next transport
	dbra	d7,.Loop
.No:	move.w	Total_price,d0		; Remove gold
	sub.w	d0,Current_gold
	st	Transport_created		; Prohibit
	jsr	Update_place_gold
.Exit:	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

Travel_speed:					; (KERNEL/DATA.S)
	dc.b 1,2,1,3,1,5,$ff,1,3,2,3
	even
Stationary_table:				; (MAP/2D_MAP.S)
	dc.b -1,0,1,2,-1,-1,-1,-1,-1,3,4
	even
Stationary_dimensions:			; (KERNEL/DATA.S)
	dc.w 32,22,32,11,48,34,48,21,48,39
Stationary_size	EQU	(2*22+2*11+3*34+3*21+3*39)*8

MerchTRANS_CIL:
	dc.w 0,0,Exit_cicon
	dc.w 0,0,0			; Icon will be inserted
	dc.w 0,0,0
	dc.l 0,0,Exit_PLACES
	dc.l 0,Buy_transport,0
	dc.l 0,0,0
	dc.l MerchTRANS_CIL_evaluate
MerchTRANS_icon_table:			; CIL buy transport icons
	dc.b 0,0,0,0
	dc.b 0,0,0,0
	dc.b Buy_raft_cicon,Buy_ship_cicon,Buy_horse_cicon,0
	dc.b 0,0,0,0
MerchTRANS_prompt_table:			; Buy selector prompt numbers
	dc.b 0,0,0,0
	dc.b 0,0,0,0
	dc.b 152,153,154,0
	dc.b 0,0,0,0

	SECTION	Fast_BSS,bss
Time_warp:	ds.w 1
Icons_redraw:	ds.w 1			; Redraw the control icons
Swim_status:	ds.b 1
Transport_created:	ds.b 1
	even
Stationary_graphics:	ds.b Stationary_size
