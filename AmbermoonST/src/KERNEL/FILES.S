; Loading files (Atari ST)
; Replaces the file handling of KERNEL/FILES.S of the Amiga version.
; Files are loaded with GEMDOS. While the system is taken over, the TOS
; system timer (Timer C, needed by the disk drivers for time-outs) is
; switched on during loading. The VBL, raster and keyboard interrupts stay
; active.

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
	tst.b	System_active		; Switch on Timer C
	beq.s	.Go
	bset	#5,MFP_IERB
	bset	#5,MFP_IMRB
.Go:
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
.Exit:	tst.b	System_active		; Switch off Timer C
	beq.s	.Done
	bclr	#5,MFP_IERB
	bclr	#5,MFP_IMRB
.Done:	movem.l	(sp)+,d1-d3/a0-a2
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
