; Proof of concept : inventory (Atari ST)
;
; The Inventory 2 screen of INVENTOR.S : the small member info (portrait,
; race, class, LP, SP, gold & food, damage & protection), the body items,
; the backpack with scroll bar and the weight. Items can be moved between
; the backpack and the body (with the checks and boni of the original), to
; other backpack slots and to other party members.
;
; The Amiga version uses one palette for the status block, the items and the
; portraits (Main_pal), because a moved item can be dragged onto the
; portraits. Here the area below the status block has its own palette for
; the items and the portrait (Inv_palette), and a moved item is shown as a
; white silhouette like in Amberstar (white has the same ST colour in both
; palettes).
;
; The Stats icon switches to the Inventory 1 screen (character screen :
; attributes, skills, languages and conditions), which has its own palette
; for the portrait and the status icons, the backpack icon switches back.
;
; Right mouse button on a portrait or F1...F6 opens the inventory of a member.
; Left mouse button on an item takes it (the whole stack) ; then left mouse
; button on a slot, the body or a portrait puts it there, right mouse button
; or ESC puts it back. ESC or the exit icon closes the inventory.

	SECTION	Program,code

Body_slot_size	EQU	16
Backpack_slot_height	EQU	24
; Scroll bar descriptors (the data of the scroll bars of HULL/CONTROLS.S)
	rsreset
SBD_pos_list:	rs.l 1			; Positions of the 12 slots
SBD_X:	rs.w 1
SBD_Y:	rs.w 1
SBD_height:	rs.w 1
SBD_row_height:	rs.w 1
SBD_thingy_height:	rs.w 1
SBD_max_row:	rs.w 1			; Number of rows - visible rows
SBD_units:	rs.w 1			; Slots per row
SBD_half:	rs.w 1			; Half page (rows)
SBD_update:	rs.l 1			; Routine which shows the slots
Info_X	EQU	208			; Small member info
Info_Y	EQU	49
; Text numbers in TEXTS.BIN
Male_txt	EQU	9
Female_txt	EQU	10
Age_txt	EQU	13
Experience_txt	EQU	17
LP_txt	EQU	18
PP_txt	EQU	19
SLP_txt	EQU	20
TP_txt	EQU	21
Goldfood_txt	EQU	22
ProtDam_txt	EQU	23
Weight_txt	EQU	40
Weight_kg_txt	EQU	41
Inventory_headline	EQU	48
Race_names	EQU	64
Class_names	EQU	80
Messages	EQU	96
Skills_txt	EQU	5
Attrs_txt	EQU	6
Language_txt	EQU	7
Conditions_txt	EQU	8
Skill_txt	EQU	14
Attr_txt	EQU	15
Short_attr_names	EQU	396
Short_skill_names	EQU	412
Language_names	EQU	428
Condition_names	EQU	444

;*****************************************************************************
; [ Inventory screen ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From [ Inv2_ModInit ], [ Inv2_DisInit ] and [ Inv2_ModExit ].
;*****************************************************************************
Inventory_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Member_present		; Anyone there ?
	beq	.None
	move.w	d7,Inventory_member
	sf	Moving_flag
	clr.l	Ghost_text
	clr.l	Drag_graphic
	jsr	Reset_party_weight
	moveq.l	#2,d0			; Inventory 2 possible ?
	jsr	Get_inventory_char
	move.w	Body_conditions(a1),d1
	andi.w	#Inv2_mask,d1
	beq.s	.Inv2
	moveq.l	#1,d0			; No -> Inventory 1
.Inv2:	jsr	Show_inventory_mode
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
	sf	Inventory_exit
; ---------- Main loop ----------------------------
.Loop:	jsr	Inventory_input
	tst.b	Inventory_exit
	bne.s	.Exit
	jsr	Update_ghost
	jsr	Switch_screens
	bra.s	.Loop
; ---------- Back to the map ----------------------
.Exit:	clr.l	Ghost_text
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	lea.l	Mouse_pointer,a0
	jsr	Change_Mptr
	lea.l	Map_RL,a0
	jsr	Set_raster_list
	jsr	Display_status_block	; (LP & SP maximum may change)
	jsr	Draw_map_screen
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
.None:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Show Inventory 1 or 2 ]
;   IN : d0 - 1 = Inventory 1 (character screen), 2 = Inventory 2 (.w)
; All registers are restored
; NOTE :
;   - From [ Inv1_DisInit ] and [ Inv2_DisInit ]. The whole screen is faded
;     (the Amiga version fades only the bottom).
;*****************************************************************************
Show_inventory_mode:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	d0,Inventory_mode
	move.l	#Inv_PA,Print_area_ptr
	clr.l	Ghost_text
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	lea.l	Inventory_files,a0		; Inventory 2
	lea.l	Inv_RL,a1
	lea.l	Inv_portraits,a2
	cmp.w	#1,Inventory_mode
	bne.s	.Go
	lea.l	Character_files,a0		; Inventory 1
	lea.l	Char_RL,a1
	lea.l	Char_portraits,a2
.Go:	move.l	a2,Small_portraits
	jsr	Load_files		; Load layout
	move.l	a1,a0			; Install palettes
	jsr	Set_raster_list
	moveq.l	#0,d0			; Show layout
	moveq.l	#Middle_Y+1,d1
	moveq.l	#20,d6
	move.w	#199-Middle_Y,d7
	lea.l	Extra_layout,a0
	jsr	Put_unmasked_block
	cmp.w	#1,Inventory_mode
	beq.s	.Inv1
	moveq.l	#Window_colour,d4		; Clear text area
	move.w	#20,d0			; (from [ Init_Inv2_layout ])
	move.w	#50,d1
	move.w	#182,d2
	move.w	#70,d3
	jsr	Draw_box
	move.w	#31,Ink_colour		; Print headline
	move.w	#Default_shadow,Shadow_colour
	moveq.l	#Inventory_headline,d0
	jsr	Get_text
	moveq.l	#19,d0
	moveq.l	#40,d1
	move.w	#165,d2
	jsr	Print_centered_string
	jsr	Display_Inv2_member_info
	lea.l	Inv2_CIL,a0
	bra.s	.Icons
.Inv1:	jsr	Display_Inv1_member_info
	lea.l	Inv1_CIL,a0
.Icons:	jsr	Display_CIL		; Show icons
	jsr	Copy_screen_to_both
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Read_mouse_clicks
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Handle the input of the inventory screen ]
; All registers are restored
;*****************************************************************************
Inventory_input:
	movem.l	d0-d7/a0-a6,-(sp)
; ---------- Keys ---------------------------------
.Keys:	jsr	Read_key
	tst.w	d0
	beq.s	.Mouse
	cmp.w	#$01,d0			; ESC ?
	beq.s	.Escape
	cmp.w	#$61,d0			; UNDO ?
	beq.s	.Escape
	cmp.w	#$3b,d0			; F1...F6 ?
	bmi.s	.Keys
	cmp.w	#$40+1,d0
	bpl.s	.Keys
	subi.w	#$3b-1,d0
	move.w	d0,d7
	jsr	Switch_inventory_member
	bra.s	.Keys
.Escape:	tst.b	Moving_flag		; Moving an item ?
	beq.s	.Close
	jsr	Move_aborted		; Yes -> put it back
	bra.s	.Keys
.Close:	st	Inventory_exit		; No -> exit
	bra	.Exit
; ---------- Mouse ---------------------------------
.Mouse:	jsr	Read_mouse_clicks
	move.w	d0,d6
	beq	.Exit
	jsr	Find_inventory_object	; What is under the mouse ?
	move.w	d0,d1
	lsr.w	#8,d1			; d1 = type, d0 = number
	andi.w	#$00ff,d0
	btst	#Right_pressed,d6		; Right button ?
	beq.s	.Left
	tst.b	Moving_flag		; Moving an item ?
	beq.s	.Right2
	jsr	Move_aborted		; Yes -> put it back
	bra	.Exit
.Right2:	cmp.w	#Obj_backpack,d1		; Backpack item ?
	bne.s	.Right3
	st	Right_move		; Yes -> take all
	jsr	Move_backpack_item
	sf	Right_move
	bra	.Exit
.Right3:	cmp.w	#Obj_member,d1		; Portrait ?
	bne	.Exit
	move.w	d0,d7			; Yes -> switch
	jsr	Switch_inventory_member
	bra	.Exit
.Left:	btst	#Left_pressed,d6		; Left button ?
	beq	.Exit
	tst.b	Moving_flag		; Moving an item ?
	bne	.Moving
; ---------- Not moving ---------------------------
	cmp.w	#Obj_member,d1		; Portrait ?
	bne.s	.No_member
	move.w	d0,d7			; Yes -> switch
	jsr	Switch_inventory_member
	bra	.Exit
.No_member:	cmp.w	#Obj_body,d1		; Body item ?
	bne.s	.No_body
	tst.w	d0
	beq	.Exit
	jsr	Move_body_item
	bra	.Exit
.No_body:	cmp.w	#Obj_backpack,d1		; Backpack item ?
	bne.s	.No_backpack
	jsr	Move_backpack_item
	bra	.Exit
.No_backpack:
	cmp.w	#Obj_scroll_bar,d1		; Scroll bar ?
	bne.s	.No_bar
	jsr	Scroll_bar_pressed
	bra	.Exit
.No_bar:	cmp.w	#Obj_icon,d1		; Control icon ?
	bne	.Exit
	cmp.w	#1,d0			; Stats / backpack ?
	bne.s	.No_switch
	moveq.l	#3,d0			; Switch screen
	sub.w	Inventory_mode,d0
	jsr	Show_inventory_mode
	bra	.Exit
.No_switch:	cmp.w	#2,Inventory_mode		; Item functions (Inventory 2)
	bne.s	.No_items
	cmp.w	#2,d0			; Use item ?
	bne.s	.No_use
	jsr	Use_item
	bra	.Exit
.No_use:	cmp.w	#4,d0			; Drop item ?
	bne.s	.No_drop
	jsr	Drop_item
	bra	.Exit
.No_drop:	cmp.w	#7,d0			; View item ?
	bne.s	.No_view
	jsr	View_item
	bra	.Exit
.No_view:	cmp.w	#5,d0			; Drop gold ?
	bne.s	.No_dgold
	jsr	Drop_gold
	bra	.Exit
.No_dgold:	cmp.w	#6,d0			; Drop food ?
	bne.s	.No_dfood
	jsr	Drop_food
	bra	.Exit
.No_dfood:	cmp.w	#8,d0			; Transfer gold ?
	bne.s	.No_tgold
	jsr	Transfer_gold
	bra	.Exit
.No_tgold:	cmp.w	#9,d0			; Transfer food ?
	bne.s	.No_items
	jsr	Transfer_food
	bra	.Exit
.No_items:	cmp.w	#3,d0			; Exit ?
	bne	.Exit
	jsr	Press_exit_icon
	st	Inventory_exit
	bra	.Exit
; ---------- Moving an item -----------------------
.Moving:	cmp.w	#Obj_member,d1		; Portrait ?
	bne.s	.No_member2
	jsr	Member_moved
	bra.s	.Exit
.No_member2:
	cmp.w	#Obj_body,d1		; Body ?
	bne.s	.No_body2
	jsr	Body_item_moved
	bra.s	.Exit
.No_body2:	cmp.w	#Obj_backpack,d1		; Backpack slot ?
	bne.s	.No_backpack2
	jsr	Backpack_item_moved
	bra.s	.Exit
.No_backpack2:
	cmp.w	#Obj_scroll_bar,d1		; Scroll bar ?
	bne.s	.Exit
	jsr	Scroll_bar_pressed
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Find the object under the mouse ]
;  OUT : d0 - Type * 256 + number / 0 = nothing (.w)
; Changed registers : d0
; NOTE :
;   - Replaces the object trees (Inv2_L2 etc. in INVENTOR.S).
;*****************************************************************************
Find_inventory_object:
	movem.l	d1-d4/a0,-(sp)
	move.w	Mouse_X,d2
	move.w	Mouse_Y,d3
; ---------- Status block -------------------------
	cmp.w	#Middle_Y+1,d3		; Portraits ?
	bpl.s	.No_status
	move.w	d2,d0
	subi.w	#16,d0
	bmi	.None
	ext.l	d0
	divu.w	#48,d0
	cmp.w	#6,d0
	bpl	.None
	addq.w	#1,d0
	move.l	d7,-(sp)			; Anyone there ?
	move.w	d0,d7
	jsr	Member_present
	movem.l	(sp)+,d7
	beq	.None
	ori.w	#Obj_member<<8,d0
	bra	.Exit
; ---------- Body slots ---------------------------
.No_status:	cmp.w	#1,Inventory_mode		; Inventory 1 ?
	beq	.No_bar
	cmp.w	#3,Inventory_mode		; Layout 3 (no body) ?
	beq.s	.Slots
	lea.l	Body_pos_list,a0
	moveq.l	#1,d0
	moveq.l	#Body_slot_size,d4
.Loop1:	jsr	.Inside
	beq	.Body
	addq.w	#1,d0
	cmp.w	#9+1,d0
	bmi.s	.Loop1
; ---------- Backpack slots -----------------------
.Slots:	move.l	SB_ptr,a0
	move.l	SBD_pos_list(a0),a0
	moveq.l	#1,d0
	moveq.l	#Backpack_slot_height,d4
.Loop2:	jsr	.Inside
	beq	.Backpack
	addq.w	#1,d0
	cmp.w	#12+1,d0
	bmi.s	.Loop2
; ---------- Body area (number 0) -----------------
	cmp.w	#3,Inventory_mode
	beq.s	.No_body
	moveq.l	#0,d0
	cmp.w	#20,d2
	bmi.s	.No_body
	cmp.w	#84+16,d2
	bpl.s	.No_body
	cmp.w	#72,d3
	bmi.s	.No_body
	cmp.w	#176+16,d3
	bmi	.Body
; ---------- Scroll bar ---------------------------
.No_body:	move.l	SB_ptr,a0
	move.w	SBD_X(a0),d1
	cmp.w	d1,d2
	bmi.s	.No_bar
	addq.w	#6,d1
	cmp.w	d1,d2
	bpl.s	.No_bar
	move.w	SBD_Y(a0),d1
	cmp.w	d1,d3
	bmi.s	.No_bar
	add.w	SBD_height(a0),d1
	cmp.w	d1,d3
	bpl.s	.No_bar
	move.w	#Obj_scroll_bar<<8,d0
	bra.s	.Exit
; ---------- Control icons ------------------------
.No_bar:	subi.w	#208,d2
	bmi.s	.None
	subi.w	#143,d3
	bmi.s	.None
	ext.l	d2
	divu.w	#32,d2
	ext.l	d3
	divu.w	#17,d3
	cmp.w	#3,d2
	bpl.s	.None
	cmp.w	#3,d3
	bpl.s	.None
	mulu.w	#3,d3
	add.w	d3,d2
	addq.w	#1,d2
	move.w	d2,d0
	ori.w	#Obj_icon<<8,d0
	bra.s	.Exit
.Body:	ori.w	#Obj_body<<8,d0
	bra.s	.Exit
.Backpack:	ori.w	#Obj_backpack<<8,d0
	bra.s	.Exit
.None:	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d1-d4/a0
	rts

; Is the mouse (d2,d3) in the slot at (a0)+ (16 x d4) ? eq = yes
.Inside:	move.w	(a0)+,d1
	cmp.w	d1,d2
	bmi.s	.Out1
	addi.w	#16,d1
	cmp.w	d1,d2
	bpl.s	.Out1
	move.w	(a0)+,d1
	cmp.w	d1,d3
	bmi.s	.Out2
	add.w	d4,d1
	cmp.w	d1,d3
	bpl.s	.Out2
	moveq.l	#0,d1			; Inside
	rts
.Out1:	addq.l	#2,a0
.Out2:	moveq.l	#-1,d1
	rts

;*****************************************************************************
; [ Show the name of the item under the mouse ]
; All registers are restored
; NOTE :
;   - Like [ Item_touched ] and [ Body_item_touched ] (DISPLAY.S), but the
;     name is drawn with the mouse pointer.
;*****************************************************************************
Update_ghost:
	movem.l	d0-d2/d7/a0-a2,-(sp)
	sub.l	a2,a2			; No name
	clr.l	Ghost_text2
	move.w	#White,Ghost_ink
	cmp.w	#1,Inventory_mode		; Inventory 1 ?
	bne.s	.Inv2
	jsr	Condition_touched
	move.l	a0,a2
	bra.s	.Done
.Inv2:	tst.b	Moving_flag		; Moving an item ?
	bne.s	.Done
	jsr	Find_inventory_object
	move.w	d0,d1
	lsr.w	#8,d1
	andi.w	#$00ff,d0
	cmp.w	#Obj_body,d1		; Body ?
	beq.s	.Body
	cmp.w	#Obj_backpack,d1		; Backpack ?
	bne.s	.Done
	addi.w	#9,d0
	add.w	Scroll_bar_result,d0
	bra.s	.Slot
.Body:	tst.w	d0			; Body slot ?
	beq.s	.Done
.Slot:	jsr	Get_slot_packet
	move.w	Object_index(a0),d0		; Anything there ?
	beq.s	.Done
	jsr	Get_item_data
	lea.l	Item_name(a1),a2
	tst.b	Price_ghost		; Show price ?
	beq.s	.Done
	moveq.l	#0,d0			; Yes (like [ Create_object_price ])
	move.w	Price(a1),d0
	move.w	#White,Ghost_ink2
	cmp.w	Current_gold,d0		; Affordable ?
	bls.s	.Yes
	move.w	#Red,Ghost_ink2
.Yes:	lea.l	Price_text,a0
	moveq.l	#5,d7
	jsr	DecL_convert
	move.l	#Price_text,Ghost_text2
.Done:	move.l	a2,Ghost_text
	movem.l	(sp)+,d0-d2/d7/a0-a2
	rts

;*****************************************************************************
; [ Switch to the inventory of another member ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From [ Inv2_Mright ].
;*****************************************************************************
Switch_inventory_member:
	movem.l	d0/a0,-(sp)
	cmp.w	Inventory_member,d7		; Same as now ?
	beq.s	.Exit
	jsr	Save_scroll_bar_position
	move.w	d7,Inventory_member
	cmp.w	#1,Inventory_mode		; Inventory 1 ?
	bne.s	.Inv2
	jsr	Display_Inv1_member_info
	bra.s	.No
.Inv2:	jsr	Display_Inv2_member_info
	tst.b	Moving_flag		; Moving ?
	beq.s	.No
	moveq.l	#55,d0			; Show prompt again
	jsr	Print_prompt
.No:	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Display Inventory 2 member info ]
; All registers are restored
;*****************************************************************************
Display_Inv2_member_info:
	movem.l	d0/d1/a0/a1,-(sp)
	jsr	Get_inventory_char		; Backpack slots
	lea.l	Char_inventory+Backpack_slots(a1),a1
	move.l	a1,Slot_base
	move.l	#Backpack_bar,SB_ptr
	jsr	Erase_PA
	jsr	Display_small_member_info
	jsr	Display_body_objects
	lea.l	Inventory_scroll_positions,a0	; Get old scroll position
	move.w	Inventory_member,d0
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0
	jsr	Set_scroll_row
	jsr	Update_weight
	movem.l	(sp)+,d0/d1/a0/a1
	rts

; Store the scroll bar position of the current member
Save_scroll_bar_position:
	movem.l	d0/d1/a0,-(sp)
	lea.l	Inventory_scroll_positions,a0
	move.w	Inventory_member,d1
	add.w	d1,d1
	move.w	Scroll_row,-2(a0,d1.w)
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Display small member info ]
; All registers are restored
; NOTE :
;   - From INVENTOR.S.
;*****************************************************************************
Display_small_member_info:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	#Info_X,d0		; Clear area
	move.w	#Info_Y,d1
	move.w	#303,d2
	move.w	#128,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
; ---------- Display portrait ---------------------
	move.l	Small_portraits,a0
	move.w	Inventory_member,d7
	subq.w	#1,d7
	mulu.w	#34*2*8,d7
	add.l	d7,a0
	move.w	#Info_X,d0
	move.w	#Info_Y,d1
	moveq.l	#2,d6
	moveq.l	#34,d7
	jsr	Put_unmasked_block
; --------- Print character name ------------------
	jsr	Get_inventory_char
	move.w	#Default_shadow,Shadow_colour
	move.w	#Yellow,Ink_colour
	move.w	#Info_X,d0
	move.w	#Info_Y+35,d1
	move.w	#96,d2
	lea.l	Char_name(a1),a0
	jsr	Print_centered_string
; ---------- Print character sex ------------------
	move.w	#White,Ink_colour
	moveq.l	#Male_txt,d0
	tst.b	Char_sex(a1)
	beq.s	.Male
	moveq.l	#Female_txt,d0
.Male:	jsr	Get_text
	move.w	#Info_X+34,d0
	move.w	#Info_Y+7,d1
	jsr	Put_text_line
; ---------- Print character race -----------------
	moveq.l	#0,d0
	move.b	Char_race(a1),d0
	addi.w	#Race_names,d0
	jsr	Get_text
	move.w	#Info_X+34,d0
	move.w	#Info_Y,d1
	jsr	Put_text_line
; ---------- Print character class ----------------
	move.b	Char_race(a1),d0		; Special or monster ?
	move.w	#Special_race_mask,d1
	btst	d0,d1
	bne.s	.No_class
	moveq.l	#0,d0
	move.b	Char_class(a1),d0
	addi.w	#Class_names,d0
	jsr	Get_text
	move.l	a0,a2			; Get length
	moveq.l	#0,d2
.Len:	tst.b	(a2)+
	beq.s	.Len_done
	addq.w	#1,d2
	bra.s	.Len
.Len_done:	move.w	#Info_X+34,d0
	move.w	#Info_Y+21,d1
	jsr	Put_text_line
; ---------- Print character level ----------------
	moveq.l	#0,d0
	move.b	Level_nr(a1),d0
	moveq.l	#2,d7
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	#Info_X+34,d0
	addq.w	#1,d2
	mulu.w	#Char_width+1,d2
	add.w	d2,d0
	move.w	#Info_Y+21,d1
	lea.l	Number,a0
	jsr	Put_text_line
; ---------- Print character's age ----------------
.No_class:	moveq.l	#Age_txt,d0
	jsr	Copy_text
	moveq.l	#0,d0
	move.w	AAge(a1),d0
	add.w	AAge+Magic(a1),d0
	moveq.l	#3,d7
	lea.l	6(a2),a0
	jsr	DecL_convert
	move.w	#Info_X+34,d0
	move.w	#Info_Y+14,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Print experience points --------------
	moveq.l	#Experience_txt,d0
	jsr	Copy_text
	move.l	Experience_points(a1),d0
	moveq.l	#6,d7
	lea.l	3(a2),a0
	jsr	DecL_convert
	move.w	#Info_X+34,d0
	move.w	#Info_Y+28,d1
	move.l	a2,a0
	jsr	Put_text_line
	jsr	Update_small_member_info	; Do the rest
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Display Inventory 1 member info ]
; All registers are restored
; NOTE :
;   - From INVENTOR.S.
;*****************************************************************************
Display_Inv1_member_info:
	movem.l	d0-d7/a0-a4,-(sp)
	jsr	Display_small_member_info	; Small info
	jsr	Get_inventory_char
	move.w	#16,d0			; Clear area
	move.w	#49,d1
	move.w	#191,d2
	move.w	#193,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	move.w	#Default_shadow,Shadow_colour
;----------- Print character skills ---------------
	move.w	#Light_green,Ink_colour
	moveq.l	#Skills_txt,d0		; Print "SKILLS"
	jsr	Get_text
	move.w	#16+6,d0
	move.w	#50+65,d1
	move.w	#12*6,d2
	jsr	Print_centered_string
	move.w	#White,Ink_colour
	move.w	#Short_skill_names,d0	; Print skills
	jsr	Get_text
	move.l	a0,a3
	lea.l	Skills(a1),a4
	move.w	#16+6,d3
	move.w	#50+72,d4
	moveq.l	#Max_skills-1,d5
	moveq.l	#"0",d6
	moveq.l	#2,d7
.Loop1:	move.w	d3,d0			; Print skill name
	move.w	d4,d1
	move.l	a3,a0
	jsr	Put_text_line
	moveq.l	#Skill_txt,d0
	jsr	Copy_text
	move.w	(a4),d0			; Convert normal skill
	add.w	Magic(a4),d0
	move.l	a2,a0
	jsr	DecR_convert
	move.b	#"%",(a0)
	move.w	Maximum(a4),d0		; Convert maximum skill
	lea.l	4(a2),a0
	jsr	DecR_convert
	move.b	#"%",(a0)
	move.w	d3,d0			; Print skill
	addi.w	#5*(Char_width+1),d0
	move.w	d4,d1
	move.l	a2,a0
	jsr	Put_text_line
	addq.w	#Char_height+1,d4		; Next skill
.Skip1:	tst.b	(a3)+
	bne.s	.Skip1
	addq.w	#Skill_data_size,a4
	dbra	d5,.Loop1
;----------- Print character attributes -----------
	move.w	#Light_green,Ink_colour
	moveq.l	#Attrs_txt,d0		; Print "ATTRIBUTES"
	jsr	Get_text
	move.w	#16+6,d0
	move.w	#50,d1
	move.w	#12*6,d2
	jsr	Print_centered_string
	move.w	#White,Ink_colour
	move.w	#Short_attr_names,d0	; Print attributes
	jsr	Get_text
	move.l	a0,a3
	lea.l	Attributes(a1),a4
	move.w	#50+7,d4
	moveq.l	#Max_attrs-1,d5
	moveq.l	#3,d7
.Loop2:	move.w	d3,d0			; Print attribute name
	move.w	d4,d1
	move.l	a3,a0
	jsr	Put_text_line
	moveq.l	#Attr_txt,d0
	jsr	Copy_text
	move.w	(a4),d0			; Convert normal attribute
	add.w	Magic(a4),d0
	move.l	a2,a0
	jsr	DecR_convert
	move.b	#"/",(a0)
	move.w	Maximum(a4),d0		; Convert maximum attribute
	lea.l	4(a2),a0
	jsr	DecR_convert
	move.w	d3,d0			; Print attribute
	addi.w	#5*(Char_width+1),d0
	move.w	d4,d1
	move.l	a2,a0
	jsr	Put_text_line
	addq.w	#Char_height+2,d4		; Next attribute
.Skip2:	tst.b	(a3)+
	bne.s	.Skip2
	addq.w	#Attr_data_size,a4
	dbra	d5,.Loop2
; ---------- Print known languages ----------------
	move.w	#Light_green,Ink_colour
	moveq.l	#Language_txt,d0		; Print "LANGUAGES"
	jsr	Get_text
	move.w	#16+15*6,d0
	move.w	#50,d1
	move.w	#12*6,d2
	jsr	Print_centered_string
	move.w	#White,Ink_colour
	move.w	#Language_names,d0	; Print languages
	jsr	Get_text
	move.w	#16+15*6,d0
	move.w	#50+7,d1
	move.b	Learned_languages(a1),d6
	moveq.l	#0,d7
.Loop3:	btst	d7,d6			; Language known ?
	beq.s	.Next3
	move.l	a0,-(sp)
	jsr	Put_text_line
	move.l	(sp)+,a0
.Next3:	addq.w	#Char_height+2,d1		; Next language
.Skip3:	tst.b	(a0)+
	bne.s	.Skip3
	addq.w	#1,d7
	cmpi.w	#Max_languages,d7
	bmi.s	.Loop3
; ---------- Display conditions -------------------
	move.w	#Light_green,Ink_colour
	moveq.l	#Conditions_txt,d0		; Print "CONDITIONS"
	jsr	Get_text
	moveq.l	#96,d0
	move.w	#50+65,d1
	moveq.l	#80,d2
	jsr	Print_centered_string
	lea.l	Condition_list,a3		; (for the names)
	move.w	Body_conditions(a1),d6	; Dead or alive ?
	move.w	d6,d0
	andi.w	#Dead_mask,d0
	beq.s	.Alive
	moveq.l	#96,d0			; Display cross icon
	moveq.l	#124,d1
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	#Dead,(a3)+
	lea.l	Status_icons+(Dead_icon-1)*16*8,a0
	jsr	Put_masked_icon
	bra.s	.Done
.Alive:	lea.l	Bodymind_pos,a2
	lea.l	Condition_icon_table,a4
.Again:	moveq.l	#0,d7			; Get condition number
	move.b	(a4),d7
	cmp.b	#-1,d7			; Last one ?
	beq.s	.Done
	btst	d7,d6			; Got it ?
	beq.s	.Next
	moveq.l	#96,d0			; Get coordinates
	moveq.l	#124,d1
	add.w	(a2)+,d0
	add.w	(a2)+,d1
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d7,(a3)+
	moveq.l	#0,d4			; Get icon address
	move.b	1(a4),d4
	subq.w	#1,d4
	lsl.w	#7,d4			; (16 x 8 bytes)
	lea.l	Status_icons,a0
	add.w	d4,a0
	jsr	Put_masked_icon		; Display icon
.Next:	addq.l	#2,a4			; Next body condition
	bra.s	.Again
.Done:	move.w	#-1,(a3)			; End of list
	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Find the condition under the mouse ]
;  OUT : a0 - Pointer to name / 0 = none (.l)
; Changed registers : a0
; NOTE :
;   - From [ Condition_touched ] : the name of a condition which makes
;     the member inactive is shown in light blue, the others in yellow.
;*****************************************************************************
Condition_touched:
	movem.l	d0-d3/a1,-(sp)
	sub.l	a0,a0
	move.w	Mouse_X,d2
	move.w	Mouse_Y,d3
	lea.l	Condition_list,a1
.Loop:	move.w	(a1)+,d0			; End of list ?
	bmi.s	.Exit
	move.w	(a1)+,d1
	addq.l	#2,a1
	cmp.w	d0,d2			; Mouse inside ?
	bmi.s	.Loop
	addi.w	#16,d0
	cmp.w	d0,d2
	bpl.s	.Loop
	cmp.w	d1,d3
	bmi.s	.Loop
	addi.w	#16,d1
	cmp.w	d1,d3
	bpl.s	.Loop
	move.w	-2(a1),d0			; Yes -> get name
	move.w	#Yellow,Ghost_ink
	move.w	#Active_mask,d1
	btst	d0,d1
	beq.s	.Ink
	move.w	#Lighter_blue,Ghost_ink
.Ink:	addi.w	#Condition_names,d0
	jsr	Get_text
.Exit:	movem.l	(sp)+,d0-d3/a1
	rts

;*****************************************************************************
; [ Update small member info ]
; All registers are restored
; NOTE :
;   - From INVENTOR.S (without the spells which change the protection and
;     the damage).
;*****************************************************************************
Update_small_member_info:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	#Info_X,d0		; Clear area
	move.w	#85+7,d1
	move.w	#303,d2
	move.w	#128,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	jsr	Get_inventory_char
	moveq.l	#"0",d6
	moveq.l	#3,d7
	move.w	#White,Ink_colour
	move.w	#Default_shadow,Shadow_colour
; ---------- Print member's life points -----------
	moveq.l	#LP_txt,d0
	jsr	Copy_text
	move.w	Life_points(a1),d0
	lea.l	5(a2),a0
	jsr	DecR_convert
	move.b	#"/",(a0)
	move.w	Life_points+Maximum(a1),d0
	add.w	Life_points+Magic(a1),d0
	lea.l	9(a2),a0
	jsr	DecR_convert
	move.w	#Info_X+12,d0
	move.w	#85+7,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Print member's power points ----------
	tst.b	Spell_class_counter(a1)	; Any spell classes ?
	beq	.No_magic
	moveq.l	#PP_txt,d0
	jsr	Copy_text
	move.w	Power_points+Maximum(a1),d0
	add.w	Power_points+Magic(a1),d0
	lea.l	9(a2),a0
	jsr	DecR_convert
	move.w	Power_points(a1),d0
	lea.l	5(a2),a0
	jsr	DecR_convert
	move.b	#"/",(a0)
	move.w	#Info_X+12,d0
	move.w	#85+14,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Print member's spell learn points ----
	moveq.l	#SLP_txt,d0
	jsr	Copy_text
	move.w	Nr_spell_learn_points(a1),d0
	lea.l	4(a2),a0
	jsr	DecR_convert
	move.w	#Info_X+6,d0
	move.w	#85+21,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Display gold & food ------------------
.No_magic:	moveq.l	#Goldfood_txt,d0
	jsr	Copy_text
	move.w	Gold_coins(a1),d0
	moveq.l	#5,d7
	lea.l	2(a2),a0
	jsr	DecR_convert
	move.b	#" ",(a0)
	move.w	Food_rations(a1),d0
	lea.l	10(a2),a0
	moveq.l	#4,d7
	jsr	DecR_convert
	move.w	#Info_X+6,d0
	move.w	#85+28,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Display sword & shield icons ---------
	move.w	#Info_X+6,d0
	move.w	#85+35,d1
	moveq.l	#1,d6
	moveq.l	#9,d7
	lea.l	Swordshield,a0
	jsr	Put_masked_block
	addi.w	#47,d0
	lea.l	9*8(a0),a0
	jsr	Put_masked_block
; ---------- Display protection -------------------
	moveq.l	#ProtDam_txt,d0
	jsr	Copy_text
	move.w	Protection(a1),d0
	add.w	Protection_magic(a1),d0
	moveq.l	#"0",d6
	moveq.l	#3,d7
	lea.l	1(a2),a0
	jsr	SDecR_convert
	move.w	#Info_X+60,d0
	move.w	#85+35+2,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Display damage -----------------------
	moveq.l	#ProtDam_txt,d0
	jsr	Copy_text
	move.w	Damage(a1),d0
	add.w	Damage_magic(a1),d0
	lea.l	1(a2),a0
	jsr	SDecR_convert
	move.w	#Info_X+12,d0
	move.w	#85+35+2,d1
	move.l	a2,a0
	jsr	Put_text_line
; ---------- Print member's training points -------
	moveq.l	#TP_txt,d0
	jsr	Copy_text
	move.w	Nr_training_points(a1),d0
	moveq.l	#"0",d6
	moveq.l	#3,d7
	lea.l	3(a2),a0
	jsr	DecR_convert
	move.w	#Info_X+54,d0
	move.w	#85+21,d1
	move.l	a2,a0
	jsr	Put_text_line
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Update weight display ]
; All registers are restored
; NOTE :
;   - From INVENTOR.S (without blinking).
;*****************************************************************************
Update_weight:
	movem.l	d0-d7/a0-a2,-(sp)
	moveq.l	#26,d0			; Make box
	move.w	#151,d1
	moveq.l	#70,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box2
	move.w	#White,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	move.l	d0,-(sp)
	moveq.l	#Weight_txt,d0		; Print "WEIGHT"
	jsr	Get_text
	move.l	(sp)+,d0
	addq.w	#1,d0
	addq.w	#2,d1
	jsr	Print_centered_string
	jsr	Get_inventory_char
	move.l	Weight_normal(a1),d2
	divu.w	#1000,d2
	move.w	AStrength(a1),d3
	add.w	AStrength+Magic(a1),d3
	cmp.w	d2,d3			; Too heavy ?
	bpl.s	.Ok
	move.w	#Red,Ink_colour
.Ok:	moveq.l	#Weight_kg_txt,d0
	jsr	Copy_text
	move.l	a2,a0			; Convert normal weight
	moveq.l	#"0",d6
	moveq.l	#3,d7
	move.w	d2,d0
	jsr	DecR_convert
	move.b	#"K",(a0)
	lea.l	6(a2),a0			; Convert maximum weight
	move.w	d3,d0
	jsr	DecR_convert
	move.b	#"K",(a0)
	moveq.l	#26,d0			; Print weight
	move.w	#160,d1
	moveq.l	#70,d2
	move.l	a2,a0
	jsr	Print_centered_string
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Display the body objects ]
; All registers are restored
; NOTE :
;   - From INVENTOR.S : a double-handed weapon or ring is marked with a
;     cross over the other hand or ringfinger.
;*****************************************************************************
Display_body_objects:
	movem.l	d0-d7/a0-a3,-(sp)
	moveq.l	#1,d0			; Display objects
.Loop:	jsr	Display_body_object
	addq.w	#1,d0
	cmp.w	#9+1,d0
	bmi.s	.Loop
; ---------- Handle hands exception ---------------
	moveq.l	#Right_hand+1,d0		; In right hand ?
	jsr	Get_packet
	move.w	Object_index(a0),d0
	beq.s	.No
	jsr	Get_item_data
	cmpi.b	#2,Hand_use(a1)		; Double-handed ?
	bne.s	.No
	lea.l	Body_pos_list+Left_hand*4,a3
	jsr	.Cross
.No:	moveq.l	#Right_finger+1,d0		; In right finger ?
	jsr	Get_packet
	move.w	Object_index(a0),d0
	beq.s	.Exit
	jsr	Get_item_data
	cmpi.b	#2,Ring_use(a1)		; Double-handed ?
	bne.s	.Exit
	lea.l	Body_pos_list+Left_finger*4,a3
	jsr	.Cross
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

; Erase the slot at (a3) and display a cross (object graphic 0)
.Cross:	move.w	(a3),d0
	move.w	2(a3),d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	moveq.l	#1,d6
	moveq.l	#16,d7
	lea.l	Object_icons,a0
	jmp	Put_masked_block

;*****************************************************************************
; [ Display a body object ]
;   IN : d0 - Slot number {1...9} (.w)
; All registers are restored
; NOTE :
;   - From DISPLAY.S.
;*****************************************************************************
Display_body_object:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Body_pos_list-4,a3		; Find coordinates
	move.w	d0,d1
	lsl.w	#2,d1
	add.w	d1,a3
	jsr	Get_packet
	move.l	a0,a2
	move.w	(a3),d0			; Erase area
	move.w	2(a3),d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	move.w	Object_index(a2),d0		; Any object ?
	beq.s	.Exit
	jsr	Get_item_data
	jsr	Get_item_graphic
	move.w	(a3),d0			; Display object
	move.w	2(a3),d1
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Update the backpack slots ]
; All registers are restored
; NOTE :
;   - From [ Update_objects ] (DISPLAY.S).
;*****************************************************************************
Update_objects:
	move.l	d0,-(sp)
	moveq.l	#1,d0
.Loop:	jsr	Display_object
	addq.w	#1,d0
	cmp.w	#12+1,d0
	bmi.s	.Loop
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Display an object of the backpack or a chest ]
;   IN : d0 - Slot number {1...12} (.w)
; All registers are restored
; NOTE :
;   - From DISPLAY.S. [ Scroll_bar_result ] is added to the slot number, the
;     packets are at [ Slot_base ], the positions in the scroll bar
;     descriptor [ SB_ptr ].
;*****************************************************************************
Display_object:
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	SB_ptr,a3			; Find coordinates
	move.l	SBD_pos_list(a3),a3
	subq.w	#1,d0
	move.w	d0,d1
	lsl.w	#2,d1
	add.w	d1,a3
	add.w	Scroll_bar_result,d0	; Get packet
	mulu.w	#Object_packet_size,d0
	move.l	Slot_base,a2
	add.l	d0,a2
	move.w	(a3),d0			; Erase area
	move.w	2(a3),d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#24-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	move.w	Object_index(a2),d0		; Any object ?
	beq.s	.Exit
	jsr	Get_item_data
	jsr	Get_item_graphic
	move.w	(a3),d0			; Display object
	move.w	2(a3),d1
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block
	moveq.l	#0,d0			; Get quantity
	move.b	Quantity(a2),d0
	cmp.b	#1,d0			; Just one ?
	beq.s	.Exit
	lea.l	Number,a0			; Display quantity
	moveq.l	#2,d7
	jsr	DecL_convert
	move.w	#White,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	lea.l	Number,a0
	move.w	(a3),d0
	addi.w	#17,d1
	moveq.l	#16,d2
	jsr	Print_centered_string
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Display control icons ]
;   IN : a0 - Pointer to control icon list (9 words) (.l)
; All registers are restored
; NOTE :
;   - From HULL/CONTROLS.S : disabled icons (bit 15) are chequered.
;*****************************************************************************
Display_CIL:
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	a0,a2
	lea.l	Icon_pos,a3
	moveq.l	#9-1,d2
.Loop:	move.w	(a3)+,d0			; Get coordinates
	move.w	(a3)+,d1
	move.w	(a2)+,d3			; Display button
	jsr	Display_up_button
	tst.w	d3			; Disabled ?
	bpl.s	.Next
	movem.l	d1/d2,-(sp)		; Chequer it
	addq.w	#3,d1
	moveq.l	#2,d6
	moveq.l	#11,d7
	lea.l	Chequered,a0
	jsr	Put_masked_block
	movem.l	(sp)+,d1/d2
.Next:	dbra	d2,.Loop
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; Show the exit icon pressed until the mouse button is released
Press_exit_icon:
	movem.l	d0/d1/d3,-(sp)
	move.w	Icon_pos+2*4,d0
	move.w	Icon_pos+2*4+2,d1
	moveq.l	#Exit_cicon,d3
	jsr	Display_down_button
	jsr	Copy_screen_to_both
.Wait:	jsr	Switch_screens
	btst	#Left_pressed,Mouse_buttons
	bne.s	.Wait
	jsr	Display_up_button
	movem.l	(sp)+,d0/d1/d3
	rts

;*****************************************************************************
; [ Scroll bar ]
; NOTE :
;   - From HULL/CONTROLS.S, for the scroll bar descriptor [ SB_ptr ].
;*****************************************************************************
; [ Set the scroll bar row ]
;   IN : d0 - Row (.w)
; All registers are restored
Set_scroll_row:
	movem.l	d0/d1/a0,-(sp)
	move.l	SB_ptr,a0
	tst.w	d0
	bpl.s	.Ok1
	moveq.l	#0,d0
.Ok1:	cmp.w	SBD_max_row(a0),d0
	ble.s	.Ok2
	move.w	SBD_max_row(a0),d0
.Ok2:	move.w	d0,Scroll_row
	move.w	d0,d1
	mulu.w	SBD_units(a0),d1
	move.w	d1,Scroll_bar_result
	mulu.w	SBD_row_height(a0),d0
	sf	d1
	jsr	Draw_scroll_bar
	move.l	SBD_update(a0),a0		; Show the slots
	jsr	(a0)
	movem.l	(sp)+,d0/d1/a0
	rts

; [ Draw scroll bar ]
;   IN : d0 - Y-offset of the thingy (.w)
;        d1 - Thingy selected (.b)
; All registers are restored
Draw_scroll_bar:
	movem.l	d0-d6/a0/a1,-(sp)
	move.l	SB_ptr,a0
	lea.l	Unselected_thingy_colours,a1
	tst.b	d1
	beq.s	.Do
	lea.l	Selected_thingy_colours,a1
.Do:	move.w	d0,d6
; ---------- Draw scroll bar ----------------------
	move.w	SBD_X(a0),d0		; First box
	move.w	SBD_Y(a0),d1
	move.w	d0,d2
	addq.w	#6-1,d2
	move.w	d1,d3
	add.w	SBD_height(a0),d3
	subq.w	#1,d3
	moveq.l	#26,d4
	jsr	Draw_box
	addq.w	#1,d0			; Second box
	addq.w	#1,d1
	moveq.l	#27,d4
	jsr	Draw_box
; ---------- Draw thingy --------------------------
	move.w	SBD_X(a0),d0		; First box
	move.w	SBD_Y(a0),d1
	add.w	d6,d1
	move.w	d0,d2
	addq.w	#6-1,d2
	move.w	d1,d3
	add.w	SBD_thingy_height(a0),d3
	subq.w	#1,d3
	move.w	(a1)+,d4
	jsr	Draw_box
	addq.w	#1,d0			; Second box
	addq.w	#1,d1
	move.w	(a1)+,d4
	jsr	Draw_box
	subq.w	#1,d0			; Third box
	subq.w	#1,d1
	subq.w	#1,d2
	subq.w	#1,d3
	move.w	(a1)+,d4
	jsr	Draw_box
	addq.w	#1,d0			; Fourth box
	addq.w	#1,d1
	move.w	(a1)+,d4
	jsr	Draw_box
	subq.w	#1,d0			; Fifth box (pixel)
	subq.w	#1,d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	(a1)+,d4
	jsr	Draw_box
	add.w	SBD_thingy_height(a0),d1	; Shadow
	move.w	SBD_Y(a0),d3		; Thingy at the bottom ?
	add.w	SBD_height(a0),d3
	subq.w	#1,d3
	cmp.w	d3,d1
	bgt.s	.Exit
	move.w	d0,d2			; Draw shadow under thingy
	addq.w	#6-1,d2
	move.w	d1,d3
	moveq.l	#26,d4
	jsr	Draw_box
.Exit:	movem.l	(sp)+,d0-d6/a0/a1
	rts

; [ Scroll bar pressed ]
; All registers are restored
Scroll_bar_pressed:
	movem.l	d0-d4/a0,-(sp)
	move.l	SB_ptr,a0
	move.w	Scroll_row,d2		; Get thingy position
	mulu.w	SBD_row_height(a0),d2
	add.w	SBD_Y(a0),d2
	move.w	Mouse_Y,d0
	cmp.w	d2,d0			; Above thingy ?
	bpl.s	.Not_above
	move.w	Scroll_row,d0		; Half page up
	sub.w	SBD_half(a0),d0
	bra.s	.Set
.Not_above:	add.w	SBD_thingy_height(a0),d2	; Below thingy ?
	cmp.w	d2,d0
	bmi.s	.In
	move.w	Scroll_row,d0		; Half page down
	add.w	SBD_half(a0),d0
.Set:	jsr	Set_scroll_row
	jsr	Copy_screen_to_both
	bra	.Exit
; ---------- Drag scroll thingy -------------------
.In:	clr.l	Ghost_text
	sub.w	SBD_thingy_height(a0),d2	; Grab offset
	sub.w	d2,d0
	move.w	d0,d3
	move.w	SBD_max_row(a0),d4		; Maximum offset
	mulu.w	SBD_row_height(a0),d4
.Again:	move.w	Mouse_Y,d0		; Get position
	sub.w	d3,d0
	sub.w	SBD_Y(a0),d0
	bpl.s	.Ok1
	moveq.l	#0,d0
.Ok1:	cmp.w	d4,d0
	ble.s	.Ok2
	move.w	d4,d0
.Ok2:	move.w	d0,d2
	move.w	SBD_row_height(a0),d1	; Get row
	lsr.w	#1,d1
	add.w	d1,d0
	ext.l	d0
	divu.w	SBD_row_height(a0),d0
	cmp.w	Scroll_row,d0		; Update needed ?
	beq.s	.No
	jsr	Set_scroll_row
.No:	move.w	d2,d0			; Show thingy
	st	d1
	jsr	Draw_scroll_bar
	jsr	Copy_screen_to_both
	jsr	Switch_screens
	btst	#Left_pressed,Mouse_buttons	; Still pressed ?
	bne.s	.Again
	move.w	Scroll_row,d0		; Deselect
	jsr	Set_scroll_row
	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Take an item from the body ]
;   IN : d0 - Slot number {1...9} (.w)
; All registers are restored
; NOTE :
;   - From [ Move_body_item ].
;*****************************************************************************
Move_body_item:
	movem.l	d0-d3/a0-a2,-(sp)
	move.w	d0,d2
	jsr	Get_packet
	move.l	a0,a2
	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Exit
	jsr	Get_item_data
	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed ?
	beq.s	.No
	moveq.l	#42,d0			; Cursed !
	jsr	Do_prompt
	bra.s	.Exit
.No:	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	jsr	Get_inventory_char		; Remove item
	move.l	a1,a0
	moveq.l	#1,d3
	jsr	Remove_item
	jsr	Display_body_objects
	move.w	d2,Source_slot		; Move it !
	jsr	Start_moving
.Exit:	movem.l	(sp)+,d0-d3/a0-a2
	rts

;*****************************************************************************
; [ Take an item from the backpack ]
;   IN : d0 - Slot number {1...12} (.w)
;        [ Right_move ] - Take the whole stack (right mouse button) (.b)
; All registers are restored
; NOTE :
;   - From [ Move_backpack_item ] and [ Move_all_backpack_items ] : the
;     left mouse button asks how many items of a stack are taken.
;*****************************************************************************
Move_backpack_item:
	movem.l	d0-d3/a0-a2,-(sp)
	move.w	d0,d1
	addi.w	#9,d0
	add.w	Scroll_bar_result,d0
	move.w	d0,d2
	jsr	Get_packet
	move.l	a0,a2
	tst.w	Object_index(a2)		; Anything there ?
	beq.s	.Exit
	moveq.l	#0,d3			; How many ?
	move.b	Quantity(a2),d3
	cmp.w	#1,d3
	beq.s	.Take
	tst.b	Right_move		; All ?
	bne.s	.Take
	moveq.l	#54,d0			; No -> ask
	jsr	Ask_quantity
	move.l	d0,d3
	beq.s	.Exit
.Take:	lea.l	Inter_packet,a0		; Copy packet
	Copy_packet a2,a0
	move.b	d3,Quantity(a0)
	jsr	Get_inventory_char		; Remove item(s)
	move.l	a1,a0
	jsr	Remove_item
	move.w	d1,d0
	jsr	Display_object
	move.w	d2,Source_slot		; Move it !
	jsr	Start_moving
.Exit:	movem.l	(sp)+,d0-d3/a0-a2
	rts

;*****************************************************************************
; [ Start / stop moving an item ]
; All registers are restored
; NOTE :
;   - Like [ Move_item_DisInit ] and [ Move_item_DisExit ].
;*****************************************************************************
Start_moving:
	movem.l	d0/a0,-(sp)
	st	Moving_flag
	move.w	Inventory_member,Moving_member
	clr.l	Ghost_text
	jsr	Init_moving_item
	lea.l	Pick_pointer,a0
	jsr	Change_Mptr
	moveq.l	#55,d0			; "Where to ?"
	jsr	Print_prompt
	jsr	Update_weight
	jsr	Update_small_member_info
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0/a0
	rts

Stop_moving:
	move.l	a0,-(sp)
	sf	Moving_flag
	clr.l	Drag_graphic
	lea.l	Mouse_pointer,a0
	jsr	Change_Mptr
	jsr	Erase_PA
	jsr	Hide_status_icons
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Make the graphic of the moved item ]
; All registers are restored
; NOTE :
;   - Like [ Create_object_graphics ], but the item is a white silhouette
;     (ST colour 1, which is white in the UI and the inventory palette), so
;     it can be dragged onto the portraits.
;*****************************************************************************
Init_moving_item:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Drag_buffer,a2		; Clear
	moveq.l	#24*2-1,d7
.Clear:	clr.l	(a2)+
	dbra	d7,.Clear
	lea.l	Inter_packet,a3
	move.w	Object_index(a3),d0		; Get graphic
	jsr	Get_item_data
	jsr	Get_item_graphic
	lea.l	Drag_buffer,a2		; Make silhouette
	moveq.l	#16-1,d7
.Loop:	movem.w	(a0)+,d0-d3
	or.w	d1,d0
	or.w	d2,d0
	or.w	d3,d0
	move.w	d0,(a2)
	addq.l	#8,a2
	dbra	d7,.Loop
; ---------- Quantity -----------------------------
	moveq.l	#0,d0
	move.b	Quantity(a3),d0
	cmp.b	#1,d0			; Just one ?
	beq	.Done
	lea.l	Number,a0			; Convert quantity
	moveq.l	#2,d7
	jsr	DecL_convert
	move.l	Work_screen,-(sp)		; Draw it on a dummy screen
	move.l	#Window_background,Work_screen
	lea.l	Window_background,a0	; Clear
	move.w	#Char_height*ST_bytes_per_line/4-1,d7
.Clear2:	clr.l	(a0)+
	dbra	d7,.Clear2
	move.w	Ink_colour,-(sp)
	move.w	Shadow_colour,-(sp)
	move.w	#1,Ink_colour		; (no palette translation there)
	move.w	#-1,Shadow_colour
	move.l	Current_RL_ptr,-(sp)
	clr.l	Current_RL_ptr
	lea.l	Number,a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#16,d2
	jsr	Print_centered_string
	move.l	(sp)+,Current_RL_ptr
	move.w	(sp)+,Shadow_colour
	move.w	(sp)+,Ink_colour
	move.l	(sp)+,Work_screen
	lea.l	Window_background,a0	; Copy to the graphic
	lea.l	Drag_buffer+17*8,a2
	moveq.l	#Char_height-1,d7
.Copy:	move.w	(a0),(a2)
	lea.l	ST_bytes_per_line(a0),a0
	addq.l	#8,a2
	dbra	d7,.Copy
.Done:	move.l	#Drag_buffer,Drag_graphic
	jsr	Show_transfer_victims
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Player clicked on the body while moving an item ]
; All registers are restored
; NOTE :
;   - From [ Body_item_moved ] : the item goes to its place on the body
;     (whichever body slot was clicked). An item there is swapped.
;*****************************************************************************
Body_item_moved:
	movem.l	d0-d7/a0-a4,-(sp)
	sf	Object_swap_flag		; No swap
	jsr	Get_inventory_char		; (a1 = item, a4 = character)
	move.l	a1,a4
	lea.l	Inter_packet,a2
	move.w	Object_index(a2),d0
	jsr	Get_item_data
; ---------- Is this item equippable ? ------------
	moveq.l	#0,d0			; Get slot
	move.b	Item_body_place(a1),d0
	bne.s	.Equip_OK
	moveq.l	#34,d0			; Cannot do this !
	jsr	Do_prompt
	bra	.Exit
; ---------- Is the slot free ? -------------------
.Equip_OK:	move.w	d0,Target_slot
	jsr	Get_packet
	move.l	a0,a3
	move.w	Object_index(a3),d1		; Free ?
	beq	.Free
	cmp.w	#Right_finger+1,d0		; Exception ?
	bne.s	.Full
	moveq.l	#Left_finger+1,d0		; Other finger free ?
	move.w	d0,Target_slot
	jsr	Get_packet
	move.l	a0,a3
	move.w	Object_index(a3),d1
	beq	.Free
; ---------- Can the other slot be emptied ? ------
.Full:	move.l	a1,-(sp)
	move.w	d1,d0
	jsr	Get_item_data
	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed ?
	move.l	(sp)+,a1
	beq.s	.Swap
	moveq.l	#42,d0			; Cursed !
	jsr	Do_prompt
	bra	.Exit
; ---------- Swap ---------------------------------
.Swap:	cmp.b	#1,Quantity(a2)		; More than one ?
	bne	.Exit
	lea.l	Swap_packet,a0		; Save target packet
	Copy_packet a3,a0
	move.l	a4,a0			; Remove item
	move.w	Target_slot,d2
	moveq.l	#1,d3
	jsr	Remove_item
	st	Object_swap_flag
; ---------- Is it broken ? -----------------------
.Free:	btst	#Broken_item,Item_bits_DYNAMIC(a2)
	beq.s	.Not_broken
	move.w	#207,d0			; Broken !
	bra	.Refuse
; ---------- Do you have the right class ? --------
.Not_broken:
	move.b	Char_class(a4),d0		; Right class ?
	move.w	Class_use(a1),d1
	btst	d0,d1
	bne.s	.Class_OK
	moveq.l	#35,d0			; Wrong class !
	bra	.Refuse
; ---------- Do you have the right sex ? ----------
.Class_OK:	move.b	Char_sex(a4),d0		; Right sex ?
	move.b	Sex_use(a1),d1
	btst	d0,d1
	bne.s	.Sex_OK
	moveq.l	#36,d0			; Wrong sex !
	bra	.Refuse
; ---------- Do you have enough hands free ? ------
.Sex_OK:	move.b	Hand_use(a1),d0		; Does it matter ?
	beq.s	.Hands_OK
	moveq.l	#2,d1			; Maximum is two hands
	sub.b	Hands_occupied(a4),d1
	cmp.b	d0,d1
	bpl.s	.Hands_OK
	moveq.l	#37,d0			; Not enough hands free !
	bra	.Refuse
; ---------- Do you have enough fingers free ? ----
.Hands_OK:	move.b	Ring_use(a1),d0		; Does it matter ?
	beq.s	.Fingers_OK
	moveq.l	#2,d1			; Maximum is two ringfingers
	sub.b	Ringfingers_occupied(a4),d1
	cmp.b	d0,d1
	bpl.s	.Fingers_OK
	moveq.l	#38,d0			; Not enough fingers !
	bra	.Refuse
; ---------- Equip it -----------------------------
.Fingers_OK:
	move.l	a4,a1			; Add item
	lea.l	Inter_packet,a0
	move.w	Target_slot,d2
	jsr	Add_item_2_body
	tst.b	Object_swap_flag		; Move or swap ?
	beq.s	.Move
	lea.l	Swap_packet,a2		; Make new source packet
	lea.l	Inter_packet,a0
	Copy_packet a2,a0
	move.w	Target_slot,Source_slot	; Move this !
	move.w	Inventory_member,Moving_member
	jsr	Init_moving_item
	bra.s	.Show
.Move:	tst.w	Inter_packet+Object_index	; Any left ?
	beq.s	.All_gone
	jsr	Init_moving_item		; Yes -> Update
	bra.s	.Show
.All_gone:	jsr	Stop_moving		; No -> stop
.Show:	jsr	Display_body_objects
	jsr	Update_weight
	jsr	Update_small_member_info
	jsr	Copy_screen_to_both
	bra.s	.Exit
; ---------- Not possible -------------------------
.Refuse:	jsr	Do_prompt
	tst.b	Object_swap_flag		; Was anything swapped ?
	beq.s	.Exit
	move.l	a4,a1			; Put it back
	move.w	Target_slot,d2
	lea.l	Swap_packet,a0
	jsr	Add_item_2_body
.Exit:	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Player clicked on a backpack slot while moving an item ]
;   IN : d0 - Slot number {1...12} (.w)
; All registers are restored
; NOTE :
;   - From [ Backpack_item_moved ].
;*****************************************************************************
Backpack_item_moved:
	movem.l	d0-d7/a0-a4,-(sp)
	addi.w	#9,d0			; Get packet
	add.w	Scroll_bar_result,d0
	move.w	d0,Target_slot
	jsr	Get_packet
	move.l	a0,a2
	jsr	Get_inventory_char
	move.l	a1,a4
	lea.l	Inter_packet,a3
	move.w	Object_index(a3),d0		; Get item data
	jsr	Get_item_data
	move.w	Object_index(a2),d0		; Anything there ?
	beq	.Empty
	cmp.w	Object_index(a3),d0		; Same item ?
	bne	.Swap
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple ?
	beq	.Swap
; ---------- Add to non-empty slot ----------------
	cmpi.b	#99,Quantity(a2)		; Not full ?
	bcc	.Exit
	moveq.l	#0,d0			; Does it fit in the slot ?
	move.b	Quantity(a2),d0
	moveq.l	#0,d3
	move.b	Quantity(a3),d3
	add.w	d3,d0
	cmpi.w	#99,d0
	bls.s	.End
	moveq.l	#99,d0			; Calculate number that will
	sub.b	Quantity(a2),d0		;  fit
	move.b	#99,Quantity(a2)		; Fill slot
	sub.b	d0,Quantity(a3)		; Remove item(s)
	mulu.w	Weight(a1),d0		; Increase weight
	add.l	d0,Weight_normal(a4)
	jsr	Init_moving_item
	bra	.Show
.End:	add.b	d3,Quantity(a2)		; Transfer
	mulu.w	Weight(a1),d3		; Increase weight
	add.l	d3,Weight_normal(a4)
	clr.w	Object_index(a3)		; Destroy
	bra.s	.Done
; ---------- Fill empty slot ----------------------
.Empty:	Copy_packet a3,a2
	moveq.l	#0,d3			; Increase weight
	move.b	Quantity(a3),d3
	mulu.w	Weight(a1),d3
	add.l	d3,Weight_normal(a4)
	clr.b	Quantity(a3)		; Destroy item
	clr.w	Object_index(a3)
	bra.s	.Done
; ---------- Swap packets -------------------------
.Swap:	lea.l	Swap_packet,a0		; Save target packet
	Copy_packet a2,a0
	move.l	a4,a0			; Remove item
	move.w	Target_slot,d2
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	jsr	Remove_item
	Copy_packet a3,a2			; Copy packet
	moveq.l	#0,d3			; Increase weight
	move.b	Quantity(a3),d3
	mulu.w	Weight(a1),d3
	add.l	d3,Weight_normal(a4)
	lea.l	Swap_packet,a0		; Make new source packet
	Copy_packet a0,a3
	move.w	Target_slot,Source_slot	; Move this !
	move.w	Inventory_member,Moving_member
	jsr	Init_moving_item
	bra.s	.Show
.Done:	jsr	Stop_moving		; All gone
.Show:	jsr	Update_objects
	jsr	Update_weight
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Player clicked on a portrait while moving an item ]
;   IN : d0 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From [ Member_moved ] : the item goes into the backpack of the member,
;     if there is room and the member can carry it ([ Scan_4_transfer_victims ]).
;*****************************************************************************
Member_moved:
	movem.l	d0-d7/a0-a3,-(sp)
	move.w	d0,d7
	lea.l	Inter_packet,a2
	jsr	Check_transfer		; Possible ?
	bne.s	.Exit
	jsr	Get_char_data
	move.l	a1,a3
; ---------- Move it ------------------------------
.Do:	move.l	a3,a1
	move.l	a2,a0
	jsr	Auto_move_to_backpack
	tst.w	Object_index(a2)		; Any left ?
	bne.s	.Left
	jsr	Stop_moving		; No -> stop
	bra.s	.Show
.Left:	jsr	Init_moving_item		; Yes -> update
.Show:	jsr	Update_objects
	jsr	Update_weight
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Put the moved item back ]
; All registers are restored
; NOTE :
;   - Like [ Move_aborted ] : the item goes back to the slot where it came
;     from (or into the backpack, if the slot is used now).
;*****************************************************************************
Move_aborted:
	movem.l	d0-d7/a0-a3,-(sp)
	move.w	Moving_member,d7		; Same member ?
	jsr	Switch_inventory_member
	jsr	Get_inventory_char
	lea.l	Inter_packet,a3
	move.w	Source_slot,d0
	move.w	d0,d2
	jsr	Get_packet
	move.l	a0,a2
	cmp.w	#9+1,d2			; Body ?
	bpl.s	.Backpack
	tst.w	Object_index(a2)		; Free ?
	bne.s	.Auto
	move.l	a3,a0			; Yes -> put it back
	jsr	Add_item_2_body
	bra.s	.Done
.Backpack:	tst.w	Object_index(a2)		; Free ?
	bne.s	.Auto
	Copy_packet a3,a2			; Yes -> put it back
	move.w	Object_index(a3),d0		; Increase weight
	move.l	a1,-(sp)
	jsr	Get_item_data
	moveq.l	#0,d3
	move.b	Quantity(a3),d3
	mulu.w	Weight(a1),d3
	move.l	(sp)+,a1
	add.l	d3,Weight_normal(a1)
	clr.w	Object_index(a3)
	bra.s	.Done
.Auto:	move.l	a3,a0			; Into the backpack
	jsr	Auto_move_to_backpack
.Done:	jsr	Stop_moving
	jsr	Display_body_objects
	jsr	Update_objects
	jsr	Update_weight
	jsr	Update_small_member_info
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Automatically distribute items in backpack ]
;   IN : a0 - Pointer to source packet (.l)
;        a1 - Pointer to character data (.l)
; All registers are restored
; NOTE :
;   - From INVENTOR.S. Removes the items from the source packet.
;*****************************************************************************
Auto_move_to_backpack:
	movem.l	d0-d3/d7/a0-a4,-(sp)
	move.l	a0,a2
	move.l	a1,a0
	lea.l	Char_inventory+Backpack_slots(a0),a3	; Get target inventory
	move.w	Object_index(a2),d0		; Get object data
	jsr	Get_item_data
; ---------- Scan for slots with this item --------
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple ?
	beq	.Single
	move.l	a3,a4
	move.w	Object_index(a2),d2
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	moveq.l	#Items_per_char-1,d7
.Loop1:	move.w	Object_index(a4),d0		; Anything there ?
	beq.s	.Next1
	cmp.w	d2,d0			; Same item ?
	bne.s	.Next1
	cmpi.b	#99,Quantity(a4)		; Not full ?
	bcc.s	.Next1
	moveq.l	#0,d0			; Does it fit in the slot ?
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
.Next1:	addq.w	#Object_packet_size,a4
	dbra	d7,.Loop1
; ---------- Scan for free slot -------------------
	move.l	a3,a4
	moveq.l	#Items_per_char-1,d7
.Loop2:	tst.w	Object_index(a4)		; Free slot ?
	beq.s	.Do_it1
	addq.w	#Object_packet_size,a4
	dbra	d7,.Loop2
	bra.s	.Exit
.Do_it1:	Copy_packet a2,a4
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	clr.b	Quantity(a4)
.End:	sub.b	d3,Quantity(a2)		; Transfer
	add.b	d3,Quantity(a4)
	mulu.w	Weight(a1),d3		; Increase weight
	add.l	d3,Weight_normal(a0)
	bra.s	.Exit
; ---------- Scan for free slots in backpack ------
.Single:	move.l	a3,a4
	moveq.l	#Items_per_char-1,d7
.Loop3:	tst.w	Object_index(a4)		; Free slot ?
	beq.s	.Do_it2
	addq.w	#Object_packet_size,a4
	dbra	d7,.Loop3
	bra.s	.Exit
.Do_it2:	Copy_packet a2,a4
	subq.b	#1,Quantity(a2)
	move.b	#1,Quantity(a4)
	moveq.l	#0,d3			; Increase weight
	move.w	Weight(a1),d3
	add.l	d3,Weight_normal(a0)
.Exit:	tst.b	Quantity(a2)		; All gone ?
	bne.s	.Skip
	clr.w	Object_index(a2)		; Yes -> destroy item
.Skip:	movem.l	(sp)+,d0-d3/d7/a0-a4
	rts

;*****************************************************************************
; [ Remove item ]
;   IN : d2 - Slot number {1...33} (.w)
;        d3 - Quantity that is to be removed (backpack only) (.w)
;        a0 - Pointer to character data (.l)
; All registers are restored
; NOTE :
;   - From INVENTOR.S.
;*****************************************************************************
Remove_item:
	movem.l	d0/d1/a0-a3,-(sp)
	lea.l	Char_inventory(a0),a2	; Get packet address
	move.w	d2,d0
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data
	beq	.Exit
	jsr	Get_item_data
	cmp.w	#9+1,d2			; On body ?
	bmi.s	.Body
	moveq.l	#0,d0			; Reduce quantity
	move.b	Quantity(a2),d0
	sub.w	d3,d0
	bgt.s	.Yes			; Any left ?
	clr.w	Object_index(a2)		; Destroy item
	moveq.l	#0,d0
.Yes:	move.b	d0,Quantity(a2)
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
	mulu.w	#Skill_data_size,d0
	moveq.l	#0,d1
	move.b	Malus_1(a1),d1
	add.w	d1,Magic(a3,d0.w)
.No1:	moveq.l	#0,d0			; Skill tax 2
	move.b	Item_skill_2(a1),d0
	beq.s	.No2
	subq.w	#1,d0
	mulu.w	#Skill_data_size,d0
	moveq.l	#0,d1
	move.b	Malus_2(a1),d1
	add.w	d1,Magic(a3,d0.w)
.No2:	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed item ?
	bne.s	.Cursed
	jsr	Negative_boni		; Remove boni
	bra.s	.Go_on
.Cursed:	jsr	Positive_boni		; Add boni
.Go_on:	moveq.l	#0,d0			; Remove weight
	move.w	Weight(a1),d0
	sub.l	d0,Weight_normal(a0)
	clr.w	Object_index(a2)		; Destroy item
.Exit:	movem.l	(sp)+,d0/d1/a0-a3
	rts

;*****************************************************************************
; [ Add item to body ]
;   IN : d2 - Slot number {1...9} (.w)
;        a0 - Pointer to source packet (.l)
;        a1 - Pointer to character data (.l)
; All registers are restored
; NOTE :
;   - From INVENTOR.S. Removes ONE item from the source packet.
;*****************************************************************************
Add_item_2_body:
	movem.l	d0-d2/a0-a4,-(sp)
	move.l	a0,a4
	move.l	a1,a0
	lea.l	Char_inventory(a0),a2	; Get target packet address
	subq.w	#1,d2
	mulu.w	#Object_packet_size,d2
	add.l	d2,a2
	Copy_packet a4,a2
	move.b	#1,Quantity(a2)
	move.w	Object_index(a4),d0		; Get source object data
	jsr	Get_item_data
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
	mulu.w	#Skill_data_size,d0
	moveq.l	#0,d1
	move.b	Malus_1(a1),d1
	sub.w	d1,Magic(a3,d0.w)
.No1:	moveq.l	#0,d0			; Skill tax 2
	move.b	Item_skill_2(a1),d0
	beq.s	.No2
	subq.w	#1,d0
	mulu.w	#Skill_data_size,d0
	moveq.l	#0,d1
	move.b	Malus_2(a1),d1
	sub.w	d1,Magic(a3,d0.w)
.No2:	btst	#Cursed,Item_bits_STATIC(a1)	; Cursed item ?
	bne.s	.Cursed
	jsr	Positive_boni		; Add boni
	bra.s	.Go_on
.Cursed:	jsr	Negative_boni		; Remove boni
.Go_on:	moveq.l	#0,d0			; Add weight
	move.w	Weight(a1),d0
	add.l	d0,Weight_normal(a0)
	subq.b	#1,Quantity(a4)		; Remove 1 item
	bgt.s	.Exit			; All gone ?
	clr.b	Quantity(a4)
	clr.w	Object_index(a4)		; Yes -> destroy item
.Exit:	movem.l	(sp)+,d0-d2/a0-a4
	rts

;*****************************************************************************
; [ Give positive / negative boni ]
;   IN : a0 - Pointer to character data (.l)
;        a1 - Pointer to item data (.l)
; All registers are restored
; NOTE :
;   - From INVENTOR.S.
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
	move.b	Damage_pts(a1),d2		; Damage bonus
	add.w	d2,Damage_magic(a0)
	movem.l	(sp)+,d0-d2/a2
	rts

Negative_boni:
	movem.l	d0-d2/a2,-(sp)
	move.b	LP_max(a1),d2		; LP max bonus
	ext.w	d2
	sub.w	d2,Life_points+Magic(a0)
	move.b	SP_max(a1),d2		; SP max bonus
	ext.w	d2
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
	move.b	Damage_pts(a1),d2		; Damage bonus
	sub.w	d2,Damage_magic(a0)
	movem.l	(sp)+,d0-d2/a2
	rts

;*****************************************************************************
; [ Reset weight of party members ]
; All registers are restored
; NOTE :
;   - From INVENTOR.S.
;*****************************************************************************
Reset_party_weight:
	movem.l	d0-d2/d6/d7/a0-a2,-(sp)
	moveq.l	#1,d7
.Loop1:	jsr	Get_char_data
	move.l	a1,a0
	lea.l	Char_inventory(a0),a2	; Calculate weight of items
	moveq.l	#0,d2
	moveq.l	#Items_per_char+9-1,d6
.Loop2:	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Next2
	jsr	Get_item_data
	move.w	Weight(a1),d0		; Get weight
	moveq.l	#0,d1			; Get quantity
	move.b	Quantity(a2),d1
	mulu.w	d1,d0
	add.l	d0,d2
.Next2:	addq.w	#Object_packet_size,a2
	dbra	d6,.Loop2
	move.w	Gold_coins(a0),d0		; Add weight of gold
	mulu.w	#Gold_weight,d0
	add.l	d0,d2
	move.w	Food_rations(a0),d0		; Add weight of food
	mulu.w	#Food_weight,d0
	add.l	d0,d2
	move.l	d2,Weight_normal(a0)	; Repair weight
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop1
	movem.l	(sp)+,d0-d2/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Prompts ]
; NOTE :
;   - Like [ Print_prompt ] and [ Do_prompt ] (HULL/CONTROLS.S) with the
;     print area of the inventory (.PA of Inv2_Mod in MODULES.S).
;*****************************************************************************
; [ Print a prompt ]
;   IN : d0 - Message number (.w)
; All registers are restored
Print_prompt:
	move.l	a0,-(sp)
	addi.w	#Messages,d0
	jsr	Get_text
	addi.w	#-Messages,d0
	jsr	Print_PA_text
	move.l	(sp)+,a0
	rts

; [ Print a text in the print area (as many lines as fit) ]
;   IN : a0 - Pointer to text (.l)
; All registers are restored
Print_PA_text:
	movem.l	d0-d7/a0/a3/a4,-(sp)
	jsr	Erase_PA
	move.l	Print_area_ptr,a3
	move.w	PA_X2(a3),d2		; Width
	sub.w	PA_X1(a3),d2
	addq.w	#1,d2
	move.w	d2,d0
	ext.l	d0
	divu.w	#Char_width+1,d0
	move.w	d0,Text_width
	jsr	Process_text
	move.w	PA_Ink(a3),Ink_colour
	move.w	#Default_shadow,Shadow_colour
	lea.l	Text_lines,a4
	move.w	PA_Y2(a3),d0		; Lines that fit
	sub.w	PA_Y1(a3),d0
	ext.l	d0
	divu.w	#Char_height+2,d0
	move.w	Text_height,d7
	cmp.w	d0,d7
	bls.s	.Ok
	move.w	d0,d7
.Ok:	move.w	PA_X1(a3),d0
	move.w	PA_Y1(a3),d1
	addq.w	#1,d1
	bra.s	.Next
.Line:	move.l	a4,a0
	jsr	Print_centered_string
	lea.l	Line_stride(a4),a4
	addi.w	#Char_height+2,d1
.Next:	dbra	d7,.Line
	movem.l	(sp)+,d0-d7/a0/a3/a4
	rts

; [ Print a prompt and wait for the user ]
;   IN : d0 - Message number (.w)
; All registers are restored
Do_prompt:
	move.l	d0,-(sp)
	clr.l	Ghost_text
	jsr	Print_prompt
	jsr	Copy_screen_to_both
	jsr	Wait_for_click
	jsr	Erase_PA
	tst.b	Moving_flag		; Still moving ?
	beq.s	.No
	moveq.l	#55,d0			; "Where to ?"
	jsr	Print_prompt
.No:	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
	move.l	(sp)+,d0
	rts

; [ Erase the print area ]
; All registers are restored
Erase_PA:
	movem.l	d0-d4/a0,-(sp)
	move.l	Print_area_ptr,a0
	movem.w	(a0),d0/d2		; (X1, X2)
	movem.w	PA_Y1(a0),d1/d3		; (Y1, Y2)
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Draw a standard box (HIGH) ]
;   IN : d0 - Top-left X-coordinate (.w)
;        d1 - Top-left Y-coordinate (.w)
;        d2 - Width of box (.w)
;        d3 - Height of box (.w)
; All registers are restored
; NOTE :
;   - From HULL/CONTROLS.S.
;*****************************************************************************
Draw_standard_box2:
	movem.l	d0-d4,-(sp)
	add.w	d0,d2			; Draw dark edge
	add.w	d1,d3
	addq.w	#1,d0
	addq.w	#1,d1
	subq.w	#1,d2
	subq.w	#1,d3
	moveq.l	#26,d4
	jsr	Draw_box
	subq.w	#1,d0			; Draw light edge
	subq.w	#1,d1
	subq.w	#1,d2
	subq.w	#1,d3
	moveq.l	#30,d4
	jsr	Draw_box
	addq.w	#1,d0			; Draw main area
	addq.w	#1,d1
	moveq.l	#28,d4
	jsr	Draw_box
	subq.w	#1,d0			; Draw light spot
	subq.w	#1,d1
	move.w	d0,d2
	move.w	d1,d3
	moveq.l	#31,d4
	jsr	Draw_box
	movem.l	(sp)+,d0-d4
	rts

;*****************************************************************************
; [ Helpers ]
;*****************************************************************************
; [ Get the character data of the inventory member ]
;  OUT : a1 - Pointer to character data (.l)
; Changed registers : a1
Get_inventory_char:
	move.l	d7,-(sp)
	move.w	Inventory_member,d7
	jsr	Get_char_data
	move.l	(sp)+,d7
	rts

; [ Get the character data of a member ]
;   IN : d7 - Member number {1...6} (.w)
;  OUT : a1 - Pointer to character data (.l)
; Changed registers : a1
Get_char_data:
	move.l	d7,-(sp)
	lea.l	Party_chars,a1
	subq.w	#1,d7
	mulu.w	#512,d7
	add.l	d7,a1
	move.l	(sp)+,d7
	rts

; [ Get an object packet of the inventory member ]
;   IN : d0 - Slot number {1...33} (.w)
;  OUT : a0 - Pointer to object packet (.l)
; Changed registers : a0
Get_packet:
	movem.l	d0/a1,-(sp)
	jsr	Get_inventory_char
	lea.l	Char_inventory-Object_packet_size(a1),a0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	movem.l	(sp)+,d0/a1
	rts

; [ Get the packet of a slot ]
;   IN : d0 - Slot number : body {1...9} or slot under the scroll bar + 9 (.w)
;  OUT : a0 - Pointer to object packet (.l)
; Changed registers : a0
Get_slot_packet:
	cmp.w	#9+1,d0			; Body ?
	bmi	Get_packet
	move.l	d0,-(sp)			; No -> [ Slot_base ]
	subi.w	#9+1,d0
	mulu.w	#Object_packet_size,d0
	move.l	Slot_base,a0
	add.l	d0,a0
	move.l	(sp)+,d0
	rts

; [ Get item data ]
;   IN : d0 - Object index {1...} (.w)
;  OUT : a1 - Pointer to item data (.l)
; Changed registers : a1
Get_item_data:
	move.l	d0,-(sp)
	lea.l	Object_data+2-Item_data_size,a1
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	move.l	(sp)+,d0
	rts

; [ Get item graphic ]
;   IN : a1 - Pointer to item data (.l)
;  OUT : a0 - Pointer to graphic (16x16) (.l)
; Changed registers : a0
Get_item_graphic:
	move.l	d0,-(sp)
	moveq.l	#0,d0
	move.b	Item_pic(a1),d0
	lsl.w	#7,d0			; (16 x 8 bytes)
	lea.l	Object_icons,a0
	add.l	d0,a0
	move.l	(sp)+,d0
	rts

; [ Get a text of TEXTS.BIN ]
;   IN : d0 - Text number (.w)
;  OUT : a0 - Pointer to text (.l)
; Changed registers : a0
Get_text:
	move.l	d0,-(sp)
	lea.l	Texts,a0
	bra.s	.Next
.Loop:	tst.b	(a0)+
	bne.s	.Loop
.Next:	dbra	d0,.Loop
	move.l	(sp)+,d0
	rts

; [ Copy a text of TEXTS.BIN into the text buffer ]
;   IN : d0 - Text number (.w)
;  OUT : a2 - Pointer to the copy (.l)
; Changed registers : a2
Copy_text:
	move.l	a0,-(sp)
	jsr	Get_text
	lea.l	Inv_text_buffer,a2
.Loop:	move.b	(a0)+,(a2)+
	bne.s	.Loop
	lea.l	Inv_text_buffer,a2
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Number conversion ]
; NOTE :
;   - Like HULL/NUMERIC.S : the digits are followed by an EOL.
;*****************************************************************************
; [ Unsigned, right justified ]
;   IN : d0 - Number (.w)
;        d6 - Fill character (.b)
;        d7 - Number of digits (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to the EOL (.l)
; Changed registers : a0
DecR_convert:
	movem.l	d0-d2/d7,-(sp)
	andi.l	#$ffff,d0
	add.w	d7,a0			; Write backwards
	clr.b	(a0)
	move.l	a0,-(sp)
	subq.w	#1,d7
	moveq.l	#0,d2			; First digit
.Loop:	tst.l	d0			; Number done ?
	bne.s	.Digit
	tst.w	d2			; (at least one digit)
	beq.s	.Digit
	move.b	d6,-(a0)
	bra.s	.Next
.Digit:	divu.w	#10,d0
	swap	d0
	addi.b	#"0",d0
	move.b	d0,-(a0)
	clr.w	d0
	swap	d0
.Next:	moveq.l	#1,d2
	dbra	d7,.Loop
	move.l	(sp)+,a0
	movem.l	(sp)+,d0-d2/d7
	rts

; [ Signed, right justified (sign + digits) ]
;   IN : d0 - Number (.w)
;        d6 - Fill character (.b)
;        d7 - Number of digits (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to the EOL (.l)
; Changed registers : a0
SDecR_convert:
	move.l	d0,-(sp)
	move.b	#" ",(a0)			; Insert sign
	tst.w	d0
	beq.s	.Do
	move.b	#"+",(a0)
	tst.w	d0
	bpl.s	.Do
	move.b	#"-",(a0)
	neg.w	d0
.Do:	addq.l	#1,a0
	jsr	DecR_convert
	move.l	(sp)+,d0
	rts

; [ Unsigned, left justified ]
;   IN : d0 - Number (.l)
;        d7 - Maximum number of digits (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to the EOL (.l)
; Changed registers : a0
DecL_convert:
	movem.l	d0-d2/d7/a1/a2,-(sp)
	lea.l	Number_digits+12,a2		; Digits backwards
	move.l	a2,a1
.Loop:	move.l	d0,d1			; Divide by 10 (32 bit)
	clr.w	d1
	swap	d1
	divu.w	#10,d1
	move.w	d1,d2
	swap	d2
	move.w	d0,d1
	divu.w	#10,d1
	move.w	d1,d2
	swap	d1			; Remainder
	addi.b	#"0",d1
	move.b	d1,-(a1)
	move.l	d2,d0
	subq.w	#1,d7
	beq.s	.Copy
	tst.l	d0
	bne.s	.Loop
.Copy:	cmp.l	a2,a1			; Copy digits
	beq.s	.End
	move.b	(a1)+,(a0)+
	bra.s	.Copy
.End:	clr.b	(a0)
	movem.l	(sp)+,d0-d2/d7/a1/a2
	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

; Raster list of the inventory (Inv_RL in MODULES.S)
Inv_RL:	R_palette 0,UI_palette
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Inv_palette
	R_range Info_Y,25,35,Portrait_range
	R_end
	even

; Print area of the inventory (.PA of Inv2_Mod in MODULES.S)
Inv_PA:	dc.w 21,181,50,70,White

; Raster list of the character screen (Inv_RL with its own palette)
Char_RL:	R_palette 0,UI_palette
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Char_palette
	R_range Info_Y,25,35,Portrait_range
	R_end
	even

; Control icon lists (Inv1_CIL and Inv2_CIL in INVENTOR.S) : the item
; functions are not possible in the proof of concept
Disabled	EQU	$8000
Inv1_CIL:	dc.w Backpack_cicon,0,Exit_cicon
	dc.w 0,0,0
	dc.w 0,0,0
Inv2_CIL:	dc.w Stats_cicon,Use_item_cicon,Exit_cicon
	dc.w Drop_item_cicon,Drop_gold_cicon,Drop_food_cicon
	dc.w View_item_cicon,Transfer_gold_cicon,Transfer_food_cicon

; Objects under the mouse
	rsreset
	rs.b 1
Obj_member:	rs.b 1
Obj_body:	rs.b 1
Obj_backpack:	rs.b 1
Obj_scroll_bar:	rs.b 1
Obj_icon:	rs.b 1

; The following two lists MUST follow each other ! (INVENTOR.S)
Body_pos_list:
	dc.w 20,72,52,72,84,72
	dc.w 20,124,84,97,84,124
	dc.w 20,176,52,176,84,176
Backpack_pos_list:
	dc.w 109,76,131,76,153,76
	dc.w 109,105,131,105,153,105
	dc.w 109,134,131,134,153,134
	dc.w 109,163,131,163,153,163

; Positions of the condition icons relative to 96,124 (INVENTOR.S)
Bodymind_pos:
	dc.w 0,0,32,0,64,0
	dc.w 16,16,48,16
	dc.w 0,32,32,32,64,32
	dc.w 16,48,48,48

; Conditions and their status icons (INVENTOR.S)
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

; Scroll bar of the backpack (Inv2_scroll_bar in INVENTOR.S : 8 rows of 3
; slots, 4 rows visible)
Backpack_bar:	dc.l Backpack_pos_list
	dc.w 175,76,112,112/8,112-4*(112/8),4,3,2
	dc.l Update_objects

; Scroll bar thingy colours (HULL/CONTROLS.S)
Unselected_thingy_colours:
	dc.w 28,27,30,29,31
Selected_thingy_colours:
	dc.w 29,28,31,30,31

; Files loaded when the inventory is opened
Inventory_files:
	dc.l	Extra_layout,320*163/2
	dc.b	"DATA\LAYOUT2.BIN",0
	even
	dc.l	0
Character_files:
	dc.l	Extra_layout,320*163/2
	dc.b	"DATA\LAYOUT6.BIN",0
	even
	dc.l	0

	SECTION	Fast_BSS,bss
Inventory_member:	ds.w 1
Inventory_mode:	ds.w 1			; 1 = Inventory 1, 2 = Inventory 2
Small_portraits:	ds.l 1
Condition_list:	ds.w 3*12+1		; X, Y, condition / -1
Inventory_scroll_positions:	ds.w 6
Scroll_row:	ds.w 1
SB_ptr:	ds.l 1			; Scroll bar descriptor
Print_area_ptr:	ds.l 1			; Print area (X1, X2, Y1, Y2)
Slot_base:	ds.l 1			; Packets of the slots under the scroll bar
Scroll_bar_result:	ds.w 1
Source_slot:	ds.w 1
Target_slot:	ds.w 1
Moving_member:	ds.w 1
Inter_packet:	ds.b Object_packet_size
Swap_packet:	ds.b Object_packet_size
Moving_flag:	ds.b 1
Object_swap_flag:	ds.b 1
Right_move:	ds.b 1			; Take the whole stack
Inventory_exit:	ds.b 1
	even
Number:	ds.b 12
Price_text:	ds.b 8
Price_ghost:	ds.b 1			; Show the price of an item above its name
	even
Number_digits:	ds.b 12
Inv_text_buffer:	ds.b 64
Drag_buffer:	ds.b 24*8			; Moved item (16x24)
Inv_palette:	ds.b 64
Inv_portraits:	ds.b 6*34*2*8
Char_palette:	ds.b 64
Char_portraits:	ds.b 6*34*2*8
Status_icons:	ds.b 22*16*8
Inv_graphics:					; INVGFX.BIN
Swordshield:	ds.b 2*9*8
Chequered:	ds.b 11*2*8
Pick_pointer:	ds.b 4+16*8
Object_icons:	ds.b 188*16*8
Object_data:	ds.b 2+402*Item_data_size
Texts:	ds.b 20*1024
	even
