; Proof of concept : map events and text windows (Atari ST)
;
; Taken from EVENTS.S, MAIN.S, HULL/WINDOWS.S, HULL/CONTROLS.S and
; HULL/WORDS.S of the original source. Implemented events : map exit /
; teleport (1), text popup (4, without picture), change icon (10), query
; (13) and modify (14) of the bit arrays of the savegame. Other events end
; the event chain. A text popup with a picture is shown like the module
; ShowPicTxt_Mod (EVENTS.S, MODULES.S) : layout 7 with the picture and the
; text below, with the palette of the picture.

	SECTION	Program,code

; Offsets in the savegame (Party_data.sav)
Save_quest	EQU	$0104
Save_events	EQU	$0504
Save_CD	EQU	$2504
Save_chests	EQU	$35a4
Save_doors	EQU	$35c4

;*****************************************************************************
; [ Handle events at player's current location ]
; All registers are restored
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
Event_handler:
	movem.l	d0/d1,-(sp)
	move.w	Map_Xcoord,d0		; Get player's coordinates
	move.w	Map_Ycoord,d1
	jsr	Find_event		; Find event
	bmi.s	.Exit			; Any there ?
	jsr	Check_event_save_status	; Already saved ?
	bne.s	.Exit
	jsr	Handle_event_chain		; Handle
.Exit:	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Handle chain of events ]
; All registers are restored
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
Handle_event_chain:
	sf	Success
	st	First_event
.Again:	sf	Break_event		; Handle event
	jsr	Handle_event
	sf	First_event
	tst.b	Break_event		; Break ?
	bne.s	.Exit
	jsr	Chain_to_next_event		; Next event
	bpl.s	.Again			; Last ?
.Exit:	sf	Success
	rts

;*****************************************************************************
; [ Check if current event has been saved ]
;  OUT : eq - Not saved
;        ne - Saved
; All registers are restored
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
Check_event_save_status:
	movem.l	d0-d2,-(sp)
	move.w	Current_event_entry_nr,d0	; Calculate bit number
	move.w	Current_event_map_nr,d1
	subq.w	#1,d1
	mulu.w	#Events_per_map,d1
	add.w	d1,d0
	subq.w	#1,d0
	moveq.l	#Event_bit_array,d1		; Get bit
	moveq.l	#3,d2
	jsr	Access_bit_array
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Find map event ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : pl - Event
;        mi - No event
; All registers are restored
; NOTE :
;   - From EVENTS.S (without NPC events), with [ Get_map_tile ] for city and
;     world maps.
;*****************************************************************************
Find_event:
	movem.l	d0-d2/a0/a1,-(sp)
	jsr	Get_map_tile		; Get tile
	beq.s	.None
	move.w	d2,Current_event_map_nr
	move.w	d0,Current_event_X
	move.w	d1,Current_event_Y
	move.l	a1,Current_event_map	; Map data with the events
	moveq.l	#0,d0			; Get event number
	move.b	1(a0),d0
	beq.s	.None
	move.w	d0,Current_event_entry_nr	; Store
	jsr	Get_first_event		; Get event offset
	moveq.l	#0,d0			; Force pl
	bra.s	.Exit
.None:	moveq.l	#-1,d0			; Force mi
.Exit:	movem.l	(sp)+,d0-d2/a0/a1
	rts

;*****************************************************************************
; [ Get first event in chain ]
;   IN : d0 - Event number {1...255} (.w)
; All registers are restored
; NOTE :
;   - From EVENTS.S. Sets [ Current_event_base ] and [ Current_event_data ].
;*****************************************************************************
Get_first_event:
	movem.l	d0-d2/a0/a1,-(sp)
	move.l	Current_event_map,a0	; Skip map layers
	moveq.l	#0,d1
	move.b	Map_width(a0),d1
	moveq.l	#0,d2
	move.b	Map_height(a0),d2
	mulu.w	d2,d1
	lsl.l	#2,d1
	addi.l	#Map_data,d1
	lea.l	0(a0,d1.l),a1		; Get number of entries
	moveq.l	#0,d2
	move.w	(a1)+,d2
	add.w	d0,d0			; Get first event number
	move.w	-2(a1,d0.w),d0
	add.l	d2,d2			; Skip event entry list
	add.l	d2,d1
	addq.l	#2,d1			; Skip number of entries
	addq.l	#2,d1			; Skip number of events
	add.l	a0,d1
	move.l	d1,Current_event_base	; Store event base
	move.w	d0,Current_event_block	; Store event block
	jsr	Copy_event_data
	movem.l	(sp)+,d0-d2/a0/a1
	rts

; Copy event d0 to Current_event_data
Copy_event_data:
	movem.l	d0/d7/a0/a1,-(sp)
	mulu.w	#Event_data_size,d0
	move.l	Current_event_base,a0
	add.l	d0,a0
	lea.l	Current_event_data,a1
	moveq.l	#Event_data_size-1,d7	; (bytewise : not aligned)
.Loop:	move.b	(a0)+,(a1)+
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Chain to next event ]
; OUT : pl - Next event
;       mi - No next event
; All registers are restored
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
Chain_to_next_event:
	movem.l	d0/d7,-(sp)
	move.w	Current_event_data+Next_event_nr,d0	; Get next event block
	move.w	Current_event_block,d7	; Get current event block
	move.w	d0,Current_event_block	; Store
	cmpi.w	#-1,d0			; Last in chain ?
	beq.s	.Last
	cmp.w	d0,d7			; Endless loop ?
	beq.s	.Last
	jsr	Copy_event_data
	moveq.l	#0,d0			; Force pl
	bra.s	.Exit
.Last:	moveq.l	#-1,d0			; Force mi
.Exit:	movem.l	(sp)+,d0/d7
	rts

;*****************************************************************************
; [ Handle map event ]
; All registers are restored
; NOTE :
;   - From EVENTS.S. Events which are not implemented end the chain.
;*****************************************************************************
Handle_event:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#0,d0			; Get current event type
	move.b	Current_event_data,d0
	tst.w	d0			; Legal ?
	beq.s	.Stop
	cmpi.w	#Max_events+1,d0
	bpl.s	.Stop
	move.l	#Map_event_mask,d1		; Possible in map ?
	btst	d0,d1
	beq.s	.Exit
	move.l	#Map_break_mask,d1		; Break ?
	btst	d0,d1
	sne	Break_event
	lsl.w	#2,d0			; Execute event
	lea.l	Event_ptrs,a0
	movea.l	-4(a0,d0.w),a0
	jsr	(a0)
	bra.s	.Exit
.Stop:	st	Break_event
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

Not_implemented:
	st	Break_event		; End the chain
	rts

No_event:					; (events without effect here, e.g. music)
	rts

; Event routines (Event_ptrs in EVENTS.S)
Event_ptrs:
	dc.l Map_exit,Not_implemented,Not_implemented,Show_pictxt,Not_implemented	; 1 - 5
	dc.l Not_implemented,Not_implemented,Not_implemented,Not_implemented,Change_icon	; 6 - 10
	dc.l Not_implemented,Not_implemented,Query,Modify,Not_implemented	; 11 - 15
	dc.l No_event,Not_implemented,Not_implemented,Not_implemented,No_event	; 16 - 20
	dc.l No_event,Not_implemented,Not_implemented,Not_implemented	; 21 - 24

;*****************************************************************************
; [ After a map change or a jump ]
; All registers are restored
; NOTE :
;   - Like the Amiga version, the events of the new position are handled,
;     but only after the current event chain has ended.
;*****************************************************************************
After_map_change:
	st	Pending_events
	rts

;*****************************************************************************
; [ Map Exit event ]
; NOTE :
;   - From EVENTS.S. All exit types (teleport, trapdoors, ...) are handled
;     like a normal map exit, the wind gates and the end sequence end the
;     chain.
;*****************************************************************************
Map_exit:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get map exit type
	move.b	Event_b5(a5),d0
	cmp.w	#2,d0			; Wind gate ?
	beq	Not_implemented
	cmp.w	#4,d0			; End sequence ?
	beq	Not_implemented
	move.w	Event_w6(a5),d0		; To current map ?
	beq.s	.Same
	cmp.w	Map_nr,d0
	beq.s	.Same
	jsr	Do_MX			; No -> Real map exit
	move.w	Event_w6(a5),d0
	jsr	Change_map
	jmp	After_map_change
.Same:	jsr	Do_MX			; Yes -> Just jump
	jsr	World_evaluate
	jmp	After_map_change

Do_MX:	moveq.l	#0,d0			; Get new coordinates
	move.b	Event_b1(a5),d0
	moveq.l	#0,d1
	move.b	Event_b2(a5),d1
	tst.w	d0			; Keep old coordinates ?
	bne.s	.Change
	tst.w	d1
	beq.s	.Keep1
.Change:	move.w	d0,Map_Xcoord		; Set new coordinates
	move.w	d1,Map_Ycoord
.Keep1:	moveq.l	#0,d0
	move.b	Event_b3(a5),d0		; Get new view direction ?
	cmp.w	#4,d0			; Keep old view direction ?
	beq.s	.Keep2
	move.w	d0,View_direction		; No -> Set new
.Keep2:	rts

;*****************************************************************************
; [ Show picture + text event ]
; NOTE :
;   - From EVENTS.S.
;*****************************************************************************
Show_pictxt:
	lea.l	Current_event_data,a5
	tst.b	First_event		; First event in chain ?
	beq.s	.Go_on
	btst	#0,Event_b2(a5)		; Triggered by moving ?
	bne.s	.Go_on
	st	Break_event		; No -> abort chain
	bra.s	.Exit
.Go_on:	cmp.b	#-1,Event_b1(a5)		; Any picture ?
	beq.s	.No_pic
	moveq.l	#0,d0			; Get text number
	move.b	Event_b5(a5),d0
	jsr	Get_event_texts
	jsr	Find_large_text
	moveq.l	#0,d0			; Get picture number
	move.b	Event_b1(a5),d0
	jsr	Show_picture_text
	bra.s	.Exit
.No_pic:	moveq.l	#0,d0			; Get text number
	move.b	Event_b5(a5),d0
	cmp.b	#-1,d0			; Any ?
	beq.s	.Exit
	jsr	Get_event_texts		; Print text
	jsr	Find_large_text
	jsr	Text_window
.Exit:	rts

;*****************************************************************************
; [ Show a picture and a text ]
;   IN : d0 - Picture number {0...} (.w)
;        a0 - Pointer to text (.l)
; All registers are restored
; NOTE :
;   - From [ ShowPicTxt_ModInit ] (EVENTS.S) and [ Init_ShowPicTxt_layout ]
;     (DISPLAY.S).
;*****************************************************************************
Show_picture_text:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,-(sp)
	move.w	d0,-(sp)
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	move.w	(sp)+,d0			; Load picture & palette
	lea.l	Event_picture,a1
	move.l	#20*ShowPicTxt_height*8,d1
	moveq.l	#'E',d2
	jsr	Load_numbered_file
	lea.l	Event_palette,a1
	moveq.l	#64,d1
	moveq.l	#'Q',d2
	jsr	Load_numbered_file
	lea.l	ShowPicTxt_RL,a0		; Install palette
	jsr	Set_raster_list
; ---------- Show layout & picture ----------------
	moveq.l	#0,d0			; Show layout
	moveq.l	#Middle_Y+1,d1
	moveq.l	#20,d6
	move.w	#199-Middle_Y,d7
	lea.l	Layout7,a0
	jsr	Put_unmasked_block
	moveq.l	#Window_colour,d4		; Clear text area
	move.w	#16,d0
	move.w	#138,d1
	move.w	#303,d2
	move.w	#192,d3
	jsr	Draw_box
	moveq.l	#0,d0			; Display picture
	move.w	#ShowPicTxt_Y,d1
	moveq.l	#20,d6
	moveq.l	#ShowPicTxt_height,d7
	lea.l	Event_picture,a0
	jsr	Put_unmasked_block
	jsr	Copy_screen_to_both
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
; ---------- Do text ------------------------------
	move.l	(sp)+,a0
	move.w	#(302-18+1)/(Char_width+1),Text_width
	jsr	Process_text
	lea.l	Text_lines,a4		; First line
	move.w	Text_height,d6		; Lines left
.Page:	move.w	d6,d5			; Lines of this page
	cmp.w	#ShowPicTxt_lines,d5
	bls.s	.Ok
	moveq.l	#ShowPicTxt_lines,d5
.Ok:	moveq.l	#Window_colour,d4		; Clear text area
	move.w	#16,d0
	move.w	#138,d1
	move.w	#303,d2
	move.w	#192,d3
	jsr	Draw_box
	move.w	#Default_ink,Ink_colour	; Print the lines
	move.w	#Default_shadow,Shadow_colour
	move.w	#18,d0
	move.w	#139+1,d1
	move.w	d5,d7
	subq.w	#1,d7
.Line:	move.l	a4,a0
	jsr	Put_text_line
	lea.l	Line_stride(a4),a4
	addi.w	#Char_height+2,d1
	dbra	d7,.Line
	jsr	Copy_screen_to_both		; Show
	jsr	Wait_for_click
	sub.w	d5,d6			; Next page
	bne	.Page
; ---------- Back to the map ----------------------
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	lea.l	Map_RL,a0
	jsr	Set_raster_list
	jsr	Draw_map_screen
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; Get the map texts of the event map (world submaps have their own texts)
;  OUT : a0 - Pointer to the map texts (.l)
Get_event_texts:
	movem.l	d0-d2/a1,-(sp)
	move.w	Current_event_map_nr,d0
	cmp.w	Map_texts_nr,d0		; Loaded ?
	beq.s	.Ok
	move.w	d0,Map_texts_nr		; No -> load them
	lea.l	Map_texts,a1
	move.l	#Max_map_texts,d1
	moveq.l	#'X',d2
	jsr	Load_numbered_file
.Ok:	lea.l	Map_texts,a0
	movem.l	(sp)+,d0-d2/a1
	rts

;*****************************************************************************
; [ Change Icon event ]
; NOTE :
;   - From EVENTS.S. The change is made in the loaded map only (the Amiga
;     version remembers it in a list of modifications).
;*****************************************************************************
Change_icon:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get coordinates
	move.b	Event_b1(a5),d0
	moveq.l	#0,d1
	move.b	Event_b2(a5),d1
	tst.w	d0			; Event coordinates ?
	bne.s	.Ok
	tst.w	d1
	bne.s	.Ok
	move.w	Current_event_X,d0		; Yes -> Get
	move.w	Current_event_Y,d1
.Ok:	move.w	Event_w6(a5),d2		; Get new icon number
	move.w	Event_w8(a5),d7		; Current map ?
	beq.s	.Do
	cmp.w	Current_event_map_nr,d7
	bne.s	.Exit
.Do:	move.l	Current_event_map,a0	; Calculate map offset
	moveq.l	#0,d3
	move.b	Map_width(a0),d3
	tst.w	d0			; Inside map ?
	ble.s	.Exit
	cmp.w	d3,d0
	bgt.s	.Exit
	tst.w	d1
	ble.s	.Exit
	subq.w	#1,d1
	mulu.w	d3,d1
	subq.w	#1,d0
	add.w	d0,d1
	lsl.l	#2,d1
	lea.l	Map_data(a0),a0
	add.l	d1,a0
	move.b	d2,2+1(a0)		; Change overlay
	lsr.w	#8,d2
	move.b	d2,2(a0)
.Exit:	rts

;*****************************************************************************
; [ Query event ]
; NOTE :
;   - From EVENTS.S. Queries which are not implemented are false.
;*****************************************************************************
Query:
	lea.l	Current_event_data,a5
	sf	Query_result		; Clear result
	moveq.l	#0,d0			; Get query type
	move.b	Event_b1(a5),d0
	cmp.w	#.Max,d0			; Implemented ?
	bpl.s	.Done
	lsl.w	#2,d0			; Execute query
	move.l	.Ptrs(pc,d0.w),d0
	beq.s	.Done
	move.l	d0,a0
	jsr	(a0)
.Done:	tst.b	Event_b2(a5)		; False desired ?
	bne.s	.No
	not.b	Query_result		; Yes -> reverse result
.No:	tst.b	Query_result		; Query true or false ?
	bne.s	.Exit
	move.w	Event_w8(a5),Current_event_data+Next_event_nr	; Negative chain
.Exit:	rts

.Ptrs:	dc.l .Quest,.Event,.Door,.Chest		;  0 -  3
	dc.l .CD,0,0,0				;  4 -  7
	dc.l 0,.Success,0,.Light			;  8 - 11
	dc.l .Direction				; 12
.Max	EQU	13

.Quest:	moveq.l	#Quest_bit_array,d1
	bra.s	.Do
.Event:	moveq.l	#Event_bit_array,d1
	bra.s	.Do
.Door:	moveq.l	#Door_bit_array,d1
	bra.s	.Do
.Chest:	moveq.l	#Chest_bit_array,d1
	bra.s	.Do
.CD:	moveq.l	#CD_bit_array,d1
.Do:	move.w	Event_w6(a5),d0		; Get bit number
	moveq.l	#3,d2			; Get bit
	jsr	Access_bit_array
	sne	Query_result
	rts

.Success:	move.b	Success,Query_result	; Copy flag
	rts

.Light:	st	Query_result		; (no darkness yet)
	rts

.Direction:	move.w	Event_w6(a5),d0		; Get direction
	cmp.w	View_direction,d0		; Same ?
	seq	Query_result
	rts

;*****************************************************************************
; [ Modify event ]
; NOTE :
;   - From EVENTS.S (only the bit arrays).
;*****************************************************************************
Modify:
	lea.l	Current_event_data,a5
	moveq.l	#0,d0			; Get modify type
	move.b	Event_b1(a5),d0
	cmp.w	#5,d0			; Bit array ?
	bpl.s	.Exit
	move.b	.Arrays(pc,d0.w),d1
	move.w	Event_w6(a5),d0		; Get bit number
	move.b	Event_b2(a5),d2		; Modify bit
	jsr	Access_bit_array
	cmp.b	#CD_bit_array,d1		; Characters changed ?
	bne.s	.Exit
	jsr	Get_CD_value
.Exit:	rts

.Arrays:	dc.b Quest_bit_array,Event_bit_array,Door_bit_array,Chest_bit_array
	dc.b CD_bit_array
	even

;*****************************************************************************
; [ Access bit array ]
;   IN : d0 - Bit number (.w)
;        d1 - Bit array type (.w)
;        d2 - Action (0 = clear, 1 = set, 2 = toggle, 3 = test) (.b)
;  OUT : eq - Bit clear (only when testing)
;        ne - Bit set (only when testing)
; All registers are restored
; NOTE :
;   - From MAIN.S, the arrays are in the savegame.
;*****************************************************************************
Access_bit_array:
	movem.l	d0/d1/a0,-(sp)
	cmp.w	#5,d1			; Legal array type ?
	bpl	.Exit
	lea.l	.Bit_array_table(pc),a0	; Get bit array info
	lsl.w	#3,d1
	add.l	d1,a0
	andi.l	#$0000ffff,d0		; Legal number ?
	cmp.l	(a0)+,d0
	bcc.s	.Exit
	move.l	(a0),a0			; Get array address
	moveq.l	#$0007,d1			; Calculate bit & byte
	and.w	d0,d1
	lsr.l	#3,d0
	add.l	d0,a0
	tst.b	d2			; Clear ?
	bne.s	.No1
	bclr	d1,(a0)			; Clear
	bra.s	.Exit
.No1:	cmp.b	#1,d2			; Set ?
	bne.s	.No2
	bset	d1,(a0)			; Set
	bra.s	.Exit
.No2:	cmp.b	#2,d2			; Toggle ?
	bne.s	.No3
	bchg	d1,(a0)			; Toggle
	bra.s	.Exit
.No3:	cmp.b	#3,d2			; Test ?
	bne.s	.Exit
	btst	d1,(a0)			; Test
.Exit:	movem.l	(sp)+,d0/d1/a0
	rts

.Bit_array_table:				; (order of the bit array types)
	dc.l	8192,Savegame+Save_quest
	dc.l	256,Savegame+Save_chests
	dc.l	256,Savegame+Save_doors
	dc.l	32*1024,Savegame+Save_CD
	dc.l	64*1024,Savegame+Save_events

;*****************************************************************************
; [ Text window ]
;   IN : a0 - Pointer to text (.l)
; All registers are restored
; NOTE :
;   - From [ TxtW_DisInit ] (HULL/CONTROLS.S) : a window of 18 truncs at
;     (TxtW_X, TxtW_Y), as high as the text. Longer texts are shown in
;     pages of 16 lines.
;*****************************************************************************
Text_window:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#Max_text_window_line,Text_width
	jsr	Process_text
	lea.l	Text_lines,a4		; First line
	move.w	Text_height,d6		; Lines left
.Page:	move.w	d6,d5			; Lines of this page
	cmp.w	#16,d5
	bls.s	.Ok
	moveq.l	#16,d5
.Ok:	move.w	d5,d0			; Calculate window height
	mulu.w	#Char_height+2,d0
	move.w	d0,d4			; (text height)
	move.w	d0,d3
	addi.w	#15,d3
	lsr.w	#4,d3
	cmpi.w	#2,d3			; Window too small ?
	bpl.s	.No
	moveq.l	#2,d3
.No:	move.w	#TxtW_X,d0		; Open a window
	move.w	#TxtW_Y,d1
	moveq.l	#18,d2
	addq.w	#2,d3
	jsr	Open_window
	move.w	d3,d7			; Vertical centering
	subq.w	#2,d7
	lsl.w	#4,d7
	sub.w	d4,d7
	lsr.w	#1,d7
	add.w	d7,d1
	addi.w	#16+1,d1
	move.w	#Default_ink,Ink_colour	; Print the lines
	move.w	#Default_shadow,Shadow_colour
	move.w	#TxtW_X+16,d0
	move.w	d5,d7
	subq.w	#1,d7
.Line:	move.l	a4,a0
	jsr	Put_text_line
	lea.l	Line_stride(a4),a4
	addi.w	#Char_height+2,d1
	dbra	d7,.Line
	jsr	Copy_screen_to_both		; Show
	jsr	Wait_for_click
	jsr	Close_window
	sub.w	d5,d6			; Next page
	bne	.Page
	jsr	Invalidate_tile_caches
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Wait for a mouse click or a key ]
; All registers are restored
;*****************************************************************************
Wait_for_click:
	move.l	d0,-(sp)
	jsr	Read_mouse_clicks		; Forget old events
.Flush:	jsr	Read_key
	tst.w	d0
	bne.s	.Flush
.Loop:	jsr	Switch_screens		; (mouse pointer)
	jsr	Read_mouse_clicks
	tst.w	d0
	bne.s	.Exit
	jsr	Read_key
	tst.w	d0
	beq.s	.Loop
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Open a window ]
;   IN : d0 - Top left X-coordinate (on trunc boundary) (.w)
;        d1 - Top left Y-coordinate (.w)
;        d2 - Width of window (in truncs) (.w)
;        d3 - Height of window (in truncs) (.w)
; All registers are restored
; NOTE :
;   - From HULL/WINDOWS.S (one window, without PA, MA and object tree).
;*****************************************************************************
Open_window:
	movem.l	d0-d7/a0,-(sp)
	movem.w	d0-d3,Window_data		; Insert input
; --------- Save background -----------------------
	lea.l	Window_background,a0
	move.w	d2,d6
	move.w	d3,d7
	lsl.w	#4,d7
	jsr	Get_block
; --------- Draw border of window -----------------
	subq.w	#2,d2			; Adjust counters
	subq.w	#2,d3
	moveq.l	#0,d4			; Top-left corner
	jsr	Put_window_part
	moveq.l	#1,d4			; Left column
	move.w	d3,d7
	bra.s	.Entry1
.Loop1:	jsr	Put_window_part
.Entry1:	addi.w	#16,d1
	dbra	d7,.Loop1
	moveq.l	#2,d4			; Bottom-left corner
	jsr	Put_window_part
	moveq.l	#4,d4			; Bottom row
	move.w	d2,d7
	bra.s	.Entry2
.Loop2:	jsr	Put_window_part
.Entry2:	addi.w	#16,d0
	dbra	d7,.Loop2
	moveq.l	#7,d4			; Bottom-right corner
	jsr	Put_window_part
	moveq.l	#6,d4			; Right column
	move.w	d3,d7
	bra.s	.Entry3
.Loop3:	jsr	Put_window_part
.Entry3:	subi.w	#16,d1
	dbra	d7,.Loop3
	moveq.l	#5,d4			; Top-right corner
	jsr	Put_window_part
	moveq.l	#3,d4			; Top row
	move.w	d2,d7
	bra.s	.Entry4
.Loop4:	jsr	Put_window_part
.Entry4:	subi.w	#16,d0
	dbra	d7,.Loop4
; --------- Fill window ---------------------------
	movem.w	Window_data,d0-d3
	addi.w	#16,d0
	addi.w	#16,d1
	subq.w	#2,d2
	lsl.w	#4,d2
	add.w	d0,d2
	subq.w	#1,d2
	subq.w	#2,d3
	lsl.w	#4,d3
	add.w	d1,d3
	subq.w	#1,d3
	move.w	#Window_colour,d4
	jsr	Draw_box
	movem.l	(sp)+,d0-d7/a0
	rts

; [ Put part of a window on the screen ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Part number (0-8) (.w)
; All registers are restored
Put_window_part:
	movem.l	d4/a0,-(sp)
	lea.l	Window_icons,a0
	lsl.w	#7,d4			; (16 x 8 bytes)
	add.w	d4,a0
	jsr	Put_masked_icon
	movem.l	(sp)+,d4/a0
	rts

;*****************************************************************************
; [ Close window ]
; All registers are restored
; NOTE :
;   - From HULL/WINDOWS.S.
;*****************************************************************************
Close_window:
	movem.l	d0-d7/a0,-(sp)
	lea.l	Window_background,a0	; Restore background
	movem.w	Window_data,d0-d3
	move.w	d2,d6
	move.w	d3,d7
	lsl.w	#4,d7
	jsr	Put_unmasked_block
	jsr	Copy_screen_to_both
	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Process a text ]
;   IN : a0 - Pointer to text (.l)
;  OUT : [ Text_lines ] - The lines (.b) [ Text_height ] - Number of lines
; All registers are restored
; NOTE :
;   - Like [ Process_text ] (HULL/WORDS.S) : the text is broken into lines
;     of up to 42 characters (the width of the text window), '^' starts a
;     new line, ~SELF~ and ~LEAD~ are replaced by the name of the active
;     party member and other text commands are removed.
;*****************************************************************************
Process_text:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Text_lines,a1		; Start of first line
	moveq.l	#0,d6			; Number of lines
	moveq.l	#0,d7			; Line length
	move.l	a1,a2			; Write pointer
	sub.l	a3,a3			; No space in this line yet
.Loop:	move.b	(a0)+,d0			; Get character
	beq	.End
	cmp.b	#CR,d0			; New line ?
	bne.s	.No_CR
	jsr	.New_line
	bra.s	.Loop
.No_CR:	cmp.b	#Command_char,d0		; Text command ?
	bne.s	.Char
	move.b	(a0),d1			; ~SELF~ / ~LEAD~ ?
	lsl.w	#8,d1
	move.b	1(a0),d1
	swap	d1
	move.b	2(a0),d1
	lsl.w	#8,d1
	move.b	3(a0),d1
.Skip:	move.b	(a0)+,d0			; Skip command
	beq	.End
	cmp.b	#Command_char,d0
	bne.s	.Skip
	cmp.l	#'SELF',d1
	beq	.Insert_name
	cmp.l	#'LEAD',d1
	beq	.Insert_name
	bra	.Loop
.Char:	cmp.b	#' ',d0			; Space ?
	bne.s	.Not_space
	tst.w	d7			; At the start of a line ?
	beq.s	.Loop			; Yes -> skip
	move.l	a2,a3			; Remember position
.Not_space:	move.b	d0,(a2)+			; Store
	addq.w	#1,d7
	cmp.w	Text_width,d7		; Line full ?
	bls	.Loop
	jsr	.Wrap
	bra	.Loop
.End:	tst.w	d7			; Last line
	beq.s	.Done
	clr.b	(a2)
	addq.w	#1,d6
.Done:	move.w	d6,Text_height
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; Insert the name of the active member (the hero in the proof of concept)
.Insert_name:
	movem.l	a4,-(sp)
	lea.l	Names,a4
.Copy:	move.b	(a4)+,d0
	beq.s	.Copied
	move.b	d0,(a2)+
	addq.w	#1,d7
	cmp.w	Text_width,d7
	bls.s	.Copy
	jsr	.Wrap
	bra.s	.Copy
.Copied:	movem.l	(sp)+,a4
	bra	.Loop

; Start a new line
.New_line:	clr.b	(a2)
	addq.w	#1,d6
	lea.l	Line_stride(a1),a1
	move.l	a1,a2
	moveq.l	#0,d7
	sub.l	a3,a3
	cmp.w	#Max_lines-1,d6		; Too many lines ?
	bmi.s	.Ok
	subq.w	#1,d6
	lea.l	-(Line_stride)(a1),a1
	move.l	a1,a2
.Ok:	rts

; Wrap the current line at the last space
.Wrap:	move.l	a3,d0			; Any space ?
	beq.s	.Hard
	movem.l	a0/a4,-(sp)
	lea.l	1(a3),a0			; Rest of the line
	move.l	a2,a4
	clr.b	(a3)			; End this line
	jsr	.New_line
.Move:	cmp.l	a4,a0			; Move rest to the new line
	bpl.s	.Moved
	move.b	(a0)+,(a2)+
	addq.w	#1,d7
	bra.s	.Move
.Moved:	movem.l	(sp)+,a0/a4
	rts
.Hard:	move.b	-1(a2),d0			; No space : break the word
	subq.l	#1,a2
	jsr	.New_line
	move.b	d0,(a2)+
	addq.w	#1,d7
	rts

	SECTION	Fast_DATA,data
; Raster list of the picture screen (ShowPicTxt_RL in MODULES.S)
ShowPicTxt_RL:
	R_palette 0,UI_palette
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Event_palette
	R_end
	even

	SECTION	Fast_BSS,bss
Max_line_length	EQU	48			; (buffer)
Max_text_window_line	EQU	42
ShowPicTxt_lines	EQU	7
Line_stride	EQU	Max_line_length+2
Max_lines	EQU	64
Current_event_data:	ds.b Event_data_size
	even
Current_event_map:	ds.l 1
Current_event_base:	ds.l 1
Current_event_block:	ds.w 1
Current_event_entry_nr:	ds.w 1
Current_event_map_nr:	ds.w 1
Current_event_X:	ds.w 1
Current_event_Y:	ds.w 1
Text_height:	ds.w 1
Text_width:	ds.w 1
Window_data:	ds.w 4
Success:	ds.b 1
Break_event:	ds.b 1
First_event:	ds.b 1
Query_result:	ds.b 1
Text_lines:	ds.b Max_lines*(Line_stride)
	even
Window_background:	ds.b 18*9*16*8
Event_palette:	ds.b 64
Event_picture:	ds.b 20*ShowPicTxt_height*8
