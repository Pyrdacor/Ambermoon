; Apres combat screen
; Written by J.Horneman (In Tune With The Universe)
; Start : 4-3-1993
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Apres combat ]
;*****************************************************************************
Apres_combat:
	sf	Battling			; Reset variables
	jsr	Set_spell_area
	jsr	Set_map_music
	cmp.b	#Combat_lost,Combat_result	; Everyone fled ?
	bne.s	.Not_over
	move.b	Apres_pool_handle,d0	; Free memory
	jsr	Free_memory
	jmp	Game_over			; Game over!
.Not_over:	cmp.b	#Combat_fled,Combat_result	; Everyone fled ?
	bne.s	.Heroic
	jsr	Restore_coordinates		; Back !
	sf	Success
	move.w	#Monster_delay_time,Monster_move_delay	; Wait
	move.b	Apres_pool_handle,d0	; Free memory
	jsr	Free_memory
	bra	.Leave
.Heroic:	move.w	Combat_char_index,d0	; Encounter event ?
	bpl.s	.No_event
	st	Success			; Success !
	bra.s	.Go_on
.No_event:	move.w	Map_nr,d1			; Get CD bit number
	subq.w	#1,d1
	mulu.w	#Max_chars,d1
	add.w	d1,d0
	moveq.l	#CD_bit_array,d1		; Set bit in CD array
	moveq.l	#1,d2
	jsr	Access_bit_array
	jsr	Get_CD_value		; Reset internal CD
.Go_on:	tst.w	Nr_apres_objects		; Any loot ?
	bne.s	.Loot
	tst.w	Apres_gold
	bne.s	.Loot
	tst.w	Apres_food
	beq.s	.No_loot
.Loot:	Push	Module,Apres_Mod		; Yes -> Divide the loot
	bra.s	.Exit
.No_loot:	move.b	Apres_pool_handle,d0	; Free memory
	jsr	Free_memory
	tst.l	Gained_experience		; Are you experienced ?
	beq.s	.Leave
	jsr	Divide_EP			; Divide EP
	tst.l	d0			; Any ?
	beq.s	.Leave
	lea.l	EP_divide_text,a1		; Make text list
	lea.l	Number,a0
	move.l	a0,4(a1)
	moveq.l	#5,d7			; Convert EP
	jsr	DecL_convert
	move.l	a1,TxtW_ptr		; Do text window
	Push	Module,TxtW_Mod
	jsr	Check_member_levels		; Check !
.Leave:	jsr	Reset_after_combat		; It's okay now
.Exit:	rts

;*****************************************************************************
; [ Reset after combat ]
; All registers are restored
;*****************************************************************************
Reset_after_combat:
	movem.l	d0/d7/a0/a1,-(sp)
; ---------- Clear combat conditions --------------
	lea.l	Party_handles,a0
	moveq.l	#6-1,d7
.Loop:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next
	Get	(a0),a1			; Clear battle conditions
	and.w	#Reset_mask,Body_conditions(a1)
	Free	(a0)
.Next:	addq.l	#1,a0			; Next
	dbra	d7,.Loop
; ---------- Reset active member ------------------
	move.w	Previous_active_member,d7	; Reset active member
	jsr	Activate_member
	beq.s	.Ok			; Possible ?
	move.w	Active_member,d7		; No -> Current leader OK ?
	jsr	Activate_member
	beq.s	.Ok			; Possible ?
	jsr	Select_new_active_member	; No -> Select new leader
.Ok:	jsr	Update_active_status	; Update displays
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Divide experience points ]
;  OUT : d0 - EP per member (.l)
; All registers are restored
;*****************************************************************************
Divide_EP:
	movem.l	d1/d7/a0/a1,-(sp)
	jsr	Count_members		; Divide over how many ?
	tst.w	d0			; Anyone ?
	bne.s	.Yes
	move.w	#134,d0			; "No-one !"
	jsr	Do_prompt
	moveq.l	#0,d0			; No EP
	bra.s	.Exit
.Yes:	move.l	Gained_experience,d1	; Calculate EP pro member
	beq.s	.Exit
	divu.w	d0,d1
	ext.l	d1
	tst.l	d1			; At least 1
	bne.s	.Notzero
	moveq.l	#1,d1
.Notzero:	lea.l	Party_handles,a0		; Divide EP
	moveq.l	#6-1,d7
.Loop:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next
	Get	(a0),a1
	move.w	Body_conditions(a1),d0	; Alive and kicking ?
	andi.w	#Alive_mask,d0
	bne.s	.Done
	add.l	d1,Experience_points(a1)	; Yes -> Experience
.Done:	Free	(a0)
.Next:	addq.l	#1,a0			; Next member
	dbra	d7,.Loop
	move.l	d1,d0			; Output
.Exit:	movem.l	(sp)+,d1/d7/a0/a1
	rts

;*****************************************************************************
; [ Apres Combat module ]
;*****************************************************************************
Apres_ModInit:
	move.w	Apres_gold,Current_gold	; Set
	move.w	Apres_food,Current_food
	jsr	Pool_apres_items		; Pool items
	moveq.l	#Trashpile_pic,d0		; Load picture
	jsr	Load_80x80_picture
	jsr	Load_object_graphics
	jsr	Apres_DisInit		; Build screen
	jsr	Divide_EP			; Divide EP
	tst.l	d0			; Any ?
	beq.s	.No_EP
	lea.l	EP_divide_text,a1		; Make text list
	lea.l	Number,a0
	move.l	a0,4(a1)
	moveq.l	#5,d7			; Convert EP
	jsr	DecL_convert
	moveq.l	#0,d0			; Print text
	move.l	a1,a0
	jsr	Display_text_and_wait
	jsr	Check_member_levels		; Check !
.No_EP:	jsr	Reset_after_combat		; It's okay now
	move.w	#133,d0
	jmp	Print_prompt

Apres_ModExit:
	move.b	Pic_80x80_handle,d0		; Free memory
	jsr	Free_memory
	move.b	Apres_pool_handle,d0
	jsr	Free_memory
	jsr	Free_object_graphics
	jmp	Destroy_ghosts		; Kill !

Apres_DisUpd:
	jsr	Update_gold		; Display gold & food
	jsr	Update_food
	jmp	Basic_DisUpd

Apres_DisInit:
	moveq.l	#Chest_layout,d0		; Show new layout
	jsr	Show_layout
	jsr	Display_80x80_picture	; Show picture
	move.w	#110,Gold_X		; Set gold & food positions
	move.w	#103,Gold_Y
	move.w	#303-44,Food_X
	move.w	#103,Food_Y
	lea.l	Apres_CIL,a0		; Show control icons
	jsr	Display_control_icons
	move.b	Apres_pool_handle,Slotbase_handle	; Display scroll bar
	clr.l	Slotbase_offset
	move.l	#Lay3_object_pos_list,Object_pos_list
	lea.l	Lay3_scroll_bar,a0
	move.w	Nr_apres_objects,Total_units(a0)
	clr.w	Scroll_thingy_Y(a0)
	jsr	Push_Scroll_bar
	jmp	Fade_in_bottom		; Fade in

Apres_DisExit:
	Pop	Scroll_bar
	jmp	Fade_out_bottom

Apres_CIL_evaluate:
; ---------- Any gold ? ---------------------------
	tst.w	Current_gold		; Well ?
	bne.s	.Gold_OK
	bset	#7,8(a0)			; Disable {Divide gold}
	bset	#7,14(a0)			; Disable {Transfer gold}
; ---------- Any food ? ---------------------------
.Gold_OK:	tst.w	Current_food		; Well ?
	bne.s	.Food_OK
	bset	#7,10(a0)			; Disable {Divide food}
	bset	#7,16(a0)			; Disable {Transfer food}
; ---------- Any items ? --------------------------
.Food_OK:	Get	Apres_pool_handle,a1	; Well ?
	move.w	Nr_apres_objects,d7
	bra.s	.Entry
.Loop:	tst.w	Object_index(a1)
	bne.s	.Exit
	addq.w	#Object_packet_size,a1
.Entry:	dbra	d7,.Loop
	bset	#7,12(a0)			; Disable	{View item}
.Exit:	Free	Apres_pool_handle
	rts

; ********** Apres combat - Exit ******************
Exit_Apres:
	move.b	Apres_pool_handle,d0	; Anything important left ?
	move.w	Nr_apres_objects,d7
	jsr	Check_for_vital_items
	bne.s	.Exit
	jsr	Exit_display		; No -> Exit apres screen
	Pop	Module
.Exit:	rts

; ********** Apres combat - Divide food ***********
Divide_food_APRES:
	move.w	Current_food,d0
	jsr	Divide_food
	move.w	d0,Current_food
	rts

; ********** Apres combat - Divide gold ***********
Divide_gold_APRES:
	move.w	Current_gold,d0
	jsr	Divide_gold
	move.w	d0,Current_gold
	rts

; ********** Apres combat - Transfer gold *********
Transfer_gold_APRES:
	moveq.l	#0,d0			; How much ?
	move.w	Current_gold,d0
	move.l	d0,Maximum_number
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
	move.l	InputNr_number,d0		; Remove gold
	sub.w	d0,Current_gold
	lea.l	Party_handles-1,a1		; Add gold
	add.w	Selected_member,a1
	Get	(a1),a0
	move.l	InputNr_number,d0
	add.w	d0,Gold_coins(a0)
	mulu.w	#Gold_weight,d0
	add.l	d0,Weight_normal(a0)
	Free	(a1)
.Exit:	rts

; ********** Apres combat - Transfer food *********
Transfer_food_APRES:
	moveq.l	#0,d0			; How much ?
	move.w	Current_food,d0
	move.l	d0,Maximum_number
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
; [ Pool apres items ]
; All registers are restored
;*****************************************************************************
Pool_apres_items:
	movem.l	d0-d2/d7/a0-a3,-(sp)
	Get	Apres_pool_handle,a1
; ---------- Try to pool same items ---------------
	move.l	Object_data_ptr,a0		; Do
	move.l	a1,a2
	move.w	Nr_apres_objects,d7
	bra	.Entry1
.Loop1:	move.w	Object_index(a2),d0		; Anything there ?
	beq	.Next1
	subq.w	#1,d0			; Yes -> Multiple ?
	mulu.w	#Item_data_size,d0
	btst	#Multiple,Item_bits_STATIC(a0,d0.l)
	beq	.Next1
	move.l	a1,a3			; Yes -> Try to pool
	move.w	Object_index(a2),d0
	moveq.l	#0,d1
	move.b	Quantity(a2),d1
.Loop2:	cmp.l	a2,a3			; End reached ?
	beq	.Next1
	cmp.w	Object_index(a3),d0		; Same item ?
	bne.s	.Next2
	cmpi.b	#99,Quantity(a3)		; Not full ?
	bgt.s	.Next2
	moveq.l	#0,d2			; Does it	fit in the slot ?
	move.b	Quantity(a3),d2
	add.w	d1,d2
	cmpi.w	#99,d2
	bls.s	.Fit
	moveq.l	#99,d2			; Calculate number that will
	sub.b	Quantity(a3),d2		;  fit
	sub.w	d2,d1
	move.b	#99,Quantity(a3)		; Fill slot
	sub.b	d2,Quantity(a2)		; Remove item(s)
	bra.s	.Next2
.Fit:	add.b	d1,Quantity(a3)		; Transfer completely
	clr.b	Quantity(a2)
	clr.w	Object_index(a2)
	bra.s	.Next1
.Next2:	addq.w	#Object_packet_size,a3	; Next packet
	bra.s	.Loop2
.Next1:	addq.w	#Object_packet_size,a2	; Next packet
.Entry1:	dbra	d7,.Loop1
; ---------- Try to move everything to the front --
	moveq.l	#0,d0			; Search all packets
	move.w	Nr_apres_objects,d7
	bra	.Entry3
.Loop3:	tst.w	Object_index(a1)		; Packet empty ?
	beq.s	.Delete
	addq.w	#1,d0			; No -> Count
	addq.w	#Object_packet_size,a1	; Next packet
.Entry3:	dbra	d7,.Loop3
	bra.s	.Done
.Delete:	move.l	a1,a2			; Yes -> Start moving
	bra.s	.Next4
.Loop4:	tst.w	Object_index(a1)		; Packet empty ?
	beq.s	.Next4
	Copy_packet a1,a2			; No -> Move
	clr.w	Object_index(a1)
	addq.w	#Object_packet_size,a2
	addq.w	#1,d0			; Count
.Next4:	addq.w	#Object_packet_size,a1	; Next packet
.Entry4:	dbra	d7,.Loop4
.Done:	Free	Apres_pool_handle
; ---------- Store number -------------------------
	addq.w	#5,d0			; Round to multiple of 6
	divu.w	#6,d0
	cmp.w	#2,d0			; (at least 12)
	bpl.s	.Ok
	moveq.l	#2,d0
.Ok:	mulu.w	#6,d0
	move.w	d0,Nr_apres_objects		; Store
.Exit:	movem.l	(sp)+,d0-d2/d7/a0-a3
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Apres_CIL:	dc.w 0,0,Exit_cicon
	dc.w 0,Divide_gold_cicon,Divide_food_cicon
	dc.w View_item_cicon,Transfer_gold_cicon,Transfer_food_cicon
	dc.l 0,0,Exit_Apres
	dc.l 0,Divide_gold_APRES,Divide_food_APRES
	dc.l View_item_LAY3,Transfer_gold_APRES,Transfer_food_APRES
	dc.l Apres_CIL_evaluate
