; Shared data tables (palettes, spell data, file infos, ...)
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.


	SECTION	Fast_DATA,data
	cnop	0,4				; (start of a separately linked object)
Default_Mptr:
	dc.w	1		; Cursor.HotspotX
	dc.w	1		; Cursor.HotspotY
	dc.b	0,0,$70,0,0,0,$70,0,$e8,0,$70,0,$58,0,$fe,0
	dc.b	$78,0,$6e,0,$bf,0,$7c,0,$3a,0,$76,$90,$3f,0,$11,0
	dc.b	$38,$48,$1f,$90,$1a,$90,$39,$24,$f,$d8,5,$c0,$12,$94,$f,$f8
	dc.b	3,$f0,9,$68,7,$f0,1,$c0,4,$e8,3,$f0,0,$88,2,$ec
	dc.b	1,$f0,5,$1c,$b,$87,7,$f8,2,$b4,5,$ef,3,$1e,0,$1a
	dc.b	3,$3d,0,$e,0,4,0,$1a,0,$c,0,0,0,$1c,0
	dc.b	0		; 3 bit with palette offset 24
Up_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
	dc.b	0,0,1,0,3,$80,1,0,3,0,7,$c0,3,$80,6,$40
	dc.b	$f,$a0,7,$c0,$c,$e0,$1f,$10,$f,$e0,$d,$80,$32,8,$1f,$f0
	dc.b	7,$40,$3c,$78,3,$80,0,0,6,$40,3,$80,2,$80,4,$c0
	dc.b	3,0,1,$80,5,$c0,2,0,1,$80,5,$c0,2,0,0,0
	dc.b	7,$c0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Down_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,$e0
	dc.b	0,0,1,$c0,3,$e0,1,$c0,1,$c0,3,$e0,1,$c0,1,$80
	dc.b	3,$e0,1,$c0,1,0,3,$e0,1,$c0,0,$60,$1f,$bc,1,$c0
	dc.b	$a,$d0,$17,$24,$f,$f8,7,$80,8,8,7,$f0,0,$20,4,$30
	dc.b	3,$c0,1,$c0,3,$e0,0,0,0,$80,1,$c0,0,0,0,0
	dc.b	0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Left_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,1,$80,0,0,1,0,3,$80,1,0,2,0
	dc.b	7,$80,3,0,7,0,$e,$fc,7,0,$c,$d0,$1f,$64,$f,$f8
	dc.b	$19,$88,$3e,$c,$1f,$f0,3,$38,$1c,$3c,$f,$c0,6,0,8,$fc
	dc.b	7,0,0,0,4,$80,3,0,0,0,2,$80,1,0,0,0
	dc.b	1,$80,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Right_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,$80
	dc.b	0,0,0,$80,1,$c0,0,$80,1,$80,1,$e0,0,$c0,2,$c0
	dc.b	$3e,$f0,1,$e0,$1e,$90,$3f,$e8,$1f,$f0,$19,$f0,$3e,4,$1f,$f8
	dc.b	$c,$10,$30,$18,$1f,$e0,1,$20,$3f,$30,0,$c0,0,$c0,1,$60
	dc.b	0,$80,0,0,1,$40,0,$80,0,0,1,$80,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Upleft_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,$1f,$f0,0,0,$f,$c0,$1f,$f0,$f,$e0,$f,$40
	dc.b	$1f,$a0,$f,$c0,$c,$80,$1f,$40,$f,$80,8,$40,$1f,$a0,$f,$c0
	dc.b	2,$e0,$1d,$10,$f,$e0,0,$80,$1a,8,$d,$f0,8,$30,$15,$34
	dc.b	8,$c8,0,$70,$18,$f8,0,0,0,$20,0,$70,0,0,0,0
	dc.b	0,$20,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Upright_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,$f,$f8,0,0,7,$f0,$f,$f8,7,$f0,1,$d0
	dc.b	7,$e8,3,$f0,0,$20,3,$c8,1,$f0,2,$60,7,$88,3,$f0
	dc.b	4,$90,$f,$18,7,$e0,$b,$30,$1c,$78,$f,$80,6,$10,$38,$b8
	dc.b	$1f,0,0,0,$11,$18,$e,0,4,0,$e,0,0,0,0,0
	dc.b	4,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Downleft_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$20
	dc.b	0,0,0,$20,0,$70,0,$20,0,$40,$18,$f8,0,$70,8,$90
	dc.b	$1d,$e4,8,$f8,$c,$20,$1f,$c8,$d,$f0,$c,$c0,$1f,$10,$f,$e0
	dc.b	9,$80,$1e,$20,$f,$c0,$b,0,$1c,$c0,$f,$80,6,$40,$18,$20
	dc.b	$f,$c0,$c,$c0,$10,$d0,$f,$20,0,0,$1f,$f0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Downright_2D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0
	dc.b	0,0,4,0,$e,0,4,0,$e,0,$1f,$18,$e,0,$1d,$10
	dc.b	$3f,$a8,$1f,$10,0,0,$1f,$e8,$f,$b0,5,$c0,$a,8,7,$f0
	dc.b	3,$90,4,$18,3,$e0,1,$10,2,$18,1,$e0,0,$30,6,$38
	dc.b	3,$c0,4,$f0,8,$f8,7,0,0,0,$f,$f8,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Forward_3D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
	dc.b	0,0,1,0,5,$40,3,$80,$f,$e0,$17,$d0,$f,$e0,$39,$70
	dc.b	$5f,$84,$3f,$f8,2,0,$7f,$fc,3,$80,2,$c0,3,$40,7,$80
	dc.b	1,$80,$e,$20,7,$c0,7,0,4,$20,$f,$c0,2,$60,$1c,$70
	dc.b	$f,$80,$c,$e0,8,$f0,$1f,0,0,0,$3f,$f8,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Back_3D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,3,$80,0,0,3,$80,7,$c0,3,$80,6,0
	dc.b	$b,$a0,7,$c0,4,$40,$f7,$9e,$f,$e0,$79,$94,$fe,$7a,$7f,$fc
	dc.b	$33,8,$5c,$c,$3f,$f0,6,$20,$10,$30,$f,$c0,2,$80,6,$c0
	dc.b	1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Left_3D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$60
	dc.b	0,0,0,$40,1,$20,0,$c0,0,$a0,5,$e0,3,$c0,2,$40
	dc.b	$17,$ff,$f,$80,$c,$d6,$5f,$b,$3f,$fc,$39,$84,$fe,6,$7f,$f8
	dc.b	$12,$f8,$7c,$fc,$3f,0,$15,0,$29,$f8,$1e,0,$e,0,$13,0
	dc.b	$c,0,0,0,$a,0,4,0,0,0,6,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Right_3D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0
	dc.b	0,0,2,0,6,$80,3,0,1,$c0,7,$60,3,$80,1,$f0
	dc.b	$fd,$d8,3,$e0,$3f,$8c,$ff,$f6,$7f,$f8,$2c,$36,$53,$c1,$3f,$fe
	dc.b	0,$64,$20,$86,$1f,$f8,0,$c8,$1f,$8c,0,$70,0,$10,0,$98
	dc.b	0,$60,0,$20,0,$70,0,0,0,0,0,$20,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Turnleft_3D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$60
	dc.b	0,0,0,0,1,$60,0,$c0,0,$c0,5,$a0,3,$c0,3,$20
	dc.b	$17,$a0,$f,$c0,$c,$70,$5f,$d8,$3f,$e0,$38,$f8,$ff,$14,$7f,$f8
	dc.b	$12,$f8,$7c,$c2,$3f,$3c,$17,$32,$29,$63,$1e,$1c,4,6,$11,$37
	dc.b	$e,$18,2,$1e,$a,$2f,4,$10,0,$10,6,$3f,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Turnright_3D_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0
	dc.b	0,0,2,0,6,$80,3,0,1,0,7,$a0,3,$c0,1,$c0
	dc.b	5,$e8,3,$f0,3,8,$17,$f2,$f,$fc,$10,$7a,$3f,$85,$1f,$fe
	dc.b	$26,$e4,$7b,6,$3c,$f8,$4c,$c8,$b6,$8c,$78,$70,$18,$50,$e4,$d8
	dc.b	$78,$20,$30,$20,$c4,$70,$78,0,0,0,$fc,$60,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Turn180_left_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dcb.b	32,0
	dc.b	1,$e0,0,0,0,$80,5,$e8,3,$f0,3,$38,$f,$c4,7,$f8
	dc.b	4,$38,$1f,2,$f,$fc,8,$82,$6e,$f3,$1f,$1c,$32,$b6,$fd,$c7
	dc.b	$7f,$f8,$17,$e,$48,$6f,$3f,$90,$c,$e,$19,$2f,6,$10,0,0
	dc.b	4,$3f,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Turn180_right_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dcb.b	32,0
	dc.b	7,$80,0,0,3,0,$17,$a0,$f,$c0,$c,$c0,$1f,$10,$3f,$e0
	dc.b	$31,$d0,$3d,$18,$7e,$e0,$20,$80,$fb,$ce,$7c,$70,$4d,$64,$f7,$81
	dc.b	$7b,$fe,$58,$c4,$e6,6,$79,$f8,$30,$50,$c4,$d8,$78,$20,0,0
	dc.b	$fc,$20,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Zzz_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,$3f,$c0
	dc.b	0,0,$1f,$80,$7f,$c0,$3f,$80,$66,$80,$bf,$80,$7f,0,5,0
	dc.b	$ff,0,6,0,8,0,$1d,$f8,$e,0,$10,0,$3b,$e8,$1d,$f0
	dc.b	$2b,$20,$76,$50,$3f,$e0,$3e,$60,$c0,$bf,$7f,$c0,2,$dc,$ff,$41
	dc.b	1,$be,1,$b0,4,$5a,3,$e4,0,0,7,$f6,0,8,0,6
	dc.b	0,$27,0,$18,0,0,0,$3f,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Eye_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,5,$60,$c,$70,3,$80,0,$30,$2f,$c4,$1f,$f8,$14,$2c
	dc.b	$67,$e2,$38,$1c,$6c,$44,$a5,$d5,$5a,$3a,$e7,$1a,$72,$ce,$bf,$3d
	dc.b	$72,$6e,$b1,$dd,$7e,$3e,$31,$cc,$59,$ba,$3e,$7c,$13,$88,$34,$6c
	dc.b	$f,$f0,1,$80,7,$e0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Mouth_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,$a,$a0
	dc.b	$1b,$b0,4,$40,$3f,$c8,$6e,$ec,$1f,$f0,$70,$60,$bf,$9a,$7f,$fc
	dc.b	$40,6,$df,$f4,$e0,$e,$48,$3c,$b3,$9a,$7c,$7c,$21,$b0,$5f,$c4
	dc.b	$3f,$f8,7,$90,$30,$18,$f,$e0,0,0,$f,$e0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Mptr_20:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,$7f,$f8,0,0,$17,$f0,$57,$f4
	dc.b	$2f,$f8,$2e,$c,$5f,$fe,$27,$30,$c,$fc,$5f,$ce,$27,$30,$d,$dc
	dc.b	$5e,$ee,$27,$30,3,$bc,$5c,$6e,$27,$f0,$1f,$fc,$5f,$fe,$20,0
	dc.b	$10,4,$5f,$fe,$20,0,$10,4,$5f,$fe,$20,0,$10,4,$5f,$fe
	dc.b	$20,0,$20,4,$7f,$fe,0,0,$10,4,$5f,$fe,$20,0,$3f,$fc
	dc.b	$7f,$fe,0,0,0,0,$7f,$fe,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Gold_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,7,$c0,0,0,3,0,$b,$a0
	dc.b	7,$c0,5,$80,$14,$50,$f,$e0,$a,0,$19,$f0,$f,$e0,4,$60
	dc.b	$3b,$d0,$f,$e0,$19,$a0,$57,$f8,$3f,$c0,$26,$d0,$a1,$44,$7f,$b8
	dc.b	$54,$a0,$c8,$ea,$7f,$1c,$23,$b0,$de,$8e,$7f,$7c,$4c,$6c,$be,$1a
	dc.b	$7f,$fc,$35,$34,$89,$7e,$7e,$f8,$26,$9c,$66,$6e,$19,$f0,0,$98
	dc.b	$3f,$9c,0,$60,0,0,0,$f8,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Food_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,$1c,0,0,0,4,0,$2e,0,$1c,0,$1a,0,$5e,0
	dc.b	$3c,0,$d,0,$5f,$80,$3e,0,2,$40,$37,$60,$f,$80,1,$d0
	dc.b	$a,$18,7,$e0,2,$60,9,$84,7,$f8,6,$18,$d,$e2,3,$fc
	dc.b	3,$26,4,$c3,3,$fc,1,$5c,4,$9d,3,$e2,3,$10,6,$a5
	dc.b	1,$da,0,$ee,2,$6d,1,$92,1,$d8,3,$79,0,$86,0,$36
	dc.b	1,$33,0,$cc,0,$54,0,$c6,0,$38,0,0,0,$7c,0
	dc.b	0		; 3 bit with palette offset 24
Pick_Mptr:
	dc.w	1		; Cursor.HotspotX
	dc.w	1		; Cursor.HotspotY
	dc.b	0,0,$fc,0,0,0,$50,0,$e4,0,$78,0,$50,0,$98,0
	dc.b	$60,0,$20,0,$b0,0,$40,0,$40,0,$e0,0,0,0,0,0
	dc.b	$c0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dcb.b	47,0
	dc.b	0		; 3 bit with palette offset 24
Hand_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,0,0,0,0,0,0,$7c,0,0,0,$2c,0,$f7,0
	dc.b	$78,0,$2a,$80,$9c,$e0,$7f,0,$6a,$50,$67,$9c,$1f,$e0,$92,$cc
	dc.b	$61,$ef,$ff,$f0,$3d,$2a,0,$f3,$ff,$fc,$3e,$8a,$fe,$73,1,$fc
	dc.b	$b,$aa,$4f,$73,$30,$fc,$15,$d2,$9b,$e3,$67,$fc,$2d,$64,$b4,7
	dc.b	$4f,$f8,$13,$80,$75,$fe,$e,0,4,0,$f,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
EyeMouth_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,3,$c0,0,0,1,$80,3,$c0,1,$80,1,0,7,$e0
	dc.b	1,$80,1,0,$b,$d0,7,$e0,$b,$50,$15,$a8,$f,$f0,4,0
	dc.b	$2f,$d4,$19,$b8,8,$10,$f4,$2f,$18,$18,$74,$3c,$fc,$3f,$7c,$3e
	dc.b	$40,0,$fc,$3f,$7c,$3e,8,$10,$f4,$2f,$18,$18,1,$a0,$2b,$d4
	dc.b	$1d,$b8,$b,$50,$15,$a8,$f,$f0,1,0,$b,$d0,7,$e0,0,0
	dc.b	3,$e0,1,$80,0,0,3,$c0,1,$80,0,0,3,$c0,0
	dc.b	0		; 3 bit with palette offset 24
Click_Mptr:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,7,$e0,0,0,4,$a0,$1d,$38,3,$c0,$15,$68,$33,$8c
	dc.b	$f,$f0,$23,4,$60,6,$1f,$f8,$3f,$fc,$7f,$fe,0,0,$7f,$fe
	dc.b	$af,$af,$79,$7a,$7f,$f8,$ff,$fb,$49,$4e,$36,$b0,$ff,$fd,$49,$4e
	dc.b	$36,$b0,$ff,$fb,$49,$4e,$7f,$fe,$b6,$b5,$49,$4a,$2d,$ae,$80,$85
	dc.b	$7f,$7a,$3f,$fc,$7f,$fe,0,0,$36,$9c,$6f,$e6,$1f,$f8,$15,$c8
	dc.b	$32,$c,$f,$f0,4,$60,$1c,$78,3,$80,0,0,7,$e0,0
	dc.b	0		; 3 bit with palette offset 24
Mptr_27:
	dc.w	7		; Cursor.HotspotX
	dc.w	7		; Cursor.HotspotY
	dc.b	0,0,$55,$55,0,0,0,0,$aa,$aa,$55,$55,$55,$55,$ff,$ff
	dc.b	$55,$55,$c0,0,0,0,$ff,$ff,$ff,$fe,$7f,$ff,$80,0,$61,$fe
	dc.b	$5f,$ff,$be,0,$3a,$1e,$bf,$ff,$45,$e0,$37,$b2,$bf,$ef,$48,$5c
	dc.b	$2f,$76,$bf,$ff,$50,$88,$82,$26,$3d,$db,$ff,$fc,$7f,$fe,$7f,$ff
	dc.b	$80,0,$80,0,$ff,$ff,0,0,0,0,$aa,$aa,$55,$55,$55,$55
	dc.b	$ff,$ff,0,0,0,0,$55,$55,0,0,0,0,0,0,0
	dc.b	0		; 3 bit with palette offset 24
Main_pal:
	dc.w	0,$edc,$ffe,$bbc,$89a,$578,$256,$34
	dc.w	$fc9,$ea7,$c85,$a63,$842,$521,$b80,$da0
	dc.w	$fc0,$f90,$c60,$812,$c43,$e63,$aa4,$573
	dc.w	$254,$509,$222,$443,$665,$887,$aa9
	dc.w	$ccb		; 0RGB ; 0RGB
Automap_pal:
	dc.w	0,$fdc,$eb9,$c96,$410,$851,$a74,$630
	dc.w	$f60,$d30,$900,$fc0,$b90,$860,$9a3,$570
	dc.w	$240,$8be,$38c,$48,$c8d,$a69,$836,$fff
	dc.w	$79d,$16a,$211,$432,$654,$876,$a98
	dc.w	$cba		; 0RGB ; 0RGB
Tactic_pal:
	dc.w	0,$edc,$ffe,$bbc,$89a,$578,$256,$34
	dc.w	$fc9,$ea7,$c85,$a63,$842,$521,$b80,$da0
	dc.w	$fc0,$f90,$c60,$812,$c43,$e63,$aa4,$573
	dc.w	$49d,$259,$210,$431,$653,$875,$a97
	dc.w	$cb9		; 0RGB ; 0RGB
Sky_ranges:
	dc.w	$22,$22,$22,$22,$22,$22,$22,$22
	dc.w	$23,$23,$23,$23,$23,$23,$23,$24
	dc.w	$24,$24,$24,$24,$24,$24,$25,$25
	dc.w	$25,$25,$25,$25,$26,$26,$26,$26
	dc.w	$26,$27,$27,$27,$27,$27,$28,$28
	dc.w	$28,$29,$29,$29,$2a,$2a,$12a,$12a
	dc.w	$22a,$22a,$32a,$32a,$42a,$42a,$52a,$52a
	dc.w	$62a,$62a,$72a,$72a,$82a,$82a,$82a,$729
	dc.w	$729,$729,$628,$527,$426,$325,$224
	dc.w	$224		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	6,6,6,6,6,6,6,$16
	dc.w	$16,$16,$16,$16,$16,$26,$26,$26
	dc.w	$26,$26,$36,$36,$36,$36,$36,$46
	dc.w	$46,$46,$46,$56,$56,$56,$56,$66
	dc.w	$66,$167,$167,$268,$268,$368,$468,$468
	dc.w	$568,$668,$668,$768,$768,$868,$868,$967
	dc.w	$967,$a66,$a66,$a55,$a44,$b43,$c42,$c41
	dc.w	$c40,$d50,$e60,$e60,$e70,$e80,$e80,$e90
	dc.w	$ea0,$ea0,$eb0,$ec0,$ec0,$ed0,$ee0
	dc.w	$ee0		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	$2cc,$2cc,$2cc,$2cc,$2cc,$2cc,$2cc,$3cc
	dc.w	$3cc,$3cc,$3cc,$3cc,$3cc,$3cc,$4cc,$4cc
	dc.w	$4cc,$4cc,$4cc,$4cc,$4cc,$5cc,$5cc,$5cc
	dc.w	$5cc,$5cc,$5cc,$6cc,$6cc,$6cc,$6cc,$6cc
	dc.w	$6cc,$7cc,$7cc,$7cc,$7cc,$7cc,$7cc,$8cc
	dc.w	$8cc,$8cc,$8cc,$8cc,$9cc,$9cc,$9cc,$9cc
	dc.w	$acc,$acc,$acc,$bcb,$bcb,$bcb,$cca,$cca
	dc.w	$dc9,$dc9,$ec8,$ec8,$ec7,$ec6,$eb4,$ea2
	dc.w	$e91,$e80,$e80,$e70,$e60,$e50,$e40
	dc.w	$e40		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	2,2,2,2,2,2,2,2
	dc.w	3,3,3,3,3,3,3,4
	dc.w	4,4,4,4,5,5,5,5
	dc.w	5,5,6,6,6,6,7,7
	dc.w	7,8,8,$108,$108,$208,$208,$208
	dc.w	$308,$308,$408,$408,$508,$508,$608,$608
	dc.w	$708,$708,$808,$808,$818,$828,$828,$838
	dc.w	$848,$848,$747,$646,$646,$545,$23,$23
	dc.w	$23,$23,$123,$123,$114,$114,$114
	dc.w	$114		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	$42,$42,$42,$42,$42,$43,$43,$43
	dc.w	$43,$44,$44,$44,$44,$45,$45,$45
	dc.w	$45,$46,$46,$46,$46,$47,$47,$47
	dc.w	$48,$48,$48,$49,$49,$4a,$4a,$4a
	dc.w	$14a,$14a,$24a,$24a,$24a,$34a,$34a,$44a
	dc.w	$44a,$54a,$54a,$64a,$64a,$74a,$84a,$84a
	dc.w	$94a,$a4a,$a4a,$b5a,$c6a,$c6a,$d7a,$e8a
	dc.w	$e8a,$e99,$e99,$c88,$977,$766,$456,$356
	dc.w	$245,$144,$34,$34,$34,$123,$113
	dc.w	$113		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	$48,$48,$48,$48,$48,$48,$48,$49
	dc.w	$49,$49,$49,$49,$49,$4a,$4a,$4a
	dc.w	$4a,$4a,$4a,$5a,$5a,$5a,$5a,$5a
	dc.w	$6a,$6a,$6a,$6a,$7a,$7a,$7a,$8a
	dc.w	$8a,$8a,$9a,$9a,$aa,$aa,$2bb,$4cc
	dc.w	$4cc,$5dd,$6ee,$6ee,$7ee,$8ee,$9ee,$aee
	dc.w	$bee,$cee,$dee,$eee,$ddd,$ccc,$bbb,$aaa
	dc.w	$999,$888,$888,$777,$777,$666,$665,$564
	dc.w	$563,$562,$461,$461,$461,$461,$461
	dc.w	$461		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	2,2,2,2,2,2,2,3
	dc.w	3,3,3,3,3,3,4,4
	dc.w	4,4,4,4,4,$105,$105,$105
	dc.w	$105,$105,$105,$206,$206,$206,$206,$206
	dc.w	$206,$307,$307,$307,$307,$307,$408,$408
	dc.w	$408,$408,$519,$519,$519,$62a,$62a,$62a
	dc.w	$73a,$73a,$73a,$84a,$84a,$849,$848,$947
	dc.w	$a46,$a45,$a44,$b55,$c66,$c66,$c77,$c88
	dc.w	$c88,$b77,$a66,$a66,$955,$844,$733
	dc.w	$622		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	$404,$404,$404,$404,$404,$404,$404,$504
	dc.w	$504,$504,$504,$504,$504,$504,$604,$604
	dc.w	$604,$604,$604,$713,$713,$713,$713,$713
	dc.w	$822,$822,$822,$822,$922,$922,$922,$922
	dc.w	$a22,$a22,$a22,$b33,$b33,$b33,$c44,$c44
	dc.w	$d45,$d45,$e46,$e47,$e48,$e58,$e68,$e68
	dc.w	$e77,$e86,$e86,$e95,$ea4,$ea4,$eb5,$ec6
	dc.w	$ec6,$ed6,$ee6,$ed4,$ec2,$ea0,$e80,$e60
	dc.w	$e40,$e20,$e00,$c00,$a00,$800,$600
	dc.w	$400		; 1 color per row 0RGB, 72 rows (half 3D height)
	dc.w	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
	dc.w	$cc,$cc,$cc,$2ca,$2ca,$2ca,$2ca,$2ca
	dc.w	$4ca,$4ca,$4ca,$4ca,$4ca,$4ca,$6ca,$6ca
	dc.w	$6ca,$6ca,$6ca,$6ca,$6ca,$6ca,$8c8,$8c8
	dc.w	$8c8,$8c8,$8c8,$8c8,$ac8,$ac8,$ac8,$ac8
	dc.w	$ac8,$cc6,$cc6,$cc6,$cc6,$cc6,$cc6,$cc6
	dc.w	$cc8,$cc8,$cc8,$cc8,$cc8,$cca,$cca,$cca
	dc.w	$cca,$cca,$ccc,$ccc,$ccc,$ccc,$ccc,$cca
	dc.w	$cc8,$cc6,$cc4,$cc2,$cc0,$ca0,$c80
	dc.w	$c60		; 1 color per row 0RGB, 72 rows (half 3D height) ; 1 color per row 0RGB, 72 rows (half 3D height)
C3_palettes:
	dc.w	0,$357,$246,$135,$24,$13,2,$212
	dc.w	$101,$26,$322,$333,$144,$122,$300
	dc.w	$620		; 0RGB
	dc.w	0,$bab,$998,$878,$655,$533,$311,$942
	dc.w	$620,$a69,$b62,$d84,$773,$351,$a20
	dc.w	$d50		; 0RGB
	dc.w	0,$339,$328,$227,$216,$114,2,$214
	dc.w	$203,$4aa,$325,$436,$34,$23,$303
	dc.w	$411		; 0RGB
	dc.w	0,$896,$574,$454,$334,$113,$103,$534
	dc.w	$313,$4aa,$753,$963,$353,$34,$813
	dc.w	$a42		; 0RGB
	dc.w	0,$854,$644,$534,$424,$313,$202,$624
	dc.w	$413,$647,$734,$844,$332,$122,$610
	dc.w	$720		; 0RGB
	dc.w	0,$da9,$b87,$965,$643,$421,$202,$934
	dc.w	$613,$37b,$a53,$c84,$763,$242,$b20
	dc.w	$c60		; 0RGB ; 0RGB
	dc.b	0,0
Spell_data:
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	3		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	5		; SpellInfo.SP
	dc.b	2		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	8		; SpellInfo.SP
	dc.b	3		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$14		; SpellInfo.SP
	dc.b	8		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$14		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$c		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	$10		; = EnemyRow ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	$20		; = AllEnemies ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$96		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$1e		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$96		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$1e		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$1e		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$c		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$a		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$a		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	$40		; = Item ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	5		; SpellInfo.SP
	dc.b	2		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$a		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$a		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$14		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	$80		; = Blink ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e4		; = Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e4		; = Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$27		; = WorldMap | Map2D | Map3D | Lyramion ; SpellInfo.UseConditions
	dc.b	$96		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$27		; = WorldMap | Map2D | Map3D | Lyramion ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$1e		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$1e		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e4		; = Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	4		; = AllAllies ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	$40		; = Item ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	$40		; = Item ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	5		; SpellInfo.SP
	dc.b	3		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e8		; = Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	$40		; = Item ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$1e		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$3c		; SpellInfo.SP
	dc.b	$1e		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	5		; SpellInfo.SP
	dc.b	2		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$23		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$2d		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	5		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	$10		; = EnemyRow ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$a		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$3c		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	8		; = Unk4 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$a		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$1e		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$fa		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$b0		; = Battle | Lyramion | Morag ; SpellInfo.UseConditions
	dc.b	$a		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$10		; = Earth ; SpellInfo.Element
	dc.b	$b0		; = Battle | Lyramion | Morag ; SpellInfo.UseConditions
	dc.b	$f		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$10		; = Earth ; SpellInfo.Element
	dc.b	$b0		; = Battle | Lyramion | Morag ; SpellInfo.UseConditions
	dc.b	$14		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	$10		; = EnemyRow ; SpellInfo.Target
	dc.b	$10		; = Earth ; SpellInfo.Element
	dc.b	$b0		; = Battle | Lyramion | Morag ; SpellInfo.UseConditions
	dc.b	$19		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	$20		; = AllEnemies ; SpellInfo.Target
	dc.b	$10		; = Earth ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$14		; SpellInfo.SP
	dc.b	5		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$20		; = Wind ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$1e		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$20		; = Wind ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$28		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	$10		; = EnemyRow ; SpellInfo.Target
	dc.b	$20		; = Wind ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$32		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	$20		; = AllEnemies ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$28		; SpellInfo.SP
	dc.b	$a		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$40		; = Fire ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$3c		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$40		; = Fire ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$50		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	$10		; = EnemyRow ; SpellInfo.Target
	dc.b	$40		; = Fire ; SpellInfo.Element
	dc.b	$f0		; = Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	$64		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	$20		; = AllEnemies ; SpellInfo.Target
	dc.b	$40		; = Fire ; SpellInfo.Element
	dc.b	$70		; = Battle | Lyramion | ForestMoon ; SpellInfo.UseConditions
	dc.b	$50		; SpellInfo.SP
	dc.b	$f		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$80		; = Water ; SpellInfo.Element
	dc.b	$70		; = Battle | Lyramion | ForestMoon ; SpellInfo.UseConditions
	dc.b	$78		; SpellInfo.SP
	dc.b	$14		; SpellInfo.SLP
	dc.b	8		; = SingleEnemy ; SpellInfo.Target
	dc.b	$80		; = Water ; SpellInfo.Element
	dc.b	$70		; = Battle | Lyramion | ForestMoon ; SpellInfo.UseConditions
	dc.b	$a0		; SpellInfo.SP
	dc.b	$19		; SpellInfo.SLP
	dc.b	$10		; = EnemyRow ; SpellInfo.Target
	dc.b	$80		; = Water ; SpellInfo.Element
	dc.b	$70		; = Battle | Lyramion | ForestMoon ; SpellInfo.UseConditions
	dc.b	$c8		; SpellInfo.SP
	dc.b	$1e		; SpellInfo.SLP
	dc.b	$20		; = AllEnemies ; SpellInfo.Target
	dc.b	$80		; = Water ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	$e7		; = WorldMap | Map2D | Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$21		; = WorldMap | Lyramion ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$21		; = WorldMap | Lyramion ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	1		; = Unk1 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ff		; = WorldMap | Map2D | Map3D | Camp | Battle | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$e4		; = Map3D | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	2		; = Unk2 ; SpellInfo.Element
	dc.b	$ef		; = WorldMap | Map2D | Map3D | Camp | Lyramion | ForestMoon | Morag ; SpellInfo.UseConditions
	dc.b	1		; SpellInfo.SP
	dc.b	1		; SpellInfo.SLP
	dc.b	1		; = SingleAlly ; SpellInfo.Target
	dc.b	4		; = Unk3 ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
	dc.b	0		; = None ; SpellInfo.UseConditions
	dc.b	0		; SpellInfo.SP
	dc.b	0		; SpellInfo.SLP
	dc.b	0		; = None ; SpellInfo.Target
	dc.b	0		; = None ; SpellInfo.Element
Sinus_table:
	dc.w	0,$65,$c9,$12e,$192,$1f7,$25b,$2c0
	dc.w	$324,$388,$3ed,$451,$4b5,$51a,$57e,$5e2
	dc.w	$646,$6aa,$70e,$772,$7d6,$839,$89d,$901
	dc.w	$964,$9c7,$a2b,$a8e,$af1,$b54,$bb7,$c1a
	dc.w	$c7c,$cdf,$d41,$da4,$e06,$e68,$eca,$f2b
	dc.w	$f8d,$fee,$1050,$10b1,$1112,$1173,$11d3,$1234
	dc.w	$1294,$12f4,$1354,$13b4,$1413,$1473,$14d2,$1531
	dc.w	$1590,$15ee,$164c,$16ab,$1709,$1766,$17c4,$1821
	dc.w	$187e,$18db,$1937,$1993,$19ef,$1a4b,$1aa7,$1b02
	dc.w	$1b5d,$1bb8,$1c12,$1c6c,$1cc6,$1d20,$1d79,$1dd3
	dc.w	$1e2b,$1e84,$1edc,$1f34,$1f8c,$1fe3,$203a,$2091
	dc.w	$20e7,$213d,$2193,$21e8,$223d,$2292,$22e7,$233b
	dc.w	$238e,$23e2,$2435,$2488,$24da,$252c,$257e,$25cf
	dc.w	$2620,$2671,$26c1,$2711,$2760,$27af,$27fe,$284c
	dc.w	$289a,$28e7,$2935,$2981,$29ce,$2a1a,$2a65,$2ab0
	dc.w	$2afb,$2b45,$2b8f,$2bd8,$2c21,$2c6a,$2cb2,$2cfa
	dc.w	$2d41,$2d88,$2dcf,$2e15,$2e5a,$2e9f,$2ee4,$2f28
	dc.w	$2f6c,$2faf,$2ff2,$3034,$3076,$30b8,$30f9,$3139
	dc.w	$3179,$31b9,$31f8,$3236,$3274,$32b2,$32ef,$332c
	dc.w	$3368,$33a3,$33df,$3419,$3453,$348d,$34c6,$34ff
	dc.w	$3537,$356e,$35a5,$35dc,$3612,$3648,$367d,$36b1
	dc.w	$36e5,$3718,$374b,$377e,$37b0,$37e1,$3812,$3842
	dc.w	$3871,$38a1,$38cf,$38fd,$392b,$3958,$3984,$39b0
	dc.w	$39db,$3a06,$3a30,$3a59,$3a82,$3aab,$3ad3,$3afa
	dc.w	$3b21,$3b47,$3b6d,$3b92,$3bb6,$3bda,$3bfd,$3c20
	dc.w	$3c42,$3c64,$3c85,$3ca5,$3cc5,$3ce4,$3d03,$3d21
	dc.w	$3d3f,$3d5b,$3d78,$3d93,$3daf,$3dc9,$3de3,$3dfc
	dc.w	$3e15,$3e2d,$3e45,$3e5c,$3e72,$3e88,$3e9d,$3eb1
	dc.w	$3ec5,$3ed8,$3eeb,$3efd,$3f0f,$3f20,$3f30,$3f40
	dc.w	$3f4f,$3f5d,$3f6b,$3f78,$3f85,$3f91,$3f9c,$3fa7
	dc.w	$3fb1,$3fbb,$3fc4,$3fcc,$3fd4,$3fdb,$3fe1,$3fe7
	dc.w	$3fec,$3ff1,$3ff5,$3ff8,$3ffb,$3ffd,$3fff,$4000
	dc.w	$4000,$4000,$3fff,$3ffd,$3ffb,$3ff8,$3ff5,$3ff1
	dc.w	$3fec,$3fe7,$3fe1,$3fdb,$3fd4,$3fcc,$3fc4,$3fbb
	dc.w	$3fb1,$3fa7,$3f9c,$3f91,$3f85,$3f78,$3f6b,$3f5d
	dc.w	$3f4f,$3f40,$3f30,$3f20,$3f0f,$3efd,$3eeb,$3ed8
	dc.w	$3ec5,$3eb1,$3e9d,$3e88,$3e72,$3e5c,$3e45,$3e2d
	dc.w	$3e15,$3dfc,$3de3,$3dc9,$3daf,$3d93,$3d78,$3d5b
	dc.w	$3d3f,$3d21,$3d03,$3ce4,$3cc5,$3ca5,$3c85,$3c64
	dc.w	$3c42,$3c20,$3bfd,$3bda,$3bb6,$3b92,$3b6d,$3b47
	dc.w	$3b21,$3afa,$3ad3,$3aab,$3a82,$3a59,$3a30,$3a06
	dc.w	$39db,$39b0,$3984,$3958,$392b,$38fd,$38cf,$38a1
	dc.w	$3871,$3842,$3812,$37e1,$37b0,$377e,$374b,$3718
	dc.w	$36e5,$36b1,$367d,$3648,$3612,$35dc,$35a5,$356e
	dc.w	$3537,$34ff,$34c6,$348d,$3453,$3419,$33df,$33a3
	dc.w	$3368,$332c,$32ef,$32b2,$3274,$3236,$31f8,$31b9
	dc.w	$3179,$3139,$30f9,$30b8,$3076,$3034,$2ff2,$2faf
	dc.w	$2f6c,$2f28,$2ee4,$2e9f,$2e5a,$2e15,$2dcf,$2d88
	dc.w	$2d41,$2cfa,$2cb2,$2c6a,$2c21,$2bd8,$2b8f,$2b45
	dc.w	$2afb,$2ab0,$2a65,$2a1a,$29ce,$2981,$2935,$28e7
	dc.w	$289a,$284c,$27fe,$27af,$2760,$2711,$26c1,$2671
	dc.w	$2620,$25cf,$257e,$252c,$24da,$2488,$2435,$23e2
	dc.w	$238e,$233b,$22e7,$2292,$223d,$21e8,$2193,$213d
	dc.w	$20e7,$2091,$203a,$1fe3,$1f8c,$1f34,$1edc,$1e84
	dc.w	$1e2b,$1dd3,$1d79,$1d20,$1cc6,$1c6c,$1c12,$1bb8
	dc.w	$1b5d,$1b02,$1aa7,$1a4b,$19ef,$1993,$1937,$18db
	dc.w	$187e,$1821,$17c4,$1766,$1709,$16ab,$164c,$15ee
	dc.w	$1590,$1531,$14d2,$1473,$1413,$13b4,$1354,$12f4
	dc.w	$1294,$1234,$11d3,$1173,$1112,$10b1,$1050,$fee
	dc.w	$f8d,$f2b,$eca,$e68,$e06,$da4,$d41,$cdf
	dc.w	$c7c,$c1a,$bb7,$b54,$af1,$a8e,$a2b,$9c7
	dc.w	$964,$901,$89d,$839,$7d6,$772,$70e,$6aa
	dc.w	$646,$5e2,$57e,$51a,$4b5,$451,$3ed,$388
	dc.w	$324,$2c0,$25b,$1f7,$192,$12e,$c9,$65
	dc.w	0,$ff9b,$ff37,$fed2,$fe6e,$fe09,$fda5,$fd40
	dc.w	$fcdc,$fc78,$fc13,$fbaf,$fb4b,$fae6,$fa82,$fa1e
	dc.w	$f9ba,$f956,$f8f2,$f88e,$f82a,$f7c7,$f763,$f6ff
	dc.w	$f69c,$f639,$f5d5,$f572,$f50f,$f4ac,$f449,$f3e6
	dc.w	$f384,$f321,$f2bf,$f25c,$f1fa,$f198,$f136,$f0d5
	dc.w	$f073,$f012,$efb0,$ef4f,$eeee,$ee8d,$ee2d,$edcc
	dc.w	$ed6c,$ed0c,$ecac,$ec4c,$ebed,$eb8d,$eb2e,$eacf
	dc.w	$ea70,$ea12,$e9b4,$e955,$e8f7,$e89a,$e83c,$e7df
	dc.w	$e782,$e725,$e6c9,$e66d,$e611,$e5b5,$e559,$e4fe
	dc.w	$e4a3,$e448,$e3ee,$e394,$e33a,$e2e0,$e287,$e22d
	dc.w	$e1d5,$e17c,$e124,$e0cc,$e074,$e01d,$dfc6,$df6f
	dc.w	$df19,$dec3,$de6d,$de18,$ddc3,$dd6e,$dd19,$dcc5
	dc.w	$dc72,$dc1e,$dbcb,$db78,$db26,$dad4,$da82,$da31
	dc.w	$d9e0,$d98f,$d93f,$d8ef,$d8a0,$d851,$d802,$d7b4
	dc.w	$d766,$d719,$d6cb,$d67f,$d632,$d5e6,$d59b,$d550
	dc.w	$d505,$d4bb,$d471,$d428,$d3df,$d396,$d34e,$d306
	dc.w	$d2bf,$d278,$d231,$d1eb,$d1a6,$d161,$d11c,$d0d8
	dc.w	$d094,$d051,$d00e,$cfcc,$cf8a,$cf48,$cf07,$cec7
	dc.w	$ce87,$ce47,$ce08,$cdca,$cd8c,$cd4e,$cd11,$ccd4
	dc.w	$cc98,$cc5d,$cc21,$cbe7,$cbad,$cb73,$cb3a,$cb01
	dc.w	$cac9,$ca92,$ca5b,$ca24,$c9ee,$c9b8,$c983,$c94f
	dc.w	$c91b,$c8e8,$c8b5,$c882,$c850,$c81f,$c7ee,$c7be
	dc.w	$c78f,$c75f,$c731,$c703,$c6d5,$c6a8,$c67c,$c650
	dc.w	$c625,$c5fa,$c5d0,$c5a7,$c57e,$c555,$c52d,$c506
	dc.w	$c4df,$c4b9,$c493,$c46e,$c44a,$c426,$c403,$c3e0
	dc.w	$c3be,$c39c,$c37b,$c35b,$c33b,$c31c,$c2fd,$c2df
	dc.w	$c2c1,$c2a5,$c288,$c26d,$c251,$c237,$c21d,$c204
	dc.w	$c1eb,$c1d3,$c1bb,$c1a4,$c18e,$c178,$c163,$c14f
	dc.w	$c13b,$c128,$c115,$c103,$c0f1,$c0e0,$c0d0,$c0c0
	dc.w	$c0b1,$c0a3,$c095,$c088,$c07b,$c06f,$c064,$c059
	dc.w	$c04f,$c045,$c03c,$c034,$c02c,$c025,$c01f,$c019
	dc.w	$c014,$c00f,$c00b,$c008,$c005,$c003,$c001,$c000
	dc.w	$c000,$c000,$c001,$c003,$c005,$c008,$c00b,$c00f
	dc.w	$c014,$c019,$c01f,$c025,$c02c,$c034,$c03c,$c045
	dc.w	$c04f,$c059,$c064,$c06f,$c07b,$c088,$c095,$c0a3
	dc.w	$c0b1,$c0c0,$c0d0,$c0e0,$c0f1,$c103,$c115,$c128
	dc.w	$c13b,$c14f,$c163,$c178,$c18e,$c1a4,$c1bb,$c1d3
	dc.w	$c1eb,$c204,$c21d,$c237,$c251,$c26d,$c288,$c2a5
	dc.w	$c2c1,$c2df,$c2fd,$c31c,$c33b,$c35b,$c37b,$c39c
	dc.w	$c3be,$c3e0,$c403,$c426,$c44a,$c46e,$c493,$c4b9
	dc.w	$c4df,$c506,$c52d,$c555,$c57e,$c5a7,$c5d0,$c5fa
	dc.w	$c625,$c650,$c67c,$c6a8,$c6d5,$c703,$c731,$c75f
	dc.w	$c78f,$c7be,$c7ee,$c81f,$c850,$c882,$c8b5,$c8e8
	dc.w	$c91b,$c94f,$c983,$c9b8,$c9ee,$ca24,$ca5b,$ca92
	dc.w	$cac9,$cb01,$cb3a,$cb73,$cbad,$cbe7,$cc21,$cc5d
	dc.w	$cc98,$ccd4,$cd11,$cd4e,$cd8c,$cdca,$ce08,$ce47
	dc.w	$ce87,$cec7,$cf07,$cf48,$cf8a,$cfcc,$d00e,$d051
	dc.w	$d094,$d0d8,$d11c,$d161,$d1a6,$d1eb,$d231,$d278
	dc.w	$d2bf,$d306,$d34e,$d396,$d3df,$d428,$d471,$d4bb
	dc.w	$d505,$d550,$d59b,$d5e6,$d632,$d67f,$d6cb,$d719
	dc.w	$d766,$d7b4,$d802,$d851,$d8a0,$d8ef,$d93f,$d98f
	dc.w	$d9e0,$da31,$da82,$dad4,$db26,$db78,$dbcb,$dc1e
	dc.w	$dc72,$dcc5,$dd19,$dd6e,$ddc3,$de18,$de6d,$dec3
	dc.w	$df19,$df6f,$dfc6,$e01d,$e074,$e0cc,$e124,$e17c
	dc.w	$e1d5,$e22d,$e287,$e2e0,$e33a,$e394,$e3ee,$e448
	dc.w	$e4a3,$e4fe,$e559,$e5b5,$e611,$e66d,$e6c9,$e725
	dc.w	$e782,$e7df,$e83c,$e89a,$e8f7,$e955,$e9b4,$ea12
	dc.w	$ea70,$eacf,$eb2e,$eb8d,$ebed,$ec4c,$ecac,$ed0c
	dc.w	$ed6c,$edcc,$ee2d,$ee8d,$eeee,$ef4f,$efb0,$f012
	dc.w	$f073,$f0d5,$f136,$f198,$f1fa,$f25c,$f2bf,$f321
	dc.w	$f384,$f3e6,$f449,$f4ac,$f50f,$f572,$f5d5,$f639
	dc.w	$f69c,$f6ff,$f763,$f7c7,$f82a,$f88e,$f8f2,$f956
	dc.w	$f9ba,$fa1e,$fa82,$fae6,$fb4b,$fbaf,$fc13,$fc78
	dc.w	$fcdc,$fd40,$fda5,$fe09,$fe6e,$fed2,$ff37,$ff9b
ATN_table:
	dc.w	0,1,1,2,3,3,4,4
	dc.w	5,6,6,7,8,8,9,$a
	dc.w	$a,$b,$b,$c,$d,$d,$e,$f
	dc.w	$f,$10,$11,$11,$12,$12,$13,$14
	dc.w	$14,$15,$16,$16,$17,$18,$18,$19
	dc.w	$19,$1a,$1b,$1b,$1c,$1d,$1d,$1e
	dc.w	$1f,$1f,$20,$20,$21,$22,$22,$23
	dc.w	$24,$24,$25,$26,$26,$27,$27,$28
	dc.w	$29,$29,$2a,$2b,$2b,$2c,$2c,$2d
	dc.w	$2e,$2e,$2f,$30,$30,$31,$32,$32
	dc.w	$33,$33,$34,$35,$35,$36,$37,$37
	dc.w	$38,$39,$39,$3a,$3a,$3b,$3c,$3c
	dc.w	$3d,$3e,$3e,$3f,$3f,$40,$41,$41
	dc.w	$42,$43,$43,$44,$45,$45,$46,$46
	dc.w	$47,$48,$48,$49,$4a,$4a,$4b,$4b
	dc.w	$4c,$4d,$4d,$4e,$4f,$4f,$50,$50
	dc.w	$51,$52,$52,$53,$54,$54,$55,$55
	dc.w	$56,$57,$57,$58,$59,$59,$5a,$5a
	dc.w	$5b,$5c,$5c,$5d,$5e,$5e,$5f,$5f
	dc.w	$60,$61,$61,$62,$63,$63,$64,$64
	dc.w	$65,$66,$66,$67,$68,$68,$69,$69
	dc.w	$6a,$6b,$6b,$6c,$6c,$6d,$6e,$6e
	dc.w	$6f,$70,$70,$71,$71,$72,$73,$73
	dc.w	$74,$75,$75,$76,$76,$77,$78,$78
	dc.w	$79,$79,$7a,$7b,$7b,$7c,$7d,$7d
	dc.w	$7e,$7e,$7f,$80,$80,$81,$81,$82
	dc.w	$83,$83,$84,$84,$85,$86,$86,$87
	dc.w	$88,$88,$89,$89,$8a,$8b,$8b,$8c
	dc.w	$8c,$8d,$8e,$8e,$8f,$8f,$90,$91
	dc.w	$91,$92,$92,$93,$94,$94,$95,$95
	dc.w	$96,$97,$97,$98,$98,$99,$9a,$9a
	dc.w	$9b,$9c,$9c,$9d,$9d,$9e,$9f,$9f
	dc.w	$a0,$a0,$a1,$a1,$a2,$a3,$a3,$a4
	dc.w	$a4,$a5,$a6,$a6,$a7,$a7,$a8,$a9
	dc.w	$a9,$aa,$aa,$ab,$ac,$ac,$ad,$ad
	dc.w	$ae,$af,$af,$b0,$b0,$b1,$b2,$b2
	dc.w	$b3,$b3,$b4,$b4,$b5,$b6,$b6,$b7
	dc.w	$b7,$b8,$b9,$b9,$ba,$ba,$bb,$bc
	dc.w	$bc,$bd,$bd,$be,$be,$bf,$c0,$c0
	dc.w	$c1,$c1,$c2,$c3,$c3,$c4,$c4,$c5
	dc.w	$c5,$c6,$c7,$c7,$c8,$c8,$c9,$ca
	dc.w	$ca,$cb,$cb,$cc,$cc,$cd,$ce,$ce
	dc.w	$cf,$cf,$d0,$d0,$d1,$d2,$d2,$d3
	dc.w	$d3,$d4,$d4,$d5,$d6,$d6,$d7,$d7
	dc.w	$d8,$d8,$d9,$da,$da,$db,$db,$dc
	dc.w	$dc,$dd,$de,$de,$df,$df,$e0,$e0
	dc.w	$e1,$e1,$e2,$e3,$e3,$e4,$e4,$e5
	dc.w	$e5,$e6,$e7,$e7,$e8,$e8,$e9,$e9
	dc.w	$ea,$ea,$eb,$ec,$ec,$ed,$ed,$ee
	dc.w	$ee,$ef,$ef,$f0,$f1,$f1,$f2,$f2
	dc.w	$f3,$f3,$f4,$f4,$f5,$f6,$f6,$f7
	dc.w	$f7,$f8,$f8,$f9,$f9,$fa,$fa,$fb
	dc.w	$fc,$fc,$fd,$fd,$fe,$fe,$ff,$ff
	dc.w	$100,$100,$101,$102,$102,$103,$103,$104
	dc.w	$104,$105,$105,$106,$106,$107,$107,$108
	dc.w	$109,$109,$10a,$10a,$10b,$10b,$10c,$10c
	dc.w	$10d,$10d,$10e,$10e,$10f,$110,$110,$111
	dc.w	$111,$112,$112,$113,$113,$114,$114,$115
	dc.w	$115,$116,$116,$117,$117,$118,$119,$119
	dc.w	$11a,$11a,$11b,$11b,$11c,$11c,$11d,$11d
	dc.w	$11e,$11e,$11f,$11f,$120,$120,$121,$121
	dc.w	$122,$122,$123,$123,$124,$125,$125,$126
	dc.w	$126,$127,$127,$128,$128,$129,$129,$12a
	dc.w	$12a,$12b,$12b,$12c,$12c,$12d,$12d,$12e
	dc.w	$12e,$12f,$12f,$130,$130,$131,$131,$132
	dc.w	$132,$133,$133,$134,$134,$135,$135,$136
	dc.w	$136,$137,$137,$138,$138,$139,$139,$13a
	dc.w	$13a,$13b,$13b,$13c,$13c,$13d,$13d,$13e
	dc.w	$13e,$13f,$13f,$140,$140,$141,$141,$142
	dc.w	$142,$143,$143,$144,$144,$145,$145,$146
	dc.w	$146,$147,$147,$148,$148,$149,$149,$14a
	dc.w	$14a,$14b,$14b,$14c,$14c,$14d,$14d,$14e
	dc.w	$14e,$14f,$14f,$14f,$150,$150,$151,$151
	dc.w	$152,$152,$153,$153,$154,$154,$155,$155
	dc.w	$156,$156,$157,$157,$158,$158,$159,$159
	dc.w	$15a,$15a,$15a,$15b,$15b,$15c,$15c,$15d
	dc.w	$15d,$15e,$15e,$15f,$15f,$160,$160,$161
	dc.w	$161,$162,$162,$162,$163,$163,$164,$164
	dc.w	$165,$165,$166,$166,$167,$167,$168,$168
	dc.w	$168,$169,$169,$16a,$16a,$16b,$16b,$16c
	dc.w	$16c,$16d,$16d,$16e,$16e,$16e,$16f,$16f
	dc.w	$170,$170,$171,$171,$172,$172,$173,$173
	dc.w	$173,$174,$174,$175,$175,$176,$176,$177
	dc.w	$177,$177,$178,$178,$179,$179,$17a,$17a
	dc.w	$17b,$17b,$17b,$17c,$17c,$17d,$17d,$17e
	dc.w	$17e,$17f,$17f,$17f,$180,$180,$181,$181
	dc.w	$182,$182,$183,$183,$183,$184,$184,$185
	dc.w	$185,$186,$186,$186,$187,$187,$188,$188
	dc.w	$189,$189,$189,$18a,$18a,$18b,$18b,$18c
	dc.w	$18c,$18d,$18d,$18d,$18e,$18e,$18f,$18f
	dc.w	$18f,$190,$190,$191,$191,$192,$192,$192
	dc.w	$193,$193,$194,$194,$195,$195,$195,$196
	dc.w	$196,$197,$197,$198,$198,$198,$199,$199
	dc.w	$19a,$19a,$19a,$19b,$19b,$19c,$19c,$19d
	dc.w	$19d,$19d,$19e,$19e,$19f,$19f,$19f,$1a0
	dc.w	$1a0,$1a1,$1a1,$1a1,$1a2,$1a2,$1a3,$1a3
	dc.w	$1a3,$1a4,$1a4,$1a5,$1a5,$1a6,$1a6,$1a6
	dc.w	$1a7,$1a7,$1a8,$1a8,$1a8,$1a9,$1a9,$1aa
	dc.w	$1aa,$1aa,$1ab,$1ab,$1ac,$1ac,$1ac,$1ad
	dc.w	$1ad,$1ae,$1ae,$1ae,$1af,$1af,$1b0,$1b0
	dc.w	$1b0,$1b1,$1b1,$1b2,$1b2,$1b2,$1b3,$1b3
	dc.w	$1b3,$1b4,$1b4,$1b5,$1b5,$1b5,$1b6,$1b6
	dc.w	$1b7,$1b7,$1b7,$1b8,$1b8,$1b9,$1b9,$1b9
	dc.w	$1ba,$1ba,$1ba,$1bb,$1bb,$1bc,$1bc,$1bc
	dc.w	$1bd,$1bd,$1be,$1be,$1be,$1bf,$1bf,$1bf
	dc.w	$1c0,$1c0,$1c1,$1c1,$1c1,$1c2,$1c2,$1c3
	dc.w	$1c3,$1c3,$1c4,$1c4,$1c4,$1c5,$1c5,$1c6
	dc.w	$1c6,$1c6,$1c7,$1c7,$1c7,$1c8,$1c8,$1c9
	dc.w	$1c9,$1c9,$1ca,$1ca,$1ca,$1cb,$1cb,$1cb
	dc.w	$1cc,$1cc,$1cd,$1cd,$1cd,$1ce,$1ce,$1ce
	dc.w	$1cf,$1cf,$1d0,$1d0,$1d0,$1d1,$1d1,$1d1
	dc.w	$1d2,$1d2,$1d2,$1d3,$1d3,$1d4,$1d4,$1d4
	dc.w	$1d5,$1d5,$1d5,$1d6,$1d6,$1d6,$1d7,$1d7
	dc.w	$1d7,$1d8,$1d8,$1d9,$1d9,$1d9,$1da,$1da
	dc.w	$1da,$1db,$1db,$1db,$1dc,$1dc,$1dc,$1dd
	dc.w	$1dd,$1de,$1de,$1de,$1df,$1df,$1df,$1e0
	dc.w	$1e0,$1e0,$1e1,$1e1,$1e1,$1e2,$1e2,$1e2
	dc.w	$1e3,$1e3,$1e3,$1e4,$1e4,$1e4,$1e5,$1e5
	dc.w	$1e6,$1e6,$1e6,$1e7,$1e7,$1e7,$1e8,$1e8
	dc.w	$1e8,$1e9,$1e9,$1e9,$1ea,$1ea,$1ea,$1eb
	dc.w	$1eb,$1eb,$1ec,$1ec,$1ec,$1ed,$1ed,$1ed
	dc.w	$1ee,$1ee,$1ee,$1ef,$1ef,$1ef,$1f0,$1f0
	dc.w	$1f0,$1f1,$1f1,$1f1,$1f2,$1f2,$1f2,$1f3
	dc.w	$1f3,$1f3,$1f4,$1f4,$1f4,$1f5,$1f5,$1f5
	dc.w	$1f6,$1f6,$1f6,$1f7,$1f7,$1f7,$1f8,$1f8
	dc.w	$1f8,$1f9,$1f9,$1f9,$1fa,$1fa,$1fa,$1fb
	dc.w	$1fb,$1fb,$1fc,$1fc,$1fc,$1fc,$1fd,$1fd
	dc.w	$1fd,$1fe,$1fe,$1fe,$1ff,$1ff,$1ff,$200
	dc.w	$200
Level_start_EPs:
	dc.w	$4b		; 96
	dc.w	$96		; 150
	dc.w	$b4,$64,$7d,$5a,$5a,$5a,$5f,$7fff
	dc.w	0
World_move_delay:
	dc.b	2,1,2,1,2,0,0,2,0,2,1
Travel_speed:
	dc.b	1,2,1,3,1,5,$ff,1,3,2,3
Travel_music:
	dc.b	$e,8,$10,6,$f,7,$19,$e,$14,2,$16,0
World_data:
	dc.w	$10		; Num adjacent maps in x direction
	dc.w	$10		; Num adjacent maps in y direction
	dc.w	$32		; Width of each map in tiles (never used)
	dc.w	$32		; Height of each map in tiles (never used)
	dc.w	1		; Index of first map for this world
	dc.w	6		; Always 6 (morning time?), never used
	dc.w	$12		; Always 18 (night time?), never used
	dc.w	6		; Num adjacent maps in x direction
	dc.w	6		; Num adjacent maps in y direction
	dc.w	$32		; Width of each map in tiles (never used)
	dc.w	$32		; Height of each map in tiles (never used)
	dc.w	$12c		; Index of first map for this world
	dc.w	6		; Always 6 (morning time?), never used
	dc.w	$12		; Always 18 (night time?), never used
	dc.w	4		; Num adjacent maps in x direction
	dc.w	4		; Num adjacent maps in y direction
	dc.w	$32		; Width of each map in tiles (never used)
	dc.w	$32		; Height of each map in tiles (never used)
	dc.w	$201		; Index of first map for this world
	dc.w	6		; Always 6 (morning time?), never used
	dc.w	$12		; Always 18 (night time?), never used ; Num adjacent maps in x direction
Combat_bg_2D_table:
	dc.b	$f		; CombatBackgroundInfo.ImageIndex
	dc.b	$27		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$30		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$31		; CombatBackgroundInfo.PaletteIdNight
	dc.b	1		; CombatBackgroundInfo.ImageIndex
	dc.b	$25		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$25		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$25		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$f		; CombatBackgroundInfo.ImageIndex
	dc.b	$27		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$30		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$31		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$f		; CombatBackgroundInfo.ImageIndex
	dc.b	$27		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$30		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$31		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$d		; CombatBackgroundInfo.ImageIndex
	dc.b	$23		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$2e		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$2f		; CombatBackgroundInfo.PaletteIdNight
	dc.b	1		; CombatBackgroundInfo.ImageIndex
	dc.b	$25		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$25		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$25		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$10		; CombatBackgroundInfo.ImageIndex
	dc.b	$29		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$2c		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$2d		; CombatBackgroundInfo.PaletteIdNight
	dc.b	8		; CombatBackgroundInfo.ImageIndex
	dc.b	$17		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1e		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1f		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$a		; CombatBackgroundInfo.ImageIndex
	dc.b	$19		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$19		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$19		; CombatBackgroundInfo.PaletteIdNight
	dc.b	7		; CombatBackgroundInfo.ImageIndex
	dc.b	$16		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$16		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$16		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$b		; CombatBackgroundInfo.ImageIndex
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdNight
	dc.b	1		; CombatBackgroundInfo.ImageIndex
	dc.b	$25		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$25		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$25		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$a		; CombatBackgroundInfo.ImageIndex
	dc.b	$19		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$19		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$19		; CombatBackgroundInfo.PaletteIdNight
	dc.b	8		; CombatBackgroundInfo.ImageIndex
	dc.b	$17		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1e		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1f		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$10		; CombatBackgroundInfo.ImageIndex
	dc.b	$29		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$2c		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$2d		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$e		; CombatBackgroundInfo.ImageIndex
	dc.b	$24		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$2a		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$2b		; CombatBackgroundInfo.PaletteIdNight
Combat_bg_3D_table:
	dc.b	$a		; CombatBackgroundInfo.ImageIndex
	dc.b	$19		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$19		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$19		; CombatBackgroundInfo.PaletteIdNight
	dc.b	6		; CombatBackgroundInfo.ImageIndex
	dc.b	$15		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$15		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$15		; CombatBackgroundInfo.PaletteIdNight
	dc.b	7		; CombatBackgroundInfo.ImageIndex
	dc.b	$16		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$16		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$16		; CombatBackgroundInfo.PaletteIdNight
	dc.b	9		; CombatBackgroundInfo.ImageIndex
	dc.b	$18		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$18		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$18		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$b		; CombatBackgroundInfo.ImageIndex
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$b		; CombatBackgroundInfo.ImageIndex
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1a		; CombatBackgroundInfo.PaletteIdNight
	dc.b	4		; CombatBackgroundInfo.ImageIndex
	dc.b	$13		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$13		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$13		; CombatBackgroundInfo.PaletteIdNight
	dc.b	5		; CombatBackgroundInfo.ImageIndex
	dc.b	$14		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$14		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$14		; CombatBackgroundInfo.PaletteIdNight
	dc.b	1		; CombatBackgroundInfo.ImageIndex
	dc.b	$25		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$25		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$25		; CombatBackgroundInfo.PaletteIdNight
	dc.b	8		; CombatBackgroundInfo.ImageIndex
	dc.b	$17		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1e		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1f		; CombatBackgroundInfo.PaletteIdNight
	dc.b	8		; CombatBackgroundInfo.ImageIndex
	dc.b	$17		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1e		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1f		; CombatBackgroundInfo.PaletteIdNight
	dc.b	2		; CombatBackgroundInfo.ImageIndex
	dc.b	$11		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$1c		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$1d		; CombatBackgroundInfo.PaletteIdNight
	dc.b	$c		; CombatBackgroundInfo.ImageIndex
	dc.b	$22		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$22		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$22		; CombatBackgroundInfo.PaletteIdNight
	dc.b	1		; CombatBackgroundInfo.ImageIndex
	dc.b	$25		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$25		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$25		; CombatBackgroundInfo.PaletteIdNight
	dc.b	5		; CombatBackgroundInfo.ImageIndex
	dc.b	$28		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$28		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$28		; CombatBackgroundInfo.PaletteIdNight
	dc.b	3		; CombatBackgroundInfo.ImageIndex
	dc.b	$12		; CombatBackgroundInfo.PaletteIdDay
	dc.b	$12		; CombatBackgroundInfo.PaletteIdTwilight
	dc.b	$12		; CombatBackgroundInfo.PaletteIdNight
Race_heights:
	dc.w	$b4		; Human: 180 (also reference height)
	dc.w	$be		; Elf: 190
	dc.w	$96		; Dwarf: 150
	dc.w	$78		; Gnome: 120
	dc.w	$c3		; Half-Elf: 195
	dc.w	$a0		; Sylph: 160
	dc.w	$be		; Feline: 190
	dc.w	$af		; Moranian: 175
	dc.w	$b4		; Thalionic: 180
Chared_portraits:
	dc.w	2,$19,7,$17,$1f,$26,$2c,$33
Destruction_table:
	dc.w	4
Destruction_spell_max_damage_values:
	dc.w	8,$a,$19,8,$10,8,$16,8
	dc.w	$10,$10,$30,$14,$20,$14,$23,$14
	dc.w	$1e,$28,$55,$23,$41,$28,$46,$20
	dc.w	$3c,$5a,$b4,$40,$80,$80,$100
Event_pix_palette_table:
	dc.b	$1b,$20,$21,$21,$21,$21,$21,$21
Stationary_dimensions:
	dc.w	$20,$16
	dc.b	0,$20,0,$b,0,$30,0,$22,0,$30,0,$15,0,$30,0,$27
Condition_object_index_table:
	dc.b	0,7,0,0,8,9,0,0,1,2,3,4,5,6,0,0
File_load_routines:
	dc.l	Copy_memory		; Default (index 0), memory block
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Relocate_music		; Music.amb
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory
	dc.l	Relocate_zoom_buffer		; Zoom buffer (run-time)
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory,Copy_memory,Copy_memory
	dc.l	Copy_memory		; Last in original (Object_icons)
	dc.l	Copy_memory		; Text.amb (was already present)
	dc.l	Copy_memory		; Objects.amb
	dc.l	Copy_memory		; Button_graphics
	dc.l	0		; Reserve load function
File_infos:
	dc.b	$64		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	$32		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	$64		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$6e		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$78		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$78		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$78		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$78		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$79		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$78		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$6e		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$63		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$5a		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$50		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$32		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$800		; Compression space
	dc.b	$50		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	$5a		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$5a		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	$64		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$1000		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$800		; Compression space
	dc.b	$32		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$7f		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$63		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$1000		; Compression space
	dc.b	$65		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$5a		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$50		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$63		; FileInfoSmall.MemPrio
	dc.b	2		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	$5a		; FileInfoSmall.MemPrio
	dc.b	2		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	$64		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$46		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$800		; Compression space
	dc.b	$78		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$78		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$46		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$32		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	$62		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$79		; FileInfoSmall.MemPrio
	dc.b	1		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$7f		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$7f		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$7f		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	$7f		; FileInfoSmall.MemPrio
	dc.b	3		; 1: Chip, 2: Fast, 3: Both
	dc.w	$400		; Compression space
	dc.b	0		; FileInfoSmall.MemPrio
	dc.b	0		; 1: Chip, 2: Fast, 3: Both
	dc.w	0		; Compression space
	dc.b	0,0
Save00_party_data_sav:
	dc.b	$a,"Save.00/Party_data.sav",0
Save00_party_char_amb:
	dc.b	$a,"Save.00/Party_char.amb",0
Save00_automap_amb:
	dc.b	$a,"Save.00/Automap.amb",0
Save00_chest_data_amb:
	dc.b	$a,"Save.00/Chest_data.amb",0
Save00_merchant_data_amb:
	dc.b	$a,"Save.00/Merchant_data.amb",0
ERROR_0026d5ee:
	dc.b	"ERROR",0
Data_path:
	dc.b	1
	dc.b	"AM2_BLIT",0
File_path:
	dc.b	0
	dc.b	"AMBER_ :",0
	dcb.b	32,0
Amberfiles_prefix:
	dc.b	0,"Amberfiles/"
File_name_buffer:
	dcb.b	34,0
File_indices_with_multiple_files:
	dc.w	6		; XMap_data.amb
	dc.w	$f		; XMap_texts.amb
	dc.w	8		; XIcon_gfx.amb
	dc.w	$c		; XWall3D.amb (CHIP)
	dc.w	$1f		; XWall3D.amb (FAST)
	dc.w	$1d		; XObject3D.amb
	dc.w	$21
	dc.w	$1e		; XOverlay3D.amb
THIS_LABEL_IS_FOR_THE_NEXT_LIST:
	dc.w	$b		; XLab_data.amb
	dc.w	0		; End marker
Save_file_names:
	dc.l	Disk_number_party_data_sav,Disk_number_party_char_amb,Disk_number_NPC_char_amb,Disk_number_monster_char_data_amb
	dc.l	Disk_number_portraits_amb,Disk_number_map_data_amb,Disk_number_icon_data_amb,Disk_number_icon_gfx_amb
	dc.l	Disk_number_travel_gfx_amb,Disk_number_NPC_gfx_amb,Disk_number_lab_data_amb,Disk_number_wall3_d_amb
	dc.l	Disk_number_lab_background_amb,Disk_number_pics80x80_amb,Disk_number_map_texts_amb,Disk_number_chest_data_amb
	dc.l	Disk_number_monster_groups_amb,Disk_number_merchant_data_amb,Disk_number_combat_background_amb,Disk_number_monster_gfx_amb
	dc.l	Disk_number_automap_amb,Disk_number_object_texts_amb,Disk_number_event_pix_amb,Disk_number_layouts_amb
	dc.l	Disk_number_music_amb,Disk_number_palettes_amb,Disk_number_riddlemouth_graphics_amb,Disk_number_dict_amb
	dc.l	Disk_number_object3_d_amb,Disk_number_overlay3_d_amb,Disk_number_wall3_d_amb,0
	dc.l	Disk_number_object3_d_amb,Disk_number_saves,Disk_number_party_texts_amb,Disk_number_NPC_texts_amb
	dc.l	Disk_number_automap_graphics_amb,Disk_number_place_data_amb,Disk_number_combat_graphics_amb,Disk_number_floors_amb
	dc.l	Disk_number_save00_party_char_amb,Disk_number_stationary_amb,Disk_number_party_gfx_amb,Object_icons_disk
	dc.l	Disk_number_text_amb
	dc.l	Disk_number_objects_amb		; Objects.amb
	dc.l	Button_graphics_disk		; Button_graphics
	dc.l	0		; Free file slot
	dc.b	0,0
Disk_number_icon_gfx_amb:
	dc.b	3,4,6,0
	dc.b	"0Icon_gfx.amb",0
Disk_number_lab_data_amb:
	dc.b	0,4,6,0
	dc.b	"0Lab_data.amb",0
Disk_number_wall3_d_amb:
	dc.b	0,5,6,0
	dc.b	"0Wall3D.amb",0
Disk_number_map_texts_amb:
	dc.b	3		; Disk number for 1Map_texts.amb
	dc.b	4		; Disk number for 2Map_texts.amb
	dc.b	6		; Disk number for 3Map_texts.amb
	dc.b	0		; End of disk numbers for XMap_texts.amb
	dc.b	"0Map_texts.amb",0
Disk_number_object3_d_amb:
	dc.b	0
	dc.b	4		; Disk number for 2Object3D.amb
	dc.b	6		; Disk number for 3Object3D.amb
	dc.b	0		; End of disk numbers for XObject3D.amb
	dc.b	"0Object3D.amb",0
Disk_number_overlay3_d_amb:
	dc.b	0,5,6,0
	dc.b	"0Overlay3D.amb",0
Disk_number_NPC_char_amb:
	dc.b	7		; Disk number for NPC_char.amb
	dc.b	"NPC_char.amb",0
Disk_number_portraits_amb:
	dc.b	7
	dc.b	"Portraits.amb",0
Disk_number_icon_data_amb:
	dc.b	7
	dc.b	"Icon_data.amb",0
Disk_number_travel_gfx_amb:
	dc.b	7
	dc.b	"Travel_gfx.amb",0
Disk_number_NPC_gfx_amb:
	dc.b	7
	dc.b	"NPC_gfx.amb",0
Disk_number_lab_background_amb:
	dc.b	7
	dc.b	"Lab_background.amb",0
Disk_number_pics80x80_amb:
	dc.b	7
	dc.b	"Pics_80x80.amb",0
Disk_number_object_texts_amb:
	dc.b	7
	dc.b	"Object_texts.amb",0
Disk_number_event_pix_amb:
	dc.b	7
	dc.b	"Event_pix.amb",0
Disk_number_layouts_amb:
	dc.b	7
	dc.b	"Layouts.amb",0
Disk_number_palettes_amb:
	dc.b	7
	dc.b	"Palettes.amb",0
Disk_number_riddlemouth_graphics_amb:
	dc.b	7
	dc.b	"Riddlemouth_graphics",0
Disk_number_party_texts_amb:
	dc.b	7
	dc.b	"Party_texts.amb",0
Disk_number_NPC_texts_amb:
	dc.b	7
	dc.b	"NPC_texts.amb",0
Disk_number_automap_graphics_amb:
	dc.b	7
	dc.b	"Automap_graphics",0
Disk_number_place_data_amb:
	dc.b	7
	dc.b	"Place_data",0
Disk_number_combat_graphics_amb:
	dc.b	7
	dc.b	"Combat_graphics",0
Disk_number_floors_amb:
	dc.b	7
	dc.b	"Floors.amb",0
Disk_number_stationary_amb:
	dc.b	7
	dc.b	"Stationary",0
Disk_number_party_gfx_amb:
	dc.b	7
	dc.b	"Party_gfx.amb",0
Disk_number_objects_amb:
	dc.b	1
	dc.b	"Objects.amb",0
Disk_number_monster_char_data_amb:
	dc.b	8		; Disk number for Monster_char.amb
	dc.b	"Monster_char.amb",0
Disk_number_monster_groups_amb:
	dc.b	8		; Disk number for Monster_groups.amb
	dc.b	"Monster_groups.amb",0
Disk_number_combat_background_amb:
	dc.b	8
	dc.b	"Combat_background.amb",0
Disk_number_monster_gfx_amb:
	dc.b	8
	dc.b	"Monster_gfx.amb",0
Disk_number_music_amb:
	dc.b	9
	dc.b	"Music.amb",0
Disk_number_party_data_sav:
	dc.b	$a
	dc.b	"Party_data.sav",0
Disk_number_party_char_amb:
	dc.b	$a
	dc.b	"Party_char.amb",0
Disk_number_chest_data_amb:
	dc.b	$a
	dc.b	"Chest_data.amb",0
Disk_number_merchant_data_amb:
	dc.b	$a
	dc.b	"Merchant_data.amb",0
Disk_number_automap_amb:
	dc.b	$a
	dc.b	"Automap.amb",0
Disk_number_saves:
	dc.b	$a
	dc.b	"Saves",0
Disk_number_save00_party_char_amb:
	dc.b	$a
	dc.b	"Save.00/Party_char.amb",0
Disk_number_dict_amb:
	dc.b	7
	dc.b	"Dict.amb",0
Disk_number_text_amb:
	dc.b	1
	dc.b	"Text.amb",0
Disk_number_map_data_amb:
	dc.b	3,4,6,0,$30
	dc.b	"Map_data.amb",0
Known_error_text:
	dc.l	0		; Address to "An I/O error has occured"
IO_error_message_placeholder:
	dc.l	0		; Pointer to message placeholder
IO_error_message_current_file:
	dc.l	0		; Addess to "The current file:"
IO_error_file_placeholder:
	dc.l	0		; Pointer to file placeholder
Retry_txt_ptr:
	dc.l	0		; Address to "Retry?"
	dc.l	0		; End marker
Disk_request_text:
	dc.l	0		; Address to "Please insert disk"
Insert_disk_placeholder:
	dc.l	0		; Pointer to disk placeholder
In_any_drive_txt_ptr:
	dc.l	0		; Address to "in any drive"
	dc.l	0		; End marker
Save_disk_request_text:
	dc.l	0		; Address to "Please insert savegame disk"
	dc.l	0		; End marker
Default_text_not_found_string:
	dc.b	"This text-block doesn't exist!",0
	dc.b	0
Text_error_text_ptr:
	dc.l	Default_text_not_found_string		; Might be overwritten by text loader
Lack_of_memory:
	dc.l	Default_lack_of_memory_text		; Might be overwritten by text loader
Out_of_memory_text_ptr:
	dc.l	Default_out_of_memory_text		; Might be overwritten by text loader
Default_lack_of_memory_text:
	dc.b	"Due to lack of chip memory the program will now",0
	dc.b	"deactivate the music.",0
	dc.b	"",0
	dc.b	"Please use the installation program to read the",0
	dc.b	"troubleshooting-document, to find out how this",0
	dc.b	"problem may be avoided.",0
	dc.b	"",0
	dc.b	"Click any mouse button to continue.",0
	dc.b	$ff		; End marker
Default_out_of_memory_text:
	dc.b	"The program has run out of memory! A restart will",0
	dc.b	"now be attempted. Your position in the game won't be",0
	dc.b	"harmed, but you will be returned to the map screen.",0
	dc.b	"",0
	dc.b	"Please use the installation program to read the",0
	dc.b	"troubleshooting-document, to find out how this",0
	dc.b	"problem may be avoided.",0
	dc.b	"",0
	dc.b	"Click any mouse button to continue.",0
	dc.b	$ff		; End marker
	dc.b	0		; Align byte
Divide_start_text_ptr:
	dc.l	0
Divide_inter_text_ptr:
	dc.l	0
Divide_end_text_ptr:
	dc.l	0
No_recup_text:
	dc.l	0		; Placeholder for subject name
Has_no_more_food_txt_ptr:
	dc.l	0		; Address to "has no more food"
	dc.l	0		; End marker
Recup1_text:
	dc.l	0		; Placeholder for subject name
Regains_txt_ptr:
	dc.l	0		; Address to "regains"
Text_regains_LP_placeholder:
	dc.l	0		; Placeholder for LP
Lp_txt_ptr:
	dc.l	0		; Address to "LP"
	dc.l	0		; End marker
Recup2_text:
	dc.l	0		; Placeholder for subject name
Regains2_txt_ptr:
	dc.l	0		; Address to "regains"
Text_regains_LP_and_SP_placeholder_LP:
	dc.l	0		; Placeholder for LP
Lp_and_txt_ptr:
	dc.l	0		; Address to "LP and"
Text_regains_LP_and_SP_placeholder_SP:
	dc.l	0		; Placeholder for SP
Sp_txt_ptr:
	dc.l	0		; Address to "SP"
	dc.l	0		; End marker
Aging_text:
	dc.l	0		; Placeholder for subject name
Has_aged_txt_ptr:
	dc.l	0		; Address to "has aged"
	dc.l	0		; End marker
Ageddeath_text:
	dc.l	0		; Placeholder for subject name
Has_died_of_age_txt_ptr:
	dc.l	0		; Address to "has died of age"
	dc.l	0		; End marker
BuySell_req_text:
	dc.l	0		; Placeholder for the message
Text_place_price_yes_no_message_placeholder_price:
	dc.l	0		; Placeholder for price
Gp_agree_txt_ptr:
	dc.l	0		; Address to "GP. Agree?"
	dc.l	0		; End marker
Food_price_text:
	dc.l	0		; Address to "One ration costs"
Text_buy_food_message_placeholder_price:
	dc.l	0		; Placeholder for price
Gp_txt_ptr:
	dc.l	0		; Address to "GP."
	dc.l	0		; End marker
Make_level_text:
	dc.l	0		; Placeholder for subject name
Has_reached_level_txt_ptr:
	dc.l	0		; Address to "has reached level"
Text_has_reached_level_placeholder_level:
	dc.l	0		; Placeholder for level
Text_txt_ptr:
	dc.l	0		; Address to "!"
	dc.l	0		; End marker
Attack_text:
	dc.l	0		; Placeholder for subject name
Attacks_txt_ptr:
	dc.l	0		; Address to "attacks"
Text_attacks_with_the_placeholder_target:
	dc.l	0		; Placeholder for target name
With_the_txt_ptr:
	dc.l	0		; Address to "with the"
Text_attacks_with_the_placeholder_weapon:
	dc.l	0		; Placeholder for weapon name
Text2_txt_ptr:
	dc.l	0		; Address to "!"
Text_attacks_with_the_end_marker:
	dc.l	0		; End marker
Attack2_text:
	dc.l	0		; Placeholder for subject name
Attacks2_txt_ptr:
	dc.l	0		; Address to "attacks"
Text_attacks_placeholder_target:
	dc.l	0		; Placeholder for target name
Text3_txt_ptr:
	dc.l	0		; Address to "!"
Text_attacks_end_marker:
	dc.l	0		; End marker
Broken_text:
	dc.l	0		; Placeholder for subject name
S_txt_ptr:
	dc.l	0		; Address to "'s"
Text_was_broken_placeholder_item:
	dc.l	0		; Placeholder for equip name
Was_broken_txt_ptr:
	dc.l	0		; Address to "was broken"
	dc.l	0		; End marker
Hit_text:
	dc.l	0		; Placeholder for subject name
Did_txt_ptr:
	dc.l	0		; Address to "did"
Text_did_damage_placeholder_damage:
	dc.l	0		; Placeholder for damage value
Points_of_damage_txt_ptr:
	dc.l	0		; Address to "points of damage"
Text_did_damage_end_marker:
	dc.l	0		; End marker
EP_divide_text:
	dc.l	0		; Address to "Everyone receives"
Text_receive_exp_placeholder_exp:
	dc.l	0		; Placeholder for exp
Experience_points_txt_ptr:
	dc.l	0		; Address to "experience points"
	dc.l	0		; End marker
Magic_action_text:
	dc.l	0		; Placeholder for subject name
Casts_the_txt_ptr:
	dc.l	0		; Address to "casts the"
Text_casts_placeholder_spell:
	dc.l	0		; Placeholder for spell name
Spell_txt_ptr:
	dc.l	0		; Address to "- spell!"
	dc.l	0		; End marker
Magic_object_text:
	dc.l	0		; Placeholder for subject name
Casts_the2_txt_ptr:
	dc.l	0		; Address to "casts the"
Text_casts_from_placeholder_spell:
	dc.l	0		; Placeholder for spell name
Spell_from_the_txt_ptr:
	dc.l	0		; Address to "- spell from the"
Text_casts_from_placeholder_item:
	dc.l	0		; Placeholder for item name
Text4_txt_ptr:
	dc.l	0		; Address to "!"
	dc.l	0		; End marker
Wrong_answer_text:
	dc.l	0		; Placeholder for answer
Is_not_the_right_txt_ptr:
	dc.l	0		; Address to "is not the right answer"
	dc.l	0		; End marker
That_text_ptr:
	dc.l	0		; Address to "That"
Prompts_ptr:
	dc.l	0
Automap_icon_names_ptr:
	dc.l	0
Option_names_ptr:
	dc.l	0
Song_names_ptr:
	dc.l	0
Spell_class_names_ptr:
	dc.l	0
Spell_names_ptr:
	dc.l	0
Language_names_ptr:
	dc.l	0
Class_names_ptr:
	dc.l	0
Race_names_ptr:
	dc.l	0
Skill_names_ptr:
	dc.l	0
Attribute_names_ptr:
	dc.l	0
Short_skill_names_ptr:
	dc.l	0
Short_attr_names_ptr:
	dc.l	0
Item_type_names_ptr:
	dc.l	0
Condition_names_ptr:
	dc.l	0
Magic_txt_ptr:
	dc.l	0		; "Function"
APR_txt_ptr:
	dc.l	0
He_txt_ptr:
	dc.l	0
She_txt_ptr:
	dc.l	0
His_txt_ptr:
	dc.l	0
Hers_txt_ptr:
	dc.l	0
Skills_txt_ptr:
	dc.l	0
Attrs_txt_ptr:
	dc.l	0
Language_txt_ptr:
	dc.l	0
Conditions_txt_ptr:
	dc.l	0
Male_txt_ptr:
	dc.l	0
Female_txt_ptr:
	dc.l	0
Both_txt_ptr:
	dc.l	0
Compass_txt_ptr:
	dc.l	0
Age_nr_ptr:
	dc.l	0
Age_txt_ptr:
	dc.l	0
Skill_txt_ptr:
	dc.l	0
Attr_txt_ptr:
	dc.l	0
EP_txt_ptr:
	dc.l	0
Experience_nr_ptr:
	dc.l	0
Experience_txt_ptr:
	dc.l	0
LP_txt_ptr:
	dc.l	0
PP_txt_ptr:
	dc.l	0
SLP_txt_ptr:
	dc.l	0
TP_txt_ptr:
	dc.l	0
Goldfood_txt_ptr:
	dc.l	0
ProtDam_txt_ptr:
	dc.l	0
Gold_txt_ptr:
	dc.l	0
Food_txt_ptr:
	dc.l	0
Classes_txt_ptr:
	dc.l	0
Sex_txt_ptr:
	dc.l	0
Weight2_nr_ptr:
	dc.l	0
Weight2_txt_ptr:
	dc.l	0
Hands_nr_ptr:
	dc.l	0
Hands_txt_ptr:
	dc.l	0
Fingers_nr_ptr:
	dc.l	0
Fingers_txt_ptr:
	dc.l	0
Damage_nr_ptr:
	dc.l	0
Damage_txt_ptr:
	dc.l	0
Protection_nr_ptr:
	dc.l	0
Protection_txt_ptr:
	dc.l	0
LP_max_nr_ptr:
	dc.l	0
LP_max_txt_ptr:
	dc.l	0
PP_max_nr_ptr:
	dc.l	0
PP_max_txt_ptr:
	dc.l	0
MBW_nr_ptr:
	dc.l	0
MBW_txt_ptr:
	dc.l	0
MBA_nr_ptr:
	dc.l	0
MBA_txt_ptr:
	dc.l	0
Attr2_txt_ptr:
	dc.l	0
Skill2_txt_ptr:
	dc.l	0
Cursed_txt_ptr:
	dc.l	0
Weight_txt_ptr:
	dc.l	0
Weight_nr2_ptr:
	dc.l	0
Weight_nr1_ptr:
	dc.l	0
Weight_kg_txt_ptr:
	dc.l	0
Legend_txt_ptr:
	dc.l	0
YAH_text_ptr:
	dc.l	0
On_txt_ptr:
	dc.l	0
Off_txt_ptr:
	dc.l	0
MonKnow_line_ptr:
	dc.l	0
Chared_headline_ptr:
	dc.l	0
Inventory_headline_ptr:
	dc.l	0
	dc.b	0,0
