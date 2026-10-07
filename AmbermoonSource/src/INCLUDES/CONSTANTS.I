; Constants (reconstructed)
; These constants are used by the original source code, but their
; definitions are missing in the source snapshot (they were part of the
; kernel include files). The values were recovered from AM2_CPU.

; ---------- Assembly flags --------------------------
Cheat	EQU	0
FALSE	EQU	0
Fingerprint	EQU	0

; ---------- AmigaDOS error codes --------------------
ERROR_DIR_NOT_FOUND	EQU	204
ERROR_DISK_FULL	EQU	221
ERROR_DISK_NOT_VALIDATED	EQU	213
ERROR_DISK_WRITE_PROTECTED	EQU	214
ERROR_INCOMPLETE_READ	EQU	500
ERROR_INCOMPLETE_WRITE	EQU	501
ERROR_INVALID_COMPONENT_NAME	EQU	210
ERROR_NOT_A_DOS_DISK	EQU	225
ERROR_NO_FREE_STORE	EQU	103
ERROR_OBJECT_EXISTS	EQU	203
ERROR_OBJECT_IN_USE	EQU	202
ERROR_OBJECT_NOT_FOUND	EQU	205
ERROR_OBJECT_TOO_LARGE	EQU	207
ERROR_OBJECT_WRONG_TYPE	EQU	212
ERROR_READ_PROTECTED	EQU	224
ERROR_RENAME_ACROSS_DEVICES	EQU	215
ERROR_SEEK_ERROR	EQU	219
ERROR_WRITE_PROTECTED	EQU	223

; ---------- Kernel error codes ----------------------
CR	EQU	94
ENDLESS_EVENT	EQU	-4002
GAME_COMPLETED	EQU	-5000
MERGED_TEXT_TOO_LONG	EQU	-3001
OS_ERROR	EQU	-1000
PROCESSED_TEXT_TOO_LONG	EQU	-3002

; ---------- Screen ----------------------------------
Bytes_per_line	EQU	200
Char_height	EQU	5
Char_width	EQU	5
Icon_size	EQU	160
Pal_size	EQU	32
Screen_depth	EQU	5
Screen_height	EQU	200
Screen_width	EQU	20

; ---------- Clip areas (CA) -------------------------
CA_X1	EQU	0
CA_X2	EQU	2
CA_Y1	EQU	4
CA_Y2	EQU	6
CA_data_size	EQU	8

; ---------- Mouse areas (MA) ------------------------
MA_X1	EQU	0
MA_X2	EQU	2
MA_Y1	EQU	4
MA_Y2	EQU	6
MA_ptr	EQU	50

; ---------- Print areas (PA) ------------------------
PA_Ink	EQU	8
PA_Paper	EQU	12
PA_Shadow	EQU	10
PA_X1	EQU	0
PA_X2	EQU	2
PA_Y1	EQU	4
PA_Y2	EQU	6
PA_data_size	EQU	14
PA_ptr	EQU	46

; ---------- Objects (object tree) -------------------
Obj_X1	EQU	0
Obj_X2	EQU	2
Obj_Y1	EQU	4
Obj_Y2	EQU	6
Obj_brother	EQU	10
Obj_child	EQU	14

; ---------- HDOBs (hardware/display objects) --------
HDOB_base_colour	EQU	10
HDOB_bg_handle	EQU	4
HDOB_depth	EQU	8
HDOB_drawX	EQU	0
HDOB_drawY	EQU	2
HDOB_flag	EQU	17
HDOB_gfx_handle	EQU	16
HDOB_height	EQU	6
HDOB_offset	EQU	12
HDOB_oldX	EQU	0
HDOB_oldY	EQU	2
HDOB_screen1	EQU	18
HDOB_screen2	EQU	24
HDOB_width	EQU	4

; ---------- Modules ---------------------------------
DisExit_ptr	EQU	34
DisInit_ptr	EQU	30
DisUpd_ptr	EQU	2
Global_mod	EQU	0
Kev_ptr	EQU	18
Local_mod	EQU	1
Mev_ptr	EQU	14
ModExit_ptr	EQU	26
ModInit_ptr	EQU	22
Module_ID	EQU	1
Module_data_size	EQU	54
Mouse_ptr	EQU	42
Raster_list_ptr	EQU	38
ScrQ_ptr	EQU	10
VblQ_ptr	EQU	6

; ---------- Maxima ----------------------------------
Max_HDOBs	EQU	8
Max_PA	EQU	12
Max_batch	EQU	64
Max_input_length	EQU	50
Max_modules	EQU	8
Max_scroll_bars	EQU	3
Max_songs	EQU	32
Max_trees	EQU	8
Max_windows	EQU	4

; ---------- Other -----------------------------------
Amiga_key	EQU	28
Block_subfile_nr	EQU	22
Command_char	EQU	126
Cursor_colour	EQU	28
Cursor_interval	EQU	10
Default_safety_factor	EQU	$400
Fade_out	EQU	3
GAME_COMPLETED2	EQU	-5001
GAME_COMPLETED3	EQU	-5002
Ink_command	EQU	$494e4b20
Left_pressed	EQU	0
Right_clicked	EQU	5
Right_pressed	EQU	4
Save_game_disk	EQU	10
Set_new	EQU	1
Start_fade_in	EQU	2

