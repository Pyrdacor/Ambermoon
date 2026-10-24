; Proof of concept : item functions of the inventory (Atari ST)
;
; From INVENTOR.S, DISPLAY.S, MAGIC.S and HULL/CONTROLS.S :
;   - the Accept / Refuse status icons on the portraits while an item is
;     moved (who can take it),
;   - selecting an item, the Yes / No requester and selecting a member,
;   - dropping, viewing (item view windows 1 & 2) and using items : magic
;     items with the spells which work on party members (healing, removing
;     conditions, spell points, attributes, ...), text scrolls and special
;     items.

	SECTION	Program,code

; Text numbers in TEXTS.BIN
Both_txt	EQU	11
Classes_txt	EQU	26
Sex_txt	EQU	27
Weight2_txt	EQU	28
Hands_txt	EQU	29
Fingers_txt	EQU	30
Damage_txt	EQU	31
Protection_txt	EQU	32
LP_max_txt	EQU	33
SP_max_txt	EQU	34
MBW_txt	EQU	35
MBA_txt	EQU	36
Attr2_txt	EQU	37
Skill2_txt	EQU	38
Cursed_txt	EQU	39
Item_type_names	EQU	460
Attribute_names	EQU	492
Skill_names	EQU	508
Spell_class_names	EQU	524
Spell_names	EQU	532

;*****************************************************************************
; [ Status icons in the status block ]
;*****************************************************************************
; [ Display a status icon ]
;   IN : d0 - Status icon number / 0 = none (.w)
;        d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From [ Update_member_status ] (DISPLAY.S).
Display_status_icon:
	movem.l	d0-d7/a0,-(sp)
	move.w	d0,d2
	move.w	d7,d0			; Get X-coordinate
	subq.w	#1,d0
	mulu.w	#48,d0
	addi.w	#16+32,d0
	moveq.l	#1,d1			; Erase icon
	moveq.l	#1,d6
	moveq.l	#16,d7
	lea.l	Status_M+8,a0
	jsr	Put_unmasked_block
	tst.w	d2			; Any icon ?
	beq.s	.Exit
	subq.w	#1,d2			; Display icon
	lsl.w	#7,d2			; (16 x 8 bytes)
	lea.l	Status_icons_UI,a0
	add.w	d2,a0
	jsr	Put_masked_icon
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

; [ Show who can take the moved item ]
; All registers are restored
; NOTE :
;   - From [ Show_transfer_victims ] (INVENTOR.S).
Show_transfer_victims:
	movem.l	d0/d7/a2,-(sp)
	lea.l	Inter_packet,a2
	moveq.l	#1,d7
.Loop:	moveq.l	#Accept_icon,d0
	jsr	Check_transfer
	beq.s	.Yes
	moveq.l	#Refuse_icon,d0
.Yes:	jsr	Display_status_icon
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d7/a2
	rts

; [ Remove the status icons ]
; All registers are restored
Hide_status_icons:
	movem.l	d0/d7,-(sp)
	moveq.l	#0,d0
	moveq.l	#1,d7
.Loop:	jsr	Display_status_icon
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d7
	rts

;*****************************************************************************
; [ Check if a member can take an item ]
;   IN : d7 - Member number {1...6} (.w)
;        a2 - Pointer to object packet (.l)
;  OUT : eq - Yes, ne - No
; All registers are restored
; NOTE :
;   - From [ Scan_4_transfer_victims ] (INVENTOR.S) : the member must be
;     alive, strong enough and have room in the backpack.
;*****************************************************************************
Check_transfer:
	movem.l	d0-d4/a0/a1/a3,-(sp)
	jsr	Get_char_data
	move.l	a1,a3
	move.w	#Alive_mask,d0		; Alive ?
	and.w	Body_conditions(a3),d0
	bne.s	.No
	move.w	Object_index(a2),d0
	jsr	Get_item_data
	moveq.l	#0,d1			; Get weight of items
	move.b	Quantity(a2),d1
	move.w	Weight(a1),d2
	mulu.w	d1,d2
	move.w	AStrength(a3),d3		; Not too heavy ?
	add.w	AStrength+Magic(a3),d3
	mulu.w	#1000,d3
	addi.l	#999,d3
	sub.l	Weight_normal(a3),d3
	cmp.l	d2,d3
	bmi.s	.No
	lea.l	Char_inventory+Backpack_slots(a3),a0	; Free slot ?
	moveq.l	#Items_per_char-1,d4
.Loop:	move.w	Object_index(a0),d3
	beq.s	.Yes
	cmp.w	Object_index(a2),d3		; No -> Same object ?
	bne.s	.Next
	btst	#Multiple,Item_bits_STATIC(a1)	; Yes -> Multiple item ?
	beq.s	.Next
	moveq.l	#0,d3			; Yes -> Fits ?
	move.b	Quantity(a0),d3
	add.w	d1,d3
	cmp.w	#100,d3
	bmi.s	.Yes
.Next:	addq.w	#Object_packet_size,a0
	dbra	d4,.Loop
.No:	moveq.l	#-1,d0
	bra.s	.Exit
.Yes:	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d0-d4/a0/a1/a3
	rts

;*****************************************************************************
; [ Select an item ]
;   IN : d0 - Prompt (message number) (.w)
;        d1 - 0 = backpack only, 1 = body & backpack (.w)
;  OUT : d0 - Slot number {1...33} / 0 = none (.w)
; Changed registers : d0
; NOTE :
;   - Like the ItemSelect modules : the right mouse button or ESC aborts.
;*****************************************************************************
Select_item:
	movem.l	d1-d7/a0-a6,-(sp)
	move.w	d1,d5
	jsr	Print_prompt
	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
	moveq.l	#0,d4			; Result
.Loop:	jsr	Update_ghost
	jsr	Switch_screens
	jsr	Read_key			; ESC ?
	cmp.w	#$01,d0
	beq.s	.Done
	jsr	Read_mouse_clicks
	move.w	d0,d6
	beq.s	.Loop
	btst	#Right_pressed,d6		; Right button ?
	bne.s	.Done
	jsr	Find_inventory_object
	move.w	d0,d1
	lsr.w	#8,d1
	andi.w	#$00ff,d0
	cmp.w	#Obj_scroll_bar,d1		; Scroll bar ?
	bne.s	.No_bar
	jsr	Scroll_bar_pressed
	bra.s	.Loop
.No_bar:	cmp.w	#Obj_backpack,d1		; Backpack slot ?
	bne.s	.No_backpack
	addi.w	#9,d0
	add.w	Scroll_bar_result,d0
	bra.s	.Check
.No_backpack:
	cmp.w	#Obj_body,d1		; Body slot ?
	bne.s	.Loop
	tst.w	d5			; Allowed ?
	beq.s	.Loop
	tst.w	d0
	beq.s	.Loop
.Check:	move.w	d0,d2			; Anything there ?
	jsr	Get_slot_packet
	tst.w	Object_index(a0)
	beq.s	.Loop
	move.w	d2,d4			; Yes
.Done:	clr.l	Ghost_text
	jsr	Erase_PA
	jsr	Copy_screen_to_both
	move.w	d4,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Select a member ]
;   IN : d0 - Prompt (message number) (.w)
;  OUT : d0 - Member number {1...6} / 0 = none (.w)
; Changed registers : d0
; NOTE :
;   - Like the MemberSel module.
;*****************************************************************************
Select_member:
	movem.l	d1-d7/a0-a6,-(sp)
	jsr	Print_prompt
	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
	moveq.l	#0,d4
.Loop:	jsr	Switch_screens
	jsr	Read_key			; ESC ?
	cmp.w	#$01,d0
	beq.s	.Done
	jsr	Read_mouse_clicks
	move.w	d0,d6
	beq.s	.Loop
	btst	#Right_pressed,d6		; Right button ?
	bne.s	.Done
	jsr	Find_inventory_object
	move.w	d0,d1
	lsr.w	#8,d1
	cmp.w	#Obj_member,d1		; Portrait ?
	bne.s	.Loop
	andi.w	#$00ff,d0
	move.w	d0,d4
.Done:	jsr	Erase_PA
	jsr	Copy_screen_to_both
	move.w	d4,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Yes / No requester ]
;   IN : d0 - Message number (.w)
;  OUT : d0 - 1 = Yes, 0 = No (.w)
; Changed registers : d0
; NOTE :
;   - From [ Req_ModInit ] (HULL/CONTROLS.S).
;*****************************************************************************
Ask_yes_no:
	move.l	a0,-(sp)
	addi.w	#Messages,d0		; Get text
	jsr	Get_text
	jsr	Ask_yes_no_text
	move.l	(sp)+,a0
	rts

; [ Yes / No requester with a text ]
;   IN : a0 - Pointer to text (.l)
;  OUT : d0 - 1 = Yes, 0 = No (.w)
; Changed registers : d0
Ask_yes_no_text:
	movem.l	d1-d7/a0-a6,-(sp)
	move.w	#(14-2)*16/(Char_width+1),Text_width	; Process text
	jsr	Process_text
	move.w	Text_height,d5		; Calculate window height
	cmp.w	#6*2,d5
	bls.s	.Ok0
	moveq.l	#6*2,d5
.Ok0:	mulu.w	#Char_height+2,d5
	move.w	d5,d3
	addi.w	#15,d3
	lsr.w	#4,d3
	move.w	d3,d4			; Icons Y-coordinate
	lsl.w	#4,d4
	addi.w	#ReqW_Y,d4
	move.w	d4,Req_icon_Y
	move.w	#ReqW_X-16,d0		; Open window
	move.w	#ReqW_Y-16,d1
	moveq.l	#14,d2
	addq.w	#3,d3
	jsr	Open_window
	move.w	#White,Ink_colour		; Print text
	move.w	#Default_shadow,Shadow_colour
	lea.l	Text_lines,a4
	move.w	Text_height,d7
	move.w	#ReqW_X,d0
	move.w	#ReqW_Y,d1
	bra.s	.Next
.Line:	move.l	a4,a0
	jsr	Put_text_line
	lea.l	Line_stride(a4),a4
	addi.w	#Char_height+2,d1
.Next:	dbra	d7,.Line
	move.w	#ReqW_X+63,d0		; Draw box around icons
	move.w	Req_icon_Y,d1
	subq.w	#1,d1
	moveq.l	#64,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display YES & NO icons
	addq.w	#1,d1
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
	btst	#Left_pressed,d0
	beq.s	.Loop
	move.w	Mouse_Y,d1		; On the icons ?
	sub.w	Req_icon_Y,d1
	bmi.s	.Loop
	cmp.w	#17,d1
	bpl.s	.Loop
	move.w	Mouse_X,d0
	subi.w	#ReqW_X+64,d0
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
	addi.w	#ReqW_X+64,d0
	move.w	Req_icon_Y,d1
	jsr	Display_down_button
	jsr	Copy_screen_to_both
.Wait:	jsr	Switch_screens
	btst	#Left_pressed,Mouse_buttons
	bne.s	.Wait
.Done:	jsr	Close_window
	move.w	d4,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw a standard box (DEEP) ]
;   IN : d0 - Top-left X-coordinate (.w)
;        d1 - Top-left Y-coordinate (.w)
;        d2 - Width of INSIDE of box (.w)
;        d3 - Height of INSIDE of box (.w)
; All registers are restored
; NOTE :
;   - From HULL/CONTROLS.S.
;*****************************************************************************
Draw_standard_box:
	movem.l	d0-d4,-(sp)
	add.w	d0,d2			; Draw dark edge
	add.w	d1,d3
	moveq.l	#26,d4
	jsr	Draw_box
	addq.w	#1,d0			; Draw light edge
	addq.w	#1,d1
	addq.w	#1,d2
	addq.w	#1,d3
	moveq.l	#30,d4
	jsr	Draw_box
	subq.w	#1,d2			; Draw main area
	subq.w	#1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	movem.l	(sp)+,d0-d4
	rts

;*****************************************************************************
; [ Drop an item ]
; All registers are restored
; NOTE :
;   - From [ Drop_item ] (INVENTOR.S). The whole stack is dropped (the Amiga
;     version asks how many).
;*****************************************************************************
Drop_item:
	movem.l	d0-d3/a0-a2,-(sp)
	moveq.l	#28,d0			; Select item
	moveq.l	#0,d1
	jsr	Select_item
	move.w	d0,d2			; Anything selected ?
	beq.s	.Exit
	jsr	Get_packet
	move.l	a0,a2
	move.w	Object_index(a2),d0
	jsr	Get_item_data
	btst	#Droppable,Item_bits_STATIC(a1)	; Droppable ?
	bne.s	.Drop
	moveq.l	#29,d0			; "This item is important !"
	jsr	Do_prompt
	bra.s	.Exit
.Drop:	moveq.l	#47,d0			; Are you sure ?
	jsr	Ask_yes_no
	tst.w	d0
	beq.s	.Exit
	moveq.l	#0,d3			; Drop
	move.b	Quantity(a2),d3
	jsr	Get_inventory_char
	move.l	a1,a0
	jsr	Remove_item
	jsr	Update_objects
	jsr	Update_weight
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d3/a0-a2
	rts

;*****************************************************************************
; [ View an item ]
; All registers are restored
; NOTE :
;   - From [ View_item ], [ ItemView1_DisInit ] and [ ItemView2_DisInit ]
;     (INVENTOR.S). The second window (details of identified items) is
;     shown instead of the first one.
;*****************************************************************************
View_item:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#31,d0			; Select item
	moveq.l	#1,d1
	jsr	Select_item
	tst.w	d0			; Anything selected ?
	beq	.Exit
	jsr	Get_slot_packet
	lea.l	Inter_packet,a1		; Copy packet
	Copy_packet a0,a1
.Again:	jsr	Item_view_window_1
	jsr	Read_mouse_clicks
.Loop:	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC ?
	beq.s	.Close
	jsr	Read_mouse_clicks
	tst.w	d0
	beq.s	.Loop
	btst	#Magic_check,Inter_packet+Item_bits_DYNAMIC	; Identified ?
	beq.s	.Close
	move.w	Mouse_X,d0		; Look icon ?
	subi.w	#ItemView1_X+224,d0
	bmi.s	.Close
	cmp.w	#32,d0
	bpl.s	.Close
	move.w	Mouse_Y,d0
	subi.w	#ItemView1_Y+47,d0
	bmi.s	.Close
	cmp.w	#17,d0
	bpl.s	.Close
	jsr	Close_window		; Show details
	jsr	Item_view_window_2
	jsr	Wait_for_click
	jsr	Close_window
	bra.s	.Again
.Close:	jsr	Close_window
	jsr	Read_mouse_clicks
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Item view window 1 ]
; NOTE :
;   - The item is in [ Inter_packet ].
Item_view_window_1:
	movem.l	d0-d7/a0-a4,-(sp)
	move.w	#ItemView1_X-16,d0		; Open a window
	move.w	#ItemView1_Y-16,d1
	moveq.l	#18,d2
	moveq.l	#6,d3
	jsr	Open_window
	jsr	Check_item_cursed
	lea.l	Inter_packet,a3
	move.w	Object_index(a3),d0
	jsr	Get_item_data
	move.l	a1,a2
	move.w	#ItemView1_X-1,d0		; Draw box around icon
	move.w	#ItemView1_Y-1,d1
	moveq.l	#16,d2
	moveq.l	#16,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display icon
	addq.w	#1,d1
	jsr	Get_item_graphic
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block
	move.w	#White,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	move.w	#ItemView1_X+19,d0		; Print item name
	move.w	#ItemView1_Y+1,d1
	lea.l	Item_name(a2),a0
	jsr	Put_text_line
	moveq.l	#0,d0			; Get item type
	move.b	Item_type(a2),d0
	beq.s	.No_type
	addi.w	#Item_type_names-1,d0	; Print item type
	jsr	Get_text
	move.w	#ItemView1_X+19,d0
	move.w	#ItemView1_Y+9,d1
	jsr	Put_text_line
; ---------- Classes ------------------------------
.No_type:	lea.l	Classname_pos_list,a4
	moveq.l	#0,d2
	move.w	#Special_class_mask,d3
	not.w	d3
	and.w	Class_use(a2),d3
.Loop:	btst	d2,d3			; Usable ?
	beq.s	.Next
	move.w	d2,d0			; Print class name
	addi.w	#Class_names,d0
	jsr	Get_text
	move.w	(a4)+,d0
	move.w	(a4)+,d1
	jsr	Put_text_line
.Next:	addq.w	#1,d2
	cmp.w	#Max_classes,d2
	bmi.s	.Loop
	move.w	#30,Ink_colour
	moveq.l	#Classes_txt,d0		; Print "CLASSES"
	jsr	Get_text
	move.w	#ItemView1_X+145,d0
	move.w	#ItemView1_Y-1,d1
	jsr	Put_text_line
	moveq.l	#Sex_txt,d0		; Print "GENDER"
	jsr	Get_text
	move.w	#ItemView1_X+145,d0
	move.w	#ItemView1_Y+46,d1
	jsr	Put_text_line
	move.w	#White,Ink_colour
	moveq.l	#0,d0			; Print sex use
	move.b	Sex_use(a2),d0
	addi.w	#Male_txt-1,d0
	jsr	Get_text
	move.w	#ItemView1_X+145,d0
	move.w	#ItemView1_Y+54,d1
	jsr	Put_text_line
; ---------- Look icon (identified items) ---------
	btst	#Magic_check,Item_bits_DYNAMIC(a3)
	beq.s	.No_look
	move.w	#ItemView1_X+223,d0		; Draw box around icon
	move.w	#ItemView1_Y+46,d1
	moveq.l	#32,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display icon
	addq.w	#1,d1
	moveq.l	#Look_cicon,d3
	jsr	Display_up_button
; ---------- Values -------------------------------
.No_look:	moveq.l	#Weight2_txt,d0		; Weight
	moveq.l	#0,d1
	move.w	Weight(a2),d1
	move.w	#ItemView1_Y+20,d2
	jsr	.Weight
	moveq.l	#Hands_txt,d0		; Hands
	moveq.l	#0,d1
	move.b	Hand_use(a2),d1
	move.w	#ItemView1_Y+30,d2
	jsr	.Value
	moveq.l	#Fingers_txt,d0		; Fingers
	moveq.l	#0,d1
	move.b	Ring_use(a2),d1
	move.w	#ItemView1_Y+38,d2
	jsr	.Value
	moveq.l	#Damage_txt,d0		; Damage
	move.b	Damage_pts(a2),d1
	ext.w	d1
	move.w	#ItemView1_Y+46,d2
	jsr	.Signed
	moveq.l	#Protection_txt,d0		; Protection
	move.b	Protection_pts(a2),d1
	ext.w	d1
	move.w	#ItemView1_Y+54,d2
	jsr	.Signed
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d7/a0-a4
	rts

; Print text d0 with the weight d1 (right justified, 5 digits) at y = d2
.Weight:	movem.l	d0-d2/d6/d7/a0/a2,-(sp)
	jsr	Copy_text
	jsr	Number_position
	move.w	d1,d0
	moveq.l	#" ",d6
	moveq.l	#5,d7
	jsr	DecR_convert
	move.b	#" ",(a0)
	move.w	#ItemView1_X,d0
	move.w	d2,d1
	move.l	a2,a0
	jsr	Put_text_line
	movem.l	(sp)+,d0-d2/d6/d7/a0/a2
	rts

; Print text d0 with the number d1 (left justified) at y = d2
.Value:	movem.l	d0-d2/d7/a0/a2,-(sp)
	jsr	Copy_text
	jsr	Number_position
	move.w	d1,d0
	moveq.l	#1,d7
	jsr	DecL_convert
	move.w	#ItemView1_X,d0
	move.w	d2,d1
	move.l	a2,a0
	jsr	Put_text_line
	movem.l	(sp)+,d0-d2/d7/a0/a2
	rts

; Print text d0 with the signed number d1 (inverted if cursed) at y = d2
.Signed:	movem.l	d0-d2/d7/a0/a2,-(sp)
	jsr	Copy_text
	jsr	Number_position
	tst.b	Cursed_flag
	beq.s	.Not_cursed
	neg.w	d1
.Not_cursed:	move.w	d1,d0
	moveq.l	#2,d7
	jsr	SDecL_convert
	move.w	#ItemView1_X,d0
	move.w	d2,d1
	move.l	a2,a0
	jsr	Put_text_line
	movem.l	(sp)+,d0-d2/d7/a0/a2
	rts

; [ Item view window 2 ]
Item_view_window_2:
	movem.l	d0-d7/a0-a4,-(sp)
	move.w	#ItemView2_X-16,d0		; Open a window
	move.w	#ItemView2_Y-16,d1
	moveq.l	#12,d2
	moveq.l	#6,d3
	jsr	Open_window
	jsr	Check_item_cursed
	lea.l	Inter_packet,a3
	move.w	Object_index(a3),d0
	jsr	Get_item_data
	move.l	a1,a4
	move.w	#White,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	moveq.l	#LP_max_txt,d0		; LP-max
	move.b	LP_max(a4),d1
	ext.w	d1
	move.w	#ItemView2_X,d2
	move.w	#ItemView2_Y,d3
	jsr	.Signed
	moveq.l	#SP_max_txt,d0		; SP-max
	move.b	SP_max(a4),d1
	ext.w	d1
	addi.w	#80,d2
	jsr	.Signed
	moveq.l	#MBW_txt,d0		; Magic bonus weapon
	moveq.l	#0,d1
	move.b	Weapon_magic_bonus(a4),d1
	move.w	#ItemView2_X,d2
	addq.w	#7,d3
	jsr	.Value
	moveq.l	#MBA_txt,d0		; Magic bonus armour
	moveq.l	#0,d1
	move.b	Armour_magic_bonus(a4),d1
	addi.w	#80,d2
	jsr	.Value
	move.w	#17,Ink_colour		; Print "ATTRIBUTE" & "SKILL"
	moveq.l	#Attr2_txt,d0
	jsr	Get_text
	move.w	#ItemView2_X,d0
	move.w	#ItemView2_Y+14,d1
	jsr	Put_text_line
	moveq.l	#Skill2_txt,d0
	jsr	Get_text
	move.w	#ItemView2_X,d0
	move.w	#ItemView2_Y+28,d1
	jsr	Put_text_line
	move.w	#White,Ink_colour
	tst.b	Attribute_normal(a4)	; Any attribute changed ?
	beq.s	.No_attr
	moveq.l	#0,d0
	move.b	Attribute(a4),d0
	addi.w	#Attribute_names,d0
	moveq.l	#0,d1
	move.b	Attribute_normal(a4),d1
	move.w	#ItemView2_Y+21,d3
	jsr	.Bonus
.No_attr:	tst.b	Skill_normal(a4)		; Any skill changed ?
	beq.s	.No_skill
	moveq.l	#0,d0
	move.b	Skill(a4),d0
	addi.w	#Skill_names,d0
	moveq.l	#0,d1
	move.b	Skill_normal(a4),d1
	move.w	#ItemView2_Y+35,d3
	jsr	.Bonus
.No_skill:	tst.b	Charges(a3)		; Any magic ?
	beq	.No_magic
	move.w	#17,Ink_colour		; Print spell class name
	moveq.l	#0,d0
	move.b	Spell_class(a4),d0
	addi.w	#Spell_class_names,d0
	jsr	Get_text
	move.w	#ItemView2_X,d0
	move.w	#ItemView2_Y+42,d1
	jsr	Put_text_line
	move.w	#White,Ink_colour		; Print spell name
	moveq.l	#0,d0
	move.b	Spell_class(a4),d0
	mulu.w	#Max_spells,d0
	moveq.l	#0,d1
	move.b	Spell_number(a4),d1
	add.w	d1,d0
	addi.w	#Spell_names-1,d0
	jsr	Get_text
	move.l	a0,a2			; Get length
	moveq.l	#0,d5
.Len:	tst.b	(a2)+
	beq.s	.Len_done
	addq.w	#Char_width+1,d5
	bra.s	.Len
.Len_done:	move.w	#ItemView2_X,d0
	move.w	#ItemView2_Y+49,d1
	jsr	Put_text_line
	lea.l	Charges_txt,a0		; Print charges
	move.b	#"(",(a0)+
	moveq.l	#0,d0
	move.b	Charges(a3),d0
	moveq.l	#"0",d6
	moveq.l	#2,d7
	jsr	DecR_convert
	move.b	#")",(a0)+
	clr.b	(a0)
	move.w	#ItemView2_X+Char_width+1,d0
	add.w	d5,d0
	lea.l	Charges_txt,a0
	jsr	Put_text_line
.No_magic:	tst.b	Cursed_flag		; Cursed ?
	beq.s	.Done
	move.w	#Red,Ink_colour		; Print "CURSED"
	moveq.l	#Cursed_txt,d0
	jsr	Get_text
	move.w	#ItemView2_X,d0
	move.w	#ItemView2_Y+56,d1
	move.w	#160,d2
	jsr	Print_centered_string
.Done:	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d7/a0-a4
	rts

; Print text d0 with the number d1 (left justified) at d2,d3
.Value:	movem.l	d0-d3/d7/a0/a2,-(sp)
	jsr	Copy_text
	jsr	Number_position
	move.w	d1,d0
	moveq.l	#2,d7
	jsr	DecL_convert
	move.w	d2,d0
	move.w	d3,d1
	move.l	a2,a0
	jsr	Put_text_line
	movem.l	(sp)+,d0-d3/d7/a0/a2
	rts

; Print text d0 with the signed number d1 (inverted if cursed) at d2,d3
.Signed:	movem.l	d0-d3/d7/a0/a2,-(sp)
	jsr	Copy_text
	jsr	Number_position
	tst.b	Cursed_flag
	beq.s	.Not_cursed
	neg.w	d1
.Not_cursed:	move.w	d1,d0
	moveq.l	#2,d7
	jsr	SDecL_convert
	move.w	d2,d0
	move.w	d3,d1
	move.l	a2,a0
	jsr	Put_text_line
	movem.l	(sp)+,d0-d3/d7/a0/a2
	rts

; Print the name d0 and the bonus d1 (inverted if cursed) at y = d3
.Bonus:	movem.l	d0-d3/d7/a0,-(sp)
	jsr	Get_text
	move.w	#ItemView2_X,d0
	move.w	d3,d1
	jsr	Put_text_line
	tst.b	Cursed_flag
	beq.s	.Not_cursed2
	neg.w	d1
.Not_cursed2:
	move.w	d1,d0
	lea.l	Number,a0
	moveq.l	#2,d7
	jsr	SDecL_convert
	move.w	#ItemView2_X+120,d0
	move.w	d3,d1
	lea.l	Number,a0
	jsr	Put_text_line
	movem.l	(sp)+,d0-d3/d7/a0
	rts

; [ Check if the item in Inter_packet is known to be cursed ]
;  OUT : [ Cursed_flag ]
; All registers are restored
; NOTE :
;   - Like [ Check_item_cursed ] (KERNEL/TEXTS.S) : the curse is only shown
;     when the item was identified.
Check_item_cursed:
	movem.l	d0/a1,-(sp)
	move.w	Inter_packet+Object_index,d0
	jsr	Get_item_data
	move.b	Item_bits_STATIC(a1),d0
	andi.b	#1<<Cursed,d0
	and.b	Inter_packet+Item_bits_DYNAMIC,d0	; (Magic_check is bit 0)
	sne	Cursed_flag
	movem.l	(sp)+,d0/a1
	rts

; [ Find the number in a copied text ]
;   IN : a2 - Pointer to text (.l)
;  OUT : a0 - Pointer to the first "0" (.l)
; Changed registers : a0
Number_position:
	move.l	a2,a0
.Loop:	cmp.b	#"0",(a0)
	beq.s	.Exit
	tst.b	(a0)+
	bne.s	.Loop
	subq.l	#1,a0
.Exit:	rts

;*****************************************************************************
; [ Use an item ]
; All registers are restored
; NOTE :
;   - From [ Use_item ] (INVENTOR.S) and MAGIC.S, without item events,
;     transports and the spells which do not work on party members.
;*****************************************************************************
Use_item:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#30,d0			; Select item
	moveq.l	#1,d1
	jsr	Select_item
	move.w	d0,Used_item_slot		; Anything selected ?
	beq	.Exit
	jsr	Get_packet
	move.l	a0,a3			; a3 = packet
	move.w	Object_index(a3),d0
	jsr	Get_item_data
	move.l	a1,a2			; a2 = item data
	jsr	Get_inventory_char		; a1 = character
; ---------- Check if item is broken --------------
	btst	#Broken_item,Item_bits_DYNAMIC(a3)
	beq.s	.Not_broken
	moveq.l	#62,d0			; "Broken!"
	bra	.Prompt
; ---------- Check if item is magical -------------
.Not_broken:
	tst.b	Spell_number(a2)		; Any magic in this item ?
	beq	.No_magic
	tst.b	Charges(a3)		; Any charges left ?
	bne.s	.Charges_OK
	move.w	#265,d0			; No -> "No charges!"
	bra	.Prompt
.Charges_OK:
	move.b	Char_class(a1),d0		; Right class ?
	move.w	Class_use(a2),d1
	btst	d0,d1
	bne.s	.Class_OK
	move.w	#243,d0			; No -> "Wrong class!"
	bra	.Prompt
.Class_OK:	lea.l	Spell_data,a4		; Get pointer to spell data
	moveq.l	#0,d0
	move.b	Spell_class(a2),d0
	move.w	d0,Selected_class
	moveq.l	#0,d1
	move.b	Spell_number(a2),d1
	move.w	d1,Selected_spell
	mulu.w	#Max_spells,d0
	add.w	d1,d0
	subq.w	#1,d0
	mulu.w	#Spell_data_size,d0
	add.w	d0,a4
	move.b	Spell_area_bits(a4),d0	; Right area ?
	moveq.l	#1,d1			; (2D city map)
	tst.b	World_map
	beq.s	.City
	moveq.l	#0,d1			; (world map)
.City:	btst	d1,d0
	bne.s	.Area_OK
	move.w	#244,d0			; No -> "Wrong area!"
	bra	.Prompt
.Area_OK:	move.w	Current_world_nr,d1		; Right world ?
	addq.w	#5,d1
	btst	d1,d0
	bne.s	.World_OK
	move.w	#245,d0			; No -> "Wrong world!"
	bra	.Prompt
.World_OK:	jsr	Find_spell_handler		; Possible here ?
	move.l	a0,d0
	bne.s	.Handler_OK
	move.w	#282,d0			; No -> "No use!"
	bra	.Prompt
; ---------- Select the target --------------------
.Handler_OK:
	move.w	#%01111110,d6		; Everyone
	btst	#Single_target_bit,Spell_target_bits(a4)	; Single target ?
	beq.s	.All
	move.w	#284,d0			; Who ?
	jsr	Select_member
	tst.w	d0
	beq	.Exit
	moveq.l	#0,d6
	bset	d0,d6
; ---------- Do it --------------------------------
.All:	move.w	Used_item_slot,d2		; Remove used item / charge
	jsr	Get_inventory_char
	move.l	a1,a0
	btst	#Multiple,Item_bits_STATIC(a2)	; Multiple ?
	bne.s	.Remove
	cmpi.b	#255,Charges(a3)		; No -> Infinite charges ?
	beq.s	.Targets
	subq.b	#1,Charges(a3)		; No -> One charge less
	bra.s	.Targets
.Remove:	moveq.l	#1,d3
	jsr	Remove_item
.Targets:	moveq.l	#1,d7			; Do all targets
.Loop:	btst	d7,d6
	beq.s	.Next
	jsr	Get_char_data
	move.l	a1,a0
	jsr	(a5)
	jsr	Update_member_bars
.Next:	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	bra	.Show
; ---------- Check if it's a special item ---------
.No_magic:	cmp.b	#Special_itemtype,Item_type(a2)	; Is it ?
	bne.s	.Not_special
	move.w	Special_item_flags,d0	; Yes -> Already in use ?
	move.b	Misc_1(a2),d1
	btst	d1,d0
	beq.s	.No
	moveq.l	#48,d0			; Yes -> "Fool!"
	bra	.Prompt
.No:	bset	d1,d0			; No -> Use
	move.w	d0,Special_item_flags
	jsr	Destroy_used_item
	moveq.l	#43,d0			; "Yay!"
	jsr	Do_prompt
	bra	.Show
; ---------- Check if it's a text scroll ----------
.Not_special:
	cmpi.b	#Textscroll_itemtype,Item_type(a2)	; Is it ?
	bne.s	.No_text_scroll
	moveq.l	#0,d0			; Yes -> Load text file
	move.b	Misc_1(a2),d0
	lea.l	Map_texts,a1
	move.l	#Max_map_texts,d1
	moveq.l	#'O',d2
	jsr	Load_object_text_file
	move.w	#-1,Map_texts_nr		; (map texts are gone)
	moveq.l	#0,d0			; Show text
	move.b	Misc_2(a2),d0
	lea.l	Map_texts,a0
	jsr	Find_large_text
	jsr	Text_window
	jsr	Destroy_used_item
	bra.s	.Show
; ---------- Cannot be used -----------------------
.No_text_scroll:
	moveq.l	#63,d0			; Transport : "Not here !"
	cmp.b	#Transport_itemtype,Item_type(a2)
	beq.s	.Prompt
	move.w	#282,d0			; "No use!"
.Prompt:	jsr	Do_prompt
	bra.s	.Exit
.Show:	jsr	Display_body_objects
	jsr	Update_objects
	jsr	Update_weight
	jsr	Display_small_member_info
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Destroy the used item (if it is destroyed after use) ]
; All registers are restored
; NOTE :
;   - From [ Destroy_used_item ] (without breaking).
Destroy_used_item:
	movem.l	d0-d3/a0/a1,-(sp)
	move.w	Used_item_slot,d2
	move.w	d2,d0
	jsr	Get_packet
	move.w	Object_index(a0),d0
	beq.s	.Exit
	jsr	Get_item_data
	btst	#Destroy_after_use,Item_bits_STATIC(a1)	; Destroy ?
	beq.s	.Exit
	jsr	Get_inventory_char
	move.l	a1,a0
	moveq.l	#1,d3
	jsr	Remove_item
.Exit:	movem.l	(sp)+,d0-d3/a0/a1
	rts

; [ Load a text file of the text scrolls ("DATA\OT<n>.BIN") ]
;   IN : d0 - File number (.w), d1 - maximum length (.l), a1 - buffer (.l)
; All registers are restored
Load_object_text_file:
	movem.l	d0/a0,-(sp)
	lea.l	Object_text_name+7,a0
	addi.b	#"0",d0
	move.b	d0,(a0)
	lea.l	Object_text_name,a0
	move.l	d1,d0
	jsr	Load_file
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Find the handler of a spell ]
;   IN : [ Selected_class ], [ Selected_spell ]
;  OUT : a5 - Pointer to handler / a0 = 0 : not possible here (.l)
; Changed registers : a0,a5
; NOTE :
;   - Like Magic_class_ptrs (MAGIC.S), only the spells which work on party
;     members. A handler is called for each target :
;       IN : d7 - Member number, a0 - Pointer to character data
;*****************************************************************************
Find_spell_handler:
	move.l	d0,-(sp)
	sub.l	a0,a0
	lea.l	Class0_spells,a5
	move.w	Selected_class,d0
	beq.s	.Do
	lea.l	Class6_spells,a5
	cmp.w	#6,d0
	bne.s	.Exit
.Do:	move.w	Selected_spell,d0
	add.w	d0,d0
	move.w	-2(a5,d0.w),d0
	beq.s	.Exit
	lea.l	Spell_handlers,a5
	add.w	d0,a5
	move.l	a5,a0
.Exit:	move.l	(sp)+,d0
	rts

Spell_handlers:
	rts				; (offset 0 means "not possible")

; *** Healing spells (MAGIC.S : Healing) ***
SH_Healing:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get max LP percentage
	moveq.l	#0,d1
	move.b	.Table-1(pc,d0.w),d1
	bmi.s	.Exit
	move.w	Life_points+Maximum(a0),d0	; Calculate added LP
	mulu.w	d1,d0
	divu.w	#100,d0
	tst.w	d0
	bne.s	.Notzero
	moveq.l	#1,d0
.Notzero:	move.w	Life_points(a0),d1		; Add
	move.w	Life_points+Maximum(a0),d2
	add.w	Life_points+Magic(a0),d2
	add.w	d0,d1
	cmp.w	d2,d1
	bmi.s	.Ok
	move.w	d2,d1
.Ok:	move.w	d1,Life_points(a0)
.Exit:	rts
.Table:	dc.b 10,-1,-1,-1,-1,-1,-1,25,-1,-1,50,-1,-1,-1,-1,-1
	dc.b -1,75,25,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	even

; *** Remove condition spells (MAGIC.S : Remove_cond) ***
SH_Remove_cond:
	move.w	Body_conditions(a0),d0	; Can be healed ?
	andi.w	#Heal_mask,d0
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get condition
	move.b	.Table-1(pc,d0.w),d0
	bmi.s	.Exit
	move.w	Body_conditions(a0),d1	; Remove
	bclr	d0,d1
	move.w	d1,Body_conditions(a0)
.Exit:	rts
.Table:	dc.b -1,Panicked,Panicked,Blind
	dc.b Blind,Diseased,Diseased,-1
	dc.b Poisoned,Poisoned,-1,-1
	dc.b -1,-1,-1,-1
	dc.b -1,-1,-1,-1
	dc.b Lamed,Lamed,Aging,Aging
	dc.b Petrified,Asleep,Irritated,Stoned
	dc.b Mad,-1
	even

; *** Restore stamina (MAGIC.S) ***
SH_Restore_stamina:
	move.w	Body_conditions(a0),d0	; Alive ?
	move.w	d0,d1
	andi.w	#Alive_mask,d1
	bne.s	.Exit
	bclr	#Exhausted,d0		; Yes -> Exhausted ?
	beq.s	.Exit
	move.w	d0,Body_conditions(a0)	; Yes -> restore attributes
	lea.l	Attributes(a0),a1		;  & skills (De_exhaust)
	moveq.l	#Max_attrs-1,d1
.Loop1:	move.w	Backup(a1),(a1)
	addq.w	#Attr_data_size,a1
	dbra	d1,.Loop1
	lea.l	Skills(a0),a1
	moveq.l	#Max_skills-1,d1
.Loop2:	move.w	Backup(a1),(a1)
	addq.w	#Skill_data_size,a1
	dbra	d1,.Loop2
.Exit:	rts

; *** Youth (MAGIC.S) ***
SH_Youth:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit
	jsr	Random			; Get random number
	mulu.w	#10,d0
	swap	d0
	addq.w	#1,d0
	move.w	AAge(a0),d1		; Subtract from age
	cmp.w	#Minimum_age,d1		; Already young enough ?
	ble.s	.Exit
	sub.w	d0,d1
	cmp.w	#Minimum_age,d1		; Too young ?
	bpl.s	.Ok
	move.w	#Minimum_age,d1
.Ok:	move.w	d1,AAge(a0)
.Exit:	rts

; *** Spell points (MAGIC.S : MSpell_points) ***
SH_Spell_points:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit
	move.w	Selected_spell,d0		; Get max SP percentage
	subq.w	#5,d0
	moveq.l	#0,d1
	move.b	.Table(pc,d0.w),d1
	move.w	Power_points+Maximum(a0),d0	; Calculate added SP
	beq.s	.Exit
	mulu.w	d1,d0
	divu.w	#100,d0
	tst.w	d0
	bne.s	.Notzero
	moveq.l	#1,d0
.Notzero:	move.w	Power_points(a0),d1		; Add
	move.w	Power_points+Maximum(a0),d2
	add.w	Power_points+Magic(a0),d2
	add.w	d0,d1
	cmp.w	d2,d1
	bmi.s	.Ok
	move.w	d2,d1
.Ok:	move.w	d1,Power_points(a0)
.Exit:	rts
.Table:	dc.b 10,25,50,75,100
	even

; *** Heal all (MAGIC.S) ***
SH_Heal_all:
	clr.w	Body_conditions(a0)		; Heal
	move.w	Life_points+Maximum(a0),d0	; Reset LP
	add.w	Life_points+Magic(a0),d0
	move.w	d0,Life_points(a0)
	rts

; *** Increase attribute (MAGIC.S : MAttribute) ***
SH_Attribute:
	move.w	Body_conditions(a0),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne.s	.Exit
	lea.l	Attributes(a0),a1		; Get attribute data
	move.w	Selected_spell,d0
	subi.w	#12,d0
	mulu.w	#Attr_data_size,d0
	add.w	d0,a1
	jsr	Random			; Get random number
	mulu.w	#5,d0
	swap	d0
	addq.w	#1,d0
	add.w	(a1),d0			; Increase attribute
	cmp.w	Maximum(a1),d0		; Too high ?
	bls.s	.Ok
	move.w	Maximum(a1),d0
.Ok:	move.w	d0,(a1)
.Exit:	rts

; *** Drug (MAGIC.S) ***
SH_Drug:
	move.w	Body_conditions(a0),d0	; Alive ?
	move.w	d0,d1
	andi.w	#Alive_mask,d1
	bne.s	.Exit
	bset	#Stoned,d0
	move.w	d0,Body_conditions(a0)
.Exit:	rts

; Spell handlers (offsets from Spell_handlers, 0 = not possible here)
H	MACRO
	dc.w	\1-Spell_handlers
	ENDM
Class0_spells:
	H	SH_Healing
	dc.w	0,0
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Healing
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Healing
	dc.w	0,0,0,0,0,0
	H	SH_Healing
	H	SH_Healing
	dc.w	0
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Remove_cond
	dc.w	0,0
	H	SH_Remove_cond
	H	SH_Remove_cond
	H	SH_Restore_stamina
Class6_spells:
	dc.w	0,0
	H	SH_Youth
	dc.w	0
	H	SH_Spell_points
	H	SH_Spell_points
	H	SH_Spell_points
	H	SH_Spell_points
	H	SH_Spell_points
	H	SH_Heal_all
	dc.w	0
	H	SH_Attribute
	H	SH_Attribute
	H	SH_Attribute
	H	SH_Attribute
	H	SH_Attribute
	H	SH_Attribute
	H	SH_Attribute
	H	SH_Attribute
	dc.w	0
	H	SH_Drug
	dc.w	0,0,0,0,0,0,0,0,0

;*****************************************************************************
; [ Number conversion : signed, left justified ]
;   IN : d0 - Number (.w)
;        d7 - Maximum number of digits (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to the EOL (.l)
; Changed registers : a0
; NOTE :
;   - Like SDecL_convert (HULL/NUMERIC.S) : sign ("+", "-", " ") and digits.
;*****************************************************************************
SDecL_convert:
	move.l	d0,-(sp)
	move.b	#" ",(a0)
	tst.w	d0
	beq.s	.Do
	move.b	#"+",(a0)
	tst.w	d0
	bpl.s	.Do
	move.b	#"-",(a0)
	neg.w	d0
.Do:	addq.l	#1,a0
	andi.l	#$ffff,d0
	jsr	DecL_convert
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

; Positions of the class names in item view window 1 (INVENTOR.S)
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

Object_text_name:
	dc.b	"DATA\OT0.BIN",0
	even

	SECTION	Fast_BSS,bss
Used_item_slot:	ds.w 1
Selected_class:	ds.w 1
Selected_spell:	ds.w 1
Special_item_flags:	ds.w 1
Req_icon_Y:	ds.w 1
Cursed_flag:	ds.b 1
	even
Charges_txt:	ds.b 8
Status_icons_UI:	ds.b 22*16*8
Spell_data:	ds.b 7*30*Spell_data_size
	even

	SECTION	Program,code
;*****************************************************************************
; [ Input a number ]
;   IN : d0 - Prompt (message number) (.w)
;        d1 - Maximum number (.l)
;        d2 - 1 = gold, 2 = food (icon and name) (.w)
;  OUT : d0 - Number / 0 = none (.l)
; Changed registers : d0
; NOTE :
;   - Like the InputNr module (HULL/CONTROLS.S, ObjGoldFood_DisInit in
;     DISPLAY.S) : left click on the arrows counts (faster while the button
;     is held), right click goes to the maximum / minimum, {OK} ends. The
;     number can not be typed in the proof of concept, ESC gives 0.
;*****************************************************************************
Input_number:
	movem.l	d1-d7/a0-a2,-(sp)
	move.l	d1,Maximum_number
	clr.l	InputNr_number
	move.w	d0,d5			; Save prompt
	move.w	d2,d6
	move.w	#InputNr_X-16,d0		; Open window
	move.w	#InputNr_Y-16,d1
	moveq.l	#11,d2
	moveq.l	#6,d3
	jsr	Open_window
	move.w	#InputNr_X-1,d0		; Draw box around icon
	move.w	#InputNr_Y-1,d1
	moveq.l	#16,d2
	moveq.l	#16,d3
	jsr	Draw_standard_box
	lea.l	Object_icons+Gold_icon*16*8,a0	; Display icon
	moveq.l	#Gold_txt,d7
	cmp.w	#1,d6
	beq.s	.Gold
	lea.l	Object_icons+Food_icon*16*8,a0
	moveq.l	#Food_txt,d7
.Gold:	move.w	#InputNr_X,d0
	move.w	#InputNr_Y,d1
	jsr	Put_masked_icon
	move.w	#InputNr_X+19,d0		; Draw box around name
	move.w	#InputNr_Y+2,d1
	move.w	#122,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	move.w	#20,Ink_colour		; Print name
	move.w	#Default_shadow,Shadow_colour
	addq.w	#1,d0
	addq.w	#2,d1
	exg	d0,d7
	jsr	Get_text
	exg	d0,d7
	jsr	Print_centered_string
	move.w	#InputNr_X-1,d0		; Draw box around prompt
	move.w	#InputNr_Y+16+2,d1
	move.w	#142,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	move.w	#17,Ink_colour		; Print prompt
	move.w	d5,d0
	addi.w	#Messages,d0
	jsr	Get_text
	move.w	#InputNr_X,d0
	move.w	#InputNr_Y+16+4,d1
	jsr	Print_centered_string
	move.w	#InputNr_X-1,d0		; Draw box around icons
	move.w	#InputNr_Y+29,d1
	moveq.l	#32,d2
	moveq.l	#34,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display up & down icons
	addq.w	#1,d1
	moveq.l	#Up_2D_cicon,d3
	jsr	Display_up_button
	addi.w	#17,d1
	moveq.l	#Down_2D_cicon,d3
	jsr	Display_up_button
	move.w	#InputNr_X+111,d0		; Draw box around OK icon
	move.w	#InputNr_Y+46,d1
	moveq.l	#32,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display OK icon
	addq.w	#1,d1
	moveq.l	#OK_cicon,d3
	jsr	Display_up_button
	jsr	.Show
	jsr	Read_mouse_clicks
; ---------- Input loop ---------------------------
.Loop:	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC ?
	bne.s	.No_esc
	clr.l	InputNr_number
	bra	.Done
.No_esc:	jsr	Read_mouse_clicks
	move.w	d0,d4
	beq.s	.Loop
	move.w	Mouse_X,d0		; Up or down icon ?
	move.w	Mouse_Y,d1
	sub.w	#InputNr_X,d0
	bmi.s	.Loop
	cmp.w	#32,d0
	bpl	.No_arrows
	sub.w	#InputNr_Y+30,d1
	bmi.s	.Loop
	cmp.w	#34,d1
	bpl.s	.Loop
	moveq.l	#1,d2			; Up = +1, down = -1
	moveq.l	#Up_2D_cicon,d3
	move.w	#InputNr_Y+30,d1
	move.w	Mouse_Y,d0
	cmp.w	#InputNr_Y+30+17,d0
	bmi.s	.Up
	moveq.l	#-1,d2
	moveq.l	#Down_2D_cicon,d3
	move.w	#InputNr_Y+47,d1
.Up:	move.w	#InputNr_X,d0
	btst	#Right_pressed,d4		; Right button ?
	beq.s	.Count
	move.l	Maximum_number,InputNr_number	; Yes -> All / nothing
	tst.w	d2
	bpl.s	.All
	clr.l	InputNr_number
.All:	jsr	.Show
	jsr	Display_down_button
	jsr	Copy_screen_to_both
	moveq.l	#8,d7			; (feedback)
.Feedback:	jsr	Switch_screens
	dbra	d7,.Feedback
	bra.s	.Up_again
.Count:	jsr	Display_down_button		; Left button -> count
	move.w	#First_add,d7
	moveq.l	#1,d4			; (first step)
.Again:	move.l	InputNr_number,d5
	tst.w	d2
	bpl.s	.Add
	sub.l	d4,d5
	bpl.s	.Store
	moveq.l	#0,d5
	bra.s	.Store
.Add:	add.l	d4,d5
	cmp.l	Maximum_number,d5
	ble.s	.Store
	move.l	Maximum_number,d5
.Store:	move.l	d5,InputNr_number
	jsr	.Show
	jsr	Copy_screen_to_both
	jsr	Switch_screens
	btst	#Left_pressed,Mouse_buttons	; Still pressed ?
	beq.s	.Up_again
	moveq.l	#0,d4			; Yes -> faster
	move.w	d7,d4
	lsr.w	#8,d4
	addi.w	#Add_delta,d7
	bpl.s	.Again
	move.w	#$7fff,d7
	bra.s	.Again
.Up_again:	jsr	Display_up_button
	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
	bra	.Loop
.No_arrows:	btst	#Left_pressed,d4		; OK icon ?
	beq	.Loop
	sub.w	#111,d0
	bmi	.Loop
	cmp.w	#32,d0
	bpl	.Loop
	sub.w	#InputNr_Y+47,d1
	bmi	.Loop
	cmp.w	#17,d1
	bpl	.Loop
	move.w	#InputNr_X+112,d0		; Feedback
	move.w	#InputNr_Y+47,d1
	moveq.l	#OK_cicon,d3
	jsr	Display_down_button
	jsr	Copy_screen_to_both
.Wait:	jsr	Switch_screens
	btst	#Left_pressed,Mouse_buttons
	bne.s	.Wait
.Done:	jsr	Close_window
	jsr	Read_mouse_clicks
	move.l	InputNr_number,d0
	movem.l	(sp)+,d1-d7/a0-a2
	rts

; Show the number
.Show:	movem.l	d0-d3/d7/a0,-(sp)
	move.w	#InputNr_X+47,d0		; Draw box around number
	move.w	#InputNr_Y+38,d1
	moveq.l	#48,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	move.l	InputNr_number,d0		; Convert number
	moveq.l	#5,d7
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	#31,Ink_colour		; Print number
	move.w	#Default_shadow,Shadow_colour
	move.w	#InputNr_X+48,d0
	move.w	#InputNr_Y+40,d1
	lea.l	Number,a0
	jsr	Print_centered_string
	movem.l	(sp)+,d0-d3/d7/a0
	rts

	SECTION	Fast_BSS,bss
Maximum_number:	ds.l 1
InputNr_number:	ds.l 1
