; Falcon kernel : the renderer of the 3D maps (walls, objects, floor & ceiling)
; (Replaces 3D.S of the ST kernel.)
;
; The CPU version of the original renderer (MAP/3D_RENDER.S, AM2_CPU) runs as
; it is on the 68030 : it draws into the MOVEP screen of the 3D view, which
; [ Show_MOVEP_screen ] (GRAPHICS.S) puts on the screen. The parts of the
; blitter : ST_KERNEL/3D_CPU.S.

	include	MAP/3D_RENDER.S

	include	ST_KERNEL/3D_CPU.S
