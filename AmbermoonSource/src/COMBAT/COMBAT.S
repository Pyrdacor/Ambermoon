; Combat screen
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
; [ Check for combat ]
;*****************************************************************************
Combat_check:
	tst.b	Combat_req		; Combat ?
	beq	.Exit
	jsr	Wait_4_unclick		; Yes
	sf	Combat_req		; Clear flags
	sf	Could_not_flee
	move.w	#200,d0			; Combat requester
	jsr	Prompt_req
	tst.b	d0			; Wanna fight ?
	bne	.Yes
	Get	Active_handle,a0		; No -> Feel lucky, punk ?
	move.w	ADexterity(a0),d0
	add.w	ADexterity+Magic(a0),d0
	add.w	ALuck(a0),d0
	add.w	ALuck+Magic(a0),d0
	Free	Active_handle
	move.w	#150,d1
	jsr	Probe
	bmi	.Failed
	jsr	Restore_coordinates		; Yes -> Exit
	move.w	#Monster_delay_time,Monster_move_delay	; Wait
	bra	.Exit
.Failed:	st	Could_not_flee		; Monster advantage !!!
.Yes:	move.w	Map_Xcoord,d0		; Get combat background
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	andi.l	#$f0000000,d0
	rol.l	#4,d0
	move.w	d0,Combat_background	; Store
	move.w	Active_member,Previous_active_member	; Save
	jsr	Exit_display		; Fight !
	Push	Module,Combat_Mod
	jsr	Init_display
.Exit:	rts

;*****************************************************************************
; [ Combat screen ]
;*****************************************************************************
Combat_ModInit:
	moveq.l	#0,d0			; Stop music
	jsr	Set_music
	st	Battling			; Set flags 'n stuff
	move.w	#Combat_spell_area,Spell_area_type
	move.w	Active_member,d7		; Activate member (!)
	jsr	Activate_member
	lea.l	Combat_data,a0		; Clear combat data
	moveq.l	#0,d0
	move.w	#Combat_data_size/2-1,d7
.Loop:	move.w	d0,(a0)+
	dbra	d7,.Loop
	jsr	Init_COMOBs		; Initialize
	LOCAL
; ---------- Load combat data ---------------------
	move.w	Combat_background,d0	; Convert background number
	cmp.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl.s	.3D
	lea.l	Combat_bg_2D_table,a0	; 2D
	bra.s	.Do
.3D:	lea.l	Combat_bg_3D_table,a0	; 3D
.Do:	lsl.w	#2,d0			; Get real number
	add.w	d0,a0
	moveq.l	#0,d0
	move.b	(a0),d0
	moveq.l	#Combat_background_file,d1	; Load background
	jsr	Load_subfile
	move.b	d0,Combat_background_handle
	move.b	1(a0),d0			; More than one palette ?
	cmp.b	2(a0),d0
	bne.s	.Yes
	cmp.b	3(a0),d0
	bne.s	.Yes
	moveq.l	#0,d1			; No
	bra.s	.Skip
.Yes:	lea.l	Time_table,a1		; Yes -> Get time/light
	add.w	Hour,a1
	moveq.l	#0,d1
	move.b	(a1),d1
	cmp.w	#2,d1			; Night ?
	seq	Night_palette
.Skip:	moveq.l	#0,d0			; Get palette number
	move.b	1(a0,d1.w),d0
	move.w	d0,Combat_palette_nr	; Store
	move.w	Monstergroup_nr,d0		; Load monster group
	moveq.l	#Monster_data_file,d1
	jsr	Load_subfile
	move.b	d0,Monstergroup_handle
	LOCAL
; ---------- Load monster data --------------------
	Get	Monstergroup_handle,a0	; Make batch
	lea.l	Batch,a1
	moveq.l	#0,d0
	moveq.l	#Max_monsters-1,d7
.Loop:	move.w	(a0)+,d1			; Get monster number
	beq.s	.Next			; Anything there ?
	move.w	d1,(a1)+			; Yes -> Insert
	addq.w	#1,d0			; Count
.Next:	dbra	d7,.Loop
	move.w	d0,Nr_monsters		; Store
	move.w	d0,Remaining_monsters
	lea.l	Batch,a0			; Load batch
	lea.l	Monster_data_handles,a1
	moveq.l	#Monster_char_file,d1
	jsr	Load_batch_of_subfiles
	Free	Monstergroup_handle
	LOCAL
; ---------- Fill combat array (party) ------------
	lea.l	Combat_party,a0
	lea.l	Party_handles,a1
	lea.l	Order,a2
	lea.l	Party_positions,a3
	lea.l	Combat_matrix,a4
	moveq.l	#1,d7
.Loop:	tst.b	(a1)			; Anyone there ?
	beq	.Next
	Get	(a1),a5
	move.w	Body_conditions(a5),d0	; Able to fight ?
	andi.w	#Fight_mask,d0
	bne.s	.Done	
	move.b	(a1),Part_handle(a0)	; Set data
	move.b	#1,Part_type(a0)
	move.b	d7,Part_nr(a0)
	move.b	Char_class(a5),Part_icon_nr(a0)
	moveq.l	#0,d2			; Get battle order position
	move.b	(a2),d2
	add.w	d2,d2			; Get tactic coordinates
	moveq.l	#0,d0
	move.b	0(a3,d2.w),d0
	moveq.l	#0,d1
	move.b	1(a3,d2.w),d1
	move.w	d0,Part_X(a0)		; Store
	move.w	d1,Part_Y(a0)
	mulu.w	#6,d1			; Insert participant
	add.w	d1,d0			;  in matrix
	lsl.w	#2,d0
	move.l	a0,0(a4,d0.w)
.Done:	Free	(a1)
.Next:	lea.l	Participant_data_size(a0),a0	; Next member
	addq.l	#1,a1
	addq.l	#1,a2
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	LOCAL
; ---------- Fill combat array (monsters) ---------
	lea.l	Combat_monsters,a0
	lea.l	Monster_data_handles,a1
	Get	Monstergroup_handle,a2
	lea.l	Monster_positions,a3
	lea.l	Combat_matrix,a4
	moveq.l	#1,d6
	moveq.l	#Max_monsters-1,d7
.Loop:	tst.w	(a2)			; Anything there ?
	beq	.Next
	move.b	(a1)+,d1			; Set data
	move.b	d1,Part_original_handle(a0)
	move.b	#2,Part_type(a0)
	move.b	d6,Part_nr(a0)
	move.w	(a2),Part_work(a0)		; Temporary !
	jsr	Clone_monster_data		; Make a clone
	move.b	d0,Part_handle(a0)
	moveq.l	#0,d0			; Get tactic coordinates
	move.b	(a3),d0
	moveq.l	#0,d1
	move.b	1(a3),d1
	move.w	d0,Part_X(a0)		; Store
	move.w	d1,Part_Y(a0)
	mulu.w	#6,d1			; Insert participant
	add.w	d1,d0			;  in matrix
	lsl.w	#2,d0
	move.l	a0,0(a4,d0.w)
	lea.l	Participant_data_size(a0),a0	; Next participant
	addq.w	#1,d6
.Next:	addq.l	#2,a2			; Next monster
	addq.l	#2,a3
	dbra	d7,.Loop
	move.b	Monstergroup_handle,d0	; Discard monster group
	jsr	Free_pointer
	jsr	Free_memory
	LOCAL
; ---------- Prepare monsters for combat ----------
	lea.l	Combat_monsters,a0		; Do all monsters
	move.w	Nr_monsters,d7
	bra.s	.Entry
.Loop:	move.b	#%00001100,Part_flags(a0)	; Long- and short-range
	Get	Part_handle(a0),a1
	tst.b	Spell_class_counter(a1)	; Know any spells ?
	beq.s	.No
	bset	#Part_magic_cap,Part_flags(a0)	; Yes
.No:	Free	Part_handle(a0)
	lea.l	Participant_data_size(a0),a0	; Next
.Entry:	dbra	d7,.Loop
	LOCAL
; ---------- Load & recolour monster graphics -----
	lea.l	Combat_monsters,a0		; Do all monsters
	moveq.l	#Monster_gfx_file,d1
	move.w	Nr_monsters,d7
	bra.s	.Entry
.Loop:	Get	Part_handle(a0),a1		; Get graphics number
	moveq.l	#0,d0
	move.b	Monster_picture_load_nr(a1),d0
	Free	Part_handle(a0)
	move.w	d0,d2			; Store icon number
	addi.w	#10-1,d2
	move.b	d2,Part_icon_nr(a0)
	jsr	Load_subfile		; Load monster graphics
	move.b	d0,Part_gfx_handle(a0)	; Store
	lea.l	Participant_data_size(a0),a0	; Next
.Entry:	dbra	d7,.Loop
	jsr	Recolour_monsters		; Recolour
	LOCAL
; ---------- Initialize monster COMOBs ------------
	lea.l	Combat_monsters,a1		; For all monsters
	move.w	Nr_monsters,d7
	bra	.Entry
.Loop:	jsr	Add_COMOB			; Add COMOB
	move.w	Part_X(a1),d0		; Get tactic coordinates
	move.w	Part_Y(a1),d1
	jsr	Calculate_3D_coordinates	; Convert
	move.w	d0,COMOB_3D_X(a0)		; Store 3D coordinates
	clr.w	COMOB_3D_Y(a0)
	move.w	d1,COMOB_3D_Z(a0)
	Get	Part_original_handle(a1),a2	; Copy data
	move.w	Monster_display_width(a2),COMOB_Display_width(a0)
	move.w	Monster_display_height(a2),COMOB_Display_height(a0)
	move.w	Monster_width(a2),COMOB_Source_width(a0)
	move.w	Monster_height(a2),COMOB_Source_height(a0)
	tst.b	Anim_frame+Appear_anim-1(a2)	; Appear animation ?
	beq.s	.No
	moveq.l	#0,d0			; Yes -> Get start frame
	move.b	Anim_dat+(Appear_anim-1)*32(a2),d0
	bra.s	.Store
.No:	moveq.l	#0,d0			; Get default frame
	move.b	Anim_dat(a2),d0
.Store:	move.w	d0,COMOB_Frame(a0)		; Store
	move.w	d0,Part_default_frame(a1)
	Free	Part_original_handle(a1)
	move.b	Part_gfx_handle(a1),COMOB_Gfx_handle(a0)
	move.l	a0,Part_COMOB_ptr(a1)	; Store pointer to COMOB
	lea.l	Participant_data_size(a1),a1	; Next monster
.Entry:	dbra	d7,.Loop
	LOCAL
; ---------- Load more stuff ----------------------
	move.w	Combat_palette_nr,d0	; Load palette
	moveq.l	#Palette_file,d1
	jsr	Load_subfile
	move.b	d0,d7
	jsr	Claim_pointer
	move.l	d0,a0
	lea.l	Combat_pal,a1		; Copy palette
	lea.l	Combat_backup_pal,a2
	moveq.l	#Pal_size-1,d6
.Loop:	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbra	d6,.Loop
	move.b	d7,d0			; Destroy palette
	jsr	Free_pointer
	jsr	Free_memory
	moveq.l	#Combat_gfx_file,d0		; Load combat graphics
	jsr	Load_file
	move.b	d0,FXGFX_handle
	LOCAL
; ---------- Do -----------------------------------
	jsr	Update_control_status	; Set control status
	move.l	#2*Combat_height*Bytes_per_line,d0	; Make zoom screen
	jsr	Allocate_CHIP
	move.b	d0,Combat_zoom_screen_handle
	clr.w	Nr_apres_objects		; Initialize apres pool
	move.l	#((6+Max_monsters)*(9+Items_per_char))*Object_packet_size,d0
	jsr	Allocate_memory
	jsr	Clear_memory
	move.b	d0,Apres_pool_handle
	jsr	Reset_combat		; Clear actions & targets
	jsr	Combat_DisInit		; Build screen
	moveq.l	#Combat_music,d0		; Start music
	moveq.l	#0,d1
	jsr	Set_music
; ---------- Let monsters appear ------------------
	sf	COMOBs_blocked		; Start display
	lea.l	Combat_monsters,a0		; For all monsters
	move.w	Nr_monsters,d7
	bra	.Entry
.Loop:	Get	Part_original_handle(a0),a1	; Appear animation ?
	move.b	Anim_frame+Appear_anim-1(a1),d0
	Free	Part_original_handle(a0)
	tst.b	d0
	beq.s	.Next
	Set_anim	Appear_anim,a0		; Yes -> Appear !
	jsr	Wait_4_animation
	Get	Part_original_handle(a0),a1	; Get default frame
	moveq.l	#0,d0
	move.b	Anim_dat(a1),d0
	Free	Part_original_handle(a0)
	move.w	d0,Part_default_frame(a0)	; Store
	move.l	Part_COMOB_ptr(a0),a1
	move.w	d0,COMOB_Frame(a1)
.Next:	lea.l	Participant_data_size(a0),a0	; Next monster
.Entry:	dbra	d7,.Loop
	st	Random_animating		; Start random animations
	LOCAL
; ---------- Start 1st round when flight failed ---
	tst.b 	Could_not_flee		; Could not flee ?
	beq.s	.Exit
	sf 	Could_not_flee		; They got you !
	move.w	#203,d0
	jsr	Do_prompt
	jsr	OK_combat			; Fight !
.Exit:	rts

Combat_ModExit:
	lea.l	Combat_monsters,a0		; Free monster memory
	move.w	Nr_monsters,d7
	subq.w	#1,d7
.Loop:	move.b	Part_handle(a0),d0
	jsr	Free_memory
	move.b	Part_original_handle(a0),d0
	jsr	Free_memory
	move.b	Part_gfx_handle(a0),d0
	jsr	Free_memory
	lea.l	Participant_data_size(a0),a0	; Next monster
	dbra	d7,.Loop
	move.b	FXGFX_handle,d0		; Free memory
	jsr	Free_memory
	move.b	Combat_zoom_screen_handle,d0
	jsr	Free_memory
	move.b	Combat_background_handle,d0
	jsr	Free_memory
	move.b	Tactic_bg_handle,d0
	jsr	Free_memory
	moveq.l	#0,d0			; Stop music
	jsr	Set_music
	tst.b	Reload_map_data		; Reload map data ?
	beq.s	.No
	sf	Reload_map_data		; Yes
	cmp.b	#Map_3D,Current_map_type	; 2D or 3D map ?
	bpl.s	.3D_map
	jsr	Load_2D_map_data
	move.w	Travel_mode,d0		; Set initial travelmode
	jsr	Set_new_travel_mode
	bra.s	.No
.3D_map:	jsr	Load_3D_map_data
.No:	jsr	Set_map_music		; Reset music
	jsr	Fade_out_bottom
	jmp	Apres_combat

Combat_DisInit:
	moveq.l	#Combat_layout,d0		; Show new layout
	jsr	Show_layout
	jsr	Get_tactic_window		; Save background
	lea.l	Combat_CIL,a0		; Show control icons
	jsr	Display_control_icons
	st	Update_command		; Show all
	jsr	Combat_DisUpd
	jsr	Draw_combat_screen
	jmp	Fade_in_bottom

Combat_DisUpd:
	jsr	Draw_tactic_window		; Display tactic window
	jsr	Show_active_member
	move.l	Active_participant,a0	; Any action ?
	tst.b	Part_action(a0)
	beq.s	.No
	jsr	Show_active_target		; Yes -> Show target
.No:	jsr	Draw_tactic_icons		; Icons
	jsr	Display_combat_spells	; Spells
	jmp	Basic_DisUpd		; The usual

Combat_CIL_evaluate:
	move.l	Active_participant,a1
	Get	Active_handle,a2
	move.w	Body_conditions(a2),d7
; ---------- Flight possible ? --------------------
	cmp.w	#4,Part_Y(a1)		; On bottom row ?
	bne.s	.Off1
	move.w	d7,d0
	andi.w	#Flee_mask,d0
	beq.s	.Ok1
.Off1:	bset	#7,(a0)			; Disable {Flee}
; ---------- Movement possible ? ------------------
.Ok1:	move.w	d7,d0
	andi.w	#Move_mask,d0
	beq.s	.Ok2
	bset	#7,6(a0)			; Disable {Move}
; ---------- Attack possible ? --------------------
.Ok2:	move.w	Damage(a2),d0		; Get damage
	add.w	Damage_magic(a2),d0
	tst.w	d0			; Any ?
	beq.s	.Off2
	move.w	d7,d0
	andi.w	#Attack_mask,d0
	beq.s	.Ok3
.Off2:	bset	#7,12(a0)			; Disable {Attack}
; ---------- Parade possible ? --------------------
.Ok3:	move.w	d7,d0
	andi.w	#Parade_mask,d0
	beq.s	.Ok4
	bset	#7,14(a0)			; Disable {Parade}
; ---------- Magic possible ? ---------------------
.Ok4:	tst.b	Spell_class_counter(a2)	; Any spell classes	?
	beq.s	.Off3
	move.w	d7,d0			; Capable ?
	andi.w	#Magic_mask,d0
	bne.s	.Off3
	btst	#Blind,d7			; Blind ?
	beq.s	.Ok5
	move.b	Char_class(a2),d0		; Can still use magic ?
	move.w	#Blind_magic_mask,d1
	btst	d0,d1
	bne.s	.Ok5
.Off3:	bset	#7,16(a0)			; Disable {Use magic}
; ---------- Advance possible ? -------------------
.Ok5:	Free	Active_handle
	lea.l	Combat_matrix+2*6*4,a1	; Monsters in front rows ?
	moveq.l	#6*2-1,d7
.Loop1:	tst.l	(a1)			; Anything ?
	beq.s	.Next1
	move.l	(a1),a2			; Monster ?
	cmp.b	#2,Part_type(a2)
	beq.s	.Off4
.Next1:	addq.l	#4,a1			; Next
	dbra	d7,.Loop1
	bra.s	.Ok6
.Off4:	bset	#7,8(a0)			; Disable {Advance}
.Ok6:	rts

; ********** Combat screen - Flee *****************
Flee_combat:
	move.l	Active_participant,a0
	move.w	#-1,Part_target(a0)		; Store
	move.b	#Flee_action,Part_action(a0)
	rts

; ********** Combat screen - Move *****************
Move_combat:
	move.l	Active_participant,a1
	move.l	a1,a0			; Get occupied targets
	jsr	Get_occupied_targets
	move.l	d0,Target_mask
	move.l	d0,d1
	jsr	Check_movement_range	; Find possible targets
	and.l	d0,Target_mask		; No unreachable targets
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	tst.l	d0			; Can you go anywhere ?
	bne.s	.Yes
	move.w	#202,d0			; Boxed in !
	jsr	Do_prompt
	bra	.Exit
.Yes:	move.l	d0,Tactic_mask		; Store mask
	move.w	#201,ItemSelect_prompt	; Move where ?
	move.l	#Show_move_tactic,Tactic_draw_vector
	Push	Module,TacticSel_Mod
	move.w	Selected_tactic,d0		; Anywhere ?
	bmi	.Exit
	move.w	d0,Part_target(a1)		; Yes -> Store
	move.b	#Move_action,Part_action(a1)
.Exit:	rts

; ********** Combat screen - Advance **************
Advance:
; ---------- Tell ---------------------------------
	move.w	#233,d0			; "The party advances !"
	jsr	Do_prompt
; ---------- Show ---------------------------------
	lea.l	Combat_matrix,a0		; Set vectors
	moveq.l	#6*2-1,d7
.Loop:	tst.l	(a0)
	beq.s	.Next
	move.l	(a0),a1
	move.l	Part_COMOB_ptr(a1),a1
	move.w	#-(128/Move_steps),COMOB_3D_vector_Z(a1)
.Next:	addq.l	#4,a0
	dbra	d7,.Loop
	LOCAL
	moveq.l	#Move_steps-1,d7		; Show movement
.Loop:	st	Update_command
	jsr	Update_combat_screen
	dbra	d7,.Loop
	LOCAL
	lea.l	Combat_matrix,a0		; Clear vectors
	moveq.l	#6*2-1,d7
.Loop:	tst.l	(a0)
	beq.s	.Next
	move.l	(a0),a1
	move.l	Part_COMOB_ptr(a1),a1
	clr.w	COMOB_3D_vector_Z(a1)
.Next:	addq.l	#4,a0
	dbra	d7,.Loop
	LOCAL
; ---------- Do -----------------------------------
	lea.l	Combat_matrix+(6*2-1)*4,a0	; Move all monsters down
	moveq.l	#6*2-1,d7
.Loop:	tst.l	(a0)
	beq.s	.Next
	move.l	(a0),a1
	clr.l	(a0)
	addq.w	#1,Part_Y(a1)
	move.l	a1,6*4(a0)
.Next:	subq.l	#4,a0
	dbra	d7,.Loop
	rts

; ********** Combat screen - Attack ***************
Attack:
; ---------- Check weapon -------------------------
	Get	Active_handle,a0
	lea.l	Char_inventory+Right_hand_slot(a0),a1
	move.w	Object_index(a1),d0		; Get item in right hand
	beq	.Close			; Nothing ? -> Close range
	move.l	Object_data_ptr,a1		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	cmp.b	#Longrange_itemtype,Item_type(a1)	; Long range ?
	bne	.Close
; ---------- Check long-range weapon --------------
	lea.l	Char_inventory+Left_hand_slot(a0),a2
	move.w	Object_index(a2),d0		; Get item in left hand
	Free	Active_handle
	move.b	Ammo_use_ID(a1),d1		; Get required ammo ID
	beq	.Ammo_OK			; (if any!)
	tst.w	d0			; Anything ?
	beq.s	.No_ammo
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	cmp.b	Ammo_ID(a2),d1		; Is correct ?
	beq	.Ammo_OK
.No_ammo:	move.w	#204,d0			; No ammo !
	jsr	Do_prompt
	bra	.Exit
; ---------- Determine long-range targets ---------
.Ammo_OK:	move.l	Active_participant,a1
	move.l	a1,a0
	jsr	Get_longrange_targets
	move.l	d0,Tactic_mask		; Store mask
; ---------- Select long-range target -------------
	move.w	#205,ItemSelect_prompt	; Attack what ?
	move.l	#Show_attack_tactic,Tactic_draw_vector
	Push	Module,TacticSel_Mod
	move.w	Selected_tactic,d0		; Anywhere ?
	bmi	.Exit
	move.w	d0,Part_target(a1)		; Store
	move.b	#Long_range_action,Part_action(a1)
	bra	.Exit
; ---------- Determine close-range targets --------
.Close:	Free	Active_handle
	move.l	Active_participant,a1
	move.l	a1,a0
	jsr	Get_closerange_targets	; Any targets ?
	tst.l	d0
	bne.s	.Yes
	move.w	#206,d0			; Out of reach !
	jsr	Do_prompt
	bra	.Exit
.Yes:	move.l	d0,Tactic_mask		; Store mask
; ---------- Select close-range target ------------
	move.w	#205,ItemSelect_prompt	; Attack what ?
	move.l	#Show_attack_tactic,Tactic_draw_vector
	Push	Module,TacticSel_Mod
	move.w	Selected_tactic,d0		; Anywhere ?
	bmi	.Exit
	move.w	d0,Part_target(a1)		; Yes -> Store
	move.b	#Close_range_action,Part_action(a1)
.Exit:	rts

; ********** Combat screen - Parade ***************
Parade:
	move.l	Active_participant,a0
	move.w	#-1,Part_target(a0)		; Store
	move.b	#Parade_action,Part_action(a0)
	rts

; ********** Combat screen - OK *******************
OK_combat:
	lea.l	CombatDisplay_Mod,a0
	jmp	Push_Module

;*****************************************************************************
; [ Do combat round ]
; No registers are restored
;*****************************************************************************
Do_combat_round:
	st	Fighting			; Start !
	sf	Random_animating
	jsr	Destroy_ghosts
	move.w	#208,d0			; Remove icons
	move.w	#143,d1
	moveq.l	#96,d2
	moveq.l	#51,d3
	jsr	Draw_standard_box2
	addi.w	#32,d0			; Display weapons
	addq.w	#7,d1
	moveq.l	#28,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#36,d7
	Get	FXGFX_handle,a0
	add.l	#Fighting_FXGFX,a0
	jsr	Put_masked_block
	Free	FXGFX_handle
	jsr	Update_screen
; ---------- Determine actions for monsters -------
	jsr	Calculate_global_danger
	lea.l	Combat_monsters,a0
	move.w	Nr_monsters,d7
	bra.s	.Entry
.Loop:	tst.b	Part_type(a0)		; Present ?
	beq.s	.Next
	btst	#Part_uncontrol,Part_flags(a0)	; Under control ?
	bne.s	.Next
	clr.b	Part_action(a0)		; Yes -> Select action
	clr.w	Part_target(a0)
	jsr	Determine_monster_action
.Next:	lea.l	Participant_data_size(a0),a0	; Next monster
.Entry:	dbra	d7,.Loop
	LOCAL
; ---------- Insert party members in speed list ---
	lea.l	Combat_party,a0
	lea.l	Combat_speed_list,a1
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop:	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next
	btst	#Part_uncontrol,Part_flags(a0)	; Under control ?
	beq.s	.Yes
	jsr	Select_uncontrollable_action	; No
	bra.s	.Go_on
.Yes:	addq.w	#1,d5			; Yes -> Count
.Go_on:	move.l	a0,(a1)+			; Insert
	addq.w	#1,d6
.Next:	lea.l	Participant_data_size(a0),a0	; Next member
	dbra	d7,.Loop
	move.w	d5,Remaining_members	; Store
	LOCAL
; ---------- Insert monsters in speed list --------
	lea.l	Combat_monsters,a0
	moveq.l	#0,d5
	move.w	Nr_monsters,d7
	bra.s	.Entry
.Loop:	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next
	btst	#Part_uncontrol,Part_flags(a0)	; Under control ?
	beq.s	.Yes
	jsr	Select_uncontrollable_action	; No
.Yes:	move.l	a0,(a1)+			; Insert
	addq.w	#1,d5
	addq.w	#1,d6
.Next:	lea.l	Participant_data_size(a0),a0	; Next monster
.Entry:	dbra	d7,.Loop
	move.w	d5,Remaining_monsters	; Store
	move.w	d6,Nr_participants
	LOCAL
; ---------- Sort participants on speed -----------
	move.w	d6,d7			; Do
	lea.l	Compare_participants,a0
	lea.l	Swap_participants,a1
	lea.l	Combat_speed_list,a6
	jsr	Shellsort
; ---------- Handle all participants --------------
	lea.l	Combat_speed_list,a1
	move.w	Nr_participants,d7
	subq.w	#1,d7
.Loop1:	move.l	(a1)+,a0			; Get participant data
; ***** Execute chosen action *****
	moveq.l	#0,d0			; Any action ?
	move.b	Part_action(a0),d0
	beq	.Next1
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	bne.s	.Monster1
	move.w	#White,Combat_ink_colour	; Party
	sf	Party_or_monster
	bra.s	.Go_on1
.Monster1:	move.w	#Light_red,Combat_ink_colour	; Monster
	st	Party_or_monster
	jsr	Wait_4_animation		; Finish animation
.Go_on1:	lea.l	Combat_action_table,a2	; Get action data
	subq.w	#1,d0
	mulu.w	#6,d0
	add.w	d0,a2
	Get	Part_handle(a0),a3		; Get conditions
	move.w	Body_conditions(a3),d0
	Free	Part_handle(a0)
	and.w	4(a2),d0			; Capable of this action ?
	beq.s	.Yes
	clr.b	Part_action(a0)		; No -> Reset action
	move.w	#-1,Part_target(a0)
	bra	.Next1
.Yes:	movem.l	d0-d7/a0-a6,-(sp)		; Yes -> Execute action
	move.l	(a2),a2
	jsr	(a2)
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	Update_control_status	; Remove incapable participants
	jsr	Update_combat_screen
	jsr	Update_combat_screen	; !
; ***** Check for end of battle *****
	tst.w	Remaining_members		; All players gone ?
	bne.s	.Ok
	tst.w	Fled_members		; Any fled ?
	bne.s	.Chicken
	move.b	#Combat_lost,Combat_result	; No -> Lost...
	Pop	Module			; Leave combat
	Pop	Module
	bra	.Leave
.Chicken:	move.b	#Combat_fled,Combat_result	; Yes -> Fled !
	Pop	Module			; Leave combat
	Pop	Module
	bra	.Leave
.Ok:	tst.w	Remaining_monsters		; All monsters gone ?
	bne.s	.Next1
	move.b	#Combat_won,Combat_result	; Won !
	Pop	Module			; Leave combat
	Pop	Module
	bra	.Leave
.Next1:	dbra	d7,.Loop1			; Next participant
	jsr	Erase_PA			; Erase last message
	jsr	Update_screen
; ---------- Check if leader is still capable -----
	Get	Active_handle,a0		; Leader still capable ?
	move.w	Body_conditions(a0),d0
	Free	Active_handle
	andi.w	#Active_mask,d0
	beq.s	.Skip
	jsr	Select_new_active_member	; No -> Select new leader
; ---------- Advance monsters ---------------------
.Skip:	lea.l	Combat_matrix+3*6*4,a0	; No -> 4th row empty ?
	moveq.l	#6-1,d7
.Loop2:	tst.l	(a0)+
	bne.s	.Exit
	dbra	d7,.Loop2
	cmp.w	#1,Remaining_members	; More than one left ?
	bls.s	.Exit
	move.w	#226,d0			; "The monsters advance !"
	jsr	Do_prompt
	moveq.l	#6-1,d7			; Move all party members up
.Loop3:	tst.l	(a0)
	beq.s	.Next3
	move.l	(a0),a1
	clr.l	(a0)
	subq.w	#1,Part_Y(a1)
	move.l	a1,-6*4(a0)
.Next3:	addq.l	#4,a0
	dbra	d7,.Loop3
.Exit:	lea.l	Combat_CIL,a0		; Show control icons
	jsr	Display_control_icons
	Pop	Module
	move.w	#31,Combat_ink_colour	; Reset ink
.Leave:	sf	Fighting			; Stop !
	st	Random_animating
	jmp	Update_screen

;*****************************************************************************
; [ Update participant control status ]
; All registers are restored
;*****************************************************************************
Update_control_status:
	movem.l	d0/d1/d7/a0-a2,-(sp)
	lea.l	Combat_matrix,a1		; Search matrix
	moveq.l	#30-1,d7
.Loop:	tst.l	(a1)			; Anything there ?
	beq	.Next
	move.l	(a1),a0
	Get	Part_handle(a0),a2		; Get conditions
	move.w	Body_conditions(a2),d0
	Free	Part_handle(a0)
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	beq	.Party
; ---------- Check monster ------------------------
	move.w	d0,d1			; Monster -> Participating ?
	andi.w	#Fight_mask,d1
	beq.s	.Yes1
	subq.w	#1,Remaining_monsters	; Count down
	jsr	Remove_participant		; Remove
	bra.s	.Next
.Yes1:	andi.w	#Control_mask,d0		; Controllable ?
	beq.s	.Control1
	bset	#Part_uncontrol,Part_flags(a0)	; No -> News ?
	bne.s	.Next
	clr.b	Part_action(a0)		; Yes -> Reset action
	move.w	#-1,Part_target(a0)
	bra.s	.Next
.Control1:	bclr	#Part_uncontrol,Part_flags(a0)	; Yes
	bra.s	.Next
; ---------- Check party --------------------------
.Party:	move.w	d0,d1			; Party -> Participating ?
	andi.w	#Fight_mask,d1
	beq.s	.Yes2
	subq.w	#1,Remaining_members	; No -> Count down
	jsr	Remove_participant		; Remove
	bra.s	.Next
.Yes2:	andi.w	#Control_mask,d0		; Controllable ?
	beq.s	.Control2
	bset	#Part_uncontrol,Part_flags(a0)	; No -> News ?
	bne.s	.Next
	clr.b	Part_action(a0)		; Yes -> Reset action
	move.w	#-1,Part_target(a0)
	subq.w	#1,Remaining_members	; Count down
	bra.s	.Next
.Control2:	bclr	#Part_uncontrol,Part_flags(a0)	; Yes -> News ?
	beq.s	.Next
	addq.w	#1,Remaining_members	; Yes -> Count back up
.Next:	addq.l	#4,a1			; Next matrix entry
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d1/d7/a0-a2
	rts

;*****************************************************************************
; [ Combat action - Move ]
;   IN : a0 - Pointer to participant data (.l)
; No registers are restored
;*****************************************************************************
Do_move:
	tst.b	Party_or_monster		; Party or monster ?
	bne	.Monster
; ---------- Move party member --------------------
	move.w	#228,d0			; " moves!"
	jsr	Do_part_prompt
	lea.l	Combat_matrix,a1
	move.w	Part_target(a0),d0		; Get destination
	lsl.w	#2,d0
	tst.l	0(a1,d0.w)		; Empty ?
	beq.s	.Empty
	move.w	#229,d0			; " blocked!"
	jsr	Do_part_prompt
	bra	.Exit
.Empty:	move.l	a0,0(a1,d0.w)		; Copy to destination
	move.w	Part_Y(a0),d0		; Clear source
	mulu.w	#6,d0
	add.w	Part_X(a0),d0
	lsl.w	#2,d0
	clr.l	0(a1,d0.w)
	moveq.l	#0,d0			; Set new coordinates
	move.w	Part_target(a0),d0
	divu.w	#6,d0
	move.w	d0,Part_Y(a0)
	swap	d0
	move.w	d0,Part_X(a0)
	jsr	Update_combat_screen	; Show
	bra	.Exit
; ---------- Move monster -------------------------
.Monster:	cmp.b	#Stand_anim,Part_anim(a0)	; Already animating ?
	beq.s	.No
	jsr	Wait_4_animation		; Yes -> Wait
.No:	moveq.l	#0,d0			; Get destination Y
	move.w	Part_target(a0),d0
	add.w	d0,d0
	move.w	Part_target(a0,d0.w),d0
	divu.w	#6,d0
	cmp.w	Part_Y(a0),d0		; Move or retreat ?
	bmi.s	.Retreat
	move.w	#228,d0			; " moves!"
	jsr	Do_part_prompt
	bra.s	.Go_on
.Retreat:	move.w	#232,d0			; " retreats!"
	jsr	Do_part_prompt
.Go_on:	Get	Part_original_handle(a0),a1
	moveq.l	#0,d5			; Get number of frames
	move.b	Anim_frame(a1),d5
;	btst	#0,Anim_motion(a1)		; Wave or circle ?
;	beq.s	.Circle
;	move.w	d5,d0			; Wave
;	subq.w	#1,d0
;	add.w	d0,d5
.Circle:	Free	Part_original_handle(a0)
	tst.w	d5			; At least one
	bne.s	.Some
	moveq.l	#1,d5
.Some:	bset	#Part_handanimated,Part_flags(a0)	; Prepare animation
	lea.l	Combat_matrix,a1		; Do moves
	lea.l	Part_target(a0),a2
	move.l	Part_COMOB_ptr(a0),a3
	move.w	(a2)+,d7			; Get number of moves
	bra	.Entry1
.Loop1:	move.w	(a2)+,d6			; Get destination
	move.w	d6,d0
	lsl.w	#2,d0
	tst.l	0(a1,d0.w)		; Empty ?
	bne	.Done
	move.l	a0,0(a1,d0.w)		; Copy to destination
	Set_anim	Stand_anim,a0
	move.w	Part_Y(a0),d0		; Clear source
	mulu.w	#6,d0
	add.w	Part_X(a0),d0
	lsl.w	#2,d0
	clr.l	0(a1,d0.w)
	moveq.l	#0,d0			; Calculate new coordinates
	move.w	d6,d0
	divu.w	#6,d0
	move.w	d0,d1
	swap	d0
	move.w	d0,Part_X(a0)		; Store
	move.w	d1,Part_Y(a0)
	jsr	Calculate_3D_coordinates	; Calculate target coordinates
	sub.w	COMOB_3D_X(a3),d0		; Calculate total vector
	sub.w	COMOB_3D_Z(a3),d1
	ext.l	d0
	ext.l	d1
	divs.w	d5,d0			; Calculate movement vector
	divs.w	d5,d1
	move.w	d0,COMOB_3D_vector_X(a3)	; Set vector
	move.w	d1,COMOB_3D_vector_Z(a3)
	move.w	d5,d6			; Show movement
	subq.w	#1,d6
.Loop2:	jsr	Do_animation_update
	jsr	Update_combat_screen
	dbra	d6,.Loop2
	clr.w	COMOB_3D_vector_X(a3)	; Clear vector
	clr.w	COMOB_3D_vector_Z(a3)
.Entry1:	dbra	d7,.Loop1			; Next move
.Done:	bclr	#Part_handanimated,Part_flags(a0)
	jsr	Wait_4_animation		; Wait
.Exit:	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
	rts

;*****************************************************************************
; [ Combat action - Parade ]
;   IN : a0 - Pointer to participant data (.l)
; No registers are restored
;*****************************************************************************
Do_parade:
	rts

;*****************************************************************************
; [ Combat action - Close-range weapon ]
;   IN : a0 - Pointer to participant data (.l)
; No registers are restored
;*****************************************************************************
Do_close_range:
; ---------- Find defender ------------------------
	lea.l	Combat_matrix,a1		; Get defender data
	move.w	Part_target(a0),d0
	lsl.w	#2,d0
	add.w	d0,a1
	move.l	(a1),d0			; Still there ?
	bne.s	.Yes
	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
	tst.b	Party_or_monster		; Monster ?
	beq	.Party0
	move.l	Part_COMOB_ptr(a0),a1	; Yes -> Move forward
	subq.w	#1,COMOB_3D_Z(a1)
	Set_anim	Closerange_anim,a0		; Animate
	jsr	Wait_4_animation
	addq.w	#1,COMOB_3D_Z(a1)		; Move back
.Party0:	move.w	#211,d0			; "Missed !"
	jsr	Do_part_prompt
	bra	.Exit2
.Yes:	move.l	d0,a1
	Get	Part_handle(a0),a2		; Get character data
	Get	Part_handle(a1),a3

; *** R E G I S T E R   C O N T E N T S ***
;  a0 - Pointer to attacker's participant data
;  a1 - Pointer to defender's participant data
;  a2 - Pointer to attacker's character data
;  a3 - Pointer to defender's character data

; ---------- Check undamageability ----------------
	move.w	Body_conditions(a3),d0	; Undamageable ?
	andi.w	#Damage_mask,d0
	beq.s	.Ok0
	jsr	Show_closerange_attack	; Yes
	move.w	#262,d0			; "Cannot damage !"
	jsr	Do_prompt
	bra	.Exit
; ---------- Check magical protection -------------
.Ok0:	move.w	Magic_bonus_armour(a3),d0	; Magical aura too strong ?
	cmp.w	Magic_bonus_weapon(a2),d0
	bls.s	.Ok1
	jsr	Show_closerange_attack	; Yes
	move.w	#212,d0			; "Magic too strong !"
	jsr	Do_part_prompt
	bra	.Exit
; ---------- Get number of attacks ----------------
.Ok1:	moveq.l	#0,d6			; Get
	move.b	Attacks_per_round(a2),d6
	bclr	#Part_hurried,Part_flags(a0)	; Hurried ?
	beq.s	.No
	add.w	d6,d6			; Yes -> Double
.No:	subq.w	#1,d6
.Loop:	sf	Abort_attack		; Clear
	jsr	Show_closerange_attack	; Show
; ---------- Probe attacker's attack skill --------
	move.w	SAttack(a2),d0		; Get attack skill
	add.w	SAttack+Magic(a2),d0
	jsr	Probe_100			; Monster -> Probe
	bpl.s	.Ok2
	move.w	#213,d0			; "Attack failed !"
	jsr	Do_part_prompt
	bra	.Done
; ---------- Probe defender's parade skill --------
.Ok2:	cmp.b	#Parade_action,Part_action(a1)	; Defending ?
	bne	.Ok3
	move.w	SParade(a3),d0		; Get parade skill
	add.w	SParade+Magic(a3),d0
	jsr	Probe_100			; Probe
	bpl.s	.Ok3
	move.w	#214,d0			; "Attack was deflected !"
	jsr	Do_part_prompt
	jsr	Break_attacker
	jsr	Break_parader
	bra	.Done
; ---------- Probe attacker's critical hit skill --
.Ok3:	btst	#End_monster_type,Monster_type_status(a3)	; Endmonster ?
	bne.s	.Ok4
	move.w	SCritical_hit(a2),d0	; Get critical hit skill
	add.w	SCritical_hit+Magic(a2),d0
	jsr	Probe_100			; Probe
	bmi.s	.Ok4
	move.w	#216,d0			; "Critical hit !"
	jsr	Do_part_prompt
	jsr	Break_attacker
	jsr	Break_defender
	move.w	Life_points+Maximum(a3),d1	; Kill (maximum!)
	bra	.Damage
; ---------- Calculate afflicted damage -----------
.Ok4:	jsr	Calculate_damage_and_protection
	jsr	Break_attacker		; Break NOW!
	jsr	Break_defender
	sub.w	d2,d1			; Calculate difference
	bgt.s	.Do
	move.w	#215,d0			; "No damage was done !"
	jsr	Do_part_prompt
	bra	.Done
; ---------- Do damage ----------------------------
.Do:	jsr	Print_hitting		; Tell 'em
.Damage:	move.w	d1,d0			; For the records
	jsr	Process_damage
	cmp.b	#1,Part_type(a1)		; Party or monster ?
	bne.s	.Monster4
	move.l	a0,-(sp)			; Do damage
	move.l	a1,a0
	jsr	Do_combat_damage
	move.l	(sp)+,a0
	bra	.Done
.Monster4:	move.l	a0,-(sp)			; Do damage
	move.l	a1,a0
	jsr	Do_damage_to_monster
	move.l	(sp)+,a0
.Done:	tst.b	Abort_attack		; Abort ?
	beq.s	.Next
	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
	bra.s	.Exit
.Next:	dbra	d6,.Loop			; Next attack
.Exit:	Free	Part_handle(a0)		; Exit
	Free	Part_handle(a1)
.Exit2:	rts

;*****************************************************************************
; [ Calculate attacker's damage & defender's protection ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;        a1 - Pointer to defender's participant data (.l)
;        a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
;  OUT : d1 - Attacker's damage (.w)
;        d2 - Defender's protection (.w)
; All registers are restored
;*****************************************************************************
Calculate_damage_and_protection:
	move.l	d0,-(sp)
; ---------- Calculate damage ---------------------
	move.w	Damage(a2),d0		; Calculate maximum damage
	add.w	Damage_magic(a2),d0
	moveq.l	#0,d1
	move.w	AStrength(a2),d1
	add.w	AStrength+Magic(a2),d1
	divu.w	#25,d1
	add.w	d0,d1
	cmp.b	#1,Part_type(a0)		; Party ?
	bne.s	.Zero1
	move.w	Spell_3_data,d0		; Add spell's effect (if any)
	beq.s	.Zero1
	addi.w	#100,d0
	mulu.w	d0,d1
	divu.w	#100,d1
.Zero1:	move.w	d1,d0
	jsr	Get_random_50_100
	move.w	d0,d1

;	jsr	Random			; Random between 50% and 100%
;	mulu.w	#50,d0
;	swap	d0
;	add.w	#50,d0
;	mulu.w	d0,d1
;	divu.w	#100,d1

; ---------- Calculate protection -----------------
	move.w	Protection(a3),d0		; Calculate maximum protection
	add.w	Protection_magic(a3),d0
	moveq.l	#0,d2
	move.w	AConstitution(a3),d2
	add.w	AConstitution+Magic(a3),d2
	divu.w	#25,d2
	add.w	d0,d2
	cmp.b	#1,Part_type(a0)		; Party ?
	bne.s	.Zero2
	move.w	Spell_2_data,d0		; Add spell's effect (if any)
	beq.s	.Zero2
	addi.w	#100,d0
	mulu.w	d0,d2
	divu.w	#100,d2
.Zero2:	move.w	d2,d0
	jsr	Get_random_50_100
	move.w	d0,d2

;	jsr	Random			; Random between 50% and 100%
;	mulu.w	#50,d0
;	swap	d0
;	add.w	#50,d0
;	mulu.w	d0,d2
;	divu.w	#100,d2

	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Try to break attacker's weapon ]
;   IN : a0 - Pointer to attacker's participant data (.l)
; All registers are restored
;*****************************************************************************
Break_attacker:
	movem.l	d0-d2,-(sp)
	move.l	#Attacker_break_mask,d1
	move.b	Part_handle(a0),d0		; Try to break sword
	moveq.l	#Right_hand,d2
	jsr	Try_to_break_combat_item
	beq.s	.Exit			; Well ?
	st	Abort_attack		; Abort
	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
.Exit:	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Try to break parader's sword & shield ]
;   IN : a1 - Pointer to defender's participant data (.l)
; All registers are restored
;*****************************************************************************
Break_parader:
	movem.l	d0-d2,-(sp)
	move.l	#Parader_break_mask,d1
	move.b	Part_handle(a1),d0		; Try to break sword
	moveq.l	#Right_hand,d2
	jsr	Try_to_break_combat_item
	moveq.l	#Left_hand,d2		; Try to break shield
	jsr	Try_to_break_combat_item
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Try to break defender's armour ]
;   IN : a1 - Pointer to defender's participant data (.l)
; All registers are restored
;*****************************************************************************
Break_defender:
	movem.l	d0-d2,-(sp)
	move.l	#Defender_break_mask,d1
	move.b	Part_handle(a1),d0		; Try to break armour
	moveq.l	#Body,d2
	jsr	Try_to_break_combat_item
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Show close-range attack ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;        a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
; All registers are restored
;*****************************************************************************
Show_closerange_attack:
	jsr	Print_attacking		; Tell 'em
	tst.b	Party_or_monster		; Party or monster ?
	bne.s	.Monster
	jsr	Show_slash		; Party -> Slash!
	bra.s	.Exit
.Monster:	move.l	a1,-(sp)			; Monster
	move.l	Part_COMOB_ptr(a0),a1	; Move forward
	subq.w	#1,COMOB_3D_Z(a1)
	Set_anim	Closerange_anim,a0		; Animate
	jsr	Wait_4_animation
	addq.w	#1,COMOB_3D_Z(a1)		; Move back
	move.l	(sp)+,a1
.Exit:	rts

;*****************************************************************************
; [ Show close-range slash ]
;   IN : a1 - Pointer to defender's participant data (.l)
; All registers are restored
;*****************************************************************************
Show_slash:
	movem.l	d0-d2/a0,-(sp)
	move.l	a1,a0			; Create slash shape
	jsr	Get_3D_part_coordinates
	jsr	Add_COMOB
	move.w	d0,COMOB_3D_X(a0)
	move.w	d1,COMOB_3D_Y(a0)
	move.w	d2,COMOB_3D_Z(a0)
	move.w	#24,COMOB_Display_width(a0)	; Set data
	move.w	#48,COMOB_Display_height(a0)
	move.w	#16,COMOB_Source_width(a0)
	move.w	#43,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Slash_FXGFX,COMOB_Gfx_base(a0)
	moveq.l	#3,d0			; Show
	moveq.l	#3-1,d1
.Loop:	jsr	Update_combat_screen
	jsr	Circle_COMOB
	dbra	d1,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Combat action - Long-range weapon ]
;   IN : a0 - Pointer to participant data (.l)
; No registers are restored
;*****************************************************************************
Do_long_range:
; ---------- Find defender ------------------------
	lea.l	Combat_matrix,a1		; Get defender data
	move.w	Part_target(a0),d0
	lsl.w	#2,d0
	add.w	d0,a1
	move.l	(a1),d0			; Still there ?
	bne.s	.Yes
	clr.b	Part_action(a0)		; No -> Reset action
	move.w	#-1,Part_target(a0)
	Get	Part_handle(a0),a2		; Remove ammunition
	jsr	Remove_ammo
	Free	Part_handle(a0)
	tst.b	Party_or_monster		; Monster ?
	beq	.Party0
	move.l	Part_COMOB_ptr(a0),a1	; Yes -> Move forward
	subq.w	#1,COMOB_3D_Z(a1)
	Set_anim	Longrange_anim,a0		; Animate
	jsr	Wait_4_animation
	addq.w	#1,COMOB_3D_Z(a1)		; Move back
.Party0:	move.w	#211,d0			; "Missed !"
	jsr	Do_part_prompt
	bra	.Exit2
.Yes:	move.l	d0,a1
	Get	Part_handle(a0),a2		; Get character data
	Get	Part_handle(a1),a3

; *** R E G I S T E R   C O N T E N T S ***
;  a0 - Pointer to attacker's participant data
;  a1 - Pointer to defender's participant data
;  a2 - Pointer to attacker's character data
;  a3 - Pointer to defender's character data

; ---------- Check undamageability ----------------
	move.w	Body_conditions(a3),d0	; Undamageable ?
	andi.w	#Damage_mask,d0
	beq.s	.Ok0
	jsr	Show_longrange_attack	; Yes
	move.w	#262,d0			; "Cannot damage !"
	jsr	Do_prompt
	bra	.Exit
; ---------- Check magical protection -------------
.Ok0:	move.w	Magic_bonus_armour(a3),d0	; Magical aura too strong ?
	cmp.w	Magic_bonus_weapon(a2),d0
	bls.s	.Ok1
	jsr	Show_longrange_attack	; Yes
	move.w	#212,d0			; "Magic too strong !"
	jsr	Do_part_prompt
	bra	.Exit
; ---------- Get number of attacks ----------------
.Ok1:	moveq.l	#0,d6			; Get
	move.b	Attacks_per_round(a2),d6
	bclr	#Part_hurried,Part_flags(a0)	; Hurried ?
	beq.s	.No
	add.w	d6,d6			; Yes -> Double
.No:	subq.w	#1,d6
.Loop:	sf	Abort_attack		; Clear
	jsr	Show_longrange_attack	; Show
; ---------- Probe attacker's attack skill --------
	move.w	SAttack(a2),d0		; Get attack skill
	add.w	SAttack+Magic(a2),d0
	jsr	Probe_100			; Monster -> Probe
	bpl.s	.Ok2
	move.w	#213,d0			; "Attack failed !"
	jsr	Do_part_prompt
	bra	.Done
; ---------- Probe defender's parade skill --------
.Ok2:	cmp.b	#Parade_action,Part_action(a1)	; Defending ?
	bne	.Ok3
	move.w	SParade(a2),d0		; Get parade skill
	add.w	SParade+Magic(a2),d0
	jsr	Probe_100			; Probe
	bpl.s	.Ok3
	move.w	#214,d0			; "Attack was deflected !"
	jsr	Do_part_prompt
	jsr	Break_attacker
	jsr	Break_parader
	bra	.Done
; ---------- Probe attacker's critical hit skill --
.Ok3:	btst	#End_monster_type,Monster_type_status(a3)	; Endmonster ?
	bne.s	.Ok4
	move.w	SCritical_hit(a2),d0	; Get critical hit skill
	add.w	SCritical_hit+Magic(a2),d0
	jsr	Probe_100			; Probe
	bmi.s	.Ok4
	move.w	#216,d0			; "Critical hit !"
	jsr	Do_part_prompt
	jsr	Break_attacker
	jsr	Break_defender
	move.w	Life_points(a3),d1		; Kill
	bra	.Damage
; ---------- Calculate afflicted damage -----------
.Ok4:	jsr	Calculate_damage_and_protection
	jsr	Break_attacker		; Break NOW!
	jsr	Break_defender
	sub.w	d2,d1			; Calculate difference
	bgt.s	.Do
	move.w	#215,d0			; "No damage was done !"
	jsr	Do_part_prompt
	bra	.Done
; ---------- Do damage ----------------------------
.Do:	jsr	Print_hitting		; Tell 'em
.Damage:	move.w	d1,d0			; For the records
	jsr	Process_damage
	cmp.b	#1,Part_type(a1)		; Party or monster ?
	bne.s	.Monster4
	move.l	a0,-(sp)			; Do damage
	move.l	a1,a0
	jsr	Do_combat_damage
	move.l	(sp)+,a0
	bra	.Done
.Monster4:	move.l	a0,-(sp)			; Do damage
	move.l	a1,a0
	jsr	Do_damage_to_monster
	move.l	(sp)+,a0
.Done:	tst.b	Abort_attack		; Abort ?
	beq.s	.Next
	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
	bra.s	.Exit
.Next:	dbra	d6,.Loop			; Next attack
.Exit:	Free	Part_handle(a0)		; Exit
	Free	Part_handle(a1)
.Exit2:	rts

;*****************************************************************************
; [ Show long-range attack ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;        a1 - Pointer to defender's participant data (.l)
;        a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
; All registers are restored
;*****************************************************************************
Show_longrange_attack:
	move.l	a4,-(sp)
	jsr	Print_attacking		; Tell 'em
	tst.b	Party_or_monster		; Monster ?
	bne.s	.Monster
	jsr	Show_moving_projectile	; No -> Fiuuuww... Thud!
	jsr	Remove_ammo		; Remove ammunition
	bra.s	.Exit
.Monster:	move.l	Part_COMOB_ptr(a0),a4	; Yes
	subq.w	#1,COMOB_3D_Z(a4)		; Move forward
	Set_anim	Longrange_anim,a0		; Animate
	jsr	Show_moving_projectile	; Fiuuuww... Thud!
	jsr	Wait_4_animation
	jsr	Remove_ammo		; Remove ammunition
	addq.w	#1,COMOB_3D_Z(a4)		; Move back
.Exit:	move.l	(sp)+,a4
	rts

;*****************************************************************************
; [ Show moving projectile ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;        a1 - Pointer to defender's participant data (.l)
;        a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
; All registers are restored
;*****************************************************************************
Show_moving_projectile:
	movem.l	d0/d1/d7/a0/a3,-(sp)
	move.l	Object_data_ptr,a3		; Get weapon's ammo ID
	move.w	Char_inventory+Right_hand_slot+Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	move.b	Ammo_use_ID(a3,d0.w),d0
	ext.w	d0
	lea.l	Projectile_table,a3		; Get projectile info
	mulu.w	#Proj_data_size,d0
	add.w	d0,a3
	jsr	Determine_COMOB_flip	; Determine flip
	smi	d1
	move.w	Proj_speed(a3),d0		; Prepare movement
	jsr	Prepare_COMOB_movement
	tst.b	d1			; Left or right ?
	beq.s	.Right
	bset	#0,COMOB_Mirror_flags(a0)	; Flip
.Right:	tst.w	COMOB_3D_vector_Z(a0)	; To or fro ?
	bpl.s	.To
	move.l	Proj_fro_gfx_base(a3),COMOB_Gfx_base(a0)
	bra.s	.Go_on
.To:	move.l	Proj_to_gfx_base(a3),COMOB_Gfx_base(a0)
.Go_on:	move.w	Proj_source_width(a3),COMOB_Source_width(a0)	; Initialize COMOB
	move.w	Proj_source_height(a3),COMOB_Source_height(a0)
	move.w	Proj_target_width(a3),COMOB_Display_width(a0)
	move.w	Proj_target_height(a3),COMOB_Display_height(a0)
	move.w	Proj_nr_frames(a3),d0
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	bra.s	.Entry
.Loop:	jsr	Update_combat_screen	; Show
	jsr	Circle_COMOB		; Animate
.Entry:	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
.Exit:	movem.l	(sp)+,d0/d1/d7/a0/a3
	rts

;*****************************************************************************
; [ Remove ammunition & reload ]
;   IN : a0 - Pointer to attacker's participant data (.b)
;        a2 - Pointer to attacker's character data (.l)
; All registers are restored
;*****************************************************************************
Remove_ammo:
	movem.l	d0/d2/d3/d7/a1/a3,-(sp)
	move.l	Object_data_ptr,a1		; Get required ammo
	move.w	Char_inventory+Right_hand_slot+Object_index(a2),d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	tst.b	Ammo_use_ID(a1,d0.w)	; Any ammo ?
	bne	.Yes
	btst	#Destroy_after_use,Item_bits_STATIC(a1,d0.w)	; Destroy ?
	beq	.Exit
	move.b	Part_handle(a0),d0		; Remove from right hand
	moveq.l	#Right_hand+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	bra.s	.Done
.Yes:	lea.l	Char_inventory+Backpack_slots(a2),a3
	moveq.l	#9+1,d2
	move.w	Char_inventory+Left_hand_slot+Object_index(a2),d7
.Loop:	cmp.w	Object_index(a3),d7		; Right ammo ?
	bne.s	.Next
	move.b	Part_handle(a0),d0		; Yes -> Remove
	moveq.l	#1,d3
	jsr	Remove_item
	bra.s	.Exit
.Next:	addq.w	#Object_packet_size,a3	; Next slot
	addq.w	#1,d2
	cmp.w	#Items_per_char+9+1,d2
	bmi.s	.Loop
	move.b	Part_handle(a0),d0		; Remove from left hand
	moveq.l	#Left_hand+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.w	#217,d0			; Tell 'em
	jsr	Do_part_prompt
.Done:	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
	st	Abort_attack		; Abort
.Exit:	movem.l	(sp)+,d0/d2/d3/d7/a1/a3
	rts

;*****************************************************************************
; [ Print "Attacks!" text ]
;   IN : a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
; All registers are restored
;*****************************************************************************
Print_attacking:
	movem.l	d0/a0/a1,-(sp)
	move.w	Char_inventory+Right_hand_slot+Object_index(a2),d0
	bne.s	.Normal			; Any weapon ?
	lea.l	Attack2_text,a1
	lea.l	Char_name(a2),a0		; Insert attacker's name
	move.l	a0,(a1)
	lea.l	Char_name(a3),a0		; Insert defender's name
	move.l	a0,8(a1)
	clr.l	16(a1)			; End text list
	bra.s	.Do
.Normal:	lea.l	Attack_text,a1
	lea.l	Char_name(a2),a0		; Insert attacker's name
	move.l	a0,(a1)
	lea.l	Char_name(a3),a0		; Insert defender's name
	move.l	a0,8(a1)
	move.l	Object_data_ptr,a0		; Insert weapon name
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.w	d0,a0
	lea.l	Item_name(a0),a0
	move.l	a0,16(a1)
	clr.l	24(a1)			; End text list
.Do:	move.l	a1,a0			; Print text
	moveq.l	#0,d0
	jsr	Display_combat_text
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
;  [ Print "Hits!" text ]
;   IN : d1 - Amount of damage (.w)
;        a2 - Pointer to attacker's character data (.l)
; All registers are restored
;*****************************************************************************
Print_hitting:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	Hit_text,a1
	lea.l	Char_name(a2),a0		; Insert attacker's name
	move.l	a0,(a1)
	lea.l	Number,a0			; Insert number
	move.l	a0,8(a1)
	move.w	d1,d0			; Convert damage
	moveq.l	#5,d7
	jsr	DecL_convert
	clr.l	16(a1)			; End text list
	move.l	a1,a0			; Print text
	moveq.l	#0,d0
	jsr	Display_combat_text
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Try to break item ]
;   IN : d0 - Character data handle (.b)
;        d1 - Item type mask (.l)
;        d2 - Slot index {0...8} (.w)
;  OUT : eq - Not broken
;        ne - Broken
; All registers are restored
;*****************************************************************************
Try_to_break_combat_item:
	movem.l	d0/d1/d3/d6/d7/a0/a1,-(sp)
	moveq.l	#0,d7			; Default is not broken
	move.b	d0,d6			; Save
	jsr	Claim_pointer		; Get character data
	move.l	d0,a0
	lea.l	Char_inventory(a0),a0	; Get packet address
	move.w	d2,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a0
	move.w	Object_index(a0),d0		; Any object ?
	beq	.Exit
	move.l	Object_data_ptr,a1		; Get object data
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	move.b	Item_type(a1),d0		; Right item type ?
	btst	d0,d1
	beq	.Exit
	btst	#Unbreakable,Item_bits_STATIC(a1)	; Unbreakable ?
	bne	.Exit
	moveq.l	#0,d0			; Try to break
	move.b	Item_break(a1),d0
	move.w	#1000,d1
	jsr	Probe
	bmi.s	.Exit
	jsr	Print_breaking_combat	; Tell 'em
	bset	#Broken_item,Item_bits_DYNAMIC(a0)	; Break !
	jsr	Put_item_in_apres_pool	; Put away
	move.b	d6,d0			; Remove
	addq.w	#1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	moveq.l	#-1,d7			; Broke it !
.Exit:	move.b	d6,d0
	jsr	Free_pointer
	tst.w	d7			; Output
	movem.l	(sp)+,d0/d1/d3/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Print "Object breaks" text ]
;   IN : d6 - Character data handle (.b)
;        a1 - Pointer to object data (.l)
; All registers are restored
;*****************************************************************************
Print_breaking_combat:
	movem.l	d0/a0-a2,-(sp)
	lea.l	Broken_text,a2
	Get	d6,a0			; Insert character name
	lea.l	Char_name(a0),a0
	move.l	a0,(a2)
	lea.l	Item_name(a1),a1		; Insert object name
	move.l	a1,8(a2)
	move.l	a2,a0			; Print text
	moveq.l	#0,d0
	jsr	Display_combat_text
	Free	d6
	movem.l	(sp)+,d0/a0-a2
	rts

;*****************************************************************************
; [ Put item in apres-pool ]
;   IN : a0 - Pointer to object packet (.l)
; All registers are restored
;*****************************************************************************
Put_item_in_apres_pool:
	movem.l	d0/a1,-(sp)
	Get	Apres_pool_handle,a1	; Copy packet
	move.w	Nr_apres_objects,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a1
	Copy_packet a0,a1
	Free	Apres_pool_handle
	addq.w	#1,Nr_apres_objects		; Count up
	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Combat action - Flee ]
;   IN : a0 - Pointer to participant data (.l)
; No registers are restored
;*****************************************************************************
Do_flee:
	move.w	#142,d0			; Tell 'em
	jsr	Do_part_prompt
	Get	Part_handle(a0),a1		; Fleeing
	move.w	Body_conditions(a1),d0
	bset	#Fleeing,d0
	move.w	d0,Body_conditions(a1)
	Free	Part_handle(a0)
	tst.b	Party_or_monster		; Party or monster ?
	bne.s	.Monster
	addq.w	#1,Fled_members		; Count
	bra.s	.Done
.Monster:	Get	Part_handle(a0),a1
	moveq.l	#0,d0			; Gain EP
	move.w	Battle_experience(a1),d0
	add.l	d0,Gained_experience
	move.w	Body_conditions(a1),d0	; Fleeing
	bset	#Fleeing,d0
	move.w	d0,Body_conditions(a1)
	Free	Part_handle(a0)
	jsr	Show_flight		; Show
.Done:	rts

;*****************************************************************************
; [ Show flight ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are restored
;*****************************************************************************
Show_flight:
	movem.l	d7/a0,-(sp)
	Set_anim	Stand_anim,a0		; Move back...
	move.l	Part_COMOB_ptr(a0),a0
	move.w	#-2,COMOB_3D_vector_Y(a0)	; ...and down
	move.w	#50,COMOB_3D_vector_Z(a0)
	moveq.l	#20-1,d7
.Loop:	jsr	Update_combat_screen
	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Select active character in tactical window ]
; No registers are restored
;*****************************************************************************
Tactical_member_left:
	jsr	Get_tactic_index		; Get index
	tst.w	d0
	bmi	.Exit
	jsr	Wait_4_unclick		; Wait
	move.w	d0,d4
	lea.l	Combat_matrix,a0		; Look in matrix
	lsl.w	#2,d0
	add.w	d0,a0
	tst.l	(a0)			; Anything there ?
	bne	.Full
; ---------- Check if movement is possible --------
	cmp.w	#18,d4			; In bottom two rows ?
	bmi	.Done
	Get	Active_handle,a1		; Moving possible ?
	move.w	Body_conditions(a1),d0
	Free	Active_handle
	andi.w	#Move_mask,d0
	beq.s	.Can_move
	move.w	#218,d0			; "Can't move"
	jsr	Do_prompt
	bra	.Done
.Can_move:	move.l	Active_participant,a0	; Get occupied targets
	jsr	Get_occupied_targets
	move.l	d0,d1
	btst	d4,d1			; Occupied ?
	beq.s	.Free
	move.w	#221,d0			; "Occupied"
	jsr	Do_prompt
	bra	.Done
.Free:	jsr	Check_movement_range	; Find possible targets
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	btst	d4,d0			; Can be reached ?
	beq.s	.Too_far
	move.w	d4,Part_target(a0)		; Yes -> Store
	move.b	#Move_action,Part_action(a0)
	move.w	#208,d0			; Feedback
	move.w	#160,d1
	moveq.l	#Combat_pos_cicon,d3
	jsr	Feedback
	bra	.Done
.Too_far:	move.w	#219,d0			; "Can't reach"
	jsr	Do_prompt
	bra	.Done
.Full:	move.l	(a0),a0			; Is party ?
	cmp.b	#1,Part_type(a0)
	beq	.Party
; ---------- Check if attack is possible ----------
	Get	Active_handle,a1		; Attacking possible ?
	move.w	Body_conditions(a1),d0
	move.w	Damage(a1),d1
	add.w	Damage_magic(a1),d1
	Free	Active_handle
	andi.w	#Attack_mask,d0
	bne.s	.Cant
	tst.w	d1
	bne.s	.Can_attack
.Cant:	move.w	#220,d0			; "Can't attack"
	jsr	Do_prompt
	bra	.Done
; ---------- Check weapon -------------------------
.Can_attack:
	Get	Active_handle,a0
	lea.l	Char_inventory+Right_hand_slot(a0),a1
	move.w	Object_index(a1),d0		; Get item in right hand
	beq	.Close			; Nothing ? -> Close range
	move.l	Object_data_ptr,a1		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	cmp.b	#Longrange_itemtype,Item_type(a1)	; Long range ?
	bne	.Close
; ---------- Check long-range weapon --------------
	lea.l	Char_inventory+Left_hand_slot(a0),a2
	move.w	Object_index(a2),d0		; Get item in left hand
	Free	Active_handle
	move.b	Ammo_use_ID(a1),d1		; Get required ammo ID
	beq	.Do			; (if any!)
	tst.w	d0			; Anything ?
	beq.s	.No_ammo
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	cmp.b	Ammo_ID(a2),d1		; Is correct ?
	beq	.Do
.No_ammo:	move.w	#204,d0			; No ammo !
	jsr	Do_prompt
	bra	.Done
.Do:	move.l	Active_participant,a0
	move.w	d4,Part_target(a0)		; Store
	move.b	#Long_range_action,Part_action(a0)
	move.w	#208,d0			; Feedback
	move.w	#177,d1
	moveq.l	#Attack_cicon,d3
	jsr	Feedback
	bra	.Done
; ---------- Determine close-range targets --------
.Close:	Free	Active_handle
	move.l	Active_participant,a0	; Get targets
	jsr	Get_closerange_targets
	btst	d4,d0			; Can be reached ?
	beq	.Too_far
	move.w	d4,Part_target(a0)		; Yes -> Store
	move.b	#Close_range_action,Part_action(a0)
	move.w	#208,d0			; Feedback
	move.w	#177,d1
	moveq.l	#Attack_cicon,d3
	jsr	Feedback
	bra	.Done
; ---------- Try to make active -------------------
.Party:	moveq.l	#0,d7			; Get member number
	move.b	Part_nr(a0),d7
	jsr	Activate_member		; Make active
.Done:	jsr	Tactic_touched		; Touch
.Exit:	rts

;*****************************************************************************
; [ Select active character & enter Inventory in tactical window ]
; No registers are restored
;*****************************************************************************
Tactical_member_right:
	jsr	Get_tactic_index		; Get index
	tst.w	d0
	bmi.s	.Exit
	lea.l	Combat_matrix,a0		; Look in matrix
	lsl.w	#2,d0
	add.w	d0,a0
	tst.l	(a0)			; Anything there ?
	beq.s	.Exit
	move.l	(a0),a0			; Is party ?
	cmp.b	#1,Part_type(a0)
	bne.s	.Done
	moveq.l	#0,d7			; Get member number
	move.b	Part_nr(a0),d7
	cmp.w	Active_member,d7		; Same ?
	beq.s	.Skip
	jsr	Activate_member		; No -> Make active
	bne.s	.Done
.Skip:	jsr	Destroy_ghosts		; Kill!
	moveq.l	#0,d0			; Enter Inventory
	move.w	d7,d0
	lsl.w	#8,d0
	jsr	Member_right
	bra.s	.Exit
.Done:	jsr	Tactic_touched		; Touch
.Exit:	rts

;*****************************************************************************
; [ Reset combat actions & targets ]
; All registers are restored
;*****************************************************************************
Reset_combat:
	movem.l	d7/a0/a1,-(sp)
	lea.l	Combat_matrix,a0
	moveq.l	#30-1,d7
.Loop:	tst.l	(a0)			; Anything there ?
	beq.s	.Next
	move.l	(a0),a1			; Clear data
	clr.b	Part_action(a1)
	move.w	#-1,Part_target(a1)
.Next:	addq.l	#4,a0			; Next entry
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0/a1
	rts

;*****************************************************************************
; [ Display combat status icons ]
; All registers are restored
;*****************************************************************************
Display_combat_status_icons:
	movem.l	d0-d2/d7/a0-a3,-(sp)
	lea.l	Combat_party,a0		; Search party
	lea.l	Party_status_icons,a1
	lea.l	Action_icons_table,a2
	moveq.l	#6-1,d7
.Loop:	moveq.l	#0,d0			; Default
	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next
	moveq.l	#0,d0			; Get action
	move.b	Part_action(a0),d0		; (if any)
	beq.s	.None
	move.b	-1(a2,d0.w),d0		; Get icon
	bra.s	.Next
.None:	Get	Part_handle(a0),a3		; Get conditions
	move.w	Body_conditions(a3),d2
	Free	Part_handle(a0)
	lea.l	.Table,a3			; Search
.Again:	move.b	(a3)+,d1			; Get condition bit
	bmi.s	.Next
	btst	d1,d2			; Got it ?
	bne.s	.Yes
	addq.l	#1,a3			; No -> Next
	bra.s	.Again
.Yes:	move.b	(a3),d0			; Yes -> Set icon
.Next:	move.b	d0,(a1)+			; Store
	lea.l	Participant_data_size(a0),a0	; Next member
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d2/d7/a0-a3
	rts

.Table:	dc.b Dead,Dead_icon
	dc.b Ashes,Dead_icon
	dc.b Dust,Dead_icon
	dc.b Fleeing,Flee_icon
	dc.b Asleep,Asleep_icon
	dc.b Petrified,Petrified_icon
	dc.b Panicked,Panicked_icon
	dc.b Mad,Mad_icon
	dc.b -1
	even

;*****************************************************************************
; [ Create clone of monster character data ]
;   IN : d1 - Original data memory handle (.b)
;  OUT : d0 - Clone data memory handle (.b)
; Changed registers : d0
; Notes :
;   - This routine duplicates the monster character data, enters the maxima
;     for skills, attributes, LP and PP and randomizes the normal values for
;     these by -5% to +5%.
;*****************************************************************************
Clone_monster_data:
	movem.l	d7/a0-a2,-(sp)
; ---------- Duplicate data -----------------------
	move.l	#Clone_data_size,d0		; Make cloned data buffer
	jsr	Allocate_memory
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Clone data
	move.l	d0,a0
	move.l	a0,a2
	Get	d1,a1
	move.w	#Clone_data_size/2-1,d7
.Loop:	move.w	(a1)+,(a0)+
	dbra	d7,.Loop
	Free	d1
	LOCAL
; ---------- Enter maxima -------------------------
	lea.l	Attributes(a2),a0		; Enter attribute maxima
	moveq.l	#Max_attrs-1,d7
.Loop:	move.w	(a0),Maximum(a0)
	addq.w	#Attr_data_size,a0
	dbra	d7,.Loop
	LOCAL
	lea.l	Skills(a2),a0		; Enter skill maxima
	moveq.l	#Max_skills-1,d7
.Loop:	move.w	(a0),Maximum(a0)
	addq.w	#Skill_data_size,a0
	dbra	d7,.Loop
	LOCAL
	move.w	Life_points(a2),Life_points+Maximum(a2)	; LP & PP
	move.w	Power_points(a2),Power_points+Maximum(a2)
; ---------- Randomize ----------------------------
	lea.l	Attributes(a2),a0		; Randomize attributes
	moveq.l	#Max_attrs-1,d7
.Loop:	jsr	Random			; Get -5% to +5%
	mulu.w	#10,d0
	swap	d0
	subq.w	#5,d0
	muls.w	(a0),d0
	divs.w	#100,d0
	add.w	(a0),d0			; Add to normal
	tst.w	d0			; Below zero ?
	bpl.s	.Below_OK
	moveq.l	#0,d0			; Yes
	bra.s	.Store
.Below_OK:	cmp.w	Maximum(a0),d0		; Above maximum ?
	bmi.s	.Store
	move.w	Maximum(a0),d0		; Yes
.Store:	move.w	d0,(a0)			; Store
	addq.w	#Attr_data_size,a0
	dbra	d7,.Loop
	LOCAL
	lea.l	Skills(a2),a0		; Randomize skills
	moveq.l	#Max_skills-1,d7
.Loop:	jsr	Random			; Get -5% to +5%
	mulu.w	#10,d0
	swap	d0
	subq.w	#5,d0
	muls.w	(a0),d0
	divs.w	#100,d0
	add.w	(a0),d0			; Add to normal
	tst.w	d0			; Below zero ?
	bpl.s	.Below_OK
	moveq.l	#0,d0			; Yes
	bra.s	.Store
.Below_OK:	cmp.w	Maximum(a0),d0		; Above maximum ?
	bmi.s	.Store
	move.w	Maximum(a0),d0		; Yes
.Store:	move.w	d0,(a0)			; Store
	addq.w	#Skill_data_size,a0
	dbra	d7,.Loop
	LOCAL
	jsr	Random			; Add -5% to +5%
	mulu.w	#10,d0
	swap	d0
	addi.w	#100-5,d0
	muls.w	Life_points(a2),d0
	divs.w	#100,d0
	tst.w	d0			; Below zero ?
	bpl.s	.Below_OK
	moveq.l	#0,d0			; Yes
	bra.s	.Store
.Below_OK:	cmp.w	Life_points+Maximum(a2),d0	; Above maximum ?
	bmi.s	.Store
	move.w	Life_points+Maximum(a2),d0	; Yes
.Store:	move.w	d0,Life_points(a2)		; Store
	LOCAL
	jsr	Random			; Add -5% to +5%
	mulu.w	#10,d0
	swap	d0
	addi.w	#100-5,d0
	muls.w	Power_points(a2),d0
	divs.w	#100,d0
	tst.w	d0			; Below zero ?
	bpl.s	.Below_OK
	moveq.l	#0,d0			; Yes
	bra.s	.Store
.Below_OK:	cmp.w	Power_points+Maximum(a2),d0	; Above maximum ?
	bmi.s	.Store
	move.w	Power_points+Maximum(a2),d0	; Yes
.Store:	move.w	d0,Power_points(a2)		; Store
	LOCAL
	move.w	(sp)+,d0			; Exit
	jsr	Free_pointer
	movem.l	(sp)+,d7/a0-a2
	rts

;*****************************************************************************
; [ Compare two combat participants (Shellsort) ]
;   IN : d5 - Source index {1...} (.w)
;        d6 - Destination index {1...} (.w)
;        a6 - Combat speed array (.l)
;  OUT : eq - Source  = Destination
;        gs - Source >= Destination
;        ls - Source <= Destination
; All registers are restored
;*****************************************************************************
Compare_participants:
	movem.l	d0/d1/d5/d6/a0-a2,-(sp)
	lsl.w	#2,d5			; Find participants
	move.l	-4(a6,d5.w),a0
	lsl.w	#2,d6
	move.l	-4(a6,d6.w),a1
	Get	Part_handle(a0),a2		; Get speeds
	move.w	ASpeed(a2),d0
	add.w	ASpeed+Magic(a2),d0
	Free	Part_handle(a0)
	Get	Part_handle(a1),a2
	move.w	ASpeed(a2),d1
	add.w	ASpeed+Magic(a2),d1
	Free	Part_handle(a1)
	cmp.w	d0,d1			; Compare
.Exit:	movem.l	(sp)+,d0/d1/d5/d6/a0-a2
	rts

;*****************************************************************************
; [ Swap two combat participants (Shellsort) ]
;   IN : d5 - Source index {1...} (.w)
;        d6 - Destination index {1...} (.w)
;        a6 - Combat speed array (.l)
; All registers are restored
;*****************************************************************************
Swap_participants:
	movem.l	d0/d5/d6/a0/a1,-(sp)
	lsl.w	#2,d5			; Find participants
	lea.l	-4(a6,d5.w),a0
	lsl.w	#2,d6
	lea.l	-4(a6,d6.w),a1
	move.l	(a0),d0			; Swap
	move.l	(a1),(a0)
	move.l	d0,(a1)
	movem.l	(sp)+,d0/d5/d6/a0/a1
	rts

;*****************************************************************************
; [ Determine movement range in combat ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : d0 - Possible movement mask (.l)
; Changed registers : d0
;*****************************************************************************
Check_movement_range:
	movem.l	d1-d7/a0-a2,-(sp)
	lea.l	Move_cells,a1		; Clear automatus
	moveq.l	#15-1,d7
.Loop:	clr.w	(a1)+
	dbra	d7,.Loop
	lea.l	-30(a1),a1
	LOCAL
	Get	Part_handle(a0),a2		; Get movement speed
	move.w	ASpeed(a2),d2
	add.w	ASpeed+Magic(a2),d2
	Free	Part_handle(a0)
	ext.l	d2			; Determine range
	divs.w	#Move_speed_factor,d2
	tst.w	d2			; Clip below
	bne.s	.Below_OK
	moveq.l	#1,d2
	bra.s	.Ok
.Below_OK:	cmp.w	#3+1,d2			; Clip above
	bmi.s	.Ok
	moveq.l	#3,d2
.Ok:	addq.w	#1,d2			; One more
	move.w	Part_X(a0),d0		; Get coordinates
	move.w	Part_Y(a0),d1
	mulu.w	#6,d1			; Initialize automatus
	add.w	d1,d0
	move.b	d2,0(a1,d0.w)
	cmp.b	#1,Party_type(a0)		; Party or monster ?
	bne.s	.Monster
	move.l	#Combat_party_mask,d6	; Get allowed mask
	bra.s	.Continue
.Monster:	move.l	#Combat_monster_mask,d6
.Continue:	LOCAL
.Again:	sf	CellA_completed		; Clear
	moveq.l	#0,d4			; Do pass
	moveq.l	#0,d5
	moveq.l	#0,d7
.Loop1:	btst	d7,d6			; Allowed ?
	beq	.Next1
	moveq.l	#0,d3			; Get current cell
	move.b	0(a1,d7.w),d3
	beq	.Next1			; Empty ?
	subq.w	#1,d3
	moveq.l	#8-1,d2			; Look around
.Loop2:	move.w	d4,d0			; Move in a direction
	move.w	d5,d1
	jsr	Move_in_8_directions
	cmp.w	#5,d0			; In range ?
	bhi.s	.Next2
	cmp.w	#4,d1
	bhi.s	.Next2
	mulu.w	#6,d1			; Get cell index
	add.w	d1,d0
	btst	d0,d6			; Allowed ?
	beq.s	.Next2
	moveq.l	#0,d1			; Get cell
	move.b	0(a1,d0.w),d1
	cmp.w	d1,d3			; Up hill ?
	bls.s	.Next2
	move.b	d3,0(a1,d0.w)		; Spread
	st	CellA_completed		; Flag !
.Next2:	dbra	d2,.Loop2			; Next direction
.Next1:	addq.w	#1,d4			; Update coordinates
	cmp.w	#6,d4
	bmi.s	.Below
	moveq.l	#0,d4
	addq.w	#1,d5
.Below:	addq.w	#1,d7			; Next cell
	cmp.w	#30,d7
	bmi.s	.Loop1
	tst.b	CellA_completed		; Any changes ?
	bne.s	.Again
	LOCAL
	lea.l	Combat_matrix,a0		; Build mask
	moveq.l	#0,d0
	moveq.l	#0,d7
.Loop:	tst.l	(a0)+			; Occupied ?
	bne.s	.Next
	tst.b	(a1)			; Cell filled ?
	beq.s	.Next
	bset	d7,d0			; Yes -> Set mask
.Next:	addq.l	#1,a1			; Next cell
	addq.w	#1,d7
	cmp.w	#30,d7
	bmi.s	.Loop
	movem.l	(sp)+,d1-d7/a0-a2
	rts

;*****************************************************************************
; [ Print a prompt referring to a combat participant ]
;   IN : d0 - Prompt number (.w)
;        a0 - Pointer to participant data (.l)
; All registers are	restored
;*****************************************************************************
Do_part_prompt:
	movem.l	d0/a0-a2,-(sp)
	move.l	a0,a2
	lea.l	Text_list,a1
	Get	Part_handle(a2),a0		; Get participant name
	lea.l	Char_name(a0),a0
	move.l	a0,(a1)
	move.l	Prompts_ptr,a0		; Find prompt
	jsr	Find_large_text
	move.l	a0,4(a1)
	clr.l	8(a1)			; End text list
	move.l	a1,a0			; Print text
	moveq.l	#0,d0	
	jsr	Display_combat_text
	Free	Part_handle(a2)
	movem.l	(sp)+,d0/a0-a2
	rts

;*****************************************************************************
; [ Display a text in combat ]
;   IN : a0 - Pointer to text list (.l)
; All registers are	restored
;*****************************************************************************
Display_combat_text:
	move.l	d1,-(sp)
	move.w	Internal_flags,d1		; Slow or fast ?
	btst	#Fast_combat_bit,d1
	bne.s	.Fast
	st	Combat_spell_display_block	; Slow
	jsr	Display_text_and_wait
	jsr	Erase_PA			; Erase
	sf	Combat_spell_display_block
	jsr	Display_combat_spells
	jsr	Update_screen
	bra.s	.Exit
.Fast:	jsr	Display_text		; Fast
	moveq.l	#Fast_combat_delay,d0
	jsr	Delay
.Exit:	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Do damage to party member in combat ]
;   IN : d0 - Amount of damage (.w)
;        a0 - Pointer to party member's participant data (.l)
; All registers are	restored
;*****************************************************************************
Do_combat_damage:
	movem.l	d0-d3/a1,-(sp)
	Get	Part_handle(a0),a1
	move.w	Body_conditions(a1),d1	; Can be damaged ?
	andi.w	#Damage_mask,d1
	bne	.Exit
	tst.w	d0			; Yes -> Any damage ?
	beq.s	.Skip
	move.w	Body_conditions(a1),d1	; Yes -> Wake up
	bclr	#Asleep,d1
	move.w	d1,Body_conditions(a1)
; ---------- Show ---------------------------------
.Skip:	move.w	d0,Part_damage(a0)		; Show in tactical window
	move.b	#Combat_damage_interval,Part_damage_timer(a0)
	move.w	d0,d3			; Save
	move.l	a0,-(sp)
	jsr	Get_3D_part_coordinates	; Create scratches
	jsr	Add_COMOB
	move.w	d0,COMOB_3D_X(a0)
	move.w	d1,COMOB_3D_Y(a0)
	move.w	#-256,COMOB_3D_Z(a0)
	moveq.l	#16,d0			; Set size
	add.w	d3,d0
	move.w	d0,COMOB_Display_width(a0)
	move.w	d0,COMOB_Display_height(a0)	; Set other data
	move.w	#32,COMOB_Source_width(a0)
	move.w	#32,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Scratches_FXGFX,COMOB_Gfx_base(a0)
	moveq.l	#4,d0			; Show
	moveq.l	#4-1,d1
.Loop:	jsr	Update_combat_screen
	jsr	Circle_COMOB
	dbra	d1,.Loop
	jsr	Delete_COMOB		; Delete
	move.l	(sp)+,a0			; Restore
	move.w	d3,d0
; ---------- Do -----------------------------------
	moveq.l	#0,d7			; Get member number
	move.b	Part_nr(a0),d7
	jsr	Do_damage			; Do
	move.w	Body_conditions(a1),d1	; Dead ?
	btst	#Dead,d1
	beq.s	.Exit
	st	Abort_attack		; Yes -> Abort !
.Exit:	Free	Part_handle(a0)
	movem.l	(sp)+,d0-d3/a1
	rts

;*****************************************************************************
; [ Do damage to monster ]
;   IN : d0 - Amount of damage (.w)
;        a0 - Pointer to monster's participant data (.l)
; All registers are	restored
;*****************************************************************************
Do_damage_to_monster:
	movem.l	d0/d1/a0-a2,-(sp)
	Get	Part_handle(a0),a1		; Can be damaged ?
	move.w	Body_conditions(a1),d1
	Free	Part_handle(a0)
	andi.w	#Damage_mask,d1
	bne	.Exit
	tst.w	d0			; Yes -> Any damage ?
	beq.s	.Skip
	move.w	Body_conditions(a1),d1	; Yes -> Wake up
	bclr	#Asleep,d1
	move.w	d1,Body_conditions(a1)
; ---------- Show ---------------------------------
.Skip:	move.w	d0,Part_damage(a0)		; Show in tactic window
	move.b	#Combat_damage_interval,Part_damage_timer(a0)
	movem.l	d0/a0,-(sp)
	Set_anim	Hit_anim,a0		; Hit animation
	move.l	a0,a1			; Create blood explosion
	move.l	Part_COMOB_ptr(a1),a2
	jsr	Add_COMOB
	move.w	COMOB_3D_X(a2),COMOB_3D_X(a0)	; Set position
	move.w	COMOB_Display_height(a2),d0
	lsr.w	#1,d0
	subi.w	#16,d0
	bpl.s	.Pos
	moveq.l	#0,d0
.Pos:	move.w	d0,COMOB_3D_Y(a0)
	move.w	COMOB_3D_Z(a2),d0
	subq.w	#1,d0
	move.w	d0,COMOB_3D_Z(a0)
	move.w	Part_damage(a1),d0		; Set size
	lsr.w	#2,d0
	cmp.w	#50,d0
	bmi.s	.Ok1
	moveq.l	#50,d0
.Ok1:	addi.w	#32,d0
	move.w	d0,COMOB_Display_width(a0)
	move.w	d0,COMOB_Display_height(a0)
	move.w	#32,COMOB_Source_width(a0)	; Set other data
	move.w	#32,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Blood_FXGFX,COMOB_Gfx_base(a0)
	moveq.l	#4,d0			; Show
	moveq.l	#4-1,d1
.Loop:	jsr	Update_combat_screen
	jsr	Update_combat_screen
	jsr	Circle_COMOB
	dbra	d1,.Loop
	jsr	Delete_COMOB		; Delete
	move.l	a1,a0			; Wait
	jsr	Wait_4_animation
	movem.l	(sp)+,d0/a0
; ---------- Do -----------------------------------
	Get	Part_handle(a0),a1		; Do the damage
	move.w	Life_points(a1),d1
	sub.w	d0,d1
	bgt.s	.Ok2			; Dead ?
	Free	Part_handle(a0)
	jsr	Show_monster_death		; Kill !
	jsr	Kill_monster
	st	Abort_attack		; Abort !
	bra.s	.Exit
.Ok2:	move.w	d1,Life_points(a1)		; Store new LP
	Free	Part_handle(a0)
.Exit:	movem.l	(sp)+,d0/d1/a0-a2
	rts

;*****************************************************************************
; [ Kill monster ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are	restored
; Notes :
;   - Death is NOT shown !
;   - Items, gold & food are put in Apres pool.
;*****************************************************************************
Kill_monster:
	movem.l	d0/d7/a0/a1,-(sp)
	Get	Part_handle(a0),a1
	move.w	Body_conditions(a1),d0	; Kill !
	bset	#Dead,d0
	move.w	d0,Body_conditions(a1)
	clr.w	Life_points(a1)
	move.w	Gold_coins(a1),d0		; For afterwards
	add.w	d0,Apres_gold
	move.w	Food_rations(a1),d0
	add.w	d0,Apres_food
	move.l	a0,-(sp)			; Put items in pool
	lea.l	Char_inventory(a1),a0
	moveq.l	#9+Items_per_char-1,d7
.Loop:	tst.w	Object_index(a0)		; Anything there ?
	beq.s	.Next
	jsr	Put_item_in_apres_pool	; Yes -> Put
.Next:	addq.w	#Object_packet_size,a0	; Next slot
	dbra	d7,.Loop
	move.l	(sp)+,a0
	moveq.l	#0,d0			; Gain EP
	move.w	Battle_experience(a1),d0
	add.l	d0,Gained_experience
	Free	Part_handle(a0)
	jsr	Update_control_status	; Remove incapable participants
	jsr	Update_combat_screen
	jsr	Update_combat_screen	; !
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Destroy monster ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are	restored
; Notes :
;   - Death is NOT shown !
;   - Items, gold & food are NOT put in Apres pool.
;*****************************************************************************
Destroy_monster:
	movem.l	d0/d7/a0/a1,-(sp)
	Get	Part_handle(a0),a1
	move.w	Body_conditions(a1),d0	; Kill !
	bset	#Dead,d0
	move.w	d0,Body_conditions(a1)
	clr.w	Life_points(a1)
	moveq.l	#0,d0			; Gain EP
	move.w	Battle_experience(a1),d0
	add.l	d0,Gained_experience
	Free	Part_handle(a0)
	jsr	Update_control_status	; Remove incapable participants
	jsr	Update_combat_screen
	jsr	Update_combat_screen	; !
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Show monster death ]
;   IN : a0 - Pointer to monster's participant data (.l)
; All registers are	restored
; Notes :
;   - This routine shows a death by damage (i.e. non-magical).
;*****************************************************************************
Show_monster_death:
	movem.l	d7/a0/a1,-(sp)
	Get	Part_original_handle(a0),a1	; Die animation ?
	move.b	Anim_frame+Die_anim-1(a1),d0
	Free	Part_original_handle(a0)
	tst.b	d0
	beq	.Skip
	Set_anim	Die_anim,a0		; Yes -> Die !
	jsr	Wait_4_animation
.Skip:	move.l	Part_COMOB_ptr(a0),a0	; Remove COMOB
	move.l	a0,a1
	jsr	Delete_COMOB
	jsr	Add_COMOB			; Create new one
	move.w	COMOB_3D_X(a1),COMOB_3D_X(a0)	; Initialize
	move.w	COMOB_3D_Y(a1),COMOB_3D_Y(a0)
	move.w	COMOB_3D_Z(a1),COMOB_3D_Z(a0)
	move.w	COMOB_Display_width(a1),d0
	move.w	d0,d1
	lsr.w	#2,d1
	add.w	d1,d0
	move.w	d0,COMOB_Display_width(a0)
	move.w	COMOB_Display_height(a1),d0
	move.w	d0,d1
	lsr.w	#2,d1
	add.w	d1,d0
	move.w	d0,COMOB_Display_height(a0)
	move.w	#48,COMOB_Source_width(a0)
	move.w	#59,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Explosion_FXGFX,COMOB_Gfx_base(a0)
	moveq.l	#14-1,d7			; Show & animate
.Loop:	jsr	Update_combat_screen
	addq.w	#1,COMOB_Frame(a0)
	bset	#COMOB_update,COMOB_Flags(a0)
	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d7/a0/a1
	rts

;*****************************************************************************
; [ Remove participant ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are	restored
;*****************************************************************************
Remove_participant:
	movem.l	d0/a1,-(sp)
	lea.l	Combat_matrix,a1		; Remove participant
	move.w	Part_Y(a0),d0
	mulu.w	#6,d0
	add.w	Part_X(a0),d0
	lsl.w	#2,d0
	clr.l	0(a1,d0.w)
	clr.b	Part_type(a0)		; Deactivate
	clr.b	Part_action(a0)		; Reset action (!)
	move.w	#-1,Part_target(a0)
	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Make bitlist of occupied movement targets (PARTY) ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : d0 - Bitlist (.l)
; Changed registers : d0
;*****************************************************************************
Get_occupied_targets:
	movem.l	d1/d6/d7/a0-a2,-(sp)
	move.b	Part_type(a0),d6		; Get participant type
	lea.l	Combat_matrix,a1		; Build occupied target mask
	moveq.l	#0,d0
	moveq.l	#30-1,d7
.Loop:	tst.l	(a1)			; Anyone there ?
	beq.s	.Next
	move.l	(a1),a2
	cmp.l	a0,a2			; Is self ?
	beq.s	.Next
	tst.b	Part_type(a2)		; Anyone there ?
	beq.s	.Next
	cmp.b	Part_type(a2),d6		; Is friend ?
	bne.s	.Next
	cmp.b	#Move_action,Part_action(a2)	; About to move ?
	bne.s	.Next
	cmp.b	#1,d6			; Party or monster ?
	bne.s	.Monster
	move.w	Part_target(a2),d1		; Get target
	bmi.s	.Next			; Any ?
	bra.s	.Do
.Monster:	move.w	Part_target(a2),d1		; Get number of targets
	bls.s	.Next			; Any ?
	add.w	d1,d1			; Yes -> Get final destination
	move.w	Part_target(a2,d1.w),d1
.Do:	bset	d1,d0			; Mask
.Next:	addq.l	#4,a1			; Next
	dbra	d7,.Loop
	movem.l	(sp)+,d1/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Make bitlist of long-range attack targets ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : d0 - Bitlist (.l)
; Changed registers : d0
;*****************************************************************************
Get_longrange_targets:
	movem.l	d6/d7/a0/a1,-(sp)
	move.b	Part_type(a0),d6		; Get participant type
	lea.l	Combat_matrix,a0		; Search matrix
	moveq.l	#0,d0
	moveq.l	#0,d7
.Loop:	tst.l	(a0)			; Anyone there ?
	beq.s	.Next
	move.l	(a0),a1			; Is enemy ?
	tst.b	Part_type(a1)
	beq.s	.Next
	cmp.b	Part_type(a1),d6
	beq.s	.Next
	bset	d7,d0			; Yes -> Mask
.Next:	addq.l	#4,a0			; Next matrix entry
	addq.w	#1,d7
	cmp.w	#30,d7
	bmi.s	.Loop
	movem.l	(sp)+,d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Make bitlist of close-range attack targets ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;  OUT : d0 - Bitlist (.l)
; Changed registers : d0
;*****************************************************************************
Get_closerange_targets:
	move.l	d1,-(sp)
	move.w	Part_X(a0),d0		; Get coordinates
	move.w	Part_Y(a0),d1
	jsr	Do_closerange_targets	; Do
	move.l	(sp)+,d1
	rts

; [ Make bitlist of close-range attack targets ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to attacker's participant data (.l)
;  OUT : d0 - Bitlist (.l)
; Changed registers : d0
Do_closerange_targets:
	movem.l	d1-d6/a0/a1,-(sp)
	move.w	d0,d3			; Copy
	move.w	d1,d4
	move.b	Part_type(a0),d6		; Get attacker type
	lea.l	Combat_matrix,a1		; Get possible attack mask
	moveq.l	#0,d5
	moveq.l	#8-1,d2
.Loop:	move.w	d3,d0			; Move in a direction
	move.w	d4,d1
	jsr	Move_in_8_directions
	cmp.w	#5,d0			; Out of range ?
	bhi.s	.Next
	cmp.w	#4,d1
	bhi.s	.Next
	mulu.w	#6,d1			; Look in matrix
	add.w	d1,d0
	move.w	d0,d1
	lsl.w	#2,d0
	move.l	0(a1,d0.w),d0		; Anything there ?
	beq.s	.Next
	move.l	d0,a0
	tst.b	Part_type(a0)
	beq.s	.Next
	cmp.b	Part_type(a0),d6		; Is enemy ?
	beq.s	.Next
	bset	d1,d5			; Yes -> Mask
.Next:	dbra	d2,.Loop			; Next direction
	move.l	d5,d0			; Output
	movem.l	(sp)+,d1-d6/a0/a1
	rts

;*****************************************************************************
; [ Update combat animations ]
; All registers are restored
;*****************************************************************************
Update_combat_animations:
	movem.l	d7/a0,-(sp)
	lea.l	Combat_monsters,a0		; Do all monsters
	move.w	Nr_monsters,d7
	bra	.Entry
.Loop:	tst.b	Part_type(a0)		; Still there ?
	beq.s	.Next
	btst	#Part_handanimated,Part_flags(a0)	; Yes -> Do ?
	bne.s	.Next
	jsr	Do_animation_update		; Yes -> Do
.Next:	lea.l	Participant_data_size(a0),a0	; Next monster
.Entry:	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Update monster animation ]
;   IN : a0 - Pointer to monster participant data (.l)
; All registers are restored
;*****************************************************************************
Do_animation_update:
	movem.l	d0-d2/a1/a2,-(sp)
	moveq.l	#0,d0			; Yes -> Get animation type
	move.b	Part_anim(a0),d0
	beq	.Exit			; If any
	move.b	Part_anim_index(a0),d1	; Get frame index
	ext.w	d1
	Get	Part_original_handle(a0),a1
	subq.w	#1,d0			; Adjust
	lea.l	Anim_frame(a1),a2		; Get number of frames
	moveq.l	#0,d2
	move.b	0(a2,d0.w),d2
	beq	.End			; If any
	btst	d0,Anim_motion(a1)		; Wave or circle ?
	beq.s	.Circle
	cmp.w	#1,d2			; One-frame wave animation ?
	beq	.Circle
	btst	#Part_wavedir,Part_flags(a0)	; Going back or forth ?
	beq.s	.Forth
	subq.w	#1,d1			; Back
	bne	.Do			; End ?
	bclr	#Part_wavedir,Part_flags(a0)	; Yes -> Forth next time
.End:	clr.b	Part_anim(a0)		; End of animation
	move.w	Part_default_frame(a0),d0	; Return to first frame
	moveq.l	#0,d1
	bra	.Frame
.Forth:	addq.w	#1,d1			; Forth
	cmp.w	d2,d1			; End ?
	bmi	.Do
	subq.w	#2,d1			; Yes -> Go back
	bset	#Part_wavedir,Part_flags(a0)
	bra	.Do
.Circle:	addq.w	#1,d1			; Forth
	cmp.w	d2,d1			; End ?
	bpl.s	.End
.Do:	lea.l	Anim_dat(a1),a2		; Get current frame
	lsl.w	#5,d0
	add.w	d0,a2
	moveq.l	#0,d0
	move.b	0(a2,d1.w),d0
.Frame:	move.l	Part_COMOB_ptr(a0),a2	; Get COMOB data
	cmp.w	COMOB_Frame(a2),d0		; New ?
	beq.s	.Same
	move.w	d0,COMOB_Frame(a2)		; Yes
	bset	#COMOB_update,COMOB_Flags(a2)
.Same:	move.b	d1,Part_anim_index(a0)	; Store new index
.Done:	Free	Part_original_handle(a0)
.Exit:	movem.l	(sp)+,d0-d2/a1/a2
	rts

;*****************************************************************************
; [ Start random animations ]
; All registers are restored
;*****************************************************************************
Start_random_animations:
	movem.l	d0/d7/a0/a1,-(sp)
	tst.b	Random_animating		; Allowed ?
	beq	.Exit
	lea.l	Combat_monsters,a0		; Yes -> Check monsters
	move.w	Nr_monsters,d7
	bra.s	.Entry1
.Loop1:	tst.b	Part_type(a0)		; Alive ?
	beq.s	.Next1
	tst.b	Part_anim(a0)		; Animating ?
	bne.s	.Exit			; Yes -> Exit
.Next1:	lea.l	Participant_data_size(a0),a0	; Next monster
.Entry1:	dbra	d7,.Loop1
	jsr	Random			; Select monster
	mulu.w	#Max_monsters,d0
	swap	d0
	lea.l	Combat_monsters,a0		; Find data
	mulu.w	#Participant_data_size,d0
	add.w	d0,a0
	tst.b	Part_type(a0)		; Alive ?
	beq.s	.Exit
	Get	Part_handle(a0),a1		; Yes -> Capable of movement ?
	move.w	Body_conditions(a1),d0
	Free	Part_handle(a0)
	andi.w	#Animate_mask,d0
	bne.s	.Exit
	Set_anim	Stand_anim,a0		; Animate!
.Exit:	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Select action for uncontrollable participant ]
;   IN : a0 - Pointer to uncontrollable participant data (.l)
; All registers are restored
;*****************************************************************************
Select_uncontrollable_action:
	movem.l	d0/a1,-(sp)
	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Part_target(a0)
	Get	Part_handle(a0),a1		; What's the matter ?
	move.w	Body_conditions(a1),d0
	btst	#Asleep,d0		; Asleep ?
	bne.s	.Exit
	btst	#Petrified,d0		; Petrified ?
	bne.s	.Exit
	btst	#Panicked,d0		; Panicked ?
	beq.s	.No_panic
	jsr	Select_panic_action		; Yes -> AAAAAHH!!!!!
	bra.s	.Exit
.No_panic	btst	#Mad,d0			; Mad ?
	beq.s	.Exit
	jsr	Select_crazy_action		; Yes -> YAARGGLLL!!!
.Exit:	Free	Part_handle(a0)
	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Select panic action ]
;   IN : a0 - Pointer to participant data (.l)
;        a1 - Pointer to character data (.l)
; All registers are restored
;*****************************************************************************
Select_panic_action:
	movem.l	d0-d5/d7/a2,-(sp)
	cmp.b	#2,Part_type(a0)		; Monster ?
	bne.s	.Party
	jsr	Select_defensive_monster_action	; Yes
	bra	.Exit
; ---------- Try to flee --------------------------
.Party:	cmp.w	#4,Part_Y(a0)		; In bottom row ?
	bne.s	.Move
	move.w	Body_conditions(a1),d0	; Can flee ?
	andi.w	#Flee_mask,d0
	bne	.Exit
	move.w	#-1,Part_target(a0)		; Yes -> Flee
	move.b	#Flee_action,Part_action(a0)
	bra	.Exit
; ---------- Get movement range -------------------
.Move:	jsr	Get_occupied_targets	; Get occupied targets
	move.l	d0,d1
	jsr	Check_movement_range	; Get movement range
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	tst.l	d0			; Any left ?
	beq	.Exit
	move.l	d0,d5			; Yes
	move.w	Part_X(a0),d0		; Get coordinates
	move.w	Part_Y(a0),d1
	move.w	d1,d2			; Get tactic index
	mulu.w	#6,d2
	add.w	d0,d2
	move.w	d2,d4			; Save
	move.w	ASpeed(a1),d7		; Get movement speed
	add.w	ASpeed+Magic(a1),d7
	ext.l	d7			; Determine range
	divs.w	#Move_speed_factor,d7
	tst.w	d7			; Clip below
	bne.s	.Below_OK
	moveq.l	#1,d7
	bra.s	.Ok
.Below_OK:	cmp.w	#3+1,d7			; Clip above
	bmi.s	.Ok
	moveq.l	#3,d7
.Ok:	bra	.Next
; ---------- Try to retreat -----------------------
.Loop:	cmp.w	#5,d1			; Downest ?
	beq	.Done
	move.w	d2,d3			; Down possible ?
	addq.w	#6,d3
	btst	d3,d5
	beq.s	.No
	addq.w	#1,d1			; Yes -> Move down
	addq.w	#6,d2
	bra.s	.Next
.No:	addq.w	#1,d1			; No -> Move down...
	addq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Defensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	bne.s	.Next
	subq.w	#1,d1			; No -> Move back up...
	subq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Defensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	beq.s	.Done
	bclr	d3,d5			; Yes -> No turning back !
.Next:	dbra	d7,.Loop			; Next step
.Done:	cmp.w	d2,d4			; Moved ?
	beq.s	.Exit
	move.b	#Move_action,Part_action(a0)	; Set action
	move.w	d2,Part_target(a0)
.Exit:	movem.l	(sp)+,d0-d5/d7/a2
	rts

;*****************************************************************************
; [ Select crazy action ]
;   IN : a0 - Pointer to participant data (.l)
;        a1 - Pointer to character data (.l)
; All registers are restored
;*****************************************************************************
Select_crazy_action:
	movem.l	d0-d4/a2,-(sp)
	jsr	Random			; Move or attack ?
	cmp.w	#40000,d0
	bmi	.Attack
	jsr	Try_crazy_move		; Move
	tst.b	Part_action(a0)		; Success ?
	bne.s	.Exit
	jsr	Try_crazy_attack		; No -> Attack
	bra.s	.Exit
.Attack:	jsr	Try_crazy_attack		; Attack
	tst.b	Part_action(a0)		; Success ?
	bne.s	.Exit
	jsr	Try_crazy_move		; No -> Move
.Exit:	movem.l	(sp)+,d0-d4/a2
	rts

; [ Try to move somewhere ]
;   IN : a0 - Pointer to participant data (.l)
;        a1 - Pointer to character data (.l)
; Changed registers : d0,d1,d2,d3,d4,a2
Try_crazy_move:
	move.w	Body_conditions(a1),d0	; Moving possible ?
	andi.w	#Move_mask,d0
	bne	.Exit
	jsr	Check_movement_range	; Find possible targets
	tst.l	d0			; Any ?
	beq	.Exit
	move.l	d0,d3			; Count targets
	moveq.l	#0,d4
	moveq.l	#30-1,d0
.Loop1:	btst	d0,d3
	beq.s	.Next1
	addq.w	#1,d4
.Next1:	dbra	d0,.Loop1
	jsr	Random			; Yes -> Select
	mulu.w	d4,d0
	swap	d0
	moveq.l	#-1,d1			; Find target
.Loop2:	addq.w	#1,d1
	btst	d1,d3
	beq.s	.Loop2
	subq.w	#1,d0
	bgt.s	.Loop2
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	bne.s	.Monster
	move.w	d1,Part_target(a0)		; Party
	bra.s	.Skip
.Monster:	move.w	#1,Part_target(a0)		; Monster
	move.w	d1,Part_target+2(a0)
.Skip:	move.b	#Move_action,Part_action(a0)
.Exit:	rts

; [ Try to attack something ]
;   IN : a0 - Pointer to participant data (.l)
;        a1 - Pointer to character data (.l)
; Changed registers : d0,d1,d2,d3,d4,a2
Try_crazy_attack:
	move.w	Body_conditions(a1),d0	; Attacking possible ?
	andi.w	#Attack_mask,d0
	bne	.Exit
	move.w	Damage(a1),d0
	add.w	Damage_magic(a1),d0
	beq	.Exit
	move.w	Char_inventory+Right_hand_slot+Object_index(a1),d0	; Get item in right hand
	beq	.Close			; Nothing ? -> Close range
	move.l	Object_data_ptr,a2		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a2
	cmp.b	#Longrange_itemtype,Item_type(a2)	; Long range ?
	beq	.Exit
.Close:	lea.l	Combat_matrix,a2		; Get possible move mask
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#8-1,d2
.Loop1:	move.w	Part_X(a0),d0		; Move in a direction
	move.w	Part_Y(a0),d1
	jsr	Move_in_8_directions
	cmp.w	#5,d0			; Out of range ?
	bhi.s	.Next1
	cmp.w	#4,d1
	bhi.s	.Next1
	mulu.w	#6,d1			; Look in matrix
	add.w	d1,d0
	move.w	d0,d1
	lsl.w	#2,d0
	tst.l	0(a2,d0.w)		; Anything there ?
	beq.s	.Next1
	bset	d1,d3			; Yes -> Mask
	addq.w	#1,d4			; Count up
.Next1:	dbra	d2,.Loop1			; Next direction
	tst.w	d4			; Any targets ?
	beq	.Exit
	jsr	Random			; Yes -> Select
	mulu.w	d4,d0
	swap	d0
	moveq.l	#-1,d1			; Find target
.Loop2:	addq.w	#1,d1
	btst	d1,d3
	beq.s	.Loop2
	subq.w	#1,d0
	bgt.s	.Loop2
	move.w	d1,Part_target(a0)		; Store
	move.b	#Close_range_action,Part_action(a0)
.Exit:	rts

;*****************************************************************************
; [ Recolour monster graphics ]
; All registers are restored
;*****************************************************************************
Recolour_monsters:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Combat_monsters,a1		; Do all monsters
	move.w	Nr_monsters,d7
	bra	.Entry1
.Loop1:	btst	#Part_recoloured,Part_flags(a1) 	; Been done ?
	bne	.Next1
	bset	#Part_recoloured,Part_flags(a1)	; No -> Mark
; ---------- Search monsters with same graphics ---
	lea.l	Recolour_list,a2		; Insert first monster
	clr.w	(a2)+
	move.l	a1,(a2)+
	moveq.l	#1,d1
	move.l	a1,a3			; Search other monsters
	move.b	Part_gfx_handle(a1),d0
	move.w	d7,d6
	bra.s	.Next2			; !!!
.Loop2:	cmp.b	Part_gfx_handle(a3),d0	; No -> Same graphics ?
	bne.s	.Next2
	clr.w	(a2)+			; Yes -> Insert
	move.l	a3,(a2)+
	bset	#Part_recoloured,Part_flags(a3)	; Mark
	addq.w	#1,d1			; Count up
.Next2:	lea.l	Participant_data_size(a3),a3	; Next monster
	dbra	d6,.Loop2
; ---------- Identify different types -------------
	sf	Keep_original		; Clear flag
	lea.l	Recolour_list,a2		; Check monsters
	moveq.l	#1,d2
	move.w	d1,d6
	bra	.Entry3
.Loop3:	tst.w	(a2)			; Already checked ?
	bne	.Next3
	move.l	2(a2),a0			; No
	jsr	Check_recolouring		; Natural colours ?
	bne.s	.Skip
	move.w	#1000,(a2)		; Yes
	tst.b	Keep_original		; First one with natural colours ?
	bne	.Next3
	st	Keep_original		; No -> Set flag
	addq.w	#1,d2
	bra	.Next3
.Skip:	move.w	d2,(a2)			; Identify
	move.l	a2,a3			; Search other monsters
	move.w	Part_work(a0),d0
	move.w	d6,d5
	bra.s	.Next4			; !!!
.Loop4:	tst.w	(a3)			; Already checked ?
	bne	.Next4
	move.l	2(a3),a4			; No
	cmp.w	Part_work(a4),d0		; Same monster ?
	beq.s	.Same
	jsr	Compare_recolouring_tables	; No -> Same recolouring tables ?
	bne.s	.Next4
.Same:	move.w	d2,(a3)			; Yes -> Identify
.Next4:	addq.l	#6,a3			; Next monster
	dbra	d5,.Loop4
	addq.w	#1,d2			; Next type
.Next3:	addq.l	#6,a2			; Next monster
.Entry3:	dbra	d6,.Loop3
	subq.w	#1,d2			; !

; ---------- REGISTER CONTENTS --------------------
; d1 - Number of monsters with these graphics (.w)
; d2 - Number of different monster types (.w)
; d7 - Global loop counter (.w)
; a1 - Pointer to current monster participant data (.l)

; ---------- Only one monster type ? --------------
	cmp.w	#1,d2			; Well ?
	bne.s	.More
	cmp.w	#1000,Recolour_list		; Yes -> Natural colours ?
	beq	.Next1
	move.l	a1,a0			; No -> Recolour it
	jsr	Recolour_the_monster
	move.b	Part_gfx_handle(a1),d0	; Invalidate memory
	jsr	Invalidate_memory
	bra	.Next1
; ---------- Sort monsters on type ----------------
.More:	movem.l	d7/a0/a1,-(sp)
	move.w	d1,d7			; Do
	lea.l	Compare_monsters,a0
	lea.l	Swap_monsters,a1
	lea.l	Recolour_list,a2
	jsr	Shellsort
	movem.l	(sp)+,d7/a0/a1
; ---------- Recolour monsters --------------------
	lea.l	Recolour_list,a2		; Do all monsters
	move.w	d1,d6
	bra	.Entry5
.Loop5:	move.w	(a2),d0			; Get type
	beq	.Next5			; Any ?
	cmp.w	#1000,d0			; Natural ?
	beq	.Next1
	move.l	2(a2),a0			; No
	cmp.w	d0,d2			; Last monster ?
	bne	.No
	tst.b	Keep_original		; Yes -> Keep original ?
	bne.s	.No
	jsr	Recolour_the_monster	; No -> Recolour it
	move.b	Part_gfx_handle(a0),d0	; Invalidate memory
	jsr	Invalidate_memory
	bra	.Next1
.No:	jsr	Recolour_a_monster		; Yes
	move.l	a2,a3			; Search other monsters
	move.b	Part_gfx_handle(a0),d1
	move.w	d6,d5
	bra.s	.Next6			; !!!
.Loop6:	cmp.w	(a3),d0			; Is same monster ?
	bne	.Next5	
	move.l	2(a3),a0			; Yes -> Same graphics
	move.b	d1,Part_gfx_handle(a0)
	clr.w	(a3)			; Eliminate
.Next6:	addq.l	#6,a3			; Next monster
	dbra	d5,.Loop6
.Next5:	addq.l	#6,a2			; Next monster
.Entry5:	dbra	d6,.Loop5
.Next1:	lea.l	Participant_data_size(a1),a1	; Next monster
.Entry1:	dbra	d7,.Loop1
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Compare two monsters (Shellsort) ]
;   IN : d5 - Source index {1...} (.w)
;        d6 - Destination index {1...} (.w)
;        a2 - Monster recolouring list (.l)
;  OUT : eq - Source  = Destination
;        gs - Source >= Destination
;        ls - Source <= Destination
; All registers are restored
Compare_monsters:
	movem.l	d0/d1/d5/d6,-(sp)
	mulu.w	#6,d5			; Get monster types
	move.w	-6(a2,d5.w),d0
	mulu.w	#6,d6
	move.w	-6(a2,d6.w),d1
	cmp.w	d1,d0			; Compare
	movem.l	(sp)+,d0/d1/d5/d6
	rts

; [ Swap two monsters (Shellsort) ]
;   IN : d5 - Source index {1...} (.w)
;        d6 - Destination index {1...} (.w)
;        a2 - Monster recolouring list (.l)
; All registers are restored
Swap_monsters:
	movem.l	d0/d5/d6/a0/a1,-(sp)
	mulu.w	#6,d5			; Find monsters
	lea.l	-6(a2,d5.w),a0
	mulu.w	#6,d6
	lea.l	-6(a2,d6.w),a1
	move.w	(a0),d0			; Swap
	move.w	(a1),(a0)
	move.w	d0,(a1)
	move.l	2(a0),d0
	move.l	2(a1),2(a0)
	move.l	d0,2(a1)
	movem.l	(sp)+,d0/d5/d6/a0/a1
	rts

; [ Compare two recolouring tables ]
;   IN : a0 - Pointer to first monster's participant data (.l)
;        a4 - Pointer to second monster's participant data (.l)
;  OUT : eq - The same
;        ne - Different
; All registers are restored
Compare_recolouring_tables:
	movem.l	d0/d7/a1/a2,-(sp)
	moveq.l	#-1,d0			; Default is different
	Get	Part_original_handle(a0),a1	; Get recolouring tables
	lea.l	Amiga_recol(a1),a1
	Get	Part_original_handle(a4),a2
	lea.l	Amiga_recol(a2),a2
	moveq.l	#Pal_size-1,d7		; Compare
.Loop:	cmpm.b	(a1)+,(a2)+
	bne.s	.Exit
	dbra	d7,.Loop
	moveq.l	#0,d0			; Equal!
.Exit:	Free	Part_original_handle(a0)
	Free	Part_original_handle(a4)
	tst.w	d0			; Well ?
	movem.l	(sp)+,d0/d7/a1/a2
	rts

; [ Check if a monster should be recoloured ]
;   IN : a0 - Pointer to monster participant data (.l)
;  OUT : ne - Recolour
;        eq - No recolour
Check_recolouring:
	movem.l	d0/d7/a1,-(sp)
	moveq.l	#-1,d7			; Default is recolour
	Get	Part_original_handle(a0),a1	; Get recolouring table
	lea.l	Amiga_recol(a1),a1
	moveq.l	#0,d0			; Natural colours ?
.Loop:	cmp.b	(a1)+,d0
	bne.s	.Exit
	addq.w	#1,d0
	cmp.w	#Pal_size,d0
	bmi.s	.Loop
	moveq.l	#0,d7			; Yes
.Exit:	Free	Part_original_handle(a0)
	tst.w	d7			; Well ?
	movem.l	(sp)+,d0/d7/a1
	rts

; [ Recolour a monster ]
;   IN : a0 - Pointer to monster participant data (.l)
; Note :
;   - This routine assumes a check has already been made to see if the
;     monster should be recoloured at all.
Recolour_a_monster:
	movem.l	d0/d1/d6/d7/a0-a2,-(sp)
	move.l	a0,a2			; No
; ---------- Duplicate graphics -------------------
	move.b	Part_gfx_handle(a2),d0	; Get graphics handle
	move.b	d0,d7			; Get graphics length
	jsr	Get_memory_length
	move.l	d0,d1
	jsr	Allocate_CHIP		; Make buffer
	move.b	d0,Part_gfx_handle(a2)
	jsr	Claim_pointer		; Get destination address
	move.l	d0,a1
	move.b	d7,d0			; Get source address
	jsr	Claim_pointer
	move.l	d0,a0
	move.l	d1,d0			; Duplicate graphics
	jsr	Copy_memory
	move.b	d7,d0
	jsr	Free_pointer
; ---------- Recolour graphics --------------------
	move.l	a1,a0
	Get	Part_original_handle(a2),a1
	move.w	Monster_width(a1),d6	; Get dimensions
	lsr.w	#4,d6
	move.w	Monster_height(a1),d7
	move.w	d6,d0			; Calculate size of one frame
	add.w	d0,d0
	mulu.w	d7,d0
	mulu.w	#Screen_depth,d0
	divu.w	d0,d1			; Calculate number of frames
	lea.l	Amiga_recol(a1),a1		; Get recolouring table
	bra.s	.Entry2
.Loop2:	jsr	Recolour_block		; Recolour a frame
	add.w	d0,a0			; Next frame
.Entry2:	dbra	d1,.Loop2
	Free	Part_gfx_handle(a2)
	Free	Part_original_handle(a2)
.Exit:	movem.l	(sp)+,d0/d1/d6/d7/a0-a2
	rts

; [ Recolour THE monster ]
;   IN : a0 - Pointer to monster participant data (.l)
; Note :
;   - This routine assumes a check has already been made to see if the
;     monster should be recoloured at all.
Recolour_the_monster:
	movem.l	d0/d1/d6/d7/a0-a2,-(sp)
	move.l	a0,a2
; ---------- Recolour graphics --------------------
	move.b	Part_gfx_handle(a2),d0	; Get graphics handle
	move.b	d0,d7			; Get graphics length
	jsr	Get_memory_length
	move.l	d0,d1
	move.b	d7,d0			; Get graphics address
	jsr	Claim_pointer
	move.l	d0,a0
	Get	Part_original_handle(a2),a1
	move.w	Monster_width(a1),d6	; Get dimensions
	lsr.w	#4,d6
	move.w	Monster_height(a1),d7
	move.w	d6,d0			; Calculate size of one frame
	add.w	d0,d0
	mulu.w	d7,d0
	mulu.w	#Screen_depth,d0
	divu.w	d0,d1			; Calculate number of frames
	lea.l	Amiga_recol(a1),a1		; Get recolouring table
	bra.s	.Entry2
.Loop2:	jsr	Recolour_block		; Recolour a frame
	add.w	d0,a0			; Next frame
.Entry2:	dbra	d1,.Loop2
	Free	Part_gfx_handle(a2)
	Free	Part_original_handle(a2)
.Exit:	movem.l	(sp)+,d0/d1/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Display combat spell icons ]
; All registers are	restored
;*****************************************************************************
Display_combat_spells:        
	tst.b	Combat_spell_display_block	; Blocked ?
	bne	.Exit
	movem.l	d0-d7/a0/a1/a3,-(sp)	; No
	lea.l	Spell_2_duration,a1		; Spells 2,3 and 4
	lea.l	Spell_icons+96,a3
	moveq.l	#16,d0
	moveq.l	#3-1,d7
.Loop:	move.w	d7,-(sp)
	move.w	(a1),d7			; Get duration
	bne	.Yes			; Any ?
	move.w	#171,d1			; No -> Erase
	move.w	d0,d2
	addi.w	#16-1,d2
	move.w	#171+24-1,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	bra.s	.Next
.Yes:	cmp.w	#Max_spell_duration,d7	; Yes -> More as maximum ?
	bmi.s	.Less
	moveq.l	#12,d7			; Full
	bra.s	.Do
.Less:	ext.l	d7			; Calculate height of bar
	mulu.w	#12,d7
	divu.w	#Max_spell_duration,d7
	tst.w	d7			; At least one
	bne.s	.Do
	moveq.l	#1,d7
.Do:	move.w	d7,-(sp)
	move.w	#171,d1			; Draw icon
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
	move.l	a3,a0
	jsr	Put_unmasked_block
	move.w	(sp)+,d7
	addq.w	#1,d0			; Draw empty bar
	move.w	d0,d2
	addi.w	#14-1,d2
	addi.w	#17,d1
	move.w	d1,d3
	addq.w	#4-1,d3
	moveq.l	#26,d4
	jsr	Draw_box
	move.w	d0,d2			; Draw real bar
	addq.w	#1,d0
	addq.w	#1,d1
	subq.w	#1,d3
	add.w	d7,d2
	moveq.l	#31,d4
	jsr	Draw_box
	subq.w	#2,d0			; Adjust
.Next:	addi.w	#16,d0			; Next spell
	addq.l	#4,a1
	lea.l	96(a3),a3
	move.w	(sp)+,d7
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d7/a0/a1/a3
.Exit:	rts

;*****************************************************************************
; [ Set layout colours in combat screen ]
; All registers are	restored
;*****************************************************************************
Set_layout_colours:
	movem.l	d0-d4/d7/a0/a1,-(sp)
	lea.l	Tactic_pal+26*2,a0		; Copy last colours
	lea.l	Combat_pal+26*2,a1
	moveq.l	#6-1,d7
.Loop:	move.w	(a0)+,(a1)+
	dbra	d7,.Loop
	move.l	#Combat_pal,Combat_pal_ptr	; Install palette %%%1
	tst.b	Night_palette		; Clear necessary ?
	beq	.Exit
	move.w	#Combat_X,d0		; Yes -> Clear
	move.w	#Combat_Y,d1
	move.w	#Combat_X+Combat_width-1,d2
	move.w	#Combat_Y+Combat_height-1,d3
	moveq.l	#0,d4
	jsr	Draw_box
	st	COMOBs_blocked		; Block automatic refresh
	jsr	Update_screen
.Exit:	jsr	Reset_current_RL		; Update
	movem.l	(sp)+,d0-d4/d7/a0/a1
	rts

;*****************************************************************************
; [ Restore combat colours in combat screen ]
; All registers are	restored
;*****************************************************************************
Restore_combat_colours:
	movem.l	d7/a0/a1,-(sp)
	lea.l	Combat_backup_pal+26*2,a0	; Copy last colours
	lea.l	Combat_pal+26*2,a1
	moveq.l	#6-1,d7
.Loop:	move.w	(a0)+,(a1)+
	dbra	d7,.Loop
	tst.b	Night_palette		; Redraw needed ?
	beq	.Exit
	st	Update_command		; Yes -> Show all
	jsr	Update_combat_screen
	sf	COMOBs_blocked		; Restart automatic refresh
.Exit:	jsr	Reset_current_RL		; Update
	movem.l	(sp)+,d7/a0/a1
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Time_table:
	dc.b 2,2,2,2,2,1			;  0 - 5
	dc.b 1,0,0,0,0,0			;  6 - 11
	dc.b 0,0,0,0,0,0			; 12 - 17
	dc.b 0,1,1,2,2,2			; 18 - 23
	even

Combat_CA:	dc.w Combat_X,Combat_X+Combat_width-1
	dc.w Combat_Y,Combat_Y+Combat_height-1
Combat_action_table:
	dc.l Do_move			; Move
	dc.w Move_mask
	dc.l Do_parade			; Parade
	dc.w Parade_mask
	dc.l Do_close_range		; Close-range
	dc.w Attack_mask
	dc.l Do_long_range			; Long-range
	dc.w Attack_mask
	dc.l Do_flee			; Flee
	dc.w Flee_mask
	dc.l Do_cast_spell			; Cast spell
	dc.w Magic_mask
	dc.l Do_use_magic_object		; Use magic object
	dc.w Use_item_mask

Combat_CIL:
	dc.w Flee_cicon,Disk_cicon,OK_cicon
	dc.w Combat_pos_cicon,Forward_3D_cicon,0
	dc.w Attack_cicon,Parade_cicon,Use_magic_cicon
	dc.l Flee_combat,Options_menu,OK_combat
	dc.l Move_combat,Advance,0
	dc.l Attack,Parade,Magic_combat
	dc.l Combat_CIL_evaluate

; *** COMBAT SCREEN : 2nd layer ***
Combat_L2:
	dc.w Tactic_X,Tactic_X+96-1,Tactic_Y,Tactic_Y+(5*Tactic_cell_height)-1	; Tactic window
	dc.b 2
	even
	dc.l Control_area,0

Projectile_table:
	dc.l Special_to_FXGFX,Special_to_FXGFX		; 0 - SPECIAL
	dc.w 16,13,32,26,4,30
	dc.l Stone_FXGFX,Stone_FXGFX			; 1 - Stone
	dc.w 16,16,16,16,1,30
	dc.l Arrow_to_FXGFX,Arrow_fro_FXGFX		; 2 - Normal arrow
	dc.w 16,20,24,13,1,30
	dc.l Crossbow_to_FXGFX,Crossbow_fro_FXGFX	; 3 - Crossbow arrow
	dc.w 16,19,24,13,1,30
	dc.l Dagger_to_FXGFX,Dagger_to_FXGFX		; 4 - Dagger
	dc.w 16,15,24,13,1,30

Monster_positions:
	dc.b 0,0,1,0,2,0,3,0,4,0,5,0
	dc.b 0,1,1,1,2,1,3,1,4,1,5,1
	dc.b 0,2,1,2,2,2,3,2,4,2,5,2
Party_positions:
	dc.b 0,3,1,3,2,3,3,3,4,3,5,3
	dc.b 0,4,1,4,2,4,3,4,4,4,5,4
Action_icons_table:
	dc.b Move_icon,Parade_icon,Closerange_icon,Longrange_icon
	dc.b Flee_icon,Magic_icon,Objectmagic_icon
Very_small_numbers:
	dc.b $60,$d0,$d0,$d0,$60		; 0
	dc.b $30,$70,$30,$30,$30		; 1
	dc.b $e0,$30,$60,$c0,$f0		; 2
	dc.b $e0,$30,$60,$30,$e0		; 3
	dc.b $20,$60,$d0,$f0,$30		; 4
	dc.b $f0,$c0,$e0,$30,$e0		; 5
	dc.b $60,$c0,$e0,$d0,$60		; 6
	dc.b $f0,$30,$60,$c0,$c0		; 7
	dc.b $60,$d0,$60,$d0,$60		; 8
	dc.b $60,$b0,$70,$30,$60		; 9

	SECTION	Chip_BSS,bss_c
Very_small_buffer:	ds.w 5

	SECTION	Fast_BSS,bss
Combat_data:
Combat_zoom_screen_handle:	ds.b 1		; Combat flags
Party_or_monster:	ds.b 1
Tactic_bg_handle:	ds.b 1
Abort_attack:	ds.b 1
Apres_pool_handle:	ds.b 1
Show_monsters:	ds.b 1
Combat_result:	ds.b 1
CellA_completed:	ds.b 1
Combat_icons:	ds.b 6
Move_cells:	ds.b 5*6
Random_animating:	ds.b 1
Fighting:	ds.b 1
Keep_original:	ds.b 1
Night_palette:	ds.b 1
Combat_spell_display_block:	ds.b 1
	even
Combat_palette_nr:	ds.w 1
Combat_backup_pal:	ds.w Pal_size
Gained_experience:	ds.l 1
Nr_apres_objects:	ds.w 1
Nr_battle_rounds:	ds.w 1
Global_danger:	ds.w 1
Tactic_draw_vector:	ds.l 1
Nr_monsters:	ds.w 1
Remaining_monsters:	ds.w 1			; Under control
Remaining_members:	ds.w 1			; Under control
Fled_members:	ds.w 1
Nr_participants:	ds.w 1
Apres_gold:	ds.w 1
Apres_food:	ds.w 1
Selected_tactic:	ds.w 1
Tactic_mask:	ds.l 1
Target_mask:	ds.l 1

Recolour_list:	ds.w Max_monsters*3

Combat_party:	ds.w 6*Participant_data_size/2
Combat_monsters:	ds.w Max_monsters*Participant_data_size/2
Combat_matrix:	ds.l 5*6
Combat_speed_list:	ds.l 6+Max_monsters

MonKnow_ptr:	ds.l 1

FXGFX_workspace:
	ds.l 32
Combat_data_size	EQU *-Combat_data
