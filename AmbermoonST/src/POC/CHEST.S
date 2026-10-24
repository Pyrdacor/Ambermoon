; Proof of concept : doors and chests (Atari ST)
;
; The Door and Item found events of EVENTS.S with the door and chest screens
; (layout 3) : picking locks, using keys and lockpicks, finding and
; disarming traps, and the opened chest or pile with its items, gold and
; food. Items are taken by moving them onto a portrait (like in the
; inventory). The chests are kept in memory (CHESTS.BIN), so they stay
; empty when they were emptied.
;
; Layout 3 uses the inventory palette below the status block.

	SECTION	Program,code

Active_member	EQU	1			; (the hero in the proof of concept)
Pic80_X	EQU	16			; 80x80 picture
Pic80_Y	EQU	43
Chest_size	EQU	Items_per_chest*Object_packet_size+4
Gold_X	EQU	110
Food_X	EQU	303-44
Goldfood_Y	EQU	103
; Text numbers in TEXTS.BIN
Gold_txt	EQU	24
Food_txt	EQU	25

;*****************************************************************************
; [ Door event ]
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
Door:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Already open ?
	move.b	Event_b2(a5),d0
	moveq.l	#Door_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	bne.s	.Exit
	clr.w	Lay3_type			; Door
	moveq.l	#Door_pic,d0		; Show door screen
	lea.l	Door_CIL,a0
	jsr	Show_lay3
	moveq.l	#0,d0			; Any text ?
	move.b	Event_b3(a5),d0
	cmp.b	#-1,d0
	beq.s	.No_text
	jsr	Lay3_text
.No_text:	jsr	Locked_loop
.Exit:	rts

;*****************************************************************************
; [ Item found event (chest or pile) ]
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
Item_found:
	lea.l	Current_event_data,a5
; ---------- Is the chest hidden ? ----------------
	tst.b	Event_b2(a5)		; Is it ?
	beq.s	.Not
	moveq.l	#Active_member,d7		; Probe {Searching}
	jsr	Get_char_data
	move.w	SSearch(a1),d0
	add.w	SSearch+Magic(a1),d0
	jsr	Probe_100
	bmi.s	.Exit
; ---------- Is it a chest or a trashpile ? -------
.Not:	btst	#0,Event_b5(a5)
	bne.s	.Open
; ---------- Is the chest already open ? ----------
	moveq.l	#0,d0			; Well ?
	move.b	Event_b4(a5),d0
	moveq.l	#Chest_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	bne.s	.Open
	tst.b	Event_b1(a5)		; 0 % locked ?
	beq.s	.Open
; ---------- Closed chest -------------------------
	move.w	#1,Lay3_type		; Closed chest
	moveq.l	#Closed_chest_pic,d0
	lea.l	ClosedChest_CIL,a0
	jsr	Show_lay3
	jsr	Locked_loop
	bra.s	.Exit
; ---------- Opened chest -------------------------
.Open:	jsr	Opened_chest
.Exit:	rts

;*****************************************************************************
; [ Show a layout 3 screen ]
;   IN : d0 - 80x80 picture number (.w)
;        a0 - Pointer to control icon list (.l)
; All registers are restored
; NOTE :
;   - From [ Door_DisInit ] and [ ClosedChest_DisInit ].
;*****************************************************************************
Show_lay3:
	movem.l	d0-d7/a0-a2,-(sp)
	move.l	a0,a2
	move.w	d0,d2
	sf	Trap_found
	sf	Trap_disarmed
	sf	Moving_flag
	sf	Lay3_exit
	sf	Success
	move.w	#3,Inventory_mode		; (for the objects under the mouse)
	move.w	#Active_member,Inventory_member	; (for ~INVN~)
	move.l	#Lay3_bar,SB_ptr
	move.l	#Lay3_PA,Print_area_ptr
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	lea.l	Lay3_files,a0		; Load layout
	jsr	Load_files
	move.w	d2,d0			; Load picture
	jsr	Load_80x80_picture
	lea.l	Lay3_RL,a0		; Install palettes
	jsr	Set_raster_list
	moveq.l	#0,d0			; Show layout
	moveq.l	#Middle_Y+1,d1
	moveq.l	#20,d6
	move.w	#199-Middle_Y,d7
	lea.l	Extra_layout,a0
	jsr	Put_unmasked_block
	jsr	Display_80x80_picture
	jsr	Erase_PA
	move.l	a2,a0			; Show icons
	jsr	Display_CIL
	jsr	Hide_Lay3_objects
	jsr	Copy_screen_to_both
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Load an 80x80 picture ]
;   IN : d0 - Picture number (.w)
; All registers are restored
Load_80x80_picture:
	movem.l	d0-d2/a1,-(sp)
	lea.l	Pic80_buffer,a1
	move.l	#5*80*8,d1
	move.l	#'P80_',d2
	jsr	Load_named_file
	movem.l	(sp)+,d0-d2/a1
	rts

; [ Display the 80x80 picture ]
; All registers are restored
Display_80x80_picture:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	moveq.l	#Pic80_X,d0
	moveq.l	#Pic80_Y,d1
	moveq.l	#5,d6
	moveq.l	#80,d7
	lea.l	Pic80_buffer,a0
	jsr	Put_unmasked_block
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

; [ Hide the object slots of layout 3 ]
; All registers are restored
; NOTE :
;   - From [ Hide_Lay3_objects ] (DISPLAY.S).
Hide_Lay3_objects:
	movem.l	d0-d3/d7/a0,-(sp)
	lea.l	Lay3_object_pos_list,a0
	moveq.l	#16,d2
	moveq.l	#24,d3
	moveq.l	#12-1,d7
.Loop:	move.w	(a0)+,d0
	move.w	(a0)+,d1
	jsr	Draw_standard_box2
	dbra	d7,.Loop
	move.w	#154,d0			; Hide scroll bar
	move.w	#139,d1
	moveq.l	#6,d2
	moveq.l	#53,d3
	jsr	Draw_standard_box2
	movem.l	(sp)+,d0-d3/d7/a0
	rts

; [ Back to the map ]
;   IN : d0 - 0 = stay, 1 = go back to the previous position (.w)
; All registers are restored
; NOTE :
;   - Like [ Door_Exit ] ([ Restore_coordinates ] and [ Basic_exit ]).
Close_lay3:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,d7
	clr.l	Ghost_text
	clr.l	Drag_graphic
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	jsr	Hide_status_icons
	lea.l	Mouse_pointer,a0
	jsr	Change_Mptr
	tst.w	d7			; Go back ?
	beq.s	.Stay
	move.w	Old_Xcoord,Map_Xcoord	; Yes
	move.w	Old_Ycoord,Map_Ycoord
	jsr	World_evaluate
.Stay:	jsr	Recalc_mapbuf_coords
	lea.l	Map_RL,a0
	jsr	Set_raster_list
	jsr	Display_status_block
	jsr	Draw_map_screen
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Print a map text in the print area and wait ]
;   IN : d0 - Text block number (.w)
; All registers are restored
; NOTE :
;   - Like [ Do_text ] (HULL/CONTROLS.S) with the print area of layout 3.
Lay3_text:
	movem.l	d0-d7/a0-a4,-(sp)
	jsr	Get_event_texts
	jsr	Find_large_text
	move.l	Print_area_ptr,a3
	move.w	PA_X2(a3),d0		; Width
	sub.w	PA_X1(a3),d0
	addq.w	#1,d0
	ext.l	d0
	divu.w	#Char_width+1,d0
	move.w	d0,Text_width
	jsr	Process_text
	move.w	PA_Y2(a3),d5		; Lines per page
	sub.w	PA_Y1(a3),d5
	addq.w	#1,d5
	ext.l	d5
	divu.w	#Char_height+2,d5
	lea.l	Text_lines,a4
	move.w	Text_height,d6		; Lines left
	beq.s	.Exit
.Page:	jsr	Erase_PA
	move.w	#White,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	move.w	PA_X1(a3),d0
	move.w	PA_Y1(a3),d1
	addq.w	#1,d1
	move.w	d5,d7
	cmp.w	d6,d7
	bls.s	.Ok
	move.w	d6,d7
.Ok:	sub.w	d7,d6
	subq.w	#1,d7
.Line:	move.l	a4,a0
	jsr	Put_text_line
	lea.l	Line_stride(a4),a4
	addi.w	#Char_height+2,d1
	dbra	d7,.Line
	jsr	Copy_screen_to_both
	jsr	Wait_for_click
	tst.w	d6
	bne.s	.Page
	jsr	Erase_PA
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Door / closed chest screen ]
; NOTE :
;   - From the Door and ClosedChest modules (EVENTS.S).
;*****************************************************************************
Locked_loop:
	movem.l	d0-d7/a0-a6,-(sp)
.Loop:	jsr	Switch_screens
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
	cmp.w	#1,d0			; Pick lock ?
	bne.s	.No1
	jsr	Pick_lock
	bra.s	.Next
.No1:	cmp.w	#2,d0			; Use item ?
	bne.s	.No2
	jsr	Use_item_lock
	bra.s	.Next
.No2:	cmp.w	#3,d0			; Exit ?
	bne.s	.No3
	jsr	Press_exit_icon
.Leave:	moveq.l	#1,d0			; Go back
	jsr	Close_lay3
	bra.s	.Exit
.No3:	cmp.w	#4,d0			; Find trap ?
	bne.s	.No4
	jsr	Find_trap
	bra.s	.Next
.No4:	cmp.w	#7,d0			; Disarm trap ?
	bne.s	.Loop
	jsr	Disarm_trap
.Next:	tst.b	Lay3_exit			; Done ?
	beq.s	.Loop
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Pick lock ]
; NOTE :
;   - From [ Pick_lock_DOOR ] and [ Pick_lock_CHEST ].
Pick_lock:
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	moveq.l	#0,d0			; Get locked percentage
	move.b	Current_event_data+Event_b1,d0
	cmpi.w	#100,d0			; Fully locked ?
	beq.s	.No_luck
	neg.w	d0			; Probe {Pick locks}
	add.w	SPick_locks(a1),d0
	add.w	SPick_locks+Magic(a1),d0
	jsr	Probe_100
	bpl.s	.Opened_it
	tst.b	Trap_disarmed		; Trap already disarmed ?
	beq.s	.Trap
.No_luck:	moveq.l	#76,d0			; No luck !
	jmp	Do_prompt
.Trap:	cmp.w	#-1,Current_event_data+Event_w8	; Any trap ?
	beq.s	.No_luck
	move.w	ADexterity(a1),d0		; Probe {Dexterity}
	add.w	ADexterity+Magic(a1),d0
	jsr	Probe_100
	bpl.s	.No_trap
	jmp	Trap_released
.No_trap:	moveq.l	#69,d0			; The trap failed
	jmp	Do_prompt
.Opened_it:	moveq.l	#68,d0			; Opened it !
	tst.w	Lay3_type
	beq	Door_opened
	moveq.l	#80,d0
	bra	Chest_opened

; [ The trap is released : the negative chain is handled ]
Trap_released:
	move.w	Current_event_data+Event_w8,Current_event_data+Next_event_nr
	moveq.l	#1,d0			; Exit
	jsr	Close_lay3
	st	Lay3_exit
	rts

; [ Find trap ]
; NOTE :
;   - From [ Find_trap_DOOR ].
Find_trap:
	tst.b	Trap_found		; Already found ?
	bne.s	.Exit
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	cmp.w	#-1,Current_event_data+Event_w8	; Any trap ?
	beq.s	.No_find
	move.w	SFind_traps(a1),d0		; Probe {Find traps}
	add.w	SFind_traps+Magic(a1),d0
	jsr	Probe_100
	bpl.s	.Found_it
.No_find:	moveq.l	#72,d0			; No traps
	jmp	Do_prompt
.Found_it:	st	Trap_found		; Found it !
	moveq.l	#71,d0
	jmp	Do_prompt
.Exit:	rts

; [ Disarm trap ]
; NOTE :
;   - From [ Disarm_trap_DOOR ] (only after the trap was found).
Disarm_trap:
	tst.b	Trap_found		; Found ?
	beq.s	.Exit
	tst.b	Trap_disarmed		; Not disarmed yet ?
	bne.s	.Exit
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	move.w	SDisarm_traps(a1),d0	; Probe {Disarm traps}
	add.w	SDisarm_traps+Magic(a1),d0
	jsr	Probe_100
	bpl.s	.Disarmed_it
	move.w	ADexterity(a1),d0		; Probe {Dexterity}
	add.w	ADexterity+Magic(a1),d0
	jsr	Probe_100
	bmi	Trap_released
	moveq.l	#69,d0			; The trap failed
	jmp	Do_prompt
.Disarmed_it:
	st	Trap_disarmed		; Disarmed it !
	moveq.l	#73,d0
	jmp	Do_prompt
.Exit:	rts

; [ Use a key or a lockpick ]
; NOTE :
;   - From [ Use_item_DOOR ] and [ Use_item_CHEST ] : the backpack of the
;     active member is shown in the object slots.
Use_item_lock:
	movem.l	d0-d7/a0-a3,-(sp)
	moveq.l	#Active_member,d7		; Show backpack
	jsr	Get_char_data
	lea.l	Char_inventory+Backpack_slots(a1),a1
	move.l	a1,Slot_base
	moveq.l	#0,d0
	jsr	Set_scroll_row
	move.w	#77,d0			; Select item
	tst.w	Lay3_type
	beq.s	.Door
	move.w	#78,d0
.Door:	moveq.l	#0,d1
	jsr	Select_item
	tst.w	d0
	beq	.Done
	jsr	Get_slot_packet		; Get item
	move.l	a0,a2
	move.w	d0,d2			; (slot number)
	move.w	Object_index(a2),d0
	jsr	Get_item_data
	lea.l	Current_event_data,a5
	cmp.w	Event_w6(a5),d0		; Right item ?
	bne.s	.Wrong1
	btst	#Destroy_after_use,Item_bits_STATIC(a1)	; Use once ?
	beq.s	.Opened
	moveq.l	#1,d3			; Remove key
	jsr	.Remove
.Opened:	moveq.l	#70,d0			; The key fits
	tst.w	Lay3_type
	beq.s	.Prompt
	moveq.l	#79,d0
.Prompt:	jsr	Do_prompt
	jsr	Hide_Lay3_objects
	moveq.l	#-1,d0			; Open
	tst.w	Lay3_type
	bne.s	.Chest
	jsr	Door_opened
	bra.s	.Exit
.Chest:	jsr	Chest_opened
	bra.s	.Exit
.Wrong1:	cmpi.b	#6,Spell_class(a1)		; Lockpick ?
	bne.s	.Wrong2
	cmpi.b	#1,Spell_number(a1)
	bne.s	.Wrong2
	moveq.l	#1,d3			; (used up)
	jsr	.Remove
	cmpi.b	#100,Event_b1(a5)		; Fully locked ?
	bmi.s	.Works
	moveq.l	#75,d0			; Lockpick breaks
	jsr	Do_prompt
	bra.s	.Done
.Works:	moveq.l	#74,d0			; Lockpick works
	tst.w	Lay3_type
	beq.s	.Prompt2
	moveq.l	#81,d0
.Prompt2:	jsr	Do_prompt
	jsr	Hide_Lay3_objects
	moveq.l	#-1,d0
	tst.w	Lay3_type
	bne.s	.Chest
	jsr	Door_opened
	bra.s	.Exit
.Wrong2:	moveq.l	#82,d0			; Does not fit
	tst.w	Lay3_type
	beq.s	.Prompt3
	moveq.l	#83,d0
.Prompt3:	jsr	Do_prompt
.Done:	jsr	Hide_Lay3_objects
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

; Remove d3 items of slot d2 from the active member
.Remove:	movem.l	d0/d7/a0/a1,-(sp)
	moveq.l	#Active_member,d7
	jsr	Get_char_data
	move.l	a1,a0
	jsr	Remove_item
	movem.l	(sp)+,d0/d7/a0/a1
	rts

; [ Door was opened ]
;   IN : d0 - Prompt number when no text is given / -1 (.w)
; NOTE :
;   - From [ Door_opened ].
Door_opened:
	lea.l	Current_event_data,a5
	moveq.l	#0,d1			; Any text ?
	move.b	Event_b4(a5),d1
	cmp.b	#-1,d1
	beq.s	.None
	move.w	d1,d0			; Display text
	jsr	Lay3_text
	bra.s	.Go_on
.None:	tst.w	d0			; Any prompt ?
	bmi.s	.Go_on
	jsr	Do_prompt
.Go_on:	moveq.l	#0,d0			; Save
	move.b	Event_b2(a5),d0
	moveq.l	#Door_bit_array,d1
	moveq.l	#1,d2
	jsr	Access_bit_array
	st	Success			; Success !
	st	Lay3_exit
	moveq.l	#0,d0			; Exit
	jmp	Close_lay3

; [ Chest was opened ]
;   IN : d0 - Prompt number / -1 (.w)
; NOTE :
;   - From [ Chest_opened ].
Chest_opened:
	lea.l	Current_event_data,a5
	tst.w	d0			; Any prompt ?
	bmi.s	.Skip
	jsr	Do_prompt
.Skip:	moveq.l	#0,d0			; Save
	move.b	Event_b4(a5),d0
	moveq.l	#Chest_bit_array,d1
	moveq.l	#1,d2
	jsr	Access_bit_array
	st	Success			; Success !
	st	Lay3_exit
	jmp	Opened_chest		; Open the chest

;*****************************************************************************
; [ Opened chest screen ]
; NOTE :
;   - From the OpenedChest module (EVENTS.S).
;*****************************************************************************
Opened_chest:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get chest data
	move.b	Event_b4(a5),d0
	mulu.w	#Chest_size,d0
	lea.l	Chests,a0
	add.l	d0,a0
	move.l	a0,Chest_ptr
	lea.l	Chest_work,a1		; Work on a copy
	move.w	#Chest_size-1,d7
.Copy:	move.b	(a0)+,(a1)+
	dbra	d7,.Copy
	move.w	#2,Lay3_type
	jsr	Chest_picture		; Show screen
	move.w	d0,Chest_pic
	lea.l	OpenedChest_CIL,a0
	jsr	Show_lay3
	move.w	#2,Lay3_type
	jsr	Show_chest
	btst	#0,Event_b5(a5)		; Pile ?
	bne.s	.Text
	tst.b	Success			; Just opened ?
	beq.s	.No_text
.Text:	moveq.l	#0,d0			; Any text ?
	move.b	Event_b3(a5),d0
	cmp.b	#-1,d0
	beq.s	.No_text
	jsr	Lay3_text
.No_text:	jsr	Opened_chest_loop
	btst	#1,Event_b5(a5)		; Write back ?
	bne.s	.Exit
	lea.l	Chest_work,a0		; Yes
	move.l	Chest_ptr,a1
	move.w	#Chest_size-1,d7
.Copy2:	move.b	(a0)+,(a1)+
	dbra	d7,.Copy2
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Load the picture of the chest ]
;  OUT : d0 - Picture number (.w)
; Changed registers : d0
Chest_picture:
	moveq.l	#Trashpile_pic,d0
	btst	#0,Current_event_data+Event_b5	; Pile or chest ?
	bne.s	.Exit
	moveq.l	#Opened_chest_pic,d0	; Full
	jsr	Chest_filled
	bne.s	.Exit
	moveq.l	#Empty_chest_pic,d0		; Empty
.Exit:	rts

; [ Is the chest filled ? ]
;  OUT : ne - Yes, eq - No
; All registers are restored
Chest_filled:
	movem.l	d7/a0,-(sp)
	lea.l	Chest_work,a0
	tst.w	Chest_gold(a0)		; Maybe gold or food ?
	bne.s	.Yes
	tst.w	Chest_food(a0)
	bne.s	.Yes
	moveq.l	#Items_per_chest-1,d7
.Loop:	tst.w	Object_index(a0)		; Anything there ?
	bne.s	.Yes
	addq.w	#Object_packet_size,a0
	dbra	d7,.Loop
	moveq.l	#0,d7
	bra.s	.Exit
.Yes:	moveq.l	#-1,d7
.Exit:	tst.w	d7
	movem.l	(sp)+,d7/a0
	rts

; [ Show the items, gold & food of the chest ]
; All registers are restored
Show_chest:
	movem.l	d0,-(sp)
	move.l	#Chest_work,Slot_base
	move.l	#Lay3_bar,SB_ptr
	moveq.l	#0,d0
	jsr	Set_scroll_row
	jsr	Update_goldfood
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0
	rts

; [ Update the gold & food display ]
; All registers are restored
; NOTE :
;   - From [ Update_gold ] and [ Update_food ].
Update_goldfood:
	movem.l	d0-d7/a0,-(sp)
	move.w	#Gold_X,d7
	move.w	Chest_work+Chest_gold,d5
	moveq.l	#Gold_txt,d6
	jsr	.Box
	move.w	#Food_X,d7
	move.w	Chest_work+Chest_food,d5
	moveq.l	#Food_txt,d6
	jsr	.Box
	movem.l	(sp)+,d0-d7/a0
	rts

; Box at X = d7 with the amount d5 and the text d6
.Box:	move.w	d7,d0
	move.w	#Goldfood_Y,d1
	tst.w	d5			; Any ?
	bne.s	.Yes
	move.w	d0,d2			; No -> Erase
	move.w	d1,d3
	addi.w	#45-1,d2
	addi.w	#17-1,d3
	moveq.l	#Window_colour,d4
	jmp	Draw_box
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
	move.w	#Goldfood_Y+9,d1
	moveq.l	#45,d2
	lea.l	Number,a0
	jmp	Print_centered_string

; [ Opened chest : input loop ]
Opened_chest_loop:
	movem.l	d0-d7/a0-a6,-(sp)
	sf	Lay3_exit
.Loop:	jsr	Update_ghost
	jsr	Switch_screens
	jsr	Read_key
	cmp.w	#$01,d0			; ESC ?
	bne.s	.No_esc
	tst.b	Moving_flag		; Moving ?
	beq	.Leave
	jsr	Chest_move_aborted
	bra.s	.Loop
.No_esc:	jsr	Read_mouse_clicks
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
	bra.s	.Loop
.Left:	btst	#Left_pressed,d6
	beq.s	.Loop
	cmp.w	#Obj_scroll_bar,d1		; Scroll bar ?
	bne.s	.No_bar
	jsr	Scroll_bar_pressed
	bra.s	.Loop
.No_bar:	tst.b	Moving_flag		; Moving ?
	bne.s	.Moving
	cmp.w	#Obj_backpack,d1		; Chest slot ?
	bne.s	.No_slot
	jsr	Take_chest_item
	bra	.Loop
.No_slot:	cmp.w	#Obj_icon,d1		; Control icon ?
	bne	.Loop
	cmp.w	#3,d0			; Exit ?
	bne.s	.No_exit
	jsr	Press_exit_icon
	bra	.Leave
.No_exit:	cmp.w	#5,d0			; Divide gold ?
	bne.s	.No_gold
	lea.l	Chest_work+Chest_gold,a0
	moveq.l	#Gold_weight,d2
	moveq.l	#Gold_coins,d3
	jsr	Divide
	bra.s	.Check
.No_gold:	cmp.w	#6,d0			; Divide food ?
	bne.s	.No_food
	lea.l	Chest_work+Chest_food,a0
	move.w	#Food_weight,d2
	moveq.l	#Food_rations,d3
	jsr	Divide
	bra.s	.Check
.No_food:	cmp.w	#7,d0			; View item ?
	bne	.Loop
	jsr	View_item
	bra	.Loop
.Moving:	cmp.w	#Obj_member,d1		; Portrait ?
	bne.s	.No_member
	jsr	Chest_member_moved
	bra.s	.Check
.No_member:	cmp.w	#Obj_backpack,d1		; Chest slot ?
	bne	.Loop
	jsr	Chest_item_moved
; ---------- Chest emptied ? ----------------------
.Check:	jsr	Update_goldfood
	jsr	Update_status_bars
	jsr	Chest_filled		; Still something there ?
	bne.s	.Filled
	tst.b	Moving_flag
	bne.s	.Filled
	btst	#0,Current_event_data+Event_b5	; Pile ?
	beq.s	.Chest
	st	Success			; Yes -> Done
	btst	#1,Current_event_data+Event_b5	; Write back ?
	bne.s	.Leave
	jsr	Save_event
	bra.s	.Leave
.Chest:	cmp.w	#Empty_chest_pic,Chest_pic	; Show empty chest
	beq.s	.Filled
	moveq.l	#Empty_chest_pic,d0
	move.w	d0,Chest_pic
	jsr	Load_80x80_picture
	jsr	Display_80x80_picture
.Filled:	jsr	Copy_screen_to_both
	bra	.Loop
.Leave:	moveq.l	#1,d0			; Exit
	jsr	Close_lay3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Redraw the LP & SP bars of the party ]
Update_status_bars:
	movem.l	d7,-(sp)
	moveq.l	#1,d7
.Loop:	jsr	Update_member_bars
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d7
	rts

; [ Take an item from the chest ]
;   IN : d0 - Slot number {1...12} (.w)
; NOTE :
;   - From [ Move_all_LAY3_items ] (the whole stack is taken).
Take_chest_item:
	movem.l	d0-d3/a0-a2,-(sp)
	add.w	Scroll_bar_result,d0
	move.w	d0,Source_slot
	jsr	Chest_packet
	move.l	a0,a2
	tst.w	Object_index(a2)		; Anything there ?
	beq.s	.Exit
	lea.l	Inter_packet,a1		; Copy packet
	Copy_packet a2,a1
	clr.b	Quantity(a2)		; Remove
	clr.w	Object_index(a2)
	st	Moving_flag
	clr.l	Ghost_text
	jsr	Init_moving_item
	lea.l	Pick_pointer,a0
	jsr	Change_Mptr
	moveq.l	#55,d0			; "Where to ?"
	jsr	Print_prompt
	jsr	Update_objects
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d3/a0-a2
	rts

; [ Get a chest packet ]
;   IN : d0 - Slot number {1...24} (.w)
;  OUT : a0 - Pointer to packet (.l)
; Changed registers : a0
Chest_packet:
	move.l	d0,-(sp)
	lea.l	Chest_work-Object_packet_size,a0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a0
	move.l	(sp)+,d0
	rts

; [ Player clicked on a portrait while moving an item from the chest ]
;   IN : d0 - Member number {1...6} (.w)
; NOTE :
;   - From [ Member_moved_LAY3 ].
Chest_member_moved:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	d0,d7
	lea.l	Inter_packet,a2
	jsr	Check_transfer		; Possible ?
	bne.s	.Exit
	jsr	Get_char_data
	move.l	a2,a0
	jsr	Auto_move_to_backpack
	tst.w	Object_index(a2)		; Any left ?
	bne.s	.Left
	jsr	Stop_moving		; No -> stop
	bra.s	.Exit
.Left:	jsr	Init_moving_item		; Yes -> update
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Player clicked on a chest slot while moving an item ]
;   IN : d0 - Slot number {1...12} (.w)
; NOTE :
;   - From [ LAY3_item_moved ].
Chest_item_moved:
	movem.l	d0-d7/a0-a4,-(sp)
	add.w	Scroll_bar_result,d0
	move.w	d0,Target_slot
	jsr	Chest_packet
	move.l	a0,a2
	lea.l	Inter_packet,a3
	move.w	Object_index(a3),d0
	jsr	Get_item_data
	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Empty
	cmp.w	Object_index(a3),d0		; Same item ?
	bne.s	.Swap
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple ?
	beq.s	.Swap
	moveq.l	#0,d0			; Does it fit in the slot ?
	move.b	Quantity(a2),d0
	moveq.l	#0,d3
	move.b	Quantity(a3),d3
	add.w	d3,d0
	cmpi.w	#99,d0
	bls.s	.End
	moveq.l	#99,d0			; Calculate number that will
	sub.b	Quantity(a2),d0		;  fit
	move.b	#99,Quantity(a2)
	sub.b	d0,Quantity(a3)
	jsr	Init_moving_item
	bra.s	.Show
.End:	add.b	d3,Quantity(a2)		; Transfer
	clr.w	Object_index(a3)
	bra.s	.Done
.Empty:	Copy_packet a3,a2			; Fill empty slot
	clr.w	Object_index(a3)
	bra.s	.Done
.Swap:	lea.l	Swap_packet,a4		; Swap
	Copy_packet a2,a4
	Copy_packet a3,a2
	Copy_packet a4,a3
	move.w	Target_slot,Source_slot
	jsr	Init_moving_item
	bra.s	.Show
.Done:	jsr	Stop_moving
.Show:	jsr	Update_objects
	movem.l	(sp)+,d0-d7/a0-a4
	rts

; [ Put the moved item back into the chest ]
Chest_move_aborted:
	movem.l	d0/a0/a2,-(sp)
	move.w	Source_slot,d0
	jsr	Chest_packet
	tst.w	Object_index(a0)		; Free ?
	beq.s	.Put
	lea.l	Chest_work,a0		; No -> find a free slot
	moveq.l	#Items_per_chest-1,d0
.Loop:	tst.w	Object_index(a0)
	beq.s	.Put
	addq.w	#Object_packet_size,a0
	dbra	d0,.Loop
	bra.s	.Exit
.Put:	lea.l	Inter_packet,a2
	Copy_packet a2,a0
	clr.w	Object_index(a2)
	jsr	Stop_moving
	jsr	Update_objects
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0/a0/a2
	rts

;*****************************************************************************
; [ Divide gold or food ]
;   IN : d2 - Weight of one unit (.w)
;        d3 - Offset of the gold or food in the character data (.w)
;        a0 - Pointer to the amount (.l)
; All registers are restored
; NOTE :
;   - Like [ Divide_gold ] and [ Divide_food ] (MAIN.S) : the units are
;     given one by one to the members who can carry them.
;*****************************************************************************
Divide:
	movem.l	d0-d7/a0-a2,-(sp)
	ext.l	d2
.Again:	moveq.l	#0,d6			; Nobody yet
	moveq.l	#1,d7
.Loop:	tst.w	(a0)			; Anything left ?
	beq.s	.Exit
	jsr	Get_char_data
	move.w	#Alive_mask,d0		; Alive ?
	and.w	Body_conditions(a1),d0
	bne.s	.Next
	move.w	AStrength(a1),d0		; Can carry one more ?
	add.w	AStrength+Magic(a1),d0
	addq.w	#1,d0
	mulu.w	#1000,d0
	subq.l	#1,d0
	sub.l	Weight_normal(a1),d0
	cmp.l	d2,d0
	bmi.s	.Next
	subq.w	#1,(a0)			; Yes -> give one
	addq.w	#1,0(a1,d3.w)
	add.l	d2,Weight_normal(a1)
	moveq.l	#1,d6
.Next:	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	tst.w	d6			; Anyone ?
	bne.s	.Again
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Helpers ]
;*****************************************************************************
; [ Probe ]
;   IN : d0 - Probe value (.w)
;  OUT : pl - Positive probe (dice roll < probe value), mi - Negative probe
; All registers are restored
; NOTE :
;   - Like [ Probe_100 ] (MAIN.S).
Probe_100:
	movem.l	d0/d1,-(sp)
	move.w	d0,d1
	jsr	Random			; Dice roll 0...99
	mulu.w	#100,d0
	swap	d0
	cmp.w	d1,d0
	bmi.s	.Yes
	moveq.l	#-1,d0
	bra.s	.Exit
.Yes:	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d0/d1
	rts

; [ Save the current event (it will not happen again) ]
; All registers are restored
; NOTE :
;   - From [ Save_event ] (EVENTS.S).
Save_event:
	movem.l	d0-d2,-(sp)
	move.w	Current_event_entry_nr,d0	; Calculate bit number
	move.w	Current_event_map_nr,d1
	subq.w	#1,d1
	mulu.w	#Events_per_map,d1
	add.w	d1,d0
	subq.w	#1,d0
	moveq.l	#Event_bit_array,d1		; Set bit
	moveq.l	#1,d2
	jsr	Access_bit_array
	movem.l	(sp)+,d0-d2
	rts

; [ Load a file "DATA\<prefix><number>.BIN" ]
;   IN : d0 - Number (.w)
;        d1 - Maximum length (.l)
;        d2 - Prefix (4 characters) (.l)
;        a1 - Pointer to buffer (.l)
; All registers are restored
Load_named_file:
	movem.l	d0-d2/a0,-(sp)
	lea.l	Named_file+5,a0
	rol.l	#8,d2			; Prefix
	move.b	d2,(a0)+
	rol.l	#8,d2
	move.b	d2,(a0)+
	rol.l	#8,d2
	move.b	d2,(a0)+
	rol.l	#8,d2
	move.b	d2,(a0)+
	andi.l	#$ffff,d0			; Number
	cmp.w	#10,d0
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
	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

; Raster list of layout 3 (Main_RL : the inventory palette below)
Lay3_RL:	R_palette 0,UI_palette
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Inv_palette
	R_end
	even

; Print area of layout 3 (Lay3_PA in MODULES.S)
Lay3_PA:	dc.w 113,300,46,97

; Scroll bar of layout 3 (Lay3_scroll_bar in DISPLAY.S : 4 rows of 6 slots,
; 2 rows visible)
Lay3_bar:	dc.l Lay3_object_pos_list
	dc.w 154,139,53,53/4,53-2*(53/4),2,6,1

; Positions of the object slots of layout 3 (ACTIONS.S)
Lay3_object_pos_list:
	dc.w 22,139,44,139,66,139
	dc.w 88,139,110,139,132,139
	dc.w 22,168,44,168,66,168
	dc.w 88,168,110,168,132,168

; Control icon lists (EVENTS.S) : using items, finding and disarming traps
; are done by the active member
Door_CIL:	dc.w Pick_lock_cicon,Use_item_cicon,Exit_cicon
	dc.w Find_traps_cicon,0,0
	dc.w Disarm_traps_cicon,0,0
ClosedChest_CIL:
	dc.w Pick_lock_cicon,Use_item_cicon,Exit_cicon
	dc.w Find_traps_cicon,0,0
	dc.w Disarm_traps_cicon,0,0
OpenedChest_CIL:
	dc.w 0,0,Exit_cicon
	dc.w 0,Divide_gold_cicon,Divide_food_cicon
	dc.w View_item_cicon,Transfer_gold_cicon+Disabled,Transfer_food_cicon+Disabled

Lay3_files:
	dc.l	Extra_layout,320*163/2
	dc.b	"DATA\LAYOUT3.BIN",0
	even
	dc.l	0

Named_file:	dc.b	"DATA\XXXXXXXXXXXX",0
	even

	SECTION	Fast_BSS,bss
Lay3_type:	ds.w 1			; 0 = door, 1 = closed chest, 2 = opened chest
Chest_pic:	ds.w 1
Chest_ptr:	ds.l 1
Old_Xcoord:	ds.w 1
Old_Ycoord:	ds.w 1
Trap_found:	ds.b 1
Trap_disarmed:	ds.b 1
Lay3_exit:	ds.b 1
	even
Chest_work:	ds.b Chest_size
Pic80_buffer:	ds.b 5*80*8
Chests:	ds.b 256*Chest_size
	even
