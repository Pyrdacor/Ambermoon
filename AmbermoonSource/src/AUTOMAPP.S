; Automapper
; Written by J.Horneman (In Tune With The Universe)
; Start : 31-9-1992
;
; *** Merged with Ambermoon 1.21 (based on the disassembly of AM2_CPU) ***
;   - Bugfixes are marked with "FIX:" comments.
;   - Texts and the item data are no longer part of the executable, they are
;     loaded from files. They are accessed via pointers ("..._ptr", see
;     KERNEL/TEXTS.S) instead of "lea.l <text>,an".
;

	SECTION	Program,code
;*****************************************************************************
; [ Automap screen ]
;*****************************************************************************
Automap_ModInit:
; ---------- Initialize variables -----------------
	clr.w	Icon_update		; !
	clr.w	Automap_X			; Clear coordinates
	clr.w	Automap_Y
	move.w	#96,Mouse_X		; Centre mouse
	move.w	#37+81,Mouse_Y
	move.w	#-1,Current_ghost_index	; Clear
	move.w	Width_of_map,d0		; Get width
	addq.w	#1,d0 			; Make even
	andi.w	#$fffe,d0
	move.w	d0,Width_of_automap		; Store
	cmp.w	#Automap_window_width-6,d0	; Scroll horizontally ?
	sgt	Automap_scroll_X
	bls.s	.Ok_X
	move.w	Map_Xcoord,d2		; Yes -> Centre horizontally
	subi.w	#Automap_window_width/2,d2
	bls.s	.Ok_X			; Out of bounds ?
	move.w	d2,d3
	addi.w	#Automap_window_width-1,d3
	cmp.w	d0,d3
	bmi.s	.Ok1
	move.w	d0,d2			; Yes -> Clip
	subi.w	#Automap_window_width-4,d2	
.Ok1:	andi.w	#$fffe,d2			; Make even
	move.w	d2,Automap_X		; Store
.Ok_X:	move.w	Height_of_map,d1		; Get height
	addq.w	#1,d1			; Make even
	andi.w	#$fffe,d1
	move.w	d1,Height_of_automap	; Store
	cmp.w	#Automap_window_height-6,d1	; Scroll vertically ?
	sgt	Automap_scroll_Y
	bls.s	.Ok_Y
	move.w	Map_Ycoord,d2		; Yes -> Centre vertically
	subi.w	#Automap_window_height/2,d2
	bmi.s	.Ok_Y			; Out of bounds ?
	move.w	d2,d3
	addi.w	#Automap_window_height-1,d3
	cmp.w	d1,d3
	bls.s	.Ok2
	move.w	d1,d2			; Yes -> Clip
	subi.w	#Automap_window_height-5,d2	
.Ok2:	move.w	d2,Automap_Y		; Store
.Ok_Y:	mulu.w	d1,d0			; Make & clear buffers
	move.w	d0,d1
	lsl.l	#3,d0
	jsr	Allocate_CHIP
	move.b	d0,Automap_floor_handle
	jsr	Clear_memory
	moveq.l	#0,d0
	move.w	d1,d0
	jsr	Allocate_memory
	move.b	d0,Automap_buffer_handle
	jsr	Clear_memory
	moveq.l	#Automap_gfx_file,d0	; Load automap graphics
	jsr	Load_file
	move.b	d0,Automap_gfx_handle
	LOCAL
; ---------- Prepare automap (MAP) ----------------
	Get	Mapdata_handle,a0
	move.l	a0,a1
	lea.l	Map_data(a0),a0
	add.l	Event_automap_offset,a1
	Get	Labdata_handle,a5
	moveq.l	#1,d1
	move.l	#Automap_hidden_mask,d4
.Loop_Y:	move.l	a0,a2
	moveq.l	#1,d0
.Loop_X:	jsr	Get_automap_bit		; Explored ?
	beq	.Next_X
	moveq.l	#0,d2			; Yes -> Get map byte
	move.b	(a2),d2
	beq.s	.Done			; Empty ?
	cmp.b	#-1,d2			; Dummy wall ?
	beq.s	.Done
	cmp.w	#First_wall,d2		; Wall or object ?
	bmi	.Object
	subi.w	#First_wall,d2		; Wall !
	lea.l	Wall_data_offsets,a3	; Get wall data address
	lsl.w	#2,d2
	move.l	0(a3,d2.w),a3
	adda.l	a5,a3
	moveq.l	#0,d2			; Get automapper icon
	move.b	Wall_automapper_icon(a3),d2
	bra.s	.Do1
.Object:	cmp.w	Nr_of_groups,d2		; Legal ?
	bgt.s	.Done
	subq.w	#1,d2			; Get automapper icon
	mulu.w	#Objectgroup3D_data_size,d2
	move.w	Lab_data+2+Object_automapper_icon(a5,d2.w),d2
.Do1:	jsr	Insert_automap_icon		; Insert
.Done:	moveq.l	#0,d3			; Get event byte
	move.b	1(a2),d3
	beq.s	.Next_X			; Empty ?
	movem.l	d0/d1,-(sp)
	move.w	Map_nr,d0			; Calculate bit number
	subq.w	#1,d0
	mulu.w	#Events_per_map,d0
	add.w	d3,d0
	subq.w	#1,d0
	moveq.l	#Event_bit_array,d1		; Get bit
	moveq.l	#3,d2
	jsr	Access_bit_array
	sne	d2
	movem.l	(sp)+,d0/d1
	tst.b	d2			; Has event been saved ?
	bne.s	.Next_X
	moveq.l	#0,d2			; Get automapper icon
	move.b	-1(a1,d3.w),d2
	beq.s	.Next_X			; Any ?
	btst	d2,d4			; Yes -> Hidden ?
	beq.s	.Not_hidden1
	btst	#Show_traps_function,Automap_function	; Yes -> Show ?
	beq.s	.Next_X
	bra.s	.Show1
.Not_hidden1:
	jsr	Check_automap_door		; Check doors & chests
	jsr	Check_automap_chest
.Show1:	jsr	Insert_automap_icon		; Insert
.Next_X:	addq.l	#2,a2			; Next X
	addq.w	#1,d0
	cmp.w	Width_of_map,d0
	ble	.Loop_X
	add.w	Width_of_map,a0		; Next Y
	add.w	Width_of_map,a0
	addq.w	#1,d1
	cmp.w	Height_of_map,d1
	ble	.Loop_Y
	Free	Labdata_handle
	Free	Mapdata_handle
	LOCAL
; ---------- Prepare automap (NPC's) --------------
	lea.l	VNPC_data,a0		; Check all NPC's
	move.l	CD_value,d6
	moveq.l	#0,d7
.Loop:	tst.b	NPC_char_nr(a0)		; Anyone there ?
	beq	.Next
	btst	d7,d6			; Removed ?
	bne	.Next
	move.w	VMap_X(a0),d0		; Get coordinates
	move.w	VMap_Y(a0),d1
	moveq.l	#0,d3			; Get NPC event
	move.b	NPC_event_nr(a0),d3
	beq.s	.No			; Any ?
	tst.b	-1(a1,d3.w)		; Yes -> Automapper icon ?
	beq	.No
	movem.l	d0/d1,-(sp)		; Yes
	move.w	Map_nr,d0			; Calculate bit number
	subq.w	#1,d0
	mulu.w	#Events_per_map,d0
	add.w	d3,d0
	subq.w	#1,d0
	moveq.l	#Event_bit_array,d1		; Get bit
	moveq.l	#3,d2
	jsr	Access_bit_array
	sne	d2
	movem.l	(sp)+,d0/d1
	tst.b	d2			; Has event been saved ?
	bne.s	.Next
	moveq.l	#0,d2			; Yes -> Get automapper icon
	move.b	-1(a1,d3.w),d2
	move.w	VMap_X(a0),d0		; Yes -> Been there ?
	move.w	VMap_Y(a0),d1
	jsr	Get_automap_bit
	beq	.Next
	btst	d2,d4			; Yes -> Hidden ?
	beq.s	.Not_hidden2
	btst	#Show_traps_function,Automap_function	; Yes -> Show ?
	beq.s	.Next
	bra.s	.Show2
.Not_hidden2:
	jsr	Check_automap_door		; Check doors & chests
	jsr	Check_automap_chest
.Show2:	jsr	Insert_automap_icon		; Insert
	bra	.Next
.No:	move.b	NPC_status_bits(a0),d2	; What kind of NPC ?
	andi.w	#$0003,d2
	cmp.w	#Monster_type,d2		; Party or NPC ?
	bpl.s	.Monster
	btst	#Show_NPCs_function,Automap_function	; Show ?
	beq.s	.Next
	moveq.l	#Person_auto_icon,d2	; Insert person
	bra.s	.Do2
.Monster:	bne.s	.Next			; Monster or object ?
	btst	#Show_monsters_function,Automap_function	; Show ?
	beq.s	.Next
	moveq.l	#Monster_auto_icon,d2	; Insert monster
.Do2:	jsr	Insert_automap_icon
.Next:	lea.l	VNPC_data_size(a0),a0	; Next NPC
	addq.w	#1,d7
	cmp.w	#Max_chars,d7
	bmi	.Loop
	LOCAL
; ---------- Prepare automap (Goto-points) --------
	move.w	Nr_goto_points,d7		; Any ?
	beq	.Skip
	Get	Mapdata_handle,a0		; Search Goto-points
	add.l	Goto_point_offset,a0
	bra.s	.Entry
.Loop:	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq.s	.Known
	moveq.l	#0,d0			; Known ?
	move.b	Goto_bit_nr(a0),d0
	moveq.l	#Goto_point_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	beq.s	.Next			; No -> Exit
.Known:	moveq.l	#0,d0			; Yes -> Insert
	move.b	Goto_X(a0),d0
	moveq.l	#0,d1
	move.b	Goto_Y(a0),d1
	moveq.l	#Goto_auto_icon,d2
	jsr	Insert_automap_icon
.Next:	lea.l	Goto_pnt_data_size(a0),a0	; Next Goto-point
.Entry:	dbra	d7,.Loop
.Done:	Free	Mapdata_handle		; No luck
.Skip:	clr.w	Automap_page_nr		; Reset variables
	clr.w	Automap_pageflip_timer
	jmp	Automap_DisInit		; Build screen

Automap_ModExit:
	move.b	Automap_gfx_handle,d0	; Free memory
	jsr	Free_memory
	move.b	Automap_floor_handle,d0
	jsr	Free_memory
	move.b	Automap_buffer_handle,d0
	jsr	Free_memory
	jsr	Destroy_ghosts		; Kill !
	jmp	Fade_out_bottom		; Fade out

Automap_DisInit:
	moveq.l	#Automap_layout,d0		; Show new layout
	jsr	Show_layout
	jsr	Display_automap		; Display automap
	jsr	Display_automap_legend	; Display legend
	jmp	Fade_in_bottom		; Fade in

Automap_DisUpd:
	jsr	Display_automap		; Display automap
	jsr	Update_animation
	cmp.w	#Automap_pageflip_interval,Automap_pageflip_timer
	bmi.s	.Skip
	clr.w	Automap_pageflip_timer	; Reset time
	move.w	Automap_page_nr,d0		; Next page
	addq.w	#4,d0
	lea.l	Legend_page_list,a0		; Last ?
	tst.l	0(a0,d0.w)
	bne.s	.No
	moveq.l	#0,d0			; Yes -> Back to first
.No:	move.w	d0,Automap_page_nr		; Store
	jsr	Display_automap_legend	; Re-draw legend
	jsr	Update_screen
.Skip:	jmp	Basic_DisUpd		; The usual

Time_legend_pageflip:
	addq.w	#1,Automap_pageflip_timer	; Count
	rts

; ********** Goto-point selected ******************
Goto_point_selected:
	jsr	Find_Goto_point		; Search for Goto-point
	jsr	Wait_4_unclick
	tst.w	d0			; Any ?
	bpl.s	.Yes
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	bne	.Exit
	move.w	Mouse_X,d0		; Calculate coordinates
	move.w	Mouse_Y,d1
	subi.w	#Automap_window_X+32,d0
	subi.w	#Automap_window_Y+32,d1
	asr.w	#3,d0
	asr.w	#3,d1
	add.w	Automap_X,d0
	add.w	Automap_Y,d1
	addq.w	#1,d0
	addq.w	#1,d1
	tst.w	d0			; Out of bounds ?
	bls	.Exit
	cmp.w	Width_of_map,d0
	bgt	.Exit
	tst.w	d1
	bls	.Exit
	cmp.w	Height_of_map,d1
	bgt	.Exit
	move.w	d0,Map_Xcoord		; No -> Jump
	move.w	d1,Map_Ycoord
	jsr	Jumped			; Update
	bra	.Leave
.Yes:	jsr	Destroy_ghosts		; Kill !
	move.w	d0,d7			; Save
	tst.b	Stygian			; Dark ?
	beq.s	.No1
	moveq.l	#51,d0			; Yes -> "Fool!"
	jsr	Do_prompt_window
	bra	.Exit
.No1:	tst.b	Big_brother_flag		; Being watched ?
	beq.s	.No2
	move.w	#137,d0			; Yes -> "Fool!"
	jsr	Do_prompt_window
	bra	.Exit
.No2:	move.w	#141,d0			; Are you sure ?
	jsr	Prompt_req
	tst.b	d0			; Yes ?
	beq	.Exit
	Get	Mapdata_handle,a0		; Find data
	add.l	Goto_point_offset,a0
	mulu.w	#Goto_pnt_data_size,d7
	add.l	d7,a0
	moveq.l	#0,d0			; Get coordinates
	move.b	Goto_X(a0),d0
	moveq.l	#0,d1
	move.b	Goto_Y(a0),d1
	moveq.l	#0,d2			; & view direction
	move.b	Goto_viewdir(a0),d2
	Free	Mapdata_handle
	move.w	Map_Xcoord,d3		; Get old coordinates
	move.w	Map_Ycoord,d4
	move.w	d0,Map_Xcoord		; Set new
	move.w	d1,Map_Ycoord
	move.w	d2,View_direction		; & view direction
	jsr	Jumped			; Update
	sub.w	d0,d3			; Calculate dX & dY
	bpl.s	.Ok1
	neg.w	d3
.Ok1:	sub.w	d1,d4
	bpl.s	.Ok2
	neg.w	d4
.Ok2:	add.w	d4,d3			; Calculate total length
	bne.s	.Notzero
	move.w	#143,d0			; "Fool!"
	jsr	Do_prompt_window
	bra	.Exit
.Notzero:	ext.l	d3			; Calculate time
	divu.w	#Moves_per_step,d3
	bra.s	.Entry			; Time passes...
.Loop:	jsr	Update_time
.Entry:	dbra	d3,.Loop
.Leave:	Pop	Module			; Leave
	jsr	Init_display
.Exit:	rts

; ********** Goto-point touched *******************
Goto_point_touched:
	jsr	Find_Goto_point		; Search for Goto-point
	tst.w	d0			; Any ?
	bpl.s	.Yes
	jsr	Destroy_ghosts		; No
	bra	.Exit
.Yes:	cmp.w	Current_ghost_index,d0	; Already being shown ?
	bne.s	.New
	jsr	Set_ghost_positions		; Yes -> Update positions
	bra	.Exit
.New:	jsr	Destroy_ghosts		; Destroy previous
	move.w	d0,Current_ghost_index	; Store new
	Get	Mapdata_handle,a0		; Find data
	add.l	Goto_point_offset,a0
	mulu.w	#Goto_pnt_data_size,d0
	add.l	d0,a0
	move.w	#23,Ink_colour		; Set ink colour
	addq.w	#Goto_text,a0		; Create ghost string
	jsr	Create_1st_ghost
.Exit:	rts

; ********** Move automap by key ******************
Automap_up:
	moveq.l	#1,d0			; Fake
	bra	Move_automap

Automap_right:
	moveq.l	#3,d0			; Fake
	bra	Move_automap

Automap_down:
	moveq.l	#5,d0			; Fake
	bra	Move_automap

Automap_left:
	moveq.l	#7,d0			; Fake
	bra	Move_automap

; ********** Move automap *************************
Move_automap:
	tst.b	d0			; In bump area ?
	beq	.Exit
	andi.w	#$000f,d0			; Get bump area number
	subq.w	#1,d0
	move.w	d0,d1
	andi.w	#$0006,d1			; Execute first movement
	add.w	d1,d1
	move.l	.Ptrs(pc,d1.w),a0
	jsr	(a0)
	btst	#0,d0			; Diagonal ?
	beq.s	.Exit
	move.l	.Ptrs+4(pc,d1.w),a0		; Yes -> Execute second
	jsr	(a0)
.Exit:	jmp	Destroy_ghosts		; Kill !

.Ptrs:	dc.l .Up
	dc.l .Right
	dc.l .Down
	dc.l .Left
	dc.l .Up

; [ Automap movement routines ]
; All registers are restored

.Up:	tst.b	Automap_scroll_Y		; Scroll vertically ?
	beq.s	.Exit1
	tst.w	Automap_Y			; Top ?
	beq.s	.Exit1
	subq.w	#1,Automap_Y		; Move up
.Exit1:	rts

.Right:	move.l	d0,-(sp)
	tst.b	Automap_scroll_X		; Scroll horizontally ?
	beq.s	.Exit2
	move.w	Width_of_automap,d0		; Right ?
	subi.w	#Automap_window_width-6+1,d0
	cmp.w	Automap_X,d0
	bls.s	.Exit2
	addq.w	#2,Automap_X		; Move right
.Exit2:	move.l	(sp)+,d0
	rts

.Down:	move.l	d0,-(sp)
	tst.b	Automap_scroll_Y		; Scroll vertically ?
	beq.s	.Exit3
	move.w	Height_of_automap,d0	; Down ?
	subi.w	#Automap_window_height-6+1,d0
	cmp.w	Automap_Y,d0
	bls.s	.Exit3
	addq.w	#1,Automap_Y		; Move down
.Exit3:	move.l	(sp)+,d0
	rts

.Left:	tst.b	Automap_scroll_X		; Scroll horizontally ?
	beq.s	.Exit4
	tst.w	Automap_X			; Left ?
	beq.s	.Exit4
	subq.w	#2,Automap_X		; Move left
.Exit4:	rts

; ********** Quit automap *************************
Quit_automap:
	jsr	Wait_4_unclick		; Wait
	Pop	Module			; Leave
	jmp	Init_display

;*****************************************************************************
; [ Find goto-point ]
;  OUT : d0 - Goto-point number / -1 - No Goto-point (.w)
; Changed registers : d0
;*****************************************************************************
Find_Goto_point:
	movem.l	d1/d2/d4-d7/a0,-(sp)
	move.w	Nr_goto_points,d7		; Any ?
	beq	.No_luck
	move.w	Mouse_X,d4		; Calculate coordinates
	move.w	Mouse_Y,d5
	subi.w	#Automap_window_X+32,d4
	subi.w	#Automap_window_Y+32,d5
	asr.w	#3,d4
	asr.w	#3,d5
	add.w	Automap_X,d4
	add.w	Automap_Y,d5
	addq.w	#1,d4
	addq.w	#1,d5
	tst.w	d4			; Out of bounds ?
	bls	.No_luck
	cmp.w	Width_of_map,d4
	bgt	.No_luck
	tst.w	d5
	bls	.No_luck
	cmp.w	Height_of_map,d5
	bgt	.No_luck
	Get	Mapdata_handle,a0		; Search Goto-points
	add.l	Goto_point_offset,a0
	moveq.l	#0,d6
	bra.s	.Entry
.Loop:	cmp.b	Goto_X(a0),d4		; Correct coordinates ?
	bne.s	.Next
	cmp.b	Goto_Y(a0),d5
	bne.s	.Next
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	beq.s	.Known
	moveq.l	#0,d0			; Known ?
	move.b	Goto_bit_nr(a0),d0
	moveq.l	#Goto_point_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	beq.s	.Unknown			; No -> Exit
.Known:	Free	Mapdata_handle		; Yes
	bra.s	.Exit
.Next:	lea.l	Goto_pnt_data_size(a0),a0	; Next Goto-point
	addq.w	#1,d6
.Entry:	dbra	d7,.Loop
.Unknown:	Free	Mapdata_handle		; No luck
.No_luck:	moveq.l	#-1,d6
.Exit:	move.w	d6,d0			; Output
	movem.l	(sp)+,d1/d2/d4-d7/a0
	rts

;*****************************************************************************
; [ Check automap door ]
;   IN : d2 - Automap icon number (.w)
;        d3 - Event entry number (.w)
;  OUT : d2 - New automap icon number (.w)
; Changed registers : d2
; Notes :
;   - This routine has been designed to work in MOST cases.
;*****************************************************************************
Check_automap_door:
	cmp.w	#Closed_door_auto_icon,d2	; Door ?
	bne	.Exit2
	movem.l	d0/d1/d3/a0/a1,-(sp)
	Get	Mapdata_handle,a0		; Get first event number
	andi.w	#$00ff,d3
	add.w	d3,d3
	ext.l	d3
	add.l	Event_entry_offset,d3
	move.w	-2(a0,d3.l),d3
	add.l	Event_data_offset,a0	; Search through chain
.Again:	mulu.w	#Event_data_size,d3		; Find event data
	lea.l	0(a0,d3.l),a1
	cmp.b	#Door_type,(a1)		; Is door ?
	beq.s	.Yes
	move.w	Next_event_nr(a1),d3	; No -> Next event
	cmp.w	#-1,d3
	bne.s	.Again
	bra	.Exit
.Yes:	moveq.l	#0,d0			; Already open ?
	move.b	Event_b2(a1),d0
	moveq.l	#Door_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	bne.s	.Open
	moveq.l	#Closed_door_auto_icon,d2	; Reset
	bra.s	.Exit
.Open:	moveq.l	#Open_door_auto_icon,d2	; OPEN !!!
.Exit:	Free	Mapdata_handle
	movem.l	(sp)+,d0/d1/d3/a0/a1
.Exit2:	rts

;*****************************************************************************
; [ Check automap chest ]
;   IN : d2 - Automap icon number (.w)
;        d3 - Event entry number (.w)
;  OUT : d2 - New automap icon number (.w)
; Changed registers : d2
; Notes :
;   - This routine has been designed to work in MOST cases.
;*****************************************************************************
Check_automap_chest:
	cmp.w	#Closed_chest_auto_icon,d2	; Chest ?
	bne	.Exit2
	movem.l	d0/d1/d3/a0/a1,-(sp)
	Get	Mapdata_handle,a0		; Get first event number
	andi.w	#$00ff,d3
	add.w	d3,d3
	ext.l	d3
	add.l	Event_entry_offset,d3
	move.w	-2(a0,d3.l),d3
	add.l	Event_data_offset,a0	; Search through chain
.Again:	mulu.w	#Event_data_size,d3		; Find event data
	lea.l	0(a0,d3.l),a1
	cmp.b	#Item_found_type,(a1)	; Is chest ?
	beq.s	.Yes
	move.w	Next_event_nr(a1),d3	; No -> Next event
	cmp.w	#-1,d3
	bne.s	.Again
	bra	.Exit
; ---------- Is the chest hidden ? ----------------
.Yes:	tst.b	Event_b2(a1)		; Is it ?
	beq.s	.Not
	tst.b	Clairvoyant		; Clairvoyant ?
	bne.s	.Not
	Get	Active_handle,a0		; Probe {Searching}
	move.w	SSearch(a0),d0
	add.w	SSearch+Magic(a0),d0
	Free	Active_handle
	jsr	Probe_100
	bpl.s	.Not
	moveq.l	#0,d2			; Invisible
	bra	.Exit
; ---------- Is the chest already open ? ----------
.Not:	moveq.l	#0,d0			; Well ?
	move.b	Event_b4(a1),d0
	moveq.l	#Chest_bit_array,d1
	moveq.l	#3,d2
	jsr	Access_bit_array
	bne.s	.Open
	tst.b	Event_b1(a1)		; 0 % locked ?
	beq.s	.Open
	moveq.l	#Closed_chest_auto_icon,d2	; Reset
	bra.s	.Exit
.Open:	moveq.l	#Open_chest_auto_icon,d2	; OPEN !!!
.Exit:	Free	Mapdata_handle
	movem.l	(sp)+,d0/d1/d3/a0/a1
.Exit2:	rts

;*****************************************************************************
; [ Display automap ]
; All registers are restored
;*****************************************************************************
Display_automap:
	movem.l	d0-d7/a0-a2,-(sp)
	Push	CA,Automap_CA
	move.w	Automap_X,d2		; Get coordinates
	move.w	Automap_Y,d3
	lsl.w	#3,d2
	lsl.w	#3,d3
	neg.w	d2
	neg.w	d3
	addi.w	#Automap_window_X+32,d2
	addi.w	#Automap_window_Y+32,d3
	Get	Automap_gfx_handle,a1
	moveq.l	#0,d4			; Display border
	moveq.l	#3,d5
; ---------- Display corners ----------------------
	moveq.l	#2,d6
	moveq.l	#32,d7
	move.w	d2,d0			; Top-left
	move.w	d3,d1
	subi.w	#32,d0
	subi.w	#32,d1
	lea.l	AM_TL_corner_offset(a1),a0
	jsr	Put_unmasked_block
	move.w	Height_of_automap,d1	; Bottom-left
	lsl.w	#3,d1
	add.w	d3,d1
	lea.l	AM_BL_corner_offset(a1),a0
	jsr	Put_unmasked_block
	move.w	Width_of_automap,d0		; Bottom-right
	lsl.w	#3,d0
	add.w	d2,d0
	lea.l	AM_BR_corner_offset(a1),a0
	jsr	Put_unmasked_block
	move.w	d3,d1			; Top-right
	subi.w	#32,d1
	lea.l	AM_TR_corner_offset(a1),a0
	jsr	Put_unmasked_block
; ---------- Display edges ------------------------
	moveq.l	#1,d6			; Top edge
	lea.l	AM_top_edge_offset(a1),a0
	move.w	d2,d0
	clr.w	Automap_work_X
	move.l	d2,-(sp)
	move.w	Width_of_automap,d2
	lsr.w	#1,d2
	bra.s	.Entry1
.Loop1:	jsr	Display_automap_edge
	addq.w	#1,Automap_work_X
	addi.w	#16,d0
.Entry1:	dbra	d2,.Loop1
	move.l	(sp)+,d2
	lea.l	AM_bottom_edge_offset(a1),a0	; Bottom edge
	move.w	d2,d0
	move.w	Height_of_automap,d1
	lsl.w	#3,d1
	add.w	d3,d1
	clr.w	Automap_work_X
	move.l	d2,-(sp)
	move.w	Width_of_automap,d2
	lsr.w	#1,d2
	bra.s	.Entry2
.Loop2:	jsr	Display_automap_edge
	addq.w	#1,Automap_work_X
	addi.w	#16,d0
.Entry2:	dbra	d2,.Loop2
	move.l	(sp)+,d2
	moveq.l	#2,d6			; Left edge
	moveq.l	#16,d7
	lea.l	AM_left_edge_offset(a1),a0
	move.w	d2,d0
	subi.w	#32,d0
	move.w	d3,d1
	clr.w	Automap_work_X
	move.l	d2,-(sp)
	move.w	Height_of_automap,d2
	lsr.w	#1,d2
	bra.s	.Entry3
.Loop3:	jsr	Display_automap_edge
	addq.w	#1,Automap_work_X
	addi.w	#16,d1
.Entry3:	dbra	d2,.Loop3
	move.l	(sp)+,d2
	lea.l	AM_right_edge_offset(a1),a0	; Right edge
	move.w	Width_of_automap,d0
	lsl.w	#3,d0
	add.w	d2,d0
	move.w	d3,d1
	clr.w	Automap_work_X
	move.l	d2,-(sp)
	move.w	Height_of_automap,d2
	lsr.w	#1,d2
	bra.s	.Entry4
.Loop4:	jsr	Display_automap_edge
	addq.w	#1,Automap_work_X
	addi.w	#16,d1
.Entry4:	dbra	d2,.Loop4
	move.l	(sp)+,d2
; --------- Display automap floor -----------------
	move.w	d2,d0			; Get data
	move.w	d3,d1
	move.w	Width_of_automap,d6
	move.w	Height_of_automap,d7
	moveq.l	#Automap_paper_colour,d4
	movem.l	d2/d3,-(sp)		; Erase floor
	move.w	d6,d2
	lsl.w	#3,d2
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d7,d3
	lsl.w	#3,d3
	add.w	d1,d3
	subq.w	#1,d3
	jsr	Draw_box
	movem.l	(sp)+,d2/d3
	moveq.l	#Automap_ink_colour,d4	; Display floor
	moveq.l	#1,d5
	lsr.w	#1,d6
	lsl.w	#3,d7
	Get	Automap_floor_handle,a0
	jsr	Put_masked_silhouette
	Free	Automap_floor_handle
; --------- Display map name ----------------------
	move.l	d2,-(sp)
	move.w	#23,Ink_colour		; Set ink
	Get	Maptext_handle,a0		; Get map name
	moveq.l	#0,d0
	jsr	Find_large_text
	Free	Maptext_handle
	move.w	d2,d0			; Print
	move.w	d3,d1
	move.w	Width_of_automap,d2
	addq.w	#2,d2
	lsl.w	#3,d2
	jsr	Print_centered_string
	move.l	(sp)+,d2
; ---------- Display automap icons ----------------
	Get	Automap_buffer_handle,a2	; Get data
	move.w	d3,d1
	subq.w	#8,d1
	moveq.l	#Screen_depth,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
	move.w	#1,Automap_work_Y		; Reset
	move.w	Height_of_automap,d4
	subq.w	#1,d4
.Loop5:	move.l	d4,-(sp)
	move.w	d2,d0
	move.w	#1,Automap_work_X
	move.w	Width_of_automap,d4
	subq.w	#1,d4
.Loop6:	moveq.l	#0,d3			; Get icon number
	move.b	(a2)+,d3
	beq.s	.Nothing			; Any ?
	jsr	Display_automap_icon	; Yes -> Display
.Nothing:	move.w	Automap_work_X,d3		; On player's position ?
	cmp.w	Map_Xcoord,d3
	bne.s	.Next6
	move.w	Automap_work_Y,d3
	cmp.w	Map_Ycoord,d3
	bne.s	.Next6
	lea.l	AM_YAH_base_offset(a1),a0	; Display YAH base
	jsr	Put_masked_block
 	subi.w	#16,d1
	move.w	Special_item_flags,d3	; Compass ?
	btst	#Compass_bit,d3
	bne.s	.Yes
	lea.l	AM_YAH_top_offset(a1),a0	; No -> Display YAH top
	jsr	Put_masked_block
	bra.s	.Go_on
.Yes:	move.w	Y_angle,d3		; Determine direction
	neg.w	d3
	addi.w	#slang/16,d3
	andi.w	#slang-1,d3
	ext.l	d3
	divu.w	#slang/8,d3
.Do:	lea.l	AM_YAH_arrows_offset(a1),a0	; Get graphics address
	mulu.w	#AM_icon_size,d3
	add.l	d3,a0
	jsr	Put_masked_block		; Display YAH arrow
.Go_on:	addi.w	#16,d1
.Next6:	addq.w	#8,d0			; Next X
	addq.w	#1,Automap_work_X
	dbra	d4,.Loop6
	addq.w	#8,d1			; Next Y
	addq.w	#1,Automap_work_Y
	move.l	(sp)+,d4
	dbra	d4,.Loop5
	Free	Automap_gfx_handle		; Exit
	Free	Automap_buffer_handle
	Pop	CA
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Display automap icon ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d3 - Automap icon number [1...] (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a1 - Pointer to automap graphics (.l)
; All registers are restored
;*****************************************************************************
Display_automap_icon:
	movem.l	d2/d3/a0,-(sp)
	lea.l	Automap_icon_table-2,a0	; Get automap icon info
	add.w	d3,d3
	add.w	d3,a0
	moveq.l	#0,d3			; Get first frame + wave flag
	move.b	(a0)+,d3
	moveq.l	#0,d2			; Get number of frames
	move.b	(a0)+,d2
	cmp.w	#1,d2			; Any animation ?
	beq.s	.No_anim
	lea.l	Circle_anim-4,a0		; Circle or wave ?
	bclr	#7,d3
	beq.s	.Circle
	lea.l	Wave_anim-4,a0		; Wave
.Circle:	lsl.w	#2,d2			; Get current frame
	add.b	0(a0,d2.w),d3
.No_anim:	lea.l	AM_icons_offset(a1),a0	; Calculate frame address
	mulu.w	#AM_icon_size,d3
	add.l	d3,a0
	jsr	Put_masked_block		; Display
.Exit:	movem.l	(sp)+,d2/d3/a0
	rts

;*****************************************************************************
; [ Display automap edge ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Base colour (.w)
;        d5 - Number of planes (.w)
;        d6 - Width in truncs (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to graphics (.l)
; All registers are restored
;*****************************************************************************
Display_automap_edge:
	movem.l	d3/a0,-(sp)
	move.w	Automap_work_X,d3		; Choose frame
	andi.w	#$0003,d3
	mulu.w	#AM_edge_size,d3
	add.l	d3,a0
	jsr	Put_unmasked_block		; Display
	movem.l	(sp)+,d3/a0
	rts

;*****************************************************************************
; [ Display automap legend ]
; All registers are restored
;*****************************************************************************
Display_automap_legend:
	movem.l	d0-d7/a0/a5,-(sp)
	Get	Automap_gfx_handle,a1
; ---------- Display top --------------------------
	move.w	#216,d0			; Pretty box
	move.w	#45,d1
	move.w	#88,d2
	move.w	#10,d3
	jsr	Draw_standard_box2
	move.l	Legend_txt_ptr,a0		; Print "LEGEND"
	addq.w	#1,d0
	addq.w	#2,d1
	subq.w	#2,d2
	jsr	Print_centered_string
; ---------- Display legend -----------------------
	move.w	#216,d0			; Pretty box
	move.w	#55,d1
	move.w	#88,d2
	move.w	#110,d3
	jsr	Draw_standard_box2
	lea.l	Legend_page_list,a0		; Get current page descriptor
	add.w	Automap_page_nr,a0
	move.l	(a0),a0
	jsr	Display_legend_page
; ---------- Display bottom -----------------------
	move.w	#216,d0			; Pretty box
	move.w	#188-24+1,d1
	move.w	#88,d2
	move.w	#24,d3
	jsr	Draw_standard_box2
	move.w	Special_item_flags,d0	; Locator ?
	btst	#Coords_bit,d0
	beq	.No
	move.l	YAH_text_ptr,a0		; Print "You Are Here"
	move.w	#219,d0
	move.w	#188-23+4,d1
	jsr	Put_text_line
	lea.l	X_string+2,a0		; Convert X
	move.w	Map_Xcoord,d0
	moveq.l	#2,d7
	jsr	DecL_convert
	lea.l	X_string,a0		; Print X
	move.w	#219,d0
	move.w	#178,d1
	jsr	Put_text_line
	lea.l	Y_string+2,a0		; Convert Y
	move.w	Map_Ycoord,d0
	jsr	DecL_convert
	lea.l	Y_string,a0		; Print Y
	move.w	#219+30,d0
	jsr	Put_text_line
.No:	moveq.l	#5,d5			; Display YAH-symbol
	moveq.l	#1,d6
	moveq.l	#16,d7
	move.w	#303-16,d0		; Base
	move.w	#188-16,d1
	lea.l	AM_YAH_base_offset(a1),a0
	jsr	Put_masked_block
 	subi.w	#16,d1
	move.w	Special_item_flags,d2	; Compass ?
	btst	#Compass_bit,d2
	bne.s	.Yes
	lea.l	AM_YAH_top_offset(a1),a0	; No -> Display YAH top
	jsr	Put_masked_block
	bra.s	.Go_on
.Yes:	move.w	Y_angle,d2		; Determine direction
	neg.w	d2
	addi.w	#slang/16,d2
	andi.w	#slang-1,d2
	ext.l	d2
	divu.w	#slang/8,d2
.Do:	lea.l	AM_YAH_arrows_offset(a1),a0	; Get graphics address
	mulu.w	#AM_icon_size,d2
	add.l	d2,a0
	jsr	Put_masked_block		; Display YAH arrow
.Go_on:	Free	Automap_gfx_handle
	movem.l	(sp)+,d0-d7/a0/a5
	rts

;*****************************************************************************
; [ Display automap legend page ]
;   IN : a0 - Pointer to legend page descriptor (.l)
; All registers are restored
;*****************************************************************************
Display_legend_page:
	movem.l	d0-d7/a0-a4,-(sp)
	Get	Automap_gfx_handle,a1
	lea.l	AM_icons_offset(a1),a1
	move.l	Automap_icon_names_ptr,a2
	move.l	a0,a3
	lea.l	Automap_icon_table,a4
	move.w	#51,d1
	move.w	#219,d2
	move.l	#Automap_hidden_mask,d4
	moveq.l	#5,d5
	moveq.l	#1,d6
	moveq.l	#16,d7
.Again:	moveq.l	#0,d0			; Get icon number
	move.b	(a3)+,d0
	beq	.End
	cmp.w	#Person_auto_icon,d0	; NPC icon ?
	bne.s	.No_NPC
	btst	#Show_NPCs_function,Automap_function	; Function on ?
	bne.s	.Do
	bra.s	.Again
.No_NPC:	cmp.w	#Monster_auto_icon,d0	; Monster icon ?
	bne.s	.No_mon
	btst	#Show_monsters_function,Automap_function	; Function on ?
	bne.s	.Do
	bra.s	.Again
.No_mon:	btst	d0,d4			; Hidden ?
	beq.s	.Do
	btst	#Show_traps_function,Automap_function	; Function on ?
	beq.s	.Again
.Do:	subq.w	#2,d0			; Get first frame
	add.w	d0,d0
	move.b	0(a4,d0.w),d0
	bclr	#7,d0
	move.l	a1,a0			; Find graphics address
	mulu.w	#AM_icon_size,d0
	add.l	d0,a0
	move.w	d2,d0			; Display
	jsr	Put_masked_block
	moveq.l	#0,d0			; Get icon number
	move.b	-1(a3),d0
	subq.w	#2,d0			; Find text
	move.l	a2,a0
	jsr	Find_small_text
	move.w	d2,d0			; Print it
	addi.w	#16,d0
	addi.w	#9,d1
	jsr	Put_text_line
	add.w	#13-9,d1			; Next
	bra.s	.Again
.End:	Free	Automap_gfx_handle
	movem.l	(sp)+,d0-d7/a0-a4
	rts

;*****************************************************************************
; [ Insert automap icon ]
;   IN : d0 - X-coordinate {1...} (.w)
;        d1 - Y-coordinate {1...} (.w)
;        d2 - Automap icon number (.w)
; All registers are restored
;*****************************************************************************
Insert_automap_icon:
	move.l	d3,-(sp)
	tst.w	d2			; Too low ?
	ble	.Exit
	cmp.w	#Max_auto_icons,d2		; Too high ?
	ble	.Ok
	moveq.l	#WRONG_auto_icon,d2
.Ok:	move.l	#Automap_wall_mask,d3	; Wall ?
	btst	d2,d3
	beq	.No_wall
; ---------- Insert icon in floor -----------------
	movem.l	d0-d2/d6/d7/a0-a2,-(sp)
	moveq.l	#4-1,d2			; Determine wall type
	moveq.l	#0,d3
	move.w	d0,d6
	move.w	d1,d7
	lea.l	Normal_wall_mask,a2		; Default
	btst	#Show_hidden_function,Automap_function	; Function on ?
	beq.s	.Loop1
	jsr	Get_location_status		; Get wall info
	btst	#Way_blocked_bit,d0		; Blocked ?
	bne.s	.Loop1
	btst	#Blocked_foot_bit,d0
	beq.s	.Loop1
	lea.l	Hidden_wall_mask,a2		; No -> Secret !
.Loop1:	move.w	d6,d0			; Check around
	move.w	d7,d1
	jsr	Move_in_direction
	jsr	Get_automap_bit		; Known ?
	beq.s	.No
	jsr	Get_location_status		; Yes
	btst	#Vision_blocked_bit,d0	; Vision blocked ?
	beq.s	.No
	bset	d2,d3			; Indicate
.No:	dbra	d2,.Loop1			; Next
	Get	Automap_gfx_handle,a0	; Get graphics address
	mulu.w	#AM_wall_size,d3
	add.l	d3,a0
	Get	Automap_floor_handle,a1	; Get destination address
	subq.w	#1,d6
	add.w	d6,a1
	subq.w	#1,d7
	lsl.w	#3,d7
	mulu.w	Width_of_automap,d7
	add.l	d7,a1
	moveq.l	#8-1,d7			; Insert wall icon
.Loop2:	move.b	(a0),d0
	and.b	(a2)+,d0
	move.b	d0,(a1)
	addq.l	#2,a0
	add.w	Width_of_automap,a1
	dbra	d7,.Loop2
	Free	Automap_floor_handle	; End
	Free	Automap_gfx_handle
	movem.l	(sp)+,d0-d2/d6/d7/a0-a2
	cmp.w	#Wall_auto_icon,d2		; Real wall ?
	beq.s	.Exit
; ---------- Insert icon in buffer ----------------
.No_wall:	movem.l	d0-d2/a0,-(sp)
	Get	Automap_buffer_handle,a0	; Get buffer address
	subq.w	#1,d0
	add.w	d0,a0
	subq.w	#1,d1
	mulu.w	Width_of_automap,d1
	add.w	d1,a0
	subq.w	#1,d2			; Adapt
	move.b	d2,(a0)			; Insert
	Free	Automap_buffer_handle
	movem.l	(sp)+,d0-d2/a0
.Exit:	move.l	(sp)+,d3
	rts

;*****************************************************************************
; [ Initialize automap ]
; All registers are restored
;*****************************************************************************
Init_automap:
	movem.l	d0/d1,-(sp)
	move.w	Map_nr,d0			; Load automap
	moveq.l	#Automap_file,d1
	jsr	Load_subfile
	move.b	d0,Automap_handle
	sf	Automap_updated		; Clear
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Exit automap ]
; All registers are restored
;*****************************************************************************
Exit_automap:
	move.l	d0,-(sp)
	jsr	Save_automap		; Save automap
	move.b	Automap_handle,d0		; Free memory
	jsr	Free_memory
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Save automap ]
; All registers are restored
;*****************************************************************************
Save_automap:
	movem.l	d0/d1/a0,-(sp)
	tst.b	Automap_updated		; Changed ?
	beq.s	.Exit
	move.w	Map_nr,d0			; Yes -> Save
	moveq.l	#Automap_file,d1
	Get	Automap_handle,a0
	jsr	Save_subfile
	Free	Automap_handle
	sf	Automap_updated		; Clear
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

;*****************************************************************************
; [ Update automap ]
; All registers are restored
;*****************************************************************************
Update_automap:
	movem.l	d0-d3/d6/d7/a0-a2,-(sp)
	tst.b	Stygian			; Can you	see ?
	bne	.Exit
	Get	Automap_handle,a0
	move.w	Map_Xcoord,d0		; Update current position
	move.w	Map_Ycoord,d1
	jsr	Set_automap_bit
	lea.l	Dir8_offset,a1		; Update around player
	lea.l	Automap_extra_view_table,a2
	move.w	d0,d2
	move.w	d1,d3
	moveq.l	#8-1,d7
.Loop1:	move.b	(a1)+,d0			; Get vector
	ext.w	d0
	add.w	d2,d0
	move.b	(a1)+,d1
	ext.w	d1
	add.w	d3,d1
	jsr	Set_automap_bit		; Set bit in automap
	jsr	Get_location_status		; Get location status
	btst	#Vision_blocked_bit,d0	; Vision blocked ?
	beq.s	.No
	addq.l	#6,a2			; Yes -> Skip
	bra.s	.Next1
.No:	moveq.l	#3-1,d6			; No -> Extra view
.Loop2:	move.b	(a2)+,d0			; Get vector
	ext.w	d0
	add.w	d2,d0
	move.b	(a2)+,d1
	ext.w	d1
	add.w	d3,d1
	jsr	Set_automap_bit		; Set bit in automap
	dbra	d6,.Loop2
.Next1:	dbra	d7,.Loop1			; Next direction
	Free	Automap_handle
.Exit:	movem.l	(sp)+,d0-d3/d6/d7/a0-a2
	rts

;****************************************************************************
; [ Get bit from automap ]
;   IN : d0 - X-coordinate {1...} (.w)
;        d1 - Y-coordinate {1...} (.w)
;  OUT : eq - Bit is not set
;        ne - Bit is set
; All registers are restored
;****************************************************************************
Get_automap_bit:
	movem.l	d0/d1/a0,-(sp)
	cmp.w	#Super_chicken,Travel_mode	; Cheating ?
	bne.s	.No
	moveq.l	#-1,d0			; Force NE
	bra	.Exit
.No:	subq.w	#1,d0			; Correction
	subq.w	#1,d1
	mulu.w	Width_of_map,d1		; Calculate bit-number
	add.w	d0,d1			;  & offset
	moveq.l	#7,d0
	and.w	d1,d0
	lsr.w	#3,d1
	Get	Automap_handle,a0		; Get byte
	move.b	0(a0,d1.w),d1
	Free	Automap_handle
	btst	d0,d1			; Test
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

;****************************************************************************
; [ Set bit in automap ]
;   IN : d0 - X-coordinate {1...Width_of_map} (.w)
;        d1 - Y-coordinate {1...Height_of_map} (.w)
;        a0 - Pointer to automap (.l)
; All registers are restored
;****************************************************************************
Set_automap_bit:
	movem.l	d0/d1,-(sp)
	subq.w	#1,d0			; Correction
	subq.w	#1,d1
	cmp.w	Width_of_map,d0		; Inside map ?
	bhs.s	.Exit
	cmp.w	Height_of_map,d1
	bhs.s	.Exit
	mulu.w	Width_of_map,d1		; Calculate bit-number
	add.w	d0,d1			;  & offset
	moveq.l	#7,d0
	and.w	d1,d0
	lsr.w	#3,d1
	btst	d0,0(a0,d1.w)		; Bit already set ?
	bne.s	.Exit
	bset	d0,0(a0,d1.w)		; Set bit
	st	Automap_updated
.Exit:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
; *** AUTOMAPPER : 2nd layer ***
Automapper_L2:
	dc.w 0,207,37,199			; Automap area
	dc.b 1
	even
	dc.l 0,Automapper_L3

; *** AUTOMAPPER : 3rd layer ***
Automapper_L3:
	dc.w 0,15,37,37+15			; Top-left
	dc.b 8
	even
	dc.l .C2
.C2:	dc.w 16,191,37,37+15		; Top
	dc.b 1
	even
	dc.l .C3
.C3:	dc.w 192,207,37,37+15		; Top-right
	dc.b 2
	even
	dc.l .C4
.C4:	dc.w 0,15,37+16,199-16		; Left
	dc.b 7
	even
	dc.l .C5
.C5:	dc.w 16,191,37+16,199-16		; MIDDLE
	dc.b 9
	even
	dc.l .C6
.C6:	dc.w 192,207,37+16,199-16		; Right
	dc.b 3
	even
	dc.l .C7
.C7:	dc.w 0,15,199-15,199		; Bottom-left
	dc.b 6
	even
	dc.l .C8
.C8:	dc.w 16,191,199-15,199		; Bottom
	dc.b 5
	even
	dc.l .C9
.C9:	dc.w 192,207,199-15,199		; Bottom-right
	dc.b 4
	even
	dc.l 0

Automap_CA:	dc.w 0,207,37,199
Automap_icon_table:
	dc.b AM_icon01,4,AM_icon02,4
	dc.b AM_icon03,4,AM_icon04,4
	dc.b AM_icon05,4,AM_icon06,4
	dc.b AM_icon07,4,AM_icon08,1
	dc.b AM_icon09,1,AM_icon10,1
	dc.b AM_icon11,1,AM_icon12,1
	dc.b AM_icon13,1,AM_icon14,1
	dc.b AM_icon15,1,AM_icon16,1
	dc.b $80+AM_icon17,8
	dc.b AM_icon_WRONG,8		; WRONG icon
	even

	FINGERPRINT

Legend_page_list:
	dc.l Legend_page_1,Legend_page_2
	dc.l 0
Legend_page_1:
	dc.b Riddlemouth_auto_icon
	dc.b Teleporter_auto_icon
	dc.b Closed_door_auto_icon
	dc.b Closed_chest_auto_icon
	dc.b Spinner_auto_icon
	dc.b Merchant_auto_icon
	dc.b Inn_auto_icon
	dc.b Special_auto_icon
	dc.b 0
Legend_page_2:
	dc.b Map_exit_auto_icon
	dc.b Trashpile_auto_icon
	dc.b Trap_auto_icon
	dc.b Trapdoor_auto_icon
	dc.b Person_auto_icon
	dc.b Monster_auto_icon
	dc.b Goto_auto_icon
	dc.b 0

Automap_extra_view_table:
	dc.b -1,-2,0,-2,1,-2		; N
	dc.b 1,-2,2,-2,2,-1		; NE
	dc.b 2,-1,2,0,2,1			; E
	dc.b 2,1,2,2,1,2			; SE
	dc.b -1,2,0,2,1,2			; S
	dc.b -2,1,-2,2,-1,2		; SW
	dc.b -2,-1,-2,-0,-2,1		; W
	dc.b -2,-2,-1,-2,-2,-1		; NW
	even

Normal_wall_mask:	dc.l $ffffffff,$ffffffff
Hidden_wall_mask:	dc.l $55aa55aa,$55aa55aa
