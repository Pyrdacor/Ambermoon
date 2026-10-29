; ST kernel - the renderer of the 3D maps (walls, objects, floor & ceiling)
; Not ported yet for the ST : MAP/3D_RENDER.S (the CPU version of the
; original) uses 68020 instructions. The Falcon version includes it
; (AmbermoonFalcon/KERNEL/3D.S).

	SECTION	Program,code
Draw_ceiling:
	rts
Draw_floor:
	rts
Insert_horizon:
	rts
draw_zoomshape:
	rts
put_dpoly:
	rts

	SECTION	Fast_BSS,bss
Floor_X:	ds.w 1
Floor_Z:	ds.w 1
Floor_source_gfx:	ds.l 1
cls_bottom:	ds.w 1
cls_top:	ds.w 1
dpoly_koos3d:	ds.w 64
zoom_screen:	ds.l 1
zoom_screen2:	ds.l 1
