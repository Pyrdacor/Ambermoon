; ST kernel : music
;
; The music of the ST version : one player ([ Music_player ], made by
; port/tools/port_music.py) and the data of the songs in Music.amb. The
; player finds the data of a song directly behind itself : [ _SA_Hardcalc ]
; copies the loaded song there. The player sounds with the YM2149, uses
; Timer A and (instead of Timer B, which shows the raster) Timer D for its
; effects, and is called by the vertical blank handler.
; The routines replace those of the Amiga player (see INCLUDES/MACROS.I).

	SECTION	Program,code

;*****************************************************************************
; [ Take a song ]
;   IN : a0 - Pointer to the song (size (.l), data) (.l)
; All registers are restored
;*****************************************************************************
_SA_Hardcalc:
	movem.l	d0/a0/a1,-(sp)
	jsr	_SA_StopSong
	move.l	(a0)+,d0
	move.l	d0,Music_size
	beq.s	.Exit			; (no ST version of this song)
	lea.l	Music_data,a1
	addq.w	#1,d0			; (at most 16K)
	lsr.w	#1,d0
	subq.w	#1,d0
.Copy:	move.w	(a0)+,(a1)+
	dbra	d0,.Copy
.Exit:	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Start / stop the song ]
; All registers are restored
; NOTE :
;   - The ST version has one song per file, the song number is ignored.
;*****************************************************************************
_SA_StartSong:
	tst.l	Music_size		; Any song ?
	beq.s	.Exit
	tst.b	Music_playing
	bne.s	.Exit
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	sr,-(sp)
	ori.w	#$0700,sr
	moveq.l	#1,d0			; Start
	jsr	Music_player
	st	Music_playing
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-d7/a0-a6
.Exit:	rts

_SA_StopSong:
	tst.b	Music_playing		; Playing ?
	beq.s	.Exit
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	sr,-(sp)
	ori.w	#$0700,sr
	sf	Music_playing
	moveq.l	#0,d0			; Stop (sound off, the timers as
	jsr	Music_player		;  before the start)
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-d7/a0-a6
.Exit:	rts

;*****************************************************************************
; [ Play the song (vertical blank) ]
;*****************************************************************************
_SA_IrqLowLevel:
	tst.b	Music_playing
	beq.s	.Exit
	jsr	Music_player+8
.Exit:	rts

;*****************************************************************************
; [ The control register of Timer D (for the player) ]
; NOTE :
;   - Timer D shares its control register with Timer C, which the disk
;     drivers need : only the lower 4 bits are changed.
;   - [ Music_timer_D_get ] : OUT d0 (.b), [ Music_timer_D_set ] : IN d1 (.b)
;*****************************************************************************
Music_timer_D_off:
	andi.b	#$f0,MFP_TCDCR
	rts

Music_timer_D_get:
	move.b	MFP_TCDCR,d0
	andi.b	#$0f,d0
	rts

Music_timer_D_set:
	move.w	d1,-(sp)
	andi.b	#$0f,d1
	andi.b	#$f0,MFP_TCDCR
	or.b	d1,MFP_TCDCR
	move.w	(sp)+,d1
	rts

	include	ST_KERNEL/MUSPLAY.I
Music_data:	ds.b 16384			; The song (behind the player)
	IFNE	Music_data-Music_player-8314
	FAIL	"Music_data must follow the player directly"
	ENDC

	SECTION	Fast_BSS,bss
Music_size:	ds.l 1
Music_playing:	ds.b 1
	even
