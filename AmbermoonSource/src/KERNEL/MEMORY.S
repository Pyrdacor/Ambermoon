; Memory manager (memory areas, blocks & handles)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Remove all unclaimed memory blocks ]
; All registers are restored
;*****************************************************************************
Kill_unclaimed_memory:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	File_info_pointers,a1
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2
.Loop:
	move.l	a1,a0
.Loop2:
	move.l	12(a0),d0
	beq.s	.Skip
	move.l	d0,a0
	tst.l	20(a0)
	beq.s	.Loop2
	tst.b	19(a0)
	bne.s	.Loop2
	jsr	Free_handle
	clr.b	17(a0)
	clr.l	20(a0)
	jsr	Merge_free_blocks
	bra.s	.Loop2
.Skip:
	lea.l	18(a1),a1
.Skip2:
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Invalidate a memory block (it will be removed when it is freed) ]
;   IN : d0 - Memory handle (.b)
; All registers are restored
;*****************************************************************************
Invalidate_memory:
	move.l	a0,-(sp)
	andi.w	#$ff,d0
	cmp.w	#200,d0
	bpl.s	.Exit
	jsr	Check_handle
	bne.s	.Exit
	bset.b	#1,17(a0)
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Get the length of a memory block ]
;   IN : d0 - Memory handle (.b)
;  OUT : d0 - Length (.l)
;*****************************************************************************
Get_memory_length:
	movem.l	d1/a0,-(sp)
	andi.w	#$ff,d0
	cmp.w	#200,d0
	bpl.s	.Exit
	jsr	Check_handle
	bne.s	.Exit
	move.l	4(a0),d0
	moveq.l	#0,d1
	move.b	17(a0),d1
	andi.w	#$f0,d1
	lsr.w	#4,d1
	sub.w	d1,d0
.Exit:
	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Clear the claims of all memory blocks ]
; All registers are restored
;*****************************************************************************
Clear_all_claims:
	movem.l	d1/d7/a0/a1,-(sp)
	lea.l	File_info_pointers,a1
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2
.Loop:
	move.l	a1,a0
.Loop2:
	move.l	12(a0),d1
	beq.s	.Skip
	move.l	d1,a0
	clr.b	19(a0)
	bra.s	.Loop2
.Skip:
	lea.l	18(a1),a1
.Skip2:
	dbra	d7,.Loop
	movem.l	(sp)+,d1/d7/a0/a1
	rts

;*****************************************************************************
; [ Get a memory block for a (sub)file which may already be in memory ]
;   IN : d0 - Subfile number (.w)
;        d1 - File number (.b)
;  OUT : d0 - Memory handle / 0 (.b)
;*****************************************************************************
Reallocate_memory:
	move.l	a0,-(sp)
	jsr	Handle_file_priorities
	jsr	Get_sub_file_by_id
	move.l	a0,d0
	beq.w	.Exit
	jsr	Update_file_mem_prio
	btst.b	#0,17(a0)
	beq.s	.Skip
	move.b	18(a0),d0
	bra.w	.Exit
.Skip:
	jsr	Claim_block
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Get a memory block for a file which may already be in memory ]
;*****************************************************************************
Duplicate_or_load_block:
	movem.l	d1/d2/a0-a2,-(sp)
	jsr	Handle_file_priorities
	jsr	Get_sub_file_by_id
	move.l	a0,d0
	beq.s	.Exit
	btst.b	#0,17(a0)
	beq.s	.Skip
	move.l	a0,a2
	move.l	4(a2),d0
	move.l	d0,-(sp)
	moveq.l	#0,d1
	move.b	20(a2),d1
	move.w	22(a2),d2
	jsr	File_allocate
	move.b	d0,d1
	jsr	Claim_pointer
	move.l	d0,a1
	move.l	(a2),a0
	move.l	(sp)+,d0
	jsr	Copy_memory
	move.b	d1,d0
	jsr	Free_pointer
	bra.s	.Exit
.Skip:
	jsr	Update_file_mem_prio
	jsr	Claim_block
.Exit:
	movem.l	(sp)+,d1/d2/a0-a2
	rts

;*****************************************************************************
; [ Claim a memory block ]
;   IN : a0 - Pointer to memory block descriptor (.l)
;*****************************************************************************
Claim_block:
	movem.l	d1/d2/d7/a0-a2,-(sp)
	bset.b	#0,17(a0)
	jsr	Allocate_handle
	lea.l	File_info_pointers,a1
	moveq.l	#0,d2
	move.b	16(a0),d2
	mulu.w	#18,d2
	add.w	d2,a1
	cmpi.b	#1,17(a1)
	bne.w	.Exit
	jsr	File_get_mem_type
	cmp.b	#1,d1
	bne.w	.Exit
	move.b	d0,d7
	move.l	a0,a2
	move.l	4(a2),d0
	moveq.l	#0,d1
	move.b	20(a2),d1
	move.w	22(a2),d2
	jsr	File_allocate
	move.b	d0,d1
	jsr	Claim_pointer
	move.l	d0,a1
	move.b	d7,d0
	jsr	Check_handle
	move.l	a0,a2
	move.l	(a2),a0
	move.l	4(a2),d0
	jsr	Copy_memory
	move.l	a2,a0
	jsr	Free_handle
	clr.b	17(a0)
	clr.l	20(a0)
	jsr	Merge_free_blocks
	move.b	d1,d0
	jsr	Free_pointer
.Exit:
	movem.l	(sp)+,d1/d2/d7/a0-a2
	rts

;*****************************************************************************
; [ Find the memory block of a (sub)file ]
;   IN : d0 - Subfile number (.w)
;        d1 - File number (.b)
;  OUT : a0 - Pointer to memory block descriptor / 0 (.l)
; NOTE (disassembly) :
;   D0 = Id?
;   D1 = Type? Prio? Disk?
;*****************************************************************************
Get_sub_file_by_id:
	movem.l	d0-d2/d7/a1,-(sp)
	lsl.w	#8,d1
	swap	d0
	move.w	d1,d0
	swap	d0
	move.l	#-16711681,d1
	lea.l	File_info_pointers,a1
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2		; Iterate over all files
.Loop:
	move.l	a1,a0
.Loop2:
	move.l	12(a0),d2		; Iterate over all sub-files
	beq.s	.Skip
	move.l	d2,a0		; A0 are the sub-file infos
	move.l	20(a0),d2
	beq.s	.Loop2
	and.l	d1,d2
	cmp.l	d0,d2		; Check if (0x14,A0) & 0xFF00FFFF
					; matches 0xTT00IIII where TT is the
					; type given by D1 and IIII is the
					; index given by D0.
	bne.s	.Loop2
	btst.b	#1,17(a0)		; If this bit is set, ignore sub-file#
	beq.s	.Exit		; All ok, A0=found ptr
	bra.s	.Loop2
.Skip:
	lea.l	18(a1),a1		; A1 are the file infos
.Skip2:
	dbra	d7,.Loop
	sub.l	a0,a0		; Not found, A0=0
.Exit:
	movem.l	(sp)+,d0-d2/d7/a1
	rts

;*****************************************************************************
; [ Shrink a memory block ]
;   IN : d0 - Memory handle (.b)
;        d1 - New length (.l)
; All registers are restored
;*****************************************************************************
Shrink_memory:
	movem.l	d0/d1/a0,-(sp)
	jsr	Handle_file_priorities
	jsr	Check_handle
	bne.s	.Exit
	addq.l	#1,d1
	andi.b	#-$2,d1
	cmp.l	4(a0),d1
	bpl.s	.Exit
	move.l	d1,d0
	jsr	Append_sub_file
	move.l	12(a0),a0
	jsr	Merge_free_blocks
.Exit:
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Free a memory block ]
;   IN : d0 - Memory handle (.b)
; All registers are restored
; NOTE :
;   - File data is kept in memory as long as possible.
;*****************************************************************************
Free_memory:
	movem.l	d0/a0/a1,-(sp)
	jsr	Handle_file_priorities
	jsr	Check_handle
	bne.s	.Exit
	btst.b	#0,17(a0)		; Is this the "in-use" marker?
					; If this is 0, it skips the
					; logic here.
	beq.s	.Exit
	tst.b	19(a0)
	bne.s	.Exit
	btst.b	#1,17(a0)
	bne.s	.Skip
	tst.b	20(a0)		; Check file index
	bne.s	.Skip2
.Skip:
	jsr	Kill_memory		; File index is 0
	bra.s	.Exit
.Skip2:
	jsr	Free_handle		; File index is not 0
	bclr.b	#0,17(a0)		; Set to "not used"
.Exit:
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Free and remove a memory block ]
;   IN : d0 - Memory handle (.b)
; All registers are restored
;*****************************************************************************
Kill_memory:
	move.l	a0,-(sp)
	jsr	Handle_file_priorities
	jsr	Check_handle
	bne.s	.Exit
	tst.b	19(a0)
	beq.s	.Skip
	bset.b	#1,17(a0)
	bra.s	.Exit
.Skip:
	jsr	Free_handle
	clr.b	17(a0)
	clr.l	20(a0)
	jsr	Merge_free_blocks
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Clear a memory block (fill with zeroes) ]
;   IN : d0 - Memory handle (.b)
; All registers are restored
; NOTE (disassembly) :
;   Attaches memory to a free file
;   slot, initializes the memory with
;   0 and returns the handle as D0.
;   Basically this is like FUN_ReadFile
;   but uses user-allocated memory instead
;   of loaded file data. You still have to
;   call FUN_ReleaseOpenedFile at the end!
;*****************************************************************************
Clear_memory:
	movem.l	d0/d1/a0,-(sp)
	jsr	Check_handle
	bne.s	.Exit
	move.l	4(a0),d0		; Memory size
	moveq.l	#0,d1		; Clear memory with zeros
	move.l	(a0),a0		; Memory pointer
	jsr	Fill_memory
.Exit:
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Allocate CHIP memory ]
;   IN : d0 - Size in bytes (.l)
;  OUT : d0 - Memory handle (.b)
;*****************************************************************************
Allocate_CHIP:
	move.l	d1,-(sp)
	move.b	#1,d1		; Mem type CHIP
	jsr	Alloc_file_data_memory
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Allocate FAST memory ]
;   IN : d0 - Size in bytes (.l)
;  OUT : d0 - Memory handle (.b)
;*****************************************************************************
Allocate_FAST:
	move.l	d1,-(sp)
	move.b	#2,d1		; Mem type FAST
	jsr	Alloc_file_data_memory
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Allocate memory (CHIP or FAST) ]
;   IN : d0 - Size in bytes (.l)
;  OUT : d0 - Memory handle (.b)
;*****************************************************************************
Allocate_memory:
	move.l	d1,-(sp)
	move.b	#3,d1		; Mem type CHIP/FAST
	jsr	Alloc_file_data_memory
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Allocate memory for a file ]
;   IN : d0 - Size in bytes (.l)
;        d1 - File number (.b)
;        d2 - Subfile number (.w)
;  OUT : d0 - Memory handle (.b)
;*****************************************************************************
File_allocate:
	movem.l	d1/a0,-(sp)
	move.w	d1,-(sp)
	tst.b	d1
	bne.s	.Skip
	move.b	Default_file_mem_type,d1		; If no valid file index, default
					; the mem type to CHIP/FAST.
	jsr	Alloc_file_data_memory
	bra.s	.Skip2
.Skip:
	jsr	File_get_mem_type		; Otherwise get mem type from
					; file info list.
	jsr	Alloc_file_data_memory
.Skip2:
	move.w	(sp)+,d1
	jsr	Check_handle
	move.b	d1,20(a0)
	move.w	d2,22(a0)
	jsr	Update_file_mem_prio
	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Allocate a memory block ]
;   IN : d0 - Size in bytes (.l)
;        d1 - Memory type (1 = CHIP, 2 = FAST, 3 = any) (.b)
;  OUT : d0 - Memory handle (.b)
; NOTE :
;   - Tries the allocation strategies one after the other until one succeeds.
;   - Exits the program if no memory is available.
;*****************************************************************************
Alloc_file_data_memory:
	movem.l	d1/d7/a0/a1,-(sp)		; D0 is the size in bytes
	jsr	Handle_file_priorities
	sf	Memory_moved_flag
	sf	Restart_music
	move.l	d0,File_memory_pointers
	addq.l	#3,d0		; To next long boundary
	andi.b	#-$4,d0		; Ensure full longs
	tst.l	d0		; If size is 0, set it to 4.
	bne.s	.Skip
	moveq.l	#4,d0
.Skip:
	move.l	d0,d7		; Store alloc size in D7
	lea.l	Allocation_strategies,a1		; Loop through a list of functions,
					; check if the function returns true
					; and if so you're done. Otherwise
					; proceed with next function. If no
					; function returns true, raise error.
.Loop:
	tst.l	(a1)
	beq.s	.Skip2
	move.l	(a1)+,a0
	move.l	d7,d0
	jsr	(a0)
	tst.b	d0		; Handled flag? Each function is
					; some kind of allocation and if
					; none is able to alloc, raise
					; error?
	bne.w	.Skip3
	bra.s	.Loop
.Skip2:
	sf	Restart_music		; If no function handles it
					; an error is raised.
	jmp	Out_of_memory
.Skip3:
	tst.b	Memory_moved_flag
	beq.s	.Skip4
	sf	Memory_moved_flag
	jsr	Rebuild_handle_table
.Skip4:
	tst.b	Restart_music
	beq.s	.Exit
	sf	Restart_music
	move.l	d0,-(sp)
	st	Music_flag		; Set last song to 0xff.
	moveq.l	#-1,d0
	jsr	Set_music		; Play last song.
	move.l	(sp)+,d0
.Exit:
	movem.l	(sp)+,d1/d7/a0/a1
	rts

; Allocation strategies (tried in this order)
Allocation_strategies:
	dc.l	Alloc_strategy1

Allocation_strategies2:
	dc.l	Alloc_strategy2,Alloc_strategy3,Copy_memory_blocks,Alloc_strategy4
	dc.l	Alloc_strategy5,Alloc_strategy6,Alloc_strategy7,Alloc_strategy8
	dc.l	Alloc_strategy9,0

;*****************************************************************************
; [ Allocation strategy 1 : Use CHIP memory if no FAST memory is available ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
; NOTE (disassembly) :
;   This changes the memory type
;   from 2 (FAST) to 1 (MEM) if
;   no FAST memory was allocated.
;*****************************************************************************
Alloc_strategy1:
	moveq.l	#0,d0
	cmpi.b	#2,d1
	bne.s	.Exit
	tst.l	Allocated_fast_memory_size
	bne.s	.Exit
	move.b	#1,d1
.Exit:
	rts

;*****************************************************************************
; [ Allocation strategy 2 : Find a free block in the memory areas ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
; NOTE (disassembly) :
;   This tries to find a valid memory
;   block for the file. It only considers
;   those with the right mem type given
;   as D1.
;*****************************************************************************
Alloc_strategy2:
	movem.l	d1-d7/a0-a6,-(sp)
	lea.l	File_info_pointers,a1
	moveq.l	#0,d2
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2		; Iterate over all allocated
					; memory blocks.
.Loop:
	move.b	17(a1),d3		; Check chain index
					; 0: CHIP mem
					; 1: FAST mem
	btst.l	d3,d1		; D1 is the requested mem type
					; 1: CHIP
					; 2: FAST
	beq.s	.Skip
	move.l	a1,a0		; If mem type matches
	jsr	Get_best_free_file_slot		; This func iterates over the
					; 12 byte file slot infos.
					; While the loop here iterates
					; over a linked list where the next
					; pointer is at offset 18 (0x12).
	cmp.l	#4-4,a0		; If no slot found, skip
	beq.s	.Skip		; Skip null pointers
	cmp.l	4(a0),d2		; Take slot with highest (0x4,A0)
	bpl.s	.Skip
	move.l	4(a0),d2		; Track max value
	move.l	a0,a2		; Use max value pointer
.Skip:
	lea.l	18(a1),a1		; Go to next element
.Skip2:
	dbra	d7,.Loop
	cmp.l	d0,d2
	bpl.s	.Skip3
	moveq.l	#0,d0		; If D0 >= max found (0x4,A0)
					; value, then return false.
	bra.w	.Exit
.Skip3:
	move.l	a2,a0		; Otherwise select it, load
					; the associated file if not
					; already and return true.
	jsr	Ensure_file_loaded
.Exit:
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Allocation strategy 3 : Find a free block after removing file data of the lowest priority ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
;*****************************************************************************
Alloc_strategy3:
	movem.l	d1-d7/a0-a6,-(sp)
	lea.l	Default_Mptr+2700,a0
	jsr	Push_Mptr
	move.l	d0,d4
	lea.l	File_info_pointers,a0
	moveq.l	#0,d2
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2		; Iterate over all allocated memory blocks
.Loop:
	move.b	17(a0),d3
	btst.l	d3,d1
	beq.s	.Skip		; Skip wrong mem types
	jsr	Get_sub_file_chain_total_size
	cmp.l	d0,d2
	bpl.s	.Skip
	move.l	d0,d2		; Store max subfile size
	move.l	a0,a1		; A1 points to largest subfile
.Skip:
	lea.l	18(a0),a0
.Skip2:
	dbra	d7,.Loop
	cmp.l	d4,d2
	bpl.s	.Skip3
	moveq.l	#0,d0
	bra.w	.Exit
.Skip3:
	jsr	Compact_area		; Not enough space for largest
					; subfile? Try alloc for first
					; subfile instead.
	move.l	d4,d0
	jsr	Alloc_strategy2
.Exit:
	jsr	Pop_Mptr
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Move memory blocks to make room ]
;   IN : d7 - Size in bytes (.l)
;*****************************************************************************
Copy_memory_blocks:
	movem.l	d1-d7/a0-a6,-(sp)
	cmp.b	#1,d1
	beq.s	.Skip
.Loop:
	moveq.l	#0,d0
	bra.w	.Exit
.Skip:
	tst.l	Allocated_fast_memory_size
	beq.s	.Loop
	lea.l	Default_Mptr+2700,a0
	jsr	Push_Mptr
	move.l	d0,-(sp)
	move.w	d1,-(sp)
	lea.l	File_info_pointers,a1
	move.w	Allocated_memory_block_count,d7
	bra.w	.Skip5
.Loop2:
	cmpi.b	#0,17(a1)
	bne.w	.Skip4
	move.l	a1,a3
	moveq.l	#0,d6
.Loop3:
	move.l	12(a3),d0
	beq.w	.Skip3
	move.l	d0,a3
	tst.l	20(a3)
	beq.s	.Loop3
	tst.b	19(a3)
	bne.s	.Loop3
	btst.b	#0,17(a3)
	bne.s	.Loop3
	move.b	20(a3),d1
	beq.s	.Loop3
	jsr	File_get_mem_type
	cmp.b	#1,d1
	bne.s	.Loop3
	move.b	18(a3),d5
	move.l	4(a3),d0
	move.b	#2,d1
	jsr	Alloc_strategy2
	tst.b	d0
	bne.s	.Skip2
	move.l	4(a3),d0		; File index
	jsr	Alloc_strategy3
	tst.b	d0
	beq.s	.Loop3
.Skip2:
	jsr	Check_handle
	bne.s	.Loop3
	clr.b	17(a0)
	clr.b	19(a0)
	clr.l	20(a0)
	jsr	Free_handle
	add.l	4(a0),d6
	jsr	Copy_memory_block
	tst.l	20(a0)
	bne.s	.Loop3
	jsr	Merge_free_blocks
	bra.w	.Loop3
.Skip3:
	tst.l	d6
	beq.s	.Skip4
	jsr	Compact_area
.Skip4:
	lea.l	18(a1),a1
.Skip5:
	dbra	d7,.Loop2
	move.w	(sp)+,d1
	move.l	(sp)+,d0
	jsr	Pop_Mptr
	jsr	Alloc_strategy2
.Exit:
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Allocation strategy 4 : Compact the memory areas and find a free block ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
;*****************************************************************************
Alloc_strategy4:
	movem.l	d1-d7/a0-a6,-(sp)
	lea.l	Default_Mptr+2700,a0
	jsr	Push_Mptr
	move.l	d0,d4
	moveq.l	#0,d6
.Loop:
	lea.l	File_info_pointers,a0
	moveq.l	#0,d2
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2
.Loop2:
	move.b	17(a0),d3
	btst.l	d3,d1
	beq.s	.Skip
	jsr	Get_sub_file_chain_total_size
	move.l	d0,d3
	move.b	d6,d0
	jsr	Get_freeable_memory
	add.l	d3,d0
	cmp.l	d0,d2
	bpl.s	.Skip
	move.l	d0,d2
	move.l	a0,a1
.Skip:
	lea.l	18(a0),a0
.Skip2:
	dbra	d7,.Loop2
	cmp.l	d4,d2
	bmi.s	.Skip3
	move.l	a1,a0
	move.b	d6,d0
	jsr	Clear_file_infos
	jsr	Compact_area
	jsr	Get_best_free_file_slot
	cmp.l	4(a0),d4
	bls.s	.Skip4
.Skip3:
	addq.b	#1,d6
	bne.s	.Loop
	moveq.l	#0,d0
	bra.w	.Exit
.Skip4:
	move.l	d4,d0
	jsr	Alloc_strategy2
.Exit:
	jsr	Pop_Mptr
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Allocation strategy 5 : Remove unclaimed memory ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
;*****************************************************************************
Alloc_strategy5:
	moveq.l	#0,d0
	cmpi.b	#2,d1
	bne.s	.Exit
	lea.l	Allocation_strategies,a1
	move.b	#1,d1
.Exit:
	rts

;*****************************************************************************
; [ Allocation strategy 6 : Remove file data and compact ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
;*****************************************************************************
Alloc_strategy6:
	movem.l	d1-d7/a0-a6,-(sp)
	cmp.b	#1,d1
	beq.s	.Skip
.Loop:
	moveq.l	#0,d0
	bra.w	.Exit
.Skip:
	tst.l	Allocated_fast_memory_size
	beq.s	.Loop
	lea.l	Default_Mptr+2700,a0
	jsr	Push_Mptr
	move.l	d0,-(sp)
	move.w	d1,-(sp)
	jsr	Compact_memory
	lea.l	File_info_pointers,a1
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip4
.Loop2:
	cmpi.b	#0,17(a1)
	bne.s	.Skip3
	move.l	a1,a3
	moveq.l	#0,d6
.Loop3:
	move.l	12(a3),d0
	beq.s	.Skip2
	move.l	d0,a3
	tst.l	20(a3)
	beq.s	.Loop3
	tst.b	19(a3)
	bne.s	.Loop3
	move.b	20(a3),d1
	jsr	File_get_mem_type
	cmp.b	#2,d1
	bne.s	.Loop3
	move.l	4(a3),d0
	jsr	Alloc_strategy2
	tst.b	d0
	beq.s	.Loop3
	jsr	Check_handle
	bne.s	.Loop3
	clr.b	17(a0)
	clr.b	19(a0)
	clr.l	20(a0)
	jsr	Free_handle
	add.l	4(a0),d6
	jsr	Copy_memory_block
	tst.l	20(a0)
	bne.s	.Loop3
	jsr	Merge_free_blocks
	bra.s	.Loop3
.Skip2:
	tst.l	d6
	beq.s	.Skip3
	jsr	Compact_area
.Skip3:
	lea.l	18(a1),a1
.Skip4:
	dbra	d7,.Loop2
	move.w	(sp)+,d1
	move.l	(sp)+,d0
	jsr	Pop_Mptr
	jsr	Alloc_strategy2
.Exit:
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Allocation strategy 7 : Remove all unclaimed file data and compact ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
;*****************************************************************************
Alloc_strategy7:
	movem.l	d1-d7/a0-a6,-(sp)
	cmp.b	#1,d1
	beq.s	.Skip
.Loop:
	moveq.l	#0,d0
	bra.w	.Exit
.Skip:
	tst.l	Allocated_fast_memory_size
	beq.s	.Loop
	lea.l	Default_Mptr+2700,a0
	jsr	Push_Mptr
	move.l	d0,-(sp)
	move.w	d1,-(sp)
	lea.l	File_info_pointers,a1
	move.w	Allocated_memory_block_count,d7
	bra.w	.Skip4
.Loop2:
	cmpi.b	#0,17(a1)
	bne.s	.Skip3
	move.l	a1,a3
	moveq.l	#0,d6
.Loop3:
	move.l	12(a3),d0
	beq.s	.Skip2
	move.l	d0,a3
	tst.l	20(a3)
	beq.s	.Loop3
	tst.b	19(a3)
	bne.s	.Loop3
	move.b	20(a3),d1
	jsr	File_get_mem_type
	cmp.b	#3,d1
	bne.s	.Loop3
	move.l	4(a3),d0
	move.b	#2,d1
	jsr	Alloc_strategy2
	tst.b	d0
	beq.s	.Loop3
	jsr	Check_handle
	bne.s	.Loop3
	clr.b	17(a0)
	clr.b	19(a0)
	clr.l	20(a0)
	jsr	Free_handle
	add.l	4(a0),d6
	jsr	Copy_memory_block
	tst.l	20(a0)
	bne.s	.Loop3
	jsr	Merge_free_blocks
	bra.s	.Loop3
.Skip2:
	tst.l	d6
	beq.s	.Skip3
	jsr	Compact_area
.Skip3:
	lea.l	18(a1),a1
.Skip4:
	dbra	d7,.Loop2
	move.w	(sp)+,d1
	move.l	(sp)+,d0
	jsr	Pop_Mptr
	jsr	Alloc_strategy2
.Exit:
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Allocation strategy 8 : Show the "lack of memory" warning ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
;*****************************************************************************
Alloc_strategy8:
	moveq.l	#0,d0
	tst.b	Reload_map_data
	bne.s	.Exit
	jsr	Remove_map_data
	tst.b	Reload_map_data
	beq.s	.Exit
	lea.l	Allocation_strategies,a1
.Exit:
	rts

;*****************************************************************************
; [ Allocation strategy 9 : Out of memory : exit ]
;   IN : d7 - Size in bytes (.l)
;  OUT : eq - Failed
;        ne - Success, a0 = memory block descriptor
;*****************************************************************************
Alloc_strategy9:
	move.l	d2,-(sp)
	move.l	d0,d2
	moveq.l	#0,d0
	tst.l	Allocated_fast_memory_size
	beq.s	.Skip
	cmp.b	#1,d1
	bne.s	.Exit
.Skip:
	tst.b	Music_flag
	beq.s	.Exit
	jsr	Music_off
	jsr	Lack_of_memory_warning
	sf	Restart_music
	jsr	Compact_memory
	move.l	d2,d0
	jsr	Alloc_strategy2
.Exit:
	move.l	(sp)+,d2
	rts

;*****************************************************************************
; [ Move one memory block ]
;   IN : a0 - Pointer to source memory block descriptor (.l)
;        a1 - Pointer to target memory block descriptor (.l)
; NOTE (disassembly) :
;   A3: Source memory block
;   A0: Destination info
;*****************************************************************************
Copy_memory_block:
	movem.l	d0/a0-a2,-(sp)
	lea.l	File_load_routines,a2
	moveq.l	#0,d0
	move.b	20(a3),d0		; File index
	lsl.w	#2,d0		; * 4
	move.l	0(a2,d0.w),d0		; Get data copy routine as D0
	beq.s	.Exit
	move.l	d0,a2		; Move it to A2
	st	Memory_moved_flag
	move.l	a0,-(sp)
	move.l	(a0),a1		; Destination
	move.l	(a3),a0		; Source data
	move.l	4(a3),d0		; Size in bytes
	jsr	(a2)		; Call copy/load data
	move.l	(sp)+,a0
	move.l	20(a3),20(a0)
	move.b	18(a3),18(a0)
	move.b	17(a3),17(a0)
	move.b	21(a3),21(a0)
	move.l	a3,a0
	clr.b	17(a0)
	clr.b	18(a0)
	clr.b	19(a0)
	clr.l	20(a0)
	jsr	Merge_free_blocks
	move.l	a0,a3
.Exit:
	movem.l	(sp)+,d0/a0-a2
	rts

;*****************************************************************************
; [ Compact all memory areas (move blocks together) ]
; All registers are restored
;*****************************************************************************
Compact_memory:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	File_info_pointers,a0
	move.b	#-1,d0
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip
.Loop:
	jsr	Clear_file_infos
	move.l	a0,a1
	jsr	Compact_area
	lea.l	18(a0),a0
.Skip:
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Check if a file is in memory and reload it if necessary ]
;   IN : a0 - Pointer to memory block descriptor (.l)
;*****************************************************************************
Ensure_file_loaded:
	movem.l	d1/a1,-(sp)
	clr.l	20(a0)		; Reset file index to 0 (invalid)
	bset.b	#0,17(a0)
	jsr	Update_file_mem_prio
	cmp.l	4(a0),d0
	beq.s	.Skip
	jsr	Append_sub_file
	move.l	12(a0),a1
	exg	a1,a0
	jsr	Merge_free_blocks
	move.l	a1,a0
.Skip:
	move.l	d0,d1
	sub.l	File_memory_pointers,d1
	andi.w	#$f,d1
	lsl.w	#4,d1
	andi.b	#$f,17(a0)
	or.b	d1,17(a0)
	tst.l	File_memory_pointers
	bne.s	.Exit
	move.l	(a0),a1
	clr.l	(a1)
.Exit:
	jsr	Allocate_handle
	movem.l	(sp)+,d1/a1
	rts

;*****************************************************************************
; [ Compact one memory area ]
;   IN : a1 - Pointer to memory area descriptor (.l)
; All registers are restored
;*****************************************************************************
Compact_area:
	movem.l	d0/a0/a3,-(sp)
	move.l	a1,a3
.Loop:
	move.l	12(a3),d0
	beq.s	.Exit
	move.l	d0,a3
	tst.l	20(a3)
	beq.s	.Skip
	tst.b	19(a3)
	bne.s	.Loop
	jsr	Move_block_down
	bra.s	.Loop
.Skip:
	move.l	a3,a0
	jsr	Merge_free_blocks
	move.l	a0,a3
	bra.s	.Loop
.Exit:
	movem.l	(sp)+,d0/a0/a3
	rts

;*****************************************************************************
; [ Move a memory block into the best free gap below it ]
;   IN : a1 - Pointer to memory area descriptor (.l)
;        a3 - Pointer to memory block descriptor (.l)
;*****************************************************************************
Move_block_down:
	movem.l	d0/a0-a2,-(sp)
	lea.l	File_load_routines,a2
	moveq.l	#0,d0
	move.b	20(a3),d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d0
	beq.w	.Exit
	move.l	d0,a2
	jsr	Find_largest_free_block
	cmp.l	#4-4,a0
	beq.w	.Exit
	st	Memory_moved_flag
	move.l	4(a3),d0
	cmp.l	4(a0),d0
	beq.s	.Skip2
	bmi.s	.Skip
	move.l	8(a3),a0
	cmp.l	#4-4,a0
	beq.w	.Exit
	tst.l	20(a0)
	bne.w	.Exit
	move.l	a0,-(sp)
	move.l	(a0),a1
	move.l	(a3),a0
	jsr	(a2)
	move.l	(sp)+,a0
	move.l	4(a0),4(a3)
	move.l	d0,4(a0)
	add.l	(a0),d0
	move.l	d0,(a3)
	bra.s	.Skip3
.Skip:
	jsr	Append_sub_file
.Skip2:
	move.l	a0,-(sp)
	move.l	(a0),a1
	move.l	(a3),a0
	jsr	(a2)
	move.l	(sp)+,a0
.Skip3:
	move.l	20(a3),20(a0)
	move.b	18(a3),18(a0)
	move.b	17(a3),17(a0)
	move.b	21(a3),21(a0)
	move.l	a3,a0
	clr.b	17(a0)
	clr.b	18(a0)
	clr.b	19(a0)
	clr.l	20(a0)
	jsr	Merge_free_blocks
	move.l	a0,a3
.Exit:
	movem.l	(sp)+,d0/a0-a2
	rts

;*****************************************************************************
; [ Find the largest free block before a given block ]
;   IN : a1 - Pointer to memory area descriptor (.l)
;        a3 - Pointer to memory block descriptor (.l)
;  OUT : a0 - Pointer to free block descriptor / 0 (.l)
;*****************************************************************************
Find_largest_free_block:
	movem.l	d0/a1,-(sp)
	moveq.l	#0,d0
	sub.l	a0,a0
.Loop:
	tst.l	12(a1)
	beq.s	.Exit
	move.l	12(a1),a1
	cmp.l	a3,a1
	beq.s	.Exit
	tst.l	20(a1)
	bne.s	.Loop
	cmp.l	4(a1),d0
	bpl.s	.Loop
	move.l	4(a1),d0
	move.l	a1,a0
	bra.s	.Loop
.Exit:
	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Copy memory (overlapping areas are allowed) ]
;   IN : d0 - Number of bytes (.l)
;        a0 - Source (.l)
;        a1 - Target (.l)
; All registers are restored
; NOTE (disassembly) :
;   A0 = source data
;   A1 = destination
;   D0 = size in bytes
;*****************************************************************************
Copy_memory:
	movem.l	d0-d7/a0-a4,-(sp)
	addq.l	#1,d0		; D0 is the size
	andi.b	#-$2,d0		; To next word boundary
	tst.l	d0
	beq.w	.Exit		; 0 bytes? Return
	cmp.l	a0,a1
	beq.w	.Exit		; Copy to self? Return
	bmi.s	.Skip		; branch if A0 > A1
	lea.l	0(a0,d0.l),a2		; A2 = source data end ptr
	cmp.l	a1,a2		; A0 < A1 (source < dest)
					; compare end ptr with dest
	bgt.s	.Skip4		; branch if A2 > A1
.Skip:
	move.l	d0,d1		; D1 = num bytes
	lsr.l	#5,d1		; D1 = num 32 byte chunks
	beq.s	.Skip2		; Skip if 0 chunks
	moveq.l	#32,d2		; 32 bytes per copy
.Loop:
	movem.l	(a0)+,d3-d7/a2-a4		; Copy 8 * 4 (32) bytes
	movem.l	d3-d7/a2-a4,(a1)
	add.l	d2,a1
	subq.l	#1,d1
	bne.s	.Loop		; Keep going until all are copied
.Skip2:
	andi.w	#$1f,d0		; Rest chunk (0 to 31 bytes).
					; But can only be a multiple
					; of 2, so 0 to 30 bytes.
	lsr.w	#1,d0		; Num bytes to num words
	bra.s	.Skip3
.Loop2:
	move.w	(a0)+,(a1)+		; Move remaining words
.Skip3:
	dbra	d0,.Loop2
	bra.w	.Exit		; Done
.Skip4:
	add.l	d0,a0		; source start < dest < source end
	add.l	d0,a1		; This also copies the data
					; but end to start.
	move.l	d0,d1
	lsr.l	#5,d1
	beq.s	.Skip5
	moveq.l	#32,d2
.Loop3:
	sub.l	d2,a0
	movem.l	(a0),d3-d7/a2-a4
	movem.l	d3-d7/a2-a4,-(a1)
	subq.l	#1,d1
	bne.s	.Loop3
.Skip5:
	andi.w	#$1f,d0
	lsr.w	#1,d0
	bra.s	.Skip6
.Loop4:
	move.w	-(a0),-(a1)
.Skip6:
	dbra	d0,.Loop4
.Exit:
	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Find the best fitting free block in a memory area ]
;   IN : d7 - Size in bytes (.l)
;        a1 - Pointer to memory area descriptor (.l)
;  OUT : a0 - Pointer to memory block descriptor / 0 (.l)
;*****************************************************************************
Get_best_free_file_slot:
	movem.l	d0/a1,-(sp)
	moveq.l	#0,d0
	sub.l	a1,a1
.Loop:
	tst.l	12(a0)
	beq.s	.Exit		; If no more files, use last found free
	move.l	12(a0),a0		; Go to next file slot
	tst.l	20(a0)
	bne.s	.Loop		; If it has a file index, try next
	cmp.l	4(a0),d0
	bpl.s	.Loop
	move.l	4(a0),d0
	move.l	a0,a1		; Only select if (0x4,A0) is bigger
	bra.s	.Loop
.Exit:
	move.l	a1,a0		; Select free slot with highest (0x4,A0)
	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Calculate the total size of all blocks in a memory area ]
;   IN : a0 - Pointer to memory area descriptor (.l)
;  OUT : d0 - Size (.l)
;*****************************************************************************
Get_sub_file_chain_total_size:
	movem.l	d1/a0,-(sp)
	moveq.l	#0,d0
.Loop:
	move.l	12(a0),d1
	beq.s	.Exit
	move.l	d1,a0
	tst.l	20(a0)
	bne.s	.Loop
	add.l	4(a0),d0
	bra.s	.Loop
.Exit:
	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Calculate how much memory could be freed in an area ]
;   IN : d0 - Priority (.b)
;        a0 - Pointer to memory area descriptor (.l)
;  OUT : d0 - Size (.l)
;*****************************************************************************
Get_freeable_memory:
	movem.l	d1/d6/a0,-(sp)
	move.b	d0,d6
	moveq.l	#0,d0
.Loop:
	move.l	12(a0),d1
	beq.s	.Exit
	move.l	d1,a0
	tst.b	20(a0)
	beq.s	.Loop
	btst.b	#0,17(a0)
	bne.s	.Loop
	cmp.b	21(a0),d6
	bcs.s	.Loop
	add.l	4(a0),d0
	bra.s	.Loop
.Exit:
	movem.l	(sp)+,d1/d6/a0
	rts

;*****************************************************************************
; [ Clear the file data of a memory area ]
;   IN : a0 - Pointer to memory area descriptor (.l)
;*****************************************************************************
Clear_file_infos:
	movem.l	d1/a0,-(sp)
.Loop:
	move.l	12(a0),d1
	beq.s	.Exit
	move.l	d1,a0
	tst.b	20(a0)		; Check file index
	beq.s	.Loop
	btst.b	#0,17(a0)		; File index valid, check
					; bit 0 at offset 0x11
					; (maybe in-use flag?)
	bne.s	.Loop
	cmp.b	21(a0),d0		; Check mem prio
	bcs.s	.Loop		; If mem prio is >= D0, proceed
					; and clear. Otherwise skip.
	clr.b	17(a0)		; Clear flags
	clr.b	18(a0)
	clr.b	19(a0)
	clr.l	20(a0)		; Clear file index
	jsr	Merge_free_blocks
	bra.s	.Loop
.Exit:
	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Merge a free block with its free neighbours ]
;   IN : a0 - Pointer to memory block descriptor (.l)
;  OUT : a0 - Pointer to merged block descriptor (.l)
;*****************************************************************************
Merge_free_blocks:
	movem.l	d0/a1/a2,-(sp)
	cmp.l	#4-4,a0
	beq.w	.Exit
	tst.l	20(a0)
	bne.w	.Exit
	tst.l	8(a0)
	beq.w	.Exit
	move.l	8(a0),a2
	tst.l	8(a2)
	beq.w	.Skip
	tst.l	20(a2)
	bne.w	.Skip
	move.l	4(a0),d0
	add.l	d0,4(a2)
	jsr	Remove_block_descriptor
	move.l	a2,a0
.Skip:
	tst.l	12(a0)
	beq.w	.Exit
	move.l	12(a0),a2
	tst.l	20(a2)
	bne.w	.Exit
	move.l	4(a2),d0
	add.l	d0,4(a0)
	move.l	a2,a0
	jsr	Remove_block_descriptor
.Exit:
	movem.l	(sp)+,d0/a1/a2
	rts

;*****************************************************************************
; [ Split a memory block ]
;   IN : d0 - Size of the first part (.l)
;        a0 - Pointer to memory block descriptor (.l)
;*****************************************************************************
Append_sub_file:
	movem.l	d1/a0/a1,-(sp)
	addq.l	#1,d0
	andi.b	#-$2,d0		; To next word boundary
	cmp.l	4(a0),d0
	bpl.s	.Exit
	move.l	a0,a1		; (0x4,A0) was greater than D0
	jsr	Get_next_free_sub_file_slot		; A0 = free slot to use
	jsr	Insert_sub_file		; A1 = file info, A0 = new subfile
	move.l	4(a1),d1
	sub.l	d0,d1
	move.l	d1,4(a0)
	move.l	(a1),d1
	add.l	d0,d1
	move.l	d1,(a0)
	move.l	d0,4(a1)
	move.b	16(a1),16(a0)
.Exit:
	movem.l	(sp)+,d1/a0/a1
	rts

;*****************************************************************************
; [ Decrease the priorities of the file data in memory (ageing) ]
; All registers are restored
;*****************************************************************************
Handle_file_priorities:
	movem.l	d0/d7/a0,-(sp)		; File priority handling?
	addq.l	#1,Total_ticks
	move.w	Tick_counter,d0
	beq.s	.Skip
	subq.w	#1,d0		; Decrement ticks if not 0 already.
	bne.s	.Skip		; If just reaching 0, reset to 10000.
					; Also call some method which
					; clears some byte in all file infos.
	jsr	Init_file_infos
	move.w	#10000,d0		; Set value for counter to 10000
					; again.
.Skip:
	move.w	d0,Tick_counter
	lea.l	Sub_file_pointers,a0
	move.w	#499,d7		; 500 loops, each 24 bytes
.Loop:
	btst.b	#0,17(a0)
	bne.s	.Skip2
	tst.b	20(a0)		; File index
	beq.s	.Skip2
	move.b	21(a0),d0		; Mem prio
	subq.b	#1,d0
	beq.s	.Skip2
	move.b	d0,21(a0)		; Mem prio is reduced by 1
					; each time down to 1.
.Skip2:
	lea.l	24(a0),a0		; Go to next file handle/info
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Initialize the file infos (memory types, priorities) ]
;*****************************************************************************
Init_file_infos:
	movem.l	d0/d1/d6/d7/a0/a1,-(sp)
	lea.l	Sub_file_pointers,a0
	move.w	#499,d7		; 500 loops (sub-files?)
.Loop:
	bclr.b	#2,17(a0)		; Clear some bits for each of
					; the 500 24byte structs.
	lea.l	24(a0),a0
	dbra	d7,.Loop
	lea.l	File_info_pointers,a0		; This is a list of structures
					; of size 0x12 (18). The amount
					; is given at 0x2849b2.
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip
.Loop2:
	jsr	Check_validity_of_file_data_info
	lea.l	18(a0),a0
.Skip:
	dbra	d7,.Loop2
	movem.l	(sp)+,d0/d1/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Check the memory block descriptors for consistency ]
; NOTE :
;   - Exits the program if the memory lists are corrupt.
;*****************************************************************************
Check_validity_of_file_data_info:
	movem.l	d0-d5/d7/a0,-(sp)		; This looks like some validity
					; checks for some pointers and
					; structure connections. Most
					; likely A0 is a timer struct
					; with elapsed function pointer.
	move.l	(a0),d0
	move.l	d0,d1
	move.l	d0,d5
	add.l	4(a0),d1
	move.l	4(a0),d2
	move.l	#Sub_file_pointers,d3
	move.l	#Current_file_compression_space,d4
.Loop:
	move.l	12(a0),d7
	beq.s	.Skip
	cmp.l	d3,d7
	bmi.w	.Loop2
	cmp.l	d4,d7
	bpl.w	.Loop2
	move.l	d7,a0
	btst.b	#2,17(a0)
	bne.w	.Loop2
	bset.b	#2,17(a0)
	move.l	(a0),d7
	cmp.l	d5,d7
	bne.w	.Loop2
	cmp.l	d0,d7
	bmi.w	.Loop2
	cmp.l	d1,d7
	bpl.w	.Loop2
	add.l	4(a0),d7
	move.l	d7,d5
	subq.l	#1,d7
	cmp.l	d0,d7
	bmi.s	.Loop2
	cmp.l	d1,d7
	bpl.s	.Loop2
	sub.l	4(a0),d2
	bra.s	.Loop
.Loop2:
	move.l	#-2006,Return_value
	jmp	Exit_program
.Skip:
	tst.l	d2
	bne.s	.Loop2
	cmp.l	d5,d1
	bne.s	.Loop2
	movem.l	(sp)+,d0-d5/d7/a0
	rts

;*****************************************************************************
; [ Set the priority of a memory block to the file priority ]
;   IN : a0 - Pointer to memory block descriptor (.l)
;*****************************************************************************
Update_file_mem_prio:
	move.l	d1,-(sp)
	moveq.l	#0,d1
	move.b	20(a0),d1		; File index
	beq.s	.Exit		; 0 is invalid
	jsr	Get_file_mem_prio
.Exit:
	ori.b	#-$80,d1
	move.b	d1,21(a0)		; Store negative mem prio
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Create a handle for a memory area which is not managed by the memory manager ]
;   IN : a0 - Address (.l)
;  OUT : d0 - Handle (200...224) (.b)
; NOTE :
;   - [ Claim_pointer ] returns the address for these handles.
; NOTE (disassembly) :
;   There can be up to 24 pointers and the id will be 200 to 223.
;*****************************************************************************
Create_fake_handle:
	movem.l	d7/a1,-(sp)
	move.w	#200,d0
	lea.l	Stored_object_pointers_up_to24,a1
	moveq.l	#24,d7
.Loop:
	tst.l	(a1)+
	bne.s	.Skip
	move.l	a0,-4(a1)
	bra.s	.Exit
.Skip:
	addq.b	#1,d0
	dbra	d7,.Loop
	move.l	#-2004,Return_value
	jmp	Exit_program
.Exit:
	movem.l	(sp)+,d7/a1
	rts

;*****************************************************************************
; [ Destroy a fake handle ]
;   IN : d0 - Handle (.b)
; All registers are restored
; NOTE (disassembly) :
;   Frees a memory handle previously acquired by FUN_AcquireMemoryHandle.
;*****************************************************************************
Destroy_fake_handle:
	movem.l	d0/a0,-(sp)
	lea.l	Stored_object_pointers_up_to24,a0
	andi.w	#$ff,d0
	subi.w	#200,d0
	lsl.w	#2,d0
	clr.l	0(a0,d0.w)
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Get the address of a memory block (and claim it) ]
;   IN : d0 - Memory handle (.b)
;  OUT : d0 - Address (.l)
; NOTE :
;   - A claimed memory block will not be moved. Use [ Free_pointer ] when done.
;   - Normally the macro "Get" is used.
; NOTE (disassembly) :
;   You can store pointers and assign an id. Then you can retrieve that pointer with that id. Ids < 200 are handled differently than those >= 200. You can only store 256 pointers.
;*****************************************************************************
Claim_pointer:
	move.l	a0,-(sp)
	andi.w	#$ff,d0
	cmp.w	#200,d0
	bmi.s	.Skip
	lea.l	Stored_object_pointers_up_to24,a0
	subi.w	#200,d0
	andi.w	#$ff,d0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),d0
	bra.w	.Exit
.Skip:
	jsr	Check_handle
	bne.s	.Exit
	cmpi.b	#-1,19(a0)
	beq.s	.Skip2
	addq.b	#1,19(a0)
.Skip2:
	move.l	(a0),d0
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Release the address of a memory block (unclaim it) ]
;   IN : d0 - Memory handle (.b)
; All registers are restored
; NOTE :
;   - Normally the macro "Free" is used.
;*****************************************************************************
Free_pointer:
	move.l	a0,-(sp)
	andi.w	#$ff,d0
	cmp.w	#200,d0
	bpl.s	.Exit
	jsr	Check_handle
	bne.s	.Exit
	tst.b	19(a0)
	beq.s	.Exit
	subq.b	#1,19(a0)
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Allocate a memory handle for a block ]
;   IN : a0 - Pointer to memory block descriptor (.l)
;  OUT : d0 - Handle (.b)
; NOTE :
;   - Exits the program if there are no free handles.
;*****************************************************************************
Allocate_handle:
	movem.l	d7/a1,-(sp)
	tst.b	19(a0)
	bne.s	.Exit
	lea.l	File_memory_pointers+4,a1
	moveq.l	#1,d0
	move.w	#198,d7
.Loop:
	tst.l	(a1)+
	beq.s	.Skip
	addq.w	#1,d0
	dbra	d7,.Loop
	move.l	#-2004,Return_value
	jmp	Exit_program
.Skip:
	move.l	a0,-4(a1)
	move.b	d0,18(a0)
.Exit:
	movem.l	(sp)+,d7/a1
	rts

;*****************************************************************************
; [ Free the memory handle of a block ]
;   IN : a0 - Pointer to memory block descriptor (.l)
; All registers are restored
;*****************************************************************************
Free_handle:
	movem.l	d0/a0,-(sp)
	tst.b	19(a0)
	bne.s	.Exit
	moveq.l	#0,d0
	move.b	18(a0),d0
	beq.s	.Exit
	clr.b	18(a0)
	lea.l	File_memory_pointers+4,a0
	lsl.w	#2,d0
	clr.l	-4(a0,d0.w)
.Exit:
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Rebuild the memory handle table ]
; All registers are restored
;*****************************************************************************
Rebuild_handle_table:
	movem.l	d0/d7/a0-a2,-(sp)
	lea.l	File_memory_pointers+4,a0
	move.w	#198,d7
.Loop:
	clr.l	(a0)+
	dbra	d7,.Loop
	lea.l	File_info_pointers,a1
	lea.l	File_memory_pointers+4,a2
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2
.Loop2:
	move.l	a1,a0
.Loop3:
	move.l	12(a0),d0
	beq.s	.Skip
	move.l	d0,a0
	moveq.l	#0,d0
	move.b	18(a0),d0
	beq.s	.Loop3
	lsl.w	#2,d0
	move.l	a0,-4(a2,d0.w)
	bra.s	.Loop3
.Skip:
	lea.l	18(a1),a1
.Skip2:
	dbra	d7,.Loop2
	movem.l	(sp)+,d0/d7/a0-a2
	rts

;*****************************************************************************
; [ Check a memory handle ]
;   IN : d0 - Handle (.b)
;  OUT : a0 - Pointer to memory block descriptor (.l)
;        eq - Handle is valid
;        ne - Handle is invalid
;*****************************************************************************
Check_handle:
	movem.l	d0-d2/d7/a1/a2,-(sp)
	moveq.l	#-1,d1		; Set D1 to true
	tst.b	d0		; If D0 is 0, just return true
	beq.s	.Exit
	andi.w	#$ff,d0		; Ensure D0w only has values 1-255
	cmp.w	#200,d0		; Only handle 1-199
	bpl.s	.Exit
	lea.l	File_memory_pointers,a2
	move.w	d0,d2
	lsl.w	#2,d2		; 4 bytes per entry (pointer)
	add.w	d2,a2
	move.l	(a2),d2		; Get pointer for index
	beq.s	.Exit		; If 0, return
	move.l	d2,a0		; A0 now is the pointer
	cmp.b	18(a0),d0		; If already has the right index, return success
	beq.s	.Skip3
	lea.l	File_info_pointers,a1
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2
.Loop:
	move.l	a1,a0
.Loop2:
	move.l	12(a0),d2
	beq.s	.Skip
	move.l	d2,a0
	cmp.b	18(a0),d0
	bne.s	.Loop2
	move.l	a0,(a2)
	bra.s	.Skip3
.Skip:
	lea.l	18(a1),a1
.Skip2:
	dbra	d7,.Loop
	bra.s	.Exit
.Skip3:
	moveq.l	#0,d1		; Mark success, return false
.Exit:
	tst.w	d1
	movem.l	(sp)+,d0-d2/d7/a1/a2
	rts

;*****************************************************************************
; [ Get a free memory block descriptor ]
;  OUT : a0 - Pointer to memory block descriptor (.l)
;*****************************************************************************
Get_next_free_sub_file_slot:
	movem.l	d0/d7,-(sp)
	tst.l	Free_descriptor_ptr
	beq.s	.Skip
	move.l	Free_descriptor_ptr,a0
	clr.l	Free_descriptor_ptr
	tst.l	(a0)
	beq.w	.Skip3
.Skip:
	moveq.l	#0,d0
.Loop:
	lea.l	Sub_file_pointers,a0
	move.w	#499,d7		; Up to 500 sub-files
.Loop2:
	tst.l	(a0)
	beq.w	.Skip3		; Branch for first null pointer.
					; So this searches to the end
					; of the linked list of sub-files.
	lea.l	24(a0),a0
	dbra	d7,.Loop2
	lea.l	File_info_pointers,a0		; If all 500 sub-files are
					; used and there is no space,
					; clear all file info and
					; exit with error below.
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2
.Loop3:
	jsr	Clear_file_infos
	lea.l	18(a0),a0
.Skip2:
	dbra	d7,.Loop3
	addq.b	#1,d0
	bne.s	.Loop
	move.l	#-2003,Return_value		; If D0 was -1, error
	jmp	Exit_program
.Skip3:
	clr.b	17(a0)		; Last sub-file was found
	clr.b	16(a0)		; and there is some space.
	clr.b	18(a0)		; Clear some values. A0 is now
					; the address of the next free
					; sub-file slot.
	clr.b	19(a0)
	clr.l	20(a0)
	movem.l	(sp)+,d0/d7
	rts

;*****************************************************************************
; [ Insert a memory block descriptor into a list ]
;   IN : a0 - Pointer to new descriptor (.l)
;        a1 - Pointer to predecessor (.l)
; NOTE (disassembly) :
;   Inserts a sub-file into the
;   linked list of sub-files for
;   the given file info.
;   Loaded files are organized as chains
;   of memory blocks (linked lists).
;   This function inserts A0 after A1 and
;   ensures a possible successor of A1 is
;   chained together with A0 correctly.
;*****************************************************************************
Insert_sub_file:
	move.l	a2,-(sp)		; A1 is the file info
	move.l	12(a1),a2		; A2 is the sub-file pointer
	cmp.l	#4-4,a2
	beq.s	.Exit
	move.l	a0,8(a2)		; If pointer exists, store
					; sub-file slot pointer as
					; predecessor for current
					; start element (sub-file).
.Exit:
	move.l	a2,12(a0)		; Reference the old sub-file
					; pointer as the next pointer
					; in the new sub-file slot.
					; The slot becomes the list
					; start element.
	move.l	a1,8(a0)		; Set the file info as the
					; predecessor of the new
					; sub-file.
	move.l	a0,12(a1)		; The file info now references
					; the new sub-file slot as the
					; begin of its sub-files.
	move.l	(sp)+,a2
	rts

;*****************************************************************************
; [ Remove a block descriptor from its list ]
;   IN : a0 - Pointer to memory block descriptor (.l)
; All registers are restored
;*****************************************************************************
Remove_block_descriptor:
	movem.l	a1/a2,-(sp)
	move.l	8(a0),a1
	move.l	12(a0),a2
	cmp.l	#4-4,a2
	beq.s	.Exit
	move.l	a1,8(a2)
.Exit:
	move.l	a2,12(a1)
	clr.l	(a0)
	move.l	a0,Free_descriptor_ptr
	movem.l	(sp)+,a1/a2
	rts

;*****************************************************************************
; [ Initialize the memory areas (one free block per area) ]
; All registers are restored
;*****************************************************************************
Init_sub_files:
	movem.l	d7/a0-a2,-(sp)
	move.w	#10000,Tick_counter
	lea.l	File_info_pointers,a2
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip2
.Loop:
	move.l	a2,a1
.Loop2:
	tst.l	12(a1)
	beq.s	.Skip
	move.l	12(a1),a0
	jsr	Remove_block_descriptor
	bra.s	.Loop2
.Skip:
	jsr	Get_next_free_sub_file_slot
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.b	16(a1),16(a0)
	move.l	a2,a1
	jsr	Insert_sub_file
	lea.l	18(a2),a2		; Successor
.Skip2:
	dbra	d7,.Loop
	lea.l	File_memory_pointers+4,a0
	move.w	#198,d7
.Loop3:
	clr.l	(a0)+
	dbra	d7,.Loop3
	lea.l	Stored_object_pointers_up_to24,a0
	moveq.l	#24,d7
.Loop4:
	clr.l	(a0)+
	dbra	d7,.Loop4
	movem.l	(sp)+,d7/a0-a2
	rts

;*****************************************************************************
; [ Allocate the memory areas from the system ]
;  OUT : mi - Not enough memory
; NOTE :
;   - At least 280000 bytes are needed.
; NOTE (disassembly) :
;   This allocates at least 280000 CHIP
;   and 75000 FAST memory or at least
;   325000 CHIP memory if there is no
;   FAST memory.
;*****************************************************************************
Allocate_chip_and_fast_memory:
	movem.l	d0-d7/a0-a2,-(sp)
	moveq.l	#-1,d0
	lea.l	File_info_pointers,a2
	moveq.l	#0,d7		; This will hold the amount of
					; total allocated memory blocks
					; at the end. This is limited
					; to 10.
	move.l	#$2800,d3		; Ensure free 10240 bytes
					; after allocation.
	moveq.l	#0,d5		; Memory slot index 0
	moveq.l	#2,d6		; Allocate as CHIP
	jsr	Allocate_system_memory
	cmp.l	#280000,d4		; We need at least 280000 bytes.
	bpl.s	.Skip
	move.l	#-2001,Return_value		; Else error
	bra.s	.Exit
.Skip:
	move.l	d4,Allocated_chip_memory_size
	move.l	#$2800,d3
	moveq.l	#1,d5		; Memory slot index 1
	moveq.l	#4,d6		; Allocate as FAST
	jsr	Allocate_system_memory
	cmp.l	#75000,d4		; We need at least 75000 bytes.
	bpl.s	.Skip2
	move.l	Allocated_chip_memory_size,d1
	cmp.l	#355000,d1		; If no FAST mem available,
					; check if the first CHIP
					; alloc has enough space
					; for this data too.
	bpl.s	.Skip2
	move.l	#-2002,Return_value		; Else error
	bra.s	.Exit
.Skip2:
	move.l	d4,Allocated_fast_memory_size
	moveq.l	#0,d0
.Exit:
	move.w	d7,Allocated_memory_block_count
	tst.w	d0
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Allocate memory from the system for the memory areas ]
;   IN : d0 - Memory type (.w)
;  OUT : mi - Not enough memory
; NOTE (disassembly) :
;   This tries to allocate 10 of
;   the largest available memory
;   blocks. D3 gives the amount
;   of available memory to preserve
;   afterwards. If this is not
;   available after allocation, the
;   memory is freed.
;*****************************************************************************
Allocate_system_memory:
	movem.l	d0-d3/d5/d6/a0/a1,-(sp)
	moveq.l	#0,d4
.Loop:
	cmp.w	#10,d7		; FIX: Check the limit BEFORE allocating.
	bpl.s	.Skip		; The block counter d7 counts the CHIP and
					; FAST blocks together and the table
					; File_info_pointers only has room for 10.
					; If the CHIP memory was fragmented into
					; 10 blocks (e.g. when started from
					; Workbench), one FAST block was stored
					; behind the table (in Sub_file_pointers).
					; This entry was overwritten during the
					; game and Free_all_memory then freed a
					; wrong block -> Guru 8100 0005 on exit.
	move.l	d6,d1		; Allocate flags
	ori.l	#$20000,d1		; MEMF_LARGEST
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOAvailMem(a6)
	move.l	(sp)+,a6
	cmp.l	#$1400,d0		; Is largest chunk size >= 5120 bytes?
	bmi.s	.Skip		; If not try another approach
	move.l	d0,d2		; If so, save the block size
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOAllocMem(a6)		; And allocate this block
	move.l	(sp)+,a6
	tst.l	d0
	beq.s	.Loop		; Failed to alloc? Try again.
					; Most likely someone allocated
					; it in the meantime.
	move.l	d0,(a2)		; Store pointer to memory at (A2)
	move.l	d2,4(a2)		; Store size of block
	move.b	d5,17(a2)		; Store identifier for the chain
	move.b	d7,16(a2)		; Store chain element index
	add.l	d2,d4		; Add to total allocated size
	lea.l	18(a2),a2		; Set A2 to next memory chain pointer
	addq.w	#1,d7		; Increase memory chain element index
	cmp.w	#10,d7		; Limit to 10 memory elements per chain
	bmi.s	.Loop
.Skip:
	move.l	d6,d1		; This time without MEMF_LARGEST
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOAvailMem(a6)
	move.l	(sp)+,a6
	sub.l	d0,d3		; More memory available then needed, just return
	bmi.s	.Exit
.Loop2:
	lea.l	-18(a2),a2		; If not, we free the memory
	cmp.b	17(a2),d5		; Check if part of the current chain
	bne.s	.Exit
	move.l	4(a2),d0		; If so get size of the mem block
	cmp.l	d0,d3		; D3 holds the amount that
					; couldn't be allocated.
					; 
	bmi.s	.Skip2
	sub.l	d0,d3
	sub.l	d0,d4		; Reduce total allocated size
	move.l	4(a2),d0		; Get block size
	move.l	(a2),a1		; Get block mem pointer
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOFreeMem(a6)		; Free it
	move.l	(sp)+,a6
	subq.w	#1,d7		; Decrease chain element index
	beq.s	.Exit		; Until all elements have freed
	bra.s	.Loop2
.Skip2:
	move.l	d0,d1
	sub.l	d3,d1
	cmp.l	#$1400,d1
	bpl.s	.Skip3
	sub.l	d0,d4
	move.l	4(a2),d0
	move.l	(a2),a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOFreeMem(a6)
	move.l	(sp)+,a6
	subq.w	#1,d7
	bra.s	.Exit
.Skip3:
	sub.l	d3,d0
	move.l	d0,4(a2)
	sub.l	d3,d4
	move.l	(a2),a1
	add.l	d0,a1
	move.l	d3,d0
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOFreeMem(a6)
	move.l	(sp)+,a6
	lea.l	18(a2),a2
.Exit:
	movem.l	(sp)+,d0-d3/d5/d6/a0/a1
	rts

;*****************************************************************************
; [ Free all memory areas (back to the system) ]
; All registers are restored
;*****************************************************************************
Free_all_memory:
	movem.l	d0/d1/d7/a0-a2,-(sp)
	lea.l	File_info_pointers,a2
	move.w	Allocated_memory_block_count,d7
	bra.s	.Skip
.Loop:
	move.l	4(a2),d0
	move.l	(a2),a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOFreeMem(a6)
	move.l	(sp)+,a6
	lea.l	18(a2),a2
.Skip:
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d1/d7/a0-a2
	rts

;*****************************************************************************
; [ Release the blitter (DisownBlitter) ]
; All registers are restored
;*****************************************************************************
Free_blitter_usage:
	movem.l	d0/d1/a0/a1,-(sp)
	tst.b	Blitter_is_not_owned
	bne.s	.Exit
	st	Blitter_is_not_owned
	move.w	#$400,Custom+dmacon
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVODisownBlitter(a6)		; DisownBlitter (free blitter for other use)
	move.l	(sp)+,a6
.Exit:
	movem.l	(sp)+,d0/d1/a0/a1
	rts

;*****************************************************************************
; [ Get the blitter (OwnBlitter) ]
; All registers are restored
;*****************************************************************************
Own_blitter:
	movem.l	d0/d1/a0/a1,-(sp)
	tst.b	Blitter_is_not_owned
	beq.s	.Exit
	sf	Blitter_is_not_owned
.Wait:
	btst.b	#6,Custom+dmaconr		; Wait for blitter finish
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOOwnBlitter(a6)		; OwnBlitter
	move.l	(sp)+,a6
	move.w	#-$7c00,Custom+dmacon
	move.w	#$40,Custom+intena
.Exit:
	movem.l	(sp)+,d0/d1/a0/a1
	rts


	SECTION	Fast_DATA,data
Default_file_mem_type:
	dc.b	3,0

	SECTION	Fast_BSS,bss
Memory_moved_flag:
	ds.b	2
Tick_counter:
	ds.w	1
Allocated_chip_memory_size:
	ds.l	1
Allocated_fast_memory_size:
	ds.b	4
Total_ticks:
	ds.l	1
Allocated_memory_block_count:
	ds.w	1
Free_descriptor_ptr:
	ds.l	1
File_memory_pointers:
	ds.b	800
Stored_object_pointers_up_to24:
	ds.b	96
	ds.l	1
File_info_pointers:
	ds.b	180
Sub_file_pointers:
	ds.l	4
