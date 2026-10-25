; Proof of concept : the status block of the party (Atari ST)
;
; From DISPLAY.S and MAIN.S : the condition icons of the party members
; (switched every 2 seconds), the damage burst on the portrait, the death
; mask and the death of a party member. The status block is drawn into both
; screens, so a member that changed is redrawn in two frames.
;
; The active member is always member 1 in the proof of concept : when it
; dies, no new leader is chosen.

	SECTION	Program,code

Damage_frames	EQU	2*Damage_interval		; (50 frames per second)

;*****************************************************************************
; [ Update the status block ]
; All registers are restored
; NOTE :
;   - Like [ Update_status_block ], [ Update_damage_magic ] and
;     [ AutoIcon_switch ] (DISPLAY.S). Called once per frame by the map.
;*****************************************************************************
Update_status:
	movem.l	d0/d7/a0/a1,-(sp)
	move.w	VBL_counter,d0		; Is it time ?
	sub.w	AutoIcon_time,d0
	cmp.w	#AutoIcon_interval,d0
	bmi.s	.No_switch
	move.w	VBL_counter,AutoIcon_time
	jsr	AutoIcon_switch
.No_switch:	lea.l	Damage_timers,a0
	lea.l	Status_redraw,a1
	moveq.l	#1,d7
.Loop:	tst.b	(a1)			; Redraw ?
	beq.s	.No_redraw
	subq.b	#1,(a1)
	jsr	Redraw_member
.No_redraw:	tst.b	(a0)			; Damage ?
	beq.s	.Next
	subq.b	#1,(a0)			; Count down
	bne.s	.Show
	jsr	Force_status_update		; End -> erase
	bra.s	.Next
.Show:	moveq.l	#0,d0			; Show damage
	move.b	Char_damage-Damage_timers(a0),d0
	jsr	Display_damage
.Next:	addq.l	#1,a0			; Next member
	addq.l	#1,a1
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0/d7/a0/a1
	rts

; [ Redraw a member in both screens ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
Force_status_update:
	move.l	a0,-(sp)
	lea.l	Status_redraw,a0
	move.b	#2,-1(a0,d7.w)
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Redraw a party member in the status block ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - Like [ Display_portrait ] and [ Update_member_status ] (DISPLAY.S).
;*****************************************************************************
Redraw_member:
	movem.l	d0-d7/a0,-(sp)
	jsr	Display_portrait
	move.w	d7,d0			; Erase icon & bars
	subq.w	#1,d0
	mulu.w	#48,d0
	addi.w	#16+32,d0
	moveq.l	#0,d1
	moveq.l	#1,d6
	move.w	d7,d2
	moveq.l	#36,d7
	lea.l	Status_M,a0
	jsr	Put_unmasked_block
	move.w	d2,d7
	jsr	Get_char_data
	move.w	Body_conditions(a1),d0	; Dead ?
	andi.w	#Dead_mask,d0
	beq.s	.Alive
	moveq.l	#Dead_icon,d0		; Yes -> no bars
	bra.s	.Icon
.Alive:	jsr	Update_member_bars
	lea.l	Party_status_icons,a0
	moveq.l	#0,d0
	move.b	-1(a0,d7.w),d0
.Icon:	jsr	Display_status_icon
	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Automatic icon switching ]
; All registers are restored
; NOTE :
;   - From [ AutoIcon_switch ] (DISPLAY.S), without the overweight icon.
;*****************************************************************************
AutoIcon_switch:
	movem.l	d0-d3/d6/d7/a0-a3,-(sp)
	lea.l	Party_status_icons,a0
	lea.l	AutoIcon_counters,a3
	moveq.l	#1,d7
.Loop1:	jsr	Get_char_data
	move.w	Body_conditions(a1),d1
	move.w	d1,d2			; Dead ?
	andi.w	#Dead_mask,d2
	bne.s	.Next1
	move.w	(a3),d2			; Load counter
	addq.w	#1,d2			; Increase
	cmpi.w	#Nr_AutoIcons,d2
	bmi.s	.Ok1
	moveq.l	#0,d2
.Ok1:	moveq.l	#Nr_AutoIcons-1,d6
.Loop2:	move.b	.Bit_table(pc,d2.w),d3	; Get condition bit number
	bmi.s	.Next2			; (if any)
	btst	d3,d1			; Condition set ?
	bne.s	.Do_it
.Next2:	addq.w	#1,d2			; Next condition
	cmpi.w	#Nr_AutoIcons,d2
	bmi.s	.Ok2
	moveq.l	#0,d2
.Ok2:	dbra	d6,.Loop2
	moveq.l	#0,d2			; No icon
	bra.s	.Set
.Do_it:	move.w	d2,(a3)
	addi.w	#Lamed_icon,d2		; Set icon number
.Set:	cmp.b	(a0),d2			; Changed ?
	beq.s	.Next1
	move.b	d2,(a0)
	jsr	Force_status_update
.Next1:	addq.l	#1,a0			; Next member
	addq.l	#2,a3
	addq.w	#1,d7
	cmpi.w	#6+1,d7
	bmi.s	.Loop1
	movem.l	(sp)+,d0-d3/d6/d7/a0-a3
	rts

.Bit_table:
	dc.b Lamed,Poisoned,Petrified,Diseased
	dc.b Aging,Irritated,Mad,Asleep
	dc.b Panicked,Blind,-1,Stoned
	dc.b Exhausted
	even

;*****************************************************************************
; [ Display damage ]
;   IN : d0 - Amount of damage (.w)
;        d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From DISPLAY.S.
;*****************************************************************************
Display_damage:
	movem.l	d0-d7/a0,-(sp)
	move.w	d0,d2
	subq.w	#1,d7			; Calculate X-coordinate
	mulu.w	#48,d7
	addi.w	#16,d7
	move.w	d7,d4
	move.w	d4,d0			; Display damage burst
	moveq.l	#1,d1
	moveq.l	#2,d6
	moveq.l	#26,d7
	lea.l	Damage_star,a0
	jsr	Put_masked_block
	tst.w	d2			; Any damage ?
	beq.s	.Exit
	move.w	#White,Ink_colour		; Print damage
	move.w	#Default_shadow,Shadow_colour
	moveq.l	#0,d0
	move.w	d2,d0
	moveq.l	#2,d7
	lea.l	Number,a0
	jsr	DecL_convert
	move.w	d4,d0
	addi.w	#11,d0
	moveq.l	#11,d1
	moveq.l	#12,d2
	lea.l	Number,a0
	jsr	Print_centered_string
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Do damage to a party member ]
;   IN : d0 - Amount of damage (.w)
;        d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From MAIN.S.
;*****************************************************************************
Do_damage:
	movem.l	d1/a0/a1,-(sp)
	jsr	Get_char_data
	move.w	Life_points(a1),d1		; Do the damage
	sub.w	d0,d1
	bgt.s	.Ok			; Dead ?
	jsr	Kill_member		; Kill !
	bra.s	.Exit
.Ok:	move.w	d1,Life_points(a1)		; Store new LP
	lea.l	Char_damage,a0		; Start damage
	move.b	d0,-1(a0,d7.w)
	lea.l	Damage_timers,a0
	move.b	#Damage_frames,-1(a0,d7.w)
	jsr	Force_status_update
.Exit:	movem.l	(sp)+,d1/a0/a1
	rts

;*****************************************************************************
; [ Kill party member ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From MAIN.S.
;*****************************************************************************
Kill_member:
	movem.l	d0/a0/a1,-(sp)
	jsr	Get_char_data
	move.w	Body_conditions(a1),d0	; Kill !
	bset	#Dead,d0
	move.w	d0,Body_conditions(a1)
	clr.w	Life_points(a1)
	lea.l	Damage_timers,a0		; (no damage burst)
	clr.b	-1(a0,d7.w)
	jsr	Show_death		; Show
	jsr	Redraw_member		; (in both screens)
	jsr	Switch_screens
	jsr	Redraw_member
	lea.l	Status_redraw,a0
	clr.b	-1(a0,d7.w)
	movem.l	(sp)+,d0/a0/a1
	rts

;*****************************************************************************
; [ Show party member's death ]
;   IN : d7 - Member number {1...6} (.w)
; All registers are restored
; NOTE :
;   - From MAIN.S : the portrait moves down and the death mask comes from
;     above.
;*****************************************************************************
Show_death:
	movem.l	d0-d7/a0/a1,-(sp)
	move.w	d7,Death_member
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
	moveq.l	#1,d3			; Face Y
	moveq.l	#1-34,d4			; Skull Y
	moveq.l	#2,d6
	moveq.l	#34,d7
.Again:	move.w	d5,d0			; Erase area
	moveq.l	#1,d1
	move.w	d0,d2
	addi.w	#32-1,d2
	move.l	d3,-(sp)
	moveq.l	#1+34-1,d3
	move.l	d4,-(sp)
	moveq.l	#25,d4
	jsr	Draw_box
	move.l	(sp)+,d4
	move.l	(sp)+,d3
	move.w	d3,d1			; Display portrait
	move.l	a1,a0
	jsr	Put_masked_block
	move.w	d4,d1			; Display skull
	lea.l	Death_mask,a0
	jsr	Put_masked_block
	jsr	.Name
	jsr	Switch_screens		; Show
	addq.w	#2,d3			; Move down
	addq.w	#1,d4
	cmp.w	#1+1,d4			; Done ?
	blt.s	.Again
	jsr	Pop_CA
	movem.l	(sp)+,d0-d7/a0/a1
	rts

; Print the first five letters of the name
.Name:	movem.l	d0-d2/d7/a0/a1,-(sp)
	move.w	Death_member,d7
	lea.l	Names,a0
	subq.w	#1,d7
	lsl.w	#4,d7
	add.w	d7,a0
	lea.l	Temp_name,a1
	moveq.l	#5-1,d7
.Loop:	move.b	(a0)+,(a1)+
	dbeq	d7,.Loop
	clr.b	(a1)
	move.w	#Lighter_blue,Ink_colour
	move.w	#Default_shadow,Shadow_colour
	move.w	d5,d0
	addq.w	#2,d0
	moveq.l	#31,d1
	moveq.l	#30,d2
	lea.l	Temp_name,a0
	jsr	Print_centered_string
	movem.l	(sp)+,d0-d2/d7/a0/a1
	rts

	SECTION	Fast_BSS,bss
AutoIcon_time:	ds.w 1
Death_member:	ds.w 1
AutoIcon_counters:	ds.w 6
Party_status_icons:	ds.b 6
Status_redraw:	ds.b 6			; Number of screens to redraw
Char_damage:	ds.b 6
Damage_timers:	ds.b 6
	even
Kill_CA:	ds.w 4
Damage_star:	ds.b 2*8*26
Death_mask:	ds.b 2*8*34
	even
