; Text handling routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 2-7-1992

	XREF	HLC_table
	XREF	Outline_text
	XREF	Input_Mod
	XREF	Input_PA

	XDEF	Display_text
	XDEF	Display_text_and_wait
	XDEF	Input_string
	XDEF	Edit_string
	XDEF	Print_centered_string
	XDEF	Erase_PA
	XDEF	Push_PA
	XDEF	Pop_PA
	XDEF	Reset_PA_stack
	XDEF	Process_text
	XDEF	Text_height
	XDEF	Input_mask_table

	XDEF	Input_DisUpd
	XDEF	Input_ModInit
	XDEF	Input_ModExit
	XDEF	Input_clear
	XDEF	Input_backspace
	XDEF	Input_key
	XDEF	Input_abort
	XDEF	Input_aborted

	SECTION	Program,code
;*****************************************************************************
; [ Display & scroll a text / Wait for user if text was not scrolled ]
;   IN : d0 - Text handle of already processed text / 0 (.b)
;        a0 - Pointer to string list (if d0 = 0) (.l)
; All registers are restored
;*****************************************************************************
Display_text_and_wait:
	st	Text_wait_flag
Display_text:
	movem.l	d0-d2/d5-d7/a0,-(sp)
	jsr	Erase_PA			; Clear window
	jsr	Update_screen
	sf	Rune_flag			; Normal font
	tst.b	d0			; Already processed ?
	bne.s	.Yes
	jsr	Process_text		; Process text
.Yes:	move.b	d0,d7
	move.l	PA_Sp,a0			; Reset colour
	move.l	(a0),a0
	move.w	PA_Shadow(a0),Shadow_colour
; --------- Scroll at all ? -----------------------
	move.w	PA_height,d0		; Does it	fit ?
	cmp.w	Text_height,d0
	bmi.s	.Scroll
	cmp.w	#1,Text_height		; Yes -> Only one line ?
	bne	.More
	jsr	Erase_PA			; Yes -> Erase print area
	move.l	PA_Sp,a0			; Get PA
	move.l	(a0),a0
	move.w	PA_X1(a0),d0		; Load top-left coordinates
	move.w	PA_Y1(a0),d1
	move.w	PA_X2(a0),d2		; Get width
	sub.w	d0,d2
	Get	d7,a0			; Get text address
	move.b	(a0)+,d5			; Set ink
	subq.w	#1,d5
	move.w	d5,Ink_colour
	jsr	Print_centered_string	; Print string
	Free	d7
	bra.s	.Wait1
.More:	move.b	d7,d0			; More -> Show text
	moveq.l	#0,d1
	jsr	Refresh_text_window
.Wait1:	jsr	Update_screen
	tst.b	Text_wait_flag		; Wait ?
	beq.s	.No
	moveq.l	#10,d0			; Delay
	jsr	Delay
	jsr	Wait_4_user		; Yes
.No:	bra	.Exit
; --------- Scroll down ---------------------------
.Scroll:	moveq.l	#0,d6			; Number of pages
	move.w	Text_height,d6
	divu.w	PA_height,d6
	move.w	d6,d5			; Remaining lines
	mulu.w	PA_height,d5
	sub.w	Text_height,d5
	neg.w	d5
	move.w	PA_height,d1		; Show entire pages
	subq.w	#1,d1
	neg.w	d1
	bra.s	.Entry1
.Loop1:	move.w	PA_height,d2		; Show one page
	subq.w	#1,d2
.Loop2:	move.b	d7,d0			; Refresh
	jsr	Refresh_text_window
	jsr	Switch_screens
	addq.w	#1,d1			; Scroll down
	dbra	d2,.Loop2
	jsr	Copy_screen		; Wait
	jsr	Wait_4_user
.Entry1:	dbra	d6,.Loop1
	move.w	d5,d2			; Show last page
	beq.s	.None			; (if any)
	subq.w	#1,d2
.Loop3:	move.b	d7,d0			; Refresh
	jsr	Refresh_text_window
	jsr	Switch_screens
	addq.w	#1,d1			; Scroll down
	dbra	d2,.Loop3
	jsr	Copy_screen		; Wait
	jsr	Wait_4_user
; --------- Free scrolling ------------------------
.None:	jsr	Mouse_off
	lea.l	Scroll_MA,a0		; Make custom MA
	move.w	Text_height,d0
	sub.w	PA_height,d0
	mulu.w	#Char_height+2,d0
	move.w	d0,MA_Y2(a0)
	jsr	Push_MA
	subq.w	#1,d1			; Scroll
	move.w	d1,d0
	mulu.w	#Char_height+2,d0
	move.w	d0,Mouse_Y
.Again:	move.b	d7,d0			; Refresh
	jsr	Refresh_text_window
	jsr	Switch_screens
.Wait2:	btst	#Right_clicked,Button_state	; Mouse button pressed ?
	bne.s	.Done
	moveq.l	#0,d0			; Update scrolling
	move.w	Mouse_Y,d0
	divu.w	#Char_height+2,d0
	cmp.w	d0,d1
	beq.s	.Wait2
	move.w	d0,d1
	bra.s	.Again
; --------- Exit ----------------------------------
.Done:	jsr	Wait_4_unclick
	Pop	MA
	jsr	Mouse_on
	jsr	Copy_screen
.Exit:	move.b	d7,d0			; Free text memory
	jsr	Free_memory
	sf	Text_wait_flag
	movem.l	(sp)+,d0-d2/d5-d7/a0
	rts

;*****************************************************************************
; [ Refresh text window ]
;   IN : d0 - Processed text memory handle (.b)
;        d1 - Vertical offset in lines (.w)
; All registers are restored
;*****************************************************************************
Refresh_text_window:          
	movem.l	d0-d2/d5-d7/a0,-(sp)
	jsr	Erase_PA			; Erase print area
	move.w	d0,d5			; Save input
	move.w	d1,d6
	move.l	PA_Sp,a0			; Get PA
	move.l	(a0),a0
	move.w	PA_X1(a0),d0		; Load top-left coordinates
	move.w	PA_Y1(a0),d1
; --------- Scroll in ? ---------------------------
	tst.w	d6			; Well ?
	bpl	.Ok_1
	move.w	d6,d7			; Completely out ?
	neg.w	d7
	cmp.w	PA_height,d7
	bpl.s	.Exit
	move.w	d7,d2			; Adjust Y-coordinate
	mulu.w	#Char_height+2,d2
	add.w	d2,d1
	moveq.l	#0,d6			; Print from line 0
	sub.w	PA_height,d7		; Calculate height
	neg.w	d7
	bra.s	.Cont
; --------- Scroll out ? --------------------------
.Ok_1:	cmp.w	Text_height,d6		; Completely out ?
	bpl.s	.Exit
	move.w	Text_height,d7		; Remaining lines
	sub.w	d6,d7
	cmp.w	PA_height,d7		; Well ?
	bmi.s	.Cont
.Ok_2:	move.w	PA_height,d7
; --------- Display text --------------------------
.Cont:	Get	d5,a0			; Get text address
	bra.s	.Entry1			; Skip unwanted lines
.Loop1:	tst.b	(a0)+
	bne.s	.Loop1
.Entry1:	dbra	d6,.Loop1
	moveq.l	#0,d6			; Display text
	bra.s	.Entry2
.Loop2:	move.b	(a0)+,d6			; Set ink
	subq.w	#1,d6
	move.w	d6,Ink_colour
	jsr	Put_text_line		; Print line
	addq.w	#Char_height+2,d1
.Entry2:	dbra	d7,.Loop2
	Free	d5			; Exit
.Exit:	movem.l	(sp)+,d0-d2/d5-d7/a0
	rts

;*****************************************************************************
; [ Erase print area ]
; All registers are restored
;*****************************************************************************
Erase_PA:
	movem.l	d0-d4/a0,-(sp)
	move.l	PA_Sp,a0			; Get PA
	move.l	(a0),a0
	move.w	PA_Paper(a0),d4		; Transparent paper ?
	bmi.s	.Exit
	move.w	PA_X1(a0),d0		; Get X & Y coordinates
	move.w	PA_Y1(a0),d1
	move.w	PA_width,d2		; Draw paper box
	mulu.w	#Char_width+1,d2
	add.w	d0,d2
	subq.w	#1,d2
	move.w	PA_height,d3
	mulu.w	#Char_height+2,d3
	add.w	d1,d3
	subq.w	#1,d3
	jsr	Draw_box
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

;*****************************************************************************
; [ Input a string ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Maximum length of input string (.w)
;  OUT : a0 - Pointer to input string (.l)
; Changed registers : a0
; NOTE :
;  - A fitting PA will be installed.
;*****************************************************************************
Input_string:
	jsr	Wait_4_unclick
	jsr	Prepare_input		; Prepare input
	clr.b	Input_buffer		; Clear input string
	clr.w	Current_length
	Push	Module,Input_Mod		; Input
	lea.l	Input_buffer,a0		; Output
	tst.b	Input_aborted		; Aborted ?
	beq.s	.Exit
	clr.b	(a0)			; Yes
.Exit:	rts

;*****************************************************************************
; [ Edit an existing string ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Maximum length of input string (.w)
;        a0 - Pointer to original string (.l)
; All registers are restored
; NOTE :
;  - A fitting PA will be installed.
;*****************************************************************************
Edit_string:
	movem.l	d0/d1/a0/a1,-(sp)
	jsr	Wait_4_unclick
	jsr	Prepare_input		; Prepare input
	move.l	a0,Original_input
	jsr	Fill_input_buffer		; Fill input buffer
	Push	Module,Input_Mod		; Input
	tst.b	Input_aborted		; Aborted ?
	bne	.Exit
	move.w	Max_length,d1		; Copy back to original
	lea.l	Input_buffer,a0
	move.l	Original_input,a1
	jsr	Strlen			; Get new string length
	cmp.w	d0,d1			; Too long ?
	bpl.s	.No
	move.w	d1,d0			; Yes -> First part only
.No:	exg	a1,a0			; Copy
	jsr	Strncpy
	clr.b	(a0)			; Insert EOL
.Exit:	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Fill input buffer (edit) ]
; All registers are restored
;*****************************************************************************
Fill_input_buffer:
	movem.l	d0/d2/a0/a1,-(sp)
	move.w	Max_length,d1		; Copy original to buffer
	move.l	Original_input,a0
	lea.l	Input_buffer,a1
	jsr	Strlen			; Get original string length
	cmp.w	d0,d1			; Too long ?
	bpl.s	.No
	move.w	d1,d0			; Yes -> First part only
.No:	move.w	d0,Current_length		; Set length
	move.w	d0,d1			; Adjust cursor
	mulu.w	#Char_width+1,d1
	add.w	d1,Cursor_X
	exg	a1,a0			; Copy
	jsr	Strncpy
	clr.b	(a0)			; Insert EOL
	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Prepare input ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Maximum length of input string (.w)
; All registers are restored
;*****************************************************************************
Prepare_input:
	movem.l	d0-d2/a0,-(sp)
	move.w	d0,Cursor_X		; Store input
	move.w	d1,Cursor_Y
	move.w	d2,Max_length
	lea.l	Input_PA,a0		; Make PA
	move.w	d0,PA_X1(a0)
	move.w	d1,PA_Y1(a0)
	add.w	#Char_height+2,d1
	move.w	d1,PA_Y2(a0)
	addq.w	#1,d2
	mulu.w	#Char_width+1,d2
	add.w	d2,d0
	move.w	d0,PA_X2(a0)
	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Input module ]
;*****************************************************************************
Input_DisUpd:
	jsr	Erase_PA			; Erase input area
	lea.l	Input_buffer,a0		; Print input string
	move.w	Input_PA+PA_X1,d0
	move.w	Input_PA+PA_Y1,d1
	jsr	Put_text_line
	move.w	Cursor_timer,d0		; Time to blink cursor ?
	subq.w	#1,d0
	bne.s	.Ok
	not.b	Blink			; Toggle
	move.w	#Cursor_interval,d0		; Reset timer
.Ok:	move.w	d0,Cursor_timer		; Store
	tst.b	Blink			; Blink ?
	beq.s	.No
	move.w	Cursor_X,d0		; Show cursor
	move.w	Cursor_Y,d1
	move.w	d0,d2
	move.w	d1,d3
	add.w	#Char_width-1,d2
	add.w	#Char_height-1,d3
	moveq.l	#Cursor_colour,d4
	jsr	Draw_box
.No:	rts

Input_ModInit:
	jsr	Mouse_off
	move.w	#1,Cursor_timer		; Reset variables
	sf	Input_aborted
	rts

Input_ModExit:
	jmp	Mouse_on

Input_key:
	move.w	Current_length,d7		; Maximum length reached ?
	cmp.w	Max_length,d7
	beq	.Exit
	andi.w	#$00ff,d0			; Legal character ?
	cmpi.w	#32,d0
	bmi	.Exit
	lea.l	Input_mask_table-32,a0	; Translate
	move.b	0(a0,d0.w),d0
	cmp.b	#-1,d0
	beq	.Exit
	lea.l	Input_buffer,a0		; Insert
	move.b	d0,0(a0,d7.w)
	addq.w	#1,d7
	clr.b	0(a0,d7.w)
	move.w	d7,Current_length
	add.w	#Char_width+1,Cursor_X	; Cursor right
.Exit:	jsr	Reset_keyboard
	rts

Input_backspace:
	move.w	Current_length,d7		; Minimum length reached ?
	beq	.Exit
	lea.l	Input_buffer,a0		; Backspace
	subq.w	#1,d7
	clr.b	0(a0,d7.w)
	move.w	d7,Current_length
	sub.w	#Char_width+1,Cursor_X	; Cursor left
.Exit:	jsr	Reset_keyboard
	rts

Input_clear:
	clr.w	Current_length		; Clear string
	clr.b	Input_buffer
	move.w	Input_PA+PA_X1,Cursor_X	; Reset cursor
	jmp	Reset_keyboard

Input_abort:
	st	Input_aborted		; Set
	jsr	Wait_4_unclick		; Exit
	jmp	Pop_Module

;*****************************************************************************
; [ Print centered string ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Width of area in which to center (.w)
;        a0 - Pointer to string (.l)
; All registers are restored
;*****************************************************************************
Print_centered_string:        
	movem.l	d0/d2/d6,-(sp)
	move.w	d0,d6			; Get string length
	jsr	Strlen	
	exg.l	d0,d6
	mulu.w	#Char_width+1,d6		; Calculate new X-coordinate
	sub.w	d6,d2
	bmi.s	.Skip
	asr.w	#1,d2
	add.w	d2,d0
.Skip:	jsr	Put_text_line		; Print
	movem.l	(sp)+,d0/d2/d6
	rts

;*****************************************************************************
; [ Push a PA on the stack ]
;   IN : a0 - Pointer to PA (.l)
; All registers are restored
;*****************************************************************************
Push_PA:     
	move.l	a1,-(sp)
	movea.l	PA_Sp,a1
	addq.l	#4,a1
	cmpa.l	#PAStack_end,a1		; Possible ?
	beq.s	.Exit
	move.l	a0,(a1)			; Push
	move.l	a1,PA_Sp
	jsr	Init_PA			; Initialize new PA
.Exit:	movea.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Pop a PA from the stack ]
; All registers are restored
;*****************************************************************************
Pop_PA:      
	move.l	a0,-(sp)
	movea.l	PA_Sp,a0
	cmpa.l	#PAStack_start,a0		; Possible ?
	beq.s	.Exit
	subq.l	#4,a0			; Pop
	move.l	a0,PA_Sp
	move.l	(a0),a0			; Initialize old PA
	jsr	Init_PA
.Exit:	movea.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Reset the PA stack ]
; All registers are restored
;*****************************************************************************
Reset_PA_stack:    
	movem.l	a0/a1,-(sp)
	lea.l	Default_PA,a0		; Reset stack
	lea.l	PAStack_start,a1
	move.l	a1,PA_Sp
	move.l	a0,(a1)
	jsr	Init_PA			; Initialize default PA
	movem.l	(sp)+,a0/a1
	rts

;*****************************************************************************
; [ Initialize a PA ]
;   IN : a0 - Pointer to PA (.l)
; All registers are restored
;*****************************************************************************
Init_PA:
	move.l	d0,-(sp)
	moveq.l	#0,d0			; Calculate width
	move.w	PA_X2(a0),d0
	sub.w	PA_X1(a0),d0
	addq.w	#1,d0
	divu.w	#Char_width+1,d0
	bne.s	.Not_zero1
	moveq.l	#1,d0
.Not_zero1:
	move.w	d0,PA_width		; Store
	moveq.l	#0,d0			; Calculate height
	move.w	PA_Y2(a0),d0
	sub.w	PA_Y1(a0),d0
	addq.w	#1,d0
	divu.w	#Char_height+2,d0
	bne.s	.Not_zero2
	moveq.l	#1,d0
.Not_zero2:
	move.w	d0,PA_height		; Store
	move.w	PA_Ink(a0),Ink_colour	; Set colours
	move.w	PA_Shadow(a0),Shadow_colour
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Process a text ]
;   IN : a0 - Pointer to string list (.l)
;  OUT : d0 - Handle of processed text (.b)
; All registers are restored
;*****************************************************************************
Process_text:      
	movem.l	d1-d4/d7/a0-a3/a5,-(sp)
	lea.l	-Process_LDS(sp),sp		; Create local variables
	move.l	sp,a5
	opt	o2-				; (not optimized by the original assembler)
	move.l	a0,Text_list_ptr(a5)	; Store input
	opt	o2+
	move.w	PA_width,d7
	move.l	PA_Sp,a3			; Reset colour
	move.l	(a3),a3
	move.w	PA_Ink(a3),Current_ink
; --------- Estimate length of processed text ------------------------------
	moveq.l	#0,d1			; Add all string lengths
	move.l	a0,a1
.Again1:	move.l	(a1)+,d0			; End of list ?
	beq.s	.End1
	move.l	d0,a0			; Get string length
	jsr	Strlen
	add.l	d0,d1
	addq.l	#1,d1
	bra.s	.Again1
.End1:	tst.l	d1			; Completely empty ?
	beq	.Exit
	move.l	d1,d0			; Estimate length of raw
	lsr.l	#1,d0			;  text
	add.l	d0,d1
	move.l	d1,Raw_length(a5)
	move.l	d1,d0			; Allocate raw text buffer
	jsr	Allocate_memory
	move.b	d0,Raw_text_handle(a5)
	move.w	d7,d0			; Estimate length of
	divu.w	d0,d1			;  processed text
	bne.s	.Not
	moveq.l	#1,d1
.Not:	addq.w	#2,d0			; + 2 for EOL & Ink
	mulu.w	d1,d0
	tst.b	Outline_text		; Outline ?
	bne.s	.Outline1
	move.l	d0,d1			; No -> + 50% error margin
	lsr.l	#1,d1
	add.l	d1,d0
	bra.s	.Go_on3
.Outline1:	add.l	d0,d0			; Yes -> + 100% error margin
.Go_on3:	move.l	d0,Processed_length(a5)	; Store length
; --------- Merge all strings into one -------------------------------------
	move.b	Raw_text_handle(a5),d0
	jsr	Claim_pointer
	move.l	d0,a0
	move.l	d0,a3
	opt	o2-				; (not optimized by the original assembler)
	move.l	Text_list_ptr(a5),a2
	opt	o2+
.Again2:	move.l	(a2)+,d0			; End of list ?
	beq.s	.End2
	move.l	d0,a1
.Again3:	move.b	(a1)+,d0			; Read character
	beq.s	.Again2			; End of line ?
	cmp.b	#Command_char,d0		; Command ?
	bne.s	.No_com1
	jsr	HLC_handler		; Handle it
	bra.s	.Again3
.No_com1:	move.b	d0,(a0)+			; Copy character
	bra.s	.Again3
.End2:	clr.b	(a0)+			; Insert EOL
	move.l	a0,d1			; Calculate real length
	sub.l	a3,d1
	cmp.l	Raw_length(a5),d1		; Estimating error ?
	ble.s	.Ok1
	move.l	#MERGED_TEXT_TOO_LONG,Return_value	; Yes -> Exit
	jmp	Exit_program
.Ok1:	move.l	d1,Raw_length(a5)		; Store real length
	move.b	Raw_text_handle(a5),d0	; Shrink raw text buffer
	jsr	Shrink_memory
	jsr	Free_pointer
; --------- Format text ----------------------------------------------------
	move.l	Processed_length(a5),d0	; Allocate processed text
	jsr	Allocate_memory		;  buffer
	move.b	d0,Processed_text_handle(a5)
	jsr	Claim_pointer
	move.l	d0,a0
	move.l	a3,a1
	moveq.l	#0,d1

; ******* Register contents *******
;	d0 - Visible X
;	d1 - Y
;	d2 - Real X
;	d7 - PA width
;	a0 - Pointer to processed text
;	a1 - Pointer to raw text
;	a3 - Pointer to start of line in raw text

.Next_line:
	moveq.l	#0,d0			; Reset
	addq.w	#1,d1
	moveq.l	#0,d2
.Space:	cmp.b	#" ",(a1)+		; Remove spaces at the
	beq.s	.Space			;  start of a line
	subq.l	#1,a1
	move.l	a1,a3
.Again4:	move.b	(a1)+,d3			; Read character
	beq	.End3			; End of text ?
; --------- Handle carriage returns ---------------
	cmp.b	#CR,d3			; Carriage return ?
	bne.s	.No_CR
	jsr	Add_line			; Add line
	bra.s	.Next_line		; Next line
; --------- Skip text commands --------------------
.No_CR:	cmp.b	#Command_char,d3		; Command character ?
	bne.s	.No_com2
	addq.w	#2,d2
.Seek1:	cmpi.b	#Command_char,(a1)+		; Seek command end &
	beq.s	.Again4 			;  update real X
	addq.w	#1,d2
	bra.s	.Seek1
; --------- Next character ------------------------
.No_com2:	addq.w	#1,d0			; X = X + 1
	addq.w	#1,d2
	cmp.w	d0,d7			; Line too long ?
	bpl.s	.Again4
; --------- Search for last space -----------------
	move.w	d2,d4			; Save real X
.Again5:	move.b	-(a1),d3			; Read character
	cmpi.b	#" ",d3			; Space ?
	beq.s	.Found
	cmpi.b	#Command_char,d3		; Command	end ?
	bne.s	.No_com3
	subq.w	#2,d2
.Seek2:	cmpi.b	#Command_char,-(a1)		; Seek command start
	beq.s	.Again5
	subq.w	#1,d2
	bra.s	.Seek2
.No_com3:	tst.w	d2			; Start of line ?
	ble.s	.Found
	subq.w	#1,d0
	subq.w	#1,d2
	bgt.s	.Again5
; --------- Wrap line -----------------------------
.Found:	tst.w	d2			; Back at	the start	?
	beq.s	.No_wrap
	addq.l	#1,a1			; Skip space
	bra.s	.Go_on1
.No_wrap:	add.w	d4,a1			; Cut off	word
	subq.l	#1,a1
	move.w	d7,d0
	subq.w	#1,d0
	move.w	d4,d2
	subq.w	#1,d2
.Go_on1:	tst.b	Outline_text		; Outline ?
	bne.s	.Outline2
	jsr	Add_line			; No -> Add line
	bra	.Next_line		; Next line
.Outline2:	jsr	Outline_string		; Outline
	bra	.Next_line
; --------- End of text ---------------------------
.End3:	tst.w	d2			; Last line empty ?
	bne.s	.Not_zero
	subq.w	#1,d1			; One line less
	bra.s	.Go_on2
.Not_zero:	jsr	Add_line			; Add line
.Go_on2:	move.w	d1,Text_height		; Store height
	move.b	Raw_text_handle(a5),d0	; Free raw text
	jsr	Free_pointer
	jsr	Free_memory
	move.b	Processed_text_handle(a5),d0	; Calculate real length
	jsr	Free_pointer
	jsr	Claim_pointer
	move.l	a0,d1
	sub.l	d0,d1
	cmp.l	Processed_length(a5),d1	; Estimating error ?
	ble.s	.Ok2
	move.l	#PROCESSED_TEXT_TOO_LONG,Return_value	; Yes -> Exit
	jmp	Exit_program
.Ok2:	move.l	d1,Processed_length(a5)	; Store real length
	move.b	Processed_text_handle(a5),d0	; Shrink processed text buffer
	jsr	Shrink_memory
	jsr	Free_pointer
.Exit:	lea.l	Process_LDS(sp),sp		; Destroy local variables
	movem.l	(sp)+,d1-d4/d7/a0-a3/a5
	rts

	rsreset
Text_list_ptr:	rs.l 1
Raw_length:	rs.l 1
Processed_length:	rs.l 1
Raw_text_handle:	rs.b 1
Processed_text_handle:	rs.b 1
Process_LDS:	rs.b 0

;*****************************************************************************
; [ Scan line for ink codes ]
;   IN : d2 - Real length of source string (.w)
;        a0 - Pointer to destination string (.l)
;        a3 - Pointer to source string (.l)
;  OUT : a0 - Pointer to destination string + 1 (.l)
; Changed registers : a0
;*****************************************************************************
Scan_line_for_ink:
	movem.l	d0-d2/a3,-(sp)
	move.w	Current_ink,d0		; Default is current
.Seek1:	cmp.b	#Command_char,(a3)+		; Seek command start
	beq.s	.Found1
	dbra	d2,.Seek1
	bra.s	.Exit
.Found1:	move.b	(a3)+,d1			; Get command
	lsl.w	#8,d1
	move.b	(a3)+,d1
	swap	d1
	move.b	(a3)+,d1
	lsl.w	#8,d1
	move.b	(a3)+,d1
	cmp.l	#Ink_command,d1		; Is Ink command ?
	beq.s	.Yes
.Seek2:	cmp.b	#Command_char,(a3)+		; No -> Seek command end
	beq.s	.Seek1
	dbra	d2,.Seek2
	bra.s	.Exit
.Yes:	moveq.l	#0,d0			; Convert two bytes
	move.b	(a3)+,d0			;  to number
	subi.b	#"0",d0
	mulu.w	#10,d0
	add.b	(a3)+,d0
	subi.b	#"0",d0
	andi.w	#Pal_size-1,d0		; Is new ink colour
	addq.l	#1,a3			; Skip end of command code
	bra.s	.Seek1
.Exit:	move.w	d0,Current_ink		; Is new current ink
	addq.w	#1,d0			; Insert ink + 1 (!!)
	move.b	d0,(a0)+
	movem.l	(sp)+,d0-d2/a3
	rts

;*****************************************************************************
; [ Add a line to the processed text ]
;   IN : d2 - Real length of source string (.w)
;        a0 - Pointer to destination string (.l)
;        a3 - Pointer to source string (.l)
;  OUT : a0 - Pointer to end of string (.l)
; Changed registers : a0
;*****************************************************************************
Add_line:
	jsr	Scan_line_for_ink		; Insert ink colour
	movem.l	d0/a1,-(sp)		; Copy string
	move.w	d2,d0
	move.l	a3,a1
	jsr	Strncpy
	movem.l	(sp)+,d0/a1
	clr.b	(a0)+			; Insert EOL
	rts

;*****************************************************************************
; [ Outline a string left and right ]
;   IN : d0 - Visible length of source string (.w)
;        d2 - Real length of source string (.w)
;        d7 - Width of PA (.w)
;        a0 - Pointer to destination string (.l)
;        a3 - Pointer to source string (.l)
;  OUT : a0 - Pointer to end of string (.l)
; Changed registers : a0
; Notes :
;   - This routine assumes the initial spaces are skipped.
;*****************************************************************************
Outline_string:     
	jsr	Scan_line_for_ink		; Insert ink colour
	movem.l	d0-d3/d5-d7/a1/a3,-(sp)
	move.w	PA_width,d7
	move.w	d2,d6
	tst.w	d6			; Empty string ?
	bne.s	.Again1
.Superfluous:
	move.l	a3,a1			; Copy string
	move.w	d6,d0
	jsr	Strncpy
	clr.b	(a0)+			; Insert EOL
	bra	.Exit
.Again1:	cmp.b	#" ",-1(a3,d6.w)		; Ignore spaces at the end
	bne.s	.Done1
	subq.w	#1,d0
	subq.w	#1,d6
	bne.s	.Again1
; --------- Count spaces ---------------------------------------------------
.Done1:	move.l	a3,a1
	moveq.l	#0,d1
	move.w	d6,d5
	bra.s	.Entry1
.Loop1:	move.b	(a1)+,d2			; Read character
	cmp.b	#Command_char,d2		; Command character ?
	bne.s	.No_com1
	subq.w	#1,d5
	bmi.s	.End1
.Seek1:	cmpi.b	#Command_char,(a1)+		; Seek end of command
	beq.s	.Entry1
	dbra	d5,.Seek1
	bra.s	.End1
.No_com1:	cmp.b	#" ",d2			; Is it a space ?
	bne.s	.Entry1
	addq.w	#1,d1			; Yes, count
.Entry1:	dbra	d5,.Loop1
.End1:	tst.w	d1			; Any spaces ?
	beq.s	.Superfluous
; --------- Divide spaces --------------------------------------------------
	lea.l	Space_table,a1		; Clear space table
	move.w	d1,d2
	subq.w	#1,d2
.Loop2:	clr.b	0(a1,d2.w)
	dbra	d2,.Loop2
	move.w	d7,d2			; Calculate extra spaces
	sub.w	d0,d2
	moveq.l	#0,d3			; Divide spaces
.Again2:	cmp.w	d1,d2			; End of loop ?
	bmi.s	.Done2
	addq.b	#1,0(a1,d3.w)		; Add one
	subq.w	#1,d2			; Count down
	addq.w	#1,d3			; Next space
	cmp.w	d1,d3
	bne.s	.Again2
	moveq.l	#0,d3
	bra.s	.Again2
.Done2:	moveq.l	#0,d3			; Seed = 0
	bra.s	.Entry4			; Divide remainder
.Loop4:	moveq.l	#0,d0			; Select random space
	move.w	d3,d0
	divu.w	d1,d0
	mulu.w	d1,d0
	sub.w	d3,d0
	neg.w	d0
	addq.b	#1,0(a1,d0.w)		; Add one
	move.w	d3,d0			; Next random number
	lsl.w	#4,d3
	add.w	d0,d3
	addi.w	#17,d3
.Entry4:	dbra	d2,.Loop4
; --------- Copy & format string -------------------------------------------
	move.w	d6,d5
	bra.s	.Entry5
.Loop5:	move.b	(a3)+,d2			; Read character
	move.b	d2,(a0)+			; Copy character
	cmp.b	#Command_char,d2		; Command character ?
	bne.s	.No_com2
	subq.w	#1,d5
	bmi.s	.End2
.Seek2:	move.b	(a3)+,d2			; Read character
	move.b	d2,(a0)+			; Copy character
	cmp.b	#Command_char,d2		; End of command ?
	beq.s	.Entry5
	dbra	d5,.Seek2
	bra.s	.End2
.No_com2:	cmp.b	#" ",d2			; Is it a space ?
	bne.s	.Entry5
	moveq.l	#0,d3			; Yes, insert extra spaces
	move.b	(a1)+,d3
	bra.s	.Entry6
.Loop6:	move.b	d2,(a0)+
.Entry6:	dbra	d3,.Loop6
.Entry5:	dbra	d5,.Loop5
.End2:	clr.b	(a0)+			; Insert EOL
.Exit:	movem.l	(sp)+,d0-d3/d5-d7/a1/a3
	rts

;*****************************************************************************
; [ Text command handler - high level ]
;   IN : a0 - Pointer to raw text (.l)
;        a1 - Pointer to command (.l)
;  OUT : a0 - Pointer to raw text (.l)
;        a1 - Pointer to string after command (.l)
; Changed registers : a0,a1
;*****************************************************************************
HLC_handler:
	movem.l	d0-d7/a2-a6,-(sp)
	move.b	(a1)+,d0			; Get command
	lsl.w	#8,d0
	move.b	(a1)+,d0
	swap	d0
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	lea.l	HLC_table,a2
.Again:	tst.l	(a2)			; End of command list ?
	bne.s	.Not_end
; --------- Command is unknown -> copy to raw text -------------------------
	move.b	#Command_char,(a0)+		; Copy command to raw text
	rol.l	#8,d0
	move.b	d0,(a0)+
	rol.l	#8,d0
	move.b	d0,(a0)+
	rol.l	#8,d0
	move.b	d0,(a0)+
	rol.l	#8,d0
	move.b	d0,(a0)+
.Seek1:	move.b	(a1)+,d0			; Copy command
	move.b	d0,(a0)+
	cmp.b	#Command_char,d0		; End of command ?
	bne.s	.Seek1
	bra.s	.Exit
.Not_end:	cmp.l	(a2)+,d0			; Found ?
	bne.s	.Again
; --------- Command is known -> execute & skip -----------------------------
	move.l	(a2),a2			; Execute
	jsr	(a2)
.Seek2:	cmp.b	#Command_char,(a1)+		; End of command ?
	bne.s	.Seek2
.Exit:	movem.l	(sp)+,d0-d7/a2-a6
	rts

;***************************************************************************	
; The DATA & BSS segments	
;***************************************************************************	
	SECTION	Fast_DATA,data
Scroll_MA:	dc.w 0,319,0,0
Default_PA:
	dc.w 0,(Screen_width*16)-1
	dc.w 0,Screen_height-1
	dc.w 31,0,27

Input_mask_table:
	dc.b " !""#",-1,"%&'"
	dc.b "()*+,-./"
	dc.b "0123456789"
	dc.b ":;",-1,"=",-1,"?",-1
	dc.b "ABCDEFGHIJ"
	dc.b "KLMNOPQRST"
	dc.b "UVWXYZ"
	dc.b -1,-1,-1,-1,"_",-1
	dc.b "ABCDEFGHIJ"
	dc.b "KLMNOPQRST"
	dc.b "UVWXYZ"
	dcb.b 6,-1
	dc.b "Ü"				; Ü ATARI
	dc.b "È"				; È ATARI
	dc.b "A"				; À ATARI
	dc.b "Ä"				; ä ATARI
	dc.b "À"				; À ATARI
	dc.b -1
	dc.b "Ç"				; Ç ATARI
	dc.b "È"				; È ATARI
	dc.b -1
	dc.b "È"				; È ATARI
	dcb.b 3,-1
	dc.b "Ä"				; Ä ATARI
	dc.b -1
	dc.b "È"				; È ATARI
	dcb.b 3,-1
	dc.b "Ö"				; ö ATARI
	dc.b -1
	dc.b "Û"				; Û ATARI
	dcb.b 2,-1
	dc.b "Ö"				; Ö ATARI
	dc.b "Ü"				; Ü ATARI
	dc.b "Ç"				; Ç ATARI
	dcb.b 2,-1
	dc.b "ß"				; ß ATARI
	dc.b -1
	dc.b "À"				; À ATARI
	dcb.b 21,-1
	dc.b "À"				; À ATARI
	dcb.b 9,-1
	dc.b "À"				; À AMIGA
	dc.b "À"				; À AMIGA
	dcb.b 2,-1
	dc.b "Ä"				; À AMIGA
	dcb.b 2,-1
	dc.b "Ç"				; Ç AMIGA
	dc.b "È"				; È AMIGA
	dc.b "È"				; È AMIGA
	dc.b "È"				; È AMIGA
	dcb.b 9,-1
	dc.b "Ô"				; Ô AMIGA
	dc.b -1
	dc.b "Ö"				; Ö AMIGA
	dcb.b 4,-1
	dc.b "Û"				; Û AMIGA
	dc.b "Ü"				; Ü AMIGA
	dcb.b 2,-1
	dc.b "ß"				; ß AMIGA
	dc.b "À"				; À AMIGA
	dc.b "À"				; À AMIGA
	dc.b "À"				; À AMIGA
	dc.b -1
	dc.b "Ä"				; ä AMIGA
	dcb.b 2,-1
	dc.b "Ç"				; Ç AMIGA
	dc.b "È"				; È AMIGA
	dc.b "È"				; È AMIGA
	dc.b "È"				; È AMIGA
	dcb.b 9,-1
	dc.b "Ô"				; Ô AMIGA
	dc.b -1
	dc.b "ö"				; ö AMIGA
	dcb.b 4,-1
	dc.b "Û"				; Û AMIGA
	dc.b "Ü"				; ü AMIGA
	dcb.b 3,-1
	even

	SECTION	Fast_BSS,bss
PA_Sp:	ds.l 1				; PA stack
PAStack_start:        
	ds.l Max_PA
PAStack_end:

Text_wait_flag:	ds.b 1
Input_aborted:	ds.b 1
Input_buffer:	ds.b Max_input_length
	ds.b 1
	even

Cursor_X:	ds.w 1				; Input cursor coordinates
Cursor_Y:	ds.w 1
Cursor_timer:	ds.w 1
Blink:	ds.b 1
	even
Current_ink:	ds.w 1
Max_length:	ds.w 1			; Input string length
Current_length:	ds.w 1
Original_input:	ds.l 1			; Original input string
PA_width:	ds.w 1				; Of current PA
PA_height:	ds.w 1				;  (in characters)
Text_height:	ds.w 1			; Of current text
Space_table:	ds.b 60			; Should always be enough
	even
