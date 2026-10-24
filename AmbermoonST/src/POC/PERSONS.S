; Proof of concept : persons (NPCs) and time on 2D maps (Atari ST)
;
; Taken from PERSONS.S, TIME.S, MAP/MAP.S and MAIN.S of the original source,
; without monsters (they stay where they are), combat, events and the memory
; manager (the map data is in Map_data_buffer).

	SECTION	Program,code

;*****************************************************************************
; [ Calculate offsets to map data ]
; All registers are restored
; NOTE :
;   - From MAP/MAP.S (only the NPC path base offset is needed).
;*****************************************************************************
Calculate_map_data_offsets:
	movem.l	d0/d1/a0,-(sp)
	lea.l	Map_data_buffer,a0
	move.l	#Map_data,d0		; Start at underlay layer
	move.w	Width_of_map,d1		; 2D -> 4 bytes/square
	mulu.w	Height_of_map,d1
	lsl.l	#2,d1
	add.l	d1,d0
	moveq.l	#0,d1			; Skip event entry list
	move.w	0(a0,d0.l),d1
	addq.l	#2,d0
	add.l	d1,d1
	add.l	d1,d0
	move.w	0(a0,d0.l),d1		; Skip event data
	addq.l	#2,d0
	mulu.w	#Event_data_size,d1
	add.l	d1,d0
	move.l	d0,NPC_path_base_offset	; Store offset
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Initialize persons (2D map) ]
; All registers are restored
; NOTE :
;   - From PERSONS.S.
;*****************************************************************************
Init_persons_2D:
	movem.l	d0/d1/d6/d7/a0-a3,-(sp)
	lea.l	Map_data_buffer,a0		; Copy NPC data
	move.l	a0,a2
	move.l	a0,a3
	lea.l	NPC_data(a0),a0
	add.l	NPC_path_base_offset,a2
	lea.l	VNPC_data,a1
	moveq.l	#0,d7
.Loop1:	clr.b	NPC_char_nr(a1)		; Default = absent
	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq	.Next1
	movem.l	a0/a1,-(sp)		; Copy data (unaligned)
	moveq.l	#NPC_data_size-1,d6
.Loop2:	move.b	(a0)+,(a1)+
	dbra	d6,.Loop2
	movem.l	(sp)+,a0/a1
	clr.w	VPathlen(a1)		; Clear path length
	move.b	NPC_status_bits(a1),d0	; What is it ?
	move.b	d0,d1
	andi.b	#$03,d1
	cmp.b	#2,d1			; Monster or person ?
	beq.s	.No_path
	btst	#2,d0			; Path or random ?
	bne.s	.No_path
	move.l	a2,d0			; Store offset
	sub.l	a3,d0
	move.l	d0,VPath_ptr(a1)
	lea.l	Max_steps*2(a2),a2		; Skip
	bra.s	.Next1
.No_path:	moveq.l	#0,d0			; Copy start position
	move.b	(a2)+,d0
	move.w	d0,VMap_X(a1)
	move.b	(a2)+,d0
	move.w	d0,VMap_Y(a1)
.Next1:	lea.l	NPC_data_size(a0),a0	; Next NPC
	lea.l	VNPC_data_size(a1),a1
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop1
	move.w	#-1,Current_NPC
	movem.l	(sp)+,d0/d1/d6/d7/a0-a3
	rts

;*****************************************************************************
; [ NPC manager (2D map) ]
; All registers are restored
; NOTE :
;   - From PERSONS.S. This routine updates the positions of all NPC's in
;     the current map. Then the NPC's are inserted in a map buffer.
;*****************************************************************************
NPC_manager_2D:
	movem.l	d0/d1/d6/d7/a1/a2,-(sp)
; ---------- Update NPC positions -----------------
	lea.l	VNPC_data,a1
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop1:	tst.b	NPC_char_nr(a1)		; Anyone there ?
	beq.s	.Next1
	btst	d7,d6			; Not removed ?
	bne.s	.Next1
	move.b	NPC_status_bits(a1),d0	; What is it ?
	move.b	d0,d1
	andi.b	#$03,d1
	cmp.b	#2,d1			; Monster or person ?
	beq.s	.Next1			; (monsters are not handled)
	btst	#2,d0			; Path or random ?
	beq.s	.Path
	jsr	Random_person_2D		; Handle random person
	bra.s	.Next1
.Path:	jsr	Path_person_2D		; Handle person on a path
.Next1:	lea.l	VNPC_data_size(a1),a1	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop1
; ---------- Insert NPC's in map buffer -----------
	lea.l	VNPC_data,a1
	lea.l	Persons_buffer,a2
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop2:	tst.b	NPC_char_nr(a1)		; Anyone there ?
	beq.s	.Next2
	btst	d7,d6			; Not removed ?
	bne.s	.Next2
	move.w	VMap_X(a1),d0		; Get coordinates
	move.w	VMap_Y(a1),d1
	tst.w	d0			; Visible ?
	bne.s	.Show
	tst.w	d1
	beq.s	.Next2
.Show:	sub.w	Map_Xcoord,d0		; Calculate buffer coordinates
	sub.w	Map_Ycoord,d1
	add.w	Mapbuf_X,d0
	add.w	Mapbuf_Y,d1
	cmpi.w	#Mapbuf_width-1,d0		; In map window ?
	bhi.s	.Next2
	cmpi.w	#Mapbuf_height,d1
	bhi.s	.Next2
	mulu.w	#Mapbuf_width,d1		; Insert
	add.w	d0,d1
	moveq.l	#0,d0
	move.b	d7,d0
	addq.w	#1,d0
	move.b	d0,0(a2,d1.w)
.Next2:	lea.l	VNPC_data_size(a1),a1	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop2
	sf	New_step			; Clear flags
	sf	New_move
	movem.l	(sp)+,d0/d1/d6/d7/a1/a2
	rts

;*****************************************************************************
; [ Clear persons buffer ]
; All registers are restored
;*****************************************************************************
Clear_persons_buffer:
	movem.l	d7/a0,-(sp)
	lea.l	Persons_buffer,a0
	moveq.l	#Mapbuf_width*(Mapbuf_height+1)-1,d7
.Loop:	clr.b	(a0)+
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Check if movement is possible for NPC (2D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;        a1 - Pointer to NPC data (.l)
;  OUT :     Zero - Movement possible
;        Non-zero - Movement impossible
; All registers are restored
; NOTE :
;   - From PERSONS.S.
;*****************************************************************************
NPC_movement_check_2D:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	st	Collision			; Default
; ---------- Check out-of-map collision -----------
	cmp.w	#1,d0			; X too low ?
	blt	.Exit
	cmp.w	Width_of_map,d0		; X too high ?
	bgt	.Exit
	cmp.w	#1,d1			; Y too low ?
	blt	.Exit
	cmp.w	Height_of_map,d1		; Y too high ?
	bgt	.Exit
; ---------- Check if the party is there ----------
; (added : in the Amiga version this is checked elsewhere)
	cmp.w	Map_Xcoord,d0
	bne.s	.No_party
	cmp.w	Map_Ycoord,d1
	beq	.Exit
.No_party:
; ---------- Check if another NPC is present ------
	lea.l	VNPC_data,a0		; Check NPC's
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop1:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq.s	.Next1
	cmpa.l	a0,a1			; Is I ?
	beq.s	.Next1
	btst	d7,d6			; Deleted ?
	bne.s	.Next1
	cmp.w	VMap_X(a0),d0		; Same coordinates ?
	bne.s	.Next1
	cmp.w	VMap_Y(a0),d1
	beq	.Exit
.Next1:	lea.l	VNPC_data_size(a0),a0	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop1
; ---------- Check cheat mode ---------------------
	cmpi.b	#Super_chicken,NPC_travel_mode(a1)	; Cheat mode ?
	bne.s	.Normal
	sf	Collision			; No collision
	bra	.Exit
; ---------- Check if target square is blocked ----
.Normal:	jsr	Get_location_status		; Get location status
	moveq.l	#0,d1			; Get travel mode
	move.b	NPC_travel_mode(a1),d1
	add.w	#Blocked_foot_bit,d1
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Exit
	btst.l	d1,d0			; Way blocked for current
	seq	Collision			;  travel mode ?
.Exit:	tst.b	Collision			; Get zero flag
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

;*****************************************************************************
; [ Person on a path movement routine (2D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
; NOTE :
;   - From PERSONS.S.
;*****************************************************************************
Path_person_2D:
	movem.l	d0/d1/a0,-(sp)
	lea.l	Map_data_buffer,a0		; Get pointer to path
	adda.l	VPath_ptr(a1),a0
	move.w	Current_step,d0		; Get position
	add.w	d0,d0
	add.w	d0,a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.w	d0,VMap_X(a1)		; Store
	move.w	d1,VMap_Y(a1)
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Random NPC movement routine (2D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
; NOTE :
;   - From PERSONS.S.
;*****************************************************************************
Random_person_2D:
	movem.l	d0-d2/d7,-(sp)
	tst.b	New_step			; Update position ?
	beq	.Exit
	tst.w	VPathlen(a1)		; End of path ?
	bne.s	.Loop
	moveq.l	#4-1,d7			; Try four times
	bra.s	.Entry
.Loop:	move.w	VMap_X(a1),d0		; Get position
	move.w	VMap_Y(a1),d1
	move.w	VDir(a1),d2		; Update position
	jsr	Move_in_direction
	jsr	NPC_movement_check_2D	; Possible ?
	beq.s	.Move
.Entry:	jsr	Choose_random_path_2D	; Choose new path
	dbra	d7,.Loop
	clr.w	VPathlen(a1)		; End of path
	bra.s	.Exit
.Move:	subq.w	#1,VPathlen(a1)		; Count down
	move.w	d0,VMap_X(a1)		; Store new coordinates
	move.w	d1,VMap_Y(a1)
.Exit:	movem.l	(sp)+,d0-d2/d7
	rts

;*****************************************************************************
; [ Choose random path (2D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
; NOTE :
;   - From PERSONS.S.
;*****************************************************************************
Choose_random_path_2D:
	movem.l	d0-d2/a0,-(sp)
	jsr	Random			; Choose random path length
	moveq.l	#$3,d1
	and.w	d0,d1
	addq.w	#1,d1
	move.w	VDir(a1),d2		; Get current direction
	addq.w	#1,d2			; Rotate counter-clockwise
	andi.w	#$0003,d2
	jsr	Random			; Make random full turn
	andi.w	#$0002,d0
	add.w	d0,d2
	andi.w	#$0003,d2
	move.w	d2,VDir(a1)		; Store
	add.w	d2,d2			; Check path length
	add.w	d2,d2
	movea.l	.Pathcheck(pc,d2.w),a0
	jsr	(a0)
	move.w	d1,VPathlen(a1)		; Store
	movem.l	(sp)+,d0-d2/a0
	rts

.Pathcheck:	dc.l .Up,.Right,.Down,.Left

; Path check routines
;   IN : d1 - Path length (.w)
;        a1 - Pointer to virtual NPC data (.l)
; Changed registers : d0,d1

.Up:	move.w	VMap_Y(a1),d0		; Check path length
	sub.w	d1,d0
	bmi.s	.Up_exit			; Ok ?
	subq.w	#1,d0			; Adjust
	add.w	d0,d1
.Up_exit:	rts

.Right:	move.w	Width_of_map,d0		; Check path length
	sub.w	VMap_X(a1),d0
	sub.w	d1,d0
	bpl.s	.Right_exit		; Ok ?
	add.w	d0,d1			; Adjust
.Right_exit:	rts

.Down:	move.w	Height_of_map,d0		; Check path length
	sub.w	VMap_Y(a1),d0
	sub.w	d1,d0
	bpl.s	.Down_exit		; Ok ?
	add.w	d0,d1			; Adjust
.Down_exit:	rts

.Left:	move.w	VMap_X(a1),d0		; Check path length
	sub.w	d1,d0
	bmi.s	.Left_exit		; Ok ?
	subq.w	#1,d0			; Adjust
	add.w	d0,d1
.Left_exit:	rts

;*****************************************************************************
; [ Move in one of 4 directions ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Direction {0=N, 1=E, 2=S, 3=W} (.w)
;  OUT : d0 - New X-coordinate (.w)
;        d1 - New Y-coordinate (.w)
; Changed registers : d0,d1
; NOTE :
;   - From MAIN.S.
;*****************************************************************************
Move_in_direction:
	movem.l	d2/a0,-(sp)
	lea.l	Dir_offset,a0		; Get offsets
	andi.w	#$0003,d2
	add.w	d2,d2
	add.w	d2,a0
	move.b	(a0)+,d2			; Update X
	ext.w	d2
	add.w	d2,d0
	move.b	(a0),d2			; Update Y
	ext.w	d2
	add.w	d2,d1
	movem.l	(sp)+,d2/a0
	rts

;*****************************************************************************
; [ Initialize time ]
; All registers are restored
; NOTE :
;   - From TIME.S.
;*****************************************************************************
Init_time:
	movem.l	d0/d1,-(sp)
	move.w	Hour,d0			; Calculate current step
	mulu.w	#Minutes_per_hour,d0
	moveq.l	#0,d1
	move.w	Minute,d1
	add.l	d1,d0
	divu.w	#Minutes_per_step,d0
	move.w	d0,Current_step
	move.w	#Moves_per_step,Move_count
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Update time (next step) ]
; All registers are restored
; NOTE :
;   - From TIME.S (only minutes and hours).
;*****************************************************************************
Update_time:
	move.l	d0,-(sp)
	st	New_step			; Signal
	addq.w	#1,Current_step		; Update current step
	move.w	Minute,d0			; Update minute
	addi.w	#Minutes_per_step,d0
	move.w	d0,Minute
	subi.w	#Minutes_per_hour,d0	; Next hour ?
	bmi	.Exit
	move.w	d0,Minute
	move.w	Hour,d0			; Update hour
	addq.w	#1,d0
	move.w	d0,Hour
	subi.w	#Hours_per_day,d0		; Next day ?
	bmi	.Exit
	move.w	d0,Hour
	move.w	#0,Current_step		; Reset current step
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Real-time step update ]
; Called by the vertical blank interrupt.
; All registers are restored
; NOTE :
;   - From TIME.S.
;*****************************************************************************
Realtime:
	move.l	d0,-(sp)
	move.w	Frame,d0			; Next frame
	addq.w	#1,d0
	move.w	d0,Frame
	cmpi.w	#VBLs_per_step,d0		; Next step ?
	bmi.s	.Exit
	move.w	Realtime_step,d0		; Force next step
	addq.w	#1,d0
	cmp.w	#4,d0
	bpl.s	.Skip
	move.w	d0,Realtime_step
.Skip:	clr.w	Frame
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Handle real-time steps ]
; All registers are restored
; NOTE :
;   - From [ Map_DisUpd ] (MAP/MAP.S), [ Zzz ] is [ Update_time ].
;*****************************************************************************
Handle_realtime_steps:
	move.l	d0,-(sp)
	move.w	Realtime_step,d0		; Repeat
	bra.s	.Entry
.Loop:	move.w	d0,Realtime_step
	jsr	Update_time
.Entry:	dbra	d0,.Loop
	clr.w	Realtime_step
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Time logic after movement ]
; All registers are restored
; NOTE :
;   - From MAP/MAP.S.
;*****************************************************************************
Time_after_move:
	move.l	d0,-(sp)
	st	New_move			; New move for NPC's
	clr.w	Frame			; Reset real-time step counter
	move.w	Move_count,d0		; Count down
	dbra	d0,.Count
	jsr	Update_time		; 1 step per {x} moves
	moveq.l	#Moves_per_step,d0
.Count:	move.w	d0,Move_count		; Store counter
	move.l	(sp)+,d0
	rts

	SECTION	Fast_DATA,data
Dir_offset:	dc.b 0,-1,1,0,0,1,-1,0	; NESW
	even

	SECTION	Fast_BSS,bss
NPC_path_base_offset:	ds.l 1
CD_value:	ds.l 1
Current_NPC:	ds.w 1
Current_step:	ds.w 1
Hour:	ds.w 1
Minute:	ds.w 1
Frame:	ds.w 1
Realtime_step:	ds.w 1
Move_count:	ds.w 1
New_step:	ds.b 1
New_move:	ds.b 1
Collision:	ds.b 1
	even
VNPC_data:	ds.b Max_chars*VNPC_data_size
Persons_buffer:	ds.b Mapbuf_width*(Mapbuf_height+1)
	even
