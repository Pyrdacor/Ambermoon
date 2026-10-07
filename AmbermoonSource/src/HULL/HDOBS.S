; Hand-Draw OBject (HDOB) routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 14-9-1992

; NOTES :
;  - A HDOBs dimensions may not be changed once it has been inserted in the
;    list because a memory block (for the background) has already
;    been allocated using the original dimensions.
;  - The background memory handle will be set by [ Add_HDOB ].
;  - When changing the entire screen (i.e. clearing it or building a new
;    screen), one must clear all HDOBs by calling [ Reset_HDOBs ].
;  - Do not change the CA while HDOBs are being displayed.

	XDEF	Hide_HDOBs
	XDEF	Show_HDOBs
	XDEF	Reset_HDOBs
	XDEF	Add_HDOB
	XDEF	Remove_HDOB
	XDEF	Clear_all_HDOBs

	SECTION	Program,code
;***************************************************************************
; [ Hide all HDOBs ]
; All registers are restored
;***************************************************************************
Hide_HDOBs:
	cmpi.b	#-1,Suppress_drawing	; At maximum ?
	beq.s	.Exit
	addq.b	#1,Suppress_drawing		; Increase flag
.Exit:	rts

;***************************************************************************
; [ Show all HDOBs ]
; All registers are restored
;***************************************************************************
Show_HDOBs:
	tst.b	Suppress_drawing		; Already	on ?
	beq.s	.Exit
	subq.b	#1,Suppress_drawing		; Decrease flag
.Exit:	rts

;*****************************************************************************
; [ Reset the HDOB state ]
; All registers are	restored
;*****************************************************************************
Reset_HDOBs:
	clr.b	Suppress_drawing		; Turn it on
	rts
	
;***************************************************************************
; [ Add a HDOB ]
;   IN : a0 - Pointer to HDOB (.l)
; All registers are restored
;***************************************************************************
Add_HDOB:
	movem.l	d0-d2/d5-d7/a1,-(sp)
	lea.l	HDOB_list,a1		; Search free entry
	moveq.l	#Max_HDOBs-1,d2
.Loop:	tst.l	(a1)+			; Free ?
	bne.s	.Next
	move.l	a0,-4(a1)			; Insert
	clr.b	HDOB_screen1+HDOB_bg_handle(a0)
	clr.b	HDOB_screen2+HDOB_bg_handle(a0)
	bra.s	.Exit
.Next:	dbra	d2,.Loop			; Next
	; NO FREE ENTRY !
.Exit:	movem.l	(sp)+,d0-d2/d5-d7/a1
	rts

;***************************************************************************
; [ Remove a HDOB ]
;   IN : a0 - Pointer to HDOB (.l)
; All registers are restored
;***************************************************************************
Remove_HDOB:
	clr.b	HDOB_gfx_handle(a0)		; Clear graphics handle
	clr.l	HDOB_offset(a0)
	rts

;***************************************************************************
; [ Clear all HDOBs ]
; All registers are restored
;***************************************************************************
Clear_all_HDOBs:
	movem.l	d0/d7/a0/a1,-(sp)
	lea.l	HDOB_list,a0		; For all HDOBs
	moveq.l	#Max_HDOBs-1,d7
.Loop:	move.l	(a0)+,d0			; Something there ?
	beq.s	.Next			; No -> next
	clr.l	-4(a0)			; Destroy entry
	move.l	d0,a1
	move.b	HDOB_screen1+HDOB_bg_handle(a1),d0	; Destroy background buffer
	jsr	Free_memory
	move.b	HDOB_screen2+HDOB_bg_handle(a1),d0
	jsr	Free_memory
	clr.l	HDOB_offset(a1)
.Next:	dbra	d7,.Loop			; Next HDOB
	jsr	Reset_HDOBs		; Activate
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;***************************************************************************
; [ Draw all HDOBs ]
; All registers are restored
;***************************************************************************
Draw_HDOBs:
	movem.l	d0-d7/a0-a3,-(sp)
	moveq.l	#HDOB_screen1,d3		; Get erase info offset
	tst.b	Screen_flag
	bne.s	.Ok
	moveq.l	#HDOB_screen2,d3
; ---------- Save backgrounds ---------------------
.Ok:	lea.l	HDOB_list,a1		; For all HDOBs
	moveq.l	#Max_HDOBs-1,d2
.Loop1:	move.l	(a1)+,d0			; Something there ?
	beq.s	.Next1			; No -> next
	move.l	d0,a2
	lea.l	0(a2,d3.w),a3
	tst.b	HDOB_gfx_handle(a2)		; Do ?
	beq.s	.Next1
	move.b	HDOB_bg_handle(a3),d0	; Get background buffer address
	bne.s	.Do
	move.w	HDOB_width(a2),d0		; Create background buffer
	addq.w	#1,d0
	add.w	d0,d0
	mulu.w	HDOB_height(a2),d0
	mulu.w	#Screen_depth,d0
	jsr	Allocate_CHIP
	move.b	d0,HDOB_bg_handle(a3)	; Store handle
.Do:	jsr	Claim_pointer
	move.l	d0,a0
	move.w	HDOB_drawX(a2),d0		; Save background
	move.w	HDOB_drawY(a2),d1
	moveq.l	#Screen_depth,d5
	move.w	HDOB_width(a2),d6
	addq.w	#1,d6
	move.w	HDOB_height(a2),d7
	jsr	Get_block
	move.w	d0,HDOB_oldX(a3)		; Store restore coordinates
	move.w	d1,HDOB_oldY(a3)
	move.b	HDOB_bg_handle(a3),d0	; Free pointer
	jsr	Free_pointer
.Next1:	dbra	d2,.Loop1			; Next HDOB
; ---------- Draw HDOBs ---------------------------
	tst.b	Suppress_drawing		; Suppressed ?
	bne	.Exit
	lea.l	HDOB_list,a1		; For all HDOBs
	moveq.l	#Max_HDOBs-1,d2
.Loop2:	move.l	(a1)+,d0			; Something there ?
	beq.s	.Next2			; No -> next
	move.l	d0,a2
	lea.l	0(a2,d3.w),a3
	move.b	HDOB_gfx_handle(a2),d0	; Do ?
	beq	.Next2
	jsr	Claim_pointer		; Get graphics address
	move.l	d0,a0
	add.l	HDOB_offset(a2),a0
	movem.l	d2/d3,-(sp)
	move.w	HDOB_drawX(a2),d0		; Get coordinates
	move.w	HDOB_drawY(a2),d1
	move.w	HDOB_width(a2),d6		; Get dimensions
	move.w	HDOB_height(a2),d7
	tst.b	HDOB_flag(a2)		; Mask or block ?
	beq.s	.Mask
	move.w	d6,d2			; Clear area
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d1,d3
	add.w	d7,d3
	subq.w	#1,d3
	moveq.l	#0,d4
	jsr	Draw_box
.Mask:	move.w	HDOB_base_colour(a2),d4	; Draw block
	move.w	HDOB_depth(a2),d5
	jsr	Put_masked_block2
	movem.l	(sp)+,d2/d3
	move.b	HDOB_gfx_handle(a2),d0	; Free pointer
	jsr	Free_pointer
.Next2:	dbra	d2,.Loop2			; Next HDOB
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;***************************************************************************
; [ Erase all HDOBs ]
; All registers are restored
;***************************************************************************
Erase_HDOBs:
	movem.l	d0-d7/a0-a3,-(sp)
	moveq.l	#HDOB_screen1,d3		; Get erase info offset
	tst.b	Screen_flag
	bne.s	.Ok
	moveq.l	#HDOB_screen2,d3
; ---------- Restore backgrounds ------------------
.Ok:	lea.l	HDOB_list,a1		; For all HDOBs
	moveq.l	#Max_HDOBs-1,d2
.Loop:	move.l	(a1)+,d0			; Something there ?
	beq.s	.Next			; No -> next
	move.l	d0,a2
	lea.l	0(a2,d3.w),a3
	move.b	HDOB_bg_handle(a3),d0	; Get background buffer address
	beq.s	.Next
	jsr	Claim_pointer
	move.l	d0,a0
	move.w	HDOB_oldX(a3),d0		; Restore background
	move.w	HDOB_oldY(a3),d1
	moveq.l	#Screen_depth,d5
	move.w	HDOB_width(a2),d6
	addq.w	#1,d6
	move.w	HDOB_height(a2),d7
	jsr	Put_unmasked_block
	move.b	HDOB_bg_handle(a3),d0	; Free pointer
	jsr	Free_pointer
	tst.b	HDOB_gfx_handle(a2)		; Destroy ?
	bne.s	.Next
	move.b	HDOB_screen1+HDOB_bg_handle(a2),d0	; Destroy background buffer
	jsr	Free_memory
	move.b	HDOB_screen2+HDOB_bg_handle(a2),d0
	jsr	Free_memory
	clr.l	-4(a1)			; Destroy entry
.Next:	dbra	d2,.Loop			; Next HDOB
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_BSS,bss
Suppress_drawing:	ds.b 1
	even
HDOB_list:	ds.l Max_HDOBs
