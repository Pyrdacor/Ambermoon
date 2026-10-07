; Places
; Written by J.Horneman (In Tune With The Universe)
; Start : 27-10-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Places event ]
; No registers are restored
;*****************************************************************************
Places:
	lea.l	Current_event_data,a5
	move.w	Hour,d0
	tst.b	Event_b3(a5)		; Always open ?
	bne.s	.No1
	tst.b	Event_b4(a5)
	beq.s	.Open
.No1:	moveq.l	#0,d1			; Get opening time
	move.b	Event_b3(a5),d1
	cmp.w	d0,d1			; Too early ?
	ble.s	.No2
.Closed:	jsr	Restore_coordinates		; Back, sinister fiend !
	moveq.l	#0,d0			; Get closed text number
	move.b	Event_b1(a5),d0
	cmp.b	#-1,d0			; Any ?
	beq	.Exit
	Get	Maptext_handle,a0		; Yes -> Show
	jsr	Do_text_window
	Free	Maptext_handle
	bra	.Exit
.No2:	move.b	Event_b4(a5),d1		; Get closing time
	cmp.w	d1,d0			; Too late ?
	bge.s	.Closed
.Open:	moveq.l	#0,d0			; Get place type
	move.b	Event_b2(a5),d0
	lsl.w	#2,d0			; Get pointer to module
	move.l	.Mods(pc,d0.w),d7
	beq.s	.Exit
	jsr	Exit_display		; Fade out
	moveq.l	#Place_data_file,d0		; Load place data
	jsr	Load_file
	move.b	d0,Place_data_handle
	moveq.l	#0,d0			; Get current place info
	move.b	Event_b2(a5),d0
	move.w	d0,Current_place_type	; Store
	move.w	Event_w6(a5),Current_place_nr
	movea.l	d7,a0			; Do it
	jsr	Push_Module
.Exit:	rts

.Mods:	dc.l Trainer_Mod			; Places modules
	dc.l Healer_Mod
	dc.l Sage_Mod
	dc.l Enchanter_Mod
	dc.l Inn_Mod
	dc.l MerchOBJC_Mod
	dc.l MerchFOOD_Mod
	dc.l MerchOBJC_Mod
	dc.l MerchTRANS_Mod
	dc.l MerchTRANS_Mod
	dc.l MerchTRANS_Mod
	dc.l Blacksmith_Mod

;*****************************************************************************
; [ General places module elements ]
;*****************************************************************************
Places_ModInit:
	move.w	Current_place_type,d7	; Get place type
	cmp.w	#Trainer_place,d7		; Trainer ?
	bne.s	.No1
	lea.l	Trainer_pictures,a0		; Get trainer picture
	add.w	Trainer_skill,a0
	moveq.l	#0,d0
	move.b	(a0),d0
	bra.s	.Do1
.No1:	lea.l	Place_pictures,a0		; Get place picture
	move.w	Current_world_nr,d0
	mulu.w	#Max_places,d0
	add.w	d0,a0
	add.w	d7,a0
	moveq.l	#0,d0
	move.b	(a0),d0
.Do1:	jsr	Load_80x80_picture		; Load picture
	clr.w	Current_gold
	jsr	Init_display		; Build screen
	move.w	Current_place_type,d7	; Get place type
	cmp.w	#Trainer_place,d7		; Trainer ?
	bne.s	.No2
	lea.l	Trainer_enter_texts,a0	; Get trainer text
	move.w	Trainer_skill,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	bra.s	.Do2
.No2:	lea.l	Place_enter_texts-2,a0	; Get place text
	add.w	d7,d7
	move.w	0(a0,d7.w),d0
.Do2:	jsr	Do_prompt			; Print entrance text
	jsr	Pool_gold			; Do
	move.w	d0,Current_gold
	rts

Places_ModExit:
	move.b	Pic_80x80_handle,d0		; Free memory
	jsr	Free_memory
	move.b	Place_data_handle,d0
	jsr	Free_memory
	jsr	Destroy_ghosts		; Kill !
	rts

Places_DisInit:
	jsr	Display_80x80_picture	; Show picture
	move.w	#110,Gold_X		; Set gold & food positions
	move.w	#103,Gold_Y
	move.w	#303-44,Food_X
	move.w	#103,Food_Y
	move.w	#White,Ink_colour		; Set ink colour
	move.w	Current_place_nr,d0		; Get offset to place text
	subq.w	#1,d0
	mulu.w	#Place_string_length,d0
	Get	Place_data_handle,a0	; Calculate pointer to place
	move.w	(a0)+,d1			;  texts
	mulu.w	#Place_data_size,d1
	adda.l	d1,a0
	adda.l	d0,a0
	clr.b	29(a0)			; Insert EOL
	moveq.l	#110,d0			; Print place text
	moveq.l	#37,d1
	move.w	#194,d2
	jsr	Print_centered_string
	Free	Place_data_handle
	jsr	Update_display		; Update
	jmp	Fade_in_bottom		; Fade in

Places_DisUpd:
	jsr	Update_gold		; Display gold
	jmp	Basic_DisUpd		; The usual

; ********** Places - Exit ************************
Exit_PLACES:
	move.w	Current_gold,d0		; Do
	jsr	Divide_gold
	moveq.l	#0,d0
	move.w	d0,Current_gold		; Show
	jsr	Update_gold
	jsr	Update_screen
	tst.w	Current_gold		; Any left ?
	beq	.Leave
	move.w	#139,d0			; Yes -> Leave ?
	jsr	Prompt_req
	tst.b	d0
	bne.s	.Leave
	jsr	Pool_gold			; No -> Pool again
	add.w	d0,Current_gold
	jsr	Update_gold		; Show
	jsr	Update_screen
	bra	.Exit
.Leave:	jsr	Restore_coordinates		; Back !
	jsr	Exit_display		; Fade out
	cmpi.w	#Inn_place,Current_place_type	; Inn ?
	bne.s	.Do
	tst.b	Inn_flag			; Gonna camp ?
	beq.s	.Do
	Get	Place_data_handle,a0	; Set destination
	lea.l	Inn_destination,a1
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	lea.l	2(a0,d0.l),a0
	move.w	Inn_X(a0),(a1)+
	move.w	Inn_Y(a0),(a1)+
	move.w	Inn_map_nr(a0),(a1)
	move.w	Inn_heal_percentage(a0),Current_inn_value
	Free	Place_data_handle
	Pop	Module			; Enter camp
	Push	Module,Camp_Mod
	bra.s	.Exit
.Do:	Pop	Module			; Exit
	jsr	Init_display
.Exit:	rts

;*****************************************************************************
; [ Trainer place event ]
;*****************************************************************************
Trainer_ModInit:
	Get	Place_data_handle,a0	; Get trainer data
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	lea.l	2(a0,d0.l),a0
	move.w	Trainer_price(a0),Total_price
	move.w	Trainer_skill_nr(a0),Trainer_skill
	Free	Place_data_handle
	jmp	Places_ModInit

Trainer_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	Trainer_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

Trainer_CIL_evaluate:
	Get	Active_handle,a1
	move.w	Trainer_skill,d7		; Get skill offset
	mulu.w	#Skill_data_size,d7
	addi.w	#Skills,d7
	moveq.l	#0,d1			; Get possible skill increase
	move.w	Maximum(a1,d7.w),d1
	cmp.w	0(a1,d7.w),d1
	bgt.s	.Ok			; Can be trained ?
	bset	#7,6(a0)			; Disable {Train skill}
.Ok:	Free	Active_handle
	rts

; ********** Trainer - Train skill ****************
Train_skill:
; ---------- Any training points ? ----------------
	Get	Active_handle,a1
	tst.w	Nr_training_points(a1)
	bne.s	.Ok0
	move.w	#181,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit
; ---------- Enough money ? -----------------------
.Ok0:	move.w	Current_gold,d0
	cmp.w	Total_price,d0
	bcc.s	.Ok1			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit
; ---------- How many percent ? -------------------
.Ok1:	move.w	Trainer_skill,d7		; Get skill offset
	mulu.w	#Skill_data_size,d7
	addi.w	#Skills,d7
	moveq.l	#0,d1			; Calculate maximum
	move.w	Maximum(a1,d7.w),d1
	sub.w	0(a1,d7.w),d1
	moveq.l	#0,d0			; How many can you buy ?
	move.w	Current_gold,d0
	divu.w	Total_price,d0
	cmp.w	d1,d0			; Too much ?
	bmi.s	.Not
	move.w	d1,d0			; Yes
.Not:	cmp.w	Nr_training_points(a1),d0	; Enough training points ?
	bls.s	.Ok3
	move.w	Nr_training_points(a1),d0	; No
.Ok3:	ext.l	d0			; Store
	move.l	d0,Maximum_number
	move.w	#179,InputNr_prompt		; How many do you want ?
	st	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d1		; Any ?
	beq	.Exit
; ---------- Sure ? -------------------------------
	move.w	#180,d0
	mulu.w	Total_price,d1
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq	.Exit
; ---------- Train --------------------------------
	sub.w	d1,Current_gold		; Remove gold
	move.l	InputNr_number,d0		; Increase skill
	add.w	d0,0(a1,d7.w)
	sub.w	d0,Nr_training_points(a1)	; Decrease training points
	move.w	#182,d0			; "Yay!"
	jsr	Do_prompt
.Exit:	Free	Active_handle
	rts

;*****************************************************************************
; [ Healer place event ]
;*****************************************************************************
Healer_ModInit:
	move.w	Active_member,Victim_member	; Initialize
	move.b	Active_handle,Victim_handle
	jsr	Load_object_graphics
	jmp	Places_ModInit

Healer_ModExit:
	jsr	Free_object_graphics	; Is also used for other places!
	jmp	Places_ModExit

Healer_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	Healer_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

Healer_DisExit:
	move.w	Victim_member,d7		; Restore old
	jsr	Force_status_update
	jmp	Fade_out_bottom

Healer_CIL_evaluate:
	Get	Victim_handle,a1
; ---------- Dead ? -------------------------------
	move.w	Body_conditions(a1),d0
	andi.w	#Alive_mask,d0
	beq.s	.Ok1
	bset	#7,0(a0)			; Disable {Heal LP}
	bset	#7,6(a0)			; Disable {Heal cursed}
	bra.s	.Ok3
; ---------- Heal LP ? ----------------------------
.Ok1:	move.w	Life_points(a1),d0		; Already at maximum ?
	move.w	Life_points+Maximum(a1),d1
	add.w	Life_points+Magic(a1),d1
	cmp.w	d1,d0
	bmi.s	.Ok2
	bset	#7,0(a0)			; Disable {Heal LP}
; ---------- Remove cursed items ? ----------------
.Ok2:	lea.l	Char_inventory(a1),a2	; Search body
	move.l	Object_data_ptr,a3
	moveq.l	#9-1,d7
.Loop:	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Next
	subq.w	#1,d0			; Get object data address
	mulu.w	#Item_data_size,d0
	move.b	Item_bits_STATIC(a3,d0.l),d0	; Get bits
	btst	#Cursed,d0		; Cursed ?
	bne.s	.Ok3
.Next:	addq.w	#Object_packet_size,a2	; Next slot
	dbra	d7,.Loop
	bset	#7,6(a0)			; Disable {Heal cursed}
; ---------- Heal condition -----------------------
.Ok3:	move.w	Body_conditions(a1),d0
	andi.w	#Healable_mask,d0
	bne.s	.Ok4
	bset	#7,12(a0)			; Disable {Heal conditions}
.Ok4:	Free	Victim_handle
	rts

; ********** Healer - Heal LP *********************
Heal_LP:
; ---------- Enough money ? -----------------------
	Get	Place_data_handle,a0	; Get price
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	move.w	Heal_LP_price+2(a0,d0.l),Total_price
	Free	Place_data_handle
	move.w	Current_gold,d0		; Well ?
	cmp.w	Total_price,d0
	bcc.s	.Ok			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit
; ---------- How many LP ? ------------------------
.Ok:	Get	Victim_handle,a1
	moveq.l	#0,d1			; Calculate maximum
	move.w	Life_points+Maximum(a1),d1
	add.w	Life_points+Magic(a1),d1
	sub.w	Life_points(a1),d1
	moveq.l	#0,d0			; How many can you buy ?
	move.w	Current_gold,d0
	divu.w	Total_price,d0
	cmp.w	d1,d0			; Too much ?
	bmi.s	.Not
	move.w	d1,d0
.Not:	ext.l	d0			; Store
	move.l	d0,Maximum_number
	move.w	#172,InputNr_prompt		; How many do you want ?
	st	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d1		; Any ?
	beq	.Done
; ---------- Sure ? -------------------------------
	move.w	#173,d0
	mulu.w	Total_price,d1
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq.s	.Done
	st	Success			; Success !
; ---------- Heal LP ------------------------------
	sub.w	d1,Current_gold		; Remove gold
	move.l	InputNr_number,d0		; Heal
	add.w	d0,Life_points(a1)
	move.w	Victim_member,d0		; Sparkle
	jsr	Do_sparkle
.Done:	Free	Victim_handle
.Exit:	rts

; ********** Healer - Heal cursed items ***********
Heal_cursed_items:
; ---------- Enough money ? -----------------------
	Get	Place_data_handle,a0	; Get price
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	move.w	Remove_curse_price+2(a0,d0.l),Total_price
	Free	Place_data_handle
	move.w	Current_gold,d0		; Well ?
	cmp.w	Total_price,d0
	bcc.s	.Ok			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit
; ---------- Sure ? -------------------------------
.Ok:	move.w	#178,d0
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq	.Exit
	sub.w	d1,Current_gold		; Remove gold
	st	Success			; Success !
; ---------- Build fake Inventory 2 screen --------
	jsr	Fade_out_bottom		; Fade out
	move.b	Victim_handle,Inventory_handle	; Set
	move.w	Victim_member,Inventory_member
	moveq.l	#Inv2_layout,d0		; Show layout
	jsr	Show_layout
	jsr	Display_Inv2_member_info	; Show info
	jsr	Update_weight		; Print weight
	lea.l	Inv2_CIL,a0		; Show icons
	jsr	Display_control_icons
	jsr	Update_screen
	jsr	Fade_in_bottom
	moveq.l	#25,d0			; Wait
	jsr	Delay
; ---------- Destroy cursed objects ---------------
	Get	Victim_handle,a0		; Search body
	lea.l	Char_inventory(a0),a0
	move.l	Object_data_ptr,a1
	moveq.l	#1,d7
.Loop:	move.w	Object_index(a0),d0		; Anything there ?
	beq.s	.Next
	subq.w	#1,d0			; Get object data address
	mulu.w	#Item_data_size,d0
	move.b	Item_bits_STATIC(a1,d0.l),d0	; Get bits
	btst	#Cursed,d0		; Cursed ?
	beq.s	.Next
	move.w	d7,d0			; Boom !
	jsr	Cursed_item_is_destroyed
	move.b	Victim_handle,d0		; Remove
	move.w	d7,d2
	jsr	Remove_item
	moveq.l	#25,d0			; Wait
	jsr	Delay
.Next:	addq.w	#Object_packet_size,a0	; Next slot
	addq.w	#1,d7
	cmp.w	#9+1,d7
	bmi.s	.Loop
	Free	Victim_handle
; ---------- Exit ---------------------------------
	jsr	Fade_out_bottom		; Fade out
	jsr	Init_display		; Restore
.Exit:	rts

; ********** Healer - Heal condition **************
Heal_condition:
; ---------- Create fake objects ------------------
	jsr	Clear_sold_slots		; Clear
	Get	Victim_handle,a0		; Get conditions
	move.w	Body_conditions(a0),d0
	Free	Victim_handle
	Get	Sold_slots_handle,a0	; Create fake objects
	lea.l	Condition_object_index_table,a1
	moveq.l	#0,d1
	moveq.l	#0,d7
.Loop:	btst	d7,d0			; Condition set ?
	beq.s	.Next
	move.b	#1,Quantity(a0)		; Create object
	move.b	(a1),Object_index+1(a0)
	move.b	d7,Charges(a0)		; !!!
	addq.w	#Object_packet_size,a0	; Next object
	addq.w	#1,d1
.Next:	addq.l	#1,a1			; Next condition
	addq.w	#1,d7
	cmp.w	#16,d7
	bmi.s	.Loop
	Free	Sold_slots_handle
	tst.w	d1			; ANY conditions ?
	beq	.Exit
; ---------- Which condition ? --------------------
	move.b	Sold_slots_handle,Slotbase_handle
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0
	move.w	#12,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
.Repeat:	move.w	#174,ItemSelect_prompt	; Select condition
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	Get	Sold_slots_handle,a2	; Get object packet address
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
	moveq.l	#0,d5			; Get condition
	move.b	Charges(a2),d5
	Free	Sold_slots_handle
	lea.l	Healer_condition_table,a0	; Get price offset
	moveq.l	#0,d1
	move.b	0(a0,d5.w),d1
	Get	Place_data_handle,a0	; Get price
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	add.w	d1,d0
	move.w	2(a0,d0.w),Total_price
	Free	Place_data_handle
; ---------- Enough money ? -----------------------
	move.w	Current_gold,d0		; Well ?
	cmp.w	Total_price,d0
	bcc.s	.Ok			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Repeat
; ---------- Sure ? -------------------------------
.Ok:	move.w	#177,d0
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq	.Repeat
	st	Success			; Success !
; ---------- Heal condition -----------------------
	sub.w	d1,Current_gold		; Remove gold
	Get	Victim_handle,a0		; Heal
	move.w	Body_conditions(a0),d0
	bclr	d5,d0
	move.w	d0,Body_conditions(a0)
	Free	Victim_handle
	Get	Sold_slots_handle,a0	; Remove object
	move.w	Selected_item,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	clr.w	Object_index(a0)
	Free	Sold_slots_handle
	moveq.l	#0,d0			; Get object graphic address
	move.b	Item_pic(a1),d0
	mulu.w	#Icon_size,d0
	Get	Object_gfx_handle,a0
	add.l	d0,a0
	movea.l	Object_pos_list,a1		; Get slot coordinates
	move.w	Selected_item,d0
	sub.w	Scroll_bar_result,d0
	lsl.w	#2,d0
	add.w	d0,a1
	move.w	(a1),d0
	move.w	2(a1),d1
	move.w	d0,d2			; Erase slot
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	jsr	Update_screen
	moveq.l	#0,d4			; Boom !
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Explode_bitmap
	Free	Object_gfx_handle
; ---------- Resurrecting ? -----------------------
	cmp.w	#Dust,d5			; Dust ?
	bne.s	.No_dust
	Get	Victim_handle,a0		; Yes -> Turn to ashes
	move.w	Body_conditions(a0),d0
	bset	#Ashes,d0
	move.w	d0,Body_conditions(a0)
	Free	Victim_handle
	bra	.Done
.No_dust:	cmp.w	#Ashes,d5			; Ashes ?
	bne.s	.No_ashes
	Get	Victim_handle,a0		; Yes -> Turn to dead
	move.w	Body_conditions(a0),d0
	bset	#Dead,d0
	move.w	d0,Body_conditions(a0)
	Free	Victim_handle
	bra	.Done
.No_ashes:	cmp.w	#Dead,d5			; Dead ?
	bne	.Done
	move.w	Victim_member,d7		; "Yay!"
	jsr	Force_status_update
	move.b	Victim_handle,Subject_handle
	move.w	#57,d0
	jsr	Do_prompt
	jsr	Erase_PA			; Clear
.Done:	move.b	Sold_slots_handle,d0	; Healthy ?
	jsr	Check_slots_empty
	bne	.Repeat			; No -> Repeat
.Exit:	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Update_screen

;*****************************************************************************
; [ Display ANKH ]
; No registers are restored
;*****************************************************************************
Display_Ankh:
	move.w	Victim_member,d0		; Calculate X-coordinate
	subq.w	#1,d0
	mulu.w	#48,d0
	addi.w	#16,d0
	moveq.l	#1,d1			; Initialize
	moveq.l	#5,d5
	moveq.l	#2,d6
	moveq.l	#29,d7
	lea.l	Ankh_symbol,a0		; Display ANKH
	jmp	Put_masked_block

;*****************************************************************************
; [ Left mouse-button clicked	on party member - Healer ] MOUSE EVENT
; No registers are restored
;*****************************************************************************
Healer_member_left:        
	andi.l	#$0000ff00,d0		; Get member number
	beq.s	.Exit
	lsr.w	#8,d0
	cmp.w	Victim_member,d0		; Same ?
	beq.s	.Exit
	lea.l	Party_handles-1,a0		; Get data handle
	add.w	d0,a0
	tst.b	(a0)			; Anyone there ?
	beq.s	.Exit
	move.w	Victim_member,d7		; Yes -> Restore old
	jsr	Force_status_update
	move.w	d0,Victim_member		; Set new
	move.b	(a0),Victim_handle
	jsr	Display_Ankh		; Show
.Exit:	rts

;*****************************************************************************
; [ Healer victim selected by keys F1...F6 ] KEY EVENT
;*****************************************************************************
Healer_select_1:
	move.w	#1*256,d0
	jmp	Healer_member_left
Healer_select_2:
	move.w	#2*256,d0
	jmp	Healer_member_left
Healer_select_3:
	move.w	#3*256,d0
	jmp	Healer_member_left
Healer_select_4:
	move.w	#4*256,d0
	jmp	Healer_member_left
Healer_select_5:
	move.w	#5*256,d0
	jmp	Healer_member_left
Healer_select_6:
	move.w	#6*256,d0
	jmp	Healer_member_left

;*****************************************************************************
; [ Cursed item is destroyed ]
;   IN : d0 - Slot number {1...9} (.w)
; All registers are restored
;*****************************************************************************
Cursed_item_is_destroyed:
	movem.l	d0-d4/d6/d7/a0,-(sp)
	move.w	d0,Moved_slot		; Save input
	lea.l	Body_pos_list-4,a0		; Get slot coordinates
	lsl.w	#2,d0
	add.w	d0,a0
	move.w	(a0),Slot_X
	move.w	2(a0),Slot_Y
	Get	Victim_handle,a0		; Get object packet address
	lea.l	Char_inventory(a0),a0
	move.w	Moved_slot,d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	move.w	Object_index(a0),d0		; Get object index
	Free	Victim_handle
	tst.w	d0			; Anything there ?
	beq	.Exit
	move.l	Object_data_ptr,a0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a0
	moveq.l	#0,d0			; Get object graphic address
	move.b	Item_pic(a0),d0
	mulu.w	#Icon_size,d0
	Get	Object_gfx_handle,a0
	add.l	d0,a0
	move.w	Slot_X,d0			; Erase slot
	move.w	Slot_Y,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	jsr	Update_screen
	move.w	Slot_X,d0			; Boom !
	move.w	Slot_Y,d1
	moveq.l	#0,d4
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Explode_bitmap
	Free	Object_gfx_handle
.Exit:	movem.l	(sp)+,d0-d4/d6/d7/a0
	rts

;*****************************************************************************
; [ Sage place event ]
;*****************************************************************************
Sage_ModInit:
	Get	Place_data_handle,a0	; Get examination price
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	move.w	Sage_price+2(a0,d0.l),Total_price
	Free	Place_data_handle
	jsr	Load_object_graphics
	jmp	Places_ModInit

Sage_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	Sage_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

; ********** Sage - Examine body item *************
Examine_body_item:
; ---------- Enough money ? -----------------------
	move.w	Current_gold,d0
	cmp.w	Total_price,d0
	bcc.s	.Ok			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit2
; ---------- Fake twelve slots --------------------
.Ok:	jsr	Clear_sold_slots		; Clear
	Get	Active_handle,a0		; Duplicate body slots
	lea.l	Char_inventory(a0),a0
	Get	Sold_slots_handle,a1
	move.l	#9*Object_packet_size,d0
	jsr	Copy_memory
	Free	Sold_slots_handle
	Free	Active_handle
; ---------- Which item ? -------------------------
	move.w	#169,ItemSelect_prompt	; Select item
	move.b	Sold_slots_handle,Slotbase_handle
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#12,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	jsr	Do_examine		; Yes -> Do
	st	Success			; Success !
.Exit:	jsr	Hide_Lay3_objects		; Hide slots
	jsr	Update_screen
.Exit2:	rts

; ********** Sage - Examine backpack item *********
Examine_backpack_item:
; ---------- Enough money ? -----------------------
	move.w	Current_gold,d0
	cmp.w	Total_price,d0
	bcc.s	.Ok			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit2
; ---------- Which item ? -------------------------
.Ok:	move.w	#169,ItemSelect_prompt	; Select item
	move.b	Active_handle,Slotbase_handle
	move.l	#Char_inventory+Backpack_slots,Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#Items_per_char,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	addi.w	#9,d0			; Yes -> Do
	jsr	Do_examine
	st	Success			; Success !
.Exit:	jsr	Hide_Lay3_objects		; Hide slots
	jsr	Update_screen
.Exit2:	rts

;*****************************************************************************
; [ Examine object ]
;   IN : d0 - Slot index {0...32} (.w)
; No registers are restored
;*****************************************************************************
Do_examine:
	Get	Active_handle,a2		; Get object packet address
	lea.l	Char_inventory(a2),a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
; ---------- Already examined ? -------------------
	btst	#Magic_check,Item_bits_DYNAMIC(a2)
	beq.s	.Ok1
	move.w	#170,d0			; Fool !
	jsr	Do_prompt
	bra.s	.Exit
; ---------- Are you sure ? -----------------------
.Ok1:	move.w	#171,d0
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
; ---------- Do it --------------------------------
	sub.w	d1,Current_gold		; Remove gold
	bset	#Magic_check,Item_bits_DYNAMIC(a2)	; Examined !
	move.w	Selected_item,d0		; Sparkle!
	jsr	Sparkle_object2
	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	Free	Active_handle
	Push	Module,ItemView1_Mod	; Show 'em
	bra.s	.Exit2
.Exit:	Free	Active_handle
.Exit2:	rts

;*****************************************************************************
; [ Enchanter place event ]
;*****************************************************************************
Enchanter_ModInit:
	Get	Place_data_handle,a0	; Get enchantment price
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	move.w	Enchantment_price+2(a0,d0.l),Total_price
	Free	Place_data_handle
	jsr	Load_object_graphics
	jmp	Places_ModInit

Enchanter_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	Enchanter_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

; ********** Enchanter - Enchant item *************
Enchant_item:
; FIX: The gold check was moved behind the item selection,
;      because the price now depends on the item (#125).
; ---------- Which item ? -------------------------
.Ok0:	move.w	#155,ItemSelect_prompt	; Select item
	move.b	Active_handle,Slotbase_handle
	move.l	#Char_inventory+Backpack_slots,Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#Items_per_char,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	Get	Active_handle,a2		; Get object packet address
	lea.l	Char_inventory+Backpack_slots(a2),a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
; ---------- Magical object ? ---------------------
	tst.b	Spell_number(a1)
	bne.s	.Ok1
	move.w	#163,d0			; Fool !
	jsr	Do_prompt
	bra	.Done
; ---------- Already charged up ? -----------------
.Ok1:	move.b	Charges(a2),d0
	cmp.b	Enchantment_charge_max(a1),d0
	bmi.s	.Ok2
	move.w	#164,d0			; Fool !
	jsr	Do_prompt
	bra	.Done
; ---------- Maximum enchantment reached ? --------
.Ok2:	move.b	Enchantment_normal(a2),d0
	cmp.b	Enchantment_max(a1),d0
	bmi.s	.Ok3
	move.w	#165,d0			; Fool !
	jsr	Do_prompt
	bra	.Done
; ---------- Enough money ? -----------------------
.Ok3:	moveq.l	#0,d0			; FIX: Item specific price per charge (#125)
	move.b	Enchantment_charge_price(a1),d0
	bne.s	.Price
	move.w	Total_price,d0		; Otherwise use the enchanter base price
.Price:	move.w	d0,Charge_price
	cmp.w	Current_gold,d0		; Enough money ?
	bls.s	.Enough			; (unsigned)
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Done
; ---------- How many charges ? -------------------
.Enough:	moveq.l	#0,d1			; Calculate maximum
	move.b	Enchantment_charge_max(a1),d1
	sub.b	Charges(a2),d1
	moveq.l	#0,d0			; How many can you buy ?
	move.w	Current_gold,d0
	divu.w	Charge_price,d0		; FIX: Was Total_price (#125)
	cmp.w	d1,d0			; Too much ?
	bmi.s	.Not
	move.w	d1,d0
.Not:	ext.l	d0			; Store
	move.l	d0,Maximum_number
	move.w	#168,InputNr_prompt		; How many do you want ?
	st	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d1		; Any ?
	beq	.Done
; ---------- Sure ? -------------------------------
	move.w	#166,d0
	mulu.w	Charge_price,d1		; FIX: Was Total_price (#125)
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq.s	.Done
	st	Success			; Success !
; ---------- Enchant it ---------------------------
	sub.w	d1,Current_gold		; Remove gold
	move.l	InputNr_number,d0		; Add charges
	add.b	d0,Charges(a2)
	move.w	Selected_item,d0		; Sparkle!
	jsr	Sparkle_object2
	move.b	Enchantment_normal(a2),d0	; Increase counter
	addq.b	#1,d0
	move.b	d0,Enchantment_normal(a2)
	cmp.b	Enchantment_max(a1),d0
	bmi.s	.Done
	move.w	#167,d0			; Last time !
	jsr	Do_prompt
.Done:	Free	Active_handle
.Exit:	jsr	Hide_Lay3_objects		; Hide slots
	jsr	Update_screen
.Exit2:	rts

;*****************************************************************************
; [ Inn place event ]
;*****************************************************************************
Inn_ModInit:
	sf	Room_rented		; Clear flag
	Get	Place_data_handle,a0	; Get price for one room
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	move.w	Inn_price+2(a0,d0.l),d1
	Free	Place_data_handle
	jsr	Count_members		; Calculate total price
	mulu.w	d1,d0
	move.w	d0,Total_price		; Store
	jmp	Places_ModInit

Inn_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	Inn_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

Inn_CIL_evaluate:
	tst.b	Room_rented		; Already rented ?
	beq.s	.Ok
	bset	#7,6(a0)			; Disable {Guestroom}
.Ok:	rts

; ********** Inn - Rent a room ********************
Guestroom:
	move.w	Current_gold,d0		; Enough money ?
	cmp.w	Total_price,d0
	bcc.s	.Ok			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; "Fool !"
	jsr	Do_prompt
	bra	.Exit
.Ok:	move.w	#151,d0			; Are you sure ?
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
	st	Success			; Success !
	move.w	Total_price,d0		; Remove gold
	sub.w	d0,Current_gold
	st	Inn_flag			; Camp
	st	Room_rented
	lea.l	Current_event_data,a5	; Get sold text number
	moveq.l	#0,d0
	move.b	Event_b5(a5),d0
	cmp.b	#-1,d0			; Any ?
	beq	.None
	Get	Maptext_handle,a0		; Yes -> Show
	jsr	Do_text
	Free	Maptext_handle
	bra.s	.Skip
.None:	move.w	#281,d0			; "Have fun !"
	jsr	Do_prompt
.Skip:	jsr	Exit_PLACES		; Do
.Exit:	rts

;*****************************************************************************
; [ Object/Magic merchant place event ]
;*****************************************************************************
MerchOBJC_ModInit:
	lea.l	Current_event_data,a5
	move.w	Event_w8(a5),d0		; Load merchant data
	addq.w	#1,d0			; !!!
	moveq.l	#Merchant_data_file,d1
	jsr	Load_subfile
	move.b	d0,Merchant_data_handle
	jsr	Clear_sold_slots		; Clear slots
	jsr	Load_object_graphics
	jmp	Places_ModInit

MerchOBJC_ModExit:
	lea.l	Current_event_data,a5
	move.w	Event_w8(a5),d0		; Write merchant data back
	addq.w	#1,d0			; !!!
	moveq.l	#Merchant_data_file,d1
	Get	Merchant_data_handle,a0
	jsr	Save_subfile
	move.b	Merchant_data_handle,d0	; Free memory
	jsr	Free_pointer
	jsr	Free_memory
	jsr	Free_object_graphics
	jmp	Places_ModExit

MerchOBJC_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	MerchOBJC_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Reset_sold_scroll_bar	; Initialize scroll bar
	jmp	Places_DisInit

MerchOBJC_CIL_evaluate:
; ---------- Can one view an object ? -------------
	move.b	Merchant_data_handle,d0	; Well ?
	jsr	Check_slots_empty
	bne.s	.Ok1
	bset	#7,(a0)			; Disable {Buy item}
	bset	#7,8(a0)			; Disable {View item}
	bra.s	.Not_MT1
; ---------- Can one buy an object ? --------------
.Ok1:	tst.w	Current_gold		; Any gold ?
	beq.s	.Off1
	move.b	Sold_slots_handle,d0	; Any slots free ?
	jsr	Check_slots_full
	beq.s	.Not_MT1
.Off1:	bset	#7,(a0)			; Disable {Buy item}
; ---------- Can one sell an object ? -------------
.Not_MT1:	cmp.w	#Magic_place,Current_place_type	; Magic ?
	beq.s	.Off2
	jsr	Check_active_backpack	; Anything to sell ?
	bne.s	.Not_MT2
.Off2:	bset	#7,6(a0)			; Disable {Sell item}
.Not_MT2:	rts

; ********** Object merchant - Exit ***************
Exit_MerchOBJC:
	move.b	Sold_slots_handle,d0	; Any stuff left ?
	jsr	Check_slots_empty
	beq.s	.No
	move.w	#162,d0			; Sure ?
	jsr	Prompt_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
.No:	jsr	Exit_PLACES		; Normal exit
.Exit:	rts

; ********** Object merchant - Buy item ***********
Buy_item:
	move.w	#146,ItemSelect_prompt	; Select item
	move.b	Merchant_data_handle,Slotbase_handle
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#Items_per_chest,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Merchant_ItemSelect_Mod
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	Get	Merchant_data_handle,a2	; Get object packet address
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
	move.w	Current_gold,d0		; Affordable ?
	cmp.w	Price(a1),d0
	bcc.s	.Yes			; FIX: Was bpl (gold is unsigned)
	move.w	#150,d0			; "Go away, bum!"
	jsr	Do_prompt
	bra	.Exit
.Yes:	move.l	#1,InputNr_number		; Single
	cmpi.b	#1,Quantity(a2)		; More than one ?
	beq.s	.Ask
	moveq.l	#0,d0			; How many are available ?
	move.b	Quantity(a2),d0
	tst.w	Price(a1)			; For free ?
	beq.s	.Error
	moveq.l	#0,d1			; How many can you buy ?
	move.w	Current_gold,d1
	divu.w	Price(a1),d1
	cmpi.w	#1,d1			; Only one ?
	beq.s	.Ask
	cmpi.w	#100,d1			; Too much ?
	bmi.s	.Not
.Error:	moveq.l	#99,d1
.Not:	cmp.w	d1,d0			; Can you	buy too many ?
	bpl.s	.Ok
	move.w	d0,d1
.Ok:	ext.l	d1			; How many do you want ?
	move.l	d1,Maximum_number
	move.w	Object_index(a2),InputNr_object
	move.w	#147,InputNr_prompt
	sf	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Exit
.Ask:	moveq.l	#0,d1			; Get object price
	move.w	Price(a1),d1
	move.l	InputNr_number,d0		; Calculate total price
	mulu.w	d0,d1
	move.w	d1,Total_price		; Store
	move.w	#148,d0			; Are you sure ?
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
	st	Success			; Success !
	move.w	Total_price,d0		; Take gold
	sub.w	d0,Current_gold
	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	move.l	InputNr_number,d0
	move.b	d0,Quantity(a0)
	move.b	Sold_slots_handle,d0	; Move to sold slots
.Again:	jsr	Auto_move_to_INV
	tst.b	Quantity(a0)		; All moved ?
	bne.s	.Again
	cmp.b	#-1,Quantity(a2)		; Infinite ?
	beq.s	.Exit
	move.w	Selected_item,d2		; Remove items
	addq.w	#1,d2
	move.l	InputNr_number,d3
	jsr	Remove_LAY3_item
.Exit:	Free	Merchant_data_handle
	jsr	Reset_sold_scroll_bar
	jsr	Update_screen
.Exit2:	rts

; ********** Object merchant - Sell item **********
Sell_item:
	clr.w	Scroll_bar_work		; Clear
	move.b	Merchant_data_handle,d0	; Any slots free ?
	jsr	Check_slots_full
	beq.s	.Not_MT
	move.w	#145,d0			; No
	jsr	Do_prompt
	bra	.Exit
.Repeat:	move.b	Merchant_data_handle,d0	; Any slots free ?
	jsr	Check_slots_full
	bne	.Exit
.Not_MT:	move.w	#135,ItemSelect_prompt	; Select item
	move.b	Active_handle,Slotbase_handle
	move.l	#Char_inventory+Backpack_slots,Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#Items_per_char,Total_units(a0)
	move.w	Scroll_bar_work,Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod	; Select
	jsr	Get_scroll_bar		; Store position
	move.w	d0,Scroll_bar_work
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	Get	Active_handle,a2		; Get object packet address
	move.l	a2,a3
	lea.l	Char_inventory+Backpack_slots(a2),a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Broken ?
	beq.s	.Unbroken
	move.w	#210,d0			; "Go away!"
	jsr	Do_prompt
	bra	.Done
.Unbroken:	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
	btst	#Droppable,Item_bits_STATIC(a1)	; Can it be sold ?
	beq.s	.Refuse
	cmpi.w	#Minimum_price,Price(a1)	; Too cheap ?
	bgt.s	.Ok
.Refuse:	move.w	#285,d0			; "Begone!"
	jsr	Do_prompt
	bra	.Done
.Ok:	move.l	#1,InputNr_number		; Single
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple item ?
	beq.s	.Ask
	cmpi.b	#1,Quantity(a2)		; More than one ?
	beq.s	.Ask
	moveq.l	#0,d0			; How much ?
	move.b	Quantity(a2),d0
	move.l	d0,Maximum_number
	move.w	Object_index(a2),InputNr_object
	move.w	#136,InputNr_prompt
	sf	ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	tst.l	InputNr_number		; Any ?
	beq	.Done
.Ask:	moveq.l	#0,d1			; Get object price
	move.w	Price(a1),d1
	divu.w	#3,d1			; Calculate price
	moveq.l	#0,d2
	move.w	ACharisma(a3),d2
	add.w	ACharisma+Magic(a3),d2
	divu.w	#10,d2
	mulu.w	Price(a1),d2
	divu.w	#100,d2
	add.l	d2,d1
	move.l	InputNr_number,d0		; Calculate total price
	mulu.w	d0,d1
	tst.w	d1			; At least 1
	bne.s	.Not_zero
	moveq.l	#1,d1
.Not_zero:	move.w	d1,Total_price		; Store
	move.w	#140,d0			; Are you sure ?
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq.s	.Done
	st	Success			; Success !

;	move.w	Selected_item,d0		; Whee !
;	addq.w	#1,d0
;	move.l	InputNr_number,d1
;	jsr	Show_dropped_items

	move.w	Total_price,d0		; Give gold
	add.w	d0,Current_gold
	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	move.l	InputNr_number,d0
	move.b	d0,Quantity(a0)
	jsr	Auto_move_to_merchant	; Move to merchant
	move.b	Active_handle,d0		; Remove items
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	move.l	InputNr_number,d3
	jsr	Remove_item
.Done:	Free	Active_handle
	jsr	Check_active_backpack	; All gone ?
	bne	.Repeat			; No -> Again
.Exit:	jsr	Reset_sold_scroll_bar
	jsr	Update_screen
.Exit2:	rts

; ********** Object merchant - View item **********
View_item_MOBJC:
	move.b	Merchant_data_handle,Slotbase_handle	; Display scroll bar
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0
	move.w	#Items_per_chest,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	move.w	#149,ItemSelect_prompt	; Select item
	Push	Module,Merchant_ItemSelect_Mod
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	Get	Slotbase_handle,a2		; Get object packet address
	add.l	Slotbase_offset,a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	Free	Slotbase_handle
	Push	Module,ItemView1_Mod	; Show 'em
.Exit:	jsr	Reset_sold_scroll_bar	; Initialize scroll bar
	jmp	Update_screen

;*****************************************************************************
; [ Food merchant place event ]
;*****************************************************************************
MerchFOOD_ModInit:
	Get	Place_data_handle,a0	; Get food price
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	move.w	Food_price+2(a0,d0.l),Total_price
	Free	Place_data_handle
	clr.w	Current_food		; Clear
	jsr	Load_object_graphics
	jsr	Places_ModInit
	jmp	Print_food_price		; Print food price

MerchFOOD_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	MerchFOOD_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

MerchFOOD_DisUpd:
	jsr	Update_food		; Print food
	jmp	Places_DisUpd

MerchFOOD_CIL_evaluate:
	move.w	Current_gold,d0		; Enough dough ?
	cmp.w	Total_price,d0
	bpl.s	.Ok1
	bset	#7,6(a0)			; Disable {Buy food}
.Ok1:	tst.w	Current_food		; Any food bought ?
	bne.s	.Ok2
	bset	#7,8(a0)			; Disable	{Transfer	food}
	bset	#7,10(a0)			; Disable	{Divide food}
.Ok2:	rts

; ********** Food merchant - Exit *****************
Exit_MerchFOOD:
	tst.w	Current_food		; Any food left ?
	beq.s	.No
	move.w	#161,d0			; Sure ?
	jsr	Prompt_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
.No:	jsr	Exit_PLACES		; Normal exit
.Exit:	rts

; ********** Food merchant - Buy food *************
Buy_food:
	moveq.l	#0,d0			; How many can you buy ?
	move.w	Current_gold,d0
	divu.w	Total_price,d0
	cmpi.w	#99,d0			; Too much ?
	bmi.s	.Not
	moveq.l	#99,d0
.Not:	ext.l	d0			; Store
	move.l	d0,Maximum_number
	move.w	#157,InputNr_prompt		; How many do you want ?
	move.b	#2,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d1		; Any ?
	beq	.Exit
	move.w	#158,d0			; Are you sure ?
	mulu.w	Total_price,d1
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq	.Exit
	st	Success			; Success !
	sub.w	d1,Current_gold		; Remove gold
	move.l	InputNr_number,d0		; Add food
	add.w	d0,Current_food
.Exit:	jmp	Print_food_price		; Restore price

; ********** Food merchant - Divide food **********
MerchFOOD_Divide_food:
	move.w	Current_food,d0		; Divide
	jsr	Divide_food
	move.w	d0,Current_food
	beq.s	.Gone			; Anything left ?
	move.w	#159,d0			; Yes
	bra.s	.Do
.Gone:	move.w	#160,d0			; No
.Do:	jsr	Do_prompt
	jmp	Print_food_price		; Restore price

; ********** Food merchant - Transfer food ********
MerchFOOD_Transfer_food:
	moveq.l	#0,d0			; How much ?
	move.w	Current_food,d0
	move.l	d0,Maximum_number
	move.w	#156,InputNr_prompt
	move.b	#2,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d0		; Any ?
	beq	.Exit
	moveq.l	#0,d7			; Anyone interested ?
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
	move.l	InputNr_number,d0		; Remove food
	sub.w	d0,Current_food
	lea.l	Party_handles-1,a1		; Add food
	add.w	Selected_member,a1
	Get	(a1),a0
	move.l	InputNr_number,d0
	add.w	d0,Food_rations(a0)
	mulu.w	#Food_weight,d0
	add.l	d0,Weight_normal(a0)
	Free	(a1)
.Exit:	rts

;*****************************************************************************
; [ Print food price ]
; All registers are restored
;*****************************************************************************
Print_food_price:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	Food_price_text,a1
	lea.l	Number,a0			; Convert number
	move.l	a0,4(a1)
	moveq.l	#0,d0
	move.w	Total_price,d0
	moveq.l	#5,d7
	jsr	DecL_convert
	move.l	a1,a0
	moveq.l	#0,d0
	jsr	Display_text		; Print food price
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Transport merchant place event ]
;*****************************************************************************
MerchTRANS_ModInit:
	Get	Place_data_handle,a0	; Get transport price/type
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	lea.l	2(a0,d0.l),a0
	move.w	Trans_price(a0),d1
	move.w	Newtrans_X(a0),d2
	move.w	Newtrans_Y(a0),d3
	move.w	Newtrans_map_nr(a0),d4
	move.w	Newtrans_type(a0),d5
	Free	Place_data_handle
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
.Next:	addq.w	#Trans_data_size,a0	; Next transport
	dbra	d7,.Loop
	st	Transport_created		; Prohibit !
.Done:	jmp	Places_ModInit

MerchTRANS_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	MerchTRANS_icon_table,a0	; Get control icon number
	add.w	Current_place_type,a0
	moveq.l	#0,d0
	move.b	(a0),d0
	lea.l	MerchTRANS_CIL,a0		; Show control icons
	move.w	d0,6(a0)			; (Insert)
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

MerchTRANS_CIL_evaluate:
	tst.b	Transport_created		; Already full ?
	bne.s	.Off
	move.w	Current_gold,d0		; Enough dough ?
	cmp.w	Total_price,d0
	bpl.s	.Ok
.Off:	bset	#7,6(a0)			; Disable {Buy transport}
.Ok:	rts

Buy_transport:
	lea.l	MerchTRANS_prompt_table,a0	; Get control icon number
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
	beq	.None
	Get	Maptext_handle,a0		; Yes -> Show
	jsr	Do_text
	Free	Maptext_handle
.None:	Get	Place_data_handle,a0	; Get transport data
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	lea.l	2(a0,d0.l),a0
	move.w	Newtrans_X(a0),d0
	move.w	Newtrans_Y(a0),d1
	move.w	Newtrans_map_nr(a0),d2
	move.w	Newtrans_type(a0),d3
	Free	Place_data_handle
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
.Exit:	rts

;*****************************************************************************
; [ Blacksmith place event ]
;*****************************************************************************
Blacksmith_ModInit:
	Get	Place_data_handle,a0	; Get repair price
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_data_size,d0
	move.w	Blacksmith_price+2(a0,d0.l),Total_price
	Free	Place_data_handle
	jsr	Load_object_graphics
	jmp	Places_ModInit

Blacksmith_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	lea.l	Blacksmith_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Places_DisInit

; ********** Blacksmith - Repair item *************
Repair_item:
; ---------- Which item ? -------------------------
	move.w	#209,ItemSelect_prompt	; Select item
	move.b	Active_handle,Slotbase_handle
	move.l	#Char_inventory+Backpack_slots,Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#Items_per_char,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod
	Pop	Scroll_bar
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit2
; ---------- Item ? What item ? -------------------
	Get	Active_handle,a2		; Get object packet address
	lea.l	Char_inventory+Backpack_slots(a2),a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
; ---------- Is broken ? --------------------------
	btst	#Broken_item,Item_bits_DYNAMIC(a2)
	bne.s	.Ok1
	move.w	#274,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit
; ---------- Enough money ? -----------------------
.Ok1:	move.w	Price(a1),d1		; Calculate price
	mulu.w	Total_price,d1
	divu.w	#100,d1
	tst.w	d1			; At least one
	bne.s	.Notzero
	moveq.l	#1,d1
.Notzero:	cmp.w	Current_gold,d1		; Enough ?
	bls.s	.Ok2
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Exit
; ---------- Are you sure ? -----------------------
.Ok2:	move.w	#275,d0			; Ask
	jsr	BuySell_req
	tst.b	d0			; Yes ?
	beq.s	.Exit
	st	Success			; Success !
; ---------- Do it --------------------------------
	sub.w	d1,Current_gold		; Remove gold
	move.w	Selected_item,d0		; Sparkle!
	jsr	Sparkle_object2
	bclr	#Broken_item,Item_bits_DYNAMIC(a2)	; Repaired !
	jsr	Sparkle_object2
.Exit:	Free	Active_handle
.Exit2:	jsr	Hide_Lay3_objects		; Hide slots
	jmp	Update_screen

;***************************************************************************	
; [ Buy / sell requester ]
;   IN : d0 - Prompt number (.w)
;        d1 - Amount of gold (.w)
;  OUT : d0 - Requester result (.b)
; Changed registers : d0
;***************************************************************************
BuySell_req:
	movem.l	d1-d3/d7/a0/a1,-(sp)
	move.l	Prompts_ptr,a0		; Find prompt text
	jsr	Find_large_text
	lea.l	BuySell_req_text,a1
	move.l	a0,(a1)
	lea.l	Number,a0			; Convert number
	move.l	a0,4(a1)
	moveq.l	#0,d0
	move.w	d1,d0
	moveq.l	#5,d7
	jsr	DecL_convert
	move.l	a1,a0
	moveq.l	#0,d0
	jsr	Display_text
	move.w	#BSReq_X-1,d0		; Draw box around icons
	move.w	#BSReq_Y-1,d1
	move.w	#64,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	move.w	#BSReq_X,d0		; Display YES icon
	move.w	#BSReq_Y,d1
	move.b	#Yes_cicon,d3
	jsr	Display_up_button
	addi.w	#32,d0			; Display NO icon
	move.b	#No_cicon,d3
	jsr	Display_up_button
	jsr	Update_screen
	sf	BSReq_result		; Clear
	Push	Tree,BSReq_L1		; Do
	Push	Module,BSReq_Mod
	Pop	Tree
	jsr	Erase_PA			; Remove
	jsr	Update_screen
	move.b	BSReq_result,d0		; Output
	movem.l	(sp)+,d1-d3/d7/a0/a1
	rts

BSReq_Yes:	move.w	#BSReq_X,d0		; Feedback
	move.w	#BSReq_Y,d1
	move.b	#Yes_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	Pop	Module			; Exit
	st	BSReq_result		; Positive
.Exit:	rts

BSReq_No:	move.w	#BSReq_X+32,d0		; Feedback
	move.w	#BSReq_Y,d1
	move.b	#No_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ Automatically distribute items in merchant file ]
;   IN : a0 - Pointer to source packet (.l)
; All registers are restored
;  - This routine does NOT redraw anything ! It is intended as a general,
;    safe method of adding items.
;  - This routine will remove items from the source packet, and destroy
;    the source packet if the quantity reaches zero.
;  - The main difference with [ Auto_move_to_chest ] is that a merchant can
;    have ANY item as multiples.
;*****************************************************************************
Auto_move_to_merchant:
	movem.l	d0-d3/d7/a1-a4,-(sp)
	move.l	a0,a2
	Get	Merchant_data_handle,a3	; Get target inventory
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
; ---------- Scan for slots with this item --------
	move.l	a3,a4			; Get chest slots
	move.w	Object_index(a2),d2
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	moveq.l	#Items_per_chest-1,d7
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
.Next1:	addq.w	#Object_packet_size,a4	; Next packet
	dbra	d7,.Loop1
	move.l	a3,a4			; Get chest slots
	moveq.l	#Items_per_chest-1,d7
.Loop2:	tst.w	Object_index(a4)		; Free slot ?
	beq.s	.Do_it1
	addq.w	#Object_packet_size,a4	; Next packet
	dbra	d7,.Loop2
	bra.s	.Exit			; (shouldn't occur)
.Do_it1:	Copy_packet a2,a4			; Copy packet
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	clr.b	Quantity(a4)
.End:	sub.b	d3,Quantity(a2)		; Transfer
	add.b	d3,Quantity(a4)
.Exit:	tst.b	Quantity(a2)		; All gone ?
	bgt.s	.Skip
	clr.w	Object_index(a2)		; Yes -> destroy item
.Skip:	Free	Merchant_data_handle
	movem.l	(sp)+,d0-d3/d7/a1-a4
	rts

;*****************************************************************************
; [ Create merchant item name & price ]
; No registers are restored
;*****************************************************************************
Merchant_item_touched:
	tst.b	d0			; Any selected ?
	beq	.No_slot
	cmp.b	#-1,d0			; Scroll bar ?
	beq	.No_slot
	andi.w	#$00ff,d0			; Get real slot number
	subq.w	#1,d0
	add.w	Scroll_bar_result,d0
	cmp.w	Current_ghost_index,d0	; Already being shown ?
	bne.s	.New
; ---------- Update current position --------------
	jsr	Set_ghost_positions
	bra	.Exit
; ---------- See if the slot was actually filled --
.New:	move.w	d0,d1			; Save for later
	mulu.w	#Object_packet_size,d0	; Get packet address
	Get	Slotbase_handle,a2
	add.l	Slotbase_offset,a2
	move.w	Object_index(a2,d0.l),d0	; Get object index
	Free	Slotbase_handle
; ---------- Destroy old object name (if any) -----
	jsr	Destroy_ghosts
; ---------- Initialize the new object name -------
	tst.w	d0			; Anything there ?
	beq	.Exit
	move.w	d1,Current_ghost_index	; Store
	jsr	Create_object_name
	jsr	Create_object_price
	bra	.Exit
; ---------- Destroy current name (if any) --------
.No_slot:	jsr	Destroy_ghosts
.Exit:	rts

;***************************************************************************
; [ Create object price ]
;   IN : d0 - Object index (.w)
; All registers are restored
;***************************************************************************
Create_object_price:
	movem.l	d0/d7/a0/a1,-(sp)
	subq.w	#1,d0			; Get object data address
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a1
	add.l	d0,a1
	moveq.l	#0,d0			; Get price
	move.w	Price(a1),d0
	cmp.w	Current_gold,d0		; Affordable ?
	bls.s	.Yes
	move.w	#Red,Ink_colour		; No -> Red
	bra.s	.Go_on
.Yes:	move.w	#White,Ink_colour		; Yes -> White
.Go_on:	lea.l	Number,a0			; Convert price
	moveq.l	#5,d7
	jsr	DecL_convert
	lea.l	Number,a0			; Create ghost string
	jsr	Create_2nd_ghost
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
; *** BUY/SELL REQUESTER : 1st layer ***
BSReq_L1:	dc.w BSReq_X,BSReq_Y
	dc.w 0,31,0,16
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 32,63,0,16
	dc.b 2
	even
	dc.l 0,0

Place_pictures:
; *** Lyramion ***
	dc.b 0,Healer_pic,Sage_pic,Enchantress_pic
	dc.b Inn_pic,Object_merchant_pic,Object_merchant_pic,Librarian_pic
	dc.b Ship_merchant_pic,Ship_merchant_pic,Horse_merchant_pic
	dc.b Sage_pic
; *** Forest moon ***
	dc.b 0,Healer_pic
	dcb.b 10,Forest_merchant_pic
; *** Desert moon ***
	dc.b 0
	dcb.b 11,Desert_merchant_pic

Trainer_pictures:
	dc.b Warrior_trainer_pic		; Attack
	dc.b Warrior_trainer_pic		; Parade
	dc.b Warrior_trainer_pic		; Swimming
	dc.b Warrior_trainer_pic		; Critical hit
	dc.b Thief_trainer_pic		; Find traps
	dc.b Thief_trainer_pic		; Disarm traps
	dc.b Thief_trainer_pic		; Pick locks
	dc.b Thief_trainer_pic		; Searching
	dc.b Magic_trainer_pic		; Read scrolls
	dc.b Magic_trainer_pic		; Use magic
	even

Place_enter_texts:
	dc.w 123,124,125
	dc.w 126,127,128,129
	dc.w 130,131,132,208
Trainer_enter_texts:
	dc.w 183,184,185,122,186
	dc.w 187,188,189,190,191

Trainer_CIL:
	dc.w 0,0,Exit_cicon
	dc.w Train_skill_cicon,0,0
	dc.w 0,0,0
	dc.l 0,0,Exit_PLACES
	dc.l Train_skill,0,0
	dc.l 0,0,0
	dc.l Trainer_CIL_evaluate
Healer_CIL:
	dc.w Heal_LP_cicon,0,Exit_cicon
	dc.w Heal_cursed_items_cicon,0,0
	dc.w Heal_condition_cicon,0,0
	dc.l Heal_LP,0,Exit_PLACES
	dc.l Heal_cursed_items,0,0
	dc.l Heal_condition,0,0
	dc.l Healer_CIL_evaluate
Sage_CIL:
	dc.w Body_items_cicon,0,Exit_cicon
	dc.w Backpack_cicon,0,0
	dc.w 0,0,0
	dc.l Examine_body_item,0,Exit_PLACES
	dc.l Examine_backpack_item,0,0
	dc.l 0,0,0
	dc.l 0
Enchanter_CIL:
	dc.w 0,0,Exit_cicon
	dc.w Enchant_item_cicon,0,0
	dc.w 0,0,0
	dc.l 0,0,Exit_PLACES
	dc.l Enchant_item,0,0
	dc.l 0,0,0
	dc.l 0
Inn_CIL:
	dc.w 0,0,Exit_cicon
	dc.w Camp_cicon,0,0
	dc.w 0,0,0
	dc.l 0,0,Exit_PLACES
	dc.l Guestroom,0,0
	dc.l 0,0,0
	dc.l Inn_CIL_evaluate
MerchOBJC_CIL:
	dc.w Buy_item_cicon,0,Exit_cicon
	dc.w Sell_item_cicon,View_item_cicon,0
	dc.w 0,0,0
	dc.l Buy_item,0,Exit_MerchOBJC
	dc.l Sell_item,View_item_MOBJC,0
	dc.l 0,0,0
	dc.l MerchOBJC_CIL_evaluate
MerchFOOD_CIL:
	dc.w 0,0,Exit_cicon
	dc.w Buy_food_cicon,Divide_food_cicon,Transfer_food_cicon
	dc.w 0,0,0
	dc.l 0,0,Exit_MerchFOOD
	dc.l Buy_food,MerchFOOD_Divide_food,MerchFOOD_Transfer_food
	dc.l 0,0,0
	dc.l MerchFOOD_CIL_evaluate
MerchTRANS_CIL:
	dc.w 0,0,Exit_cicon
	dc.w 0,0,0			; Icon will be inserted
	dc.w 0,0,0
	dc.l 0,0,Exit_PLACES
	dc.l Buy_transport,0,0
	dc.l 0,0,0
	dc.l MerchTRANS_CIL_evaluate
Blacksmith_CIL:
	dc.w 0,0,Exit_cicon
	dc.w Repair_item_cicon,0,0
	dc.w 0,0,0
	dc.l 0,0,Exit_PLACES
	dc.l Repair_item,0,0
	dc.l 0,0,0
	dc.l 0

MerchTRANS_icon_table:
	dc.b 0,0,0,0			; CIL buy transport icons
	dc.b 0,0,0,0
	dc.b Buy_raft_cicon,Buy_ship_cicon,Buy_horse_cicon,0
	dc.b 0,0,0,0
MerchTRANS_prompt_table:
	dc.b 0,0,0,0			; Buy selector prompt numbers
	dc.b 0,0,0,0
	dc.b 152,153,154,0
	dc.b 0,0,0,0
Healer_condition_table:
	dc.b -1,Mad_price,-1,-1		; Healer price offsets
	dc.b Blind_price,Stoned_price,-1,-1
	dc.b Lamed_price,Poisoned_price,Petrified_price,Diseased_price
	dc.b Aging_price,Dead_price,Ashes_price,Dust_price
