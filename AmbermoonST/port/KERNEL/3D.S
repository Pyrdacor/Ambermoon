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

	SECTION	Program,code

; [ The blocks of a column ] (\1 : the shift, \2 : the next line of the
; source, \3 : the source; see [ Column_entry ])
Column_blocks	macro
	bsr.w	Column_entry
N	SET	1
	REPT	Column_lines
	move.l	(\3),d0
	\1	d1,d0
	and.l	d4,d0
	and.l	d2,N*72(a4)
	or.l	d0,N*72(a4)
	\2
N	SET	N+1
	ENDR
	rts
	endm

Column_lines	EQU	144		; (the clip area of the 3D view)

;*****************************************************************************
; [ Draw a column of a wall (unrolled) ]
;   IN : d0 - Number of lines - 1 (.w)
;        d1 - Shift of the texture (.w)
;        d2 - Mask of the other pixels (.l)
;        d4 - Mask of the pixel (.l)
;        a2 - Pointer to the steps of the zoom (zoom_ptrbuff) (.l)
;        a4 - Pointer to the MOVEP screen (.l)
;        a5 - Pointer to the texture (.l)
; Changed registers : d0,a2,a4,a5
; NOTE :
;   - The loops .Loop3/.Loop4 and .Loop6/.Loop7 of [ CPU_put_dpoly ]
;     (PATCHES/3D_RENDER.diff), without the loop : one block per line (see
;     [ Column_entry ]). The pixel of the texture is shifted to the right
;     (lsr) or to the left (lsl).
;*****************************************************************************
Wall_column_lsr:
	Column_blocks	lsr.l,<add.w (a2)+,a5>,a5
Wall_column_lsl:
	Column_blocks	lsl.l,<add.w (a2)+,a5>,a5

;*****************************************************************************
; [ Draw a column of a zoomed object (unrolled) ]
;   IN : d0 - Number of lines - 1 (.w)
;        d1 - Shift of the graphics (.w)
;        d2 - Mask of the other pixels (.l)
;        d4 - Mask of the pixel (.l)
;        a3 - Pointer to the graphics (.l)
;        a4 - Pointer to the zoom screen (.l)
;        a5 - Bytes per line of the graphics (.w)
; Changed registers : d0,a3,a4
; NOTE :
;   - The loops .Loop2/.Loop3 of [ CPU_zoom_columns ]
;     (PATCHES/3D_RENDER.diff), like [ Wall_column_lsr ].
;*****************************************************************************
Zoom_column_lsl:
	Column_blocks	lsl.l,<add.w a5,a3>,a3
Zoom_column_lsr:
	Column_blocks	lsr.l,<add.w a5,a3>,a3

;*****************************************************************************
; [ Draw a column of an object into the 3D view (unrolled) ]
;   IN : like [ Zoom_column_lsl ], but :
;        a4 - Pointer to the MOVEP screen (.l)
;        a5 - Pointer to the steps of the lines (Zoomshape_Y_table) (.l)
; Changed registers : d0,a3,a4,a5
; NOTE :
;   - The loops .Loop2/.Loop3 of [ CPU_draw_zoomshape ]
;     (PATCHES/3D_RENDER.diff), like [ Wall_column_lsr ].
;*****************************************************************************
Shape_column_lsl:
	Column_blocks	lsl.l,<add.w (a5)+,a3>,a3
Shape_column_lsr:
	Column_blocks	lsr.l,<add.w (a5)+,a3>,a3

;*****************************************************************************
; [ The first block of a column ]
;   IN : d0 - Number of lines - 1 (.w)
;        a4 - Pointer to the first line (.l)
;        (sp) - Pointer to the blocks (.l)
;  OUT : a4 - The pointer of the block of line 1 (.l)
;        (sp) - Pointer to the first block (.l)
; Changed registers : d0,a4
; NOTE :
;   - One block per line, the block of line N writes at N * 72 (not 0 : the
;     size of the blocks stays 16 bytes); the first block is the one of the
;     number of lines (up to 144, the clip area of the 3D view).
;*****************************************************************************
Column_entry:
	neg.w	d0			; Blocks skipped + 1
	addi.w	#Column_lines,d0
	lsl.w	#3,d0			; (* 72)
	suba.w	d0,a4
	lsl.w	#3,d0
	suba.w	d0,a4
	lsr.w	#2,d0			; (16 bytes per block)
	subi.w	#16,d0
	ext.l	d0
	add.l	d0,(sp)
	rts
