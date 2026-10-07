; File names, file infos & saved games
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code
	dc.b	0,0

;*****************************************************************************
; [ Build the path of a file ]
;   IN : d0 - File number (.w)
;  OUT : a0 - Pointer to file name (.l)
;*****************************************************************************
Get_file_path_by_index:
	movem.l	d0/d1/a1,-(sp)
	tst.w	d0
	bne.s	.Skip
	move.l	a0,a1
	bra.s	.Skip7
.Skip:
	cmpi.w	#49,d0		; Check file index in range (< 45)
	bmi.s	.Skip2
	lea.l	ERROR_0026d5ee,a0
	bra.w	.Exit
.Skip2:
	lea.l	Save_file_names,a1
	move.w	d0,d1
	lsl.w	#2,d1
	move.l	-4(a1,d1.w),a1
	lea.l	File_indices_with_multiple_files,a0
.Loop:
	move.w	(a0)+,d1
	beq.w	.Skip7
	cmp.w	d0,d1		; If index is 6 (XMap_data.amb files), proceed to get prefix
	bne.s	.Loop
	move.w	Map_nr,d1
	cmp.w	#257,d1		; If map index < 257, use prefix 1 (1Map_data etc)
	bpl.s	.Skip3
	moveq.l	#1,d0
	bra.s	.Skip6
.Skip3:
	cmp.w	#300,d1		; Else if map index < 300, use prefix 2 (2Map_data etc)
	bpl.s	.Skip4
	moveq.l	#2,d0
	bra.s	.Skip6
.Skip4:
	cmp.w	#400,d1		; Else if map index < 400, use prefix 3 (3Map_data etc)
	bpl.s	.Skip5
	moveq.l	#3,d0
	bra.s	.Skip6
.Skip5:
	moveq.l	#2,d0		; Otherwise use prefix 2 (2Map_data etc)
.Skip6:
	move.b	-1(a1,d0.w),d1		; Read the number based on map index
	addq.l	#3,a1		; Set real disk number to it
	move.b	d1,(a1)
	addi.b	#48,d0		; Also set text to "1Map_data.amb" etc
	move.b	d0,1(a1)
.Skip7:
	tst.b	Intro_menu_choice+2
	bne.s	.Skip8
	lea.l	File_path,a0		; Filename for disk access
	move.b	(a1)+,d0		; Get disk number
	move.b	d0,(a0)+		; Store disk number
	addq.l	#6,a0
	addi.b	#64,d0		; Convert number to 'A', 'B', etc
	move.b	d0,(a0)+		; Insert 'A' etc into "AMBER_" string
	addq.l	#1,a0		; After this we are behind the "AMBER_X:" string
	jsr	Strcpy		; There are 32 free bytes where the filename is copied to
	lea.l	File_path,a0		; Again point to the whole string which is now "AMBER_X: Filename"
	bra.s	.Exit
.Skip8:
	lea.l	File_name_buffer,a0		; Filename for external files
	addq.l	#1,a1
	jsr	Strcpy
	lea.l	Amberfiles_prefix,a0		; Here the string "Amberfiles/Filename" is built instead
.Exit:
	movem.l	(sp)+,d0/d1/a1
	rts

;*****************************************************************************
; [ Get the memory type of a file ]
;   IN : d1 - File number (.b)
;  OUT : d1 - Memory type (.b)
;*****************************************************************************
File_get_mem_type:
	move.l	a0,-(sp)
	lea.l	File_infos,a0
	andi.w	#$ff,d1		; D1 is the file index
	subq.w	#1,d1		; From 1-based to 0-based
	lsl.w	#2,d1		; FileInfo size is 4
	move.b	1(a0,d1.w),d1		; Get mem type
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Get the memory priority of a file ]
;   IN : d1 - File number (.b)
;  OUT : d1 - Priority (.b)
;*****************************************************************************
Get_file_mem_prio:
	move.l	a0,-(sp)
	lea.l	File_infos,a0
	andi.w	#$ff,d1
	subq.w	#1,d1
	lsl.w	#2,d1
	move.b	0(a0,d1.w),d1
	andi.b	#$7f,d1
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Get the decompression space of a file ]
;   IN : d0 - File number (.w)
;  OUT : d0 - Extra space (.l)
;*****************************************************************************
Get_file_cmp_space:
	move.l	a0,-(sp)
	lea.l	File_infos,a0
	andi.w	#$ff,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	move.w	2(a0,d0.w),d0
	ext.l	d0
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Copy a saved game to the work files ]
;   IN : d0 - Save game number (.w)
;*****************************************************************************
Get_saved_game:
	movem.l	d0/d1/d6/d7/a0-a3,-(sp)
	jsr	Set_save_file_names
	moveq.l	#0,d1
	lea.l	Savegame_file_infos,a2
	lea.l	Save_file_names,a3
	moveq.l	#4,d7
.Loop:
	move.l	2(a2),a0
	moveq.l	#0,d0
	jsr	Load_file
	move.b	d0,d6
	jsr	Claim_pointer
	move.l	d0,a0
	move.w	(a2),d0
	lsl.w	#2,d0
	move.l	-4(a3,d0.w),a1
	move.b	d6,d0
	jsr	Get_memory_length
	jsr	Save_file
	move.b	d6,d0
	jsr	Free_pointer
	jsr	Kill_memory
	addq.l	#6,a2
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d1/d6/d7/a0-a3
	rts

;*****************************************************************************
; [ Copy the work files to a saved game ]
;   IN : d0 - Save game number (.w)
;*****************************************************************************
Put_saved_game:
	movem.l	d0/d1/d6/d7/a0-a3,-(sp)
	tst.w	d0
	beq.w	.Exit
	jsr	Set_save_file_names
	moveq.l	#0,d1
	lea.l	Savegame_file_infos,a2
	lea.l	Save_file_names,a3
	moveq.l	#4,d7
.Loop:
	move.w	(a2),d0
	lsl.w	#2,d0
	move.l	-4(a3,d0.w),a0
	moveq.l	#0,d0
	jsr	Load_file
	move.b	d0,d6
	jsr	Claim_pointer
	move.l	d0,a0
	move.l	2(a2),a1
	move.b	d6,d0
	jsr	Get_memory_length
	jsr	Save_encrypted_file
	move.b	d6,d0
	jsr	Free_pointer
	jsr	Kill_memory
	addq.l	#6,a2
	dbra	d7,.Loop
.Exit:
	movem.l	(sp)+,d0/d1/d6/d7/a0-a3
	rts

;*****************************************************************************
; [ Insert the save game number into the save file names ]
;   IN : d0 - Save game number (.w)
; All registers are restored
;*****************************************************************************
Set_save_file_names:
	movem.l	d1/d6/d7/a0/a1,-(sp)
	cmp.w	#11,d0
	bpl.s	.Exit
	move.b	#48,d6
	moveq.l	#2,d7
	lea.l	Savegame_file_infos,a1
	moveq.l	#4,d1
.Loop:
	addq.l	#2,a1
	move.l	(a1)+,a0
	addq.w	#6,a0
	jsr	DecR_convert
	move.b	#47,(a0)
	dbra	d1,.Loop
.Exit:
	movem.l	(sp)+,d1/d6/d7/a0/a1
	rts
	dc.b	0,0

