#!/usr/bin/env python3
"""Makes KERNEL/INTRO.S from the output of intro_source.py : the changes for the ST and the Falcon (see
KERNEL/INTRO_COMMON.S and the INTRO_HW.S of each machine).

    intro_patch.py <generated.s> <INTRO.S>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from patchlib import Source

S = Source(sys.argv[1])
replace, after = S.replace, S.after

H5 = '(Intro_h5+$%x).l'
# entry : no system, no interrupts
replace(0x0, 0x12c, [])
# the music : the player of the kernel (the songs of the machine : INTRO_HW.S)
replace(0x24a, 0x252, ['jsr\tIntro_music_init'])
replace(0x25e, 0x268, ['jsr\tIntro_song'])
replace(0xc96, 0xc9c, [])
replace(0xc9e, 0xca2, ['jsr\tIntro_song'])
replace(0x282c, 0x2836, ['jsr\t_SA_IrqLowLevel'])
# the comet : the steps wait for their time, the late ones are not drawn (the impact belongs to the music)
replace(0xb20, 0xb24, ['jsr\tIntro_comet_late', 'bne.w\tL00bfc', 'bsr.w\tL0288a'])
# end of the program
replace(0x1158, 0x11c8, ['jsr\t_SA_StopSong', 'jsr\tIntro_exit', 'rts'])
# the menu draws into the shown screen : converted when it changed
replace(0x10cc, 0x10d0, ['jsr	Intro_menu_wait'])
after(0x124a, ['st	Intro_dirty'])
# the end of the stars : they stay in the Amiga screen
after(0x3b6, ['jsr	Intro_freeze_stars'])
# the intro was skipped : the picture of the menu is shown at once (the fade)
after(0x0d90, ['jsr	Intro_present'])
# the menu goes to 5 planes : its picture stays on the screen (no frame with the new layout)
replace(0xfa0, 0xfa8, [])
# the start : the first picture after the screens are cleared (the copper list on the Amiga comes before)
replace(0x200, 0x204, [])
after(0x238, ['jsr	Intro_present'])
# the screens are cleared : shown at once, the new colours come next (the old logo must not get them)
after(0x13ca, ['jsr	Intro_present'])
# the stars start : only they are in plane 4
after(0x268, ['jsr	Intro_clear_stars'])
# the pointer of the menu
after(0x10b0, ['jsr\tIntro_pointer_on'])
replace(0x1136, 0x113c, ['clr.l\t' + H5 % 0x12174, 'jsr\tIntro_pointer_off'])
# the menu entry INTRO : Z set : the intro of the Amiga program again (the ST : its own intro, Run_intro)
replace(0x1146, 0x114e, ['jsr\tIntro_replay'])
# the colours of the main menu come (Intro_menu_in : at once after the intro of the machine)
replace(0xd94, 0xd9e, ['jsr\tIntro_menu_in'])
# the system
# the copper list, the screen change
replace(0x2452, 0x24cc, ['jsr\tIntro_present', 'rts'])
replace(0x24cc, 0x251e, ['jsr\tIntro_init', 'rts'])
replace(0x289a, 0x28de, ['jmp\tIntro_video'])
replace(0x2738, 0x2744, [])
# the interrupt : colours, buttons, mouse, stars, return
replace(0x252c, 0x254e, ['jsr\tIntro_buttons', 'jsr\tIntro_palette'])
replace(0x255e, 0x263e, ['jsr\tIntro_mouse'])
replace(0x2646, 0x2664, ['jsr\tIntro_stars'])
replace(0x283a, 0x2848, ['rts'])
# the stars : offsets in a screen of the machine (d0 must stay : the direction of the star)
replace(0x1ac4, 0x1acc, ['jsr\tIntro_star_offset'])
HEAD = '''; ST kernel : the intro and the main menu
; The code of the Amiga program Ambermoon_intro (made from the executable with
; port/tools/intro_source.py and port/tools/intro_patch.py : without the
; changes it assembles to the same bytes). The labels are the offsets in the
; code. The hardware of the Amiga : INTRO_COMMON.S, AMIGA_BLIT.S and the
; INTRO_HW.S of the machine. The data are made by port/tools/intro_data.py.

	include	ST_KERNEL/INTRO_COMMON.S
	include	ST_KERNEL/AMIGA_BLIT.S
	include	ST_KERNEL/INTRO_HW.S
	include	ST_KERNEL/FANTASY.S

	SECTION	Program,code

; [ The intro and the main menu ]
;   IN : d0 - There is a savegame ($ff) or not (0) (.b)
;        d1 - The intro is skipped ($ff : the menu at once) or not (0) (.b)
;  OUT : d0 - The chosen menu entry (.w)
Intro_main:
	move.b	d0,(Intro_h5+$12212).l
	move.b	d1,(Intro_h5+$12213).l
	jsr	L0012c
	moveq.l	#0,d0
	move.w	(Intro_h5+$12172).l,d0
	rts

'''
TAIL = '''
	SECTION	Fast_DATA,data
	even
Intro_h1:
	include	ST_KERNEL/INTRO_H1.I
	even
Intro_music_module:
	incbin	"ST_KERNEL/INTRO_MU.BIN"
	even

; The data hunks 2-4 (loaded from the file Intro_data) and the BSS : the memory
; of the intro, the last part of the BSS (INTRO_COMMON.S)
	include	ST_KERNEL/INTRO.I
	SECTION	Intro_BSS,bss
Intro_area:
Intro_h2:	ds.b	Intro_h2_size
Intro_h3:	ds.b	Intro_h3_size
Intro_h4:	ds.b	Intro_h4_size
Intro_h5:	ds.b	$%x
	even
Intro_h6:	ds.b	$%x
Intro_h6_end:
	include	ST_KERNEL/INTRO_ST.I		; (the intro of the ST : its data and a screen,
	IFGT	Intro_st_size+256+Screen_size-(*-Intro_area)	;  more memory when it needs it)
	ds.b	Intro_st_size+256+Screen_size-(*-Intro_area)
	ENDC
	IFNE	Intro_st_size			; (its screen stays until the menu is there)
	IFLT	Intro_st_size-(Intro_h6_end-Intro_area)
	FAIL	"The last screen of the intro of the ST is in the memory of the Amiga program"
	ENDC
	ENDC
Intro_area_end:
	IFGT	Star_cache+Star_slots*512-Intro_area_end
	FAIL	"The fairy needs more memory than the intro"
	ENDC

	SECTION	Program,code
''' % (0x488c * 4, 0x915b * 4)
open(sys.argv[2], 'w', newline='\n').write(HEAD + S.text() + TAIL)
