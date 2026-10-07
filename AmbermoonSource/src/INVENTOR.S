; Inventory screens
; Written by J.Horneman (In Tune With The Universe)
; Start : 24-9-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Right mouse-button clicked on party member ] MOUSE EVENT / INVENTORY 1
; All registers are restored
;*****************************************************************************
Inv1_Mright:
	movem.l	d0-d3/a0,-(sp)
	andi.l	#$0000ff00,d0		; Get member number
	beq.s	.Exit
	lsr.w	#8,d0
	cmp.w	Inventory_member,d0		; Same as now ?
	beq	.Exit
	move.w	d0,d1			; Save for later
	lea.l	Party_handles,a0
	move.b	-1(a0,d0.w),d0
	beq	.Exit			; Anyone there ?
	move.b	d0,d2			; Save for later
	jsr	Claim_pointer		; Get flag
	move.l	d0,a0
	move.b	Secret_inventory(a0),d3
	move.b	d2,d0
	jsr	Free_pointer
	tst.b	d3			; Secret inventory ?
	beq.s	.No
	move.b	d2,Subject_handle		; Yes !
	move.w	#286,d0			; "Begone!"
	jsr	Do_prompt_window
	bra.s	.Exit
.No:	move.b	d2,Inventory_handle		; Store
	move.w	d1,Inventory_member
	jsr	Destroy_ghosts		; Kill!
	jsr	Display_Inv1_member_info	; Show info
	jsr	Update_screen
.Exit:	movem.l	(sp)+,d0-d3/a0
	rts

;*****************************************************************************
; [ Inventory 1 selected (in Inventory 1) by keys F1...F6 ] KEY EVENT
;*****************************************************************************
GoInv1_1:	move.l	#1*256,d0
	bra.s	Inv1_Mright
GoInv1_2:	move.l	#2*256,d0
	bra	Inv1_Mright
GoInv1_3:	move.l	#3*256,d0
	bra	Inv1_Mright
GoInv1_4:	move.l	#4*256,d0
	bra	Inv1_Mright
GoInv1_5:	move.l	#5*256,d0
	bra	Inv1_Mright
GoInv1_6:	move.l	#6*256,d0
	bra	Inv1_Mright

;*****************************************************************************
; [ Right mouse-button clicked on party member ] MOUSE EVENT / INVENTORY 2
; All registers are restored
;*****************************************************************************
Inv2_Mright:
	movem.l	d0-d4/a0,-(sp)
	andi.l	#$0000ff00,d0		; Get member number
	beq.s	.Exit
	lsr.w	#8,d0
	cmp.w	Inventory_member,d0		; Same as now ?
	beq	.Exit
	move.w	d0,d1			; Save for later
	lea.l	Party_handles,a0
	move.b	-1(a0,d0.w),d0
	beq	.Exit			; Anyone there ?
	move.b	d0,d2			; Save for later
	jsr	Claim_pointer		; Get conditions & flag
	move.l	d0,a0
	move.w	Body_conditions(a0),d3
	move.b	Secret_inventory(a0),d4
	move.b	d2,d0
	jsr	Free_pointer
	tst.b	d4			; Secret inventory ?
	beq.s	.No
	move.b	d2,Subject_handle		; Yes !
	move.w	#286,d0			; "Begone!"
	jsr	Do_prompt_window
	bra.s	.Exit
.No:	andi.w	#Inv2_mask,d3		; Not allowed ?
	bne.s	.Exit
	jsr	Save_scroll_bar_position
	move.b	d2,Inventory_handle		; Store new
	move.w	d1,Inventory_member
	jsr	Destroy_ghosts		; Kill!
	jsr	Display_Inv2_member_info	; Show info
	jsr	Update_screen
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Inventory 2 selected (in Inventory 2) by keys F1...F6 ] KEY EVENT
;*****************************************************************************
GoInv2_1:	move.l	#1*256,d0
	bra	Inv2_Mright
GoInv2_2:	move.l	#2*256,d0
	bra	Inv2_Mright
GoInv2_3:	move.l	#3*256,d0
	bra	Inv2_Mright
GoInv2_4:	move.l	#4*256,d0
	bra	Inv2_Mright
GoInv2_5:	move.l	#5*256,d0
	bra	Inv2_Mright
GoInv2_6:	move.l	#6*256,d0
	bra	Inv2_Mright

;*****************************************************************************
; [ Inventory 1 module ]
;*****************************************************************************
Inv1_DisInit:
	moveq.l	#Inv1_layout,d0		; Show layout
	jsr	Show_layout
	jsr	Display_Inv1_member_info	; Show info
	lea.l	Inv1_CIL,a0		; Show icons
	jsr	Display_control_icons
	jmp	Fade_in_bottom

Inv1_DisExit:
	jsr	Destroy_ghosts		; Destroy !
	jmp	Fade_out_bottom

Inv1_DisUpd:
	jsr	Update_status_block
	jsr	Update_damage_magic
	jsr	Update_control_icons
	jmp	Update_small_member_info

Inv1_CIL_update:
	Get	Inventory_handle,a1
	move.w	Body_conditions(a1),d0
	andi.w	#Inv2_mask,d0		; Not allowed ?
	bne.s	.Off
	tst.b	Secret_inventory(a1)	; Secret ?
	beq.s	.Exit
.Off:	bset	#7,(a0)			; Disable {Inventory 2}
.Exit:	Free	Inventory_handle
	rts

; ********** Inventory 1 - Exit *******************
Inv1_Exit:
	Pop	Module
	jmp	Init_display

; ********** Inventory 1 - Enter Inventory 2  *****
Go_Inv2:
	Pop	Module
	lea.l	Inv2_Mod,a0
	jmp	Push_Module

; ********** Inventory 1 - Condition touched ******
Condition_touched:
	tst.b	d0			; Touched anything ?
	beq	.Nothing
	andi.w	#$00ff,d0			; Yes -> Get real number
	subq.w	#1,d0
	cmp.w	Current_ghost_index,d0	; Already being shown ?
	bne.s	.New
	jsr	Set_ghost_positions		; Yes -> Update position
	bra	.Exit
.New:	jsr	Destroy_ghosts		; Destroy old name
	Get	Inventory_handle,a0		; No -> Get conditions
	move.w	Body_conditions(a0),d7
	Free	Inventory_handle
	move.w	d7,d1			; Dead ?
	andi.w	#Dead_mask,d1
	beq.s	.Alive
	tst.w	d0			; Yes -> Over first icon ?
	bne	.Exit
	move.w	d0,Current_ghost_index	; Yes
	moveq.l	#Dead,d0			; Show DEAD name
	bra	.Do
.Alive:	lea.l	Condition_icon_table,a0	; Alive -> Check conditions
	move.w	d0,d2
.Again:	move.b	(a0),d1			; Get condition number
	cmp.b	#-1,d1			; Last one ?
	beq	.Exit
	btst	d1,d7			; No -> Got it ?
	beq.s	.Next
	tst.w	d2			; Yes -> Is this the one ?
	beq.s	.Found
	subq.w	#1,d2			; No -> Count down
.Next:	addq.l	#2,a0			; Next body condition
	bra.s	.Again
.Found:	move.w	d0,Current_ghost_index	; Yay!
	move.b	d1,d0
.Do:	move.w	#Active_mask,d1		; Deactivating condition ?
	btst	d0,d1
	bne.s	.Yes
	move.w	#Yellow,Ink_colour		; No
	bra.s	.Go_on
.Yes:	move.w	#Lighter_blue,Ink_colour	; Yes
.Go_on:	move.l	Condition_names_ptr,a0		; Get name
	ext.w	d0
	jsr	Find_small_text
	jsr	Create_1st_ghost		; Create ghost string
	bra.s	.Exit
.Nothing:	jsr	Destroy_ghosts		; Destroy name
.Exit:	rts

;*****************************************************************************
; [ Display Inventory 1 member info ]
; All registers are restored
;*****************************************************************************
Display_Inv1_member_info:
	movem.l	d0-d7/a0-a4,-(sp)
	jsr	Display_small_member_info	; Small info
	Get	Inventory_handle,a1
	move.w	#16,d0			; Clear area
	move.w	#49,d1
	move.w	#191,d2
	move.w	#193,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
;----------- Print character skills ---------------
	move.w	#22,Ink_colour		; Set ink
	move.w	#16+6,d0			; Print "SKILLS"
	move.w	#50+65,d1
	move.w	#12*6,d2
	move.l	Skills_txt_ptr,a0
	jsr	Print_centered_string
	move.w	#2,Ink_colour		; Set ink
	move.l	Short_skill_names_ptr,a2	; Print skills
	move.l	Skill_txt_ptr,a3
	lea.l	Skills(a1),a4
	move.w	#16+6,d3
	move.w	#50+72,d4
	moveq.l	#1,d5
	moveq.l	#"0",d6
	moveq.l	#2,d7
.Loop1:	move.w	d3,d0			; Print skill name
	move.w	d4,d1
	move.l	a2,a0
	jsr	Put_text_line
	move.w	(a4),d0			; Convert normal skill
	add.w	Magic(a4),d0
	move.l	a3,a0
	jsr	DecR_convert
	move.b	#"%",(a0)			; Correction
	move.w	Maximum(a4),d0		; Convert maximum skill
	lea.l	4(a3),a0
	jsr	DecR_convert
	move.b	#"%",(a0)			; Correction
	move.w	d3,d0			; Print skill
	move.w	d4,d1
	addi.w	#5*(Char_width+1),d0
	move.l	a3,a0
	jsr	Put_text_line
	addq.w	#Char_height+1,d4		; Next skill
.Loop2:	tst.b	(a2)+
	bne.s	.Loop2
	addq.w	#Skill_data_size,a4
	addq.w	#1,d5
	cmpi.w	#Max_skills+1,d5
	bmi.s	.Loop1
	LOCAL
;----------- Print character attributes -----------
	move.w	#22,Ink_colour		; Set ink
	move.w	#16+6,d0			; Print "ATTRIBUTES"
	move.w	#50,d1
	move.w	#12*6,d2
	move.l	Attrs_txt_ptr,a0
	jsr	Print_centered_string
	move.w	#2,Ink_colour		; Set ink
	move.l	Short_attr_names_ptr,a2		; Print attributes
	move.l	Attr_txt_ptr,a3
	lea.l	Attributes(a1),a4
	move.w	#16+6,d3
	move.w	#50+7,d4
	moveq.l	#1,d5
	moveq.l	#"0",d6
	moveq.l	#3,d7
.Loop1:	move.w	d3,d0			; Print attribute name
	move.w	d4,d1
	move.l	a2,a0
	jsr	Put_text_line
	move.w	(a4),d0			; Convert normal attribute
	add.w	Magic(a4),d0
	move.l	a3,a0
	jsr	DecR_convert
	move.b	#"/",(a0)			; Correction
	move.w	Maximum(a4),d0		; Convert maximum attribute
	lea.l	4(a3),a0
	jsr	DecR_convert
	move.w	d3,d0			; Print attribute
	move.w	d4,d1
	addi.w	#5*(Char_width+1),d0
	move.l	a3,a0
	jsr	Put_text_line
	addq.w	#Char_height+2,d4		; Next attribute
.Loop2:	tst.b	(a2)+
	bne.s	.Loop2
	addq.w	#Attr_data_size,a4
	addq.w	#1,d5
	cmpi.w	#Max_attrs+1,d5
	bmi.s	.Loop1
	LOCAL
; ---------- Print known languages ----------------
	move.w	#22,Ink_colour		; Set ink
	move.w	#16+15*6,d0		; Print "LANGUAGES"
	move.w	#50,d1
	move.w	#12*6,d2
	move.l	Language_txt_ptr,a0
	jsr	Print_centered_string
	move.w	#2,Ink_colour		; Set ink
	move.l	Language_names_ptr,a2		; Print languages
	move.w	#16+15*6,d0
	move.w	#50+7,d1
	move.b	Learned_languages(a1),d6
	moveq.l	#0,d7
.Loop1:	btst	d7,d6			; Language known ?
	beq.s	.Next1
	move.l	a2,a0			; Print language name
	jsr	Put_text_line
.Next1:	addq.w	#Char_height+2,d1		; Next language
.Loop2:	tst.b	(a2)+
	bne.s	.Loop2
	addq.w	#1,d7
	cmpi.w	#Max_languages,d7
	bmi.s	.Loop1
	LOCAL
; ---------- Display conditions -------------------
	move.w	#22,Ink_colour		; Set ink
	move.w	#96,d0			; Print "CONDITIONS"
	move.w	#50+65,d1
	move.w	#80,d2
	move.l	Conditions_txt_ptr,a0
	jsr	Print_centered_string
	move.w	Body_conditions(a1),d6	; Dead or alive ?
	move.w	d6,d0
	andi.w	#Dead_mask,d0
	beq.s	.Alive
	move.w	#96,d0			; Display cross icon
	move.w	#124,d1
	moveq.l	#Screen_depth,d5
	lea.l	Status_icons+(Dead_icon*160)-160,a0
	jsr	Put_masked_icon
	bra	.Dead
.Alive:	lea.l	Bodymind_pos,a2
	lea.l	Condition_icon_table,a3
	lea.l	Status_icons,a4
	move.w	#96,d2
	move.w	#124,d3
	moveq.l	#Screen_depth,d5
.Again:	move.b	(a3),d7			; Get condition number
	cmp.b	#-1,d7			; Last one ?
	beq	.Dead
	btst	d7,d6			; Got it ?
	beq.s	.Next
	move.w	d2,d0			; Get coordinates
	move.w	d3,d1
	add.w	(a2)+,d0
	add.w	(a2)+,d1
	moveq.l	#0,d4			; Get icon address
	move.b	1(a3),d4
	subq.w	#1,d4
	mulu.w	#Icon_size,d4
	lea.l	0(a4,d4.l),a0
	jsr	Put_masked_icon		; Display	icon
.Next:	addq.l	#2,a3			; Next body condition
	bra.s	.Again
.Dead:	LOCAL
	Free	Inventory_handle
	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Display small member info ]
; All registers are restored
;*****************************************************************************
Display_small_member_info:
	movem.l	d0-d7/a0/a1,-(sp)
; ---------- Clear area ---------------------------
	move.w	#208,d0
	move.w	#49,d1
	move.w	#303,d2
	move.w	#128,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
; ---------- Display portrait ---------------------
	lea.l	Portrait_handles,a0		; Get portrait handle
	move.w	Inventory_member,d7
	move.b	-1(a0,d7.w),d4
	move.b	d4,d0			; Get portrait address
	jsr	Claim_pointer
	move.l	d0,a0
	move.w	#208,d0			; Display portrait
	move.w	#49,d1
	moveq.l	#5,d5
	moveq.l	#2,d6
	moveq.l	#34,d7
	jsr	Put_unmasked_block
	Free	d4
; --------- Print character name ------------------
	Get	Inventory_handle,a1
	move.w	#16,Ink_colour		; Set ink
	move.w	#208,d0
	move.w	#84,d1
	move.w	#96,d2
	lea.l	Char_name(a1),a0
	jsr	Print_centered_string
; ---------- Print character sex ------------------
	move.w	#2,Ink_colour		; Set ink
	move.b	Char_sex(a1),d0
	beq.s	.Male
	move.l	Female_txt_ptr,a0
	bra.s	.Do
.Male:	move.l	Male_txt_ptr,a0
.Do:	move.w	#208+34,d0
	move.w	#49+7,d1
	jsr	Put_text_line
; ---------- Print character race -----------------
	move.l	Race_names_ptr,a0		; Get race name address
	moveq.l	#0,d0
	move.b	Char_race(a1),d0
	jsr	Find_small_text
	move.w	#208+34,d0		; Print character race
	move.w	#49,d1
	jsr	Put_text_line
; ---------- Print character class ----------------
	move.b	Char_race(a1),d0		; Special or monster ?
	move.w	#Special_race_mask,d1
	btst	d0,d1
	bne	.No_class
	move.l	Class_names_ptr,a0		; Get class name address
	moveq.l	#0,d0
	move.b	Char_class(a1),d0
	jsr	Find_small_text
	jsr	Strlen			; Get length
	move.w	d0,d2
	move.w	#208+34,d0		; Print character class
	move.w	#49+21,d1
	jsr	Put_text_line
; ---------- Print character level ----------------
	move.b	Level_nr(a1),d0		; Convert	level
	moveq.l	#2,d7
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	#208+34,d0		; Print level
	addq.w	#1,d2
	mulu.w	#Char_width+1,d2
	add.w	d2,d0
	move.w	#49+21,d1
	lea.l	Number,a0
	jsr	Put_text_line
; ---------- Print character's age ----------------
.No_class:	move.w	AAge(a1),d0		; Convert	age
	add.w	AAge+Magic(a1),d0
					; FIX: Removed "add.w Time_data_year,d0".
					;  The age is already increased every year
					;  (see [ Every_year ]) so it was counted twice.
	moveq.l	#3,d7
	move.l	Age_nr_ptr,a0
	jsr	DecL_convert
	move.w	#208+34,d0		; Print age
	move.w	#49+14,d1
	move.l	Age_txt_ptr,a0
	jsr	Put_text_line
; ---------- Print experience points --------------
	move.l	Experience_points(a1),d0	; Convert experience points
	moveq.l	#6,d7
	move.l	Experience_nr_ptr,a0
	jsr	DecL_convert
	move.w	#208+34,d0		; Print experience points
	move.w	#49+28,d1
	move.l	Experience_txt_ptr,a0
	jsr	Put_text_line
; ---------- Exit ---------------------------------
	Free	Inventory_handle
	jsr	Update_small_member_info	; Do the rest
	movem.l	(sp)+,d0-d7/a0/a1
	rts

;*****************************************************************************
; [ Update small member info ]
; All registers are restored
;*****************************************************************************
Update_small_member_info:
	movem.l	d0/d1/d6/d7/a0-a2,-(sp)
	move.w	#208,d0			; Clear area
	move.w	#85+7,d1
	move.w	#303,d2
	move.w	#128,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	Get	Inventory_handle,a1		; Start
	moveq.l	#"0",d6
	moveq.l	#3,d7
	move.w	#2,Ink_colour		; Set ink
; ---------- Print member's life points -----------
	move.l	LP_txt_ptr,a2
	move.w	Life_points(a1),d0		; Convert	normal LP
	lea.l	5(a2),a0
	jsr	DecR_convert
	move.b	#"/",(a0)			; Correction
	move.w	Life_points+Maximum(a1),d0	; Convert	maximum LP
	add.w	Life_points+Magic(a1),d0
	lea.l	9(a2),a0
	jsr	DecR_convert
	move.w	#208+12,d0		; Print LP
	move.w	#85+7,d1
	movea.l	a2,a0
	jsr	Put_text_line
; ---------- Print member's power points ----------
	tst.b	Spell_class_counter(a1)	; Any spell classes	?
	beq	.No_magic
	move.l	PP_txt_ptr,a2
	move.w	Power_points+Maximum(a1),d0	; Convert	maximum PP
	add.w	Power_points+Magic(a1),d0
	lea.l	9(a2),a0
	jsr	DecR_convert
	move.w	Power_points(a1),d0		; Convert	normal PP
	lea.l	5(a2),a0
	jsr	DecR_convert
	move.b	#"/",(a0)			; Correction
	move.w	#208+12,d0		; Print PP
	move.w	#85+14,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Print member's spell learn points ----
	move.l	SLP_txt_ptr,a2
	move.w	Nr_spell_learn_points(a1),d0	; Convert	SLP
	lea.l	4(a2),a0
	jsr	DecR_convert
	move.w	#208+6,d0			; Print SLP
	move.w	#85+21,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Display gold & food ------------------
.No_magic:	move.l	Goldfood_txt_ptr,a2
	move.w	Gold_coins(a1),d0		; Convert gold
	moveq.l	#5,d7
	lea.l	2(a2),a0
	jsr	DecR_convert
	move.b	#" ",(a0)			; Correction
	move.w	Food_rations(a1),d0		; Convert	food
	lea.l	10(a2),a0
	moveq.l	#4,d7
	jsr	DecR_convert
	move.w	#208+6,d0			; Print gold & food
	move.w	#85+28,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Display sword & shield icons ---------
	move.w	#208+6,d0			; Display sword icon
	move.w	#85+35,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#1,d6
	moveq.l	#9,d7
	lea.l	Swordshield,a0
	jsr	Put_masked_block
	addi.w	#47,d0			; Display	shield icon
	lea.l	9*6(a0),a0
	jsr	Put_masked_block
; ---------- Display protection -------------------
	tst.w	Spell_2_duration		; Spell on ?
	beq.s	.No
	move.w	Blinked_colour,Ink_colour	; Yes
	bra.s	.Go_on
.No:	move.w	#2,Ink_colour		; No
.Go_on:	move.l	ProtDam_txt_ptr,a2
	move.w	Protection(a1),d0		; Get protection
	add.w	Protection_magic(a1),d0
	move.w	Spell_2_data,d1		; Add spell's effect (if any)
	beq.s	.Zero
	addi.w	#100,d1
	mulu.w	d1,d0
	divu.w	#100,d0
.Zero:	moveq.l	#"0",d6			; Convert to string
	moveq.l	#3,d7
	lea.l	1(a2),a0
	jsr	SDecR_convert
	move.w	#208+60,d0		; Print protection
	move.w	#85+35+2,d1
	move.l	a2,a0
	jsr	Put_text_line
	LOCAL
; ---------- Display damage -----------------------
	tst.w	Spell_3_duration		; Spell on ?
	beq.s	.No
	move.w	Blinked_colour,Ink_colour	; Yes
	bra.s	.Go_on
.No:	move.w	#2,Ink_colour		; No
.Go_on:	move.w	Damage(a1),d0		; Get damage
	add.w	Damage_magic(a1),d0
	move.w	Spell_3_data,d1		; Add spell's effect (if any)
	beq.s	.Zero
	addi.w	#100,d1
	mulu.w	d1,d0
	divu.w	#100,d0
.Zero:	moveq.l	#"0",d6			; Convert to string
	lea.l	1(a2),a0
	jsr	SDecR_convert
	move.w	#208+12,d0		; Print damage	
	move.w	#85+35+2,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Print member's training points -------
	move.w	#2,Ink_colour
	move.l	TP_txt_ptr,a2
	move.w	Nr_training_points(a1),d0	; Convert	TP
	moveq.l	#"0",d6
	moveq.l	#3,d7
	lea.l	3(a2),a0
	jsr	DecR_convert
	move.w	#208+54,d0		; Print TP
	move.w	#85+21,d1
	move.l	a2,a0
	jsr	Put_text_line
	Free	Inventory_handle
	movem.l	(sp)+,d0/d1/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Inventory 2 module ]
;*****************************************************************************
Inv2_ModInit:
	jsr	Load_object_graphics
	jsr	Reset_party_weight
	jmp	Inv2_DisInit

Inv2_ModExit:
	jsr	Free_object_graphics
; ---------- Validate party combat actions --------
	tst.b	Battling			; Fighting ?
	beq	.Exit
	lea.l	Combat_party,a0
	moveq.l	#6-1,d7
.Loop:	tst.b	Part_type(a0)		; Anyone there ?
	beq	.Next
	Get	Part_handle(a0),a1		; Yes
	move.b	Part_action(a0),d0		; Get action
	beq	.Done			; If any
; ***** Validate close-range attack *****
	cmp.b	#Close_range_action,d0	; Close-range attack ?
	bne.s	.Not1
	move.w	Damage(a1),d0		; Yes -> Get damage
	add.w	Damage_magic(a1),d0
	tst.w	d0			; Any ?
	bne	.Done
.Reset:	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
	bra	.Done
; ***** Validate long-range attack *****
.Not1:	cmp.b	#Long_range_action,d0	; Long-range attack ?
	bne.s	.Not2
	move.w	Char_inventory+Right_hand_slot+Object_index(a1),d0	; Get item in right hand
	beq.s	.Reset			; If any
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	cmp.b	#Longrange_itemtype,Item_type(a2)	; Long-range weapon ?
	bne.s	.Reset
	move.b	Ammo_use_ID(a2),d1		; Get required ammo ID
	beq	.Done			; (if any!)
	move.w	Char_inventory+Left_hand_slot+Object_index(a1),d0		; Get item in left hand
	beq.s	.Reset			; If any
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	cmp.b	Ammo_ID(a2),d1		; Is correct ?
	bne.s	.Reset
	bra	.Done
; ***** Validate using magic objects *****
.Not2:	cmp.b	#Use_magic_object_action,d0	; Using a magic object ?
	bne.s	.Done
	lea.l	Char_inventory(a1),a2	; Get magic item
	moveq.l	#0,d0
	move.b	Part_target+7(a0),d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a2
	move.w	Object_index(a2),d0		; If any
	beq.s	.Reset
	tst.b	Charges(a2)		; Any charges left ?
	beq.s	.Reset
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	tst.b	Spell_number(a2)		; Any magic in this item ?
	beq	.Reset
	move.b	Part_target+4(a0),d0	; Yes -> Same spell ?
	cmp.b	Spell_class(a2),d0
	bne	.Reset
	move.b	Part_target+5(a0),d0
	cmp.b	Spell_number(a2),d0
	bne	.Reset
.Done:	Free	Part_handle(a0)
.Next:	lea.l	Participant_data_size(a0),a0	; Next member
	dbra	d7,.Loop
.Exit:	jmp	Inv2_DisExit

Inv2_DisInit:
	moveq.l	#Inv2_layout,d0		; Show layout
	jsr	Show_layout
	move.w	#19,d0			; Print headline
	move.w	#40,d1
	move.w	#165,d2
	move.l	Inventory_headline_ptr,a0
	jsr	Print_centered_string
	jsr	Display_Inv2_member_info	; Show info
	Push	Scroll_bar,Inv2_scroll_bar
	jsr	Update_weight		; Print weight
	tst.b	Chest_flag		; In chest ?
	bne.s	.Chest
	lea.l	Inv2_CIL,a0		; No
	bra.s	.Go_on
.Chest:	lea.l	ChestInv2_CIL,a0		; Yes
.Go_on:	jsr	Display_control_icons	; Show icons
	jmp	Fade_in_bottom

Inv2_DisExit:
	jsr	Destroy_ghosts		; Destroy !
	Pop	Scroll_bar
	jmp	Fade_out_bottom

Inv2_DisUpd:
	jsr	Update_status_block
	jsr	Update_damage_magic
	jsr	Update_control_icons
	jsr	Update_small_member_info
	jmp	Update_weight

; ********** Inventory 2 - Enter Inventory 1  *****
Go_Inv1:
	jsr	Save_scroll_bar_position
	Pop	Module			; Go
	lea.l	Inv1_Mod,a0
	jmp	Push_Module

; ********** Inventory 2 - Exit Inventory 2 *******
Exit_Inv2:
	jsr	Save_scroll_bar_position
	Pop	Module			; Exit
	jmp	Init_display

; ********** Inventory 2 - Use an item ************
Use_item:
	jsr	Destroy_ghosts		; Destroy !
	move.w	#30,ItemSelect_prompt	; Select item
	Push	Module,Inv2B_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit2
	Get	Inventory_handle,a0		; Get object packet address
	move.l	a0,a1
	lea.l	Char_inventory(a1),a1
	mulu.w	#Object_packet_size,d0
	add.l	d0,a1
	move.l	Object_data_ptr,a2		; Get object data address
	move.w	Object_index(a1),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.w	d0,a2
; ---------- Check if item is broken --------------
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq.s	.Not_broken
	btst	#Broken_item,Item_bits_DYNAMIC(a1)	; Is it ?
	beq.s	.Not_broken
	move.w	#62,d0			; "Broken!"
	jsr	Do_prompt
	bra	.Exit
; ---------- Check for a Use item event -----------
.Not_broken:
	tst.b	Battling			; In combat ?
	bne	.No_event
	tst.b	Handling_event		; In an event chain ?
	bne	.No_event
	move.w	Map_Xcoord,d0		; Find event
	move.w	Map_Ycoord,d1
	jsr	Find_event
	bmi	.No_event
	jsr	Check_event_save_status	; Already saved ?
	bne	.No_event
	lea.l	Current_event_data,a5	; No -> Examine event
	cmp.b	#Query_type,(a5)		; Query ?
	bne	.No_event
	cmp.b	#Item_used_QM_type,Event_b1(a5)	; For used item ?
	bne	.No_event
	move.w	Object_index(a1),Used_object_index	; Yes -> Do
	move.w	Selected_item,d0
	addq.w	#1,d0
	move.w	d0,Casting_item_slot
	Free	Inventory_handle
	st	Using_item
	jsr	Handle_event_chain
	sf	Using_item
	tst.b	Use_item_success		; Success ?
	bne	.Exit2
	Get	Inventory_handle,a0		; No -> Get object packet address
	move.l	a0,a1
	lea.l	Char_inventory(a1),a1
	move.w	Selected_item,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a1
; ---------- Check if item is magical -------------
.No_event:
	tst.b	Spell_number(a2)		; Any magic in this item ?
	beq	.No_magic
	tst.b	Charges(a1)		; Any charges left ?
	bne.s	.Charges_OK
	move.w	#265,d0			; No -> "No charges!"
	jsr	Do_prompt
	bra	.Exit
.Charges_OK:
	move.b	Char_class(a0),d0		; Right class ?
	move.w	Class_use(a2),d1
	btst	d0,d1
	bne.s	.Class_OK
	move.w	#243,d0			; No -> "Wrong class!"
	jsr	Do_prompt
	bra	.Exit
.Class_OK:	lea.l	Spell_data,a3		; Get pointer to spell data
	moveq.l	#0,d0
	move.b	Spell_class(a2),d0
	moveq.l	#0,d1
	move.b	Spell_number(a2),d1
	mulu.w	#Max_spells,d0
	add.w	d1,d0
	subq.w	#1,d0
	mulu.w	#Spell_data_size,d0
	adda.w	d0,a3
	move.b	Spell_area_bits(a3),d0	; Right area ?
	move.w	Spell_area_type,d1
	btst	d1,d0
	bne.s	.Area_OK
	move.w	#244,d0			; No -> "Wrong area!"
	jsr	Do_prompt
	bra	.Exit
.Area_OK:	move.w	Current_world_nr,d4		; Right world ?
	addq.w	#5,d4
	btst	d4,d0
	bne.s	.World_OK
	move.w	#245,d0			; No -> "Wrong world!"
	jsr	Do_prompt
	bra	.Exit
.World_OK:	moveq.l	#0,d0			; Set spell class & number
	move.b	Spell_class(a2),d0
	move.w	d0,Selected_class
	move.b	Spell_number(a2),d0
	move.w	d0,Selected_spell
	st	Magic_object_flag		; Signal objectness
	tst.b	Battling			; In combat ?
	bne.s	.Combat
	move.w	Selected_item,d0		; No -> Save slot number
	addq.w	#1,d0
	move.w	d0,Casting_item_slot
	move.w	Inventory_member,Casting_member	; Set caster's variables
	move.b	Inventory_handle,Casting_handle
	jsr	Do_magic			; Do magic !
	sf	Magic_object_flag
	bra	.Exit
.Combat:	jsr	Exit_Inv2			; Yes -> Leave inventory
	lea.l	Combat_party,a0		; Get participant data
	move.w	Inventory_member,d0
	subq.w	#1,d0
	mulu.w	#Participant_data_size,d0
	add.w	d0,a0
	move.l	a0,Casting_participant	; Set caster's variables
	moveq.l	#0,d0
	move.b	Part_nr(a0),d0
	move.w	d0,Casting_member
	move.b	Part_handle(a0),Casting_handle
	move.w	Selected_item,d0		; Enter action
	addq.w	#1,d0
	move.b	d0,Part_target+7(a0)
 	move.b	#Use_magic_object_action,Part_action(a0)
	jsr	Combat_spell_entry		; Select target
	sf	Magic_object_flag
	bra	.Exit
; ---------- Check if it's a special item ---------
.No_magic:
	cmp.b	#Special_itemtype,Item_type(a2)	; Is it ?
	bne.s	.Not_special
	move.w	Special_item_flags,d0	; Yes -> Get data
	move.b	Misc_1(a2),d1
	btst	d1,d0			; Already in use ?
	beq.s	.No
	move.w	#48,d0			; Yes -> "Fool!"
	jsr	Do_prompt
	bra	.Exit
.No:	bset	d1,d0			; No -> Use
	move.w	d0,Special_item_flags
	move.w	Selected_item,d0		; Destroy object
	addq.w	#1,d0
	jsr	Destroy_used_item
	move.w	#43,d0			; "Yay!"
	jsr	Do_prompt
	bra	.Exit
; ---------- Check if it's a text scroll ----------
.Not_special:
	cmpi.b	#Textscroll_itemtype,Item_type(a2)	; Is it ?
	bne	.No_text_scroll
	moveq.l	#0,d0			; Yes -> Get text file number
	move.b	Misc_1(a2),d0
	moveq.l	#Object_texts_file,d1	; Load text file
	jsr	Load_subfile
	move.b	d0,d7
	jsr	Claim_pointer
	move.l	d0,a0
	moveq.l	#0,d0			; Get text block number
	move.b	Misc_2(a2),d0
	jsr	Do_text_window		; Show text
	move.b	d7,d0			; Remove text file
	jsr	Free_pointer
	jsr	Free_memory
	move.w	Selected_item,d0		; Destroy object
	addq.w	#1,d0
	jsr	Destroy_used_item
	bra	.Exit
; ---------- Check if it's a transportation -------
.No_text_scroll:
	cmp.b	#Transport_itemtype,Item_type(a2)	; Is it ?
	bne	.No_transport
	tst.w	Travel_mode		; On foot ?
	beq.s	.Foot_OK
.Error:	move.w	#63,d0			; "Not here !"
	jsr	Do_prompt
	bra.s	.Exit
.Foot_OK:	cmp.b	#Map_3D,Current_map_type	; In 2D map ?
	bpl.s	.Error
	tst.b	Show_trans		; Show travelmodes ?
	beq.s	.Error
	moveq.l	#0,d7			; Get new travelmode
	move.b	Misc_1(a2),d7
	move.l	Current_location_status,d0	; Way blocked ?
	move.w	d7,d1
	add.w	#Blocked_foot_bit,d1
	btst.l	#Way_blocked_bit,d0
	bne.s	.Error
	btst.l	d1,d0
	beq.s	.Error
	move.w	Selected_item,d0		; Destroy object
	addq.w	#1,d0
	jsr	Destroy_used_item
	move.w	d7,d0			; Set new travelmode
	jsr	Set_new_travel_mode
	Free	Inventory_handle		; Leave Inventory
	jsr	Exit_Inv2
	bra.s	.Exit2
; ---------- Cannot be used -----------------------
.No_transport:
	move.w	#282,d0			; "No use!"
	jsr	Do_prompt
.Exit:	Free	Inventory_handle
.Exit2:	rts

; ********** Inventory 2 - Drop an item ***********
Drop_item:
	jsr	Destroy_ghosts		; Destroy !
	move.w	#28,ItemSelect_prompt	; Select item
	Push	Module,Inv2_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit2
	Get	Inventory_handle,a2		; Get object packet address
	lea.l	Char_inventory(a2),a2
	addi.w	#9,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
	btst	#Droppable,Item_bits_STATIC(a1)	; Droppable ?
	bne.s	.Drop
	moveq.l	#29,d0			; Print "Don't ..."
	jsr	Do_prompt
	bra	.Exit
.Drop:	move.l	#1,InputNr_number		; Single
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple item ?
	beq.s	.Ask
	cmpi.b	#1,Quantity(a2)		; More than one ?
	beq.s	.Ask
	moveq.l	#0,d0			; How much ?
	move.b	Quantity(a2),d0
	move.l	d0,Maximum_number
	move.w	Object_index(a2),InputNr_object
	move.w	#40,InputNr_prompt
	sf	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
.Ask:	moveq.l	#47,d0			; Are you sure ?
	jsr	Prompt_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
	move.w	Selected_item,d0		; Whee !
	addq.w	#1,d0
	move.l	InputNr_number,d1
	jsr	Drop_items
.Exit:	Free	Inventory_handle
.Exit2:	rts

; ********** Inventory 2 - Drop gold **************
Drop_gold:
	jsr	Destroy_ghosts		; Destroy !
	Get	Inventory_handle,a0		; How much ?
	moveq.l	#0,d0
	move.w	Gold_coins(a0),d0
	move.l	d0,Maximum_number
	Free	Inventory_handle
	move.w	#32,InputNr_prompt
	move.b	#1,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
	moveq.l	#49,d0			; Are you sure ?
	jsr	Prompt_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
	Get	Inventory_handle,a0		; Drop gold
	move.l	InputNr_number,d0
	sub.w	d0,Gold_coins(a0)
	mulu.w	#Gold_weight,d0
	sub.l	d0,Weight_normal(a0)
	Free	Inventory_handle
.Exit:	rts

; ********** Inventory 2 - Drop food **************
Drop_food:
	jsr	Destroy_ghosts		; Destroy !
	Get	Inventory_handle,a0		; How much ?
	moveq.l	#0,d0
	move.w	Food_rations(a0),d0
	move.l	d0,Maximum_number
	Free	Inventory_handle
	move.w	#33,InputNr_prompt
	move.b	#2,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
	moveq.l	#50,d0			; Are you sure ?
	jsr	Prompt_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
	Get	Inventory_handle,a0		; Drop food
	move.l	InputNr_number,d0
	sub.w	d0,Food_rations(a0)
	mulu.w	#Food_weight,d0
	sub.l	d0,Weight_normal(a0)
	Free	Inventory_handle
.Exit:	rts

; ********** Inventory 2 - View an item ***********
View_item:
	jsr	Destroy_ghosts		; Destroy !
	move.w	#31,ItemSelect_prompt	; Select item
	Push	Module,Inv2B_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	Get	Inventory_handle,a2		; Get object packet address
	lea.l	Char_inventory(a2),a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	Free	Inventory_handle
	Push	Module,ItemView1_Mod	; Show 'em
.Exit:	rts

; ********** Inventory 2 - Transfer gold **********
Transfer_gold:
	jsr	Destroy_ghosts		; Destroy !
	Get	Inventory_handle,a0		; How much ?
	moveq.l	#0,d0
	move.w	Gold_coins(a0),d0
	move.l	d0,Maximum_number
	Free	Inventory_handle
	move.w	#52,InputNr_prompt
	move.b	#1,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d0		; Any ?
	beq	.Exit
	move.w	Inventory_member,d7		; Anyone interested ?
	jsr	Scan_4_gold_victims
	bne	.Do
	moveq.l	#90,d0			; No !
	jsr	Do_prompt
	bra	.Exit
.Do:	jsr	Show_transfer_victims	; Show
	lea.l	TIVS_Mod,a0		; Who ?
	move.l	#Gold_Mptr,Mouse_ptr(a0)
	jsr	Push_Module
	tst.w	Selected_member
	beq	.Exit
	Get	Inventory_handle,a0		; Remove gold
	move.l	InputNr_number,d0
	sub.w	d0,Gold_coins(a0)
	mulu.w	#Gold_weight,d0
	sub.l	d0,Weight_normal(a0)
	Free	Inventory_handle
	lea.l	Party_handles-1,a1		; Add gold
	add.w	Selected_member,a1
	Get	(a1),a0
	move.l	InputNr_number,d0
	add.w	d0,Gold_coins(a0)
	mulu.w	#Gold_weight,d0
	add.l	d0,Weight_normal(a0)
	Free	(a1)
.Exit:	rts

; ********** Inventory 2 - Transfer food **********
Transfer_food:
	jsr	Destroy_ghosts		; Destroy !
	Get	Inventory_handle,a0		; How much ?
	moveq.l	#0,d0
	move.w	Food_rations(a0),d0
	move.l	d0,Maximum_number
	Free	Inventory_handle
	move.w	#53,InputNr_prompt
	move.b	#2,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d0		; Any ?
	beq	.Exit
	move.w	Inventory_member,d7		; Anyone interested ?
	jsr	Scan_4_food_victims
	bne	.Do
	moveq.l	#90,d0			; No !
	jsr	Do_prompt
	bra	.Exit
.Do:	jsr	Show_transfer_victims	; Show
	lea.l	TIVS_Mod,a0		; Who ?
	move.l	#Food_Mptr,Mouse_ptr(a0)
	jsr	Push_Module
	tst.w	Selected_member
	beq	.Exit
	Get	Inventory_handle,a0		; Remove food
	move.l	InputNr_number,d0
	sub.w	d0,Food_rations(a0)
	mulu.w	#Food_weight,d0
	sub.l	d0,Weight_normal(a0)
	Free	Inventory_handle
	lea.l	Party_handles-1,a1		; Add food
	add.w	Selected_member,a1
	Get	(a1),a0
	move.l	InputNr_number,d0
	add.w	d0,Food_rations(a0)
	mulu.w	#Food_weight,d0
	add.l	d0,Weight_normal(a0)
	Free	(a1)
.Exit:	rts

; ********** Inventory 2 - Drop item in chest *****
Drop_item_CHEST:
	jsr	Destroy_ghosts		; Destroy !
	move.w	#84,ItemSelect_prompt	; Select item
	Push	Module,Inv2_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit2
	Get	Inventory_handle,a2		; Get object packet address
	lea.l	Char_inventory(a2),a2
	addi.w	#9,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
	move.l	#1,InputNr_number		; Single
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple item ?
	beq.s	.One
	cmpi.b	#1,Quantity(a2)		; More than one ?
	beq.s	.One
	moveq.l	#0,d0			; How much ?
	move.b	Quantity(a2),d0
	move.l	d0,Maximum_number
	move.w	Object_index(a2),InputNr_object
	move.w	#85,InputNr_prompt
	sf	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
.One:	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	move.l	InputNr_number,d1
	move.b	d1,Quantity(a0)
	move.b	Chest_data_handle,d0	; Move to chest
	jsr	Auto_move_to_INV
	moveq.l	#0,d2			; Get remaining quantity
	move.b	Quantity(a0),d2
	cmp.w	d1,d2			; Any moved ?
	bne.s	.Yes
	moveq.l	#91,d0			; No !
	jsr	Do_prompt
	bra	.Exit
.Yes:	move.w	Selected_item,d0		; Whee !
	addq.w	#1,d0
	jsr	Drop_items_in_chest
	tst.w	d2			; All moved ?
	beq.s	.Exit
	moveq.l	#92,d0			; No
	jsr	Do_prompt
.Exit:	Free	Inventory_handle
.Exit2:	rts

; ********** Inventory 2 - Drop gold in chest *****
Drop_gold_CHEST:
	jsr	Destroy_ghosts		; Destroy !
	Get	Inventory_handle,a0		; Calculate maximum
	moveq.l	#0,d0
	move.w	Gold_coins(a0),d0
	Free	Inventory_handle
	Get	Chest_data_handle,a0
	move.l	#32767,d1
	sub.w	Chest_gold(a0),d1
	Free	Chest_data_handle
	cmp.l	d1,d0
	bmi.s	.Do
	move.l	d1,d0
.Do:	tst.l	d0			; Any ?
	bne.s	.Yes
	moveq.l	#88,d0			; Full !
	jsr	Do_prompt
	bra	.Exit
.Yes:	move.l	d0,Maximum_number
	move.w	#86,InputNr_prompt		; How much ?
	move.b	#1,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
	Get	Inventory_handle,a0		; Drop gold...
	move.l	InputNr_number,d0
	sub.w	d0,Gold_coins(a0)
	move.w	d0,d1
	mulu.w	#Gold_weight,d1
	sub.l	d1,Weight_normal(a0)
	Free	Inventory_handle
	Get	Chest_data_handle,a0	; ...in chest
	add.w	d0,Chest_gold(a0)
	Free	Chest_data_handle
.Exit:	rts

; ********** Inventory 2 - Drop food in chest *****
Drop_food_CHEST:
	jsr	Destroy_ghosts		; Destroy !
	Get	Inventory_handle,a0		; Calculate maximum
	moveq.l	#0,d0
	move.w	Food_rations(a0),d0
	Free	Inventory_handle
	Get	Chest_data_handle,a0
	move.l	#32767,d1
	sub.w	Chest_food(a0),d1
	Free	Chest_data_handle
	cmp.l	d1,d0
	bmi.s	.Do
	move.l	d1,d0
.Do:	tst.l	d0			; Any ?
	bne.s	.Yes
	moveq.l	#89,d0			; Full !
	jsr	Do_prompt
	bra	.Exit
.Yes:	move.l	d0,Maximum_number
	move.w	#87,InputNr_prompt		; How much ?
	move.b	#2,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
	Get	Inventory_handle,a0		; Drop food...
	move.l	InputNr_number,d0
	sub.w	d0,Food_rations(a0)
	move.w	d0,d1
	mulu.w	#Food_weight,d1
	sub.l	d1,Weight_normal(a0)
	Free	Inventory_handle
	Get	Chest_data_handle,a0	; ...in chest
	add.w	d0,Chest_food(a0)
	Free	Chest_data_handle
.Exit:	rts

;*****************************************************************************
; [ Try to break item ]
;   IN : d2 - Slot index {1...33} (.w)
; All registers are restored
;*****************************************************************************
Try_to_break_item:
	movem.l	d0/d1/d3/a0/a1,-(sp)
	Get	Inventory_handle,a0
	lea.l	Char_inventory(a0),a0	; Get packet address
	move.w	d2,d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	move.w	Object_index(a0),d0		; Any object ?
	beq	.Exit
	move.l	Object_data_ptr,a1		; Get object data
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	btst	#Unbreakable,Item_bits_STATIC(a1)	; Unbreakable ?
	bne	.Exit
	moveq.l	#0,d0			; Try to break
	move.b	Item_break(a1),d0
	move.w	#1000,d1
	jsr	Probe
	bmi.s	.Exit
	jsr	Print_breaking		; Tell 'em
	bset	#Broken_item,Item_bits_DYNAMIC(a0)	; Break !
	cmp.w	#9+1,d2			; Body or backpack ?
	bpl.s	.Backpack
	move.b	Inventory_handle,d0		; Body -> Drop in backpack
	jsr	Auto_move_to_backpack
	jsr	Remove_item		; Remove
	move.w	d2,d0			; Update body slot
	jsr	Display_body_object
	jsr	Update_objects		; Update backpack slots
	bra.s	.Done
.Backpack:	move.w	d2,d0			; Backpack
	sub.w	Scroll_bar_result,d0
	subi.w	#9,d0
	jsr	Display_object
.Done:	jsr	Update_screen
.Exit:	Free	Inventory_handle
	movem.l	(sp)+,d0/d1/d3/a0/a1
	rts

;*****************************************************************************
; [ Print "Object breaks" text ]
;   IN : a1 - Pointer to object data (.l)
; All registers are restored
;*****************************************************************************
Print_breaking:
	movem.l	d0/a0-a2,-(sp)
	lea.l	Broken_text,a2
	Get	Inventory_handle,a0		; Insert character name
	lea.l	Char_name(a0),a0
	move.l	a0,(a2)
	lea.l	Item_name(a1),a1		; Insert object name
	move.l	a1,8(a2)
	move.l	a2,TxtW_ptr		; Set text
	Push	Module,TxtW_Mod
	Free	Inventory_handle
	movem.l	(sp)+,d0/a0-a2
	rts

;*****************************************************************************
; [ Item(s) are dropped ]
;   IN : d0 - Slot number {1...24} (.w)
;        d1 - Number of items (.w)
; All registers are restored
;*****************************************************************************
Drop_items:
	movem.l	d0-d4/d7/a0,-(sp)
	move.w	d0,d2			; Save input
	move.w	d1,d7
	movea.l	Object_pos_list,a0		; Get slot coordinates
	sub.w	Scroll_bar_result,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a0
	move.w	(a0),Slot_X
	move.w	2(a0),Slot_Y
	Get	Slotbase_handle,a0		; Get object packet address
	add.l	Slotbase_offset,a0
	move.w	d2,d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	move.w	Object_index(a0),d0		; Get object index
	Free	Slotbase_handle
	tst.w	d0			; Anything there ?
	beq	.Exit
	move.l	Object_data_ptr,a0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a0
	moveq.l	#0,d0			; Get object graphic address
	move.b	Item_pic(a0),d0
	mulu.w	#Icon_size,d0
	lea.l	Move_key_HDOB,a0		; Initialize HDOB
	move.w	Slot_X,HDOB_drawX(a0)
	move.w	Slot_Y,HDOB_drawY(a0)
	move.b	Object_gfx_handle,HDOB_gfx_handle(a0)
	move.l	d0,HDOB_offset(a0)
	addi.w	#9,d2			; Load
	moveq.l	#1,d3
	moveq.l	#0,d4
	jsr	Add_HDOB			; Start
	jsr	Update_screen
	bra.s	.Entry1
.Loop1:	move.b	Inventory_handle,d0		; Remove item
	jsr	Remove_item
	move.w	d2,d0			; Update object display
	sub.w	Scroll_bar_result,d0
	subi.w	#9,d0
	jsr	Display_object
	jsr	Update_screen
	move.w	Slot_X,HDOB_drawX(a0)	; Initialize position
	move.w	Slot_Y,HDOB_drawY(a0)
	jsr	Drop_HDOB			; Drop
	addq.w	#1,d4			; Count up
	cmp.w	#10,d4			; Taking too long ?
	bpl.s	.Done
.Entry1:	dbra	d7,.Loop1
.Done:	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	jsr	Update_screen
	tst.w	d7			; Too many ?
	bmi.s	.Exit
	bra.s	.Entry2			; Do the rest
.Loop2:	move.b	Inventory_handle,d0		; Remove item
	jsr	Remove_item
	move.w	d2,d0			; Update object display
	sub.w	Scroll_bar_result,d0
	subi.w	#9,d0
	jsr	Display_object
	jsr	Update_screen
.Entry2:	dbra	d7,.Loop2
.Exit:	movem.l	(sp)+,d0-d4/d7/a0
	rts

;*****************************************************************************
; [ Item(s) are dropped in a chest ]
;   IN : d0 - Slot number {1...24} (.w)
;        d1 - Number of items (.w)
; All registers are restored
;*****************************************************************************
Drop_items_in_chest:
	movem.l	d0-d4/d7/a0,-(sp)
	move.w	d0,d2			; Save input
	move.w	d1,d7
	movea.l	Object_pos_list,a0		; Get slot coordinates
	sub.w	Scroll_bar_result,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a0
	move.w	(a0),Slot_X
	move.w	2(a0),Slot_Y
	Get	Slotbase_handle,a0		; Get object packet address
	add.l	Slotbase_offset,a0
	move.w	d2,d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	move.w	Object_index(a0),d0		; Get object index
	Free	Slotbase_handle
	tst.w	d0			; Anything there ?
	beq	.Exit
	move.l	Object_data_ptr,a0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a0
	moveq.l	#0,d0			; Get object graphic address
	move.b	Item_pic(a0),d0
	mulu.w	#Icon_size,d0
	lea.l	Move_key_HDOB,a0		; Initialize HDOB
	move.w	Slot_X,HDOB_drawX(a0)
	move.w	Slot_Y,HDOB_drawY(a0)
	move.b	Object_gfx_handle,HDOB_gfx_handle(a0)
	move.l	d0,HDOB_offset(a0)
	addi.w	#9,d2			; Load
	moveq.l	#1,d3
	moveq.l	#0,d4
	jsr	Add_HDOB			; Start
	jsr	Update_screen
	bra.s	.Entry1
.Loop1:	move.b	Inventory_handle,d0		; Remove item
	jsr	Remove_item
	move.w	d2,d0			; Update object display
	sub.w	Scroll_bar_result,d0
	subi.w	#9,d0
	jsr	Display_object
	jsr	Update_screen
	move.w	Slot_X,HDOB_drawX(a0)	; Initialize position
	move.w	Slot_Y,HDOB_drawY(a0)
	movem.l	d0-d2,-(sp)		; Move it
	move.w	#320,d0
	move.w	#100,d1
	moveq.l	#10,d2
	jsr	Move_HDOB
	movem.l	(sp)+,d0-d2
	addq.w	#1,d4			; Count up
	cmp.w	#10,d4			; Taking too long ?
	bpl.s	.Done
.Entry1:	dbra	d7,.Loop1
.Done:	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	jsr	Update_screen
	tst.w	d7			; Too many ?
	bmi.s	.Exit
	bra.s	.Entry2			; Do the rest
.Loop2:	move.b	Inventory_handle,d0		; Remove item
	jsr	Remove_item
	move.w	d2,d0			; Update object display
	sub.w	Scroll_bar_result,d0
	subi.w	#9,d0
	jsr	Display_object
	jsr	Update_screen
.Entry2:	dbra	d7,.Loop2
.Exit:	movem.l	(sp)+,d0-d4/d7/a0
	rts

;*****************************************************************************
; [ Save scroll bar position ]
; All registers are restored
;*****************************************************************************
Save_scroll_bar_position:
	movem.l	d0/d1/a0,-(sp)
	lea.l	Inventory_scroll_bar_positions,a0	; Store old
	move.w	Inventory_member,d1		;  scroll bar position
	add.w	d1,d1
	jsr	Get_scroll_bar
	move.w	d0,-2(a0,d1.w)
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Update weight display ]
; No registers are restored
;*****************************************************************************
Update_weight:
	move.w	#26,d0			; Make box
	move.w	#151,d1
	move.w	#70,d2
	move.w	#17,d3
	jsr	Draw_standard_box2
	move.w	#2,Ink_colour		; Set ink
	addq.w	#1,d0			; Print "WEIGHT"
	addq.w	#2,d1
	move.l	Weight_txt_ptr,a0
	jsr	Print_centered_string
	Get	Inventory_handle,a1		; Get data
	move.l	Weight_normal(a1),d2
	divu.w	#1000,d2
	move.w	AStrength(a1),d3
	add.w	AStrength+Magic(a1),d3
	Free	Inventory_handle
	cmp.w	d2,d3			; Too heavy ?
	bpl.s	.Ok
	jsr	Blink_colour		; Blink !
	move.w	Blinked_colour,Ink_colour
.Ok:	move.l	Weight_nr1_ptr,a0		; Convert normal weight
	moveq.l	#"0",d6
	moveq.l	#3,d7
	move.w	d2,d0
	jsr	DecR_convert
	move.b	#"K",(a0)
	move.l	Weight_nr2_ptr,a0		; Convert maximum weight
	move.w	d3,d0
	jsr	DecR_convert
	move.b	#"K",(a0)
	move.w	#26,d0			; Print weight
	move.w	#160,d1
	move.w	#70,d2
	move.l	Weight_kg_txt_ptr,a0
	jsr	Print_centered_string
	rts

;*****************************************************************************
; [ Re-evaluate control icons for Inventory 2 ]
; No registers are restored
;*****************************************************************************
Inv2_CIL_evaluate:
	Get	Inventory_handle,a1
; ---------- Check if we are in combat ------------
	tst.b	Battling			; Well ?
	beq.s	.No_combat
	bset	#7,6(a0)			; Disable	{Drop item}
	bset	#7,14(a0)			; Disable	{Transfer	gold}
	bset	#7,16(a0)			; Disable	{Transfer	food}
	move.w	Body_conditions(a1),d0	; Can use item ?
	andi.w	#Use_item_mask,d0
	beq.s	.No_combat
	bset	#7,2(a0)			; Disable	{Use item}
; ---------- Check if character is special --------
.No_combat:
	move.b	Char_race(a1),d0		; Special or monster ?
	move.w	#Special_race_mask,d1
	btst	d0,d1
	beq.s	.Race_OK
	bset	#7,2(a0)			; Disable	{Use item}
	bset	#7,12(a0)			; Disable	{View item}
	bset	#7,14(a0)			; Disable	{Transfer	gold}
	bset	#7,16(a0)			; Disable	{Transfer	food}
; ---------- Check if character CARRIES items -----
.Race_OK:	lea.l	Char_inventory+Backpack_slots(a1),a2
	moveq.l	#0,d0
	moveq.l	#Items_per_char-1,d7
.Loop1:	or.w	Object_index(a2),d0
	addq.w	#Object_packet_size,a2
	dbra	d7,.Loop1
	tst.w	d0			; Any objects ?
	bne.s	.Items_OK
	bset	#7,6(a0)			; Disable {Drop item}
; ---------- Check if character WEARS items -------
	lea.l	Char_inventory(a1),a2
	moveq.l	#0,d0
	moveq.l	#9-1,d7
.Loop2:	or.w	Object_index(a2),d0
	addq.w	#Object_packet_size,a2
	dbra	d7,.Loop2
	tst.w	d0			; Any objects ?
	bne.s	.Items_OK
	bset	#7,2(a0)			; Disable {Use item}
	bset	#7,12(a0)			; Disable {View item}
; ---------- Check if character has any gold ------
.Items_OK:	tst.w	Gold_coins(a1)		; Any gold ?
	bne.s	.Gold_OK
	bset	#7,8(a0)			; Disable	{Drop gold}
	bset	#7,14(a0)			; Disable	{Transfer gold}
; ---------- Check if character has any food ------
.Gold_OK:	tst.w	Food_rations(a1)		; Any food ?
	bne.s	.Food_OK
	bset	#7,10(a0)			; Disable	{Drop food}
	bset	#7,16(a0)			; Disable	{Transfer food}
; ---------- Check if character is alone ----------
.Food_OK:	cmp.w	#1,Nr_members		; Alone ?
	bne.s	.Exit
	bset	#7,14(a0)			; Disable	{Transfer gold}
	bset	#7,16(a0)			; Disable	{Transfer food}
.Exit:	Free	Inventory_handle
	rts

;*****************************************************************************
; [ Display Inventory 2 member info ]
; All registers are restored
;*****************************************************************************
Display_Inv2_member_info:
	movem.l	d0-d7/a0-a2,-(sp)
	jsr	Display_small_member_info	; Display small info
	jsr	Display_body_objects	; Display body objects
; ---------- Display backpack items ---------------
.Skip:	move.w	#-1,Current_ghost_index
	move.b	Inventory_handle,Slotbase_handle
	move.l	#Char_inventory+Backpack_slots,Slotbase_offset
	move.l	#Backpack_pos_list,Object_pos_list
	lea.l	Inventory_scroll_bar_positions,a0	; Get old
	move.w	Inventory_member,d0		;  scroll bar position
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0
	lea.l	Inv2_scroll_bar,a0		; Display scroll bar
	move.w	d0,Scroll_thingy_Y(a0)
	jsr	Init_scroll_bar
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Display body objects ]
; All registers are restored
;*****************************************************************************
Display_body_objects:
	movem.l	d0-d7/a0/a1/a3,-(sp)
	moveq.l	#1,d0			; Display objects
	moveq.l	#9-1,d7
.Loop:	jsr	Display_body_object
	addq.w	#1,d0
	dbra	d7,.Loop
; ---------- Handle hands exception ---------------
	Get	Inventory_handle,a1
	move.l	a1,-(sp)
	lea.l	Char_inventory+Right_hand_slot(a1),a1	; In right hand ?
	move.w	Object_index(a1),d0
	beq.s	.No
	move.l	Object_data_ptr,a1
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	cmpi.b	#2,Hand_use(a1)		; Double-handed ?
	bne.s	.No
	lea.l	Body_pos_list+5*4,a3	; Get coordinates
	move.w	(a3),d0
	move.w	2(a3),d1
	move.w	d0,d2			; Erase area
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	moveq.l	#5,d5			; Display cross over
	moveq.l	#1,d6			;  left hand
	moveq.l	#16,d7
	Get	Object_gfx_handle,a0
	jsr	Put_masked_block2
	Free	Object_gfx_handle
.No:	move.l	(sp)+,a1
; ---------- Handle ringfingers exception ---------
	lea.l	Char_inventory+Right_finger_slot(a1),a1	; In right finger ?
	move.w	Object_index(a1),d0
	beq.s	.Exit
	move.l	Object_data_ptr,a1
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	cmpi.b	#2,Ring_use(a1)		; Double-handed ?
	bne.s	.Exit
	lea.l	Body_pos_list+8*4,a3	; Get coordinates
	move.w	(a3),d0
	move.w	2(a3),d1
	move.w	d0,d2			; Erase area
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	moveq.l	#5,d5			; Display cross over
	moveq.l	#1,d6			;  left ringfinger
	moveq.l	#16,d7
	Get	Object_gfx_handle,a0
	jsr	Put_masked_block2
	Free	Object_gfx_handle
.Exit:	Free	Inventory_handle
	movem.l	(sp)+,d0-d7/a0/a1/a3
	rts

;*****************************************************************************
; [ Inventory 2 transfer victim select modules ]
;*****************************************************************************
TIVS_DisInit:
	clr.w	Selected_member		; Clear
	moveq.l	#44,d0			; Print message
	jsr	Print_prompt
	jsr	Update_screen
	rts

TIVS_DisExit:
	sf	AutoIcon_block		; Enable AutoIcon switching
	jsr	AutoIcon_switch
	jsr	Erase_PA			; Erase text
	jsr	Update_screen
	rts

Victim_selected:  
	jsr	Wait_4_unclick
	move.w	Transfer_victims,d1		; Is it a victim ?
	lsr.w	#8,d0
	btst	d0,d1
	beq	.Exit
	move.w	d0,Selected_member		; Yes
	Pop	Module
.Exit:	rts

;*****************************************************************************
; [ Scan characters to see if gold transfer is possible ]
;   IN : d0 - Number of gold coins (.w)
;        d7 - Number of transferring member / 0 (.w)
;  OUT :     zero = Nobody wants to have anything to do with this filthy gold
;        non-zero = Someone might perhaps be vaguely interested
; All registers are restored
;*****************************************************************************
Scan_4_gold_victims:
	movem.l	d0-d6/a1/a2,-(sp)
	lea.l	Party_handles,a1
	move.w	d0,d1
	move.w	d0,d2
	mulu.w	#Gold_weight,d2
	move.w	#Special_race_mask,d4
	moveq.l	#1,d5
	moveq.l	#0,d6
.Loop:	move.b	(a1)+,d0			; Anyone there ?
	beq	.Next
	cmp.w	d5,d7			; Transferring member ?
	beq	.Next
.Do_it:	jsr	Claim_pointer		; Get character data
	move.l	d0,a2
; ---------- Check if character is normal ---------
	move.b	Char_race(a2),d0		; Special or monster ?
	btst	d0,d4
	bne.s	.Done
; ---------- Check if member is alive -------------
	move.w	#Alive_mask,d3
	and.w	Body_conditions(a2),d3
	bne.s	.Done
; ---------- Check if member is secretive ---------
	tst.b	Secret_inventory(a2)
	bne.s	.Done
; ---------- Check the extra weight ---------------
	move.w	AStrength(a2),d3		; Get possible weight
	add.w	AStrength+Magic(a2),d3
	mulu.w	#1000,d3
	addi.l	#999,d3			; !
	sub.l	Weight_normal(a2),d3
	cmp.l	d2,d3			; Not too heavy ?
	bmi.s	.Done
; ---------- Check the extra coins ----------------
	move.w	Gold_coins(a2),d3
	add.w	d1,d3
	bvs.s	.Done
	bset	d5,d6			; Gimme! Gimme!
.Done:	move.b	-1(a1),d0
	jsr	Free_pointer
.Next:	addq.w	#1,d5			; Next member
	cmpi.w	#6+1,d5
	bmi.s	.Loop
	move.w	d6,Transfer_victims		; Store
	tst.w	d6			; Anyone interested ?
	movem.l	(sp)+,d0-d6/a1/a2
	rts

;*****************************************************************************
; [ Scan characters to see if food transfer is possible ]
;   IN : d0 - Number of food rations (.w)
;        d7 - Number of transferring member / 0 (.w)
;  OUT :     zero = Nobody wants to have anything to do with this filthy food
;        non-zero = Someone might perhaps be vaguely interested
; All registers are restored
;*****************************************************************************
Scan_4_food_victims:
	movem.l	d0-d6/a1/a2,-(sp)
	lea.l	Party_handles,a1
	move.w	d0,d1
	move.w	d0,d2
	mulu.w	#Food_weight,d2
	move.w	#Special_race_mask,d4
	moveq.l	#1,d5
	moveq.l	#0,d6
.Loop:	move.b	(a1)+,d0			; Anyone there ?
	beq	.Next
	cmp.w	d5,d7			; Transferring member ?
	beq	.Next
.Do_it:	jsr	Claim_pointer		; Get character data
	move.l	d0,a2
; ---------- Check if character is normal ---------
	move.b	Char_race(a2),d0		; Special or monster ?
	btst	d0,d4
	bne.s	.Done
; ---------- Check if member is alive -------------
	move.w	#Alive_mask,d3
	and.w	Body_conditions(a2),d3
	bne.s	.Done
; ---------- Check if member is secretive ---------
	tst.b	Secret_inventory(a2)
	bne.s	.Done
; ---------- Check the extra weight ---------------
	move.w	AStrength(a2),d3		; Get possible weight
	add.w	AStrength+Magic(a2),d3
	mulu.w	#1000,d3
	addi.l	#999,d3			; !
	sub.l	Weight_normal(a2),d3
	cmp.l	d2,d3			; Not too heavy ?
	bmi.s	.Done
; ---------- Check the extra rations --------------
	move.w	Food_rations(a2),d3
	add.w	d1,d3
	bvs.s	.Done
	bset	d5,d6			; Gimme! Gimme!
.Done:	move.b	-1(a1),d0
	jsr	Free_pointer
.Next:	addq.w	#1,d5			; Next member
	cmpi.w	#6+1,d5
	bmi.s	.Loop
	move.w	d6,Transfer_victims		; Store
	tst.w	d6			; Anyone interested ?
	movem.l	(sp)+,d0-d6/a1/a2
	rts

;*****************************************************************************
; [ Set status icons according to transfer victim status ]
; All registers are restored
;*****************************************************************************
Show_transfer_victims:
	movem.l	d0/d7/a0,-(sp)
	st	AutoIcon_block		; Disable AutoIcon switching
	lea.l	Party_status_icons,a0
	move.w	Transfer_victims,d0		; Get data
	moveq.l	#1,d7
.Loop:	btst	d7,d0			; Interested ?
	bne.s	.Yes
.No:	move.b	#Refuse_icon,(a0)+		; NO
	bra.s	.Next
.Yes:	move.b	#Accept_icon,(a0)+		; YES
.Next:	addq.w	#1,d7			; Next character
	cmpi.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Item view window 1 ]
;*****************************************************************************
ItemView1_DisInit:
	move.w	#ItemView1_X-16,d0		; Open a window
	move.w	#ItemView1_Y-16,d1
	moveq.l	#18,d2
	moveq.l	#6,d3
	lea.l	ItemView1_L1,a0
	jsr	Open_window
	lea.l	Inter_packet,a1		; Get object packet
	move.l	Object_data_ptr,a2		; Get object data address
	move.w	Object_index(a1),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	jsr	Check_item_cursed		; Cursed item ?
					; FIX: Was "btst #Cursed,Item_bits_STATIC(a2)".
					;  A curse is only shown when the item was
					;  identified (Magic_check bit of the packet).
	sne	Cursed_flag
	Get	Object_gfx_handle,a0	; Get object graphic address
	moveq.l	#0,d0
	move.b	Item_pic(a2),d0
	mulu.w	#Icon_size,d0
	add.l	d0,a0
	move.w	#ItemView1_X-1,d0		; Draw box around icon
	move.w	#ItemView1_Y-1,d1
	moveq.l	#16,d2
	moveq.l	#16,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display icon
	addq.w	#1,d1
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block2
	Free	Object_gfx_handle
	move.w	#2,Ink_colour		; Set colours
	move.w	#ItemView1_X+19,d0		; Print item name
	move.w	#ItemView1_Y+1,d1
	lea.l	Item_name(a2),a0
	jsr	Put_text_line
	moveq.l	#0,d0			; Get item type
	move.b	Item_type(a2),d0
	beq	.No_type			; Any ?
	move.l	Item_type_names_ptr,a0		; Find type name
	subq.w	#1,d0
	jsr	Find_small_text
	move.w	#ItemView1_X+19,d0		; Print item type
	move.w	#ItemView1_Y+9,d1
	jsr	Put_text_line
.No_type:	move.l	Class_names_ptr,a3		; Print classes
	lea.l	Classname_pos_list,a4
	moveq.l	#0,d2
	move.w	#Special_class_mask,d3
	not.w	d3
	and.w	Class_use(a2),d3
.Loop:	btst	d2,d3			; Usable ?
	beq.s	.Next
	move.w	d2,d0			; Find class text
	move.l	a3,a0
	jsr	Find_small_text
	move.w	(a4)+,d0			; Set cursor
	move.w	(a4)+,d1
	jsr	Put_text_line
.Next:	addq.w	#1,d2			; Next class
	cmp.w	#Max_classes,d2
	bmi.s	.Loop
	move.w	#30,Ink_colour
	move.w	#ItemView1_X+145,d0		; Print "CLASSES:"
	move.w	#ItemView1_Y-1,d1
	move.l	Classes_txt_ptr,a0
	jsr	Put_text_line
	move.w	#ItemView1_X+145,d0		; Print "GENDER:"
	move.w	#ItemView1_Y+46,d1
	move.l	Sex_txt_ptr,a0
	jsr	Put_text_line
	move.w	#2,Ink_colour
	lea.l	Conditions_txt_ptr,a0	; Print sex use
					; CHANGE: Was "Sex_use_strings-4". The gender names
					;  are taken from the text pointers (Male_txt_ptr,
					;  Female_txt_ptr, Both_txt_ptr follow).
	moveq.l	#0,d0
	move.b	Sex_use(a2),d0
	lsl.w	#2,d0
	movea.l	0(a0,d0.w),a0
	move.w	#ItemView1_X+145,d0
	move.w	#ItemView1_Y+54,d1
	jsr	Put_text_line
	btst	#Magic_check,Item_bits_DYNAMIC(a1)	; Lored ?
	bne.s	.Do
	cmp.w	#Super_chicken,Travel_mode	; Cheat mode ?
	bne.s	.Skip
.Do:	move.w	#ItemView1_X+223,d0		; Draw box around icon
	move.w	#ItemView1_Y+46,d1
	move.w	#32,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display icon
	addq.w	#1,d1
	moveq.l	#Look_cicon,d3
	jsr	Display_up_button
.Skip:	move.l	Weight2_nr_ptr,a0		; Convert weight
	move.w	Weight(a2),D0
	moveq.l	#" ",d6
	moveq.l	#5,d7
	jsr	DecR_convert
	move.b	#" ",(a0)
	move.w	#ItemView1_X,d0		; Print weight
	move.w	#ItemView1_Y+20,d1
	move.l	Weight2_txt_ptr,a0
	jsr	Put_text_line
	move.l	Hands_nr_ptr,a0		; Convert hands
	move.b	Hand_use(a2),D0
	moveq.l	#1,d7
	jsr	DecL_convert
	move.w	#ItemView1_X,d0		; Print hand use
	move.w	#ItemView1_Y+30,d1
	move.l	Hands_txt_ptr,a0
	jsr	Put_text_line
	move.l	Fingers_nr_ptr,a0		; Convert fingers
	move.b	Ring_use(a2),D0
	moveq.l	#1,d7
	jsr	DecL_convert
	move.w	#ItemView1_X,d0		; Print finger use
	move.w	#ItemView1_Y+38,d1
	move.l	Fingers_txt_ptr,a0
	jsr	Put_text_line
	move.l	Damage_nr_ptr,a0		; Convert damage
	move.b	Damage_pts(a2),d0
	jsr	Cursed_invert
	moveq.l	#2,d7			; FIX: Was 3 digits (too wide for the window)
	jsr	SDecL_convert
	move.w	#ItemView1_X,d0		; Print damage
	move.w	#ItemView1_Y+46,d1
	move.l	Damage_txt_ptr,a0
	jsr	Put_text_line
	move.l	Protection_nr_ptr,a0		; Convert protection
	move.b	Protection_pts(a2),d0
	jsr	Cursed_invert
	moveq.l	#2,d7			; FIX: Was 3 digits (too wide for the window)
	jsr	SDecL_convert
	move.w	#ItemView1_X,d0		; Print protection
	move.w	#ItemView1_Y+54,d1
	move.l	Protection_txt_ptr,a0
	jsr	Put_text_line
	jmp	Update_screen		; End

Do_ItemView2:
	lea.l	Inter_packet,a0		; Possible ?
	btst	#Magic_check,Item_bits_DYNAMIC(a0)	; Lored ?
	bne.s	.Do
	cmp.w	#Super_chicken,Travel_mode	; Cheat mode ?
	bne.s	.Exit
.Do:	move.w	#ItemView1_X+224,d0		; Feedback
	move.w	#ItemView1_Y+47,d1
	moveq.l	#Look_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	Push	Module,ItemView2_Mod
.Exit:	rts

;*****************************************************************************
; [ Item view window 2 ]
;*****************************************************************************
ItemView2_DisInit:
	move.w	#ItemView2_X-16,d0		; Open a window
	move.w	#ItemView2_Y-16,d1
	moveq.l	#12,d2
	moveq.l	#6,d3
	sub.l	a0,a0
	jsr	Open_window
	lea.l	Inter_packet,a1		; Get object packet
	move.l	Object_data_ptr,a2		; Get object data address
	move.w	Object_index(a1),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	move.w	#2,Ink_colour		; Set colours
	move.l	LP_max_nr_ptr,a0		; Convert LP-max
	move.b	LP_max(a2),d0
	jsr	Cursed_invert
	moveq.l	#2,d7
	jsr	SDecL_convert
	move.w	#ItemView2_X,d0		; Print LP-max
	move.w	#ItemView2_Y,d1
	move.l	LP_max_txt_ptr,a0
	jsr	Put_text_line
	move.l	PP_max_nr_ptr,a0		; Convert PP-max
	move.b	SP_max(a2),d0
	jsr	Cursed_invert
	moveq.l	#2,d7
	jsr	SDecL_convert
	move.w	#ItemView2_X+80,d0		; Print PP-max
	move.w	#ItemView2_Y,d1
	move.l	PP_max_txt_ptr,a0
	jsr	Put_text_line
	move.l	MBW_nr_ptr,a0			; Convert MBW
	move.b	Weapon_magic_bonus(a2),D0
	moveq.l	#2,d7
	jsr	DecL_convert
	move.w	#ItemView2_X,d0		; Print MBW
	move.w	#ItemView2_Y+7,d1
	move.l	MBW_txt_ptr,a0
	jsr	Put_text_line
	move.l	MBA_nr_ptr,a0			; Convert MBA
	move.b	Armour_magic_bonus(a2),D0
	moveq.l	#2,d7
	jsr	DecL_convert
	move.w	#ItemView2_X+80,d0		; Print MBA
	move.w	#ItemView2_Y+7,d1
	move.l	MBA_txt_ptr,a0
	jsr	Put_text_line
	move.w	#17,Ink_colour		; Set ink
	move.w	#ItemView2_X,d0		; Print "ATTRIBUTE"
	move.w	#ItemView2_Y+14,d1
	move.l	Attr2_txt_ptr,a0
	jsr	Put_text_line
	move.w	#ItemView2_X,d0		; Print "SKILL"
	move.w	#ItemView2_Y+28,d1
	move.l	Skill2_txt_ptr,a0
	jsr	Put_text_line
	move.w	#2,Ink_colour
	tst.b	Attribute_normal(a2)	; Any attribute changed ?
	beq	.No_attr
	lea.l	Attrskill_nr,a0		; Yes -> Convert attribute bonus
	move.b	Attribute_normal(a2),d0
	jsr	Cursed_invert
	moveq.l	#2,d7
	jsr	SDecL_convert
	move.l	Attribute_names_ptr,a0		; Find attribute name
	moveq.l	#0,d0
	move.b	Attribute(a2),d0
	jsr	Find_small_text
	move.w	#ItemView2_X,d0		; Print
	move.w	#ItemView2_Y+21,d1
	jsr	Put_text_line
	addi.w	#120,d0
	lea.l	Attrskill_nr,a0
	jsr	Put_text_line
.No_attr:	tst.b	Skill_normal(a2)		; Any skill changed ?
	beq	.No_skill
	lea.l	Attrskill_nr,a0		; Yes -> Convert skill bonus
	move.b	Skill_normal(a2),d0
	jsr	Cursed_invert
	moveq.l	#2,d7
	jsr	SDecL_convert
	move.l	Skill_names_ptr,a0		; Find skill name
	moveq.l	#0,d0
	move.b	Skill(a2),d0
	jsr	Find_small_text
	move.w	#ItemView2_X,d0		; Print
	move.w	#ItemView2_Y+35,d1
	jsr	Put_text_line
	addi.w	#120,d0
	lea.l	Attrskill_nr,a0
	jsr	Put_text_line
.No_skill:	move.w	#17,Ink_colour		; Set ink
	tst.b	Charges(a1)		; Any magic ?
	bne	.Magic
	move.w	#ItemView2_X,d0		; Print "MAGIC"
	move.w	#ItemView2_Y+42,d1
	move.l	Magic_txt_ptr,a0
	jsr	Put_text_line
	bra	.No_magic
.Magic:	move.l	Spell_class_names_ptr,a0	; Find spell class name
	moveq.l	#0,d0
	move.b	Spell_class(a2),d0
	jsr	Find_small_text
	move.w	#ItemView2_X,d0		; Print spell class name
	move.w	#ItemView2_Y+42,d1
	jsr	Put_text_line
	move.w	#2,Ink_colour		; Set ink
	lea.l	Charges_txt+1,a0		; Convert charges
	move.b	Charges(a1),d0
	moveq.l	#"0",d6
	moveq.l	#2,d7
	jsr	DecR_convert
	move.b	#")",(a0)			; Correction
	move.l	Spell_names_ptr,a0		; Find spell name
	moveq.l	#0,d0
	move.b	Spell_class(a2),d0
	mulu.w	#Max_spells,d0
	moveq.l	#0,d1
	move.b	Spell_number(a2),d1
	add.w	d1,d0
	subq.w	#1,d0
	jsr	Find_small_text
	jsr	Strlen			; Get name length
	move.w	d0,d7
	move.w	#ItemView2_X,d0		; Print spell name
	move.w	#ItemView2_Y+49,d1
	jsr	Put_text_line
	addq.w	#1,d7			; Print charges
	mulu.w	#Char_width+1,d7
	add.w	d7,d0
	lea.l	Charges_txt,a0
	jsr	Put_text_line
.No_magic:	jsr	Update_screen
	rts

Accursed_blink:
	tst.b	Cursed_flag		; Cursed ?
	beq.s	.Exit
	jsr	Blink_colour		; Blink !
	move.w	Blinked_colour,Ink_colour
	move.w	#ItemView2_X,d0		; Print "CURSED"
	move.w	#ItemView2_Y+56,d1
	move.w	#160,d2
	move.l	Cursed_txt_ptr,a0
	jsr	Print_centered_string
.Exit:	rts

Cursed_invert:
	tst.b	Cursed_flag		; Cursed ?
	beq.s	.Exit
	neg.b	d0			; Negative
.Exit:	rts

;*****************************************************************************
; [ Move item in Inventory 2 ]
;*****************************************************************************
Move_body_item:
	jsr	Wait_4_unclick
; ---------- Item ? What item ? -------------------
	tst.b	d0			; Any selected ?
	beq	.Exit2
	andi.w	#$00ff,d0			; Get real slot number
	move.w	d0,d6
	Get	Inventory_handle,a2		; Get packet address
	lea.l	Char_inventory(a2),a2
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object index
	beq	.Exit			; Anything there ?
	jsr	Destroy_ghosts		; Remove name
	move.l	Object_data_ptr,a1		; Get data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
; ---------- But can it be done ? -----------------
	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed ?
	beq.s	.No1
	moveq.l	#42,d0			; Cursed !
	jsr	Do_prompt
	bra	.Exit
.No1:	tst.b	Battling			; Are we fighting ?
	beq.s	.No2
	btst	#Combat_equip,Item_bits_STATIC(a1)	; Can it be
	bne.s	.No2			;  un-equipped ?
	moveq.l	#56,d0			; Not now !
	jsr	Do_prompt
	bra	.Exit
; ---------- Okay, let's move it ------------------
.No2:	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	Free	Inventory_handle
	move.b	Inventory_handle,d0		; Remove item
	move.w	d6,d2
	jsr	Remove_item
	jsr	Scan_4_transfer_victims	; Anyone interested ?
	jsr	Show_transfer_victims	; Show
	jsr	Display_body_objects
	jsr	Update_screen
	move.w	d6,Source_slot		; Move it !
	move.b	Inventory_handle,Moving_handle
	move.w	Inventory_member,Moving_member
	Push	Module,Move_item_Mod
	bra.s	.Exit2
.Exit:	Free	Inventory_handle		; Exit
.Exit2:	rts

Move_all_backpack_items:
	st	Right_move		; Set
	bra	Enter_backpack_item
Move_backpack_item:
	sf	Right_move		; Clear
Enter_backpack_item:
	jsr	Wait_4_unclick
; ---------- Item ? What item ? -------------------
	tst.b	d0			; Any selected ?
	beq	.Exit2
	cmp.b	#-1,d0			; Scroll bar ?
	beq	.Exit2
	andi.w	#$00ff,d0			; Get real slot number
	move.w	d0,d6
	addi.w	#9,d0
	add.w	Scroll_bar_result,d0
	move.w	d0,Source_slot
	Get	Inventory_handle,a2		; Get packet address
	lea.l	Char_inventory(a2),a2
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object index
	beq	.Exit			; Anything there ?
	jsr	Destroy_ghosts		; Remove name
	move.l	Object_data_ptr,a1		; Get data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
; ---------- But how many ? -----------------------
	move.l	#1,InputNr_number		; Single
	cmp.b	#1,Quantity(a2)		; More than one ?
	beq.s	.Single
	moveq.l	#0,d0			; How many ?
	move.b	Quantity(a2),d0
	tst.b	Right_move		; All ?
	beq.s	.Not_all
	move.l	d0,InputNr_number		; Yes
	bra.s	.Single
.Not_all:	move.l	d0,Maximum_number		; No -> ask
	move.w	Object_index(a2),InputNr_object
	move.w	#54,InputNr_prompt
	sf	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
; ---------- Okay, let's move it ------------------
.Single:	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	move.l	InputNr_number,d0
	move.b	d0,Quantity(a0)
	Free	Inventory_handle
	move.b	Inventory_handle,d0		; Remove item
	move.w	Source_slot,d2
	move.l	InputNr_number,d3
	jsr	Remove_item
	jsr	Scan_4_transfer_victims	; Anyone interested ?
	jsr	Show_transfer_victims	; Show
	move.w	d6,d0
	jsr	Display_object
	jsr	Update_screen
	move.b	Inventory_handle,Moving_handle	; Move it !
	move.w	Inventory_member,Moving_member
	Push	Module,Move_item_Mod
	bra.s	.Exit2
.Exit:	Free	Inventory_handle		; Exit
.Exit2:	rts

;***************************************************************************
; [ Move item target selector ]
; Note:
;  - This routine will only work for the Inventory 2 screen.
;***************************************************************************
Move_item_DisUpd:
	lea.l	Move_item_HDOB,a0		; Update HDOB position
	move.w	Mouse_X,(a0)+
	move.w	Mouse_Y,(a0)+
	jmp	Inv2_DisUpd

Move_item_DisInit:
	jsr	Init_moving_item
	moveq.l	#55,d0			; Print prompt
	jsr	Print_prompt
	jsr	Update_screen
	rts

Move_item_DisExit:
	sf	AutoIcon_block		; Enable AutoIcon switching
	jsr	AutoIcon_switch
	jsr	Erase_PA			; Remove text
	jsr	Destroy_ghosts
	jmp	Update_screen

; ********** Player clicked on body slot **********
Body_item_moved:
	jsr	Wait_4_unclick
	sf	Object_swap_flag		; No swap
	lea.l	Inter_packet,a2		; Get packet address
	move.l	Object_data_ptr,a1		; Get object data address
	move.w	Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	Get	Inventory_handle,a0		; Get character data address
; ---------- Can it be equipped in battle ? -------
	tst.b	Battling			; Are we fighting ?
	beq.s	.Combat_OK
	btst	#Combat_equip,Item_bits_STATIC(a1)	; Can it be
	bne.s	.Combat_OK			;  equipped ?
	moveq.l	#45,d0			; Not now !
	jsr	Do_prompt
	bra	.Exit
; ---------- Is this item equippable ? ------------
.Combat_OK:
	moveq.l	#0,d0			; Get slot
	move.b	Item_body_place(a1),d0
	bne.s	.Equip_OK
	moveq.l	#34,d0			; Cannot do this !
	jsr	Do_prompt
	bra	.Exit
; ---------- Is the slot free ? -------------------
.Equip_OK:
	move.w	d0,Target_slot		; Store
	move.l	a0,a3			; Find target slot
	lea.l	Char_inventory(a3),a3
	subq.w	#1,d0
	move.w	d0,d1
	mulu.w	#Object_packet_size,d1
	add.l	d1,a3	
	move.w	Object_index(a3),d1		; Free ?
	beq	.Free
	cmpi.b	#Right_finger,d0		; Exception ?
	bne.s	.Full
	addq.w	#2,Target_slot		; Store
	move.l	a0,a3			; Other finger free ?
	lea.l	Char_inventory+Left_finger_slot(a3),a3
	move.w	Object_index(a3),d1		; Free ?
	beq	.Free
; ---------- Can the other slot be emptied ? ------
.Full:	move.l	Object_data_ptr,a4		; Get other object data
	subq.w	#1,d1
	mulu.w	#Item_data_size,d1
	add.l	d1,a4
	btst	#Cursed,Item_bits_STATIC(a4)	; Cursed ?
	beq.s	.No
	moveq.l	#42,d0			; Cursed !
	jsr	Do_prompt
	bra	.Exit
.No:	tst.b	Battling			; Are we fighting ?
	beq.s	.Swap
	btst	#Combat_equip,Item_bits_STATIC(a4)	; Can it be
	bne.s	.Swap			;  un-equipped ?
	moveq.l	#56,d0			; Not now !
	jsr	Do_prompt
	bra	.Exit
; ---------- Swap ---------------------------------
.Swap:	cmp.b	#1,Quantity(a2)		; More than one ?
	bne	.Exit
	lea.l	Swap_packet,a4		; Save target packet
	Copy_packet a3,a4
	move.b	Inventory_handle,d0		; Remove item
	move.w	Target_slot,d2
	jsr	Remove_item
	st	Object_swap_flag
; ---------- Is it broken ? -----------------------
.Free:	btst	#Broken_item,Item_bits_DYNAMIC(a2)
	beq.s	.Not_broken
	move.w	#207,d0			; Broken !
	jsr	Do_prompt
	bra	.Done
; ---------- Do you have the right class ? --------
.Not_broken:
	move.b	Char_class(a0),d0		; Right class ?
	move.w	Class_use(a1),d1
	btst	d0,d1
	bne.s	.Class_OK
	moveq.l	#35,d0			; Wrong class !
	jsr	Do_prompt
	bra	.Done
; ---------- Do you have the right sex ? ----------
.Class_OK:
	move.b	Char_sex(a0),d0		; Right sex ?
	move.b	Sex_use(a1),d1
	btst	d0,d1
	bne.s	.Sex_OK
	moveq.l	#36,d0			; Wrong sex !
	jsr	Do_prompt
	bra	.Done
; ---------- Do you have enough hands free ? ------
.Sex_OK:
	move.b	Hand_use(a1),d0		; Does it matter ?
	beq.s	.Hands_OK
	moveq.l	#2,d1			; Maximum is two hands
	sub.b	Hands_occupied(a0),d1
	cmp.b	d0,d1
	bpl.s	.Hands_OK
	moveq.l	#37,d0			; Not enough hands free !
	jsr	Do_prompt
	bra	.Done
; ---------- Do you have enough fingers free ? ----
.Hands_OK:
	move.b	Ring_use(a1),d0		; Does it matter ?
	beq.s	.Fingers_OK
	moveq.l	#2,d1			; Maximum is two ringfingers
	sub.b	Ringfingers_occupied(a0),d1
	cmp.b	d0,d1
	bpl.s	.Fingers_OK
	moveq.l	#38,d0			; Not enough fingers !
	jsr	Do_prompt
	bra	.Done
; ---------- Equip it -----------------------------
.Fingers_OK:
	tst.b	Object_swap_flag		; Move or swap ?
	beq.s	.Move
	lea.l	Inter_packet,a0		; Add new item
	move.b	Inventory_handle,d0
	move.w	Target_slot,d2
	jsr	Add_item_2_body
	lea.l	Swap_packet,a2		; Make new source packet
	Copy_packet a2,a0
	jsr	Destroy_ghosts		; New moving item
	jsr	Exit_moving_item
	jsr	Init_moving_item
	jsr	Scan_4_transfer_victims	; Anyone interested ?
	jsr	Show_transfer_victims	; Show
	jsr	Display_body_objects
	jsr	Update_screen
	move.w	Target_slot,Source_slot	; Move this !
	move.b	Inventory_handle,Moving_handle
	move.w	Inventory_member,Moving_member
	bra	.Exit
.Move:	lea.l	Inter_packet,a0		; Add item
	move.b	Inventory_handle,d0
	move.w	Target_slot,d2
	jsr	Add_item_2_body
	jsr	Display_body_objects	; Show
	jsr	Update_screen
	tst.w	Inter_packet+Object_index	; Any left ?
	beq.s	.All_gone
	jsr	Update_moving_item		; Yes -> Update
	bra.s	.Exit
.All_gone:	jsr	Exit_moving_item		; No -> Destroy & exit
	Pop	Module
.Exit:	Free	Inventory_handle
	rts
.Done:	tst.b	Object_swap_flag		; Was anything swapped ?
	beq.s	.Exit
	move.b	Inventory_handle,d0		; Put it back
	move.w	Target_slot,d2
	lea.l	Swap_packet,a0
	jsr	Add_item_2_body
	bra.s	.Exit

; ********** Player clicked on backpack slot ******
Backpack_item_moved:
	jsr	Wait_4_unclick
; ---------- Item ? What item ? -------------------
	tst.b	d0			; Any selected ?
	beq	.Exit2
	cmp.b	#-1,d0			; Scroll bar ?
	beq	.Exit2
; ---------- Try to move --------------------------
	andi.w	#$00ff,d0			; Get real slot number
	move.w	d0,d6
	addi.w	#9,d0
	add.w	Scroll_bar_result,d0
	move.w	d0,Target_slot
	Get	Inventory_handle,a0		; Get packet address
	move.l	a0,a2
	lea.l	Char_inventory(a2),a2
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	lea.l	Inter_packet,a3
	move.l	Object_data_ptr,a1		; Get data address
	move.w	Object_index(a3),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	move.w	Object_index(a2),d0		; Anything there ?
	beq	.Empty
	cmp.w	Object_index(a3),d0		; Same item ?
	bne	.Swap
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple ?
	beq	.Swap
; ---------- Add to non-empty slot ----------------
	cmpi.b	#99,Quantity(a2)		; Not full ?
	bgt	.Exit
	moveq.l	#0,d0			; Does it	fit in the slot ?
	move.b	Quantity(a2),d0
	moveq.l	#0,d3
	move.b	Quantity(a3),d3
	add.w	d3,d0
	cmpi.w	#99,d0
	bls.s	.End
	moveq.l	#99,d0			; Calculate number that will
	sub.b	Quantity(a2),d0		;  fit
	sub.w	d0,d3
	move.b	#99,Quantity(a2)		; Fill slot
	sub.b	d0,Quantity(a3)		; Remove item(s)
	jsr	Update_moving_item
	mulu.w	Weight(a1),d0		; Increase weight
	add.l	d0,Weight_normal(a0)
	bra	.Exit
.End:	add.b	d3,Quantity(a2)		; Transfer
	mulu.w	Weight(a1),d3		; Increase weight
	add.l	d3,Weight_normal(a0)
	clr.w	Object_index(a3)		; Destroy
	bra	.Exit
; ---------- Fill empty slot ----------------------
.Empty:	Copy_packet a3,a2			; Copy packet
	moveq.l	#0,d3			; Increase weight
	move.b	Quantity(a3),d3
	mulu.w	Weight(a1),d3
	add.l	d3,Weight_normal(a0)
	clr.b	Quantity(a3)		; Destroy item
	clr.w	Object_index(a3)
	bra	.Exit
; ---------- Swap packets -------------------------
.Swap:	lea.l	Swap_packet,a4		; Save target packet
	Copy_packet a2,a4
	move.b	Inventory_handle,d0		; Remove item
	move.w	Target_slot,d2
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	jsr	Remove_item
	Copy_packet a3,a2			; Copy packet
	moveq.l	#0,d3			; Increase weight
	move.b	Quantity(a3),d3
	mulu.w	Weight(a1),d3
	add.l	d3,Weight_normal(a0)
	Copy_packet a4,a3			; Make new source packet
	jsr	Destroy_ghosts		; New moving item
	jsr	Exit_moving_item
	jsr	Init_moving_item
	move.l	a4,a0			; Anyone interested ?
	jsr	Scan_4_transfer_victims
	jsr	Show_transfer_victims	; Show
	jsr	Update_objects
	jsr	Update_screen
	move.w	Target_slot,Source_slot	; Move this !
	move.b	Inventory_handle,Moving_handle
	move.w	Inventory_member,Moving_member
	bra.s	.Skip
.Exit:	jsr	Update_objects		; Show
	jsr	Update_screen
	tst.w	Object_index(a3)		; Any left ?
	bne.s	.Skip
	jsr	Exit_moving_item		; No -> exit
	Pop	Module
.Skip:	Free	Inventory_handle
.Exit2:	rts

; ********** Player aborted ***********************
Move_aborted:
	jsr	Wait_4_unclick
	move.w	Moving_member,d0		; Same guy ?
	cmp.w	Inventory_member,d0
	beq.s	.Skip
	lsl.w	#8,d0			; No -> switch
	jsr	Inv2_Mright
.Skip:	move.w	Source_slot,d0		; Try to put it back
	cmp.w	#9+1,d0			; Body ?
	bmi	Body_item_moved
	subi.w	#9,d0			; No -> Backpack
	move.w	Scroll_bar_result,d1	; Slot out of view ?
	move.w	d0,d2
	sub.w	d1,d2
	cmp.w	#12,d2
	ble.s	.No
	jsr	Set_scroll_bar2		; Set scroll bar
.No:	sub.w	Scroll_bar_result,d0	; Do
	bra	Backpack_item_moved

; ********** Player clicked on member portrait ****
Member_moved:
	jsr	Wait_4_unclick
	move.w	Transfer_victims,d1		; Is it a victim ?
	lsr.w	#8,d0
	btst	d0,d1
	beq	.Exit
	move.w	d0,d7			; Save for later
	lea.l	Party_handles,a0		; Get handle
	move.b	-1(a0,d0.w),d0
	lea.l	Inter_packet,a0		; Automated
	jsr	Auto_move_to_backpack
	tst.w	Inter_packet+Object_index	; Any left ?
	bne.s	.Exit
	jsr	Exit_moving_item		; No -> destroy
	cmp.w	Inventory_member,d7		; Show ?
	bne.s	.No
	jsr	Update_objects		; Yes
.No:	jsr	Update_screen
	Pop	Module
.Exit:	rts

;*****************************************************************************
; [ Automatically distribute items in backpack ]
;   IN : d0 - Character data handle (.b)
;        a0 - Pointer to source packet (.l)
; All registers are restored
;  - This routine does NOT redraw anything ! It is intended as a general,
;    safe method of adding items.
;  - This routine will remove items from the source packet, and destroy
;    the source packet if the quantity reaches zero.
;*****************************************************************************
Auto_move_to_backpack:
	movem.l	d0-d3/d7/a0-a4,-(sp)
	move.l	a0,a2
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Get character data
	move.l	d0,a0
	lea.l	Char_inventory+Backpack_slots(a0),a3	; Get target inventory
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
; ---------- Scan for slots with this item --------
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple ?
	beq	.Single
	move.l	a3,a4			; Get backpack slots
	move.w	Object_index(a2),d2
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	moveq.l	#Items_per_char-1,d7
.Loop1:	move.w	Object_index(a4),d0		; Anything there ?
	beq.s	.Next1
	cmp.w	d2,d0			; Same item ?
	bne.s	.Next1
	cmpi.b	#99,Quantity(a4)		; Not full ?
	bgt.s	.Next1
	moveq.l	#0,d0			; Does it	fit in the slot ?
	move.b	Quantity(a4),d0
	add.w	d3,d0
	cmpi.w	#99,d0
	bls.s	.End
	moveq.l	#99,d0			; Calculate number that will
	sub.b	Quantity(a4),d0		;  fit
	sub.w	d0,d3
	move.b	#99,Quantity(a4)		; Fill slot
	sub.b	d0,Quantity(a2)		; Remove item(s)
	mulu.w	Weight(a1),d0		; Increase weight
	add.l	d0,Weight_normal(a0)
.Next1:	addq.w	#Object_packet_size,a4	; Next packet
	dbra	d7,.Loop1
; ---------- Scan for free slot -------------------
	move.l	a3,a4			; Get backpack slots
	moveq.l	#Items_per_char-1,d7
.Loop2:	tst.w	Object_index(a4)		; Free slot ?
	beq.s	.Do_it1
	addq.w	#Object_packet_size,a4	; Next packet
	dbra	d7,.Loop2
	bra	.Exit			; (shouldn't occur)
.Do_it1:	Copy_packet a2,a4			; Copy packet
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	clr.b	Quantity(a4)
.End:	sub.b	d3,Quantity(a2)		; Transfer
	add.b	d3,Quantity(a4)
	mulu.w	Weight(a1),d3		; Increase weight
	add.l	d3,Weight_normal(a0)
	bra.s	.Exit
; ---------- Scan for free slots in backpack ------
.Single:	move.l	a3,a4			; Get backpack slots
	moveq.l	#Items_per_char-1,d7
.Loop3:	tst.w	Object_index(a4)		; Free slot ?
	beq.s	.Do_it2
	addq.w	#Object_packet_size,a4	; Next packet
	dbra	d7,.Loop3
	bra.s	.Exit			; (shouldn't occur)
; ---------- Fill slot ----------------------------
.Do_it2:	Copy_packet a2,a4			; Copy packet
	subq.b	#1,Quantity(a2)
	move.b	#1,Quantity(a4)
	moveq.l	#0,d3			; Increase weight
	move.w	Weight(a1),d3
	add.l	d3,Weight_normal(a0)
.Exit:	tst.b	Quantity(a2)		; All gone ?
	bgt.s	.Skip
	clr.w	Object_index(a2)		; Yes -> destroy item
.Skip:	move.w	(sp)+,d0
	jsr	Free_pointer
	movem.l	(sp)+,d0-d3/d7/a0-a4
	rts

;*****************************************************************************
; [ Remove item ]
;   IN : d0 - Character data handle (.b)
;        d2 - Slot number {1...33} (.w)
;        d3 - Quantity that is to be removed (backpack only) (.w)
; All registers are restored
; Note :
;  - This routine does NOT redraw anything ! It is intended as a general,
;    safe method of removing items.
;*****************************************************************************
Remove_item:
	movem.l	d0/d1/a0-a3,-(sp)
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Get character data
	move.l	d0,a0
	lea.l	Char_inventory(a0),a2	; Get packet address
	move.w	d2,d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	cmp.w	#9+1,d2			; On body ?
	bmi.s	.Body
	moveq.l	#0,d0			; Reduce quantity
	move.b	Quantity(a2),d0
	sub.w	d3,d0
	bgt.s	.Yes			; Any left ?
	clr.w	Object_index(a2)		; Destroy item
.Yes:	move.b	d0,Quantity(a2)		; Store
	moveq.l	#0,d0			; Remove weight
	move.w	Weight(a1),d0
	mulu.w	d3,d0
	sub.l	d0,Weight_normal(a0)
	bra	.Exit
; ---------- Remove boni --------------------------
.Body:	move.b	Hand_use(a1),d0		; Adjust hands & fingers
	sub.b	d0,Hands_occupied(a0)	;  occupied
	move.b	Ring_use(a1),d0
	sub.b	d0,Ringfingers_occupied(a0)
	moveq.l	#0,d0			; Weapon bonus
	move.b	Weapon_magic_bonus(a1),d0
	sub.w	d0,Magic_bonus_weapon(a0)
	move.b	Armour_magic_bonus(a1),d0	; Armour bonus
	sub.w	d0,Magic_bonus_armour(a0)
	lea.l	Skills(a0),a3		; Skill tax 1
	moveq.l	#0,d0
	move.b	Item_skill_1(a1),d0
	beq.s	.No1
	subq.w	#1,d0
	mulu.w	#6,d0
	moveq.l	#0,d1
	move.b	Malus_1(a1),d1
	add.w	d1,Magic(a3,d0.w)
.No1:	moveq.l	#0,d0			; Skill tax 2
	move.b	Item_skill_2(a1),d0
	beq.s	.No2
	subq.w	#1,d0
	mulu.w	#6,d0
	moveq.l	#0,d1
	move.b	Malus_2(a1),d1
	add.w	d1,Magic(a3,d0.w)
.No2:	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed item ?
	bne.s	.Cursed
	jsr	Negative_boni		; Remove boni
	bra.s	.Go_on
.Cursed:	jsr	Positive_boni		; Add boni
; ---------- Remove body item ---------------------
.Go_on:	moveq.l	#0,d0			; Remove weight
	move.w	Weight(a1),d0
	sub.l	d0,Weight_normal(a0)
	clr.w	Object_index(a2)		; Destroy item
.Exit:	move.w	(sp)+,d0
	jsr	Free_pointer
	movem.l	(sp)+,d0/d1/a0-a3
	rts

;*****************************************************************************
; [ Add item to body ]
;   IN : d0 - Character data handle (.b)
;        d2 - Slot number {1...9} (.w)
;        a0 - Pointer to source packet (.l)
; All registers are restored
; Note :
;  - This routine does not check if d2 contains a valid slot.
;  - This routine does NOT redraw anything ! It is intended as a general,
;    safe method of adding items.
;  - This routine will remove ONE item from the source packet, and destroy
;    the source packet if the quantity reaches zero.
;*****************************************************************************
Add_item_2_body:
	movem.l	d0/d1/a0-a4,-(sp)
	move.l	a0,a4
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Get character data
	move.l	d0,a0
	lea.l	Char_inventory(a0),a2	; Get target packet address
	subq.w	#1,d2
	mulu.w	#Object_packet_size,d2
	add.l	d2,a2
	Copy_packet a4,a2			; Copy packet
	move.b	#1,Quantity(a2)
	move.l	Object_data_ptr,a1		; Get source object data
	move.w	Object_index(a4),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
; ---------- Add boni -----------------------------
	move.b	Hand_use(a1),d0		; Adjust hands & fingers
	add.b	d0,Hands_occupied(a0)	;  occupied
	move.b	Ring_use(a1),d0
	add.b	d0,Ringfingers_occupied(a0)
	moveq.l	#0,d0			; Weapon bonus
	move.b	Weapon_magic_bonus(a1),d0
	add.w	d0,Magic_bonus_weapon(a0)
	move.b	Armour_magic_bonus(a1),d0	; Armour bonus
	add.w	d0,Magic_bonus_armour(a0)
	lea.l	Skills(a0),a3		; Skill tax 1
	moveq.l	#0,d0
	move.b	Item_skill_1(a1),d0
	beq.s	.No1
	subq.w	#1,d0
	mulu.w	#Skill_data_size,d0		; FIX: Was "mulu.w #6,d0" (skills are 8 bytes)
	moveq.l	#0,d1
	move.b	Malus_1(a1),d1
	sub.w	d1,Magic(a3,d0.w)
.No1:	moveq.l	#0,d0			; Skill tax 2
	move.b	Item_skill_2(a1),d0
	beq.s	.No2
	subq.w	#1,d0
	mulu.w	#Skill_data_size,d0		; FIX: Was "mulu.w #6,d0" (skills are 8 bytes)
	moveq.l	#0,d1
	move.b	Malus_2(a1),d1
	sub.w	d1,Magic(a3,d0.w)
.No2:	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed item ?
	bne.s	.Cursed
	jsr	Positive_boni		; Add boni
	bra.s	.Go_on
.Cursed:	jsr	Negative_boni		; Remove boni
; ---------- Add one item -------------------------
.Go_on:	moveq.l	#0,d0			; Add weight
	move.w	Weight(a1),d0
	add.l	d0,Weight_normal(a0)
	subq.b	#1,Quantity(a4)		; Remove 1 item
	bgt.s	.Exit			; All gone ?
	clr.w	Object_index(a4)		; Yes -> destroy item
.Exit:	move.w	(sp)+,d0
	jsr	Free_pointer
	movem.l	(sp)+,d0/d1/a0-a4
	rts

;*****************************************************************************
; [ Give positive boni ]
;   IN : a0 - Pointer to character data (.l)
;        a1 - Pointer to item data (.l)
; All registers are restored
; Note :
;  - This is an internal routine.
;*****************************************************************************
Positive_boni:
	movem.l	d0-d2/a2,-(sp)
	move.b	LP_max(a1),d2		; LP max bonus
	ext.w	d2
	add.w	d2,Life_points+Magic(a0)
	move.b	SP_max(a1),d2		; SP max bonus
	ext.w	d2
	add.w	d2,Power_points+Magic(a0)
	moveq.l	#0,d1			; Attribute bonus ?
	move.b	Attribute_normal(a1),d1
	beq.s	.No1
	lea.l	Attributes(a0),a2		; Yes
	move.b	Attribute(a1),d0
	ext.w	d0
	mulu.w	#Attr_data_size,d0
	add.w	d1,Magic(a2,d0.w)
.No1:	moveq.l	#0,d1			; Skill bonus ?
	move.b	Skill_normal(a1),d1
	beq.s	.No2
	lea.l	Skills(a0),a2		; Yes
	move.b	Skill(a1),d0
	ext.w	d0
	mulu.w	#Skill_data_size,d0
	add.w	d1,Magic(a2,d0.w)
.No2:	moveq.l	#0,d2			; Protection bonus
	move.b	Protection_pts(a1),d2
	add.w	d2,Protection_magic(a0)
	move.b	Damage_pts(a1),d2		; Armour bonus
	add.w	d2,Damage_magic(a0)
	movem.l	(sp)+,d0-d2/a2
	rts

;*****************************************************************************
; [ Give negative boni ]
;   IN : a0 - Pointer to character data (.l)
;        a1 - Pointer to item data (.l)
; All registers are restored
; Note :
;  - This is an internal routine.
;*****************************************************************************
Negative_boni:
	movem.l	d0-d2/a2,-(sp)
	moveq.l	#0,d2			; LP max bonus
	move.b	LP_max(a1),d2
	sub.w	d2,Life_points+Magic(a0)
	move.b	SP_max(a1),d2		; SP max bonus
	sub.w	d2,Power_points+Magic(a0)
	moveq.l	#0,d1			; Attribute bonus ?
	move.b	Attribute_normal(a1),d1
	beq.s	.No1
	lea.l	Attributes(a0),a2		; Yes
	move.b	Attribute(a1),d0
	ext.w	d0
	mulu.w	#Attr_data_size,d0
	sub.w	d1,Magic(a2,d0.w)
.No1:	moveq.l	#0,d1			; Skill bonus ?
	move.b	Skill_normal(a1),d1
	beq.s	.No2
	lea.l	Skills(a0),a2		; Yes
	move.b	Skill(a1),d0
	ext.w	d0
	mulu.w	#Skill_data_size,d0
	sub.w	d1,Magic(a2,d0.w)
.No2:	moveq.l	#0,d2			; Protection bonus
	move.b	Protection_pts(a1),d2
	sub.w	d2,Protection_magic(a0)
	move.b	Damage_pts(a1),d2		; Armour bonus
	sub.w	d2,Damage_magic(a0)
	movem.l	(sp)+,d0-d2/a2
	rts

;*****************************************************************************
; [ Initialize moving item HDOB ]
; All registers are restored
;*****************************************************************************
Init_moving_item:
	movem.l	d0/a0,-(sp)
	lea.l	Inter_packet,a0		; Create HDOB
	jsr	Create_object_graphics
	move.b	d0,Move_item_gfx_handle
	lea.l	Move_item_HDOB,a0		; Install HDOB
	move.w	Mouse_X,HDOB_drawX(a0)
	move.w	Mouse_Y,HDOB_drawY(a0)
	move.b	d0,HDOB_gfx_handle(a0)
	jsr	Add_HDOB
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Destroy moving item HDOB ]
; All registers are restored
;*****************************************************************************
Exit_moving_item:
	movem.l	d0/a0,-(sp)
	lea.l	Move_item_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	jsr	Update_screen
	move.b	Move_item_gfx_handle,d0	; Destroy graphics
	jsr	Free_memory
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Update moving item HDOB graphics ]
; All registers are restored
;*****************************************************************************
Update_moving_item:
	movem.l	d0/a0,-(sp)
	move.b	Move_item_gfx_handle,d0	; Destroy graphics
	jsr	Free_memory
	lea.l	Inter_packet,a0		; Create graphics
	jsr	Create_object_graphics
	move.b	d0,Move_item_gfx_handle
	lea.l	Move_item_HDOB,a0		; Update HDOB
	move.b	d0,HDOB_gfx_handle(a0)
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Create a graphic block containing an object ]
;   IN : a0 - Pointer to object packet (.l)
;  OUT : d0 - Memory handle (.b)
; Changed registers : d0
;*****************************************************************************
Create_object_graphics:
	movem.l	d1/d2/d4-d7/a0/a2,-(sp)
	move.l	a0,a2
	opt	o4-				; (not optimized by the original assembler)
	move.l	#5*2*24,d0		; Make buffer
	opt	o4+
	jsr	Allocate_CHIP
	move.b	d0,d4
	move.l	#24*Bytes_per_line,d0	; Make dummy screen
	jsr	Allocate_CHIP
	jsr	Clear_memory
	move.w	d0,-(sp)
	jsr	Claim_pointer
	move.l	d0,Work_screen
	move.l	Object_data_ptr,a0		; Get object data address
	move.w	Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a0
	moveq.l	#0,d0			; Get object graphic address
	move.b	Item_pic(a0),d0
	mulu.w	#Icon_size,d0
	Get	Object_gfx_handle,a0
	add.l	d0,a0
	moveq.l	#0,d0			; Display object
	moveq.l	#0,d1
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block2
	Free	Object_gfx_handle
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Broken ?
	beq.s	.No
	move.w	d4,-(sp)			; Yes -> Show
	lea.l	Broken,a0
	moveq.l	#26,d4
	moveq.l	#1,d5
	jsr	Put_masked_silhouette
	move.w	(sp)+,d4
.No:	move.b	Quantity(a2),d0
	cmp.b	#1,d0			; Just one ?
	beq.s	.Skip
	lea.l	Number,a0			; Convert quantity
	moveq.l	#2,d7
	jsr	DecL_convert
	move.w	#2,Ink_colour		; Set ink
	move.w	#26,Shadow_colour
	lea.l	Number,a0			; Display quantity
	moveq.l	#0,d0
	addi.w	#17,d1
	moveq.l	#16,d2
	jsr	Print_centered_string
.Skip:	moveq.l	#0,d0			; Get block
	moveq.l	#0,d1
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#24,d7
	Get	d4,a0
	jsr	Get_block
	Free	d4
	move.l	Off_screen,Work_screen	; Reset
	clr.w	Shadow_colour
	move.w	(sp)+,d0			; Destroy screen
	jsr	Free_pointer
	jsr	Free_memory
	move.b	d4,d0			; Output
	movem.l	(sp)+,d1/d2/d4-d7/a0/a2
	rts

;*****************************************************************************
; [ Scan characters to see if transfer is possible ]
;   IN : a0 - Pointer to object packet (.l)
; All registers are restored
;*****************************************************************************
Scan_4_transfer_victims: 
	movem.l	d0-d7/a0-a5,-(sp)
	lea.l	Party_handles,a1
	move.l	Object_data_ptr,a3		; Get object data address
	move.w	Object_index(a0),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a3
	moveq.l	#0,d1			; Get quantity
	move.b	Quantity(a0),d1
	moveq.l	#0,d2			; Get weight of items
	move.w	Weight(a3),d2
	mulu.w	d1,d2
	move.w	Object_index(a0),d5
	moveq.l	#0,d6
	moveq.l	#1,d7
.Loop:	move.b	(a1)+,d0			; Anyone there ?
	beq	.Next
	jsr	Claim_pointer		; Get character data
	move.l	d0,a2
; ---------- Check if character is normal ---------
	move.w	#Special_race_mask,d3	; Special or monster ?
	move.b	Char_race(a2),d0
	btst	d0,d3
	bne.s	.Done
; ---------- Check if member is alive -------------
	move.w	#Alive_mask,d3
	and.w	Body_conditions(a2),d3
	bne.s	.Done
; ---------- Check if member is secretive ---------
	tst.b	Secret_inventory(a2)
	bne.s	.Done
; ---------- Check if the extra weight ------------
	move.w	AStrength(a2),d3
	add.w	AStrength+Magic(a2),d3
	mulu.w	#1000,d3
	addi.l	#999,d3			; !
	sub.l	Weight_normal(a2),d3
	cmp.l	d2,d3			; Not too heavy ?
	bmi.s	.Done
; ---------- Scan for free slots in backpack ------
	lea.l	Char_inventory+Backpack_slots(a2),a4
	moveq.l	#Items_per_char-1,d4
.Loop2:	move.w	Object_index(a4),d3		; Free slot ?
	beq.s	.Do
	cmp.w	d3,d5			; No -> Same object ?
	bne.s	.Next2
	move.l	Object_data_ptr,a5		; Yes -> Get object data
	subq.w	#1,d3
	mulu.w	#Item_data_size,d3
	add.w	d3,a5
	btst	#Multiple,Item_bits_STATIC(a5)	; Multiple item ?
	beq.s	.Next2
	moveq.l	#0,d3			; Yes -> Fits ?
	move.b	Quantity(a4),d3
	add.w	d1,d3
	cmp.w	#100,d3
	bmi.s	.Do
.Next2:	addq.w	#Object_packet_size,a4	; Next packet
	dbra	d4,.Loop2
	bra.s	.Done
.Do:	bset	d7,d6			; Gimme! Gimme!
.Done:	move.b	-1(a1),d0
	jsr	Free_pointer
.Next:	addq.w	#1,d7			; Next member
	cmpi.w	#6+1,d7
	bmi	.Loop
	move.w	d6,Transfer_victims		; Store
	movem.l	(sp)+,d0-d7/a0-a5
	rts

;*****************************************************************************
; [ Destroy used item (maybe) ]
;   IN : d0 - Slot number {1...33} (.w)
; All registers are restored
;*****************************************************************************
Destroy_used_item:
	movem.l	d0/d2/a0,-(sp)
	move.w	d0,d2			; Save
	Get	Inventory_handle,a0		; Get object packet address
	lea.l	Char_inventory(a0),a0
	subq.w	#1,d0	
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	move.w	Object_index(a0),d0		; Get object index
	Free	Inventory_handle
	move.l	Object_data_ptr,a0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	btst	#Destroy_after_use,Item_bits_STATIC(a0,d0.w)	; Destroy ?
	bne.s	.Yes
	btst	#Multiple,Item_bits_STATIC(a0,d0.w)	; Multiple ?
	bne	.Exit
	jsr	Try_to_break_item		; No -> Try to break
	bra	.Exit
.Yes:	move.b	Inventory_handle,d0		; Remove item
	moveq.l	#1,d3
	jsr	Remove_item
	jsr	Get_module_ID		; In Inventory ?
	cmp.b	#Inv2_ID,d0
	bne.s	.Exit
	move.w	d2,d0			; Yes
	cmp.w	#9+1,d0			; Body or backpack ?
	bpl.s	.Backpack
	jsr	Display_body_object		; Body
	bra.s	.Done
.Backpack:	sub.w	Scroll_bar_result,d0	; Backpack
	subi.w	#9,d0
	jsr	Display_object
.Done:	jsr	Update_screen
	move.w	d2,d0			; Boom!
	jsr	Used_item_is_destroyed
.Exit:	movem.l	(sp)+,d0/d2/a0
	rts

	FINGERPRINT

;*****************************************************************************
; [ Used item is destroyed ]
;   IN : d0 - Slot number (1...33)
; All registers are restored
;*****************************************************************************
Used_item_is_destroyed:
	movem.l	d0/d1/a0/a1,-(sp)
	cmp.w	#9+1,d0			; Backpack ?
	bmi.s	.Body
	sub.w	Scroll_bar_result,d0	; Yes -> Adjust
.Body:	lea.l	Body_pos_list,a0		; Get slot coordinates
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a0
	lea.l	Dissolve_HDOB,a1		; Initialize HDOB
	move.w	(a0)+,HDOB_drawX(a1)
	move.w	(a0)+,HDOB_drawY(a1)
	move.l	a1,a0			; Install HDOB
	jsr	Add_HDOB
	moveq.l	#11,d0			; Poof !
	moveq.l	#3,d1
	lea.l	Dissolve,a0
	jsr	Animate_HDOB
	move.l	a1,a0			; Destroy HDOB
	jsr	Remove_HDOB
	jsr	Update_screen
.Exit:	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Reset weight of party members ]
; All registers are restored
;*****************************************************************************
Reset_party_weight:
	movem.l	d0-d2/d6/d7/a0-a3,-(sp)
	lea.l	Party_handles,a3
	moveq.l	#6-1,d7
.Loop1:	move.b	(a3),d0			; Anyone there ?
	beq	.Next1
	jsr	Claim_pointer		; Get character data
	move.l	d0,a0
	lea.l	Char_inventory(a0),a1	; Calculate weight of items
	moveq.l	#0,d0
	moveq.l	#Items_per_char+9-1,d6
.Loop2:	move.w	Object_index(a1),d1		; Anything there ?
	beq.s	.Next2
	subq.w	#1,d1			; Yes -> Get data
	mulu.w	#Item_data_size,d1
	move.l	Object_data_ptr,a2
	add.l	d1,a2
	move.w	Weight(a2),d1		; Get weight
	moveq.l	#0,d2			; Get quantity
	move.b	Quantity(a1),d2
	mulu.w	d2,d1			; Add weight
	add.l	d1,d0
.Next2:	addq.w	#Object_packet_size,a1
	dbra	d6,.Loop2
	move.w	Gold_coins(a0),d1		; Add weight of gold
	mulu.w	#Gold_weight,d1
	add.l	d1,d0
	move.w	Food_rations(a0),d1		; Add weight of food
	mulu.w	#Food_weight,d1
	add.l	d1,d0
	move.l	d0,Weight_normal(a0)	; Repair weight
	move.b	(a3),d0			; Next party member
	jsr	Free_pointer
.Next1:	addq.l	#1,a3
	dbra	d7,.Loop1
	movem.l	(sp)+,d0-d2/d6/d7/a0-a3
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Inv1_CIL:
	dc.w Backpack_cicon,0,Exit_cicon
	dc.w 0,0,0
	dc.w 0,0,0
	dc.l Go_Inv2,0,Inv1_Exit
	dc.l 0,0,0
	dc.l 0,0,0
	dc.l Inv1_CIL_update
Inv2_CIL:
	dc.w Stats_cicon,Use_item_cicon,Exit_cicon
	dc.w Drop_item_cicon,Drop_gold_cicon,Drop_food_cicon
	dc.w View_item_cicon,Transfer_gold_cicon,Transfer_food_cicon
	dc.l Go_Inv1,Use_item,Exit_Inv2
	dc.l Drop_item,Drop_gold,Drop_food
	dc.l View_item,Transfer_gold,Transfer_food
	dc.l Inv2_CIL_evaluate
ChestInv2_CIL:
	dc.w Stats_cicon,Use_item_cicon,Exit_cicon
	dc.w Drop_item_chest_cicon,Drop_gold_chest_cicon,Drop_food_chest_cicon
	dc.w View_item_cicon,Transfer_gold_cicon,Transfer_food_cicon
	dc.l Go_Inv1,Use_item,Exit_Inv2
	dc.l Drop_item_CHEST,Drop_gold_CHEST,Drop_food_CHEST
	dc.l View_item,Transfer_gold,Transfer_food
	dc.l Inv2_CIL_evaluate

; *** INVENTORY I : 2nd layer ***
Inv1_L2:
	dc.w 16,191,49,193			; Condition object area
	dc.b 2
	even
	dc.l Control_area,Inv1_L3

; *** INVENTORY I : 3rd layer - Condition objects ***
Inv1_L3:
	dc.w 96,96+15,124,124+15		; Condition object 1
	dc.b 1
	even
	dc.l .C2
.C2:	dc.w 128,128+15,124,124+15		; Condition object 2
	dc.b 2
	even
	dc.l .C3
.C3:	dc.w 160,160+15,124,124+15		; Condition object 3
	dc.b 3
	even
	dc.l .C4
.C4:	dc.w 112,112+15,140,140+15		; Condition object 4
	dc.b 4
	even
	dc.l .C5
.C5:	dc.w 144,144+15,140,140+15		; Condition object 5
	dc.b 5
	even
	dc.l .C6
.C6:	dc.w 96,96+15,156,156+15		; Condition object 6
	dc.b 6
	even
	dc.l .C7
.C7:	dc.w 128,128+15,156,156+15		; Condition object 7
	dc.b 7
	even
	dc.l .C8
.C8:	dc.w 160,160+15,156,156+15		; Condition object 8
	dc.b 8
	even
	dc.l .C9
.C9:	dc.w 112,112+15,172,172+15		; Condition object 9
	dc.b 9
	even
	dc.l .C10
.C10:	dc.w 144,144+15,172,172+15		; Condition object 10
	dc.b 10
	even
	dc.l 0

; *** INVENTORY II : 2nd layer ***
Inv2_L2:
	dc.w 20,84+15,72,176+15		; Body object area
	dc.b 2
	even
	dc.l Backpack_area,BodyObj_C1
Backpack_area:
	dc.w 109,180,76,163+23		; Backpack object area
	dc.b 3
	even
	dc.l Control_area,Backpack_C1

; *** INVENTORY II : 3rd layer - Body objects ***
BodyObj_C1:
	dc.w 20,20+15,72,72+15		; Body object 1
	dc.b 1
	even
	dc.l .C2
.C2:	dc.w 52,52+15,72,72+15		; Body object 2
	dc.b 2
	even
	dc.l .C3
.C3:	dc.w 84,80+15,72,72+15		; Body object 3
	dc.b 3
	even
	dc.l .C4
.C4:	dc.w 20,20+15,124,124+15		; Body object 4
	dc.b 4
	even
	dc.l .C5
.C5:	dc.w 84,84+15,97,97+15		; Body object 5
	dc.b 5
	even
	dc.l .C6
.C6:	dc.w 84,80+15,124,124+15		; Body object 6
	dc.b 6
	even
	dc.l .C7
.C7:	dc.w 20,20+15,176,176+15		; Body object 7
	dc.b 7
	even
	dc.l .C8
.C8:	dc.w 52,52+15,176,176+15		; Body object 8
	dc.b 8
	even
	dc.l .C9
.C9:	dc.w 84,84+15,176,176+15		; Body object 9
	dc.b 9
	even
	dc.l 0

; *** INVENTORY II : 3rd layer - Backpack objects ***
Backpack_C1:
	dc.w 109,109+15,76,76+23		; Backpack object 1
	dc.b 1
	even
	dc.l .C2
.C2:	dc.w 131,131+15,76,76+23		; Backpack object 2
	dc.b 2
	even
	dc.l .C3
.C3:	dc.w 153,153+15,76,76+23		; Backpack object 3
	dc.b 3
	even
	dc.l .C4
.C4:	dc.w 109,109+15,105,105+23		; Backpack object 4
	dc.b 4
	even
	dc.l .C5
.C5:	dc.w 131,131+15,105,105+23		; Backpack object 5
	dc.b 5
	even
	dc.l .C6
.C6:	dc.w 153,153+15,105,105+23		; Backpack object 6
	dc.b 6
	even
	dc.l .C7
.C7:	dc.w 109,109+15,134,134+23		; Backpack object 7
	dc.b 7
	even
	dc.l .C8
.C8:	dc.w 131,131+15,134,134+23		; Backpack object 8
	dc.b 8
	even
	dc.l .C9
.C9:	dc.w 153,153+15,134,134+23		; Backpack object 9
	dc.b 9
	even
	dc.l .C10
.C10:	dc.w 109,109+15,163,163+23		; Backpack object 10
	dc.b 10
	even
	dc.l .C11
.C11:	dc.w 131,131+15,163,163+23		; Backpack object 11
	dc.b 11
	even
	dc.l .C12
.C12:	dc.w 153,153+15,163,163+23		; Backpack object 12
	dc.b 12
	even
	dc.l ScrollBar_L2

; *** VIEW ITEM WINDOW 1 : 1st layer ***
ItemView1_L1:
	dc.w ItemView1_X,ItemView1_Y
	dc.w 224,224+31,47,47+16
	dc.b 1
	even
	dc.l 0,0

Bodymind_pos:
	dc.w 0,0,32,0,64,0			; Relative positions
	dc.w 16,16,48,16
	dc.w 0,32,32,32,64,32
	dc.w 16,48,48,48

; The following two lists MUST follow each other !
Body_pos_list:
	dc.w 20,72,52,72,84,72
	dc.w 20,124,84,97,84,124
	dc.w 20,176,52,176,84,176
Backpack_pos_list:
	dc.w 109,76,131,76,153,76
	dc.w 109,105,131,105,153,105
	dc.w 109,134,131,134,153,134
	dc.w 109,163,131,163,153,163

Inv2_scroll_bar:
	dc.w Items_per_char,3,4,112,175,76
	dc.l Update_objects
	dcb.b Scroll_bar_extra_data

; CHANGE: The table Sex_use_strings is no longer needed. Its space is
;         used for two number buffers (the texts are external now).
Attrskill_nr:	dc.b " 01",0
Charges_txt:	dc.b "(01)",0
	dc.b 0,0,0
Classname_pos_list:
y	set 0
	rept 5
	dc.w ItemView1_X+145,ItemView1_Y+7+y
y	set y+7
	endr
y	set 0
	rept 4
	dc.w ItemView1_X+145+54,ItemView1_Y+7+y
y	set y+7
	endr

Move_item_HDOB:
	dc.w 0,0
	dc.w 1,24,5,0
	dc.l 0
	dc.b 0,0
	dcb.w 6,0
Condition_icon_table:
	dc.b Lamed,Lamed_icon
	dc.b Poisoned,Poisoned_icon
	dc.b Petrified,Petrified_icon
	dc.b Diseased,Diseased_icon
	dc.b Aging,Aging_icon
	dc.b Irritated,Irritated_icon
	dc.b Mad,Mad_icon
	dc.b Asleep,Asleep_icon
	dc.b Panicked,Panicked_icon
	dc.b Blind,Blind_icon
	dc.b Stoned,Stoned_icon
	dc.b Exhausted,Exhausted_icon
	dc.b -1,-1
	even
