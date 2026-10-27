; Proof of concept : combat display, monster logic and end of combat (Atari ST)
;
; From COMBAT/COMOBS.S, COMBAT/COMBAT_M.S, COMBAT/TACTIC.S, COMBAT/MONSTER_.S
; and COMBAT/APRES.S.
;
; The COMbat OBjects (monsters and effects) are projected like in the
; original. The original draws them with the blitter into a zoom screen and
; only updates the changed areas. Here the combat window is rebuilt in every
; frame : the background is copied and the COMOBs are drawn from far to near
; with [ Draw_zoom ], which scales the ST graphics (4 planes) on the fly : a
; line of the source is unpacked into bytes (one per pixel) and the scaled
; line is packed into the planes again, 8 pixels at a time.

	SECTION	Program,code

Combat_PA_X1	EQU	5			; Print area of layout 4
Combat_PA_X2	EQU	88
Combat_PA_Y1	EQU	139
Combat_PA_Y2	EQU	194
Combat_ink_party	EQU	White
Combat_ink_monster	EQU	Light_red
Battle_order	EQU	Savegame+$35e4		; (after Door_open)
; Offsets in COMBFX.BIN after the conversion (ST, 4 planes)
Blood_FX	EQU	0			; 32x32, 4 frames
Scratches_FX	EQU	2048			; 32x32, 4 frames
Slash_FX	EQU	4096			; 16x43, 3 frames
Explosion_FX	EQU	5128			; 48x59, 14 frames
Tactic_icon_gfx	EQU	36*2*8			; (after the weapons)
; Format texts
Attack_txt	EQU	17
Attack2_txt	EQU	18
Broken_txt	EQU	19
Hit_txt	EQU	20
EP_txt	EQU	21
Level_txt	EQU	16

;*****************************************************************************
; [ COMOB management ]
;*****************************************************************************
; [ Initialize COMOBs ]
; All registers are restored
Init_COMOBs:
	movem.l	d7/a0,-(sp)
	lea.l	COMOB_table,a0
	move.w	#Max_COMOBs*Co_size/2-1,d7
.Clear:	clr.w	(a0)+
	dbra	d7,.Clear
	movem.l	(sp)+,d7/a0
	rts

; [ Add a COMOB ]
;  OUT : a0 - Pointer to new COMOB data (.l)
; Changed registers : a0
Add_COMOB:
	move.l	d7,-(sp)
	lea.l	COMOB_table,a0		; Find free slot
	moveq.l	#Max_COMOBs-1,d7
.Loop:	tst.b	Co_flags(a0)
	beq.s	.Found
	lea.l	Co_size(a0),a0
	dbra	d7,.Loop
	lea.l	Spare_COMOB,a0		; (none free : never drawn)
.Found:	move.l	a0,-(sp)			; Clear
	moveq.l	#Co_size/2-1,d7
.Clear:	clr.w	(a0)+
	dbra	d7,.Clear
	move.l	(sp)+,a0
	move.b	#1,Co_flags(a0)		; Present
	move.l	(sp)+,d7
	rts

; [ Delete a COMOB ]
;   IN : a0 - Pointer to COMOB data (.l)
; All registers are restored
Delete_COMOB:
	clr.b	Co_flags(a0)
	rts

; [ Do a circle animation on a COMOB ]
;   IN : d0 - Number of animation frames (.w)
;        a0 - Pointer to COMOB data (.l)
; All registers are restored
Circle_COMOB:
	move.l	d1,-(sp)
	move.w	Co_frame(a0),d1		; Next frame
	addq.w	#1,d1
	cmp.w	d0,d1			; Last frame ?
	bmi.s	.Ok
	moveq.l	#0,d1			; Yes -> Back to start
.Ok:	move.w	d1,Co_frame(a0)
	move.l	(sp)+,d1
	rts

; [ Initialize the COMOB of a monster ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are restored
Init_monster_COMOB:
	movem.l	d0/d1/a0-a2,-(sp)
	move.l	a0,a1
	move.l	Cp_original(a1),a2
	jsr	Add_COMOB
	move.w	Cpart_X(a1),d0		; Store 3D coordinates
	move.w	Cpart_Y(a1),d1
	jsr	Calculate_3D_coordinates
	move.w	d0,Co_3D_X(a0)
	move.w	d1,Co_3D_Z(a0)
	move.w	Monster_display_width(a2),Co_disp_width(a0)
	move.w	Monster_display_height(a2),Co_disp_height(a0)
	move.w	Monster_width(a2),Co_src_width(a0)
	move.w	Monster_height(a2),Co_src_height(a0)
	moveq.l	#0,d0
	tst.b	Anim_frame+Appear_anim-1(a2)	; Appear animation ?
	beq.s	.No
	move.b	Anim_dat+(Appear_anim-1)*32(a2),d0	; Yes -> Start frame
	bra.s	.Store
.No:	move.b	Anim_dat(a2),d0		; No -> Default frame
.Store:	move.w	d0,Co_frame(a0)
	move.b	d0,Part_default_frame(a1)
	move.l	Cp_gfx(a1),Co_gfx(a0)
	move.l	a0,Cpart_COMOB_ptr(a1)
	movem.l	(sp)+,d0/d1/a0-a2
	rts

;*****************************************************************************
; [ Calculate 3D coordinates ]
;   IN : d0 - Tactical X-coordinate (.w)
;        d1 - Tactical Y-coordinate / -1 = party (.w)
;  OUT : d0 - 3D X-coordinate (.w)
;        d1 - 3D Z-coordinate (.w)
; Changed registers : d0,d1
; NOTE :
;   - From COMBAT_M.S.
;*****************************************************************************
Calculate_3D_coordinates:
	cmp.w	#-1,d1			; Monster or party ?
	beq.s	.Party
	subq.w	#3,d0			; Calculate X
	add.w	d0,d0
	addq.w	#1,d0
	muls.w	#40/2,d0
	subq.w	#2,d1			; Calculate Z
	neg.w	d1
	asl.w	#7,d1
	rts
.Party:	subq.w	#3,d0			; Calculate X
	add.w	d0,d0
	addq.w	#1,d0
	lsl.w	#3,d0
	move.w	#-256,d1			; Set Z
	rts

; [ Get the 3D coordinates of a participant ]
;   IN : a0 - Pointer to participant data (.l)
;  OUT : d0/d1/d2 - 3D X, Y & Z (.w)
; Changed registers : d0,d1,d2
Get_3D_part_coordinates:
	move.l	a1,-(sp)
	cmp.b	#1,Part_type(a0)		; Party or monster ?
	bne.s	.Monster
	move.w	Cpart_X(a0),d0		; Party
	moveq.l	#-1,d1
	jsr	Calculate_3D_coordinates
	move.w	d1,d2
	addq.w	#1,d2			; In front !
	move.l	Cp_char(a0),a1		; Get height of race
	moveq.l	#0,d1
	move.b	Char_race(a1),d1
	lea.l	Race_heights,a1
	add.w	d1,d1
	move.w	0(a1,d1.w),d1
	mulu.w	#Projectile_height,d1
	divu.w	(a1),d1
	bra.s	.Exit
.Monster:	move.l	Cpart_COMOB_ptr(a0),a1	; Monster
	move.w	Co_3D_X(a1),d0
	move.w	Co_disp_height(a1),d1
	lsr.w	#1,d1
	move.w	Co_3D_Z(a1),d2
	subq.w	#1,d2			; In front !
.Exit:	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ Draw the combat window ]
; All registers are restored
; NOTE :
;   - Like [ Draw_combat_screen ] and [ Process_COMOB ] (COMOBS.S), but the
;     whole window is drawn.
;*****************************************************************************
Draw_combat_screen:
	movem.l	d0-d7/a0-a6,-(sp)
; ---------- Copy background ----------------------
	move.l	Combat_bg_ptr,a0
	lea.l	64(a0),a0
	move.l	Work_screen,a1
	lea.l	Combat_Y*ST_bytes_per_line(a1),a1
	move.w	#Combat_height*ST_bytes_per_line/32-1,d7
.Copy:	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)
	lea.l	32(a1),a1
	dbra	d7,.Copy
; ---------- Move & sort COMOBs -------------------
	lea.l	COMOB_table,a0
	lea.l	COMOB_sort_list,a1
	moveq.l	#0,d6
	moveq.l	#Max_COMOBs-1,d7
.Loop1:	tst.b	Co_flags(a0)		; Present ?
	beq.s	.Next1
	move.w	Co_vector_X(a0),d0		; Yes -> Move
	add.w	d0,Co_3D_X(a0)
	move.w	Co_vector_Y(a0),d0
	add.w	d0,Co_3D_Y(a0)
	move.w	Co_vector_Z(a0),d0
	add.w	d0,Co_3D_Z(a0)
	move.w	Co_3D_Z(a0),d0		; Insert (far ones first)
	move.w	d6,d1
	lsl.w	#2,d1
.Ins:	tst.w	d1
	beq.s	.Put
	move.l	-4(a1,d1.w),a2
	cmp.w	Co_3D_Z(a2),d0
	ble.s	.Put
	move.l	a2,0(a1,d1.w)
	subq.w	#4,d1
	bra.s	.Ins
.Put:	move.l	a0,0(a1,d1.w)
	addq.w	#1,d6
.Next1:	lea.l	Co_size(a0),a0
	dbra	d7,.Loop1
; ---------- Draw COMOBs --------------------------
	bra.s	.Entry2
.Loop2:	move.l	(a1)+,a0
	jsr	Draw_COMOB
.Entry2:	dbra	d6,.Loop2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Project & draw a COMOB ]
;   IN : a0 - Pointer to COMOB data (.l)
; All registers are restored
Draw_COMOB:
	movem.l	d0-d7/a0,-(sp)
	move.w	Co_3D_Z(a0),d3		; Behind the camera ?
	addi.w	#Combat_proj_factor,d3
	ble	.Exit
	move.w	Co_3D_X(a0),d0		; Project coordinates
	move.w	Co_3D_Y(a0),d1
	subi.w	#Combat_camera_height,d1
	ext.l	d0
	ext.l	d1
	moveq.l	#Combat_proj_log,d4
	asl.l	d4,d0
	asl.l	d4,d1
	divs.w	d3,d0
	divs.w	d3,d1
	neg.w	d1
	addi.w	#Combat_cX,d0		; Centre
	addi.w	#Combat_cY,d1
	moveq.l	#0,d6			; Project display size
	move.w	Co_disp_width(a0),d6
	moveq.l	#0,d7
	move.w	Co_disp_height(a0),d7
	lsl.l	d4,d6
	lsl.l	d4,d7
	divu.w	d3,d6
	divu.w	d3,d7
	tst.w	d6			; Visible ?
	beq.s	.Exit
	tst.w	d7
	beq.s	.Exit
	sub.w	d7,d1			; Adjust to bottom-centre
	move.w	d6,d2
	lsr.w	#1,d2
	sub.w	d2,d0
	move.w	Co_src_width(a0),d4		; Get frame
	move.w	Co_src_height(a0),d5
	move.w	d4,d2
	lsr.w	#4,d2
	lsl.w	#3,d2
	mulu.w	d5,d2
	mulu.w	Co_frame(a0),d2
	move.l	Co_gfx(a0),a0
	add.l	d2,a0
	jsr	Draw_zoom
.Exit:	movem.l	(sp)+,d0-d7/a0
	rts

;*****************************************************************************
; [ Draw a zoomed graphic in the combat window ]
;   IN : d0 - Left X-coordinate (.w)
;        d1 - Top Y-coordinate (.w)
;        d4 - Source width (multiple of 16) (.w)
;        d5 - Source height (.w)
;        d6 - Width on screen (.w)
;        d7 - Height on screen (.w)
;        a0 - Pointer to graphics (ST, 4 planes, colour 0 = transparent) (.l)
; All registers are restored
; NOTE :
;   - Replaces [ Draw_zoom_shape ]. The graphic is clipped against the
;     combat window.
;*****************************************************************************
Draw_zoom:
	movem.l	d0-d7/a0-a6,-(sp)
	cmp.w	d4,d6			; Same size ?
	bne.s	.Zoom
	cmp.w	d5,d7
	bne.s	.Zoom
	tst.w	d0
	bmi.s	.Zoom
	move.l	a0,a2			; Yes -> Normal block
	lea.l	Combat_CA,a0
	jsr	Push_CA
	move.l	a2,a0
	lsr.w	#4,d6
	jsr	Put_masked_block
	jsr	Pop_CA
	bra	.Exit
.Zoom:	movem.w	d0/d1/d4-d7,Zoom_X		; Store parameters
	move.l	a0,Zoom_gfx
; ---------- Clip vertically ----------------------
	moveq.l	#0,d2			; First line
	moveq.l	#Combat_Y,d3
	sub.w	d1,d3
	ble.s	.Y1
	move.w	d3,d2
.Y1:	move.w	d7,d3			; Last line + 1
	move.w	#Combat_Y+Combat_height,d4
	sub.w	d1,d4
	cmp.w	d4,d3
	ble.s	.Y2
	move.w	d4,d3
.Y2:	cmp.w	d3,d2
	bge	.Exit
	movem.w	d2/d3,Zoom_ys
; ---------- Clip horizontally --------------------
	moveq.l	#0,d2			; First column
	move.w	d0,d3
	neg.w	d3
	ble.s	.X1
	move.w	d3,d2
.X1:	move.w	d6,d3			; Last column + 1
	move.w	#Combat_X+Combat_width,d4
	sub.w	d0,d4
	cmp.w	d4,d3
	ble.s	.X2
	move.w	d4,d3
.X2:	cmp.w	d3,d2
	bge	.Exit
; ---------- Make column table --------------------
	moveq.l	#0,d4			; Step (8.8)
	move.w	Zoom_srcw,d4
	lsl.l	#8,d4
	divu.w	Zoom_w,d4
	andi.l	#$0000ffff,d4
	move.w	d2,d5			; Start position
	mulu.w	d4,d5
	lea.l	Zoom_xtab,a1
	move.w	d3,d7
	sub.w	d2,d7
	move.w	d7,Zoom_count
	subq.w	#1,d7
.Xtab:	move.l	d5,d6
	lsr.l	#8,d6
	move.w	d6,(a1)+
	add.l	d4,d5
	dbra	d7,.Xtab
	add.w	Zoom_X,d2			; First screen column
	move.w	d2,Zoom_x0
; ---------- Draw lines ---------------------------
	moveq.l	#0,d4			; Step (8.8)
	move.w	Zoom_srch,d4
	lsl.l	#8,d4
	divu.w	Zoom_h,d4
	andi.l	#$0000ffff,d4
	move.l	d4,Zoom_ystep
	move.w	Zoom_ys,d5		; Start position
	mulu.w	d4,d5
	move.l	d5,Zoom_ypos
	move.w	#-1,Zoom_last_sy
	move.w	Zoom_Y,d1			; First screen line
	add.w	Zoom_ys,d1
	mulu.w	#ST_bytes_per_line,d1
	add.l	Work_screen,d1
	move.l	d1,Zoom_row
	move.w	Zoom_ye,d7
	sub.w	Zoom_ys,d7
	subq.w	#1,d7
.Row:	move.l	Zoom_ypos,d5		; Get source line
	lsr.l	#8,d5
	cmp.w	Zoom_last_sy,d5		; New ?
	beq.s	.Same
	move.w	d5,Zoom_last_sy		; Yes -> Unpack
	jsr	Zoom_unpack_line
.Same:	jsr	Zoom_put_line		; Draw
	move.l	Zoom_ystep,d0		; Next line
	add.l	d0,Zoom_ypos
	addi.l	#ST_bytes_per_line,Zoom_row
	dbra	d7,.Row
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Unpack a line of the source graphic (one byte per pixel) ]
;   IN : d5 - Source line (.w)
; All registers are restored
; NOTE :
;   - The bytes are the colours * 4 (index for [ Plane_table ]).
Zoom_unpack_line:
	movem.l	d0-d5/a2/a4/a5,-(sp)
	move.w	Zoom_srcw,d4		; Get line address
	lsr.w	#4,d4
	move.w	d4,d0
	lsl.w	#3,d0
	mulu.w	d5,d0
	move.l	Zoom_gfx,a2
	add.l	d0,a2
	lea.l	Zoom_chunky,a4
	lea.l	Chunky_table,a5
	subq.w	#1,d4
.Loop:	moveq.l	#0,d5			; Left 8 pixels
	jsr	.Eight
	moveq.l	#1,d5			; Right 8 pixels
	jsr	.Eight
	addq.l	#8,a2			; Next trunc
	dbra	d4,.Loop
	movem.l	(sp)+,d0-d5/a2/a4/a5
	rts

; Unpack the bytes at d5(a2) of the 4 planes
.Eight:	moveq.l	#0,d3			; Plane 3
	move.b	6(a2,d5.w),d3
	lsl.w	#3,d3
	move.l	0(a5,d3.w),d0
	move.l	4(a5,d3.w),d1
	add.l	d0,d0
	add.l	d1,d1
	moveq.l	#0,d3			; Plane 2
	move.b	4(a2,d5.w),d3
	lsl.w	#3,d3
	add.l	0(a5,d3.w),d0
	add.l	4(a5,d3.w),d1
	add.l	d0,d0
	add.l	d1,d1
	moveq.l	#0,d3			; Plane 1
	move.b	2(a2,d5.w),d3
	lsl.w	#3,d3
	add.l	0(a5,d3.w),d0
	add.l	4(a5,d3.w),d1
	add.l	d0,d0
	add.l	d1,d1
	moveq.l	#0,d3			; Plane 0
	move.b	0(a2,d5.w),d3
	lsl.w	#3,d3
	add.l	0(a5,d3.w),d0
	add.l	4(a5,d3.w),d1
	move.l	d0,(a4)+
	move.l	d1,(a4)+
	rts

; [ Draw a scaled line ]
; All registers are restored
Zoom_put_line:
	movem.l	d0-d7/a0-a5,-(sp)
	move.l	Zoom_row,a0
	lea.l	Zoom_xtab,a3
	lea.l	Zoom_chunky,a4
	lea.l	Plane_table,a5
	move.w	Zoom_x0,d4		; Screen X
	move.w	Zoom_count,d5		; Pixels left
	moveq.l	#0,d1
.Byte:	moveq.l	#7,d6			; Pixels in this byte
	and.w	d4,d6
	moveq.l	#8,d3
	sub.w	d6,d3
	cmp.w	d5,d3
	ble.s	.Ok
	move.w	d5,d3
.Ok:	moveq.l	#0,d2			; Collect pixels
	move.w	d3,d7
	subq.w	#1,d7
.Pixel:	move.w	(a3)+,d0
	move.b	0(a4,d0.w),d1
	add.l	d2,d2
	add.l	0(a5,d1.w),d2
	dbra	d7,.Pixel
	moveq.l	#8,d7			; Align
	sub.w	d6,d7
	sub.w	d3,d7
	lsl.l	d7,d2
	tst.l	d2			; Anything ?
	beq.s	.Next
	move.w	d4,d0			; Get address
	lsr.w	#4,d0
	lsl.w	#3,d0
	lea.l	0(a0,d0.w),a1
	btst	#3,d4
	beq.s	.Even
	addq.l	#1,a1
.Even:	move.l	d2,d0			; Make mask
	swap	d0
	or.w	d2,d0
	move.w	d0,d7
	lsr.w	#8,d7
	or.b	d7,d0
	not.b	d0
	and.b	d0,6(a1)			; Put
	or.b	d2,6(a1)
	lsr.l	#8,d2
	and.b	d0,4(a1)
	or.b	d2,4(a1)
	lsr.l	#8,d2
	and.b	d0,2(a1)
	or.b	d2,2(a1)
	lsr.l	#8,d2
	and.b	d0,(a1)
	or.b	d2,(a1)
.Next:	add.w	d3,d4			; Next byte
	sub.w	d3,d5
	bgt.s	.Byte
	movem.l	(sp)+,d0-d7/a0-a5
	rts

; [ Make the table for unpacking ]
; All registers are restored
; NOTE :
;   - For each byte value 8 bytes : 4 for each set bit (from left to right).
Init_chunky_table:
	movem.l	d0-d2/a0,-(sp)
	lea.l	Chunky_table,a0
	moveq.l	#0,d0
.Loop:	moveq.l	#8-1,d1
.Bit:	moveq.l	#0,d2
	btst	d1,d0
	beq.s	.Zero
	moveq.l	#4,d2
.Zero:	move.b	d2,(a0)+
	dbra	d1,.Bit
	addq.w	#1,d0
	cmp.w	#256,d0
	bmi.s	.Loop
	movem.l	(sp)+,d0-d2/a0
	rts

;*****************************************************************************
; [ Update the combat screen ]
; All registers are restored
; NOTE :
;   - From COMBAT_M.S. Draws the combat window and the tactic window and
;     shows the screen.
;*****************************************************************************
Update_combat_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Draw_combat_screen
	jsr	Draw_tactic_window
	jsr	Show_active_member
	jsr	Draw_tactic_icons
	jsr	Update_status
	jsr	Switch_screens
	jsr	Combat_animation_timer
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Update the combat screen in the input loop ]
; All registers are restored
; NOTE :
;   - Like [ Combat_DisUpd ] with [ Tactic_touched ] (the name and the life
;     points of the participant under the mouse).
Update_combat_display:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Draw_combat_screen
	jsr	Draw_tactic_window
	jsr	Show_active_member
	move.l	Active_participant,a0	; Show current target
	cmp.b	#Close_range_action,Part_action(a0)
	beq.s	.Target
	cmp.b	#Long_range_action,Part_action(a0)
	beq.s	.Target
	cmp.b	#Move_action,Part_action(a0)
	bne.s	.No_target
.Target:	btst	#4,VBL_counter+1
	bne.s	.No_target
	jsr	Show_active_target
.No_target:	jsr	Draw_tactic_icons
	jsr	Update_tactic_ghost
	jsr	Update_status
	jsr	Switch_screens
	jsr	Combat_animation_timer
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Update the combat animations ]
; All registers are restored
; NOTE :
;   - The original counts the VBLs in [ Time_combat ].
Combat_animation_timer:
	movem.l	d0,-(sp)
	move.w	VBL_counter,d0		; Not too fast ?
	sub.w	Combat_anim_time,d0
	cmp.w	#Combat_animspeed,d0
	bmi.s	.Exit
	move.w	VBL_counter,Combat_anim_time	; No -> Animate
	jsr	Update_combat_animations
	jsr	Start_random_animations
.Exit:	movem.l	(sp)+,d0
	rts

; [ Wait for the end of a combat animation ]
;   IN : a0 - Pointer to participant data (.l)
; All registers are restored
Wait_4_animation:
	cmp.b	#2,Part_type(a0)		; Is monster ?
	bne.s	.Exit
.Wait:	tst.b	Part_anim(a0)		; Animation ended ?
	beq.s	.Exit
	jsr	Update_combat_screen	; No -> Update
	bra.s	.Wait
.Exit:	rts

; [ Wait for a click in combat ]
; All registers are restored
Combat_wait_click:
	move.l	d0,-(sp)
	jsr	Read_mouse_clicks		; Forget old events
.Flush:	jsr	Read_key
	tst.w	d0
	bne.s	.Flush
.Loop:	jsr	Update_combat_screen
	jsr	Read_mouse_clicks
	tst.w	d0
	bne.s	.Exit
	jsr	Read_key
	tst.w	d0
	beq.s	.Loop
.Exit:	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Monster animations ]
; NOTE :
;   - From COMBAT.S.
;*****************************************************************************
; [ Update all monster animations ]
; All registers are restored
Update_combat_animations:
	movem.l	d7/a0,-(sp)
	lea.l	Combat_monsters,a0		; Do all monsters
	move.w	Nr_monsters,d7
	bra.s	.Entry
.Loop:	tst.b	Part_type(a0)		; Still there ?
	beq.s	.Next
	btst	#Part_handanimated,Part_flags(a0)	; Yes -> Do ?
	bne.s	.Next
	jsr	Do_animation_update		; Yes -> Do
.Next:	lea.l	Cp_size(a0),a0		; Next monster
.Entry:	dbra	d7,.Loop
	movem.l	(sp)+,d7/a0
	rts

; [ Update a monster animation ]
;   IN : a0 - Pointer to monster participant data (.l)
; All registers are restored
Do_animation_update:
	movem.l	d0-d2/a1/a2,-(sp)
	moveq.l	#0,d0			; Get animation type
	move.b	Part_anim(a0),d0
	beq	.Exit			; If any
	move.b	Part_anim_index(a0),d1	; Get frame index
	ext.w	d1
	move.l	Cp_original(a0),a1
	subq.w	#1,d0			; Adjust
	lea.l	Anim_frame(a1),a2		; Get number of frames
	moveq.l	#0,d2
	move.b	0(a2,d0.w),d2
	beq.s	.End			; If any
	btst	d0,Anim_motion(a1)		; Wave or circle ?
	beq.s	.Circle
	cmp.w	#1,d2			; One-frame wave animation ?
	beq.s	.Circle
	btst	#Part_wavedir,Part_flags(a0)	; Going back or forth ?
	beq.s	.Forth
	subq.w	#1,d1			; Back
	bne.s	.Do			; End ?
	bclr	#Part_wavedir,Part_flags(a0)	; Yes -> Forth next time
.End:	clr.b	Part_anim(a0)		; End of animation
	moveq.l	#0,d0			; Return to first frame
	move.b	Part_default_frame(a0),d0
	moveq.l	#0,d1
	bra.s	.Frame
.Forth:	addq.w	#1,d1			; Forth
	cmp.w	d2,d1			; End ?
	bmi.s	.Do
	subq.w	#2,d1			; Yes -> Go back
	bset	#Part_wavedir,Part_flags(a0)
	bra.s	.Do
.Circle:	addq.w	#1,d1			; Forth
	cmp.w	d2,d1			; End ?
	bpl.s	.End
.Do:	lea.l	Anim_dat(a1),a2		; Get current frame
	lsl.w	#5,d0
	add.w	d0,a2
	moveq.l	#0,d0
	move.b	0(a2,d1.w),d0
.Frame:	move.l	Cpart_COMOB_ptr(a0),a2	; Set frame
	move.w	d0,Co_frame(a2)
	move.b	d1,Part_anim_index(a0)	; Store new index
.Exit:	movem.l	(sp)+,d0-d2/a1/a2
	rts

; [ Start random animations ]
; All registers are restored
Start_random_animations:
	movem.l	d0/d7/a0/a1,-(sp)
	tst.b	Random_animating		; Allowed ?
	beq.s	.Exit
	lea.l	Combat_monsters,a0		; Yes -> Check monsters
	move.w	Nr_monsters,d7
	bra.s	.Entry1
.Loop1:	tst.b	Part_type(a0)		; Alive ?
	beq.s	.Next1
	tst.b	Part_anim(a0)		; Animating ?
	bne.s	.Exit			; Yes -> Exit
.Next1:	lea.l	Cp_size(a0),a0		; Next monster
.Entry1:	dbra	d7,.Loop1
	jsr	Random			; Select monster
	mulu.w	#Max_monsters,d0
	swap	d0
	cmp.w	Nr_monsters,d0
	bpl.s	.Exit
	lea.l	Combat_monsters,a0		; Find data
	mulu.w	#Cp_size,d0
	add.w	d0,a0
	tst.b	Part_type(a0)		; Alive ?
	beq.s	.Exit
	move.l	Cp_char(a0),a1		; Yes -> Capable of movement ?
	move.w	Body_conditions(a1),d0
	andi.w	#Animate_mask,d0
	bne.s	.Exit
	Set_anim	Stand_anim,a0		; Animate!
.Exit:	movem.l	(sp)+,d0/d7/a0/a1
	rts

;*****************************************************************************
; [ Combat effects ]
; NOTE :
;   - From COMBAT.S.
;*****************************************************************************
; [ Show close-range slash ]
;   IN : a1 - Pointer to defender's participant data (.l)
; All registers are restored
Show_slash:
	movem.l	d0-d2/d7/a0,-(sp)
	move.l	a1,a0			; Create slash shape
	jsr	Get_3D_part_coordinates
	jsr	Add_COMOB
	move.w	d0,Co_3D_X(a0)
	move.w	d1,Co_3D_Y(a0)
	move.w	d2,Co_3D_Z(a0)
	move.w	#24,Co_disp_width(a0)	; Set data
	move.w	#48,Co_disp_height(a0)
	move.w	#16,Co_src_width(a0)
	move.w	#43,Co_src_height(a0)
	move.l	Combat_FX_ptr,d0
	addi.l	#Slash_FX,d0
	move.l	d0,Co_gfx(a0)
	moveq.l	#3,d0			; Show
	moveq.l	#3-1,d7
.Loop:	jsr	Update_combat_screen
	jsr	Circle_COMOB
	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d0-d2/d7/a0
	rts

; [ Show scratches on a party member ]
;   IN : d0 - Amount of damage (.w)
;        a0 - Pointer to party member's participant data (.l)
; All registers are restored
Show_scratches:
	movem.l	d0-d3/d7/a0,-(sp)
	move.w	d0,d3
	jsr	Get_3D_part_coordinates	; Create scratches
	jsr	Add_COMOB
	move.w	d0,Co_3D_X(a0)
	move.w	d1,Co_3D_Y(a0)
	move.w	#-256,Co_3D_Z(a0)
	moveq.l	#16,d0			; Set size
	add.w	d3,d0
	move.w	d0,Co_disp_width(a0)
	move.w	d0,Co_disp_height(a0)
	move.w	#32,Co_src_width(a0)
	move.w	#32,Co_src_height(a0)
	move.l	Combat_FX_ptr,d0
	addi.l	#Scratches_FX,d0
	move.l	d0,Co_gfx(a0)
	moveq.l	#4,d0			; Show
	moveq.l	#4-1,d7
.Loop:	jsr	Update_combat_screen
	jsr	Circle_COMOB
	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d0-d3/d7/a0
	rts

; [ Show blood on a monster ]
;   IN : a0 - Pointer to monster's participant data (.l)
; All registers are restored
Show_blood:
	movem.l	d0/d7/a0-a2,-(sp)
	move.l	a0,a1			; Create blood explosion
	move.l	Cpart_COMOB_ptr(a1),a2
	jsr	Add_COMOB
	move.w	Co_3D_X(a2),Co_3D_X(a0)	; Set position
	move.w	Co_disp_height(a2),d0
	lsr.w	#1,d0
	subi.w	#16,d0
	bpl.s	.Pos
	moveq.l	#0,d0
.Pos:	move.w	d0,Co_3D_Y(a0)
	move.w	Co_3D_Z(a2),d0
	subq.w	#1,d0
	move.w	d0,Co_3D_Z(a0)
	move.w	Cpart_damage(a1),d0		; Set size
	lsr.w	#2,d0
	cmp.w	#50,d0
	bmi.s	.Ok1
	moveq.l	#50,d0
.Ok1:	addi.w	#32,d0
	move.w	d0,Co_disp_width(a0)
	move.w	d0,Co_disp_height(a0)
	move.w	#32,Co_src_width(a0)	; Set other data
	move.w	#32,Co_src_height(a0)
	move.l	Combat_FX_ptr,d0
	addi.l	#Blood_FX,d0
	move.l	d0,Co_gfx(a0)
	moveq.l	#4,d0			; Show
	moveq.l	#4-1,d7
.Loop:	jsr	Update_combat_screen
	jsr	Update_combat_screen
	jsr	Circle_COMOB
	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d0/d7/a0-a2
	rts

; [ Show monster death ]
;   IN : a0 - Pointer to monster's participant data (.l)
; All registers are restored
Show_monster_death:
	movem.l	d0-d4/d7/a0/a1,-(sp)
	move.l	Cp_original(a0),a1		; Die animation ?
	tst.b	Anim_frame+Die_anim-1(a1)
	beq.s	.Skip
	Set_anim	Die_anim,a0		; Yes -> Die !
	jsr	Wait_4_animation
.Skip:	move.l	Cpart_COMOB_ptr(a0),a0	; Remove COMOB
	movem.w	Co_3D_X(a0),d0-d2
	move.w	Co_disp_width(a0),d3
	move.w	Co_disp_height(a0),d4
	jsr	Delete_COMOB
	jsr	Add_COMOB			; Create new one
	movem.w	d0-d2,Co_3D_X(a0)
	move.w	d3,d0
	lsr.w	#2,d0
	add.w	d0,d3
	move.w	d3,Co_disp_width(a0)
	move.w	d4,d0
	lsr.w	#2,d0
	add.w	d0,d4
	move.w	d4,Co_disp_height(a0)
	move.w	#48,Co_src_width(a0)
	move.w	#59,Co_src_height(a0)
	move.l	Combat_FX_ptr,d0
	addi.l	#Explosion_FX,d0
	move.l	d0,Co_gfx(a0)
	moveq.l	#14-1,d7			; Show & animate
.Loop:	jsr	Update_combat_screen
	addq.w	#1,Co_frame(a0)
	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d0-d4/d7/a0/a1
	rts

; [ Show the flight of a monster ]
;   IN : a0 - Pointer to monster's participant data (.l)
; All registers are restored
Show_flight:
	movem.l	d7/a0,-(sp)
	Set_anim	Stand_anim,a0		; Move back...
	move.l	Cpart_COMOB_ptr(a0),a0
	move.w	#-2,Co_vector_Y(a0)		; ...and down
	move.w	#50,Co_vector_Z(a0)
	moveq.l	#20-1,d7
.Loop:	jsr	Update_combat_screen
	dbra	d7,.Loop
	jsr	Delete_COMOB		; Delete
	movem.l	(sp)+,d7/a0
	rts

;*****************************************************************************
; [ Tactic window ]
; NOTE :
;   - From TACTIC.S.
;*****************************************************************************
; [ Draw the tactic window (background) ]
; All registers are restored
Draw_tactic_window:
	movem.l	d0/d1/d6/d7/a0,-(sp)
	move.w	#Tactic_X,d0
	move.w	#Tactic_Y-1,d1
	moveq.l	#6,d6
	moveq.l	#5*Tactic_cell_height+2,d7
	lea.l	Tactic_background,a0
	jsr	Put_unmasked_block
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts

; [ Draw the tactic icons ]
; All registers are restored
Draw_tactic_icons:
	movem.l	d0-d7/a0-a3,-(sp)
	lea.l	Combat_matrix,a1		; Draw tactical matrix
	move.l	Tactic_icons_ptr,a2
	lea.l	Tactic_icon_gfx(a2),a2
	move.w	#Tactic_Y-1,d1
	moveq.l	#1,d6
	moveq.l	#14,d7
	moveq.l	#5-1,d2
.Loop_Y:	move.w	#Tactic_X,d0
	moveq.l	#6-1,d3
.Loop_X:	tst.l	(a1)			; Anything there ?
	beq.s	.Next_X
	move.l	(a1),a3			; Yes -> Get data
	moveq.l	#0,d4			; Get icon number
	move.b	Part_icon_nr(a3),d4
	mulu.w	#14*8,d4			; Get graphics address
	lea.l	0(a2,d4.w),a0
	jsr	Put_masked_block		; Display tactical icon
	tst.b	Part_damage_timer(a3)	; Any damage ?
	beq.s	.Next_X
	jsr	Show_damage		; Yes -> Show
.Next_X:	addq.l	#4,a1			; Next
	addi.w	#16,d0
	dbra	d3,.Loop_X
	addi.w	#Tactic_cell_height,d1
	dbra	d2,.Loop_Y
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Print damage ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a3 - Pointer to participant (.l)
; All registers are restored
Show_damage:
	movem.l	d0-d7/a0-a3,-(sp)
	subq.b	#1,Part_damage_timer(a3)	; Count down
	moveq.l	#0,d2			; Get damage
	move.w	Cpart_damage(a3),d2
	beq	.Exit
	cmp.w	#1000,d2			; Too large ?
	bmi.s	.Ok
	move.w	#999,d2			; Yes -> Clip
.Ok:	lea.l	Very_small_numbers,a0	; Get three digits &
	divu.w	#10,d2			;  pointers to font
	swap	d2
	move.w	d2,d3
	mulu.w	#5,d3
	lea.l	0(a0,d3.w),a2
	clr.w	d2
	swap	d2
	divu.w	#10,d2
	move.w	d2,d3
	swap	d2
	mulu.w	#5,d2
	lea.l	0(a0,d2.w),a1
	mulu.w	#5,d3
	add.w	d3,a0
	lea.l	Very_small_buffer,a3	; Draw to buffer
	moveq.l	#5-1,d7
.Loop:	moveq.l	#0,d2			; Take first digit
	move.b	(a0)+,d2
	lsl.w	#8,d2
	moveq.l	#0,d3			; Take second digit
	move.b	(a1)+,d3
	lsl.w	#3,d3
	or.w	d3,d2			; Merge
	moveq.l	#0,d3			; Take third digit
	move.b	(a2)+,d3
	lsr.w	#2,d3
	or.w	d3,d2			; Merge
	move.w	d2,(a3)+			; Put in buffer
	dbra	d7,.Loop
	lea.l	-10(a3),a0		; Display
	addq.w	#1,d0
	addi.w	#10,d1
	moveq.l	#White,d4			; (blinking)
	btst	#3,VBL_counter+1
	beq.s	.Colour
	moveq.l	#Light_red,d4
.Colour:	moveq.l	#5,d7
	jsr	Put_silhouette
.Exit:	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Put a 16 pixel wide silhouette ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Colour (.w)
;        d7 - Height (.w)
;        a0 - Pointer to the lines (one word each) (.l)
; All registers are restored
Put_silhouette:
	movem.l	d0-d7/a0-a2,-(sp)
	jsr	Get_ST_colour
	move.l	Work_screen,a1
	jsr	Get_screen_offset_d0d1
	move.w	d0,d5
	andi.w	#15,d5
	subq.w	#1,d7
.Line:	moveq.l	#0,d2			; Get line
	move.w	(a0)+,d2
	swap	d2
	lsr.l	d5,d2			; (left & right trunc)
	move.l	d2,d3			; Mask
	not.l	d3
	move.w	d4,d1
	move.l	a1,a2
	moveq.l	#4-1,d6
.Plane:	lsr.w	#1,d1			; Set or clear ?
	bcc.s	.Clear
	swap	d2
	or.w	d2,(a2)
	swap	d2
	or.w	d2,8(a2)
	bra.s	.Next
.Clear:	swap	d3
	and.w	d3,(a2)
	swap	d3
	and.w	d3,8(a2)
.Next:	addq.l	#2,a2			; Next plane
	dbra	d6,.Plane
	lea.l	ST_bytes_per_line(a1),a1	; Next line
	dbra	d7,.Line
	movem.l	(sp)+,d0-d7/a0-a2
	rts

; [ Show the active member in the tactic window ]
; All registers are restored
Show_active_member:
	movem.l	d0-d4/a0,-(sp)
	move.l	Active_participant,a0
	move.l	a0,d0
	beq.s	.Exit
	move.w	Cpart_X(a0),d0		; Calculate screen coordinates
	move.w	Cpart_Y(a0),d1
	lsl.w	#4,d0
	mulu.w	#Tactic_cell_height,d1
	addi.w	#Tactic_X,d0
	addi.w	#Tactic_Y,d1
	moveq.l	#16,d2			; Draw rectangle
	moveq.l	#Tactic_cell_height,d3
	moveq.l	#Yellow,d4
	jsr	Draw_rectangle
.Exit:	movem.l	(sp)+,d0-d4/a0
	rts

; [ Show the target of the active member in the tactic window ]
;   IN : a0 - Pointer to active character's participant data (.l)
; All registers are restored
Show_active_target:
	movem.l	d0-d4,-(sp)
	moveq.l	#0,d0			; Get target
	move.w	Cpart_target(a0),d0
	bmi.s	.Exit
	jsr	Calculate_tactic_coordinates
	moveq.l	#16,d2			; Draw rectangle
	moveq.l	#Tactic_cell_height,d3
	moveq.l	#Light_red,d4
	jsr	Draw_rectangle
.Exit:	movem.l	(sp)+,d0-d4
	rts

; [ Show possible attacks in the tactic window ]
; All registers are restored
Show_attack_tactic:
	movem.l	d0/a0,-(sp)
	jsr	Show_active_member		; Show active member
	btst	#4,VBL_counter+1		; Alternate
	bne.s	.Alt
	move.l	Tactic_mask,d0		; Show possible attacks
	lea.l	Draw_green_square,a0
	jsr	Show_mask_tactic
	bra.s	.Exit
.Alt:	move.l	Active_participant,a0
	cmp.b	#Close_range_action,Part_action(a0)	; Attacking ?
	beq.s	.Yes
	cmp.b	#Long_range_action,Part_action(a0)
	bne.s	.Exit
.Yes:	jsr	Show_active_target		; Show current target
.Exit:	movem.l	(sp)+,d0/a0
	rts

; [ Show possible moves in the tactic window ]
; All registers are restored
Show_move_tactic:
	movem.l	d0/a0,-(sp)
	jsr	Show_active_member		; Show active member
	btst	#4,VBL_counter+1		; Alternate
	bne.s	.Alt
	move.l	Tactic_mask,d0		; Show possible moves
	lea.l	Draw_green_square,a0
	jsr	Show_mask_tactic
	move.l	Target_mask,d0		; Show occupied targets
	lea.l	Draw_red_cross,a0
	jsr	Show_mask_tactic
	bra.s	.Exit
.Alt:	move.l	Active_participant,a0
	cmp.b	#Move_action,Part_action(a0)	; Moving ?
	bne.s	.Exit
	jsr	Show_active_target		; Show current target
.Exit:	movem.l	(sp)+,d0/a0
	rts

; [ Calculate the screen coordinates of a tactic location ]
;   IN : d0 - Tactical location number {0...29} (.l)
;  OUT : d0/d1 - Screen coordinates (.w)
; Changed registers : d0,d1
Calculate_tactic_coordinates:
	divu.w	#6,d0
	move.w	d0,d1
	swap	d0
	lsl.w	#4,d0
	mulu.w	#Tactic_cell_height,d1
	addi.w	#Tactic_X,d0
	addi.w	#Tactic_Y,d1
	rts

; [ Show squares from a mask in the tactic window ]
;   IN : d0 - Mask (.l)
;        a0 - Pointer to draw routine (.l)
; All registers are restored
Show_mask_tactic:
	movem.l	d0/d1/d4-d7,-(sp)
	move.w	#Tactic_Y,d1
	move.l	d0,d4
	moveq.l	#0,d5
	moveq.l	#5-1,d7
.Loop_Y:	move.w	#Tactic_X,d0
	moveq.l	#6-1,d6
.Loop_X:	btst	d5,d4			; In mask ?
	beq.s	.Next_X
	jsr	(a0)			; Yes -> Draw
.Next_X:	addq.w	#1,d5			; Next X
	addi.w	#16,d0
	dbra	d6,.Loop_X
	addi.w	#Tactic_cell_height,d1	; Next Y
	dbra	d7,.Loop_Y
	movem.l	(sp)+,d0/d1/d4-d7
	rts

; Tactic window mask display routines (IN : d0/d1 - coordinates)
Draw_green_square:
	movem.l	d0-d4,-(sp)
	addq.w	#1,d0
	addq.w	#1,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#14-1,d2
	addi.w	#Tactic_cell_height-3,d3
	moveq.l	#Light_green,d4
	jsr	Draw_box
	movem.l	(sp)+,d0-d4
	rts

Draw_red_cross:
	movem.l	d4/d7/a0,-(sp)
	moveq.l	#Dark_red,d4
	moveq.l	#Tactic_cell_height,d7
	lea.l	Red_cross,a0
	jsr	Put_silhouette
	movem.l	(sp)+,d4/d7/a0
	rts

; [ Draw a rectangle ]
;   IN : d0/d1 - Top-left coordinates (.w)
;        d2/d3 - Width & height (.w)
;        d4 - Colour (.w)
; All registers are restored
Draw_rectangle:
	movem.l	d0-d3,-(sp)
	add.w	d0,d2			; Right & bottom
	subq.w	#1,d2
	add.w	d1,d3
	subq.w	#1,d3
	movem.w	d0-d3,-(sp)
	move.w	d1,d3			; Top
	jsr	Draw_box
	movem.w	(sp),d0-d3		; Bottom
	move.w	d3,d1
	jsr	Draw_box
	movem.w	(sp),d0-d3		; Left
	move.w	d0,d2
	jsr	Draw_box
	movem.w	(sp),d0-d3		; Right
	move.w	d2,d0
	jsr	Draw_box
	addq.l	#8,sp
	movem.l	(sp)+,d0-d3
	rts

; [ Get the tactic index under the mouse ]
;  OUT : d0 - Tactic index / -1 (.w)
; Changed registers : d0
Get_tactic_index:
	move.l	d1,-(sp)
	move.w	Mouse_X,d0		; Get mouse coordinates
	move.w	Mouse_Y,d1
	subi.w	#Tactic_X,d0		; Translate
	bmi.s	.Out
	subi.w	#Tactic_Y,d1
	bmi.s	.Out
	lsr.w	#4,d0			; Scale
	ext.l	d1
	divs.w	#Tactic_cell_height,d1
	cmp.w	#5,d0			; Out of range ?
	bhi.s	.Out
	cmp.w	#4,d1
	bhi.s	.Out
	mulu.w	#6,d1			; Calculate index
	add.w	d1,d0
	bra.s	.Exit
.Out:	moveq.l	#-1,d0
.Exit:	move.l	(sp)+,d1
	rts

; [ Show the name & strength of the participant under the mouse ]
; All registers are restored
; NOTE :
;   - Like [ Tactic_touched ], [ Create_tactic_name ] and
;     [ Create_tactic_strength ].
Update_tactic_ghost:
	movem.l	d0-d3/d7/a0-a2,-(sp)
	clr.l	Ghost_text
	clr.l	Ghost_text2
	jsr	Get_tactic_index		; Get index
	tst.w	d0
	bmi	.Exit
	lea.l	Combat_matrix,a0		; Look in matrix
	lsl.w	#2,d0
	move.l	0(a0,d0.w),d0		; Anything there ?
	beq	.Exit
	move.l	d0,a2
	tst.b	Part_type(a2)
	beq	.Exit
	move.l	Cp_char(a2),a1
	cmp.b	#1,Part_type(a2)		; Party or monster ?
	bne.s	.Monster
	move.w	Body_conditions(a1),d1	; Possible active ?
	andi.w	#Active_mask,d1
	bne.s	.No
	move.w	#White,Ghost_ink		; Yes
	bra.s	.Do
.No:	move.w	#Lighter_blue,Ghost_ink	; No
	bra.s	.Do
.Monster:	move.w	#Light_red,Ghost_ink	; Monster
.Do:	lea.l	Char_name(a1),a0		; Name
	move.l	a0,Ghost_text
	move.w	Ghost_ink,Ghost_ink2
	cmp.b	#1,Part_type(a2)		; (monster's strength
	beq.s	.Strength			;  only with magic)
	tst.b	Show_monsters
	beq.s	.Exit
.Strength:	move.w	Life_points+Maximum(a1),d3	; Get maximum LP
	add.w	Life_points+Magic(a1),d3
	move.w	Life_points(a1),d2		; Get normal LP
	cmp.w	d3,d2			; More than maximum ?
	bmi.s	.Less
	move.w	d3,d2			; Yes -> Full
.Less:	moveq.l	#3,d7			; Make string
	lea.l	Tactic_strength,a0
	moveq.l	#0,d0
	move.w	d2,d0
	jsr	DecL_convert
	move.b	#'/',(a0)+
	moveq.l	#0,d0
	move.w	d3,d0
	jsr	DecL_convert
	move.l	#Tactic_strength,Ghost_text2
.Exit:	movem.l	(sp)+,d0-d3/d7/a0-a2
	rts

;*****************************************************************************
; [ Select a location in the tactic window ]
;   IN : d0 - Prompt number (.w)
;        d1 - 1 = show moves, 2 = show attacks (.w)
;        [ Tactic_mask ] - Possible locations (.l)
;  OUT : d0 - Tactic index (.w)
;        mi - Aborted
; Changed registers : d0
; NOTE :
;   - Like the TacticSel module (TACTIC.S).
;*****************************************************************************
Select_tactic:
	movem.l	d1-d7/a0-a6,-(sp)
	move.w	d1,d7
	clr.l	Ghost_text
	clr.l	Ghost_text2
	jsr	Print_prompt
	jsr	Copy_screen_to_both
	jsr	Read_mouse_clicks
.Loop:	jsr	Draw_combat_screen		; Display
	jsr	Draw_tactic_window
	cmp.w	#1,d7
	bne.s	.Attack
	jsr	Show_move_tactic
	bra.s	.Go_on
.Attack:	jsr	Show_attack_tactic
.Go_on:	jsr	Draw_tactic_icons
	jsr	Update_tactic_ghost
	jsr	Update_status
	jsr	Switch_screens
	jsr	Combat_animation_timer
	jsr	Read_key			; ESC ?
	cmp.w	#$01,d0
	beq.s	.Abort
	jsr	Read_mouse_clicks
	btst	#Right_pressed,d0		; Right button ?
	bne.s	.Abort
	btst	#Left_pressed,d0		; Left button ?
	beq.s	.Loop
	jsr	Get_tactic_index		; In tactic window ?
	tst.w	d0
	bmi.s	.Loop
	move.l	Tactic_mask,d1		; Can be clicked on ?
	btst	d0,d1
	beq.s	.Loop
	bra.s	.Exit
.Abort:	moveq.l	#-1,d0
.Exit:	move.w	d0,-(sp)
	clr.l	Ghost_text
	clr.l	Ghost_text2
	jsr	Erase_PA
	jsr	Copy_screen_to_both
	move.w	(sp)+,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;*****************************************************************************
; [ Display the combat status icons ]
; All registers are restored
; NOTE :
;   - From COMBAT.S : the action or the condition of each member.
;*****************************************************************************
Display_combat_status_icons:
	movem.l	d0-d2/d7/a0-a3,-(sp)
	lea.l	Combat_party,a0		; Search party
	lea.l	Party_status_icons,a1
	lea.l	Action_icons_table,a2
	moveq.l	#1,d7
.Loop:	moveq.l	#0,d0			; Default
	tst.b	Part_type(a0)		; Anyone there ?
	beq.s	.Next
	move.b	Part_action(a0),d0		; Get action (if any)
	beq.s	.None
	move.b	-1(a2,d0.w),d0		; Get icon
	bra.s	.Next
.None:	move.l	Cp_char(a0),a3		; Get conditions
	move.w	Body_conditions(a3),d2
	lea.l	.Table,a3			; Search
.Again:	move.b	(a3)+,d1			; Get condition bit
	bmi.s	.Next
	btst	d1,d2			; Got it ?
	bne.s	.Yes
	addq.l	#1,a3			; No -> Next
	bra.s	.Again
.Yes:	move.b	(a3),d0			; Yes -> Set icon
.Next:	cmp.b	(a1),d0			; Changed ?
	beq.s	.Same
	move.b	d0,(a1)			; Yes -> Store & redraw
	jsr	Force_status_update
.Same:	addq.l	#1,a1
	lea.l	Cp_size(a0),a0		; Next member
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	movem.l	(sp)+,d0-d2/d7/a0-a3
	rts

.Table:	dc.b Dead,Dead_icon
	dc.b Ashes,Dead_icon
	dc.b Dust,Dead_icon
	dc.b Fleeing,Flee_icon
	dc.b Asleep,Asleep_icon
	dc.b Petrified,Petrified_icon
	dc.b Panicked,Panicked_icon
	dc.b Mad,Mad_icon
	dc.b -1
	even

;*****************************************************************************
; [ Monster logic ]
; NOTE :
;   - From MONSTER_.S, without magic.
;*****************************************************************************
; [ Determine monster action ]
;   IN : a0 - Pointer to monster's participant data (.l)
; All registers are restored
Determine_monster_action:
	movem.l	d0-d2/a1,-(sp)
	move.l	Cp_char(a0),a1
	move.b	Monster_type_status(a1),d0	; End monster ?
	btst	#End_monster_type,d0
	bne	.Offend
; ---------- Determine danger ---------------------
	move.w	Life_points+Maximum(a1),d1	; Calculate local danger
	add.w	Life_points+Magic(a1),d1	; 0...75
	move.w	d1,d0
	sub.w	Life_points(a1),d0
	muls.w	#75,d0
	divs.w	d1,d0
	move.w	Global_danger,d1		; Add global danger
	subi.w	#50,d1			; -12...12
	asr.w	#2,d1
	add.w	d1,d0
	move.w	Nr_monsters,d2		; Add group decimation factor
	subq.w	#1,d2			; -10...30
	beq.s	.One
	move.w	Remaining_monsters,d1
	subq.w	#1,d1
	mulu.w	#40,d1
	divu.w	d2,d1
	subi.w	#30,d1
	neg.w	d1
	add.w	d1,d0
.One:	tst.w	d0			; Clip bottom
	bpl.s	.Ok1
	moveq.l	#0,d0
	bra.s	.Ok2
.Ok1:	cmp.w	#100,d0			; Clip top
	bmi.s	.Ok2
	moveq.l	#100,d0
; ---------- Determine offensive/defensive --------
.Ok2:	moveq.l	#0,d1			; Too dangerous ?
	move.b	Courage(a1),d1
	sub.w	d0,d1
	bmi.s	.Defend
.Offend:	jsr	Select_offensive_monster_action	; No !
	bra.s	.Done
.Defend:	move.w	d1,d0			; Yes... defensive action ?
	neg.w	d0
	moveq.l	#100,d1
	sub.b	Courage(a1),d1
	ext.w	d1
	jsr	Probe
	bmi.s	.Offend
	jsr	Select_defensive_monster_action	; Yes
.Done:	tst.b	Part_action(a0)		; Doing something ?
	bne.s	.Exit
	move.w	Body_conditions(a1),d0	; No -> Can parade ?
	andi.w	#Parade_mask,d0
	bne.s	.Exit
	move.w	#-1,Cpart_target(a0)		; Yes -> Do
	move.b	#Parade_action,Part_action(a0)
.Exit:	movem.l	(sp)+,d0-d2/a1
	rts

; [ Select defensive monster action ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
Select_defensive_monster_action:
	movem.l	d0-d3/d5/d7/a2,-(sp)
; ---------- Try to flee --------------------------
	tst.w	Cpart_Y(a0)		; In top row ?
	bne.s	.Move
	move.w	Body_conditions(a1),d0	; Can flee ?
	andi.w	#Flee_mask,d0
	bne	.Exit
	move.w	#-1,Cpart_target(a0)		; Yes -> Flee
	move.b	#Flee_action,Part_action(a0)
	bra	.Exit
; ---------- Get movement range -------------------
.Move:	jsr	Get_occupied_targets	; Get occupied targets
	move.l	d0,d1
	jsr	Check_movement_range	; Get movement range
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	tst.l	d0			; Any left ?
	beq	.Exit
	move.l	d0,d5			; Yes
	lea.l	Cpart_target(a0),a2		; Reset number of moves
	clr.w	(a2)+
	move.w	Cpart_X(a0),d0		; Get coordinates
	move.w	Cpart_Y(a0),d1
	move.w	d1,d2			; Get tactic index
	mulu.w	#6,d2
	add.w	d0,d2
	jsr	Get_move_range		; Get movement speed
	bra.s	.Entry
; ---------- Try to retreat -----------------------
.Loop:	tst.w	d1			; Uppest ?
	beq.s	.Done
	move.w	d2,d3			; Up possible ?
	subq.w	#6,d3
	btst	d3,d5
	beq.s	.No
	subq.w	#1,d1			; Yes -> Move up
	subq.w	#6,d2
	bra.s	.Next
.No:	subq.w	#1,d1			; No -> Move up...
	subq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Defensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	bne.s	.Next
	addq.w	#1,d1			; No -> Move back down...
	addq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Defensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	beq.s	.Done
	bclr	d3,d5			; Yes -> No turning back !
.Next:	move.w	d2,(a2)+			; Store move
	addq.w	#1,Cpart_target(a0)
.Entry:	dbra	d7,.Loop			; Next step
.Done:	tst.w	Cpart_target(a0)		; Moved ?
	beq.s	.Exit
	move.b	#Move_action,Part_action(a0)	; Set action
.Exit:	movem.l	(sp)+,d0-d3/d5/d7/a2
	rts

; [ Get the movement range ]
;   IN : a1 - Pointer to character data (.l)
;  OUT : d7 - Range {1...3} (.w)
; Changed registers : d7
Get_move_range:
	move.w	ASpeed(a1),d7		; Get movement speed
	add.w	ASpeed+Magic(a1),d7
	ext.l	d7			; Determine range
	divs.w	#Move_speed_factor,d7
	tst.w	d7			; Clip below
	bne.s	.Below_OK
	moveq.l	#1,d7
	rts
.Below_OK:	cmp.w	#3+1,d7			; Clip above
	bmi.s	.Ok
	moveq.l	#3,d7
.Ok:	rts

; [ Try DEFENSIVE movement to the left or to the right ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Tactic index {0...29} (.w)
;        d5 - Movement range mask (.l)
;  OUT : d0 - New X-coordinate (.w)
;        d2 - New tactic index {0...29} (.w)
; Changed registers : d0,d2
Defensive_left_or_right:
	move.l	d3,-(sp)
; ---------- Both left & right possible ? ---------
	tst.w	d0			; Leftest ?
	beq.s	.Right1
	cmp.w	#5,d0			; Rightest ?
	beq.s	.Left1
	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq.s	.Right1
	addq.w	#2,d3			; Right possible ?
	btst	d3,d5
	beq.s	.Left1
; ---------- Which is better ? --------------------
	move.l	d0,-(sp)			; Chance >= 0.5 ?
	jsr	Random
	move.w	d0,d3
	move.l	(sp)+,d0
	andi.w	#$00ff,d3
	cmp.w	#128,d3
	bmi.s	.Left2
	bra.s	.Right2
; ---------- Try to move right --------------------
.Right1:	move.w	d2,d3			; Right possible ?
	addq.w	#1,d3
	btst	d3,d5
	beq.s	.Exit
.Right2:	addq.w	#1,d0			; Move right
	addq.w	#1,d2
	bra.s	.Exit
; ---------- Try to move left ---------------------
.Left1:	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq.s	.Exit
.Left2:	subq.w	#1,d0			; Move left
	subq.w	#1,d2
.Exit:	move.l	(sp)+,d3
	rts

; [ Select offensive monster action ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
Select_offensive_monster_action:
	movem.l	d0/d1/a2,-(sp)
	move.b	Part_flags(a0),d1		; Capable of anything ?
	andi.b	#%00001100,d1		; (no magic)
	beq.s	.Exit
.Again:	jsr	Random			; Yes -> Select capability
	andi.w	#$000f,d0
	move.b	.Distribution(pc,d0.w),d0
	bclr	d0,d1			; Capable ?
	beq.s	.Again			; No -> Re-select
	lsl.w	#2,d0			; Try action
	movea.l	.Vectors-4(pc,d0.w),a2
	jsr	(a2)
	tst.b	Part_action(a0)		; Success ?
	bne.s	.Exit
	tst.b	d1			; Tried everything ?
	bne.s	.Again
.Exit:	movem.l	(sp)+,d0/d1/a2
	rts

.Distribution:
	dcb.b 8,Part_magic_cap
	dcb.b 6,Part_long_cap
	dcb.b 2,Part_close_cap
	even
.Vectors:
	dc.l Try_close_range_attack		; (magic)
	dc.l Try_long_range_attack
	dc.l Try_close_range_attack

; [ Try long-range attack ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
Try_long_range_attack:
	movem.l	d0-d7/a2-a4,-(sp)
	move.w	Body_conditions(a1),d0	; Capable of fighting ?
	andi.w	#Attack_mask,d0
	bne	.Exit
; ---------- Long-range weapon ? ------------------
	move.w	Char_inventory+Right_hand_slot+Object_index(a1),d0
	beq	.Search			; Nothing ?
	jsr	Get_item_data_a2
	cmp.b	#Longrange_itemtype,Item_type(a2)	; Long range ?
	bne	.Exit
	move.w	Damage(a1),d0		; Get damage
	add.w	Damage_magic(a1),d0
	tst.w	d0			; Any ?
	beq	.Search
; ---------- Check long-range weapon --------------
	move.w	Char_inventory+Left_hand_slot+Object_index(a1),d0
	move.b	Ammo_use_ID(a2),d1		; Get required ammo ID
	beq	.Attack			; (if any!)
	tst.w	d0			; Anything ?
	beq.s	.Drop
	move.l	a2,a3
	jsr	Get_item_data_a2
	exg	a2,a3
	cmp.b	Ammo_ID(a3),d1		; Is correct ?
	beq.s	.Attack
; ---------- Drop weapon --------------------------
.Drop:	move.l	a0,-(sp)			; Put away
	lea.l	Char_inventory+Right_hand_slot(a1),a0
	jsr	Put_item_in_apres_pool
	move.l	a1,a0			; Remove
	moveq.l	#Right_hand+1,d2
	moveq.l	#1,d3
	jsr	Remove_item
	move.l	(sp)+,a0
	move.w	#231,d0			; " dropped weapon."
	jsr	Do_part_prompt
; ---------- Search weapon ------------------------
.Search:	jsr	Search_another_weapon
	tst.w	d7			; Found any ?
	bmi.s	.Exit
	bne.s	.Attack			; Yes -> Long- or close-range ?
	jsr	Select_close_range_target	; Close range
	bra.s	.Exit
.Attack:	jsr	Select_long_range_target	; Select
.Exit:	movem.l	(sp)+,d0-d7/a2-a4
	rts

; [ Get item data into a2 ]
;   IN : d0 - Object index (.w)
;  OUT : a2 - Pointer to item data (.l)
; Changed registers : a2
Get_item_data_a2:
	move.l	a1,-(sp)
	jsr	Get_item_data
	move.l	a1,a2
	move.l	(sp)+,a1
	rts

; [ Select long-range target ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
Select_long_range_target:
	movem.l	d0/d1,-(sp)
	jsr	Get_longrange_targets	; Get targets
	tst.l	d0			; Any ?
	beq.s	.Exit
	jsr	Select_monster_target	; Yes -> Select
	move.w	d1,Cpart_target(a0)		; Store
	move.b	#Long_range_action,Part_action(a0)
.Exit:	movem.l	(sp)+,d0/d1
	rts

; [ Try close-range attack ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
Try_close_range_attack:
	movem.l	d0/d7/a2/a3,-(sp)
	move.w	Body_conditions(a1),d0	; Capable of fighting ?
	andi.w	#Attack_mask,d0
	bne.s	.Exit
; ---------- Close-range weapon ? -----------------
	move.w	Char_inventory+Right_hand_slot+Object_index(a1),d0
	beq.s	.Empty			; Nothing ?
	jsr	Get_item_data_a2
	cmp.b	#Closerange_itemtype,Item_type(a2)	; Close range ?
	bne.s	.Exit
.Empty:	move.w	Damage(a1),d0		; Get damage
	add.w	Damage_magic(a1),d0
	tst.w	d0			; Any ?
	bne.s	.Yes
; ---------- Search weapon ------------------------
	jsr	Search_another_weapon	; No
	tst.w	d7			; Found any ?
	bmi.s	.Exit
	beq.s	.Yes			; Yes -> Long- or close-range ?
	jsr	Select_long_range_target	; Long-range
	bra.s	.Exit
.Yes:	jsr	Select_close_range_target	; Select
.Exit:	movem.l	(sp)+,d0/d7/a2/a3
	rts

; [ Select close-range target ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
; All registers are restored
Select_close_range_target:
	movem.l	d0-d6,-(sp)
; ---------- Anything attackable ? ----------------
	jsr	Get_closerange_targets	; Get possible targets
	tst.l	d0			; Any ?
	bne	.Attack
; ---------- Move where ? -------------------------
	jsr	Get_occupied_targets	; Get occupied targets
	move.l	d0,d1
	jsr	Check_movement_range	; Get movement range
	not.l	d1			; Remove occupied targets
	and.l	d1,d0
	tst.l	d0			; Any left ?
	beq.s	.Just
	move.l	d0,d5			; Yes
	moveq.l	#0,d1			; Coordinates
	moveq.l	#0,d2
	moveq.l	#0,d3			; Complete mask
	moveq.l	#0,d6			; Search movement range
.Loop2:	btst	d6,d5			; In range ?
	beq.s	.Next2
	move.w	d2,d0			; Get close-range targets
	jsr	Do_closerange_targets
	or.l	d0,d3
.Next2:	addq.w	#1,d2			; Next
	cmp.w	#6,d2
	bmi.s	.No
	moveq.l	#0,d2
	addq.w	#1,d1
.No:	addq.w	#1,d6
	cmp.w	#4*6,d6
	bmi.s	.Loop2
	tst.l	d3			; Any targets in reach ?
	bne.s	.Move
; ---------- Just move ----------------------------
.Just:	jsr	Just_move_monster		; No -> Just move
	bra	.Exit
; ---------- Move towards a target ----------------
.Move:	move.l	d3,d0			; Select target
	jsr	Select_monster_target
	move.w	d1,d3
	moveq.l	#0,d1			; Coordinates
	moveq.l	#0,d2
	moveq.l	#0,d6			; Search movement range
.Loop3:	btst	d6,d5			; In range ?
	beq.s	.Next3
	move.w	d2,d0			; Get close-range targets
	jsr	Do_closerange_targets
	btst	d3,d0			; Is this the one ?
	beq.s	.Next3
	move.w	#1,Cpart_target(a0)		; Store
	move.w	d6,Cpart_target+2(a0)
	move.b	#Move_action,Part_action(a0)
	bra.s	.Exit
.Next3:	addq.w	#1,d2			; Next
	cmp.w	#6,d2
	bmi.s	.No2
	moveq.l	#0,d2
	addq.w	#1,d1
.No2:	addq.w	#1,d6
	cmp.w	#4*6,d6
	bmi.s	.Loop3
	bra.s	.Exit			; (shouldn't occur)
; ---------- Attack a target ----------------------
.Attack:	jsr	Select_monster_target	; Select target
	move.w	d1,Cpart_target(a0)		; Store
	move.b	#Close_range_action,Part_action(a0)
.Exit:	movem.l	(sp)+,d0-d6
	rts

; [ Select target for monster ]
;   IN : d0 - Possible target bit-list (.l)
;        a0 - Pointer to monster's participant data (.l)
;  OUT : d1 - Target number {0...29} (.w)
; Changed registers : d1
Select_monster_target:
	movem.l	d0/d2-d5/d7/a2/a3,-(sp)
;----------- Find strongest targets ---------------
	lea.l	Combat_matrix,a2
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d7
.Loop:	btst	d7,d0			; Target ?
	beq.s	.Next
	move.l	(a2),a3			; Yes -> Get data
	move.w	Cpart_mean_damage(a3),d5	; Get mean damage
	cmp.w	d5,d1			; More mean damage ?
	bgt.s	.Next
	bmi.s	.New			; No -> Same ?
	bset	d7,d2			; Yes -> Mark
	addq.w	#1,d3
	bra.s	.Next
.New:	move.w	d5,d1			; More
	moveq.l	#0,d2
	bset	d7,d2
	moveq.l	#1,d3
.Next:	addq.l	#4,a2			; Next
	addq.w	#1,d7
	cmp.w	#6*5,d7
	bmi.s	.Loop
; ---------- Choose one ---------------------------
	jsr	Random			; Select
	mulu.w	d3,d0
	swap	d0
	moveq.l	#0,d1
.Loop2:	btst	d1,d2			; Target ?
	beq.s	.Next2
	tst.w	d0			; Selected ?
	beq.s	.Exit
	subq.w	#1,d0			; Count down
.Next2:	addq.w	#1,d1			; Next
	cmp.w	#6*5,d1
	bmi.s	.Loop2
	moveq.l	#0,d1			; (shouldn't occur)
.Exit:	movem.l	(sp)+,d0/d2-d5/d7/a2/a3
	rts

; [ Just move monster forward ]
;   IN : d5 - Movement range (.l)
;        a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
;  OUT : d5 - New movement range (.l)
; Changed registers : d5
Just_move_monster:
	movem.l	d0-d3/d7/a2,-(sp)
	lea.l	Cpart_target(a0),a2		; Reset number of moves
	clr.w	(a2)+
	move.w	Cpart_X(a0),d0		; Get coordinates
	move.w	Cpart_Y(a0),d1
	move.w	d1,d2			; Get tactic index
	mulu.w	#6,d2
	add.w	d0,d2
	jsr	Get_move_range		; Get movement speed
	bra.s	.Entry
.Loop:	cmp.w	#3,d1			; Downest ?
	bne.s	.Down
	move.w	d2,d3			; Yes -> Try left/right
	jsr	Offensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	beq.s	.Done
	bclr	d3,d5			; Yes -> No turning back !
	bra.s	.Next
.Down:	move.w	d2,d3			; Down possible ?
	addq.w	#6,d3
	btst	d3,d5
	beq.s	.No
	addq.w	#1,d1			; Yes -> Move down
	addq.w	#6,d2
	bra.s	.Next
.No:	addq.w	#1,d1			; No -> Move down...
	addq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Offensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	bne.s	.Next
	subq.w	#1,d1			; No -> Move back up...
	subq.w	#6,d2
	move.w	d2,d3			; ...and try left/right
	jsr	Offensive_left_or_right
	cmp.w	d2,d3			; Moved ?
	beq.s	.Done
	bclr	d3,d5			; Yes -> No turning back !
.Next:	move.w	d2,(a2)+			; Store move
	addq.w	#1,Cpart_target(a0)
.Entry:	dbra	d7,.Loop			; Next step
.Done:	tst.w	Cpart_target(a0)		; Moved ?
	beq.s	.Exit
	move.b	#Move_action,Part_action(a0)	; Set action
.Exit:	movem.l	(sp)+,d0-d3/d7/a2
	rts

; [ Try OFFENSIVE movement to the left or to the right ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Tactic index {0...29} (.w)
;        d5 - Movement range mask (.l)
;  OUT : d0 - New X-coordinate (.w)
;        d2 - New tactic index {0...29} (.w)
; Changed registers : d0,d2
Offensive_left_or_right:
	movem.l	d3/d7/a0/a1,-(sp)
; ---------- Both left & right possible ? ---------
	tst.w	d0			; Leftest ?
	beq.s	.Right1
	cmp.w	#5,d0			; Rightest ?
	beq.s	.Left1
	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq.s	.Right1
	addq.w	#2,d3			; Right possible ?
	btst	d3,d5
	beq.s	.Left1
; ---------- Which is better ? --------------------
	lea.l	Combat_matrix+3*6*4,a0	; Check matrix
	moveq.l	#0,d3
	moveq.l	#0,d7
.Loop:	cmp.w	d0,d7			; Directly below ?
	beq.s	.Next
	tst.l	(a0)			; Anything in top row ?
	beq.s	.Bottom
	move.l	(a0),a1			; Is enemy ?
	cmp.b	#1,Part_type(a1)
	bne.s	.Bottom
	cmp.w	d7,d0			; Left or right ?
	bmi.s	.Right3
	sub.w	Cpart_mean_damage(a1),d3	; Left
	bra.s	.Bottom
.Right3:	add.w	Cpart_mean_damage(a1),d3	; Right
.Bottom:	tst.l	6*4(a0)			; Anything in bottom row ?
	beq.s	.Next
	move.l	(a0),a1			; Is enemy ?
	cmp.b	#1,Part_type(a1)
	bne.s	.Next
	cmp.w	d7,d0			; Left or right ?
	bmi.s	.Right4
	sub.w	Cpart_mean_damage(a1),d3	; Left
	bra.s	.Next
.Right4:	add.w	Cpart_mean_damage(a1),d3	; Right
.Next:	addq.l	#4,a0			; Next column
	addq.w	#1,d7
	cmp.w	#6,d7
	bmi.s	.Loop
	tst.w	d3			; Move where ?
	beq.s	.Exit
	bmi.s	.Left2
	bra.s	.Right2
; ---------- Try to move right --------------------
.Right1:	move.w	d2,d3			; Right possible ?
	addq.w	#1,d3
	btst	d3,d5
	beq.s	.Exit
.Right2:	addq.w	#1,d0			; Move right
	addq.w	#1,d2
	bra.s	.Exit
; ---------- Try to move left ---------------------
.Left1:	move.w	d2,d3			; Left possible ?
	subq.w	#1,d3
	btst	d3,d5
	beq.s	.Exit
.Left2:	subq.w	#1,d0			; Move left
	subq.w	#1,d2
.Exit:	movem.l	(sp)+,d3/d7/a0/a1
	rts

; [ Process damage done by participant ]
;   IN : d0 - Amount of damage (.w)
;        a0 - Pointer to attacker's participant data (.l)
; All registers are restored
Process_damage:
	movem.l	d0-d2,-(sp)
	moveq.l	#0,d1			; Count up
	move.b	Part_nr_attacks(a0),d1
	addq.b	#1,d1
	bne.s	.Ok			; Too much ?
	move.b	#255,d1			; Yes -> Clip
.Ok:	move.b	d1,Part_nr_attacks(a0)
	move.l	Cpart_total_damage(a0),d2	; Add to total damage
	andi.l	#$0000ffff,d0
	add.l	d0,d2
	move.l	d2,Cpart_total_damage(a0)
	divu.w	d1,d2			; Calculate mean damage
	move.w	d2,Cpart_mean_damage(a0)
	movem.l	(sp)+,d0-d2
	rts

; [ Calculate global danger ]
; All registers are restored
Calculate_global_danger:
	movem.l	d0-d2/d7/a0/a1,-(sp)
	lea.l	Combat_matrix,a0		; Search matrix
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#30-1,d7
.Loop:	tst.l	(a0)			; Anything there ?
	beq.s	.Next
	move.l	(a0),a1			; Yes
	moveq.l	#0,d2			; Get mean damage
	move.w	Cpart_mean_damage(a1),d2
	cmp.b	#1,Part_type(a1)		; Party or monster ?
	bne.s	.Monster
	add.l	d2,d0			; Party
	bra.s	.Next
.Monster:	add.l	d2,d1			; Monster
.Next:	addq.l	#4,a0			; Next entry
	dbra	d7,.Loop
	tst.l	d0			; Clip total mean damages
	bne.s	.Ok1
	moveq.l	#1,d0
	bra.s	.Clip1
.Ok1:	cmp.l	#32767,d0
	bmi.s	.Clip1
	move.l	#32767,d0
.Clip1:	tst.l	d1
	bne.s	.Ok2
	moveq.l	#1,d1
	bra.s	.Clip2
.Ok2:	cmp.l	#32767,d1
	bmi.s	.Clip2
	move.l	#32767,d1
.Clip2:	mulu.w	#50,d0			; Calculate global danger
	divu.w	d1,d0
	cmp.w	#100,d0			; Too high ?
	bmi.s	.Ok3
	moveq.l	#100,d0			; Yes
.Ok3:	move.w	d0,Global_danger		; Store
	movem.l	(sp)+,d0-d2/d7/a0/a1
	rts

; [ Search & equip new weapon for monster ]
;   IN : a0 - Pointer to monster's participant data (.l)
;        a1 - Pointer to monster's character data (.l)
;  OUT : d7 -  0 = Found close-range weapon
;              1 = Found long-range weapon
;             -1 = Found nothing
; All registers are restored
Search_another_weapon:
	movem.l	d0-d3/a2-a4,-(sp)
	lea.l	Char_inventory+Backpack_slots(a1),a2
	moveq.l	#9+1,d2
.Loop1:	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Next1
	btst	#Broken_item,Item_bits_DYNAMIC(a2)	; Broken ?
	bne.s	.Next1
	move.l	a2,-(sp)
	jsr	Get_item_data_a2
	move.l	a2,a3
	move.l	(sp)+,a2
	cmp.b	#Closerange_itemtype,Item_type(a3)	; Close range ?
	bne.s	.No
	moveq.l	#0,d7			; Yes
	bra	.Found_weapon
.No:	cmp.b	#Longrange_itemtype,Item_type(a3)	; Long range ?
	bne.s	.Next1
	moveq.l	#1,d7			; Yes
	bra.s	.Found_longrange
.Next1:	lea.l	Object_packet_size(a2),a2	; Next slot
	addq.w	#1,d2
	cmp.w	#9+Items_per_char+1,d2
	bmi.s	.Loop1
	move.w	Damage(a1),d0		; Get damage
	add.w	Damage_magic(a1),d0
	tst.w	d0			; Any ?
	beq.s	.Panic
	moveq.l	#0,d7			; Yes -> Close-range attack
	bra	.Exit
.Panic:	bclr	#Part_long_cap,Part_flags(a0)	; Not capable
	bclr	#Part_close_cap,Part_flags(a0)
	move.b	Courage(a1),d0		; Panic!
	lsr.b	#1,d0
	move.b	d0,Courage(a1)
	moveq.l	#-1,d7			; No luck
	bra	.Exit
; ---------- Search ammo for long-range weapon ----
.Found_longrange:
	move.b	Ammo_use_ID(a3),d1		; Get required ammo
	beq.s	.Found_weapon		; (if any)
	lea.l	Char_inventory+Backpack_slots(a1),a3
	moveq.l	#9+1,d3
.Loop2:	move.w	Object_index(a3),d0		; Any object ?
	beq.s	.Next2
	btst	#Broken_item,Item_bits_DYNAMIC(a3)	; Broken ?
	bne.s	.Next2
	jsr	Get_item_data_a4
	cmp.b	Ammo_ID(a4),d1		; Right ammo ?
	beq.s	.Found_ammo
.Next2:	lea.l	Object_packet_size(a3),a3	; Next slot
	addq.w	#1,d3
	cmp.w	#Items_per_char+9+1,d3
	bmi.s	.Loop2
	bra	.Next1			; Next weapon (!!!)
; ---------- Equip ammunition ---------------------
.Found_ammo:
	movem.l	d2/a0/a1,-(sp)
	lea.l	Inter_packet,a4		; Copy packet
	Copy_packet a3,a4
	move.l	a1,a0			; Remove ammo from backpack
	move.w	d3,d2
	moveq.l	#1,d3
	jsr	Remove_item
	lea.l	Inter_packet,a0		; Equip ammo
	moveq.l	#Left_hand+1,d2
	jsr	Add_item_2_body
	movem.l	(sp)+,d2/a0/a1
; ---------- Equip weapon -------------------------
.Found_weapon:
	movem.l	a0/a1,-(sp)
	lea.l	Inter_packet,a3		; Copy packet
	Copy_packet a2,a3
	move.l	a1,a0			; Remove weapon from backpack
	moveq.l	#1,d3
	jsr	Remove_item
	lea.l	Inter_packet,a0		; Equip weapon
	moveq.l	#Right_hand+1,d2
	jsr	Add_item_2_body
	movem.l	(sp)+,a0/a1
.Exit:	movem.l	(sp)+,d0-d3/a2-a4
	rts

; [ Get item data into a4 ]
;   IN : d0 - Object index (.w)
;  OUT : a4 - Pointer to item data (.l)
; Changed registers : a4
Get_item_data_a4:
	move.l	a1,-(sp)
	jsr	Get_item_data
	move.l	a1,a4
	move.l	(sp)+,a1
	rts

;*****************************************************************************
; [ End of combat ]
; NOTE :
;   - From [ Combat_ModExit ] and APRES.S.
;*****************************************************************************
Combat_exit:
	movem.l	d0-d7/a0-a6,-(sp)
	sf	Battling
	moveq.l	#1,d0			; Fade out
	jsr	Fade_screen
	clr.l	Ghost_text
	clr.l	Ghost_text2
	jsr	Reload_map_graphics		; (overwritten by the combat)
	cmp.b	#Combat_lost,Combat_result	; Lost ?
	bne.s	.Not_over
	jsr	Game_over			; Yes -> Game over !
	bra	.Exit
.Not_over:	cmp.b	#Combat_fled,Combat_result	; Everyone fled ?
	bne.s	.Heroic
	jsr	Restore_coordinates		; Back !
	sf	Success
	move.w	#Monster_delay_time,Monster_move_delay	; Wait
	jsr	Reset_after_combat
	jsr	Back_to_map
	bra	.Exit
.Heroic:	move.w	Combat_char_index,d0	; Encounter event ?
	bmi.s	.Go_on
	move.w	Map_nr,d1			; No -> Get CD bit number
	subq.w	#1,d1
	mulu.w	#Max_chars,d1
	add.w	d1,d0
	moveq.l	#CD_bit_array,d1		; Set bit in CD array
	moveq.l	#1,d2
	jsr	Access_bit_array
	jsr	Get_CD_value		; Reset internal CD
.Go_on:	jsr	Reset_after_combat		; It's okay now
	jsr	Divide_EP			; Divide EP
	move.l	d0,d7
	jsr	Pool_apres_items		; Any loot ?
	tst.w	Nr_apres_objects
	bne.s	.Loot
	tst.w	Apres_gold
	bne.s	.Loot
	tst.w	Apres_food
	beq.s	.No_loot
.Loot:	jsr	Apres_combat		; Yes -> Divide the loot
	bra.s	.Exit
.No_loot:	jsr	Back_to_map		; No
	tst.l	d7			; Any EP ?
	beq.s	.Exit
	jsr	Make_EP_text		; Yes -> Tell
	jsr	Text_window
	moveq.l	#0,d0			; (text window)
	jsr	Check_member_levels
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

; [ Back to the map screen ]
; All registers are restored
Back_to_map:
	movem.l	d0/a0,-(sp)
	jsr	Recalc_mapbuf_coords
	lea.l	Map_RL,a0
	jsr	Set_raster_list
	jsr	Display_status_block
	jsr	Draw_map_screen
	moveq.l	#0,d0			; Fade in
	jsr	Fade_screen
	jsr	Clear_keyboard
	jsr	Read_mouse_clicks
	movem.l	(sp)+,d0/a0
	rts

; [ Load the map graphics again ]
; All registers are restored
Reload_map_graphics:
	movem.l	d0-d3/a0/a1,-(sp)
	move.w	Current_tileset,d0		; Icon graphics
	lea.l	Icon_graphics,a1
	move.l	#Max_icons*16*8,d1
	moveq.l	#'I',d2
	jsr	Load_numbered_file
	move.w	Current_NPC_file,d0		; NPC graphics
	ble.s	.No_NPCs
	move.w	Current_tileset,d1
	moveq.l	#'N',d2
	lea.l	NPC_graphics,a1
	move.l	#Max_NPC_graphics,d3
	jsr	Load_sprite_file
.No_NPCs:	jsr	Invalidate_tile_caches
	movem.l	(sp)+,d0-d3/a0/a1
	rts

; [ Make the text "Everyone gets ... experience points" ]
;   IN : d7 - EP per member (.l)
;  OUT : a0 - Pointer to text (.l)
; Changed registers : a0
Make_EP_text:
	movem.l	d0/d7/a1,-(sp)
	move.l	d7,d0			; Convert EP
	lea.l	Combat_number,a0
	moveq.l	#5,d7
	jsr	DecL_convert
	move.l	#Combat_number,Format_args
	moveq.l	#EP_txt,d0
	lea.l	Format_buffer,a1
	jsr	Format_text
	lea.l	Format_buffer,a0
	movem.l	(sp)+,d0/d7/a1
	rts

; [ Check member levels ]
;   IN : d0 - 0 = text window, 1 = print area (.w)
; All registers are restored
; NOTE :
;   - Like [ Check_member_levels ] and [ Make_levels ] (MAIN.S) : the
;     values of the members who made a level are increased and a text
;     tells it.
Check_member_levels:
	movem.l	d0-d7/a0-a3,-(sp)
	move.w	d0,d5
	moveq.l	#1,d7
.Loop:	jsr	Get_char_data
	move.w	Body_conditions(a1),d0	; Alive ?
	andi.w	#Alive_mask,d0
	bne	.Next
	moveq.l	#0,d4			; Count levels
	lea.l	Level_start_EPs,a2		; Get start EP
	moveq.l	#0,d0
	move.b	Char_class(a1),d0
	add.w	d0,d0
	move.w	0(a2,d0.w),d1
.Again:	moveq.l	#0,d2			; Get current level
	move.b	Level_nr(a1),d2
	cmpi.w	#Max_level,d2		; Maximum level ?
	bpl.s	.Done
	move.w	d2,d0			; Get EP factor
	addq.w	#1,d0			;  (L+1)*(L+2)/2
	addq.w	#2,d2
	mulu.w	d2,d0
	lsr.l	#1,d0
	mulu.w	d1,d0			; Get total EP
	cmp.l	Experience_points(a1),d0	; Enough ?
	bgt.s	.Done
	addq.w	#1,d4			; Yes -> Make level
	jsr	Make_level
	bra.s	.Again
.Done:	tst.w	d4			; Any ?
	beq.s	.Next
	lea.l	Char_name(a1),a0		; Yes -> Tell
	move.l	a0,Format_args
	lea.l	Combat_number,a0
	moveq.l	#0,d0
	move.b	Level_nr(a1),d0
	move.l	d7,-(sp)
	moveq.l	#2,d7
	jsr	DecL_convert
	move.l	(sp)+,d7
	move.l	#Combat_number,Format_args+4
	moveq.l	#Level_txt,d0
	move.l	a1,-(sp)
	lea.l	Format_buffer,a1
	jsr	Format_text
	move.l	(sp)+,a1
	lea.l	Format_buffer,a0
	tst.w	d5
	bne.s	.PA
	jsr	Text_window
	bra.s	.Shown
.PA:	jsr	Show_PA_text
.Shown:	jsr	Force_status_update
.Next:	addq.w	#1,d7			; Next member
	cmp.w	#6+1,d7
	bmi	.Loop
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; [ Make a level ]
;   IN : a1 - Pointer to character data (.l)
; All registers are restored
Make_level:
	movem.l	d0/d1,-(sp)
	addq.b	#1,Level_nr(a1)		; Next level
	moveq.l	#0,d0			; Calculate new APR
	move.b	Level_nr(a1),d0
	move.w	Special_1(a1),d1		; Factor zero ?
	beq.s	.One
	divu.w	d1,d0			; No -> Calculate
	tst.w	d0
	bne.s	.Ok1			; At least 1
.One:	moveq.l	#1,d0
.Ok1:	move.b	d0,Attacks_per_round(a1)	; Store
	move.w	Special_2(a1),d0		; Calculate extra LP & LP max
	jsr	Get_random_50_100
	add.w	d0,Life_points(a1)		; Add
	add.w	d0,Life_points+Maximum(a1)
	tst.b	Spell_class_counter(a1)	; Any spell classes ?
	beq.s	.No_magic
	move.w	Special_3(a1),d0		; Calculate extra SP & SP max
	jsr	Get_random_50_100
	moveq.l	#0,d1			; Intelligence bonus
	move.w	AIntelligence(a1),d1
	divu.w	#20,d1
	add.w	d1,d0
	add.w	d0,Power_points(a1)		; Add
	add.w	d0,Power_points+Maximum(a1)
	move.w	Special_4(a1),d0		; Calculate extra SLP
	jsr	Get_random_50_100
	moveq.l	#0,d1			; Intelligence bonus
	move.w	AIntelligence(a1),d1
	divu.w	#20,d1
	add.w	d1,d0
	add.w	d0,Nr_spell_learn_points(a1)	; Add
.No_magic:	move.w	Special_5(a1),d0		; Calculate extra TP
	jsr	Get_random_50_100
	add.w	d0,Nr_training_points(a1)	; Add
	movem.l	(sp)+,d0/d1
	rts

; [ Game over ]
; All registers are restored
; NOTE :
;   - The proof of concept ends.
Game_over:
	move.l	a0,-(sp)
	jsr	Back_to_map
	lea.l	Game_over_text,a0
	jsr	Text_window
	st	Quit_flag
	move.l	(sp)+,a0
	rts

; [ Reset after combat ]
; All registers are restored
Reset_after_combat:
	movem.l	d7/a1,-(sp)
	lea.l	Party_status_icons,a1	; (no combat icons)
	moveq.l	#6-1,d7
.Clear:	clr.b	(a1)+
	dbra	d7,.Clear
	moveq.l	#1,d7			; Clear battle conditions
.Loop:	jsr	Get_char_data
	andi.w	#Reset_mask,Body_conditions(a1)
	jsr	Force_status_update
	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	jsr	AutoIcon_switch
	movem.l	(sp)+,d7/a1
	rts

; [ Divide experience points ]
;  OUT : d0 - EP per member (.l)
; All registers are restored
Divide_EP:
	movem.l	d1/d7/a1,-(sp)
	jsr	Count_members		; Divide over how many ?
	tst.w	d0			; Anyone ?
	beq.s	.None
	move.l	Gained_experience,d1	; Calculate EP per member
	beq.s	.None
	divu.w	d0,d1
	andi.l	#$0000ffff,d1
	bne.s	.Notzero			; At least 1
	moveq.l	#1,d1
.Notzero:	moveq.l	#1,d7			; Divide EP
.Loop:	jsr	Get_char_data
	move.w	Body_conditions(a1),d0	; Alive and kicking ?
	andi.w	#Alive_mask,d0
	bne.s	.Next
	add.l	d1,Experience_points(a1)	; Yes -> Experience
.Next:	addq.w	#1,d7
	cmp.w	#6+1,d7
	bmi.s	.Loop
	move.l	d1,d0			; Output
	bra.s	.Exit
.None:	moveq.l	#0,d0			; No EP
.Exit:	movem.l	(sp)+,d1/d7/a1
	rts

; [ Pool the items of the apres pool ]
; All registers are restored
; NOTE :
;   - From APRES.S. Afterwards the items are at the start of the pool.
Pool_apres_items:
	movem.l	d0-d2/d7/a0-a3,-(sp)
	lea.l	Apres_pool,a2
	move.w	Nr_apres_objects,d7
	bra.s	.Entry1
.Loop1:	move.w	Object_index(a2),d0		; Anything there ?
	beq.s	.Next1
	move.l	a1,-(sp)			; Yes -> Multiple ?
	jsr	Get_item_data
	btst	#Multiple,Item_bits_STATIC(a1)
	move.l	(sp)+,a1
	beq.s	.Next1
	lea.l	Apres_pool,a3		; Yes -> Try to pool
	moveq.l	#0,d1
	move.b	Quantity(a2),d1
.Loop2:	cmp.l	a2,a3			; End reached ?
	beq.s	.Next1
	cmp.w	Object_index(a3),d0		; Same item ?
	bne.s	.Next2
	cmpi.b	#99,Quantity(a3)		; Not full ?
	bcc.s	.Next2
	moveq.l	#0,d2			; Does it fit in the slot ?
	move.b	Quantity(a3),d2
	add.w	d1,d2
	cmpi.w	#99,d2
	bls.s	.Fit
	moveq.l	#99,d2			; Calculate number that will
	sub.b	Quantity(a3),d2		;  fit
	sub.w	d2,d1
	move.b	#99,Quantity(a3)		; Fill slot
	sub.b	d2,Quantity(a2)		; Remove item(s)
	bra.s	.Next2
.Fit:	add.b	d1,Quantity(a3)		; Transfer completely
	clr.b	Quantity(a2)
	clr.w	Object_index(a2)
	bra.s	.Next1
.Next2:	lea.l	Object_packet_size(a3),a3	; Next packet
	bra.s	.Loop2
.Next1:	lea.l	Object_packet_size(a2),a2	; Next packet
.Entry1:	dbra	d7,.Loop1
; ---------- Move everything to the front ---------
	lea.l	Apres_pool,a1
	move.l	a1,a2
	moveq.l	#0,d0
	move.w	Nr_apres_objects,d7
	bra.s	.Entry3
.Loop3:	tst.w	Object_index(a1)		; Packet empty ?
	beq.s	.Next3
	cmp.l	a1,a2			; No -> Move
	beq.s	.Same
	Copy_packet a1,a2
	clr.w	Object_index(a1)
.Same:	lea.l	Object_packet_size(a2),a2
	addq.w	#1,d0			; Count
.Next3:	lea.l	Object_packet_size(a1),a1	; Next packet
.Entry3:	dbra	d7,.Loop3
	move.w	d0,Nr_apres_objects		; Store number
	movem.l	(sp)+,d0-d2/d7/a0-a3
	rts

; [ Apres combat : divide the loot ]
; All registers are restored
; NOTE :
;   - Like the Apres module : the opened chest screen with the trash pile
;     (up to 24 items).
Apres_combat:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Chest_work,a1		; Fill chest
	move.w	#Chest_size/2-1,d7
.Clear:	clr.w	(a1)+
	dbra	d7,.Clear
	lea.l	Apres_pool,a0
	lea.l	Chest_work,a1
	move.w	Nr_apres_objects,d7
	cmp.w	#Items_per_chest,d7
	bls.s	.Ok
	move.w	#Items_per_chest,d7
.Ok:	bra.s	.Entry
.Loop:	Copy_packet a0,a1
	lea.l	Object_packet_size(a0),a0
	lea.l	Object_packet_size(a1),a1
.Entry:	dbra	d7,.Loop
	move.w	Apres_gold,Chest_work+Chest_gold
	move.w	Apres_food,Chest_work+Chest_food
	lea.l	Current_event_data,a5	; Behave like a pile
	move.b	Event_b3(a5),-(sp)
	move.b	Event_b5(a5),-(sp)
	st	Event_b3(a5)		; (no text)
	move.b	#%11,Event_b5(a5)		; (pile, no write back)
	move.w	Map_Xcoord,Old_Xcoord	; (stay here)
	move.w	Map_Ycoord,Old_Ycoord
	moveq.l	#Trashpile_pic,d0		; Show screen
	move.w	d0,Chest_pic
	move.w	#2,Lay3_type
	lea.l	OpenedChest_CIL,a0
	jsr	Show_lay3
	move.w	#2,Lay3_type
	jsr	Show_chest
	tst.l	d7			; Any EP ?
	beq.s	.No_EP
	jsr	Make_EP_text		; Yes -> Tell
	jsr	Show_PA_text
	moveq.l	#1,d0			; (print area)
	jsr	Check_member_levels
.No_EP:	move.w	#133,d0			; "After the battle..."
	jsr	Print_prompt
	jsr	Copy_screen_to_both
	jsr	Opened_chest_loop
	lea.l	Current_event_data,a5
	move.b	(sp)+,Event_b5(a5)
	move.b	(sp)+,Event_b3(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; Data
;*****************************************************************************
	SECTION	Fast_DATA,data

; Raster list of the combat screen : the palette of the combat background
; (and the monsters) in the combat window, the inventory palette below
Combat_RL:	R_palette 0,UI_palette
	R_range 1,25,35,Portrait_range
	R_palette Combat_Y,Combat_palette
	R_palette Combat_Y+Combat_height+1,Inv_palette
	R_end
	even

Combat_CA:	dc.w Combat_X,Combat_X+Combat_width-1
	dc.w Combat_Y,Combat_Y+Combat_height-1

; Plane bits of the 16 colours (index = colour * 4) : planes 0...3 in the
; bytes 3...0
Plane_table:
	dc.l $00000000,$01000000,$00010000,$01010000
	dc.l $00000100,$01000100,$00010100,$01010100
	dc.l $00000001,$01000001,$00010001,$01010001
	dc.l $00000101,$01000101,$00010101,$01010101

Race_heights:					; (KERNEL/DATA.S)
	dc.w $b4,$be,$96,$78,$c3,$a0,$be,$af,$b4
	dc.w $b4,$b4,$b4,$b4,$b4,$b4,$b4

Very_small_numbers:				; (COMBAT.S)
	dc.b $60,$d0,$d0,$d0,$60		; 0
	dc.b $30,$70,$30,$30,$30		; 1
	dc.b $e0,$30,$60,$c0,$f0		; 2
	dc.b $e0,$30,$60,$30,$e0		; 3
	dc.b $20,$60,$d0,$f0,$30		; 4
	dc.b $f0,$c0,$e0,$30,$e0		; 5
	dc.b $60,$c0,$e0,$d0,$60		; 6
	dc.b $f0,$30,$60,$c0,$c0		; 7
	dc.b $60,$d0,$60,$d0,$60		; 8
	dc.b $60,$b0,$70,$30,$60		; 9
	even

Level_start_EPs:				; (KERNEL/DATA.S)
	dc.w $4b,$96,$b4,$64,$7d,$5a,$5a,$5a,$5f,$7fff
	dc.w $7fff,$7fff,$7fff,$7fff,$7fff,$7fff

Red_cross:					; (16x13)
	dc.w $0000,$4004,$2008,$1010,$0820,$0440,$0280
	dc.w $0440,$0820,$1010,$2008,$4004,$0000

Game_over_text:	dc.b "Die Gruppe wurde besiegt.",0
	even

	SECTION	Fast_BSS,bss
Battling:	ds.b 1
	even
Combat_palette:	ds.b 64			; Palette & lookup table
Tactic_strength:	ds.b 8
Very_small_buffer:	ds.w 5
Zoom_X:	ds.w 1			; (in this order)
Zoom_Y:	ds.w 1
Zoom_srcw:	ds.w 1
Zoom_srch:	ds.w 1
Zoom_w:	ds.w 1
Zoom_h:	ds.w 1
Zoom_ys:	ds.w 1
Zoom_ye:	ds.w 1
Zoom_x0:	ds.w 1
Zoom_count:	ds.w 1
Zoom_last_sy:	ds.w 1
Zoom_gfx:	ds.l 1
Zoom_ystep:	ds.l 1
Zoom_ypos:	ds.l 1
Zoom_row:	ds.l 1
Zoom_xtab:	ds.w Combat_width
Zoom_chunky:	ds.b 512
Chunky_table:	ds.b 256*8
COMOB_sort_list:	ds.l Max_COMOBs
COMOB_table:	ds.b Max_COMOBs*Co_size
Spare_COMOB:	ds.b Co_size
	even
