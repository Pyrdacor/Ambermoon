; Events
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
; [ Handle events at player's current location ]
; All registers are restored
;*****************************************************************************
Event_handler:
	movem.l	d0/d1,-(sp)
	sf	Map_or_dialogue		; Map
	move.w	Travel_mode,d0		; Correct travel-mode ?
	move.w	#Event_mask,d1
	btst	d0,d1
	beq	.Exit
	move.w	Map_Xcoord,d0		; Get player's coordinates
	move.w	Map_Ycoord,d1
	jsr	Find_event		; Find event
	bmi.s	.Exit			; Any there ?
	jsr	Check_event_save_status	; Already saved ?
	bne.s	.Exit
	jsr	Handle_event_chain		; Handle
.Exit:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Handle chain of events ]
; All registers are restored
;*****************************************************************************
Handle_event_chain:
	sf	Success
	st	Handling_event
.Again:	sf	Break_event		; Handle event
	jsr	Handle_event
	tst.b	Break_event		; Break ?
	bne.s	.Exit
	jsr	Chain_to_next_event		; Next event
	bpl.s	.Again			; Last ?
.Exit:	sf	Success
	sf	Handling_event
	tst.b	Faded_flag
	bne.s	.Leave
	jsr	Init_display
.Leave:	rts

;*****************************************************************************
; [ Handle events in dialogue ]
;   IN : d0 - Dialogue action number (.w)
;        d1 - Value for dialogue action event (.w)
;  OUT : pl - An event was found
;        mi - No event was found
; All registers are restored
;*****************************************************************************
DIA_event_handler:
	movem.l	d0,-(sp)
	st	Map_or_dialogue		; Dialogue
	jsr	Find_DIA_event		; Find event
	bmi.s	.Exit			; Any there ?
	jsr	Handle_DIA_event_chain	; Handle
	moveq.l	#1,d0			; Positive !
.Exit:	movem.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Handle chain of events in dialogue ]
; All registers are restored
;*****************************************************************************
Handle_DIA_event_chain:
	sf	Success
	st	Handling_event
.Again:	jsr	Handle_DIA_event		; Handle event
	tst.b	Break_event		; Break ?
	bne.s	.Exit
	jsr	Chain_to_next_event		; Next event
	bpl.s	.Again			; Last ?
.Exit:	sf	Success
	sf	Handling_event
	tst.b	Faded_flag
	bne.s	.Leave
	jsr	Init_display
.Leave:	rts

;*****************************************************************************
; [ Check if current event has been saved ]
;  OUT : eq - Not saved
;        ne - Saved
; All registers are restored
;*****************************************************************************
Check_event_save_status:
	movem.l	d0-d2,-(sp)
	move.w	Current_event_entry_nr,d0	; Calculate bit number
	move.w	Current_event_map_nr,d1
	subq.w	#1,d1
	mulu.w	#Events_per_map,d1
	add.w	d1,d0
	subq.w	#1,d0
	moveq.l	#Event_bit_array,d1		; Get bit
	moveq.l	#3,d2
	jsr	Access_bit_array
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Save current event ]
; All registers are restored
;*****************************************************************************
Save_event:
	movem.l	d0-d2,-(sp)
	move.b	Current_event_data,d0	; Get current event type
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

;*****************************************************************************
; [ Get first event in chain ]
;   IN : d0 - Event number {1...255} (.b)
; All registers are restored
; Notes :
;  - This routine uses [ Current_event_handle ].
;    It sets [ Current_event_base ] and [ Current_event_data ].
;*****************************************************************************
Get_first_event:
	movem.l	d0-d2/a0/a1,-(sp)
	andi.w	#$00ff,d0			; Mask off rubbish
	Get	Current_event_handle,a0	; Get map data
	cmp.b	#World_2D,Current_map_type	; 2D world map ?
	bne	.No_world
; ---------- 2D world map -------------------------
	move.w	d0,d2			; Save
	moveq.l	#0,d0			; Skip map layers
	move.w	Size_of_map,d0
	lsl.l	#2,d0
	addi.l	#Map_data,d0
	lea.l	0(a0,d0.l),a1		; Get number of entries
	moveq.l	#0,d1
	move.w	(a1)+,d1
	add.l	d1,d1			; Skip event entry list
	add.l	d1,d0
	addq.l	#4,d0			; Skip number of events
	move.l	d0,Current_event_base	; Store event base
	add.l	d0,a0
	add.w	d2,d2			; Get first event number
	moveq.l	#0,d1
	move.w	-2(a1,d2.w),d1
	bra.s	.Do
; ---------- Other maps ---------------------------
.No_world:	add.w	d0,d0			; Get first event number
	ext.l	d0
	add.l	Event_entry_offset,d0
	moveq.l	#0,d1
	move.w	-2(a0,d0.l),d1
	move.l	Event_data_offset,d0	; Get event offset
	move.l	d0,Current_event_base	; Store event base
	add.l	d0,a0
; ---------- Set event data -----------------------
.Do:	move.w	d1,Current_event_block	; Store event block
	mulu.w	#Event_data_size,d1		; Copy event data
	add.l	d1,a0
	lea.l	Current_event_data,a1
	moveq.l	#(Event_data_size/2)-1,d0
.Loop:	move.w	(a0)+,(a1)+
	dbra	d0,.Loop
.Exit:	Free	Current_event_handle
	movem.l	(sp)+,d0-d2/a0/a1
	rts

;*****************************************************************************
; [ Chain to next event ]
; OUT : pl - Next event
;       mi - No next event
; All registers are restored
; Notes :
;  - This routine re-sets [ Current_event_data ].
;*****************************************************************************
Chain_to_next_event:
	movem.l	d0/d7/a0/a1,-(sp)
	move.w	Current_event_data+Next_event_nr,d0	; Get next event block
	move.w	Current_event_block,d7	; Get current event block
	move.w	d0,Current_event_block	; Store
	cmpi.w	#-1,d0			; Last in chain ?
	bne.s	.No1
	moveq.l	#-1,d0			; Force mi
	bra.s	.Exit
.No1:	cmp.w	d0,d7			; Endless loop ?
	bne.s	.No2
	move.l	#ENDLESS_EVENT,Return_value	; Yes -> Exit
	jmp	Exit_program
.No2:	mulu.w	#Event_data_size,d0		; Set data offset
	add.l	Current_event_base,d0
	Get	Current_event_handle,a0	; Copy event data
	add.l	d0,a0
	lea.l	Current_event_data,a1
	moveq.l	#(Event_data_size/2)-1,d7
.Loop:	move.w	(a0)+,(a1)+
	dbra	d7,.Loop
	Free	Current_event_handle
	moveq.l	#0,d0			; Force pl
.Exit:	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Find map event ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : pl - Event
;        mi - No event
; All registers are restored
; Notes :
;   - In 2D wilderness, the coordinates may fall outside the map, but	must
;     refer to the current map. They may not fall outside the quad-map !
;   - This routine initializes
;      [ Current_event_data ],
;      [ Current_event_map_nr ],
;      [ Current_event_handle ],
;      [ Current_event_text_handle ],
;      [ Current_event_entry_nr ] and
;      [ Current_event_base ].
;   - It calls [ Get_first_event ] !
;*****************************************************************************
Find_event:
	movem.l	d0-d7/a0/a1,-(sp)
	move.w	d0,d4			; Save coordinates
	move.w	d1,d5
	cmpi.b	#World_2D,Current_map_type	; 2D wilderness ?
	beq	.2D_wild
	move.w	Map_nr,Current_event_map_nr	; Default
; ---------- Check for NPC events -----------------
	lea.l	VNPC_data,a0
	moveq.l	#0,d0
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq.s	.Next
	btst	d7,d6			; Deleted ?
	bne.s	.Next
	cmp.w	VMap_X(a0),d4		; Right coordinates ?
	bne.s	.Next
	cmp.w	VMap_Y(a0),d5
	bne.s	.Next
	move.b	NPC_event_nr(a0),d0		; Get event
	beq	.End			; Any ?
	move.b	Mapdata_handle,Current_event_handle
	move.b	Maptext_handle,Current_event_text_handle
	bra	.Event
.Next:	lea.l	VNPC_data_size(a0),a0	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi.s	.Loop
.End:	move.b	Mapdata_handle,d2		; Get normal map handle
	move.b	Maptext_handle,d3
	bra	.Go_on
; ---------- Get 2D wilderness map handle ---------
.2D_wild:	move.w	Quad_index,d2		; Get quad index
	cmp.w	#1,d0			; Out of range left ?
	bpl.s	.Left_OK
	bclr	#0,d2			; Map to the left
	add.w	Submap_width,d4
	bra.s	.Check_Y
.Left_OK:	cmp.w	Submap_width,d0		; Out of range right ?
	bls.s	.Check_Y
	bset	#0,d2			; Map to the right
	sub.w	Submap_width,d4
.Check_Y:	cmp.w	#1,d1			; Out of range top ?
	bpl.s	.Top_OK
	bclr	#1,d2			; Map to the top
	add.w	Submap_height,d5
	bra.s	.Done
.Top_OK:	cmp.w	Submap_height,d1		; Out of range top ?
	bls.s	.Done
	bset	#1,d2			; Map to the top
	sub.w	Submap_height,d5
.Done:	lea.l	Quad_map,a1		; Get map handle
	mulu.w	#Quad_mapsize,d2
	adda.w	d2,a1
	move.b	Quad_map_handle(a1),d2
	move.b	Quad_maptext_handle(a1),d3
	move.w	Quad_mapnr(a1),Current_event_map_nr
; ---------- Get event data -----------------------
.Go_on:	move.b	d2,Current_event_handle	; Store
	move.b	d3,Current_event_text_handle
	move.w	d4,Current_event_X
	move.w	d5,Current_event_Y
	subq.w	#1,d4			; Correction
	subq.w	#1,d5
	cmp.w	Width_of_map,d4		; Inside map ?
	bhi	.Exit
	cmp.w	Height_of_map,d5
	bhi	.Exit
	mulu.w	Width_of_map,d5		; Calculate map offset
	add.w	d4,d5
	add.w	d5,d5
	cmpi.b	#Map_3D,Current_map_type	; 2D map ?
	bpl.s	.No
	add.w	d5,d5			; Yes -> 4 bytes
.No:	Get	d2,a0			; Get event number
	lea.l	Map_data(a0),a0
	moveq.l	#0,d0
	move.b	1(a0,d5.w),d0
	Free	d2
	tst.w	d0			; Any ?
	bne	.Event
	moveq.l	#-1,d0			; Force mi
	bra	.Exit
.Event:	move.w	d0,Current_event_entry_nr	; Store
	jsr	Get_first_event		; Get event offset
	moveq.l	#0,d0			; Force pl
.Exit:	movem.l	(sp)+,d0-d7/a0/a1
	rts

;*****************************************************************************
; [ Find dialogue event ]
;   IN : d0 - Dialogue action number (.w)
;        d1 - Value for dialogue action event (.w)
;  OUT : pl - Event
;        mi - No event
; All registers are restored
; Notes :
;   - This routine initializes
;      [ Current_event_data ],
;      [ Current_event_map_nr ],
;      [ Current_event_handle ],
;      [ Current_event_entry_nr ] and
;      [ Current_event_base ].
;*****************************************************************************
Find_DIA_event:
	movem.l	d0-d2/d6/d7/a0-a2,-(sp)
	move.w	d0,Current_DIAC		; Store input
	move.w	d1,Current_DIAC_value
	move.b	Active_handle,DIAC_victim_handle
	moveq.l	#-1,d7			; Default is no event
	Get	Dialogue_handle,a0		; Get dialogue data
	move.l	a0,d2
	move.l	d0,-(sp)
	jsr	Get_dialogue_offset
	add.l	d0,a0
	move.l	(sp)+,d0
	move.w	(a0)+,d6			; Get number of entries
	beq	.Exit			; Any ?
	move.l	a0,a1			; Get event data
	add.w	d6,a1
	add.w	d6,a1
	addq.l	#2,a1
	sub.l	a1,d2			; Set event base
	neg.l	d2
	move.l	d2,Current_event_base
	subq.w	#1,d6
.Loop1:	move.w	(a0)+,d2			; Get entry number
	move.w	d2,Current_event_block
	mulu.w	#Event_data_size,d2		; Get first event
	move.l	a1,a2
	add.l	d2,a2
	cmp.b	#Dia_action_type,(a2)	; Dialogue action ?
	bne	.Next1
	cmp.b	Event_b1(a2),d0		; Correct action type ?
	bne	.Next1
	jsr	Dia_action		; Correct value ?
	bne	.Next1
	clr.w	Current_event_map_nr	; Yes -> Set event info
	move.w	-2(a0),Current_event_entry_nr
	move.b	Dialogue_handle,Current_event_handle
	lea.l	Current_event_data,a0	; Copy event data
	moveq.l	#(Event_data_size/2)-1,d2
.Loop2:	move.w	(a2)+,(a0)+
	dbra	d2,.Loop2

	ifne	Cheat
	jsr	Print_current_event
	endc

	moveq.l	#1,d7			; Success !
	bra	.Exit
.Next1:	dbra	d6,.Loop1			; Next event chain
.Exit:	Free	Dialogue_handle
	tst.w	d7			; Any luck ?
	movem.l	(sp)+,d0-d2/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Handle map event ]
; All registers are restored
;*****************************************************************************
Handle_event:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#0,d0			; Get current event type
	move.b	Current_event_data,d0
	tst.w	d0			; Legal ?
	beq.s	.Exit
	cmpi.w	#Max_events+1,d0
	bpl.s	.Exit

	ifne	Cheat
	jsr	Print_current_event
	endc

	move.l	#Map_event_mask,d1		; Possible in map ?
	btst	d0,d1
	beq.s	.Exit
	move.l	#Clear_success_mask,d1	; Clear success ?
	btst	d0,d1
	beq.s	.No
	sf	Success			; Yes
.No:	move.l	#Map_break_mask,d1		; Break ?
	btst	d0,d1
	sne	Break_event
	lsl.w	#2,d0			; Execute event
	lea.l	Event_ptrs,a0
	movea.l	-4(a0,d0.w),a0
	jsr	(a0)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Handle dialogue event ]
; All registers are restored
;*****************************************************************************
Handle_DIA_event:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#0,d0			; Get current event type
	move.b	Current_event_data,d0
	tst.w	d0			; Legal ?
	beq.s	.Exit
	cmpi.w	#Max_events+1,d0
	bpl.s	.Exit

	ifne	Cheat
	jsr	Print_current_event
	endc

	move.l	#Dia_event_mask,d1		; Possible in dialogue ?
	btst	d0,d1
	beq.s	.Exit
	move.l	#Clear_success_mask,d1	; Clear success ?
	btst	d0,d1
	beq.s	.No1
	sf	Success			; Yes
.No1:	move.l	#Dia_break_mask,d1		; Break off dialogue ?
	btst	d0,d1
	beq.s	.No2
	st	Abort_dialogue		; Yes -> Abort
	Pop	Module
.No2:	move.l	#Map_break_mask,d1		; Break ?
	btst	d0,d1
	sne	Break_event
	lsl.w	#2,d0			; Execute event
	lea.l	Event_ptrs,a0
	move.l	-4(a0,d0.w),a0
	jsr	(a0)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Map Exit event ]
; No registers are restored
;*****************************************************************************
Map_exit:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get map exit type
	move.b	Event_b5(a5),d0
	lsl.w	#2,d0			; Do map exit
	move.l	.Ptrs(pc,d0.w),a0
	jsr	(a0)
	rts

.Ptrs:	dc.l Normal_MX,Teleport,Windgate,Trapdoor_up
	dc.l End_seq,Trapdoor_down

Normal_MX:
	move.w	Event_w6(a5),d0		; To current map ?
	cmp.w	Map_nr,d0
	beq.s	.Same
	jsr	Exit_map			; No -> Real map exit
	jsr	Do_MX
	move.w	Event_w6(a5),Map_nr
	jsr	Init_map
	jsr	Do_MX2
	bra.s	.Exit
.Same:	jsr	Exit_display		; Yes -> Just jump
	jsr	Do_MX
	jsr	Do_MX2
	jsr	Jumped
	jsr	Init_display
.Exit:	rts

Teleport:
	move.w	Event_w6(a5),d0		; To current map ?
	cmp.w	Map_nr,d0
	bne.s	Normal_MX
	jsr	Do_MX			; Yes -> Just jump
	jsr	Do_MX2
	jsr	Jumped
	jsr	Update_display
	jmp	After_move

Windgate:
	move.w	Special_item_flags,d0	; Got the	windchain	?
	btst	#Windchain_bit,d0
	bne	Normal_MX			; Yes -> normal map exit
	rts

End_seq:
	jsr	Fade_out_all		; Yay!
	lea.l	Member_nrs,a0		; Search party
	moveq.l	#6-1,d7
.Loop:	cmp.w	#Valdyn_code,(a0)+		; Is this Valdyn ?
	beq.s	.Yes
	dbra	d7,.Loop			; No -> Next member
	move.l	#GAME_COMPLETED3,Return_value
	bra.s	.Exit
.Yes:	move.w	Internal_flags,d0		; Yes -> Valdyn has thingy ?
	btst	#Fuck_bit,d0
	beq.s	.No
	move.l	#GAME_COMPLETED2,Return_value	; Yes
	bra.s	.Exit
.No:	move.l	#GAME_COMPLETED,Return_value	; No
.Exit:	jmp	Exit_program

Trapdoor_down:
	cmp.b	#Map_3D,Current_map_type	; In 3D map ?
	bmi.s	.No
	jsr	Update_screen		; Yes -> Going down !
	moveq.l	#-2,d0
	moveq.l	#-2,d1
	move.w	#-wall_height+16,d2
.Again:	cmp.w	d0,d2			; Too low ?
	bge.s	.Done
	move.w	d0,FX_camera_height		; Set new height
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	add.w	d1,d0			; Move down
	subq.w	#2,d1			; Faster
	bra.s	.Again
.Done:	jsr	Copy_screen
	st	Float_down
.No:	jmp	Normal_MX			; Normal map exit

Trapdoor_up:
	cmp.b	#Map_3D,Current_map_type	; In 3D map ?
	bmi.s	.No
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
.No:	jmp	Normal_MX			; Normal map exit

Do_MX:	moveq.l	#0,d0			; Get new coordinates
	move.b	Event_b1(a5),d0
	moveq.l	#0,d1
	move.b	Event_b2(a5),d1
	tst.w	d0			; Keep old coordinates ?
	bne.s	.Change
	tst.w	d1
	beq.s	.Keep1
.Change:	move.w	d0,Map_Xcoord		; Set new coordinates
	move.w	d1,Map_Ycoord
.Keep1:	move.b	Event_b3(a5),d0		; Get new view direction ?
	cmp.w	#4,d0			; Keep old view direction ?
	beq.s	.Keep2
	move.w	d0,View_direction		; No -> Set new
.Keep2:	rts

Do_MX2:	move.b	Event_b4(a5),d0		; Keep old travelmode ?
	bmi.s	.Keep
	jsr	Set_new_travel_mode		; No -> Set new
.Keep:	rts

;*****************************************************************************
; [ Door event ]
; No registers are restored
;*****************************************************************************
Door:
	moveq.l	#0,d0			; Already open ?
	move.b	Current_event_data+Event_b2,d0
	moveq.l	#Door_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	bne.s	.Exit
	jsr	Exit_display		; Do door
	Push	Module,Door_Mod
.Exit:	rts

Door_ModInit:
	sf	Trap_found		; Clear flags
	sf	Trap_disarmed
	moveq.l	#Door_pic,d0		; Load picture
	jsr	Load_80x80_picture
	jsr	Load_object_graphics
	jsr	Door_DisInit		; Build screen
	moveq.l	#0,d0			; Get text block number
	move.b	Current_event_data+Event_b3,d0
	cmp.b	#-1,d0			; Any text ?
	beq.s	.Exit
	Get	Current_event_text_handle,a0	; Display text
	jsr	Do_text
	Free	Current_event_text_handle
.Exit:	rts

Door_ModExit:
	jsr	Free_object_graphics	; Free memory
	move.b	Pic_80x80_handle,d0
	jmp	Free_memory

Door_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	jsr	Display_80x80_picture	; Show picture
	lea.l	Door_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide objects
	jmp	Fade_in_bottom

Door_CIL_evaluate:
	Get	Active_handle,a1
; ---------- Any items in backpack ? --------------
	jsr	Check_active_backpack	; Well ?
	bne.s	.Not_empty
	bset	#7,2(a0)			; Disable {Use item}
; ---------- Any trap found yet ? -----------------
.Not_empty:
	tst.b	Trap_found
	beq.s	.Not_found
	bset	#7,6(a0)			; Disable {Find trap}
	bra.s	.Continue
.Not_found:
	bset	#7,12(a0)			; Disable {Disarm trap}
	bra.s	.Ok
; ---------- Trap disarmed yet ? ------------------
.Continue:	tst.b	Trap_disarmed
	beq.s	.Ok
	bset	#7,12(a0)			; Disable {Disarm trap}
; ---------- Active character blind ? -------------
.Ok:	move.w	Body_conditions(a1),d0
	btst	#Blind,d0
	beq.s	.Exit
	bset	#7,6(a0)			; Disable {Find trap}
	bset	#7,12(a0)			; Disable {Disarm trap}
.Exit:	Free	Active_handle
	rts

; ********** Door screen - Exit *******************
Door_Exit:          
	jsr	Restore_coordinates
	jmp	Basic_exit

; ********** Door screen - Pick lock **************
Pick_lock_DOOR:
	Get	Active_handle,a0
	lea.l	Current_event_data,a5
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq	.Opened_it
	moveq.l	#0,d0			; Get locked percentage
	move.b	Event_b1(a5),d0
	cmpi.w	#100,d0			; Door fully locked ?
	beq.s	.No_luck
	neg.w	d0			; Probe {Find traps}
	add.w	SPick_locks(a0),d0
	add.w	SPick_locks+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.Opened_it
	tst.b	Trap_disarmed		; Trap already disarmed ?
	beq	.Trap
.No_luck:
	Free	Active_handle
	moveq.l	#76,d0			; No luck !
	jsr	Do_prompt
	bra	.Exit
.Trap:
	cmp.w	#-1,Event_w8(a5)		; Any trap ?
	beq.s	.No_luck
	move.w	ADexterity(a0),d0		; Probe {Dexterity}
	add.w	ADexterity+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.No_trap
	move.w	Event_w8(a5),Next_event_nr(a5)	; Negative chain
	Free	Active_handle
	jsr	Door_Exit			; Exit
	bra	.Exit
.No_trap:
	Free	Active_handle
	moveq.l	#69,d0			; The trap failed
	jsr	Do_prompt
	bra	.Exit
.Opened_it:
	Free	Active_handle		; Opened the door ! Yay !
	moveq.l	#68,d0
	jsr	Door_opened
.Exit:	rts

; ********** Door screen - Use item ***************
Use_item_DOOR:
	clr.w	Scroll_bar_work		; Clear
.Repeat:	move.w	#77,ItemSelect_prompt	; Select item
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
	add.l	Slotbase_offset,a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	move.w	d0,d1
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a0
	add.l	d0,a0
	Free	Active_handle
	lea.l	Current_event_data,a5	; Get event data
	cmp.w	Event_w6(a5),d1		; Right item ?
	bne	.Wrong1
; ---------- Right item ---------------------------
	btst	#Destroy_after_use,Item_bits_STATIC(a0)	; Use once ?
	beq.s	.Use_more
	move.w	#Doorlock_X-8,d0		; Show key destruction
	move.w	#Doorlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#70,d3
	jsr	Key_is_destroyed
	move.b	Active_handle,d0		; Remove item
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	bra.s	.Go_on
.Use_more:	move.w	#Doorlock_X-8,d0		; Show key's effect
	move.w	#Doorlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#70,d3
	jsr	Key_is_not_destroyed
.Go_on:	jsr	Hide_Lay3_objects		; Hide
	jsr	Update_screen
	moveq.l	#-1,d0			; Yay! Did it!
	jsr	Door_opened
	bra	.Exit2
; ---------- Wrong item - maybe lockpick ----------
.Wrong1:	cmpi.b	#6,Spell_class(a0)		; Special magical object ?
	bne	.Wrong2
	cmpi.b	#1,Spell_number(a0)
	bne	.Wrong2
	cmpi.b	#100,Event_b1(a5)		; Fully locked ?
	bmi.s	.Works
	move.w	#Doorlock_X-8,d0		; Show lockpick destruction
	move.w	#Doorlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#75,d3
	jsr	Lockpick_breaks
	move.b	Active_handle,d0		; Remove item
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	bra	.Done
.Works:	move.w	#Doorlock_X-8,d0		; Show lockpick's effect
	move.w	#Doorlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#74,d3
	jsr	Lockpick_works
	move.b	Active_handle,d0		; Remove item
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	jsr	Hide_Lay3_objects		; Hide
	jsr	Update_screen
	moveq.l	#-1,d0			; Yay! Did it!
	jsr	Door_opened
	bra.s	.Exit2
; ---------- Wrong item - not lockpick ------------
.Wrong2:	move.w	#Doorlock_X-8,d0		; Wrong item
	move.w	#Doorlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#82,d3
	jsr	Key_does_not_fit
.Done:	bra	.Repeat			; Next!
.Exit:	jsr	Hide_Lay3_objects		; Hide
	jsr	Update_screen
.Exit2:	rts

; ********** Door screen - Find trap **************
Find_trap_DOOR:
	Get	Active_handle,a0
	cmp.w	#-1,Current_event_data+Event_w8	; Any trap ?
	beq.s	.No_find
	move.w	SFind_traps(a0),d0		; Probe {Find traps}
	add.w	SFind_traps+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.Found_it
.No_find:	moveq.l	#72,d0			; No traps, guv'
	bra.s	.Go_on
.Found_it:	st	Trap_found		; Found it! Yay!
	moveq.l	#71,d0
.Go_on:	Free	Active_handle
	jsr	Do_prompt
	rts

; ********** Door screen - Disarm trap ************
Disarm_trap_DOOR:
	Get	Active_handle,a0
	move.w	SDisarm_traps(a0),d0	; Probe {Disarm traps}
	add.w	SDisarm_traps+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.Disarmed_it
	move.w	ADexterity(a0),d0		; Probe {Dexterity}
	add.w	ADexterity+Magic(a0),d0
	jsr	Probe_100
	bmi.s	.Trapped
	moveq.l	#69,d0			; The trap failed
	bra.s	.Go_on
.Trapped:	move.w	Event_w8(a5),Next_event_nr(a5)	; Negative chain
	Free	Active_handle
	jsr	Door_Exit			; Exit
	bra.s	.Exit
.Disarmed_it:
	st	Trap_disarmed		; Disarmed it! Yay!
	moveq.l	#73,d0
.Go_on:	Free	Active_handle
	jsr	Do_prompt
.Exit:	rts

;*****************************************************************************
; [ Door was opened ]
;   IN : d0 - Prompt number when no text is given (.w)
; No registers are restored
;*****************************************************************************
Door_opened:
	lea.l	Current_event_data,a5
	moveq.l	#0,d1			; Get text block number
	move.b	Event_b4(a5),d1
	cmp.b	#-1,d1			; Any text ?
	beq.s	.None
	move.w	d1,d0			; Display text
	Get	Current_event_text_handle,a0
	jsr	Do_text
	Free	Current_event_text_handle
	bra.s	.Go_on
.None:	tst.w	d0			; Any prompt ?
	bmi.s	.Go_on
	jsr	Do_prompt			; Standard text
.Go_on:	moveq.l	#0,d0			; Save
	move.b	Event_b2(a5),d0
	moveq.l	#Door_bit_array,d1
	moveq.l	#1,d2
	jsr	Access_bit_array
	st	Success			; Success !
	jmp	Basic_exit		; Exit

;*****************************************************************************
; [ Item Found event ]
; No registers are restored
;*****************************************************************************
Item_found:
	lea.l	Current_event_data,a5
; ---------- Is the chest hidden ? ----------------
	tst.b	Event_b2(a5)		; Is it ?
	beq.s	.Not
	tst.b	Clairvoyant		; Clairvoyant ?
	bne.s	.Not
	Get	Active_handle,a0		; Probe {Searching}
	move.w	SSearch(a0),d0
	add.w	SSearch+Magic(a0),d0
	Free	Active_handle
	jsr	Probe_100
	bmi	.Exit
; ---------- Is it a chest or a trashpile ? -------
.Not:	btst	#0,Event_b5(a5)
	bne	.Open
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
.Closed:	jsr	Exit_display
	Push	Module,ClosedChest_Mod
	bra	.Exit
; ---------- Opened chest -------------------------
.Open:	jsr	Exit_display
	Push	Module,OpenedChest_Mod
.Exit:	rts

;*****************************************************************************
; [ Closed Chest module ]
;*****************************************************************************
ClosedChest_ModInit:
	sf	Trap_found		; Clear flags
	sf	Trap_disarmed
	moveq.l	#Closed_chest_pic,d0	; Load picture
	jsr	Load_80x80_picture
	jsr	Load_object_graphics
	jmp	ClosedChest_DisInit

ClosedChest_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	jsr	Display_80x80_picture	; Show picture
	lea.l	ClosedChest_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide objects
	jmp	Fade_in_bottom

; ********** Chest screen - Pick lock *************
Pick_lock_CHEST:
	Get	Active_handle,a0
	lea.l	Current_event_data,a5
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq	.Opened_it
	moveq.l	#0,d0			; Get locked percentage
	move.b	Event_b1(a5),d0
	cmpi.w	#100,d0			; Door fully locked ?
	beq.s	.No_luck
	neg.w	d0			; Probe {Find traps}
	add.w	SPick_locks(a0),d0
	add.w	SPick_locks+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.Opened_it
; Increase locked percentage ?
	tst.b	Trap_disarmed		; Trap already disarmed ?
	beq	.Trap
.No_luck:
	Free	Active_handle
	moveq.l	#76,d0			; No luck !
	jsr	Do_prompt
	bra	.Exit
.Trap:
	cmp.w	#-1,Event_w8(a5)		; Any trap ?
	beq.s	.No_luck
	move.w	ADexterity(a0),d0		; Probe {Dexterity}
	add.w	ADexterity+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.No_trap
	move.w	Event_w8(a5),Next_event_nr(a5)	; Negative chain
	Free	Active_handle
	jsr	Door_Exit			; Exit
	bra	.Exit
.No_trap:
	Free	Active_handle
	moveq.l	#69,d0			; The trap failed
	jsr	Do_prompt
	bra	.Exit
.Opened_it:
	Free	Active_handle		; Opened the chest ! Yay !
	moveq.l	#80,d0
	jsr	Chest_opened
.Exit:	rts

; ********** Chest screen - Use item **************
Use_item_CHEST:
	clr.w	Scroll_bar_work		; Clear
.Repeat:	move.w	#78,ItemSelect_prompt	; Select item
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
	add.l	Slotbase_offset,a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object data address
	move.w	d0,d1
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a0
	add.l	d0,a0
	Free	Active_handle
	lea.l	Current_event_data,a5	; Get event data
	cmp.w	Event_w6(a5),d1		; Right item ?
	bne	.Wrong1
; ---------- Right item ---------------------------
	btst	#Destroy_after_use,Item_bits_STATIC(a0)	; Use once ?
	beq.s	.Use_more
	move.w	#Chestlock_X-8,d0		; Show key destruction
	move.w	#Chestlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#79,d3
	jsr	Key_is_destroyed
	move.b	Active_handle,d0		; Remove item
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	bra.s	.Go_on
.Use_more:	move.w	#Chestlock_X-8,d0		; Show key's effect
	move.w	#Chestlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#79,d3
	jsr	Key_is_not_destroyed
.Go_on:	jsr	Hide_Lay3_objects		; Hide
	jsr	Update_screen
	moveq.l	#-1,d0			; Yay! Did it!
	jsr	Chest_opened
	bra	.Exit2
; ---------- Wrong item - maybe lockpick ----------
.Wrong1:	cmpi.b	#6,Spell_class(a0)		; Special magical object ?
	bne	.Wrong2
	cmpi.b	#1,Spell_number(a0)
	bne	.Wrong2
	cmpi.b	#100,Event_b1(a5)		; Fully locked ?
	bmi.s	.Works
	move.w	#Chestlock_X-8,d0		; Show lockpick destruction
	move.w	#Chestlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#75,d3
	jsr	Lockpick_breaks
	move.b	Active_handle,d0		; Remove item
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	bra.s	.Done
.Works:	move.w	#Chestlock_X-8,d0		; Show lockpick's effect
	move.w	#Chestlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#81,d3
	jsr	Lockpick_works
	move.b	Active_handle,d0		; Remove item
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	jsr	Hide_Lay3_objects		; Hide
	jsr	Update_screen
	moveq.l	#-1,d0			; Yay! Did it!
	jsr	Chest_opened
	bra.s	.Exit2
; ---------- Wrong item - not lockpick ------------
.Wrong2:	move.w	#Chestlock_X-8,d0		; Wrong item
	move.w	#Chestlock_Y-8,d1
	move.w	Selected_item,d2
	addq.w	#1,d2
	moveq.l	#83,d3
	jsr	Key_does_not_fit
.Done:	bra	.Repeat			; Next!
.Exit:	jsr	Hide_Lay3_objects		; Hide
	jsr	Update_screen
.Exit2:	rts

;*****************************************************************************
; [ Chest was opened ]
;   IN : d0 - Prompt number (.w)
; No registers are restored
;*****************************************************************************
Chest_opened:
	lea.l	Current_event_data,a5
	tst.w	d0			; Any prompt ?
	bmi.s	.Skip
	jsr	Do_prompt			; Show text
.Skip:	moveq.l	#0,d0			; Save
	move.b	Event_b4(a5),d0
	moveq.l	#Chest_bit_array,d1
	moveq.l	#1,d2
	jsr	Access_bit_array
	st	Success			; Success !
	Pop	Module			; Open the chest
	st	First_chest
	Push	Module,OpenedChest_Mod
	sf	First_chest
	rts

;*****************************************************************************
; [ Opened Chest module ]
;*****************************************************************************
OpenedChest_ModInit:
	sf	Trap_found		; Clear flags
	sf	Trap_disarmed
	sf	Chest_text_printed
	lea.l	Current_event_data,a5
; ---------- Load data & evaluate chest -----------
	moveq.l	#0,d0			; Load chest data
	move.b	Event_b4(a5),d0
	addq.w	#1,d0			; !!!
	moveq.l	#Chest_data_file,d1
	jsr	Load_subfile
	move.b	d0,Chest_data_handle
	Get	Chest_data_handle,a0	; Look in chest
	moveq.l	#-1,d0
	tst.w	Chest_gold(a0)		; Maybe gold or food ?
	bne.s	.Done
	tst.w	Chest_food(a0)
	bne.s	.Done
	moveq.l	#Items_per_chest-1,d7	; No
.Loop:	tst.w	Object_index(a0)		; Anything there ?
	bne.s	.Done
	addq.w	#Object_packet_size,a0
	dbra	d7,.Loop
	moveq.l	#0,d0			; No
.Done:	Free	Chest_data_handle
	move.b	d0,Chest_filled		; Store
	btst	#0,Event_b5(a5)		; Pile or chest ?
	bne.s	.Pile
	st	Chest_flag		; For Inventory 2
	tst.b	Chest_filled		; Full or empty chest ?
	beq.s	.Empty
	moveq.l	#Opened_chest_pic,d0	; Full
	bra.s	.Go_on
.Empty:	moveq.l	#Empty_chest_pic,d0		; Empty
	bra.s	.Go_on
.Pile:	moveq.l	#Trashpile_pic,d0		; Pile
; ---------- Build screen & display text ----------
.Go_on:	jsr	Load_80x80_picture		; Load picture
	jsr	Load_object_graphics
	jmp	OpenedChest_DisInit		; Build screen

OpenedChest_ModExit:
	sf	Chest_flag		; For Inventory 2
	lea.l	Current_event_data,a5
	btst	#1,Event_b5(a5)		; Write back ?
	bne	.No
	moveq.l	#0,d0			; Yes -> Save chest data
	move.b	Event_b4(a5),d0
	addq.w	#1,d0			; !!!
	moveq.l	#Chest_data_file,d1
	Get	Chest_data_handle,a0
	jsr	Save_subfile
	move.b	Chest_data_handle,d0	; Free memory
	jsr	Free_pointer
	jsr	Free_memory
	bra.s	.Go_on
.No:	move.b	Chest_data_handle,d0	; No -> Kill (!) memory
	jsr	Kill_memory
.Go_on:	move.b	Pic_80x80_handle,d0
	jsr	Free_memory
	jsr	Free_object_graphics
	jmp	Destroy_ghosts		; Kill !

OpenedChest_DisUpd:
; ---------- Show gold & food ---------------------
	Get	Chest_data_handle,a0	; Update gold & food
	move.w	Chest_gold(a0),Current_gold
	move.w	Chest_food(a0),Current_food
	Free	Chest_data_handle
	jsr	Update_gold		; Display
	jsr	Update_food
	jsr	Basic_DisUpd		; The usual
; ---------- Show full or empty chest -------------
	Get	Chest_data_handle,a0	; Look in chest
	lea.l	Current_event_data,a5
	moveq.l	#-1,d0
	tst.w	Chest_gold(a0)		; Maybe gold or food ?
	bne.s	.Done
	tst.w	Chest_food(a0)
	bne.s	.Done
	moveq.l	#Items_per_chest-1,d7	; No
.Loop:	tst.w	Object_index(a0)		; Anything there ?
	bne.s	.Done
	addq.w	#Object_packet_size,a0
	dbra	d7,.Loop
	moveq.l	#0,d0			; No
.Done:	Free	Chest_data_handle
	cmp.b	Chest_filled,d0		; Change ?
	beq.s	.Exit
	move.b	d0,Chest_filled		; Yes -> Store
	btst	#0,Event_b5(a5)		; Pile or chest ?
	beq.s	.Chest
	tst.b	d0			; Pile empty ?
	bne.s	.Exit
	st	Success			; Yes -> Success !
	btst	#1,Event_b5(a5)		; Write back ?
	bne.s	.No
	jsr	Save_event		; Yes -> Save
.No:	jsr	Update_screen		; Leave
	jsr	Door_Exit
	bra.s	.Exit
.Chest:	move.b	Pic_80x80_handle,d0		; Remove current picture
	jsr	Free_memory
	tst.b	Chest_filled		; Full or empty chest ?
	beq.s	.Empty
	moveq.l	#Opened_chest_pic,d0	; Full
	bra.s	.Go_on
.Empty:	moveq.l	#Empty_chest_pic,d0		; Empty
.Go_on:	jsr	Load_80x80_picture		; Load picture
	jsr	Display_80x80_picture	; Show picture
	jsr	Update_screen
.Exit:	rts

OpenedChest_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	jsr	Display_80x80_picture	; Show picture
	move.w	#110,Gold_X		; Set gold & food positions
	move.w	#103,Gold_Y
	move.w	#303-44,Food_X
	move.w	#103,Food_Y
	lea.l	OpenedChest_CIL,a0		; Show control icons
	jsr	Display_control_icons
	move.b	Chest_data_handle,Slotbase_handle	; Display scroll bar
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0
	move.w	#Items_per_chest,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
; ---------- Print text if necessary --------------
; Must be here because fade-in must happen when [ Init_display ] is called.

	tst.b	First_chest		; Just opened ?
	beq.s	.No
	jsr	Update_screen		; Yes
	bra.s	.Print
.No:	jsr	Fade_in_bottom		; No -> fade in
	btst	#0,Event_b5(a5)		; Pile ?
	beq.s	.Exit
.Print:	moveq.l	#0,d0			; Get text block number
	move.b	Event_b3(a5),d0
	cmp.b	#-1,d0			; Any text ?
	beq.s	.Exit
	tst.b	Chest_text_printed		; Text printed ?
	bne.s	.Exit
	st	Chest_text_printed		; Is now!
	Get	Current_event_text_handle,a0	; Display text
	jsr	Do_text
	Free	Current_event_text_handle
.Exit:	rts

OpenedChest_DisExit:
	jsr	Destroy_ghosts		; Destroy !
	Pop	Scroll_bar
	jmp	Fade_out_bottom

OpenedChest_CIL_evaluate:
	Get	Chest_data_handle,a1
; ---------- Any gold in chest ? ------------------
	tst.w	Chest_gold(a1)		; Well ?
	bne.s	.Gold_OK
	bset	#7,8(a0)			; Disable {Divide gold}
	bset	#7,14(a0)			; Disable {Transfer gold}
; ---------- Any food in chest ? ------------------
.Gold_OK:	tst.w	Chest_food(a1)		; Well ?
	bne.s	.Food_OK
	bset	#7,10(a0)			; Disable {Divide food}
	bset	#7,16(a0)			; Disable {Transfer food}
; ---------- Any items in chest ? -----------------
.Food_OK:	moveq.l	#Items_per_chest-1,d7	; Well ?
.Loop:	tst.w	Object_index(a1)
	bne.s	.Exit
	addq.w	#Object_packet_size,a1
	dbra	d7,.Loop
	bset	#7,12(a0)			; Disable	{View item}
.Exit:	Free	Chest_data_handle
	rts

; ********** Layout 3 - View item *****************
View_item_LAY3:
	jsr	Destroy_ghosts		; Destroy !
	move.w	#31,ItemSelect_prompt	; Select item
	Push	Module,Lay3_ItemSelect_Mod
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
.Exit:	rts

; ********** Opened chest screen - Divide food ****
Divide_food_CHEST:
	Get	Chest_data_handle,a0
	move.w	Chest_food(a0),d0
	jsr	Divide_food
	move.w	d0,Chest_food(a0)
	Free	Chest_data_handle
	rts

; ********** Opened chest screen - Divide gold ****
Divide_gold_CHEST:
	Get	Chest_data_handle,a0
	move.w	Chest_gold(a0),d0
	jsr	Divide_gold
	move.w	d0,Chest_gold(a0)
	Free	Chest_data_handle
	rts

; ********** Chest screen - Transfer gold *********
Transfer_gold_CHEST:
	jsr	Destroy_ghosts		; Destroy !
	Get	Chest_data_handle,a0	; How much ?
	moveq.l	#0,d0
	move.w	Chest_gold(a0),d0
	move.l	d0,Maximum_number
	Free	Chest_data_handle
	move.w	#52,InputNr_prompt
	move.b	#1,ObjGoldFood
	clr.l	Minimum_number
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d0		; Any ?
	beq	.Exit
	moveq.l	#0,d7			; Anyone interested ?
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
	Get	Chest_data_handle,a0	; Remove gold
	move.l	InputNr_number,d0
	sub.w	d0,Chest_gold(a0)
	Free	Chest_data_handle
	lea.l	Party_handles-1,a1		; Add gold
	add.w	Selected_member,a1
	Get	(a1),a0
	move.l	InputNr_number,d0
	add.w	d0,Gold_coins(a0)
	mulu.w	#Gold_weight,d0
	add.l	d0,Weight_normal(a0)
	Free	(a1)
.Exit:	rts

; ********** Chest screen - Transfer food *********
Transfer_food_CHEST:
	jsr	Destroy_ghosts		; Destroy !
	Get	Chest_data_handle,a0	; How much ?
	moveq.l	#0,d0
	move.w	Chest_food(a0),d0
	move.l	d0,Maximum_number
	Free	Chest_data_handle
	move.w	#53,InputNr_prompt
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
	Get	Chest_data_handle,a0	; Remove food
	move.l	InputNr_number,d0
	sub.w	d0,Chest_food(a0)
	Free	Chest_data_handle
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
; [ Update gold display ]
; No registers are restored
;*****************************************************************************
Update_gold:
	tst.w	Current_gold		; Any gold ?
	bne	.Yes
	move.w	Gold_X,d0			; No -> Erase
	move.w	Gold_Y,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#45-1,d2
	addi.w	#17-1,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	bra	.Exit
.Yes:	move.w	Gold_X,d0			; Yes -> Make box
	move.w	Gold_Y,d1
	move.w	#45,d2
	move.w	#17,d3
	jsr	Draw_standard_box2
	move.w	#2,Ink_colour		; Set ink
	addq.w	#1,d0			; Print "GOLD"
	addq.w	#2,d1
	move.l	Gold_txt_ptr,a0
	jsr	Print_centered_string
	lea.l	Number,a0			; Convert gold
	move.w	Current_gold,d0
	moveq.l	#5,d7
	jsr	DecL_convert
	move.w	Gold_X,d0			; Print
	move.w	Gold_Y,d1
	addq.w	#1,d0
	addi.w	#9,d1
	lea.l	Number,a0
	jsr	Print_centered_string
.Exit:	rts

;*****************************************************************************
; [ Update food display ]
; No registers are restored
;*****************************************************************************
Update_food:
	tst.w	Current_food		; Any food ?
	bne	.Yes
	move.w	Food_X,d0			; No -> Erase
	move.w	Food_Y,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#45-1,d2
	addi.w	#17-1,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	bra	.Exit
.Yes:	move.w	Food_X,d0			; Make box
	move.w	Food_Y,d1
	move.w	#45,d2
	move.w	#17,d3
	jsr	Draw_standard_box2
	move.w	#2,Ink_colour		; Set ink
	addq.w	#1,d0			; Print "FOOD"
	addq.w	#2,d1
	move.l	Food_txt_ptr,a0
	jsr	Print_centered_string
	lea.l	Number,a0			; Convert food
	move.w	Current_food,d0
	moveq.l	#5,d7
	jsr	DecL_convert
	move.w	Food_X,d0			; Print
	move.w	Food_Y,d1
	addq.w	#1,d0
	addi.w	#9,d1
	lea.l	Number,a0
	jsr	Print_centered_string
.Exit:	rts

;*****************************************************************************
; [ Move item from an inventory ]
;*****************************************************************************
Move_all_LAY3_items:
	st	Right_move		; Set
	bra	Enter_LAY3_item
Move_LAY3_item:
	sf	Right_move		; Clear
Enter_LAY3_item:
	jsr	Wait_4_unclick
; ---------- Item ? What item ? -------------------
	tst.b	d0			; Any selected ?
	beq	.Exit2
	cmp.b	#-1,d0			; Scroll bar ?
	beq	.Exit2
	andi.w	#$00ff,d0			; Get real slot number
	move.w	d0,d6
	add.w	Scroll_bar_result,d0
	move.w	d0,Source_slot
	Get	Slotbase_handle,a2		; Get packet address
	add.l	Slotbase_offset,a2
	subq.w	#1,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	Object_index(a2),d0		; Get object index
	beq	.Exit			; Anything there ?
	jsr	Destroy_ghosts		; Kill !
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
.Not_all:	move.l	d0,Maximum_number
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
	Free	Slotbase_handle
	move.w	Source_slot,d2		; Remove item
	move.l	InputNr_number,d3
	jsr	Remove_LAY3_item
	jsr	Scan_4_transfer_victims	; Anyone interested ?
	jsr	Show_transfer_victims	; Show
	move.w	d6,d0
	jsr	Display_object
	jsr	Update_screen
	Push	Module,Move_LAY3_item_Mod	; Move it !
	bra.s	.Exit2
.Exit:	Free	Slotbase_handle		; Exit
.Exit2:	rts

;***************************************************************************
; [ Move LAY3 item target selector ]
; Note:
;  - This routine will only work for Layout 3 & 8.
;***************************************************************************
Move_LAY3_item_DisUpd:
	lea.l	Move_item_HDOB,a0		; Update HDOB position
	move.w	Mouse_X,(a0)+
	move.w	Mouse_Y,(a0)+
	jmp	Basic_DisUpd

; ********** Player clicked on LAY3 slot **********
LAY3_item_moved:
	jsr	Wait_4_unclick
; ---------- Item ? What item ? -------------------
	tst.b	d0			; Any selected ?
	beq	.Exit2
	cmp.b	#-1,d0			; Scroll bar ?
	beq	.Exit2
; ---------- Try to move --------------------------
	andi.w	#$00ff,d0			; Get real slot number
	move.w	d0,d6
	add.w	Scroll_bar_result,d0
	move.w	d0,Target_slot
	Get	Slotbase_handle,a2		; Get packet address
	add.l	Slotbase_offset,a2
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
	bra	.Exit
.End:	add.b	d3,Quantity(a2)		; Transfer
	clr.w	Object_index(a3)		; Destroy
	bra	.Exit
; ---------- Fill empty slot ----------------------
.Empty:	Copy_packet a3,a2			; Copy packet
	clr.b	Quantity(a3)		; Destroy item
	clr.w	Object_index(a3)
	bra	.Exit
; ---------- Swap packets -------------------------
.Swap:	lea.l	Swap_packet,a4		; Save target packet
	Copy_packet a2,a4
	move.w	Target_slot,d2		; Remove item
	moveq.l	#0,d3
	move.b	Quantity(a2),d3
	jsr	Remove_LAY3_item
	Copy_packet a3,a2			; Copy packet
	Copy_packet a4,a3			; Make new source packet
	jsr	Destroy_ghosts		; Kill !
	jsr	Exit_moving_item
	jsr	Init_moving_item
	move.l	a4,a0			; Anyone interested ?
	jsr	Scan_4_transfer_victims
	jsr	Show_transfer_victims	; Show
	jsr	Update_objects
	jsr	Update_screen
	move.w	Target_slot,Source_slot	; Move this !
	bra.s	.Skip
.Exit:	jsr	Update_objects		; Show
	jsr	Update_screen
	tst.w	Object_index(a3)		; Any left ?
	bne.s	.Skip
	jsr	Exit_moving_item		; No -> exit
	Pop	Module
.Skip:	Free	Slotbase_handle
.Exit2:	rts

; ********** Player aborted ***********************
Move_LAY3_aborted:
	jsr	Wait_4_unclick
	move.w	Source_slot,d0		; Try to put it back
	move.w	Scroll_bar_result,d1	; Slot out of view ?
	move.w	d0,d2
	sub.w	d1,d2
	cmp.w	#12,d2
	blo.s	.No
	jsr	Set_scroll_bar2		; Set scroll bar
.No:	sub.w	Scroll_bar_result,d0	; Do
	bra	LAY3_item_moved

; ********** Player clicked on member portrait ****
Member_moved_LAY3:
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
	Pop	Module
.Exit:	rts

;*****************************************************************************
; [ Remove item from an inventory ]
;   IN : d2 - Slot number {1...24} (.w)
;        d3 - Quantity that is to be removed (.w)
; All registers are restored
; Note :
;  - It is assumed that the inventory is currently visible over a scroll-bar.
;  - This routine does NOT redraw anything ! It is intended as a general,
;    safe method of removing items.
;*****************************************************************************
Remove_LAY3_item:
	movem.l	d0/d2/a1/a2,-(sp)
	Get	Slotbase_handle,a2		; Get packet address
	add.l	Slotbase_offset,a2
	subq.w	#1,d2
	mulu.w	#Object_packet_size,d2
	add.l	d2,a2
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	moveq.l	#0,d0			; Reduce quantity
	move.b	Quantity(a2),d0
	sub.w	d3,d0
	bgt.s	.Yes			; Any left ?
	clr.w	Object_index(a2)		; Destroy item
.Yes:	move.b	d0,Quantity(a2)		; Store
	Free	Slotbase_handle
	movem.l	(sp)+,d0/d2/a1/a2
	rts

;*****************************************************************************
; [ Automatically distribute items in inventory ]
;   IN : d0 - Inventory memory handle (.b)
;        a0 - Pointer to source packet (.l)
; All registers are restored
;  - This routine does NOT redraw anything ! It is intended as a general,
;    safe method of adding items.
;  - This routine will remove items from the source packet, and destroy
;    the source packet if the quantity reaches zero.
;  - It is assumed that the inventory contains {Items_per_chest} slots.
;*****************************************************************************
Auto_move_to_INV:
	movem.l	d0-d3/d7/a0-a4,-(sp)
	move.l	a0,a2
	jsr	Claim_pointer		; Get target inventory
	move.l	d0,a3
	move.l	Object_data_ptr,a1		; Get object data
	move.w	Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
; ---------- Scan for slots with this item --------
	btst	#Multiple,Item_bits_STATIC(a1)	; Multiple ?
	beq	.Single
	move.l	a3,a4			; Scan slots
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
	move.l	a3,a4			; Scan slots
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
	bra.s	.Exit
; ---------- Scan for free slots ------------------
.Single:	move.l	a3,a4			; Scan slots
	moveq.l	#Items_per_chest-1,d7
.Loop3:	tst.w	Object_index(a4)		; Free slot ?
	beq.s	.Do_it2
	addq.w	#Object_packet_size,a4	; Next packet
	dbra	d7,.Loop3
	bra.s	.Exit			; (shouldn't occur)
; ---------- Fill slot ----------------------------
.Do_it2:	Copy_packet a2,a4			; Copy packet
	subq.b	#1,Quantity(a2)
	move.b	#1,Quantity(a4)
.Exit:	tst.b	Quantity(a2)		; All gone ?
	bgt.s	.Skip
	clr.w	Object_index(a2)		; Yes -> destroy item
.Skip:	movem.l	(sp)+,d0-d3/d7/a0-a4
	jmp	Free_pointer

;*****************************************************************************
; [ Show picture + text event ]
; No registers are restored
;*****************************************************************************
Show_pictxt:
	lea.l	Current_event_data,a5
	tst.b	Stygian			; Can we see ?
	beq.s	.Yes
	tst.b	Event_b3(a5)		; Visual event ?
	bne	.Yes
.No:	st	Break_event		; Abort chain
	bra	.Exit
.Yes:	tst.b	Eye_flag			; Looking or moving ?
	beq.s	.Walk
	btst	#1,Event_b2(a5)		; Move only ?
	beq.s	.No
	bra.s	.Go_on
.Walk:	btst	#0,Event_b2(a5)		; Look only ?
	beq.s	.No
.Go_on:	cmp.b	#-1,Event_b1(a5)		; Any picture ?
	beq	.No_pic
	jsr	Exit_display		; Yes
	Push	Module,ShowPicTxt_Mod
	jsr	Init_display
	bra	.Exit
.No_pic:	moveq.l	#0,d0			; Get text number
	move.b	Event_b5(a5),d0
	cmp.b	#-1,d0			; Any ?
	beq.s	.Exit
	jsr	Update_screen		; Yes -> print text
	Get	Current_event_text_handle,a0
	jsr	Do_text_window
	Free	Current_event_text_handle
.Exit:	rts

ShowPicTxt_ModInit:
	moveq.l	#ShowPicTxt_layout,d0	; Show new layout
	jsr	Show_layout
	lea.l	Current_event_data,a5
; ---------- Load & display picture ---------------
	moveq.l	#0,d2			; Get picture number
	move.b	Event_b1(a5),d2
	move.w	d2,d0			; Load picture
	addq.w	#1,d0			; !!!
	moveq.l	#Event_pix_file,d1
	jsr	Load_subfile
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Display picture
	move.l	d0,a0
	moveq.l	#0,d0
	move.w	#ShowPicTxt_Y,d1
	moveq.l	#Screen_depth,d5
	moveq.l	#20,d6
	moveq.l	#ShowPicTxt_height,d7
	jsr	Put_unmasked_block
	move.w	(sp)+,d0			; Remove picture
	jsr	Free_pointer
	jsr	Free_memory
; ---------- Load & install palette ---------------
	lea.l	Event_pix_palette_table,a0	; Get palette number
	move.b	0(a0,d2.w),d0
	moveq.l	#Palette_file,d1		; Load palette
	jsr	Load_subfile
	move.b	d0,d7
	jsr	Claim_pointer
	move.l	d0,a0
	lea.l	Batch,a1			; Copy palette
	moveq.l	#Pal_size-1,d6
.Loop:	move.w	(a0)+,(a1)+
	dbra	d6,.Loop
	move.b	d7,d0			; Destroy palette
	jsr	Free_pointer
	jsr	Free_memory
	jsr	Fade_in_bottom		; Fade in
; ---------- Do text ------------------------------
	move.w	#31,Ink_colour		; Set ink
	moveq.l	#0,d0			; Get text number
	move.b	Event_b5(a5),d0
	cmp.b	#-1,d0			; Any ?
	beq.s	.Exit
	Get	Current_event_text_handle,a0	; Yes -> print text
	jsr	Do_text
	Free	Current_event_text_handle
.Exit:	jmp	Pop_Module		; Exit

;*****************************************************************************
; [ Spinner event ]
; No registers are restored
;*****************************************************************************
Spinner:
	moveq.l	#0,d0
	move.b	Current_event_data+Event_b1,d0
	cmpi.w	#4,d0			; Random ?
	bmi.s	.No
.Repeat:	jsr	Random			; Random !
	andi.w	#$0003,d0
	cmp.w	View_direction,d0		; The same ?
	beq.s	.Repeat
.No:	move.w	d0,View_direction		; Set new	view direction
	cmp.b	#Map_3D,Current_map_type	; 3D map ?
	bmi	.No_3D
	mulu.w	#slang/4,d0		; Get target angle
	neg.w	d0
	andi.w	#slang-1,d0
	move.w	d0,d1			; Save
	sub.w	Y_angle,d0		; Calculate number of steps
	bpl.s	.Pos
	neg.w	d0
.Pos:	ext.l	d0
	divu.w	#slang/Fullturn_steps,d0
	add.w	#Fullturn_steps-1,d0
	jsr	Update_screen
.Loop:	add.l	#slang*32768/Fullturn_steps,Y_angle	; Rotate
	jsr	M3_DisUpd			; Display
	jsr	Map_DisUpd
	jsr	Switch_screens
	dbra	d0,.Loop
	swap	d1			; Set real angle
	clr.w	d1
	move.l	d1,Y_angle
	jsr	M3_DisUpd			; Display last time
	jsr	Map_DisUpd
	jsr	Switch_screens
	jsr	Copy_screen
.No_3D:	jmp	Wait_4_unclick		; Wait

;*****************************************************************************
; [ Trap event ]
; No registers are restored
;*****************************************************************************
Event_trap:
	lea.l	Current_event_data,a5
	moveq.l	#0,d5			; Get amount of damage
	move.b	Event_b4(a5),d5
	moveq.l	#0,d0			; Get condition
	move.b	Event_b1(a5),d0
	lea.l	.Table,a0
	move.b	0(a0,d0.w),d6
	tst.b	Event_b2(a5)		; Party or active ?
	beq	.Active
	lea.l	Party_handles,a1		; Party
	sf	Success
	moveq.l	#1,d7
.Loop:	tst.b	(a1)			; Anyone there ?
	beq.s	.Next
	Get	(a1),a0
	move.w	Body_conditions(a0),d0	; Alive and kicking ?
	andi.w	#Alive_mask,d0
	bne.s	.Done
	move.b	Char_sex(a0),d0		; Correct sex ?
	btst	d0,Event_b3(a5)
	beq.s	.Done
	jsr	.Do_trap			; Do trap
.Done:	Free	(a1)
.Next:	addq.l	#1,a1			; Next member
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	jsr	Update_active_status	; Update!
	bra	.Exit_all
; ---------- Hurt active character ----------------
.Active:	Get	Active_handle,a0		; Active member only
	move.b	Char_sex(a0),d0		; Correct sex ?
	btst	d0,Event_b3(a5)
	beq.s	.Done2
	move.w	Active_member,d7		; Do trap
	jsr	.Do_trap
.Done2:	Free	Active_handle
; ---------- Exit ---------------------------------
.Exit_all:	Get	Active_handle,a0		; Leader deactivated ?
	move.w	Body_conditions(a0),d0
	Free	Active_handle
	andi.w	#Active_mask,d0
	beq.s	.Ok1
	jsr	Select_new_active_member	; Yes -> new leader
.Ok1:	rts

.Table:	dc.b -1,Mad,Blind,Stoned
	dc.b Lamed,Poisoned,Petrified,Diseased
	dc.b Aging,Dead
	even

; [ Do trap effect ]
;   IN : d5 - Amount of damage (.w)
;        d6 - Condition number / -1 (.w)
;        d7 - Member number {1...6} (.w)
;        a0 - Pointer to victim's character data (.l)
;        a5 - Pointer to current event data (.l)
; All registers are restored
.Do_trap:
	movem.l	d0/d1,-(sp)
	move.w	ALuck(a0),d0		; Probe luck
	add.w	ALuck+Magic(a0),d0
	jsr	Probe_100
	bmi.s	.Bad_luck
	move.w	#279,d0			; "Lucky!"
	jsr	Do_member_prompt_window
	bra.s	.Exit
.Bad_luck:	st	Success			; Yay !
	tst.w	d5			; Any damage ?
	beq.s	.No_damage
	move.w	d5,d1			; Yes -> Get 50% to 100%
	lsr.w	#1,d1
	jsr	Random
	mulu.w	d1,d0
	swap	d0
	add.w	d5,d0
	jsr	Do_damage			; Do
.No_damage:
	tst.b	d6			; Any condition ?
	bmi.s	.Exit
	cmp.b	#Dead,d6			; Yes -> Kill ?
	bne.s	.Not_kill
	jsr	Kill_member		; Yes
	bra.s	.Exit
.Not_kill:	move.w	Body_conditions(a0),d0	; No -> Set condition
	bset	d6,d0
	move.w	d0,Body_conditions(a0)
.Exit:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Anti Magic event ]
; No registers are restored
;*****************************************************************************
Anti_magic:
	lea.l	Current_event_data,a5
	move.b	Event_b1(a5),d0		; All or one ?
	bne.s	.One
	lea.l	Spell_1_duration,a0		; Clear all spells
	moveq.l	#0,d0
	moveq.l	#6-1,d7
.Loop:	move.l	d0,(a0)+
	dbra	d7,.Loop
	bra.s	.Exit
.One:	lea.l	Spell_1_duration,a0		; Clear one spell
	ext.w	d0
	subq.w	#1,d0
	cmp.w	#6,d0			; Legal ?
	bpl.s	.Exit
	add.w	d0,d0
	add.w	d0,a0
	clr.l	(a0)
.Exit:	rts

;*****************************************************************************
; [ Riddle Mouth event ]
; No registers are restored
;*****************************************************************************
Riddle_mouth:
	jsr	Exit_display
	Push	Module,RiddleM_Mod
	rts

RiddleM_ModInit:    
	sf	RM_anim_flag		; No animation
	clr.w	RM_anim_index
	clr.w	RM_anim_count
	moveq.l	#Dictionary_file,d0		; Load dictionary
	jsr	Load_file
	move.b	d0,Dictionary_handle
	moveq.l	#RM_gfx_file,d0		; Load graphics
	jsr	Load_file
	move.b	d0,RM_gfx_handle
	moveq.l	#Riddlemouth_pic,d0		; Load picture
	jsr	Load_80x80_picture
	jsr	RiddleM_DisInit		; Build screen
	jmp	Ask_riddleM		; Print question

RiddleM_ModExit:    
	move.b	RM_gfx_handle,d0		; Free memory
	jsr	Free_memory
	move.b	Dictionary_handle,d0
	jsr	Free_memory
	move.b	Pic_80x80_handle,d0
	jmp	Free_memory

RiddleM_DisInit:    
	moveq.l	#Riddlemouth_layout,d0	; Show new layout
	jsr	Show_layout
	Get	Pic_80x80_handle,a0		; Display	80x80 picture
	move.w	#224,d0
	moveq.l	#49,d1
	moveq.l	#5,d5
	moveq.l	#5,d6
	moveq.l	#80,d7
	jsr	Put_unmasked_block
	Free	Pic_80x80_handle
	lea.l	RiddleM_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Fade_in_bottom		; Fade in
	moveq.l	#0,d1			; Open eyes
	moveq.l	#4-1,d7
.Loop:	move.w	d1,d0			; Show frame
	jsr	Display_RM_eyes
	jsr	Update_screen
	moveq.l	#RM_eyes_speed,d0		; Wait
	jsr	Delay
	addq.w	#1,d1			; Next frame
	dbra	d7,.Loop
	rts

RiddleM_DisExit:
	moveq.l	#4-1,d7			; Close eyes
.Loop:	move.w	d7,d0			; Show frame
	jsr	Display_RM_eyes
	jsr	Update_screen
	moveq.l	#RM_eyes_speed,d0		; Wait
	jsr	Delay
	dbra	d7,.Loop			; Next frame
	jmp	Fade_out_bottom		; Fade out

; ********** Riddlemouth - Answer *****************
Answer_riddleM:     
	jsr	Clear_new_words_array	; Select a word
	Push	Module,WSelW_Mod
	tst.b	No_word_selected		; Any word entered ?
	bne	.Exit
	move.w	Selected_word,d0		; Get word
	cmp.w	#-1,d0			; In dictionary ?
	beq	.No
	lea.l	Current_event_data,a5	; Is it the one ?
	cmp.w	Event_w6(a5),d0
	beq.s	.Right
	cmp.w	Event_w8(a5),d0		; Or the other one ?
	bne	.Wrong
.Right:	moveq.l	#0,d0			; Any message ?
	move.b	Event_b2(a5),d0
	cmpi.b	#-1,d0
	beq.s	.No_text
	Get	Current_event_text_handle,a0	; Yes -> print it
	st	RM_anim_flag		; Start animation
	jsr	Do_text
	Free	Current_event_text_handle
.No_text:	st	Success			; Success !
	jsr	Basic_exit		; Exit
	bra.s	.Exit
.No:	lea.l	Wrong_answer_text,a1	; Build text
	move.l	That_text_ptr,(a1)		; "That ..."
	bra.s	.Do
.Wrong:	lea.l	Wrong_answer_text,a1	; Build text
	lea.l	Dictionary_word,a0		; Insert word
	jsr	Find_word
	move.l	a0,(a1)
.Do:	st	RM_anim_flag		; Start animation
	moveq.l	#0,d0			; Print text
	move.l	a1,a0
	jsr	Display_text_and_wait
	jsr	Erase_PA			; Erase
	jsr	Update_screen
.Exit:	rts

; ********** Riddlemouth - Ask ********************
Ask_riddleM:        
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get text number
	move.b	Event_b1(a5),d0
	cmp.b	#-1,d0			; Any text ?
	beq.s	.Exit
	Get	Current_event_text_handle,a0	; Yes -> print it
	st	RM_anim_flag		; Start animation
	jsr	Do_text
	Free	Current_event_text_handle
.Exit:	rts

Animate_RM_mouth:
	tst.b	RM_anim_flag		; Animate ?
	beq.s	.Exit
	move.w	RM_anim_index,d1		; Get current frame
	moveq.l	#0,d0
	move.b	.Anim(pc,d1.w),d0
	cmp.b	#-1,d0			; Last frame ?
	bne.s	.Do
	sf	RM_anim_flag		; Yes -> end of animation
	clr.w	RM_anim_index
	clr.w	RM_anim_count
	bra.s	.Exit
.Do:	jsr	Display_RM_mouth		; No -> display mouth
	move.w	RM_anim_count,d0		; Animation speed count
	addq.w	#1,d0
	cmp.w	#RM_mouth_speed,d0		; Time for next frame ?
	bmi.s	.No
	addq.w	#1,RM_anim_index		; Yes -> next frame
	moveq.l	#0,d0			; Reset speed counter
.No:	move.w	d0,RM_anim_count		; Store
.Exit:	rts

.Anim:	dc.b 0,1,3,5,3,1,0,2,4,6,4,2,0,-1
	even

;*****************************************************************************
; [ Display riddlemouth mouth ]
;   IN : d0 - Frame number {0...6} (.w)
; All registers are restored
;*****************************************************************************
Display_RM_mouth:
	movem.l	d0/d1/d4-d7/a0,-(sp)
	Get	RM_gfx_handle,a0		; Get frame address
	lea.l	RM_mouths_offset(a0),a0
	mulu.w	#RM_mouth_size,d0
	add.l	d0,a0
	move.w	#224+16,d0		; Display mouth frame
	move.w	#49+41,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#3,d6
	moveq.l	#15,d7
	jsr	Put_unmasked_block
	Free	RM_gfx_handle
	movem.l	(sp)+,d0/d1/d4-d7/a0
	rts

;*****************************************************************************
; [ Display riddlemouth eyes ]
;   IN : d0 - Frame number {0...3} (.w)
; All registers are restored
;*****************************************************************************
Display_RM_eyes:
	movem.l	d0/d1/d4-d7/a0,-(sp)
	Get	RM_gfx_handle,a0		; Get frame address
	mulu.w	#RM_eyes_size,d0
	add.l	d0,a0
	move.w	#224+16,d0		; Display eye frame
	move.w	#49+23,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#3,d6
	moveq.l	#9,d7
	jsr	Put_unmasked_block
	Free	RM_gfx_handle
	movem.l	(sp)+,d0/d1/d4-d7/a0
	rts

;*****************************************************************************
; [ Datachange event ]
; No registers are restored
;*****************************************************************************
Datachange:
	lea.l	Current_event_data,a5
	moveq.l	#0,d2			; Get change type
	move.b	Event_b1(a5),d2
	cmp.w	#8+1,d2			; Legal ?
	bpl.s	.Exit_all
	lea.l	.Ptrs1,a1			; Get handler address
	lsl.w	#2,d2
	move.l	0(a1,d2.w),a1
	moveq.l	#-1,d1			; Default maximum value
	tst.b	Event_b4(a5)		; Active or party ?
	beq	.Active
	lea.l	Party_handles,a2		; Party
	moveq.l	#6-1,d7
.Loop:	move.b	(a2)+,d0			; Anyone there ?
	beq.s	.Next
	Get	d0,a0
	move.w	Body_conditions(a0),d0	; Alive and kicking ?
	andi.w	#Alive_mask,d0
	bne.s	.Done
	movem.l	d7/a1/a2,-(sp)		; Change data
	jsr	(a1)	
	movem.l	(sp)+,d7/a1/a2
.Done:	Free	-1(a2)
.Next:	dbra	d7,.Loop			; Next member
	bra.s	.Exit_all
.Active:	Get	Active_handle,a0		; Active member only
	jsr	(a1)			; Change data
	Free	Active_handle
.Exit_all:	rts

.Ptrs1:	dc.l .Attribute,.Skill,.LP,.SP,.SLP
	dc.l .Conditions,.Spell_classes,.Languages,.XP

; [ Data type handlers ]
;   IN : d1 - -1 (default maximum value) (.l)
;        a0 - Pointer to character data (.l)
; No registers are restored

.Attribute:
	lea.l	Attributes(a0),a1		; Select attribute
	move.w	Event_w6(a5),d2
	cmp.w	#Max_attrs,d2		; Legal ?
	bpl.s	.Exit1
	mulu.w	#Attr_data_size,d2
	add.w	d2,a1
	moveq.l	#0,d0			; Get attribute values
	move.w	(a1),d0
	add.w	Magic(a1),d0
	moveq.l	#0,d1
	move.w	Maximum(a1),d1
	jsr	.Do			; Change
	move.w	d0,(a1)			; Store
.Exit1:	rts

.Skill:
	lea.l	Skills(a0),a1		; Select skill
	move.w	Event_w6(a5),d2
	cmp.w	#Max_skills,d2		; Legal ?
	bpl.s	.Exit2
	mulu.w	#Skill_data_size,d2
	add.w	d2,a1
	moveq.l	#0,d0			; Get skill values
	move.w	(a1),d0
	add.w	Magic(a1),d0
	moveq.l	#0,d1
	move.w	Maximum(a1),d1
	jsr	.Do			; Change
	move.w	d0,(a1)			; Store
.Exit2:	rts

.LP:
	moveq.l	#0,d0			; Get LP & LP maximum
	move.w	Life_points(a0),d0
	moveq.l	#0,d1
	move.w	Life_points+Maximum(a0),d1
	add.w	Life_points+Magic(a0),d1
	jsr	.Do			; Change
	move.w	d0,Life_points(a0)		; Store
	rts

.SP:
	moveq.l	#0,d0			; Get SP & SP maximum
	move.w	Power_points(a0),d0
	moveq.l	#0,d1
	move.w	Power_points+Maximum(a0),d1
	add.w	Power_points+Magic(a0),d1
	jsr	.Do			; Change
	move.w	d0,Power_points(a0)		; Store
	rts

.SLP:
	moveq.l	#0,d0			; Get SLP
	move.w	Nr_spell_learn_points(a0),d0
	jsr	.Do			; Change
	move.w	d0,Nr_spell_learn_points(a0)	; Store
	rts

.Conditions:
	moveq.l	#0,d0			; Get conditions
	move.w	Body_conditions(a0),d0
	jsr	.Do			; Change
	move.w	d0,Body_conditions(a0)	; Store
	rts

.Spell_classes:
	moveq.l	#0,d0			; Get spell classes
	move.b	Spell_class_counter(a0),d0
	jsr	.Do			; Change
	move.b	d0,Spell_class_counter(a0)	; Store
	rts

.Languages:
	moveq.l	#0,d0			; Get languages
	move.b	Learned_languages(a0),d0
	jsr	.Do			; Change
	move.b	d0,Learned_languages(a0)	; Store
	rts

.XP:
	move.l	Experience_points(a0),d0	; Get experience points
	jsr	.Do			; Change
	move.l	d0,Experience_points(a0)	; Store
	jmp	Check_member_levels		; Check !

; [ Select & execute data changer ]
;   IN : d0 - Data longword (.l)
;        d1 - Maximum value (.l)
;        a5 - Pointer to event data (.l)
;  OUT : d0 - New data longword (.l)
; Changed registers : d0
.Do:
	movem.l	d2/a1,-(sp)
	moveq.l	#0,d2			; Get change type
	move.b	Event_b2(a5),d2
	cmp.w	#7+1,d2			; Legal ?
	bpl.s	.Exit_do
	lsl.w	#2,d2			; Change data
	move.l	.Ptrs2(pc,d2.w),a1
	jsr	(a1)
.Exit_do:	movem.l	(sp)+,d2/a1
	rts

.Ptrs2:	dc.l .Inc,.Dec,.Inc_percent,.Dec_percent,.Full
	dc.l .Bitclear,.Bitset,.Bitchange

; [ Actual data changers ]
;   IN : d0 - Data longword (.l)
;        d1 - Maximum value (.l)
;        a5 - Pointer to event data (.l)
;  OUT : d0 - New data longword (.l)
; Changed registers : d0,d2
; Notes :
;  - An overflow may occur in [ .Inc_percent ] and [ .Dec_percent ] routines.

.Inc:
	moveq.l	#0,d2			; Get add value
	move.w	Event_w8(a5),d2
	tst.b	Event_b3(a5)		; Random ?
	beq.s	.No1
	move.l	d0,-(sp)			; Yes
	jsr	Random
	andi.l	#$0000ffff,d0
	divu.w	d2,d0
	swap	d0
	move.w	d0,d2
	addq.w	#1,d2			; FIX: Random value 0...max-1 -> 1...max
	move.l	(sp)+,d0
.No1:	add.l	d2,d0			; Add
	cmp.l	d1,d0			; Too much ?
	bls.s	.Ok1
	move.l	d1,d0			; Yes -> clip
.Ok1:	rts
	
.Dec:
	moveq.l	#0,d2			; Get subtract value
	move.w	Event_w8(a5),d2
	tst.b	Event_b3(a5)		; Random ?
	beq.s	.No2
	move.l	d0,-(sp)			; Yes
	jsr	Random
	andi.l	#$0000ffff,d0
	divu.w	d2,d0
	swap	d0
	move.w	d0,d2
	addq.w	#1,d2			; FIX: Random value 0...max-1 -> 1...max
	move.l	(sp)+,d0
.No2:	sub.l	d2,d0			; Subtract
	bpl.s	.Ok2			; Too little ?
	moveq.l	#0,d0			; Yes -> clip
.Ok2:	rts

.Inc_percent:
	move.w	Event_w8(a5),d2		; Get add percentage
	beq.s	.Ok3
	tst.b	Event_b3(a5)		; Random ?
	beq.s	.No3
	move.l	d0,-(sp)			; Yes
	jsr	Random
	andi.l	#$0000ffff,d0
	divu.w	d2,d0
	swap	d0
	move.w	d0,d2
	addq.w	#1,d2			; FIX: Random value 0...max-1 -> 1...max
	move.l	(sp)+,d0
.No3:	mulu.w	d1,d2			; Get actual value
	divu.w	#100,d2
	andi.l	#$0000ffff,d2
	add.l	d2,d0			; Add
	cmp.l	d1,d0			; Too much ?
	bls.s	.Ok3
	move.l	d1,d0			; Yes -> clip
.Ok3:	rts

.Dec_percent:
	move.w	Event_w8(a5),d2		; Get subtract percentage
	beq.s	.Ok4
	tst.b	Event_b3(a5)		; Random ?
	beq.s	.No4
	move.l	d0,-(sp)			; Yes
	jsr	Random
	andi.l	#$0000ffff,d0
	divu.w	d2,d0
	swap	d0
	move.w	d0,d2
	addq.w	#1,d2			; FIX: Random value 0...max-1 -> 1...max
	move.l	(sp)+,d0
.No4:	mulu.w	d1,d2			; Get actual value
	divu.w	#100,d2
	andi.l	#$0000ffff,d2
	sub.l	d2,d0			; Subtract
	bpl.s	.Ok4			; Too little ?
	moveq.l	#0,d0			; Yes -> clip
.Ok4:	rts
	
.Full:
	move.l	d1,d0			; Full
	rts

.Bitclear:
	move.w	Event_w6(a5),d2		; Clear bit
	bclr	d2,d0
	rts

.Bitset:
	move.w	Event_w6(a5),d2		; Set bit
	bset	d2,d0
	rts

.Bitchange:
	move.w	Event_w6(a5),d2		; Toggle bit
	bchg	d2,d0
	rts

;*****************************************************************************
; [ Change Icon event ]
; No registers are restored
;*****************************************************************************
Change_icon:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get coordinates
	move.b	Event_b1(a5),d0
	moveq.l	#0,d1
	move.b	Event_b2(a5),d1
	tst.w	d0			; Event coordinates ?
	bne.s	.Ok
	tst.w	d1
	bne.s	.Ok
	move.w	Current_event_X,d0		; Yes -> Get
	move.w	Current_event_Y,d1
.Ok:	move.w	Event_w6(a5),d2		; Get new icon number
	move.w	Event_w8(a5),d7		; Current map ?
	bne.s	.Do
	move.w	Map_nr,d7			; Yes
.Do:	jsr	Do_change_icon		; Change it
	jsr	Enter_modification		; Save it for posterity
	rts

;*****************************************************************************
; [ Encounter event ]
; No registers are restored
;*****************************************************************************
Encounter:
	lea.l	Current_event_data,a5
	sf	Could_not_flee		; Clear flag
	move.w	Event_w6(a5),Monstergroup_nr	; Set info
	move.w	#-1,Combat_char_index
	move.w	Map_Xcoord,d0		; Get combat background
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	andi.l	#$f0000000,d0
	rol.l	#4,d0
	move.w	d0,Combat_background	; Store
	move.w	Active_member,Previous_active_member	; Save
	jsr	Exit_display		; Fight !
	Push	Module,Combat_Mod
	rts

;*****************************************************************************
; [ Query event ]
; No registers are restored
;*****************************************************************************
Query:
	lea.l	Current_event_data,a5
	sf	Query_result		; Clear result
	moveq.l	#0,d0			; Get query type
	move.b	Event_b1(a5),d0
	cmp.w	#Max_QM_type,d0		; Legal ?
	bpl.s	.Exit
	lsl.w	#2,d0			; Execute query
	move.l	.Ptrs(pc,d0.w),a0
	jsr	(a0)
	tst.b	Event_b2(a5)		; False desired ?
	bne.s	.No
	not.b	Query_result		; Yes -> reverse result
.No:	tst.b	Query_result		; Query true or false ?
	bne.s	.Exit
	move.w	Event_w8(a5),Next_event_nr(a5)	; Negative chain
.Exit:	rts

.Ptrs:	dc.l .Quest,.Event,.Door,.Chest		;  0 -  3
	dc.l .CD,.Party,.Item_carried,.Item_used	;  4 -  7
	dc.l .WD,.Success,.Internal,.Light		;  8 - 11
	dc.l .Direction,.Condition,.Touched,.Word_spoken	; 12 - 15
	dc.l .Alien_nr,.Levitate,.Gold,.Food		; 16 - 19
	dc.l .Seen				; 20

; [ Query routines ]
;   IN : a5 - Pointer to current event data (.l)
; No registers are restored

.Quest:	moveq.l	#Quest_bit_array,d1
	bra	.Do

.Event:	moveq.l	#Event_bit_array,d1
	bra	.Do

.Door:	moveq.l	#Door_bit_array,d1
	bra	.Do

.Chest:	moveq.l	#Chest_bit_array,d1
	bra	.Do

.CD:	moveq.l	#CD_bit_array,d1
	bra	.Do

.WD:	moveq.l	#WD_bit_array,d1

.Do:	move.w	Event_w6(a5),d0		; Get bit number
	moveq.l	#3,d2			; Get bit
	jsr	Access_bit_array
	sne	Query_result
	rts

.Party:
	st	Query_result
	move.w	Event_w6(a5),d0		; Get character number
	lea.l	Member_nrs,a0		; Search party
	moveq.l	#6-1,d7
.Loop1:	cmp.w	(a0)+,d0			; Is this the one ?
	beq.s	.Done
	dbra	d7,.Loop1			; Next member
	sf	Query_result		; No luck
.Done:	rts

; [ Seek x items of type y in the party member's inventories ]
.Item_carried:
	st	Query_result		; Default is luck
	move.w	Event_w6(a5),d0		; Get item number
	moveq.l	#0,d1			; Get required quantity
	move.b	Event_b3(a5),d1
	lea.l	Party_handles,a0		; Search party
	moveq.l	#6-1,d7
.Loop2:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next2
	Get	(a0),a1			; Search inventory
	lea.l	Char_inventory(a1),a1
	moveq.l	#Items_per_char+9-1,d6
.Loop3:	cmp.w	Object_index(a1),d0		; Is this the one ?
	bne.s	.Next3
	moveq.l	#0,d2			; Count down
	move.b	Quantity(a1),d2
	sub.w	d2,d1
	bgt.s	.Next3			; Enough ?
	Free	(a0)			; Yes -> exit
	bra.s	.Exit2
.Next3:	addq.w	#Object_packet_size,a1	; Next item
	dbra	d6,.Loop3
	Free	(a0)
.Next2:	addq.l	#1,a0			; Next party member
	dbra	d7,.Loop2
	sf	Query_result		; No luck
.Exit2:	rts

.Item_used:
	sf	Query_result		; Default is no luck
	tst.b	Using_item		; Using item ?
	beq.s	.Exit3
	sf	Use_item_success		; Clear
	move.w	Event_w6(a5),d0		; Right object ?
	cmp.w	Used_object_index,d0
	bne.s	.Wrong
	st	Query_result		; Yes!
	st	Use_item_success
	move.w	Casting_item_slot,d0	; Destroy
	jsr	Destroy_used_item
	jsr	Exit_Inv2			; Leave inventory
	bra.s	.Exit3
.Wrong:	cmp.w	#-1,Event_w8(a5)		; Negative chain ?
	sne	Use_item_success
.Exit3:	rts

.Success:
	move.b	Success,Query_result	; Copy flag
	rts

.Internal:
	move.w	Event_w6(a5),d0		; Get bit number
	andi.w	#$000f,d0
	move.w	Internal_flags,d1		; Test internal flags
	btst	d0,d1
	sne	Query_result
	rts

.Light:
	move.b	Stygian,Query_result	; Copy flag
	not.b	Query_result		; Invert
	rts

.Direction:
	move.w	Event_w6(a5),d0		; Get direction
	cmp.w	View_direction,d0		; Same ?
	seq	Query_result
	rts

.Condition:
	Get	Dialogue_handle,a0		; Get conditions
	move.w	Body_conditions(a0),d0
	Free	Dialogue_handle
	move.w	Event_w6(a5),d1		; Get bit number
	btst	d1,d0			; Test
	sne	Query_result
	rts

.Touched:
	move.b	Hand_flag,Query_result	; Copy flag
	rts

.Word_spoken:
	sf	Query_result		; Default is no luck
	tst.b	Mouth_flag		; Speaking ?
	beq.s	.Exit4
	move.w	QM_spoken_word,d0		; Yes -> Get spoken word
	cmp.w	#-1,d0			; In dictionary ?
	beq.s	.Exit4
.Yes:	cmp.w	Event_w6(a5),d0		; Right word ?
	bne.s	.Exit4
	st	Query_result		; Yay !
.Exit4:	rts

.Alien_nr:
	move.l	#9999,Maximum_number	; What alien number ?
	clr.l	Minimum_number
	move.w	#65,InputNr_prompt
	st	ObjGoldFood
	Push	Module,InputNr_Mod
	move.l	InputNr_number,d0		; Right number ?
	cmp.w	Event_w6(a5),d0
	seq	Query_result
	rts

.Levitate:
	move.b	Levitation_flag,Query_result	; Copy flag
	rts

.Gold:
	Get	Active_handle,a0		; Get active's gold
	move.w	Gold_coins(a0),d0
	Free	Active_handle
	cmp.w	Event_w6(a5),d0		; Enough ?
	spl	Query_result
	rts

.Food:
	Get	Active_handle,a0		; Get active's food
	move.w	Food_rations(a0),d0
	Free	Active_handle
	cmp.w	Event_w6(a5),d0		; Enough ?
	spl	Query_result
	rts

.Seen:
	move.b	Eye_flag,Query_result	; Copy flag
	rts

;*****************************************************************************
; [ Modify event ]
; No registers are restored
;*****************************************************************************
Modify:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get modify type
	move.b	Event_b1(a5),d0
	cmp.w	#Max_QM_type,d0		; Legal ?
	bpl.s	.Exit
	lsl.w	#2,d0			; Execute modify
	move.l	.Ptrs(pc,d0.w),d0
	beq.s	.Exit
	move.l	d0,a0
	jsr	(a0)
.Exit:	rts

.Ptrs:	dc.l .Quest,.Event,.Door,.Chest	;  0 -  3
	dc.l .CD,0,.Item_carried,0		;  4 -  7
	dc.l .WD,0,.Internal,0		;  8 - 11
	dc.l .Direction,.Condition,0,0	; 12 - 15
	dc.l 0,0,.Gold,.Food		; 16 - 19
	dc.l 0				; 20

; [ Modify routines ]
;   IN : a5 - Pointer to current event data (.l)
; No registers are restored

.Quest:	moveq.l	#Quest_bit_array,d1
	bra	.Do

.Event:	moveq.l	#Event_bit_array,d1
	bra	.Do

.Door:	moveq.l	#Door_bit_array,d1
	bra	.Do

.Chest:	moveq.l	#Chest_bit_array,d1
	bra	.Do

.CD:	moveq.l	#CD_bit_array,d1
	bra	.Do

.Do:	move.w	Event_w6(a5),d0		; Get bit number
	move.b	Event_b2(a5),d2		; Modify bit
	jsr	Access_bit_array
	rts

.WD:	move.w	Event_w6(a5),d0		; Get info
	tst.b	Map_or_dialogue		; Map or dialogue ?
	beq.s	.Map
	moveq.l	#New_words_bit_array,d1	; Dialogue -> new word
	moveq.l	#1,d2
	jsr	Access_bit_array
.Map:	moveq.l	#WD_bit_array,d1		; Modify bit
	move.b	Event_b2(a5),d2
	jsr	Access_bit_array
	rts

; [ Destroy x items of type y in the party member's inventories ]
.Item_carried:
	moveq.l	#0,d1			; Get required number
	move.b	Event_b3(a5),d1
	move.w	Event_w6(a5),d4		; Get item number
	lea.l	Party_handles,a0		; Search party
	moveq.l	#6-1,d7
.Loop1:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next1
	Get	(a0),a1			; Search inventory
	lea.l	Char_inventory(a1),a1
	moveq.l	#1,d2
.Loop2:	cmp.w	Object_index(a1),d4		; Is this the one ?
	bne.s	.Next2
	moveq.l	#0,d3			; Get quantity
	move.b	Quantity(a1),d3
	cmp.w	d3,d1			; Too much ?
	bmi.s	.Too_much
	sub.w	d3,d1			; No
	bra.s	.Do2
.Too_much:	move.w	d1,d3			; Too much
	moveq.l	#0,d1
.Do2:	move.b	(a0),d0			; Remove items
	jsr	Remove_item
	tst.w	d1			; All done ?
	bne.s	.Next2
	Free	(a0)			; Yes -> exit
	bra.s	.Exit2
.Next2:	addq.w	#Object_packet_size,a1	; Next item
	addq.w	#1,d2
	cmp.w	#Items_per_char+9+1,d2
	bmi.s	.Loop2
	Free	(a0)
.Next1:	addq.l	#1,a0			; Next party member
	dbra	d7,.Loop1
.Exit2:	rts

.Internal:
	move.w	Event_w6(a5),d0		; Get bit number
	andi.w	#$000f,d0
	move.w	Internal_flags,d1		; Change internal flags
	jsr	.Change_bit
	move.w	d1,Internal_flags
	rts

.Direction:
	move.w	Event_w6(a5),View_direction	; Set direction
	rts

.Condition:
	Get	Dialogue_handle,a0		; Get conditions
	move.w	Body_conditions(a0),d1
	move.w	Event_w6(a5),d0		; Get bit number
	jsr	.Change_bit		; Change
	move.w	d1,Body_conditions(a0)	; Store
	Free	Dialogue_handle
	rts

.Gold:
	Get	Active_handle,a0
	move.w	Gold_coins(a0),d0		; Get active's gold
	move.w	Event_w6(a5),d1
	cmp.w	d1,d0			; Remove too many ?
	bpl.s	.Ok1
	move.w	d0,d1			; Yes -> Clip
.Ok1:	sub.w	d1,d0			; Remove gold
	move.w	d0,Gold_coins(a0)
	mulu.w	#Gold_weight,d1		; Remove weight
	sub.l	d1,Weight_normal(a0)
	Free	Active_handle
	rts

.Food:
	Get	Active_handle,a0
	move.w	Food_rations(a0),d0		; Get active's food
	move.w	Event_w6(a5),d1
	cmp.w	d1,d0			; Remove too many ?
	bpl.s	.Ok2
	move.w	d0,d1			; Yes -> Clip
.Ok2:	sub.w	d1,d0			; Remove food
	move.w	d0,Food_rations(a0)
	mulu.w	#Food_weight,d1		; Remove weight
	sub.l	d1,Weight_normal(a0)
	Free	Active_handle
	rts

; [ Change bit ]
;   IN : d0 - Bit number (.b)
;        d1 - Value (.w)
;        a5 - Pointer to current event data (.l)
;  OUT : d1 - New value (.w)
; Changed registers : d1,d2
.Change_bit:
	move.b	Event_b2(a5),d2		; Clear ?
	bne.s	.No1
	bclr	d0,d1			; Clear
	bra.s	.Done
.No1:	cmp.b	#1,d2			; Set ?
	bne.s	.No2
	bset	d0,d1			; Set
	bra.s	.Done
.No2:	cmp.b	#2,d2			; Toggle ?
	bne.s	.Done
	bchg	d0,d1			; Toggle
.Done:	rts

;*****************************************************************************
; [ Chance event ]
; No registers are restored
;*****************************************************************************
Chance:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get probe value
	move.b	Event_b1(a5),d0
	jsr	Probe_100			; Probe
	bpl.s	.Exit			; Success ?
	move.w	Event_w8(a5),Next_event_nr(a5)	; Negative chain
.Exit:	rts

;*****************************************************************************
; [ Dialogue action event ]
;   IN : d1 - Value (.w)
;        a2 - Pointer to Dialogue Action event data (.l)
;  OUT : eq - Value is correct
;        ne - Value is not correct
; All registers are restored (!!!)
; Notes :
;   - This is a special event and is handled differently from the others.
;     It is in fact called directly by [ Find_DIA_event ] to determine if
;     this chain should be executed. The event is then executed again, but
;     a dummy entry in { Event_ptrs } ensures that nothing happens.
;*****************************************************************************
Dia_action:
	movem.l	d0/d1/d7/a0,-(sp)
	moveq.l	#0,d7			; Default is OK
	moveq.l	#0,d0			; Get action type
	move.b	Event_b1(a2),d0
	cmp.w	#Max_DIAC,d0		; Legal ?
	bpl.s	.Exit
	lsl.w	#2,d0			; Execute test
	move.l	.Ptrs(pc,d0.w),d0
	beq.s	.Exit
	move.l	d0,a0
	jsr	(a0)
.Exit:	tst.w	d7			; Test result
	movem.l	(sp)+,d0/d1/d7/a0
	rts

.Ptrs:	dc.l .Value,.Item,.Item,.Gold
	dc.l .Food,0,0,0
	dc.l 0

; [ Dialogue action routines ]
;   IN : d1 - Value (.w)
;        a2 - Pointer to current event data (.l)
; No registers are restored

.Value:	cmp.w	#-1,Event_w6(a2)		; Does it matter ?
	beq.s	.Exit1
	cmp.w	Event_w6(a2),d1		; Correct value ?
	sne	d7
.Exit1:	rts

.Item:	cmp.w	#-1,Event_w6(a2)		; Does it matter ?
	beq.s	.Exit2
	Get	Active_handle,a0		; Get object packet address
	lea.l	Char_inventory+Backpack_slots(a0),a0
	mulu.w	#Object_packet_size,d1
	add.w	d1,a0
	move.w	Object_index(a0),d1		; Get object index
	Free	Active_handle
	cmp.w	Event_w6(a2),d1		; Correct item ?
	sne	d7
.Exit2:	rts

.Gold:	cmp.w	#-1,Event_w6(a2)		; Does it matter ?
	beq.s	.Exit3
	cmp.w	Event_w6(a2),d1		; Enough ?
	bmi.s	.Not3
	move.w	Event_w6(a2),Current_DIAC_value	; Yes
	bra.s	.Exit3
.Not3:	move.w	#102,d0			; "Gimme more!"
	jsr	Do_prompt
	st	Not_enough		; Bah!
	st	d7
.Exit3:	rts

.Food:	cmp.w	#-1,Event_w6(a2)		; Does it matter ?
	beq.s	.Exit4
	cmp.w	Event_w6(a2),d1		; Enough ?
	bmi.s	.Not4
	move.w	Event_w6(a2),Current_DIAC_value	; Yes
	bra.s	.Exit4
.Not4:	move.w	#227,d0			; "Gimme more!"
	jsr	Do_prompt
	st	Not_enough		; Bah!
	st	d7
.Exit4:	rts

;*****************************************************************************
; [ Dialogue text event RESULT ]
; No registers are restored
;*****************************************************************************
Dia_text:
	lea.l	Current_event_data,a5	; Get text number
	moveq.l	#0,d0
	move.b	Event_b1(a5),d0
	Get	Dialogue_text_handle,a0	; Display text
	jsr	Do_text
	Free	Dialogue_text_handle
	rts

;*****************************************************************************
; [ Dialogue give event RESULT ]
; No registers are restored
;*****************************************************************************
Dia_give:
	lea.l	Current_event_data,a5
	tst.b	Event_b1(a5)		; Item ?
	bne	.Gold_or_food
	Get	Sold_slots_handle,a0	; Find free slot
	moveq.l	#Items_per_char-1,d7
.Loop:	tst.w	Object_index(a0)
	beq.s	.Found
	addq.w	#Object_packet_size,a0
	dbra	d7,.Loop
	bra	.Done
.Found:	move.l	Object_data_ptr,a1		; Get object data
	move.w	Event_w8(a5),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	move.b	Event_w6+1(a5),Quantity(a0)	; Fill slot
	move.b	Spell_charges(a1),Charges(a0)
	move.b	Enchantment_normal_init(a1),Enchantment_normal(a0)
	move.b	Item_bits_DYNAMIC_init(a1),Item_bits_DYNAMIC(a0)
	move.w	Event_w8(a5),Object_index(a0)
	tst.b	Dialogue_items		; Already some there ?
	beq.s	.Done
	jsr	Update_objects		; Yes -> Update
	jsr	Update_screen
.Done:	Free	Sold_slots_handle		; Exit
	bra.s	.Exit
.Gold_or_food:
	cmp.b	#1,Event_b1(a5)		; Gold ?
	bne	.Food
	Get	Active_handle,a0		; Take this gold
	move.w	Event_w6(a5),d0
	add.w	d0,Gold_coins(a0)
	mulu.w	#Gold_weight,d0
	add.l	d0,Weight_normal(a0)
	Free	Active_handle
	bra.s	.Exit
.Food:	Get	Active_handle,a0		; Take this food
	move.w	Event_w6(a5),d0
	add.w	d0,Food_rations(a0)
	mulu.w	#Food_weight,d0
	add.l	d0,Weight_normal(a0)
	Free	Active_handle
.Exit:	rts

;*****************************************************************************
; [ Requester event ]
; No registers are restored
;*****************************************************************************
Requester:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get text number
	move.b	Event_b1(a5),d0
	Get	Current_event_text_handle,a0	; Find text
	jsr	Find_large_text
	lea.l	Text_list,a1
	move.l	a0,(a1)
	clr.l	4(a1)
	move.l	a1,ReqText_ptr		; Set text
	st	Req_NO			; Request
	Push	Module,Req_Mod
	Free	Current_event_text_handle
	tst.b	Req_result		; Get result
	bne.s	.Exit
	move.w	Event_w8(a5),Next_event_nr(a5)	; Negative chain
.Exit:	rts

;*****************************************************************************
; [ Sound event ]
; No registers are restored
;*****************************************************************************
Sound:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get music / effect number
	move.b	Event_b2(a5),d0
	tst.b	Event_b1(a5)		; Music or sound effect ?
	bne.s	.FX
	cmp.b	#-1,d0			; Music -> Reset map music ?
	bne.s	.No
	clr.w	Current_map_music		; Yes
	jsr	Set_map_music		; Start
	bra.s	.Exit
.No:	move.w	d0,Current_map_music	; No
	moveq.l	#0,d1			; Start new music
	jsr	Set_music
	bra.s	.Exit
.FX:	nop				; Not implemented
.Exit:	rts

;*****************************************************************************
; [ Create transport event ]
; No registers are restored
;*****************************************************************************
Create_transport:
	lea.l	Current_event_data,a5
	lea.l	Trans_data,a0		; Seek free slot
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a0)		; Anything there ?
	bne.s	.Next
	move.w	Event_w6(a5),Trans_map_nr(a0)	; Set map number
	move.b	Event_b1(a5),Trans_X(a0)	; Set coordinates
	move.b	Event_b2(a5),Trans_Y(a0)
	move.b	Event_b3(a5),Trans_type(a0)	; Set transport type
	bra.s	.Exit
.Next:	addq.w	#Trans_data_size,a0	; Next transport
	dbra	d7,.Loop
.Exit:	rts

;*****************************************************************************
; [ Dialogue Execute event ]
; No registers are restored
;*****************************************************************************
Dia_execute:
	move.w	Current_DIAC,d0		; Get parameters
	move.w	Current_DIAC_value,d1
	lsl.w	#2,d0			; Execute action
	move.l	.Ptrs(pc,d0.w),d0
	beq.s	.Exit
	move.l	d0,a0
	jsr	(a0)
.Exit:	rts

.Ptrs:	dc.l 0,0,.Item,.Gold
	dc.l .Food,.Join,.Leave,0
	dc.l 0

; [ Dialogue action execute routines ]
; No registers are restored

;   IN : d1 - Slot number {0...23} (.w)
.Item:
	jsr	Dissolve_item_at_portrait	; Poof!
	st	Item_accepted		; Set
	move.b	DIAC_victim_handle,d0	; Remove item
	move.w	d1,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jmp	Remove_item

;   IN : d1 - Number of gold coins (.w)
.Gold:
	Get	DIAC_victim_handle,a0
	cmp.w	Gold_coins(a0),d1		; Enough ?
	bls.s	.Ok1
	move.w	Gold_coins(a0),d1		; No -> clip
.Ok1:	sub.w	d1,Gold_coins(a0)		; Remove gold
	mulu.w	#Gold_weight,d1
	sub.l	d1,Weight_normal(a0)
	Free	DIAC_victim_handle
	rts

;   IN : d1 - Number of food rations (.w)
.Food:
	Get	DIAC_victim_handle,a0
	cmp.w	Food_rations(a0),d1		; Enough ?
	bls.s	.Ok2
	move.w	Food_rations(a0),d1		; No -> clip
.Ok2:	sub.w	d1,Food_rations(a0)		; Remove food
	mulu.w	#Food_weight,d1
	sub.l	d1,Weight_normal(a0)
	Free	DIAC_victim_handle
	rts

; No data required
.Join:
	tst.b	NPC_or_member		; Just checking
	bne.s	.Exit1
	st	Joined			; Yay !
	jsr	Add_party_member
.Exit1:	rts

; No data required
.Leave:
	tst.b	NPC_or_member		; Just checking
	beq.s	.Exit2
	move.w	Dialogue_NPC_index,d7	; Go !
	jsr	Remove_party_member
	st	Abort_dialogue		; Abort !
	st	Left			; Indicate
	Pop	Module
.Exit2:	rts

;*****************************************************************************
; [ Remove Party Member event ]
; No registers are restored
;*****************************************************************************
Remove_member:
	lea.l	Current_event_data,a5
; ---------- Search character in party ------------
	moveq.l	#0,d0			; Get party character number
	move.b	Event_b1(a5),d0
	lea.l	Member_nrs+2,a0		; Search other party members
	moveq.l	#2,d7
	moveq.l	#5-1,d6
.Loop1:	cmp.w	(a0)+,d0			; Is this the one ?
	beq.s	.Found
	addq.w	#1,d7			; No -> Next
	dbra	d6,.Loop1
	sf	Success			; No luck!
	bra	.Exit
.Found:	st	Success			; Yay!
	lea.l	Party_handles,a0		; Get character data
	move.b	-1(a0,d7.w),d6
	Get	d6,a0
	lea.l	Char_inventory(a0),a0
	subq.l	#8,sp			; FIX: Temporary object packet
	move.l	sp,a1
; ---------- Dump body items ----------------------
	moveq.l	#0,d0			; Get body chest number
	move.b	Event_b2(a5),d0
	addq.w	#1,d0			; !!!
	move.w	d0,d5
	moveq.l	#Chest_data_file,d1		; Load chest data
	jsr	Load_subfile
	move.b	d0,d4
	moveq.l	#1,d2			; Dump body items
	moveq.l	#9-1,d1
.Loop2:	tst.w	Object_index(a0)		; Anything there ?
	beq.s	.Next2
	Copy_packet a0,a1			; FIX: Remove the item from the
	move.b	d6,d0			;  character first (Auto_move_to_INV
	jsr	Remove_item		;  destroys the source packet, so
	exg	a0,a1			;  Remove_item used Object_index 0)
	move.b	d4,d0			; Put in chest
	jsr	Auto_move_to_INV
	exg	a0,a1
.Next2:	addq.w	#1,d2			; Next body item
	addq.w	#Object_packet_size,a0
	dbra	d1,.Loop2			; FIX: Was dbra d7 (the member number)
	move.l	a0,-(sp)
	Get	d4,a0			; Save chest
	move.w	d5,d0
	moveq.l	#Chest_data_file,d1		; FIX: d1 was not set
	jsr	Save_subfile
	move.b	d4,d0			; Free memory
	jsr	Free_pointer
	jsr	Free_memory	
	move.l	(sp)+,a0
; ---------- Dump backpack items ------------------
	moveq.l	#0,d0			; Get backpack chest number
	move.b	Event_b3(a5),d0
	addq.w	#1,d0			; !!!
	move.w	d0,d5
	moveq.l	#Chest_data_file,d1		; Load chest data
	jsr	Load_subfile
	move.b	d0,d4
	moveq.l	#9+1,d2			; Dump backpack items
					; FIX: Was 1 (backpack slots are 10...33)
	moveq.l	#Items_per_char-1,d1
.Loop3:	tst.w	Object_index(a0)		; Anything there ?
	beq.s	.Next3
	Copy_packet a0,a1			; FIX: See above
	move.b	d6,d0
	moveq.l	#0,d3
	move.b	Quantity(a0),d3
	jsr	Remove_item
	exg	a0,a1
	move.b	d4,d0			; Put in chest
	jsr	Auto_move_to_INV
	exg	a0,a1
.Next3:	addq.w	#1,d2			; Next backpack item
	addq.w	#Object_packet_size,a0
	dbra	d1,.Loop3			; FIX: Was dbra d7 (the member number)
	Get	d4,a0			; Save chest
	move.w	d5,d0
	moveq.l	#Chest_data_file,d1		; FIX: d1 was not set
	jsr	Save_subfile
	move.b	d4,d0			; Free memory
	jsr	Free_pointer
	jsr	Free_memory	
	Free	d6
	addq.l	#8,sp			; FIX: Remove temporary packet
; ---------- Remove party member ------------------
	jsr	Remove_party_member		; Goodbye !
.Exit:	rts

;*****************************************************************************
; [ Lockpick breaks ]
;   IN : d0 - X-coordinate of lock (.w)
;        d1 - Y-coordinate of lock (.w)
;        d2 - Slot number (1...24)
;        d3 - Prompt number (.w)
; All registers are restored
;*****************************************************************************
Lockpick_breaks:
	movem.l	d0-d4/d6/d7/a0/a1,-(sp)
	move.w	d0,Lock_X			; Save input
	move.w	d1,Lock_Y
	move.w	d2,Moved_slot
	move.w	d3,Moved_prompt
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
	tst.w	d0			; Anything there ?
	beq	.Exit
	move.l	Object_data_ptr,a0		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a0
	moveq.l	#0,d0			; Get object graphic address
	move.b	Item_pic(a0),d0
	mulu.w	#Icon_size,d0
	move.l	d0,a1			; Save
	lea.l	Move_key_HDOB,a0		; Initialize HDOB
	move.w	Slot_X,HDOB_drawX(a0)
	move.w	Slot_Y,HDOB_drawY(a0)
	move.l	d0,HDOB_offset(a0)
	move.b	Object_gfx_handle,HDOB_gfx_handle(a0)
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
	move.w	Lock_X,d0			; Move lockpick to lock
	move.w	Lock_Y,d1
	moveq.l	#4,d2
	jsr	Move_HDOB
	lea.l	Move_key_HDOB,a0		; Vibrate lockpick
	moveq.l	#8,d0
	jsr	Vibrate_HDOB
	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	move.w	HDOB_drawX(a0),d2
	move.w	HDOB_drawY(a0),d1
	jsr	Remove_HDOB
	Get	Object_gfx_handle,a0	; Boom !
	add.l	a1,a0
	move.w	d2,d0
	moveq.l	#0,d4
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Explode_bitmap
	Free	Object_gfx_handle
	move.w	Moved_prompt,d0		; Did it !
	jsr	Do_prompt
.Exit:	movem.l	(sp)+,d0-d4/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Lockpick is used successfully ]
;   IN : d0 - X-coordinate of lock (.w)
;        d1 - Y-coordinate of lock (.w)
;        d2 - Slot number (1...24)
;        d3 - Prompt number (.w)
; All registers are restored
;*****************************************************************************
Lockpick_works:
	movem.l	d0-d4/a0,-(sp)
	move.w	d0,Lock_X			; Save input
	move.w	d1,Lock_Y
	move.w	d2,Moved_slot
	move.w	d3,Moved_prompt
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
	move.l	d0,HDOB_offset(a0)
	move.b	Object_gfx_handle,HDOB_gfx_handle(a0)
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
	move.w	Lock_X,d0			; Move lockpick to lock
	move.w	Lock_Y,d1
	moveq.l	#4,d2
	jsr	Move_HDOB
	lea.l	Move_key_HDOB,a0		; Vibrate lockpick
	moveq.l	#8,d0
	jsr	Vibrate_HDOB
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
	move.w	Moved_prompt,d0		; It worked !
	jsr	Do_prompt
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Key fits in door or chest, and is not destroyed ]
;   IN : d0 - X-coordinate of lock (.w)
;        d1 - Y-coordinate of lock (.w)
;        d2 - Slot number (1...24)
;        d3 - Prompt number (.w)
; All registers are restored
;*****************************************************************************
Key_is_not_destroyed:
	movem.l	d0-d4/a0,-(sp)
	move.w	d0,Lock_X			; Save input
	move.w	d1,Lock_Y
	move.w	d2,Moved_slot
	move.w	d3,Moved_prompt
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
	move.w	Lock_X,d0			; Move key to lock
	move.w	Lock_Y,d1
	moveq.l	#4,d2
	jsr	Move_HDOB
	lea.l	Move_key_HDOB,a0		; Vibrate key
	moveq.l	#8,d0
	jsr	Vibrate_HDOB
	move.w	Moved_prompt,d0		; Did it !
	jsr	Do_prompt
	move.w	Slot_X,d0			; Move key back to slot
	move.w	Slot_Y,d1
	moveq.l	#6,d2			;  (quickly !)
	jsr	Move_HDOB
	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	jsr	Update_screen
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Key fits in door or chest, and is destroyed ]
;   IN : d0 - X-coordinate of lock (.w)
;        d1 - Y-coordinate of lock (.w)
;        d2 - Slot number (1...24)
;        d3 - Prompt number (.w)
; All registers are restored
;*****************************************************************************
Key_is_destroyed:
	movem.l	d0-d4/d6/d7/a0/a1,-(sp)
	move.w	d0,Lock_X			; Save input
	move.w	d1,Lock_Y
	move.w	d2,Moved_slot
	move.w	d3,Moved_prompt
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
	move.w	Lock_X,d0			; Move key to lock
	move.w	Lock_Y,d1
	moveq.l	#4,d2
	jsr	Move_HDOB
	lea.l	Move_key_HDOB,a0		; Vibrate key
	moveq.l	#8,d0
	jsr	Vibrate_HDOB
	move.w	Moved_prompt,d0		; Did it !
	jsr	Do_prompt
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
.Exit:	movem.l	(sp)+,d0-d4/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Key does not fit in door or chest ]
;   IN : d0 - X-coordinate of lock (.w)
;        d1 - Y-coordinate of lock (.w)
;        d2 - Slot number (1...24)
;        d3 - Prompt number (.w)
; All registers are restored
;*****************************************************************************
Key_does_not_fit:
	movem.l	d0-d4/a0,-(sp)
	move.w	d0,Lock_X			; Save input
	move.w	d1,Lock_Y
	move.w	d2,Moved_slot
	move.w	d3,Moved_prompt
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
	move.w	Lock_X,d0			; Move key to lock
	move.w	Lock_Y,d1
	moveq.l	#4,d2
	jsr	Move_HDOB
	moveq.l	#10,d0			; Wait
	jsr	Delay
	lea.l	Move_key_HDOB,a0		; Vibrate key
	moveq.l	#8,d0
	jsr	Vibrate_HDOB
	move.w	Moved_prompt,d0		; Wrong item !
	jsr	Do_prompt
	move.w	Slot_X,d0			; Move key back to slot
	move.w	Slot_Y,d1
	moveq.l	#6,d2			;  (quickly !)
	jsr	Move_HDOB
	lea.l	Move_key_HDOB,a0		; Destroy HDOB
	jsr	Remove_HDOB
	jsr	Update_screen
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Move_key_HDOB:
	dc.w 0,0
	dc.w 1,16,5,0
	dc.l 0
	dc.b 0,0
	dcb.w 6,0
Dissolve_HDOB:
	dc.w 0,0
	dc.w 1,16,3,0
	dc.l 0
	dc.b 0,0
	dcb.w 6,0
Event_ptrs:
	dc.l Map_exit,Door,Item_found,Show_pictxt,Spinner
	dc.l Event_trap,Anti_magic,Riddle_mouth,Datachange,Change_icon
	dc.l Encounter,Places,Query,Modify,Chance
	dc.l Dumdum,Dia_text,Dia_give,Requester,Sound
	dc.l Dumdum,Create_transport,Dia_execute,Remove_member
Event_messages:
	dc.b 0,0,0,0,58
	dc.b 59,0,0,0,0
	dc.b 0,0,0,0,0
	dc.b 0,0,0,0,0
	dc.b 0,0,0,0
	even

Door_CIL:	dc.w Pick_lock_cicon,Use_item_cicon,Exit_cicon
	dc.w Find_traps_cicon,0,0
	dc.w Disarm_traps_cicon,0,0
	dc.l Pick_lock_DOOR,Use_item_DOOR,Door_Exit
	dc.l Find_trap_DOOR,0,0
	dc.l Disarm_trap_DOOR,0,0
	dc.l Door_CIL_evaluate
RiddleM_CIL:
	dc.w 0,0,Exit_cicon
	dc.w 0,0,0
	dc.w Talk_cicon,0,Listen_cicon
	dc.l 0,0,Basic_exit
	dc.l 0,0,0
	dc.l Answer_riddleM,0,Ask_riddleM
	dc.l 0
ClosedChest_CIL:
	dc.w Pick_lock_cicon,Use_item_cicon,Exit_cicon
	dc.w Find_traps_cicon,0,0
	dc.w Disarm_traps_cicon,0,0
	dc.l Pick_lock_CHEST,Use_item_CHEST,Door_Exit
	dc.l Find_trap_DOOR,0,0
	dc.l Disarm_trap_DOOR,0,0
	dc.l Door_CIL_evaluate
OpenedChest_CIL:
	dc.w 0,0,Exit_cicon
	dc.w 0,Divide_gold_cicon,Divide_food_cicon
	dc.w View_item_cicon,Transfer_gold_cicon,Transfer_food_cicon
	dc.l 0,0,Door_Exit
	dc.l 0,Divide_gold_CHEST,Divide_food_CHEST
	dc.l View_item_LAY3,Transfer_gold_CHEST,Transfer_food_CHEST
	dc.l OpenedChest_CIL_evaluate
