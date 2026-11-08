; ST kernel : the intro, made anew for the ST
;
; The intro of the Amiga (INTRO.S) draws with the blitter, which the ST does not
; have in this way. Here the intro is made anew (like Intro.cs of Ambermoon.net),
; with the graphics in the format of the ST screen (port/tools/intro_st.py :
; the file Intro_st, loaded into the memory of the intro). Everything depends on
; the ticks since the start (50 per second) : when a frame takes longer, the
; next one shows the right state, the intro stays with the music.
;   - Three screens : one is drawn while the others are shown or wait to be
;     shown. What was drawn into a screen is noted, it is cleared before the
;     screen is drawn again.
;   - The ST shows the Amiga lines from [ Ist_top ] on.
; Afterwards the main menu of the Amiga program (INTRO.S) comes.

Ist_stars_count	EQU	150
Ist_rects_count	EQU	9			; (the logo or the town, PRESENTS or
					;  its name, 5 objects, 2 sparks)
Ist_objects_tick	EQU	915			; (the planets come)
Ist_spark_size	EQU	4*47*10			; (a frame : 4 chunks, 47 lines, mask)

	SECTION	Program,code

;*****************************************************************************
; [ Play the intro ]
;  OUT : d1 - $ff : it was played (the menu comes at once), 0 : not (.b)
; All registers are restored except d1
; NOTE :
;   - Called by [ Run_intro ]. A mouse button ends it.
;*****************************************************************************
Intro_native:
	movem.l	d0/d2-d7/a0-a6,-(sp)
	lea.l	.Name(pc),a0		; The data
	lea.l	Intro_st_data,a1
	move.l	#Intro_st_size,d0
	jsr	Intro_load_file
	bne	.Not
	jsr	Ist_init
	moveq.l	#0,d0			; The music
	jsr	Intro_song
.Loop:	move.w	VBL_counter,d0		; The ticks since the start
	sub.w	Ist_start,d0
	move.w	d0,Ist_ticks
	jsr	Ist_scenes
	tst.b	Ist_end
	bne.s	.End
	jsr	Ist_frame
	btst.b	#1,ST_mouse_buttons		; (a button : the end)
	bne.s	.End
	btst.b	#0,ST_mouse_buttons
	beq.s	.Loop
.End:	move.b	Ist_end,Intro_native_played	; (to its end : the colours of the
	jsr	Ist_exit			;  menu at once)
	st	d1
	bra.s	.Exit
.Not:	sf	Intro_native_played
	moveq.l	#0,d1
.Exit:	movem.l	(sp)+,d0/d2-d7/a0-a6
	rts
.Name:	dc.b	"Intro_st",0
	even

;*****************************************************************************
; [ Start : the screens, the interrupt ]
; All registers are restored
;*****************************************************************************
Ist_init:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	On_screen,Ist_game_screens		; Three screens : the two of
	move.l	Off_screen,Ist_game_screens+4		;  the game and one in the
	move.l	On_screen,Ist_screens			;  memory of the intro
	move.l	Off_screen,Ist_screens+4
	move.l	#Intro_st_data+Intro_st_size+255,d0
	andi.w	#$ff00,d0
	move.l	d0,Ist_screens+8
	lea.l	Ist_screens,a2
	moveq.l	#3-1,d6
.Clear:	move.l	(a2)+,a0
	jsr	Clear_screen
	dbra	d6,.Clear
	lea.l	Ist_records,a0		; (nothing in the screens)
	move.w	#3*Ist_record_size/2-1,d7
.Records:	clr.w	(a0)+
	dbra	d7,.Records
	lea.l	Ist_records,a0		; (no page of the credits)
	moveq.l	#3-1,d7
.Pages:	st	Ist_rec_page(a0)
	lea.l	Ist_record_size(a0),a0
	dbra	d7,.Pages
	move.w	#-1,Ist_low_colour
	move.w	#-1,Ist_next_low
	sf	Ist_next_new
	move.w	#-1,Ist_star_cache_ticks
	clr.l	Ist_logo			; (nothing from the last time)
	clr.w	Ist_presents_lines
	sf	Ist_end
	sf	Ist_scene
	move.w	#-1,Ist_palette_level
	clr.w	Ist_shown_vbl
	st	Mouse_off_flag
	lea.l	Ist_vbl,a0
	move.l	a0,VBL_hook
	jsr	My_vsync
	move.w	VBL_counter,Ist_start
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ The end : the screens of the game ]
; All registers are restored
; NOTE :
;   - After the whole intro the main menu comes without a break (like the
;     Amiga) : the music goes on (its end is the song of the menu), the last
;     picture (the main menu) stays in the last screen, which is not in the
;     memory of the Amiga program, until the menu of the Amiga program is
;     there ([ Intro_hold ], [ Intro_menu_in ]). The interrupt stays for the
;     music.
;*****************************************************************************
Ist_exit:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	Ist_end			; The whole intro ?
	bne.s	.Hold
	jsr	_SA_StopSong
	clr.l	VBL_hook
	jsr	Init_copper		; (black)
	jsr	My_vsync
	move.l	Ist_game_screens,a0
	move.l	a0,On_screen
	move.l	a0,Shown_screen
	jsr	Set_video_base
	jsr	Clear_screen
	move.l	Ist_game_screens+4,a0
	move.l	a0,Off_screen
	move.l	a0,Work_screen
	jsr	Clear_screen
	bra.s	.Exit
.Hold:	move.l	Ist_screens+8,a6		; The last picture into the last screen
	move.l	Shown_screen,a0
	cmp.l	a0,a6
	beq.s	.Shown
	jsr	Ist_copy_screen
	move.l	a6,a0
	move.l	a0,Shown_screen
	jsr	Set_video_base
.Shown:	st	Intro_hold
	move.l	Ist_game_screens,On_screen
	move.l	Ist_game_screens+4,a0
	move.l	a0,Off_screen
	move.l	a0,Work_screen
.Exit:	jsr	My_vsync
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ The vertical blank ] (VBL_hook)
; NOTE :
;   - The music (like the interrupt of the Amiga program).
;   - The colours : when [ Ist_colours ] changed. Colour 1 of the lines of
;     the credits : [ Ist_low_colour ] (-1 : the same).
;*****************************************************************************
Ist_vbl:
	jsr	_SA_IrqLowLevel		; The music
	tst.b	Ist_colours_new
	beq.s	.Exit
	sf	Ist_colours_new
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Intro_events,a1		; The raster events : the colours
	clr.w	(a1)+
	move.w	#-1,(a1)+
	lea.l	Ist_colours,a0
	lea.l	Intro_ST_palettes,a2	; (two buffers : the events of the last
	not.b	Intro_palette_buffer	;  frame are still shown)
	beq.s	.Buffer
	lea.l	32(a2),a2
.Buffer:	move.l	a2,(a1)+
	moveq.l	#16-1,d7
.Copy:	move.w	(a0)+,(a2)+
	dbra	d7,.Copy
	move.w	Ist_low_colour,d0
	bmi.s	.End
	move.w	#Ist_credits_line,(a1)+
	move.w	#1,(a1)+
	clr.w	(a1)+
	move.w	d0,(a1)+
.End:	move.w	#$7fff,(a1)
	lea.l	Intro_events,a0
	jsr	Show_raster_events
	movem.l	(sp)+,d0-d7/a0-a3
.Exit:	rts

;*****************************************************************************
; [ The colours ]
;   IN : d0 - Level 0 (black) - 15 (.w)
;        a0 - Pointer to 16 Amiga colours (.l)
; All registers are restored
; NOTE :
;   - Every component times the level / 15. The ST colours go to
;     [ Ist_next_colours ], they are shown with the next screen.
;*****************************************************************************
Ist_set_colours:
	movem.l	d0-d4/d7/a0/a1,-(sp)
	lea.l	Ist_next_colours,a1
	moveq.l	#16-1,d7
.Colour:	move.w	(a0)+,d1
	moveq.l	#0,d4			; (the new colour)
	moveq.l	#0,d3			; (the shift of the component)
.Comp:	move.w	d1,d2			; Component * level / 15
	lsr.w	d3,d2
	andi.w	#$f,d2
	mulu.w	d0,d2
	divu.w	#15,d2
	lsl.w	d3,d2
	or.w	d2,d4
	addq.w	#4,d3
	cmp.w	#12,d3
	blt.s	.Comp
	move.w	d0,-(sp)
	move.w	d4,d0
	jsr	Amiga_to_STE_colour
	move.w	d0,(a1)+
	move.w	(sp)+,d0
	dbra	d7,.Colour
	st	Ist_next_new
	movem.l	(sp)+,d0-d4/d7/a0/a1
	rts

;*****************************************************************************
; [ Show the drawn screen ]
; All registers are restored
; NOTE :
;   - It is shown with the next vertical blank; the next one drawn is the
;     third screen (neither shown nor waiting).
;*****************************************************************************
Ist_present:
	movem.l	d0/a0/a1,-(sp)
	move.w	Ist_shown_vbl,d0		; (the one before is shown)
.Wait:	cmp.w	VBL_counter,d0
	beq.s	.Wait
	tst.b	Ist_next_new		; Its colours : first (the vertical
	beq.s	.Same			;  blank makes the colours of the
	sf	Ist_next_new		;  lines for the next frame), then
	lea.l	Ist_next_colours,a0	;  the screen
	lea.l	Ist_colours,a1
	moveq.l	#16-1,d0
.Copy:	move.w	(a0)+,(a1)+
	dbra	d0,.Copy
	move.w	Ist_next_low,Ist_low_colour
	st	Ist_colours_new
	move.w	VBL_counter,d0
.Vbl:	cmp.w	VBL_counter,d0
	beq.s	.Vbl
.Same:	move.l	Off_screen,a0		; Show it
	move.l	a0,Shown_screen
	jsr	Set_video_base
	move.w	VBL_counter,Ist_shown_vbl
	lea.l	Ist_screens,a1		; The next one : the third
.Find:	move.l	(a1)+,d0
	cmp.l	On_screen,d0
	beq.s	.Find
	cmp.l	a0,d0
	beq.s	.Find
	move.l	a0,On_screen
	move.l	d0,Off_screen
	move.l	d0,Work_screen
	movem.l	(sp)+,d0/a0/a1
	rts

; [ The record of the screen which is drawn ]
;  OUT : a5 - Pointer to the record (.l)
; Changed registers : a5
Ist_record:
	lea.l	Ist_records,a5
	move.l	a0,-(sp)
	move.l	Off_screen,a0
	cmp.l	Ist_screens,a0
	beq.s	.Exit
	lea.l	Ist_record_size(a5),a5
	cmp.l	Ist_screens+4,a0
	beq.s	.Exit
	lea.l	Ist_record_size(a5),a5
.Exit:	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ The scenes ] (state from the ticks)
; All registers are restored
; NOTE :
;   - Like Intro.cs of Ambermoon.net : the stars from tick 0, the logo of
;     Thalion from tick 61 (its colours come in 60 ticks, from tick 63 it
;     gets bigger, 32 per tick from $900 to $100, the text PRESENTS after 192
;     ticks, a line every 2 ticks, after 220 more ticks it goes in 64 ticks),
;     then the lettering Ambermoon (64 per tick, it goes after 200 ticks). The
;     stars stop at tick 895, the planets come at tick 915.
;*****************************************************************************
Ist_scenes:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	Ist_ticks,d7
	moveq.l	#0,d0
	move.b	Ist_scene,d0
	add.w	d0,d0
	add.w	d0,d0
	lea.l	.Scenes(pc),a0
	move.l	0(a0,d0.w),a0
	jsr	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.Scenes:	dc.l	Ist_scene_stars,Ist_scene_logo,Ist_scene_logo,Ist_scene_after
	dc.l	Ist_scene_objects,Ist_scene_twinlake,Ist_scene_towns,Ist_scene_end

; The stars before the logo
Ist_scene_stars:
	move.w	#Ist_star_thalion,Ist_star_colour
	tst.w	Ist_palette_level		; (the colours : black, white stars)
	bpl.s	.Colours
	clr.w	Ist_palette_level
	lea.l	Ist_white_stars,a0
	moveq.l	#15,d0
	jsr	Ist_set_colours
.Colours:	cmp.w	#61,d7			; The logo ?
	blt.s	.Exit
	move.b	#1,Ist_scene
	move.w	#61,Ist_logo_start
	move.w	#-1,Ist_fade_out
	move.w	#-1,Ist_palette_level
	clr.l	Ist_logo
.Exit:	rts

; A logo (scene 1 : Thalion, 2 : Ambermoon)
Ist_scene_logo:
	move.w	d7,d6			; d6 : ticks of the logo
	sub.w	Ist_logo_start,d6
	bmi	.Exit
	lea.l	Ist_thalion,a2		; (the frames, the speed, the colours)
	moveq.l	#0,d5
	move.w	#Ist_star_thalion,Ist_star_colour
	cmp.b	#1,Ist_scene
	beq.s	.Thalion
	lea.l	Ist_ambermoon,a2
	moveq.l	#1,d5
	move.w	#Ist_star_ambermoon,Ist_star_colour
.Thalion:	tst.w	Ist_fade_out		; Fading out ?
	bpl	.Out
	move.w	d6,d0			; The colours : in 60 ticks
	mulu.w	#15,d0
	divu.w	#60,d0
	cmp.w	#15,d0
	bls.s	.Level
	moveq.l	#15,d0
.Level:	bsr	.Colours
	move.w	d6,d0			; The frame : from the third tick on
	subq.w	#2,d0
	bmi.s	.Text
	cmp.w	(a2),d0
	blt.s	.Frame
	move.w	(a2),d0
	subq.w	#1,d0
.Frame:	add.w	d0,d0
	add.w	d0,d0
	move.l	2(a2,d0.w),d0
	add.l	a2,d0
	move.l	d0,Ist_logo
.Text:	tst.w	d5			; PRESENTS : after 192 ticks
	bne.s	.Ambermoon
	sub.w	#192,d6
	bmi.s	.Exit
	move.w	d6,d0			; (a line every 2 ticks)
	lsr.w	#1,d0
	addq.w	#1,d0
	cmp.w	#22,d0
	bls.s	.Lines
	moveq.l	#22,d0
.Lines:	move.w	d0,Ist_presents_lines
	cmp.w	#220,d6			; Then 220 ticks
	blt.s	.Exit
	move.w	d7,Ist_fade_out
	bra.s	.Exit
.Ambermoon:	cmp.w	#200,d6			; Ambermoon : after 200 ticks
	blt.s	.Exit
	move.w	d7,Ist_fade_out
.Exit:	rts
.Out:	move.w	d7,d0			; Fading out : 16 steps of 4 ticks
	sub.w	Ist_fade_out,d0
	lsr.w	#2,d0
	moveq.l	#15,d1
	sub.w	d0,d1
	bmi.s	.Done
	move.w	d1,d0
	bra.s	.Colours
.Done:	clr.l	Ist_logo			; Next
	clr.w	Ist_presents_lines
	move.w	#-1,Ist_fade_out
	move.w	#-1,Ist_palette_level
	move.w	d7,Ist_logo_start
	addq.w	#1,Ist_logo_start
	addq.b	#1,Ist_scene
	rts
; the colours of the logo d5 at the level d0 (the stars white)
.Colours:	cmp.w	Ist_palette_level,d0
	beq.s	.Same
	move.w	d0,Ist_palette_level
	lea.l	Ist_palettes,a0
	move.w	d5,d1
	lsl.w	#6,d1
	add.w	d1,a0
	lea.l	Ist_logo_colours,a1		; (a copy : the colour of the stars)
	moveq.l	#16-1,d1
.Copy:	move.w	(a0)+,(a1)+
	dbra	d1,.Copy
	lea.l	Ist_logo_colours,a0
	jsr	Ist_set_colours
	move.w	Ist_star_colour,d1		; (the stars : white)
	add.w	d1,d1
	lea.l	Ist_next_colours,a1
	move.w	#$0fff,d0
	jsr	Amiga_to_STE_colour
	move.w	d0,0(a1,d1.w)
.Same:	rts

; After the logos : the stars until tick 895, the planets from tick 915 on
Ist_scene_after:
	move.w	#Ist_star_ambermoon,Ist_star_colour
	cmp.w	#Ist_objects_tick,d7
	blt.s	.Exit
	move.b	#4,Ist_scene
	move.w	#-1,Ist_upper_index
.Exit:	rts

; The planets, the meteor, the sun, the towns and the credits : the state of
; the tick from [ Ist_timeline ] (intro_st.py) : zoom, colour of the credits
; (ST), palette of the upper part, page of the credits, frame of the sparks,
; town
Ist_scene_objects:
	move.w	#1,Ist_star_colour		; (white in the palette of the planets)
	sub.w	#Ist_objects_tick,d7
	lea.l	Ist_timeline,a0
	cmp.w	(a0)+,d7
	blt.s	.In
	move.w	-2(a0),d0			; Twinlake : 2 ticks after the last
	add.w	#Ist_objects_tick+1,d0
	move.w	d0,Ist_scene_start
	move.b	#5,Ist_scene
	rts
.In:	lsl.w	#3,d7
	add.w	d7,a0
	move.l	a0,Ist_entry
	moveq.l	#0,d0			; The colours
	move.b	4(a0),d0
	move.w	2(a0),d1
	bra	Ist_upper_colours

; Twinlake : per tick the palette and the last change of the animation
; ($ff : none)
Ist_scene_twinlake:
	sub.w	Ist_scene_start,d7
	bpl.s	.Started
	moveq.l	#0,d7
.Started:	lea.l	Ist_tw_timeline,a0
	cmp.w	(a0)+,d7
	blt.s	.In
	move.w	-2(a0),d0			; The towns : 40 ticks after the last
	add.w	#40-1,d0
	add.w	d0,Ist_scene_start
	move.b	#6,Ist_scene
	rts
.In:	add.w	d7,d7
	add.w	d7,a0
	move.l	a0,Ist_entry
	moveq.l	#0,d0
	move.b	(a0),d0
	moveq.l	#-1,d1
	bra	Ist_upper_colours

; The destruction of the towns : per tick the town (0-5), the palette, x, y,
; width, height of the meteor (.w, width 0 : none)
Ist_scene_towns:
	sub.w	Ist_scene_start,d7
	bpl.s	.Started
	moveq.l	#0,d7
.Started:	lea.l	Ist_de_timeline,a0
	cmp.w	(a0)+,d7
	blt.s	.In
	move.w	-2(a0),d0			; The end screen : at the last tick
	subq.w	#1,d0
	add.w	d0,Ist_scene_start
	move.b	#7,Ist_scene
	rts
.In:	mulu.w	#10,d7
	add.l	d7,a0
	move.l	a0,Ist_entry
	moveq.l	#0,d0
	move.b	1(a0),d0
	moveq.l	#-1,d1
	bra	Ist_upper_colours

; The end screen : per tick the palette (.w), the phase (0 : the first
; picture, 1 : the clouds), x of the clouds, the first and the end chunk of the
; main menu (.w)
Ist_scene_end:
	sub.w	Ist_scene_start,d7
	bpl.s	.Started
	moveq.l	#0,d7
.Started:	lea.l	Ist_es_timeline,a0
	cmp.w	(a0)+,d7
	blt.s	.In
	st	Ist_end			; The main menu
	rts
.In:	mulu.w	#10,d7
	add.l	d7,a0
	move.l	a0,Ist_entry
	move.w	(a0),d0
	moveq.l	#-1,d1
;	bra	Ist_upper_colours

; [ The colours : a palette of [ Ist_upper ] ]
;   IN : d0 - Palette (.w)
;        d1 - Colour 1 of the credits (ST, -1 : none) (.w)
; Changed registers : d0, a1, a2
Ist_upper_colours:
	cmp.w	Ist_upper_index,d0
	bne.s	.New
	cmp.w	Ist_next_low,d1
	beq.s	.Exit
.New:	move.w	d0,Ist_upper_index
	lsl.w	#5,d0
	lea.l	Ist_upper,a1
	add.w	d0,a1
	lea.l	Ist_next_colours,a2
	moveq.l	#16-1,d0
.Copy:	move.w	(a1)+,(a2)+
	dbra	d0,.Copy
	move.w	d1,Ist_next_low
	st	Ist_next_new
.Exit:	rts

;*****************************************************************************
; [ Draw a frame and show it ]
; All registers are restored
;*****************************************************************************
Ist_frame:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Ist_record
	move.l	Off_screen,a6
	jsr	Ist_clear_last		; What was drawn into this screen
	cmp.b	#4,Ist_scene		; The planets ?
	bne.s	.Not_objects
	jsr	Ist_draw_objects
	jsr	Ist_draw_credits
	bra.s	.Show
.Not_objects:
	cmp.b	#5,Ist_scene		; Twinlake ?
	bne.s	.Not_twinlake
	jsr	Ist_draw_twinlake
	bra.s	.Show
.Not_twinlake:
	cmp.b	#6,Ist_scene		; The destruction of the towns ?
	bne.s	.Not_towns
	jsr	Ist_draw_towns
	bra.s	.Show
.Not_towns:
	cmp.b	#7,Ist_scene		; The end screen ?
	bne.s	.Logos
	jsr	Ist_draw_end
	bra.s	.Show
.Logos:	move.l	Ist_logo,d0		; The logo
	beq.s	.No_logo
	move.l	d0,a0
	moveq.l	#0,d1			; (all lines)
	move.w	6(a0),d1
	lea.l	0(a5),a4			; (its rectangle)
	jsr	Ist_block
.No_logo:	move.w	Ist_presents_lines,d1	; PRESENTS
	beq.s	.No_text
	lea.l	Ist_presents,a0
	lea.l	8(a5),a4
	jsr	Ist_block
.No_text:	jsr	Ist_draw_stars		; The stars (in front)
.Show:	jsr	Ist_present
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Clear what was drawn into the screen the last time ]
;   IN : a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d7, a0-a3
;*****************************************************************************
Ist_clear_last:
	lea.l	0(a5),a0			; The rectangles
	moveq.l	#Ist_rects_count-1,d6
.Rect:	move.w	(a0),d7			; (lines)
	beq.s	.Next
	clr.w	(a0)
	move.w	2(a0),d0			; (first line)
	mulu.w	#Screen_bytes_per_line,d0
	move.w	4(a0),d1			; (first chunk)
	lsl.w	#3,d1
	add.w	d1,d0
	lea.l	0(a6,d0.l),a1
	move.w	6(a0),d1			; (chunks)
	subq.w	#1,d7
	moveq.l	#0,d2
.Line:	move.l	a1,a2
	move.w	d1,d3
	subq.w	#1,d3
.Chunk:	move.l	d2,(a2)+
	move.l	d2,(a2)+
	dbra	d3,.Chunk
	lea.l	Screen_bytes_per_line(a1),a1
	dbra	d7,.Line
.Next:	addq.l	#8,a0
	dbra	d6,.Rect
	lea.l	Ist_star_offsets(a5),a0	; The stars
	move.w	#Ist_stars_count-1,d7
	moveq.l	#0,d1
.Star:	move.w	(a0),d1
	cmp.w	#$ffff,d1
	beq.s	.No_star
	move.w	#$ffff,(a0)
	lea.l	0(a6,d1.l),a1
	clr.b	(a1)			; (black : the whole byte, nothing else
	clr.b	2(a1)			;  is there but the stars, the logo is
	clr.b	4(a1)			;  drawn again)
	clr.b	6(a1)
.No_star:	addq.l	#2,a0
	dbra	d7,.Star
	rts

;*****************************************************************************
; [ Draw a block (the lines of chunks of a picture) ]
;   IN : d1 - Lines to draw (from the top) (.w)
;        a0 - Pointer to the block : first chunk, chunks, line, lines (.w),
;             the lines (.l)
;        a4 - Pointer to its rectangle in the record (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d7, a0-a3
;*****************************************************************************
Ist_block:
	movem.w	(a0)+,d2-d5		; Chunk, chunks, line, lines
	cmp.w	d5,d1			; (the lines to draw)
	bge.s	.All
	move.w	d1,d5
.All:	tst.w	d4			; Clip at the top
	bpl.s	.Top
	add.w	d4,d5
	move.w	d4,d0
	neg.w	d0
	mulu.w	d3,d0
	lsl.l	#3,d0
	add.l	d0,a0
	moveq.l	#0,d4
.Top:	move.w	#Screen_height,d0		; Clip at the bottom
	sub.w	d4,d0
	cmp.w	d0,d5
	ble.s	.Bottom
	move.w	d0,d5
.Bottom:	tst.w	d5
	ble.s	.Exit
	move.w	d5,(a4)			; (the rectangle)
	move.w	d4,2(a4)
	move.w	d2,4(a4)
	move.w	d3,6(a4)
	mulu.w	#Screen_bytes_per_line,d4
	lsl.w	#3,d2
	add.w	d2,d4
	lea.l	0(a6,d4.l),a1
	subq.w	#1,d5
.Line:	move.l	a1,a2
	move.w	d3,d0
	subq.w	#1,d0
.Chunk:	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbra	d0,.Chunk
	lea.l	Screen_bytes_per_line(a1),a1
	dbra	d5,.Line
.Exit:	rts

;*****************************************************************************
; [ Draw the stars ] (in front of everything)
;   IN : a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d7, a0-a4
; NOTE :
;   - The position of a star : its position at the start plus the ticks,
;     round its positions (until they stop, [ Ist_stars_stop ]).
;*****************************************************************************
Ist_draw_stars:
	move.w	Ist_ticks,d4		; The ticks of the stars
	cmp.w	#Ist_stop_tick,d4
	ble.s	.Ticks
	move.w	#Ist_stop_tick,d4
.Ticks:	move.w	Ist_star_colour,d0		; The colour
	add.w	d0,d0
	add.w	d0,d0
	lea.l	Star_routines,a3
	move.l	0(a3,d0.w),a3
	lea.l	Ist_star_offsets(a5),a4
	move.w	#Ist_stars_count-1,d7
	lea.l	Ist_star_cache,a1		; The same ticks as the last time ?
	cmp.w	Ist_star_cache_ticks,d4	;  (the stars stop)
	beq.s	.Cached
	move.l	a1,a2
	bra.s	.New
.Cached:	moveq.l	#0,d1
	move.w	(a1)+,d1
	move.w	(a1)+,d0
	cmp.w	#$ffff,d1
	beq.s	.None
	move.w	d1,(a4)
	lea.l	0(a6,d1.l),a2
	jsr	(a3)
.None:	addq.l	#2,a4
	dbra	d7,.Cached
	rts
.New:	move.w	d4,Ist_star_cache_ticks	; The positions : offset, bit
	moveq.l	#0,d0
	lea.l	Ist_stars,a1
.Star:	moveq.l	#0,d1			; (the position : start + ticks
	move.w	2(a1),d1			;  modulo the number)
	add.w	d4,d1
	divu.w	(a1),d1
	swap	d1
	lsl.w	#2,d1
	lea.l	Ist_stars,a0
	add.l	4(a1),a0
	add.w	d1,a0
	move.w	(a0)+,(a2)+		; Offset
	move.b	(a0),d0			; Bit
	move.w	d0,(a2)+
	addq.l	#8,a1
	dbra	d7,.Star
	lea.l	Ist_star_cache,a1		; Draw them
	move.w	#Ist_stars_count-1,d7
	bra.s	.Cached

Ist_stop_tick	EQU	895

;*****************************************************************************
; [ Draw the planets, the meteor, the sun, the sparks or a town ]
;   IN : a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d7, a0-a4
; NOTE :
;   - A town : in front of black, without the stars.
;*****************************************************************************
Ist_draw_objects:
	move.l	Ist_entry,a0
	moveq.l	#0,d0
	move.b	7(a0),d0			; A town ?
	cmp.b	#$ff,d0
	beq.s	.Objects
	lsl.w	#2,d0
	move.w	d0,-(sp)
	lea.l	Ist_towns,a0		; The picture
	add.l	0(a0,d0.w),a0
	move.w	#Screen_height,d1
	lea.l	0(a5),a4
	jsr	Ist_block
	move.w	(sp)+,d0			; The name
	lea.l	Ist_town_names,a0
	add.l	0(a0,d0.w),a0
	move.w	#Screen_height,d1
	lea.l	8(a5),a4
	jsr	Ist_block
	rts
.Objects:	jsr	Ist_draw_stars		; The stars (behind)
	moveq.l	#0,d0			; The objects (the last in front)
.Object:	jsr	Ist_object
	addq.w	#1,d0
	cmp.w	#5,d0
	blt.s	.Object
	move.l	Ist_entry,a0		; The sparks
	moveq.l	#0,d0
	move.b	6(a0),d0
	cmp.b	#$ff,d0
	beq.s	.Exit
	mulu.w	#Ist_spark_size,d0
	lea.l	Ist_sparks,a0
	add.l	d0,a0
	move.l	a0,-(sp)
	moveq.l	#48/16,d2
	lea.l	7*8(a5),a4
	jsr	Ist_spark
	move.l	(sp)+,a0			; (the other : 15 frames later)
	add.l	#15*Ist_spark_size,a0
	moveq.l	#192/16,d2
	lea.l	8*8(a5),a4
	jsr	Ist_spark
.Exit:	rts

; [ Draw the sparks ] (4 chunks, 47 lines from the Amiga line 153 on, masked)
;   IN : d2 - First chunk (.w)
;        a0 - Pointer to the frame (.l)
;        a4 - Pointer to its rectangle in the record (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d2, d6, d7, a0-a2
Ist_spark:
	move.w	#47,(a4)
	move.w	#153-Ist_top,2(a4)
	move.w	d2,4(a4)
	move.w	#4,6(a4)
	lea.l	(153-Ist_top)*Screen_bytes_per_line(a6),a1
	lsl.w	#3,d2
	add.w	d2,a1
	moveq.l	#47-1,d7
.Line:	move.l	a1,a2
	moveq.l	#4-1,d6
.Chunk:	move.w	(a0)+,d0
	not.w	d0
	REPT	4
	and.w	d0,(a2)
	move.w	(a0)+,d1
	or.w	d1,(a2)+
	ENDR
	dbra	d6,.Chunk
	lea.l	Screen_bytes_per_line(a1),a1
	dbra	d7,.Line
	rts

;*****************************************************************************
; [ Draw Twinlake ]
;   IN : a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d3, d7, a0-a2
; NOTE :
;   - The picture once per screen, then the changes of the animation since
;     the last one drawn into the screen (each change : the chunks which
;     change).
;*****************************************************************************
Ist_draw_twinlake:
	cmp.b	#5,Ist_rec_static(a5)	; The picture
	beq.s	.Picture
	move.b	#5,Ist_rec_static(a5)
	move.w	#-1,Ist_rec_part(a5)
	lea.l	Ist_tw_picture,a0
	bsr	Ist_copy_screen
.Picture:	move.l	Ist_entry,a0		; The last change
	move.b	1(a0),d0
	ext.w	d0			; ($ff : -1)
	move.w	Ist_rec_part(a5),d1
.Change:	cmp.w	d0,d1
	bge.s	.Done
	addq.w	#1,d1
	move.w	d1,d2
	lsl.w	#2,d2
	lea.l	Ist_tw_parts,a0
	add.l	0(a0,d2.w),a0
	move.w	(a0)+,d7
	bra.s	.Next
.Chunk:	move.w	(a0)+,d2
	lea.l	0(a6,d2.w),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
.Next:	dbra	d7,.Chunk
	bra.s	.Change
.Done:	move.w	d1,Ist_rec_part(a5)
	rts

;*****************************************************************************
; [ Draw the destruction of the towns ] (a town, the meteor)
;   IN : a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d7, a0-a4
;*****************************************************************************
Ist_draw_towns:
	cmp.b	#6,Ist_rec_static(a5)	; (black, once per screen)
	beq.s	.Black
	move.b	#6,Ist_rec_static(a5)
	move.l	a6,a0
	jsr	Clear_screen
.Black:	move.l	Ist_entry,a0		; The town
	moveq.l	#0,d0
	move.b	(a0),d0
	lsl.w	#2,d0
	lea.l	Ist_towns,a0
	add.l	0(a0,d0.w),a0
	move.w	#Screen_height,d1
	lea.l	0(a5),a4
	jsr	Ist_block
	move.l	Ist_entry,a0		; The meteor
	movem.w	2(a0),d0-d3
	tst.w	d2
	beq.s	.Exit
	moveq.l	#96,d4
	moveq.l	#88,d5
	lea.l	Ist_de_meteor,a3
	lea.l	2*8(a5),a4
	jsr	Ist_scaled
.Exit:	rts

;*****************************************************************************
; [ Draw the end screen ]
;   IN : a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0-d7, a0-a4, a6
; NOTE :
;   - The first picture once per screen. Then every frame black (colour 15)
;     and the chunks of the main menu which are shown, the clouds of the left
;     and of the right in front of them.
;*****************************************************************************
Ist_draw_end:
	move.l	Ist_entry,a0
	tst.b	2(a0)			; Phase
	bne.s	.Clouds
	cmp.b	#7,Ist_rec_static(a5)	; The first picture
	beq	.Exit
	move.b	#7,Ist_rec_static(a5)
	lea.l	Ist_es_first,a0
	bra.s	Ist_copy_screen
.Clouds:	move.b	#8,Ist_rec_static(a5)
	movem.w	6(a0),d4-d5		; First, end chunk of the main menu
	lea.l	Ist_es_menu,a0
	move.l	a6,a1
	moveq.l	#-1,d0
	move.w	#Screen_height-1,d7
.Line:	moveq.l	#0,d6			; (the chunk)
.Chunk:	cmp.w	d4,d6
	blt.s	.Black
	cmp.w	d5,d6
	bge.s	.Black
	move.l	(a0)+,(a1)+		; The main menu
	move.l	(a0)+,(a1)+
	bra.s	.Next
.Black:	move.l	d0,(a1)+			; Black
	move.l	d0,(a1)+
	addq.l	#8,a0
.Next:	addq.w	#1,d6
	cmp.w	#20,d6
	blt.s	.Chunk
	dbra	d7,.Line
	move.l	Ist_entry,a0		; The clouds of the left
	move.w	4(a0),d0
	moveq.l	#7,d5
	move.w	#Screen_height,d6
	lea.l	Ist_es_left,a0
	move.l	a6,-(sp)
	jsr	St_sprite
	move.l	(sp),a6
	move.l	Ist_entry,a0		; Of the right
	move.w	#208,d0
	sub.w	4(a0),d0
	moveq.l	#7,d5
	move.w	#Screen_height,d6
	lea.l	Ist_es_right,a0
	jsr	St_sprite
	move.l	(sp)+,a6
.Exit:	rts

; [ Copy a picture into the screen ]
;   IN : a0 - Pointer to the picture (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d7, a0, a1
Ist_copy_screen:
	move.l	a6,a1
	move.w	#Screen_size/16-1,d7
.Copy:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,.Copy
	rts

;*****************************************************************************
; [ Draw the page of the credits ] (the lines from [ Ist_credits_line ] on)
;   IN : a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; Changed registers : d0, d7, a0, a1
; NOTE :
;   - Only when the screen has another page. A page : plane 0 (colour 1).
;*****************************************************************************
Ist_draw_credits:
	move.l	Ist_entry,a0
	move.b	5(a0),d0
	cmp.b	Ist_rec_page(a5),d0
	beq.s	.Exit
	move.b	d0,Ist_rec_page(a5)
	lea.l	Ist_credits_line*Screen_bytes_per_line(a6),a1
	move.w	#(Screen_height-Ist_credits_line)*20-1,d7
	cmp.b	#$ff,d0
	beq.s	.Clear
	andi.w	#$ff,d0
	mulu.w	#(Screen_height-Ist_credits_line)*20*2,d0
	lea.l	Ist_pages,a0
	add.l	d0,a0
.Copy:	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	clr.l	(a1)+
	dbra	d7,.Copy
	rts
.Clear:	clr.l	(a1)+
	clr.l	(a1)+
	dbra	d7,.Clear
.Exit:	rts

;*****************************************************************************
; [ Draw an object scaled ] (a planet, the meteor, the sun)
;   IN : d0 - Object 0-4 (.w)
;        a5 - Pointer to the record of the screen (.l)
;        a6 - Pointer to the screen (.l)
; All registers are restored
; NOTE :
;   - Like Intro.cs : the distance is the distance of the object minus the
;     zoom; the position and the size are its values * 256 / distance. The
;     meteor stops at a zoom of [ Ist_meteor_end ].
;   - The pixels of the object : colour * 16 (0 : transparent). The columns
;     of the screen get their pixel of the object once ([ Ist_cols ] : per
;     chunk the pixels and their masks), the lines which show the same line
;     of the object get the same line of chunks ([ Ist_line ]).
;*****************************************************************************
Ist_object:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Ist_rects+2*8(a5),a4	; (its rectangle)
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a4
	move.w	d0,d1			; The zoom info
	mulu.w	#20,d1
	lea.l	Ist_objects,a0
	add.w	d1,a0
	move.l	Ist_entry,a1
	move.w	(a1),d7			; (the zoom)
	cmp.w	#3,d0
	bne.s	.Zoom
	cmp.w	#Ist_meteor_end,d7
	blt.s	.Zoom
	move.w	#Ist_meteor_zoom,d7
.Zoom:	move.l	16(a0),d1			; The pixels
	lea.l	Ist_objects,a3
	add.l	d1,a3
	cmp.w	#4,d0			; (the sun : the frame)
	bne.s	.Pixels
	move.w	Ist_ticks,d1
	ext.l	d1
	divu.w	#48,d1
	swap	d1
	lsr.w	#2,d1
	mulu.w	#64*64,d1
	add.l	d1,a3
.Pixels:	move.l	a3,Io_source
	move.w	4(a0),d6			; Distance - zoom + 256
	sub.w	d7,d6
	add.w	#256,d6
	ble	.Exit
	movem.w	(a0),d0-d3		; End x, end y, width, height
	movem.w	6(a0),d2-d3
	ext.l	d0			; x = 160 + end x * 256 / distance
	asl.l	#8,d0
	divs.w	d6,d0
	bvs	.Exit
	add.w	#160,d0
	ext.l	d1			; y = 100 - end y * 256 / distance
	asl.l	#8,d1
	divs.w	d6,d1
	bvs	.Exit
	neg.w	d1
	add.w	#100,d1
	ext.l	d2			; The size * 256 / distance
	asl.l	#8,d2
	divs.w	d6,d2
	bvs	.Exit
	ext.l	d3
	asl.l	#8,d3
	divs.w	d6,d3
	bvs	.Exit
	tst.w	d2
	ble	.Exit
	tst.w	d3
	ble	.Exit
	move.w	d2,d4			; (the middle)
	asr.w	#1,d4
	sub.w	d4,d0
	move.w	d3,d4
	asr.w	#1,d4
	sub.w	d4,d1
	move.w	10(a0),d4			; (the size of the picture)
	move.w	12(a0),d5
	bsr	Ist_scaled
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw a picture scaled ]
;   IN : d0 - x (Amiga) (.w)
;        d1 - y (Amiga line) (.w)
;        d2 - Width (> 0) (.w)
;        d3 - Height (> 0) (.w)
;        d4 - Width of the picture (.w)
;        d5 - Height of the picture (.w)
;        a3 - Pointer to the pixels of the picture (colour * 16, 0 :
;             transparent) (.l)
;        a4 - Pointer to its rectangle in the record (.l)
;        a6 - Pointer to the screen (.l)
; All registers are restored
; NOTE :
;   - Clipped to the Amiga lines [ Ist_top ] - 199. See [ Ist_object ].
;*****************************************************************************
Ist_scaled:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a3,Io_source
	move.w	d4,Io_source_width
	move.w	d5,Io_source_height
	movem.w	d0-d3,Io_x		; x, y, width, height
	move.w	d0,d4			; Clip : x
	bpl.s	.Left
	moveq.l	#0,d4
.Left:	move.w	d0,d5
	add.w	d2,d5
	cmp.w	#320,d5
	ble.s	.Right
	move.w	#320,d5
.Right:	cmp.w	d5,d4
	bge	.Exit
	movem.w	d4-d5,Io_xs		; (first, end)
	move.w	d1,d4			; y : the lines of the Amiga from
	cmp.w	#Ist_top,d4		;  Ist_top to 200
	bge.s	.Top
	move.w	#Ist_top,d4
.Top:	move.w	d1,d5
	add.w	d3,d5
	cmp.w	#200,d5
	ble.s	.Bottom
	move.w	#200,d5
.Bottom:	cmp.w	d5,d4
	bge	.Exit
	movem.w	d4-d5,Io_ys
	move.w	Io_xs,d0			; The rectangle
	lsr.w	#4,d0
	move.w	Io_xe,d1
	subq.w	#1,d1
	lsr.w	#4,d1
	sub.w	d0,d1
	move.w	d1,Io_chunks		; (- 1)
	addq.w	#1,d1
	move.w	d5,(a4)
	sub.w	d4,(a4)
	sub.w	#Ist_top,d4
	move.w	d4,2(a4)
	move.w	d0,4(a4)
	move.w	d1,6(a4)
	mulu.w	#Screen_bytes_per_line,d4	; (the first chunk on the screen)
	lsl.w	#3,d0
	add.w	d0,d4
	add.l	a6,d4
	move.l	d4,Io_screen
	move.w	Io_source_width,d0		; The steps (16.16) : x
	move.w	Io_width,d1
	bsr	Ist_ratio
	move.l	d0,d5
	move.w	Io_source_height,d0		; y
	move.w	Io_height,d1
	bsr	Ist_ratio
	move.l	d0,Io_step_y
	move.w	Io_ys,d0			; (the first line of the object)
	sub.w	Io_y,d0
	move.l	Io_step_y,d1
	bsr	Ist_mul
	move.l	d1,Io_fy
	move.w	Io_xs,d0			; The columns : per chunk the number of
	sub.w	Io_x,d0			;  pixels of the object (- 1) and
	move.l	d5,d1			;  per pixel its offset and mask
	bsr	Ist_mul
	move.l	d1,d4			; (x of the object, 16.16)
	move.w	Io_xs,d2
	move.w	Io_xe,d3
	lea.l	Ist_cols,a1
	move.w	d2,d0
	andi.w	#15,d0
	move.w	#$8000,d6
	lsr.w	d0,d6
.Chunk:	move.l	a1,a2
	addq.l	#2,a1
	moveq.l	#-1,d7
	moveq.l	#-1,d1
.Column:	move.l	d4,d0
	swap	d0
	cmp.w	d1,d0
	beq.s	.Same
	move.w	d0,d1
	addq.w	#1,d7
	move.w	d0,(a1)+
	move.w	d6,(a1)+
	bra.s	.Next
.Same:	or.w	d6,-2(a1)
.Next:	add.l	d5,d4
	addq.w	#1,d2
	cmp.w	d3,d2
	beq.s	.Done
	lsr.w	#1,d6
	bne.s	.Column
	move.w	d7,(a2)
	move.w	#$8000,d6
	bra.s	.Chunk
.Done:	move.w	d7,(a2)
	move.w	#-1,(a1)
	move.w	Io_ye,d0			; The lines
	sub.w	Io_ys,d0
	move.w	d0,Io_lines
	move.w	#-1,Io_last
.Line:	move.l	Io_fy,d0
	swap	d0
	cmp.w	Io_last,d0
	beq.s	.Draw
	move.w	d0,Io_last		; (another line of the object)
	mulu.w	Io_source_width,d0
	move.l	Io_source,a3
	add.l	d0,a3
	bsr	Ist_build_line
.Draw:	move.l	Io_screen,a2
	move.w	Io_chunks,d6
	bsr	Ist_apply_line
	add.l	#Screen_bytes_per_line,Io_screen
	move.l	Io_step_y,d0
	add.l	d0,Io_fy
	subq.w	#1,Io_lines
	bne.s	.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ (d0 << 16) / d1 ] (d0, d1 : .w, unsigned) -> d0 (.l)
; Changed registers : d0, d2
Ist_ratio:
	andi.l	#$ffff,d0
	divu.w	d1,d0			; (the integer part : the low word)
	move.w	d0,d2
	swap	d2
	clr.w	d0			; (the rest << 16)
	divu.w	d1,d0
	move.w	d0,d2
	move.l	d2,d0
	rts

; [ d0 * d1 ] (d0 : .w, unsigned; d1 : .l) -> d1 (.l)
; Changed registers : d1, d2
Ist_mul:
	move.l	d1,d2
	swap	d2
	mulu.w	d0,d2
	swap	d2
	clr.w	d2
	mulu.w	d0,d1
	add.l	d2,d1
	rts

; [ A line of the object into [ Ist_line ] ] (per chunk : mask, 4 planes)
;   IN : a3 - Pointer to the line of the object (.l)
; Changed registers : d0-d7, a1-a6
Ist_build_line:
	lea.l	Ist_cols,a1
	lea.l	Ist_line,a4
	lea.l	Ist_colour_blocks,a5
	lea.l	Ist_build_end,a6
	moveq.l	#0,d1
	moveq.l	#0,d0
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d7
	move.w	(a1)+,d5
Ist_build_entry:
	move.w	(a1)+,a2			; The pixel
	move.b	0(a3,a2.w),d1
	move.w	(a1)+,d6			; (its mask)
	jmp	0(a5,d1.w)
Ist_build_end:
	move.w	d0,(a4)+			; The end of the chunk
	move.w	d2,(a4)+
	move.w	d3,(a4)+
	move.w	d4,(a4)+
	move.w	d7,(a4)+
	moveq.l	#0,d0
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d7
	move.w	(a1)+,d5
	bpl.s	Ist_build_entry
	rts

; The code of a colour (16 bytes) : the mask into the planes of its bits
Ist_colour_block	MACRO
	IFNE	\1
	or.w	d6,d0
	ENDC
	IFNE	(\1)&1
	or.w	d6,d2
	ENDC
	IFNE	(\1)&2
	or.w	d6,d3
	ENDC
	IFNE	(\1)&4
	or.w	d6,d4
	ENDC
	IFNE	(\1)&8
	or.w	d6,d7
	ENDC
	dbra	d5,Ist_build_entry
	jmp	(a6)
	IFGT	5-(((\1)+15)/16+((\1)&1)+(((\1)>>1)&1)+(((\1)>>2)&1)+(((\1)>>3)&1))
	dcb.w	5-(((\1)+15)/16+((\1)&1)+(((\1)>>1)&1)+(((\1)>>2)&1)+(((\1)>>3)&1)),$4e71
	ENDC
	ENDM
Ist_colour_blocks:
	Ist_colour_block 0
	Ist_colour_block 1
	Ist_colour_block 2
	Ist_colour_block 3
	Ist_colour_block 4
	Ist_colour_block 5
	Ist_colour_block 6
	Ist_colour_block 7
	Ist_colour_block 8
	Ist_colour_block 9
	Ist_colour_block 10
	Ist_colour_block 11
	Ist_colour_block 12
	Ist_colour_block 13
	Ist_colour_block 14
	Ist_colour_block 15
	IFNE	*-Ist_colour_blocks-16*16
	FAIL	"The code of a colour must have 16 bytes"
	ENDC

; [ Draw [ Ist_line ] ]
;   IN : d6 - Chunks - 1 (.w)
;        a2 - Pointer to the first chunk on the screen (.l)
; Changed registers : d0, d1, d6, a2, a4
Ist_apply_line:
	lea.l	Ist_line,a4
.Chunk:	move.w	(a4)+,d0
	beq.s	.Skip
	cmp.w	#-1,d0
	beq.s	.Full
	not.w	d0
	REPT	4
	and.w	d0,(a2)
	move.w	(a4)+,d1
	or.w	d1,(a2)+
	ENDR
	dbra	d6,.Chunk
	rts
.Full:	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	dbra	d6,.Chunk
	rts
.Skip:	addq.l	#8,a4
	addq.l	#8,a2
	dbra	d6,.Chunk
	rts

	SECTION	Fast_DATA,data
Ist_white_stars:	dc.w	$000,$fff,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; The record of a screen : what was drawn into it
	rsreset
Ist_rects:	rs.w	4*Ist_rects_count	; Lines, first line, first chunk, chunks
Ist_star_offsets:	rs.w	Ist_stars_count		; ($ffff : none)
Ist_rec_page:	rs.b	1			; Page of the credits ($ff : none)
Ist_rec_static:	rs.b	1			; Scene of the picture drawn once
Ist_rec_part:	rs.w	1			; Twinlake : the last change (-1 : none)
Ist_record_size:	rs.b	0

	SECTION	Fast_BSS,bss
Ist_game_screens:	ds.l 2
Ist_screens:	ds.l 3
Ist_records:	ds.b 3*Ist_record_size
Ist_logo:	ds.l 1			; The frame of the logo (0 : none)
Ist_entry:	ds.l 1			; The state of the tick ([ Ist_timeline ])
Ist_upper_index:	ds.w 1			; (the palette of the upper part)
Ist_scene_start:	ds.w 1			; (tick of the start of the scene)
Ist_star_cache_ticks:	ds.w 1			; The positions of the stars at these
Ist_star_cache:	ds.l Ist_stars_count		;  ticks : offset, bit (.w)
Ist_low_colour:	ds.w 1			; Colour 1 of the credits (-1 : none)
Io_source:	ds.l 1			; The scaled object
Io_screen:	ds.l 1
Io_step_y:	ds.l 1
Io_fy:	ds.l 1
Io_x:	ds.w 1
Io_y:	ds.w 1
Io_width:	ds.w 1
Io_height:	ds.w 1
Io_xs:	ds.w 1
Io_xe:	ds.w 1
Io_ys:	ds.w 1
Io_ye:	ds.w 1
Io_chunks:	ds.w 1
Io_lines:	ds.w 1
Io_last:	ds.w 1
Io_source_width:	ds.w 1
Io_source_height:	ds.w 1
Ist_cols:	ds.w 21+320*2+1		; (per chunk : number, per pixel : 2)
Ist_line:	ds.w 21*5
Ist_start:	ds.w 1			; VBL_counter at the start
Ist_ticks:	ds.w 1
Ist_shown_vbl:	ds.w 1
Ist_logo_start:	ds.w 1
Ist_fade_out:	ds.w 1			; (tick of the start, -1 : not yet)
Ist_palette_level:	ds.w 1
Ist_presents_lines:	ds.w 1
Ist_star_colour:	ds.w 1
Ist_colours:	ds.w 16			; The ST colours
Ist_next_colours:	ds.w 16			; (those of the next screen)
Ist_next_low:	ds.w 1
Ist_logo_colours:	ds.w 16
Ist_scene:	ds.b 1
Ist_end:	ds.b 1
Ist_colours_new:	ds.b 1
Ist_next_new:	ds.b 1
	even

	SECTION	Program,code
