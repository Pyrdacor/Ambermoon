; Proof of concept : 2D map with layout and status block (Atari ST)
;
; Shows the 2D map layout, the status block with the portraits, the control
; icons and a 2D city map. The party can be moved with the cursor keys, the
; numeric keypad or the mouse (click into the map). The tiles are animated.
; ESC or UNDO exits.
;
; The display code follows the original 2D map code (MAP/2D_MAP.S,
; MAP/2D_CITY.S, MAP/MAP.S, DISPLAY.S, HULL/CONTROLS.S) closely, but without
; the module system, events, NPCs and the memory manager.

	SECTION	Program,code

;*****************************************************************************
; [ Load the data ]
;  OUT : d0 - 0 = ok (.w)
; NOTE :
;   - Called before the system is taken over.
;*****************************************************************************
Load_program_data:
	lea.l	File_list,a0
	jsr	Load_files
	tst.l	d0
	beq.s	.Exit
	move.l	a0,-(sp)			; Show error
	pea	Load_error_text
	move.w	#9,-(sp)			; Cconws
	trap	#GEMDOS
	addq.l	#6,sp
	move.w	#9,-(sp)			; (file name)
	trap	#GEMDOS
	addq.l	#6,sp
	move.w	#7,-(sp)			; Crawcin
	trap	#GEMDOS
	addq.l	#2,sp
	moveq.l	#-1,d0
.Exit:	rts

;*****************************************************************************
; [ Main program ]
;*****************************************************************************
Program_main:
	move.w	#15,Fade_level		; Start black
	lea.l	Map_RL,a0			; Set raster list
	jsr	Set_raster_list
	lea.l	Mouse_pointer,a0
	jsr	Change_Mptr
	move.w	#160,Mouse_X
	move.w	#100,Mouse_Y
	jsr	Init_map
	jsr	Invalidate_tile_caches
; ---------- Draw the static parts ----------------
	jsr	Display_status_block
	jsr	Show_map_layout
	jsr	Print_headline
	jsr	Display_control_icons
	jsr	Display_2D_map
	jsr	Copy_screen_to_both
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
; ---------- Main loop ----------------------------
.Loop:	jsr	Handle_input
	tst.b	Quit_flag
	bne.s	.Exit
	jsr	Display_2D_map
	jsr	Display_position
	jsr	Switch_screens
	bra.s	.Loop
.Exit:	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	rts

;*****************************************************************************
; [ Copy the work screen to the shown screen ]
; All registers are restored
;*****************************************************************************
Copy_screen_to_both:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Work_screen,a0
	move.l	On_screen,a1
	cmp.l	a0,a1
	beq.s	.Exit
	move.w	#ST_screen_size/4-1,d7
.Loop:	move.l	(a0)+,(a1)+
	dbra	d7,.Loop
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Initialize the map ]
; All registers are restored
;*****************************************************************************
Init_map:
	movem.l	d0/a0,-(sp)
	lea.l	Map_data_buffer,a0
	moveq.l	#0,d0
	move.b	4(a0),d0			; Width & height
	move.w	d0,Width_of_map
	move.b	5(a0),d0
	move.w	d0,Height_of_map
	lea.l	Start_position,a0
	move.w	(a0)+,Map_Xcoord
	move.w	(a0)+,Map_Ycoord
	move.w	(a0)+,View_direction
	move.w	#1,Party_frame
	move.b	#C2_animspeed,Anim_speed	; Animation parameters (2D city)
	move.b	#C2_animspeed,Anim_count
	move.w	#C2_animbias,Anim_bias
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Display status block ]
; All registers are restored
; NOTE :
;   - From DISPLAY.S (without the status icons and bars).
;*****************************************************************************
Display_status_block:
	movem.l	d0-d2/d4-d7/a0,-(sp)
	moveq.l	#0,d0			; Display left edge
	moveq.l	#0,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#1,d6
	moveq.l	#36,d7
	lea.l	Status_L,a0
	jsr	Put_unmasked_block
	lea.l	Status_M,a0		; Display status bars
	addi.w	#48,d0
	moveq.l	#6-1,d2
.Loop1:	jsr	Put_unmasked_block
	addi.w	#48,d0
	dbra	d2,.Loop1
	lea.l	Status_R,a0		; Display right edge
	subi.w	#32,d0
	jsr	Put_unmasked_block
	moveq.l	#1,d7			; Display portraits
.Loop2:	jsr	Display_portrait
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop2
	movem.l	(sp)+,d0-d2/d4-d7/a0
	rts

;*****************************************************************************
; [ Display member portrait ]
;   IN : d7 - Member number [1...6] (.w)
; All registers are restored
; NOTE :
;   - From DISPLAY.S.
;*****************************************************************************
Display_portrait:
	movem.l	d0-d7/a0,-(sp)
	move.w	d7,d2
	subq.w	#1,d7			; Calculate X-coordinate
	mulu.w	#48,d7
	addi.w	#16,d7
	move.w	d7,d0			; Display top
	moveq.l	#0,d1
	moveq.l	#2,d6
	moveq.l	#1,d7
	lea.l	Status_TB,a0
	jsr	Put_unmasked_block
	moveq.l	#35,d1			; Display bottom
	jsr	Put_unmasked_block
	lea.l	Portraits,a0		; Display portrait
	move.w	d2,d3
	subq.w	#1,d3
	mulu.w	#34*2*8,d3
	add.l	d3,a0
	moveq.l	#1,d1
	moveq.l	#34,d7
	jsr	Put_unmasked_block
	lea.l	Names,a0			; Display name (first 5 letters)
	move.w	d2,d3
	subq.w	#1,d3
	lsl.w	#4,d3
	add.w	d3,a0
	lea.l	Temp_name,a1
	moveq.l	#5-1,d7
.Loop:	move.b	(a0)+,(a1)+
	dbeq	d7,.Loop
	clr.b	(a1)
	move.w	#Lighter_blue,Ink_colour	; Default ink
	cmp.w	#1,d2			; Active member ?
	bne.s	.Print
	move.w	#Yellow,Ink_colour
.Print:	move.w	#Default_shadow,Shadow_colour	; (Status_PA in DISPLAY.S)
	addq.w	#2,d0
	moveq.l	#31,d1
	moveq.l	#30,d2
	lea.l	Temp_name,a0
	jsr	Print_centered_string
	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Show the 2D map layout ]
; All registers are restored
; NOTE :
;   - From [ Show_layout ] and [ Init_map_layout ] (DISPLAY.S).
;*****************************************************************************
Show_map_layout:
	movem.l	d0-d7/a0,-(sp)
	moveq.l	#0,d0			; Show layout
	moveq.l	#Middle_Y+1,d1
	moveq.l	#24,d4
	moveq.l	#3,d5
	moveq.l	#20,d6
	move.w	#199-Middle_Y,d7
	lea.l	Layout,a0
	jsr	Put_unmasked_block
	moveq.l	#Window_colour,d4		; Clear spell & item area
	move.w	#208,d0
	move.w	#49,d1
	move.w	#303,d2
	move.w	#128,d3
	jsr	Draw_box
	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Print map headline ]
; All registers are restored
; NOTE :
;   - From MAP/MAP.S.
;*****************************************************************************
Print_headline:
	movem.l	d0-d2/a0,-(sp)
	move.w	#31,Ink_colour		; Set ink
	move.w	#Default_shadow,Shadow_colour
	moveq.l	#13,d0			; Print
	moveq.l	#40,d1
	move.w	#180,d2
	lea.l	Map_name,a0
	jsr	Print_centered_string
	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Print a centered string ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Width of area (.w)
;        a0 - Pointer to string (.l)
; All registers are restored
; NOTE :
;   - From HULL/WORDS.S.
;*****************************************************************************
Print_centered_string:
	movem.l	d0/d2/d6/a0,-(sp)
	move.l	a0,-(sp)			; Get string length
	moveq.l	#0,d6
.Len:	tst.b	(a0)+
	beq.s	.Done
	addq.w	#1,d6
	bra.s	.Len
.Done:	move.l	(sp)+,a0
	mulu.w	#Char_width+1,d6		; Calculate new X-coordinate
	sub.w	d6,d2
	bmi.s	.Skip
	asr.w	#1,d2
	add.w	d2,d0
.Skip:	jsr	Put_text_line		; Print
	movem.l	(sp)+,d0/d2/d6/a0
	rts

;*****************************************************************************
; [ Display control icons ]
; All registers are restored
; NOTE :
;   - From HULL/CONTROLS.S, with the control icon list of the 2D map
;     (M2_CIL in MAP/2D_MAP.S).
;*****************************************************************************
Display_control_icons:
	movem.l	d0-d3/a2/a3,-(sp)
	lea.l	M2_CIL,a2
	lea.l	Icon_pos,a3
	moveq.l	#9-1,d2
.Loop:	move.w	(a3)+,d0			; Get coordinates
	move.w	(a3)+,d1
	move.w	(a2)+,d3			; Display button
	jsr	Display_up_button
	dbra	d2,.Loop
	movem.l	(sp)+,d0-d3/a2/a3
	rts

;*****************************************************************************
; [ Display "up" / "down" control icon ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d3 - Control icon number {0...} (.w)
; All registers are restored
; NOTE :
;   - From HULL/CONTROLS.S.
;*****************************************************************************
Display_up_button:
	move.l	a1,-(sp)
	lea.l	Button_up,a1
	bra.s	Display_button
Display_down_button:
	move.l	a1,-(sp)
	lea.l	Button_down,a1
Display_button:
	movem.l	d1/d3-d7/a0,-(sp)
	moveq.l	#24,d4			; Display button
	moveq.l	#3,d5
	moveq.l	#2,d6
	moveq.l	#17,d7
	move.l	a1,a0
	jsr	Put_unmasked_block
	lea.l	Control_icons,a0		; Calculate icon address
	andi.w	#$007f,d3
	bne.s	.Notzero
	move.w	#Empty_cicon,d3
.Notzero:	subq.w	#1,d3
	mulu.w	#13*2*8,d3
	add.l	d3,a0
	addq.w	#2,d1			; Display icon
	moveq.l	#13,d7
	jsr	Put_masked_block
	movem.l	(sp)+,d1/d3-d7/a0
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Display the party position in the spell & item area ]
; All registers are restored
;*****************************************************************************
Display_position:
	movem.l	d0-d4/a0/a1,-(sp)
	move.w	Map_Xcoord,d0		; Changed ?
	swap	d0
	move.w	Map_Ycoord,d0
	cmp.l	Last_position,d0
	beq.s	.Same
	move.l	d0,Last_position
	move.w	#2,Position_redraw		; Both screens
.Same:	tst.w	Position_redraw
	beq	.Exit
	subq.w	#1,Position_redraw
	lea.l	Position_text+2,a1		; Make text
	move.w	Map_Xcoord,d0
	jsr	.Number
	addq.l	#3,a1
	move.w	Map_Ycoord,d0
	jsr	.Number
	moveq.l	#Window_colour,d4		; Clear area
	move.w	#208,d0
	move.w	#118,d1
	move.w	#303,d2
	move.w	#126,d3
	jsr	Draw_box
	move.w	#Default_ink,Ink_colour	; Print
	move.w	#Default_shadow,Shadow_colour
	move.w	#212,d0
	move.w	#120,d1
	lea.l	Position_text,a0
	jsr	Put_text_line
.Exit:	movem.l	(sp)+,d0-d4/a0/a1
	rts

.Number:	andi.l	#$ffff,d0			; Two digits
	divu.w	#10,d0
	addi.b	#'0',d0
	move.b	d0,(a1)+
	swap	d0
	addi.b	#'0',d0
	move.b	d0,(a1)+
	rts

;*****************************************************************************
; [ Handle the input ]
; All registers are restored
;*****************************************************************************
Handle_input:
	movem.l	d0-d7/a0,-(sp)
.Keys:	jsr	Read_key			; Key events
	tst.w	d0
	beq.s	.Mouse
	cmp.w	#$01,d0			; ESC ?
	beq.s	.Quit
	cmp.w	#$61,d0			; UNDO ?
	bne.s	.Keys
.Quit:	st	Quit_flag
	bra	.Exit
; ---------- Movement -----------------------------
.Mouse:	moveq.l	#-1,d7			; No direction
	lea.l	Direction_keys,a0		; Keys held down ?
.Loop:	move.w	(a0)+,d0
	bmi.s	.No_key
	move.w	(a0)+,d1
	jsr	Key_pressed
	beq.s	.Loop
	move.w	d1,d7
	bra.s	.Move
.No_key:	btst	#Left_pressed,Mouse_buttons	; Mouse button held down ?
	beq.s	.Exit
	jsr	Mouse_direction_2D
	tst.w	d7
	bmi.s	.Exit
.Move:	jsr	Make_2D_move
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Get the movement direction from the mouse position ]
;  OUT : d7 - Direction {0...7} / -1 = none (.w)
; Changed registers : d7
; NOTE :
;   - Like the 2D map, the map window is divided into 3 x 3 areas around
;     the party. Clicking a control icon also moves.
;*****************************************************************************
Mouse_direction_2D:
	movem.l	d0-d3/a0,-(sp)
	moveq.l	#-1,d7
	move.w	Mouse_X,d0
	move.w	Mouse_Y,d1
	cmp.w	#208,d0			; Control icons ?
	bmi.s	.Map
	cmp.w	#143,d1
	bmi.s	.Exit
	subi.w	#208,d0
	divu.w	#32,d0
	subi.w	#143,d1
	divu.w	#17,d1
	cmp.w	#3,d0
	bpl.s	.Exit
	cmp.w	#3,d1
	bpl.s	.Exit
	bra.s	.Area
.Map:	subi.w	#Map2D_X,d0		; Inside the map window ?
	bmi.s	.Exit
	cmp.w	#Mapbuf_width*16,d0
	bpl.s	.Exit
	subi.w	#Map2D_Y,d1
	bmi.s	.Exit
	cmp.w	#Mapbuf_height*16,d1
	bpl.s	.Exit
	lsr.w	#4,d0			; Relative to the party
	lsr.w	#4,d1
	sub.w	Mapbuf_X,d0
	sub.w	Mapbuf_Y,d1
	moveq.l	#1,d2			; -> 0, 1, 2
	tst.w	d0
	beq.s	.X
	bpl.s	.X1
	moveq.l	#0,d2
	bra.s	.X
.X1:	moveq.l	#2,d2
.X:	moveq.l	#1,d3
	tst.w	d1
	beq.s	.Y
	bpl.s	.Y1
	moveq.l	#0,d3
	bra.s	.Y
.Y1:	moveq.l	#2,d3
.Y:	move.w	d2,d0
	move.w	d3,d1
.Area:	mulu.w	#3,d1			; Get direction
	add.w	d1,d0
	move.b	.Directions(pc,d0.w),d7
	ext.w	d7
.Exit:	movem.l	(sp)+,d0-d3/a0
	rts

.Directions:
	dc.b	7,0,1,6,-1,2,5,4,3
	even

;*****************************************************************************
; [ Make a 2D map move ]
;   IN : d7 - Movement direction {0...7} (.w)
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S (without events and travel modes).
;*****************************************************************************
Make_2D_move:
	movem.l	d2/d3/d6/d7,-(sp)
	move.w	VBL_counter,d2		; Is it time ?
	sub.w	Last_move,d2
	cmp.w	#M2_movement_speed,d2
	bmi.s	.Exit
	sf	Moved
	move.w	Map_Xcoord,d2		; Get party coordinates
	move.w	Map_Ycoord,d3
	move.w	d7,d6			; Store
	jsr	Try_2D_move		; Try original direction
	tst.b	Moved			; Possible ?
	bne.s	.Exit
	btst	#0,d6			; Orthogonal ?
	beq.s	.Exit
	move.b	.2nd_try(pc,d6.w),d7	; No
	jsr	Try_2D_move		; Try vertical
	tst.b	Moved			; Possible ?
	bne.s	.Exit
	move.b	.3rd_try(pc,d6.w),d7	; No
	jsr	Try_2D_move		; Try diagonal
.Exit:	movem.l	(sp)+,d2/d3/d6/d7
	rts

.2nd_try:	dc.b 0,0,2,4,4,4,6,0
.3rd_try:	dc.b 0,2,2,2,4,6,6,6
	even

;*****************************************************************************
; [ Try a 2D map move ]
;   IN : d2 - X-coordinate of party (.w)
;        d3 - Y-coordinate of party (.w)
;        d7 - Movement direction {0...7} (.w)
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S.
;*****************************************************************************
Try_2D_move:
	movem.l	d0-d3/d7,-(sp)
	move.b	.View(pc,d7.w),d0		; Set view direction
	ext.w	d0
	move.w	d0,View_direction
	move.w	d2,d0			; Get party coordinates
	move.w	d3,d1
	add.w	d7,d7			; Get coordinate offsets
	move.b	.Offsets(pc,d7.w),d2
	move.b	.Offsets+1(pc,d7.w),d3
	ext.w	d2
	ext.w	d3
	add.w	d2,d0			; Move
	add.w	d3,d1
	jsr	Movement_check_2D
	bne.s	.Exit			; Possible ?
	move.w	d0,Map_Xcoord		; Yes -> store new coordinates
	move.w	d1,Map_Ycoord
	st	Moved			; Yay!
	jsr	Animate_party
	move.w	VBL_counter,Last_move	; Reset clock
.Exit:	movem.l	(sp)+,d0-d3/d7
	rts

.View:	dc.b 0,0,1,2,2,2,3,0
.Offsets:	dc.b 0,-1,1,-1,1,0,1,1,0,1,-1,1,-1,0,-1,-1
	even

;*****************************************************************************
; [ Check if movement is possible (2D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : eq - Movement possible
;        ne - Movement impossible
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S (on foot, 2D city map, no NPCs).
;*****************************************************************************
Movement_check_2D:
	movem.l	d0-d2,-(sp)
	moveq.l	#-1,d2			; Zero flag off
	cmp.w	#1,d0			; X too low ?
	blt.s	.Exit
	cmp.w	Width_of_map,d0		; X too high ?
	bgt.s	.Exit
	cmp.w	#1,d1			; Y too low ?
	blt.s	.Exit
	cmp.w	Height_of_map,d1		; Y too high ?
	bgt.s	.Exit
	jsr	Get_location_status		; Get location status
	btst.l	#Way_blocked_bit,d0		; Way blocked ?
	bne.s	.Exit
	btst.l	#Blocked_foot_bit,d0	; Way possible on foot ?
	seq	d2
.Exit:	tst.b	d2			; Get zero flag
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Get location status ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : d0 - Location status (.l)
; Changed registers : d0
; NOTE :
;   - From MAP/MAP.S (2D city map, no NPCs).
;*****************************************************************************
Get_location_status:
	movem.l	d1/a0/a1,-(sp)
	lea.l	Map_data_buffer+Map_data,a1	; Get map pointer
	subq.w	#1,d1
	mulu.w	Width_of_map,d1
	subq.w	#1,d0
	add.w	d0,d1
	lsl.l	#2,d1
	add.l	d1,a1
	lea.l	Icon_data_buffer+2,a0	; Get icon data
	moveq.l	#0,d0			; Get underlay icon number
	move.b	(a1),d0
	beq.s	.No_under
	lsl.w	#3,d0			; Get underlay icon status
	move.l	-8(a0,d0.w),d0
.No_under:	moveq.l	#0,d1			; Get overlay icon number
	move.w	2(a1),d1
	beq.s	.Exit			; Is there an overlay ?
	lsl.w	#3,d1			; Get overlay icon status
	move.l	-8(a0,d1.l),d1
	btst	#Underlay_priority_bit,d1	; Underlay priority ?
	bne.s	.Exit
	move.l	d1,d0			; No -> Use overlay status
.Exit:	movem.l	(sp)+,d1/a0/a1
	rts

;*****************************************************************************
; [ Animate 2D party graphics ]
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S.
;*****************************************************************************
Animate_party:
	move.l	d0,-(sp)
	move.w	Party_frame,d0		; Get current frame
	tst.b	Party_animate_state		; Back or forth ?
	bne.s	.Back
	addq.w	#1,d0			; Forth
	cmp.w	#Party_frames,d0		; Last ?
	bmi.s	.Store
	subq.w	#2,d0			; Yes -> Reverse
	st	Party_animate_state
	bra.s	.Store
.Back:	subq.w	#1,d0			; Back
	bpl.s	.Store			; First ?
	addq.w	#2,d0			; Yes -> Reverse
	sf	Party_animate_state
.Store:	move.w	d0,Party_frame		; Store new frame
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Recalculate map buffer coordinates ]
; All registers are restored
; NOTE :
;   - From MAP/2D_CITY.S.
;*****************************************************************************
Recalc_mapbuf_coords:
	movem.l	d0/d1,-(sp)
	move.w	#Mapbuf_centreX,Mapbuf_X	; Reset map buffer coordinates
	move.w	#Mapbuf_centreY,Mapbuf_Y
	move.w	Map_Xcoord,d0		; Load party coordinates
	move.w	Map_Ycoord,d1
	cmpi.w	#Mapbuf_centreX+1,d0	; Left boundary check
	bpl.s	.Skip1
	subi.w	#Mapbuf_centreX+1,d0
	add.w	d0,Mapbuf_X
	bra.s	.Go_on1
.Skip1:	sub.w	Width_of_map,d0		; Right boundary check
	cmpi.w	#-Mapbuf_centreX+1,d0
	bmi.s	.Go_on1
	addi.w	#Mapbuf_centreX,d0
	add.w	d0,Mapbuf_X
.Go_on1:	cmpi.w	#Mapbuf_centreY+1,d1	; Top boundary check
	bpl.s	.Skip2
	subi.w	#Mapbuf_centreY+1,d1
	add.w	d1,Mapbuf_Y
	bra.s	.Go_on2
.Skip2:	sub.w	Height_of_map,d1		; Bottom boundary check
	cmpi.w	#-Mapbuf_centreY+1,d1
	bmi.s	.Go_on2
	addi.w	#Mapbuf_centreY,d1
	add.w	d1,Mapbuf_Y
.Go_on2:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Copy the visible part of the map to the buffers ]
; All registers are restored
; NOTE :
;   - From [ C2_DisUpd ] (MAP/2D_CITY.S).
;*****************************************************************************
Fill_map_buffers:
	movem.l	d0/d1/d6/d7/a1-a3,-(sp)
	jsr	Recalc_mapbuf_coords	; Set map buffer coordinates
	lea.l	Map_data_buffer+Map_data,a1	; Calculate map address
	move.w	Map_Ycoord,d0
	subq.w	#1,d0
	sub.w	Mapbuf_Y,d0
	move.w	Width_of_map,d1
	mulu.w	d1,d0
	add.w	Map_Xcoord,d0
	subq.w	#1,d0
	sub.w	Mapbuf_X,d0
	lsl.l	#2,d0
	adda.l	d0,a1
	subi.w	#Mapbuf_width,d1		; Calculate offset
	lsl.w	#2,d1
	lea.l	Underlay_buffer,a2		; Copy maps to buffer
	lea.l	Overlay_buffer,a3
	moveq.l	#Mapbuf_height-1,d7
.Loop1:	moveq.l	#Mapbuf_width-1,d6
.Loop2:	move.b	(a1)+,(a2)+		; Copy underlay
	addq.l	#1,a1			; Skip event
	move.b	(a1)+,(a3)+		; Copy overlay
	move.b	(a1)+,(a3)+
	dbra	d6,.Loop2
	adda.w	d1,a1
	dbra	d7,.Loop1
	movem.l	(sp)+,d0/d1/d6/d7/a1-a3
	rts

;*****************************************************************************
; [ Display 2D map ]
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S (without darkness, transports and persons).
;   - The Amiga version redraws the whole map window every frame with the
;     blitter. That costs about 5 frames on the ST, so a tile cache is used :
;     for each screen buffer and map buffer position the graphics which were
;     drawn last time (underlay, ground overlay, sky overlay, party) are
;     remembered, and only positions which changed are redrawn.
;*****************************************************************************
Display_2D_map:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Fill_map_buffers
	lea.l	Map2D_L2,a0
	jsr	Push_CA
	jsr	Get_tile_cache		; a4 = tile cache of work screen
	move.w	Mapbuf_Y,d0		; Map buffer position of party
	mulu.w	#Mapbuf_width,d0
	add.w	Mapbuf_X,d0
	move.w	d0,Party_cell
	lea.l	Underlay_buffer,a1
	lea.l	Overlay_buffer,a2
	lea.l	Redraw_flags,a3
	lea.l	Icon_data_buffer+2,a5
	jsr	Get_hashable_number
	moveq.l	#0,d4			; Map buffer position
	move.w	#Map2D_Y,d1
	moveq.l	#Mapbuf_height-1,d7
.Loop1:	move.w	#Map2D_X,d0
	moveq.l	#Mapbuf_width-1,d6
; ---------- Get the icons of the position --------
; Tile cache entry : underlay & overlay number (.l), party (.w), flags (.w :
; bit 0 = animated, bit 1 = sky overlay), underlay address (.l), overlay
; address (.l)
.Loop2:	moveq.l	#0,d2			; Key = underlay << 16 | overlay
	move.b	(a1)+,d2
	swap	d2
	move.w	(a2)+,d2
	moveq.l	#0,d3			; Party here ?
	move.w	Party_cell,d3
	cmp.w	d3,d4
	beq.s	.Party
	subi.w	#Mapbuf_width,d3		; (the party is 32 pixels high)
	cmp.w	d3,d4
	beq.s	.Party
	moveq.l	#0,d3
	bra.s	.No_party
.Party:	moveq.l	#1,d3
.No_party:	tst.w	d3			; Party : always redraw
	bne.s	.Redraw
	cmp.l	(a4),d2			; Same icons ?
	bne.s	.Redraw
	tst.w	4(a4)			; Party was here ?
	bne.s	.Redraw
	btst	#0,7(a4)			; Animated ?
	beq	.Skip
	jsr	Get_cell_graphics		; Frames changed ?
	cmp.l	8(a4),a0
	bne.s	.Redraw2
	cmp.l	12(a4),a6
	beq	.Skip
	bra.s	.Redraw2
.Redraw:	jsr	Get_cell_graphics
.Redraw2:	move.l	d2,(a4)			; Remember
	move.w	d3,4(a4)
	move.w	Cell_flags,6(a4)
	move.l	a0,8(a4)
	move.l	a6,12(a4)
	st	(a3)
; ---------- Draw under- & ground overlay ---------
	move.l	a0,d2			; Underlay
	bne.s	.Under
	jsr	Clear_icon
	bra.s	.Over
.Under:	jsr	Put_unmasked_icon
.Over:	move.l	a6,d2			; Ground overlay ?
	beq.s	.Next2
	btst	#1,7(a4)
	bne.s	.Next2
	move.l	a6,a0
	jsr	Put_masked_icon
	bra.s	.Next2
.Skip:	sf	(a3)			; No redraw
.Next2:	lea.l	16(a4),a4			; Next X
	addq.l	#1,a3
	addq.w	#1,d4
	addi.w	#16,d0
	addq.w	#1,d5
	dbra	d6,.Loop2
	addi.w	#16,d1			; Next Y
	subi.w	#Mapbuf_width,d5
	add.w	Width_of_map,d5
	dbra	d7,.Loop1
; ---------- Display party & sky overlays ---------
	jsr	Display_2D_party
	jsr	Display_2D_sky
	jsr	Pop_CA
	subq.b	#1,Anim_count		; Time for an update ?
	bne.s	.Exit
	jsr	Update_animation		; Update animation
	move.b	Anim_speed,Anim_count	; Reset counter
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Get the graphics of a map buffer position ]
;   IN : d2 - Underlay number << 16 | overlay number (.l)
;        d5 - Hashable number (.w)
;        a5 - Pointer to icon info (.l)
;  OUT : a0 - Underlay frame address / 0 (.l)
;        a6 - Overlay frame address / 0 (.l)
;        [ Cell_flags ] - bit 0 = animated, bit 1 = sky overlay (.w)
; Changed registers : a0,a6
;*****************************************************************************
Get_cell_graphics:
	movem.l	d2/d3,-(sp)
	clr.w	Cell_flags
	sub.l	a6,a6
	tst.w	d2			; Overlay ?
	beq.s	.No_over
	move.w	d2,d3			; Get icon info
	lsl.w	#3,d3
	btst	#Overlay_in_sky_bit,-8+3(a5,d3.w)	; (bit of the lowest byte)
	beq.s	.Ground
	bset	#1,Cell_flags+1
.Ground:	cmpi.b	#1,-8+Icon_nr_frames(a5,d3.w)	; Animated ?
	bls.s	.Still
	bset	#0,Cell_flags+1
.Still:	lea.l	Icon_graphics,a0
	jsr	Get_icon_frame_address
	move.l	a0,a6
.No_over:	sub.l	a0,a0
	swap	d2			; Underlay ?
	cmp.w	#1,d2
	bls.s	.Exit
	move.w	d2,d3			; Animated ?
	lsl.w	#3,d3
	cmpi.b	#1,-8+Icon_nr_frames(a5,d3.w)
	bls.s	.Still2
	bset	#0,Cell_flags+1
.Still2:	lea.l	Icon_graphics,a0
	jsr	Get_icon_frame_address
.Exit:	movem.l	(sp)+,d2/d3
	rts

;*****************************************************************************
; [ Get the tile cache of the work screen ]
;  OUT : a4 - Pointer to tile cache (.l)
; Changed registers : a4
;*****************************************************************************
Get_tile_cache:
	move.l	d0,-(sp)
	move.l	Work_screen,d0
	tst.l	Tile_cache_owner		; First call ?
	bne.s	.Set
	move.l	d0,Tile_cache_owner
.Set:	lea.l	Tile_cache1,a4
	cmp.l	Tile_cache_owner,d0
	beq.s	.Exit
	lea.l	Tile_cache2,a4
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Invalidate the tile caches ]
; All registers are restored
;*****************************************************************************
Invalidate_tile_caches:
	movem.l	d7/a0,-(sp)
	lea.l	Tile_cache1,a0
	move.w	#2*Mapbuf_size*4-1,d7
.Loop:	move.l	#-1,(a0)+
	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Clear a 16x16 icon on the work screen (colour 0) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
Clear_icon:
	movem.l	d2/d3/d7/a1,-(sp)
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	moveq.l	#16-1,d7
.Loop:	clr.l	(a1)+
	clr.l	(a1)
	lea.l	ST_bytes_per_line-4(a1),a1
	dbra	d7,.Loop
	movem.l	(sp)+,d2/d3/d7/a1
	rts

;*****************************************************************************
; [ Display 2D sky overlays ]
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S. Only the positions which were redrawn this frame.
;*****************************************************************************
Display_2D_sky:
	movem.l	d0-d7/a0-a4,-(sp)
	jsr	Get_tile_cache
	lea.l	Redraw_flags,a3
	move.w	#Map2D_Y,d1
	moveq.l	#Mapbuf_height-1,d7
.Loop1:	move.w	#Map2D_X,d0
	moveq.l	#Mapbuf_width-1,d6
.Loop2:	tst.b	(a3)+			; Redrawn ?
	beq.s	.Next
	btst	#1,7(a4)			; Sky overlay ?
	beq.s	.Next
	move.l	12(a4),a0
	jsr	Put_masked_icon
.Next:	lea.l	16(a4),a4			; Next X
	addi.w	#16,d0
	dbra	d6,.Loop2
	addi.w	#16,d1			; Next Y
	dbra	d7,.Loop1
	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Get hashable number ]
;  OUT : d5 - Hashable number (.w)
; Changed registers : d5
; NOTE :
;   - From MAP/2D_MAP.S.
;*****************************************************************************
Get_hashable_number:
	move.w	Map_Ycoord,d5		; Calculate hashable number
	sub.w	Mapbuf_Y,d5
	subq.w	#1,d5
	mulu.w	Width_of_map,d5
	add.w	Map_Xcoord,d5
	sub.w	Mapbuf_X,d5
	subq.w	#1,d5
	rts

;*****************************************************************************
; [ Display party ]
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S (on foot, standing).
;*****************************************************************************
Display_2D_party:
	movem.l	d0/d1/d5-d7/a0,-(sp)
	lea.l	Party_graphics,a0		; Seek graphics
	move.w	View_direction,d0		; Choose direction
	mulu.w	#Party_frames,d0
	add.w	Party_frame,d0		; Animate
	mulu.w	#32*8,d0
	add.l	d0,a0
	move.w	Mapbuf_X,d0		; Get coordinates
	lsl.w	#4,d0
	addi.w	#Map2D_X,d0
	move.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y-16,d1
	moveq.l	#5,d5			; Display party
	moveq.l	#1,d6
	moveq.l	#32,d7
	jsr	Put_masked_block
	movem.l	(sp)+,d0/d1/d5-d7/a0
	rts

;*****************************************************************************
; [ Display 2D underlay ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number (.b)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon graphics (.l)
;        a5 - Pointer to icon info (.l)
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S.
;*****************************************************************************
Display_2D_underlay:
	movem.l	d5/a0,-(sp)
	cmp.b	#1,d2			; Underlay ?
	bhi.s	.Yes
	movem.l	d2-d4,-(sp)		; No
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#16-1,d2
	addi.w	#16-1,d3
	moveq.l	#0,d4
	jsr	Draw_box
	movem.l	(sp)+,d2-d4
	bra.s	.Exit
.Yes:	andi.w	#$00ff,d2			; Yes
	jsr	Get_icon_frame_address
	moveq.l	#5,d5
	jsr	Put_unmasked_icon
.Exit:	movem.l	(sp)+,d5/a0
	rts

;*****************************************************************************
; [ Display 2D overlay ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number (.w)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon data (.l)
; All registers are restored
; NOTE :
;   - From MAP/2D_MAP.S.
;*****************************************************************************
Display_2D_overlay:
	movem.l	d5/a0,-(sp)
	jsr	Get_icon_frame_address
	moveq.l	#5,d5
	jsr	Put_masked_icon
	movem.l	(sp)+,d5/a0
	rts

;*****************************************************************************
; [ Get icon frame address ]
;   IN : d2 - Icon number (.w)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon graphics (.l)
;        a5 - Pointer to icon info (.l)
;  OUT : a0 - Icon frame address (.l)
; Changed registers : a0
; NOTE :
;   - From MAP/2D_MAP.S. An ST icon has 16 x 8 bytes.
;*****************************************************************************
Get_icon_frame_address:
	movem.l	d2-d5/a1/a2,-(sp)
	lsl.w	#3,d2			; Get pointer to icon info
	lea.l	-8(a5,d2.w),a1
	move.l	Icon_bits(a1),d2		; Get icon status
	moveq.l	#0,d3			; Get number of first frame
	move.w	Icon_1st_frame(a1),d3
	moveq.l	#0,d4			; Get number of frames
	move.b	Icon_nr_frames(a1),d4
	cmp.w	#1,d4			; Any animation ?
	bls.s	.No_anim
	lea.l	Circle_anim-4,a2		; Circle or wave ?
	btst	#Circle_wave_bit,d2
	beq.s	.Circle
	lea.l	Wave_anim-4,a2		; Wave
.Circle:	lsl.w	#2,d4			; Add number of frames
	adda.w	d4,a2
	btst	#Random_anim_bit,d2		; Random animation ?
	beq.s	.No_random
	moveq.l	#0,d4			; Random hash
	move.b	1(a2),d4
	add.w	d4,d5
	andi.w	#$000f,d5
	move.w	2(a2),d4			; Test
	btst	d5,d4
	beq.s	.No_anim
.No_random:	moveq.l	#0,d4			; Get current frame
	move.b	(a2),d4
	add.w	d4,d3
.No_anim:	subq.w	#1,d3			; Calculate frame address
	lsl.l	#7,d3			; (16 x 8 bytes)
	adda.l	d3,a0
	movem.l	(sp)+,d2-d5/a1/a2
	rts

;*****************************************************************************
; [ Update animation ]
; All registers are restored
; NOTE :
;   - From MAP/MAP.S.
;*****************************************************************************
Update_animation:
	movem.l	d0/d7/a0/a1,-(sp)
; --------- Update circle animation ---------------
	lea.l	Circle_anim+4,a0
	moveq.l	#2,d7
.Loop1:	move.b	(a0),d0			; Increase frame
	addq.b	#1,d0
	cmp.b	d0,d7			; Last frame ?
	bne.s	.Skip1
	jsr	.Recalc_random
	moveq.l	#0,d0			; Reset frame
.Skip1:	move.b	d0,(a0)			; Store frame
	addq.l	#4,a0			; Next animation length
	addq.w	#1,d7
	cmpi.w	#8+1,d7
	bmi.s	.Loop1
; --------- Update wave animation -----------------
	lea.l	Wave_anim+8,a0
	lea.l	32-8(a0),a1
	moveq.l	#3,d7
.Loop2:	move.b	(a0),d0
	tst.b	(a1)+			; Up or down ?
	bne.s	.Down
	addq.b	#1,d0			; Increase
	cmp.b	d0,d7			; Last frame ?
	bne.s	.Skip2
	subq.b	#2,d0			; Reverse	direction
	not.b	-1(a1)
	bra.s	.Skip2
.Down:	subq.b	#1,d0			; Decrease
	bne.s	.Skip2
	not.b	-1(a1)			; Reverse	direction
	jsr	.Recalc_random
.Skip2:	move.b	d0,(a0)			; Store frame
	addq.l	#4,a0			; Next animation length
	addq.w	#1,d7
	cmpi.w	#8+1,d7
	bmi.s	.Loop2
	movem.l	(sp)+,d0/d7/a0/a1
	rts

; [ Re-calculate random animation factors ]
;   IN : a0 - Pointer to animation table (.l)
; All registers are restored
.Recalc_random:
	movem.l	d0/d1/d7,-(sp)
	moveq.l	#0,d1			; Re-calculate random
	move.w	Anim_bias,d7
	subq.w	#1,d7
.Loop:	jsr	Random
	lsr.w	#1,d0
	andi.w	#$000f,d0
	bset	d0,d1
	dbra	d7,.Loop
	move.w	d1,2(a0)			; Store
	jsr	Random			; Re-calculate offset
	lsr.w	#1,d0
	move.b	d0,1(a0)
	movem.l	(sp)+,d0/d1/d7
	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

; Raster list of the 2D map (Map_RL in MODULES.S)
Map_RL:	R_palette 0,UI_palette
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Map_palette
	R_end
	even

; Colour gradient behind the portraits (DISPLAY.S)
Portrait_range:
	dc.w $010,$010,$010,$010
	dc.w $011,$011,$012,$012
	dc.w $013,$013,$014,$014
	dc.w $015,$015,$016,$016
	dc.w $017,$017,$018,$018
	dc.w $019,$019,$01a,$01a
	dc.w $01b,$01b,$01c,$01c
	dc.w $01d,$01d,$01e,$01e
	dc.w $01f,$01f,0

; Clip area of the 2D map window
Map2D_L2:	dc.w Map2D_X,Map2D_X+Mapbuf_width*16-1
	dc.w Map2D_Y,Map2D_Y+Mapbuf_height*16-1

; Control icon list of the 2D map (M2_CIL in MAP/2D_MAP.S)
M2_CIL:	dc.w Upleft_2D_cicon,Up_2D_cicon,Upright_2D_cicon
	dc.w Left_2D_cicon,Hourglass_cicon,Right_2D_cicon
	dc.w Downleft_2D_cicon,Down_2D_cicon,Downright_2D_cicon

; Positions of the control icons (HULL/CONTROLS.S)
Icon_pos:	dc.w 208,143,240,143,272,143
	dc.w 208,160,240,160,272,160
	dc.w 208,177,240,177,272,177

; Keys : scan code, direction
Direction_keys:
	dc.w	$48,0,$50,4,$4b,6,$4d,2	; Cursor keys
	dc.w	$68,0,$6e,4,$6a,6,$6c,2	; Numeric keypad 8, 2, 4, 6
	dc.w	$67,7,$69,1,$6d,5,$6f,3	; Numeric keypad 7, 9, 1, 3
	dc.w	-1

; Files : buffer, maximum length, name
File_list:
	dc.l	UI_palette,64
	dc.b	"DATA\UIPAL.BIN",0
	even
	dc.l	Map_palette,64
	dc.b	"DATA\MAPPAL.BIN",0
	even
	dc.l	Layout,320*163/2
	dc.b	"DATA\LAYOUT.BIN",0
	even
	dc.l	Status_L,UI_graphics_size
	dc.b	"DATA\UIGFX.BIN",0
	even
	dc.l	Control_icons,78*13*2*8
	dc.b	"DATA\BUTTONS.BIN",0
	even
	dc.l	Mouse_pointer,4+16*8
	dc.b	"DATA\MPTR.BIN",0
	even
	dc.l	Portraits,6*34*2*8
	dc.b	"DATA\PORTR.BIN",0
	even
	dc.l	Names,6*16
	dc.b	"DATA\NAMES.BIN",0
	even
	dc.l	Font_data,1024
	dc.b	"DATA\FONT.BIN",0
	even
	dc.l	Icon_graphics,Max_icons*16*8
	dc.b	"DATA\ICONS.BIN",0
	even
	dc.l	Icon_data_buffer,2+Max_icons*8
	dc.b	"DATA\ICONDAT.BIN",0
	even
	dc.l	Map_data_buffer,Max_map_size
	dc.b	"DATA\MAP.BIN",0
	even
	dc.l	Party_graphics,17*32*8
	dc.b	"DATA\PARTY.BIN",0
	even
	dc.l	Map_name,64
	dc.b	"DATA\MAPNAME.BIN",0
	even
	dc.l	Start_position,6
	dc.b	"DATA\START.BIN",0
	even
	dc.l	0

Position_text:
	dc.b	"X:00 Y:00",0
Load_error_text:
	dc.b	"Ambermoon ST: cannot load ",0
	even

	SECTION	Fast_BSS,bss
Max_icons	EQU	2048
Max_map_size	EQU	12+320+100*100*4+16384
UI_graphics_size	EQU	3*36*8+8+34*2*8+2*17*2*8

UI_palette:	ds.b 64
Map_palette:	ds.b 64
Status_L:	ds.b 36*8			; UI graphics (UIGFX.BIN)
Status_M:	ds.b 36*8
Status_R:	ds.b 36*8
Status_TB:	ds.b 2*8
Empty_portrait:	ds.b 34*2*8
Button_up:	ds.b 17*2*8
Button_down:	ds.b 17*2*8
Mouse_pointer:	ds.b 4+16*8
Names:	ds.b 6*16
Temp_name:	ds.b 6
Map_name:	ds.b 64
	even
Start_position:	ds.w 3
Quit_flag:	ds.b 1
Moved:	ds.b 1
Party_animate_state:	ds.b 1
Anim_count:	ds.b 1
Anim_speed:	ds.b 1
	even
Anim_bias:	ds.w 1
Circle_anim:	ds.l 8			; Animation tables
Wave_anim:	ds.l 8
	ds.b	8			;  Direction flags
	even
Last_move:	ds.w 1
Last_position:	ds.l 1
Position_redraw:	ds.w 1
Map_Xcoord:	ds.w 1
Map_Ycoord:	ds.w 1
View_direction:	ds.w 1
Party_frame:	ds.w 1
Width_of_map:	ds.w 1
Height_of_map:	ds.w 1
Mapbuf_X:	ds.w 1
Mapbuf_Y:	ds.w 1
Party_cell:	ds.w 1
Cell_flags:	ds.w 1
Tile_cache_owner:	ds.l 1
Tile_cache1:	ds.l 4*Mapbuf_size
Tile_cache2:	ds.l 4*Mapbuf_size
Redraw_flags:	ds.b Mapbuf_size
	even
Underlay_buffer:	ds.b Mapbuf_size
	even
Overlay_buffer:	ds.w Mapbuf_size
Font_data:	ds.b 1024
Layout:	ds.b 320*163/2
Control_icons:	ds.b 78*13*2*8
Portraits:	ds.b 6*34*2*8
Party_graphics:	ds.b 17*32*8
Icon_data_buffer:	ds.b 2+Max_icons*8
Map_data_buffer:	ds.b Max_map_size
Icon_graphics:	ds.b Max_icons*16*8
