; 3D renderer : blitter versions (merged AM2_BLIT)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Blitter,code

;*****************************************************************************
; [ Insert the horizon (sky/background) into the 3D view ]
;   IN : a0 - Pointer to horizon graphics (.l)
;        a1 - Pointer to MOVEP screen position (.l)
; NOTE :
;   - Calls the CPU or the blitter version depending on [ Blitter_or_CPU ].
;   - In 1.21 the AM2_CPU and AM2_BLIT executables were merged into one.
;*****************************************************************************
Insert_horizon:
	tst.b	Blitter_or_CPU
	beq.s	.Skip
	jsr	CPU_insert_horizon
	bra.s	.Exit
.Skip:
	jsr	Blit_insert_horizon
.Exit:
	rts

;*****************************************************************************
; [ Insert the horizon into the 3D view (blitter version) ]
;   IN : a0 - Pointer to horizon graphics (.l)
;        a1 - Pointer to MOVEP screen position (.l)
;*****************************************************************************
Blit_insert_horizon:
	move.l	a6,-(sp)
	lea.l	Custom,a6
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	a0,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.l	#-$1,bltafwm(a6)
	move.w	#$48,bltamod(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$9f00000,bltcon0(a6)
	move.w	#$524,bltsize(a6)
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	(sp)+,a6
	rts

;*****************************************************************************
; [ Initialize the blitter usage (blitter version) ]
; NOTE :
;   - Decides whether CPU loops or blitter are faster (68020+, fast memory)
;     and installs the blitter interrupt handler.
;*****************************************************************************
Blit_init_blitter:
	movem.l	d0/d7/a0/a6,-(sp)
	tst.b	CPU_68020_plus
	beq.s	.Skip
	st	First_time+1		; Use loops for 68020+
	bra.w	.Exit
.Skip:
	tst.l	Allocated_fast_memory_size
	bne.s	.Skip2
	sf	First_time+1		; If no FAST mem is available,
					; don't use loops below 68020.
	bra.w	.Exit
.Skip2:
	lea.l	Custom,a6
	lea.l	Old_DMACONR,a0		; Backup registers and
					; blit interrupt handler.
	move.w	dmaconr(a6),(a0)+
	move.w	intenar(a6),(a0)+
	move.l	$6c,(a0)+
.Wait:
	btst.b	#6,dmaconr(a6)		; Wait for blitter finish
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#Blitter_interrupt_handler,$6c		; Set blitter interrupt handler
					; to FUN_BlitterInterruptHandler.
	move.w	#$7fff,dmacon(a6)		; Setup blitter
	move.w	#$7fff,intena(a6)
	move.w	#-$79c0,dmacon(a6)
	move.w	#-$3fc0,intena(a6)
	move.l	Off_screen,a0
	move.l	a0,bltapt(a6)
	move.l	a0,bltbpt(a6)
	move.l	a0,bltcpt(a6)
	move.l	a0,bltdpt(a6)
	move.l	#-$1,bltafwm(a6)
	move.w	#0,bltamod(a6)
	move.w	#0,bltbmod(a6)
	move.w	#0,bltcmod(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$ff00000,bltcon0(a6)
	lea.l	Blit_time_counter,a0
	moveq.l	#0,d7
	move.w	#$140a,bltsize(a6)		; Copy 5130 words (10260 bytes)
.Loop:
	addq.l	#1,(a0)
	tst.b	d7		; Loop while blitter copies the data
	beq.s	.Loop		; D0 is the total number of loops
					; needed while the blitter copied.
	move.l	(a0),d0		; Count of loops while the
					; blitter copied the data.
	cmp.l	#4,d0
	spl	First_time+1		; Loop count >= 4, better use loops
	lea.l	Old_DMACONR,a0		; Restore registers and
					; blit interrupt handler.
	move.w	(a0)+,d0
	ori.w	#-$8000,d0
	move.w	#$7fff,dmacon(a6)
	move.w	d0,dmacon(a6)
	move.w	(a0)+,d0
	ori.w	#-$8000,d0
	move.w	#$7fff,intena(a6)
	move.w	d0,intena(a6)
	move.l	(a0)+,$6c
.Exit:
	movem.l	(sp)+,d0/d7/a0/a6
	rts

Old_DMACONR:
	dc.w	0

Old_INTENAR:
	dc.w	0

Old_blitter_interrupt_handler_ptr:
	dc.l	0

Blit_time_counter:
	dc.l	0

;*****************************************************************************
; [ Blitter interrupt handler (counts finished blits) ]
;*****************************************************************************
Blitter_interrupt_handler:
	st	d7		; Notify finish by setting D7 to true
	move.w	#$40,Custom+intreq
	rte

;*****************************************************************************
; [ Initialize the blitter usage ]
; NOTE :
;   - Calls the CPU or the blitter version.
;*****************************************************************************
Init_blitter:
	tst.b	Blitter_or_CPU
	beq.s	.Skip
	jsr	CPU_init_blitter
	bra.s	.Exit
.Skip:
	jsr	Blit_init_blitter
.Exit:
	rts

;*****************************************************************************
; [ Interpolate the wall edges (CPU version) ]
;   IN : d7 - Number of columns (.w)
;        a0 - Pointer to edge table (.l)
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

;*****************************************************************************
; [ Interpolate the wall edges (unrolled version) ]
;   IN : d7 - Number of columns (.w)
;        a0 - Pointer to edge table (.l)
;*****************************************************************************
Blit_edge_loop:
	neg.w	d7
	addi.w	#144,d7
	mulu.w	#12,d7
	jmp	.Skip(pc,d7.w)
.Skip:
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	moveq.l	#0,d0
	rts

;*****************************************************************************
; [ Draw a distorted wall polygon (put_dpoly) ]
;   IN : a0 - Pointer to wall graphics (.l)
;        dpoly_koos3d - 3D coordinates of the wall
; NOTE :
;   - Calls the CPU or the blitter version depending on [ Blitter_or_CPU ].
;*****************************************************************************
put_dpoly:
	tst.b	Blitter_or_CPU
	beq.s	.Skip
	jsr	CPU_put_dpoly
	bra.s	.Exit
.Skip:
	jsr	Blit_put_dpoly
.Exit:
	rts

;*****************************************************************************
; [ Draw a distorted wall polygon (blitter version) ]
;   IN : a0 - Pointer to wall graphics (.l)
; NOTE :
;   - Uses unrolled code for speed.
;*****************************************************************************
Blit_put_dpoly:
	move.w	#128,Wall_texture_width
	move.l	a0,Currently_rendered_wall_data
	lea.l	dpoly_koos3d,a0		; Wall surface infos (x, nextx, etc)
	bsr.w	Blit_clip_wall
	tst.w	d0
	bmi.w	.Exit		; If clipping returned -1, abort.
	bsr.w	Blit_project_wall
	bsr.w	Blit_wall_edges
	tst.w	d0
	bmi.w	.Exit
	moveq.l	#0,d0
	move.w	Wall_texture_width,d0
	asl.l	#7,d0
	moveq.l	#0,d6
	movem.w	Wall_Z_values,d4/d5
	tst.w	d4
	bpl.s	.Skip
	neg.w	d4
	move.w	d5,d3
	add.w	d4,d3
	move.w	Wall_texture_width,d6
	muls.w	d4,d6
	asl.l	#7,d6
	divs.w	d3,d6
	ext.l	d6
	sub.w	d6,d0
	moveq.l	#9,d7
	asl.l	d7,d6
	addi.l	#$8000,d6
	move.l	d6,d5
	bra.w	.Skip3
.Skip:
	tst.w	d5
	bpl.s	.Skip2
	neg.w	d5
	move.w	d5,d3
	add.w	d4,d3
	move.w	Wall_texture_width,d6
	muls.w	d5,d6
	asl.l	#7,d6
	divs.w	d3,d6
	ext.l	d6
	sub.w	d6,d0
.Skip2:
	move.l	#$8000,d5
.Skip3:
	move.w	Wall_right_X,d7
	sub.w	Wall_left_X,d7
	addq.w	#1,d7
	divu.w	d7,d0
	subq.w	#1,d7
	move.w	d0,d6
	moveq.l	#9,d2
	move.w	cx2,d0
	sub.w	Wall_right_X,d0
	bge.s	.Skip4
	add.w	d0,d7
	bmi.w	.Exit
.Skip4:
	move.w	Wall_left_X,d0
	sub.w	cx1,d0
	bge.s	.Skip5
	add.w	d0,d7
	bmi.w	.Exit
	move.w	cx1,Wall_left_X
	neg.w	d0
	muls.w	d6,d0
	asl.l	d2,d0
	add.l	d0,d5
.Skip5:
	ext.l	d6
	asl.l	d2,d6
	tst.w	seethru_flag
	bne.w	.Skip40
	lea.l	Custom,a6
	move.l	Currently_rendered_wall_data,a0
	move.l	MOVEP_ptr,a1
	moveq.l	#0,d3
	move.w	Wall_left_X,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.b	d4,d0
	lsl.w	#8,d4
	move.b	d0,d4
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	#-$1,bltafwm(a6)
	lea.l	Wall_column_table,a3
	move.l	a0,d0
	move.l	d0,d1
	addi.l	#$1400,d1
	swap	d0
	swap	d1
	cmp.w	d0,d1
	bne.w	.Skip22
	tst.l	Wall_clip_flags
	beq.w	.Loop4
.Loop:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	sub.w	d3,d1
	bmi.s	.Skip6
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	moveq.l	#68,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#$3c,bltamod(a6)
	moveq.l	#0,d2
	bra.w	.Skip7
.Skip6:
	neg.w	d1
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#2,bltcon1(a6)
	moveq.l	#-76,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#-$44,bltamod(a6)
	moveq.l	#2,d2
.Skip7:
	move.w	d4,bltbdat(a6)
	swap	d2
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	cmp.w	#319,d7
	ble.s	.Skip8
	move.w	#319,d7
.Skip8:
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	cmp.w	cy2,d1
	bgt.w	.Skip15
	move.w	d1,d7
	sub.w	cy1,d7
	bge.s	.Skip11
	moveq.l	#0,d1
	tst.b	First_time+1
	bmi.s	.Skip9
	lea.l	Wall_jump_base(pc),a4
	add.w	d7,d7
	jsr	0(a4,d7.w)
	bra.s	.Skip10
.Skip9:
	neg.w	d7
	subq.w	#1,d7
.Loop2:
	add.w	(a2)+,d1
	dbra	d7,.Loop2
.Skip10:
	add.l	d1,d0
	move.w	cy1,d1
.Skip11:
	cmp.w	cy1,d2
	blt.w	.Skip15
	cmp.w	cy2,d2
	ble.s	.Skip12
	move.w	cy2,d2
.Skip12:
	sub.w	d1,d2
	swap	d2
	move.w	d2,a4
	swap	d2
	mulu.w	#72,d1
	add.l	a1,d1
	add.l	a4,d1
	add.l	a4,d0
	move.l	d1,bltcpt(a6)
	move.l	d1,bltdpt(a6)
	lea.l	82(a6),a4
	lea.l	bltsize(a6),a5
	move.l	d0,-2(a4)
	move.w	#66,d1
	move.l	a3,-(sp)
	tst.b	First_time+1
	bmi.w	.Skip13
	neg.w	d2
	addi.w	#143,d2
	add.w	d2,d2
	move.w	d2,d7
	add.w	d2,d2
	add.w	d7,d2
	lea.l	Fast_blit_columns1,a3
	jsr	0(a3,d2.w)
	bra.w	.Skip14
.Skip13:
	lea.l	dmaconr(a6),a3
	move.w	#14,d7
.Loop3:
	btst.b	d7,(a3)
	bne.s	.Loop3
	move.w	d0,(a4)
	move.w	d1,(a5)
	add.w	(a2)+,d0
	dbra	d2,.Loop3
.Skip14:
	move.l	(sp)+,a3
.Skip15:
	add.l	d6,d5
	subq.w	#1,d3
	lsr.w	#1,d4
	bcc.s	.Skip16
	move.w	#-32640,d4
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip16:
	swap	d7
	dbra	d7,.Loop
.Exit:
	rts
.Loop4:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
.Wait3:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait3
	sub.w	d3,d1
	bmi.s	.Skip17
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	moveq.l	#68,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#$3c,bltamod(a6)
	moveq.l	#0,d2
	bra.w	.Skip18
.Skip17:
	neg.w	d1
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#2,bltcon1(a6)
	moveq.l	#-76,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#-$44,bltamod(a6)
	moveq.l	#2,d2
.Skip18:
	move.w	d4,bltbdat(a6)
	swap	d2
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	sub.w	d1,d2
	swap	d2
	move.w	d2,a4
	swap	d2
	mulu.w	#72,d1
	add.l	a1,d1
	add.l	a4,d1
	add.l	a4,d0
	move.l	d1,bltcpt(a6)
	move.l	d1,bltdpt(a6)
	lea.l	82(a6),a4
	lea.l	bltsize(a6),a5
	move.l	d0,-2(a4)
	move.w	#66,d1
	move.l	a3,-(sp)
	tst.b	First_time+1
	bne.s	.Skip19
	neg.w	d2
	addi.w	#143,d2
	add.w	d2,d2
	move.w	d2,d7
	add.w	d2,d2
	add.w	d7,d2
	lea.l	Fast_blit_columns1,a3
	jsr	0(a3,d2.w)
	bra.w	.Skip20
.Skip19:
	lea.l	dmaconr(a6),a3
	move.w	#14,d7
.Loop5:
	btst.b	d7,(a3)
	bne.s	.Loop5
	move.w	d0,(a4)
	move.w	d1,(a5)
	add.w	(a2)+,d0
	dbra	d2,.Loop5
.Skip20:
	move.l	(sp)+,a3
	add.l	d6,d5
	subq.w	#1,d3
	lsr.w	#1,d4
	bcc.s	.Skip21
	move.w	#-32640,d4
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip21:
	swap	d7
	dbra	d7,.Loop4
	rts
.Skip22:
	tst.l	Wall_clip_flags
	beq.w	.Loop9
.Loop6:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
.Wait4:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait4
	sub.w	d3,d1
	bmi.s	.Skip23
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	moveq.l	#68,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#$3c,bltamod(a6)
	moveq.l	#0,d2
	bra.w	.Skip24
.Skip23:
	neg.w	d1
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#2,bltcon1(a6)
	moveq.l	#-76,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#-$44,bltamod(a6)
	moveq.l	#2,d2
.Skip24:
	move.w	d4,bltbdat(a6)
	swap	d2
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	cmp.w	#319,d7
	ble.s	.Skip25
	move.w	#319,d7
.Skip25:
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	cmp.w	cy2,d1
	bgt.w	.Skip32
	move.w	d1,d7
	sub.w	cy1,d7
	bge.s	.Skip28
	moveq.l	#0,d1
	tst.b	First_time+1
	bmi.s	.Skip26
	lea.l	Wall_jump_base(pc),a4
	add.w	d7,d7
	jsr	0(a4,d7.w)
	bra.s	.Skip27
.Skip26:
	neg.w	d7
	subq.w	#1,d7
.Loop7:
	add.w	(a2)+,d1
	dbra	d7,.Loop7
.Skip27:
	add.l	d1,d0
	move.w	cy1,d1
.Skip28:
	cmp.w	cy1,d2
	blt.w	.Skip32
	cmp.w	cy2,d2
	ble.s	.Skip29
	move.w	cy2,d2
.Skip29:
	sub.w	d1,d2
	swap	d2
	move.w	d2,a4
	swap	d2
	mulu.w	#72,d1
	add.l	a1,d1
	add.l	a4,d1
	add.l	a4,d0
	move.l	d1,bltcpt(a6)
	move.l	d1,bltdpt(a6)
	lea.l	bltapt(a6),a4
	lea.l	bltsize(a6),a5
	move.w	#66,d1
	movem.l	a0/a3,-(sp)
	move.l	d0,a0
	tst.b	First_time+1
	bmi.s	.Skip30
	neg.w	d2
	addi.w	#143,d2
	add.w	d2,d2
	move.w	d2,d7
	add.w	d2,d2
	add.w	d7,d2
	lea.l	Fast_blit_columns2,a3
	jsr	0(a3,d2.w)
	bra.w	.Skip31
.Skip30:
	lea.l	dmaconr(a6),a3
	move.w	#14,d7
.Loop8:
	btst.b	d7,(a3)
	bne.s	.Loop8
	move.l	a0,(a4)
	move.w	d1,(a5)
	add.w	(a2)+,a0
	dbra	d2,.Loop8
.Skip31:
	movem.l	(sp)+,a0/a3
.Skip32:
	add.l	d6,d5
	subq.w	#1,d3
	lsr.w	#1,d4
	bcc.s	.Skip33
	move.w	#-32640,d4
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip33:
	swap	d7
	dbra	d7,.Loop6
	rts
.Loop9:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
.Wait5:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait5
	sub.w	d3,d1
	bmi.s	.Skip34
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	moveq.l	#68,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#$3c,bltamod(a6)
	moveq.l	#0,d2
	bra.w	.Skip35
.Skip34:
	neg.w	d1
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,bltcon0(a6)
	move.w	#2,bltcon1(a6)
	moveq.l	#-76,d1
	move.w	d1,bltcmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#-$44,bltamod(a6)
	moveq.l	#2,d2
.Skip35:
	move.w	d4,bltbdat(a6)
	swap	d2
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	cmp.w	#319,d7
	ble.s	.Skip36
	move.w	#319,d7
.Skip36:
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	sub.w	d1,d2
	swap	d2
	move.w	d2,a4
	swap	d2
	mulu.w	#72,d1
	add.l	a1,d1
	add.l	a4,d1
	add.l	a4,d0
	move.l	d1,bltcpt(a6)
	move.l	d1,bltdpt(a6)
	lea.l	bltapt(a6),a4
	lea.l	bltsize(a6),a5
	move.w	#66,d1
	movem.l	a0/a3,-(sp)
	move.l	d0,a0
	tst.b	First_time+1
	bmi.s	.Skip37
	neg.w	d2
	addi.w	#143,d2
	add.w	d2,d2
	move.w	d2,d7
	add.w	d2,d2
	add.w	d7,d2
	lea.l	Fast_blit_columns2,a3
	jsr	0(a3,d2.w)
	bra.w	.Skip38
.Skip37:
	lea.l	dmaconr(a6),a3
	move.w	#14,d7
.Loop10:
	btst.b	d7,(a3)
	bne.s	.Loop10
	move.l	a0,(a4)
	move.w	d1,(a5)
	add.w	(a2)+,a0
	dbra	d2,.Loop10
.Skip38:
	movem.l	(sp)+,a0/a3
	add.l	d6,d5
	subq.w	#1,d3
	lsr.w	#1,d4
	bcc.s	.Skip39
	move.w	#-32640,d4
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip39:
	swap	d7
	dbra	d7,.Loop9
	rts
.Skip40:
	lea.l	Custom,a6
	move.l	Currently_rendered_wall_data,a0
	move.l	MOVEP_ptr,a1
	moveq.l	#0,d3
	move.w	Wall_left_X,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#1,d4
	lsl.w	d3,d4
	move.b	d4,d0
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lea.l	Wall_column_table,a3
.Loop11:
	swap	d7
	move.l	d5,d0
	clr.w	d0
	swap	d0
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	move.l	d0,a5
	eori.w	#7,d1
	move.w	d1,d4
	lsl.w	#2,d4
	lea.l	Wall_blit_masks,a4
	move.l	0(a4,d4.w),d4
	sub.w	d3,d1
	bpl.s	.Skip41
	neg.w	d1
	bset.l	#$1f,d1
.Skip41:
	move.l	d1,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	d2,d7
	sub.w	d1,d7
	cmp.w	#319,d7
	ble.s	.Skip42
	move.w	#319,d7
.Skip42:
	lea.l	zoom_ptrbuff,a2
	lsl.w	#2,d7
	move.l	0(a2,d7.w),a2
	cmp.w	cy2,d1
	bgt.w	.Skip341
	move.w	d1,d7
	sub.w	cy1,d7
	bge.s	.Skip45
	moveq.l	#0,d1
	moveq.l	#0,d1
	tst.b	First_time+1
	bne.s	.Skip43
	lea.l	Wall_jump_base(pc),a4
	add.w	d7,d7
	jsr	0(a4,d7.w)
	bra.s	.Skip44
.Skip43:
	neg.w	d7
	subq.w	#1,d7
.Loop12:
	add.w	(a2)+,d1
	dbra	d7,.Loop12
.Skip44:
	add.l	d1,a5
	move.w	cy1,d1
.Skip45:
	cmp.w	cy1,d2
	blt.w	.Skip341
	cmp.w	cy2,d2
	ble.s	.Skip46
	move.w	cy2,d2
.Skip46:
	sub.w	d1,d2
	mulu.w	#72,d1		; Height * lines of 72px
	add.l	a1,d1
	move.l	d1,a4
	move.l	d0,d1
	move.w	d2,d0
	move.w	d3,d2
	lsl.w	#2,d2
	lea.l	Wall_blit_masks,a6
	move.l	0(a6,d2.w),d2
	not.l	d2
	tst.b	First_time+1
	bne.w	.Skip338
	neg.w	d0
	addi.w	#143,d0
	mulu.w	#18,d0
	bclr.l	#$1f,d1
	bne.w	.Skip192
	jmp	.Skip47(pc,d0.w)
.Skip47:
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip48
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip48:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip49
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip49:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip50
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip50:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip51
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip51:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip52
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip52:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip53
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip53:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip54
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip54:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip55
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip55:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip56
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip56:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip57
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip57:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip58
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip58:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip59
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip59:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip60
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip60:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip61
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip61:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip62
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip62:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip63
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip63:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip64
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip64:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip65
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip65:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip66
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip66:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip67
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip67:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip68
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip68:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip69
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip69:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip70
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip70:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip71
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip71:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip72
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip72:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip73
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip73:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip74
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip74:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip75
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip75:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip76
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip76:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip77
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip77:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip78
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip78:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip79
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip79:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip80
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip80:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip81
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip81:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip82
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip82:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip83
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip83:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip84
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip84:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip85
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip85:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip86
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip86:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip87
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip87:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip88
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip88:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip89
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip89:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip90
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip90:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip91
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip91:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip92
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip92:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip93
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip93:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip94
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip94:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip95
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip95:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip96
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip96:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip97
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip97:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip98
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip98:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip99
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip99:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip100
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip100:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip101
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip101:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip102
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip102:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip103
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip103:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip104
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip104:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip105
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip105:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip106
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip106:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip107
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip107:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip108
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip108:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip109
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip109:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip110
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip110:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip111
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip111:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip112
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip112:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip113
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip113:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip114
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip114:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip115
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip115:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip116
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip116:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip117
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip117:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip118
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip118:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip119
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip119:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip120
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip120:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip121
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip121:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip122
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip122:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip123
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip123:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip124
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip124:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip125
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip125:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip126
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip126:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip127
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip127:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip128
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip128:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip129
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip129:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip130
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip130:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip131
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip131:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip132
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip132:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip133
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip133:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip134
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip134:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip135
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip135:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip136
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip136:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip137
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip137:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip138
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip138:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip139
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip139:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip140
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip140:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip141
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip141:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip142
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip142:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip143
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip143:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip144
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip144:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip145
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip145:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip146
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip146:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip147
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip147:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip148
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip148:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip149
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip149:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip150
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip150:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip151
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip151:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip152
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip152:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip153
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip153:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip154
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip154:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip155
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip155:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip156
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip156:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip157
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip157:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip158
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip158:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip159
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip159:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip160
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip160:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip161
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip161:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip162
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip162:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip163
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip163:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip164
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip164:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip165
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip165:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip166
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip166:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip167
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip167:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip168
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip168:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip169
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip169:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip170
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip170:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip171
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip171:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip172
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip172:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip173
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip173:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip174
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip174:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip175
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip175:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip176
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip176:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip177
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip177:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip178
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip178:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip179
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip179:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip180
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip180:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip181
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip181:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip182
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip182:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip183
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip183:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip184
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip184:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip185
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip185:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip186
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip186:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip187
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip187:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip188
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip188:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip189
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip189:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip190
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip190:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip191
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip191:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	bra.w	.Skip341
.Skip192:
	jmp	.Skip193(pc,d0.w)
.Skip193:
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip194
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip194:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip195
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip195:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip196
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip196:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip197
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip197:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip198
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip198:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip199
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip199:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip200
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip200:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip201
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip201:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip202
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip202:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip203
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip203:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip204
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip204:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip205
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip205:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip206
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip206:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip207
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip207:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip208
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip208:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip209
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip209:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip210
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip210:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip211
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip211:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip212
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip212:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip213
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip213:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip214
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip214:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip215
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip215:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip216
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip216:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip217
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip217:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip218
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip218:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip219
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip219:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip220
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip220:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip221
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip221:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip222
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip222:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip223
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip223:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip224
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip224:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip225
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip225:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip226
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip226:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip227
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip227:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip228
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip228:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip229
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip229:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip230
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip230:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip231
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip231:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip232
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip232:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip233
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip233:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip234
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip234:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip235
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip235:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip236
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip236:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip237
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip237:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip238
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip238:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip239
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip239:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip240
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip240:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip241
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip241:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip242
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip242:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip243
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip243:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip244
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip244:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip245
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip245:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip246
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip246:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip247
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip247:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip248
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip248:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip249
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip249:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip250
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip250:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip251
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip251:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip252
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip252:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip253
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip253:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip254
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip254:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip255
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip255:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip256
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip256:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip257
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip257:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip258
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip258:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip259
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip259:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip260
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip260:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip261
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip261:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip262
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip262:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip263
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip263:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip264
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip264:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip265
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip265:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip266
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip266:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip267
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip267:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip268
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip268:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip269
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip269:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip270
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip270:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip271
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip271:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip272
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip272:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip273
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip273:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip274
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip274:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip275
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip275:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip276
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip276:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip277
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip277:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip278
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip278:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip279
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip279:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip280
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip280:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip281
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip281:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip282
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip282:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip283
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip283:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip284
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip284:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip285
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip285:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip286
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip286:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip287
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip287:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip288
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip288:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip289
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip289:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip290
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip290:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip291
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip291:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip292
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip292:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip293
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip293:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip294
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip294:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip295
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip295:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip296
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip296:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip297
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip297:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip298
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip298:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip299
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip299:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip300
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip300:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip301
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip301:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip302
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip302:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip303
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip303:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip304
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip304:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip305
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip305:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip306
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip306:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip307
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip307:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip308
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip308:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip309
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip309:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip310
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip310:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip311
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip311:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip312
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip312:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip313
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip313:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip314
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip314:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip315
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip315:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip316
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip316:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip317
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip317:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip318
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip318:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip319
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip319:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip320
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip320:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip321
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip321:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip322
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip322:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip323
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip323:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip324
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip324:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip325
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip325:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip326
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip326:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip327
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip327:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip328
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip328:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip329
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip329:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip330
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip330:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip331
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip331:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip332
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip332:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip333
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip333:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip334
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip334:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip335
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip335:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip336
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip336:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip337
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip337:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	bra.w	.Skip341
.Skip338:
	move.w	d0,d7
	bclr.l	#$1f,d1
	bne.w	.Loop14
.Loop13:
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip339
	lsr.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip339:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop13
	bra.w	.Skip341
.Loop14:
	move.l	(a5),d0
	and.l	d4,d0
	beq.s	.Skip340
	lsl.l	d1,d0
	and.l	d2,(a4)
	or.l	d0,(a4)
.Skip340:
	add.w	(a2)+,a5
	lea.l	72(a4),a4
	dbra	d7,.Loop14
.Skip341:
	add.l	d6,d5
	subq.w	#1,d3
	bpl.s	.Skip342
	moveq.l	#7,d3
	addq.l	#4,a1
.Skip342:
	swap	d7
	dbra	d7,.Loop11
	rts

Wall_blit_masks:
	dc.l	$1010101,$2020202,$4040404,$8080808
	dc.l	$10101010,$20202020,$40404040

;*****************************************************************************
; [ Wall_blit_masks_end ]
;*****************************************************************************
Wall_blit_masks_end:
	dc.l	$80808080
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
	add.w	(a2)+,d1
Wall_jump_base:
	rts

;*****************************************************************************
; [ Project the 3D coordinates of a wall to the screen (blitter version) ]
;   IN : a0 - Pointer to 3D wall coordinates (.l)
;*****************************************************************************
Blit_project_wall:
	lea.l	Projected_wall,a1
	move.w	scrx,d4
	move.w	scry,d5
	move.w	8(a0),d0		; StartX
	addi.w	#256,d0		; + 256
	move.w	(a0),d2		; EndX
	ext.l	d2
	asl.l	#8,d2		; * 256
	divs.w	d0,d2		; Scale by dist
	add.w	d4,d2		; Add half screen size
	move.w	d2,(a1)+
	move.w	4(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy2,d2
	sgt	Wall_clip_flags
	move.w	6(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy1,d2
	slt	Wall_clip_flag2
	move.w	10(a0),d0
	addi.w	#256,d0
	move.w	2(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	add.w	d4,d2
	move.w	d2,(a1)+
	move.w	4(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy2,d2
	sgt	Wall_clip_flag3
	move.w	6(a0),d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d0,d2
	neg.w	d2
	add.w	d5,d2
	move.w	d2,(a1)+
	cmp.w	cy1,d2
	slt	Wall_clip_flag4
	rts

;*****************************************************************************
; [ Clip a wall against the front plane (blitter version) ]
;   IN : a0 - Pointer to 3D wall coordinates (.l)
;  OUT : d0 - 0 = visible, -1 = invisible (.w)
;*****************************************************************************
Blit_clip_wall:
	move.l	8(a0),Wall_Z_values
	move.w	8(a0),d5		; StartX
	bmi.w	.Skip
	move.w	10(a0),d6		; StartXTransformed
	bpl.w	.Exit
	clr.w	10(a0)		; If < 0, set to 0
	sub.w	d6,d5		; and sub from StartX
	move.w	2(a0),d0		; EndXTransformed
	sub.w	(a0),d0		; Sub EndX from it.
	muls.w	8(a0),d0		; * StartX
	divs.w	d5,d0		; / (StartXTrans - StartX)
	add.w	(a0),d0		; + EndX
	move.w	d0,2(a0)		; Save as EndXTransformed
	bra.w	.Exit
.Skip:
	move.w	10(a0),d6
	bmi.w	.Exit2
	clr.w	8(a0)
	sub.w	d5,d6
	move.w	(a0),d0
	sub.w	2(a0),d0
	muls.w	10(a0),d0
	divs.w	d6,d0
	add.w	2(a0),d0
	move.w	d0,(a0)
.Exit:
	moveq.l	#0,d0
	rts
.Exit2:
	moveq.l	#-1,d0		; StartX and StartXTrans are neg.
					; Return -1.
	rts

;*****************************************************************************
; [ Calculate the top & bottom edges of a projected wall (blitter version) ]
;  OUT : d0 - 0 = visible, -1 = invisible (.w)
; NOTE :
;   - Uses unrolled code for speed.
;*****************************************************************************
Blit_wall_edges:
	movem.w	Projected_wall,d0-d5
	cmp.w	d0,d3
	bge.s	.Skip
	exg	d0,d3
	exg	d1,d4
	exg	d2,d5
.Skip:
	move.w	d0,Wall_left_X
	move.w	d3,Wall_right_X
	lea.l	Wall_column_table,a0
	sub.w	d0,d3
	addq.w	#1,d3
	move.w	d3,d7
	sub.w	d1,d4
	ext.l	d4
	asl.l	#7,d4
	divs.w	d3,d4
	sub.w	d2,d5
	ext.l	d5
	asl.l	#7,d5
	divs.w	d3,d5
	ext.l	d4
	ext.l	d5
	move.w	d1,d0
	move.w	d2,d1
	move.w	#-$8000,d2
	move.w	#-$8000,d3
	move.w	cx2,d6
	sub.w	Wall_right_X,d6
	bge.s	.Skip2
	add.w	d6,d7
	bmi.w	.Exit
.Skip2:
	move.w	Wall_left_X,d6
	sub.w	cx1,d6
	bge.s	.Skip3
	add.w	d6,d7
	bmi.w	.Exit
	neg.w	d6
	move.w	d7,-(sp)
	move.w	d6,-(sp)
	moveq.l	#9,d7
	muls.w	d4,d6
	asl.l	d7,d6
	add.w	d6,d2
	swap	d6
	addx.w	d6,d0
	move.w	(sp)+,d6
	muls.w	d5,d6
	asl.l	d7,d6
	add.w	d6,d3
	swap	d6
	addx.w	d6,d1
	move.w	(sp)+,d7
.Skip3:
	moveq.l	#9,d6
	asl.l	d6,d4
	asl.l	d6,d5
	move.w	d4,a2
	move.w	d5,a3
	swap	d4
	swap	d5
	neg.w	d7
	addi.w	#144,d7
	mulu.w	#12,d7
	jmp	.Skip4(pc,d7.w)
.Skip4:
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	move.w	d1,(a0)+
	add.w	a3,d3
	addx.w	d5,d1
	move.w	d0,(a0)+
	add.w	a2,d2
	addx.w	d4,d0
	moveq.l	#0,d0
	rts
.Exit:
	moveq.l	#-1,d0
	rts

;*****************************************************************************
; [ Draw a zoomed 3D object (blitter version) ]
;   (see [ draw_zoomshape ] for parameters)
;*****************************************************************************
Blit_draw_zoomshape:
	move.w	d0,Zoomshape_X
	move.w	d1,Zoomshape_Y
	move.w	d2,Zoomshape_mask
	move.w	d4,Zoomshape_source_width
	move.w	d5,Zoomshape_source_height
	move.l	a0,Zoomshape_line_size
	move.w	d7,d0
	move.w	d6,d7
	move.w	d0,Zoomshape_target_width
	move.w	d7,Zoomshape_target_height
	clr.w	Zoomshape_skip_lines
	clr.w	Zoomshape_skip_columns
	move.w	Zoomshape_X,d2
	sub.w	cx1,d2
	bpl.s	.Skip
	add.w	d2,d7
	ble.w	Blit_zoomshape_exit
	move.w	cx1,Zoomshape_X
	neg.w	d2
	mulu.w	Zoomshape_source_width,d2
	divu.w	Zoomshape_target_height,d2
	andi.w	#-$8,d2
	move.w	d2,Zoomshape_skip_lines
.Skip:
	move.w	Zoomshape_Y,d2
	add.w	d0,d2
	subq.w	#1,d2
	sub.w	cy2,d2
	ble.s	.Skip2
	sub.w	d2,d0
	ble.w	Blit_zoomshape_exit
	mulu.w	Zoomshape_source_height,d2
	divu.w	Zoomshape_target_width,d2
	move.w	d2,Zoomshape_skip_columns
.Skip2:
	clr.w	Zoomshape_clip_left
	clr.w	Zoomshape_clip_top
	move.w	Zoomshape_Y,d2
	sub.w	cy1,d2
	bpl.s	.Skip3
	add.w	d2,d0
	ble.w	Blit_zoomshape_exit
	neg.w	d2
	move.w	d2,Zoomshape_clip_top
	clr.w	Zoomshape_Y
.Skip3:
	move.w	Zoomshape_X,d2
	add.w	d7,d2
	subq.w	#1,d2
	sub.w	cx2,d2
	ble.s	.Skip4
	sub.w	d2,d7
	ble.w	Blit_zoomshape_exit
	move.w	d2,Zoomshape_clip_left
.Skip4:
	move.w	d0,Zoomshape_visible_height
	move.w	d7,Zoomshape_visible_width
	bsr.w	Blit_zoomshape_tables
	move.w	Zoomshape_target_width,d0
	cmp.w	Zoomshape_source_height,d0
	bgt.w	Blit_zoomshape_draw
	lea.l	Custom,a6
	move.l	Zoomshape_line_size,a0
	move.l	zoom_screen,a1
	lea.l	Zoomshape_Y_table,a2
	move.w	Zoomshape_source_width,d6
	addi.w	#15,d6
	sub.w	Zoomshape_source_X_offset,d6
	sub.w	Zoomshape_skip_lines,d6
	andi.w	#-$10,d6
	move.w	d6,d5
	lsr.w	#2,d6
	addi.w	#64,d6
	move.w	Zoomshape_source_width,d0
	andi.w	#-$10,d0
	lsr.w	#1,d0
	move.w	d0,d1
	mulu.w	Zoomshape_source_Y_offset,d0
	add.w	d0,a0
	move.w	Zoomshape_skip_lines,d0
	lsr.w	#1,d0
	add.w	d0,a0
	lsr.w	#1,d5
	neg.w	d5
	addi.w	#72,d5
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	move.l	a1,bltdpt(a6)
	move.w	d5,bltdmod(a6)
	move.w	#$9f0,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	move.l	#-$1,bltafwm(a6)
	lea.l	bltapt(a6),a4
	lea.l	bltsize(a6),a5
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
	lea.l	dmaconr(a6),a1
	moveq.l	#14,d5
.Loop:
	btst.b	d5,(a1)
	bne.s	.Loop
	move.l	a0,(a4)
	move.w	d6,(a5)
	move.w	(a2)+,d0
	mulu.w	d1,d0
	add.w	d0,a0
	dbra	d7,.Loop
.Wait2:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait2
	tst.w	Zoomshape_mask
	beq.s	.Skip5
	move.w	Zoomshape_source_width,d4
	addq.w	#7,d4
	sub.w	Zoomshape_source_X_offset,d4
	sub.w	Zoomshape_skip_lines,d4
	lsr.w	#3,d4
	move.w	Zoomshape_visible_height,d5
	moveq.l	#-1,d6
	bsr.w	Blit_make_zoom_mask
	move.l	zoom_screen2,a3
.Skip5:
	move.l	zoom_screen,a0
	move.l	MOVEP_ptr,a1
	move.w	Zoomshape_Y,d0
	mulu.w	#72,d0
	add.l	d0,a1
	moveq.l	#0,d3
	move.w	Zoomshape_X,d0
	add.w	Zoomshape_visible_width,d0
	subq.w	#1,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#0,d4
	bset.l	d3,d4
	move.b	d4,d0
	lsl.w	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	lsl.l	#8,d4
	move.b	d0,d4
	move.w	Zoomshape_visible_height,d5
	lsl.w	#6,d5
	addq.w	#2,d5
	moveq.l	#0,d6
	move.w	Zoomshape_source_width,d6
	subq.w	#1,d6
	sub.w	Zoomshape_source_X_offset,d6
	sub.w	Zoomshape_skip_lines,d6
	move.w	#68,a4
	move.w	#-76,a5
	tst.w	Zoomshape_mask
	beq.w	Blit_zoom_columns
	lea.l	Blit_zoom_masks,a4
.Wait3:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait3
	move.w	#0,bltcon1(a6)
	move.w	#$44,bltcmod(a6)
	move.w	#$44,bltbmod(a6)
	move.w	#$44,bltamod(a6)
	move.w	#$44,bltdmod(a6)
	lea.l	Zoomshape_X_table,a2
	move.w	Zoomshape_visible_width,d7
	subq.w	#1,d7
.Loop2:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	move.l	d0,d2
	add.l	a0,d0
	add.l	a3,d2
	move.w	d1,d4
	eori.w	#7,d1
.Wait4:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait4
	sub.w	d3,d1
	bmi.s	.Skip7
.Loop3:
	ror.w	#4,d1
	move.w	d1,bltcon1(a6)
	ori.w	#$fca,d1
	move.w	d1,bltcon0(a6)
	add.w	d4,d4
	add.w	d4,d4
	move.l	0(a4,d4.w),bltafwm(a6)
	move.l	a1,bltcpt(a6)
	move.l	d0,bltbpt(a6)
	move.l	d2,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d5,bltsize(a6)
	addq.w	#1,d3
	andi.w	#7,d3
	bne.s	.Skip6
	subq.l	#4,a1
.Skip6:
	dbra	d7,.Loop2
	rts
.Skip7:
	move.w	#2,bltcon1(a6)
	move.w	#-$4c,bltcmod(a6)
	move.w	#-$4c,bltdmod(a6)
	move.w	#-$4c,bltbmod(a6)
	move.w	#-$4c,bltamod(a6)
	addq.l	#2,a1
	addq.l	#2,d0
	addq.l	#2,d2
	bra.w	.Skip8
.Loop4:
	move.w	#0,bltcon1(a6)
	move.w	#$44,bltcmod(a6)
	move.w	#$44,bltdmod(a6)
	move.w	#$44,bltbmod(a6)
	move.w	#$44,bltamod(a6)
	subq.l	#2,a1
	subq.l	#2,d0
	subq.l	#2,d2
	bra.w	.Loop3
.Loop5:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	move.l	d0,d2
	add.l	a0,d0
	add.l	a3,d2
	move.w	d1,d4
	eori.w	#7,d1
	addq.l	#2,d0
	addq.l	#2,d2
.Wait5:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait5
	sub.w	d3,d1
	bpl.s	.Loop4
.Skip8:
	neg.w	d1
	ror.w	#4,d1
	addq.w	#2,d1
	move.w	d1,bltcon1(a6)
	subq.w	#2,d1
	ori.w	#$fca,d1
	move.w	d1,bltcon0(a6)
	add.w	d4,d4
	add.w	d4,d4
	move.l	0(a4,d4.w),bltafwm(a6)
	move.l	a1,bltcpt(a6)
	move.l	d0,bltbpt(a6)
	move.l	d2,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	d5,bltsize(a6)
	addq.w	#1,d3
	andi.w	#7,d3
	bne.s	.Skip9
	subq.l	#4,a1
.Skip9:
	dbra	d7,.Loop5
	rts

Blit_zoom_masks:
	dc.l	$80808080,$40404040,$20202020,$10101010
	dc.l	$8080808,$4040404,$2020202,$1010101

;*****************************************************************************
; [ Draw the zoomed columns of a 3D object (blitter version) ]
;   IN : a6 - Custom (.l)
;*****************************************************************************
Blit_zoom_columns:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	Blit_zoom_columns
	move.w	#0,66(a6)
	move.w	#68,96(a6)
	move.w	#68,102(a6)
	move.w	a4,100(a6)
	move.l	#-1,68(a6)
	lea.l	Zoomshape_X_table,a2
	move.w	Zoomshape_visible_width,d7
	subq.w	#1,d7
.Loop:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	sub.w	d3,d1
	bmi.s	.Skip2
.Loop2:
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,64(a6)
	move.w	d4,114(a6)
	move.l	a1,72(a6)
	move.l	a1,84(a6)
	move.l	d0,80(a6)
	move.w	d5,88(a6)
	addq.w	#1,d3
	add.w	d4,d4
	bcc.s	.Skip
	move.w	#257,d4
	moveq.l	#0,d3
	subq.l	#4,a1
.Skip:
	dbra	d7,.Loop
	rts
.Skip2:
	move.w	#2,66(a6)
	move.w	#-76,96(a6)
	move.w	#-76,102(a6)
	move.w	a5,100(a6)
	addq.l	#2,a1
	addq.l	#2,d0
	bra.w	.Skip3
.Loop3:
	move.w	#0,66(a6)
	move.w	#68,96(a6)
	move.w	#68,102(a6)
	move.w	a4,100(a6)
	subq.l	#2,a1
	subq.l	#2,d0
	bra.s	.Loop2
.Loop4:
	move.l	d6,d0
	sub.w	(a2)+,d6
	moveq.l	#7,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#1,d0
	add.l	a0,d0
	eori.w	#7,d1
	addq.l	#2,d0
.Wait2:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait2
	sub.w	d3,d1
	bpl.s	.Loop3
.Skip3:
	neg.w	d1
	ror.w	#4,d1
	ori.w	#$be2,d1
	move.w	d1,64(a6)
	move.w	d4,114(a6)
	move.l	d0,80(a6)
	move.l	a1,72(a6)
	move.l	a1,84(a6)
	move.w	d5,88(a6)
	addq.w	#1,d3
	add.w	d4,d4
	bcc.s	.Skip4
	move.w	#257,d4
	moveq.l	#0,d3
	subq.l	#4,a1
.Skip4:
	dbra	d7,.Loop4
Blit_zoomshape_exit:
	rts
Blit_zoomshape_draw:
	lea.l	Custom,a6
	move.l	Zoomshape_line_size,a0
	move.l	zoom_screen,a1
	lea.l	Zoomshape_X_table,a2
	move.w	Zoomshape_source_width,d5
	andi.w	#-$8,d5
	lsr.w	#1,d5
	mulu.w	Zoomshape_source_Y_offset,d5
	add.w	d5,a0
	moveq.l	#0,d3
	move.w	Zoomshape_X,d0
	andi.w	#7,d0
	add.w	Zoomshape_visible_width,d0
	subq.w	#1,d0
	moveq.l	#7,d3
	and.w	d0,d3
	sub.w	d3,d0
	lsr.w	#1,d0
	add.w	d0,a1
	eori.w	#7,d3
	moveq.l	#0,d4
	bset.l	d3,d4
	move.b	d4,d0
	lsl.w	#8,d4
	move.b	d0,d4
	move.w	Zoomshape_source_height,d5
	sub.w	Zoomshape_source_Y_offset,d5
	sub.w	Zoomshape_skip_columns,d5
	lsl.w	#6,d5
	addq.w	#2,d5
	moveq.l	#0,d6
	move.w	Zoomshape_source_width,d6
	subq.w	#1,d6
	sub.w	Zoomshape_source_X_offset,d6
	move.w	Zoomshape_source_width,d0
	andi.w	#-$8,d0
	lsr.w	#1,d0
	move.w	d0,d1
	neg.w	d1
	subq.w	#4,d0
	subq.w	#4,d1
	move.w	d0,a4
	move.w	d1,a5
	bsr.w	Blit_zoom_columns
	tst.w	Zoomshape_mask
	bne.w	.Skip7
	move.l	zoom_screen,a0
	lea.l	Zoomshape_Y_table,a2
	move.l	MOVEP_ptr,a1
	move.w	Zoomshape_Y,d0
	mulu.w	#72,d0
	add.l	d0,a1
	move.w	Zoomshape_X,d0
	moveq.l	#7,d5
	and.w	d0,d5
	sub.w	d5,d0
	lsr.w	#1,d0
	add.w	d0,a1
	move.w	Zoomshape_visible_width,d0
	addq.w	#7,d0
	add.w	d5,d0
	lsr.w	#3,d0
	move.w	d0,d6
	lsl.w	#2,d0
	neg.w	d0
	move.w	d5,d4
	add.w	d5,d5
	add.w	d5,d5
	lea.l	Floor_masks1,a3
	move.l	0(a3,d5.w),d5
	add.w	Zoomshape_visible_width,d4
	subq.w	#1,d4
	andi.w	#7,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	32(a3,d4.w),d4
	move.l	d4,d2
	move.l	d5,d3
	not.l	d2
	not.l	d3
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
	cmp.w	#1,d6
	beq.w	.Skip6
	cmp.w	#2,d6
	beq.w	.Loop6
	subq.w	#2,d6
	neg.w	d6
	addi.w	#16,d6
	add.w	d6,d6
	lea.l	.Skip5,a3
	add.w	d6,a3
.Loop5:
	move.l	a0,a4
	move.l	a1,a5
	move.l	(a4)+,d0
	and.l	d5,d0
	and.l	d3,(a5)
	or.l	d0,(a5)+
	jmp	(a3)
.Skip5:
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,d0
	and.l	d4,d0
	and.l	d2,(a5)
	or.l	d0,(a5)+
	move.w	(a2)+,d0
	mulu.w	#72,d0
	add.w	d0,a0
	lea.l	72(a1),a1
	dbra	d7,.Loop5
	rts
.Loop6:
	move.l	a0,a4
	move.l	a1,a5
	move.l	(a4)+,d0
	and.l	d5,d0
	and.l	d3,(a5)
	or.l	d0,(a5)+
	move.l	(a4)+,d0
	and.l	d4,d0
	and.l	d2,(a5)
	or.l	d0,(a5)+
	move.w	(a2)+,d0
	mulu.w	#72,d0
	add.w	d0,a0
	lea.l	72(a1),a1
	dbra	d7,.Loop6
	rts
.Skip6:
	and.l	d4,d5
	or.l	d2,d3
.Loop7:
	move.l	(a0),d0
	and.l	d5,d0
	and.l	d3,(a1)
	or.l	d0,(a1)
	move.w	(a2)+,d0
	mulu.w	#72,d0
	add.w	d0,a0
	lea.l	72(a1),a1
	dbra	d7,.Loop7
	rts
.Skip7:
	move.w	Zoomshape_X,d5
	andi.w	#7,d5
	move.w	d5,d4
	add.w	d5,d5
	add.w	d5,d5
	lea.l	Floor_masks1,a3
	move.l	0(a3,d5.w),d2
	add.w	Zoomshape_visible_width,d4
	subq.w	#1,d4
	andi.w	#7,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	32(a3,d4.w),d3
	move.w	Zoomshape_X,d0
	andi.w	#7,d0
	move.w	Zoomshape_visible_width,d4
	addq.w	#7,d4
	add.w	d0,d4
	lsr.w	#3,d4
	move.w	Zoomshape_source_height,d5
	sub.w	Zoomshape_source_Y_offset,d5
	sub.w	Zoomshape_skip_columns,d5
	moveq.l	#0,d6
	bsr.w	Blit_make_zoom_mask2
	move.l	zoom_screen,a0
	lea.l	Zoomshape_Y_table,a2
	move.l	zoom_screen2,a3
	move.l	MOVEP_ptr,a1
	move.w	Zoomshape_Y,d0
	mulu.w	#72,d0
	add.l	d0,a1
	move.w	Zoomshape_X,d0
	moveq.l	#7,d5
	and.w	d0,d5
	sub.w	d5,d0
	lsr.w	#1,d0
	add.w	d0,a1
	move.w	Zoomshape_visible_width,d0
	addq.w	#7,d0
	add.w	d5,d0
	lsr.w	#3,d0
	move.w	d0,d6
	add.w	d6,d6
	addi.w	#64,d6
	lsl.w	#2,d0
	neg.w	d0
	addi.w	#72,d0
.Wait3:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait3
	move.w	d0,bltcmod(a6)
	move.w	d0,bltbmod(a6)
	move.w	d0,bltamod(a6)
	move.w	d0,bltdmod(a6)
	move.l	a1,bltcpt(a6)
	move.l	a1,bltdpt(a6)
	lea.l	dmaconr(a6),a1
	lea.l	bltbpt(a6),a4
	lea.l	bltsize(a6),a5
	move.w	#$fca,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	move.w	Zoomshape_visible_height,d7
	subq.w	#1,d7
	moveq.l	#14,d5
.Loop8:
	btst.b	d5,(a1)
	bne.s	.Loop8
	move.l	a3,4(a4)
	move.l	a0,(a4)
	move.w	d6,(a5)
	move.w	(a2)+,d0
	mulu.w	#72,d0
	add.w	d0,a3
	add.w	d0,a0
	dbra	d7,.Loop8
	rts

;*****************************************************************************
; [ Create the mask for the zoom screen (blitter version) ]
;   IN : d4 - Width in bytes / 4 (.w)
;        d5 - Height (.w)
;*****************************************************************************
Blit_make_zoom_mask:
	move.l	zoom_screen,a0
	move.l	zoom_screen2,a1
	subq.w	#1,d4
	subq.w	#1,d5
.Loop:
	move.w	d4,d7
	pea	72(a0)
	pea	72(a1)
.Loop2:
	move.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	dbra	d7,.Loop2
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	dbra	d5,.Loop
	rts

;*****************************************************************************
; [ Create the clipped mask for the zoom screen (blitter version) ]
;   IN : d2 - Right edge mask (.l)
;        d4 - Width in bytes / 4 (.w)
;        d5 - Height (.w)
;*****************************************************************************
Blit_make_zoom_mask2:
	move.l	zoom_screen,a0
	move.l	zoom_screen2,a1
	subq.w	#1,d5
	subq.w	#2,d4
	bmi.s	.Skip2
.Loop:
	move.w	d4,d7
	pea	72(a0)
	pea	72(a1)
	move.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	and.l	d2,-4(a1)
	bra.s	.Skip
.Loop2:
	move.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
.Skip:
	dbra	d7,.Loop2
	move.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	and.l	d3,-4(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	dbra	d5,.Loop
	rts
.Skip2:
	and.l	d3,d2
.Loop3:
	move.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	or.b	(a0)+,d0
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	and.l	d2,-4(a1)
	lea.l	68(a0),a0
	lea.l	68(a1),a1
	dbra	d5,.Loop3
	rts

;*****************************************************************************
; [ Calculate the X and Y step tables for a 3D object (blitter version) ]
;*****************************************************************************
Blit_zoomshape_tables:
	move.w	Zoomshape_target_width,d7
	lea.l	Zoomshape_Y_table,a0
	move.w	Zoomshape_source_height,d0
	subq.w	#1,d0
	ext.l	d0
	divs.w	d7,d0
	move.w	d0,d4
	swap	d0
	move.w	d7,d1
	move.w	d1,d2
	addq.w	#1,d0
	moveq.l	#0,d3
	move.w	Zoomshape_clip_top,d6
	beq.s	.Skip
	move.w	d4,d3
	mulu.w	d6,d3
	move.w	d0,d7
	mulu.w	d6,d7
	divu.w	d2,d7
	add.w	d7,d3
	swap	d7
	sub.w	d7,d2
.Skip:
	subq.w	#1,d2
	move.w	d3,Zoomshape_source_Y_offset
	move.w	Zoomshape_visible_height,d6
	subq.w	#1,d6
.Loop:
	move.w	d4,d5
	sub.w	d0,d2
	bpl.s	.Skip2
	add.w	d1,d2
	addq.w	#1,d5
.Skip2:
	move.w	d5,(a0)+
	dbra	d6,.Loop
	move.w	Zoomshape_target_height,d7
	lea.l	Zoomshape_X_table,a0
	move.w	Zoomshape_source_width,d0
	subq.w	#1,d0
	ext.l	d0
	divs.w	d7,d0
	move.w	d0,d4
	swap	d0
	move.w	d7,d1
	move.w	d1,d2
	addq.w	#1,d0
	moveq.l	#0,d3
	move.w	Zoomshape_clip_left,d6
	beq.s	.Skip3
	move.w	d4,d3
	mulu.w	d6,d3
	move.w	d0,d7
	mulu.w	d6,d7
	divu.w	d2,d7
	add.w	d7,d3
	swap	d7
	sub.w	d7,d2
.Skip3:
	subq.w	#1,d2
	move.w	d3,Zoomshape_source_X_offset
	move.w	Zoomshape_visible_width,d6
	subq.w	#1,d6
.Loop2:
	move.w	d4,d5
	sub.w	d0,d2
	bpl.s	.Skip4
	add.w	d1,d2
	addq.w	#1,d5
.Skip4:
	move.w	d5,(a0)+
	dbra	d6,.Loop2
	rts

;*****************************************************************************
; [ Draw a zoomed 3D object (draw_zoomshape) ]
;   IN : d0 - X-position (.w)
;        d1 - Y-position (.w)
;        d2 - Mask (.w)
;        d4 - Source width (.w)
;        d5 - Source height (.w)
;        d6 - New width (.w)
;        d7 - New height (.w)
;        a0 - Pointer to graphics (.l)
; NOTE :
;   - Calls the CPU or the blitter version depending on [ Blitter_or_CPU ].
;*****************************************************************************
draw_zoomshape:
	tst.b	Blitter_or_CPU
	beq.s	.Skip
	jsr	CPU_draw_zoomshape
	bra.s	.Exit
.Skip:
	jsr	Blit_draw_zoomshape
.Exit:
	rts
	; 

