; Time update routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 25-6-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Initialize time ]
; All registers are restored
;*****************************************************************************
Init_time:
	movem.l	d0/d1,-(sp)
	move.w	Hour,d0			; Calculate current	step
	mulu.w	#Minutes_per_hour,d0
	moveq.l	#0,d1
	move.w	Minute,d1
	add.l	d1,d0
	divu.w	#Minutes_per_step,d0
	move.w	d0,Current_step
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Update time (next step) ]
; All registers are restored
;*****************************************************************************
Update_time:
	move.l	d0,-(sp)
	st	New_step			; Signal
; --------- Next 5 minutes ------------------------
	addq.w	#1,Current_step		; Update current step
	move.w	Minute,d0			; Update minute
	opt	o5-				; (not optimized by the original assembler)
	addi.w	#Minutes_per_step,d0
	opt	o5+
	move.w	d0,Minute
	jsr	Every_step		; Step logic
	subi.w	#Minutes_per_hour,d0	; Next hour ?
	bmi	.Exit
	move.w	d0,Minute
; --------- Next hour -----------------------------
	move.w	Hour,d0			; Update hour
	addq.w	#1,d0
	move.w	d0,Hour
	jsr	Every_hour		; Hour logic
	subi.w	#Hours_per_day,d0		; Next day ?
	bmi	.Exit
	move.w	d0,Hour
; --------- Next day ------------------------------
	move.w	#0,Current_step		; Reset current step
	move.w	Day,d0			; Update day
	addq.w	#1,d0
	move.w	d0,Day
	jsr	Every_day			; Day logic
	subi.w	#Days_per_month,d0		; Next month ?
	bls.s	.Exit
	move.w	d0,Day
; --------- Next month ----------------------------
	move.w	Month,d0			; Update month
	addq.w	#1,d0
	move.w	d0,Month
	subi.w	#Months_per_year,d0		; Next year ?
	bls.s	.Exit
	move.w	d0,Month
; --------- Next year -----------------------------
	addq.w	#1,Year			; Update year
	addq.w	#1,Time_data_year		; Update age offset
	jsr	Every_year		; Year logic
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Every step logic ]
; All registers are restored
;*****************************************************************************
Every_step:
	movem.l	d7/a0,-(sp)
	cmp.b	#Map_3D,Current_map_type
	bmi.s	.No_3D
	jsr	Update_M3_light_level
; --------- Update special spells -----------------
.No_3D:	lea.l	Spell_1_duration,a0
	moveq.l	#6-1,d7
.Loop:	tst.w	(a0)			; Active ?
	beq.s	.Next
	subq.w	#1,(a0)			; Yes -> Count down
	bne.s	.Next			; Zero ?
	clr.w	2(a0)			; Yes -> Clear data
.Next:	addq.l	#4,a0			; Next spell
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Every hour logic ]
; All registers are restored
;*****************************************************************************
Every_hour:
	movem.l	d0/d1/d5-d7/a0-a2,-(sp)
; ---------- Exhaust party members ----------------
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq	.Ok
	move.w	Camp_counter,d0		; Count up
	addq.w	#1,d0
	move.w	d0,Camp_counter
	cmp.w	#Exhaust_time,d0		; Exhausting ?
	bpl.s	.Do
	cmp.w	#Tired_time,d0		; Tiring ?
	bmi	.Ok
	move.w	#224,d0			; Getting tired...
	jsr	Do_prompt_window
	bra	.Ok
.Do:	lea.l	Party_handles,a0		; Yes -> Do !
	moveq.l	#0,d5
	moveq.l	#1,d7
.Loop1:	move.b	(a0),d0			; Anyone there ?
	beq.s	.Next1
	jsr	Claim_pointer
	movea.l	d0,a1
	move.w	Body_conditions(a1),d1
	btst	#Exhausted,d1		; Already exhausted ?
	bne	.Done
	bset	#Exhausted,d1		; Exhaust !
	move.w	d1,Body_conditions(a1)
	addq.w	#1,d5			; Count
	lea.l	Attributes(a1),a2		; Half attributes
	moveq.l	#Max_attrs-1,d6
.Loop2:	move.w	(a2),d0			; Backup
	move.w	d0,Backup(a2)
	lsr.w	#1,d0			; Half !
	move.w	d0,(a2)
	addq.w	#Attr_data_size,a2	; Next attribute
	dbra	d6,.Loop2
	lea.l	Skills(a1),a2		; Half skills
	moveq.l	#Max_skills-1,d6
.Loop3:	move.w	(a2),d0			; Backup
	move.w	d0,Backup(a2)
	lsr.w	#1,d0			; Half !
	move.w	d0,(a2)
	addq.w	#Skill_data_size,a2	; Next skill
	dbra	d6,.Loop3
.Done:	move.b	(a0),d0
	jsr	Free_pointer
.Next1:	addq.l	#1,a0			; Next member
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop1
	tst.w	d5			; Any ?
	beq.s	.Ok
	move.w	#175,d0			; Tell 'em !
	jsr	Do_prompt_window
.Ok:	LOCAL
; --------- Damage party members ------------------
	lea.l	Party_handles,a0
	moveq.l	#1,d7
.Loop:	move.b	(a0),d0			; Anyone there ?
	beq	.Next
	moveq.l	#0,d6			; No damage
	jsr	Claim_pointer
	movea.l	d0,a1
	move.w	#Alive_mask,d0		; Alive and kicking	?
	and.w	Body_conditions(a1),d0
	bne.s	.Done
	move.w	Body_conditions(a1),d1	; Poisoned ?
	btst	#Poisoned,d1
	beq.s	.Not_poisoned
	jsr	Random			; Yes -> Hurt person
	mulu.w	#5,d0
	swap.w	d0
	addq.w	#1,d0
	move.w	d0,d6
.Not_poisoned:
	btst	#Exhausted,d1		; Exhausted ?
	beq.s	.Done
	moveq.l	#0,d0			; Yes -> Hurt person
	move.w	Life_points(a1),d0
	divu.w	#10,d0
	tst.w	d0			; At least one
	bne.s	.Ok
	moveq.l	#1,d0
.Ok:	add.w	d0,d6
.Done:	tst.w	d6			; Any damage ?
	beq.s	.No
	move.w	d6,d0			; Yes -> Do
	jsr	Do_damage
.No:	move.b	(a0),d0
	jsr	Free_pointer
.Next:	addq.l	#1,a0			; Next member
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d1/d5-d7/a0-a2
	rts

;*****************************************************************************
; [ Every day logic ]
; All registers are restored
;*****************************************************************************
Every_day:
	movem.l	d0/d7/a0-a2,-(sp)
; --------- Decrease random attribute of diseased people ---------
	lea.l	Party_handles,a0
	moveq.l	#1,d7
.Loop:	move.b	(a0),d0			; Anyone there ?
	beq.s	.Next
	jsr	Claim_pointer
	movea.l	d0,a1
	move.w	#Alive_mask,d0		; Alive and kicking	?
	and.w	Body_conditions(a1),d0
	bne.s	.No
	move.w	Body_conditions(a1),d0	; Diseased ?
	btst	#Diseased,d0
	beq.s	.No
	lea.l	Attributes(a1),a2		; Choose attribute
	jsr	Random
	mulu.w	#8,d0			; Only first 8 !!!
	swap.w	d0
	mulu.w	#Attr_data_size,d0		; FIX: Was "mulu.w #6,d0" (attributes are 8 bytes)
	adda.w	d0,a2
	cmpi.w	#1,(a2)			; Already	at minimum ?
	beq.s	.Done
	subq.w	#1,(a2)			; Decrease attribute
.Done:	moveq.l	#0,d0			; Display	empty damage star
	jsr	Do_damage
.No:	move.b	(a0),d0
	jsr	Free_pointer
.Next:	addq.l	#1,a0			; Next character
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d7/a0-a2
	rts

;****************************************************************************
; [ Every year logic ]
; All registers are restored
;*****************************************************************************
Every_year:
	movem.l	d0/d1/d7/a0/a1,-(sp)
; --------- Kill old people -----------------------
	lea.l	Party_handles,a0
	moveq.l	#1,d7
.Loop:	move.b	(a0),d0			; Anyone there ?
	beq.s	.Next
	jsr	Claim_pointer
	movea.l	d0,a1
	move.w	#Alive_mask,d0		; Alive and kicking	?
	and.w	Body_conditions(a1),d0
	bne.s	.Next
	move.w	AAge(a1),d0		; Get age & increase
	addq.w	#1,d0
	move.w	d0,AAge(a1)
	add.w	AAge+Magic(a1),d0
					; FIX: Removed "add.w Time_data_year,d0" (age counted twice)
	move.w	AAge+Maximum(a1),d1
	cmp.w	d0,d1			; Too old	?
	bpl.s	.Next
	move.l	a0,-(sp)			; Print "dying..."
	lea.l	Ageddeath_text,a0
	jsr	Print_member_text
	move.l	(sp)+,a0
	jsr	Kill_member		; Kill !
.No:	move.b	(a0),d0
	jsr	Free_pointer
.Next:	addq.l	#1,a0			; Next character
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d1/d7/a0/a1
	rts

;*****************************************************************************
; [ Zzz function ]
; All registers are restored
;*****************************************************************************
Zzz:
	jsr	Update_time		; Next step
	jsr	Wait_4_unclick
	jsr	Save_coordinates		; Save coordinates
	jmp	Game_after_move

;*****************************************************************************
; [ Hourglass function ]
; All registers are restored
;*****************************************************************************
Hourglass:
	tst.b	Big_brother_flag		; Being watched ?
	beq.s	.No
	move.w	#288,d0			; Yes -> "Fool!"
	jsr	Do_prompt_window
	bra.s	.Exit
.No:	move.l	#24,Maximum_number		; Wait for how long ?
	clr.l	Minimum_number
	move.w	#225,InputNr_prompt
	st	ObjGoldFood
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d0		; Any ?
	beq	.Exit
	mulu.w	#Minutes_per_hour/Minutes_per_step,d0	; Wait {x} hours
	bra.s	.Entry
.Wait:	jsr	Update_time
.Entry:	dbra	d0,.Wait
	jsr	Update_light_status
	jsr	Save_coordinates		; Save coordinates
	jsr	Game_after_move
.Exit:	rts

;*****************************************************************************
; [ Realtime step update ]
; All registers are restored
;*****************************************************************************
Realtime:
	move.l	d0,-(sp)
	tst.b	Time_lock			; Locked ?
	bne.s	.Exit
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
; [ Update light status ]
; All registers are restored
;*****************************************************************************
Update_light_status:
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl.s	.3D_map
	jsr	Evaluate_2D_light		; 2D
	move.w	New_light_level,Current_light_level
	bra.s	.Exit
.3D_map:	cmp.b	#City_3D,Current_map_type	; City or dungeon ?
	beq.s	.City
	jsr	Evaluate_D3_light		; Dungeon
	move.w	New_light_level,Current_light_level
	jsr	Set_D3_light_level
	bra.s	.Exit
.City:	jsr	Evaluate_C3_light		; City
	move.w	New_sky_level,Current_sky_level
	move.w	New_light_level,Current_light_level
	jsr	Set_C3_light_level
.Exit:	rts
