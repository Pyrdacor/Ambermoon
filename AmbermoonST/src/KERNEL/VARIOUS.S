; Various routines taken unchanged from the Amiga version (HULL/VARIOUS.S)

	SECTION	Program,code

;*****************************************************************************
; [ Random number generator ]
;  OUT : d0 - Random number (.w)
; Changed registers : d0
;*****************************************************************************
Random:
	move.l	d1,-(sp)
	movem.w	Seed,d0-d1		; Get seed
	ror.w	#1,d0			; Calculate next seed
	addq.w	#7,d0
	eor.w	d1,d0
	exg.l	d0,d1
	movem.w	d0-d1,Seed		; Store
	andi.l	#$0000ffff,d0
	move.l	(sp)+,d1
	rts

	SECTION	Fast_DATA,data
Seed:	dc.w	$1234,$5678
