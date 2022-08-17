
; #######################
; # HUNK00 - CODE       #
; #######################
	section	hunk00,CODE
;   {
start:
	jmp (FUN_003038a6,PC)
FUN_00300004:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	clr.w (-$0002,A5)
	jsr (FUN_00302f4c,PC)
	jsr (FUN_00302e1c,PC)
	jsr (FUN_00302fc6,PC)
	tst.w DAT_003050ea
	beq.b LAB_0030003c
	pea $000003ed
	pea (s_CONSOLE__00300412,PC)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,DAT_00304f80
	bra.b LAB_00300052
LAB_0030003c:
	pea $000003ed
	pea (DAT_0030041b,PC)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,DAT_00304f80
LAB_00300052:
	tst.w DAT_003050ec
	beq.w LAB_003001c2
	pea (s_C_Install_0030041d,PC)
	jsr (FUN_00302f8a,PC)
	addq.w #$00000004,SP
	tst.w D0
	bne.b LAB_003000c4
	pea (DAT_00300427,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Befehl_im__C____Verzeichnis_Ihre_00300465,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_bitte_von_der_AMBERMOON_Disk_A_u_003004a8,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_003004ed,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	pea (DAT_0030050b,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	move.l DAT_00304f80,-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	pea $00000005
	jsr FUN_003048b2
	addq.w #$00000004,SP
LAB_003000c4:
	pea (s_SYS_System_Format_0030050d,PC)
	jsr (FUN_00302f8a,PC)
	addq.w #$00000004,SP
	tst.w D0
	bne.b LAB_0030012c
	pea (DAT_0030051f,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Befehl_im__System____Verzeichnis_0030055c,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_bitte_von_der_AMBERMOON_Disk_A_u_003005a4,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_003005e9,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	pea (DAT_00300607,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	move.l DAT_00304f80,-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	pea $00000005
	jsr FUN_003048b2
	addq.w #$00000004,SP
LAB_0030012c:
	pea (s_SYS_System_More_00300609,PC)
	jsr (FUN_00302f8a,PC)
	addq.w #$00000004,SP
	tst.w D0
	beq.b LAB_00300144
	move.w #$0001,DAT_003050ee
	bra.b LAB_003001c0
LAB_00300144:
	pea (s_SYS_Utilities_More_00300619,PC)
	jsr (FUN_00302f8a,PC)
	addq.w #$00000004,SP
	tst.w D0
	beq.b LAB_0030015a
	clr.w DAT_003050ee
	bra.b LAB_003001c0
LAB_0030015a:
	pea (DAT_0030062c,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Befehl_entweder_im__System____od_00300667,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Ihrer_Festplatte__Kopieren_Sie_d_003006a8,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Disk_A_und_starten_Sie_dieses_Pr_003006e7,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300714,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	pea (DAT_00300732,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	move.l DAT_00304f80,-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	pea $00000005
	jsr FUN_003048b2
	addq.w #$00000004,SP
LAB_003001c0:
	bra.b LAB_0030022c
LAB_003001c2:
	pea (s_OS_Befehle_werden_kopiert____00300734,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_00300752,PC)
	jsr (FUN_003027e8,PC)
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Copy_0030076b,PC)
	pea (s_AMBER_A_C_Copy_0030075c,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Install_0030078c,PC)
	pea (s_AMBER_A_C_Install_0030077a,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Run_003007ac,PC)
	pea (s_AMBER_A_C_Run_0030079e,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Assign_003007cb,PC)
	pea (s_AMBER_A_C_Assign_003007ba,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Format_003007f2,PC)
	pea (s_AMBER_A_System_Format_003007dc,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_More_00300817,PC)
	pea (s_AMBER_A_System_More_00300803,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
LAB_0030022c:
	pea (DAT_00300826,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s__OPTIONEN__00300828,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300838,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s__1___AMBERMOON_auf_Ihrer_Festpla_0030083a,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_0030086d,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_003008ac,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s__2___Spielstand_Diskette__Disk_J_003008ae,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_003008dc,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300913,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300915,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300947,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300986,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_003009b7,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s__4___Das_Troubleshoot___Dokument_003009b9,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_003009e5,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s__irgendwelche_Probleme_mit_dem_P_00300a22,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300a5d,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s__5___Beenden__00300a5f,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s___Verlassen_des_Installations_Pr_00300a6e,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300a9c,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300a9e,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000001
	pea (-$0003,A5)
	jsr (FUN_003021be,PC)
	addq.w #$00000008,SP
	move.b (-$0003,A5),D0
	ext.w D0
	ext.l D0
	bra.b LAB_0030036a
caseD_31:
	jsr (FUN_00300b2a,PC)
	bra.b caseD_5
caseD_32:
	jsr (FUN_003012d6,PC)
	bra.b caseD_5
caseD_33:
	jsr (FUN_00301642,PC)
	bra.b caseD_5
caseD_34:
	jsr (FUN_00301f0c,PC)
	bra.b caseD_5
caseD_35:
	move.w #$0001,(-$0002,A5)
	bra.b caseD_5
switchdataD_00300360:
	; unsigned short
	dc.w $ffc0
	; unsigned short
	dc.w $ffc6
	; unsigned short
	dc.w $ffcc
	; unsigned short
	dc.w $ffd2
	; unsigned short
	dc.w $ffd8
LAB_0030036a:
	sub.l #$00000031,D0
	cmp.l #$00000005,D0
	bcc.b caseD_5
	asl.l #$00000001,D0
	move.w (switchdataD_00300360,PC,D0.w),D0
switchD:
	jmp (caseD_5-2,PC,D0.w)
caseD_5:
	tst.w (-$0002,A5)
	beq.w LAB_0030022c
	tst.w DAT_003050ec
	bne.b LAB_003003e6
	pea (s_RAM_AM2_C_Copy_00300abd,PC)
	jsr _DeleteFileThunk
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Install_00300acc,PC)
	jsr _DeleteFileThunk
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Run_00300ade,PC)
	jsr _DeleteFileThunk
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Install_00300aec,PC)
	jsr _DeleteFileThunk
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Format_00300afe,PC)
	jsr _DeleteFileThunk
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_More_00300b0f,PC)
	jsr _DeleteFileThunk
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_00300b1e,PC)
	jsr _DeleteFileThunk
	addq.w #$00000004,SP
LAB_003003e6:
	pea (DAT_00300b28,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	move.l DAT_00304f80,-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	clr.l -(SP)
	jsr FUN_003048b2
	addq.w #$00000004,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_CONSOLE__00300412:
	dc.b "CONSOLE:",0
DAT_0030041b:
; Unknown data at address 0030041b.
	dc.b $2a
; Unknown data at address 0030041c.
	dc.b $00
s_C_Install_0030041d:
	dc.b "C:Install",0
DAT_00300427:
; Unknown data at address 00300427.
	dc.b $44
; Unknown data at address 00300428.
	dc.b $61
; Unknown data at address 00300429.
	dc.b $73
; Unknown data at address 0030042a.
	dc.b $20
; Unknown data at address 0030042b.
	dc.b $41
; Unknown data at address 0030042c.
	dc.b $4d
; Unknown data at address 0030042d.
	dc.b $42
; Unknown data at address 0030042e.
	dc.b $45
; Unknown data at address 0030042f.
	dc.b $52
; Unknown data at address 00300430.
	dc.b $4d
; Unknown data at address 00300431.
	dc.b $4f
; Unknown data at address 00300432.
	dc.b $4f
; Unknown data at address 00300433.
	dc.b $4e
; Unknown data at address 00300434.
	dc.b $2d
; Unknown data at address 00300435.
	dc.b $49
; Unknown data at address 00300436.
	dc.b $6e
; Unknown data at address 00300437.
	dc.b $73
; Unknown data at address 00300438.
	dc.b $74
; Unknown data at address 00300439.
	dc.b $61
; Unknown data at address 0030043a.
	dc.b $6c
; Unknown data at address 0030043b.
	dc.b $6c
; Unknown data at address 0030043c.
	dc.b $61
; Unknown data at address 0030043d.
	dc.b $74
; Unknown data at address 0030043e.
	dc.b $69
; Unknown data at address 0030043f.
	dc.b $6f
; Unknown data at address 00300440.
	dc.b $6e
; Unknown data at address 00300441.
	dc.b $73
; Unknown data at address 00300442.
	dc.b $70
; Unknown data at address 00300443.
	dc.b $72
; Unknown data at address 00300444.
	dc.b $6f
; Unknown data at address 00300445.
	dc.b $67
; Unknown data at address 00300446.
	dc.b $72
; Unknown data at address 00300447.
	dc.b $61
; Unknown data at address 00300448.
	dc.b $6d
; Unknown data at address 00300449.
	dc.b $6d
; Unknown data at address 0030044a.
	dc.b $20
; Unknown data at address 0030044b.
	dc.b $62
; Unknown data at address 0030044c.
	dc.b $65
; Unknown data at address 0030044d.
	dc.b $6e
; Unknown data at address 0030044e.
	dc.b $f6
	dc.b "tigt den >Install< -",$a,0
s_Befehl_im__C____Verzeichnis_Ihre_00300465:
	dc.b "Befehl im >C< - Verzeichnis Ihrer Festplatte. Kopieren Sie diesen",$a,0
s_bitte_von_der_AMBERMOON_Disk_A_u_003004a8:
	dc.b "bitte von der AMBERMOON Disk A und starten Sie dieses Programm neu.",$a,0
DAT_003004ed:
; Unknown data at address 003004ed.
	dc.b $0a
; Unknown data at address 003004ee.
	dc.b $44
; Unknown data at address 003004ef.
	dc.b $72
; Unknown data at address 003004f0.
	dc.b $fc
	dc.b "cken Sie bitte >RETURN<.",$a,0
DAT_0030050b:
; Unknown data at address 0030050b.
	dc.b $0c
; Unknown data at address 0030050c.
	dc.b $00
s_SYS_System_Format_0030050d:
	dc.b "SYS:System/Format",0
DAT_0030051f:
; Unknown data at address 0030051f.
	dc.b $44
; Unknown data at address 00300520.
	dc.b $61
; Unknown data at address 00300521.
	dc.b $73
; Unknown data at address 00300522.
	dc.b $20
; Unknown data at address 00300523.
	dc.b $41
; Unknown data at address 00300524.
	dc.b $4d
; Unknown data at address 00300525.
	dc.b $42
; Unknown data at address 00300526.
	dc.b $45
; Unknown data at address 00300527.
	dc.b $52
; Unknown data at address 00300528.
	dc.b $4d
; Unknown data at address 00300529.
	dc.b $4f
; Unknown data at address 0030052a.
	dc.b $4f
; Unknown data at address 0030052b.
	dc.b $4e
; Unknown data at address 0030052c.
	dc.b $2d
; Unknown data at address 0030052d.
	dc.b $49
; Unknown data at address 0030052e.
	dc.b $6e
; Unknown data at address 0030052f.
	dc.b $73
; Unknown data at address 00300530.
	dc.b $74
; Unknown data at address 00300531.
	dc.b $61
; Unknown data at address 00300532.
	dc.b $6c
; Unknown data at address 00300533.
	dc.b $6c
; Unknown data at address 00300534.
	dc.b $61
; Unknown data at address 00300535.
	dc.b $74
; Unknown data at address 00300536.
	dc.b $69
; Unknown data at address 00300537.
	dc.b $6f
; Unknown data at address 00300538.
	dc.b $6e
; Unknown data at address 00300539.
	dc.b $73
; Unknown data at address 0030053a.
	dc.b $70
; Unknown data at address 0030053b.
	dc.b $72
; Unknown data at address 0030053c.
	dc.b $6f
; Unknown data at address 0030053d.
	dc.b $67
; Unknown data at address 0030053e.
	dc.b $72
; Unknown data at address 0030053f.
	dc.b $61
; Unknown data at address 00300540.
	dc.b $6d
; Unknown data at address 00300541.
	dc.b $6d
; Unknown data at address 00300542.
	dc.b $20
; Unknown data at address 00300543.
	dc.b $62
; Unknown data at address 00300544.
	dc.b $65
; Unknown data at address 00300545.
	dc.b $6e
; Unknown data at address 00300546.
	dc.b $f6
	dc.b "tigt den >Format< -",$a,0
s_Befehl_im__System____Verzeichnis_0030055c:
	dc.b "Befehl im >System< - Verzeichnis Ihrer Festplatte. Kopieren Sie diesen",$a,0
s_bitte_von_der_AMBERMOON_Disk_A_u_003005a4:
	dc.b "bitte von der AMBERMOON Disk A und starten Sie dieses Programm neu.",$a,0
DAT_003005e9:
; Unknown data at address 003005e9.
	dc.b $0a
; Unknown data at address 003005ea.
	dc.b $44
; Unknown data at address 003005eb.
	dc.b $72
; Unknown data at address 003005ec.
	dc.b $fc
	dc.b "cken Sie bitte >RETURN<.",$a,0
DAT_00300607:
; Unknown data at address 00300607.
	dc.b $0c
; Unknown data at address 00300608.
	dc.b $00
s_SYS_System_More_00300609:
	dc.b "SYS:System/More",0
s_SYS_Utilities_More_00300619:
	dc.b "SYS:Utilities/More",0
DAT_0030062c:
; Unknown data at address 0030062c.
	dc.b $44
; Unknown data at address 0030062d.
	dc.b $61
; Unknown data at address 0030062e.
	dc.b $73
; Unknown data at address 0030062f.
	dc.b $20
; Unknown data at address 00300630.
	dc.b $41
; Unknown data at address 00300631.
	dc.b $4d
; Unknown data at address 00300632.
	dc.b $42
; Unknown data at address 00300633.
	dc.b $45
; Unknown data at address 00300634.
	dc.b $52
; Unknown data at address 00300635.
	dc.b $4d
; Unknown data at address 00300636.
	dc.b $4f
; Unknown data at address 00300637.
	dc.b $4f
; Unknown data at address 00300638.
	dc.b $4e
; Unknown data at address 00300639.
	dc.b $2d
; Unknown data at address 0030063a.
	dc.b $49
; Unknown data at address 0030063b.
	dc.b $6e
; Unknown data at address 0030063c.
	dc.b $73
; Unknown data at address 0030063d.
	dc.b $74
; Unknown data at address 0030063e.
	dc.b $61
; Unknown data at address 0030063f.
	dc.b $6c
; Unknown data at address 00300640.
	dc.b $6c
; Unknown data at address 00300641.
	dc.b $61
; Unknown data at address 00300642.
	dc.b $74
; Unknown data at address 00300643.
	dc.b $69
; Unknown data at address 00300644.
	dc.b $6f
; Unknown data at address 00300645.
	dc.b $6e
; Unknown data at address 00300646.
	dc.b $73
; Unknown data at address 00300647.
	dc.b $70
; Unknown data at address 00300648.
	dc.b $72
; Unknown data at address 00300649.
	dc.b $6f
; Unknown data at address 0030064a.
	dc.b $67
; Unknown data at address 0030064b.
	dc.b $72
; Unknown data at address 0030064c.
	dc.b $61
; Unknown data at address 0030064d.
	dc.b $6d
; Unknown data at address 0030064e.
	dc.b $6d
; Unknown data at address 0030064f.
	dc.b $20
; Unknown data at address 00300650.
	dc.b $62
; Unknown data at address 00300651.
	dc.b $65
; Unknown data at address 00300652.
	dc.b $6e
; Unknown data at address 00300653.
	dc.b $f6
	dc.b "tigt den >More< -",$a,0
s_Befehl_entweder_im__System____od_00300667:
	dc.b "Befehl entweder im >System< - oder im >Utilities< - Verzeichnis",$a,0
s_Ihrer_Festplatte__Kopieren_Sie_d_003006a8:
	dc.b "Ihrer Festplatte. Kopieren Sie diesen bitte von der AMBERMOON",$a,0
s_Disk_A_und_starten_Sie_dieses_Pr_003006e7:
	dc.b "Disk A und starten Sie dieses Programm neu.",$a,0
DAT_00300714:
; Unknown data at address 00300714.
	dc.b $0a
; Unknown data at address 00300715.
	dc.b $44
; Unknown data at address 00300716.
	dc.b $72
; Unknown data at address 00300717.
	dc.b $fc
	dc.b "cken Sie bitte >RETURN<.",$a,0
DAT_00300732:
; Unknown data at address 00300732.
	dc.b $0c
; Unknown data at address 00300733.
	dc.b $00
s_OS_Befehle_werden_kopiert____00300734:
	dc.b "OS-Befehle werden kopiert...",$a,0
s_RAM_AM2_C_00300752:
	dc.b "RAM:AM2_C",0
s_AMBER_A_C_Copy_0030075c:
	dc.b "AMBER_A:C/Copy",0
s_RAM_AM2_C_Copy_0030076b:
	dc.b "RAM:AM2_C/Copy",0
s_AMBER_A_C_Install_0030077a:
	dc.b "AMBER_A:C/Install",0
s_RAM_AM2_C_Install_0030078c:
	dc.b "RAM:AM2_C/Install",0
s_AMBER_A_C_Run_0030079e:
	dc.b "AMBER_A:C/Run",0
s_RAM_AM2_C_Run_003007ac:
	dc.b "RAM:AM2_C/Run",0
s_AMBER_A_C_Assign_003007ba:
	dc.b "AMBER_A:C/Assign",0
s_RAM_AM2_C_Assign_003007cb:
	dc.b "RAM:AM2_C/Assign",0
s_AMBER_A_System_Format_003007dc:
	dc.b "AMBER_A:System/Format",0
s_RAM_AM2_C_Format_003007f2:
	dc.b "RAM:AM2_C/Format",0
s_AMBER_A_System_More_00300803:
	dc.b "AMBER_A:System/More",0
s_RAM_AM2_C_More_00300817:
	dc.b "RAM:AM2_C/More",0
DAT_00300826:
; Unknown data at address 00300826.
	dc.b $0c
; Unknown data at address 00300827.
	dc.b $00
s__OPTIONEN__00300828:
	dc.b "     OPTIONEN:",$a,0
DAT_00300838:
; Unknown data at address 00300838.
	dc.b $0a
; Unknown data at address 00300839.
	dc.b $00
s__1___AMBERMOON_auf_Ihrer_Festpla_0030083a:
	dc.b " 1 - AMBERMOON auf Ihrer Festplatte installieren.",$a,0
DAT_0030086d:
; Unknown data at address 0030086d.
	dc.b $20
; Unknown data at address 0030086e.
	dc.b $20
; Unknown data at address 0030086f.
	dc.b $20
; Unknown data at address 00300870.
	dc.b $20
; Unknown data at address 00300871.
	dc.b $28
; Unknown data at address 00300872.
	dc.b $57
; Unknown data at address 00300873.
	dc.b $65
; Unknown data at address 00300874.
	dc.b $6e
; Unknown data at address 00300875.
	dc.b $6e
; Unknown data at address 00300876.
	dc.b $20
; Unknown data at address 00300877.
	dc.b $53
; Unknown data at address 00300878.
	dc.b $69
; Unknown data at address 00300879.
	dc.b $65
; Unknown data at address 0030087a.
	dc.b $20
; Unknown data at address 0030087b.
	dc.b $41
; Unknown data at address 0030087c.
	dc.b $4d
; Unknown data at address 0030087d.
	dc.b $42
; Unknown data at address 0030087e.
	dc.b $45
; Unknown data at address 0030087f.
	dc.b $52
; Unknown data at address 00300880.
	dc.b $4d
; Unknown data at address 00300881.
	dc.b $4f
; Unknown data at address 00300882.
	dc.b $4f
; Unknown data at address 00300883.
	dc.b $4e
; Unknown data at address 00300884.
	dc.b $20
; Unknown data at address 00300885.
	dc.b $76
; Unknown data at address 00300886.
	dc.b $6f
; Unknown data at address 00300887.
	dc.b $6e
; Unknown data at address 00300888.
	dc.b $20
; Unknown data at address 00300889.
	dc.b $49
; Unknown data at address 0030088a.
	dc.b $68
; Unknown data at address 0030088b.
	dc.b $72
; Unknown data at address 0030088c.
	dc.b $65
; Unknown data at address 0030088d.
	dc.b $72
; Unknown data at address 0030088e.
	dc.b $20
; Unknown data at address 0030088f.
	dc.b $46
; Unknown data at address 00300890.
	dc.b $65
; Unknown data at address 00300891.
	dc.b $73
; Unknown data at address 00300892.
	dc.b $74
; Unknown data at address 00300893.
	dc.b $70
; Unknown data at address 00300894.
	dc.b $6c
; Unknown data at address 00300895.
	dc.b $61
; Unknown data at address 00300896.
	dc.b $74
; Unknown data at address 00300897.
	dc.b $74
; Unknown data at address 00300898.
	dc.b $65
; Unknown data at address 00300899.
	dc.b $20
; Unknown data at address 0030089a.
	dc.b $73
; Unknown data at address 0030089b.
	dc.b $70
; Unknown data at address 0030089c.
	dc.b $69
; Unknown data at address 0030089d.
	dc.b $65
; Unknown data at address 0030089e.
	dc.b $6c
; Unknown data at address 0030089f.
	dc.b $65
; Unknown data at address 003008a0.
	dc.b $6e
; Unknown data at address 003008a1.
	dc.b $20
; Unknown data at address 003008a2.
	dc.b $6d
; Unknown data at address 003008a3.
	dc.b $f6
; Unknown data at address 003008a4.
	dc.b $63
; Unknown data at address 003008a5.
	dc.b $68
; Unknown data at address 003008a6.
	dc.b $74
; Unknown data at address 003008a7.
	dc.b $65
; Unknown data at address 003008a8.
	dc.b $6e
; Unknown data at address 003008a9.
	dc.b $29
; Unknown data at address 003008aa.
	dc.b $0a
; Unknown data at address 003008ab.
	dc.b $00
DAT_003008ac:
; Unknown data at address 003008ac.
	dc.b $0a
; Unknown data at address 003008ad.
	dc.b $00
s__2___Spielstand_Diskette__Disk_J_003008ae:
	dc.b " 2 - Spielstand-Diskette (Disk J) erstellen.",$a,0
DAT_003008dc:
; Unknown data at address 003008dc.
	dc.b $20
; Unknown data at address 003008dd.
	dc.b $20
; Unknown data at address 003008de.
	dc.b $20
; Unknown data at address 003008df.
	dc.b $20
; Unknown data at address 003008e0.
	dc.b $28
; Unknown data at address 003008e1.
	dc.b $57
; Unknown data at address 003008e2.
	dc.b $65
; Unknown data at address 003008e3.
	dc.b $6e
; Unknown data at address 003008e4.
	dc.b $6e
; Unknown data at address 003008e5.
	dc.b $20
; Unknown data at address 003008e6.
	dc.b $53
; Unknown data at address 003008e7.
	dc.b $69
; Unknown data at address 003008e8.
	dc.b $65
; Unknown data at address 003008e9.
	dc.b $20
; Unknown data at address 003008ea.
	dc.b $41
; Unknown data at address 003008eb.
	dc.b $4d
; Unknown data at address 003008ec.
	dc.b $42
; Unknown data at address 003008ed.
	dc.b $45
; Unknown data at address 003008ee.
	dc.b $52
; Unknown data at address 003008ef.
	dc.b $4d
; Unknown data at address 003008f0.
	dc.b $4f
; Unknown data at address 003008f1.
	dc.b $4f
; Unknown data at address 003008f2.
	dc.b $4e
; Unknown data at address 003008f3.
	dc.b $20
; Unknown data at address 003008f4.
	dc.b $76
; Unknown data at address 003008f5.
	dc.b $6f
; Unknown data at address 003008f6.
	dc.b $6e
; Unknown data at address 003008f7.
	dc.b $20
; Unknown data at address 003008f8.
	dc.b $44
; Unknown data at address 003008f9.
	dc.b $69
; Unknown data at address 003008fa.
	dc.b $73
; Unknown data at address 003008fb.
	dc.b $6b
; Unknown data at address 003008fc.
	dc.b $65
; Unknown data at address 003008fd.
	dc.b $74
; Unknown data at address 003008fe.
	dc.b $74
; Unknown data at address 003008ff.
	dc.b $65
; Unknown data at address 00300900.
	dc.b $20
; Unknown data at address 00300901.
	dc.b $73
; Unknown data at address 00300902.
	dc.b $70
; Unknown data at address 00300903.
	dc.b $69
; Unknown data at address 00300904.
	dc.b $65
; Unknown data at address 00300905.
	dc.b $6c
; Unknown data at address 00300906.
	dc.b $65
; Unknown data at address 00300907.
	dc.b $6e
; Unknown data at address 00300908.
	dc.b $20
; Unknown data at address 00300909.
	dc.b $6d
; Unknown data at address 0030090a.
	dc.b $f6
; Unknown data at address 0030090b.
	dc.b $63
; Unknown data at address 0030090c.
	dc.b $68
; Unknown data at address 0030090d.
	dc.b $74
; Unknown data at address 0030090e.
	dc.b $65
; Unknown data at address 0030090f.
	dc.b $6e
; Unknown data at address 00300910.
	dc.b $29
; Unknown data at address 00300911.
	dc.b $0a
; Unknown data at address 00300912.
	dc.b $00
DAT_00300913:
; Unknown data at address 00300913.
	dc.b $0a
; Unknown data at address 00300914.
	dc.b $00
DAT_00300915:
; Unknown data at address 00300915.
	dc.b $20
; Unknown data at address 00300916.
	dc.b $33
; Unknown data at address 00300917.
	dc.b $20
; Unknown data at address 00300918.
	dc.b $2d
; Unknown data at address 00300919.
	dc.b $20
; Unknown data at address 0030091a.
	dc.b $42
; Unknown data at address 0030091b.
	dc.b $6f
; Unknown data at address 0030091c.
	dc.b $6f
; Unknown data at address 0030091d.
	dc.b $74
; Unknown data at address 0030091e.
	dc.b $2d
; Unknown data at address 0030091f.
	dc.b $44
; Unknown data at address 00300920.
	dc.b $69
; Unknown data at address 00300921.
	dc.b $73
; Unknown data at address 00300922.
	dc.b $6b
; Unknown data at address 00300923.
	dc.b $20
; Unknown data at address 00300924.
	dc.b $66
; Unknown data at address 00300925.
	dc.b $fc
	dc.b "r Festplattenbetrieb erstellen.",$a,0
DAT_00300947:
; Unknown data at address 00300947.
	dc.b $20
; Unknown data at address 00300948.
	dc.b $20
; Unknown data at address 00300949.
	dc.b $20
; Unknown data at address 0030094a.
	dc.b $20
; Unknown data at address 0030094b.
	dc.b $28
; Unknown data at address 0030094c.
	dc.b $57
; Unknown data at address 0030094d.
	dc.b $65
; Unknown data at address 0030094e.
	dc.b $6e
; Unknown data at address 0030094f.
	dc.b $6e
; Unknown data at address 00300950.
	dc.b $20
; Unknown data at address 00300951.
	dc.b $53
; Unknown data at address 00300952.
	dc.b $69
; Unknown data at address 00300953.
	dc.b $65
; Unknown data at address 00300954.
	dc.b $20
; Unknown data at address 00300955.
	dc.b $41
; Unknown data at address 00300956.
	dc.b $4d
; Unknown data at address 00300957.
	dc.b $42
; Unknown data at address 00300958.
	dc.b $45
; Unknown data at address 00300959.
	dc.b $52
; Unknown data at address 0030095a.
	dc.b $4d
; Unknown data at address 0030095b.
	dc.b $4f
; Unknown data at address 0030095c.
	dc.b $4f
; Unknown data at address 0030095d.
	dc.b $4e
; Unknown data at address 0030095e.
	dc.b $20
; Unknown data at address 0030095f.
	dc.b $76
; Unknown data at address 00300960.
	dc.b $6f
; Unknown data at address 00300961.
	dc.b $6e
; Unknown data at address 00300962.
	dc.b $20
; Unknown data at address 00300963.
	dc.b $49
; Unknown data at address 00300964.
	dc.b $68
; Unknown data at address 00300965.
	dc.b $72
; Unknown data at address 00300966.
	dc.b $65
; Unknown data at address 00300967.
	dc.b $72
; Unknown data at address 00300968.
	dc.b $20
; Unknown data at address 00300969.
	dc.b $46
; Unknown data at address 0030096a.
	dc.b $65
; Unknown data at address 0030096b.
	dc.b $73
; Unknown data at address 0030096c.
	dc.b $74
; Unknown data at address 0030096d.
	dc.b $70
; Unknown data at address 0030096e.
	dc.b $6c
; Unknown data at address 0030096f.
	dc.b $61
; Unknown data at address 00300970.
	dc.b $74
; Unknown data at address 00300971.
	dc.b $74
; Unknown data at address 00300972.
	dc.b $65
; Unknown data at address 00300973.
	dc.b $20
; Unknown data at address 00300974.
	dc.b $73
; Unknown data at address 00300975.
	dc.b $70
; Unknown data at address 00300976.
	dc.b $69
; Unknown data at address 00300977.
	dc.b $65
; Unknown data at address 00300978.
	dc.b $6c
; Unknown data at address 00300979.
	dc.b $65
; Unknown data at address 0030097a.
	dc.b $6e
; Unknown data at address 0030097b.
	dc.b $20
; Unknown data at address 0030097c.
	dc.b $6d
; Unknown data at address 0030097d.
	dc.b $f6
; Unknown data at address 0030097e.
	dc.b $63
; Unknown data at address 0030097f.
	dc.b $68
; Unknown data at address 00300980.
	dc.b $74
; Unknown data at address 00300981.
	dc.b $65
; Unknown data at address 00300982.
	dc.b $6e
; Unknown data at address 00300983.
	dc.b $2c
; Unknown data at address 00300984.
	dc.b $0a
; Unknown data at address 00300985.
	dc.b $00
DAT_00300986:
; Unknown data at address 00300986.
	dc.b $20
; Unknown data at address 00300987.
	dc.b $20
; Unknown data at address 00300988.
	dc.b $20
; Unknown data at address 00300989.
	dc.b $20
; Unknown data at address 0030098a.
	dc.b $61
; Unknown data at address 0030098b.
	dc.b $62
; Unknown data at address 0030098c.
	dc.b $65
; Unknown data at address 0030098d.
	dc.b $72
; Unknown data at address 0030098e.
	dc.b $20
; Unknown data at address 0030098f.
	dc.b $6e
; Unknown data at address 00300990.
	dc.b $69
; Unknown data at address 00300991.
	dc.b $63
; Unknown data at address 00300992.
	dc.b $68
; Unknown data at address 00300993.
	dc.b $74
; Unknown data at address 00300994.
	dc.b $20
; Unknown data at address 00300995.
	dc.b $fc
; Unknown data at address 00300996.
	dc.b $62
; Unknown data at address 00300997.
	dc.b $65
; Unknown data at address 00300998.
	dc.b $72
; Unknown data at address 00300999.
	dc.b $20
; Unknown data at address 0030099a.
	dc.b $67
; Unknown data at address 0030099b.
	dc.b $65
; Unknown data at address 0030099c.
	dc.b $6e
; Unknown data at address 0030099d.
	dc.b $fc
; Unknown data at address 0030099e.
	dc.b $67
; Unknown data at address 0030099f.
	dc.b $65
; Unknown data at address 003009a0.
	dc.b $6e
; Unknown data at address 003009a1.
	dc.b $64
; Unknown data at address 003009a2.
	dc.b $20
; Unknown data at address 003009a3.
	dc.b $53
; Unknown data at address 003009a4.
	dc.b $70
; Unknown data at address 003009a5.
	dc.b $65
; Unknown data at address 003009a6.
	dc.b $69
; Unknown data at address 003009a7.
	dc.b $63
; Unknown data at address 003009a8.
	dc.b $68
; Unknown data at address 003009a9.
	dc.b $65
; Unknown data at address 003009aa.
	dc.b $72
; Unknown data at address 003009ab.
	dc.b $20
; Unknown data at address 003009ac.
	dc.b $76
; Unknown data at address 003009ad.
	dc.b $65
; Unknown data at address 003009ae.
	dc.b $72
; Unknown data at address 003009af.
	dc.b $66
; Unknown data at address 003009b0.
	dc.b $fc
; Unknown data at address 003009b1.
	dc.b $67
; Unknown data at address 003009b2.
	dc.b $65
; Unknown data at address 003009b3.
	dc.b $6e
; Unknown data at address 003009b4.
	dc.b $29
; Unknown data at address 003009b5.
	dc.b $0a
; Unknown data at address 003009b6.
	dc.b $00
DAT_003009b7:
; Unknown data at address 003009b7.
	dc.b $0a
; Unknown data at address 003009b8.
	dc.b $00
s__4___Das_Troubleshoot___Dokument_003009b9:
	dc.b " 4 - Das Troubleshoot - Dokument einsehen.",$a,0
DAT_003009e5:
; Unknown data at address 003009e5.
	dc.b $20
; Unknown data at address 003009e6.
	dc.b $20
; Unknown data at address 003009e7.
	dc.b $20
; Unknown data at address 003009e8.
	dc.b $20
; Unknown data at address 003009e9.
	dc.b $28
; Unknown data at address 003009ea.
	dc.b $5a
; Unknown data at address 003009eb.
	dc.b $75
; Unknown data at address 003009ec.
	dc.b $73
; Unknown data at address 003009ed.
	dc.b $e4
; Unknown data at address 003009ee.
	dc.b $74
; Unknown data at address 003009ef.
	dc.b $7a
; Unknown data at address 003009f0.
	dc.b $6c
; Unknown data at address 003009f1.
	dc.b $69
; Unknown data at address 003009f2.
	dc.b $63
; Unknown data at address 003009f3.
	dc.b $68
; Unknown data at address 003009f4.
	dc.b $65
; Unknown data at address 003009f5.
	dc.b $20
; Unknown data at address 003009f6.
	dc.b $49
; Unknown data at address 003009f7.
	dc.b $6e
; Unknown data at address 003009f8.
	dc.b $66
; Unknown data at address 003009f9.
	dc.b $6f
; Unknown data at address 003009fa.
	dc.b $72
; Unknown data at address 003009fb.
	dc.b $6d
; Unknown data at address 003009fc.
	dc.b $61
; Unknown data at address 003009fd.
	dc.b $74
; Unknown data at address 003009fe.
	dc.b $69
; Unknown data at address 003009ff.
	dc.b $6f
; Unknown data at address 00300a00.
	dc.b $6e
; Unknown data at address 00300a01.
	dc.b $65
; Unknown data at address 00300a02.
	dc.b $6e
; Unknown data at address 00300a03.
	dc.b $20
; Unknown data at address 00300a04.
	dc.b $fc
	dc.b "ber AMBERMOON und falls Sie",$a,0
s__irgendwelche_Probleme_mit_dem_P_00300a22:
	dc.b "    irgendwelche Probleme mit dem Programm haben sollten)",$a,0
DAT_00300a5d:
; Unknown data at address 00300a5d.
	dc.b $0a
; Unknown data at address 00300a5e.
	dc.b $00
s__5___Beenden__00300a5f:
	dc.b " 5 - Beenden.",$a,0
s___Verlassen_des_Installations_Pr_00300a6e:
	dc.b "    (Verlassen des Installations-Programmes)",$a,0
DAT_00300a9c:
; Unknown data at address 00300a9c.
	dc.b $0a
; Unknown data at address 00300a9d.
	dc.b $00
DAT_00300a9e:
; Unknown data at address 00300a9e.
	dc.b $57
; Unknown data at address 00300a9f.
	dc.b $e4
	dc.b "hlen Sie bitte eine Option: ",0
s_RAM_AM2_C_Copy_00300abd:
	dc.b "RAM:AM2_C/Copy",0
s_RAM_AM2_C_Install_00300acc:
	dc.b "RAM:AM2_C/Install",0
s_RAM_AM2_C_Run_00300ade:
	dc.b "RAM:AM2_C/Run",0
s_RAM_AM2_C_Install_00300aec:
	dc.b "RAM:AM2_C/Install",0
s_RAM_AM2_C_Format_00300afe:
	dc.b "RAM:AM2_C/Format",0
s_RAM_AM2_C_More_00300b0f:
	dc.b "RAM:AM2_C/More",0
s_RAM_AM2_C_00300b1e:
	dc.b "RAM:AM2_C",0
DAT_00300b28:
; Unknown data at address 00300b28.
	dc.b $0c
; Unknown data at address 00300b29.
	dc.b $00
FUN_00300b2a:
	link.w A5,#-$000002a0
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0004,A5)
	clr.l (-$0008,A5)
LAB_00300b3a:
	pea (DAT_00300eb2,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Das_Programm_wird,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_BEISPIEL,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_AMBERMOON_auf_Partition_DH0,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00300fd0,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Bitte_Pfadnamen_angeben,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000064
	pea DAT_00304f84
	jsr (FUN_003021be,PC)
	addq.w #$00000008,SP
	pea -2
	pea DAT_00304f84
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	tst.l (-$0008,A5)
	beq.b LAB_00300bf4
	pea (-$010c,A5)
	move.l (-$0008,A5),-(SP)
	jsr _ExamineThunk
	addq.w #$00000008,SP
	move.l (-$0008,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	tst.l (-$0108,A5)
	bge.b LAB_00300bf2
	pea DAT_00304f84
	pea (s_ist_kein_Verzeichnis,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
	clr.l (-$0008,A5)
LAB_00300bf2:
	bra.b LAB_00300c12
LAB_00300bf4:
	pea DAT_00304f84
	pea (s_existiert_nicht,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
LAB_00300c12:
	tst.l (-$0008,A5)
	beq.w LAB_00300b3a
	pea DAT_00304f84
	jsr FUN_003030c6
	addq.w #$00000004,SP
	subq.l #$00000001,D0
	move.w D0,(-$010e,A5)
	moveq #$00000000,D0
	move.w (-$010e,A5),D0
	lea DAT_00304f84,A0
	cmpi.b #$0000003a,($00,A0,D0.l)
	beq.b LAB_00300c68
	moveq #$00000000,D0
	move.w (-$010e,A5),D0
	lea DAT_00304f84,A0
	cmpi.b #$0000002f,($00,A0,D0.l)
	beq.b LAB_00300c68
	pea (DAT_00301058,PC)
	pea DAT_00304f84
	jsr FUN_00303cb8
	addq.w #$00000008,SP
LAB_00300c68:
	pea DAT_00304f84
	pea (s_AMBERMOON_wird_nach,PC)
	pea (-$01d7,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea (-$01d7,A5)
	jsr (FUN_00302786,PC)
	addq.w #$00000004,SP
	move.b D0,DAT_00304fe8
	cmpi.b #$0000004e,DAT_00304fe8
	bne.b LAB_00300cc0
	pea (DAT_0030109f,PC)
	jsr (FUN_00302786,PC)
	addq.w #$00000004,SP
	move.b D0,DAT_00304fe8
	cmpi.b #$0000004a,DAT_00304fe8
	bne.b LAB_00300cbc
LAB_00300cb4:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00300cbc:
	bra.w LAB_00300b3a
LAB_00300cc0:
	pea (DAT_003010ce,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea DAT_00304f84
	pea (s_AmbermoonInfoPlaceholder,PC)
	pea (-$01d7,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea (s_Ambermoon,PC)
	pea DAT_00304f84
	jsr FUN_00303cb8
	addq.w #$00000008,SP
	pea DAT_00304f84
	pea (-$029f,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
	pea (-$029f,A5)
	jsr (FUN_003027e8,PC)
	addq.w #$00000004,SP
	pea (-$01d7,A5)
	pea (s_FolderInfo,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (s_Installiere_von_Disk_A,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00301139,PC)
	pea (-$029f,A5)
	jsr FUN_00303cb8
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AmbermoonFile,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AmbermoonInfo,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AmbermoonInstall,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AmbermoonInstallInfo,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (s_Amberfiles,PC)
	pea (-$029f,A5)
	jsr FUN_00303cb8
	addq.w #$00000008,SP
	pea (-$029f,A5)
	jsr (FUN_003027e8,PC)
	addq.w #$00000004,SP
	pea (DAT_003011a8,PC)
	pea (-$029f,A5)
	jsr FUN_00303cb8
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AM2_CPU,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_Button_graphics,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP	
	pea (-$029f,A5)
	pea (s_Objects_amb,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP	
	pea (-$029f,A5)
	pea (s_readme_txt,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_liesmich_txt,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_Text_amb,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_Keymap,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_TroubleDoc,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	jsr (FUN_0030281e,PC)
	addq.w #$00000004,SP
	pea (-$029f,A5)
	jsr (FUN_003028da,PC)
	addq.w #$00000004,SP
	pea (s_Startspielstand_wird_kopiert,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (-$029f,A5)
	pea (s_Save00,PC)
	pea (-$01d7,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea (-$01d7,A5)
	pea (s_Initial,PC)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	move.w #$0002,(-$010e,A5)
	bra.b LAB_00300e76
LAB_00300e22:
	moveq #$00000000,D0
	move.w (-$010e,A5),D0
	add.l #$00000040,D0
	move.b D0,(-$010f,A5)
	move.b (-$010f,A5),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	pea (s_Installiere_von_Disk,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	move.b (-$010f,A5),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	pea (s_AmberDiskPlaceholder,PC)
	pea (-$01d7,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea (-$029f,A5)
	pea (-$01d7,A5)
	jsr (FUN_003026aa,PC)
	addq.w #$00000008,SP
	addq.w #$00000001,(-$010e,A5)
LAB_00300e76:
	cmpi.w #$0000000a,(-$010e,A5)
	bcs.b LAB_00300e22
	move.w #$0001,DAT_00304ce4
	pea (s_Installation_abgeschlossen,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Um_zu_spielen_starten_Sie_AMBER,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_003012b4,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	bra.w LAB_00300cb4
DAT_00300eb2:
; Unknown data at address 00300eb2.
	dc.b $0c
	dc.b $a,"Bitte geben Sie den Pfadnamen an, unter dem AMBERMOON installiert",$a,0
s_Das_Programm_wird:
	dc.b "werden soll. Das Programm wird sich dort sein eigenes Verzeichnis erstellen.",$a,$a,0
s_BEISPIEL:
	dc.b "BEISPIEL: Sie geben >DH0:< ein. Es wird dann ein Verzeichnis namens",$a,0
s_AMBERMOON_auf_Partition_DH0:
	dc.b "AMBERMOON auf Partition DH0: erzeugt, und das Installationsprogramm",$a,0
DAT_00300fd0:
; Unknown data at address 00300fd0.
	dc.b $6b
; Unknown data at address 00300fd1.
	dc.b $6f
; Unknown data at address 00300fd2.
	dc.b $70
; Unknown data at address 00300fd3.
	dc.b $69
; Unknown data at address 00300fd4.
	dc.b $65
; Unknown data at address 00300fd5.
	dc.b $72
; Unknown data at address 00300fd6.
	dc.b $74
; Unknown data at address 00300fd7.
	dc.b $20
; Unknown data at address 00300fd8.
	dc.b $61
; Unknown data at address 00300fd9.
	dc.b $6c
; Unknown data at address 00300fda.
	dc.b $6c
; Unknown data at address 00300fdb.
	dc.b $65
; Unknown data at address 00300fdc.
	dc.b $20
; Unknown data at address 00300fdd.
	dc.b $62
; Unknown data at address 00300fde.
	dc.b $65
; Unknown data at address 00300fdf.
	dc.b $6e
; Unknown data at address 00300fe0.
	dc.b $f6
	dc.b "tigten Files in diesen Ordner hinein.",$a,$a,0
s_Bitte_Pfadnamen_angeben:
	dc.b "Bitte Pfadnamen angeben: ",0
s_ist_kein_Verzeichnis:
	dc.b $a,'"',"%s",'"'," ist kein Verzeichnis!",$a,0
s_existiert_nicht:
	dc.b $a,'"',"%s",'"'," existiert nicht!",$a,0
DAT_00301058:
; Unknown data at address 00301058.
	dc.b $2f
; Unknown data at address 00301059.
	dc.b $00
s_AMBERMOON_wird_nach:
	dc.b "AMBERMOON wird nach ",'"',"%sAmbermoon",'"'," installiert.",$a,"Einverstanden? (J/N):",0
DAT_0030109f:
; Unknown data at address 0030109f.
	dc.b $4d
; Unknown data at address 003010a0.
	dc.b $f6
	dc.b "chten Sie die Installation abbrechen? (J/N):",0
DAT_003010ce:
; Unknown data at address 003010ce.
	dc.b $0c
	dc.b $a,"AMBERMOON wird installiert...",$a,$a,0
s_AmbermoonInfoPlaceholder:
	dc.b "%sAmbermoon.info",0
s_Ambermoon:
	dc.b "Ambermoon",0
s_FolderInfo:
	dc.b "AMBER_A:Folder_info",0
s_Installiere_von_Disk_A:
	dc.b "Installiere von Disk A.",$a,$a,0
DAT_00301139:
; Unknown data at address 00301139.
	dc.b $2f
; Unknown data at address 0030113a.
	dc.b $00
s_AmbermoonFile:
	dc.b "AMBER_A:Ambermoon",0
s_AmbermoonInfo:
	dc.b "AMBER_A:Ambermoon.info",0
s_AmbermoonInstall:
	dc.b "AMBER_A:Ambermoon_install",0
s_AmbermoonInstallInfo:
	dc.b "AMBER_A:Ambermoon_install.info",0
s_Amberfiles:
	dc.b "Amberfiles",0
DAT_003011a8:
; Unknown data at address 003011a8.
	dc.b $2f
; Unknown data at address 003011a9.
	dc.b $00
s_AM2_CPU:
	dc.b "AMBER_A:AM2_CPU",0
s_Button_graphics:
	dc.b "AMBER_A:Button_graphics",0
s_Objects_amb:
	dc.b "AMBER_A:Objects.amb",0
s_readme_txt:
	dc.b "AMBER_A:readme.txt",0
s_liesmich_txt:
	dc.b "AMBER_A:liesmich.txt",0
s_Text_amb:
	dc.b "AMBER_A:Text.amb",0
s_Keymap:
	dc.b "AMBER_A:Keymap",0
s_TroubleDoc:
	dc.b "AMBER_A:Trouble.doc",0
s_Startspielstand_wird_kopiert:
	dc.b $a,"Startspielstand wird kopiert.",$a,0
s_Save00:
	dc.b "%sSave.00/",0
s_Initial:
	dc.b "AMBER_A:Initial/#?",0
s_Installiere_von_Disk:
	dc.b $a,"Installiere von Disk %c.",$a,0
s_AmberDiskPlaceholder:
	dc.b "AMBER_%c:#?",0
s_Installation_abgeschlossen:
	dc.b $a,"Installation abgeschlossen.",$a,0
s_Um_zu_spielen_starten_Sie_AMBER:
	dc.b "Um zu spielen, starten Sie AMBERMOON bitte von der Workbench aus.",$a,0
DAT_003012b4:
; Unknown data at address 003012b4.
	dc.b $0a
; Unknown data at address 003012b5.
	dc.b $44
; Unknown data at address 003012b6.
	dc.b $72
; Unknown data at address 003012b7.
	dc.b $fc
	dc.b "cken Sie bitte auf >RETURN<.",$a,0
FUN_003012d6:
	link.w A5,#-$00000008
	movem.l A6/D3/D2,-(SP)
	pea (DAT_003013e6,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_0030140e,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00301439,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_eine_Diskette_wechseln__00301465,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	clr.l -(SP)
	pea (s_AMBER_J_0030147f,PC)
	jsr (FUN_00302278,PC)
	addq.w #$00000008,SP
	tst.w D0
	beq.w LAB_003013ce
	pea -1
	pea (s_AMBER_J__00301487,PC)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	move.l (-$0008,A5),-(SP)
	jsr _CurrentDirThunk
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	pea (s_AMBER_J__00301490,PC)
	jsr (FUN_0030281e,PC)
	addq.w #$00000004,SP
	pea (s_AMBER_J__00301499,PC)
	jsr (FUN_003028da,PC)
	addq.w #$00000004,SP
	move.l (-$0004,A5),-(SP)
	jsr _CurrentDirThunk
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	pea (s__Start_Spielstand_wird_kopiert__003014a2,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_AMBER_J_Save_00_Party_data_sav_003014e2,PC)
	pea (s_AMBER_A_Initial_Party_data_sav_003014c3,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Party_char_amb_00301520,PC)
	pea (s_AMBER_A_Initial_Party_char_amb_00301501,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Automap_amb_0030155b,PC)
	pea (s_AMBER_A_Initial_Automap_amb_0030153f,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Chest_data_amb_00301596,PC)
	pea (s_AMBER_A_Initial_Chest_data_amb_00301577,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Merchant_data_am_003015d7,PC)
	pea (s_AMBER_A_Initial_Merchant_data_am_003015b5,PC)
	jsr (FUN_00302a60,PC)
	addq.w #$00000008,SP
	pea (s__Spielstand_Diskette_wurde_erste_003015f9,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
LAB_003013ce:
	pea (DAT_0030161f,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_003013e6:
; Unknown data at address 003013e6.
	dc.b $0c
	dc.b "Spielstand-Diskette wird erstellt...",$a,$a,0
DAT_0030140e:
; Unknown data at address 0030140e.
	dc.b $48
; Unknown data at address 0030140f.
	dc.b $49
; Unknown data at address 00301410.
	dc.b $4e
; Unknown data at address 00301411.
	dc.b $57
; Unknown data at address 00301412.
	dc.b $45
; Unknown data at address 00301413.
	dc.b $49
; Unknown data at address 00301414.
	dc.b $53
; Unknown data at address 00301415.
	dc.b $3a
; Unknown data at address 00301416.
	dc.b $20
; Unknown data at address 00301417.
	dc.b $42
; Unknown data at address 00301418.
	dc.b $69
; Unknown data at address 00301419.
	dc.b $74
; Unknown data at address 0030141a.
	dc.b $74
; Unknown data at address 0030141b.
	dc.b $65
; Unknown data at address 0030141c.
	dc.b $20
; Unknown data at address 0030141d.
	dc.b $61
; Unknown data at address 0030141e.
	dc.b $63
; Unknown data at address 0030141f.
	dc.b $68
; Unknown data at address 00301420.
	dc.b $74
; Unknown data at address 00301421.
	dc.b $65
; Unknown data at address 00301422.
	dc.b $6e
; Unknown data at address 00301423.
	dc.b $20
; Unknown data at address 00301424.
	dc.b $53
; Unknown data at address 00301425.
	dc.b $69
; Unknown data at address 00301426.
	dc.b $65
; Unknown data at address 00301427.
	dc.b $20
; Unknown data at address 00301428.
	dc.b $64
; Unknown data at address 00301429.
	dc.b $61
; Unknown data at address 0030142a.
	dc.b $72
; Unknown data at address 0030142b.
	dc.b $61
; Unknown data at address 0030142c.
	dc.b $75
; Unknown data at address 0030142d.
	dc.b $66
; Unknown data at address 0030142e.
	dc.b $2c
; Unknown data at address 0030142f.
	dc.b $20
; Unknown data at address 00301430.
	dc.b $64
; Unknown data at address 00301431.
	dc.b $61
; Unknown data at address 00301432.
	dc.b $df
; Unknown data at address 00301433.
	dc.b $20
; Unknown data at address 00301434.
	dc.b $64
; Unknown data at address 00301435.
	dc.b $61
; Unknown data at address 00301436.
	dc.b $73
; Unknown data at address 00301437.
	dc.b $0a
; Unknown data at address 00301438.
	dc.b $00
DAT_00301439:
; Unknown data at address 00301439.
	dc.b $4c
; Unknown data at address 0030143a.
	dc.b $61
; Unknown data at address 0030143b.
	dc.b $75
; Unknown data at address 0030143c.
	dc.b $66
; Unknown data at address 0030143d.
	dc.b $77
; Unknown data at address 0030143e.
	dc.b $65
; Unknown data at address 0030143f.
	dc.b $72
; Unknown data at address 00301440.
	dc.b $6b
; Unknown data at address 00301441.
	dc.b $73
; Unknown data at address 00301442.
	dc.b $6c
; Unknown data at address 00301443.
	dc.b $e4
	dc.b "mpchen erloschen ist, bevor Sie",$a,0
s_eine_Diskette_wechseln__00301465:
	dc.b "eine Diskette wechseln.",$a,$a,0
s_AMBER_J_0030147f:
	dc.b "AMBER_J",0
s_AMBER_J__00301487:
	dc.b "AMBER_J:",0
s_AMBER_J__00301490:
	dc.b "AMBER_J:",0
s_AMBER_J__00301499:
	dc.b "AMBER_J:",0
s__Start_Spielstand_wird_kopiert__003014a2:
	dc.b $a,"Start-Spielstand wird kopiert.",$a,0
s_AMBER_A_Initial_Party_data_sav_003014c3:
	dc.b "AMBER_A:Initial/Party_data.sav",0
s_AMBER_J_Save_00_Party_data_sav_003014e2:
	dc.b "AMBER_J:Save.00/Party_data.sav",0
s_AMBER_A_Initial_Party_char_amb_00301501:
	dc.b "AMBER_A:Initial/Party_char.amb",0
s_AMBER_J_Save_00_Party_char_amb_00301520:
	dc.b "AMBER_J:Save.00/Party_char.amb",0
s_AMBER_A_Initial_Automap_amb_0030153f:
	dc.b "AMBER_A:Initial/Automap.amb",0
s_AMBER_J_Save_00_Automap_amb_0030155b:
	dc.b "AMBER_J:Save.00/Automap.amb",0
s_AMBER_A_Initial_Chest_data_amb_00301577:
	dc.b "AMBER_A:Initial/Chest_data.amb",0
s_AMBER_J_Save_00_Chest_data_amb_00301596:
	dc.b "AMBER_J:Save.00/Chest_data.amb",0
s_AMBER_A_Initial_Merchant_data_am_003015b5:
	dc.b "AMBER_A:Initial/Merchant_data.amb",0
s_AMBER_J_Save_00_Merchant_data_am_003015d7:
	dc.b "AMBER_J:Save.00/Merchant_data.amb",0
s__Spielstand_Diskette_wurde_erste_003015f9:
	dc.b $a,"Spielstand-Diskette wurde erstellt.",$a,0
DAT_0030161f:
; Unknown data at address 0030161f.
	dc.b $0a
; Unknown data at address 00301620.
	dc.b $44
; Unknown data at address 00301621.
	dc.b $72
; Unknown data at address 00301622.
	dc.b $fc
	dc.b "cken Sie bitte auf >RETURN<.",$a,0
; Unknown data at address 00301641.
	dc.b $00
FUN_00301642:
	link.w A5,#-$000001fe
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0004,A5)
	clr.l (-$0008,A5)
	clr.l (-$000c,A5)
	clr.l (-$0010,A5)
	tst.w DAT_00304ce4
	bne.w LAB_003017d0
	pea (s_Haben_Sie_AMBERMOON_schon_auf_Ih_00301a7a,PC)
	jsr (FUN_00302786,PC)
	addq.w #$00000004,SP
	move.b D0,DAT_00304fe8
	cmpi.b #$0000004e,DAT_00304fe8
	bne.b LAB_003016ae
	pea (DAT_00301abd,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_bevor_Sie_eine_Boot_Disk_erstell_00301afe,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00301b23,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
LAB_003016a6:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_003016ae:
	pea (DAT_00301b45,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Bitte_Pfadnamen_angeben__00301b8f,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000064
	pea DAT_00304f84
	jsr (FUN_003021be,PC)
	addq.w #$00000008,SP
	pea DAT_00304f84
	jsr FUN_003030c6
	addq.w #$00000004,SP
	subq.l #$00000001,D0
	move.w D0,(-$01fe,A5)
	moveq #$00000000,D0
	move.w (-$01fe,A5),D0
	lea DAT_00304f84,A0
	cmpi.b #$0000003a,($00,A0,D0.l)
	beq.b LAB_00301724
	moveq #$00000000,D0
	move.w (-$01fe,A5),D0
	lea DAT_00304f84,A0
	cmpi.b #$0000002f,($00,A0,D0.l)
	beq.b LAB_00301724
	pea (DAT_00301ba9,PC)
	pea DAT_00304f84
	jsr FUN_00303cb8
	addq.w #$00000008,SP
LAB_00301724:
	pea DAT_00304f84
	pea (s__sAmbermoon_00301bab,PC)
	pea (-$01dc,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea -2
	pea (-$01dc,A5)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0010,A5)
	tst.l (-$0010,A5)
	beq.b LAB_0030179a
	pea (-$0114,A5)
	move.l (-$0010,A5),-(SP)
	jsr _ExamineThunk
	addq.w #$00000008,SP
	move.l (-$0010,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	tst.l (-$0110,A5)
	bge.b LAB_00301798
	pea (-$01dc,A5)
	pea (s__AMBERMOON_Verzeichnis_wurde_nic_00301bb7,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
	clr.l (-$0010,A5)
LAB_00301798:
	bra.b LAB_003017b6
LAB_0030179a:
	pea (-$01dc,A5)
	pea (s__AMBERMOON_Verzeichnis_wurde_nic_00301bed,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
LAB_003017b6:
	tst.l (-$0010,A5)
	beq.w LAB_003016ae
	pea (s_Ambermoon__00301c23,PC)
	pea DAT_00304f84
	jsr FUN_00303cb8
	addq.w #$00000008,SP
LAB_003017d0:
	pea (DAT_00301c2e,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s__Die_Partition_mit_dem__C____Ver_00301c63,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_Bitte_Partitionsnamen_angeben__00301c97,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000020
	pea (-$01fc,A5)
	jsr (FUN_003021be,PC)
	addq.w #$00000008,SP
	pea (-$01fc,A5)
	jsr FUN_003030c6
	addq.w #$00000004,SP
	subq.l #$00000001,D0
	move.w D0,(-$01fe,A5)
	moveq #$00000000,D0
	move.w (-$01fe,A5),D0
	lea (-$01fc,A5),A0
	cmpi.b #$0000003a,($00,A0,D0.l)
	beq.b LAB_00301836
	pea (DAT_00301cb7,PC)
	pea (-$01fc,A5)
	jsr FUN_00303cb8
	addq.w #$00000008,SP
LAB_00301836:
	pea (-$01fc,A5)
	pea (DAT_00301cb9,PC)
	pea (-$01dc,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea -2
	pea (-$01dc,A5)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0010,A5)
	tst.l (-$0010,A5)
	beq.b LAB_003018aa
	pea (-$0114,A5)
	move.l (-$0010,A5),-(SP)
	jsr _ExamineThunk
	addq.w #$00000008,SP
	move.l (-$0010,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	tst.l (-$0110,A5)
	bge.b LAB_003018a8
	pea (-$01fc,A5)
	pea (s___C____Verzeichnis_kann_nicht_ge_00301cbd,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
	clr.l (-$0010,A5)
LAB_003018a8:
	bra.b LAB_003018c6
LAB_003018aa:
	pea (-$01fc,A5)
	pea (s___C____Verzeichnis_kann_nicht_ge_00301cf6,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
LAB_003018c6:
	tst.l (-$0010,A5)
	beq.w LAB_003017d0
	pea (DAT_00301d2f,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00301d4d,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00301d78,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (s_eine_Diskette_wechseln__00301da4,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000001
	pea (s_Ambermoon_boot_disk_00301dbe,PC)
	jsr (FUN_00302278,PC)
	addq.w #$00000008,SP
	tst.w D0
	beq.w LAB_00301a66
	pea -1
	pea (s_Ambermoon_boot_disk__00301dd2,PC)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$000c,A5)
	move.l (-$000c,A5),-(SP)
	jsr _CurrentDirThunk
	addq.w #$00000004,SP
	move.l D0,(-$0008,A5)
	pea (s_Startup_sequence_wird_generiert__00301de7,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea (DAT_00301e09,PC)
	jsr (FUN_003027e8,PC)
	addq.w #$00000004,SP
	pea $000003ee
	pea (s_S_startup_sequence_00301e0b,PC)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	pea (-$01fc,A5)
	pea (-$01fc,A5)
	pea (s__sC_Assign_SYS___s_00301e1e,PC)
	pea (-$01dc,A5)
	jsr FUN_00303dce
	lea ($0010,SP),SP
	pea (-$01dc,A5)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea (s_SYS_C_Assign_C__SYS_C_00301e31,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea (s_C_Path_C__SYS_System_add_00301e47,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea (s_Assign_DEVS__SYS_Devs_00301e60,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea (s_Assign_L__SYS_L_00301e76,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea (s_Assign_LIBS__SYS_Libs_00301e86,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea DAT_00304f84
	pea (s_Cd__s_00301e9c,PC)
	pea (-$01dc,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea (-$01dc,A5)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	tst.w DAT_003050ea
	beq.b LAB_00301a0c
	pea (s_Ambermoon_BOOT2_00301ea2,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	bra.b LAB_00301a36
LAB_00301a0c:
	pea (s_SetMap_d_00301eb2,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea (s_Ambermoon_BOOT2_00301ebb,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
	pea (s_EndCLI_00301ecb,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00302230,PC)
	addq.w #$00000008,SP
LAB_00301a36:
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	jsr _CurrentDirThunk
	addq.w #$00000004,SP
	move.l (-$000c,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	pea (s__Boot_Disk_wurde_erstellt__00301ed2,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
LAB_00301a66:
	pea (DAT_00301eee,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	bra.w LAB_003016a6
s_Haben_Sie_AMBERMOON_schon_auf_Ih_00301a7a:
	dc.b "Haben Sie AMBERMOON schon auf Ihrer Festplatte installiert? (J/N):",0
DAT_00301abd:
; Unknown data at address 00301abd.
	dc.b $0c
	dc.b $a,"Bitte installieren Sie AMBERMOON zuerst auf Ihrer Festplatte,",$a,0
s_bevor_Sie_eine_Boot_Disk_erstell_00301afe:
	dc.b "bevor Sie eine Boot-Disk erstellen.",$a,0
DAT_00301b23:
; Unknown data at address 00301b23.
	dc.b $0a
; Unknown data at address 00301b24.
	dc.b $44
; Unknown data at address 00301b25.
	dc.b $72
; Unknown data at address 00301b26.
	dc.b $fc
	dc.b "cken Sie bitte auf >RETURN<.",$a,0
DAT_00301b45:
; Unknown data at address 00301b45.
	dc.b $0c
	dc.b $a,"Bitte geben Sie den Pfadnamen an, in dem AMBERMOON installiert wurde.",$a,$a,0
s_Bitte_Pfadnamen_angeben__00301b8f:
	dc.b "Bitte Pfadnamen angeben: ",0
DAT_00301ba9:
; Unknown data at address 00301ba9.
	dc.b $2f
; Unknown data at address 00301baa.
	dc.b $00
s__sAmbermoon_00301bab:
	dc.b "%sAmbermoon",0
s__AMBERMOON_Verzeichnis_wurde_nic_00301bb7:
	dc.b $a,"AMBERMOON-Verzeichnis wurde nicht gefunden in ",'"',"%s",'"',"!",$a,0
s__AMBERMOON_Verzeichnis_wurde_nic_00301bed:
	dc.b $a,"AMBERMOON-Verzeichnis wurde nicht gefunden in ",'"',"%s",'"',"!",$a,0
s_Ambermoon__00301c23:
	dc.b "Ambermoon/",0
DAT_00301c2e:
; Unknown data at address 00301c2e.
	dc.b $0c
	dc.b $a,"Bitte geben Sie den Namen Ihrer Boot-Partition an",$a,0
s__Die_Partition_mit_dem__C____Ver_00301c63:
	dc.b "(Die Partition mit dem >C< - Verzeichnis darauf).",$a,$a,0
s_Bitte_Partitionsnamen_angeben__00301c97:
	dc.b "Bitte Partitionsnamen angeben: ",0
DAT_00301cb7:
; Unknown data at address 00301cb7.
	dc.b $3a
; Unknown data at address 00301cb8.
	dc.b $00
DAT_00301cb9:
; Unknown data at address 00301cb9.
	dc.b $25
; Unknown data at address 00301cba.
	dc.b $73
; Unknown data at address 00301cbb.
	dc.b $43
; Unknown data at address 00301cbc.
	dc.b $00
s___C____Verzeichnis_kann_nicht_ge_00301cbd:
	dc.b $a,">C< - Verzeichnis kann nicht gefunden werden auf '%s'!",$a,0
s___C____Verzeichnis_kann_nicht_ge_00301cf6:
	dc.b $a,">C< - Verzeichnis kann nicht gefunden werden auf '%s'!",$a,0
DAT_00301d2f:
; Unknown data at address 00301d2f.
	dc.b $0c
	dc.b "Boot-Disk wird erstellt...",$a,$a,0
DAT_00301d4d:
; Unknown data at address 00301d4d.
	dc.b $48
; Unknown data at address 00301d4e.
	dc.b $49
; Unknown data at address 00301d4f.
	dc.b $4e
; Unknown data at address 00301d50.
	dc.b $57
; Unknown data at address 00301d51.
	dc.b $45
; Unknown data at address 00301d52.
	dc.b $49
; Unknown data at address 00301d53.
	dc.b $53
; Unknown data at address 00301d54.
	dc.b $3a
; Unknown data at address 00301d55.
	dc.b $20
; Unknown data at address 00301d56.
	dc.b $42
; Unknown data at address 00301d57.
	dc.b $69
; Unknown data at address 00301d58.
	dc.b $74
; Unknown data at address 00301d59.
	dc.b $74
; Unknown data at address 00301d5a.
	dc.b $65
; Unknown data at address 00301d5b.
	dc.b $20
; Unknown data at address 00301d5c.
	dc.b $61
; Unknown data at address 00301d5d.
	dc.b $63
; Unknown data at address 00301d5e.
	dc.b $68
; Unknown data at address 00301d5f.
	dc.b $74
; Unknown data at address 00301d60.
	dc.b $65
; Unknown data at address 00301d61.
	dc.b $6e
; Unknown data at address 00301d62.
	dc.b $20
; Unknown data at address 00301d63.
	dc.b $53
; Unknown data at address 00301d64.
	dc.b $69
; Unknown data at address 00301d65.
	dc.b $65
; Unknown data at address 00301d66.
	dc.b $20
; Unknown data at address 00301d67.
	dc.b $64
; Unknown data at address 00301d68.
	dc.b $61
; Unknown data at address 00301d69.
	dc.b $72
; Unknown data at address 00301d6a.
	dc.b $61
; Unknown data at address 00301d6b.
	dc.b $75
; Unknown data at address 00301d6c.
	dc.b $66
; Unknown data at address 00301d6d.
	dc.b $2c
; Unknown data at address 00301d6e.
	dc.b $20
; Unknown data at address 00301d6f.
	dc.b $64
; Unknown data at address 00301d70.
	dc.b $61
; Unknown data at address 00301d71.
	dc.b $df
; Unknown data at address 00301d72.
	dc.b $20
; Unknown data at address 00301d73.
	dc.b $64
; Unknown data at address 00301d74.
	dc.b $61
; Unknown data at address 00301d75.
	dc.b $73
; Unknown data at address 00301d76.
	dc.b $0a
; Unknown data at address 00301d77.
	dc.b $00
DAT_00301d78:
; Unknown data at address 00301d78.
	dc.b $4c
; Unknown data at address 00301d79.
	dc.b $61
; Unknown data at address 00301d7a.
	dc.b $75
; Unknown data at address 00301d7b.
	dc.b $66
; Unknown data at address 00301d7c.
	dc.b $77
; Unknown data at address 00301d7d.
	dc.b $65
; Unknown data at address 00301d7e.
	dc.b $72
; Unknown data at address 00301d7f.
	dc.b $6b
; Unknown data at address 00301d80.
	dc.b $73
; Unknown data at address 00301d81.
	dc.b $6c
; Unknown data at address 00301d82.
	dc.b $e4
	dc.b "mpchen erloschen ist, bevor Sie",$a,0
s_eine_Diskette_wechseln__00301da4:
	dc.b "eine Diskette wechseln.",$a,$a,0
s_Ambermoon_boot_disk_00301dbe:
	dc.b "Ambermoon boot disk",0
s_Ambermoon_boot_disk__00301dd2:
	dc.b "Ambermoon boot disk:",0
s_Startup_sequence_wird_generiert__00301de7:
	dc.b "Startup-sequence wird generiert.",$a,0
DAT_00301e09:
; Unknown data at address 00301e09.
	dc.b $53
; Unknown data at address 00301e0a.
	dc.b $00
s_S_startup_sequence_00301e0b:
	dc.b "S/startup-sequence",0
s__sC_Assign_SYS___s_00301e1e:
	dc.b "%sC/Assign SYS: %s",0
s_SYS_C_Assign_C__SYS_C_00301e31:
	dc.b "SYS:C/Assign C: SYS:C",0
s_C_Path_C__SYS_System_add_00301e47:
	dc.b "C:Path C: SYS:System add",0
s_Assign_DEVS__SYS_Devs_00301e60:
	dc.b "Assign DEVS: SYS:Devs",0
s_Assign_L__SYS_L_00301e76:
	dc.b "Assign L: SYS:L",0
s_Assign_LIBS__SYS_Libs_00301e86:
	dc.b "Assign LIBS: SYS:Libs",0
s_Cd__s_00301e9c:
	dc.b "Cd %s",0
s_Ambermoon_BOOT2_00301ea2:
	dc.b "Ambermoon BOOT2",0
s_SetMap_d_00301eb2:
	dc.b "SetMap d",0
s_Ambermoon_BOOT2_00301ebb:
	dc.b "Ambermoon BOOT2",0
s_EndCLI_00301ecb:
	dc.b "EndCLI",0
s__Boot_Disk_wurde_erstellt__00301ed2:
	dc.b $a,"Boot-Disk wurde erstellt.",$a,0
DAT_00301eee:
; Unknown data at address 00301eee.
	dc.b $0a
; Unknown data at address 00301eef.
	dc.b $44
; Unknown data at address 00301ef0.
	dc.b $72
; Unknown data at address 00301ef1.
	dc.b $fc
	dc.b "cken Sie bitte >RETURN<.",$a,0
FUN_00301f0c:
	link.w A5,#-$000000c8
	movem.l A6/D3/D2,-(SP)
	tst.w DAT_003050ea
	beq.b LAB_00301f7a
	tst.w DAT_003050ec
	beq.b LAB_00301f50
	tst.w DAT_003050ee
	beq.b LAB_00301f3e
	pea (s_SYS_System_More_Amberfiles_Troub_00302064,PC)
	pea (-$00c8,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
	bra.b LAB_00301f4e
LAB_00301f3e:
	pea (s_SYS_Utilities_More_Amberfiles_Tr_0030208b,PC)
	pea (-$00c8,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
LAB_00301f4e:
	bra.b LAB_00301f60
LAB_00301f50:
	pea (s_RAM_AM2_C_More_AMBER_A_Trouble_d_003020b5,PC)
	pea (-$00c8,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
LAB_00301f60:
	move.l DAT_00304f80,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr _Execute
	lea ($000c,SP),SP
	bra.w LAB_00302054
LAB_00301f7a:
	tst.w DAT_003050ec
	beq.w LAB_0030202e
	pea DAT_00304fea
	pea (s_Assign_X___s_Amberfiles__003020d8,PC)
	pea (-$00c8,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	move.l DAT_00304f80,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr _Execute
	lea ($000c,SP),SP
	tst.w D0
	bne.b LAB_00301fd6
	pea (s_Der_Assign_Befehl_konnte_nicht_g_003020f1,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
LAB_00301fce:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00301fd6:
	tst.w DAT_003050ee
	beq.b LAB_00301ff0
	pea (s_SYS_System_More_X_Trouble_doc_00302123,PC)
	pea (-$00c8,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
	bra.b LAB_00302000
LAB_00301ff0:
	pea (s_SYS_Utilities_More_X_Trouble_doc_00302141,PC)
	pea (-$00c8,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
LAB_00302000:
	move.l DAT_00304f80,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr _Execute
	lea ($000c,SP),SP
	move.l DAT_00304f80,-(SP)
	clr.l -(SP)
	pea (s_Assign_X__remove_00302162,PC)
	jsr _Execute
	lea ($000c,SP),SP
	bra.b LAB_00302054
LAB_0030202e:
	pea (s_RAM_AM2_C_More_AMBER_A_Trouble_d_00302173,PC)
	pea (-$00c8,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
	move.l DAT_00304f80,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr _Execute
	lea ($000c,SP),SP
LAB_00302054:
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
	bra.w LAB_00301fce
s_SYS_System_More_Amberfiles_Troub_00302064:
	dc.b "SYS:System/More Amberfiles/Trouble.doc",0
s_SYS_Utilities_More_Amberfiles_Tr_0030208b:
	dc.b "SYS:Utilities/More Amberfiles/Trouble.doc",0
s_RAM_AM2_C_More_AMBER_A_Trouble_d_003020b5:
	dc.b "RAM:AM2_C/More AMBER_A:Trouble.doc",0
s_Assign_X___s_Amberfiles__003020d8:
	dc.b "Assign X: %s/Amberfiles/",0
s_Der_Assign_Befehl_konnte_nicht_g_003020f1:
	dc.b "Der Assign-Befehl konnte nicht gestartet werden.",$a,0
s_SYS_System_More_X_Trouble_doc_00302123:
	dc.b "SYS:System/More X:Trouble.doc",0
s_SYS_Utilities_More_X_Trouble_doc_00302141:
	dc.b "SYS:Utilities/More X:Trouble.doc",0
s_Assign_X__remove_00302162:
	dc.b "Assign X: remove",0
s_RAM_AM2_C_More_AMBER_A_Trouble_d_00302173:
	dc.b "RAM:AM2_C/More AMBER_A:Trouble.doc",0
FUN_00302196:
	link.w A5,#-$0000000a
	movem.l A6/D3/D2,-(SP)
	pea $00000001
	pea (-$000a,A5)
	move.l DAT_00304f80,-(SP)
	jsr _ReadThunk
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_003021be:
	link.w A5,#-$00000068
	movem.l A6/D3/D2,-(SP)
	pea (-$0068,A5)
	pea (DAT_0030222c,PC)
	jsr FUN_00303108
	addq.w #$00000008,SP
	pea (-$0068,A5)
	jsr FUN_003030c6
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	move.l (-$0004,A5),D0
	cmp.l ($000c,A5),D0
	bcs.b LAB_00302214
	move.l ($000c,A5),-(SP)
	pea (-$0068,A5)
	move.l ($0008,A5),-(SP)
	jsr FUN_00303ce2
	lea ($000c,SP),SP
	move.l ($000c,A5),D0
	movea.l ($0008,A5),A0
	clr.b ($00,A0,D0.l)
	bra.b LAB_00302224
LAB_00302214:
	pea (-$0068,A5)
	move.l ($0008,A5),-(SP)
	jsr FUN_003030b6
	addq.w #$00000008,SP
LAB_00302224:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_0030222c:
; Unknown data at address 0030222c.
	dc.b $25
; Unknown data at address 0030222d.
	dc.b $73
; Unknown data at address 0030222e.
	dc.b $00
; Unknown data at address 0030222f.
	dc.b $00
FUN_00302230:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	move.l ($000c,A5),-(SP)
	jsr FUN_003030c6
	addq.w #$00000004,SP
	move.l D0,-(SP)
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	jsr _WriteThunk
	lea ($000c,SP),SP
	pea $00000001
	pea (DAT_00302276,PC)
	move.l ($0008,A5),-(SP)
	jsr _WriteThunk
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_00302276:
; Unknown data at address 00302276.
	dc.b $0a
; Unknown data at address 00302277.
	dc.b $00
FUN_00302278:
	link.w A5,#-$000000d6
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0008,A5)
	lea (DAT_003024c2,PC),A0
	move.l A0,(-$00d4,A5)
	move.l ($0008,A5),-(SP)
	pea (s_CON_0_100_640_100__Formatiere_____00302504,PC)
	pea (-$00d0,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea $000003ed
	pea (-$00d0,A5)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.w DAT_003050ec
	beq.b LAB_0030232a
	move.l (-$00d4,A5),-(SP)
	jsr FUN_003030c6
	addq.w #$00000004,SP
	move.l D0,-(SP)
	move.l (-$00d4,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr _WriteThunk
	lea ($000c,SP),SP
	pea $00000001
	pea (-$00d0,A5)
	move.l (-$0004,A5),-(SP)
	jsr _ReadThunk
	lea ($000c,SP),SP
	move.l ($0008,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_SYS_System_Format_DRIVE_df0__NAM_0030252a,PC)
	pea (-$00d0,A5)
	jsr FUN_00303dce
	lea ($0010,SP),SP
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (-$00d0,A5)
	jsr _Execute
	lea ($000c,SP),SP
	move.w D0,(-$00d6,A5)
	bra.w LAB_003023e0
LAB_0030232a:
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (s_RAM_AM2_C_Assign_C__RAM_AM2_C__00302559,PC)
	jsr _Execute
	lea ($000c,SP),SP
	tst.w D0
	bne.b LAB_00302364
	pea (s_Der_Assign_Befehl_konnte_nicht_g_00302578,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
	moveq #$00000000,D0
LAB_0030235c:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00302364:
	move.l (-$00d4,A5),-(SP)
	jsr FUN_003030c6
	addq.w #$00000004,SP
	move.l D0,-(SP)
	move.l (-$00d4,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr _WriteThunk
	lea ($000c,SP),SP
	pea $00000001
	pea (-$00d0,A5)
	move.l (-$0004,A5),-(SP)
	jsr _ReadThunk
	lea ($000c,SP),SP
	move.l ($0008,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_RAM_AM2_C_Format_DRIVE_df0__NAME_003025aa,PC)
	pea (-$00d0,A5)
	jsr FUN_00303dce
	lea ($0010,SP),SP
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (-$00d0,A5)
	jsr _Execute
	lea ($000c,SP),SP
	move.w D0,(-$00d6,A5)
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (s_RAM_AM2_C_Assign_C__SYS_C__003025d8,PC)
	jsr _Execute
	lea ($000c,SP),SP
LAB_003023e0:
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	tst.w (-$00d6,A5)
	bne.b LAB_00302410
	pea (s_Der_Format_Befehl_konnte_nicht_g_003025f3,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
	moveq #$00000000,D0
	bra.w LAB_0030235c
LAB_00302410:
	move.l ($0008,A5),-(SP)
	pea (DAT_00302625,PC)
	pea (-$00d0,A5)
	jsr FUN_00303dce
	lea ($000c,SP),SP
	pea -2
	pea (-$00d0,A5)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	move.l (-$0008,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	cmpi.w #$00000001,($000e,A5)
	bne.b LAB_003024b0
	tst.w DAT_003050ec
	beq.b LAB_00302468
	pea (s_Install_df0__00302629,PC)
	pea (-$00d0,A5)
	jsr FUN_00303dce
	addq.w #$00000008,SP
	bra.b LAB_00302478
LAB_00302468:
	pea (s_RAM_AM2_C_Install_df0__00302636,PC)
	pea (-$00d0,A5)
	jsr FUN_00303dce
	addq.w #$00000008,SP
LAB_00302478:
	move.l DAT_00304f80,-(SP)
	clr.l -(SP)
	pea (-$00d0,A5)
	jsr _Execute
	lea ($000c,SP),SP
	tst.w D0
	bne.b LAB_003024b0
	pea (s_Der_Install_Befehl_konnte_nicht_g_0030264d,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
	moveq #$00000000,D0
	bra.w LAB_0030235c
LAB_003024b0:
	pea (s__Die_Disk_wurde_erfolgreich_form_00302680,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	moveq #$00000001,D0
	bra.w LAB_0030235c
DAT_003024c2:
; Unknown data at address 003024c2.
	dc.b $4c
; Unknown data at address 003024c3.
	dc.b $65
; Unknown data at address 003024c4.
	dc.b $67
; Unknown data at address 003024c5.
	dc.b $65
; Unknown data at address 003024c6.
	dc.b $6e
; Unknown data at address 003024c7.
	dc.b $20
; Unknown data at address 003024c8.
	dc.b $53
; Unknown data at address 003024c9.
	dc.b $69
; Unknown data at address 003024ca.
	dc.b $65
; Unknown data at address 003024cb.
	dc.b $20
; Unknown data at address 003024cc.
	dc.b $62
; Unknown data at address 003024cd.
	dc.b $69
; Unknown data at address 003024ce.
	dc.b $74
; Unknown data at address 003024cf.
	dc.b $74
; Unknown data at address 003024d0.
	dc.b $65
; Unknown data at address 003024d1.
	dc.b $20
; Unknown data at address 003024d2.
	dc.b $65
; Unknown data at address 003024d3.
	dc.b $69
; Unknown data at address 003024d4.
	dc.b $6e
; Unknown data at address 003024d5.
	dc.b $65
; Unknown data at address 003024d6.
	dc.b $20
; Unknown data at address 003024d7.
	dc.b $44
; Unknown data at address 003024d8.
	dc.b $69
; Unknown data at address 003024d9.
	dc.b $73
; Unknown data at address 003024da.
	dc.b $6b
; Unknown data at address 003024db.
	dc.b $65
; Unknown data at address 003024dc.
	dc.b $74
; Unknown data at address 003024dd.
	dc.b $74
; Unknown data at address 003024de.
	dc.b $65
; Unknown data at address 003024df.
	dc.b $20
; Unknown data at address 003024e0.
	dc.b $69
; Unknown data at address 003024e1.
	dc.b $6e
; Unknown data at address 003024e2.
	dc.b $20
; Unknown data at address 003024e3.
	dc.b $44
; Unknown data at address 003024e4.
	dc.b $46
; Unknown data at address 003024e5.
	dc.b $30
; Unknown data at address 003024e6.
	dc.b $3a
; Unknown data at address 003024e7.
	dc.b $20
; Unknown data at address 003024e8.
	dc.b $65
; Unknown data at address 003024e9.
	dc.b $69
; Unknown data at address 003024ea.
	dc.b $6e
; Unknown data at address 003024eb.
	dc.b $20
; Unknown data at address 003024ec.
	dc.b $75
; Unknown data at address 003024ed.
	dc.b $6e
; Unknown data at address 003024ee.
	dc.b $64
; Unknown data at address 003024ef.
	dc.b $20
; Unknown data at address 003024f0.
	dc.b $64
; Unknown data at address 003024f1.
	dc.b $72
; Unknown data at address 003024f2.
	dc.b $fc
	dc.b "cken Sie Return.",0
s_CON_0_100_640_100__Formatiere_____00302504:
	dc.b "CON:0/100/640/100/ Formatiere [ %s ] ",0
s_SYS_System_Format_DRIVE_df0__NAM_0030252a:
	dc.b "SYS:System/Format DRIVE df0: NAME ",'"',"%s",'"'," NOICONS",0
s_RAM_AM2_C_Assign_C__RAM_AM2_C__00302559:
	dc.b "RAM:AM2_C/Assign C: RAM:AM2_C/",0
s_Der_Assign_Befehl_konnte_nicht_g_00302578:
	dc.b "Der Assign-Befehl konnte nicht gestartet werden.",$a,0
s_RAM_AM2_C_Format_DRIVE_df0__NAME_003025aa:
	dc.b "RAM:AM2_C/Format DRIVE df0: NAME ",'"',"%s",'"'," NOICONS",0
s_RAM_AM2_C_Assign_C__SYS_C__003025d8:
	dc.b "RAM:AM2_C/Assign C: SYS:C/",0
s_Der_Format_Befehl_konnte_nicht_g_003025f3:
	dc.b "Der Format-Befehl konnte nicht gestartet werden.",$a,0
DAT_00302625:
; Unknown data at address 00302625.
	dc.b $25
; Unknown data at address 00302626.
	dc.b $73
; Unknown data at address 00302627.
	dc.b $3a
; Unknown data at address 00302628.
	dc.b $00
s_Install_df0__00302629:
	dc.b "Install df0:",0
s_RAM_AM2_C_Install_df0__00302636:
	dc.b "RAM:AM2_C/Install df0:",0
s_Der_Install_Befehl_konnte_nicht_g_0030264d:
	dc.b "Der Install-Befehl konnte nicht gestartet werden.",$a,0
s__Die_Disk_wurde_erfolgreich_form_00302680:
	dc.b $a,"Die Disk wurde erfolgreich formatiert.",$a,0
; Unknown data at address 003026a9.
	dc.b $00
FUN_003026aa:
	link.w A5,#-$000000ca
	movem.l A6/D3/D2,-(SP)
	tst.w DAT_003050ec
	beq.b LAB_003026d6
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_Copy__s__s_00302736,PC)
	pea (-$00c8,A5)
	jsr FUN_00303dce
	lea ($0010,SP),SP
	bra.b LAB_003026f0
LAB_003026d6:
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_RAM_AM2_C_Copy__s__s_00302741,PC)
	pea (-$00c8,A5)
	jsr FUN_00303dce
	lea ($0010,SP),SP
LAB_003026f0:
	move.l DAT_00304f80,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr _Execute
	lea ($000c,SP),SP
	move.w D0,(-$00ca,A5)
	tst.w (-$00ca,A5)
	bne.b LAB_00302728
	pea (s_Der_Copy_Befehl_konnte_nicht_ges_00302756,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00000064
	jsr _Delay
	addq.w #$00000004,SP
LAB_00302728:
	move.w (-$00ca,A5),D0
	ext.l D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_Copy__s__s_00302736:
	dc.b "Copy %s %s",0
s_RAM_AM2_C_Copy__s__s_00302741:
	dc.b "RAM:AM2_C/Copy %s %s",0
s_Der_Copy_Befehl_konnte_nicht_ges_00302756:
	dc.b "Der Copy-Befehl konnte nicht gestartet werden.",$a,0
FUN_00302786:
	link.w A5,#-$00000006
	movem.l A6/D3/D2,-(SP)
LAB_0030278e:
	move.l ($0008,A5),-(SP)
	pea (DAT_003027e2,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea $00000004
	pea (-$0005,A5)
	jsr (FUN_003021be,PC)
	addq.w #$00000008,SP
	move.b (-$0005,A5),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_003030d8
	addq.w #$00000004,SP
	move.b D0,(-$0006,A5)
	cmpi.b #$0000004a,(-$0006,A5)
	beq.b LAB_003027d2
	cmpi.b #$0000004e,(-$0006,A5)
	bne.b LAB_0030278e
LAB_003027d2:
	move.b (-$0006,A5),D0
	ext.w D0
	ext.l D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_003027e2:
; Unknown data at address 003027e2.
	dc.b $0c
; Unknown data at address 003027e3.
	dc.b $0a
; Unknown data at address 003027e4.
	dc.b $25
; Unknown data at address 003027e5.
	dc.b $73
; Unknown data at address 003027e6.
	dc.b $00
; Unknown data at address 003027e7.
	dc.b $00
FUN_003027e8:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0004,A5)
	move.l ($0008,A5),-(SP)
	jsr _CreateDir
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	beq.b LAB_00302816
	move.l (-$0004,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
LAB_00302816:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_0030281e:
	link.w A5,#-$000000ce
	movem.l A6/D3/D2,-(SP)
	pea (s_Save_Verzeichnisse_werden_generi_003028a6,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	clr.w (-$0002,A5)
	bra.b LAB_00302896
LAB_00302838:
	moveq #$00000000,D0
	move.w (-$0002,A5),D0
	moveq #$0000000a,D1
	jsr FUN_00304296
	move.l D0,-(SP)
	moveq #$00000000,D0
	move.w (-$0002,A5),D0
	moveq #$00000064,D1
	jsr FUN_00304296
	moveq #$0000000a,D1
	jsr FUN_003042a2
	move.l D0,-(SP)
	move.l ($0008,A5),-(SP)
	pea (s__sSave__1u_1u_003028cc,PC)
	pea (-$00ce,A5)
	jsr FUN_00303dce
	lea ($0014,SP),SP
	pea (-$00ce,A5)
	jsr _CreateDir
	addq.w #$00000004,SP
	move.l D0,(-$0006,A5)
	move.l (-$0006,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	addq.w #$00000001,(-$0002,A5)
LAB_00302896:
	cmpi.w #$0000000b,(-$0002,A5)
	bcs.b LAB_00302838
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_Save_Verzeichnisse_werden_generi_003028a6:
	dc.b "Save-Verzeichnisse werden generiert.",$a,0
s__sSave__1u_1u_003028cc:
	dc.b "%sSave.%1u%1u",0
FUN_003028da:
	link.w A5,#-$000000d0
	movem.l A6/D3/D2,-(SP)
	pea (s_Save_Datei_wird_generiert__003029bc,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	pea $00010000
	pea $0000017e
	jsr _AllocMemThunk
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	tst.l (-$0008,A5)
	bne.b LAB_00302912
LAB_0030290a:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00302912:
	move.l ($0008,A5),-(SP)
	pea (-$00d0,A5)
	jsr FUN_003030b6
	addq.w #$00000008,SP
	pea (s_Saves_003029d8,PC)
	pea (-$00d0,A5)
	jsr FUN_00303cb8
	addq.w #$00000008,SP
	pea $000003ee
	pea (-$00d0,A5)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	bne.b LAB_0030295e
	pea $0000017e
	move.l (-$0008,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	bra.b LAB_0030290a
LAB_0030295e:
	pea $0000017e
	move.l (-$0008,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr _WriteThunk
	lea ($000c,SP),SP
	cmp.l #$0000017e,D0
	beq.b LAB_0030299c
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	pea $0000017e
	move.l (-$0008,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	bra.w LAB_0030290a
LAB_0030299c:
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	pea $0000017e
	move.l (-$0008,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	bra.w LAB_0030290a
s_Save_Datei_wird_generiert__003029bc:
	dc.b "Save-Datei wird generiert.",$a,0
s_Saves_003029d8:
	dc.b "Saves",0
FUN_003029de:
	link.w A5,#-$0000000c
	movem.l A6/D3/D2,-(SP)
	clr.l (-$000c,A5)
	clr.l -(SP)
	pea $00000104
	jsr _AllocMemThunk
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	beq.b LAB_00302a54
	pea -2
	move.l ($0008,A5),-(SP)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	beq.b LAB_00302a32
	move.l (-$0008,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr _ExamineThunk
	addq.w #$00000008,SP
	tst.w D0
	beq.b LAB_00302a32
	movea.l (-$0008,A5),A0
	move.l ($007c,A0),(-$000c,A5)
LAB_00302a32:
	tst.l (-$0004,A5)
	beq.b LAB_00302a44
	move.l (-$0004,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
LAB_00302a44:
	pea $00000104
	move.l (-$0008,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
LAB_00302a54:
	move.l (-$000c,A5),D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00302a60:
	link.w A5,#-$0000000c
	movem.l A6/D3/D2,-(SP)
	move.l ($0008,A5),-(SP)
	jsr (FUN_003029de,PC)
	addq.w #$00000004,SP
	move.l D0,(-$0008,A5)
	bne.b LAB_00302aa0
	move.l ($0008,A5),-(SP)
	pea (s_Datei__s_nicht_gefunden__00302c4e,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea (DAT_00302c68,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
LAB_00302a98:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00302aa0:
	clr.l -(SP)
	move.l (-$0008,A5),-(SP)
	jsr _AllocMemThunk
	addq.w #$00000008,SP
	move.l D0,(-$000c,A5)
	bne.b LAB_00302ad6
	move.l ($0008,A5),-(SP)
	pea (DAT_00302c8e,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea (DAT_00302cbc,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	bra.b LAB_00302a98
LAB_00302ad6:
	pea $000003ed
	move.l ($0008,A5),-(SP)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	bne.b LAB_00302b20
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	move.l ($0008,A5),-(SP)
	pea (DAT_00302ce2,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea (DAT_00302d0a,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	bra.w LAB_00302a98
LAB_00302b20:
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr _ReadThunk
	lea ($000c,SP),SP
	cmp.l (-$0008,A5),D0
	beq.b LAB_00302b7c
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	move.l ($0008,A5),-(SP)
	pea (s_Datei__s_konnte_nicht_gelesen_we_00302d30,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea (DAT_00302d57,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	bra.w LAB_00302a98
LAB_00302b7c:
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	pea $000003ee
	move.l ($000c,A5),-(SP)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	bne.b LAB_00302bd2
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	move.l ($000c,A5),-(SP)
	pea (DAT_00302d7d,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea (DAT_00302da5,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	bra.w LAB_00302a98
LAB_00302bd2:
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr _WriteThunk
	lea ($000c,SP),SP
	cmp.l (-$0008,A5),D0
	beq.b LAB_00302c2e
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	move.l ($000c,A5),-(SP)
	pea (s_Datei__s_konnte_nicht_geschriebe_00302dcb,PC)
	jsr FUN_00303e34
	addq.w #$00000008,SP
	pea (DAT_00302df6,PC)
	jsr FUN_00303e34
	addq.w #$00000004,SP
	jsr (FUN_00302196,PC)
	bra.w LAB_00302a98
LAB_00302c2e:
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr _FreeMemThunk
	addq.w #$00000008,SP
	bra.w LAB_00302a98
s_Datei__s_nicht_gefunden__00302c4e:
	dc.b "Datei %s nicht gefunden.",$a,0
DAT_00302c68:
; Unknown data at address 00302c68.
	dc.b $44
; Unknown data at address 00302c69.
	dc.b $72
; Unknown data at address 00302c6a.
	dc.b $fc
	dc.b "cken Sie bitte die RETURN -Taste.",$a,0
DAT_00302c8e:
; Unknown data at address 00302c8e.
	dc.b $4e
; Unknown data at address 00302c8f.
	dc.b $69
; Unknown data at address 00302c90.
	dc.b $63
; Unknown data at address 00302c91.
	dc.b $68
; Unknown data at address 00302c92.
	dc.b $74
; Unknown data at address 00302c93.
	dc.b $20
; Unknown data at address 00302c94.
	dc.b $67
; Unknown data at address 00302c95.
	dc.b $65
; Unknown data at address 00302c96.
	dc.b $6e
; Unknown data at address 00302c97.
	dc.b $fc
; Unknown data at address 00302c98.
	dc.b $67
; Unknown data at address 00302c99.
	dc.b $65
; Unknown data at address 00302c9a.
	dc.b $6e
; Unknown data at address 00302c9b.
	dc.b $64
; Unknown data at address 00302c9c.
	dc.b $20
; Unknown data at address 00302c9d.
	dc.b $66
; Unknown data at address 00302c9e.
	dc.b $72
; Unknown data at address 00302c9f.
	dc.b $65
; Unknown data at address 00302ca0.
	dc.b $69
; Unknown data at address 00302ca1.
	dc.b $65
; Unknown data at address 00302ca2.
	dc.b $72
; Unknown data at address 00302ca3.
	dc.b $20
; Unknown data at address 00302ca4.
	dc.b $53
; Unknown data at address 00302ca5.
	dc.b $70
; Unknown data at address 00302ca6.
	dc.b $65
; Unknown data at address 00302ca7.
	dc.b $69
; Unknown data at address 00302ca8.
	dc.b $63
; Unknown data at address 00302ca9.
	dc.b $68
; Unknown data at address 00302caa.
	dc.b $65
; Unknown data at address 00302cab.
	dc.b $72
; Unknown data at address 00302cac.
	dc.b $20
; Unknown data at address 00302cad.
	dc.b $66
; Unknown data at address 00302cae.
	dc.b $fc
	dc.b "r Datei %s.",$a,0
DAT_00302cbc:
; Unknown data at address 00302cbc.
	dc.b $44
; Unknown data at address 00302cbd.
	dc.b $72
; Unknown data at address 00302cbe.
	dc.b $fc
	dc.b "cken Sie bitte die RETURN -Taste.",$a,0
DAT_00302ce2:
; Unknown data at address 00302ce2.
	dc.b $44
; Unknown data at address 00302ce3.
	dc.b $61
; Unknown data at address 00302ce4.
	dc.b $74
; Unknown data at address 00302ce5.
	dc.b $65
; Unknown data at address 00302ce6.
	dc.b $69
; Unknown data at address 00302ce7.
	dc.b $20
; Unknown data at address 00302ce8.
	dc.b $25
; Unknown data at address 00302ce9.
	dc.b $73
; Unknown data at address 00302cea.
	dc.b $20
; Unknown data at address 00302ceb.
	dc.b $6b
; Unknown data at address 00302cec.
	dc.b $6f
; Unknown data at address 00302ced.
	dc.b $6e
; Unknown data at address 00302cee.
	dc.b $6e
; Unknown data at address 00302cef.
	dc.b $74
; Unknown data at address 00302cf0.
	dc.b $65
; Unknown data at address 00302cf1.
	dc.b $20
; Unknown data at address 00302cf2.
	dc.b $6e
; Unknown data at address 00302cf3.
	dc.b $69
; Unknown data at address 00302cf4.
	dc.b $63
; Unknown data at address 00302cf5.
	dc.b $68
; Unknown data at address 00302cf6.
	dc.b $74
; Unknown data at address 00302cf7.
	dc.b $20
; Unknown data at address 00302cf8.
	dc.b $67
; Unknown data at address 00302cf9.
	dc.b $65
; Unknown data at address 00302cfa.
	dc.b $f6
	dc.b "ffnet werden.",$a,0
DAT_00302d0a:
; Unknown data at address 00302d0a.
	dc.b $44
; Unknown data at address 00302d0b.
	dc.b $72
; Unknown data at address 00302d0c.
	dc.b $fc
	dc.b "cken Sie bitte die RETURN -Taste.",$a,0
s_Datei__s_konnte_nicht_gelesen_we_00302d30:
	dc.b "Datei %s konnte nicht gelesen werden.",$a,0
DAT_00302d57:
; Unknown data at address 00302d57.
	dc.b $44
; Unknown data at address 00302d58.
	dc.b $72
; Unknown data at address 00302d59.
	dc.b $fc
	dc.b "cken Sie bitte die RETURN -Taste.",$a,0
DAT_00302d7d:
; Unknown data at address 00302d7d.
	dc.b $44
; Unknown data at address 00302d7e.
	dc.b $61
; Unknown data at address 00302d7f.
	dc.b $74
; Unknown data at address 00302d80.
	dc.b $65
; Unknown data at address 00302d81.
	dc.b $69
; Unknown data at address 00302d82.
	dc.b $20
; Unknown data at address 00302d83.
	dc.b $25
; Unknown data at address 00302d84.
	dc.b $73
; Unknown data at address 00302d85.
	dc.b $20
; Unknown data at address 00302d86.
	dc.b $6b
; Unknown data at address 00302d87.
	dc.b $6f
; Unknown data at address 00302d88.
	dc.b $6e
; Unknown data at address 00302d89.
	dc.b $6e
; Unknown data at address 00302d8a.
	dc.b $74
; Unknown data at address 00302d8b.
	dc.b $65
; Unknown data at address 00302d8c.
	dc.b $20
; Unknown data at address 00302d8d.
	dc.b $6e
; Unknown data at address 00302d8e.
	dc.b $69
; Unknown data at address 00302d8f.
	dc.b $63
; Unknown data at address 00302d90.
	dc.b $68
; Unknown data at address 00302d91.
	dc.b $74
; Unknown data at address 00302d92.
	dc.b $20
; Unknown data at address 00302d93.
	dc.b $67
; Unknown data at address 00302d94.
	dc.b $65
; Unknown data at address 00302d95.
	dc.b $f6
	dc.b "ffnet werden.",$a,0
DAT_00302da5:
; Unknown data at address 00302da5.
	dc.b $44
; Unknown data at address 00302da6.
	dc.b $72
; Unknown data at address 00302da7.
	dc.b $fc
	dc.b "cken Sie bitte die RETURN -Taste.",$a,0
s_Datei__s_konnte_nicht_geschriebe_00302dcb:
	dc.b "Datei %s konnte nicht geschrieben werden.",$a,0
DAT_00302df6:
; Unknown data at address 00302df6.
	dc.b $44
; Unknown data at address 00302df7.
	dc.b $72
; Unknown data at address 00302df8.
	dc.b $fc
	dc.b "cken Sie bitte die RETURN -Taste.",$a,0
FUN_00302e1c:
	link.w A5,#-$0000001a
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0010,A5)
	tst.w DAT_003050ea
	beq.w LAB_00302ee2
	move.w #$0001,DAT_003050ec
	pea $000003ed
	pea (s_Ambermoon_install_00302f2e,PC)
	jsr _OpenThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	beq.w LAB_00302ee0
	move.l (-$0004,A5),D0
	asl.l #$00000002,D0
	movea.l D0,A0
	move.l ($0008,A0),(-$0008,A5)
	movea.l (-$0008,A5),A0
	moveq #$00000000,D0
	move.b ($000e,A0),D0
	move.l D0,(-$0018,A5)
	move.l (-$0018,A5),D0
	and.l #$00000003,D0
	bne.b LAB_00302ed4
	movea.l (-$0008,A5),A0
	move.l ($0010,A0),(-$000c,A5)
	movea.l (-$000c,A5),A0
	move.l ($000a,A0),(-$0014,A5)
	movea.l (-$0014,A5),A0
	cmpi.b #$00000044,(A0)
	bne.b LAB_00302ed4
	movea.l (-$0014,A5),A0
	cmpi.b #$00000046,($0001,A0)
	bne.b LAB_00302ed4
	movea.l (-$0014,A5),A0
	move.b ($0002,A0),D0
	ext.w D0
	moveq #$00000000,D1
	move.w D0,D1
	sub.l #$00000030,D1
	move.w D1,(-$001a,A5)
	tst.w (-$001a,A5)
	bcs.b LAB_00302ed4
	cmpi.w #$00000003,(-$001a,A5)
	bhi.b LAB_00302ed4
	clr.w DAT_003050ec
LAB_00302ed4:
	move.l (-$0004,A5),-(SP)
	jsr _CloseThunk
	addq.w #$00000004,SP
LAB_00302ee0:
	bra.b LAB_00302f26
LAB_00302ee2:
	clr.w DAT_003050ec
	pea -1
	pea (s_Folder_info_00302f40,PC)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0010,A5)
	tst.l (-$0010,A5)
	beq.b LAB_00302f10
	move.l (-$0010,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	bra.b LAB_00302f26
LAB_00302f10:
	jsr _IoErrThunk
	cmp.l #$000000cd,D0
	bne.b LAB_00302f26
	move.w #$0001,DAT_003050ec
LAB_00302f26:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_Ambermoon_install_00302f2e:
	dc.b "Ambermoon_install",0
s_Folder_info_00302f40:
	dc.b "Folder_info",0
FUN_00302f4c:
	link.w A5,#-$0000000a
	movem.l A6/D3/D2,-(SP)
	move.l #$00000004,(-$0004,A5)
	movea.l (-$0004,A5),A0
	move.l (A0),(-$0008,A5)
	movea.l (-$0008,A5),A0
	move.w ($0014,A0),(-$000a,A5)
	cmpi.w #$00000024,(-$000a,A5)
	bcs.b LAB_00302f7a
	moveq #$00000001,D0
	bra.b LAB_00302f7c
LAB_00302f7a:
	moveq #$00000000,D0
LAB_00302f7c:
	move.w D0,DAT_003050ea
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00302f8a:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	pea -2
	move.l ($0008,A5),-(SP)
	jsr _LockThunk
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	beq.b LAB_00302fc2
	move.l (-$0004,A5),-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
	moveq #$00000001,D0
LAB_00302fba:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00302fc2:
	moveq #$00000000,D0
	bra.b LAB_00302fba
FUN_00302fc6:
	link.w A5,#-$0000011c
	movem.l A6/D3/D2,-(SP)
	move.l #$000000fe,(-$0118,A5)
	clr.l -(SP)
	jsr _FindTaskThunk
	addq.w #$00000004,SP
	movea.l D0,A0
	move.l ($0098,A0),(-$0004,A5)
	clr.b DAT_003050e8
	clr.b DAT_003050e9
LAB_00302ff4:
	move.l (-$0118,A5),(-$0114,A5)
	pea (-$0108,A5)
	move.l (-$0004,A5),-(SP)
	jsr _ExamineThunk
	addq.w #$00000008,SP
	lea (-$0100,A5),A0
	move.l A0,(-$011c,A5)
	move.l (-$011c,A5),-(SP)
	jsr FUN_003030c6
	addq.w #$00000004,SP
	move.l D0,(-$010c,A5)
	move.l (-$010c,A5),D0
	sub.l D0,(-$0118,A5)
	clr.l (-$0110,A5)
	bra.b LAB_00303050
LAB_00303030:
	move.l (-$0110,A5),D0
	movea.l (-$011c,A5),A0
	move.l (-$0110,A5),D1
	add.l (-$0118,A5),D1
	lea DAT_00304fea,A1
	move.b ($00,A0,D0.l),($00,A1,D1.l)
	addq.l #$00000001,(-$0110,A5)
LAB_00303050:
	move.l (-$0110,A5),D0
	cmp.l (-$010c,A5),D0
	blt.b LAB_00303030
	subq.l #$00000001,(-$0118,A5)
	move.l (-$0118,A5),D0
	lea DAT_00304fea,A0
	move.b #$2f,($00,A0,D0.l)
	move.l (-$0004,A5),-(SP)
	jsr _ParentDir
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	bne.w LAB_00302ff4
	move.l (-$0114,A5),D0
	lea DAT_00304fea,A0
	move.b #$3a,($00,A0,D0.l)
	lea DAT_00304feb,A0
	movea.l (-$0118,A5),A1
	adda.l A0,A1
	move.l A1,-(SP)
	pea DAT_00304fea
	jsr FUN_003030b6
	addq.w #$00000008,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_003030b6:
	movea.l ($0004,SP),A0
	move.l A0,D0
	movea.l ($0008,SP),A1
LAB_003030c0:
	move.b (A1)+,(A0)+
	bne.b LAB_003030c0
	rts
FUN_003030c6:
	movea.l ($0004,SP),A0
	move.l A0,D0
LAB_003030cc:
	tst.b (A0)+
	bne.b LAB_003030cc
	suba.l D0,A0
	move.l A0,D0
	subq.l #$00000001,D0
	rts
FUN_003030d8:
	moveq #$00000000,D0
	move.b ($0007,SP),D0
	cmp.b #$60,D0
	bls.b LAB_003030ee
	cmp.b #$7a,D0
	bhi.b LAB_003030ee
	sub.b #$20,D0
LAB_003030ee:
	rts
; Unknown data at address 003030f0.
	dc.b $70
; Unknown data at address 003030f1.
	dc.b $00
; Unknown data at address 003030f2.
	dc.b $10
; Unknown data at address 003030f3.
	dc.b $2f
; Unknown data at address 003030f4.
	dc.b $00
; Unknown data at address 003030f5.
	dc.b $07
; Unknown data at address 003030f6.
	dc.b $b0
; Unknown data at address 003030f7.
	dc.b $3c
; Unknown data at address 003030f8.
	dc.b $00
; Unknown data at address 003030f9.
	dc.b $40
; Unknown data at address 003030fa.
	dc.b $63
; Unknown data at address 003030fb.
	dc.b $0a
; Unknown data at address 003030fc.
	dc.b $b0
; Unknown data at address 003030fd.
	dc.b $3c
; Unknown data at address 003030fe.
	dc.b $00
; Unknown data at address 003030ff.
	dc.b $5a
; Unknown data at address 00303100.
	dc.b $62
; Unknown data at address 00303101.
	dc.b $04
; Unknown data at address 00303102.
	dc.b $d0
; Unknown data at address 00303103.
	dc.b $3c
; Unknown data at address 00303104.
	dc.b $00
; Unknown data at address 00303105.
	dc.b $20
; Unknown data at address 00303106.
	dc.b $4e
; Unknown data at address 00303107.
	dc.b $75
FUN_00303108:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	clr.l DAT_00304f6c
	pea ($000c,A5)
	move.l ($0008,A5),-(SP)
	pea (LAB_00303134,PC)
	jsr FUN_00303196
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00303134:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	tst.l ($0008,A5)
	bne.b LAB_0030316e
	btst.b #$00000003,DAT_00304db4
	beq.b LAB_00303158
	move.l #-$00000001,DAT_00304f6c
	bra.b LAB_0030316c
LAB_00303158:
	pea DAT_00304da8
	jsr FUN_00303662
	move.l D0,DAT_00304f6c
	addq.w #$00000004,SP
LAB_0030316c:
	bra.b LAB_00303188
LAB_0030316e:
	pea DAT_00304da8
	move.l DAT_00304f6c,-(SP)
	jsr FUN_003037b6
	move.l D0,DAT_00304f6c
	addq.w #$00000008,SP
LAB_00303188:
	move.l DAT_00304f6c,D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00303196:
	link.w A5,#-$0000008e
	movem.l A6/A3/A2/D7/D6/D5/D4/D3/D2,-(SP)
	movea.l ($000c,A5),A2
	movea.l ($0010,A5),A3
	moveq #$00000000,D5
	move.l ($0008,A5),DAT_00304f74
LAB_003031b0:
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	beq.w LAB_003034dc
	cmp.l #$00000025,D4
	bne.w LAB_003034a2
	clr.b (-$0005,A5)
	clr.b (-$0006,A5)
	clr.b (-$0007,A5)
	move.l #$0000007f,DAT_00304f70
	cmpi.b #$0000002a,(A2)
	bne.b LAB_003031ee
	addq.l #$00000001,A2
	move.b #$01,(-$0005,A5)
LAB_003031ee:
	move.b (A2),D0
	ext.w D0
	ext.l D0
	lea DAT_00304d27,A0
	btst.b #$00000002,($00,A0,D0.l)
	beq.b LAB_0030324a
	clr.l DAT_00304f70
LAB_00303208:
	move.b (A2),D0
	ext.w D0
	ext.l D0
	moveq #$0000000a,D1
	move.l D0,-(SP)
	move.l DAT_00304f70,D0
	jsr FUN_00304aa4
	move.l (SP)+,D1
	add.l D0,D1
	sub.l #$00000030,D1
	move.l D1,DAT_00304f70
	addq.l #$00000001,A2
	move.b (A2),D0
	ext.w D0
	ext.l D0
	lea DAT_00304d27,A0
	btst.b #$00000002,($00,A0,D0.l)
	bne.b LAB_00303208
	move.b #$01,(-$0007,A5)
LAB_0030324a:
	cmpi.b #$0000006c,(A2)
	bne.b LAB_00303258
	move.b #$01,(-$0006,A5)
	addq.l #$00000001,A2
LAB_00303258:
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D7
	bra.w LAB_00303450
LAB_00303268:
	moveq #$00000025,D4
	bra.w LAB_003034b8
LAB_0030326e:
	move.b #-$01,(-$0006,A5)
	bra.b LAB_0030327c
LAB_00303276:
	move.b #$01,(-$0006,A5)
LAB_0030327c:
	moveq #$0000000c,D4
	moveq #$0000000a,D6
	bra.b LAB_00303298
LAB_00303282:
	move.b #$01,(-$0006,A5)
LAB_00303288:
	moveq #$00000000,D4
	moveq #$00000010,D6
	bra.b LAB_00303298
LAB_0030328e:
	move.b #$01,(-$0006,A5)
LAB_00303294:
	moveq #$0000000e,D4
	moveq #$00000008,D6
LAB_00303298:
	jsr (FUN_00303510,PC)
	tst.l D0
	bne.w LAB_003034dc
	pea (-$0004,A5)
	move.l D6,-(SP)
	lea DAT_00304cfd,A0
	movea.l D4,A1
	adda.l A0,A1
	move.l A1,-(SP)
	lea s_ABCDEFabcdef9876543210_00304ce6,A0
	movea.l D4,A1
	adda.l A0,A1
	move.l A1,-(SP)
	jsr (FUN_00303558,PC)
	tst.l D0
	lea ($0010,SP),SP
	beq.w LAB_003034dc
	tst.b (-$0005,A5)
	bne.b LAB_00303304
	tst.b (-$0006,A5)
	bge.b LAB_003032e6
	movea.l A3,A0
	addq.l #$00000004,A3
	movea.l (A0),A1
	move.w (-$0002,A5),(A1)
	bra.b LAB_00303302
LAB_003032e6:
	tst.b (-$0006,A5)
	ble.b LAB_003032f8
	movea.l A3,A0
	addq.l #$00000004,A3
	movea.l (A0),A1
	move.l (-$0004,A5),(A1)
	bra.b LAB_00303302
LAB_003032f8:
	movea.l A3,A0
	addq.l #$00000004,A3
	movea.l (A0),A1
	move.l (-$0004,A5),(A1)
LAB_00303302:
	addq.l #$00000001,D5
LAB_00303304:
	bra.w LAB_003034a0
LAB_00303308:
	clr.b (-$0006,A5)
	cmpi.b #$0000005e,(A2)
	beq.b LAB_00303318
	cmpi.b #$0000007e,(A2)
	bne.b LAB_00303320
LAB_00303318:
	addq.l #$00000001,A2
	move.b #$01,(-$0006,A5)
LAB_00303320:
	lea (-$008e,A5),A0
	move.l A0,(-$000c,A5)
	bra.b LAB_00303334
LAB_0030332a:
	movea.l (-$000c,A5),A0
	addq.l #$00000001,(-$000c,A5)
	move.b D4,(A0)
LAB_00303334:
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	cmp.l #$0000005d,D0
	bne.b LAB_0030332a
	movea.l (-$000c,A5),A0
	clr.b (A0)
	bra.b LAB_0030336c
LAB_00303350:
	move.b #$01,(-$0006,A5)
	move.b #$20,(-$008e,A5)
	move.b #$09,(-$008d,A5)
	move.b #$0a,(-$008c,A5)
	clr.b (-$008b,A5)
LAB_0030336c:
	jsr (FUN_00303510,PC)
	tst.l D0
	bne.w LAB_003034dc
LAB_00303376:
	tst.b (-$0005,A5)
	bne.b LAB_00303384
	movea.l A3,A0
	addq.l #$00000004,A3
	move.l (A0),(-$000c,A5)
LAB_00303384:
	clr.b (-$0007,A5)
LAB_00303388:
	move.l DAT_00304f70,D0
	subq.l #$00000001,DAT_00304f70
	tst.l D0
	beq.b LAB_00303412
	clr.l -(SP)
	movea.l DAT_00304f74,A0
	jsr (A0)
	move.l D0,D4
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	beq.b LAB_00303412
	tst.b (-$0006,A5)
	beq.b LAB_003033ce
	move.l D4,-(SP)
	pea (-$008e,A5)
	jsr FUN_003037ec
	tst.l D0
	addq.w #$00000008,SP
	beq.b LAB_003033ca
	moveq #$00000001,D0
	bra.b LAB_003033cc
LAB_003033ca:
	moveq #$00000000,D0
LAB_003033cc:
	bra.b LAB_003033e6
LAB_003033ce:
	move.l D4,-(SP)
	pea (-$008e,A5)
	jsr FUN_003037ec
	tst.l D0
	addq.w #$00000008,SP
	bne.b LAB_003033e4
	moveq #$00000001,D0
	bra.b LAB_003033e6
LAB_003033e4:
	moveq #$00000000,D0
LAB_003033e6:
	beq.b LAB_003033f8
	pea $00000001
	movea.l DAT_00304f74,A0
	jsr (A0)
	addq.w #$00000004,SP
	bra.b LAB_00303412
LAB_003033f8:
	tst.b (-$0005,A5)
	bne.b LAB_00303408
	movea.l (-$000c,A5),A0
	addq.l #$00000001,(-$000c,A5)
	move.b D4,(A0)
LAB_00303408:
	move.b #$01,(-$0007,A5)
	bra.w LAB_00303388
LAB_00303412:
	tst.b (-$0007,A5)
	beq.w LAB_003034dc
	tst.b (-$0005,A5)
	bne.b LAB_00303430
	cmp.l #$00000063,D7
	beq.b LAB_0030342e
	movea.l (-$000c,A5),A0
	clr.b (A0)
LAB_0030342e:
	addq.l #$00000001,D5
LAB_00303430:
	bra.b LAB_003034a0
LAB_00303432:
	tst.b (-$0007,A5)
	bne.b LAB_00303442
	move.l #$00000001,DAT_00304f70
LAB_00303442:
	clr.b (-$008e,A5)
	move.b #$01,(-$0006,A5)
	bra.w LAB_00303376
LAB_00303450:
	sub.l #$00000025,D0
	beq.w LAB_00303268
	sub.l #$0000001f,D0
	beq.w LAB_00303276
	sub.l #$0000000b,D0
	beq.w LAB_0030328e
	sub.l #$00000009,D0
	beq.w LAB_00303282
	subq.l #$00000003,D0
	beq.w LAB_00303308
	subq.l #$00000008,D0
	beq.b LAB_00303432
	subq.l #$00000001,D0
	beq.w LAB_0030327c
	subq.l #$00000004,D0
	beq.w LAB_0030326e
	subq.l #$00000007,D0
	beq.w LAB_00303294
	subq.l #$00000004,D0
	beq.w LAB_00303350
	subq.l #$00000005,D0
	beq.w LAB_00303288
LAB_003034a0:
	bra.b LAB_003034d8
LAB_003034a2:
	lea DAT_00304d27,A0
	btst.b #$00000004,($00,A0,D4.l)
	beq.b LAB_003034b8
	bsr.b FUN_00303510
	tst.l D0
	bne.b LAB_003034dc
	bra.b LAB_003034d8
LAB_003034b8:
	clr.l -(SP)
	movea.l DAT_00304f74,A0
	jsr (A0)
	cmp.l D4,D0
	addq.w #$00000004,SP
	beq.b LAB_003034d8
	pea $00000001
	movea.l DAT_00304f74,A0
	jsr (A0)
	addq.w #$00000004,SP
	bra.b LAB_003034dc
LAB_003034d8:
	bra.w LAB_003031b0
LAB_003034dc:
	tst.l D5
	bne.b LAB_0030350c
	clr.l -(SP)
	movea.l DAT_00304f74,A0
	jsr (A0)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_003034fe
	moveq #-$00000001,D0
LAB_003034f6:
	movem.l (SP)+,D2/D3/D4/D5/D6/D7/A2/A3/A6
	unlk A5
	rts
LAB_003034fe:
	pea $00000001
	movea.l DAT_00304f74,A0
	jsr (A0)
	addq.w #$00000004,SP
LAB_0030350c:
	move.l D5,D0
	bra.b LAB_003034f6
FUN_00303510:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
LAB_00303518:
	clr.l -(SP)
	movea.l DAT_00304f74,A0
	jsr (A0)
	lea DAT_00304d27,A0
	btst.b #$00000004,($00,A0,D0.l)
	addq.w #$00000004,SP
	beq.b LAB_00303534
	bra.b LAB_00303518
LAB_00303534:
	pea $00000001
	movea.l DAT_00304f74,A0
	jsr (A0)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_00303554
	moveq #-$00000001,D0
LAB_0030354c:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00303554:
	moveq #$00000000,D0
	bra.b LAB_0030354c
FUN_00303558:
	link.w A5,#-$00000008
	movem.l A6/A2/D5/D4/D3/D2,-(SP)
	tst.l DAT_00304f70
	bgt.b LAB_00303572
	moveq #$00000000,D0
LAB_0030356a:
	movem.l (SP)+,D2/D3/D4/D5/A2/A6
	unlk A5
	rts
LAB_00303572:
	clr.l (-$0008,A5)
	moveq #$00000000,D5
	move.l D5,(-$0004,A5)
	clr.l -(SP)
	movea.l DAT_00304f74,A0
	jsr (A0)
	move.l D0,D4
	cmp.l #$0000002d,D0
	addq.w #$00000004,SP
	bne.b LAB_0030359e
	move.l #$00000001,(-$0008,A5)
	addq.l #$00000001,D5
	bra.b LAB_003035b8
LAB_0030359e:
	cmp.l #$0000002b,D4
	bne.b LAB_003035aa
	addq.l #$00000001,D5
	bra.b LAB_003035b8
LAB_003035aa:
	pea $00000001
	movea.l DAT_00304f74,A0
	jsr (A0)
	addq.w #$00000004,SP
LAB_003035b8:
	bra.b LAB_00303636
LAB_003035ba:
	clr.l -(SP)
	movea.l DAT_00304f74,A0
	jsr (A0)
	addq.w #$00000004,SP
	move.l D0,D4
	move.l D0,-(SP)
	move.l ($0008,A5),-(SP)
	jsr FUN_003037ec
	movea.l D0,A2
	tst.l D0
	addq.w #$00000008,SP
	bne.b LAB_0030360c
	cmpi.l #$00000010,($0010,A5)
	bne.b LAB_003035fc
	tst.l (-$0004,A5)
	bne.b LAB_003035fc
	cmp.l #$00000078,D4
	beq.b LAB_00303634
	cmp.l #$00000058,D4
	beq.b LAB_00303634
LAB_003035fc:
	pea $00000001
	movea.l DAT_00304f74,A0
	jsr (A0)
	addq.w #$00000004,SP
	bra.b LAB_00303640
LAB_0030360c:
	move.l ($0010,A5),D1
	move.l (-$0004,A5),D0
	jsr FUN_00304aa4
	move.l D0,(-$0004,A5)
	move.l A2,D0
	sub.l ($0008,A5),D0
	movea.l ($000c,A5),A0
	move.b ($00,A0,D0.l),D1
	ext.w D1
	ext.l D1
	add.l D1,(-$0004,A5)
LAB_00303634:
	addq.l #$00000001,D5
LAB_00303636:
	cmp.l DAT_00304f70,D5
	blt.w LAB_003035ba
LAB_00303640:
	tst.l (-$0008,A5)
	beq.b LAB_00303654
	movea.l ($0014,A5),A0
	move.l (-$0004,A5),D0
	neg.l D0
	move.l D0,(A0)
	bra.b LAB_0030365c
LAB_00303654:
	movea.l ($0014,A5),A0
	move.l (-$0004,A5),(A0)
LAB_0030365c:
	move.l D5,D0
	bra.w LAB_0030356a
FUN_00303662:
	link.w A5,#$00000000
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
LAB_0030366e:
	move.l A2,-(SP)
	jsr FUN_003036a6
	move.l D0,D4
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	beq.b LAB_003036a2
	move.l D4,D0
	bra.b LAB_0030369a
LAB_00303686:
	subq.l #$00000001,(A2)
	bset.b #$00000003,($000c,A2)
	moveq #-$00000001,D0
LAB_00303690:
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
LAB_00303698:
	bra.b LAB_0030366e
LAB_0030369a:
	tst.l D0
	beq.b LAB_00303698
	subq.l #$00000004,D0
	beq.b LAB_00303686
LAB_003036a2:
	move.l D4,D0
	bra.b LAB_00303690
FUN_003036a6:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	movea.l (A2),A0
	cmpa.l ($0004,A2),A0
	bcs.b LAB_003036c8
	move.l A2,-(SP)
	bsr.b FUN_003036da
	addq.w #$00000004,SP
LAB_003036c0:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_003036c8:
	movea.l (A2),A0
	addq.l #$00000001,(A2)
	move.b (A0),D0
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	bra.b LAB_003036c0
FUN_003036da:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	move.b ($000c,A2),D0
	and.b #$18,D0
	beq.b LAB_003036fa
	moveq #-$00000001,D0
LAB_003036f2:
	movem.l (SP)+,D2/D3/D4/A2/A3/A6
	unlk A5
	rts
LAB_003036fa:
	bclr.b #$00000002,($000c,A2)
	tst.l ($0008,A2)
	bne.b LAB_00303710
	move.l A2,-(SP)
	jsr FUN_003045aa
	addq.w #$00000004,SP
LAB_00303710:
	move.b ($000c,A2),D0
	ext.w D0
	ext.l D0
	btst.l #$00000007,D0
	beq.b LAB_0030375a
	lea DAT_00304da8,A0
	movea.l A0,A3
LAB_00303726:
	move.b ($000c,A3),D0
	ext.w D0
	ext.l D0
	and.l #$00000084,D0
	cmp.l #$00000084,D0
	bne.b LAB_0030374a
	pea -1
	move.l A3,-(SP)
	jsr FUN_00304470
	addq.w #$00000008,SP
LAB_0030374a:
	adda.l #$00000016,A3
	lea DAT_00304f60,A0
	cmpa.l A0,A3
	bcs.b LAB_00303726
LAB_0030375a:
	move.w ($0010,A2),D0
	ext.l D0
	move.l D0,-(SP)
	move.l ($0008,A2),-(SP)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_00303806
	move.l D0,D4
	tst.l D0
	lea ($000c,SP),SP
	bgt.b LAB_00303794
	tst.l D4
	bne.b LAB_00303788
	moveq #$00000008,D0
	bra.b LAB_0030378a
LAB_00303788:
	moveq #$00000010,D0
LAB_0030378a:
	or.b D0,($000c,A2)
	moveq #-$00000001,D0
	bra.w LAB_003036f2
LAB_00303794:
	move.l ($0008,A2),(A2)
	movea.l ($0008,A2),A0
	adda.l D4,A0
	move.l A0,($0004,A2)
	movea.l (A2),A0
	addq.l #$00000001,(A2)
	move.b (A0),D0
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	bra.w LAB_003036f2
FUN_003037b6:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($000c,A5),A2
	cmpi.l #-$00000001,($0008,A5)
	beq.b LAB_003037d4
	movea.l (A2),A0
	cmpa.l ($0008,A2),A0
	bhi.b LAB_003037de
LAB_003037d4:
	moveq #-$00000001,D0
LAB_003037d6:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_003037de:
	subq.l #$00000001,(A2)
	movea.l (A2),A0
	move.b ($000b,A5),(A0)
	move.l ($0008,A5),D0
	bra.b LAB_003037d6
FUN_003037ec:
	movea.l ($0004,SP),A0
	move.l ($0008,SP),D0
LAB_003037f4:
	move.b (A0)+,D1
	beq.b LAB_00303802
	cmp.b D0,D1
	bne.b LAB_003037f4
	move.l A0,D0
	subq.l #$00000001,D0
	rts
LAB_00303802:
	moveq #$00000000,D0
	rts
FUN_00303806:
	link.w A5,#$00000000
	movem.l A6/A2/D5/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	jsr FUN_0030483c
	moveq #$00000006,D1
	move.l D4,D0
	jsr FUN_00304aa4
	movea.l D0,A2
	adda.l DAT_003050f0,A2
	tst.l D4
	blt.b LAB_0030383e
	move.w DAT_00304f60,D0
	ext.l D0
	cmp.l D0,D4
	bge.b LAB_0030383e
	tst.l (A2)
	bne.b LAB_00303852
LAB_0030383e:
	move.l #$00000002,DAT_003050f4
	moveq #-$00000001,D0
LAB_0030384a:
	movem.l (SP)+,D2/D3/D4/D5/A2/A6
	unlk A5
	rts
LAB_00303852:
	move.w ($0004,A2),D0
	ext.l D0
	and.l #$00000003,D0
	cmp.l #$00000001,D0
	bne.b LAB_00303874
	move.l #$00000005,DAT_003050f4
	moveq #-$00000001,D0
	bra.b LAB_0030384a
LAB_00303874:
	move.l ($0010,A5),-(SP)
	move.l ($000c,A5),-(SP)
	move.l (A2),-(SP)
	jsr _Read
	move.l D0,D5
	cmp.l #-$00000001,D0
	lea ($000c,SP),SP
	bne.b LAB_003038a2
	jsr _IoErr
	move.l D0,DAT_003050f4
	moveq #-$00000001,D0
	bra.b LAB_0030384a
LAB_003038a2:
	move.l D5,D0
	bra.b LAB_0030384a
FUN_003038a6:
	bsr.b FUN_00303924
	lea DAT_00304f6c,A1
	lea DAT_00304f6c,A2
	cmpa.l A1,A2
	bne.b LAB_003038c6
	move.w #$0075,D1
	bmi.b LAB_003038c6
	moveq #$00000000,D2
LAB_003038c0:
	move.l D2,(A1)+
	dbf D1,LAB_003038c0
LAB_003038c6:
	move.l SP,DAT_003050f8
	movea.l $00000004,A6
	move.l A6,_SysBase
	movem.l A0/D0,-(SP)
	btst.b #$00000004,($0129,A6)
	beq.b LAB_003038f2
	lea (LAB_003038ec,PC),A5
	jsr (-$001e,A6)
	bra.b LAB_003038f2
LAB_003038ec:
	clr.l -(SP)
	frestore (SP)+
	rte
LAB_003038f2:
	lea (s_dos_library_00303918,PC),A1
	jsr (-$0198,A6)
	move.l D0,_DOSBase
	bne.b LAB_0030390e
	move.l #$00038007,D7
	jsr (-$006c,A6)
	bra.b LAB_00303914
LAB_0030390e:
	jsr FUN_0030392c
LAB_00303914:
	addq.w #$00000008,SP
	rts
s_dos_library_00303918:
	dc.b "dos.library",0
FUN_00303924:
	lea FUN_00303924,A4
	rts
FUN_0030392c:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	pea $00010000
	move.w DAT_00304f60,D0
	muls.w #$0006,D0
	move.l D0,-(SP)
	jsr _AllocMem
	move.l D0,DAT_003050f0
	addq.w #$00000008,SP
	bne.b LAB_0030396e
	clr.l -(SP)
	pea $00010000
	jsr _Alert
	addq.w #$00000008,SP
	movea.l DAT_003050f8,SP
	rts
LAB_0030396e:
	movea.l DAT_003050f0,A0
	clr.w ($0004,A0)
	movea.l DAT_003050f0,A0
	move.w #$0001,($0010,A0)
	movea.l DAT_003050f0,A0
	move.w #$0001,($000a,A0)
	movea.l DAT_003050f8,A0
	move.l DAT_003050f8,D0
	sub.l ($0004,A0),D0
	addq.l #$00000008,D0
	move.l D0,DAT_00305104
	movea.l DAT_00305104,A0
	move.l #$4d414e58,(A0)
	clr.l -(SP)
	jsr _FindTask
	movea.l D0,A2
	tst.l ($00ac,A2)
	addq.w #$00000004,SP
	beq.b LAB_003039fe
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	move.l A2,-(SP)
	jsr FUN_00303ab6
	move.l #$00000001,DAT_00305108
	movea.l DAT_003050f0,A0
	ori.w #-$00008000,($0004,A0)
	movea.l DAT_003050f0,A0
	ori.w #-$00008000,($000a,A0)
	lea ($000c,SP),SP
	bra.b LAB_00303a54
LAB_003039fe:
	pea ($005c,A2)
	jsr _WaitPort
	pea ($005c,A2)
	jsr _GetMsg
	move.l D0,DAT_0030510c
	movea.l DAT_0030510c,A0
	tst.l ($0024,A0)
	addq.w #$00000008,SP
	beq.b LAB_00303a3a
	movea.l DAT_0030510c,A0
	movea.l ($0024,A0),A1
	move.l (A1),-(SP)
	jsr _CurrentDir
	addq.w #$00000004,SP
LAB_00303a3a:
	move.l DAT_0030510c,-(SP)
	move.l A2,-(SP)
	jsr FUN_00303d04
	move.l DAT_0030510c,DAT_00305110
	addq.w #$00000008,SP
LAB_00303a54:
	jsr _Input
	movea.l DAT_003050f0,A0
	move.l D0,(A0)
	jsr _Output
	movea.l DAT_003050f0,A0
	move.l D0,($0006,A0)
	beq.b LAB_00303a8e
	pea $000003ed
	pea (DAT_00303ab4,PC)
	jsr _Open
	movea.l DAT_003050f0,A0
	move.l D0,($000c,A0)
	addq.w #$00000008,SP
LAB_00303a8e:
	move.l DAT_00305110,-(SP)
	move.l DAT_00305114,-(SP)
	jsr FUN_00300004
	clr.l -(SP)
	jsr FUN_003048b2
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
DAT_00303ab4:
; Unknown data at address 00303ab4.
	dc.b $2a
; Unknown data at address 00303ab5.
	dc.b $00
FUN_00303ab6:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D5/D4/D3/D2,-(SP)
	movea.l ($0010,A5),A2
	movea.l ($0008,A5),A0
	tst.l ($00ac,A0)
	beq.b LAB_00303ae4
	movea.l ($0008,A5),A0
	move.l ($00ac,A0),D0
	asl.l #$00000002,D0
	move.l D0,D4
	movea.l D4,A0
	move.l ($0010,A0),D0
	asl.l #$00000002,D0
	movea.l D0,A3
	bra.b LAB_00303aea
LAB_00303ae4:
	movea.l DAT_00304f62,A3
LAB_00303aea:
	move.b (A3),D0
	ext.w D0
	ext.l D0
	add.l ($000c,A5),D0
	addq.l #$00000002,D0
	move.l D0,DAT_00305118
	clr.l -(SP)
	move.l DAT_00305118,-(SP)
	jsr _AllocMem
	move.l D0,DAT_0030511c
	addq.w #$00000008,SP
	bne.b LAB_00303b1c
LAB_00303b14:
	movem.l (SP)+,D2/D3/D4/D5/A2/A3/A6
	unlk A5
	rts
LAB_00303b1c:
	move.b (A3),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	move.l D5,-(SP)
	movea.l A3,A0
	addq.l #$00000001,A0
	move.l A0,-(SP)
	move.l DAT_0030511c,-(SP)
	jsr FUN_00303ce2
	movea.l DAT_0030511c,A0
	adda.l D5,A0
	lea (DAT_00303cb6,PC),A1
LAB_00303b44:
	move.b (A1)+,(A0)+
	bne.b LAB_00303b44
	move.l ($000c,A5),-(SP)
	move.l A2,-(SP)
	move.l DAT_0030511c,-(SP)
	jsr FUN_00303cbe
	movea.l DAT_0030511c,A0
	clr.b ($00,A0,D5.l)
	move.l #$00000001,DAT_00305114
	movea.l DAT_0030511c,A0
	adda.l D5,A0
	movea.l A0,A3
	addq.l #$00000001,A3
	movea.l A3,A2
	lea ($0018,SP),SP
LAB_00303b80:
	move.b (A3),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	cmp.l #$00000020,D0
	beq.b LAB_00303bb0
	cmp.l #$00000009,D5
	beq.b LAB_00303bb0
	cmp.l #$0000000c,D5
	beq.b LAB_00303bb0
	cmp.l #$0000000d,D5
	beq.b LAB_00303bb0
	cmp.l #$0000000a,D5
	bne.b LAB_00303bb4
LAB_00303bb0:
	addq.l #$00000001,A3
	bra.b LAB_00303b80
LAB_00303bb4:
	cmpi.b #$00000020,(A3)
	blt.w LAB_00303c48
	cmpi.b #$00000022,(A3)
	bne.b LAB_00303bf4
	addq.l #$00000001,A3
LAB_00303bc4:
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	beq.b LAB_00303bf2
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b D5,(A0)
	cmp.l #$00000022,D5
	bne.b LAB_00303bf0
	cmpi.b #$00000022,(A3)
	bne.b LAB_00303bea
	addq.l #$00000001,A3
	bra.b LAB_00303bf0
LAB_00303bea:
	clr.b (-$0001,A2)
	bra.b LAB_00303bf2
LAB_00303bf0:
	bra.b LAB_00303bc4
LAB_00303bf2:
	bra.b LAB_00303c38
LAB_00303bf4:
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	beq.b LAB_00303c32
	cmp.l #$00000020,D5
	beq.b LAB_00303c32
	cmp.l #$00000009,D5
	beq.b LAB_00303c32
	cmp.l #$0000000c,D5
	beq.b LAB_00303c32
	cmp.l #$0000000d,D5
	beq.b LAB_00303c32
	cmp.l #$0000000a,D5
	beq.b LAB_00303c32
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b D5,(A0)
	bra.b LAB_00303bf4
LAB_00303c32:
	movea.l A2,A0
	addq.l #$00000001,A2
	clr.b (A0)
LAB_00303c38:
	tst.l D5
	bne.b LAB_00303c3e
	subq.l #$00000001,A3
LAB_00303c3e:
	addq.l #$00000001,DAT_00305114
	bra.w LAB_00303b80
LAB_00303c48:
	clr.b (A2)
	clr.l -(SP)
	move.l DAT_00305114,D0
	addq.l #$00000001,D0
	asl.l #$00000002,D0
	move.l D0,-(SP)
	jsr _AllocMem
	move.l D0,DAT_00305110
	addq.w #$00000008,SP
	bne.b LAB_00303c72
	clr.l DAT_00305114
	bra.w LAB_00303b14
LAB_00303c72:
	moveq #$00000000,D5
	movea.l DAT_0030511c,A3
	bra.b LAB_00303c9c
LAB_00303c7c:
	move.l D5,D0
	asl.l #$00000002,D0
	movea.l DAT_00305110,A0
	move.l A3,($00,A0,D0.l)
	movea.l A3,A0
	move.l A0,D0
LAB_00303c8e:
	tst.b (A0)+
	bne.b LAB_00303c8e
	suba.l D0,A0
	subq.l #$00000001,A0
	addq.l #$00000001,A0
	adda.l A0,A3
	addq.l #$00000001,D5
LAB_00303c9c:
	cmp.l DAT_00305114,D5
	blt.b LAB_00303c7c
	move.l D5,D0
	asl.l #$00000002,D0
	movea.l DAT_00305110,A0
	clr.l ($00,A0,D0.l)
	bra.w LAB_00303b14
DAT_00303cb6:
	; undefined1
	dc.b $20
DAT_00303cb7:
	; undefined1
	dc.b $00
FUN_00303cb8:
	move.w #$7fff,D0
	bra.b LAB_00303cc2
FUN_00303cbe:
	move.w ($000e,SP),D0
LAB_00303cc2:
	movea.l ($0004,SP),A0
LAB_00303cc6:
	tst.b (A0)+
	bne.b LAB_00303cc6
	subq.w #$00000001,A0
	movea.l ($0008,SP),A1
	subq.w #$00000001,D0
LAB_00303cd2:
	move.b (A1)+,(A0)+
	dbeq D0,LAB_00303cd2
	beq.b LAB_00303cdc
	clr.b (A0)
LAB_00303cdc:
	move.l ($0004,SP),D0
	rts
FUN_00303ce2:
	movem.l ($0004,SP),A0/A1
	move.l A0,D0
	move.l ($000c,SP),D1
	bra.b LAB_00303cf2
LAB_00303cf0:
	move.b (A1)+,(A0)+
LAB_00303cf2:
	dbeq D1,LAB_00303cf0
	beq.b LAB_00303cfe
	addq.w #$00000001,D1
	bra.b LAB_00303cfe
LAB_00303cfc:
	clr.b (A0)+
LAB_00303cfe:
	dbf D1,LAB_00303cfc
	rts
FUN_00303d04:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D6/D5/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	clr.l -(SP)
	pea (s_icon_library_00303db8,PC)
	jsr _OpenLibrary
	move.l D0,_IconBase
	addq.w #$00000008,SP
	bne.b LAB_00303d2e
LAB_00303d26:
	movem.l (SP)+,D2/D3/D4/D5/D6/A2/A3/A6
	unlk A5
	rts
LAB_00303d2e:
	movea.l ($000c,A5),A0
	movea.l ($0024,A0),A1
	move.l ($0004,A1),-(SP)
	jsr _GetDiskObject
	move.l D0,D4
	addq.w #$00000004,SP
	beq.b LAB_00303da0
	pea (s_WINDOW_00303dc5,PC)
	movea.l D4,A0
	move.l ($0036,A0),-(SP)
	jsr _FindToolType
	movea.l D0,A3
	tst.l D0
	addq.w #$00000008,SP
	beq.b LAB_00303d96
	pea $000003ed
	move.l A3,-(SP)
	jsr _Open
	move.l D0,D6
	addq.w #$00000008,SP
	beq.b LAB_00303d96
	move.l D6,D0
	asl.l #$00000002,D0
	move.l D0,D5
	movea.l D5,A0
	move.l ($0008,A0),($00a4,A2)
	move.l D6,($009c,A2)
	pea $000003ed
	pea (DAT_00303dcc,PC)
	jsr _Open
	move.l D0,($00a0,A2)
	addq.w #$00000008,SP
LAB_00303d96:
	move.l D4,-(SP)
	jsr _FreeDiskObject
	addq.w #$00000004,SP
LAB_00303da0:
	move.l _IconBase,-(SP)
	jsr _CloseLibraryThunk
	clr.l _IconBase
	addq.w #$00000004,SP
	bra.w LAB_00303d26
s_icon_library_00303db8:
	dc.b "icon.library",0
s_WINDOW_00303dc5:
	dc.b "WINDOW",0
DAT_00303dcc:
; Unknown data at address 00303dcc.
	dc.b $2a
; Unknown data at address 00303dcd.
	dc.b $00
FUN_00303dce:
	link.w A5,#$00000000
	movem.l A6/D4/D3/D2,-(SP)
	move.l ($0008,A5),DAT_00304f78
	pea ($0010,A5)
	move.l ($000c,A5),-(SP)
	pea (LAB_00303e08,PC)
	jsr FUN_00303ee8
	move.l D0,D4
	movea.l DAT_00304f78,A0
	clr.b (A0)
	move.l D4,D0
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/D4/A6
	unlk A5
	rts
LAB_00303e08:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	movea.l DAT_00304f78,A0
	addq.l #$00000001,DAT_00304f78
	move.b ($000b,A5),D0
	move.b D0,(A0)
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00303e34:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	pea ($000c,A5)
	move.l ($0008,A5),-(SP)
	pea LAB_003042fc
	jsr FUN_00303ee8
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00303e5c:
	link.w A5,#$00000000
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0010,A5),A2
	cmpi.l #$00000004,($0014,A5)
	bne.b LAB_00303e7a
	movea.l ($0008,A5),A0
	move.l (A0),D4
	bra.b LAB_00303e8e
LAB_00303e7a:
	tst.l ($000c,A5)
	ble.b LAB_00303e88
	movea.l ($0008,A5),A0
	move.l (A0),D4
	bra.b LAB_00303e8e
LAB_00303e88:
	movea.l ($0008,A5),A0
	move.l (A0),D4
LAB_00303e8e:
	clr.l ($0014,A5)
	tst.l ($000c,A5)
	bge.b LAB_00303eaa
	neg.l ($000c,A5)
	tst.l D4
	bge.b LAB_00303eaa
	neg.l D4
	move.l #$00000001,($0014,A5)
LAB_00303eaa:
	move.l ($000c,A5),D1
	move.l D4,D0
	jsr FUN_00304296
	lea s_0123456789abcdef_00304d14,A0
	subq.l #$00000001,A2
	move.b ($00,A0,D0.l),(A2)
	move.l ($000c,A5),D1
	move.l D4,D0
	jsr FUN_003042a2
	move.l D0,D4
	bne.b LAB_00303eaa
	tst.l ($0014,A5)
	beq.b LAB_00303ede
	subq.l #$00000001,A2
	move.b #$2d,(A2)
LAB_00303ede:
	move.l A2,D0
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
FUN_00303ee8:
	link.w A5,#-$000000ec
	movem.l A6/A3/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	movea.l ($000c,A5),A3
	clr.l (-$0008,A5)
	move.l ($0010,A5),(-$0004,A5)
LAB_00303f02:
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	beq.w LAB_0030424c
	cmp.l #$00000025,D4
	bne.w LAB_00304230
	clr.b (-$00de,A5)
	move.l #$00000001,(-$000c,A5)
	move.l #$00000020,(-$0010,A5)
	move.l #$00002710,(-$0014,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	cmp.l #$0000002d,D0
	bne.b LAB_00303f5c
	clr.l (-$000c,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00303f5c:
	cmp.l #$00000030,D4
	bne.b LAB_00303f78
	move.l #$00000030,(-$0010,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00303f78:
	cmp.l #$0000002a,D4
	bne.b LAB_00303f9a
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	move.l (A0),(-$0018,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	bra.b LAB_00303fd2
LAB_00303f9a:
	clr.l (-$0018,A5)
	bra.b LAB_00303fc4
LAB_00303fa0:
	moveq #$0000000a,D1
	move.l (-$0018,A5),D0
	jsr FUN_00304aa4
	add.l D4,D0
	sub.l #$00000030,D0
	move.l D0,(-$0018,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00303fc4:
	lea DAT_00304d27,A0
	btst.b #$00000002,($00,A0,D4.l)
	bne.b LAB_00303fa0
LAB_00303fd2:
	cmp.l #$0000002e,D4
	bne.b LAB_00304040
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	cmp.l #$0000002a,D0
	bne.b LAB_00304008
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	move.l (A0),(-$0014,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	bra.b LAB_00304040
LAB_00304008:
	clr.l (-$0014,A5)
	bra.b LAB_00304032
LAB_0030400e:
	moveq #$0000000a,D1
	move.l (-$0014,A5),D0
	jsr FUN_00304aa4
	add.l D4,D0
	sub.l #$00000030,D0
	move.l D0,(-$0014,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00304032:
	lea DAT_00304d27,A0
	btst.b #$00000002,($00,A0,D4.l)
	bne.b LAB_0030400e
LAB_00304040:
	move.l #$00000004,(-$001c,A5)
	cmp.l #$0000006c,D4
	bne.b LAB_00304066
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	move.l #$00000004,(-$001c,A5)
	bra.b LAB_0030407a
LAB_00304066:
	cmp.l #$00000068,D4
	bne.b LAB_0030407a
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_0030407a:
	move.l D4,D0
	bra.w LAB_00304100
LAB_00304080:
	move.l #$00000008,(-$0020,A5)
	bra.b LAB_003040a6
LAB_0030408a:
	move.l #$0000000a,(-$0020,A5)
	bra.b LAB_003040a6
LAB_00304094:
	move.l #$00000010,(-$0020,A5)
	bra.b LAB_003040a6
LAB_0030409e:
	move.l #-$0000000a,(-$0020,A5)
LAB_003040a6:
	move.l (-$001c,A5),-(SP)
	pea (-$00de,A5)
	move.l (-$0020,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00303e5c,PC)
	move.l D0,(-$0024,A5)
	move.l (-$001c,A5),D0
	add.l D0,(-$0004,A5)
	lea ($0010,SP),SP
	bra.b LAB_00304128
LAB_003040cc:
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	movea.l (A0),A1
	move.l A1,(-$0024,A5)
	move.l A1,D0
LAB_003040dc:
	tst.b (A1)+
	bne.b LAB_003040dc
	suba.l D0,A1
	subq.l #$00000001,A1
	move.l A1,(-$001c,A5)
	bra.b LAB_00304134
LAB_003040ea:
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	move.l (A0),D4
LAB_003040f4:
	lea (-$00df,A5),A0
	move.l A0,(-$0024,A5)
	move.b D4,(A0)
	bra.b LAB_00304128
LAB_00304100:
	sub.l #$00000063,D0
	beq.b LAB_003040ea
	subq.l #$00000001,D0
	beq.b LAB_0030409e
	sub.l #$0000000b,D0
	beq.w LAB_00304080
	subq.l #$00000004,D0
	beq.b LAB_003040cc
	subq.l #$00000002,D0
	beq.w LAB_0030408a
	subq.l #$00000003,D0
	beq.w LAB_00304094
	bra.b LAB_003040f4
LAB_00304128:
	lea (-$00de,A5),A0
	suba.l (-$0024,A5),A0
	move.l A0,(-$001c,A5)
LAB_00304134:
	move.l (-$001c,A5),D0
	cmp.l (-$0014,A5),D0
	ble.b LAB_00304144
	move.l (-$0014,A5),(-$001c,A5)
LAB_00304144:
	tst.l (-$000c,A5)
	beq.b LAB_003041ba
	movea.l (-$0024,A5),A0
	cmpi.b #$0000002d,(A0)
	beq.b LAB_0030415e
	movea.l (-$0024,A5),A0
	cmpi.b #$0000002b,(A0)
	bne.b LAB_00304192
LAB_0030415e:
	cmpi.l #$00000030,(-$0010,A5)
	bne.b LAB_00304192
	subq.l #$00000001,(-$0018,A5)
	movea.l (-$0024,A5),A0
	addq.l #$00000001,(-$0024,A5)
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_00304192
	moveq #-$00000001,D0
LAB_0030418a:
	movem.l (SP)+,D2/D3/D4/A2/A3/A6
	unlk A5
	rts
LAB_00304192:
	bra.b LAB_003041ac
LAB_00304194:
	move.l (-$0010,A5),-(SP)
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_003041a8
	moveq #-$00000001,D0
	bra.b LAB_0030418a
LAB_003041a8:
	addq.l #$00000001,(-$0008,A5)
LAB_003041ac:
	move.l (-$0018,A5),D0
	subq.l #$00000001,(-$0018,A5)
	cmp.l (-$001c,A5),D0
	bgt.b LAB_00304194
LAB_003041ba:
	clr.l (-$0020,A5)
	bra.b LAB_003041e4
LAB_003041c0:
	movea.l (-$0024,A5),A0
	addq.l #$00000001,(-$0024,A5)
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_003041e0
	moveq #-$00000001,D0
	bra.b LAB_0030418a
LAB_003041e0:
	addq.l #$00000001,(-$0020,A5)
LAB_003041e4:
	movea.l (-$0024,A5),A0
	tst.b (A0)
	beq.b LAB_003041f6
	move.l (-$0020,A5),D0
	cmp.l (-$0014,A5),D0
	blt.b LAB_003041c0
LAB_003041f6:
	move.l (-$0020,A5),D0
	add.l D0,(-$0008,A5)
	tst.l (-$000c,A5)
	bne.b LAB_0030422e
	bra.b LAB_00304220
LAB_00304206:
	pea $00000020
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_0030421c
	moveq #-$00000001,D0
	bra.w LAB_0030418a
LAB_0030421c:
	addq.l #$00000001,(-$0008,A5)
LAB_00304220:
	move.l (-$0018,A5),D0
	subq.l #$00000001,(-$0018,A5)
	cmp.l (-$001c,A5),D0
	bgt.b LAB_00304206
LAB_0030422e:
	bra.b LAB_00304248
LAB_00304230:
	move.l D4,-(SP)
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_00304244
	moveq #-$00000001,D0
	bra.w LAB_0030418a
LAB_00304244:
	addq.l #$00000001,(-$0008,A5)
LAB_00304248:
	bra.w LAB_00303f02
LAB_0030424c:
	move.l (-$0008,A5),D0
	bra.w LAB_0030418a
; Unknown data at address 00304254.
	dc.b $48
; Unknown data at address 00304255.
	dc.b $e7
; Unknown data at address 00304256.
	dc.b $48
; Unknown data at address 00304257.
	dc.b $00
; Unknown data at address 00304258.
	dc.b $42
; Unknown data at address 00304259.
	dc.b $84
; Unknown data at address 0030425a.
	dc.b $4a
; Unknown data at address 0030425b.
	dc.b $80
; Unknown data at address 0030425c.
	dc.b $6a
; Unknown data at address 0030425d.
	dc.b $04
; Unknown data at address 0030425e.
	dc.b $44
; Unknown data at address 0030425f.
	dc.b $80
; Unknown data at address 00304260.
	dc.b $52
; Unknown data at address 00304261.
	dc.b $44
; Unknown data at address 00304262.
	dc.b $4a
; Unknown data at address 00304263.
	dc.b $81
; Unknown data at address 00304264.
	dc.b $6a
; Unknown data at address 00304265.
	dc.b $06
; Unknown data at address 00304266.
	dc.b $44
; Unknown data at address 00304267.
	dc.b $81
; Unknown data at address 00304268.
	dc.b $0a
; Unknown data at address 00304269.
	dc.b $44
; Unknown data at address 0030426a.
	dc.b $00
; Unknown data at address 0030426b.
	dc.b $01
; Unknown data at address 0030426c.
	dc.b $61
; Unknown data at address 0030426d.
	dc.b $3e
; Unknown data at address 0030426e.
	dc.b $4a
; Unknown data at address 0030426f.
	dc.b $44
; Unknown data at address 00304270.
	dc.b $67
; Unknown data at address 00304271.
	dc.b $02
; Unknown data at address 00304272.
	dc.b $44
; Unknown data at address 00304273.
	dc.b $80
; Unknown data at address 00304274.
	dc.b $4c
; Unknown data at address 00304275.
	dc.b $df
; Unknown data at address 00304276.
	dc.b $00
; Unknown data at address 00304277.
	dc.b $12
; Unknown data at address 00304278.
	dc.b $4a
; Unknown data at address 00304279.
	dc.b $80
; Unknown data at address 0030427a.
	dc.b $4e
; Unknown data at address 0030427b.
	dc.b $75
; Unknown data at address 0030427c.
	dc.b $48
; Unknown data at address 0030427d.
	dc.b $e7
; Unknown data at address 0030427e.
	dc.b $48
; Unknown data at address 0030427f.
	dc.b $00
; Unknown data at address 00304280.
	dc.b $42
; Unknown data at address 00304281.
	dc.b $84
; Unknown data at address 00304282.
	dc.b $4a
; Unknown data at address 00304283.
	dc.b $80
; Unknown data at address 00304284.
	dc.b $6a
; Unknown data at address 00304285.
	dc.b $04
; Unknown data at address 00304286.
	dc.b $44
; Unknown data at address 00304287.
	dc.b $80
; Unknown data at address 00304288.
	dc.b $52
; Unknown data at address 00304289.
	dc.b $44
; Unknown data at address 0030428a.
	dc.b $4a
; Unknown data at address 0030428b.
	dc.b $81
; Unknown data at address 0030428c.
	dc.b $6a
; Unknown data at address 0030428d.
	dc.b $02
; Unknown data at address 0030428e.
	dc.b $44
; Unknown data at address 0030428f.
	dc.b $81
; Unknown data at address 00304290.
	dc.b $61
; Unknown data at address 00304291.
	dc.b $1a
; Unknown data at address 00304292.
	dc.b $20
; Unknown data at address 00304293.
	dc.b $01
; Unknown data at address 00304294.
	dc.b $60
; Unknown data at address 00304295.
	dc.b $d8
FUN_00304296:
	move.l D1,-(SP)
	bsr.b FUN_003042ac
	move.l D1,D0
	move.l (SP)+,D1
	tst.l D0
	rts
FUN_003042a2:
	move.l D1,-(SP)
	bsr.b FUN_003042ac
	move.l (SP)+,D1
	tst.l D0
	rts
FUN_003042ac:
	movem.l D3/D2,-(SP)
	swap D1
	tst.w D1
	bne.b LAB_003042d6
	swap D1
	move.w D1,D3
	move.w D0,D2
	clr.w D0
	swap D0
	divu.w D3,D0
	move.l D0,D1
	swap D0
	move.w D2,D1
	divu.w D3,D1
	move.w D1,D0
	clr.w D1
	swap D1
	movem.l (SP)+,D2/D3
	rts
LAB_003042d6:
	swap D1
	move.l D1,D3
	move.l D0,D1
	clr.w D1
	swap D1
	swap D0
	clr.w D0
	moveq #$0000000f,D2
LAB_003042e6:
	add.l D0,D0
	addx.l D1,D1
	cmp.l D1,D3
	bhi.b LAB_003042f2
	sub.l D3,D1
	addq.w #$00000001,D0
LAB_003042f2:
	dbf D2,LAB_003042e6
	movem.l (SP)+,D2/D3
	rts
LAB_003042fc:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	pea DAT_00304dbe
	move.l ($0008,A5),-(SP)
	jsr FUN_0030431e
	addq.w #$00000008,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_0030431e:
	link.w A5,#$00000000
	movem.l A6/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	move.l ($000c,A5),-(SP)
	move.l D4,-(SP)
	jsr FUN_0030436c
	cmp.l #$0000000a,D4
	addq.w #$00000008,SP
	bne.b LAB_0030436a
	movea.l ($000c,A5),A0
	move.b ($000c,A0),D0
	ext.w D0
	ext.l D0
	btst.l #$00000007,D0
	beq.b LAB_0030436a
	pea -1
	move.l ($000c,A5),-(SP)
	jsr FUN_00304470
	addq.w #$00000008,SP
LAB_00304362:
	movem.l (SP)+,D2/D3/D4/A6
	unlk A5
	rts
LAB_0030436a:
	bra.b LAB_00304362
FUN_0030436c:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($000c,A5),A2
	movea.l (A2),A0
	cmpa.l ($0004,A2),A0
	bcs.b LAB_0030439c
	move.l ($0008,A5),D0
	and.l #$000000ff,D0
	move.l D0,-(SP)
	move.l A2,-(SP)
	jsr (FUN_00304470,PC)
	addq.w #$00000008,SP
LAB_00304394:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_0030439c:
	movea.l (A2),A0
	addq.l #$00000001,(A2)
	move.b ($000b,A5),D0
	move.b D0,(A0)
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	bra.b LAB_00304394
LAB_003043b2:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	lea DAT_00304da8,A0
	movea.l A0,A2
LAB_003043c2:
	movea.l A2,A0
	adda.l #$00000016,A2
	move.l A0,-(SP)
	bsr.b FUN_003043e2
	addq.w #$00000004,SP
	lea DAT_00304f60,A0
	cmpa.l A0,A2
	bcs.b LAB_003043c2
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
FUN_003043e2:
	link.w A5,#$00000000
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	moveq #$00000000,D4
	move.l A2,D0
	bne.b LAB_003043fe
	moveq #-$00000001,D0
LAB_003043f6:
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
LAB_003043fe:
	tst.b ($000c,A2)
	beq.b LAB_0030445e
	btst.b #$00000002,($000c,A2)
	beq.b LAB_00304418
	pea -1
	move.l A2,-(SP)
	bsr.b FUN_00304470
	move.l D0,D4
	addq.w #$00000008,SP
LAB_00304418:
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_00304a44
	or.l D0,D4
	btst.b #$00000001,($000c,A2)
	addq.w #$00000004,SP
	beq.b LAB_00304440
	move.l ($0008,A2),-(SP)
	jsr FUN_003046ae
	addq.w #$00000004,SP
LAB_00304440:
	btst.b #$00000005,($000c,A2)
	beq.b LAB_0030445e
	move.l ($0012,A2),-(SP)
	jsr FUN_00304774
	move.l ($0012,A2),-(SP)
	jsr FUN_003046ae
	addq.w #$00000008,SP
LAB_0030445e:
	clr.l (A2)
	clr.l ($0004,A2)
	clr.l ($0008,A2)
	clr.b ($000c,A2)
	move.l D4,D0
	bra.b LAB_003043f6
FUN_00304470:
	link.w A5,#-$00000002
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	lea (LAB_003043b2,PC),A0
	move.l A0,DAT_00305124
	btst.b #$00000004,($000c,A2)
	beq.b LAB_00304498
	moveq #-$00000001,D0
LAB_00304490:
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
LAB_00304498:
	btst.b #$00000002,($000c,A2)
	beq.b LAB_003044d6
	movea.l (A2),A0
	suba.l ($0008,A2),A0
	move.l A0,D4
	move.l D4,-(SP)
	move.l ($0008,A2),-(SP)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_003047a6
	cmp.l D4,D0
	lea ($000c,SP),SP
	beq.b LAB_003044d6
LAB_003044c6:
	bset.b #$00000004,($000c,A2)
	clr.l (A2)
	clr.l ($0004,A2)
	moveq #-$00000001,D0
	bra.b LAB_00304490
LAB_003044d6:
	cmpi.l #-$00000001,($000c,A5)
	bne.b LAB_003044f0
	bclr.b #$00000002,($000c,A2)
	clr.l (A2)
	clr.l ($0004,A2)
	moveq #$00000000,D0
	bra.b LAB_00304490
LAB_003044f0:
	tst.l ($0008,A2)
	bne.b LAB_00304500
	move.l A2,-(SP)
	jsr FUN_003045aa
	addq.w #$00000004,SP
LAB_00304500:
	cmpi.w #$00000001,($0010,A2)
	bne.b LAB_0030453a
	move.b ($000f,A5),(-$0001,A5)
	pea $00000001
	pea (-$0001,A5)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_003047a6
	cmp.l #$00000001,D0
	lea ($000c,SP),SP
	bne.b LAB_003044c6
	move.l ($000c,A5),D0
	bra.w LAB_00304490
LAB_0030453a:
	move.l ($0008,A2),(A2)
	move.w ($0010,A2),D0
	ext.l D0
	add.l ($0008,A2),D0
	move.l D0,($0004,A2)
	bset.b #$00000002,($000c,A2)
	movea.l (A2),A0
	addq.l #$00000001,(A2)
	move.b ($000f,A5),D0
	move.b D0,(A0)
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	bra.w LAB_00304490
; Unknown data at address 0030456a.
	dc.b $4e
; Unknown data at address 0030456b.
	dc.b $55
; Unknown data at address 0030456c.
	dc.b $00
; Unknown data at address 0030456d.
	dc.b $00
; Unknown data at address 0030456e.
	dc.b $48
; Unknown data at address 0030456f.
	dc.b $e7
; Unknown data at address 00304570.
	dc.b $30
; Unknown data at address 00304571.
	dc.b $22
; Unknown data at address 00304572.
	dc.b $41
; Unknown data at address 00304573.
	dc.b $f9
; Unknown data at address 00304574.
	dc.b $00
; Unknown data at address 00304575.
	dc.b $30
; Unknown data at address 00304576.
	dc.b $4d
; Unknown data at address 00304577.
	dc.b $a8
; Unknown data at address 00304578.
	dc.b $24
; Unknown data at address 00304579.
	dc.b $48
; Unknown data at address 0030457a.
	dc.b $4a
; Unknown data at address 0030457b.
	dc.b $2a
; Unknown data at address 0030457c.
	dc.b $00
; Unknown data at address 0030457d.
	dc.b $0c
; Unknown data at address 0030457e.
	dc.b $67
; Unknown data at address 0030457f.
	dc.b $1c
; Unknown data at address 00304580.
	dc.b $d5
; Unknown data at address 00304581.
	dc.b $fc
; Unknown data at address 00304582.
	dc.b $00
; Unknown data at address 00304583.
	dc.b $00
; Unknown data at address 00304584.
	dc.b $00
; Unknown data at address 00304585.
	dc.b $16
; Unknown data at address 00304586.
	dc.b $41
; Unknown data at address 00304587.
	dc.b $f9
; Unknown data at address 00304588.
	dc.b $00
; Unknown data at address 00304589.
	dc.b $30
; Unknown data at address 0030458a.
	dc.b $4f
; Unknown data at address 0030458b.
	dc.b $60
; Unknown data at address 0030458c.
	dc.b $b5
; Unknown data at address 0030458d.
	dc.b $c8
; Unknown data at address 0030458e.
	dc.b $65
; Unknown data at address 0030458f.
	dc.b $0a
; Unknown data at address 00304590.
	dc.b $70
; Unknown data at address 00304591.
	dc.b $00
; Unknown data at address 00304592.
	dc.b $4c
; Unknown data at address 00304593.
	dc.b $df
; Unknown data at address 00304594.
	dc.b $44
; Unknown data at address 00304595.
	dc.b $0c
; Unknown data at address 00304596.
	dc.b $4e
; Unknown data at address 00304597.
	dc.b $5d
; Unknown data at address 00304598.
	dc.b $4e
; Unknown data at address 00304599.
	dc.b $75
; Unknown data at address 0030459a.
	dc.b $60
; Unknown data at address 0030459b.
	dc.b $de
; Unknown data at address 0030459c.
	dc.b $42
; Unknown data at address 0030459d.
	dc.b $92
; Unknown data at address 0030459e.
	dc.b $42
; Unknown data at address 0030459f.
	dc.b $aa
; Unknown data at address 003045a0.
	dc.b $00
; Unknown data at address 003045a1.
	dc.b $04
; Unknown data at address 003045a2.
	dc.b $42
; Unknown data at address 003045a3.
	dc.b $aa
; Unknown data at address 003045a4.
	dc.b $00
; Unknown data at address 003045a5.
	dc.b $08
; Unknown data at address 003045a6.
	dc.b $20
; Unknown data at address 003045a7.
	dc.b $0a
; Unknown data at address 003045a8.
	dc.b $60
; Unknown data at address 003045a9.
	dc.b $e8
FUN_003045aa:
	link.w A5,#-$0004
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	pea $00000400
	jsr FUN_00304696
	move.l D0,(-$0004,A5)
	addq.w #$00000004,SP
	bne.b LAB_003045e2
	move.w #$0001,($0010,A2)
	movea.l A2,A0
	adda.l #$0000000e,A0
	move.l A0,($0008,A2)
LAB_003045da:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_003045e2:
	move.w #$0400,($0010,A2)
	bset.b #$00000001,($000c,A2)
	move.l (-$0004,A5),($0008,A2)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_00304700
	tst.l D0
	addq.w #$00000004,SP
	beq.b LAB_00304610
	ori.b #-$00000080,($000c,A2)
LAB_00304610:
	bra.b LAB_003045da
LAB_00304612:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D3/D2,-(SP)
	movea.l DAT_00304f7c,A2
	bra.b LAB_00304638
LAB_00304622:
	movea.l (A2),A3
	move.l ($0004,A2),D0
	addq.l #$00000008,D0
	move.l D0,-(SP)
	move.l A2,-(SP)
	jsr _FreeMem
	addq.w #$00000008,SP
	movea.l A3,A2
LAB_00304638:
	move.l A2,D0
	bne.b LAB_00304622
	clr.l DAT_00304f7c
	movem.l (SP)+,D2/D3/A2/A3/A6
	unlk A5
	rts
FUN_0030464a:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	lea (LAB_00304612,PC),A0
	move.l A0,DAT_00305128
	clr.l -(SP)
	move.l ($0008,A5),D0
	addq.l #$00000008,D0
	move.l D0,-(SP)
	jsr _AllocMem
	movea.l D0,A2
	tst.l D0
	addq.w #$00000008,SP
	bne.b LAB_0030467e
	moveq #$00000000,D0
LAB_00304676:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_0030467e:
	move.l DAT_00304f7c,(A2)
	move.l ($0008,A5),($0004,A2)
	move.l A2,DAT_00304f7c
	move.l A2,D0
	addq.l #$00000008,D0
	bra.b LAB_00304676
FUN_00304696:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	move.l ($0008,A5),-(SP)
	bsr.b FUN_0030464a
	addq.w #$00000004,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_003046ae:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D3/D2,-(SP)
	suba.l A3,A3
	movea.l DAT_00304f7c,A2
	bra.b LAB_003046ce
LAB_003046c0:
	movea.l ($0008,A5),A0
	subq.l #$00000008,A0
	cmpa.l A2,A0
	beq.b LAB_003046dc
	movea.l A2,A3
	movea.l (A2),A2
LAB_003046ce:
	move.l A2,D0
	bne.b LAB_003046c0
	moveq #-$00000001,D0
LAB_003046d4:
	movem.l (SP)+,D2/D3/A2/A3/A6
	unlk A5
	rts
LAB_003046dc:
	move.l A3,D0
	beq.b LAB_003046e4
	move.l (A2),(A3)
	bra.b LAB_003046ea
LAB_003046e4:
	move.l (A2),DAT_00304f7c
LAB_003046ea:
	move.l ($0004,A2),D0
	addq.l #$00000008,D0
	move.l D0,-(SP)
	move.l A2,-(SP)
	jsr _FreeMem
	moveq #$00000000,D0
	addq.w #$00000008,SP
	bra.b LAB_003046d4
FUN_00304700:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	moveq #$00000006,D1
	move.l ($0008,A5),D0
	jsr FUN_00304aa4
	movea.l D0,A2
	adda.l DAT_003050f0,A2
	tst.l ($0008,A5)
	blt.b LAB_00304736
	move.w DAT_00304f60,D0
	ext.l D0
	move.l ($0008,A5),D1
	cmp.l D0,D1
	bge.b LAB_00304736
	tst.l (A2)
	bne.b LAB_0030474a
LAB_00304736:
	move.l #$00000002,DAT_003050f4
	moveq #-$00000001,D0
LAB_00304742:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_0030474a:
	moveq #$00000006,D1
	move.l ($0008,A5),D0
	jsr FUN_00304aa4
	movea.l DAT_003050f0,A0
	move.l ($00,A0,D0.l),-(SP)
	jsr _IsInteractive
	tst.l D0
	addq.w #$00000004,SP
	beq.b LAB_00304770
	moveq #$00000001,D0
	bra.b LAB_00304772
LAB_00304770:
	moveq #$00000000,D0
LAB_00304772:
	bra.b LAB_00304742
FUN_00304774:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	move.l ($0008,A5),-(SP)
	jsr _DeleteFile
	tst.l D0
	addq.w #$00000004,SP
	bne.b LAB_003047a2
	jsr _IoErr
	move.l D0,DAT_003050f4
	moveq #-$00000001,D0
LAB_0030479a:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_003047a2:
	moveq #$00000000,D0
	bra.b LAB_0030479a
FUN_003047a6:
	link.w A5,#$00000000
	movem.l A6/A2/D5/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	jsr FUN_0030483c
	moveq #$00000006,D1
	move.l D4,D0
	jsr FUN_00304aa4
	movea.l D0,A2
	adda.l DAT_003050f0,A2
	tst.l D4
	blt.b LAB_003047de
	move.w DAT_00304f60,D0
	ext.l D0
	cmp.l D0,D4
	bge.b LAB_003047de
	tst.l (A2)
	bne.b LAB_003047f2
LAB_003047de:
	move.l #$00000002,DAT_003050f4
	moveq #-$00000001,D0
LAB_003047ea:
	movem.l (SP)+,D2/D3/D4/D5/A2/A6
	unlk A5
	rts
LAB_003047f2:
	move.w ($0004,A2),D0
	and.w #$0003,D0
	bne.b LAB_0030480a
	move.l #$00000005,DAT_003050f4
	moveq #-$00000001,D0
	bra.b LAB_003047ea
LAB_0030480a:
	move.l ($0010,A5),-(SP)
	move.l ($000c,A5),-(SP)
	move.l (A2),-(SP)
	jsr _Write
	move.l D0,D5
	cmp.l #-$00000001,D0
	lea ($000c,SP),SP
	bne.b LAB_00304838
	jsr _IoErr
	move.l D0,DAT_003050f4
	moveq #-$00000001,D0
	bra.b LAB_003047ea
LAB_00304838:
	move.l D5,D0
	bra.b LAB_003047ea
FUN_0030483c:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	pea $00001000
	clr.l -(SP)
	jsr _SetSignal
	move.l D0,(-$0004,A5)
	btst.l #$0000000c,D0
	addq.w #$00000008,SP
	beq.b LAB_00304876
	tst.l DAT_00305108
	bne.b LAB_00304870
	move.l (-$0004,A5),D0
LAB_00304868:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00304870:
	jsr FUN_0030487a
LAB_00304876:
	moveq #$00000000,D0
	bra.b LAB_00304868
FUN_0030487a:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	pea $00000004
	pea (DAT_003048ae,PC)
	jsr _Output
	move.l D0,-(SP)
	jsr _Write
	pea $00000001
	jsr FUN_003048b2
	lea ($0010,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_003048ae:
; Unknown data at address 003048ae.
	dc.b $5e
; Unknown data at address 003048af.
	dc.b $43
; Unknown data at address 003048b0.
	dc.b $0a
; Unknown data at address 003048b1.
	dc.b $00
FUN_003048b2:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	tst.l DAT_00305124
	beq.b LAB_003048ca
	movea.l DAT_00305124,A0
	jsr (A0)
LAB_003048ca:
	move.l ($0008,A5),-(SP)
	jsr FUN_003048de
	addq.w #$00000004,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_003048de:
	link.w A5,#-$0004
	movem.l A6/D4/D3/D2,-(SP)
	move.l ($0008,A5),(-$0004,A5)
	tst.l DAT_003050f0
	beq.b LAB_0030492a
	moveq #$00000000,D4
	bra.b LAB_00304904
LAB_003048f8:
	move.l D4,-(SP)
	jsr FUN_00304a44
	addq.w #$00000004,SP
	addq.l #$00000001,D4
LAB_00304904:
	move.w DAT_00304f60,D0
	ext.l D0
	cmp.l D0,D4
	blt.b LAB_003048f8
	move.w DAT_00304f60,D0
	muls.w #$0006,D0
	move.l D0,-(SP)
	move.l DAT_003050f0,-(SP)
	jsr _FreeMem
	addq.w #$00000008,SP
LAB_0030492a:
	tst.l DAT_00305128
	beq.b LAB_0030493a
	movea.l DAT_00305128,A0
	jsr (A0)
LAB_0030493a:
	tst.l DAT_00304f66
	beq.b LAB_00304950
	move.l DAT_00304f66,-(SP)
	jsr _UnLockThunk
	addq.w #$00000004,SP
LAB_00304950:
	tst.l DAT_0030512c
	beq.b LAB_00304964
	movea.l DAT_0030512c,A0
	move.l DAT_00305130,(A0)
LAB_00304964:
	tst.l DAT_00305134
	beq.b LAB_0030497a
	move.l DAT_00305134,-(SP)
	jsr _CloseLibrary
	addq.w #$00000004,SP
LAB_0030497a:
	tst.l DAT_00305138
	beq.b LAB_00304990
	move.l DAT_00305138,-(SP)
	jsr _CloseLibrary
	addq.w #$00000004,SP
LAB_00304990:
	tst.l DAT_0030513c
	beq.b LAB_003049a6
	move.l DAT_0030513c,-(SP)
	jsr _CloseLibrary
	addq.w #$00000004,SP
LAB_003049a6:
	tst.l DAT_00305140
	beq.b LAB_003049bc
	move.l DAT_00305140,-(SP)
	jsr _CloseLibrary
	addq.w #$00000004,SP
LAB_003049bc:
	movea.l $00000004,A6
	btst.b #$00000004,($0129,A6)
	beq.b LAB_003049dc
	move.l A5,-(SP)
	lea (LAB_003049d6,PC),A5
	jsr (-$001e,A6)
	movea.l (SP)+,A5
	bra.b LAB_003049dc
LAB_003049d6:
	clr.l -(SP)
	frestore (SP)+
	rte
LAB_003049dc:
	tst.l DAT_0030510c
	bne.b LAB_00304a1c
	tst.l DAT_0030511c
	beq.b LAB_00304a1a
	move.l DAT_00305118,-(SP)
	move.l DAT_0030511c,-(SP)
	jsr _FreeMem
	move.l DAT_00305114,D0
	addq.l #$00000001,D0
	asl.l #$00000002,D0
	move.l D0,-(SP)
	move.l DAT_00305110,-(SP)
	jsr _FreeMem
	lea ($0010,SP),SP
LAB_00304a1a:
	bra.b LAB_00304a30
LAB_00304a1c:
	jsr _Forbid
	move.l DAT_0030510c,-(SP)
	jsr _ReplyMsg
	addq.w #$00000004,SP
LAB_00304a30:
	move.l (-$0004,A5),D0
	movea.l DAT_003050f8,SP
	rts
; Unknown data at address 00304a3c.
	dc.b $4c
; Unknown data at address 00304a3d.
	dc.b $df
; Unknown data at address 00304a3e.
	dc.b $40
; Unknown data at address 00304a3f.
	dc.b $1c
; Unknown data at address 00304a40.
	dc.b $4e
; Unknown data at address 00304a41.
	dc.b $5d
; Unknown data at address 00304a42.
	dc.b $4e
; Unknown data at address 00304a43.
	dc.b $75
FUN_00304a44:
	link.w A5,#$00000000
	movem.l A6/A2/D6/D5/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	moveq #$00000006,D1
	move.l D4,D0
	jsr FUN_00304aa4
	movea.l D0,A2
	adda.l DAT_003050f0,A2
	tst.l D4
	blt.b LAB_00304a76
	move.w DAT_00304f60,D0
	ext.l D0
	cmp.l D0,D4
	bge.b LAB_00304a76
	tst.l (A2)
	bne.b LAB_00304a8a
LAB_00304a76:
	move.l #$00000002,DAT_003050f4
	moveq #-$00000001,D0
LAB_00304a82:
	movem.l (SP)+,D2/D3/D4/D5/D6/A2/A6
	unlk A5
	rts
LAB_00304a8a:
	move.w ($0004,A2),D0
	and.w #-$8000,D0
	bne.b LAB_00304a9e
	move.l (A2),-(SP)
	jsr _Close
	addq.w #$00000004,SP
LAB_00304a9e:
	clr.l (A2)
	moveq #$00000000,D0
	bra.b LAB_00304a82
FUN_00304aa4:
	movem.l D3/D2/D1,-(SP)
	move.w D1,D2
	mulu.w D0,D2
	move.l D1,D3
	swap D3
	mulu.w D0,D3
	swap D3
	clr.w D3
	add.l D3,D2
	swap D0
	mulu.w D1,D0
	swap D0
	clr.w D0
	add.l D2,D0
	movem.l (SP)+,D1/D2/D3
	rts
_CloseThunk:
	jmp _Close
_Close:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$0024,A6)
_CreateDir:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$0078,A6)
_CurrentDirThunk:
	jmp _CurrentDir
_CurrentDir:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$007e,A6)
_Delay:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$00c6,A6)
_DeleteFileThunk:
	jmp _DeleteFile
_DeleteFile:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$0048,A6)
_ExamineThunk:
	jmp _Examine
_Examine:
	movem.l ($0004,SP),D1/D2
	movea.l _DOSBase,A6
	jmp (-$0066,A6)
_Execute:
	movem.l ($0004,SP),D1/D2/D3
	movea.l _DOSBase,A6
	jmp (-$00de,A6)
_Input:
	movea.l _DOSBase,A6
	jmp (-$0036,A6)
_IoErrThunk:
	jmp _IoErr
_IoErr:
	movea.l _DOSBase,A6
	jmp (-$0084,A6)
_IsInteractive:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$00d8,A6)
_LockThunk:
	jmp _Lock
_Lock:
	movem.l ($0004,SP),D1/D2
	movea.l _DOSBase,A6
	jmp (-$0054,A6)
_OpenThunk:
	jmp _Open
_Open:
	movem.l ($0004,SP),D1/D2
	movea.l _DOSBase,A6
	jmp (-$001e,A6)
_Output:
	movea.l _DOSBase,A6
	jmp (-$003c,A6)
_ParentDir:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$00d2,A6)
_ReadThunk:
	jmp _Read
_Read:
	movem.l ($0004,SP),D1/D2/D3
	movea.l _DOSBase,A6
	jmp (-$002a,A6)
_UnLockThunk:
	jmp _UnLock
_UnLock:
	move.l ($0004,SP),D1
	movea.l _DOSBase,A6
	jmp (-$005a,A6)
_WriteThunk:
	jmp _Write
_Write:
	movem.l ($0004,SP),D1/D2/D3
	movea.l _DOSBase,A6
	jmp (-$0030,A6)
_Alert:
	movem.l A5/D7,-(SP)
	movem.l ($000c,SP),D7/A5
	movea.l _SysBase,A6
	jsr (-$006c,A6)
	movem.l (SP)+,D7/A5
	rts
_CloseLibraryThunk:
	jmp _CloseLibrary
_CloseLibrary:
	movea.l ($0004,SP),A1
	movea.l _SysBase,A6
	jmp (-$019e,A6)
_AllocMemThunk:
	jmp _AllocMem
_AllocMem:
	movem.l ($0004,SP),D0/D1
	movea.l _SysBase,A6
	jmp (-$00c6,A6)
_FindTaskThunk:
	jmp _FindTask
_FindTask:
	movea.l ($0004,SP),A1
	movea.l _SysBase,A6
	jmp (-$0126,A6)
_Forbid:
	movea.l _SysBase,A6
	jmp (-$0084,A6)
_FreeMemThunk:
	jmp _FreeMem
_FreeMem:
	movea.l ($0004,SP),A1
	move.l ($0008,SP),D0
	movea.l _SysBase,A6
	jmp (-$00d2,A6)
_GetMsg:
	movea.l ($0004,SP),A0
	movea.l _SysBase,A6
	jmp (-$0174,A6)
_OpenLibrary:
	movea.l _SysBase,A6
	movea.l ($0004,SP),A1
	move.l ($0008,SP),D0
	jmp (-$0228,A6)
_ReplyMsg:
	movea.l ($0004,SP),A1
	movea.l _SysBase,A6
	jmp (-$017a,A6)
_SetSignal:
	movem.l ($0004,SP),D0/D1
	movea.l _SysBase,A6
	jmp (-$0132,A6)
_WaitPort:
	movea.l ($0004,SP),A0
	movea.l _SysBase,A6
	jmp (-$0180,A6)
_FindToolType:
	movem.l ($0004,SP),A0/A1
	movea.l _IconBase,A6
	jmp (-$0060,A6)
_FreeDiskObject:
	movea.l ($0004,SP),A0
	movea.l _IconBase,A6
	jmp (-$005a,A6)
_GetDiskObject:
	movea.l ($0004,SP),A0
	movea.l _IconBase,A6
	jmp (-$004e,A6)
;   }

; #######################
; # HUNK01 - DATA       #
; #######################
	section	hunk01,DATA
;   {
DAT_00304ce4:
; Unknown data at address 00304ce4.
	dc.b $00
; Unknown data at address 00304ce5.
	dc.b $00
s_ABCDEFabcdef9876543210_00304ce6:
	dc.b "ABCDEFabcdef9876543210",0
DAT_00304cfd:
; Unknown data at address 00304cfd.
	dc.b $0a
; Unknown data at address 00304cfe.
	dc.b $0b
; Unknown data at address 00304cff.
	dc.b $0c
; Unknown data at address 00304d00.
	dc.b $0d
; Unknown data at address 00304d01.
	dc.b $0e
; Unknown data at address 00304d02.
	dc.b $0f
; Unknown data at address 00304d03.
	dc.b $0a
; Unknown data at address 00304d04.
	dc.b $0b
; Unknown data at address 00304d05.
	dc.b $0c
; Unknown data at address 00304d06.
	dc.b $0d
; Unknown data at address 00304d07.
	dc.b $0e
; Unknown data at address 00304d08.
	dc.b $0f
; Unknown data at address 00304d09.
	dc.b $09
; Unknown data at address 00304d0a.
	dc.b $08
; Unknown data at address 00304d0b.
	dc.b $07
; Unknown data at address 00304d0c.
	dc.b $06
; Unknown data at address 00304d0d.
	dc.b $05
; Unknown data at address 00304d0e.
	dc.b $04
; Unknown data at address 00304d0f.
	dc.b $03
; Unknown data at address 00304d10.
	dc.b $02
; Unknown data at address 00304d11.
	dc.b $01
; Unknown data at address 00304d12.
	dc.b $00
; Unknown data at address 00304d13.
	dc.b $00
s_0123456789abcdef_00304d14:
	dc.b "0123456789abcdef",0
; Unknown data at address 00304d25.
	dc.b $00
; Unknown data at address 00304d26.
	dc.b $00
DAT_00304d27:
; Unknown data at address 00304d27.
	dc.b $20
; Unknown data at address 00304d28.
	dc.b $20
; Unknown data at address 00304d29.
	dc.b $20
; Unknown data at address 00304d2a.
	dc.b $20
; Unknown data at address 00304d2b.
	dc.b $20
; Unknown data at address 00304d2c.
	dc.b $20
; Unknown data at address 00304d2d.
	dc.b $20
; Unknown data at address 00304d2e.
	dc.b $20
; Unknown data at address 00304d2f.
	dc.b $20
; Unknown data at address 00304d30.
	dc.b $30
; Unknown data at address 00304d31.
	dc.b $30
; Unknown data at address 00304d32.
	dc.b $30
; Unknown data at address 00304d33.
	dc.b $30
; Unknown data at address 00304d34.
	dc.b $30
; Unknown data at address 00304d35.
	dc.b $20
; Unknown data at address 00304d36.
	dc.b $20
; Unknown data at address 00304d37.
	dc.b $20
; Unknown data at address 00304d38.
	dc.b $20
; Unknown data at address 00304d39.
	dc.b $20
; Unknown data at address 00304d3a.
	dc.b $20
; Unknown data at address 00304d3b.
	dc.b $20
; Unknown data at address 00304d3c.
	dc.b $20
; Unknown data at address 00304d3d.
	dc.b $20
; Unknown data at address 00304d3e.
	dc.b $20
; Unknown data at address 00304d3f.
	dc.b $20
; Unknown data at address 00304d40.
	dc.b $20
; Unknown data at address 00304d41.
	dc.b $20
; Unknown data at address 00304d42.
	dc.b $20
; Unknown data at address 00304d43.
	dc.b $20
; Unknown data at address 00304d44.
	dc.b $20
; Unknown data at address 00304d45.
	dc.b $20
; Unknown data at address 00304d46.
	dc.b $20
; Unknown data at address 00304d47.
	dc.b $90
; Unknown data at address 00304d48.
	dc.b $40
; Unknown data at address 00304d49.
	dc.b $40
; Unknown data at address 00304d4a.
	dc.b $40
; Unknown data at address 00304d4b.
	dc.b $40
; Unknown data at address 00304d4c.
	dc.b $40
; Unknown data at address 00304d4d.
	dc.b $40
; Unknown data at address 00304d4e.
	dc.b $40
; Unknown data at address 00304d4f.
	dc.b $40
; Unknown data at address 00304d50.
	dc.b $40
; Unknown data at address 00304d51.
	dc.b $40
; Unknown data at address 00304d52.
	dc.b $40
; Unknown data at address 00304d53.
	dc.b $40
; Unknown data at address 00304d54.
	dc.b $40
; Unknown data at address 00304d55.
	dc.b $40
; Unknown data at address 00304d56.
	dc.b $40
; Unknown data at address 00304d57.
	dc.b $0c
; Unknown data at address 00304d58.
	dc.b $0c
; Unknown data at address 00304d59.
	dc.b $0c
; Unknown data at address 00304d5a.
	dc.b $0c
; Unknown data at address 00304d5b.
	dc.b $0c
; Unknown data at address 00304d5c.
	dc.b $0c
; Unknown data at address 00304d5d.
	dc.b $0c
; Unknown data at address 00304d5e.
	dc.b $0c
; Unknown data at address 00304d5f.
	dc.b $0c
; Unknown data at address 00304d60.
	dc.b $0c
; Unknown data at address 00304d61.
	dc.b $40
; Unknown data at address 00304d62.
	dc.b $40
; Unknown data at address 00304d63.
	dc.b $40
; Unknown data at address 00304d64.
	dc.b $40
; Unknown data at address 00304d65.
	dc.b $40
; Unknown data at address 00304d66.
	dc.b $40
; Unknown data at address 00304d67.
	dc.b $40
; Unknown data at address 00304d68.
	dc.b $09
; Unknown data at address 00304d69.
	dc.b $09
; Unknown data at address 00304d6a.
	dc.b $09
; Unknown data at address 00304d6b.
	dc.b $09
; Unknown data at address 00304d6c.
	dc.b $09
; Unknown data at address 00304d6d.
	dc.b $09
; Unknown data at address 00304d6e.
	dc.b $01
; Unknown data at address 00304d6f.
	dc.b $01
; Unknown data at address 00304d70.
	dc.b $01
; Unknown data at address 00304d71.
	dc.b $01
; Unknown data at address 00304d72.
	dc.b $01
; Unknown data at address 00304d73.
	dc.b $01
; Unknown data at address 00304d74.
	dc.b $01
; Unknown data at address 00304d75.
	dc.b $01
; Unknown data at address 00304d76.
	dc.b $01
; Unknown data at address 00304d77.
	dc.b $01
; Unknown data at address 00304d78.
	dc.b $01
; Unknown data at address 00304d79.
	dc.b $01
; Unknown data at address 00304d7a.
	dc.b $01
; Unknown data at address 00304d7b.
	dc.b $01
; Unknown data at address 00304d7c.
	dc.b $01
; Unknown data at address 00304d7d.
	dc.b $01
; Unknown data at address 00304d7e.
	dc.b $01
; Unknown data at address 00304d7f.
	dc.b $01
; Unknown data at address 00304d80.
	dc.b $01
; Unknown data at address 00304d81.
	dc.b $01
; Unknown data at address 00304d82.
	dc.b $40
; Unknown data at address 00304d83.
	dc.b $40
; Unknown data at address 00304d84.
	dc.b $40
; Unknown data at address 00304d85.
	dc.b $40
; Unknown data at address 00304d86.
	dc.b $40
; Unknown data at address 00304d87.
	dc.b $40
; Unknown data at address 00304d88.
	dc.b $0a
; Unknown data at address 00304d89.
	dc.b $0a
; Unknown data at address 00304d8a.
	dc.b $0a
; Unknown data at address 00304d8b.
	dc.b $0a
; Unknown data at address 00304d8c.
	dc.b $0a
; Unknown data at address 00304d8d.
	dc.b $0a
; Unknown data at address 00304d8e.
	dc.b $02
; Unknown data at address 00304d8f.
	dc.b $02
; Unknown data at address 00304d90.
	dc.b $02
; Unknown data at address 00304d91.
	dc.b $02
; Unknown data at address 00304d92.
	dc.b $02
; Unknown data at address 00304d93.
	dc.b $02
; Unknown data at address 00304d94.
	dc.b $02
; Unknown data at address 00304d95.
	dc.b $02
; Unknown data at address 00304d96.
	dc.b $02
; Unknown data at address 00304d97.
	dc.b $02
; Unknown data at address 00304d98.
	dc.b $02
; Unknown data at address 00304d99.
	dc.b $02
; Unknown data at address 00304d9a.
	dc.b $02
; Unknown data at address 00304d9b.
	dc.b $02
; Unknown data at address 00304d9c.
	dc.b $02
; Unknown data at address 00304d9d.
	dc.b $02
; Unknown data at address 00304d9e.
	dc.b $02
; Unknown data at address 00304d9f.
	dc.b $02
; Unknown data at address 00304da0.
	dc.b $02
; Unknown data at address 00304da1.
	dc.b $02
; Unknown data at address 00304da2.
	dc.b $40
; Unknown data at address 00304da3.
	dc.b $40
; Unknown data at address 00304da4.
	dc.b $40
; Unknown data at address 00304da5.
	dc.b $40
; Unknown data at address 00304da6.
	dc.b $20
; Unknown data at address 00304da7.
	dc.b $00
DAT_00304da8:
; Unknown data at address 00304da8.
	dc.b $00
; Unknown data at address 00304da9.
	dc.b $00
; Unknown data at address 00304daa.
	dc.b $00
; Unknown data at address 00304dab.
	dc.b $00
; Unknown data at address 00304dac.
	dc.b $00
; Unknown data at address 00304dad.
	dc.b $00
; Unknown data at address 00304dae.
	dc.b $00
; Unknown data at address 00304daf.
	dc.b $00
; Unknown data at address 00304db0.
	dc.b $00
; Unknown data at address 00304db1.
	dc.b $00
; Unknown data at address 00304db2.
	dc.b $00
; Unknown data at address 00304db3.
	dc.b $00
DAT_00304db4:
	; undefined1
	dc.b $01
; Unknown data at address 00304db5.
	dc.b $00
; Unknown data at address 00304db6.
	dc.b $00
; Unknown data at address 00304db7.
	dc.b $00
; Unknown data at address 00304db8.
	dc.b $00
; Unknown data at address 00304db9.
	dc.b $01
; Unknown data at address 00304dba.
	dc.b $00
; Unknown data at address 00304dbb.
	dc.b $00
; Unknown data at address 00304dbc.
	dc.b $00
; Unknown data at address 00304dbd.
	dc.b $00
DAT_00304dbe:
; Unknown data at address 00304dbe.
	dc.b $00
; Unknown data at address 00304dbf.
	dc.b $00
; Unknown data at address 00304dc0.
	dc.b $00
; Unknown data at address 00304dc1.
	dc.b $00
; Unknown data at address 00304dc2.
	dc.b $00
; Unknown data at address 00304dc3.
	dc.b $00
; Unknown data at address 00304dc4.
	dc.b $00
; Unknown data at address 00304dc5.
	dc.b $00
; Unknown data at address 00304dc6.
	dc.b $00
; Unknown data at address 00304dc7.
	dc.b $00
; Unknown data at address 00304dc8.
	dc.b $00
; Unknown data at address 00304dc9.
	dc.b $00
DAT_00304dca:
	; undefined1
	dc.b $01
; Unknown data at address 00304dcb.
	dc.b $01
; Unknown data at address 00304dcc.
	dc.b $00
; Unknown data at address 00304dcd.
	dc.b $00
; Unknown data at address 00304dce.
	dc.b $00
; Unknown data at address 00304dcf.
	dc.b $01
; Unknown data at address 00304dd0.
	dc.b $00
; Unknown data at address 00304dd1.
	dc.b $00
; Unknown data at address 00304dd2.
	dc.b $00
; Unknown data at address 00304dd3.
	dc.b $00
; Unknown data at address 00304dd4.
	dc.b $00
; Unknown data at address 00304dd5.
	dc.b $00
; Unknown data at address 00304dd6.
	dc.b $00
; Unknown data at address 00304dd7.
	dc.b $00
; Unknown data at address 00304dd8.
	dc.b $00
; Unknown data at address 00304dd9.
	dc.b $00
; Unknown data at address 00304dda.
	dc.b $00
; Unknown data at address 00304ddb.
	dc.b $00
; Unknown data at address 00304ddc.
	dc.b $00
; Unknown data at address 00304ddd.
	dc.b $00
; Unknown data at address 00304dde.
	dc.b $00
; Unknown data at address 00304ddf.
	dc.b $00
; Unknown data at address 00304de0.
	dc.b $01
; Unknown data at address 00304de1.
	dc.b $02
; Unknown data at address 00304de2.
	dc.b $00
; Unknown data at address 00304de3.
	dc.b $00
; Unknown data at address 00304de4.
	dc.b $00
; Unknown data at address 00304de5.
	dc.b $01
; Unknown data at address 00304de6.
	dc.b $00
; Unknown data at address 00304de7.
	dc.b $00
; Unknown data at address 00304de8.
	dc.b $00
; Unknown data at address 00304de9.
	dc.b $00
; Unknown data at address 00304dea.
	dc.b $00
; Unknown data at address 00304deb.
	dc.b $00
; Unknown data at address 00304dec.
	dc.b $00
; Unknown data at address 00304ded.
	dc.b $00
; Unknown data at address 00304dee.
	dc.b $00
; Unknown data at address 00304def.
	dc.b $00
; Unknown data at address 00304df0.
	dc.b $00
; Unknown data at address 00304df1.
	dc.b $00
; Unknown data at address 00304df2.
	dc.b $00
; Unknown data at address 00304df3.
	dc.b $00
; Unknown data at address 00304df4.
	dc.b $00
; Unknown data at address 00304df5.
	dc.b $00
; Unknown data at address 00304df6.
	dc.b $00
; Unknown data at address 00304df7.
	dc.b $00
; Unknown data at address 00304df8.
	dc.b $00
; Unknown data at address 00304df9.
	dc.b $00
; Unknown data at address 00304dfa.
	dc.b $00
; Unknown data at address 00304dfb.
	dc.b $00
; Unknown data at address 00304dfc.
	dc.b $00
; Unknown data at address 00304dfd.
	dc.b $00
; Unknown data at address 00304dfe.
	dc.b $00
; Unknown data at address 00304dff.
	dc.b $00
; Unknown data at address 00304e00.
	dc.b $00
; Unknown data at address 00304e01.
	dc.b $00
; Unknown data at address 00304e02.
	dc.b $00
; Unknown data at address 00304e03.
	dc.b $00
; Unknown data at address 00304e04.
	dc.b $00
; Unknown data at address 00304e05.
	dc.b $00
; Unknown data at address 00304e06.
	dc.b $00
; Unknown data at address 00304e07.
	dc.b $00
; Unknown data at address 00304e08.
	dc.b $00
; Unknown data at address 00304e09.
	dc.b $00
; Unknown data at address 00304e0a.
	dc.b $00
; Unknown data at address 00304e0b.
	dc.b $00
; Unknown data at address 00304e0c.
	dc.b $00
; Unknown data at address 00304e0d.
	dc.b $00
; Unknown data at address 00304e0e.
	dc.b $00
; Unknown data at address 00304e0f.
	dc.b $00
; Unknown data at address 00304e10.
	dc.b $00
; Unknown data at address 00304e11.
	dc.b $00
; Unknown data at address 00304e12.
	dc.b $00
; Unknown data at address 00304e13.
	dc.b $00
; Unknown data at address 00304e14.
	dc.b $00
; Unknown data at address 00304e15.
	dc.b $00
; Unknown data at address 00304e16.
	dc.b $00
; Unknown data at address 00304e17.
	dc.b $00
; Unknown data at address 00304e18.
	dc.b $00
; Unknown data at address 00304e19.
	dc.b $00
; Unknown data at address 00304e1a.
	dc.b $00
; Unknown data at address 00304e1b.
	dc.b $00
; Unknown data at address 00304e1c.
	dc.b $00
; Unknown data at address 00304e1d.
	dc.b $00
; Unknown data at address 00304e1e.
	dc.b $00
; Unknown data at address 00304e1f.
	dc.b $00
; Unknown data at address 00304e20.
	dc.b $00
; Unknown data at address 00304e21.
	dc.b $00
; Unknown data at address 00304e22.
	dc.b $00
; Unknown data at address 00304e23.
	dc.b $00
; Unknown data at address 00304e24.
	dc.b $00
; Unknown data at address 00304e25.
	dc.b $00
; Unknown data at address 00304e26.
	dc.b $00
; Unknown data at address 00304e27.
	dc.b $00
; Unknown data at address 00304e28.
	dc.b $00
; Unknown data at address 00304e29.
	dc.b $00
; Unknown data at address 00304e2a.
	dc.b $00
; Unknown data at address 00304e2b.
	dc.b $00
; Unknown data at address 00304e2c.
	dc.b $00
; Unknown data at address 00304e2d.
	dc.b $00
; Unknown data at address 00304e2e.
	dc.b $00
; Unknown data at address 00304e2f.
	dc.b $00
; Unknown data at address 00304e30.
	dc.b $00
; Unknown data at address 00304e31.
	dc.b $00
; Unknown data at address 00304e32.
	dc.b $00
; Unknown data at address 00304e33.
	dc.b $00
; Unknown data at address 00304e34.
	dc.b $00
; Unknown data at address 00304e35.
	dc.b $00
; Unknown data at address 00304e36.
	dc.b $00
; Unknown data at address 00304e37.
	dc.b $00
; Unknown data at address 00304e38.
	dc.b $00
; Unknown data at address 00304e39.
	dc.b $00
; Unknown data at address 00304e3a.
	dc.b $00
; Unknown data at address 00304e3b.
	dc.b $00
; Unknown data at address 00304e3c.
	dc.b $00
; Unknown data at address 00304e3d.
	dc.b $00
; Unknown data at address 00304e3e.
	dc.b $00
; Unknown data at address 00304e3f.
	dc.b $00
; Unknown data at address 00304e40.
	dc.b $00
; Unknown data at address 00304e41.
	dc.b $00
; Unknown data at address 00304e42.
	dc.b $00
; Unknown data at address 00304e43.
	dc.b $00
; Unknown data at address 00304e44.
	dc.b $00
; Unknown data at address 00304e45.
	dc.b $00
; Unknown data at address 00304e46.
	dc.b $00
; Unknown data at address 00304e47.
	dc.b $00
; Unknown data at address 00304e48.
	dc.b $00
; Unknown data at address 00304e49.
	dc.b $00
; Unknown data at address 00304e4a.
	dc.b $00
; Unknown data at address 00304e4b.
	dc.b $00
; Unknown data at address 00304e4c.
	dc.b $00
; Unknown data at address 00304e4d.
	dc.b $00
; Unknown data at address 00304e4e.
	dc.b $00
; Unknown data at address 00304e4f.
	dc.b $00
; Unknown data at address 00304e50.
	dc.b $00
; Unknown data at address 00304e51.
	dc.b $00
; Unknown data at address 00304e52.
	dc.b $00
; Unknown data at address 00304e53.
	dc.b $00
; Unknown data at address 00304e54.
	dc.b $00
; Unknown data at address 00304e55.
	dc.b $00
; Unknown data at address 00304e56.
	dc.b $00
; Unknown data at address 00304e57.
	dc.b $00
; Unknown data at address 00304e58.
	dc.b $00
; Unknown data at address 00304e59.
	dc.b $00
; Unknown data at address 00304e5a.
	dc.b $00
; Unknown data at address 00304e5b.
	dc.b $00
; Unknown data at address 00304e5c.
	dc.b $00
; Unknown data at address 00304e5d.
	dc.b $00
; Unknown data at address 00304e5e.
	dc.b $00
; Unknown data at address 00304e5f.
	dc.b $00
; Unknown data at address 00304e60.
	dc.b $00
; Unknown data at address 00304e61.
	dc.b $00
; Unknown data at address 00304e62.
	dc.b $00
; Unknown data at address 00304e63.
	dc.b $00
; Unknown data at address 00304e64.
	dc.b $00
; Unknown data at address 00304e65.
	dc.b $00
; Unknown data at address 00304e66.
	dc.b $00
; Unknown data at address 00304e67.
	dc.b $00
; Unknown data at address 00304e68.
	dc.b $00
; Unknown data at address 00304e69.
	dc.b $00
; Unknown data at address 00304e6a.
	dc.b $00
; Unknown data at address 00304e6b.
	dc.b $00
; Unknown data at address 00304e6c.
	dc.b $00
; Unknown data at address 00304e6d.
	dc.b $00
; Unknown data at address 00304e6e.
	dc.b $00
; Unknown data at address 00304e6f.
	dc.b $00
; Unknown data at address 00304e70.
	dc.b $00
; Unknown data at address 00304e71.
	dc.b $00
; Unknown data at address 00304e72.
	dc.b $00
; Unknown data at address 00304e73.
	dc.b $00
; Unknown data at address 00304e74.
	dc.b $00
; Unknown data at address 00304e75.
	dc.b $00
; Unknown data at address 00304e76.
	dc.b $00
; Unknown data at address 00304e77.
	dc.b $00
; Unknown data at address 00304e78.
	dc.b $00
; Unknown data at address 00304e79.
	dc.b $00
; Unknown data at address 00304e7a.
	dc.b $00
; Unknown data at address 00304e7b.
	dc.b $00
; Unknown data at address 00304e7c.
	dc.b $00
; Unknown data at address 00304e7d.
	dc.b $00
; Unknown data at address 00304e7e.
	dc.b $00
; Unknown data at address 00304e7f.
	dc.b $00
; Unknown data at address 00304e80.
	dc.b $00
; Unknown data at address 00304e81.
	dc.b $00
; Unknown data at address 00304e82.
	dc.b $00
; Unknown data at address 00304e83.
	dc.b $00
; Unknown data at address 00304e84.
	dc.b $00
; Unknown data at address 00304e85.
	dc.b $00
; Unknown data at address 00304e86.
	dc.b $00
; Unknown data at address 00304e87.
	dc.b $00
; Unknown data at address 00304e88.
	dc.b $00
; Unknown data at address 00304e89.
	dc.b $00
; Unknown data at address 00304e8a.
	dc.b $00
; Unknown data at address 00304e8b.
	dc.b $00
; Unknown data at address 00304e8c.
	dc.b $00
; Unknown data at address 00304e8d.
	dc.b $00
; Unknown data at address 00304e8e.
	dc.b $00
; Unknown data at address 00304e8f.
	dc.b $00
; Unknown data at address 00304e90.
	dc.b $00
; Unknown data at address 00304e91.
	dc.b $00
; Unknown data at address 00304e92.
	dc.b $00
; Unknown data at address 00304e93.
	dc.b $00
; Unknown data at address 00304e94.
	dc.b $00
; Unknown data at address 00304e95.
	dc.b $00
; Unknown data at address 00304e96.
	dc.b $00
; Unknown data at address 00304e97.
	dc.b $00
; Unknown data at address 00304e98.
	dc.b $00
; Unknown data at address 00304e99.
	dc.b $00
; Unknown data at address 00304e9a.
	dc.b $00
; Unknown data at address 00304e9b.
	dc.b $00
; Unknown data at address 00304e9c.
	dc.b $00
; Unknown data at address 00304e9d.
	dc.b $00
; Unknown data at address 00304e9e.
	dc.b $00
; Unknown data at address 00304e9f.
	dc.b $00
; Unknown data at address 00304ea0.
	dc.b $00
; Unknown data at address 00304ea1.
	dc.b $00
; Unknown data at address 00304ea2.
	dc.b $00
; Unknown data at address 00304ea3.
	dc.b $00
; Unknown data at address 00304ea4.
	dc.b $00
; Unknown data at address 00304ea5.
	dc.b $00
; Unknown data at address 00304ea6.
	dc.b $00
; Unknown data at address 00304ea7.
	dc.b $00
; Unknown data at address 00304ea8.
	dc.b $00
; Unknown data at address 00304ea9.
	dc.b $00
; Unknown data at address 00304eaa.
	dc.b $00
; Unknown data at address 00304eab.
	dc.b $00
; Unknown data at address 00304eac.
	dc.b $00
; Unknown data at address 00304ead.
	dc.b $00
; Unknown data at address 00304eae.
	dc.b $00
; Unknown data at address 00304eaf.
	dc.b $00
; Unknown data at address 00304eb0.
	dc.b $00
; Unknown data at address 00304eb1.
	dc.b $00
; Unknown data at address 00304eb2.
	dc.b $00
; Unknown data at address 00304eb3.
	dc.b $00
; Unknown data at address 00304eb4.
	dc.b $00
; Unknown data at address 00304eb5.
	dc.b $00
; Unknown data at address 00304eb6.
	dc.b $00
; Unknown data at address 00304eb7.
	dc.b $00
; Unknown data at address 00304eb8.
	dc.b $00
; Unknown data at address 00304eb9.
	dc.b $00
; Unknown data at address 00304eba.
	dc.b $00
; Unknown data at address 00304ebb.
	dc.b $00
; Unknown data at address 00304ebc.
	dc.b $00
; Unknown data at address 00304ebd.
	dc.b $00
; Unknown data at address 00304ebe.
	dc.b $00
; Unknown data at address 00304ebf.
	dc.b $00
; Unknown data at address 00304ec0.
	dc.b $00
; Unknown data at address 00304ec1.
	dc.b $00
; Unknown data at address 00304ec2.
	dc.b $00
; Unknown data at address 00304ec3.
	dc.b $00
; Unknown data at address 00304ec4.
	dc.b $00
; Unknown data at address 00304ec5.
	dc.b $00
; Unknown data at address 00304ec6.
	dc.b $00
; Unknown data at address 00304ec7.
	dc.b $00
; Unknown data at address 00304ec8.
	dc.b $00
; Unknown data at address 00304ec9.
	dc.b $00
; Unknown data at address 00304eca.
	dc.b $00
; Unknown data at address 00304ecb.
	dc.b $00
; Unknown data at address 00304ecc.
	dc.b $00
; Unknown data at address 00304ecd.
	dc.b $00
; Unknown data at address 00304ece.
	dc.b $00
; Unknown data at address 00304ecf.
	dc.b $00
; Unknown data at address 00304ed0.
	dc.b $00
; Unknown data at address 00304ed1.
	dc.b $00
; Unknown data at address 00304ed2.
	dc.b $00
; Unknown data at address 00304ed3.
	dc.b $00
; Unknown data at address 00304ed4.
	dc.b $00
; Unknown data at address 00304ed5.
	dc.b $00
; Unknown data at address 00304ed6.
	dc.b $00
; Unknown data at address 00304ed7.
	dc.b $00
; Unknown data at address 00304ed8.
	dc.b $00
; Unknown data at address 00304ed9.
	dc.b $00
; Unknown data at address 00304eda.
	dc.b $00
; Unknown data at address 00304edb.
	dc.b $00
; Unknown data at address 00304edc.
	dc.b $00
; Unknown data at address 00304edd.
	dc.b $00
; Unknown data at address 00304ede.
	dc.b $00
; Unknown data at address 00304edf.
	dc.b $00
; Unknown data at address 00304ee0.
	dc.b $00
; Unknown data at address 00304ee1.
	dc.b $00
; Unknown data at address 00304ee2.
	dc.b $00
; Unknown data at address 00304ee3.
	dc.b $00
; Unknown data at address 00304ee4.
	dc.b $00
; Unknown data at address 00304ee5.
	dc.b $00
; Unknown data at address 00304ee6.
	dc.b $00
; Unknown data at address 00304ee7.
	dc.b $00
; Unknown data at address 00304ee8.
	dc.b $00
; Unknown data at address 00304ee9.
	dc.b $00
; Unknown data at address 00304eea.
	dc.b $00
; Unknown data at address 00304eeb.
	dc.b $00
; Unknown data at address 00304eec.
	dc.b $00
; Unknown data at address 00304eed.
	dc.b $00
; Unknown data at address 00304eee.
	dc.b $00
; Unknown data at address 00304eef.
	dc.b $00
; Unknown data at address 00304ef0.
	dc.b $00
; Unknown data at address 00304ef1.
	dc.b $00
; Unknown data at address 00304ef2.
	dc.b $00
; Unknown data at address 00304ef3.
	dc.b $00
; Unknown data at address 00304ef4.
	dc.b $00
; Unknown data at address 00304ef5.
	dc.b $00
; Unknown data at address 00304ef6.
	dc.b $00
; Unknown data at address 00304ef7.
	dc.b $00
; Unknown data at address 00304ef8.
	dc.b $00
; Unknown data at address 00304ef9.
	dc.b $00
; Unknown data at address 00304efa.
	dc.b $00
; Unknown data at address 00304efb.
	dc.b $00
; Unknown data at address 00304efc.
	dc.b $00
; Unknown data at address 00304efd.
	dc.b $00
; Unknown data at address 00304efe.
	dc.b $00
; Unknown data at address 00304eff.
	dc.b $00
; Unknown data at address 00304f00.
	dc.b $00
; Unknown data at address 00304f01.
	dc.b $00
; Unknown data at address 00304f02.
	dc.b $00
; Unknown data at address 00304f03.
	dc.b $00
; Unknown data at address 00304f04.
	dc.b $00
; Unknown data at address 00304f05.
	dc.b $00
; Unknown data at address 00304f06.
	dc.b $00
; Unknown data at address 00304f07.
	dc.b $00
; Unknown data at address 00304f08.
	dc.b $00
; Unknown data at address 00304f09.
	dc.b $00
; Unknown data at address 00304f0a.
	dc.b $00
; Unknown data at address 00304f0b.
	dc.b $00
; Unknown data at address 00304f0c.
	dc.b $00
; Unknown data at address 00304f0d.
	dc.b $00
; Unknown data at address 00304f0e.
	dc.b $00
; Unknown data at address 00304f0f.
	dc.b $00
; Unknown data at address 00304f10.
	dc.b $00
; Unknown data at address 00304f11.
	dc.b $00
; Unknown data at address 00304f12.
	dc.b $00
; Unknown data at address 00304f13.
	dc.b $00
; Unknown data at address 00304f14.
	dc.b $00
; Unknown data at address 00304f15.
	dc.b $00
; Unknown data at address 00304f16.
	dc.b $00
; Unknown data at address 00304f17.
	dc.b $00
; Unknown data at address 00304f18.
	dc.b $00
; Unknown data at address 00304f19.
	dc.b $00
; Unknown data at address 00304f1a.
	dc.b $00
; Unknown data at address 00304f1b.
	dc.b $00
; Unknown data at address 00304f1c.
	dc.b $00
; Unknown data at address 00304f1d.
	dc.b $00
; Unknown data at address 00304f1e.
	dc.b $00
; Unknown data at address 00304f1f.
	dc.b $00
; Unknown data at address 00304f20.
	dc.b $00
; Unknown data at address 00304f21.
	dc.b $00
; Unknown data at address 00304f22.
	dc.b $00
; Unknown data at address 00304f23.
	dc.b $00
; Unknown data at address 00304f24.
	dc.b $00
; Unknown data at address 00304f25.
	dc.b $00
; Unknown data at address 00304f26.
	dc.b $00
; Unknown data at address 00304f27.
	dc.b $00
; Unknown data at address 00304f28.
	dc.b $00
; Unknown data at address 00304f29.
	dc.b $00
; Unknown data at address 00304f2a.
	dc.b $00
; Unknown data at address 00304f2b.
	dc.b $00
; Unknown data at address 00304f2c.
	dc.b $00
; Unknown data at address 00304f2d.
	dc.b $00
; Unknown data at address 00304f2e.
	dc.b $00
; Unknown data at address 00304f2f.
	dc.b $00
; Unknown data at address 00304f30.
	dc.b $00
; Unknown data at address 00304f31.
	dc.b $00
; Unknown data at address 00304f32.
	dc.b $00
; Unknown data at address 00304f33.
	dc.b $00
; Unknown data at address 00304f34.
	dc.b $00
; Unknown data at address 00304f35.
	dc.b $00
; Unknown data at address 00304f36.
	dc.b $00
; Unknown data at address 00304f37.
	dc.b $00
; Unknown data at address 00304f38.
	dc.b $00
; Unknown data at address 00304f39.
	dc.b $00
; Unknown data at address 00304f3a.
	dc.b $00
; Unknown data at address 00304f3b.
	dc.b $00
; Unknown data at address 00304f3c.
	dc.b $00
; Unknown data at address 00304f3d.
	dc.b $00
; Unknown data at address 00304f3e.
	dc.b $00
; Unknown data at address 00304f3f.
	dc.b $00
; Unknown data at address 00304f40.
	dc.b $00
; Unknown data at address 00304f41.
	dc.b $00
; Unknown data at address 00304f42.
	dc.b $00
; Unknown data at address 00304f43.
	dc.b $00
; Unknown data at address 00304f44.
	dc.b $00
; Unknown data at address 00304f45.
	dc.b $00
; Unknown data at address 00304f46.
	dc.b $00
; Unknown data at address 00304f47.
	dc.b $00
; Unknown data at address 00304f48.
	dc.b $00
; Unknown data at address 00304f49.
	dc.b $00
; Unknown data at address 00304f4a.
	dc.b $00
; Unknown data at address 00304f4b.
	dc.b $00
; Unknown data at address 00304f4c.
	dc.b $00
; Unknown data at address 00304f4d.
	dc.b $00
; Unknown data at address 00304f4e.
	dc.b $00
; Unknown data at address 00304f4f.
	dc.b $00
; Unknown data at address 00304f50.
	dc.b $00
; Unknown data at address 00304f51.
	dc.b $00
; Unknown data at address 00304f52.
	dc.b $00
; Unknown data at address 00304f53.
	dc.b $00
; Unknown data at address 00304f54.
	dc.b $00
; Unknown data at address 00304f55.
	dc.b $00
; Unknown data at address 00304f56.
	dc.b $00
; Unknown data at address 00304f57.
	dc.b $00
; Unknown data at address 00304f58.
	dc.b $00
; Unknown data at address 00304f59.
	dc.b $00
; Unknown data at address 00304f5a.
	dc.b $00
; Unknown data at address 00304f5b.
	dc.b $00
; Unknown data at address 00304f5c.
	dc.b $00
; Unknown data at address 00304f5d.
	dc.b $00
; Unknown data at address 00304f5e.
	dc.b $00
; Unknown data at address 00304f5f.
	dc.b $00
DAT_00304f60:
	; undefined2
	dc.w $0014
DAT_00304f62:
	; undefined4
	dc.l $00000000
DAT_00304f66:
	; undefined4
	dc.l $00000000
; Unknown data at address 00304f6a.
	dc.b $00
; Unknown data at address 00304f6b.
	dc.b $00
;   }

; #######################
; # HUNK02 - BSS        #
; #######################
	section	hunk02,BSS
;   {
DAT_00304f6c:
	; undefined4
	dx.l 1
DAT_00304f70:
	; undefined4
	dx.l 1
DAT_00304f74:
	; undefined4
	dx.l 1
DAT_00304f78:
	; undefined4
	dx.l 1
DAT_00304f7c:
	; undefined4
	dx.l 1
DAT_00304f80:
	; undefined4
	dx.l 1
DAT_00304f84:
; Unknown data at address 00304f84.
	dx.b 1
; Unknown data at address 00304f85.
	dx.b 1
; Unknown data at address 00304f86.
	dx.b 1
; Unknown data at address 00304f87.
	dx.b 1
; Unknown data at address 00304f88.
	dx.b 1
; Unknown data at address 00304f89.
	dx.b 1
; Unknown data at address 00304f8a.
	dx.b 1
; Unknown data at address 00304f8b.
	dx.b 1
; Unknown data at address 00304f8c.
	dx.b 1
; Unknown data at address 00304f8d.
	dx.b 1
; Unknown data at address 00304f8e.
	dx.b 1
; Unknown data at address 00304f8f.
	dx.b 1
; Unknown data at address 00304f90.
	dx.b 1
; Unknown data at address 00304f91.
	dx.b 1
; Unknown data at address 00304f92.
	dx.b 1
; Unknown data at address 00304f93.
	dx.b 1
; Unknown data at address 00304f94.
	dx.b 1
; Unknown data at address 00304f95.
	dx.b 1
; Unknown data at address 00304f96.
	dx.b 1
; Unknown data at address 00304f97.
	dx.b 1
; Unknown data at address 00304f98.
	dx.b 1
; Unknown data at address 00304f99.
	dx.b 1
; Unknown data at address 00304f9a.
	dx.b 1
; Unknown data at address 00304f9b.
	dx.b 1
; Unknown data at address 00304f9c.
	dx.b 1
; Unknown data at address 00304f9d.
	dx.b 1
; Unknown data at address 00304f9e.
	dx.b 1
; Unknown data at address 00304f9f.
	dx.b 1
; Unknown data at address 00304fa0.
	dx.b 1
; Unknown data at address 00304fa1.
	dx.b 1
; Unknown data at address 00304fa2.
	dx.b 1
; Unknown data at address 00304fa3.
	dx.b 1
; Unknown data at address 00304fa4.
	dx.b 1
; Unknown data at address 00304fa5.
	dx.b 1
; Unknown data at address 00304fa6.
	dx.b 1
; Unknown data at address 00304fa7.
	dx.b 1
; Unknown data at address 00304fa8.
	dx.b 1
; Unknown data at address 00304fa9.
	dx.b 1
; Unknown data at address 00304faa.
	dx.b 1
; Unknown data at address 00304fab.
	dx.b 1
; Unknown data at address 00304fac.
	dx.b 1
; Unknown data at address 00304fad.
	dx.b 1
; Unknown data at address 00304fae.
	dx.b 1
; Unknown data at address 00304faf.
	dx.b 1
; Unknown data at address 00304fb0.
	dx.b 1
; Unknown data at address 00304fb1.
	dx.b 1
; Unknown data at address 00304fb2.
	dx.b 1
; Unknown data at address 00304fb3.
	dx.b 1
; Unknown data at address 00304fb4.
	dx.b 1
; Unknown data at address 00304fb5.
	dx.b 1
; Unknown data at address 00304fb6.
	dx.b 1
; Unknown data at address 00304fb7.
	dx.b 1
; Unknown data at address 00304fb8.
	dx.b 1
; Unknown data at address 00304fb9.
	dx.b 1
; Unknown data at address 00304fba.
	dx.b 1
; Unknown data at address 00304fbb.
	dx.b 1
; Unknown data at address 00304fbc.
	dx.b 1
; Unknown data at address 00304fbd.
	dx.b 1
; Unknown data at address 00304fbe.
	dx.b 1
; Unknown data at address 00304fbf.
	dx.b 1
; Unknown data at address 00304fc0.
	dx.b 1
; Unknown data at address 00304fc1.
	dx.b 1
; Unknown data at address 00304fc2.
	dx.b 1
; Unknown data at address 00304fc3.
	dx.b 1
; Unknown data at address 00304fc4.
	dx.b 1
; Unknown data at address 00304fc5.
	dx.b 1
; Unknown data at address 00304fc6.
	dx.b 1
; Unknown data at address 00304fc7.
	dx.b 1
; Unknown data at address 00304fc8.
	dx.b 1
; Unknown data at address 00304fc9.
	dx.b 1
; Unknown data at address 00304fca.
	dx.b 1
; Unknown data at address 00304fcb.
	dx.b 1
; Unknown data at address 00304fcc.
	dx.b 1
; Unknown data at address 00304fcd.
	dx.b 1
; Unknown data at address 00304fce.
	dx.b 1
; Unknown data at address 00304fcf.
	dx.b 1
; Unknown data at address 00304fd0.
	dx.b 1
; Unknown data at address 00304fd1.
	dx.b 1
; Unknown data at address 00304fd2.
	dx.b 1
; Unknown data at address 00304fd3.
	dx.b 1
; Unknown data at address 00304fd4.
	dx.b 1
; Unknown data at address 00304fd5.
	dx.b 1
; Unknown data at address 00304fd6.
	dx.b 1
; Unknown data at address 00304fd7.
	dx.b 1
; Unknown data at address 00304fd8.
	dx.b 1
; Unknown data at address 00304fd9.
	dx.b 1
; Unknown data at address 00304fda.
	dx.b 1
; Unknown data at address 00304fdb.
	dx.b 1
; Unknown data at address 00304fdc.
	dx.b 1
; Unknown data at address 00304fdd.
	dx.b 1
; Unknown data at address 00304fde.
	dx.b 1
; Unknown data at address 00304fdf.
	dx.b 1
; Unknown data at address 00304fe0.
	dx.b 1
; Unknown data at address 00304fe1.
	dx.b 1
; Unknown data at address 00304fe2.
	dx.b 1
; Unknown data at address 00304fe3.
	dx.b 1
; Unknown data at address 00304fe4.
	dx.b 1
; Unknown data at address 00304fe5.
	dx.b 1
; Unknown data at address 00304fe6.
	dx.b 1
; Unknown data at address 00304fe7.
	dx.b 1
DAT_00304fe8:
	; undefined1
	dx.b 1
; Unknown data at address 00304fe9.
	dx.b 1
DAT_00304fea:
; Unknown data at address 00304fea.
	dx.b 1
DAT_00304feb:
; Unknown data at address 00304feb.
	dx.b 1
; Unknown data at address 00304fec.
	dx.b 1
; Unknown data at address 00304fed.
	dx.b 1
; Unknown data at address 00304fee.
	dx.b 1
; Unknown data at address 00304fef.
	dx.b 1
; Unknown data at address 00304ff0.
	dx.b 1
; Unknown data at address 00304ff1.
	dx.b 1
; Unknown data at address 00304ff2.
	dx.b 1
; Unknown data at address 00304ff3.
	dx.b 1
; Unknown data at address 00304ff4.
	dx.b 1
; Unknown data at address 00304ff5.
	dx.b 1
; Unknown data at address 00304ff6.
	dx.b 1
; Unknown data at address 00304ff7.
	dx.b 1
; Unknown data at address 00304ff8.
	dx.b 1
; Unknown data at address 00304ff9.
	dx.b 1
; Unknown data at address 00304ffa.
	dx.b 1
; Unknown data at address 00304ffb.
	dx.b 1
; Unknown data at address 00304ffc.
	dx.b 1
; Unknown data at address 00304ffd.
	dx.b 1
; Unknown data at address 00304ffe.
	dx.b 1
; Unknown data at address 00304fff.
	dx.b 1
; Unknown data at address 00305000.
	dx.b 1
; Unknown data at address 00305001.
	dx.b 1
; Unknown data at address 00305002.
	dx.b 1
; Unknown data at address 00305003.
	dx.b 1
; Unknown data at address 00305004.
	dx.b 1
; Unknown data at address 00305005.
	dx.b 1
; Unknown data at address 00305006.
	dx.b 1
; Unknown data at address 00305007.
	dx.b 1
; Unknown data at address 00305008.
	dx.b 1
; Unknown data at address 00305009.
	dx.b 1
; Unknown data at address 0030500a.
	dx.b 1
; Unknown data at address 0030500b.
	dx.b 1
; Unknown data at address 0030500c.
	dx.b 1
; Unknown data at address 0030500d.
	dx.b 1
; Unknown data at address 0030500e.
	dx.b 1
; Unknown data at address 0030500f.
	dx.b 1
; Unknown data at address 00305010.
	dx.b 1
; Unknown data at address 00305011.
	dx.b 1
; Unknown data at address 00305012.
	dx.b 1
; Unknown data at address 00305013.
	dx.b 1
; Unknown data at address 00305014.
	dx.b 1
; Unknown data at address 00305015.
	dx.b 1
; Unknown data at address 00305016.
	dx.b 1
; Unknown data at address 00305017.
	dx.b 1
; Unknown data at address 00305018.
	dx.b 1
; Unknown data at address 00305019.
	dx.b 1
; Unknown data at address 0030501a.
	dx.b 1
; Unknown data at address 0030501b.
	dx.b 1
; Unknown data at address 0030501c.
	dx.b 1
; Unknown data at address 0030501d.
	dx.b 1
; Unknown data at address 0030501e.
	dx.b 1
; Unknown data at address 0030501f.
	dx.b 1
; Unknown data at address 00305020.
	dx.b 1
; Unknown data at address 00305021.
	dx.b 1
; Unknown data at address 00305022.
	dx.b 1
; Unknown data at address 00305023.
	dx.b 1
; Unknown data at address 00305024.
	dx.b 1
; Unknown data at address 00305025.
	dx.b 1
; Unknown data at address 00305026.
	dx.b 1
; Unknown data at address 00305027.
	dx.b 1
; Unknown data at address 00305028.
	dx.b 1
; Unknown data at address 00305029.
	dx.b 1
; Unknown data at address 0030502a.
	dx.b 1
; Unknown data at address 0030502b.
	dx.b 1
; Unknown data at address 0030502c.
	dx.b 1
; Unknown data at address 0030502d.
	dx.b 1
; Unknown data at address 0030502e.
	dx.b 1
; Unknown data at address 0030502f.
	dx.b 1
; Unknown data at address 00305030.
	dx.b 1
; Unknown data at address 00305031.
	dx.b 1
; Unknown data at address 00305032.
	dx.b 1
; Unknown data at address 00305033.
	dx.b 1
; Unknown data at address 00305034.
	dx.b 1
; Unknown data at address 00305035.
	dx.b 1
; Unknown data at address 00305036.
	dx.b 1
; Unknown data at address 00305037.
	dx.b 1
; Unknown data at address 00305038.
	dx.b 1
; Unknown data at address 00305039.
	dx.b 1
; Unknown data at address 0030503a.
	dx.b 1
; Unknown data at address 0030503b.
	dx.b 1
; Unknown data at address 0030503c.
	dx.b 1
; Unknown data at address 0030503d.
	dx.b 1
; Unknown data at address 0030503e.
	dx.b 1
; Unknown data at address 0030503f.
	dx.b 1
; Unknown data at address 00305040.
	dx.b 1
; Unknown data at address 00305041.
	dx.b 1
; Unknown data at address 00305042.
	dx.b 1
; Unknown data at address 00305043.
	dx.b 1
; Unknown data at address 00305044.
	dx.b 1
; Unknown data at address 00305045.
	dx.b 1
; Unknown data at address 00305046.
	dx.b 1
; Unknown data at address 00305047.
	dx.b 1
; Unknown data at address 00305048.
	dx.b 1
; Unknown data at address 00305049.
	dx.b 1
; Unknown data at address 0030504a.
	dx.b 1
; Unknown data at address 0030504b.
	dx.b 1
; Unknown data at address 0030504c.
	dx.b 1
; Unknown data at address 0030504d.
	dx.b 1
; Unknown data at address 0030504e.
	dx.b 1
; Unknown data at address 0030504f.
	dx.b 1
; Unknown data at address 00305050.
	dx.b 1
; Unknown data at address 00305051.
	dx.b 1
; Unknown data at address 00305052.
	dx.b 1
; Unknown data at address 00305053.
	dx.b 1
; Unknown data at address 00305054.
	dx.b 1
; Unknown data at address 00305055.
	dx.b 1
; Unknown data at address 00305056.
	dx.b 1
; Unknown data at address 00305057.
	dx.b 1
; Unknown data at address 00305058.
	dx.b 1
; Unknown data at address 00305059.
	dx.b 1
; Unknown data at address 0030505a.
	dx.b 1
; Unknown data at address 0030505b.
	dx.b 1
; Unknown data at address 0030505c.
	dx.b 1
; Unknown data at address 0030505d.
	dx.b 1
; Unknown data at address 0030505e.
	dx.b 1
; Unknown data at address 0030505f.
	dx.b 1
; Unknown data at address 00305060.
	dx.b 1
; Unknown data at address 00305061.
	dx.b 1
; Unknown data at address 00305062.
	dx.b 1
; Unknown data at address 00305063.
	dx.b 1
; Unknown data at address 00305064.
	dx.b 1
; Unknown data at address 00305065.
	dx.b 1
; Unknown data at address 00305066.
	dx.b 1
; Unknown data at address 00305067.
	dx.b 1
; Unknown data at address 00305068.
	dx.b 1
; Unknown data at address 00305069.
	dx.b 1
; Unknown data at address 0030506a.
	dx.b 1
; Unknown data at address 0030506b.
	dx.b 1
; Unknown data at address 0030506c.
	dx.b 1
; Unknown data at address 0030506d.
	dx.b 1
; Unknown data at address 0030506e.
	dx.b 1
; Unknown data at address 0030506f.
	dx.b 1
; Unknown data at address 00305070.
	dx.b 1
; Unknown data at address 00305071.
	dx.b 1
; Unknown data at address 00305072.
	dx.b 1
; Unknown data at address 00305073.
	dx.b 1
; Unknown data at address 00305074.
	dx.b 1
; Unknown data at address 00305075.
	dx.b 1
; Unknown data at address 00305076.
	dx.b 1
; Unknown data at address 00305077.
	dx.b 1
; Unknown data at address 00305078.
	dx.b 1
; Unknown data at address 00305079.
	dx.b 1
; Unknown data at address 0030507a.
	dx.b 1
; Unknown data at address 0030507b.
	dx.b 1
; Unknown data at address 0030507c.
	dx.b 1
; Unknown data at address 0030507d.
	dx.b 1
; Unknown data at address 0030507e.
	dx.b 1
; Unknown data at address 0030507f.
	dx.b 1
; Unknown data at address 00305080.
	dx.b 1
; Unknown data at address 00305081.
	dx.b 1
; Unknown data at address 00305082.
	dx.b 1
; Unknown data at address 00305083.
	dx.b 1
; Unknown data at address 00305084.
	dx.b 1
; Unknown data at address 00305085.
	dx.b 1
; Unknown data at address 00305086.
	dx.b 1
; Unknown data at address 00305087.
	dx.b 1
; Unknown data at address 00305088.
	dx.b 1
; Unknown data at address 00305089.
	dx.b 1
; Unknown data at address 0030508a.
	dx.b 1
; Unknown data at address 0030508b.
	dx.b 1
; Unknown data at address 0030508c.
	dx.b 1
; Unknown data at address 0030508d.
	dx.b 1
; Unknown data at address 0030508e.
	dx.b 1
; Unknown data at address 0030508f.
	dx.b 1
; Unknown data at address 00305090.
	dx.b 1
; Unknown data at address 00305091.
	dx.b 1
; Unknown data at address 00305092.
	dx.b 1
; Unknown data at address 00305093.
	dx.b 1
; Unknown data at address 00305094.
	dx.b 1
; Unknown data at address 00305095.
	dx.b 1
; Unknown data at address 00305096.
	dx.b 1
; Unknown data at address 00305097.
	dx.b 1
; Unknown data at address 00305098.
	dx.b 1
; Unknown data at address 00305099.
	dx.b 1
; Unknown data at address 0030509a.
	dx.b 1
; Unknown data at address 0030509b.
	dx.b 1
; Unknown data at address 0030509c.
	dx.b 1
; Unknown data at address 0030509d.
	dx.b 1
; Unknown data at address 0030509e.
	dx.b 1
; Unknown data at address 0030509f.
	dx.b 1
; Unknown data at address 003050a0.
	dx.b 1
; Unknown data at address 003050a1.
	dx.b 1
; Unknown data at address 003050a2.
	dx.b 1
; Unknown data at address 003050a3.
	dx.b 1
; Unknown data at address 003050a4.
	dx.b 1
; Unknown data at address 003050a5.
	dx.b 1
; Unknown data at address 003050a6.
	dx.b 1
; Unknown data at address 003050a7.
	dx.b 1
; Unknown data at address 003050a8.
	dx.b 1
; Unknown data at address 003050a9.
	dx.b 1
; Unknown data at address 003050aa.
	dx.b 1
; Unknown data at address 003050ab.
	dx.b 1
; Unknown data at address 003050ac.
	dx.b 1
; Unknown data at address 003050ad.
	dx.b 1
; Unknown data at address 003050ae.
	dx.b 1
; Unknown data at address 003050af.
	dx.b 1
; Unknown data at address 003050b0.
	dx.b 1
; Unknown data at address 003050b1.
	dx.b 1
; Unknown data at address 003050b2.
	dx.b 1
; Unknown data at address 003050b3.
	dx.b 1
; Unknown data at address 003050b4.
	dx.b 1
; Unknown data at address 003050b5.
	dx.b 1
; Unknown data at address 003050b6.
	dx.b 1
; Unknown data at address 003050b7.
	dx.b 1
; Unknown data at address 003050b8.
	dx.b 1
; Unknown data at address 003050b9.
	dx.b 1
; Unknown data at address 003050ba.
	dx.b 1
; Unknown data at address 003050bb.
	dx.b 1
; Unknown data at address 003050bc.
	dx.b 1
; Unknown data at address 003050bd.
	dx.b 1
; Unknown data at address 003050be.
	dx.b 1
; Unknown data at address 003050bf.
	dx.b 1
; Unknown data at address 003050c0.
	dx.b 1
; Unknown data at address 003050c1.
	dx.b 1
; Unknown data at address 003050c2.
	dx.b 1
; Unknown data at address 003050c3.
	dx.b 1
; Unknown data at address 003050c4.
	dx.b 1
; Unknown data at address 003050c5.
	dx.b 1
; Unknown data at address 003050c6.
	dx.b 1
; Unknown data at address 003050c7.
	dx.b 1
; Unknown data at address 003050c8.
	dx.b 1
; Unknown data at address 003050c9.
	dx.b 1
; Unknown data at address 003050ca.
	dx.b 1
; Unknown data at address 003050cb.
	dx.b 1
; Unknown data at address 003050cc.
	dx.b 1
; Unknown data at address 003050cd.
	dx.b 1
; Unknown data at address 003050ce.
	dx.b 1
; Unknown data at address 003050cf.
	dx.b 1
; Unknown data at address 003050d0.
	dx.b 1
; Unknown data at address 003050d1.
	dx.b 1
; Unknown data at address 003050d2.
	dx.b 1
; Unknown data at address 003050d3.
	dx.b 1
; Unknown data at address 003050d4.
	dx.b 1
; Unknown data at address 003050d5.
	dx.b 1
; Unknown data at address 003050d6.
	dx.b 1
; Unknown data at address 003050d7.
	dx.b 1
; Unknown data at address 003050d8.
	dx.b 1
; Unknown data at address 003050d9.
	dx.b 1
; Unknown data at address 003050da.
	dx.b 1
; Unknown data at address 003050db.
	dx.b 1
; Unknown data at address 003050dc.
	dx.b 1
; Unknown data at address 003050dd.
	dx.b 1
; Unknown data at address 003050de.
	dx.b 1
; Unknown data at address 003050df.
	dx.b 1
; Unknown data at address 003050e0.
	dx.b 1
; Unknown data at address 003050e1.
	dx.b 1
; Unknown data at address 003050e2.
	dx.b 1
; Unknown data at address 003050e3.
	dx.b 1
; Unknown data at address 003050e4.
	dx.b 1
; Unknown data at address 003050e5.
	dx.b 1
; Unknown data at address 003050e6.
	dx.b 1
; Unknown data at address 003050e7.
	dx.b 1
DAT_003050e8:
	; undefined1
	dx.b 1
DAT_003050e9:
; Unknown data at address 003050e9.
	dx.b 1
DAT_003050ea:
; Unknown data at address 003050ea.
	dx.b 1
; Unknown data at address 003050eb.
	dx.b 1
DAT_003050ec:
; Unknown data at address 003050ec.
	dx.b 1
; Unknown data at address 003050ed.
	dx.b 1
DAT_003050ee:
; Unknown data at address 003050ee.
	dx.b 1
; Unknown data at address 003050ef.
	dx.b 1
DAT_003050f0:
	; undefined4
	dx.l 1
DAT_003050f4:
; Unknown data at address 003050f4.
	dx.b 1
; Unknown data at address 003050f5.
	dx.b 1
; Unknown data at address 003050f6.
	dx.b 1
; Unknown data at address 003050f7.
	dx.b 1
DAT_003050f8:
	; undefined4
	dx.l 1
_SysBase:
	; ExecBase *
	dx.l 1
_DOSBase:
	; DosLibrary *
	dx.l 1
DAT_00305104:
	; undefined4
	dx.l 1
DAT_00305108:
; Unknown data at address 00305108.
	dx.b 1
; Unknown data at address 00305109.
	dx.b 1
; Unknown data at address 0030510a.
	dx.b 1
; Unknown data at address 0030510b.
	dx.b 1
DAT_0030510c:
	; undefined4
	dx.l 1
DAT_00305110:
	; undefined4
	dx.l 1
DAT_00305114:
	; undefined4
	dx.l 1
DAT_00305118:
	; undefined4
	dx.l 1
DAT_0030511c:
	; undefined4
	dx.l 1
_IconBase:
	; Library *
	dx.l 1
DAT_00305124:
	; undefined4
	dx.l 1
DAT_00305128:
	; undefined4
	dx.l 1
DAT_0030512c:
	; undefined4
	dx.l 1
DAT_00305130:
	; undefined4
	dx.l 1
DAT_00305134:
	; undefined4
	dx.l 1
DAT_00305138:
	; undefined4
	dx.l 1
DAT_0030513c:
	; undefined4
	dx.l 1
DAT_00305140:
	; undefined4
	dx.l 1
;   }
