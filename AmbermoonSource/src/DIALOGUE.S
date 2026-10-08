; Dialogue screen
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
; [ Dialogue module ]
;*****************************************************************************
Dialogue_ModInit:
	sf	Joined			; Clear
	sf	Left
	sf	Abort_dialogue
	sf	Dialogue_items		; FIX: Not cleared before. When a dialogue was
					; left with items in the slots ({Exit}, "Yes"),
					; the flag stayed set. In the next dialogue the
					; slots are empty, so Dialogue_DisUpd "hid" the
					; items and popped the new dialogue module and
					; a wrong scroll bar -> graphics mess / crash.
					; (Github issue #74)
	jsr	Clear_new_words_array
	jsr	Clear_sold_slots
	tst.b	NPC_or_member		; Dialogue with party member ?
	bne	.Skip
	Get	Dialogue_handle,a0		; Load dialogue portrait
	moveq.l	#0,d0
	move.b	Portrait_nr(a0),d0
	Free	Dialogue_handle
	moveq.l	#Portraits_file,d1
	jsr	Load_unique_subfile
	move.b	d0,Dialogue_portrait_handle
.Skip:	moveq.l	#Dictionary_file,d0		; Load dictionary
	jsr	Load_file
	move.b	d0,Dictionary_handle
	jsr	Load_object_graphics
	jsr	Dialogue_DisInit		; Build screen
	moveq.l	#Init_DIAC,d0		; Start
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	tst.b	NPC_or_member		; Member ?
	bne.s	.Member
	move.w	#117,d0			; Yo!
	bra.s	.Do
.Member:	move.w	#119,d0			; OK
.Do:	jsr	Do_prompt
.Exit:	rts

Dialogue_ModExit:
	move.b	Dictionary_handle,d0	; Free memory
	jsr	Free_memory
	jsr	Free_object_graphics
	tst.b	NPC_or_member		; Dialogue with party member ?
	bne.s	.Skip
	tst.b	Joined			; Yes -> Joined ?
	bne.s	.Skip
	move.b	Dialogue_portrait_handle,d0	; No -> Free memory
	jsr	Kill_memory
	move.b	Dialogue_handle,d0
	jsr	Free_memory
.Skip:	move.b	Dialogue_text_handle,d0
	jsr	Free_memory
	jmp	Fade_out_bottom

Dialogue_DisInit:
	jsr	Build_dialogue_screen
	jmp	Fade_in_bottom

Dialogue2_DisInit:
	jsr	Build_dialogue_screen
	jsr	Show_dialogue_items
	jmp	Fade_in_bottom

Dialogue_DisUpd:
	Get	Active_handle,a0
	move.w	Gold_coins(a0),Current_gold	; Update gold & food
	move.w	Food_rations(a0),Current_food
	move.w	#16,Ink_colour		; Set ink
	move.w	#208,d0			; Erase active name
	move.w	#99,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#96-1,d2
	addq.w	#6-1,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	move.w	#96,d2			; Print active name
	lea.l	Char_name(a0),a0
	jsr	Print_centered_string
	Free	Active_handle
	jsr	Update_gold		; Display gold & food
	jsr	Update_food
; ---------- Check if items should be shown -------
.Ok1:	move.b	Sold_slots_handle,d0	; Slots empty ?
	jsr	Check_slots_empty
	beq.s	.Empty
	tst.b	Dialogue_items		; No -> Scroll bar shown ?
	bne.s	.Done
	st	Dialogue_items		; Show
	jsr	Show_dialogue_items
	Push	Module,Dialogue2_Mod
	jsr	Update_screen
	bra.s	.Done
.Empty:	tst.b	Dialogue_items		; Yes -> Scroll bar hidden ?
	beq.s	.Done
	sf	Dialogue_items		; Hide
	Pop	Module
	jsr	Hide_dialogue_items
	jsr	Update_screen
.Done:	jmp	Basic_DisUpd		; The usual

Dialogue_CIL_evaluate:
; ---------- Any slots filled ? -------------------
	move.b	Sold_slots_handle,d0	; Well ?
	jsr	Check_slots_empty
	beq.s	.Ok2
	bset	#7,8(a0)			; Disable {Leave party}
; ---------- Any stuff in backpack ? --------------
.Ok2:	jsr	Check_active_backpack	; Well ?
	bne.s	.Ok3
	bset	#7,6(a0)			; Disable {Show item}
	bset	#7,12(a0)			; Disable {Give item}
; ---------- Any gold ? ---------------------------
.Ok3:	Get	Active_handle,a1
	tst.w	Gold_coins(a1)		; Well ?
	bne.s	.Ok4
	bset	#7,14(a0)			; Disable {Give gold}
; ---------- Any food ? ---------------------------
.Ok4:	tst.w	Food_rations(a1)		; Well ?
	bne.s	.Ok5
	bset	#7,16(a0)			; Disable {Give food}
; ---------- Can join ? ---------------------------
.Ok5:	Free	Active_handle
	tst.b	Joined			; Already joined ?
	bne.s	.Off5
	tst.b	NPC_or_member		; In party ?
	beq.s	.Ok6
.Off5:	bset	#7,10(a0)			; Disable {Join party}
; ---------- Can leave ? --------------------------
.Ok6:	tst.b	Left			; Already left ?
	bne.s	.Off6
	tst.b	NPC_or_member		; In party ?
	bne.s	.Ok7
.Off6:	bset	#7,8(a0)			; Disable {Leave party}
.Ok7:	rts

; ********** Dialogue - Exit **********************
DIA_Exit:
	move.b	Sold_slots_handle,d0	; Anything important left ?
	moveq.l	#Items_per_char,d7
	jsr	Check_for_vital_items
	bne.s	.Exit2
	tst.b	Dialogue_items		; Items shown ?
	beq.s	.Skip
	move.w	#287,d0			; Yes -> Really leave ?
	jsr	Prompt_req
	tst.b	d0
	beq.s	.Exit2
	Pop	Module			; Yes
	jsr	Destroy_ghosts
	Pop	Scroll_bar
.Skip:	tst.b	Left			; Insulted ?
	bne.s	.Exit
	moveq.l	#Exit_DIAC,d0		; The end
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	tst.b	NPC_or_member		; Member ?
	bne.s	.Exit
	move.w	#118,d0			; Goodbye !
	jsr	Do_prompt
.Exit:	Pop	Module			; Exit
	jsr	Init_display
.Exit2:	rts

; ********** Dialogue - Ask a word ****************
DIA_Ask_word:
	jsr	Destroy_ghosts		; Destroy !
	Push	Module,WSelW_Mod		; Select a word
	jsr	Reset_dialogue_scroll_bar
	jsr	Update_screen
	tst.b	No_word_selected		; Any word entered ?
	bne	.Exit
	move.w	Selected_word,d1		; Get word
	cmp.w	#-1,d1			; In dictionary ?
	bne.s	.Yes
	moveq.l	#0,d0			; Huh ?
	jsr	Do_prompt
	bra.s	.Exit
.Yes:	moveq.l	#Ask_word_DIAC,d0		; Try
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	move.w	#107,d0			; What ?
	jsr	Do_prompt
.Exit:	rts

; ********** Dialogue - Show item *****************
DIA_Show_item:
	jsr	Destroy_ghosts		; Destroy !
	move.w	#108,ItemSelect_prompt	; Select item
	move.b	Active_handle,Slotbase_handle
	move.l	#Char_inventory+Backpack_slots,Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#Items_per_char,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	move.w	d0,d2			; Yes -> Move
	addq.w	#1,d2
	jsr	Move_item_to_portrait
	move.w	d0,d1			; Try
	moveq.l	#Show_item_DIAC,d0
	jsr	DIA_event_handler
	bmi.s	.No			; Anything ?
	tst.b	Abort_dialogue		; Yes -> Aborting ?
	beq.s	.Done
	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	bra.s	.Exit2
.No:	move.w	#114,d0			; Uh-buh !
	jsr	Do_prompt
.Done:	jsr	Move_item_back_to_slot	; Move back
.Exit:	Pop	Scroll_bar
	jsr	Reset_dialogue_scroll_bar
	jsr	Update_screen
.Exit2:	rts

; ********** Dialogue - Give item *****************
DIA_Give_item:
	jsr	Destroy_ghosts		; Destroy !
	move.w	#109,ItemSelect_prompt	; Select item
	move.b	Active_handle,Slotbase_handle
	move.l	#Char_inventory+Backpack_slots,Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0		; Display scroll bar
	move.w	#Items_per_char,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	Push	Module,Lay3_ItemSelect_Mod
	move.w	Selected_item,d0		; Anything selected ?
	bmi	.Exit
	move.w	d0,d2			; Yes -> Move
	addq.w	#1,d2
	jsr	Move_item_to_portrait
	move.w	d0,d1			; Save slot number
	sf	Item_accepted		; Clear
	moveq.l	#Give_item_DIAC,d0		; Try
	jsr	DIA_event_handler
	bmi.s	.No			; Anything ?
	tst.b	Abort_dialogue		; Yes -> Aborting ?
	beq.s	.Done
	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	bra.s	.Exit2
.No:	move.w	#114,d0			; Uh-buh !
	jsr	Do_prompt
	bra.s	.Return
.Done:	tst.b	Item_accepted		; Removed ?
	bne.s	.Exit
.Return:	jsr	Move_item_back_to_slot	; No -> Move back
.Exit:	Pop	Scroll_bar
	jsr	Reset_dialogue_scroll_bar
	jsr	Update_screen
.Exit2:	rts

; ********** Dialogue - Leave party ***************
DIA_Leave_party:
	Get	Dialogue_handle,a0		; Get conditions
	move.w	Body_conditions(a0),d0
	Free	Dialogue_handle
	move.w	#Alive_mask,d1		; Alive and kicking ?
	and.w	d0,d1
	beq.s	.Alive
	moveq.l	#98,d0			; Yes -> "No stiffs..."
	jsr	Do_prompt
	bra	.Exit
.Alive:	btst	#Mad,d0			; Bonkers ?
	beq	.Sane
	moveq.l	#99,d0			; Yes -> "No loonies..."
	jsr	Do_prompt
	bra	.Exit
.Sane:	btst	#Petrified,d0		; Petrified ?
	beq.s	.Ok
	moveq.l	#100,d0			; Yes -> "No petrified..."
	jsr	Do_prompt
	bra	.Exit
.Ok:	tst.w	Current_world_nr		; On Lyramion ?
	beq.s	.Lyramion
	moveq.l	#97,d0			; No -> "No way!"
	jsr	Do_prompt
	bra	.Exit
.Lyramion:	moveq.l	#Leave_party_DIAC,d0	; Try
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	moveq.l	#116,d0			; No -> Kick out anyway
	jsr	Do_prompt
	move.w	Dialogue_NPC_index,d7
	jsr	Remove_party_member
	st	Left			; Indicate
	jsr	DIA_Exit			; Leave dialogue
.Exit:	rts

; ********** Dialogue - Join party ****************
DIA_Join_party:
	cmpi.w	#6,Nr_members		; Party full ?
	bmi.s	.No
	move.w	#121,d0			; Yes !
	jsr	Do_prompt
	bra	.Exit
.No:	Get	Dialogue_handle,a0		; Is party ?
	move.b	(a0),d0
	Free	Dialogue_handle
	tst.b	d0
	beq.s	.Party
	move.w	#115,d0			; No -> Hah !
	jsr	Do_prompt
	bra.s	.Exit
.Party:	moveq.l	#Join_party_DIAC,d0		; Yes -> Try
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	st	Joined			; No -> Join anyway
	jsr	Add_party_member
.Exit:	rts

; ********** Dialogue - Give gold *****************
DIA_Give_gold:
	jsr	Destroy_ghosts		; Destroy !
	Get	Active_handle,a0		; How much ?
	moveq.l	#0,d0
	move.w	Gold_coins(a0),d0
	move.l	d0,Maximum_number
	Free	Active_handle
	move.w	#110,InputNr_prompt
	move.b	#1,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d1		; Any ?
	beq	.Exit
	sf	Not_enough		; Yes
	moveq.l	#Give_gold_DIAC,d0		; Try
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	tst.b	Not_enough		; Yes -> But not enough ?
	bne.s	.Exit
	move.w	#112,d0			; Hah !
	jsr	Do_prompt
.Exit:	rts

; ********** Dialogue - Give food *****************
DIA_Give_food:
	jsr	Destroy_ghosts		; Destroy !
	Get	Active_handle,a0		; How much ?
	moveq.l	#0,d0
	move.w	Food_rations(a0),d0
	move.l	d0,Maximum_number
	Free	Active_handle
	move.w	#111,InputNr_prompt
	move.b	#2,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d1		; Any ?
	beq	.Exit
	sf	Not_enough		; Yes
	moveq.l	#Give_food_DIAC,d0		; Try
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	tst.b	Not_enough		; Yes -> But not enough ?
	bne.s	.Exit
	move.w	#113,d0			; Hah !
	jsr	Do_prompt
.Exit:	rts

;*****************************************************************************
; [ Get character dialogue offset ]
;   IN : a0 - Pointer to character data (.l)
;  OUT : d0 - Offset to dialogue (.l)
; Changed registers : d0
;*****************************************************************************
Get_dialogue_offset:
 	move.l	a1,-(sp)
	lea.l	Dialogue_offsets,a1
	moveq.l	#0,d0
	move.b	Char_type(a0),d0
	lsl.w	#2,d0
	move.l	0(a1,d0.w),d0
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Move an item to the portrait in a dialogue ]
;   IN : d2 - Slot number {1...24} (.w)
; All registers are restored
;*****************************************************************************
Move_item_to_portrait:
	movem.l	d0-d4/a0,-(sp)
	move.w	d2,Moved_slot		; Save input
	movea.l	Object_pos_list,a0		; Get slot coordinates
	move.w	d2,d0
	sub.w	Scroll_bar_result,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a0
	move.w	(a0),Slot_X
	move.w	2(a0),Slot_Y
	Get	Active_handle,a0		; Get object packet address
	lea.l	Char_inventory+Backpack_slots(a0),a0
	move.w	d2,d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	move.w	Object_index(a0),d0		; Get object index
	Free	Active_handle
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
	move.w	Slot_X,d0			; Erase slot
	move.w	Slot_Y,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	jsr	Add_HDOB			; Start
	jsr	Update_screen
	move.w	#208+8,d0			; Move item to portrait
	move.w	#43+30,d1
	moveq.l	#8,d2
	jsr	Move_HDOB
	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Dissolve the item at the portrait in a dialogue ]
; All registers are restored
; Notes :
;   - This routine must be called after [ Move_item_to_portrait ].
;*****************************************************************************
Dissolve_item_at_portrait:
	movem.l	d0/d1/a0/a1,-(sp)
	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	lea.l	Dissolve_HDOB,a1
	move.w	HDOB_drawX(a0),HDOB_drawX(a1)
	move.w	HDOB_drawY(a0),HDOB_drawY(a1)
	jsr	Remove_HDOB
	move.l	a1,a0			; Create HDOB
	jsr	Add_HDOB
	moveq.l	#11,d0			; Poof !
	moveq.l	#3,d1
	lea.l	Dissolve,a0
	jsr	Animate_HDOB
	lea.l	Dissolve_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	jsr	Update_screen
	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Move the item back to it's slot in a dialogue ]
; All registers are restored
; Notes :
;   - This routine must be called after [ Move_item_to_portrait ].
;*****************************************************************************
Move_item_back_to_slot:
	movem.l	d0-d2/a0,-(sp)
	lea.l	Move_key_HDOB,a0		; Move key back to slot
	move.w	Slot_X,d0
	move.w	Slot_Y,d1
	moveq.l	#10,d2			;  (quickly !)
	jsr	Move_HDOB
	jsr	Remove_HDOB		; Destroy HDOB
	jsr	Update_screen
	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Add party member ]
; All registers are	restored
; Notes :
;   - Since this can only happen in a dialogue, the required data are read
;     DIRECTLY from the dialogue variables !
;*****************************************************************************
Add_party_member:
	movem.l	d0-d2/d6/d7/a0,-(sp)
	lea.l	Party_handles,a0		; Find free slot
	moveq.l	#1,d6
	moveq.l	#6-1,d7
.Loop1:	tst.b	(a0)+
	beq.s	.Found1
	addq.w	#1,d6
	dbra	d7,.Loop1
	bra	.Exit			; All full !
.Found1:	move.b	Dialogue_handle,-1(a0)	; Insert character
	move.w	Map_nr,d0			; Calculate CD value
	subq.w	#1,d0
	mulu.w	#Max_chars,d0
	add.w	Dialogue_NPC_index,d0
	Get	Dialogue_handle,a0		; Already has CD value ?
	move.w	Person_save_bit_pos(a0),d1
	cmp.w	#-1,d1
	bne.s	.Yes
	move.w	d0,Person_save_bit_pos(a0)	; No -> Store
.Yes:	Free	Dialogue_handle
	moveq.l	#CD_bit_array,d1		; Set bit in CD array
	moveq.l	#1,d2
	jsr	Access_bit_array
	jsr	Get_CD_value		; Reset
	move.w	d6,Dialogue_NPC_index	; Set
	st	NPC_or_member
	lea.l	Member_nrs,a0		; Insert in party data
	move.w	d6,d0
	add.w	d0,d0
	move.w	Dialogue_char_nr,-2(a0,d0.w)
	lea.l	Portrait_handles,a0		; Insert portrait handle
	move.b	Dialogue_portrait_handle,-1(a0,d6.w)
	addq.w	#1,Nr_members		; Count up
	lea.l	Order,a0			; Build list of occupied
	moveq.l	#0,d0			;  battle order slots
	moveq.l	#6-1,d7
.Loop2:	move.b	(a0)+,d1
	bset	d1,d0
	dbra	d7,.Loop2
	moveq.l	#12-1,d7			; Seek free slot in	battle
.Loop3:	btst	d7,d0			;  order
	beq.s	.Found2
	dbra	d7,.Loop3
.Found2:	lea.l	Order,a0			; Give character position in
	move.b	d7,-1(a0,d6.w)		;  battle order
	move.w	d6,d7			; Show
	jsr	Show_arrival
	jsr	Force_status_update		; Update
	jsr	Update_status_block
	jsr	Update_screen
.Exit:	movem.l	(sp)+,d0-d2/d6/d7/a0
	rts

;*****************************************************************************
; [ Show party member's arrival ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Show_arrival:
	movem.l	d0-d7/a0/a1/a5,-(sp)
	subq.w	#Death_LDS,sp		; Create local variables
	move.l	sp,a5
; ---------- Prepare ------------------------------
	move.w	d7,d0			; Calculate X-coordinate
	subq.w	#1,d0
	mulu.w	#48,d0
	addi.w	#16,d0
	move.w	d0,KillX(a5)		; Store
	lea.l	Kill_CA,a0		; Install clip area
	move.w	d0,CA_X1(a0)
	move.w	#1,CA_Y1(a0)
	move.w	d0,CA_X2(a0)
	add.w	#32-1,CA_X2(a0)
	move.w	#1+34-1,CA_Y2(a0)
	jsr	Push_CA
	move.w	#1,SkullY(a5)		; Set Y-coordinate
	lea.l	Party_handles,a0		; Duplicate first five
	move.b	-1(a0,d7.w),d1		;  letters of member's name
	Get	d1,a0
	lea.l	Char_name(a0),a0
	lea.l	Temp_name,a1
	moveq.l	#5-1,d0
.Loop:	move.b	(a0)+,(a1)+
	dbeq	d0,.Loop
	Free	d1
	Push	PA,Status_PA		; Set PA & ink
	move.w	#20,Ink_colour
	lea.l	Portrait_handles,a0		; Get portrait address
	move.b	-1(a0,d7.w),d0
	move.b	d0,Kill_handle(a5)
	jsr	Claim_pointer
	move.l	d0,a1
	jsr	Update_screen
; ---------- Do --------------------------------------
	moveq.l	#30,d2
	moveq.l	#2,d6
	moveq.l	#34,d7
.Again:	move.w	KillX(a5),d0		; Display portrait
	moveq.l	#1,d1
	moveq.l	#5,d5
	move.l	a1,a0
	jsr	Put_unmasked_block
	addq.w	#2,d0			; Display	character	name
	moveq.l	#31,d1
	lea.l	Temp_name,a0
	jsr	Print_centered_string
	subq.w	#2,d0			; Display empty portrait
	move.w	SkullY(a5),d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	lea.l	Empty_portrait,a0
	jsr	Put_unmasked_block
	jsr	Switch_screens		; Show
	addq.w	#1,SkullY(a5)		; Move down
	cmp.w	#35+2,SkullY(a5)		; Done ?
	blt.s	.Again
; ---------- End ----------------------------------
	jsr	Update_screen		; Update
	move.b	Kill_handle(a5),d0		; End
	jsr	Free_pointer
	Pop	PA
	Pop	CA
	addq.w	#Death_LDS,sp		; Destroy local variables
	movem.l	(sp)+,d0-d7/a0/a1/a5
	rts

;*****************************************************************************
; [ Reset dialogue scroll bar ]
; All registers are restored
;*****************************************************************************
Reset_dialogue_scroll_bar:
	tst.b	Dialogue_items		; Any items ?
	bne.s	.Show
	jsr	Hide_Lay3_objects		; No
	bra.s	.Exit
.Show:	jsr	Reset_sold_scroll_bar	; Yes
.Exit:	rts

;*****************************************************************************
; [ Show dialogue items ]
; All registers are restored
;*****************************************************************************
Show_dialogue_items:
	move.l	a0,-(sp)
	move.b	Sold_slots_handle,Slotbase_handle	; Reset scrollbar
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0
	move.w	#Items_per_char,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Hide dialogue items ]
; All registers are restored
;*****************************************************************************
Hide_dialogue_items:
	jsr	Destroy_ghosts		; Destroy !
	Pop	Scroll_bar
	jmp	Hide_Lay3_objects

;*****************************************************************************
; [ Build dialogue screen ]
; All registers are restored
;*****************************************************************************
Build_dialogue_screen:
	moveq.l	#Dialogue_layout,d0		; Show new layout
	jsr	Show_layout
	move.w	#208,Gold_X		; Set gold & food positions
	move.w	#106,Gold_Y
	move.w	#256,Food_X
	move.w	#106,Food_Y
	lea.l	Dialogue_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide
; ---------- Display portrait ---------------------
	move.w	#208,d0			; Display portrait
	move.w	#43,d1
	moveq.l	#5,d5
	moveq.l	#2,d6
	moveq.l	#34,d7
	Get	Dialogue_portrait_handle,a0
	jsr	Put_unmasked_block
	Free	Dialogue_portrait_handle
; --------- Print character name ------------------
	Get	Dialogue_handle,a1		; Display character info
	move.w	#20,Ink_colour		; Set ink
	move.w	#208,d0
	move.w	#78,d1
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
	move.w	#43+7,d1
	jsr	Put_text_line
; ---------- Print character race -----------------
	move.l	Race_names_ptr,a0		; Get race name address
	moveq.l	#0,d0
	move.b	Char_race(a1),d0
	jsr	Find_small_text
	move.w	#208+34,d0		; Print character race
	move.w	#43,d1
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
	move.w	#43+21,d1
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
	move.w	#43+21,d1
	lea.l	Number,a0
	jsr	Put_text_line
; ---------- Print character's age ----------------
.No_class:	move.w	AAge(a1),d0		; Convert	age
	add.w	AAge+Magic(a1),d0
					; FIX: Removed "add.w Time_data_year,d0" (age counted twice)
	moveq.l	#3,d7
	move.l	Age_nr_ptr,a0
	jsr	DecL_convert
	move.w	#208+34,d0		; Print age
	move.w	#43+14,d1
	move.l	Age_txt_ptr,a0
	jsr	Put_text_line
	Free	Dialogue_handle		; End
	jmp	Dialogue_DisUpd		; First time

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Dialogue_CIL:
	dc.w Talk_cicon,0,Exit_cicon
	dc.w View_item_cicon,Leave_party_cicon,Join_party_cicon
	dc.w Give_item_cicon,Give_gold_cicon,Give_food_cicon
	dc.l DIA_Ask_word,0,DIA_Exit
	dc.l DIA_Show_item,DIA_Leave_party,DIA_Join_party
	dc.l DIA_Give_item,DIA_Give_gold,DIA_Give_food
	dc.l Dialogue_CIL_evaluate
Dialogue_offsets:
	dc.l Char_dialogue,NPC_dialogue,0
