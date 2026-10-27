; Proof of concept : loading maps, map changes and the 2D world maps (Atari ST)
;
; The converted data is in DATA\ (see tools/st_convert.py). A map is loaded
; with [ Load_map ]; the graphics of its tileset, the NPC and party graphics
; are only loaded when they change.
;
; 2D world maps consist of submaps of 50x50 (Lyramion 16x16 submaps etc.).
; The Amiga version keeps a "quad-map" of 2x2 submaps around the party
; (MAP/2D_WILD.S). Here the 3x3 submaps around the submap of the party are
; kept in memory, so every position of the map window can be read with
; [ Get_map_tile ], which handles city maps and world maps.

	SECTION	Program,code

Submap_size	EQU	50			; Width & height of a world submap
World_slot_size	EQU	11*1024			; (largest world map : 10964 bytes)

;*****************************************************************************
; [ Load a map ]
;   IN : d0 - Map number (.w)
; All registers are restored
; NOTE :
;   - [ Map_Xcoord ] and [ Map_Ycoord ] must be set.
;*****************************************************************************
Load_map:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	d0,Map_nr
	lea.l	Map_data_buffer,a1		; Load map data
	move.l	#Max_map_size,d1
	moveq.l	#'M',d2
	jsr	Load_numbered_file
	lea.l	Map_data_buffer,a0
	moveq.l	#0,d0
	move.b	Map_width(a0),d0		; Width & height
	move.w	d0,Width_of_map
	move.b	Map_height(a0),d0
	move.w	d0,Height_of_map
; ---------- Tileset ------------------------------
	moveq.l	#0,d7
	move.b	Icondat_filenr(a0),d7
	cmp.w	Current_tileset,d7		; Changed ?
	beq.s	.Same_ts
	move.w	d7,Current_tileset
	move.w	#-1,Current_world		; Reload sprites
	move.w	#-1,Current_NPC_file
	lea.l	Icon_graphics,a1		; Icon graphics
	move.l	#Max_icons*16*8,d1
	moveq.l	#'I',d2
	move.w	d7,d0
	jsr	Load_numbered_file
	lea.l	Icon_data_buffer,a1		; Icon data
	move.l	#2+Max_icons*8,d1
	moveq.l	#'D',d2
	jsr	Load_numbered_file
	lea.l	Map_palette,a1		; Palette
	moveq.l	#64,d1
	moveq.l	#'P',d2
	jsr	Load_numbered_file
	jsr	Load_travel_graphics	; Travel graphics
	jsr	Load_stationary_graphics	; Stationary transports
.Same_ts:
; ---------- Party & NPC graphics -----------------
	lea.l	Map_data_buffer,a0
	moveq.l	#0,d6
	move.b	World_number(a0),d6
	cmp.w	Current_world,d6		; Party graphics changed ?
	beq.s	.Same_world
	move.w	d6,Current_world
	move.w	d6,d0			; "G<world>_<tileset>"
	move.w	Current_tileset,d1
	moveq.l	#'G',d2
	lea.l	Party_graphics,a1
	move.l	#17*32*8,d3
	jsr	Load_sprite_file
.Same_world:
	moveq.l	#0,d6
	move.b	Npcgfx_filenr(a0),d6
	beq.s	.No_NPCs
	cmp.w	Current_NPC_file,d6		; NPC graphics changed ?
	beq.s	.No_NPCs
	move.w	d6,Current_NPC_file
	move.w	d6,d0			; "N<file>_<tileset>"
	move.w	Current_tileset,d1
	moveq.l	#'N',d2
	lea.l	NPC_graphics,a1
	move.l	#Max_NPC_graphics,d3
	jsr	Load_sprite_file
.No_NPCs:
; ---------- Map texts ----------------------------
	move.w	Map_nr,d0
	lea.l	Map_texts,a1
	move.l	#Max_map_texts,d1
	moveq.l	#'X',d2
	jsr	Load_numbered_file
	lea.l	Map_texts,a0
	move.w	Map_nr,Map_texts_nr
; ---------- World map or city map ? --------------
	jsr	Check_world_map
	tst.b	World_map
	beq.s	.City
	jsr	Init_world_map
	bra.s	.Done
.City:	jsr	Calculate_map_data_offsets
	jsr	Init_persons_2D
	move.b	#C2_animspeed,Anim_speed	; Animation parameters (2D city)
	move.b	#C2_animspeed,Anim_count
	move.w	#C2_animbias,Anim_bias
.Done:	move.w	Travel_mode,d0		; (speed of the travel mode)
	jsr	Set_new_travel_mode
	jsr	Get_CD_value
	jsr	Make_map_name
	jsr	Update_light_status
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Load a numbered data file ("DATA\<letter><number>.BIN") ]
;   IN : d0 - Number (.w)
;        d1 - Maximum length (.l)
;        d2 - Letter (.b)
;        a1 - Pointer to buffer (.l)
; All registers are restored
; NOTE :
;   - Map files have 3 digits, the others as many as needed.
;*****************************************************************************
Load_numbered_file:
	movem.l	d0-d3/a0/a1,-(sp)
	lea.l	File_name+5,a0		; Make name
	move.b	d2,(a0)+
	cmp.b	#'M',d2			; 3 digits ?
	beq.s	.Three
	cmp.b	#'X',d2
	bne.s	.Free
.Three:	moveq.l	#3,d3
	jsr	Put_number
	bra.s	.Ext
.Free:	moveq.l	#0,d3
	jsr	Put_number
.Ext:	jsr	Put_extension
	move.l	d1,d0			; Load
	lea.l	File_name,a0
	jsr	Load_file
	tst.l	d0
	bmi	File_error
	movem.l	(sp)+,d0-d3/a0/a1
	rts

;*****************************************************************************
; [ Load a sprite file ("DATA\<letter><a>_<b>.BIN") ]
;   IN : d0 - First number (.w)
;        d1 - Second number (.w)
;        d2 - Letter (.b)
;        d3 - Maximum length (.l)
;        a1 - Pointer to buffer (.l)
; All registers are restored
;*****************************************************************************
Load_sprite_file:
	movem.l	d0-d3/a0/a1,-(sp)
	lea.l	File_name+5,a0		; Make name
	move.b	d2,(a0)+
	move.l	d3,-(sp)
	moveq.l	#0,d3
	jsr	Put_number
	move.b	#'_',(a0)+
	move.w	d1,d0
	jsr	Put_number
	jsr	Put_extension
	move.l	(sp)+,d0			; Load
	lea.l	File_name,a0
	jsr	Load_file
	tst.l	d0
	bmi	File_error
	movem.l	(sp)+,d0-d3/a0/a1
	rts

; Put a decimal number : d0 = number, d3 = digits (0 = as needed), a0 = target
Put_number:
	movem.l	d0-d2/a1,-(sp)
	lea.l	Number_buffer+6,a1
	andi.l	#$ffff,d0
	moveq.l	#0,d2			; Count digits
.Loop:	divu.w	#10,d0
	swap	d0
	addi.b	#'0',d0
	move.b	d0,-(a1)
	clr.w	d0
	swap	d0
	addq.w	#1,d2
	tst.w	d0
	bne.s	.Loop
.Fill:	cmp.w	d3,d2			; Leading zeroes
	bpl.s	.Copy
	move.b	#'0',-(a1)
	addq.w	#1,d2
	bra.s	.Fill
.Copy:	subq.w	#1,d2
.Loop2:	move.b	(a1)+,(a0)+
	dbra	d2,.Loop2
	movem.l	(sp)+,d0-d2/a1
	rts

Put_extension:
	move.b	#'.',(a0)+
	move.b	#'B',(a0)+
	move.b	#'I',(a0)+
	move.b	#'N',(a0)+
	clr.b	(a0)
	rts

;*****************************************************************************
; [ Show a file error and exit ]
;*****************************************************************************
File_error:
	jsr	Restore_system
	pea	Load_error_text
	move.w	#9,-(sp)			; Cconws
	trap	#GEMDOS
	addq.l	#6,sp
	pea	File_name
	move.w	#9,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	move.w	#7,-(sp)			; Crawcin
	trap	#GEMDOS
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#GEMDOS

;*****************************************************************************
; [ Get CD value for current map ]
; All registers are restored
; NOTE :
;   - From PERSONS.S. The CD bits are in the savegame.
;*****************************************************************************
Get_CD_value:
	movem.l	d0/a0,-(sp)
	lea.l	Savegame+Save_CD,a0		; Get CD value
	move.w	Map_nr,d0
	lsl.w	#2,d0
	lea.l	-4(a0,d0.w),a0
	move.b	3(a0),d0
	lsl.w	#8,d0
	move.b	2(a0),d0
	swap	d0
	move.b	1(a0),d0
	lsl.w	#8,d0
	move.b	(a0),d0
	move.l	d0,CD_value		; Store
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Make the map name for the headline ]
; All registers are restored
;*****************************************************************************
Make_map_name:
	movem.l	d0/a0/a1,-(sp)
	lea.l	Map_name,a1
	tst.b	World_map			; World map ?
	beq.s	.City
	lea.l	World_names,a0		; Yes -> world name
	move.w	Current_world_nr,d0
	lsl.w	#5,d0
	add.w	d0,a0
	bra.s	.Copy
.City:	lea.l	Map_texts,a0		; No -> first map text
	clr.b	(a1)
	tst.w	(a0)			; Any ?
	beq.s	.Exit
	moveq.l	#0,d0
	jsr	Find_large_text
.Skip:	cmp.b	#' ',(a0)+		; Skip leading spaces
	beq.s	.Skip
	subq.l	#1,a0
.Copy:	moveq.l	#40-1,d0
.Loop:	move.b	(a0)+,(a1)+
	dbeq	d0,.Loop
	clr.b	(a1)
.Trim:	cmp.l	#Map_name,a1		; Remove trailing spaces
	beq.s	.Exit
	tst.b	-(a1)
	beq.s	.Trim
	cmp.b	#' ',(a1)
	bne.s	.Exit
	clr.b	(a1)
	bra.s	.Trim
.Exit:	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Find a text block in a LARGE text file ]
;   IN : d0 - Text block number [0...] (.w)
;        a0 - Pointer to large text file (.l)
;  OUT : a0 - Pointer to text (.l)
; Changed registers : a0
; NOTE :
;   - From HULL/CONTROLS.S.
;*****************************************************************************
Find_large_text:
	movem.l	d0/d7/a1,-(sp)
	move.w	(a0)+,d7			; Get number of texts
	move.l	a0,a1
	cmp.w	d7,d0			; Legal block number ?
	bmi.s	.Yes
	lea.l	No_text,a0		; No
	bra.s	.Exit
.Yes:	add.w	d7,d7			; Skip block lengths
	add.w	d7,a0
	bra.s	.Entry			; Find block
.Loop:	add.w	(a1)+,a0
.Entry:	dbra	d0,.Loop
.Exit:	movem.l	(sp)+,d0/d7/a1
	rts

;*****************************************************************************
; [ Check if the current map is a world map ]
; All registers are restored
;*****************************************************************************
Check_world_map:
	movem.l	d0-d2/a0,-(sp)
	sf	World_map
	lea.l	Map_data_buffer,a0		; Get world
	moveq.l	#0,d0
	move.b	World_number(a0),d0
	cmp.w	#3,d0
	bpl.s	.Exit
	move.w	d0,Current_world_nr
	lea.l	World_data,a0		; Get world data
	mulu.w	#World_data_entry,d0
	add.w	d0,a0
	move.w	(a0)+,World_width
	move.w	(a0)+,World_height
	move.w	(a0)+,First_world_map_nr
	move.w	Map_nr,d1			; Inside the world ?
	sub.w	First_world_map_nr,d1
	bmi.s	.Exit
	move.w	World_width,d2
	mulu.w	World_height,d2
	cmp.w	d2,d1
	bpl.s	.Exit
	st	World_map
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Initialize a 2D world map ]
; All registers are restored
; NOTE :
;   - From [ W2_ModInit ] (MAP/2D_WILD.S).
;*****************************************************************************
Init_world_map:
	movem.l	d2/a0,-(sp)
	jsr	Clear_persons_buffer	; No persons
	lea.l	VNPC_data,a0
	moveq.l	#Max_chars-1,d2
.Clear:	clr.b	NPC_char_nr(a0)
	lea.l	VNPC_data_size(a0),a0
	dbra	d2,.Clear
	moveq.l	#0,d2			; Get current map number
	move.w	Map_nr,d2
	sub.w	First_world_map_nr,d2	; Subtract number of first map
	divu.w	World_width,d2		; Calculate world coordinates
	move.w	d2,World_Y
	swap	d2
	move.w	d2,World_X
	jsr	Load_world_submaps
	move.b	#W2_animspeed,Anim_speed	; Set animation parameters
	move.b	#W2_animspeed,Anim_count
	move.w	#W2_animbias,Anim_bias
	movem.l	(sp)+,d2/a0
	rts

;*****************************************************************************
; [ Get world map number ]
;   IN : d0 - World X (.w)
;        d1 - World Y (.w)
;  OUT : d2 - World map number (.w)
; Changed registers : d2
; NOTE :
;   - From MAP/2D_WILD.S.
;*****************************************************************************
Get_world_map_number:
	movem.l	d0/d1,-(sp)
	tst.w	d0			; Wrap X
	bpl.s	.Skip_X
	add.w	World_width,d0
	bra.s	.Check_Y
.Skip_X:	cmp.w	World_width,d0
	bmi.s	.Check_Y
	sub.w	World_width,d0
.Check_Y:	tst.w	d1			; Wrap Y
	bpl.s	.Skip_Y
	add.w	World_height,d1
	bra.s	.Cont
.Skip_Y:	cmp.w	World_height,d1
	bmi.s	.Cont
	sub.w	World_height,d1
.Cont:	mulu.w	World_width,d1
	move.w	d1,d2
	add.w	d0,d2
	add.w	First_world_map_nr,d2	; Add number of first map
	movem.l	(sp)+,d0/d1
	rts

;*****************************************************************************
; [ Make sure that the 3x3 submaps around the party are loaded ]
; All registers are restored
;*****************************************************************************
Load_world_submaps:
	movem.l	d0-d7/a0-a2,-(sp)
	lea.l	Needed_submaps,a0		; Get the needed map numbers
	moveq.l	#-1,d1
.Loop_Y:	moveq.l	#-1,d0
.Loop_X:	movem.w	d0/d1,-(sp)
	add.w	World_X,d0
	add.w	World_Y,d1
	jsr	Get_world_map_number
	movem.w	(sp)+,d0/d1
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmp.w	#2,d0
	bmi.s	.Loop_X
	addq.w	#1,d1
	cmp.w	#2,d1
	bmi.s	.Loop_Y
; ---------- Free slots which are not needed ------
	lea.l	World_slot_nrs,a1
	moveq.l	#9-1,d7
.Loop1:	move.w	(a1),d0
	lea.l	Needed_submaps,a0
	moveq.l	#9-1,d6
.Find:	cmp.w	(a0)+,d0
	beq.s	.Keep
	dbra	d6,.Find
	clr.w	(a1)			; Not needed
.Keep:	addq.l	#2,a1
	dbra	d7,.Loop1
; ---------- Load the missing maps ----------------
	lea.l	Needed_submaps,a0
	moveq.l	#9-1,d7
.Loop2:	move.w	(a0)+,d0
	jsr	Find_world_slot		; Loaded ?
	bne.s	.Next2
	lea.l	World_slot_nrs,a1		; No -> find a free slot
	moveq.l	#0,d1
.Free:	tst.w	(a1)+
	beq.s	.Got
	addq.w	#1,d1
	bra.s	.Free
.Got:	move.w	d0,-2(a1)
	mulu.w	#World_slot_size,d1
	lea.l	World_slots,a1
	add.l	d1,a1
	move.l	#World_slot_size,d1
	moveq.l	#'M',d2
	jsr	Load_numbered_file
.Next2:	dbra	d7,.Loop2
	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************************************
; [ Find the slot of a loaded world submap ]
;   IN : d0 - Map number (.w)
;  OUT : ne - Found, a2 = pointer to map data
;        eq - Not loaded
; Changed registers : a2
;*****************************************************************************
Find_world_slot:
	movem.l	d1/d7,-(sp)
	lea.l	World_slot_nrs,a2
	moveq.l	#0,d1
	moveq.l	#9-1,d7
.Loop:	cmp.w	(a2)+,d0
	beq.s	.Found
	addq.w	#1,d1
	dbra	d7,.Loop
	moveq.l	#0,d1			; eq
	bra.s	.Exit
.Found:	mulu.w	#World_slot_size,d1
	lea.l	World_slots,a2
	add.l	d1,a2
	moveq.l	#1,d1			; ne
.Exit:	movem.l	(sp)+,d1/d7
	rts

;*****************************************************************************
; [ Get a tile of the current map ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : ne - a0 = pointer to the tile (4 bytes), a1 = pointer to the map
;             data, d0/d1 = coordinates in that map, d2 = its map number
;        eq - Outside the map
; Changed registers : d0,d1,d2,a0,a1
; NOTE :
;   - In world maps the coordinates may be outside the current submap, by
;     up to one submap.
;*****************************************************************************
Get_map_tile:
	tst.b	World_map			; World map ?
	bne.s	.World
	lea.l	Map_data_buffer,a1		; City map
	move.w	Map_nr,d2
	cmp.w	#1,d0			; Inside the map ?
	blt.s	.Outside
	cmp.w	Width_of_map,d0
	bgt.s	.Outside
	cmp.w	#1,d1
	blt.s	.Outside
	cmp.w	Height_of_map,d1
	bgt.s	.Outside
	movem.w	d0/d1,-(sp)
	subq.w	#1,d1
	mulu.w	Width_of_map,d1
	subq.w	#1,d0
	add.w	d0,d1
	lsl.l	#2,d1
	lea.l	Map_data(a1),a0
	add.l	d1,a0
	movem.w	(sp)+,d0/d1
	move.w	Map_nr,d2			; ne (map numbers are > 0)
	rts
.Outside:	moveq.l	#0,d2			; eq
	rts
; ---------- World map ----------------------------
.World:	movem.l	d3/d4/a2,-(sp)
	moveq.l	#0,d3			; Submap offsets
	moveq.l	#0,d4
	cmp.w	#1,d0
	bpl.s	.X1
	add.w	#Submap_size,d0
	moveq.l	#-1,d3
	bra.s	.X2
.X1:	cmp.w	#Submap_size,d0
	ble.s	.X2
	sub.w	#Submap_size,d0
	moveq.l	#1,d3
.X2:	cmp.w	#1,d1
	bpl.s	.Y1
	add.w	#Submap_size,d1
	moveq.l	#-1,d4
	bra.s	.Y2
.Y1:	cmp.w	#Submap_size,d1
	ble.s	.Y2
	sub.w	#Submap_size,d1
	moveq.l	#1,d4
.Y2:	movem.w	d0/d1,-(sp)		; Get submap
	move.w	World_X,d0
	add.w	d3,d0
	move.w	World_Y,d1
	add.w	d4,d1
	jsr	Get_world_map_number
	move.w	d2,d0
	jsr	Find_world_slot
	movem.w	(sp)+,d0/d1
	beq.s	.Not
	move.l	a2,a1
	move.w	d1,d3			; Get tile
	subq.w	#1,d3
	mulu.w	#Submap_size,d3
	add.w	d0,d3
	subq.w	#1,d3
	lsl.l	#2,d3
	lea.l	Map_data(a1),a0
	add.l	d3,a0
	movem.l	(sp)+,d3/d4/a2
	tst.w	d2			; ne (map numbers are > 0)
	rts
.Not:	movem.l	(sp)+,d3/d4/a2
	moveq.l	#0,d2			; eq
	rts

;*****************************************************************************
; [ Re-evaluate the world map after a move ]
; All registers are restored
; NOTE :
;   - From [ Quad_evaluate ] (MAP/2D_WILD.S) : when the party leaves the
;     submap, the neighbouring submap becomes the current one.
;*****************************************************************************
World_evaluate:
	movem.l	d0-d3,-(sp)
	tst.b	World_map
	beq	.Exit
	move.w	Map_Xcoord,d0		; Get party coordinates
	move.w	Map_Ycoord,d1
	move.w	World_X,d2		; Get world coordinates
	move.w	World_Y,d3
	sf	Submap_changed
	cmpi.w	#1,d0			; X < 1 ?
	bpl.s	.Skip_X
	add.w	#Submap_size,d0
	subq.w	#1,d2
	st	Submap_changed
	bra.s	.Check_Y
.Skip_X:	cmp.w	#Submap_size,d0		; X > {width} ?
	bls.s	.Check_Y
	sub.w	#Submap_size,d0
	addq.w	#1,d2
	st	Submap_changed
.Check_Y:	cmpi.w	#1,d1			; Y < 1 ?
	bpl.s	.Skip_Y
	add.w	#Submap_size,d1
	subq.w	#1,d3
	st	Submap_changed
	bra.s	.Continue
.Skip_Y:	cmp.w	#Submap_size,d1		; Y > {height} ?
	bls.s	.Continue
	sub.w	#Submap_size,d1
	addq.w	#1,d3
	st	Submap_changed
.Continue:	tst.b	Submap_changed
	beq.s	.Exit
	move.w	d0,Map_Xcoord		; Store new values
	move.w	d1,Map_Ycoord
	move.w	d2,d0			; Wrap & get new map number
	move.w	d3,d1
	jsr	Get_world_map_number
	move.w	d2,Map_nr
	sub.w	First_world_map_nr,d2
	andi.l	#$ffff,d2
	divu.w	World_width,d2
	move.w	d2,World_Y
	swap	d2
	move.w	d2,World_X
	jsr	Load_world_submaps		; Load the new neighbours
	jsr	Get_CD_value
.Exit:	movem.l	(sp)+,d0-d3
	rts

;*****************************************************************************
; [ Change to another map ]
;   IN : d0 - Map number (.w)
; All registers are restored
; NOTE :
;   - The coordinates and the view direction must already be set.
;*****************************************************************************
Change_map:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,-(sp)
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	move.w	(sp)+,d0
	jsr	Load_map
	jsr	Draw_map_screen
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw the map screen into both screens ]
; All registers are restored
;*****************************************************************************
Draw_map_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Invalidate_tile_caches
	jsr	Show_map_layout
	jsr	Print_headline
	jsr	Display_control_icons
	move.l	#-1,Last_position		; Redraw position
	jsr	Display_2D_map
	jsr	Display_position
	jsr	Copy_screen_to_both
	jsr	Invalidate_tile_caches
	move.l	#-1,Last_position
	movem.l	(sp)+,d0-d7/a0-a6
	rts

	SECTION	Fast_DATA,data
File_name:	dc.b	"DATA\XXXXXXXXXXXX",0
	even
No_text:	dc.b	0
	even
; World data (KERNEL/DATA.S) : submaps in x & y direction, first map
World_data_entry	EQU	6
World_data:	dc.w	16,16,1			; Lyramion
	dc.w	6,6,300				; Kire's moon
	dc.w	4,4,513				; Morag

	SECTION	Fast_BSS,bss
Max_map_texts	EQU	8*1024			; (largest text file : 3738 bytes)
Number_buffer:	ds.b 8
Map_nr:	ds.w 1
Map_texts_nr:	ds.w 1
Current_tileset:	ds.w 1
Current_world:	ds.w 1			; World of the party graphics
Current_NPC_file:	ds.w 1
Current_world_nr:	ds.w 1
World_width:	ds.w 1
World_height:	ds.w 1
First_world_map_nr:	ds.w 1
World_X:	ds.w 1
World_Y:	ds.w 1
World_map:	ds.b 1
Submap_changed:	ds.b 1
Needed_submaps:	ds.w 9
World_slot_nrs:	ds.w 9
Max_travel_graphics	EQU	6*1024
Travel_graphics:	ds.b Max_travel_graphics
Map_texts:	ds.b Max_map_texts
World_slots:	ds.b 9*World_slot_size
