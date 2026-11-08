#!/usr/bin/env python3
"""Makes KERNEL/EXTRO.S from the output of intro_source.py : the changes for the Falcon (see
AmbermoonFalcon/KERNEL/EXTRO_HW.S; written there).

    extro_patch.py <generated.s> <EXTRO.S>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from patchlib import Source

S = Source(sys.argv[1])
replace, after = S.replace, S.after

# entry : no system (the music and the kind of the ending come from Run_extro)
replace(0x0, 0x120, [])
# the program : no interrupt levels, the screens and the interrupt of the kernel
replace(0x120, 0x124, [])
replace(0x12a, 0x156, ['jsr\tExtro_init'])
replace(0x1a0, 0x1a4, [])
# the music : the replay of the kernel
replace(0x20e, 0x216, ['lea.l\tExtro_music_module,a0', 'jsr\t_SA_Hardcalc'])
replace(0x218, 0x222, ['jsr\t_SA_StartSong'])
replace(0x352, 0x35c, ['jsr\t_SA_StopSong'])
replace(0xf38, 0xf42, ['jsr\t_SA_IrqLowLevel'])
# end of the program
replace(0x35c, 0x3c8, ['jsr\tIntro_exit', 'movea.l\t(Extro_h4+$0).l,a7', 'rts'])
# a new picture is in the Amiga screens : converted into the screens of the Falcon
after(0x2e8, ['jsr\tExtro_picture'])
# a frame of the text : the picture, and the brightened picture where the text is, straight into the
# screen of the Falcon (5 blits on the Amiga)
replace(0x44a, 0x4c0, ['jsr\tExtro_compose'])
# the copper list, the screen change
replace(0xebc, 0xf26, ['jmp\tExtro_present'])
replace(0xf8e, 0xfd2, ['jmp\tIntro_video'])
# the interrupt : buttons, colours, return
after(0xf2a, ['jsr\tIntro_buttons', 'jsr\tExtro_palette'])
replace(0xf46, 0xf54, ['rts'])
HEAD = '''; Falcon kernel : the extro (the end of the game)
; The code of the Amiga program Ambermoon_extro (deploded and made from the
; executable with AmbermoonST/port/tools/intro_source.py and extro_patch.py).
; The labels are the offsets in the code. The hardware of the Amiga :
; EXTRO_HW.S, INTRO_HW.S and ST_KERNEL/INTRO_COMMON.S. The data hunks are made
; by AmbermoonST/port/tools/intro_data.py.

	include	ST_KERNEL/EXTRO_HW.S

	SECTION	Program,code

'''
TAIL = '''
	SECTION	Fast_DATA,data
	even
Extro_h1:
	include	ST_KERNEL/EXTRO_H1.I
	even
Extro_h2:
	incbin	"ST_KERNEL/EXTRO_H2.BIN"
	even
Extro_music_module:
	incbin	"ST_KERNEL/EXTRO_MU.BIN"
	even

	SECTION	Fast_BSS,bss
Extro_h4:	ds.b	$%x
	even

	SECTION	Program,code
''' % 0xc0
open(sys.argv[2], 'w', newline='\n').write(HEAD + S.text() + TAIL)
