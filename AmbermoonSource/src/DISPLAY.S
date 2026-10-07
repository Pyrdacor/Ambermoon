; Display routines
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
; [ Show layout ]
;   IN : d0 - Layout number (.w)
; All registers are	restored
;*****************************************************************************
Show_layout:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,-(sp)
	moveq.l	#Layout_file,d1		; Load packed layout
	jsr	Load_subfile
	move.b	d0,d2
	jsr	Claim_pointer
	move.l	d0,a0
	move.l	#(199-Middle_Y)*120+Default_safety_factor,d0	; Make buffer
	jsr	Allocate_CHIP
	move.b	d0,d3
	jsr	Claim_pointer
	move.l	d0,a1
	move.b	d2,d0			; Copy
	jsr	Get_memory_length
	jsr	Copy_memory
	move.b	d2,d0			; Remove layout
	jsr	Free_pointer
	jsr	Free_memory
	move.l	a1,a0			; Unpack layout
	jsr	Decompress
	move.b	d3,d0			; Shrink memory block
	move.l	#(199-Middle_Y)*120,d1
	jsr	Shrink_memory
	moveq.l	#0,d0			; Show layout
	moveq.l	#Middle_Y+1,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#20,d6
	move.w	#199-Middle_Y,d7
	jsr	Put_unmasked_block
	move.b	d3,d0			; Free pointers
	jsr	Free_pointer
	jsr	Free_memory
	move.w	(sp)+,d0
; ---------- Initialize layout --------------------
	lsl.w	#3,d0
	move.l	.Layout_info-8(pc,d0.w),Layout_ptr	; Set object branch
	move.l	.Layout_info-8+4(pc,d0.w),d0		; Initialize display
	beq.s	.Exit
	move.l	d0,a0
	jsr	(a0)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

.Layout_info:
	dc.l Map2D_L2,Init_map_layout	; 2D map
	dc.l Inv2_L2,Init_Inv2_layout	; Inventory 2
	dc.l Lay3_L2,Init_Chest_layout	; Chest etc.
	dc.l Combat_L2,Init_Combat_layout	; Combat
	dc.l Map3D_L2,Init_map_layout	; 3D map
	dc.l Inv1_L2,0			; Inventory 1
	dc.l 0,Init_ShowPicTxt_layout	; Show pic + text
	dc.l Lay3_L2,Init_Dia_layout		; Dialogue
	dc.l Control_area,Init_RiddleM_layout	; Riddle-mouth
	dc.l BattleOrder_L2,Init_BO_layout	; Battle order
	dc.l Automapper_L2,0		; Automapper

;*****************************************************************************
; [ Layout initialization routines ]
; All registers are	restored
;*****************************************************************************
Init_map_layout:
	moveq.l	#Window_colour,d4
	move.w	#208,d0			; Clear spell & item area
	move.w	#49,d1
	move.w	#303,d2
	move.w	#128,d3
	jsr	Draw_box
	rts

Init_Inv2_layout:
	moveq.l	#Window_colour,d4
	move.w	#20,d0			; Clear text area
	move.w	#50,d1
	move.w	#182,d2
	move.w	#70,d3
	jsr	Draw_box
	rts

Init_Chest_layout:
	moveq.l	#Window_colour,d4
	move.w	#111,d0			; Clear large text area
	move.w	#44,d1
	move.w	#302,d2
	move.w	#99,d3
	jsr	Draw_box
	move.w	#110,d0			; Clear small text area
	move.w	#101,d1
	move.w	#303,d2
	move.w	#121,d3
	jsr	Draw_box
	rts

Init_Combat_layout:
	jmp	Erase_PA

Init_ShowPicTxt_layout:
	moveq.l	#Window_colour,d4
	move.w	#16,d0			; Clear text area
	move.w	#138,d1
	move.w	#303,d2
	move.w	#192,d3
	jsr	Draw_box
	rts

Init_Dia_layout:
	moveq.l	#Window_colour,d4
	move.w	#15,d0			; Clear large text area
	move.w	#43,d1
	move.w	#191,d2
	move.w	#122,d3
	jsr	Draw_box
	move.w	#208,d0			; Clear ID area
	move.w	#43,d1
	move.w	#303,d2
	move.w	#122,d3
	jsr	Draw_box
	rts

Init_RiddleM_layout:
	moveq.l	#Window_colour,d4
	move.w	#16,d0			; Clear text area
	move.w	#50,d1
	move.w	#191,d2
	move.w	#193,d3
	jsr	Draw_box
	rts

Init_BO_layout:
	moveq.l	#Window_colour,d4
	move.w	#16,d0			; Clear portrait area
	move.w	#43,d1
	move.w	#16+288-1,d2
	move.w	#122,d3
	jsr	Draw_box
	move.w	#16,d0			; Clear text area
	move.w	#144,d1
	move.w	#193,d2
	move.w	#193,d3
	jsr	Draw_box
	rts

;*****************************************************************************
; [ Force status display update ]
;   IN : d7 - Member number [1...6] (.w)
; All registers are	restored
;*****************************************************************************
Force_status_update:
	movem.l	d7/a0,-(sp)
	lea.l	Shadow_data,a0	; Clear data
	subq.w	#1,d7
	mulu.w	#Shadow_data_size,d7
	move.l	#$00ffffff,0(a0,d7.w)
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Display status block ]
; All registers are	restored
;*****************************************************************************
Display_status_block:
	movem.l	d0-d2/d4-d7/a0,-(sp)
	moveq.l	#0,d0			; Display left edge
	moveq.l	#0,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#1,d6
	moveq.l	#36,d7
	lea.l	Status_L,a0
	jsr	Put_unmasked_block
	lea.l	Status_M,a0		; Display status bars
	addi.w	#48,d0
	moveq.l	#6-1,d2
.Loop1:	jsr	Put_unmasked_block
	addi.w	#48,d0
	dbra	d2,.Loop1
	lea.l	Status_R,a0		; Display right edge
	subi.w	#32,d0
	jsr	Put_unmasked_block
	moveq.l	#1,d7			; Display portraits
.Loop2:	jsr	Display_portrait
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop2
	movem.l	(sp)+,d0-d2/d4-d7/a0
	rts

;*****************************************************************************
; [ Update status block ]
; All registers are	restored
;*****************************************************************************
Update_status_block:          
	movem.l	d0/d1/d7/a0-a4,-(sp)
	lea.l	Shadow_data,a1
	lea.l	Party_handles,a2
	lea.l	Party_status_icons,a3
	lea.l	Shadow_update,a4
; --------- Handle change of active member --------
	move.w	Shadow_active,d0		; New active member	?
	move.w	Active_member,d1
	cmp.w	d0,d1
	beq.s	.Cont
	move.w	d1,Shadow_active		; Update
	tst.w	d0			; Redraw deactivated member
	beq.s	.Skip
	subq.w	#1,d0
	mulu.w	#Shadow_data_size,d0
	move.l	#$00ffffff,0(a1,d0.w)
.Skip:	tst.w	d1			; Redraw activated member
	beq.s	.Cont
	subq.w	#1,d1
	mulu.w	#Shadow_data_size,d1
	move.l	#$00ffffff,0(a1,d1.w)
; --------- Update all party members --------------
.Cont:	moveq.l	#1,d7
.Loop:	tst.b	(a2)			; Anyone there ?
	bne.s	.Yes
	tst.b	(a1)
	beq.s	.Next
	clr.b	(a1)			; Update
	bset	#0,(a4)			; Mark
	bra.s	.Do1
.Yes	move.b	(a2),d0			; New character ?
	cmp.b	(a1),d0
	beq.s	.Old
	move.b	d0,(a1)			; Update
	bset	#0,(a4)			; Mark
	bra.s	.Do1
.Old:	btst	#0,(a4)			; Update marked ?
	beq.s	.Do2
	bclr	#0,(a4)
.Do1:	jsr	Display_portrait		; Display
.Do2:	jsr	Update_member_status
.Next:	addq.w	#Shadow_data_size,a1	; Next member
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d1/d7/a0-a4
	rts

;*****************************************************************************
; [ Display member portrait ]
;   IN : d7 - Member number [1...6] (.w)
; All registers are	restored
;*****************************************************************************
Display_portrait:
	movem.l	d0-d7/a0-a2/a5,-(sp)
	opt	o11-				; (not optimized by the original assembler)
	lea.l	-Display_member_LDS(sp),sp	; Create local variables
	opt	o11+
	move.l	sp,a5
	opt	o2-				; (not optimized by the original assembler)
	move.w	d7,Displayed_member(a5)	; Store
	opt	o2+
	subq.w	#1,d7			; Calculate X-coordinate
	mulu.w	#48,d7
	addi.w	#16,d7
	move.w	d7,Displayed_X(a5)		; Store
; --------- Display status block parts ------------
	move.w	d7,d0			; Display top
	moveq.l	#0,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#1,d7
	lea.l	Status_TB,a0
	jsr	Put_unmasked_block
	moveq.l	#35,d1			; Display bottom
	jsr	Put_unmasked_block
; --------- Display portrait ----------------------
	lea.l	Party_handles,a0		; Anyone there ?
	opt	o2-				; (not optimized by the original assembler)
	move.w	Displayed_member(a5),d0
	opt	o2+
	move.b	-1(a0,d0.w),d3
	bne.s	.Yes
	move.w	Displayed_X(a5),d0		; Display empty portrait
	moveq.l	#1,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#34,d7
	lea.l	Empty_portrait,a0
	jsr	Put_unmasked_block
	bra	.Exit
.Yes:	Push	PA,Status_PA
	move.w	#Lighter_blue,Ink_colour	; Default ink
	Get	d3,a1			; Get character data
	move.w	Body_conditions(a1),d0	; Dead or alive ?
	andi.w	#Dead_mask,d0
	beq.s	.Alive
	move.w	Displayed_X(a5),d0		; Display death mask
	moveq.l	#1,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#34,d7
	lea.l	Death_mask,a0
	jsr	Put_unmasked_block
	bra	.Print
.Alive:	lea.l	Portrait_handles,a0		; Get portrait address
	opt	o2-				; (not optimized by the original assembler)
	move.w	Displayed_member(a5),d0
	opt	o2+
	move.b	-1(a0,d0.w),d4
	Get	d4,a0
	move.w	Displayed_X(a5),d0		; Display real portrait
	moveq.l	#1,d1
	moveq.l	#5,d5
	moveq.l	#2,d6
	moveq.l	#34,d7
	jsr	Put_unmasked_block
	Free	d4
; ---------- Determine ink ------------------------
	opt	o2-				; (not optimized by the original assembler)
	move.w	Displayed_member(a5),d0	; Active character ?
	opt	o2+
	cmp.w	Active_member,d0
	bne.s	.No
	move.w	#Yellow,Ink_colour		; Yes
	bne.s	.Print
.No:	move.w	Body_conditions(a1),d0	; No -> Possible active ?
	andi.w	#Active_mask,d0
	bne.s	.Print
	move.w	#Red,Ink_colour		; Yes
; --------- Print character's name ----------------
.Print:	lea.l	Char_name(a1),a0		; Duplicate first five
	lea.l	Temp_name,a2		;  letters of member's name
	moveq.l	#5-1,d7
.Loop:	move.b	(a0)+,(a2)+
	dbeq	d7,.Loop
	Free	d3
	move.w	Displayed_X(a5),d0		; Display	character	name
	addq.w	#2,d0
	moveq.l	#31,d1
	moveq.l	#30,d2
	lea.l	Temp_name,a0
	jsr	Print_centered_string
	Pop	PA
	opt	o11-				; (not optimized by the original assembler)
.Exit:	lea.l	Display_member_LDS(sp),sp
	opt	o11+
	movem.l	(sp)+,d0-d7/a0-a2/a5
	rts

	rsreset
Displayed_member:	rs.w 1
Displayed_X:	rs.w 1
Display_member_LDS:	rs.b 0

;*****************************************************************************
; [ Update member status ]
;   IN : d7 - Member number [1...6] (.w)
;        a1 - Pointer to shadow data (.l)
;        a3 - Pointer to status icons (.l)
;        a4 - Pointer to update list (.l)
; All registers are	restored
;*****************************************************************************
Update_member_status:
	movem.l	d0-d7/a0/a2,-(sp)
	subq.w	#Display_member_LDS,sp	; Create local variables
	move.l	sp,a5
	move.w	d7,Displayed_member(a5)	; Store
	subq.w	#1,d7			; Calculate X-coordinate
	mulu.w	#48,d7
	addi.w	#16,d7
	move.w	d7,Displayed_X(a5)		; Store
; --------- Get character data --------------------
	lea.l	Party_handles,a0		; Anyone there ?
	move.w	Displayed_member(a5),d0
	move.b	-1(a0,d0.w),d0
	bne.s	.Yes
	move.w	Displayed_X(a5),d0		; Erase icon
	addi.w	#32,d0
	moveq.l	#1,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	lea.l	Status_M+6,a0
	jsr	Put_unmasked_icon
	moveq.l	#19,d1			; Erase bars
	lea.l	Status_M+19*6,a0
	jsr	Put_unmasked_icon
	bra	.Exit
.Yes:	Get	d0,a2			; Get character data
	move.w	Body_conditions(a2),d0	; Dead or alive ?
	andi.w	#Dead_mask,d0
	beq.s	.Alive
	cmp.b	#Dead_icon,Shadow_icon(a1)	; Already dead ?
	bne.s	.Do0
	btst	#2,(a4)			; Update marked ?
	beq	.No_bars
	bclr	#2,(a4)
.Do0:	move.w	Displayed_X(a5),d0		; Erase bars
	addi.w	#32,d0
	moveq.l	#19,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	lea.l	Status_M+19*6,a0
	jsr	Put_unmasked_icon
	move.b	#Dead_icon,(a3)		; Dead !
	bset	#2,(a4)			; Mark
	bra	.No_bars
; --------- Update bars ---------------------------
.Alive:	cmp.b	#Dead_icon,(a3)		; Dead icon still there ?
	bne.s	.No_cross
	clr.b	(a3)			; No -> Remove
.No_cross:	move.w	Life_points+Maximum(a2),d0	; Get maximum LP
	add.w	Life_points+Magic(a2),d0
	move.w	Life_points(a2),d7		; Get normal LP
	cmp.w	d0,d7			; More as	maximum ?
	bmi.s	.Less1
	moveq.l	#16,d7			; Full bar
	bra.s	.Do1
.Less1:	ext.l	d7			; Calculate height of bar
	lsl.l	#4,d7
	tst.w	d0
	beq.s	.Zero1
	divu.w	d0,d7
	bne.s	.Do1
.Zero1:	moveq.l	#1,d7
.Do1:	tst.b	Spell_class_counter(a2)	; ANY magic ?
	bne.s	.Magic
	moveq.l	#0,d6			; No!
	bra.s	.Do2
.Magic:	move.w	Power_points+Maximum(a2),d0	; Get maximum PP
	add.w	Power_points+Magic(a2),d0
	move.w	Power_points(a2),d6		; Get normal PP
	cmp.w	d0,d6			; More as	maximum ?
	bmi.s	.Less2
	moveq.l	#16,d6			; Full bar
	bra.s	.Do2
.Less2:	ext.l	d6			; Calculate height of bar
	lsl.l	#4,d6
	tst.w	d0
	beq.s	.Zero2
	divu.w	d0,d6
	bne.s	.Do2
.Zero2:	moveq.l	#1,d6
.Do2:	cmp.b	Shadow_LP(a1),d7		; Change ?
	bne.s	.Change1
	cmp.b	Shadow_PP(a1),d6
	bne.s	.Change1
	btst	#2,(a4)			; Update marked ?
	beq	.No_bars
	bclr	#2,(a4)
	bra.s	.Update1
.Change1:	move.b	d7,Shadow_LP(a1)		; Update
	move.b	d6,Shadow_PP(a1)
	bset	#2,(a4)			; Mark
.Update1:	move.w	Displayed_X(a5),d0		; Erase bars
	addi.w	#32,d0
	moveq.l	#19,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	lea.l	Status_M+19*6,a0
	jsr	Put_unmasked_icon
	move.w	Displayed_X(a5),d0		; Draw LP bar
	addi.w	#34,d0
	move.w	d0,d2
	moveq.l	#34,d3
	move.w	d3,d1
	sub.w	d7,d1
	addq.w	#1,d1
	moveq.l	#7,d4
	jsr	Draw_box
	addq.w	#1,d0
	move.w	Displayed_X(a5),d2
	addi.w	#37,d2
	moveq.l	#6,d4
	jsr	Draw_box
	tst.w	d6			; Any PP ?
	beq.s	.No_bars
	move.w	Displayed_X(a5),d0		; Draw PP bar
	addi.w	#34+8,d0
	move.w	d0,d2
	moveq.l	#34,d3
	move.w	d3,d1
	sub.w	d6,d1
	addq.w	#1,d1
	moveq.l	#24,d4
	jsr	Draw_box
	addq.w	#1,d0
	move.w	Displayed_X(a5),d2
	addi.w	#37+8,d2
	moveq.l	#23,d4
	jsr	Draw_box
; --------- Show status icon ----------------------
.No_bars:	move.b	(a3),d7			; Change ?
	cmp.b	Shadow_icon(a1),d7
	bne	.Change2
	btst	#1,(a4)			; Update marked ?
	beq	.Done
	bclr	#1,(a4)
	bra.s	.Update2
.Change2:	move.b	d7,Shadow_icon(a1)		; Update
	bset	#1,(a4)			; Mark
.Update2:	move.w	Displayed_X(a5),d0		; Erase icon
	addi.w	#32,d0
	moveq.l	#1,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	lea.l	Status_M+6,a0
	jsr	Put_unmasked_icon
	tst.b	d7			; Any icon ?
	beq.s	.Done
	lea.l	Status_icons,a0		; Get icon address
	andi.w	#$00ff,d7
	subq.w	#1,d7
	mulu.w	#Icon_size,d7
	add.l	d7,a0
	move.w	Displayed_X(a5),d0		; Display icon
	addi.w	#32,d0
	moveq.l	#1,d1
	moveq.l	#Screen_depth,d5
	jsr	Put_masked_icon
; --------- Exit ----------------------------------
.Done:	lea.l	Party_handles,a0		; Free
	move.w	Displayed_member(a5),d0
	move.b	-1(a0,d0.w),d0
	jsr	Free_pointer
.Exit:	addq.w	#Display_member_LDS,sp
	movem.l	(sp)+,d0-d7/a0/a2
	rts

;*****************************************************************************
; [ Update damage & magic display ]
; All registers are restored
;*****************************************************************************
Update_damage_magic:          
	movem.l	d0/d7/a0,-(sp)
; --------- Update damage bursts ------------------
	Push	PA,Status_PA
	lea.l	Char_damage,a0
	moveq.l	#1,d7
.Loop1:	tst.b	6(a0)			; Any damage ?
	beq.s	.Next1
	moveq.l	#0,d0			; Yes -> display it
	move.b	(a0),d0
	jsr	Display_damage
	subq.b	#1,6(a0)			; Count down
	bne.s	.Next1
	jsr	Force_status_update		; Erase
.Next1:	addq.l	#1,a0			; Next member
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop1
	Pop	PA
; --------- Update magic sparkles -----------------
	lea.l	Magic_counters,a0
	moveq.l	#1,d7
.Loop2:	tst.b	(a0)+			; Any sparkles left ?
	beq.s	.Next2
	jsr	Force_status_update		; Yes -> display it
	jsr	Display_magic
.Next2:	addq.w	#1,d7			; Next member
	cmpi.w	#6+1,d7
	bmi.s	.Loop2
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Wait for sparkles to end ]
; All registers are restored
;*****************************************************************************
Wait_4_sparkles:
	movem.l	d7/a0,-(sp)
	bra.s	.Entry
.Wait:	jsr	Update_display		; Update
	jsr	Switch_screens
.Entry:	lea.l	Magic_counters,a0		; All sparkles gone ?
	moveq.l	#6-1,d7
.Loop:	tst.b	(a0)+
	bne.s	.Wait
	dbra	d7,.Loop
	jsr	Copy_screen		; Yes
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Display damage ]
;   IN : d0 - Amount of damage (.w)
;        d7 - Member number [1...6] (.w)
; All registers are restored
;*****************************************************************************
Display_damage:     
	movem.l	d0-d7/a0,-(sp)
	move.w	d0,d2
	subq.w	#1,d7			; Calculate X-coordinate
	mulu.w	#48,d7
	addi.w	#16,d7
	move.w	d7,d4
	move.w	d4,d0			; Display damage burst
	moveq.l	#1,d1
	moveq.l	#5,d5
	moveq.l	#2,d6
	moveq.l	#26,d7
	lea.l	Damage_star,a0
	jsr	Put_masked_block
	tst.w	d2			; Any damage ?
	beq.s	.Exit
	move.w	#White,Ink_colour		; Set ink
	moveq.l	#0,d0			; Convert number
	move.w	d2,d0
	moveq.l	#2,d7
	lea.l	Temp_number,a0
	jsr	DecL_convert
	move.w	d4,d0			; Print damage
	addi.w	#11,d0
	moveq.l	#11,d1
	moveq.l	#12,d2
	lea.l	Temp_number,a0
	jsr	Print_centered_string
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Display magic sparkles ]
;   IN : d7 - Member number [1...6] (.w)
; All registers are restored
;*****************************************************************************
Display_magic:      
	movem.l	d0-d2/d4-d7/a0-a2,-(sp)
	lea.l	Magic_counters,a0		; Get current counter value
	moveq.l	#0,d4
	move.b	-1(a0,d7.w),d4
	move.w	d7,-(sp)			; Save
	move.w	d7,d5			; Calculate X-coordinate
	mulu.w	#48,d5
	subi.w	#32,d5
	lea.l	Sparkle_CA,a0		; Install clip area
	move.w	d5,CA_X1(a0)
	move.w	d5,CA_X2(a0)
	add.w	#32-1,CA_X2(a0)
	jsr	Push_CA
	lea.l	Sparkle_data,a1		; Find sparkle data
	subq.w	#1,d7
	mulu.w	#Max_sparkles*Sparkle_data_size,d7
	add.w	d7,a1
	lea.l	Magic_stars,a2		; Do sparkles
	move.w	#9*5*2,d6
	moveq.l	#Max_sparkles-1,d7
.Loop:	moveq.l	#0,d2			; Get frame number
	move.b	Sparkle_frame(a1),d2
	beq	.Next			; Anything there ?
	subq.w	#1,d2			; Get frame address
	lsr.w	#2,d2
	mulu.w	d6,d2
	lea.l	0(a2,d2.l),a0
	moveq.l	#0,d0			; Get coordinates
	move.b	Sparkle_X(a1),d0
	add.w	d5,d0
	subq.w	#4,d0
	move.b	Sparkle_Y(a1),d1
	ext.w	d1
	movem.l	d5-d7,-(sp)		; Display sparkle
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#9,d7
	jsr	Put_masked_block
	movem.l	(sp)+,d5-d7
	addq.w	#Sparkle_speed,d1		; Move down
	cmp.w	#1+34,d1			; Out ?
	blt.s	.In
	clr.b	Sparkle_frame(a1)		; Out !
	subq.w	#1,d4			; Count down
	bra.s	.Next
.In:	move.b	d1,Sparkle_Y(a1)		; Store new Y-coordinate
	subq.b	#1,Sparkle_frame(a1)	; Next frame
	bne.s	.Next			; Last ?
	subq.w	#1,d4			; Yes -> count down
.Next:	addq.w	#Sparkle_data_size,a1	; Next sparkle
	dbra	d7,.Loop
	Pop	CA			; Remove clip area
	move.w	(sp)+,d7			; Restore
	lea.l	Magic_counters,a0		; Set new counter value
	move.b	d4,-1(a0,d7.w)
	bne.s	.Exit			; All gone ?
	jsr	Force_status_update		; Erase all (other screen)
.Exit:	movem.l	(sp)+,d0-d2/d4-d7/a0-a2
	rts

;*****************************************************************************
; [ Automatic icon switching ]
; All registers are	restored
;*****************************************************************************
AutoIcon_switch:    
	movem.l	d0-d3/d5-d7/a0-a3,-(sp)
	cmpi.w	#AutoIcon_interval,AutoIcon_timer	; Is it time ?
	bmi	.Exit
	clr.w	AutoIcon_timer		; Reset timer
	tst.b	AutoIcon_block		; Activated ?
	bne	.Exit
	lea.l	Party_handles,a0		; Initialize registers
	lea.l	Party_status_icons,a1
	lea.l	AutoIcon_counters,a3
	move.b	Overweight,d5
	moveq.l	#1,d7
.Loop1:	tst.b	(a0)			; Anyone there ?
	beq.s	.Next1
	btst	d7,d5			; Overweight ?
	beq.s	.Not_over
	move.b	#Overweight_icon,(a1)	; Set 16t	icon
	bra.s	.Next1
.Not_over:
	move.b	(a0),d0			; Get body conditions
	jsr	Claim_pointer
	move.l	d0,a2
	move.w	Body_conditions(a2),d1
	move.b	(a0),d0
	jsr	Free_pointer
	move.w	d1,d2			; Character dead ?
	andi.w	#Dead_mask,d2
	bne.s	.Next1
	move.w	(a3),d2			; Load counter
	addq.w	#1,d2			; Increase
	cmpi.w	#Nr_AutoIcons,d2
	bmi.s	.Ok1
	moveq.l	#0,d2
.Ok1:	moveq.l	#Nr_AutoIcons-1,d6
.Loop2:	move.b	.Bit_table(pc,d2.w),d3	; Get condition bit number
	bmi.s	.Next2			; (if any)
	btst	d3,d1			; Condition set ?
	bne.s	.Do_it
.Next2:	addq.w	#1,d2			; Next condition
	cmpi.w	#Nr_AutoIcons,d2
	bmi.s	.Ok2
	moveq.l	#0,d2
.Ok2:	dbra	d6,.Loop2
	clr.b	(a1)			; No icon
	bra.s	.Next1
.Bit_table:
	dc.b Lamed,Poisoned,Petrified,Diseased
	dc.b Aging,Irritated,Mad,Asleep
	dc.b Panicked,Blind,-1,Stoned
	dc.b Exhausted
	even
.Do_it:	move.w	d2,(a3)
	addi.w	#Lamed_icon,d2		; Set icon number
	move.b	d2,(a1)
.Next1:	addq.l	#1,a0			; Next character
	addq.l	#1,a1
	addq.l	#2,a3
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop1
.Exit:	movem.l	(sp)+,d0-d3/d5-d7/a0-a3
	rts

Time_AutoIcon:
	addq.w	#1,AutoIcon_timer
	rts

;*****************************************************************************
; [ Display spell icons ]
; All registers are	restored
;*****************************************************************************
Display_spells:        
	movem.l	d0-d7/a0/a1/a3,-(sp)
	lea.l	Spell_1_duration,a1
	lea.l	Spell_icons,a3
	move.w	#208,d0
	moveq.l	#6-1,d7
.Loop:	move.w	d7,-(sp)
	move.w	(a1),d7			; Get duration
	bne	.Yes			; Any ?
	move.w	#49+57,d1			; No -> Erase
	move.w	d0,d2
	addi.w	#16-1,d2
	move.w	#49+57+24-1,d3
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
	move.w	#49+57,d1			; Draw icon
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
	rts

;*****************************************************************************
; [ Display special items ]
; All registers are	restored
;*****************************************************************************
Display_special_items:
	movem.l	d0-d7/a0,-(sp)
	move.w	#Default_ink,Ink_colour	; Set ink
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq.s	.Cheat
	move.w	Special_item_flags,d3	; No
	bra.s	.Go_on
.Cheat:	moveq.l	#-1,d3			; Yes!
.Go_on:	move.w	d3,d2			; Evaluate changes
	move.w	Previous_SIF,d1
	move.w	d2,Previous_SIF
	eor.w	d1,d2
	move.w	Previous_SIF_changes,d0
	move.w	d2,Previous_SIF_changes
	or.w	d0,d2
; --------- Handle Windchain ----------------------
	btst	#Windchain_bit,d2		; Update windchain ?
	beq.s	.No_windchain
	btst	#Windchain_bit,d3		; Draw or erase ?
	bne.s	.Draw1
	movem.w	d2/d3,-(sp)
	move.w	#208+32,d0		; Erase windchain
	move.w	#49+40,d1
	move.w	#208+32+31,d2
	move.w	#49+40+14,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	movem.w	(sp)+,d2/d3
	bra.s	.No_windchain
.Draw1:	move.w	#208+32,d0		; Display windchain
	move.w	#49+40,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#15,d7
	lea.l	Windchain,a0
	jsr	Put_unmasked_block
.No_windchain:
; --------- Handle Day/Night display --------------
	btst	#Daynight_bit,d2		; Update compass ?
	bne.s	.Change2
	btst	#Daynight_bit,d3		; No -> Present ?
	bne.s	.Draw2
	bra	.No_daynight
.Change2:	btst	#Daynight_bit,d3		; Draw or erase ?
	bne.s	.Draw2
	movem.w	d2/d3,-(sp)
	move.w	#208+64,d0		; Erase day/night display
	move.w	#49+24,d1
	move.w	#208+64+31,d2
	move.w	#49+24+31,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	movem.w	(sp)+,d2/d3
	bra.s	.No_daynight
.Draw2:	lea.l	Daynight_icons,a0		; Select according to time
	move.w	Hour,d0
	move.b	.Table(pc,d0.w),d0
	mulu.w	#32*12,d0
	adda.w	d0,a0
	move.w	#208+64,d0		; Display day/night
	move.w	#49+24,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#32,d7
	jsr	Put_unmasked_block
	bra.s	.No_daynight
.Table:	dc.b 0,0,0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,2,3,3,0,0,0,0
	even
.No_daynight:
; --------- Handle Compass ------------------------
	btst	#Compass_bit,d2		; Update compass ?
	bne.s	.Change3
	btst	#Compass_bit,d3		; No -> Present ?
	bne.s	.Draw3b
	bra	.No_compass
.Change3:	btst	#Compass_bit,d3		; Draw or erase ?
	bne.s	.Draw3a
	movem.w	d2/d3,-(sp)
	move.w	#208,d0			; Erase compass
	move.w	#49+24,d1
	move.w	#208+31,d2
	move.w	#49+24+31,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	movem.w	(sp)+,d2/d3
	bra	.No_compass
.Draw3a:	move.w	#208,d0			; Display compass
	move.w	#49+24,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#32,d7
	lea.l	Compass,a0
	jsr	Put_unmasked_block
	bra.s	.Draw3c
.Draw3b:	movem.w	d2/d3,-(sp)
	move.w	#208,d0			; Erase compass text
	move.w	#49+24+13,d1
	move.w	#208+31,d2
	move.w	#49+24+13+5,d3
	moveq.l	#0,d4
	jsr	Draw_box
	movem.w	(sp)+,d2/d3
.Draw3c:	cmp.b	#2,Current_map_type		; 2D or 3D map ?
	bpl.s	.3D
	move.w	View_direction,d1		; Calculate 2D offset
	addq.w	#1,d1
	mulu.w	#8*(Char_width+1),d1
	subi.w	#13,d1
	bra.s	.Print
.3D:	move.w	Y_angle,d1		; Calculate 3D offset
	neg.w	d1
	andi.w	#slang-1,d1
	addi.w	#slang/4,d1
	mulu.w	#4*8*(Char_width+1),d1
	divu.w	#slang,d1
	subi.w	#13,d1
.Print:	Push	CA,Compass_CA		; Print compass text
	move.w	#-1,Shadow_colour
	move.w	#208,d0
	sub.w	d1,d0
	move.w	#49+24+13,d1
	move.l	Compass_txt_ptr,a0
	jsr	Put_text_line
	clr.w	Shadow_colour
	Pop	CA
.No_compass:
; --------- Handle Coordinates --------------------
	btst	#Coords_bit,d2		; Update coordinates ?
	bne.s	.Change4
	btst	#Coords_bit,d3		; No -> Present ?
	beq	.No_coordinates
.Change4:	movem.w	d2/d3,-(sp)
	move.w	#208,d0			; Erase coordinates
	move.w	#49,d1
	move.w	#208+31,d2
	move.w	#49+15,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	movem.w	(sp)+,d2/d3
	btst	#Coords_bit,d3		; Draw or erase ?
	beq	.No_coordinates
	movem.w	d2/d3,-(sp)
	move.w	Map_Xcoord,d2		; Load coordinates
	move.w	Map_Ycoord,d3
	cmpi.b	#1,Current_map_type		; Wilderness ?
	bne.s	.No_wild
	move.w	World_X,d0		; Adapt coordinates
	mulu.w	Submap_width,d0
	add.w	d0,d2
	move.w	World_Y,d0
	mulu.w	Submap_height,d0
	add.w	d0,d3
.No_wild:	lea.l	X_string+2,a0		; Convert X
	moveq.l	#0,d0
	move.w	d2,d0
	moveq.l	#" ",d6
	moveq.l	#3,d7
	jsr	DecR_convert
	lea.l	X_string,a0		; Print X
	move.w	#208+2,d0
	move.w	#49+1,d1
	jsr	Put_text_line
	lea.l	Y_string+2,a0		; Convert Y
	moveq.l	#0,d0
	move.w	d3,d0
	moveq.l	#" ",d6
	moveq.l	#3,d7
	jsr	DecR_convert
	lea.l	Y_string,a0		; Print Y
	move.w	#208+2,d0
	move.w	#49+8,d1
	jsr	Put_text_line
	movem.w	(sp)+,d2/d3
.No_coordinates:
; --------- Handle Clock --------------------------
	btst	#Clock_bit,d2		; Update clock ?
	bne.s	.Change5
	btst	#Clock_bit,d3		; No -> Present ?
	beq	.No_clock
.Change5:	movem.w	d2/d3,-(sp)
	move.w	#208+64,d0			; Erase coordinates
	move.w	#49,d1
	move.w	#208+64+31,d2
	move.w	#49+15,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	movem.w	(sp)+,d2/d3
	btst	#Clock_bit,d3		; Draw or erase ?
	beq	.No_clock
	lea.l	Time_string,a0
	move.w	Hour,d0			; Convert hour
	moveq.l	#" ",d6
	moveq.l	#2,d7
	jsr	DecR_convert
	move.b	#":",(a0)+		; Correction
	move.w	Minute,d0			; Convert minutes
	moveq.l	#"0",d6
	moveq.l	#2,d7
	jsr	DecR_convert
	lea.l	Time_string,a0		; Print time
	move.w	#208+65,d0
	move.w	#49+5,d1
	jsr	Put_text_line
; --------- Handle Eye ----------------------------
.No_clock:	btst	#Eye_bit,d2		; Update Eye ?
	bne.s	.Change6
	btst	#Eye_bit,d3		; No -> Present ?
	bne.s	.Draw6
	bra	.No_eye
.Change6:	btst	#Eye_bit,d3		; Draw or erase ?
	bne.s	.Draw6
	movem.w	d2/d3,-(sp)
	move.w	#208+32,d0		; Erase Eye
	move.w	#49,d1
	move.w	#208+32+31,d2
	move.w	#49+31,d3
	moveq.l	#Window_colour,d4
	jsr	Draw_box
	movem.w	(sp)+,d2/d3
	bra.s	.No_eye
.Draw6:	tst.b	Big_brother_flag		; Select eye
	bne.s	.Seen
	lea.l	Eye_off,a0
	bra.s	.Do
.Seen:	lea.l	Eye_on,a0
.Do:	move.w	#208+32,d0		; Display eye
	move.w	#49,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#32,d7
	jsr	Put_unmasked_block
.No_eye:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Load 80 x 80 picture ]
;   IN : d0 - Picture number (.w)
; All registers are restored
;*****************************************************************************
Load_80x80_picture: 
	movem.l	d0/d1,-(sp)
	move.w	#Pic80x80_file,d1		; Load picture
	jsr	Load_subfile
	move.b	d0,Pic_80x80_handle
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Display 80x80 picture ]
; All registers are	restored
; Note :
;  - The coordinates are for Layout 3.
;*****************************************************************************
Display_80x80_picture:        
	movem.l	d0/d1/d5-d7/a0,-(sp)
	Get	Pic_80x80_handle,a0
	moveq.l	#16,d0			; Display	80x80 picture
	moveq.l	#43,d1
	moveq.l	#5,d5
	moveq.l	#5,d6
	moveq.l	#80,d7
	jsr	Put_unmasked_block
	Free	Pic_80x80_handle
	movem.l	(sp)+,d0/d1/d5-d7/a0
	rts

;*****************************************************************************
; [ Print a prompt referring to a party member ]
;   IN : d0 - Prompt number (.w)
;        d7 - Member number [1...6] (.w)
; All registers are	restored
;*****************************************************************************
Do_member_prompt:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	Text_list,a1
	move.l	Prompts_ptr,a0		; Find prompt
	jsr	Find_large_text
	move.l	a0,4(a1)			; Insert in text list
	lea.l	Party_handles-1,a0		; Get member name
	move.b	0(a0,d7.w),d7
	Get	d7,a0
	lea.l	Char_name(a0),a0
	move.l	a0,(a1)			; Insert in text list
	clr.l	8(a1)
	move.l	a1,a0			; Print text
	moveq.l	#0,d0
	jsr	Display_text_and_wait
	Free	d7
	jsr	Erase_PA			; Erase
	jsr	Update_screen
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Print a prompt referring to a party member in a window ]
;   IN : d0 - Prompt number (.w)
;        d7 - Member number [1...6] (.w)
; All registers are	restored
;*****************************************************************************
Do_member_prompt_window:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	Text_list,a1
	move.l	Prompts_ptr,a0		; Find prompt
	jsr	Find_large_text
	move.l	a0,4(a1)			; Insert in text list
	lea.l	Party_handles-1,a0		; Get member name
	move.b	0(a0,d7.w),d7
	Get	d7,a0
	lea.l	Char_name(a0),a0
	move.l	a0,(a1)			; Insert in text list
	clr.l	8(a1)
	move.l	a1,TxtW_ptr		; Set text
	Push	Module,TxtW_Mod
	Free	d7
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Print a text referring to a party member ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to text list (.l)
; All registers are	restored
; Note :
;  - This routine assumes the text list has at least 2 entries.
;*****************************************************************************
Print_member_text:
	movem.l	d0/a1/a2,-(sp)
	lea.l	Party_handles-1,a1		; Get member name
	add.w	d7,a1
	Get	(a1),a2
	lea.l	Char_name(a2),a2
	move.l	a2,(a0)			; Insert in text list
	moveq.l	#0,d0			; Print text
	jsr	Display_text_and_wait
	Free	(a1)
	movem.l	(sp)+,d0/a1/a2
	rts

;*****************************************************************************
; [ Print a text referring to a party member in a window ]
;   IN : d7 - Member number [1...6] (.w)
;        a0 - Pointer to text list (.l)
; All registers are	restored
; Note :
;  - This routine assumes the text list has at least 2 entries.
;*****************************************************************************
Do_member_text_window:
	movem.l	d0/a0-a2,-(sp)
	lea.l	Party_handles-1,a1		; Get member name
	add.w	d7,a1
	Get	(a1),a2
	lea.l	Char_name(a2),a2
	move.l	a2,(a0)			; Insert in text list
	move.l	a0,TxtW_ptr		; Set text
	Push	Module,TxtW_Mod
	Free	(a1)
	movem.l	(sp)+,d0/a0-a2
	rts

;***************************************************************************
; [ Standard item selector ]
; Note:
;  - This routine will work for Layout 3, the Dialogue screen and the
;    backpack slots in the Inventory 2 screen.
;***************************************************************************
ItemSelect_DisInit:
	move.w	#-1,Selected_item		; Clear
	move.w	#-1,Current_ghost_index
	move.w	ItemSelect_prompt,d0	; Print prompt
	jsr	Print_prompt
	jmp	Update_screen

ItemSelect_DisExit:
	jsr	Destroy_ghosts		; Kill!
	jsr	Erase_PA			; Erase text area
	jmp	Update_screen

Item_selected:
	tst.b	d0			; Any selected ?
	beq.s	.Exit
	cmp.b	#-1,d0			; Scroll bar ?
	beq.s	.Exit
	jsr	Wait_4_unclick
	andi.w	#$00ff,d0			; Get real slot number
	subq.w	#1,d0
	add.w	Scroll_bar_result,d0
	move.w	d0,d1
	mulu.w	#Object_packet_size,d0	; Get packet address
	Get	Slotbase_handle,a2
	add.l	Slotbase_offset,a2
	move.w	Object_index(a2,d0.l),d0	; Get object index
	Free	Slotbase_handle
	tst.w	d0			; Anything there ?
	beq.s	.Exit
	move.w	d1,Selected_item		; Store
	Pop	Module			; Exit
.Exit:	rts

Body_item_selected:
	tst.b	d0			; Any selected ?
	beq.s	.Exit
	jsr	Wait_4_unclick
	andi.w	#$00ff,d0			; Get real slot number
	subq.w	#1,d0
	move.w	d0,d1
	mulu.w	#Object_packet_size,d0	; Get packet address
	Get	Inventory_handle,a2
	lea.l	Char_inventory(a2),a2
	move.w	Object_index(a2,d0.l),d0	; Get object index
	Free	Inventory_handle
	tst.w	d0			; Anything there ?
	beq.s	.Exit
	move.w	d1,Selected_item		; Store
	Pop	Module			; Exit
.Exit:	rts

Backpack_item_selected:
	tst.b	d0			; Any selected ?
	beq.s	.Exit
	cmp.b	#-1,d0			; Scroll bar ?
	beq.s	.Exit
	jsr	Wait_4_unclick
	andi.w	#$00ff,d0			; Get real slot number
	add.w	#9-1,d0
	add.w	Scroll_bar_result,d0
	move.w	d0,d1
	mulu.w	#Object_packet_size,d0	; Get packet address
	Get	Inventory_handle,a2
	lea.l	Char_inventory(a2),a2
	move.w	Object_index(a2,d0.l),d0	; Get object index
	Free	Inventory_handle
	tst.w	d0			; Anything there ?
	beq.s	.Exit
	move.w	d1,Selected_item		; Store
	Pop	Module			; Exit
.Exit:	rts

Item_touched:
	tst.b	d0			; Any selected ?
	beq	.No_slot
	cmp.b	#-1,d0			; Scroll bar ?
	beq	.No_slot
	andi.w	#$00ff,d0			; Get real slot number
	subq.w	#1,d0
	add.w	Scroll_bar_result,d0
	cmp.w	Current_ghost_index,d0	; Already being shown ?
	bne.s	.New
; ---------- Update current position --------------
	jsr	Set_ghost_positions
	bra	.Exit
; ---------- See if the slot was actually filled --
.New:	move.w	d0,d1			; Save for later
	mulu.w	#Object_packet_size,d0	; Get packet address
	Get	Slotbase_handle,a2
	add.l	Slotbase_offset,a2
	move.w	Object_index(a2,d0.l),d0	; Get object index
	Free	Slotbase_handle
; ---------- Destroy old object name (if any) -----
	jsr	Destroy_ghosts
; ---------- Initialize the new object name -------
	tst.w	d0			; Anything there ?
	beq	.Exit
	move.w	d1,Current_ghost_index	; Store
	jsr	Create_object_name
	bra	.Exit
; ---------- Destroy current name (if any) --------
.No_slot:	jsr	Destroy_ghosts
.Exit:	rts

Body_item_touched:
	tst.b	d0			; Any selected ?
	beq	.No_slot
;	cmp.b	#-1,d0			; Scroll bar ?
;	beq	.No_slot
	andi.w	#$00ff,d0			; Get real slot number
	subq.w	#1,d0
	cmp.w	Current_ghost_index,d0	; Already being shown ?
	bne.s	.New
; ---------- Update current position --------------
	jsr	Set_ghost_positions
	bra	.Exit
; ---------- See if the slot was actually filled --
.New:	move.w	d0,d1			; Save for later
	mulu.w	#Object_packet_size,d0	; Get packet address
	Get	Inventory_handle,a2
	lea.l	Char_inventory(a2),a2
	move.w	Object_index(a2,d0.l),d0	; Get object index
	Free	Inventory_handle
; ---------- Destroy old object name (if any) -----
	jsr	Destroy_ghosts
; ---------- Initialize the new object name -------
	tst.w	d0			; Anything there ?
	beq	.Exit
	move.w	d1,Current_ghost_index	; Store
	jsr	Create_object_name
	bra	.Exit
; ---------- Destroy current name (if any) --------
.No_slot:	jsr	Destroy_ghosts
.Exit:	rts

;***************************************************************************
; [ Create object name ]
;   IN : d0 - Object index (.w)
; All registers are restored
; Note :
;  - This is an internal routine.
;***************************************************************************
Create_object_name:
	movem.l	d0/a0,-(sp)
	subq.w	#1,d0			; Get object data address
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a0
	add.l	d0,a0
	move.w	#White,Ink_colour		; Set ink
	lea.l	Item_name(a0),a0		; Create ghost string
	jsr	Create_1st_ghost
	movem.l	(sp)+,d0/a0
	rts

;***************************************************************************
; [ Hide Layout 3 object slots ]
; No registers are restored
;***************************************************************************
Hide_Lay3_objects:
	lea.l	Lay3_object_pos_list,a0	; Hide object slots
	move.w	#16,d2
	move.w	#24,d3
	moveq.l	#12-1,d7
.Loop:	move.w	(a0)+,d0			; Get coordinates
	move.w	(a0)+,d1
	jsr	Draw_standard_box2
	dbra	d7,.Loop
	move.w	#154,d0			; Hide scroll bar
	move.w	#139,d1
	move.w	#6,d2
	move.w	#53,d3
	jsr	Draw_standard_box2
	rts

;***************************************************************************
; [ Update object slots ]
; No registers are restored
; Note :
;  - This routine will work for Layout 3 and the Dialogue screen and for
;    the backpack slots in the Inventory 2 screen.
;***************************************************************************
Update_objects:
	moveq.l	#1,d0			; Display objects
	moveq.l	#12-1,d7
.Loop:	jsr	Display_object
	addq.w	#1,d0
	dbra	d7,.Loop
	rts

;***************************************************************************
; [ Display an object ]
;   IN : d0 - Slot number {1...12} (.w)
; All registers are restored
; Note :
;  - [ Scroll_bar_result ] is added to the slot number !
;  - This routine will work for Layout 3, the Dialogue screen and the
;    backpack slots in the Inventory 2 screen.
;***************************************************************************
Display_object:
	movem.l	d0-d7/a0-a3,-(sp)
	subq.w	#1,d0
	movea.l	Object_pos_list,a3		; Find coordinates
	move.w	d0,d1
	lsl.w	#2,d1
	add.w	d1,a3
	Get	Slotbase_handle,a2		; Get object packet address
	add.l	Slotbase_offset,a2
	add.w	Scroll_bar_result,d0
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	(a3),d0			; Get coordinates
	move.w	2(a3),d1
	move.w	d0,d2			; Erase area
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#24-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	move.w	Object_index(a2),d0		; Any object ?
	beq	.Exit
	subq.w	#1,d0			; Get object data address
	mulu.w	#Item_data_size,d0
	move.l	Object_data_ptr,a0
	add.l	d0,a0
	moveq.l	#0,d0			; Get object graphic address
	move.b	Item_pic(a0),d0
	mulu.w	#Icon_size,d0
	Get	Object_gfx_handle,a0
	add.l	d0,a0
	move.w	(a3),d0			; Get coordinates
	move.w	2(a3),d1
	moveq.l	#5,d5			; Display object
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block2
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Broken ?
	beq.s	.No
	lea.l	Broken,a0			; Yes -> Show
	moveq.l	#26,d4
	moveq.l	#1,d5
	jsr	Put_masked_silhouette
.No:	move.b	Quantity(a2),d0		; Get quantity
	cmp.b	#1,d0			; Just one ?
	beq.s	.Skip
	lea.l	Number,a0			; Convert quantity
	moveq.l	#2,d7
	jsr	DecL_convert
	move.w	#White,Ink_colour		; Set ink
	lea.l	Number,a0			; Display quantity
	move.w	(a3),d0
	addi.w	#17,d1
	moveq.l	#16,d2
	jsr	Print_centered_string
.Skip:	Free	Object_gfx_handle		; Exit
.Exit:	Free	Slotbase_handle
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;***************************************************************************
; [ Display a body object ]
;   IN : d0 - Slot number {1...9} (.w)
; All registers are restored
;***************************************************************************
Display_body_object:
	movem.l	d0-d7/a0-a3,-(sp)
	subq.w	#1,d0
	lea.l	Body_pos_list,a3		; Find coordinates
	move.w	d0,d1
	lsl.w	#2,d1
	add.w	d1,a3
	Get	Inventory_handle,a2		; Get object packet address
	lea.l	Char_inventory(a2),a2
	mulu.w	#Object_packet_size,d0
	add.l	d0,a2
	move.w	(a3),d0			; Erase area
	move.w	2(a3),d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	move.w	Object_index(a2),d0		; Any object ?
	beq	.Exit
	move.l	Object_data_ptr,a1		; Get object data address
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a1
	Get	Object_gfx_handle,a0	; Get object graphic address
	moveq.l	#0,d0
	move.b	Item_pic(a1),d0
	mulu.w	#Icon_size,d0
	add.l	d0,a0
	move.w	(a3),d0			; Display object
	move.w	2(a3),d1
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
	jsr	Put_masked_block2
	Free	Object_gfx_handle
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Broken ?
	beq.s	.Exit
	lea.l	Broken,a0			; Yes -> Show
	moveq.l	#26,d4
	moveq.l	#1,d5
	jsr	Put_masked_silhouette
.Exit:	Free	Inventory_handle		; Exit
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Blink ink colour ]
; No registers are restored
;*****************************************************************************
Blink_colour:
	subq.w	#1,Blink_count		; Every 4	frames
	bne.s	.Skip
	addq.w	#1,Blink_index
	move.w	#Blink_interval,Blink_count
.Skip:	lea.l	Blink_colours,a0		; Get colour
	move.w	Blink_index,d0
	moveq.l	#0,d1
	move.b	0(a0,d0.w),d1
	bpl.s	.Not_end			; End of colour list ?
	moveq.l	#0,d0			; Reset
	move.b	(a0),d1
.Not_end:	move.w	d0,Blink_index		; Store
	move.w	d1,Blinked_colour		; Set colour
	rts

;*****************************************************************************
; [ Blink ink colour - range 2 ]
; No registers are restored
;*****************************************************************************
Blink_colour2:
	subq.w	#1,Blink_count		; Every 4	frames
	bne.s	.Skip
	addq.w	#1,Blink_index
	move.w	#Blink_interval,Blink_count
.Skip:	lea.l	Blink_colours2,a0		; Get colour
	move.w	Blink_index,d0
	moveq.l	#0,d1
	move.b	0(a0,d0.w),d1
	bpl.s	.Not_end			; End of colour list ?
	moveq.l	#0,d0			; Reset
	move.b	(a0),d1
.Not_end:	move.w	d0,Blink_index		; Store
	move.w	d1,Blinked_colour		; Set colour
	rts

;***************************************************************************	
; [ Object, gold or food numerical input requester ]
;***************************************************************************
ObjGoldFood_DisInit:
	move.b	ObjGoldFood,d0		; Object, gold or food ?
	bne.s	.Not_obj
	move.l	Object_data_ptr,a0		; Get object data address
	move.w	InputNr_object,d0
	subq.w	#1,d0
	mulu.w	#Item_data_size,d0
	add.l	d0,a0
	lea.l	Item_name(a0),a2		; Get object name
	Get	Object_gfx_handle,a1	; Get object graphic address
	moveq.l	#0,d0
	move.b	Item_pic(a0),d0
	mulu.w	#Icon_size,d0
	add.l	d0,a1
	bra.s	.Draw
.Not_obj:	cmp.b	#1,d0			; Gold ?
	bne.s	.Not_gold
	Get	Object_gfx_handle,a1
	lea.l	(Gold_icon*Icon_size)(a1),a1	; Gold
	move.l	Gold_txt_ptr,a2
	bra.s	.Draw
.Not_gold:	cmp.b	#2,d0			; Food ?
	bne.s	.Not_food
	Get	Object_gfx_handle,a1
	lea.l	(Food_icon*Icon_size)(a1),a1	; Food
	move.l	Food_txt_ptr,a2
	bra.s	.Draw
.Not_food:	sub.l	a1,a1			; Nothing
.Draw:	jsr	InputNr_DisInit
	move.b	Object_gfx_handle,d0
	jmp	Free_pointer

ObjGoldFood_DisUpd:
	jsr	Basic_DisUpd
	jmp	Show_InputNr

;***************************************************************************
; [ Create 1st ghost ]
;   IN : a0 - Pointer to string (.l)
; All registers are restored
; Note :
;  - Always call this BEFORE [ Create_2nd_ghost ] !
;***************************************************************************
Create_1st_ghost:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	jsr	Create_string_graphics	; Create graphics
	move.b	d0,Ghost1_gfx_handle	; Store data
	move.w	d7,Ghost1_string_length
	lea.l	Ghost1_HDOB,a0
	move.b	d0,HDOB_gfx_handle(a0)
	move.w	d6,HDOB_width(a0)
	move.w	Mouse_Y,d1		; Set 1st ghost position
	jsr	Set_string_position
	jsr	Add_HDOB			; Activate HDOB
	sf	Second_ghost		; Clear !
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

;***************************************************************************
; [ Create 2nd ghost ]
;   IN : a0 - Pointer to string (.l)
; All registers are restored
; Note :
;  - Always call this AFTER [ Create_1st_ghost ] !
;***************************************************************************
Create_2nd_ghost:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	jsr	Create_string_graphics	; Create graphics
	move.b	d0,Ghost2_gfx_handle	; Store data
	move.w	d7,Ghost2_string_length
	lea.l	Ghost2_HDOB,a0
	move.b	d0,HDOB_gfx_handle(a0)
	move.w	d6,HDOB_width(a0)
	move.w	Ghost1_HDOB+HDOB_drawY,d1	; Set 2nd ghost position
	jsr	Set_string_position
	jsr	Add_HDOB			; Activate HDOB
	st	Second_ghost		; Set !
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

;***************************************************************************
; [ Destroy ghosts (if any) ]
; All registers are restored
;***************************************************************************
Destroy_ghosts:
	movem.l	d0/a0,-(sp)
	cmp.w	#-1,Current_ghost_index	; Anything shown now ?
	beq.s	.Exit
	lea.l	Ghost1_HDOB,a0		; Destroy 1st ghost
	jsr	Remove_HDOB
	move.b	Ghost1_gfx_handle,d0
	jsr	Free_memory
	tst.b	Second_ghost		; Two ghosts ?
	beq.s	.Done
	lea.l	Ghost2_HDOB,a0		; Destroy 2nd ghost
	jsr	Remove_HDOB
	move.b	Ghost2_gfx_handle,d0
	jsr	Free_memory
.Done:	jsr	Update_screen
	move.w	#-1,Current_ghost_index	; Indicate
.Exit:	movem.l	(sp)+,d0/a0
	rts

;***************************************************************************
; [ Set ghost string positions ]
; All registers are restored
;***************************************************************************
Set_ghost_positions:
	movem.l	d1/d7/a0,-(sp)
	move.w	Mouse_Y,d1		; Update 1st ghost position
	move.w	Ghost1_string_length,d7
	lea.l	Ghost1_HDOB,a0
	jsr	Set_string_position
	tst.b	Second_ghost		; Two ghosts ?
	beq.s	.Exit
	move.w	HDOB_drawY(a0),d1		; Update 2nd ghost position
	move.w	Ghost2_string_length,d7
	lea.l	Ghost2_HDOB,a0
	jsr	Set_string_position
.Exit:	movem.l	(sp)+,d1/d7/a0
	rts

;***************************************************************************
; [ Set ghost string HDOB position ]
;   IN : d1 - Y-coordinate (.w)
;        d7 - String length (.w)
;        a0 - Pointer to HDOB (.w)
; All registers are restored
;***************************************************************************
Set_string_position:
	movem.l	d0/d1/d7,-(sp)
	sub.w	#Char_height+2,d1		; Set Y coordinate
	move.w	d1,HDOB_drawY(a0)
	mulu.w	#Char_width+1,d7		; Get string width
	subq.w	#1,d7
	move.w	d7,d0			; Centre X coordinate
	lsr.w	#1,d0
	neg.w	d0
	add.w	Mouse_X,d0
	bpl.s	.Left_OK			; Too far left ?
	moveq.l	#0,d0			; Yes
	bra.s	.Do
.Left_OK:	move.w	d0,d1			; Too far right ?
	add.w	d7,d1
	subq.w	#1,d1
	cmp.w	#320,d1
	bmi.s	.Do
	move.w	#320,d0			; Yes
	sub.w	d7,d0
.Do:	move.w	d0,HDOB_drawX(a0)		; Store
	movem.l	(sp)+,d0/d1/d7
	rts

;***************************************************************************
; [ Adapt palette ]
;   IN : d0 - Global target colour (.w)
;        a0 - Pointer to palette (.l)
; All registers are restored
;***************************************************************************
Adapt_palette:
	movem.l	d0/d1/d7/a0,-(sp)
	move.w	d0,d1
	addq.l	#2,a0
	moveq.l	#Pal_size-2,d7
.Loop:	move.w	(a0),d0
	jsr	Fade_colour
	move.w	d0,(a0)+
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d1/d7/a0
	rts

;***************************************************************************
; [ Let an object sparkle ]
;   IN : d0 - Slot number {0...32} (.w)
; All registers are restored
; Note :
;  - This routine will ONLY work for the Inventory 2 screen.
;***************************************************************************
Sparkle_object:
	movem.l	d0/a1/a2,-(sp)
	cmp.w	#9,d0			; Body or backpack ?
	bpl.s	.Backpack
	lea.l	Body_pos_list,a1		; Body item
	lea.l	Display_body_object,a2
	bra.s	.Do
.Backpack:	sub.w	Scroll_bar_result,d0	; Backpack item
	subi.w	#9,d0
	movea.l	Object_pos_list,a1
	lea.l	Display_object,a2
.Do:	jsr	Do_sparkle_object		; Do
	movem.l	(sp)+,d0/a1/a2
	rts

;***************************************************************************
; [ Let an object sparkle ]
;   IN : d0 - Slot number {0...23} (.w)
; All registers are restored
;***************************************************************************
Sparkle_object2:
	movem.l	d0/a1/a2,-(sp)
	sub.w	Scroll_bar_result,d0
	movea.l	Object_pos_list,a1
	lea.l	Display_object,a2
	jsr	Do_sparkle_object
	movem.l	(sp)+,d0/a1/a2
	rts

;***************************************************************************
; [ Do sparkling effect on object ]
;   IN : d0 - Slot number {0...11} (.w)
;        a1 - Pointer to slot coordinate list (.l)
;        a2 - Pointer to object display routine (.l)
; All registers are restored
;***************************************************************************
Do_sparkle_object:
	movem.l	d0-d7/a0/a1,-(sp)
	move.w	d0,d4			; Save for later
	addq.w	#1,d4
	lsl.w	#2,d0			; Get coordinates
	add.w	d0,a1
	move.w	(a1)+,d3
	move.w	(a1),d1
	jsr	Update_screen
	lea.l	Magic_stars,a1		; Do sparkles
	moveq.l	#4-1,d7
.Loop:	movem.l	d1/d3/d7,-(sp)
	jsr	Random			; Determine start frame
	andi.w	#$0007,d0
	addq.w	#8,d0
	move.w	d0,d2
	jsr	Random			; Determine coordinates
	mulu.w	#7,d0
	swap	d0
	add.w	d0,d3
	jsr	Random
	mulu.w	#7,d0
	swap	d0
	add.w	d0,d1
.Again:	move.w	d4,d0			; Restore object
	jsr	(a2)
	move.w	d2,d0			; Get graphics address
	lsr.w	#2,d0
	mulu.w	#9*5*2,d0
	lea.l	0(a1,d0.w),a0
	move.w	d3,d0			; Display sparkle
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#9,d7
	jsr	Put_masked_block
	jsr	Switch_screens		; Show
	subq.w	#1,d2			; Next frame
	bpl.s	.Again
	movem.l	(sp)+,d1/d3/d7
	dbra	d7,.Loop
	move.w	d4,d0			; Restore object
	jsr	(a2)
	jsr	Update_screen
	movem.l	(sp)+,d0-d7/a0/a1
	rts

;***************************************************************************	
; The DATA & BSS segments	
;***************************************************************************
	SECTION	Fast_DATA,data
Blink_colours:
	dc.b 19,20,21,17,16,2,2,2,16,17,21,20,19
	dc.b -1
Blink_colours2:
	dc.b 2,3,4,5,6,7,6,5,4,3,2,2,2
	dc.b -1
	even
Portrait_range:
	dc.w $010,$010,$010,$010
	dc.w $011,$011,$012,$012
	dc.w $013,$013,$014,$014
	dc.w $015,$015,$016,$016
	dc.w $017,$017,$018,$018
	dc.w $019,$019,$01a,$01a
	dc.w $01b,$01b,$01c,$01c
	dc.w $01d,$01d,$01e,$01e
	dc.w $01f,$01f,0

Lay3_scroll_bar:
	dc.w 0,6,2,53,154,139
	dc.l Update_objects
	dcb.b Scroll_bar_extra_data

Status_PA:	dc.w 0,319,0,35,31,0,-1
Compass_CA:	dc.w 208,208+31,0,199
Sparkle_CA:	dc.w 0,0,1,34

Time_string:	dc.b "00:00",0
X_string:	dc.b "X:000",0
Y_string:	dc.b "Y:000",0
	even

	SECTION	Fast_BSS,bss
Temp_name:	ds.b 6
Temp_number:	ds.b 3
	even
