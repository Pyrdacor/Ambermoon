; Falcon kernel : the hardware of the fairy of Thalion (FANTASY.S)
;
; FANTASY.S is the code of the Amiga program Fantasy_intro. It draws into Amiga
; screens with 5 planes and 256 lines, like the intro (INTRO_HW.S : custom chips
; in memory, the blitter). Here :
;   - The copper is gone : [ Fantasy_present ] converts the Amiga screen. Only
;     the lines from [ Fantasy_split ] on change, and the lines of the fairy.
;   - The copper changes 7 colours in the line [ Fantasy_split ] : the lines
;     from there on use the second bank of colours.
;   - The fairy (8 sprites, 4 attached pairs : 16 colours, the colours 16-31) is
;     drawn into the converted screen.

Fantasy_split	EQU	134		; The line of the colour change
Fairy_width	EQU	4		; (pairs of sprites)
Fairy_lines	EQU	71
Fairy_sprite	EQU	$124		; Size of a sprite
Fairy_frame	EQU	$920		; Size of a frame of the 8 sprites

	SECTION	Program,code

;*****************************************************************************
; [ Show the fairy ]
; All registers are restored
;*****************************************************************************
Fantasy_main:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	F00110
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Blit a sparkle ] (F0078c : the registers of the blitter are set)
;   IN : d3 - BLTSIZE (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
; All registers are restored
; NOTE :
;   - Always the same kind of blit (cookie cut, two words, from the data of
;     the fairy) : straight to [ Intro_star_blit ], without the checks of
;     [ Intro_blit ].
;*****************************************************************************
Fantasy_sparkle:
	move.w	d3,Blt_size(a6)
	movem.l	d0-d7/a0-a5,-(sp)
	move.w	d3,d0			; Height
	lsr.w	#6,d0
	cmp.w	#Star_rows,d0
	bhi.s	.Blit
	move.w	d0,Bl_height
	move.w	Blt_con0(a6),d2		; Shift
	rol.w	#4,d2
	andi.w	#15,d2
	jsr	Intro_star_blit
	movem.l	(sp)+,d0-d7/a0-a5
	rts
.Blit:	movem.l	(sp)+,d0-d7/a0-a5
	jmp	Intro_blit

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
	jsr	Intro_clear
	move.w	#-1,Fantasy_old_y
	move.w	#-1,Fantasy_old_y+2
	clr.w	Fantasy_full
	clr.w	Fant_h2+$d0
	sf	Fantasy_visible
	lea.l	F00d88,a0
	move.l	a0,VBL_hook
	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Give the screens back ]
; All registers are restored
;*****************************************************************************
Fantasy_exit:
	jmp	Intro_exit

;*****************************************************************************
; [ There is a new picture in the Amiga screens ]
; All registers are restored
;*****************************************************************************
Fantasy_new_picture:
	move.w	#2,Fantasy_full
	rts

;*****************************************************************************
; [ Show the Amiga screen ] (the copper list on the Amiga)
; All registers are restored
;*****************************************************************************
Fantasy_present:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Intro_wait_shown
	move.l	Fant_h2+$f4,a0		; The Amiga screen
	move.l	Off_screen,a1
	moveq.l	#0,d6			; (the old fairy of this screen)
	cmp.l	Intro_first_screen,a1
	beq.s	.First
	moveq.l	#2,d6
.First:	move.w	Fant_h2+$ca,d5		; The fairy
	tst.b	Fantasy_visible		; (set by the interrupt, with the sprites)
	bne.s	.Fairy
	moveq.l	#-1,d5
.Fairy:	lea.l	Fantasy_old_y,a5
	tst.w	Fantasy_full		; The whole picture ?
	beq.s	.Parts
	subq.w	#1,Fantasy_full
	moveq.l	#0,d0
	move.w	Intro_lines,d1
	jsr	Fantasy_lines
	move.w	Intro_lines,d7		; The second bank
	sub.w	#Fantasy_split,d7
	mulu.w	#20,d7
	subq.w	#1,d7
	move.l	a1,a2
	add.l	#Fantasy_split*Screen_bytes_per_line+10,a2
.Bank:	move.w	#-1,(a2)
	lea.l	16(a2),a2
	dbra	d7,.Bank
	bra.s	.Sprite
.Parts:	move.w	0(a5,d6.w),d0		; The old fairy
	cmp.w	#-1,d0
	beq.s	.No_old
	moveq.l	#Fairy_lines,d1
	jsr	Fantasy_upper
.No_old:	cmp.w	#-1,d5			; The new fairy
	beq.s	.No_new
	move.w	d5,d0
	moveq.l	#Fairy_lines,d1
	jsr	Fantasy_upper
.No_new:	move.w	#Fantasy_split,d0		; The part which changes
	move.w	Intro_lines,d1
	sub.w	d0,d1
	jsr	Fantasy_lines
.Sprite:	move.w	d5,0(a5,d6.w)
	cmp.w	#-1,d5
	beq.s	.Show
	jsr	Fantasy_fairy
.Show:	jsr	Intro_show
	move.l	Off_screen,Work_screen
	jsr	Pointer_out_of_work
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Convert the lines above the colour change ]
;   IN : d0 - First line (.w)
;        d1 - Number of lines (.w)
;        a0 - Pointer to the Amiga screen (.l)
;        a1 - Pointer to the Falcon screen (.l)
; Changed registers : d0, d1, d7, a2, a3
;*****************************************************************************
Fantasy_upper:
	tst.w	d0			; Clip
	bpl.s	.Top
	add.w	d0,d1
	moveq.l	#0,d0
.Top:	move.w	d0,d7
	add.w	d1,d7
	cmp.w	#Fantasy_split,d7
	ble.s	Fantasy_lines
	move.w	#Fantasy_split,d1
	sub.w	d0,d1
; (on into [ Fantasy_lines ])

;*****************************************************************************
; [ Convert lines ]
;   IN : d0 - First line (.w)
;        d1 - Number of lines (.w)
;        a0 - Pointer to the Amiga screen (.l)
;        a1 - Pointer to the Falcon screen (.l)
; Changed registers : d0, d1, d7, a2, a3
;*****************************************************************************
Fantasy_lines:
	tst.w	d1
	ble.s	.Exit
	move.w	d0,d7
	mulu.w	#200,d7
	lea.l	0(a0,d7.l),a2
	move.w	d0,d7
	mulu.w	#Screen_bytes_per_line,d7
	lea.l	0(a1,d7.l),a3
	subq.w	#1,d1
.Line:	moveq.l	#20-1,d7
.Word:	move.w	40(a2),2(a3)
	move.w	80(a2),4(a3)
	move.w	120(a2),6(a3)
	move.w	160(a2),8(a3)
	move.w	(a2)+,(a3)
	lea.l	16(a3),a3
	dbra	d7,.Word
	lea.l	160(a2),a2
	dbra	d1,.Line
.Exit:	rts

;*****************************************************************************
; [ Draw the fairy into the Falcon screen ]
;   IN : d5 - Y of the fairy (.w)
;        a1 - Pointer to the Falcon screen (.l)
; Changed registers : d0-d7, a0, a2-a4, a6
; NOTE :
;   - The sprites of a pair : planes 0 + 1 and 2 + 3, colour 16 + value. Value
;     0 is transparent.
;*****************************************************************************
Fantasy_fairy:
	lea.l	Fant_h1+$1ac,a0		; The frame
	move.w	Fant_h2+$bc,d0
	mulu.w	#Fairy_frame,d0
	add.l	d0,a0
	moveq.l	#Fairy_width-1,d7
	move.w	Fant_h2+$c8,d2		; X (the sprites start one pixel left)
	subq.w	#1,d2
.Pair:	movem.w	d2/d7,-(sp)
	move.l	a0,a2			; The sprites of the pair
	lea.l	Fairy_sprite(a0),a3
	addq.l	#4,a2
	addq.l	#4,a3
	moveq.l	#15,d0			; Shift and chunk
	and.w	d2,d0
	move.w	d0,Fantasy_shift
	asr.w	#4,d2
	move.w	d2,Fantasy_chunk
	move.w	d5,d0			; Clip the lines
	moveq.l	#Fairy_lines,d6
	tst.w	d0
	bpl.s	.Top
	add.w	d0,d6			; (above the screen)
	neg.w	d0
	lsl.w	#2,d0
	add.w	d0,a2
	add.w	d0,a3
	moveq.l	#0,d0
.Top:	move.w	Intro_lines,d1
	sub.w	d0,d1
	cmp.w	d1,d6
	ble.s	.Lines
	move.w	d1,d6
.Lines:	subq.w	#1,d6
	bmi	.Next
	mulu.w	#Screen_bytes_per_line,d0
	lea.l	0(a1,d0.l),a6
.Line:	movem.w	(a2)+,d0/d1		; The planes of the line
	movem.w	(a3)+,d2/d3
	move.w	d0,d4			; Anything ?
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
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
	move.w	Fantasy_shift,d7
	lsr.l	d7,d0
	lsr.l	d7,d1
	lsr.l	d7,d2
	lsr.l	d7,d3
	lsr.l	d7,d4
	swap	d0			; The left chunk
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	move.w	Fantasy_chunk,d7
	bsr.s	.Put
	swap	d0			; The right chunk
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	move.w	Fantasy_chunk,d7
	addq.w	#1,d7
	bsr.s	.Put
.Skip:	lea.l	Screen_bytes_per_line(a6),a6
	dbra	d6,.Line
.Next:	movem.w	(sp)+,d2/d7
	add.w	#16,d2
	lea.l	2*Fairy_sprite(a0),a0
	dbra	d7,.Pair
	rts
; The planes d0-d3 and the mask d4 into the chunk d7 of the line a6
.Put:	cmp.w	#20,d7
	bcc.s	.Out
	lsl.w	#4,d7
	lea.l	0(a6,d7.w),a4
	move.w	d4,d7
	not.w	d7
	and.w	d7,(a4)
	or.w	d0,(a4)+
	and.w	d7,(a4)
	or.w	d1,(a4)+
	and.w	d7,(a4)
	or.w	d2,(a4)+
	and.w	d7,(a4)
	or.w	d3,(a4)+
	or.w	d4,(a4)
.Out:	rts

;*****************************************************************************
; [ Set the colours ] (vertical blank)
; All registers are restored
; NOTE :
;   - The colours of the Amiga : 32 from Fant_h2+$20, and 32 from Fant_h2+$60
;     of which the copper takes those in the table F00d12.
;*****************************************************************************
Fantasy_palette:
	movem.l	d0-d3/d7/a0-a3,-(sp)
	lea.l	Fant_h2+$20,a0		; The same as last time ?
	lea.l	Fantasy_old_palette,a1
	moveq.l	#64-1,d7
.Same:	cmpm.w	(a0)+,(a1)+
	dbne	d7,.Same
	beq	.Exit
	lea.l	Fant_h2+$20,a0		; Keep them
	lea.l	Fantasy_old_palette,a1
	moveq.l	#64-1,d7
.Keep:	move.w	(a0)+,(a1)+
	dbra	d7,.Keep
	lea.l	Fant_h2+$20,a0		; The first bank
	lea.l	Videl_palette,a1
	lea.l	Nibble_to_videl,a2
	moveq.l	#32-1,d7
.Loop:	move.w	(a0)+,d0
	jsr	Amiga_to_videl
	move.l	d1,(a1)+
	dbra	d7,.Loop
	lea.l	Videl_palette,a0		; The second bank
	moveq.l	#32-1,d7
.Bank:	move.l	(a0)+,(a1)+
	dbra	d7,.Bank
	lea.l	F00d12,a3			; (those of the copper list)
.Copper:	move.w	(a3)+,d3
	bmi.s	.Exit
	lea.l	Fant_h2+$60,a0
	move.w	0(a0,d3.w),d0
	jsr	Amiga_to_videl
	lea.l	Videl_palette+32*4,a0
	add.w	d3,d3
	move.l	d1,0(a0,d3.w)
	bra.s	.Copper
.Exit:	movem.l	(sp)+,d0-d3/d7/a0-a3
	rts

	SECTION	Fast_BSS,bss
Fantasy_full:	ds.w 1
Fantasy_old_y:	ds.w 2
Fantasy_shift:	ds.w 1
Fantasy_chunk:	ds.w 1
Fantasy_old_palette:	ds.w 64
Fantasy_visible:	ds.b 1
	even

	SECTION	Program,code
