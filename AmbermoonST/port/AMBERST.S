; Ambermoon for the Atari ST - port of the original source (see PORT.md)
;
; Build file : the include list of AMBERMOON.S. The files which depend on the
; Amiga hardware are replaced by the ST kernel (ST_KERNEL/), they are marked
; "; ST:". Built by port/build.sh (the sources are copied to build/port/src).

; ---------- Fix the order of the hunks -----------
; (The sections are created in this order.)
	SECTION	Program,code
	SECTION	Chip_BSS,bss
	SECTION	Longword_BSS,bss
	SECTION	Chip_DATA,data
	SECTION	Fast_DATA,data
	SECTION	Buffer1_BSS,bss
	SECTION	Text_pointers,data
	SECTION	Buffer2_BSS,bss
	SECTION	Texts,code
	SECTION	Fast_BSS,bss
	SECTION	Chip_BSS2,bss
	SECTION	Blitter,code
	SECTION	Blitter2,code
	SECTION	Font_DATA,data

	include	INCLUDES/HARDWARE.I
	include	INCLUDES/MACROS.I
	include	INCLUDES/CONSTANTS.I
	include	GAME_OFF.S
	include	ST_KERNEL/ST_HARDWARE.I	; ST:

; ---------- Modules (in link order) --------------
	opt	o1-,o2-,o4-,o5-,o11-		; reconstructed code : explicit encodings
;include	KERNEL/START.S		; ST: replaced by the ST kernel
	SECTION	Program,code		; ST: TOS starts at the beginning of the
	jmp	Start			;  text segment
	IFD	DEBUG
	include	KERNEL/DEBUG_AE.S	; Debug build only
	ENDC
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
;include	KERNEL/SYSTEM.S		; ST: replaced by the ST kernel
;include	KERNEL/GRAPHICS.S		; ST: replaced by the ST kernel
;include	KERNEL/COLOURS.S		; ST: replaced by the ST kernel
;include	KERNEL/MOUSE.S		; ST: replaced by the ST kernel
;include	KERNEL/TEXT.S		; ST: replaced by the ST kernel
	include	KERNEL/MEMORY.S
	include	KERNEL/FILES.S
	include	KERNEL/INPUT.S
;include	KERNEL/DI_SCREEN.S		; ST: replaced by the ST kernel
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
;include	MAP/3D_RENDER.S		; ST: replaced by the ST kernel
;include	MUSIC/SONIC_ARRANGER.S		; ST: replaced by the ST kernel
;include	KERNEL/ZOOM.S		; ST: replaced by the ST kernel
	include	KERNEL/TEXTS.S
;include	MAP/3D_BLIT.S		; ST: replaced by the ST kernel
;include	MAP/3D_BLIT2.S		; ST: replaced by the ST kernel
	include	KERNEL/BUFFERS.S

; ---------- ST kernel ----------------------------
	include	ST_KERNEL/START.S		; ST:
	include	ST_KERNEL/SYSTEM.S		; ST:
	include	ST_KERNEL/COLOURS.S		; ST:
	include	ST_KERNEL/MOUSE.S		; ST:
	include	ST_KERNEL/POINTER.S		; ST:
	include	ST_KERNEL/GRAPHICS.S		; ST:
	include	ST_KERNEL/TEXT.S		; ST:
	include	ST_KERNEL/IKBD.S		; ST:
	include	ST_KERNEL/LIBS.S		; ST:
	include	ST_KERNEL/STUBS.S		; ST: (stage 1)
