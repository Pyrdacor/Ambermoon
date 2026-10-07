; Character editor
; Written by J.Horneman (In Tune With The Universe)
; Start : 2-7-1993
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Character editor ]
;*****************************************************************************
Chared_ModInit:
	move.w	#2,Ink_colour
	lea.l	Chared_portraits,a1		; Make batch
	lea.l	Batch,a0
	moveq.l	#Portraits_per_sex*2-1,d7
.Loop:	move.w	(a1)+,(a0)+
	dbra	d7,.Loop
	LOCAL
	moveq.l	#Portraits_per_sex*2,d0	; Load portraits
	moveq.l	#Portraits_file,d1
	lea.l	Batch,a0
	lea.l	Chared_portrait_handles,a1
	jsr	Load_batch_of_subfiles
	moveq.l	#1,d0			; Load baby character
	moveq.l	#Baby_char_file,d1
	jsr	Load_subfile
	move.b	d0,Chared_handle
	jsr	Claim_pointer		; Get initial portrait
	move.l	d0,a0
	moveq.l	#0,d0
	move.b	Portrait_nr(a0),d0
	Free	Chared_handle
	lea.l	Chared_portraits,a0		; Seek index
	moveq.l	#0,d1
	moveq.l	#Portraits_per_sex*2-1,d7
.Loop:	cmp.w	(a0)+,d0
	beq.s	.Found
	addq.w	#1,d1
	dbra	d7,.Loop
	moveq.l	#0,d1			; Not found -> Default
.Found:	move.w	d1,Chared_portrait		; Store
	jmp	Chared_DisInit

Chared_ModExit:
	lea.l	Chared_portrait_handles,a0	; Free memory
	moveq.l	#Portraits_per_sex*2-1,d7
.Loop:	move.b	(a0)+,d0
	jsr	Kill_memory
	dbra	d7,.Loop
	Get	Chared_handle,a0		; Insert data
	move.w	Chared_portrait,d7
	moveq.l	#0,d0			; Determine sex
	cmp.w	#Portraits_per_sex,d7
	bmi.s	.Male
	moveq.l	#1,d0
.Male:	move.b	d0,Char_sex(a0)		; Store
	lea.l	Chared_portraits,a1		; Get portrait number
	add.w	d7,d7
	move.w	0(a1,d7.w),d0
	move.b	d0,Portrait_nr(a0)		; Store
	moveq.l	#1,d0			; Save character data
	moveq.l	#Baby_char_file,d1
	jsr	Save_subfile
	move.b	Chared_handle,d0		; Free memory
	jsr	Free_pointer
	jsr	Kill_memory
	jsr	Close_window		; Close
	jmp	Fade_out_all

Chared_DisInit:
	move.w	#Chared_X-16,d0		; Open window
	move.w	#Chared_Y-16,d1
	moveq.l	#16,d2
	moveq.l	#6,d3
	lea.l	Chared_L1,a0
	jsr	Open_window
	move.w	#Chared_X+95,d0		; Draw box around portrait
	move.w	#Chared_Y+12,d1
	moveq.l	#32,d2
	moveq.l	#34,d3
	jsr	Draw_standard_box
	move.w	#Chared_X,d0		; Print headline
	move.w	#Chared_Y+2,d1
	move.w	#14*16,d2
	move.l	Chared_headline_ptr,a0
	jsr	Print_centered_string
	lea.l	Chared_icons,a0		; Draw icons & boxes
	moveq.l	#32,d2
	moveq.l	#5-1,d7
.Loop:	move.w	(a0)+,d0			; Get coordinates
	move.w	(a0)+,d1
	addi.w	#Chared_X-1,d0		; Draw box around icon
	addi.w	#Chared_Y-1,d1
	moveq.l	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display icon
	addq.w	#1,d1
	move.w	(a0)+,d3
	jsr	Display_up_button
	dbra	d7,.Loop
	jsr	Chared_DisUpd		; Update
	jmp	Fade_in_all

Chared_DisUpd:
	lea.l	Chared_portrait_handles,a1	; Get portrait address
	add.w	Chared_portrait,a1
	move.w	#Chared_X+96,d0		; Draw portrait
	move.w	#Chared_Y+13,d1
	moveq.l	#5,d5
	moveq.l	#2,d6
	moveq.l	#34,d7
	Get	(a1),a0
	jsr	Put_unmasked_block
	Free	(a1)
	move.w	#Chared_X+62,d0		; Draw box around name
	move.w	#Chared_Y+49,d1
	move.w	#98,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	addq.w	#2,d0			; Print character name
	addq.w	#2,d1
	Get	Chared_handle,a0
	lea.l	Char_name(a0),a0
	jsr	Put_text_line
	Free	Chared_handle
	rts

; ********** Switch to male **********************
Male_chared:
	moveq.l	#0,d0			; Feedback
	jsr	Chared_feedback
	bne.s	.Exit
	move.w	Chared_portrait,d0		; Already male ?
	cmp.w	#Portraits_per_sex,d0
	bmi.s	.Exit
	clr.w	Chared_portrait		; No -> Switch
.Exit:	rts

; ********** Switch to female ********************
Female_chared:
	moveq.l	#1,d0			; Feedback
	jsr	Chared_feedback
	bne.s	.Exit
	move.w	Chared_portrait,d0		; Already female ?
	cmp.w	#Portraits_per_sex,d0
	bpl.s	.Exit
	move.w	#Portraits_per_sex,Chared_portrait	; No -> Switch
.Exit:	rts

; ********** Left portrait ***********************
Left_portrait:
	moveq.l	#2,d0			; Feedback
	jsr	Chared_feedback
	bne.s	.Exit
	move.w	Chared_portrait,d0		; Do
	divu.w	#Portraits_per_sex,d0
	move.w	d0,d1
	swap	d0
	subq.w	#1,d0
	bpl.s	.Ok
	moveq.l	#Portraits_per_sex-1,d0
.Ok:	mulu.w	#Portraits_per_sex,d1
	add.w	d1,d0
	move.w	d0,Chared_portrait
.Exit:	rts

; ********** Right portrait **********************
Right_portrait:
	moveq.l	#3,d0			; Feedback
	jsr	Chared_feedback
	bne.s	.Exit
	move.w	Chared_portrait,d0		; Do
	divu.w	#Portraits_per_sex,d0
	move.w	d0,d1
	swap	d0
	addq.w	#1,d0
	cmp.w	#Portraits_per_sex,d0
	bmi.s	.Ok
	moveq.l	#0,d0
.Ok:	mulu.w	#Portraits_per_sex,d1
	add.w	d1,d0
	move.w	d0,Chared_portrait
.Exit:	rts

; ********** Exit character editor ***************
Exit_chared:
	moveq.l	#4,d0			; Feedback
	jsr	Chared_feedback
	bne.s	.Exit
	move.w	#277,d0			; Really exit ?
	jsr	Prompt_req
	tst.b	d0
	beq	.Exit
	Pop	Module			; Yes
.Exit:	rts

; ********** Enter name ***************************
Enter_name:
	move.w	#Chared_X+64,d0		; Edit string
	move.w	#Chared_Y+51,d1
	moveq.l	#15,d2
	Get	Chared_handle,a0
	lea.l	Char_name(a0),a0
	jsr	Edit_string
	Free	Chared_handle
	rts

;*****************************************************************************
; [ Feedback character editor icon ]
;   IN : d0 - Chared icon index {0...4} (.w)
; No registers are restored
;*****************************************************************************
Chared_feedback:
	lea.l	Chared_icons,a0		; Get icon info
	mulu.w	#6,d0
	add.w	d0,a0
	move.w	(a0)+,d0			; Get coordinates
	move.w	(a0)+,d1
	addi.w	#Chared_X,d0
	addi.w	#Chared_Y,d1
	move.w	(a0)+,d3			; Feedback
	jmp	Feedback

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Chared_icons:
	dc.w 0,10,Male_cicon		; Male
	dc.w 0,30,Female_cicon		; Female
	dc.w 48,21,Left_2D_cicon		; Left
	dc.w 144,21,Right_2D_cicon		; Right
	dc.w 192,47,OK_cicon		; OK

; *** CHARACTER EDITOR : 1st layer ***
Chared_L1:
	dc.w Chared_X,Chared_Y
	dc.w 0,31,10,10+16			; Male icon
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 0,31,30,30+16			; Female icon
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 48,48+31,21,21+16		; Left icon
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 144,144+31,21,21+16		; Right icon
	dc.b 4
	even
	dc.l .C5,0
.C5:	dc.w 192,192+31,47,47+16		; OK icon
	dc.b 5
	even
	dc.l .C6,0
.C6:	dc.w 62,62+97,50,50+7		; Character name
	dc.b 6
	even
	dc.l 0,0
