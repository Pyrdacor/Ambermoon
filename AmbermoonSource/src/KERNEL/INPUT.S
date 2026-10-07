; Keyboard input & fatal error popup
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ Input handler (called by the input.device) ]
;   IN : a0 - Pointer to input event list (.l)
;  OUT : d0 - Input events (.l)
; NOTE :
;   - Key presses are stored with [ Store_Kev ].
;*****************************************************************************
Run_input_handler:
	movem.l	d0-d7/a0-a6,-(sp)
.Loop:
	cmp.l	#4-4,a0
	beq.w	.Exit		; A0 holds the base address of
					; the custom chips. So 0
					; indicates some kind of error.
	moveq.l	#0,d0
	move.b	4(a0),d0
	cmp.w	#1,d0
	bne.w	.Skip3
	move.w	6(a0),d0
	btst.l	#7,d0
	bne.w	.Skip4
	movem.l	d1/a0/a1,-(sp)
	lea.l	Key_buffer,a1
	sub.l	a2,a2
	moveq.l	#1,d1		; Maybe command? CMD_RESET?
	move.l	a6,-(sp)
	move.l	Console_device_pointer,a6
	jsr	-48(a6)		; Call some method on the
					; console device. DoIO?
	move.l	(sp)+,a6
	movem.l	(sp)+,d1/a0/a1
	cmp.l	#1,d0
	beq.s	.Skip
	clr.b	Key_buffer
.Skip:
	move.w	8(a0),d0
	moveq.l	#0,d1
	lea.l	Input_event_buffer,a1
	moveq.l	#7,d7
.Loop2:
	move.b	(a1)+,d2
	btst.l	d7,d0
	beq.s	.Skip2
	bset.l	d2,d1
.Skip2:
	dbra	d7,.Loop2
	moveq.l	#0,d0
	move.b	7(a0),d0
	swap	d0
	or.b	Key_buffer,d0
	or.l	d1,d0
	jsr	Store_Kev
	bra.w	.Skip4
.Skip3:
	cmp.w	#16,d0
	bne.w	.Skip4
	moveq.l	#0,d0
	bset.l	#$1d,d0
	jsr	Store_Kev
.Skip4:
	move.l	(a0),a0
	bra.w	.Loop
.Exit:
	movem.l	(sp)+,d0-d7/a0-a6
	moveq.l	#0,d0
	rts

;*****************************************************************************
; [ Read the next key event ]
;  OUT : d0 - Key code / 0 (.w)
;*****************************************************************************
Read_key:
	move.l	a0,-(sp)
	move.l	Kev_read_ptr,a0
	cmp.l	Kev_write_ptr,a0
	bne.s	.Skip
	moveq.l	#0,d0		; It's like the mouse state history but
					; this time only a single pointer is
					; tracked and of course 0 is the invalid
					; marker.
	bra.s	.Exit
.Skip:
	move.l	(a0)+,d0
	cmp.l	#Key_buffer,a0
	blt.s	.Skip2
	lea.l	Kev_buffer,a0
.Skip2:
	move.l	a0,Kev_read_ptr
.Exit:
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Store a key event ]
;   IN : d0 - Key code (.w)
; All registers are restored
;*****************************************************************************
Store_Kev:
	movem.l	a0/a1,-(sp)
	move.l	Kev_write_ptr,a0
	move.l	a0,a1
	addq.l	#4,a1
	cmp.l	#Key_buffer,a1
	blt.s	.Skip
	lea.l	Kev_buffer,a1
.Skip:
	cmp.l	Kev_read_ptr,a1
	beq.s	.Exit
	move.l	d0,(a0)
	move.l	a1,Kev_write_ptr
.Exit:
	movem.l	(sp)+,a0/a1
	rts

;*****************************************************************************
; [ Show a fatal error and exit ]
;   IN : Return_value - Error code
;*****************************************************************************
Fatal_error:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Close_current_file
	jsr	Own_blitter
	jsr	Init_diagnostic_screen
	lea.l	File_could_not_be_loaded,a1
	jsr	DI_Print
	jsr	DI_CR
	jsr	DI_CR
	lea.l	S_memory_block_0026a418,a2
	move.w	10(a5),d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),a1
	jsr	DI_Print
	move.w	12(a5),d0
	jsr	DI_Print_number
	jsr	Exit_diagnostic_screen
	movem.l	(sp)+,d0-d7/a0-a6
	jmp	Exit_program
Decompress_end:
	movem.l	d0/d7,-(sp)
	moveq.l	#0,d0
	move.w	#-1,d7
.Loop:
	move.w	d0,Custom+color00
	addq.w	#1,d0
	dbra	d7,.Loop
	movem.l	(sp)+,d0/d7
	rts

;*****************************************************************************
; [ Show the "lack of memory" warning on the diagnostic screen ]
; All registers are restored
;*****************************************************************************
Lack_of_memory_warning:
	move.l	a1,-(sp)
	jsr	Init_diagnostic_screen
	move.l	Lack_of_memory,a1
	jsr	DI_Print_text
	jsr	Exit_diagnostic_screen
	move.l	(sp)+,a1
	rts


	SECTION	Fast_DATA,data
Input_event_buffer:
	dc.b	$1c,$1c,$1a,$1a,$19,$1b,$18,$18
Kev_read_ptr:
	dc.l	Kev_buffer
Kev_write_ptr:
	dc.l	Kev_buffer
S_memory_block_0026a418:
	dc.l	Memory_block_0026a4cc,Party_data_0026a4e2,Party_character_0026a4f8,NPC_character_0026a50e
	dc.l	Monster_character_0026a524,Portrait_0026a53a,Map_data_0026a550,Icon_data_0026a566
	dc.l	Icon_graphics_0026a57c,Travel_graphics_0026a592,NPC_graphics_0026a5a8,Lab_data_0026a5be
	dc.l	Str_3_d_wall_CHIP_0026a5d4,Str_3_d_background_0026a5ea,Str_80x80_picture_0026a600,Map_texts_0026a616
	dc.l	Chest_data_0026a62c,Monster_group_0026a642,Merchant_data_0026a658,Combat_background_0026a66e
	dc.l	Monster_graphics_0026a684,Automap_0026a69a,Object_texts_0026a6b0,Event_picture_0026a6c6
	dc.l	Layout_0026a6dc,Music_0026a6f2,Palette_0026a708,Riddlemouth_graphics_0026a71e
	dc.l	Dictionary_0026a734,Str_3_d_object_CHIP_0026a74a,Str_3_d_overlay_0026a760,Str_3_d_wall_FAST_0026a776
	dc.l	Zoom_buffer_0026a78c,Str_3_d_object_FAST_0026a7a2,Saves_0026a7b8,Party_texts_0026a7ce
	dc.l	NPC_texts_0026a7e4,Automap_graphics_0026a7fa,Place_data_0026a810,Combat_graphics_0026a826
	dc.l	Floor_ceiling,Baby_character_0026a852,Stationary_graphics_0026a868,Party_graphics_0026a87e
	dc.l	Object_graphics_0026a894
Memory_block_0026a4cc:
	dc.b	"Memory block         ",0
Party_data_0026a4e2:
	dc.b	"Party data           ",0
Party_character_0026a4f8:
	dc.b	"Party character      ",0
NPC_character_0026a50e:
	dc.b	"NPC character        ",0
Monster_character_0026a524:
	dc.b	"Monster character    ",0
Portrait_0026a53a:
	dc.b	"Portrait             ",0
Map_data_0026a550:
	dc.b	"Map data             ",0
Icon_data_0026a566:
	dc.b	"Icon data            ",0
Icon_graphics_0026a57c:
	dc.b	"Icon graphics        ",0
Travel_graphics_0026a592:
	dc.b	"Travel graphics      ",0
NPC_graphics_0026a5a8:
	dc.b	"NPC graphics         ",0
Lab_data_0026a5be:
	dc.b	"Lab data             ",0
Str_3_d_wall_CHIP_0026a5d4:
	dc.b	"3D wall CHIP         ",0
Str_3_d_background_0026a5ea:
	dc.b	"3D background        ",0
Str_80x80_picture_0026a600:
	dc.b	"80x80 picture        ",0
Map_texts_0026a616:
	dc.b	"Map texts            ",0
Chest_data_0026a62c:
	dc.b	"Chest data           ",0
Monster_group_0026a642:
	dc.b	"Monster group        ",0
Merchant_data_0026a658:
	dc.b	"Merchant data        ",0
Combat_background_0026a66e:
	dc.b	"Combat background    ",0
Monster_graphics_0026a684:
	dc.b	"Monster graphics     ",0
Automap_0026a69a:
	dc.b	"Automap              ",0
Object_texts_0026a6b0:
	dc.b	"Object texts         ",0
Event_picture_0026a6c6:
	dc.b	"Event picture        ",0
Layout_0026a6dc:
	dc.b	"Layout               ",0
Music_0026a6f2:
	dc.b	"Music                ",0
Palette_0026a708:
	dc.b	"Palette              ",0
Riddlemouth_graphics_0026a71e:
	dc.b	"Riddlemouth graphics ",0
Dictionary_0026a734:
	dc.b	"Dictionary           ",0
Str_3_d_object_CHIP_0026a74a:
	dc.b	"3D object CHIP       ",0
Str_3_d_overlay_0026a760:
	dc.b	"3D overlay           ",0
Str_3_d_wall_FAST_0026a776:
	dc.b	"3D wall FAST         ",0
Zoom_buffer_0026a78c:
	dc.b	"Zoom buffer          ",0
Str_3_d_object_FAST_0026a7a2:
	dc.b	"3D object FAST       ",0
Saves_0026a7b8:
	dc.b	"Saves                ",0
Party_texts_0026a7ce:
	dc.b	"Party texts          ",0
NPC_texts_0026a7e4:
	dc.b	"NPC texts            ",0
Automap_graphics_0026a7fa:
	dc.b	"Automap graphics     ",0
Place_data_0026a810:
	dc.b	"Place data           ",0
Combat_graphics_0026a826:
	dc.b	"Combat graphics      ",0
Floor_ceiling:
	dc.b	"Floor/ceiling        ",0
Baby_character_0026a852:
	dc.b	"Baby character       ",0
Stationary_graphics_0026a868:
	dc.b	"Stationary graphics  ",0
Party_graphics_0026a87e:
	dc.b	"Party graphics       ",0
Object_graphics_0026a894:
	dc.b	"Object graphics      ",0
File_could_not_be_loaded:
	dc.b	"FILE COULDN'T BE LOADED :",0
Diagnostics_list1:
	dc.b	$31,0
Ptr_26a8c6:
	dc.l	Decompress_end
	dc.b	0,0

	SECTION	Fast_BSS,bss
Kev_buffer:
	ds.l	20
Key_buffer:
	ds.b	2
