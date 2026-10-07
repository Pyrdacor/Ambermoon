; Combat monster logic routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 4-3-1993
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Determine monster action ]
;   IN : a0 - Pointer to monster's participant data (.l)
; All registers are restored
;*****************************************************************************
Determine_monster_action:
	movem.l	d0-d2/a1,-(sp)
	Get	Part_handle(a0),a1
	move.b	Monster_type_status(a1),d0	; End monster ?
	btst	#End_monster_type,d0
	bne	.Offend
; ---------- Determine danger ---------------------
	move.w	Life_points+Maximum(a1),d1	; Calculate local danger
	add.w	Life_points+Magic(a1),d1	; 0...75
	move.w	d1,d0
	sub.w	Life_points(a1),d0
	muls.w	#75,d0
	divs.w	d1,d0
	move.w	Global_danger,d1		; Add global danger
	subi.w	#50,d1			; -12...12
	asr.w	#2,d1
	add.w	d1,d0
	move.w	Nr_monsters,d2		; Add group decimation factor
	subq.w	#1,d2			; -10...30
	beq.s	.One
	move.w	Remaining_monsters,d1
	subq.w	#1,d1
	mulu.w	#40,d1
	divu.w	d2,d1
	subi.w	#30,d1
	neg.w	d1
	add.w	d1,d0
.One:	tst.w	d0			; Clip bottom
	bpl.s	.Ok1
	moveq.l	#0,d0
	bra.s	.Ok2
.Ok1:	cmp.w	#100,d0			; Clip top
	bmi.s	.Ok2
	moveq.l	#100,d0
; ---------- Determine offensive/defensive --------
.Ok2:	moveq.l	#0,d1			; Too dangerous ?
	move.b	Courage(a1),d1
	sub.w	d0,d1
	bmi.s	.Defend
.Offend:	jsr	Select_offensive_monster_action	; No !
	bra.s	.Done
.Defend:	move.w	d1,d0			; Yes... defensive action ?
	neg.w	d0
	moveq.l	#100,d1
	sub.b	Courage(a1),d1
	ext.w	d1
	jsr	Probe
	bmi.s	.Offend
	jsr	Select_defensive_monster_action	; Yes
.Done:	tst.b	Part_action(a0)		; Doing something ?
	bne.s	.Exit
	move.w	Body_conditions(a1),d0	; No -> Can parade ?
	andi.w	#Parade_mask,d0
	bne.s	.Exit
	move.w	#-1,Part_target(a0)		; Yes -> Do
	move.b	#Parade_action,Part_action(a0)
.Exit:	Free	Part_handle(a0)
	movem.l	(sp)+,d0-d2/a1
	rts

;*****************************************************************************
; [ Select defensive monster action ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
; Notes :
;   - This routine is also called for panicking monsters.
;*****************************************************************************
Select_defensive_monster_action:
	movem.l	d0-d3/d5/d7/a2,-(sp)
; ---------- Try to flee --------------------------
	tst.w	Part_Y(a0)		; In top row ?
	bne.s	.Move
	move.w	Body_conditions(a1),d0	; Can flee ?
	andi.w	#Flee_mask,d0
	bne	.Exit
	move.w	#-1,Part_target(a0)		; Yes -> Flee
	move.b	#Flee_action,Part_action(a0)
	bra	.Exit
; ---------- Get movement range -------------------
.Move:	jsr	Get_occupied_targets	; Get occupied targets
	move.l	d0,d1
	jsr	Check_movement_range	; Get movement range
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	tst.l	d0			; Any left ?
	beq	.Exit
	move.l	d0,d5			; Yes
	lea.l	Part_target(a0),a2		; Reset number of moves
	clr.w	(a2)+
	move.w	Part_X(a0),d0		; Get coordinates
	move.w	Part_Y(a0),d1
	move.w	d1,d2			; Get tactic index
	mulu.w	#6,d2
	add.w	d0,d2
	move.w	ASpeed(a1),d7		; Get movement speed
	add.w	ASpeed+Magic(a1),d7
	ext.l	d7			; Determine range
	divs.w	#Move_speed_factor,d7
	tst.w	d7			; Clip below
	bne.s	.Below_OK
	moveq.l	#1,d7
	bra.s	.Ok
.Below_OK:	cmp.w	#3+1,d7			; Clip above
	bmi.s	.Ok
	moveq.l	#3,d7
.Ok:	bra	.Entry
; ---------- Try to retreat -----------------------
.Loop:	tst.w	d1			; Uppest ?
	beq	.Done
	move.w	d2,d3			; Up possible ?
	subq.w	#6,d3
	btst	d3,d5
	beq.s	.No
	subq.w	#1,d1			; Yes -> Move up
	subq.w	#6,d2
	bra.s	.Next
.No:	subq.w	#1,d1			; No -> Move up...
	subq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Defensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	bne.s	.Next
	addq.w	#1,d1			; No -> Move back down...
	addq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Defensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	beq.s	.Done
	bclr	d3,d5			; Yes -> No turning back !
.Next:	move.w	d2,(a2)+			; Store move
	addq.w	#1,Part_target(a0)
.Entry:	dbra	d7,.Loop			; Next step
.Done:	tst.w	Part_target(a0)		; Moved ?
	beq.s	.Exit
	move.b	#Move_action,Part_action(a0)	; Set action
.Exit:	movem.l	(sp)+,d0-d3/d5/d7/a2
	rts

;*****************************************************************************
; [ Try DEFENSIVE movement to the left or to the right ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Tactic index {0...29} (.w)
;        d5 - Movement range mask (.l)
;  OUT : d0 - New X-coordinate (.w)
;        d2 - New tactic index {0...29} (.w)
; Changed registers : d0,d2
; Notes :
;   - This is an internal routine.
;   - It will work both for monsters and for party members.
;*****************************************************************************
Defensive_left_or_right:
	movem.l	d3,-(sp)
; ---------- Both left & right possible ? ---------
	tst.w	d0			; Leftest ?
	beq.s	.Right1
	cmp.w	#5,d0			; Rightest ?
	beq.s	.Left1
	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq.s	.Right1
	addq.w	#2,d3			; Right possible ?
	btst	d3,d5
	beq.s	.Left1
; ---------- Which is better ? --------------------
	move.l	d0,-(sp)			; Chance >= 0.5 ?
	jsr	Random
	move.w	d0,d3
	move.l	(sp)+,d0
	andi.w	#$00ff,d3
	cmp.w	#128,d3
	bmi.s	.Left2
	bra.s	.Right2
; ---------- Try to move right --------------------
.Right1:	move.w	d2,d3			; Right possible ?
	addq.w	#1,d3
	btst	d3,d5
	beq	.Exit
.Right2:	addq.w	#1,d0			; Move right
	addq.w	#1,d2
	bra	.Exit
; ---------- Try to move left ---------------------
.Left1:	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq	.Exit
.Left2:	subq.w	#1,d0			; Move left
	subq.w	#1,d2
.Exit:	movem.l	(sp)+,d3
	rts

;*****************************************************************************
; [ Select offensive monster action ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
;*****************************************************************************
Select_offensive_monster_action:
	movem.l	d0/d1/a2,-(sp)
	move.b	Part_flags(a0),d1		; Capable of anything ?
	andi.b	#%00001110,d1
	beq	.Exit
.Again:	jsr	Random			; Yes -> Select capability
	andi.w	#$000f,d0
	move.b	.Distribution(pc,d0.w),d0
	bclr	d0,d1			; Capable ?
	beq.s	.Again			; No -> Re-select
	lsl.w	#2,d0			; Try action
	movea.l	.Vectors-4(pc,d0.w),a2
	jsr	(a2)
	tst.b	Part_action(a0)		; Success ?
	bne.s	.Exit
	tst.b	d1			; Tried everything ?
	bne.s	.Again
.Exit:	movem.l	(sp)+,d0/d1/a2
	rts

.Distribution:
	dcb.b 8,Part_magic_cap
	dcb.b 6,Part_long_cap
	dcb.b 2,Part_close_cap
	even
.Vectors:
	dc.l Try_magical_attack
	dc.l Try_long_range_attack
	dc.l Try_close_range_attack

;*****************************************************************************
; [ Try magical attack ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
;*****************************************************************************
Try_magical_attack:
	movem.l	d0-d7/a2/a3,-(sp)
; ---------- Magic possible ? ---------------------
	move.w	Body_conditions(a1),d0	; Capable of magic ?
	andi.w	#Magic_mask,d0
	bne	.Exit
	tst.w	Power_points(a1)		; Any spell-points left ?
	bne.s	.Ok
.Fail:	bclr	#Part_magic_cap,Part_flags(a0)	; Not capable
	bra	.Exit
; ---------- Determine possible spells & targets --
.Ok:	clr.l	Monster_spells_1		; Clear
	clr.l	Monster_spells_3
	moveq.l	#0,d1			; None
	move.w	Power_points(a1),d6		; Get spell points
	move.l	Spells_class_1(a1),d0	; Try spell class 1
	andi.l	#Monsterspell_1_mask,d0
	beq.s	.Try_3
	lea.l	Spell_data+Max_spells*Spell_data_size,a2	; Check spells
	moveq.l	#0,d3
	moveq.l	#1,d7
.Loop1:	btst	d7,d0			; Spell available ?
	beq.s	.Next1
	moveq.l	#0,d2			; Yes -> Enough SP ?
	move.b	Spell_point_cost(a2),d2
	cmp.w	d2,d6
	bmi.s	.Next1
	move.b	Spell_target_bits(a2),d2	; Yes -> Get target
	andi.b	#%00111000,d2
	beq.s	.Next1			; (if any)
	lsr.w	#3,d2			; Insert
	or.b	d2,d1
	bset	d7,d3			; Mark
.Next1:	addq.w	#Spell_data_size,a2	; Next spell
	addq.w	#1,d7
	cmp.w	#Max_spells,d7
	bls.s	.Loop1
	move.l	d3,Monster_spells_1		; Store
.Try_3:	move.l	Spells_class_3(a1),d0	; Try spell class 1
	andi.l	#Monsterspell_3_mask,d0
	beq.s	.Done_3
	lea.l	Spell_data+3*Max_spells*Spell_data_size,a2	; Check spells
	moveq.l	#0,d3
	moveq.l	#1,d7
.Loop2:	btst	d7,d0			; Spell available ?
	beq.s	.Next2
	moveq.l	#0,d2			; Yes -> Enough SP ?
	move.b	Spell_point_cost(a2),d2
	cmp.w	d2,d6
	bmi.s	.Next2
	move.b	Spell_target_bits(a2),d2	; Yes -> Get target
	andi.b	#%00111000,d2
	beq.s	.Next2			; (if any)
	lsr.w	#3,d2			; Insert
	or.b	d2,d1
	bset	d7,d3			; Mark
.Next2:	addq.w	#Spell_data_size,a2	; Next spell
	addq.w	#1,d7
	cmp.w	#Max_spells,d7
	bls.s	.Loop2
	move.l	d3,Monster_spells_3		; Store
.Done_3:	tst.b	d1			; Any targets ?
	beq	.Fail
	move.b	d1,Monster_magic_target	; Yes -> Store
; ---------- Determine maximum danger -------------
	jsr	Get_longrange_targets	; Get all targets
	tst.l	d0			; Any ?
	beq	.Exit
	lea.l	Combat_matrix,a2		; Determine maximum
	moveq.l	#-1,d1
	moveq.l	#0,d7
.Loop3:	btst	d7,d0			; Target ?
	beq.s	.Next3
	move.l	(a2),a3			; Yes -> Get data
	move.w	Part_mean_damage(a3),d5	; Get mean damage
	cmp.w	d5,d1			; Same as maximum ?
	bne.s	.Not_same
	bset	d7,d2			; Yes -> Mark
	bra.s	.Next3
.Not_same:	cmp.w	d5,d1			; No -> More ?
	bgt.s	.Next3
	move.w	d5,d1			; Yes
	moveq.l	#0,d2			; Make mask
	bset	d7,d2
.Next3:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#6*5,d7
	bmi.s	.Loop3
	move.l	d2,Monster_single_target	; Store
; ---------- Determine relative danger ------------	
	tst.w	d1			; Maximum is zero ?
	bne	.Notzero
	lea.l	Combat_matrix,a2		; Set dangers
	moveq.l	#0,d7
.Loop4:	btst	d7,d0			; Target ?
	beq.s	.Next4
	move.l	(a2),a3			; Yes
	move.w	#100,Part_work(a3)		; Set relative danger
.Next4:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#6*5,d7
	bmi.s	.Loop4
	bra.s	.Go_on
.Notzero:	lea.l	Combat_matrix,a2		; Calculate relative danger
	moveq.l	#0,d7
.Loop5:	btst	d7,d0			; Target ?
	beq.s	.Next5
	move.l	(a2),a3			; Yes -> Get data
	move.w	Part_mean_damage(a3),d5	; Get mean damage
	mulu.w	#100,d5			; Relativate
	divu.w	d1,d5
	move.w	d5,Part_work(a3)		; Store
.Next5:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#6*5,d7
	bmi.s	.Loop5
; ---------- Maybe entire party ? -----------------
.Go_on:	btst	#2,Monster_magic_target	; Is possible target ?
	beq	.Not_all
	lea.l	Combat_matrix,a2		; Calculate mean relative
	moveq.l	#0,d1			;  danger
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d7
.Loop6:	btst	d7,d0			; Target ?
	beq.s	.Next6
	move.l	(a2),a3			; Yes
	move.w	Part_work(a3),d3		; Add
	add.l	d3,d1
	addq.w	#1,d2			; Count
.Next6:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#6*5,d7
	bmi.s	.Loop6
	divu.w	d2,d1			; Calculate
	cmp.w	#75,d1			; Attack all ?
	bmi.s	.Not_all
	move.b	#All_enemies_targmode,Part_target+6(a0)	; Enter data
	move.l	#Combat_party_mask,Part_target(a0)
	moveq.l	#5,d1
	bra	.Select
; ---------- Maybe a party row ? ------------------
.Not_all:	btst	#1,Monster_magic_target	; Is possible target ?
	beq	.Not_row
	lea.l	Combat_matrix+18*4,a2	; Calculate mean relative
	moveq.l	#0,d1			;  danger of 1st row
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#18,d7
.Loop7:	btst	d7,d0			; Target ?
	beq.s	.Next7
	move.l	(a2),a3			; Yes
	move.w	Part_work(a3),d3		; Add
	add.l	d3,d1
	addq.w	#1,d2			; Count
.Next7:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#24,d7
	bmi.s	.Loop7
	tst.w	d2			; Any in 1st row ?
	beq.s	.1st_MT
	divu.w	d2,d1			; Calculate
.1st_MT:	move.w	d1,-(sp)			; Save
	lea.l	Combat_matrix+24*4,a2	; Calculate mean relative
	moveq.l	#0,d1			;  danger of 2nd row
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#24,d7
.Loop8:	btst	d7,d0			; Target ?
	beq.s	.Next8
	move.l	(a2),a3			; Yes
	move.w	Part_work(a3),d3		; Add
	add.l	d3,d1
	addq.w	#1,d2			; Count
.Next8:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#30,d7			; FIX: Was 24 (wrong end of last row)
	bmi.s	.Loop8
	tst.w	d2			; Any in 2nd row ?
	beq.s	.2nd_MT
	divu.w	d2,d1			; Calculate
.2nd_MT:	move.w	(sp)+,d2			; Restore 1st row
	cmp.w	d1,d2			; Which row is best ?
	bpl.s	.1st_best
	cmp.w	#50,d1			; Attack 2nd row ?
	bmi.s	.1st_best
	move.b	#Enemy_row_targmode,Part_target+6(a0)	; Enter data
	move.l	#%00111111000000000000000000000000,Part_target(a0)
	moveq.l	#4,d1
	bra.s	.Select
.1st_best:	cmp.w	#50,d2			; Attack 1st row ?
	bmi.s	.Not_row
	move.b	#Enemy_row_targmode,Part_target+6(a0)	; Enter data
	move.l	#%00000000111111000000000000000000,Part_target(a0)
	moveq.l	#4,d1
	bra.s	.Select
; ---------- Single target ------------------------
.Not_row:	move.l	Monster_single_target,d1	; How many targets ?
	moveq.l	#0,d2
	moveq.l	#30-1,d7
.Loop13:	btst	d7,d1
	beq.s	.Next13
	addq.w	#1,d2
.Next13:	dbra	d7,.Loop13
	tst.w	d2			; Any ?
	beq	.Exit			;  (shouldn't occur)
	jsr	Random			; Select
	mulu.w	d2,d0
	swap	d0
	moveq.l	#0,d3
.Loop14:	btst	d3,d1			; Target ?
	beq.s	.Next14
	tst.w	d0			; Selected ?
	beq.s	.Selected
	subq.w	#1,d0			; Count down
.Next14:	addq.w	#1,d3			; Next
	cmp.w	#6*5,d3
	bmi.s	.Loop14
	moveq.l	#0,d3			;  (shouldn't occur)
.Selected:	moveq.l	#0,d0			; Make target mask
	bset	d3,d0
	move.b	#Enemy_targmode,Part_target+6(a0)	; Enter data
	move.l	d0,Part_target(a0)
	moveq.l	#3,d1
; ---------- Determine possible spells ------------
.Select:	lea.l	Monster_spells,a3
	moveq.l	#0,d2
	move.l	Monster_spells_1,d0		; Try class 1
	beq	.Not_1
	lea.l	Spell_data+Max_spells*Spell_data_size,a2	; Check spells
	moveq.l	#1,d7
.Loop9:	btst	d7,d0			; Spell available ?
	beq.s	.Next9
	move.b	Spell_target_bits(a2),d3	; Yes -> Correct target ?
	btst	d1,d3
	beq.s	.Next9
	move.b	#1,(a3)+			; Yes -> Insert
	move.b	d7,(a3)+
	addq.w	#1,d2			; Count
.Next9:	addq.w	#Spell_data_size,a2	; Next spell
	addq.w	#1,d7
	cmp.w	#Max_spells,d7
	bls.s	.Loop9
.Not_1:	move.l	Monster_spells_3,d0		; Try class 3
	beq	.Not_3
	lea.l	Spell_data+3*Max_spells*Spell_data_size,a2	; Check spells
	moveq.l	#1,d7
.Loop10:	btst	d7,d0			; Spell available ?
	beq.s	.Next10
	move.b	Spell_target_bits(a2),d3	; Yes -> Correct target ?
	btst	d1,d3
	beq.s	.Next10
	move.b	#3,(a3)+			; Yes -> Insert
	move.b	d7,(a3)+
	addq.w	#1,d2			; Count
.Next10:	addq.w	#Spell_data_size,a2	; Next spell
	addq.w	#1,d7
	cmp.w	#Max_spells,d7
	bls.s	.Loop10
; ---------- Select & enter spell -----------------
.Not_3:	jsr	Random			; Select random spell
	mulu.w	d2,d0
	swap	d0
	lea.l	Monster_spells,a3		; Find info
	add.w	d0,d0
	add.w	d0,a3
	move.b	(a3)+,Part_target+4(a0)	; Enter spell class & number
	move.b	(a3),Part_target+5(a0)
 	move.b	#Cast_spell_action,Part_action(a0)	; Enter action
.Exit:	movem.l	(sp)+,d0-d7/a2/a3
	rts

;*****************************************************************************
; [ Try long-range attack ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
;*****************************************************************************
Try_long_range_attack:
	movem.l	d0-d7/a2-a4,-(sp)
; ---------- Attack possible ? --------------------
	move.w	Body_conditions(a1),d0	; Capable of fighting ?
	andi.w	#Attack_mask,d0
	bne	.Exit
; ---------- Long-range weapon ? ------------------
.Repeat:	lea.l	Char_inventory+Right_hand_slot(a1),a2
	move.w	Object_index(a2),d0		; Get item in right hand
	beq	.Search			; Nothing ?
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	cmp.b	#Longrange_itemtype,Item_type(a2)	; Long range ?
	bne	.Exit
	move.w	Damage(a1),d0		; Get damage
	add.w	Damage_magic(a1),d0
	tst.w	d0			; Any ?
	beq	.Search
; ---------- Check long-range weapon --------------
	lea.l	Char_inventory+Left_hand_slot(a1),a3
	move.w	Object_index(a3),d0		; Get item in left hand
	move.b	Ammo_use_ID(a2),d1		; Get required ammo ID
	beq	.Attack			; (if any!)
	tst.w	d0			; Anything ?
	beq	.Drop
	move.l	Object_data_ptr,a3		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a3
	cmp.b	Ammo_ID(a3),d1		; Is correct ?
	beq	.Attack
; ---------- Drop weapon --------------------------
.Drop:	move.l	a0,-(sp)			; Put away
	lea.l	Char_inventory+Right_hand_slot(a1),a0
	jsr	Put_item_in_apres_pool
	move.l	(sp)+,a0
	move.b	Part_handle(a0),d0		; Remove
	moveq.l	#Right_hand+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.w	#231,d0			; " dropped weapon."
	jsr	Do_part_prompt
; ---------- Search weapon ------------------------
.Search:	jsr	Search_another_weapon
	tst.w	d7			; Found any ?
	bmi.s	.Exit
	bne.s	.Attack			; Yes -> Long- or close-range ?
	jsr	Select_close_range_target	; Close range
	bra.s	.Exit
; ---------- Attack -------------------------------
.Attack:	jsr	Select_long_range_target	; Select
.Exit:	movem.l	(sp)+,d0-d7/a2-a4
	rts

;*****************************************************************************
; [ Select long-range target ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
;*****************************************************************************
Select_long_range_target:
	movem.l	d0/d1,-(sp)
	jsr	Get_longrange_targets	; Get targets
	tst.l	d0			; Any ?
	beq.s	.Exit
	jsr	Select_monster_target	; Yes -> Select
	move.w	d1,Part_target(a0)		; Store
	move.b	#Long_range_action,Part_action(a0)
.Exit:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Try short-range attack ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
;*****************************************************************************
Try_close_range_attack:
	movem.l	d0/d7/a2/a3,-(sp)
; ---------- Attack possible ? --------------------
	move.w	Body_conditions(a1),d0	; Capable of fighting ?
	andi.w	#Attack_mask,d0
	bne	.Exit
; ---------- Close-range weapon ? -----------------
.Repeat:	lea.l	Char_inventory+Right_hand_slot(a1),a2
	move.w	Object_index(a2),d0		; Get item in right hand
	beq.s	.Empty			; Nothing ?
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	cmp.b	#Closerange_itemtype,Item_type(a2)	; Close range ?
	bne	.Exit
.Empty:	move.w	Damage(a1),d0		; Get damage
	add.w	Damage_magic(a1),d0
	tst.w	d0			; Any ?
	bne	.Yes
; ---------- Search weapon ------------------------
	jsr	Search_another_weapon	; No
	tst.w	d7			; Found any ?
	bmi	.Exit
	beq.s	.Yes			; Yes -> Long- or close-range ?
	jsr	Select_long_range_target	; Long-range
	bra	.Exit
; ---------- Attack -------------------------------
.Yes:	jsr	Select_close_range_target	; Select
.Exit:	movem.l	(sp)+,d0/d7/a2/a3
	rts

;*****************************************************************************
; [ Select long-range target ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
;*****************************************************************************
Select_close_range_target:
	movem.l	d0-d6,-(sp)
; ---------- Anything attackable ? ----------------
	jsr	Get_closerange_targets	; Get possible targets
	tst.l	d0			; Any ?
	bne	.Attack
; ---------- Move where ? -------------------------
	jsr	Get_occupied_targets	; Get occupied targets
	move.l	d0,d1
	jsr	Check_movement_range	; Get movement range
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	tst.l	d0			; Any left ?
	beq	.Just
	move.l	d0,d5			; Yes
	moveq.l	#0,d1			; Coordinates
	moveq.l	#0,d2
	moveq.l	#0,d3			; Complete mask
	moveq.l	#0,d6			; Search movement range
.Loop2:	btst	d6,d5			; In range ?
	beq.s	.Next2
	move.w	d2,d0			; Get close-range targets
	jsr	Do_closerange_targets
	or.l	d0,d3
.Next2:	addq.w	#1,d2			; Next
	cmp.w	#6,d2
	bmi.s	.No
	moveq.l	#0,d2
	addq.w	#1,d1
.No:	addq.w	#1,d6
	cmp.w	#4*6,d6
	bmi.s	.Loop2
	tst.l	d3			; Any targets in reach ?
	bne.s	.Move
; ---------- Just move ----------------------------
.Just:	jsr	Just_move_monster		; No -> Just move
	bra	.Exit
; ---------- Move towards a target ----------------
.Move:	move.l	d3,d0			; Select target
	jsr	Select_monster_target
	move.w	d1,d3
	moveq.l	#0,d1			; Coordinates
	moveq.l	#0,d2
	moveq.l	#0,d6			; Search movement range
.Loop3:	btst	d6,d5			; In range ?
	beq.s	.Next3
	move.w	d2,d0			; Get close-range targets
	jsr	Do_closerange_targets
	btst	d3,d0			; Is this the one ?
	beq.s	.Next3
	move.w	#1,Part_target(a0)		; Store
	move.w	d6,Part_target+2(a0)
	move.b	#Move_action,Part_action(a0)
	bra	.Exit
.Next3:	addq.w	#1,d2			; Next
	cmp.w	#6,d2
	bmi.s	.No2
	moveq.l	#0,d2
	addq.w	#1,d1
.No2:	addq.w	#1,d6
	cmp.w	#4*6,d6
	bmi.s	.Loop3
	bra	.Exit			; (shouldn't occur)
; ---------- Attack a target ----------------------
.Attack:	jsr	Select_monster_target	; Select target
	move.w	d1,Part_target(a0)		; Store
	move.b	#Close_range_action,Part_action(a0)
.Exit:	movem.l	(sp)+,d0-d6
	rts

;*****************************************************************************
; [ Select target for monster ]
;   IN : d0 - Possible target bit-list (.l)
;        a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
;  OUT : d1 - Target number {0...23} (.w)
; Changed registers : d1
; Notes :
;   - This is an internal routine.
;*****************************************************************************
Select_monster_target:
	movem.l	d0/d2-d5/d7/a2/a3,-(sp)
;----------- Find strongest targets ---------------
	lea.l	Combat_matrix,a2
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d7
.Loop:	btst	d7,d0			; Target ?
	beq.s	.Next
	move.l	(a2),a3			; Yes -> Get data
	move.w	Part_mean_damage(a3),d5	; Get mean damage
	cmp.w	d5,d1			; More mean damage ?
	bgt.s	.Next
	bmi.s	.New			; No -> Same ?
	bset	d7,d2			; Yes -> Mark
	addq.w	#1,d3
	bra.s	.Next
.New:	move.w	d5,d1			; More
	moveq.l	#0,d2
	bset	d7,d2
	moveq.l	#1,d3
.Next:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#6*5,d7
	bmi.s	.Loop
	LOCAL
; ---------- Choose one ---------------------------
	jsr	Random			; Select
	mulu.w	d3,d0
	swap	d0
	moveq.l	#0,d1
.Loop:	btst	d1,d2			; Target ?
	beq.s	.Next
	tst.w	d0			; Selected ?
	beq.s	.Exit
	subq.w	#1,d0			; Count down
.Next:	addq.w	#1,d1			; Next
	cmp.w	#6*5,d1
	bmi.s	.Loop
	moveq.l	#0,d1			; (shouldn't occur)
.Exit:	movem.l	(sp)+,d0/d2-d5/d7/a2/a3
	rts

;*****************************************************************************
; [ Just move monster forward ]
;   IN : d5 - Movement range (.l)
;        a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
;  OUT : d5 - New movement range (.l)
; Changed registers : d5
; Notes :
;   - This is an internal routine.
;*****************************************************************************
Just_move_monster:
	movem.l	d0-d3/d7/a2,-(sp)
	lea.l	Part_target(a0),a2		; Reset number of moves
	clr.w	(a2)+
	move.w	Part_X(a0),d0		; Get coordinates
	move.w	Part_Y(a0),d1
	move.w	d1,d2			; Get tactic index
	mulu.w	#6,d2
	add.w	d0,d2
	move.w	ASpeed(a1),d7		; Get movement speed
	add.w	ASpeed+Magic(a1),d7
	ext.l	d7			; Determine range
	divs.w	#Move_speed_factor,d7
	tst.w	d7			; Clip below
	bne.s	.Below_OK
	moveq.l	#1,d7
	bra.s	.Ok
.Below_OK:	cmp.w	#3+1,d7			; Clip above
	bmi.s	.Ok
	moveq.l	#3,d7
.Ok:	bra	.Entry
.Loop:	cmp.w	#3,d1			; Downest ?
	bne	.Down
	move.w	d2,d3			; Yes -> Try left/right
	jsr	Offensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	beq	.Done
	bclr	d3,d5			; Yes -> No turning back !
	bra	.Next
.Down:	move.w	d2,d3			; Down possible ?
	addq.w	#6,d3
	btst	d3,d5
	beq.s	.No
	addq.w	#1,d1			; Yes -> Move down
	addq.w	#6,d2
	bra.s	.Next
.No:	addq.w	#1,d1			; No -> Move down...
	addq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Offensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	bne.s	.Next
	subq.w	#1,d1			; No -> Move back up...
	subq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Offensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	beq.s	.Done
	bclr	d3,d5			; Yes -> No turning back !
.Next:	move.w	d2,(a2)+			; Store move
	addq.w	#1,Part_target(a0)
.Entry:	dbra	d7,.Loop			; Next step
.Done:	LOCAL
	tst.w	Part_target(a0)		; Moved ?
	beq.s	.Exit
	move.b	#Move_action,Part_action(a0)	; Set action
.Exit:	movem.l	(sp)+,d0-d3/d7/a2
	rts

;*****************************************************************************
; [ Try OFFENSIVE movement to the left or to the right ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Tactic index {0...29} (.w)
;        d5 - Movement range mask (.l)
;  OUT : d0 - New X-coordinate (.w)
;        d2 - New tactic index {0...29} (.w)
; Changed registers : d0,d2
; Notes :
;   - This is an internal routine.
;*****************************************************************************
Offensive_left_or_right:
	movem.l	d3/d7/a0/a1,-(sp)
; ---------- Both left & right possible ? ---------
	tst.w	d0			; Leftest ?
	beq.s	.Right1
	cmp.w	#5,d0			; Rightest ?
	beq.s	.Left1
	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq.s	.Right1
	addq.w	#2,d3			; Right possible ?
	btst	d3,d5
	beq.s	.Left1
; ---------- Which is better ? --------------------
	lea.l	Combat_matrix+3*6*4,a0	; Check matrix
	moveq.l	#0,d3
	moveq.l	#0,d7
.Loop:	cmp.w	d0,d7			; Directly below ?
	beq	.Next
	tst.l	(a0)			; Anything in top row ?
	beq.s	.Bottom
	move.l	(a0),a1			; Is enemy ?
	cmp.b	#1,Part_type(a1)
	bne.s	.Bottom
	cmp.w	d7,d0			; Left or right ?
	bmi.s	.Right3
	sub.w	Part_mean_damage(a1),d3	; Left
	bra.s	.Bottom
.Right3:	add.w	Part_mean_damage(a1),d3	; Right
.Bottom:	tst.l	6*4(a0)			; Anything in bottom row ?
	beq.s	.Next
	move.l	(a0),a1			; Is enemy ?
	cmp.b	#1,Part_type(a1)
	bne.s	.Next
	cmp.w	d7,d0			; Left or right ?
	bmi.s	.Right4
	sub.w	Part_mean_damage(a1),d3	; Left
	bra.s	.Next
.Right4:	add.w	Part_mean_damage(a1),d3	; Right
.Next:	addq.l	#4,a0			; Next column
	addq.w	#1,d7
	cmp.w	#6,d7
	bmi.s	.Loop
	tst.w	d3			; Move where ?
	beq	.Exit
	bmi.s	.Left2
	bra.s	.Right2
; ---------- Try to move right --------------------
.Right1:	move.w	d2,d3			; Right possible ?
	addq.w	#1,d3
	btst	d3,d5
	beq	.Exit
.Right2:	addq.w	#1,d0			; Move right
	addq.w	#1,d2
	bra	.Exit
; ---------- Try to move left ---------------------
.Left1:	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq	.Exit
.Left2:	subq.w	#1,d0			; Move left
	subq.w	#1,d2
.Exit:	movem.l	(sp)+,d3/d7/a0/a1
	rts

;*****************************************************************************
; [ Process damage done by participant ]
;   IN : d0 - Amount of damage (.w)
;        a0 - Pointer to attacker's participant data (.l)
; All registers are restored
;*****************************************************************************
Process_damage:
	movem.l	d0-d2,-(sp)
	moveq.l	#0,d1			; Count up
	move.b	Part_nr_attacks(a0),d1
	addq.b	#1,d1
	bne.s	.Ok			; Too much ?
	move.b	#255,d1			; Yes -> Clip
.Ok:	move.b	d1,Part_nr_attacks(a0)
	move.l	Part_total_damage(a0),d2	; Add to total damage
	andi.l	#$0000ffff,d0	
	add.l	d0,d2
	move.l	d2,Part_total_damage(a0)
	divu.w	d1,d2			; Calculate mean damage
	move.w	d2,Part_mean_damage(a0)
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Calculate global danger ]
; All registers are restored
; Notes :
;	  0...49 - Monsters advantage
;	      50 - No advantage
;	51...100 - Party advantage
;*****************************************************************************
Calculate_global_danger:
	movem.l	d0-d2/d7/a0/a1,-(sp)
	lea.l	Combat_matrix,a0		; Search matrix
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#30-1,d7
.Loop:	tst.l	(a0)			; Anything there ?
	beq.s	.Next
	move.l	(a0),a1			; Yes
	moveq.l	#0,d2			; Get mean damage
	move.w	Part_mean_damage(a1),d2
	cmp.b	#1,Part_type(a1)		; Party or monster ?
	bne.s	.Monster
	add.l	d2,d0			; Party
	bra.s	.Next
.Monster:	add.l	d2,d1			; Monster
.Next:	addq.l	#4,a0			; Next entry
	dbra	d7,.Loop
	tst.l	d0			; Clip total mean damages
	bne.s	.Ok1
	moveq.l	#1,d0
	bra.s	.Clip1
.Ok1:	cmp.l	#32767,d0
	bmi.s	.Clip1
	move.l	#32767,d0
.Clip1:	tst.l	d1
	bne.s	.Ok2
	moveq.l	#1,d1
	bra.s	.Clip2
.Ok2:	cmp.l	#32767,d1
	bmi.s	.Clip2
	move.l	#32767,d1
.Clip2:	mulu.w	#50,d0			; Calculate global danger
	divu.w	d1,d0
	cmp.w	#100,d0			; Too high ?
	bmi.s	.Ok3
	moveq.l	#100,d0			; Yes
.Ok3:	move.w	d0,Global_danger		; Store
	movem.l	(sp)+,d0-d2/d7/a0/a1
	rts

;*****************************************************************************
; [ Search & equip new weapon for monster ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
;  OUT : d7 -  0 = Found close-range weapon
;              1 = Found long-range weapon
;             -1 = Found nothing
; All registers are restored
; Notes :
;   - Whatever calls this routine assumes a weapon is equipped and ready.
;*****************************************************************************
Search_another_weapon:
	movem.l	d0-d3/a2-a4,-(sp)
; ---------- Search another weapon ----------------
	lea.l	Char_inventory+Backpack_slots(a1),a2
	moveq.l	#9+1,d2
.Loop1:	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Next1
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Broken ?
	bne.s	.Next1
	move.l	Object_data_ptr,a3		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a3
	cmp.b	#Closerange_itemtype,Item_type(a3)	; Close range ?
	bne.s	.No
	moveq.l	#0,d7			; Yes
	bra	.Found_weapon
.No:	cmp.b	#Longrange_itemtype,Item_type(a3)	; Long range ?
	bne.s	.Next1
	moveq.l	#1,d7			; Yes
	bra.s	.Found_longrange
.Next1:	addq.w	#Object_packet_size,a2	; Next slot
	addq.w	#1,d2
	cmp.w	#9+Items_per_char+1,d2
	bmi.s	.Loop1
	move.w	Damage(a1),d0		; Get damage
	add.w	Damage_magic(a1),d0
	tst.w	d0			; Any ?
	beq.s	.Panic
	moveq.l	#0,d7			; Yes -> Close-range attack
	bra	.Exit
.Panic:	bclr	#Part_long_cap,Part_flags(a0)	; Not capable
	bclr	#Part_close_cap,Part_flags(a0)
	move.b	Courage(a1),d0		; Panic!
	lsr.b	#1,d0
	move.b	d0,Courage(a1)
	moveq.l	#-1,d7			; No luck
	bra	.Exit
; ---------- Search ammo for long-range weapon ----
.Found_longrange:
	move.b	Ammo_use_ID(a3),d1		; Get required ammo
	beq	.Found_weapon		; (if any)
	lea.l	Char_inventory+Backpack_slots(a1),a3
	moveq.l	#9+1,d3
.Loop2:	move.w	Object_index(a3),d0		; Any object ?
	beq.s	.Next2
	btst	#Broken_item,Item_bits_DYNAMIC(a3)	; Broken ?
	bne.s	.Next1
	move.l	Object_data_ptr,a4		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a4
	cmp.b	Ammo_ID(a4),d1		; Right ammo ?
	beq.s	.Found_ammo
.Next2:	addq.w	#Object_packet_size,a3	; Next slot
	addq.w	#1,d3
	cmp.w	#Items_per_char+9+1,d3
	bmi.s	.Loop2
	bra.s	.Next1			; Next weapon (!!!)
; ---------- Equip ammunition ---------------------
.Found_ammo:
	move.w	d2,-(sp)
	lea.l	Inter_packet,a4		; Copy packet
	Copy_packet a3,a4
	move.b	Part_handle(a0),d0		; Remove ammo from backpack
	move.w	d3,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.l	a0,-(sp)			; Equip ammo
	move.l	a4,a0
	move.w	#Left_hand+1,d2
	jsr	Add_item_2_body
	move.l	(sp)+,a0
	move.w	(sp)+,d2
; ---------- Equip weapon -------------------------
.Found_weapon:
	lea.l	Inter_packet,a3		; Copy packet
	Copy_packet a2,a3
	move.b	Part_handle(a0),d0		; Remove weapon from backpack
	moveq.l	#1,d3
	jsr	Remove_item
	move.l	a0,-(sp)			; Equip weapon
	lea.l	Inter_packet,a0
	move.w	#Right_hand+1,d2
	jsr	Add_item_2_body
	move.l	(sp)+,a0
.Exit:	movem.l	(sp)+,d0-d3/a2-a4
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_BSS,bss
Monster_magic_target:	ds.b 1
	even
Monster_single_target:	ds.l 1
Monster_spells_1:	ds.l 1
Monster_spells_3:	ds.l 1
Monster_spells:	ds.w Max_monster_spells
