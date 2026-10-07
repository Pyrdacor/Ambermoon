; Special effects
; Written by J.Horneman (In Tune With The Universe)
; Start : 8-2-1993

	XDEF	Drop_HDOB
	XDEF	Animate_HDOB
	XDEF	Vibrate_HDOB
	XDEF	Move_HDOB
	XDEF	Explode_bitmap

Explode_time	EQU 50

	rsreset
Pixel_eraseX:	rs.w 1
Pixel_eraseY:	rs.w 1
Pixel_erasecolour:	rs.w 1

	rsreset
Pixel_drawX:	rs.l 1
Pixel_drawY:	rs.l 1
Pixel_drawcolour:	rs.w 1
Pixel_erase1:	rs.w 3
Pixel_erase2:	rs.w 3
Pixel_dX:	rs.l 1
Pixel_dY:	rs.l 1
Pixel_gravity:	rs.l 1
Pixel_lifespan:	rs.w 1
Pixel_data_size:	rs.b 0

	SECTION	Program,code
;*****************************************************************************
; [ Drop HDOB ]
;   IN : a0 - HDOB address (.l)
; All registers are restored
; Notes :
;   - the HDOB must have been initialized and added.
;   - the HDOB's current position is used as the source position.
;*****************************************************************************
Drop_HDOB:
	movem.l	d0/d1/d4/d6/d7/a0/a1/a5,-(sp)
	lea.l	-Drop_HDOB_LDS(sp),sp	; Create local variables
	move.l	sp,a5
	moveq.l	#0,d0			; Store coordinates
	move.w	HDOB_drawX(a0),d0
	swap	d0
	opt	o2-				; (not optimized by the original assembler)
	move.l	d0,Drop_X(a5)
	opt	o2+
	move.w	HDOB_drawY(a0),d0
	swap	d0
	move.l	d0,Drop_Y(a5)
.Again1:	jsr	Random			; Get random vector
	move.w	d0,d1
	andi.w	#$0fff,d1
	subi.w	#14*256,d1
	jsr	Random
	andi.w	#$0fff,d0
	subi.w	#7*256+128,d0
	tst.w	d0			; Null vector ?
	bne.s	.Do
	tst.w	d1
	beq.s	.Again1			; Yes -> again
.Do:	ext.l	d0			; Scale vector
	ext.l	d1
	asl.l	#7,d0
	asl.l	#7,d1
	move.l	d0,Drop_dX(a5)
	move.l	d1,Drop_dY(a5)
	moveq.l	#0,d0			; Calculate gravity
	jsr	Random
	andi.l	#$00000fff,d0
	addi.l	#64000/2-2048,d0
	move.l	d0,Drop_gravity(a5)
	move.l	CA_Sp,a1			; Get CA
	move.l	(a1),a1
	move.w	CA_X1(a1),d4
	move.w	CA_X2(a1),d6
	move.w	CA_Y2(a1),d7
	opt	o2-				; (not optimized by the original assembler)
.Again2:	move.l	Drop_X(a5),d0		; Get coordinates
	opt	o2+
	move.l	Drop_Y(a5),d1
	add.l	Drop_dX(a5),d0		; Add vector
	add.l	Drop_dY(a5),d1
	swap	d0			; Clip
	swap	d1
	cmp.w	d4,d0			; X over left edge ?
	bmi	.End
	cmp.w	d6,d0			; X over right edge ?
	bgt	.End
	cmp.w	d7,d1			; Y over bottom edge ?
	bgt	.End
	move.w	d0,HDOB_drawX(a0)		; No -> store coordinates
	move.w	d1,HDOB_drawY(a0)
	swap	d0
	swap	d1
	opt	o2-				; (not optimized by the original assembler)
	move.l	d0,Drop_X(a5)
	opt	o2+
	move.l	d1,Drop_Y(a5)
	move.l	Drop_gravity(a5),d0		; Gravitate
	add.l	d0,Drop_dY(a5)
	jsr	Switch_screens		; Switch
	bra.s	.Again2
.End:	lea.l	Drop_HDOB_LDS(sp),sp	; Destroy local variables
	movem.l	(sp)+,d0/d1/d4/d6/d7/a0/a1/a5
	rts

	rsreset
Drop_X:	rs.l 1
Drop_Y:	rs.l 1
Drop_dX:	rs.l 1
Drop_dY:	rs.l 1
Drop_gravity:	rs.l 1
Drop_HDOB_LDS:	rs.b 0

;*****************************************************************************
; [ Animate HDOB ]
;   IN : d0 - Number of animation frames (.w)
;        d1 - Pause between animation frames (.w)
;        a0 - Address of first animation frame (.l)
;        a1 - HDOB address (.l)
; All registers are restored
; Notes :
;   - the HDOB must have been initialized and added.
;   - the HDOB's current position is used as the source position.
;*****************************************************************************
Animate_HDOB:
	movem.l	d0/d2/d7/a0,-(sp)
	move.w	d0,d7
	move.w	HDOB_width(a1),d2		; Calculate frame size
	mulu.w	HDOB_height(a1),d2
	mulu.w	HDOB_depth(a1),d2
	add.l	d2,d2
	bra.s	.Entry
.Loop:	jsr	Create_fake_handle		; Create fake handle
	move.b	d0,HDOB_gfx_handle(a1)	; Insert current frame
	jsr	Switch_screens		; Show
	jsr	Destroy_fake_handle		; Destroy handle
	move.w	d1,d0			; Wait
	jsr	Delay
	add.l	d2,a0			; Next frame
.Entry:	dbra	d7,.Loop
	movem.l	(sp)+,d0/d2/d7/a0
	rts

;*****************************************************************************
; [ Vibrate HDOB ]
;   IN : d0 - Number of vibrations (.w)
;        a0 - HDOB address (.l)
; All registers are restored
; Notes :
;   - the HDOB must have been initialized and added.
;   - the HDOB's current position is used as the source position.
;*****************************************************************************
Vibrate_HDOB:
	movem.l	d0/d1,-(sp)
	move.w	HDOB_drawX(a0),d1		; Get current X
	bra	.Entry
.Loop:	subq.w	#1,d1			; A little left
	move.w	d1,HDOB_drawX(a0)
	jsr	Switch_screens
	addq.w	#1,d1			; A little right
	move.w	d1,HDOB_drawX(a0)
	jsr	Switch_screens
	addq.w	#1,d1			; A little right
	move.w	d1,HDOB_drawX(a0)
	jsr	Switch_screens
	subq.w	#1,d1			; A little left
	move.w	d1,HDOB_drawX(a0)
	jsr	Switch_screens
.Entry:	dbra	d0,.Loop			; And again !
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Move HDOB ]
;   IN : d0 - Target X-coordinate (.w)
;        d1 - Target Y-coordinate (.w)
;        d2 - Movement speed (.w)
;        a0 - HDOB address (.l)
; All registers are restored
; Notes :
;   - the HDOB must have been initialized and added.
;   - the HDOB's current position is used as the source position.
;*****************************************************************************
Move_HDOB:
	movem.l	d0-d4,-(sp)
	move.w	d0,Target_X		; Save target coordinates
	move.w	d1,Target_Y
	move.w	d2,d4			; Save speed
	move.w	HDOB_drawX(a0),Source_X	; Get source coordinates
	move.w	HDOB_drawY(a0),Source_Y
.Again:	move.w	Target_X,d2		; Get target coordinates
	move.w	Target_Y,d3
	sub.w	Source_X,d2		; Calculate total vector
	sub.w	Source_Y,d3
	move.w	d2,d0
	move.w	d3,d1
	muls.w	d0,d0			; Calculate total length
	muls.w	d1,d1
	add.l	d1,d0
	tst.l	d0			; Zero ?
	beq	.End
	jsr	Square_root
	cmp.w	d0,d4			; Almost there ?
	bpl.s	.Skip			; Yes -> skip
	muls.w	d4,d2			; Calculate movement vector
	muls.w	d4,d3
	divs.w	d0,d2
	divs.w	d0,d3
.Skip:	add.w	d2,Source_X		; Calculate new coordinates
	add.w	d3,Source_Y
	move.w	Source_X,HDOB_drawX(a0)	; Set HDOB coordinates
	move.w	Source_Y,HDOB_drawY(a0)
	jsr	Switch_screens		; Again
	bra.s	.Again
.End:	movem.l	(sp)+,d0-d4
	rts

;*****************************************************************************
; [ Explode bitmap ]
;   IN : d0 - Left X-position (.w)
;        d1 - Top Y-position (.w)
;        d4 - Background colour (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Bitmap address (.l)
; All registers are restored
;*****************************************************************************
Explode_bitmap:
	movem.l	d0-d7/a0-a6,-(sp)
; ---------- Initialize data ----------------------
	move.w	d4,Background_colour	; Store
	move.l	d0,-(sp)			; Get pixel buffer
	move.w	d6,d0
	lsl.w	#4,d0
	mulu.w	d7,d0
	mulu.w	#Pixel_data_size,d0
	jsr	Allocate_memory
	jsr	Clear_memory
	move.b	d0,Pixelbuffer_handle
	move.l	(sp)+,d0
	Get	Pixelbuffer_handle,a1	; Convert bitmap
	jsr	Convert_bitmap
	tst.w	d0			; Any pixels ?
	beq	.Exit
	move.w	d0,Nr_of_pixels		; Store
	move.w	d0,Nr_of_real_pixels
	move.w	d0,d7			; Initialize pixel vectors
	subq.w	#1,d7
.Loop1:	jsr	Random			; Get random vector
	move.w	d0,d1
	andi.w	#$0fff,d1
	subi.w	#12*256,d1
	jsr	Random
	andi.w	#$0fff,d0
	subi.w	#8*256,d0
	tst.w	d0			; Null vector ?
	bne.s	.Do
	tst.w	d1
	beq.s	.Loop1			; Yes -> again
.Do:	ext.l	d0			; Scale vector
	ext.l	d1
	asl.l	#6,d0
	asl.l	#6,d1
	move.l	d0,Pixel_dX(a1)
	move.l	d1,Pixel_dY(a1)
	moveq.l	#0,d0			; Calculate gravity
	jsr	Random
	andi.l	#$00000fff,d0
	addi.l	#25000/2-2048,d0
	move.l	d0,Pixel_gravity(a1)
	jsr	Random			; Calculate lifespan
	andi.w	#$001f,d0
	move.w	d0,Pixel_lifespan(a1)
.Next1:	lea.l	Pixel_data_size(a1),a1	; Next pixel
	dbra	d7,.Loop1
	Free	Pixelbuffer_handle
; ---------- Display explosion --------------------
	jsr	Update_screen
	move.w	#Explode_time,d2
	move.l	CA_Sp,a0			; Get CA
	move.l	(a0),a0
	move.w	CA_X1(a0),d4
	move.w	CA_X2(a0),d6
	move.w	CA_Y2(a0),d7
	bra	.Entry
.Again:	tst.w	Nr_of_real_pixels		; Any pixels left ?
	beq	.Done
	tst.w	d2			; Time out ?
	beq	.Done
	Get	Pixelbuffer_handle,a0	; Update pixel positions
	move.w	Nr_of_pixels,d3
	subq.w	#1,d3
.Loop2:	tst.w	Pixel_drawcolour(a0)	; Something there ?
	bmi.s	.Next2			; No -> next
	subq.w	#1,Pixel_lifespan(a0)	; Age
	beq	.Kill
	move.l	Pixel_drawX(a0),d0		; Get coordinates
	move.l	Pixel_drawY(a0),d1
	add.l	Pixel_dX(a0),d0		; Add vector
	add.l	Pixel_dY(a0),d1
	swap	d0			; Clip
	swap	d1
	cmp.w	d4,d0			; X over left edge ?
	bmi	.Kill
	cmp.w	d6,d0			; X over right edge ?
	bgt	.Kill
	cmp.w	d7,d1			; Y over bottom edge ?
	bgt	.Kill
	swap	d0			; No -> store coordinates
	swap	d1
	move.l	d0,Pixel_drawX(a0)
	move.l	d1,Pixel_drawY(a0)
	move.l	Pixel_gravity(a0),d0	; Gravitate
	add.l	d0,Pixel_dY(a0)
	bra.s	.Next2
.Kill:	move.w	#-1,Pixel_drawcolour(a0)	; Kill pixel
	subq.w	#1,Nr_of_real_pixels
.Next2:	lea.l	Pixel_data_size(a0),a0	; Next pixel
	dbra	d3,.Loop2
	Free	Pixelbuffer_handle
.Entry:	jsr	Draw_pixels		; Draw
	jsr	Switch_screens		; Switch
	not.b	Pixel_switch
	jsr	Erase_pixels		; Erase
	subq.w	#1,d2			; Count down
	bra	.Again
.Done:	jsr	Switch_screens		; Switch
	not.b	Pixel_switch
	jsr	Erase_pixels		; Erase everything
	jsr	Update_screen
.Exit:	move.b	Pixelbuffer_handle,d0	; Destroy buffer
	jsr	Free_memory
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw pixels ]
; All registers are restored
;*****************************************************************************
Draw_pixels:
	movem.l	d0/d1/d4/d6/d7/a0/a1,-(sp)
	moveq.l	#Pixel_erase1,d6		; Get erase info offset
	tst.b	Pixel_switch
	bne.s	.Ok
	moveq.l	#Pixel_erase2,d6
.Ok:	Get	Pixelbuffer_handle,a1
; ---------- Save old pixels ----------------------
	move.l	a1,a0			; For all pixels
	move.w	Nr_of_pixels,d7
	subq.w	#1,d7
.Loop1:	tst.w	Pixel_drawcolour(a0)	; Something there ?
	bmi.s	.Next1			; No -> next
	move.w	Pixel_drawX(a0),d0		; Get pixel
	move.w	Pixel_drawY(a0),d1
	jsr	Get_pixel
	move.w	d0,Pixel_eraseX(a0,d6.w)	; Store erase info
	move.w	d1,Pixel_eraseY(a0,d6.w)
	move.w	d4,Pixel_erasecolour(a0,d6.w)
.Next1:	lea.l	Pixel_data_size(a0),a0	; Next pixel
	dbra	d7,.Loop1
; ---------- Set new pixels -----------------------
	move.l	a1,a0			; For all pixels
	move.w	Nr_of_pixels,d7
	subq.w	#1,d7
.Loop2:	move.w	Pixel_drawcolour(a0),d4	; Something there ?
	bmi.s	.Next2			; No -> next
	move.w	Pixel_drawX(a0),d0		; Plot pixel
	move.w	Pixel_drawY(a0),d1
	jsr	Plot_pixel
.Next2:	lea.l	Pixel_data_size(a0),a0	; Next pixel
	dbra	d7,.Loop2
	Free	Pixelbuffer_handle
	movem.l	(sp)+,d0/d1/d4/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Erase pixels ]
; All registers are restored
;*****************************************************************************
Erase_pixels:
	movem.l	d0/d1/d4/d6/d7/a0/a1,-(sp)
	moveq.l	#Pixel_erase1,d6		; Get erase info offset
	tst.b	Pixel_switch
	bne.s	.Ok
	moveq.l	#Pixel_erase2,d6
.Ok:	Get	Pixelbuffer_handle,a0
	move.w	Nr_of_pixels,d7		; For all pixels
	subq.w	#1,d7
.Loop:	tst.w	Pixel_erasecolour(a0,d6.w)	; Something there ?
	bmi.s	.Next
	move.w	Pixel_eraseX(a0,d6.w),d0	; Restore pixel
	move.w	Pixel_eraseY(a0,d6.w),d1
	move.w	Pixel_erasecolour(a0,d6.w),d4
	jsr	Plot_pixel
	tst.w	Pixel_drawcolour(a0)	; Killed ?
	bpl.s	.Next
	move.w	#-1,Pixel_erasecolour(a0,d6.w)	; Kill
.Next:	lea.l	Pixel_data_size(a0),a0	; Next pixel
	dbra	d7,.Loop
	Free	Pixelbuffer_handle
	movem.l	(sp)+,d0/d1/d4/d6/d7/a0/a1
	rts

;*****************************************************************************
; [ Convert bitmap to pixel list ]
;   IN : d0 - Left X-coordinate (.w)
;        d1 - Top Y-coordinate (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to bitmap (.l)
;        a1 - Pointer to pixel list (.l)
;  OUT : d0 - Number of pixels converted (.w)
; Changed registers : d0
; Notes :
;  - This routine will convert {Screen_depth} bitplanes.
;*****************************************************************************
Convert_bitmap:     
	movem.l	d1/d3-d7/a0-a3,-(sp)
	lea.l	Pixel_buffer,a2
	move.l	a0,a3
	move.w	d0,d2
	move.w	d6,d3
	mulu.w	#Screen_depth*2,d3
	moveq.l	#0,d4
	subq.w	#1,d7
.Loop1:	move.l	a3,a0			; Do line
	move.w	d2,d0
	move.w	d6,d5
	subq.w	#1,d5
.Loop2:	jsr	Convert_trunc		; Do trunc
	jsr	Insert_pixels
	addi.w	#16,d0			; Next trunc
	addq.l	#2,a0
	dbra	d5,.Loop2
	addq.w	#1,d1			; Next line
	add.l	d3,a3
	dbra	d7,.Loop1
	move.w	d4,d0			; Copy to output
	movem.l	(sp)+,d1/d3-d7/a0-a3
	rts

	FINGERPRINT

;*****************************************************************************
; [ Convert trunc to pixels ]
;   IN : d6 - Width of bitmap in truncs (.w)
;        a0 - Pointer to bitmap (.l)
;        a2 - Pointer to pixel buffer (.l)
; All registers are restored
; Notes :
;  - This routine will convert {Screen_depth} bitplanes.
;*****************************************************************************
Convert_trunc:     
	movem.l	d0-d6/a0,-(sp)
	add.w	d6,d6			; Load one trunc
	move.w	(a0),d0
	add.w	d6,a0
	move.w	(a0),d1
	add.w	d6,a0
	move.w	(a0),d2
	add.w	d6,a0
	move.w	(a0),d3
	add.w	d6,a0
	move.w	(a0),d4
	move.l	a2,a0			; Do 16 pixels
	moveq.l	#16-1,d6
.Loop:	moveq.l	#0,d5			; Convert one pixel
	add.w	d4,d4
	addx.w	d5,d5
	add.w	d3,d3
	addx.w	d5,d5
	add.w	d2,d2
	addx.w	d5,d5
	add.w	d1,d1
	addx.w	d5,d5
	add.w	d0,d0
	addx.w	d5,d5
	move.b	d5,(a0)+			; Store pixel
	dbra	d6,.Loop			; Next pixel
	movem.l	(sp)+,d0-d6/a0
	rts

;*****************************************************************************
; [ Insert one trunc of pixels in list ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Pixel counter (.w)
;        a1 - Pointer to pixel list (.l)
;        a2 - Pointer to pixel buffer (.l)
;  OUT : d4 - Updated pixel counter (.w)
;        a1 - Updated pointer to pixel list (.l)
; Changed registers : d4,a1
;*****************************************************************************
Insert_pixels:     
	movem.l	d0/d2/d7/a2,-(sp)
	move.w	Background_colour,d2	; Insert pixels
	moveq.l	#16-1,d7
.Loop:	cmp.b	(a2),d2			; Background colour ?
	beq.s	.Next
	move.w	d0,Pixel_drawX(a1)		; Enter pixel in list
	move.w	d1,Pixel_drawY(a1)
	move.b	(a2),Pixel_drawcolour+1(a1)
	lea.l	Pixel_data_size(a1),a1
	addq.w	#1,d4			; Count
.Next:	addq.l	#1,a2			; Next pixel
	addq.w	#1,d0
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d2/d7/a2
	rts

;	movem.l	d0/d2/d7/a2,-(sp)
;	btst	#0,d1			; Odd or even ?
;	beq.s	.Even
;	addq.w	#1,d0			; Chessboard
;	addq.l	#1,a2
;.Even:	move.w	Background_colour,d2	; Insert pixels
;	moveq.l	#8-1,d7
;.Loop:	cmp.b	(a2),d2			; Background colour ?
;	beq.s	.Next
;	move.w	d0,Pixel_drawX(a1)		; Enter pixel in list
;	move.w	d1,Pixel_drawY(a1)
;	move.b	(a2),Pixel_drawcolour+1(a1)
;	lea.l	Pixel_data_size(a1),a1
;	addq.w	#1,d4			; Count
;.Next:	addq.l	#2,a2			; Next pixel
;	addq.w	#2,d0
;	dbra	d7,.Loop
;	movem.l	(sp)+,d0/d2/d7/a2
;	rts

;***************************************************************************	
; The DATA & BSS segments	
;***************************************************************************
	SECTION	Fast_BSS,BSS
Target_X:	ds.w 1
Target_Y:	ds.w 1
Source_X:	ds.w 1
Source_Y:	ds.w 1

Pixel_switch:	ds.b 1
Pixelbuffer_handle:	ds.b 1
	even
Nr_of_pixels:	ds.w 1
Nr_of_real_pixels:	ds.w 1
Background_colour:	ds.w 1
