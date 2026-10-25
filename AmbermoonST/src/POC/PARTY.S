; Proof of concept : joining and leaving the party (Atari ST)
;
; From DIALOGUE.S ([ Add_party_member ], [ Show_arrival ]) and MAIN.S
; ([ Remove_party_member ], [ Show_removal ]). An empty place in the party
; has the character number 0 in [ Member_nrs ]; its character data is
; cleared and marked as dead, so it is skipped by everything that only
; handles living members.
;
; The original saves the data of a character who leaves the party into its
; file. Here it is kept in [ Party_store ] and used when the character is
; talked to or joins again. The portraits of a character who joins are
; loaded in the three palettes (status block, inventory, character screen).

	SECTION	Program,code

;*****************************************************************************
; [ Is a member present ? ]
;   IN : d7 - Member number {1...6} (.w)
;  OUT : ne - Present, eq - Empty place
; All registers are restored
;*****************************************************************************
Member_present:
	move.l	a0,-(sp)
	lea.l	Member_nrs-2,a0
	add.w	d7,a0
	add.w	d7,a0
	tst.w	(a0)
	movem.l	(sp)+,a0			; (flags stay)
	rts

; [ Count the members of the party ]
;  OUT : d0 - Number of members (.w)
; Changed registers : d0
Count_party:
	movem.l	d7/a0,-(sp)
	lea.l	Member_nrs,a0
	moveq.l	#0,d0
	moveq.l	#6-1,d7
.Loop:	tst.w	(a0)+
	beq.s	.Next
	addq.w	#1,d0
.Next:	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Add a party member ]
;   IN : [ Dialogue_data_ptr ] - Character data (.l)
;        [ Dialogue_char_nr ] - Character number (.w)
;        [ Dialogue_NPC_index ] - Index of the person in the map (.w)
; All registers are restored
; NOTE :
;   - From [ Add_party_member ] (DIALOGUE.S).
;*****************************************************************************
Add_party_member:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Member_nrs,a0		; Find free place
	moveq.l	#1,d6
	moveq.l	#6-1,d7
.Loop1:	tst.w	(a0)+
	beq.s	.Found1
	addq.w	#1,d6
	dbra	d7,.Loop1
	bra	.Exit			; All full !
.Found1:	move.w	Dialogue_char_nr,-2(a0)	; Insert character
	move.w	d6,d7
	jsr	Get_char_data		; Copy character data
	move.l	a1,a3
	move.l	Dialogue_data_ptr,a0
	move.w	#512/4-1,d0
.Copy:	move.l	(a0)+,(a1)+
	dbra	d0,.Copy
	move.w	Map_nr,d0			; Calculate CD bit number
	subq.w	#1,d0
	mulu.w	#Max_chars,d0
	add.w	Dialogue_NPC_index,d0
	cmp.w	#-1,Person_save_bit_pos(a3)	; Already has one ?
	bne.s	.Yes
	move.w	d0,Person_save_bit_pos(a3)	; No -> Store
.Yes:	moveq.l	#CD_bit_array,d1		; Set bit in CD array
	moveq.l	#1,d2
	jsr	Access_bit_array
	jsr	Get_CD_value		; Reset
	lea.l	Party_stored-1,a0		; (data is in the party now)
	add.w	Dialogue_char_nr,a0
	sf	(a0)
	lea.l	Names-16,a0		; Copy name
	move.w	d7,d0
	lsl.w	#4,d0
	add.w	d0,a0
	lea.l	Char_name(a3),a1
	moveq.l	#15-1,d0
.Name:	move.b	(a1)+,(a0)+
	dbra	d0,.Name
	clr.b	(a0)
	moveq.l	#0,d0			; Load portraits
	move.b	Portrait_nr(a3),d0
	move.w	d7,d3
	subq.w	#1,d3
	mulu.w	#34*2*8,d3
	move.l	#34*2*8,d1
	lea.l	Portraits,a1
	add.l	d3,a1
	move.l	#'PUI_',d2
	jsr	Load_person_file
	lea.l	Inv_portraits,a1
	add.l	d3,a1
	move.l	#'PT__',d2
	jsr	Load_person_file
	lea.l	Char_portraits,a1
	add.l	d3,a1
	move.l	#'PCH_',d2
	jsr	Load_person_file
	moveq.l	#0,d0			; Occupied battle order slots
	moveq.l	#1,d5
.Loop2:	cmp.w	d5,d7			; (not the new one)
	beq.s	.Next2
	exg	d5,d7
	jsr	Member_present
	exg	d5,d7
	beq.s	.Next2
	lea.l	Battle_order-1,a0
	move.b	0(a0,d5.w),d1
	bset	d1,d0
.Next2:	addq.w	#1,d5
	cmp.w	#6+1,d5
	bmi.s	.Loop2
	moveq.l	#12-1,d1			; Seek free slot
.Loop3:	btst	d1,d0
	beq.s	.Found2
	dbra	d1,.Loop3
.Found2:	lea.l	Battle_order-1,a0
	move.b	d1,0(a0,d7.w)
	jsr	Clear_member_status
	jsr	Show_arrival		; Show
	jsr	Force_status_update
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

;*****************************************************************************
; [ Remove a party member ]
;   IN : d7 - Member number {2...6} (.w)
; All registers are restored
; NOTE :
;   - From [ Remove_party_member ] (MAIN.S).
;*****************************************************************************
Remove_party_member:
	movem.l	d0-d2/d7/a0-a2,-(sp)
	jsr	Show_removal		; Show
	jsr	Get_char_data
	move.w	Person_save_bit_pos(a1),d0	; Clear bit in CD array
	cmp.w	#-1,d0
	beq.s	.No_bit
	moveq.l	#CD_bit_array,d1
	moveq.l	#0,d2
	jsr	Access_bit_array
	jsr	Get_CD_value		; Reset
.No_bit:	lea.l	Member_nrs-2,a0		; Get character number
	add.w	d7,a0
	add.w	d7,a0
	move.w	(a0),d0
	clr.w	(a0)			; Clear member number
	lea.l	Party_stored-1,a0		; Keep the data
	st	0(a0,d0.w)
	subq.w	#1,d0
	mulu.w	#512,d0
	lea.l	Party_store,a2
	add.l	d0,a2
	move.l	a1,a0
	move.w	#512/4-1,d0
.Copy:	move.l	(a0)+,(a2)+
	clr.l	-4(a0)			; (and clear)
	dbra	d0,.Copy
	move.w	#1<<Dead,Body_conditions(a1)	; (skipped as dead)
	lea.l	Names-16,a0		; Clear name
	move.w	d7,d0
	lsl.w	#4,d0
	clr.b	0(a0,d0.w)
	jsr	Clear_member_status
	jsr	Force_status_update		; Update
	movem.l	(sp)+,d0-d2/d7/a0-a2
	rts

; [ Clear the status display of a member ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
Clear_member_status:
	move.l	a0,-(sp)
	lea.l	Party_status_icons-1,a0
	clr.b	0(a0,d7.w)
	lea.l	Damage_timers-1,a0
	clr.b	0(a0,d7.w)
	lea.l	Char_damage-1,a0
	clr.b	0(a0,d7.w)
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Show a party member's arrival / removal ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From [ Show_arrival ] (DIALOGUE.S) and [ Show_removal ] (MAIN.S) :
;     the empty portrait moves down and away / down and over the portrait.
;*****************************************************************************
Show_arrival:
	movem.l	d0/d1,-(sp)
	moveq.l	#1,d0			; From 1 to 36
	moveq.l	#35+2,d1
	move.w	#20,Slide_ink
	jsr	Slide_empty_portrait
	movem.l	(sp)+,d0/d1
	rts

Show_removal:
	movem.l	d0/d1,-(sp)
	moveq.l	#1-34,d0			; From -33 to 1
	moveq.l	#2,d1
	move.w	#Red,Slide_ink
	jsr	Slide_empty_portrait
	movem.l	(sp)+,d0/d1
	rts

; [ Move the empty portrait over a portrait ]
;   IN : d0 - Start Y-coordinate (.w)
;        d1 - End Y-coordinate + 1 (.w)
;        d7 - Member number {1...6} (.w)
;        [ Slide_ink ] - Colour of the name (.w)
; All registers are restored
Slide_empty_portrait:
	movem.l	d0-d7/a0-a2,-(sp)
	move.w	d0,d3			; Y of the empty portrait
	move.w	d1,d4
	move.w	d7,d5
	subq.w	#1,d5			; Calculate X-coordinate
	mulu.w	#48,d5
	addi.w	#16,d5
	lea.l	Kill_CA,a0		; Make clip area
	move.w	d5,CA_X1(a0)
	move.w	#1,CA_Y1(a0)
	move.w	d5,CA_X2(a0)
	addi.w	#32-1,CA_X2(a0)
	move.w	#1+34-1,CA_Y2(a0)
	jsr	Push_CA
	lea.l	Portraits,a1		; Get portrait address
	move.w	d7,d0
	subq.w	#1,d0
	mulu.w	#34*2*8,d0
	add.l	d0,a1
	lea.l	Names-16,a2		; Get name
	move.w	d7,d0
	lsl.w	#4,d0
	add.w	d0,a2
	lea.l	Temp_name,a0		; (first 5 letters)
	moveq.l	#5-1,d0
.Copy:	move.b	(a2)+,(a0)+
	dbeq	d0,.Copy
	clr.b	(a0)
	moveq.l	#2,d6
	moveq.l	#34,d7
.Again:	move.w	d5,d0			; Display portrait
	moveq.l	#1,d1
	move.l	a1,a0
	jsr	Put_unmasked_block
	move.w	Slide_ink,Ink_colour	; Display name
	move.w	#Default_shadow,Shadow_colour
	movem.w	d0-d2,-(sp)
	addq.w	#2,d0
	moveq.l	#31,d1
	moveq.l	#30,d2
	lea.l	Temp_name,a0
	jsr	Print_centered_string
	movem.w	(sp)+,d0-d2
	move.w	d3,d1			; Display empty portrait
	lea.l	Empty_portrait,a0
	jsr	Put_masked_block
	jsr	Switch_screens		; Show
	addq.w	#1,d3			; Move down
	cmp.w	d4,d3			; Done ?
	blt.s	.Again
	jsr	Pop_CA
	movem.l	(sp)+,d0-d7/a0-a2
	rts

	SECTION	Fast_BSS,bss
Dialogue_char_nr:	ds.w 1
Dialogue_NPC_index:	ds.w 1			; Person / member number
Slide_ink:	ds.w 1
NPC_or_member:	ds.b 1
Joined:	ds.b 1
Left:	ds.b 1
Party_stored:	ds.b 16			; Data in Party_store ?
	even
Party_store:	ds.b 16*512
