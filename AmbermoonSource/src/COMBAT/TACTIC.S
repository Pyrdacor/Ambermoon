; Combat tactic window routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 4-3-1993

	SECTION	Program,code
;*****************************************************************************
; [ Select party member (MAGIC) ]
;  OUT : d0 - Selected position {0...29} / -1 (.w)
; Changed registers : d0
; Note :
;   - This routine assumes [ ItemSelect_prompt ] has already been set.
;*****************************************************************************
Select_party_member:
	movem.l	d1/d6/d7/a0,-(sp)
	lea.l	Combat_party,a0		; Search party members
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop:	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next
	move.w	Part_X(a0),d0		; Yes -> Get coordinates
	move.w	Part_Y(a0),d1
	mulu.w	#6,d1			; Calculate index
	add.w	d1,d0
	bset	d0,d6			; Mask
.Next:	lea.l	Participant_data_size(a0),a0	; Next party member
	dbra	d7,.Loop
	move.l	d6,Tactic_mask		; Store mask
	move.l	#Show_magic_tactic,Tactic_draw_vector	; Who ?
	Push	Module,TacticSel_Mod
	move.w	Selected_tactic,d0		; Get result
	movem.l	(sp)+,d1/d6/d7/a0
	rts

;*****************************************************************************
; [ Select monster (MAGIC) ]
;  OUT : d0 - Selected position {0...29} / -1 (.w)
; Changed registers : d0
; Note :
;   - This routine assumes [ ItemSelect_prompt ] has already been set.
;*****************************************************************************
Select_monster:
	movem.l	d1/d6/d7/a0,-(sp)
	lea.l	Combat_monsters,a0		; Search monsters
	moveq.l	#0,d6
	move.w	Nr_monsters,d7
	bra.s	.Entry
.Loop:	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next
	move.w	Part_X(a0),d0		; Yes -> Get coordinates
	move.w	Part_Y(a0),d1
	mulu.w	#6,d1			; Calculate index
	add.w	d1,d0
	bset	d0,d6			; Mask
.Next:	lea.l	Participant_data_size(a0),a0	; Next party member
.Entry:	dbra	d7,.Loop
	move.l	d6,Tactic_mask		; Store mask
	move.l	#Show_magic_tactic,Tactic_draw_vector	; Who ?
	Push	Module,TacticSel_Mod
	move.w	Selected_tactic,d0		; Get result
	movem.l	(sp)+,d1/d6/d7/a0
	rts

;*****************************************************************************
; [ Select row of party members (MAGIC) ]
;  OUT : d0 - Selected row {4...5} / -1 (.w)
; Changed registers : d0
; Note :
;   - This routine assumes [ ItemSelect_prompt ] has already been set.
;*****************************************************************************
Select_member_row:
	move.l	a0,-(sp)
	move.l	#Show_member_row_tactic,Tactic_draw_vector	; Who ?
	move.l	#Combat_party_mask,Tactic_mask
	Push	Module,TacticSel_Mod
	moveq.l	#0,d0			; Get row number
	move.w	Selected_tactic,d0
	bmi.s	.Exit
	divu.w	#6,d0
.Exit:	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Select row of monsters (MAGIC) ]
;  OUT : d0 - Selected row {0...4} / -1 (.w)
; Changed registers : d0
; Note :
;   - This routine assumes [ ItemSelect_prompt ] has already been set.
;*****************************************************************************
Select_monster_row:
	move.l	a0,-(sp)
	move.l	#Show_monster_row_tactic,Tactic_draw_vector	; Who ?
	move.l	#Combat_monster_mask,Tactic_mask
	Push	Module,TacticSel_Mod
	moveq.l	#0,d0			; Get row number
	move.w	Selected_tactic,d0
	bmi.s	.Exit
	divu.w	#6,d0
.Exit:	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Get tactic window background ]
; All registers are restored
;*****************************************************************************
Get_tactic_window:
	movem.l	d0/d1/d5-d7/a0,-(sp)
	tst.b	Tactic_bg_handle		; Done already ?
	bne.s	.Exit
	move.l	#6*2*3*(5*Tactic_cell_height+2),d0	; Make buffer
	jsr	Allocate_CHIP
	move.b	d0,Tactic_bg_handle
	move.w	#Tactic_X,d0		; Get background
	move.w	#Tactic_Y-1,d1
	moveq.l	#3,d5
	moveq.l	#6,d6
	moveq.l	#5*Tactic_cell_height+2,d7
	Get	Tactic_bg_handle,a0
	jsr	Get_block
	Free	Tactic_bg_handle
.Exit:	movem.l	(sp)+,d0/d1/d5-d7/a0
	rts

;*****************************************************************************
; [ Draw tactic window ]
; All registers are restored
;*****************************************************************************
Draw_tactic_window:
	movem.l	d0/d1/d4-d7/a0,-(sp)
	move.w	#Tactic_X,d0
	move.w	#Tactic_Y-1,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#6,d6
	moveq.l	#5*Tactic_cell_height+2,d7
	Get	Tactic_bg_handle,a0
	jsr	Put_unmasked_block
	Free	Tactic_bg_handle
	movem.l	(sp)+,d0/d1/d4-d7/a0
	rts

;*****************************************************************************
; [ Draw tactic icons ]
; All registers are restored
;*****************************************************************************
Draw_tactic_icons:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Combat_matrix,a1		; Draw tactical matrix
	Get	FXGFX_handle,a2
	add.l	#Tactical_GFX,a2
	move.w	#Tactic_Y-1,d1
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#14,d7
	moveq.l	#5-1,d2
.Loop_Y:	move.w	#Tactic_X,d0
	moveq.l	#6-1,d3
.Loop_X:	tst.l	(a1)			; Anything there ?
	beq.s	.Next_X
	move.l	(a1),a3			; Yes -> Get data
	moveq.l	#0,d4			; Get icon number
	move.b	Part_icon_nr(a3),d4
	mulu.w	#14*2*Screen_depth,d4	; Get graphics address
	lea.l	0(a2,d4.w),a0
	jsr	Put_masked_block		; Display tactical icon
	tst.b	Part_damage_timer(a3)	; Any damage ?
	beq.s	.Next_X
	jsr	Show_damage		; Yes -> Show
.Next_X:	addq.l	#4,a1			; Next
	addi.w	#16,d0
	dbra	d3,.Loop_X
	addi.w	#Tactic_cell_height,d1
	dbra	d2,.Loop_Y
	Free	FXGFX_handle
	jsr	Blink_colour		; Blink
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Print damage ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a3 - Pointer to participant (.l)
; All registers are restored
;*****************************************************************************
Show_damage:
	movem.l	d0-d7/a0-a3,-(sp)
	subq.b	#1,Part_damage_timer(a3)	; Count down
	moveq.l	#0,d2			; Get damage
	move.w	Part_damage(a3),d2
	beq	.Exit
	cmp.w	#1000,d2			; Too large ?
	bmi.s	.Ok
	move.w	#999,d2			; Yes -> Clip
.Ok:	lea.l	Very_small_numbers,a0	; Get three digits &
	divu.w	#10,d2			;  pointers to font
	swap	d2
	move.w	d2,d3
	mulu.w	#5,d3
	lea.l	0(a0,d3.w),a2
	clr.w	d2
	swap	d2
	divu.w	#10,d2
	move.w	d2,d3
	swap	d2
	mulu.w	#5,d2
	lea.l	0(a0,d2.w),a1
	mulu.w	#5,d3
	add.w	d3,a0
	lea.l	Very_small_buffer,a3	; Draw to buffer
	moveq.l	#5-1,d7
.Loop:	moveq.l	#0,d2			; Take first digit
	move.b	(a0)+,d2
	lsl.w	#8,d2
	moveq.l	#0,d3			; Take second digit
	move.b	(a1)+,d3
	lsl.w	#3,d3
	or.w	d3,d2			; Merge
	moveq.l	#0,d3			; Take third digit
	move.b	(a2)+,d3
	lsr.w	#2,d3
	or.w	d3,d2			; Merge
	move.w	d2,(a3)+			; Put in buffer
	dbra	d7,.Loop
	lea.l	-10(a3),a0		; Display
	addq.w	#1,d0
	addi.w	#10,d1
	move.w	Blinked_colour,d4
	moveq.l	#1,d5
	moveq.l	#1,d6
	moveq.l	#5,d7
	jsr	Put_masked_silhouette
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Show possible party member rows in tactic window ]
; All registers are restored
;*****************************************************************************
Show_member_row_tactic:
	movem.l	d0/d1/d6/d7/a0/a1,-(sp)
	jsr	Show_active_member		; Show active member
	moveq	#0,d0			; Get mouse Y
	move.w	Mouse_Y,d0
	subi.w	#Tactic_Y,d0
	bmi	.Exit			; Too low ?
	divu.w	#Tactic_cell_height,d0	; Get row number
	cmpi.w	#4,d0			; Too low ?
	bmi	.Exit
	mulu.w	#6,d0			; Get offset
	lea.l	Combat_matrix,a0		; Search matrix row
	move.w	d0,d1
	lsl.w	#2,d1
	add.w	d1,a0
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop:	tst.l	(a0)			; Anything there ?
	beq.s	.Set
	move.l	(a0),a1			; Is a party member ?
	cmp.b	#1,Part_type(a1)
	bne.s	.Next
.Set:	bset	d0,d6			; Yes -> Set mask
.Next:	addq.w	#1,d0			; Next square in row
	addq.l	#4,a0
	dbra	d7,.Loop
	move.l	d6,d0			; Show member row
	lea.l	Draw_green_square,a0
	jsr	Show_mask_tactic
.Exit:	movem.l	(sp)+,d0/d1/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Show possible monster rows in tactic window ]
; All registers are restored
;*****************************************************************************
Show_monster_row_tactic:
	movem.l	d0/d1/d6/d7/a0/a1,-(sp)
	jsr	Show_active_member		; Show active member
	moveq	#0,d0			; Get mouse Y
	move.w	Mouse_Y,d0
	subi.w	#Tactic_Y,d0
	bmi	.Exit			; Too low ?
	divu.w	#Tactic_cell_height,d0	; Get row number
	cmpi.w	#4,d0			; Too high ?
	bpl	.Exit
	mulu.w	#6,d0			; Get offset
	lea.l	Combat_matrix,a0		; Search matrix row
	move.w	d0,d1
	lsl.w	#2,d1
	add.w	d1,a0
	moveq.l	#0,d6
	moveq.l	#6-1,d7
.Loop:	tst.l	(a0)			; Anything there ?
	beq.s	.Set
	move.l	(a0),a1			; Is a monster ?
	cmp.b	#2,Part_type(a1)
	bne.s	.Next
.Set:	bset	d0,d6			; Yes -> Set mask
.Next:	addq.w	#1,d0			; Next square in row
	addq.l	#4,a0
	dbra	d7,.Loop
	move.l	d6,d0			; Show monster row
	lea.l	Draw_green_square,a0
	jsr	Show_mask_tactic
.Exit:	movem.l	(sp)+,d0/d1/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Show possible participant rows in tactic window ]
; All registers are restored
;*****************************************************************************
Show_participant_row_tactic:
	movem.l	d0/d1/a0,-(sp)
	jsr	Show_active_member		; Show active member
	moveq	#0,d0			; Get mouse Y
	move.w	Mouse_Y,d0
	subi.w	#Tactic_Y,d0
	bmi	.Exit			; Too low ?
	divu.w	#Tactic_cell_height,d0	; Get row number
	move.l	#%00000000000000000000000000111111,d1
	mulu.w	#6,d0
	lsl.l	d0,d1
	lea.l	Draw_green_square,a0	; Show participant row
	jsr	Show_mask_tactic
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Show possible magic targets in tactic window ]
; All registers are restored
;*****************************************************************************
Show_magic_tactic:
	movem.l	d0/a0,-(sp)
	jsr	Show_active_member		; Show active member
	btst	#4,VBL_counter+1		; Alternate
	bne	.Exit
	move.l	Tactic_mask,d0		; Show possible attacks
	lea.l	Draw_green_square,a0
	jsr	Show_mask_tactic
.Exit:	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Show possible attacks in tactic window ]
; All registers are restored
;*****************************************************************************
Show_attack_tactic:
	movem.l	d0/a0,-(sp)
	jsr	Show_active_member		; Show active member
	btst	#4,VBL_counter+1		; Alternate
	bne	.Alt
	move.l	Tactic_mask,d0		; Show possible attacks
	lea.l	Draw_green_square,a0
	jsr	Show_mask_tactic
	bra	.Exit
.Alt:	move.l	Active_participant,a0
	cmp.b	#Close_range_action,Part_action(a0)	; Attacking ?
	beq.s	.Yes
	cmp.b	#Long_range_action,Part_action(a0)
	bne.s	.Exit
.Yes:	jsr	Show_active_target		; Show current target
.Exit:	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Show possible moves in tactic window ]
; All registers are restored
;*****************************************************************************
Show_move_tactic:
	movem.l	d0/a0,-(sp)
	jsr	Show_active_member		; Show active member
	btst	#4,VBL_counter+1		; Alternate
	bne	.Alt
	move.l	Tactic_mask,d0		; Show possible moves
	lea.l	Draw_green_square,a0
	jsr	Show_mask_tactic
	move.l	Target_mask,d0		; Show occupied targets
	lea.l	Draw_red_cross,a0
	jsr	Show_mask_tactic
	bra	.Exit
.Alt:	move.l	Active_participant,a0
	cmp.b	#Move_action,Part_action(a0)	; Moving ?
	bne.s	.Exit
	jsr	Show_active_target		; Show current target
.Exit:	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Show active member in tactic window ]
; All registers are restored
;*****************************************************************************
Show_active_member:
	movem.l	d0-d4/a0,-(sp)
	move.l	Active_participant,a0
	move.w	Part_X(a0),d0		; Calculate screen coordinates
	move.w	Part_Y(a0),d1
	lsl.w	#4,d0
	mulu.w	#Tactic_cell_height,d1
	addi.w	#Tactic_X,d0
	addi.w	#Tactic_Y,d1
	moveq.l	#16,d2			; Draw rectangle
	moveq.l	#Tactic_cell_height,d3
	moveq.l	#Yellow,d4
	jsr	Draw_rectangle
	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Show active member's target in tactic window ]
;   IN : a0 - Pointer to active character's participant data (.l)
; All registers are restored
;*****************************************************************************
Show_active_target:
	movem.l	d0-d4/d7/a0-a2,-(sp)
	cmp.b	#Cast_spell_action,Part_action(a0)	; Magic ?
	bmi	.One
	moveq.l	#0,d2			; Get target mode
	move.b	Part_target+6(a0),d2
	cmp.b	#Item_targmode,d2		; Show anything ?
	bmi.s	.Yes
	cmp.b	#Special_targmode,d2	; Special target ?
	bne	.Exit
	lea.l	Spell_exception_table,a1	; Yes -> Seek
	moveq.l	#0,d0
	move.b	Part_target+4(a0),d0
	moveq.l	#0,d1
	move.b	Part_target+5(a0),d1
.Again:	cmp.l	#-1,(a1)			; End of table ?
	beq	.Exit
	cmp.w	Xspell_class(a1),d0		; Right class ?
	bne.s	.Next1
	cmp.w	Xspell_number(a1),d1	; Right spell ?
	bne.s	.Next1
	move.l	Xspell_target_display(a1),a1	; Yes -> Do exception
	jsr	(a1)
	bra	.Exit
.Next1:	lea.l	Xspell_data_size(a1),a1	; Next exception
	bra.s	.Again
.Yes:	move.b	.Table(pc,d2.w),d2		; Show whom ?
	lea.l	Combat_matrix,a1		; Filter target mask
	move.l	Part_target(a0),d0
	moveq.l	#0,d1
	moveq.l	#30-1,d7
.Loop2:	tst.l	(a1)			; Anyone there ?
	beq.s	.Next2
	move.l	(a1),a2			; Yes -> Filter
	cmp.b	Part_type(a2),d2
	beq.s	.Next2
	bclr	d1,d0
.Next2:	addq.l	#4,a1
	addq.w	#1,d1
	dbra	d7,.Loop2
	lea.l	Draw_red_rectangle,a0	; Show targets
	jsr	Show_mask_tactic
	bra.s	.Exit
.Table:	dc.b 1,2,1,2,1,2			; Table
	even
.One:	moveq.l	#0,d0			; Get target
	move.w	Part_target(a0),d0
	bmi.s	.Exit
.Do:	jsr	Calculate_tactic_coordinates
	moveq.l	#16,d2			; Draw rectangle
	moveq.l	#Tactic_cell_height,d3
	moveq.l	#Light_red,d4
	jsr	Draw_rectangle
.Exit:	movem.l	(sp)+,d0-d4/d7/a0-a2
	rts

;*****************************************************************************
; [ Show target of Blink spell in tactic window ]
;   IN : a0 - Pointer to active character's participant data (.l)
; All registers are restored
;*****************************************************************************
Show_blink_target:
	movem.l	d0-d4,-(sp)
	btst	#4,VBL_counter+1		; Alternate
	bne.s	.Alt
	move.w	Part_target(a0),d0		; Target member
	bra.s	.Do
.Alt:	move.w	Part_target+2(a0),d0	; Destination
.Do:	jsr	Calculate_tactic_coordinates
	moveq.l	#16,d2			; Draw rectangle
	moveq.l	#Tactic_cell_height,d3
	moveq.l	#Light_red,d4
	jsr	Draw_rectangle
	movem.l	(sp)+,d0-d4
	rts

;*****************************************************************************
; [ Show squares from mask in tactic window ]
;   IN : d0 - Tactical location number {0...29} (.w)
;  OUT : d0 - Screen X-coordinate (.w)
;        d1 - Screen Y-coordinate (.w)
; Changed registers : d0,d1
;*****************************************************************************
Calculate_tactic_coordinates:
	divu.w	#6,d0			; Calculate tactic coordinates
	move.w	d0,d1
	swap	d0
	lsl.w	#4,d0			; Calculate screen coordinates
	mulu.w	#Tactic_cell_height,d1
	addi.w	#Tactic_X,d0
	addi.w	#Tactic_Y,d1
	rts

;*****************************************************************************
; [ Show squares from mask in tactic window ]
;   IN : d0 - Mask (.l)
;        a0 - Pointer to draw routine (.l)
; All registers are restored
;*****************************************************************************
Show_mask_tactic:
	movem.l	d0/d1/d4-d7,-(sp)
	move.w	#Tactic_Y,d1		; Do
	move.l	d0,d4
	moveq.l	#0,d5
	moveq.l	#5-1,d7
.Loop_Y:	move.w	#Tactic_X,d0
	moveq.l	#6-1,d6
.Loop_X:	btst	d5,d4			; In mask ?
	beq.s	.Next_X
	jsr	(a0)			; Yes -> Draw
.Next_X:	addq.w	#1,d5			; Next X
	addi.w	#16,d0
	dbra	d6,.Loop_X
	addi.w	#Tactic_cell_height,d1	; Next Y
	dbra	d7,.Loop_Y
	movem.l	(sp)+,d0/d1/d4-d7
	rts

;*****************************************************************************
; [ Tactic window mask display routines ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
Draw_green_square:
	movem.l	d0-d4,-(sp)
	addq.w	#1,d0
	addq.w	#1,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#14-1,d2
	addi.w	#Tactic_cell_height-3,d3
	moveq.l	#Light_green,d4
	jsr	Draw_box
	movem.l	(sp)+,d0-d4
	rts

Draw_red_cross:
	movem.l	d4-d7/a0,-(sp)
	moveq.l	#Dark_red,d4
	moveq.l	#1,d5
	moveq.l	#1,d6
	moveq.l	#Tactic_cell_height,d7
	lea.l	Red_cross,a0
	jsr	Put_masked_silhouette
	movem.l	(sp)+,d4-d7/a0
	rts

Draw_red_rectangle:
	movem.l	d2-d4,-(sp)
	moveq.l	#16,d2
	moveq.l	#Tactic_cell_height,d3
	moveq.l	#Light_red,d4
	jsr	Draw_rectangle
	movem.l	(sp)+,d2-d4
	rts

;*****************************************************************************
; [ Tactic window selector module ]
; All registers are restored
;*****************************************************************************
TacticSel_DisInit:
	jsr	Destroy_ghosts		; Kill!
	move.w	#-1,Selected_tactic		; Clear
	move.w	#-1,Current_ghost_index
	move.w	ItemSelect_prompt,d0	; Print prompt
	jsr	Print_prompt
	jmp	Update_screen

TacticSel_DisExit:
	jsr	Destroy_ghosts		; Kill !
	jsr	Erase_PA			; Erase text area
	jmp	Update_screen

TacticSel_DisUpd:
	jsr	Draw_tactic_window		; Display
	move.l	Tactic_draw_vector,d0	; Extra tactical display
	beq.s	.Exit
	movea.l	d0,a0
	jsr	(a0)
.Exit:	jsr	Draw_tactic_icons		; Icons
	jmp	Basic_DisUpd		; The usual

Tactic_clicked:
	jsr	Get_tactic_index		; Get index
	tst.w	d0
	bmi	.Exit
	jsr	Wait_4_unclick
	move.w	d0,d1
	lea.l	Combat_matrix,a0		; Look in matrix
	lsl.w	#2,d0
	add.w	d0,a0
	move.l	Tactic_mask,d0		; Can be clicked on ?
	btst	d1,d0
	beq.s	.Done
	move.w	d1,Selected_tactic		; Yes -> Store
	Pop	Module			; Exit
.Done:	jsr	Tactic_touched		; Touch
.Exit:	rts

Tactic_touched:
	jsr	Get_tactic_index		; Get index
	tst.w	d0
	bmi	.Exit
	move.w	d0,d1
	cmp.w	Current_ghost_index,d0	; Already being shown ?
	bne.s	.New
	jsr	Set_ghost_positions		; Yes -> Update positions
	bra	.Clip
.New:	jsr	Destroy_ghosts		; Destroy previous
	lea.l	Combat_matrix,a0		; Look in matrix
	lsl.w	#2,d0
	add.w	d0,a0
	tst.l	(a0)			; Anything there ?
	beq	.Exit
	move.w	d1,Current_ghost_index	; Store
	move.l	(a0),a0			; Make new one
	jsr	Create_tactic_name
	jsr	Create_tactic_strength
.Clip:	tst.b	Second_ghost		; One or two ?
	bne.s	.Two
	lea.l	Ghost1_HDOB,a0		; One -> Clip name
	move.w	HDOB_drawY(a0),d0
	cmp.w	#Tactic_Y,d0
	bpl.s	.Exit
	move.w	#Tactic_Y,HDOB_drawY(a0)
	bra.s	.Exit
.Two:	lea.l	Ghost1_HDOB,a0		; Two -> Clip name
	move.w	HDOB_drawY(a0),d0
	cmp.w	#Tactic_Y+Char_height+2,d0
	bpl.s	.Ok
	move.w	#Tactic_Y+Char_height+2,HDOB_drawY(a0)
.Ok:	lea.l	Ghost2_HDOB,a0		; Clip strength
	move.w	HDOB_drawY(a0),d0
	cmp.w	#Tactic_Y,d0
	bpl.s	.Exit
	move.w	#Tactic_Y,HDOB_drawY(a0)
.Exit:	rts

;***************************************************************************
; [ Get tactic index under mouse ]
;  OUT : d0 - Tactic index (.w)
; Changed registers : d0
;***************************************************************************
Get_tactic_index:
	move.l	d1,-(sp)
	move.w	Mouse_X,d0		; Get mouse coordinates
	move.w	Mouse_Y,d1
	subi.w	#Tactic_X,d0		; Translate
	subi.w	#Tactic_Y,d1
	lsr.w	#4,d0			; Scale
	ext.l	d1
	divs.w	#Tactic_cell_height,d1
	cmp.w	#5,d0			; Out of range ?
	bhi.s	.Out
	cmp.w	#4,d1
	bhi.s	.Out
	mulu.w	#6,d1			; Calculate index
	add.w	d1,d0
	bra.s	.Exit
.Out:	moveq.l	#-1,d0			; Yes
.Exit:	move.l	(sp)+,d1
	rts

;***************************************************************************
; [ Create tactic name ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are restored
; Note :
;  - This is an internal routine.
;***************************************************************************
Create_tactic_name:
	movem.l	d0/d1/a0,-(sp)
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	bne.s	.Monster
	move.b	Part_handle(a0),d0		; Party -> Get character data
	Get	d0,a0
	move.w	Body_conditions(a0),d1	; Possible active ?
	andi.w	#Active_mask,d1
	bne.s	.No
	move.w	#White,Ink_colour		; Yes
	bra.s	.Do
.No:	move.w	#Lighter_blue,Ink_colour	; No
	bra.s	.Do
.Monster:	move.w	#Light_red,Ink_colour	; Monster
	move.b	Part_handle(a0),d0		; Get character data
	Get	d0,a0
.Do:	lea.l	Char_name(a0),a0		; Create ghost string
	jsr	Create_1st_ghost
	Free	d0
	movem.l	(sp)+,d0/d1/a0
	rts

;***************************************************************************
; [ Create tactic strength ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are restored
; Notes :
;  - Theoretically, this routine will always be called after
;    [ Create_tactic_name ]. Therefore the ink colour is already set.
;***************************************************************************
Create_tactic_strength:
	movem.l	d0-d3/d6/d7/a0/a5,-(sp)
	move.l	a0,a5			; Save
	cmp.b	#1,Part_type(a5)		; Party or monster ?
	beq.s	.Do
	tst.b	Show_monsters		; Able to see this ?
	bne.s	.Do
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	bne	.Exit
.Do:	Get	Part_handle(a5),a0
	move.w	Life_points+Maximum(a0),d3	; Get maximum LP
	add.w	Life_points+Magic(a0),d3
	move.w	Life_points(a0),d2		; Get normal LP
	Free	Part_handle(a5)
	cmp.w	d3,d2			; More as	maximum ?
	bmi.s	.Less
	move.w	d3,d2			; Yes -> Full
.Less:	moveq.l	#3,d7			; Make string
	lea.l	Number,a0
	move.w	d2,d0			; Convert	normal LP
	jsr	DecL_convert
	move.b	#"/",(a0)+		; Correction
	move.w	d3,d0			; Convert	maximum LP
	jsr	DecL_convert
	lea.l	Number,a0			; Create ghost string
	jsr	Create_2nd_ghost
.Exit:	movem.l	(sp)+,d0-d3/d6/d7/a0/a5
	rts
