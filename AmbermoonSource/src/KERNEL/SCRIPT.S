; Script player (script build only, symbol Script)
;
; Plays the inputs of a compiled script (Amberfiles/Script.bin, made by
; AmbermoonSource/script/amscript.py from a text script) like a player would:
; key presses go into the key event queue, the mouse pointer and its buttons
; are set in [ Update_mouse ]. The player runs in the vertical blank, so it
; works in every module and wait loop of the game. It can wait for and branch
; on the state of the game (map, position, module, ...), which makes scripts
; independent of loading times and random events.
;
; The format of Script.bin (all values are big endian words):
;   "AMSC" (2 words), version (1), then the instructions. An instruction is an
;   opcode word followed by its operand words. Jump targets are byte offsets
;   from the start of the file.
;
;   0 END                         end of the script, the mouse is given back
;   1 WAIT frames                 wait a number of frames
;   2 KEY code                    a key press (code = the long word of the key
;     hi lo                         event: raw key << 16 | qualifiers | ASCII)
;   3 MOUSE x y                   the scripted mouse pointer goes to x, y
;   4 BUTTONS mask                the scripted mouse buttons: 1 left, 2 right
;   5 FREE                        the real mouse is used again
;   6 JUMPIF var cmp value target jump if (var cmp value) is true
;                                   cmp: 0 =, 1 <>, 2 <, 3 >=, 4 >, 5 <=
;   7 JUMP target
;   8 SET reg value               register (var $10 + reg) = value
;   9 ADD reg value               register += value
;  10 LOG tag                     add a line to Amberfiles/Script.log: tag,
;                                   frame, map, x, y, module, depth, r0, script
;                                   position (tag $ff every 256 frames)
;                                   (hexadecimal). The file is written by
;                                   [ Script_flush ] in the main loop.
;  11 MOUSETILE dx dy             the scripted mouse pointer goes to the middle
;                                   of the tile dx, dy relative to the party
;                                   on a 2D map (signed)
;  12 STEER3D x y                 3D maps: one frame of walking to the middle
;                                   of the square x, y: turn and/or forward
;                                   key presses; r5 = 1 when it is reached
;  13 GET reg var                 register = variable
;  14 JUMPIFV var cmp var2 target like JUMPIF, compared with a variable
;  15 ALIGN3D angle               3D maps: r6 = signed difference of the
;                                   angle to the given one (-512..511); if it
;                                   is at most half a turn step + 2: r5 = 1,
;                                   else r5 = 0 and if it
;                                   is at most 160: a turn key press towards it
;  16 STEERMOUSE x y              3D maps: one frame of walking to the middle
;                                   of the square x, y with the mouse button
;                                   held in the 3D view: top middle = forward,
;                                   top left/right = forward and turning (more
;                                   to the outside = stronger); r5 = 1 when it
;                                   is reached (then the button is released)
;  18 MOUSENPC slot               2D maps: the scripted mouse pointer goes to
;                                   the middle of the square of the map
;                                   character slot (0-31), at most one
;                                   square from the party (its direction)
;  19 FLOW table                 2D maps: one frame of walking with the mouse
;                                   along a direction table (byte offset in
;                                   the script: width, height (words), then
;                                   4 bits per square, high nibble first:
;                                   0 = target, 1-8 = up, up right, right,
;                                   ... up left, 15 = no way); r5 = 0
;                                   walking, 1 at the target
;                                   (button released), 2 no way from here
;  20 MOUSEAUTO x y               automap: the scripted mouse pointer goes to
;                                   the middle of the map square x, y (e.g.
;                                   a goto point)
;  21 MOUSESPELL nr               spell selection window: the scripted mouse
;                                   pointer goes to the spell with this number
;                                   (of the class); r5 = 1 if it is visible,
;                                   else 0 (scroll with cursor up / down)
;  22 WORLDDIR x y                world map: one frame of walking / flying in a
;                                   straight line (also diagonal) to the global
;                                   square x, y (16 x 16 maps of 50 x 50: x =
;                                   ((map - 1) & 15) * 50 + map x); r5 = 1 at
;                                   the target (button released)
;  23 CALL target                 subroutine call (8 levels)
;  24 RET                         return from the subroutine
;  25 MOUSEITEM item mode         the scripted mouse pointer goes to the item
;                                   (number) in the backpack of the active
;                                   member (mode bits 8-15: member 1-6
;                                   instead): mode 0 = item area of chests,
;                                   conversations, doors (6 x 2: x 27 + 22 *
;                                   column, y 152 / 178), 1 = inventory (3 x
;                                   4: x 117 + 22 * column, y 88 + 29 * row);
;                                   r5 = 1 if found (first 12 slots), else 0
;  26 MOVE3D dir                 3D maps: one frame of moving in the map
;                                   direction dir (0 north, 1 east, 2 south,
;                                   3 west) without turning: the mouse is held
;                                   in the forward / back / strafe zone that
;                                   fits the current view direction
;  27 MOUSECELL member            combat: the scripted mouse pointer goes to
;                                   the cell of the member (1-6) in the
;                                   tactic window (its current position)
;  28 FLOW3D table               3D maps: like FLOW (only up, right, down,
;                                   left), one frame of moving without turning
;                                   (see MOVE3D); r5 = 0 moving, 1 at the
;                                   target, 2 no way from here
;  29 MOUSEMONSTER               combat: the scripted mouse pointer goes to
;                                   the cell of the first monster (it moves)
;  30 CURVE3D x y                3D maps: one frame of running to the
;                                   middle of the square x, y and steering on
;                                   the way (mouse held in the top left /
;                                   right zone: forward and turning, more to
;                                   the outside = stronger); r5 = 1 when it is
;                                   reached
;  31 SEED hi lo                  sets the seed of the random generator
;                                   (Seed, long word)
;  32 SEEDLOCK hi lo              sets the seed of the random generator at
;                                   the start of every frame (0 = off): every
;                                   frame gets the same random numbers
;  17 SAVE slot                   save the game into slot 1-10 (name
;                                   "SCRIPT"), done by [ Script_flush ] in
;                                   the main loop; the script waits for it
;
; The variables: see [ Script_get_var ].

	SECTION	Program,code

; The opcodes
SC_END		EQU	0
SC_WAIT		EQU	1
SC_KEY		EQU	2
SC_MOUSE	EQU	3
SC_BUTTONS	EQU	4
SC_FREE		EQU	5
SC_JUMPIF	EQU	6
SC_JUMP		EQU	7
SC_SET		EQU	8
SC_ADD		EQU	9
SC_LOG		EQU	10
SC_MOUSETILE	EQU	11
SC_STEER3D	EQU	12
SC_GET		EQU	13
SC_JUMPIFV	EQU	14
SC_ALIGN3D	EQU	15
SC_STEERMOUSE	EQU	16
SC_SAVE		EQU	17
SC_MOUSENPC	EQU	18
SC_FLOW		EQU	19
SC_MOUSEAUTO	EQU	20
SC_MOUSESPELL	EQU	21
SC_WORLDDIR	EQU	22
SC_CALL		EQU	23
SC_RET		EQU	24
SC_MOUSEITEM	EQU	25
SC_MOVE3D	EQU	26
SC_MOUSECELL	EQU	27
SC_FLOW3D	EQU	28
SC_MOUSEMONSTER	EQU	29
SC_CURVE3D	EQU	30
SC_SEED		EQU	31
SC_SEEDLOCK	EQU	32

Script_max_size	EQU	65536
Script_steps	EQU	64		; At most this many instructions per frame
Script_log_size	EQU	16384

;*****************************************************************************
; [ Load the script ]
; NOTE :
;   - Without Amberfiles/Script.bin (or with a damaged one) nothing happens.
; All registers are restored
;*****************************************************************************
Script_init:
	movem.l	d0-d3/a0/a1/a6,-(sp)
	sf	Script_running
	move.l	#Script_filename,d1
	move.l	#1005,d2			; MODE_OLDFILE
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)
	tst.l	d0
	beq.w	.Exit
	move.l	d0,d3
	move.l	d3,d1
	move.l	#Script_buffer,d2
	move.l	d3,-(sp)
	move.l	#Script_max_size,d3
	jsr	_LVORead(a6)
	move.l	(sp)+,d3
	move.l	d0,-(sp)
	move.l	d3,d1
	jsr	_LVOClose(a6)
	move.l	(sp)+,d0
	cmp.l	#6,d0			; Header and version ?
	blt.w	.Exit
	cmpi.l	#"AMSC",Script_buffer
	bne.w	.Exit
	cmpi.w	#1,Script_buffer+4		; Version 1 ?
	bne.w	.Exit
	move.l	#6,Script_pc
	clr.w	Script_wait
	clr.w	Script_buttons
	sf	Script_mouse
	clr.w	Script_save_slot
	sf	Script_save_done
	clr.w	Script_sp
	clr.l	Script_seed_lock
	st	Script_running
.Exit:	movem.l	(sp)+,d0-d3/a0/a1/a6
	rts

;*****************************************************************************
; [ Run the script (called in the vertical blank) ]
; All registers are restored
;*****************************************************************************
Script_VBL:
	tst.l	Script_seed_lock		; Random seed locked ?
	beq.s	.No_lock
	move.l	Script_seed_lock,Seed	; Yes -> the same numbers every frame
.No_lock:	tst.b	Script_running
	beq	.Exit2
	movem.l	d0-d7/a0-a2,-(sp)
	move.l	Module_Sp,d0		; Module stack changed ?
	beq.w	.No_sp
	move.l	d0,a0
	move.l	Mev_ptr(a0),d1
	cmp.l	Script_last_sp,d0
	bne.w	.Changed
	cmp.l	Script_last_mev,d1
	beq.w	.No_sp
.Changed:	move.l	d0,Script_last_sp		; Yes -> Remember the time
	move.l	d1,Script_last_mev
	move.w	VBL_counter,Script_sp_time
.No_sp:	move.w	VBL_counter,d0		; Heartbeat in the log every 256 frames
	andi.w	#$ff,d0
	bne.w	.No_beat
	move.w	#$ff,d0
	jsr	Script_log_line
.No_beat:	tst.w	Script_wait		; Waiting ?
	beq.w	.Go
	subq.w	#1,Script_wait
	bra	.Exit
.Go:	lea.l	Script_buffer,a2
	moveq.l	#Script_steps-1,d7
.Loop:	move.l	Script_pc,d0
	cmp.l	#Script_max_size-2,d0	; Outside ?
	bhs	.Stop
	lea.l	0(a2,d0.l),a0
	move.w	(a0)+,d0			; Get opcode
	cmp.w	#SC_SEEDLOCK,d0		; Known ?
	bhi	.Stop
	add.w	d0,d0
	move.w	.Table(pc,d0.w),d0
	jmp	.Table(pc,d0.w)
.Table:	dc.w	.Stop-.Table,.Wait-.Table,.Key-.Table,.Mouse-.Table
	dc.w	.Buttons-.Table,.Free-.Table,.Jumpif-.Table,.Jump-.Table
	dc.w	.Set-.Table,.Add-.Table,.Log-.Table,.Mousetile-.Table
	dc.w	.Steer3D-.Table,.Get-.Table,.Jumpifv-.Table,.Align3D-.Table
	dc.w	.Steermouse-.Table,.Save-.Table,.Mousenpc-.Table
	dc.w	.Flow-.Table,.Mouseauto-.Table,.Mousespell-.Table
	dc.w	.Worlddir-.Table,.Call-.Table,.Ret-.Table
	dc.w	.Mouseitem-.Table,.Move3D-.Table,.Mousecell-.Table
	dc.w	.Flow3D-.Table,.Mousemonster-.Table,.Curve3D-.Table
	dc.w	.Seed-.Table,.Seedlock-.Table

; a0 points behind the opcode
.Wait:	move.w	(a0)+,d0
	bsr	.Next
	tst.w	d0
	beq.w	.Again
	subq.w	#1,d0			; This frame counts
	move.w	d0,Script_wait
	bra	.Exit
.Key:	move.l	(a0)+,d0
	bsr	.Next
	jsr	Store_Kev
	bra.w	.Again
.Mouse:	move.w	(a0)+,Script_X
	move.w	(a0)+,Script_Y
	bsr.w	.Next
	st	Script_mouse
	bra.w	.Again
.Buttons:	move.w	(a0)+,Script_buttons
	bsr.w	.Next
	st	Script_mouse
	bra.w	.Again
.Free:	bsr.w	.Next
	sf	Script_mouse
	clr.w	Script_buttons
	bra.w	.Again
.Jumpifv:	move.w	4(a0),d0			; Operands: var, comparison, var2, target
	jsr	Script_get_var
	move.w	d0,d2			; Value of var2
	move.w	(a0),d0
	jsr	Script_get_var		; Value of var
	move.w	2(a0),d1			; Comparison
	move.w	6(a0),d3			; Target
	addq.l	#8,a0
	bsr.w	.Next
	bra.w	.Compare
.Jumpif:	move.w	(a0)+,d0			; Get variable
	jsr	Script_get_var
	move.w	(a0)+,d1			; Get comparison
	move.w	(a0)+,d2			; Get value
	move.w	(a0)+,d3			; Get target
	bsr.w	.Next
.Compare:
	cmp.w	#1,d1
	beq.w	.Ne
	cmp.w	#2,d1
	beq.w	.Lt
	cmp.w	#3,d1
	beq.w	.Ge
	cmp.w	#4,d1
	beq.w	.Gt
	cmp.w	#5,d1
	beq.w	.Le
	cmp.w	d2,d0			; =
	beq.w	.Take
	bra.w	.Again
.Ne:	cmp.w	d2,d0
	bne.w	.Take
	bra.w	.Again
.Lt:	cmp.w	d2,d0
	blt.w	.Take
	bra.w	.Again
.Ge:	cmp.w	d2,d0
	bge.w	.Take
	bra.w	.Again
.Gt:	cmp.w	d2,d0
	bgt.w	.Take
	bra.w	.Again
.Le:	cmp.w	d2,d0
	ble.w	.Take
	bra.w	.Again
.Take:	moveq.l	#0,d0
	move.w	d3,d0
	move.l	d0,Script_pc
	bra.w	.Again
.Jump:	moveq.l	#0,d0
	move.w	(a0)+,d0
	move.l	d0,Script_pc
	bra.w	.Again
.Set:	move.w	(a0)+,d0			; Get register
	move.w	(a0)+,d1
	bsr.w	.Next
	andi.w	#7,d0
	add.w	d0,d0
	lea.l	Script_regs,a1
	move.w	d1,0(a1,d0.w)
	bra.w	.Again
.Add:	move.w	(a0)+,d0
	move.w	(a0)+,d1
	bsr.w	.Next
	andi.w	#7,d0
	add.w	d0,d0
	lea.l	Script_regs,a1
	add.w	d1,0(a1,d0.w)
	bra.w	.Again
.Mousetile:
	move.w	(a0)+,d0			; Get dx, dy
	move.w	(a0)+,d1
	bsr.w	.Next
	add.w	Mapbuf_X,d0		; X = Map2D_X + 16 * (Mapbuf_X + dx) + 8
	lsl.w	#4,d0
	addi.w	#Map2D_X+8,d0
	add.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y+8,d1
	move.w	d0,Script_X
	move.w	d1,Script_Y
	st	Script_mouse
	bra.w	.Again
.Steer3D:	move.w	(a0)+,d0			; Get target square
	move.w	(a0)+,d1
	bsr.w	.Next
	jsr	Script_steer_3D
	bra.w	.Exit			; One step per frame
.Steermouse:
	move.w	(a0)+,d0			; Get target square
	move.w	(a0)+,d1
	bsr.w	.Next
	jsr	Script_steer_mouse
	bra.w	.Exit			; One step per frame
.Align3D:	move.w	(a0)+,d1			; Get the angle
	bsr.w	.Next
	move.w	Y_angle,d0		; Difference (-512..511)
	sub.w	d1,d0
	andi.w	#slang-1,d0
	cmp.w	#slang/2,d0
	blt.w	.Pos_diff
	subi.w	#slang,d0
.Pos_diff:	move.w	d0,Script_regs+12		; r6
	clr.w	Script_regs+10		; r5
	move.w	d0,d1
	bpl.w	.Abs_diff
	neg.w	d1
.Abs_diff:	move.w	Dungeon_speed,d2		; Tolerance: half a turn step + 2
	lsr.w	#4,d2			; (a step is Dungeon_speed / 8, which
	addq.w	#2,d2			;  depends on the frame rate)
	cmp.w	d2,d1
	bgt.w	.Not_aligned
	move.w	#1,Script_regs+10		; Aligned
	bra.w	.Exit
.Not_aligned:
	cmp.w	#160,d1			; Small ?
	bgt.w	.Exit
	move.l	#$004e0000,d0		; Too far left -> cursor right
	tst.w	Script_regs+12
	bgt.w	.Fine
	move.l	#$004f0000,d0		; Too far right -> cursor left
.Fine:	jsr	Store_Kev
	bra.w	.Exit			; One key per frame
.Get:	move.w	(a0)+,d1			; Get register
	move.w	(a0)+,d0			; Get variable
	bsr.w	.Next
	jsr	Script_get_var
	andi.w	#7,d1
	add.w	d1,d1
	lea.l	Script_regs,a1
	move.w	d0,0(a1,d1.w)
	bra.w	.Again
.Log:	move.w	(a0)+,d0			; Get tag
	bsr.w	.Next
	jsr	Script_log_line
	bra.w	.Again
.Mousenpc:	move.w	(a0)+,d0			; Get slot
	bsr.w	.Next
	move.w	d0,d5			; (bits 8-9: 1 = 45 degrees left,
	lsr.w	#8,d5			;  2 = 45 degrees right of it)
	andi.w	#Max_chars-1,d0
	lea.l	VNPC_data,a1
	mulu.w	#VNPC_data_size,d0
	add.l	d0,a1
	move.w	VMap_X(a1),d0		; X = Map2D_X + 16 * (Mapbuf_X + dx) + 8
	sub.w	Map_Xcoord,d0		;  (dx, dy at most one square: the
	bsr.w	.Clip1			;  direction, inside the map view)
	add.w	Mapbuf_X,d0
	lsl.w	#4,d0
	addi.w	#Map2D_X+8,d0
	move.w	VMap_Y(a1),d1
	sub.w	Map_Ycoord,d1
	exg	d0,d1
	bsr.w	.Clip1
	exg	d0,d1
	tst.w	d5			; Turn the direction ?
	beq.w	.No_turn
	lea.l	.Dir_ring(pc),a1		; Find it in the ring
	moveq.l	#0,d4
.Ring:	cmp.b	(a1,d4.w),d0
	bne.w	.Ring_next
	cmp.b	1(a1,d4.w),d1
	beq.w	.Ring_found
.Ring_next:	addq.w	#2,d4
	cmp.w	#16,d4
	blo.w	.Ring
	bra.w	.No_turn
.Ring_found:	cmp.w	#1,d5			; Left: one back, right: one on
	bne.w	.Ring_right
	subq.w	#2,d4
	bra.w	.Ring_wrap
.Ring_right:	addq.w	#2,d4
.Ring_wrap:	andi.w	#15,d4
	move.b	(a1,d4.w),d0
	ext.w	d0
	move.b	1(a1,d4.w),d1
	ext.w	d1
.No_turn:	add.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y+8,d1
	move.w	d0,Script_X
	move.w	d1,Script_Y
	st	Script_mouse
	bra.w	.Again
.Mouseauto:
	move.w	(a0)+,d0			; X = window X + 32 + 8 * (x - 1 - Automap_X) + 4
	move.w	(a0)+,d1
	bsr.w	.Next
	subq.w	#1,d0
	sub.w	Automap_X,d0
	lsl.w	#3,d0
	addi.w	#Automap_window_X+32+4,d0
	subq.w	#1,d1
	sub.w	Automap_Y,d1
	lsl.w	#3,d1
	addi.w	#Automap_window_Y+32+4,d1
	move.w	d0,Script_X
	move.w	d1,Script_Y
	st	Script_mouse
	moveq.l	#0,d2			; Visible ? (r2 / r6: scroll
	cmp.w	#36,d0			;  direction x / y, r5 = 1 if
	bge.w	.Auto_x1			;  visible)
	moveq.l	#-1,d2
.Auto_x1:	cmp.w	#200,d0
	ble.w	.Auto_x2
	moveq.l	#1,d2
.Auto_x2:	moveq.l	#0,d3
	cmp.w	#Automap_window_Y+36,d1
	bge.w	.Auto_y1
	moveq.l	#-1,d3
.Auto_y1:	cmp.w	#199,d1
	ble.w	.Auto_y2
	moveq.l	#1,d3
.Auto_y2:	move.w	d2,Script_regs+4		; r2
	move.w	d3,Script_regs+12		; r6
	clr.w	Script_regs+10		; r5
	move.w	d2,d4
	or.w	d3,d4
	bne.w	.Again
	move.w	#1,Script_regs+10
	bra.w	.Again
.Mousespell:
	move.w	(a0)+,d0			; Get spell number
	bsr.w	.Next
	clr.w	Script_regs+10		; r5 = 0
	lea.l	Spell_table,a1		; Search
	moveq.l	#0,d1
.Spell_loop:	cmp.w	Nr_of_spells,d1
	bhs.w	.Again
	cmp.b	1(a1),d0
	beq.w	.Spell_found
	addq.l	#4,a1
	addq.w	#1,d1
	bra.w	.Spell_loop
.Spell_found:	sub.w	Scroll_bar_result,d1	; Visible line ?
	bmi.w	.Again
	cmp.w	#16,d1
	bhs.w	.Again
	mulu.w	#Char_height+2,d1		; Y = window Y + 2 + 7 * line + 3
	addi.w	#SpSelW_Y+2+3,d1
	move.w	d1,Script_Y
	move.w	#SpSelW_X+40,Script_X
	st	Script_mouse
	move.w	#1,Script_regs+10		; r5 = 1
	bra.w	.Again
.Worlddir:
	move.w	(a0)+,d2			; Get target
	move.w	(a0)+,d3
	bsr.w	.Next
	move.w	Map_nr,d0			; Global position
	subq.w	#1,d0
	move.w	d0,d1
	andi.w	#15,d0
	mulu.w	Submap_width,d0
	add.w	Map_Xcoord,d0
	lsr.w	#4,d1
	mulu.w	Submap_width,d1
	add.w	Map_Ycoord,d1
	sub.w	d0,d2			; Direction
	sub.w	d1,d3
	move.w	d2,d0
	bsr.w	.Clip1
	move.w	d0,d2
	move.w	d3,d0
	bsr.w	.Clip1
	move.w	d0,d3
	move.w	d2,d4			; Arrived ?
	or.w	d3,d4
	bne.w	.World_go
	clr.w	Script_buttons
	move.w	#1,Script_regs+10		; r5 = 1
	bra.w	.Again
.World_go:	add.w	Mapbuf_X,d2		; Pointer next to the party
	lsl.w	#4,d2
	addi.w	#Map2D_X+8,d2
	move.w	d2,Script_X
	add.w	Mapbuf_Y,d3
	lsl.w	#4,d3
	addi.w	#Map2D_Y+8,d3
	move.w	d3,Script_Y
	move.w	#1,Script_buttons
	st	Script_mouse
	clr.w	Script_regs+10		; r5 = 0
	bra.w	.Again
.Mouseitem:
	move.w	(a0)+,d2			; Get item & mode
	move.w	(a0)+,d3
	bsr.w	.Next
	clr.w	Script_regs+10		; r5 = 0
	move.w	d3,d0			; Member
	lsr.w	#8,d0
	bne.w	.Item_member
	move.w	Active_member,d0
.Item_member:	subq.w	#1,d0
	cmp.w	#6,d0
	bhs.w	.Again
	lea.l	Party_handles,a1
	move.b	0(a1,d0.w),d0
	beq.w	.Again
	movem.l	a0/a2,-(sp)		; Character data (no claim: read only)
	jsr	Check_handle
	move.l	(a0),a1
	movem.l	(sp)+,a0/a2
	bne.w	.Again
	lea.l	Char_inventory+9*Object_packet_size(a1),a1
	moveq.l	#0,d1			; Search the first 12 slots
.Item_loop:	cmp.w	Object_index(a1),d2
	beq.w	.Item_found
	lea.l	Object_packet_size(a1),a1
	addq.w	#1,d1
	cmp.w	#12,d1
	blo.w	.Item_loop
	bra.w	.Again
.Item_found:	andi.w	#$ff,d3
	bne.w	.Item_inv
	moveq.l	#0,d0			; Item area: 6 x 2
	move.w	d1,d0
	divu.w	#6,d0
	move.w	d0,d4			; Row
	swap	d0			; Column
	mulu.w	#22,d0
	addi.w	#27,d0
	mulu.w	#26,d4
	addi.w	#152,d4
	bra.w	.Item_set
.Item_inv:	moveq.l	#0,d0			; Inventory: 3 x 4
	move.w	d1,d0
	divu.w	#3,d0
	move.w	d0,d4
	swap	d0
	mulu.w	#22,d0
	addi.w	#117,d0
	mulu.w	#29,d4
	addi.w	#88,d4
.Item_set:	move.w	d0,Script_X
	move.w	d4,Script_Y
	st	Script_mouse
	move.w	#1,Script_regs+10		; r5 = 1
	bra.w	.Again
.Mousecell:	move.w	(a0)+,d0			; Get member
	bsr.w	.Next
	subq.w	#1,d0			; Its participant data (current
	andi.w	#7,d0			;  position, members can move)
	mulu.w	#Participant_data_size,d0
	lea.l	Combat_party,a1
	add.l	d0,a1
	move.w	Part_X(a1),d1		; X = Tactic_X + 16 * column + 8
	lsl.w	#4,d1
	addi.w	#Tactic_X+8,d1
	move.w	Part_Y(a1),d2		; Y = Tactic_Y + 13 * row + 6
	mulu.w	#Tactic_cell_height,d2
	addi.w	#Tactic_Y+Tactic_cell_height/2,d2
	move.w	d1,Script_X
	move.w	d2,Script_Y
	st	Script_mouse
	bra.w	.Again
.Seedlock:	move.l	(a0)+,Script_seed_lock	; Lock the random seed (0 = off)
	bsr.w	.Next
	bra.w	.Again
.Seed:	move.l	(a0)+,Seed		; Set the random seed
	bsr.w	.Next
	bra.w	.Again
.Curve3D:	move.w	(a0)+,d0			; Get target square
	move.w	(a0)+,d1
	bsr.w	.Next
	jsr	Script_curve_3D
	bra.w	.Again
.Mousemonster:
	bsr.w	.Next
	lea.l	Combat_monsters,a1
	move.w	Part_X(a1),d0		; X = Tactic_X + 16 * column + 8
	lsl.w	#4,d0
	addi.w	#Tactic_X+8,d0
	move.w	Part_Y(a1),d1		; Y = Tactic_Y + 13 * row + 6
	mulu.w	#Tactic_cell_height,d1
	addi.w	#Tactic_Y+Tactic_cell_height/2,d1
	move.w	d0,Script_X
	move.w	d1,Script_Y
	st	Script_mouse
	bra.w	.Again
.Flow3D:	moveq.l	#0,d0			; Get table
	move.w	(a0)+,d0
	bsr.w	.Next
	lea.l	0(a2,d0.l),a1
	move.w	Map_Xcoord,d0		; Inside ?
	subq.w	#1,d0
	bmi.w	.F3_no_way
	cmp.w	(a1),d0
	bhs.w	.F3_no_way
	move.w	Map_Ycoord,d1
	subq.w	#1,d1
	bmi.w	.F3_no_way
	cmp.w	2(a1),d1
	bhs.w	.F3_no_way
	mulu.w	(a1),d1			; Direction of this square (nibble)
	add.w	d0,d1
	move.l	d1,d0
	lsr.l	#1,d0
	move.b	4(a1,d0.l),d0
	btst	#0,d1
	bne.w	.F3_low
	lsr.b	#4,d0
.F3_low:	andi.w	#$000f,d0
	beq.w	.F3_arrived
	cmp.w	#8,d0
	bhi.w	.F3_no_way
	clr.w	Script_regs+10		; r5 = 0
	move.w	d0,d1			; 1/3/5/7 -> N/E/S/W
	subq.w	#1,d1
	lsr.w	#1,d1
; Centred in the square across the direction ? (else the party hits the
; corners): first sideways to the middle (tolerance 64 of 512)
	btst	#0,d1			; North / south ?
	bne.w	.F3_ew
	move.w	Map_Xcoord,d2		; X centre = (x - 1) * 512 + 256
	subq.w	#1,d2
	moveq.l	#psize_log,d3
	lsl.w	d3,d2
	addi.w	#patt_size/2,d2
	move.w	Player_X,d3
	sub.w	d2,d3
	cmp.w	#64,d3
	ble.w	.F3_x1
	moveq.l	#3,d1			; Too far east: west
	bra.w	.Move3D_dir
.F3_x1:	cmp.w	#-64,d3
	bge.w	.Move3D_dir
	moveq.l	#1,d1			; Too far west: east
	bra.w	.Move3D_dir
.F3_ew:	move.w	Height_of_map,d2		; Y centre = (h - y) * 512 + 256
	sub.w	Map_Ycoord,d2		;  (dungeon Y is up)
	moveq.l	#psize_log,d3
	lsl.w	d3,d2
	addi.w	#patt_size/2,d2
	move.w	Player_Y,d3
	sub.w	d2,d3
	cmp.w	#64,d3
	ble.w	.F3_y1
	moveq.l	#2,d1			; Too far north: south
	bra.w	.Move3D_dir
.F3_y1:	cmp.w	#-64,d3
	bge.w	.Move3D_dir
	moveq.l	#0,d1			; Too far south: north
	bra.w	.Move3D_dir
.F3_arrived:	move.w	Map_Xcoord,d2		; In the middle of the square ? (else
	subq.w	#1,d2			;  move there first: turns and walks
	moveq.l	#psize_log,d3		;  on from here do not hit corners)
	lsl.w	d3,d2
	addi.w	#patt_size/2,d2
	move.w	Player_X,d3
	sub.w	d2,d3
	moveq.l	#3,d1			; Too far east: west
	cmp.w	#64,d3
	bgt.w	.F3_centre
	moveq.l	#1,d1			; Too far west: east
	cmp.w	#-64,d3
	blt.w	.F3_centre
	move.w	Height_of_map,d2
	sub.w	Map_Ycoord,d2
	moveq.l	#psize_log,d3
	lsl.w	d3,d2
	addi.w	#patt_size/2,d2
	move.w	Player_Y,d3
	sub.w	d2,d3
	moveq.l	#2,d1			; Too far north: south
	cmp.w	#64,d3
	bgt.w	.F3_centre
	moveq.l	#0,d1			; Too far south: north
	cmp.w	#-64,d3
	blt.w	.F3_centre
	clr.w	Script_buttons		; Yes: arrived
	move.w	#1,Script_regs+10
	bra.w	.Again
.F3_centre:	clr.w	Script_regs+10
	bra.w	.Move3D_dir
.F3_no_way:	clr.w	Script_buttons
	move.w	#2,Script_regs+10
	bra.w	.Again
.Move3D:	move.w	(a0)+,d1			; Get map direction
	bsr.w	.Next
.Move3D_dir:	move.w	Y_angle,d0		; View: 0 north, 1 west, 2 south,
	addi.w	#slang/8,d0		;  3 east (the angle grows to the left)
	andi.w	#slang-1,d0
	lsr.w	#8,d0
	neg.w	d0			; -> 0 north, 1 east, 2 south, 3 west
	andi.w	#3,d0
	sub.w	d0,d1			; Relative: 0 forward, 1 right,
	andi.w	#3,d1			;  2 back, 3 left
	add.w	d1,d1
	add.w	d1,d1
	lea.l	.Move_zones(pc),a1
	move.w	0(a1,d1.w),Script_X
	move.w	2(a1,d1.w),Script_Y
	move.w	#1,Script_buttons
	st	Script_mouse
	bra.w	.Again
.Move_zones:	dc.w	104,50,174,120,104,191,33,120
.Call:	moveq.l	#0,d1			; Get target
	move.w	(a0)+,d1
	bsr.w	.Next
	move.w	Script_sp,d0		; Push the return position
	cmp.w	#8,d0
	bhs.w	.Stop
	lsl.w	#2,d0
	lea.l	Script_stack,a1
	move.l	Script_pc,0(a1,d0.w)
	addq.w	#1,Script_sp
	move.l	d1,Script_pc
	bra.w	.Again
.Ret:	move.w	Script_sp,d0		; Pop
	beq.w	.Stop
	subq.w	#1,d0
	move.w	d0,Script_sp
	lsl.w	#2,d0
	lea.l	Script_stack,a1
	move.l	0(a1,d0.w),Script_pc
	bra.w	.Again
; The 8 directions clockwise (dx, dy), up first
.Dir_ring:	dc.b	0,-1,1,-1,1,0,1,1,0,1,-1,1,-1,0,-1,-1
; d0.w limited to -1..1
.Clip1:	cmp.w	#1,d0
	ble.w	.Clip1_low
	moveq.l	#1,d0
.Clip1_low:	cmp.w	#-1,d0
	bge.w	.Clip1_ok
	moveq.l	#-1,d0
.Clip1_ok:	rts
.Flow:	moveq.l	#0,d0			; Get table
	move.w	(a0)+,d0
	bsr.w	.Next
	lea.l	0(a2,d0.l),a1
	move.w	Map_Xcoord,d0		; Inside ?
	subq.w	#1,d0
	bmi.w	.No_way
	cmp.w	(a1),d0
	bhs.w	.No_way
	move.w	Map_Ycoord,d1
	subq.w	#1,d1
	bmi.w	.No_way
	cmp.w	2(a1),d1
	bhs.w	.No_way
	mulu.w	(a1),d1			; Direction of this square
	add.w	d0,d1			;  (4 bits each, high nibble first)
	move.l	d1,d0
	lsr.l	#1,d0
	move.b	4(a1,d0.l),d0
	btst	#0,d1
	bne.w	.Low_nibble
	lsr.b	#4,d0
.Low_nibble:	andi.w	#$000f,d0
	beq.w	.Arrived
	cmp.w	#8,d0
	bhi.w	.No_way
	add.w	d0,d0			; Pointer next to the party
	lea.l	.Flow_dirs-2(pc),a1
	move.b	0(a1,d0.w),d1
	ext.w	d1
	add.w	Mapbuf_X,d1
	lsl.w	#4,d1
	addi.w	#Map2D_X+8,d1
	move.w	d1,Script_X
	move.b	1(a1,d0.w),d1
	ext.w	d1
	add.w	Mapbuf_Y,d1
	lsl.w	#4,d1
	addi.w	#Map2D_Y+8,d1
	move.w	d1,Script_Y
	move.w	#1,Script_buttons
	st	Script_mouse
	clr.w	Script_regs+10		; r5 = 0
	bra.w	.Again
.Arrived:	clr.w	Script_buttons
	move.w	#1,Script_regs+10		; r5 = 1
	bra.w	.Again
.No_way:	clr.w	Script_buttons
	move.w	#2,Script_regs+10		; r5 = 2
	bra.w	.Again
.Flow_dirs:	dc.b	0,-1,1,-1,1,0,1,1,0,1,-1,1,-1,0,-1,-1
.Save:	tst.b	Script_save_done		; Saved ?
	bne.w	.Saved
	tst.w	Script_save_slot		; No -> Requested ?
	bne.w	.Exit
	move.w	(a0),Script_save_slot	; No -> Request
	bra.w	.Exit
.Saved:	sf	Script_save_done
	addq.l	#2,a0
	bsr.w	.Next
	bra.w	.Again
.Again:	dbra	d7,.Loop
	bra.w	.Exit			; Enough for this frame
.Stop:	sf	Script_running		; End of the script
	sf	Script_mouse
	clr.w	Script_buttons
.Exit:	movem.l	(sp)+,d0-d7/a0-a2
.Exit2:	rts

; The next instruction starts at a0
.Next:	move.l	a0,d6
	sub.l	a2,d6
	move.l	d6,Script_pc
	rts

;*****************************************************************************
; [ Add a line to the log ]
;   IN : d0 - Tag (.w)
; All registers are restored
;*****************************************************************************
Script_log_line:
	movem.l	d0-d3/a0/a1,-(sp)
	move.l	Script_log_length,d1
	cmp.l	#Script_log_size-64,d1	; Full ?
	bhi.w	.Exit
	lea.l	Script_log,a1
	add.l	d1,a1
	bsr.w	.Hex			; Tag
	lea.l	.Vars(pc),a0
	moveq.l	#6-1,d2			; Frame, map, x, y, module, depth
.Loop:	move.w	(a0)+,d0
	jsr	Script_get_var
	bsr.w	.Hex
	dbra	d2,.Loop
	move.w	Script_regs,d0		; r0, r1
	bsr.w	.Hex
	move.w	Script_pc+2,d0		; Script position (instead of r1)
	bsr.w	.Hex
	move.b	#10,-1(a1)		; End of line instead of the last space
	lea.l	Script_log,a0
	sub.l	a0,a1
	move.l	a1,Script_log_length
	st	Script_log_dirty
.Exit:	movem.l	(sp)+,d0-d3/a0/a1
	rts

.Vars:	dc.w	5,0,1,2,3,4

; d0.w as 4 hex digits and a space at a1
.Hex:	movem.l	d1/d2,-(sp)
	moveq.l	#4-1,d2
.Digit:	rol.w	#4,d0
	move.w	d0,d1
	andi.w	#$f,d1
	addi.w	#'0',d1
	cmp.w	#'9',d1
	bls.w	.Ok
	addi.w	#'a'-'9'-1,d1
.Ok:	move.b	d1,(a1)+
	dbra	d2,.Digit
	move.b	#' ',(a1)+
	movem.l	(sp)+,d1/d2
	rts

;*****************************************************************************
; [ Write the log (called by the main loop) ]
; NOTE :
;   - At most once per second, and only when something was added.
; All registers are restored
;*****************************************************************************
Script_flush:
	tst.w	Script_save_slot		; Save requested ?
	beq.w	.No_save
	tst.b	Script_save_done
	bne.w	.No_save
	jsr	Script_save_game
.No_save:	tst.b	Script_log_dirty
	beq.w	.Exit2
	movem.l	d0-d3/a0/a1/a6,-(sp)
	move.w	VBL_counter,d0
	sub.w	Script_log_time,d0
	cmp.w	#50,d0
	blo.w	.Exit
	move.w	VBL_counter,Script_log_time
	sf	Script_log_dirty
	move.l	#Script_log_filename,d1
	move.l	#1006,d2			; MODE_NEWFILE
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)
	tst.l	d0
	beq.w	.Exit
	move.l	d0,-(sp)
	move.l	d0,d1
	move.l	#Script_log,d2
	move.l	Script_log_length,d3
	jsr	_LVOWrite(a6)
	move.l	(sp)+,d1
	jsr	_LVOClose(a6)
.Exit:	movem.l	(sp)+,d0-d3/a0/a1/a6
.Exit2:	rts

;*****************************************************************************
; [ One frame of running to a square on a 3D map, steering on the way ]
;   IN : d0 - Map X-coordinate of the target square (.w)
;        d1 - Map Y-coordinate of the target square (.w)
; NOTE :
;   - The mouse button is held in the 3D view: top middle (straight on), or
;     the top left / right zone (forward and turning; 45 degrees or more:
;     strongly, else slightly).
;   - Register 5 is 1 when the middle of the square is reached (100 units).
; All registers are restored
;*****************************************************************************
Script_curve_3D:
	movem.l	d0-d7/a0,-(sp)
	subq.w	#1,d0			; Target in dungeon coordinates
	moveq.l	#psize_log,d2
	lsl.w	d2,d0
	addi.w	#patt_size/2,d0
	move.w	Height_of_map,d3
	sub.w	d1,d3
	lsl.w	d2,d3
	addi.w	#patt_size/2,d3
	sub.w	Player_X,d0		; Vector to the target (vx, vy)
	sub.w	Player_Y,d3
	move.w	d3,d1
	move.w	d0,d2			; Reached ?
	bpl.w	.Abs_x
	neg.w	d2
.Abs_x:	cmp.w	#100,d2
	bhs.w	.Go
	move.w	d1,d2
	bpl.w	.Abs_y
	neg.w	d2
.Abs_y:	cmp.w	#100,d2
	bhs.w	.Go
	move.w	#1,Script_regs+10		; Yes
	clr.w	Script_buttons
	bra.w	.Exit
.Go:	clr.w	Script_regs+10
	lea.l	Sinus_table,a0		; Facing f = (-sin, cos)
	move.w	Y_angle,d2
	andi.w	#slang-1,d2
	add.w	d2,d2
	move.w	0(a0,d2.w),d4		; Sine
	addi.w	#slang/2,d2
	andi.w	#slang*2-1,d2
	move.w	0(a0,d2.w),d5		; Cosine
	neg.w	d4			; fx
	move.w	d4,d6			; Dot = fx * vx + fy * vy
	muls.w	d0,d6
	move.w	d5,d2
	muls.w	d1,d2
	add.l	d2,d6
	move.w	d4,d7			; Cross = fx * vy - fy * vx
	muls.w	d1,d7
	move.w	d5,d2
	muls.w	d0,d2
	sub.l	d2,d7
	move.l	d7,d3			; |cross|
	bpl.w	.Abs_c
	neg.l	d3
.Abs_c:	move.l	d3,d2			; More than 2 degrees ? (|cross| * 32 > dot)
	lsl.l	#5,d2
	tst.l	d6			; Behind (passed it) ? Reached
	bgt.w	.Ahead			;  (else the party would circle around it)
	move.w	#1,Script_regs+10
	clr.w	Script_buttons
	bra.w	.Exit
.Ahead:	cmp.l	d6,d2
	ble.w	.Straight
	moveq.l	#4,d4			; Steering strength: slight
.Mild:	tst.l	d7			; Left (cross >= 0) or right
	bpl.w	.Left
	move.w	#Map3D_X+96,d0		; Top right zone
	add.w	d4,d0
	bra.w	.Set
.Left:	move.w	#Map3D_X+48-1,d0		; Top left zone
	sub.w	d4,d0
.Set:	move.w	d0,Script_X
	move.w	#Map3D_Y+1,Script_Y
	bra.w	.Hold
.Straight:	move.w	#104,Script_X		; Top middle: forward at full speed
	move.w	#50,Script_Y
.Hold:	move.w	#1,Script_buttons
	st	Script_mouse
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Save the game into the slot Script_save_slot ]
; NOTE :
;   - Like the save in the options menu after the slot was selected.
; All registers are restored
;*****************************************************************************
Script_save_game:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#Saves_file,d0		; Load saves file
	jsr	Load_file
	move.b	d0,Saves_handle
	jsr	Claim_pointer
	move.l	d0,a0
	move.w	Script_save_slot,d0
	move.w	d0,Selected_save
	subq.w	#1,d0			; Name of the slot
	mulu.w	#Save_name_length+1,d0
	lea.l	2(a0,d0.l),a0
	lea.l	Script_save_name,a1
	moveq.l	#Save_name_length+1-1,d7
.Copy:	move.b	(a1)+,(a0)+
	dbra	d7,.Copy
	move.b	Saves_handle,d0
	jsr	Free_pointer
	jsr	Save_game_selected
	clr.w	Script_save_slot
	st	Script_save_done
	moveq.l	#$5a,d0			; Log
	jsr	Script_log_line
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ One frame of walking to a square on a 3D map ]
;   IN : d0 - Map X-coordinate of the target square (.w)
;        d1 - Map Y-coordinate of the target square (.w)
; NOTE :
;   - Only key presses: turn left/right while the target is not ahead,
;     forward while it is roughly ahead (less than 45 degrees).
;   - Register 5 is 1 when the middle of the square is reached, else 0.
; All registers are restored
;*****************************************************************************
Script_steer_3D:
	movem.l	d0-d7/a0,-(sp)
	subq.w	#1,d0			; Target in dungeon coordinates
	moveq.l	#psize_log,d2
	lsl.w	d2,d0
	addi.w	#patt_size/2,d0
	move.w	Height_of_map,d3
	sub.w	d1,d3
	lsl.w	d2,d3
	addi.w	#patt_size/2,d3
	sub.w	Player_X,d0		; Vector to the target (vx, vy)
	sub.w	Player_Y,d3
	move.w	d3,d1
	move.w	d0,d2			; Reached ?
	bpl.w	.Abs_x
	neg.w	d2
.Abs_x:	cmp.w	#100,d2
	bhs.w	.Go
	move.w	d1,d2
	bpl.w	.Abs_y
	neg.w	d2
.Abs_y:	cmp.w	#100,d2
	bhs.w	.Go
	move.w	#1,Script_regs+10		; Yes
	bra.w	.Exit
.Go:	clr.w	Script_regs+10
	lea.l	Sinus_table,a0		; Facing f = (-sin, cos)
	move.w	Y_angle,d2
	andi.w	#slang-1,d2
	add.w	d2,d2
	move.w	0(a0,d2.w),d4		; Sine
	addi.w	#slang/2,d2
	andi.w	#slang*2-1,d2
	move.w	0(a0,d2.w),d5		; Cosine
	neg.w	d4			; fx
	move.w	d4,d6			; Dot = fx * vx + fy * vy
	muls.w	d0,d6
	move.w	d5,d7
	muls.w	d1,d7
	add.l	d7,d6
	move.w	d4,d7			; Cross = fx * vy - fy * vx
	muls.w	d1,d7
	move.w	d5,d2
	muls.w	d0,d2
	sub.l	d2,d7
	move.l	d7,d3			; |cross|
	bpl.w	.Abs_c
	neg.l	d3
.Abs_c:	move.l	d6,d2			; Turn if |cross| > dot / 8 or behind
	asr.l	#3,d2
	cmp.l	d2,d3
	ble.w	.No_turn
	move.l	#$004f0000,d0		; Cursor left (turn left)
	tst.l	d7
	bpl.w	.Turn
	move.l	#$004e0000,d0		; Cursor right (turn right)
.Turn:	jsr	Store_Kev
.No_turn:	tst.l	d6			; Forward if ahead and |cross| < dot
	ble.w	.Exit
	cmp.l	d6,d3
	bge.w	.Exit
	move.l	#$004c0000,d0		; Cursor up (forward)
	jsr	Store_Kev
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ One frame of walking to a square on a 3D map with the mouse ]
;   IN : d0 - Map X-coordinate of the target square (.w)
;        d1 - Map Y-coordinate of the target square (.w)
; NOTE :
;   - The mouse button is held in the 3D view (see [ Moving_mouse ]):
;     top middle zone (x 80-127) = forward at full speed, top left zone
;     (x 32-79) = turn left and forward (the more to the left, the stronger),
;     top right zone (x 128-175) = turn right and forward.
;   - Register 5 is 1 when the middle of the square is reached (the button is
;     released then), else 0.
; All registers are restored
;*****************************************************************************
Script_steer_mouse:
	movem.l	d0-d7/a0,-(sp)
	subq.w	#1,d0			; Target in dungeon coordinates
	moveq.l	#psize_log,d2
	lsl.w	d2,d0
	addi.w	#patt_size/2,d0
	move.w	Height_of_map,d3
	sub.w	d1,d3
	lsl.w	d2,d3
	addi.w	#patt_size/2,d3
	sub.w	Player_X,d0		; Vector to the target (vx, vy)
	sub.w	Player_Y,d3
	move.w	d3,d1
	move.w	d0,d2			; Reached ?
	bpl.w	.Abs_x
	neg.w	d2
.Abs_x:	cmp.w	#100,d2
	bhs.w	.Go
	move.w	d1,d2
	bpl.w	.Abs_y
	neg.w	d2
.Abs_y:	cmp.w	#100,d2
	bhs.w	.Go
	move.w	#1,Script_regs+10		; Yes
	clr.w	Script_buttons
	bra.w	.Exit
.Go:	clr.w	Script_regs+10
	lea.l	Sinus_table,a0		; Facing f = (-sin, cos)
	move.w	Y_angle,d2
	andi.w	#slang-1,d2
	add.w	d2,d2
	move.w	0(a0,d2.w),d4		; Sine
	addi.w	#slang/2,d2
	andi.w	#slang*2-1,d2
	move.w	0(a0,d2.w),d5		; Cosine
	neg.w	d4			; fx
	move.w	d4,d6			; Dot = fx * vx + fy * vy
	muls.w	d0,d6
	move.w	d5,d7
	muls.w	d1,d7
	add.l	d7,d6
	move.w	d4,d7			; Cross = fx * vy - fy * vx
	muls.w	d1,d7
	move.w	d5,d2
	muls.w	d0,d2
	sub.l	d2,d7
	move.l	d7,d3			; |cross|
	bpl.w	.Abs_c
	neg.l	d3
.Abs_c:	tst.w	Script_turn_wait		; Waiting for a 90 degree turn ?
	beq.w	.No_wait
	subq.w	#1,Script_turn_wait
	clr.w	Script_buttons
	bra.w	.Exit
.No_wait:	asr.l	#8,d6			; Dot / 4096
	asr.l	#4,d6
	ble.w	.Turn90			; Behind -> 90 degree turn
	move.l	d3,d2			; |cross| / 4096
	lsr.l	#8,d2
	lsr.l	#4,d2
	cmp.l	d6,d2			; More than 45 degrees ?
	bhs.w	.Turn90
	move.l	d2,d0			; More than 7 degrees ?
	lsl.l	#3,d0
	cmp.l	d6,d0
	bhi.w	.Turn_keys
	move.w	#104,Script_X		; No -> top middle: forward at full speed
	move.w	#50,Script_Y
	move.w	#1,Script_buttons
	st	Script_mouse
	bra.w	.Exit
.Turn_keys:
	clr.w	Script_buttons		; Turn on the spot with the cursor keys
	tst.b	Mouse_moving		; (not while the mouse module is active)
	bne.w	.Exit
	move.l	#$004f0000,d0		; Cursor left
	tst.l	d7
	bpl.w	.Key
	move.l	#$004e0000,d0		; Cursor right
.Key:	jsr	Store_Kev
	bra.w	.Exit
.Turn90:	clr.w	Script_buttons		; 90 degrees with a right click
	tst.b	Mouse_moving		; (top left/right zone of the 3D view)
	bne.w	.Exit
	move.w	#56,Script_X
	tst.l	d7
	bpl.w	.Left90
	move.w	#152,Script_X
.Left90:	move.w	#60,Script_Y
	move.w	#2,Script_buttons
	st	Script_mouse
	move.w	#25,Script_turn_wait	; Release next frame, then wait
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Distance to the nearest monster ahead (3D maps) ]
;  OUT : d0 - Distance in squares along the view direction / 255 (.w)
; NOTE :
;   - Monsters at most one square to the side count.
; All other registers are restored
;*****************************************************************************
Script_monster_ahead:
	movem.l	d1-d7/a0,-(sp)
	move.w	Y_angle,d6		; Facing: 0 north, 1 west, 2 south, 3 east
	addi.w	#slang/8,d6
	andi.w	#slang-1,d6
	lsr.w	#8,d6
	move.w	#255,d0			; Nearest
	lea.l	VNPC_data,a0
	move.l	CD_value,d5
	moveq.l	#0,d7
.Loop:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq.w	.Next
	btst	d7,d5			; Deleted ?
	bne.w	.Next
	move.b	NPC_status_bits(a0),d1	; Monster ?
	andi.b	#3,d1
	cmp.b	#Monster_type,d1
	bne.w	.Next
	move.w	VMap_X(a0),d1		; Offset to the party (map: y down)
	sub.w	Map_Xcoord,d1
	move.w	VMap_Y(a0),d2
	sub.w	Map_Ycoord,d2
	cmp.w	#1,d6			; Ahead / side for the facing
	blt.w	.North
	beq.w	.West
	cmp.w	#2,d6
	beq.w	.South
	move.w	d1,d3			; East: ahead = dx, side = dy
	move.w	d2,d4
	bra.w	.Check
.North:	move.w	d2,d3			; North: ahead = -dy, side = dx
	neg.w	d3
	move.w	d1,d4
	bra.w	.Check
.West:	move.w	d1,d3			; West: ahead = -dx, side = dy
	neg.w	d3
	move.w	d2,d4
	bra.w	.Check
.South:	move.w	d2,d3			; South: ahead = dy, side = dx
	move.w	d1,d4
.Check:	tst.w	d3			; Ahead ?
	ble.w	.Next
	tst.w	d4			; At most one square to the side ?
	bpl.w	.Pos
	neg.w	d4
.Pos:	cmp.w	#1,d4
	bgt.w	.Next
	cmp.w	d0,d3			; Nearer ?
	bge.w	.Next
	move.w	d3,d0
.Next:	lea.l	VNPC_data_size(a0),a0
	addq.w	#1,d7
	cmp.w	#Max_chars,d7
	blt.w	.Loop
	movem.l	(sp)+,d1-d7/a0
	rts

;*****************************************************************************
; [ Get the value of a script variable ]
;   IN : d0 - Variable (.w)
;  OUT : d0 - Value (.w)
; NOTE :
;   0 map number, 1 X, 2 Y, 3 module ID, 4 module stack depth, 5 frame
;   counter, 6 mouse X, 7 mouse Y, 8 travel mode, 9 map type,
;   10 number of party members, 11 active member, 12/13 map buffer X/Y,
;   14 view direction, 15 3D angle (0-1023 = 360 degrees, 0 north, left +),
;   $18 3D angle 0-1023, $19/$1a 3D position X/Y (dungeon units, 512 per
;   square, Y up), $1b 1 while moving with the mouse on a 3D map (module
;   Mousemove_3D_Mod is pushed then), $1c distance to the nearest monster
;   ahead (3D, at most one square to the side; 255 = none), $1d 1 if the
;   top module is Mousemove_3D_Mod (walking with the mouse on a 3D map),
;   $1e frames since the module stack changed (at most 10000; every push and
;   pop clears the key buffer: keys only after it is stable for a moment),
;   $1f 1 if the second control icons of the map are shown (eye, hand, ...),
;   $20-$3f distance (in squares, max(|dx|, |dy|)) of the map character in
;   slot 0-31 to the party (255 = not there), $41-$46 1 if member 1-6 is
;   there and alive, $47 1 if the active member is alive, $48-$4d LP and
;   $4e-$53 SP of member 1-6, $54-$59 battle order slot (0-11) of member
;   1-6, $5a 1 if the current battle was started by an event, $40 the scroll
;   bar position
;   (e.g. first visible slot - 1 of a chest),
;   $10-$17 registers 0-7. Others are 0.
; All registers are restored
;*****************************************************************************
Script_get_var:
	movem.l	d1/a0,-(sp)
	cmp.w	#$18,d0			; 3D angle 0-1023 ?
	bne.w	.No_angle
	move.w	Y_angle,d0
	andi.w	#slang-1,d0
	bra.w	.Exit
.No_angle:	cmp.w	#$19,d0			; 3D position ?
	bne.w	.No_px
	move.w	Player_X,d0
	bra.w	.Exit
.No_px:	cmp.w	#$1a,d0
	bne.w	.No_py
	move.w	Player_Y,d0
	bra.w	.Exit
.No_py:	cmp.w	#$1b,d0			; Moving with the mouse (3D) ?
	bne.w	.No_mm
	moveq.l	#0,d0
	tst.b	Mouse_moving
	beq.w	.Exit
	moveq.l	#1,d0
	bra.w	.Exit
.No_mm:	cmp.w	#$1d,d0			; Top module = Mousemove_3D_Mod ?
	bne.w	.No_top
	move.l	Module_Sp,d0
	beq.w	.Exit
	move.l	d0,a0
	move.l	Mev_ptr(a0),d1
	moveq.l	#0,d0
	cmp.l	Mousemove_3D_Mod+Mev_ptr,d1
	bne.w	.Exit
	moveq.l	#1,d0
	bra.w	.Exit
.No_top:	cmp.w	#$1e,d0			; Frames since the module stack changed ?
	bne.w	.No_stable
	move.w	VBL_counter,d0
	sub.w	Script_sp_time,d0
	cmp.w	#10000,d0
	bls.w	.Exit
	move.w	#10000,d0
	bra.w	.Exit
.No_stable:	cmp.w	#$1f,d0			; Second control icons on the map ?
	bne.w	.No_cil
	moveq.l	#0,d0
	tst.b	Which_CIL
	beq.w	.Exit
	moveq.l	#1,d0
	bra.w	.Exit
.No_cil:	cmp.w	#$5a,d0			; Battle of an event (not a map monster) ?
	bne.w	.No_evbattle
	moveq.l	#0,d0
	tst.w	Combat_char_index
	bpl.w	.Exit
	moveq.l	#1,d0
	bra.w	.Exit
.No_evbattle:	cmp.w	#$48,d0			; LP / SP of member 1-6 ?
	blt.w	.No_lpsp
	cmp.w	#$53,d0
	bgt.w	.No_lpsp
	moveq.l	#0,d1			; Offset: LP or SP
	subi.w	#$48,d0
	cmp.w	#6,d0
	blt.w	.Lpsp_lp
	subq.w	#6,d0
	moveq.l	#Power_points-Life_points,d1
.Lpsp_lp:	lea.l	Party_handles,a0
	move.b	0(a0,d0.w),d0
	beq.w	.Zero
	jsr	Check_handle		; (no claim: read only)
	bne.w	.Zero
	move.l	(a0),a0
	add.w	d1,a0
	move.w	Life_points(a0),d0
	bra.w	.Exit
.No_lpsp:	cmp.w	#$54,d0			; Battle order slot of member 1-6 ?
	blt.w	.No_order
	cmp.w	#$59,d0
	bgt.w	.No_order
	subi.w	#$54,d0
	lea.l	Order,a0
	moveq.l	#0,d1
	move.b	0(a0,d0.w),d1
	move.w	d1,d0
	bra.w	.Exit
.No_order:	cmp.w	#$47,d0			; Active member alive ?
	bne.w	.No_act_alive
	move.w	Active_member,d0
	subq.w	#1,d0
	bmi.w	.Zero
	addi.w	#$41,d0
.No_act_alive:	cmp.w	#$41,d0			; Member 1-6 alive ?
	blt.w	.No_alive
	cmp.w	#$46,d0
	bgt.w	.No_alive
	subi.w	#$41,d0
	lea.l	Party_handles,a0
	move.b	0(a0,d0.w),d0
	beq.w	.Zero
	jsr	Check_handle		; (no claim: read only)
	bne.w	.Zero
	move.l	(a0),a0
	move.w	Body_conditions(a0),d0
	andi.w	#Dead_mask,d0
	seq	d0
	andi.w	#1,d0
	bra.w	.Exit
.No_alive:	cmp.w	#$40,d0			; Scroll bar position ?
	bne.w	.No_scroll
	move.w	Scroll_bar_result,d0
	bra.w	.Exit
.No_scroll:	cmp.w	#$20,d0			; Distance to a map character ?
	blt.w	.No_npc
	cmp.w	#$3f,d0
	bgt.w	.No_npc
	subi.w	#$20,d0
	move.l	CD_value,d1		; Deleted ?
	btst	d0,d1
	bne.w	.Far
	lea.l	VNPC_data,a0
	mulu.w	#VNPC_data_size,d0
	add.l	d0,a0
	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq.w	.Far
	move.w	VMap_X(a0),d0		; max(|dx|, |dy|)
	sub.w	Map_Xcoord,d0
	bpl.w	.Pos_x
	neg.w	d0
.Pos_x:	move.w	VMap_Y(a0),d1
	sub.w	Map_Ycoord,d1
	bpl.w	.Pos_y
	neg.w	d1
.Pos_y:	cmp.w	d1,d0
	bge.w	.Exit
	move.w	d1,d0
	bra.w	.Exit
.Far:	move.w	#255,d0
	bra.w	.Exit
.No_npc:	cmp.w	#$1c,d0			; Monster ahead (3D) ?
	bne.w	.No_ahead
	jsr	Script_monster_ahead
	bra.w	.Exit
.No_ahead:	cmp.w	#$10,d0			; Register ?
	blt.w	.Game
	cmp.w	#$17,d0
	bgt.w	.Zero
	subi.w	#$10,d0
	add.w	d0,d0
	lea.l	Script_regs,a0
	move.w	0(a0,d0.w),d0
	bra.w	.Exit
.Game:	cmp.w	#3,d0			; Module ID ?
	bne.w	.No_ID
	move.l	Module_Sp,d0
	beq.w	.Zero
	move.l	d0,a0
	moveq.l	#0,d0
	move.b	Module_ID(a0),d0
	bra.w	.Exit
.No_ID:	cmp.w	#4,d0			; Module stack depth ?
	bne.w	.No_depth
	move.l	Module_Sp,d0
	beq.w	.Exit
	sub.l	#ModStack_start,d0
	divu.w	#Module_data_size,d0
	bra.w	.Exit
.No_depth:	cmp.w	#Script_nr_vars,d0		; Simple variable ?
	bhs.w	.Zero
	add.w	d0,d0
	add.w	d0,d0
	lea.l	Script_var_table,a0
	move.l	0(a0,d0.w),a0
	cmp.l	#0,a0
	beq.w	.Zero
	move.w	(a0),d0
	bra.w	.Exit
.Zero:	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Scripted mouse for [ Update_mouse ] ]
;   IN : d0 - Mouse X (.w)
;        d1 - Mouse Y (.w)
;  OUT : d0 - Mouse X (.w)
;        d1 - Mouse Y (.w)
;        eq - Not scripted
;        ne - Scripted
; All other registers are restored
;*****************************************************************************
Script_mouse_position:
	tst.b	Script_mouse
	beq.w	.Exit
	move.w	Script_X,d0
	move.w	Script_Y,d1
	tst.b	Script_mouse		; ne
.Exit:	rts

; The address of the word of each simple variable (0 = not one)
Script_var_table:
	dc.l	Map_nr,Map_Xcoord,Map_Ycoord,0
	dc.l	0,VBL_counter,Mouse_X,Mouse_Y
	dc.l	Travel_mode,Current_map_type,Nr_members,Active_member
	dc.l	Mapbuf_X,Mapbuf_Y,View_direction,Y_angle
Script_nr_vars	EQU	(*-Script_var_table)/4

Script_filename:
	dc.b	"Amberfiles/Script.bin",0
Script_log_filename:
	dc.b	"Amberfiles/Script.log",0
Script_save_name:
	dc.b	"SCRIPT"
	dcb.b	Save_name_length+1-6,0
	even


	SECTION	Fast_BSS,bss
Script_pc:	ds.l	1
Script_wait:	ds.w	1
Script_X:	ds.w	1
Script_Y:	ds.w	1
Script_buttons:	ds.w	1
Script_regs:	ds.w	8
Script_turn_wait:	ds.w	1
Script_running:	ds.b	1
Script_mouse:	ds.b	1
Script_log_length:	ds.l	1
Script_log_time:	ds.w	1
Script_log_dirty:	ds.b	1
Script_save_done:	ds.b	1
	even
Script_save_slot:	ds.w	1
Script_last_sp:	ds.l	1
Script_last_mev:	ds.l	1
Script_sp_time:	ds.w	1
Script_sp:	ds.w	1
Script_seed_lock:	ds.l	1
Script_stack:	ds.l	8
	even
Script_buffer:	ds.b	Script_max_size
Script_log:	ds.b	Script_log_size
