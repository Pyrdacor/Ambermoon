; Persons handling
; Written by J.Horneman (In Tune With The Universe)
; Start : 28-10-1992

	SECTION	Program,code
;*****************************************************************************
; [ Initialize persons (2D map) ]
; All registers are restored
;*****************************************************************************
Init_persons_2D:
	movem.l	d0/d1/d6/d7/a0-a3,-(sp)
	jsr	Get_CD_value
	clr.w	Monster_move_delay
	Get	Mapdata_handle,a0		; Copy NPC data
	move.l	a0,a2
	move.l	a0,a3
	lea.l	NPC_data(a0),a0
	add.l	NPC_path_base_offset,a2
	lea.l	VNPC_data,a1
	moveq.l	#0,d7
.Loop1:	clr.b	NPC_char_nr(a1)		; Default = absent
	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq	.Next1
	movem.l	a0/a1,-(sp)		; Copy data
	moveq.l	#NPC_data_size/2-1,d6
.Loop2:	move.w	(a0)+,(a1)+
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
	Free	Mapdata_handle
	movem.l	(sp)+,d0/d1/d6/d7/a0-a3
	rts

;*****************************************************************************
; [ Initialize persons (3D map) ]
; All registers are restored
;*****************************************************************************
Init_persons_3D:
	movem.l	d0/d1/d6/d7/a0-a6,-(sp)
	jsr	Get_CD_value
	clr.w	Monster_move_delay
	lea.l	VNPC_data,a0		; Clear internal NPC data
	moveq.l	#0,d0
	move.w	#((VNPC_data_size*Max_chars)/2)-1,d7
.Loop1:	move.w	d0,(a0)+
	dbra	d7,.Loop1
	Get	Mapdata_handle,a0		; Copy NPC data
	move.l	a0,a2
	move.l	a0,a3
	lea.l	NPC_data(a0),a0
	add.l	NPC_path_base_offset,a2
	lea.l	VNPC_data,a1
	Get	Labdata_handle,a4
	moveq.l	#0,d7
.Loop2:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq	.Next2
	movem.l	a0/a1,-(sp)		; Copy data
	moveq.l	#NPC_data_size/2-1,d6
.Loop3:	move.w	(a0)+,(a1)+
	dbra	d6,.Loop3
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
	move.w	#1,VMap_X(a1)		; Clear position
	move.w	#1,VMap_Y(a1)
	bra.s	.Next2
.No_path:	moveq.l	#0,d0			; Copy start position
	move.b	(a2)+,d0
	move.w	d0,VMap_X(a1)
	move.b	(a2)+,d0
	move.w	d0,VMap_Y(a1)
.Next2:	move.w	VMap_X(a1),d0		; Set positions
	move.w	VMap_Y(a1),d1
	move.w	d0,VTarget_X(a1)
	move.w	d1,VTarget_Y(a1)
	jsr	Map_to_dungeon
	move.w	d0,VSource_X(a1)
	move.w	d1,VSource_Y(a1)
	bset	#Movement_ended,VFlags(a1)	; End of movement
	move.w	NPC_icon_nr(a1),d0		; Get object group data
	subq.w	#1,d0
	mulu.w	#Objectgroup3D_data_size,d0
	lea.l	Lab_data+4(a4,d0.w),a5
	moveq.l	#Objects_per_group-1,d1	; Do each object in group
.Loop4:	move.w	Object_nr(a5),d0		; Anything there ?
	beq.s	.Next4
	move.l	a4,a6			; Get object data
	adda.l	Object_data_offset,a6
	subq.w	#1,d0
	mulu.w	#Object3D_data_size,d0
	move.l	Object_bits(a6,d0.w),d0	; Get object bits
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Blocks
	btst.l	#Blocked_foot_bit,d0	; Way possible for current
	bne.s	.Next4			;  travel mode ?
.Blocks:	bset	#NPC_blocks,VFlags(a1)	; No -> NPC blocks !
	bra.s	.Done
.Next4:	addq.w	#Objectingroup_data_size,a5	; Next object in
	dbra	d1,.Loop4				;  group
.Done:	lea.l	NPC_data_size(a0),a0	; Next NPC
	lea.l	VNPC_data_size(a1),a1
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi	.Loop2
	Free	Labdata_handle
	Free	Mapdata_handle
	movem.l	(sp)+,d0/d1/d6/d7/a0-a6
	rts

;*****************************************************************************
; [ NPC manager (2D map) ]
; All registers are restored
; Notes :
;  - This routine updates the positions of all NPC's in the current
;    map and checks if combat should be started. Then the NPC's are inserted
;    in a map buffer.
;*****************************************************************************
NPC_manager_2D:
	movem.l	d0/d1/d6/d7/a1/a2,-(sp)
	jsr	Get_CD_value		; Updated at all times !
	sf	Big_brother_flag
	tst.w	Monster_move_delay		; Waiting ?
	beq	.Zero
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
	bne.s	.Hunt
	jsr	Battle_check		; Handle staying monster
	bra.s	.Next1
.Hunt:	jsr	Hunting_monster_2D		; Handle hunting monster
	jsr	Battle_check
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
; [ NPC manager (3D map) ]
; All registers are restored
;*****************************************************************************
NPC_manager_3D:
	movem.l	d0-d3/d6/d7/a1,-(sp)
	jsr	Get_CD_value		; Updated at all times !
	sf	Big_brother_flag
	tst.w	Monster_move_delay		; Waiting ?
	beq	.Zero
	subq.w	#1,Monster_move_delay	; Yes
; ---------- Update NPC target locations ----------
.Zero:	lea.l	VNPC_data,a1
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop1:	tst.b	NPC_char_nr(a1)		; Anyone there ?
	beq	.Next1
	btst	d7,d6			; Not removed ?
	bne	.Next1
	bclr	#NPC_collided,VFlags(a1)	; Clear
	move.b	NPC_status_bits(a1),d0	; What is it ?
	moveq.l	#3,d1
	and.b	d0,d1
	cmp.b	#Monster_type,d1		; Monster ?
	bne.s	.Person
	btst	#2,d0			; Yes -> Hunt or stay ?
	bne.s	.Hunt
	jsr	Battle_check		; Handle staying monster
	bra.s	.Next1
.Hunt:	jsr	Hunting_monster_3D		; Handle hunting monster
	jsr	Battle_check
	bra.s	.Next1
.Person:	btst	#2,d0			; Path or random ?
	beq.s	.Path
	jsr	Random_person_3D		; Handle random person
	bra.s	.Next1
.Path:	jsr	Path_person_3D		; Handle person on a path
.Next1:	lea.l	VNPC_data_size(a1),a1	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop1
; ---------- Move NPC's ---------------------------
	lea.l	VNPC_data,a1
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop2:	tst.b	NPC_char_nr(a1)		; Anyone there ?
	beq	.Next2
	btst	d7,d6			; Not removed ?
	bne	.Next2
	btst	#Movement_ended,VFlags(a1)	; Movement ended ?
	bne	.Next2
	move.w	VTarget_X(a1),d0		; Get target map coordinates
	move.w	VTarget_Y(a1),d1
	tst.w	d0			; Zero ?
	bne.s	.Notzero1
	tst.w	d1
	beq.s	.Jump
.Notzero1:	jsr	Map_to_dungeon		; Get target dungeon coordinates
	move.w	d0,.X			; Store
	move.w	d1,.Y
	tst.w	VSource_X(a1)		; Current coordinates zero ?
	bne.s	.Notzero2
	tst.w	VSource_Y(a1)
	bne.s	.Notzero2
.Jump:	move.w	d0,VSource_X(a1)		; Yes -> jump
	move.w	d1,VSource_Y(a1)
	bset	#Movement_ended,VFlags(a1)	; Movement ended
	bra	.Next2
.Notzero2:	sub.w	VSource_X(a1),d0		; Calculate total vector
	sub.w	VSource_Y(a1),d1
	move.w	d0,d2
	move.w	d1,d3
	muls.w	d0,d0			; Calculate total length
	muls.w	d1,d1
	add.l	d1,d0
	tst.l	d0			; Zero ?
	beq	.End
	jsr	Square_root
	move.w	Dungeon_speed,d1		; Get speed
	mulu.w	#35,d1			;  (= x% of dungeon speed)
	divu.w	#100,d1
	cmp.w	d0,d1			; Almost there ?
	bpl.s	.Skip			; Yes -> skip
	muls.w	d1,d2			; Calculate movement vector
	muls.w	d1,d3
	divs.w	d0,d2
	divs.w	d0,d3
.Skip:	add.w	VSource_X(a1),d2		; Calculate destination
	add.w	VSource_Y(a1),d3
	move.w	d2,d0			; Move possible ?
	move.w	d3,d1
	jsr	NPC_movement_check_3D
	beq.s	.Yes
.Block:	bset	#Movement_ended,VFlags(a1)	; No -> end of movement
	bset	#NPC_collided,VFlags(a1)
	bra	.Next2
.Yes:	move.w	d0,VSource_X(a1)		; Store new dungeon coordinates
	move.w	d1,VSource_Y(a1)
	jsr	Dungeon_to_map
	move.w	d0,VMap_X(a1)		; Store new map coordinates
	move.w	d1,VMap_Y(a1)
	cmp.w	.X,d0			; Target reached ?
	bne.s	.Next2
	cmp.w	.Y,d1
	bne.s	.Next2
.End:	bset	#Movement_ended,VFlags(a1)	; Yes -> end of movement
.Next2:	lea.l	VNPC_data_size(a1),a1	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi	.Loop2
.Exit:	sf	New_move			; Clear flags
	sf	New_step
	movem.l	(sp)+,d0-d3/d6/d7/a1
	rts

.X:	dc.w 0				; Target dungeon coordinates
.Y:	dc.w 0

;*****************************************************************************
; [ Check if movement is possible for NPC (2D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;        a1 - Pointer to NPC data (.l)
;  OUT :     Zero - Movement possible
;        Non-zero - Movement impossible
; All registers are restored
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
; [ Check if movement is possible for NPC (3D map) ]
;   IN : d0 - Dungeon X-coordinate (.w)
;        d1 - Dungeon Y-coordinate (.w)
;        a1 - Pointer to NPC data (.l)
;  OUT :     Zero - Movement possible
;        Non-zero - Movement impossible
; All registers are restored
;*****************************************************************************
NPC_movement_check_3D:
	movem.l	d0-d7/a0-a5,-(sp)
	st	Collision			; Default
	move.w	d0,d6			; Save dungeon coordinates
	move.w	d1,d7
	jsr	Dungeon_to_map		; Calculate map coordinates
	move.w	d0,d4			; Save map coordinates
	move.w	d1,d5
	Get	Mapdata_handle,a0		; Get pointer to map &
	lea.l	Map_data(a0),a0		;  labyrinth data
	Get	Labdata_handle,a5
; ---------- Check out-of-map collision -----------
	cmp.w	#1,d4			; X too low ?
	blt	.Exit
	cmp.w	Width_of_map,d4		; X too high ?
	bgt	.Exit
	cmp.w	#1,d5			; Y too low ?
	blt	.Exit
	cmp.w	Height_of_map,d5		; Y too high ?
	bgt	.Exit
; ---------- Check if another NPC is present ------
	lea.l	VNPC_data,a2		; Check NPC's
	move.l	CD_value,d2
	moveq.l	#0,d3
.Loop1:	tst.b	NPC_char_nr(a2)		; Anyone there ?
	beq.s	.Next1
	cmpa.l	a1,a2			; Is I ?
	beq.s	.Next1
	btst	d3,d2			; Deleted ?
	bne.s	.Next1
	cmp.w	VMap_X(a2),d4		; Same coordinates ?
	bne.s	.Next1
	cmp.w	VMap_Y(a2),d5
	beq	.Exit
.Next1:	lea.l	VNPC_data_size(a2),a2	; Next NPC
	addq.w	#1,d3
	cmpi.w	#Max_chars,d3
	bmi.s	.Loop1
; ---------- Check cheat mode ---------------------
	cmpi.b	#Super_chicken,NPC_travel_mode(a1)	; Cheat mode ?
	bne.s	.Normal
	sf	Collision			; No collision
	bra	.Exit
; ---------- Check if target square is blocked ----
.Normal:	move.w	d4,d0			; Get map coordinates
	move.w	d5,d1
	subq.w	#1,d0			; Calculate map pointer
	add.w	d0,d0
	add.w	d0,a0
	subq.w	#1,d1
	mulu.w	Width_of_map,d1
	add.l	d1,d1
	add.l	d1,a0
	moveq.l	#0,d0			; Get map byte
	move.b	(a0),d0
	bne	.Full			; Anything ?
	sf	Collision			; No -> no collision
	bra	.Exit
.Full:	cmp.b	#-1,d0			; Dummy wall ?
	bne.s	.No_dummy
	st	Collision			; Yes -> Ouch!
	bra	.Exit
.No_dummy:	cmp.w	#First_wall,d0		; Wall or object ?
	bmi.s	.Object
	subi.w	#First_wall,d0		; Get wall status bits
	lsl.w	#2,d0
	move.l	a5,a2
	lea.l	Wall_data_offsets,a3
	add.l	0(a3,d0.w),a2
	move.l	Wall_bits(a2),d0
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne	.Exit
	moveq.l	#0,d1			; Get travel mode
	move.b	NPC_travel_mode(a1),d1
	add.w	#Blocked_foot_bit,d1
	btst.l	d1,d0			; Way possible for current
	seq	Collision			;  travel mode ?
	bra	.Exit
; ---------- Check collision with objects ---------
.Object:	sf	Collision			; Default
	andi.w	#patt_size-1,d6		; Get dungeon coordinates
	andi.w	#patt_size-1,d7		;  within map square
	subq.w	#1,d0			; Get object group data
	mulu.w	#Objectgroup3D_data_size,d0
	lea.l	Lab_data+4(a5,d0.w),a0
	moveq.l	#Objects_per_group-1,d3	; Do each object in group
.Loop2:	move.w	Object_nr(a0),d0		; Anything there ?
	beq.s	.Next2
	move.l	a5,a2			; Get object data
	adda.l	Object_data_offset,a2
	subq.w	#1,d0
	mulu.w	#Object3D_data_size,d0
	add.l	d0,a2
	move.l	Object_bits(a2),d0		; Get object bits
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Try
	moveq.l	#0,d1			; Get travel mode
	move.b	NPC_travel_mode(a1),d1
	add.w	#Blocked_foot_bit,d1
	btst.l	d1,d0			; Way possible for current
	bne.s	.Next2			;  travel mode ?
.Try:	move.w	Object_X(a0),d0		; Get object coordinates
	move.w	Object_Y(a0),d1
	move.w	Object_dungeon_width(a2),d2	; Get top-left corner
	lsr.w	#1,d2
	sub.w	d2,d0
	sub.w	d2,d1
	cmp.w	d0,d6			; Below/right of top-left ?
	bmi.s	.Next2
	cmp.w	d1,d7
	bmi.s	.Next2
	move.w	Object_dungeon_width(a2),d2	; Get bottom-right corner
	add.w	d2,d0
	add.w	d2,d1
	cmp.w	d0,d6			; Above/left of bottom-right ?
	bpl.s	.Next2
	cmp.w	d1,d7
	bpl.s	.Next2
	st	Collision			; Collision !
	bra	.Exit
.Next2:	addq.w	#Objectingroup_data_size,a0	; Next object in
	dbra	d3,.Loop2				;  group
; ---------- Exit & test collision ----------------
.Exit:	Free	Labdata_handle
	Free	Mapdata_handle
	tst.b	Collision			; Get zero flag
	movem.l	(sp)+,d0-d7/a0-a5
	rts

;*****************************************************************************
; [ Check for collision with monster ]
;   IN : d7 - NPC index (.w)
;        a1 - Pointer to NPC data (.l)
; All registers are restored
;*****************************************************************************
Battle_check:
	movem.l	d0/d1/a0,-(sp)
	tst.b	NPCs_off			; NPC's off ?
	bne	.Exit
	move.w	Travel_mode,d0		; Vulnerable ?
	move.w	#Combat_mask,d1
	btst	d0,d1
	beq	.Exit
	move.w	VMap_X(a1),d0		; Get coordinates
	move.w	VMap_Y(a1),d1
	cmp.w	Map_Xcoord,d0		; X the same ?
	bne.s	.Exit
	cmp.w	Map_Ycoord,d1		; Y the same ?
	bne.s	.Exit
	st	Big_brother_flag		; Yes -> Gaze!
	tst.w	Monster_move_delay		; Waiting ?
	bne.s	.Exit
	move.l	a1,a0			; No!
	jsr	Turn_towards_NPC
	moveq.l	#0,d0			; Get monstergroup number
	move.b	NPC_char_nr(a1),d0
	move.w	d0,Monstergroup_nr		; Set info
	move.w	d7,Combat_char_index
	st	Combat_req		; Activate requester
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Get CD value for current map ]
; All registers are restored
; Notes :
;  - This is one of the few routines which actually depends on [ Max_chars ]
;    being 32.
;*****************************************************************************
Get_CD_value:
	movem.l	d0/a0,-(sp)
	lea.l	CD,a0			; Get CD value
	move.w	Map_nr,d0
	lsl.w	#2,d0
	lea.l	-4(a0,d0.w),a0
	move.b	3(a0),d0
	lsl.w	#8,d0
	move.b	2(a0),d0
	swap	d0
	move.b	1(a0),d0
	lsl.w	#8,d0
	move.b	(a0),d0
	move.l	d0,CD_value		; Store
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Person on a path movement routine (2D map) ]
;   IN : a1 - Pointer to  NPC data (.l)
; All registers are restored
;*****************************************************************************
Path_person_2D:
	movem.l	d0/d1/a0,-(sp)
	Get	Mapdata_handle,a0		; Get pointer to path
	adda.l	VPath_ptr(a1),a0
	move.w	Current_step,d0		; Get position
	add.w	d0,d0
	add.w	d0,a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	Free	Mapdata_handle
	move.w	d0,VMap_X(a1)		; Store
	move.w	d1,VMap_Y(a1)
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Person on a path movement routine (3D map) ]
;   IN : a1 - Pointer to  NPC data (.l)
; All registers are restored
;*****************************************************************************
Path_person_3D:
	movem.l	d0-d2/a0,-(sp)
	Get	Mapdata_handle,a0		; Get pointer to path
	adda.l	VPath_ptr(a1),a0
	move.w	Current_step,d0		; Get position
	add.w	d0,d0
	add.w	d0,a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	Free	Mapdata_handle
	tst.w	d0			; Visible at all ?
	bne.s	.Yes
	tst.w	d1
	beq.s	.Jump
.Yes:	bclr	#Movement_ended,VFlags(a1)	; Yes -> start movement
	move.w	d0,VTarget_X(a1)		; Store target position
	move.w	d1,VTarget_Y(a1)
	move.w	d0,d2			; X : Move or jump ?
	sub.w	VMap_X(a1),d2
	addq.w	#1,d2
	cmp.w	#3,d2
	bhs.s	.Jump
	move.w	d1,d2			; Y : Move or jump ?
	sub.w	VMap_Y(a1),d2
	addq.w	#1,d2
	cmp.w	#3,d2
	blo.s	.Exit
.Jump:	move.w	d0,VMap_X(a1)		; Set new coordinates
	move.w	d1,VMap_Y(a1)
	jsr	Map_to_dungeon
	move.w	d0,VSource_X(a1)
	move.w	d1,VSource_Y(a1)
	bset	#Movement_ended,VFlags(a1)	; End of movement
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Random NPC movement routine (2D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
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
; All registers are	restored
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
.Up_exit:	
	rts

.Right:	move.w	Width_of_map,d0		; Check path length
	sub.w	VMap_X(a1),d0
	sub.w	d1,d0
	bpl.s	.Right_exit		; Ok ?
	add.w	d0,d1			; Adjust
.Right_exit:
	rts

.Down:	move.w	Height_of_map,d0		; Check path length
	sub.w	VMap_Y(a1),d0
	sub.w	d1,d0
	bpl.s	.Down_exit		; Ok ?
	add.w	d0,d1			; Adjust
.Down_exit:
	rts

.Left:	move.w	VMap_X(a1),d0		; Check path length
	sub.w	d1,d0
	bmi.s	.Left_exit		; Ok ?
	subq.w	#1,d0			; Adjust
	add.w	d0,d1
.Left_exit:
	rts

;*****************************************************************************
; [ Random NPC movement routine (3D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
;*****************************************************************************
Random_person_3D:
	movem.l	d0-d3/d7,-(sp)
	btst	#Movement_ended,VFlags(a1)	; Movement ended ?
	beq	.Exit
	tst.b	New_step			; Is it time ?
	beq	.Exit
	tst.w	VPathlen(a1)		; End of path ?
	bne.s	.Loop
	moveq.l	#4-1,d7			; Try four times
	bra.s	.Entry
.Loop:	move.w	VMap_X(a1),d0		; Get position
	move.w	VMap_Y(a1),d1
	move.w	VDir(a1),d2		; Update position
	jsr	Move_in_8_directions
	move.w	d0,d2			; Save
	move.w	d1,d3
	jsr	Map_to_dungeon		; Calculate dungeon coordinates
	jsr	NPC_movement_check_3D	; Possible ?
	beq.s	.Move
.Entry:	jsr	Choose_random_path_3D	; Choose new path
	dbra	d7,.Loop
	clr.w	VPathlen(a1)		; Clear path length
	bra.s	.Exit
.Move:	subq.w	#1,VPathlen(a1)		; Count down
	move.w	d2,VTarget_X(a1)		; Store target coordinates
	move.w	d3,VTarget_Y(a1)
	bclr	#Movement_ended,VFlags(a1)	; Start movement
.Exit:	movem.l	(sp)+,d0-d3/d7
	rts

;*****************************************************************************
; [ Choose random path (3D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are	restored
;*****************************************************************************
Choose_random_path_3D:
	movem.l	d0-d3/a0,-(sp)
	jsr	Random			; Choose random path length
	moveq.l	#$3,d1
	and.w	d0,d1
	addq.w	#1,d1
	move.w	VDir(a1),d2		; Get current direction
	jsr	Random			; Rotate randomly (with
	andi.w	#$000f,d0			;  distribution !)
	move.b	.Distribution(pc,d0.w),d0
	add.w	d0,d2
	andi.w	#$0007,d2
	move.w	d2,VDir(a1)		; Store
	move.w	d2,d3			; Save
	andi.w	#$001e,d2			; Check normal path length
	add.w	d2,d2
	movea.l	.Pathcheck(pc,d2.w),a0
	jsr	(a0)
	btst	#0,d3			; Diagonal ?
	beq.s	.Exit
	movea.l	.Pathcheck+4(pc,d2.w),a0	; Yes -> check other path length
	jsr	(a0)
.Exit:	move.w	d1,VPathlen(a1)		; Output
	movem.l	(sp)+,d0-d3/a0
	rts

.Distribution:
	dc.b 3,-3			; 3/8 rotation
	rept 3
	dc.b 1,-1			; 1/8 rotation
	endr
	rept 4
	dc.b 2,-2			; 2/8 rotation
	endr
.Pathcheck:	
	dc.l .Up,.Right,.Down,.Left,.Up

; Path check routines
;   IN : d1 - Path length (.w)
;        a1 - Pointer to  NPC data (.l)
; Changed registers : d0,d1

.Up:	move.w	VMap_Y(a1),d0		; Check path length
	sub.w	d1,d0
	cmp.w	#2,d0			; Ok ?
	bpl.s	.Up_exit
	move.w	VMap_Y(a1),d1		; Adjust
	subq.w	#2,d1
.Up_exit:	
	rts

.Right:	move.w	VMap_X(a1),d0		; Check path length
	add.w	d1,d0
	addq.w	#1,d0
	cmp.w	Width_of_map,d0
	bmi.s	.Right_exit		; Ok ?
	move.w	Width_of_map,d1		; Adjust
	subq.w	#1,d1
	sub.w	VMap_X(a1),d1
.Right_exit:
	rts

.Down:	move.w	VMap_Y(a1),d0		; Check path length
	add.w	d1,d0
	addq.w	#1,d0
	cmp.w	Height_of_map,d0
	bmi.s	.Down_exit		; Ok ?
	move.w	Height_of_map,d1		; Adjust
	subq.w	#1,d1
	sub.w	VMap_Y(a1),d1
.Down_exit:
	rts

.Left:	move.w	VMap_X(a1),d0		; Check path length
	sub.w	d1,d0
	cmp.w	#2,d0			; Ok ?
	bgt.s	.Left_exit
	move.w	VMap_X(a1),d1		; Adjust
	subq.w	#2,d1
.Left_exit:	
	rts

;*****************************************************************************
; [ Hunting monster movement routine (2D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
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
	tst.w	d0			; X =< 0 ?
	ble.s	.No_move1
	cmp.w	Width_of_map,d0		; X > Width ?
	bhi.s	.No_move1
	tst.w	d1			; Y =< 0 ?
	ble.s	.No_move1
	cmp.w	Height_of_map,d1		; Y > Height ?
	bhi.s	.No_move1
	jsr	NPC_movement_check_2D
	beq	.Move
.No_move1:	bclr	#0,VFlags(a1)		; Random movement
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
	jsr	NPC_movement_check_2D
	beq.s	.Move
	move.w	d4,d0			; Restore coordinates
	move.w	d5,d1
	rol.l	#8,d2			; Get 2nd direction
	tst.b	d2
	bmi.s	.No_move2
	jsr	Move_in_direction		; Try move
	jsr	NPC_movement_check_2D
	beq.s	.Move
	move.w	d4,d0			; Restore coordinates
	move.w	d5,d1
	rol.l	#8,d2			; Get 3rd direction
	tst.b	d2
	bmi.s	.No_move2
	jsr	Move_in_direction		; Try move
	jsr	NPC_movement_check_2D
	beq.s	.Move
.No_move2:	move.w	d4,d0			; Restore coordinates
	move.w	d5,d1
	bra.s	.Exit
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

;*****************************************************************************
; [ Hunting monster movement routine (3D map) ]
;   IN : a1 - Pointer to NPC data (.l)
; All registers are restored
;*****************************************************************************
Hunting_monster_3D:
	btst	#Moving_randomly,VFlags(a1)	; Moving at random ?
	beq.s	.No
	btst	#Movement_ended,VFlags(a1)	; Ready ?
	beq.s	.Random
.No:	jsr	Check_line_of_sight		; In line of sight ?
	bne.s	.Random
.Visible:	st	Big_brother_flag		; Gaze!
	tst.w	Monster_move_delay		; Waiting ?
	bne	.Exit
	btst	#Movement_ended,VFlags(a1)	; Movement ended ?
	bne.s	.Ended
.Do:	move.w	Map_Xcoord,VTarget_X(a1)	; Go get it !
	move.w	Map_Ycoord,VTarget_Y(a1)
	bra.s	.Exit
.Ended:	btst	#NPC_collided,VFlags(a1)	; Collided ?
	bne.s	.Bounce
	bclr	#Movement_ended,VFlags(a1)	; No -> Be sure
	bra.s	.Do
.Bounce:	bclr	#NPC_collided,VFlags(a1)	; Yes -> Do random move
	bset	#Moving_randomly,VFlags(a1)
.Random:	tst.w	Monster_move_delay		; Waiting ?
	bne.s	.Exit
	jsr	Random_person_3D
.Exit:	rts

;*****************************************************************************
; [ Check if player is in monster's line of sight ]
;   IN : a1 - Pointer to  NPC data (.l)
;  OUT :     Zero - In line of sight
;        Non-zero - NOT in line of sight
; All registers are restored
; Notes :
;  - The destination coordinates are (0,0) !!!
;  - Regarding time : in 3D maps, where this routine is most critical,
;    it will not use a lot of time since the line of sight is cut off as
;    soon as a vision-blocking element is found. In narrow corridors this
;    will happen very soon and very often.
;*****************************************************************************
Check_line_of_sight:          
	movem.l	d0-d7,-(sp)
; ---------- Calculate stuff ----------------------
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
	bmi	.dYdX
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
	bne	.Not
	move.l	(sp)+,d0
.Entry1:	add.w	d5,d6			; Trace line
	cmp.w	d4,d6
	bmi.s	.Skip1
	sub.w	d4,d6
	add.w	d3,d1			; Update Y
.Skip1:	add.w	d2,d0			; Update X
	dbra	d7,.Again1		; Next
	bra	.Seen
; ---------- dY > dX ------------------------------
.dYdX: 	move.w	d5,d6			; Initialize Bresenham
	lsr.w	#1,d6			;  variable
	move.w	d5,d7			; dY = counter
	subq.w	#1,d7			; One less
	bmi.s	.Not2			; Exit if zero
	bra.s	.Entry2
.Again2:	move.l	d0,-(sp)			; Vision blocked ?
	jsr	Get_location_status
	btst	#Vision_blocked_bit,d0
	bne	.Not
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
; [ Turn towards NPC ]
;   IN : a0 - Pointer to NPC data (.l)
; All registers are restored
;*****************************************************************************
Turn_towards_NPC:
	movem.l	d0-d5/d7,-(sp)
	cmp.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl	.3D
; ---------- 2D map -------------------------------
	move.w	VMap_X(a0),d0		; Get NPC coordinates
	move.w	VMap_Y(a0),d1
	sub.w	Map_Xcoord,d0		; Calculate dX & dY
	sub.w	Map_Ycoord,d1
	move.w	d0,d2			; ABS dX
	bpl.s	.Pos1
	neg.w	d2
.Pos1:	move.w	d1,d3			; ABS dY
	bpl.s	.Pos2
	neg.w	d3
.Pos2:	ext.l	d0			; Mega SGN function
	beq.s	.Zero1
	swap.w	d0
	bmi.s	.Zero1
	moveq.l	#1,d0
.Zero1:	ext.l	d1			; Mega SGN function
	beq.s	.Zero2
	swap.w	d1
	bmi.s	.Zero2
	moveq.l	#1,d1
.Zero2:	addq.w	#1,d0			; Calculate index
	addq.w	#1,d1
	mulu.w	#3,d1
	add.w	d1,d0
	cmp.w	d2,d3			; dX > dY ?
	bpl.s	.No
	addi.w	#9,d0
.No:	move.b	.Table(pc,d0.w),d0		; Get view direction
	cmp.w	View_direction,d0		; Already looking that way ?
	beq	.Exit2
	move.w	d0,View_direction		; No -> Store
	jsr	Display_2D_map		; Display
	jsr	Map_DisUpd
	jsr	Update_screen
	bra	.Exit
.Table:	dc.b 0,0,0,3,2,1,2,2,2		; dX =< dY
	dc.b 3,0,1,3,2,1,3,2,1		; dX  > dY
	even
; ---------- 3D map -------------------------------
.3D:	moveq.l	#4-1,d7			; Try 4 times
.Loop:	move.w	VSource_X(a0),d2		; Get vector
	move.w	VSource_Y(a0),d3
	sub.w	Player_X,d2
	sub.w	Player_Y,d3
	tst.w	d2			; Is zero ?
	bne.s	.Not_zero1
	tst.w	d3
	beq	.Done
.Not_zero1:
	move.w	d2,d0			; Calculate length
	move.w	d3,d1
	mulu.w	d0,d0
	mulu.w	d1,d1
	add.l	d1,d0
	jsr	Square_root
	tst.w	d0			; At least one
	bne.s	.Not_zero2
	moveq.l	#1,d0
.Not_zero2:
	move.w	d0,d5			; Save length
	move.w	d2,d0			; Get angle
	move.w	d3,d1
	jsr	Calculate_ATN
	move.w	d0,d4			; Save angle
	cmp.w	#patt_size/2,d5		; Too close ?
	bpl	.Go_on
	move.w	d2,d0			; Yes -> Get vector
	mulu.w	#patt_size/2,d0
	divu.w	d5,d0
	move.w	d3,d1
	mulu.w	#patt_size/2,d1
	divu.w	d5,d1
	move.w	Player_X,d2		; Move
	move.w	Player_Y,d3
	sub.w	d0,d2
	add.w	d1,d3
	swap	d2
	swap	d3
	clr.w	d2
	clr.w	d3
	move.l	d2,d0
	move.l	d3,d1
	jsr	Movement_check_3D		; Try
	bne.s	.Go_on
	swap	d0			; Calculate map coordinates
	swap	d1
	jsr	Dungeon_to_map
	cmp.w	Map_Xcoord,d0		; Any change ?
	bne.s	.Go_on
	cmp.w	Map_Ycoord,d1
	bne.s	.Go_on
	move.l	d2,Player_X		; No -> Set new X & Y
	move.l	d3,Player_Y
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	dbra	d7,.Loop			; Try again
.Go_on:	move.w	d4,d0			; Restore angle
	subi.w	#slang,d0			; Invert
	neg.w	d0
	andi.w	#slang-1,d0
	swap	d0			; Set final angle
	clr.w	d0
	move.l	d0,Y_angle
.Done:	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Update_screen
	jsr	Save_coordinates		; To avoid sudden jumps
.Exit:	moveq.l	#25,d0			; Wait
	jsr	Delay
.Exit2:	movem.l	(sp)+,d0-d5/d7
	rts
