; Main game
; Written by J.Horneman (In Tune With The Universe)
; Start : 16-9-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Initialize program ]
; No registers are restored
; NOTE :
;  - Do not call this routine directly, but call [ Restart_game ] instead.
;*****************************************************************************
Init_program:
; ---------- Clear game data ----------------------
	lea.l	Game_data,a0
	moveq.l	#0,d0
	move.l	#(Game_data_size-2)/2-1,d7
					; NOTE: In 1.21 the size was not adapted when
					;  Charge_price was added, so the last word of the
					;  game data (Casting_participant+2) is not cleared.
					;  This is harmless. Use Game_data_size/2-1 to fix it.
.Loop:	move.w	d0,(a0)+
	subq.l	#1,d7
	bne.s	.Loop
	LOCAL
; ---------- Select saved game --------------------
	tst.b	First_time		; First time ?
	bne	.Do
	st	First_time		; Yes

	ifne	Fingerprint
	tst.b	First_fingerprint		; Fingerprinted ?
	beq	.No_print
	jsr	Init_diagnostic_screen	; Yes
	lea.l	Fingerprint_start_text,a1	; Print start text
	jsr	DI_Print
	jsr	DI_CR
	jsr	DI_CR
	lea.l	First_fingerprint,a0	; Decrypt fingerprint
	lea.l	Batch,a1
	moveq.l	#-1,d1
	moveq.l	#Fingerprint_size-1,d7
.Loop:	move.b	(a0)+,d0
	eor.b	d1,d0
	move.b	d0,(a1)+
	dbra	d7,.Loop
	clr.b	(a1)			; Extra EOL
	lea.l	Batch,a1			; Print fingerprint
	jsr	DI_Print
	jsr	DI_CR
	jsr	DI_CR
	lea.l	Fingerprint_end_text,a1	; Print end text
	jsr	DI_Print_text
	jsr	Exit_diagnostic_screen	; Wait & exit
.No_print:
	endc

	clr.w	Initial_save		; Journey onward ?
	tst.w	Intro_menu_choice
	bne.s	.New
	moveq.l	#Saves_file,d0		; No -> Load saves file
	jsr	Load_file
	move.b	d0,d7
	jsr	Claim_pointer		; Get last save number
	move.l	d0,a0
	move.w	(a0),d1
	move.w	d1,Initial_save
	move.b	d7,d0			; Remove saves file
	jsr	Free_pointer
	jsr	Kill_memory
	tst.w	d1			; ANY initial save ?
	bne.s	.Do
.New:	Push	Module,Chared_Mod		; No -> Create char
.Do:	move.w	Initial_save,d0		; Memory safety on ?
	bmi.s	.Skip
	jsr	Get_saved_game		; Copy to work files
.Skip:	LOCAL
; ---------- Initialize ---------------------------
	move.w	#1,Blink_count		; Reset blinking
	Push	Tree,Main_tree		; Initialize object	tree
	opt	o4-				; (not optimized by the original assembler)
	move.l	#Items_per_char*Object_packet_size,d0	; Make sale slots
	opt	o4+
	jsr	Allocate_memory
	move.b	d0,Sold_slots_handle
	lea.l	Level_factors,a0		; Initialize level factors
	moveq.l	#1,d0			; L = 1
	moveq.l	#0,d1			; Fold = 0
	moveq.l	#Max_level-1,d7
.Loop:	move.w	d0,d2			; Fx = Fold + L
	add.w	d1,d2
	move.w	d2,(a0)+
	addq.w	#1,d0			; L = L + 1
	move.w	d2,d1			; Fold = Fx
	dbra	d7,.Loop
	LOCAL
; ---------- Load & copy party data ---------------
	moveq.l	#Party_data_file,d0		; Load party data
	jsr	Load_file
	move.b	d0,-(sp)
	jsr	Claim_pointer		; Get actual address
	move.l	d0,a0
	lea.l	Party_data,a1		; Copy party data
	move.w	#Party_data_size/2-1,d7
.Loop:	move.w	(a0)+,(a1)+
	dbra	d7,.Loop
	jsr	Init_modifications		; Copy modification	list
	move.b	(sp)+,d0			; Remove file
	jsr	Free_pointer
	jsr	Kill_memory
	jsr	Init_time			; Initialize time
	move.w	Internal_flags,d0		; Initialize music flag
	btst	#Music_flag_bit,d0
	seq	Music_flag
	btst	#Outline_text_bit,d0
	sne	Outline_text
	LOCAL
; ---------- Load party characters' data ----------
	lea.l	Batch,a0			; Build batch
	lea.l	Member_nrs,a1
	moveq.l	#0,d0
	moveq.l	#6-1,d7
.Loop:	move.w	(a1)+,d1
	beq.s	.Next
	move.w	d1,(a0)+
	addq.w	#1,d0
.Next:	dbra	d7,.Loop
	move.w	d0,Nr_members		; Correction
	lea.l	Batch,a0			; Load batch
	lea.l	Party_handles,a1
	moveq.l	#Party_char_file,d1
	jsr	Load_batch_of_subfiles
	LOCAL
; ---------- Load party member portraits ----------
	lea.l	Batch,a2
	moveq.l	#6-1,d7
.Loop:	moveq.l	#0,d0			; Default
	move.b	(a1)+,d1			; Anyone there ?
	beq.s	.Next
	Get	d1,a0			; Get portrait number
	move.b	Portrait_nr(a0),d0
	Free	d1
.Next:	move.w	d0,(a2)+			; Store
	dbra	d7,.Loop			; Next party member
	lea.l	Batch,a0
	lea.l	Portrait_handles,a1
	moveq.l	#6,d0
	moveq.l	#Portraits_file,d1
	jsr	Load_batch_of_subfiles
	LOCAL
; ---------- Start --------------------------------
	move.w	Active_member,d7		; Activate member
	jsr	Activate_member
	jsr	Display_status_block	; Build screen
	jsr	Update_status_block
	jsr	Fade_in_all		; Fade in again
	jsr	Init_map			; Initialize map
Dumdum:	rts

;*****************************************************************************
; [ Initialize modifications ]
;   IN : a0 - Pointer to end of party data FILE (.l)
;        a1 - Pointer to end of party data (.l)
; All registers are	restored
;*****************************************************************************
Init_modifications:
	movem.l	d0/a0/a1,-(sp)
	moveq.l	#0,d0
.Again:	tst.w	(a0)			; End of list ?
	beq.s	.Exit
	rept	Modif_data_size/2
	move.w	(a0)+,(a1)+		; Copy info
	endr
	addq.w	#1,d0			; Count
	cmp.w	#Max_mods,d0		; Maximum reached ?
	bmi.s	.Again
.Exit:	clr.w	(a1)			; Enter sentinel
	move.w	d0,Nr_of_modifications	; Store
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Make modifications to current map ]
;   IN : d7 - Map number (.w)
; All registers are	restored
;*****************************************************************************
Make_modifications: 
	movem.l	d0-d2/a0,-(sp)
	lea.l	Modifications,a0
	moveq.l	#0,d0
	moveq.l	#0,d1
.Again:	tst.w	(a0)			; End of list ?
	beq	.Exit
	cmp.w	Modif_map_nr(a0),d7		; This map ?
	bne	.Next
	move.b	Modif_X(a0),d0		; Load info
	move.b	Modif_Y(a0),d1
	move.w	Modif_icon(a0),d2
	jsr	Do_change_icon		; Make modification
.Next:	addq.l	#Modif_data_size,a0		; Next modification
	bra.s	.Again
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Enter modification in list ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number (.w)
;        d7 - Map number (.w)
; All registers are	restored
;*****************************************************************************
Enter_modification: 
	movem.l	d6/a0,-(sp)
	lea.l	Modifications,a0		; Already present ?
.Again:	tst.w	(a0)			; End of list ?
	beq	.End
	cmp.w	Modif_map_nr(a0),d7		; Same map ?
	bne.s	.Next
	cmp.b	Modif_X(a0),d0		; Same coordinates ?
	bne.s	.Next
	cmp.b	Modif_Y(a0),d1
	bne.s	.Next
	cmp.w	Modif_icon(a0),d2		; Same icon ?
	beq	.Exit			; Yes -> Exit
	move.w	d2,Modif_icon(a0)		; No -> Change icon !
	bra.s	.Exit
.Next:	addq.l	#Modif_data_size,a0		; Next modification
	bra.s	.Again
.End:	move.w	Nr_of_modifications,d6	; Increase number
	addq.w	#1,d6
	cmpi.w	#Max_mods+1,d6
	bpl.s	.Exit
	move.w	d6,Nr_of_modifications
	move.w	d7,Modif_map_nr(a0)		; Store info
	move.b	d0,Modif_X(a0)
	move.b	d1,Modif_Y(a0)
	move.w	d2,Modif_icon(a0)
	clr.w	Modif_data_size(a0)		; Insert sentinel
.Exit:	movem.l	(sp)+,d6/a0
	rts

;*****************************************************************************
; [ Change an icon ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;        d2 - Icon number (.w)
;        d7 - Map number (.w)
; All registers are restored
;*****************************************************************************
Do_change_icon:
	movem.l	d0/d1/d3/d6/a0/a1,-(sp)
	cmp.b	#World_2D,Current_map_type	; World map ?
	bne.s	.No
	lea.l	Quad_map,a0		; Yes, try all maps
	moveq.l	#4-1,d6
.Loop:	cmp.w	Quad_mapnr(a0),d7		; Is it this one ?
	bne.s	.Next
	move.b	Quad_map_handle(a0),d6	; Yes -> do
	bra.s	.Do
.Next:	addq.w	#Quad_mapsize,a0		; Next map
	dbra	d6,.Loop
	bra	.Exit
.No:	cmp.w	Map_nr,d7			; Is it the current map ?
	bne	.Exit
	move.b	Mapdata_handle,d6
.Do:	tst.w	d0			; Inside map ?
	ble	.Exit
	cmp.w	Width_of_map,d0
	bgt	.Exit
	tst.w	d1
	ble	.Exit
	cmp.w	Height_of_map,d1
	bgt	.Exit
	subq.w	#1,d1			; Calculate map offset
	mulu.w	Width_of_map,d1
	subq.w	#1,d0
	add.w	d0,d1
	add.w	d1,d1
	cmpi.b	#Map_3D,Current_map_type	; 3D map ?
	bpl.s	.Under
	add.w	d1,d1			; No -> 4 bytes/square
	tst.w	d2			; Delete ?
	beq.s	.Delete
	Get	Icondata_handle,a1		; No -> Get icon status bits
	move.w	d2,d3
	lsl.w	#3,d3
	move.l	-8+2(a1,d3.w),d3
	Free	Icondata_handle
	btst	#Underlay_bit,d3		; Under- or overlay ?
	beq.s	.Under
.Delete:	Get	d6,a0			; Change overlay icon
	lea.l	Map_data(a0),a0
	move.w	d2,2(a0,d1.w)
	Free	d6
	bra.s	.Exit
.Under:	Get	d6,a0			; Change underlay icon
	lea.l	Map_data(a0),a0
	move.b	d2,0(a0,d1.w)
	Free	d6
.Exit:	movem.l	(sp)+,d0/d1/d3/d6/a0/a1
	rts

;*****************************************************************************
; [ Set new travel mode ]
;   IN : d0 - New travel mode	(.w)
; All registers are	restored
;*****************************************************************************
Set_new_travel_mode:
	movem.l	d0/a0,-(sp)
	cmp.w	#Max_travelmodes,d0		; Legal ?
	bpl.s	.Exit
	move.w	d0,Travel_mode		; Yes -> Store
	cmp.b	#Map_3D,Current_map_type	; 2D map ?
	bpl.s	.Exit
	jsr	Set_map_music		; Yes -> Switch music
	clr.w	Time_warp			; Clear
	tst.b	Show_trans		; Show travel-modes ?
	beq.s	.Exit
	lea.l	Travel_speed,a0		; Set new	movement speed
	move.b	0(a0,d0.w),d0
	move.w	d0,Time_warp
	clr.w	Move_count		; Reset counter
	jsr	Init_travelmode		; Yes -> Load new graphics
.Exit:	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Left mouse-button clicked	on party member ] MOUSE EVENT
; All registers are restored
;*****************************************************************************
Member_left:        
	movem.l	d0/d7,-(sp)
	andi.l	#$0000ff00,d0		; Get member number
	beq.s	.Exit
	lsr.w	#8,d0
	move.w	d0,d7
	cmp.w	Active_member,d7		; Same ?
	beq.s	.Exit
	jsr	Activate_member		; Make active
.Exit:	movem.l	(sp)+,d0/d7
	rts

;*****************************************************************************
; [ Make member active ]
;   IN : d7 - Member number [1...6] (.w)
;  OUT : eq - Possible
;        ne - Impossible
; All registers are restored
;*****************************************************************************
Activate_member:
	movem.l	d0/d1/d5-d7/a0/a1,-(sp)
	moveq.l	#-1,d6			; Default is impossible
	lea.l	Party_handles-1,a0		; Get data handle
	move.b	0(a0,d7.w),d5
	beq	.Exit2			; Anyone there ?
	Get	d5,a1
	moveq.l	#Dialogue_ID,d0		; Yes -> In dialogue ?
	jsr	Find_module
	beq.s	.No1
	tst.b	NPC_or_member		; With party member ?
	bne.s	.Yes
	tst.b	Joined			; Joined ?
	beq.s	.Skip
.Yes:	cmp.w	Dialogue_NPC_index,d7	; With this member ?
	beq.s	.Exit
	bra.s	.No1
.Skip:	Get	Dialogue_handle,a0		; Get NPC's languages
	move.b	Learned_languages(a0),d0
	Free	Dialogue_handle
	and.b	Learned_languages(a1),d0	; Compare with new active's
	tst.b	d0			; Que ?
	bne.s	.No1
	move.w	#106,d0			; No comprendo, signor !
	jsr	Do_prompt_window
	bra	.Exit
.No1:	move.w	Body_conditions(a1),d0	; Get conditions
	move.w	d0,d1
	andi.w	#Active_mask,d1		; Possible active ?
	bne	.Exit
	move.b	d5,Active_handle		; Store
	move.w	d7,Active_member
	jsr	Check_active_member		; Update status
	tst.b	Battling			; In combat ?
	beq.s	.No2
	lea.l	Combat_party,a0		; Set active participant
	subq.w	#1,d7
	mulu.w	#Participant_data_size,d7
	add.l	d7,a0
	move.l	a0,Active_participant
.No2:	moveq.l	#0,d6			; Success !
.Exit:	Free	d5
.Exit2:	tst.w	d6			; Any luck ?
	movem.l	(sp)+,d0/d1/d5-d7/a0/a1
	rts

;*****************************************************************************
; [ Active member selected by keys 1...6 ] KEY EVENT
;*****************************************************************************
Select_1:	move.w	#1*256,d0
	jmp	Member_left
Select_2:	move.w	#2*256,d0
	jmp	Member_left
Select_3:	move.w	#3*256,d0
	jmp	Member_left
Select_4:	move.w	#4*256,d0
	jmp	Member_left
Select_5:	move.w	#5*256,d0
	jmp	Member_left
Select_6:	move.w	#6*256,d0
	jmp	Member_left

;*****************************************************************************
; [ Right mouse-button clicked on party member ] MOUSE EVENT
; All registers are	restored
;*****************************************************************************
Member_right:       
	movem.l	d0-d4/d7/a0,-(sp)
	andi.l	#$0000ff00,d0		; Get member number
	beq.s	.Exit
	lsr.w	#8,d0
	move.w	d0,d1			; Save for later
	lea.l	Party_handles,a0
	move.b	-1(a0,d0.w),d0
	beq	.Exit			; Anyone there ?
	move.b	d0,d2			; Save for later
	jsr	Claim_pointer		; Get conditions & flag
	move.l	d0,a0
	move.w	Body_conditions(a0),d3
	move.b	Secret_inventory(a0),d4
	move.b	d2,d0
	jsr	Free_pointer
	tst.b	d4			; Secret inventory ?
	beq.s	.No
	move.b	d2,Subject_handle		; Yes !
	move.w	#286,d0			; "Begone!"
	jsr	Do_prompt_window
	bra.s	.Exit
.No:	move.b	d2,Inventory_handle		; Store
	move.w	d1,Inventory_member
	jsr	Exit_display		; Fade out
	andi.w	#Inv2_mask,d3		; Inventory 2 possible ?
	beq.s	.Inv2
	Push	Module,Inv1_Mod		; Go to Inventory 1
	bra.s	.Exit
.Inv2:	Push	Module,Inv2_Mod		; Go to Inventory 2
.Exit:	movem.l	(sp)+,d0-d4/d7/a0
	rts

;*****************************************************************************
; [ Inventory 2 selected by keys 1...6 ] KEY EVENT
;*****************************************************************************
GoInv_1:	move.w	#1*256,d0
	jmp	Member_right
GoInv_2:	move.w	#2*256,d0
	jmp	Member_right
GoInv_3:	move.w	#3*256,d0
	jmp	Member_right
GoInv_4:	move.w	#4*256,d0
	jmp	Member_right
GoInv_5:	move.w	#5*256,d0
	jmp	Member_right
GoInv_6:	move.w	#6*256,d0
	jmp	Member_right

;*****************************************************************************
; Control icon key event routines
;*****************************************************************************
Icon_1:	moveq.l	#1,d0
	jmp	Do_control_icons
Icon_2:	moveq.l	#2,d0
	jmp	Do_control_icons
Icon_3:	moveq.l	#3,d0
	jmp	Do_control_icons
Icon_4:	moveq.l	#4,d0
	jmp	Do_control_icons
Icon_5:	moveq.l	#5,d0
	jmp	Do_control_icons
Icon_6:	moveq.l	#6,d0
	jmp	Do_control_icons
Icon_7:	moveq.l	#7,d0
	jmp	Do_control_icons
Icon_8:	moveq.l	#8,d0
	jmp	Do_control_icons
Icon_9:	moveq.l	#9,d0
	jmp	Do_control_icons

;*****************************************************************************
; [ Update status display of all party members ]
; All registers are	restored
;*****************************************************************************
Update_active_status:
	movem.l	d7/a0,-(sp)
	lea.l	Party_handles,a0		; Check party
	moveq.l	#1,d7
.Loop:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next
	jsr	Force_status_update		; Yes
.Next:	addq.l	#1,a0			; Next member
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Check active character ]
; All registers are	restored
;*****************************************************************************
Check_active_member:
	movem.l	d0/a0,-(sp)
	Get	Active_handle,a0
	move.w	Body_conditions(a0),d0
	btst	#Stoned,d0		; Stoned ?
	bne.s	.Drugged
	tst.b	Drugged_FX		; No -> Was before ?
	beq.s	.Ok
	sf	Drugged_FX		; Yes -> Reset
	jsr	Reset_current_RL
	bra.s	.Ok
.Drugged:	st	Drugged_FX		; Yes -> Whee!
.Ok:	Free	Active_handle
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Select new active character ]
; All registers are	restored
;*****************************************************************************
Select_new_active_member:
	movem.l	d0/d7/a0/a1,-(sp)
	clr.w	Active_member		; No active member
	lea.l	Party_handles,a0		; Game over ?
	moveq.l	#6-1,d7
.Loop:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next
	Get	(a0),a1			; Could be active ?
	move.w	Body_conditions(a1),d0
	Free	(a0)
	andi.w	#Active_mask,d0
	beq	.Select
.Next:	addq.l	#1,a0			; Next member
	dbra	d7,.Loop
	jmp	Game_over			; Game over!
.Select:	move.w	#222,MemberSel_prompt	; Who is the new leader ?
	move.l	#Active_check,MemberSel_ptr
	Push	Module,ActiveSel_Mod
	move.w	Selected_member,d7		; Set new
	jsr	Activate_member
.Exit:	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Game Over ]
; All registers are restored
;*****************************************************************************
Game_over:
	jsr	Exit_display
	lea.l	GameOver_Mod,a0
	jmp	Push_Module

GameOver_ModInit:
	moveq.l	#Game_over_music,d0		; Start music
	moveq.l	#0,d1
	jsr	Set_music
	moveq.l	#ShowPicTxt_layout,d0	; Show new layout
	jsr	Show_layout
; ---------- Load & display picture ---------------
	move.w	#Game_Over_picture,d0	; Load picture
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
	moveq.l	#Game_Over_palette,d0	; Load palette
	moveq.l	#Palette_file,d1
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
	move.b	Active_handle,Subject_handle	; Print sad message
	move.w	#290,d0
	jsr	Do_prompt
	jsr	Erase_PA			; Erase
	jsr	Update_screen
	move.w	#291,d0			; Print request
	jsr	Print_prompt
	move.w	#128-1,d0			; Draw box around icons
	move.w	#169-1,d1
	move.w	#64,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display LOAD icon
	addq.w	#1,d1
	move.b	#Load_cicon,d3
	jsr	Display_up_button
	addi.w	#32,d0			; Display QUIT icon
	move.b	#Quit_cicon,d3
	jsr	Display_up_button
	jsr	Update_screen
	Push	Tree,LQReq_L1		; Do
	rts

GameOver_ModExit:
	Pop	Tree
	jmp	Fade_out_bottom

LQ_Load:	move.w	#128,d0			; Feedback
	move.w	#169,d1
	move.b	#Load_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	jsr	Load_game			; Load
.Exit:	rts

LQ_Quit:	move.w	#128+32,d0		; Feedback
	move.w	#169,d1
	move.b	#Quit_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	jsr	Quit_game			; Quit
.Exit:	rts

;*****************************************************************************
; [ Check if selected member can be activated ]
;   IN : d0 - Selected member number (.w)
; No registers are restored
;*****************************************************************************
Active_check:
	lea.l	Party_handles,a0		; Get member data
	move.b	-1(a0,d0.w),d7
	beq.s	.Exit
	Get	d7,a0
	move.w	Body_conditions(a0),d6
	Free	d7
	andi.w	#Active_mask,d6		; Can be active ?
	bne.s	.Exit
	move.w	d0,Selected_member		; Yes
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ Check if selected member is alive ]
;   IN : d0 - Selected member number (.w)
; No registers are restored
;*****************************************************************************
Alive_check:
	lea.l	Party_handles,a0		; Get member data
	move.b	-1(a0,d0.w),d7
	beq.s	.Exit
	Get	d7,a0
	move.w	Body_conditions(a0),d6
	Free	d7
	andi.w	#Alive_mask,d6		; Alive ?
	bne.s	.Exit
	move.w	d0,Selected_member		; Yes
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ Check if selected member can be spoken with ]
;   IN : d0 - Selected member number (.w)
; No registers are restored
;*****************************************************************************
Talk_check:
	lea.l	Party_handles,a0		; Get member data
	move.b	-1(a0,d0.w),d7
	beq.s	.Exit
	Get	d7,a0
	move.w	Body_conditions(a0),d6
	Free	d7
	andi.w	#Talk_mask,d6		; Talking ?
	bne.s	.Exit
	move.w	d0,Selected_member		; Yes
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ Check if selected member's inventory can be accessed ]
;   IN : d0 - Selected member number (.w)
; No registers are restored
;*****************************************************************************
Inventory_check:
	lea.l	Party_handles,a0		; Get member data
	move.b	-1(a0,d0.w),d7
	beq.s	.Exit
	Get	d7,a0
	move.w	Body_conditions(a0),d1
	move.b	Secret_inventory(a0),d2
	Free	d7
	tst.b	d2			; Secret inventory ?
	beq.s	.No
	move.b	d7,Subject_handle		; Yes !
	move.w	#286,d0			; "Begone!"
	jsr	Do_prompt_window
	bra.s	.Exit
.No:	andi.w	#Inv2_mask,d1		; Can access inventory ?
	bne.s	.Exit
	move.w	d0,Selected_member		; Yes
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ Check if selected member is present ]
;   IN : d0 - Selected member number (.w)
; No registers are restored
;*****************************************************************************
Present_check:
	lea.l	Party_handles,a0		; Anyone there ?
	tst.b	-1(a0,d0.w)
	beq.s	.Exit
	move.w	d0,Selected_member		; Yes
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ High level text commands ]
;   IN : a0 - Pointer to raw text (.l)
;        a1 - Pointer to command parameters (.l)
; Changed registers : a0,a1
; NOTE :
;  - a0 and a1 may be changed but must be kept VALID in any case.
;*****************************************************************************
HLC_table:
	dc.l "LEAD",Insert_leader_name	; Active member's name
	dc.l "SELF",Insert_self_name		; Player's name
	dc.l "CAST",Insert_caster_name	; Caster's name
	dc.l "INVN",Insert_inventory_name	; Inventory character's name
	dc.l "SUBJ",Insert_subject_name	; Subject's name
	dc.l "SEX1",Insert_sex1		; He/she of subject
	dc.l "SEX2",Insert_sex2		; His/her of subject
	dc.l 0

Insert_leader_name:
	move.l	d1,-(sp)
	move.b	Active_handle,d1
	jsr	Insert_name
	move.l	(sp)+,d1
	rts

Insert_self_name:
	movem.l	d0/d1/a2,-(sp)
	move.b	Party_handles,d1		; First character
	Get	d1,a2			; Is alive ?
	move.w	Body_conditions(a2),d0
	Free	d1
	andi.w	#Alive_mask,d0
	beq.s	.Yes
	move.b	Active_handle,d1		; No -> Take active
.Yes:	jsr	Insert_name
	movem.l	(sp)+,d0/d1/a2
	rts

Insert_caster_name:
	move.l	d1,-(sp)
	move.b	Casting_handle,d1
	jsr	Insert_name
	move.l	(sp)+,d1
	rts

Insert_inventory_name:
	move.l	d1,-(sp)
	move.b	Inventory_handle,d1
	jsr	Insert_name
	move.l	(sp)+,d1
	rts

Insert_subject_name:
	move.l	d1,-(sp)
	move.b	Subject_handle,d1
	jsr	Insert_name
	move.l	(sp)+,d1
	rts

Insert_name:
	movem.l	d0/a1,-(sp)
	move.b	d1,d0			; Get character data
	jsr	Claim_pointer
	move.l	d0,a1
	lea.l	Char_name(a1),a1		; Insert name
	jsr	Strcpy
	subq.l	#1,a0
	move.b	d1,d0			; Free pointer
	jsr	Free_pointer
	movem.l	(sp)+,d0/a1
	rts

Insert_sex1:
	movem.l	d0/a1,-(sp)
	Get	Subject_handle,a1		; Get sex of character
	move.b	Char_sex(a1),d0
	Free	Subject_handle
	tst.b	d0			; Male or female ?
	beq.s	.He
	move.l	She_txt_ptr,a1		; Female
	bra.s	.Do
.He	move.l	He_txt_ptr,a1			; Male
.Do:	jsr	Strcpy			; Insert sex
	subq.l	#1,a0
	movem.l	(sp)+,d0/a1
	rts

Insert_sex2:
	movem.l	d0/a1,-(sp)
	Get	Subject_handle,a1		; Get sex of character
	move.b	Char_sex(a1),d0
	Free	Subject_handle
	tst.b	d0			; Male or female ?
	beq.s	.He
	move.l	Hers_txt_ptr,a1		; Female
	bra.s	.Do
.He	move.l	His_txt_ptr,a1		; Male
.Do:	jsr	Strcpy			; Insert sex
	subq.l	#1,a0
	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Probe	/ 100% ]
;   IN : d0 - Probe	value (.w)
;  OUT : pl - Positive probe (dice roll	=< probe value)
;        mi - Negative probe (dice roll	 > probe value)
; All registers are	restored
;*****************************************************************************
Probe_100:
	movem.l	d1,-(sp)
	move.w	#100,d1			; 100 %
	jsr	Probe
	movem.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Probe	]
;   IN : d0 - Probe	value (.w)
;        d1 - Probe range (.w)
;  OUT : pl - Positive probe (dice roll	=< probe value)
;        mi - Negative probe (dice roll	 > probe value)
; All registers are	restored
;*****************************************************************************
Probe:
	movem.l	d0-d2/d7,-(sp)
	cmpi.w	#Super_chicken,Travel_mode	; Superchicken mode	?
	bne.s	.Go_on
	moveq.l	#0,d7			; Yes -> Success
	bra.s	.Exit
.Go_on:	tst.w	d0			; Zero or lower ?
	bgt.s	.Ok1
	moveq.l	#-1,d7			; Yes -> Failure
	bra.s	.Exit
.Ok1:	cmp.w	d1,d0			; Above probe range ?
	bmi.s	.Ok2
	moveq.l	#0,d7			; Yes -> Success
	bra.s	.Exit
.Ok2:	move.w	d0,d2			; Save
	jsr	Random			; Get {random} MOD {range}
	mulu.w	d1,d0
	swap.w	d0
	cmp.w	d0,d2			; Probe
	smi	d7
.Exit:	tst.b	d7			; Well ?
	movem.l	(sp)+,d0-d2/d7
	rts

;*****************************************************************************
; [ Do magic sparkle ]
;   IN : d0 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Do_sparkle:         
	movem.l	d0/d7/a0,-(sp)
	lea.l	Magic_counters,a0		; Set counter
	move.b	#Max_sparkles,-1(a0,d0.w)
	lea.l	Sparkle_data,a0		; Find sparkle data
	subq.w	#1,d0
	mulu.w	#Max_sparkles*Sparkle_data_size,d0
	add.w	d0,a0
	moveq.l	#Max_sparkles-1,d7		; Initialize sparkles
.Loop:	jsr	Random			; Set frame
	andi.w	#$000f,d0	
	move.b	.Distribution(pc,d0.w),d0
	lsl.w	#2,d0
	move.b	d0,Sparkle_frame(a0)
	jsr	Random			; Set X-coordinate
	andi.w	#$001f,d0
	move.b	d0,Sparkle_X(a0)
	jsr	Random			; Set Y-coordinate
	andi.w	#$001f,d0
	subi.w	#16,d0
	move.b	d0,Sparkle_Y(a0)
	addq.w	#Sparkle_data_size,a0	; Next sparkle
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d7/a0
	rts

.Distribution:
	dc.b 4,4,4,4,4,4,4
	dc.b 3,3,3,3,3
	dc.b 2,2,2,2
	even

;*****************************************************************************
; [ Do damage ]
;   IN : d0 - Amount of damage (.w)
;        d7 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Do_damage:
	movem.l	d0-d2/d7/a0,-(sp)
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq.s	.Exit
	lea.l	Party_handles,a0		; Get pointer to character
	move.b	-1(a0,d7.w),d1
	beq.s	.Exit			; Anyone there ?
	Get	d1,a0
	move.w	Life_points(a0),d2		; Do the damage
	sub.w	d0,d2
	bgt.s	.Ok			; Dead ?
	Free	d1
	jsr	Kill_member		; Kill !
	bra.s	.Exit
.Ok:	move.w	d2,Life_points(a0)		; Store new LP
	Free	d1
	lea.l	Char_damage,a0		; Start damage
	move.b	d0,-1(a0,d7.w)
	move.b	#Damage_interval,-1+6(a0,d7.w)
.Exit:	movem.l	(sp)+,d0-d2/d7/a0
	rts

;*****************************************************************************
; [ Kill party member ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Kill_member:
	movem.l	d0-d7/a0,-(sp)
	lea.l	Party_handles,a0		; Get pointer to character
	move.b	-1(a0,d7.w),d1
	beq	.Exit			; Anyone there ?
	Get	d1,a0
	move.w	Body_conditions(a0),d0	; Kill !
	bset	#Dead,d0
	move.w	d0,Body_conditions(a0)
	clr.w	Life_points(a0)
	Free	d1
	jsr	Show_death		; Show
	jsr	Force_status_update
	cmp.w	Active_member,d7		; Was it our trusty	leader ?
	bne.s	.Exit
	tst.b	Battling			; In combat ?
	bne.s	.Exit
	jsr	Select_new_active_member	; No -> new leader
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Show party member's death ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Show_death:
	movem.l	d0-d7/a0/a1/a5,-(sp)
	opt	o11-				; (not optimized by the original assembler)
	lea.l	-Death_LDS(sp),sp		; Create local variables
	opt	o11+
	move.l	sp,a5
; ---------- Prepare ------------------------------
	move.w	d7,d0			; Calculate X-coordinate
	subq.w	#1,d0
	mulu.w	#48,d0
	addi.w	#16,d0
	opt	o2-				; (not optimized by the original assembler)
	move.w	d0,KillX(a5)		; Store
	opt	o2+
	lea.l	Kill_CA,a0		; Make clip area
	move.w	d0,CA_X1(a0)
	move.w	#1,CA_Y1(a0)
	addi.w	#32-1,d0
	move.w	d0,CA_X2(a0)
	move.w	#1+34-1,CA_Y2(a0)
	move.w	#1-34,SkullY(a5)		; Set Y-coordinates
	move.w	#1,FaceY(a5)
; ---------- Display character's name -------------
	lea.l	Party_handles,a0		; Duplicate first five
	move.b	-1(a0,d7.w),d1		;  letters of member's name
	Get	d1,a0
	lea.l	Char_name(a0),a0
	lea.l	Temp_name,a1
	moveq.l	#5-1,d0
.Loop:	move.b	(a0)+,(a1)+
	dbeq	d0,.Loop
	Free	d1
	Push	PA,Status_PA		; Set PA & ink
	move.w	#Lighter_blue,Ink_colour
	opt	o2-				; (not optimized by the original assembler)
	move.w	KillX(a5),d0		; Display	character	name
	opt	o2+
	addq.w	#2,d0
	moveq.l	#31,d1
	moveq.l	#30,d2
	lea.l	Temp_name,a0
	jsr	Print_centered_string
	jsr	Update_screen
; ---------- Do -----------------------------------
	Push	CA,Kill_CA
	lea.l	Portrait_handles,a0		; Get portrait address
	move.b	-1(a0,d7.w),d0
	move.b	d0,Kill_handle(a5)
	jsr	Claim_pointer
	move.l	d0,a1
	moveq.l	#2,d6			; Get portrait dimension
	moveq.l	#34,d7
	opt	o2-				; (not optimized by the original assembler)
.Again:	move.w	KillX(a5),d0		; Erase area
	opt	o2+
	moveq.l	#1,d1
	move.w	d0,d2
	addi.w	#32-1,d2
	moveq.l	#1+34-1,d3
	moveq.l	#25,d4
	jsr	Draw_box
	move.w	FaceY(a5),d1		; Display portrait
	moveq.l	#5,d5
	move.l	a1,a0
	jsr	Put_unmasked_block
	move.w	SkullY(a5),d1		; Display skull
	moveq.l	#24,d4
	moveq.l	#3,d5
	lea.l	Death_mask,a0
	jsr	Put_unmasked_block
	addq.w	#2,d0			; Display	character	name
	moveq.l	#31,d1
	moveq.l	#30,d2
	lea.l	Temp_name,a0
	move.w	#Lighter_blue,Ink_colour
	jsr	Print_centered_string
	jsr	Switch_screens		; Show
	addq.w	#2,FaceY(a5)		; Move down
	addq.w	#1,SkullY(a5)
	cmp.w	#1+1,SkullY(a5)		; Done ?
	blt.s	.Again
	Pop	CA
; ---------- End ----------------------------------
	jsr	Update_screen		; Update
	move.b	Kill_handle(a5),d0		; End
	jsr	Free_pointer
	Pop	PA
	opt	o11-				; (not optimized by the original assembler)
	lea.l	Death_LDS(sp),sp		; Destroy local variables
	opt	o11+
	movem.l	(sp)+,d0-d7/a0/a1/a5
	rts

	rsreset
KillX:	rs.w 1
FaceY:	rs.w 1
SkullY:	rs.w 1
Kill_handle:	rs.b 1
	rseven
Death_LDS:	rs.b 0

;*****************************************************************************
; [ Remove party member ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Remove_party_member:
	movem.l	d0-d2/d7/a0/a1,-(sp)
	jsr	Show_removal		; Show
	lea.l	Party_handles-1,a1		; Clear bit in CD array
	add.w	d7,a1
	Get	(a1),a0
	move.w	Person_save_bit_pos(a0),d0
	moveq.l	#CD_bit_array,d1
	moveq.l	#0,d2
	jsr	Access_bit_array
	Free	(a1)
	jsr	Get_CD_value		; Reset
	lea.l	Member_nrs,a0		; Save datafile
	move.w	d7,d0
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0
	moveq.l	#Party_char_file,d1
	Get	(a1),a0
	jsr	Save_subfile
	move.b	(a1),d0			; Free memory
	jsr	Free_pointer
	jsr	Kill_memory
	clr.b	(a1)			; Clear handle
	move.w	d7,d0
	add.w	d0,d0
	lea.l	Magic_counters,a0		; Clear magic counter
	clr.b	-1(a0,d7.w)
	lea.l	Member_nrs,a0		; Clear member number
	clr.w	-2(a0,d0.w)
	lea.l	Char_damage,a0		; Clear damage counter
	clr.w	-2(a0,d0.w)
	subq.w	#1,Nr_members		; Count down
	jsr	Update_status_block		; Update
	jsr	Update_screen
	cmp.w	Active_member,d7		; Was this the leader ?
	bne.s	.Exit
	jsr	Select_new_active_member	; Yes -> New leader
.Exit:	movem.l	(sp)+,d0-d2/d7/a0/a1
	rts

;*****************************************************************************
; [ Show party member's removal ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Show_removal:
	movem.l	d0-d7/a0/a1/a5,-(sp)
	subq.w	#Death_LDS,sp		; Create local variables
	move.l	sp,a5
; ---------- Prepare ------------------------------
	move.w	d7,d0			; Calculate X-coordinate
	subq.w	#1,d0
	mulu.w	#48,d0
	addi.w	#16,d0
	move.w	d0,KillX(a5)		; Store
	lea.l	Kill_CA,a0		; Install clip area
	move.w	d0,CA_X1(a0)
	move.w	#1,CA_Y1(a0)
	move.w	d0,CA_X2(a0)
	add.w	#32-1,CA_X2(a0)
	move.w	#1+34-1,CA_Y2(a0)
	jsr	Push_CA
	move.w	#1-34,SkullY(a5)		; Set Y-coordinate
	lea.l	Party_handles,a0		; Duplicate first five
	move.b	-1(a0,d7.w),d1		;  letters of member's name
	Get	d1,a0
	lea.l	Char_name(a0),a0
	lea.l	Temp_name,a1
	moveq.l	#5-1,d0
.Loop:	move.b	(a0)+,(a1)+
	dbeq	d0,.Loop
	Free	d1
	Push	PA,Status_PA		; Set PA & ink
	move.w	#Red,Ink_colour
	lea.l	Portrait_handles,a0		; Get portrait address
	move.b	-1(a0,d7.w),d0
	move.b	d0,Kill_handle(a5)
	jsr	Claim_pointer
	move.l	d0,a1
	jsr	Update_screen
; ---------- Do --------------------------------------
	moveq.l	#30,d2
	moveq.l	#2,d6
	moveq.l	#34,d7
.Again:	move.w	KillX(a5),d0		; Display portrait
	moveq.l	#1,d1
	moveq.l	#5,d5
	move.l	a1,a0
	jsr	Put_unmasked_block
	addq.w	#2,d0			; Display	character	name
	moveq.l	#31,d1
	lea.l	Temp_name,a0
	jsr	Print_centered_string
	subq.w	#2,d0			; Display empty portrait
	move.w	SkullY(a5),d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	lea.l	Empty_portrait,a0
	jsr	Put_unmasked_block
	jsr	Switch_screens		; Show
	addq.w	#1,SkullY(a5)		; Move down
	cmp.w	#2+1,SkullY(a5)		; Done ?
	blt.s	.Again
; ---------- End ----------------------------------
	jsr	Update_screen		; Update
	move.b	Kill_handle(a5),d0		; End
	jsr	Free_pointer
	Pop	PA
	Pop	CA
	addq.w	#Death_LDS,sp		; Destroy local variables
	movem.l	(sp)+,d0-d7/a0/a1/a5
	rts

;*****************************************************************************
; [ De-exhaust party member ]
;   IN : a0 - Pointer to character data (.l)
; All registers are	restored
;*****************************************************************************
De_exhaust:
	movem.l	d0/d7/a1,-(sp)
	move.w	Body_conditions(a0),d0	; Exhausted ?
	bclr	#Exhausted,d0
	beq.s	.Exit
	move.w	d0,Body_conditions(a0)	; No more
	lea.l	Attributes(a0),a1		; Restore attributes
	moveq.l	#Max_attrs-1,d7
.Loop1:	move.w	Backup(a1),(a1)
	addq.w	#Attr_data_size,a1	; Next attribute
	dbra	d7,.Loop1
	lea.l	Skills(a0),a1		; Restore skills
	moveq.l	#Max_skills-1,d7
.Loop2:	move.w	Backup(a1),(a1)
	addq.w	#Skill_data_size,a1	; Next skill
	dbra	d7,.Loop2
.Exit:	movem.l	(sp)+,d0/d7/a1
	rts

;*****************************************************************************
; [ Increase life points ]
;   IN : d0 - Added amount of LP (.w)
;        d7 - Member number {1...6} (.w)
; All registers are restored
;*****************************************************************************
Increase_LP:
	movem.l	d0-d2/a0/a1,-(sp)
	lea.l	Party_handles-1,a0
	add.w	d7,a0
	tst.b	(a0)			; Anyone there ?
	beq.s	.Exit
	Get	(a0),a1			; Get character data
	move.w	Life_points(a1),d1		; Get data
	move.w	Life_points+Maximum(a1),d2
	add.w	Life_points+Magic(a1),d2
	cmp.w	d2,d1			; Already	too much ?
	bpl.s	.Done
	add.w	d0,d1			; Add
	cmp.w	d2,d1			; Too much ?
	bmi.s	.Ok
	move.w	d2,d1			; Yes -> adjust
.Ok:	move.w	d1,Life_points(a1)
.Done:	Free	(a0)
.Exit:	movem.l	(sp)+,d0-d2/a0/a1
	rts

;*****************************************************************************
; [ Increase spell points ]
;   IN : d0 - Added	amount of	PP (.w)
;        d7 - Member number {1...6} (.w)
; All registers are	restored
;*****************************************************************************
Increase_PP:
	movem.l	d0-d2/a0/a1,-(sp)
	lea.l	Party_handles-1,a0
	add.w	d7,a0
	tst.b	(a0)			; Anyone there ?
	beq.s	.Exit
	Get	(a0),a1			; Get character data
	move.w	Power_points(a1),d1		; Get data
	move.w	Power_points+Maximum(a1),d2
	add.w	Power_points+Magic(a1),d2
	cmp.w	d2,d1			; Already	too much ?
	bpl.s	.Done
	add.w	d0,d1			; Add
	cmp.w	d2,d1			; Too much ?
	bmi.s	.Ok
	move.w	d2,d1			; Yes -> adjust
.Ok:	move.w	d1,Power_points(a1)
.Done:	Free	(a0)
.Exit:	movem.l	(sp)+,d0-d2/a0/a1
	rts

;*****************************************************************************
; [ Move in one of 4 directions ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Direction {0=N, 1=E, 2=S, 3=W} (.w)
;  OUT : d0 - New X-coordinate (.w)
;        d1 - New Y-coordinate (.w)
; Changed registers : d0,d1
;*****************************************************************************
Move_in_direction:
	movem.l	d2/a0,-(sp)
	lea.l	Dir_offset,a0		; Get offsets
	andi.w	#$0003,d2
	add.w	d2,d2
	add.w	d2,a0
	move.b	(a0)+,d2			; Update X
	ext.w	d2
	add.w	d2,d0
	move.b	(a0),d2			; Update Y
	ext.w	d2
	add.w	d2,d1
	movem.l	(sp)+,d2/a0
	rts

;*****************************************************************************
; [ Move in one of 8 directions ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Direction {0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW} (.w)
;  OUT : d0 - New X-coordinate (.w)
;        d1 - New Y-coordinate (.w)
; Changed registers : d0,d1
;*****************************************************************************
Move_in_8_directions:
	movem.l	d2/d3/a0,-(sp)
	lea.l	Dir8_offset,a0		; Get offsets
	andi.w	#$0007,d2
	add.w	d2,d2
	add.w	d2,a0
	move.b	(a0)+,d2			; Update X
	ext.w	d2
	add.w	d2,d0
	move.b	(a0),d2			; Update Y
	ext.w	d2
	add.w	d2,d1
	movem.l	(sp)+,d2/d3/a0
	rts

;*****************************************************************************
; [ Clear new words array ]
; All registers are restored
;*****************************************************************************
Clear_new_words_array:
	movem.l	d7/a0,-(sp)
	lea.l	New_words,a0
	move.w	#((Max_words+7)/8)-1,d7
.Loop:	clr.b	(a0)+
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Test / modify bit from array ]
;   IN : d0 - Bit number (.w)
;        d1 - Bit array type (.w)
;        d2 - 0 = Clear bit  (.b)
;             1 = Set bit
;             2 = Toggle bit
;             3 = Test
;  OUT : (if d2 = 3)
;        eq - Bit was cleared
;        ne - Bit was set
; All registers are restored
;*****************************************************************************
Access_bit_array:
	movem.l	d0/d1/a0,-(sp)
	cmp.w	#Max_bit_array,d1		; Legal array type ?
	bpl	.Exit
	lea.l	.Bit_array_table(pc),a0	; Get bit array info
	lsl.w	#3,d1
	add.l	d1,a0
	andi.l	#$0000ffff,d0		; Legal number ?
	cmp.l	(a0)+,d0
	bcc.s	.Exit
	move.l	(a0),a0			; Get array address
	moveq.l	#$0007,d1			; Calculate bit & byte
	and.w	d0,d1
	lsr.w	#3,d0
	add.w	d0,a0
	tst.b	d2			; Clear ?
	bne.s	.No1
	bclr	d1,(a0)			; Clear
	bra.s	.Exit
.No1:	cmp.b	#1,d2			; Set ?
	bne.s	.No2
	bset	d1,(a0)			; Set
	bra.s	.Exit
.No2:	cmp.b	#2,d2			; Toggle ?
	bne.s	.No3
	bchg	d1,(a0)			; Toggle
	bra.s	.Exit
.No3:	cmp.b	#3,d2			; Test ?
	bne.s	.Exit
	btst	d1,(a0)			; Test
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

.Bit_array_table:
	dc.l Max_quest,Quest
	dc.l Max_chests,Chest_open
	dc.l Max_doors,Door_open
	dc.l Max_CD,CD
	dc.l Max_event,Event
	dc.l Max_words,WD
	dc.l Max_words,New_words
	dc.l Max_Goto_points,Goto_points

;*****************************************************************************
; [ Pool gold ]
;  OUT : d0 - Pooled gold coins (.w)
; Changed registers : d0
;*****************************************************************************
Pool_gold:    
	movem.l	d1/d2/d6/d7/a0/a1,-(sp)
	lea.l	Party_handles,a0		; Calculate gold demand
	move.w	#Special_race_mask,d2
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop1:	tst.b	(a0)			; Any character there ?
	beq	.Next1
	Get	(a0),a1			; Get character data
; ---------- Check if character is normal ---------
	move.b	Char_race(a1),d0		; Special or monster ?
	btst	d0,d2
	bne.s	.Done1
; ---------- Check if member is alive -------------
	move.w	#Alive_mask,d0
	and.w	Body_conditions(a1),d0
	bne.s	.Done1
; ---------- Check if member is secretive ---------
	tst.b	Secret_inventory(a1)
	bne.s	.Done1
; ---------- Pool gold ----------------------------
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
	moveq.l	#0,d7			; Force end of loop
.No:	sub.w	d0,Gold_coins(a1)		; Remove gold
	mulu.w	#Gold_weight,d0		; Remove weight
	sub.l	d0,Weight_normal(a1)
.Done1:	Free	(a0)+			; Next member
.Next1:	dbra	d7,.Loop1
	move.w	d6,d0			; Output
	movem.l	(sp)+,d1/d2/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Divide gold ]
;   IN : d0 - Number of gold coins (.w)
;  OUT : d0 - Remaining gold coins (.w)
; Changed registers : d0
;*****************************************************************************
Divide_gold:
	movem.l	d1/d2/d6/d7/a0-a2,-(sp)
	andi.l	#$0000ffff,d0
	beq	.Exit			; Any gold ?
	move.l	d0,-(sp)
	lea.l	Party_handles,a0		; Calculate gold demand
	lea.l	Divide_workspace,a1
	move.w	#Special_race_mask,d2
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop1:	moveq.l	#0,d0			; Default is no gold
	tst.b	(a0)			; Any character there ?
	beq	.Next1
	Get	(a0),a2			; Get character data
; ---------- Check if character is normal ---------
	move.b	Char_race(a2),d1		; Special or monster ?
	btst	d1,d2
	bne	.Done1
; ---------- Check if member is alive -------------
	move.w	#Alive_mask,d1
	and.w	Body_conditions(a2),d1
	bne.s	.Done1
; ---------- Check if member is secretive ---------
	tst.b	Secret_inventory(a2)
	bne.s	.Done1
; ---------- Calculate gold demand by weight ------
	move.w	AStrength(a2),d0		; Carry how many ?
	add.w	AStrength+Magic(a2),d0
	addq.w	#1,d0
	mulu.w	#1000,d0
	subq.l	#1,d0
	sub.l	Weight_normal(a2),d0
	beq.s	.Done1
	divu.w	#Gold_weight,d0
; ---------- Check if too much --------------------
	move.w	Gold_coins(a2),d1		; Not too much ?
	add.w	d0,d1
	bvc.s	.Done1
	move.w	#32767,d0
	sub.w	Gold_coins(a2),d0
.Done1:	Free	(a0)
.Next1:	move.w	d0,(a1)+			; Store potential gold
	tst.w	d0
	beq.s	.Skip1
	addq.w	#1,d6			; Count
.Skip1:	addq.l	#1,a0			; Next member
	dbra	d7,.Loop1
; ---------- Divide the gold ----------------------
	move.l	(sp)+,d0
	tst.w	d6			; Anyone interested ?
	beq	.Exit
	move.l	#Gold_weight,d2		; Yes
.Again:	subq.w	#6,a0			; Try to divide
	lea.l	-12(a1),a1
	moveq.l	#6-1,d7
.Loop2:	tst.w	(a1)			; Interested ?
	beq.s	.Next2
	Get	(a0),a2			; Yes -> give gold
	subq.w	#1,d0
	addq.w	#1,Gold_coins(a2)
	add.l	d2,Weight_normal(a2)
	subq.w	#1,(a1)
	bne.s	.Done2			; Satisfied ?
	subq.w	#1,d6			; Yes -> count down
.Done2:	Free	(a0)
.Next2:	tst.w	d0			; All gold divided ?
	beq.s	.Exit
	tst.w	d6			; All satisfied ?
	beq.s	.Exit
	addq.l	#1,a0			; Next member
	addq.l	#2,a1
	dbra	d7,.Loop2
	bra.s	.Again			; Again
.Exit:	movem.l	(sp)+,d1/d2/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Divide food ]
;   IN : d0 - Number of food rations (.w)
;  OUT : d0 - Remaining food rations (.w)
; Changed registers : d0
;*****************************************************************************
Divide_food:
	movem.l	d1/d2/d6/d7/a0-a2,-(sp)
	andi.l	#$0000ffff,d0
	beq	.Exit			; Any food ?
	move.l	d0,-(sp)
	lea.l	Party_handles,a0		; Calculate food demand
	lea.l	Divide_workspace,a1
	move.w	#Special_race_mask,d2
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop1:	moveq.l	#0,d0			; Zero food
	tst.b	(a0)			; Any character there ?
	beq	.Next1
	Get	(a0),a2			; Get character data
; ---------- Check if character is normal ---------
	move.b	Char_race(a2),d0		; Special or monster ?
	btst	d0,d2
	bne.s	.Done1
; ---------- Check if member is alive -------------
	move.w	#Alive_mask,d0
	and.w	Body_conditions(a2),d0
	bne.s	.Done1
; ---------- Check if member is secretive ---------
	tst.b	Secret_inventory(a2)
	bne.s	.Done1
; ---------- Calculate food demand by weight ------
	move.w	AStrength(a2),d0		; Carry how many ?
	add.w	AStrength+Magic(a2),d0
	addq.w	#1,d0
	mulu.w	#1000,d0
	subq.l	#1,d0
	sub.l	Weight_normal(a2),d0
	divu.w	#Food_weight,d0
; ---------- Check if too much --------------------
	move.w	Food_rations(a2),d1		; Not too much ?
	add.w	d0,d1
	bvc.s	.Done1
	move.w	#32767,d0
	sub.w	Food_rations(a2),d0
.Done1:	Free	(a0)
.Next1:	move.w	d0,(a1)+			; Store potential food
	beq.s	.Skip1
	addq.w	#1,d6			; Count
.Skip1:	addq.l	#1,a0			; Next member
	dbra	d7,.Loop1
; ---------- Divide the food ----------------------
	move.l	(sp)+,d0
	tst.w	d6			; Anyone interested ?
	beq	.Exit
	opt	o4-				; (not optimized by the original assembler)
	move.l	#Food_weight,d2		; Yes
	opt	o4+
.Again:	subq.w	#6,a0			; Try to divide
	lea.l	-12(a1),a1
	moveq.l	#6-1,d7
.Loop2:	tst.w	(a1)			; Interested ?
	beq.s	.Next2
	Get	(a0),a2			; Yes -> give food
	subq.w	#1,d0
	addq.w	#1,Food_rations(a2)
	add.l	d2,Weight_normal(a2)
	subq.w	#1,(a1)
	bne.s	.Done2			; Satisfied ?
	subq.w	#1,d6			; Yes -> count down
.Done2:	Free	(a0)
.Next2:	tst.w	d0			; All food divided ?
	beq.s	.Exit
	tst.w	d6			; All satisfied ?
	beq.s	.Exit
	addq.l	#1,a0			; Next member
	addq.l	#2,a1
	dbra	d7,.Loop2
	bra.s	.Again			; Again
.Exit:	movem.l	(sp)+,d1/d2/d6/d7/a0-a2
	rts

;*****************************************************************************
; [ Check if active character carries items in backpack ]
;  OUT : eq - Empty
;        ne - Not empty
; All registers are restored
;*****************************************************************************
Check_active_backpack:
	movem.l	d0/d7/a0,-(sp)
	Get	Active_handle,a0		; Get backpack data
	lea.l	Char_inventory+Backpack_slots(a0),a0
	move.w	Object_index(a0),d0		; Get first item
	addq.w	#Object_packet_size,a0
	moveq.l	#Items_per_char-2,d7	; OR with other items
.Loop:	or.w	Object_index(a0),d0
	addq.w	#Object_packet_size,a0
	dbra	d7,.Loop
	Free	Active_handle
	tst.w	d0			; Well ?
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Check if an inventory is empty ]
;   IN : d0 - Inventory data handle (.b)
;  OUT : eq - Empty
;        ne - Not empty
; All registers are restored
; Notes :
;   - This routine assumes that the slots start at the beginning of the
;     memory block, and that there are {Items_per_chest} items.
;     Thus, it will work for Chest data, Merchant data and Sold slots.
;*****************************************************************************
Check_slots_empty:
	movem.l	d0/d1/d7/a0,-(sp)
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Get inventory address
	move.l	d0,a0
	move.w	Object_index(a0),d1		; Get first item
	addq.w	#Object_packet_size,a0
	moveq.l	#Items_per_chest-2,d7	; OR with other items
.Loop:	or.w	Object_index(a0),d1
	addq.w	#Object_packet_size,a0
	dbra	d7,.Loop
	move.w	(sp)+,d0			; Free pointer
	jsr	Free_pointer
	tst.w	d1			; Well ?
	movem.l	(sp)+,d0/d1/d7/a0
	rts

;*****************************************************************************
; [ Check if an inventory is full ]
;   IN : d0 - Inventory data handle (.b)
;  OUT : eq - Not full
;        ne - Full
; All registers are restored
; Notes :
;   - This routine assumes that the slots start at the beginning of the
;     memory block, and that there are {Items_per_chest} items.
;     Thus, it will work for Chest data, Merchant data and Sold slots.
;*****************************************************************************
Check_slots_full:
	movem.l	d0/d1/d7/a0,-(sp)
	moveq.l	#0,d1			; Default is not full
	move.w	d0,-(sp)
	jsr	Claim_pointer		; Get inventory address
	move.l	d0,a0
	moveq.l	#Items_per_chest-1,d7	; Check slots
.Loop:	tst.w	Object_index(a0)
	beq.s	.Not_full
	addq.w	#Object_packet_size,a0
	dbra	d7,.Loop
	moveq.l	#-1,d1			; Full !
.Not_full:	move.w	(sp)+,d0			; Free pointer
	jsr	Free_pointer
	tst.w	d1			; Well ?
	movem.l	(sp)+,d0/d1/d7/a0
	rts

;*****************************************************************************
; [ Count non-special members ]
;  OUT : d0 - Number (.w)
; Changed registers : d0
;*****************************************************************************
Count_members:
	movem.l	d1/d2/d7/a0/a1,-(sp)
	lea.l	Party_handles,a0
	moveq.l	#0,d0
	move.w	#Special_race_mask,d2
	moveq.l	#6-1,d7
.Loop:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next
	Get	(a0),a1
	move.b	Char_race(a1),d1		; Special or monster ?
	btst	d1,d2
	bne.s	.Done
	move.w	Body_conditions(a1),d1	; Alive and kicking ?
	andi.w	#Alive_mask,d1
	bne.s	.Done
	addq.w	#1,d0			; Count !
.Done:	Free	(a0)
.Next:	addq.l	#1,a0			; Next member
	dbra	d7,.Loop
	movem.l	(sp)+,d1/d2/d7/a0/a1
	rts

;***************************************************************************** 
; [ Check member levels ]
; All registers are restored
;***************************************************************************** 
Check_member_levels:
	movem.l	d0-d4/d7/a0-a4,-(sp)
	lea.l	Party_handles,a0		; Check party
	lea.l	Level_start_EPs,a1
	lea.l	Level_factors,a2
	lea.l	Make_level_counters,a4
	moveq.l	#0,d4
	moveq.l	#1,d7
.Loop:	clr.b	(a4)			; Clear
	tst.b	(a0)			; Anyone there ?
	beq	.Next
	Get	(a0),a3			; Get member data
	move.w	Body_conditions(a3),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne	.Done
	moveq.l	#0,d2			; Get current level
	move.b	Level_nr(a3),d2
	move.l	Experience_points(a3),d3	; Get current EP
	moveq.l	#0,d0			; Get start EP
	move.b	Char_class(a3),d0
	add.w	d0,d0
	move.w	0(a1,d0.w),d1
.Again:	cmpi.w	#Max_level,d2		; Maximum level ?
	bpl	.Done
	move.w	d2,d0			; Get EP factor
	add.w	d0,d0
	move.w	0(a2,d0.w),d0		; (for NEXT level)
	mulu.w	d1,d0			; Get total EP
	cmp.l	d3,d0			; Enough ?
	bgt	.Done
	addq.b	#1,(a4)			; Yes -> Count up
	addq.w	#1,d2			; Try next level
	moveq.l	#-1,d4			; Indicate
	bra.s	.Again
.Done:	Free	(a0)
.Next:	addq.l	#1,a0			; Next member
	addq.l	#1,a4
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	tst.w	d4			; Anyone made a level ?
	beq.s	.Exit
	Push	Module,Make_levels_Mod	; Yes -> Show
.Exit:	movem.l	(sp)+,d0-d4/d7/a0-a4
	rts

;*****************************************************************************
; [ Make levels ]
; All registers are restored
;*****************************************************************************
Make_levels:
	movem.l	d0-d7/a0-a4,-(sp)
	moveq.l	#Fanfare_music,d0		; Start music
	moveq.l	#0,d1
	jsr	Set_music
	move.w	#Make_level_X-16,d0		; Open window
	move.w	#Make_level_Y-16,d1
	moveq.l	#18,d2
	moveq.l	#6,d3
	sub.l	a0,a0
	jsr	Open_window
	lea.l	Party_handles,a2		; Check party
	lea.l	Make_level_counters,a4
	moveq.l	#1,d7
.Loop1:	tst.b	(a4)			; Making a level ?
	beq	.Next1
	Get	(a2),a1			; Yes
	moveq.l	#0,d6			; How many ?
	move.b	(a4),d6
	bra	.Entry2
; ---------- Increase character values ------------
.Loop2:	addq.b	#1,Level_nr(a1)		; Next level
	moveq.l	#0,d0			; Calculate new APR
	move.b	Level_nr(a1),d0
	move.w	Special_1(a1),d1		; Factor zero ?
	beq.s	.One
.Not_zero:	divu.w	d1,d0			; No -> Calculate
	tst.w	d0
	bne.s	.Ok1			; At least 1
.One:	moveq.l	#1,d0
.Ok1:	move.b	d0,Attacks_per_round(a1)	; Store
	move.w	Special_2(a1),d0		; Calculate extra LP & LP max
	jsr	Get_random_50_100
	add.w	d0,Life_points(a1)		; Add
	add.w	d0,Life_points+Maximum(a1)
	tst.b	Spell_class_counter(a1)	; Any spell classes	?
	beq	.No_magic1
	move.w	Special_3(a1),d0		; Calculate extra SP & SP max
	jsr	Get_random_50_100
	moveq.l	#0,d1			; Intelligence bonus
	move.w	AIntelligence(a1),d1
	divu.w	#20,d1
	add.w	d1,d0
	add.w	d0,Power_points(a1)		; Add
	add.w	d0,Power_points+Maximum(a1)
	move.w	Special_4(a1),d0		; Calculate extra SLP
	jsr	Get_random_50_100
	moveq.l	#0,d1			; Intelligence bonus
	move.w	AIntelligence(a1),d1
	divu.w	#20,d1
	add.w	d1,d0
	add.w	d0,Nr_spell_learn_points(a1)	; Add
.No_magic1:
	move.w	Special_5(a1),d0		; Calculate extra TP
	jsr	Get_random_50_100
	add.w	d0,Nr_training_points(a1)	; Add
.Entry2:	dbra	d6,.Loop2
; ---------- Display ------------------------------
	move.w	d7,-(sp)
	move.w	#Make_level_X,d0		; Clear inside of window
	move.w	#Make_level_Y,d1
	move.w	#Make_level_X+256-1,d2
	move.w	#Make_level_Y+64-1,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	moveq.l	#"0",d6			; Fill character
; ---------- Print member's level -----------------
	lea.l	Make_level_text,a3		; Print "... has level .."
	lea.l	Char_name(a1),a0		; Insert character name
	move.l	a0,(a3)
	lea.l	Number,a0			; Convert 
	move.l	a0,8(a3)
	moveq.l	#2,d7
	moveq.l	#0,d0
	move.b	Level_nr(a1),d0
	jsr	DecL_convert
	move.l	a3,a0			; Print
	moveq.l	#0,d0
	jsr	Display_text
; ---------- Print member's life points -----------
	move.w	#Default_ink,Ink_colour	; Set ink
	move.l	Prompts_ptr,a0		; "LP are now :"
	move.w	#193,d0
	jsr	Find_large_text
	move.w	#Make_level_X,d0
	move.w	#Make_level_Y+14,d1
	jsr	Put_text_line
	move.l	LP_txt_ptr,a3
	move.w	Life_points(a1),d0		; Convert	normal LP
	moveq.l	#3,d7
	lea.l	5(a3),a0
	jsr	DecR_convert
	move.b	#"/",(a0)			; Correction
	move.w	Life_points+Maximum(a1),d0	; Convert	maximum LP
	add.w	Life_points+Magic(a1),d0
	lea.l	9(a3),a0
	jsr	DecR_convert
	move.w	#Make_level_X+180,d0	; Print LP
	lea.l	5(a3),a0
	jsr	Put_text_line
; ---------- Print member's power points ----------
	tst.b	Spell_class_counter(a1)	; Any spell classes	?
	beq	.No_magic2
	move.l	Prompts_ptr,a0		; "PP are now :"
	move.w	#194,d0
	jsr	Find_large_text
	move.w	#Make_level_X,d0
	move.w	#Make_level_Y+21,d1
	jsr	Put_text_line
	move.l	PP_txt_ptr,a3
	move.w	Power_points+Maximum(a1),d0	; Convert	maximum PP
	add.w	Power_points+Magic(a1),d0
	lea.l	9(a3),a0
	jsr	DecR_convert
	move.w	Power_points(a1),d0		; Convert	normal PP
	lea.l	5(a3),a0
	jsr	DecR_convert
	move.b	#"/",(a0)			; Correction
	move.w	#Make_level_X+180,d0	; Print PP
	lea.l	5(a3),a0
	jsr	Put_text_line
; ---------- Print member's spell learn points ----
	move.l	Prompts_ptr,a0		; "SLP are now :"
	move.w	#195,d0
	jsr	Find_large_text
	move.w	#Make_level_X,d0
	move.w	#Make_level_Y+28,d1
	jsr	Put_text_line
	move.w	Nr_spell_learn_points(a1),d0	; Convert	SLP
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	#Make_level_X+180,d0	; Print SLP
	lea.l	Number,a0
	jsr	Put_text_line
; ---------- Print member's training points -------
.No_magic2:
	move.l	Prompts_ptr,a0		; "TP are now :"
	move.w	#196,d0
	jsr	Find_large_text
	move.w	#Make_level_X,d0
	move.w	#Make_level_Y+35,d1
	jsr	Put_text_line
	move.w	Nr_training_points(a1),d0	; Convert	TP
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	#Make_level_X+180,d0	; Print TP
	lea.l	Number,a0
	jsr	Put_text_line
; ---------- Print member's APR -------------------
	move.l	Prompts_ptr,a0		; "APR are now :"
	move.w	#197,d0
	jsr	Find_large_text
	move.w	#Make_level_X,d0
	move.w	#Make_level_Y+42,d1
	jsr	Put_text_line
	moveq.l	#0,d0			; Convert	APR
	move.b	Attacks_per_round(a1),d0
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	#Make_level_X+180,d0	; Print APR
	lea.l	Number,a0
	jsr	Put_text_line
; ---------- Print EP for next level --------------
	cmpi.b	#Max_level,Level_nr(a1)	; Maximum level ?
	bmi	.No
	move.l	Prompts_ptr,a0		; "Max !"
	move.w	#199,d0
	jsr	Find_large_text
	move.w	#Make_level_X,d0
	move.w	#Make_level_Y+56,d1
	jsr	Put_text_line
	bra	.Go_on
.No:	move.l	Prompts_ptr,a0		; "You need :"
	move.w	#198,d0
	jsr	Find_large_text
	move.w	#Make_level_X,d0
	move.w	#Make_level_Y+56,d1
	jsr	Put_text_line
	moveq.l	#0,d0			; Get start EP
	move.b	Char_class(a1),d0
	lea.l	Level_start_EPs,a3
	add.w	d0,d0
	move.w	0(a3,d0.w),d2
	moveq.l	#0,d0			; Get EP factor
	move.b	Level_nr(a1),d0
	lea.l	Level_factors,a3
	add.w	d0,d0
	move.w	0(a3,d0.w),d0		; (for NEXT level)
	mulu.w	d2,d0			; Get total EP
	lea.l	Number,a0			; Convert experience points
	moveq.l	#8,d7
	jsr	DecL_convert
	lea.l	Number,a0			; Print experience points
	jsr	Strlen
	move.w	d0,d7
	move.w	#Make_level_X+180,d0
	jsr	Put_text_line
	move.l	EP_txt_ptr,a0			; Print "EP."
	addq.w	#1,d7
	mulu.w	#Char_width+1,d7
	addi.w	#Make_level_X+180,d7
	move.w	d7,d0
	jsr	Put_text_line
; ---------- Wait & next --------------------------
.Go_on:	Free	(a2)
	jsr	Update_screen
	jsr	Wait_4_user		; Wait
	move.w	(sp)+,d7
.Next1:	addq.l	#1,a2			; Next member
	addq.l	#1,a4
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi	.Loop1
	jsr	Close_window		; Close window
	jsr	Set_map_music		; Reset music
	movem.l	(sp)+,d0-d7/a0-a4
	jmp	Pop_Module

;*****************************************************************************
; [ Switch music on ]
; All registers are restored
;*****************************************************************************
Music_on:
	move.l	d0,-(sp)
	move.w	Internal_flags,d0		; Game flag
	bclr	#Music_flag_bit,d0
	move.w	d0,Internal_flags
	st	Music_flag		; System flag
	moveq.l	#-1,d0			; Do
	jsr	Set_music
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Switch music off ]
; All registers are restored
;*****************************************************************************
Music_off:
	move.l	d0,-(sp)
	move.w	Internal_flags,d0		; Game flag
	bset	#Music_flag_bit,d0
	move.w	d0,Internal_flags
	sf	Music_flag		; System flag
	moveq.l	#0,d0			; Do
	jsr	Set_music
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Check object list for vital items & warn ]
;   IN : d0 - Memory handle of object list (.b)
;        d7 - Number of objects in object list (.w)
;  OUT : eq - No vital objects
;        ne - Some vital objects
; All registers are restored
;*****************************************************************************
Check_for_vital_items:
	movem.l	d0-d7/a0-a3,-(sp)
	move.b	d0,d4			; Save
; ---------- Check if vital items are left --------
	move.l	Object_data_ptr,a0		; Count vital items
	Get	d4,a1
	moveq.l	#0,d6
	move.w	d7,d3
	bra.s	.Entry1
.Loop1:	move.w	Object_index(a1),d0		; Anything there ?
	beq.s	.Next1
	subq.w	#1,d0			; Yes
	mulu.w	#Item_data_size,d0
	btst	#Droppable,Item_bits_STATIC(a0,d0.l)	; Vital ?
	bne.s	.Next1
	addq.w	#1,d6			; Yes -> Count
.Next1:	addq.w	#Object_packet_size,a1	; Next object
.Entry1:	dbra	d3,.Loop1
	Free	d4
	tst.w	d6			; Any vital items left ?
	bne.s	.Yes
	moveq.l	#0,d0			; NO!
	bra	.Exit
; ---------- Display names of vital items ---------
.Yes:	move.w	d6,d0			; Make text list
	lsl.w	#3,d0
	addq.l	#8,d0
	jsr	Allocate_memory
	move.b	d0,d5
	jsr	Claim_pointer		; Insert first text
	move.l	d0,a2
	move.l	Divide_start_text_ptr,(a2)+
	Get	d4,a1			; Insert names of items
	move.w	d7,d3
	bra.s	.Entry2
.Loop2:	move.w	Object_index(a1),d0		; Anything there ?
	beq.s	.Next2
	subq.w	#1,d0			; Yes
	mulu.w	#Item_data_size,d0
	btst	#Droppable,Item_bits_STATIC(a0,d0.l)	; Vital ?
	bne.s	.Next2
	lea.l	Item_name(a0,d0.l),a3	; Yes -> Insert name
	move.l	a3,(a2)+
	subq.w	#1,d6			; Count down
	beq.s	.Last
	move.l	Divide_inter_text_ptr,(a2)+	; Inbetween
	bra.s	.Next2
.Last:	move.l	Divide_end_text_ptr,(a2)+	; Last
	bra.s	.Done
.Next2:	addq.w	#Object_packet_size,a1	; Next object
.Entry2:	dbra	d3,.Loop2
.Done:	Free	d4
	clr.l	(a2)			; End text list
	move.b	d5,d0			; Display text
	jsr	Free_pointer
	jsr	Claim_pointer
	move.l	d0,a0
	moveq.l	#0,d0
	jsr	Display_text_and_wait
	move.b	d5,d0			; Exit
	jsr	Free_pointer
	jsr	Free_memory
	moveq.l	#-1,d0			; YES!
.Exit:	tst.w	d0			; Well ?
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Load object graphics ]
; All registers are restored
;*****************************************************************************
Load_object_graphics:
	movem.l	d0/d7,-(sp)
	move.b	Object_gfx_load_counter,d7	; Already present ?
	bne.s	.Skip
	moveq.l	#Object_gfx_file,d0		; No -> Load object graphics
	jsr	Load_file
	move.b	d0,Object_gfx_handle
.Skip:	addq.b	#1,d7			; Count up
	move.b	d7,Object_gfx_load_counter
	movem.l	(sp)+,d0/d7
	rts

;*****************************************************************************
; [ Free object graphics ]
; All registers are restored
;*****************************************************************************
Free_object_graphics:
	movem.l	d0/d7,-(sp)
	move.b	Object_gfx_load_counter,d7	; Present ?
	beq.s	.Exit
	subq.b	#1,d7			; Yes -> Count down
	bne.s	.Skip
	move.b	Object_gfx_handle,d0	; Free object graphics
	jsr	Free_memory
.Skip:	move.b	d7,Object_gfx_load_counter
.Exit:	movem.l	(sp)+,d0/d7
	rts

;*****************************************************************************
; [ Schnism check ]
;   IN : d0 - Key event code (.l)
; All registers are restored
;*****************************************************************************
Schnism_check:
	movem.l	d0/a0,-(sp)
	cmpi.w	#Max_Schnism,Schnism_counter	; Too much ?
	beq	.Exit
	movea.l	Schnism_ptr,a0
	cmp.b	(a0)+,d0			; Correct	?
	beq.s	.Correct
	lea.l	Schnism,a0		; No, try again
	bra	.Not_end
.Correct:	tst.b	(a0)			; End of password ?
	bne	.Not_end
	move.w	Schnism_counter,d0		; Get effect address
	lsl.w	#2,d0
	movea.l	.Ptrs(pc,d0.w),a0
	jsr	(a0)
	addq.w	#1,Schnism_counter		; Next !
	lea.l	Schnism,a0		; Try again
.Not_end:	move.l	a0,Schnism_ptr		; Store pointer
.Exit:	movem.l	(sp)+,d0/a0
	rts

.Ptrs:	dc.l Schnism_1,Schnism_2,Schnism_3

Schnism_1:
	moveq.l	#0,d0			; Phase 1
	jmp	Prompt_req

Schnism_2:
	move.w	#293,d0			; Phase 2
	jmp	Prompt_req

Schnism_3:
	move.w	#294,d0			; Phase 3
	jsr	Prompt_req
	lea.l	Party_handles,a0		; Drug the entire party
	moveq.l	#6-1,d7
.Loop:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next
	Get	(a0),a1			; Yes -> Drug
	move.w	Body_conditions(a1),d0
	bset	#Stoned,d0
	move.w	d0,Body_conditions(a1)
	Free	(a0)
.Next:	addq.l	#1,a0			; Next member
	dbra	d7,.Loop
	jmp	Check_active_member		; Do it

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Dir_offset:
	dc.b 0,-1,1,0,0,1,-1,0	; NESW
Dir8_offset:
	dc.b 0,-1,1,-1		; N NE
	dc.b 1,0,1,1		; E SE
	dc.b 0,1,-1,1		; S SW
	dc.b -1,0,-1,-1		; W NW
	even

Schnism:	dc.b "schnism",0
Schnism_ptr:	dc.l Schnism

; *** MAIN TREE : 1st layer ***
Main_tree:
	dc.w 0,0
	dc.w 0,319,0,35			; Status block area
	dc.b 1
	even
	dc.l .C2,Statusblock_L2C1
.C2:	dc.w 0,319,37,199			; Layout area
	dc.b 2
	even
	dc.l 0
Layout_ptr: 
   	dc.l 0				; Layout-dependent data

; *** STATUS BLOCK : 2nd layer ***
Statusblock_L2C1:
	dc.w 16,47+16,1,35			; Member 1 portrait
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 64,95+16,1,35			; Member 2 portrait
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 112,143+16,1,35		; Member 3 portrait
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 160,191+16,1,35		; Member 4 portrait
	dc.b 4
	even
	dc.l .C5,0
.C5:	dc.w 208,239+16,1,35		; Member 5 portrait
	dc.b 5
	even
	dc.l .C6,0
.C6:	dc.w 256,287+16,1,35		; Member 6 portrait
	dc.b 6
	even
	dc.l 0,0

; *** CONTROL ICONS : 2nd layer ***
Control_area:	dc.w 208,303,145,192	; Control	icon area
	dc.b 1
	even
	dc.l 0,Control_C1

; *** CONTROL ICONS : 3rd layer ***
Control_C1:	
	dc.w 208,239,145,160		; Control	icon 1
	dc.b 1
	even
	dc.l .C2
.C2:	dc.w 240,271,145,160		; Control	icon 2
	dc.b 2
	even
	dc.l .C3
.C3:	dc.w 272,303,145,160		; Control	icon 3
	dc.b 3
	even
	dc.l .C4
.C4:	dc.w 208,239,161,176		; Control	icon 4
	dc.b 4
	even
	dc.l .C5
.C5:	dc.w 240,271,161,176		; Control	icon 5
	dc.b 5
	even
	dc.l .C6
.C6:	dc.w 272,303,161,176		; Control	icon 6
	dc.b 6
	even
	dc.l .C7
.C7:	dc.w 208,239,177,192		; Control	icon 7
	dc.b 7
	even
	dc.l .C8
.C8:	dc.w 240,271,177,192		; Control	icon 8
	dc.b 8
	even
	dc.l .C9
.C9:	dc.w 272,303,177,192		; Control	icon 9
	dc.b 9
	even
	dc.l 0

; *** LOAD/QUIT REQUESTER : 1st layer ***
LQReq_L1:	dc.w 128,169
	dc.w 0,31,0,16
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 32,63,0,16
	dc.b 2
	even
	dc.l 0,0

Ghost1_HDOB:
	dc.w 0,0
	dc.w 0,Char_height+1,5,0
	dc.l 0
	dc.b 0,0
	dcb.w 6,0
Ghost2_HDOB:
	dc.w 0,0
	dc.w 0,Char_height+1,5,0
	dc.l 0
	dc.b 0,0
	dcb.w 6,0

	SECTION	Fast_BSS,bss
Initial_save:	ds.w 1			; Important !
Intro_menu_choice:	ds.w 1
Floppy_or_HD:	ds.b 1
First_time:	ds.b 1
Turbo_flag:	ds.b 1
	even

; ********* G A M E   D A T A *********************
Game_data:

Party_handles:	ds.b 6			; Memory handles
Portrait_handles:	ds.b 6
Chared_portrait_handles:	ds.b Portraits_per_sex*2
Chared_handle:	ds.b 1
Stationary_handle:	ds.b 1
Active_handle:	ds.b 1
Victim_handle:	ds.b 1
Ghost1_gfx_handle:	ds.b 1
Ghost2_gfx_handle:	ds.b 1
Dialogue_handle:	ds.b 1
Dialogue_text_handle:	ds.b 1
Dialogue_portrait_handle:	ds.b 1
DIAC_victim_handle:	ds.b 1
Combat_background_handle:	ds.b 1
FXGFX_handle:	ds.b 1
Object_gfx_handle:	ds.b 1
Monstergroup_handle:	ds.b 1
Monster_data_handles:	ds.b Max_monsters
Automap_handle:	ds.b 1
Automap_gfx_handle:	ds.b 1
Automap_floor_handle:	ds.b 1
Automap_buffer_handle:	ds.b 1
Mapdata_handle:	ds.b 1
Labdata_handle:				; DOUBLE !!!
Icondata_handle:	ds.b 1
Icongfx_handle:	ds.b 1
NPCgfx_handle:	ds.b 1
Transgfx_handle:	ds.b 1
Maptext_handle:	ds.b 1
Inventory_handle:	ds.b 1
Subject_handle:	ds.b 1
Casting_handle:	ds.b 1
Horizon_gfx_handle:	ds.b 1
Horizon_preshift_handle:	ds.b 1
Music_handle:	ds.b 1
Slotbase_handle:	ds.b 1
Current_event_handle:	ds.b 1
Current_event_text_handle:	ds.b 1
Sold_slots_handle:	ds.b 1
Word_list_handle:	ds.b 1
Dictionary_handle:	ds.b 1
RM_gfx_handle:	ds.b 1
Chest_data_handle:	ds.b 1
Merchant_data_handle:	ds.b 1
Zoomscreen_handle:	ds.b 1
Zoombuffer_handle:	ds.b 1
MPB_buffer_handle:	ds.b 1
Floor_buffer_handle:	ds.b 1
Ceiling_buffer_handle:	ds.b 1
MOVEP_handle:	ds.b 1
Saves_handle:	ds.b 1
Wall_handles:	ds.b Max_3D_walls
Object_handles:	ds.b Max_3D_objects
Submap_handles:	ds.b 4
Place_data_handle:	ds.b 1
Minimap_handle:	ds.b 1

AutoIcon_block:	ds.b 1			; Game flags
Handling_event:	ds.b 1
Big_brother_flag:	ds.b 1
Drugged_FX:	ds.b 1
Switch_back:	ds.b 1
Reload_map_data:	ds.b 1
Using_item:	ds.b 1
Object_gfx_load_counter:	ds.b 1		; (one byte should be enough)
Spell_multiple_target:	ds.b 1
Spell_failed:	ds.b 1
Options_mask:	ds.b 1
Transport_created:	ds.b 1
Room_rented:	ds.b 1
Automap_function:	ds.b 1
Automap_scroll_X:	ds.b 1
Automap_scroll_Y:	ds.b 1
BSReq_result:	ds.b 1
Abort_dialogue:	ds.b 1
Item_accepted:	ds.b 1
Outline_text:	ds.b 1
Joined:	ds.b 1
Left:	ds.b 1
Not_enough:	ds.b 1
Map_or_dialogue:	ds.b 1
NPC_or_member:	ds.b 1
Right_move:	ds.b 1
Chest_filled:	ds.b 1
Chest_flag:	ds.b 1
Music_flag:	ds.b 1
Dialogue_items:	ds.b 1
First_chest:	ds.b 1
No_word_selected:	ds.b 1
RM_anim_flag:	ds.b 1
Magic_object_flag:	ds.b 1
Overweight:	ds.b 1
Which_CIL:	ds.b 1
Battling:	ds.b 1
Could_not_flee:	ds.b 1
Party_invisible:	ds.b 1
Stygian:	ds.b 1
Slept:	ds.b 1
Pic_80x80_handle:	ds.b 1
Inn_flag:	ds.b 1
ObjGoldFood:	ds.b 1
Query_result:	ds.b 1
Success:	ds.b 1
Cursed_flag:	ds.b 1
Trap_found:	ds.b 1
Trap_disarmed:	ds.b 1
Chest_text_printed:	ds.b 1
Break_event:	ds.b 1
Collision:	ds.b 1
Second_ghost:	ds.b 1
Levitation_flag:	ds.b 1
Use_item_success:	ds.b 1
Empty_save_selected:	ds.b 1

Make_level_counters:	ds.b 6
Number:	ds.b 11
Dictionary_word:	ds.b 21
Dictionary_word2:	ds.b 21

Swim_status:	ds.b 1			; Map flags
Party_animate_state:	ds.b 1		; Wave direction
;Animate_party_flag:	ds.b 1
Automap_updated:	ds.b 1
Travelmode_present:	ds.b 1
Horizon_flag:	ds.b 1
NPCs_off:	ds.b 1
Float_down:	ds.b 1
Float_up:	ds.b 1
Floor_ceiling_status:	ds.b 1
Floor_ceiling_potential:	ds.b 1
Saved_map_byte:	ds.b 1
Mouse_moving:	ds.b 1
Combat_req:	ds.b 1
Show_trans:	ds.b 1
Moved:	ds.b 1
Bumped:	ds.b 1
New_move:	ds.b 1
Eye_flag:	ds.b 1
Hand_flag:	ds.b 1
Mouth_flag:	ds.b 1
Clairvoyant:	ds.b 1

Time_lock:	ds.b 1				; Used to lock time-update
New_step:	ds.b 1				; Signals a new step
	even

Ghost1_string_length:	ds.w 1		; Ghost string data
Ghost2_string_length:	ds.w 1
Current_ghost_index:	ds.w 1
Party_frame:	ds.w 1
QM_spoken_word:	ds.w 1
EHM_ptr:	ds.l 1
Scroll_bar_work:	ds.w 1

Schnism_counter:	ds.w 1

Saved_map_ptr:	ds.l 1
Current_map_byte:	ds.w 1
Selected_music:	ds.w 1
Nr_of_known_words:	ds.w 1			; Word selector
Selected_word:	ds.w 1
New_words:	ds.b 128				; New words boolean array
	even
InputNr_object:	ds.w 1
SavedSelW_prompt:	ds.w 1
Selected_save:	ds.w 1
Realtime_step:	ds.w 1			; Real-time step counter
Current_step:	ds.w 1			; Current step
Frame:	ds.w 1				; Current frame (Vbl)
Dialogue_NPC_index:	ds.w 1
Dialogue_char_nr:	ds.w 1
Current_DIAC:	ds.w 1
Current_DIAC_value:	ds.w 1
Party_status_icons:	ds.b 6			; Display variables
Shadow_data:	ds.b 6*Shadow_data_size
Shadow_update:	ds.b 6		; 0 - Portrait, 1 - Icon, 2 - Bars
Shadow_active:	ds.w 1
Previous_SIF:	ds.w 1
Previous_SIF_changes:	ds.w 1
Monster_move_delay:	ds.w 1
Current_place_type:	ds.w 1
Current_place_nr:	ds.w 1
Total_price:	ds.w 1
Charge_price:	ds.w 1			; FIX: Enchanter price per charge (#125)
Inn_destination:	ds.w 3
Current_inn_value:	ds.w 1
Victim_member:	ds.w 1
Trainer_skill:	ds.w 1

Chared_portrait:	ds.w 1
Chared_name:	ds.b 15
	ds.b 1
	even

Automap_X:	ds.w 1
Automap_Y:	ds.w 1
Width_of_automap:	ds.w 1
Height_of_automap:	ds.w 1

Automap_work_X:	ds.w 1
Automap_work_Y:	ds.w 1
Automap_pageflip_timer:	ds.w 1
Automap_page_nr:	ds.w 1

Level_factors:	ds.w Max_level

Selected_class:	ds.w 1
Selected_spell:	ds.w 1

Spell_table:	ds.w Max_spells*2
Nr_of_spells:	ds.w 1
Spell_area_type:	ds.w 1

Selected_item:	ds.w 1
ItemSelect_prompt:	ds.w 1
Object_pos_list:	ds.l 1
Casting_member:	ds.w 1
Inventory_member:	ds.w 1
Used_object_index:	ds.w 1
Casting_item_slot:	ds.w 1			; Is used for use item !
Magic_target_mask:	ds.w 1
Magic_target_slot:	ds.w 1

Char_damage:	ds.w 6
Magic_counters:	ds.b 6
	even
Sparkle_data:	ds.w (Max_sparkles*Sparkle_data_size*6)/2
AutoIcon_timer:	ds.w 1
AutoIcon_counters:	ds.w 6
Control_list_ptr_MAIN:	ds.l 1		; BUILD: Renamed (was Control_list_ptr). Unused,
					;  the one in HULL/CONTROLS.S is used.

Inter_packet:	ds.w Object_packet_size/2
Swap_packet:	ds.w Object_packet_size/2

Blink_count:	ds.w 1			; Curse blink variables
Blink_index:	ds.w 1
Blinked_colour:	ds.w 1

Slot_X:	ds.w 1
Slot_Y:	ds.w 1
Lock_X:	ds.w 1
Lock_Y:	ds.w 1
Moved_slot:	ds.w 1
Moved_prompt:	ds.w 1

Transfer_victims:	ds.w 1

Text_list:	ds.l 8
BO_list:	ds.b 12				; Battle order variables
BO_member:	ds.w 1
BO_original_pos:	ds.w 1

Current_map_type:	ds.w 1
Nr_of_modifications:	ds.w 1
Current_location_status:	ds.l 1
Kill_CA:	ds.w CA_data_size/2

Old_Xcoord:	ds.w 1			; Old coordinates
Old_Ycoord:	ds.w 1
Old_mapbufX:	ds.w 1
Old_mapbufY:	ds.w 1
Old_QuadX:	ds.w 1
Old_QuadY:	ds.w 1
Old_quadindex:	ds.w 1
Old_playerX:	ds.l 1
Old_playerY:	ds.l 1
Old_Yangle:	ds.l 1

Mapbuf_X:	ds.w 1				; Map buffer coordinates
Mapbuf_Y:	ds.w 1

Underlay_buffer:	ds.b Mapbuf_size		; Map buffers
	even
Persons_buffer:	ds.b (Mapbuf_height+1)*Mapbuf_width
	even
Trans_buffer:	ds.b (Mapbuf_height+2)*(Mapbuf_width+2)
	even
Overlay_buffer:	ds.w Mapbuf_size

Current_pal:	ds.w Pal_size
Current_sky:	ds.w C3_horizon
Combat_pal:	ds.w Pal_size

Anim_count:	ds.b 1			; Animation data
Anim_speed:	ds.b 1
	even
Anim_update:	ds.w 1
Anim_bias:	ds.w 1
Circle_anim:	ds.l 8			; Animation tables
Wave_anim:	ds.l 8
	ds.b 8				;  Direction flags
	even
Move_count:	ds.w 1			; Timing variables
Time_warp:	ds.w 1
Timer:	ds.l 1
Current_map_music:	ds.w 1
Current_NPC:	ds.w 1
Mouse_direction:	ds.w 1			; Current	direction	of mouse
First_CIL_ptr:	ds.l 1			; Pointer	to main map CIL

Event_entry_offset:	ds.l 1			; Offsets	to map data
Event_data_offset:	ds.l 1
NPC_path_base_offset:	ds.l 1
Goto_point_offset:	ds.l 1
Event_automap_offset:	ds.l 1
Slotbase_offset:	ds.l 1			; Other offsets

Width_of_map:	ds.w 1			; Map data
Height_of_map:	ds.w 1
Size_of_map:	ds.w 1
Nr_goto_points:	ds.w 1
Current_light_level:	ds.w 1		; Day-night data
New_light_level:	ds.w 1
Current_sky_level:	ds.w 1
New_sky_level:	ds.w 1
Backup_pal:	ds.w 16

CD_value:	ds.l 1				; NPC data
VNPC_data:	ds.b Max_chars*VNPC_data_size
	even

Quad_map:					; Quad maps
Quadmap_0:	ds.b Quad_mapsize
Quadmap_1:	ds.b Quad_mapsize
Quadmap_2:	ds.b Quad_mapsize
Quadmap_3:	ds.b Quad_mapsize
	even

Quad_index:	ds.w 1			; World map variables
Quad_X:	ds.w 1
Quad_Y:	ds.w 1
World_X:	ds.w 1
World_Y:	ds.w 1

Current_world_nr:	ds.w 1
Current_world:
World_width:	ds.w 1
World_height:	ds.w 1
Submap_width:	ds.w 1
Submap_height:	ds.w 1
First_world_map_nr:	ds.w 1
Start_of_dawn:	ds.w 1
Start_of_dusk:	ds.w 1

Minimap_frame:	ds.w 1			; Minimap variables
Minimap_X:	ds.w 1
Minimap_Y:	ds.w 1
Minimap_centre_X:	ds.w 1
Minimap_centre_Y:	ds.w 1
Minimap_width:	ds.w 1
Minimap_height:	ds.w 1

Moving_member:	ds.w 1
Moving_handle:	ds.b 1
Move_item_gfx_handle:	ds.b 1
Object_swap_flag:	ds.b 1
	even
Source_slot:	ds.w 1
Target_slot:	ds.w 1

Made_area:	ds.w 4
RM_anim_index:	ds.w 1
RM_anim_count:	ds.w 1
Batch:	ds.w Max_batch			; (for 3D objects !)
			; Also used as temporary palette buffer

Inventory_scroll_bar_positions:	ds.w 6
Magic_scroll_bar_positions:	ds.w 6

Current_gold:	ds.w 1
Current_food:	ds.w 1
Gold_X:	ds.w 1
Gold_Y:	ds.w 1
Food_X:	ds.w 1
Food_Y:	ds.w 1

Current_event_base:	ds.l 1
Current_event_map_nr:	ds.w 1
Current_event_X:	ds.w 1
Current_event_Y:	ds.w 1
Current_event_entry_nr:	ds.w 1
Current_event_block:	ds.w 1
Current_event_data:	ds.b Event_data_size
	even
Divide_workspace:	ds.w 6

; ---------- 3D map data --------------------------
FX_camera_height:	ds.w 1
Sky_colour:	ds.l 1
Floor_colour:	ds.l 1
Yoghurt_X:	ds.w 1
Yoghurt_Y:	ds.w 1
Object_data_offset:	ds.l 1
Wall_data_offsets:	ds.l Max_3D_walls

seethru_flag:	ds.w 1
scry:	ds.w 1
cx1:	ds.w 1
cy1:	ds.w 1
cx2:	ds.w 1
cy2:	ds.w 1

view_points:	ds.l 4
rot_points:	ds.l 16*16
proj_points:	ds.l 16*16*2
clip_tab:	ds.l 16
dminx:	ds.w 1
dminy:	ds.w 1
dmaxx:	ds.w 1
dmaxy:	ds.w 1
drawstartx:	ds.w 1
drawstarty:	ds.w 1
drawsizex:	ds.w 1
drawsizey:	ds.w 1
dsizex:	ds.w 1
dsizey:	ds.w 1
dsizex2:	ds.w 1
dsizey2:	ds.w 1

Player_X:	ds.l 1				; 16 bit fixed point !
Player_Y:	ds.l 1
Y_angle:	ds.l 1

Nr_of_groups:	ds.w 1
Nr_of_objects:	ds.w 1
Nr_of_walls:	ds.w 1
Wall_transparencies:	ds.b Max_3D_walls
	even

head_height:	ds.w 1
dface_anz:	ds.w 1
dobj_anz:	ds.w 1
xoffset:	ds.w 1
zoffset:	ds.w 1
dungeon_addr:	ds.l 1
wall_list1:	ds.w Max_visible_walls*19
wall_list2:	ds.w Max_visible_objects*6
wall_cliptab:	ds.w Max_visible_walls*2+Max_visible_objects*10
end_of_wallcliptab:
	ds.l 10				; Safety

color:	ds.w 1
Dungeon_speed:	ds.w 1

matrize:	ds.w 9
MOVEP_ptr:	ds.l 1
MPB_ptr:	ds.l 1
Labdata_ptr:	ds.l 1
Eight_bytes:	ds.l 2

; ---------- Combat screen ------------------------
Monstergroup_nr:	ds.w 1
Combat_char_index:	ds.w 1
Combat_background:	ds.w 1
Previous_active_member:	ds.w 1
Active_participant:	ds.l 1
Casting_participant:	ds.l 1

Game_data_size	EQU *-Game_data

; ********* P A R T Y   D A T A *******************
Party_data:         
Year:	ds.w 1				; Current date & time
Month:	ds.w 1
Day:	ds.w 1
Hour:	ds.w 1
Minute:	ds.w 1
Map_nr:	ds.w 1
Map_Xcoord:	ds.w 1
Map_Ycoord:	ds.w 1
View_direction:	ds.w 1

Spell_1_duration:	ds.w 1			; Light
Spell_1_data:	ds.w 1
Spell_2_duration:	ds.w 1			; Parade
Spell_2_data:	ds.w 1
Spell_3_duration:	ds.w 1			; Attack
Spell_3_data:	ds.w 1
Spell_4_duration:	ds.w 1			; Anti-magic
Spell_4_data:	ds.w 1
Spell_5_duration:	ds.w 1			; Clairvoyance
Spell_5_data:	ds.w 1
Spell_6_duration:	ds.w 1			; Automap view
Spell_6_data:	ds.w 1

Nr_members:	ds.w 1			; Is set by the program !
Active_member:	ds.w 1
Member_nrs:	ds.w 6

Time_data_year:	ds.w 1			; Relative year
Travel_mode:	ds.w 1
Special_item_flags:	ds.w 1
Internal_flags:	ds.w 1
Camp_counter:	ds.w 1			; Hours since last camp

Trans_data:	ds.b Max_transports*Trans_data_size	; Transport data

Quest:	ds.b 1024		;      Quest solved boolean array
Event:	ds.b 8192		;    Event executed boolean array
CD:	ds.b 4096		; Character removed boolean array
WD:	ds.b 128			;       Known words boolean array
Goto_points:	ds.b 32		; Known Goto-points boolean array
Chest_open:	ds.b 32		;     Opened chests boolean array
Door_open:	ds.b 32			;      Opened doors boolean array

Order:	ds.b 6			; Combat positions for each member

Party_data_size	EQU *-Party_data
Modifications:
	ds.w (Max_mods*Modif_data_size)/2+1

	SECTION	Longword_BSS,bss
zoom_ptrbuff:	ds.l Max_zoom
Wall_ptrs:	ds.l Max_3D_walls
wall_list0:	ds.l (Max_visible_walls+Max_visible_objects)*2
