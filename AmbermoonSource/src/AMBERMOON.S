; Ambermoon - main program (AM2)
; Build file : includes all modules in link order.
;
; Assemble with vasm (Motorola syntax), e.g. :
;   vasmm68k_mot -m68030 -Fhunkexe -o AM2_CPU -nosym -kick1hunks -keepempty -no-opt -align AMBERMOON.S
;
; The original code was assembled with some optimizations of the
; original assembler (short branches, zero displacements, MOVEQ, ADDQ/SUBQ,
; LEA -> ADDQ). These are switched on for the original modules only; the
; reconstructed code uses explicit encodings.
; -align : like the original assembler, DC/DS/RS .w/.l are aligned to even
;          addresses automatically.

; ---------- Fix the order of the hunks -----------
; (The sections are created in this order.)
	SECTION	Program,code
	SECTION	Chip_BSS,bss_c
	SECTION	Longword_BSS,bss
	SECTION	Chip_DATA,data_c
	SECTION	Fast_DATA,data
	SECTION	Buffer1_BSS,bss
	SECTION	Text_pointers,data
	SECTION	Buffer2_BSS,bss
	SECTION	Texts,code
	SECTION	Fast_BSS,bss
	SECTION	Chip_BSS2,bss_c
	SECTION	Blitter,code
	SECTION	Blitter2,code
	SECTION	Font_DATA,data

	include	INCLUDES/HARDWARE.I
	include	INCLUDES/MACROS.I
	include	INCLUDES/CONSTANTS.I
	include	GAME_OFF.S

; ---------- Modules (in link order) --------------
	opt	o1-,o2-,o4-,o5-,o11-		; reconstructed code : explicit encodings
	include	KERNEL/START.S
	opt	o2+,o4+,o5+,o11+		; original code : optimizations of the original assembler
	include	MAIN.S
	include	DISPLAY.S
	include	WORD_SEL.S
	include	INVENTOR.S
	include	ACTIONS.S
	include	DIALOGUE.S
	include	AUTOMAPP.S
	include	MAGIC.S
	include	MINIMAP.S
	include	CHARACTE.S
	include	MODULES.S
	include	MAP/MAP.S
	include	MAP/2D_MAP.S
	include	MAP/2D_CITY.S
	include	MAP/2D_WILD.S
	include	MAP/3D_MAP.S
	include	TIME.S
	include	EVENTS.S
	include	PLACES.S
	include	PERSONS.S
	include	DIAGNOST.S
	include	COMBAT/COMBAT.S
	include	COMBAT/APRES.S
	include	COMBAT/COMOBS.S
	include	COMBAT/TACTIC.S
	include	COMBAT/MONSTER_.S
	include	COMBAT/COMBAT_M.S
	include	COMBAT/REVERSE_.S
	opt	o1-,o2-,o4-,o5-,o11-		; reconstructed code : explicit encodings
	include	KERNEL/SYSTEM.S
	include	KERNEL/GRAPHICS.S
	include	KERNEL/COLOURS.S
	include	KERNEL/MOUSE.S
	include	KERNEL/TEXT.S
	include	KERNEL/MEMORY.S
	include	KERNEL/FILES.S
	include	KERNEL/INPUT.S
	include	KERNEL/DI_SCREEN.S
	opt	o2+,o4+,o5+,o11+		; original code : optimizations of the original assembler
	include	HULL/VARIOUS.S
	include	HULL/WORDS.S
	include	HULL/NUMERIC.S
	include	HULL/FADE.S
	include	HULL/MODULE_C.S
	include	HULL/OBJECT.S
	include	HULL/WINDOWS.S
	include	HULL/HDOBS.S
	include	HULL/CONTROLS.S
	include	HULL/EFFECTS.S
	opt	o1-,o2-,o4-,o5-,o11-		; reconstructed code : explicit encodings
	include	KERNEL/DATA.S
	include	KERNEL/CHIP_DATA.S
	include	KERNEL/CHIP_BSS.S
	include	KERNEL/FILES2.S
	include	MAP/3D_RENDER.S
	include	MUSIC/SONIC_ARRANGER.S
	include	KERNEL/ZOOM.S
	include	KERNEL/TEXTS.S
	include	MAP/3D_BLIT.S
	include	MAP/3D_BLIT2.S
	include	KERNEL/BUFFERS.S
