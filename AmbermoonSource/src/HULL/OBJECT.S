; Object recognition system
; Written	by J.Horneman (In Tune With The Universe)
; Start :	5-9-1992

	XDEF	Push_Tree
	XDEF	Pop_Tree
	XDEF	Reset_tree_stack
	XDEF	Find_object
	XDEF	Offset_X
	XDEF	Offset_Y

	SECTION	Program,code
;*****************************************************************************
; [ Push a object tree on the stack ]
;   IN : a0 - Pointer to object tree (.l)
; All registers are	restored
;*****************************************************************************
Push_Tree:     
	move.l	a1,-(sp)
	movea.l	Tree_Sp,a1
	addq.l	#4,a1
	cmpa.l	#TreeStack_end,a1		; Possible ?
	beq.s	.Exit
	move.l	a0,(a1)			; Push
	move.w	(a0),Offset_X		; Set offset
	move.w	2(a0),Offset_Y
	move.l	a1,Tree_Sp
.Exit:	movea.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Pop a tree from the stack ]
; All registers are	restored
;*****************************************************************************
Pop_Tree:      
	move.l	a0,-(sp)
	movea.l	Tree_Sp,a0
	cmpa.l	#TreeStack_start,a0		; Possible ?
	beq.s	.Exit
	subq.l	#4,a0			; Pop
	move.l	a0,Tree_Sp
	move.l	(a0),a0			; Set offset
	move.w	(a0),Offset_X
	move.w	2(a0),Offset_Y
.Exit:	movea.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Reset the tree stack ]
; All registers are	restored
;*****************************************************************************
Reset_tree_stack:    
	movem.l	a0/a1,-(sp)
	lea.l	Default_Tree,a0		; Reset stack
	lea.l	TreeStack_start,a1
	move.l	a1,Tree_Sp
	move.l	a0,(a1)
	movem.l	(sp)+,a0/a1
	rts

;*****************************************************************************
; [ Find object ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : d2 - $00xxyyzz
;	    xx = first layer identification
;	    yy = second layer identification
;	    zz = third layer identification
;	     0 = nothing was found
; Changed registers : d2
;*****************************************************************************
Find_object:        
	movem.l	d0/d1/d7/a0,-(sp)
	moveq.l	#0,d2			; Clear output
	movea.l	Tree_Sp,a0		; Get current tree
	move.l	(a0),a0
	sub.w	(a0)+,d0			; Translation
	sub.w	(a0)+,d1
	move.l	a0,d7
	jsr	Search_layer		; Identify 1st layer
	tst.b	d2			; Anything found ?
	beq.s	.Exit
	swap.w	d2
	move.l	Obj_child(a0),d7		; Second layer child
	beq.s	.Exit			; Any ?
	jsr	Search_layer		; Identify 2nd layer
	tst.b	d2			; Anything found ?
	beq.s	.Exit
	lsl.w	#8,d2
	move.l	Obj_child(a0),d7		; Third layer child
	beq.s	.Exit			; Any ?
	jsr	Search_layer		; Identify 3rd layer
.Exit:	movem.l	(sp)+,d0/d1/d7/a0
	rts

; [ Search a layer of objects ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d7 - Pointer to first entry in	layer (.l)
;  OUT : d2 - ID of	entry (.b)
;        a0 - Pointer to entry (.l)
; Changed registers : d2,d7,a0
Search_layer:       
.Again:	movea.l	d7,a0
	cmp.w	Obj_X1(a0),d0		; Check X	against left edge
	bmi.s	.Next
	cmp.w	Obj_X2(a0),d0		; Check X	against right edge
	bgt.s	.Next
	cmp.w	Obj_Y1(a0),d1		; Check Y	against top edge
	bmi.s	.Next
	cmp.w	Obj_Y2(a0),d1		; Check Y	against bottom edge
	bgt.s	.Next
	move.b	8(a0),d2			; Get ID
	bra.s	.Exit
.Next:	move.l	Obj_brother(a0),d7		; Next brother
	bne.s	.Again
.Exit:	rts

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
Default_Tree:
	dc.w 0,319,0,199			; Entire screen
	dc.b 1				; Dummy ID
	even
	dc.l 0,0				; No brothers or children

	SECTION	Fast_BSS,bss
Offset_X:	ds.w 1				; Current offset
Offset_Y:	ds.w 1
Tree_Sp:	ds.l 1				; Tree stack
TreeStack_start:        
	ds.l Max_trees
TreeStack_end:
