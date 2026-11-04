; ST kernel - the zoom of the combat monsters (KERNEL/ZOOM.S of the Amiga
; version : the blitter). Not ported yet for the ST : a zoomed monster is not
; drawn (the Falcon version : AmbermoonFalcon/KERNEL/ZOOM.S).

	SECTION	Program,code
Draw_zoom_shape:
	rts
Draw_zoom_silhouette:
	rts

	SECTION	Fast_BSS,bss
Zoomscreen1_ptr:	ds.l 1
Zoomscreen2_ptr:	ds.l 1
