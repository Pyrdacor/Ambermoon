; Magic
; Written by J.Horneman (In Tune With The Universe)
; Start : 31-9-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Spell select window module ]
; Note :
;  - This module will exit if no spells are known in this class.
;*****************************************************************************
SpSelW_ModInit:
	clr.w	Selected_spell		; Clear
; ---------- Make list of spells & status ---------
	Get	Active_handle,a0
	move.w	Power_points(a0),d6		; Get magic points
	lea.l	Spells_class_0(a0),a0	; Get known spells bit-list
	move.w	Selected_class,d0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),d3
	Free	Active_handle
	lea.l	Spell_data,a1		; Get pointer to spell data
	move.w	Selected_class,d0
	mulu.w	#Spell_data_size*Max_spells,d0
	adda.w	d0,a1
	lea.l	Spell_table,a0		; Initialize registers
	moveq.l	#0,d1
	moveq.l	#1,d2
	move.w	Selected_class,d7
	mulu.w	#Max_spells,d7
	addq.w	#1,d7

; ---------- REGISTER CONTENTS --------------------
;	d1 - Counter (.w)
;	d2 - Bit index (.w)
;	d3 - Known spells bit-list (.l)
;	d6 - Number of spell points (.w)
;	d7 - Number of first spell name (.w)
;	a0 - Pointer to spell table (.l)
;	a1 - Pointer to spell data (.l)

.Loop:	btst	d2,d3			; Spell known ?
	beq	.Next
	addq.w	#1,d1			; Count
	moveq.l	#0,d5
	move.b	Spell_area_bits(a1),d0	; Right area ?
	move.w	Spell_area_type,d4
	btst	d4,d0
	bne.s	.Area_OK
	moveq.l	#Spell_wrong_area,d0	; No -> Wrong area
	bra.s	.Do
.Area_OK:	move.w	Current_world_nr,d4		; Right world ?
	addq.w	#5,d4
	btst	d4,d0
	bne.s	.World_OK
	moveq.l	#Spell_wrong_world,d0	; No -> Wrong world
	bra.s	.Do
.World_OK:	moveq.l	#0,d0			; Enough spell points ?
	move.b	Spell_point_cost(a1),d0
	beq.s	.Error
	cmp.w	d0,d6
	bpl.s	.Enough
.Error:	moveq.l	#Spell_not_enough_SP,d0	; No -> Not enough SP
	bra.s	.Do
.Enough:	moveq.l	#0,d5			; How many times ?
	move.w	d6,d5
	divu.w	d0,d5
	cmpi.w	#100,d5
	bmi.s	.Ok
	moveq.l	#99,d5
.Ok:	moveq.l	#Spell_OK,d0		; -> Possible spell
.Do:	move.b	d0,(a0)+			; Store spell data
	move.b	d2,(a0)+
	move.b	d5,(a0)+
	move.b	d7,(a0)+
.Next:	addq.w	#Spell_data_size,a1	; Next spell
	addq.w	#1,d7
	addq.w	#1,d2
	cmp.w	#Max_spells+1,d2
	bmi.s	.Loop
	LOCAL
	move.w	d1,Nr_of_spells		; Store number of spells
	move.w	d1,SpSelW_scroll_bar+Total_units
	bne.s	.Do			; Any spells ?
	move.w	#278,d0			; "Fool !"
	jsr	Do_prompt_window
	Pop	Module
	bra.s	.Exit
.Do:	jsr	SpSelW_DisInit		; Yes
.Exit:	rts

SpSelW_DisInit:
	move.w	#SpSelW_X-16,d0		; Open a window
	move.w	#SpSelW_Y-16,d1
	moveq.l	#13,d2
	moveq.l	#10,d3
	lea.l	SpSelW_L1,a0
	jsr	Open_window
	move.w	#SpSelW_X,d0		; Draw box
	move.w	#SpSelW_Y+117,d1
	move.w	#172,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	lea.l	Magic_scroll_bar_positions,a0	; Get old scroll bar position
	move.w	Active_member,d0
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0
	lea.l	SpSelW_scroll_bar,a0	; Display scroll bar
	move.w	d0,Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	jmp	Update_screen

SpSelW_DisExit:
	tst.w	Nr_of_spells		; Any spells ?
	beq.s	.Exit
	jsr	Close_window		; Yes
	lea.l	Magic_scroll_bar_positions,a0	; Store old scroll bar position
	move.w	Active_member,d1
	add.w	d1,d1
	jsr	Get_scroll_bar
	move.w	d0,-2(a0,d1.w)
	Pop	Scroll_bar		; Remove
.Exit:	rts

SpSelW_DisUpd:
	move.w	#SpSelW_X+1,d0		; Erase message
	move.w	#SpSelW_Y+119,d1
	move.w	#SpSelW_X+172,d2
	move.w	#SpSelW_Y+119+6,d3
	moveq.l	#27,d4
	jsr	Draw_box
	jmp	Update_spell_window

Update_spell_window:
	move.w	#SpSelW_X,d0		; Clear spell area
	move.w	#SpSelW_Y,d1
	move.w	#160,d2
	move.w	#113,d3
	jsr	Draw_standard_box
	move.w	Scroll_bar_result,d0	; Get bar position
	move.w	Nr_of_spells,d2		; Show how many spells ?
	sub.w	d0,d2
	cmp.w	#16,d2
	bls.s	.Ok
	moveq.l	#16,d2
.Ok:	lea.l	Spell_table,a1		; Skip
	move.l	Spell_names_ptr,a2
	lsl.w	#2,d0
	add.w	d0,a1
	move.w	#SpSelW_Y+2,d1
	bra	.Entry
.Loop:	tst.b	(a1)			; Spell OK ?
	bne.s	.Wrong
	move.w	#31,Ink_colour		; Yes
	bra.s	.Go_on
.Wrong:	move.w	#28,Ink_colour		; No
.Go_on:	move.l	a2,a0			; Print spell name
	move.b	3(a1),d0
	andi.w	#$00ff,d0
	subq.w	#1,d0
	jsr	Find_small_text
	move.w	#SpSelW_X+4,d0
	jsr	Put_text_line
	move.b	2(a1),d0			; Possible ?
	beq.s	.Next
	lea.l	Number,a0			; Convert number
	move.b	#"(",(a0)+
	moveq.l	#2,d7
	jsr	DecL_convert
	move.b	#")",(a0)+
	clr.b	(a0)
	move.w	#SpSelW_X+132,d0		; Print number
	lea.l	Number,a0
	jsr	Put_text_line
.Next:	addq.w	#7,d1			; Next spell
	addq.l	#4,a1
.Entry:	dbra	d2,.Loop
	rts

Spell_selected:
	lsr.w	#8,d0			; Clicked on a spell ?
	tst.b	d0
	beq	.Exit
	move.w	d0,d7			; Save
	add.w	Scroll_bar_result,d0	; Calculate slot number
	cmp.w	Nr_of_spells,d0		; Empty slot ?
	bhi	.Exit
	lea.l	Spell_table-4,a0		; Get spell data
	lsl.w	#2,d0
	add.w	d0,a0
	tst.b	(a0)			; Possible spell ?
	bne	.Exit
	moveq.l	#0,d0			; Get spell number
	move.b	1(a0),d0
	move.w	d0,Selected_spell
	moveq.l	#0,d0			; Get spell name
	move.b	3(a0),d0
	move.l	Spell_names_ptr,a0
	subq.w	#1,d0
	jsr	Find_small_text
	move.w	#26,Ink_colour		; Set colours
	move.w	#31,Shadow_colour
	move.w	d7,d1			; Print it
	subq.w	#1,d1
	mulu.w	#Char_height+2,d1
	addi.w	#SpSelW_Y+2,d1
	move.w	#SpSelW_X+4,d0
	jsr	Put_text_line
	move.w	#0,Shadow_colour		; Reset
	jsr	Update_screen
	jsr	Wait_4_unclick
	Pop	Module
.Exit:	rts

Spell_touched:
	lsr.w	#8,d0			; Clicked on a spell ?
	tst.b	d0
	beq	.Exit
	move.w	d0,d7			; Save
	add.w	Scroll_bar_result,d0	; Calculate slot number
	cmp.w	Nr_of_spells,d0		; Empty slot ?
	bhi	.Exit
	lea.l	Spell_table-4,a0		; Get spell data
	lsl.w	#2,d0
	add.w	d0,a0
	tst.b	(a0)			; Possible spell ?
	beq	.Ok
	move.w	#31,Ink_colour		; No
	move.w	#SpSelW_X+1,d0		; Erase previous message
	move.w	#SpSelW_Y+119,d1
	move.w	#SpSelW_X+172,d2
	move.w	#SpSelW_Y+119+6,d3
	moveq.l	#27,d4
	jsr	Draw_box
	move.w	#SpSelW_X+1,d0		; Print error message
	move.w	#SpSelW_Y+119,d1
	move.w	#172,d2
	cmp.b	#Spell_not_enough_SP,(a0)	; Not enough SP ?
	bne.s	.Not_SP
	moveq.l	#26,d3			; Yes
	bra.s	.Do
.Not_SP:	cmp.b	#Spell_wrong_area,(a0)	; Wrong area ?
	bne.s	.Not_area
	moveq.l	#27,d3			; Yes
	bra.s	.Do
.Not_area:	move.w	#241,d3			; No -> Wrong world
.Do:	jsr	Print_centered_prompt	; Tell 'em
	bra	.Exit
.Ok:	moveq.l	#0,d0			; Get spell name
	move.b	3(a0),d0
	move.l	Spell_names_ptr,a0
	subq.w	#1,d0
	jsr	Find_small_text
	move.w	#0,Ink_colour		; Set colours
	move.w	#-1,Shadow_colour
	move.w	d7,d1			; Get coordinates
	subq.w	#1,d1
	mulu.w	#Char_height+2,d1
	addi.w	#SpSelW_Y+1,d1
	move.w	#SpSelW_X+1,d0
	move.w	d0,d2			; Draw highlighting box
	move.w	d1,d3
	addi.w	#158,d2
	add.w	#Char_height+1,d3
	moveq.l	#31,d4
	jsr	Draw_box
	addq.w	#3,d0			; Print it
	addq.w	#1,d1
	jsr	Put_text_line
	move.w	#0,Shadow_colour		; Reset
.Exit:	rts

;*****************************************************************************
; [ Do magic ]
; All registers are restored
; Notes :
;   - [ Selected_class ], [ Selected_spell ], [ Casting_member ] and
;     [ Casting_handle ] must have been set.
;*****************************************************************************
Do_magic:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Spell_data,a0		; Get pointer to spell data
	move.w	Selected_class,d0
	mulu.w	#Max_spells,d0
	add.w	Selected_spell,d0
	subq.w	#1,d0
	mulu.w	#Spell_data_size,d0
	adda.w	d0,a0
	moveq.l	#0,d0			; Get target bits
	move.b	Spell_target_bits(a0),d0
	btst	#Special_target_bit,d0	; Special spell ?
	bne	.Done
.Target:	btst	#Item_target_bit,d0		; Item target ?
	beq	.Not_item
	move.w	#237,MemberSel_prompt	; Whose item ?
	move.l	#Inventory_check,MemberSel_ptr
	Push	Module,MemberSel_Mod
	move.w	Selected_member,d1		; Anyone ?
	beq	.Exit2
	tst.b	Magic_object_flag		; Already in Inventory ?
	beq.s	.Enter
	move.w	d1,d0			; Yes -> Change to target
	lsl.w	#8,d0			;   inventory
	jsr	Inv2_Mright
	move.w	#240,ItemSelect_prompt	; Select item
	Push	Module,Inv2B_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	bra.s	.Go_on
.Enter:	move.w	d1,d0			; No -> Enter Inventory
	lsl.w	#8,d0
	jsr	Member_right
	st	Switch_back		; Switch back !
	move.w	#240,ItemSelect_prompt	; Select item
	Push	Module,Inv2B_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
.Go_on:	move.w	d0,Magic_target_slot	; Store target slot (0-32)  
	move.w	Selected_member,Magic_target_mask	; Store target member
	bra.s	.Done
.Not_item:	btst	#Single_target_bit,d0	; Single target ?
	beq.s	.Multiple
	tst.b	Magic_object_flag		; From object ?
	beq.s	.No
	move.w	#284,MemberSel_prompt	; Yes
	bra.s	.Go_on2
.No:	move.w	#235,MemberSel_prompt	; No
.Go_on2:	move.l	#Present_check,MemberSel_ptr	; Who ?
	Push	Module,MemberSel_Mod
	move.w	Selected_member,d0		; No-one ?
	beq	.Exit
	moveq.l	#1,d1			; Store target mask
	lsl.w	d0,d1
	move.w	d1,Magic_target_mask
	sf	Spell_multiple_target
	bra.s	.Done
.Multiple:	move.w	#%01111110,Magic_target_mask	; Everyone
	st	Spell_multiple_target
.Done:	lea.l	Magic_class_ptrs,a1		; Get spell list address
	move.w	Selected_class,d0
	lsl.w	#2,d0
	move.l	0(a1,d0.w),d0
	beq	.Exit
	move.l	d0,a1
	move.w	Selected_spell,d0		; Get spell handler address
	lsl.w	#2,d0
	move.l	-4(a1,d0.w),d0
	beq	.Exit
	move.l	d0,a1
	jsr	(a1)			; Execute
.Exit:	tst.b	Switch_back		; Switch back ?
	beq.s	.Exit2
	sf	Switch_back		; Yes
	jsr	Exit_Inv2			; Leave Inventory
.Exit2:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Handle spell ]
;  OUT : eq - Spell succeeded
;        ne - Spell failed
; All registers are restored
;*****************************************************************************
Handle_spell:          
	movem.l	d0/d1/a0,-(sp)
	tst.b	Magic_object_flag		; From object ?
	beq.s	.Real
	tst.b	Battling			; Yes -> In combat ?
	beq.s	.No1
	move.l	Casting_participant,a0	; Yes
	moveq.l	#0,d0
	move.b	Part_target+7(a0),d0
	bra.s	.Do
.No1:	move.w	Casting_item_slot,d0	; No
.Do:	jsr	Remove_used_magic_item	; Remove item
	sf	Spell_failed		; Success !
	bra	.Exit
.Real:	lea.l	Spell_data,a0		; Get pointer to spell data
	move.w	Selected_class,d0
	mulu.w	#Max_spells,d0
	add.w	Selected_spell,d0
	subq.w	#1,d0
	mulu.w	#Spell_data_size,d0
	adda.w	d0,a0
	moveq.l	#0,d0			; Get SP cost
	move.b	Spell_point_cost(a0),d0
	Get	Casting_handle,a0		; Remove SP
	move.w	Power_points(a0),d1
	sub.w	d0,d1
	bpl.s	.Ok
	moveq.l	#0,d1			; (should never happen)
.Ok:	move.w	d1,Power_points(a0)
	move.w	SUse_magic(a0),d0		; Get magic using skill
	add.w	SUse_magic+Magic(a0),d0
	Free	Casting_handle
	jsr	Probe_100			; Probe
	smi	Spell_failed		; Set flag
	bpl.s	.Exit
	tst.b	Battling			; In combat ?
	beq	.No2
	move.w	#242,d0			; Yes -> " failed!"
	move.l	Casting_participant,a0
	jsr	Do_part_prompt
	bra.s	.Exit
.No2:	move.w	#248,d0			; No -> "Spell failed!"
	jsr	Do_prompt_window
.Exit:	movem.l	(sp)+,d0/d1/a0
	tst.b	Spell_failed		; Success ?
	rts

;*****************************************************************************
; [ Do all targets ]
;   IN : a0 - Pointer to routine (.l)
; All registers are restored
;*****************************************************************************
Do_all_targets:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a2			; Save
	lea.l	Party_handles,a1		; Do all targets
	move.w	Magic_target_mask,d0
	moveq.l	#1,d7
.Loop:	tst.b	(a1)			; Anyone there ?
	beq.s	.Next
	btst	d7,d0			; Yes -> Targeted ?
	beq.s	.Next
	move.b	(a1),Subject_handle		; Yes -> Is subject
	Get	(a1),a0			; Do
	movem.l	d0/d7/a1/a2,-(sp)
	jsr	(a2)
	movem.l	(sp)+,d0/d7/a1/a2
	Free	(a1)
.Next:	addq.l	#1,a1			; Next party member
	addq.w	#1,d7
	cmp.w	#6,d7
	bls.s	.Loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Remove used magic item ]
;   IN : d0 - Slot number {1...33} (.w)
; All registers are restored
;*****************************************************************************
Remove_used_magic_item:
	movem.l	d0/d2/d3/a0/a1,-(sp)
	move.w	d0,d2			; Save
	Get	Casting_handle,a0		; Get object packet
	lea.l	Char_inventory(a0),a0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a0
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a0),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple ?
	bne.s	.Remove
	cmpi.b	#255,Charges(a0)		; No -> Infinite charges ?
	beq.s	.Sparkle
	subq.b	#1,Charges(a0)		; No -> One charge less
.Sparkle:	Free	Casting_handle
	jsr	Get_module_ID		; In Inventory ?
	cmp.b	#Inv2_ID,d0
	bne	.Exit
	move.w	Casting_member,d0		; In the RIGHT Inventory ?
	cmp.w	Inventory_member,d0
	bne	.Exit
	move.w	d2,d0			; Yes -> Sparkle
	subq.w	#1,d0
	jsr	Sparkle_object
	jsr	Try_to_break_item		; Try to break it
	bra	.Exit
.Remove:	Free	Casting_handle
	move.b	Casting_handle,d0		; Remove item
	moveq.l	#1,d3
	jsr	Remove_item
	jsr	Get_module_ID		; In Inventory ?
	cmp.b	#Inv2_ID,d0
	bne.s	.Exit
	move.w	Casting_member,d0		; In the RIGHT Inventory ?
	cmp.w	Inventory_member,d0
	bne.s	.Exit
	move.w	d2,d0			; Yes
	cmp.w	#9+1,d0			; Body or backpack ?
	bpl.s	.Backpack
	jsr	Display_body_object		; Body
	bra.s	.Done
.Backpack:	sub.w	Scroll_bar_result,d0	; Backpack
	subi.w	#9,d0
	jsr	Display_object
.Done:	jsr	Update_screen		; Boom!
	move.w	d2,d0
	jsr	Used_item_is_destroyed
.Exit:	movem.l	(sp)+,d0/d2/d3/a0/a1
	rts

;*****************************************************************************
; [ Spell handlers - NORMAL / PARTY ]
; No registers are restored
;*****************************************************************************

; ********** Class 0 spells ***********************
; *** Healing spells ***
Healing:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Heal ]
;   IN : d7 - Target member number [1...6] (.w)
;        a0 - Pointer to target character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit2
	move.w	Selected_spell,d0		; Get max LP percentage
	moveq.l	#0,d1
	move.b	.Table-1(pc,d0.w),d1
	bmi.s	.Exit2
	move.w	Life_points+Maximum(a0),d0	; Calculate added LP
	mulu.w	d1,d0
	divu.w	#100,d0
	tst.w	d0
	bne.s	.Notzero
	moveq.l	#1,d0
.Notzero:	jsr	Increase_LP		; Add
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

.Table:	dc.b 10,-1,-1,-1
	dc.b -1,-1,-1,25
	dc.b -1,-1,50,-1
	dc.b -1,-1,-1,-1
	dc.b -1,75,25,-1
	dc.b -1,-1,-1,-1
	dc.b -1,-1,-1,-1
	dc.b -1,-1
	even

; *** Remove condition spells ***
Remove_cond:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Remove condition ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Can be healed ?
	andi.w	#Heal_mask,d0
	bne.s	.Exit2
	move.w	Selected_spell,d0		; Get condition
	move.b	.Table-1(pc,d0.w),d0
	bmi.s	.Exit2
	move.w	Body_conditions(a0),d1	; Remove
	bclr	d0,d1
	move.w	d1,Body_conditions(a0)
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

.Table:	dc.b -1,Panicked,Panicked,Blind
	dc.b Blind,Diseased,Diseased,-1
	dc.b Poisoned,Poisoned,-1,-1
	dc.b -1,-1,-1,-1
	dc.b -1,-1,-1,-1
	dc.b Lamed,Lamed,Aging,Aging
	dc.b Petrified,Asleep,Irritated,Stoned
	dc.b Mad,-1
	even

; *** Wake the dead ***
Wake_the_dead:
	jsr	Handle_spell		; Handle spell
	bne.s	.Fail
	lea.l	.Do1,a0			; Do all targets
	bra.s	.Go
.Fail:	lea.l	.Do2,a0
.Go:	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Wake the dead ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do1:
	move.w	Body_conditions(a0),d0	; Get conditions
	btst	#Dust,d0			; Ashes or dust ?
	bne.s	.Yes
	btst	#Ashes,d0
	beq.s	.No
.Yes:	move.w	#250,d0			; No can do!
	jsr	Do_prompt_window
	bra.s	.Exit2
.No:	btst	#Dead,d0			; Dead ?
	bne.s	.Dead
	move.w	#249,d0			; No!
	jsr	Do_prompt_window
	bra.s	.Exit2
.Dead:	bclr	#Dead,d0			; Arise!
	move.w	d0,Body_conditions(a0)
	move.w	#1,Life_points(a0)
	jsr	Force_status_update		; Show
	move.w	#57,d0			; "Yay!"
	jsr	Do_prompt_window
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

; [ Change dead body to ashes ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do2:
	move.w	Body_conditions(a0),d0	; Get conditions
	btst	#Dead,d0			; Dead ?
	beq.s	.Exit3
	bclr	#Dead,d0			; Change !
	bset	#Ashes,d0
	move.w	d0,Body_conditions(a0)
	move.w	#256,d0			; "Sob!"
	jsr	Do_prompt_window
.Exit3:	rts

; *** Change ashes ***
Change_ashes:
	jsr	Handle_spell		; Handle spell
	bne.s	.Fail
	lea.l	.Do1,a0			; Do all targets
	bra.s	.Go
.Fail:	lea.l	.Do2,a0
.Go:	jsr	Do_all_targets
.Exit:	rts

; [ Change ashes to dead body ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do1:
	move.w	Body_conditions(a0),d0	; Get conditions
	btst	#Ashes,d0			; Ashes ?
	bne.s	.Yes
	move.w	#251,d0			; No!
	jsr	Do_prompt_window
	bra.s	.Exit2
.Yes:	bclr	#Ashes,d0			; Change !
	bset	#Dead,d0
	move.w	d0,Body_conditions(a0)
	move.w	#253,d0			; "Yay!"
	jsr	Do_prompt_window
.Exit2:	rts

; [ Change ashes to dust ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do2:
	move.w	Body_conditions(a0),d0	; Get conditions
	btst	#Ashes,d0			; Ashes ?
	beq.s	.Exit3
	bclr	#Ashes,d0			; Change !
	bset	#Dust,d0
	move.w	d0,Body_conditions(a0)
	move.w	#255,d0			; "Sob!"
	jsr	Do_prompt_window
.Exit3:	rts

; *** Change dust ***
Change_dust:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
.Exit:	rts

; [ Change dust ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Get conditions
	btst	#Dust,d0			; Dust ?
	bne.s	.Yes
	move.w	#252,d0			; No!
	jsr	Do_prompt_window
	bra.s	.Exit2
.Yes:	bclr	#Dust,d0			; Change !
	bset	#Ashes,d0
	move.w	d0,Body_conditions(a0)
	move.w	#254,d0			; "Yay!"
	jsr	Do_prompt_window
.Exit2:	rts

; *** Resurrection
Resurrection:
	jsr	Handle_spell		; Handle spell
	bne.s	.Fail
	lea.l	.Do1,a0			; Do all targets
	bra.s	.Go
.Fail:	lea.l	.Do2,a0
.Go:	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Resurrect ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do1:
	move.w	Body_conditions(a0),d0	; Get conditions
	move.w	#Dead_mask,d1		; Dead ?
	and.w	d0,d1
	beq.s	.Exit2
	btst	#Dust,d0			; Ashes or dust ?
	bne.s	.Yes
	btst	#Ashes,d0
	beq.s	.No
.Yes:	move.w	#250,d0			; No can do!
	jsr	Do_prompt_window
	bra.s	.Exit2
.No:	bclr	#Dead,d0			; Arise!
	move.w	d0,Body_conditions(a0)
	move.w	Life_points+Maximum(a0),d0
	add.w	Life_points+Magic(a0),d0
	move.w	d0,Life_points(a0)
	jsr	Force_status_update		; Show
	move.w	#57,d0			; "Yay!"
	jsr	Do_prompt_window
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

; [ Change dead body to ashes ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do2:
	move.w	Body_conditions(a0),d0	; Get conditions
	btst	#Dead,d0			; Dead ?
	beq.s	.Exit3
	bclr	#Dead,d0			; Change !
	bset	#Ashes,d0
	move.w	d0,Body_conditions(a0)
	move.w	#256,d0			; "Sob!"
	jsr	Do_prompt_window
.Exit3:	rts

; *** Restore stamina ***
Restore_stamina:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Restore stamina ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	move.w	d0,d1
	andi.w	#Alive_mask,d1
	bne.s	.Exit2
	btst	#Exhausted,d0		; Yes -> Exhausted ?
	beq.s	.Exit2
	jsr	De_exhaust		; Yes
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

; ********** Class 1 spells ***********************
; *** Charge item ***
Charge_item:
	jsr	Handle_spell		; Handle spell
	beq.s	.Succeed
	jsr	Spell_on_item_failed	; Fail !
	bra	.Exit
.Succeed:	lea.l	Party_handles,a0		; Get target character data
	move.w	Magic_target_mask,d7
	move.b	-1(a0,d7.w),d6
	Get	d6,a0
	lea.l	Char_inventory(a0),a0	; Get target slot
	move.w	Magic_target_slot,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a0
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a0),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.w	d0,a1
	tst.b	Spell_number(a1)		; Magical object ?
	bne.s	.Ok1
	Free	d6			; No
	move.w	#264,d0			; "Not magical!"
	jsr	Do_prompt_window
	bra	.Exit
.Ok1:	moveq.l	#0,d0			; How many charges possible ?
	move.b	Enchantment_charge_max(a1),d0
	sub.b	Charges(a0),d0
	bgt.s	.Ok2			; Fully charged ?
	Free	d6			; Yes
	move.w	#257,d0			; "Already charged!"
	jsr	Do_prompt_window
	bra.s	.Exit
.Ok2:	Get	Casting_handle,a2		; Get level of caster
	moveq.l	#0,d1
	move.b	Level_nr(a2),d1
	Free	Casting_handle
	cmp.w	d1,d0			; Level too high ?
	bpl.s	.Ok3
	move.w	d0,d1			; Yes -> Clip
.Ok3:	jsr	Random			; Determine added charges
	mulu.w	d1,d0
	swap	d0
	addq.w	#1,d0
	add.b	d0,Charges(a0)		; Add
	Free	d6
	move.w	Magic_target_slot,d0	; Sparkle
	jsr	Sparkle_object
.Exit:	rts

; *** Light ***
MLight:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get data
	subq.w	#2,d0
	add.w	d0,d0
	move.b	.Table+1(pc,d0.w),d1
	move.b	.Table(pc,d0.w),d0
	moveq.l	#1,d7			; Set
	jsr	Set_permanent_spell
	jsr	Update_light_status
.Exit:	rts

.Table:	dc.b 1,30,1,60,2,120,3,180
	even

; *** Create food ***
Create_food:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Create food ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit2
	cmp.w	#32767,Food_rations(a0)	; Got maximum food ?
	beq.s	.Exit2
	addq.w	#1,Food_rations(a0)		; No -> Give food
	add.l	#Food_weight,Weight_normal(a0)
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

; *** Remove cursed items ***
Remove_curse:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
.Exit:	rts

; [ Remove cursed items ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne	.Exit2
	lea.l	Party_handles,a0		; Get handle
	move.b	-1(a0,d7.w),d6
; ---------- Build fake Inventory 2 screen --------
	move.w	d6,-(sp)
	jsr	Fade_out_bottom		; Fade out
	move.b	d6,Inventory_handle		; Set
	move.w	d7,Inventory_member
	moveq.l	#Inv2_layout,d0		; Show layout
	jsr	Show_layout
	jsr	Load_object_graphics
	jsr	Display_Inv2_member_info	; Show info
	jsr	Update_weight		; Print weight
	lea.l	Inv2_CIL,a0		; Show icons
	jsr	Display_control_icons
	jsr	Fade_in_bottom
	moveq.l	#25,d0			; Wait
	jsr	Delay
	move.w	(sp)+,d6
; ---------- Destroy cursed objects ---------------
	lea.l	Char_inventory(a1),a0	; Search body
					; FIX: Was "Char_inventory(a0)", but a0 points to the
					;  window data. a1 points to the character data.
	move.l	Object_data_ptr,a1
	moveq.l	#0,d5
	moveq.l	#1,d7
.Loop:	move.w	Object_index(a0),d0		; Anything there ?
	beq.s	.Next
	subq.w	#1,d0			; Get object data address
	mulu.w	#Item_data_size,d0
	move.b	Item_bits_STATIC(a1,d0.l),d0	; Get bits
	btst	#Cursed,d0		; Cursed ?
	beq.s	.Next
	addq.w	#1,d5			; Yes -> Count
	move.w	d7,d0			; Boom !
	jsr	Cursed_item_is_destroyed
	move.b	d6,d0			; Remove
	move.w	d7,d2
	jsr	Remove_item
	moveq.l	#25,d0			; Wait
	jsr	Delay
.Next:	addq.w	#Object_packet_size,a0	; Next slot
	addq.w	#1,d7
	cmp.w	#9+1,d7
	bmi.s	.Loop
	tst.w	d5			; Any ?
	bne.s	.Yes
	move.w	#273,d0			; "Sucker!"
	jsr	Do_prompt_window
; ---------- Exit ---------------------------------
.Yes:	jsr	Fade_out_bottom		; Fade out
	jsr	Free_object_graphics
	jsr	Init_display		; Restore
.Exit2:	rts

; *** Jump ***
Jump:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	move.w	Map_Xcoord,d0		; Get coordinates
	move.w	Map_Ycoord,d1
	move.w	View_direction,d2		; Get view direction
	moveq.l	#0,d3
	tst.b	Show_trans		; Show travelmodes ?
	beq.s	.Skip
	move.w	Travel_mode,d3		; Yes -> Get travel mode
	cmp.w	#Swimming,d3		; Swimming ?
	bne.s	.Skip
	moveq.l	#On_foot,d3		; Yes -> Equals on foot
.Skip:	add.w	#Blocked_foot_bit,d3
	jsr	Move_in_direction		; Move forward
	move.w	d0,d6			; Save coordinates
	move.w	d1,d7
	jsr	Check_jump_target		; Way blocked ?
					; FIX: Also checks for locked doors, places and
					;  riddlemouths, which could be jumped over (#98).
	bne.s	.Error
	move.w	d6,d0			; Restore coordinates
	move.w	d7,d1
	jsr	Move_in_direction		; Move forward
	move.w	d0,d6			; Save coordinates
	move.w	d1,d7
	jsr	Check_jump_target		; Way blocked ? (FIX: see above)
	bne.s	.Error
	move.w	d6,Map_Xcoord		; No -> Jump
	move.w	d7,Map_Ycoord
	jsr	Jumped
	jsr	Event_handler		; Handle first event
	bra.s	.Exit
.Error:	move.w	#66,d0			; "Ouch!"
	jsr	Do_prompt_window
.Exit:	rts

;*****************************************************************************
; [ Check if a jump target is blocked ]
;   IN : d3 - Travel mode blocked bit number (.w)
;        d6 - X-coordinate (.w)
;        d7 - Y-coordinate (.w)
;  OUT : eq - Not blocked
;        ne - Blocked
; All registers are restored
; NOTE :
;  - FIX: Added in 1.21 (#98). Besides the location status it checks the
;    events at the target position : places and riddlemouths always block,
;    doors block when they are locked.
;*****************************************************************************
Check_jump_target:
	movem.l	d1-d7/a0-a6,-(sp)		; Event processing may change registers
	jsr	Get_location_status
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Block
	btst.l	d3,d0			; Travel mode allowed ?
	beq.s	.Block
	move.w	d6,d0			; Any event here ?
	move.w	d7,d1
	jsr	Find_event
	bmi	.No_block
	jsr	Check_event_save_status	; Already done ?
	bne	.No_block
	lea.l	Current_event_data,a5	; Handle condition events
	jsr	Do_condition_events
	tst.b	Break_event		; Condition not met ?
	bne.s	.No_block
	cmp.b	#Places_type,(a5)		; Place ?
	beq.s	.Block			; Always block
	cmp.b	#Riddle_mouth_type,(a5)	; Riddlemouth ?
	beq.s	.Block			; Always block
	cmp.b	#Door_type,(a5)		; Door ?
	bne.s	.No_block
	moveq.l	#0,d0			; Yes -> Already open ?
	move.b	Current_event_data+Event_b2,d0
	moveq.l	#Door_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	beq.s	.Block			; No -> Locked
.No_block:	sf	Break_event
	moveq.l	#0,d0
	bra.s	.Exit
.Block:	sf	Break_event
	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d1-d7/a0-a6		; (Does not change the flags)
	rts

;*****************************************************************************
; [ Handle the chain of condition events ]
;   IN : a5 - Pointer to current event data (.l)
;  OUT : Break_event - Set if a condition was not met
; NOTE :
;  - FIX: Added in 1.21 (#98) for [ Check_jump_target ].
;*****************************************************************************
Do_condition_events:
	sf	Success
	st	Handling_event
.Again:	sf	Break_event
	cmp.b	#Query_type,(a5)		; Condition event ?
	bne.s	.Exit
	jsr	Handle_event		; Yes -> Handle
	tst.b	Break_event		; Condition not met ?
	bne.s	.Exit
	jsr	Chain_to_next_event	; Next event in chain
	bpl.s	.Again
	st	Break_event
.Exit:	sf	Success
	sf	Handling_event
	rts

; *** Word of marking ***
Word_of_marking:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	Get	Casting_handle,a0		; Mark position
	lea.l	Recall_data(a0),a0
	move.w	Map_Xcoord,(a0)+
	move.w	Map_Ycoord,(a0)+
	move.w	Map_nr,(a0)
	Free	Casting_handle
	move.w	#259,d0			; "Did it!"
	jsr	Do_prompt_window
.Exit:	rts

; *** Word of returning ***
Word_of_returning:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	Get	Casting_handle,a0		; Get marked position
	movem.w	Recall_data(a0),d1-d3
	Free	Casting_handle
	tst.w	d3			; Any ?
	bne.s	.Yes
	move.w	#261,d0			; "Fool!"
	jsr	Do_prompt_window
	bra.s	.Exit
.Yes:	move.w	#260,d0			; "Did it!"
	jsr	Do_prompt_window
	cmp.w	Map_nr,d3			; Other map ?
	bne.s	.Other
	move.w	d1,Map_Xcoord		; No -> Set new coordinates
	move.w	d2,Map_Ycoord
	jsr	Jumped
	bra.s	.Exit
.Other:	jsr	Exit_map			; Yes -> Exit current map
	move.w	d1,Map_Xcoord		; Set new coordinates
	move.w	d2,Map_Ycoord
	move.w	d3,Map_nr			; & map number
	jsr	Init_map			; Initialize new map
.Exit:	rts

; *** Shield ***
MShield:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get data
	subi.w	#14,d0
	add.w	d0,d0
	move.b	.Table+1(pc,d0.w),d1
	move.b	.Table(pc,d0.w),d0
	moveq.l	#2,d7			; Set
	jsr	Set_permanent_spell
.Exit:	rts

.Table:	dc.b 10,30,20,90,30,180
	even

; *** Attack ***
MAttack:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get data
	subi.w	#17,d0
	add.w	d0,d0
	move.b	.Table+1(pc,d0.w),d1
	move.b	.Table(pc,d0.w),d0
	moveq.l	#3,d7			; Set
	jsr	Set_permanent_spell
.Exit:	rts

.Table:	dc.b 10,30,20,90,30,180
	even

; *** Levitation ***
Levitation:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
; ---------- Float up if in 3D map ----------------
	cmp.b	#Map_3D,Current_map_type	; In 3D map ?
	bmi.s	.No_3D
;	sf	Moved
	jsr	Update_screen		; Yes -> Going up !
	moveq.l	#2,d0
	moveq.l	#2,d1
	Get	Labdata_handle,a0
	move.w	Wall_in_cm(a0),d2
	Free	Labdata_handle
	lsr.w	#1,d2
	sub.w	head_height,d2
	moveq.l	#0,d7
.Again:	cmp.w	d2,d0			; Too high ?
	bpl.s	.Done
	move.w	d0,FX_camera_height		; Set new height
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	add.w	d1,d0			; Move up
	addq.w	#2,d1			; Faster
	addq.w	#1,d7			; Count
	bra.s	.Again
.Done:	jsr	Copy_screen
; ---------- Check for trapdoor up ----------------
.No_3D:	move.w	Map_Xcoord,d0		; Find event
	move.w	Map_Ycoord,d1
	jsr	Find_event
	bmi.s	.Error
	jsr	Check_event_save_status	; Already saved ?
	bne.s	.Error
	lea.l	Current_event_data,a5	; No -> Examine event
	cmp.b	#Query_type,(a5)		; Query ?
	bne.s	.Error
	cmp.b	#Levitate_QM_type,Event_b1(a5)	; For levitation ?
	bne.s	.Error
	st	Float_up			; Fly!
	st	Levitation_flag
	jsr	Handle_event_chain		; Handle event
	sf	Levitation_flag
	bra.s	.Exit
; ---------- Float back down if in 3D map ---------
.Error:	move.w	#64,d0			; "Big deal"
	jsr	Do_prompt_window
	cmp.b	#Map_3D,Current_map_type	; In 3D map ?
	bmi.s	.Exit
	jsr	Update_screen		; Yes -> Going down !
	move.w	FX_camera_height,d0
	moveq.l	#2,d1
	bra.s	.Entry
.Loop:	move.w	d0,FX_camera_height		; Set new height
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	sub.w	d1,d0			; Move down
	addq.w	#2,d1
.Entry:	dbra	d7,.Loop
	jsr	Copy_screen
.Exit:	rts

; *** Anti magic  ***
MAnti_magic:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get data
	subi.w	#21,d0
	add.w	d0,d0
	move.b	.Table+1(pc,d0.w),d1
	move.b	.Table(pc,d0.w),d0
	moveq.l	#4,d7			; Set
	jsr	Set_permanent_spell
.Exit:	rts

.Table:	dc.b 15,30,25,180
	even

; *** Alchemistic globe ***
Alchemistic_globe:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	moveq.l	#3,d0			; Set light
	move.w	#180,d1
	moveq.l	#1,d7
	jsr	Set_permanent_spell
	moveq.l	#30,d0			; Set parade
	move.w	#180,d1
	moveq.l	#2,d7
	jsr	Set_permanent_spell
	moveq.l	#30,d0			; Set attack
	move.w	#180,d1
	moveq.l	#3,d7
	jsr	Set_permanent_spell
	moveq.l	#25,d0			; Set anti-magic
	move.w	#180,d1
	moveq.l	#4,d7
	jsr	Set_permanent_spell
	jsr	Update_light_status
.Exit:	rts

; *** Repair item ***
MRepair_item:
	jsr	Handle_spell		; Handle spell
	beq.s	.Succeed
	jsr	Spell_on_item_failed	; Fail !
	bra	.Exit
.Succeed:	lea.l	Party_handles,a0		; Get target character data
	move.w	Magic_target_mask,d7
	move.b	-1(a0,d7.w),d6
	Get	d6,a0
	lea.l	Char_inventory(a0),a0	; Get target slot
	move.w	Magic_target_slot,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a0
	btst	#Broken_item,Item_bits_DYNAMIC(a0)	; Is broken ?
	bne.s	.Repair
	Free	d6			; No
	move.w	#271,d0			; "Fool!"
	jsr	Do_prompt_window
	bra.s	.Exit
.Repair:	bclr	#Broken_item,Item_bits_DYNAMIC(a0)	; Repair
	Free	d6
	move.w	Magic_target_slot,d0	; Sparkle
	jsr	Sparkle_object
.Exit:	rts

; *** Duplicate item ***
Duplicate_item:
	jsr	Handle_spell		; Handle spell
	beq.s	.Succeed
	jsr	Spell_on_item_failed	; Fail !
	bra	.Exit
.Succeed:	lea.l	Party_handles,a0		; Get target character data
	move.w	Magic_target_mask,d7
	move.b	-1(a0,d7.w),d6
	Get	d6,a0
	lea.l	Char_inventory(a0),a0	; Get target slot
	move.w	Magic_target_slot,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a0
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a0),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.w	d0,a1
	btst	#Duplicatable,Item_bits_STATIC(a1)	; Possible ?
	bne.s	.Double
	Free	d6			; No
	move.w	#269,d0			; "Sorry!"
	jsr	Do_prompt_window
	bra.s	.Exit
.Double:	lea.l	Inter_packet,a1		; Copy packet
	Copy_packet a0,a1
	Free	d6
	move.w	Magic_target_slot,d0	; Sparkle
	jsr	Sparkle_object
	move.l	a1,a0			; Add one to backpack
	move.b	#1,Quantity(a0)
	move.b	d6,d0
	jsr	Auto_move_to_backpack
	tst.b	Quantity(a0)		; Gone ?
	bne.s	.Full
	jsr	Update_objects		; Yes -> Display
	jsr	Update_screen
	bra.s	.Exit
.Full:	move.w	#272,d0			; No -> "Tough luck"
	jsr	Do_prompt_window
.Exit:	rts

; ********** Class 2 spells ***********************
; *** Identification ***
Identification:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	Party_handles,a0		; Get target character data
	move.w	Magic_target_mask,d7
	move.b	-1(a0,d7.w),d6
	Get	d6,a0
	lea.l	Char_inventory(a0),a0	; Get target slot
	move.w	Magic_target_slot,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a0
	bset	#Magic_check,Item_bits_DYNAMIC(a0)	; Identify
	lea.l	Inter_packet,a1		; Copy packet
	Copy_packet a0,a1
	Free	d6
	move.w	Magic_target_slot,d0	; Sparkle
	jsr	Sparkle_object
	Push	Module,ItemView1_Mod	; Show
.Exit:	rts

; *** Clairvoyance ***
MClairvoyance:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get duration
	subq.w	#3,d0
	move.b	.Table(pc,d0.w),d1
	moveq.l	#0,d0			; No data
	moveq.l	#5,d7			; Set
	jsr	Set_permanent_spell
.Exit:	rts

.Table:	dc.b 30,90,180
	even

; *** Minimap ***
Minimap:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	Get	Mapdata_handle,a0		; Possible ?
	move.w	Map_special(a0),d0
	Free	Mapdata_handle
	btst	#View_map_bit,d0
	bne.s	.Yes
	move.w	#276,d0			; No -> "Tough luck"
	jsr	Do_prompt_window
	bra.s	.Exit
.Yes:	jsr	Get_module_ID		; In Inventory ?
	cmp.b	#Inv2_ID,d0
	bne.s	.Skip
	jsr	Exit_Inv2			; Yes -> Leave
.Skip:	Push	Module,Minimap_Mod		; Do
.Exit:	rts

; *** Magic compass ***
Magic_compass:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	Push	Module,MagicCompass_Mod	; Do
.Exit:	rts

MagicCompass_ModInit:
	move.w	#CompassW_X-16,d0		; Open window
	move.w	#CompassW_Y-16,d1
	moveq.l	#4,d2
	moveq.l	#4,d3
	suba.l	a0,a0
	jsr	Open_window
	move.w	#CompassW_X,d0		; Display compass
	move.w	#CompassW_Y,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#32,d7
	lea.l	Compass,a0
	jsr	Put_unmasked_block
	cmp.b	#2,Current_map_type		; 2D or 3D map ?
	bpl.s	.3D
	move.w	View_direction,d3		; Calculate 2D offset
	addq.w	#1,d3
	mulu.w	#8*(Char_width+1),d3
	subi.w	#13,d3
	bra.s	.Draw
.3D:	move.w	Y_angle,d3		; Calculate 3D offset
	neg.w	d3
	andi.w	#slang-1,d3
	addi.w	#slang/4,d3
	mulu.w	#4*8*(Char_width+1),d3
	divu.w	#slang,d3
	subi.w	#13,d3
.Draw:	Push	CA,CompassW_CA		; Print compass text
	move.w	#-1,Shadow_colour
	move.w	#31,Ink_colour
	move.w	#CompassW_X,d0
	sub.w	d3,d0
	move.w	#CompassW_Y+13,d1
	move.l	Compass_txt_ptr,a0
	jsr	Put_text_line
	clr.w	Shadow_colour
	Pop	CA
	jmp	Update_screen

; *** Special automap ***
Special_automap:
	cmp.b	#Map_3D,Current_map_type	; 3D map ?
	bpl.s	.Ok
	move.w	#258,d0			; "Not here!"
	jsr	Do_prompt_window
	bra.s	.Exit
.Ok:	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get data
	subq.w	#8,d0
	move.b	.Table(pc,d0.w),Automap_function
	jsr	Exit_display		; Show automap
	Push	Module,Automap_Mod
.Exit:	rts

.Table:	dc.b 1<<Show_traps_function
	dc.b 1<<Show_monsters_function
	dc.b 1<<Show_NPCs_function
	dc.b 1<<Show_hidden_function
	dc.b %00001111
	even

; *** Automap ***
MAutomap:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get duration
	subi.w	#13,d0
	move.b	.Table(pc,d0.w),d1
	moveq.l	#0,d0			; No data
	moveq.l	#6,d7			; Set
	jsr	Set_permanent_spell
.Exit:	rts

.Table:	dc.b 30,60,90
	even

; *** Mystical globe ***
Mystical_globe:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	moveq.l	#0,d0			; Set clairvoyance
	move.w	#180,d1
	moveq.l	#5,d7
	jsr	Set_permanent_spell
	moveq.l	#6,d7			; Set mystical map
	jsr	Set_permanent_spell
.Exit:	rts

; ********** Class 6 spells ***********************
; *** Call giant eagle ***
Call_eagle:
	tst.w	Travel_mode		; On foot ?
	beq.s	.Ok1
	move.w	#283,d0			; No
	jsr	Do_prompt_window
	bra.s	.Exit
.Ok1:	cmp.b	#World_2D,Current_map_type	; World map ?
	beq.s	.Ok2
	move.w	#244,d0			; No
	jsr	Do_prompt_window
	bra.s	.Exit
.Ok2:	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	move.w	#46,d0			; "Yay!"
	jsr	Do_prompt_window
	jsr	Get_under_module_ID		; Coming from map ?
	cmp.b	#W2Map_ID,d0
	bne.s	.Skip
	jsr	Exit_Inv2			; Yes -> Leave Inventory
	move.w	#1,View_direction		; Ha !
	jsr	Show_eagle_flying_in	; Whee !
.Skip:	moveq.l	#Giant_eagle,d0		; Do it
	jsr	Set_new_travel_mode
.Exit:	rts

; *** Youth ***
Youth:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Youth ]
;   IN : d7 - Target member number [1...6] (.w)
;        a0 - Pointer to target character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit2
	jsr	Random			; Get random number
	mulu.w	#10,d0
	swap	d0
	addq.w	#1,d0
	move.w	AAge(a0),d1		; Subtract from age
	sub.w	d0,d1
	cmp.w	#Minimum_age,d1		; Too young ?
	bpl.s	.Ok
	move.w	#Minimum_age,d1		; Yes -> Clip
.Ok:	move.w	d1,AAge(a0)		; Store new age
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
	tst.b	Magic_object_flag		; In Inventory ?
	beq.s	.Exit2
	cmp.w	Inventory_member,d7		; Of victim ?
	bne.s	.Exit2
	jsr	Display_Inv2_member_info	; Show info
	jsr	Update_screen
.Exit2:	rts

; *** Magic music ***
Magic_music:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	Push	Module,MusSelW_Mod		; Select song
.Exit:	rts

MusSelW_DisInit:
	clr.w	Selected_music		; Clear
	move.w	#MusSelW_X-16,d0		; Open a window
	move.w	#MusSelW_Y-16,d1
	moveq.l	#15,d2
	moveq.l	#10,d3
	lea.l	MusSelW_L1,a0
	jsr	Open_window
	move.w	#MusSelW_X+159,d0		; Draw box around icon
	move.w	#MusSelW_Y+113,d1
	move.w	#32,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display exit icon
	addq.w	#1,d1
	moveq.l	#Exit_cicon,d3
	jsr	Display_up_button
	Push	Scroll_bar,MusSelW_scroll_bar	; Show scroll bar
	jmp	Update_screen

Update_music_select_window:
	move.w	#31,Ink_colour		; Set colour
	move.w	#MusSelW_X,d0		; Clear song area
	move.w	#MusSelW_Y-2,d1
	move.w	#192,d2
	move.w	#113,d3
	jsr	Draw_standard_box
	move.w	Scroll_bar_result,d2	; Get bar position
	moveq.l	#Max_songs,d7		; Show how many songs ?
	sub.w	d2,d7
	cmp.w	#16+1,d7
	bmi.s	.Ok
	moveq.l	#16,d7
.Ok:	move.w	#MusSelW_Y,d1		; Show song names
	bra.s	.Entry
.Loop:	move.l	Song_names_ptr,a0
	move.w	d2,d0
	jsr	Find_small_text
	move.w	#MusSelW_X+4,d0
	jsr	Put_text_line
	addq.w	#Char_height+2,d1		; Next song name
	addq.w	#1,d2
.Entry:	dbra	d7,.Loop
	rts

MusSelW_DisExit:
	jsr	Close_window
	jmp	Pop_Scroll_bar

Exit_MusSelW:
	move.w	#MusSelW_X+160,d0		; Feedback
	move.w	#MusSelW_Y+114,d1
	moveq.l	#Exit_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	jsr	Basic_abort		; Exit
.Exit:	rts

Music_selected:
	lsr.w	#8,d0			; Clicked on a tune ?
	tst.b	d0
	beq	.Exit
	move.w	d0,d1
	add.w	Scroll_bar_result,d0	; Calculate slot number
	cmp.w	#Max_songs,d0		; Empty slot ?
	bhi	.Exit
	move.w	d0,Selected_music		; Store
	move.l	Song_names_ptr,a0		; Find song name
	subq.w	#1,d0
	jsr	Find_small_text
	move.w	#26,Ink_colour		; Set colours
	move.w	#31,Shadow_colour
	subq.w	#1,d1			; Print it
	mulu.w	#Char_height+2,d1
	addi.w	#MusSelW_Y,d1
	move.w	#MusSelW_X+4,d0
	jsr	Put_text_line
	move.w	#0,Shadow_colour		; Reset
	jsr	Update_screen		; Exit
	jsr	Wait_4_unclick
	tst.b	Music_flag		; Music on ?
	bne.s	.Skip
	jsr	Music_on			; No -> Switch on
.Skip:	move.w	Selected_music,d0		; Start music
	moveq.l	#0,d1
	jsr	Set_music
.Exit:	rts

Music_touched:
	lsr.w	#8,d0			; Clicked on a tune ?
	tst.b	d0
	beq	.Exit
	move.w	d0,d1
	add.w	Scroll_bar_result,d0	; Calculate slot number
	cmp.w	#Max_songs,d0		; Empty slot ?
	bhi	.Exit
	move.l	Song_names_ptr,a0		; Find song name
	subq.w	#1,d0
	jsr	Find_small_text
	move.w	#0,Ink_colour		; Set colours
	move.w	#-1,Shadow_colour
	subq.w	#1,d1			; Get coordinates
	mulu.w	#Char_height+2,d1
	addi.w	#MusSelW_Y-1,d1
	move.w	#MusSelW_X+1,d0
	move.w	d0,d2			; Draw highlighting box
	move.w	d1,d3
	addi.w	#190,d2
	add.w	#Char_height+1,d3
	moveq.l	#31,d4
	jsr	Draw_box
	addq.w	#3,d0			; Print song name
	addq.w	#1,d1
	jsr	Put_text_line
	move.w	#0,Shadow_colour		; Reset
.Exit:	rts

; *** Spell points ***
MSpell_points:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Add spell points ]
;   IN : d7 - Target member number [1...6] (.w)
;        a0 - Pointer to target character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit2
	move.w	Selected_spell,d0		; Get max PP percentage
	subq.w	#5,d0
	moveq.l	#0,d1
	move.b	.Table(pc,d0.w),d1
	move.w	Power_points+Maximum(a0),d0	; Calculate added PP
	beq.s	.Exit2			; (if any)
	mulu.w	d1,d0
	divu.w	#100,d0
	tst.w	d0
	bne.s	.Notzero
	moveq.l	#1,d0
.Notzero:	jsr	Increase_PP		; Add
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

.Table:	dc.b 10,25,50,75,100
	even

; *** Heal all ***
Heal_all:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Heal party member ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	clr.w	Body_conditions(a0)		; Heal
	move.w	Life_points+Maximum(a0),d0	; Reset LP
	add.w	Life_points+Magic(a0),d0
	move.w	d0,Life_points(a0)
	move.w	d7,d0			; Sparkle!
	jmp	Do_sparkle

; *** Magic map ***
Magic_map:
	rts

; *** Increase attribute ***
MAttribute:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Increase attribute ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit2
	lea.l	Attributes(a0),a0		; Get attribute data
	move.w	Selected_spell,d0
	subi.w	#12,d0
	mulu.w	#Attr_data_size,d0
	add.w	d0,a0
	jsr	Random			; Get random number
	mulu.w	#5,d0
	swap	d0
	addq.w	#1,d0
	add.w	(a0),d0			; Increase attribute
	cmp.w	Maximum(a0),d0		; Too high ?
	bls.s	.Ok
	move.w	Maximum(a0),d0		; Yes -> Clip
.Ok:	move.w	d0,(a0)			; Store
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

; *** Levitation 2 - The Floating Strikes Back ***
Levitation2:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
; ---------- Check for trapdoor up ----------------
	move.w	Map_Xcoord,d0		; Find event
	move.w	Map_Ycoord,d1
	jsr	Find_event
	bmi.s	.Error
	jsr	Check_event_save_status	; Already saved ?
	bne.s	.Error
	lea.l	Current_event_data,a5	; No -> Examine event
	cmp.b	#Query_type,(a5)		; Query ?
	bne.s	.Error
	cmp.b	#Levitate_QM_type,Event_b1(a5)	; For levitation ?
	beq.s	.Do
.Error:	move.w	#270,d0			; "No can do"
	jsr	Do_prompt_window
	bra	.Exit
; ---------- Float up if in 3D map ----------------
.Do:	jsr	Exit_Inv2			; Leave Inventory
	cmp.b	#Map_3D,Current_map_type	; In 3D map ?
	bmi.s	.No_3D
;	sf	Moved
	jsr	Update_screen		; Yes -> Going up !
	moveq.l	#2,d0
	moveq.l	#2,d1
	Get	Labdata_handle,a0
	move.w	Wall_in_cm(a0),d2
	Free	Labdata_handle
	lsr.w	#1,d2
	sub.w	head_height,d2
	moveq.l	#0,d7
.Again:	cmp.w	d2,d0			; Too high ?
	bpl.s	.Done
	move.w	d0,FX_camera_height		; Set new height
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	add.w	d1,d0			; Move up
	addq.w	#2,d1			; Faster
	addq.w	#1,d7			; Count
	bra.s	.Again
.Done:	jsr	Copy_screen
	st	Float_up
; ---------- Do -----------------------------------
.No_3D:	st	Levitation_flag		; Fly!
	jsr	Handle_event_chain		; Handle event
	sf	Levitation_flag
.Exit:	rts

; *** Drug ***
Drug:
	jsr	Handle_spell		; Handle spell
	bne.s	.Exit
	lea.l	.Do,a0			; Do all targets
	jsr	Do_all_targets
	jsr	Wait_4_sparkles		; Wait
.Exit:	rts

; [ Set drugged condition ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to character data (.l)
; No registers are restored
.Do:
	move.w	Body_conditions(a0),d0	; Alive ?
	move.w	d0,d1
	andi.w	#Alive_mask,d1
	bne.s	.Exit2
	bset	#Stoned,d0		; Yes -> Whee!
	move.w	d0,Body_conditions(a0)
	move.w	d7,d0			; Sparkle!
	jsr	Do_sparkle
.Exit2:	rts

;*****************************************************************************
; [ Show giant eagle flying in ]
; All registers are restored
;*****************************************************************************
Show_eagle_flying_in:
	movem.l	d0/d1/d7/a0,-(sp)
	tst.b	Stygian			; Darkness ?
	bne	.Exit
	jsr	Update_display		; No -> Show party on foot
	Push	CA,Map2D_L2
	lea.l	Giant_eagle_shape,a0	; Make fake handle
	jsr	Create_fake_handle
	move.b	d0,d7
	move.w	Mapbuf_X,d0		; Get start coordinates
	lsl.w	#4,d0
	addi.w	#Map2D_X-8-4*25,d0
	move.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y-8-25,d1
	lea.l	Giant_eagle_HDOB,a0		; Set coordinates
	move.w	d0,HDOB_drawX(a0)
	move.w	d1,HDOB_drawY(a0)
	move.b	d7,HDOB_gfx_handle(a0)	; Set handle
	jsr	Add_HDOB			; Initialize
	jsr	Update_screen
	moveq.l	#25-1,d7
.Loop:	move.w	d0,HDOB_drawX(a0)		; Set new coordinates
	move.w	d1,HDOB_drawY(a0)
	jsr	Switch_screens		; Show
	addq.w	#4,d0			; Fly away
	addq.w	#1,d1
	dbra	d7,.Loop
	jsr	Remove_HDOB		; Exit
	move.b	HDOB_gfx_handle(a0),d0
	jsr	Destroy_fake_handle
	Pop	CA
.Exit:	movem.l	(sp)+,d0/d1/d7/a0
	rts

;*****************************************************************************
; [ Spell on an item failed ]
; No registers are restored
;*****************************************************************************
Spell_on_item_failed:
	lea.l	Party_handles,a0		; Get target character data
	move.w	Magic_target_mask,d7
	move.b	-1(a0,d7.w),d6
	Get	d6,a0
	lea.l	Char_inventory(a0),a0	; Get target slot
	move.w	Magic_target_slot,d0
	mulu.w	#Object_packet_size,d0
	move.w	Object_index(a0,d0.w),d1	; Get object index
	Free	d6
	move.b	d6,d0			; Remove item
	move.w	Magic_target_slot,d2
	addq.w	#1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.w	Magic_target_slot,d0	; Get target slot
	sub.w	#9-1,d0
	jsr	Display_object		; Update object display
	jsr	Update_screen
	move.l	Object_pos_list,a1		; Get slot coordinates
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a1
	move.l	Object_data_ptr,a0		; Get object data address
	subq.w	#1,d1
	mulu.w	#Item_data_size,d1
	add.l	d1,a0
	moveq.l	#0,d0			; Get object graphics address
	move.b	Item_pic(a0),d0
	Get	Object_gfx_handle,a0
	mulu.w	#Icon_size,d0
	add.l	d0,a0
	move.w	(a1)+,d0			; Boom !
	move.w	(a1)+,d1
	moveq.l	#27,d4
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Explode_bitmap
	move.b	Object_gfx_handle,d0	; Exit
	jmp	Free_pointer

;*****************************************************************************
; [ Set permanent spell data ]
;   IN : d0 - Data (.b)
;        d1 - Duration (.b)
;        d7 - Spell number {1...6} (.w)
; All registers are restored
;*****************************************************************************
Set_permanent_spell:
	movem.l	d7/a0,-(sp)
	andi.w	#$00ff,d0			; Mask off rubiish
	andi.w	#$00ff,d1
	lea.l	Spell_1_duration-4,a0	; Find data
	lsl.w	#2,d7
	add.w	d7,a0
	cmp.w	(a0),d1			; New duration shorter ?
	bmi.s	.Exit
	move.w	d0,2(a0)			; No -> Set new spell data
	move.w	d1,(a0)
.Exit:	movem.l	(sp)+,d7/a0
	rts

******************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
CompassW_CA:
	dc.w CompassW_X,CompassW_X+31,CompassW_Y,CompassW_Y+31
Fake_Inv2_CIL:
	dc.w Stats_cicon,Use_item_cicon,Exit_cicon
	dc.w Drop_item_cicon,Drop_gold_cicon,Drop_food_cicon
	dc.w View_item_cicon,Transfer_gold_cicon,Transfer_food_cicon
	dc.l 0,0,0
	dc.l 0,0,0
	dc.l 0,0,0
	dc.l 0

SpSelW_scroll_bar:
	dc.w 0,1,16,114,SpSelW_X+160+7,SpSelW_Y
	dc.l Update_spell_window
	dcb.b Scroll_bar_extra_data
MusSelW_scroll_bar:
	dc.w Max_songs,1,16,113,MusSelW_X+192+7,MusSelW_Y-1
	dc.l Update_music_select_window
	dcb.b Scroll_bar_extra_data

; *** SPELL SELECT WINDOW : 1st layer ***
SpSelW_L1:
	dc.w SpSelW_X,SpSelW_Y
	dc.w 0,175,0,111			; Spell area
	dc.b 1
	even
	dc.l 0,SpSelW_L2

; *** SPELL SELECT WINDOW : 2nd layer ***
SpSelW_L2:
	dc.w 0,159,0,6			; Spells
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 0,159,7,13
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 0,159,14,20
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 0,159,21,27
	dc.b 4
	even
	dc.l .C5,0
.C5:	dc.w 0,159,28,34
	dc.b 5
	even
	dc.l .C6,0
.C6:	dc.w 0,159,35,41
	dc.b 6
	even
	dc.l .C7,0
.C7:	dc.w 0,159,42,48
	dc.b 7
	even
	dc.l .C8,0
.C8:	dc.w 0,159,49,55
	dc.b 8
	even
	dc.l .C9,0
.C9:	dc.w 0,159,56,62
	dc.b 9
	even
	dc.l .C10,0
.C10:	dc.w 0,159,63,69
	dc.b 10
	even
	dc.l .C11,0
.C11:	dc.w 0,159,70,76
	dc.b 11
	even
	dc.l .C12,0
.C12:	dc.w 0,159,77,83
	dc.b 12
	even
	dc.l .C13,0
.C13:	dc.w 0,159,84,90
	dc.b 13
	even
	dc.l .C14,0
.C14:	dc.w 0,159,91,97
	dc.b 14
	even
	dc.l .C15,0
.C15:	dc.w 0,159,98,104
	dc.b 15
	even
	dc.l .C16,0
.C16:	dc.w 0,159,105,111
	dc.b 16
	even
	dc.l ScrollBar_L2,0

; *** MUSIC SELECT WINDOW : 1st layer ***
MusSelW_L1:
	dc.w MusSelW_X,MusSelW_Y
	dc.w 0,207,-1,112			; Song area
	dc.b 1
	even
	dc.l .C2,MusSelW_L2
.C2:	dc.w 160,160+31,114,114+16		; Exit icon
	dc.b 3
	dc.l 0,0

; *** MUSIC SELECT WINDOW : 2nd layer ***
MusSelW_L2:
	dc.w 0,191,0,6			; Songs
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 0,191,7,13
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 0,191,14,20
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 0,191,21,27
	dc.b 4
	even
	dc.l .C5,0
.C5:	dc.w 0,191,28,34
	dc.b 5
	even
	dc.l .C6,0
.C6:	dc.w 0,191,35,41
	dc.b 6
	even
	dc.l .C7,0
.C7:	dc.w 0,191,42,48
	dc.b 7
	even
	dc.l .C8,0
.C8:	dc.w 0,191,49,55
	dc.b 8
	even
	dc.l .C9,0
.C9:	dc.w 0,191,56,62
	dc.b 9
	even
	dc.l .C10,0
.C10:	dc.w 0,191,63,69
	dc.b 10
	even
	dc.l .C11,0
.C11:	dc.w 0,191,70,76
	dc.b 11
	even
	dc.l .C12,0
.C12:	dc.w 0,191,77,83
	dc.b 12
	even
	dc.l .C13,0
.C13:	dc.w 0,191,84,90
	dc.b 13
	even
	dc.l .C14,0
.C14:	dc.w 0,191,91,97
	dc.b 14
	even
	dc.l .C15,0
.C15:	dc.w 0,191,98,104
	dc.b 15
	even
	dc.l .C16,0
.C16:	dc.w 0,191,105,111
	dc.b 16
	even
	dc.l ScrollBar_L2,0

; ********** Normal magic *************************
Magic_class_ptrs:
	dc.l .Class_0_ptrs,.Class_1_ptrs,.Class_2_ptrs,0
	dc.l 0,0,.Class_6_ptrs

.Class_0_ptrs:
	dc.l Healing,0,0,Remove_cond
	dc.l Remove_cond,Remove_cond,Remove_cond,Healing
	dc.l Remove_cond,Remove_cond,Healing,0
	dc.l 0,0,Wake_the_dead,Change_ashes
	dc.l Change_dust,Healing,Healing,Resurrection
	dc.l Remove_cond,Remove_cond,Remove_cond,Remove_cond
	dc.l Remove_cond,0,0,Remove_cond
	dc.l Remove_cond,Restore_stamina
.Class_1_ptrs:
	dc.l Charge_item,MLight,MLight,MLight
	dc.l MLight,0,Create_food,Remove_curse
	dc.l 0,Jump,0,Word_of_marking
	dc.l Word_of_returning,MShield,MShield,MShield
	dc.l MAttack,MAttack,MAttack,Levitation
	dc.l MAnti_magic,MAnti_magic,Alchemistic_globe,0
	dc.l 0,MRepair_item,Duplicate_item,0
	dc.l 0,0
.Class_2_ptrs:
	dc.l 0,Identification,MClairvoyance,MClairvoyance
	dc.l MClairvoyance,Minimap,Magic_compass,Special_automap
	dc.l Special_automap,Special_automap,Special_automap,Special_automap
	dc.l MAutomap,MAutomap,MAutomap,Mystical_globe
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0
.Class_6_ptrs:
	dc.l 0,Call_eagle,Youth,Magic_music
	dc.l MSpell_points,MSpell_points,MSpell_points,MSpell_points
	dc.l MSpell_points,Heal_all,Magic_map,MAttribute
	dc.l MAttribute,MAttribute,MAttribute,MAttribute
	dc.l MAttribute,MAttribute,MAttribute,Levitation2
	dc.l Drug,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0
