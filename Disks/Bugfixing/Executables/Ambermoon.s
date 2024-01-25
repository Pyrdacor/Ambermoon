
; #######################
; # HUNK00 - CODE       #
; #######################
	section	hunk00,CODE
;   {
start:
	jsr FUN_RetrieveVBRAddressAsSupervisor
	jsr FUN_0021fd64
	jsr FUN_0021fa00
	jsr FUN_0021f9b4
	jsr FUN_0021fdd6
	tst.w DAT_0022104c
	beq.b LAB_0021f02e
	tst.b DAT_00221030
	beq.b LAB_0021f034
LAB_0021f02e:
	jmp LAB_0021f0c4
LAB_0021f034:
	jsr FUN_OpenLibraries
	jsr FUN_0021fa16
	cmpi.w #$00000001,DAT_0022104c
	bne.b LAB_0021f06e
	jsr FUN_0021ff3a
	bne.b LAB_0021f06e
	lea DAT_002204e6,A0
	jsr FUN_0021f5a2
	move.l #$00000005,DAT_00221046
	jmp LAB_0021f0b0
LAB_0021f06e:
	st DAT_00221033
	move.l #s_RUNNING,D1 ; Process name = "RUNNING"
	moveq #$00000000,D2 ; Prio = 0 (normal)
	lea start-4,A0
	move.l (A0),D3 ; Seglist
	clr.l (A0)
	move.l #$00000800,D4 ; StackSize = 0x800
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$008a,A6) ; dos.CreateProc
	movea.l (SP)+,A6
	moveq #$00000000,D1 ; Lock = 0
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$007e,A6) ; dos.CurrentDir
	movea.l (SP)+,A6
	move.l D0,DAT_LastCurrentDirLock
LAB_0021f0b0:
	jsr FUN_0021fa7e
	jsr FUN_CloseLibraries
	move.l DAT_00221046,D0
	rts
;   }

; #######################
; # HUNK01 - CODE       #
; #######################
	section	hunk01,CODE
;   {
LAB_0021f0c4:
	move.l #LAB_00220f14,D0
	addq.l #$00000007,D0
	andi.l #-$00000008,D0
	move.l D0,DAT_00220f10
	jsr FUN_OpenLibraries
	jsr FUN_0021fd64
	jsr FUN_0021fa16
	tst.b DAT_00221033
	beq.b LAB_0021f11a
	moveq #$00000064,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$00c6,A6)
	movea.l (SP)+,A6
	move.l DAT_LastCurrentDirLock,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$007e,A6)
	movea.l (SP)+,A6
	bra.w LAB_0021f1fa
LAB_0021f11a:
	tst.b DAT_0022102d
	bne.w LAB_0021f19c
	moveq #$00000000,D7
	move.l #LAB_00220cde,D1
	moveq #-$00000002,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0054,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.b LAB_0021f178
	move.l D0,D7
	movea.l DAT_00220f10,A5
	move.l D7,D1
	move.l A5,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0066,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.b LAB_0021f178
	tst.l ($0004,A5)
	bpl.w LAB_0021f178
	move.l D7,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$005a,A6)
	movea.l (SP)+,A6
	bra.b LAB_0021f19c
LAB_0021f178:
	tst.l D7
	beq.b LAB_0021f18c
	move.l D7,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$005a,A6)
	movea.l (SP)+,A6
LAB_0021f18c:
	lea DAT_00220472,A0
	jsr FUN_0021f5a2
	bra.w LAB_0021f3f4
LAB_0021f19c:
	tst.b DAT_0022102d
	beq.w LAB_0021f1fa
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0084,A6)
	movea.l (SP)+,A6
	lea s_RUNNING,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0126,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.b LAB_0021f1de
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$008a,A6)
	movea.l (SP)+,A6
	bra.w LAB_0021f3f4
LAB_0021f1de:
	movea.l DAT_Task,A0
	move.l #s_RUNNING,($000a,A0)
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$008a,A6)
	movea.l (SP)+,A6
LAB_0021f1fa:
	jsr FUN_0021f8c8
	tst.w DAT_0022104c
	beq.b LAB_0021f20e
	jsr FUN_0021fdf4
LAB_0021f20e:
	jsr FUN_CreateWindow
	jsr FUN_0021fb74
	tst.w DAT_0022104c
	bne.b LAB_0021f23c
	jsr FUN_0021ff3a
	bne.b LAB_0021f23c
	lea DAT_002205c9,A0
	jsr FUN_0021f5a2
	jmp LAB_0021f3f4
LAB_0021f23c:
	tst.b DAT_00221030
	beq.b LAB_0021f272
	cmpi.w #$00000001,DAT_0022104c
	bne.b LAB_0021f272
	jsr FUN_0021ff3a
	bne.b LAB_0021f272
	lea DAT_002204e6,A0
	jsr FUN_0021f5a2
	move.l #$00000005,DAT_00221046
	jmp LAB_0021f3f4
LAB_0021f272:
	lea BYTE_00220dc7,A0
	jsr FUN_0021f41a
	tst.l D0
	beq.w LAB_0021f3f4
	tst.w (A0)
	sne DAT_00221024
	move.l DAT_0022105a,D0
	movea.l A0,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$00d2,A6)
	movea.l (SP)+,A6
	jsr FUN_00220010
	lea BYTE_00220d7c,A1
	jsr FUN_RunExecutable
	jsr FUN_002200b2
	cmp.l #-$00000001,D0
	beq.w LAB_0021f3f4
	lea BYTE_00220d9c,A0
	jsr FUN_0021f41a
	tst.l D0
	beq.w LAB_0021f3f4
	move.l A0,DAT_00221020
	lea DAT_00221020,A0
	lea BYTE_00220d8b,A1
	jsr FUN_RunExecutable
	cmp.l #-$00000001,D0
	bne.b LAB_0021f316
	move.l DAT_0022105a,D0
	movea.l DAT_00221020,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$00d2,A6)
	movea.l (SP)+,A6
	jmp LAB_0021f3f4
LAB_0021f316:
	move.w D0,D7
	move.l DAT_0022105a,D0
	movea.l DAT_00221020,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$00d2,A6)
	movea.l (SP)+,A6
	cmp.w #$0003,D7
	beq.w LAB_0021f3f4
	move.w D7,DAT_0022102a
	move.l #$00abacab,DAT_00221026
	jsr FUN_DetermineAssemblyToRun
	move.b DAT_UseAM2CPU,DAT_LoaderVersionAndBlitterFlag
	move.l DAT_LoaderVersionAndBlitterFlag,D3
	lea DAT_AM2CPU,A1
	lea DAT_00221026,A0
	jsr FUN_RunExecutable
	tst.l D0
	beq.w LAB_0021f3f4
	cmp.l #-$00000001,D0
	beq.w LAB_0021f3f4
	cmp.l #-$00001388,D0
	ble.b LAB_0021f39a
	lea DAT_00220244,A0
	jsr FUN_0021f768
	bra.w LAB_0021f3f4
LAB_0021f39a:
	neg.w D0
	subi.l #$00001388,D0
	move.b D0,DAT_00221024
	lea BYTE_00220dba,A0
	jsr FUN_0021f41a
	tst.l D0
	beq.w LAB_0021f3f4
	move.l A0,DAT_00221020
LAB_0021f3c0:
	lea DAT_00221020,A0
	lea BYTE_00220da9,A1
	jsr FUN_RunExecutable
	jsr FUN_0021ffd0
	bne.b LAB_0021f3c0
	move.l DAT_0022105a,D0
	movea.l DAT_00221020,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$00d2,A6)
	movea.l (SP)+,A6
LAB_0021f3f4:
	jsr FUN_0021fb94
	jsr FUN_0021fcb4
	jsr FUN_0021fa7e
	jsr FUN_0021ff04
	jsr FUN_CloseLibraries
	move.l DAT_00221046,D0
	rts
FUN_0021f41a:
	movem.l A5/A4/A2/A1/D7/D6/D3/D2/D1,-(SP)
	clr.l D6
	jsr FUN_GetFilePath
	move.l A0,DAT_ExePath
	movea.l A0,A5
	jsr FUN_0021f4de
	tst.l D0
	beq.w LAB_0021f4ac
	move.l D0,D7
	moveq #$00000002,D1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$00c6,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.w LAB_0021f4ac
	movea.l D0,A4
	move.l A5,D1
	move.l #$000003ed,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$001e,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.w LAB_0021f4ac
	move.l D0,D6
	move.l D6,D1
	move.l A4,D2
	move.l D7,D3
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$002a,A6)
	movea.l (SP)+,A6
	cmp.l D0,D3
	bne.w LAB_0021f4ac
	move.l D6,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0024,A6)
	movea.l (SP)+,A6
	move.l D7,DAT_0022105a
	movea.l A4,A0
	move.l D7,D0
LAB_0021f4a6:
	movem.l (SP)+,D1/D2/D3/D6/D7/A1/A2/A4/A5
	rts
LAB_0021f4ac:
	tst.l D6
	beq.b LAB_0021f4c0
	move.l D6,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0024,A6)
	movea.l (SP)+,A6
LAB_0021f4c0:
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0084,A6)
	movea.l (SP)+,A6
	lea DAT_002201be,A0
	jsr FUN_0021f768
	moveq #$00000000,D0
	bra.b LAB_0021f4a6
FUN_0021f4de:
	movem.l A5/A1/A0/D7/D6/D2/D1,-(SP)
	moveq #$00000000,D7
	move.l A0,D1
	moveq #-$00000002,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0054,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.b LAB_0021f52c
	move.l D0,D6
	movea.l DAT_00220f10,A5
	move.l D6,D1
	move.l A5,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0066,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.b LAB_0021f52c
	move.l ($007c,A5),D7
	move.l D6,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$005a,A6)
	movea.l (SP)+,A6
LAB_0021f52c:
	move.l D7,D0
	movem.l (SP)+,D1/D2/D6/D7/A0/A1/A5
	rts
FUN_RunExecutable:
	movem.l A5/A2/A1/A0/D7/D2/D1,-(SP)
	movea.l A0,A5 ; A5 now has 0xabacab
	movea.l A1,A0 ; A0 now has the exe name like AM2_CPU
	jsr FUN_GetFilePath ; Filename to path (disk or folder)
	move.l A0,DAT_ExePath ; Store exe path
	move.l A0,D1 ; Store exe path in D1.
			; LoadSeg needs it there.
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0096,A6) ; dos.LoadSeg (loads exe)
	movea.l (SP)+,A6
	tst.l D0 ; if LoadSeg returns 0, some error occured
	bne.b LAB_0021f57a
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0084,A6) ; dos.IOErr
	movea.l (SP)+,A6
	lea DAT_002201be,A0
	jsr FUN_0021f768
	moveq #-$00000001,D0 ; In error case return -1
	bra.b LAB_0021f59c
LAB_0021f57a:
	move.l D0,D1 ; Move ptr to loaded hunks to D1
	lsl.l #$00000002,D1 ; BCL pointer (or reglist) to
			; real data pointer is multiply
			; by 4. Then you are at the file
			; header, so add 4 to be at the
			; first hunk address.
	addq.l #$00000004,D1
	movea.l D1,A1 ; A1 now points to the first code hunk.
	movea.l A5,A0
	move.l D0,-(SP)
	jsr (A1) ; Call the code hunk of the real exe
	move.l D0,D7 ; Save return code from exe in D7
	move.l (SP)+,D1 ; Restore the reglist in D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6 ; UnLoadSeg needs the reglist in D1
	jsr (-$009c,A6) ; dos.UnLoadSeg
	movea.l (SP)+,A6
	move.l D7,D0 ; Return the exit code of the called exe
LAB_0021f59c:
	movem.l (SP)+,D1/D2/D7/A0/A1/A2/A5
	rts
FUN_0021f5a2:
	movem.l A5/A2/A1/A0/D3/D2/D1/D0,-(SP)
	jsr FUN_0021fcb4
	movea.l A0,A5
	move.l #LAB_00220c90,D1 ; Filename
	move.l #$000003ed,D2 ; Access mode = MODE_OLDFILE
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$001e,A6) ; dos.Open
	movea.l (SP)+,A6
	tst.l D0
	beq.w LAB_0021f602
	move.l D0,DAT_0022105e
	movea.l A5,A0
	jsr FUN_0021f6e2
	lea s_PleasePressReturn,A0
	jsr FUN_0021f73c
	jsr FUN_0021f6c4
	move.l DAT_0022105e,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0024,A6)
	movea.l (SP)+,A6
LAB_0021f602:
	movem.l (SP)+,D0/D1/D2/D3/A0/A1/A2/A5
	rts
FUN_0021f608:
	movem.l A5/A2/A1/A0/D7/D3/D2/D1/D0,-(SP)
	jsr FUN_0021fcb4
	move.w D0,D7
	movea.l A0,A5
	move.l #LAB_00220c90,D1
	move.l #$000003ed,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$001e,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.w LAB_0021f6be
	move.l D0,DAT_0022105e
	lea s_AnErrorHasOccured,A0
	jsr FUN_0021f73c
	movea.l A5,A0
	jsr FUN_0021f73c
	cmp.w #$0003,D7
	beq.b LAB_0021f65c
	cmp.w #$0002,D7
	bne.b LAB_0021f668
LAB_0021f65c:
	movea.l DAT_ExePath,A0
	jsr FUN_0021f73c
LAB_0021f668:
	lea PTR_s_EmptyString_00220c50,A0
	lsl.w #$00000002,D7
	movea.l ($00,A0,D7.w),A0
	jsr FUN_0021f6e2
	lea s_PleasePressReturn,A0
	jsr FUN_0021f73c
	jsr FUN_0021f6c4
	lea BYTE_00220b67,A0
	jsr FUN_0021f6e2
	lea s_PleasePressReturn,A0
	jsr FUN_0021f73c
	jsr FUN_0021f6c4
	move.l DAT_0022105e,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0024,A6)
	movea.l (SP)+,A6
LAB_0021f6be:
	movem.l (SP)+,D0/D1/D2/D3/D7/A0/A1/A2/A5
	rts
FUN_0021f6c4:
	move.l DAT_0022105e,D1
	move.l #DAT_00221046-4,D2
	moveq #$00000001,D3
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$002a,A6)
	movea.l (SP)+,A6
	rts
FUN_0021f6e2:
	movem.l A1/A0/D3/D2/D1/D0,-(SP)
	movea.l A0,A2
	jsr FUN_0021f7a8
	tst.l D0
	beq.b LAB_0021f736
	lea ($01,A2,D0.l),A2
LAB_0021f6f6:
	move.l DAT_0022105e,D1
	move.l A0,D2
	move.l D0,D3
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0030,A6)
	movea.l (SP)+,A6
	movea.l A2,A0
	jsr FUN_0021f7a8
	tst.l D0
	beq.b LAB_0021f736
	lea ($01,A2,D0.l),A2
	move.l A0,-(SP)
	lea s_PressAnyKeyToContinue,A0
	jsr FUN_0021f73c
	movea.l (SP)+,A0
	jsr FUN_0021f6c4
	bra.b LAB_0021f6f6
LAB_0021f736:
	movem.l (SP)+,D0/D1/D2/D3/A0/A1
	rts
FUN_0021f73c:
	movem.l A1/A0/D3/D2/D1/D0,-(SP)
	jsr FUN_0021f7a8
	tst.l D0
	beq.b LAB_0021f762
	move.l DAT_0022105e,D1
	move.l A0,D2
	move.l D0,D3
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0030,A6)
	movea.l (SP)+,A6
LAB_0021f762:
	movem.l (SP)+,D0/D1/D2/D3/A0/A1
	rts
FUN_0021f768:
	movem.l A0/D1/D0,-(SP)
	move.w D0,D1
LAB_0021f76e:
	cmpi.w #-$00000001,(A0)
	beq.b LAB_0021f78e
	cmp.w (A0),D1
	beq.b LAB_0021f798
	addq.l #$00000004,A0
	jsr FUN_0021f7a8
	addq.l #$00000001,D0
	btst.l #$00000000,D0
	beq.b LAB_0021f78a
	addq.l #$00000001,D0
LAB_0021f78a:
	adda.l D0,A0
	bra.b LAB_0021f76e
LAB_0021f78e:
	lea s_FileError+721,A0
	moveq #$00000000,D0
	bra.b LAB_0021f79c
LAB_0021f798:
	addq.l #$00000002,A0
	move.w (A0)+,D0
LAB_0021f79c:
	jsr FUN_0021f608
	movem.l (SP)+,D0/D1/A0
	rts
FUN_0021f7a8:
	move.l A0,-(SP)
	moveq #-$00000001,D0
LAB_0021f7ac:
	addq.l #$00000001,D0
	tst.b (A0)+
	bne.b LAB_0021f7ac
	movea.l (SP)+,A0
	rts
FUN_DetermineAssemblyToRun:
	movem.l A6/A5/A0/D7/D0,-(SP)
	sf DAT_UseAM2CPU
	movea.l $4,A0
	btst.b #$00000001,($0129,A0)
	beq.w LAB_0021f8b6
	movea.l DAT_VBRAddress,A5
	lea $00dff000,A6
	lea DAT_00221036,A0
	move.w ($0002,A6),(A0)+
	move.w ($001c,A6),(A0)+
	move.l ($006c,A5),(A0)+
LAB_0021f7ee:
	btst.b #$00000006,($0002,A6)
	btst.b #$00000006,($0002,A6)
	bne.b LAB_0021f7ee
	move.l #LAB_0021f8bc,($006c,A5)
	move.w #$7fff,($0096,A6)
	move.w #$7fff,($009a,A6)
	move.w #-$79c0,($0096,A6)
	move.w #-$3fc0,($009a,A6)
	lea $00010000,A0
	move.l A0,($0050,A6)
	move.l A0,($004c,A6)
	move.l A0,($0048,A6)
	move.l A0,($0054,A6)
	move.l #-$00000001,($0044,A6)
	move.w #$0000,($0064,A6)
	move.w #$0000,($0062,A6)
	move.w #$0000,($0060,A6)
	move.w #$0000,($0066,A6)
	move.l #$0f800000,($0040,A6)
	lea DAT_0022103e,A0
	clr.l (A0)
	moveq #$00000000,D7
	move.w #$140a,($0058,A6) ; Copy 5130 words with D=ABC and loop
			; until the blit finish interrupt sets
			; D7. Each loop will increase a counter.
			; If it is < 256 at the end of the blit,
			; use AM2_BLIT, otherwise AM2_CPU.
LAB_0021f86a:
	addq.l #$00000001,(A0)
	tst.b D7
	beq.b LAB_0021f86a
	move.l (A0),D0
	cmp.l #$00000100,D0
	spl DAT_UseAM2CPU
	lea DAT_00221036,A0
	move.w (A0)+,D0
	ori.w #-$00008000,D0
	move.w #$7fff,($0096,A6)
	move.w D0,($0096,A6)
	move.w (A0)+,D0
	ori.w #-$00008000,D0
	move.w #$7fff,($009a,A6)
	move.w D0,($009a,A6)
	move.l (A0)+,($006c,A5)
LAB_0021f8a8:
	btst.b #$00000006,($0002,A6)
	btst.b #$00000006,($0002,A6)
	bne.b LAB_0021f8a8
LAB_0021f8b6:
	movem.l (SP)+,D0/D7/A0/A5/A6
	rts
LAB_0021f8bc:
	st D7
	move.w #$0040,$00dff09c
	rte
FUN_0021f8c8:
	movem.l A1/A0/D2/D1/D0,-(SP)
	tst.b DAT_00221030
	bne.w LAB_0021f926
	sf DAT_LoadFromFolder
	move.l #LAB_00220d70,D1
	moveq #-$00000002,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0054,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.b LAB_0021f90a
	move.l D0,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$005a,A6)
	movea.l (SP)+,A6
	bra.w LAB_0021f9ae
LAB_0021f90a:
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0084,A6)
	movea.l (SP)+,A6
	cmp.w #$00cd,D0
	seq DAT_LoadFromFolder
	bra.w LAB_0021f9ae
LAB_0021f926:
	st DAT_LoadFromFolder
	move.l #LAB_00220cde,D1
	move.l #$000003ed,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$001e,A6)
	movea.l (SP)+,A6
	tst.l D0
	beq.w LAB_0021f9ae
	move.l D0,-(SP)
	lsl.l #$00000002,D0
	movea.l D0,A0
	movea.l ($0008,A0),A0
	moveq #$00000000,D0
	move.b ($000e,A0),D0
	andi.l #$00000003,D0
	cmp.l #$00000000,D0
	bne.b LAB_0021f99e
	movea.l ($0010,A0),A0
	movea.l ($000a,A0),A0
	cmpi.b #$00000044,(A0)+
	bne.b LAB_0021f99e
	cmpi.b #$00000046,(A0)+
	bne.b LAB_0021f99e
	move.b (A0),D0
	cmp.b #$30,D0
	beq.b LAB_0021f998
	cmp.b #$31,D0
	beq.b LAB_0021f998
	cmp.b #$32,D0
	beq.b LAB_0021f998
	cmp.b #$33,D0
	bne.b LAB_0021f99e
LAB_0021f998:
	sf DAT_LoadFromFolder
LAB_0021f99e:
	move.l (SP)+,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0024,A6)
	movea.l (SP)+,A6
LAB_0021f9ae:
	movem.l (SP)+,D0/D1/D2/A0/A1
	rts
FUN_0021f9b4:
	movem.l A1/A0/D0,-(SP)
	clr.w DAT_0022104c
	tst.b DAT_0022102d
	bne.w LAB_0021f9fa
	cmp.l #$00000001,D0
	beq.b LAB_0021f9fa
LAB_0021f9d0:
	lea DAT_00220cd1,A1
LAB_0021f9d6:
	move.b (A0)+,D0
	beq.b LAB_0021f9fa
	cmp.b (A1),D0
	bne.b LAB_0021f9d0
	addq.l #$00000001,A1
	tst.b (A1)
	bne.b LAB_0021f9d6
	moveq #$00000000,D0
	move.b (A0),D0
	subi.b #$00000030,D0
	cmp.w #$000a,D0
	bcs.b LAB_0021f9f4
	moveq #-$00000001,D0
LAB_0021f9f4:
	move.w D0,DAT_0022104c
LAB_0021f9fa:
	movem.l (SP)+,D0/A0/A1
	rts
FUN_0021fa00:
	move.l A0,-(SP)
	movea.l DAT_Task,A0
	tst.l ($00ac,A0)
	seq DAT_0022102d
	movea.l (SP)+,A0
	rts
FUN_0021fa16:
	movem.l A5/A1/A0/D1/D0,-(SP)
	tst.b DAT_00221033
	bne.w LAB_0021fa78
	tst.b DAT_0022102d
	beq.w LAB_0021fa78
	movea.l DAT_Task,A5
	lea ($005c,A5),A5
	movea.l A5,A0
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0180,A6)
	movea.l (SP)+,A6
	movea.l A5,A0
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0174,A6)
	movea.l (SP)+,A6
	movea.l D0,A5
	move.l A5,DAT_00221062
	move.l ($0024,A5),D0
	beq.b LAB_0021fa78
	movea.l D0,A0
	move.l (A0),D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$007e,A6)
	movea.l (SP)+,A6
LAB_0021fa78:
	movem.l (SP)+,D0/D1/A0/A1/A5
	rts
FUN_0021fa7e:
	movem.l A1/A0/D1/D0,-(SP)
	tst.l DAT_00221062
	beq.b LAB_0021fab2
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0084,A6)
	movea.l (SP)+,A6
	movea.l DAT_00221062,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$017a,A6)
	movea.l (SP)+,A6
	clr.l DAT_00221062
LAB_0021fab2:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_OpenLibraries:
	movem.l A1/A0/D1/D0,-(SP)
	moveq #$00000021,D0
	lea s_DosLibrary,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0228,A6)
	movea.l (SP)+,A6
	move.l D0,DAT_DOSLibrary
	moveq #$00000021,D0
	lea s_GraphicsLibrary,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0228,A6)
	movea.l (SP)+,A6
	move.l D0,DAT_GraphicsLibrary
	moveq #$00000021,D0
	lea s_IntuitionLibrary,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0228,A6)
	movea.l (SP)+,A6
	move.l D0,DAT_IntuitionLibrary
	movea.l D0,A0
	move.w ($0014,A0),D0
	move.w D0,DAT_0022104a
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_CloseLibraries:
	movem.l A1/A0/D1/D0,-(SP)
	move.l DAT_DOSLibrary,D0
	beq.b LAB_0021fb3e
	movea.l D0,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$019e,A6)
	movea.l (SP)+,A6
LAB_0021fb3e:
	move.l DAT_GraphicsLibrary,D0
	beq.b LAB_0021fb56
	movea.l D0,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$019e,A6)
	movea.l (SP)+,A6
LAB_0021fb56:
	move.l DAT_IntuitionLibrary,D0
	beq.b LAB_0021fb6e
	movea.l D0,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$019e,A6)
	movea.l (SP)+,A6
LAB_0021fb6e:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_0021fb74:
	movem.l A1/A0/D1/D0,-(SP)
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$004e,A6)
	movea.l (SP)+,A6
	tst.l D0
	sne DAT_00221032
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_0021fb94:
	movem.l A1/A0/D1/D0,-(SP)
	tst.b DAT_00221032
	beq.b LAB_0021fbae
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$00d2,A6)
	movea.l (SP)+,A6
LAB_0021fbae:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_CreateWindow:
	movem.l A1/A0/D1/D0,-(SP)
	tst.b DAT_00221031
	bne.w LAB_0021fcae
	lea DAT_ScreenInfo,A0
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$00c6,A6) ; intuition.OpenScreen
	movea.l (SP)+,A6
	move.l D0,DAT_Screen
	lea DAT_WindowInfo,A0
	move.l D0,DAT_WindowInfo+30
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$00cc,A6) ; intuition.OpenWindow
	movea.l (SP)+,A6
	move.l D0,DAT_Window
	movea.l DAT_Screen,A0
	moveq #$00000000,D0 ; False -> Hide title
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$011a,A6) ; intuition.ShowTitle
	movea.l (SP)+,A6
	movea.l DAT_Screen,A0
	lea ($002c,A0),A0 ; Screen's viewport
	lea DAT_ViewPortColors,A1 ; $000 and $777
	moveq #$00000002,D0 ; 2 colors, background and color1
	move.l A6,-(SP)
	movea.l DAT_GraphicsLibrary,A6
	jsr (-$00c0,A6) ; graphics.LoadRGB4
	movea.l (SP)+,A6
	movea.l DAT_Task,A0
	move.l ($00b8,A0),DAT_00221082
	move.l DAT_Window,($00b8,A0)
	move.l #LAB_00220cde,D1 ; File "Ambermoon"
	move.l #$000003ed,D2 ; Access mode = 1005
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$001e,A6) ; dos.Open
	movea.l (SP)+,A6
	tst.l D0
	beq.b LAB_0021fca8
	move.l D0,-(SP)
	lsl.l #$00000002,D0
	movea.l D0,A0
	movea.l ($0008,A0),A0
	moveq #$00000000,D0
	move.b ($000e,A0),D0
	andi.l #$00000003,D0
	cmp.l #$00000000,D0
	bne.b LAB_0021fc98
	movea.l ($0010,A0),A0
	move.l ($00b8,A0),DAT_00221086
	move.l DAT_Window,($00b8,A0)
LAB_0021fc98:
	move.l (SP)+,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0024,A6)
	movea.l (SP)+,A6
LAB_0021fca8:
	st DAT_00221031
LAB_0021fcae:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_0021fcb4:
	movem.l A1/A0/D1/D0,-(SP)
	tst.b DAT_00221031
	beq.w LAB_0021fd5e
	movea.l DAT_Task,A0
	move.l DAT_00221082,($00b8,A0)
	move.l #LAB_00220cde,D1
	move.l #$000003ed,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$001e,A6)
	movea.l (SP)+,A6
	tst.l D0
	bmi.b LAB_0021fd30
	move.l D0,-(SP)
	lsl.l #$00000002,D0
	movea.l D0,A0
	movea.l ($0008,A0),A0
	moveq #$00000000,D0
	move.b ($000e,A0),D0
	andi.l #$00000003,D0
	cmp.l #$00000000,D0
	bne.b LAB_0021fd20
	move.l ($0010,A0),D0
	movea.l D0,A0
	move.l DAT_00221086,($00b8,A0)
	sf DAT_00221031
LAB_0021fd20:
	move.l (SP)+,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0024,A6)
	movea.l (SP)+,A6
LAB_0021fd30:
	movea.l DAT_Window,A0
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$0048,A6)
	movea.l (SP)+,A6
	clr.l DAT_Window
	movea.l DAT_Screen,A0
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$0042,A6)
	movea.l (SP)+,A6
LAB_0021fd5e:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_0021fd64:
	movem.l A1/A0/D1/D0,-(SP)
	suba.l A1,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0126,A6)
	movea.l (SP)+,A6
	move.l D0,DAT_Task
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_GetFilePath:
	movem.l A1/D0,-(SP)
	movea.l A0,A1 ; A1 is the filename preceeded by disk index
	tst.b DAT_LoadFromFolder
	bne.b LAB_0021fdb0
	lea s_AMBER+6,A0 ; Insert disk letter into format string
	move.b (A1)+,D0 ; First 'char' is the disk index.
	addi.b #$00000040,D0 ; Add 0x40 to get 'A', 'B', 'C', etc.
	move.b D0,(A0)+
	addq.l #$00000001,A0 ; Now point to the start of the filename
	jsr FUN_CopyString
	lea s_AMBER,A0 ; Re-select whole path for return
	bra.b LAB_0021fdc4 ; Done
LAB_0021fdb0:
	lea s_Amberfiles+11,A0 ; Load from folder Amberfiles
	addq.l #$00000001,A1 ; Skip disk index
	jsr FUN_CopyString
	lea s_Amberfiles,A0 ; Return path
LAB_0021fdc4:
	movem.l (SP)+,D0/A1
	rts
FUN_CopyString:
	move.l D0,-(SP) ; Copies bytes until a 0 byte occurs
LAB_0021fdcc:
	move.b (A1)+,D0
	move.b D0,(A0)+
	bne.b LAB_0021fdcc
	move.l (SP)+,D0
	rts
FUN_0021fdd6:
	movem.l A0/D0,-(SP)
	movea.l $4,A0
	move.w ($0014,A0),D0
	cmp.w #$0024,D0
	spl DAT_00221030
	movem.l (SP)+,D0/A0
	rts
FUN_0021fdf4:
	movem.l A1/A0/D1/D0,-(SP)
	tst.b DAT_00221030
	beq.w LAB_0021fefe
	tst.b DAT_00221034
	bne.w LAB_0021fefe
	lea BYTE_00220d55,A0
	jsr FUN_GetFilePath
	move.l A0,DAT_ExePath
	move.l A0,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0096,A6)
	movea.l (SP)+,A6
	tst.l D0
	bne.b LAB_0021fe50
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0084,A6)
	movea.l (SP)+,A6
	lea DAT_002201be,A0
	jsr FUN_0021f768
	bra.w LAB_0021fefe
LAB_0021fe50:
	lsl.l #$00000002,D0
	addi.l #$00000012,D0
	move.l D0,DAT_00221072
	moveq #-$00000001,D0
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$014a,A6)
	movea.l (SP)+,A6
	lea DAT_00220e22,A0
	move.b D0,($000f,A0)
	move.l DAT_Task,($0010,A0)
	lea s_ConsoleDevice,A0
	lea DAT_00220e44,A1
	moveq #-$00000001,D0
	moveq #$00000000,D1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$01bc,A6)
	movea.l (SP)+,A6
	tst.l D0
	bne.w LAB_0021fefe
	lea DAT_00220e44,A1
	move.w #$000a,($001c,A1)
	move.l #$00000020,($0024,A1)
	move.l DAT_00221072,($0028,A1)
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$01c8,A6)
	movea.l (SP)+,A6
	lea DAT_00220e44,A1
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$01c2,A6)
	movea.l (SP)+,A6
	moveq #$00000000,D0
	move.b DAT_00220e31,D0
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$0150,A6)
	movea.l (SP)+,A6
	st DAT_00221034
LAB_0021fefe:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_0021ff04:
	movem.l A1/A0/D1/D0,-(SP)
	tst.b DAT_00221034
	beq.w LAB_0021ff34
	move.l DAT_00221072,D1
	subi.l #$00000012,D1
	lsr.l #$00000002,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$009c,A6)
	movea.l (SP)+,A6
	sf DAT_00221034
LAB_0021ff34:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_0021ff3a:
	movem.l A3/A2/A1/A0/D7/D6/D3/D2/D1/D0,-(SP)
	moveq #-$00000001,D7
	tst.b DAT_LoadFromFolder
	bne.w LAB_0021ffc8
	movea.l DAT_Task,A2
	move.l ($00b8,A2),D6
	move.l #-$00000001,($00b8,A2)
	move.l #LAB_00220ce8,D1
	moveq #-$00000002,D2
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$0054,A6)
	movea.l (SP)+,A6
	move.l D6,($00b8,A2)
	tst.l D0
	beq.b LAB_0021ff8e
	move.l D0,D1
	move.l A6,-(SP)
	movea.l DAT_DOSLibrary,A6
	jsr (-$005a,A6)
	movea.l (SP)+,A6
	bra.w LAB_0021ffc8
LAB_0021ff8e:
	movea.l DAT_Window,A0
	lea DAT_00220e9c,A1
	lea DAT_00220e74,A2
	lea DAT_00220e88,A3
	move.w #$1101,D0
	move.w D0,D1
	move.l #$00000140,D2
	moveq #$00000050,D3
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$015c,A6)
	movea.l (SP)+,A6
	tst.w D0
	bne.b LAB_0021ffc8
	moveq #$00000000,D7
LAB_0021ffc8:
	tst.w D7
	movem.l (SP)+,D0/D1/D2/D3/D6/D7/A0/A1/A2/A3
	rts
FUN_0021ffd0:
	movem.l A3/A2/A1/A0/D7/D3/D2/D1/D0,-(SP)
	movea.l DAT_Window,A0
	lea DAT_00220ed8,A1
	lea DAT_00220e74,A2
	lea DAT_00220e88,A3
	move.w #$1101,D0
	move.w D0,D1
	move.l #$00000140,D2
	moveq #$00000050,D3
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$015c,A6)
	movea.l (SP)+,A6
	tst.w D0
	movem.l (SP)+,D0/D1/D2/D3/D7/A0/A1/A2/A3
	rts
FUN_00220010:
	movem.l A1/A0/D1/D0,-(SP)
	move.w DAT_0022104a,D0
	cmp.w #$0027,D0
	bmi.w LAB_002200ac
	movea.l D0,A0
	movea.l ($0030,A0),A0
	lea DAT_00220f00,A1
	move.l A6,-(SP)
	movea.l DAT_GraphicsLibrary,A6
	jsr (-$02c4,A6)
	movea.l (SP)+,A6
	tst.l D0
	bne.w LAB_002200ac
	move.l PTR_00220f04,DAT_0022108a
	move.l #$00000001,PTR_00220f04
	move.l #-$7fffffcf,DAT_00220f00
	movea.l DAT_Screen,A0
	movea.l ($0030,A0),A0
	lea DAT_00220f00,A1
	move.l A6,-(SP)
	movea.l DAT_GraphicsLibrary,A6
	jsr (-$02c4,A6)
	movea.l (SP)+,A6
	tst.l D0
	bne.w LAB_002200ac
	movea.l DAT_Screen,A0
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$017a,A6)
	movea.l (SP)+,A6
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$0186,A6)
	movea.l (SP)+,A6
	st DAT_00221035
LAB_002200ac:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_002200b2:
	movem.l A1/A0/D1/D0,-(SP)
	tst.b DAT_00221035
	beq.w LAB_0022011c
	lea DAT_00220f00,A1
	move.l DAT_0022108a,PTR_00220f04
	move.l #-$7fffffcf,(A1)
	movea.l DAT_Screen,A0
	movea.l ($0030,A0),A0
	move.l A6,-(SP)
	movea.l DAT_GraphicsLibrary,A6
	jsr (-$02c4,A6) ; graphics.VideoControl
	movea.l (SP)+,A6
	tst.l D0
	bne.w LAB_0022011c
	movea.l DAT_Screen,A0
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$017a,A6)
	movea.l (SP)+,A6
	move.l A6,-(SP)
	movea.l DAT_IntuitionLibrary,A6
	jsr (-$0186,A6)
	movea.l (SP)+,A6
	sf DAT_00221035
LAB_0022011c:
	movem.l (SP)+,D0/D1/A0/A1
	rts
FUN_RetrieveVBRAddressAsSupervisor:
	movem.l A5/A1/A0/D1/D0,-(SP)
	movea.l $4,A0
	btst.b #$00000001,($0129,A0)
	sne DAT_0022102f
	lea FUN_RetrieveVBRAddress,A5
	move.l A6,-(SP)
	movea.l $4,A6
	jsr (-$001e,A6)
	movea.l (SP)+,A6
	movem.l (SP)+,D0/D1/A0/A1/A5
	rts
FUN_RetrieveVBRAddress:
	tst.b DAT_0022102f
	bne.b LAB_0022015e
	suba.l A0,A0
	bra.b LAB_00220162
LAB_0022015e:
	movec VBR,A0
LAB_00220162:
	move.l A0,DAT_VBRAddress
	rte
	dc.b $00
	dc.b $00
;   }

; #######################
; # HUNK02 - DATA       #
; #######################
	section	hunk02,DATA
;   {
s_PressAnyKeyToContinue:
	dc.b $a,$a,"Press any key to continue...",0
s_AnErrorHasOccured:
	dc.b "An error has occurred :",$a,$a,0
s_PleasePressReturn:
	dc.b $a,$a,"Please press RETURN.",$a,0
; Unknown data at address 002201bd.
	dc.b $00
DAT_002201be:
; Unknown data at address 002201be.
	dc.b $00
; Unknown data at address 002201bf.
	dc.b $67
; Unknown data at address 002201c0.
	dc.b $00
; Unknown data at address 002201c1.
	dc.b $02
	dc.b "There is not enough free memory.",$a,"Current file : ",0,0
; Unknown data at address 002201f4.
	dc.b $00
; Unknown data at address 002201f5.
	dc.b $cc
; Unknown data at address 002201f6.
	dc.b $00
; Unknown data at address 002201f7.
	dc.b $03
	dc.b "Directory not found.",$a,"Current file : ",0
; Unknown data at address 0022021d.
	dc.b $00
; Unknown data at address 0022021e.
	dc.b $00
; Unknown data at address 0022021f.
	dc.b $cd
; Unknown data at address 00220220.
	dc.b $00
; Unknown data at address 00220221.
	dc.b $03
	dc.b "File not found.",$a,"Current file : ",0
; Unknown data at address 00220242.
	dc.b $ff
; Unknown data at address 00220243.
	dc.b $ff
DAT_00220244:
; Unknown data at address 00220244.
	dc.b $fc
; Unknown data at address 00220245.
	dc.b $18
; Unknown data at address 00220246.
	dc.b $00
; Unknown data at address 00220247.
	dc.b $01
	dc.b "The OS reported an error during the game.",0
; Unknown data at address 00220272.
	dc.b $fc
; Unknown data at address 00220273.
	dc.b $15
; Unknown data at address 00220274.
	dc.b $00
; Unknown data at address 00220275.
	dc.b $01
	dc.b "68000 address error exception.",0
; Unknown data at address 00220295.
	dc.b $00
; Unknown data at address 00220296.
	dc.b $fc
; Unknown data at address 00220297.
	dc.b $14
; Unknown data at address 00220298.
	dc.b $00
; Unknown data at address 00220299.
	dc.b $01
	dc.b "68000 illegal exception.",0,0
; Unknown data at address 002202b4.
	dc.b $fc
; Unknown data at address 002202b5.
	dc.b $13
; Unknown data at address 002202b6.
	dc.b $00
; Unknown data at address 002202b7.
	dc.b $01
	dc.b "68000 divide by zero exception.",0
; Unknown data at address 002202d8.
	dc.b $f8
; Unknown data at address 002202d9.
	dc.b $2f
; Unknown data at address 002202da.
	dc.b $00
; Unknown data at address 002202db.
	dc.b $02
	dc.b "There is not enough CHIP memory available.",0,0
; Unknown data at address 00220308.
	dc.b $f8
; Unknown data at address 00220309.
	dc.b $2e
; Unknown data at address 0022030a.
	dc.b $00
; Unknown data at address 0022030b.
	dc.b $02
	dc.b "There is not enough memory available.",0
; Unknown data at address 00220332.
	dc.b $f8
; Unknown data at address 00220333.
	dc.b $2d
; Unknown data at address 00220334.
	dc.b $00
; Unknown data at address 00220335.
	dc.b $01
	dc.b "There are not enough memory blocks available.",0
; Unknown data at address 00220364.
	dc.b $f8
; Unknown data at address 00220365.
	dc.b $2c
; Unknown data at address 00220366.
	dc.b $00
; Unknown data at address 00220367.
	dc.b $01
	dc.b "There are not enough memory handles available.",0,0
; Unknown data at address 00220398.
	dc.b $f8
; Unknown data at address 00220399.
	dc.b $2a
; Unknown data at address 0022039a.
	dc.b $00
; Unknown data at address 0022039b.
	dc.b $01
	dc.b "A memory area is corrupted.",0
; Unknown data at address 002203b8.
	dc.b $f8
; Unknown data at address 002203b9.
	dc.b $2c
; Unknown data at address 002203ba.
	dc.b $00
; Unknown data at address 002203bb.
	dc.b $01
	dc.b "There are not enough fake memory handles available.",0
; Unknown data at address 002203f0.
	dc.b $f4
; Unknown data at address 002203f1.
	dc.b $47
; Unknown data at address 002203f2.
	dc.b $00
; Unknown data at address 002203f3.
	dc.b $01
	dc.b "A text is too long after merging.",0
; Unknown data at address 00220416.
	dc.b $f4
; Unknown data at address 00220417.
	dc.b $46
; Unknown data at address 00220418.
	dc.b $00
; Unknown data at address 00220419.
	dc.b $01
	dc.b "A text is too long after processing.",0,0
; Unknown data at address 00220440.
	dc.b $f0
; Unknown data at address 00220441.
	dc.b $5e
; Unknown data at address 00220442.
	dc.b $00
; Unknown data at address 00220443.
	dc.b $00
	dc.b "There's an endless loop in the event chain.",0
; Unknown data at address 00220470.
	dc.b $ff
; Unknown data at address 00220471.
	dc.b $ff
DAT_00220472:
; Unknown data at address 00220472.
	dc.b $0c
	dc.b "If you want to start Ambermoon from the CLI, you must",$a,"make sure the Ambermoon-directory is the current directory.",0
; Unknown data at address 002204e5.
	dc.b $00
DAT_002204e6:
; Unknown data at address 002204e6.
	dc.b $0c
	dc.b "Please create a saved-game disk using the Ambermoon-",$a,"installation program. The installation program will be",$a,"loaded automatically once you have read this text.",$a,"Please choose option 2 and follow the instructions on",$a,"the screen.",0
; Unknown data at address 002205c8.
	dc.b $00
DAT_002205c9:
; Unknown data at address 002205c9.
	dc.b $0c
	dc.b "Please create a saved-game disk using the Ambermoon-",$a,"installation program.",0
; Unknown data at address 00220615.
	dc.b $00
s_InternalError:
	dc.b $a,$a,"This is an internal error. Our most sincere apologies.",$a,$a,"You can try to play on simply by rebooting your computer",$a,"and restarting the game. The error may not appear every",$a,"time.",0
; Unknown data at address 002206c7.
	dc.b $00
s_NotEnoughMemory:
	dc.b $a,$a,"You need about 400.000 bytes of CHIP memory and",$a,"440.000 bytes of FAST memory, or 820.000 bytes of",$a,"CHIP memory if your computer has no FAST memory.",$a,$a,"Please refer to the trouble-shooting document on disk A",$a,"to find out how to remedy this. This document can be",$a,"viewed easily from the installation program, which can",$a,"also be found on disk A.",$a,$a,"If you think you have enough memory, try rebooting if you",$a,"haven't already. Memory may be too fragmented.",0
; Unknown data at address 00220885.
	dc.b $00
s_FileError:
	dc.b $a,$a,"If you are playing from hard-disk, the best way to remedy afile error is to re-install the game.",$a,"To avoid having to start all over again, copy the >Save.XX<-",$a,"directories and the >Saves<-file to a safe place, and copy",$a,"them back after installation. These directories can be found",$a,"in the >Amberfiles<-directory.",$a,"If you have already re-installed, a file from the current saved",$a,"game may be damaged or missing. In this case,",$a,"select BEGIN QUEST in the main menu. When the character",$a,"editor comes on the screen, just press on the Exit-button.",$a,"You can now load one of your other saved positions and",$a,"replay from there.",$a,$a,"If you are playing from disk, something is wrong with",$a,"your disks. If you made a backup, try to restore these.",$a,"UNKNOWN ERROR.",0
	dc.b $00
BYTE_00220b67:
	dc.b $0c
	dc.b "If an internal error has occurred, or if a different kind",$a,"of error occurred even though you have tried to remedy it,",$a,"please get in touch with us.",0
	dc.b "",0
s_Yes:
	dc.b "Yes",0
s_No:
	dc.b "No",0
s_HaveYouMadeA:
	dc.b "Have you made a",0
s_SaveDiskYet:
	dc.b "Save-game disk yet?",0
s__00220c26:
	dc.b "",0
s_Would_you_like_to_see_00220c27:
	dc.b "Would you like to see",0
s_EndingAgain:
	dc.b "the ending again?",0,0
PTR_s_EmptyString_00220c50:
	dc.l s_EmptyString
	dc.l s_InternalError
	dc.l s_NotEnoughMemory
	dc.l s_FileError
s_EmptyString:
	dc.b $00
s_DosLibrary:
	dc.b "dos.library",0
s_GraphicsLibrary:
	dc.b "graphics.library",0
s_IntuitionLibrary:
	dc.b "intuition.library",0
LAB_00220c90:
	dc.b "CON:0/20/640/200/ Ambermoon output",0
s_ConsoleDevice:
	dc.b "console.device",0
	dc.b "Workbench",0
	dc.b "NIL:",0
DAT_00220cd1:
	; undefined1
	dc.b $42
DAT_00220cd2:
	; undefined1
	dc.b $4f
; Unknown data at address 00220cd3.
	dc.b $4f
; Unknown data at address 00220cd4.
	dc.b $54
; Unknown data at address 00220cd5.
	dc.b $00
s_RUNNING:
	dc.b "RUNNING",0
LAB_00220cde:
	dc.b "Ambermoon",0
LAB_00220ce8:
	dc.b "AMBER_J:",0
s_AMBER:
	dc.b "AMBER_ :",0,0,0
	; db[30]
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
s_Amberfiles:
	dc.b "Amberfiles/",0,0,0
	; db[30]
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $01
	dc.b "Amber2Install",0
BYTE_00220d55:
	dc.b $01
	dc.b "Keymap",0
DAT_AM2BLIT:
	dc.b $01
	dc.b "AM2_BLIT",0
DAT_AM2CPU:
	dc.b $01
	dc.b "AM2_CPU",0
LAB_00220d70:
	dc.b "Folder_info",0
BYTE_00220d7c:
	dc.b $02
	dc.b "Fantasy_intro",0
BYTE_00220d8b:
	dc.b $02
	dc.b "Ambermoon_intro",0
BYTE_00220d9c:
	dc.b $02
	dc.b "Intro_music",0
BYTE_00220da9:
	dc.b $09
	dc.b "Ambermoon_extro",0
BYTE_00220dba:
	dc.b $09
	dc.b "Extro_music",0
BYTE_00220dc7:
	dc.b $0a
	dc.b "Saves",0
DAT_ViewPortColors:
	; dw[2]
	dc.w $0000
	dc.w $0777
DAT_ScreenInfo:
	; struct NewScreen
	dc.w 0 ; NewScreen.LeftEdge
	dc.w 0 ; NewScreen.TopEdge
	dc.w 320 ; NewScreen.Width
	dc.w 200 ; NewScreen.Height
	dc.w 1 ; NewScreen.Depth
	dc.b $00 ; NewScreen.DetailPen
	dc.b $01 ; NewScreen.BlockPen
	dc.w $0000 ; NewScreen.ViewModes
	dc.w $000f ; NewScreen.Type
	dc.l $00000000 ; null pointer address ; NewScreen.Font
	dc.l $00000000 ; null pointer address ; NewScreen.DefaultTitle
	dc.l $00000000 ; null pointer address ; NewScreen.Gadgets
	dc.l $00000000 ; null pointer address ; NewScreen.CustomBitMap
DAT_WindowInfo:
	; struct NewWindow
	dc.w 0 ; NewWindow.LeftEdge
	dc.w 0 ; NewWindow.TopEdge
	dc.w 320 ; NewWindow.Width
	dc.w 200 ; NewWindow.Height
	dc.b $ff ; NewWindow.DetailPen
	dc.b $ff ; NewWindow.BlockPen
	dc.l $00000000 ; NewWindow.IDCMPFlags
	dc.l $00011900 ; NewWindow.Flags
	dc.l $00000000 ; null pointer address ; NewWindow.FirstGadget
	dc.l $00000000 ; null pointer address ; NewWindow.CheckMark
	dc.l $00000000 ; null pointer address ; NewWindow.Title
	dc.l $00000000 ; null pointer address ; NewWindow.Screen
	dc.l $00000000 ; null pointer address ; NewWindow.BitMap
	dc.w 32 ; NewWindow.MinWidth
	dc.w 32 ; NewWindow.MinHeight
	dc.w $ffff ; NewWindow.MaxWidth
	dc.w $ffff ; NewWindow.MaxHeight
	dc.w $000f ; NewWindow.Type
DAT_00220e22:
; Unknown data at address 00220e22.
	dc.b $00
; Unknown data at address 00220e23.
	dc.b $00
; Unknown data at address 00220e24.
	dc.b $00
; Unknown data at address 00220e25.
	dc.b $00
; Unknown data at address 00220e26.
	dc.b $00
; Unknown data at address 00220e27.
	dc.b $00
; Unknown data at address 00220e28.
	dc.b $00
; Unknown data at address 00220e29.
	dc.b $00
; Unknown data at address 00220e2a.
	dc.b $04
; Unknown data at address 00220e2b.
	dc.b $00
; Unknown data at address 00220e2c.
	dc.b $00
; Unknown data at address 00220e2d.
	dc.b $00
; Unknown data at address 00220e2e.
	dc.b $00
; Unknown data at address 00220e2f.
	dc.b $00
; Unknown data at address 00220e30.
	dc.b $00
DAT_00220e31:
	; undefined1
	dc.b $00
DAT_00220e32:
	; undefined4
	dc.l $00000000
PTR_DAT_00220e36:
	dc.l DAT_00220e3a
DAT_00220e3a:
; Unknown data at address 00220e3a.
	dc.b $00
; Unknown data at address 00220e3b.
	dc.b $00
; Unknown data at address 00220e3c.
	dc.b $00
; Unknown data at address 00220e3d.
	dc.b $00
	dc.l PTR_DAT_00220e36
; Unknown data at address 00220e42.
	dc.b $00
; Unknown data at address 00220e43.
	dc.b $00
DAT_00220e44:
; Unknown data at address 00220e44.
	dc.b $00
; Unknown data at address 00220e45.
	dc.b $00
; Unknown data at address 00220e46.
	dc.b $00
; Unknown data at address 00220e47.
	dc.b $00
; Unknown data at address 00220e48.
	dc.b $00
; Unknown data at address 00220e49.
	dc.b $00
; Unknown data at address 00220e4a.
	dc.b $00
; Unknown data at address 00220e4b.
	dc.b $00
; Unknown data at address 00220e4c.
	dc.b $07
; Unknown data at address 00220e4d.
	dc.b $00
; Unknown data at address 00220e4e.
	dc.b $00
; Unknown data at address 00220e4f.
	dc.b $00
; Unknown data at address 00220e50.
	dc.b $00
; Unknown data at address 00220e51.
	dc.b $00
	dc.l DAT_00220e22
; Unknown data at address 00220e56.
	dc.b $00
; Unknown data at address 00220e57.
	dc.b $30
; Unknown data at address 00220e58.
	dc.b $00
; Unknown data at address 00220e59.
	dc.b $00
; Unknown data at address 00220e5a.
	dc.b $00
; Unknown data at address 00220e5b.
	dc.b $00
; Unknown data at address 00220e5c.
	dc.b $00
; Unknown data at address 00220e5d.
	dc.b $00
; Unknown data at address 00220e5e.
	dc.b $00
; Unknown data at address 00220e5f.
	dc.b $00
DAT_00220e60:
	; undefined2
	dc.w $0000
; Unknown data at address 00220e62.
	dc.b $00
; Unknown data at address 00220e63.
	dc.b $00
; Unknown data at address 00220e64.
	dc.b $00
; Unknown data at address 00220e65.
	dc.b $00
; Unknown data at address 00220e66.
	dc.b $00
; Unknown data at address 00220e67.
	dc.b $00
DAT_00220e68:
	; undefined4
	dc.l $00000000
DAT_00220e6c:
	; undefined4
	dc.l $00000000
; Unknown data at address 00220e70.
	dc.b $00
; Unknown data at address 00220e71.
	dc.b $00
; Unknown data at address 00220e72.
	dc.b $00
; Unknown data at address 00220e73.
	dc.b $00
DAT_00220e74:
; Unknown data at address 00220e74.
	dc.b $00
; Unknown data at address 00220e75.
	dc.b $01
; Unknown data at address 00220e76.
	dc.b $00
; Unknown data at address 00220e77.
	dc.b $00
; Unknown data at address 00220e78.
	dc.b $00
; Unknown data at address 00220e79.
	dc.b $05
; Unknown data at address 00220e7a.
	dc.b $00
; Unknown data at address 00220e7b.
	dc.b $04
; Unknown data at address 00220e7c.
	dc.b $00
; Unknown data at address 00220e7d.
	dc.b $00
; Unknown data at address 00220e7e.
	dc.b $00
; Unknown data at address 00220e7f.
	dc.b $00
	dc.l s_Yes
	dc.l $00000000 ; null pointer address
DAT_00220e88:
; Unknown data at address 00220e88.
	dc.b $00
; Unknown data at address 00220e89.
	dc.b $01
; Unknown data at address 00220e8a.
	dc.b $00
; Unknown data at address 00220e8b.
	dc.b $00
; Unknown data at address 00220e8c.
	dc.b $00
; Unknown data at address 00220e8d.
	dc.b $05
; Unknown data at address 00220e8e.
	dc.b $00
; Unknown data at address 00220e8f.
	dc.b $04
; Unknown data at address 00220e90.
	dc.b $00
; Unknown data at address 00220e91.
	dc.b $00
; Unknown data at address 00220e92.
	dc.b $00
; Unknown data at address 00220e93.
	dc.b $00
	dc.l s_No
	dc.l $00000000 ; null pointer address
DAT_00220e9c:
; Unknown data at address 00220e9c.
	dc.b $00
; Unknown data at address 00220e9d.
	dc.b $01
; Unknown data at address 00220e9e.
	dc.b $00
; Unknown data at address 00220e9f.
	dc.b $00
; Unknown data at address 00220ea0.
	dc.b $00
; Unknown data at address 00220ea1.
	dc.b $05
; Unknown data at address 00220ea2.
	dc.b $00
; Unknown data at address 00220ea3.
	dc.b $04
; Unknown data at address 00220ea4.
	dc.b $00
; Unknown data at address 00220ea5.
	dc.b $00
; Unknown data at address 00220ea6.
	dc.b $00
; Unknown data at address 00220ea7.
	dc.b $00
	dc.l s_HaveYouMadeA
	dc.l DAT_00220eb0
DAT_00220eb0:
; Unknown data at address 00220eb0.
	dc.b $00
; Unknown data at address 00220eb1.
	dc.b $01
; Unknown data at address 00220eb2.
	dc.b $00
; Unknown data at address 00220eb3.
	dc.b $00
; Unknown data at address 00220eb4.
	dc.b $00
; Unknown data at address 00220eb5.
	dc.b $05
; Unknown data at address 00220eb6.
	dc.b $00
; Unknown data at address 00220eb7.
	dc.b $0e
; Unknown data at address 00220eb8.
	dc.b $00
; Unknown data at address 00220eb9.
	dc.b $00
; Unknown data at address 00220eba.
	dc.b $00
; Unknown data at address 00220ebb.
	dc.b $00
	dc.l s_SaveDiskYet
	dc.l DAT_00220ec4
DAT_00220ec4:
; Unknown data at address 00220ec4.
	dc.b $00
; Unknown data at address 00220ec5.
	dc.b $01
; Unknown data at address 00220ec6.
	dc.b $00
; Unknown data at address 00220ec7.
	dc.b $00
; Unknown data at address 00220ec8.
	dc.b $00
; Unknown data at address 00220ec9.
	dc.b $05
; Unknown data at address 00220eca.
	dc.b $00
; Unknown data at address 00220ecb.
	dc.b $18
; Unknown data at address 00220ecc.
	dc.b $00
; Unknown data at address 00220ecd.
	dc.b $00
; Unknown data at address 00220ece.
	dc.b $00
; Unknown data at address 00220ecf.
	dc.b $00
	dc.l s__00220c26
	dc.l $00000000 ; null pointer address
DAT_00220ed8:
; Unknown data at address 00220ed8.
	dc.b $00
; Unknown data at address 00220ed9.
	dc.b $01
; Unknown data at address 00220eda.
	dc.b $00
; Unknown data at address 00220edb.
	dc.b $00
; Unknown data at address 00220edc.
	dc.b $00
; Unknown data at address 00220edd.
	dc.b $05
; Unknown data at address 00220ede.
	dc.b $00
; Unknown data at address 00220edf.
	dc.b $04
; Unknown data at address 00220ee0.
	dc.b $00
; Unknown data at address 00220ee1.
	dc.b $00
; Unknown data at address 00220ee2.
	dc.b $00
; Unknown data at address 00220ee3.
	dc.b $00
	dc.l s_Would_you_like_to_see_00220c27
	dc.l DAT_00220eec
DAT_00220eec:
; Unknown data at address 00220eec.
	dc.b $00
; Unknown data at address 00220eed.
	dc.b $01
; Unknown data at address 00220eee.
	dc.b $00
; Unknown data at address 00220eef.
	dc.b $00
; Unknown data at address 00220ef0.
	dc.b $00
; Unknown data at address 00220ef1.
	dc.b $05
; Unknown data at address 00220ef2.
	dc.b $00
; Unknown data at address 00220ef3.
	dc.b $0e
; Unknown data at address 00220ef4.
	dc.b $00
; Unknown data at address 00220ef5.
	dc.b $00
; Unknown data at address 00220ef6.
	dc.b $00
; Unknown data at address 00220ef7.
	dc.b $00
	dc.l s_EndingAgain
	dc.l $00000000 ; null pointer address
DAT_00220f00:
	; undefined4
	dc.l $80000032
PTR_00220f04:
	dc.l $00000000 ; null pointer address
	dc.l $00000000 ; null pointer address
	dc.l $00000000 ; null pointer address
;   }

; #######################
; # HUNK03 - BSS        #
; #######################
	section	hunk03,BSS
;   {
DAT_00220f10:
	; undefined4
	dx.l 1
LAB_00220f14:
; Unknown data at address 00220f14.
	dx.b 1
; Unknown data at address 00220f15.
	dx.b 1
; Unknown data at address 00220f16.
	dx.b 1
; Unknown data at address 00220f17.
	dx.b 1
; Unknown data at address 00220f18.
	dx.b 1
; Unknown data at address 00220f19.
	dx.b 1
; Unknown data at address 00220f1a.
	dx.b 1
; Unknown data at address 00220f1b.
	dx.b 1
DAT_00220f1c:
	; undefined4
	dx.l 1
; Unknown data at address 00220f20.
	dx.b 1
; Unknown data at address 00220f21.
	dx.b 1
; Unknown data at address 00220f22.
	dx.b 1
; Unknown data at address 00220f23.
	dx.b 1
; Unknown data at address 00220f24.
	dx.b 1
; Unknown data at address 00220f25.
	dx.b 1
; Unknown data at address 00220f26.
	dx.b 1
; Unknown data at address 00220f27.
	dx.b 1
; Unknown data at address 00220f28.
	dx.b 1
; Unknown data at address 00220f29.
	dx.b 1
; Unknown data at address 00220f2a.
	dx.b 1
; Unknown data at address 00220f2b.
	dx.b 1
; Unknown data at address 00220f2c.
	dx.b 1
; Unknown data at address 00220f2d.
	dx.b 1
; Unknown data at address 00220f2e.
	dx.b 1
; Unknown data at address 00220f2f.
	dx.b 1
; Unknown data at address 00220f30.
	dx.b 1
; Unknown data at address 00220f31.
	dx.b 1
; Unknown data at address 00220f32.
	dx.b 1
; Unknown data at address 00220f33.
	dx.b 1
; Unknown data at address 00220f34.
	dx.b 1
; Unknown data at address 00220f35.
	dx.b 1
; Unknown data at address 00220f36.
	dx.b 1
; Unknown data at address 00220f37.
	dx.b 1
; Unknown data at address 00220f38.
	dx.b 1
; Unknown data at address 00220f39.
	dx.b 1
; Unknown data at address 00220f3a.
	dx.b 1
; Unknown data at address 00220f3b.
	dx.b 1
; Unknown data at address 00220f3c.
	dx.b 1
; Unknown data at address 00220f3d.
	dx.b 1
; Unknown data at address 00220f3e.
	dx.b 1
; Unknown data at address 00220f3f.
	dx.b 1
; Unknown data at address 00220f40.
	dx.b 1
; Unknown data at address 00220f41.
	dx.b 1
; Unknown data at address 00220f42.
	dx.b 1
; Unknown data at address 00220f43.
	dx.b 1
; Unknown data at address 00220f44.
	dx.b 1
; Unknown data at address 00220f45.
	dx.b 1
; Unknown data at address 00220f46.
	dx.b 1
; Unknown data at address 00220f47.
	dx.b 1
; Unknown data at address 00220f48.
	dx.b 1
; Unknown data at address 00220f49.
	dx.b 1
; Unknown data at address 00220f4a.
	dx.b 1
; Unknown data at address 00220f4b.
	dx.b 1
; Unknown data at address 00220f4c.
	dx.b 1
; Unknown data at address 00220f4d.
	dx.b 1
; Unknown data at address 00220f4e.
	dx.b 1
; Unknown data at address 00220f4f.
	dx.b 1
; Unknown data at address 00220f50.
	dx.b 1
; Unknown data at address 00220f51.
	dx.b 1
; Unknown data at address 00220f52.
	dx.b 1
; Unknown data at address 00220f53.
	dx.b 1
; Unknown data at address 00220f54.
	dx.b 1
; Unknown data at address 00220f55.
	dx.b 1
; Unknown data at address 00220f56.
	dx.b 1
; Unknown data at address 00220f57.
	dx.b 1
; Unknown data at address 00220f58.
	dx.b 1
; Unknown data at address 00220f59.
	dx.b 1
; Unknown data at address 00220f5a.
	dx.b 1
; Unknown data at address 00220f5b.
	dx.b 1
; Unknown data at address 00220f5c.
	dx.b 1
; Unknown data at address 00220f5d.
	dx.b 1
; Unknown data at address 00220f5e.
	dx.b 1
; Unknown data at address 00220f5f.
	dx.b 1
; Unknown data at address 00220f60.
	dx.b 1
; Unknown data at address 00220f61.
	dx.b 1
; Unknown data at address 00220f62.
	dx.b 1
; Unknown data at address 00220f63.
	dx.b 1
; Unknown data at address 00220f64.
	dx.b 1
; Unknown data at address 00220f65.
	dx.b 1
; Unknown data at address 00220f66.
	dx.b 1
; Unknown data at address 00220f67.
	dx.b 1
; Unknown data at address 00220f68.
	dx.b 1
; Unknown data at address 00220f69.
	dx.b 1
; Unknown data at address 00220f6a.
	dx.b 1
; Unknown data at address 00220f6b.
	dx.b 1
; Unknown data at address 00220f6c.
	dx.b 1
; Unknown data at address 00220f6d.
	dx.b 1
; Unknown data at address 00220f6e.
	dx.b 1
; Unknown data at address 00220f6f.
	dx.b 1
; Unknown data at address 00220f70.
	dx.b 1
; Unknown data at address 00220f71.
	dx.b 1
; Unknown data at address 00220f72.
	dx.b 1
; Unknown data at address 00220f73.
	dx.b 1
; Unknown data at address 00220f74.
	dx.b 1
; Unknown data at address 00220f75.
	dx.b 1
; Unknown data at address 00220f76.
	dx.b 1
; Unknown data at address 00220f77.
	dx.b 1
; Unknown data at address 00220f78.
	dx.b 1
; Unknown data at address 00220f79.
	dx.b 1
; Unknown data at address 00220f7a.
	dx.b 1
; Unknown data at address 00220f7b.
	dx.b 1
; Unknown data at address 00220f7c.
	dx.b 1
; Unknown data at address 00220f7d.
	dx.b 1
; Unknown data at address 00220f7e.
	dx.b 1
; Unknown data at address 00220f7f.
	dx.b 1
; Unknown data at address 00220f80.
	dx.b 1
; Unknown data at address 00220f81.
	dx.b 1
; Unknown data at address 00220f82.
	dx.b 1
; Unknown data at address 00220f83.
	dx.b 1
; Unknown data at address 00220f84.
	dx.b 1
; Unknown data at address 00220f85.
	dx.b 1
; Unknown data at address 00220f86.
	dx.b 1
; Unknown data at address 00220f87.
	dx.b 1
; Unknown data at address 00220f88.
	dx.b 1
; Unknown data at address 00220f89.
	dx.b 1
; Unknown data at address 00220f8a.
	dx.b 1
; Unknown data at address 00220f8b.
	dx.b 1
; Unknown data at address 00220f8c.
	dx.b 1
; Unknown data at address 00220f8d.
	dx.b 1
; Unknown data at address 00220f8e.
	dx.b 1
; Unknown data at address 00220f8f.
	dx.b 1
; Unknown data at address 00220f90.
	dx.b 1
; Unknown data at address 00220f91.
	dx.b 1
; Unknown data at address 00220f92.
	dx.b 1
; Unknown data at address 00220f93.
	dx.b 1
; Unknown data at address 00220f94.
	dx.b 1
; Unknown data at address 00220f95.
	dx.b 1
; Unknown data at address 00220f96.
	dx.b 1
; Unknown data at address 00220f97.
	dx.b 1
; Unknown data at address 00220f98.
	dx.b 1
; Unknown data at address 00220f99.
	dx.b 1
; Unknown data at address 00220f9a.
	dx.b 1
; Unknown data at address 00220f9b.
	dx.b 1
; Unknown data at address 00220f9c.
	dx.b 1
; Unknown data at address 00220f9d.
	dx.b 1
; Unknown data at address 00220f9e.
	dx.b 1
; Unknown data at address 00220f9f.
	dx.b 1
; Unknown data at address 00220fa0.
	dx.b 1
; Unknown data at address 00220fa1.
	dx.b 1
; Unknown data at address 00220fa2.
	dx.b 1
; Unknown data at address 00220fa3.
	dx.b 1
; Unknown data at address 00220fa4.
	dx.b 1
; Unknown data at address 00220fa5.
	dx.b 1
; Unknown data at address 00220fa6.
	dx.b 1
; Unknown data at address 00220fa7.
	dx.b 1
; Unknown data at address 00220fa8.
	dx.b 1
; Unknown data at address 00220fa9.
	dx.b 1
; Unknown data at address 00220faa.
	dx.b 1
; Unknown data at address 00220fab.
	dx.b 1
; Unknown data at address 00220fac.
	dx.b 1
; Unknown data at address 00220fad.
	dx.b 1
; Unknown data at address 00220fae.
	dx.b 1
; Unknown data at address 00220faf.
	dx.b 1
; Unknown data at address 00220fb0.
	dx.b 1
; Unknown data at address 00220fb1.
	dx.b 1
; Unknown data at address 00220fb2.
	dx.b 1
; Unknown data at address 00220fb3.
	dx.b 1
; Unknown data at address 00220fb4.
	dx.b 1
; Unknown data at address 00220fb5.
	dx.b 1
; Unknown data at address 00220fb6.
	dx.b 1
; Unknown data at address 00220fb7.
	dx.b 1
; Unknown data at address 00220fb8.
	dx.b 1
; Unknown data at address 00220fb9.
	dx.b 1
; Unknown data at address 00220fba.
	dx.b 1
; Unknown data at address 00220fbb.
	dx.b 1
; Unknown data at address 00220fbc.
	dx.b 1
; Unknown data at address 00220fbd.
	dx.b 1
; Unknown data at address 00220fbe.
	dx.b 1
; Unknown data at address 00220fbf.
	dx.b 1
; Unknown data at address 00220fc0.
	dx.b 1
; Unknown data at address 00220fc1.
	dx.b 1
; Unknown data at address 00220fc2.
	dx.b 1
; Unknown data at address 00220fc3.
	dx.b 1
; Unknown data at address 00220fc4.
	dx.b 1
; Unknown data at address 00220fc5.
	dx.b 1
; Unknown data at address 00220fc6.
	dx.b 1
; Unknown data at address 00220fc7.
	dx.b 1
; Unknown data at address 00220fc8.
	dx.b 1
; Unknown data at address 00220fc9.
	dx.b 1
; Unknown data at address 00220fca.
	dx.b 1
; Unknown data at address 00220fcb.
	dx.b 1
; Unknown data at address 00220fcc.
	dx.b 1
; Unknown data at address 00220fcd.
	dx.b 1
; Unknown data at address 00220fce.
	dx.b 1
; Unknown data at address 00220fcf.
	dx.b 1
; Unknown data at address 00220fd0.
	dx.b 1
; Unknown data at address 00220fd1.
	dx.b 1
; Unknown data at address 00220fd2.
	dx.b 1
; Unknown data at address 00220fd3.
	dx.b 1
; Unknown data at address 00220fd4.
	dx.b 1
; Unknown data at address 00220fd5.
	dx.b 1
; Unknown data at address 00220fd6.
	dx.b 1
; Unknown data at address 00220fd7.
	dx.b 1
; Unknown data at address 00220fd8.
	dx.b 1
; Unknown data at address 00220fd9.
	dx.b 1
; Unknown data at address 00220fda.
	dx.b 1
; Unknown data at address 00220fdb.
	dx.b 1
; Unknown data at address 00220fdc.
	dx.b 1
; Unknown data at address 00220fdd.
	dx.b 1
; Unknown data at address 00220fde.
	dx.b 1
; Unknown data at address 00220fdf.
	dx.b 1
; Unknown data at address 00220fe0.
	dx.b 1
; Unknown data at address 00220fe1.
	dx.b 1
; Unknown data at address 00220fe2.
	dx.b 1
; Unknown data at address 00220fe3.
	dx.b 1
; Unknown data at address 00220fe4.
	dx.b 1
; Unknown data at address 00220fe5.
	dx.b 1
; Unknown data at address 00220fe6.
	dx.b 1
; Unknown data at address 00220fe7.
	dx.b 1
; Unknown data at address 00220fe8.
	dx.b 1
; Unknown data at address 00220fe9.
	dx.b 1
; Unknown data at address 00220fea.
	dx.b 1
; Unknown data at address 00220feb.
	dx.b 1
; Unknown data at address 00220fec.
	dx.b 1
; Unknown data at address 00220fed.
	dx.b 1
; Unknown data at address 00220fee.
	dx.b 1
; Unknown data at address 00220fef.
	dx.b 1
; Unknown data at address 00220ff0.
	dx.b 1
; Unknown data at address 00220ff1.
	dx.b 1
; Unknown data at address 00220ff2.
	dx.b 1
; Unknown data at address 00220ff3.
	dx.b 1
; Unknown data at address 00220ff4.
	dx.b 1
; Unknown data at address 00220ff5.
	dx.b 1
; Unknown data at address 00220ff6.
	dx.b 1
; Unknown data at address 00220ff7.
	dx.b 1
; Unknown data at address 00220ff8.
	dx.b 1
; Unknown data at address 00220ff9.
	dx.b 1
; Unknown data at address 00220ffa.
	dx.b 1
; Unknown data at address 00220ffb.
	dx.b 1
; Unknown data at address 00220ffc.
	dx.b 1
; Unknown data at address 00220ffd.
	dx.b 1
; Unknown data at address 00220ffe.
	dx.b 1
; Unknown data at address 00220fff.
	dx.b 1
; Unknown data at address 00221000.
	dx.b 1
; Unknown data at address 00221001.
	dx.b 1
; Unknown data at address 00221002.
	dx.b 1
; Unknown data at address 00221003.
	dx.b 1
; Unknown data at address 00221004.
	dx.b 1
; Unknown data at address 00221005.
	dx.b 1
; Unknown data at address 00221006.
	dx.b 1
; Unknown data at address 00221007.
	dx.b 1
; Unknown data at address 00221008.
	dx.b 1
; Unknown data at address 00221009.
	dx.b 1
; Unknown data at address 0022100a.
	dx.b 1
; Unknown data at address 0022100b.
	dx.b 1
; Unknown data at address 0022100c.
	dx.b 1
; Unknown data at address 0022100d.
	dx.b 1
; Unknown data at address 0022100e.
	dx.b 1
; Unknown data at address 0022100f.
	dx.b 1
; Unknown data at address 00221010.
	dx.b 1
; Unknown data at address 00221011.
	dx.b 1
; Unknown data at address 00221012.
	dx.b 1
; Unknown data at address 00221013.
	dx.b 1
; Unknown data at address 00221014.
	dx.b 1
; Unknown data at address 00221015.
	dx.b 1
; Unknown data at address 00221016.
	dx.b 1
; Unknown data at address 00221017.
	dx.b 1
; Unknown data at address 00221018.
	dx.b 1
; Unknown data at address 00221019.
	dx.b 1
; Unknown data at address 0022101a.
	dx.b 1
; Unknown data at address 0022101b.
	dx.b 1
; Unknown data at address 0022101c.
	dx.b 1
; Unknown data at address 0022101d.
	dx.b 1
; Unknown data at address 0022101e.
	dx.b 1
; Unknown data at address 0022101f.
	dx.b 1
DAT_00221020:
	; undefined4
	dx.l 1
DAT_00221024:
; Unknown data at address 00221024.
	dx.b 1
; Unknown data at address 00221025.
	dx.b 1
DAT_00221026:
; Unknown data at address 00221026.
	dx.b 1
; Unknown data at address 00221027.
	dx.b 1
; Unknown data at address 00221028.
	dx.b 1
; Unknown data at address 00221029.
	dx.b 1
DAT_0022102a:
; Unknown data at address 0022102a.
	dx.b 1
; Unknown data at address 0022102b.
	dx.b 1
DAT_LoadFromFolder:
; Unknown data at address 0022102c.
	dx.b 1
DAT_0022102d:
; Unknown data at address 0022102d.
	dx.b 1
DAT_UseAM2CPU:
	; undefined1
	dx.b 1
DAT_0022102f:
; Unknown data at address 0022102f.
	dx.b 1
DAT_00221030:
; Unknown data at address 00221030.
	dx.b 1
DAT_00221031:
; Unknown data at address 00221031.
	dx.b 1
DAT_00221032:
; Unknown data at address 00221032.
	dx.b 1
DAT_00221033:
; Unknown data at address 00221033.
	dx.b 1
DAT_00221034:
; Unknown data at address 00221034.
	dx.b 1
DAT_00221035:
; Unknown data at address 00221035.
	dx.b 1
DAT_00221036:
	; undefined2
	dx.w 1
DAT_00221038:
	; undefined2
	dx.w 1
DAT_0022103a:
	; undefined4
	dx.l 1
DAT_0022103e:
	; undefined4
	dx.l 1
; Unknown data at address 00221042.
	dx.b 1
; Unknown data at address 00221043.
	dx.b 1
; Unknown data at address 00221044.
	dx.b 1
; Unknown data at address 00221045.
	dx.b 1
DAT_00221046:
	; undefined4
	dx.l 1
DAT_0022104a:
	; undefined2
	dx.w 1
DAT_0022104c:
	; undefined2
	dx.w 1
DAT_DOSLibrary:
	; undefined4
	dx.l 1
DAT_GraphicsLibrary:
	; undefined4
	dx.l 1
DAT_IntuitionLibrary:
	; undefined4
	dx.l 1
DAT_0022105a:
	; undefined4
	dx.l 1
DAT_0022105e:
	; undefined4
	dx.l 1
DAT_00221062:
	; undefined4
	dx.l 1
DAT_ExePath:
	; undefined4
	dx.l 1
DAT_LastCurrentDirLock:
	; undefined4
	dx.l 1
DAT_Task:
	; Task *
	dx.l 1
DAT_00221072:
	; undefined4
	dx.l 1
DAT_Screen:
	; Screen *
	dx.l 1
DAT_Window:
	; Window *
	dx.l 1
DAT_VBRAddress:
	dx.l 1
DAT_00221082:
	; undefined4
	dx.l 1
DAT_00221086:
	; undefined4
	dx.l 1
DAT_0022108a:
	; undefined4
	dx.l 1
; Unknown data at address 0022108e.
	dx.b 1
; Unknown data at address 0022108f.
	dx.b 1
DAT_ScrollOffset:
	dx.w 1
;   }

; #######################
; # HUNK04 - DATA       #
; #######################
	section	hunk04,DATA
;   {
DAT_LoaderVersionAndBlitterFlag:
	dc.b $00 ; Leave this at 0!
			; It will be replaced by
			; the blitter flag before
			; passing the whole long
			; to AM2_CPU.
DAT_LoaderVersionMajor:
	dc.b $01
DAT_LoaderVersionMinor:
	dc.w $0000
;   }
