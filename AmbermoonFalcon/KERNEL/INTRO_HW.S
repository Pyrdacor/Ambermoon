; Falcon kernel : the hardware of the intro and the main menu (INTRO.S)
;
; INTRO.S is the code of the Amiga program Ambermoon_intro, which draws into
; Amiga screens (line interleaved planes, in memory) with the CPU and the
; blitter (ST_KERNEL/INTRO_COMMON.S : the common parts). Here :
;   - The copper is gone : [ Intro_present ] converts the Amiga screen into
;     the screen of the Falcon and shows it. Colours : [ Intro_palette ].
;     Colour 1 of the lines from 200 on (the text under the picture, a copper
;     split on the Amiga) comes from the second bank.
;   - The stars move in every frame in the shown screen ([ Intro_stars ]).
;   - The mouse pointer (a sprite) is the pointer of the kernel.
;   - The music is the Sonic Arranger replay of the kernel (MUSIC.S) with the
;     module of Intro_music.
; The screens have up to 256 lines ([ Intro_video ]), a VGA monitor shows 240.

Intro_screen_size	EQU	256*Screen_bytes_per_line
Videl_VFT	EQU	$ffff82a2

	SECTION	Program,code

;*****************************************************************************
; [ Take over the screens ]
; All registers are restored
;*****************************************************************************
Intro_init:
	movem.l	d0/a0-a2,-(sp)
	tst.l	VBL_hook			; (again after "intro" in the menu)
	bne.s	.Hook
	move.l	On_screen,Intro_old_on
	move.l	Off_screen,Intro_old_off
	move.w	Videl_VDB,Intro_old_vdb
	move.w	Videl_VDE,Intro_old_vde
	move.l	#Intro_buffers+255,d0	; Screens, aligned to 256 bytes
	andi.w	#$ff00,d0
	move.l	d0,On_screen
	move.l	d0,Intro_first_screen
	add.l	#Intro_screen_size,d0
	move.l	d0,Off_screen
	move.l	d0,Work_screen
	move.l	On_screen,a0
	jsr	Set_video_base
	jsr	Reset_MA_stack
	jsr	Reset_Mptr_stack
	jsr	Intro_clear
.Hook:	st	Mouse_off_flag		; (no pointer before the menu)
	lea.l	L02522,a0
	move.l	a0,VBL_hook
	movem.l	(sp)+,d0/a0-a2
	rts

;*****************************************************************************
; [ Give the screens back ]
; All registers are restored
;*****************************************************************************
Intro_exit:
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	VBL_hook
	jsr	My_vsync
	sf	Pointer_records+Rec_drawn	; (the screens of the game have no
	sf	Pointer_records+Rec_size+Rec_drawn	;  pointer yet)
	jsr	Reset_MA_stack
	move.l	Intro_old_on,a0
	move.l	a0,On_screen
	move.l	Intro_old_off,Off_screen
	move.l	Intro_old_off,Work_screen
	jsr	Set_video_base
	move.w	Intro_old_vdb,Videl_VDB
	move.w	Intro_old_vde,Videl_VDE
	jsr	Init_copper		; (black colours)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Clear both screens ]
; All registers are restored
;*****************************************************************************
Intro_clear:
	movem.l	d0/d7/a0,-(sp)
	sf	Pointer_records+Rec_drawn	; (no pointer in the screens : its
	sf	Pointer_records+Rec_size+Rec_drawn	;  background is gone)
	lea.l	Intro_line_used,a0		; (no line has anything)
	move.w	#2*5*256/4-1,d7
.Used:	clr.l	(a0)+
	dbra	d7,.Used
	lea.l	Intro_buffers,a0
	move.l	#(2*Intro_screen_size+256)/16-1,d7
	moveq.l	#0,d0
.Loop:	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	subq.l	#1,d7
	bpl.s	.Loop
	movem.l	(sp)+,d0/d7/a0
	rts

;*****************************************************************************
; [ Set the size of the display ]
;   IN : d0 - Number of lines (.w)
;        d1 - Number of planes (.w)
; All registers are restored
; NOTE :
;   - The VIDEL shows the lines around the middle of the display of the game
;     (VDB / VDE in half lines, up to the end of the frame).
;*****************************************************************************
Intro_video:
	movem.l	d0-d4,-(sp)
	move.w	Intro_planes,d4		; (fewer planes : the old ones must go)
	cmp.w	d1,d4
	sgt	d4
	move.w	d1,Intro_planes
	move.w	Intro_old_vde,d1		; Half lines per line
	sub.w	Intro_old_vdb,d1
	ext.l	d1
	divu.w	#Screen_height,d1
	move.w	d0,d2			; Lines above and below the 200
	sub.w	#Screen_height,d2
	mulu.w	d1,d2
	lsr.w	#1,d2
	move.w	Intro_old_vdb,d3
	sub.w	d2,d3
	bpl.s	.Top
	moveq.l	#0,d3			; (at the top of the frame)
.Top:	add.w	Intro_old_vde,d2
	cmp.w	Videl_VFT,d2		; Not more than the frame
	bcs.s	.Bottom
	move.w	Videl_VFT,d2
	subq.w	#2,d2
.Bottom:	move.w	d3,Videl_VDB
	move.w	d2,Videl_VDE
	sub.w	d3,d2			; The lines which are shown
	ext.l	d2
	divu.w	d1,d2
	cmp.w	d0,d2
	bls.s	.Lines
	move.w	d0,d2
.Lines:	cmp.w	Intro_lines,d2		; The picture stays (the menu goes from
	bne.s	.Clear			;  4 to 5 planes with the same picture)
	tst.b	d4
	beq.s	.Keep
.Clear:	jsr	Intro_clear
.Keep:	move.w	d2,Intro_lines
	move.w	#$2c81,Intro_custom+$8e	; The whole display window
	add.w	#$2c,d0
	lsl.w	#8,d0
	move.b	#$c1,d0
	move.w	d0,Intro_custom+$90
	movem.l	(sp)+,d0-d4
	rts

;*****************************************************************************
; [ Show the Amiga screen ] (the copper list and its screen change on the Amiga)
; All registers are restored
;*****************************************************************************
Intro_present:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Intro_wait_shown
	move.l	Off_screen,a3		; The pointer out of the screen which is
	jsr	Pointer_record		;  converted (else its background from
	jsr	Restore_pointer		;  before comes back : the menu)
	move.l	Intro_h5+$20,a0		; The Amiga screen
	move.l	Off_screen,a1
	lea.l	Intro_line_used,a6		; (the lines of this screen)
	cmp.l	Intro_first_screen,a1
	beq.s	.Table
	add.w	#5*256,a6
.Table:	move.w	Intro_planes,d6
	move.w	d6,d5			; Bytes per line
	mulu.w	#40,d5
	sub.w	#40,d5			; (from the end of a plane line)
	move.w	d5,a5
	tst.w	Intro_h5+$2a		; Stars : plane 4 is theirs (the Amiga
	beq.s	.Planes			;  clears it in every frame)
	moveq.l	#4,d6
.Planes:	subq.w	#1,d6
.Plane:	move.l	a0,a2
	move.l	a1,a3
	move.l	a6,a4
	move.w	Intro_lines,d7
	subq.w	#1,d7
.Line:	movem.l	(a2),d0-d5		; Anything in this line ?
	or.l	d1,d0
	or.l	d2,d0
	or.l	d3,d0
	or.l	d4,d0
	or.l	d5,d0
	movem.l	24(a2),d1-d4
	or.l	d1,d0
	or.l	d2,d0
	or.l	d3,d0
	or.l	d4,d0
	move.b	(a4),d1			; (and in the screen ?)
	tst.l	d0
	sne	(a4)+
	bne.s	.Convert
	tst.b	d1
	bne.s	.Convert
	lea.l	40(a2),a2			; Empty and empty : nothing to do
	lea.l	Screen_bytes_per_line(a3),a3
	bra.s	.Skip
.Convert:	moveq.l	#4-1,d4			; 20 words, the plane of the chunks
.Word:	move.w	(a2)+,(a3)
	move.w	(a2)+,16(a3)
	move.w	(a2)+,32(a3)
	move.w	(a2)+,48(a3)
	move.w	(a2)+,64(a3)
	lea.l	80(a3),a3
	dbra	d4,.Word
.Skip:	add.w	a5,a2
	dbra	d7,.Line
	lea.l	40(a0),a0
	addq.l	#2,a1
	add.w	#256,a6
	dbra	d6,.Plane
; ---------- The text under the picture ------------
	tst.w	Intro_h5+$12150		; Colour split ?
	beq.s	.No_split
	move.w	Intro_lines,d7
	sub.w	#Screen_height,d7
	ble.s	.No_split
	move.l	Off_screen,a1		; Plane 5 : the second bank
	add.l	#Screen_height*Screen_bytes_per_line+10,a1
	mulu.w	#20,d7
	subq.w	#1,d7
.Bank:	move.w	#-1,(a1)
	lea.l	16(a1),a1
	dbra	d7,.Bank
.No_split:
; ---------- The display window ---------------------
	moveq.l	#0,d0			; First line
	move.b	Intro_custom+$8e,d0
	sub.w	#$2c,d0
	bpl.s	.Y1
	moveq.l	#0,d0
.Y1:	moveq.l	#0,d1			; After the last line
	move.b	Intro_custom+$90,d1
	cmp.w	#$80,d1
	bcc.s	.Y2
	add.w	#$100,d1
.Y2:	sub.w	#$2c,d1
	move.l	Off_screen,a1
	move.w	d0,d7			; Above
	jsr	Intro_clear_lines
	move.w	Intro_lines,d7		; Below
	sub.w	d1,d7
	ble.s	.Window
	move.l	Off_screen,a1
	mulu.w	#Screen_bytes_per_line,d1
	add.l	d1,a1
	jsr	Intro_clear_lines
.Window:
	jsr	Intro_show
	move.l	Off_screen,Work_screen
	jsr	Pointer_out_of_work
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Clear lines of a screen ]
;   IN : d7 - Number of lines (.w), a1 - Pointer to the first line (.l)
; Changed registers : d2, d3, d7, a1
Intro_clear_lines:
	subq.w	#1,d7
	bmi.s	.Exit
	moveq.l	#0,d2
.Line:	moveq.l	#Screen_bytes_per_line/16-1,d3
.Chunk:	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	dbra	d3,.Chunk
	dbra	d7,.Line
.Exit:	rts

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
; Changed registers : d0-d2, d7, a0-a2
;*****************************************************************************
Intro_palette:
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
	lea.l	Intro_h5+$121c6,a0		; The 32 colours of the intro
	lea.l	Videl_palette,a1
	lea.l	Nibble_to_videl,a2
	moveq.l	#32-1,d7
.Loop:	move.w	(a0)+,d0
	jsr	Amiga_to_videl
	move.l	d1,(a1)+
	dbra	d7,.Loop
	tst.w	Intro_h5+$12150		; The second bank : with the colour
	beq.s	.Exit			;  of the text
	lea.l	Videl_palette,a0
	moveq.l	#32-1,d7
.Bank:	move.l	(a0)+,(a1)+
	dbra	d7,.Bank
	move.w	Intro_h5+$12158,d0
	jsr	Amiga_to_videl
	move.l	d1,Videl_palette+33*4
.Exit:	rts

;*****************************************************************************
; [ Move the stars ] (vertical blank)
; Changed registers : d0-d2, d7, a0-a2, a4, a6
; NOTE :
;   - The offsets in the table of the stars are offsets in a Falcon screen
;     (INTRO.S, L01a5c). The last positions are erased : plane 4 has nothing
;     else. They go into both screens : the shown one changes at any time.
;*****************************************************************************
Intro_stars:
	move.l	Intro_first_screen,a6
	lea.l	Intro_screen_size(a6),a2
	lea.l	Intro_h5+$2c,a4
	lea.l	Intro_star_last,a1
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	#$95,d7
.Loop:	move.w	(a1),d2			; Erase
	beq.s	.New
	clr.b	0(a6,d2.l)
	clr.b	0(a2,d2.l)
.New:	move.l	(a4),a0			; Next position
	move.w	(a0)+,d0
	bpl.s	.Ok
	move.l	(a0)+,a0
	move.w	(a0)+,d0
.Ok:	move.w	(a0)+,d1
	move.l	a0,(a4)+
	move.w	d1,(a1)+
	bset.b	d0,0(a6,d1.l)
	bset.b	d0,0(a2,d1.l)
	dbra	d7,.Loop
	rts

;*****************************************************************************
; [ Clear plane 4 of both screens, for the stars ]
; All registers are restored
;*****************************************************************************
Intro_clear_stars:
	movem.l	d7/a0,-(sp)
	move.l	Intro_first_screen,a0
	addq.l	#8,a0
	move.w	#2*256*20-1,d7
.Loop:	clr.w	(a0)
	lea.l	16(a0),a0
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
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
	lea.l	Intro_h5+$2c,a4		; The last positions
	move.w	#$95,d7
.Star:	move.l	(a4)+,a1
	move.w	-4(a1),d0			; Bit
	moveq.l	#0,d1
	move.w	-2(a1),d1			; Offset in a Falcon screen
	divu.w	#Screen_bytes_per_line,d1
	move.w	d1,d2			; Line
	mulu.w	#200,d2
	swap	d1			; Offset in the line
	move.w	d1,d3
	andi.w	#1,d3			; (the byte of the word)
	lsr.w	#4,d1			; Chunk
	add.w	d1,d1
	add.w	d3,d1
	add.w	d1,d2
	bset.b	d0,160(a0,d2.l)
	dbra	d7,.Star
	movem.l	(sp)+,d0-d3/d7/a0/a1/a4
	rts

;*****************************************************************************
; [ Switch on the mouse pointer of the menu ]
; All registers are restored
; NOTE :
;   - The sprites of the Amiga (two attached sprites : 16 colours, the colours
;     16-31) become the graphics of the kernel pointer.
;*****************************************************************************
Intro_pointer_on:
	movem.l	d0-d7/a0-a2,-(sp)
	lea.l	Intro_h4+$20588+4,a0	; First sprite
	lea.l	72(a0),a1			; Second sprite
	lea.l	Falcon_pointer_gfx,a2
	moveq.l	#16-1,d7
.Loop:	movem.w	(a0)+,d0/d1
	movem.w	(a1)+,d2/d3
	move.w	d0,d4			; Mask
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	move.w	d4,(a2)+
	move.w	d0,(a2)+			; Planes 0-3
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)+			; Plane 4 : the colours 16-31
	clr.w	(a2)+			; Planes 5-7 : bank 0
	clr.w	(a2)+
	clr.w	(a2)+
	dbra	d7,.Loop
	clr.w	Mouse_hotspot_X
	clr.w	Mouse_hotspot_Y
	lea.l	.MA(pc),a0
	jsr	Push_MA
	move.w	Intro_h5+$12168,Mouse_X
	move.w	Intro_h5+$1216a,Mouse_Y
	st	Pointer_changed
	clr.b	Mouse_off_flag
	movem.l	(sp)+,d0-d7/a0-a2
	rts
.MA:	dc.w	0,$130,0,$f0

;*****************************************************************************
; [ Switch off the mouse pointer of the menu ]
; All registers are restored
;*****************************************************************************
Intro_pointer_off:
	st	Mouse_off_flag
	jmp	Pop_MA

;*****************************************************************************
; [ The offset of a star ] (INTRO.S, L01a5c : the table of the stars)
;   IN : d2 - X (.w)
;        d3 - Y (.w)
;  OUT : d3 - Offset in a Falcon screen : the byte of plane 4 (.w)
; Changed registers : d2, d3
;*****************************************************************************
Intro_star_offset:
	mulu.w	#Screen_bytes_per_line,d3
	btst	#3,d2			; (the byte of the word)
	beq.s	.Even
	addq.w	#1,d3
.Even:	lsr.w	#4,d2			; The chunk
	lsl.w	#4,d2
	add.w	d2,d3
	addq.w	#8,d3
	rts

;*****************************************************************************
; [ The mouse position for the code of the Amiga ] (vertical blank)
; All registers are restored
;*****************************************************************************
Intro_mouse:
	move.w	Mouse_X,Intro_h5+$12168
	move.w	Mouse_Y,Intro_h5+$1216a
	rts

;*****************************************************************************
; [ The music of the intro ]
;   IN : d0 - Song (0 the intro, 1 the main menu) (.w) ([ Intro_song ])
; All registers are restored
;*****************************************************************************
Intro_music_init:
	move.l	a0,-(sp)
	lea.l	Intro_music_module,a0
	jsr	_SA_Hardcalc
	move.l	(sp)+,a0
	rts

Intro_song:
	jmp	_SA_StartSong

;*****************************************************************************
; [ The memory of the intro is not needed any more ]
; NOTE :
;   - The Falcon keeps it : the extro uses it.
;*****************************************************************************
Intro_free:
	rts

;*****************************************************************************
; [ A frame of the main menu ] (the Falcon has all the colours : nothing)
;*****************************************************************************
Intro_menu_frame:
	rts

;*****************************************************************************
; [ The intro made anew for the machine ] (the Falcon : the one of the Amiga)
;  OUT : d1 - 0 : not played (.b)
;*****************************************************************************
Intro_native:
	moveq.l	#0,d1
	rts

;*****************************************************************************
; [ The menu entry INTRO : the intro of the Amiga program again ? ]
;  OUT : Z set : yes (the Falcon : when it was chosen)
;*****************************************************************************
Intro_replay:
	cmpi.w	#2,Intro_h5+$12172
	rts

	include	ST_KERNEL/EXTRO.S

	SECTION	Fast_BSS,bss
Intro_shown_vbl:	ds.w 1
Intro_planes:	ds.w 1
Intro_lines:	ds.w 1
Intro_old_vdb:	ds.w 1
Intro_old_vde:	ds.w 1
Intro_old_on:	ds.l 1
Intro_old_off:	ds.l 1
Intro_star_last:	ds.w $96
Intro_first_screen:	ds.l 1
Intro_old_palette:	ds.w 32+2
Intro_line_used:	ds.b 2*5*256
Intro_buffers:	ds.b 2*Intro_screen_size+256
