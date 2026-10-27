; ST kernel : program start & main loop
; Replaces KERNEL/START.S of the Amiga version. After the TOS part, the start
; is the same as [ Start_program ] of the Amiga version.

	SECTION	Program,code

;*****************************************************************************
; [ Program entry ]
; Called by TOS with the basepage on the stack.
;*****************************************************************************
Start:
	move.l	4(sp),a0			; Get basepage
	move.l	$c(a0),d0			; Size of TEXT
	add.l	$14(a0),d0			;  + DATA
	add.l	$1c(a0),d0			;  + BSS
	addi.l	#$100,d0			;  + basepage
	lea.l	ST_stack_top,sp		; Use own stack
	move.l	d0,-(sp)			; Give back the rest of the memory
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#Mshrink,-(sp)
	trap	#GEMDOS
	lea.l	12(sp),sp
	jsr	Init_libraries		; (TOS is still active)
	jsr	Init_IKBD
	clr.l	-(sp)			; Supervisor mode
	move.w	#Super,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	move.l	d0,Old_SSP
	clr.w	Intro_menu_choice		; Journey onward
	move.b	#1,Intro_menu_choice+2	; External files (DATA\)
	jsr	Start_program
	move.l	Old_SSP,-(sp)		; User mode
	move.w	#Super,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	clr.w	-(sp)			; Exit
	trap	#GEMDOS

;*****************************************************************************
; [ Load texts and resources and reset the module stack ]
;*****************************************************************************
Init_texts_and_resources:
	jsr	Load_texts
	jsr	Load_resources
	jsr	Reset_module_stack
	rts

;*****************************************************************************
; [ Program start ]
; NOTE :
;   - Like [ Start_program ] of the Amiga version.
;*****************************************************************************
Start_program:
	move.l	(sp)+,Return_address
	move.l	sp,Stack_pointer
	lea.l	Return_value,sp
	jsr	Allocate_chip_and_fast_memory
	bpl.s	.Skip
	jmp	Exit_to_loader
.Skip:
	jsr	Init_system
Restart_game:
	lea.l	Return_value,sp
	jsr	Init_sub_files
	jsr	Reset_PA_stack
	jsr	Reset_MA_stack
	jsr	Reset_Mptr_stack
	jsr	Reset_CA_stack
	jsr	Reset_tree_stack
	jsr	Reset_scroll_bar_stack
	jsr	Clear_all_HDOBs
	jsr	Init_texts_and_resources
	jsr	Show_mouse_pointer
	moveq.l	#0,d0
	jsr	Set_music
	move.l	Off_screen,a0
	jsr	Clear_screen
	jsr	Update_screen
	jsr	Fade_in_all
	jsr	Init_program
.Loop:
	jsr	Update_display
	jsr	Handle_input
	jsr	Switch_screens
	bra.s	.Loop

;*****************************************************************************
; [ Exit the program ]
; NOTE :
;   - This routine does not return.
;*****************************************************************************
Exit_program:
	moveq.l	#0,d0
	jsr	Set_music
	jsr	Exit_system
Exit_to_loader:
	jsr	Free_all_memory
	move.l	Stack_pointer,sp
	move.l	Return_value,d0
	move.l	Return_address,a0
	jmp	(a0)

	SECTION	Fast_DATA,data
Version_string1_ptr:	dc.l 0			; (filled when the texts are loaded)
Version_string2_ptr:	dc.l 0

	SECTION	Fast_BSS,bss
Old_SSP:	ds.l 1
	ds.b	8192
ST_stack_top:
