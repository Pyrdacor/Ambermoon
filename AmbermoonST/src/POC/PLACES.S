; Proof of concept : places (Atari ST)
;
; From PLACES.S and the camp of ACTIONS.S : the Places event with the place
; screens (layout 3) of the trainers, healers, sages, inns, object & magic
; merchants (library) and blacksmiths, and the camp after renting a room.
; The gold of the party is pooled while the party is in a place and divided
; when it leaves, like in the original. The control icon lists have the same
; layout as the original ones (icons, routines, evaluation routine).
;
; Not done : the enchanter and the food merchant (not used in the 2D maps),
; the transport merchants (there are no transports in the proof of concept),
; casting & learning spells in the camp, the sparkles and explosions.

	SECTION	Program,code

Place_name_X	EQU	110			; Name of the place
Place_name_Y	EQU	37
Max_sold	EQU	Items_per_chest		; Bought items
; Text numbers in TEXTS.BIN
Format_messages	EQU	742
Recup1_txt	EQU	10			; (format messages)
Recup2_txt	EQU	11
Gp_agree_txt	EQU	14

;*****************************************************************************
; [ Places event ]
; No registers are restored
; NOTE :
;   - From [ Places ] (PLACES.S).
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
	beq.s	.Exit
	sf	Map_or_dialogue		; Yes -> Show
	jsr	Get_event_texts
	jsr	Find_large_text
	jmp	Text_window
.No2:	move.b	Event_b4(a5),d1		; Get closing time
	cmp.w	d1,d0			; Too late ?
	bge.s	.Closed
.Open:	moveq.l	#0,d0			; Get place type
	move.b	Event_b2(a5),d0
	cmp.w	#Max_places,d0		; Legal ?
	bpl.s	.Exit
	move.w	d0,Current_place_type	; Store
	move.w	Event_w6(a5),d1		; Get place data
	move.w	d1,Current_place_nr
	subq.w	#1,d1
	mulu.w	#Place_data_size,d1
	lea.l	Places_data+2,a0
	add.l	d1,a0
	move.l	a0,Place_ptr
	lsl.w	#2,d0			; Do it
	move.l	.Mods(pc,d0.w),d0
	beq.s	.Exit
	move.l	d0,a0
	jsr	(a0)
.Exit:	rts

.Mods:	dc.l Trainer_place_init		; Places modules
	dc.l Healer_place_init
	dc.l Sage_place_init
	dc.l 0				; (enchanter)
	dc.l Inn_place_init
	dc.l MerchOBJC_place_init
	dc.l 0				; (food merchant)
	dc.l MerchOBJC_place_init
	dc.l MerchTRANS_place_init		; Transport merchants
	dc.l MerchTRANS_place_init
	dc.l MerchTRANS_place_init
	dc.l Blacksmith_place_init

; [ Go back to the previous position on the map ]
; All registers are restored
; NOTE :
;   - Like [ Restore_coordinates ] (MAP/MAP.S).
Restore_coordinates:
	move.w	Old_Xcoord,Map_Xcoord
	move.w	Old_Ycoord,Map_Ycoord
	jsr	World_evaluate
	jmp	Recalc_mapbuf_coords

;*****************************************************************************
; [ General place screen ]
;*****************************************************************************
; [ Enter a place ]
;   IN : a0 - Pointer to control icon list (as in PLACES.S) (.l)
; All registers are restored
; NOTE :
;   - From [ Places_ModInit ] and [ Places_DisInit ].
Enter_place:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,Place_CIL_ptr
	sf	Place_exit
	sf	Price_ghost
	sf	Sold_shown
	move.l	#Sold_slots,Slot_base
	clr.w	Current_gold
	move.w	#Active_member,Victim_member
	lea.l	Sold_slots,a1		; Clear sold slots
	move.w	#Max_sold*Object_packet_size/2-1,d7
.Clear:	clr.w	(a1)+
	dbra	d7,.Clear
	move.w	Current_place_type,d7	; Get place type
	cmp.w	#Trainer_place,d7		; Trainer ?
	bne.s	.No1
	move.l	Place_ptr,a1		; Get trainer picture
	move.w	Trainer_skill_nr(a1),d0
	move.b	Trainer_pictures(pc,d0.w),d0
	bra.s	.Do1
.No1:	move.b	Place_pictures(pc,d7.w),d0	; Get place picture
.Do1:	ext.w	d0
	move.w	d0,d1
	jsr	Pool_gold			; Pool gold
	move.w	d0,Current_gold
	move.w	d1,d0
	jsr	Show_lay3			; Build screen
	jsr	Place_CIL_evaluate
	jsr	Print_place_name
	jsr	Update_place_gold
	jsr	Update_status_bars
	jsr	Copy_screen_to_both
	move.w	Current_place_type,d7	; Get entrance text
	cmp.w	#Trainer_place,d7
	bne.s	.No2
	move.l	Place_ptr,a1
	move.w	Trainer_skill_nr(a1),d0
	add.w	d0,d0
	move.w	Trainer_enter_texts(pc,d0.w),d0
	bra.s	.Do2
.No2:	add.w	d7,d7
	move.w	Place_enter_texts-2(pc,d7.w),d0
.Do2:	jsr	Do_prompt			; Print entrance text
	jsr	Place_loop		; Do
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; Places pictures (Place_pictures in PLACES.S, only Lyramion)
Place_pictures:
	dc.b 0,Healer_pic,Sage_pic,Enchantress_pic
	dc.b Inn_pic,Object_merchant_pic,Object_merchant_pic,Librarian_pic
	dc.b Ship_merchant_pic,Ship_merchant_pic,Horse_merchant_pic
	dc.b Sage_pic
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

; [ Print the name of the place ]
; All registers are restored
Print_place_name:
	movem.l	d0-d2/a0/a1,-(sp)
	lea.l	Places_data,a0		; Get name
	move.w	(a0)+,d0
	mulu.w	#Place_data_size,d0
	add.l	d0,a0
	move.w	Current_place_nr,d0
	subq.w	#1,d0
	mulu.w	#Place_string_length,d0
	add.l	d0,a0
	lea.l	Place_name,a1		; Copy (29 characters)
	moveq.l	#Place_string_length-2,d0
.Copy:	move.b	(a0)+,(a1)+
	dbeq	d0,.Copy
	clr.b	(a1)
	move.w	#White,Ink_colour		; Print
	move.w	#Default_shadow,Shadow_colour
	move.w	#Place_name_X,d0
	moveq.l	#Place_name_Y,d1
	move.w	#194,d2
	lea.l	Place_name,a0
	jsr	Print_centered_string
	movem.l	(sp)+,d0-d2/a0/a1
	rts

; [ Show the pooled gold ]
; All registers are restored
Update_place_gold:
	movem.l	d1/d5-d7,-(sp)
	move.w	#Gold_X,d7
	move.w	#Goldfood_Y,d1
	move.w	Current_gold,d5
	moveq.l	#Gold_txt,d6
	jsr	Goldfood_box
	movem.l	(sp)+,d1/d5-d7
	rts

; [ Evaluate & show the control icons of the place ]
; All registers are restored
; NOTE :
;   - Like [ Display_control_icons ] with the evaluation routine.
Place_CIL_evaluate:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Place_CIL_ptr,a1		; Copy icons
	lea.l	Place_CIL_work,a0
	moveq.l	#9-1,d7
.Loop:	move.w	(a1)+,(a0)+
	dbra	d7,.Loop
	lea.l	9*4(a1),a1		; Evaluate
	move.l	(a1),d0
	beq.s	.Show
	move.l	d0,a1
	lea.l	Place_CIL_work,a0
	jsr	(a1)
.Show:	lea.l	Place_CIL_work,a0		; Show
	jsr	Display_CIL
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Place input loop ]
; All registers are restored
; NOTE :
;   - Like the place modules : control icons, the bought items (which are
;     taken like the items of a chest) and the healer's patient.
;*****************************************************************************
Place_loop:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Show_sold_items
	jsr	Copy_screen_to_both
.Loop:	tst.b	Place_exit		; Leave ?
	bne	.Exit
	clr.l	Ghost_text		; Names of the bought items
	tst.b	Sold_shown
	beq.s	.No_ghost
	jsr	Update_ghost
.No_ghost:	jsr	Update_status
	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC ?
	bne.s	.No_esc
	tst.b	Moving_flag		; Moving ?
	beq.s	.Leave
	jsr	Chest_move_aborted
	bra.s	.Loop
.Leave:	moveq.l	#3-1,d0			; Exit
	bra	.Do
.No_esc:	cmp.w	#$3b,d0			; F1...F6 ?
	bmi.s	.No_key
	cmp.w	#$40+1,d0
	bpl.s	.No_key
	subi.w	#$3b-1,d0
	jsr	Place_member_selected
	bra.s	.Loop
.No_key:	jsr	Read_mouse_clicks
	move.w	d0,d6
	beq.s	.Loop
	jsr	Find_inventory_object
	move.w	d0,d1
	lsr.w	#8,d1
	andi.w	#$00ff,d0
	btst	#Right_pressed,d6		; Right button ?
	beq.s	.Left
	tst.b	Moving_flag
	beq.s	.Loop
	jsr	Chest_move_aborted
	bra	.Loop
.Left:	btst	#Left_pressed,d6
	beq	.Loop
	tst.b	Moving_flag		; Moving ?
	bne	.Moving
	cmp.w	#Obj_member,d1		; Portrait ?
	bne.s	.No_member
	jsr	Place_member_selected
	bra	.Loop
.No_member:	tst.b	Sold_shown		; Bought items shown ?
	beq.s	.No_slot
	cmp.w	#Obj_scroll_bar,d1		; Scroll bar ?
	bne.s	.No_bar
	jsr	Scroll_bar_pressed
	bra	.Loop
.No_bar:	cmp.w	#Obj_backpack,d1		; Slot ?
	bne.s	.No_slot
	jsr	Take_chest_item
	bra	.Loop
.No_slot:	cmp.w	#Obj_icon,d1		; Control icon ?
	bne	.Loop
	subq.w	#1,d0			; Possible ?
	bmi	.Loop
	lea.l	Place_CIL_work,a0
	move.w	d0,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d1
	beq	.Loop
	bmi	.Loop
	cmp.w	#3-1,d0			; Exit ?
	bne.s	.Do
	jsr	Press_exit_icon
.Do:	move.l	Place_CIL_ptr,a0		; Execute
	lsl.w	#2,d0
	move.l	9*2(a0,d0.w),d0
	beq	.Loop
	move.l	d0,a0
	jsr	(a0)
	tst.b	Place_exit		; Leave ?
	bne.s	.Exit
	jsr	Place_CIL_evaluate		; Update
	jsr	Update_place_gold
	jsr	Show_sold_items
	jsr	Copy_screen_to_both
	bra	.Loop
.Moving:	cmp.w	#Obj_member,d1		; Portrait ?
	bne.s	.No_member2
	jsr	Chest_member_moved
	bra.s	.Check
.No_member2:	cmp.w	#Obj_backpack,d1		; Slot ?
	bne	.Loop
	jsr	Chest_item_moved
.Check:	jsr	Update_status_bars
	jsr	Show_sold_items
	jsr	Place_CIL_evaluate
	jsr	Copy_screen_to_both
	bra	.Loop
.Exit:	jsr	Hide_victim		; Leave
	moveq.l	#1,d0
	jsr	Close_lay3
	tst.b	Inn_flag			; Go to camp ?
	beq.s	.Done
	jsr	Camp_screen
.Done:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ A party member was selected (portrait or F1...F6) ]
;   IN : d0 - Member number {1...6} (.w)
; All registers are restored
Place_member_selected:
	cmp.w	#Healer_place,Current_place_type	; Healer ?
	bne.s	.Exit
	jmp	Healer_member_left
.Exit:	rts

; [ Show the bought items (if any) ]
; All registers are restored
; NOTE :
;   - Like [ Reset_sold_scroll_bar ].
Show_sold_items:
	movem.l	d0/a0,-(sp)
	lea.l	Sold_slots,a0		; Any ?
	jsr	Check_slots_empty
	beq.s	.Empty
	st	Sold_shown		; Yes -> show
	move.l	#Sold_slots,Slot_base
	move.l	#Lay3_bar,SB_ptr
	move.w	Scroll_bar_result,d0
	jsr	Set_scroll_row
	bra.s	.Exit
.Empty:	tst.b	Sold_shown		; No -> hide
	beq.s	.Exit
	sf	Sold_shown
	jsr	Hide_Lay3_objects
.Exit:	movem.l	(sp)+,d0/a0
	rts

; [ Check if 24 object slots are empty ]
;   IN : a0 - Pointer to slots (.l)
;  OUT : eq - Empty, ne - Not empty
; All registers are restored
Check_slots_empty:
	movem.l	d7/a0,-(sp)
	moveq.l	#Items_per_chest-1,d7
.Loop:	tst.w	Object_index(a0)
	bne.s	.Exit
	addq.l	#Object_packet_size,a0
	dbra	d7,.Loop
	moveq.l	#0,d7
.Exit:	movem.l	(sp)+,d7/a0
	rts

; [ Check if 24 object slots are full ]
;   IN : a0 - Pointer to slots (.l)
;  OUT : eq - Full, ne - Not full
; All registers are restored
Check_slots_full:
	movem.l	d7/a0,-(sp)
	moveq.l	#Items_per_chest-1,d7
.Loop:	tst.w	Object_index(a0)
	beq.s	.Free
	addq.l	#Object_packet_size,a0
	dbra	d7,.Loop
	moveq.l	#0,d7			; (eq)
	bra.s	.Exit
.Free:	moveq.l	#1,d7			; (ne)
.Exit:	movem.l	(sp)+,d7/a0
	rts

; [ Anything in the backpack of the active member ? ]
;  OUT : ne - Yes, eq - No
; All registers are restored
Check_active_backpack:
	movem.l	d7/a0/a1,-(sp)
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	lea.l	Char_inventory+Backpack_slots(a1),a0
	moveq.l	#Items_per_char-1,d7
.Loop:	tst.w	Object_index(a0)
	bne.s	.Exit
	addq.l	#Object_packet_size,a0
	dbra	d7,.Loop
	moveq.l	#0,d7
.Exit:	movem.l	(sp)+,d7/a0/a1
	rts

; [ Select an item of the active member's backpack ]
;   IN : d0 - Prompt (.w)
;  OUT : d0 - Backpack slot {0...23} / -1 (.w)
;        a2 - Pointer to the packet (.l)
; Changed registers : d0,a2
Select_backpack_item:
	movem.l	d1/d7/a1,-(sp)
	move.l	d0,-(sp)
	moveq.l	#Active_member,d7		; Show backpack
	jsr	Get_char_data
	lea.l	Char_inventory+Backpack_slots(a1),a1
	move.l	a1,Slot_base
	move.l	#Lay3_bar,SB_ptr
	moveq.l	#0,d0
	jsr	Set_scroll_row
	move.l	(sp)+,d0
	moveq.l	#0,d1
	jsr	Select_slot_item
	movem.l	(sp)+,d1/d7/a1
	rts

; [ Select an item of the slots at [ Slot_base ] ]
;   IN : d0 - Prompt (.w)
;  OUT : d0 - Slot {0...23} / -1 (.w)
;        a2 - Pointer to the packet (.l)
; Changed registers : d0,a2
Select_slot_item:
	move.l	a0,-(sp)
	moveq.l	#0,d1
	jsr	Select_item
	subi.w	#9+1,d0			; Anything ?
	bmi.s	.Exit
	move.l	d0,-(sp)
	addi.w	#9+1,d0
	jsr	Get_slot_packet
	move.l	a0,a2
	move.l	(sp)+,d0
.Exit:	move.l	(sp)+,a0
	tst.w	d0
	rts

;*****************************************************************************
; [ Exit a place ]
; NOTE :
;   - From [ Exit_PLACES ] (PLACES.S).
;*****************************************************************************
Exit_PLACES:
	movem.l	d0-d3/a0,-(sp)
	lea.l	Current_gold,a0		; Divide gold
	moveq.l	#Gold_weight,d2
	moveq.l	#Gold_coins,d3
	jsr	Divide
	jsr	Update_place_gold		; Show
	jsr	Update_status_bars
	jsr	Copy_screen_to_both
	tst.w	Current_gold		; Any left ?
	beq.s	.Leave
	move.w	#139,d0			; Yes -> Leave ?
	jsr	Ask_yes_no
	tst.w	d0
	bne.s	.Leave
	jsr	Pool_gold			; No -> Pool again
	add.w	d0,Current_gold
	bra.s	.Exit
.Leave:	st	Place_exit		; Leave
.Exit:	movem.l	(sp)+,d0-d3/a0
	rts

;*****************************************************************************
; [ Pool gold ]
;  OUT : d0 - Number of gold coins (.w)
; Changed registers : d0
; NOTE :
;   - From MAIN.S.
;*****************************************************************************
Pool_gold:
	movem.l	d1/d2/d6/d7/a1,-(sp)
	move.w	#Special_race_mask,d2
	moveq.l	#0,d6
	moveq.l	#1,d7
.Loop:	jsr	Get_char_data
	move.b	Char_race(a1),d0		; Special or monster ?
	btst	d0,d2
	bne.s	.Next
	move.w	#Alive_mask,d0		; Alive ?
	and.w	Body_conditions(a1),d0
	bne.s	.Next
	tst.b	Secret_inventory(a1)	; Secretive ?
	bne.s	.Next
	moveq.l	#0,d0			; Add to pooled amount
	move.w	Gold_coins(a1),d0
	add.l	d0,d6
	cmp.l	#32767,d6			; Too much ?
	bmi.s	.No
	sub.l	d0,d6			; Yes -> clip
	subi.l	#32767,d6
	neg.l	d6
	move.w	d6,d0
	move.l	#32767,d6
	moveq.l	#6,d7			; (end of loop)
.No:	sub.w	d0,Gold_coins(a1)		; Remove gold
	mulu.w	#Gold_weight,d0		; Remove weight
	sub.l	d0,Weight_normal(a1)
.Next:	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	move.w	d6,d0			; Output
	movem.l	(sp)+,d1/d2/d6/d7/a1
	rts

;*****************************************************************************
; [ Buy / sell requester ]
;   IN : d0 - Prompt (message number) (.w)
;        d1 - Amount of gold (.w)
;  OUT : d0 - 1 = Yes, 0 = No (.w)
; Changed registers : d0
; NOTE :
;   - From [ BuySell_req ] (PLACES.S) : the prompt and "{0} GP. Agree?".
;*****************************************************************************
BuySell_req:
	movem.l	d1-d7/a0-a2,-(sp)
	addi.w	#Messages,d0		; Make text
	jsr	Get_text
	lea.l	Format_buffer,a1
.Copy:	move.b	(a0)+,(a1)+
	bne.s	.Copy
	subq.l	#1,a1
	moveq.l	#0,d0			; Convert number
	move.w	d1,d0
	lea.l	Number,a0
	moveq.l	#5,d7
	jsr	DecL_convert
	lea.l	Number,a0			; Insert "{0} GP. Agree?"
	move.l	a0,Format_args
	move.w	#Gp_agree_txt,d0
	jsr	Format_text
	lea.l	Format_buffer,a0		; Print
	jsr	Print_PA_text
	move.w	#BSReq_X-1,d0		; Draw box around icons
	move.w	#BSReq_Y-1,d1
	moveq.l	#64,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box
	move.w	#BSReq_X,d0		; Display YES & NO icons
	move.w	#BSReq_Y,d1
	moveq.l	#Yes_cicon,d3
	jsr	Display_up_button
	addi.w	#32,d0
	moveq.l	#No_cicon,d3
	jsr	Display_up_button
	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
; ---------- Wait for the answer ------------------
	moveq.l	#0,d4
.Loop:	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC = No
	beq.s	.Done
	jsr	Read_mouse_clicks
	btst	#Right_pressed,d0		; Right = No
	bne.s	.Done
	btst	#Left_pressed,d0
	beq.s	.Loop
	move.w	Mouse_Y,d1		; On the icons ?
	subi.w	#BSReq_Y,d1
	bmi.s	.Loop
	cmp.w	#17,d1
	bpl.s	.Loop
	move.w	Mouse_X,d0
	subi.w	#BSReq_X,d0
	bmi.s	.Loop
	cmp.w	#64,d0
	bpl.s	.Loop
	lsr.w	#5,d0			; 0 = Yes, 1 = No
	moveq.l	#Yes_cicon,d3
	tst.w	d0
	beq.s	.Yes
	moveq.l	#No_cicon,d3
.Yes:	seq	d4
	andi.w	#1,d4
	lsl.w	#5,d0			; Feedback
	addi.w	#BSReq_X,d0
	move.w	#BSReq_Y,d1
	jsr	Display_down_button
	jsr	Copy_screen_to_both
.Wait:	jsr	Switch_screens
	btst	#Left_pressed,Mouse_buttons
	bne.s	.Wait
.Done:	jsr	Erase_PA
	jsr	Copy_screen_to_both
	move.w	d4,d0
	movem.l	(sp)+,d1-d7/a0-a2
	rts

;*****************************************************************************
; [ Format a text ]
;   IN : d0 - Number of the format text (.w)
;        a1 - Pointer to the output (.l)
;        [ Format_args ] - Pointers to the strings for {0}, {1}, {2} (.l)
;  OUT : a1 - Pointer to the end of the output (EOL) (.l)
; Changed registers : a1
; NOTE :
;   - Like [ Display_text ] with a text list.
;*****************************************************************************
Format_text:
	movem.l	d0/a0/a2,-(sp)
	addi.w	#Format_messages,d0
	jsr	Get_text
.Loop:	move.b	(a0)+,d0
	beq.s	.End
	cmp.b	#'{',d0			; Argument ?
	bne.s	.Store
	moveq.l	#0,d0
	move.b	(a0)+,d0
	subi.b	#'0',d0
	addq.l	#1,a0			; (skip })
	lsl.w	#2,d0
	lea.l	Format_args,a2
	move.l	0(a2,d0.w),a2
.Insert:	move.b	(a2)+,(a1)+
	bne.s	.Insert
	subq.l	#1,a1
	bra.s	.Loop
.Store:	move.b	d0,(a1)+
	bra.s	.Loop
.End:	clr.b	(a1)
	movem.l	(sp)+,d0/a0/a2
	rts

;*****************************************************************************
; [ Trainer ]
; NOTE :
;   - From PLACES.S.
;*****************************************************************************
Trainer_place_init:
	move.l	Place_ptr,a0
	move.w	Trainer_price(a0),Total_price
	lea.l	Trainer_CIL,a0
	jmp	Enter_place

; Get the skill of the active member in a1
Trainer_skill:
	move.l	d7,-(sp)
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	move.l	Place_ptr,a0
	move.w	Trainer_skill_nr(a0),d7
	mulu.w	#Skill_data_size,d7
	lea.l	Skills(a1,d7.w),a0
	move.l	(sp)+,d7
	rts

Trainer_CIL_evaluate:
	move.l	a0,-(sp)
	jsr	Trainer_skill
	move.w	Maximum(a0),d1		; Can be trained ?
	cmp.w	(a0),d1
	move.l	(sp)+,a0
	bgt.s	.Ok
	bset	#7,6(a0)			; Disable {Train skill}
.Ok:	rts

Train_skill:
	jsr	Trainer_skill		; (a0 = skill, a1 = member)
; ---------- Any training points ? ----------------
	tst.w	Nr_training_points(a1)
	bne.s	.Ok0
	move.w	#181,d0			; Fool !
	jmp	Do_prompt
; ---------- Enough money ? -----------------------
.Ok0:	move.w	Current_gold,d0
	cmp.w	Total_price,d0
	bcc.s	.Ok1
	move.w	#150,d0			; Fool !
	jmp	Do_prompt
; ---------- How many percent ? -------------------
.Ok1:	moveq.l	#0,d1			; Calculate maximum
	move.w	Maximum(a0),d1
	sub.w	(a0),d1
	moveq.l	#0,d0			; How many can you buy ?
	move.w	Current_gold,d0
	divu.w	Total_price,d0
	cmp.w	d1,d0			; Too much ?
	bmi.s	.Not
	move.w	d1,d0
.Not:	cmp.w	Nr_training_points(a1),d0	; Enough training points ?
	bls.s	.Ok3
	move.w	Nr_training_points(a1),d0
.Ok3:	moveq.l	#0,d1
	move.w	d0,d1
	move.w	#179,d0			; How many do you want ?
	moveq.l	#0,d2
	jsr	Input_number
	move.l	d0,d5
	beq.s	.Exit			; Any ?
; ---------- Sure ? -------------------------------
	move.w	d5,d1
	mulu.w	Total_price,d1
	move.w	#180,d0
	jsr	BuySell_req
	tst.w	d0			; Yes ?
	beq.s	.Exit
; ---------- Train --------------------------------
	jsr	Trainer_skill
	sub.w	d1,Current_gold		; Remove gold
	add.w	d5,(a0)			; Increase skill
	sub.w	d5,Nr_training_points(a1)	; Decrease training points
	move.w	#182,d0			; "Yay!"
	jsr	Do_prompt
.Exit:	rts

;*****************************************************************************
; [ Healer ]
; NOTE :
;   - From PLACES.S. The patient is chosen by clicking on the portrait (or
;     F1...F6), the ankh is shown on the portrait.
;*****************************************************************************
Healer_place_init:
	lea.l	Healer_CIL,a0
	jmp	Enter_place

; [ Get the patient's data in a1 ]
Get_victim:
	move.l	d7,-(sp)
	move.w	Victim_member,d7
	jsr	Get_char_data
	move.l	(sp)+,d7
	rts

Healer_CIL_evaluate:
	jsr	Show_victim
	jsr	Get_victim
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
	moveq.l	#9-1,d7
.Loop:	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Next
	move.l	a1,-(sp)
	jsr	Get_item_data
	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed ?
	move.l	(sp)+,a1
	bne.s	.Ok3
.Next:	addq.l	#Object_packet_size,a2	; Next slot
	dbra	d7,.Loop
	bset	#7,6(a0)			; Disable {Heal cursed}
; ---------- Heal condition -----------------------
.Ok3:	move.w	Body_conditions(a1),d0
	andi.w	#Healable_mask,d0
	bne.s	.Ok4
	bset	#7,12(a0)			; Disable {Heal conditions}
.Ok4:	rts

; [ Show the ankh on the patient's portrait (both screens) ]
Show_victim:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	move.w	Victim_member,d0		; Calculate X-coordinate
	subq.w	#1,d0
	mulu.w	#48,d0
	addi.w	#16,d0
	moveq.l	#1,d1
	moveq.l	#2,d6
	moveq.l	#29,d7
	lea.l	Ankh_symbol,a0
	jsr	Put_masked_block
	jsr	Switch_screens
	jsr	Put_masked_block
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

; [ Remove the ankh ]
Hide_victim:
	cmp.w	#Healer_place,Current_place_type	; Healer ?
	bne.s	.Exit
	move.l	d7,-(sp)
	move.w	Victim_member,d7
	jsr	Redraw_member
	jsr	Switch_screens
	jsr	Redraw_member
	move.l	(sp)+,d7
.Exit:	rts

; [ Choose another patient ]
;   IN : d0 - Member number {1...6} (.w)
Healer_member_left:
	cmp.w	Victim_member,d0		; Same ?
	beq.s	.Exit
	jsr	Hide_victim		; Restore old
	move.w	d0,Victim_member		; Set new
	jsr	Place_CIL_evaluate		; (shows the ankh)
	jsr	Copy_screen_to_both
.Exit:	rts

; ********** Healer - Heal LP *********************
Heal_LP:
	move.l	Place_ptr,a0		; Get price
	move.w	Heal_LP_price(a0),Total_price
	move.w	Current_gold,d0		; Enough money ?
	cmp.w	Total_price,d0
	bcc.s	.Ok
	move.w	#150,d0			; Fool !
	jmp	Do_prompt
.Ok:	jsr	Get_victim		; How many LP ?
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
.Not:	moveq.l	#0,d1
	move.w	d0,d1
	move.w	#172,d0			; How many do you want ?
	moveq.l	#0,d2
	jsr	Input_number
	move.l	d0,d5
	beq.s	.Exit			; Any ?
	move.w	d5,d1			; Sure ?
	mulu.w	Total_price,d1
	move.w	#173,d0
	jsr	BuySell_req
	tst.w	d0
	beq.s	.Exit
	st	Success
	sub.w	d1,Current_gold		; Remove gold
	jsr	Get_victim		; Heal
	add.w	d5,Life_points(a1)
	move.l	d7,-(sp)
	move.w	Victim_member,d7
	jsr	Force_status_update
	move.l	(sp)+,d7
.Exit:	rts

; ********** Healer - Heal cursed items ***********
Heal_cursed_items:
	move.l	Place_ptr,a0		; Get price
	move.w	Remove_curse_price(a0),Total_price
	move.w	Current_gold,d0		; Enough money ?
	cmp.w	Total_price,d0
	bcc.s	.Ok
	move.w	#150,d0			; Fool !
	jmp	Do_prompt
.Ok:	move.w	#178,d0			; Sure ?
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.w	d0
	beq.s	.Exit
	sub.w	d1,Current_gold		; Remove gold
	st	Success
	jsr	Get_victim		; Destroy cursed objects
	move.l	a1,a0
	lea.l	Char_inventory(a0),a2
	moveq.l	#1,d2
.Loop:	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Next
	jsr	Get_item_data
	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed ?
	beq.s	.Next
	moveq.l	#1,d3			; Remove
	jsr	Remove_item
.Next:	addq.l	#Object_packet_size,a2
	addq.w	#1,d2
	cmp.w	#9+1,d2
	bmi.s	.Loop
	move.l	d7,-(sp)
	move.w	Victim_member,d7
	jsr	Force_status_update
	move.l	(sp)+,d7
.Exit:	rts

; ********** Healer - Heal condition **************
Heal_condition:
.Repeat:	lea.l	Sold_slots,a0		; Create fake objects
	move.w	#Max_sold*Object_packet_size/2-1,d7
.Clear:	clr.w	(a0)+
	dbra	d7,.Clear
	jsr	Get_victim		; Get conditions
	move.w	Body_conditions(a1),d0
	lea.l	Sold_slots,a0
	lea.l	Condition_object_index_table,a1
	moveq.l	#0,d1
	moveq.l	#0,d7
.Loop:	btst	d7,d0			; Condition set ?
	beq.s	.Next
	tst.b	(a1)			; (healable)
	beq.s	.Next
	move.b	#1,Quantity(a0)		; Create object
	move.b	(a1),Object_index+1(a0)
	move.b	d7,Charges(a0)		; !!!
	addq.l	#Object_packet_size,a0	; Next object
	addq.w	#1,d1
.Next:	addq.l	#1,a1			; Next condition
	addq.w	#1,d7
	cmp.w	#16,d7
	bmi.s	.Loop
	tst.w	d1			; ANY conditions ?
	beq	.Exit
; ---------- Which condition ? --------------------
	move.l	#Sold_slots,Slot_base	; Show
	move.l	#Lay3_bar,SB_ptr
	moveq.l	#0,d0
	jsr	Set_scroll_row
	move.w	#174,d0			; Select condition
	jsr	Select_slot_item
	bmi	.Exit
	moveq.l	#0,d5			; Get condition
	move.b	Charges(a2),d5
	lea.l	Healer_condition_table,a0	; Get price
	moveq.l	#0,d1
	move.b	0(a0,d5.w),d1
	move.l	Place_ptr,a0
	move.w	0(a0,d1.w),Total_price
	move.w	Current_gold,d0		; Enough money ?
	cmp.w	Total_price,d0
	bcc.s	.Ok
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra	.Repeat
.Ok:	move.w	#177,d0			; Sure ?
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.w	d0
	beq	.Repeat
	st	Success
	sub.w	d1,Current_gold		; Remove gold
	jsr	Update_place_gold
	jsr	Get_victim		; Heal
	move.w	Body_conditions(a1),d0
	bclr	d5,d0
; ---------- Resurrecting ? -----------------------
	cmp.w	#Dust,d5			; Dust ?
	bne.s	.No_dust
	bset	#Ashes,d0			; Yes -> Turn to ashes
	bra.s	.Store
.No_dust:	cmp.w	#Ashes,d5			; Ashes ?
	bne.s	.Store
	bset	#Dead,d0			; Yes -> Turn to dead
.Store:	move.w	d0,Body_conditions(a1)
	move.l	d7,-(sp)
	move.w	Victim_member,d7
	jsr	Redraw_member		; Show
	jsr	Switch_screens
	jsr	Redraw_member
	jsr	Show_victim
	move.l	(sp)+,d7
	cmp.w	#Dead,d5			; Resurrected ?
	bne	.Repeat
	move.w	Victim_member,Subject_member	; "Yay!"
	moveq.l	#57,d0
	jsr	Do_prompt
	bra	.Repeat
.Exit:	jsr	Hide_Lay3_objects		; Hide slots
	rts

;*****************************************************************************
; [ Sage ]
; NOTE :
;   - From PLACES.S.
;*****************************************************************************
Sage_place_init:
	move.l	Place_ptr,a0
	move.w	Sage_price(a0),Total_price
	lea.l	Sage_CIL,a0
	jmp	Enter_place

; ********** Sage - Examine body item *************
Examine_body_item:
	move.w	Current_gold,d0		; Enough money ?
	cmp.w	Total_price,d0
	bcc.s	.Ok
	move.w	#150,d0			; Fool !
	jmp	Do_prompt
.Ok:	moveq.l	#Active_member,d7		; Fake twelve slots
	jsr	Get_char_data
	lea.l	Char_inventory(a1),a0
	lea.l	Sold_slots,a1
	move.w	#Max_sold*Object_packet_size/2-1,d7
.Clear:	clr.w	(a1)+
	dbra	d7,.Clear
	lea.l	Sold_slots,a1
	moveq.l	#9*Object_packet_size/2-1,d7
.Copy:	move.w	(a0)+,(a1)+
	dbra	d7,.Copy
	move.l	#Sold_slots,Slot_base
	move.l	#Lay3_bar,SB_ptr
	moveq.l	#0,d0
	jsr	Set_scroll_row
	move.w	#169,d0			; Which item ?
	jsr	Select_slot_item
	bmi.s	.Exit
	jsr	Do_examine		; Yes -> Do
.Exit:	jmp	Hide_Lay3_objects

; ********** Sage - Examine backpack item *********
Examine_backpack_item:
	move.w	Current_gold,d0		; Enough money ?
	cmp.w	Total_price,d0
	bcc.s	.Ok
	move.w	#150,d0			; Fool !
	jmp	Do_prompt
.Ok:	move.w	#169,d0			; Which item ?
	jsr	Select_backpack_item
	bmi.s	.Exit
	addi.w	#9,d0
	jsr	Do_examine
.Exit:	jmp	Hide_Lay3_objects

; [ Examine object ]
;   IN : d0 - Slot index {0...32} of the active member (.w)
Do_examine:
	moveq.l	#Active_member,d7		; Get packet
	jsr	Get_char_data
	lea.l	Char_inventory(a1),a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	btst	#Magic_check,Item_bits_DYNAMIC(a2)	; Already examined ?
	beq.s	.Ok1
	move.w	#170,d0			; Fool !
	jmp	Do_prompt
.Ok1:	move.w	#171,d0			; Are you sure ?
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.w	d0
	beq.s	.Exit
	sub.w	d1,Current_gold		; Remove gold
	st	Success
	bset	#Magic_check,Item_bits_DYNAMIC(a2)	; Examined !
	lea.l	Inter_packet,a0		; Show 'em
	Copy_packet a2,a0
	jsr	Show_item_view
.Exit:	rts

;*****************************************************************************
; [ Inn ]
; NOTE :
;   - From PLACES.S.
;*****************************************************************************
Inn_place_init:
	sf	Room_rented
	sf	Inn_flag
	move.l	Place_ptr,a0		; Get price for one room
	move.w	Inn_price(a0),d1
	jsr	Count_members		; Calculate total price
	mulu.w	d1,d0
	move.w	d0,Total_price
	lea.l	Inn_CIL,a0
	jmp	Enter_place

Inn_CIL_evaluate:
	tst.b	Room_rented		; Already rented ?
	beq.s	.Ok
	bset	#7,6(a0)			; Disable {Guestroom}
.Ok:	rts

; [ Count the members who are alive ]
;  OUT : d0 - Number (.w)
; Changed registers : d0
Count_members:
	movem.l	d1/d7/a1,-(sp)
	moveq.l	#0,d0
	moveq.l	#1,d7
.Loop:	jsr	Get_char_data
	move.w	#Alive_mask,d1
	and.w	Body_conditions(a1),d1
	bne.s	.Next
	addq.w	#1,d0
.Next:	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d1/d7/a1
	rts

; ********** Inn - Rent a room ********************
Guestroom:
	move.w	Current_gold,d0		; Enough money ?
	cmp.w	Total_price,d0
	bcc.s	.Ok
	move.w	#150,d0			; "Fool !"
	jmp	Do_prompt
.Ok:	move.w	#151,d0			; Are you sure ?
	move.w	Total_price,d1
	jsr	BuySell_req
	tst.w	d0
	beq.s	.Exit
	st	Success
	move.w	Total_price,d0		; Remove gold
	sub.w	d0,Current_gold
	jsr	Update_place_gold
	st	Inn_flag			; Camp
	st	Room_rented
	moveq.l	#0,d0			; Get sold text number
	move.b	Current_event_data+Event_b5,d0
	cmp.b	#-1,d0			; Any ?
	beq.s	.None
	jsr	Lay3_text			; Yes -> Show
	bra.s	.Skip
.None:	move.w	#281,d0			; "Have fun !"
	jsr	Do_prompt
.Skip:	move.l	Place_ptr,a0		; Set destination
	lea.l	Inn_destination,a1
	move.w	Inn_X(a0),(a1)+
	move.w	Inn_Y(a0),(a1)+
	move.w	Inn_map_nr(a0),(a1)
	move.w	Inn_heal_percentage(a0),Current_inn_value
	jsr	Exit_PLACES		; Do
	tst.b	Place_exit		; Left ?
	bne.s	.Exit
	sf	Inn_flag			; No
	sf	Room_rented
.Exit:	rts

;*****************************************************************************
; [ Object / magic merchant ]
; NOTE :
;   - From PLACES.S. The merchant data stays in memory (MERCHANT.BIN).
;*****************************************************************************
MerchOBJC_place_init:
	move.w	Current_event_data+Event_w8,d0	; Get merchant data
	mulu.w	#Items_per_chest*Object_packet_size,d0
	lea.l	Merchants,a0
	add.l	d0,a0
	move.l	a0,Merchant_ptr
	lea.l	MerchOBJC_CIL,a0
	jmp	Enter_place

MerchOBJC_CIL_evaluate:
	move.l	a0,a1
; ---------- Can one view an object ? -------------
	move.l	Merchant_ptr,a0		; Well ?
	jsr	Check_slots_empty
	bne.s	.Ok1
	bset	#7,(a1)			; Disable {Buy item}
	bset	#7,8(a1)			; Disable {View item}
	bra.s	.Not_MT1
; ---------- Can one buy an object ? --------------
.Ok1:	tst.w	Current_gold		; Any gold ?
	beq.s	.Off1
	lea.l	Sold_slots,a0		; Any slots free ?
	jsr	Check_slots_full
	bne.s	.Not_MT1
.Off1:	bset	#7,(a1)			; Disable {Buy item}
; ---------- Can one sell an object ? -------------
.Not_MT1:	cmp.w	#Magic_place,Current_place_type	; Magic ?
	beq.s	.Off2
	jsr	Check_active_backpack	; Anything to sell ?
	bne.s	.Not_MT2
.Off2:	bset	#7,6(a1)			; Disable {Sell item}
.Not_MT2:	move.l	a1,a0
	rts

; ********** Object merchant - Exit ***************
Exit_MerchOBJC:
	lea.l	Sold_slots,a0		; Any stuff left ?
	jsr	Check_slots_empty
	beq.s	.No
	move.w	#162,d0			; Sure ?
	jsr	Ask_yes_no
	tst.w	d0
	beq.s	.Exit
.No:	jsr	Exit_PLACES		; Normal exit
.Exit:	rts

; ********** Object merchant - Buy item ***********
Buy_item:
	move.l	Merchant_ptr,Slot_base	; Show merchant's items
	move.l	#Lay3_bar,SB_ptr
	moveq.l	#0,d0
	jsr	Set_scroll_row
	st	Price_ghost
	move.w	#146,d0			; Select item
	jsr	Select_slot_item
	sf	Price_ghost
	bmi	.Exit
	move.w	d0,d6			; (slot)
	move.w	Object_index(a2),d0		; Get item data
	jsr	Get_item_data
	move.w	Current_gold,d0		; Affordable ?
	cmp.w	Price(a1),d0
	bcc.s	.Yes
	move.w	#150,d0			; "Go away, bum!"
	jsr	Do_prompt
	bra	.Exit
.Yes:	moveq.l	#1,d5			; Single
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
.Not:	cmp.b	#-1,Quantity(a2)		; Infinite ?
	beq.s	.Ok
	cmp.w	d1,d0			; Can you buy too many ?
	bpl.s	.Ok
	move.w	d0,d1
.Ok:	ext.l	d1			; How many do you want ?
	move.w	#147,d0
	moveq.l	#3,d2
	move.w	Object_index(a2),d3
	jsr	Input_number
	move.l	d0,d5
	beq	.Exit
.Ask:	moveq.l	#0,d1			; Calculate total price
	move.w	Price(a1),d1
	mulu.w	d5,d1
	move.w	d1,Total_price
	move.w	#148,d0			; Are you sure ?
	jsr	BuySell_req
	tst.w	d0
	beq.s	.Exit
	st	Success
	move.w	Total_price,d0		; Take gold
	sub.w	d0,Current_gold
	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	move.b	d5,Quantity(a0)
	lea.l	Sold_slots,a3		; Move to sold slots
	jsr	Auto_move_to_slots
	cmp.b	#-1,Quantity(a2)		; Infinite ?
	beq.s	.Exit
	sub.b	d5,Quantity(a2)		; Remove items
	bgt.s	.Exit
	clr.b	Quantity(a2)
	clr.w	Object_index(a2)
.Exit:	sf	Price_ghost
	clr.l	Ghost_text2
	sf	Sold_shown		; (redraw)
	jmp	Hide_Lay3_objects

; ********** Object merchant - Sell item **********
Sell_item:
	move.l	Merchant_ptr,a0		; Any slots free ?
	jsr	Check_slots_full
	bne.s	.Repeat
	move.w	#145,d0			; No
	jmp	Do_prompt
.Repeat:	move.l	Merchant_ptr,a0		; Any slots free ?
	jsr	Check_slots_full
	beq	.Exit
	move.w	#135,d0			; Select item
	jsr	Select_backpack_item
	bmi	.Exit
	move.w	d0,d6			; (slot)
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Broken ?
	beq.s	.Unbroken
	move.w	#210,d0			; "Go away!"
	jsr	Do_prompt
	bra	.Done
.Unbroken:	move.w	Object_index(a2),d0		; Get item data
	jsr	Get_item_data
	btst	#Droppable,Item_bits_STATIC(a1)	; Can it be sold ?
	beq.s	.Refuse
	cmpi.w	#Minimum_price,Price(a1)	; Too cheap ?
	bgt.s	.Ok
.Refuse:	move.w	#285,d0			; "Begone!"
	jsr	Do_prompt
	bra	.Done
.Ok:	moveq.l	#1,d5			; Single
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple item ?
	beq.s	.Ask
	cmpi.b	#1,Quantity(a2)		; More than one ?
	beq.s	.Ask
	moveq.l	#0,d1			; How much ?
	move.b	Quantity(a2),d1
	move.w	#136,d0
	moveq.l	#3,d2
	move.w	Object_index(a2),d3
	jsr	Input_number
	move.l	d0,d5
	beq	.Done
.Ask:	moveq.l	#0,d1			; Calculate price
	move.w	Price(a1),d1
	divu.w	#3,d1
	andi.l	#$0000ffff,d1
	move.l	a1,a3
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	moveq.l	#0,d2
	move.w	ACharisma(a1),d2
	add.w	ACharisma+Magic(a1),d2
	divu.w	#10,d2
	mulu.w	Price(a3),d2
	divu.w	#100,d2
	andi.l	#$0000ffff,d2
	add.l	d2,d1
	mulu.w	d5,d1			; Calculate total price
	tst.w	d1			; At least 1
	bne.s	.Not_zero
	moveq.l	#1,d1
.Not_zero:	move.w	d1,Total_price
	move.w	#140,d0			; Are you sure ?
	jsr	BuySell_req
	tst.w	d0
	beq.s	.Done
	st	Success
	move.w	Total_price,d0		; Give gold
	add.w	d0,Current_gold
	jsr	Update_place_gold
	lea.l	Inter_packet,a0		; Move to merchant
	Copy_packet a2,a0
	move.b	d5,Quantity(a0)
	move.l	Merchant_ptr,a3
	jsr	Auto_move_to_slots
	moveq.l	#Active_member,d7		; Remove items
	jsr	Get_char_data
	move.l	a1,a0
	move.w	d6,d2
	addi.w	#9+1,d2
	move.w	d5,d3
	jsr	Remove_item
.Done:	jsr	Check_active_backpack	; All gone ?
	bne	.Repeat
.Exit:	sf	Sold_shown		; (redraw)
	jmp	Hide_Lay3_objects

; ********** Object merchant - View item **********
View_item_MOBJC:
	move.l	Merchant_ptr,Slot_base	; Show merchant's items
	move.l	#Lay3_bar,SB_ptr
	moveq.l	#0,d0
	jsr	Set_scroll_row
	st	Price_ghost
	move.w	#149,d0			; Select item
	jsr	Select_slot_item
	sf	Price_ghost
	bmi.s	.Exit
	lea.l	Inter_packet,a0		; Show 'em
	Copy_packet a2,a0
	jsr	Show_item_view
.Exit:	clr.l	Ghost_text2
	sf	Sold_shown		; (redraw)
	jmp	Hide_Lay3_objects

; [ Move items into 24 slots ]
;   IN : a0 - Pointer to source packet (.l)
;        a3 - Pointer to the slots (.l)
; All registers are restored
; NOTE :
;   - Like [ Auto_move_to_merchant ] (PLACES.S) : any item can be put into
;     stacks of up to 99.
Auto_move_to_slots:
	movem.l	d0-d3/d7/a2/a4,-(sp)
	move.l	a0,a2
	move.l	a3,a4			; Scan for slots with this item
	move.w	Object_index(a2),d2
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	moveq.l	#Items_per_chest-1,d7
.Loop1:	move.w	Object_index(a4),d0		; Same item ?
	cmp.w	d2,d0
	bne.s	.Next1
	cmpi.b	#99,Quantity(a4)		; Not full ?
	bcc.s	.Next1			; (also infinite)
	moveq.l	#0,d0			; Does it fit in the slot ?
	move.b	Quantity(a4),d0
	add.w	d3,d0
	cmpi.w	#99,d0
	bls.s	.End
	moveq.l	#99,d0			; Calculate number that will
	sub.b	Quantity(a4),d0		;  fit
	sub.w	d0,d3
	move.b	#99,Quantity(a4)		; Fill slot
	sub.b	d0,Quantity(a2)
.Next1:	addq.l	#Object_packet_size,a4	; Next packet
	dbra	d7,.Loop1
	move.l	a3,a4			; Find free slot
	moveq.l	#Items_per_chest-1,d7
.Loop2:	tst.w	Object_index(a4)
	beq.s	.Do_it
	addq.l	#Object_packet_size,a4
	dbra	d7,.Loop2
	bra.s	.Exit			; (shouldn't occur)
.Do_it:	Copy_packet a2,a4			; Copy packet
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	clr.b	Quantity(a4)
.End:	sub.b	d3,Quantity(a2)		; Transfer
	add.b	d3,Quantity(a4)
.Exit:	tst.b	Quantity(a2)		; All gone ?
	bgt.s	.Skip
	clr.w	Object_index(a2)
.Skip:	movem.l	(sp)+,d0-d3/d7/a2/a4
	rts

;*****************************************************************************
; [ Blacksmith ]
; NOTE :
;   - From PLACES.S.
;*****************************************************************************
Blacksmith_place_init:
	move.l	Place_ptr,a0
	move.w	Blacksmith_price(a0),Total_price
	lea.l	Blacksmith_CIL,a0
	jmp	Enter_place

; ********** Blacksmith - Repair item *************
Repair_item:
	move.w	#209,d0			; Which item ?
	jsr	Select_backpack_item
	bmi.s	.Exit
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Is broken ?
	bne.s	.Ok1
	move.w	#274,d0			; Fool !
	jsr	Do_prompt
	bra.s	.Exit
.Ok1:	move.w	Object_index(a2),d0		; Calculate price
	jsr	Get_item_data
	move.w	Price(a1),d1
	mulu.w	Total_price,d1
	divu.w	#100,d1
	tst.w	d1			; At least one
	bne.s	.Notzero
	moveq.l	#1,d1
.Notzero:	cmp.w	Current_gold,d1		; Enough ?
	bls.s	.Ok2
	move.w	#150,d0			; Fool !
	jsr	Do_prompt
	bra.s	.Exit
.Ok2:	move.w	#275,d0			; Are you sure ?
	jsr	BuySell_req
	tst.w	d0
	beq.s	.Exit
	st	Success
	sub.w	d1,Current_gold		; Remove gold
	bclr	#Broken_item,Item_bits_DYNAMIC(a2)	; Repaired !
.Exit:	jmp	Hide_Lay3_objects

;*****************************************************************************
; [ Show the item in Inter_packet ]
; All registers are restored
; NOTE :
;   - Like the ItemView1 module.
;*****************************************************************************
Show_item_view:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Item_view_window_1
	jsr	Read_mouse_clicks
.Loop:	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC ?
	beq.s	.Close
	jsr	Read_mouse_clicks
	tst.w	d0
	beq.s	.Loop
.Close:	jsr	Close_window
	jsr	Read_mouse_clicks
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Camp ]
; NOTE :
;   - From the camp module (ACTIONS.S), only after renting a room in an inn
;     and only resting.
;*****************************************************************************
Camp_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	sf	Slept
	sf	Place_exit
	moveq.l	#Camp_inn_pic,d0		; Get picture
	tst.b	Inn_flag			; Inn ?
	bne.s	.Pic
	moveq.l	#Camp_wilderness_pic,d0
	btst	#Wilderness_bit,Map_data_buffer+Map_special+1
	bne.s	.Pic
	moveq.l	#Camp_dungeon_pic,d0
.Pic:	move.w	d0,d7
	move.w	Map_Xcoord,Old_Xcoord	; (the party stays here)
	move.w	Map_Ycoord,Old_Ycoord
	move.w	d7,d0			; Show camp
	lea.l	Camp_CIL,a0
	move.l	a0,Place_CIL_ptr
	jsr	Show_lay3
	jsr	Place_CIL_evaluate
	jsr	Copy_screen_to_both
.Loop:	tst.b	Place_exit		; Leave ?
	bne	.Exit
	jsr	Update_status
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
	cmp.w	#3,d0			; Exit ?
	bne.s	.No_exit
	jsr	Press_exit_icon
.Leave:	st	Place_exit
	bra.s	.Loop
.No_exit:	cmp.w	#4,d0			; Learn spell ?
	bne.s	.No_learn
	btst	#7,Camp_CIL+6
	bne.s	.Loop
	jsr	Learn_spell
	jsr	Place_CIL_evaluate
	jsr	Copy_screen_to_both
	bra	.Loop
.No_learn:	cmp.w	#7,d0			; Rest ?
	bne	.Loop
	tst.b	Slept
	bne.s	.Loop
	jsr	Rest
	jsr	Place_CIL_evaluate
	jsr	Copy_screen_to_both
	bra	.Loop
; ---------- Exit camp ----------------------------
.Exit:	tst.b	Inn_flag			; Inn ?
	bne.s	.Inn
	moveq.l	#0,d0			; No -> back to the map
	jsr	Close_lay3
	bra.s	.Return
.Inn:	sf	Inn_flag
	lea.l	Inn_destination,a0		; Set new coordinates
	move.w	(a0)+,Map_Xcoord
	move.w	(a0)+,Map_Ycoord
	move.w	(a0),d0			; Get new map number
	beq.s	.Same			; Same map ?
	cmp.w	Map_nr,d0
	beq.s	.Same
	moveq.l	#0,d1			; (no return)
	move.w	Map_Xcoord,Old_Xcoord
	move.w	Map_Ycoord,Old_Ycoord
	jsr	Close_lay3_to_map		; No -> new map
	jsr	Change_map
	bra.s	.Done
.Same:	move.w	Map_Xcoord,Old_Xcoord	; Yes
	move.w	Map_Ycoord,Old_Ycoord
	moveq.l	#1,d0
	jsr	Close_lay3
.Done:	jsr	After_map_change
.Return:	movem.l	(sp)+,d0-d7/a0-a6
	rts

Camp_CIL_evaluate:
	movem.l	d7/a1,-(sp)
	tst.b	Slept			; Already slept ?
	beq.s	.Ok1
	bset	#7,12(a0)			; Disable {Rest}
.Ok1:	moveq.l	#Active_member,d7		; Any spell classes ?
	jsr	Get_char_data
	tst.b	Spell_class_counter(a1)
	beq.s	.Off
	jsr	Check_active_backpack	; Any items ?
	bne.s	.Exit
.Off:	bset	#7,6(a0)			; Disable {Learn spell}
.Exit:	movem.l	(sp)+,d7/a1
	rts

; ********** Map - Camp ***************************
; NOTE :
;   - From [ Camp ] (ACTIONS.S).
Camp:
	tst.b	Big_brother_flag		; Being watched ?
	beq.s	.No
	moveq.l	#39,d0			; Yes -> "Fool!"
	jmp	Prompt_window
.No:	sf	Inn_flag			; No -> Do
	jmp	Camp_screen

; ********** Camp screen - Learn spell ************
; NOTE :
;   - From [ Learn_spell ] (ACTIONS.S). The scroll simply disappears
;     (the original dissolves or explodes it).
Learn_spell:
	movem.l	d0-d7/a0-a4,-(sp)
.Repeat:	moveq.l	#19,d0			; Select item
	jsr	Select_backpack_item
	bmi	.Exit			; Anything selected ?
	move.w	d0,d6			; Yes
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	move.l	a1,a0
	move.w	Object_index(a2),d0		; Get object data
	jsr	Get_item_data
	cmp.b	#Spellscroll_itemtype,Item_type(a1)	; A scroll ?
	beq.s	.Ok1
	moveq.l	#20,d0			; "Not a scroll"
	bra	.Prompt
.Ok1:	move.b	Spell_class_counter(a0),d0	; Spell class known ?
	move.b	Spell_class(a1),d1
	btst	d1,d0
	bne.s	.Ok2
	moveq.l	#21,d0			; "Wrong class"
	bra	.Prompt
.Ok2:	lea.l	Spells_class_0(a0),a3	; Spell known ?
	ext.w	d1
	lsl.w	#2,d1
	add.w	d1,a3
	move.l	(a3),d0
	moveq.l	#0,d1
	move.b	Spell_number(a1),d1
	btst	d1,d0
	beq.s	.Ok3
	moveq.l	#61,d0			; "Knows already!"
	bra.s	.Prompt
.Ok3:	lea.l	Spell_data,a4		; Get pointer to spell data
	moveq.l	#0,d0
	move.b	Spell_class(a1),d0
	mulu.w	#Max_spells,d0
	add.w	d1,d0
	subq.w	#1,d0
	mulu.w	#Spell_data_size,d0
	add.w	d0,a4
	moveq.l	#0,d0			; Get SLP cost
	move.b	Spell_learn_point_cost(a4),d0
	move.w	Nr_spell_learn_points(a0),d2	; Get SLP
	sub.w	d0,d2			; Enough ?
	bpl.s	.Ok4
	moveq.l	#25,d0			; "Not enough SLP!"
	bra.s	.Prompt
.Ok4:	move.w	d2,Nr_spell_learn_points(a0)	; Store new SLP
	move.l	a1,a4
	move.w	d6,d2			; Remove item
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	moveq.l	#0,d0			; Show slots
	jsr	Set_scroll_row
	jsr	Copy_screen_to_both
	move.w	SRead_scrolls(a0),d0	; Probe {Read scrolls} skill
	add.w	SRead_scrolls+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.Pos
	moveq.l	#23,d0			; "Bang!"
	bra.s	.Prompt
.Pos:	move.b	Spell_number(a4),d1		; Learn spell
	move.l	(a3),d0
	bset	d1,d0
	move.l	d0,(a3)
	moveq.l	#22,d0			; "Yay!"
.Prompt:	jsr	Do_prompt
	jsr	Check_active_backpack	; All gone ?
	bne	.Repeat			; No -> Again
.Exit:	jsr	Hide_Lay3_objects		; Hide
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d7/a0-a4
	rts

; [ Leave layout 3 before a map change ]
Close_lay3_to_map:
	movem.l	d0/a0,-(sp)
	clr.l	Ghost_text
	clr.l	Drag_graphic
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	lea.l	Mouse_pointer,a0
	jsr	Change_Mptr
	lea.l	Map_RL,a0
	jsr	Set_raster_list
	jsr	Display_status_block
	movem.l	(sp)+,d0/a0
	rts

; ********** Camp screen - Rest *******************
Rest:
	tst.b	Inn_flag			; Inn ?
	bne.s	.Ok
	cmp.w	#Camp_time,Camp_counter	; Too early ?
	bpl.s	.Ok
	move.w	#176,d0			; "Too early !"
	jmp	Do_prompt
.Ok:	st	Slept			; Set flag
	moveq.l	#1,d7			; De-exhaust people
.Loop0:	jsr	Get_char_data
	move.l	a1,a0
	jsr	De_exhaust
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop0
; ---------- Wait x hours -------------------------
	tst.b	Inn_flag			; (not in the inn)
	bne.s	.Not_dungeon
	btst	#Dungeon_bit,Map_data_buffer+Map_special+1	; Dungeon ?
	bne.s	.8_hours
.Not_dungeon:
	cmp.w	#Morning_time,Hour		; Early ?
	bmi.s	.Dawn
	cmp.w	#Evening_time,Hour		; Evening ?
	bmi.s	.8_hours
.Dawn:	move.w	#101,d0			; "Till dawn..."
	jsr	Do_prompt
	moveq.l	#0,d7			; What time is it ?
	move.w	Hour,d7
	cmp.w	#Evening_time,d7		; Beyond midnight ?
	bmi.s	.Yes
	subi.w	#24,d7			; No
	neg.w	d7
	add.w	#Dawn_time,d7
	bra.s	.Do
.Yes:	sub.w	#Dawn_time,d7		; Yes
	neg.w	d7
.Do:	subq.w	#1,d7			; Minus current hour
	bmi.s	.Skip
	mulu.w	#Minutes_per_hour,d7	; Calculate minutes
.Skip:	move.w	#Minutes_per_hour,d0
	sub.w	Minute,d0
	add.w	d0,d7
	divu.w	#Minutes_per_step,d7
	bra.s	.Wait
.8_hours:	moveq.l	#24,d0			; "8 hours..."
	jsr	Do_prompt
	move.w	#(8*Minutes_per_hour)/Minutes_per_step-1,d7
.Wait:	clr.w	Camp_counter		; Clear
	bra.s	.Entry
.Loop1:	jsr	Update_time		; Wait x hours
.Entry:	dbra	d7,.Loop1
	clr.w	Camp_counter		; Clear again
	jsr	Update_light_status
; ---------- Gain LP & PP -------------------------
	moveq.l	#50,d2			; Outside : 50%
	tst.b	Inn_flag
	beq.s	.Go_on
	move.w	Current_inn_value,d2	; Inn : healing percentage
.Go_on:	moveq.l	#1,d7
.Loop2:	jsr	Get_char_data
	move.w	Body_conditions(a1),d0	; Alive and kicking ?
	andi.w	#Alive_mask,d0
	bne.s	.Next2
	tst.b	Inn_flag			; Outside ?
	bne.s	.Recup
	tst.w	Food_rations(a1)		; Yes -> Any food left ?
	bne.s	.Enough
	lea.l	Char_name(a1),a0		; "... has no food"
	move.l	a0,Format_args
	moveq.l	#9,d0
	movem.l	a0/a1,-(sp)
	lea.l	Format_buffer,a1
	jsr	Format_text
	lea.l	Format_buffer,a0
	jsr	Show_PA_text
	movem.l	(sp)+,a0/a1
	bra.s	.Next2
.Enough:	subq.w	#1,Food_rations(a1)		; Remove 1 food
	subi.l	#Food_weight,Weight_normal(a1)
.Recup:	jsr	Add_LP_and_PP		; Do it
.Next2:	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop2
	jmp	Erase_PA

; [ De-exhaust a character ]
;   IN : a0 - Pointer to character data (.l)
; All registers are restored
; NOTE :
;   - From MAIN.S.
De_exhaust:
	movem.l	d0/d7/a1,-(sp)
	move.w	Body_conditions(a0),d0	; Exhausted ?
	bclr	#Exhausted,d0
	beq.s	.Exit
	move.w	d0,Body_conditions(a0)	; No more
	lea.l	Attributes(a0),a1		; Restore attributes
	moveq.l	#Max_attrs-1,d7
.Loop1:	move.w	Backup(a1),(a1)
	addq.l	#Attr_data_size,a1
	dbra	d7,.Loop1
	lea.l	Skills(a0),a1		; Restore skills
	moveq.l	#Max_skills-1,d7
.Loop2:	move.w	Backup(a1),(a1)
	addq.l	#Skill_data_size,a1
	dbra	d7,.Loop2
.Exit:	movem.l	(sp)+,d0/d7/a1
	rts

; [ Add LP & SP after resting ]
;   IN : d2 - Percentage (.w)
;        d7 - Member number {1...6} (.w)
;        a1 - Pointer to character data (.l)
; All registers are restored
; NOTE :
;   - From ACTIONS.S : "{0} regains {1} LP (and {2} SP)."
Add_LP_and_PP:
	movem.l	d0/d1/d4/d5/a0/a1,-(sp)
	moveq.l	#0,d4
	moveq.l	#0,d5
	move.w	Life_points+Maximum(a1),d0	; Get maximum LP
	add.w	Life_points+Magic(a1),d0
	move.w	d0,d1			; Calculate maximum gain
	sub.w	Life_points(a1),d1
	bmi.s	.Skip1
	mulu.w	d2,d0			; Calculate gained LP
	divu.w	#100,d0
	tst.w	d0			; Zero ?
	bne.s	.Not_zero1
	moveq.l	#1,d0			; At least 1
.Not_zero1:	cmp.w	d0,d1			; Too high ?
	bpl.s	.Ok1
	move.w	d1,d0
.Ok1:	move.w	d0,d4
.Skip1:	tst.b	Spell_class_counter(a1)	; Magic person ?
	beq.s	.Skip2
	move.w	Power_points+Maximum(a1),d0	; Get maximum PP
	add.w	Power_points+Magic(a1),d0
	move.w	d0,d1
	sub.w	Power_points(a1),d1
	bmi.s	.Skip2
	mulu.w	d2,d0			; Calculate gained PP
	divu.w	#100,d0
	tst.w	d0
	bne.s	.Not_zero2
	moveq.l	#1,d0
.Not_zero2:	cmp.w	d0,d1
	bpl.s	.Ok2
	move.w	d1,d0
.Ok2:	move.w	d0,d5
.Skip2:	add.w	d4,Life_points(a1)		; Add LP & PP
	add.w	d5,Power_points(a1)
	jsr	Force_status_update
	lea.l	Char_name(a1),a0		; Print
	move.l	a0,Format_args
	lea.l	Number,a0			; Convert gained LP
	move.l	a0,Format_args+4
	moveq.l	#0,d0
	move.w	d4,d0
	move.l	d7,-(sp)
	moveq.l	#3,d7
	jsr	DecL_convert
	lea.l	Number+5,a0		; Convert gained SP
	move.l	a0,Format_args+8
	moveq.l	#0,d0
	move.w	d5,d0
	jsr	DecL_convert
	move.l	(sp)+,d7
	lea.l	Format_buffer,a1
	moveq.l	#Recup1_txt,d0		; "Just LP" or "LP & SP"
	tst.w	d5
	beq.s	.Just
	moveq.l	#Recup2_txt,d0
.Just:	jsr	Format_text
	lea.l	Format_buffer,a0
	jsr	Print_PA_text
	jsr	Copy_screen_to_both
	jsr	Wait_for_click
	movem.l	(sp)+,d0/d1/d4/d5/a0/a1
	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

; Control icon lists (PLACES.S and ACTIONS.S)
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
Blacksmith_CIL:
	dc.w 0,0,Exit_cicon
	dc.w Repair_item_cicon,0,0
	dc.w 0,0,0
	dc.l 0,0,Exit_PLACES
	dc.l Repair_item,0,0
	dc.l 0,0,0
	dc.l 0
Camp_CIL:					; (casting spells is not
	dc.w Use_magic_cicon+Disabled,0,Exit_cicon	;  possible)
	dc.w Read_scroll_cicon,0,0
	dc.w Zzz_cicon,0,0
	dc.l 0,0,0
	dc.l 0,0,0
	dc.l 0,0,0
	dc.l Camp_CIL_evaluate

; Condition "items" (Condition_object_index_table in KERNEL/DATA.S)
Condition_object_index_table:
	dc.b 0,7,0,0,8,9,0,0,1,2,3,4,5,6,0,0
; Healer price offsets (Healer_condition_table in PLACES.S)
Healer_condition_table:
	dc.b -1,Mad_price,-1,-1
	dc.b Blind_price,Stoned_price,-1,-1
	dc.b Lamed_price,Poisoned_price,Petrified_price,Diseased_price
	dc.b Aging_price,Dead_price,Ashes_price,Dust_price
	even

	SECTION	Fast_BSS,bss
Place_ptr:	ds.l 1			; Data of the current place
Place_CIL_ptr:	ds.l 1
Merchant_ptr:	ds.l 1
Format_args:	ds.l 3
Current_place_type:	ds.w 1
Current_place_nr:	ds.w 1
Current_gold:	ds.w 1
Total_price:	ds.w 1
Victim_member:	ds.w 1
Current_inn_value:	ds.w 1
Inn_destination:	ds.w 3
Place_CIL_work:	ds.w 9
Place_exit:	ds.b 1
Sold_shown:	ds.b 1
Inn_flag:	ds.b 1
Room_rented:	ds.b 1
Slept:	ds.b 1
	even
Place_name:	ds.b Place_string_length
Format_buffer:	ds.b 256
Sold_slots:	ds.b Max_sold*Object_packet_size
Ankh_symbol:	ds.b 2*8*29
Places_data:	ds.b 4032
Merchants:	ds.b 32*Items_per_chest*Object_packet_size
	even
