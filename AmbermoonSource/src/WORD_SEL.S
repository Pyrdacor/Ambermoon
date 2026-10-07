; Word select window
; Written by J.Horneman (In Tune With The Universe)
; Start : 16-9-1992

	SECTION	Program,code
;*****************************************************************************
; [ Word select window ]
;*****************************************************************************
WSelW_ModInit:
	move.w	#-1,Selected_word		; Clear
	st	No_word_selected
	move.l	#Max_words*2,d0		; Make buffer
	jsr	Allocate_memory
	move.b	d0,Word_list_handle
	jsr	Claim_pointer
	move.l	d0,a0
	moveq.l	#0,d0			; Fill buffer
	moveq.l	#WD_bit_array,d1
	moveq.l	#3,d2
	moveq.l	#0,d6
	move.w	#Max_words-1,d7
.Loop:	jsr	Access_bit_array		; Word known ?
	beq.s	.Next
	move.w	d0,(a0)+			; Insert
	addq.w	#1,d6			; Count
.Next:	addq.w	#1,d0			; Next word
	dbra	d7,.Loop
	Free	Word_list_handle
	move.w	d6,Nr_of_known_words	; Store
	tst.w	d6			; Any words known ?
	bne.s	.Ok
	st	No_word_selected		; No -> exit
	Pop	Module
	bra.s	.Exit
.Ok:	jsr	Sort_word_list		; Sort words
	jsr	WSelW_DisInit		; Do
.Exit:	rts

WSelW_ModExit:
	move.b	Word_list_handle,d0		; Free memory
	jsr	Free_memory
	jmp	WSelW_DisExit

WSelW_DisInit:
	move.w	#WSelW_X-16,d0		; Open a window
	move.w	#WSelW_Y-16,d1
	moveq.l	#11,d2
	moveq.l	#10,d3
	lea.l	WSelW_L1,a0
	jsr	Open_window
 	move.w	#WSelW_X-1,d0		; Draw box around icon
	move.w	#WSelW_Y+113,d1
	move.w	#32,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display talk icon
	addq.w	#1,d1
	moveq.l	#Talk_cicon,d3
	jsr	Display_up_button
	move.w	#WSelW_X+95,d0		; Draw box around icon
	move.w	#WSelW_Y+113,d1
	move.w	#32,d2
	move.w	#17,d3
	jsr	Draw_standard_box
	addq.w	#1,d0			; Display exit icon
	addq.w	#1,d1
	moveq.l	#Exit_cicon,d3
	jsr	Display_up_button
 	lea.l	WSelW_scroll_bar,a0		; Show scroll bar
	move.w	Nr_of_known_words,Total_units(a0)
	jsr	Push_Scroll_bar
	jmp	Update_screen

WSelW_DisExit:
	tst.w	Nr_of_known_words		; Any words ?
	beq.s	.Exit
	jsr	Close_window
	Pop	Scroll_bar
.Exit:	rts

Update_wordselect_window:
	move.w	#WSelW_X,d0		; Clear word area
	move.w	#WSelW_Y-2,d1
	move.w	#128,d2
	move.w	#113,d3
	jsr	Draw_standard_box
	move.w	Scroll_bar_result,d0	; Get bar position
	move.w	Nr_of_known_words,d7	; Show how many words ?
	sub.w	d0,d7
	cmp.w	#16+1,d7
	bmi.s	.Ok
	moveq.l	#16,d7
.Ok:	Get	Word_list_handle,a1		; Skip
	add.w	d0,d0
	add.w	d0,a1
	moveq.l	#3,d2			; Show
	move.w	#WSelW_Y,d3
	bra.s	.Entry
.Loop:	lea.l	Dictionary_word,a0
	move.w	(a1)+,d0			; Get word number
	moveq.l	#New_words_bit_array,d1	; New word ?
	jsr	Access_bit_array
	beq.s	.Not_new
	move.w	#Yellow,Ink_colour		; New
	bra.s	.Continue
.Not_new:	move.w	#31,Ink_colour		; Old
.Continue:	jsr	Find_word			; Get word
	move.w	#WSelW_X+4,d0		; Print
	move.w	d3,d1
	jsr	Put_text_line
	addq.w	#Char_height+2,d3		; Next word
.Entry:	dbra	d7,.Loop
	Free	Word_list_handle
	rts

Exit_WSelW:
	move.w	#WSelW_X+96,d0		; Feedback
	move.w	#WSelW_Y+114,d1
	moveq.l	#Exit_cicon,d3
	jsr	Feedback
	bne.s	.Exit
	jsr	Basic_abort		; Exit
.Exit:	rts

Word_input:
	move.w	#2,Ink_colour
	move.w	#WSelW_X,d0		; Feedback
	move.w	#WSelW_Y+114,d1
	moveq.l	#Talk_cicon,d3
	jsr	Feedback
	bne	.Exit
	move.w	#WordIn_X-16,d0		; Open window
	move.w	#WordIn_Y-16,d1
	moveq.l	#10,d2
	moveq.l	#3,d3
	sub.l	a0,a0
	jsr	Open_window
	move.w	#WordIn_X,d0		; Draw box
	move.w	#WordIn_Y+2,d1
	move.w	#127,d2
	moveq.l	#8,d3
	jsr	Draw_standard_box
	jsr	Update_screen
	move.w	#WordIn_X+2,d0		; Input string
	move.w	#WordIn_Y+4,d1
	moveq.l	#20,d2
	jsr	Input_string
	jsr	Close_window		; Close window
	tst.b	Input_aborted		; Aborted ?
	bne.s	.Exit
	tst.b	(a0)			; Empty string ?
	beq.s	.Exit
	jsr	Search_word		; No -> search word
	move.w	d0,Selected_word
	cmp.w	#-1,d0			; In dictionary ?
	beq.s	.Done
	moveq.l	#WD_bit_array,d1		; Yes -> already known ?
	moveq.l	#3,d2
	jsr	Access_bit_array
	bne.s	.Done
	moveq.l	#1,d2			; No -> Now it is
	jsr	Access_bit_array
	moveq.l	#New_words_bit_array,d1	; A new word !
	jsr	Access_bit_array
.Done:	sf	No_word_selected		; Selected !
	Pop	Module			; Exit
.Exit:	rts

Word_selected:
	lsr.w	#8,d0			; Clicked on a word ?
	tst.b	d0
	beq	.Exit
	move.w	d0,d1
	add.w	Scroll_bar_result,d0	; Calculate slot number
	cmp.w	Nr_of_known_words,d0	; Empty slot ?
	bhi	.Exit
	Get	Word_list_handle,a0		; Get word number
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0
	Free	Word_list_handle
	move.w	d0,Selected_word		; Store
	lea.l	Dictionary_word,a0		; Find word
	jsr	Find_word
	move.w	#26,Ink_colour		; Set colours
	move.w	#31,Shadow_colour
	subq.w	#1,d1			; Print it
	mulu.w	#Char_height+2,d1
	addi.w	#WSelW_Y,d1
	move.w	#WSelW_X+4,d0
	jsr	Put_text_line
	move.w	#0,Shadow_colour		; Reset
	jsr	Update_screen
	jsr	Wait_4_unclick
	sf	No_word_selected		; Selected !
	Pop	Module
.Exit:	rts

Word_touched:
	lsr.w	#8,d0			; Clicked on a word ?
	tst.b	d0
	beq	.Exit
	move.w	d0,d3
	add.w	Scroll_bar_result,d0	; Calculate slot number
	cmp.w	Nr_of_known_words,d0	; Empty slot ?
	bhi	.Exit
	Get	Word_list_handle,a0		; Get word number
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0
	Free	Word_list_handle
	moveq.l	#New_words_bit_array,d1	; New word ?
	moveq.l	#3,d2
	jsr	Access_bit_array
	beq.s	.Not_new
	moveq.l	#Yellow,d4		; New
	bra.s	.Continue
.Not_new:	moveq.l	#31,d4			; Old
.Continue:	lea.l	Dictionary_word,a0		; Find word
	jsr	Find_word
	move.w	#0,Ink_colour		; Set colours
	move.w	#-1,Shadow_colour
	subq.w	#1,d3			; Get coordinates
	mulu.w	#Char_height+2,d3
	addi.w	#WSelW_Y-1,d3
	move.w	#WSelW_X+1,d0
	move.w	d0,d2			; Draw highlighting box
	move.w	d3,d1
	addi.w	#126,d2
	add.w	#Char_height+1,d3
	jsr	Draw_box
	addq.w	#3,d0			; Print word
	addq.w	#1,d1
	jsr	Put_text_line
	move.w	#0,Shadow_colour		; Reset
.Exit:	rts

;*****************************************************************************
; [ Sort known word list - using Shellsort ]
; All registers are restored
;*****************************************************************************
Sort_word_list:
	movem.l	d7/a0/a1/a6,-(sp)
	Get	Word_list_handle,a6		; Do
	move.w	Nr_of_known_words,d7
	lea.l	.Compare_words,a0
	lea.l	.Swap_words,a1
	jsr	Shellsort
	Free	Word_list_handle
	movem.l	(sp)+,d7/a0/a1/a6
	rts

; [ Compare two words ]
;   IN : d5 - Source index {...} (.w)
;        d6 - Destination index {1...} (.w)
;        a6 - Pointer to word list (.l)
;  OUT : eq - Source  = Destination
;        gs - Source >= Destination
;        ls - Source <= Destination
; All registers are restored
.Compare_words:
	movem.l	d0/d5/d6/a0/a1,-(sp)
	lea.l	Dictionary_word2,a0		; Get second word
	add.w	d6,d6
	move.w	-2(a6,d6.w),d0
	jsr	Find_word
	move.l	a0,a1
	lea.l	Dictionary_word,a0		; Get first word
	add.w	d5,d5
	move.w	-2(a6,d5.w),d0
	jsr	Find_word
.Loop:	move.b	(a0)+,d0			; Compare characters
	cmp.b	(a1)+,d0
	bne.s	.Exit
	tst.b	d0			; End of words ?
	bne.s	.Loop
	cmp.b	d0,d0			; Set flags (same)
.Exit:	movem.l	(sp)+,d0/d5/d6/a0/a1
	rts

; [ Swap two words ]
;   IN : d5 - Source index {1...} (.w)
;        d6 - Destination index {1...} (.w)
;        a6 - Pointer to word list (.l)
; All registers are restored
.Swap_words:
	movem.l	d0/d5/d6,-(sp)
	add.w	d5,d5			; Swap
	add.w	d6,d6
	move.w	-2(a6,d5.w),d0
	move.w	-2(a6,d6.w),-2(a6,d5.w)
	move.w	d0,-2(a6,d6.w)
	movem.l	(sp)+,d0/d5/d6
	rts

;*****************************************************************************
; [ Find a word in the dictionary ]
;   IN : d0 - Number of word (.w)
;        a0 - Pointer to word buffer (.l)
; All registers are restored
;*****************************************************************************
Find_word:
	movem.l	d0/d1/a0/a1,-(sp)
	Get	Dictionary_handle,a1
	cmp.w	(a1)+,d0			; Legal word ?
	bpl	.Exit
	moveq.l	#0,d1
	bra.s	.Entry
.Loop:	move.b	(a1)+,d1			; Get length
	adda.w	d1,a1			; Next word
.Entry:	dbra	d0,.Loop
	moveq.l	#0,d0			; Copy word
	move.b	(a1)+,d0
	jsr	Strncpy
.Exit:	clr.b	(a0)			; Insert EOL
	Free	Dictionary_handle
	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Search word in dictionary ]
;   IN : a0 - Pointer to word (.l)
;  OUT : d0 - Word number / -1 = not found (.w)
; Changed registers : d0
;*****************************************************************************
Search_word:
	movem.l	d1/d4-d7/a1-a4,-(sp)
	lea.l	Input_mask_table,a4
	jsr	Strlen			; Get length of word
	move.w	d0,d4
	moveq.l	#0,d0			; Clear
	moveq.l	#0,d1
	Get	Dictionary_handle,a1	; Get number of words
	move.w	(a1)+,d7
	bra.s	.Entry1
.Loop1:	moveq.l	#0,d6			; Get length of word
	move.b	(a1)+,d6
	move.w	d6,d5			; Duplicate length of word
	movea.l	a0,a2			; Duplicate pointers
	movea.l	a1,a3
	bra.s	.Entry2
.Loop2:	move.b	(a3)+,d1			; Get character
	move.b	-32(a4,d1.w),d1		; Translate
	cmp.b	(a2)+,d1			; Compare
	bne.s	.Next1
.Entry2:	dbra	d6,.Loop2
	cmp.w	d4,d5			; Right length ?
	beq.s	.Found
.Next1:	addq.w	#1,d0			; Next word
	adda.w	d5,a1
.Entry1:	dbra	d7,.Loop1
	moveq.l	#-1,d0			; Word doesn't exist
.Found:	Free	Dictionary_handle
	movem.l	(sp)+,d1/d4-d7/a1-a4
	rts

;***************************************************************************	
; The DATA & BSS segments	
;***************************************************************************
	SECTION	Fast_DATA,data
; *** WORD SELECT WINDOW : 1st layer ***
WSelW_L1:	dc.w WSelW_X,WSelW_Y
	dc.w 0,143,-1,112			; Word area
	dc.b 1
	even
	dc.l .C2,WSelW_L2
.C2:	dc.w 0,31,114,114+16		; Mouth icon
	dc.b 2
	dc.l .C3,0
.C3:	dc.w 96,96+31,114,114+16		; Exit icon
	dc.b 3
	dc.l 0,0

; *** WORD SELECT WINDOW : 2nd layer ***
WSelW_L2:	dc.w 0,127,0,6			; Words
	dc.b 1
	even
	dc.l .C2,0
.C2:	dc.w 0,127,7,13
	dc.b 2
	even
	dc.l .C3,0
.C3:	dc.w 0,127,14,20
	dc.b 3
	even
	dc.l .C4,0
.C4:	dc.w 0,127,21,27
	dc.b 4
	even
	dc.l .C5,0
.C5:	dc.w 0,127,28,34
	dc.b 5
	even
	dc.l .C6,0
.C6:	dc.w 0,127,35,41
	dc.b 6
	even
	dc.l .C7,0
.C7:	dc.w 0,127,42,48
	dc.b 7
	even
	dc.l .C8,0
.C8:	dc.w 0,127,49,55
	dc.b 8
	even
	dc.l .C9,0
.C9:	dc.w 0,127,56,62
	dc.b 9
	even
	dc.l .C10,0
.C10:	dc.w 0,127,63,69
	dc.b 10
	even
	dc.l .C11,0
.C11:	dc.w 0,127,70,76
	dc.b 11
	even
	dc.l .C12,0
.C12:	dc.w 0,127,77,83
	dc.b 12
	even
	dc.l .C13,0
.C13:	dc.w 0,127,84,90
	dc.b 13
	even
	dc.l .C14,0
.C14:	dc.w 0,127,91,97
	dc.b 14
	even
	dc.l .C15,0
.C15:	dc.w 0,127,98,104
	dc.b 15
	even
	dc.l .C16,0
.C16:	dc.w 0,127,105,111
	dc.b 16
	even
	dc.l ScrollBar_L2,0

WSelW_scroll_bar:
	dc.w 0,1,16,113,WSelW_X+128+7,WSelW_Y-1
	dc.l Update_wordselect_window
	dcb.b Scroll_bar_extra_data
