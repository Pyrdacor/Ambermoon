#!/usr/bin/env python3
"""Makes KERNEL/FANTASY.S from the output of intro_source.py : the changes for the ST and the Falcon (see
KERNEL/INTRO_COMMON.S and the FANTASY_HW.S of each machine).

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
# the sprites start here : before this the fairy has no position of her way yet
after(0xe16, ['st\tFantasy_visible'])
replace(0xff6, 0xff8, ['rts'])
replace(0x1018, 0x101a, ['rts'])
# the end of the interrupt : the fairy in the shown screen (the ST : like the sprites of the Amiga, every frame)
replace(0x100c, 0x1010, ['jsr	Fantasy_vbl', 'movem.l	(a7)+,d0-d7/a0-a6'])
replace(0xfe6, 0xfea, ['jsr	Fantasy_vbl', 'movem.l	(a7)+,d0-d7/a0-a6'])
# the frame : present and draw share the 3 ticks (the Amiga waits a tick after the copper
# so that the old screen is not shown any more : the Falcon shows its own screens)
after(0x226, ['clr.l	(Fant_h2+$a0).l'])
replace(0x22e, 0x238, [])
replace(0x248, 0x252, ['cmpi.l	#3,(Fant_h2+$a0).l'])
# a sparkle : straight to the blit of the sparkles (the same kind of blit every time)
replace(0x7fa, 0x7fe, ['jsr	Fantasy_sparkle'])
# the drawing : the machine can draw itself (the ST : into its screen, the routine returns with Z set), else the
# code of the Amiga goes on (the Falcon : Z clear)
replace(0xbc0, 0xbc6, ['jsr\tFantasy_draw_lower', 'bne.s\t*+4', 'rts', 'lea.l\t$dff000.l,a6'])
replace(0x348, 0x34e, ['jsr\tFantasy_draw_reveal', 'beq\tF003a0', 'lea.l\t$dff000.l,a6'])
replace(0x324, 0x326, ['blt.w\tF003a0'])     # (the code is longer now)
replace(0x32a, 0x32c, ['bge.w\tF003a0'])
# the free places of the new sparkles : the search goes on after the last one (the places before it are taken :
# the same places as before), not from the first place for every sparkle
replace(0x3a0, 0x3a2, ['moveq\t#$17,d7', 'lea.l\t(Fant_h2+$102).l,a0', 'move.w\t#$18f,d6'])
replace(0x3c6, 0x3d0, [])
after(0x3e0, ['subq.w\t#1,d6', 'bmi.s\tF003e6'])
replace(0x78c, 0x790, ['jsr\tFantasy_draw_sparkle', 'bne.s\t*+4', 'rts', 'movem.l\td2/a2,-(a7)'])
replace(0x804, 0x808, ['jsr\tFantasy_draw_small', 'bne.s\t*+4', 'rts', 'mulu.w\t#$c8,d1'])
replace(0x86e, 0x872, ['jsr\tFantasy_draw_dots', 'bne.s\t*+4', 'rts', 'mulu.w\t#$c8,d1'])
replace(0x72a, 0x72e, ['jsr\tFantasy_draw_dot', 'beq\tF00744', 'mulu.w\t#$c8,d1'])
HEAD = '''; ST kernel : the fairy of Thalion
; The code of the Amiga program Fantasy_intro (deploded and made from the
; executable with port/tools/intro_source.py and port/tools/fantasy_patch.py).
; The labels are the offsets in the code. The hardware of the Amiga :
; INTRO_COMMON.S, AMIGA_BLIT.S and the FANTASY_HW.S of the machine. The data
; are made by port/tools/intro_data.py.

	include	ST_KERNEL/FANTASY_HW.S

	SECTION	Program,code

'''
TAIL = '''
; The data (loaded from the file Fantasy_data) and the BSS : in the memory of
; the intro (INTRO_COMMON.S), before the intro
Fant_h1	EQU	Intro_area
Fant_h1_end	EQU	Fant_h1+Fant_h1_size
Fant_h2	EQU	Intro_area+((Fantasy_data_size+3)&-4)
Fant_h3	EQU	Fant_h2+$%x
Star_cache	EQU	Fant_h3+$%x		; (AMIGA_BLIT.S, INTRO.S : it fits)

	SECTION	Program,code
''' % (0x2224, 0x19320)
open(sys.argv[2], 'w', newline='\n').write(HEAD + S.text() + TAIL)
