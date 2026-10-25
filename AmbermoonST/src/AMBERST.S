; Ambermoon for the Atari ST - proof of concept
; Build file: includes the original include files (constants, macros and
; structures of the Amiga version), the ST kernel and the proof of concept.
;
;   vasmm68k_mot -Ftos -m68000 -nosym -o AMBERST.PRG AMBERST.S

	include	"INCLUDES/ST_HARDWARE.I"
	include	"../../AmbermoonSource/src/INCLUDES/CONSTANTS.I"
	include	"../../AmbermoonSource/src/INCLUDES/MACROS.I"
	include	"../../AmbermoonSource/src/GAME_OFF.S"

	include	"KERNEL/START.S"
	include	"KERNEL/SYSTEM.S"
	include	"KERNEL/COLOURS.S"
	include	"KERNEL/GRAPHICS.S"
	include	"KERNEL/INPUT.S"
	include	"KERNEL/MOUSE.S"
	include	"KERNEL/TEXT.S"
	include	"KERNEL/FILES.S"
	include	"KERNEL/VARIOUS.S"
	include	"POC/MAP2D.S"
	include	"POC/PERSONS.S"
	include	"POC/MAPLOAD.S"
	include	"POC/EVENTS.S"
	include	"POC/LIGHT.S"
	include	"POC/INVENTORY.S"
	include	"POC/ITEMS.S"
	include	"POC/CHEST.S"
	include	"POC/DIALOGUE.S"
	include	"POC/STATUS.S"
	include	"POC/PLACES.S"
	include	"POC/COMBAT.S"
	include	"POC/COMBAT2.S"
	include	"POC/PARTY.S"
	include	"POC/TRANSPORT.S"
