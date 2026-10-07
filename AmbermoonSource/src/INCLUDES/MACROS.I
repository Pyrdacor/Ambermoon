; Macros of the kernel (reconstructed)
; These macros are used by the original source code but their definitions
; are missing in the source snapshot. They were reconstructed from the
; machine code of AM2_CPU.

;*****************************************************************************
; [ Get the address of a memory block ]
;   IN : \1 - Memory handle (.b)
;  OUT : \2 - Address of memory block (.l)
;*****************************************************************************
Get	macro
	move.l	d0,-(sp)
	move.b	\1,d0
	jsr	Claim_pointer
	move.l	d0,\2
	move.l	(sp)+,d0
	endm

;*****************************************************************************
; [ Release the address of a memory block ]
;   IN : \1 - Memory handle (.b)
;*****************************************************************************
Free	macro
	move.w	d0,-(sp)
	move.b	\1,d0
	jsr	Free_pointer
	move.w	(sp)+,d0
	endm

;*****************************************************************************
; [ Push something on a stack ]
;   IN : \1 - Stack type (Module, CA, MA, PA, Mptr, Scroll_bar, Tree)
;        \2 - Address of the new entry
;*****************************************************************************
Push	macro
	lea.l	\2,a0
	jsr	Push_\1
	endm

;*****************************************************************************
; [ Pop something from a stack ]
;   IN : \1 - Stack type (Module, CA, MA, PA, Mptr, Scroll_bar, Tree)
;*****************************************************************************
Pop	macro
	jsr	Pop_\1
	endm

;*****************************************************************************
; [ Start a new scope for local labels ]
;*****************************************************************************
LOCAL	macro
Local_scope\@:
	endm

;*****************************************************************************
; [ Call the music routine ]
;   IN : \1 - Music_init, Music_start or Music_stop
;*****************************************************************************
music	macro
	jsr	\1
	endm
Music_init	EQU	_SA_Hardcalc
Music_start	EQU	_SA_StartSong
Music_stop	EQU	_SA_StopSong

;*****************************************************************************
; [ Set the background colour (debugging) ]
;   IN : \1 - Colour
;*****************************************************************************
XX	macro
	move.w	#\1,$dff180
	endm

;*****************************************************************************
; [ Fingerprint (disabled in the release version) ]
;*****************************************************************************
FINGERPRINT	macro
	endm

;*****************************************************************************
; [ Start of a separately assembled object ]
; The original program was linked from several object files. The linker
; aligns every section of an object to a longword boundary.
;*****************************************************************************
New_object	macro
	SECTION	Program,code
	cnop	0,4
	SECTION	Chip_BSS,bss_c
	cnop	0,4
	SECTION	Longword_BSS,bss
	cnop	0,4
	SECTION	Chip_DATA,data_c
	cnop	0,4
	SECTION	Fast_DATA,data
	cnop	0,4
	SECTION	Fast_BSS,bss
	cnop	0,4
	endm

;*****************************************************************************
; [ Align the RS counter to an even address ]
;*****************************************************************************
rseven	macro
	rsset	(__RS+1)&-2
	endm

;*****************************************************************************
; [ Raster list entries ]
; R_palette - Set a complete palette from line \1 on (\2 = palette)
; R_range   - Set \3 colours starting with colour \2 from line \1 on (\4 = colours)
; R_end     - End of raster list
;*****************************************************************************
R_palette	macro
	dc.b 0,\1
	dc.l \2
	endm
R_range	macro
	dc.b 1,\1,\2,\3
	dc.l \4
	endm
R_end	macro
	dc.b -1,0
	endm
