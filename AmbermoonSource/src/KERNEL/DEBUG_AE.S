; Debug build only: shows the location of a 68000 address error.
; Assembled only if the symbol DEBUG is defined (see compile_debug.sh in
; Disks/Bugfixing/Executables). Instead of the Guru 8000 0003, the
; diagnostic screen shows the offset of the crash in the code hunk, the
; accessed address, the PC and the instruction word. Look the offset up in
; a listing of the debug build (vasm option -L).
; Only installed on a plain 68000 (the exception frame differs on 68010+).

	SECTION	Program,code
Install_AE_handler:
	movem.l	d0/a0,-(sp)
	move.l	4,a0
	move.w	296(a0),d0		; AttnFlags
	andi.w	#3,d0			; 68010 / 68020 ?
	bne.s	.Exit			; Only for the plain 68000
	move.l	$c,Dbg_old_vector
	move.l	#AE_handler,$c
.Exit:	movem.l	(sp)+,d0/a0
	rts

; 68000 address error frame: 0(sp) status word, 2(sp) access address,
; 6(sp) instruction register, 8(sp) SR, 10(sp) PC
AE_handler:
	move.l	2(sp),Dbg_access
	move.w	6(sp),Dbg_ir
	move.l	10(sp),Dbg_pc
	move.l	#AE_show,10(sp)		; Continue in AE_show
	ori.w	#$2000,8(sp)		; ... in supervisor mode
	addq.l	#8,sp			; Remove extra words of the frame
	rte

AE_show:
	move.w	#$2000,sr
	lea.l	Return_value,sp
	jsr	Init_diagnostic_screen
	lea.l	Dbg_txt1,a1
	jsr	DI_Print
	jsr	DI_CR
	jsr	DI_CR
	lea.l	Dbg_txt_hunk0,a1		; Offsets in the code hunks
	move.l	#Start,d1
	bsr	.Offset
	lea.l	Dbg_txt_hunk8,a1
	move.l	#Check_item_cursed,d1
	bsr	.Offset
	lea.l	Dbg_txt_hunkB,a1
	move.l	#Insert_horizon,d1
	bsr	.Offset
	lea.l	Dbg_txt_hunkC,a1
	move.l	#Fast_blit_columns1,d1
	bsr	.Offset
	jsr	DI_CR
	lea.l	Dbg_txt_acc,a1		; Access address
	jsr	DI_Print
	move.l	Dbg_access,d0
	bsr	Print_hex
	jsr	DI_CR
	lea.l	Dbg_txt_pc,a1		; Absolute PC
	jsr	DI_Print
	move.l	Dbg_pc,d0
	bsr	Print_hex
	jsr	DI_CR
	lea.l	Dbg_txt_ir,a1		; Instruction word
	jsr	DI_Print
	move.w	Dbg_ir,d0
	swap	d0
	clr.w	d0
	bsr	Print_hex
	jsr	DI_CR
.Halt:	bra.s	.Halt

.Offset:
	move.l	Dbg_pc,d0
	sub.l	d1,d0
	bmi.s	.No
	cmp.l	#$40000,d0
	bpl.s	.No
	jsr	DI_Print
	bsr	Print_hex
	jsr	DI_CR
.No:	rts

; Print d0 as 8 hex digits
Print_hex:
	movem.l	d0-d2/a1,-(sp)
	lea.l	Dbg_hexbuf,a1
	moveq.l	#8-1,d2
.Loop:	rol.l	#4,d0
	move.b	d0,d1
	andi.b	#$f,d1
	addi.b	#'0',d1
	cmpi.b	#'9',d1
	bls.s	.Ok
	addq.b	#'A'-'9'-1,d1
.Ok:	move.b	d1,(a1)+
	dbra	d2,.Loop
	clr.b	(a1)
	lea.l	Dbg_hexbuf,a1
	jsr	DI_Print
	movem.l	(sp)+,d0-d2/a1
	rts

	SECTION	Fast_DATA,data
Dbg_txt1:	dc.b	"ADDRESS ERROR (DEBUG BUILD)",0
Dbg_txt_hunk0:	dc.b	"OFFSET HUNK 0: ",0
Dbg_txt_hunk8:	dc.b	"OFFSET HUNK 8: ",0
Dbg_txt_hunkB:	dc.b	"OFFSET HUNK 11: ",0
Dbg_txt_hunkC:	dc.b	"OFFSET HUNK 12: ",0
Dbg_txt_acc:	dc.b	"ACCESS ADDRESS: ",0
Dbg_txt_pc:	dc.b	"PC: ",0
Dbg_txt_ir:	dc.b	"INSTRUCTION: ",0
	even

	SECTION	Fast_BSS,bss
Dbg_old_vector:	ds.l	1
Dbg_access:	ds.l	1
Dbg_pc:	ds.l	1
Dbg_ir:	ds.w	1
Dbg_hexbuf:	ds.b	10
