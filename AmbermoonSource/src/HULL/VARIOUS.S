; Various routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 18-8-1992

	XREF	Wait_4_user_Mod
	XREF	Music_routine
	XREF	Music_flag
	XREF	Music_handle
	XREF	ATN_table

	XDEF	Get_random_50_100
	XDEF	Shuttlesort
	XDEF	Shellsort
	XDEF	Strcpy
	XDEF	Strncpy
	XDEF	Strlen
	XDEF	Wait_4_user
	XDEF	Delay
	XDEF	Wait_4_click
	XDEF	Wait_4_unclick
	XDEF	Wait_4_rightclick
	XDEF	Wait_4_rightunclick
	XDEF	Wait_4_key
	XDEF	Reset_keyboard
	XDEF	Reset_mouse_buffer
	XDEF	Crypt_block
	XDEF	Fill_memory
	XDEF	Random
;	XDEF	Unsigned_32_bit_multiply
;	XDEF	Signed_32_bit_multiply
	XDEF	Square_root
	XDEF	Calculate_ATN
	XDEF	Get_music
	XDEF	Set_music
	XDEF	Relocate_music

	SECTION	Program,code
;*****************************************************************************
; [ Get random value between 50% of 100% of input value ]
;   IN : d0 - Input value (.w)
;  OUT : d0 - Random value between 50% of 100% of input value (.w)
; Changed registers : d0
;*****************************************************************************
Get_random_50_100:
	move.l	d1,-(sp)
	move.w	d0,d1			; Save input value
	jsr	Random			; Get random value [0-65535]
	mulu.w	#51,d0			; Transform to [0-50]
	swap	d0
	addi.w	#50,d0			; Transform to [50-100]
	mulu.w	d1,d0			; Transform input value
	divu.w	#100,d0
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ Generic Shuttlesort ]
;   IN : d7 - Number of elements (.w)
;        a0 - Pointer to Compare routine (.l)
;        a1 - Pointer to Swap routine (.l)
; All registers are restored
; Notes :
;   - Unlike Shellsort, this sorting routine will not change the order
;     of elements with an equal value.
;*****************************************************************************
Shuttlesort:
	movem.l	d0/d1/d5/d6,-(sp)
	cmp.w	#1,d7			; More than 1 element ?
	bls.s	.Exit
	moveq.l	#1,d0			; For L = 1 to N-1
.Loop1:	move.w	d0,d5			; If (L) > (L+1)
	move.w	d0,d6
	addq.w	#1,d6
	jsr	(a0)
	ble.s	.Next1
	jsr	(a1)			; Swap (L,L+1)
	move.w	d0,d1			; PS = L-1
.Loop2:	tst.w	d1			; If PS > 0
	beq.s	.Next1
	move.w	d1,d5			; If (PS) > (PS+1)
	move.w	d1,d6
	addq.w	#1,d6
	jsr	(a0)
	ble.s	.Next1
	jsr	(a1)			; Swap (PS,PS+1)
	subq.w	#1,d1			; PS = PS-1
	bra.s	.Loop2
.Next1:	addq.w	#1,d0			; Next L
	cmp.w	d7,d0
	bmi.s	.Loop1
.Exit:	movem.l	(sp)+,d0/d1/d5/d6
	rts

;*****************************************************************************
; [ Generic Shellsort ]
;   IN : d7 - Number of elements (.w)
;        a0 - Pointer to Compare routine (.l)
;        a1 - Pointer to Swap routine (.l)
; All registers are restored
;*****************************************************************************
Shellsort:
	movem.l	d0-d2/d5/d6,-(sp)
	cmp.w	#1+1,d7			; More than 1 element ?
	bmi	.Done1
	move.w	d7,d0			; Inc = Count
.Again1:	cmp.w	#1,d0			; While (Inc>1)
	bls.s	.Done1
	lsr.w	#1,d0			; Inc = Inc/2
	moveq.l	#1,d1			; L = 1
.Again2:	move.w	d7,d2			; While (L <= Count - Inc)
	sub.w	d0,d2
	cmp.w	d1,d2
	bmi.s	.Done2
	move.w	d1,d5			; If (L) > (L+Inc)
	move.w	d1,d6
	add.w	d0,d6
	jsr	(a0)
	ble.s	.Endif1
	jsr	(a1)			; Swap(L,L+Inc)
	move.w	d1,d2			; Ps = L-Inc
	sub.w	d0,d2
.Again3:	tst.w	d2			; While (Ps>0)
	ble.s	.Done3
	move.w	d2,d5			; If (Ps) > (Ps+Inc)
	move.w	d2,d6
	add.w	d0,d6
	jsr	(a0)
	ble.s	.Else2
	jsr	(a1)			; Swap(Ps,Ps+Inc)
	sub.w	d0,d2			; Ps = Ps-Inc
	bra.s	.Endif2
.Else2:	moveq.l	#0,d2			; Ps = 0
.Endif2:	bra.s	.Again3			; }
.Done3:
.Endif1:	addq.w	#1,d1			; L++
	bra.s	.Again2			; }
.Done2:	bra.s	.Again1			; }
.Done1:	movem.l	(sp)+,d0-d2/d5/d6
	rts

;*****************************************************************************
; [ Strcpy function ]
;   IN : a0 - Pointer to destination string (.l)
;        a1 - Pointer to source string (.l)
; Changed registers : a0,a1
; Note :
;   - This routine copies the EOL as well.
;*****************************************************************************
Strcpy:   
	move.l	d0,-(sp)
.Again:	move.b	(a1)+,d0			; Read character
	move.b	d0,(a0)+			; Copy character
	bne.s	.Again			; End of line ?
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Strncpy function ]
;   IN : d0 - Number of characters to copy (.w)
;        a0 - Pointer to destination string (.l)
;        a1 - Pointer to source string (.l)
; Changed registers : d0,a0,a1
;*****************************************************************************
Strncpy:  
	bra.s	.Entry
.Loop:	move.b	(a1)+,(a0)+		; Copy character
.Entry:	dbra	d0,.Loop
	rts

;*****************************************************************************
; [ Strlen function ]
;   IN : a0 - Pointer to string (.l)
;  OUT : d0 - String length (.l)
; Changed registers : d0
;*****************************************************************************
Strlen:  
	move.l	a0,-(sp)
	moveq.l	#-1,d0
.Again:	addq.l	#1,d0			; Count up
	tst.b	(a0)+			; End of string ?
	bne.s	.Again			; No, repeat
	move.l	(sp)+,a0
	rts

;***************************************************************************
; [ Wait for the user ]
; All registers are restored
;***************************************************************************
Wait_4_user:
	move.l	a0,-(sp)
	jsr	Wait_4_unclick
	Push	Module,Wait_4_user_Mod
	jsr	Wait_4_unclick
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Delay	]
;   IN : d0 - Number of VBL's	to delay (.w)
; All registers are	restored
;*****************************************************************************
Delay:    
	move.l	d0,-(sp)
	bra.s	.Entry
.Loop:	jsr	My_vsync
.Entry:	dbra	d0,.Loop
	move.l	(sp)+,d0
	rts

;***************************************************************************
; [ Wait for a mouse click ]
; All registers are restored
;***************************************************************************
Wait_4_click:
	move.l	d0,-(sp)
.Wait:	move.b	Button_state,d0
	andi.b	#$11,d0
	beq.s	.Wait
	jsr	Wait_4_unclick
	move.l	(sp)+,d0
	rts

;***************************************************************************
; [ Wait for mouse button to be released ]
; All registers are restored
;***************************************************************************
Wait_4_unclick:
	move.l	d0,-(sp)
.Wait:	move.b	Button_state,d0		; Wait
	andi.b	#$11,d0
	bne.s	.Wait
	move.l	(sp)+,d0
	rts

;***************************************************************************
; [ Wait for a right mouse click ]
; All registers are restored
;***************************************************************************
Wait_4_rightclick:
	move.l	d0,-(sp)
.Wait:	move.b	Button_state,d0
	btst	#Right_pressed,d0
	beq.s	.Wait
	jsr	Wait_4_rightunclick
	move.l	(sp)+,d0
	rts

;***************************************************************************
; [ Wait for right mouse button to be released ]
; All registers are restored
;***************************************************************************
Wait_4_rightunclick:
	move.l	d0,-(sp)
.Wait:	move.b	Button_state,d0		; Wait
	btst	#Right_pressed,d0
	bne.s	.Wait
	move.l	(sp)+,d0
	rts

;***************************************************************************
; [ Wait for a key ]
; All registers are restored
;***************************************************************************
Wait_4_key:
	move.l	d0,-(sp)
.Again:	jsr	Read_key			; Read a key
	tst.l	d0			; None available ?
	beq.s	.Again			; No -> again
	move.l	(sp)+,d0
	rts

;***************************************************************************
; [ Clear the keyboard buffer ]
; All registers are restored
;***************************************************************************
Reset_keyboard:
	move.l	d0,-(sp)
.Again:	jsr	Read_key			; Read a key
	tst.l	d0			; None available ?
	bne.s	.Again			; Yes -> again
	move.l	(sp)+,d0
	rts

;***************************************************************************
; [ Clear the mouse event buffer ]
; All registers are restored
;***************************************************************************
Reset_mouse_buffer:
	movem.l	d0-d2,-(sp)
.Again:	jsr	Read_Mev			; Read a mouse event
	tst.w	d2			; None available ?
	bne.s	.Again			; Yes -> again
	movem.l	(sp)+,d0-d2
	rts

;*****************************************************************************
; [ Encrypt/decrypt memory block ]
;   IN : d0 - Encryption seed (.w)
;        d7 - Length of block (.l)
;        a0 - Pointer to start of block (.l)
;  OUT : d0 - Encryption seed (.w)
; Changed registers : d0
; NOTE :
;  - The length of the block is made even.
;*****************************************************************************
Crypt_block:
	movem.l	d1/d2/d7/a0,-(sp)
	move.w	#87,d2
	addq.l	#1,d7
	asr.l	#1,d7
	bra	.Entry
.Loop:	eor.w	d0,(a0)+			; Encrypt
	move.w	d0,d1			; Make next seed
	lsl.w	#4,d0			; (Seed =	Seed x 17	+ 87)
	add.w	d1,d0
	add.w	d2,d0
.Entry:	subq.l	#1,d7			; Next word
	bpl.s	.Loop
	movem.l	(sp)+,d1/d2/d7/a0
	rts

;***************************************************************************
; [ Fill memory ]
;   IN : d0 - Number of bytes to clear (must be even) (.l)
;        d1 - Fill value (.l)
;        a0 - Address at which to clear (must be even) (.l)
; All registers are restored
;***************************************************************************
Fill_memory:
	movem.l	d0-d2/a0,-(sp)
	add.l	d0,a0			; Work from back to front
	move.l	d1,d2
	move.l	d0,d1			; Do chunks of 32 bytes
	lsr.l	#5,d1
	beq.s	.Skip
	movem.l	d3-d7/a1/a2,-(sp)
	move.l	d2,d3			; Clear registers
	move.l	d2,d4
	move.l	d2,d5
	move.l	d2,d6
	move.l	d2,d7
	move.l	d2,a1
	move.l	d2,a2
.Loop1:	movem.l	d2-d7/a1/a2,-(a0)
	subq.l	#1,d1
	bne.s	.Loop1
	movem.l	(sp)+,d3-d7/a1/a2
.Skip:	andi.w	#$001f,d0			; Do remaining words
	lsr.w	#1,d0
	beq.s	.Exit
	subq.w	#1,d0			; DBRA correction
.Loop2:	move.w	d2,-(a0)
	dbra	d0,.Loop2
.Exit:	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Get random number ]
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

	ifne	FALSE
;*****************************************************************************
; [ 32-bit unsigned multiplication ]
;   IN : d0 - Value 1 (.l)
;        d1 - Value 2 (.l)
;  OUT : d0 - Value 1 x Value 2 (.l)
; Changed registers : d0
;*****************************************************************************
Unsigned_32_bit_multiply:
	movem.l	d1/d3-d5,-(sp)
	move.w	d0,d3			; d3 = B x D
	mulu.w	d1,d3
	move.w	d0,d5
	swap	d0
	move.w	d0,d4
	mulu.w	d1,d4			; d4 = A x D
	swap	d1
	mulu.w	d1,d5			; d5 = B x C
	add.w	d5,d4
	swap	d3
	add.w	d3,d4
	move.w	d4,d3
	swap	d3
	move.l	d3,d0
	movem.l	(sp)+,d1/d3-d5
	rts

;*****************************************************************************
; [ 32-bit signed multiplication ]
;   IN : d0 - Value 1 (.l)
;        d1 - Value 2 (.l)
;  OUT : d0 - Value 1 x Value 2 (.l)
; Changed registers : d0
;*****************************************************************************
Signed_32_bit_multiply:
	movem.l	d1-d5,-(sp)
	moveq.l	#0,d2			; Clear negate flag
	tst.l	d0			; Value 1 negative ?
	bge.s	.Nomin1
	neg.l	d0			; Make positive
	addq.w	#1,d2			; Flag negation
.Nomin1:	tst.l	d1			; Value 2 negative ?
	bge.s	.Nomin2
	neg.l	d1			; Make positive
	addq.w	#1,d2			; Flag negation
.Nomin2:	move.w	d0,d3			; Calculate product
	mulu.w	d1,d3
	move.w	d0,d5
	swap	d0
	move.w	d0,d4
	mulu.w	d1,d4
	swap	d1
	mulu.w	d1,d5
	add.w	d5,d4
	swap	d3
	add.w	d3,d4
	move.w	d4,d3
	swap	d3
	move.l	d3,d0
	btst	#0,d2			; Negate ?
	beq.s	.Exit
	neg.l	d0			; Negate
.Exit:	movem.l	(sp)+,d1-d5
	rts
	endc

;*****************************************************************************
; [ 32-bit square root ]
;   IN : d0 - Value (.l)
;  OUT : d0 - Square root of Value (.w)
; Changed registers : d0
; Original routine by C. Jungen
; Notes :
;  - This routine uses interval minimizing.
;  - It costs about 3 scan-lines of processing time.
;*****************************************************************************
Square_root:
	movem.l	d1-d3,-(sp)
	moveq.l	#0,d1			; Xroot=0
	tst.l	d0			; Legal value ?
	bls	.Exit
	move.l	#$10000000,d2		; m2=2^32
.Iteration:
	move.l	d1,d3
	add.l	d2,d3			; x2=xroot+m2
	asr.l	#1,d1			; SHR(Xroot,1)
	cmp.l	d3,d0			; x2<=x?
	blt.s	.X2_is_greater
	sub.l	d3,d0			; x=x-x2
	add.l	d2,d1			; xroot=xroot+m2
.X2_is_greater:
	asr.l	#2,d2			; SHR(m2,2)
	bne.s	.Iteration
.Exit:	move.l	d1,d0			; Output
	movem.l	(sp)+,d1-d3
	rts

;*****************************************************************************
; [ Calculate arcus-tangens of vector ]
;   IN : d0 - dX (.w)
;        d1 - dY (.w)
;  OUT : d0 - Angle (.w)
; Changed registers : d0
; Original routine by C. Jungen
;*****************************************************************************
Calculate_ATN:
	movem.l	d1/d5-d7/a0,-(sp)
; Die Tabelle gilt nur für positive Wert von Dx/Dy <= $4000 (entspricht 1)
	move.w	d0,d6			; Dx merken
	bge.s	.dx_positiv		; d0=ABS(Dx)
	neg.w	d0
.dx_positiv:
	move.w	d1,d7			; Dy merken
	bge.s	.dy_positiv		; d1=ABS(Dy)
	neg.w	d1
.dy_positiv:
	cmp.w	d0,d1			; sicherstellen, dass der Bruch<= $4000 (entsp. 1) ist
	sle	d5			; Flag für Dy mit Dx vertauscht
	bgt.s	.dy_higher_than_dx
	exg	d0,d1			; Dx mit Dy tauschen
.dy_higher_than_dx:
	tst.w	d1			; Dy=Dx=0?
	beq.s	.Exit
; Dx mit $4000 erweitern
	swap	d0
	clr.w	d0
	asr.l	#2,d0
	divu	d1,d0			; Dx/Dy
; durch 16 teilen (Tabellen-Einheit)  und gleichzeitig Wordzugriff
	asr.w	#4-1,d0
	andi.w	#$fffe,d0
	lea	ATN_table,a0		; Zeiger auf Werte-Tabelle
	move.w	(a0,d0.w),d0		; ATN-Wert holen
; falls dy/dx berechnet wurde => Komplementärwinkel benutzen
	tst.b	d5			; dx mit dy getauscht?
	beq.s	.deltas_not_swapped
	neg.w	d0			; Alpha = 90 Altgrad - Beta
	addi.w	#$0400,d0
.deltas_not_swapped:
; falls SGN(Dx*Dy)=-1 => Ergebnis=-Ergebnis
	eor.w	d7,d6			; Vorzeichen feststellen
	bge.s	.not_negative
	neg.w	d0
.not_negative:
	tst.w	d7			; Vorzeichen dy prüfen
	bge.s	.no_add_180
	addi.w	#$0800,d0			; 180 Altgrad addieren
.no_add_180:
	asr.w	#2,d0			; Konvertierung v. $1000 nach $400
	andi.w	#$03ff,d0			; Winkel begrenzen auf Wertebereich
.Exit:	movem.l	(sp)+,d1/d5-d7/a0
	rts

;*****************************************************************************
; [ Get music ]
;  OUT : d0 - Current music number (.w)
; All registers are restored
;*****************************************************************************
Get_music:
	move.w	Current_music,d0		; Get
	rts

;*****************************************************************************
; [ Set music ]
;   IN : d0 - Music number / 
;              0 - Stop music /
;             -1 - Start music (.w)
;        d1 - Song number (0...) (.w)
; All registers are restored
; NOTES :
;   - The three music variables work in the following way :
;	Current_music	: Music currently selected by main program
;	Loaded_music	: Music currently loaded in memory
;	Playing_music	: Music currently being played
;*****************************************************************************
Set_music:
	movem.l	d0-d7/a0-a6,-(sp)
; ---------- Stop music ---------------------------
	tst.w	d0			; Stop ?
	bne.s	.Ok
	clr.w	Loaded_music		; Yes
	tst.b	Music_handle		; Any music loaded ?
	beq	.Exit
	move.w	#$000f,Custom+dmacon	; Yes -> DMA channels off
	jsr	Remove_music
	bra	.Exit
; ---------- Restart music ------------------------
.Ok:	cmp.w	#-1,d0			; Restart ?
	bne	.New
	move.w	Current_music,d0		; Yes
	bra	.Play
; ---------- New music ----------------------------
.New:	cmpi.w	#Max_songs,d0		; Illegal	input ?
	bgt	.Exit
	cmp.w	Loaded_music,d0		; Same as	before ?
	bne.s	.Other
	cmp.w	Current_song,d1
	beq	.Exit
.Other:	move.w	d0,Current_music		; No -> Store
	move.w	d1,Current_song
	tst.b	Music_handle		; Any music loaded ?
	beq.s	.Play
	jsr	Remove_music		; Yes -> Remove it
; ---------- Start whatever music -----------------
.Play:	tst.b	Music_flag		; Music on ?
	beq	.Exit
	move.w	Current_music,d0		; Any music selected ?
	beq.s	.Exit
	move.w	d0,Loaded_music		; Yes
	moveq.l	#Music_file,d1		; Load music
	jsr	Load_subfile
	move.b	d0,Music_handle
	jsr	Claim_pointer		; Initialize
	move.l	d0,a0
	music	Music_init
	move.b	Music_handle,d0
	jsr	Free_pointer
	move.w	Current_music,Playing_music	; Set
	move.w	Current_song,d0		; Start music
	music	Music_start
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Remove current music from memory ]
; Changed registers : d0
;*****************************************************************************
Remove_music:
	music	Music_stop		; Stop it
	clr.w	Playing_music
	move.b	Music_handle,d0		; Remove music
	jsr	Free_memory
	clr.b	Music_handle
	rts

;*****************************************************************************
; [ Relocate music file ]
;   IN : d0 - Size of memory block (.l)
;        a0 - Source address (.l)
;        a1 - Target address (.l)
;        a3 - Pointer to source memory block descriptor (.l)
; All registers are	restored
;*****************************************************************************
Relocate_music:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	Music_flag		; Music on ?
	beq.s	.Copy
	move.w	Playing_music,d1		; Copying playing music ?
	cmp.w	Block_subfile_nr(a3),d1
	beq.s	.On
.Copy:	jsr	Copy_memory		; Just copy
	bra.s	.Exit
.On:	music	Music_stop		; Stop it
	clr.w	Playing_music
	sf	Music_flag		; Off
	move.w	#$000f,Custom+dmacon
	jsr	Copy_memory		; Move music
	st	Restart_music		; On later
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;***************************************************************************	
; The DATA & BSS segments	
;***************************************************************************
	SECTION	Fast_DATA,data
Seed:	dc.l $12345678

	SECTION	Fast_BSS,bss
Restart_music:	ds.b 1
	even
Current_music:	ds.w 1
Current_song:	ds.w 1
Loaded_music:	ds.w 1
Playing_music:	ds.w 1
