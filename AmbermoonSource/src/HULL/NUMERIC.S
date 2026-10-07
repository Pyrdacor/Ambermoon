; Numeric conversion routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 12-4-1991

; NOTES :
;   - All numbers must be EXTended to longwords before calling this
;     routine.

	XDEF	String_to_number
	XDEF	Hex_convert
	XDEF	SDecL_convert
	XDEF	DecL_convert
	XDEF	SDecR_convert
	XDEF	DecR_convert
	XDEF	Insert_sign

	SECTION	Program,code	
;*****************************************************************************
; [ ASCII to decimal converter ]
;   IN : a0 - Pointer to string (.l)
;  OUT : d0 - Number (.l)
; Changed registers : d0
; Notes :
;   - If the string is illegal, the result will be 0.
;*****************************************************************************
String_to_number:
	movem.l	d1/a0,-(sp)
	moveq.l	#0,d0			; Default is zero
.Again1:	tst.b	(a0)			; End of string ?
	beq	.Exit
	cmp.b	#" ",(a0)+		; Leading space ?
	beq.s	.Again1
	subq.l	#1,a0			; No -> back one
.Again2:	moveq.l	#0,d1			; Get character
	move.b	(a0)+,d1
	beq.s	.Exit			; End of string ?
	cmp.w	#"0",d1			; Legal ?
	bmi.s	.Exit
	cmp.w	#"9"+1,d1
	bpl.s	.Exit
	mulu.w	#10,d0			; Yes -> add
	subi.w	#"0",d1
	ext.l	d1
	add.l	d1,d0
	bra.s	.Again2
.Exit:	movem.l	(sp)+,d1/a0
	rts

;*****************************************************************************
; [ Binary to hexadecimal ASCII converter ]
;   IN : d0 - Number (.l)
;        d7 - Number of digits to be put out (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to end of string (EOL) (.l)
; Changed registers : a0
; Notes :
;   -     byte = 2 digits
;   -     word = 4 digits
;   - longword = 8 digits
;   - An EOL is automatically added to the end of the string.
;*****************************************************************************
Hex_convert:        
	movem.l	d0/d1/d7,-(sp)
	tst.w	d7			; Legal input ?
	beq	.Exit
	add.w	d7,a0			; Go to end of string
	clr.b	(a0)			; Insert EOL
	move.l	a0,-(sp)
	subq.w	#1,d7
.Loop2:	moveq.l	#$f,d1			; Get low	nibble
	and.w	d0,d1
	cmpi.w	#$a,d1			; Convert	to HEX
	bmi.s	.No_letter
	addi.w	#"A"-10,d1
	bra.s	.Skip
.No_letter:
	addi.w	#"0",d1
.Skip:	move.b	d1,-(a0)			; Insert in string
	ror.l	#4,d0			; Rotate
	dbra	d7,.Loop2			; Next nibble
	move.l	(sp)+,a0			; Output
.Exit:	movem.l	(sp)+,d0/d1/d7
	rts

;*****************************************************************************
; [ SIGNED Binary to decimal ASCII converter - left justified ]
;   IN : d0 - Number (.b/.w/.l)
;        d7 - Number of digits to be put out (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to end of string (EOL) (.l)
; Changed registers : a0
; Notes :
;   - A longword has 10 digits.
;   - An EOL is automatically added to the end of the string.
;*****************************************************************************
SDecL_convert:
	move.l	d0,-(sp)
	tst.w	d7			; Legal input ?
	beq	.Exit
	cmpi.w	#10+1,d7
	bhi	.Exit
	cmp.w	#2+1,d7			; Byte ?
	bpl.s	.No_byte
	ext.w	d0
	ext.l	d0
	bra.s	.Do
.No_byte:	cmp.w	#5+1,d7			; Word ?
	bpl.s	.Do
	ext.l	d0
.Do:	tst.l	d0			; Insert sign
	jsr	Insert_sign
	tst.l	d0			; Negative ?
	bpl.s	.Pos
	neg.l	d0			; Yes -> Negate
.Pos:	jsr	Do_DecL_convert		; Convert
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ UNSIGNED Binary to decimal ASCII converter - left justified ]
;   IN : d0 - Number (.b/.w/.l)
;        d7 - Number of digits to be put out (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to end of string (EOL) (.l)
; Changed registers : a0
; Notes :
;   - A longword has 10 digits.
;   - An EOL is automatically added to the end of the string.
;*****************************************************************************
DecL_convert:
	move.l	d0,-(sp)
	tst.w	d7			; Legal input ?
	beq	.Exit
	cmpi.w	#10+1,d7
	bhi	.Exit
	cmp.w	#2+1,d7			; Byte ?
	bpl.s	.No_byte
	andi.l	#$000000ff,d0
	bra.s	.Do
.No_byte:	cmp.w	#5+1,d7			; Word ?
	bpl.s	.Do
	andi.l	#$0000ffff,d0
.Do:	jsr	Do_DecL_convert		; Convert
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ UNSIGNED Binary to decimal ASCII converter - left justified ]
;   IN : d0 - Number (.l)
;        d7 - Number of digits to be put out (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to end of string (EOL) (.l)
; Changed registers : a0
; Notes :
;   - A longword has 10 digits.
;   - An EOL is automatically added to the end of the string.
;*****************************************************************************
Do_DecL_convert:
	movem.l	d0/d2-d4/d7/a1,-(sp)
.Do:	tst.l	d0			; Zero ?
	bne.s	.Notzero
	move.b	#"0",(a0)+		; Zero
	bra	.End
.Notzero:	lea.l	Weights+40,a1		; Get weight pointer
	move.w	d7,d3
	add.w	d3,d3
	add.w	d3,d3
	suba.w	d3,a1
	cmp.l	-4(a1),d0			; Not too big ?
	bmi.s	.Ok
	subq.w	#1,d7			; Make dummy number
.Loop1:	move.b	#"*",(a0)+
	dbra	d7,.Loop1
	bra	.End
.Ok:	moveq.l	#0,d3			; Convert number
	subq.w	#1,d7
.Loop2:	move.l	(a1)+,d4			; Load weight
	move.w	#"0",d2
.Weigh:	cmp.l	d4,d0			; Weigh number
	bmi.s	.Skip
	sub.l	d4,d0			; Reduce weight
	addq.w	#1,d2			; Increase digit
	bra.s	.Weigh
.Skip:	cmpi.w	#"0",d2			; Leading space ?
	bne.s	.No_leading_space
	tst.w	d3
	beq.s	.Next2
.No_leading_space:  
	move.b	d2,(a0)+			; Insert in string
	st	d3
.Next2:	dbra	d7,.Loop2
.End:	clr.b	(a0)			; Insert EOL
.Exit:	movem.l	(sp)+,d0/d2-d4/d7/a1
	rts

;*****************************************************************************
; [ SIGNED Binary to decimal ASCII converter - right justified ]
;   IN : d0 - Number (.b/.w/.l)
;        d6 - Fill character (.b)
;        d7 - Number of digits to be put out (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to end of string (EOL) (.l)
; Changed registers : a0
; Notes :
;   - A longword has 10 digits.
;   - An EOL is automatically added to the end of the string.
;*****************************************************************************
SDecR_convert:
	move.l	d0,-(sp)
	tst.w	d7			; Legal input ?
	beq	.Exit
	cmpi.w	#10+1,d7
	bhi	.Exit
	cmp.w	#2+1,d7			; Byte ?
	bpl.s	.No_byte
	ext.w	d0
	ext.l	d0
	bra.s	.Do
.No_byte:	cmp.w	#5+1,d7			; Word ?
	bpl.s	.Do
	ext.l	d0
.Do:	tst.l	d0			; Insert sign
	jsr	Insert_sign
	tst.l	d0			; Negative ?
	bpl.s	.Pos
	neg.l	d0			; Yes -> Negate
.Pos:	jsr	Do_DecR_convert		; Convert
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ UNSIGNED Binary to decimal ASCII converter - right justified ]
;   IN : d0 - Number (.b/.w/.l)
;        d6 - Fill character (.b)
;        d7 - Number of digits to be put out (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to end of string (EOL) (.l)
; Changed registers : a0
; Notes :
;   - A longword has 10 digits.
;   - An EOL is automatically added to the end of the string.
;*****************************************************************************
DecR_convert:
	move.l	d0,-(sp)
	tst.w	d7			; Legal input ?
	beq	.Exit
	cmpi.w	#10+1,d7
	bhi	.Exit
	cmp.w	#2+1,d7			; Byte ?
	bpl.s	.No_byte
	andi.l	#$000000ff,d0
	bra.s	.Do
.No_byte:	cmp.w	#5+1,d7			; Word ?
	bpl.s	.Do
	andi.l	#$0000ffff,d0
.Do:	jsr	Do_DecR_convert		; Convert
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ UNSIGNED Binary to decimal ASCII converter - right justified ]
;   IN : d0 - Number (.l)
;        d6 - Fill character (.b)
;        d7 - Number of digits to be put out (.w)
;        a0 - Pointer to string (.l)
;  OUT : a0 - Pointer to end of string (EOL) (.l)
; Changed registers : a0
; Notes :
;   - A longword has 10 digits.
;   - An EOL is automatically added to the end of the string.
;*****************************************************************************
Do_DecR_convert:
	movem.l	d0/d2-d4/d7/a1,-(sp)
	tst.l	d0			; Zero ?
	bne.s	.Notzero
	subq.w	#1,d7			; Leading spaces
	bra.s	.Entry0
.Loop0:	move.b	d6,(a0)+
.Entry0:	dbra	d7,.Loop0
	move.b	#"0",(a0)+		; Zero
	bra	.End
.Notzero:	lea.l	Weights+40,a1		; Get weight pointer
	move.w	d7,d3
	add.w	d3,d3
	add.w	d3,d3
	suba.w	d3,a1
	cmp.l	-4(a1),d0			; Not too big ?
	bmi.s	.Ok
	subq.w	#1,d7			; Make dummy number
.Loop1:	move.b	#"*",(a0)+
	dbra	d7,.Loop1
	bra	.End
.Ok:	moveq.l	#0,d3			; Convert number
	subq.w	#1,d7
.Loop2:	move.l	(a1)+,d4			; Load weight
	move.w	#"0",d2
.Weigh:	cmp.l	d4,d0			; Weigh number
	bmi.s	.Skip
	sub.l	d4,d0			; Reduce weight
	addq.w	#1,d2			; Increase digit
	bra.s	.Weigh
.Skip:	cmpi.w	#"0",d2			; Leading space ?
	bne.s	.No_leading_space
	tst.w	d3
	bne.s	.No_leading_space
	move.b	d6,(a0)+			; Insert fill character
	bra.s	.Next2
.No_leading_space:  
	move.b	d2,(a0)+			; Insert in string
	st	d3
.Next2:	dbra	d7,.Loop2
.End:	clr.b	(a0)			; Insert EOL
.Exit:	movem.l	(sp)+,d0/d2-d4/d7/a1
	rts

;***************************************************************************
; [ Insert sign in string ]
;   IN : a0 - Pointer to string (.l)
;        condition codes
;  OUT : a0 - Pointer to string after sign (.l)
; Changed registers : a0
; Notes :
;   - The condition codes are changed.
;***************************************************************************
Insert_sign:
	bpl.s	.Pos			; Negative ?
	move.b	#"-",(a0)+		; Yes -> minus	
	bra.s	.Exit
.Pos:	beq.s	.Zero			; Zero ?
	move.b	#"+",(a0)+		; No -> plus
	bra.s	.Exit
.Zero:	move.b	#" ",(a0)+		; Zero
.Exit:	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
	dc.l 10000000000
Weights:	dc.l 1000000000,100000000,10000000,1000000
	dc.l 100000,10000,1000,100,10,1
