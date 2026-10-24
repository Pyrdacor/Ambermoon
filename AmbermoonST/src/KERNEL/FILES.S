; Loading files (Atari ST)
; Replaces the file handling of KERNEL/FILES.S of the Amiga version.
; For the proof of concept all files are loaded at the start with GEMDOS,
; while TOS is still active.

	SECTION	Program,code

;*****************************************************************************
; [ Load a file ]
;   IN : d0 - Maximum length (.l)
;        a0 - Pointer to file name (.l)
;        a1 - Pointer to buffer (.l)
;  OUT : d0 - Number of bytes read / negative = error (.l)
; All other registers are restored
;*****************************************************************************
Load_file:
	movem.l	d1-d3/a0-a2,-(sp)
	move.l	d0,d3
	clr.w	-(sp)			; Fopen(name, read only)
	move.l	a0,-(sp)
	move.w	#Fopen,-(sp)
	trap	#GEMDOS
	addq.l	#8,sp
	tst.l	d0
	bmi.s	.Exit
	move.w	d0,d2			; Handle
	move.l	a1,-(sp)			; Fread(handle, length, buffer)
	move.l	d3,-(sp)
	move.w	d2,-(sp)
	move.w	#Fread,-(sp)
	trap	#GEMDOS
	lea.l	12(sp),sp
	move.l	d0,d3
	move.w	d2,-(sp)			; Fclose(handle)
	move.w	#Fclose,-(sp)
	trap	#GEMDOS
	addq.l	#4,sp
	move.l	d3,d0
.Exit:	movem.l	(sp)+,d1-d3/a0-a2
	rts

;*****************************************************************************
; [ Load a list of files ]
;   IN : a0 - Pointer to file list (.l)
;             per file : buffer (.l), maximum length (.l), name (0-terminated,
;             even), end : 0 (.l)
;  OUT : d0 - 0 = ok / negative = error (.l)
;        a0 - Pointer to the file name in case of an error (.l)
;*****************************************************************************
Load_files:
	movem.l	d1/a1/a2,-(sp)
.Loop:	move.l	(a0)+,d0
	beq.s	.Done
	move.l	d0,a1
	move.l	(a0)+,d0
	jsr	Load_file
	tst.l	d0
	bmi.s	.Error
.Skip:	tst.b	(a0)+			; Next entry
	bne.s	.Skip
	move.l	a0,d1
	addq.l	#1,d1
	andi.w	#-2,d1
	move.l	d1,a0
	bra.s	.Loop
.Done:	moveq.l	#0,d0
.Error:	movem.l	(sp)+,d1/a1/a2
	rts
