; ST kernel - stubs (stage 1 of PORT.md)
; Every routine and variable of the interface which is not implemented yet.

	SECTION	Program,code
Change_Mptr:
	rts
Clear_1plane_block:
	rts
Clear_screen:
	rts
Close_current_file:
	rts
Copy_screen:
	rts
DI_Print_text:
	rts
Decompress:
	rts
Draw_box:
	rts
Draw_ceiling:
	rts
Draw_floor:
	rts
Draw_hline:
	rts
Draw_vline:
	rts
Draw_zoom_shape:
	rts
Draw_zoom_silhouette:
	rts
Duplicate_block:
	rts
Exit_diagnostic_screen:
	rts
Exit_program:
	rts
Fade_colour:
	rts
File_get_mem_type:
	rts
Get_block:
	rts
Get_file_mem_prio:
	rts
Get_pixel:
	rts
Get_saved_game:
	rts
Init_diagnostic_screen:
	rts
Insert_horizon:
	rts
Lack_of_memory_warning:
	rts
Load_batch_of_subfiles:
	rts
Load_batch_of_unique_subfiles:
	rts
Load_file:
	rts
Load_subfile:
	rts
Load_unique_subfile:
	rts
Mouse_off:
	rts
Mouse_on:
	rts
My_vsync:
	rts
Plot_pixel:
	rts
Pop_CA:
	rts
Pop_MA:
	rts
Pop_Mptr:
	rts
Push_CA:
	rts
Push_MA:
	rts
Push_Mptr:
	rts
Put_masked_block:
	rts
Put_masked_block2:
	rts
Put_masked_icon:
	rts
Put_masked_silhouette:
	rts
Put_saved_game:
	rts
Put_text_line:
	rts
Put_unmasked_block:
	rts
Put_unmasked_icon:
	rts
Read_Mev:
	rts
Read_key:
	rts
Recolour_block:
	rts
Restart_game:
	rts
Save_encrypted_file:
	rts
Save_file:
	rts
Save_subfile:
	rts
Set_fade:
	rts
Show_MOVEP_screen:
	rts
Switch_screens:
	rts
Update_screen:
	rts
Wait_4_fade:
	rts
_SA_Hardcalc:
	rts
_SA_StartSong:
	rts
_SA_StopSong:
	rts
cls_bottom:
	rts
cls_top:
	rts
dpoly_koos3d:
	rts
draw_zoomshape:
	rts
put_dpoly:
	rts
zoom_screen:
	rts
zoom_screen2:
	rts

	SECTION	Fast_BSS,bss
Blitter_is_not_owned:	ds.w 1
Button_state:	ds.w 1
CA_Sp:	ds.l 1
CPU_68020_plus:	ds.w 1
Current_file_compression_space:	ds.l 1
Current_filename:	ds.l 1
Default_MA:	ds.w 4
Diagnostics_list1:	ds.l 4
Floor_X:	ds.w 1
Floor_Z:	ds.w 1
Floor_source_gfx:	ds.l 1
Ink_colour:	ds.w 1
Library_graphics:	ds.l 1
Mouse_X:	ds.w 1
Mouse_Y:	ds.w 1
Off_screen:	ds.l 1
Pixel_buffer:	ds.b 64
Return_value:	ds.l 1
Rune_flag:	ds.w 1
Screen_flag:	ds.w 1
Shadow_colour:	ds.w 1
VBL_counter:	ds.w 1
Version_string1_ptr:	ds.l 1
Version_string2_ptr:	ds.l 1
Vertical_screen_offset:	ds.w 1
Work_screen:	ds.l 1
Zoomscreen1_ptr:	ds.l 1
Zoomscreen2_ptr:	ds.l 1
