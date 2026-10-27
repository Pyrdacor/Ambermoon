; Proof of concept : persons (NPCs) and time on 2D maps (Atari ST)
;
; Taken from PERSONS.S, TIME.S, MAP/MAP.S and MAIN.S of the original source,
; without the memory manager (the map data is in Map_data_buffer). Monsters
; which see the party hunt it; when a monster reaches the party, a combat is
; requested (see COMBAT.S).

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
	sf	Big_brother_flag
	tst.w	Monster_move_delay		; Waiting ?
	beq.s	.Zero
	subq.w	#1,Monster_move_delay	; Yes
; ---------- Update NPC positions -----------------
.Zero:	lea.l	VNPC_data,a1
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
	bne.s	.Person
	btst	#2,d0			; Hunt or stay ?
	beq.s	.Stay
	jsr	Hunting_monster_2D		; Handle hunting monster
.Stay:	jsr	Battle_check
	bra.s	.Next1
.Person:	btst	#2,d0			; Path or random ?
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
; [ Check for combat with a monster ]
;   IN : d7 - NPC index {0...31} (.w)
;        a1 - Pointer to NPC data (.l)
; All registers are restored
; NOTE :
;   - From PERSONS.S (always on foot).
;*****************************************************************************
Battle_check:
	movem.l	d0/d1,-(sp)
	move.w	Travel_mode,d0		; Vulnerable ?
	move.w	#Combat_mask,d1
	btst	d0,d1
	beq.s	.Exit
	move.w	VMap_X(a1),d0		; Get coordinates
	move.w	VMap_Y(a1),d1
	cmp.w	Map_Xcoord,d0		; X the same ?
	bne.s	.Exit
	cmp.w	Map_Ycoord,d1		; Y the same ?
	bne.s	.Exit
	st	Big_brother_flag		; Gaze!
	tst.w	Monster_move_delay		; Waiting ?
	bne.s	.Exit
	moveq.l	#0,d0			; Get monstergroup number
	move.b	NPC_char_nr(a1),d0
	move.w	d0,Monstergroup_nr		; Set info
	move.w	d7,Combat_char_index
	st	Combat_req		; Activate requester
.Exit:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Hunting monster movement routine (2D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
; NOTE :
;   - From PERSONS.S.
;*****************************************************************************
Hunting_monster_2D:
	movem.l	d0-d6,-(sp)
	move.w	VMap_X(a1),d0		; Get position
	move.w	VMap_Y(a1),d1
	jsr	Check_line_of_sight		; Check line of sight
	beq	.Visible
	tst.w	Monster_move_delay		; Waiting ?
	bne	.Exit
	tst.b	New_step			; Update position ?
	beq	.Exit
	btst	#0,VFlags(a1)		; Moving at random ?
	bne.s	.Not_random
	jsr	Random_person_2D
	bra	.Exit
.Not_random:
	move.w	VDir(a1),d2		; Get direction
	jsr	Move_in_direction
	jsr	Monster_movement_check
	beq	.Move
	bclr	#0,VFlags(a1)		; Random movement
	clr.w	VPathlen(a1)		; Force new path
	jsr	Random_person_2D
	bra	.Exit
.Visible:	st	Big_brother_flag		; Gaze!
	tst.w	Monster_move_delay		; Waiting ?
	bne	.Exit
	ori.b	#3,VFlags(a1)		; Set bit 0 & 1
	tst.b	New_step			; Update position ?
	bne.s	.Ok
	tst.b	New_move
	beq	.Exit
.Ok:	move.w	d0,d2			; Duplicate coordinates
	move.w	d1,d3
	sub.w	Map_Xcoord,d2		; Calculate dX & dY
	sub.w	Map_Ycoord,d3
	move.w	d2,d4
	bpl.s	.Pos1
	neg.w	d4
.Pos1:	move.w	d3,d5
	bpl.s	.Pos2
	neg.w	d5
.Pos2:	ext.l	d2			; Mega SGN function
	beq.s	.Zero1
	swap.w	d2
	bmi.s	.Zero1
	moveq.l	#1,d2
.Zero1:	ext.l	d3			; Mega SGN function
	beq.s	.Zero2
	swap.w	d3
	bmi.s	.Zero2
	moveq.l	#1,d3
.Zero2:	sub.w	d5,d4			; dX - dY
	ext.l	d4			; Mega SGN function
	beq.s	.Zero3
	swap.w	d4
	bmi.s	.Zero3
	moveq.l	#1,d4
.Zero3:	neg.w	d2			; Invert
	neg.w	d3
	addq.w	#1,d2			; Calculate index
	addq.w	#1,d3
	addq.w	#1,d4
	add.w	d3,d2
	add.w	d3,d3
	add.w	d3,d2
	move.w	d4,d3
	lsl.w	#3,d3
	add.w	d3,d2
	add.w	d4,d2
	add.w	d2,d2			; Get direction priorities
	add.w	d2,d2
	move.l	.Dir_table(pc,d2.w),d2
	bmi	.Move
	move.w	d0,d4			; Copy coordinates
	move.w	d1,d5
	rol.l	#8,d2			; Get 1st direction
	tst.b	d2
	bmi.s	.No_move2
	jsr	Move_in_direction		; Try move
	jsr	Monster_movement_check
	beq.s	.Move
	move.w	d4,d0			; Restore coordinates
	move.w	d5,d1
	rol.l	#8,d2			; Get 2nd direction
	tst.b	d2
	bmi.s	.No_move2
	jsr	Move_in_direction		; Try move
	jsr	Monster_movement_check
	beq.s	.Move
	move.w	d4,d0			; Restore coordinates
	move.w	d5,d1
	rol.l	#8,d2			; Get 3rd direction
	tst.b	d2
	bmi.s	.No_move2
	jsr	Move_in_direction		; Try move
	jsr	Monster_movement_check
	beq.s	.Move
.No_move2:	bra.s	.Exit
.Move:	move.w	d0,VMap_X(a1)		; Store new coordinates
	move.w	d1,VMap_Y(a1)
	andi.w	#$00ff,d2			; Store direction
	move.w	d2,VDir(a1)
.Exit:	movem.l	(sp)+,d0-d6
	rts

.Dir_table:
	dc.l $00030100,$00030100,$00010300	; dX < dY
	dc.l $03000200,-1,$01000200
	dc.l $02030100,$02010300,$02010300
	dc.l $0003ff00,-1,$0001ff00		; dX = dY
	dc.l -1,-1,-1
	dc.l $0203ff00,-1,$0201ff00
	dc.l $03000200,$00030100,$01000200	; dX > dY
	dc.l $03000200,-1,$01000200
	dc.l $03020000,$02030100,$01020000

; [ Movement check for monsters ]
;   IN : d0/d1 - Coordinates (.w)
;        a1 - Pointer to NPC data (.l)
;  OUT : eq - Possible, ne - Not possible
; All registers are restored
; NOTE :
;   - Like [ NPC_movement_check_2D ], but monsters may go to the party.
Monster_movement_check:
	cmp.w	Map_Xcoord,d0
	bne	NPC_movement_check_2D
	cmp.w	Map_Ycoord,d1
	bne	NPC_movement_check_2D
	rts

;*****************************************************************************
; [ Check if the party is in a monster's line of sight ]
;   IN : a1 - Pointer to NPC data (.l)
;  OUT : eq - In line of sight, ne - NOT in line of sight
; All registers are restored
; NOTE :
;   - From PERSONS.S.
;*****************************************************************************
Check_line_of_sight:
	movem.l	d0-d7,-(sp)
	move.w	VMap_X(a1),d0		; Get monster's absolute
	move.w	VMap_Y(a1),d1		;  coordinates
	move.w	d0,d4			; Calculate monster's
	move.w	d1,d5			;  relative coordinates
	sub.w	Map_Xcoord,d4
	sub.w	Map_Ycoord,d5
	tst.w	d4			; Same location ?
	bne.s	.Notzero
	tst.w	d5
	beq	.Seen
.Notzero:	move.w	d4,d2			; Mega SGN function
	ext.l	d2
	beq.s	.Zero1
	swap.w	d2
	bmi.s	.Zero1
	moveq.l	#1,d2
.Zero1:	move.w	d5,d3			; Mega SGN function
	ext.l	d3
	beq.s	.Zero2
	swap.w	d3
	bmi.s	.Zero2
	moveq.l	#1,d3
.Zero2:	neg.w	d2			; Reverse
	neg.w	d3
	tst.w	d4			; Calculate dX
	bpl.s	.No_abs1
	neg.w	d4
.No_abs1:	tst.w	d5			; Calculate dY
	bpl.s	.No_abs2
	neg.w	d5
.No_abs2:	cmp.w	d5,d4			; dY > dX ?
	bmi.s	.dYdX
; ---------- dY =< dX -----------------------------
	move.w	d4,d6			; Initialize Bresenham
	lsr.w	#1,d6			;  variable
	move.w	d4,d7			; dX = counter
	subq.w	#1,d7			; One less
	bmi	.Not2			; Exit if zero
	bra.s	.Entry1
.Again1:	move.l	d0,-(sp)			; Vision blocked ?
	jsr	Get_location_status
	btst	#Vision_blocked_bit,d0
	bne.s	.Not
	move.l	(sp)+,d0
.Entry1:	add.w	d5,d6			; Trace line
	cmp.w	d4,d6
	bmi.s	.Skip1
	sub.w	d4,d6
	add.w	d3,d1			; Update Y
.Skip1:	add.w	d2,d0			; Update X
	dbra	d7,.Again1		; Next
	bra.s	.Seen
; ---------- dY > dX ------------------------------
.dYdX:	move.w	d5,d6			; Initialize Bresenham
	lsr.w	#1,d6			;  variable
	move.w	d5,d7			; dY = counter
	subq.w	#1,d7			; One less
	bmi.s	.Not2			; Exit if zero
	bra.s	.Entry2
.Again2:	move.l	d0,-(sp)			; Vision blocked ?
	jsr	Get_location_status
	btst	#Vision_blocked_bit,d0
	bne.s	.Not
	move.l	(sp)+,d0
.Entry2:	add.w	d4,d6			; Trace line
	cmp.w	d5,d6
	bmi.s	.Skip2
	sub.w	d5,d6
	add.w	d2,d0			; Update X
.Skip2:	add.w	d3,d1			; Update Y
	dbra	d7,.Again2		; Next
.Seen:	moveq.l	#0,d0			; Peek a boo !
	bra.s	.Exit
.Not:	move.l	(sp)+,d0			; Stack correction
.Not2:	moveq.l	#-1,d0			; Where are you ?
.Exit:	tst.b	d0			; Get zero flag
	movem.l	(sp)+,d0-d7
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
	cmp.w	#1000,Camp_counter		; Hours since the last camp
	bpl.s	.Max
	addq.w	#1,Camp_counter
.Max:	move.w	Hour,d0			; Update hour
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
	tst.b	World_map			; (world map : travel speed)
	beq.s	.Count
	move.w	Time_warp,d0
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
Camp_counter:	ds.w 1			; Hours since last camp
New_step:	ds.b 1
Big_brother_flag:	ds.b 1			; Monster sees the party
New_move:	ds.b 1
Collision:	ds.b 1
	even
VNPC_data:	ds.b Max_chars*VNPC_data_size
Persons_buffer:	ds.b Mapbuf_width*(Mapbuf_height+1)
	even
