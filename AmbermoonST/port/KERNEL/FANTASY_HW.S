; ST kernel : the hardware of the fairy of Thalion (FANTASY.S)
; (The Falcon version has its own FANTASY_HW.S.)
;
; FANTASY.S is the code of the Amiga program Fantasy_intro : its logic (the way
; of the fairy, her dust, the lettering and its sparkles) runs as it is, but the
; ST draws itself, straight into its screen, with data in the format of the ST
; screen (port/tools/fantasy_st.py : [ Fst_picture ] ...) :
;   - The picture is put into both screens once ([ Fantasy_new_picture ]).
;   - The lower part (the lettering) is copied from the picture in every
;     frame ([ Fantasy_draw_lower ]); the lettering is uncovered in the
;     picture ([ Fantasy_draw_reveal ]). The dust in the upper part is put
;     back from the picture too (a list per screen : [ Fantasy_dirty ]) : it
;     leaves no trail.
;   - The sparkles and the small sparkles of the dust are shifted in advance
;     (16 shifts), the dust is drawn pixel by pixel in the ST colours
;     ([ Fairy_dust ]).
;   - The fairy (sprites on the Amiga) is drawn into the screen before it is
;     shown (with the blitter of the STE), the background under her is kept;
;     before the screen is drawn again (when the other one is shown) she is
;     taken out of it.
;   - The lines above [ Fantasy_split ] have 16 colours, the lines from there
;     on 16 others (a raster event); the ST shows the lines from
;     [ Fantasy_top ] on.
; The routines Fantasy_draw_* return with Z set : the code of the Amiga does
; not draw then (the Falcon returns with Z clear).

Fantasy_split	EQU	134		; The line of the colour change
Fantasy_top	EQU	21		; The first line which is shown
Fairy_width	EQU	4		; (chunks)
Fairy_lines	EQU	71
Fairy_frame_size	EQU	Fairy_lines*Fairy_width*10	; (mask and 4 planes per chunk)
Fairy_save_size	EQU	Fairy_lines*5*8
Lower_lines	EQU	Fantasy_top+Screen_height-Fantasy_split	; (shown)
Letters_line	EQU	12		; (in the lower part)
Letters_lines	EQU	Lower_lines-Letters_line
Letters_chunk	EQU	4
Fairy_save_data	EQU	8		; (lines, screen, chunks)
Fairy_save_record	EQU	Fairy_save_data+Fairy_save_size
Dirty_list	EQU	4*1500

	SECTION	Program,code

;*****************************************************************************
; [ Take over the screens, start the interrupt ]
; All registers are restored
;*****************************************************************************
Fantasy_init:
	movem.l	d0/d1/a0,-(sp)
	jsr	Intro_init
	move.w	#256,d0
	moveq.l	#5,d1
	jsr	Intro_video
	move.w	#Fantasy_top,Intro_top
	jsr	Intro_clear
	move.l	On_screen,Fantasy_game_screens	; Three screens : one is drawn
	move.l	Off_screen,Fantasy_game_screens+4	;  while the others are shown or
	move.l	On_screen,Fantasy_screens		;  wait to be shown (no wait)
	move.l	Off_screen,Fantasy_screens+4
	move.l	#Star_cache+255,d0		; (the third one : in the memory of
	andi.w	#$ff00,d0			;  the intro)
	move.l	d0,Fantasy_screens+8
	clr.w	Fant_h2+$d0
	sf	Fantasy_visible
	clr.w	Fantasy_saves		; (no fairy in the screens)
	clr.w	Fantasy_saves+Fairy_save_record
	clr.w	Fantasy_saves+2*Fairy_save_record
	clr.l	Fantasy_dirty		; (no dust)
	clr.l	Fantasy_dirty_ends
	clr.l	Fantasy_dirty_ends+4
	clr.l	Fantasy_dirty_ends+8
	lea.l	Fantasy_line_offsets,a0	; (the offsets of the lines)
	moveq.l	#0,d0
	move.w	#Screen_height-1,d1
.Lines:	move.w	d0,(a0)+
	add.w	#Screen_bytes_per_line,d0
	dbra	d1,.Lines
	lea.l	F00d88,a0
	move.l	a0,VBL_hook
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Give the screens back ]
; All registers are restored
;*****************************************************************************
Fantasy_exit:
	move.l	a0,-(sp)
	move.l	Fantasy_game_screens,a0	; (the screens of the game again)
	move.l	a0,On_screen
	move.l	a0,Shown_screen
	jsr	Set_video_base
	move.l	Fantasy_game_screens+4,Off_screen
	move.l	Fantasy_game_screens+4,Work_screen
	move.l	(sp)+,a0
	jmp	Intro_exit

;*****************************************************************************
; [ The picture is there ] (the code of the Amiga put it into its screens)
; All registers are restored
;*****************************************************************************
Fantasy_new_picture:
	movem.l	d6/d7/a0-a2,-(sp)
	lea.l	Fantasy_screens,a2
	moveq.l	#3-1,d6
.Screen:	lea.l	Fst_picture,a0
	move.l	(a2)+,a1
	bsr.s	.Copy
	dbra	d6,.Screen
	clr.w	Fantasy_saves
	clr.w	Fantasy_saves+Fairy_save_record
	clr.w	Fantasy_saves+2*Fairy_save_record
	movem.l	(sp)+,d6/d7/a0-a2
	rts
.Copy:	move.w	#Screen_size/4-1,d7
.Long:	move.l	(a0)+,(a1)+
	dbra	d7,.Long
	rts

;*****************************************************************************
; [ Show the screen ] (the copper list on the Amiga)
; All registers are restored
; NOTE :
;   - The fairy is drawn into it. It is shown with the next vertical blank;
;     the next one drawn is the third screen (neither shown nor waiting).
;*****************************************************************************
Fantasy_present:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Intro_wait_shown		; (the one before is shown)
	tst.b	Fantasy_visible		; The fairy into it
	beq.s	.Show
	move.l	Off_screen,a1
	jsr	Fantasy_save_record
	jsr	Fantasy_fairy
.Show:	jsr	Fantasy_dirty_shown
	move.l	Off_screen,a0		; Show it
	move.l	a0,Shown_screen
	jsr	Set_video_base
	move.w	VBL_counter,Intro_shown_vbl
	lea.l	Fantasy_screens,a1		; The next one : the third
.Find:	move.l	(a1)+,d0
	cmp.l	On_screen,d0
	beq.s	.Find
	cmp.l	a0,d0
	beq.s	.Find
	move.l	a0,On_screen
	move.l	d0,Off_screen
	move.l	d0,Work_screen
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ The end of the vertical blank ] (F0100c)
; NOTE :
;   - Nothing : the fairy in every vertical blank (like the sprites of the
;     Amiga) took half of the time of the 68000 (the background under her).
;*****************************************************************************
Fantasy_vbl:
	rts

; [ The record of the background under the fairy of a screen ]
;   IN : a1 - Pointer to the screen (.l)
;  OUT : a5 - Pointer to its record (.l)
; Changed registers : a5
Fantasy_save_record:
	lea.l	Fantasy_saves,a5
	cmp.l	Fantasy_screens,a1
	beq.s	.Exit
	lea.l	Fairy_save_record(a5),a5
	cmp.l	Fantasy_screens+4,a1
	beq.s	.Exit
	lea.l	Fairy_save_record(a5),a5
.Exit:	rts

; [ The number of a screen ] (0-2, times 4)
;   IN : a1 - Pointer to the screen (.l)
;  OUT : d0 - Number * 4 (.w)
; Changed registers : d0
Fantasy_screen_number:
	moveq.l	#0,d0
	cmp.l	Fantasy_screens,a1
	beq.s	.Exit
	moveq.l	#4,d0
	cmp.l	Fantasy_screens+4,a1
	beq.s	.Exit
	moveq.l	#8,d0
.Exit:	rts

; [ Put the background under the fairy back ]
;   IN : a5 - Pointer to the record (.l)
; Changed registers : d0, d1, d7, a0, a2, a3
Fantasy_restore:
	move.w	(a5),d7			; Lines
	beq.s	.Exit
	clr.w	(a5)
	move.l	2(a5),a2			; Screen
	move.w	6(a5),d1			; Chunks
	lea.l	Fairy_save_data(a5),a0
	subq.w	#1,d7
.Line:	move.l	a2,a3
	move.w	d1,d0
	subq.w	#1,d0
.Chunk:	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	dbra	d0,.Chunk
	lea.l	Screen_bytes_per_line(a2),a2
	dbra	d7,.Line
.Exit:	rts

;*****************************************************************************
; [ Draw the fairy into the screen ]
;   IN : a1 - Pointer to the screen (.l)
;        a5 - Pointer to the record of its background (.l)
; Changed registers : d0-d7, a0, a2-a4, a6
; NOTE :
;   - [ Fst_fairy ] : per frame the data of the upper colours and of the lower
;     colours, per line 4 chunks of mask and 4 planes. Above
;     [ Fantasy_split ] the upper colours, from there on the lower ones.
;*****************************************************************************
Fantasy_fairy:
	lea.l	Fst_fairy,a0		; The frame
	move.w	Fant_h2+$bc,d0
	mulu.w	#2*Fairy_frame_size,d0
	add.l	d0,a0
	move.w	Fant_h2+$c8,d2		; X (the sprites start one pixel left)
	subq.w	#1,d2
	asr.w	#4,d2			; (the chunk)
	move.w	Fant_h2+$ca,d0		; Clip the lines
	sub.w	#Fantasy_top,d0
	moveq.l	#Fairy_lines,d6
	tst.w	d0
	bpl.s	.Top
	add.w	d0,d6			; (above the screen)
	neg.w	d0
	mulu.w	#Fairy_width*10,d0
	add.l	d0,a0
	moveq.l	#0,d0
.Top:	move.w	#Screen_height,d1
	sub.w	d0,d1
	cmp.w	d1,d6
	ble.s	.Lines
	move.w	d1,d6
.Lines:	tst.w	d6
	ble	.Exit
	move.w	d0,Fantasy_line
	cmp.w	#Fantasy_split-Fantasy_top,d0	; Below the colour change ?
	blt.s	.Upper
	lea.l	Fairy_frame_size(a0),a0
.Upper:	mulu.w	#Screen_bytes_per_line,d0
	lea.l	0(a1,d0.l),a6
	move.w	d2,d3			; The chunks which are kept : from the
	bpl.s	.Left			;  first one (in the screen) on, 5
	moveq.l	#0,d3
.Left:	move.w	d2,d4
	addq.w	#5,d4
	cmp.w	#20,d4
	ble.s	.Right
	moveq.l	#20,d4
.Right:	sub.w	d3,d4
	ble	.Exit
	move.w	d6,(a5)			; Keep the background
	move.w	d3,d0
	lsl.w	#3,d0
	pea	0(a6,d0.w)
	move.l	(sp)+,2(a5)
	move.w	d4,6(a5)
	move.l	2(a5),a2
	lea.l	Fairy_save_data(a5),a3
	move.w	d6,d1
	subq.w	#1,d1
.Save:	move.l	a2,a4
	move.w	d4,d0
	subq.w	#1,d0
.Save_c:	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	dbra	d0,.Save_c
	lea.l	Screen_bytes_per_line(a2),a2
	dbra	d1,.Save
	move.w	Fant_h2+$c8,d0		; X (the sprites start one pixel left)
	subq.w	#1,d0
	move.w	#Fantasy_split-Fantasy_top,d1	; Lines above the colour change
	sub.w	Fantasy_line,d1
	ble.s	.One
	cmp.w	d6,d1
	bge.s	.One
	movem.l	d0/d1/d6/a0/a6,-(sp)	; Two parts : the lower one with the
	move.w	d1,d6			;  data of the lower colours
	moveq.l	#Fairy_width,d5
	bsr	St_sprite
	movem.l	(sp)+,d0/d1/d6/a0/a6
	sub.w	d1,d6
	move.w	d1,d2
	mulu.w	#Fairy_width*10,d2
	add.l	d2,a0
	lea.l	Fairy_frame_size(a0),a0
	mulu.w	#Screen_bytes_per_line,d1
	add.l	d1,a6
.One:	moveq.l	#Fairy_width,d5
	bra	St_sprite
.Exit:	rts

;*****************************************************************************
; [ Draw a sprite with a mask ] (clipped at the left and the right edge)
;   IN : d0 - X (also outside the screen) (.w)
;        d5 - Chunks of a line of the sprite (.w)
;        d6 - Lines (> 0) (.w)
;        a0 - Pointer to the first line of the sprite : per chunk the mask
;             and 4 planes (.l)
;        a6 - Pointer to the line in the screen (.l)
; Changed registers : d0-d7, a0, a2-a4, a6
; NOTE :
;   - With the blitter of the STE : for each plane D = D & !mask, then
;     D = D | plane (the source : every fifth word). The chunks are one more
;     in the screen when they are shifted : the last word is not read (NFSR),
;     the masks of the destination take the bits. At the left edge the first
;     chunks are not drawn : the word before the first one drawn is read
;     first (FXSR); at the right edge the last ones are not drawn.
;*****************************************************************************
St_sprite:
	moveq.l	#15,d1			; Shift and chunk
	and.w	d0,d1
	move.w	d0,d2
	asr.w	#4,d2
	move.w	d5,Fb_width
	move.w	d5,d0
	mulu.w	#10,d0
	move.w	d0,Fb_line
	tst.b	Bl_hardware		; The blitter of the STE ?
	beq	St_sprite_cpu
	moveq.l	#-1,d7			; (the bits of the word itself)
	lsr.w	d1,d7
	move.w	d5,d3			; d3 : chunks, d4 : first source chunk
	addq.w	#1,d3
	moveq.l	#0,d4
	move.w	#-1,Fb_middle
	tst.w	d2
	bpl.s	.Not_left
	add.w	d2,d3			; Left edge
	ble	.Exit
	move.w	d2,d4
	not.w	d4			; (-chunk-1)
	moveq.l	#0,d2
	ori.b	#$c0,d1			; (FXSR, NFSR)
	move.w	#-1,Fb_first
	move.w	d7,Fb_last
	not.w	Fb_last
	cmp.w	#1,d3			; (one word : the mask of the last one,
	bne.s	.Set			;  without NFSR : with FXSR and NFSR one
	move.w	Fb_last,Fb_first		;  word has no Y increment)
	andi.b	#$bf,d1
	bra.s	.Set
.Not_left:	move.w	#20,d0			; Right edge ?
	sub.w	d2,d0
	ble	.Exit
	cmp.w	d3,d0
	bge.s	.Middle
	move.w	d0,d3			; (the last chunks are not drawn)
	move.w	d7,Fb_first
	move.w	#-1,Fb_last
	bra.s	.Set
.Middle:	ori.b	#$40,d1			; (NFSR)
	move.w	d7,Fb_first
	move.w	d7,Fb_last
	not.w	Fb_last
.Set:	move.w	d3,d0			; Source reads per line
	btst	#7,d1
	beq.s	.No_fxsr
	addq.w	#1,d0
.No_fxsr:	btst	#6,d1
	beq.s	.No_nfsr
	subq.w	#1,d0
.No_nfsr:	subq.w	#1,d0			; Y increments : to the next line of the
	mulu.w	#10,d0			;  source
	neg.w	d0
	add.w	Fb_line,d0
	move.w	d0,Fb_source_y
	move.w	d3,d0
	subq.w	#1,d0
	lsl.w	#3,d0
	neg.w	d0
	add.w	#Screen_bytes_per_line,d0
	move.w	d0,Fb_dest_y
	mulu.w	#10,d4			; The first source chunk
	add.l	d4,a0
	lsl.w	#3,d2			; The first chunk
	add.w	d2,a6
	lea.l	STB_registers,a4
	move.w	#10,(a4)			; Source X & Y increment
	move.w	Fb_source_y,2(a4)
	move.w	Fb_first,8(a4)		; Masks
	move.w	Fb_middle,10(a4)
	move.w	Fb_last,12(a4)
	move.w	#8,14(a4)			; Destination X & Y increment
	move.w	Fb_dest_y,16(a4)
	move.w	d3,d5
	move.l	a0,a2
	move.l	a6,a3
	moveq.l	#4-1,d4			; The planes
.Plane:	move.l	a0,4(a4)			; D = D & !mask
	move.l	a3,18(a4)
	move.w	d5,22(a4)
	move.w	d6,24(a4)
	move.w	#$0204,26(a4)
	move.b	d1,29(a4)
	bsr.s	.Start
	addq.l	#2,a2			; D = D | plane
	move.l	a2,4(a4)
	move.l	a3,18(a4)
	move.w	d5,22(a4)
	move.w	d6,24(a4)
	move.w	#$0207,26(a4)
	move.b	d1,29(a4)
	bsr.s	.Start
	addq.l	#2,a3
	dbra	d4,.Plane
.Exit:	rts
.Start:	move.b	#$80,28(a4)		; (without HOG)
.Wait:	bset.b	#7,28(a4)
	nop
	bne.s	.Wait
	rts

; The same with the processor (d1 : shift, d2 : chunk)
St_sprite_cpu:
	move.w	d1,Fb_shift
	move.w	d2,Fb_chunk
	subq.w	#1,d6
.Line:	move.w	Fb_chunk,d7
	move.w	Fb_width,d5
	subq.w	#1,d5
.Chunk:	movem.w	(a0)+,d0-d4		; Mask and planes
	tst.w	d0			; Anything ?
	beq.s	.Skip
	swap	d0			; Up, then to the right
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	clr.w	d0
	clr.w	d1
	clr.w	d2
	clr.w	d3
	clr.w	d4
	move.w	d5,-(sp)
	move.w	Fb_shift,d5
	lsr.l	d5,d0
	lsr.l	d5,d1
	lsr.l	d5,d2
	lsr.l	d5,d3
	lsr.l	d5,d4
	move.w	(sp)+,d5
	swap	d0			; The left chunk
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	bsr.s	.Put
	addq.w	#1,d7
	swap	d0			; The right chunk
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	bsr.s	.Put
	bra.s	.Next
.Skip:	addq.w	#1,d7
.Next:	dbra	d5,.Chunk
	lea.l	Screen_bytes_per_line(a6),a6
	dbra	d6,.Line
	rts
; The mask d0 and the planes d1-d4 into the chunk d7 of the line a6
.Put:	cmp.w	#20,d7
	bcc.s	.Out
	move.w	d7,-(sp)
	lsl.w	#3,d7
	lea.l	0(a6,d7.w),a4
	move.w	d0,d7
	not.w	d7
	and.w	d7,(a4)
	or.w	d1,(a4)+
	and.w	d7,(a4)
	or.w	d2,(a4)+
	and.w	d7,(a4)
	or.w	d3,(a4)+
	and.w	d7,(a4)
	or.w	d4,(a4)
	move.w	(sp)+,d7
.Out:	rts
;*****************************************************************************
; [ The lower part of the screen ] (F00bc0 : its background with the lettering)
;  OUT : Z set
; All registers are restored
;*****************************************************************************
Fantasy_draw_lower:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Off_screen,a1		; The fairy out of it
	jsr	Fantasy_save_record
	jsr	Fantasy_restore
	jsr	Fantasy_restore_dirty
	lea.l	Fst_picture+(Fantasy_split-Fantasy_top)*Screen_bytes_per_line,a0
	move.l	Off_screen,a1
	add.l	#(Fantasy_split-Fantasy_top)*Screen_bytes_per_line,a1
	move.w	#Lower_lines*Screen_bytes_per_line/48-1,d7
.Copy:	movem.l	(a0)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a1)
	lea.l	48(a1),a1
	dbra	d7,.Copy
	REPT	(Lower_lines*Screen_bytes_per_line-Lower_lines*Screen_bytes_per_line/48*48)/4
	move.l	(a0)+,(a1)+
	ENDR
	movem.l	(sp)+,d0-d7/a0-a6
	ori.b	#4,ccr
	rts

;*****************************************************************************
; [ Uncover a part of the lettering ] (F00348)
;   IN : d0 - Byte of its column (.w)
;        d2 - Pixel in the column : 0, 4, 8, 12 (.w)
;  OUT : Z set
; All registers are restored
; NOTE :
;   - The pixels of the pattern (F00544) of the column come from the lettering
;     ([ Fst_letters ]) into the picture ([ Fst_picture ]).
;*****************************************************************************
Fantasy_draw_reveal:
	movem.l	d0-d4/d7/a0/a1,-(sp)
	move.w	d2,d1			; The pattern
	lsr.w	#1,d1
	lea.l	F00544,a0
	move.w	0(a0,d1.w),d1
	move.w	d1,d2
	not.w	d2
	lsr.w	#1,d0			; The column
	lsl.w	#3,d0
	lea.l	Fst_letters,a0
	add.w	d0,a0
	lea.l	Fst_picture+(Fantasy_split-Fantasy_top+Letters_line)*Screen_bytes_per_line+Letters_chunk*8,a1
	add.w	d0,a1
	move.w	#Letters_lines-1,d7
.Line:	REPT	4
	move.w	(a0)+,d3
	and.w	d1,d3
	move.w	(a1),d4
	and.w	d2,d4
	or.w	d4,d3
	move.w	d3,(a1)+
	ENDR
	lea.l	13*8-8(a0),a0
	lea.l	Screen_bytes_per_line-8(a1),a1
	dbra	d7,.Line
	movem.l	(sp)+,d0-d4/d7/a0/a1
	ori.b	#4,ccr
	rts

;*****************************************************************************
; [ Draw a sparkle ] (F0078c)
;   IN : d0 - X (.w)
;        d1 - Y (.w)
;        a0 - Pointer to its graphic (Fant_h1+$19b8c + n * $b4) (.l)
;  OUT : Z set
; All registers are restored
;*****************************************************************************
Fantasy_draw_sparkle:
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	a0,d2			; The sparkle (offset / 180)
	sub.l	#Fant_h1+$19b8c,d2
	lsr.w	#2,d2
	mulu.w	#1457,d2
	swap	d2
	lsl.w	#4,d2
	moveq.l	#15,d3			; Shift
	and.w	d0,d3
	add.w	d3,d2
	mulu.w	#9*24,d2
	lea.l	Fst_sparkles,a0
	add.l	d2,a0
	moveq.l	#9,d7			; Lines
	bsr	Fantasy_shifted
	movem.l	(sp)+,d0-d7/a0-a3
	ori.b	#4,ccr
	rts

;*****************************************************************************
; [ Draw a small sparkle of the dust ] (F00804)
;   IN : d0 - Byte of X (low word), its shift (bits 28-31) (.l)
;        d1 - Y (.w)
;        a0 - Pointer to its graphic (Fant_h1+$80, $e4, $148) (.l)
;  OUT : Z set
; All registers are restored
;*****************************************************************************
Fantasy_draw_small:
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	a0,d2			; The sparkle
	sub.l	#Fant_h1+$80,d2
	divu.w	#100,d2
	lsl.w	#4,d2
	move.l	d0,d3			; Shift
	swap	d3
	rol.w	#4,d3
	andi.w	#15,d3
	add.w	d3,d2
	mulu.w	#5*24,d2
	lea.l	Fst_small,a0
	add.l	d2,a0
	andi.w	#$fffe,d0			; X
	lsl.w	#3,d0
	add.w	d3,d0
	moveq.l	#5,d7			; Lines
	bsr	Fantasy_small_dirty
	bsr	Fantasy_shifted
	movem.l	(sp)+,d0-d7/a0-a3
	ori.b	#4,ccr
	rts

; [ Draw a graphic which is shifted in advance ]
;   IN : d0 - X (.w)
;        d1 - Y of the Amiga screen (.w)
;        d7 - Lines (.w)
;        a0 - Pointer to its lines : two chunks, each the inverted mask
;             twice, planes 0+1, planes 2+3 (.l)
; Changed registers : d0-d7, a0-a2
Fantasy_shifted:
	sub.w	#Fantasy_top,d1		; Clip the lines
	bpl.s	.Top
	add.w	d1,d7
	neg.w	d1
	mulu.w	#24,d1
	add.l	d1,a0
	moveq.l	#0,d1
.Top:	move.w	#Screen_height,d2
	sub.w	d1,d2
	cmp.w	d2,d7
	ble.s	.Lines
	move.w	d2,d7
.Lines:	subq.w	#1,d7
	bmi.s	.Exit
	mulu.w	#Screen_bytes_per_line,d1
	move.l	Off_screen,a1
	add.l	d1,a1
	asr.w	#4,d0			; Chunk
	bmi.s	.Exit
	cmp.w	#20,d0
	bcc.s	.Exit
	lsl.w	#3,d0
	add.w	d0,a1
	cmp.w	#19*8,d0			; (the right one : in the screen ?)
	beq.s	.Edge
.Line:	movem.l	(a0)+,d0-d5
	move.l	a1,a2
	cmp.l	#-1,d0			; (nothing in the left chunk)
	beq.s	.Right
	and.l	d0,(a2)
	or.l	d1,(a2)+
	and.l	d0,(a2)
	or.l	d2,(a2)+
	cmp.l	#-1,d3
	beq.s	.Next
	and.l	d3,(a2)
	or.l	d4,(a2)+
	and.l	d3,(a2)
	or.l	d5,(a2)
	bra.s	.Next
.Right:	cmp.l	#-1,d3
	beq.s	.Next
	addq.l	#8,a2
	and.l	d3,(a2)
	or.l	d4,(a2)+
	and.l	d3,(a2)
	or.l	d5,(a2)
.Next:	lea.l	Screen_bytes_per_line(a1),a1
	dbra	d7,.Line
.Exit:	rts
.Edge:	movem.l	(a0)+,d0-d5		; (only the left chunk)
	move.l	a1,a2
	and.l	d0,(a2)
	or.l	d1,(a2)+
	and.l	d0,(a2)
	or.l	d2,(a2)
	lea.l	Screen_bytes_per_line(a1),a1
	dbra	d7,.Edge
	rts

;*****************************************************************************
; [ Draw the dust ] (F0086e : two pixels, F0072a : the pixels of a byte)
;   IN : d0 - X (.w) (F0086e) or : pixels of the byte (bits 16-23), byte of
;             X (low word) (.l) (F0072a)
;        d1 - Y (.w)
;        d2 - Amiga colour * 4 (.w)
;  OUT : Z set
; All registers are restored
;*****************************************************************************
Fantasy_draw_dots:
	movem.l	d0-d4/a0/a1,-(sp)
	bsr.s	Fantasy_dust_line
	bmi.s	.Exit
	move.w	d0,d1			; The first pixel
	bsr.s	Fantasy_pixel
	move.w	d1,d0			; The second one
	addq.w	#1,d0
	bsr.s	Fantasy_pixel
.Exit:	movem.l	(sp)+,d0-d4/a0/a1
	ori.b	#4,ccr
	rts

Fantasy_draw_dot:
	movem.l	d0-d4/a0/a1,-(sp)
	bsr.s	Fantasy_dust_line
	bmi.s	.Exit
	move.l	d0,d3			; The pixels of the byte
	swap	d3
	moveq.l	#0,d2			; The byte : chunk and byte of the word
	move.w	d0,d2
	lsr.w	#1,d2
	lsl.w	#3,d2
	andi.w	#1,d0
	add.w	d0,d2
	add.l	d2,a1
	bsr.s	Fantasy_plot
.Exit:	movem.l	(sp)+,d0-d4/a0/a1
	ori.b	#4,ccr
	rts

; [ The ST colour and the line of the dust ]
;   IN : d1 - Y (.w), d2 - Amiga colour * 4 (.w)
;  OUT : d4 - ST colour (.w), a1 - Pointer to the line (.l), N set : not shown
; Changed registers : d1, d4, a0, a1
Fantasy_dust_line:
	moveq.l	#0,d4
	move.w	d2,d4
	lsr.w	#2,d4
	lea.l	Fairy_dust,a0
	move.b	0(a0,d4.w),d4
	sub.w	#Fantasy_top,d1
	bmi.s	.Exit
	cmp.w	#Screen_height,d1
	bge.s	.Not
	add.w	d1,d1
	lea.l	Fantasy_line_offsets,a1
	move.w	0(a1,d1.w),d1
	move.l	Off_screen,a1
	add.w	d1,a1
	moveq.l	#0,d1
	rts
.Not:	moveq.l	#-1,d1
.Exit:	rts

; [ One pixel ]
;   IN : d0 - X (.w), d4 - ST colour (.w), a1 - Pointer to the line (.l)
; Changed registers : d0, d2, d3, a0
Fantasy_pixel:
	cmp.w	#320,d0
	bcc.s	.Exit
	move.l	a1,a0
	moveq.l	#7,d2			; The bit
	and.w	d0,d2
	eori.w	#7,d2
	moveq.l	#0,d3
	bset	d2,d3
	moveq.l	#0,d2			; The byte
	move.w	d0,d2
	lsr.w	#4,d2
	lsl.w	#3,d2
	btst	#3,d0
	beq.s	.Even
	addq.w	#1,d2
.Even:	add.l	d2,a0
	exg	a0,a1
	bsr.s	Fantasy_plot
	exg	a0,a1
.Exit:	rts

; [ The pixels of a byte in a colour ]
;   IN : d3 - Pixels (.b), d4 - ST colour (.w), a1 - Pointer to the byte of
;        plane 0 (.l)
; Changed registers : d2
Fantasy_plot:
	move.l	a1,d2			; (the upper part : the dust is put back
	sub.l	Off_screen,d2		;  from the picture)
	cmp.l	#(Fantasy_split-Fantasy_top)*Screen_bytes_per_line,d2
	bcc.s	.Lower
	movem.l	d1/a0,-(sp)
	moveq.l	#0,d1
	bsr	Fantasy_dirty_add
	movem.l	(sp)+,d1/a0
.Lower:	move.b	d3,d2
	not.b	d2
	move.w	d4,-(sp)
	add.w	d4,d4
	add.w	d4,d4
	move.l	Plot_routines(pc,d4.w),-(sp)
	move.w	4(sp),d4
	rts				; (to the routine : it returns)
Plot_routines:
	dc.l	Plot_0,Plot_1,Plot_2,Plot_3,Plot_4,Plot_5,Plot_6,Plot_7
	dc.l	Plot_8,Plot_9,Plot_10,Plot_11,Plot_12,Plot_13,Plot_14,Plot_15
Plot_pixels	MACRO
	IFNE	(\1)&1
	or.b	d3,(a1)
	ELSE
	and.b	d2,(a1)
	ENDC
	IFNE	(\1)&2
	or.b	d3,2(a1)
	ELSE
	and.b	d2,2(a1)
	ENDC
	IFNE	(\1)&4
	or.b	d3,4(a1)
	ELSE
	and.b	d2,4(a1)
	ENDC
	IFNE	(\1)&8
	or.b	d3,6(a1)
	ELSE
	and.b	d2,6(a1)
	ENDC
	addq.l	#2,sp			; (the colour)
	rts
	ENDM
Plot_0:	Plot_pixels	0
Plot_1:	Plot_pixels	1
Plot_2:	Plot_pixels	2
Plot_3:	Plot_pixels	3
Plot_4:	Plot_pixels	4
Plot_5:	Plot_pixels	5
Plot_6:	Plot_pixels	6
Plot_7:	Plot_pixels	7
Plot_8:	Plot_pixels	8
Plot_9:	Plot_pixels	9
Plot_10:	Plot_pixels	10
Plot_11:	Plot_pixels	11
Plot_12:	Plot_pixels	12
Plot_13:	Plot_pixels	13
Plot_14:	Plot_pixels	14
Plot_15:	Plot_pixels	15

; [ Remember a part of the upper lines which was drawn ]
;   IN : d1 - Lines of 2 chunks, 0 : the byte of the 4 planes (.w)
;        d2 - Offset in the screen (.l)
; Changed registers : a0
Fantasy_dirty_add:
	move.l	Fantasy_dirty,a0
	cmp.l	#0,a0			; (not while it is drawn)
	beq.s	.End
	cmp.l	#Fantasy_dirty_lists+Dirty_list,a0	; (the end of the list of
	beq.s	.End			;  this screen)
	cmp.l	#Fantasy_dirty_lists+2*Dirty_list,a0
	beq.s	.End
	cmp.l	#Fantasy_dirty_lists+3*Dirty_list,a0
	beq.s	.End
	move.w	d2,(a0)+
	move.w	d1,(a0)+
	move.l	a0,Fantasy_dirty
.End:	rts

; [ A small sparkle in the upper lines : remembered ]
;   IN : d0 - X (.w), d1 - Y of the Amiga screen (.w)
; All registers are restored
Fantasy_small_dirty:
	movem.l	d0-d2/a0,-(sp)
	sub.w	#Fantasy_top,d1
	bpl.s	.Top
	moveq.l	#0,d1			; (the lines in the screen)
.Top:	cmp.w	#Fantasy_split-Fantasy_top,d1
	bge.s	.Exit
	mulu.w	#Screen_bytes_per_line,d1
	asr.w	#4,d0
	bmi.s	.Exit
	lsl.w	#3,d0
	ext.l	d0
	add.l	d1,d0
	move.l	d0,d2
	moveq.l	#5,d1
	bsr	Fantasy_dirty_add
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

; [ Put the parts of the upper lines back which were drawn in this screen ]
; Changed registers : d0-d3, a0-a3
; NOTE :
;   - From the picture; the list of the screen is made anew while it is
;     drawn ([ Fantasy_dirty ]), its end is kept when it is shown
;     ([ Fantasy_dirty_shown ]).
Fantasy_restore_dirty:
	move.l	Off_screen,a1
	jsr	Fantasy_screen_number
	lea.l	Fantasy_dirty_ends,a3
	add.w	d0,a3
	lea.l	Fantasy_dirty_lists,a0
	mulu.w	#Dirty_list/4,d0
	add.l	d0,a0
	move.l	a0,Fantasy_dirty		; (the new list)
	move.l	(a3),d3			; (the end of the old one)
	clr.l	(a3)
.Part:	cmp.l	d3,a0
	bcc.s	.Exit
	moveq.l	#0,d0
	move.w	(a0)+,d0			; Offset
	move.w	(a0)+,d1			; Lines
	lea.l	Fst_picture,a3
	add.l	d0,a3
	lea.l	0(a1,d0.l),a2
	tst.w	d1
	bne.s	.Lines
	move.b	(a3),(a2)			; A byte
	move.b	2(a3),2(a2)
	move.b	4(a3),4(a2)
	move.b	6(a3),6(a2)
	bra.s	.Part
.Lines:	subq.w	#1,d1
.Line:	move.l	(a3),(a2)
	move.l	4(a3),4(a2)
	move.l	8(a3),8(a2)
	move.l	12(a3),12(a2)
	lea.l	Screen_bytes_per_line(a3),a3
	lea.l	Screen_bytes_per_line(a2),a2
	dbra	d1,.Line
	bra.s	.Part
.Exit:	rts

; [ The screen is shown : the end of its list is kept ]
; Changed registers : a1, a3
Fantasy_dirty_shown:
	tst.l	Fantasy_dirty		; (nothing drawn)
	beq.s	.Exit
	move.l	Off_screen,a1
	move.l	d0,-(sp)
	jsr	Fantasy_screen_number
	lea.l	Fantasy_dirty_ends,a3
	add.w	d0,a3
	move.l	(sp)+,d0
	move.l	Fantasy_dirty,(a3)
	clr.l	Fantasy_dirty
.Exit:	rts

;*****************************************************************************
; [ Set the colours ] (vertical blank)
; All registers are restored
; NOTE :
;   - The colours : 32 from Fant_h2+$20 (the upper lines) and 32 from
;     Fant_h2+$60 (the lower lines), the first 16 of each are the ST colours.
;*****************************************************************************
Fantasy_palette:
	movem.l	d0/d7/a0-a3,-(sp)
	lea.l	Fant_h2+$20,a0		; The same as last time ?
	lea.l	Fantasy_old_palette,a1
	moveq.l	#64-1,d7
.Same:	cmpm.w	(a0)+,(a1)+
	dbne	d7,.Same
	beq.s	.Exit
	lea.l	Fant_h2+$20,a0		; Keep them
	lea.l	Fantasy_old_palette,a1
	moveq.l	#64-1,d7
.Keep:	move.w	(a0)+,(a1)+
	dbra	d7,.Keep
	lea.l	Intro_ST_palettes,a1	; Both palettes (two buffers : the
	not.b	Intro_palette_buffer	;  events of the last frame are still
	beq.s	.Buffer			;  shown)
	lea.l	Fantasy_ST_palettes,a1
.Buffer:	move.l	a1,a3
	lea.l	Fant_h2+$20,a0
	bsr.s	.Colours
	lea.l	Fant_h2+$60,a0
	bsr.s	.Colours
	lea.l	Intro_events,a1		; The raster events
	clr.w	(a1)+
	move.w	#-1,(a1)+
	move.l	a3,(a1)+
	move.w	#Fantasy_split-Fantasy_top,(a1)+
	move.w	#-1,(a1)+
	pea	32(a3)
	move.l	(sp)+,(a1)+
	move.w	#$7fff,(a1)
	lea.l	Intro_events,a0
	jsr	Show_raster_events
.Exit:	movem.l	(sp)+,d0/d7/a0-a3
	rts
.Colours:	moveq.l	#16-1,d7
.Colour:	move.w	(a0)+,d0
	jsr	Amiga_to_STE_colour
	move.w	d0,(a1)+
	dbra	d7,.Colour
	rts

	SECTION	Fast_BSS,bss
Fantasy_line:	ds.w 1
Fb_first:	ds.w 1			; (St_sprite)
Fb_middle:	ds.w 1
Fb_last:	ds.w 1

Fb_source_y:	ds.w 1
Fb_dest_y:	ds.w 1

Fb_width:	ds.w 1			; (chunks of a line of the sprite)
Fb_line:	ds.w 1			; (bytes of a line of the sprite)
Fb_shift:	ds.w 1
Fb_chunk:	ds.w 1
Fantasy_line_offsets:	ds.w Screen_height
Fantasy_dirty:	ds.l 1			; The next entry of the list
Fantasy_dirty_ends:	ds.l 3			; The ends of the lists of the screens
Fantasy_dirty_lists:	ds.b 3*Dirty_list		; Per entry : offset, lines
Fantasy_screens:	ds.l 3			; The three screens
Fantasy_game_screens:	ds.l 2
Fantasy_old_palette:	ds.w 64
Fantasy_ST_palettes:	ds.w 2*16
Fantasy_saves:	ds.b 3*Fairy_save_record	; Per screen : lines, screen, chunks, data
Fantasy_visible:	ds.b 1
	even

	SECTION	Program,code
