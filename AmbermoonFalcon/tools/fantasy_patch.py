#!/usr/bin/env python3
"""Makes KERNEL/FANTASY.S from the output of intro_source.py : the changes for the Falcon (see KERNEL/FANTASY_HW.S).

    fantasy_patch.py <generated.s> <FANTASY.S>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from patchlib import Source

S = Source(sys.argv[1])
replace, after = S.replace, S.after

# entry : no system, no interrupts
replace(0x0, 0x110, [])
# the end of the program
replace(0x2b0, 0x316, ['jsr\tFantasy_exit', 'rts'])
# the screens and the interrupt
replace(0xd22, 0xd84, ['jsr\tFantasy_init', 'rts'])
# the picture is in the Amiga screens : converted completely
after(0x134, ['jsr\tFantasy_new_picture'])
# the copper list, the screen change
replace(0xc98, 0xd12, ['jsr\tFantasy_present', 'rts'])
# the interrupt : buttons, colours, return
after(0xd8e, ['jsr\tIntro_buttons'])
after(0xdb0, ['jsr\tFantasy_palette'])
replace(0xff6, 0xff8, ['rts'])
replace(0x1018, 0x101a, ['rts'])
HEAD = '''; Falcon kernel : the fairy of Thalion
; The code of the Amiga program Fantasy_intro (deploded and made from the
; executable with tools/intro_source.py and tools/fantasy_patch.py). The labels
; are the offsets in the code. The hardware of the Amiga : FANTASY_HW.S and
; INTRO_HW.S. The data hunk is made by tools/intro_data.py.

	include	ST_KERNEL/FANTASY_HW.S

	SECTION	Program,code

'''
TAIL = '''
	SECTION	Fast_DATA,data
	even
Fant_h1:
	incbin	"ST_KERNEL/FANT_H1.BIN"
	even

	SECTION	Fast_BSS,bss
Fant_h2:	ds.b	$%x
	even
Fant_h3:	ds.b	$%x

	SECTION	Program,code
''' % (0x2224, 0x19320)
open(sys.argv[2], 'w', newline='\n').write(HEAD + S.text() + TAIL)
