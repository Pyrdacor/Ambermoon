; Icon actions
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
; [ Re-evaluate second CIL ]
;   IN : a0 - Pointer to CIL (.l)
; No registers are restored
;*****************************************************************************
Second_CIL_evaluate:
	Get	Active_handle,a1
	Get	Mapdata_handle,a2		; Get map bits
	move.w	Map_special(a2),d7
	Free	Mapdata_handle
; --------- Active character blind ? --------------
	move.w	Body_conditions(a1),d0	; Well ?
	btst	#Blind,d0
	beq.s	.Ok
	bset	#7,(a0)			; Disable	{Eye}
.Ok:	LOCAL
; --------- Can the party change travel-mode ? ----
	tst.b	Show_trans		; Show travel-modes ?
	beq	.Off
	move.w	Travel_mode,d0		; Up or off ?
	move.w	#Get_off_mask,d1
	btst	d0,d1
	bne	.Get_up
	move.l	Current_location_status,d0	; Blocked ?
	btst	#Way_blocked_bit,d0
	bne.s	.Off
	btst	#Blocked_foot_bit,d0	; Blocked for foot ?
	bne.s	.On
	btst	#Blocked_swimming_bit,d0	; Blocked for swimming ?
	beq.s	.Off
.On:	jsr	Seek_transport_HERE		; Already a transport here ?
	tst.w	d0
	bne.s	.Off
	bra.s	.Ok
.Get_up:	jsr	Seek_transport_HERE		; Any transport here ?
	tst.w	d0
	bne.s	.Ok
.Off:	bset	#7,6(a0)			; Disable {Change travel-mode}
.Ok:	LOCAL
; --------- Magic allowed ? -----------------------
	tst.b	Spell_class_counter(a1)	; Any spell classes	?
	beq.s	.Off
	btst	#Magic_bit,d7		; Magic allowed here ?
	bne.s	.Ok
.Off:	bset	#7,8(a0)			; Disable	{Use magic}
.Ok:	LOCAL
	Free	Active_handle
; --------- Can the party camp here ? -------------
	btst	#Camp_bit,d7		; Well ?
	beq	.No_camp
	move.w	Travel_mode,d0		; Travelmode OK ?
	move.w	#Camp_mask,d1
	bset	d0,d1
	bne	.Ok
.No_camp:	bset	#7,10(a0)			; Disable	{Camp}
.Ok:	LOCAL
; ---------- Can the party use the auto-mapper ? --
	cmpi.b	#Map_3D,Current_map_type	; 3D map ?
	bpl.s	.Exit
	bset	#7,12(a0)			; Disable	{Automapper}
.Exit:	rts

;*****************************************************************************
; [ Map second CIL actions ]
;*****************************************************************************

	FINGERPRINT

; ********** Eye **********************************
Eye_action:
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl	.3D_map
	move.l	#Look,EHM_ptr		; 2D -> Select
	Push	Module,Eye_Mod
	bra.s	.Exit
.3D_map:	move.w	Map_Xcoord,d0		; 3D
	move.w	Map_Ycoord,d1
	jsr	Look			; Look ?
	bne.s	.Exit
	jsr	Get_coordinates_in_front	; No
	jsr	Look			; Look ?
.Exit:	rts

; ********** Hand *********************************
Hand_action:
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl	.3D_map
	move.l	#Touch,EHM_ptr		; 2D -> Select
	Push	Module,Hand_Mod
	bra.s	.Exit
.3D_map:	move.w	Map_Xcoord,d0		; 3D
	move.w	Map_Ycoord,d1
	jsr	Touch			; Touch ?
	bne.s	.Exit
	jsr	Get_coordinates_in_front	; No
	jsr	Touch			; Touch ?
.Exit:	rts

; ********** Mouth ********************************
Mouth_action:
	cmpi.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl	.3D_map
	move.l	#Talk_2D,EHM_ptr		; 2D -> Select
	Push	Module,Mouth_Mod
	bra.s	.Exit
.3D_map:	move.w	Map_Xcoord,d0		; 3D
	move.w	Map_Ycoord,d1
	jsr	Talk			; Talk ?
	bne.s	.Exit
	jsr	Get_coordinates_in_front	; No
	jsr	Talk			; Talk ?
	bne.s	.Exit
	jsr	Talk_to_yourself		; Madness
.Exit:	rts

; ********** Change travel-mode *******************
Change_travel_mode:
	move.w	Travel_mode,d0		; Get travel mode
	cmp.w	#On_foot,d0		; On foot now ?
	beq	.Up
	cmp.w	#Swimming,d0		; Or swimming ?
	beq	.Up
	btst	d0,#Stationary_mask&$ff	; Leave transport ?
					; BUILD: "&$ff" added. BTST with an immediate operand
					;  only tests bits 0-7 (bit number modulo 8); the
					;  original assembler truncated the mask silently.
	beq	.No
	lea.l	Trans_data,a0		; Seek free slot
	moveq.l	#Max_transports-1,d7
.Loop:	tst.b	Trans_type(a0)		; Anything there ?
	bne.s	.Next
	move.w	Map_nr,Trans_map_nr(a0)	; Set map number
	move.w	Map_Xcoord,d1		; Set coordinates
	move.b	d1,Trans_X(a0)
	move.w	Map_Ycoord,d1
	move.b	d1,Trans_Y(a0)
	move.b	d0,Trans_type(a0)		; Set transport type
	bra.s	.No
.Next:	addq.w	#Trans_data_size,a0	; Next transport
	dbra	d7,.Loop
.No:	move.w	d0,d1			; Save
	moveq.l	#On_foot,d0		; Back on foot
	jsr	Set_new_travel_mode
	cmp.w	#Giant_eagle,d1		; Was eagle ?
	bne.s	.No_eagle
	jsr	Show_eagle_flying_away	; Yes -> Show
.No_eagle:	jsr	Game_after_move		; Maybe something happens
	jsr	Event_handler
	bra.s	.Exit
.Up:	jsr	Seek_transport_HERE		; Get on what ?
	tst.w	d0			; Nothing ?!
	beq.s	.Exit			;  (shouldn't occur)
	lea.l	Trans_data,a0		; Remove transport
	mulu.w	#Trans_data_size,d1
	clr.b	Trans_type(a0,d1.w)
	jsr	Set_new_travel_mode		; Do it !
.Exit:	rts

; ********** Cast spell ***************************
Cast_spell:
	Get	Active_handle,a0		; Get spell classes
	move.b	Spell_class_counter(a0),d0
	Free	Active_handle
	moveq.l	#4-1,d7			; Find spell class
.Loop:	btst	d7,d0			; Got it ?
	beq.s	.Next
	move.w	d7,Selected_class		; Yes -> Store
	bra.s	.Found
.Next:	dbra	d7,.Loop			; No -> Next spell class
	bra.s	.Exit
.Found:	Push	Module,SpSelW_Mod		; Select spell
	tst.w	Selected_spell		; Any selected ?
	beq.s	.Exit
	sf	Magic_object_flag		; Do magic !
	move.b	Active_handle,Casting_handle
	move.w	Active_member,Casting_member
	jsr	Do_magic
.Exit:	rts

; ********** Camp screen **************************
Camp:
	tst.b	Big_brother_flag		; Being watched ?
	beq.s	.No
	moveq.l	#39,d0			; Yes -> "Fool!"
	jsr	Do_prompt_window
	bra.s	.Exit
.No:	jsr	Exit_display		; No -> Do
	Push	Module,Camp_Mod
.Exit:	rts

; ********** Automapper screen ********************
Automapper:
	moveq.l	#0,d0			; Default is off
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	bne.s	.No
	move.b	#%00001111,d0		; Yes
	bra.s	.Do
.No:	Get	Mapdata_handle,a0		; Possible ?
	move.w	Map_special(a0),d1
	Free	Mapdata_handle
	btst	#View_map_bit,d1
	bne.s	.Yes
	move.w	#289,d0			; No -> "Tough luck"
	jsr	Do_prompt_window
	bra.s	.Exit
.Yes:	tst.w	Spell_6_duration		; Special spell on ?
	beq.s	.Do
	move.b	#%00001111,d0		; Yes
.Do:	move.b	d0,Automap_function
	jsr	Exit_display		; Do
	Push	Module,Automap_Mod
.Exit:	rts

; ********** Battle order screen ******************
Battle_order:
	jsr	Exit_display		; Do
	lea.l	BattleOrder_Mod,a0
	jmp	Push_Module

; ********** Options menu *************************
Options_menu:
	lea.l	Options_Mod,a0		; Do
	jmp	Push_Module

;*****************************************************************************
; [ Show giant eagle flying away ]
; All registers are restored
;*****************************************************************************
Show_eagle_flying_away:
	movem.l	d0/d1/d7/a0,-(sp)
	tst.b	Stygian			; Darkness ?
	bne	.Exit
	jsr	Update_display		; No -> Show party on foot
	Push	CA,Map2D_L2
	lea.l	Giant_eagle_shape,a0	; Make fake handle
	jsr	Create_fake_handle
	move.b	d0,d7
	move.w	Mapbuf_X,d0		; Get start coordinates
	lsl.w	#4,d0
	add.w	#Map2D_X-8,d0
	move.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y-8,d1
	lea.l	Giant_eagle_HDOB,a0		; Set coordinates
	move.w	d0,HDOB_drawX(a0)
	move.w	d1,HDOB_drawY(a0)
	move.b	d7,HDOB_gfx_handle(a0)	; Set handle
	jsr	Add_HDOB			; Initialize
	jsr	Update_screen
	moveq.l	#25-1,d7
.Loop:	move.w	d0,HDOB_drawX(a0)		; Set new coordinates
	move.w	d1,HDOB_drawY(a0)
	jsr	Switch_screens		; Show
	addq.w	#4,d0			; Fly away
	subq.w	#1,d1
	dbra	d7,.Loop
	jsr	Remove_HDOB		; Exit
	jsr	Update_screen
	move.b	HDOB_gfx_handle(a0),d0
	jsr	Destroy_fake_handle
	Pop	CA
.Exit:	movem.l	(sp)+,d0/d1/d7/a0
	rts

;*****************************************************************************
; [ Get coordinates in front of the player ]
;  OUT : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
; Changed registers : d0,d1
;*****************************************************************************
Get_coordinates_in_front:
	movem.l	d2/d3/a0,-(sp)
	move.w	Map_Xcoord,d0		; Get current coordinates
	move.w	Map_Ycoord,d1
	cmp.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl.s	.3D
	move.w	View_direction,d2		; 2D
	jsr	Move_in_direction		; Get
	bra.s	.Exit
.3D:	lea.l	Sinus_table,a0		; 3D -> Along vector
	move.w	Y_angle,d1
	andi.w	#slang-1,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d0		; Sine
	addi.w	#slang/2,d1
	andi.w	#slang*2-1,d1
	move.w	0(a0,d1.w),d1		; Cosine
	muls.w	#patt_size,d0		; To next map square
	muls.w	#patt_size,d1
	asl.l	#2,d0			; 16 bit nachkomma !
	asl.l	#2,d1
	move.l	Player_X,d2		; Move
	move.l	Player_Y,d3
	sub.l	d0,d2
	add.l	d1,d3
	move.l	d2,d0
	move.l	d3,d1
	swap	d0			; Get map coordinates
	swap	d1
	jsr	Dungeon_to_map
.Exit:	movem.l	(sp)+,d2/d3/a0
	rts

;*****************************************************************************
; [ Switch to 2D action mode ]
; No registers are restored
;*****************************************************************************
Mouse_action_on:
	jsr	Wait_4_unclick
	move.l	#Action_2D,EHM_ptr
	lea.l	Action2D_Mod,a0
	jmp	Push_Module

Action2D_switch:
	move.w	Mouse_X,d0		; Determine relative map
	move.w	Mouse_Y,d1		;  coordinates
	subi.w	#Map2D_X,d0
	subi.w	#Map2D_Y,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	sub.w	Mapbuf_X,d0
	sub.w	Mapbuf_Y,d1
	addq.w	#1,d0
	addq.w	#2,d1
	cmp.w	#2,d0			; In Eye area ?
	bhi.s	.Mouth
	cmp.w	#3,d1
	bhi.s	.Mouth
	lea.l	EyeMouth_Mptr,a0		; Yes
	jsr	Change_Mptr
	bra.s	.Exit
.Mouth:	lea.l	Mouth_Mptr,a0		; No
	jsr	Change_Mptr
.Exit:	rts

;*****************************************************************************
; [ Determine map coordinates under mouse, process & exit ]
; No registers are restored
;*****************************************************************************
EHM_clicked:
	move.w	Mouse_X,d0		; Determine map coordinates
	move.w	Mouse_Y,d1
	subi.w	#Map2D_X,d0
	subi.w	#Map2D_Y,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	sub.w	Mapbuf_X,d0
	sub.w	Mapbuf_Y,d1
	add.w	Map_Xcoord,d0
	add.w	Map_Ycoord,d1
	jsr	Wait_4_unclick		; Exit
	Pop	Module
	move.l	EHM_ptr,a0		; Process
	jmp	(a0)

;*****************************************************************************
; [ Action in 2D maps ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
Action_2D:
	jsr	Talk			; Talk ?
	bne.s	.Exit
	move.w	d0,d2			; No -> In look range ?
	sub.w	Map_Xcoord,d2
	addq.w	#1,d2
	cmp.w	#2,d2
	bhi.s	.Exit
	move.w	d1,d2
	sub.w	Map_Ycoord,d2
	addq.w	#2,d2
	cmp.w	#3,d2
	bhi.s	.Exit
	jsr	Look			; Yes -> Look ?
.Exit:	rts

;*****************************************************************************
; [ 2D map - Eye action ModInit ]
; No registers are restored
;*****************************************************************************
Eye_ModInit:
	lea.l	Made_area,a0		; Calculate mouse area
	move.w	Mapbuf_X,d0		; X
	subq.w	#1,d0
	lsl.w	#4,d0
	addi.w	#Map2D_X+7,d0
	move.w	d0,d1
	cmpi.w	#Map2D_X,d0		; Left Ok	?
	bpl.s	.Left_Ok
	move.w	#Map2D_X+7,d0
.Left_Ok:
	move.w	d0,MA_X1(a0)
	addi.w	#48-15,d1
	cmpi.w	#Map2D_X+(Mapbuf_width*16),d1	; Right Ok ?
	bmi.s	.Right_Ok
	move.w	#Map2D_X+(Mapbuf_width*16)-8,d1
.Right_Ok:
	move.w	d1,MA_X2(a0)
	move.w	Mapbuf_Y,d0		; Y
	subq.w	#2,d0			; 1 more for higher person
	lsl.w	#4,d0
	addi.w	#Map2D_Y+7,d0
	move.w	d0,d1
	cmpi.w	#Map2D_Y,d0		; Top Ok ?
	bpl.s	.Top_Ok
	move.w	#Map2D_Y+7,d0
.Top_Ok:
	move.w	d0,MA_Y1(a0)
	addi.w	#64-15,d1
	cmpi.w	#Map2D_Y+(Mapbuf_height*16),d1	; Bottom Ok ?
	bmi.s	.Bottom_Ok
	move.w	#Map2D_Y+(Mapbuf_height*16)-8,d1
.Bottom_Ok:
	move.w	d1,MA_Y2(a0)
	rts

;*****************************************************************************
; [ 2D map - Mouth action ModInit ]
; No registers are restored
;*****************************************************************************
Mouth_ModInit:
	lea.l	Made_area,a0		; Calculate mouse area
	move.w	Mapbuf_X,d0		; X
	subq.w	#1,d0
	lsl.w	#4,d0
	opt	o5-				; (not optimized by the original assembler)
	addi.w	#Map2D_X-9,d0
	opt	o5+
	move.w	d0,d1
	cmpi.w	#Map2D_X,d0		; Left Ok	?
	bpl.s	.Left_Ok
	move.w	#Map2D_X+7,d0
.Left_Ok:
	move.w	d0,MA_X1(a0)
	addi.w	#80-15,d1
	cmpi.w	#Map2D_X+(Mapbuf_width*16),d1	; Right Ok ?
	bmi.s	.Right_Ok
	move.w	#Map2D_X+(Mapbuf_width*16)-8,d1
.Right_Ok:
	move.w	d1,MA_X2(a0)
	move.w	Mapbuf_Y,d0		; Y
	subq.w	#2,d0			; 1 more for higher person
	lsl.w	#4,d0
	addi.w	#Map2D_Y-9,d0
	move.w	d0,d1
	cmpi.w	#Map2D_Y,d0		; Top Ok ?
	bpl.s	.Top_Ok
	move.w	#Map2D_Y+7,d0
.Top_Ok:
	move.w	d0,MA_Y1(a0)
	addi.w	#80-15,d1
	cmpi.w	#Map2D_Y+(Mapbuf_height*16),d1	; Bottom Ok ?
	bmi.s	.Bottom_Ok
	move.w	#Map2D_Y+(Mapbuf_height*16)-8,d1
.Bottom_Ok:
	move.w	d1,MA_Y2(a0)
	rts

;*****************************************************************************
; [ Look ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : eq - No luck
;        ne - I saw something
; All registers are restored
;*****************************************************************************
Look:
	movem.l	d0/d1/d5-d7/a0,-(sp)
	moveq.l	#0,d5			; Default is no luck
	cmpi.b	#World_2D,Current_map_type	; 2D wilderness ?
	beq	.No_NPC
	lea.l	VNPC_data,a0		; Check NPC's
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq	.Next
	btst	d7,d6			; Deleted	?
	bne	.Next
	cmp.w	VMap_X(a0),d0		; Right coordinates	?
	bne	.Next
	cmp.w	VMap_Y(a0),d1
	beq.s	.Found
	cmp.b	#Map_3D,Current_map_type	; 2D map ?
	bpl	.Next
	btst	#3,NPC_status_bits(a0)	; NPC graphics ?
	bne	.Next
	move.w	d1,d2			; Clicking on head ?
	addq.w	#1,d2
	cmp.w	VMap_Y(a0),d2
	bne	.Next
.Found:	move.b	NPC_status_bits(a0),d2	; Get NPC type
	moveq.l	#3,d3
	and.b	d2,d3
	cmp.b	#Monster_type,d3		; Object or monster ?
	bpl	.No_NPC
	btst	#4,d2			; Short dialogue ?
	bne	.No_NPC
	jsr	Load_NPC_data		; Load data
	Get	Dialogue_handle,a0		; Get text block number
	move.w	Description_text_nr(a0),d0
	Free	Dialogue_handle
	cmp.w	#-1,d0			; Any text ?
	beq.s	.No
	Get	Dialogue_text_handle,a0	; Yes -> describe
	jsr	Do_text_window
	Free	Dialogue_text_handle
	moveq.l	#-1,d5			; Yay!
.No:	jsr	Destroy_NPC_data		; Remove data
	bra	.Exit
.Next:	lea.l	VNPC_data_size(a0),a0	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi	.Loop
.No_NPC:	jsr	Handle_visible_events	; Look for events
	sne	d5
.Exit:	tst.w	d5			; Well ?
	movem.l	(sp)+,d0/d1/d5-d7/a0
	rts

;*****************************************************************************
; [ Handle visible events ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : eq - No event was seen
;        ne - Some event was seen
; All registers are restored
;*****************************************************************************
Handle_visible_events:
	movem.l	d0/d1/d7,-(sp)
	moveq.l	#0,d7			; Default is no luck
	jsr	Find_event		; Find event
	bmi.s	.Exit			; Any there ?
	jsr	Check_event_save_status	; Already saved ?
	bne.s	.Exit
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get event type
	move.b	(a5),d0
	cmp.b	#Query_type,d0		; Query ?
	bne.s	.No1
	cmp.b	#Seen_QM_type,Event_b1(a5)	; For eye ?
	beq.s	.Yes
.No1:	move.l	#Visible_event_mask,d1	; No -> Visible ?
	btst	d0,d1
	beq.s	.No2
.Yes:	jsr	Save_coordinates		; Save!
	st	Eye_flag			; Handle event
	jsr	Handle_event_chain
	sf	Eye_flag
	moveq.l	#-1,d7			; Yay !
	bra.s	.Exit
.No2:	jsr	Print_visible_event		; Print event
	sne	d7
.Exit:	tst.w	d7			; Test
	movem.l	(sp)+,d0/d1/d7
	rts

;*****************************************************************************
; [ Print visible event ]
;   IN : d0 - Current event type (.w)
;  OUT : eq - Not a visible event
;        ne - A text was printed
; All registers are restored
;*****************************************************************************
Print_visible_event:
	movem.l	d0/a0,-(sp)
	lea.l	Event_messages,a0		; Visible event ?
	move.b	-1(a0,d0.w),d0
	beq.s	.Exit
	jsr	Update_screen		; Yes -> Print text
	andi.w	#$00ff,d0
	jsr	Do_prompt_window
	moveq.l	#-1,d0			; Yay !
.Exit:	tst.w	d0			; Well ?
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Touch ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : eq - No luck
;        ne - I felt something
; All registers are restored
;*****************************************************************************
Touch:
	movem.l	d0-d2/a5,-(sp)
	moveq.l	#0,d2			; Default is no luck
	jsr	Find_event		; Find event
	bmi.s	.Exit
	jsr	Check_event_save_status	; Already saved ?
	bne.s	.Exit
	lea.l	Current_event_data,a5	; No -> Examine event
	moveq.l	#0,d0			; Get event type
	move.b	(a5),d0
	move.l	#Handable_event_mask,d1	; Touchable ?
	btst	d0,d1
	bne.s	.Do
	cmp.b	#Query_type,d0		; Query ?
	bne.s	.Exit
	cmp.b	#Touched_QM_type,Event_b1(a5)	; For touch ?
	bne.s	.Exit
.Do:	st	Hand_flag			; Handle event
	jsr	Handle_event_chain
	sf	Hand_flag
	moveq.l	#-1,d2			; Success !
.Exit:	tst.w	d2			; Any luck ?
	movem.l	(sp)+,d0-d2/a5
	rts

;*****************************************************************************
; [ Talk in 2D maps ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
Talk_2D:
	jsr	Talk
	bne.s	.Exit
	jsr	Talk_to_yourself
.Exit:	rts

;*****************************************************************************
; [ Talk to person (if any) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : eq - No luck
;        ne - I talked to something
; All registers are	restored
;*****************************************************************************
Talk:
	movem.l	d0-d2/d5-d7/a0,-(sp)
	moveq.l	#0,d5			; Default is no luck
; ---------- Look for NPC's -----------------------
	cmpi.b	#World_2D,Current_map_type	; 2D wilderness ?
	beq	.No_NPC
	lea.l	VNPC_data,a0		; Check NPC's
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq	.Next
	btst	d7,d6			; Deleted	?
	bne	.Next
	cmp.w	VMap_X(a0),d0		; Right coordinates	?
	bne	.Next
	cmp.w	VMap_Y(a0),d1
	beq.s	.Found
; ---------- Check for higher person --------------
	cmp.b	#Map_3D,Current_map_type	; 2D map ?
	bpl	.Next
	btst	#3,NPC_status_bits(a0)	; NPC graphics ?
	bne	.Next
	move.w	d1,d2			; Clicking on head ?
	addq.w	#1,d2
	cmp.w	VMap_Y(a0),d2
	bne	.Next
; ---------- See if this is a person --------------
.Found:	move.b	NPC_status_bits(a0),d2	; Get NPC type
	andi.b	#$03,d2
	cmp.b	#Monster_type,d2		; Object or monster ?
	bpl	.No_NPC
; ---------- See if victim is asleep --------------
	cmp.b	#Map_3D,Current_map_type	; 2D map ?
	bpl	.No_sleep
	tst.b	Show_trans		; Travelmodes ?
	bne	.No_sleep
	btst	#NPC_sleeping,VFlags(a0)	; Well ?
	beq	.No_sleep
	move.w	#105,d0			; Come back later !
	jsr	Do_prompt_window
	moveq.l	#-1,d5			; Yay!
	bra	.Exit
; ---------- Check for long or short dialogue -----
.No_sleep:	jsr	Turn_towards_NPC		; Look at me when I'm talking
	move.b	NPC_status_bits(a0),d2	; Long or short ?
	btst	#4,d2
	bne	.Short
; ---------- Compare languages --------------------
	jsr	Load_NPC_data		; Load data
	Get	Dialogue_handle,a0		; Get NPC's languages
	move.b	Learned_languages(a0),d0
	Free	Dialogue_handle
	Get	Active_handle,a0		; Compare with active's
	and.b	Learned_languages(a0),d0
	Free	Active_handle
	tst.b	d0			; Que ?
	bne.s	.Capito
	jsr	Destroy_NPC_data		; No comprendo, signor !
	move.w	#106,d0
	jsr	Do_prompt_window
	moveq.l	#-1,d5			; Yay!
	bra	.Exit
; ---------- Start long dialogue ------------------
.Capito:	move.w	d7,Dialogue_NPC_index	; Store index
	sf	NPC_or_member		; With NPC
	jsr	Exit_display		; Do
	Push	Module,Dialogue_Mod
	moveq.l	#-1,d5			; Yay!
	bra	.Exit
; ---------- Do short dialogue --------------------
.Short:	moveq.l	#0,d0			; Small talk
	move.b	NPC_char_nr(a0),d0
	Get	Maptext_handle,a0
	jsr	Do_text_window
	Free	Maptext_handle
	moveq.l	#-1,d5			; Yay!
	bra	.Exit
.Next:	lea.l	VNPC_data_size(a0),a0	; Next NPC
	addq.w	#1,d7
	cmpi.w	#Max_chars,d7
	bmi	.Loop
; ---------- Look for talkable events -------------
.No_NPC:	jsr	Handle_talkable_events	; Talk to events
	sne	d5
.Exit:	tst.w	d5			; Well ?
	movem.l	(sp)+,d0-d2/d5-d7/a0
	rts

;*****************************************************************************
; [ Talk to yourself ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
Talk_to_yourself:
	movem.l	d0-d2/d6/d7/a0,-(sp)
	cmp.w	#1,Nr_members		; All alone ?
	beq	.Exit
	cmp.b	#Map_3D,Current_map_type	; 2D map ?
	bpl	.Self
	cmp.w	Map_Xcoord,d0		; Clicking on party ?
	bne	.Exit
	cmp.w	Map_Ycoord,d1
	beq.s	.Self
	move.w	d1,d2			; Clicking on head ?
	addq.w	#1,d2
	cmp.w	Map_Ycoord,d2
	bne	.Exit
.Self:	moveq.l	#1,d7			; You're the leader !
	jsr	Activate_member
	beq	.Do
	move.w	#120,d0			; You cannot talk
	jsr	Do_prompt_window
	bra	.Exit
.Do:	jsr	Update_status_block		; Show
	jsr	Update_screen
	move.w	#103,MemberSel_prompt	; Talk to whom ?
	move.l	#Talk_check,MemberSel_ptr
	Push	Module,MemberSel_Mod
	move.w	Selected_member,d0		; No-one ?
	beq	.Exit
	cmp.w	#1,d0			; Yourself ?
	bne.s	.Else
	move.w	#104,d0			; Weirdo !
	jsr	Do_prompt_window
	bra	.Exit
.Else:	lea.l	Party_handles,a0		; Set data handle
	move.b	-1(a0,d0.w),Dialogue_handle
	lea.l	Portrait_handles,a0		; Set portrait handle
	move.b	-1(a0,d0.w),Dialogue_portrait_handle
	move.w	d0,Dialogue_NPC_index	; Store member number
	lea.l	Member_nrs,a0		; Get character number
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0
	moveq.l	#Party_text_file,d1		; Load character texts
	jsr	Load_subfile
	move.b	d0,Dialogue_text_handle
	st	NPC_or_member		; With party member
	jsr	Exit_display		; Do
	Push	Module,Dialogue_Mod
.Exit:	movem.l	(sp)+,d0-d2/d6/d7/a0
	rts

;*****************************************************************************
; [ Handle talkable events ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : eq - No event was talked to
;        ne - Some event was talked to
; All registers are restored
;*****************************************************************************
Handle_talkable_events:
	movem.l	d0/d1/d7/a0/a5,-(sp)
	moveq.l	#0,d7			; Default is no success
	jsr	Find_event		; Find event
	bmi.s	.Exit
	jsr	Check_event_save_status	; Already saved ?
	bne.s	.Exit
	lea.l	Current_event_data,a5	; No -> Examine event
	moveq.l	#0,d0			; Get event type
	move.b	(a5),d0
	move.l	#Talkable_event_mask,d1	; Talkable ?
	btst	d0,d1
	bne.s	.Do
	cmp.b	#Query_type,d0		; Query ?
	bne.s	.Exit
	cmp.b	#Word_spoken_QM_type,Event_b1(a5)	; For spoken word ?
	bne.s	.Exit
	moveq.l	#Dictionary_file,d0		; Yes -> Load dictionary
	jsr	Load_file
	move.b	d0,Dictionary_handle
	Push	Module,WSelW_Mod		; Select a word
	move.b	Dictionary_handle,d0	; Free memory
	jsr	Free_memory
	tst.b	No_word_selected		; Any word entered ?
	bne.s	.Skip
	move.w	Selected_word,QM_spoken_word	; Yes -> Store word
.Do:	st	Mouth_flag		; Handle event
	jsr	Handle_event_chain
	sf	Mouth_flag
.Skip:	moveq.l	#-1,d7			; Success !
.Exit:	tst.w	d7			; Test success
	movem.l	(sp)+,d0/d1/d7/a0/a5
	rts

;*****************************************************************************
; [ Reset dialogue scroll bar ]
; All registers are restored
;*****************************************************************************
Reset_sold_scroll_bar:
	movem.l	d0/a0,-(sp)
	move.b	Sold_slots_handle,Slotbase_handle
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0
	move.w	#Items_per_char,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Init_scroll_bar
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Battle order module ]
;*****************************************************************************
BattleOrder_ModInit:
	lea.l	BO_list,a0		; Build battle order list
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)
	subq.l	#8,a0
	lea.l	Party_handles,a1
	lea.l	Order,a2
	moveq.l	#1,d7
.Loop:	tst.b	(a1)			; Anyone there ?
	beq.s	.Next
	moveq.l	#0,d0			; Get order index
	move.b	(a2),d0
	move.b	d7,0(a0,d0.w)		; Insert
.Next:	addq.l	#1,a1			; Next member
	addq.l	#1,a2
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop
	jmp	BattleOrder_DisInit

BattleOrder_ModExit:
	lea.l	BO_list+12,a0		; Write new battle order
	lea.l	Order,a1
	moveq.l	#12-1,d7
.Loop:	move.b	-(a0),d0			; Anyone there ?
	beq.s	.Next
	ext.w	d0
	move.b	d7,-1(a1,d0.w)		; Insert
.Next:	dbra	d7,.Loop
	jmp	BattleOrder_DisExit

BattleOrder_DisInit:
	moveq.l	#Battle_order_layout,d0	; Show new layout
	jsr	Show_layout
	jsr	Show_battle_order		; Show battle order
	lea.l	BattleOrder_CIL,a0		; Display icons
	jsr	Display_control_icons
	jsr	Fade_in_bottom
	move.w	#18,d0			; Print text
	jmp	Print_prompt

BattleOrder_DisExit:
	jmp	Fade_out_bottom

Show_battle_order:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Portrait_handles,a1		; Show battle order
	lea.l	BattleOrder_pos_list,a2
	lea.l	BO_list,a3
	moveq.l	#12-1,d4
.Loop:	move.w	(a2),d0			; Get coordinates
	move.w	2(a2),d1
	subq.w	#1,d0			; Empty
	subq.w	#1,d1
	moveq.l	#32,d2
	moveq.l	#34,d3
	jsr	Draw_standard_box
	moveq.l	#0,d2			; Anyone there ?
	move.b	(a3)+,d2
	beq.s	.Next
	move.b	-1(a1,d2.w),d2		; Display	portrait
	Get	d2,a0
	move.w	(a2),d0
	move.w	2(a2),d1
	moveq.l	#5,d5
	moveq.l	#2,d6
	moveq.l	#34,d7
	jsr	Put_unmasked_block
	Free	d2
.Next:	addq.l	#4,a2			; Next member
	dbra	d4,.Loop
	movem.l	(sp)+,d0-d7/a0-a3
	rts

Exit_BattleOrder:
	Pop	Module
	jmp	Init_display

BattleOrder_clicked:
	jsr	Wait_4_unclick
	tst.b	d0			; Clicked	on portrait ?
	beq	.Exit
	lea.l	BO_list-1,a0		; Get source slot address
	ext.w	d0
	move.w	d0,BO_original_pos
	add.w	d0,a0
	move.b	(a0),d0
	beq.s	.Exit			; Empty slot ?
	clr.b	(a0)			; Clear
	jsr	Show_battle_order		; Show
	jsr	Update_screen
	ext.w	d0			; Select position
	move.w	d0,BO_member
.Again:	Push	Module,BOPosSel_Mod
	tst.w	BO_member			; Ready ?
	bne.s	.Again
.Exit:	rts

;*****************************************************************************
; [ Battle order position select ]
;*****************************************************************************
BOPosSel_DisInit:
	lea.l	BattleOrder_HDOB,a0		; Install HDOB
	move.w	Mouse_X,HDOB_drawX(a0)
	move.w	Mouse_Y,HDOB_drawY(a0)
	lea.l	Portrait_handles,a1
	move.w	BO_member,d0
	move.b	-1(a1,d0.w),HDOB_gfx_handle(a0)
	jsr	Add_HDOB
	jmp	Update_screen

BOPosSel_DisUpd:
	lea.l	BattleOrder_HDOB,a0		; Update HDOB position
	move.w	Mouse_X,HDOB_drawX(a0)
	move.w	Mouse_Y,HDOB_drawY(a0)
	jmp	Basic2_DisUpd

BOPos_selected:
	jsr	Wait_4_unclick
	tst.b	d0			; Clicked	on portrait ?
	beq.s	.Exit
	lea.l	BO_list-1,a0		; Get target slot address
	ext.w	d0
	move.w	d0,BO_original_pos
	adda.w	d0,a0
	move.w	BO_member,d1
	tst.b	(a0)			; Target slot empty	?
	bne.s	.Swap
	move.b	d1,(a0)			; Insert
	clr.w	BO_member			; Clear
	bra.s	.Show
.Swap:	move.b	(a0),d0			; Swap
	move.b	d1,(a0)
	ext.w	d0
	move.w	d0,BO_member
.Show:	lea.l	BattleOrder_HDOB,a0		; Remove HDOB
	jsr	Remove_HDOB
	jsr	Show_battle_order		; Show
	jsr	Update_screen
	Pop	Module
.Exit:	rts

Exit_BOPosSel:
	move.w	BO_original_pos,d0		; Try to restore
	bra.s	BOPos_selected

;*****************************************************************************
; [ Camp screen module ]
;*****************************************************************************
Camp_ModInit:
	sf	Slept			; Clear flag
	moveq.l	#Camp_music,d0		; Set music
	moveq.l	#0,d1
	jsr	Set_music
	tst.b	Inn_flag			; Inn ?
	bne.s	.Inn
	Get	Mapdata_handle,a0		; No
	move.w	Map_special(a0),d0
	Free	Mapdata_handle
	btst	#Wilderness_bit,d0		; Wilderness ?
	beq.s	.Dungeon
	moveq.l	#Camp_wilderness_pic,d0	; Yes
	bra.s	.Do
.Dungeon:	moveq.l	#Camp_dungeon_pic,d0	; No
	bra.s	.Do
.Inn:	moveq.l	#Camp_inn_pic,d0		; Inn
.Do:	jsr	Load_80x80_picture
	jsr	Load_object_graphics
	jmp	Camp_DisInit

Camp_ModExit:
	move.b	Pic_80x80_handle,d0		; Free memory
	jsr	Free_memory
	jsr	Free_object_graphics
	jsr	Set_map_music		; Reset music
	jmp	Fade_out_bottom

Camp_DisInit:
	move.w	#Camp_spell_area,Spell_area_type	; Set spell area
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	jsr	Display_80x80_picture	; Show picture
	lea.l	Camp_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jsr	Hide_Lay3_objects		; Hide objects
	jmp	Fade_in_bottom

Camp_CIL_evaluate:
	Get	Active_handle,a1
	tst.b	Slept			; Already slept ?
	beq.s	.Ok1
	bset	#7,12(a0)			; Disable {Rest}
.Ok1:	tst.b	Spell_class_counter(a1)	; Any spell classes ?
	bne.s	.Ok2
	bset	#7,(a0)			; Disable {Cast spell}
	bset	#7,6(a0)			; Disable {Learn spell}
	bra.s	.Exit
.Ok2:	jsr	Check_active_backpack	; Any items ?
	bne.s	.Exit
	bset	#7,6(a0)			; Disable {Learn spell}
.Exit:	Free	Active_handle
	rts

; ********** Camp screen - Exit camp **************
Exit_camp:
	Pop	Module			; Exit camp
	jsr	Wait_4_fade
	tst.b	Inn_flag			; Inn ?
	bne.s	.Inn
	jsr	Init_display		; No
	bra.s	.Exit
.Inn:	sf	Inn_flag			; Yes -> Clear
	lea.l	Inn_destination,a0		; Set new	coordinates
	move.w	(a0)+,Map_Xcoord
	move.w	(a0)+,Map_Ycoord
	move.w	(a0),d0			; Get new map number
	beq.s	.Same			; Same map ?
	move.w	d0,Map_nr			; No
	jsr	Exit_map			; Exit current map
	jsr	Init_map			; Initialize new map
	bra.s	.Exit
.Same:	jsr	Jumped			; Yes
	jsr	Init_display		; Show
	jsr	Event_handler		; Handle first event
.Exit:	rts

; ********** Camp screen - Rest *******************
Rest:
	tst.b	Inn_flag			; Inn ?
	bne.s	.Ok
	cmp.w	#Camp_time,Camp_counter	; Too early ?
	bpl.s	.Ok
	move.w	#176,d0			; "Too early !"
	jsr	Do_prompt
	rts				; SECOND EXIT POINT
.Ok:	st	Slept			; Set flag
; ---------- De-exhaust people --------------------
	lea.l	Party_handles,a1
	moveq.l	#6-1,d7
.Loop:	tst.b	(a1)			; Anyone there ?
	beq.s	.Next
	Get	(a1),a0			; Yes -> De-exhaust
	jsr	De_exhaust
	Free	(a1)
.Next:	addq.l	#1,a1			; Next member
	dbra	d7,.Loop
	LOCAL
; ---------- Wait x hours -------------------------
	Get	Mapdata_handle,a0		; Get map info
	move.w	Map_special(a0),d0
	Free	Mapdata_handle
	btst	#Dungeon_bit,d0		; Dungeon ?
	bne	.8_hours
	cmp.w	#Morning_time,Hour		; Early ?
	bmi.s	.Dawn
	cmp.w	#Evening_time,Hour		; Evening ?
	bmi.s	.8_hours	
; ***** Rest till dawn *****
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
; ***** Rest for 8 hours *****
.8_hours:	move.w	#24,d0			; "8 hours..."
	jsr	Do_prompt
	move.w	#(8*Minutes_per_hour)/Minutes_per_step-1,d7
; ***** Wait *****
.Wait:	clr.w	Camp_counter		; Clear
	bra.s	.Entry
.Loop:	jsr	Update_time		; Wait x hours
.Entry:	dbra	d7,.Loop
	jsr	Update_light_status
	clr.w	Camp_counter		; Clear again
	LOCAL
; ---------- Age aging people ---------------------
	tst.b	Inn_flag			; Inn ?
	bne	.Skip
	lea.l	Party_handles,a2
	moveq.l	#1,d7
.Loop:	move.b	(a2)+,d0			; Anyone there ?
	beq.s	.Next
	jsr	Claim_pointer
	move.l	d0,a1
	move.w	Body_conditions(a1),d0
	move.w	d0,d1			; Alive and kicking	?
	andi.w	#Alive_mask,d1
	bne.s	.Done
	btst	#Aging,d0			; Aging ?
	beq.s	.Done
	lea.l	Aging_text,a0		; Print "aging..."
	jsr	Print_member_text
	jsr	Wait_4_user
	move.w	AAge(a1),d0		; Increase age
	addq.w	#1,d0
	move.w	d0,AAge(a1)
	add.w	AAge+Magic(a1),d0
					; FIX: Removed "add.w Time_data_year,d0" (age counted twice)
	move.w	AAge+Maximum(a1),d1		; Too old	?
	cmp.w	d0,d1
	bpl.s	.Done
	lea.l	Ageddeath_text,a0		; Print "dying..."
	jsr	Print_member_text
	jsr	Kill_member		; Kill !
.Done:	Free	-1(a2)
.Next:	addq.w	#1,d7			; Next member
	cmpi.w	#6+1,d7
	bmi.s	.Loop
.Skip:	LOCAL
; ---------- Gain LP & PP -------------------------
	lea.l	Party_handles,a2
	tst.b	Inn_flag			; Inn- or out-side ?
	bne.s	.Inn
	moveq.l	#50,d2
	bra.s	.Go_on
.Inn:	move.w	Current_inn_value,d2	; Get healing percentage
.Go_on:	moveq.l	#1,d7
.Loop1:	move.b	(a2)+,d0			; Anyone there ?
	beq	.Next1
	jsr	Claim_pointer
	move.l	d0,a1
	move.w	Body_conditions(a1),d0
	move.w	d0,d1			; Alive and kicking	?
	andi.w	#Alive_mask,d1
	bne	.Done
	tst.b	Inn_flag			; Inn- or out-side ?
	bne.s	.Do
	tst.w	Food_rations(a1)		; Outside -> Any food left ?
	bne.s	.Enough
	lea.l	No_recup_text,a0		; Print "no food..."
	jsr	Print_member_text
	bra.s	.Done
.Enough:	subq.w	#1,Food_rations(a1)		; Remove 1 food
	subi.l	#Food_weight,Weight_normal(a1)
.Do:	jsr	Add_LP_and_PP		; Do it (50%)
.Done:	Free	-1(a2)
.Next1:	addq.w	#1,d7			; Next member
	cmpi.w	#6+1,d7
	bmi.s	.Loop1
; ---------- End ----------------------------------
	jsr	Erase_PA
	jsr	Update_screen
	lea.l	Spell_1_data,a0		; Deactivate spells
	moveq.l	#6-1,d7
.Loop2:	clr.l	(a0)+
	dbra	d7,.Loop2
	rts

; ********** Camp screen - Learn spell ************
Learn_spell:
	clr.w	Scroll_bar_work		; Clear
.Repeat:	move.w	#19,ItemSelect_prompt	; Select item
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
	Get	Active_handle,a0
	move.l	a0,a2			; Get object packet address
	add.l	Slotbase_offset,a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.l	Object_data_ptr,a1		; Get object data address
	move.w	Object_index(a2),d0
	move.w	d0,d7			; Save for later
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	cmp.b	#Spellscroll_itemtype,Item_type(a1)	; A scroll ?
	beq	.Ok1
	moveq.l	#20,d0			; "Not a scroll"
	jsr	Do_prompt
	bra	.Done
.Ok1:	move.b	Spell_class_counter(a0),d0	; Spell class known ?
	move.b	Spell_class(a1),d1
	btst	d1,d0
	bne.s	.Ok2
	moveq.l	#21,d0			; "Wrong class"
	jsr	Do_prompt
	bra	.Done
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
	jsr	Do_prompt
	bra	.Done
.Ok3:	lea.l	Spell_data,a4		; Get pointer to spell data
	moveq.l	#0,d0
	move.b	Spell_class(a1),d0
	mulu.w	#Max_spells,d0
	add.w	d1,d0
	subq.w	#1,d0
	mulu.w	#Spell_data_size,d0
	adda.w	d0,a4
	moveq.l	#0,d0			; Get SLP cost
	move.b	Spell_learn_point_cost(a4),d0
	move.w	Nr_spell_learn_points(a0),d1	; Get SLP
	sub.w	d0,d1			; Enough ?
	bpl.s	.Ok4
	moveq.l	#25,d0			; "Not enough SLP!"
	jsr	Do_prompt
	bra.s	.Done
.Ok4:	move.w	d1,Nr_spell_learn_points(a0)	; Store new SLP
	move.b	Active_handle,d0		; Remove item
	move.w	Selected_item,d2
	addi.w	#9+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.w	SRead_scrolls(a0),d0	; Probe {Learn spells} skill
	add.w	SRead_scrolls+Magic(a0),d0
	jsr	Probe_100
	bpl.s	.Pos
	moveq.l	#23,d0			; "Bang!"
	jsr	Do_prompt
	move.w	Selected_item,d0		; Boom!
	move.w	d7,d1
	jsr	Learn_spell_failed
	bra.s	.Done
.Pos:	move.b	Spell_number(a1),d1		; Learn spell
	move.l	(a3),d0
	bset	d1,d0
	move.l	d0,(a3)
	moveq.l	#22,d0			; "Yay!"
	jsr	Do_prompt
	move.w	Selected_item,d0		; Zap!
	jsr	Learn_spell_succeeded
.Done:	Free	Active_handle
	jsr	Check_active_backpack	; All gone ?
	bne	.Repeat			; No -> Again
.Exit:	jsr	Hide_Lay3_objects		; Hide
	jsr	Update_screen
.Exit2:	rts

;*****************************************************************************
; [ Learning a spell succeeded ]
;   IN : d0 - Slot number (0...23) (.w)
; All registers are restored
;*****************************************************************************
Learn_spell_succeeded:
	movem.l	d0/d1/a0/a1,-(sp)
	sub.w	Scroll_bar_result,d0	; Adjust
	addq.w	#1,d0
	jsr	Display_object		; Update object display
	jsr	Update_screen
	move.l	Object_pos_list,a0		; Get slot coordinates
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
; [ Learning a spell failed ]
;   IN : d0 - Slot number (0...23) (.w)
;        d1 - Object index (.w)
; All registers are restored
;*****************************************************************************
Learn_spell_failed:
	movem.l	d0/d1/d4/d6/d7/a0/a1,-(sp)
	sub.w	Scroll_bar_result,d0	; Adjust
	addq.w	#1,d0
	jsr	Display_object		; Update object display
	jsr	Update_screen
	move.l	Object_pos_list,a1		; Get slot coordinates
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a1
	move.l	Object_data_ptr,a0		; Get object data address
	subq.w	#1,d1
	mulu.w	#Item_data_size,d1
	add.l	d1,a0
	moveq.l	#0,d0			; Get object graphics address
	move.b	Item_pic(a0),d0
	Get	Object_gfx_handle,a0
	mulu.w	#Icon_size,d0
	add.l	d0,a0
	move.w	(a1)+,d0			; Boom !
	move.w	(a1)+,d1
	moveq.l	#27,d4
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Explode_bitmap
	Free	Object_gfx_handle
	movem.l	(sp)+,d0/d1/d4/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Calculate & output gained LP & PP ]
;   IN : d2 - Recuperate factor {0...100%} (.w)
;        d7 - Member number [1...6] (.w)
;        a1 - Pointer to character data (.l)
; All registers are restored
;*****************************************************************************
Add_LP_and_PP:
	movem.l	d0/d1/d4/d5/d7/a0,-(sp)
	moveq.l	#0,d4			; Clear
	moveq.l	#0,d5
; ---------- Calculate gained LP ------------------
	move.w	Life_points+Maximum(a1),d0	; Get maximum LP
	add.w	Life_points+Magic(a1),d0
	move.w	d0,d1			; Calculate maximum gain
	sub.w	Life_points(a1),d1
	bmi.s	.Skip
	mulu.w	d2,d0			; Calculate gained LP
	divu.w	#100,d0
	tst.w	d0			; Zero ?
	bne.s	.Not_zero
	moveq.l	#1,d0			; At least 1
.Not_zero:	cmp.w	d0,d1			; Too high ?
	bpl.s	.Ok
	move.w	d1,d0			; Yes -> Clip
.Ok:	move.w	d0,d4			; Store
.Skip:	LOCAL
; ---------- Calculate gained PP ------------------
	tst.b	Spell_class_counter(a1)	; Magic person ?
	beq.s	.Skip
	move.w	Power_points+Maximum(a1),d0	; Get maximum PP
	add.w	Power_points+Magic(a1),d0
	move.w	d0,d1			; Calculate maximum gain
	sub.w	Power_points(a1),d1
	bmi.s	.Skip
	mulu.w	d2,d0			; Calculate gained PP
	divu.w	#100,d0
	tst.w	d0			; Zero ?
	bne.s	.Not_zero
	moveq.l	#1,d0			; At least 1
.Not_zero:	cmp.w	d0,d1			; Too high ?
	bpl.s	.Ok
	move.w	d1,d0			; Yes -> Clip
.Ok:	move.w	d0,d5			; Store
.Skip:	LOCAL
; ---------- Print --------------------------------
	move.w	d7,-(sp)
	move.w	d4,d0			; Add LP & PP
	jsr	Increase_LP
	move.w	d5,d0
	jsr	Increase_PP
	lea.l	Number,a0			; Convert gained LP
	moveq.l	#3,d7
	move.w	d4,d0
	jsr	DecL_convert
	tst.w	d5			; Any PP gained ?
	bne.s	.Both
	lea.l	Recup1_text,a0		; No -> Print "Just LP" text
	move.l	#Number,8(a0)
	move.w	(sp)+,d7
	jsr	Print_member_text
	bra.s	.Exit
.Both:	lea.l	Number+5,a0		; Yes -> Convert gained PP
	move.w	d5,d0
	moveq.l	#3,d7
	jsr	DecL_convert
	lea.l	Recup2_text,a0		; Print "PP & LP" text
	move.l	#Number,8(a0)
	move.l	#Number+5,16(a0)
	move.w	(sp)+,d7
	jsr	Print_member_text
.Exit:	movem.l	(sp)+,d0/d1/d4/d5/d7/a0
	rts

;*****************************************************************************
; [ Options "screen" ]
;*****************************************************************************
Options_ModInit:
; ---------- Determine context --------------------
	tst.b	Battling			; Fighting ?
	beq	.No
	jsr	Set_layout_colours		; Yes
	move.w	#Combat_X,d0		; Combat
	move.w	#Combat_Y,d1
	moveq.l	#(Combat_width/16),d2
	moveq.l	#6,d3
	bra.s	.Do
.No:	cmp.b	#Map_3D,Current_map_type	; No -> 2D or 3D map ?
	bpl.s	.3D
	move.w	#Map2D_X,d0		; 2D
	move.w	#Map2D_Y,d1
	moveq.l	#Mapbuf_width,d2
	moveq.l	#Mapbuf_height,d3
	bra.s	.Do
.3D:	move.w	#Map3D_X,d0		; 3D
	move.w	#Map3D_Y,d1
	moveq.l	#9,d2
	moveq.l	#9,d3
; ---------- Cross-hatch display window -----------
.Do:	movem.l	d0-d3,-(sp)
	lea.l	Cross_hatch,a0		; Initialize registers
	moveq.l	#0,d4
	moveq.l	#1,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
	subq.w	#1,d3			; DBRA correction
.Loop_Y:	movem.w	d0/d2,-(sp)
	subq.w	#1,d2			; DBRA correction
.Loop_X:	jsr	Put_masked_silhouette	; Cross-hatch one square
	addi.w	#16,d0			; Next X
	dbra	d2,.Loop_X
	movem.w	(sp)+,d0/d2		; Next Y
	addi.w	#16,d1
	dbra	d3,.Loop_Y
	movem.l	(sp)+,d0-d3
; ---------- Print version ------------------------
	lsl.w	#4,d2			; Determine coordinates
	lsl.w	#2,d3
	add.w	d3,d1
	movem.w	d0-d2,-(sp)		; Display surrounding box
	lsr.w	#1,d2
	add.w	d2,d0
	subi.w	#64,d0
	subq.w	#3,d1
	move.w	#128,d2
	moveq.l	#19,d3
	jsr	Draw_standard_box2
	movem.w	(sp)+,d0-d2
	move.w	#31,Ink_colour		; Set ink
	move.l	Version_string1_ptr,a0		; Print
	jsr	Print_centered_string
	addq.w	#7,d1
	move.l	Version_string2_ptr,a0
	jsr	Print_centered_string
	lea.l	Options_CIL,a0		; Show control icons
	jsr	Display_control_icons
	jmp	Update_screen

Options_ModExit:
	tst.b	Battling			; Fighting ?
	beq.s	.No
	jsr	Restore_combat_colours	; Yes
	lea.l	Combat_CIL,a0		; Restore combat CIL
	jsr	Display_control_icons
	st	Update_command		; Show all
	bra.s	.Exit
.No:	jsr	Init_map_CIL		; No -> Restore map CIL
.Exit:	jmp	Update_screen

Options_CIL_evaluate:
	tst.b	Battling			; In combat ?
	beq.s	.Exit
	bset	#7,12(a0)			; Disable {Save game}
.Exit:	rts

; ********** Options - Options window *************
Options_window:
	move.w	Internal_flags,d7		; Get old flags
	Push	Module,OptionsW_Mod		; Do window
	move.w	Internal_flags,d0		; Get changes
	eor.w	d0,d7
; ---------- Check music --------------------------
	btst	#Music_flag_bit,d7
	beq.s	.Ok1
	move.b	Music_flag,d0		; Toggle music flag
	not.b	d0
	move.b	d0,Music_flag
	ext.w	d0			; Start/stop music
	jsr	Set_music
; ---------- Check text outlining -----------------
.Ok1:	btst	#Outline_text_bit,d7
	beq.s	.Ok2
	not.b	Outline_text		; Toggle outline flag
; ---------- Check dungeon floor ------------------
.Ok2:	btst	#Dungeon_floor_bit,d7
	beq.s	.Ok3
	bchg	#0,Floor_ceiling_status	; Toggle internal flag
	bne.s	.Off1
	jsr	Load_floor
	btst	#1,Floor_ceiling_status	; No ceiling either ?
	bne.s	.Ok3
	jsr	Create_MPB_table		; Make MPB buffer
	bra.s	.Ok3
.Off1:	move.b	Floor_buffer_handle,d0	; Free floor
	jsr	Free_memory
	btst	#1,Floor_ceiling_status	; No ceiling either ?
	bne.s	.Ok3
	move.b	MPB_buffer_handle,d0	; Free MPB buffer
	jsr	Free_memory
; ---------- Check dungeon ceiling ----------------
.Ok3:	btst	#Dungeon_ceiling_bit,d7
	beq.s	.Exit
	bchg	#1,Floor_ceiling_status	; Toggle internal flag
	bne.s	.Off2
	jsr	Load_ceiling
	btst	#0,Floor_ceiling_status	; No floor either ?
	bne.s	.Exit
	jsr	Create_MPB_table		; Make MPB buffer
	bra	.Exit
.Off2:	move.b	Ceiling_buffer_handle,d0	; Free ceiling
	jsr	Free_memory
	btst	#0,Floor_ceiling_status	; No floor either ?
	bne.s	.Exit
	move.b	MPB_buffer_handle,d0	; Free MPB buffer
	jsr	Free_memory
.Exit:	rts

; ********** Options - Quit game ******************
Quit_game:
	moveq.l	#60,d0			; Really ?
	jsr	Prompt_req
	tst.b	d0
	beq	.Exit
	Pop	Module			; Leave
	jsr	Exit_display
	jmp	Exit_program
.Exit:	rts

; ********** Options - Save game ******************
Save_game:
; ---------- Select save position -----------------
	moveq.l	#Saves_file,d0		; Load saves file
	jsr	Load_file
	move.b	d0,Saves_handle
	move.w	#96,SavedSelW_prompt
	Push	Module,SaveSelW_Mod		; Select save game
	tst.w	Selected_save		; Anything selected ?
	bne.s	.Do
	move.b	Saves_handle,d0		; No -> Remove saves file
	jsr	Free_memory
	bra	.Exit
.Do:	tst.b	Empty_save_selected		; Yes -> Empty save selected ?
	bne.s	.Skip
	moveq.l	#95,d0			; No -> Are you sure ?
	jsr	Prompt_req
	tst.b	d0
	bne.s	.Skip
	move.b	Saves_handle,d0		; No -> Destroy (!) saves file
	jsr	Kill_memory
	bra	.Exit
; ---------- Save automapper data -----------------
.Skip:	cmpi.b	#Map_3D,Current_map_type	; 3D map ?
	bmi.s	.No_3D
	jsr	Save_automap
; ---------- Save party character data ------------
.No_3D:	lea.l	Party_handles,a1
	lea.l	Member_nrs,a2
	moveq.l	#Party_char_file,d1
	moveq.l	#6-1,d7
.Loop1:	tst.b	(a1)			; Anyone there ?
	beq.s	.Next1
	move.w	(a2),d0			; Save datafile
	Get	(a1),a0
	jsr	Save_subfile
	Free	(a1)
.Next1:	addq.l	#1,a1			; Next member
	addq.l	#2,a2
	dbra	d7,.Loop1
; ---------- Save party data ----------------------
	moveq.l	#0,d0			; Calculate party data length
	move.w	Nr_of_modifications,d0
	mulu.w	#Modif_data_size,d0
	addi.l	#Party_data_size+2,d0
	moveq.l	#Party_data_file,d1		; Save party data
	lea.l	Party_data,a0
	jsr	Save_encrypted_file
; ---------- Copy work files to save folder -------
	move.w	Selected_save,d0
	jsr	Put_saved_game
; ---------- Save selected save number ------------
	move.b	Saves_handle,d0		; Save saves file
	jsr	Get_memory_length
	moveq.l	#Saves_file,d1
	Get	Saves_handle,a0
	move.w	Selected_save,(a0)		; Store save number
	jsr	Save_file
	move.b	Saves_handle,d0		; Destroy saves file
	jsr	Free_pointer
	jsr	Free_memory
.Exit:	rts

; ********** Options - Load game ******************
Load_game:
	moveq.l	#Saves_file,d0		; Load saves file
	jsr	Load_file
	move.b	d0,Saves_handle
	jsr	Claim_pointer		; Any saved games ?
	move.l	d0,a0
	tst.w	(a0)+			; Current save entered ?
	bne	.Select
	moveq.l	#Max_saves-1,d7
.Loop:	tst.b	(a0)			; String empty ?
	bne	.Select
	lea.l	Save_name_length+1(a0),a0	; Yes -> Try next
	dbra	d7,.Loop
	Free	Saves_handle		; All empty
	move.w	#292,d0			; Really restart ?
	jsr	Prompt_req
	tst.b	d0
	beq	.Exit
	clr.w	Selected_save		; Yes
	bra.s	.Do
.Select:	Free	Saves_handle		; Saved games are present
	move.w	#230,SavedSelW_prompt
	Push	Module,LoadSelW_Mod		; Select save game
	move.b	Saves_handle,d0		; Destroy file
	jsr	Free_memory
	tst.w	Selected_save		; Anything selected ?
	beq	.Exit
	moveq.l	#94,d0			; Yes -> Really load ?
	jsr	Prompt_req
	tst.b	d0
	beq	.Exit
.Do:	jsr	Fade_out_all		; Yes -> Fade out
	move.w	Selected_save,Initial_save	; Set
	jmp	Restart_game		; Restart
.Exit:	rts

;*****************************************************************************
; [ Saved game selector ]
;*****************************************************************************
SavedSelW_DisInit:
	clr.w	Selected_save		; Clear
	move.w	#SavedSelW_X-16,d0		; Open window
	move.w	#SavedSelW_Y-16,d1
	moveq.l	#18,d2
	moveq.l	#7,d3
	lea.l	SavedSelW_L1,a0
	jsr	Open_window
	jsr	Update_saved_window		; Print saved names
	move.w	#31,Ink_colour		; Set ink
	move.w	#SavedSelW_X,d0		; "Which save ?"
	move.w	#SavedSelW_Y,d1
	move.w	#256,d2
	move.w	SavedSelW_prompt,d3
	jsr	Print_centered_prompt
	jmp	Update_screen

Update_saved_window:
	move.w	#SavedSelW_X-1,d0		; Display box
	move.w	#SavedSelW_Y+7,d1
	move.w	#256,d2
	move.w	#Max_saves*(Char_height+2)+1,d3
	jsr	Draw_standard_box
	move.w	#31,Ink_colour		; Set ink
	Get	Saves_handle,a1		; Print save names
	addq.l	#2,a1
	move.w	#SavedSelW_Y+9,d1
	moveq.l	#" ",d6
	moveq.l	#2,d7
	moveq.l	#1,d5
.Loop:	lea.l	Number,a0			; Convert number
	move.w	d5,d0
	jsr	DecR_convert
	lea.l	Number,a0			; Print it
	move.w	#SavedSelW_X,d0
	jsr	Put_text_line
	move.l	a1,a0
	addi.w	#3*(Char_width+1),d0	; Print save name
	jsr	Put_text_line
.Next:	add.w	#Char_height+2,d1		; Next save
	lea.l	Save_name_length+1(a1),a1	
	addq.w	#1,d5
	cmp.w	#Max_saves+1,d5
	bmi.s	.Loop
	Free	Saves_handle
	rts

Load_selected:
	lsr.w	#8,d0			; Any save ?
	tst.b	d0
	beq	.Exit
	Get	Saves_handle,a0		; Get save name
	addq.l	#2,a0
	move.w	d0,d1
	subq.w	#1,d1
	mulu.w	#Save_name_length+1,d1
	add.l	d1,a0
	tst.b	(a0)			; Empty ?
	beq	.Exit
	move.w	d0,Selected_save		; Store
	move.w	#26,Ink_colour		; Set colours
	move.w	#31,Shadow_colour
	move.w	d0,d1			; Print it
	subq.w	#1,d1
	mulu.w	#Char_height+2,d1
	addi.w	#SavedSelW_Y+9,d1
	move.w	#SavedSelW_X+3*(Char_width+1),d0
	jsr	Put_text_line
	Free	Saves_handle
	move.w	#0,Shadow_colour		; Reset
	jsr	Update_screen
	jsr	Wait_4_unclick		; Wait
	Pop	Module
.Exit:	rts

Load_touched:
	lsr.w	#8,d0			; Any save ?
	tst.b	d0
	beq	.Exit
	Get	Saves_handle,a0		; Get save name
	addq.l	#2,a0
	subq.w	#1,d0
	move.w	d0,d1
	mulu.w	#Save_name_length+1,d1
	add.l	d1,a0
	tst.b	(a0)			; Empty ?
	beq	.Exit
	move.w	#0,Ink_colour		; Set colours
	move.w	#-1,Shadow_colour
	move.w	d0,d1			; Get coordinates
	mulu.w	#Char_height+2,d1
	addi.w	#SavedSelW_Y+8,d1
	move.w	#SavedSelW_X+3*(Char_width+1)-1,d0
	move.w	d0,d2			; Draw highlighting box
	move.w	d1,d3
	addi.w	#255-3*(Char_width+1),d2
	add.w	#Char_height+1,d3
	moveq.l	#31,d4
	jsr	Draw_box
	addq.w	#1,d0			; Print saved game name
	addq.w	#1,d1
	jsr	Put_text_line
	Free	Saves_handle
	move.w	#0,Shadow_colour		; Reset
.Exit:	rts

Save_selected:
	lsr.w	#8,d0			; Any save ?
	tst.b	d0
	beq	.Exit
	move.w	d0,Selected_save		; Store
	Get	Saves_handle,a0		; Get save name
	addq.l	#2,a0
	subq.w	#1,d0
	move.w	d0,d1
	mulu.w	#Save_name_length+1,d1
	add.l	d1,a0
	move.l	a0,a1
	tst.b	(a0)			; Empty ?
	seq	Empty_save_selected
	move.w	#26,Ink_colour		; Set colours
	move.w	#31,Shadow_colour
	move.w	d0,d1			; Print it
	mulu.w	#Char_height+2,d1
	addi.w	#SavedSelW_Y+9,d1
	move.w	#SavedSelW_X+3*(Char_width+1),d0
	jsr	Put_text_line
	jsr	Update_screen
	move.w	#0,Shadow_colour		; Reset
	jsr	Wait_4_unclick		; Wait
	move.w	#Save_name_length,d2	; Edit string
	move.l	a1,a0
	jsr	Edit_string
	Free	Saves_handle
	tst.b	Input_aborted		; Aborted ?
	bne.s	.Abort
	tst.b	(a0)			; Empty ?
	bne.s	.Ok
.Abort:	clr.w	Selected_save		; Abort
	bra.s	.Exit
.Ok:	Pop	Module			; Exit
.Exit:	rts

Save_touched:
	lsr.w	#8,d0			; Any save ?
	tst.b	d0
	beq	.Exit
	Get	Saves_handle,a0		; Get save name
	addq.l	#2,a0
	subq.w	#1,d0
	move.w	d0,d1
	mulu.w	#Save_name_length+1,d1
	add.l	d1,a0
	move.w	#0,Ink_colour		; Set colours
	move.w	#-1,Shadow_colour
	move.w	d0,d1			; Get coordinates
	mulu.w	#Char_height+2,d1
	addi.w	#SavedSelW_Y+8,d1
	move.w	#SavedSelW_X+3*(Char_width+1)-1,d0
	move.w	d0,d2			; Draw highlighting box
	move.w	d1,d3
	addi.w	#255-3*(Char_width+1),d2
	add.w	#Char_height+1,d3
	moveq.l	#31,d4
	jsr	Draw_box
	addq.w	#1,d0			; Print saved game name
	addq.w	#1,d1
	jsr	Put_text_line
	Free	Saves_handle
	move.w	#0,Shadow_colour		; Reset
.Exit:	rts

;*****************************************************************************
; [ Options window ]
;*****************************************************************************
OptionsW_ModInit:
; ---------- Build options mask -------------------
	moveq.l	#-1,d0
	cmp.b	#Map_3D,Current_map_type	; In 3D map ?
	bmi.s	.Off
	tst.b	Battling			; In combat ?
	beq.s	.Ok1
.Off:	bclr	#4,d0			; Disable floor & ceiling
	bclr	#5,d0
	bra.s	.Done
.Ok1:	move.b	Floor_ceiling_potential,d1	; Get potential
	btst	#0,d1			; Floor possible ?
	bne.s	.Ok2
	bclr	#4,d0			; No -> Disable
.Ok2:	btst	#1,d1			; Ceiling possible ?
	bne.s	.Done
	bclr	#5,d0			; No -> Disable
.Done:	move.b	d0,Options_mask		; Store mask
; ---------- Build window -------------------------
	move.w	#OptionsW_X-16,d0		; Open window
	move.w	#OptionsW_Y-16,d1
	moveq.l	#14,d2
	moveq.l	#6,d3
	lea.l	OptionsW_L1,a0
	jsr	Open_window
	jsr	Update_option_names		; Show option names
	move.w	#31,Ink_colour
	move.w	#OptionsW_X,d0		; "Options"
	move.w	#OptionsW_Y,d1
	move.w	#192,d2
	move.w	#234,d3
	jsr	Print_centered_prompt
	move.w	#OptionsW_X+159,d0		; Draw box around exit icon
	move.w	#OptionsW_Y+46,d1
	move.w	#32,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display exit icon
	addq.w	#1,d1
	moveq.l	#Exit_cicon,d3
	jsr	Display_up_button
	jmp	Update_screen

Options_aborted:
	move.w	#OptionsW_X+160,d0		; Feedback
	move.w	#OptionsW_Y+47,d1
	move.b	#Exit_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	jsr	Pop_Module		; Exit
.Exit:	rts

Option_selected:
	move.w	d0,d7			; Save
	andi.w	#$ff00,d0			; Which option ?
	lsr.w	#8,d0
	beq	.Exit			; (if any)
	move.b	Options_mask,d1		; Masked ?
	btst	d0,d1
	beq.s	.Exit
	jsr	Wait_4_unclick		; Wait
	lea.l	Option_bits,a0		; Toggle flag
	move.b	-1(a0,d0.w),d0
	move.w	Internal_flags,d1
	bchg	d0,d1
	move.w	d1,Internal_flags
	jsr	Update_option_names		; Update
	move.w	d7,d0
	jsr	Option_touched
.Exit:	rts

Option_touched:
	andi.w	#$ff00,d0			; Which option ?
	lsr.w	#8,d0
	beq	.Exit			; (if any)
	move.b	Options_mask,d1		; Masked ?
	btst	d0,d1
	beq	.Exit
	subq.w	#1,d0			; Save
	move.w	d0,d7
	move.l	Option_names_ptr,a0		; Get option name
	jsr	Find_small_text
	move.w	#OptionsW_X,d0		; Get coordinates
	move.w	d7,d1
	mulu.w	#Char_height+2,d1
	addi.w	#OptionsW_Y+8,d1
	move.w	#0,Ink_colour		; Set colours
	move.w	#-1,Shadow_colour
	move.w	d0,d2			; Draw highlighting box
	move.w	d1,d3
	addi.w	#190,d2
	add.w	#Char_height+1,d3
	moveq.l	#31,d4
	jsr	Draw_box
	addq.w	#1,d0			; Print option name
	addq.w	#1,d1
	jsr	Put_text_line
	lea.l	Option_bits,a0		; On or off ?
	move.b	0(a0,d7.w),d6
	move.w	Internal_flags,d0
	bclr	#7,d6			; Inverse ?
	beq.s	.Normal
	btst	d6,d0			; Yes -> Off or on ?
	beq.s	.On
	bra.s	.Off
.Normal:	btst	d6,d0			; No -> On or off ?
	beq.s	.Off
.On:	move.l	On_txt_ptr,a0			; On
	bra.s	.Do
.Off:	move.l	Off_txt_ptr,a0		; Off
.Do:	move.w	#OptionsW_X+168,d0		; Print on/off
	jsr	Put_text_line
	move.w	#0,Shadow_colour		; Reset
.Exit:	rts

;*****************************************************************************
; [ Update option names ]
; All registers are restored
;*****************************************************************************
Update_option_names:
	movem.l	d0-d3/d7/a0-a2,-(sp)
	move.w	#OptionsW_X-1,d0		; Display box
	move.w	#OptionsW_Y+7,d1
	move.w	#192,d2
	move.w	#Max_options*(Char_height+2)+1,d3
	jsr	Draw_standard_box
	move.l	Option_names_ptr,a1		; Print option names
	lea.l	Option_bits,a2
	move.w	#OptionsW_Y+9,d1
	move.w	Internal_flags,d2
	move.b	Options_mask,d3
	moveq.l	#1,d7
.Loop:	btst	d7,d3			; Masked ?
	bne.s	.Unmasked
	move.w	#28,Ink_colour		; Dark ink
	move.l	a1,a0			; Print option name
	move.w	#OptionsW_X+1,d0
	jsr	Put_text_line
	move.l	a0,a1
	bra.s	.Next
.Unmasked:	move.w	#31,Ink_colour		; Normal ink
	move.l	a1,a0			; Print option name
	move.w	#OptionsW_X+1,d0
	jsr	Put_text_line
	move.l	a0,a1
	move.b	(a2)+,d0			; Get bit number
	bclr	#7,d0			; Inverse ?
	beq.s	.Normal
	btst	d0,d2			; Yes -> Off or on ?
	beq.s	.On
	bra.s	.Off
.Normal:	btst	d0,d2			; No -> On or off ?
	beq.s	.Off
.On:	move.l	On_txt_ptr,a0			; On
	bra.s	.Do
.Off:	move.l	Off_txt_ptr,a0		; Off
.Do:	move.w	#OptionsW_X+168,d0		; Print on/off
	jsr	Put_text_line
.Next:	add.w	#Char_height+2,d1		; Next option
	addq.w	#1,d7
	cmp.w	#Max_options+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0-d3/d7/a0-a2
	rts

;*****************************************************************************
; [ Load NPC data ]
;   IN : a0 - Pointer to NPC data (.l)
; All registers are restored
;*****************************************************************************
Load_NPC_data:
	movem.l	d0-d2,-(sp)
	move.b	NPC_status_bits(a0),d0	; Get NPC type
	andi.b	#$03,d0
	cmp.b	#2,d0			; Object or monster ?
	bpl.s	.Exit
	moveq.l	#0,d2			; Get character number
	move.b	NPC_char_nr(a0),d2
	move.w	d2,Dialogue_char_nr		; Store
	tst.b	d0			; Party or true NPC ?
	bne	.NPC
	move.w	d2,d0			; Load character data
	moveq.l	#Party_char_file,d1
	jsr	Load_subfile
	move.b	d0,Dialogue_handle
	move.w	d2,d0			; Load character texts
	moveq.l	#Party_text_file,d1
	jsr	Load_subfile
	move.b	d0,Dialogue_text_handle
	bra	.Exit
.NPC:	move.w	d2,d0			; Load character data
	moveq.l	#NPC_char_file,d1
	jsr	Load_subfile
	move.b	d0,Dialogue_handle
	move.w	d2,d0			; Load text file
	moveq.l	#NPC_text_file,d1
	jsr	Load_subfile
	move.b	d0,Dialogue_text_handle
.Exit:	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Destroy NPC data ]
; All registers are restored
;*****************************************************************************
Destroy_NPC_data:
	move.l	d0,-(sp)
	move.b	Dialogue_handle,d0		; Destroy character data
	jsr	Free_memory
	move.b	Dialogue_text_handle,d0	; Destroy text file
	jsr	Free_memory
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Clear sold slots ]
; All registers are restored
;*****************************************************************************
Clear_sold_slots:
	movem.l	d7/a0,-(sp)
	Get	Sold_slots_handle,a0
	move.w	#(Items_per_char*Object_packet_size)/2-1,d7
.Loop:	clr.w	(a0)+
	dbra	d7,.Loop
	Free	Sold_slots_handle
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
; *** BATTLE ORDER : 2nd layer ***
BattleOrder_L2:
	dc.w 16,287,45,88+34		; Battle order area
	dc.b 2
	even
	dc.l Control_area,BattleOrder_L3

; *** BATTLE ORDER : 3rd layer ***
BattleOrder_L3:
	dc.w 16,16+31,45,45+33
	dc.b 1
	even
	dc.l .C2
.C2:	dc.w 64,64+31,45,45+33
	dc.b 2
	even
	dc.l .C3
.C3:	dc.w 112,112+31,45,45+33
	dc.b 3
	even
	dc.l .C4
.C4:	dc.w 160,160+31,45,45+33
	dc.b 4
	even
	dc.l .C5
.C5:	dc.w 208,208+31,45,45+33
	dc.b 5
	even
	dc.l .C6
.C6:	dc.w 256,256+31,45,45+33
	dc.b 6
	even
	dc.l .C7
.C7:	dc.w 16,16+31,88,88+34
	dc.b 7
	even
	dc.l .C8
.C8:	dc.w 64,64+31,88,88+34
	dc.b 8
	even
	dc.l .C9
.C9:	dc.w 112,112+31,88,88+34
	dc.b 9
	even
	dc.l .C10
.C10:	dc.w 160,160+31,88,88+34
	dc.b 10
	even
	dc.l .C11
.C11:	dc.w 208,208+31,88,88+34
	dc.b 11
	even
	dc.l .C12
.C12:	dc.w 256,256+31,88,88+34
	dc.b 12
	even
	dc.l 0

; *** LAYOUT 3 : 2nd layer ***
Lay3_L2:
	dc.w 16,191,139,215		; Object area
	dc.b 2
	even
	dc.l Control_area,Lay3Obj_L3

; *** LAYOUT 3 : 3rd layer ***
Lay3Obj_L3:
	dc.w 22,37,139,139+23
	dc.b 1
	even
	dc.l .C2
.C2:	dc.w 44,59,139,139+23
	dc.b 2
	even
	dc.l .C3
.C3:	dc.w 66,81,139,139+23
	dc.b 3
	even
	dc.l .C4
.C4:	dc.w 88,103,139,139+23
	dc.b 4
	even
	dc.l .C5
.C5:	dc.w 110,125,139,139+23
	dc.b 5
	even
	dc.l .C6
.C6:	dc.w 132,147,139,139+23
	dc.b 6
	even
	dc.l .C7
.C7:	dc.w 22,37,168,168+23
	dc.b 7
	even
	dc.l .C8
.C8:	dc.w 44,59,168,168+23
	dc.b 8
	even
	dc.l .C9
.C9:	dc.w 66,81,168,168+23
	dc.b 9
	even
	dc.l .C10
.C10:	dc.w 88,103,168,168+23
	dc.b 10
	even
	dc.l .C11
.C11:	dc.w 110,125,168,168+23
	dc.b 11
	even
	dc.l .C12
.C12:	dc.w 132,147,168,168+23
	dc.b 12
	even
	dc.l ScrollBar_L2

; *** SAVE GAME SELECT WINDOW : 1st layer ***
SavedSelW_L1:
	dc.w SavedSelW_X,SavedSelW_Y
	dc.w 0,255,8,78			; Saves area
	dc.b 1
	even
	dc.l 0,SavedSelW_L2

; *** SAVE GAME SELECT WINDOW : 2nd layer ***
SavedSelW_L2:
	dc.w 0,255,8,15			; Saves
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 0,255,16,22
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 0,255,23,29
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 0,255,30,36
	dc.b 4
	even
	dc.l .C5,0
.C5:	dc.w 0,255,37,43
	dc.b 5
	even
	dc.l .C6,0
.C6:	dc.w 0,255,44,50
	dc.b 6
	even
	dc.l .C7,0
.C7:	dc.w 0,255,51,57
	dc.b 7
	even
	dc.l .C8,0
.C8:	dc.w 0,255,58,64
	dc.b 8
	even
	dc.l .C9,0
.C9:	dc.w 0,255,65,71
	dc.b 9
	even
	dc.l .C10,0
.C10:	dc.w 0,255,72,78
	dc.b 10
	even
	dc.l 0,0

; *** OPTIONS WINDOW : 1st layer ***
OptionsW_L1:
	dc.w OptionsW_X,OptionsW_Y
	dc.w 0,191,8,43			; Options area
	dc.b 1
	even
	dc.l .C2,OptionsW_L2
.C2:	dc.w 160,160+31,47,47+16		; Exit icon
	dc.b 2
	even
	dc.l 0,0

; *** OPTIONS WINDOW : 2nd layer ***
OptionsW_L2:
	dc.w 0,191,8,15			; Options
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 0,191,16,22
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 0,191,23,29
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 0,191,30,36
	dc.b 4
	even
	dc.l .C5,0
.C5:	dc.w 0,191,37,43
	dc.b 5
	even
	dc.l 0,0

BattleOrder_pos_list:
x	set 0
	rept 6
	dc.w 16+x,45
x	set x+48
	endr
x	set 0
	rept 6
	dc.w 16+x,88
x	set x+48
	endr

Lay3_object_pos_list:
	dc.w 22,139,44,139,66,139
	dc.w 88,139,110,139,132,139
	dc.w 22,168,44,168,66,168
	dc.w 88,168,110,168,132,168

BattleOrder_HDOB:
	dc.w 0,0
	dc.w 2,34,5,0
	dc.l 0
	dc.b 0,-1
	dcb.w 6,0
Giant_eagle_HDOB:
	dc.w 0,0
	dc.w 2,29,5,0
	dc.l 0
	dc.b 0,0
	dcb.w 6,0

Second_CIL:
	dc.w Look_cicon,Hand_cicon,Talk_cicon
	dc.w Change_trans_cicon,Use_magic_cicon,Camp_cicon
	dc.w Automapper_cicon,Combat_pos_cicon,Disk_cicon
	dc.l Eye_action,Hand_action,Mouth_action
	dc.l Change_travel_mode,Cast_spell,Camp
	dc.l Automapper,Battle_order,Options_menu
	dc.l Second_CIL_evaluate
BattleOrder_CIL:
	dc.w 0,0,Exit_cicon
	dc.w 0,0,0
	dc.w 0,0,0
	dc.l 0,0,Exit_BattleOrder
	dc.l 0,0,0
	dc.l 0,0,0
	dc.l 0
Camp_CIL:
	dc.w Use_magic_cicon,0,Exit_cicon
	dc.w Read_scroll_cicon,0,0
	dc.w Zzz_cicon,0,0
	dc.l Cast_spell,0,Exit_camp
	dc.l Learn_spell,0,0
	dc.l Rest,0,0
	dc.l Camp_CIL_evaluate
Options_CIL:
	dc.w Quit_cicon,0,Exit_cicon
	dc.w Options_window_cicon,0,0
	dc.w Save_cicon,Load_cicon,0
	dc.l Quit_game,0,Pop_Module
	dc.l Options_window,0,0
	dc.l Save_game,Load_game,0
	dc.l Options_CIL_evaluate

Option_bits:
	dc.b $80+Music_flag_bit
	dc.b Fast_combat_bit
	dc.b Outline_text_bit
	dc.b Dungeon_floor_bit
	dc.b Dungeon_ceiling_bit
	even
