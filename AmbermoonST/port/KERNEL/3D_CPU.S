; ST kernel - the parts of MAP/3D_BLIT.S (the Amiga blitter) which the CPU
; renderer of the 3D maps (MAP/3D_RENDER.S) needs : their CPU versions
; (included by 3D.S, of the ST and of the Falcon)
;
; MAP/3D_BLIT.S is left out, its entry points go to the CPU versions here
; ([ Blitter_or_CPU ] is always set : the TOS has no loader which clears it).

	SECTION	Program,code
Insert_horizon:
	jmp	CPU_insert_horizon
put_dpoly:
	jmp	CPU_put_dpoly
draw_zoomshape:
	jmp	CPU_draw_zoomshape
Blit_edge_loop:			; (not called : Blitter_or_CPU is set)
	jmp	CPU_edge_loop

;*****************************************************************************
; [ Interpolate the wall edges (CPU version) ]
;   IN : d7 - Number of columns (.w)
;        a0 - Pointer to edge table (.l)
; NOTE :
;   - From MAP/3D_BLIT.S.
;*****************************************************************************
CPU_edge_loop:
	subq.w	#1,d7
.Loop:
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	dbra	d7,.Loop
	moveq.l	#0,d0
	rts
