
;************************
;*** level3-interrupt ***
;************************
level3:
		addq.l	#1,vindex
		movem.l	d0-d7/a0-a6,-(sp)
		lea	$dff000,a6
;*** farbpalette setzen ***
		movem.l	palette0,d0-d7
		movem.l	d0-d7,$dff180
		movem.l	palette0+32,d0-d7
		movem.l	d0-d7,$dff1a0
		tst	vbl_flag
		beq	skip_level3
;*** sprites setzen ***
		tst	magic_doit
		bne.s	.ending
		move.l	elfe_kptr,a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		cmp	#12345,(a0)
		bne.s	.normal
		tst.w	2(a0)
		bpl.s	.now_magic
		tst	leave_flag
		bne.s	.ending
		move	#400/3,leave_flag	;schulz !!
		bra.s	.ending
.now_magic:	move	#-1,magic_doit
		move.w	#-1,magic_offs
		addq.l	#4,a0
.normal:	move.l	a0,elfe_kptr
		move	d0,posx
		move	d1,posy
.ending:
;--- pointer holen ---
		lea	elfe,a0
		move	elfe_ani,d2
		mulu	#73*32,d2
		add.l	d2,a0
;--- koos eintragen ---
		move	posx,d0		;x
		move	posy,d1		;start_y

		add	#$80,d0		;screen_start
		add	#$28,d1		;screen_start
		move	d1,d2
		add	#71,d2		;endy

		rol.w	#7,d2
		lsl	#8,d1		;E0-E7
		addx.w	d2,d2		;E8 bit uebernehmen
		addx.b	d2,d2		;L8 bit uebernehmen
		lsr.w	#1,d0		;H0
		addx.b	d2,d2		;uebernehmen
		or.b	#$80,d2		;attach-bit
		move.b	d0,d1
;d1 = erstes kontrollwort
;d2 = zweites kontrollwort

		lea	$dff120,a1
		moveq	#4-1,d7
.koos_loop:
		move.l	a0,(a1)+	;pointer schreiben
		move.w	d1,(a0)		;kontrollwort 1
		move.w	d2,2(a0)	;kontrollwort 2
		add.w	#73*4,a0	;naechstes sprite
		move.l	a0,(a1)+
		move.w	d1,(a0)
		move.w	d2,2(a0)
		addq	#8,d1		;16 pixel nach rechts
		add.w	#73*4,a0
		dbra	d7,.koos_loop

		subq	#1,elfe_anidelay
		bpl.s	.cont
		addq	#3,elfe_anidelay
		addq	#1,elfe_ani
		tst	magic_doit
		bpl.s	.no_xani
		tst.w	magic_offs
		bmi.s	.no_add
		addq	#4,magic_offs
.no_add:	cmp	#3,elfe_ani	;-> hier uebergang !
		bne.s	.no_xani
		move	#4,elfe_ani	;-> zauber starten !
		clr.w	magic_offs	;jetzt mega_funkel !
		bra.s	.cont
.no_xani:	cmp	#4,elfe_ani
		beq.s	.reset
		cmp	#23,elfe_ani
		bne.s	.cont
		move.w	#1,magic_doit	;-> zauber beendet !
		move	#-110,magic_x	;nach soviel vbl's los !
.reset:		clr.w	elfe_ani
.cont:
;*** flugstaub ! ***
		subq	#1,elfe_fcount
		bpl.s	.no_newf
		move	elfe_fdelay,d0
		tst	magic_doit
		beq.s	.much
		lsl	#4,d0
.much:		add	d0,elfe_fcount
		move	posx,d0
		add	#19,d0
		move	posy,d1
		add	#17,d1
		bsr	new_funkel
.no_newf:
;*** mega-staub !!! ***
		tst	magic_doit
		bpl.s	.no_megaf
		move	magic_offs,d4
		bmi.s	.no_megaf
		tst.w	elfe_anidelay
		bne.s	.no_megaf
		lea	magic_offstab,a5
		move.w	(a5,d4.w),d0	;ani-offset holen !
		move.w	2(a5,d4.w),d1	;
		add	posx,d0
		add	posy,d1
		sub	#125,d0
		sub	#70,d1
		cmp	#16,elfe_ani	;punkt losloesen ?
		bne.s	.no
		move	d0,megaf_x
		move	d1,megaf_y
.no:		bsr	new_funkel
.no_megaf:
;*** hyper-staub ! ***
		move	megaf_x,d2
		bmi.s	.no_hyperf
		move	megaf_y,d3
		moveq	#6-1,d7
.mhf_loop:
		bsr	random
		move	d0,d1
		lsr	#4,d1
		and	#15,d0
		and	#15,d1
		add	d2,d0
		add	d3,d1
		movem.w	d2/d3/d7,-(sp)
		bsr	new_funkel
		movem.w	(sp)+,d2/d3/d7
		dbra	d7,.mhf_loop

		addq	#6,megaf_x
		addq	#1,megaf_y
		cmp	#160,megaf_x
		blt.s	.no_hyperf
		move	#-1,megaf_x
.no_hyperf:
		cmp	#-1,magic_x
		bge.s	.no_mxwait
		addq	#1,magic_x
		cmp	#-1,magic_x
		bne.s	.no_mxwait
		move	#60,magic_x	;starten !
.no_mxwait:
		movem.l	(sp)+,d0-d7/a0-a6
		move	#%100000,$dff09c
	nop
	nop
		rte

;*** sprites killen ***
skip_level3:
		lea	$dff120,a0
		moveq	#8-1,d7
		lea	sprite_00,a1
.sprk_loop:	move.l	a1,(a0)+
		dbra	d7,.sprk_loop
		movem.l	(sp)+,d0-d7/a0-a6
		move	#%100000,$dff09c
		rte

vsync:
		move.l	vindex,d0
.wait:		cmp.l	vindex,d0
		beq.s	.wait
		rts






;*************************************
; [ sterne pinseln ]
;
;*************************************
make_magic:
		move	magic_x,d4
		bmi	no_magicmake
;--- neue spalte blitten ---
		cmp	#64,d4
		blt.s	.no_vline
		cmp	#272,d4
		bge.s	.no_vline
		move	d4,d0
		sub	#64,d0
		moveq	#15,d2
		and	d0,d2
		lsr	#3,d0
		lea	background+8+146*200,a1
		lea	flogo,a0
		add.w	d0,a0
		add.w	d0,a1
		lea	$dff000,a6
		lsr	#2,d2
		add	d2,d2
		lea	mbl_masks,a2
		waitblit
		move	#40-2,$60(a6)	;c	
		move	#26-2,$64(a6)	;a
		move	#40-2,$66(a6)	;d
		move.l	a0,$50(a6)	;source_a
		move.l	a1,$48(a6)	;source_c
		move.l	a1,$54(a6)	;dest_d
		move.l	#-1,$44(a6)
;			  fedcba9876543210
		move.w	#%0000101111100010,$40(a6)
		move.w	#0,$42(a6)
		move.w	(a2,d2.w),$72(a6)	;data_b
		move.w	#83*planes*64+1,$58(a6)	;blit !

.no_vline:
		moveq	#24-1,d7
.iloop:
		bsr	random
		move.l	d0,d1
		divu	#88,d1
		swap	d1
		add	#148-8,d1		
		bsr	random
		move	#7*32,d2
		and	d0,d2		;-> ani * 32
		and	#7,d0
		sub	#4,d0
		add	d4,d0

;--- neuen starten ---
		lea	magic_buffer,a0
		move	#star_anz-1,d6
.sloop:		tst.w	(a0)
		bmi.s	.free
		addq.l	#6,a0
		dbra	d6,.sloop
		bra.s	.no_free
.free:		move	d0,(a0)+	;x
		move	d1,(a0)+
		move	d2,(a0)+	;ani
		dbra	d7,.iloop
.no_free:
;--- bewegen ---
		addq	#4,magic_x
		cmp	#276,magic_x
		blt.s	.keep
		move	#-1,magic_x
		clr.w	magic_doit
.keep:
no_magicmake:
;--- zeichnen + animieren ---
		lea	magic_buffer,a4
		move	#star_anz-1,d7
.draw_loop:
		move.w	(a4),d0		;x
		bmi.s	.next
		move	2(a4),d1	;y
		move.w	4(a4),d2	;ani
		move.w	mani_tab(pc,d2.w),d2
		bpl.s	.cont
		move	d2,(a4)		;erase
		bra.s	.next
.cont:		addq.w	#2,4(a4)	;weiter animieren
;		addq	#2,(a4)
		mulu	#9*20,d2
		lea	overfunkel,a0
		add.l	d2,a0
		move	#9*planes*64+2,d3
		bsr	blit_star

.next:		addq.l	#6,a4
		dbra	d7,.draw_loop

		rts

mani_tab:
	dc.w	6,3,0,3,6,-1,0,0,0,0,0,0,0,0,0,0
	dc.w	4,1,4,-1,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	8,5,2,5,8,-1,0,0,0,0,0,0,0,0,0,0
	dc.w	6,6,3,3,0,0,3,3,3,6,6,6,-1,0,0,0
	dc.w	7,7,4,4,0,0,0,4,4,7,7,-1,0,0,0,0
	dc.w	8,8,8,5,5,5,0,0,0,5,5,5,8,8,8,-1
	dc.w	3,0,3,-1,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	5,0,5,-1,0,0,0,0,0,0,0,0,0,0,0,0

mbl_masks:
	dc.w	$f000,$0f00,$00f0,$000f


;d0 = x
;d1 = y
new_funkel:
		tst	d0
		bmi.s	.ready
		cmp	#319-8,d0
		bgt.s	.ready
		cmp	#255,d1
		bgt.s	.ready
		cmp	#134,d1
		blt.s	.ready

		lea	plot_buffer,a0
		move	#funkel_anz-1,d7
.slp:		tst.w	(a0)
		bpl.s	.not_free
;		movem.w	posx,d0-d1
		asl.w	#4,d1
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		move.w	#0,(a0)+
		bsr	random
		and	#7,d0
		add	#32,d0
		move.w	d0,(a0)+
		bsr	random
		divu	#11,d0
		swap	d0
		add	d0,d0
		move	d0,(a0)+	;color
		bra.s	.ready
.not_free:	add.w	#funkel_size,a0
		dbra	d7,.slp
.ready:

		rts


random:
		move.w	old_random,d0
		mulu	#53527,d0
		move.w	d0,old_random
		lsr.l	#8,d0
		and.l	#$7fff,d0
		rts

old_random:	dc.w	17



;*** dicke punkte verwalten ***
make_funkel:
	lea	plot_buffer2,a2	;zum neue starten
	move	#funkel_anz2,d6	;anzahl freie
	lea	plot_buffer,a3
	lea	puls_tab,a5

	bsr	random		; Initial start counter
	moveq	#3,d5
	and	d0,d5

; plot_buffer format :
;	X-coordinate
;	Y-coordinate x 16
;	X-speed (???)
;	Y-speed
;	Colour index

	moveq	#funkel_anz-1,d7
.funkel_loop:
	move.l	a3,a4		; Duplicate pointer
	move.w	(a4)+,d0		; Get X-coordinate
	bmi.w	.slot_empty	; Next entry if empty
	move.w	(a4),d1		; Get Y-coordinate
	move.w	4(a4),d2		; Get Y-speed
	add	d2,d1		; Update Y-coordinate
	cmp	#256*16,d1	; Off screen ?
	blt.s	.conty
	move	#-1,(a3)		; Yes -> Clear entry
	bra.w	.slot_empty	; Next entry
.conty:	move	d1,(a4)+		; No -> Store new Y-coordinate

	lsr	#4,d1		; Calculate real Y-coordinate

	move	4(a4),d3		; Get colour index
	move.w	(a5,d3.w),d2	; Get colour from table
	bpl.s	.cok		; Sentinel reached ?
	moveq	#0,d3		; Yes -> Cycle index
	move	(a5),d2		; Get first colour
.cok:	addq	#2,d3		; Update colour index
	move	d3,4(a4)		; Store new colour index

	bsr	plot_5p2		; Display large pixel

	subq	#1,d5		; Time for a new object ?
	bpl.s	.slot_empty	; No -> Next entry
	addq	#3,d5		; Yes -> Reset counter
;--- neues teil starten ---
	tst	d6		; Any new entries free ?
	beq	.slot_empty	; No -> Next entry
.search:	tst.l	(a2)		; Search free entry
	beq.s	.free
	add.w	#funkel_size2,a2
	subq	#1,d6
	bne.s	.search
	bra.s	.slot_empty	; None free -> Next entry
.free:
;--- kleinen punkt starten ---
	bsr	random		; Calculate random Y-speed
	moveq	#15,d1
	and	d0,d1
	addq	#8,d1
	move	d1,6(a2)		; Store
	lsr	#5,d0 
	move	d0,d1		; (Keep)
	and	#3,d0		; Calculate random X-offset
	clr.w	8(a2)		; Default is no star
	lsr	#4,d1		; Chance OK ?
	and	#7,d1
	bne.s	.no_star
	move	#puls_nr2*2,8(a2)	; Yes -> With star
.no_star:
	add.w	(a3),d0		; Get original X-coordinate + offset
	moveq	#7,d1		; Create bit mask
	and	d0,d1
	eor	#7,d1
	moveq	#0,d2
	bset	d1,d2
	moveq	#15,d1		; Combine with bit number
	and	d0,d1
	ror.w	#4,d1
	or	d1,d2
	move.w	d2,(a2)		; Store
	lsr	#3,d0		; Store X-offset on screen
	move.w	d0,2(a2)
	move.w	2(a3),4(a2)	; Copy Y-coordinate

	lea	funkel_size2(a2),a2	; Next new entry
	subq	#1,d6
.slot_empty:
	add.w	#funkel_size,a3	; Next entry
	dbra	d7,.funkel_loop

	rts

puls_tab:
	dc.w 9*4,11*4,13*4,14*4,13*4,12*4,12*4,11*4,10*4,10*4
	dc.w 9*4,9*4,10*4,14*4,12*4,10*4,26*4,28*4
	dc.w 24*4,26*4,28*4,14*4,27*4,26*4,25*4,14*4,20*4,9*4,-1

;*** kleine punkte verwalten ***
make_funkel2:
	lea	plot_jmptab,a2
	lea	plot_buffer2,a3
	lea	puls_tab2,a5
	move.w	#funkel_anz2-1,d7
.funkel_loop:
	move.l	a3,a4
	move.l	(a4)+,d0	;x
	beq.s	.slot_empty
	move.w	(a4),d1		;y
	move.w	2(a4),d2	;yv !
	add	d2,d1
	cmp	#256*16,d1
	blt.s	.conty
	clr.l	(a3)		;abschalten !
	bra.s	.slot_empty
.conty:	move	d1,(a4)

	lsr	#4,d1		;4 bit nachkomma

	move	4(a4),d3	;farbe holen
	move.w	(a5,d3.w),d2
	bne.s	.cok
	clr.l	(a3)		;abschalten
	bra.s	.slot_empty
.cok:	bpl.s	.plot_it

	addq	#2,d3
	move	d3,4(a4)
	cmp	#256-5,d1
	bge.s	.slot_empty
	lea	stars-100,a0	;negativ = stern !
	sub.w	d2,a0
;	bclr	#0,d0
	bsr	blit_star2
	bra.s	.slot_empty		

.plot_it:	addq	#2,d3
	move	d3,4(a4)

.plot:
;	bsr	plot_5p

	mulu	#bpscanl,d1
	move.l	workbase,a0
	add.w	d0,a0	;+ xoffset
	add.l	d1,a0	;+ yoffset
	swap	d0
	move	d0,d1
	not	d1
	move.l	(a2,d2.w),a1
	jsr	(a1)		;passende plotroutine aufrufen

.slot_empty:
	lea	funkel_size2(a3),a3

	dbra	d7,.funkel_loop

	rts

puls_nr2 = 16
puls_tab2:
	dc.w	9*4,10*4,11*4,12*4,11*4,10*4,9*4,9*4,9*4
	dc.w	11*4,14*4,13*4,12*4,11*4,10*4
	dc.w	0
	dc.w	9*4,10*4,11*4,12*4,11*4,10*4,9*4,9*4,9*4
	dc.w	11*4,14*4,-100,-200,-300
	dc.w	0

;d3 = blit_size
blit_star:
		movem.l	d2/a2,-(sp)
		mulu	#bpscanl,d1
		moveq	#15,d2
		and	d0,d2
		sub	d2,d0
		lsr	#3,d0
		ext.l	d0
		add.l	d1,d0
		move.l	workbase,a2
		add.l	d0,a2
		lea	$dff000,a6
		lea	2(a0),a1
		waitblit
		move.l	a1,$50(a6)	;source A
		move.l	a0,$4c(a6)	;source B
		move.l	a2,$48(a6)	;source C
		move.l	a2,$54(a6)	;dest D
		ror.w	#4,d2
		move.w	d2,$42(a6)
;			  fedcba9876543210
		or.w	#%0000111111001010,d2
		move.w	d2,$40(a6)
		move.l	#$ffff0000,$44(a6)
		move.w	#4-4,$64(a6)	;modulo_A
		move.w	#4-4,$62(a6)	;modulo_B
		move.w	#40-4,$60(a6)	;modulo_C
		move.w	#40-4,$66(a6)	;modulo_D
;		move	#5*planes*64+2,$58(a6)	;BLIT !
		move	d3,$58(a6)	;BLIT !
		movem.l	(sp)+,d2/a2
		rts

blit_star2:
;d0 = xoffset(LO) bitnummer(HI) %111100000000
;d1 = y
		mulu	#bpscanl,d1
		move.l	workbase,a1
		add.w	d0,a1
		add.l	d1,a1
		swap	d0
		clr.b	d0		;bitmuster loeschen
		lea	$dff000,a6
		waitblit
		move.l	a1,$48(a6)	;source C
		move.l	a1,$54(a6)	;dest D
		move.l	a0,$4c(a6)	;source B
		lea	2(a0),a1
		move.l	a0,$50(a6)	;source A
		move.w	d0,$42(a6)
;			  fedcba9876543210
		or.w	#%0000111111001010,d0
		move.w	d0,$40(a6)
		move.l	#$ffff0000,$44(a6)
		move.w	#4-4,$64(a6)	;modulo_A
		move.w	#4-4,$62(a6)	;modulo_B
		move.w	#40-4,$60(a6)	;modulo_C
		move.w	#40-4,$66(a6)	;modulo_D
		move	#5*planes*64+2,$58(a6)	;BLIT !
		rts


;*** doppeltes pixel plotten ***
plot_5p2:
		mulu	#bpscanl,d1
		moveq	#7,d3
		and	d0,d3
		eor	#7,d3
		lsr	#3,d0
		ext.l	d0
		add.l	d1,d0
		move.l	workbase,a0
		add.l	d0,a0
		moveq	#0,d0
		bset	d3,d0
		subq	#1,d3
		bmi.s	.shit
		bset	d3,d0
		bra	do_plot
.shit:		bsr	do_plot
		addq.l	#1,a0
		move	#$80,d0
		move	#$7f,d1
		jmp	(a1)
;*** einfaches pixel plotten ***
plot_5p:
;d0 = xoffset(LO) bitmuster(HI)
;d1 = y
;d2 = farbe
		mulu	#bpscanl,d1
		move.l	workbase,a0
		add.w	d0,a0
		add.l	d1,a0
		swap	d0
do_plot:
		move	d0,d1
		not	d1
		move.l	plot_jmptab(pc,d2.w),a1
		jmp	(a1)
plot_jmptab:
		dc.l	.plot00,.plot01,.plot02,.plot03
		dc.l	.plot04,.plot05,.plot06,.plot07
		dc.l	.plot08,.plot09,.plot10,.plot11
		dc.l	.plot12,.plot13,.plot14,.plot15
		dc.l	.plot16,.plot17,.plot18,.plot19
		dc.l	.plot20,.plot21,.plot22,.plot23
		dc.l	.plot24,.plot25,.plot26,.plot27
		dc.l	.plot28,.plot29,.plot30,.plot31

.plot00:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot01:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot02:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot03:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot04:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot05:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot06:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot07:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		and.b	d1,160(a0)
		rts
.plot08:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot09:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot10:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot11:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot12:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot13:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot14:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot15:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		and.b	d1,160(a0)
		rts
.plot16:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot17:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot18:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot19:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot20:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot21:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot22:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot23:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		and.b	d1,120(a0)
		or.b	d0,160(a0)
		rts
.plot24:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
.plot25:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
.plot26:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
.plot27:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		and.b	d1,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
.plot28:
		and.b	d1,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
.plot29:
		or.b	d0,(a0)
		and.b	d1,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
.plot30:
		and.b	d1,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
.plot31:
		or.b	d0,(a0)
		or.b	d0,40(a0)
		or.b	d0,80(a0)
		or.b	d0,120(a0)
		or.b	d0,160(a0)
		rts
