; File manager (loading, saving, packers, disk errors)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Load the subfile sizes of a file ]
;   IN : d0 - File number (.w)
;  OUT : a0 - Pointer to size list (.l)
;*****************************************************************************
Load_subfile_sizes:
	movem.l	d0-d3/a0/a1,-(sp)
	clr.l	6(a5)
	move.w	10(a5),d0
	jsr	Get_file_path_by_index
	move.b	(a0)+,Current_disk_index_for_file_loading
	move.l	a0,Current_filename
	move.l	a0,d1
	move.l	#1005,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)		; Open
	move.l	(sp)+,a6
	tst.l	d0
	beq.w	.Skip2		; Error
	move.l	d0,6(a5)		; Success, store new file handle
	move.l	d0,Current_open_file_handle
	move.l	6(a5),d1
	move.l	a5,d2		; Read into buffer A5
	addi.l	#0,d2
	moveq.l	#6,d3		; Read 6 bytes
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip2		; Error
	cmp.l	d0,d3		; Compare num read bytes
					; to requested bytes.
	beq.s	.Skip
.Loop:
	move.w	#500,Dos_IO_error_code		; error 500
	bra.w	.Skip3
.Skip:
	move.l	6(a5),d1
	move.l	#Sub_file_sizes,d2		; Buffer to subfile sizes
	moveq.l	#0,d3
	move.w	4(a5),d3		; Num files is at offset 4
					; (we read 6 bytes before
					; which is 4 bytes header
					; plus the num files word).
	lsl.l	#2,d3		; * 4 as each file's size
					; is given as a long.
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)		; Read the sub file sizes.
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip2		; Error
	cmp.l	d0,d3		; Read enough bytes?
	bne.s	.Loop
	movem.l	(sp)+,d0-d3/a0/a1
	rts
.Skip2:
	jsr	Get_dos_IO_error
.Skip3:
	movem.l	(sp)+,d0-d3/a0/a1
	jsr	Close_file
	jsr	Handle_disk_error
	bra.w	Load_subfile_sizes

;*****************************************************************************
; [ Close the current file ]
;*****************************************************************************
Close_file:
	jmp	Close_current_file

;*****************************************************************************
; [ Load a subfile ]
;   IN : d0 - Subfile number (.w)
;        d1 - File number (.w)
;  OUT : d0 - Memory handle (.b)
; NOTE (disassembly) :
;   D1 = File index
;   D0 = Sub file index (texture index)
;*****************************************************************************
Load_subfile:
	movem.l	d1-d7/a0-a6,-(sp)
	lea.l	-28(sp),sp
	move.l	sp,a5
	clr.b	22(a5)
	move.w	d0,12(a5)
	move.w	d1,10(a5)
	jsr	Reallocate_memory
	tst.b	d0
	bne.w	.Exit		; Already loaded? Return handle.
	jsr	Free_blitter_usage
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	jsr	Load_subfile_sizes
	move.w	12(a5),d1
	cmp.w	4(a5),d1
	ble.s	.Skip
	jsr	Close_file
	bra.w	.Skip3
.Skip:
	lea.l	Sub_file_sizes,a0		; Get just loaded subfile sizes
	moveq.l	#0,d0		; Init offset as 0
	move.w	12(a5),d1
	subq.w	#1,d1		; Sum all sizes before our
					; given file. Index is 1-based
					; so sub 1 here.
	bra.s	.Skip2
.Loop:
	add.l	(a0)+,d0		; Add the size to the offset
.Skip2:
	dbra	d1,.Loop		; Loop through all preceding subfiles
	move.l	d0,14(a5)		; Store offset to subfile data
	move.l	(a0),18(a5)		; Store size of subfile
	jsr	Load_subfile_from_archive
	jsr	Close_file
.Skip3:
	jsr	Pop_Mptr
	jsr	Own_blitter
	move.b	22(a5),d0
	bne.s	.Exit
	jmp	Fatal_error
.Exit:
	lea.l	28(sp),sp
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Load a subfile into its own memory block (never shared) ]
;   IN : d0 - Subfile number (.w)
;        d1 - File number (.w)
;  OUT : d0 - Memory handle (.b)
;*****************************************************************************
Load_unique_subfile:
	movem.l	d1-d7/a0-a6,-(sp)
	lea.l	-28(sp),sp
	move.l	sp,a5
	clr.b	22(a5)
	move.w	d0,12(a5)
	move.w	d1,10(a5)
	jsr	Duplicate_or_load_block
	tst.b	d0
	bne.w	.Exit
	jsr	Free_blitter_usage
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	jsr	Load_subfile_sizes
	move.w	12(a5),d1
	cmp.w	4(a5),d1
	ble.s	.Skip
	jsr	Close_file
	bra.w	.Skip5
.Skip:
	lea.l	Sub_file_sizes,a0
	moveq.l	#0,d0
	move.w	12(a5),d1
	subq.w	#1,d1
	bra.s	.Skip2
.Loop:
	add.l	(a0)+,d0
.Skip2:
	dbra	d1,.Loop
	move.l	d0,14(a5)
	tst.l	(a0)
	bne.s	.Skip3
	move.b	#-1,22(a5)
	bra.s	.Skip4
.Skip3:
	move.l	(a0),18(a5)
	jsr	Load_subfile_from_archive
.Skip4:
	jsr	Close_file
.Skip5:
	jsr	Pop_Mptr
	jsr	Own_blitter
	move.b	22(a5),d0
	bne.s	.Exit
	jmp	Fatal_error
.Exit:
	lea.l	28(sp),sp
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Load several subfiles ]
;   IN : d0 - Number of subfiles (.w)
;        d1 - File number (.w)
;        a0 - Pointer to list of subfile numbers (.w)
;        a1 - Pointer to list of handles (.b)
; NOTE (disassembly) :
;   D0 = Count
;   D1 = Type of data (file id)
;   see https://gitlab.com/ambermoon/research/-/wikis/files
;   A0 = Indices (sub-file ids like map id etc)
;   A1 = Target list with pointer ids
;*****************************************************************************
Load_batch_of_subfiles:
	movem.l	d0-d7/a0-a6,-(sp)
	st	Batch_loading_flag
	cmp.w	#1,d0		; Single data pointer
	bne.s	.Skip
	move.w	(a0),d0		; Index (key)
	jsr	Load_subfile
	move.b	d0,(a1)
	bra.w	.Exit
.Skip:
	lea.l	-38(sp),sp
	move.l	sp,a5
	move.w	d0,32(a5)		; Count
	move.w	d1,10(a5)		; Type
	move.l	a1,28(a5)		; Target id list
	tst.w	d0
	beq.w	.Skip10		; Count = 0, skip
	; This sorts the ids (keys) and
	; the associated values as well.
	jsr	Sort_dictionary
	move.l	a0,-(sp)
	lea.l	Temp_index_buffer,a3		; This holds the dictionary values
	move.w	10(a5),d1		; Type
	move.w	32(a5),d7		; Now holds the count
	move.w	d7,d6		; Store count in D6 as well
	subq.w	#1,d7
.Loop:
	move.w	(a0),d0		; Index (key)
	beq.s	.Skip2
	jsr	Reallocate_memory
	tst.b	d0
	beq.s	.Skip3
.Skip2:
	subq.w	#1,d6
	move.w	(a3),d2
	move.b	d0,0(a1,d2.w)
	move.w	#-1,(a3)
.Skip3:
	addq.l	#2,a0
	addq.l	#2,a3
	dbra	d7,.Loop
	move.l	(sp)+,a0
	tst.w	d6
	beq.w	.Skip10
	jsr	Free_blitter_usage
	move.l	a0,-(sp)
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	move.l	(sp)+,a0
	jsr	Load_subfile_sizes
	clr.l	34(a5)
	clr.l	18(a5)
	lea.l	Temp_index_buffer,a3
	moveq.l	#0,d6
	move.w	32(a5),d7
	subq.w	#1,d7
.Loop2:
	cmpi.w	#-1,(a3)
	bne.s	.Skip4
	addq.l	#2,a0
	addq.l	#2,a3
	bra.w	.Skip9
.Skip4:
	move.w	(a0)+,d0
	tst.w	d6
	beq.s	.Skip5
	cmp.w	-4(a0),d0
	beq.w	.Skip8
.Skip5:
	move.w	d0,12(a5)
	clr.b	22(a5)
	tst.w	d0
	ble.w	.Skip7
	cmp.w	4(a5),d0
	bgt.w	.Skip7
	lea.l	Sub_file_sizes,a2
	moveq.l	#0,d0
	move.w	12(a5),d1
	subq.w	#1,d1
	bra.s	.Skip6
.Loop3:
	add.l	(a2)+,d0
.Skip6:
	dbra	d1,.Loop3
	move.l	d0,d1
	sub.l	34(a5),d0
	move.l	d1,34(a5)
	sub.l	18(a5),d0
	move.l	d0,14(a5)
	move.l	(a2),18(a5)
	jsr	Load_subfile_from_archive
.Skip7:
	tst.b	22(a5)
	bne.s	.Skip8
	jmp	Fatal_error
.Skip8:
	move.w	(a3)+,d0
	move.b	22(a5),0(a1,d0.w)
.Skip9:
	addq.w	#1,d6
	dbra	d7,.Loop2
	jsr	Close_file
	jsr	Pop_Mptr
	jsr	Own_blitter
.Skip10:
	lea.l	38(sp),sp
.Exit:
	sf	Batch_loading_flag
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Load several subfiles into their own memory blocks ]
;   IN : d0 - Number of subfiles (.w)
;        d1 - File number (.w)
;        a0 - Pointer to list of subfile numbers (.w)
;        a1 - Pointer to list of handles (.b)
;*****************************************************************************
Load_batch_of_unique_subfiles:
	movem.l	d0-d7/a0-a6,-(sp)
	st	Batch_loading_flag
	cmp.w	#1,d0
	bne.s	.Skip3
	move.w	(a0),d0		; Texture index (bit 15 = overlay flag)
	bclr.l	#$f,d0		; Remove overlay flag
	bne.s	.Skip		; Was it set? Branch.
	jsr	Load_subfile
	bra.s	.Skip2
.Skip:
	jsr	Load_unique_subfile
.Skip2:
	move.b	d0,(a1)		; Copy texture handle over
	bra.w	.Exit
.Skip3:
	lea.l	-38(sp),sp
	move.l	sp,a5
	move.w	d0,32(a5)
	move.w	d1,10(a5)
	move.l	a1,28(a5)
	tst.w	d0
	beq.w	.Skip14
	jsr	Sort_dictionary
	move.l	a0,-(sp)
	lea.l	Temp_index_buffer,a3
	move.w	10(a5),d1
	move.w	32(a5),d7
	move.w	d7,d6
	subq.w	#1,d7
.Loop:
	move.w	(a0),d0
	beq.s	.Skip6
	bclr.l	#$f,d0
	bne.s	.Skip4
	jsr	Reallocate_memory
	bra.s	.Skip5
.Skip4:
	jsr	Duplicate_or_load_block
.Skip5:
	tst.b	d0
	beq.s	.Skip7
.Skip6:
	subq.w	#1,d6
	move.w	(a3),d2
	move.b	d0,0(a1,d2.w)
	move.w	#-1,(a3)
.Skip7:
	addq.l	#2,a0
	addq.l	#2,a3
	dbra	d7,.Loop
	move.l	(sp)+,a0
	tst.w	d6
	beq.w	.Skip14
	jsr	Free_blitter_usage
	move.l	a0,-(sp)
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	move.l	(sp)+,a0
	jsr	Load_subfile_sizes
	clr.l	34(a5)
	clr.l	18(a5)
	lea.l	Temp_index_buffer,a3
	moveq.l	#0,d6
	move.w	32(a5),d7
	subq.w	#1,d7
.Loop2:
	cmpi.w	#-1,(a3)
	bne.s	.Skip8
	addq.l	#2,a0
	addq.l	#2,a3
	bra.w	.Skip13
.Skip8:
	move.w	(a0)+,d0
	bclr.l	#$f,d0
	bne.s	.Skip9
	tst.w	d6
	beq.s	.Skip9
	cmp.w	-4(a0),d0
	beq.w	.Skip12
.Skip9:
	move.w	d0,12(a5)
	clr.b	22(a5)
	tst.w	d0
	ble.w	.Skip11
	cmp.w	4(a5),d0
	bgt.w	.Skip11
	lea.l	Sub_file_sizes,a2
	moveq.l	#0,d0
	move.w	12(a5),d1
	subq.w	#1,d1
	bra.s	.Skip10
.Loop3:
	add.l	(a2)+,d0
.Skip10:
	dbra	d1,.Loop3
	move.l	d0,d1
	sub.l	34(a5),d0
	move.l	d1,34(a5)
	sub.l	18(a5),d0
	move.l	d0,14(a5)
	move.l	(a2),18(a5)
	jsr	Load_subfile_from_archive
.Skip11:
	tst.b	22(a5)
	bne.s	.Skip12
	jmp	Fatal_error
.Skip12:
	move.w	(a3)+,d0
	move.b	22(a5),0(a1,d0.w)
.Skip13:
	addq.w	#1,d6
	dbra	d7,.Loop2
	jsr	Close_file
	jsr	Pop_Mptr
	jsr	Own_blitter
.Skip14:
	lea.l	38(sp),sp
.Exit:
	sf	Batch_loading_flag
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Sort the dictionary (words) after loading ]
; NOTE (disassembly) :
;   D0 = count
;   A0 = list of ids
;*****************************************************************************
Sort_dictionary:
	movem.l	d0-d7/a0/a2,-(sp)
	lea.l	Temp_index_buffer,a2
	moveq.l	#0,d1
	move.w	d0,d7
	subq.w	#1,d7		; Loop 'count' times
.Loop:
	move.w	d1,(a2)+		; Set increasing index 0..count-1
	addq.w	#1,d1
	dbra	d7,.Loop
	subq.l	#2,a0		; D7 below starts at 2 so we
					; adjust the pointer so that
					; the first D7 will point to
					; the start of the target list.
	lea.l	Temp_index_buffer-2,a2		; Do the same adjustment for
					; the temp data area as it
					; also uses D7 as word index.
	move.w	d0,d5
	add.w	d5,d5		; D5 = 2 * count
	moveq.l	#2,d7		; D7 starts at 2
	; The following code sorts the ids
.Loop2:
	move.w	2(a0,d7.w),d2		; Next id
	cmp.w	0(a0,d7.w),d2
	bpl.s	.Skip		; If current id < next id -> jump
	move.w	0(a0,d7.w),d3
	move.w	d2,0(a0,d7.w)
	move.w	d3,2(a0,d7.w)		; Swap ids
	move.w	2(a2,d7.w),d2
	move.w	0(a2,d7.w),d3
	move.w	d2,0(a2,d7.w)
	move.w	d3,2(a2,d7.w)		; Swap indices as well
	move.w	d7,d6
	subq.w	#2,d6
	beq.s	.Skip		; If first iteration, skip
					; following code.
.Loop3:
	move.w	2(a0,d6.w),d2		; Also sort all previous elements
	cmp.w	0(a0,d6.w),d2
	bpl.s	.Skip
	move.w	0(a0,d6.w),d3
	move.w	d2,0(a0,d6.w)
	move.w	d3,2(a0,d6.w)
	move.w	2(a2,d6.w),d2
	move.w	0(a2,d6.w),d3
	move.w	d2,0(a2,d6.w)
	move.w	d3,2(a2,d6.w)
	subq.w	#2,d6
	bne.s	.Loop3
.Skip:
	addq.w	#2,d7		; Next, inc D7 by 2
	cmp.w	d5,d7
	bne.s	.Loop2
	movem.l	(sp)+,d0-d7/a0/a2
	rts

;*****************************************************************************
; [ Load a subfile from an AMBR container (raw data) ]
;*****************************************************************************
Load_AMBR:
	movem.l	d0-d3/d7/a0/a1/a4,-(sp)
	tst.l	18(a5)
	bne.s	.Skip2
	tst.b	Batch_loading_flag
	beq.s	.Skip
	move.l	6(a5),d1
	move.l	14(a5),d2
	moveq.l	#0,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)		; Seek to subfile data
	move.l	(sp)+,a6
	tst.l	d0
	bmi.w	.Skip4
.Skip:
	moveq.l	#0,d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	jsr	Clear_memory
	move.b	d0,22(a5)
	bra.s	.Exit
.Skip2:
	move.l	6(a5),d1
	move.l	14(a5),d2
	moveq.l	#0,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bmi.w	.Skip4
	move.l	18(a5),d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	move.b	d0,22(a5)
	jsr	Claim_pointer
	move.l	d0,24(a5)
	move.l	6(a5),d1
	move.l	d0,d2
	move.l	18(a5),d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip4
	cmp.l	d0,d3
	beq.w	.Skip3
	move.w	#500,Dos_IO_error_code
	bra.w	.Skip5
.Skip3:
	move.b	22(a5),d0
	jsr	Free_pointer
.Exit:
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	rts
.Skip4:
	jsr	Get_dos_IO_error
.Skip5:
	move.b	22(a5),d0
	beq.s	.Skip6
	jsr	Free_pointer
	jsr	Free_memory
.Skip6:
	jsr	Handle_disk_error
	move.l	6(a5),d1
	moveq.l	#0,d2
	move.w	4(a5),d2
	lsl.w	#2,d2
	addq.l	#6,d2
	moveq.l	#-1,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	bra.w	Load_AMBR

;*****************************************************************************
; [ Load a subfile from an AMPC container (packed data) ]
;*****************************************************************************
Load_AMPC:
	movem.l	d0-d3/d7/a0/a1/a4,-(sp)
	tst.l	18(a5)
	bne.s	.Skip2
	tst.b	Batch_loading_flag
	beq.s	.Skip
	move.l	6(a5),d1
	move.l	14(a5),d2
	moveq.l	#0,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bmi.w	.Skip6
.Skip:
	moveq.l	#0,d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	jsr	Clear_memory
	move.b	d0,22(a5)
	bra.w	.Exit
.Skip2:
	move.w	10(a5),d0
	jsr	Set_current_file_compression_space
	move.l	6(a5),d1
	move.l	14(a5),d2
	moveq.l	#0,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bmi.w	.Skip6
	lea.l	File_header_when_loading,a4
	move.l	6(a5),d1
	move.l	a4,d2
	moveq.l	#8,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip6
	cmp.l	d0,d3
	beq.s	.Skip3
.Loop:
	move.w	#500,Dos_IO_error_code
	bra.w	.Skip7
.Skip3:
	cmpi.l	#21778242,(a4)
	beq.w	.Skip4
	move.l	18(a5),d0
	subq.l	#4,d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	move.b	d0,22(a5)
	jsr	Claim_pointer
	move.l	d0,24(a5)
	move.l	d0,a0
	addq.l	#4,a4
	move.l	(a4),(a0)+
	move.l	6(a5),d1
	move.l	a0,d2
	move.l	18(a5),d3
	subq.l	#8,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip6
	cmp.l	d0,d3
	bne.s	.Loop
	bra.w	.Skip5
.Skip4:
	move.l	4(a4),d0
	andi.l	#$ffffff,d0
	move.l	d0,d7
	add.l	Current_file_compression_space,d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	move.b	d0,22(a5)
	jsr	Claim_pointer
	move.l	d0,24(a5)
	move.l	d0,a0
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	6(a5),d1
	move.l	a0,d2
	move.l	18(a5),d3
	subq.l	#8,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip6
	cmp.l	d0,d3
	bne.w	.Loop
	move.l	24(a5),a0
	jsr	Decompress
	move.b	22(a5),d0
	move.l	d7,d1
	jsr	Shrink_memory
.Skip5:
	move.b	22(a5),d0
	jsr	Free_pointer
.Exit:
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	rts
.Skip6:
	jsr	Get_dos_IO_error
.Skip7:
	move.b	22(a5),d0
	beq.s	.Skip8
	jsr	Free_pointer
	jsr	Free_memory
.Skip8:
	jsr	Handle_disk_error
	move.l	6(a5),d1
	moveq.l	#0,d2
	move.w	4(a5),d2
	lsl.w	#2,d2
	addq.l	#6,d2
	moveq.l	#-1,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	bra.w	Load_AMPC

;*****************************************************************************
; [ Load a subfile from an AMNC container (encrypted data) ]
;*****************************************************************************
Load_AMNC:
	jsr	Load_AMBR
	movem.l	d0/d7/a0,-(sp)
	move.w	12(a5),d0
	move.l	18(a5),d7
	move.l	24(a5),a0
	jsr	Crypt_block
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Load a subfile from an AMNP container (packed & encrypted data) ]
;*****************************************************************************
Load_AMNP:
	movem.l	d0-d3/d7/a0/a1/a4,-(sp)
	tst.l	18(a5)
	bne.s	.Skip2
	tst.b	Batch_loading_flag
	beq.s	.Skip
	move.l	6(a5),d1
	move.l	14(a5),d2
	moveq.l	#0,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bmi.w	.Skip6
.Skip:
	moveq.l	#0,d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	jsr	Clear_memory
	move.b	d0,22(a5)
	bra.w	.Exit
.Skip2:
	move.w	10(a5),d0
	jsr	Set_current_file_compression_space
	move.l	6(a5),d1
	move.l	14(a5),d2
	moveq.l	#0,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bmi.w	.Skip6
	lea.l	File_header_when_loading,a4
	move.l	6(a5),d1
	move.l	a4,d2
	moveq.l	#8,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip6
	cmp.l	d0,d3
	beq.s	.Skip3
.Loop:
	move.w	#500,Dos_IO_error_code
	bra.w	.Skip7
.Skip3:
	cmpi.l	#21778242,(a4)
	beq.w	.Skip4
	move.l	18(a5),d0
	subq.l	#4,d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	move.b	d0,22(a5)
	jsr	Claim_pointer
	move.l	d0,24(a5)
	move.l	d0,a0
	addq.l	#4,a4
	move.l	(a4),(a0)+
	move.l	6(a5),d1
	move.l	a0,d2
	move.l	18(a5),d3
	subq.l	#8,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip6
	cmp.l	d0,d3
	bne.s	.Loop
	move.l	d7,-(sp)
	move.w	12(a5),d0
	move.l	d3,d7
	addq.l	#4,d7
	move.l	24(a5),a0
	jsr	Crypt_block
	move.l	(sp)+,d7
	bra.w	.Skip5
.Skip4:
	move.l	4(a4),d0
	andi.l	#$ffffff,d0
	move.l	d0,d7
	add.l	Current_file_compression_space,d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	jsr	File_allocate
	move.b	d0,22(a5)
	jsr	Claim_pointer
	move.l	d0,24(a5)
	move.l	d0,a0
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	6(a5),d1
	move.l	a0,d2
	move.l	18(a5),d3
	subq.l	#8,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip6
	cmp.l	d0,d3
	bne.w	.Loop
	move.l	d7,-(sp)
	move.w	12(a5),d0
	move.l	d3,d7
	move.l	24(a5),a0
	addq.l	#8,a0
	jsr	Crypt_block
	move.l	(sp)+,d7
	subq.l	#8,a0
	jsr	Decompress
	move.b	22(a5),d0
	move.l	d7,d1
	jsr	Shrink_memory
.Skip5:
	move.b	22(a5),d0
	jsr	Free_pointer
.Exit:
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	rts
.Skip6:
	jsr	Get_dos_IO_error
.Skip7:
	move.b	22(a5),d0
	beq.s	.Skip8
	jsr	Free_pointer
	jsr	Free_memory
.Skip8:
	jsr	Handle_disk_error
	move.l	6(a5),d1
	moveq.l	#0,d2
	move.w	4(a5),d2
	lsl.w	#2,d2
	addq.l	#6,d2
	moveq.l	#-1,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	bra.w	Load_AMNP

;*****************************************************************************
; [ Load a file ]
;   IN : d0 - File number (.w)
;  OUT : d0 - Memory handle (.b)
;*****************************************************************************
Load_file:
	movem.l	d1-d7/a0-a6,-(sp)
	jsr	Free_blitter_usage
	lea.l	-22(sp),sp
	move.l	sp,a5
	move.w	d0,0(a5)
	clr.l	10(a5)
	clr.b	18(a5)
	clr.b	19(a5)
	tst.w	d0
	beq.s	.Skip
	move.w	d0,d1
	moveq.l	#0,d0
	jsr	Reallocate_memory
	tst.b	d0
	bne.w	.Exit
	move.w	d1,d0
.Skip:
	jsr	Get_file_path_by_index
	move.b	(a0)+,Current_disk_index_for_file_loading		; First byte is the disk index (0 if load from folder)
	move.l	a0,Current_filename
	move.l	a0,6(a5)
	move.w	0(a5),d0
	jsr	Set_current_file_compression_space
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	move.l	6(a5),a0
	jsr	Get_file_size
	move.l	d0,2(a5)		; Store file size
	move.l	6(a5),d1
	move.l	#1005,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.w	.Skip9
	move.l	d0,10(a5)
	move.l	d0,Current_open_file_handle
	lea.l	File_header_when_loading,a4
	move.l	d0,d1
	move.l	a4,d2
	moveq.l	#12,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip9
	cmp.l	d0,d3
	beq.s	.Skip2
.Loop:
	move.w	#500,Dos_IO_error_code		; Set error code for
					; "not read enough data"
	bra.w	.Skip10
.Skip2:
	cmpi.w	#19016,(a4)		; Check for JH header
	bne.s	.Skip3
	addq.l	#2,a4
	move.w	(a4)+,d0		; Read JH key
	eori.w	#$4a48,d0		; XOR key with "JH"
	moveq.l	#8,d7		; Decrypt the next 8 bytes
	move.l	a4,a0		; Store pointer to file data in A0
	jsr	Crypt_block
	move.w	d0,20(a5)		; Store current encrypt key for
					; later (following data).
	bset.b	#0,19(a5)		; Mark as JH encoded
.Skip3:
	cmpi.l	#21778242,(a4)		; Check for 1"LOB" header
	beq.w	.Skip4
	move.l	2(a5),d0		; No LOB, get file size
	btst.b	#0,19(a5)		; Is JH encoded?
	beq.s	.Skip5
	subq.l	#4,d0		; If so, reduce filesize by JH header size
	bra.s	.Skip5
.Skip4:
	move.l	4(a4),d0		; Compressed size
	andi.l	#$ffffff,d0		; Limit to 24bit size
	move.l	d0,d6		; Save it as D6
	add.l	Current_file_compression_space,d0		; Add room for compression data
	bset.b	#1,19(a5)		; Mark as LOB compressed
.Skip5:
	move.w	0(a5),d1		; File index
	moveq.l	#0,d2
	jsr	File_allocate
	move.b	d0,18(a5)
	jsr	Claim_pointer
	move.l	d0,14(a5)
	move.l	d0,a0
	btst.b	#0,19(a5)
	bne.s	.Skip6
	move.l	(a4)+,(a0)+
.Skip6:
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	10(a5),d1
	move.l	a0,d2
	move.l	2(a5),d3
	subi.l	#12,d3
	beq.w	.Skip8
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0		; Error?
	beq.w	.Skip9
	cmp.l	d0,d3		; Read Size == Requested Size?
	bne.w	.Loop
	btst.b	#0,19(a5)
	beq.s	.Skip7
	move.w	20(a5),d0
	move.l	2(a5),d7
	subi.l	#12,d7
	move.l	14(a5),a0
	addq.l	#8,a0
	jsr	Crypt_block
.Skip7:
	btst.b	#1,19(a5)
	beq.s	.Skip8
	move.l	14(a5),a0
	jsr	Decompress
	move.b	18(a5),d0
	move.l	d6,d1
	jsr	Shrink_memory
.Skip8:
	jsr	Close_current_file
	move.b	18(a5),d0
	jsr	Free_pointer
	jsr	Pop_Mptr
.Exit:
	lea.l	22(sp),sp
	jsr	Own_blitter
	movem.l	(sp)+,d1-d7/a0-a6
	rts
.Skip9:
	jsr	Get_dos_IO_error		; Load error handling
.Skip10:
	jsr	Close_current_file
	move.b	18(a5),d0
	beq.s	.Skip11
	jsr	Free_pointer
	jsr	Free_memory
.Skip11:
	move.w	0(a5),d0
	jsr	Pop_Mptr
	lea.l	22(sp),sp
	jsr	Own_blitter
	movem.l	(sp)+,d1-d7/a0-a6
	jsr	Handle_disk_error
	bra.w	Load_file

;*****************************************************************************
; [ Save a file ]
;   IN : d0 - File number (.w)
;        a0 - Pointer to data (.l)
;        d1 - Length (.l)
;*****************************************************************************
Save_file:
	movem.l	d0-d3/a0/a1/a5,-(sp)
	jsr	Free_blitter_usage
	move.l	a0,-(sp)
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	move.l	(sp)+,a0
	lea.l	-22(sp),sp
	move.l	sp,a5
	move.l	d0,2(a5)
	move.w	d1,(a5)
	move.l	a0,14(a5)
	clr.l	10(a5)
	tst.w	d1
	bne.s	.Skip
	moveq.l	#0,d0
	move.l	a1,a0
	bra.s	.Skip2
.Skip:
	move.w	d1,d0
.Skip2:
	jsr	Get_file_path_by_index
	move.b	(a0)+,Current_disk_index_for_file_loading
	move.l	a0,Current_filename
	move.l	a0,6(a5)
	move.l	a0,d1
	move.l	#1006,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.w	.Skip4
	move.l	d0,10(a5)
	move.l	d0,Current_open_file_handle
	move.l	d0,d1
	move.l	14(a5),d2
	move.l	2(a5),d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOWrite(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip4
	cmp.l	d0,d3
	beq.s	.Skip3
	move.w	#501,Dos_IO_error_code
	bra.w	.Skip5
.Skip3:
	jsr	Close_current_file
	lea.l	22(sp),sp
	jsr	Pop_Mptr
	jsr	Own_blitter
	movem.l	(sp)+,d0-d3/a0/a1/a5
	rts
.Skip4:
	jsr	Get_dos_IO_error
.Skip5:
	jsr	Close_current_file
	lea.l	22(sp),sp
	jsr	Pop_Mptr
	jsr	Own_blitter
	movem.l	(sp)+,d0-d3/a0/a1/a5
	jsr	Handle_disk_error
	bra.w	Save_file

;*****************************************************************************
; [ Save an encrypted file ]
;   IN : d0 - File number (.w)
;        a0 - Pointer to data (.l)
;        d1 - Length (.l)
;*****************************************************************************
Save_encrypted_file:
	movem.l	d0-d3/d7/a0/a1/a4/a5,-(sp)
	jsr	Free_blitter_usage
	move.l	a0,-(sp)
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	move.l	(sp)+,a0
	lea.l	-22(sp),sp
	move.l	sp,a5
	move.l	d0,2(a5)
	move.w	d1,(a5)
	move.l	a0,14(a5)
	clr.l	10(a5)
	tst.w	d1
	bne.s	.Skip
	moveq.l	#0,d0
	move.l	a1,a0
	bra.s	.Skip2
.Skip:
	move.w	d1,d0
.Skip2:
	jsr	Get_file_path_by_index
	move.b	(a0)+,Current_disk_index_for_file_loading
	move.l	a0,Current_filename
	move.l	a0,6(a5)
	move.l	a0,d1
	move.l	#1006,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.w	.Skip4
	move.l	d0,10(a5)
	move.l	d0,Current_open_file_handle
	lea.l	File_header_when_loading,a4
	move.w	#19016,(a4)
	jsr	Random
	move.w	d0,20(a5)
	eori.w	#$4a48,d0
	move.w	d0,2(a4)
	move.l	10(a5),d1
	move.l	a4,d2
	moveq.l	#4,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOWrite(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip4
	cmp.l	d0,d3
	beq.s	.Skip3
.Loop:
	move.w	#501,Dos_IO_error_code
	bra.w	.Skip5
.Skip3:
	move.w	20(a5),d0
	move.l	2(a5),d7
	move.l	14(a5),a0
	jsr	Crypt_block
	bset.b	#0,19(a5)
	move.l	10(a5),d1
	move.l	a0,d2
	move.l	d7,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOWrite(a6)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip4
	cmp.l	d0,d3
	bne.s	.Loop
	jsr	Close_current_file
	move.w	20(a5),d0
	move.l	2(a5),d7
	move.l	14(a5),a0
	jsr	Crypt_block
	lea.l	22(sp),sp
	jsr	Pop_Mptr
	jsr	Own_blitter
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4/a5
	rts
.Skip4:
	jsr	Get_dos_IO_error
.Skip5:
	jsr	Close_current_file
	lea.l	22(sp),sp
	jsr	Pop_Mptr
	jsr	Own_blitter
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4/a5
	jsr	Handle_disk_error
	bra.w	Save_encrypted_file

;*****************************************************************************
; [ Save a subfile ]
;   IN : d0 - Subfile number (.w)
;        d1 - File number (.w)
;        a0 - Pointer to data (.l)
;*****************************************************************************
Save_subfile:
	movem.l	d0-d7/a0/a5,-(sp)
	jsr	Free_blitter_usage
	lea.l	-28(sp),sp
	move.l	sp,a5
	move.w	d0,12(a5)
	move.w	d1,10(a5)
	move.l	a0,24(a5)
	cmpi.w	#49,d1
	bpl.w	.Exit
	tst.w	d0		; 0 is invalid as file index
	ble.w	.Exit
	cmp.w	#530,d0		; 530 = max file index
	bgt.w	.Exit
	lea.l	Default_Mptr+2000,a0
	jsr	Push_Mptr
	jsr	Load_subfile_sizes
	move.w	12(a5),d1
	cmp.w	4(a5),d1
	ble.s	.Skip2
.Loop:
	jsr	Close_file
	bra.w	.Skip5
.Skip2:
	cmpi.l	#1095582290,(a5)
	bne.s	.Loop
	lea.l	Sub_file_sizes,a0
	moveq.l	#0,d0
	move.w	12(a5),d1
	subq.w	#1,d1
	bra.s	.Skip3
.Loop2:
	add.l	(a0)+,d0
.Skip3:
	dbra	d1,.Loop2
	move.l	d0,14(a5)
	tst.l	(a0)
	beq.s	.Skip4
	move.l	(a0),18(a5)
	jsr	Write_file_data
.Skip4:
	jsr	Close_file
.Skip5:
	jsr	Pop_Mptr
.Exit:
	lea.l	28(sp),sp
	jsr	Own_blitter
	movem.l	(sp)+,d0-d7/a0/a5
	rts

;*****************************************************************************
; [ Write data to the current file ]
;   IN : a5 - Pointer to file request (.l)
; NOTE :
;   - Writes in chunks until everything is written (fix for PFS etc.).
;*****************************************************************************
Write_file_data:
	movem.l	d0-d3/a0/a1,-(sp)
	move.l	6(a5),d1
	move.l	14(a5),d2
	moveq.l	#0,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bmi.w	.Skip
	move.l	6(a5),d1		; File handle
	move.l	24(a5),d2		; Buffer
	move.l	18(a5),d3		; Length
.WriteMore:
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOWrite(a6)		; Write(file=D1, buffer=D2, length=D3)
	move.l	(sp)+,a6
	cmp.l	#-1,d0
	beq.w	.Skip
	; Fix save crash on PFS etc
	add.l	d0,d2
	sub.l	d0,d3
	bgt.s	.WriteMore
	movem.l	(sp)+,d0-d3/a0/a1
	rts
.Skip:
	jsr	Get_dos_IO_error
	jsr	Handle_disk_error
	move.l	6(a5),d1
	moveq.l	#0,d2
	move.w	4(a5),d2
	lsl.w	#2,d2
	addq.l	#6,d2
	moveq.l	#-1,d3
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	movem.l	(sp)+,d0-d3/a0/a1
	bra.w	Write_file_data

;*****************************************************************************
; [ Get the last AmigaDOS error (IoErr) ]
;  OUT : Dos_IO_error_code
;*****************************************************************************
Get_dos_IO_error:
	movem.l	d0/d1/a0/a1,-(sp)
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOIoErr(a6)		; IoErr
	move.l	(sp)+,a6
	move.w	d0,Dos_IO_error_code
	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Show the current disk error ]
; All registers are restored
;*****************************************************************************
Handle_disk_error:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Own_blitter
	move.w	Dos_IO_error_code,d0
	cmp.w	#218,d0
	bne.s	.Skip
	moveq.l	#0,d0
	move.b	Current_disk_index_for_file_loading,d0
	jsr	Disk_requester
	bra.s	.Exit
.Skip:
	jsr	Disk_error_handler
.Exit:
	jsr	Free_blitter_usage
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Load a subfile from a container file (AMBR, AMPC, AMNC, AMNP) ]
;*****************************************************************************
Load_subfile_from_archive:
	movem.l	d7/a0,-(sp)
	lea.l	Archive_loading_routines,a0
	move.l	(a5),d0		; The first 6 bytes of A5
					; contain the file header.
					; So D0 now is the magic
					; string like "AMNP" etc.
	moveq.l	#3,d7		; 4 possible loading routines
.Loop:
	cmp.l	(a0),d0
	bne.s	.Skip
	move.l	4(a0),a0		; If match, load the file
	jsr	(a0)
	bra.s	.Exit
.Skip:
	addq.l	#8,a0		; Go to next loading routine/header
	dbra	d7,.Loop
.Exit:
	movem.l	(sp)+,d7/a0
	rts

; Container types and their loading routines
Archive_loading_routines:
	dc.b	"AMBR"

Archive_loading_functions:
	dc.l	Load_AMBR

Compressed_archive_loading_routines:
	dc.b	"AMPC"
	dc.l	Load_AMPC
	dc.b	"AMNC"
	dc.l	Load_AMNC
	dc.b	"AMNP"
	dc.l	Load_AMNP

;*****************************************************************************
; [ Get the size of a file / subfile ]
; NOTE (disassembly) :
;   A0: Filename
;*****************************************************************************
Get_file_size:
	movem.l	d1/d2/d6/d7/a0/a1/a5,-(sp)
	moveq.l	#0,d6
	move.l	a0,d1
	moveq.l	#-2,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOLock(a6)		; dos.Lock
	move.l	(sp)+,a6
	tst.l	d0
	beq.w	.Skip
	move.l	d0,d6
	move.l	#File_info_block,d0
	addq.l	#7,d0
	andi.l	#-$8,d0
	move.l	d0,a5
	move.l	d6,d1
	move.l	a5,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOExamine(a6)		; dos.Examine
	move.l	(sp)+,a6
	tst.l	d0
	beq.w	.Skip
	move.l	124(a5),d7		; Store file size in D7
	move.l	d6,d1
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOUnLock(a6)		; dos.Unlock
	move.l	(sp)+,a6
	move.l	d7,d0		; Return file size as D0
	movem.l	(sp)+,d1/d2/d6/d7/a0/a1/a5
	rts
.Skip:
	jsr	Get_dos_IO_error
	tst.l	d6
	beq.s	.Skip2
	move.l	d6,d1
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOUnLock(a6)		; dos.Unlock
	move.l	(sp)+,a6
.Skip2:
	jsr	Handle_disk_error
	movem.l	(sp)+,d1/d2/d6/d7/a0/a1/a5
	bra.w	Get_file_size

;*****************************************************************************
; [ Set the extra space needed to decompress the current file ]
;*****************************************************************************
Set_current_file_compression_space:
	movem.l	d0/a0,-(sp)
	tst.w	d0
	bne.s	.Skip
	move.l	#1024,d0		; Default to 0x400 if index is 0
	bra.s	.Exit
.Skip:
	jsr	Get_file_cmp_space		; Otherwise read from file info list
.Exit:
	move.l	d0,Current_file_compression_space
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Decompress data ]
;   IN : a0 - Pointer to packed data (.l)
;*****************************************************************************
Decompress:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Current_file_compression_space,d0
	jsr	Decompress_block
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Decompress a data block in place ]
;   IN : d0 - Size (.l)
;        a0 - Pointer to data (.l)
;  OUT : d0 - Decompressed size (.l)
;        a0 - Pointer to data (.l)
;*****************************************************************************
Decompress_block:
	lea.l	Decompress_entry(pc),a2
	move.l	a0,2(a2)
	move.l	d0,14(a2)
	move.l	a0,a1
	jsr	(a2)
	lea.l	Decompress_entry(pc),a2
	move.l	2(a2),a0
	move.l	6(a2),d0
	rts

;*****************************************************************************
; [ Decompress_entry ]
;*****************************************************************************
Decompress_entry:
	bra.s	Do_decompress

Decompress_target:
	dc.l	0

Decompress_chunk_size:
	dc.l	0

Decompress_chunk_count:
	dc.l	0

Decompress_offset:
	dc.l	$6400

Decompress_extra_table:
	dc.b	0,0,0,0,8,0,$3c,0,$3c,0,0,0,0,0,3,0
	dc.b	0,0,0,0

;*****************************************************************************
; [ Decompressor main loop ]
;   IN : a1 - Pointer to compressed data (.l)
;*****************************************************************************
Do_decompress:
	lea.l	Decompress_chunk_count(pc),a0
	move.l	(a1)+,(a0)
.Loop:
	beq.s	.Exit
	moveq.l	#0,d0
	move.b	(a1),d0
	add.w	d0,d0
	move.w	Decompress_extra_table(pc,d0.w),d0
	bsr.s	Decompress_chunk
	move.l	Decompress_target(pc),a1
	lea.l	Decompress_chunk_count(pc),a0
	subq.b	#1,(a0)
	bra.s	.Loop
.Exit:
	rts

;*****************************************************************************
; [ Decompress one chunk ]
;   IN : d0 - Extra space (.l)
;        a1 - Pointer to chunk (.l)
;*****************************************************************************
Decompress_chunk:
	lea.l	Decompress_chunk_size(pc),a0
	move.l	(a1),d1
	andi.l	#$ffffff,d1
	move.l	d1,(a0)
	move.l	4(a1),d2
	addq.l	#8,d2
	add.l	d0,d2
	move.l	Decompress_target(pc),a0
	add.l	Decompress_offset(pc),a0
	add.l	d1,a0
	add.l	d2,a1
.Loop:
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	subq.l	#8,d2
	bpl.s	.Loop
	sub.l	d2,a0
	move.l	Decompress_target(pc),a1
	cmpi.b	#6,(a0)
	bne.w	.Exit
	move.l	(a0)+,d0
	andi.l	#$ffffff,d0
	add.l	a1,d0
	addq.l	#4,a0
	move.l	#128,d1
.Loop2:
	add.b	d1,d1
	bne.s	.Skip
	move.b	(a0)+,d1
	addx.b	d1,d1
.Skip:
	bcc.s	.Skip2
	move.b	(a0)+,(a1)+
	cmp.l	d0,a1
	blt.s	.Loop2
	rts
.Skip2:
	moveq.l	#0,d3
	move.b	(a0)+,d3
	move.b	d3,d2
	andi.w	#$f,d2
	lsl.w	#4,d3
	move.b	(a0)+,d3
	move.l	a1,a2
	sub.l	d3,a2
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
.Loop3:
	move.b	(a2)+,(a1)+
	dbra	d2,.Loop3
	cmp.l	d0,a1
	blt.s	.Loop2
	rts
.Exit:
	rts

;*****************************************************************************
; [ Close the current file ]
; All registers are restored
;*****************************************************************************
Close_current_file:
	movem.l	d0/d1/a0/a1,-(sp)
	move.l	Current_open_file_handle,d1
	beq.s	.Exit
	tst.b	Blitter_is_not_owned
	bne.s	.Skip
	jsr	Free_blitter_usage
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOClose(a6)
	move.l	(sp)+,a6
	clr.l	Current_open_file_handle
	jsr	Own_blitter
	bra.s	.Exit
.Skip:
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOClose(a6)
	move.l	(sp)+,a6
	clr.l	Current_open_file_handle
.Exit:
	movem.l	(sp)+,d0/d1/a0/a1
	rts


	SECTION	Fast_BSS,bss
	ds.b	4
	ds.l	2
	ds.b	9040
	ds.l	1
	ds.b	2928
Current_file_compression_space:
	ds.l	1
Sub_file_sizes:
	ds.b	2120
Temp_index_buffer:
	ds.b	128
Dos_IO_error_code:
	ds.w	1
Current_filename:
	ds.l	1
Current_open_file_handle:
	ds.l	1
File_info_block:
	ds.b	268
File_header_when_loading:
	ds.b	12
Current_disk_index_for_file_loading:
	ds.b	1
Blitter_is_not_owned:
	ds.b	1
Batch_loading_flag:
	ds.b	2
