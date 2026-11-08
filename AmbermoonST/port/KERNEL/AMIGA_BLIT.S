; ST kernel : the blitter of the Amiga, in software
;
; For the programs of the intro (INTRO.S, FANTASY.S and the extro of the
; Falcon), which use the blitter of the Amiga : its registers are memory
; ([ Intro_custom ], at their offsets), a blit is done when BLTSIZE was
; written ([ Intro_blit ], the call is put in by port/tools/patchlib.py).
; With the blitter of the STE ([ Bl_hardware ], set by the ST : INTRO_HW.S)
; the usual blits are done by it ([ Hardware_blit ]) : clearing, copying and
; the cookie cut of graphics with their mask.

	SECTION	Program,code

;*****************************************************************************
; [ Do a blit ] (BLTSIZE of the Amiga)
; All registers are restored
; NOTE :
;   - The registers of the blitter are in [ Intro_custom ], at their offsets.
;     After the blit the pointers are behind the data, like on the Amiga (the
;     code goes on with them).
;*****************************************************************************
Blt_con0	EQU	$40
Blt_con1	EQU	$42
Blt_afwm	EQU	$44
Blt_alwm	EQU	$46
Blt_cpt	EQU	$48
Blt_bpt	EQU	$4c
Blt_apt	EQU	$50
Blt_dpt	EQU	$54
Blt_size	EQU	$58
Blt_cmod	EQU	$60
Blt_bmod	EQU	$62
Blt_amod	EQU	$64
Blt_dmod	EQU	$66
Blt_cdat	EQU	$70
Blt_bdat	EQU	$72
Blt_adat	EQU	$74

Star_slots	EQU	256		; The sparkles of the fairy (a slot : 512
Star_rows	EQU	46		;  bytes, 18 + 10 for each line with A)

Intro_blit:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Intro_custom,a6
	andi.w	#$fffe,Blt_apt+2(a6)	; (the blitter has even addresses only)
	andi.w	#$fffe,Blt_bpt+2(a6)
	andi.w	#$fffe,Blt_cpt+2(a6)
	andi.w	#$fffe,Blt_dpt+2(a6)
	move.w	Blt_size(a6),d0		; Size
	moveq.l	#63,d6
	and.w	d0,d6
	bne.s	.Width
	moveq.l	#64,d6
.Width:	lsr.w	#6,d0
	bne.s	.Height
	move.w	#1024,d0
.Height:	move.w	d0,Bl_height
	subq.w	#1,d6
	move.w	Blt_con0(a6),d0		; Function
	jsr	Intro_blit_fast		; (the usual cases)
	beq	.Exit
	move.w	Blt_size(a6),d6		; (again : changed by the fast way)
	andi.w	#63,d6
	bne.s	.Width2
	moveq.l	#64,d6
.Width2:	subq.w	#1,d6
	move.w	Blt_con0(a6),d0
	moveq.l	#0,d1
	move.b	d0,d1
	lea.l	Bl_generic,a5		; (d1 : minterms for the generic one)
	lea.l	.Functions(pc),a0
.Find:	move.w	(a0)+,d2
	bmi.s	.Found
	cmp.w	d1,d2
	beq.s	.Known
	addq.l	#4,a0
	bra.s	.Find
.Known:	move.l	(a0),a5
.Found:	move.w	d1,Bl_minterms
	move.w	d0,d1			; Shift of A & B
	rol.w	#4,d1
	andi.w	#15,d1
	move.w	d1,Bl_sa
	move.w	Blt_con1(a6),d1
	rol.w	#4,d1
	andi.w	#15,d1
	move.w	d1,Bl_sb
	moveq.l	#2,d1			; Direction
	btst.b	#1,Blt_con1+1(a6)
	sne	Bl_desc
	beq.s	.Up
	moveq.l	#-2,d1
.Up:	move.w	d1,Bl_step
	move.l	Blt_apt(a6),a0		; Channels
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	Blt_dpt(a6),a3
	move.w	d0,Bl_con0
	moveq.l	#0,d3			; (previous A & B)
	moveq.l	#0,d4
; ---------- Lines -------------------------------
.Line:	move.w	d6,d5
	st	Bl_first
.Word:	move.w	Bl_con0,d7
; ---------- A -----------------------------------
	btst	#11,d7
	beq.s	.No_A
	move.w	(a0),d0
	add.w	Bl_step,a0
	bra.s	.Have_A
.No_A:	move.w	Blt_adat(a6),d0
.Have_A:	tst.b	Bl_first
	beq.s	.A_last
	and.w	Blt_afwm(a6),d0
.A_last:	tst.w	d5
	bne.s	.A_mid
	and.w	Blt_alwm(a6),d0
.A_mid:	move.w	Bl_sa,d1
	tst.b	Bl_desc
	bne.s	.A_desc
	swap	d3			; Old : high word
	move.w	d0,d3
	move.l	d3,d0
	lsr.l	d1,d0
	bra.s	.B
.A_desc:	move.w	d0,d2			; New : high word, old : low word
	swap	d0
	move.w	d3,d0
	lsl.l	d1,d0
	swap	d0
	move.w	d2,d3
; ---------- B -----------------------------------
.B:	btst	#10,d7
	beq.s	.No_B
	move.w	(a1),d1
	add.w	Bl_step,a1
	bra.s	.Have_B
.No_B:	move.w	Blt_bdat(a6),d1
.Have_B:	move.w	Bl_sb,d2
	beq.s	.C_0
	tst.b	Bl_desc
	bne.s	.B_desc
	swap	d4
	move.w	d1,d4
	move.l	d4,d1
	lsr.l	d2,d1
	bra.s	.C
.B_desc:	move.w	d1,-(sp)
	swap	d1
	move.w	d4,d1
	lsl.l	d2,d1
	swap	d1
	move.w	(sp)+,d4
	bra.s	.C
.C_0:
; ---------- C -----------------------------------
.C:	btst	#9,d7
	beq.s	.No_C
	move.w	(a2),d2
	add.w	Bl_step,a2
	bra.s	.Have_C
.No_C:	move.w	Blt_cdat(a6),d2
.Have_C:	jsr	(a5)			; d0 = function(d0, d1, d2)
	btst	#8,d7			; D
	beq.s	.No_D
	move.w	d0,(a3)
	add.w	Bl_step,a3
.No_D:	sf	Bl_first
	dbra	d5,.Word
; ---------- Next line ---------------------------
	move.w	Bl_con0,d7
	tst.b	Bl_desc
	bne.s	.Mod_desc
	btst	#11,d7
	beq.s	.M1
	add.w	Blt_amod(a6),a0
.M1:	btst	#10,d7
	beq.s	.M2
	add.w	Blt_bmod(a6),a1
.M2:	btst	#9,d7
	beq.s	.M3
	add.w	Blt_cmod(a6),a2
.M3:	btst	#8,d7
	beq.s	.Next
	add.w	Blt_dmod(a6),a3
	bra.s	.Next
.Mod_desc:	btst	#11,d7
	beq.s	.M4
	sub.w	Blt_amod(a6),a0
.M4:	btst	#10,d7
	beq.s	.M5
	sub.w	Blt_bmod(a6),a1
.M5:	btst	#9,d7
	beq.s	.M6
	sub.w	Blt_cmod(a6),a2
.M6:	btst	#8,d7
	beq.s	.Next
	sub.w	Blt_dmod(a6),a3
.Next:	subq.w	#1,Bl_height
	bne	.Line
	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a3,Blt_dpt(a6)
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

.Functions:
	dc.w	$f0
	dc.l	Bl_f0
	dc.w	$ca
	dc.l	Bl_ca
	dc.w	$e2
	dc.l	Bl_e2
	dc.w	$fc
	dc.l	Bl_fc
	dc.w	$fe
	dc.l	Bl_fe
	dc.w	$fa
	dc.l	Bl_fa
	dc.w	$0a
	dc.l	Bl_0a
	dc.w	$00
	dc.l	Bl_00
	dc.w	-1

;*****************************************************************************
; [ The usual blits, fast ]
;   IN : d0 - BLTCON0 (.w)
;        d6 - Width in words - 1 (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
;        [ Bl_height ]
;  OUT : Z set if the blit was done
; Changed registers : d0-d7, a0-a5
; NOTE :
;   - A copy (A to D, no shift, ascending, no masks), and one word wide with
;     all channels (the columns of the zoom : each word is one line in a plane).
;*****************************************************************************
Intro_blit_fast:
	cmp.w	#$0100,d0			; Clear ?
	bne.s	.No_clear
	tst.w	Blt_con1(a6)
	bne	.No
	tst.b	Bl_hardware
	bne	Hardware_clear
	move.l	Blt_dpt(a6),a3
	move.w	Blt_dmod(a6),a2
	move.w	Bl_height,d7
	subq.w	#1,d7
	moveq.l	#0,d0
.Cl_line:	move.w	d6,d5
.Cl_word:	move.w	d0,(a3)+
	dbra	d5,.Cl_word
	add.w	a2,a3
	dbra	d7,.Cl_line
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.No_clear:	move.w	d0,d1			; Cookie cut, ascending, wider than
	andi.w	#$00ff,d1			;  one word
	cmp.w	#$ca,d1
	bne.s	.No_cookie
	tst.w	d6
	beq.s	.No_cookie
	move.w	d0,d1
	andi.w	#$0f00,d1
	cmp.w	#$0f00,d1			; (A, B, C, D or B, C, D)
	beq.s	.Cookie
	cmp.w	#$0700,d1
	bne.s	.No_cookie
.Cookie:	jmp	Intro_blit_cookie
.No_cookie:
	cmp.w	#$09f0,d0			; Copy ?
	bne	.Column
	cmp.l	#-1,Blt_afwm(a6)
	bne	.No
	tst.w	Blt_con1(a6)
	bne	.No
	move.l	Blt_apt(a6),a0
	move.l	Blt_dpt(a6),a3
	move.w	Blt_amod(a6),a1
	move.w	Blt_dmod(a6),a2
	move.w	Bl_height,d7
	tst.b	Bl_hardware		; (the blitter of the STE : not for small
	beq.s	.Cpu			;  ones, it takes some time to start)
	move.w	d6,d0
	addq.w	#1,d0
	mulu.w	d7,d0
	cmp.l	#64,d0
	bcc	Hardware_copy
.Cpu:
	move.w	a1,d0			; In one piece ? (e.g. the background
	or.w	Blt_dmod(a6),d0		;  of the lettering of the fairy : every
	beq.s	.Piece			;  frame)
	subq.w	#1,d7
.Copy:	move.w	d6,d5
.Word:	move.w	(a0)+,(a3)+
	dbra	d5,.Word
	add.w	a1,a0
	add.w	a2,a3
	dbra	d7,.Copy
	move.l	a0,Blt_apt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.Piece:	addq.w	#1,d6			; Words
	mulu.w	d6,d7
	move.l	a6,-(sp)
.Block:	cmp.l	#24,d7			; 48 bytes at once
	blt.s	.Rest
	movem.l	(a0)+,d0-d6/a1/a2/a4-a6
	movem.l	d0-d6/a1/a2/a4-a6,(a3)
	lea.l	48(a3),a3
	sub.l	#24,d7
	bra.s	.Block
.Rest:	subq.w	#1,d7
	bmi.s	.Whole
.Word2:	move.w	(a0)+,(a3)+
	dbra	d7,.Word2
.Whole:	move.l	(sp)+,a6
	move.l	a0,Blt_apt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.No:	moveq.l	#1,d0
	rts
.Column:	tst.w	d6			; One word wide ?
	bne.s	.No
	move.w	d0,d1			; Shift
	rol.w	#4,d1
	andi.w	#15,d1
	move.w	Blt_afwm(a6),d5		; Mask
	and.w	Blt_alwm(a6),d5
	moveq.l	#0,d3			; (previous A & B)
	moveq.l	#0,d4
	move.w	Bl_height,d7
	subq.w	#1,d7
	move.l	Blt_apt(a6),a0
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	Blt_dpt(a6),a3
	move.w	Blt_amod(a6),a4
	move.w	Blt_cmod(a6),a5
	move.w	Blt_con1(a6),d2
	btst	#1,d2
	bne	.Down
; ---------- Ascending ----------------------------
	addq.w	#2,a4
	addq.w	#2,a5
	andi.w	#$0fff,d0			; (d2 : BLTCON1 : shift B = shift A)
	cmp.w	#$0fca,d0
	bne.s	.Be2
	lsr.w	#8,d2
	lsr.w	#4,d2
	cmp.w	d1,d2
	bne	.No
	move.w	Blt_bmod(a6),d6		; (the steps in registers, in the loop)
	addq.w	#2,d6
	move.w	Blt_dmod(a6),d0
	addq.w	#2,d0
	move.w	d0,a6
.Ca:	move.w	(a0),d0			; A : (A & B) | (!A & C)
	add.w	a4,a0
	and.w	d5,d0
	swap	d3
	move.w	d0,d3
	move.l	d3,d0
	lsr.l	d1,d0
	move.w	(a1),d2			; B
	add.w	d6,a1
	swap	d4
	move.w	d2,d4
	move.l	d4,d2
	lsr.l	d1,d2
	and.w	d0,d2
	not.w	d0
	and.w	(a2),d0
	add.w	a5,a2
	or.w	d2,d0
	move.w	d0,(a3)
	add.w	a6,a3
	dbra	d7,.Ca
	lea.l	Intro_custom,a6
	bra.s	.Done
.Be2:	cmp.w	#$0be2,d0
	bne	.No
	bsr	Column_hardware		; (the blitter of the STE ?)
	beq	Hardware_column
	move.w	Blt_bdat(a6),d2		; (A & B) | (!B & C), B : BDAT
	move.w	Blt_dmod(a6),d0
	addq.w	#2,d0
	move.w	d0,a6			; (the step in a register, in the loop)
	move.w	d2,d4
	not.w	d4
.E2:	move.w	(a0),d0
	add.w	a4,a0
	and.w	d5,d0
	swap	d3
	move.w	d0,d3
	move.l	d3,d0
	lsr.l	d1,d0
	and.w	d2,d0
	move.w	(a2),d6
	add.w	a5,a2
	and.w	d4,d6
	or.w	d6,d0
	move.w	d0,(a3)
	add.w	a6,a3
	dbra	d7,.E2
	lea.l	Intro_custom,a6
.Done:	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
; ---------- Descending ---------------------------
.Down:	move.w	#-2,d6			; (step - modulo)
	sub.w	a4,d6
	move.w	d6,a4
	move.w	#-2,d6
	sub.w	a5,d6
	move.w	d6,a5
	move.w	#-2,d6
	sub.w	Blt_dmod(a6),d6
	move.w	d6,Bl_dstep
	andi.w	#$0fff,d0
	cmp.w	#$0fca,d0
	bne.s	.Be2_d
	lsr.w	#8,d2
	lsr.w	#4,d2
	cmp.w	d1,d2
	bne	.No
	move.w	#-2,d6
	sub.w	Blt_bmod(a6),d6
	move.w	d6,Bl_bstep
	move.w	Bl_dstep,a6		; (in a register, in the loop)
.Ca_d:	move.w	(a0),d0			; A
	add.w	a4,a0
	and.w	d5,d0
	move.w	d0,d6
	swap	d0
	move.w	d3,d0
	lsl.l	d1,d0
	swap	d0
	move.w	d6,d3
	move.w	(a1),d2			; B
	add.w	Bl_bstep,a1
	move.w	d2,d6
	swap	d2
	move.w	d4,d2
	lsl.l	d1,d2
	swap	d2
	move.w	d6,d4
	and.w	d0,d2
	not.w	d0
	and.w	(a2),d0
	add.w	a5,a2
	or.w	d2,d0
	move.w	d0,(a3)
	add.w	a6,a3
	dbra	d7,.Ca_d
	lea.l	Intro_custom,a6
	bra	.Done
.Be2_d:	cmp.w	#$0be2,d0
	bne	.No
	tst.w	d1			; (the blitter of the STE : not shifted)
	bne.s	.E2_cpu
	bsr	Column_hardware
	beq	Hardware_column_down
.E2_cpu:	move.w	Blt_bdat(a6),d2
	move.w	d2,d4
	not.w	d4
	move.w	Bl_dstep,a6		; (in a register, in the loop)
.E2_d:	move.w	(a0),d0
	add.w	a4,a0
	and.w	d5,d0
	move.w	d0,d6
	swap	d0
	move.w	d3,d0
	lsl.l	d1,d0
	swap	d0
	move.w	d6,d3
	and.w	d2,d0
	move.w	(a2),d6
	add.w	a5,a2
	and.w	d4,d6
	or.w	d6,d0
	move.w	d0,(a3)
	add.w	a6,a3
	dbra	d7,.E2_d
	lea.l	Intro_custom,a6
	bra	.Done

;*****************************************************************************
; [ Cookie cut blit, fast ]
;   IN : d0 - BLTCON0 (.w)
;        d6 - Width in words - 1 (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
;  OUT : Z set if the blit was done
; Changed registers : d0-d7, a0-a5
;*****************************************************************************
Intro_blit_cookie:
	move.w	Blt_con1(a6),d1
	btst	#1,d1			; Descending : the slow way
	bne	.No
	lsr.w	#8,d1			; Shift of B
	lsr.w	#4,d1
	move.w	d0,d2			; Shift of A
	rol.w	#4,d2
	andi.w	#15,d2
	cmp.w	d1,d2			; (the same : one shift below)
	beq.s	.Go
	btst	#11,d0			; (the mask of A only without A)
	bne	.No
	bra.s	.General
.Go:	cmp.w	#1,d6			; Two words, A only in the first one,
	bne.s	.General			;  C = D ? (the sparkles of the fairy)
	btst	#11,d0
	beq.s	.General
	cmp.l	#$ffff0000,Blt_afwm(a6)
	bne.s	.General
	move.l	Blt_cpt(a6),d3
	cmp.l	Blt_dpt(a6),d3
	bne.s	.General
	move.w	Blt_cmod(a6),d3
	cmp.w	Blt_dmod(a6),d3
	bne.s	.General
	tst.w	Blt_bmod(a6)
	beq	.Two
.General:	btst	#11,d0			; With A (then the shifts are the
	bne	.Fast			;  same) : the fast way
	move.w	d1,Bl_sb
	move.w	d2,Bl_sa
	move.w	d0,Bl_con0
	move.l	Blt_apt(a6),a0
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	Blt_dpt(a6),a3
	move.w	Blt_bmod(a6),a4
	move.w	Blt_cmod(a6),a5
	moveq.l	#0,d3			; (previous A & B)
	moveq.l	#0,d4
	move.w	Bl_height,d7
	subq.w	#1,d7
.Line:	move.w	d6,d5
	move.w	Blt_afwm(a6),d1		; The first word : its mask
	bra.s	.First
.Word:	moveq.l	#-1,d1
.First:	tst.w	d5
	bne.s	.Mask
	and.w	Blt_alwm(a6),d1
.Mask:	btst	#3,Bl_con0		; A
	beq.s	.No_A
	move.w	(a0)+,d0
	bra.s	.Have_A
.No_A:	move.w	Blt_adat(a6),d0
.Have_A:	and.w	d1,d0
	swap	d3
	move.w	d0,d3
	move.l	d3,d0
	move.w	Bl_sa,d1
	lsr.l	d1,d0
	move.w	(a1)+,d2			; B
	swap	d4
	move.w	d2,d4
	move.l	d4,d2
	move.w	Bl_sb,d1
	lsr.l	d1,d2
	and.w	d0,d2			; (A & B) | (!A & C)
	not.w	d0
	and.w	(a2)+,d0
	or.w	d2,d0
	move.w	d0,(a3)+
	dbra	d5,.Word
	btst	#3,Bl_con0
	beq.s	.No_mod
	add.w	Blt_amod(a6),a0
.No_mod:	add.w	a4,a1
	add.w	a5,a2
	add.w	Blt_dmod(a6),a3
	dbra	d7,.Line
	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.No:	moveq.l	#1,d0
	rts
; With A, the same shift for A and B (d1) : the first and the last word of a
; line with their masks, the words between without.
Cookie_word	MACRO
	swap	d3			; A (d0, masked)
	move.w	d0,d3
	move.l	d3,d0
	lsr.l	d1,d0
	move.w	(a1)+,d2			; B
	swap	d4
	move.w	d2,d4
	move.l	d4,d2
	lsr.l	d1,d2
	and.w	d0,d2			; (A & B) | (!A & C)
	not.w	d0
	and.w	(a2)+,d0
	or.w	d2,d0
	move.w	d0,(a3)+
	ENDM
.Fast:	tst.b	Bl_hardware		; The blitter of the STE ?
	beq.s	.Software
	cmp.l	#$ffff0000,Blt_afwm(a6)	; (graphics one word wider than their
	bne.s	.Software			;  data, onto C = D)
	move.l	Blt_cpt(a6),d0
	cmp.l	Blt_dpt(a6),d0
	bne.s	.Software
	move.w	Blt_cmod(a6),d0
	cmp.w	Blt_dmod(a6),d0
	beq	Hardware_cookie
.Software:	move.l	Blt_apt(a6),a0
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	Blt_dpt(a6),a3
	move.w	Blt_bmod(a6),a4
	move.w	Blt_cmod(a6),a5
	moveq.l	#0,d3			; (previous A & B)
	moveq.l	#0,d4
	move.w	Bl_height,d7
	subq.w	#1,d7
.F_line:	move.w	(a0)+,d0			; The first word
	and.w	Blt_afwm(a6),d0
	move.w	d6,d5
	beq.s	.F_one
	Cookie_word
	subq.w	#2,d5			; The words between
	bmi.s	.F_last
.F_word:	move.w	(a0)+,d0
	Cookie_word
	dbra	d5,.F_word
.F_last:	move.w	(a0)+,d0			; The last word
	and.w	Blt_alwm(a6),d0
	Cookie_word
	bra.s	.F_next
.F_one:	and.w	Blt_alwm(a6),d0		; (only one word)
	Cookie_word
.F_next:	add.w	Blt_amod(a6),a0
	add.w	a4,a1
	add.w	a5,a2
	add.w	Blt_dmod(a6),a3
	dbra	d7,.F_line
	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a3,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
; Two words : the second word of A is masked, so a line without A stays C.
; (B without modulo : the B before a line is the word before it)
.Two:	move.l	Blt_apt(a6),d3		; From the data of the fairy ?
	cmp.l	#Fant_h1,d3
	bcs.s	.Two_direct
	cmp.l	#Fant_h1_end,d3
	bcc.s	.Two_direct
	cmp.w	#Star_rows,Bl_height
	bhi.s	.Two_direct
	jmp	Intro_star_blit		; Yes -> made once
.Two_direct:	move.w	d2,d5			; (the shift of A and B)
	move.l	Blt_apt(a6),a0
	move.l	Blt_bpt(a6),a1
	move.l	Blt_cpt(a6),a2
	move.l	a1,a5			; (the first line : no B before it)
	move.w	Blt_amod(a6),a4
	addq.w	#4,a4
	move.w	Blt_cmod(a6),a3
	addq.w	#4,a3
	move.w	Bl_height,d7
	subq.w	#1,d7
.T_line:	tst.w	(a0)			; A ?
	bne.s	.T_draw
.T_next:	add.w	a4,a0
	addq.l	#4,a1
	add.w	a3,a2
	dbra	d7,.T_line
	move.l	a0,Blt_apt(a6)
	move.l	a1,Blt_bpt(a6)
	move.l	a2,Blt_cpt(a6)
	move.l	a2,Blt_dpt(a6)
	moveq.l	#0,d0
	rts
.T_draw:	move.w	(a0),d0			; A
	move.w	(a1),d2			; B
	move.w	2(a1),d3
	moveq.l	#0,d4			; (the B before)
	cmpa.l	a5,a1
	beq.s	.T_first
	move.w	-2(a1),d4
.T_first:	swap	d0			; A : the first word high, the
	clr.w	d0			;  second one low
	lsr.l	d5,d0
	move.w	d4,d1			; B : the first word
	swap	d1
	move.w	d2,d1
	lsr.l	d5,d1
	swap	d2			; B : the second word
	move.w	d3,d2
	lsr.l	d5,d2
	move.l	d0,d6			; (A & B) | (!A & C)
	swap	d6
	and.w	d6,d1
	not.w	d6
	and.w	(a2),d6
	or.w	d1,d6
	move.w	d6,(a2)
	and.w	d0,d2
	not.w	d0
	and.w	2(a2),d0
	or.w	d2,d0
	move.w	d0,2(a2)
	bra.s	.T_next

;*****************************************************************************
; [ Cookie cut blit of a sparkle ] (see [ Intro_blit_cookie ], .Two)
;   IN : d2 - Shift of A and B (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
;  OUT : Z set (the blit was done)
; Changed registers : d0-d7, a0-a5
; NOTE :
;   - A and B come from the data of the fairy, which never changes : each
;     sparkle (source, shift, size) is made once into a list of its lines with
;     A, each with the mask and the data of both words (Star_slots, the slot
;     from the source and the shift).
;*****************************************************************************
Intro_star_blit:
	move.l	Blt_apt(a6),d3		; The slot
	move.l	d3,d0
	sub.l	#Fant_h1,d0		; (the sparkles are 180 bytes apart :
	lsl.l	#2,d0			;  45 * 16 for each, with the 16
	add.w	d2,d0			;  shifts behind it)
	andi.l	#Star_slots-1,d0
	lsl.l	#8,d0			; (512 bytes)
	add.l	d0,d0
	lea.l	Star_cache,a2
	add.l	d0,a2
	cmp.l	(a2),d3			; Made already ?
	bne.s	.Make
	move.l	Blt_bpt(a6),d0
	cmp.l	4(a2),d0
	bne.s	.Make
	cmp.w	8(a2),d2
	bne.s	.Make
	move.w	Bl_height,d0
	cmp.w	10(a2),d0
	bne.s	.Make
	move.w	Blt_amod(a6),d0
	cmp.w	12(a2),d0
	bne.s	.Make
	move.w	Blt_cmod(a6),d0
	cmp.w	14(a2),d0
	beq	.Draw
.Make:	move.l	d3,(a2)			; Make the lines
	move.l	Blt_bpt(a6),4(a2)
	move.w	d2,8(a2)
	move.w	Bl_height,10(a2)
	move.w	Blt_amod(a6),12(a2)
	move.w	Blt_cmod(a6),14(a2)
	lea.l	18(a2),a3
	move.l	d3,a0			; A
	move.l	4(a2),a1			; B
	move.w	d2,d5
	moveq.l	#0,d4			; (previous B)
	moveq.l	#0,d6			; (the line in C)
	move.w	12(a2),a4
	addq.w	#4,a4
	move.w	14(a2),a5
	addq.w	#4,a5
	move.w	10(a2),d7
	subq.w	#1,d7
	clr.w	Bl_row
.M_line:	move.w	(a0),d0			; A
	move.w	(a1)+,d2			; B
	move.w	(a1)+,d3
	tst.b	Bl_no_plane4		; (the ST : plane 4 is not shown, the
	beq.s	.M_row			;  rows of the sparkle are the planes)
	addq.w	#1,Bl_row
	cmp.w	#5,Bl_row
	bne.s	.M_row
	clr.w	Bl_row
	bra.s	.M_next
.M_row:	tst.w	d0
	beq.s	.M_next
	swap	d0			; A : the first word high, the
	clr.w	d0			;  second one low
	lsr.l	d5,d0
	move.w	d4,d1			; B : the first word
	swap	d1
	move.w	d2,d1
	lsr.l	d5,d1
	swap	d2			; B : the second word
	move.w	d3,d2
	lsr.l	d5,d2
	move.w	d6,(a3)+			; Line : the offset in C, then for
	swap	d0			;  each word !A and A & B
	and.w	d0,d1
	not.w	d0
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	swap	d0
	and.w	d0,d2
	not.w	d0
	move.w	d0,(a3)+
	move.w	d2,(a3)+
.M_next:	move.w	d3,d4
	add.w	a4,a0
	add.w	a5,d6
	dbra	d7,.M_line
	move.l	a3,d0			; Number of lines
	sub.l	a2,d0
	sub.l	#18,d0
	divu.w	#10,d0
	move.w	d0,16(a2)
.Draw:	move.l	Blt_cpt(a6),a1		; Draw : (C & !A) | (A & B)
	lea.l	16(a2),a0
	move.w	(a0)+,d7
	beq.s	.Done
	subq.w	#1,d7
.D_line:	move.w	(a0)+,d0
	lea.l	0(a1,d0.w),a3
	move.w	(a3),d1
	and.w	(a0)+,d1
	or.w	(a0)+,d1
	move.w	d1,(a3)+
	move.w	(a3),d1
	and.w	(a0)+,d1
	or.w	(a0)+,d1
	move.w	d1,(a3)
	dbra	d7,.D_line
.Done:	move.w	10(a2),d1			; The pointers behind the blit
	move.w	12(a2),d0
	addq.w	#4,d0
	mulu.w	d1,d0
	add.l	d0,Blt_apt(a6)
	moveq.l	#0,d0
	move.w	d1,d0
	lsl.l	#2,d0
	add.l	d0,Blt_bpt(a6)
	move.w	14(a2),d0
	addq.w	#4,d0
	mulu.w	d1,d0
	add.l	d0,Blt_cpt(a6)
	add.l	d0,Blt_dpt(a6)
	moveq.l	#0,d0
	rts

;*****************************************************************************
; [ Blits with the blitter of the STE ]
;   IN : d1 - Shift (.w) ([ Hardware_cookie ])
;        d6 - Width in words - 1 (.w)
;        a6 - Pointer to [ Intro_custom ] (.l)
;        [ Bl_height ]
;  OUT : Z set (the blit was done)
; Changed registers : d0-d7, a0-a5
; NOTE :
;   - The blitter of the STE shifts its source like the one of the Amiga
;     (the word before and the word, to the right), but it has only one
;     source, and the masks are for the destination. So :
;   - The cookie cut (A : the mask, B : the graphic, C = D, the last word of
;     A masked, one word more than the graphic) : D = D & !A, then D = D | B.
;     The last word of a line is not read (NFSR) : its bits come from the
;     word before, the first word only gets the bits of its own word (the
;     masks of the destination).
;   - Copy and clear : one pass.
;   - The blitter is started without HOG : it gives the bus to the CPU now
;     and then, the interrupts (the colours of the lines) come in time.
;*****************************************************************************
STB_registers	EQU	$ffff8a20		; Source X increment, ...

Hardware_cookie:
	move.w	d6,d2			; Words
	addq.w	#1,d2
	move.w	Bl_height,d3
	moveq.l	#-1,d7			; Masks : the first word, the words between,
	lsr.w	d1,d7			;  the last word
	move.w	d7,d6
	swap	d6
	move.w	#-1,d6
	not.w	d7
	ori.w	#$40,d1			; (NFSR, the shift)
	move.l	Blt_apt(a6),a0		; D = D & !A
	move.l	Blt_dpt(a6),a3
	move.w	Blt_amod(a6),d4
	addq.w	#4,d4
	move.w	Blt_dmod(a6),d5
	addq.w	#2,d5
	move.w	#$0204,d0
	bsr	Hardware_blit
	move.l	Blt_bpt(a6),a0		; D = D | B
	move.w	Blt_bmod(a6),d4
	addq.w	#4,d4
	move.w	#$0207,d0
	bsr	Hardware_blit
	add.w	d2,d2			; The pointers behind the blit
	move.w	d2,d0
	add.w	Blt_amod(a6),d0
	mulu.w	d3,d0
	add.l	d0,Blt_apt(a6)
	move.w	d2,d0
	add.w	Blt_bmod(a6),d0
	mulu.w	d3,d0
	add.l	d0,Blt_bpt(a6)
	move.w	d2,d0
	add.w	Blt_dmod(a6),d0
	mulu.w	d3,d0
	add.l	d0,Blt_cpt(a6)
	add.l	d0,Blt_dpt(a6)
	moveq.l	#0,d0
	rts

; [ Can the blitter of the STE do a column (BDAT) ? ]
;   IN : d5 - Mask of A (.w)
;        a2, a3 - C and D (.l)
;  OUT : Z set : yes
; Changed registers : d0
Column_hardware:
	tst.b	Bl_hardware
	beq.s	.No
	cmp.w	#-1,d5			; (A not masked)
	bne.s	.No
	cmp.l	a2,a3			; (C = D)
	bne.s	.No
	move.w	Blt_cmod(a6),d0
	cmp.w	Blt_dmod(a6),d0
	rts
.No:	moveq.l	#1,d0
	rts

; A column : D = A where BDAT is set (one word, A shifted : its bits from the
; word before come from the line before, like on the Amiga; the shifter of
; the blitter gets 0 first : the Amiga starts with 0)
Hardware_column:
	move.w	d1,-(sp)
	move.w	#$0203,d0			; (a word 0 through the shifter, nothing
	moveq.l	#0,d1			;  written)
	moveq.l	#1,d2
	moveq.l	#1,d3
	moveq.l	#2,d4
	moveq.l	#2,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	lea.l	Bl_zero,a0
	lea.l	Bl_dummy,a3
	bsr	Hardware_blit
	move.w	(sp)+,d1
	move.w	Blt_amod(a6),d4
	addq.w	#2,d4
	move.w	Blt_dmod(a6),d5
	addq.w	#2,d5
	bra.s	Hardware_column2
; The same downwards, not shifted
Hardware_column_down:
	move.w	Blt_amod(a6),d4
	addq.w	#2,d4
	neg.w	d4
	move.w	Blt_dmod(a6),d5
	addq.w	#2,d5
	neg.w	d5
Hardware_column2:
	move.w	Blt_bdat(a6),d6		; (the mask of D : BDAT)
	swap	d6
	move.w	Blt_bdat(a6),d6
	move.w	d6,d7
	moveq.l	#1,d2
	move.w	Bl_height,d3
	move.l	Blt_apt(a6),a0
	move.l	Blt_dpt(a6),a3
	move.w	#$0203,d0
	bsr	Hardware_blit
	move.w	d4,d0			; The pointers behind the blit
	muls.w	d3,d0
	add.l	d0,Blt_apt(a6)
	move.w	d5,d0
	muls.w	d3,d0
	add.l	d0,Blt_cpt(a6)
	add.l	d0,Blt_dpt(a6)
	moveq.l	#0,d0
	rts

Hardware_copy:
	move.w	#$0203,d0			; D = A
	move.l	Blt_apt(a6),a0
	move.w	Blt_amod(a6),d4
	bra.s	Hardware_one
Hardware_clear:
	moveq.l	#$0000,d0			; D = 0
	sub.l	a0,a0
	moveq.l	#0,d4
Hardware_one:
	move.w	d6,d2			; Words
	addq.w	#1,d2
	move.w	Bl_height,d3
	addq.w	#2,d4
	move.l	Blt_dpt(a6),a3
	move.w	Blt_dmod(a6),d5
	addq.w	#2,d5
	moveq.l	#-1,d6
	moveq.l	#-1,d7
	moveq.l	#0,d1
	bsr.s	Hardware_blit
	add.w	d2,d2			; The pointers behind the blit
	move.w	d2,d1
	add.w	Blt_dmod(a6),d1
	mulu.w	d3,d1
	add.l	d1,Blt_dpt(a6)
	cmp.w	#$0203,d0
	bne.s	.Exit
	add.w	Blt_amod(a6),d2
	mulu.w	d3,d2
	add.l	d2,Blt_apt(a6)
.Exit:	moveq.l	#0,d0
	rts

; [ One pass of the blitter ]
;   IN : d0 - HOP and OP (.w)
;        d1 - Skew and flags (.b)
;        d2 - Words per line (.w)
;        d3 - Lines (.w)
;        d4 - Source Y increment (.w)
;        d5 - Destination Y increment (.w)
;        d6 - Mask of the first word, mask of the words between (.l)
;        d7 - Mask of the last word (.w)
;        a0 - Source (.l)
;        a3 - Destination (.l)
; Changed registers : a4
Hardware_blit:
	lea.l	STB_registers,a4
	move.w	#2,(a4)+			; Source X & Y increment, address
	move.w	d4,(a4)+
	move.l	a0,(a4)+
	move.l	d6,(a4)+			; Masks
	move.w	d7,(a4)+
	move.w	#2,(a4)+			; Destination X & Y increment, address
	move.w	d5,(a4)+
	move.l	a3,(a4)+
	move.w	d2,(a4)+			; Size
	move.w	d3,(a4)+
	move.w	d0,(a4)+			; HOP, OP
	move.b	d1,1(a4)			; Skew
	move.b	#$80,(a4)			; Start
.Wait:	bset.b	#7,(a4)			; (again until it is done : the CPU
	nop				;  gets the bus between)
	bne.s	.Wait
	rts

; The functions : IN d0 (A), d1 (B), d2 (C), OUT d0. d3 is the old A, d4 the
; old B (kept)
Bl_f0:	rts
Bl_ca:	and.w	d0,d1			; (A & B) | (!A & C)
	not.w	d0
	and.w	d2,d0
	or.w	d1,d0
	rts
Bl_e2:	and.w	d1,d0			; (A & B) | (!B & C)
	not.w	d1
	and.w	d2,d1
	or.w	d1,d0
	rts
Bl_fc:	or.w	d1,d0			; A | B
	rts
Bl_fe:	or.w	d1,d0			; A | B | C
	or.w	d2,d0
	rts
Bl_fa:	or.w	d2,d0			; A | C
	rts
Bl_0a:	not.w	d0			; !A & C
	and.w	d2,d0
	rts
Bl_00:	moveq.l	#0,d0
	rts
Bl_generic:
	movem.l	d3-d6,-(sp)		; Every minterm
	moveq.l	#0,d5
	move.w	Bl_minterms,d6
	move.w	d0,d3
	not.w	d3
	move.w	d1,d4
	not.w	d4
	lsl.b	#1,d6			; ABC
	bcc.s	.T6
	move.w	d0,-(sp)
	and.w	d1,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T6:	lsl.b	#1,d6			; AB!C
	bcc.s	.T5
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d0,(sp)
	and.w	d1,(sp)
	or.w	(sp)+,d5
.T5:	lsl.b	#1,d6			; A!BC
	bcc.s	.T4
	move.w	d0,-(sp)
	and.w	d4,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T4:	lsl.b	#1,d6			; A!B!C
	bcc.s	.T3
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d0,(sp)
	and.w	d4,(sp)
	or.w	(sp)+,d5
.T3:	lsl.b	#1,d6			; !ABC
	bcc.s	.T2
	move.w	d3,-(sp)
	and.w	d1,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T2:	lsl.b	#1,d6			; !AB!C
	bcc.s	.T1
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d3,(sp)
	and.w	d1,(sp)
	or.w	(sp)+,d5
.T1:	lsl.b	#1,d6			; !A!BC
	bcc.s	.T0
	move.w	d3,-(sp)
	and.w	d4,(sp)
	and.w	d2,(sp)
	or.w	(sp)+,d5
.T0:	lsl.b	#1,d6			; !A!B!C
	bcc.s	.Done
	move.w	d2,-(sp)
	not.w	(sp)
	and.w	d3,(sp)
	and.w	d4,(sp)
	or.w	(sp)+,d5
.Done:	move.w	d5,d0
	movem.l	(sp)+,d3-d6
	rts

	SECTION	Fast_BSS,bss
Intro_custom:	ds.b $200			; The custom chips
Bl_height:	ds.w 1
Bl_minterms:	ds.w 1
Bl_sa:	ds.w 1
Bl_sb:	ds.w 1
Bl_step:	ds.w 1
Bl_con0:	ds.w 1
Bl_bstep:	ds.w 1
Bl_dstep:	ds.w 1
Bl_row:	ds.w 1
Bl_zero:	ds.w 1
Bl_dummy:	ds.w 1
Bl_hardware:	ds.b 1			; The blitter of the STE is there
Bl_no_plane4:	ds.b 1			; Plane 4 is not shown (the sparkles)
Bl_first:	ds.b 1
Bl_desc:	ds.b 1
	even
