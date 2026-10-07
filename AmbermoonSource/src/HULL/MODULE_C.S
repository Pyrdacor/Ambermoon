; Module control routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 5-9-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	XREF	Default_module
	XREF	Diagnostics_list2

	XDEF	Push_Module
	XDEF	Pop_Module
	XDEF	Reset_module_stack
	XDEF	Handle_input
	XDEF	Init_display
	XDEF	Exit_display
	XDEF	Update_display
	XDEF	Get_module_ID
	XDEF	Get_under_module_ID
	XDEF	Find_module
	XDEF	Key_or_mouse

	SECTION	Program,Code
;*****************************************************************************
; [ Push a module on the stack ]
;   IN : a0 - Pointer to module (.l)
; All registers are restored
;*****************************************************************************
Push_Module:     
	movem.l	d0-d7/a0-a6,-(sp)

; First, the keyboard and mouse buffers are cleared.

	jsr	Reset_keyboard
	jsr	Reset_mouse_buffer

; Then the module stack-pointer is loaded and increased. If this is
; impossible, the routine exits.

	move.l	Module_Sp,a1
	move.l	a1,a2
	lea.l	Module_data_size(a1),a1
	cmpa.l	#ModStack_end,a1		; Possible ?
	beq	.Exit

; Then the module information is copied to the stack. The first byte is the
; Global/Local flag. If a local module has already been pushed, any
; following modules WILL also be local.

	move.l	a0,a3
	move.l	a1,a4
	tst.b	Pop_counter		; Any local modules pushed ?
	beq.s	.No_loc
	move.b	#Local_mod,(a4)
	bra.s	.Go_on
.No_loc:	move.b	(a3),(a4)			; Copy module flag
.Go_on:	

; The module ID is copied. If none is given, the ID of the previous module
; is NOT copied.

	move.b	Module_ID(a3),Module_ID(a4)	; Copy module ID
	addq.l	#2,a2			; Skip flag & ID
	addq.l	#2,a3
	addq.l	#2,a4

; The next 10 entries of the module are copied (DisUpd to RasterList). If a
; -1 is entered, the entry of the previous module is used.

	moveq.l	#10-1,d7
.Loop1:	move.l	(a3)+,d0			; Get entry
	cmp.l	#-1,d0			; Transparent ?
	bne.s	.No2
	move.l	(a2),d0			; Yes -> take previous
.No2:	move.l	d0,(a4)+			; Store
	addq.l	#4,a2			; Next entry
	dbra	d7,.Loop1

; The last 3 entries (Mouse PoinTeR to MA) are simply copied.

	moveq.l	#3-1,d7
.Loop2:	move.l	(a3)+,(a4)+
	dbra	d7,.Loop2
	move.l	a1,Module_Sp		; Push

; If the original module is global, all claims are cleared to avoid errors
; with the memory manager.

	btst	#0,(a0)			; Local before ?
	bne.s	.Local1
	jsr	Clear_all_claims		; No -> safety
	bset	#1,(a1)			; Indicate
.Local1:

; If the actually pushed module is global, the module is initialized and the
; routine exits.

	move.l	a1,a0
	btst	#0,(a0)			; Local now ?
	bne.s	.Local2
	jsr	Init_module		; Initialize new module
	bra.s	.Exit
.Local2:

; The local pop semaphore is increased.

	move.b	Pop_counter,d0		; Increase counter
	addq.b	#1,d0
	move.b	d0,Pop_counter

; The local module is initialized.

	jsr	Init_module		; Initialize new module

; This is the local main loop. After each element follows a check to see
; if the module was popped.

	cmp.b	Pop_counter,d0		; Already popped ?
	bne.s	.Exit
.Loop3:	jsr	Update_display		; Update display
	cmp.b	Pop_counter,d0
	bne.s	.Exit
	jsr	Handle_input		; Handle input
	cmp.b	Pop_counter,d0
	bne.s	.Exit
	jsr	Switch_screens		; Switch screens
	cmp.b	Pop_counter,d0
	beq.s	.Loop3
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Pop a module from the stack ]
; All registers are restored
;*****************************************************************************
Pop_Module:      
	movem.l	d0-d7/a0-a6,-(sp)

; First, the keyboard and mouse buffers are cleared.

	jsr	Reset_keyboard
	jsr	Reset_mouse_buffer

; Then the module stack-pointer is loaded. If popping is impossible, the
; routine exits.

	movea.l	Module_Sp,a1
	cmpa.l	#ModStack_start,a1		; Possible ?
	beq.s	.Exit

; If the current module is local, the local pop semaphore is decreased.

	move.l	a1,a0
	btst	#0,(a0)			; Global module ?
	beq.s	.Global
	subq.b	#1,Pop_counter		; Pop
.Global:

; The stack-pointer is decreased and stored.

	lea.l	-Module_data_size(a1),a1	; Pop
	move.l	a1,Module_Sp

; All HDOBs are destroyed if this WAS a global module.

	btst	#1,(a0)			; Was it ?
	beq.s	.No
	jsr	Clear_all_HDOBs		; Yes -> destroy
.No:

; The popped module is de-initialized.

	jsr	Exit_module		; Exit module
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Reset the module stack ]
; All registers are restored
;*****************************************************************************
Reset_module_stack:    
	movem.l	d7/a0-a2,-(sp)
	clr.b	Pop_counter		; Pop all local modules
	lea.l	ModStack_start,a1		; Reset stack
	move.l	a1,Module_Sp
	lea.l	Default_module,a0		; Push module
	move.l	a1,a2
	moveq.l	#(Module_data_size)/4-1,d7
.Loop:	move.l	(a0)+,(a2)+
	dbra	d7,.Loop
	move.l	a1,a0			; Initialize default module
	jsr	Init_module
	movem.l	(sp)+,d7/a0-a2
	rts

;*****************************************************************************
; [ Initialize current module ]
;   IN : a0 - Pointer to module (.l)
; All registers are restored
;*****************************************************************************
Init_module:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a1

; If no mouse pointer was given, the default mouse pointer is pushed. If the
; given mouse pointer is -1, no mouse pointer is pushed.

	move.l	Mouse_ptr(a1),d0		; Push mouse pointer
	bne.s	.Ok1
	lea.l	Default_Mptr,a0
	bra.s	.Do1
.Ok1:	cmp.l	#-1,d0
	beq.s	.No1
	move.l	d0,a0
.Do1:	jsr	Push_Mptr
.No1:

; If no PA was given, the default PA is pushed. If the given PA is -1, no
; PA is pushed.

	move.l	PA_ptr(a1),d0		; Push PA
	bne.s	.Ok2
	lea.l	Default_PA,a0
	bra.s	.Do2
.Ok2:	cmp.l	#-1,d0
	beq.s	.No2
	move.l	d0,a0
.Do2:	jsr	Push_PA
.No2:

; If no MA was given, the default MA is pushed. If the given MA is -1, no
; MA is pushed.

	move.l	MA_ptr(a1),d0		; Push MA
	bne.s	.Ok3
	lea.l	Default_MA,a0
	bra.s	.Do3
.Ok3:	cmp.l	#-1,d0
	beq.s	.No3
	move.l	d0,a0
.Do3:	jsr	Push_MA
.No3:

; If a ModInit entry was given, it is executed.

	move.l	ModInit_ptr(a1),d0		; Get ModInit address
	beq.s	.No4
	movea.l	d0,a0			; Execute
	jsr	(a0)
.No4:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Exit current module ]
;   IN : a0 - Pointer to module (.l)
; All registers are restored
;*****************************************************************************
Exit_module:
	movem.l	d0-d7/a0-a6,-(sp)
	cmp.l	#-1,Mouse_ptr(a0)		; Pop mouse pointer
	beq.s	.No1
	jsr	Pop_Mptr
.No1:	cmp.l	#-1,PA_ptr(a0)		; Pop PA
	beq.s	.No2
	jsr	Pop_PA
.No2:	cmp.l	#-1,MA_ptr(a0)		; Pop MA
	beq.s	.No3
	jsr	Pop_MA
.No3:	move.l	ModExit_ptr(a0),d0		; Get ModExit address
	beq.s	.No4
	move.l	a0,-(sp)			; Execute
	movea.l	d0,a0
	jsr	(a0)
	move.l	(sp)+,a0
.No4:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Input handler ]
; All registers are restored
;*****************************************************************************
Handle_input:
	movem.l	d0-d3/a0/a1,-(sp)
; ---------- Handle mouse input -------------------
	st	Key_or_mouse		; Mouse !
	move.l	Module_Sp,d0		; Get Mev address
	beq.s	.No_Mev
	move.l	d0,a0
	move.l	Mev_ptr(a0),d0
	beq.s	.No_Mev
	movea.l	d0,a0
.Again1:	jsr	Read_Mev			; Read event
	tst.w	d2			; Any ?
	bne.s	.Mev
	move.w	Mouse_X,d0		; Get coordinates
	move.w	Mouse_Y,d1
	jsr	Find_object		; Get object ID
	move.l	d2,d0			; Create event ID
	ori.l	#$80000000,d0
	jsr	Handle_list		; Do
	bra.s	.Do_Kev
.Mev:	move.w	d2,d3
	jsr	Find_object		; Get object ID
	moveq.l	#0,d0			; Create event ID
	move.b	d3,d0
	lsl.w	#8,d0
	swap	d0
	or.l	d2,d0
	jsr	Handle_list		; Do
	bne.s	.Again1			; Event executed ?
.No_Mev:	jsr	Reset_mouse_buffer		; Clear buffer
; ---------- Handle key input ---------------------
.Do_Kev:	sf	Key_or_mouse		; Key !
	move.l	Module_Sp,d0		; Get Kev address
	beq.s	.Exit
	move.l	d0,a0
	move.l	Kev_ptr(a0),d0
	beq.s	.Exit
	movea.l	d0,a0
.Again2:	jsr	Read_key			; Read a key
	tst.l	d0			; Key pressed ?
	beq.s	.Exit
	btst	#Amiga_key,d0		; Amiga pressed ?
	beq.s	.None
	lea.l	Diagnostics_list1,a1	; Yes -> Do diagnostic keys
	jsr	Handle_diagnostics_list
	lea.l	Diagnostics_list2,a1
	jsr	Handle_diagnostics_list
	bra.s	.Done
.None:	jsr	Handle_list		; No -> Do normal keys
	bne.s	.Again2			; Event executed ?
.Done:	jsr	Reset_keyboard		; Clear buffer
.Exit:	movem.l	(sp)+,d0-d3/a0/a1
	rts

;*****************************************************************************
; [ Diagnostic key list handler ]
;   IN : d0 - Key ID (.l)
;        a1 - Pointer to diagnostic key list (.l)
; All registers are restored
;*****************************************************************************
Handle_diagnostics_list:
	movem.l	d0-d7/a0-a6,-(sp)
.Again:	tst.w	(a1)			; End of list ?
	beq.s	.Exit
	cmp.b	(a1),d0			; No -> Is this it ?
	beq.s	.Found
	addq.l	#6,a1			; No -> Next entry
	bra.s	.Again
.Found:	move.l	2(a1),a1			; Execute
	jsr	(a1)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Event list handler ]
;   IN : d0 - Event ID (.l)
;        a0 - Pointer to event list (.l)
;  OUT : eq = An event was executed
;        ne = No event was executed
; Changed registers : a0
;*****************************************************************************
Handle_list:        
	movem.l	d0-d7/a1-a6,-(sp)
.Again:	tst.l	(a0)			; End of list ?
	beq.s	.End
	move.l	(a0)+,d1			; Mask
	and.l	d0,d1
	cmp.l	(a0)+,d1			; Compare
	bne.s	.Next
;	jsr	Record_input		; Record
	move.l	a0,-(sp)			; Execute routine
	movea.l	(a0),a0
	jsr	(a0)
	move.l	(sp)+,a0
	moveq.l	#0,d0			; Indicate success
	bra.s	.Exit
.Next:	addq.l	#4,a0			; Next event
	bra.s	.Again
.End:	moveq.l	#-1,d0			; Indicate no success
.Exit:	movem.l	(sp)+,d0-d7/a1-a6
	rts

;*****************************************************************************
; [ Call current module's DisInit routine ]
; All registers are restored
;*****************************************************************************
Init_display:       
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Module_Sp,d0		; Get DisInit address
	beq.s	.Exit
	move.l	d0,a0
	move.l	DisInit_ptr(a0),d0
	beq.s	.Exit
	movea.l	d0,a0			; Execute
	jsr	(a0)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Call current module's DisExit routine ]
; All registers are restored
;*****************************************************************************
Exit_display:       
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Module_Sp,d0		; Get DisExit address
	beq.s	.Exit
	move.l	d0,a0
	move.l	DisExit_ptr(a0),d0
	beq.s	.Exit
	movea.l	d0,a0			; Execute
	jsr	(a0)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Call current module's DisUpd routine ]
; All registers are restored
;*****************************************************************************
Update_display:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Module_Sp,d0		; Get DisUpd address
	beq.s	.Exit
	move.l	d0,a0
	move.l	DisUpd_ptr(a0),d0
	beq.s	.Exit
	ifne	Cheat
	clr.l	Update_timer		; Start the clock
	endc
	movea.l	d0,a0			; Execute
	jsr	(a0)
	ifne	Cheat
	move.l	Update_timer,d0		; Stop the clock
	addq.l	#1,d0
	move.w	d0,Update_time_value
	jsr	Print_update_time		; Print
	endc
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Get current module's ID ]
;  OUT : d0 - Current module ID (.b)
; Changed registers : d0
;*****************************************************************************
Get_module_ID:
	move.l	a0,-(sp)
	move.l	Module_Sp,d0		; Get module address
	beq.s	.Exit
	move.l	d0,a0
	moveq.l	#0,d0			; Get module ID
	move.b	Module_ID(a0),d0
.Exit:	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Get ID of module UNDER current module ]
;  OUT : d0 - Module ID (.b)
; Changed registers : d0
;*****************************************************************************
Get_under_module_ID:
	move.l	a0,-(sp)
	move.l	Module_Sp,d0		; Get module address
	beq.s	.Exit
	move.l	d0,a0
	moveq.l	#0,d0			; Default
	lea.l	-Module_data_size(a0),a0	; Previous module
	cmp.l	#ModStack_start,a0		; End ?
	ble.s	.Exit
	moveq.l	#0,d0			; Get module ID
	move.b	Module_ID(a0),d0
.Exit:	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Find module ]
;   IN : d0 - Module ID (.b)
;  OUT : eq - Not found
;        ne - Found
; All registers are restored
;*****************************************************************************
Find_module:
	movem.l	d1/d7/a0,-(sp)
	moveq.l	#0,d7			; Default is NO
	move.l	Module_Sp,d1		; Get module address
	beq.s	.Exit
	move.l	d1,a0
.Seek:	cmp.b	Module_ID(a0),d0		; Is this it ?
	bne.s	.Next
	moveq.l	#1,d7			; Yes -> Found it
	bra.s	.Exit
.Next:	lea.l	-Module_data_size(a0),a0	; Previous module
	cmp.l	#ModStack_start,a0		; End ?
	bgt.s	.Seek
.Exit:	tst.w	d7			; Well ?
	movem.l	(sp)+,d1/d7/a0
	rts

;*****************************************************************************
; [ Screen queue handler ]
; All registers are restored
;*****************************************************************************
ScrQ_handler:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	Q_block			; Blocked ?
	bne.s	.Exit
	move.l	Module_Sp,d0		; Get pointer to Screen Q
	beq.s	.Exit
	move.l	d0,a0
	move.l	ScrQ_ptr(a0),d0
	beq.s	.Exit
	movea.l	d0,a0
.Again:	move.l	(a0)+,d0			; End of list ?
	beq.s	.Exit
	move.l	a0,-(sp)			; No -> execute routine
	movea.l	d0,a0
	jsr	(a0)
	movea.l	(sp)+,a0
	bra.s	.Again			; Next entry
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Vbl queue handler ]
; All registers are restored
;*****************************************************************************
VblQ_handler:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	Q_block			; Blocked ?
	bne.s	.Exit
	move.l	Module_Sp,d0		; Get pointer to Vbl Q
	beq.s	.Exit
	move.l	d0,a0
	move.l	VblQ_ptr(a0),d0
	beq.s	.Exit
	move.l	d0,a0
.Again:	move.l	(a0)+,d0			; End of list ?
	beq.s	.Exit
	move.l	a0,-(sp)			; No -> execute routine
	movea.l	d0,a0
	jsr	(a0)
	movea.l	(sp)+,a0
	bra.s	.Again			; Next entry
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	ifne	Cheat
	addq.l	#1,Update_timer		; Count
	endc
	rts

	ifne	Cheat
;*****************************************************************************
; [ Print display update time ]
; All registers are restored
;*****************************************************************************
Print_update_time:
	movem.l	d0-d4/d6/d7/a0,-(sp)
	tst.b	Show_update_time		; Show ?
	beq.s	.Exit
	move.w	#300,d0			; Yes -> Erase area
	moveq.l	#0,d1
	move.w	#319,d2
	moveq.l	#7,d3
	moveq.l	#0,d4
	jsr	Draw_box
	lea.l	Hull_number,a0		; Convert number
	move.w	Update_time_value,d0
	moveq.l	#" ",d6
	moveq.l	#2,d7
	jsr	DecR_convert
	lea.l	Hull_number,a0		; Display number
	move.w	#300,d0
	moveq.l	#0,d1
	jsr	Put_text_line
.Exit:	movem.l	(sp)+,d0-d4/d6/d7/a0
	rts
	endc

;***************************************************************************	
; The DATA & BSS segments	
;***************************************************************************
	SECTION	Fast_DATA,data

	SECTION	Fast_BSS,bss
Pop_counter:	ds.b 1			; Local module pop flag
Key_or_mouse:	ds.b 1
Q_block:	ds.b 1
Hull_number:	ds.b 11			; BUILD: Renamed (was Number, which is also
					;  defined in MAIN.S). The hull was assembled separately.
	even

	ifne	Cheat
Show_update_time:	ds.b 1
	even
Update_timer:	ds.l 1
Update_time_value:	ds.w 1
	endc

Module_Sp:	ds.l 1			; Module stack
ModStack_start:
	ds.b Max_modules*Module_data_size
	even
ModStack_end:
