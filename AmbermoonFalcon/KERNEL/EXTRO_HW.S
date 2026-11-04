; Falcon kernel : the hardware of the extro (EXTRO.S)
;
; EXTRO.S is the code of the Amiga program Ambermoon_extro. It draws into Amiga
; screens with 5 planes and 256 lines, like the intro (INTRO_HW.S : custom chips
; in memory, the blitter). Here :
;   - A picture goes into both screens of the Falcon when it is in the Amiga
;     screens ([ Extro_picture ]).
;   - The text scrolls over the picture : where it is, the picture is
;     brightened. The 5 blits of a frame on the Amiga (the picture, the
;     brightened picture, the text as the mask) are done by [ Extro_compose ]
;     straight into the screen of the Falcon, at the pace of the Amiga.
;   - The music is the Sonic Arranger replay of the kernel (MUSIC.S) with the
;     module of Extro_music.
;   - The BSS of the Amiga (hunk 5) is the BSS of the intro : the intro is over.

Extro_h5	EQU	Intro_h5
Extro_h5_size	EQU	$d3a4*4		; (Intro_h5 and Intro_h6 have $488c*4 + $915b*4)
Extro_frame	EQU	3		; Vertical blanks of the blits of a frame

	SECTION	Program,code

;*****************************************************************************
; [ Show the extro ]
; All registers are restored
; NOTE :
;   - Called in [ Exit_program ]. Only when the game is completed : the code
;     in [ Return_value ] (-5000 to -5002) is the kind of the ending.
;*****************************************************************************
Run_extro:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Return_value,d0
	add.l	#5000,d0
	bgt.s	.Exit
	cmp.l	#-2,d0
	blt.s	.Exit
	neg.l	d0
	lea.l	Extro_h4,a0		; (BSS)
	moveq.l	#$c0/4-1,d7
.Clear4:	clr.l	(a0)+
	dbra	d7,.Clear4
	lea.l	Extro_h5,a0
	move.l	#Extro_h5_size/4-1,d7
.Clear5:	clr.l	(a0)+
	subq.l	#1,d7
	bpl.s	.Clear5
	move.b	d0,Extro_h4+$2c
	jsr	E00120
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Take over the screens, start the interrupt ]
; All registers are restored
;*****************************************************************************
Extro_init:
	movem.l	d0/d7/a0,-(sp)
	lea.l	Intro_custom+$180,a0	; (the colours of the intro must not come)
	moveq.l	#32/2-1,d7
.Colours:	clr.l	(a0)+
	dbra	d7,.Colours
	lea.l	Extro_old_palette,a0
	moveq.l	#32/2-1,d7
.Old:	move.l	#-1,(a0)+
	dbra	d7,.Old
	move.w	sr,-(sp)
	ori.w	#$0700,sr
	jsr	Intro_init
	lea.l	E00f26,a0
	move.l	a0,VBL_hook
	move.w	(sp)+,sr
	jsr	Intro_clear
	lea.l	Extro_text_lines,a0
	move.w	#2*256/4-1,d7
.Lines:	clr.l	(a0)+
	dbra	d7,.Lines
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Show the screen ] (the copper list on the Amiga)
; All registers are restored
;*****************************************************************************
Extro_present:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Intro_show
	move.l	Off_screen,Work_screen
	jsr	Pointer_out_of_work
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ There is a new picture ] (in [ Extro_h4+$24 ] and the Amiga screens)
; All registers are restored
;*****************************************************************************
Extro_picture:
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	Extro_h4+$24,a0		; Into both screens
	move.l	On_screen,a1
	moveq.l	#0,d0
	move.w	Intro_lines,d1
	jsr	Fantasy_lines
	move.l	Extro_h4+$24,a0
	move.l	Off_screen,a1
	moveq.l	#0,d0
	move.w	Intro_lines,d1
	jsr	Fantasy_lines
	lea.l	Extro_text_lines,a0		; No text in them
	move.w	#2*256/4-1,d7
.Lines:	clr.l	(a0)+
	dbra	d7,.Lines
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ A frame of the text ] (the 5 blits on the Amiga)
; All registers are restored
; NOTE :
;   - The text is a mask with 40 bytes in a line ([ Extro_h5+$320 ]). Where it
;     is set the brightened picture ([ Extro_h4+$28 ]) is shown, else the
;     picture ([ Extro_h4+$24 ]). Both are Amiga screens (5 planes, line
;     interleaved). The lines without text now and before in this screen
;     ([ Extro_text_lines ]) stay as they are.
;   - The blits of the Amiga take about 2.7 vertical blanks : the frame takes
;     as long here ([ Extro_frame ]), so that the text scrolls at its speed.
;*****************************************************************************
Extro_compose:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Extro_h4+$4,Extro_start
	jsr	Intro_wait_shown
	lea.l	Extro_h5+$320,a0		; The text
	move.l	Extro_h4+$28,a1		; The brightened picture
	move.l	Extro_h4+$24,a2		; The picture
	move.l	Off_screen,a3
	lea.l	Extro_text_lines,a4		; (the lines of this screen)
	cmp.l	Intro_first_screen,a3
	beq.s	.First
	lea.l	256(a4),a4
.First:	move.w	Intro_lines,d7
	subq.w	#1,d7
.Line:	move.l	a0,a5			; Any text in this line ?
	moveq.l	#0,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	or.l	(a5)+,d0
	tst.l	d0
	sne	d1
	move.b	(a4),d2			; (or before ?)
	move.b	d1,(a4)+
	or.b	d1,d2
	bne.s	.Compose
	lea.l	40(a0),a0			; No : nothing to do
	lea.l	200(a1),a1
	lea.l	200(a2),a2
	lea.l	Screen_bytes_per_line(a3),a3
	dbra	d7,.Line
	bra	.Pace
.Compose:	moveq.l	#20-1,d6
.Word:	move.w	(a0)+,d0			; The mask
	beq.s	.Plain
	move.w	d0,d1
	not.w	d1
	move.w	(a1),d2			; The 5 planes
	and.w	d0,d2
	move.w	(a2),d3
	and.w	d1,d3
	or.w	d3,d2
	move.w	d2,(a3)
	move.w	40(a1),d2
	and.w	d0,d2
	move.w	40(a2),d3
	and.w	d1,d3
	or.w	d3,d2
	move.w	d2,2(a3)
	move.w	80(a1),d2
	and.w	d0,d2
	move.w	80(a2),d3
	and.w	d1,d3
	or.w	d3,d2
	move.w	d2,4(a3)
	move.w	120(a1),d2
	and.w	d0,d2
	move.w	120(a2),d3
	and.w	d1,d3
	or.w	d3,d2
	move.w	d2,6(a3)
	move.w	160(a1),d2
	and.w	d0,d2
	move.w	160(a2),d3
	and.w	d1,d3
	or.w	d3,d2
	move.w	d2,8(a3)
	bra.s	.Next
.Plain:	move.w	(a2),(a3)			; (no text : the picture)
	move.w	40(a2),2(a3)
	move.w	80(a2),4(a3)
	move.w	120(a2),6(a3)
	move.w	160(a2),8(a3)
.Next:	addq.l	#2,a1
	addq.l	#2,a2
	lea.l	16(a3),a3
	dbra	d6,.Word
	lea.l	160(a1),a1
	lea.l	160(a2),a2
	dbra	d7,.Line
.Pace:	move.l	Extro_start,d0		; The time of the Amiga
	addq.l	#Extro_frame-1,d0
.Wait:	cmp.l	Extro_h4+$4,d0
	bgt.s	.Wait
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Set the colours ] (vertical blank)
; All registers are restored
; NOTE :
;   - The 32 colours of the Amiga, in the colour registers.
;*****************************************************************************
Extro_palette:
	movem.l	d0-d2/d7/a0-a2,-(sp)
	lea.l	Intro_custom+$180,a0	; The same as last time ?
	lea.l	Extro_old_palette,a1
	moveq.l	#32-1,d7
.Same:	cmpm.w	(a0)+,(a1)+
	dbne	d7,.Same
	beq.s	.Exit
	lea.l	Intro_custom+$180,a0	; Keep them
	lea.l	Extro_old_palette,a1
	moveq.l	#32-1,d7
.Keep:	move.w	(a0)+,(a1)+
	dbra	d7,.Keep
	lea.l	Intro_custom+$180,a0
	lea.l	Videl_palette,a1
	lea.l	Nibble_to_videl,a2
	moveq.l	#32-1,d7
.Loop:	move.w	(a0)+,d0
	jsr	Amiga_to_videl
	move.l	d1,(a1)+
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d0-d2/d7/a0-a2
	rts

	SECTION	Fast_BSS,bss
Extro_start:	ds.l 1
Extro_old_palette:	ds.w 32
Extro_text_lines:	ds.b 2*256
	even

	SECTION	Program,code
