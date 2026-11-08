; ST kernel : the hardware of the intro and the main menu (INTRO.S)
; (The Falcon version has its own INTRO_HW.S.)
;
; INTRO.S is the code of the Amiga program Ambermoon_intro, which draws into
; Amiga screens (line interleaved planes, in memory) with the CPU and the
; blitter (INTRO_COMMON.S : the common parts). Here :
;   - [ Intro_present ] converts the Amiga screen into an ST screen (the
;     screens of the game) and shows it. The pictures have 16 colours (the
;     planes 0-3). The colours 16-31 (plane 4) are the stars (white) and the
;     texts of the menu : they get the ST colour of the 16 which is nearest
;     ([ Intro_make_lut ]).
;   - The Amiga screens have up to 256 lines, the ST shows 200 of them from
;     [ Intro_top ] on ([ Intro_video ]) : with 236 lines the lower ones (the
;     texts under the pictures), with 256 the middle.
;   - The colours ([ Intro_palette ]) : a raster event sets the 16 colours,
;     another one colour 1 of the lines from 200 on (the text under the
;     picture, a copper split on the Amiga).
;   - The stars move in every frame in the shown screen ([ Intro_stars ]), in
;     the colour nearest to theirs, on black only.
;   - The mouse pointer of the menu (a sprite with the colours 16-31) is the
;     pointer of the kernel.
;   - The music : the two songs of the intro module for the YM2149 (made by
;     port/tools/sa_to_st.py).
;   - The memory of the intro goes to the game afterwards ([ Intro_free ]).

	SECTION	Program,code

;*****************************************************************************
; [ Take over the screens ]
; All registers are restored
; NOTE :
;   - The intro uses the screens of the game.
;*****************************************************************************
Intro_init:
	move.l	a0,-(sp)
	cmp.l	#L02522,VBL_hook		; (again after "intro" in the menu)
	beq.s	.Hook
	move.l	On_screen,Intro_first_screen
	movem.l	d0-d2/a0-a2,-(sp)		; The blitter of the STE ? (XBIOS
	move.w	#-1,-(sp)			;  Blitmode(-1) : bit 1)
	move.w	#64,-(sp)
	trap	#XBIOS
	addq.l	#4,sp
	btst	#1,d0
	sne	Bl_hardware
	movem.l	(sp)+,d0-d2/a0-a2
	jsr	Reset_MA_stack
	jsr	Reset_Mptr_stack
	jsr	Intro_clear
.Hook:	st	Mouse_off_flag		; (no pointer before the menu)
	lea.l	L02522,a0
	move.l	a0,VBL_hook
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Give the screens back ]
; All registers are restored
;*****************************************************************************
Intro_exit:
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	VBL_hook
	sf	Intro_pointer_active
	jsr	Intro_clear		; (first : the colours of the game are
	jsr	Init_copper		;  not those of the picture)
	jsr	My_vsync
	jsr	My_vsync
	jsr	Reset_MA_stack
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Clear both screens ]
; All registers are restored
;*****************************************************************************
Intro_clear:
	movem.l	d7/a0,-(sp)
	sf	Pointer_records+Rec_drawn	; (no pointer in the screens : its
	sf	Pointer_records+Rec_size+Rec_drawn	;  background is gone)
	move.l	On_screen,a0
	jsr	Clear_screen
	move.l	Off_screen,a0
	jsr	Clear_screen
	lea.l	Intro_line_used,a0		; (no line has anything)
	move.w	#2*Screen_height/4-1,d7
.Used:	clr.l	(a0)+
	dbra	d7,.Used
	clr.w	Intro_star_lists		; (no stars)
	clr.w	Intro_star_lists+Star_list_size
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Set the size of the display ]
;   IN : d0 - Number of lines (.w)
;        d1 - Number of planes (.w)
; All registers are restored
; NOTE :
;   - The ST shows 200 lines from [ Intro_top ] on.
;*****************************************************************************
Intro_video:
	movem.l	d0-d2,-(sp)
	move.w	Intro_planes,d2		; (fewer planes : the old ones must go)
	cmp.w	d1,d2
	sgt	d2
	move.w	d1,Intro_planes
	cmp.w	Intro_lines,d0		; The picture stays (the menu goes from
	bne.s	.Clear			;  4 to 5 planes with the same picture)
	tst.b	d2
	beq.s	.Keep
.Clear:	jsr	Intro_clear
.Keep:	move.w	d0,Intro_lines
	moveq.l	#0,d1			; The lines which are shown
	cmp.w	#Screen_height,d0
	bls.s	.Top
	moveq.l	#(256-Screen_height)/2,d1	; 256 : the middle
	cmp.w	#256,d0
	beq.s	.Top
	move.w	d0,d1			; Else the lower ones (the texts)
	sub.w	#Screen_height,d1
.Top:	move.w	d1,Intro_top
	move.w	#$2c81,Intro_custom+$8e	; The whole display window
	add.w	#$2c,d0
	lsl.w	#8,d0
	move.b	#$c1,d0
	move.w	d0,Intro_custom+$90
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Show the Amiga screen ] (the copper list and its screen change on the Amiga)
; All registers are restored
; NOTE :
;   - A line of the ST screen which had nothing is only converted when the
;     Amiga line has something; a line which had something is converted.
;   - Plane 4 is converted with 5 planes, unless the stars move (it is
;     theirs, the Amiga clears it in every frame).
;   - Nothing while the last picture of the intro of the ST stays
;     ([ Intro_hold ]).
;*****************************************************************************
Intro_present:
	tst.b	Intro_hold
	beq.s	.Go
	rts
.Go:	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Intro_wait_shown
	move.l	Off_screen,a3		; The pointer out of the screen which is
	jsr	Pointer_record		;  converted (else its background from
	jsr	Restore_pointer		;  before comes back : the menu)
	move.l	Off_screen,a6		; (its stars : erased)
	jsr	Intro_star_list
	jsr	Intro_erase_stars
	move.l	Off_screen,a1
	lea.l	Intro_line_used,a6		; (the lines of this screen)
	cmp.l	Intro_first_screen,a1
	beq.s	.Table
	lea.l	Screen_height(a6),a6
.Table:	move.w	Intro_planes,d6		; Bytes per Amiga line
	mulu.w	#40,d6
	move.l	Intro_h5+$20,a0		; The first line which is shown
	move.w	Intro_top,d0
	mulu.w	d6,d0
	add.l	d0,a0
	sf	d5			; Plane 4 ?
	cmp.w	#5,Intro_planes
	bne.s	.Window
	tst.w	Intro_h5+$2a
	bne.s	.Window
	st	d5
; ---------- The display window -------------------
.Window:	moveq.l	#0,d1			; First line
	move.b	Intro_custom+$8e,d1
	sub.w	#$2c,d1
	moveq.l	#0,d2			; After the last line
	move.b	Intro_custom+$90,d2
	cmp.w	#$80,d2
	bcc.s	.Y2
	add.w	#$100,d2
.Y2:	sub.w	#$2c,d2
	cmp.w	Intro_lines,d2
	ble.s	.Y3
	move.w	Intro_lines,d2
.Y3:	move.w	Intro_top,d0		; In the lines of the ST
	sub.w	d0,d1
	sub.w	d0,d2
	moveq.l	#0,d7			; d7 : the line
; ---------- Lines --------------------------------
.Line:	cmp.w	d1,d7			; In the window ?
	blt	.Outside
	cmp.w	d2,d7
	bge	.Outside
	tst.b	(a6)			; Anything in the ST line ?
	bne	.Convert
	move.l	a0,a2			; Anything in the Amiga line ?
	moveq.l	#0,d0
	REPT	40
	or.l	(a2)+,d0
	ENDR
	tst.b	d5
	beq	.Empty
	REPT	10
	or.l	(a2)+,d0
	ENDR
.Empty:	tst.l	d0
	beq	.Next
	st	(a6)
.Convert:	move.l	a0,a2
	move.l	a1,a3
	tst.b	d5
	bne	.Five
	REPT	20			; 4 planes
	move.w	(a2)+,(a3)+
	move.w	38(a2),(a3)+
	move.w	78(a2),(a3)+
	move.w	118(a2),(a3)+
	ENDR
	bra	.Next
.Five:	jsr	Intro_line_5
	bra	.Next
.Outside:	tst.b	(a6)			; Outside : nothing
	beq	.Next
	sf	(a6)
	move.l	a1,a3
	moveq.l	#0,d0
	REPT	Screen_bytes_per_line/4
	move.l	d0,(a3)+
	ENDR
.Next:	add.w	d6,a0
	lea.l	Screen_bytes_per_line(a1),a1
	addq.l	#1,a6
	addq.w	#1,d7
	cmp.w	#Screen_height,d7
	blt	.Line
	jsr	Intro_show
	move.l	Off_screen,Work_screen
	jsr	Pointer_out_of_work
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Convert a line with 5 planes ]
;   IN : a2 - Pointer to the Amiga line (.l)
;        a3 - Pointer to the ST line (.l)
; Changed registers : d0, d3, d4, a2, a3
; NOTE :
;   - The colours 16-31 get the ST colours of [ Intro_lut ] : when they are
;     all the same (the stars) with the planes, else pixel by pixel.
;   - In the menu one of the colours 0-15 gives its ST colour to the colour
;     of the chosen entry ([ Intro_merge ]) : its pixels get the colour which
;     is nearest to it.
;*****************************************************************************
Intro_line_5:
	movem.l	d1/d2/d5-d7/a4,-(sp)
	moveq.l	#20-1,d4
.Word:	move.w	(a2),d1			; The planes 0-3 in d1, d2, d5, d6
	move.w	40(a2),d2
	move.w	80(a2),d5
	move.w	120(a2),d6
	move.w	160(a2),d0		; Plane 4
	tst.b	Intro_merge		; A colour given away ?
	beq.s	.Upper
	lea.l	Intro_merge_masks,a4
	move.w	(a4)+,d3			; Its pixels
	eor.w	d1,d3
	move.w	(a4)+,d7
	eor.w	d2,d7
	and.w	d7,d3
	move.w	(a4)+,d7
	eor.w	d5,d7
	and.w	d7,d3
	move.w	(a4)+,d7
	eor.w	d6,d7
	and.w	d7,d3
	move.w	d0,d7			; (not those of the colours 16-31)
	not.w	d7
	and.w	d7,d3
	beq.s	.Upper
	move.w	d3,d7			; -> the nearest colour
	and.w	(a4)+,d7
	eor.w	d7,d1
	move.w	d3,d7
	and.w	(a4)+,d7
	eor.w	d7,d2
	move.w	d3,d7
	and.w	(a4)+,d7
	eor.w	d7,d5
	and.w	(a4)+,d3
	eor.w	d3,d6
.Upper:	tst.w	d0			; Colours 16-31 ?
	beq	.Store
	tst.b	Intro_lut_one
	beq.s	.Pixels
	move.b	Intro_lut,d3		; All the same : with the planes
	or.w	d0,d1
	or.w	d0,d2
	or.w	d0,d5
	or.w	d0,d6
	not.w	d0
	lsr.b	#1,d3
	bcs.s	.S1
	and.w	d0,d1
.S1:	lsr.b	#1,d3
	bcs.s	.S2
	and.w	d0,d2
.S2:	lsr.b	#1,d3
	bcs.s	.S3
	and.w	d0,d5
.S3:	lsr.b	#1,d3
	bcs.s	.Store
	and.w	d0,d6
	bra.s	.Store
.Pixels:	lea.l	Intro_lut,a4		; Pixel by pixel
	moveq.l	#16-1,d7
.Pixel:	btst	d7,d0			; Colour 16-31 ?
	beq.s	.Lower
	moveq.l	#0,d3			; The colour
	btst	d7,d6
	beq.s	.C2
	addq.w	#8,d3
.C2:	btst	d7,d5
	beq.s	.C1
	addq.w	#4,d3
.C1:	btst	d7,d2
	beq.s	.C0
	addq.w	#2,d3
.C0:	btst	d7,d1
	beq.s	.C
	addq.w	#1,d3
.C:	move.b	0(a4,d3.w),d3		; -> ST colour
	bclr	d7,d1
	bclr	d7,d2
	bclr	d7,d5
	bclr	d7,d6
	lsr.b	#1,d3
	bcc.s	.P1
	bset	d7,d1
.P1:	lsr.b	#1,d3
	bcc.s	.P2
	bset	d7,d2
.P2:	lsr.b	#1,d3
	bcc.s	.P3
	bset	d7,d5
.P3:	lsr.b	#1,d3
	bcc.s	.Lower
	bset	d7,d6
.Lower:	dbra	d7,.Pixel
.Store:	move.w	d1,(a3)+
	move.w	d2,(a3)+
	move.w	d5,(a3)+
	move.w	d6,(a3)+
	addq.l	#2,a2
	dbra	d4,.Word
	movem.l	(sp)+,d1/d2/d5-d7/a4
	rts

;*****************************************************************************
; [ Show the converted screen ]
; Changed registers : a0 and those of the called routines
;*****************************************************************************
Intro_show:
	jsr	Pointer_into_work
	move.l	Off_screen,a0
	move.l	On_screen,Off_screen
	move.l	a0,On_screen
	move.l	a0,Shown_screen		; (no wait : the Amiga does not wait
	jsr	Set_video_base		;  for the copper either)
	move.w	VBL_counter,Intro_shown_vbl
	rts

;*****************************************************************************
; [ Wait until the last screen is really shown ]
; All registers are restored
; NOTE :
;   - The new screen is shown after the next vertical blank, the old one can
;     only be used then.
;*****************************************************************************
Intro_wait_shown:
	move.l	d0,-(sp)
	move.w	Intro_shown_vbl,d0
.Wait:	cmp.w	VBL_counter,d0
	beq.s	.Wait
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Set the colours ] (vertical blank)
; All registers are restored
; NOTE :
;   - Not while the last picture of the intro of the ST stays : its colours
;     stay ([ Intro_hold ]).
;*****************************************************************************
Intro_palette:
	tst.b	Intro_hold
	beq.s	.Go
	rts
.Go:	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Intro_h5+$121c6,a0		; The same as last time ?
	lea.l	Intro_old_palette,a1
	moveq.l	#32-1,d7
.Same:	cmpm.w	(a0)+,(a1)+
	dbne	d7,.Same
	bne.s	.Changed
	move.w	Intro_h5+$12158,d0
	cmp.w	(a1)+,d0
	bne.s	.Changed
	move.w	Intro_h5+$12150,d0
	cmp.w	(a1),d0
	beq	.Exit
.Changed:	lea.l	Intro_h5+$121c6,a0		; Keep them
	lea.l	Intro_old_palette,a1
	moveq.l	#32-1,d7
.Keep:	move.w	(a0)+,(a1)+
	dbra	d7,.Keep
	move.w	Intro_h5+$12158,(a1)+
	move.w	Intro_h5+$12150,(a1)
	lea.l	Intro_ST_palettes,a1	; The 16 colours (two buffers : the
	not.b	Intro_palette_buffer	;  events of the last frame are still
	beq.s	.Buffer			;  shown)
	lea.l	32(a1),a1
.Buffer:	move.l	a1,a3
	lea.l	Intro_h5+$121c6,a0
	moveq.l	#16-1,d7
.Colour:	move.w	(a0)+,d0
	jsr	Amiga_to_STE_colour
	move.w	d0,(a1)+
	dbra	d7,.Colour
	jsr	Intro_make_lut
	move.b	Intro_lut,Intro_star_colour
	lea.l	Intro_h5+$121c6,a0		; All black ? (only the stars are
	move.w	(a0)+,d0			;  shown, e.g. after the logo)
	moveq.l	#15-1,d7
.Black:	cmp.w	(a0)+,d0
	dbne	d7,.Black
	bne.s	.Events
	move.b	#15,Intro_star_colour	; Yes : colour 15 is theirs
	move.w	Intro_h5+$121c6+32,d0
	jsr	Amiga_to_STE_colour
	move.w	d0,30(a3)
	lea.l	Intro_lut,a0
	moveq.l	#16-1,d7
.Fill:	move.b	#15,(a0)+
	dbra	d7,.Fill
	st	Intro_lut_one
.Events:	jsr	Intro_menu_colour
	lea.l	Intro_events,a1		; The raster events : the colours
	clr.w	(a1)+
	move.w	#-1,(a1)+
	move.l	a3,(a1)+
	tst.w	Intro_h5+$12150		; Colour 1 from line 200 on ?
	beq.s	.End
	move.w	#Screen_height,d1
	sub.w	Intro_top,d1
	cmp.w	#Screen_height,d1
	bcc.s	.End
	move.w	d1,(a1)+
	move.w	#1,(a1)+
	clr.w	(a1)+
	move.w	Intro_h5+$12158,d0
	jsr	Amiga_to_STE_colour
	move.w	d0,(a1)+
.End:	move.w	#$7fff,(a1)
	lea.l	Intro_events,a0
	jsr	Show_raster_events
	tst.b	Intro_pointer_active	; (the colours of the pointer)
	beq.s	.Exit
	jsr	Intro_pointer_gfx
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ The ST colours of the colours 16-31 ]
; All registers are restored
; NOTE :
;   - [ Intro_lut ] : for each of the colours 16-31 the nearest of the
;     colours 0-15 (the sum of the differences of red, green and blue).
;     [ Intro_lut_one ] is set when they are all the same.
;*****************************************************************************
Intro_make_lut:
	movem.l	d0-d7/a0-a2,-(sp)
	lea.l	Intro_h5+$121c6+32,a0	; The colours 16-31
	lea.l	Intro_lut,a2
	st	Intro_lut_one
	moveq.l	#-1,d6			; (the colour before)
	moveq.l	#16-1,d7
.Colour:	move.w	(a0)+,d0
	cmp.w	d6,d0			; The same as the one before ?
	bne.s	.Find
	move.b	-1(a2),(a2)+
	bra.s	.Next
.Find:	move.w	d0,d6
	lea.l	Intro_h5+$121c6,a1		; The nearest
	moveq.l	#$7f,d4			; (best distance)
	moveq.l	#0,d5			; (best colour)
	moveq.l	#0,d3			; (number)
.Try:	move.w	(a1)+,d1
	jsr	Intro_distance
	cmp.w	d4,d2
	bge.s	.Worse
	move.w	d2,d4
	move.w	d3,d5
.Worse:	addq.w	#1,d3
	cmp.w	#16,d3
	blt.s	.Try
	move.b	d5,(a2)+
	cmp.l	#Intro_lut+1,a2		; (all the same ?)
	beq.s	.Next
	cmp.b	Intro_lut,d5
	beq.s	.Next
	sf	Intro_lut_one
.Next:	dbra	d7,.Colour
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ The colour of the chosen entry of the menu ] (vertical blank)
;   IN : a3 - Pointer to the 16 ST colours (.l)
; All registers are restored
; NOTE :
;   - The menu (5 planes, the texts in the colours 16-31) : colour 30 changes
;     all the time (the chosen entry). It gets an ST colour of its own : of
;     the two colours of the picture which are most alike, the one with the
;     higher number ([ Intro_merge_slot ], found by [ Intro_menu_frame ]); its
;     pixels get the other one ([ Intro_line_5 ]).
;*****************************************************************************
Menu_colour	EQU	30

Intro_menu_colour:
	movem.l	d0/d1/d5/d7/a0,-(sp)
	jsr	Intro_menu_shown		; The menu ?
	bne.s	.Off
	tst.b	Intro_merge
	beq.s	.Exit
	moveq.l	#0,d5			; Colour 30 : its ST colour
	move.b	Intro_merge_slot,d5
	move.w	Intro_h5+$121c6+2*Menu_colour,d0
	jsr	Amiga_to_STE_colour
	move.w	d5,d1
	add.w	d1,d1
	move.w	d0,0(a3,d1.w)
	lea.l	Intro_lut,a0		; The others not
	move.b	Intro_merge_to,d1
	moveq.l	#16-1,d7
.Lut:	cmp.b	(a0)+,d5
	bne.s	.Other
	move.b	d1,-1(a0)
.Other:	dbra	d7,.Lut
	move.b	d5,Intro_lut+Menu_colour-16
	bra.s	.Exit
.Off:	tst.b	Intro_merge
	beq.s	.Exit
	sf	Intro_merge
	sf	Intro_merge_wait
	clr.w	Intro_merge_colours		; (found again in the menu)
	not.w	Intro_merge_colours
.Exit:	movem.l	(sp)+,d0/d1/d5/d7/a0
	rts

; [ Is the menu shown ? ]
;  OUT : Z set : yes
Intro_menu_shown:
	cmp.w	#5,Intro_planes
	bne.s	.Exit
	tst.w	Intro_h5+$2a
	bne.s	.Exit
	tst.b	Intro_lut_one		; (all the same : the stars)
.Exit:	rts

;*****************************************************************************
; [ A frame of the main menu ] (INTRO_COMMON.S, [ Intro_menu_wait ])
; All registers are restored
; NOTE :
;   - The two colours of the picture which are most alike (see
;     [ Intro_menu_colour ]) are found when the colours stay the same (not
;     while they fade : the picture would change all the time). When they
;     change, the menu is converted again at once.
;*****************************************************************************
Intro_menu_frame:
	movem.l	d0-d7/a0/a1,-(sp)
	jsr	Intro_menu_shown
	bne	.Exit
	lea.l	Intro_h5+$121c6,a0		; New colours 0-15 ?
	lea.l	Intro_merge_colours,a1
	moveq.l	#16-1,d7
.Same:	cmpm.w	(a0)+,(a1)+
	dbne	d7,.Same
	beq.s	.Stable
	lea.l	Intro_h5+$121c6,a0		; Keep them
	lea.l	Intro_merge_colours,a1
	moveq.l	#16-1,d7
.Keep:	move.w	(a0)+,(a1)+
	dbra	d7,.Keep
	move.b	#2,Intro_merge_wait
	bra	.Exit
.Stable:	tst.b	Intro_merge_wait
	beq	.Exit
	subq.b	#1,Intro_merge_wait
	bne	.Exit
	lea.l	Intro_merge_colours,a0	; The two most alike
	move.w	#$7fff,d4
	moveq.l	#1,d3
.K:	moveq.l	#0,d5
.J:	move.w	d3,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.w	d5,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d1
	jsr	Intro_distance
	cmp.w	d4,d2
	bge.s	.Not
	move.w	d2,d4
	move.w	d3,d6			; (the one given away)
	move.w	d5,d7			; (the one its pixels get)
.Not:	addq.w	#1,d5
	cmp.w	d3,d5
	blt.s	.J
	addq.w	#1,d3
	cmp.w	#16,d3
	blt.s	.K
	tst.b	Intro_merge		; The same as before ?
	beq.s	.New
	cmp.b	Intro_merge_slot,d6
	bne.s	.New
	cmp.b	Intro_merge_to,d7
	beq.s	.Exit
.New:	sf	Intro_merge		; (the vertical blank : not now)
	lea.l	Intro_merge_masks,a1	; The masks : the bits of its number,
	move.w	d6,d0			;  the bits which change
	moveq.l	#4-1,d5
.Bits:	lsr.w	#1,d0
	scc	d1
	ext.w	d1
	move.w	d1,(a1)+
	dbra	d5,.Bits
	move.w	d6,d0
	eor.w	d7,d0
	moveq.l	#4-1,d5
.Change:	lsr.w	#1,d0
	scs	d1
	ext.w	d1
	move.w	d1,(a1)+
	dbra	d5,.Change
	move.b	d6,Intro_merge_slot
	move.b	d7,Intro_merge_to
	st	Intro_merge
	not.w	Intro_old_palette		; (the colours : made again)
	st	Intro_dirty		; (the picture : converted again)
.Exit:	movem.l	(sp)+,d0-d7/a0/a1
	rts

; [ The distance of two Amiga colours ]
;   IN : d0, d1 - Colours (.w)
;  OUT : d2 - Distance (.w)
; Changed registers : d1, d2
Intro_distance:
	movem.l	d0/d3/d4,-(sp)
	moveq.l	#0,d2
	moveq.l	#3-1,d4
.Comp:	moveq.l	#$f,d3
	and.w	d0,d3
	move.w	d1,-(sp)
	andi.w	#$f,d1
	sub.w	d1,d3
	bpl.s	.Abs
	neg.w	d3
.Abs:	add.w	d3,d2
	move.w	(sp)+,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	dbra	d4,.Comp
	movem.l	(sp)+,d0/d3/d4
	rts

;*****************************************************************************
; [ Move the stars ] (vertical blank)
; All registers are restored
; NOTE :
;   - The offsets in the table of the stars are offsets in an ST screen with
;     the lines of the Amiga ([ Intro_star_offset ]).
;   - The stars are drawn into the shown screen, in front of everything like
;     on the Amiga, in the ST colour [ Intro_star_colour ]. Every screen has a
;     list of its stars with the bytes which were there ([ Intro_star_list ]) :
;     first all are erased (from the last one on : stars in the same byte),
;     then the new ones drawn. [ Intro_present ] erases them from the screen
;     it converts.
;   - They are drawn in every second frame (the 68000 needs a quarter of the
;     time for them), in between they only move on.
;*****************************************************************************
Intro_stars:
	movem.l	d0-d7/a0-a6,-(sp)
	not.b	Intro_star_frame		; Only move on ?
	bne.s	.Draw
	lea.l	Intro_h5+$2c,a4
	move.w	#Star_count-1,d7
.Move:	move.l	(a4),a0
	tst.w	(a0)
	bpl.s	.Step
	move.l	2(a0),a0
.Step:	addq.l	#4,a0
	move.l	a0,(a4)+
	dbra	d7,.Move
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.Draw:	move.l	On_screen,a6
	jsr	Intro_star_list
	jsr	Intro_erase_stars
	lea.l	Intro_h5+$2c,a4
	move.w	Intro_top,d6
	mulu.w	#Screen_bytes_per_line,d6
	moveq.l	#0,d5			; The colour of the stars
	move.b	Intro_star_colour,d5
	add.w	d5,d5
	add.w	d5,d5
	lea.l	Star_routines,a5
	move.l	0(a5,d5.w),a5
	lea.l	2(a1),a3
	moveq.l	#0,d4			; (number of stars drawn)
	move.w	#Star_count-1,d7
.Loop:	move.l	(a4),a0			; Next position
	move.w	(a0)+,d0
	bpl.s	.Ok
	move.l	(a0)+,a0
	move.w	(a0)+,d0
.Ok:	moveq.l	#0,d1
	move.w	(a0)+,d1
	move.l	a0,(a4)+
	tst.w	d5			; (black : none)
	beq.s	.Next
	sub.l	d6,d1			; Shown ?
	bmi.s	.Next
	cmp.l	#Screen_size,d1
	bcc.s	.Next
	lea.l	0(a6,d1.l),a2
	move.l	a2,(a3)+			; Keep the bytes
	move.b	(a2),(a3)+
	move.b	2(a2),(a3)+
	move.b	4(a2),(a3)+
	move.b	6(a2),(a3)+
	jsr	(a5)			; Draw
	addq.w	#1,d4
.Next:	dbra	d7,.Loop
	move.w	d4,(a1)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Draw a star in a colour ] (a routine for each colour)
;   IN : d0 - Bit (.b)
;        a2 - Pointer to the byte of plane 0 (.l)
Star_pixel	MACRO
	IFNE	(\1)&1
	bset	d0,(a2)
	ELSE
	bclr	d0,(a2)
	ENDC
	IFNE	(\1)&2
	bset	d0,2(a2)
	ELSE
	bclr	d0,2(a2)
	ENDC
	IFNE	(\1)&4
	bset	d0,4(a2)
	ELSE
	bclr	d0,4(a2)
	ENDC
	IFNE	(\1)&8
	bset	d0,6(a2)
	ELSE
	bclr	d0,6(a2)
	ENDC
	rts
	ENDM
Star_0:	Star_pixel	0
Star_1:	Star_pixel	1
Star_2:	Star_pixel	2
Star_3:	Star_pixel	3
Star_4:	Star_pixel	4
Star_5:	Star_pixel	5
Star_6:	Star_pixel	6
Star_7:	Star_pixel	7
Star_8:	Star_pixel	8
Star_9:	Star_pixel	9
Star_10:	Star_pixel	10
Star_11:	Star_pixel	11
Star_12:	Star_pixel	12
Star_13:	Star_pixel	13
Star_14:	Star_pixel	14
Star_15:	Star_pixel	15
Star_routines:
	dc.l	Star_0,Star_1,Star_2,Star_3,Star_4,Star_5,Star_6,Star_7
	dc.l	Star_8,Star_9,Star_10,Star_11,Star_12,Star_13,Star_14,Star_15

; [ The list of the stars of a screen ]
;   IN : a6 - Pointer to the screen (.l)
;  OUT : a1 - Pointer to its list (number (.w), per star : pointer (.l) and
;             the 4 bytes) (.l)
; Changed registers : a1
Intro_star_list:
	lea.l	Intro_star_lists,a1
	cmp.l	Intro_first_screen,a6
	beq.s	.Exit
	lea.l	Star_list_size(a1),a1
.Exit:	rts

; [ Erase the stars of a screen ] (the last one first)
;   IN : a1 - Pointer to its list (.l)
; Changed registers : d0, d7, a0, a2
Intro_erase_stars:
	move.w	(a1),d7
	beq.s	.Exit
	clr.w	(a1)
	move.w	d7,d0
	lsl.w	#3,d0
	lea.l	2(a1,d0.w),a0
	subq.w	#1,d7
.Star:	subq.l	#8,a0
	move.l	(a0),a2
	move.b	4(a0),(a2)
	move.b	5(a0),2(a2)
	move.b	6(a0),4(a2)
	move.b	7(a0),6(a2)
	dbra	d7,.Star
.Exit:	rts

;*****************************************************************************
; [ Erase the stars of both screens, for new stars ]
; All registers are restored
;*****************************************************************************
Intro_clear_stars:
	movem.l	d0/d7/a0-a2/a6,-(sp)
	move.l	On_screen,a6
	jsr	Intro_star_list
	jsr	Intro_erase_stars
	move.l	Off_screen,a6
	jsr	Intro_star_list
	jsr	Intro_erase_stars
	movem.l	(sp)+,d0/d7/a0-a2/a6
	rts

;*****************************************************************************
; [ The stars become part of the Amiga screen ]
; All registers are restored
; NOTE :
;   - When the stars stop the code goes on with plane 4 of the shown Amiga
;     screen (the frozen stars) : it gets the stars of the last frame.
;*****************************************************************************
Intro_freeze_stars:
	movem.l	d0-d3/d7/a0/a1/a4,-(sp)
	move.l	Intro_h5+$20,a0		; Clear plane 4
	lea.l	160(a0),a1
	move.w	#Screen_height-1,d7
.Clear:	moveq.l	#10-1,d0
.Line:	clr.l	(a1)+
	dbra	d0,.Line
	lea.l	160(a1),a1
	dbra	d7,.Clear
	lea.l	160(a0),a0		; (plane 4)
	lea.l	Intro_h5+$2c,a4		; The last positions
	move.w	#Star_count-1,d7
.Star:	move.l	(a4)+,a1
	move.w	-4(a1),d0			; Bit
	moveq.l	#0,d1
	move.w	-2(a1),d1			; Offset in an ST screen
	divu.w	#Screen_bytes_per_line,d1
	move.w	d1,d2			; Line
	mulu.w	#200,d2
	swap	d1			; Offset in the line
	move.w	d1,d3
	andi.w	#1,d3			; (the byte of the word)
	lsr.w	#3,d1			; Chunk
	add.w	d1,d1
	add.w	d3,d1
	add.w	d1,d2
	bset.b	d0,0(a0,d2.l)
	dbra	d7,.Star
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	rts

;*****************************************************************************
; [ The offset of a star ] (INTRO.S, L01a5c : the table of the stars)
;   IN : d2 - X (.w)
;        d3 - Y (.w)
;  OUT : d3 - Offset in an ST screen with the lines of the Amiga : the byte
;             of plane 0 (.w)
; Changed registers : d2, d3
;*****************************************************************************
Intro_star_offset:
	mulu.w	#Screen_bytes_per_line,d3
	btst	#3,d2			; (the byte of the word)
	beq.s	.Even
	addq.w	#1,d3
.Even:	lsr.w	#4,d2			; The chunk
	lsl.w	#3,d2
	add.w	d2,d3
	rts

;*****************************************************************************
; [ The mouse position for the code of the Amiga ] (vertical blank)
; All registers are restored
;*****************************************************************************
Intro_mouse:
	move.w	Mouse_X,Intro_h5+$12168
	move.l	d0,-(sp)
	move.w	Mouse_Y,d0
	add.w	Intro_top,d0
	move.w	d0,Intro_h5+$1216a
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Switch on the mouse pointer of the menu ]
; All registers are restored
;*****************************************************************************
Intro_pointer_on:
	movem.l	d0/a0,-(sp)
	jsr	Intro_pointer_gfx
	st	Intro_pointer_active
	clr.w	Mouse_hotspot_X
	clr.w	Mouse_hotspot_Y
	lea.l	.MA(pc),a0
	jsr	Push_MA
	move.w	Intro_h5+$12168,Mouse_X
	move.w	Intro_h5+$1216a,d0
	sub.w	Intro_top,d0
	bpl.s	.Y
	moveq.l	#0,d0
.Y:	move.w	d0,Mouse_Y
	clr.b	Mouse_off_flag
	movem.l	(sp)+,d0/a0
	rts
.MA:	dc.w	0,$130,0,Screen_height-8

;*****************************************************************************
; [ Switch off the mouse pointer of the menu ]
; All registers are restored
;*****************************************************************************
Intro_pointer_off:
	st	Mouse_off_flag
	sf	Intro_pointer_active
	jmp	Pop_MA

;*****************************************************************************
; [ The graphics of the mouse pointer of the menu ]
; All registers are restored
; NOTE :
;   - Two attached sprites of the Amiga (16 colours, the colours 16-31)
;     become [ ST_pointer_gfx ] with the ST colours of [ Intro_lut ].
;*****************************************************************************
Intro_pointer_gfx:
	movem.l	d0-d7/a0-a4,-(sp)
	lea.l	Intro_h4+$20588+4,a0	; First sprite
	lea.l	72(a0),a1			; Second sprite
	lea.l	ST_pointer_gfx,a2
	lea.l	Intro_lut,a4
	moveq.l	#16-1,d7
.Line:	movem.w	(a0)+,d0/d1
	movem.w	(a1)+,d2/d3
	move.w	d0,d4			; Mask
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	move.w	d4,(a2)+
	moveq.l	#16-1,d6
.Pixel:	moveq.l	#0,d5			; The value (from the left)
	add.w	d3,d3
	addx.w	d5,d5
	add.w	d2,d2
	addx.w	d5,d5
	add.w	d1,d1
	addx.w	d5,d5
	add.w	d0,d0
	addx.w	d5,d5
	tst.w	d5			; (0 : transparent)
	beq.s	.Colour
	move.b	0(a4,d5.w),d5		; -> ST colour
.Colour:	move.l	a2,a3			; Into the planes
	REPT	4
	lsr.b	#1,d5
	roxl.w	(a3)+
	ENDR
	dbra	d6,.Pixel
	addq.l	#8,a2
	dbra	d7,.Line
	st	Pointer_changed
	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ The music of the intro ]
;   IN : d0 - Song (0 the intro, 1 the main menu) (.w) ([ Intro_song ])
; All registers are restored
; NOTE :
;   - [ Intro_music_module ] : the songs of the ST player, each its size (.l)
;     and its data (an even number of bytes).
;*****************************************************************************
Intro_music_init:
	rts

Intro_song:
	movem.l	d0/d1/a0,-(sp)
	lea.l	Intro_music_module,a0
	tst.w	d0
	beq.s	.Song
	tst.b	Intro_native_played		; (after the whole intro of the ST
	bne.s	.Exit			;  its song goes on : its end is the menu)
	move.l	(a0),d1			; The second one
	addq.l	#1,d1
	andi.w	#$fffe,d1
	lea.l	4(a0,d1.l),a0
.Song:	jsr	_SA_Hardcalc
	jsr	_SA_StartSong
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ The memory of the intro is not needed any more ]
; All registers are restored
; NOTE :
;   - It is the end of the BSS : the memory of the program is made smaller
;     (GEMDOS Mshrink), so the game gets it.
;*****************************************************************************
Intro_free:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	Basepage,a0
	move.l	#Intro_area,d0
	sub.l	a0,d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#Mshrink,-(sp)
	trap	#GEMDOS
	lea.l	12(sp),sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts

	include	ST_KERNEL/INTRO_ST.S		; (the intro made anew for the ST)
Intro_st_data	EQU	Intro_area

;*****************************************************************************
; [ The menu entry INTRO : the intro of the Amiga program again ? ]
;  OUT : Z clear : no (the ST plays its own intro, [ Run_intro ])
;*****************************************************************************
Intro_replay:
	andi.b	#$fb,ccr
	rts

;*****************************************************************************
; [ The extro ] (only the Falcon has it)
;*****************************************************************************
Run_extro:
	rts

Star_count	EQU	$96
Star_list_size	EQU	2+8*Star_count

	SECTION	Fast_BSS,bss
Intro_shown_vbl:	ds.w 1
Intro_planes:	ds.w 1
Intro_lines:	ds.w 1
Intro_top:	ds.w 1			; The first Amiga line on the ST
Intro_first_screen:	ds.l 1
Intro_star_lists:	ds.b 2*Star_list_size		; (see [ Intro_stars ])
Intro_old_palette:	ds.w 32+2
Intro_ST_palettes:	ds.w 2*16
Intro_events:	ds.b 3*8
Intro_merge_colours:	ds.w 16
Intro_merge_masks:	ds.w 8
Intro_line_used:	ds.b 2*Screen_height
Intro_lut:	ds.b 16			; ST colours of the colours 16-31
Intro_lut_one:	ds.b 1
Intro_star_colour:	ds.b 1
Intro_star_frame:	ds.b 1
Intro_merge:	ds.b 1			; (see [ Intro_menu_colour ])
Intro_merge_slot:	ds.b 1
Intro_merge_to:	ds.b 1
Intro_merge_wait:	ds.b 1
Intro_palette_buffer:	ds.b 1
Intro_pointer_active:	ds.b 1
	even

	SECTION	Program,code
