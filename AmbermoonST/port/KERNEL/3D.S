; ST kernel - the renderer of the 3D maps (walls, objects, floor & ceiling)
;
; The CPU version of the original renderer (MAP/3D_RENDER.S, AM2_CPU) : it
; draws into the MOVEP screen of the 3D view, which [ Show_MOVEP_screen ]
; (GRAPHICS.S) puts on the screen. Floor and ceiling ([ Draw_floor ],
; [ Draw_ceiling ]) use 68020 instructions : they are only drawn on a 68020
; or better ([ CPU_68020_plus ], like on the Amiga), the ST never calls them.
; (The Falcon version has its own 3D.S, without the change of the CPU.)

	machine	68020
	include	MAP/3D_RENDER.S
	machine	68000

	include	ST_KERNEL/3D_CPU.S
