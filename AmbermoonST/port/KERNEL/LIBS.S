; ST kernel : emulation of the Amiga libraries which the original code calls
;
; KERNEL/MEMORY.S calls exec.library (AllocMem, FreeMem, AvailMem) and
; graphics.library (OwnBlitter, DisownBlitter), KERNEL/FILES.S calls
; dos.library (Open, Close, Read, Write, Seek, Lock, UnLock, Examine, IoErr).
; A library is called with "jsr _LVOxxx(a6)", a6 = library base, and every
; entry below the base is a JMP instruction (6 bytes). So the library bases
; below are jump tables to ST routines with the register interface of the
; Amiga functions, and the original code stays unchanged. Only the exec base
; is not read from address 4 (ROM on the ST) : build.sh replaces
; "move.l 4,a6" in KERNEL/MEMORY.S by "move.l ST_exec_base,a6".

	SECTION	Program,code

Lib_entry	macro
	dc.w	$4ef9			; jmp (xxx).l
	dc.l	\1
	endm

;*****************************************************************************
; Jump tables (the base is the end of each table)
;*****************************************************************************
Exec_table:
	Lib_entry	Exec_AvailMem		; -216
	Lib_entry	Exec_FreeMem		; -210
	Lib_entry	Lib_unknown		; -204
	Lib_entry	Exec_AllocMem		; -198
	Lib_entry	Lib_unknown		; -192
	Lib_entry	Lib_unknown		; -186
	Lib_entry	Lib_unknown		; -180
	Lib_entry	Lib_unknown		; -174
	Lib_entry	Lib_unknown		; -168
	Lib_entry	Lib_unknown		; -162
	Lib_entry	Lib_unknown		; -156
	Lib_entry	Lib_unknown		; -150
	Lib_entry	Lib_unknown		; -144
	Lib_entry	Lib_unknown		; -138
	Lib_entry	Lib_unknown		; -132
	Lib_entry	Lib_unknown		; -126
	Lib_entry	Lib_unknown		; -120
	Lib_entry	Lib_unknown		; -114
	Lib_entry	Lib_unknown		; -108
	Lib_entry	Lib_unknown		; -102
	Lib_entry	Lib_unknown		; -96
	Lib_entry	Lib_unknown		; -90
	Lib_entry	Lib_unknown		; -84
	Lib_entry	Lib_unknown		; -78
	Lib_entry	Lib_unknown		; -72
	Lib_entry	Lib_unknown		; -66
	Lib_entry	Lib_unknown		; -60
	Lib_entry	Lib_unknown		; -54
	Lib_entry	Lib_unknown		; -48
	Lib_entry	Lib_unknown		; -42
	Lib_entry	Lib_unknown		; -36
	Lib_entry	Lib_unknown		; -30
	Lib_entry	Lib_unknown		; -24
	Lib_entry	Lib_unknown		; -18
	Lib_entry	Lib_unknown		; -12
	Lib_entry	Lib_unknown		; -6
Exec_lib_base:

Dos_table:
	Lib_entry	Dos_IoErr		; -132
	Lib_entry	Lib_unknown		; -126
	Lib_entry	Lib_unknown		; -120
	Lib_entry	Lib_unknown		; -114
	Lib_entry	Lib_unknown		; -108
	Lib_entry	Dos_Examine		; -102
	Lib_entry	Lib_unknown		; -96
	Lib_entry	Dos_UnLock		; -90
	Lib_entry	Dos_Lock		; -84
	Lib_entry	Lib_unknown		; -78
	Lib_entry	Lib_unknown		; -72
	Lib_entry	Dos_Seek		; -66
	Lib_entry	Lib_unknown		; -60
	Lib_entry	Lib_unknown		; -54
	Lib_entry	Dos_Write		; -48
	Lib_entry	Dos_Read		; -42
	Lib_entry	Dos_Close		; -36
	Lib_entry	Dos_Open		; -30
	Lib_entry	Lib_unknown		; -24
	Lib_entry	Lib_unknown		; -18
	Lib_entry	Lib_unknown		; -12
	Lib_entry	Lib_unknown		; -6
Dos_lib_base:

Gfx_table:
	Lib_entry	Lib_nothing		; -462
	Lib_entry	Lib_nothing		; -456
	Lib_entry	Lib_unknown		; -450
	Lib_entry	Lib_unknown		; -444
	Lib_entry	Lib_unknown		; -438
	Lib_entry	Lib_unknown		; -432
	Lib_entry	Lib_unknown		; -426
	Lib_entry	Lib_unknown		; -420
	Lib_entry	Lib_unknown		; -414
	Lib_entry	Lib_unknown		; -408
	Lib_entry	Lib_unknown		; -402
	Lib_entry	Lib_unknown		; -396
	Lib_entry	Lib_unknown		; -390
	Lib_entry	Lib_unknown		; -384
	Lib_entry	Lib_unknown		; -378
	Lib_entry	Lib_unknown		; -372
	Lib_entry	Lib_unknown		; -366
	Lib_entry	Lib_unknown		; -360
	Lib_entry	Lib_unknown		; -354
	Lib_entry	Lib_unknown		; -348
	Lib_entry	Lib_unknown		; -342
	Lib_entry	Lib_unknown		; -336
	Lib_entry	Lib_unknown		; -330
	Lib_entry	Lib_unknown		; -324
	Lib_entry	Lib_unknown		; -318
	Lib_entry	Lib_unknown		; -312
	Lib_entry	Lib_unknown		; -306
	Lib_entry	Lib_unknown		; -300
	Lib_entry	Lib_unknown		; -294
	Lib_entry	Lib_unknown		; -288
	Lib_entry	Lib_unknown		; -282
	Lib_entry	Lib_unknown		; -276
	Lib_entry	Lib_unknown		; -270
	Lib_entry	Lib_unknown		; -264
	Lib_entry	Lib_unknown		; -258
	Lib_entry	Lib_unknown		; -252
	Lib_entry	Lib_unknown		; -246
	Lib_entry	Lib_unknown		; -240
	Lib_entry	Lib_unknown		; -234
	Lib_entry	Lib_unknown		; -228
	Lib_entry	Lib_unknown		; -222
	Lib_entry	Lib_unknown		; -216
	Lib_entry	Lib_unknown		; -210
	Lib_entry	Lib_unknown		; -204
	Lib_entry	Lib_unknown		; -198
	Lib_entry	Lib_unknown		; -192
	Lib_entry	Lib_unknown		; -186
	Lib_entry	Lib_unknown		; -180
	Lib_entry	Lib_unknown		; -174
	Lib_entry	Lib_unknown		; -168
	Lib_entry	Lib_unknown		; -162
	Lib_entry	Lib_unknown		; -156
	Lib_entry	Lib_unknown		; -150
	Lib_entry	Lib_unknown		; -144
	Lib_entry	Lib_unknown		; -138
	Lib_entry	Lib_unknown		; -132
	Lib_entry	Lib_unknown		; -126
	Lib_entry	Lib_unknown		; -120
	Lib_entry	Lib_unknown		; -114
	Lib_entry	Lib_unknown		; -108
	Lib_entry	Lib_unknown		; -102
	Lib_entry	Lib_unknown		; -96
	Lib_entry	Lib_unknown		; -90
	Lib_entry	Lib_unknown		; -84
	Lib_entry	Lib_unknown		; -78
	Lib_entry	Lib_unknown		; -72
	Lib_entry	Lib_unknown		; -66
	Lib_entry	Lib_unknown		; -60
	Lib_entry	Lib_unknown		; -54
	Lib_entry	Lib_unknown		; -48
	Lib_entry	Lib_unknown		; -42
	Lib_entry	Lib_unknown		; -36
	Lib_entry	Lib_unknown		; -30
	Lib_entry	Lib_unknown		; -24
	Lib_entry	Lib_unknown		; -18
	Lib_entry	Lib_unknown		; -12
	Lib_entry	Lib_unknown		; -6
Gfx_lib_base:

; [ Set the library bases ]
; All registers are restored
Init_libraries:
	move.l	#Exec_lib_base,ST_exec_base
	move.l	#Dos_lib_base,Library_dos
	move.l	#Gfx_lib_base,Library_graphics
	rts

Lib_nothing:
	rts

Lib_unknown:
	moveq.l	#0,d0
	rts

;*****************************************************************************
; [ exec.library ]
;*****************************************************************************
MEMF_LARGEST	EQU	$20000
MEMF_FAST	EQU	4
Mem_reserve	EQU	32768			; Left for GEMDOS (file buffers)

; [ AvailMem ]
;   IN : d1 - Requirements (.l)
;  OUT : d0 - Free memory (.l)
; There is no FAST memory : the original code then uses one chain of CHIP
; memory blocks.
Exec_AvailMem:
	movem.l	d1-d2/a0-a2,-(sp)
	moveq.l	#0,d0
	btst	#2,d1			; FAST ?
	bne.s	.Exit
	move.l	d1,-(sp)
	move.l	#-1,-(sp)			; Malloc(-1) : largest block
	move.w	#Malloc,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	move.l	(sp)+,d1
	btst	#17,d1			; Largest block ?
	beq.s	.Exit
	sub.l	#Mem_reserve,d0		; Yes -> keep a reserve
	bpl.s	.Exit
	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d1-d2/a0-a2
	rts

; [ AllocMem ]
;   IN : d0 - Size (.l)
;        d1 - Requirements (.l)
;  OUT : d0 - Pointer to memory / 0 (.l)
Exec_AllocMem:
	movem.l	d1-d3/a0-a2,-(sp)
	move.l	d0,d3
	btst	#2,d1			; FAST ?
	bne.s	.None
	move.l	d0,-(sp)			; Malloc(size)
	move.w	#Malloc,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	tst.l	d0
	beq.s	.Exit
	lea.l	Mem_blocks,a0		; Remember the block
	moveq.l	#Max_mem_blocks-1,d2
.Find:	tst.l	(a0)
	beq.s	.Store
	addq.l	#8,a0
	dbra	d2,.Find
	bra.s	.Exit
.Store:	move.l	d0,(a0)+
	move.l	d3,(a0)
	bra.s	.Exit
.None:	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d1-d3/a0-a2
	rts

; [ FreeMem ]
;   IN : d0 - Size (.l)
;        a1 - Pointer to memory (.l)
; The original code also frees the end of a block : the block is shrunk.
Exec_FreeMem:
	movem.l	d0-d3/a0-a2,-(sp)
	lea.l	Mem_blocks,a0
	moveq.l	#Max_mem_blocks-1,d2
.Find:	move.l	(a0),d1			; Block which contains the memory ?
	beq.s	.Next
	cmp.l	a1,d1
	bhi.s	.Next
	add.l	4(a0),d1
	cmp.l	a1,d1
	bls.s	.Next
	cmp.l	(a0),a1			; Whole block ?
	bne.s	.Shrink
	clr.l	(a0)
	move.l	a1,-(sp)			; Mfree(block)
	move.w	#Mfree,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	bra.s	.Exit
.Shrink:	move.l	a1,d1			; Mshrink(block, new size)
	sub.l	(a0),d1
	move.l	d1,4(a0)
	move.l	d1,-(sp)
	move.l	(a0),-(sp)
	clr.w	-(sp)
	move.w	#Mshrink,-(sp)
	trap	#GEMDOS
	lea.l	12(sp),sp
	bra.s	.Exit
.Next:	addq.l	#8,a0
	dbra	d2,.Find
.Exit:	movem.l	(sp)+,d0-d3/a0-a2
	rts

;*****************************************************************************
; [ dos.library ]
; The files are in the folder DATA of the program, with 8.3 names (see
; [ Translate_path ]). A file handle is the GEMDOS handle + 1 (never 0).
;*****************************************************************************
MODE_NEWFILE	EQU	1006

; [ Open ]
;   IN : d1 - Pointer to file name (.l)
;        d2 - Mode (1005 = old file, 1006 = new file) (.l)
;  OUT : d0 - File handle / 0 (.l)
Dos_Open:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	d1,a0
	jsr	Translate_path
	jsr	Timer_C_on
	cmp.l	#MODE_NEWFILE,d2
	bne.s	.Old
	clr.w	-(sp)			; Fcreate(name, 0)
	move.l	a0,-(sp)
	move.w	#Fcreate,-(sp)
	bra.s	.Do
.Old:	move.w	#2,-(sp)			; Fopen(name, read / write)
	move.l	a0,-(sp)
	move.w	#Fopen,-(sp)
.Do:	trap	#GEMDOS
	addq.l	#8,sp
	jsr	Timer_C_off
	tst.l	d0
	bpl.s	.Ok
	move.l	d0,Dos_error
	moveq.l	#0,d0
	bra.s	.Exit
.Ok:	ext.l	d0
	addq.l	#1,d0
.Exit:	movem.l	(sp)+,d1-d2/a0-a2
	rts

; [ Close ]
;   IN : d1 - File handle (.l)
Dos_Close:
	movem.l	d0-d2/a0-a2,-(sp)
	subq.w	#1,d1
	move.w	d1,-(sp)			; Fclose(handle)
	move.w	#Fclose,-(sp)
	trap	#GEMDOS
	addq.l	#4,sp
	movem.l	(sp)+,d0-d2/a0-a2
	moveq.l	#-1,d0
	rts

; [ Read / Write ]
;   IN : d1 - File handle (.l)
;        d2 - Pointer to buffer (.l)
;        d3 - Length (.l)
;  OUT : d0 - Number of bytes / -1 (.l)
Dos_Read:
	move.w	#Fread,Dos_function
	bra.s	Dos_ReadWrite
Dos_Write:
	move.w	#Fwrite,Dos_function
Dos_ReadWrite:
	movem.l	d1-d3/a0-a2,-(sp)
	jsr	Timer_C_on
	subq.w	#1,d1
	move.l	d2,-(sp)			; Fread / Fwrite(handle, length, buffer)
	move.l	d3,-(sp)
	move.w	d1,-(sp)
	move.w	Dos_function,-(sp)
	trap	#GEMDOS
	lea.l	12(sp),sp
	jsr	Timer_C_off
	tst.l	d0
	bpl.s	.Exit
	move.l	d0,Dos_error
	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d1-d3/a0-a2
	rts

; [ Seek ]
;   IN : d1 - File handle (.l)
;        d2 - Position (.l)
;        d3 - Mode (-1 = from the start, 0 = from the current position,
;             1 = from the end) (.l)
;  OUT : d0 - Old position / -1 (.l)
Dos_Seek:
	movem.l	d1-d4/a0-a2,-(sp)
	subq.w	#1,d1
	move.w	#1,-(sp)			; Fseek(0, handle, current)
	move.w	d1,-(sp)
	clr.l	-(sp)
	move.w	#Fseek,-(sp)
	trap	#GEMDOS
	lea.l	10(sp),sp
	move.l	d0,d4			; Old position
	bmi.s	.Error
	addq.w	#1,d3			; Amiga mode -> GEMDOS mode
	move.w	d3,-(sp)			; Fseek(position, handle, mode)
	move.w	d1,-(sp)
	move.l	d2,-(sp)
	move.w	#Fseek,-(sp)
	trap	#GEMDOS
	lea.l	10(sp),sp
	tst.l	d0
	bmi.s	.Error
	move.l	d4,d0
	bra.s	.Exit
.Error:	move.l	d0,Dos_error
	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d1-d4/a0-a2
	rts

; [ Lock ]
;   IN : d1 - Pointer to file name (.l)
;  OUT : d0 - Lock / 0 (.l)
; The only use is [ Get_file_size ] (Lock, Examine, UnLock) : the size is
; read with Fsfirst and kept, the lock is a dummy.
Dos_Lock:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	d1,a0
	jsr	Translate_path
	move.l	#Dos_DTA,-(sp)		; Fsetdta
	move.w	#Fsetdta,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	jsr	Timer_C_on
	clr.w	-(sp)			; Fsfirst(name, normal files)
	move.l	a0,-(sp)
	move.w	#Fsfirst,-(sp)
	trap	#GEMDOS
	addq.l	#8,sp
	jsr	Timer_C_off
	tst.l	d0
	beq.s	.Ok
	move.l	d0,Dos_error
	moveq.l	#0,d0
	bra.s	.Exit
.Ok:	move.l	Dos_DTA+26,Dos_lock_size	; File size
	moveq.l	#1,d0
.Exit:	movem.l	(sp)+,d1-d2/a0-a2
	rts

; [ UnLock ]
Dos_UnLock:
	rts

; [ Examine ]
;   IN : d1 - Lock (.l)
;        d2 - Pointer to file info block (.l)
;  OUT : d0 - Success (.l)
Dos_Examine:
	move.l	a0,-(sp)
	move.l	d2,a0
	move.l	Dos_lock_size,124(a0)	; fib_Size
	move.l	(sp)+,a0
	moveq.l	#-1,d0
	rts

; [ IoErr ]
;  OUT : d0 - Last error (.l)
; The GEMDOS errors are translated to the AmigaDOS errors which the original
; code knows (KERNEL/FILES.S, [ Handle_disk_error ]).
Dos_IoErr:
	move.l	Dos_error,d0
	cmp.l	#-33,d0			; File not found ?
	beq.s	.Not_found
	cmp.l	#-34,d0			; Path not found ?
	beq.s	.Not_found
	cmp.l	#-36,d0			; Access denied ?
	beq.s	.Protected
	move.l	#ERROR_SEEK_ERROR,d0	; Others
	rts
.Not_found:	move.l	#ERROR_OBJECT_NOT_FOUND,d0
	rts
.Protected:	move.l	#ERROR_WRITE_PROTECTED,d0
	rts

; [ Switch the TOS system timer on / off ]
; Timer C is needed by the disk drivers (time-outs). While the system is
; taken over, it is only switched on while a file is accessed. When Timer C
; is the 50 Hz of the game ([ Tick_timer ], SYSTEM.S) it stays on, the TOS
; gets its interrupts from [ Tick_interrupt ] while a file is accessed.
; All registers are restored
Timer_C_on:
	tst.b	System_active
	beq.s	.Exit
	tst.b	Tick_timer
	beq.s	.Own
	st	TOS_timer_C
	rts
.Own:	bset	#5,MFP_IERB
	bset	#5,MFP_IMRB
.Exit:	rts

Timer_C_off:
	tst.b	System_active
	beq.s	.Exit
	tst.b	Tick_timer
	beq.s	.Own
	sf	TOS_timer_C
	rts
.Own:	bclr	#5,MFP_IERB
	bclr	#5,MFP_IMRB
.Exit:	rts

;*****************************************************************************
; [ Translate an Amiga file name to an ST file name ]
;   IN : a0 - Pointer to Amiga file name (.l)
;  OUT : a0 - Pointer to ST file name (.l)
; NOTE :
;   - The volume ("AMBER_A:") and the folder "Amberfiles/" are removed, the
;     rest (e.g. "Save.00/Party_char.amb") is looked up in [ File_map ]
;     (made by build.sh, the files have 8.3 names on the ST). Unknown names
;     are shortened to 8.3.
;*****************************************************************************
Translate_path:
	movem.l	d0-d2/a1-a3,-(sp)
	move.l	a0,a1			; Skip the volume
.Volume:	move.b	(a1)+,d0
	beq.s	.No_volume
	cmp.b	#':',d0
	bne.s	.Volume
	move.l	a1,a0
.No_volume:	lea.l	.Folder(pc),a1		; Skip "Amberfiles/"
	move.l	a0,a2
.Compare:	move.b	(a1)+,d0
	beq.s	.Skip
	move.b	(a2)+,d1
	jsr	Upper_case
	exg	d0,d1
	jsr	Upper_case
	cmp.b	d0,d1
	beq.s	.Compare
	bra.s	.Plain
.Skip:	move.l	a2,a0
.Plain:	move.l	a0,Plain_name
	jsr	Palette_copy_name		; (the copy of the map palette ?)
.Lookup:	lea.l	File_map,a1		; Search the name
.Entry:	tst.b	(a1)			; End ?
	beq.s	.Unknown
	move.l	a0,a2
.Char:	move.b	(a1)+,d0
	move.b	(a2)+,d1
	jsr	Upper_case
	exg	d0,d1
	jsr	Upper_case
	cmp.b	d0,d1
	bne.s	.Differs
	tst.b	d0
	bne.s	.Char
	lea.l	ST_path,a2		; Found -> "DATA\<short name>"
	lea.l	.Data(pc),a3
.Copy1:	move.b	(a3)+,(a2)+
	bne.s	.Copy1
	subq.l	#1,a2
.Copy2:	move.b	(a1)+,(a2)+
	bne.s	.Copy2
	bra.s	.Done
.Differs:	tst.b	-1(a1)			; Skip the rest of the long name
	beq.s	.Short
.Rest:	tst.b	(a1)+
	bne.s	.Rest
.Short:	tst.b	(a1)+			; Skip the short name
	bne.s	.Short
	bra.s	.Entry
.Unknown:	cmp.l	Plain_name,a0		; Not found : the copy of a palette ?
	beq.s	.Shorten
	move.l	Plain_name,a0		; Yes -> the file itself
	bra	.Lookup
.Shorten:	lea.l	ST_path,a2		; Shorten : "DATA\" + components
	lea.l	.Data(pc),a3
.Copy3:	move.b	(a3)+,(a2)+
	bne.s	.Copy3
	subq.l	#1,a2
.Component:	moveq.l	#0,d2			; Characters of the name
.Name:	move.b	(a0)+,d0
	beq.s	.End
	cmp.b	#'/',d0
	beq.s	.Separator
	cmp.b	#'.',d0
	beq.s	.Extension
	cmp.w	#8,d2
	bpl.s	.Name
	jsr	Upper_case
	move.b	d0,(a2)+
	addq.w	#1,d2
	bra.s	.Name
.Extension:	move.b	d0,(a2)+
	moveq.l	#3-1,d2
.Ext:	move.b	(a0)+,d0
	beq.s	.End
	cmp.b	#'/',d0
	beq.s	.Separator
	tst.w	d2
	bmi.s	.Ext
	jsr	Upper_case
	move.b	d0,(a2)+
	subq.w	#1,d2
	bra.s	.Ext
.Separator:	move.b	#'\',(a2)+
	bra.s	.Component
.End:	clr.b	(a2)
.Done:	lea.l	ST_path,a0
	movem.l	(sp)+,d0-d2/a1-a3
	rts

.Folder:	dc.b	"AMBERFILES/",0
.Data:	dc.b	"DATA\",0
	even

;*****************************************************************************
; [ Name of the copy of a graphics file for the palette of the current map ]
;   IN : a0 - Pointer to the file name (without volume and folder) (.l)
;  OUT : a0 - Pointer to "<name>#<palette number>" or the same name (.l)
; All other registers are restored
; NOTE :
;   - The party, NPC and transport graphics are shown with the palettes of
;     all 2D maps : the files have a copy per palette, converted to the ST
;     format with that palette (port/tools/port_gfx.py).
;*****************************************************************************
Palette_copy_name:
	movem.l	d0-d2/a1-a3,-(sp)
	lea.l	.Names(pc),a1
.Name:	tst.b	(a1)			; End of the list ?
	beq.s	.Exit
	move.l	a0,a2
.Char:	move.b	(a1)+,d0
	move.b	(a2)+,d1
	jsr	Upper_case
	exg	d0,d1
	jsr	Upper_case
	cmp.b	d0,d1
	bne.s	.Next
	tst.b	d0
	bne.s	.Char
	moveq.l	#0,d0			; This one : palette of the map
	move.b	Mapdata_handle,d0
	beq.s	.Exit
	jsr	Claim_pointer
	move.l	d0,a3
	moveq.l	#0,d2
	move.b	Colourpal_filenr(a3),d2
	move.b	Mapdata_handle,d0
	jsr	Free_pointer
	lea.l	Palette_copy,a2		; "<name>#<number>"
.Copy:	move.b	(a0)+,(a2)+
	bne.s	.Copy
	move.b	#'#',-1(a2)
	divu.w	#10,d2
	tst.w	d2
	beq.s	.Units
	add.b	#'0',d2
	move.b	d2,(a2)+
.Units:	swap	d2
	add.b	#'0',d2
	move.b	d2,(a2)+
	clr.b	(a2)
	lea.l	Palette_copy,a0
	bra.s	.Exit
.Next:	tst.b	-1(a1)			; Skip the rest of the name
	beq.s	.Name
.Rest:	tst.b	(a1)+
	bne.s	.Rest
	bra.s	.Name
.Exit:	movem.l	(sp)+,d0-d2/a1-a3
	rts

.Names:	dc.b	"Party_gfx.amb",0,"NPC_gfx.amb",0,"Travel_gfx.amb",0,"Stationary",0,0
	even

; [ Upper case ]
;   IN : d0 - Character (.b)
;  OUT : d0 - Upper case character (.b)
Upper_case:
	cmp.b	#'a',d0
	bcs.s	.Exit
	cmp.b	#'z'+1,d0
	bcc.s	.Exit
	subi.b	#'a'-'A',d0
.Exit:	rts

	SECTION	Fast_BSS,bss
Plain_name:	ds.l 1			; (Translate_path)
Palette_copy:	ds.b 64

	SECTION	Program,code
	include	ST_KERNEL/FILEMAP.I		; [ File_map ] (made by build.sh)

	SECTION	Fast_BSS,bss
ST_exec_base:	ds.l 1
Max_mem_blocks	EQU	16
Mem_blocks:	ds.l 2*Max_mem_blocks	; Address & size of allocated blocks
Dos_error:	ds.l 1
Dos_lock_size:	ds.l 1
Dos_function:	ds.w 1
Dos_DTA:	ds.b 44
ST_path:	ds.b 128
	even
