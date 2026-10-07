; Loading of texts, item data & resources (1.1x+)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Texts,code

;*****************************************************************************
; [ Check if an item is known to be cursed ]
;   IN : a1 - Pointer to object packet (.l)
;        a2 - Pointer to item data (.l)
;  OUT : ne - Cursed
;        eq - Not cursed (or not identified yet)
; All registers are restored
; NOTE :
;   - FIX: A curse is only revealed once the item has been identified
;     (Magic_check bit in the object packet).
;*****************************************************************************
Check_item_cursed:
	movem.l	d0,-(sp)
	move.b	Item_bits_STATIC(a2),d0
	andi.b	#1,d0
	and.b	Item_bits_DYNAMIC(a1),d0
	tst.b	d0
	movem.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Load all texts from the text file and set the text pointers ]
; NOTE :
;   - Texts are no longer part of the executable. This makes translations
;     possible without changing the program.
;*****************************************************************************
Load_texts:
	moveq.l	#45,d0
	jsr	Load_file
	move.b	d0,d6
	jsr	Claim_pointer
	move.l	d0,a3
	move.w	(a3)+,d5
	move.w	(a3)+,d7
	moveq.l	#0,d0
	add.w	d7,d0
	asl.w	#1,d0
	move.l	a3,a2
	add.l	d0,a3
	lea.l	Text_data,a4
	bra.s	.Skip
.Loop:
	move.l	(a3)+,(a4)+
.Skip:
	dbra	d5,.Loop
	lea.l	Text_addresses,a5
	move.l	#Text_data,d0
	bra.s	.Skip2
.Loop2:
	move.w	d0,d5
	add.w	(a2)+,d0
	move.l	(a5)+,a6
	move.l	d0,(a6)
	move.w	d5,d0
.Skip2:
	dbra	d7,.Loop2
	lea.l	Prompts_ptr,a2
	jsr	Load_text_section
	lea.l	Automap_icon_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Option_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Song_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Spell_class_names_ptr,a2
	jsr	Load_simple_text_section
	jsr	Set_spell_class7_name
	lea.l	Spell_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Language_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Class_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Race_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Skill_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Attribute_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Short_skill_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Short_attr_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Item_type_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	Condition_names_ptr,a2
	jsr	Load_simple_text_section
	lea.l	APR_txt_ptr,a2
	jsr	Load_UI_texts
	moveq.l	#0,d0
	move.b	d6,d0
	jsr	Load_version_texts
	jsr	Free_memory
	rts

;*****************************************************************************
; [ Set the pointers of a text section ]
;   IN : a2 - Pointer to text offsets (.l)
;        a5 - Pointer to list of text pointer addresses (.l)
;*****************************************************************************
Load_text_section:
	move.l	a4,(a2)
	move.w	(a3)+,d7
	move.w	d7,(a4)+
	moveq.l	#0,d0
	bra.s	.Skip
.Loop:
	add.w	(a3),d0
	move.w	(a3)+,(a4)+
.Skip:
	dbra	d7,.Loop
	addq.l	#3,d0
	lsr.w	#2,d0
	bra.s	.Skip2
.Loop2:
	move.l	(a3)+,(a4)+
.Skip2:
	dbra	d0,.Loop2
	rts

;*****************************************************************************
; [ Set the pointers of a simple text section ]
;*****************************************************************************
Load_simple_text_section:
	move.l	a4,(a2)
	move.w	(a3)+,d7
	bra.s	.Skip
.Loop:
	move.l	(a3)+,(a4)+
.Skip:
	dbra	d7,.Loop
	rts

;*****************************************************************************
; [ Set the pointer to the name of spell class 7 ("Magic") ]
;*****************************************************************************
Set_spell_class7_name:
	move.l	Spell_class_names_ptr,a2
	moveq.l	#0,d0
.Loop:
	tst.b	(a2)+
	bne.s	.Loop
	addq.b	#1,d0
	cmpi.b	#6,d0
	bls.s	.Loop
	move.l	a2,Magic_txt_ptr
	rts

;*****************************************************************************
; [ Set the pointers of the user interface texts ]
;*****************************************************************************
Load_UI_texts:
	move.w	(a3)+,d7
	move.l	a4,d0
	moveq.l	#0,d1
	bra.s	.Skip2
.Loop:
	cmpi.b	#-1,(a3)
	beq.s	.Skip
	move.l	d0,(a2)+
	move.w	(a3)+,d2
	add.w	d2,d1
	ext.l	d2
	add.l	d2,d0
	bra.s	.Skip2
.Skip:
	add.l	#4-3,a3
	moveq.l	#0,d2
	move.b	(a3)+,d2
	add.l	d0,d2
	move.l	d2,(a2)+
.Skip2:
	dbra	d7,.Loop
	addq.l	#3,d1
	lsr.w	#2,d1
	bra.s	.Skip3
.Loop2:
	move.l	(a3)+,(a4)+
.Skip3:
	dbra	d1,.Loop2
	rts

;*****************************************************************************
; [ Set the pointers to the version and date/language strings ]
;*****************************************************************************
Load_version_texts:
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.b	(a3)+,d6		; Object count
	move.b	(a3)+,d7		; 160 bytes per icon
	move.l	a4,Version_string1_ptr
	bra.s	.Skip
.Loop:
	move.l	(a3)+,(a4)+
.Skip:
	dbra	d6,.Loop		; A2 now points to the item data
	move.l	a4,Version_string2_ptr
	bra.s	.Skip2		; Copy 3x 20 bytes
.Loop2:
	move.l	(a3)+,(a4)+
.Skip2:
	dbra	d7,.Loop2
	jsr	Free_pointer		; Restore memory handle
	rts

;*****************************************************************************
; [ Copy a block of data ]
;   IN : d0 - Size in bytes (.l)
;        a0 - Source (.l)
;        a1 - Target (.l)
; NOTE (disassembly) :
;   D7: Data size in bytes
;   A2: Source data
;   A3: Destination buffer
;*****************************************************************************
Copy_data:
	movem.l	d6/d7/a2/a3,-(sp)
	move.l	d7,d6
	lsr.l	#2,d6
	bra.s	.Skip
.Loop:
	move.l	(a2)+,(a3)+
.Skip:
	dbra	d6,.Loop
	btst.b	d7,#1
	beq.s	.Skip2
	move.w	(a2)+,(a3)+
.Skip2:
	btst.b	d7,#0
	beq.s	.Exit
	move.b	(a2)+,(a3)+
.Exit:
	movem.l	(sp)+,d6/d7/a2/a3
	rts

Object_icons_disk:
	dc.b	7
	dc.b	"Object_icons",0

Button_graphics_disk:
	dc.b	1
	dc.b	"Button_graphics",0

Last_file_slot_disk:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0

;*****************************************************************************
; [ Load the item data from the object file ]
; NOTE :
;   - Item data is no longer part of the executable (see [ Object_data_ptr ]).
;*****************************************************************************
Load_items:
	moveq.l	#46,d0		; Objects.amb
	jsr	Load_file
	move.b	d0,d5
	jsr	Claim_pointer
	move.l	d0,a2
	move.w	(a2)+,d7
	cmpi.w	#500,d7		; Read item count
	ble.s	.Skip
	move.w	#500,d7		; Limit to 500 items
.Skip:
	lea.l	Item_data,a3
	mulu.w	#60,d7
	jsr	Copy_data
	move.b	d5,d0
	jsr	Free_pointer
	jsr	Free_memory
	move.l	#Item_data,Object_data_ptr
	rts

;*****************************************************************************
; [ Initializations before the program starts ]
;*****************************************************************************
Pre_start_initializations:
	move.l	d3,Blitter_or_CPU		; Set blitter switch passed from
					; loader. Also the loader version.
	rts

;*****************************************************************************
; [ Load the button graphics from file ]
;*****************************************************************************
Load_button_graphics:
	moveq.l	#47,d0
	jsr	Load_file
	move.b	d0,d5
	jsr	Claim_pointer
	move.l	d0,a2
	lea.l	Control_icons,a3
	move.w	#12168,d7		; 78 * 156 bytes
	jsr	Copy_data
	move.b	d5,d0
	jsr	Free_pointer
	jsr	Free_memory
	rts

;*****************************************************************************
; [ Load items and button graphics ]
;*****************************************************************************
Load_resources:
	jsr	Load_items
	jsr	Load_button_graphics
	rts
	dcb.b	8322,0			; (unused space, e.g. for patches)


	SECTION	Text_pointers,data
Text_addresses:
	dc.l	World_map_names,World_name_forest_moon,World_name_morag,Known_error_text
	dc.l	IO_error_message_current_file,Retry_txt_ptr,Disk_request_text,In_any_drive_txt_ptr
	dc.l	Save_disk_request_text,Text_error_text_ptr,Lack_of_memory,Out_of_memory_text_ptr
	dc.l	Divide_start_text_ptr,Divide_inter_text_ptr,Divide_end_text_ptr,Has_no_more_food_txt_ptr
	dc.l	Regains_txt_ptr,Lp_txt_ptr,Regains2_txt_ptr,Lp_and_txt_ptr
	dc.l	Sp_txt_ptr,Has_aged_txt_ptr,Has_died_of_age_txt_ptr,Gp_agree_txt_ptr
	dc.l	Food_price_text,Gp_txt_ptr,Has_reached_level_txt_ptr,Text_txt_ptr
	dc.l	Attacks_txt_ptr,With_the_txt_ptr,Text2_txt_ptr,Attacks2_txt_ptr
	dc.l	Text3_txt_ptr,S_txt_ptr,Was_broken_txt_ptr,Did_txt_ptr
	dc.l	Points_of_damage_txt_ptr,EP_divide_text,Experience_points_txt_ptr,Casts_the_txt_ptr
	dc.l	Spell_txt_ptr,Casts_the2_txt_ptr,Spell_from_the_txt_ptr,Text4_txt_ptr
	dc.l	Is_not_the_right_txt_ptr,That_text_ptr,0
Object_data_ptr:
	dc.l	0
Blitter_or_CPU:
	dc.b	$ff
Loader_version_major:
	dc.b	0		; The loader (Ambermoon exe) passes this in.
Loader_version_minor:
	dc.w	0		; The loader (Ambermoon exe) passes this in.
Blitter_masks:
	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,7,3,1
Blitter_values:
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
World_map_names:
	dc.l	0
World_name_forest_moon:
	dc.l	0
World_name_morag:
	dc.l	0
Savegame_file_infos:
	dc.w	1
S_save00_party_data_sav_00270f52:
	dc.l	Save00_party_data_sav
	dc.w	2
S_save00_party_char_amb_00270f58:
	dc.l	Save00_party_char_amb
	dc.w	$15
	dc.l	Save00_automap_amb
	dc.w	$10
	dc.l	Save00_chest_data_amb
	dc.w	$12
	dc.l	Save00_merchant_data_amb

	SECTION	Font_DATA,data
Glyph_mapping:
	dc.b	$ff,$24,$23,$2c,$ff,$2a,$3a,$22,$28,$29,$26,$2e,$20,$2d,$21,$2b
	dc.b	$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$1f,$1e,$ff,$2f,$ff,$25
	dc.b	$ff,0,1,2,3,4,5,6,7,8,9,$a,$b,$c,$d,$e
	dc.b	$f,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$ff,$ff,$ff,$ff,$27
	dc.b	$ff,0,1,2,3,4,5,6,7,8,9,$a,$b,$c,$d,$e
	dc.b	$f,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$1b,$3c,$3b,$1a,$3b,$ff,$3d,$3c,$ff,$3c,$ff,$ff,$ff,$1a,$ff
	dc.b	$3c,$ff,$ff,$ff,$1c,$ff,$3e,$ff,$ff,$1c,$1b,$3d,$ff,$ff,$1d,$ff
	dc.b	$3b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$3b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$3b,$3b,$ff,$ff,$1a,$ff,$ff,$3d,$3c,$3c,$3c,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$3f,$ff,$1c,$ff,$ff,$ff,$ff,$3e,$1b,$ff,$ff,$1d
	dc.b	$3b,$3b,$3b,$ff,$1a,$ff,$ff,$3d,$3c,$3c,$3c,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$3f,$ff,$1c,$ff,$ff,$ff,$ff,$3e,$1b,$ff,$ff,$ff
Rune_glyph_mapping:
	dc.b	$ff,$24,$23,$2c,$ff,$2a,$3a,$22,$28,$29,$26,$2e,$20,$2d,$21,$2b
	dc.b	$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$1f,$1e,$ff,$2f,$ff,$25
	dc.b	$ff,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e
	dc.b	$4f,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$ff,$ff,$ff,$ff,$27
	dc.b	$ff,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e
	dc.b	$4f,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$5b,$3c,$3b,$5a,$3b,$ff,$3d,$3c,$ff,$3c,$ff,$ff,$ff,$5a,$ff
	dc.b	$3c,$ff,$ff,$ff,$5c,$ff,$3e,$ff,$ff,$5c,$5b,$3d,$ff,$ff,$5d,$ff
	dc.b	$3b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$3b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$7b,$7b,$ff,$ff,$5a,$ff,$ff,$3d,$3c,$3c,$3c,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$3f,$ff,$5c,$ff,$ff,$ff,$ff,$3e,$5b,$ff,$ff,$5d
	dc.b	$3b,$3b,$3b,$ff,$5a,$ff,$ff,$3d,$3c,$3c,$3c,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$3f,$ff,$5c,$ff,$ff,$ff,$ff,$3e,$5b,$ff,$ff,$ff
Glyph_data:
	dc.b	$70,$88,$f8,$88,$88,$f0,$88,$f0,$88,$f0,$78,$88,$80,$80,$78,$f0
	dc.b	$88,$88,$88,$f0,$f8,$80,$c0,$80,$f8,$f8,$80,$f0,$80,$80,$78,$80
	dc.b	$b8,$88,$78,$88,$88,$f8,$88,$88,$70,$20,$20,$20,$70,$f8,8,8
	dc.b	8,$f0,$88,$90,$e0,$90,$88,$80,$80,$80,$80,$f8,$88,$d8,$a8,$88
	dc.b	$88,$88,$c8,$a8,$98,$88,$70,$88,$88,$88,$70,$f0,$88,$f0,$80,$80
	dc.b	$70,$88,$88,$98,$78,$f0,$88,$f0,$88,$88,$78,$80,$70,8,$f0,$f8
	dc.b	$20,$20,$20,$20,$88,$88,$88,$88,$78,$88,$88,$88,$50,$20,$88,$88
	dc.b	$a8,$a8,$50,$88,$50,$20,$50,$88,$88,$88,$78,8,$f0,$f8,$10,$20
	dc.b	$40,$f8,$88,$70,$88,$f8,$88,$88,0,$88,$88,$78,$88,$70,$88,$88
	dc.b	$70,$70,$88,$90,$88,$b0,0,$20,0,$20,$40,0,$20,0,$20,0
	dc.b	0,0,0,$20,$40,0,0,0,0,$40,$20,$40,0,0,0,$28
	dc.b	$50,0,0,0,$40,$40,$40,0,$40,$e0,$10,$60,0,$40,$a8,$70
	dc.b	$f8,$70,$a8,0,0,0,0,$f8,$10,$20,$20,$20,$10,$40,$20,$20
	dc.b	$20,$40,0,$48,$10,$20,$48,8,$10,$20,$40,$80,$50,$f8,$50,$f8
	dc.b	$50,0,0,$70,0,0,0,$20,$70,$20,0,0,$70,0,$70,0
	dc.b	$70,$98,$a8,$c8,$70,$10,$30,$50,$10,$10,$f0,8,$70,$80,$f8,$f0
	dc.b	8,$30,8,$f0,$10,$20,$50,$f8,$10,$f0,$80,$f0,8,$f0,$70,$80
	dc.b	$f0,$88,$70,$f8,$10,$e0,$40,$80,$70,$88,$70,$88,$70,$70,$88,$78
	dc.b	8,$70,$60,$50,$a0,$90,$68,$70,$70,$88,$f8,$88,$70,$f8,$80,$e0
	dc.b	$f8,$78,$88,$80,$78,$10,$20,$d8,$88,$88,$78,$20,$50,$70,$88,$70
	dc.b	$c0,$e0,$f0,$d8,$d8,$e0,$f0,$d8,$f0,$d8,$c0,$c0,$e0,$f0,$d8,$e0
	dc.b	$d0,$e8,$d0,$c8,$d8,$98,$f8,$c8,$d8,$78,$d8,$78,$38,$18,$c8,$f0
	dc.b	$c8,$f0,$c0,$e0,$f0,$18,$f0,$e0,$e0,$c0,$c0,$c0,$e0,$e8,$d0,$c0
	dc.b	$e8,$d0,$c8,$c8,$f8,$f0,$c0,$70,$28,$70,$a0,$70,$f0,$c8,$d0,$c8
	dc.b	$f0,$88,$d8,$70,$20,$70,$d8,$50,$20,$70,$d8,$f0,$d8,$f0,$e0,$c0
	dc.b	$d8,$20,$20,$70,$d8,$20,$70,$a8,$20,$70,$18,$18,$18,$38,$d8,$e0
	dc.b	$f0,$d8,$c0,$c0,$70,$50,$20,$70,$d8,$38,$78,$d8,$78,$d8,$70,$d8
	dc.b	$70,$20,$70,$20,$60,$a8,$30,$20,$c8,$d8,$f8,$d8,$98,$38,$58,$b8
	dc.b	$58,$98,$20,$70,$70,$a8,$a8,$d8,$70,$d8,$70,$d8,$e0,$f0,$d8,$f8
	dc.b	$d8,$18,$38,$58,$38,$18
