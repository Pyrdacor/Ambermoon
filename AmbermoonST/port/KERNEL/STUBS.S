; ST kernel - stubs : the parts which are not ported yet (see PORT.md)
; diagnostic screen, 3D map drawing, zoom of the combat monsters.

	SECTION	Program,code
DI_CR:
	rts
DI_Print:
	rts
DI_Print_number:
	rts
DI_Print_text:
	rts
Draw_ceiling:
	rts
Draw_floor:
	rts
Draw_zoom_shape:
	rts
Draw_zoom_silhouette:
	rts
Exit_diagnostic_screen:
	rts
Init_diagnostic_screen:
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
Zoomscreen1_ptr:	ds.l 1
Zoomscreen2_ptr:	ds.l 1
cls_bottom:	ds.w 1
cls_top:	ds.w 1
dpoly_koos3d:	ds.w 64
zoom_screen:	ds.l 1
zoom_screen2:	ds.l 1
