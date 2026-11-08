; ST kernel : the intro, the fairy and the main menu (the common parts)
;
; The Amiga programs Fantasy_intro (the fairy of Thalion) and Ambermoon_intro
; (the intro and the main menu) run as they are : FANTASY.S and INTRO.S are
; their code (made from the executables by port/tools/intro_source.py, with
; the changes of fantasy_patch.py and intro_patch.py). Here :
;   - [ Run_intro ] : the fairy, then the intro and the menu. The ST plays its
;     own intro first ([ Intro_native ], INTRO_ST.S), then the menu of the
;     Amiga program.
;   - Their data are loaded from the files Intro_data and Fantasy_data
;     (port/tools/intro_data.py) into [ Intro_area ] : the last part of the
;     BSS (INTRO.S), the fairy and her BSS first (FANTASY.S). The ST gives
;     this memory back for the game afterwards ([ Intro_free ]).
;   - The custom chips are memory ([ Intro_custom ], AMIGA_BLIT.S : the
;     blitter), the mouse buttons ([ Intro_buttons ]), the comet.
; The hardware (screens, colours, stars, mouse pointer, music) : INTRO_HW.S
; and FANTASY_HW.S of each machine.

	SECTION	Program,code

;*****************************************************************************
; [ Show the fairy, the intro and the main menu ]
; NOTE :
;   - Called in [ Start_program ] after [ Init_system ].
;   - Without the files of the intro the game starts at once.
;*****************************************************************************
Run_intro:
	lea.l	.Fantasy(pc),a0		; The fairy
	lea.l	Fant_h1,a1
	move.l	#Fantasy_data_size,d0
	jsr	Intro_load_file
	bne.s	.No_fairy
	jsr	Fantasy_main
.No_fairy:	jsr	Timer_C_on		; Is there a savegame ?
	clr.w	-(sp)			; Fopen("DATA\SAVES", read)
	pea	.Saves(pc)
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
	moveq.l	#0,d1			; The intro made anew for the machine
	tst.w	Intro_last_save		;  (not with a savegame : the menu at
	bne.s	.Menu			;  once, like the Amiga)
	jsr	Intro_native
.Menu:	lea.l	.Intro(pc),a0		; The intro and the menu of the Amiga
	lea.l	Intro_h2,a1
	move.l	#Intro_h2_size+Intro_h3_size+Intro_h4_size,d0
	jsr	Intro_load_file
	bne	.Exit
	lea.l	Intro_h5,a0		; Its BSS (the fairy was there)
	move.l	#(Intro_h6_end-Intro_h5)/4-1,d7
.Clear:	clr.l	(a0)+
	subq.l	#1,d7
	bpl.s	.Clear
	tst.w	Intro_last_save
	sne	d0
	or.b	d0,d1			; (the intro is skipped : the menu)
	jsr	Intro_main
	move.w	d0,Intro_menu_choice
	cmp.w	#2,d0			; The intro again ? (the machine plays
	bne.s	.Not_intro		;  its own, then the menu)
	jsr	Intro_native
	bra.s	.Menu
.Not_intro:	cmp.w	#3,d0			; Quit ?
	bne.s	.Exit
	jmp	Exit_program
.Exit:	jmp	Intro_free
.Saves:	dc.b	"DATA\SAVES",0
.Fantasy:	dc.b	"Fantasy_data",0
.Intro:	dc.b	"Intro_data",0
	even

;*****************************************************************************
; [ Load a file of the intro ]
;   IN : d0 - Size (.l)
;        a0 - Pointer to the name (.l)
;        a1 - Pointer to the memory (.l)
;  OUT : Z set if the file was loaded
; All registers are restored
;*****************************************************************************
Intro_load_file:
	movem.l	d0-d4/a0-a2,-(sp)
	move.l	d0,d4
	move.l	a0,d1			; Open
	move.l	#1005,d2
	jsr	Dos_Open
	tst.l	d0
	beq.s	.Error
	move.l	d0,d1			; Read
	move.l	a1,d2
	move.l	d4,d3
	jsr	Dos_Read
	move.l	d0,d2
	jsr	Dos_Close
	cmp.l	d4,d2			; Complete ?
	bne.s	.Error
	moveq.l	#0,d0
	bra.s	.Exit
.Error:	moveq.l	#-1,d0
.Exit:	movem.l	(sp)+,d0-d4/a0-a2
	rts

;*****************************************************************************
; [ Wait for a frame in the main menu ]
; All registers are restored
; NOTE :
;   - The menu draws its texts into the shown Amiga screen : they are
;     converted when something was drawn.
;*****************************************************************************
Intro_menu_wait:
	jsr	Intro_menu_frame		; (the machine : INTRO_HW.S)
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

; [ The colours of the main menu come ]
; NOTE :
;   - From black (like the Amiga). After the intro made anew for the machine
;     at once : its end screen ends with them. Its last picture (the main
;     menu) was shown until now ([ Intro_hold ]) : now the menu.
Intro_menu_in:
	lea.l	(Intro_h1+$180).l,a4
	tst.b	Intro_native_played
	beq	L01616
	movem.l	d0-d7,-(sp)
	movem.l	(a4),d0-d7
	movem.l	d0-d7,(Intro_h5+$121c6).l
	movem.l	(sp)+,d0-d7
	sf	Intro_hold
	jmp	Intro_present

	SECTION	Fast_BSS,bss
Intro_native_played:	ds.b 1			; ($ff : the intro of the machine came to its end)
Intro_hold:	ds.b 1			; ($ff : its last picture stays, the menu is made)
	even
Intro_ciaa:	ds.w 1			; CIAA PRA
Intro_dirty:	ds.w 1
Intro_last_save:	ds.w 1

	SECTION	Program,code
