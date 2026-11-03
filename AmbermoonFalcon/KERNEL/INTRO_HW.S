; Falcon kernel : the hardware of the intro and the main menu (INTRO.S)
;
; INTRO.S is the code of the Amiga program Ambermoon_intro, which draws into
; Amiga screens (line interleaved planes, in memory) with the CPU and the
; blitter. Here :
;   - The custom chips are memory ([ Intro_custom ]). When a blit is started
;     [ Intro_blit ] does it with the CPU.
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
; [ Show the intro and the main menu ]
;  OUT : d0 - The chosen menu entry (0 continue, 1 new game, 3 quit) (.w)
; NOTE :
;   - Called in [ Start_program ] after [ Init_system ].
;*****************************************************************************
Run_intro:
	jsr	Fantasy_main		; The fairy
	jsr	Timer_C_on		; Is there a savegame ?
	clr.w	-(sp)			; Fopen("DATA\SAVES", read)
	pea	.Saves
	move.w	#Fopen,-(sp)
	trap	#GEMDOS
	addq.l	#8,sp
	clr.w	Intro_last_save
	tst.w	d0
	bmi.s	.No_file
	move.w	d0,-(sp)
	pea	Intro_last_save		; Fread : the number of the last one
	move.l	#2,-(sp)
	move.w	d0,-(sp)
	move.w	#Fread,-(sp)
	trap	#GEMDOS
	lea.l	12(sp),sp
	move.w	#Fclose,-(sp)		; (the handle is on the stack)
	trap	#GEMDOS
	addq.l	#4,sp
.No_file:	jsr	Timer_C_off
	tst.w	Intro_last_save
	sne	d0
	jsr	Intro_main
	move.w	d0,Intro_menu_choice
	cmp.w	#3,d0			; Quit ?
	bne.s	.Exit
	jmp	Exit_program
.Exit:	rts
.Saves:	dc.b	"DATA\SAVES",0
	even

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
; [ Wait for a frame in the main menu ]
; All registers are restored
; NOTE :
;   - The menu draws its texts into the shown Amiga screen : they are
;     converted when something was drawn.
;*****************************************************************************
Intro_menu_wait:
	tst.b	Intro_dirty
	beq.s	.Wait
	sf	Intro_dirty
	jmp	Intro_present
.Wait:	jmp	L0288a

;*****************************************************************************
; [ Wait for this step of the comet / is it late ? ]
;  OUT : Z clear if it is not drawn
; All registers are restored
; NOTE :
;   - The impact (the step after $7b0 : the flash, the destroyed town) comes
;     with the beat of the music, like on the Amiga : [ Comet_impact ] ticks
;     after the start of the town (the music has its beat there). The steps
;     before and after come at the same pace (about 3 vertical blanks, the
;     speed of the Amiga). An early step waits, a late step is not drawn.
;   - The distance in [ Intro_h5+$1212c ] goes from $36b0 down to $fe00 in steps
;     of $100. The last step is always drawn : the destroyed town stays there.
;*****************************************************************************
Comet_steps	EQU	($36b0-$7b0)/$100+2	; (the step of the impact)
Comet_draw	EQU	2			; From the wait to the screen

Intro_comet_late:
	movem.l	d0-d2,-(sp)
	moveq.l	#0,d1
	move.w	Intro_h5+$1212c,d0
	cmp.w	#$fe00+$100,d0
	beq.s	.Exit
	move.w	#$36b0+$100,d1		; The tick of the step
	sub.w	d0,d1
	lsr.w	#8,d1
	move.w	Intro_h5+$12132,d2
	add.w	d2,d2
	mulu.w	Comet_impact(pc,d2.w),d1
	divu.w	#Comet_steps,d1
	andi.l	#$ffff,d1
	move.l	d1,d2			; Early : wait
	subq.l	#Comet_draw,d2
.Wait:	cmp.l	Intro_h5+$4,d2
	bgt.s	.Wait
	cmp.l	Intro_h5+$4,d1		; Late ?
	slo	d1
	ext.w	d1
.Exit:	tst.w	d1
	movem.l	(sp)+,d0-d2
	rts

Comet_impact:	dc.w	141,155,149	; The 3 towns

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
; [ The state of the mouse buttons for the code of the Amiga ] (vertical blank)
; Changed registers : d0
; NOTE :
;   - CIAA PRA bit 6 and POTGOR bit 10 (0 : pressed).
;*****************************************************************************
Intro_buttons:
	moveq.l	#-1,d0
	btst.b	#1,ST_mouse_buttons		; Left
	beq.s	.Left
	bclr.l	#6,d0
.Left:	move.b	d0,Intro_ciaa
	moveq.l	#-1,d0
	btst.b	#0,ST_mouse_buttons		; Right
	beq.s	.Right
	bclr.l	#2,d0
.Right:	move.b	d0,Intro_custom+$16
	rts

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
; [ Do a blit ] (BLTSIZE of the Amiga)
; All registers are restored
; NOTE :
;   - The registers of the blitter are in [ Intro_custom ], at their offsets.
;     After the blit the pointers are behind the data, like on the Amiga (the
;     code goes on with them).
;*****************************************************************************
Blt_con0	EQU	$40
Blt_con1	EQU	$42
Blt_afwm	EQU	$44
Blt_alwm	EQU	$46
Blt_cpt	EQU	$48
Blt_bpt	EQU	$4c
Blt_apt	EQU	$50
Blt_dpt	EQU	$54
Blt_size	EQU	$58
Blt_cmod	EQU	$60
Blt_bmod	EQU	$62
Blt_amod	EQU	$64
Blt_dmod	EQU	$66
Blt_cdat	EQU	$70
Blt_bdat	EQU	$72
Blt_adat	EQU	$74

Star_slots	EQU	256		; The sparkles of the fairy (a slot : 512
Star_rows	EQU	46		;  bytes, 18 + 10 for each line with A)

Intro_blit:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Intro_custom,a6
	andi.w	#$fffe,Blt_apt+2(a6)	; (the blitter has even addresses only)
	andi.w	#$fffe,Blt_bpt+2(a6)
	andi.w	#$fffe,Blt_cpt+2(a6)
	andi.w	#$fffe,Blt_dpt+2(a6)
	move.w	Blt_size(a6),d0		; Size
	moveq.l	#63,d6
	and.w	d0,d6
	bne.s	.Width
	moveq.l	#64,d6
.Width:	lsr.w	#6,d0
	bne.s	.Height
	move.w	#1024,d0
.Height:	move.w	d0,Bl_height
	subq.w	#1,d6
	move.w	Blt_con0(a6),d0		; Function
	jsr	Intro_blit_fast		; (the usual cases)
	beq	.Exit
	move.w	Blt_size(a6),d6		; (again : changed by the fast way)
	andi.w	#63,d6
	bne.s	.Width2
	moveq.l	#64,d6
.Width2:	subq.w	#1,d6
	move.w	Blt_con0(a6),d0
	moveq.l	#0,d1
	move.b	d0,d1
	lea.l	Bl_generic,a5		; (d1 : minterms for the generic one)
	lea.l	.Functions(pc),a0
.Find:	move.w	(a0)+,d2
	bmi.s	.Found
	cmp.w	d1,d2
	beq.s	.Known
	addq.l	#4,a0
	bra.s	.Find
.Known:	move.l	(a0),a5
.Found:	move.w	d1,Bl_minterms
	move.w	d0,d1			; Shift of A & B
	rol.w	#4,d1
	andi.w	#15,d1
	move.w	d1,Bl_sa
	move.w	Blt_con1(a6),d1
	rol.w	#4,d1
	andi.w	#15,d1
	move.w	d1,Bl_sb
	moveq.l	#2,d1			; Direction
	btst.b	#1,Blt_con1+1(a6)
	sne	Bl_desc
	beq.s	.Up
	moveq.l	#-2,d1
.Up:	move.w	d1,Bl_step
	move.l	Blt_apt(a6),a0		; Channels
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	Blt_dpt(a6),a3
	move.w	d0,Bl_con0
	moveq.l	#0,d3			; (previous A & B)
	moveq.l	#0,d4
; ---------- Lines -------------------------------
.Line:	move.w	d6,d5
	st	Bl_first
.Word:	move.w	Bl_con0,d7
; ---------- A -----------------------------------
	btst	#11,d7
	beq.s	.No_A
	move.w	(a0),d0
	add.w	Bl_step,a0
	bra.s	.Have_A
.No_A:	move.w	Blt_adat(a6),d0
.Have_A:	tst.b	Bl_first
	beq.s	.A_last
	and.w	Blt_afwm(a6),d0
.A_last:	tst.w	d5
	bne.s	.A_mid
	and.w	Blt_alwm(a6),d0
.A_mid:	move.w	Bl_sa,d1
	tst.b	Bl_desc
	bne.s	.A_desc
	swap	d3			; Old : high word
	move.w	d0,d3
	move.l	d3,d0
	lsr.l	d1,d0
	bra.s	.B
.A_desc:	move.w	d0,d2			; New : high word, old : low word
	swap	d0
	move.w	d3,d0
	lsl.l	d1,d0
	swap	d0
	move.w	d2,d3
; ---------- B -----------------------------------
.B:	btst	#10,d7
	beq.s	.No_B
	move.w	(a1),d1
	add.w	Bl_step,a1
	bra.s	.Have_B
.No_B:	move.w	Blt_bdat(a6),d1
.Have_B:	move.w	Bl_sb,d2
	beq.s	.C_0
	tst.b	Bl_desc
	bne.s	.B_desc
	swap	d4
	move.w	d1,d4
	move.l	d4,d1
	lsr.l	d2,d1
	bra.s	.C
.B_desc:	move.w	d1,-(sp)
	swap	d1
	move.w	d4,d1
	lsl.l	d2,d1
	swap	d1
	move.w	(sp)+,d4
	bra.s	.C
.C_0:
; ---------- C -----------------------------------
.C:	btst	#9,d7
	beq.s	.No_C
	move.w	(a2),d2
	add.w	Bl_step,a2
	bra.s	.Have_C
.No_C:	move.w	Blt_cdat(a6),d2
.Have_C:	jsr	(a5)			; d0 = function(d0, d1, d2)
	btst	#8,d7			; D
	beq.s	.No_D
	move.w	d0,(a3)
	add.w	Bl_step,a3
.No_D:	sf	Bl_first
	dbra	d5,.Word
; ---------- Next line ---------------------------
	move.w	Bl_con0,d7
	tst.b	Bl_desc
	bne.s	.Mod_desc
	btst	#11,d7
	beq.s	.M1
	add.w	Blt_amod(a6),a0
.M1:	btst	#10,d7
	beq.s	.M2
	add.w	Blt_bmod(a6),a1
.M2:	btst	#9,d7
	beq.s	.M3
	add.w	Blt_cmod(a6),a2
.M3:	btst	#8,d7
	beq.s	.Next
	add.w	Blt_dmod(a6),a3
	bra.s	.Next
.Mod_desc:	btst	#11,d7
	beq.s	.M4
	sub.w	Blt_amod(a6),a0
.M4:	btst	#10,d7
	beq.s	.M5
	sub.w	Blt_bmod(a6),a1
.M5:	btst	#9,d7
	beq.s	.M6
	sub.w	Blt_cmod(a6),a2
.M6:	btst	#8,d7
	beq.s	.Next
	sub.w	Blt_dmod(a6),a3
.Next:	subq.w	#1,Bl_height
	bne	.Line
	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a3,Blt_dpt(a6)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

.Functions:
	dc.w	$f0
	dc.l	Bl_f0
	dc.w	$ca
	dc.l	Bl_ca
	dc.w	$e2
	dc.l	Bl_e2
	dc.w	$fc
	dc.l	Bl_fc
	dc.w	$fe
	dc.l	Bl_fe
	dc.w	$fa
	dc.l	Bl_fa
	dc.w	$0a
	dc.l	Bl_0a
	dc.w	$00
	dc.l	Bl_00
	dc.w	-1

;*****************************************************************************
; [ The usual blits, fast ]
;   IN : d0 - BLTCON0 (.w)
;        d6 - Width in words - 1 (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
;        [ Bl_height ]
;  OUT : Z set if the blit was done
; Changed registers : d0-d7, a0-a5
; NOTE :
;   - A copy (A to D, no shift, ascending, no masks), and one word wide with
;     all channels (the columns of the zoom : each word is one line in a plane).
;*****************************************************************************
Intro_blit_fast:
	cmp.w	#$0100,d0			; Clear ?
	bne.s	.No_clear
	tst.w	Blt_con1(a6)
	bne	.No
	move.l	Blt_dpt(a6),a3
	move.w	Blt_dmod(a6),a2
	move.w	Bl_height,d7
	subq.w	#1,d7
	moveq.l	#0,d0
.Cl_line:	move.w	d6,d5
.Cl_word:	move.w	d0,(a3)+
	dbra	d5,.Cl_word
	add.w	a2,a3
	dbra	d7,.Cl_line
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.No_clear:	move.w	d0,d1			; Cookie cut, ascending, wider than
	andi.w	#$00ff,d1			;  one word
	cmp.w	#$ca,d1
	bne.s	.No_cookie
	tst.w	d6
	beq.s	.No_cookie
	move.w	d0,d1
	andi.w	#$0f00,d1
	cmp.w	#$0f00,d1			; (A, B, C, D or B, C, D)
	beq.s	.Cookie
	cmp.w	#$0700,d1
	bne.s	.No_cookie
.Cookie:	jmp	Intro_blit_cookie
.No_cookie:
	cmp.w	#$09f0,d0			; Copy ?
	bne.s	.Column
	cmp.l	#-1,Blt_afwm(a6)
	bne.s	.No
	tst.w	Blt_con1(a6)
	bne.s	.No
	move.l	Blt_apt(a6),a0
	move.l	Blt_dpt(a6),a3
	move.w	Blt_amod(a6),a1
	move.w	Blt_dmod(a6),a2
	move.w	Bl_height,d7
	subq.w	#1,d7
.Copy:	move.w	d6,d5
.Word:	move.w	(a0)+,(a3)+
	dbra	d5,.Word
	add.w	a1,a0
	add.w	a2,a3
	dbra	d7,.Copy
	move.l	a0,Blt_apt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.No:	moveq.l	#1,d0
	rts
.Column:	tst.w	d6			; One word wide ?
	bne.s	.No
	move.w	d0,d1			; Shift
	rol.w	#4,d1
	andi.w	#15,d1
	move.w	Blt_afwm(a6),d5		; Mask
	and.w	Blt_alwm(a6),d5
	moveq.l	#0,d3			; (previous A & B)
	moveq.l	#0,d4
	move.w	Bl_height,d7
	subq.w	#1,d7
	move.l	Blt_apt(a6),a0
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	Blt_dpt(a6),a3
	move.w	Blt_amod(a6),a4
	move.w	Blt_cmod(a6),a5
	move.w	Blt_con1(a6),d2
	btst	#1,d2
	bne	.Down
; ---------- Ascending ----------------------------
	addq.w	#2,a4
	addq.w	#2,a5
	andi.w	#$0fff,d0			; (d2 : BLTCON1 : shift B = shift A)
	cmp.w	#$0fca,d0
	bne.s	.Be2
	lsr.w	#8,d2
	lsr.w	#4,d2
	cmp.w	d1,d2
	bne	.No
	move.w	Blt_bmod(a6),d6		; (the steps in registers, in the loop)
	addq.w	#2,d6
	move.w	Blt_dmod(a6),d0
	addq.w	#2,d0
	move.w	d0,a6
.Ca:	move.w	(a0),d0			; A : (A & B) | (!A & C)
	add.w	a4,a0
	and.w	d5,d0
	swap	d3
	move.w	d0,d3
	move.l	d3,d0
	lsr.l	d1,d0
	move.w	(a1),d2			; B
	add.w	d6,a1
	swap	d4
	move.w	d2,d4
	move.l	d4,d2
	lsr.l	d1,d2
	and.w	d0,d2
	not.w	d0
	and.w	(a2),d0
	add.w	a5,a2
	or.w	d2,d0
	move.w	d0,(a3)
	add.w	a6,a3
	dbra	d7,.Ca
	lea.l	Intro_custom,a6
	bra.s	.Done
.Be2:	cmp.w	#$0be2,d0
	bne	.No
	move.w	Blt_bdat(a6),d2		; (A & B) | (!B & C), B : BDAT
	move.w	Blt_dmod(a6),d0
	addq.w	#2,d0
	move.w	d0,Bl_dstep
	move.w	d2,d4
	not.w	d4
.E2:	move.w	(a0),d0
	add.w	a4,a0
	and.w	d5,d0
	swap	d3
	move.w	d0,d3
	move.l	d3,d0
	lsr.l	d1,d0
	and.w	d2,d0
	move.w	(a2),d6
	add.w	a5,a2
	and.w	d4,d6
	or.w	d6,d0
	move.w	d0,(a3)
	add.w	Bl_dstep,a3
	dbra	d7,.E2
.Done:	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
; ---------- Descending ---------------------------
.Down:	move.w	#-2,d6			; (step - modulo)
	sub.w	a4,d6
	move.w	d6,a4
	move.w	#-2,d6
	sub.w	a5,d6
	move.w	d6,a5
	move.w	#-2,d6
	sub.w	Blt_dmod(a6),d6
	move.w	d6,Bl_dstep
	andi.w	#$0fff,d0
	cmp.w	#$0fca,d0
	bne.s	.Be2_d
	lsr.w	#8,d2
	lsr.w	#4,d2
	cmp.w	d1,d2
	bne	.No
	move.w	#-2,d6
	sub.w	Blt_bmod(a6),d6
	move.w	d6,Bl_bstep
	move.w	Bl_dstep,a6		; (in a register, in the loop)
.Ca_d:	move.w	(a0),d0			; A
	add.w	a4,a0
	and.w	d5,d0
	move.w	d0,d6
	swap	d0
	move.w	d3,d0
	lsl.l	d1,d0
	swap	d0
	move.w	d6,d3
	move.w	(a1),d2			; B
	add.w	Bl_bstep,a1
	move.w	d2,d6
	swap	d2
	move.w	d4,d2
	lsl.l	d1,d2
	swap	d2
	move.w	d6,d4
	and.w	d0,d2
	not.w	d0
	and.w	(a2),d0
	add.w	a5,a2
	or.w	d2,d0
	move.w	d0,(a3)
	add.w	a6,a3
	dbra	d7,.Ca_d
	lea.l	Intro_custom,a6
	bra	.Done
.Be2_d:	cmp.w	#$0be2,d0
	bne	.No
	move.w	Blt_bdat(a6),d2
	move.w	d2,d4
	not.w	d4
.E2_d:	move.w	(a0),d0
	add.w	a4,a0
	and.w	d5,d0
	move.w	d0,d6
	swap	d0
	move.w	d3,d0
	lsl.l	d1,d0
	swap	d0
	move.w	d6,d3
	and.w	d2,d0
	move.w	(a2),d6
	add.w	a5,a2
	and.w	d4,d6
	or.w	d6,d0
	move.w	d0,(a3)
	add.w	Bl_dstep,a3
	dbra	d7,.E2_d
	bra	.Done

;*****************************************************************************
; [ Cookie cut blit, fast ]
;   IN : d0 - BLTCON0 (.w)
;        d6 - Width in words - 1 (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
;  OUT : Z set if the blit was done
; Changed registers : d0-d7, a0-a5
;*****************************************************************************
Intro_blit_cookie:
	move.w	Blt_con1(a6),d1
	btst	#1,d1			; Descending : the slow way
	bne	.No
	lsr.w	#8,d1			; Shift of B
	lsr.w	#4,d1
	move.w	d0,d2			; Shift of A
	rol.w	#4,d2
	andi.w	#15,d2
	cmp.w	d1,d2			; (the same : one shift below)
	beq.s	.Go
	btst	#11,d0			; (the mask of A only without A)
	bne	.No
	bra.s	.General
.Go:	cmp.w	#1,d6			; Two words, A only in the first one,
	bne.s	.General			;  C = D ? (the sparkles of the fairy)
	btst	#11,d0
	beq.s	.General
	cmp.l	#$ffff0000,Blt_afwm(a6)
	bne.s	.General
	move.l	Blt_cpt(a6),d3
	cmp.l	Blt_dpt(a6),d3
	bne.s	.General
	move.w	Blt_cmod(a6),d3
	cmp.w	Blt_dmod(a6),d3
	bne.s	.General
	tst.w	Blt_bmod(a6)
	beq	.Two
.General:	move.w	d1,Bl_sb
	move.w	d2,Bl_sa
	move.w	d0,Bl_con0
	move.l	Blt_apt(a6),a0
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	Blt_dpt(a6),a3
	move.w	Blt_bmod(a6),a4
	move.w	Blt_cmod(a6),a5
	moveq.l	#0,d3			; (previous A & B)
	moveq.l	#0,d4
	move.w	Bl_height,d7
	subq.w	#1,d7
.Line:	move.w	d6,d5
	move.w	Blt_afwm(a6),d1		; The first word : its mask
	bra.s	.First
.Word:	moveq.l	#-1,d1
.First:	tst.w	d5
	bne.s	.Mask
	and.w	Blt_alwm(a6),d1
.Mask:	btst	#3,Bl_con0		; A
	beq.s	.No_A
	move.w	(a0)+,d0
	bra.s	.Have_A
.No_A:	move.w	Blt_adat(a6),d0
.Have_A:	and.w	d1,d0
	swap	d3
	move.w	d0,d3
	move.l	d3,d0
	move.w	Bl_sa,d1
	lsr.l	d1,d0
	move.w	(a1)+,d2			; B
	swap	d4
	move.w	d2,d4
	move.l	d4,d2
	move.w	Bl_sb,d1
	lsr.l	d1,d2
	and.w	d0,d2			; (A & B) | (!A & C)
	not.w	d0
	and.w	(a2)+,d0
	or.w	d2,d0
	move.w	d0,(a3)+
	dbra	d5,.Word
	btst	#3,Bl_con0
	beq.s	.No_mod
	add.w	Blt_amod(a6),a0
.No_mod:	add.w	a4,a1
	add.w	a5,a2
	add.w	Blt_dmod(a6),a3
	dbra	d7,.Line
	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.No:	moveq.l	#1,d0
	rts
; Two words : the second word of A is masked, so a line without A stays C.
; (B without modulo : the B before a line is the word before it)
.Two:	move.l	Blt_apt(a6),d3		; From the data of the fairy ?
	cmp.l	#Fant_h1,d3
	bcs.s	.Two_direct
	cmp.l	#Fant_h1_end,d3
	bcc.s	.Two_direct
	cmp.w	#Star_rows,Bl_height
	bhi.s	.Two_direct
	jmp	Intro_star_blit		; Yes -> made once
.Two_direct:	move.w	d2,d5			; (the shift of A and B)
	move.l	Blt_apt(a6),a0
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	a1,a5			; (the first line : no B before it)
	move.w	Blt_amod(a6),a4
	addq.w	#4,a4
	move.w	Blt_cmod(a6),a3
	addq.w	#4,a3
	move.w	Bl_height,d7
	subq.w	#1,d7
.T_line:	tst.w	(a0)			; A ?
	bne.s	.T_draw
.T_next:	add.w	a4,a0
	addq.l	#4,a1
	add.w	a3,a2
	dbra	d7,.T_line
	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a2,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.T_draw:	move.w	(a0),d0			; A
	move.w	(a1),d2			; B
	move.w	2(a1),d3
	moveq.l	#0,d4			; (the B before)
	cmpa.l	a5,a1
	beq.s	.T_first
	move.w	-2(a1),d4
.T_first:	swap	d0			; A : the first word high, the
	clr.w	d0			;  second one low
	lsr.l	d5,d0
	move.w	d4,d1			; B : the first word
	swap	d1
	move.w	d2,d1
	lsr.l	d5,d1
	swap	d2			; B : the second word
	move.w	d3,d2
	lsr.l	d5,d2
	move.l	d0,d6			; (A & B) | (!A & C)
	swap	d6
	and.w	d6,d1
	not.w	d6
	and.w	(a2),d6
	or.w	d1,d6
	move.w	d6,(a2)
	and.w	d0,d2
	not.w	d0
	and.w	2(a2),d0
	or.w	d2,d0
	move.w	d0,2(a2)
	bra.s	.T_next

;*****************************************************************************
; [ Cookie cut blit of a sparkle ] (see [ Intro_blit_cookie ], .Two)
;   IN : d2 - Shift of A and B (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
;  OUT : Z set (the blit was done)
; Changed registers : d0-d7, a0-a5
; NOTE :
;   - A and B come from the data of the fairy, which never changes : each
;     sparkle (source, shift, size) is made once into a list of its lines with
;     A, each with the mask and the data of both words (Star_slots, the slot
;     from the source and the shift).
;*****************************************************************************
Intro_star_blit:
	move.l	Blt_apt(a6),d3		; The slot
	move.l	d3,d0
	sub.l	#Fant_h1,d0		; (the sparkles are 180 bytes apart :
	lsl.l	#2,d0			;  45 * 16 for each, with the 16
	add.w	d2,d0			;  shifts behind it)
	andi.l	#Star_slots-1,d0
	lsl.l	#8,d0			; (512 bytes)
	add.l	d0,d0
	lea.l	Star_cache,a2
	add.l	d0,a2
	cmp.l	(a2),d3			; Made already ?
	bne.s	.Make
	move.l	Blt_bpt(a6),d0
	cmp.l	4(a2),d0
	bne.s	.Make
	cmp.w	8(a2),d2
	bne.s	.Make
	move.w	Bl_height,d0
	cmp.w	10(a2),d0
	bne.s	.Make
	move.w	Blt_amod(a6),d0
	cmp.w	12(a2),d0
	bne.s	.Make
	move.w	Blt_cmod(a6),d0
	cmp.w	14(a2),d0
	beq	.Draw
.Make:	move.l	d3,(a2)			; Make the lines
	move.l	Blt_bpt(a6),4(a2)
	move.w	d2,8(a2)
	move.w	Bl_height,10(a2)
	move.w	Blt_amod(a6),12(a2)
	move.w	Blt_cmod(a6),14(a2)
	lea.l	18(a2),a3
	move.l	d3,a0			; A
	move.l	4(a2),a1			; B
	move.w	d2,d5
	moveq.l	#0,d4			; (previous B)
	moveq.l	#0,d6			; (the line in C)
	move.w	12(a2),a4
	addq.w	#4,a4
	move.w	14(a2),a5
	addq.w	#4,a5
	move.w	10(a2),d7
	subq.w	#1,d7
.M_line:	move.w	(a0),d0			; A
	move.w	(a1)+,d2			; B
	move.w	(a1)+,d3
	tst.w	d0
	beq.s	.M_next
	swap	d0			; A : the first word high, the
	clr.w	d0			;  second one low
	lsr.l	d5,d0
	move.w	d4,d1			; B : the first word
	swap	d1
	move.w	d2,d1
	lsr.l	d5,d1
	swap	d2			; B : the second word
	move.w	d3,d2
	lsr.l	d5,d2
	move.w	d6,(a3)+			; Line : the offset in C, then for
	swap	d0			;  each word !A and A & B
	and.w	d0,d1
	not.w	d0
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	swap	d0
	and.w	d0,d2
	not.w	d0
	move.w	d0,(a3)+
	move.w	d2,(a3)+
.M_next:	move.w	d3,d4
	add.w	a4,a0
	add.w	a5,d6
	dbra	d7,.M_line
	move.l	a3,d0			; Number of lines
	sub.l	a2,d0
	sub.l	#18,d0
	divu.w	#10,d0
	move.w	d0,16(a2)
.Draw:	move.l	Blt_cpt(a6),a1		; Draw : (C & !A) | (A & B)
	lea.l	16(a2),a0
	move.w	(a0)+,d7
	beq.s	.Done
	subq.w	#1,d7
.D_line:	move.w	(a0)+,d0
	lea.l	0(a1,d0.w),a3
	move.w	(a3),d1
	and.w	(a0)+,d1
	or.w	(a0)+,d1
	move.w	d1,(a3)+
	move.w	(a3),d1
	and.w	(a0)+,d1
	or.w	(a0)+,d1
	move.w	d1,(a3)
	dbra	d7,.D_line
.Done:	move.w	10(a2),d1			; The pointers behind the blit
	move.w	12(a2),d0
	addq.w	#4,d0
	mulu.w	d1,d0
	add.l	d0,Blt_apt(a6)
	moveq.l	#0,d0
	move.w	d1,d0
	lsl.l	#2,d0
	add.l	d0,Blt_bpt(a6)
	move.w	14(a2),d0
	addq.w	#4,d0
	mulu.w	d1,d0
	add.l	d0,Blt_cpt(a6)
	add.l	d0,Blt_dpt(a6)
	moveq.l	#0,d0
	rts

; The functions : IN d0 (A), d1 (B), d2 (C), OUT d0. d3 is the old A, d4 the
; old B (kept)
Bl_f0:	rts
Bl_ca:	and.w	d0,d1			; (A & B) | (!A & C)
	not.w	d0
	and.w	d2,d0
	or.w	d1,d0
	rts
Bl_e2:	and.w	d1,d0			; (A & B) | (!B & C)
	not.w	d1
	and.w	d2,d1
	or.w	d1,d0
	rts
Bl_fc:	or.w	d1,d0			; A | B
	rts
Bl_fe:	or.w	d1,d0			; A | B | C
	or.w	d2,d0
	rts
Bl_fa:	or.w	d2,d0			; A | C
	rts
Bl_0a:	not.w	d0			; !A & C
	and.w	d2,d0
	rts
Bl_00:	moveq.l	#0,d0
	rts
Bl_generic:
	movem.l	d3-d6,-(sp)		; Every minterm
	moveq.l	#0,d5
	move.w	Bl_minterms,d6
	move.w	d0,d3
	not.w	d3
	move.w	d1,d4
	not.w	d4
	lsl.b	#1,d6			; ABC
	bcc.s	.T6
	move.w	d0,-(sp)
	and.w	d1,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T6:	lsl.b	#1,d6			; AB!C
	bcc.s	.T5
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d0,(sp)
	and.w	d1,(sp)
	or.w	(sp)+,d5
.T5:	lsl.b	#1,d6			; A!BC
	bcc.s	.T4
	move.w	d0,-(sp)
	and.w	d4,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T4:	lsl.b	#1,d6			; A!B!C
	bcc.s	.T3
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d0,(sp)
	and.w	d4,(sp)
	or.w	(sp)+,d5
.T3:	lsl.b	#1,d6			; !ABC
	bcc.s	.T2
	move.w	d3,-(sp)
	and.w	d1,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T2:	lsl.b	#1,d6			; !AB!C
	bcc.s	.T1
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d3,(sp)
	and.w	d1,(sp)
	or.w	(sp)+,d5
.T1:	lsl.b	#1,d6			; !A!BC
	bcc.s	.T0
	move.w	d3,-(sp)
	and.w	d4,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T0:	lsl.b	#1,d6			; !A!B!C
	bcc.s	.Done
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d3,(sp)
	and.w	d4,(sp)
	or.w	(sp)+,d5
.Done:	move.w	d5,d0
	movem.l	(sp)+,d3-d6
	rts

	SECTION	Fast_BSS,bss
Intro_custom:	ds.b $200			; The custom chips
Intro_ciaa:	ds.w 1			; CIAA PRA
Intro_shown_vbl:	ds.w 1
Intro_dirty:	ds.w 1
Intro_last_save:	ds.w 1
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
Star_cache:	ds.b Star_slots*512		; (see [ Intro_star_blit ])
Bl_height:	ds.w 1
Bl_minterms:	ds.w 1
Bl_sa:	ds.w 1
Bl_sb:	ds.w 1
Bl_step:	ds.w 1
Bl_con0:	ds.w 1
Bl_bstep:	ds.w 1
Bl_dstep:	ds.w 1
Bl_first:	ds.b 1
Bl_desc:	ds.b 1
Intro_buffers:	ds.b 2*Intro_screen_size+256
