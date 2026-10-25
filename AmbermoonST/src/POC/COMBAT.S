; Proof of concept : combat (Atari ST)
;
; From COMBAT/COMBAT.S, COMBAT/MONSTER_.S, COMBAT/TACTIC.S, COMBAT/APRES.S
; and PERSONS.S : the encounters (the Encounter event and the monsters on
; the map which hunt the party), the combat screen with the battlefield, the
; tactic window and the control icons, the combat rounds (moving, advancing,
; close- and long-range attacks, parading, fleeing) with the monster logic,
; and the loot and experience after the battle.
;
; The monsters are drawn like the COMOBs of the original : the battlefield is
; projected (3D coordinates) and the graphics are zoomed while drawing. The
; monster graphics are converted to the palette of the combat background when
; they are loaded (the converter has computed a palette for each background,
; with the colours of all monsters). See COMBAT2.S for the display.
;
; Not done : magic (spells of the party and of the monsters, magic items),
; the flying projectiles, the inventory during combat and the options menu.
;
; The data of a combat is kept in the memory of the map graphics (tileset and
; NPC graphics), which are loaded again after the combat.

	SECTION	Program,code

Combat_workspace	EQU	Icon_graphics		; (and NPC_graphics)
Combat_workspace_end	EQU	Icon_graphics+Max_icons*16*8+Max_NPC_graphics
Max_combat_items	EQU	(6+Max_monsters)*(9+Items_per_char)
Monster_data_size	EQU	810
Combat_bg_size	EQU	32+32+320*95/2

; The original assembler aligns the words of the participant data (vasm
; option -align), which this build does not use for the other data structures
Part_align	EQU	Part_X&1
Cpart_X	EQU	Part_X+Part_align
Cpart_Y	EQU	Part_Y+Part_align
Cpart_damage	EQU	Part_damage+Part_align
Cpart_target	EQU	Part_target+Part_align
Cpart_total_damage	EQU	Part_total_damage+Part_align
Cpart_mean_damage	EQU	Part_mean_damage+Part_align
Cpart_work	EQU	Part_work+Part_align
Cpart_COMOB_ptr	EQU	Part_COMOB_ptr+Part_align
Cpart_data_size	EQU	Participant_data_size+Part_align

; Participant data : the original participant data with pointers instead of
; memory handles
	rsset	Cpart_data_size
Cp_char:	rs.l 1			; Character data (clone for monsters)
Cp_original:	rs.l 1			; Original monster data
Cp_gfx:	rs.l 1			; Monster graphics (ST, 4 planes)
Cp_size:	rs.b 0

; COMbat OBject data
	rsreset
Co_flags:	rs.b 1			; Bit 0 = present
	rs.b 1
Co_frame:	rs.w 1
Co_3D_X:	rs.w 1
Co_3D_Y:	rs.w 1
Co_3D_Z:	rs.w 1
Co_vector_X:	rs.w 1
Co_vector_Y:	rs.w 1
Co_vector_Z:	rs.w 1
Co_disp_width:	rs.w 1			; Display size (at Z = 0)
Co_disp_height:	rs.w 1
Co_src_width:	rs.w 1			; Source size (multiple of 16)
Co_src_height:	rs.w 1
Co_gfx:	rs.l 1			; Graphics (ST, 4 planes)
Co_size:	rs.b 0

;*****************************************************************************
; [ Encounter event ]
; No registers are restored
; NOTE :
;   - From [ Encounter ] (EVENTS.S).
;*****************************************************************************
Encounter:
	lea.l	Current_event_data,a5
	sf	Could_not_flee
	move.w	Event_w6(a5),Monstergroup_nr	; Set info
	move.w	#-1,Combat_char_index
	jsr	Get_combat_background
	jsr	Combat_screen
	cmp.b	#Combat_won,Combat_result	; Won ?
	seq	Success
	rts

;*****************************************************************************
; [ Check for combat ]
; All registers are restored
; NOTE :
;   - From [ Combat_check ] (COMBAT/COMBAT.S). Called by the map.
;*****************************************************************************
Combat_check:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	Combat_req		; Combat ?
	beq	.Exit
	sf	Combat_req		; Yes
	sf	Could_not_flee
	jsr	Copy_screen_to_both
	move.w	#200,d0			; Combat requester
	jsr	Ask_yes_no
	tst.w	d0			; Wanna fight ?
	bne.s	.Yes
	moveq.l	#Active_member,d7		; No -> Feel lucky, punk ?
	jsr	Get_char_data
	move.w	ADexterity(a1),d0
	add.w	ADexterity+Magic(a1),d0
	add.w	ALuck(a1),d0
	add.w	ALuck+Magic(a1),d0
	move.w	#150,d1
	jsr	Probe
	bmi.s	.Failed
	jsr	Restore_coordinates		; Yes -> Exit
	move.w	#Monster_delay_time,Monster_move_delay	; Wait
	bra.s	.Exit
.Failed:	st	Could_not_flee		; Monster advantage !!!
.Yes:	jsr	Get_combat_background
	jsr	Combat_screen
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Get the combat background of the party's position ]
; All registers are restored
Get_combat_background:
	movem.l	d0/d1,-(sp)
	move.w	Map_Xcoord,d0
	move.w	Map_Ycoord,d1
	jsr	Get_location_status
	andi.l	#$f0000000,d0
	rol.l	#4,d0
	move.w	d0,Combat_background
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Probe ]
;   IN : d0 - Probe value (.w)
;        d1 - Probe range (.w)
;  OUT : pl - Positive probe (dice roll =< probe value)
;        mi - Negative probe (dice roll  > probe value)
; All registers are restored
; NOTE :
;   - From MAIN.S.
;*****************************************************************************
Probe:
	movem.l	d0-d2/d7,-(sp)
	tst.w	d0			; Zero or lower ?
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
.Exit:	tst.b	d7
	movem.l	(sp)+,d0-d2/d7
	rts

; [ Random value of 50% to 100% ]
;   IN : d0 - Value (.w)
;  OUT : d0 - 50% to 100% of the value (.w)
; Changed registers : d0
; NOTE :
;   - From HULL/VARIOUS.S.
Get_random_50_100:
	move.l	d1,-(sp)
	move.w	d0,d1
	jsr	Random
	mulu.w	#51,d0
	swap	d0
	addi.w	#50,d0
	mulu.w	d1,d0
	divu.w	#100,d0
	move.l	(sp)+,d1
	rts

; [ Move in one of 8 directions ]
;   IN : d0/d1 - Coordinates (.w)
;        d2 - Direction {0...7} (.w)
;  OUT : d0/d1 - New coordinates (.w)
; Changed registers : d0,d1
; NOTE :
;   - From MAIN.S.
Move_in_8_directions:
	movem.l	d2/a0,-(sp)
	lea.l	Dir8_offset,a0
	andi.w	#$0007,d2
	add.w	d2,d2
	add.w	d2,a0
	move.b	(a0)+,d2
	ext.w	d2
	add.w	d2,d0
	move.b	(a0),d2
	ext.w	d2
	add.w	d2,d1
	movem.l	(sp)+,d2/a0
	rts

;*****************************************************************************
; [ Combat screen ]
; All registers are restored
; NOTE :
;   - From the combat module (COMBAT/COMBAT.S).
;*****************************************************************************
Combat_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	st	Battling
	jsr	Init_chunky_table
	jsr	Combat_init
	tst.b	Combat_aborted		; Not enough memory ?
	bne	.Abort
	jsr	Build_combat_screen
	jsr	Monsters_appear
	tst.b 	Could_not_flee		; Could not flee ?
	beq.s	.Loop
	sf 	Could_not_flee		; They got you !
	move.w	#203,d0
	jsr	Combat_prompt
	jsr	Do_combat_round		; Fight !
; ---------- Combat input loop --------------------
.Loop:	tst.b	Combat_result		; End of combat ?
	bne	.End
	jsr	Update_combat_display
	jsr	Read_key
	cmp.w	#$3b,d0			; F1...F6 ?
	bmi.s	.No_key
	cmp.w	#$40+1,d0
	bpl.s	.No_key
	subi.w	#$3b-1,d0
	move.w	d0,d7
	jsr	Activate_member
	bra.s	.Loop
.No_key:	jsr	Read_mouse_clicks
	move.w	d0,d6
	beq.s	.Loop
	btst	#Left_pressed,d6		; Left button ?
	beq.s	.Loop
	move.w	Mouse_Y,d1
	cmp.w	#Middle_Y+1,d1		; Status block ?
	bpl.s	.No_status
	move.w	Mouse_X,d0
	subi.w	#16,d0
	bmi.s	.Loop
	ext.l	d0
	divu.w	#48,d0
	cmp.w	#6,d0
	bpl.s	.Loop
	addq.w	#1,d0
	move.w	d0,d7
	jsr	Activate_member
	bra.s	.Loop
.No_status:	jsr	Get_tactic_index		; Tactic window ?
	tst.w	d0
	bmi.s	.No_tactic
	jsr	Tactical_member_left
	bra	.Loop
.No_tactic:	jsr	Combat_icon_clicked
	bra	.Loop
; ---------- End of combat ------------------------
.End:	jsr	Combat_exit
	bra.s	.Exit
.Abort:	sf	Battling
	jsr	Reload_map_graphics		; (data was overwritten)
	jsr	Back_to_map
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Initialize combat ]
; All registers are restored
; NOTE :
;   - From [ Combat_ModInit ].
;*****************************************************************************
Combat_init:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Combat_data,a0		; Clear combat data
	move.w	#(Combat_data_end-Combat_data)/2-1,d7
.Clear:	clr.w	(a0)+
	dbra	d7,.Clear
	move.l	#Combat_workspace,Combat_free	; Reset workspace
	jsr	Init_COMOBs
; ---------- Load combat data ---------------------
	move.w	Combat_background,d0	; Get background info
	lsl.w	#2,d0
	lea.l	Combat_bg_table,a0
	add.w	d0,a0
	moveq.l	#0,d1			; Get palette (time of day)
	move.w	Hour,d2
	lea.l	Time_table,a1
	move.b	0(a1,d2.w),d1
	moveq.l	#0,d0			; Load background "CB<i>_<p>"
	move.b	(a0),d0
	move.b	1(a0,d1.w),d1
	andi.w	#$00ff,d1
	move.l	#Combat_bg_size,d2
	lea.l	CB_name,a0
	jsr	Load_combat_file
	bmi	.Exit
	move.l	a1,Combat_bg_ptr
	lea.l	TACTIC_name,a0		; Load tactical icons
	moveq.l	#-1,d0
	moveq.l	#-1,d1
	move.l	#36*2*8+35*14*8,d2
	jsr	Load_combat_file
	bmi	.Exit
	move.l	a1,Tactic_icons_ptr
	lea.l	COMBFX_name,a0		; Load combat effects
	moveq.l	#-1,d0
	moveq.l	#-1,d1
	move.l	#31190,d2
	jsr	Load_combat_file
	bmi	.Exit
	move.l	a1,a0			; Convert
	sub.l	a4,a4			; (no recolouring)
	jsr	Convert_combat_gfx
	move.l	a1,Combat_FX_ptr
	jsr	Load_monsters		; Load monsters
	tst.b	Combat_aborted
	bne	.Exit
	lea.l	Combat_files,a0		; Load layout
	jsr	Load_files
; ---------- Fill combat array (party) ------------
	lea.l	Combat_party,a0
	lea.l	Party_positions,a3
	lea.l	Combat_matrix,a4
	moveq.l	#1,d7
.Loop:	jsr	Get_char_data
	move.w	Body_conditions(a1),d0	; Able to fight ?
	andi.w	#Fight_mask,d0
	bne.s	.Next
	move.l	a1,Cp_char(a0)		; Set data
	move.b	#1,Part_type(a0)
	move.b	d7,Part_nr(a0)
	move.b	Char_class(a1),Part_icon_nr(a0)
	lea.l	Battle_order,a2		; Get battle order position
	moveq.l	#0,d2
	move.b	-1(a2,d7.w),d2
	add.w	d2,d2			; Get tactic coordinates
	moveq.l	#0,d0
	move.b	0(a3,d2.w),d0
	moveq.l	#0,d1
	move.b	1(a3,d2.w),d1
	move.w	d0,Cpart_X(a0)		; Store
	move.w	d1,Cpart_Y(a0)
	mulu.w	#6,d1			; Insert participant
	add.w	d1,d0			;  in matrix
	lsl.w	#2,d0
	move.l	a0,0(a4,d0.w)
.Next:	lea.l	Cp_size(a0),a0		; Next member
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	move.w	#Active_member,d7		; Activate member
	jsr	Activate_member
	beq.s	.Ok
	jsr	Select_new_active_member
.Ok:	jsr	Update_control_status	; Set control status
	jsr	Reset_combat		; Clear actions & targets
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

Time_table:
	dc.b 2,2,2,2,2,1			;  0 - 5
	dc.b 1,0,0,0,0,0			;  6 - 11
	dc.b 0,0,0,0,0,0			; 12 - 17
	dc.b 0,1,1,2,2,2			; 18 - 23
	even

; [ Load the monsters of the monster group ]
; All registers are restored
Load_monsters:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Monster_groups,a2		; Get monster group
	move.w	Monstergroup_nr,d0
	subq.w	#1,d0
	mulu.w	#Max_monsters*2,d0
	add.l	d0,a2
	lea.l	Combat_monsters,a0
	lea.l	Monster_positions,a3
	lea.l	Combat_matrix,a4
	moveq.l	#1,d6
	moveq.l	#Max_monsters-1,d7
.Loop:	move.w	(a2),d0			; Anything there ?
	beq	.Next
	move.b	#2,Part_type(a0)		; Set data
	move.b	d6,Part_nr(a0)
	move.w	d0,Cpart_work(a0)
	jsr	Get_monster_data		; Load original data
	bmi	.Exit
	move.l	a1,Cp_original(a0)
	jsr	Clone_monster_data		; Make a clone
	bmi	.Exit
	move.b	#%00001100,Part_flags(a0)	; Long- and short-range
	moveq.l	#0,d0			; Tactical icon
	move.b	Monster_picture_load_nr(a1),d0
	addi.w	#10-1,d0
	move.b	d0,Part_icon_nr(a0)
	jsr	Get_monster_graphics	; Load & convert graphics
	bmi	.Exit
	moveq.l	#0,d0			; Get tactic coordinates
	move.b	(a3),d0
	moveq.l	#0,d1
	move.b	1(a3),d1
	move.w	d0,Cpart_X(a0)		; Store
	move.w	d1,Cpart_Y(a0)
	mulu.w	#6,d1			; Insert participant
	add.w	d1,d0			;  in matrix
	lsl.w	#2,d0
	move.l	a0,0(a4,d0.w)
	jsr	Init_monster_COMOB
	addq.w	#1,Nr_monsters
	lea.l	Cp_size(a0),a0		; Next participant
	addq.w	#1,d6
.Next:	addq.l	#2,a2			; Next monster
	addq.l	#2,a3
	dbra	d7,.Loop
	move.w	Nr_monsters,Remaining_monsters
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Get the original data of a monster ]
;   IN : d0 - Monster number (.w)
;  OUT : a1 - Pointer to data (.l)
;        mi - Error
; Changed registers : a1
; NOTE :
;   - Each monster is loaded only once.
Get_monster_data:
	movem.l	d0-d2/d7/a0/a2,-(sp)
	lea.l	Loaded_monsters,a2		; Already loaded ?
	moveq.l	#Max_monsters-1,d7
.Loop:	tst.l	2(a2)
	beq.s	.Load
	cmp.w	(a2),d0
	beq.s	.Found
	addq.l	#6,a2
	dbra	d7,.Loop
.Found:	move.l	2(a2),a1
	moveq.l	#0,d0
	bra.s	.Exit
.Load:	move.w	d0,(a2)			; No -> load "MC<n>"
	moveq.l	#-1,d1
	move.l	#Monster_data_size,d2
	lea.l	MC_name,a0
	jsr	Load_combat_file
	bmi.s	.Exit
	move.l	a1,2(a2)
.Exit:	movem.l	(sp)+,d0-d2/d7/a0/a2
	rts

; [ Create a clone of the monster's character data ]
;   IN : a0 - Pointer to participant data (.l)
;        a1 - Pointer to original data (.l)
;  OUT : a1 - Pointer to clone (.l)
;        mi - Error
; Changed registers : a1
; NOTE :
;   - From [ Clone_monster_data ] : the maxima of the skills, attributes, LP
;     and SP are entered and the normal values are randomized by -5% to +5%.
Clone_monster_data:
	movem.l	d0-d2/d7/a2/a3,-(sp)
	move.l	#Clone_data_size,d0		; Make clone
	jsr	Allocate_combat_memory
	bmi	.Exit
	move.l	a1,a3
	move.l	Cp_original(a0),a2
	move.w	#Clone_data_size/2-1,d7
.Copy:	move.w	(a2)+,(a3)+
	dbra	d7,.Copy
	move.l	a1,Cp_char(a0)
	lea.l	Attributes(a1),a2		; Enter attribute maxima
	moveq.l	#Max_attrs-1,d7
.Loop1:	move.w	(a2),Maximum(a2)
	addq.l	#Attr_data_size,a2
	dbra	d7,.Loop1
	lea.l	Skills(a1),a2		; Enter skill maxima
	moveq.l	#Max_skills-1,d7
.Loop2:	move.w	(a2),Maximum(a2)
	addq.l	#Skill_data_size,a2
	dbra	d7,.Loop2
	move.w	Life_points(a1),Life_points+Maximum(a1)	; LP & PP
	move.w	Power_points(a1),Power_points+Maximum(a1)
	lea.l	Attributes(a1),a2		; Randomize attributes
	moveq.l	#Max_attrs-1,d7
.Loop3:	jsr	.Randomize
	addq.l	#Attr_data_size,a2
	dbra	d7,.Loop3
	lea.l	Skills(a1),a2		; Randomize skills
	moveq.l	#Max_skills-1,d7
.Loop4:	jsr	.Randomize
	addq.l	#Skill_data_size,a2
	dbra	d7,.Loop4
	lea.l	Life_points(a1),a2		; LP & PP
	jsr	.Randomize2
	lea.l	Power_points(a1),a2
	jsr	.Randomize2
	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d0-d2/d7/a2/a3
	rts

; Add -5% to +5% to (a2) (maximum in Maximum(a2))
.Randomize:	jsr	Random			; Get -5% to +5%
	mulu.w	#10,d0
	swap	d0
	subq.w	#5,d0
	muls.w	(a2),d0
	divs.w	#100,d0
	add.w	(a2),d0			; Add to normal
	bra.s	.Clip
.Randomize2:
	jsr	Random			; Get 95% to 105%
	mulu.w	#10,d0
	swap	d0
	addi.w	#100-5,d0
	muls.w	(a2),d0
	divs.w	#100,d0
.Clip:	tst.w	d0			; Below zero ?
	bpl.s	.Below_OK
	moveq.l	#0,d0
	bra.s	.Store
.Below_OK:	cmp.w	Maximum(a2),d0		; Above maximum ?
	bmi.s	.Store
	move.w	Maximum(a2),d0
.Store:	move.w	d0,(a2)
	rts

; [ Get the graphics of a monster ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : mi - Error
; All registers are restored
; NOTE :
;   - Like [ Recolour_monsters ] : the graphics are converted for each
;     combination of graphics and recolouring table only once.
Get_monster_graphics:
	movem.l	d0-d7/a0-a5,-(sp)
	move.l	a0,a5
	move.l	Cp_original(a5),a3
	moveq.l	#0,d4			; Get graphics number
	move.b	Monster_picture_load_nr(a3),d4
	lea.l	Loaded_graphics,a2		; Already converted ?
	moveq.l	#Max_monsters-1,d7
.Loop:	tst.l	2(a2)
	beq.s	.Load
	cmp.w	(a2),d4			; Same graphics ?
	bne.s	.Next
	move.l	6(a2),a1			; Same recolouring ?
	lea.l	Amiga_recol(a1),a1
	lea.l	Amiga_recol(a3),a4
	moveq.l	#32-1,d6
.Cmp:	cmpm.b	(a1)+,(a4)+
	bne.s	.Next
	dbra	d6,.Cmp
	move.l	2(a2),Cp_gfx(a5)		; Yes
	moveq.l	#0,d0
	bra.s	.Exit
.Next:	lea.l	10(a2),a2
	dbra	d7,.Loop
.Load:	move.w	d4,(a2)			; No -> load "MG<n>"
	move.l	a3,6(a2)
	move.w	d4,d0
	moveq.l	#-1,d1
	move.l	Combat_free,d2		; (all free memory)
	neg.l	d2
	addi.l	#Combat_workspace_end,d2
	lea.l	MG_name,a0
	jsr	Load_combat_file
	bmi.s	.Exit
	move.l	a1,a0			; Convert
	lea.l	Amiga_recol(a3),a4
	jsr	Convert_combat_gfx
	move.l	a1,2(a2)
	move.l	a1,Cp_gfx(a5)
	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d0-d7/a0-a5
	rts

; [ Convert 5 bit graphics (Amiga, interleaved lines) to the ST ]
;   IN : d0 - Size of the graphics (multiple of 10) (.l)
;        a0 - Pointer to the graphics, which was allocated last (.l)
;        a4 - Pointer to recolouring table (32 bytes) / 0 (.l)
;  OUT : a1 - Pointer to the converted graphics (= a0) (.l)
; All registers are restored
; NOTE :
;   - Colour 0 stays 0 (transparent), the other colours are translated with
;     the lookup table of the combat background, which never gives 0. The
;     memory which is not needed anymore is freed.
Convert_combat_gfx:
	movem.l	d0-d7/a0/a2-a4,-(sp)
	move.l	Combat_bg_ptr,a2		; Make lookup table
	lea.l	32(a2),a2
	lea.l	Convert_LUT,a3
	moveq.l	#0,d1
.LUT:	move.w	d1,d2
	move.l	a4,d3			; Recolour ?
	beq.s	.No_recol
	move.b	0(a4,d1.w),d2
	andi.w	#31,d2
.No_recol:	move.b	0(a2,d2.w),d2
	tst.w	d1			; (0 stays transparent)
	bne.s	.Not0
	moveq.l	#0,d2
.Not0:	move.b	d2,(a3)+
	addq.w	#1,d1
	cmp.w	#32,d1
	bmi.s	.LUT
	move.l	a0,a1			; Convert (in place)
	move.l	a0,a2
	divu.w	#10,d0			; Number of 16 pixel groups
	move.w	d0,d5
	lea.l	Convert_LUT,a3
	bra.s	.Entry
.Loop:	movem.w	(a2)+,d0-d4		; Get 5 planes
	lea.l	Convert_pixels,a4		; Get 16 colours
	moveq.l	#16-1,d6
.Pixel:	moveq.l	#0,d7
	add.w	d4,d4
	addx.b	d7,d7
	add.w	d3,d3
	addx.b	d7,d7
	add.w	d2,d2
	addx.b	d7,d7
	add.w	d1,d1
	addx.b	d7,d7
	add.w	d0,d0
	addx.b	d7,d7
	move.b	0(a3,d7.w),(a4)+
	dbra	d6,.Pixel
	lea.l	Convert_pixels,a4		; Make 4 planes
	moveq.l	#16-1,d6
.Plane:	move.b	(a4)+,d7
	lsr.b	#1,d7
	addx.w	d0,d0
	lsr.b	#1,d7
	addx.w	d1,d1
	lsr.b	#1,d7
	addx.w	d2,d2
	lsr.b	#1,d7
	addx.w	d3,d3
	dbra	d6,.Plane
	move.w	d0,(a1)+			; Store
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
.Entry:	dbra	d5,.Loop
	move.l	a1,Combat_free		; Free the rest
	move.l	a0,a1
	movem.l	(sp)+,d0-d7/a0/a2-a4
	rts

; [ Load a file into the combat workspace ]
;   IN : d0 - Number / -1 (.w)
;        d1 - Second number (after "_") / -1 (.w)
;        d2 - Maximum length (.l)
;        a0 - Pointer to the name prefix (.l)
;  OUT : d0 - Number of bytes read (.l)
;        a1 - Pointer to the data (.l)
;        mi - Error ([ Combat_aborted ] is set)
; Changed registers : d0,a1
Load_combat_file:
	movem.l	d1-d3/a0/a2,-(sp)
	move.w	d0,d3
	lea.l	Combat_file_name+5,a2	; Make name
.Copy:	move.b	(a0)+,(a2)+
	bne.s	.Copy
	subq.l	#1,a2
	tst.w	d3
	bmi.s	.Ext
	move.w	d3,d0
	jsr	.Number
	tst.w	d1
	bmi.s	.Ext
	move.b	#'_',(a2)+
	move.w	d1,d0
	jsr	.Number
.Ext:	move.b	#'.',(a2)+
	move.b	#'B',(a2)+
	move.b	#'I',(a2)+
	move.b	#'N',(a2)+
	clr.b	(a2)
	move.l	Combat_free,a1		; Enough memory ?
	move.l	a1,d0
	add.l	d2,d0
	cmp.l	#Combat_workspace_end,d0
	bhi.s	.Error
	lea.l	Combat_file_name,a0		; Load
	move.l	d2,d0
	jsr	Load_file
	tst.l	d0
	bmi.s	.Error
	move.l	d0,d1			; Allocate
	addq.l	#1,d1
	andi.w	#-2,d1
	add.l	d1,Combat_free
	tst.l	d0
	bra.s	.Exit
.Error:	st	Combat_aborted
	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d1-d3/a0/a2
	rts

; Put a decimal number d0 at a2
.Number:	movem.l	d0/d1/a0,-(sp)
	lea.l	Number,a0
	andi.l	#$ffff,d0
	moveq.l	#0,d1			; Count digits
.Loop:	divu.w	#10,d0
	swap	d0
	addi.b	#'0',d0
	move.b	d0,(a0)+
	clr.w	d0
	swap	d0
	addq.w	#1,d1
	tst.w	d0
	bne.s	.Loop
	subq.w	#1,d1
.Put:	move.b	-(a0),(a2)+
	dbra	d1,.Put
	movem.l	(sp)+,d0/d1/a0
	rts

; [ Allocate memory in the combat workspace ]
;   IN : d0 - Size (.l)
;  OUT : a1 - Pointer to memory (.l)
;        mi - Error
; Changed registers : a1
Allocate_combat_memory:
	move.l	d0,-(sp)
	move.l	Combat_free,a1
	addq.l	#1,d0
	andi.w	#-2,d0
	add.l	a1,d0
	cmp.l	#Combat_workspace_end,d0
	bhi.s	.Error
	move.l	d0,Combat_free
	moveq.l	#0,d0
	bra.s	.Exit
.Error:	st	Combat_aborted
	moveq.l	#-1,d0
.Exit:	tst.l	d0
	movem.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Build the combat screen ]
; All registers are restored
; NOTE :
;   - From [ Combat_DisInit ].
;*****************************************************************************
Build_combat_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	clr.l	Ghost_text
	move.l	#Combat_PA,Print_area_ptr
	move.w	#4,Inventory_mode		; (no objects under the mouse)
	move.l	Combat_bg_ptr,a0		; Install palettes
	lea.l	Combat_palette,a1
	moveq.l	#64/4-1,d7
.Pal:	move.l	(a0)+,(a1)+
	dbra	d7,.Pal
	lea.l	Combat_RL,a0
	jsr	Set_raster_list
	jsr	Display_status_block
	moveq.l	#1,d7			; (with the bars)
.Bars:	jsr	Force_status_update
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Bars
	moveq.l	#0,d0			; Show layout
	moveq.l	#Middle_Y+1,d1
	moveq.l	#20,d6
	move.w	#199-Middle_Y,d7
	lea.l	Extra_layout,a0
	jsr	Put_unmasked_block
	move.w	#Tactic_X,d0		; Save tactic window
	move.w	#Tactic_Y-1,d1
	moveq.l	#6,d6
	moveq.l	#5*Tactic_cell_height+2,d7
	lea.l	Tactic_background,a0
	jsr	Get_block
	jsr	Combat_CIL_evaluate		; Show control icons
	jsr	Display_combat_status_icons
	jsr	Draw_combat_screen
	jsr	Draw_tactic_window
	jsr	Copy_screen_to_both
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Let the monsters appear ]
; All registers are restored
Monsters_appear:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	Combat_monsters,a0		; For all monsters
	move.w	Nr_monsters,d7
	bra.s	.Entry
.Loop:	move.l	Cp_original(a0),a1		; Appear animation ?
	tst.b	Anim_frame+Appear_anim-1(a1)
	beq.s	.Next
	Set_anim	Appear_anim,a0		; Yes -> Appear !
	jsr	Wait_4_animation
	moveq.l	#0,d0			; Get default frame
	move.b	Anim_dat(a1),d0
	move.b	d0,Part_default_frame(a0)	; Store
	move.l	Cpart_COMOB_ptr(a0),a1
	move.w	d0,Co_frame(a1)
.Next:	lea.l	Cp_size(a0),a0		; Next monster
.Entry:	dbra	d7,.Loop
	st	Random_animating		; Start random animations
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Activate a party member in combat ]
;   IN : d7 - Member number {1...6} (.w)
;  OUT : eq - Activated, ne - Not possible
; All registers are restored
; NOTE :
;   - Like [ Activate_member ] (MAIN.S) : the active member gets the orders
;     in the combat. (The leader of the proof of concept is always member 1.)
;*****************************************************************************
Activate_member:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	Combat_party,a0		; Get participant
	move.w	d7,d0
	subq.w	#1,d0
	mulu.w	#Cp_size,d0
	add.l	d0,a0
	tst.b	Part_type(a0)		; In combat ?
	beq.s	.No
	move.l	Cp_char(a0),a1		; Capable ?
	move.w	Body_conditions(a1),d0
	andi.w	#Active_mask,d0
	bne.s	.No
	move.w	d7,Combat_active		; Yes
	move.l	a0,Active_participant
	jsr	Combat_CIL_evaluate
	moveq.l	#0,d0
	bra.s	.Exit
.No:	moveq.l	#-1,d0
.Exit:	tst.w	d0
	movem.l	(sp)+,d0/d7/a0/a1
	rts

; [ Select a new active member in combat ]
; All registers are restored
Select_new_active_member:
	move.l	d7,-(sp)
	moveq.l	#1,d7
.Loop:	jsr	Activate_member
	beq.s	.Exit
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
.Exit:	move.l	(sp)+,d7
	rts

;*****************************************************************************
; [ Update participant control status ]
; All registers are restored
; NOTE :
;   - From COMBAT/COMBAT.S.
;*****************************************************************************
Update_control_status:
	movem.l	d0/d1/d7/a0-a2,-(sp)
	lea.l	Combat_matrix,a1		; Search matrix
	moveq.l	#30-1,d7
.Loop:	tst.l	(a1)			; Anything there ?
	beq	.Next
	move.l	(a1),a0
	move.l	Cp_char(a0),a2		; Get conditions
	move.w	Body_conditions(a2),d0
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
	move.w	#-1,Cpart_target(a0)
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
	move.w	#-1,Cpart_target(a0)
	subq.w	#1,Remaining_members	; Count down
	bra.s	.Next
.Control2:	bclr	#Part_uncontrol,Part_flags(a0)	; Yes -> News ?
	beq.s	.Next
	addq.w	#1,Remaining_members	; Yes -> Count back up
.Next:	addq.l	#4,a1			; Next matrix entry
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d1/d7/a0-a2
	rts

; [ Reset combat actions & targets ]
; All registers are restored
Reset_combat:
	movem.l	d7/a0/a1,-(sp)
	lea.l	Combat_matrix,a0
	moveq.l	#30-1,d7
.Loop:	tst.l	(a0)			; Anything there ?
	beq.s	.Next
	move.l	(a0),a1			; Clear data
	clr.b	Part_action(a1)
	move.w	#-1,Cpart_target(a1)
.Next:	addq.l	#4,a0			; Next entry
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0/a1
	rts

; [ Remove participant ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are restored
Remove_participant:
	movem.l	d0/a1,-(sp)
	lea.l	Combat_matrix,a1		; Remove participant
	move.w	Cpart_Y(a0),d0
	mulu.w	#6,d0
	add.w	Cpart_X(a0),d0
	lsl.w	#2,d0
	cmp.l	0(a1,d0.w),a0		; (still there ?)
	bne.s	.No
	clr.l	0(a1,d0.w)
.No:	clr.b	Part_type(a0)		; Deactivate
	clr.b	Part_action(a0)		; Reset action (!)
	move.w	#-1,Cpart_target(a0)
	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Combat control icons ]
;*****************************************************************************
; [ Evaluate & show the combat control icons ]
; All registers are restored
; NOTE :
;   - From [ Combat_CIL_evaluate ].
Combat_CIL_evaluate:
	movem.l	d0/d1/d7/a0-a2,-(sp)
	lea.l	Combat_CIL,a1		; Copy icons
	lea.l	Combat_CIL_work,a0
	moveq.l	#9-1,d7
.Copy:	move.w	(a1)+,(a0)+
	dbra	d7,.Copy
	lea.l	Combat_CIL_work,a0
	move.l	Active_participant,a1
	move.l	a1,d0
	beq	.Show
	move.l	Cp_char(a1),a2
	move.w	Body_conditions(a2),d7
; ---------- Flight possible ? --------------------
	cmp.w	#4,Cpart_Y(a1)		; On bottom row ?
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
	beq.s	.Ok5
	bset	#7,14(a0)			; Disable {Parade}
; ---------- Advance possible ? -------------------
.Ok5:	lea.l	Combat_matrix+2*6*4,a1	; Monsters in front rows ?
	moveq.l	#6*2-1,d7
.Loop1:	tst.l	(a1)			; Anything ?
	beq.s	.Next1
	move.l	(a1),a2			; Monster ?
	cmp.b	#2,Part_type(a2)
	beq.s	.Off4
.Next1:	addq.l	#4,a1			; Next
	dbra	d7,.Loop1
	bra.s	.Show
.Off4:	bset	#7,8(a0)			; Disable {Advance}
.Show:	jsr	Display_CIL
	movem.l	(sp)+,d0/d1/d7/a0-a2
	rts

; [ A control icon was clicked ]
; All registers are restored
Combat_icon_clicked:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Control_icon_number		; Control icon ?
	subq.w	#1,d0
	bmi.s	.Exit
	lea.l	Combat_CIL_work,a0		; Possible ?
	move.w	d0,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d1
	beq.s	.Exit
	bmi.s	.Exit
	jsr	Press_combat_icon		; Feedback
	add.w	d0,d0			; Execute
	add.w	d0,d0
	move.l	.Ptrs(pc,d0.w),d0
	beq.s	.Exit
	move.l	d0,a0
	jsr	(a0)
	tst.b	Combat_result
	bne.s	.Exit
	jsr	Combat_CIL_evaluate
	jsr	Display_combat_status_icons
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

.Ptrs:	dc.l Flee_combat,0,OK_combat
	dc.l Move_combat,Advance,0
	dc.l Attack,Parade,0

; [ Show a control icon pressed ]
;   IN : d0 - Icon index {0...8} (.w)
; All registers are restored
Press_combat_icon:
	movem.l	d0-d3/a0,-(sp)
	lea.l	Combat_CIL_work,a0
	move.w	d0,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d3
	ext.l	d0
	divu.w	#3,d0
	move.w	d0,d1			; Y
	mulu.w	#17,d1
	addi.w	#143,d1
	swap	d0			; X
	lsl.w	#5,d0
	addi.w	#208,d0
	jsr	Display_down_button
	jsr	Copy_screen_to_both
.Wait:	jsr	Switch_screens
	btst	#Left_pressed,Mouse_buttons
	bne.s	.Wait
	jsr	Display_up_button
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d3/a0
	rts

; ********** Combat screen - Flee *****************
Flee_combat:
	move.l	Active_participant,a0
	move.w	#-1,Cpart_target(a0)
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
	jmp	Combat_prompt
.Yes:	move.l	d0,Tactic_mask		; Store mask
	move.w	#201,d0			; Move where ?
	moveq.l	#1,d1			; (show moves)
	jsr	Select_tactic
	bmi.s	.Exit			; Anywhere ?
	move.w	d0,Cpart_target(a1)		; Yes -> Store
	move.b	#Move_action,Part_action(a1)
.Exit:	rts

; ********** Combat screen - Advance **************
Advance:
	move.w	#233,d0			; "The party advances !"
	jsr	Combat_prompt
	lea.l	Combat_matrix,a0		; Set vectors
	moveq.l	#6*2-1,d7
.Loop1:	tst.l	(a0)
	beq.s	.Next1
	move.l	(a0),a1
	move.l	Cpart_COMOB_ptr(a1),a1
	move.w	#-(128/Move_steps),Co_vector_Z(a1)
.Next1:	addq.l	#4,a0
	dbra	d7,.Loop1
	moveq.l	#Move_steps-1,d7		; Show movement
.Loop2:	jsr	Update_combat_screen
	dbra	d7,.Loop2
	lea.l	Combat_matrix,a0		; Clear vectors
	moveq.l	#6*2-1,d7
.Loop3:	tst.l	(a0)
	beq.s	.Next3
	move.l	(a0),a1
	move.l	Cpart_COMOB_ptr(a1),a1
	clr.w	Co_vector_Z(a1)
.Next3:	addq.l	#4,a0
	dbra	d7,.Loop3
	lea.l	Combat_matrix+(6*2-1)*4,a0	; Move all monsters down
	moveq.l	#6*2-1,d7
.Loop4:	tst.l	(a0)
	beq.s	.Next4
	move.l	(a0),a1
	clr.l	(a0)
	addq.w	#1,Cpart_Y(a1)
	move.l	a1,6*4(a0)
.Next4:	subq.l	#4,a0
	dbra	d7,.Loop4
	rts

; ********** Combat screen - Attack ***************
Attack:
	move.l	Active_participant,a1
	move.l	Cp_char(a1),a0
	jsr	Check_attack_weapon		; Long or close range ?
	bmi.s	.Exit
	beq.s	.Close
	move.l	a1,a0			; Long range
	jsr	Get_longrange_targets
	move.l	d0,Tactic_mask
	moveq.l	#Long_range_action,d2
	bra.s	.Select
.Close:	move.l	a1,a0			; Close range
	jsr	Get_closerange_targets	; Any targets ?
	tst.l	d0
	bne.s	.Yes
	move.w	#206,d0			; Out of reach !
	jmp	Combat_prompt
.Yes:	move.l	d0,Tactic_mask
	moveq.l	#Close_range_action,d2
.Select:	move.w	#205,d0			; Attack what ?
	moveq.l	#2,d1			; (show attacks)
	jsr	Select_tactic
	bmi.s	.Exit			; Anywhere ?
	move.w	d0,Cpart_target(a1)		; Yes -> Store
	move.b	d2,Part_action(a1)
.Exit:	rts

; [ Check the weapon of a party member ]
;   IN : a0 - Pointer to character data (.l)
;  OUT : d0 - 0 = close range, 1 = long range, -1 = no ammunition (.w)
; Changed registers : d0
Check_attack_weapon:
	movem.l	d1/a1/a2,-(sp)
	move.w	Char_inventory+Right_hand_slot+Object_index(a0),d0
	beq.s	.Close			; Nothing ? -> Close range
	jsr	Get_item_data
	cmp.b	#Longrange_itemtype,Item_type(a1)	; Long range ?
	bne.s	.Close
	move.b	Ammo_use_ID(a1),d1		; Get required ammo ID
	beq.s	.Long			; (if any!)
	move.w	Char_inventory+Left_hand_slot+Object_index(a0),d0
	beq.s	.No_ammo
	jsr	Get_item_data
	cmp.b	Ammo_ID(a1),d1		; Is correct ?
	beq.s	.Long
.No_ammo:	move.w	#204,d0			; No ammo !
	jsr	Combat_prompt
	moveq.l	#-1,d0
	bra.s	.Exit
.Long:	moveq.l	#1,d0
	bra.s	.Exit
.Close:	moveq.l	#0,d0
.Exit:	tst.w	d0
	movem.l	(sp)+,d1/a1/a2
	rts

; ********** Combat screen - Parade ***************
Parade:
	move.l	Active_participant,a0
	move.w	#-1,Cpart_target(a0)
	move.b	#Parade_action,Part_action(a0)
	rts

; ********** Combat screen - OK *******************
OK_combat:
	jmp	Do_combat_round

;*****************************************************************************
; [ Select active character in tactical window ]
; NOTE :
;   - From [ Tactical_member_left ].
;*****************************************************************************
Tactical_member_left:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Get_tactic_index		; Get index
	tst.w	d0
	bmi	.Exit
	move.w	d0,d4
	lea.l	Combat_matrix,a0		; Look in matrix
	lsl.w	#2,d0
	add.w	d0,a0
	tst.l	(a0)			; Anything there ?
	bne	.Full
; ---------- Check if movement is possible --------
	cmp.w	#18,d4			; In bottom two rows ?
	bmi	.Done
	move.l	Active_participant,a0
	move.l	Cp_char(a0),a1		; Moving possible ?
	move.w	Body_conditions(a1),d0
	andi.w	#Move_mask,d0
	beq.s	.Can_move
	move.w	#218,d0			; "Can't move"
	jsr	Combat_prompt
	bra	.Done
.Can_move:	jsr	Get_occupied_targets	; Get occupied targets
	move.l	d0,d1
	btst	d4,d1			; Occupied ?
	beq.s	.Free
	move.w	#221,d0			; "Occupied"
	jsr	Combat_prompt
	bra	.Done
.Free:	jsr	Check_movement_range	; Find possible targets
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	btst	d4,d0			; Can be reached ?
	beq.s	.Too_far
	move.w	d4,Cpart_target(a0)		; Yes -> Store
	move.b	#Move_action,Part_action(a0)
	bra	.Done
.Too_far:	move.w	#219,d0			; "Can't reach"
	jsr	Combat_prompt
	bra	.Done
.Full:	move.l	(a0),a0			; Is party ?
	cmp.b	#1,Part_type(a0)
	beq	.Party
; ---------- Check if attack is possible ----------
	move.l	Active_participant,a2
	move.l	Cp_char(a2),a1		; Attacking possible ?
	move.w	Body_conditions(a1),d0
	move.w	Damage(a1),d1
	add.w	Damage_magic(a1),d1
	andi.w	#Attack_mask,d0
	bne.s	.Cant
	tst.w	d1
	bne.s	.Can_attack
.Cant:	move.w	#220,d0			; "Can't attack"
	jsr	Combat_prompt
	bra	.Done
.Can_attack:
	move.l	a1,a0			; Check weapon
	jsr	Check_attack_weapon
	bmi.s	.Done
	beq.s	.Close
	move.w	d4,Cpart_target(a2)		; Long range
	move.b	#Long_range_action,Part_action(a2)
	bra.s	.Done
.Close:	move.l	a2,a0			; Get targets
	jsr	Get_closerange_targets
	btst	d4,d0			; Can be reached ?
	beq	.Too_far
	move.w	d4,Cpart_target(a2)		; Yes -> Store
	move.b	#Close_range_action,Part_action(a2)
	bra.s	.Done
; ---------- Try to make active -------------------
.Party:	moveq.l	#0,d7			; Get member number
	move.b	Part_nr(a0),d7
	jsr	Activate_member		; Make active
.Done:	jsr	Combat_CIL_evaluate
	jsr	Display_combat_status_icons
	jsr	Copy_screen_to_both
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Do combat round ]
; All registers are restored
; NOTE :
;   - From [ Do_combat_round ].
;*****************************************************************************
Do_combat_round:
	movem.l	d0-d7/a0-a6,-(sp)
	st	Fighting			; Start !
	sf	Random_animating
	clr.l	Ghost_text
	move.w	#208,d0			; Remove icons
	move.w	#143,d1
	moveq.l	#96,d2
	moveq.l	#51,d3
	jsr	Draw_standard_box2
	addi.w	#32,d0			; Display weapons
	addq.w	#7,d1
	moveq.l	#2,d6
	moveq.l	#36,d7
	move.l	Tactic_icons_ptr,a0
	jsr	Put_masked_block
	jsr	Copy_screen_to_both
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
	clr.w	Cpart_target(a0)
	jsr	Determine_monster_action
.Next:	lea.l	Cp_size(a0),a0		; Next monster
.Entry:	dbra	d7,.Loop
; ---------- Insert party members in speed list ---
	lea.l	Combat_party,a0
	lea.l	Combat_speed_list,a1
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop2:	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next2
	btst	#Part_uncontrol,Part_flags(a0)	; Under control ?
	beq.s	.Yes2
	jsr	Select_uncontrollable_action	; No
	bra.s	.Go_on2
.Yes2:	addq.w	#1,d5			; Yes -> Count
.Go_on2:	move.l	a0,(a1)+			; Insert
	addq.w	#1,d6
.Next2:	lea.l	Cp_size(a0),a0		; Next member
	dbra	d7,.Loop2
	move.w	d5,Remaining_members	; Store
; ---------- Insert monsters in speed list --------
	lea.l	Combat_monsters,a0
	moveq.l	#0,d5
	move.w	Nr_monsters,d7
	bra.s	.Entry3
.Loop3:	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next3
	btst	#Part_uncontrol,Part_flags(a0)	; Under control ?
	beq.s	.Yes3
	jsr	Select_uncontrollable_action	; No
.Yes3:	move.l	a0,(a1)+			; Insert
	addq.w	#1,d5
	addq.w	#1,d6
.Next3:	lea.l	Cp_size(a0),a0		; Next monster
.Entry3:	dbra	d7,.Loop3
	move.w	d5,Remaining_monsters	; Store
	move.w	d6,Nr_participants
; ---------- Sort participants on speed -----------
	jsr	Sort_participants
; ---------- Handle all participants --------------
	lea.l	Combat_speed_list,a1
	move.w	Nr_participants,d7
	subq.w	#1,d7
.Loop4:	move.l	(a1)+,a0			; Get participant data
	moveq.l	#0,d0			; Any action ?
	move.b	Part_action(a0),d0
	beq	.Next4
	tst.b	Part_type(a0)		; (still there ?)
	beq	.Next4
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	bne.s	.Monster4
	move.w	#Combat_ink_party,Combat_PA+PA_Ink	; Party
	sf	Party_or_monster
	bra.s	.Go_on4
.Monster4:	move.w	#Combat_ink_monster,Combat_PA+PA_Ink	; Monster
	st	Party_or_monster
	jsr	Wait_4_animation		; Finish animation
.Go_on4:	lea.l	Combat_action_table,a2	; Get action data
	subq.w	#1,d0
	mulu.w	#6,d0
	add.w	d0,a2
	move.l	Cp_char(a0),a3		; Get conditions
	move.w	Body_conditions(a3),d0
	and.w	4(a2),d0			; Capable of this action ?
	beq.s	.Yes4
	clr.b	Part_action(a0)		; No -> Reset action
	move.w	#-1,Cpart_target(a0)
	bra	.Next4
.Yes4:	movem.l	d0-d7/a0-a6,-(sp)		; Yes -> Execute action
	move.l	(a2),a2
	jsr	(a2)
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	Update_control_status	; Remove incapable participants
	jsr	Display_combat_status_icons
	jsr	Update_combat_screen
	jsr	Update_combat_screen	; !
; ***** Check for end of battle *****
	tst.w	Remaining_members		; All players gone ?
	bne.s	.Ok
	tst.w	Fled_members		; Any fled ?
	bne.s	.Chicken
	move.b	#Combat_lost,Combat_result	; No -> Lost...
	bra	.Leave
.Chicken:	move.b	#Combat_fled,Combat_result	; Yes -> Fled !
	bra	.Leave
.Ok:	tst.w	Remaining_monsters		; All monsters gone ?
	bne.s	.Next4
	move.b	#Combat_won,Combat_result	; Won !
	bra	.Leave
.Next4:	dbra	d7,.Loop4			; Next participant
	jsr	Erase_PA			; Erase last message
; ---------- Check if leader is still capable -----
	move.l	Active_participant,a0
	tst.b	Part_type(a0)
	beq.s	.New
	move.l	Cp_char(a0),a1
	move.w	Body_conditions(a1),d0
	andi.w	#Active_mask,d0
	beq.s	.Skip
.New:	jsr	Select_new_active_member	; No -> Select new leader
; ---------- Advance monsters ---------------------
.Skip:	lea.l	Combat_matrix+3*6*4,a0	; 4th row empty ?
	moveq.l	#6-1,d7
.Loop5:	tst.l	(a0)+
	bne.s	.Done
	dbra	d7,.Loop5
	cmp.w	#1,Remaining_members	; More than one left ?
	bls.s	.Done
	move.w	#226,d0			; "The monsters advance !"
	jsr	Combat_prompt
	moveq.l	#6-1,d7			; Move all party members up
.Loop6:	tst.l	(a0)
	beq.s	.Next6
	move.l	(a0),a1
	clr.l	(a0)
	subq.w	#1,Cpart_Y(a1)
	move.l	a1,-6*4(a0)
.Next6:	addq.l	#4,a0
	dbra	d7,.Loop6
.Done:	jsr	Combat_CIL_evaluate		; Show control icons
.Leave:	move.w	#31,Combat_PA+PA_Ink	; Reset ink
	sf	Fighting			; Stop !
	st	Random_animating
	jsr	Display_combat_status_icons
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Sort the participants on their speed ]
; All registers are restored
; NOTE :
;   - Like [ Shellsort ] with [ Compare_participants ] : the fastest first.
Sort_participants:
	movem.l	d0-d3/d6/d7/a0-a3,-(sp)
	lea.l	Combat_speed_list,a2
	move.w	Nr_participants,d7
	moveq.l	#1,d6			; (insertion sort)
.Outer:	cmp.w	d7,d6
	bpl.s	.Exit
	move.w	d6,d0
.Inner:	tst.w	d0
	beq.s	.Next
	move.w	d0,d1
	lsl.w	#2,d1
	move.l	-4(a2,d1.w),a0		; Previous
	move.l	0(a2,d1.w),a1		; This one
	move.l	Cp_char(a0),a3
	move.w	ASpeed(a3),d2
	add.w	ASpeed+Magic(a3),d2
	move.l	Cp_char(a1),a3
	move.w	ASpeed(a3),d3
	add.w	ASpeed+Magic(a3),d3
	cmp.w	d2,d3			; Faster ?
	ble.s	.Next
	move.l	a1,-4(a2,d1.w)		; Yes -> swap
	move.l	a0,0(a2,d1.w)
	subq.w	#1,d0
	bra.s	.Inner
.Next:	addq.w	#1,d6
	bra.s	.Outer
.Exit:	movem.l	(sp)+,d0-d3/d6/d7/a0-a3
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
	move.w	Cpart_target(a0),d0		; Get destination
	lsl.w	#2,d0
	tst.l	0(a1,d0.w)		; Empty ?
	beq.s	.Empty
	move.w	#229,d0			; " blocked!"
	jsr	Do_part_prompt
	bra	.Exit
.Empty:	move.l	a0,0(a1,d0.w)		; Copy to destination
	move.w	Cpart_Y(a0),d0		; Clear source
	mulu.w	#6,d0
	add.w	Cpart_X(a0),d0
	lsl.w	#2,d0
	clr.l	0(a1,d0.w)
	moveq.l	#0,d0			; Set new coordinates
	move.w	Cpart_target(a0),d0
	divu.w	#6,d0
	move.w	d0,Cpart_Y(a0)
	swap	d0
	move.w	d0,Cpart_X(a0)
	jsr	Update_combat_screen	; Show
	bra	.Exit
; ---------- Move monster -------------------------
.Monster:	cmp.b	#Stand_anim,Part_anim(a0)	; Already animating ?
	beq.s	.No
	jsr	Wait_4_animation		; Yes -> Wait
.No:	moveq.l	#0,d0			; Get destination Y
	move.w	Cpart_target(a0),d0
	add.w	d0,d0
	move.w	Cpart_target(a0,d0.w),d0
	divu.w	#6,d0
	cmp.w	Cpart_Y(a0),d0		; Move or retreat ?
	bmi.s	.Retreat
	move.w	#228,d0			; " moves!"
	jsr	Do_part_prompt
	bra.s	.Go_on
.Retreat:	move.w	#232,d0			; " retreats!"
	jsr	Do_part_prompt
.Go_on:	move.l	Cp_original(a0),a1
	moveq.l	#0,d5			; Get number of frames
	move.b	Anim_frame(a1),d5
	bne.s	.Some			; At least one
	moveq.l	#1,d5
.Some:	bset	#Part_handanimated,Part_flags(a0)	; Prepare animation
	lea.l	Combat_matrix,a1		; Do moves
	lea.l	Cpart_target(a0),a2
	move.l	Cpart_COMOB_ptr(a0),a3
	move.w	(a2)+,d7			; Get number of moves
	bra	.Entry1
.Loop1:	move.w	(a2)+,d6			; Get destination
	move.w	d6,d0
	lsl.w	#2,d0
	tst.l	0(a1,d0.w)		; Empty ?
	bne	.Done
	move.l	a0,0(a1,d0.w)		; Copy to destination
	Set_anim	Stand_anim,a0
	move.w	Cpart_Y(a0),d0		; Clear source
	mulu.w	#6,d0
	add.w	Cpart_X(a0),d0
	lsl.w	#2,d0
	clr.l	0(a1,d0.w)
	moveq.l	#0,d0			; Calculate new coordinates
	move.w	d6,d0
	divu.w	#6,d0
	move.w	d0,d1
	swap	d0
	move.w	d0,Cpart_X(a0)		; Store
	move.w	d1,Cpart_Y(a0)
	jsr	Calculate_3D_coordinates	; Calculate target coordinates
	sub.w	Co_3D_X(a3),d0		; Calculate total vector
	sub.w	Co_3D_Z(a3),d1
	ext.l	d0
	ext.l	d1
	divs.w	d5,d0			; Calculate movement vector
	divs.w	d5,d1
	move.w	d0,Co_vector_X(a3)		; Set vector
	move.w	d1,Co_vector_Z(a3)
	move.w	d5,d6			; Show movement
	subq.w	#1,d6
.Loop2:	jsr	Do_animation_update
	jsr	Update_combat_screen
	dbra	d6,.Loop2
	clr.w	Co_vector_X(a3)		; Clear vector
	clr.w	Co_vector_Z(a3)
	move.w	Cpart_X(a0),d0		; (exactly there)
	move.w	Cpart_Y(a0),d1
	jsr	Calculate_3D_coordinates
	move.w	d0,Co_3D_X(a3)
	move.w	d1,Co_3D_Z(a3)
.Entry1:	dbra	d7,.Loop1			; Next move
.Done:	bclr	#Part_handanimated,Part_flags(a0)
	jsr	Wait_4_animation		; Wait
.Exit:	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Cpart_target(a0)
	rts

;*****************************************************************************
; [ Combat action - Parade ]
;*****************************************************************************
Do_parade:
	rts

;*****************************************************************************
; [ Combat action - Close-range and long-range weapons ]
;   IN : a0 - Pointer to participant data (.l)
; No registers are restored
; NOTE :
;   - From [ Do_close_range ] and [ Do_long_range ] (without the flying
;     projectiles).
;*****************************************************************************
Do_long_range:
	st	Long_range
	bra.s	Do_attack
Do_close_range:
	sf	Long_range
Do_attack:
; ---------- Find defender ------------------------
	lea.l	Combat_matrix,a1		; Get defender data
	move.w	Cpart_target(a0),d0
	lsl.w	#2,d0
	add.w	d0,a1
	move.l	(a1),d0			; Still there ?
	beq.s	.Gone
	move.l	d0,a1
	tst.b	Part_type(a1)
	bne.s	.Yes
.Gone:	clr.b	Part_action(a0)		; No -> Reset action
	move.w	#-1,Cpart_target(a0)
	tst.b	Long_range
	beq.s	.No_ammo1
	move.l	Cp_char(a0),a2		; Remove ammunition
	jsr	Remove_ammo
.No_ammo1:	tst.b	Party_or_monster		; Monster ?
	beq	.Party0
	jsr	Show_monster_attack
.Party0:	move.w	#211,d0			; "Missed !"
	jmp	Do_part_prompt
.Yes:	move.l	Cp_char(a0),a2		; Get character data
	move.l	Cp_char(a1),a3

; *** R E G I S T E R   C O N T E N T S ***
;  a0 - Pointer to attacker's participant data
;  a1 - Pointer to defender's participant data
;  a2 - Pointer to attacker's character data
;  a3 - Pointer to defender's character data

; ---------- Check undamageability ----------------
	move.w	Body_conditions(a3),d0	; Undamageable ?
	andi.w	#Damage_mask,d0
	beq.s	.Ok0
	jsr	Show_attack		; Yes
	move.w	#262,d0			; "Cannot damage !"
	jmp	Combat_prompt
; ---------- Check magical protection -------------
.Ok0:	move.w	Magic_bonus_armour(a3),d0	; Magical aura too strong ?
	cmp.w	Magic_bonus_weapon(a2),d0
	bls.s	.Ok1
	jsr	Show_attack		; Yes
	move.w	#212,d0			; "Magic too strong !"
	jmp	Do_part_prompt
; ---------- Get number of attacks ----------------
.Ok1:	moveq.l	#0,d6			; Get
	move.b	Attacks_per_round(a2),d6
	bclr	#Part_hurried,Part_flags(a0)	; Hurried ?
	beq.s	.No
	add.w	d6,d6			; Yes -> Double
.No:	subq.w	#1,d6
	bmi	.Exit
.Loop:	sf	Abort_attack		; Clear
	jsr	Show_attack		; Show
; ---------- Probe attacker's attack skill --------
	move.w	SAttack(a2),d0		; Get attack skill
	add.w	SAttack+Magic(a2),d0
	jsr	Probe_100
	bpl.s	.Ok2
	move.w	#213,d0			; "Attack failed !"
	jsr	Do_part_prompt
	bra	.Done
; ---------- Probe defender's parade skill --------
.Ok2:	cmp.b	#Parade_action,Part_action(a1)	; Defending ?
	bne	.Ok3
	move.w	SParade(a3),d0		; Get parade skill
	add.w	SParade+Magic(a3),d0
	tst.b	Long_range		; (long range : the attacker's,
	beq.s	.Parade			;  like in the original)
	move.w	SParade(a2),d0
	add.w	SParade+Magic(a2),d0
.Parade:	jsr	Probe_100
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
	jsr	Probe_100
	bmi.s	.Ok4
	move.w	#216,d0			; "Critical hit !"
	jsr	Do_part_prompt
	jsr	Break_attacker
	jsr	Break_defender
	move.w	Life_points+Maximum(a3),d1	; Kill (maximum!)
	tst.b	Long_range
	beq	.Damage
	move.w	Life_points(a3),d1
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
	move.w	#-1,Cpart_target(a0)
	bra.s	.Exit
.Next:	dbra	d6,.Loop			; Next attack
.Exit:	rts

; [ Show the attack ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;        a1 - Pointer to defender's participant data (.l)
;        a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
; All registers are restored
; NOTE :
;   - From [ Show_closerange_attack ] and [ Show_longrange_attack ].
Show_attack:
	jsr	Print_attacking		; Tell 'em
	tst.b	Long_range		; Long range ?
	beq.s	.Close
	jsr	Remove_ammo		; Yes -> remove ammunition
	tst.b	Party_or_monster
	beq.s	.Exit
	bra.s	Show_monster_attack
.Close:	tst.b	Party_or_monster		; Party or monster ?
	bne.s	Show_monster_attack
	jmp	Show_slash		; Party -> Slash!
.Exit:	rts

; [ Show the attack of a monster (move forward & animate) ]
;   IN : a0 - Pointer to monster's participant data (.l)
; All registers are restored
Show_monster_attack:
	move.l	a1,-(sp)
	move.l	Cpart_COMOB_ptr(a0),a1	; Move forward
	subq.w	#1,Co_3D_Z(a1)
	Set_anim	Closerange_anim,a0		; Animate
	tst.b	Long_range
	beq.s	.Close
	Set_anim	Longrange_anim,a0
.Close:	jsr	Wait_4_animation
	addq.w	#1,Co_3D_Z(a1)		; Move back
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Calculate attacker's damage & defender's protection ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;        a1 - Pointer to defender's participant data (.l)
;        a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
;  OUT : d1 - Attacker's damage (.w)
;        d2 - Defender's protection (.w)
; All registers are restored
; NOTE :
;   - From COMBAT/COMBAT.S (without the spells of the party).
;*****************************************************************************
Calculate_damage_and_protection:
	move.l	d0,-(sp)
	move.w	Damage(a2),d0		; Calculate maximum damage
	add.w	Damage_magic(a2),d0
	moveq.l	#0,d1
	move.w	AStrength(a2),d1
	add.w	AStrength+Magic(a2),d1
	divu.w	#25,d1
	add.w	d0,d1
	move.w	d1,d0
	jsr	Get_random_50_100
	move.w	d0,d1
	move.w	Protection(a3),d0		; Calculate maximum protection
	add.w	Protection_magic(a3),d0
	moveq.l	#0,d2
	move.w	AConstitution(a3),d2
	add.w	AConstitution+Magic(a3),d2
	divu.w	#25,d2
	add.w	d0,d2
	move.w	d2,d0
	jsr	Get_random_50_100
	move.w	d0,d2
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Try to break items ]
;*****************************************************************************
; [ Try to break attacker's weapon ]
;   IN : a0 - Pointer to attacker's participant data (.l)
; All registers are restored
Break_attacker:
	movem.l	d1/d2/a0,-(sp)
	move.l	#Attacker_break_mask,d1
	moveq.l	#Right_hand,d2
	move.l	Cp_char(a0),a0
	jsr	Try_to_break_combat_item
	movem.l	(sp)+,d1/d2/a0
	beq.s	.Exit			; Well ?
	st	Abort_attack		; Abort
	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Cpart_target(a0)
.Exit:	rts

; [ Try to break parader's sword & shield ]
;   IN : a1 - Pointer to defender's participant data (.l)
; All registers are restored
Break_parader:
	movem.l	d1/d2/a0,-(sp)
	move.l	#Parader_break_mask,d1
	move.l	Cp_char(a1),a0
	moveq.l	#Right_hand,d2
	jsr	Try_to_break_combat_item
	moveq.l	#Left_hand,d2
	jsr	Try_to_break_combat_item
	movem.l	(sp)+,d1/d2/a0
	rts

; [ Try to break defender's armour ]
;   IN : a1 - Pointer to defender's participant data (.l)
; All registers are restored
Break_defender:
	movem.l	d1/d2/a0,-(sp)
	move.l	#Defender_break_mask,d1
	move.l	Cp_char(a1),a0
	moveq.l	#Body,d2
	jsr	Try_to_break_combat_item
	movem.l	(sp)+,d1/d2/a0
	rts

; [ Try to break an item ]
;   IN : d1 - Item type mask (.l)
;        d2 - Slot index {0...8} (.w)
;        a0 - Pointer to character data (.l)
;  OUT : eq - Not broken, ne - Broken
; All registers are restored
Try_to_break_combat_item:
	movem.l	d0-d3/d7/a0-a2,-(sp)
	moveq.l	#0,d7			; Default is not broken
	lea.l	Char_inventory(a0),a2	; Get packet address
	move.w	d2,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a2
	move.w	Object_index(a2),d0		; Any object ?
	beq	.Exit
	jsr	Get_item_data
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
	lea.l	Char_name(a0),a2		; "... is broken"
	move.l	a2,Format_args
	lea.l	Item_name(a1),a2
	move.l	a2,Format_args+4
	moveq.l	#Broken_txt,d0
	jsr	Combat_format_text
	lea.l	Char_inventory(a0),a2	; Break !
	move.w	d2,d0
	mulu.w	#Object_packet_size,d0
	add.w	d0,a2
	bset	#Broken_item,Item_bits_DYNAMIC(a2)
	move.l	a0,-(sp)			; Put away
	move.l	a2,a0
	jsr	Put_item_in_apres_pool
	move.l	(sp)+,a0
	addq.w	#1,d2			; Remove
	moveq.l	#1,d3
	jsr	Remove_item
	moveq.l	#-1,d7			; Broke it !
.Exit:	tst.w	d7
	movem.l	(sp)+,d0-d3/d7/a0-a2
	rts

; [ Put item in apres-pool ]
;   IN : a0 - Pointer to object packet (.l)
; All registers are restored
Put_item_in_apres_pool:
	movem.l	d0/a1,-(sp)
	move.w	Nr_apres_objects,d0
	cmp.w	#Max_combat_items,d0
	bpl.s	.Exit
	mulu.w	#Object_packet_size,d0
	lea.l	Apres_pool,a1
	add.l	d0,a1
	Copy_packet a0,a1
	addq.w	#1,Nr_apres_objects		; Count up
.Exit:	movem.l	(sp)+,d0/a1
	rts

; [ Remove ammunition & reload ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;        a2 - Pointer to attacker's character data (.l)
; All registers are restored
Remove_ammo:
	movem.l	d0/d2/d3/d7/a0/a1/a3,-(sp)
	move.w	Char_inventory+Right_hand_slot+Object_index(a2),d0
	beq	.Exit
	jsr	Get_item_data
	tst.b	Ammo_use_ID(a1)		; Any ammo ?
	bne	.Yes
	btst	#Destroy_after_use,Item_bits_STATIC(a1)	; Destroy ?
	beq	.Exit
	move.l	a0,-(sp)
	move.l	a2,a0			; Remove from right hand
	moveq.l	#Right_hand+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.l	(sp)+,a0
	bra.s	.Done
.Yes:	lea.l	Char_inventory+Backpack_slots(a2),a3
	moveq.l	#9+1,d2
	move.w	Char_inventory+Left_hand_slot+Object_index(a2),d7
.Loop:	cmp.w	Object_index(a3),d7		; Right ammo ?
	bne.s	.Next
	move.l	a0,-(sp)			; Yes -> Remove
	move.l	a2,a0
	moveq.l	#1,d3
	jsr	Remove_item
	move.l	(sp)+,a0
	bra.s	.Exit
.Next:	addq.l	#Object_packet_size,a3	; Next slot
	addq.w	#1,d2
	cmp.w	#Items_per_char+9+1,d2
	bmi.s	.Loop
	move.l	a0,-(sp)			; Remove from left hand
	move.l	a2,a0
	moveq.l	#Left_hand+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.l	(sp)+,a0
	move.w	#217,d0			; Tell 'em
	jsr	Do_part_prompt
.Done:	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Cpart_target(a0)
	st	Abort_attack		; Abort
.Exit:	movem.l	(sp)+,d0/d2/d3/d7/a0/a1/a3
	rts

;*****************************************************************************
; [ Combat texts ]
;*****************************************************************************
; [ Print "Attacks!" text ]
;   IN : a2 - Pointer to attacker's character data (.l)
;        a3 - Pointer to defender's character data (.l)
; All registers are restored
Print_attacking:
	movem.l	d0/a0/a1,-(sp)
	lea.l	Char_name(a2),a0		; Insert names
	move.l	a0,Format_args
	lea.l	Char_name(a3),a0
	move.l	a0,Format_args+4
	move.w	Char_inventory+Right_hand_slot+Object_index(a2),d0
	beq.s	.None			; Any weapon ?
	jsr	Get_item_data		; Insert weapon name
	lea.l	Item_name(a1),a0
	move.l	a0,Format_args+8
	moveq.l	#Attack_txt,d0
	bra.s	.Do
.None:	moveq.l	#Attack2_txt,d0
.Do:	jsr	Combat_format_text
	movem.l	(sp)+,d0/a0/a1
	rts

; [ Print "Hits!" text ]
;   IN : d1 - Amount of damage (.w)
;        a2 - Pointer to attacker's character data (.l)
; All registers are restored
Print_hitting:
	movem.l	d0/d7/a0,-(sp)
	lea.l	Char_name(a2),a0		; Insert attacker's name
	move.l	a0,Format_args
	lea.l	Combat_number,a0		; Insert number
	move.l	a0,Format_args+4
	moveq.l	#0,d0
	move.w	d1,d0
	moveq.l	#5,d7
	jsr	DecL_convert
	moveq.l	#Hit_txt,d0
	jsr	Combat_format_text
	movem.l	(sp)+,d0/d7/a0
	rts

; [ Print a prompt referring to a combat participant ]
;   IN : d0 - Prompt number (.w)
;        a0 - Pointer to participant data (.l)
; All registers are restored
Do_part_prompt:
	movem.l	d0/a0-a2,-(sp)
	lea.l	Format_buffer,a2		; Name & prompt
	move.l	Cp_char(a0),a1
	lea.l	Char_name(a1),a1
.Copy1:	move.b	(a1)+,(a2)+
	bne.s	.Copy1
	subq.l	#1,a2
	addi.w	#Messages,d0
	jsr	Get_text
.Copy2:	move.b	(a0)+,(a2)+
	bne.s	.Copy2
	lea.l	Format_buffer,a0
	jsr	Display_combat_text
	movem.l	(sp)+,d0/a0-a2
	rts

; [ Print a prompt in combat ]
;   IN : d0 - Prompt number (.w)
; All registers are restored
Combat_prompt:
	move.l	a0,-(sp)
	addi.w	#Messages,d0
	jsr	Get_text
	addi.w	#-Messages,d0
	jsr	Display_combat_text
	move.l	(sp)+,a0
	rts

; [ Print a format text in combat ]
;   IN : d0 - Format text number (.w)
;        [ Format_args ] - Arguments (.l)
; All registers are restored
Combat_format_text:
	movem.l	a0/a1,-(sp)
	lea.l	Format_buffer,a1
	jsr	Format_text
	lea.l	Format_buffer,a0
	jsr	Display_combat_text
	movem.l	(sp)+,a0/a1
	rts

; [ Display a text in combat ]
;   IN : a0 - Pointer to text (.l)
; All registers are restored
; NOTE :
;   - Like the slow combat of the original : the player clicks.
Display_combat_text:
	jsr	Print_PA_text
	jsr	Copy_screen_to_both
	jsr	Combat_wait_click
	jsr	Erase_PA
	jmp	Copy_screen_to_both

;*****************************************************************************
; [ Damage ]
;*****************************************************************************
; [ Do damage to party member in combat ]
;   IN : d0 - Amount of damage (.w)
;        a0 - Pointer to party member's participant data (.l)
; All registers are restored
Do_combat_damage:
	movem.l	d0-d3/d7/a0/a1,-(sp)
	move.l	Cp_char(a0),a1
	move.w	Body_conditions(a1),d1	; Can be damaged ?
	andi.w	#Damage_mask,d1
	bne	.Exit
	tst.w	d0			; Yes -> Any damage ?
	beq.s	.Skip
	move.w	Body_conditions(a1),d1	; Yes -> Wake up
	bclr	#Asleep,d1
	move.w	d1,Body_conditions(a1)
.Skip:	move.w	d0,Cpart_damage(a0)		; Show in tactical window
	move.b	#Combat_damage_interval,Part_damage_timer(a0)
	jsr	Show_scratches		; Show
	moveq.l	#0,d7			; Do
	move.b	Part_nr(a0),d7
	jsr	Do_damage
	move.w	Body_conditions(a1),d1	; Dead ?
	btst	#Dead,d1
	beq.s	.Exit
	st	Abort_attack		; Yes -> Abort !
.Exit:	movem.l	(sp)+,d0-d3/d7/a0/a1
	rts

; [ Do damage to monster ]
;   IN : d0 - Amount of damage (.w)
;        a0 - Pointer to monster's participant data (.l)
; All registers are restored
Do_damage_to_monster:
	movem.l	d0/d1/a0/a1,-(sp)
	move.l	Cp_char(a0),a1		; Can be damaged ?
	move.w	Body_conditions(a1),d1
	andi.w	#Damage_mask,d1
	bne	.Exit
	tst.w	d0			; Yes -> Any damage ?
	beq.s	.Skip
	move.w	Body_conditions(a1),d1	; Yes -> Wake up
	bclr	#Asleep,d1
	move.w	d1,Body_conditions(a1)
.Skip:	move.w	d0,Cpart_damage(a0)		; Show in tactic window
	move.b	#Combat_damage_interval,Part_damage_timer(a0)
	Set_anim	Hit_anim,a0		; Hit animation
	jsr	Show_blood		; Blood
	jsr	Wait_4_animation
	move.w	Life_points(a1),d1		; Do the damage
	sub.w	d0,d1
	bgt.s	.Ok2			; Dead ?
	jsr	Show_monster_death		; Kill !
	jsr	Kill_monster
	st	Abort_attack		; Abort !
	bra.s	.Exit
.Ok2:	move.w	d1,Life_points(a1)		; Store new LP
.Exit:	movem.l	(sp)+,d0/d1/a0/a1
	rts

; [ Kill monster ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are restored
; NOTE :
;   - Items, gold & food are put in the apres pool.
Kill_monster:
	movem.l	d0/d7/a0/a1,-(sp)
	move.l	Cp_char(a0),a1
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
.Next:	addq.l	#Object_packet_size,a0	; Next slot
	dbra	d7,.Loop
	move.l	(sp)+,a0
	moveq.l	#0,d0			; Gain EP
	move.w	Battle_experience(a1),d0
	add.l	d0,Gained_experience
	jsr	Update_control_status	; Remove incapable participants
	jsr	Update_combat_screen
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Combat action - Flee ]
;   IN : a0 - Pointer to participant data (.l)
; No registers are restored
;*****************************************************************************
Do_flee:
	move.w	#142,d0			; Tell 'em
	jsr	Do_part_prompt
	move.l	Cp_char(a0),a1		; Fleeing
	move.w	Body_conditions(a1),d0
	bset	#Fleeing,d0
	move.w	d0,Body_conditions(a1)
	tst.b	Party_or_monster		; Party or monster ?
	bne.s	.Monster
	addq.w	#1,Fled_members		; Count
	rts
.Monster:	moveq.l	#0,d0			; Gain EP
	move.w	Battle_experience(a1),d0
	add.l	d0,Gained_experience
	jmp	Show_flight		; Show

;*****************************************************************************
; [ Movement & targets ]
;*****************************************************************************
; [ Determine movement range in combat ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : d0 - Possible movement mask (.l)
; Changed registers : d0
Check_movement_range:
	movem.l	d1-d7/a0-a2,-(sp)
	lea.l	Move_cells,a1		; Clear automatus
	moveq.l	#15-1,d7
.Loop0:	clr.w	(a1)+
	dbra	d7,.Loop0
	lea.l	-30(a1),a1
	move.l	Cp_char(a0),a2		; Get movement speed
	move.w	ASpeed(a2),d2
	add.w	ASpeed+Magic(a2),d2
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
	move.w	Cpart_X(a0),d0		; Get coordinates
	move.w	Cpart_Y(a0),d1
	mulu.w	#6,d1			; Initialize automatus
	add.w	d1,d0
	move.b	d2,0(a1,d0.w)
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	bne.s	.Monster
	move.l	#Combat_party_mask,d6	; Get allowed mask
	bra.s	.Again
.Monster:	move.l	#Combat_monster_mask,d6
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
	lea.l	Combat_matrix,a0		; Build mask
	moveq.l	#0,d0
	moveq.l	#0,d7
.Loop3:	tst.l	(a0)+			; Occupied ?
	bne.s	.Next3
	tst.b	(a1)			; Cell filled ?
	beq.s	.Next3
	bset	d7,d0			; Yes -> Set mask
.Next3:	addq.l	#1,a1			; Next cell
	addq.w	#1,d7
	cmp.w	#30,d7
	bmi.s	.Loop3
	movem.l	(sp)+,d1-d7/a0-a2
	rts

; [ Make bitlist of occupied movement targets ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : d0 - Bitlist (.l)
; Changed registers : d0
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
	move.w	Cpart_target(a2),d1		; Get target
	bmi.s	.Next			; Any ?
	bra.s	.Do
.Monster:	move.w	Cpart_target(a2),d1		; Get number of targets
	bls.s	.Next			; Any ?
	add.w	d1,d1			; Yes -> Get final destination
	move.w	Cpart_target(a2,d1.w),d1
.Do:	bset	d1,d0			; Mask
.Next:	addq.l	#4,a1			; Next
	dbra	d7,.Loop
	movem.l	(sp)+,d1/d6/d7/a0-a2
	rts

; [ Make bitlist of long-range attack targets ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : d0 - Bitlist (.l)
; Changed registers : d0
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

; [ Make bitlist of close-range attack targets ]
;   IN : a0 - Pointer to attacker's participant data (.l)
;  OUT : d0 - Bitlist (.l)
; Changed registers : d0
Get_closerange_targets:
	move.l	d1,-(sp)
	move.w	Cpart_X(a0),d0		; Get coordinates
	move.w	Cpart_Y(a0),d1
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
; [ Uncontrollable participants ]
;*****************************************************************************
; [ Select action for uncontrollable participant ]
;   IN : a0 - Pointer to uncontrollable participant data (.l)
; All registers are restored
Select_uncontrollable_action:
	movem.l	d0/a1,-(sp)
	clr.b	Part_action(a0)		; Reset action
	move.w	#-1,Cpart_target(a0)
	move.l	Cp_char(a0),a1		; What's the matter ?
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
.Exit:	movem.l	(sp)+,d0/a1
	rts

; [ Select panic action ]
;   IN : a0 - Pointer to participant data (.l)
;        a1 - Pointer to character data (.l)
; All registers are restored
Select_panic_action:
	movem.l	d0-d5/d7/a2,-(sp)
	cmp.b	#2,Part_type(a0)		; Monster ?
	bne.s	.Party
	jsr	Select_defensive_monster_action	; Yes
	bra	.Exit
.Party:	cmp.w	#4,Cpart_Y(a0)		; In bottom row ?
	bne.s	.Move
	move.w	Body_conditions(a1),d0	; Can flee ?
	andi.w	#Flee_mask,d0
	bne	.Exit
	move.w	#-1,Cpart_target(a0)		; Yes -> Flee
	move.b	#Flee_action,Part_action(a0)
	bra	.Exit
.Move:	jsr	Get_occupied_targets	; Get occupied targets
	move.l	d0,d1
	jsr	Check_movement_range	; Get movement range
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	tst.l	d0			; Any left ?
	beq	.Exit
	move.l	d0,d5			; Yes
	move.w	Cpart_X(a0),d0		; Get coordinates
	move.w	Cpart_Y(a0),d1
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
	move.w	d2,Cpart_target(a0)
.Exit:	movem.l	(sp)+,d0-d5/d7/a2
	rts

; [ Select crazy action ]
;   IN : a0 - Pointer to participant data (.l)
;        a1 - Pointer to character data (.l)
; All registers are restored
Select_crazy_action:
	movem.l	d0-d4/a2,-(sp)
	jsr	Random			; Move or attack ?
	cmp.w	#40000,d0
	bcs.s	.Attack
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
	bpl.s	.Loop2
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	bne.s	.Monster
	move.w	d1,Cpart_target(a0)		; Party
	bra.s	.Skip
.Monster:	move.w	#1,Cpart_target(a0)		; Monster
	move.w	d1,Cpart_target+2(a0)
.Skip:	move.b	#Move_action,Part_action(a0)
.Exit:	rts

; [ Try to attack something ]
Try_crazy_attack:
	move.w	Body_conditions(a1),d0	; Attacking possible ?
	andi.w	#Attack_mask,d0
	bne	.Exit
	move.w	Damage(a1),d0
	add.w	Damage_magic(a1),d0
	beq	.Exit
	move.w	Char_inventory+Right_hand_slot+Object_index(a1),d0
	beq	.Close			; Nothing ? -> Close range
	move.l	a1,-(sp)
	jsr	Get_item_data
	cmp.b	#Longrange_itemtype,Item_type(a1)	; Long range ?
	move.l	(sp)+,a1
	beq	.Exit
.Close:	lea.l	Combat_matrix,a2		; Get possible move mask
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#8-1,d2
.Loop1:	move.w	Cpart_X(a0),d0		; Move in a direction
	move.w	Cpart_Y(a0),d1
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
	bpl.s	.Loop2
	move.w	d1,Cpart_target(a0)		; Store
	move.b	#Close_range_action,Part_action(a0)
.Exit:	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

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
	dc.l Do_parade			; (cast spell)
	dc.w $ffff
	dc.l Do_parade			; (use magic object)
	dc.w $ffff

Combat_CIL:					; (options and magic are not
	dc.w Flee_cicon,Disk_cicon+Disabled,OK_cicon	;  possible)
	dc.w Combat_pos_cicon,Forward_3D_cicon,0
	dc.w Attack_cicon,Parade_cicon,Use_magic_cicon+Disabled

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
	even
Dir8_offset:
	dc.b 0,-1,1,-1		; N NE
	dc.b 1,0,1,1		; E SE
	dc.b 0,1,-1,1		; S SW
	dc.b -1,0,-1,-1		; W NW
	even

Combat_PA:	dc.w Combat_PA_X1,Combat_PA_X2,Combat_PA_Y1,Combat_PA_Y2,31

CB_name:	dc.b "CB",0
MC_name:	dc.b "MC",0
MG_name:	dc.b "MG",0
TACTIC_name:	dc.b "TACTIC",0
COMBFX_name:	dc.b "COMBFX",0
Combat_file_name:	dc.b "DATA\XXXXXXXXXXXXXXXX",0
	even
Combat_files:
	dc.l	Extra_layout,320*163/2
	dc.b	"DATA\LAYOUT4.BIN",0
	even
	dc.l	0

	SECTION	Fast_BSS,bss
; ---------- Kept between combats -----------------
Combat_req:	ds.b 1
Could_not_flee:	ds.b 1
Monstergroup_nr:	ds.w 1
Combat_char_index:	ds.w 1
Combat_background:	ds.w 1
Monster_move_delay:	ds.w 1
Combat_bg_table:	ds.b 16*4		; (CBGTAB.BIN)
Monster_groups:	ds.b 128*Max_monsters*2	; (MGROUPS.BIN)
; ---------- Cleared for each combat --------------
Combat_data:
Combat_free:	ds.l 1			; Free memory in the workspace
Combat_bg_ptr:	ds.l 1			; Background (palette, LUT, image)
Tactic_icons_ptr:	ds.l 1
Combat_FX_ptr:	ds.l 1
Active_participant:	ds.l 1
Gained_experience:	ds.l 1
Tactic_mask:	ds.l 1
Target_mask:	ds.l 1
Combat_active:	ds.w 1
Nr_apres_objects:	ds.w 1
Global_danger:	ds.w 1
Nr_monsters:	ds.w 1
Remaining_monsters:	ds.w 1			; Under control
Remaining_members:	ds.w 1			; Under control
Fled_members:	ds.w 1
Nr_participants:	ds.w 1
Apres_gold:	ds.w 1
Apres_food:	ds.w 1
Combat_anim_time:	ds.w 1
Combat_CIL_work:	ds.w 9
Loaded_monsters:	ds.w 3*Max_monsters		; Number, pointer
Loaded_graphics:	ds.w 5*Max_monsters		; Number, pointer, data
Combat_aborted:	ds.b 1
Party_or_monster:	ds.b 1
Abort_attack:	ds.b 1
Combat_result:	ds.b 1
CellA_completed:	ds.b 1
	even
Move_cells:	ds.b 5*6
Random_animating:	ds.b 1
Fighting:	ds.b 1
Long_range:	ds.b 1
Show_monsters:	ds.b 1
	even
Combat_party:	ds.b 6*Cp_size
Combat_monsters:	ds.b Max_monsters*Cp_size
Combat_matrix:	ds.l 5*6
Combat_speed_list:	ds.l 6+Max_monsters
Combat_data_end:
Convert_LUT:	ds.b 32
Convert_pixels:	ds.b 16
Combat_number:	ds.b 8
Tactic_background:	ds.b 6*8*(5*Tactic_cell_height+2)
Apres_pool:	ds.b Max_combat_items*Object_packet_size
	even
