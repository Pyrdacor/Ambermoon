; ST kernel : the fairy of Thalion
; The code of the Amiga program Fantasy_intro (deploded and made from the
; executable with port/tools/intro_source.py and port/tools/fantasy_patch.py).
; The labels are the offsets in the code. The hardware of the Amiga :
; INTRO_COMMON.S, AMIGA_BLIT.S and the FANTASY_HW.S of the machine. The data
; are made by port/tools/intro_data.py.

	include	ST_KERNEL/FANTASY_HW.S

	SECTION	Program,code

F000d0:
F000e2:
F000f8:
F00110:
	bsr.w	F00d22	; 00110
	bsr.w	F00c2c	; 00114
	lea.l	(Fant_h1+$d38c).l,a0	; 00118
	movea.l	(Fant_h2+$f4).l,a1	; 0011e
	movea.l	(Fant_h2+$f0).l,a2	; 00124
	move.w	#$31ff,d7	; 0012a
F0012e:
	move.l	(a0)+,d0	; 0012e
	move.l	d0,(a1)+	; 00130
	move.l	d0,(a2)+	; 00132
	dbra	d7,F0012e	; 00134
	jsr	Fantasy_new_picture
	bsr.w	F0101a	; 00138
	move.w	#$87e0,(Intro_custom+$096).l	; 0013c
	move.w	#$a0,(Fant_h2+$c8).l	; 00144
	move.w	#$64,(Fant_h2+$ca).l	; 0014c
	lea.l	(Fant_h2+$a62).l,a0	; 00154
	move.w	#$5f,d7	; 0015a
F0015e:
	move.w	#$ffff,(a0)	; 0015e
	adda.w	#$a,a0	; 00162
	dbra	d7,F0015e	; 00166
	lea.l	(Fant_h2+$e22).l,a0	; 0016a
	move.w	#$1ff,d7	; 00170
F00174:
	clr.l	(a0)	; 00174
	adda.w	#$a,a0	; 00176
	dbra	d7,F00174	; 0017a
	lea.l	(Fant_h2+$102).l,a0	; 0017e
	move.w	#$18f,d7	; 00184
F00188:
	move.w	#$ffff,(a0)	; 00188
	addq.l	#$6,a0	; 0018c
	dbra	d7,F00188	; 0018e
	clr.w	(Fant_h2+$bc).l	; 00192
	clr.w	(Fant_h2+$be).l	; 00198
	clr.w	(Fant_h2+$cc).l	; 0019e
	move.w	#$2,(Fant_h2+$ce).l	; 001a4
	clr.w	(Fant_h2+$d6).l	; 001ac
	clr.w	(Fant_h2+$c2).l	; 001b2
	clr.w	(Fant_h2+$c4).l	; 001b8
	move.w	#$ffff,(Fant_h2+$c0).l	; 001be
	move.l	#Fant_h1+$1ce22,(Fant_h2+$b8).l	; 001c6
	moveq	#$e,d6	; 001d0
F001d2:
	bsr.w	F0101a	; 001d2
	bsr.w	F0101a	; 001d6
	lea.l	(Fant_h1+$40).l,a0	; 001da
	lea.l	(Fant_h2+$20).l,a1	; 001e0
	moveq	#$20,d7	; 001e6
	bsr.w	F010d0	; 001e8
	lea.l	(Fant_h1+$0).l,a0	; 001ec
	lea.l	(Fant_h2+$60).l,a1	; 001f2
	moveq	#$20,d7	; 001f8
	bsr.w	F010d0	; 001fa
	move.w	d6,-(a7)	; 001fe
	bsr.w	F00c98	; 00200
	move.w	(a7)+,d6	; 00204
	dbra	d6,F001d2	; 00206
	move.w	#$32,d7	; 0020a
F0020e:
	bsr.w	F0101a	; 0020e
	btst	#$6,(Intro_ciaa).l	; 00212
	dbeq	d7,F0020e	; 0021a
	move.w	#$ffff,(Fant_h2+$d0).l	; 0021e
F00226:
	bsr.w	F00c0a	; 00226
	clr.l	(Fant_h2+$a0).l
	bsr.w	F00c98	; 0022a
	bsr.w	F00bc0	; 00238
	bsr.w	F005be	; 0023c
	bsr.w	F006c8	; 00240
	bsr.w	F00316	; 00244
F00248:
	cmpi.l	#3,(Fant_h2+$a0).l
	blt.b	F00248	; 00252
	btst	#$6,(Intro_ciaa).l	; 00254
	bne.b	F00278	; 0025c
	tst.w	(Fant_h2+$d6).l	; 0025e
	beq.b	F00270	; 00264
	cmpi.w	#$10,(Fant_h2+$d6).l	; 00266
	ble.b	F00278	; 0026e
F00270:
	move.w	#$10,(Fant_h2+$d6).l	; 00270
F00278:
	tst.w	(Fant_h2+$d6).l	; 00278
	beq.b	F00226	; 0027e
	subi.w	#$1,(Fant_h2+$d6).l	; 00280
	beq.b	F002b0	; 00288
	cmpi.w	#$10,(Fant_h2+$d6).l	; 0028a
	bge.b	F00226	; 00292
	lea.l	(Fant_h2+$20).l,a0	; 00294
	moveq	#$20,d7	; 0029a
	bsr.w	F01118	; 0029c
	lea.l	(Fant_h2+$60).l,a0	; 002a0
	moveq	#$20,d7	; 002a6
	bsr.w	F01118	; 002a8
	bra.w	F00226	; 002ac
F002b0:
	jsr	Fantasy_exit
	rts
F00316:
	move.w	(Fant_h2+$c0).l,d4	; 00316
	bmi.w	F00404	; 0031c
	cmp.w	#$40,d4	; 00320
	blt.w	F003a0
	cmp.w	#$110,d4	; 00326
	bge.w	F003a0
	move.w	d4,d0	; 0032c
	subi.w	#$40,d0	; 0032e
	moveq	#$f,d2	; 00332
	and.w	d0,d2	; 00334
	lsr.w	#$3,d0	; 00336
	lea.l	(Fant_h1+$145a4).l,a1	; 00338
	lea.l	(Fant_h1+$1a3fc).l,a0	; 0033e
	adda.w	d0,a0	; 00344
	adda.w	d0,a1	; 00346
	jsr	Fantasy_draw_reveal
	beq	F003a0
	lea.l	Intro_custom,a6
	lsr.w	#$2,d2	; 0034e
	add.w	d2,d2	; 00350
	lea.l	(F00544).l,a2	; 00352
F00358:
	btst	#$e,(Intro_custom+$002).l	; 00358
	bne.b	F00358	; 00360
	move.w	#$26,$60(a6)	; 00362
	move.w	#$18,$64(a6)	; 00368
	move.w	#$26,$66(a6)	; 0036e
	move.l	a0,$50(a6)	; 00374
	move.l	a1,$48(a6)	; 00378
	move.l	a1,$54(a6)	; 0037c
	move.l	#$ffffffff,$44(a6)	; 00380
	move.w	#$be2,$40(a6)	; 00388
	move.w	#$0,$42(a6)	; 0038e
	move.w	(a2,d2.w),$72(a6)	; 00394
	move.w	#$67c1,$58(a6)	; 0039a
	jsr	Intro_blit
F003a0:
	moveq	#$17,d7
	lea.l	(Fant_h2+$102).l,a0
	move.w	#$18f,d6
F003a2:
	bsr.w	F005a2	; 003a2
	move.l	d0,d1	; 003a6
	divu.w	#$58,d1	; 003a8
	swap	d1	; 003ac
	addi.w	#$8c,d1	; 003ae
	bsr.w	F005a2	; 003b2
	move.w	#$e0,d2	; 003b6
	and.w	d0,d2	; 003ba
	andi.w	#$7,d0	; 003bc
	subi.w	#$4,d0	; 003c0
	add.w	d4,d0	; 003c4
F003d0:
	tst.w	(a0)	; 003d0
	bmi.b	F003dc	; 003d2
	addq.l	#$6,a0	; 003d4
	dbra	d6,F003d0	; 003d6
	bra.b	F003e6	; 003da
F003dc:
	move.w	d0,(a0)+	; 003dc
	move.w	d1,(a0)+	; 003de
	move.w	d2,(a0)+	; 003e0
	subq.w	#1,d6
	bmi.s	F003e6
	dbra	d7,F003a2	; 003e2
F003e6:
	addq.w	#$4,(Fant_h2+$c0).l	; 003e6
	cmpi.w	#$114,(Fant_h2+$c0).l	; 003ec
	blt.b	F00404	; 003f4
	move.w	#$ffff,(Fant_h2+$c0).l	; 003f6
	clr.w	(Fant_h2+$c4).l	; 003fe
F00404:
	lea.l	(Fant_h2+$102).l,a4	; 00404
	move.w	#$18f,d7	; 0040a
F0040e:
	move.w	(a4),d0	; 0040e
	bmi.b	F0043c	; 00410
	move.w	$2(a4),d1	; 00412
	move.w	$4(a4),d2	; 00416
	move.w	F00444(pc,d2.w),d2	; 0041a
	bpl.b	F00424	; 0041e
	move.w	d2,(a4)	; 00420
	bra.b	F0043c	; 00422
F00424:
	addq.w	#$2,$4(a4)	; 00424
	mulu.w	#$b4,d2	; 00428
	lea.l	(Fant_h1+$19b8c).l,a0	; 0042c
	adda.l	d2,a0	; 00432
	move.w	#$b42,d3	; 00434
	bsr.w	F0078c	; 00438
F0043c:
	addq.l	#$6,a4	; 0043c
	dbra	d7,F0040e	; 0043e
	rts		; 00442
F00444:
	dc.w	$0006	; 00444
	dc.w	$0003	; 00446
	dc.w	$0000	; 00448
	dc.w	$0003	; 0044a
	dc.w	$0006	; 0044c
	dc.w	$ffff	; 0044e
	dc.w	$0000	; 00450
	dc.w	$0000	; 00452
	dc.w	$0000	; 00454
	dc.w	$0000	; 00456
	dc.w	$0000	; 00458
	dc.w	$0000	; 0045a
	dc.w	$0000	; 0045c
	dc.w	$0000	; 0045e
	dc.w	$0000	; 00460
	dc.w	$0000	; 00462
	dc.w	$0004	; 00464
	dc.w	$0001	; 00466
	dc.w	$0004	; 00468
	dc.w	$ffff	; 0046a
	dc.w	$0000	; 0046c
	dc.w	$0000	; 0046e
	dc.w	$0000	; 00470
	dc.w	$0000	; 00472
	dc.w	$0000	; 00474
	dc.w	$0000	; 00476
	dc.w	$0000	; 00478
	dc.w	$0000	; 0047a
	dc.w	$0000	; 0047c
	dc.w	$0000	; 0047e
	dc.w	$0000	; 00480
	dc.w	$0000	; 00482
	dc.w	$0008	; 00484
	dc.w	$0005	; 00486
	dc.w	$0002	; 00488
	dc.w	$0005	; 0048a
	dc.w	$0008	; 0048c
	dc.w	$ffff	; 0048e
	dc.w	$0000	; 00490
	dc.w	$0000	; 00492
	dc.w	$0000	; 00494
	dc.w	$0000	; 00496
	dc.w	$0000	; 00498
	dc.w	$0000	; 0049a
	dc.w	$0000	; 0049c
	dc.w	$0000	; 0049e
	dc.w	$0000	; 004a0
	dc.w	$0000	; 004a2
	dc.w	$0006	; 004a4
	dc.w	$0006	; 004a6
	dc.w	$0003	; 004a8
	dc.w	$0003	; 004aa
	dc.w	$0000	; 004ac
	dc.w	$0000	; 004ae
	dc.w	$0003	; 004b0
	dc.w	$0003	; 004b2
	dc.w	$0003	; 004b4
	dc.w	$0006	; 004b6
	dc.w	$0006	; 004b8
	dc.w	$0006	; 004ba
	dc.w	$ffff	; 004bc
	dc.w	$0000	; 004be
	dc.w	$0000	; 004c0
	dc.w	$0000	; 004c2
	dc.w	$0007	; 004c4
	dc.w	$0007	; 004c6
	dc.w	$0004	; 004c8
	dc.w	$0004	; 004ca
	dc.w	$0000	; 004cc
	dc.w	$0000	; 004ce
	dc.w	$0000	; 004d0
	dc.w	$0004	; 004d2
	dc.w	$0004	; 004d4
	dc.w	$0007	; 004d6
	dc.w	$0007	; 004d8
	dc.w	$ffff	; 004da
	dc.w	$0000	; 004dc
	dc.w	$0000	; 004de
	dc.w	$0000	; 004e0
	dc.w	$0000	; 004e2
	dc.w	$0008	; 004e4
	dc.w	$0008	; 004e6
	dc.w	$0008	; 004e8
	dc.w	$0005	; 004ea
	dc.w	$0005	; 004ec
	dc.w	$0005	; 004ee
	dc.w	$0000	; 004f0
	dc.w	$0000	; 004f2
	dc.w	$0000	; 004f4
	dc.w	$0005	; 004f6
	dc.w	$0005	; 004f8
	dc.w	$0005	; 004fa
	dc.w	$0008	; 004fc
	dc.w	$0008	; 004fe
	dc.w	$0008	; 00500
	dc.w	$ffff	; 00502
	dc.w	$0003	; 00504
	dc.w	$0000	; 00506
	dc.w	$0003	; 00508
	dc.w	$ffff	; 0050a
	dc.w	$0000	; 0050c
	dc.w	$0000	; 0050e
	dc.w	$0000	; 00510
	dc.w	$0000	; 00512
	dc.w	$0000	; 00514
	dc.w	$0000	; 00516
	dc.w	$0000	; 00518
	dc.w	$0000	; 0051a
	dc.w	$0000	; 0051c
	dc.w	$0000	; 0051e
	dc.w	$0000	; 00520
	dc.w	$0000	; 00522
	dc.w	$0005	; 00524
	dc.w	$0000	; 00526
	dc.w	$0005	; 00528
	dc.w	$ffff	; 0052a
	dc.w	$0000	; 0052c
	dc.w	$0000	; 0052e
	dc.w	$0000	; 00530
	dc.w	$0000	; 00532
	dc.w	$0000	; 00534
	dc.w	$0000	; 00536
	dc.w	$0000	; 00538
	dc.w	$0000	; 0053a
	dc.w	$0000	; 0053c
	dc.w	$0000	; 0053e
	dc.w	$0000	; 00540
	dc.w	$0000	; 00542
F00544:
	dc.w	$f000	; 00544
	dc.w	$0f00	; 00546
	dc.w	$00f0	; 00548
	dc.w	$000f	; 0054a
F0054c:
	tst.w	d0	; 0054c
	bmi.b	F005a0	; 0054e
	cmp.w	#$137,d0	; 00550
	bgt.b	F005a0	; 00554
	cmp.w	#$ff,d1	; 00556
	bgt.b	F005a0	; 0055a
	cmp.w	#$86,d1	; 0055c
	blt.b	F005a0	; 00560
	lea.l	(Fant_h2+$a62).l,a0	; 00562
	move.w	#$5f,d7	; 00568
F0056c:
	tst.w	(a0)	; 0056c
	bpl.b	F00598	; 0056e
	asl.w	#$4,d1	; 00570
	move.w	d0,(a0)+	; 00572
	move.w	d1,(a0)+	; 00574
	move.w	#$0,(a0)+	; 00576
	bsr.w	F005a2	; 0057a
	andi.w	#$7,d0	; 0057e
	addi.w	#$20,d0	; 00582
	move.w	d0,(a0)+	; 00586
	bsr.w	F005a2	; 00588
	divu.w	#$b,d0	; 0058c
	swap	d0	; 00590
	add.w	d0,d0	; 00592
	move.w	d0,(a0)+	; 00594
	bra.b	F005a0	; 00596
F00598:
	adda.w	#$a,a0	; 00598
	dbra	d7,F0056c	; 0059c
F005a0:
	rts		; 005a0
F005a2:
	move.w	(F005bc).l,d0	; 005a2
	mulu.w	#$d117,d0	; 005a8
	move.w	d0,(F005bc).l	; 005ac
	lsr.l	#$8,d0	; 005b2
	andi.l	#$7fff,d0	; 005b4
	rts		; 005ba
F005bc:
	dc.w	$0011	; 005bc
F005be:
	lea.l	(Fant_h2+$e22).l,a2	; 005be
	move.w	#$200,d6	; 005c4
	lea.l	(Fant_h2+$a62).l,a3	; 005c8
	lea.l	(F0068e).l,a5	; 005ce
	bsr.w	F005a2	; 005d4
	moveq	#$3,d5	; 005d8
	and.w	d0,d5	; 005da
	moveq	#$5f,d7	; 005dc
F005de:
	movea.l	a3,a4	; 005de
	move.w	(a4)+,d0	; 005e0
	bmi.w	F00684	; 005e2
	move.w	(a4),d1	; 005e6
	move.w	$4(a4),d2	; 005e8
	add.w	d2,d1	; 005ec
	cmp.w	#$1000,d1	; 005ee
	blt.b	F005fc	; 005f2
	move.w	#$ffff,(a3)	; 005f4
	bra.w	F00684	; 005f8
F005fc:
	move.w	d1,(a4)+	; 005fc
	lsr.w	#$4,d1	; 005fe
	move.w	$4(a4),d3	; 00600
	move.w	(a5,d3.w),d2	; 00604
	bpl.b	F0060e	; 00608
	moveq	#$0,d3	; 0060a
	move.w	(a5),d2	; 0060c
F0060e:
	addq.w	#$2,d3	; 0060e
	move.w	d3,$4(a4)	; 00610
	bsr.w	F0086e	; 00614
	subq.w	#$1,d5	; 00618
	bpl.b	F00684	; 0061a
	addq.w	#$3,d5	; 0061c
	tst.w	d6	; 0061e
	beq.w	F00684	; 00620
F00624:
	tst.l	(a2)	; 00624
	beq.b	F00632	; 00626
	adda.w	#$a,a2	; 00628
	subq.w	#$1,d6	; 0062c
	bne.b	F00624	; 0062e
	bra.b	F00684	; 00630
F00632:
	bsr.w	F005a2	; 00632
	moveq	#$f,d1	; 00636
	and.w	d0,d1	; 00638
	addq.w	#$8,d1	; 0063a
	move.w	d1,$6(a2)	; 0063c
	lsr.w	#$5,d0	; 00640
	move.w	d0,d1	; 00642
	andi.w	#$3,d0	; 00644
	clr.w	$8(a2)	; 00648
	lsr.w	#$4,d1	; 0064c
	andi.w	#$7,d1	; 0064e
	bne.b	F0065a	; 00652
	move.w	#$20,$8(a2)	; 00654
F0065a:
	add.w	(a3),d0	; 0065a
	moveq	#$7,d1	; 0065c
	and.w	d0,d1	; 0065e
	eori.w	#$7,d1	; 00660
	moveq	#$0,d2	; 00664
	bset	d1,d2	; 00666
	moveq	#$f,d1	; 00668
	and.w	d0,d1	; 0066a
	ror.w	#$4,d1	; 0066c
	or.w	d1,d2	; 0066e
	move.w	d2,(a2)	; 00670
	lsr.w	#$3,d0	; 00672
	move.w	d0,$2(a2)	; 00674
	move.w	$2(a3),$4(a2)	; 00678
	lea.l	$a(a2),a2	; 0067e
	subq.w	#$1,d6	; 00682
F00684:
	adda.w	#$a,a3	; 00684
	dbra	d7,F005de	; 00688
	rts		; 0068c
F0068e:
	dc.w	$0024	; 0068e
	dc.w	$002c	; 00690
	dc.w	$0034	; 00692
	dc.w	$0038	; 00694
	dc.w	$0034	; 00696
	dc.w	$0030	; 00698
	dc.w	$0030	; 0069a
	dc.w	$002c	; 0069c
	dc.w	$0028	; 0069e
	dc.w	$0028	; 006a0
	dc.w	$0024	; 006a2
	dc.w	$0024	; 006a4
	dc.w	$0028	; 006a6
	dc.w	$0038	; 006a8
	dc.w	$0030	; 006aa
	dc.w	$0028	; 006ac
	dc.w	$0068	; 006ae
	dc.w	$0070	; 006b0
	dc.w	$0060	; 006b2
	dc.w	$0068	; 006b4
	dc.w	$0070	; 006b6
	dc.w	$0038	; 006b8
	dc.w	$006c	; 006ba
	dc.w	$0068	; 006bc
	dc.w	$0064	; 006be
	dc.w	$0038	; 006c0
	dc.w	$0050	; 006c2
	dc.w	$0024	; 006c4
	dc.w	$ffff	; 006c6
F006c8:
	lea.l	(F008c0).l,a2	; 006c8
	lea.l	(Fant_h2+$e22).l,a3	; 006ce
	lea.l	(F0074e).l,a5	; 006d4
	move.w	#$1ff,d7	; 006da
F006de:
	movea.l	a3,a4	; 006de
	move.l	(a4)+,d0	; 006e0
	beq.b	F00744	; 006e2
	move.w	(a4),d1	; 006e4
	move.w	$2(a4),d2	; 006e6
	add.w	d2,d1	; 006ea
	cmp.w	#$1000,d1	; 006ec
	blt.b	F006f6	; 006f0
	clr.l	(a3)	; 006f2
	bra.b	F00744	; 006f4
F006f6:
	move.w	d1,(a4)	; 006f6
	lsr.w	#$4,d1	; 006f8
	move.w	$4(a4),d3	; 006fa
	move.w	(a5,d3.w),d2	; 006fe
	bne.b	F00708	; 00702
	clr.l	(a3)	; 00704
	bra.b	F00744	; 00706
F00708:
	bpl.b	F00724	; 00708
	addq.w	#$2,d3	; 0070a
	move.w	d3,$4(a4)	; 0070c
	cmp.w	#$fb,d1	; 00710
	bge.b	F00744	; 00714
	lea.l	(Fant_h1+$1c).l,a0	; 00716
	suba.w	d2,a0	; 0071c
	bsr.w	F00804	; 0071e
	bra.b	F00744	; 00722
F00724:
	addq.w	#$2,d3	; 00724
	move.w	d3,$4(a4)	; 00726
	jsr	Fantasy_draw_dot
	beq	F00744
	mulu.w	#$c8,d1
	movea.l	(Fant_h2+$ec).l,a0	; 0072e
	adda.w	d0,a0	; 00734
	adda.l	d1,a0	; 00736
	swap	d0	; 00738
	move.w	d0,d1	; 0073a
	not.w	d1	; 0073c
	movea.l	(a2,d2.w),a1	; 0073e
	jsr	(a1)	; 00742
F00744:
	lea.l	$a(a3),a3	; 00744
	dbra	d7,F006de	; 00748
	rts		; 0074c
F0074e:
	dc.w	$0024	; 0074e
	dc.w	$0028	; 00750
	dc.w	$002c	; 00752
	dc.w	$0030	; 00754
	dc.w	$002c	; 00756
	dc.w	$0028	; 00758
	dc.w	$0024	; 0075a
	dc.w	$0024	; 0075c
	dc.w	$0024	; 0075e
	dc.w	$002c	; 00760
	dc.w	$0038	; 00762
	dc.w	$0034	; 00764
	dc.w	$0030	; 00766
	dc.w	$002c	; 00768
	dc.w	$0028	; 0076a
	dc.w	$0000	; 0076c
	dc.w	$0024	; 0076e
	dc.w	$0028	; 00770
	dc.w	$002c	; 00772
	dc.w	$0030	; 00774
	dc.w	$002c	; 00776
	dc.w	$0028	; 00778
	dc.w	$0024	; 0077a
	dc.w	$0024	; 0077c
	dc.w	$0024	; 0077e
	dc.w	$002c	; 00780
	dc.w	$0038	; 00782
	dc.w	$ff9c	; 00784
	dc.w	$ff38	; 00786
	dc.w	$fed4	; 00788
	dc.w	$0000	; 0078a
F0078c:
	jsr	Fantasy_draw_sparkle
	bne.s	*+4
	rts
	movem.l	d2/a2,-(a7)
	mulu.w	#$c8,d1	; 00790
	moveq	#$f,d2	; 00794
	and.w	d0,d2	; 00796
	sub.w	d2,d0	; 00798
	lsr.w	#$3,d0	; 0079a
	ext.l	d0	; 0079c
	add.l	d1,d0	; 0079e
	movea.l	(Fant_h2+$ec).l,a2	; 007a0
	adda.l	d0,a2	; 007a6
	lea.l	Intro_custom,a6	; 007a8
	lea.l	$2(a0),a1	; 007ae
F007b2:
	btst	#$e,(Intro_custom+$002).l	; 007b2
	bne.b	F007b2	; 007ba
	move.l	a1,$50(a6)	; 007bc
	move.l	a0,$4c(a6)	; 007c0
	move.l	a2,$48(a6)	; 007c4
	move.l	a2,$54(a6)	; 007c8
	ror.w	#$4,d2	; 007cc
	move.w	d2,$42(a6)	; 007ce
	ori.w	#$fca,d2	; 007d2
	move.w	d2,$40(a6)	; 007d6
	move.l	#$ffff0000,$44(a6)	; 007da
	move.w	#$0,$64(a6)	; 007e2
	move.w	#$0,$62(a6)	; 007e8
	move.w	#$24,$60(a6)	; 007ee
	move.w	#$24,$66(a6)	; 007f4
	jsr	Fantasy_sparkle
	movem.l	(a7)+,d2/a2	; 007fe
	rts		; 00802
F00804:
	jsr	Fantasy_draw_small
	bne.s	*+4
	rts
	mulu.w	#$c8,d1
	movea.l	(Fant_h2+$ec).l,a1	; 00808
	adda.w	d0,a1	; 0080e
	adda.l	d1,a1	; 00810
	swap	d0	; 00812
	clr.b	d0	; 00814
	lea.l	Intro_custom,a6	; 00816
F0081c:
	btst	#$e,(Intro_custom+$002).l	; 0081c
	bne.b	F0081c	; 00824
	move.l	a1,$48(a6)	; 00826
	move.l	a1,$54(a6)	; 0082a
	move.l	a0,$4c(a6)	; 0082e
	lea.l	$2(a0),a1	; 00832
	move.l	a0,$50(a6)	; 00836
	move.w	d0,$42(a6)	; 0083a
	ori.w	#$fca,d0	; 0083e
	move.w	d0,$40(a6)	; 00842
	move.l	#$ffff0000,$44(a6)	; 00846
	move.w	#$0,$64(a6)	; 0084e
	move.w	#$0,$62(a6)	; 00854
	move.w	#$24,$60(a6)	; 0085a
	move.w	#$24,$66(a6)	; 00860
	move.w	#$642,$58(a6)	; 00866
	jsr	Intro_blit
	rts		; 0086c
F0086e:
	jsr	Fantasy_draw_dots
	bne.s	*+4
	rts
	mulu.w	#$c8,d1
	moveq	#$7,d3	; 00872
	and.w	d0,d3	; 00874
	eori.w	#$7,d3	; 00876
	lsr.w	#$3,d0	; 0087a
	ext.l	d0	; 0087c
	add.l	d1,d0	; 0087e
	movea.l	(Fant_h2+$ec).l,a0	; 00880
	adda.l	d0,a0	; 00886
	moveq	#$0,d0	; 00888
	bset	d3,d0	; 0088a
	subq.w	#$1,d3	; 0088c
	bmi.b	F00896	; 0088e
	bset	d3,d0	; 00890
	bra.w	F008b6	; 00892
F00896:
	bsr.w	F008b6	; 00896
	addq.l	#$1,a0	; 0089a
	move.w	#$80,d0	; 0089c
	move.w	#$7f,d1	; 008a0
	jmp	(a1)	; 008a4
	dc.w	$c2fc	; 008a6
	dc.w	$00c8	; 008a8
	dc.w	$2079	; 008aa
	dc.l	Fant_h2+$ec	; 008ac
	dc.w	$d0c0	; 008b0
	dc.w	$d1c1	; 008b2
	dc.w	$4840	; 008b4
F008b6:
	move.w	d0,d1	; 008b6
	not.w	d1	; 008b8
	movea.l	F008c0(pc,d2.w),a1	; 008ba
	jmp	(a1)	; 008be
F008c0:
	dc.l	F00940	; 008c0
	dc.l	F00954	; 008c4
	dc.l	F00968	; 008c8
	dc.l	F0097c	; 008cc
	dc.l	F00990	; 008d0
	dc.l	F009a4	; 008d4
	dc.l	F009b8	; 008d8
	dc.l	F009cc	; 008dc
	dc.l	F009e0	; 008e0
	dc.l	F009f4	; 008e4
	dc.l	F00a08	; 008e8
	dc.l	F00a1c	; 008ec
	dc.l	F00a30	; 008f0
	dc.l	F00a44	; 008f4
	dc.l	F00a58	; 008f8
	dc.l	F00a6c	; 008fc
	dc.l	F00a80	; 00900
	dc.l	F00a94	; 00904
	dc.l	F00aa8	; 00908
	dc.l	F00abc	; 0090c
	dc.l	F00ad0	; 00910
	dc.l	F00ae4	; 00914
	dc.l	F00af8	; 00918
	dc.l	F00b0c	; 0091c
	dc.l	F00b20	; 00920
	dc.l	F00b34	; 00924
	dc.l	F00b48	; 00928
	dc.l	F00b5c	; 0092c
	dc.l	F00b70	; 00930
	dc.l	F00b84	; 00934
	dc.l	F00b98	; 00938
	dc.l	F00bac	; 0093c
F00940:
	and.b	d1,(a0)	; 00940
	and.b	d1,$28(a0)	; 00942
	and.b	d1,$50(a0)	; 00946
	and.b	d1,$78(a0)	; 0094a
	and.b	d1,$a0(a0)	; 0094e
	rts		; 00952
F00954:
	or.b	d0,(a0)	; 00954
	and.b	d1,$28(a0)	; 00956
	and.b	d1,$50(a0)	; 0095a
	and.b	d1,$78(a0)	; 0095e
	and.b	d1,$a0(a0)	; 00962
	rts		; 00966
F00968:
	and.b	d1,(a0)	; 00968
	or.b	d0,$28(a0)	; 0096a
	and.b	d1,$50(a0)	; 0096e
	and.b	d1,$78(a0)	; 00972
	and.b	d1,$a0(a0)	; 00976
	rts		; 0097a
F0097c:
	or.b	d0,(a0)	; 0097c
	or.b	d0,$28(a0)	; 0097e
	and.b	d1,$50(a0)	; 00982
	and.b	d1,$78(a0)	; 00986
	and.b	d1,$a0(a0)	; 0098a
	rts		; 0098e
F00990:
	and.b	d1,(a0)	; 00990
	and.b	d1,$28(a0)	; 00992
	or.b	d0,$50(a0)	; 00996
	and.b	d1,$78(a0)	; 0099a
	and.b	d1,$a0(a0)	; 0099e
	rts		; 009a2
F009a4:
	or.b	d0,(a0)	; 009a4
	and.b	d1,$28(a0)	; 009a6
	or.b	d0,$50(a0)	; 009aa
	and.b	d1,$78(a0)	; 009ae
	and.b	d1,$a0(a0)	; 009b2
	rts		; 009b6
F009b8:
	and.b	d1,(a0)	; 009b8
	or.b	d0,$28(a0)	; 009ba
	or.b	d0,$50(a0)	; 009be
	and.b	d1,$78(a0)	; 009c2
	and.b	d1,$a0(a0)	; 009c6
	rts		; 009ca
F009cc:
	or.b	d0,(a0)	; 009cc
	or.b	d0,$28(a0)	; 009ce
	or.b	d0,$50(a0)	; 009d2
	and.b	d1,$78(a0)	; 009d6
	and.b	d1,$a0(a0)	; 009da
	rts		; 009de
F009e0:
	and.b	d1,(a0)	; 009e0
	and.b	d1,$28(a0)	; 009e2
	and.b	d1,$50(a0)	; 009e6
	or.b	d0,$78(a0)	; 009ea
	and.b	d1,$a0(a0)	; 009ee
	rts		; 009f2
F009f4:
	or.b	d0,(a0)	; 009f4
	and.b	d1,$28(a0)	; 009f6
	and.b	d1,$50(a0)	; 009fa
	or.b	d0,$78(a0)	; 009fe
	and.b	d1,$a0(a0)	; 00a02
	rts		; 00a06
F00a08:
	and.b	d1,(a0)	; 00a08
	or.b	d0,$28(a0)	; 00a0a
	and.b	d1,$50(a0)	; 00a0e
	or.b	d0,$78(a0)	; 00a12
	and.b	d1,$a0(a0)	; 00a16
	rts		; 00a1a
F00a1c:
	or.b	d0,(a0)	; 00a1c
	or.b	d0,$28(a0)	; 00a1e
	and.b	d1,$50(a0)	; 00a22
	or.b	d0,$78(a0)	; 00a26
	and.b	d1,$a0(a0)	; 00a2a
	rts		; 00a2e
F00a30:
	and.b	d1,(a0)	; 00a30
	and.b	d1,$28(a0)	; 00a32
	or.b	d0,$50(a0)	; 00a36
	or.b	d0,$78(a0)	; 00a3a
	and.b	d1,$a0(a0)	; 00a3e
	rts		; 00a42
F00a44:
	or.b	d0,(a0)	; 00a44
	and.b	d1,$28(a0)	; 00a46
	or.b	d0,$50(a0)	; 00a4a
	or.b	d0,$78(a0)	; 00a4e
	and.b	d1,$a0(a0)	; 00a52
	rts		; 00a56
F00a58:
	and.b	d1,(a0)	; 00a58
	or.b	d0,$28(a0)	; 00a5a
	or.b	d0,$50(a0)	; 00a5e
	or.b	d0,$78(a0)	; 00a62
	and.b	d1,$a0(a0)	; 00a66
	rts		; 00a6a
F00a6c:
	or.b	d0,(a0)	; 00a6c
	or.b	d0,$28(a0)	; 00a6e
	or.b	d0,$50(a0)	; 00a72
	or.b	d0,$78(a0)	; 00a76
	and.b	d1,$a0(a0)	; 00a7a
	rts		; 00a7e
F00a80:
	and.b	d1,(a0)	; 00a80
	and.b	d1,$28(a0)	; 00a82
	and.b	d1,$50(a0)	; 00a86
	and.b	d1,$78(a0)	; 00a8a
	or.b	d0,$a0(a0)	; 00a8e
	rts		; 00a92
F00a94:
	or.b	d0,(a0)	; 00a94
	and.b	d1,$28(a0)	; 00a96
	and.b	d1,$50(a0)	; 00a9a
	and.b	d1,$78(a0)	; 00a9e
	or.b	d0,$a0(a0)	; 00aa2
	rts		; 00aa6
F00aa8:
	and.b	d1,(a0)	; 00aa8
	or.b	d0,$28(a0)	; 00aaa
	and.b	d1,$50(a0)	; 00aae
	and.b	d1,$78(a0)	; 00ab2
	or.b	d0,$a0(a0)	; 00ab6
	rts		; 00aba
F00abc:
	or.b	d0,(a0)	; 00abc
	or.b	d0,$28(a0)	; 00abe
	and.b	d1,$50(a0)	; 00ac2
	and.b	d1,$78(a0)	; 00ac6
	or.b	d0,$a0(a0)	; 00aca
	rts		; 00ace
F00ad0:
	and.b	d1,(a0)	; 00ad0
	and.b	d1,$28(a0)	; 00ad2
	or.b	d0,$50(a0)	; 00ad6
	and.b	d1,$78(a0)	; 00ada
	or.b	d0,$a0(a0)	; 00ade
	rts		; 00ae2
F00ae4:
	or.b	d0,(a0)	; 00ae4
	and.b	d1,$28(a0)	; 00ae6
	or.b	d0,$50(a0)	; 00aea
	and.b	d1,$78(a0)	; 00aee
	or.b	d0,$a0(a0)	; 00af2
	rts		; 00af6
F00af8:
	and.b	d1,(a0)	; 00af8
	or.b	d0,$28(a0)	; 00afa
	or.b	d0,$50(a0)	; 00afe
	and.b	d1,$78(a0)	; 00b02
	or.b	d0,$a0(a0)	; 00b06
	rts		; 00b0a
F00b0c:
	or.b	d0,(a0)	; 00b0c
	or.b	d0,$28(a0)	; 00b0e
	or.b	d0,$50(a0)	; 00b12
	and.b	d1,$78(a0)	; 00b16
	or.b	d0,$a0(a0)	; 00b1a
	rts		; 00b1e
F00b20:
	and.b	d1,(a0)	; 00b20
	and.b	d1,$28(a0)	; 00b22
	and.b	d1,$50(a0)	; 00b26
	or.b	d0,$78(a0)	; 00b2a
	or.b	d0,$a0(a0)	; 00b2e
	rts		; 00b32
F00b34:
	or.b	d0,(a0)	; 00b34
	and.b	d1,$28(a0)	; 00b36
	and.b	d1,$50(a0)	; 00b3a
	or.b	d0,$78(a0)	; 00b3e
	or.b	d0,$a0(a0)	; 00b42
	rts		; 00b46
F00b48:
	and.b	d1,(a0)	; 00b48
	or.b	d0,$28(a0)	; 00b4a
	and.b	d1,$50(a0)	; 00b4e
	or.b	d0,$78(a0)	; 00b52
	or.b	d0,$a0(a0)	; 00b56
	rts		; 00b5a
F00b5c:
	or.b	d0,(a0)	; 00b5c
	or.b	d0,$28(a0)	; 00b5e
	and.b	d1,$50(a0)	; 00b62
	or.b	d0,$78(a0)	; 00b66
	or.b	d0,$a0(a0)	; 00b6a
	rts		; 00b6e
F00b70:
	and.b	d1,(a0)	; 00b70
	and.b	d1,$28(a0)	; 00b72
	or.b	d0,$50(a0)	; 00b76
	or.b	d0,$78(a0)	; 00b7a
	or.b	d0,$a0(a0)	; 00b7e
	rts		; 00b82
F00b84:
	or.b	d0,(a0)	; 00b84
	and.b	d1,$28(a0)	; 00b86
	or.b	d0,$50(a0)	; 00b8a
	or.b	d0,$78(a0)	; 00b8e
	or.b	d0,$a0(a0)	; 00b92
	rts		; 00b96
F00b98:
	and.b	d1,(a0)	; 00b98
	or.b	d0,$28(a0)	; 00b9a
	or.b	d0,$50(a0)	; 00b9e
	or.b	d0,$78(a0)	; 00ba2
	or.b	d0,$a0(a0)	; 00ba6
	rts		; 00baa
F00bac:
	or.b	d0,(a0)	; 00bac
	or.b	d0,$28(a0)	; 00bae
	or.b	d0,$50(a0)	; 00bb2
	or.b	d0,$78(a0)	; 00bb6
	or.b	d0,$a0(a0)	; 00bba
	rts		; 00bbe
F00bc0:
	jsr	Fantasy_draw_lower
	bne.s	*+4
	rts
	lea.l	Intro_custom,a6
F00bc6:
	btst	#$e,(Intro_custom+$002).l	; 00bc6
	bne.b	F00bc6	; 00bce
	movea.l	(Fant_h2+$ec).l,a0	; 00bd0
	lea.l	$68b0(a0),a0	; 00bd6
	move.l	a0,$54(a6)	; 00bda
	move.w	#$0,$66(a6)	; 00bde
	move.l	#Fant_h1+$13c3c,$50(a6)	; 00be4
	move.w	#$0,$64(a6)	; 00bec
	move.l	#$ffffffff,$44(a6)	; 00bf2
	move.l	#$9f00000,$40(a6)	; 00bfa
	move.w	#$9894,$58(a6)	; 00c02
	jsr	Intro_blit
	rts		; 00c08
F00c0a:
	move.l	(Fant_h2+$f0).l,d0	; 00c0a
	move.l	(Fant_h2+$f4).l,(Fant_h2+$f0).l	; 00c10
	move.l	d0,(Fant_h2+$f4).l	; 00c1a
	move.l	(Fant_h2+$f0).l,(Fant_h2+$ec).l	; 00c20
	rts		; 00c2a
F00c2c:
	move.l	#Fant_h3+$320,d0	; 00c2c
	move.l	d0,(Fant_h2+$f0).l	; 00c32
	move.l	d0,(Fant_h2+$ec).l	; 00c38
	addi.l	#$c800,d0	; 00c3e
	move.l	d0,(Fant_h2+$f4).l	; 00c44
	move.l	#Fant_h3+$0,(Fant_h2+$a4).l	; 00c4a
	move.l	#Fant_h3+$190,(Fant_h2+$a8).l	; 00c54
	bsr.w	F00c98	; 00c5e
	bsr.w	F0101a	; 00c62
	move.w	#$48,(Fant_h2+$ac).l	; 00c66
	move.w	#$48,(Fant_h2+$ae).l	; 00c6e
	move.w	#$0,(Fant_h2+$b0).l	; 00c76
	move.w	#$0,(Fant_h2+$b2).l	; 00c7e
	move.w	#$8f,(Fant_h2+$b4).l	; 00c86
	move.w	#$8f,(Fant_h2+$b6).l	; 00c8e
	rts		; 00c96
F00c98:
F00cb0:
F00cdc:
F00cee:
	jsr	Fantasy_present
	rts
F00d12:
	dc.w	$0028	; 00d12
	dc.w	$002a	; 00d14
	dc.w	$002c	; 00d16
	dc.w	$002e	; 00d18
	dc.w	$003a	; 00d1a
	dc.w	$003c	; 00d1c
	dc.w	$003e	; 00d1e
	dc.w	$ffff	; 00d20
F00d22:
	jsr	Fantasy_init
	rts
F00d84:
	dc.w	$ffff	; 00d84
	dc.w	$fffe	; 00d86
F00d88:
	addq.l	#$1,(Fant_h2+$a0).l	; 00d88
	movem.l	d0-d7/a0-a6,-(a7)	; 00d8e
	jsr	Intro_buttons
	lea.l	Intro_custom,a6	; 00d92
	movem.l	(Fant_h2+$20).l,d0-d7	; 00d98
	movem.l	d0-d7,(Intro_custom+$180).l	; 00da0
	movem.l	(Fant_h2+$40).l,d0-d7	; 00da8
	movem.l	d0-d7,(Intro_custom+$1a0).l	; 00db0
	jsr	Fantasy_palette
	tst.w	(Fant_h2+$d0).l	; 00db8
	beq.w	F00ff8	; 00dbe
	tst.w	(Fant_h2+$c4).l	; 00dc2
	bne.b	F00e16	; 00dc8
	movea.l	(Fant_h2+$b8).l,a0	; 00dca
	move.w	(a0)+,d0	; 00dd0
	move.w	(a0)+,d1	; 00dd2
	cmpi.w	#$3039,(a0)	; 00dd4
	bne.b	F00e04	; 00dd8
	tst.w	$2(a0)	; 00dda
	bpl.b	F00df2	; 00dde
	tst.w	(Fant_h2+$d6).l	; 00de0
	bne.b	F00e16	; 00de6
	move.w	#$85,(Fant_h2+$d6).l	; 00de8
	bra.b	F00e16	; 00df0
F00df2:
	move.w	#$ffff,(Fant_h2+$c4).l	; 00df2
	move.w	#$ffff,(Fant_h2+$c6).l	; 00dfa
	addq.l	#$4,a0	; 00e02
F00e04:
	move.l	a0,(Fant_h2+$b8).l	; 00e04
	move.w	d0,(Fant_h2+$c8).l	; 00e0a
	move.w	d1,(Fant_h2+$ca).l	; 00e10
F00e16:
	lea.l	(Fant_h1+$1ac).l,a0	; 00e16
	st	Fantasy_visible
	move.w	(Fant_h2+$bc).l,d2	; 00e1c
	mulu.w	#$920,d2	; 00e22
	adda.l	d2,a0	; 00e26
	move.w	(Fant_h2+$c8).l,d0	; 00e28
	move.w	(Fant_h2+$ca).l,d1	; 00e2e
	addi.w	#$80,d0	; 00e34
	addi.w	#$28,d1	; 00e38
	move.w	d1,d2	; 00e3c
	addi.w	#$47,d2	; 00e3e
	rol.w	#$7,d2	; 00e42
	lsl.w	#$8,d1	; 00e44
	addx.w	d2,d2	; 00e46
	addx.b	d2,d2	; 00e48
	lsr.w	#$1,d0	; 00e4a
	addx.b	d2,d2	; 00e4c
	ori.b	#$80,d2	; 00e4e
	move.b	d0,d1	; 00e52
	lea.l	(Intro_custom+$120).l,a1	; 00e54
	moveq	#$3,d7	; 00e5a
F00e5c:
	move.l	a0,(a1)+	; 00e5c
	move.w	d1,(a0)	; 00e5e
	move.w	d2,$2(a0)	; 00e60
	adda.w	#$124,a0	; 00e64
	move.l	a0,(a1)+	; 00e68
	move.w	d1,(a0)	; 00e6a
	move.w	d2,$2(a0)	; 00e6c
	addq.w	#$8,d1	; 00e70
	adda.w	#$124,a0	; 00e72
	dbra	d7,F00e5c	; 00e76
	subq.w	#$1,(Fant_h2+$be).l	; 00e7a
	bpl.b	F00ee8	; 00e80
	addq.w	#$3,(Fant_h2+$be).l	; 00e82
	addq.w	#$1,(Fant_h2+$bc).l	; 00e88
	tst.w	(Fant_h2+$c4).l	; 00e8e
	bpl.b	F00ebe	; 00e94
	tst.w	(Fant_h2+$c6).l	; 00e96
	bmi.b	F00ea4	; 00e9c
	addq.w	#$4,(Fant_h2+$c6).l	; 00e9e
F00ea4:
	cmpi.w	#$3,(Fant_h2+$bc).l	; 00ea4
	bne.b	F00ebe	; 00eac
	move.w	#$4,(Fant_h2+$bc).l	; 00eae
	clr.w	(Fant_h2+$c6).l	; 00eb6
	bra.b	F00ee8	; 00ebc
F00ebe:
	cmpi.w	#$4,(Fant_h2+$bc).l	; 00ebe
	beq.b	F00ee2	; 00ec6
	cmpi.w	#$17,(Fant_h2+$bc).l	; 00ec8
	bne.b	F00ee8	; 00ed0
	move.w	#$1,(Fant_h2+$c4).l	; 00ed2
	move.w	#$ff92,(Fant_h2+$c0).l	; 00eda
F00ee2:
	clr.w	(Fant_h2+$bc).l	; 00ee2
F00ee8:
	subq.w	#$1,(Fant_h2+$cc).l	; 00ee8
	bpl.b	F00f1e	; 00eee
	move.w	(Fant_h2+$ce).l,d0	; 00ef0
	tst.w	(Fant_h2+$c4).l	; 00ef6
	beq.b	F00f00	; 00efc
	lsl.w	#$4,d0	; 00efe
F00f00:
	add.w	d0,(Fant_h2+$cc).l	; 00f00
	move.w	(Fant_h2+$c8).l,d0	; 00f06
	addi.w	#$13,d0	; 00f0c
	move.w	(Fant_h2+$ca).l,d1	; 00f10
	addi.w	#$11,d1	; 00f16
	bsr.w	F0054c	; 00f1a
F00f1e:
	tst.w	(Fant_h2+$c4).l	; 00f1e
	bpl.b	F00f72	; 00f24
	move.w	(Fant_h2+$c6).l,d4	; 00f26
	bmi.b	F00f72	; 00f2c
	tst.w	(Fant_h2+$be).l	; 00f2e
	bne.b	F00f72	; 00f34
	lea.l	(F01188).l,a5	; 00f36
	move.w	(a5,d4.w),d0	; 00f3c
	move.w	$2(a5,d4.w),d1	; 00f40
	add.w	(Fant_h2+$c8).l,d0	; 00f44
	add.w	(Fant_h2+$ca).l,d1	; 00f4a
	subi.w	#$7d,d0	; 00f50
	subi.w	#$46,d1	; 00f54
	cmpi.w	#$10,(Fant_h2+$bc).l	; 00f58
	bne.b	F00f6e	; 00f60
	move.w	d0,(Fant_h2+$d2).l	; 00f62
	move.w	d1,(Fant_h2+$d4).l	; 00f68
F00f6e:
	bsr.w	F0054c	; 00f6e
F00f72:
	move.w	(Fant_h2+$d2).l,d2	; 00f72
	bmi.b	F00fc4	; 00f78
	move.w	(Fant_h2+$d4).l,d3	; 00f7a
	moveq	#$5,d7	; 00f80
F00f82:
	bsr.w	F005a2	; 00f82
	move.w	d0,d1	; 00f86
	lsr.w	#$4,d1	; 00f88
	andi.w	#$f,d0	; 00f8a
	andi.w	#$f,d1	; 00f8e
	add.w	d2,d0	; 00f92
	add.w	d3,d1	; 00f94
	movem.w	d2-d3/d7,-(a7)	; 00f96
	bsr.w	F0054c	; 00f9a
	movem.w	(a7)+,d2-d3/d7	; 00f9e
	dbra	d7,F00f82	; 00fa2
	addq.w	#$6,(Fant_h2+$d2).l	; 00fa6
	addq.w	#$1,(Fant_h2+$d4).l	; 00fac
	cmpi.w	#$a0,(Fant_h2+$d2).l	; 00fb2
	blt.b	F00fc4	; 00fba
	move.w	#$ffff,(Fant_h2+$d2).l	; 00fbc
F00fc4:
	cmpi.w	#$ffff,(Fant_h2+$c0).l	; 00fc4
	bge.b	F00fe6	; 00fcc
	addq.w	#$1,(Fant_h2+$c0).l	; 00fce
	cmpi.w	#$ffff,(Fant_h2+$c0).l	; 00fd4
	bne.b	F00fe6	; 00fdc
	move.w	#$3c,(Fant_h2+$c0).l	; 00fde
F00fe6:
	jsr	Fantasy_vbl
	movem.l	(a7)+,d0-d7/a0-a6
	move.w	#$20,(Intro_custom+$09c).l	; 00fea
	nop		; 00ff2
	nop		; 00ff4
	rts
F00ff8:
	lea.l	(Intro_custom+$120).l,a0	; 00ff8
	moveq	#$7,d7	; 00ffe
	lea.l	(Fant_h1+$1da06).l,a1	; 01000
F01006:
	move.l	a1,(a0)+	; 01006
	dbra	d7,F01006	; 01008
	jsr	Fantasy_vbl
	movem.l	(a7)+,d0-d7/a0-a6
	move.w	#$20,(Intro_custom+$09c).l	; 01010
	rts
F0101a:
	move.l	(Fant_h2+$a0).l,d0	; 0101a
F01020:
	cmp.l	(Fant_h2+$a0).l,d0	; 01020
	beq.b	F01020	; 01026
	rts		; 01028
F0102a:
	lea.l	Intro_custom,a6	; 0102a
	move.w	#$2881,$8e(a6)	; 01030
	addi.b	#$28,d0	; 01036
	lsl.w	#$8,d0	; 0103a
	ori.w	#$c1,d0	; 0103c
	move.w	d0,$90(a6)	; 01040
	move.l	#$3800d0,$92(a6)	; 01044
	move.w	d1,d0	; 0104c
	ror.w	#$4,d0	; 0104e
	ori.w	#$200,d0	; 01050
	move.w	d0,$100(a6)	; 01054
	subq.w	#$1,d1	; 01058
	mulu.w	#$28,d1	; 0105a
	move.w	d1,$108(a6)	; 0105e
	move.w	d1,$10a(a6)	; 01062
	move.w	#$0,$102(a6)	; 01066
	rts		; 0106c
	dc.w	$4df9	; 0106e
	dc.w	$00df	; 01070
	dc.w	$f000	; 01072
	dc.w	$343c	; 01074
	dc.w	$000f	; 01076
	dc.w	$082e	; 01078
	dc.w	$0001	; 0107a
	dc.w	$000d	; 0107c
	dc.w	$6604	; 0107e
	dc.w	$0882	; 01080
	dc.w	$0001	; 01082
	dc.w	$082e	; 01084
	dc.w	$0001	; 01086
	dc.w	$000c	; 01088
	dc.w	$6604	; 0108a
	dc.w	$0882	; 0108c
	dc.w	$0000	; 0108e
	dc.w	$102e	; 01090
	dc.w	$000d	; 01092
	dc.w	$1200	; 01094
	dc.w	$0200	; 01096
	dc.w	$0001	; 01098
	dc.w	$0201	; 0109a
	dc.w	$0002	; 0109c
	dc.w	$e209	; 0109e
	dc.w	$b101	; 010a0
	dc.w	$6604	; 010a2
	dc.w	$0882	; 010a4
	dc.w	$0003	; 010a6
	dc.w	$102e	; 010a8
	dc.w	$000c	; 010aa
	dc.w	$1200	; 010ac
	dc.w	$0200	; 010ae
	dc.w	$0001	; 010b0
	dc.w	$0201	; 010b2
	dc.w	$0002	; 010b4
	dc.w	$e209	; 010b6
	dc.w	$b101	; 010b8
	dc.w	$6604	; 010ba
	dc.w	$0882	; 010bc
	dc.w	$0002	; 010be
	dc.w	$1039	; 010c0
	dc.w	$00bf	; 010c2
	dc.w	$e001	; 010c4
	dc.w	$4640	; 010c6
	dc.w	$0240	; 010c8
	dc.w	$0080	; 010ca
	dc.w	$8440	; 010cc
	dc.w	$4e75	; 010ce
F010d0:
	subq.w	#$1,d7	; 010d0
F010d2:
	move.w	(a0)+,d0	; 010d2
	move.w	d0,d1	; 010d4
	move.w	d0,d2	; 010d6
	andi.w	#$f00,d0	; 010d8
	andi.w	#$f0,d1	; 010dc
	andi.w	#$f,d2	; 010e0
	move.w	(a1),d3	; 010e4
	move.w	d3,d4	; 010e6
	move.w	d3,d5	; 010e8
	andi.w	#$f00,d3	; 010ea
	andi.w	#$f0,d4	; 010ee
	andi.w	#$f,d5	; 010f2
	cmp.w	d0,d3	; 010f6
	bge.b	F010fe	; 010f8
	addi.w	#$100,d3	; 010fa
F010fe:
	cmp.w	d1,d4	; 010fe
	bge.b	F01106	; 01100
	addi.w	#$10,d4	; 01102
F01106:
	cmp.w	d2,d5	; 01106
	bge.b	F0110c	; 01108
	addq.w	#$1,d5	; 0110a
F0110c:
	or.w	d4,d3	; 0110c
	or.w	d5,d3	; 0110e
	move.w	d3,(a1)+	; 01110
	dbra	d7,F010d2	; 01112
	rts		; 01116
F01118:
	subq.w	#$1,d7	; 01118
F0111a:
	move.w	(a0),d0	; 0111a
	move.w	d0,d1	; 0111c
	move.w	d0,d2	; 0111e
	move.w	d0,d3	; 01120
	andi.w	#$f00,d0	; 01122
	beq.b	F0112c	; 01126
	subi.w	#$100,d3	; 01128
F0112c:
	andi.w	#$f0,d1	; 0112c
	beq.b	F01136	; 01130
	subi.w	#$10,d3	; 01132
F01136:
	andi.w	#$f,d2	; 01136
	beq.b	F01140	; 0113a
	subi.w	#$1,d3	; 0113c
F01140:
	move.w	d3,(a0)+	; 01140
	dbra	d7,F0111a	; 01142
	rts		; 01146
	dc.w	$ffff	; 01148
	dc.w	$7fff	; 0114a
	dc.w	$3fff	; 0114c
	dc.w	$1fff	; 0114e
	dc.w	$0fff	; 01150
	dc.w	$07ff	; 01152
	dc.w	$03ff	; 01154
	dc.w	$01ff	; 01156
	dc.w	$00ff	; 01158
	dc.w	$007f	; 0115a
	dc.w	$003f	; 0115c
	dc.w	$001f	; 0115e
	dc.w	$000f	; 01160
	dc.w	$0007	; 01162
	dc.w	$0003	; 01164
	dc.w	$0001	; 01166
	dc.w	$8000	; 01168
	dc.w	$c000	; 0116a
	dc.w	$e000	; 0116c
	dc.w	$f000	; 0116e
	dc.w	$f800	; 01170
	dc.w	$fc00	; 01172
	dc.w	$fe00	; 01174
	dc.w	$ff00	; 01176
	dc.w	$ff80	; 01178
	dc.w	$ffc0	; 0117a
	dc.w	$ffe0	; 0117c
	dc.w	$fff0	; 0117e
	dc.w	$fff8	; 01180
	dc.w	$fffc	; 01182
	dc.w	$fffe	; 01184
	dc.w	$ffff	; 01186
F01188:
	dc.w	$00a3	; 01188
	dc.w	$0053	; 0118a
	dc.w	$00a5	; 0118c
	dc.w	$0054	; 0118e
	dc.w	$00a6	; 01190
	dc.w	$0053	; 01192
	dc.w	$00a8	; 01194
	dc.w	$0054	; 01196
	dc.w	$00aa	; 01198
	dc.w	$0056	; 0119a
	dc.w	$00a6	; 0119c
	dc.w	$0053	; 0119e
	dc.w	$00a4	; 011a0
	dc.w	$0054	; 011a2
	dc.w	$00a2	; 011a4
	dc.w	$0054	; 011a6
	dc.w	$00a3	; 011a8
	dc.w	$0057	; 011aa
	dc.w	$00a9	; 011ac
	dc.w	$0056	; 011ae
	dc.w	$00b2	; 011b0
	dc.w	$005c	; 011b2
	dc.w	$00b5	; 011b4
	dc.w	$0062	; 011b6
	dc.w	$00b7	; 011b8
	dc.w	$0067	; 011ba
	dc.w	$00b7	; 011bc
	dc.w	$006a	; 011be
	dc.w	$00b7	; 011c0
	dc.w	$006b	; 011c2
	dc.w	$00b4	; 011c4
	dc.w	$0064	; 011c6
	dc.w	$00b3	; 011c8
	dc.w	$0063	; 011ca
	dc.w	$00af	; 011cc
	dc.w	$005d	; 011ce
	dc.w	$00aa	; 011d0
	dc.w	$0058	; 011d2
	dc.w	$2079	; 011d4
	dc.l	Fant_h2+$f4	; 011d6
	dc.w	$3e3c	; 011da
	dc.w	$1f3f	; 011dc
	dc.w	$70ff	; 011de
	dc.w	$20c0	; 011e0
	dc.w	$51cf	; 011e2
	dc.w	$fffc	; 011e4
	dc.w	$4e75	; 011e6

; The data (loaded from the file Fantasy_data) and the BSS : in the memory of
; the intro (INTRO_COMMON.S), before the intro
Fant_h1	EQU	Intro_area
Fant_h1_end	EQU	Fant_h1+Fant_h1_size
Fant_h2	EQU	Intro_area+((Fantasy_data_size+3)&-4)
Fant_h3	EQU	Fant_h2+$2224
Star_cache	EQU	Fant_h3+$19320		; (AMIGA_BLIT.S, INTRO.S : it fits)

	SECTION	Program,code
