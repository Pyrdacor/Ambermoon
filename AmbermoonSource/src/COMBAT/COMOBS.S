; COMbat OBject management
; Written by J.Horneman (In Tune With The Universe)
; Start : 20-4-1993

	SECTION	Program,code
;*****************************************************************************
; [ Initialize COMOBs ]
; All registers are restored
;*****************************************************************************
Init_COMOBs:
	movem.l	d0/d7/a0,-(sp)
	lea.l	COMOBs_data,a0		; Clear COMOB data
	moveq.l	#0,d0
	move.w	#COMOBs_data_size/2-1,d7
.Loop:	move.w	d0,(a0)+
	dbra	d7,.Loop
	st	Complete_update		; Start with complete update
	st	COMOBs_blocked		; Block automatic refresh
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Add COMOB ]
;  OUT : a0 - Pointer to new COMOB data (.l)
; All registers are restored
;*****************************************************************************
Add_COMOB:
	movem.l	d0/a1,-(sp)
	lea.l	COMOB_table,a0		; No -> Find free slot
	moveq.l	#Max_COMOBs-1,d0
.Loop:	btst	#COMOB_present,COMOB_Flags(a0)	; Present ?
	beq.s	.Found
	lea.l	COMOB_data_size(a0),a0	; Yes -> Next COMOB slot
	dbra	d0,.Loop
	bra.s	.Exit
.Found:	clr.w	COMOB_3D_vector_X(a0)	; Initialize COMOB
	clr.w	COMOB_3D_vector_Y(a0)
	clr.w	COMOB_3D_vector_Z(a0)
	move.w	#-1,COMOB_Colour(a0)
	clr.b	COMOB_Mirror_flags(a0)
	clr.w	COMOB_Frame(a0)
	clr.l	COMOB_Gfx_base(a0)
	clr.l	COMOB_Previous_CA(a0)
	clr.l	COMOB_Previous_CA+4(a0)
	move.b	#(1<<COMOB_present)!(1<<COMOB_add),COMOB_Flags(a0)
	lea.l	COMOB_sort_list,a1		; Add to sort list
	move.w	New_nr_COMOBs,d0
	lsl.w	#2,d0
	move.l	a0,0(a1,d0.l)
	addq.w	#1,New_nr_COMOBs		; Count up
.Exit:	movem.l	(sp)+,d0/a1
	rts

;*****************************************************************************
; [ Delete COMOB ]
;   IN : a0 - Pointer to COMOB data (.l)
; All registers are restored
;*****************************************************************************
Delete_COMOB:
	btst	#COMOB_add,COMOB_Flags(a0)	; Just added ?
	beq.s	.No
	bset	#COMOB_delete,COMOB_Flags(a0)	; Yes -> Delete
	bra.s	.Exit
.No:	bset	#COMOB_erase,COMOB_Flags(a0)	; No -> Erase first
.Exit:	rts

;*****************************************************************************
; [ Refresh combat screen main 3D window in screen-queue ]
; All registers are restored
;*****************************************************************************
Refresh_combat_screen:
	tst.b	COMOBs_blocked		; Blocked ?
	bne.s	.Exit
	jsr	Draw_combat_screen		; No -> Do
.Exit:	rts

;*****************************************************************************
; [ Draw combat screen main 3D window ]
; All registers are restored
;*****************************************************************************
Draw_combat_screen:
	movem.l	d0-d2/d5-d7/a0-a2,-(sp)
; ---------- Duplicate combat window --------------
	moveq.l	#Combat_X,d0		; Combat window parameters
	moveq.l	#Combat_Y,d1
	moveq.l	#Screen_depth,d5
	moveq.l	#Combat_width/16,d6
	moveq.l	#Combat_height,d7
	tst.b	Complete_update		; Update all ?
	beq.s	.Some
	tst.b	Update_command		; Gonna update anyway ?
	bne.s	.Done
	jsr	Duplicate_block		; No
	bra.s	.Done
.Some:	lea.l	Combat_CA_list,a0		; Duplicate in all CAs
	move.w	Nr_combat_CAs,d2
	bra.s	.Entry
.Loop:	tst.l	(a0)			; CA deleted ?
	beq.s	.Next
	jsr	Push_CA			; No -> Duplicate
	jsr	Duplicate_block
	jsr	Pop_CA
.Next:	addq.w	#CA_data_size,a0		; Next CA
.Entry:	dbra	d2,.Loop
.Done:	LOCAL
; ---------- Do -----------------------------------
	move.b	Update_command,Complete_update
	sf	Update_command
	clr.w	Nr_combat_CAs		; Clear
; ---------- Remove deleted COMOBs ----------------
	lea.l	COMOB_sort_list,a0
	moveq.l	#0,d0
	move.w	New_nr_COMOBs,d7
	bra.s	.Next1
.Loop1:	move.l	(a0)+,a2			; Get COMOB data
	btst	#COMOB_delete,COMOB_Flags(a2)	; Delete ?
	bne.s	.Delete
	addq.w	#1,d0			; No -> Count up
.Next1:	dbra	d7,.Loop1
	bra.s	.Done
.Delete:	bclr	#COMOB_present,COMOB_Flags(a2)	; Delete
	lea.l	-4(a0),a1			; Copy down from here
	bra.s	.Next4
.Loop4:	move.l	(a0)+,a2			; Get COMOB data
	btst	#COMOB_delete,COMOB_Flags(a2)	; Delete ?
	beq.s	.No
	bclr	#COMOB_present,COMOB_Flags(a2)	; Yes
	bra.s	.Next4
.No:	move.l	a2,(a1)+			; No -> Copy
	addq.w	#1,d0			; Count up
.Next4:	dbra	d7,.Loop4			; Next COMOB
.Done:	move.w	d0,Nr_COMOBs		; Store new number
	move.w	d0,New_nr_COMOBs
; ---------- Process all COMOBs -------------------
	lea.l	COMOB_sort_list,a1
	move.w	Nr_COMOBs,d7
	bra.s	.Next2
.Loop2:	move.l	(a1)+,a0			; Process COMOB
	jsr	Process_COMOB
.Next2:	dbra	d7,.Loop2			; Next COMOB
	lea.l	Compare_COMOBs,a0		; Sort COMOBs
	lea.l	Swap_COMOBs,a1
	lea.l	COMOB_sort_list,a2
	move.w	Nr_COMOBs,d7
	jsr	Shuttlesort
; ---------- Display all COMOBs -------------------
	Get	Combat_zoom_screen_handle,a0	; Set pointers
	move.l	a0,Zoomscreen1_ptr
	lea.l	Combat_height*Bytes_per_line(a0),a0
	move.l	a0,Zoomscreen2_ptr
	Free	Combat_zoom_screen_handle
	tst.b	Complete_update		; Update all ?
	beq.s	.Some
	Push	CA,Combat_CA		; Yes -> Draw all COMOBs
	jsr	Draw_all_COMOBs
	Pop	CA
	bra.s	.Exit
.Some:	lea.l	Combat_CA_list,a0		; Display in all CAs
	move.w	Nr_combat_CAs,d7
	bra.s	.Entry3
.Loop3:	tst.l	(a0)			; CA deleted ?
	beq.s	.Next3
	jsr	Push_CA			; No -> Draw all COMOBs
	jsr	Draw_all_COMOBs
	jsr	Pop_CA
.Next3:	addq.w	#CA_data_size,a0		; Next CA
.Entry3:	dbra	d7,.Loop3
; ---------- Update animations --------------------
.Exit:	cmp.w	#Combat_animspeed,Combat_anim_timer	; Not too fast ?
	bmi.s	.Not_now
	jsr	Update_combat_animations	; No -> Animate
	jsr	Start_random_animations
	clr.w	Combat_anim_timer		; Reset timer
.Not_now:	movem.l	(sp)+,d0-d2/d5-d7/a0-a2
	rts

;*****************************************************************************
; [ Draw all CMOBs ]
; All registers are restored
; Notes :
;   - This routine assumes a CA has been installed.
;*****************************************************************************
Draw_all_COMOBs:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	#Combat_X,d0		; Display background
	move.w	#Combat_Y,d1
	moveq.l	#5,d5
	moveq.l	#Combat_width/16,d6
	move.w	#Combat_height,d7
	Get	Combat_background_handle,a0
	jsr	Put_unmasked_block
	Free	Combat_background_handle
	lea.l	COMOB_sort_list,a1		; Do all COMOBs
	move.w	Nr_COMOBs,d2
	bra.s	.Entry
.Loop:	move.w	d2,-(sp)
	move.l	(a1)+,a2			; Get data address
	move.l	COMOB_Gfx_offset(a2),d0	; Draw at all ?
	bmi.s	.Next
	Get	COMOB_Gfx_handle(a2),a0	; Yes
	Free	COMOB_Gfx_handle(a2)
	add.l	COMOB_Gfx_base(a2),a0
	add.l	d0,a0
	movem.w	(a2),d0-d7		; Get draw data
	cmp.w	d4,d6			; Same size ?
	bne.s	.Zoom
	cmp.w	d5,d7
	bne.s	.Zoom
	tst.w	d3			; No mirroring ?
	bne.s	.Zoom
	moveq.l	#Screen_depth,d5		; Don't zoom !
	addi.w	#15,d6
	lsr.w	#4,d6
	tst.w	d2			; Silhouette ?
	bpl.s	.Silh1
	jsr	Put_masked_block		; No
	bra.s	.Next
.Silh1:	move.w	d2,d4			; Yes
	jsr	Put_masked_silhouette
	bra.s	.Next
.Zoom:	tst.w	d2			; Zoom -> Silhouette ?
	bpl.s	.Silh2
	jsr	Draw_zoom_shape		; No
	bra.s	.Next
.Silh2:	jsr	Draw_zoom_silhouette	; Yes
.Next:	move.w	(sp)+,d2			; Next
.Entry:	dbra	d2,.Loop
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Process COMOB ]
;   IN : a0 - Pointer to COMOB data (.l)
; All registers are restored
;*****************************************************************************
Process_COMOB:
	movem.l	d0-d7,-(sp)
; ---------- Evaluate movement vector -------------
	move.w	COMOB_3D_X(a0),d0		; Get 3D coordinates
	move.w	COMOB_3D_Y(a0),d1
	move.w	COMOB_3D_Z(a0),d2
	tst.w	COMOB_3D_vector_X(a0)	; Move ?
	bne.s	.Move
	tst.w	COMOB_3D_vector_Y(a0)
	bne.s	.Move
	tst.w	COMOB_3D_vector_Z(a0)
	beq.s	.Dont
.Move:	add.w	COMOB_3D_vector_X(a0),d0	; Yes
	add.w	COMOB_3D_vector_Y(a0),d1
	add.w	COMOB_3D_vector_Z(a0),d2
	move.w	d0,COMOB_3D_X(a0)		; Store new coordinates
	move.w	d1,COMOB_3D_Y(a0)
	move.w	d2,COMOB_3D_Z(a0)
	bset	#COMOB_update,COMOB_Flags(a0)	; Update
; ---------- Project ------------------------------
.Dont:	subi.w	#Combat_camera_height,d1	; Adapt to camera height
	ext.l	d0			; Project coordinates
	ext.l	d1
	move.w	d2,d3
	addi.w	#Combat_proj_factor,d3
	bne.s	.Notzero
	moveq.l	#1,d3
.Notzero:	moveq.l	#Combat_proj_log,d4
	asl.l	d4,d0
	asl.l	d4,d1
	divs.w	d3,d0
	divs.w	d3,d1
	neg.w	d1
	addi.w	#Combat_cX,d0		; Centre
	addi.w	#Combat_cY,d1
	moveq.l	#0,d6			; Get display size
	move.w	COMOB_Display_width(a0),d6
	moveq.l	#0,d7
	move.w	COMOB_Display_height(a0),d7
	moveq.l	#Combat_proj_log,d4		; Project display size
	asl.l	d4,d6
	asl.l	d4,d7
	divs.w	d3,d6
	divs.w	d3,d7
	move.w	COMOB_Source_width(a0),d4	; Get source size
	move.w	COMOB_Source_height(a0),d5
	sub.w	d7,d1			; Adjust to bottom-centre
	move.w	d6,d2
	lsr.w	#1,d2
	sub.w	d2,d0
	move.w	d0,COMOB_2D_X(a0)		; Store data
	move.w	d1,COMOB_2D_Y(a0)
	move.w	d6,COMOB_Projected_width(a0)
	move.w	d7,COMOB_Projected_height(a0)
; ---------- Calculate graphics offset ------------
	btst	#COMOB_erase,COMOB_Flags(a0)	; Erase ?
	beq.s	.No
	move.l	#-1,COMOB_Gfx_offset(a0)	; Yes
	bset	#COMOB_delete,COMOB_Flags(a0)
	bra.s	.Skip
.No:	lsr.w	#4,d4			; Calculate size of one frame
	mulu.w	#Screen_depth*2,d4
	mulu.w	d5,d4
	mulu.w	COMOB_Frame(a0),d4		; Calculate frame offset
	move.l	d4,COMOB_Gfx_offset(a0)	; Store
; ---------- Create CA ----------------------------
.Skip:	move.w	d6,d2			; Make new CA
	add.w	d0,d2
	andi.w	#$fff0,d0
	addi.w	#15,d2
	andi.w	#$fff0,d2
	subq.w	#1,d2
	move.w	d7,d3
	add.w	d1,d3
	subq.w	#1,d3
	tst.b	Complete_update		; Update all ?
	bne.s	.Yes
	bclr	#COMOB_add,COMOB_Flags(a0)	; Just added ?
	beq.s	.Old
	move.w	d0,COMOB_Previous_CA+CA_X1(a0)	; Store new
	move.w	d1,COMOB_Previous_CA+CA_Y1(a0)
	move.w	d2,COMOB_Previous_CA+CA_X2(a0)
	move.w	d3,COMOB_Previous_CA+CA_Y2(a0)
	bra	.No4			; Don't merge
.Old:	bclr	#COMOB_update,COMOB_Flags(a0)	; Update this one ?
	bne.s	.Do
	btst	#COMOB_erase,COMOB_Flags(a0)	; Erase ?
	bne.s	.Do
.Yes:	move.w	d0,COMOB_Previous_CA+CA_X1(a0)	; Store new
	move.w	d1,COMOB_Previous_CA+CA_Y1(a0)
	move.w	d2,COMOB_Previous_CA+CA_X2(a0)
	move.w	d3,COMOB_Previous_CA+CA_Y2(a0)
	bra	.Exit
.Do:	move.w	COMOB_Previous_CA+CA_X1(a0),d4	; Get previous
	move.w	COMOB_Previous_CA+CA_Y1(a0),d5
	move.w	COMOB_Previous_CA+CA_X2(a0),d6
	move.w	COMOB_Previous_CA+CA_Y2(a0),d7
	move.w	d0,COMOB_Previous_CA+CA_X1(a0)	; Store new
	move.w	d1,COMOB_Previous_CA+CA_Y1(a0)
	move.w	d2,COMOB_Previous_CA+CA_X2(a0)
	move.w	d3,COMOB_Previous_CA+CA_Y2(a0)
	cmp.w	d4,d0			; Merge with previous
	ble.s	.No1
	move.w	d4,d0
.No1:	cmp.w	d5,d1
	ble.s	.No2
	move.w	d5,d1
.No2:	cmp.w	d6,d2
	bge.s	.No3
	move.w	d6,d2
.No3:	cmp.w	d7,d3
	bge.s	.No4
	move.w	d7,d3
.No4:	jsr	Add_combat_CA		; Add
.Exit:	movem.l	(sp)+,d0-d7
	rts

;*****************************************************************************
; [ Add combat CA ]
;   IN : d0-d3 - CA (.w)
; All registers are restored
; Notes :
;   - All CA X-coordinates are on 16-pixel boundaries.
;   - CA's should not have an X1 of 0 and an X2 of 0 (quite unlikely), because
;     this routine will think the CA was deleted.
;*****************************************************************************
Add_combat_CA:
	movem.l	d0-d7/a0/a1,-(sp)
; ---------- Check if CA is off-screen ------------
	lea.l	Combat_CA,a0
	cmp.w	CA_X2(a0),d0		; X1 over right edge ?
	bgt	.Exit
	cmp.w	CA_Y2(a0),d1		; Y1 over bottom edge ?
	bgt	.Exit
	cmp.w	CA_X1(a0),d2		; X2 over left edge ?
	bmi	.Exit
	cmp.w	CA_Y1(a0),d3		; Y2 over top edge ?
	bmi	.Exit
; ---------- Clip CA against main window ----------
	cmp.w	CA_X1(a0),d0		; Clip left
	bpl.s	.Right
	move.w	CA_X1(a0),d0
.Right:	cmp.w	CA_X2(a0),d2		; Clip right
	bmi.s	.Top
	move.w	CA_X2(a0),d2
.Top:	cmp.w	CA_Y1(a0),d1		; Clip top
	bpl.s	.Bottom
	move.w	CA_Y1(a0),d1
.Bottom:	cmp.w	CA_Y2(a0),d3		; Clip bottom
	bmi.s	.Done
	move.w	CA_Y2(a0),d3		; Adjust height
; ---------- Check CA redundancy ------------------
.Done:	lea.l	Combat_CA_list,a0
	move.w	Nr_combat_CAs,d7
	bra.s	.Entry1
.Loop1:	tst.l	(a0)			; Deleted ?
	beq.s	.Next1
	cmp.w	CA_X1(a0),d0		; New CA inside this one ?
	bmi.s	.Ok
	cmp.w	CA_X2(a0),d0
	bgt.s	.Ok
	cmp.w	CA_Y1(a0),d1
	bmi.s	.Ok
	cmp.w	CA_Y2(a0),d1
	bgt.s	.Ok
	cmp.w	CA_X1(a0),d2
	bmi.s	.Ok
	cmp.w	CA_X2(a0),d2
	bgt.s	.Ok
	cmp.w	CA_Y1(a0),d3
	bmi.s	.Ok
	cmp.w	CA_Y2(a0),d3
	bmi	.Exit
.Ok:	cmp.w	CA_X1(a0),d0		; This CA inside new one ?
	bgt.s	.Next1
	cmp.w	CA_X1(a0),d2
	bmi.s	.Next1
	cmp.w	CA_Y1(a0),d1
	bgt.s	.Next1
	cmp.w	CA_Y1(a0),d3
	bmi.s	.Next1
	cmp.w	CA_X2(a0),d0
	bgt.s	.Next1
	cmp.w	CA_X2(a0),d2
	bmi.s	.Next1
	cmp.w	CA_Y2(a0),d1
	bgt.s	.Next1
	cmp.w	CA_Y2(a0),d3
	bmi.s	.Next1
	clr.l	(a0)			; Yes -> Delete CA
.Next1:	addq.w	#CA_data_size,a0		; Next CA
.Entry1:	dbra	d7,.Loop1
; ---------- Insert CA in list --------------------
	move.l	a0,a1			; Insert new CA
	move.w	d0,CA_X1(a1)
	move.w	d1,CA_Y1(a1)
	move.w	d2,CA_X2(a1)
	move.w	d3,CA_Y2(a1)
	sub.w	d0,d2			; Calculate CA size
	addq.w	#1,d2
	sub.w	d1,d3
	addq.w	#1,d3
	mulu.w	d2,d3
	lsl.w	#4,d3
	move.w	d3,d6
; ---------- Check for CA mergers -----------------
	lea.l	Combat_CA_list,a0
	move.w	Nr_combat_CAs,d7
	bra	.Entry2
.Loop2:	tst.l	(a0)			; Deleted ?
	beq	.Next2
	move.w	CA_X2(a0),d2		; Calculate combined CA size
	sub.w	CA_X1(a0),d2
	addq.w	#1,d2
	move.w	CA_Y2(a0),d3
	sub.w	CA_Y1(a0),d3
	addq.w	#1,d3
	mulu.w	d2,d3
	lsl.w	#4,d3
	move.w	d3,d5
	add.w	d6,d5
	move.w	CA_X1(a1),d0		; Get original CA
	move.w	CA_Y1(a1),d1
	move.w	CA_X2(a1),d2
	move.w	CA_Y2(a1),d3
	cmp.w	CA_X1(a0),d0		; Left edge farther left ?
	bmi.s	.No1
	move.w	CA_X1(a0),d0
.No1:	cmp.w	CA_Y1(a0),d1		; Top edge farther up ?
	bmi.s	.No2
	move.w	CA_Y1(a0),d1
.No2:	cmp.w	CA_X2(a0),d2		; Right edge farther right ?
	bgt.s	.No3
	move.w	CA_X2(a0),d2
.No3:	cmp.w	CA_Y2(a0),d3		; Bottom edge farther down ?
	bgt.s	.No4
	move.w	CA_Y2(a0),d3
.No4:	movem.w	d2/d3,-(sp)		; Calculate largest CA size
	sub.w	d0,d2
	addq.w	#1,d2
	sub.w	d1,d3
	addq.w	#1,d3
	mulu.w	d2,d3
	lsl.w	#4,d3
	move.w	d3,d4
	movem.w	(sp)+,d2/d3
	cmp.w	d4,d5			; Merge ?
	bmi.s	.Next2
	move.w	d0,CA_X1(a0)		; Make new CA
	move.w	d1,CA_Y1(a0)
	move.w	d2,CA_X2(a0)
	move.w	d3,CA_Y2(a0)
	clr.l	(a1)			; Clear
	bra.s	.Exit
.Next2:	addq.w	#CA_data_size,a0		; Next CA
.Entry2:	dbra	d7,.Loop2
	addq.w	#1,Nr_combat_CAs		; Count up
.Exit:	movem.l	(sp)+,d0-d7/a0/a1
	rts

;*****************************************************************************
; [ Compare two COMOBs (Shuttlesort) ]
;   IN : d5 - Source index {1...} (.w)
;        d6 - Destination index {1...} (.w)
;        a2 - COMOB sort list (.l)
;  OUT : eq - Source  = Destination
;        ge - Source >= Destination
;        le - Source <= Destination
; All registers are restored
;*****************************************************************************
Compare_COMOBs:
	movem.l	d0/d1/d5/d6/a0,-(sp)
	add.w	d5,d5			; Get first COMOB data
	add.w	d5,d5
	move.l	-4(a2,d5.w),a0
	move.w	COMOB_3D_Z(a0),d0		; Get first COMOB depth
	add.w	d6,d6			; Get second COMOB data
	add.w	d6,d6
	move.l	-4(a2,d6.w),a0
	move.w	COMOB_3D_Z(a0),d1		; Get second COMOB depth
	cmp.w	d0,d1			; Compare
	movem.l	(sp)+,d0/d1/d5/d6/a0
	rts

;*****************************************************************************
; [ Swap two COMOBs (Shuttlesort) ]
;   IN : d5 - Source index {1...} (.w)
;        d6 - Destination index {1...} (.w)
;        a2 - COMOB sort list (.l)
; All registers are restored
;*****************************************************************************
Swap_COMOBs:
	movem.l	d0/d5/d6,-(sp)
	add.w	d5,d5			; Find data
	add.w	d5,d5
	add.w	d6,d6
	add.w	d6,d6
	move.l	-4(a2,d5.w),d0		; Swap
	move.l	-4(a2,d6.w),-4(a2,d5.w)
	move.l	d0,-4(a2,d6.w)
	movem.l	(sp)+,d0/d5/d6
	rts

;*****************************************************************************
; [ Combat animation timer ]
;*****************************************************************************
Time_combat:
	addq.w	#1,Combat_anim_timer
	rts

;*****************************************************************************
; [ Do circle animation on COMOB ]
;   IN : d0 - Number of animation frames (.w)
;        a0 - Pointer to COMOB data (.l)
; All registers are restored
;*****************************************************************************
Circle_COMOB:
	move.l	d1,-(sp)
	cmp.w	#1,d0			; Just one frame ?
	beq.s	.Exit
	move.w	COMOB_Frame(a0),d1		; Get current frame
	addq.w	#1,d1			; Next
	cmp.w	d0,d1			; Last frame ?
	bmi.s	.Ok
	moveq.l	#0,d1			; Yes -> Back to start
.Ok:	move.w	d1,COMOB_Frame(a0)		; Store new frame
.Exit:	bset	#COMOB_update,COMOB_Flags(a0)
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Do circle animation on COMOB ]
;   IN : d0 - Number of animation frames (.w)
;        a0 - Pointer to COMOB data (.l)
; All registers are restored
;*****************************************************************************
Wave_COMOB:
	move.l	d1,-(sp)
	cmp.w	#1,d0			; Just one frame ?
	beq.s	.Exit
	move.w	COMOB_Frame(a0),d1		; Get current frame
	btst	#COMOB_to_fro,COMOB_Flags(a0)	; Going back or forth ?
	beq.s	.Forth
	subq.w	#1,d1			; Back
	bne.s	.Ok			; First frame ?
	bclr	#COMOB_to_fro,COMOB_Flags(a0)	; Yes -> Forth next time
	bra.s	.Ok
.Forth:	addq.w	#1,d1			; Forth
	cmp.w	d0,d1			; Last frame ?
	bmi.s	.Ok
	subq.w	#2,d1			; Yes -> Go back
	bset	#COMOB_to_fro,COMOB_Flags(a0)
.Ok:	move.w	d1,COMOB_Frame(a0)		; Store new frame
.Exit:	bset	#COMOB_update,COMOB_Flags(a0)
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_BSS,bss
COMOBs_data:
COMOBs_blocked:	ds.b 1
Update_command:	ds.b 1
Complete_update:	ds.b 1
	even
Combat_anim_timer:	ds.w 1
Nr_COMOBs:	ds.w 1
New_nr_COMOBs:	ds.w 1
Nr_combat_CAs:	ds.w 1

COMOB_sort_list:	ds.l Max_COMOBs
COMOB_table:	ds.w Max_COMOBs*COMOB_data_size/2
	ds.w COMOB_data_size/2		; When table is full
Combat_CA_list:	ds.w Max_COMOBs*CA_data_size/2
COMOBs_data_size	EQU *-COMOBs_data
