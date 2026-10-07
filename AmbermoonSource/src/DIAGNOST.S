; Diagnostic routines 2
; Written by Jurie Horneman (In Tune With The Universe)
; Start : 3-2-1993
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	XDEF	Out_of_memory
	XDEF	Diagnostics_list2

	SECTION	Program,code
;*****************************************************************************
; [ Out of memory ]
; No registers are restored
;*****************************************************************************
Out_of_memory:
	jsr	Fade_out_all
; ---------- Inform the player --------------------
	jsr	Init_diagnostic_screen
	move.l	Out_of_memory_text_ptr,a1
	jsr	DI_Print_text
	jsr	Exit_diagnostic_screen
; ---------- Protect memory -----------------------
	lea.l	Party_handles,a0		; Claim party data
	moveq.l	#6-1,d7
.Loop1:	move.b	(a0)+,d0			; Anyone there ?
	beq.s	.Next
	jsr	Claim_pointer
.Next:	dbra	d7,.Loop1			; Next party member
; ---------- Save automapper data & clean up ------
	cmp.b	#Map_3D,Current_map_type	; 3D map ?
	bpl.s	.3D
	jsr	Kill_unclaimed_memory	; No -> Clean up
	bra.s	.Do
.3D:	move.b	Automap_handle,d0		; Yes -> Claim
	jsr	Claim_pointer
	jsr	Kill_unclaimed_memory	; Clean up
	jsr	Save_automap		; Save automap
; ---------- Save party character data ------------
.Do:	lea.l	Party_handles,a1
	lea.l	Member_nrs,a2
	moveq.l	#Party_char_file,d1
	moveq.l	#6-1,d7
.Loop2:	tst.b	(a1)			; Anyone there ?
	beq.s	.Next2
	move.w	(a2),d0			; Yes -> Save datafile
	Get	(a1),a0
	jsr	Save_subfile
	Free	(a1)
.Next2:	addq.l	#1,a1			; Next member
	addq.l	#2,a2
	dbra	d7,.Loop2
; ---------- Save party data ----------------------
	moveq.l	#0,d0			; Calculate party data length
	move.w	Nr_of_modifications,d0
	mulu.w	#Modif_data_size,d0
	addi.l	#Party_data_size+2,d0
	moveq.l	#Party_data_file,d1		; Save party data
	lea.l	Party_data,a0
	jsr	Save_encrypted_file
; ---------- Restart ------------------------------
	move.w	#-1,Initial_save		; No loading
	jmp	Restart_game

	ifne	Cheat
;*****************************************************************************
; [ Jump to map ]
;*****************************************************************************
Jump_to_map:
	jsr	Get_module_ID		; In map screen ?
	tst.b	d0
	beq	.Exit
	cmp.b	#M3Map_ID+1,d0
	bpl	.Exit
	move.w	#16,d0			; Yes -> open window
	move.w	#50,d1
	moveq.l	#8,d2
	moveq.l	#3,d3
	sub.l	a0,a0
	jsr	Open_window
	jsr	Update_screen
	move.w	#32,d0			; Input string
	move.w	#66+4,d1
	moveq.l	#15,d2
	jsr	Input_string
	jsr	Close_window		; Close window
	jsr	String_to_number		; Convert to number
	tst.w	d0			; Error ?
	beq	.Exit
	cmp.w	#Max_maps+1,d0
	bpl	.Exit
	move.w	d0,Map_nr			; No -> new map
	move.w	#5,Map_Xcoord
	move.w	#5,Map_Ycoord
	jsr	Exit_map
	jsr	Init_map
.Exit:	rts

;*****************************************************************************
; [ Toggle Superchicken mode ]
;*****************************************************************************
Toggle_Superchicken:
	cmp.w	#Super_chicken,Travel_mode	; Already ?
	bne.s	.No
	moveq.l	#On_foot,d0		; Yes
	jsr	Set_new_travel_mode
	bra.s	.Exit
.No:	moveq.l	#Super_chicken,d0		; No
	jsr	Set_new_travel_mode
	XX	$f00
	moveq.l	#5,d0
	jsr	Delay
.Exit:	rts

;*****************************************************************************
; [ Main status screen ]
;*****************************************************************************
Main_status:
	jsr	Init_diagnostic_screen
	lea.l	Map_nr_text,a1		; Print map number
	jsr	DI_Print
	move.w	Map_nr,d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Map_X_text,a1		; Print X-coordinate
	jsr	DI_Print
	move.w	Map_Xcoord,d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Map_Y_text,a1		; Print Y-coordinate
	jsr	DI_Print
	move.w	Map_Ycoord,d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Map_view_text,a1		; Print view direction
	jsr	DI_Print
	move.w	View_direction,d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Travel_mode_text,a1		; Print travel mode
	jsr	DI_Print
	move.w	Travel_mode,d0
	jsr	DI_DecW
	jsr	DI_CR
	jsr	DI_CR
	cmp.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bmi	.No_3D
	lea.l	Groups_3D_text,a1		; Print 3D info
	jsr	DI_Print
	move.w	Nr_of_groups,d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Objects_3D_text,a1
	jsr	DI_Print
	move.w	Nr_of_objects,d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Walls_3D_text,a1
	jsr	DI_Print
	move.w	Nr_of_walls,d0
	jsr	DI_DecW
	jsr	DI_CR
.No_3D:	jmp	Exit_diagnostic_screen

;*****************************************************************************
; [ Kill all monsters ]
;*****************************************************************************
Kill_all_monsters:
	jsr	Get_module_ID		; In combat screen ?
	cmp.b	#Combat_ID,d0
	bne	.Exit
	lea.l	Combat_monsters,a0
	move.w	Nr_monsters,d7
	subq.w	#1,d7
.Loop:	Get	Part_handle(a0),a1		; Able to fight ?
	move.w	Body_conditions(a1),d0
	Free	Part_handle(a0)
	and.w	#Fight_mask,d0
	bne.s	.Next
	jsr	Kill_monster		; Yes -> Kill !
.Next:	lea.l	Participant_data_size(a0),a0	; Next monster
	dbra	d7,.Loop
.Exit:	rts

;*****************************************************************************
; [ Heal all party members ]
;*****************************************************************************
Heal_party_members:
	lea.l	Party_handles,a1
	moveq.l	#6-1,d7
.Loop:	tst.b	(a1)			; Anyone there ?
	beq.s	.Next
	Get	(a1),a0
	jsr	De_exhaust
	clr.w	Body_conditions(a0)
	move.w	Life_points+Maximum(a0),d0
	add.w	Life_points+Magic(a0),d0
	move.w	d0,Life_points(a0)
	move.w	Power_points+Maximum(a0),d0
	add.w	Power_points+Magic(a0),d0
	move.w	d0,Power_points(a0)
.Done:	Free	(a1)			; Next party member
.Next:	addq.l	#1,a1
	dbra	d7,.Loop
	rts

;*****************************************************************************
; [ Next travelmode ]
;*****************************************************************************
Next_travelmode:
	move.w	Travel_mode,d0
	addq.w	#1,d0
	cmp.w	#Max_travelmodes,d0
	bmi.s	.Ok
	moveq.l	#0,d0
.Ok:	jsr	Set_new_travel_mode
	rts

;*****************************************************************************
; [ Select music ]
;*****************************************************************************
Select_music:
	Push	Module,MusSelW_Mod		; Select song
	rts

;*****************************************************************************
; [ Toggle event tracer ]
; All registers are restored
;*****************************************************************************
Toggle_event_tracer:
	not.b	Event_tracer		; Toggle
	tst.b	Event_tracer		; On ?
	beq	.Exit
	XX	$f00
	moveq.l	#5,d0
	jsr	Delay
.Exit:	rts

;*****************************************************************************
; [ Print current event ]
; All registers are restored
;*****************************************************************************
Print_current_event:
	tst.b	Event_tracer		; On ?
	beq	.Exit
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Init_diagnostic_screen
	lea.l	Headline,a1		; Print headline
	jsr	DI_Print
	jsr	DI_CR
	jsr	DI_CR
	lea.l	Current_event_data,a5
	lea.l	Eventnr_text,a1		; Print event entry nr.
	jsr	DI_Print
	move.w	Current_event_entry_nr,d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Eventblock_text,a1		; Print event block
	jsr	DI_Print
	move.w	Current_event_block,d0
	jsr	DI_DecW
	jsr	DI_CR
	jsr	DI_CR
	lea.l	Eventb0_text,a1		; "Event type :"
	jsr	DI_Print
	lea.l	Event_name_ptrs,a1		; Print event type
	moveq.l	#0,d0
	move.b	(a5),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	move.l	0(a1,d0.w),a1
	jsr	DI_Print
	jsr	DI_CR
	jsr	DI_CR
	lea.l	Eventb1_text,a1		; Print byte 1
	jsr	DI_Print
	move.b	Event_b1(a5),d0
	jsr	DI_DecB
	jsr	DI_CR
	lea.l	Eventb2_text,a1		; Print byte 2
	jsr	DI_Print
	move.b	Event_b2(a5),d0
	jsr	DI_DecB
	jsr	DI_CR
	lea.l	Eventb3_text,a1		; Print byte 3
	jsr	DI_Print
	move.b	Event_b3(a5),d0
	jsr	DI_DecB
	jsr	DI_CR
	lea.l	Eventb4_text,a1		; Print byte 4
	jsr	DI_Print
	move.b	Event_b4(a5),d0
	jsr	DI_DecB
	jsr	DI_CR
	lea.l	Eventb5_text,a1		; Print byte 5
	jsr	DI_Print
	move.b	Event_b5(a5),d0
	jsr	DI_DecB
	jsr	DI_CR
	lea.l	Eventw6_text,a1		; Print word 6
	jsr	DI_Print
	move.w	Event_w6(a5),d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Eventw8_text,a1		; Print word 8
	jsr	DI_Print
	move.w	Event_w8(a5),d0
	jsr	DI_DecW
	jsr	DI_CR
	lea.l	Eventw10_text,a1		; Print word 10
	jsr	DI_Print
	move.w	Next_event_nr(a5),d0
	jsr	DI_DecW
	jsr	DI_CR
	jsr	Exit_diagnostic_screen
	movem.l	(sp)+,d0-d7/a0-a6
.Exit:	rts

;*****************************************************************************
; [ Show minimap ]
; All registers are restored
;*****************************************************************************
Show_minimap:
	move.l	a0,-(sp)
	Push	Module,Minimap_Mod
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Print modification list ]
; All registers are restored
;*****************************************************************************
Print_modification_list:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Init_diagnostic_screen
	lea.l	Headline2,a1		; Print headline
	jsr	DI_Print
	jsr	DI_CR
	jsr	DI_CR
	lea.l	Modifications,a5		; Do
.Again:	tst.w	(a5)			; End of list ?
	beq	.Done
	move.w	Modif_map_nr(a5),d0		; Print map number
	jsr	DI_DecW
	move.b	Modif_X(a5),d0		; Print X-coordinate
	jsr	DI_DecB
	move.b	Modif_Y(a5),d0		; Print Y-coordinate
	jsr	DI_DecB
	move.w	Modif_icon(a5),d0		; Print icon number
	jsr	DI_DecW
	jsr	DI_CR
.Next:	addq.l	#Modif_data_size,a5		; Next modification
	bra	.Again
.Done:	jsr	Exit_diagnostic_screen
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Examine all monsters ]
;*****************************************************************************
Examine_all_monsters:
	jsr	Get_module_ID		; In combat screen ?
	cmp.b	#Combat_ID,d0
	bne	.Exit
	lea.l	Combat_monsters,a1
	move.w	Nr_monsters,d7
	subq.w	#1,d7
.Loop:	Get	Part_handle(a1),a0		; Able to fight ?
	move.w	Body_conditions(a0),d0
	Free	Part_handle(a1)
	and.w	#Fight_mask,d0
	bne.s	.Next
	move.l	a1,MonKnow_ptr		; Yes -> Examine
	Push	Module,MonKnow_Mod
.Next:	lea.l	Participant_data_size(a1),a1	; Next monster
	dbra	d7,.Loop
.Exit:	rts

;*****************************************************************************
; [ Test weight of active character ]
;*****************************************************************************
Test_active_weight:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Init_diagnostic_screen
	Get	Active_handle,a0
	lea.l	Stored_weight_text,a1	; Print stored weight
	jsr	DI_Print
	move.l	Weight_normal(a0),d0
	jsr	DI_DecL
	jsr	DI_CR
	lea.l	Char_inventory(a0),a1	; Calculate weight of items
	moveq.l	#0,d0
	moveq.l	#Items_per_char+9-1,d7
.Loop:	move.w	Object_index(a1),d1		; Anything there ?
	beq.s	.Next
	subq.w	#1,d1			; Yes -> Get data
	mulu.w	#Item_data_size,d1
	lea.l	Object_data+4,a2
	add.l	d1,a2
	move.w	Weight(a2),d1		; Get weight
	moveq.l	#0,d2			; Get quantity
	move.b	Quantity(a1),d2
	mulu.w	d2,d1			; Add weight
	add.l	d1,d0
.Next:	lea.l	Object_packet_size(a1),a1
	dbra	d7,.Loop
	move.w	Gold_coins(a0),d1		; Add weight of gold
	mulu.w	#Gold_weight,d1
	add.l	d1,d0
	move.w	Food_rations(a0),d1		; Add weight of food
	mulu.w	#Food_weight,d1
	add.l	d1,d0
	move.l	d0,Weight_normal(a0)	; Repair weight
	lea.l	Calc_weight_text,a1		; Print calculated weight
	jsr	DI_Print
	jsr	DI_DecL
	jsr	DI_CR
	jsr	Exit_diagnostic_screen
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Print diagnostic numbers ]
; All registers are restored
;*****************************************************************************
Print_diagnostic_numbers:
	tst.b	Event_tracer		; On ?
	beq	.Exit
	movem.l	d0-d4/d7/a0,-(sp)
	moveq.l	#0,d0			; Clear area
	moveq.l	#0,d1
	moveq.l	#35,d2
	moveq.l	#28,d3
	moveq.l	#0,d4
	jsr	Draw_box
	lea.l	Number,a0			; Convert number
	move.w	goo1,d0
	moveq.l	#5,d7
	jsr	DecL_convert
	lea.l	Number,a0			; Print number
	moveq.l	#0,d0
	moveq.l	#0,d1
	jsr	Put_text_line
	lea.l	Number,a0			; Convert number
	move.w	goo2,d0
	jsr	DecL_convert
	lea.l	Number,a0			; Print number
	moveq.l	#0,d0
	moveq.l	#7,d1
	jsr	Put_text_line
	lea.l	Number,a0			; Convert number
	move.w	goo3,d0
	jsr	DecL_convert
	lea.l	Number,a0			; Print number
	moveq.l	#0,d0
	moveq.l	#14,d1
	jsr	Put_text_line
	lea.l	Number,a0			; Convert number
	move.w	goo4,d0
	jsr	DecL_convert
	lea.l	Number,a0			; Print number
	moveq.l	#0,d0
	moveq.l	#21,d1
	jsr	Put_text_line
	movem.l	(sp)+,d0-d4/d7/a0
.Exit:	rts

;***************************************************************************	
; The DATA & BSS segments
;***************************************************************************	
	SECTION	Fast_DATA,data
Event_name_ptrs:
	dc.l .N1,.N2,.N3,.N4
	dc.l .N5,.N6,.N7,.N8
	dc.l .N9,.N10,.N11,.N12
	dc.l .N13,.N14,.N15,.N16
	dc.l .N17,.N18,.N19,.N20
	dc.l .N21,.N22,.N23,.N24

.N1:	dc.b "Map exit",0
.N2:	dc.b "Door",0
.N3:	dc.b "Item found",0
.N4:	dc.b "Show pic+txt",0
.N5:	dc.b "Spinner",0
.N6:	dc.b "Trap",0
.N7:	dc.b "Anti magic",0
.N8:	dc.b "Riddlemouth",0
.N9:	dc.b "Datachange",0
.N10:	dc.b "Change icon",0
.N11:	dc.b "Encounter",0
.N12:	dc.b "Place",0
.N13:	dc.b "Query",0
.N14:	dc.b "Modify",0
.N15:	dc.b "Chance",0
.N16:	dc.b "Dialogue action",0
.N17:	dc.b "Dialogue text",0
.N18:	dc.b "Dialogue give",0
.N19:	dc.b "Requester",0
.N20:	dc.b "Sound",0
.N21:	dc.b "Dialogue end",0
.N22:	dc.b "Create transport",0
.N23:	dc.b "Dialogue execute",0
.N24:	dc.b "Remove party member",0

Map_nr_text:	dc.b "    Map number : ",0
Map_X_text:	dc.b "  X-coordinate : ",0
Map_Y_text:	dc.b "  Y-coordinate : ",0
Map_view_text:	dc.b "View direction : ",0
Travel_mode_text:	dc.b "   Travel mode : ",0
Groups_3D_text:	dc.b " Object groups : ",0
Objects_3D_text:	dc.b "       Objects : ",0
Walls_3D_text:	dc.b "         Walls : ",0

Headline:	dc.b "    *** Current event data ***",0
Headline2:	dc.b "  Map   X   Y  Icon",0

Eventnr_text:	dc.b "Entry number :",0
Eventblock_text:	dc.b " Event block :",0

Eventb0_text:	dc.b "Event type : ",0
Eventb1_text:	dc.b "Byte 1 : ",0
Eventb2_text:	dc.b "Byte 2 : ",0
Eventb3_text:	dc.b "Byte 3 : ",0
Eventb4_text:	dc.b "Byte 4 : ",0
Eventb5_text:	dc.b "Byte 5 : ",0
Eventw6_text:	dc.b "Word 6 : ",0
Eventw8_text:	dc.b "Word 8 : ",0
Eventw10_text:	dc.b "Next event :",0

Stored_weight_text:	dc.b "    Stored weight :",0
Calc_weight_text:	dc.b "Calculated weight :",0

Event_tracer:	dc.b 0
	even

goo1:	dc.w 0				; Diagnostic numbers
goo2:	dc.w 0
goo3:	dc.w 0
goo4:	dc.w 0

Diagnostics_list2:
	dc.b "t"
	even
	dc.l Jump_to_map
	dc.b "z"
	even
	dc.l Toggle_Superchicken
	dc.b "i"
	even
	dc.l Main_status
	dc.b "o"
	even
	dc.l Kill_all_monsters
	dc.b "p"
	even
	dc.l Heal_party_members
	dc.b "a"
	even
	dc.l Next_travelmode
	dc.b "s"
	even
	dc.l Select_music
	dc.b "d"
	even
	dc.l Toggle_event_tracer
	dc.b "f"
	even
	dc.l Show_minimap
	dc.b "j"
	even
	dc.l Print_modification_list
	dc.b "k"
	even
	dc.l Examine_all_monsters
	dc.b "y"
	even
	dc.l Test_active_weight
	dc.w 0

	else
Diagnostics_list2:
	dc.w 0
	endc
