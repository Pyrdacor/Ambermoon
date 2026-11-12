; Falcon kernel : the renderer of the 3D maps (walls, objects, floor & ceiling)
; (Replaces 3D.S of the ST kernel.)
;
; The CPU version of the original renderer (MAP/3D_RENDER.S, AM2_CPU) runs as
; it is on the 68030 : it draws into the MOVEP screen of the 3D view, which
; [ Show_MOVEP_screen ] (GRAPHICS.S) puts on the screen. The parts of the
; blitter : ST_KERNEL/3D_CPU.S.

	include	MAP/3D_RENDER.S

	include	ST_KERNEL/3D_CPU.S

	SECTION	Program,code

;*****************************************************************************
; [ Draw a column of a wall ]
;   IN : like in the 3D.S of the ST kernel (the loops of the original : on
;        the 68030 the unrolled version of the ST is larger than the cache;
;        the number of lines - 1 : d7 here, d5 for the objects)
; Changed registers : d0,d7 (.w),a2,a4,a5
;*****************************************************************************
Wall_column_lsr:
	move.l	(a5),d0
	lsr.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,Wall_column_lsr
	rts

Wall_column_lsl:
	move.l	(a5),d0
	lsl.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,Wall_column_lsl
	rts

; [ Draw a column of a zoomed object ] (like in the 3D.S of the ST kernel)
Zoom_column_lsl:
	move.l	(a3),d0
	lsl.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	a5,a3
	lea.l	72(a4),a4
	dbra	d5,Zoom_column_lsl
	rts

Zoom_column_lsr:
	move.l	(a3),d0
	lsr.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	a5,a3
	lea.l	72(a4),a4
	dbra	d5,Zoom_column_lsr
	rts

; [ Draw a column of an object into the 3D view ] (like in the 3D.S of the
; ST kernel)
Shape_column_lsl:
	move.l	(a3),d0
	lsl.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a5)+,a3
	lea.l	72(a4),a4
	dbra	d5,Shape_column_lsl
	rts

Shape_column_lsr:
	move.l	(a3),d0
	lsr.l	d1,d0
	and.l	d4,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
	add.w	(a5)+,a3
	lea.l	72(a4),a4
	dbra	d5,Shape_column_lsr
	rts
