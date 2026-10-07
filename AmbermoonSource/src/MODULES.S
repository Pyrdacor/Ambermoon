; Modules
; Written by J.Horneman (In Tune With The Universe)
; Start : 24-9-1992

Active_keys	macro
	dc.l $00ff0000,$00010000,Select_1	; Active character select
	dc.l $00ff0000,$00020000,Select_2
	dc.l $00ff0000,$00030000,Select_3
	dc.l $00ff0000,$00040000,Select_4
	dc.l $00ff0000,$00050000,Select_5
	dc.l $00ff0000,$00060000,Select_6
	endm
Inv_keys	macro
	dc.l $00ff0000,$00500000,GoInv_1	; Inventory select
	dc.l $00ff0000,$00510000,GoInv_2
	dc.l $00ff0000,$00520000,GoInv_3
	dc.l $00ff0000,$00530000,GoInv_4
	dc.l $00ff0000,$00540000,GoInv_5
	dc.l $00ff0000,$00550000,GoInv_6
	endm
Icon_keys	macro
	dc.l $00ff0000,$003d0000,Icon_1	; Control icons
	dc.l $00ff0000,$003e0000,Icon_2
	dc.l $00ff0000,$003f0000,Icon_3
	dc.l $00ff0000,$002d0000,Icon_4
	dc.l $00ff0000,$002e0000,Icon_5
	dc.l $00ff0000,$002f0000,Icon_6
	dc.l $00ff0000,$001d0000,Icon_7
	dc.l $00ff0000,$001e0000,Icon_8
	dc.l $00ff0000,$001f0000,Icon_9
	endm
Scrollbar_keys	macro
	dc.l $ffff0000,$004c0000,Scroll_bar_page_up
	dc.l $ffff0000,$004d0000,Scroll_bar_page_down
	dc.l $ffff0000,$014c0000,Scroll_bar_all_up
	dc.l $ffff0000,$014d0000,Scroll_bar_all_down
	endm

	SECTION	Program,code
Basic_DisUpd:
	jsr	Check_active_member
	jsr	Update_status_block
	jsr	Update_damage_magic
	ifne	Cheat
	jsr	Print_diagnostic_numbers
	endc
	jmp	Update_control_icons

Basic2_DisUpd:
	jsr	Update_status_block
	jmp	Update_damage_magic

Basic_abort:
	jsr	Wait_4_unclick
	jmp	Pop_Module

Basic_exit:
	jsr	Exit_display
	Pop	Module
	jmp	Init_display


	SECTION	Fast_DATA,data
Basic_VblQ:
	dc.l Time_AutoIcon
	dc.l 0
Basic_ScrQ:
	dc.l AutoIcon_switch
	dc.l 0

Map2D_VblQ:
	dc.l Time_AutoIcon
	dc.l Realtime
	dc.l Time_2D
	dc.l 0
Map_ScrQ:
	dc.l AutoIcon_switch
	dc.l Reset_map_mouse
	dc.l 0

Map2D_Mev:
	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $10ffff00,$10020100,Switch_map_CIL
	dc.l $01ffff00,$01020200,Move_mouse
	dc.l $10ffff00,$10020200,Mouse_action_on
	dc.l $01ffff00,$00020200,Change_mouse
	dc.l 0

Map2D_Kev:
	Icon_keys
	dc.l $00ff0000,$004f0000,M2_left	; Directions
	dc.l $00ff0000,$004e0000,M2_right
	dc.l $00ff0000,$004c0000,M2_up
	dc.l $00ff0000,$004d0000,M2_down
	dc.l $00ff0000,$00430000,Switch_map_CIL	; Toggle
	Active_keys
	Inv_keys
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

Map3D_Mev:
	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $10ffff00,$10020100,Switch_map_CIL
	dc.l $01ffff00,$01020200,Move_mouse
	dc.l $10ffff00,$10020200,Right_mouse
	dc.l $00ffff00,$00020200,Change_mouse
	dc.l 0

Map3D_Kev:
	Icon_keys
	dc.l $00ff0000,$004f0000,Turnleft_3D		; Directions
	dc.l $00ff0000,$004e0000,Turnright_3D
	dc.l $00ff0000,$004c0000,Forward_3D
	dc.l $00ff0000,$004d0000,Backward_3D
	dc.l $00ff0000,$00430000,Switch_map_CIL	; Toggle
	Active_keys
	Inv_keys
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

Map3D_VblQ:
	dc.l Time_AutoIcon
	dc.l Realtime
	dc.l Time_3D
	dc.l 0

Wait_Mev:
	dc.l $01000000,$01000000,Basic_abort
	dc.l $10000000,$10000000,Basic_abort
	dc.l 0
Wait_Kev:
	dc.l $000000ff," ",Basic_abort
Empty_Kev:
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

ItemSelect_Kev:
	Scrollbar_keys
	dc.l $000000ff," ",Basic_abort
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

Req_Mev:	dc.l $01ff0000,$01010000,Req_Yes
	dc.l $01ff0000,$01020000,Req_No
	dc.l 0

Normal_Mev:
	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l 0
Normal_Kev:
	Icon_keys
	Active_keys
	Inv_keys
	dc.l $0000ff00,0,Schnism_check
	dc.l 0
Normal2_Kev:
	Icon_keys
	Active_keys
	Inv_keys
	Scrollbar_keys
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

Main_RL:
	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Main_pal
	R_end
Inv_RL:
	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Main_pal
	R_range 49,25,35,Portrait_range
	R_end
Map_RL:
	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Current_pal
	R_end
C3_RL:
	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Current_pal
	R_range Map3D_Y,C3_raster_colour,C3_horizon,Current_sky
	R_end
Combat_RL:
	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	dc.b 0,Middle_Y+1
Combat_pal_ptr:	dc.l Combat_pal
	R_palette Combat_Y+Combat_height+1,Tactic_pal
	R_end

Lay3_PA:	dc.w 113,300,46,97,2,0,Window_colour

Input_PA:	dc.w 0,0,0,0,31,0,27

; ********** Default ******************************
Default_module:
	dc.b Global_mod,0
	dc.l 0
	dc.l 0,0,Wait_Mev,Wait_Kev
	dc.l 0,0,0,0
	dc.l Main_RL,0,0,0

; ********** Waiting for user *********************
Wait_4_user_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l -1,-1,Wait_Mev,Wait_Kev
	dc.l 0,0,0,0
	dc.l -1,Click_Mptr,-1,-1

; ********** Inventory 1 **************************
Inv1_Mod:
	dc.b Global_mod,Inv1_ID
	dc.l Inv1_DisUpd
	dc.l Basic_VblQ,Inv_ScrQ,.Mev,.Kev
	dc.l Inv1_DisInit,Inv2_DisExit,Inv1_DisInit,Inv2_DisExit
	dc.l Inv_RL,0,0,0

.Mev:	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Inv1_Mright
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $00ffff00,$00020200,Condition_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0
.Kev:	dc.l $00ff0000,$003d0000,Icon_1	; Control	icons
	dc.l $00ff0000,$003f0000,Icon_3
	Active_keys
	dc.l $00ff0000,$00500000,GoInv1_1	; Inventory 1 select
	dc.l $00ff0000,$00510000,GoInv1_2
	dc.l $00ff0000,$00520000,GoInv1_3
	dc.l $00ff0000,$00530000,GoInv1_4
	dc.l $00ff0000,$00540000,GoInv1_5
	dc.l $00ff0000,$00550000,GoInv1_6
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

Inv_ScrQ:	dc.l AutoIcon_switch
	dc.l Blink_colour2
	dc.l 0

; ********** Input number *************************
InputNr_Mod:
	dc.b Local_mod,0
	dc.l ObjGoldFood_DisUpd
	dc.l Basic_ScrQ,Basic_VblQ,.Mev,.Kev
	dc.l ObjGoldFood_DisInit,Close_window,0,0
	dc.l 0,0,0,0

.Mev:	dc.l $01ffff00,$01010400,InputNr_input
	dc.l $01ffff00,$01010100,InputNr_arrow_up
	dc.l $01ffff00,$01010200,InputNr_arrow_down
	dc.l $10ffff00,$10010100,InputNr_all_up
	dc.l $10ffff00,$10010200,InputNr_all_down
	dc.l $01ffff00,$01010300,InputNr_exit
	dc.l $10ffff00,$10010000,InputNr_exit
	dc.l 0
.Kev:	dc.l $ffff0000,$004c0000,InputNr_arrow_1up
	dc.l $ffff0000,$004d0000,InputNr_arrow_1down
	dc.l $ffff0000,$014c0000,InputNr_all_up
	dc.l $ffff0000,$014d0000,InputNr_all_down
	dc.l $000000ff," ",InputNr_exit
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Text window **************************
TxtW_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l 0,0,0,Empty_Kev
	dc.l TxtW_DisInit,0,0,0
	dc.l 0,0,TxtW_PA,0

; ********** General requester ********************
Req_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l Basic_VblQ,Basic_ScrQ,Req_Mev,.Kev
	dc.l Req_ModInit,Close_window,0,0
	dc.l 0,0,ReqW_PA,0

.Kev:	dc.l $000000ff,"Y",Req_Yes
	dc.l $000000ff,"J",Req_Yes
	dc.l $000000ff,"O",Req_Yes
	dc.l $000000ff,"N",Req_No
	dc.l $000000ff,"y",Req_Yes
	dc.l $000000ff,"j",Req_Yes
	dc.l $000000ff,"o",Req_Yes
	dc.l $000000ff,"n",Req_No
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Disk requester ***********************
DiskReq_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l 0,0,Req_Mev,.Kev
	dc.l Req_ModInit,Close_window,0,0
	dc.l 0,0,ReqW_PA,0

.Kev:	dc.l $000000ff,"Y",Req_Yes
	dc.l $000000ff,"J",Req_Yes
	dc.l $000000ff,"O",Req_Yes
	dc.l $000000ff,"N",Req_No
	dc.l $000000ff,"y",Req_Yes
	dc.l $000000ff,"j",Req_Yes
	dc.l $000000ff,"o",Req_Yes
	dc.l $000000ff,"n",Req_No
	dc.l $ff000000,$20000000,Req_Yes	; !!!
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Battle order - Select position *******
BOPosSel_Mod:	
	dc.b Local_mod,0
	dc.l BOPosSel_DisUpd
	dc.l -1,-1,.Mev,Empty_Kev
	dc.l BOPosSel_DisInit,0,0,0
	dc.l 0,0,0,.MA

.Mev:	dc.l $01ffff00,$01020200,BOPos_selected
	dc.l $10000000,$10000000,Exit_BOPosSel
	dc.l 0
.MA:	dc.w 16,287,45,88+34

; ********** Battle order screen ******************
BattleOrder_Mod:
	dc.b Global_mod,BattleOrder_ID
	dc.l Basic_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Normal_Kev
	dc.l BattleOrder_ModInit,BattleOrder_ModExit
	dc.l BattleOrder_DisInit,BattleOrder_DisExit
	dc.l Main_RL,0,.PA,0

.Mev:	dc.l $01ffff00,$01020200,BattleOrder_clicked
	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l 0
.PA:	dc.w 16,193,144,193,2,0,Window_colour

; ********** Spell selector ***********************
SpSelW_Mod:
	dc.b Local_mod,0
	dc.l SpSelW_DisUpd
	dc.l 0,0,.Mev,ItemSelect_Kev
	dc.l SpSelW_ModInit,SpSelW_DisExit,SpSelW_DisInit,SpSelW_DisExit
	dc.l 0,0,0,0

.Mev:	dc.l $01ffff00,$0101ff00,Scroll_bar_pressed
	dc.l $01ff0000,$01010000,Spell_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ff0000,$00010000,Spell_touched
	dc.l 0

; ********** Item selector (layout 3) *************
Lay3_ItemSelect_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l -1,-1,.Mev,ItemSelect_Kev
	dc.l ItemSelect_DisInit,ItemSelect_DisExit,0,0
	dc.l 0,0,-1,Lay3_ItemSelect_MA

.Mev:	dc.l $01ffffff,$010202ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020200,Item_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ffff00,$00020200,Item_touched
	dc.l 0
Lay3_ItemSelect_MA:	dc.w 16,166,139,192

; ********** Camp screen **************************
Camp_Mod:
	dc.b Global_mod,Camp_ID
	dc.l Basic_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Camp_ModInit,Camp_ModExit,Camp_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Options "screen" ************************
Options_Mod:
	dc.b Global_mod,Options_ID
	dc.l Basic_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,.Kev
	dc.l Options_ModInit,Options_ModExit,0,0
	dc.l -1,0,0,Control_area

.Mev:	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l 0
.Kev:	Icon_keys
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Item selector (inventory 2) **********
; BACKPACK ONLY

Inv2_ItemSelect_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l -1,-1,.Mev,ItemSelect_Kev
	dc.l ItemSelect_DisInit,ItemSelect_DisExit,0,0
	dc.l 0,0,-1,.MA

.Mev:	dc.l $01ffffff,$010203ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020300,Item_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ffff00,$00020300,Item_touched
	dc.l 0
.MA:	dc.w 109,180,76,163+23

; ********** Item selector (Inventory 2) **********
; BODY + BACKPACK

Inv2B_ItemSelect_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l -1,-1,.Mev,ItemSelect_Kev
	dc.l ItemSelect_DisInit,ItemSelect_DisExit,0,0
	dc.l 0,0,-1,.MA

.Mev:	dc.l $01ffffff,$010203ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020300,Backpack_item_selected
	dc.l $01ffff00,$01020200,Body_item_selected
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ffff00,$00020300,Item_touched
	dc.l $00ffff00,$00020200,Body_item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0
.MA:	dc.w 20,180,72,163+23

; ********** Inventory 2 - Item view window 1 *****
ItemView1_Mod:      
	dc.b Local_mod,0
	dc.l Basic2_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Wait_Kev
	dc.l ItemView1_DisInit,Close_window,0,0
	dc.l 0,0,0,0

.Mev:	dc.l $10000000,$10000000,Basic_abort
	dc.l $01ff0000,$01010000,Do_ItemView2
	dc.l 0

; ********** Inventory 2 - Item view window 2 *****
ItemView2_Mod:      
	dc.b Local_mod,0
	dc.l Basic2_DisUpd
	dc.l Basic_VblQ,.ScrQ,Wait_Mev,Wait_Kev
	dc.l ItemView2_DisInit,Close_window,0,0
	dc.l 0,0,0,0

.ScrQ:	dc.l AutoIcon_switch
	dc.l Blink_colour
	dc.l Accursed_blink
	dc.l 0

; ********** Inventory 2 - Victim select **********
TIVS_Mod:
	dc.b Local_mod,0
	dc.l Basic2_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Wait_Kev
	dc.l TIVS_DisInit,TIVS_DisExit,0,0
	dc.l 0,0,-1,Main_tree+4

.Mev:	dc.l $01ff0000,$01010000,Victim_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l 0

; ********** Inventory 2 **************************
Inv2_Mod:
	dc.b Global_mod,Inv2_ID
	dc.l Inv2_DisUpd
	dc.l Basic_VblQ,Inv_ScrQ,.Mev,.Kev
	dc.l Inv2_ModInit,Inv2_ModExit,Inv2_DisInit,Inv2_DisExit
	dc.l Inv_RL,0,.PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Inv2_Mright
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $01ffffff,$010203ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020200,Move_body_item
	dc.l $10ffff00,$10020200,Move_body_item
	dc.l $01ffff00,$01020300,Move_backpack_item
	dc.l $10ffff00,$10020300,Move_all_backpack_items
	dc.l $00ffff00,$00020200,Body_item_touched
	dc.l $00ffff00,$00020300,Item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0
.Kev:	Icon_keys
	Active_keys
	dc.l $00ff0000,$00500000,GoInv2_1	; Inventory 2 select
	dc.l $00ff0000,$00510000,GoInv2_2
	dc.l $00ff0000,$00520000,GoInv2_3
	dc.l $00ff0000,$00530000,GoInv2_4
	dc.l $00ff0000,$00540000,GoInv2_5
	dc.l $00ff0000,$00550000,GoInv2_6
	Scrollbar_keys
	dc.l $0000ff00,0,Schnism_check
	dc.l 0
.PA:	dc.w 21,181,50,70,2,0,Window_colour

; ********** Move item (Inventory 2) **************
Move_item_Mod:
	dc.b Local_mod,0
	dc.l Move_item_DisUpd
	dc.l -1,-1,.Mev,.Kev
	dc.l Move_item_DisInit,Move_item_DisExit,0,0
	dc.l 0,Pick_Mptr,-1,0

.Mev:	dc.l $02ff0000,$02010000,Member_moved
	dc.l $10ff0000,$10010000,Inv2_Mright
	dc.l $01ffffff,$010203ff,Scroll_bar_pressed
	dc.l $02ffff00,$02020300,Backpack_item_moved
	dc.l $02ffff00,$02020200,Body_item_moved
	dc.l $10000000,$10000000,Move_aborted
	dc.l $00ffff00,$00020300,Item_touched
	dc.l $00ffff00,$00020200,Body_item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0
.Kev:	Scrollbar_keys
	dc.l $000000ff," ",Move_aborted
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** 2D city map **************************
C2Map_Mod:
	dc.b Global_mod,C2Map_ID
	dc.l C2_DisUpd
	dc.l Map2D_VblQ,Map_ScrQ,Map2D_Mev,Map2D_Kev
	dc.l C2_ModInit,C2_ModExit,M2_DisInit,Map_DisExit
	dc.l Map_RL,0,0,0

; ********** 2D world map *************************
W2Map_Mod:
	dc.b Global_mod,W2Map_ID
	dc.l W2_DisUpd
	dc.l Map2D_VblQ,Map_ScrQ,Map2D_Mev,Map2D_Kev
	dc.l W2_ModInit,W2_ModExit,M2_DisInit,Map_DisExit
	dc.l Map_RL,0,0,0

; ********** 2D Action ****************************
Action2D_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l Map2D_VblQ,.ScrQ,EHM_Mev,Wait_Kev
	dc.l Mouth_ModInit,0,0,0
	dc.l 0,EyeMouth_Mptr,0,Made_area

.ScrQ:	dc.l AutoIcon_switch
	dc.l Action2D_switch
	dc.l 0

EHM_Mev:	dc.l $01000000,$01000000,EHM_clicked
	dc.l $10000000,$10000000,Basic_abort
	dc.l 0

; ********** 2D Eye action ************************
Eye_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l Map2D_VblQ,Basic_ScrQ,EHM_Mev,Wait_Kev
	dc.l Eye_ModInit,0,0,0
	dc.l 0,Eye_Mptr,0,Made_area

; ********** 2D Hand action ************************
Hand_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l Map2D_VblQ,Basic_ScrQ,EHM_Mev,Wait_Kev
	dc.l Eye_ModInit,0,0,0
	dc.l 0,Hand_Mptr,0,Made_area

; ********** 2D Mouth action **********************
Mouth_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l Map2D_VblQ,Basic_ScrQ,EHM_Mev,Wait_Kev
	dc.l Mouth_ModInit,0,0,0
	dc.l 0,Mouth_Mptr,0,Made_area

; ********** Door screen **************************
Door_Mod:
	dc.b Local_mod,Door_ID
	dc.l Basic_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Door_ModInit,Door_ModExit,Door_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Word selector ************************
WSelW_Mod:
	dc.b Local_mod,0
	dc.l Update_wordselect_window
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,.Kev
	dc.l WSelW_ModInit,WSelW_ModExit,WSelW_DisInit,WSelW_DisExit
	dc.l 0,0,0,0

.Mev:	dc.l $01ffff00,$0101ff00,Scroll_bar_pressed
	dc.l $01ff0000,$01010000,Word_selected
	dc.l $01ff0000,$01020000,Word_input
	dc.l $01ff0000,$01030000,Exit_WSelW
	dc.l $10000000,$10000000,Exit_WSelW
	dc.l $00ff0000,$00010000,Word_touched
	dc.l 0
.Kev:	Scrollbar_keys
	dc.l $000000ff," ",Exit_WSelW
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Riddlemouth screen *******************
RiddleM_Mod:
	dc.b Local_mod,RiddleM_ID
	dc.l Basic_DisUpd
	dc.l Basic_VblQ,.ScrQ,Normal_Mev,Normal_Kev
	dc.l RiddleM_ModInit,RiddleM_ModExit,RiddleM_DisInit,RiddleM_DisExit
	dc.l Main_RL,0,.PA,0

.ScrQ:	dc.l Animate_RM_mouth
	dc.l AutoIcon_switch
	dc.l 0
.PA:	dc.w 17,190,51,192,2,0,Window_colour

; ********** Closed chest screen ******************
ClosedChest_Mod:
	dc.b Local_mod,ClosedChest_ID
	dc.l Basic_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l ClosedChest_ModInit,Door_ModExit,ClosedChest_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Opened chest screen ******************
OpenedChest_Mod:
	dc.b Local_mod,OpenedChest_ID
	dc.l OpenedChest_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Normal2_Kev
	dc.l OpenedChest_ModInit,OpenedChest_ModExit,OpenedChest_DisInit,OpenedChest_DisExit
	dc.l Main_RL,0,Lay3_PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $01ffffff,$010202ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020200,Move_LAY3_item
	dc.l $10ffff00,$10020200,Move_all_LAY3_items
	dc.l $00ffff00,$00020200,Item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0

; ********** Move item (Layout 3 or 8) ************
Move_LAY3_item_Mod:
	dc.b Local_mod,0
	dc.l Move_LAY3_item_DisUpd
	dc.l -1,-1,.Mev,.Kev
	dc.l Move_item_DisInit,Move_item_DisExit,0,0
	dc.l 0,Pick_Mptr,-1,0

.Mev:	dc.l $02ff0000,$02010000,Member_moved_LAY3
	dc.l $01ffffff,$010202ff,Scroll_bar_pressed
	dc.l $02ffff00,$02020200,LAY3_item_moved
	dc.l $10000000,$10000000,Move_LAY3_aborted
	dc.l $00ffff00,$00020200,Item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0
.Kev:	Scrollbar_keys
	dc.l $ff0000ff," ",Move_LAY3_aborted
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** 3D city ******************************
C3Map_Mod:
	dc.b Global_mod,M3Map_ID
	dc.l Map3D_DisUpd
	dc.l Map3D_VblQ,Map_ScrQ,Map3D_Mev,Map3D_Kev
	dc.l M3_ModInit,M3_ModExit,M3_DisInit,Map_DisExit
	dc.l C3_RL,0,0,0

; ********** 3D dungeon ***************************
D3Map_Mod:
	dc.b Global_mod,M3Map_ID
	dc.l Map3D_DisUpd
	dc.l Map3D_VblQ,Map_ScrQ,Map3D_Mev,Map3D_Kev
	dc.l M3_ModInit,M3_ModExit,M3_DisInit,Map_DisExit
	dc.l Map_RL,0,0,0

; ********** 3D map mouse movement ****************
Mousemove_3D_Mod:
	dc.b Global_mod,0
	dc.l -1
	dc.l Map3D_VblQ,Map_ScrQ,.Mev,Empty_Kev
	dc.l Mousemove_ModInit,Mousemove_ModExit,0,MouseMove_DisExit
	dc.l -1,-1,0,Map3D_L2

.Mev:	dc.l $01ffff00,$01020200,Moving_mouse
	dc.l $01ffff00,$00020200,Pop_Module
	dc.l 0

; ********** Continuous control icon **************
Continuous_Mod:
	dc.b Global_mod,0
	dc.l -1
	dc.l -1,-1,.Mev,Empty_Kev
	dc.l 0,Continuous_ModExit,-1,-1
	dc.l -1,0,0,0

.Mev:	dc.l $01ffff00,$01020100,Do_continuous
	dc.l $80000000,$80000000,Pop_Module
	dc.l 0

; ********** Saved game selector - Load ***********
LoadSelW_Mod:
	dc.b Local_mod,0
	dc.l Update_saved_window
	dc.l 0,0,.Mev,.Kev
	dc.l SavedSelW_DisInit,Close_window,0,0
	dc.l 0,0,0,0

.Mev:	dc.l $02ff0000,$02010000,Load_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ff0000,$00010000,Load_touched
	dc.l 0
.Kev:	dc.l $000000ff," ",Basic_abort
	dc.l 0

; ********** Saved game selector - Save ***********
SaveSelW_Mod:
	dc.b Local_mod,0
	dc.l Update_saved_window
	dc.l 0,0,.Mev,.Kev
	dc.l SavedSelW_DisInit,Close_window,0,0
	dc.l 0,0,0,0

.Mev:	dc.l $02ff0000,$02010000,Save_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ff0000,$00010000,Save_touched
	dc.l 0
.Kev:	dc.l $000000ff," ",Basic_abort
	dc.l 0

; ********** Standard party member select *********
MemberSel_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l 0,0,.Mev,.Kev
	dc.l MemberSel_DisInit,MemberSel_DisExit,0,0
	dc.l 0,0,TxtW_PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l 0
.Kev:	dc.l $00ff0000,$00010000,Select_member_1	; Member select
	dc.l $00ff0000,$00020000,Select_member_2
	dc.l $00ff0000,$00030000,Select_member_3
	dc.l $00ff0000,$00040000,Select_member_4
	dc.l $00ff0000,$00050000,Select_member_5
	dc.l $00ff0000,$00060000,Select_member_6
	dc.l $000000ff," ",Basic_abort
	dc.l 0

; ********** Active party member select ***********
ActiveSel_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l 0,0,.Mev,.Kev
	dc.l MemberSel_DisInit,MemberSel_DisExit,0,0
	dc.l 0,0,TxtW_PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_selected
	dc.l 0
.Kev:	dc.l $00ff0000,$00010000,Select_member_1	; Member select
	dc.l $00ff0000,$00020000,Select_member_2
	dc.l $00ff0000,$00030000,Select_member_3
	dc.l $00ff0000,$00040000,Select_member_4
	dc.l $00ff0000,$00050000,Select_member_5
	dc.l $00ff0000,$00060000,Select_member_6
	dc.l 0

; ********** Dialogue screen **********************
Dialogue_Mod:
	dc.b Global_mod,Dialogue_ID
	dc.l Dialogue_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Dialogue_ModInit,Dialogue_ModExit,Dialogue_DisInit,Fade_out_bottom
	dc.l Dialogue_RL,0,Dialogue_PA,0

Dialogue_RL:
	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Main_pal
	R_range 43,25,35,Portrait_range
	R_end
Dialogue_PA:
	dc.w 16+1,191-1,43+1,122-1,31,0,Window_colour

; ********** Dialogue screen + scroll-bar *********
Dialogue2_Mod:
	dc.b Global_mod,0
	dc.l Dialogue_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Normal2_Kev
	dc.l 0,0,Dialogue2_DisInit,Fade_out_bottom
	dc.l Dialogue_RL,0,Dialogue_PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $01ffffff,$010202ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020200,Move_LAY3_item
	dc.l $10ffff00,$10020200,Move_all_LAY3_items
	dc.l $00ffff00,$00020200,Item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0

; ********** Places - Trainer *********************
Trainer_Mod:
	dc.b Local_mod,Trainer_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Trainer_ModInit,Places_ModExit,Trainer_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Places - Healer **********************
Healer_Mod:
	dc.b Local_mod,Healer_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,.ScrQ,.Mev,.Kev
	dc.l Healer_ModInit,Healer_ModExit,Healer_DisInit,Healer_DisExit
	dc.l Main_RL,0,Lay3_PA,0

.ScrQ:	dc.l AutoIcon_switch
	dc.l Display_Ankh
	dc.l 0
.Mev:	dc.l $02ff0000,$02010000,Healer_member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l 0
.Kev:	Icon_keys
	dc.l $00ff0000,$00010000,Healer_select_1	; Healer victim select
	dc.l $00ff0000,$00020000,Healer_select_2
	dc.l $00ff0000,$00030000,Healer_select_3
	dc.l $00ff0000,$00040000,Healer_select_4
	dc.l $00ff0000,$00050000,Healer_select_5
	dc.l $00ff0000,$00060000,Healer_select_6
	Inv_keys
	dc.l 0

; ********** Places - Sage ************************
Sage_Mod:
	dc.b Local_mod,Sage_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Sage_ModInit,Healer_ModExit,Sage_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Places - Enchanter *******************
Enchanter_Mod:
	dc.b Local_mod,Enchanter_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Enchanter_ModInit,Healer_ModExit,Enchanter_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Places - Inn *************************
Inn_Mod:
	dc.b Local_mod,Inn_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Inn_ModInit,Places_ModExit,Inn_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Places - Object merchant *************
MerchOBJC_Mod:
	dc.b Local_mod,MerchOBJC_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Normal2_Kev
	dc.l MerchOBJC_ModInit,MerchOBJC_ModExit,MerchOBJC_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $01ffffff,$010202ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020200,Move_LAY3_item
	dc.l $10ffff00,$10020200,Move_all_LAY3_items
	dc.l $00ffff00,$00020200,Item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0

; ********** Places - Food merchant ***************
MerchFOOD_Mod:
	dc.b Local_mod,MerchFOOD_ID
	dc.l MerchFOOD_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l MerchFOOD_ModInit,Healer_ModExit,MerchFOOD_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Places - Transport merchant **********
MerchTRANS_Mod:
	dc.b Local_mod,MerchTRANS_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l MerchTRANS_ModInit,Places_ModExit,MerchTRANS_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Places - Blacksmith ******************
Blacksmith_Mod:
	dc.b Local_mod,Blacksmith_ID
	dc.l Places_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,Normal_Mev,Normal_Kev
	dc.l Blacksmith_ModInit,Healer_ModExit,Blacksmith_DisInit,Fade_out_bottom
	dc.l Main_RL,0,Lay3_PA,0

; ********** Buy/sell requester *******************
BSReq_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,.Kev
	dc.l 0,0,0,0
	dc.l 0,0,0,0

.Mev:	dc.l $01ff0000,$01010000,BSReq_Yes
	dc.l $01ff0000,$01020000,BSReq_No
	dc.l 0
.Kev:	dc.l $000000ff,"Y",BSReq_Yes
	dc.l $000000ff,"J",BSReq_Yes
	dc.l $000000ff,"O",BSReq_Yes
	dc.l $000000ff,"N",BSReq_No
	dc.l $000000ff,"y",BSReq_Yes
	dc.l $000000ff,"j",BSReq_Yes
	dc.l $000000ff,"o",BSReq_Yes
	dc.l $000000ff,"n",BSReq_No
	dc.l 0

; ********** Automap screen ***********************
Automap_Mod:
	dc.b Global_mod,Automap_ID
	dc.l Automap_DisUpd
	dc.l .VblQ,Basic_ScrQ,.Mev,.Kev
	dc.l Automap_ModInit,Automap_ModExit,Automap_DisInit,Fade_out_bottom
	dc.l .RL,0,.PA,Automap_CA

.VblQ:	dc.l Time_legend_pageflip
	dc.l Time_AutoIcon
	dc.l 0
.Mev:	dc.l $01ffff00,$01020100,Goto_point_selected
	dc.l $10000000,$10000000,Quit_automap
	dc.l $00ffffff,$00020109,Goto_point_touched
	dc.l $00ffff00,$00020100,Move_automap
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0
.Kev:	Active_keys
	Inv_keys
	dc.l $00ff0000,$004f0000,Automap_left	; Directions
	dc.l $00ff0000,$004e0000,Automap_right
	dc.l $00ff0000,$004c0000,Automap_up
	dc.l $00ff0000,$004d0000,Automap_down
	dc.l $000000ff," ",Quit_automap
	dc.l 0
.RL:	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Automap_pal
	R_end
.PA:	dc.w 216,303,45,188,31,0,Window_colour

; ********** Item selector (merchant) ************
Merchant_ItemSelect_Mod:
	dc.b Local_mod,0
	dc.l -1
	dc.l -1,-1,.Mev,ItemSelect_Kev
	dc.l ItemSelect_DisInit,ItemSelect_DisExit,0,0
	dc.l 0,0,-1,Lay3_ItemSelect_MA

.Mev:	dc.l $01ffffff,$010202ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020200,Item_selected
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ffff00,$00020200,Merchant_item_touched
	dc.l 0

; ********** Make levels *************************
Make_levels_Mod:
	dc.b Local_mod,0
	dc.l Basic2_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,0,Empty_Kev
	dc.l Make_levels,0,0,0
	dc.l 0,0,0,0

; ********** Combat screen ************************
Combat_Mod:
	dc.b Local_mod,Combat_ID
	dc.l Combat_DisUpd
	dc.l Combat_VblQ,Combat_ScrQ,.Mev,.Kev
	dc.l Combat_ModInit,Combat_ModExit,Combat_DisInit,Fade_out_bottom
	dc.l Combat_RL,0,.PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $01ffff00,$01020200,Tactical_member_left
	dc.l $10ffff00,$10020200,Tactical_member_right
	dc.l $00ffff00,$00020200,Tactic_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0
.Kev:	Icon_keys
	Active_keys
	Inv_keys
	dc.l 0
.PA:	dc.w 5,88,139,194
Combat_ink_colour:				; !!!
	dc.w 2,0,Window_colour

Combat_VblQ:
	dc.l Time_combat
	dc.l 0
Combat_ScrQ:
	dc.l Display_combat_status_icons
	dc.l Refresh_combat_screen
	dc.l 0

; ********** Combat - Select from tactic screen *****
TacticSel_Mod:
	dc.b Local_mod,0
	dc.l TacticSel_DisUpd
	dc.l -1,-1,.Mev,Wait_Kev
	dc.l TacticSel_DisInit,TacticSel_DisExit,0,0
	dc.l 0,0,-1,Combat_L2

.Mev:	dc.l $01ffff00,$01020200,Tactic_clicked
	dc.l $10000000,$10000000,Basic_abort
	dc.l $00ffff00,$00020200,Tactic_touched
	dc.l 0

; ********** Apres combat screen ******************
Apres_Mod:
	dc.b Local_mod,Apres_ID
	dc.l Apres_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Normal2_Kev
	dc.l Apres_ModInit,Apres_ModExit,Apres_DisInit,Apres_DisExit
	dc.l Main_RL,0,Lay3_PA,0

.Mev:	dc.l $01ff0000,$01010000,Member_left
	dc.l $10ff0000,$10010000,Member_right
	dc.l $01ffff00,$01020100,Do_control_icons
	dc.l $01ffffff,$010202ff,Scroll_bar_pressed
	dc.l $01ffff00,$01020200,Move_LAY3_item
	dc.l $10ffff00,$10020200,Move_all_LAY3_items
	dc.l $00ffff00,$00020200,Item_touched
	dc.l $80000000,$80000000,Destroy_ghosts
	dc.l 0

; ********** Combat - Display combat **************
CombatDisplay_Mod:
	dc.b Global_mod,0
	dc.l 0				; !
	dc.l Combat_VblQ,.ScrQ,0,Empty_Kev
	dc.l Do_combat_round,0,0,0
	dc.l Combat_RL,0,-1,0

.ScrQ:	dc.l Display_combat_status_icons
	dc.l Draw_combat_screen
	dc.l Update_status_block
	dc.l Update_damage_magic
	dc.l 0

; ********** Music selector ***********************
MusSelW_Mod:
	dc.b Local_mod,0
	dc.l Update_music_select_window
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,.Kev
	dc.l MusSelW_DisInit,MusSelW_DisExit,0,0
	dc.l 0,0,0,0

.Mev:	dc.l $01ffff00,$0101ff00,Scroll_bar_pressed
	dc.l $01ff0000,$01010000,Music_selected
	dc.l $01ff0000,$01030000,Exit_MusSelW
	dc.l $10000000,$10000000,Exit_MusSelW
	dc.l $00ff0000,$00010000,Music_touched
	dc.l 0
.Kev:	Scrollbar_keys
	dc.l $000000ff," ",Exit_MusSelW
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Options window ***********************
OptionsW_Mod:
	dc.b Local_mod,0
	dc.l Update_option_names
	dc.l 0,0,.Mev,.Kev
	dc.l OptionsW_ModInit,Close_window,0,0
	dc.l 0,0,0,0

.Mev:	dc.l $02ff0000,$02010000,Option_selected
	dc.l $02ff0000,$02020000,Options_aborted
	dc.l $10000000,$10000000,Options_aborted
	dc.l $00ff0000,$00010000,Option_touched
	dc.l 0
.Kev:	dc.l $000000ff," ",Options_aborted
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Magic compass ************************
MagicCompass_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l 0,0,Wait_Mev,Wait_Kev
	dc.l MagicCompass_ModInit,Close_window,0,0
	dc.l 0,0,0,0

; ********** Minimap ******************************
Minimap_Mod:
	dc.b Local_mod,0
	dc.l Minimap_DisUpd
	dc.l 0,0,.Mev,.Kev
	dc.l Minimap_ModInit,Minimap_ModExit,Minimap_DisInit,0
	dc.l 0,0,0,0

.Mev:	dc.l $10000000,$10000000,Pop_Module
	dc.l $00ff0000,$00010000,Move_minimap
	dc.l 0
.Kev:	dc.l $00ff0000,$004f0000,Minimap_left	; Directions
	dc.l $00ff0000,$004e0000,Minimap_right
	dc.l $00ff0000,$004c0000,Minimap_up
	dc.l $00ff0000,$004d0000,Minimap_down
	dc.l $000000ff," ",Pop_Module
	dc.l $0000ff00,0,Schnism_check
	dc.l 0

; ********** Character editor *********************
Chared_Mod:
	dc.b Local_mod,0
	dc.l Chared_DisUpd
	dc.l 0,0,.Mev,.Kev
	dc.l Chared_ModInit,Chared_ModExit,Chared_DisInit,0
	dc.l .RL,0,0,0

.Mev:	dc.l $01ff0000,$01010000,Male_chared
	dc.l $01ff0000,$01020000,Female_chared
	dc.l $01ff0000,$01030000,Left_portrait
	dc.l $01ff0000,$01040000,Right_portrait
	dc.l $01ff0000,$01050000,Exit_chared
	dc.l $01ff0000,$01060000,Enter_name
	dc.l 0
.Kev:	dc.l $000000ff," ",Exit_chared
	dc.l $0000ff00,0,Schnism_check
	dc.l 0
.RL:	R_palette 0,Main_pal
	R_range Chared_Y+13,25,35,Portrait_range
	R_end

; ********** Input string *************************
Input_Mod:
	dc.b Local_mod,0
	dc.l Input_DisUpd
	dc.l 0,0,.Mev,.Kev
	dc.l Input_ModInit,Input_ModExit,0,0
	dc.l 0,0,Input_PA,0

.Mev:	dc.l $01000000,$01000000,Basic_abort		; (=Return)
	dc.l $10000000,$10000000,Input_abort
	dc.l 0
.Kev:	dc.l $000000ff,$0000000d,Basic_abort		; Return
	dc.l $ffff0000,$01410000,Input_clear		; Shift + backspace
	dc.l $00ff0000,$00410000,Input_backspace	; Backspace
	dc.l $0000ff00,0,Input_key			; Key
	dc.l 0

; ********** Show pic + txt picture screen ********
ShowPicTxt_Mod:
	dc.b Local_mod,ShowPicTxt_ID
	dc.l Basic_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,0,Empty_Kev
	dc.l ShowPicTxt_ModInit,Fade_out_bottom,ShowPicTxt_ModInit,Fade_out_bottom
	dc.l ShowPicTxt_RL,0,ShowPicTxt_PA,0

ShowPicTxt_RL:
	R_palette 0,Main_pal
	R_range 1,25,35,Portrait_range
	R_palette Middle_Y+1,Batch			; !!!
;	R_palette 131,Main_pal
	R_end
ShowPicTxt_PA:
	dc.w 18,302,139,192,31,0,Window_colour

; ********** Monster knowledge window *************
MonKnow_Mod:
	dc.b Local_mod,0
	dc.l 0
	dc.l 0,0,Wait_Mev,Wait_Kev
	dc.l MonKnow_ModInit,MonKnow_ModExit,0,0	; %%%1
	dc.l 0,0,0,0

; ********** Game Over screen *********************
GameOver_Mod:
	dc.b Local_mod,0
	dc.l Basic2_DisUpd
	dc.l Basic_VblQ,Basic_ScrQ,.Mev,Empty_Kev
	dc.l GameOver_ModInit,GameOver_ModExit,GameOver_ModInit,GameOver_ModExit
	dc.l ShowPicTxt_RL,0,ShowPicTxt_PA,0

.Mev:	dc.l $01ff0000,$01010000,LQ_Load
	dc.l $01ff0000,$01020000,LQ_Quit
	dc.l 0
