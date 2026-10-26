; ST kernel : text output (fonts, runes)
; Replaces KERNEL/TEXT.S of the Amiga version. The glyphs are drawn into the
; 1 bit text line buffer like in the Amiga version (Draw_glyphs, Render_glyph
; and the text commands are taken from it, without the blitter), then the
; buffer is put on the screen with the shadow and ink colours (the Amiga
; colours become ST colours, [ Get_ST_colour ]).

	SECTION	Program,code

;*****************************************************************************
; [ Print a text line ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to text (.l)
;  OUT : a0 - Pointer behind the text (.l)
; All other registers are restored
; NOTE :
;   - Uses [ Ink_colour ] and [ Shadow_colour ] (Amiga colour numbers,
;     shadow : -1 = none, drawn 1 pixel right and down).
;*****************************************************************************
Put_text_line:
	movem.l	d0-d7/a1-a4,-(sp)
	move.w	d0,-(sp)
	andi.w	#$f,d0
	jsr	Draw_glyphs
	move.l	a0,a4
	move.w	d0,d6			; Number of truncs
	addi.w	#15+1,d6			; (+1 : shadow)
	lsr.w	#4,d6
	move.w	(sp)+,d0
	andi.w	#-$10,d0
	move.w	Shadow_colour,d4		; Shadow
	bmi.s	.No_shadow
	addq.w	#1,d1
	jsr	Get_ST_colour
	moveq.l	#1,d5
	jsr	Put_text_buffer
	subq.w	#1,d1
.No_shadow:	move.w	Ink_colour,d4		; Ink
	jsr	Get_ST_colour
	moveq.l	#0,d5
	jsr	Put_text_buffer
	move.l	a4,a0
	movem.l	(sp)+,d0-d7/a1-a4
	rts

;*****************************************************************************
; [ Put the text line buffer on the work screen ]
;   IN : d0 - X-coordinate (multiple of 16) (.w)
;        d1 - Y-coordinate (.w)
;        d4 - ST colour (.w)
;        d5 - Shift to the right (0 or 1) (.w)
;        d6 - Number of truncs (.w)
; All registers are restored
;*****************************************************************************
Put_text_buffer:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Make_clip_masks		; (clipped like the Amiga version)
	move.w	d1,a4			; Y
	move.w	d0,d2
	lsr.w	#3,d2			; (chunk * 2)
	lea.l	Clip_masks,a5
	add.w	d2,a5
	move.l	Work_screen,a1
	jsr	Get_screen_offset
	add.l	d2,a1
	lea.l	Text_line_bit_plane_buffer,a0
	move.w	d6,d7			; Truncs to draw
	add.w	d5,d7
	lsr.w	#4,d0			; Not more than the screen
	moveq.l	#20,d2
	sub.w	d0,d2
	cmp.w	d2,d7
	ble.s	.Ok
	move.w	d2,d7
.Ok:	subq.w	#1,d7
	bmi	.Exit
	move.w	#200,d3			; Lines
	sub.w	d1,d3
	ble	.Exit
	cmp.w	#Char_height,d3
	ble.s	.Ok2
	moveq.l	#Char_height,d3
.Ok2:	subq.w	#1,d3
.Line:	cmpa.w	Clip_Y1,a4		; Line visible ?
	blt	.Skip_line
	cmpa.w	Clip_Y2,a4
	bgt	.Skip_line
	move.l	a0,a2
	move.l	a1,a3
	move.l	a5,-(sp)
	moveq.l	#0,d2			; Previous word
	move.w	d7,d0
	move.w	d6,a6			; Words left in the buffer line
.Trunc:	swap	d2			; Previous word -> high word
	clr.w	d2
	cmp.w	#0,a6
	ble.s	.Empty
	move.w	(a2)+,d2
	subq.w	#1,a6
.Empty:	move.l	d2,d1			; Mask
	lsr.l	d5,d1
	and.w	(a5)+,d1			; Clip
	btst	#0,d4			; Plane 0
	beq.s	.C0
	or.w	d1,(a3)+
	bra.s	.P1
.C0:	not.w	d1
	and.w	d1,(a3)+
	not.w	d1
.P1:	btst	#1,d4			; Plane 1
	beq.s	.C1
	or.w	d1,(a3)+
	bra.s	.P2
.C1:	not.w	d1
	and.w	d1,(a3)+
	not.w	d1
.P2:	btst	#2,d4			; Plane 2
	beq.s	.C2
	or.w	d1,(a3)+
	bra.s	.P3
.C2:	not.w	d1
	and.w	d1,(a3)+
	not.w	d1
.P3:	btst	#3,d4			; Plane 3
	beq.s	.C3
	or.w	d1,(a3)+
	bra.s	.Next
.C3:	not.w	d1
	and.w	d1,(a3)+
.Next:	dbra	d0,.Trunc
	move.l	(sp)+,a5
.Skip_line:	lea.l	40(a0),a0			; Next line
	lea.l	ST_bytes_per_line(a1),a1
	addq.w	#1,a4
	dbra	d3,.Line
.Exit:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Draw the glyphs of a text line into the text line buffer ]
;   IN : d0 - X-offset (0...15) (.w)
;        a0 - Pointer to text (.l)
;  OUT : d0 - Width in pixels (.w)
;        a0 - Pointer to text line buffer (.l)
;*****************************************************************************
Draw_glyphs:
	movem.l	d1/a1-a3,-(sp)
	move.w	d0,-(sp)
	move.l	a0,a2		; A2 is the input string
	move.l	#200,d0		; 200 bytes
	moveq.l	#0,d1		; Zero
	lea.l	Text_line_bit_plane_buffer,a0
	jsr	Fill_memory		; Fills the array with 200 zeros
	move.l	a0,a1		; A1 is the cleared array
	lea.l	Glyph_data,a0		; A0 is the glyph data
	tst.b	Rune_flag		; Select glyph mapping based on
					; "print runes" flag.
	beq.s	.Skip
	lea.l	Rune_glyph_mapping,a3
	bra.s	.Skip2
.Skip:
	lea.l	Glyph_mapping,a3
.Skip2:
	move.w	(sp)+,d0
.Loop:
	move.b	(a2)+,d1		; Get next character
	beq.w	.Exit		; If 0, abort
	cmp.b	#126,d1		; Found ~ so we check for
					; wildcards and stuff and
					; ignore it here as we only
					; want to print glyphs.
	bne.s	.Skip3
	jsr	Handle_text_command
	bra.s	.Loop
.Skip3:
	cmp.b	#32,d1
	beq.s	.Skip4		; If space, just skip glyph and
					; increase X by 6.
	cmp.b	#36,d1
	beq.s	.Skip4		; If $ (hard space), also skip
	cmp.b	#32,d1
	bcs.s	.Loop		; If char < space, fully ignore
					; the character and go to next.
	move.b	-32(a3,d1.w),d1		; Char code -= 0x20 to work
					; with 0-based offsets.
	bmi.s	.Loop		; If minus (-1 or 0xff) this char is
					; invalid so ignore it.
	jsr	Render_glyph		; Finally draw our glyph
.Skip4:
	addq.w	#6,d0		; X += 6 (next glyph pos)
	cmp.w	#314,d0		; Limit X to 314 (320-6)
	bmi.s	.Loop
.Loop2:
	tst.b	(a2)+		; Skip the rest till the end
					; of string ('\0') is reached.
					; We can't print more as the
					; screen limit is reached.
	bne.s	.Loop2
.Exit:
	move.l	a2,a0		; A0 now points to after
					; the end of string.
	movem.l	(sp)+,d1/a1-a3
	rts

;*****************************************************************************
; [ Handle a text command (~RUN1~, ~NORM~) ]
;   IN : a2 - Pointer to text (after the ~) (.l)
; NOTE (disassembly) :
;   This just ignores ~XY~ wildcards
;   while printing glyphs, but will
;   handle switching between normal
;   text and runes.
;*****************************************************************************
Handle_text_command:
	movem.l	d0-d7/a0/a1/a4-a6,-(sp)
	move.b	(a2)+,d0		; A2 is the text buffer.
					; We get next char in D0.
	lsl.w	#8,d0
	move.b	(a2)+,d0		; And another char.
	swap	d0
	move.b	(a2)+,d0		; And the 3rd one.
	lsl.w	#8,d0
	move.b	(a2)+,d0		; And the 4th one. Wildcards always use
					; 4 chars like ~SELF~, ~SEX1~ and so on.
	lea.l	Rune_command,a0
.Loop:
	tst.l	(a0)		; Check if rune string is valid.
					; This is checked in a loop for
					; rune and normal text. At the
					; end there is a 0 long inside the
					; data so that this loop will stop.
	beq.s	.Loop2
	cmp.l	(a0)+,d0		; If so and if wildcard is ~RUN1~,
	beq.s	.Skip		; handle runes.
	addq.l	#4,a0		; Otherwise go right to normal
					; text handler (is now in A0).
	bra.s	.Loop		; This whole stuff acts like a loop
					; over the list of possible text
					; modes (here: runes or normal only).
					; The tst.l instruction acts as a
					; loop break condition as the list
					; ends with a 0 long-word. If any
					; text mode wildcard is found, it is
					; used and its handler is called.
.Skip:
	move.l	(a0),a0		; Start rune text (or in second
					; loop, start normal text, etc).
	jsr	(a0)
.Loop2:
	cmpi.b	#126,(a2)+		; Wait for closing ~ and ignore
					; everything until we found it.
	bne.s	.Loop2
	cmp.l	#1229867808,d0		; Check for "INK " (with space at end!)
	bne.s	.Exit
	cmpi.b	#32,(a2)		; If a space follows ~INK XY~,
					; we skip it.
	bne.s	.Exit
	addq.l	#1,a2
.Exit:
	movem.l	(sp)+,d0-d7/a0/a1/a4-a6
	rts

; Text commands : name and routine
Rune_command:
	dc.b	"RUN1"

Text_command_table:
	dc.l	Start_rune_text

Normal_command:
	dc.b	"NORM"
	dc.l	Start_normal_text,0

;*****************************************************************************
; [ Text command ~RUN1~ : print runes ]
; NOTE :
;   - Not in cheat mode (travel mode 6).
; NOTE (disassembly) :
;   This basically just changes the
;   used mapping array and sets a flag.
;*****************************************************************************
Start_rune_text:
	cmpi.w	#6,Travel_mode		; Cheat mode always can read
					; runes as normal text.
	beq.s	.Exit
	lea.l	Rune_glyph_mapping,a3
	st	Rune_flag
.Exit:
	rts

;*****************************************************************************
; [ Text command ~NORM~ : print normal text ]
; NOTE (disassembly) :
;   This basically just changes the
;   used mapping array and resets a flag.
;*****************************************************************************
Start_normal_text:
	lea.l	Glyph_mapping,a3
	sf	Rune_flag
	rts

;*****************************************************************************
; [ Draw one glyph into the text line buffer ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Glyph index (.w)
;        a0 - Pointer to font (.l)
;        a1 - Pointer to text line buffer (.l)
; All registers are restored
; NOTE (disassembly) :
;   Writes bitplane data of a
;   glyph to the text buffer.
;*****************************************************************************
Render_glyph:
	movem.l	d0/d1/d7/a0/a1,-(sp)
	mulu.w	#5,d1		; D1 is the glyph index
	lea.l	0(a0,d1.w),a0		; This points to the desired
					; glyph data.
	moveq.l	#7,d1
	and.w	d0,d1		; D1 = x & 7 (same as x mod 8)
	lsr.w	#3,d0		; x /= 8 (byte index)
	add.w	d0,a1		; A1 points to the target buffer
	moveq.l	#4,d7		; Loop over all 5 pixel rows
	btst.l	#0,d0
	beq.s	.Skip
.Loop:
	moveq.l	#0,d0
	move.b	(a0)+,d0		; Get glyph byte
	ror.w	d1,d0
	or.b	d0,(a1)+		; Place it into the buffer
	lsr.w	#8,d0
	or.b	d0,(a1)		; And also the possible remaining bits
	lea.l	39(a1),a1		; Skip 39 bytes (40 full bytes)
					; to reach next pixel line.
					; There are 5 pixel lines, each
					; 320 pixels width.
	dbra	d7,.Loop
	bra.s	.Exit
.Skip:
	subq.w	#8,d1		; In case of x % 16 == 0,
					; we can write at exact
					; byte boundaries and won't
					; have to split the bytes.
	neg.w	d1
.Loop2:
	moveq.l	#0,d0
	move.b	(a0)+,d0
	rol.w	d1,d0
	or.w	d0,(a1)
	lea.l	40(a1),a1		; Go to next pixel line.
	dbra	d7,.Loop2
.Exit:
	movem.l	(sp)+,d0/d1/d7/a0/a1
	rts



	SECTION	Fast_BSS,bss
Text_line_bit_plane_buffer:
	ds.b	200
Rune_flag:				; (Mouse_buffer_end, the flag of the
	ds.b	1			;  Amiga version, is in MOUSE.S)
	even
Ink_colour:
	ds.w	1
Shadow_colour:
	ds.w	1
