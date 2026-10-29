; ST kernel - stubs : the parts which are not ported yet (see PORT.md)
; diagnostic screen, zoom of the combat monsters. (The 3D maps : 3D.S.)

	SECTION	Program,code
DI_CR:
	rts
DI_Print:
	rts
DI_Print_number:
	rts
DI_Print_text:
	rts
Draw_zoom_shape:
	rts
Draw_zoom_silhouette:
	rts
Exit_diagnostic_screen:
	rts
Init_diagnostic_screen:
	rts

	SECTION	Fast_BSS,bss
Zoomscreen1_ptr:	ds.l 1
Zoomscreen2_ptr:	ds.l 1
