; Program start & exit (Atari ST)
; Replaces KERNEL/START.S of the Amiga version.

	SECTION	Program,code

;*****************************************************************************
; [ Program entry ]
; Called by TOS with the basepage on the stack.
;*****************************************************************************
Program_entry:
	move.l	4(sp),a0			; Get basepage
	move.l	$c(a0),d0			; Size of TEXT
	add.l	$14(a0),d0			;  + DATA
	add.l	$1c(a0),d0			;  + BSS
	addi.l	#$100,d0			;  + basepage
	lea.l	Stack_top,sp		; Use own stack
	move.l	d0,-(sp)			; Give back the rest of the memory
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#Mshrink,-(sp)
	trap	#GEMDOS
	lea.l	12(sp),sp
	jsr	Load_program_data		; Load the data (TOS is still active)
	tst.w	d0
	bne.s	.Exit
	clr.l	-(sp)			; Supervisor mode
	move.w	#Super,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	move.l	d0,Old_SSP
	jsr	Init_system
	jsr	Program_main
	jsr	Restore_system
	move.l	Old_SSP,-(sp)		; User mode
	move.w	#Super,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
.Exit:	clr.w	-(sp)			; Exit
	trap	#GEMDOS

	SECTION	Fast_BSS,bss
Old_SSP:	ds.l 1
	ds.b	4096
Stack_top:
