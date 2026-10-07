; In-game offsets & constants
; Written by J.Horneman (In Tune With The Universe)
; Start : 24-8-1992

Middle_Y	EQU 36
Valdyn_code	EQU 12
Max_Schnism	EQU 3
Max_spell_duration	EQU 180
Max_options	EQU 5
Minimum_price	EQU 10			; In gold pieces
Party_frames	EQU 3
Camp_time	EQU 8				; In hours
Tired_time	EQU 24
Exhaust_time	EQU 36
Evening_time	EQU 19			; For camping
Morning_time	EQU 4
Dawn_time	EQU 7
Minimum_age	EQU 18			; For Youth spell
Portraits_per_sex	EQU 4			; For Character editor
Game_Over_picture	EQU 9			; For Game Over screen
Game_Over_palette	EQU 38
Gold_icon	EQU 96				; Icon numbers
Food_icon	EQU 109

Max_sparkles	EQU 20			; Sparkles per portrait
Sparkle_speed	EQU 2

Max_saves	EQU 10				; Save data
Save_name_length	EQU 38

Automap_paper_colour	EQU 6
Automap_ink_colour	EQU 7
Automap_window_X	EQU 0
Automap_window_Y	EQU 37
Automap_window_width	EQU 24
Automap_window_height	EQU 18
Automap_pageflip_interval	EQU 5*50

Add_delta	EQU 16
First_add	EQU 256-(10*Add_delta)		; Delay for repeat

Items_per_char	EQU 24
Items_per_chest	EQU 24
Place_data_size	EQU 16*2
Place_string_length	EQU 30
Events_per_map	EQU 64
Max_Goto_points	EQU 256

Combat_damage_interval	EQU 44
Move_speed_factor	EQU 40

Combat_proj_factor	EQU 512			; Combat display constants
Combat_proj_log	EQU 9
Tactic_cell_height	EQU 13
Tactic_X	EQU 96
Tactic_Y	EQU 200-(5*Tactic_cell_height)-1
Combat_X	EQU 0
Combat_Y	EQU 37
Combat_width	EQU 320
Combat_height	EQU 95
Combat_camera_height	EQU 57
Combat_cX	EQU Combat_X+Combat_width/2
Combat_cY	EQU 80
Max_COMOBs	EQU 30
Move_steps	EQU 4
Max_projectiles	EQU 3
Projectile_speed	EQU 30
Projectile_height	EQU 30
Combat_animspeed	EQU 8
Fast_combat_delay	EQU 20
Combat_row_width	EQU 270
Nr_flames	EQU 5
Monster_delay_time	EQU 15

; ---------- 3D constants -------------------------
Horizon_height	EQU 20		; Also defined in 3D object modules !!
C3_raster_colour	EQU 9
Max_3D_VBLs	EQU 13
Fullturn_steps	EQU 8
Dungeon_edge	EQU 120
First_wall	EQU 100+1			; Map byte distribution
Max_3D_walls	EQU 32
Max_3D_objects	EQU 64			; Change [ Max_batch ] !!!
Max_visible_walls	EQU 50
Max_visible_objects	EQU 150			; 38 bytes / object
Objects_per_group	EQU 8

slang	EQU 1024				; Angle positions
proj_faktor	EQU 256
proj_log	EQU 8
planes	EQU 4
patt_size	EQU 512				; Units per map square
psize_log	EQU 9
wall_height	EQU patt_size/3

Max_zoom	EQU 320
Wall_width	EQU 128

Wall_size	EQU 80*8*2*planes

Gold_weight	EQU 5			; Weight of 1 gold coin
Food_weight	EQU 250			; Weight of 1 food unit

M2_movement_speed	EQU 8

; Number of screen updates per animation frame update
C2_animspeed	EQU 4
W2_animspeed	EQU 2
D3_animspeed	EQU 2
C3_animspeed	EQU 2

; Random animation biases (chance = bias / 16)
C2_animbias	EQU 6
W2_animbias	EQU 6
D3_animbias	EQU 6
C3_animbias	EQU 6

; Horizon heights
D3_horizon	EQU 144/3
C3_horizon	EQU 144/2

; Tunes
Camp_music	EQU 21
Fanfare_music	EQU 23
Combat_music	EQU 11
Game_over_music	EQU 32

RM_mouth_speed	EQU 5		; Riddle-mouth mouth animation speed
RM_eyes_speed	EQU 5		; Riddle-mouth eyes animation speed

Max_radius	EQU 120			; Maximum	radius of	night circle

Mapbuf_width	EQU 11			; Dimensions of 2D map buffer
Mapbuf_height	EQU 9
Mapbuf_centreX	EQU 5			; Central position in
Mapbuf_centreY	EQU 4			;  2D map buffer
Mapbuf_size	EQU Mapbuf_width*Mapbuf_height

Map2D_X	EQU 16				; Positions of map windows
Map2D_Y	EQU 49
Map3D_X	EQU 32
Map3D_Y	EQU 49

Doorlock_X	EQU 81				; Lock coordinates
Doorlock_Y	EQU 110
Chestlock_X	EQU 36
Chestlock_Y	EQU 86

BSReq_X	equ 224				; Buy/sell requester icons
BSReq_Y	equ 81-5

Minimap_window_X	EQU 32
Minimap_window_Y	EQU 49+16
Minimap_window_width	EQU 144
Minimap_window_height	EQU 112

ShowPicTxt_Y	EQU 38
ShowPicTxt_height	EQU 92

; Note :
;  - the following coordinates refer to the top-left corner of the INSIDE
;    of the window.
MonKnowW_X	EQU 80				; Monster knowledge
MonKnowW_Y	EQU 54
Chared_X	EQU 48				; Character editor
Chared_Y	EQU 49
OptionsW_X	EQU 64				; Options window
OptionsW_Y	EQU 78
Make_level_X	EQU 32			; Make level window
Make_level_Y	EQU 78
SavedSelW_X	EQU 32			; Saved game selector
SavedSelW_Y	EQU 78
InputNr_X	EQU 80				; Input number
InputNr_Y	EQU 80
TxtW_X	EQU 16				; Text window
TxtW_Y	EQU 52
ReqW_X	EQU 48				; Standard requester
ReqW_Y	EQU 90
SpSelW_X	EQU 48				; Spell selector
SpSelW_Y	EQU 56
MusSelW_X	EQU 32				; Music selector
MusSelW_Y	EQU 50
WSelW_X	EQU 48				; Word selector
WSelW_Y	EQU 50
WordIn_X	EQU 64				; Word input window
WordIn_Y	EQU 100
ItemView1_X	EQU 32			; Item view window 1
ItemView1_Y	EQU 100
ItemView2_X	EQU 48			; Item view window 2
ItemView2_Y	EQU 64
CompassW_X	EQU 64				; Magic compass window
CompassW_Y	EQU 80

Max_classes	EQU 11
Max_races	EQU 15
Max_maps	EQU 1023
Max_chars	EQU 32
Max_transports	EQU 32
Max_mods	EQU 750
Max_underlays	EQU 250
Max_words	EQU 1024
Max_skills	EQU 10
Max_attrs	EQU 8
Max_level	EQU 50
Max_languages	EQU 8
Max_spell_classes	EQU 7
Max_spells	EQU 30
Max_monsters	EQU 18
Max_event	EQU Max_maps*Events_per_map
Max_CD	EQU Max_maps*Max_chars
Max_doors	EQU 255
Max_chests	EQU 255
Max_quest	EQU 8192

Nr_AutoIcons	EQU 13
AutoIcon_interval	EQU 100
Blink_interval	EQU 4
Damage_interval	EQU 10

;           Conditions : FEDCBA9876543210
Alive_mask		EQU %1110010010000000
Dead_mask		EQU %1110000000000000
Heal_mask		EQU %1110000010000000
Inv2_mask		EQU %0000010010001010
Active_mask	EQU %1110010010001110
Talk_mask		EQU %1110010010000000
Healable_mask	EQU %1111111100110010

;           Conditions : FEDCBA9876543210	Combat
Fight_mask		EQU %1110000010000000
Control_mask	EQU %1110010010001110
Damage_mask	EQU %1110010000000000	; Can NOT be damaged
Parade_mask	EQU %1110010101001110	; Combat actions
Attack_mask	EQU %1110010110001100
Move_mask		EQU %1110010110000100
Blink_mask		EQU %1110010010000000
Flee_mask		EQU %1110010110000100
Magic_mask		EQU %1110010010101101
Use_item_mask	EQU %1110010110101110
Reset_mask		EQU %1111111101110010	; To reset combat conditions
Animate_mask	EQU %1110010110000100
End_monster_mask	EQU %0000010100101011

;          Travel-mode : FEDCBA9876543210
Combat_mask	EQU %0000011010011111
Above_mask		EQU %0000000101100000
Poison_mask	EQU %0000001010010011
Clairv_mask	EQU %0000001010011111
Event_mask		EQU %0000011010011111
Swim_mask		EQU %0000000000001100
Stationary_mask	EQU %0000011000001110
Get_off_mask	EQU %0000000011000001
One_or_many_mask	EQU %0000000000000010
Camp_mask		EQU %0000011001011111
Move_exhausted_mask	EQU %0000000001100000

;               Events : 33222222222211111111110000000000
;                        10987654321098765432109876543210
Map_break_mask	EQU %00000000000000000000000000000010
Dia_break_mask	EQU %00000000001000000000100000000010
Map_event_mask	EQU %00000001010110001111111111111110
Dia_event_mask	EQU %00000001111101110111111010001010
Visible_event_mask	EQU %00000000000000000000000100011100
Handable_event_mask	EQU %00000000000000000000000100001100
Talkable_event_mask	EQU %00000000000000000000000100000000
Clear_success_mask	EQU %00000001000000000001100101001100

;     Icon status bits : 11111111111111110000000000000000
;                        FEDCBA9876543210FEDCBA9876543210
NPC_status_mask	EQU %11111100011111111111111110100010
;NPC_status_mask	EQU %00001100011111111111111110100010
Default_icon_bits	EQU %00000000011111111111111100000000
Sit_sleep_mask	EQU %00000011100000000000000000000000

;          Place types : FEDCBA9876543210
Merchant_mask	EQU %0000000010100000

;             Tactic Y : --000000111111222222333333444444
;             Tactic X : --543210543210543210543210543210
Combat_party_mask	EQU %00111111111111000000000000000000
Combat_monster_mask	EQU %00000000111111111111111111111111
Combat_all_mask	EQU %00111111111111111111111111111111

;   Automap icon types :     33222222222211111111110000000000
;                            10987654321098765432109876543210
Automap_wall_mask	EQU %00000000000000000000011000000010
Automap_hidden_mask	EQU %00000000000000000000000001110000

;                Races : FEDCBA9876543210
Special_race_mask	EQU %1111111000000000

;              Classes : FEDCBA9876543210
Special_class_mask	EQU %0000011000000000
Blind_magic_mask	EQU %0000000010000000

;        Spell classes : 76543210
Spell_class_mask	EQU %01001111

;               Spells : 33222222222211111111110000000000
;                        10987654321098765432109876543210
Monsterspell_1_mask EQU %00110000000000000000000001000000
Monsterspell_3_mask EQU %01111111111111111111111111111110
Max_monster_spells	EQU 33

;     Combat target select modes : 76543210
Targmode_invert		EQU %00101010

;           Item types : 33222222222211111111110000000000
;                        10987654321098765432109876543210
Attacker_break_mask	EQU %00000000000000101000000001100000
Parader_break_mask	EQU %00000000000000101000000001110000
Defender_break_mask	EQU %00000000000000000000000000000010

Cont	EQU 1<<14

;*****************************************************************************
; These are the Amberfile types
	rsreset
	rs.b 1			; Memory block (NOT A FILE)
Party_data_file:	rs.b 1
Party_char_file:	rs.b 1
NPC_char_file:	rs.b 1
Monster_char_file:	rs.b 1
Portraits_file:	rs.b 1
Map_data_file:	rs.b 1
Icon_data_file:	rs.b 1
Icon_gfx_file:	rs.b 1
Trans_gfx_file:	rs.b 1
NPC_gfx_file:	rs.b 1
Lab_data_file:	rs.b 1
Wall_3D_CHIP_file:	rs.b 1
Lab_background_file:	rs.b 1
Pic80x80_file:	rs.b 1
Map_text_file:	rs.b 1
Chest_data_file:	rs.b 1
Monster_data_file:	rs.b 1
Merchant_data_file:	rs.b 1
Combat_background_file:	rs.b 1
Monster_gfx_file:	rs.b 1
Automap_file:	rs.b 1
Object_texts_file:	rs.b 1
Event_pix_file:	rs.b 1
Layout_file:	rs.b 1
Music_file:	rs.b 1
Palette_file:	rs.b 1
RM_gfx_file:	rs.b 1
Dictionary_file:	rs.b 1
Object_3D_CHIP_file:	rs.b 1
Overlay_3D_file:	rs.b 1
Wall_3D_FAST_file:	rs.b 1
Zoombuffer_file:	rs.b 1
Object_3D_FAST_file:	rs.b 1
Saves_file:	rs.b 1
Party_text_file:	rs.b 1
NPC_text_file:	rs.b 1
Automap_gfx_file:	rs.b 1
Place_data_file:	rs.b 1
Combat_gfx_file:	rs.b 1
Floor_file:	rs.b 1
Baby_char_file:	rs.b 1
Stationary_file:	rs.b 1
Party_gfx_file:	rs.b 1
Object_gfx_file:	rs.b 1
Max_file_type:      rs.b 0

;*****************************************************************************
; These are the offsets for the magic sparkles
	rsreset
Sparkle_X:	rs.b 1				; 0-31
Sparkle_Y:	rs.b 1				; 1-34
Sparkle_frame:	rs.b 1			; 0 / 1-4
Sparkle_data_size:	rs.b 0

;*****************************************************************************
; These are the bit array types
	rsreset
Quest_bit_array:	rs.b 1
Chest_bit_array:	rs.b 1
Door_bit_array:	rs.b 1
CD_bit_array:	rs.b 1
Event_bit_array:	rs.b 1
WD_bit_array:	rs.b 1
New_words_bit_array:	rs.b 1
Goto_point_bit_array:	rs.b 1
Max_bit_array:	rs.b 0

;*****************************************************************************
; These are the layouts
	rsreset
	rs.b 1
Map2D_layout:	rs.b 1
Inv2_layout:	rs.b 1
Chest_layout:	rs.b 1
Combat_layout:	rs.b 1
Map3D_layout:	rs.b 1
Inv1_layout:	rs.b 1
ShowPicTxt_layout:	rs.b 1
Dialogue_layout:	rs.b 1
Riddlemouth_layout:	rs.b 1
Battle_order_layout:	rs.b 1
Automap_layout:	rs.b 1
Max_layouts:	rs.b 0

;*****************************************************************************
; These are the internal flags
	rsreset
Music_flag_bit:	rs.b 1
Fast_combat_bit:	rs.b 1
Outline_text_bit:	rs.b 1
Dungeon_floor_bit:	rs.b 1
Dungeon_ceiling_bit:	rs.b 1
	rs.b 10
Fuck_bit:	rs.b 1

;*****************************************************************************
; These are the module IDs
	rsreset
	rs.b 1				; No ID
C2Map_ID:	rs.b 1
W2Map_ID:	rs.b 1
M3Map_ID:	rs.b 1
Inv1_ID:	rs.b 1
Inv2_ID:	rs.b 1
BattleOrder_ID:	rs.b 1
Camp_ID:	rs.b 1
Options_ID:	rs.b 1
Door_ID:	rs.b 1
RiddleM_ID:	rs.b 1
ClosedChest_ID:	rs.b 1
OpenedChest_ID:	rs.b 1
Dialogue_ID:	rs.b 1
Trainer_ID:	rs.b 1
Healer_ID:	rs.b 1
Sage_ID:	rs.b 1
Enchanter_ID:	rs.b 1
Inn_ID:	rs.b 1
MerchOBJC_ID:	rs.b 1
MerchFOOD_ID:	rs.b 1
MerchMAGIC_ID:	rs.b 1
MerchTRANS_ID:	rs.b 1
Blacksmith_ID:	rs.b 1
Automap_ID:	rs.b 1
Combat_ID:	rs.b 1
Apres_ID:	rs.b 1
ShowPicTxt_ID:	rs.b 1

;*****************************************************************************
; These are the map types
	rsreset
City_2D:	rs.b 1
World_2D:	rs.b 1
Map_3D:	rs.b 0
Dungeon_3D:	rs.b 1
City_3D:	rs.b 1

;*****************************************************************************
; These are the offsets for the Control Icon Lists
	rsreset
	rs.w 9
Icon_vectors:	rs.l 9
Reeval_ptr:	rs.l 1

;*****************************************************************************
; These are the offsets for the transportations
	rsreset
Trans_type:	rs.b 1
Trans_X:	rs.b 1
Trans_Y:	rs.b 1
	rseven
Trans_map_nr:	rs.w 1
Trans_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the modifications
	rsreset
Modif_map_nr:	rs.w 1
Modif_X:	rs.b 1
Modif_Y:	rs.b 1
Modif_icon:	rs.w 1
Modif_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the object packets
	rsreset
Quantity:	rs.b 1				; Quantity
Charges:	rs.b 1				; Magical	charges  (-1 = infinite)
Enchantment_normal:	rs.b 1
Item_bits_DYNAMIC:	rs.b 1
Object_index:	rs.w 1
Object_packet_size:	rs.b 0

Copy_packet	macro
	move.l	(\1),(\2)			; Assumes size is 6 !!!
	move.w	4(\1),4(\2)
	endm

;*****************************************************************************
; These are the offsets for the spell data
	rsreset
Spell_area_bits:	rs.b 1
Spell_point_cost:	rs.b 1
Spell_learn_point_cost:	rs.b 1
Spell_target_bits:	rs.b 1
Spell_type_bits:	rs.b 1
Spell_data_size:	rs.b 0

;*****************************************************************************
; These are the spell selector codes
	rsreset
Spell_OK:	rs.b 1
Spell_wrong_area:	rs.b 1
Spell_wrong_world:	rs.b 1
Spell_not_enough_SP:	rs.b 1

;*****************************************************************************
; These are the spell target bits
	rsreset
Single_target_bit:	rs.b 1
	rs.b 5
Item_target_bit:	rs.b 1
Special_target_bit:	rs.b 1

;*****************************************************************************
; These are the spell areas
	rsreset
Wilderness_spell_area:	rs.b 1
City_spell_area:	rs.b 1
Dungeon_spell_area:	rs.b 1
Camp_spell_area:	rs.b 1
Combat_spell_area:	rs.b 1

;*****************************************************************************
; These are the map special bits
	rsreset
Light_bit:	rs.b 1
Change_bit:	rs.b 1
Dark_bit:	rs.b 1
View_map_bit:	rs.b 1

Camp_bit:	rs.b 1
Wilderness_bit:	rs.b 1
City_bit:	rs.b 1
Dungeon_bit:	rs.b 1

Show_trans_bit:	rs.b 1
Secret_submarine_bit:	rs.b 1
World_map_bit:	rs.b 1
Magic_bit:	rs.b 1

;*****************************************************************************
; These are the offsets for the chest data
	rsreset
	rs.b Items_per_chest*Object_packet_size
Chest_gold:	rs.w 1
Chest_food:	rs.w 1
Chest_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the shadow party data
	rsreset
	rs.b 1
Shadow_icon:	rs.b 1
Shadow_LP:	rs.b 1
Shadow_PP:	rs.b 1
Shadow_data_size:	rs.b 0			; DO NOT CHANGE !

;*****************************************************************************
; These are the offsets for attribute/skill values
	rsreset
	rs.w 1			; Normal
Maximum:	rs.w 1
Magic:	rs.w 1
Backup:	rs.w 1
Skill_data_size:	rs.b 0
Attr_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the character data
	rsreset
Char_type:	rs.b 1			; 0 = Party, 1 = NPC, 2 = Monster
Char_sex:	rs.b 1			; 0 = Male, 1 = Female
Char_race:	rs.b 1
Char_class:	rs.b 1
Spell_class_counter:	rs.b 1
Level_nr:	rs.b 1
Hands_occupied:	rs.b 1
Ringfingers_occupied:	rs.b 1
Learned_languages:	rs.b 1
Secret_inventory:	rs.b 1		; x Will not show or accept anything
Portrait_nr:	rs.b 1
	rs.b 1			; x
Monster_picture_load_nr:	rs.b 1
	rs.b 1			; x
	rs.b 1			; x
Courage:	rs.b 1
Spell_class_immunity:	rs.b 1	; x
Attacks_per_round:	rs.b 1
Monster_type_status:	rs.b 1	; ???
Spell_type_immunity:	rs.b 1	; x

Nr_spell_learn_points:	rs.w 1
Nr_training_points:	rs.w 1
Gold_coins:	rs.w 1
Food_rations:	rs.w 1
Person_save_bit_pos:	rs.w 1
Body_conditions:	rs.w 1
Battle_experience:	rs.w 1
Battle_round_power_point_usage:	rs.w 1	; x
Recall_data:	rs.w 3			; x X, Y, Map number

; --------- Attributes ----------------------------
Attributes:	rs.b 0
AStrength:	rs.w 4				; Magic adds to normal
AIntelligence:	rs.w 4
ADexterity:	rs.w 4
ASpeed:	rs.w 4
AConstitution:	rs.w 4
ACharisma:	rs.w 4
ALuck:	rs.w 4
AAnti_magic:	rs.w 4
AAge:	rs.w 4
	rs.w 4

; --------- Skills --------------------------------
Skills:	rs.b 0
SAttack:	rs.w 4				; Magic adds to normal
SParade:	rs.w 4
SSwimming:	rs.w 4
SCritical_hit:	rs.w 4
SFind_traps:	rs.w 4
SDisarm_traps:	rs.w 4
SPick_locks:	rs.w 4
SSearch:	rs.w 4
SRead_scrolls:	rs.w 4
SUse_magic:	rs.w 4

Life_points:	rs.w 3			; Magic adds to maximum
Power_points:	rs.w 3
Protection:	rs.w 1
Protection_magic:	rs.w 1
Damage:	rs.w 1
Damage_magic:	rs.w 1
Magic_bonus_weapon:	rs.w 1
Magic_bonus_armour:	rs.w 1

Special_1:	rs.w 1				; Attacks per round
Special_2:	rs.w 1				; Life-points
Special_3:	rs.w 1				; Power-points
Special_4:	rs.w 1				; Spell learn points
Special_5:	rs.w 1				; Training points

Description_text_nr:	rs.w 1		; -1 = no text

Experience_points:	rs.l 1
Spells_class_0:	rs.l 1
Spells_class_1:	rs.l 1
Spells_class_2:	rs.l 1
Spells_class_3:	rs.l 1
Spells_class_4:	rs.l 1
Spells_class_5:	rs.l 1
Spells_class_6:	rs.l 1
Weight_normal:	rs.l 1

Char_name:	rs.b 15
	rs.b 1
Char_data_size:	rs.b 0

;*****************************************************************************
; These are the monster type bits (-> Monster_type_status)
	rsreset
Undead_type:	rs.b 1
		rs.b 1			; (Demon)
End_monster_type:	rs.b 1
Animal_type:	rs.b 1

;*****************************************************************************
; These are the offsets for the dialogue data
	rsreset
Nr_actions:	rs.w 1
Action_entry_list:	rs.b 0

;*****************************************************************************
; These are the offsets for the PARTY character data
	rsreset
	rs.b Char_data_size
Char_inventory:	rs.b (9+Items_per_char)*Object_packet_size
Char_dialogue:	rs.b 0

;*****************************************************************************
; These are the offsets for the NPC character data
	rsreset
	rs.b Char_data_size
NPC_dialogue:	rs.b 0

;*****************************************************************************
; These are the offsets for the MONSTER character data
	rsreset
	rs.b Char_data_size
	rs.b (9+Items_per_char)*Object_packet_size
Clone_data_size:	rs.b 0

Anim_dat:	rs.b 256				; Animation sequences
Anim_frame:	rs.b 8			; Animation lengths
Atari_recol:	rs.b 16			; Recolour tables
Amiga_recol:	rs.b 32
Anim_motion:	rs.b 1			; Circle / wave bits
	rseven
Monster_width:	rs.w 1
Monster_height:	rs.w 1
Monster_display_width:	rs.w 1
Monster_display_height:	rs.w 1

;*****************************************************************************
; These are the constant world time values

Months_per_year	EQU 12
Days_per_month	EQU 30
Hours_per_day	EQU 24
Minutes_per_hour	EQU 60
Minutes_per_step	EQU 5
VBLs_per_step	EQU 500			; (10 seconds on 50	Hz)
Moves_per_step	EQU 4

Max_steps	= Hours_per_day*(Minutes_per_hour/Minutes_per_step)

;*****************************************************************************
; These are the map exit event types
	rsreset
Normal_MX_type:	rs.b 1
Teleporter_MX_type:	rs.b 1
Windgate_MX_type:	rs.b 1
Trapdoor_up_MX_type:	rs.b 1
End_seq_MX_type:	rs.b 1
Trapdoor_down_MX_type:	rs.b 1

;*****************************************************************************
; These are the query/modify event types
	rsreset
Quest_QM_type:	rs.b 1
Event_QM_type:	rs.b 1
Door_QM_type:	rs.b 1
Chest_QM_type:	rs.b 1
CD_QM_type:	rs.b 1
Party_QM_type:	rs.b 1
Item_carried_QM_type:	rs.b 1
Item_used_QM_type:	rs.b 1
Word_QM_type:	rs.b 1
Success_QM_type:	rs.b 1
Internal_QM_type:	rs.b 1
Light_QM_type:	rs.b 1
Direction_QM_type:	rs.b 1
Condition_QM_type:	rs.b 1
Touched_QM_type:	rs.b 1
Word_spoken_QM_type:	rs.b 1
Alien_nr_QM_type:	rs.b 1
Levitate_QM_type:	rs.b 1
Gold_QM_type:	rs.b 1
Food_QM_type:	rs.b 1
Seen_QM_type:	rs.b 1
Max_QM_type:	rs.b 0

;*****************************************************************************
; These are the event types
	rsreset
	rs.b 1
Map_exit_type:	rs.b 1		;	Map	Dia	Break
Door_type:	rs.b 1			; Success	Map
Item_found_type:	rs.b 1		; Success	Map	Dia
Show_pictxt_type:	rs.b 1		;	Map
Spinner_type:	rs.b 1		;	Map

Trap_type:	rs.b 1			; Success	Map
Anti_magic_type:	rs.b 1		;	Map	Dia	Cont
Riddle_mouth_type:	rs.b 1		; Success	Map
Datachange_type:	rs.b 1		;	Map	Dia	Cont
Change_icon_type:	rs.b 1		;	Map	Dia	Cont

Encounter_type:	rs.b 1		; Success	Map	Dia	Break
Places_type:	rs.b 1		;	Map	Dia	Cont
Query_type:	rs.b 1		;	Map	Dia	Cont
Modify_type:	rs.b 1		;	Map	Dia	Cont
Chance_type:	rs.b 1		;	Map

Dia_action_type:	rs.b 1		;		Dia	Cont
Dia_text_type:	rs.b 1		;		Dia	Cont
Dia_give_type:	rs.b 1		;		Dia	Cont
Requester_type:	rs.b 1		;	Map
Sound_type:	rs.b 1		;	Map	Dia	Cont

Dia_end_type:	rs.b 1		;		Dia	Break
Create_trans_type:	rs.b 1		;	Map	Dia	Cont
Dia_execute_type:	rs.b 1		;		Dia	Cont
Remove_member_type:	rs.b 1		;	Map	Dia	Cont

Max_events:         rs.b 0

;*****************************************************************************
; These are the travel-modes
	rsreset
On_foot:	rs.b 1
Horse:	rs.b 1
Raft:	rs.b 1
Ship:	rs.b 1
Magic_disc:	rs.b 1
Giant_eagle:	rs.b 1
Super_chicken:	rs.b 1
Swimming:	rs.b 1
Broom_stick:	rs.b 1
Sandcrawler:	rs.b 1
Sandskimmer:	rs.b 1
Max_travelmodes:	rs.b 0

;*****************************************************************************
; These are the status icons
	rsreset
	rs.b 1
Dead_icon:	rs.b 1
Closerange_icon:	rs.b 1
Parade_icon:	rs.b 1
Magic_icon:	rs.b 1
Flee_icon:	rs.b 1
Move_icon:	rs.b 1
Objectmagic_icon:	rs.b 1
Refuse_icon:	rs.b 1
Accept_icon:	rs.b 1
Lamed_icon:	rs.b 1
Poisoned_icon:	rs.b 1
Petrified_icon:	rs.b 1
Diseased_icon:	rs.b 1
Aging_icon:	rs.b 1
Irritated_icon:	rs.b 1
Mad_icon:	rs.b 1
Asleep_icon:	rs.b 1
Panicked_icon:	rs.b 1
Blind_icon:	rs.b 1
Overweight_icon:	rs.b 1
Stoned_icon:	rs.b 1
Exhausted_icon:	rs.b 1
Longrange_icon:	rs.b 1

;*****************************************************************************
; These are the special item flags
	rsreset
Compass_bit:	rs.b 1
Eye_bit:	rs.b 1
Daynight_bit:	rs.b 1
Windchain_bit:	rs.b 1
Coords_bit:	rs.b 1
Clock_bit:	rs.b 1

;*****************************************************************************
; These are the body & mind conditions
	rsreset
Irritated:	rs.b 1			; 0
Mad:	rs.b 1			; 1
Asleep:	rs.b 1			; 2
Panicked:	rs.b 1			; 3
Blind:	rs.b 1			; 4
Stoned:	rs.b 1			; 5
Exhausted:	rs.b 1			; 6
Fleeing:	rs.b 1			; 7

Lamed:	rs.b 1			; 8
Poisoned:	rs.b 1			; 9
Petrified:	rs.b 1			; A
Diseased:	rs.b 1			; B
Aging:	rs.b 1			; C
Dead:	rs.b 1			; D
Ashes:	rs.b 1			; E
Dust:	rs.b 1			; F

;*****************************************************************************
; These are the offsets for the event data
	rsreset
	rs.b 1				; Event type
Event_b1:		rs.b 1			; Byte data
Event_b2:		rs.b 1
Event_b3:		rs.b 1
Event_b4:		rs.b 1
Event_b5:		rs.b 1
Event_w6:		rs.w 1			; Word data
Event_w8:		rs.w 1
Next_event_nr:	rs.w 1			; Number of next event in chain
Event_data_size:    rs.b 0

;*****************************************************************************
; These are the offsets for the Goto-point data
	rsreset
Goto_X:	rs.b 1				; X-coordinate
Goto_Y:	rs.b 1				; Y-coordinate
Goto_viewdir:	rs.b 1			; View direction
Goto_bit_nr:	rs.b 1			; Save bit number
Goto_text:	rs.b 15				; Text
	rs.b 1				;  + EOL
Goto_pnt_data_size: rs.b 0

;*****************************************************************************
; These are the NPC types
	rsreset
Party_type:	rs.b 1
NPC_type:	rs.b 1
Monster_type:	rs.b 1
Object_type:	rs.b 1

;*****************************************************************************
; These are the offsets for the NPC data
	rsreset
NPC_char_nr:	rs.b 1		; Triples as short text number
				;  & monstergroup number
NPC_travel_mode:	rs.b 1
NPC_status_bits:	rs.b 1		; bit 0/1 : NPC type :
				;	0 - Party
				;	1 - NPC
				;	2 - Monster
				;	3 - Object
				; bit 2 : Movement type :
				; Party / NPC :
				;	0 - Path
				;	1 - Random
				; Monster / Object :
				;	0 - Stationary
				;	1 - Chasing
				; bit 3 : NPC / map graphics
				; bit 4 : Normal / short dialogue
NPC_event_nr:	rs.b 1
NPC_icon_nr:	rs.w 1
NPC_icon_status:	rs.l 1
NPC_data_size:      rs.b 0

;*****************************************************************************
; These are the offsets for the virtual character data
	rsreset
	rs.b NPC_data_size
VMap_X:	rs.w 1			; Map coordinates
VMap_Y:	rs.w 1
VSource_X:	rs.w 1			; Dungeon coordinates
VSource_Y:	rs.w 1
VTarget_X:	rs.w 1			; Map coordinates
VTarget_Y:	rs.w 1
VFlags:	rs.b 1			; Internal flags
	rseven
VPath_ptr:	rs.l 1			; Offset to path (if necessary)
VDir:	rs.w 1			; Current direction
VPathlen:	rs.w 1			; Remaining length of random path
VNPC_data_size:       rs.b 0

	rsreset
Movement_ended:	rs.b 1
NPC_collided:	rs.b 1
Moving_randomly:	rs.b 1
NPC_sleeping:	rs.b 1
NPC_blocks:	rs.b 1

;*****************************************************************************
; These are the offsets for the world data
	rsreset
	rs.w 7
World_data_size:    rs.b 0

;*****************************************************************************
; These are the offsets for the object data
	rsreset
Item_pic:	rs.b 1
Item_type:	rs.b 1
Item_body_place:	rs.b 1
Item_break:	rs.b 1
Sex_use:	rs.b 1
Hand_use:	rs.b 1
Ring_use:	rs.b 1
LP_max:	rs.b 1
SP_max:	rs.b 1
Attribute:	rs.b 1
Attribute_normal:	rs.b 1
Skill:	rs.b 1
Skill_normal:	rs.b 1
Protection_pts:	rs.b 1
Damage_pts:	rs.b 1
Ammo_ID:	rs.b 1
Ammo_use_ID:	rs.b 1
Item_skill_1:	rs.b 1
Item_skill_2:	rs.b 1
Malus_1:	rs.b 1
Malus_2:	rs.b 1
Misc_1:	rs.b 1
Misc_2:	rs.b 1
Spell_class:	rs.b 1
Spell_number:	rs.b 1
Spell_charges:	rs.b 1			; Initial value
Enchantment_normal_init:	rs.b 1		; Initial value
Enchantment_max:	rs.b 1			; Maximum enchantments
Enchantment_charge_max:	rs.b 1		; Maximum spell charges
Enchantment_charge_price:	rs.b 1		; Price per charge
Armour_magic_bonus:	rs.b 1
Weapon_magic_bonus:	rs.b 1
Item_bits_STATIC:	rs.b 1
Item_bits_DYNAMIC_init:	rs.b 1
Class_use:	rs.w 1
Price:	rs.w 1
Weight:	rs.w 1
Item_name:	rs.b 19
	rs.b 1
Item_data_size:	rs.b 0

;*****************************************************************************
; These are the STATIC object bits
	rsreset
Cursed:	rs.b 1
Droppable:	rs.b 1
Multiple:	rs.b 1
Combat_equip:	rs.b 1
Destroy_after_use:	rs.b 1
Unbreakable:	rs.b 1
Duplicatable:	rs.b 1

;*****************************************************************************
; These are the DYNAMIC object bits
	rsreset
Magic_check:	rs.b 1
Broken_item:	rs.b 1

;*****************************************************************************
; These are the offsets for the map data files
	rsreset
Map_special:	rs.w 1		; Map status bits
Map_type:	rs.b 1			; = 1 or 2
Map_music:	rs.b 1
Map_width:	rs.b 1
Map_height:	rs.b 1
Icondat_filenr:	rs.b 1		; Number of used ICON_DAT/ICON_GFX
				;  file (2D) or LAB_DATA file (3D)
Npcgfx_filenr:	rs.b 1
Background_filenr:	rs.b 1
Colourpal_filenr:	rs.b 1
World_number:	rs.b 1
	rseven
NPC_data:	rs.b Max_chars*NPC_data_size

Map_data: rs.b 0

; *** Map	layers ***

; Repeated [width x height] times :

; (2D)
;	0 b Underlay
;	1 b Event
;	2 w Overlay
; (3D)
;	0 b Map
;	1 b Event

; *** Event entry list ***

; Number of event entries : w
; Repeated {Number of event entries} times :
;	    0 w - Number of first event in chain (0-65535)

; *** Event data ***

; Number of events : w
; Repeated {Number of events}	times
;	    0 ? - Event data block

; *** NPC	path/position data

; Repeated {Max_chars} times :

; Nothing	/ Position (x,y) / Path (x,y) x Max_steps

; *** Goto-point data ***

; Number of Goto-points : w
; Repeated {Number of Goto-points} times :
;	   0  b - X-coordinate
;	   1  b - Y-coordinate
;	   2  b - View direction
;	   3  b - Bit numner
;	   4 15 - Goto point name
;	  19  b - EOL

; *** 3D event automapper icons ***

; Repeated {Number of event entries} times :
;	    0 b -	Number of	automapper icon

;*****************************************************************************
; These are the offsets for the quad maps
	rsreset
Quad_map_handle:	rs.b 1
Quad_maptext_handle:	rs.b 1
	even
Quad_mapnr:	rs.w 1
Quad_mapsize: 	rs.b 0

;*****************************************************************************
; These are the offsets for the 2D icon data
	rsreset
Icon_bits:	rs.l 1
Icon_1st_frame:	rs.w 1
Icon_nr_frames:	rs.b 1
Icon_minimap_colour:	rs.b 1

;*****************************************************************************
; These are the bits of the 2D icon data
	rsreset
Circle_wave_bit:	rs.b 1
Vision_blocked_bit:	rs.b 1
Underlay_bit:	rs.b 1
Distort_bit:	rs.b 0	 		; 3D object only !!!
Transparent_wall_bit:	rs.b 1 		; 3D wall only !!!
Random_anim_bit:	rs.b 1
Underlay_priority_bit:	rs.b 1
Overlay_in_sky_bit:	rs.b 1

Way_blocked_bit:	rs.b 1
Blocked_foot_bit:	rs.b 1
Blocked_horse_bit:	rs.b 1
Blocked_raft_bit:	rs.b 1
Blocked_ship_bit:	rs.b 1
Blocked_magic_disc_bit:	rs.b 1
Blocked_giant_eagle_bit:	rs.b 1
	rs.b 1
Blocked_swimming_bit:	rs.b 1
Blocked_broom_bit:	rs.b 1
Blocked_crawler_bit:	rs.b 1
Blocked_skimmer_bit:	rs.b 1
	rs.b 4				; (Possible travel-modes)
Sit_sleep_bits:	rs.b 3
Party_invisible_bit:	rs.b 1
Poison_field_bit:	rs.b 1
Combat_back_nr_bit:	rs.b 4

;*****************************************************************************
; These are the sit/sleep states
	rsreset
Standing:	rs.b 1
Sitting_north:	rs.b 1
Sitting_east:	rs.b 1
Sitting_south:	rs.b 1
Sitting_west:	rs.b 1
Sleeping:	rs.b 1

;*****************************************************************************
; These are the control icons
	rsreset
	rs.b 1
Turnleft_3D_cicon:	rs.b 1
Forward_3D_cicon:	rs.b 1
Turnright_3D_cicon:	rs.b 1
Left_3D_cicon:	rs.b 1
Right_3D_cicon:	rs.b 1
Turn180_left_cicon:	rs.b 1
Back_3D_cicon:	rs.b 1
Turn180_right_cicon:	rs.b 1
Upleft_2D_cicon:	rs.b 1
Up_2D_cicon:	rs.b 1
Upright_2D_cicon:	rs.b 1
Left_2D_cicon:	rs.b 1
Right_2D_cicon:	rs.b 1
Downleft_2D_cicon:	rs.b 1
Down_2D_cicon:	rs.b 1
Downright_2D_cicon:	rs.b 1
Look_cicon:	rs.b 1
Hand_cicon:	rs.b 1
Talk_cicon:	rs.b 1
Change_trans_cicon:	rs.b 1
Use_magic_cicon:	rs.b 1
Camp_cicon:	rs.b 1
Automapper_cicon:	rs.b 1
Combat_pos_cicon:	rs.b 1
Disk_cicon:	rs.b 1
Empty_cicon:	rs.b 1
Yes_cicon:	rs.b 1
No_cicon:	rs.b 1
OK_cicon:	rs.b 1
Exit_cicon:	rs.b 1
Buy_horse_cicon:	rs.b 1
Buy_raft_cicon:	rs.b 1
Buy_ship_cicon:	rs.b 1
Buy_item_cicon:	rs.b 1
Buy_food_cicon:	rs.b 1
Sell_item_cicon:	rs.b 1
Repair_item_cicon:	rs.b 1
Enchant_item_cicon:	rs.b 1
Heal_condition_cicon:	rs.b 1
Heal_LP_cicon:	rs.b 1
Heal_cursed_items_cicon:	rs.b 1
Train_skill_cicon:	rs.b 1
Body_items_cicon:	rs.b 1
Give_item_cicon:	rs.b 1
Give_food_cicon:	rs.b 1
Give_gold_cicon:	rs.b 1
Join_party_cicon:	rs.b 1
Leave_party_cicon:	rs.b 1
Attack_cicon:	rs.b 1
Parade_cicon:	rs.b 1
Flee_cicon:	rs.b 1
Stats_cicon:	rs.b 1
Backpack_cicon:	rs.b 1
Use_item_cicon:	rs.b 1
View_item_cicon:	rs.b 1
Transfer_gold_cicon:	rs.b 1
Transfer_food_cicon:	rs.b 1
Drop_item_cicon:	rs.b 1
Drop_gold_cicon:	rs.b 1
Drop_food_cicon:	rs.b 1
Drop_item_chest_cicon:	rs.b 1
Drop_gold_chest_cicon:	rs.b 1
Drop_food_chest_cicon:	rs.b 1
Pick_lock_cicon:	rs.b 1
Find_traps_cicon:	rs.b 1
Disarm_traps_cicon:	rs.b 1
Divide_food_cicon:	rs.b 1
Divide_gold_cicon:	rs.b 1
Zzz_cicon:	rs.b 1
Listen_cicon:	rs.b 1
Read_scroll_cicon:	rs.b 1
Hourglass_cicon:	rs.b 1
Save_cicon:	rs.b 1
Load_cicon:	rs.b 1
Quit_cicon:	rs.b 1
Options_window_cicon:	rs.b 1
Male_cicon:	rs.b 1
Female_cicon:	rs.b 1

;*****************************************************************************
; These are the offsets for the scroll bar data
	rsreset
Total_units:	rs.w 1		; Total amount of units
Units_width:	rs.w 1		; Number of units per row
Units_height:	rs.w 1		; Number of rows on screen
Scroll_bar_height:	rs.w 1		; Height of scroll bar
Scroll_bar_X:	rs.w 1		; Top-left position of scroll bar
Scroll_bar_Y:	rs.w 1
Scroll_bar_update_ptr:	rs.l 1	; Pointer to update routine

	; *** Initialized by [Init_scroll_bar] : ***
Scroll_thingy_height:	rs.w 1	; Height of thingy
Scroll_thingy_Y:	rs.w 1		; Y-coordinate of thingy
Row_height:	rs.w 1		; Height of row in pixels
Current_row:	rs.w 1		; Current row
Scroll_bar_max_height:	rs.w 1	; Maximum Y-coordinate of thingy
Scroll_bar_data_size:	rs.b 0

Scroll_bar_extra_data	EQU Scroll_bar_data_size-Scroll_thingy_height

;*****************************************************************************
; These are the 80 x 80 pictures
	rsreset
	rs.b 1
Closed_chest_pic:	rs.b 1
Door_pic:	rs.b 1
Empty_chest_pic:	rs.b 1
Enchantress_pic:	rs.b 1
Healer_pic:	rs.b 1
Horse_merchant_pic:	rs.b 1
Inn_pic:	rs.b 1
Librarian_pic:	rs.b 1
Magic_trainer_pic:	rs.b 1
Object_merchant_pic:	rs.b 1
Opened_chest_pic:	rs.b 1
Sage_pic:	rs.b 1
Ship_merchant_pic:	rs.b 1
Thief_trainer_pic:	rs.b 1
Trashpile_pic:	rs.b 1
Warrior_trainer_pic:	rs.b 1
Riddlemouth_pic:	rs.b 1
Camp_inn_pic:	rs.b 1
Camp_dungeon_pic:	rs.b 1
Camp_wilderness_pic:	rs.b 1
Desert_merchant_pic:	rs.b 1
Forest_merchant_pic:	rs.b 1

;*****************************************************************************
; These are the object types
	rsreset
	rs.b 1
Armour_itemtype:	rs.b 1
Helmet_itemtype:	rs.b 1
Shoe_itemtype:	rs.b 1
Shield_itemtype:	rs.b 1

Closerange_itemtype:	rs.b 1
Longrange_itemtype:	rs.b 1
Ammo_itemtype:	rs.b 1
Textscroll_itemtype:	rs.b 1
Spellscroll_itemtype:	rs.b 1

Drink_itemtype:	rs.b 1
Amulet_itemtype:	rs.b 1
Brooch_itemtype:	rs.b 1
Ring_itemtype:	rs.b 1
Valuable_itemtype:	rs.b 1

Tool_itemtype:	rs.b 1
Key_itemtype:	rs.b 1
Normal_itemtype:	rs.b 1
Magic_itemtype:	rs.b 1
Special_itemtype:	rs.b 1

Transport_itemtype:	rs.b 1
	rs.b 1				; Condition

;*****************************************************************************
; These are the body inventory slot offsets
	rsreset
Neck_slot:	rs.b Object_packet_size
Head_slot:	rs.b Object_packet_size
Chest_slot:	rs.b Object_packet_size
Right_hand_slot:	rs.b Object_packet_size
Body_slot:	rs.b Object_packet_size
Left_hand_slot:	rs.b Object_packet_size
Right_finger_slot:	rs.b Object_packet_size
Feet_slot:	rs.b Object_packet_size
Left_finger_slot:	rs.b Object_packet_size
Backpack_slots:	rs.b 0

;*****************************************************************************
; These are the body inventory slot numbers
	rsreset
Neck:	rs.b 1
Head:	rs.b 1
Chest:	rs.b 1
Right_hand:	rs.b 1
Body:	rs.b 1
Left_hand:	rs.b 1
Right_finger:	rs.b 1
Feet:	rs.b 1
Left_finger:	rs.b 1

;*****************************************************************************
; These are the character data types
	rsreset
Party_char:	rs.b 1
NPC_char:	rs.b 1
Monster_char:	rs.b 1

;*****************************************************************************
; These are the offsets for the LAByrinth data file
	rsreset
Wall_in_cm:	rs.w 1
Default_combat_bg_nr:	rs.w 1
Sky_colour_nr:	rs.b 1
Floor_colour_nr:	rs.b 1
Ceiling_graphics_nr:	rs.b 1
Floor_graphics_nr:	rs.b 1
Lab_data:	rs.w 0
; Number of object groups	rs.w 1

;*****************************************************************************
; These are the offsets for the 3D objects in a group
	rsreset
Object_X:	rs.w 1
Object_Y:	rs.w 1
Object_Z:	rs.w 1
Object_nr:	rs.w 1
Objectingroup_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the 3D object group data
	rsreset
Object_automapper_icon:	rs.w 1
	rs.b Objects_per_group*Objectingroup_data_size
Objectgroup3D_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the 3D object data
	rsreset
Object_bits:	rs.l 1
Object_graphics_nr:	rs.w 1
Object_nr_frames:	rs.b 1
	rs.b 1
Object_width:	rs.b 1
Object_height:	rs.b 1
Object_dungeon_width:	rs.w 1
Object_dungeon_height:	rs.w 1
Object3D_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the 3D wall data
	rsreset
Wall_bits:	rs.l 1
Wall_graphics_nr:	rs.b 1
Wall_automapper_icon:	rs.b 1
Wall_minimap_colour:	rs.b 1
Wall_nr_overlays:	rs.b 1
Wall_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the 3D wall overlay data
	rsreset
Overlay_mask_flag:	rs.b 1			; 0 = Block, 1 = Mask
Overlay_graphics_nr:	rs.b 1
Overlay_X:	rs.b 1
Overlay_Y:	rs.b 1
Overlay_width:	rs.b 1
Overlay_height:	rs.b 1
Overlay_data_size:	rs.b 0

;*****************************************************************************
; These are the dialogue actions
	rsreset
Ask_word_DIAC:	rs.b 1
Show_item_DIAC:	rs.b 1
Give_item_DIAC:	rs.b 1
Give_gold_DIAC:	rs.b 1
Give_food_DIAC:	rs.b 1
Join_party_DIAC:	rs.b 1
Leave_party_DIAC:	rs.b 1
Init_DIAC:	rs.b 1
Exit_DIAC:	rs.b 1
Max_DIAC:	rs.b 0

;*****************************************************************************
; These are the Places event types
	rsreset
Trainer_place:	rs.b 1
Healer_place:	rs.b 1
Sage_place:	rs.b 1
Enchanter_place:	rs.b 1
Inn_place:	rs.b 1
Object_place:	rs.b 1
Food_place:	rs.b 1
Magic_place:	rs.b 1
Raft_place:	rs.b 1
Ship_place:	rs.b 1
Horse_place:	rs.b 1
Blacksmith_place:	rs.b 1
Max_places:	rs.b 0

;*****************************************************************************
; These are the offsets for the riddle-mouth graphics

RM_eyes_size	equ 9*3*6
RM_mouth_size	equ 15*3*6

	rsreset
	rs.b 4*RM_eyes_size		; Eyes graphics
RM_mouths_offset:	rs.b 0			; Mouth graphics

;*****************************************************************************
; These are the offsets for the automap graphics

AM_wall_size	EQU 8*2
AM_corner_size	EQU 32*2*6
AM_edge_size	EQU 2*16*6
AM_icon_size	EQU Icon_size

	rsreset
	rs.b AM_wall_size*16		; Wall graphics
AM_TL_corner_offset:	rs.b AM_corner_size	; Corner graphics
AM_TR_corner_offset:	rs.b AM_corner_size
AM_BL_corner_offset:	rs.b AM_corner_size
AM_BR_corner_offset:	rs.b AM_corner_size
AM_top_edge_offset:	rs.b AM_edge_size*4		; Edge graphics
AM_right_edge_offset:	rs.b AM_edge_size*4
AM_bottom_edge_offset:	rs.b AM_edge_size*4
AM_left_edge_offset:	rs.b AM_edge_size*4
AM_YAH_base_offset:	rs.b AM_icon_size		; You Are Here
AM_YAH_top_offset:	rs.b AM_icon_size
AM_YAH_arrows_offset:	rs.b AM_icon_size*8
AM_icons_offset:	rs.b 0

;*****************************************************************************
; These are the automapper icons
	rsreset
	rs.b 1				; Nothing
Wall_auto_icon:	rs.b 1
Riddlemouth_auto_icon:	rs.b 1
Teleporter_auto_icon:	rs.b 1
Spinner_auto_icon:	rs.b 1
Trap_auto_icon:	rs.b 1
Trapdoor_auto_icon:	rs.b 1
Special_auto_icon:	rs.b 1
Monster_auto_icon:	rs.b 1
Closed_door_auto_icon:	rs.b 1
Open_door_auto_icon:	rs.b 1
Merchant_auto_icon:	rs.b 1
Inn_auto_icon:	rs.b 1
Closed_chest_auto_icon:	rs.b 1
Map_exit_auto_icon:	rs.b 1
Open_chest_auto_icon:	rs.b 1
Trashpile_auto_icon:	rs.b 1
Person_auto_icon:	rs.b 1
Goto_auto_icon:	rs.b 1
WRONG_auto_icon:	rs.b 1
Max_auto_icons:	rs.b 0

;*****************************************************************************
; These are the automapper icons start frames
	rsreset
AM_icon01:	rs.b 4
AM_icon02:	rs.b 4
AM_icon03:	rs.b 4
AM_icon04:	rs.b 4
AM_icon05:	rs.b 4
AM_icon06:	rs.b 4
AM_icon07:	rs.b 4
AM_icon08:	rs.b 1
AM_icon09:	rs.b 1
AM_icon10:	rs.b 1
AM_icon11:	rs.b 1
AM_icon12:	rs.b 1
AM_icon13:	rs.b 1
AM_icon14:	rs.b 1
AM_icon15:	rs.b 1
AM_icon16:	rs.b 1
AM_icon17:	rs.b 8
AM_icon_WRONG:	rs.b 0

;*****************************************************************************
; These are the automapper function bits
	rsreset
Show_NPCs_function:	rs.b 1
Show_monsters_function:	rs.b 1
Show_traps_function:	rs.b 1
Show_hidden_function:	rs.b 1

;*****************************************************************************
; These are the Trainer place data offsets
	rsreset
Trainer_skill_nr:	rs.w 1
Trainer_price:	rs.w 1

;*****************************************************************************
; These are the Healer place data offsets
	rsreset
Lamed_price:	rs.w 1
Poisoned_price:	rs.w 1
Petrified_price:	rs.w 1
Diseased_price:	rs.w 1
Aging_price:	rs.w 1
Dead_price:	rs.w 1
Ashes_price:	rs.w 1
Dust_price:	rs.w 1
Mad_price:	rs.w 1
Blind_price:	rs.w 1
Stoned_price:	rs.w 1
Heal_LP_price:	rs.w 1
Remove_curse_price:	rs.w 1

;*****************************************************************************
; These are the Sage place data offsets
	rsreset
Sage_price:	rs.w 1

;*****************************************************************************
; These are the Enchanter place data offsets
	rsreset
Enchantment_price:	rs.w 1

;*****************************************************************************
; These are the Inn place data offsets
	rsreset
Inn_price:	rs.w 1
Inn_X:	rs.w 1
Inn_Y:	rs.w 1
Inn_map_nr:	rs.w 1
Inn_heal_percentage:	rs.w 1

;*****************************************************************************
; These are the Food Merchant place data offsets
	rsreset
Food_price:	rs.w 1

;*****************************************************************************
; These are the Transport Merchant place data offsets
	rsreset
Trans_price:	rs.w 1
Newtrans_X:	rs.w 1
Newtrans_Y:	rs.w 1
Newtrans_map_nr:	rs.w 1
Newtrans_type:	rs.w 1

;*****************************************************************************
; These are the Blacksmith place data offsets
	rsreset
Blacksmith_price:	rs.w 1			; Percentage of item price

;*****************************************************************************
; These are the combat actions
	rsreset
	rs.b 1
Move_action:	rs.b 1
Parade_action:	rs.b 1
Close_range_action:	rs.b 1
Long_range_action:	rs.b 1
Flee_action:	rs.b 1
Cast_spell_action:	rs.b 1
Use_magic_object_action:	rs.b 1

;*****************************************************************************
; These are the offsets for the combat participant data
	rsreset
Part_type:	rs.b 1			; 0 - Empty, 1 - Party, 2 - Monster
Part_nr:	rs.b 1			; Member number / Monster number
Part_damage_timer:	rs.b 1		; Damage display timer
Part_icon_nr:	rs.b 1		; Tactical icon number
Part_action:	rs.b 1		; Current combat action
Part_handle:	rs.b 1		; Cloned data for monsters
Part_original_handle:	rs.b 1	; Original data for monsters
Part_gfx_handle:	rs.b 1		; Graphics handle for monsters
Part_flags:	rs.b 1
Part_nr_attacks:	rs.b 1		; Number of attacks until now
Part_anim_index:	rs.b 1
Part_anim:	rs.b 1			; Current animation type
Part_default_frame:	rs.b 1		; Default animation frame
Part_X:	rs.w 1			; Position in tactical window
Part_Y:	rs.w 1
Part_damage:	rs.w 1		; Damage being displayed
Part_target:	rs.w 4		; Target info for current action

	; BLINK :		; When using magic :
	; Selected member		;   0 - Target mask
	; 1			;   4 - Selected class
	; 9			;   5 - Selected spell
	; Special		;   6 - Target mode
				;   7 - Source item slot

Part_total_damage:	rs.l 1		; Total damage done until now
Part_mean_damage:	rs.w 1		; Mean damage done until now
Part_work:	rs.w 1			; Work variable
Part_COMOB_ptr:	rs.l 1		; Pointer to COMOB
Participant_data_size:	rs.b 0

;*****************************************************************************
; These are the participant flags
	rsreset
Part_hurried:	rs.b 1		; Haste spell active
Part_magic_cap:	rs.b 1		; Monster capabilities
Part_long_cap:	rs.b 1		; (DO NOT CHANGE)
Part_close_cap:	rs.b 1
Part_wavedir:	rs.b 1		; Wave animation direction
Part_uncontrol:	rs.b 1		; Participant is uncontrollable
Part_recoloured:	rs.b 1		; Graphics have been recoloured
Part_handanimated:	rs.b 1		; Is animated by hand

;*****************************************************************************
; These are the monster animations
	rsreset
	rs.b 1
Stand_anim:	rs.b 1
Closerange_anim:	rs.b 1
Longrange_anim:	rs.b 1
Magic_anim:	rs.b 1
Hit_anim:	rs.b 1
Die_anim:	rs.b 1
Appear_anim:	rs.b 1

Set_anim	macro
	move.b	#\1,Part_anim(\2)		; Set animation type
	st	Part_anim_index(\2)
	bclr	#Part_wavedir,Part_flags(\2)	; Forth
	endm

;*****************************************************************************
; These are the offsets for the COMbat OBjects data
	rsreset
; *** Do not change... ***
COMOB_2D_X:	rs.w 1			; d0 : 2D coordinates
COMOB_2D_Y:	rs.w 1			; d1
COMOB_Colour:	rs.w 1			; d2 : Silhouette colour / -1
	rs.b 1				; d3 : bit 0 : X-mirroring
COMOB_Mirror_flags:	rs.b 1			;      bit 1 : Y-mirroring
COMOB_Source_width:	rs.w 1			; d4 : Source graphics size
COMOB_Source_height:	rs.w 1		; d5
COMOB_Projected_width:	rs.w 1		; d6 : Projected size
COMOB_Projected_height:	rs.w 1		; d7
; *** ...until here (direct sequential access) ***
COMOB_Flags:	rs.b 1
COMOB_Gfx_handle:	rs.b 1
	rseven
COMOB_Display_width:	rs.w 1		; Display size
COMOB_Display_height:	rs.w 1
COMOB_Previous_CA:	rs.w CA_data_size/2		; Previous CA
COMOB_Gfx_base:	rs.l 1			; Offset to graphics
COMOB_Gfx_offset:	rs.l 1			; Offset to current frame
; *** Modified from outside... ***
COMOB_3D_X:	rs.w 1			; 3D coordinates
COMOB_3D_Y:	rs.w 1
COMOB_3D_Z:	rs.w 1
COMOB_3D_vector_X:	rs.w 1			; 3D vector
COMOB_3D_vector_Y:	rs.w 1
COMOB_3D_vector_Z:	rs.w 1
COMOB_Frame:	rs.w 1			; Current frame
; *** ...until here ***
COMOB_data_size:	rs.b 0

;*****************************************************************************
; These are the COMbat OBject flags
	rsreset
COMOB_present:	rs.b 1
COMOB_update:	rs.b 1
COMOB_add:	rs.b 1
COMOB_erase:	rs.b 1
COMOB_delete:	rs.b 1
COMOB_to_fro:	rs.b 1

;*****************************************************************************
; These are colours in the main palette
	rsreset
Default_shadow:	rs.b 1				; 0
	rs.b 1
White:	rs.b 1
	rs.b 1
Lighter_blue:	rs.b 1
Light_blue:	rs.b 1
	rs.b 1
Dark_blue:	rs.b 1
	rs.b 1				; 8
	rs.b 1
	rs.b 1
	rs.b 1
	rs.b 1
	rs.b 1
	rs.b 1
	rs.b 1
Yellow:	rs.b 1				; 16
	rs.b 1
	rs.b 1
Dark_red:	rs.b 1
Red:	rs.b 1
Light_red:	rs.b 1
Light_green:	rs.b 1
Dark_green:	rs.b 1
	rs.b 1				; 24 - LAYOUT COLOURS
	rs.b 1
	rs.b 1
	rs.b 1
Window_colour:	rs.b 1
	rs.b 1
	rs.b 1
Default_ink:	rs.b 1

;*****************************************************************************
; These are the combat results
	rsreset
	rs.b 1
Combat_won:	rs.b 1
Combat_lost:	rs.b 1
Combat_fled:	rs.b 1

;*****************************************************************************
; These are the combat target select modes
	rsreset
Friend_targmode:	rs.b 1
Enemy_targmode:	rs.b 1
Friend_row_targmode:	rs.b 1
Enemy_row_targmode:	rs.b 1
All_friends_targmode:	rs.b 1
All_enemies_targmode:	rs.b 1
Item_targmode:	rs.b 1
Special_targmode:	rs.b 1
No_targmode:	rs.b 1

;*****************************************************************************
; These are the battle FX graphics offsets

rsgfx	macro
	rs.b (\1/16)*Screen_depth*2*\2*\3
	endm

	rsreset
Fireball_fro_FXGFX:	rs.b 0
	rsgfx 16,16,8
Firepillar_FXGFX:	rs.b 0
	rsgfx 16,32,8
Flame_FXGFX:	rs.b 0
	rsgfx 16,16,6
Missile_to_FXGFX:	rs.b 0			; 1-17  18-24
	rsgfx 32,32,24
Missile_fro_FXGFX:	rs.b 0			; 1- 4   5-12
	rsgfx 32,32,12
Whirlwind_FXGFX:	rs.b 0
	rsgfx 32,64,4
Blood_FXGFX:	rs.b 0
	rsgfx 32,32,4
Ice_FXGFX:	rs.b 0
	rsgfx 16,16,5
Star_FXGFX:	rs.b 0
	rsgfx 16,16,5
Lightning_FXGFX:	rs.b 0
	rsgfx 32,64,1
Beam_FXGFX:	rs.b 0
	rsgfx 16,1,1
Crossbow_to_FXGFX:	rs.b 0
	rsgfx 16,19,1
Crossbow_fro_FXGFX:	rs.b 0
	rsgfx 16,19,1
Arrow_to_FXGFX:	rs.b 0
	rsgfx 16,20,1
Arrow_fro_FXGFX:	rs.b 0
	rsgfx 16,20,1
Stone_FXGFX:	rs.b 0
	rsgfx 16,16,1
Dagger_to_FXGFX:	rs.b 0
	rsgfx 16,15,1
Iceball_FXGFX:	rs.b 0
	rsgfx 16,16,1
Rock_FXGFX:	rs.b 0
	rsgfx 32,16,1
Earthmass_FXGFX:	rs.b 0
	rsgfx 64,32,1
Watermass_FXGFX:	rs.b 0
	rsgfx 64,32,1
LP_globe_FXGFX:	rs.b 0
	rsgfx 16,16,1
PP_globe_FXGFX:	rs.b 0
	rsgfx 16,16,1
Condition_circle_FXGFX:	rs.b 0
	rsgfx 32,32,1
Conditions_FXGFX:	rs.b 0
	rsgfx 16,16,11
Explosion_FXGFX:	rs.b 0
	rsgfx 48,59,14
Scratches_FXGFX:	rs.b 0
	rsgfx 32,32,4
Icepillar_FXGFX:	rs.b 0
	rsgfx 16,32,2
Slash_FXGFX:	rs.b 0
	rsgfx 16,43,3
Deflect_FXGFX:	rs.b 0
	rsgfx 32,32,4
Special_to_FXGFX:	rs.b 0
	rsgfx 16,13,4
Fighting_FXGFX:	rs.b 0
	rs.b 2*6*36
Tactical_GFX:	rs.b 0

;*****************************************************************************
; These are the offsets for the projectile data
	rsreset
Proj_to_gfx_base:	rs.l 1
Proj_fro_gfx_base:	rs.l 1
Proj_source_width:	rs.w 1
Proj_source_height:	rs.w 1
Proj_target_width:	rs.w 1
Proj_target_height:	rs.w 1
Proj_nr_frames:	rs.w 1
Proj_speed:	rs.w 1
Proj_data_size:	rs.b 0

;*****************************************************************************
; These are the offsets for the spell exception data
	rsreset
Xspell_class:	rs.w 1
Xspell_number:	rs.w 1
Xspell_target_entry:	rs.l 1
Xspell_target_display:	rs.l 1
Xspell_data_size:	rs.b 0
