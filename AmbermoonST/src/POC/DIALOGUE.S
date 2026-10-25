; Proof of concept : talking to persons (Atari ST)
;
; From ACTIONS.S ([ Talk ]), DIALOGUE.S, WORD_SEL.S and EVENTS.S : short
; dialogues (a map text), and the dialogue screen (layout 8) with the
; portrait of the person, the word selector (the known words of the
; dictionary) and the dialogue events of the person (dialogue actions,
; texts, queries, modifications, gifts, requesters, ...).
;
; The dialogue screen uses the inventory palette below the status block (it
; was chosen for all portraits).

	SECTION	Program,code

Dialogue_X	EQU	208			; Portrait & info
Dialogue_Y	EQU	43
Max_dialogue_size	EQU	4*1024
Max_dialogue_texts	EQU	8*1024			; (largest file : 5532 bytes)
Max_dictionary	EQU	4*1024
Visible_words	EQU	16

;*****************************************************************************
; [ Talk to a person ]
;   IN : d0/d1 - Map coordinates (.w)
; All registers are restored
; NOTE :
;   - From [ Talk ] (ACTIONS.S).
;*****************************************************************************
Talk_2D:
	movem.l	d0-d7/a0-a6,-(sp)
	cmp.w	Map_Xcoord,d0		; The party ?
	bne.s	.No_party
	cmp.w	Map_Ycoord,d1
	beq.s	.Party
	move.w	d1,d2			; (or the head)
	addq.w	#1,d2
	cmp.w	Map_Ycoord,d2
	bne.s	.No_party
.Party:	jsr	Talk_to_yourself
	bra	.Exit
.No_party:	jsr	Find_person		; Anyone there ?
	bmi	.Exit
	move.l	a0,d2			; Store person index
	sub.l	#VNPC_data,d2
	divu.w	#VNPC_data_size,d2
	move.w	d2,Dialogue_NPC_index
	sf	NPC_or_member
	move.b	NPC_status_bits(a0),d2	; Get NPC type
	andi.b	#$03,d2
	cmp.b	#Monster_type,d2		; Object or monster ?
	bpl	.Exit
	btst	#4,NPC_status_bits(a0)	; Long or short ?
	bne	.Short
; ---------- Long dialogue ------------------------
	moveq.l	#0,d0			; Load data
	move.b	NPC_char_nr(a0),d0
	move.w	d0,Dialogue_char_nr
	jsr	Load_person
	bmi	.Exit
	move.l	Dialogue_data_ptr,a1	; Compare languages
	move.b	Learned_languages(a1),d0
	and.b	Party_chars+(Active_member-1)*512+Learned_languages,d0
	bne.s	.Capito
	move.w	#106,d0			; "Not the same language"
	jsr	Prompt_window
	bra.s	.Exit
.Capito:	jsr	Dialogue_screen
	bra.s	.Exit
; ---------- Short dialogue -----------------------
.Short:	moveq.l	#0,d0			; Get text number
	move.b	NPC_char_nr(a0),d0
	move.w	Map_nr,Current_event_map_nr	; Map text
	sf	Map_or_dialogue
	jsr	Get_event_texts
	jsr	Find_large_text
	jsr	Text_window
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Find the person at a map position ]
;   IN : d0/d1 - Map coordinates (.w)
;  OUT : a0 - Pointer to person (.l)
;        mi - Nobody there
; Changed registers : a0
; NOTE :
;   - From [ Talk ] : also the tile above a person (its head).
Find_person:
	movem.l	d2/d6/d7,-(sp)
	tst.b	World_map			; (no persons on the world maps)
	bne.s	.None
	lea.l	VNPC_data,a0
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq.s	.Next
	btst	d7,d6			; Deleted ?
	bne.s	.Next
	cmp.w	VMap_X(a0),d0		; Right coordinates ?
	bne.s	.Next
	cmp.w	VMap_Y(a0),d1
	beq.s	.Found
	btst	#3,NPC_status_bits(a0)	; Map graphics ?
	bne.s	.Next
	move.w	d1,d2			; Clicking on the head ?
	addq.w	#1,d2
	cmp.w	VMap_Y(a0),d2
	beq.s	.Found
.Next:	lea.l	VNPC_data_size(a0),a0
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop
.None:	moveq.l	#-1,d2
	bra.s	.Exit
.Found:	moveq.l	#0,d2
.Exit:	tst.w	d2
	movem.l	(sp)+,d2/d6/d7
	rts

; [ Load the data & texts of a person ]
;   IN : d0 - Character number (.w)
;        d2 - 0 = party member, 1 = NPC (.b)
;  OUT : mi - Error
; All registers are restored
; NOTE :
;   - From [ Load_NPC_data ] (ACTIONS.S).
Load_person:
	movem.l	d0-d3/a0/a1,-(sp)
	move.l	#'NPC_',d1		; (prefixes : NPC<n>, NPCT<n>)
	move.l	#'NPCT',d3
	tst.b	d2
	bne.s	.NPC
	move.l	#'PC__',d1		; (PC<n>, PCT<n>)
	move.l	#'PCT_',d3
.NPC:	move.l	d1,d2
	lea.l	Dialogue_data,a1
	move.l	a1,Dialogue_data_ptr
	cmp.l	#'PC__',d2		; Party character who left ?
	bne.s	.Load
	lea.l	Party_stored-1,a0
	tst.b	0(a0,d0.w)
	beq.s	.Load
	move.l	d0,-(sp)			; Yes -> his data
	subq.w	#1,d0
	mulu.w	#512,d0
	lea.l	Party_store,a0
	add.l	d0,a0
	move.w	#512/4-1,d0
.Copy:	move.l	(a0)+,(a1)+
	dbra	d0,.Copy
	move.l	(sp)+,d0
	bra.s	.Texts
.Load:	move.l	#Max_dialogue_size,d1
	jsr	Load_person_file
	bmi.s	.Exit
.Texts:
	move.l	d3,d2
	lea.l	Dialogue_texts,a1
	move.l	#Max_dialogue_texts,d1
	jsr	Load_person_file
.Exit:	movem.l	(sp)+,d0-d3/a0/a1
	rts

; [ Load "DATA\<prefix><number>.BIN" (the prefix without "_") ]
;   IN : d0 - Number (.w), d1 - maximum length (.l), d2 - prefix (.l)
;        a1 - Pointer to buffer (.l)
;  OUT : mi - Error
; All registers are restored
Load_person_file:
	movem.l	d0-d3/a0,-(sp)
	lea.l	Named_file+5,a0
	moveq.l	#4-1,d3
.Prefix:	rol.l	#8,d2
	cmp.b	#'_',d2
	beq.s	.Skip
	move.b	d2,(a0)+
.Skip:	dbra	d3,.Prefix
	andi.l	#$ffff,d0			; Number (up to 3 digits)
	cmp.w	#100,d0
	bmi.s	.Two
	divu.w	#100,d0
	addi.b	#'0',d0
	move.b	d0,(a0)+
	clr.w	d0
	swap	d0
.Two:	cmp.w	#10,d0
	bmi.s	.One
	divu.w	#10,d0
	addi.b	#'0',d0
	move.b	d0,(a0)+
	swap	d0
.One:	addi.b	#'0',d0
	move.b	d0,(a0)+
	move.b	#'.',(a0)+
	move.b	#'B',(a0)+
	move.b	#'I',(a0)+
	move.b	#'N',(a0)+
	clr.b	(a0)
	lea.l	Named_file,a0
	move.l	d1,d0
	jsr	Load_file
	tst.l	d0
	movem.l	(sp)+,d0-d3/a0
	rts

; [ Show a message in a text window ]
;   IN : d0 - Message number (.w)
; All registers are restored
; NOTE :
;   - Like [ Do_prompt_window ] (HULL/CONTROLS.S).
Prompt_window:
	movem.l	d0/a0,-(sp)
	addi.w	#Messages,d0
	jsr	Get_text
	jsr	Text_window
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Dialogue screen ]
; All registers are restored
; NOTE :
;   - From the Dialogue module (DIALOGUE.S), for persons and party members
;     ([ NPC_or_member ]).
;*****************************************************************************
Dialogue_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	sf	Abort_dialogue
	sf	Joined
	sf	Left
	move.w	#Active_member,Inventory_member	; (for ~INVN~)
	move.w	#3,Inventory_mode		; (for the objects under the mouse)
	move.l	#Lay3_bar,SB_ptr
	move.l	#Dialogue_PA,Print_area_ptr
	clr.l	Ghost_text
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	lea.l	Dialogue_files,a0		; Load layout & dictionary
	jsr	Load_files
	move.l	Dialogue_data_ptr,a0	; Load portrait
	moveq.l	#0,d0
	move.b	Portrait_nr(a0),d0
	lea.l	Dialogue_portrait,a1
	move.l	#34*2*8,d1
	move.l	#'PT__',d2
	jsr	Load_person_file
	lea.l	Dialogue_RL,a0		; Install palettes
	jsr	Set_raster_list
	jsr	Build_dialogue_screen
	jsr	Copy_screen_to_both
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
	moveq.l	#Init_DIAC,d0		; Start
	moveq.l	#0,d1
	jsr	DIA_event_handler
	bpl.s	.Loop			; Anything ?
	move.w	#117,d0			; "Greetings !"
	tst.b	NPC_or_member		; (member : "OK")
	beq.s	.Greet
	move.w	#119,d0
.Greet:	jsr	Do_prompt
; ---------- Main loop ----------------------------
.Loop:	tst.b	Abort_dialogue		; Aborted ?
	bne	.Close
	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC ?
	beq.s	.Leave
	jsr	Read_mouse_clicks
	btst	#Left_pressed,d0
	beq.s	.Loop
	jsr	Find_inventory_object
	move.w	d0,d1
	lsr.w	#8,d1
	andi.w	#$00ff,d0
	cmp.w	#Obj_icon,d1		; Control icon ?
	bne.s	.Loop
	subq.w	#1,d0			; Disabled ?
	bmi.s	.Loop
	move.w	d0,d1
	add.w	d1,d1
	lea.l	Dialogue_CIL_work,a0
	move.w	0(a0,d1.w),d2
	beq.s	.Loop
	bmi.s	.Loop
	cmp.w	#3-1,d0			; Exit ?
	beq.s	.Exit
	add.w	d1,d1			; Execute
	move.l	.Ptrs(pc,d1.w),a0
	jsr	(a0)
	jsr	Dialogue_CIL_evaluate	; Update
	jsr	Copy_screen_to_both
	bra	.Loop
.Ptrs:	dc.l DIA_Ask_word,0,0
	dc.l DIA_Show_item,DIA_Leave_party,DIA_Join_party
	dc.l DIA_Give_item,DIA_Give_gold,DIA_Give_food
.Exit:	jsr	Press_exit_icon
.Leave:	moveq.l	#Exit_DIAC,d0		; The end
	moveq.l	#0,d1
	jsr	DIA_event_handler
	bpl.s	.Close			; Anything ?
	tst.b	NPC_or_member		; (not for members)
	bne.s	.Close
	move.w	#118,d0			; "Farewell !"
	jsr	Do_prompt
; ---------- Back to the map ----------------------
.Close:	sf	Map_or_dialogue
	moveq.l	#0,d0
	jsr	Close_lay3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Ask a word ]
; NOTE :
;   - From [ DIA_Ask_word ] (DIALOGUE.S).
DIA_Ask_word:
	movem.l	d0/d1,-(sp)
	jsr	Select_word		; Select a word
	tst.w	d0
	bmi.s	.Exit
	move.w	d0,d1			; Try
	moveq.l	#Ask_word_DIAC,d0
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	move.w	#107,d0			; "I don't know anything about it."
	jsr	Do_prompt
.Exit:	movem.l	(sp)+,d0/d1
	rts

; [ Show the control icons that are possible ]
; All registers are restored
; NOTE :
;   - From [ Dialogue_CIL_evaluate ] (DIALOGUE.S).
Dialogue_CIL_evaluate:
	movem.l	d0/d7/a0-a2,-(sp)
	lea.l	Dialogue_CIL,a0		; Copy
	lea.l	Dialogue_CIL_work,a1
	moveq.l	#9-1,d7
.Loop:	move.w	(a0)+,(a1)+
	dbra	d7,.Loop
	lea.l	Dialogue_CIL_work,a0
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	lea.l	Char_inventory+Backpack_slots(a1),a2	; Any items ?
	moveq.l	#Items_per_char-1,d7
.Loop2:	tst.w	Object_index(a2)
	bne.s	.Items
	lea.l	Object_packet_size(a2),a2
	dbra	d7,.Loop2
	bset	#7,3*2(a0)		; No -> disable {Show item}
	bset	#7,6*2(a0)		;  and {Give item}
.Items:	tst.w	Gold_coins(a1)		; Any gold ?
	bne.s	.Gold
	bset	#7,7*2(a0)
.Gold:	tst.w	Food_rations(a1)		; Any food ?
	bne.s	.Food
	bset	#7,8*2(a0)
.Food:	tst.b	Joined			; Can join ?
	bne.s	.No_join
	tst.b	NPC_or_member
	beq.s	.Join
.No_join:	bset	#7,5*2(a0)
.Join:	tst.b	Left			; Can leave ?
	bne.s	.No_leave
	tst.b	NPC_or_member
	bne.s	.Leave
.No_leave:	bset	#7,4*2(a0)
.Leave:	jsr	Display_CIL
	movem.l	(sp)+,d0/d7/a0-a2
	rts

; [ Show an item / give an item ]
; NOTE :
;   - From [ DIA_Show_item ] and [ DIA_Give_item ] : the backpack of the
;     active member is shown in the object slots, the selected item moves
;     to the portrait.
DIA_Show_item:
	movem.l	d0-d3/d7/a0-a2,-(sp)
	move.w	#108,d0			; Select item
	jsr	DIA_Select_item
	bmi.s	.Exit
	move.w	d0,d1			; Try
	moveq.l	#Show_item_DIAC,d0
	jsr	DIA_event_handler
	bpl.s	.Done			; Anything ?
	move.w	#114,d0			; "Nothing special"
	jsr	Do_prompt
.Done:	jsr	Move_item_back_to_slot
	jsr	Hide_Lay3_objects
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d3/d7/a0-a2
	rts

DIA_Give_item:
	movem.l	d0-d3/d7/a0-a2,-(sp)
	move.w	#109,d0			; Select item
	jsr	DIA_Select_item
	bmi.s	.Exit
	move.w	d0,d1			; Try
	sf	Item_accepted
	moveq.l	#Give_item_DIAC,d0
	jsr	DIA_event_handler
	bpl.s	.Done			; Anything ?
	move.w	#114,d0			; "Nothing special"
	jsr	Do_prompt
.Done:	tst.b	Item_accepted		; Taken ?
	bne.s	.Taken
	jsr	Move_item_back_to_slot	; No -> move back
.Taken:	jsr	Hide_Lay3_objects
	jsr	Build_dialogue_screen	; (gold, food & weight)
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d3/d7/a0-a2
	rts

; [ Select an item of the active member and move it to the portrait ]
;   IN : d0 - Prompt (message number) (.w)
;  OUT : d0 - Backpack slot {0...23} (.w)
;        mi - Nothing selected
; Changed registers : d0
DIA_Select_item:
	movem.l	d1-d7/a0-a2,-(sp)
	moveq.l	#Active_member,d7		; Show backpack
	jsr	Get_char_data
	lea.l	Char_inventory+Backpack_slots(a1),a1
	move.l	a1,Slot_base
	move.l	#Lay3_bar,SB_ptr
	move.w	d0,d2
	moveq.l	#0,d0
	jsr	Set_scroll_row
	move.w	d2,d0
	moveq.l	#0,d1
	jsr	Select_item
	subi.w	#9+1,d0			; Anything ?
	bmi.s	.Exit
	move.w	d0,d2
	jsr	Move_item_to_portrait
	move.w	d2,d0
.Exit:	movem.l	(sp)+,d1-d7/a0-a2
	tst.w	d0
	rts

; [ Move an item to the portrait ]
;   IN : d0 - Backpack slot {0...23} (.w)
; All registers are restored
; NOTE :
;   - From [ Move_item_to_portrait ] (DIALOGUE.S). The item is drawn like
;     the mouse pointer ([ Drag_fixed ]).
Move_item_to_portrait:
	movem.l	d0-d4/a0-a2,-(sp)
	move.w	d0,d2			; Save slot
	move.w	d0,d1			; Get graphic
	mulu.w	#Object_packet_size,d1
	move.l	Slot_base,a2
	move.w	Object_index(a2,d1.w),d0
	jsr	Get_item_data
	jsr	Get_item_graphic
	move.l	a0,Drag_graphic
	move.w	d2,d0			; Get slot coordinates
	sub.w	Scroll_bar_result,d0
	lsl.w	#2,d0
	lea.l	Lay3_object_pos_list,a0
	movem.w	0(a0,d0.w),d0/d1
	movem.w	d0/d1,Slot_XY
	move.w	d0,d2			; Erase slot
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#24-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	jsr	Copy_screen_to_both
	movem.w	d0/d1,Drag_pos		; Move to the portrait
	st	Drag_fixed
	move.w	#Dialogue_X+8,d0
	move.w	#Dialogue_Y+30,d1
	moveq.l	#8,d2
	jsr	Move_item
	movem.l	(sp)+,d0-d4/a0-a2
	rts

; [ Move the item back to its slot ]
; All registers are restored
Move_item_back_to_slot:
	movem.l	d0-d2,-(sp)
	movem.w	Slot_XY,d0/d1
	moveq.l	#10,d2			; (quickly !)
	jsr	Move_item
	sf	Drag_fixed
	clr.l	Drag_graphic
	moveq.l	#0,d0			; Show slots
	jsr	Set_scroll_row
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d2
	rts

; [ Move the item to a position ]
;   IN : d0/d1 - Target coordinates (.w)
;        d2 - Speed (pixels per frame) (.w)
; All registers are restored
; NOTE :
;   - Like [ Move_HDOB ] (KERNEL/HDOBS.S).
Move_item:
	movem.l	d0-d7,-(sp)
	movem.w	Drag_pos,d4/d5		; Get distance
	move.w	d0,d6
	sub.w	d4,d6
	move.w	d1,d7
	sub.w	d5,d7
	move.w	d6,d3			; Number of steps
	bpl.s	.Abs1
	neg.w	d3
.Abs1:	move.w	d7,d0
	bpl.s	.Abs2
	neg.w	d0
.Abs2:	cmp.w	d0,d3
	bpl.s	.Max
	move.w	d0,d3
.Max:	ext.l	d3
	divu.w	d2,d3
	tst.w	d3
	beq.s	.Last
	moveq.l	#1,d2			; Do
.Loop:	move.w	d6,d0
	muls.w	d2,d0
	divs.w	d3,d0
	add.w	d4,d0
	move.w	d7,d1
	muls.w	d2,d1
	divs.w	d3,d1
	add.w	d5,d1
	movem.w	d0/d1,Drag_pos
	jsr	Switch_screens
	addq.w	#1,d2
	cmp.w	d3,d2
	ble.s	.Loop
.Last:	add.w	d6,d4			; Exactly there
	add.w	d7,d5
	movem.w	d4/d5,Drag_pos
	jsr	Switch_screens
	jsr	Switch_screens
	movem.l	(sp)+,d0-d7
	rts

; [ The item disappears at the portrait ]
; All registers are restored
Dissolve_item_at_portrait:
	move.l	d7,-(sp)
	moveq.l	#25-1,d7			; (wait a moment)
.Loop:	jsr	Switch_screens
	dbra	d7,.Loop
	sf	Drag_fixed
	clr.l	Drag_graphic
	jsr	Switch_screens
	jsr	Switch_screens
	move.l	(sp)+,d7
	rts

; [ Join the party ]
; NOTE :
;   - From [ DIA_Join_party ] (DIALOGUE.S).
DIA_Join_party:
	movem.l	d0/d1/a0,-(sp)
	jsr	Count_party		; Party full ?
	cmp.w	#6,d0
	bmi.s	.No
	move.w	#121,d0			; Yes !
	jsr	Do_prompt
	bra.s	.Exit
.No:	move.l	Dialogue_data_ptr,a0	; Is party ?
	tst.b	Char_type(a0)
	beq.s	.Party
	move.w	#115,d0			; No -> Hah !
	jsr	Do_prompt
	bra.s	.Exit
.Party:	moveq.l	#Join_party_DIAC,d0		; Yes -> Try
	moveq.l	#0,d1
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	st	Joined			; No -> Join anyway
	jsr	Add_party_member
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

; [ Leave the party ]
; NOTE :
;   - From [ DIA_Leave_party ] (DIALOGUE.S).
DIA_Leave_party:
	movem.l	d0/d1/d7/a0,-(sp)
	move.l	Dialogue_data_ptr,a0	; Get conditions
	move.w	Body_conditions(a0),d0
	move.w	#Alive_mask,d1		; Alive and kicking ?
	and.w	d0,d1
	beq.s	.Alive
	moveq.l	#98,d0			; No -> "No stiffs..."
	bra.s	.Prompt
.Alive:	btst	#Mad,d0			; Bonkers ?
	beq.s	.Sane
	moveq.l	#99,d0			; Yes -> "No loonies..."
	bra.s	.Prompt
.Sane:	btst	#Petrified,d0		; Petrified ?
	beq.s	.Ok
	moveq.l	#100,d0			; Yes -> "No petrified..."
	bra.s	.Prompt
.Ok:	tst.w	Current_world_nr		; On Lyramion ?
	beq.s	.Lyramion
	moveq.l	#97,d0			; No -> "No way!"
.Prompt:	jsr	Do_prompt
	bra.s	.Exit
.Lyramion:	moveq.l	#Leave_party_DIAC,d0	; Try
	moveq.l	#0,d1
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	moveq.l	#116,d0			; No -> Kick out anyway
	jsr	Do_prompt
	move.w	Dialogue_NPC_index,d7
	jsr	Remove_party_member
	st	Left			; Indicate
	st	Abort_dialogue		; Leave dialogue
.Exit:	movem.l	(sp)+,d0/d1/d7/a0
	rts

;*****************************************************************************
; [ Talk to a party member ]
; All registers are restored
; NOTE :
;   - From [ Talk_to_yourself ] (ACTIONS.S).
;*****************************************************************************
Talk_to_yourself:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Count_party		; All alone ?
	cmp.w	#1,d0
	beq	.Exit
	move.l	Print_area_ptr,-(sp)	; Talk to whom ?
	move.l	#Map_PA,Print_area_ptr
	move.w	#103,d0
	jsr	Select_member
	move.l	(sp)+,Print_area_ptr
	move.l	#-1,Last_position		; (redraw the position)
	tst.w	d0			; No-one ?
	beq	.Exit
	cmp.w	#1,d0			; Yourself ?
	bne.s	.Else
	move.w	#104,d0			; Weirdo !
	jsr	Prompt_window
	bra	.Exit
.Else:	move.w	d0,d7			; Set data
	move.w	d0,Dialogue_NPC_index
	jsr	Get_char_data
	move.l	a1,Dialogue_data_ptr
	lea.l	Member_nrs-2,a0		; Get character number
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.w	d0,Dialogue_char_nr
	move.l	#Max_dialogue_texts,d1	; Load character texts
	move.l	#'PCT_',d2
	lea.l	Dialogue_texts,a1
	jsr	Load_person_file
	bmi.s	.Exit
	st	NPC_or_member		; With party member
	jsr	Dialogue_screen
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Give gold / food ]
; NOTE :
;   - From [ DIA_Give_gold ] and [ DIA_Give_food ].
DIA_Give_gold:
	movem.l	d0-d2/d7/a1,-(sp)
	moveq.l	#Gold_coins,d2
	move.w	#110,d0
	moveq.l	#Give_gold_DIAC,d7
	bra.s	DIA_Give_goldfood
DIA_Give_food:
	movem.l	d0-d2/d7/a1,-(sp)
	moveq.l	#Food_rations,d2
	move.w	#111,d0
	moveq.l	#Give_food_DIAC,d7
DIA_Give_goldfood:
	move.l	d7,-(sp)
	moveq.l	#Active_member,d7		; How much ?
	jsr	Get_char_data
	move.l	(sp)+,d7
	moveq.l	#0,d1
	move.w	0(a1,d2.w),d1
	move.w	d2,-(sp)
	moveq.l	#1,d2			; (gold or food)
	cmp.w	#Give_gold_DIAC,d7
	beq.s	.Gold
	moveq.l	#2,d2
.Gold:	jsr	Input_number
	move.w	(sp)+,d2
	move.l	d0,d1			; Any ?
	beq.s	.Exit
	sf	Not_enough		; Try
	move.w	d7,d0
	jsr	DIA_event_handler
	bpl.s	.Exit			; Anything ?
	tst.b	Not_enough		; Not enough ?
	bne.s	.Exit
	move.w	#112,d0			; "Hah !"
	cmp.w	#Gold_coins,d2
	beq.s	.Prompt
	move.w	#113,d0
.Prompt:	jsr	Do_prompt
.Exit:	movem.l	(sp)+,d0-d2/d7/a1
	rts

; [ Build the dialogue screen ]
; All registers are restored
; NOTE :
;   - From [ Build_dialogue_screen ] (DIALOGUE.S).
Build_dialogue_screen:
	movem.l	d0-d7/a0-a2,-(sp)
	moveq.l	#0,d0			; Show layout
	moveq.l	#Middle_Y+1,d1
	moveq.l	#20,d6
	move.w	#199-Middle_Y,d7
	lea.l	Extra_layout,a0
	jsr	Put_unmasked_block
	jsr	Erase_PA
	jsr	Dialogue_CIL_evaluate	; Show control icons
	jsr	Hide_Lay3_objects		; Hide
	move.w	#Dialogue_X,d0		; Display portrait
	move.w	#Dialogue_Y,d1
	moveq.l	#2,d6
	moveq.l	#34,d7
	lea.l	Dialogue_portrait,a0
	jsr	Put_unmasked_block
	move.l	Dialogue_data_ptr,a1
	move.w	#Default_shadow,Shadow_colour
	move.w	#Red,Ink_colour		; Print character name
	move.w	#Dialogue_X,d0
	move.w	#Dialogue_Y+35,d1
	move.w	#96,d2
	lea.l	Char_name(a1),a0
	jsr	Print_centered_string
	move.w	#White,Ink_colour		; Print character sex
	moveq.l	#Male_txt,d0
	tst.b	Char_sex(a1)
	beq.s	.Male
	moveq.l	#Female_txt,d0
.Male:	jsr	Get_text
	move.w	#Dialogue_X+34,d0
	move.w	#Dialogue_Y+7,d1
	jsr	Put_text_line
	moveq.l	#0,d0			; Print character race
	move.b	Char_race(a1),d0
	addi.w	#Race_names,d0
	jsr	Get_text
	move.w	#Dialogue_X+34,d0
	move.w	#Dialogue_Y,d1
	jsr	Put_text_line
	move.b	Char_race(a1),d0		; Special or monster ?
	move.w	#Special_race_mask,d1
	btst	d0,d1
	bne.s	.No_class
	moveq.l	#0,d0			; Print character class
	move.b	Char_class(a1),d0
	addi.w	#Class_names,d0
	jsr	Get_text
	move.l	a0,a2
	moveq.l	#0,d2
.Len:	tst.b	(a2)+
	beq.s	.Len_done
	addq.w	#Char_width+1,d2
	bra.s	.Len
.Len_done:	move.w	#Dialogue_X+34,d0
	move.w	#Dialogue_Y+21,d1
	jsr	Put_text_line
	moveq.l	#0,d0			; Print level
	move.b	Level_nr(a1),d0
	moveq.l	#2,d7
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	#Dialogue_X+34+Char_width+1,d0
	add.w	d2,d0
	move.w	#Dialogue_Y+21,d1
	lea.l	Number,a0
	jsr	Put_text_line
.No_class:	moveq.l	#Age_txt,d0		; Print age
	jsr	Copy_text
	moveq.l	#0,d0
	move.w	AAge(a1),d0
	add.w	AAge+Magic(a1),d0
	moveq.l	#3,d7
	lea.l	6(a2),a0
	jsr	DecL_convert
	move.w	#Dialogue_X+34,d0
	move.w	#Dialogue_Y+14,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Active member, gold & food -----------
	move.w	#Yellow,Ink_colour		; Print active name
	move.w	#Dialogue_X,d0
	move.w	#99,d1
	move.w	#96,d2
	lea.l	Party_chars+(Active_member-1)*512+Char_name,a0
	jsr	Print_centered_string
	lea.l	Party_chars+(Active_member-1)*512,a1
	move.w	#208,d7			; Gold
	move.w	#106,d1
	move.w	Gold_coins(a1),d5
	moveq.l	#Gold_txt,d6
	jsr	Goldfood_box
	move.w	#256,d7			; Food
	move.w	Food_rations(a1),d5
	moveq.l	#Food_txt,d6
	jsr	Goldfood_box
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Dialogue events ]
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
; [ Handle the events of a dialogue action ]
;   IN : d0 - Dialogue action (.w)
;        d1 - Value (.w)
;  OUT : pl - An event was found
;        mi - No event was found
; All registers are restored
DIA_event_handler:
	movem.l	d0,-(sp)
	st	Map_or_dialogue		; Dialogue
	jsr	Find_DIA_event		; Find event
	bmi.s	.Exit			; Any there ?
	jsr	Handle_DIA_event_chain	; Handle
	moveq.l	#1,d0			; Positive !
.Exit:	movem.l	(sp)+,d0
	rts

; [ Find the dialogue event chain of a dialogue action ]
;   IN : d0 - Dialogue action (.w)
;        d1 - Value (.w)
;  OUT : pl - Found, mi - Not found
; All registers are restored
Find_DIA_event:
	movem.l	d0-d2/d6/d7/a0-a2,-(sp)
	move.w	d0,Current_DIAC		; Store input
	move.w	d1,Current_DIAC_value
	moveq.l	#-1,d7			; Default is no event
	move.l	Dialogue_data_ptr,a0	; Get dialogue data
	move.w	#NPC_dialogue,d2		; (NPC or party member)
	tst.b	Char_type(a0)
	bne.s	.NPC
	move.w	#Char_dialogue,d2
.NPC:	add.w	d2,a0
	move.w	(a0)+,d6			; Get number of entries
	beq.s	.Exit			; Any ?
	move.l	a0,a1			; Get event data
	add.w	d6,a1
	add.w	d6,a1
	addq.l	#2,a1
	move.l	a1,Current_event_base	; Set event base
	subq.w	#1,d6
.Loop:	move.w	(a0)+,d2			; Get entry number
	move.w	d2,Current_event_block
	mulu.w	#Event_data_size,d2		; Get first event
	lea.l	0(a1,d2.l),a2
	cmp.b	#Dia_action_type,(a2)	; Dialogue action ?
	bne.s	.Next
	cmp.b	Event_b1(a2),d0		; Correct action type ?
	bne.s	.Next
	jsr	Dia_action		; Correct value ?
	bne.s	.Next
	move.w	-2(a0),Current_event_entry_nr	; Yes -> Set event info
	clr.w	Current_event_map_nr
	move.w	Current_event_block,d0	; Copy event data
	jsr	Copy_event_data
	moveq.l	#1,d7			; Success !
	bra.s	.Exit
.Next:	dbra	d6,.Loop			; Next event chain
.Exit:	tst.w	d7			; Any luck ?
	movem.l	(sp)+,d0-d2/d6/d7/a0-a2
	rts

; [ Check the value of a dialogue action ]
;   IN : d0 - Dialogue action (.w)
;        d1 - Value (.w)
;        a2 - Pointer to event data (.l)
;  OUT : eq - Correct, ne - Wrong
; All registers are restored
; NOTE :
;   - From [ Dia_action ] (EVENTS.S).
Dia_action:
	movem.l	d0-d3/d7/a0/a1,-(sp)
	moveq.l	#0,d7			; Default is OK
	move.b	Event_w6(a2),d2		; Get value (not aligned)
	lsl.w	#8,d2
	move.b	Event_w6+1(a2),d2
	cmp.w	#-1,d2			; Does it matter ?
	beq.s	.Exit
	cmp.w	#Ask_word_DIAC,d0		; Word ?
	bne.s	.No_word
	cmp.w	d1,d2			; Correct value ?
	sne	d7
	bra.s	.Exit
.No_word:	cmp.w	#Show_item_DIAC,d0		; Item ?
	beq.s	.Item
	cmp.w	#Give_item_DIAC,d0
	bne.s	.No_item
.Item:	move.w	d7,d3
	moveq.l	#Active_member,d7		; Get object index
	jsr	Get_char_data
	move.w	d3,d7
	lea.l	Char_inventory+Backpack_slots(a1),a1
	move.w	d1,d3
	mulu.w	#Object_packet_size,d3
	cmp.w	Object_index(a1,d3.w),d2	; Correct item ?
	sne	d7
	bra.s	.Exit
.No_item:	move.w	#102,d3			; Gold ?
	cmp.w	#Give_gold_DIAC,d0
	beq.s	.Amount
	move.w	#227,d3			; Food ?
	cmp.w	#Give_food_DIAC,d0
	bne.s	.Exit
.Amount:	cmp.w	d2,d1			; Enough ?
	bmi.s	.Not
	move.w	d2,Current_DIAC_value	; Yes
	bra.s	.Exit
.Not:	move.w	d3,d0			; "Give me more !"
	jsr	Do_prompt
	st	Not_enough
	st	d7
.Exit:	tst.b	d7
	movem.l	(sp)+,d0-d3/d7/a0/a1
	rts

; [ Dialogue execute event ]
; NOTE :
;   - From [ Dia_execute ] (EVENTS.S).
Dia_execute:
	move.w	Current_DIAC_value,d1	; Get parameters
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	move.l	a1,a0
	move.w	Current_DIAC,d0
	cmp.w	#Join_party_DIAC,d0		; Join ?
	bne.s	.No_join
	tst.b	NPC_or_member		; (just checking)
	bne	.Exit
	st	Joined			; Yay !
	jmp	Add_party_member
.No_join:	cmp.w	#Leave_party_DIAC,d0	; Leave ?
	bne.s	.No_leave
	tst.b	NPC_or_member		; (just checking)
	beq	.Exit
	move.w	Dialogue_NPC_index,d7	; Go !
	jsr	Remove_party_member
	st	Abort_dialogue		; Abort !
	st	Left
	rts
.No_leave:	cmp.w	#Give_item_DIAC,d0		; Item ?
	bne.s	.No_item
	jsr	Dissolve_item_at_portrait	; Poof !
	st	Item_accepted
	move.w	d1,d2			; Remove item
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jmp	Remove_item
.No_item:	moveq.l	#Gold_coins,d2		; Gold ?
	move.w	#Gold_weight,d3
	cmp.w	#Give_gold_DIAC,d0
	beq.s	.Remove
	moveq.l	#Food_rations,d2		; Food ?
	move.w	#Food_weight,d3
	cmp.w	#Give_food_DIAC,d0
	bne.s	.Exit
.Remove:	cmp.w	0(a0,d2.w),d1		; Enough ?
	bls.s	.Ok
	move.w	0(a0,d2.w),d1		; No -> clip
.Ok:	sub.w	d1,0(a0,d2.w)		; Remove
	mulu.w	d3,d1
	sub.l	d1,Weight_normal(a0)
	jsr	Build_dialogue_screen	; Show
	jsr	Copy_screen_to_both
.Exit:	rts

; [ Handle a chain of dialogue events ]
; All registers are restored
Handle_DIA_event_chain:
	sf	Success
.Again:	sf	Break_event		; Handle event
	jsr	Handle_DIA_event
	tst.b	Break_event		; Break ?
	bne.s	.Exit
	jsr	Chain_to_next_event		; Next event
	bpl.s	.Again			; Last ?
.Exit:	sf	Success
	rts

; [ Handle a dialogue event ]
; All registers are restored
Handle_DIA_event:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#0,d0			; Get current event type
	move.b	Current_event_data,d0
	tst.w	d0			; Legal ?
	beq.s	.Stop
	cmpi.w	#Max_events+1,d0
	bpl.s	.Stop
	move.l	#Dia_event_mask,d1		; Possible in dialogue ?
	btst	d0,d1
	beq.s	.Exit
	move.l	#Clear_success_mask,d1	; Clear success ?
	btst	d0,d1
	beq.s	.No1
	sf	Success
.No1:	move.l	#Dia_break_mask,d1		; Break off dialogue ?
	btst	d0,d1
	beq.s	.No2
	st	Abort_dialogue
.No2:	move.l	#Map_break_mask,d1		; Break ?
	btst	d0,d1
	sne	Break_event
	lsl.w	#2,d0			; Execute event
	lea.l	Event_ptrs,a0
	movea.l	-4(a0,d0.w),a0
	jsr	(a0)
	bra.s	.Exit
.Stop:	st	Break_event
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Dialogue text event ]
Dia_text:
	moveq.l	#0,d0			; Get text number
	move.b	Current_event_data+Event_b1,d0
	lea.l	Dialogue_texts,a0		; Display text
	jsr	Find_large_text
	jmp	Show_PA_text

; [ Dialogue give event ]
; NOTE :
;   - From [ Dia_give ] : gold & food are given to the active member, items
;     are put into the backpack of the active member (the Amiga version
;     shows them in the object slots).
Dia_give:
	lea.l	Current_event_data,a5
	lea.l	Party_chars+(Active_member-1)*512,a1
	move.b	Event_w6(a5),d0		; Get amount (not aligned)
	lsl.w	#8,d0
	move.b	Event_w6+1(a5),d0
	tst.b	Event_b1(a5)		; Item ?
	bne.s	.Gold_or_food
	lea.l	Dia_packet,a0		; Make packet
	move.b	d0,Quantity(a0)
	move.b	Event_w8(a5),d0		; (item number)
	lsl.w	#8,d0
	move.b	Event_w8+1(a5),d0
	move.w	d0,Object_index(a0)
	move.l	a1,-(sp)
	jsr	Get_item_data
	move.b	Spell_charges(a1),Charges(a0)
	move.b	Enchantment_normal_init(a1),Enchantment_normal(a0)
	move.b	Item_bits_DYNAMIC_init(a1),Item_bits_DYNAMIC(a0)
	move.l	(sp)+,a1
	jmp	Auto_move_to_backpack
.Gold_or_food:
	cmp.b	#1,Event_b1(a5)		; Gold ?
	bne.s	.Food
	add.w	d0,Gold_coins(a1)
	mulu.w	#Gold_weight,d0
	add.l	d0,Weight_normal(a1)
	bra.s	.Show
.Food:	add.w	d0,Food_rations(a1)
	mulu.w	#Food_weight,d0
	add.l	d0,Weight_normal(a1)
.Show:	jsr	Build_dialogue_screen	; (gold & food)
	jmp	Copy_screen_to_both

; [ Requester event ]
; NOTE :
;   - From [ Requester ] : the text with Yes & No, No follows the negative
;     chain.
Requester:
	lea.l	Current_event_data,a5
	jsr	Get_event_texts		; Find text
	moveq.l	#0,d0
	move.b	Event_b1(a5),d0
	jsr	Find_large_text
	jsr	Ask_yes_no_text
	tst.w	d0			; Yes ?
	bne.s	.Exit
	move.w	Event_w8(a5),Current_event_data+Next_event_nr	; Negative chain
.Exit:	rts

;*****************************************************************************
; [ Select a word ]
;  OUT : d0 - Word number / -1 = none (.w)
; Changed registers : d0
; NOTE :
;   - From WORD_SEL.S : the known words, sorted, new words in yellow. Words
;     can not be typed in the proof of concept.
;*****************************************************************************
Select_word:
	movem.l	d1-d7/a0-a6,-(sp)
	jsr	Make_word_list		; Any words known ?
	tst.w	Nr_of_known_words
	beq	.None
	move.w	#WSelW_X-16,d0		; Open a window
	move.w	#WSelW_Y-16,d1
	moveq.l	#11,d2
	moveq.l	#10,d3
	jsr	Open_window
	move.w	#WSelW_X+95,d0		; Exit icon
	move.w	#WSelW_Y+113,d1
	moveq.l	#32,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0
	addq.w	#1,d1
	moveq.l	#Exit_cicon,d3
	jsr	Display_up_button
	move.l	SB_ptr,-(sp)		; Scroll bar
	lea.l	Word_bar,a0
	move.l	a0,SB_ptr
	move.w	Nr_of_known_words,d0
	moveq.l	#0,d1			; Number of rows - visible rows
	sub.w	#Visible_words,d0
	ble.s	.All
	move.w	d0,d1
.All:	move.w	d1,SBD_max_row(a0)
	move.w	#113,d0			; Row height
	move.w	Nr_of_known_words,d2
	cmp.w	#Visible_words,d2
	bpl.s	.Many
	moveq.l	#Visible_words,d2
.Many:	ext.l	d0
	divu.w	d2,d0
	move.w	d0,SBD_row_height(a0)
	mulu.w	d1,d0			; Thingy height
	neg.w	d0
	addi.w	#113,d0
	move.w	d0,SBD_thingy_height(a0)
	moveq.l	#0,d0
	jsr	Set_scroll_row
	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
; ---------- Wait for a word ----------------------
	moveq.l	#-1,d4
.Loop:	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC ?
	beq	.Done
	jsr	Read_mouse_clicks
	move.w	d0,d6
	beq.s	.Loop
	btst	#Right_pressed,d6		; Right button ?
	bne.s	.Done
	move.w	Mouse_X,d2
	move.w	Mouse_Y,d3
	cmp.w	#WSelW_X+128+7,d2		; Scroll bar ?
	bmi.s	.No_bar
	cmp.w	#WSelW_X+128+7+6,d2
	bpl.s	.No_bar
	cmp.w	#WSelW_Y-1,d3
	bmi.s	.No_bar
	cmp.w	#WSelW_Y-1+113,d3
	bpl.s	.No_bar
	jsr	Scroll_bar_pressed
	bra.s	.Loop
.No_bar:	cmp.w	#WSelW_Y+114,d3		; Exit icon ?
	bmi.s	.No_exit
	cmp.w	#WSelW_X+96,d2
	bmi.s	.Loop
	cmp.w	#WSelW_X+96+32,d2
	bpl.s	.Loop
	bra.s	.Done
.No_exit:	sub.w	#WSelW_X,d2		; A word ?
	bmi.s	.Loop
	cmp.w	#128,d2
	bpl.s	.Loop
	sub.w	#WSelW_Y,d3
	bmi.s	.Loop
	ext.l	d3
	divu.w	#Char_height+2,d3
	cmp.w	#Visible_words,d3
	bpl.s	.Loop
	add.w	Scroll_bar_result,d3
	cmp.w	Nr_of_known_words,d3
	bpl	.Loop
	lea.l	Word_list,a0		; Get word number
	add.w	d3,d3
	move.w	0(a0,d3.w),d4
.Done:	move.l	(sp)+,SB_ptr
	jsr	Close_window
	move.w	d4,d0
	bra.s	.Exit
.None:	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d1-d7/a0-a6
	rts

; [ Show the words of the word selector ]
; All registers are restored
; NOTE :
;   - From [ Update_wordselect_window ].
Update_word_list:
	movem.l	d0-d7/a0/a1,-(sp)
	move.w	#WSelW_X,d0		; Clear word area
	move.w	#WSelW_Y-2,d1
	move.w	#128,d2
	move.w	#113,d3
	jsr	Draw_standard_box
	move.w	Scroll_bar_result,d0	; Show how many words ?
	move.w	Nr_of_known_words,d7
	sub.w	d0,d7
	cmp.w	#Visible_words+1,d7
	bmi.s	.Ok
	moveq.l	#Visible_words,d7
.Ok:	lea.l	Word_list,a1
	add.w	d0,d0
	add.w	d0,a1
	move.w	#Default_shadow,Shadow_colour
	move.w	#WSelW_Y,d3
	bra.s	.Entry
.Loop:	move.w	(a1)+,d0			; Get word number
	moveq.l	#New_words_bit_array,d1	; New word ?
	moveq.l	#3,d2
	jsr	Access_bit_array
	beq.s	.Not_new
	move.w	#Yellow,Ink_colour		; New
	bra.s	.Continue
.Not_new:	move.w	#31,Ink_colour		; Old
.Continue:	jsr	Find_word			; Print word
	move.w	#WSelW_X+4,d0
	move.w	d3,d1
	jsr	Put_text_line
	addq.w	#Char_height+2,d3
.Entry:	dbra	d7,.Loop
	movem.l	(sp)+,d0-d7/a0/a1
	rts

; [ Make the sorted list of the known words ]
; All registers are restored
Make_word_list:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Word_list,a0
	moveq.l	#0,d0
	moveq.l	#WD_bit_array,d1
	moveq.l	#3,d2
	moveq.l	#0,d6
	move.w	Dictionary,d7		; (number of words)
	bra.s	.Entry
.Loop:	jsr	Access_bit_array		; Word known ?
	beq.s	.Next
	move.w	d0,(a0)+			; Insert
	addq.w	#1,d6
.Next:	addq.w	#1,d0
.Entry:	dbra	d7,.Loop
	move.w	d6,Nr_of_known_words
; ---------- Sort (insertion sort) ----------------
	lea.l	Word_list,a2
	moveq.l	#1,d5
.Sort:	cmp.w	d6,d5
	bpl.s	.Done
	move.w	d5,d4			; Insert word d5
.Back:	tst.w	d4
	beq.s	.Next2
	move.w	d4,d0
	add.w	d0,d0
	move.w	-2(a2,d0.w),d1		; Previous word
	move.w	0(a2,d0.w),d2		; This word
	move.w	d1,d0
	jsr	Find_word
	move.l	a0,a3
	move.w	d2,d0
	jsr	Find_word
	moveq.l	#0,d3			; Compare
.Cmp:	move.b	(a3)+,d0
	move.b	(a0)+,d7
	cmp.b	d7,d0
	bne.s	.Diff
	tst.b	d0
	bne.s	.Cmp
	bra.s	.Next2
.Diff:	bls.s	.Next2			; Previous <= this : done
	move.w	d4,d0			; Swap
	add.w	d0,d0
	move.w	d2,-2(a2,d0.w)
	move.w	d1,0(a2,d0.w)
	subq.w	#1,d4
	bra.s	.Back
.Next2:	addq.w	#1,d5
	bra.s	.Sort
.Done:	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Find a word in the dictionary ]
;   IN : d0 - Word number (.w)
;  OUT : a0 - Pointer to the word (in a buffer, zero-terminated) (.l)
; Changed registers : a0
; NOTE :
;   - From WORD_SEL.S. There are two buffers, used in turn.
Find_word:
	movem.l	d0/d1/a1,-(sp)
	lea.l	Dictionary,a1
	lea.l	Word_buffer1,a0		; (alternate buffers)
	not.b	Word_buffer_flag
	beq.s	.First
	lea.l	Word_buffer2,a0
.First:	move.l	a0,-(sp)
	cmp.w	(a1)+,d0			; Legal word ?
	bpl.s	.End
	moveq.l	#0,d1
	bra.s	.Entry
.Loop:	move.b	(a1)+,d1			; Get length
	add.w	d1,a1			; Next word
.Entry:	dbra	d0,.Loop
	move.b	(a1)+,d1			; Copy word
	bra.s	.Entry2
.Copy:	move.b	(a1)+,(a0)+
.Entry2:	dbra	d1,.Copy
.End:	clr.b	(a0)
	move.l	(sp)+,a0
	movem.l	(sp)+,d0/d1/a1
	rts

;*****************************************************************************
; [ Gold or food box ]
;   IN : d1 - Y-coordinate (.w)
;        d5 - Amount (.w)
;        d6 - Text number (.w)
;        d7 - X-coordinate (.w)
; All registers are restored
; NOTE :
;   - Like [ Update_gold ] and [ Update_food ] (EVENTS.S).
;*****************************************************************************
Goldfood_box:
	movem.l	d0-d7/a0,-(sp)
	move.w	d7,d0
	move.w	d1,d4
	tst.w	d5			; Any ?
	bne.s	.Yes
	move.w	d0,d2			; No -> Erase
	move.w	d1,d3
	addi.w	#45-1,d2
	addi.w	#17-1,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	bra.s	.Exit
.Yes:	moveq.l	#45,d2			; Yes -> Make box
	moveq.l	#17,d3
	jsr	Draw_standard_box2
	move.w	#White,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	move.w	d6,d0			; Print name
	jsr	Get_text
	move.w	d7,d0
	addq.w	#1,d0
	addq.w	#2,d1
	moveq.l	#45,d2
	jsr	Print_centered_string
	moveq.l	#0,d0			; Print amount
	move.w	d5,d0
	lea.l	Number,a0
	move.l	d7,-(sp)
	moveq.l	#5,d7
	jsr	DecL_convert
	move.l	(sp)+,d7
	move.w	d7,d0
	addq.w	#1,d0
	move.w	d4,d1
	addi.w	#9,d1
	moveq.l	#45,d2
	lea.l	Number,a0
	jsr	Print_centered_string
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

; Raster list of the dialogue screen (Dialogue_RL in MODULES.S)
Dialogue_RL:
	R_palette 0,UI_palette
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Inv_palette
	R_range Dialogue_Y,25,35,Portrait_range
	R_end
	even

; Print area of the dialogue screen (Dialogue_PA in MODULES.S)
Dialogue_PA:	dc.w 16+1,191-1,43+1,122-1,31

; Print area of the map screen (prompts while a member is selected)
Map_PA:	dc.w 208+2,304-2,49,49+6*(Char_height+2),White

; Control icon list of the dialogue screen (Dialogue_CIL in DIALOGUE.S)
Dialogue_CIL:
	dc.w Talk_cicon,0,Exit_cicon
	dc.w View_item_cicon,Leave_party_cicon,Join_party_cicon
	dc.w Give_item_cicon,Give_gold_cicon,Give_food_cicon

; Scroll bar of the word selector (WSelW_scroll_bar in WORD_SEL.S : one word
; per row, 16 rows visible, the other values are set when it is opened)
Word_bar:	dc.l 0
	dc.w WSelW_X+128+7,WSelW_Y-1,113,0,0,0,1,Visible_words/2
	dc.l Update_word_list

; Character numbers of the party members (Member_nrs)
Member_nrs:	dc.w 1,8,9,10,11,12

Dialogue_files:
	dc.l	Extra_layout,320*163/2
	dc.b	"DATA\LAYOUT8.BIN",0
	even
	dc.l	Dictionary,Max_dictionary
	dc.b	"DATA\DICT.BIN",0
	even
	dc.l	0

	SECTION	Fast_BSS,bss
Dialogue_data_ptr:	ds.l 1
Nr_of_known_words:	ds.w 1
Abort_dialogue:	ds.b 1
Word_buffer_flag:	ds.b 1
Dia_packet:	ds.b Object_packet_size
	even
Current_DIAC:	ds.w 1
Current_DIAC_value:	ds.w 1
Slot_XY:	ds.w 2
Dialogue_CIL_work:	ds.w 9
Item_accepted:	ds.b 1
Not_enough:	ds.b 1
	even
Word_buffer1:	ds.b 32
Word_buffer2:	ds.b 32
Word_list:	ds.w Max_words
Dialogue_portrait:	ds.b 34*2*8
Dictionary:	ds.b Max_dictionary
Dialogue_data:	ds.b Max_dialogue_size
Dialogue_texts:	ds.b Max_dialogue_texts
	even
