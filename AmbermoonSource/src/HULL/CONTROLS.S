; Controls
; Written by J.Horneman (In Tune With The Universe)
; Start : 16-9-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	XREF	TxtW_Mod
	XREF	Req_Mod
	XREF	DiskReq_Mod
	XREF	Text_list
	XREF	Control_icons
	XREF	Button_up
	XREF	Button_down
	XREF	Chequered
	XREF	Prompts
	XREF	Continuous_Mod
	XREF	Known_error_text
	XREF	Disk_request_text
	XREF	Save_disk_request_text
	XREF	Text_error_text

	XDEF	Do_control_icons
	XDEF	Continuous_ModExit
	XDEF	Do_continuous
	XDEF	Display_control_icons
	XDEF	Update_control_icons
	XDEF	Feedback
	XDEF	Display_up_button
	XDEF	Display_down_button

	XDEF	Push_Scroll_bar
	XDEF	Pop_Scroll_bar
	XDEF	Reset_scroll_bar_stack
	XDEF	Init_scroll_bar
	XDEF	Set_scroll_bar
	XDEF	Set_scroll_bar2
	XDEF	Get_scroll_bar
	XDEF	Draw_scroll_bar
	XDEF	Scroll_bar_pressed
	XDEF	Scroll_bar_page_up
	XDEF	Scroll_bar_page_down
	XDEF	Scroll_bar_all_up
	XDEF	Scroll_bar_all_down

	XDEF	Draw_rectangle
	XDEF	Draw_standard_box
	XDEF	Draw_standard_box2

	XDEF	TxtW_DisInit
	XDEF	MemberSel_DisInit
	XDEF	MemberSel_DisExit
	XDEF	Member_selected
	XDEF	Select_member_1
	XDEF	Select_member_2
	XDEF	Select_member_3
	XDEF	Select_member_4
	XDEF	Select_member_5
	XDEF	Select_member_6
	XDEF	Prompt_req
	XDEF	Do_prompt_window
	XDEF	Do_text_window
	XDEF	Req_ModInit
	XDEF	Req_Yes
	XDEF	Req_No
	XDEF	Do_prompt
	XDEF	Do_text
	XDEF	Print_prompt
	XDEF	Print_text
	XDEF	Print_text_and_wait
	XDEF	Print_centered_prompt
	XDEF	Create_string_graphics
	XDEF	Find_large_text
	XDEF	Find_small_text
	XDEF	Control_icon_flag
	XDEF	Req_NO
	XDEF	Req_result
	XDEF	TxtW_ptr
	XDEF	ReqText_ptr
	XDEF	Scroll_bar_result
	XDEF	TxtW_PA
	XDEF	ReqW_PA
	XDEF	MemberSel_prompt
	XDEF	MemberSel_ptr
	XDEF	Selected_member
	XDEF	ScrollBar_L2
	XDEF	Continuous_flag
	XDEF	InputNr_DisInit
	XDEF	Show_InputNr
	XDEF	InputNr_input
	XDEF	InputNr_arrow_up
	XDEF	InputNr_arrow_down
	XDEF	InputNr_arrow_1up
	XDEF	InputNr_arrow_1down
	XDEF	InputNr_all_up
	XDEF	InputNr_all_down
	XDEF	InputNr_exit
	XDEF	InputNr_prompt
	XDEF	InputNr_number
	XDEF	Maximum_number
	XDEF	Minimum_number
	XDEF	Icon_update

	SECTION	Program,code
;*****************************************************************************
; [ Display control icons ]
;   IN : a0 - Pointer to CIL (.l)
; All registers are	restored
;*****************************************************************************
Display_control_icons: 
	movem.l	d0-d7/a0-a6,-(sp)
	sf	Control_icon_flag		; Deactivate control icons
	move.l	a0,Control_list_ptr		; Store
	move.l	a0,-(sp)			; Re-evaluate CIL
	move.l	Reeval_ptr(a0),d0
	beq.s	.Zero
	move.l	d0,a1
	jsr	(a1)
.Zero:	move.l	(sp)+,a0
	movea.l	a0,a2			; Display
	lea.l	Icon_pos,a3
	lea.l	Chequered,a4
	moveq.l	#9-1,d2
.Loop:	move.w	(a3)+,d0			; Get coordinates
	move.w	(a3)+,d1
	move.w	(a2),d3			; Display button
	jsr	Display_up_button
	btst.b	#7,(a2)			; Disabled ?
	beq.s	.Next
	addq.w	#3,d1			; Chequer it
	moveq.l	#Window_colour,d4
	moveq.l	#1,d5
	moveq.l	#2,d6
	moveq.l	#11,d7
	move.l	a4,a0
	jsr	Put_masked_silhouette
.Next:	addq.l	#2,a2			; Next icon
	dbra	d2,.Loop
	st	Control_icon_flag		; Activate control icons
	clr.w	Icon_update		; !
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Control icon interaction ] MOUSE EVENT
;   IN : d0 - Event	ID (.l)
; No registers are restored
;*****************************************************************************
Do_control_icons:
	tst.b	Control_icon_flag		; Active ?
	beq	.Exit
	movea.l	Control_list_ptr,a0		; Get icon number
	andi.w	#$00ff,d0
	move.w	d0,d2
	add.w	d0,d0
	move.w	-2(a0,d0.w),d3
	beq	.Exit			; Empty icon ?
	btst	#15,d3			; Disabled ?
	bne	.Exit
	lea.l	Icon_pos-4,a1		; Get icon coordinates
	add.w	d0,d0
	adda.w	d0,a1
	move.w	(a1),d0
	move.w	2(a1),d1
	btst	#14,d3			; Continuous ?
	beq	.Normal
	tst.b	Key_or_mouse		; Key or mouse ?
	beq	.Normal
	move.w	d2,Continuous_nr		; Store number
	lsl.w	#2,d2			; Get action routine
	move.l	Icon_vectors-4(a0,d2.w),d2
	beq	.Exit
	move.l	d2,Continuous_ptr
	jsr	Display_down_button		; Down
	jsr	Update_screen
	movem.w	d0/d1/d3,Continuous_data	; Store
	move.l	d2,a0			; Execute first time
	jsr	(a0)
	st	Continuous_flag		; Continously
	Push	Module,Continuous_Mod
	bra	.Exit
.Normal:	jsr	Feedback			; Feedback
	bne.s	.Exit
	lsl.w	#2,d2			; Execute action
	move.l	Icon_vectors-4(a0,d2.w),d0
	beq.s	.Exit
	movea.l	d0,a0
	jsr	(a0)
.Exit:	rts

Continuous_ModExit:
	movem.w	Continuous_data,d0/d1/d3	; Get data
	jsr	Display_up_button		; Up
	sf	Continuous_flag
	jmp	Update_screen

Do_continuous:
	andi.w	#$00ff,d0			; Same icon ?
	cmp.w	Continuous_nr,d0
	beq.s	.Yes
	Pop	Module			; No -> exit
	bra.s	.Exit
.Yes:	move.l	Continuous_ptr,a0		; Yes -> execute action
	jsr	(a0)
.Exit:	rts

;*****************************************************************************
; [ Update control icons ]
; All registers are	restored
; Note :
;  - The re-evaluation routine may change all registers. It will receive
;    a pointer to the CIL in a0.
;*****************************************************************************
Update_control_icons:         
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Control_list_ptr,d0		; Any CIL present ?
	beq	.Exit
	move.l	d0,a2
; --------- Re-evaluate control icons -------------
	lea.l	CIL_buffer,a0		; Copy CIL to buffer
	moveq.l	#9-1,d7
.Loop1:	move.w	(a2)+,d0
	bclr	#15,d0
	move.w	d0,(a0)+
	dbra	d7,.Loop1
	lea.l	-18(a0),a0
	lea.l	-18(a2),a2
	movem.l	a0/a2,-(sp)		; Re-evaluate CIL
	move.l	Reeval_ptr(a2),d0
	beq.s	.Zero
	move.l	d0,a1
	jsr	(a1)
.Zero:	movem.l	(sp)+,a0/a2
	movea.l	a2,a1			; Compare	with original
	moveq.l	#0,d0
	moveq.l	#9-1,d7
.Loop2:	cmpm.w	(a0)+,(a1)+
	beq.s	.Next2
	bset	d7,d0
.Next2:	dbra	d7,.Loop2
	tst.w	d0			; Any changes ?
	beq.s	.Skip
	lea.l	CIL_buffer,a0		; Copy buffer to CIL
	moveq.l	#9-1,d7
.Loop3:	move.w	(a0)+,(a2)+
	dbra	d7,.Loop3
; --------- Update control icons ------------------
.Skip:	move.w	Icon_update,d2		; Update
	move.w	d0,Icon_update
	or.w	d0,d2
	movea.l	Control_list_ptr,a2		; Display
	lea.l	Icon_pos,a3
	lea.l	Chequered,a4
	moveq.l	#9-1,d7
.Loop4:	move.w	d7,-(sp)
	btst	d7,d2			; Update ?
	beq	.Next4
	move.w	(a3),d0			; Get coordinates
	move.w	2(a3),d1
	move.w	(a2),d3			; Display icon
	jsr	Display_up_button
	btst	#7,(a2)			; Disabled ?
	beq.s	.Next4
	addq.w	#3,d1			; Chequer it
	moveq.l	#Window_colour,d4
	moveq.l	#1,d5
	moveq.l	#2,d6	
	moveq.l	#11,d7
	move.l	a4,a0
	jsr	Put_masked_silhouette
.Next4:	addq.l	#2,a2			; Next icon
	addq.l	#4,a3
	move.w	(sp)+,d7
	dbra	d7,.Loop4
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Control icon feedback ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d3 - Control icon number {0...} (.b)
;  OUT : eq - Do it
;        ne - User aborted
; All registers are	restored
;*****************************************************************************
Feedback:
	movem.l	d0/d1/d6/d7,-(sp)
	moveq.l	#0,d7			; Default is OK
	jsr	Display_down_button		; Down
	jsr	Update_screen
	tst.b	Key_or_mouse		; Key or mouse ?
	beq.s	.Key
	btst	#Right_pressed,Button_state	; Right mouse button pressed ?
	beq.s	.Left
	jsr	Wait_4_unclick		; Yes
	bra.s	.Go_on
.Left:	jsr	Wait_4_unclick		; Wait for mouse
	move.w	Mouse_X,d6		; Still over icon ?
	sub.w	d0,d6
	cmp.w	#32,d6
	bhi.s	.Off
	move.w	Mouse_Y,d6
	sub.w	d1,d6
	cmp.w	#17,d6
	blo.s	.Go_on
.Off:	moveq.l	#-1,d7			; No!
	bra.s	.Go_on
.Key:	move.w	d0,-(sp)
	moveq.l	#5,d0			; Wait
	jsr	Delay
	move.w	(sp)+,d0
.Go_on:	jsr	Display_up_button		; Up
	jsr	Update_screen
	tst.w	d7			; Well ?
	movem.l	(sp)+,d0/d1/d6/d7
	rts

;***************************************************************************	
; [ Display "up" control icon ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d3 - Control icon number {0...} (.b)
; All registers are restored
;***************************************************************************
Display_up_button:
	movem.l	d1/d3-d7/a0,-(sp)
	moveq.l	#24,d4			; Display up button
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#17,d7
	lea.l	Button_up,a0
	jsr	Put_unmasked_block
	lea.l	Control_icons,a0		; Calculate icon address
	andi.w	#$007f,d3
	tst.b	d3
	bne.s	.Notzero
	move.w	#Empty_cicon,d3
.Notzero:	subq.w	#1,d3
	mulu.w	#13*12,d3
	add.w	d3,a0
	addq.w	#2,d1			; Display icon
	moveq.l	#13,d7
	jsr	Put_masked_block2
	movem.l	(sp)+,d1/d3-d7/a0
	rts

;***************************************************************************	
; [ Display "down" control icon ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d3 - Control icon number {0...} (.b)
; All registers are restored
;***************************************************************************
Display_down_button:
	movem.l	d1/d3-d7/a0,-(sp)
	moveq.l	#24,d4			; Display down button
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#17,d7
	lea.l	Button_down,a0
	jsr	Put_unmasked_block
	lea.l	Control_icons,a0		; Calculate icon address
	tst.b	d3
	bne.s	.Notzero
	move.w	#Empty_cicon,d3
.Notzero:	andi.w	#$007f,d3
	subq.w	#1,d3
	mulu.w	#13*12,d3
	add.w	d3,a0
	addq.w	#4,d1			; Display icon
	moveq.l	#13,d7
	jsr	Put_masked_block2
	movem.l	(sp)+,d1/d3-d7/a0
	rts

;*****************************************************************************
; [ Push a scroll bar on the stack ]
;   IN : a0 - Pointer to scroll bar data (.l)
; All registers are	restored
;*****************************************************************************
Push_Scroll_bar:
	move.l	a1,-(sp)
	movea.l	Scroll_bar_Sp,a1
	addq.l	#4,a1
	cmpa.l	#Scroll_bar_Stack_end,a1	; Possible ?
	beq.s	.Exit
	move.l	a0,(a1)			; Push
	move.l	a1,Scroll_bar_Sp
	jsr	Init_scroll_bar		; Initialize new scroll bar
.Exit:	movea.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Pop a scroll bar from the stack ]
; All registers are	restored
; Notes :
;   - Because [ Close_window ] calls [ Pop_Tree ], which resets variables
;     ([ Offset_X ] and [ Offset_Y]) which are used by [ Init_scroll_bar ],
;     it is wise to close a window BEFORE popping a scroll bar.
;*****************************************************************************
Pop_Scroll_bar:
	move.l	a0,-(sp)
	movea.l	Scroll_bar_Sp,a0
	cmpa.l	#Scroll_bar_Stack_start,a0	; Possible ?
	beq.s	.Exit
	subq.l	#4,a0			; Pop
	move.l	a0,Scroll_bar_Sp
	move.l	(a0),a0			; Get previous scroll bar
	cmp.l	#0,a0			; Is stack base ?
	beq.s	.Exit
	jsr	Init_scroll_bar		; No -> Initialize
.Exit:	movea.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Reset the scroll bar stack ]
; All registers are	restored
;*****************************************************************************
Reset_scroll_bar_stack:
	move.l	a0,-(sp)
	lea.l	Scroll_bar_Stack_start,a0	; Reset stack
	clr.l	(a0)
	move.l	a0,Scroll_bar_Sp
	move.l	(sp)+,a0
	rts

;***************************************************************************	
; [ Initialize scroll bar ]
;   IN : a0 - Pointer to scroll bar data (.l)
; All registers are restored
;***************************************************************************
Init_scroll_bar:
	movem.l	d0/d1/a1/a2,-(sp)
	move.l	a0,Scroll_bar_data_ptr	; Store
	moveq.l	#0,d0			; Scroll at all ?
	move.w	Total_units(a0),d0
	cmp.w	Units_height(a0),d0
	bgt.s	.Yes
	move.w	Scroll_bar_height(a0),d0	; No -> preset variables
	move.w	d0,Scroll_thingy_height(a0)
	clr.w	Scroll_bar_max_height(a0)
	move.w	#1,Row_height(a0)
	bra.s	.Go_on
.Yes:	cmp.w	#1,Units_width(a0)		; More than 1 unit per row ?
	beq.s	.One
	divu.w	Units_width(a0),d0		; Yes
.One:	move.w	d0,d1
	moveq.l	#0,d0			; Calculate row height
	move.w	Scroll_bar_height(a0),d0
	divu.w	d1,d0
	move.w	d0,Row_height(a0)
	moveq.l	#0,d0			; Calculate maximum height
	move.w	Total_units(a0),d0
	divu.w	Units_width(a0),d0
	sub.w	Units_height(a0),d0
	mulu.w	Row_height(a0),d0
	move.w	d0,Scroll_bar_max_height(a0)
	sub.w	Scroll_bar_height(a0),d0	; Calculate thingy height
	neg.w	d0
	move.w	d0,Scroll_thingy_height(a0)
.Go_on:	sf	Thingy_selected		; Clear flag
	lea.l	ScrollBar_L2,a1		; Adapt object
	move.w	Scroll_bar_X(a0),d0
	sub.w	Offset_X,d0
	move.w	d0,Obj_X1(a1)
	add.w	#6-1,d0
	move.w	d0,Obj_X2(a1)
	move.w	Scroll_bar_Y(a0),d0
	sub.w	Offset_Y,d0
	move.w	d0,Obj_Y1(a1)
	add.w	Scroll_bar_height(a0),d0
	subq.w	#1,d0
	move.w	d0,Obj_Y2(a1)
	move.w	Scroll_thingy_Y(a0),d0	; Display
	jsr	Update_scroll_thingy
	movem.l	(sp)+,d0/d1/a1/a2
	rts

;***************************************************************************	
; [ Set scroll bar position ]
;   IN : d0 - Scroll bar Y position (.w)
; All registers are restored
;***************************************************************************
Set_scroll_bar:
	move.l	a0,-(sp)
	move.l	Scroll_bar_data_ptr,a0
	jsr	Update_scroll_thingy
	move.l	(sp)+,a0
	rts

;***************************************************************************	
; [ Set scroll bar position 2 ]
;   IN : d0 - Scroll bar result (.w)
; All registers are restored
;***************************************************************************
Set_scroll_bar2:
	movem.l	d0/a0,-(sp)
	move.l	Scroll_bar_data_ptr,a0
	ext.l	d0			; Calculate row
	divu.w	Units_width(a0),d0
	mulu.w	Row_height(a0),d0		; Calculate Y
	cmp.w	Scroll_bar_max_height(a0),d0	; Too high ?
	bmi.s	.Ok
	move.w	Scroll_bar_max_height(a0),d0	; Yes -> clip
.Ok:	jsr	Update_scroll_thingy	; Update
	movem.l	(sp)+,d0/a0
	rts

;***************************************************************************	
; [ Get scroll bar position ]
;  OUT : d0 - Scroll bar Y-position (.w)
; All registers are restored
;***************************************************************************
Get_scroll_bar:
	move.l	a0,-(sp)
	move.l	Scroll_bar_data_ptr,a0
	move.w	Scroll_thingy_Y(a0),d0
	move.l	(sp)+,a0
	rts

;***************************************************************************	
; [ Draw scroll bar ]
; All registers are restored
;***************************************************************************
Draw_scroll_bar:
	movem.l	d0-d4/a0/a1,-(sp)
	move.l	Scroll_bar_data_ptr,a0
	tst.b	Thingy_selected		; Thingy selected ?
	bne.s	.Yes
	lea.l	Unselected_thingy_colours,a1
	bra.s	.Do
.Yes:	lea.l	Selected_thingy_colours,a1
; ---------- Draw scroll bar ----------------------
.Do:	move.w	Scroll_bar_X(a0),d0		; Get data
	move.w	Scroll_bar_Y(a0),d1
	move.w	d0,d2			; First box
	addq.w	#6-1,d2
	move.w	d1,d3
	add.w	Scroll_bar_height(a0),d3
	subq.w	#1,d3
	moveq.l	#26,d4
	jsr	Draw_box
	addq.w	#1,d0			; Second box
	addq.w	#1,d1
	moveq.l	#27,d4
	jsr	Draw_box
; ---------- Draw thingy --------------------------
	move.w	Scroll_bar_X(a0),d0		; First box
	move.w	Scroll_bar_Y(a0),d1
	add.w	Scroll_thingy_Y(a0),d1
	move.w	d0,d2
	addq.w	#6-1,d2
	move.w	d1,d3
	add.w	Scroll_thingy_height(a0),d3
	subq.w	#1,d3
	move.w	(a1)+,d4
	jsr	Draw_box
	addq.w	#1,d0			; Second box
	addq.w	#1,d1
	move.w	(a1)+,d4
	jsr	Draw_box
	subq.w	#1,d0			; Third box
	subq.w	#1,d1
	subq.w	#1,d2
	subq.w	#1,d3
	move.w	(a1)+,d4
	jsr	Draw_box
	addq.w	#1,d0			; Fourth box
	addq.w	#1,d1
	move.w	(a1)+,d4
	jsr	Draw_box
	subq.w	#1,d0			; Fifth box
	subq.w	#1,d1
	move.w	(a1)+,d4
	jsr	Plot_pixel
	add.w	Scroll_thingy_height(a0),d1	; Shadow
	move.w	Scroll_bar_Y(a0),d3
	add.w	Scroll_bar_height(a0),d3
	subq.w	#1,d3
	cmp.w	d1,d3			; Thingy at the bottom ?
	bmi.s	.Exit
	move.w	d0,d2			; Draw shadow under thingy
	addq.w	#6-1,d2
	move.w	d1,d3
	moveq.l	#26,d4
	jsr	Draw_box
.Exit:	movem.l	(sp)+,d0-d4/a0/a1
	rts

Scroll_bar_pressed:
	move.l	Scroll_bar_data_ptr,a0
	move.w	Mouse_Y,d0		; Still in bar area ?
	move.w	Scroll_bar_Y(a0),d1
	cmp.w	d1,d0
	bmi	.Exit
	move.w	d1,d2
	add.w	Scroll_bar_height(a0),d1
	cmp.w	d1,d0
	bpl	.Exit
	add.w	Scroll_thingy_Y(a0),d2	; Above thingy ?
	cmp.w	d2,d0
	bpl	.Not_above
	jsr	Scroll_bar_page_up		; Page up
	bra	.Exit
.Not_above:
	add.w	Scroll_thingy_height(a0),d2	; Below thingy ?
	cmp.w	d2,d0
	bmi	.In
	jsr	Scroll_bar_page_down	; Page down
	bra	.Exit
; ---------- Drag scroll thingy -------------------
.In:	st	Thingy_selected		; Selected !
	jsr	Hide_HDOBs
	jsr	Update_screen
	lea.l	Scroll_bar_MA,a1		; Create MA
	move.w	Scroll_bar_X(a0),d0
	move.w	d0,MA_X1(a1)
	add.w	#6-1,d0
	move.w	d0,MA_X2(a1)
	move.w	Scroll_bar_Y(a0),d0
	move.w	d0,MA_Y1(a1)
	add.w	Scroll_bar_max_height(a0),d0
	move.w	d0,MA_Y2(a1)
	move.l	a0,-(sp)			; Set mouse
	move.l	a1,a0
	jsr	Push_MA
	move.l	(sp)+,a0
	jsr	Mouse_off
	move.w	Scroll_thingy_Y(a0),d0
	add.w	Scroll_bar_Y(a0),d0
	move.w	d0,Mouse_Y
	move.w	Scroll_thingy_Y(a0),d0	; Get Y
.Again:	ext.l	d0			; Update needed ?
	divu.w	Row_height(a0),d0
	cmp.w	Current_row(a0),d0
	beq.s	.No
	move.w	Scroll_thingy_Y(a0),d0	; Update
	jsr	Update_scroll_thingy
	jsr	Update_screen
	bra.s	.Go_on
.No:	jsr	Draw_scroll_bar		; Show bar
	jsr	Switch_screens
.Go_on:	move.b	Button_state,d0		; Still pressed ?
	btst	#Left_pressed,d0
	beq.s	.Done
	move.w	Mouse_Y,d0		; Get position
	sub.w	Scroll_bar_Y(a0),d0
	move.w	d0,Scroll_thingy_Y(a0)	; Store
	bra.s	.Again
.Done:	Pop	MA			; Restore mouse
	jsr	Mouse_on
	move.w	Scroll_thingy_Y(a0),d0	; Deselect
	sf	Thingy_selected
	jsr	Update_scroll_thingy
	jsr	Update_screen
	jsr	Show_HDOBs
.Exit:	rts

Scroll_bar_page_up:
	jsr	Light_scroll_thingy
	move.l	Scroll_bar_data_ptr,a0
	move.w	Units_height(a0),d0		; Half-page up
	lsr.w	#1,d0
	bne.s	.Notzero
	moveq.l	#1,d0
.Notzero:	neg.w	d0
	add.w	Current_row(a0),d0
	bpl.s	.Ok
	moveq.l	#0,d0
.Ok:	mulu.w	Row_height(a0),d0
	jsr	Wait_4_unclick
	jsr	Update_scroll_thingy
	jmp	Update_screen

Scroll_bar_page_down:
	jsr	Light_scroll_thingy
	move.l	Scroll_bar_data_ptr,a0
	move.w	Units_height(a0),d0		; Half-page down
	lsr.w	#1,d0
	bne.s	.Notzero
	moveq.l	#1,d0
.Notzero:	add.w	Current_row(a0),d0
	mulu.w	Row_height(a0),d0
	cmp.w	Scroll_bar_max_height(a0),d0
	bmi.s	.Ok
	move.w	Scroll_bar_max_height(a0),d0
.Ok:	jsr	Wait_4_unclick
	jsr	Update_scroll_thingy
	jmp	Update_screen

Scroll_bar_all_up:
	jsr	Light_scroll_thingy
	move.l	Scroll_bar_data_ptr,a0
	moveq.l	#0,d0			; All the way up
	jsr	Update_scroll_thingy
	jmp	Update_screen

Scroll_bar_all_down:
	jsr	Light_scroll_thingy
	move.l	Scroll_bar_data_ptr,a0
	move.w	Scroll_bar_max_height(a0),d0	; All the way down
	jsr	Update_scroll_thingy
	jmp	Update_screen

;***************************************************************************	
; [ Light scroll thingy ]
; All registers are restored
;***************************************************************************	
Light_scroll_thingy:
	st	Thingy_selected
	jsr	Draw_scroll_bar
	jsr	Update_screen
	sf	Thingy_selected
	rts

;***************************************************************************	
; [ Update scroll thingy ]
;   IN : d0 - New Y-coordinate (.w)
;        a0 - Pointer to scroll bar data (.l)
; All registers are restored
;***************************************************************************	
Update_scroll_thingy:
	movem.l	d0/d1/a0,-(sp)
	cmp.w	Scroll_bar_max_height(a0),d0	; Too far down ?
	bmi.s	.Ok
	move.w	Scroll_bar_max_height(a0),d0	; Yes
.Ok:	move.w	d0,Scroll_thingy_Y(a0)	; Set variables
	ext.l	d0
	divu.w	Row_height(a0),d0
	move.w	d0,Current_row(a0)
	mulu.w	Units_width(a0),d0
	move.w	d0,Scroll_bar_result
	jsr	Draw_scroll_bar		; Re-draw scroll bar
	move.l	Scroll_bar_update_ptr(a0),d0	; Update
	beq.s	.None
	move.l	d0,a0
	jsr	(a0)
.None:	movem.l	(sp)+,d0/d1/a0
	rts

;***************************************************************************	
; [ Draw a rectangle ]
;   IN : d0 - Top-left X-coordinate (.w)
;        d1 - Top-left Y-coordinate (.w)
;        d2 - Width of rectangle (.w)
;        d3 - Height of rectangle (.w)
;        d4 - Colour (.w)
; All registers are restored
;***************************************************************************	
Draw_rectangle:
	movem.l	d0-d3/d6/d7,-(sp)
	move.w	d2,d6			; Save width & height
	move.w	d3,d7
	subq.w	#1,d6
	subq.w	#1,d7
	add.w	d0,d2			; Top H-line
	subq.w	#1,d2
	move.w	d1,d3
	jsr	Draw_hline
	move.w	d2,d0			; Right V-line
	add.w	d7,d3
	jsr	Draw_vline
	move.w	d3,d1			; Bottom H-line
	sub.w	d6,d2
	jsr	Draw_hline
	move.w	d2,d0			; Left V-line
	sub.w	d7,d3
	jsr	Draw_vline
	movem.l	(sp)+,d0-d3/d6/d7
	rts

;***************************************************************************	
; [ Draw a standard box (DEEP) ]
;   IN : d0 - Top-left X-coordinate (.w)
;        d1 - Top-left Y-coordinate (.w)
;        d2 - Width of INSIDE of box (.w)
;        d3 - Height of INSIDE of box (.w)
; All registers are restored
; Note :
;  - This routine assumes the area where the standard box will be drawn
;    is filled with the window colour.
;***************************************************************************	
Draw_standard_box:
	movem.l	d0-d4,-(sp)
	add.w	d0,d2			; Draw dark edge
	add.w	d1,d3
	moveq.l	#26,d4
	jsr	Draw_box
	addq.w	#1,d0			; Draw light edge
	addq.w	#1,d1
	addq.w	#1,d2
	addq.w	#1,d3
	moveq.l	#30,d4
	jsr	Draw_box
	subq.w	#1,d2			; Draw main area
	subq.w	#1,d3
	moveq.l	#27,d4
	jsr	Draw_box
	movem.l	(sp)+,d0-d4
	rts

;***************************************************************************	
; [ Draw a standard box (HIGH) ]
;   IN : d0 - Top-left X-coordinate (.w)
;        d1 - Top-left Y-coordinate (.w)
;        d2 - Width of box (.w)
;        d3 - Height of box (.w)
; All registers are restored
; Note :
;  - This routine assumes the area where the standard box will be drawn
;    is filled with the window colour.
;***************************************************************************	
Draw_standard_box2:
	movem.l	d0-d4,-(sp)
	add.w	d0,d2			; Draw dark edge
	add.w	d1,d3
	addq.w	#1,d0
	addq.w	#1,d1
	subq.w	#1,d2
	subq.w	#1,d3
	moveq.l	#26,d4
	jsr	Draw_box
	subq.w	#1,d0			; Draw light edge
	subq.w	#1,d1
	subq.w	#1,d2
	subq.w	#1,d3
	moveq.l	#30,d4
	jsr	Draw_box
	addq.w	#1,d0			; Draw main area
	addq.w	#1,d1
	moveq.l	#28,d4
	jsr	Draw_box
	subq.w	#1,d0			; Draw light spot
	subq.w	#1,d1
	moveq.l	#31,d4
	jsr	Plot_pixel
	movem.l	(sp)+,d0-d4
	rts

;***************************************************************************	
; [ Standard text window ]
;***************************************************************************	
TxtW_DisInit:
	move.l	TxtW_ptr,a0		; Process text
	jsr	Process_text
	move.b	d0,d7
	cmpi.w	#16,Text_height		; Window large enough ?
	bhi.s	.Scroll			; No, scroll
	move.w	Text_height,d0		; Yes, calculate new height
	mulu.w	#Char_height+2,d0
	move.w	d0,d5
	move.w	d0,d3
	addi.w	#15,d3
	lsr.w	#4,d3
	cmpi.w	#2,d3			; Window too small ?
	bpl.s	.No
	moveq.l	#2,d3
.No:	move.w	d3,d4			; Calculate vertical offset
	lsl.w	#4,d4
	sub.w	d5,d4
	move.w	#TxtW_X,d0		; Open a window
	move.w	#TxtW_Y,d1
	moveq.l	#18,d2
	addq.w	#2,d3
	suba.l	a0,a0
	jsr	Open_window
	lea.l	TxtW_PA,a0		; Vertical centering
	lsr.w	#1,d4
	add.w	d4,d1
	addi.w	#16,d1
	move.w	d1,PA_Y1(a0)
	add.w	d5,d1			; Set height
	subq.w	#1,d1
	move.w	d1,PA_Y2(a0)
	Pop	PA			; Re-install PA
	jsr	Push_PA
	move.b	d7,d0			; Display
	jsr	Display_text_and_wait
	bra.s	.Exit
.Scroll:	move.w	#TxtW_X,d0		; Open maximum window
	move.w	#TxtW_Y,d1
	moveq.l	#18,d2
	moveq.l	#9,d3
	moveq.l	#0,d6
	suba.l	a0,a0
	jsr	Open_window
	Pop	PA			; Install	maximum print area
	Push	PA,MaxTxtW_PA
	move.b	d7,d0			; Display
	jsr	Display_text
.Exit:	jsr	Close_window		; Exit
	jmp	Pop_Module

;***************************************************************************	
; [ Standard party member selector ]
;***************************************************************************	
MemberSel_DisInit:
	clr.w	Selected_member		; Clear
	move.l	Prompts_ptr,a0		; Find text
	move.w	MemberSel_prompt,d0
	jsr	Find_large_text
	lea.l	Text_list,a1		; Insert in dummy list
	move.l	a0,(a1)
	clr.l	4(a1)
	move.l	a1,a0
	jsr	Process_text		; Process text
	move.b	d0,d7
	cmpi.w	#16,Text_height		; Window large enough ?
	bhi.s	.Scroll			; No, scroll
	move.w	Text_height,d0		; Yes, calculate new height
	mulu.w	#Char_height+2,d0
	move.w	d0,d5
	move.w	d0,d3
	addi.w	#15,d3
	lsr.w	#4,d3
	cmpi.w	#2,d3			; Window too small ?
	bpl.s	.No
	moveq.l	#2,d3
.No:	move.w	d3,d4			; Calculate vertical offset
	lsl.w	#4,d4
	sub.w	d5,d4
	move.w	#TxtW_X,d0		; Open a window
	move.w	#TxtW_Y,d1
	moveq.l	#18,d2
	addq.w	#2,d3
	suba.l	a0,a0
	jsr	Open_window
	lsr.w	#1,d4			; Vertical cursor centering
	add.w	d4,d1
	addi.w	#16,d1
	move.w	d1,TxtW_PA+PA_Y1
	add.w	d5,d1			; Set height
	subq.w	#1,d1
	move.w	d1,TxtW_PA+PA_Y2
	Pop	PA			; Re-install PA
	Push	PA,TxtW_PA
	move.b	d7,d0			; Display
	jsr	Display_text
	bra.s	.Exit
.Scroll:	move.w	#TxtW_X,d0		; Open maximum window
	move.w	#TxtW_Y,d1
	moveq.l	#18,d2
	moveq.l	#9,d3
	moveq.l	#0,d6
	suba.l	a0,a0
	jsr	Open_window
	Pop	PA			; Install	maximum print area
	Push	PA,MaxTxtW_PA
	move.b	d7,d0			; Display
	jsr	Display_text
.Exit:	Push	MA,MemberSel_MA		; To override window MA
	rts

MemberSel_DisExit:
	Pop	MA
	jmp	Close_window

Member_selected:
	jsr	Wait_4_unclick
	lsr.w	#8,d0			; Any member ?
	beq.s	.Exit
	move.l	MemberSel_ptr,a0		; Yes -> Call routine
	jsr	(a0)
.Exit:	rts

;*****************************************************************************
; [ Member selected by keys 1...6 ] KEY EVENT
;*****************************************************************************
Select_member_1:
	move.w	#1*256,d0
	jmp	Member_selected
Select_member_2:
	move.w	#2*256,d0
	jmp	Member_selected
Select_member_3:
	move.w	#3*256,d0
	jmp	Member_selected
Select_member_4:
	move.w	#4*256,d0
	jmp	Member_selected
Select_member_5:
	move.w	#5*256,d0
	jmp	Member_selected
Select_member_6:
	move.w	#6*256,d0
	jmp	Member_selected

;***************************************************************************	
; [ Prompt requester ]
;   IN : d0 - Prompt number (.w)
;  OUT : d0 - Requester result (.b)
; Changed registers : d0
;***************************************************************************
Prompt_req:
	movem.l	a0/a1,-(sp)
	move.l	Prompts_ptr,a0		; Find text
	jsr	Find_large_text
	lea.l	Text_list,a1
	move.l	a0,(a1)
	clr.l	4(a1)
	move.l	a1,ReqText_ptr		; Set text
	st	Req_NO			; Request
	Push	Module,Req_Mod
	move.b	Req_result,d0		; Get result
	movem.l	(sp)+,a0/a1
	rts

;***************************************************************************	
; [ Do prompt window ]
;   IN : d0 - Prompt number (.w)
; All registers are restored
;***************************************************************************
Do_prompt_window:
	move.l	a0,-(sp)
	move.l	Prompts_ptr,a0
	jsr	Do_text_window
	move.l	(sp)+,a0
	rts

;***************************************************************************	
; [ Do text window ]
;   IN : d0 - Prompt number (.w)
;        a0 - Pointer to text file (.l)
; All registers are restored
;***************************************************************************
Do_text_window:
	movem.l	a0/a1,-(sp)
	jsr	Find_large_text		; Find text
	lea.l	Text_list,a1
	move.l	a0,(a1)
	clr.l	4(a1)
	move.l	a1,TxtW_ptr		; Set text
	Push	Module,TxtW_Mod
	movem.l	(sp)+,a0/a1
	rts

;***************************************************************************	
; [ Standard requester ]
;***************************************************************************
Req_ModInit:
	sf	Req_result		; Clear
	move.l	ReqText_ptr,a0		; Process text
	jsr	Process_text
	move.b	d0,d7
; ---------- Calculate window height --------------
	move.w	Text_height,d0		; Calculate text height
	mulu.w	#Char_height+2,d0
	move.w	d0,d5			; Save
	move.w	d0,d3			; Calculate window height
	addi.w	#15,d3
	lsr.w	#4,d3
;	cmpi.w	#2,d3			; Window too small ?
;	bpl.s	.Ok1
;	moveq.l	#2,d3
.Ok1:	cmp.w	#6,d3			; Window too big ?
	bls.s	.Ok2
	moveq.l	#6,d3
.Ok2:	move.w	d3,d4			; Calculate icons Y-coordinate
	lsl.w	#4,d4
	move.w	d4,d0
	addi.w	#ReqW_Y,d0
	move.w	d0,Req_icon_Y		; Store
; ---------- Adapt object tree --------------------
	lea.l	Req_L1,a0
	lea.l	4(a0),a1
	move.w	d4,Obj_Y1(a1)
	move.w	d4,d0
	addi.w	#16,d0
	move.w	d0,Obj_Y2(a1)
	move.l	Obj_brother(a1),a1
	move.w	d4,Obj_Y1(a1)
	move.w	d0,Obj_Y2(a1)
; ---------- Open window --------------------------
	move.w	#ReqW_X-16,d0
	move.w	#ReqW_Y-16,d1
	moveq.l	#14,d2
	addq.w	#3,d3
	jsr	Open_window
; ---------- Adapt print area ---------------------
	lea.l	ReqW_PA,a0		; Vertical centering
	sub.w	d5,d4
	lsr.w	#1,d4
	add.w	d4,d1
	addi.w	#16,d1
	move.w	d1,PA_Y1(a0)
	add.w	d5,d1			; Set height
	subq.w	#1,d1
	move.w	d1,PA_Y2(a0)
	Pop	PA			; Re-install PA
	jsr	Push_PA
; ---------- Display text & icons -----------------
	move.b	d7,d0			; Display text
	jsr	Display_text
	tst.b	Req_NO			; NO button ?
	bne.s	.Yes
	move.w	#ReqW_X+63,d0		; Draw box around icon
	move.w	Req_icon_Y,d1
	subq.w	#1,d1
	moveq.l	#32,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display YES icon
	addq.w	#1,d1
	move.b	#Yes_cicon,d3
	jsr	Display_up_button
	bra.s	.Skip
.Yes:	move.w	#ReqW_X+63,d0		; Draw box around icons
	move.w	Req_icon_Y,d1
	subq.w	#1,d1
	moveq.l	#64,d2
	moveq.l	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display YES icon
	addq.w	#1,d1
	move.b	#Yes_cicon,d3
	jsr	Display_up_button
	addi.w	#32,d0			; Display NO icon
	move.b	#No_cicon,d3
	jsr	Display_up_button
.Skip:	jmp	Update_screen

Req_Yes:
	move.w	#ReqW_X+64,d0		; Feedback
	move.w	Req_icon_Y,d1
	move.b	#Yes_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	Pop	Module			; Exit
	st	Req_result		; Positive
.Exit:	rts

Req_No:
	tst.b	Req_NO			; Present ?
	beq.s	.Exit
	move.w	#ReqW_X+96,d0		; Feedback
	move.w	Req_icon_Y,d1
	move.b	#No_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ Print a prompt, wait for the user and erase the prompt ]
;   IN : d0 - Prompt number (.w)
; All registers are	restored
; Note :
;  - This routine assumes a PA has been installed.
;*****************************************************************************
Do_prompt:
	move.l	a0,-(sp)
	move.l	Prompts_ptr,a0
	jsr	Do_text
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Print a text, wait for the user and erase the text ]
;   IN : d0 - Text block number (.w)
;        a0 - Pointer to text file (.l)
; All registers are	restored
; Note :
;  - This routine assumes a PA has been installed.
;*****************************************************************************
Do_text:
	jsr	Print_text_and_wait		; Print, wait
	jsr	Erase_PA			; Erase
	jmp	Update_screen

;*****************************************************************************
; [ Print a prompt ]
;   IN : d0 - Prompt number (.w)
; All registers are	restored
; Note :
;  - This routine assumes a PA has been installed.
;*****************************************************************************
Print_prompt:
	move.l	a0,-(sp)
	move.l	Prompts_ptr,a0
	jsr	Print_text
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Print a text ]
;   IN : d0 - Text block number (.w)
;        a0 - Pointer to text file (.l)
; All registers are	restored
; Note :
;  - This routine assumes a PA has been installed.
;*****************************************************************************
Print_text:
	movem.l	d0/a0/a1,-(sp)
	jsr	Find_large_text		; Find text
	lea.l	Text_list,a1
	move.l	a0,(a1)
	clr.l	4(a1)
	move.l	a1,a0			; Print text
	moveq.l	#0,d0
	jsr	Display_text
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Print a text & wait ]
;   IN : d0 - Text block number (.w)
;        a0 - Pointer to text file (.l)
; All registers are	restored
; Note :
;  - This routine assumes a PA has been installed.
;*****************************************************************************
Print_text_and_wait:
	movem.l	d0/a0/a1,-(sp)
	jsr	Find_large_text		; Find text
	lea.l	Text_list,a1
	move.l	a0,(a1)
	clr.l	4(a1)
	move.l	a1,a0			; Print text
	moveq.l	#0,d0
	jsr	Display_text_and_wait
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Print a centered prompt ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Width of centering area (.w)
;        d3 - Prompt number (.w)
; All registers are	restored
; Note :
;  - This routine assumes the prompt will take up no more than one line.
;*****************************************************************************
Print_centered_prompt:
	move.l	a0,-(sp)
	move.l	Prompts_ptr,a0		; Find text
	exg.l	d0,d3
	jsr	Find_large_text
	exg.l	d0,d3
	jsr	Print_centered_string	; Print text
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Create a graphic block containing a string ]
;   IN : a0 - Pointer to string (.l)
;  OUT : d0 - Memory handle (.b)
;        d6 - Width of block (.w)
;        d7 - Length of string (.w)
; Changed registers : d0,d6,d7
;*****************************************************************************
Create_string_graphics:
	movem.l	d1-d5/a0,-(sp)
	jsr	Strlen			; Calculate width
	move.w	d0,-(sp)
	mulu.w	#Char_width+1,d0
	addi.w	#15,d0
	lsr.w	#4,d0
	move.w	d0,d6
	add.w	d0,d0			; Make buffer
	mulu.w	#5*(Char_height+1),d0
	jsr	Allocate_CHIP
	move.b	d0,d4
	move.l	#(Char_height+1)*Bytes_per_line,d0	; Make dummy screen
	jsr	Allocate_CHIP
	jsr	Clear_memory
	move.w	d0,-(sp)
	jsr	Claim_pointer
	move.l	d0,Work_screen
	move.w	#26,Shadow_colour		; Set colours
	moveq.l	#0,d0			; Print string
	moveq.l	#0,d1
	jsr	Put_text_line
	moveq.l	#5,d5			; Get block
	moveq.l	#Char_height+1,d7
	Get	d4,a0
	jsr	Get_block
	Free	d4
	move.l	Off_screen,Work_screen	; Reset
	move.w	#0,Shadow_colour
	move.w	(sp)+,d0			; Destroy screen
	jsr	Free_pointer
	jsr	Free_memory
	move.b	d4,d0			; Output
	move.w	(sp)+,d7
	movem.l	(sp)+,d1-d5/a0
	rts

;*****************************************************************************
; [ Find a text block in a LARGE text file ]
;   IN : d0 - Text block number [0...] (.w)
;        a0 - Pointer to large text file (.l)
;  OUT : a0 - Pointer to text (.l)
; Changed registers : a0
;*****************************************************************************
Find_large_text:
	movem.l	d0/d7/a1,-(sp)
	move.w	(a0)+,d7			; Get number of texts
	move.l	a0,a1
	cmp.w	d7,d0			; Legal block number ?
	bmi.s	.Yes
	move.l	Text_error_text_ptr,a0		; No
	bra.s	.Exit
.Yes:	add.w	d7,d7			; Skip block lengths
	add.w	d7,a0
	bra.s	.Entry			; Find block
.Loop:	add.w	(a1)+,a0
.Entry:	dbra	d0,.Loop
.Exit:	movem.l	(sp)+,d0/d7/a1
	rts

;*****************************************************************************
; [ Find a text block in a SMALL text file ]
;   IN : d0 - Text block number [0...] (.w)
;        a0 - Pointer to small text file (.l)
;  OUT : a0 - Pointer to text (.l)
; Changed registers : a0
;*****************************************************************************
Find_small_text:
	move.l	d0,-(sp)
	bra.s	.Entry			; Skip unwanted blocks
.Loop:	tst.b	(a0)+
	bne.s	.Loop
.Entry:	dbra	d0,.Loop
	move.l	(sp)+,d0
	rts

;***************************************************************************	
; [ Standard numerical input requester DisInit ]
;   IN : a1 - Pointer to icon graphics / 0 (.l)
;        a2 - Pointer to icon string (.l)
; No registers are restored
;***************************************************************************	
InputNr_DisInit:
	move.l	Minimum_number,InputNr_number	; Reset
	move.w	#InputNr_X-16,d0		; Open window
	move.w	#InputNr_Y-16,d1
	moveq.l	#11,d2
	moveq.l	#6,d3
	lea.l	InputNr_L1,a0
	jsr	Open_window
	cmp.l	#0,a1			; Any icon ?
	beq	.No_icon
	move.w	#InputNr_X-1,d0		; Draw box around icon
	move.w	#InputNr_Y-1,d1
	moveq.l	#16,d2
	moveq.l	#16,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display icon
	addq.w	#1,d1
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
	move.l	a1,a0
	jsr	Put_masked_block2
	move.w	#InputNr_X+19,d0		; Draw box around name
	move.w	#InputNr_Y+2,d1
	move.w	#122,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	move.w	#20,Ink_colour		; Print icon name
	addq.w	#1,d0
	addq.w	#2,d1
	move.l	a2,a0
	jsr	Print_centered_string
.No_icon:	move.l	Prompts_ptr,a0		; Get prompt address
	move.w	InputNr_prompt,d0
	jsr	Find_large_text
	move.w	#InputNr_X-1,d0		; Draw box around prompt
	move.w	#InputNr_Y+16+2,d1
	move.w	#142,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	move.w	#17,Ink_colour		; Print prompt
	addq.w	#1,d0
	addq.w	#2,d1
	jsr	Print_centered_string
	move.w	#InputNr_X-1,d0		; Draw box around icons
	move.w	#InputNr_Y+29,d1
	move.w	#32,d2
	moveq.l	#34,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display up icon
	addq.w	#1,d1
	moveq.l	#Up_2D_cicon,d3
	jsr	Display_up_button
	addi.w	#17,d1			; Display down icon
	moveq.l	#Down_2D_cicon,d3
	jsr	Display_up_button
	move.w	#InputNr_X+111,d0		; Draw box around exit icon
	move.w	#InputNr_Y+46,d1
	move.w	#32,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display OK icon
	addq.w	#1,d1
	moveq.l	#OK_cicon,d3
	jsr	Display_up_button
	jmp	Update_screen

Show_InputNr:
	movem.l	d0-d3/d7/a0,-(sp)
	move.w	#InputNr_X+47,d0		; Draw box around number
	move.w	#InputNr_Y+38,d1
	move.w	#48,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	move.l	InputNr_number,d0		; Convert number
	moveq.l	#5,d7
	lea.l	Hull_number,a0		; BUILD: Hull_number (see HULL/MODULE_C.S)
	jsr	DecL_convert
	move.w	#31,Ink_colour		; Print number
	move.w	#InputNr_X+48,d0
	move.w	#InputNr_Y+40,d1
	lea.l	Hull_number,a0
	jsr	Print_centered_string
	movem.l	(sp)+,d0-d3/d7/a0
	rts

InputNr_input:
	jsr	Wait_4_unclick
	move.w	#InputNr_X+48,d0		; Input string
	move.w	#InputNr_Y+40,d1
	moveq.l	#7,d2
	jsr	Input_string
	tst.b	(a0)			; Anything ?
	beq.s	.Exit
	jsr	String_to_number		; Yes -> Convert to number
	cmp.l	Minimum_number,d0		; Clip below
	bge.s	.No
	move.l	Minimum_number,d0
	bra.s	.Store
.No:	cmp.l	Maximum_number,d0		; Clip above
	ble.s	.Store
	move.l	Maximum_number,d0
.Store:	move.l	d0,InputNr_number		; Store
.Exit:	jsr	Show_InputNr		; Show
	jmp	Update_screen

InputNr_arrow_up:
	move.l	InputNr_number,d0		; Get number
	cmp.l	Maximum_number,d0		; Maximum ?
	blt.s	.Ok1
	move.w	#InputNr_X,d0		; Feedback
	move.w	#InputNr_Y+30,d1
	moveq.l	#Up_2D_cicon,d3
	jsr	Feedback
	bra	.Exit
.Ok1:	addq.l	#1,d0			; Increase
	move.l	d0,InputNr_number
	jsr	Show_InputNr		; Button down
	move.w	#InputNr_X,d0
	move.w	#InputNr_Y+30,d1
	moveq.l	#Up_2D_cicon,d3
	jsr	Display_down_button
	jsr	Update_screen
	move.w	#First_add,d7		; Reset
.Wait:	move.b	Button_state,d0		; Still pressed ?
	btst	#Left_pressed,d0
	beq.s	.Done
	move.l	InputNr_number,d0		; Get number
	moveq.l	#0,d1			; Increase
	move.w	d7,d1
	lsr.w	#8,d1
	add.l	d1,d0
	cmp.l	Maximum_number,d0		; Maximum	?
	bmi.s	.Skip
	move.l	Maximum_number,InputNr_number	; Maximum reached
	jsr	Show_InputNr
	jsr	Update_screen
	jsr	Wait_4_unclick		; Wait
	bra.s	.Done
.Skip:	addi.w	#Add_delta,d7		; Faster baby
	bpl.s	.Ok2
	move.w	#$7fff,d7
.Ok2:	move.l	d0,InputNr_number		; Store number
	jsr	Show_InputNr		; Display number
	jsr	Update_screen
	bra.s	.Wait
.Done:	move.w	#InputNr_X,d0		; Button up
	move.w	#InputNr_Y+30,d1
	moveq.l	#Up_2D_cicon,d3
	jsr	Display_up_button
	jsr	Update_screen
.Exit:	rts

InputNr_arrow_down:
	move.l	InputNr_number,d0		; Get number
	cmp.l	Minimum_number,d0		; Minimum ?
	bgt.s	.Ok1
	move.w	#InputNr_X,d0		; Feedback
	move.w	#InputNr_Y+47,d1
	moveq.l	#Down_2D_cicon,d3
	jsr	Feedback
	bra	.Exit
.Ok1:	subq.l	#1,d0			; Decrease
	move.l	d0,InputNr_number
	jsr	Show_InputNr		; Button down
	move.w	#InputNr_X,d0
	move.w	#InputNr_Y+47,d1
	moveq.l	#Down_2D_cicon,d3
	jsr	Display_down_button
	jsr	Update_screen
	move.w	#First_add,d7		; Reset
.Wait:	move.b	Button_state,d0		; Still pressed ?
	btst	#Left_pressed,d0
	beq.s	.Done
	move.l	InputNr_number,d0		; Get number
	moveq.l	#0,d1			; Decrease
	move.w	d7,d1
	lsr.w	#8,d1
	sub.l	d1,d0
	cmp.l	Minimum_number,d0		; Minimum ?
	bpl.s	.Skip
	move.l	Minimum_number,InputNr_number	; Minimum reached
	jsr	Show_InputNr
	jsr	Update_screen
	jsr	Wait_4_unclick		; Wait
	bra.s	.Done
.Skip:	addi.w	#Add_delta,d7		; Faster baby
	bpl.s	.Ok2
	move.w	#$7fff,d7
.Ok2:	move.l	d0,InputNr_number		; Store number
	jsr	Show_InputNr		; Display number
	jsr	Update_screen
	bra.s	.Wait
.Done:	move.w	#InputNr_X,d0		; Button up
	move.w	#InputNr_Y+47,d1
	moveq.l	#Down_2D_cicon,d3
	jsr	Display_up_button
	jsr	Update_screen
.Exit:	rts

InputNr_arrow_1up:
	move.l	InputNr_number,d0		; Get number
	cmp.l	Maximum_number,d0		; Maximum	?
	bge.s	.No
	addq.l	#1,d0			; Increase
	move.l	d0,InputNr_number
	jsr	Show_InputNr
	jsr	Update_screen
.No:	move.w	#InputNr_X,d0		; Feedback
	move.w	#InputNr_Y+30,d1
	moveq.l	#Up_2D_cicon,d3
	jsr	Feedback
.Exit:	rts

InputNr_arrow_1down:
	move.l	InputNr_number,d0		; Get number
	cmp.l	Minimum_number,d0		; Minimum	?
	ble.s	.No
	subq.l	#1,d0			; Decrease
	move.l	d0,InputNr_number
	jsr	Show_InputNr
	jsr	Update_screen
.No:	move.w	#InputNr_X,d0		; Feedback
	move.w	#InputNr_Y+47,d1
	moveq.l	#Down_2D_cicon,d3
	jsr	Feedback
.Exit:	rts

InputNr_all_up:
	move.l	Maximum_number,InputNr_number	; Maximum
	jsr	Show_InputNr
	jsr	Update_screen
	move.w	#InputNr_X,d0		; Feedback
	move.w	#InputNr_Y+30,d1
	moveq.l	#Up_2D_cicon,d3
	jsr	Feedback
	rts

InputNr_all_down:
	move.l	Minimum_number,InputNr_number	; Minimum
	jsr	Show_InputNr
	jsr	Update_screen
	move.w	#InputNr_X,d0		; Feedback
	move.w	#InputNr_Y+47,d1
	moveq.l	#Down_2D_cicon,d3
	jsr	Feedback
	rts

InputNr_exit:
	move.w	#InputNr_X+112,d0		; Feedback
	move.w	#InputNr_Y+47,d1
	moveq.l	#OK_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	Pop	Module			; Exit
.Exit:	rts

;*****************************************************************************
; [ Handle disk error ]
;   IN : d0 - Error number (.w)
; No registers are restored
;*****************************************************************************
Disk_error_handler:
	cmp.w	#ERROR_DISK_WRITE_PROTECTED,d0	; Write protect ?
	beq.s	.Write
	lea.l	Disk_errors,a0		; Seek error
.Again:	tst.w	(a0)			; End of list ?
	beq.s	.End
	cmp.w	(a0)+,d0			; Is this it ?
	beq.s	.Found
	addq.l	#2,a0			; Next error
	bra.s	.Again
; ---------- Write protect error ------------------
.Write:	move.w	#138,d0			; Write protected
	jsr	Prompt_req		; Request
	bra.s	.Done
; ---------- Unknown error ------------------------
.End:	moveq.l	#93,d0			; Probably read/write
	bra.s	.Skip
; ---------- Known error --------------------------
.Found:	move.w	(a0),d0			; Get prompt number
.Skip:	move.l	Prompts_ptr,a0		; Get prompt address
	jsr	Find_large_text
	lea.l	Known_error_text,a1		; Make error message
	move.l	a0,4(a1)
	move.l	Current_filename,12(a1)
	move.l	a1,ReqText_ptr		; Error requester
	st	Req_NO
	Push	Module,Req_Mod		; Request
	move.b	Req_result,d0
.Done:	tst.b	d0			; Retry ?
	bne.s	.Exit
	jsr	Close_current_file		; No
	move.l	#OS_ERROR,Return_value	; Exit
	jmp	Exit_program
.Exit:	rts

Disk_errors:
	dc.w ERROR_NO_FREE_STORE,1
	dc.w ERROR_OBJECT_IN_USE,2
	dc.w ERROR_OBJECT_EXISTS,3
	dc.w ERROR_DIR_NOT_FOUND,4
	dc.w ERROR_OBJECT_NOT_FOUND,5
	dc.w ERROR_OBJECT_TOO_LARGE,6
	dc.w ERROR_INVALID_COMPONENT_NAME,7
	dc.w ERROR_OBJECT_WRONG_TYPE,8
	dc.w ERROR_DISK_NOT_VALIDATED,9
	dc.w ERROR_RENAME_ACROSS_DEVICES,10
	dc.w ERROR_SEEK_ERROR,11
	dc.w ERROR_DISK_FULL,12
	dc.w ERROR_WRITE_PROTECTED,14
	dc.w ERROR_READ_PROTECTED,15
	dc.w ERROR_NOT_A_DOS_DISK,16
	dc.w ERROR_INCOMPLETE_READ,13
	dc.w ERROR_INCOMPLETE_WRITE,17
	dc.w 0

;*****************************************************************************
; [ Disk requester ]
;   IN : d0 - Disk number (.w)
; No registers are restored
;*****************************************************************************
Disk_requester:
	cmp.w	#Save_game_disk,d0		; Is save-game disk ?
	bne.s	.No
	lea.l	Save_disk_request_text,a1	; Yes -> Special text
	bra.s	.Do
.No:	lea.l	Disk_request_text,a1	; No -> Create text
	lea.l	Hull_number,a0
	move.l	a0,4(a1)
	addi.b	#"A"-1,d0
	move.b	d0,(a0)+
	clr.b	(a0)
.Do:	move.l	a1,ReqText_ptr
	st	Req_NO
	Push	Module,DiskReq_Mod		; Request
	tst.b	Req_result		; No ?
	bne.s	.Exit
	moveq.l	#60,d0			; Really ?
	jsr	Prompt_req
	tst.b	d0
	beq	.Exit
	jsr	Close_current_file		; Yes
	jmp	Exit_program		; Bye-bye
.Exit:	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
TxtW_PA:	dc.w TxtW_X+16,TxtW_X+271,0,0
	dc.w 31,0,Window_colour
MaxTxtW_PA:
	dc.w TxtW_X+16,TxtW_X+271,TxtW_Y+16,TxtW_Y+127
	dc.w 31,0,Window_colour
ReqW_PA:	dc.w ReqW_X,ReqW_X+12*16-1,0,0
	dc.w 31,0,Window_colour
MemberSel_MA:	dc.w 0,319,0,35

; 1 - Top-right / bottom-left pixels
; 2 - Bottom-right dark edge
; 3 - Top-left light edge
; 4 - Middle main area
; 5 - Highlight

Unselected_thingy_colours:
	dc.w 28,27,30,29,31
Selected_thingy_colours:
	dc.w 29,28,31,30,31
;	dc.w 20,19,16,17,2		; Yellow/red thingy for main palette

; *** SCROLL BAR : 2nd layer ***
ScrollBar_L2:
	dc.w 0,0,0,0
	dc.b 255
	even
	dc.l 0,0

; *** REQUESTER : 1st layer ***
Req_L1:	dc.w 0,0
	dc.w 64,95,0,16
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 96,127,0,16
	dc.b 2
	even
	dc.l 0,0

; *** INPUT NUMBER WINDOW : 1st layer ***
InputNr_L1:
	dc.w 0,0
	dc.w 0,143,0,63			; Item window area
	dc.b 1
	even
	dc.l 0,InputNr_L2

; *** INPUT NUMBER WINDOW : 2nd layer ***
InputNr_L2:
	dc.w 0,31,30,30+16			; Arrow up icon
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 0,31,47,47+16			; Arrow down icon
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 112,112+31,47,47+16		; Exit icon
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 48,95,40,47			; Number area
	dc.b 4
	even
	dc.l 0,0

Icon_pos:	dc.w 208,143,240,143,272,143
	dc.w 208,160,240,160,272,160
	dc.w 208,177,240,177,272,177

	SECTION	Fast_BSS,bss
Continuous_flag:	ds.b 1
Control_icon_flag:	ds.b 1
Req_NO:	ds.b 1
Req_result:	ds.b 1
	even
TxtW_ptr:	ds.l 1
ReqText_ptr:	ds.l 1
Req_icon_Y:	ds.w 1

Continuous_data:	ds.w 3
Continuous_nr:	ds.w 1
Continuous_ptr:	ds.l 1
Icon_update:	ds.w 1
CIL_buffer:	ds.w 9
Control_list_ptr:	ds.l 1

Scroll_bar_Sp:	ds.l 1			; Scroll bar stack
Scroll_bar_Stack_start:        
	ds.l Max_scroll_bars
Scroll_bar_Stack_end:

Scroll_bar_data_ptr:	ds.l 1		; Scroll bar data
Scroll_bar_MA:	ds.w 4
Thingy_selected:	ds.b 1
	even
; Scroll_bar_result:	rs.w 1		; Result of scroll bar
					; BUILD: "rs.w" did not reserve any memory here. In
					;  the executable this variable is located at the end
					;  of the CHIP BSS (see KERNEL/CHIP_BSS.S).

MemberSel_prompt:	ds.w 1
MemberSel_ptr:	ds.l 1
Selected_member:	ds.w 1

InputNr_prompt:	ds.w 1
InputNr_number:	ds.l 1
Maximum_number:	ds.l 1
Minimum_number:	ds.l 1
