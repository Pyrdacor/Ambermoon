; Reverse combat magic : monster to party
; Written by J.Horneman (In Tune With The Universe)
; Start : 4-5-1993

	SECTION	Program,code
;*****************************************************************************
; [ Spell handlers - COMBAT / MONSTERS ]
;   IN : a0 - Pointer to casting participant data (.l)
; No registers are restored
;*****************************************************************************
; *** Magical projectiles ***
CMMagical_projectiles:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	.Do,a2			; Do all targets
	jsr	Do_all_combat_targets
.Exit:	rts

; [ Do Magical projectile ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
	movem.l	a0/a1,-(sp)
; ---------- Create magic missile -----------------
	jsr	Determine_COMOB_flip	; Determine flip
	spl	d0
	move.w	d0,-(sp)
	exg	a1,a0			; Get source coordinates
	jsr	Get_3D_part_coordinates
	move.w	d0,d3			; Copy
	move.w	d1,d4
	move.w	d2,d5
	move.l	a1,a0			; Get target coordinates
	jsr	Get_3D_part_coordinates
	jsr	Add_COMOB			; Create COMOB
	move.w	d3,COMOB_3D_X(a0)		; Set coordinates
	move.w	d4,COMOB_3D_Y(a0)
	move.w	d5,COMOB_3D_Z(a0)
	moveq.l	#Projectile_speed,d6	; Process vector
	jsr	Process_COMOB_vector
	move.w	#32,COMOB_Display_width(a0)	; Initialize COMOB
	move.w	#32,COMOB_Display_height(a0)
	move.w	#32,COMOB_Source_width(a0)
	move.w	#32,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Missile_fro_FXGFX,COMOB_Gfx_base(a0)
	move.w	(sp)+,d3			; Left or right ?
	tst.b	d3
	beq.s	.Right
	bset	#0,COMOB_Mirror_flags(a0)	; Flip
; ---------- Build up missile ---------------------
.Right:	moveq.l	#4-1,d6			; Show build-up
.Loop1:	jsr	Update_combat_screen	; Show
	jsr	Update_combat_screen
	jsr	Update_combat_screen
	jsr	Update_combat_screen
	addq.w	#1,COMOB_Frame(a0)
	bset	#COMOB_update,COMOB_Flags(a0)
	dbra	d6,.Loop1
; ---------- Move towards targets -----------------
	move.w	d0,COMOB_3D_vector_X(a0)	; Set vector
	move.w	d1,COMOB_3D_vector_Y(a0)
	move.w	d2,COMOB_3D_vector_Z(a0)
	moveq.l	#8,d0
	move.w	#4,COMOB_Frame(a0)
	bra.s	.Entry2
.Loop2:	jsr	Update_combat_screen	; Show
	sub.w	#4,COMOB_Frame(a0)
	jsr	Circle_COMOB
	add.w	#4,COMOB_Frame(a0)
.Entry2:	dbra	d7,.Loop2
; ---------- The end ------------------------------
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,a0/a1
	jsr	Handle_magical_defense	; Defend ?
	bne.s	.Exit2
	Get	Part_handle(a1),a2		; Get caster's level
	moveq.l	#0,d0
	move.b	Level_nr(a2),d0
	Free	Part_handle(a1)
	jsr	Do_combat_damage		; Do damage !
	move.l	a1,a0			; Process
	jsr	Process_damage
.Exit2:	rts

; *** Dissolve victim ***
CMDissolve_victim:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	.Do,a2			; Do all targets
	jsr	Do_all_combat_targets
.Exit:	rts

; [ Do Dissolve victim ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
	jsr	Handle_magical_defense	; Defend ?
	bne	.Exit2
	Get	Part_handle(a0),a2		; Get damage
	move.w	Life_points+Maximum(a2),d0
	Free	Part_handle(a0)
	move.l	a0,-(sp)			; Process damage
	move.l	a1,a0
	jsr	Process_damage
	move.l	(sp)+,a0
	Get	Part_handle(a0),a1		; Kill !
	move.w	Body_conditions(a1),d0
	bset	#Dead,d0
	move.w	d0,Body_conditions(a1)
	clr.w	Life_points(a1)
	Free	Part_handle(a0)
.Exit2:	rts

; *** Mudsling ***
CMMudsling:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	.Do,a2			; Do all targets
	jsr	Do_all_combat_targets
.Exit:	rts

; [ Do Mudsling ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
; ---------- Create rock --------------------------
	jsr	Get_3D_part_coordinates
	move.l	a0,a2
	jsr	Add_COMOB
	move.w	d0,COMOB_3D_X(a0)
	add.w	d1,d1
	move.w	d1,COMOB_3D_Y(a0)
	move.w	d2,COMOB_3D_Z(a0)
	move.w	#32,COMOB_Display_width(a0)
	move.w	#16,COMOB_Display_height(a0)
	move.w	#32,COMOB_Source_width(a0)
	move.w	#16,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Rock_FXGFX,COMOB_Gfx_base(a0)
; ---------- Fade rock in as silhouette -----------
	lea.l	Glow_colours,a3
	moveq.l	#21-1,d7
.Loop1:	move.w	(a3)+,COMOB_Colour(a0)	; Set stone colour
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop1
	move.w	#-1,COMOB_Colour(a0)	; No silhouette
; ---------- Drop rock ----------------------------
	move.w	#-1,COMOB_3D_vector_Y(a0)	; Down
	moveq.l	#7-1,d7			; Show
.Loop2:	jsr	Update_combat_screen
	subq.w	#1,COMOB_3D_vector_Y(a0)
	dbra	d7,.Loop2
; ---------- Remove rock --------------------------
	lea.l	Glow_colours+20*2,a3
	moveq.l	#7-1,d7
.Loop5:	move.w	(a3),COMOB_Colour(a0)	; Set stone colour
	subq.l	#6,a3
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop5
	jsr	Delete_COMOB		; Remove rock
; ---------- Do damage to -------------------------
	move.l	a2,a0
	jsr	Do_destruction_damage
.Exit2:	rts

; *** Rockfall ***
CMRockfall:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	.Do,a2			; Do all targets
	jsr	Do_all_combat_targets
.Exit:	rts

; [ Do Rockfall ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
; ---------- Create rock --------------------------
	jsr	Get_3D_part_coordinates
	move.l	a0,a2
	jsr	Add_COMOB
	move.w	d0,COMOB_3D_X(a0)
	add.w	d1,d1
	move.w	d1,COMOB_3D_Y(a0)
	move.w	d2,COMOB_3D_Z(a0)
	move.w	#64,COMOB_Display_width(a0)
	move.w	#32,COMOB_Display_height(a0)
	move.w	#32,COMOB_Source_width(a0)
	move.w	#16,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Rock_FXGFX,COMOB_Gfx_base(a0)
; ---------- Fade rock in as silhouette -----------
	lea.l	Glow_colours,a3
	moveq.l	#21-1,d7
.Loop1:	move.w	(a3)+,COMOB_Colour(a0)	; Set stone colour
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop1
	move.w	#-1,COMOB_Colour(a0)	; No silhouette
; ---------- Drop rock ----------------------------
	move.w	#-1,COMOB_3D_vector_Y(a0)	; Down
	moveq.l	#7-1,d7			; Show
.Loop2:	jsr	Update_combat_screen
	subq.w	#1,COMOB_3D_vector_Y(a0)
	dbra	d7,.Loop2
; ---------- Remove rock --------------------------
	lea.l	Glow_colours+20*2,a3
	moveq.l	#7-1,d7
.Loop5:	move.w	(a3),COMOB_Colour(a0)	; Set stone colour
	subq.l	#6,a3
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop5
	jsr	Delete_COMOB		; Remove rock
; ---------- Do damage ----------------------------
	move.l	a2,a0
	jsr	Do_destruction_damage
.Exit2:	rts

; *** Earthquake ***
CMEarthquake:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	moveq.l	#0,d0			; Get left X-coordinate
	moveq.l	#2,d1
	jsr	Calculate_3D_coordinates
	move.w	d0,d3
	moveq.l	#5,d0			; Get right X-coordinate
	moveq.l	#2,d1
	jsr	Calculate_3D_coordinates
	sub.w	d3,d0			; Calculate width
	addi.w	#70,d0
; ---------- Create earthmass ---------------------
	move.l	a0,a1
	jsr	Add_COMOB
	clr.w	COMOB_3D_X(a0)
	clr.w	COMOB_3D_Y(a0)
	addi.w	#21*5-8,d1
	move.w	d1,COMOB_3D_Z(a0)
	subi.w	#8*21-20,d0
	move.w	d0,COMOB_Display_width(a0)
	move.w	#64,COMOB_Display_height(a0)
	move.w	#64,COMOB_Source_width(a0)
	move.w	#32,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Earthmass_FXGFX,COMOB_Gfx_base(a0)
; ---------- Fade mass in as silhouette -----------
	move.w	#-5,COMOB_3D_vector_Z(a0)	; Forward
	lea.l	Glow_colours,a3
	moveq.l	#21-1,d7
.Loop1:	move.w	(a3)+,COMOB_Colour(a0)	; Set colour
	addq.w	#8,COMOB_Display_width(a0)
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop1
	move.w	#-1,COMOB_Colour(a0)	; No silhouette
; ---------- Move mass forward --------------------
	move.w	#-20,COMOB_3D_vector_Z(a0)	; Forward
.Again:	jsr	Update_combat_screen	; Show
	jsr	Random			; Shake it, baby !
	andi.w	#$0007,d0
	subq.w	#3,d0
	move.w	d0,Vertical_screen_offset
	jsr	My_vsync
	cmp.w	#-200,COMOB_3D_Z(a0)	; End ?
	bgt.s	.Again
	clr.w	Vertical_screen_offset	; Stop
; ---------- Move mass down -----------------------
	move.w	#-5,COMOB_3D_vector_Y(a0)	; Down
	clr.w	COMOB_3D_vector_Z(a0)
	moveq.l	#11-1,d7
.Loop2:	jsr	Update_combat_screen
	dbra	d7,.Loop2
	jsr	Delete_COMOB		; Remove mass
; ---------- Do damage ----------------------------
	move.l	a1,a0			; Do all targets
	lea.l	Do_destruction_damage,a2
	jsr	Do_all_combat_targets
.Exit:	rts

; *** Winddevil ***
CMWinddevil:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	.Do,a2
	jsr	Do_all_combat_targets
.Exit:	rts

; [ Do Winddevil ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
; ---------- Create whirlwind ---------------------
	jsr	Get_3D_part_coordinates
	move.l	a0,a2
	jsr	Add_COMOB
	move.w	d0,COMOB_3D_X(a0)
	clr.w	COMOB_3D_Y(a0)
	move.w	d2,COMOB_3D_Z(a0)
	move.w	#40,COMOB_Display_width(a0)
	move.w	#80,COMOB_Display_height(a0)
	move.w	#32,COMOB_Source_width(a0)
	move.w	#64,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Whirlwind_FXGFX,COMOB_Gfx_base(a0)
; ---------- Fade in as silhouette ----------------
	lea.l	Glow_colours,a4
	moveq.l	#21/3-1,d7
.Loop1:	move.w	(a4),COMOB_Colour(a0)	; Set colour
	addq.l	#6,a4
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop1
	move.w	#-1,COMOB_Colour(a0)	; No silhouette
; ---------- Animate whirlwind --------------------
	lea.l	Oscillation,a4
	moveq.l	#4,d0
	moveq.l	#0,d1
	moveq.l	#16-1,d7
.Loop2:	jsr	Update_combat_screen	; Show
	move.b	0(a4,d1.w),d2		; Oscillate
	ext.w	d2
	add.w	d2,COMOB_Display_width(a0)
	move.b	1(a4,d1.w),d2
	ext.w	d2
	add.w	d2,COMOB_Display_height(a0)
	jsr	Circle_COMOB		; Animate whirlwind
	addq.w	#1,d1			; Increase index
	andi.w	#$0007,d1
	dbra	d7,.Loop2
; ---------- Remove whirlwind ---------------------
	move.w	COMOB_Display_width(a0),d0	; Get shrink factors
	lsr.w	#3,d0
	move.w	COMOB_Display_height(a0),d1
	lsr.w	#3,d1
	moveq.l	#7-1,d7
.Loop3:	sub.w	d0,COMOB_Display_width(a0)	; Shrink
	sub.w	d1,COMOB_Display_height(a0)
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop3
	jsr	Delete_COMOB		; Remove
; ---------- Do damage ----------------------------
	move.l	a2,a0
	jsr	Do_destruction_damage
.Exit2:	rts

; *** Windhowler ***
CMWindhowler:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	.Do,a2
	jsr	Do_all_combat_targets
.Exit:	rts

; [ Do Windhowler ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
; ---------- Create whirlwind ---------------------
	jsr	Get_3D_part_coordinates
	move.l	a0,a2
	jsr	Add_COMOB
	move.w	d0,COMOB_3D_X(a0)
	clr.w	COMOB_3D_Y(a0)
	move.w	d2,COMOB_3D_Z(a0)
	move.w	#48,COMOB_Display_width(a0)
	move.w	#96,COMOB_Display_height(a0)
	move.w	#32,COMOB_Source_width(a0)
	move.w	#64,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Whirlwind_FXGFX,COMOB_Gfx_base(a0)
; ---------- Fade in as silhouette ----------------
	lea.l	Glow_colours,a4
	moveq.l	#21/3-1,d7
.Loop1:	move.w	(a4),COMOB_Colour(a0)	; Set colour
	addq.l	#6,a4
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop1
	move.w	#-1,COMOB_Colour(a0)	; No silhouette
; ---------- Animate whirlwind --------------------
	lea.l	Oscillation,a4
	moveq.l	#4,d0
	moveq.l	#0,d1
	moveq.l	#24-1,d7
.Loop2:	jsr	Update_combat_screen	; Show
	move.b	0(a4,d1.w),d2		; Oscillate
	ext.w	d2
	asl.w	#1,d2
	add.w	d2,COMOB_Display_width(a0)
	move.b	1(a4,d1.w),d2
	ext.w	d2
	asl.w	#1,d2
	add.w	d2,COMOB_Display_height(a0)
	jsr	Circle_COMOB		; Animate whirlwind
	addq.w	#1,d1			; Increase index
	andi.w	#$0007,d1
	dbra	d7,.Loop2
; ---------- Remove whirlwind ---------------------
	move.w	COMOB_Display_width(a0),d0	; Get shrink factors
	lsr.w	#3,d0
	move.w	COMOB_Display_height(a0),d1
	lsr.w	#3,d1
	moveq.l	#7-1,d7
.Loop3:	sub.w	d0,COMOB_Display_width(a0)	; Shrink
	sub.w	d1,COMOB_Display_height(a0)
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop3
	jsr	Delete_COMOB		; Remove
; ---------- Do damage ----------------------------
	move.l	a2,a0
	jsr	Do_destruction_damage
.Exit2:	rts

; *** Whirlwind ***
CMWhirlwind:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
; ---------- Create whirlwind ---------------------
	move.l	a0,-(sp)
	moveq.l	#0,d0			; Get start coordinates
	moveq.l	#0,d1
	jsr	Calculate_3D_coordinates
	subq.w	#2,d1
	jsr	Add_COMOB			; Create whirlwind
	move.w	d0,COMOB_3D_X(a0)
	clr.w	COMOB_3D_Y(a0)
	move.w	d1,COMOB_3D_Z(a0)
	move.w	#48,COMOB_Display_width(a0)
	move.w	#96,COMOB_Display_height(a0)
	move.w	#32,COMOB_Source_width(a0)
	move.w	#64,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Whirlwind_FXGFX,COMOB_Gfx_base(a0)
	move.l	a0,a3
	move.l	(sp)+,a0
; ---------- Fade in as silhouette ----------------
	lea.l	Glow_colours,a4
	moveq.l	#21-1,d7
.Loop1:	move.w	(a4)+,COMOB_Colour(a3)	; Set colour
	bset	#COMOB_update,COMOB_Flags(a3)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop1
	move.w	#-1,COMOB_Colour(a3)	; No silhouette
	move.l	a3,FXGFX_workspace		; Store
; ---------- Do -----------------------------------
	lea.l	.Do,a2
	jsr	Do_all_combat_targets
; ---------- Remove whirlwind ---------------------
	move.w	COMOB_Display_width(a3),d0	; Get shrink factors
	lsr.w	#3,d0
	move.w	COMOB_Display_height(a3),d1
	lsr.w	#3,d1
	moveq.l	#7-1,d7
.Loop2:	sub.w	d0,COMOB_Display_width(a3)	; Shrink
	sub.w	d1,COMOB_Display_height(a3)
	bset	#COMOB_update,COMOB_Flags(a3)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop2
	move.l	a3,a0			; Remove
	jsr	Delete_COMOB
.Exit:	rts

; [ Do Whirlwind ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
; ---------- Move whirlwind to COMOB --------------
	move.l	FXGFX_workspace,a3
	jsr	Get_3D_part_coordinates	; Get target coordinates
	moveq.l	#0,d1
	move.w	#-250,d2
	move.w	COMOB_3D_X(a3),d3		; Get source coordinates
	moveq.l	#0,d4
	move.w	COMOB_3D_Z(a3),d5
	moveq.l	#Projectile_speed/2,d6	; Get movement vector
	jsr	Process_COMOB_vector
	move.w	d0,COMOB_3D_vector_X(a3)	; Set vector
	clr.w	COMOB_3D_vector_Y(a3)
	move.w	d2,COMOB_3D_vector_Z(a3)
	move.l	a0,a2			; Juggle registers
	move.l	a3,a0
	moveq.l	#4,d0			; Show movement
	bra.s	.Entry3
.Loop3:	jsr	Update_combat_screen
	jsr	Circle_COMOB
.Entry3:	dbra	d7,.Loop3
	clr.w	COMOB_3D_vector_X(a0)	; Stop movement
	clr.w	COMOB_3D_vector_Z(a0)
; ---------- Animate whirlwind --------------------
	lea.l	Oscillation,a4
	moveq.l	#4,d0
	moveq.l	#0,d1
	moveq.l	#8-1,d7
.Loop4:	jsr	Update_combat_screen	; Show
	move.b	0(a4,d1.w),d2		; Oscillate
	ext.w	d2
	asl.w	#1,d2
	add.w	d2,COMOB_Display_width(a0)
	move.b	1(a4,d1.w),d2
	ext.w	d2
	asl.w	#1,d2
	add.w	d2,COMOB_Display_height(a0)
	jsr	Circle_COMOB		; Animate whirlwind
	addq.w	#1,d1			; Increase index
	andi.w	#$0007,d1
	dbra	d7,.Loop4
; ---------- Do damage ----------------------------
	move.l	a2,a0
	jsr	Do_destruction_damage
.Exit2:	rts

	FINGERPRINT

; *** Waterfall ***
CMWaterfall:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	lea.l	.Do,a2			; Do all targets
	jsr	Do_all_combat_targets
.Exit:	rts

; [ Do Waterfall ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
; ---------- Create watermass ---------------------
	jsr	Get_3D_part_coordinates
	move.l	a0,a2
	jsr	Add_COMOB
	move.w	d0,COMOB_3D_X(a0)
	add.w	d1,d1
	move.w	d1,COMOB_3D_Y(a0)
	move.w	d2,COMOB_3D_Z(a0)
	move.w	#32,COMOB_Display_width(a0)
	move.w	#32,COMOB_Display_height(a0)
	move.w	#64,COMOB_Source_width(a0)
	move.w	#32,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Watermass_FXGFX,COMOB_Gfx_base(a0)
; ---------- Fade water in as silhouette ----------
	lea.l	Glow_colours,a3
	moveq.l	#21-1,d7
.Loop1:	move.w	(a3)+,COMOB_Colour(a0)	; Set stone colour
	bset	#COMOB_update,COMOB_Flags(a0)
	jsr	Update_combat_screen	; Show
	dbra	d7,.Loop1
	move.w	#-1,COMOB_Colour(a0)	; No silhouette
; ---------- Drop watermass -----------------------
	move.w	#-1,COMOB_3D_vector_Y(a0)	; Down
	moveq.l	#11-1,d7
.Loop2:	jsr	Update_combat_screen	; Show
	subq.w	#1,COMOB_3D_vector_Y(a0)	; Faster!
	addq.w	#2,COMOB_Display_height(a0)	; Longer!
	subq.w	#2,COMOB_3D_Y(a0)
	dbra	d7,.Loop2
	clr.w	COMOB_3D_vector_Y(a0)	; Squash
	moveq.l	#15-1,d7
.Loop3:	jsr	Update_combat_screen	; Show
	move.w	COMOB_Display_height(a0),d1	; Flatter!
	subi.w	#11,d1
	cmp.w	#3,d1
	bmi.s	.Skip
	move.w	d1,COMOB_Display_height(a0)
.Skip:	add.w	#11,COMOB_Display_width(a0)	; Wider!
	bset	#COMOB_update,COMOB_Flags(a0)
	dbra	d7,.Loop3
	jsr	Delete_COMOB		; Remove watermass
; ---------- Do damage ----------------------------
	move.l	a2,a0
	jsr	Do_destruction_damage
.Exit2:	rts

; *** Iceshower ***
CMIceshower:
	jsr	Handle_spell		; Handle spell
	bne	.Exit
	movem.l	a0/a1,-(sp)
	move.w	#$019,d0			; Fade to ice
	moveq.l	#2,d7
	jsr	Fade_combat_palette
; ---------- Create ice-balls ---------------------
	lea.l	FXGFX_workspace,a2
	moveq.l	#8-1,d7
.Loop1:	jsr	Add_COMOB			; Create
	move.l	a0,(a2)+
	jsr	Random			; Set X- and Z-coordinates
	mulu.w	#Combat_row_width,d0
	swap	d0
	subi.w	#Combat_row_width/2,d0
	move.w	d0,COMOB_3D_X(a0)
	jsr	Random
	andi.w	#$007f,d0
	addi.w	#100,d0
	move.w	d0,COMOB_3D_Z(a0)
	jsr	Random			; Set Y-coordinate
	andi.w	#$003f,d0
	addi.w	#10,d0
	move.w	d0,COMOB_3D_Y(a0)
	jsr	Random			; Set Z-vector
	andi.w	#$000f,d0
	addi.w	#24,d0
	neg.w	d0
	move.w	d0,COMOB_3D_vector_Z(a0)
	jsr	Random			; Set size
	andi.w	#$000f,d0
	addi.w	#16,d0
	move.w	d0,COMOB_Display_width(a0)
	move.w	d0,COMOB_Display_height(a0)
	jsr	Random			; Set mirror flags
	btst	#5,d0
	beq.s	.Zero
	bset	#0,COMOB_Mirror_flags(a0)
.Zero:	move.w	#16,COMOB_Source_width(a0)	; Set other data
	move.w	#16,COMOB_Source_height(a0)
	move.b	FXGFX_handle,COMOB_Gfx_handle(a0)
	move.l	#Iceball_FXGFX,COMOB_Gfx_base(a0)
	dbra	d7,.Loop1
; ---------- Show ---------------------------------
	move.w	#$019,d0			; Fade to ice
	moveq.l	#2,d7
	jsr	Fade_combat_palette
	moveq.l	#24-1,d6
.Loop2:	jsr	Update_combat_screen	; Show
	dbra	d6,.Loop2
; ---------- Remove ice-balls ---------------------
	lea.l	FXGFX_workspace,a1
	moveq.l	#8-1,d7
.Loop3:	move.l	(a1)+,a0
	jsr	Delete_COMOB
	dbra	d7,.Loop3
; ----------- Freeze ------------------------------
	jsr	Restore_combat_palette	; Fade back
	movem.l	(sp)+,a0/a1
	lea.l	.Do,a2			; Do all targets
	jsr	Do_all_combat_targets
	jsr	Update_combat_screen	; Update
.Exit:	rts

; [ Do Iceshower effects ]
;   IN : a0 - Pointer to victim's participant data (.l)
;        a1 - Pointer to caster's participant data (.l)
; No registers are restored
.Do:
	jsr	Freeze_participant
	jmp	Do_destruction_damage

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
	SECTION	Fast_DATA,data
; ********** Monster magic ************************
Monster_comma_class_ptrs:
	dc.l 0,.Class_1_ptrs,0,.Class_3_ptrs
	dc.l 0,0,0

.Class_1_ptrs:
	dc.l 0,0,0,0
	dc.l 0,CGhost_weapon,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,CLP_stealer
	dc.l CPP_stealer,0
.Class_3_ptrs:
	dc.l CMMagical_projectiles,CMMagical_projectiles,CCondition,CCondition
	dc.l CCondition,CCondition,CCondition,CCondition
	dc.l CCondition,CCondition,CCondition,CCondition
	dc.l CCondition,CMDissolve_victim,CMMudsling,CMRockfall
	dc.l CEarthslide,CMEarthquake,CMWinddevil,CMWindhowler
	dc.l CThunderbolt,CMWhirlwind,CFirebeam,CFireball
	dc.l CFirestorm,CFirecolumn,CMWaterfall,CIceball
	dc.l CIcestorm,CMIceshower
