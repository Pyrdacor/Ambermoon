
; #######################
; # HUNK00 - CODE       #
; #######################
	section	hunk00,CODE
;   {
start:
	jmp (FUN_00222602,PC)
FUN_0021f004:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	clr.w (-$0002,A5)
	jsr (FUN_00221ca8,PC)
	jsr (FUN_00221b78,PC)
	jsr (FUN_00221d22,PC)
	tst.w DAT_00223e46
	beq.b LAB_0021f03c
	pea $000003ed
	pea (s_CONSOLE__0021f412,PC)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,DAT_00223cdc
	bra.b LAB_0021f052
LAB_0021f03c:
	pea $000003ed
	pea (DAT_0021f41b,PC)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,DAT_00223cdc
LAB_0021f052:
	tst.w DAT_00223e48
	beq.w LAB_0021f1c2
	pea (s_C_Install_0021f41d,PC)
	jsr (FUN_00221ce6,PC)
	addq.w #$00000004,SP
	tst.w D0
	bne.b LAB_0021f0c4
	pea (s_The_AMBERMOON_installation_progr_0021f427,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_command_in_the__C____directory_o_0021f464,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_from_AMBERMOON_Disk_A_und_re_sta_0021f4a1,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__Please_press__RETURN___0021f4d3,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	pea (DAT_0021f4ec,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	move.l DAT_00223cdc,-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	pea $00000005
	jsr FUN_0022360e
	addq.w #$00000004,SP
LAB_0021f0c4:
	pea (s_SYS_System_Format_0021f4ee,PC)
	jsr (FUN_00221ce6,PC)
	addq.w #$00000004,SP
	tst.w D0
	bne.b LAB_0021f12c
	pea (s_The_AMBERMOON_installation_progr_0021f500,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_command_in_the__System____direct_0021f53c,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_from_AMBERMOON_Disk_A_und_re_sta_0021f57e,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__Please_press__RETURN___0021f5b0,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	pea (DAT_0021f5c9,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	move.l DAT_00223cdc,-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	pea $00000005
	jsr FUN_0022360e
	addq.w #$00000004,SP
LAB_0021f12c:
	pea (s_SYS_System_More_0021f5cb,PC)
	jsr (FUN_00221ce6,PC)
	addq.w #$00000004,SP
	tst.w D0
	beq.b LAB_0021f144
	move.w #$0001,DAT_00223e4a
	bra.b LAB_0021f1c0
LAB_0021f144:
	pea (s_SYS_Utilities_More_0021f5db,PC)
	jsr (FUN_00221ce6,PC)
	addq.w #$00000004,SP
	tst.w D0
	beq.b LAB_0021f15a
	clr.w DAT_00223e4a
	bra.b LAB_0021f1c0
LAB_0021f15a:
	pea (s_The_AMBERMOON_installation_progr_0021f5ee,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_command_either_in_the__System____0021f628,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_of_your_hard_disk__Copy_this_fro_0021f669,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_this_program__0021f6aa,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__Please_press__RETURN___0021f6b9,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	pea (DAT_0021f6d2,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	move.l DAT_00223cdc,-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	pea $00000005
	jsr FUN_0022360e
	addq.w #$00000004,SP
LAB_0021f1c0:
	bra.b LAB_0021f22c
LAB_0021f1c2:
	pea (s_OS_commands_are_being_copied____0021f6d4,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_0021f6f5,PC)
	jsr (FUN_002215d2,PC)
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Copy_0021f70e,PC)
	pea (s_AMBER_A_C_Copy_0021f6ff,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Install_0021f72f,PC)
	pea (s_AMBER_A_C_Install_0021f71d,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Run_0021f74f,PC)
	pea (s_AMBER_A_C_Run_0021f741,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Assign_0021f76e,PC)
	pea (s_AMBER_A_C_Assign_0021f75d,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_Format_0021f795,PC)
	pea (s_AMBER_A_System_Format_0021f77f,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_RAM_AM2_C_More_0021f7ba,PC)
	pea (s_AMBER_A_System_More_0021f7a6,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
LAB_0021f22c:
	pea (DAT_0021f7c9,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__OPTIONS__0021f7cb,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_0021f7da,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__1___Install_AMBERMOON_on_your_h_0021f7dc,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s___If_you_want_to_play_AMBERMOON_f_0021f807,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_0021f840,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__2___Create_save_game_disk__disk_0021f842,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s___If_you_want_to_play_AMBERMOON_f_0021f868,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_0021f89e,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__3___Create_a_boot_disk_for_use_w_0021f8a0,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s___If_you_want_to_play_AMBERMOON_f_0021f8d6,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__but_you_don_t_have_enough_memor_0021f90f,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_0021f937,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__4___Read_the_Troubleshooting_do_0021f939,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s___Additional_information_about_A_0021f962,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__should_have_any_problems_with_t_0021f99a,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_0021f9c7,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__5___Quit__0021f9c9,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s___Leave_the_istallation_program__0021f9d5,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_0021f9fa,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_Please_choose_an_option__0021f9fc,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000001
	pea (-$0003,A5)
	jsr (FUN_00220fd8,PC)
	addq.w #$00000008,SP
	move.b (-$0003,A5),D0
	ext.w D0
	ext.l D0
	bra.b LAB_0021f36a
caseD_31:
	jsr (FUN_0021fa84,PC)
	bra.b caseD_5
caseD_32:
	jsr (FUN_002201c8,PC)
	bra.b caseD_5
caseD_33:
	jsr (FUN_00220508,PC)
	bra.b caseD_5
caseD_34:
	jsr (FUN_00220d2e,PC)
	bra.b caseD_5
caseD_35:
	move.w #$0001,(-$0002,A5)
	bra.b caseD_5
switchdataD_0021f360:
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
LAB_0021f36a:
	sub.l #$00000031,D0
	cmp.l #$00000005,D0
	bcc.b caseD_5
	asl.l #$00000001,D0
	move.w (switchdataD_0021f360,PC,D0.w),D0
switchD:
	jmp (caseD_5-2,PC,D0.w)
caseD_5:
	tst.w (-$0002,A5)
	beq.w LAB_0021f22c
	tst.w DAT_00223e48
	bne.b LAB_0021f3e6
	pea (s_RAM_AM2_C_Copy_0021fa16,PC)
	jsr thunk_FUN_0022386e
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Install_0021fa25,PC)
	jsr thunk_FUN_0022386e
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Run_0021fa37,PC)
	jsr thunk_FUN_0022386e
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Install_0021fa45,PC)
	jsr thunk_FUN_0022386e
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_Format_0021fa57,PC)
	jsr thunk_FUN_0022386e
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_More_0021fa68,PC)
	jsr thunk_FUN_0022386e
	addq.w #$00000004,SP
	pea (s_RAM_AM2_C_0021fa77,PC)
	jsr thunk_FUN_0022386e
	addq.w #$00000004,SP
LAB_0021f3e6:
	pea (DAT_0021fa81,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	move.l DAT_00223cdc,-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	clr.l -(SP)
	jsr FUN_0022360e
	addq.w #$00000004,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_CONSOLE__0021f412:
	dc.b "CONSOLE:",0
DAT_0021f41b:
; Unknown data at address 0021f41b.
	dc.b $2a
; Unknown data at address 0021f41c.
	dc.b $00
s_C_Install_0021f41d:
	dc.b "C:Install",0
s_The_AMBERMOON_installation_progr_0021f427:
	dc.b "The AMBERMOON installation program requires the >Install< -",$a,0
s_command_in_the__C____directory_o_0021f464:
	dc.b "command in the >C< - directory of your hard-disk. Copy this",$a,0
s_from_AMBERMOON_Disk_A_und_re_sta_0021f4a1:
	dc.b "from AMBERMOON Disk A und re-start this program.",$a,0
s__Please_press__RETURN___0021f4d3:
	dc.b $a,"Please press >RETURN<.",$a,0
DAT_0021f4ec:
; Unknown data at address 0021f4ec.
	dc.b $0c
; Unknown data at address 0021f4ed.
	dc.b $00
s_SYS_System_Format_0021f4ee:
	dc.b "SYS:System/Format",0
s_The_AMBERMOON_installation_progr_0021f500:
	dc.b "The AMBERMOON installation program requires the >Format< -",$a,0
s_command_in_the__System____direct_0021f53c:
	dc.b "command in the >System< - directory of your hard-disk. Copy this",$a,0
s_from_AMBERMOON_Disk_A_und_re_sta_0021f57e:
	dc.b "from AMBERMOON Disk A und re-start this program.",$a,0
s__Please_press__RETURN___0021f5b0:
	dc.b $a,"Please press >RETURN<.",$a,0
DAT_0021f5c9:
; Unknown data at address 0021f5c9.
	dc.b $0c
; Unknown data at address 0021f5ca.
	dc.b $00
s_SYS_System_More_0021f5cb:
	dc.b "SYS:System/More",0
s_SYS_Utilities_More_0021f5db:
	dc.b "SYS:Utilities/More",0
s_The_AMBERMOON_installation_progr_0021f5ee:
	dc.b "The AMBERMOON installation program requires the >More< -",$a,0
s_command_either_in_the__System____0021f628:
	dc.b "command either in the >System< - or the >Utilities< - directory",$a,0
s_of_your_hard_disk__Copy_this_fro_0021f669:
	dc.b "of your hard-disk. Copy this from AMBERMOON Disk A und re-start",$a,0
s_this_program__0021f6aa:
	dc.b "this program.",$a,0
s__Please_press__RETURN___0021f6b9:
	dc.b $a,"Please press >RETURN<.",$a,0
DAT_0021f6d2:
; Unknown data at address 0021f6d2.
	dc.b $0c
; Unknown data at address 0021f6d3.
	dc.b $00
s_OS_commands_are_being_copied____0021f6d4:
	dc.b "OS-commands are being copied...",$a,0
s_RAM_AM2_C_0021f6f5:
	dc.b "RAM:AM2_C",0
s_AMBER_A_C_Copy_0021f6ff:
	dc.b "AMBER_A:C/Copy",0
s_RAM_AM2_C_Copy_0021f70e:
	dc.b "RAM:AM2_C/Copy",0
s_AMBER_A_C_Install_0021f71d:
	dc.b "AMBER_A:C/Install",0
s_RAM_AM2_C_Install_0021f72f:
	dc.b "RAM:AM2_C/Install",0
s_AMBER_A_C_Run_0021f741:
	dc.b "AMBER_A:C/Run",0
s_RAM_AM2_C_Run_0021f74f:
	dc.b "RAM:AM2_C/Run",0
s_AMBER_A_C_Assign_0021f75d:
	dc.b "AMBER_A:C/Assign",0
s_RAM_AM2_C_Assign_0021f76e:
	dc.b "RAM:AM2_C/Assign",0
s_AMBER_A_System_Format_0021f77f:
	dc.b "AMBER_A:System/Format",0
s_RAM_AM2_C_Format_0021f795:
	dc.b "RAM:AM2_C/Format",0
s_AMBER_A_System_More_0021f7a6:
	dc.b "AMBER_A:System/More",0
s_RAM_AM2_C_More_0021f7ba:
	dc.b "RAM:AM2_C/More",0
DAT_0021f7c9:
; Unknown data at address 0021f7c9.
	dc.b $0c
; Unknown data at address 0021f7ca.
	dc.b $00
s__OPTIONS__0021f7cb:
	dc.b "     OPTIONS:",$a,0
DAT_0021f7da:
; Unknown data at address 0021f7da.
	dc.b $0a
; Unknown data at address 0021f7db.
	dc.b $00
s__1___Install_AMBERMOON_on_your_h_0021f7dc:
	dc.b " 1 - Install AMBERMOON on your hard-disk.",$a,0
s___If_you_want_to_play_AMBERMOON_f_0021f807:
	dc.b "    (If you want to play AMBERMOON from your hard-disk)",$a,0
DAT_0021f840:
; Unknown data at address 0021f840.
	dc.b $0a
; Unknown data at address 0021f841.
	dc.b $00
s__2___Create_save_game_disk__disk_0021f842:
	dc.b " 2 - Create save-game disk (disk J).",$a,0
s___If_you_want_to_play_AMBERMOON_f_0021f868:
	dc.b "    (If you want to play AMBERMOON from floppy disk)",$a,0
DAT_0021f89e:
; Unknown data at address 0021f89e.
	dc.b $0a
; Unknown data at address 0021f89f.
	dc.b $00
s__3___Create_a_boot_disk_for_use_w_0021f8a0:
	dc.b " 3 - Create a boot-disk for use with your hard-disk.",$a,0
s___If_you_want_to_play_AMBERMOON_f_0021f8d6:
	dc.b "    (If you want to play AMBERMOON from your hard-disk,",$a,0
s__but_you_don_t_have_enough_memor_0021f90f:
	dc.b "     but you don't have enough memory)",$a,0
DAT_0021f937:
; Unknown data at address 0021f937.
	dc.b $0a
; Unknown data at address 0021f938.
	dc.b $00
s__4___Read_the_Troubleshooting_do_0021f939:
	dc.b " 4 - Read the Troubleshooting-document.",$a,0
s___Additional_information_about_A_0021f962:
	dc.b "    (Additional information about AMBERMOON and if you",$a,0
s__should_have_any_problems_with_t_0021f99a:
	dc.b "    should have any problems with the game)",$a,0
DAT_0021f9c7:
; Unknown data at address 0021f9c7.
	dc.b $0a
; Unknown data at address 0021f9c8.
	dc.b $00
s__5___Quit__0021f9c9:
	dc.b " 5 - Quit.",$a,0
s___Leave_the_istallation_program__0021f9d5:
	dc.b "    (Leave the istallation program)",$a,0
DAT_0021f9fa:
; Unknown data at address 0021f9fa.
	dc.b $0a
; Unknown data at address 0021f9fb.
	dc.b $00
s_Please_choose_an_option__0021f9fc:
	dc.b "Please choose an option: ",0
s_RAM_AM2_C_Copy_0021fa16:
	dc.b "RAM:AM2_C/Copy",0
s_RAM_AM2_C_Install_0021fa25:
	dc.b "RAM:AM2_C/Install",0
s_RAM_AM2_C_Run_0021fa37:
	dc.b "RAM:AM2_C/Run",0
s_RAM_AM2_C_Install_0021fa45:
	dc.b "RAM:AM2_C/Install",0
s_RAM_AM2_C_Format_0021fa57:
	dc.b "RAM:AM2_C/Format",0
s_RAM_AM2_C_More_0021fa68:
	dc.b "RAM:AM2_C/More",0
s_RAM_AM2_C_0021fa77:
	dc.b "RAM:AM2_C",0
DAT_0021fa81:
; Unknown data at address 0021fa81.
	dc.b $0c
; Unknown data at address 0021fa82.
	dc.b $00
; Unknown data at address 0021fa83.
	dc.b $00
FUN_0021fa84:
	link.w A5,#-$000002a0
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0004,A5)
	clr.l (-$0008,A5)
LAB_0021fa94:
	pea (DAT_0021fe0c,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_The_program_will_create_it_s_own_0021fe4f,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_EXAMPLE__You_enter__DH0____A_dir_0021fe7d,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_created_on_partition_DH0___and_t_0021febe,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_will_copy_all_the_necessary_file_0021fef7,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_Please_enter_a_path___0021ff2e,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000064
	pea DAT_00223ce0
	jsr (FUN_00220fd8,PC)
	addq.w #$00000008,SP
	pea -2
	pea DAT_00223ce0
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	tst.l (-$0008,A5)
	beq.b LAB_0021fb4e
	pea (-$010c,A5)
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_00223882
	addq.w #$00000008,SP
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	tst.l (-$0108,A5)
	bge.b LAB_0021fb4c
	pea DAT_00223ce0
	pea (s____s__is_not_a_directory__0021ff45,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
	clr.l (-$0008,A5)
LAB_0021fb4c:
	bra.b LAB_0021fb6c
LAB_0021fb4e:
	pea DAT_00223ce0
	pea (s____s__does_not_existt__0021ff60,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
LAB_0021fb6c:
	tst.l (-$0008,A5)
	beq.w LAB_0021fa94
	pea DAT_00223ce0
	jsr FUN_00221e22
	addq.w #$00000004,SP
	subq.l #$00000001,D0
	move.w D0,(-$010e,A5)
	moveq #$00000000,D0
	move.w (-$010e,A5),D0
	lea DAT_00223ce0,A0
	cmpi.b #$0000003a,($00,A0,D0.l)
	beq.b LAB_0021fbc2
	moveq #$00000000,D0
	move.w (-$010e,A5),D0
	lea DAT_00223ce0,A0
	cmpi.b #$0000002f,($00,A0,D0.l)
	beq.b LAB_0021fbc2
	pea (DAT_0021ff78,PC)
	pea DAT_00223ce0
	jsr FUN_00222a14
	addq.w #$00000008,SP
LAB_0021fbc2:
	pea DAT_00223ce0
	pea (s_AMBERMOON_will_be_installed_at___0021ff7a,PC)
	pea (-$01d7,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea (-$01d7,A5)
	jsr (FUN_00221570,PC)
	addq.w #$00000004,SP
	move.b D0,DAT_00223d44
	cmpi.b #$0000004e,DAT_00223d44
	bne.b LAB_0021fc1a
	pea (s_Do_you_want_to_cancel_the_instal_0021ffb5,PC)
	jsr (FUN_00221570,PC)
	addq.w #$00000004,SP
	move.b D0,DAT_00223d44
	cmpi.b #$00000059,DAT_00223d44
	bne.b LAB_0021fc16
LAB_0021fc0e:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_0021fc16:
	bra.w LAB_0021fa94
LAB_0021fc1a:
	pea (DAT_0021ffe4,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea DAT_00223ce0
	pea (s__sAmbermoon_info_00220008,PC)
	pea (-$01d7,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea (s_Ambermoon_00220019,PC)
	pea DAT_00223ce0
	jsr FUN_00222a14
	addq.w #$00000008,SP
	pea DAT_00223ce0
	pea (-$029f,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
	pea (-$029f,A5)
	jsr (FUN_002215d2,PC)
	addq.w #$00000004,SP
	pea (-$01d7,A5)
	pea (s_AMBER_A_Folder_info_00220023,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (s_Installing_disk_A__00220037,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_0022004c,PC)
	pea (-$029f,A5)
	jsr FUN_00222a14
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AMBER_A_Ambermoon_0022004e,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AMBER_A_Ambermoon_info_00220060,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AMBER_A_Ambermoon_install_00220077,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AMBER_A_Ambermoon_install_info_00220091,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (s_Amberfiles_002200b0,PC)
	pea (-$029f,A5)
	jsr FUN_00222a14
	addq.w #$00000008,SP
	pea (-$029f,A5)
	jsr (FUN_002215d2,PC)
	addq.w #$00000004,SP
	pea (DAT_002200bb,PC)
	pea (-$029f,A5)
	jsr FUN_00222a14
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AMBER_A_AM2_CPU_002200bd,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_Button_graphics,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP	
	pea (-$029f,A5)
	pea (s_Objects_amb,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP	
	pea (-$029f,A5)
	pea (s_readme_txt,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_Text_amb,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AMBER_A_Keymap_002200de,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	pea (s_AMBER_A_Trouble_doc_002200ed,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	pea (-$029f,A5)
	jsr (FUN_00221608,PC)
	addq.w #$00000004,SP
	pea (-$029f,A5)
	jsr (FUN_002216c8,PC)
	addq.w #$00000004,SP
	pea (s__Initial_saved_game_is_being_cop_00220101,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (-$029f,A5)
	pea (s__sSave_00__00220127,PC)
	pea (-$01d7,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea (-$01d7,A5)
	pea (s_AMBER_A_Initial____00220132,PC)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	move.w #$0002,(-$010e,A5)
	bra.b LAB_0021fdd0
LAB_0021fd7c:
	moveq #$00000000,D0
	move.w (-$010e,A5),D0
	add.l #$00000040,D0
	move.b D0,(-$010f,A5)
	move.b (-$010f,A5),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	pea (s__Installing_disk__c__00220145,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	move.b (-$010f,A5),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	pea (s_AMBER__c____0022015b,PC)
	pea (-$01d7,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea (-$029f,A5)
	pea (-$01d7,A5)
	jsr (FUN_0022149c,PC)
	addq.w #$00000008,SP
	addq.w #$00000001,(-$010e,A5)
LAB_0021fdd0:
	cmpi.w #$0000000a,(-$010e,A5)
	bcs.b LAB_0021fd7c
	move.w #$0001,DAT_00223a40
	pea (s__Installation_complete__00220167,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_To_play__start_AMBERMOON_from_th_00220180,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__Please_press__RETURN___002201ae,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	bra.w LAB_0021fc0e
DAT_0021fe0c:
; Unknown data at address 0021fe0c.
	dc.b $0c
	dc.b $a,"Please enter the path-name where AMBERMOON should be installed.",$a,0
s_The_program_will_create_it_s_own_0021fe4f:
	dc.b "The program will create it's own directory.",$a,$a,0
s_EXAMPLE__You_enter__DH0____A_dir_0021fe7d:
	dc.b "EXAMPLE: You enter >DH0:<. A directory called Ambermoon will be",$a,0
s_created_on_partition_DH0___and_t_0021febe:
	dc.b "created on partition DH0:, and the installation program",$a,0
s_will_copy_all_the_necessary_file_0021fef7:
	dc.b "will copy all the necessary files to this directory.",$a,$a,0
s_Please_enter_a_path___0021ff2e:
	dc.b "Please enter a path : ",0
s____s__is_not_a_directory__0021ff45:
	dc.b $a,'"',"%s",'"'," is not a directory!",$a,0
s____s__does_not_existt__0021ff60:
	dc.b $a,'"',"%s",'"'," does not existt!",$a,0
DAT_0021ff78:
; Unknown data at address 0021ff78.
	dc.b $2f
; Unknown data at address 0021ff79.
	dc.b $00
s_AMBERMOON_will_be_installed_at___0021ff7a:
	dc.b "AMBERMOON will be installed at ",'"',"%sAmbermoon",'"',".",$a,"Okay? (Y/N):",0
s_Do_you_want_to_cancel_the_instal_0021ffb5:
	dc.b "Do you want to cancel the installation? (Y/N):",0
DAT_0021ffe4:
; Unknown data at address 0021ffe4.
	dc.b $0c
	dc.b $a,"AMBERMOON is being installed...",$a,$a,0
s__sAmbermoon_info_00220008:
	dc.b "%sAmbermoon.info",0
s_Ambermoon_00220019:
	dc.b "Ambermoon",0
s_AMBER_A_Folder_info_00220023:
	dc.b "AMBER_A:Folder_info",0
s_Installing_disk_A__00220037:
	dc.b "Installing disk A.",$a,$a,0
DAT_0022004c:
; Unknown data at address 0022004c.
	dc.b $2f
; Unknown data at address 0022004d.
	dc.b $00
s_AMBER_A_Ambermoon_0022004e:
	dc.b "AMBER_A:Ambermoon",0
s_AMBER_A_Ambermoon_info_00220060:
	dc.b "AMBER_A:Ambermoon.info",0
s_AMBER_A_Ambermoon_install_00220077:
	dc.b "AMBER_A:Ambermoon_install",0
s_AMBER_A_Ambermoon_install_info_00220091:
	dc.b "AMBER_A:Ambermoon_install.info",0
s_Amberfiles_002200b0:
	dc.b "Amberfiles",0
DAT_002200bb:
; Unknown data at address 002200bb.
	dc.b $2f
; Unknown data at address 002200bc.
	dc.b $00
s_AMBER_A_AM2_CPU_002200bd:
	dc.b "AMBER_A:AM2_CPU",0
s_Button_graphics:
	dc.b "AMBER_A:Button_graphics",0
s_Objects_amb:
	dc.b "AMBER_A:Objects.amb",0
s_readme_txt:
	dc.b "AMBER_A:readme.txt",0
s_Text_amb:
	dc.b "AMBER_A:Text.amb",0
s_AMBER_A_Keymap_002200de:
	dc.b "AMBER_A:Keymap",0
s_AMBER_A_Trouble_doc_002200ed:
	dc.b "AMBER_A:Trouble.doc",0
s__Initial_saved_game_is_being_cop_00220101:
	dc.b $a,"Initial saved game is being copied.",$a,0
s__sSave_00__00220127:
	dc.b "%sSave.00/",0
s_AMBER_A_Initial____00220132:
	dc.b "AMBER_A:Initial/#?",0
s__Installing_disk__c__00220145:
	dc.b $a,"Installing disk %c.",$a,0
s_AMBER__c____0022015b:
	dc.b "AMBER_%c:#?",0
s__Installation_complete__00220167:
	dc.b $a,"Installation complete.",$a,0
s_To_play__start_AMBERMOON_from_th_00220180:
	dc.b "To play, start AMBERMOON from the Workbench.",$a,0
s__Please_press__RETURN___002201ae:
	dc.b $a,"Please press >RETURN<.",$a,0
; Unknown data at address 002201c7.
	dc.w $0000
FUN_002201c8:
	link.w A5,#-$00000008
	movem.l A6/D3/D2,-(SP)
	pea (DAT_002202cc,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_TIP__Please_take_care_that_the_d_002202f2,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_has_switched_off_before_you_chan_0022031e,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	clr.l -(SP)
	pea (s_AMBER_J_0022034d,PC)
	jsr (FUN_00221092,PC)
	addq.w #$00000008,SP
	tst.w D0
	beq.w LAB_002202b4
	pea -1
	pea (s_AMBER_J__00220355,PC)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_0022384c
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	pea (s_AMBER_J__0022035e,PC)
	jsr (FUN_00221608,PC)
	addq.w #$00000004,SP
	pea (s_AMBER_J__00220367,PC)
	jsr (FUN_002216c8,PC)
	addq.w #$00000004,SP
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022384c
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	pea (s__Initial_save_game_is_being_copi_00220370,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_AMBER_J_Save_00_Party_data_sav_002203b4,PC)
	pea (s_AMBER_A_Initial_Party_data_sav_00220395,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Party_char_amb_002203f2,PC)
	pea (s_AMBER_A_Initial_Party_char_amb_002203d3,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Automap_amb_0022042d,PC)
	pea (s_AMBER_A_Initial_Automap_amb_00220411,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Chest_data_amb_00220468,PC)
	pea (s_AMBER_A_Initial_Chest_data_amb_00220449,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s_AMBER_J_Save_00_Merchant_data_am_002204a9,PC)
	pea (s_AMBER_A_Initial_Merchant_data_am_00220487,PC)
	jsr (FUN_00221850,PC)
	addq.w #$00000008,SP
	pea (s__Save_game_disk_has_been_created_002204cb,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
LAB_002202b4:
	pea (s__Please_press__RETURN___002204ee,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_002202cc:
; Unknown data at address 002202cc.
	dc.b $0c
	dc.b "Save-game disk is being created...",$a,$a,0
s_TIP__Please_take_care_that_the_d_002202f2:
	dc.b "TIP: Please take care that the drive light",$a,0
s_has_switched_off_before_you_chan_0022031e:
	dc.b "has switched off before you change the disk.",$a,$a,0
s_AMBER_J_0022034d:
	dc.b "AMBER_J",0
s_AMBER_J__00220355:
	dc.b "AMBER_J:",0
s_AMBER_J__0022035e:
	dc.b "AMBER_J:",0
s_AMBER_J__00220367:
	dc.b "AMBER_J:",0
s__Initial_save_game_is_being_copi_00220370:
	dc.b $a,"Initial save-game is being copied.",$a,0
s_AMBER_A_Initial_Party_data_sav_00220395:
	dc.b "AMBER_A:Initial/Party_data.sav",0
s_AMBER_J_Save_00_Party_data_sav_002203b4:
	dc.b "AMBER_J:Save.00/Party_data.sav",0
s_AMBER_A_Initial_Party_char_amb_002203d3:
	dc.b "AMBER_A:Initial/Party_char.amb",0
s_AMBER_J_Save_00_Party_char_amb_002203f2:
	dc.b "AMBER_J:Save.00/Party_char.amb",0
s_AMBER_A_Initial_Automap_amb_00220411:
	dc.b "AMBER_A:Initial/Automap.amb",0
s_AMBER_J_Save_00_Automap_amb_0022042d:
	dc.b "AMBER_J:Save.00/Automap.amb",0
s_AMBER_A_Initial_Chest_data_amb_00220449:
	dc.b "AMBER_A:Initial/Chest_data.amb",0
s_AMBER_J_Save_00_Chest_data_amb_00220468:
	dc.b "AMBER_J:Save.00/Chest_data.amb",0
s_AMBER_A_Initial_Merchant_data_am_00220487:
	dc.b "AMBER_A:Initial/Merchant_data.amb",0
s_AMBER_J_Save_00_Merchant_data_am_002204a9:
	dc.b "AMBER_J:Save.00/Merchant_data.amb",0
s__Save_game_disk_has_been_created_002204cb:
	dc.b $a,"Save-game disk has been created.",$a,0
s__Please_press__RETURN___002204ee:
	dc.b $a,"Please press >RETURN<.",$a,0
; Unknown data at address 00220507.
	dc.b $00
FUN_00220508:
	link.w A5,#-$000001fe
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0004,A5)
	clr.l (-$0008,A5)
	clr.l (-$000c,A5)
	clr.l (-$0010,A5)
	tst.w DAT_00223a40
	bne.w LAB_00220696
	pea (s_Have_you_installed_AMBERMOON_on_y_00220934,PC)
	jsr (FUN_00221570,PC)
	addq.w #$00000004,SP
	move.b D0,DAT_00223d44
	cmpi.b #$0000004e,DAT_00223d44
	bne.b LAB_00220574
	pea (DAT_0022096f,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_before_creating_a_boot_disk__0022099d,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__Please_press__RETURN___002209bb,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
LAB_0022056c:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00220574:
	pea (DAT_002209d4,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_Enter_path__00220a0d,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000064
	pea DAT_00223ce0
	jsr (FUN_00220fd8,PC)
	addq.w #$00000008,SP
	pea DAT_00223ce0
	jsr FUN_00221e22
	addq.w #$00000004,SP
	subq.l #$00000001,D0
	move.w D0,(-$01fe,A5)
	moveq #$00000000,D0
	move.w (-$01fe,A5),D0
	lea DAT_00223ce0,A0
	cmpi.b #$0000003a,($00,A0,D0.l)
	beq.b LAB_002205ea
	moveq #$00000000,D0
	move.w (-$01fe,A5),D0
	lea DAT_00223ce0,A0
	cmpi.b #$0000002f,($00,A0,D0.l)
	beq.b LAB_002205ea
	pea (DAT_00220a1a,PC)
	pea DAT_00223ce0
	jsr FUN_00222a14
	addq.w #$00000008,SP
LAB_002205ea:
	pea DAT_00223ce0
	pea (s__sAmbermoon_00220a1c,PC)
	pea (-$01dc,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea -2
	pea (-$01dc,A5)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0010,A5)
	tst.l (-$0010,A5)
	beq.b LAB_00220660
	pea (-$0114,A5)
	move.l (-$0010,A5),-(SP)
	jsr thunk_FUN_00223882
	addq.w #$00000008,SP
	move.l (-$0010,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	tst.l (-$0110,A5)
	bge.b LAB_0022065e
	pea (-$01dc,A5)
	pea (s__The_AMBERMOON_directory_wasn_t_f_00220a28,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
	clr.l (-$0010,A5)
LAB_0022065e:
	bra.b LAB_0022067c
LAB_00220660:
	pea (-$01dc,A5)
	pea (s__The_AMBERMOON_directory_wasn_t_f_00220a58,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
LAB_0022067c:
	tst.l (-$0010,A5)
	beq.w LAB_00220574
	pea (s_Ambermoon__00220a88,PC)
	pea DAT_00223ce0
	jsr FUN_00222a14
	addq.w #$00000008,SP
LAB_00220696:
	pea (DAT_00220a93,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s__the_partition_which_contains_yo_00220ac3,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_Enter_partition_name__00220af8,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000020
	pea (-$01fc,A5)
	jsr (FUN_00220fd8,PC)
	addq.w #$00000008,SP
	pea (-$01fc,A5)
	jsr FUN_00221e22
	addq.w #$00000004,SP
	subq.l #$00000001,D0
	move.w D0,(-$01fe,A5)
	moveq #$00000000,D0
	move.w (-$01fe,A5),D0
	lea (-$01fc,A5),A0
	cmpi.b #$0000003a,($00,A0,D0.l)
	beq.b LAB_002206fc
	pea (DAT_00220b0f,PC)
	pea (-$01fc,A5)
	jsr FUN_00222a14
	addq.w #$00000008,SP
LAB_002206fc:
	pea (-$01fc,A5)
	pea (DAT_00220b11,PC)
	pea (-$01dc,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea -2
	pea (-$01dc,A5)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0010,A5)
	tst.l (-$0010,A5)
	beq.b LAB_00220770
	pea (-$0114,A5)
	move.l (-$0010,A5),-(SP)
	jsr thunk_FUN_00223882
	addq.w #$00000008,SP
	move.l (-$0010,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	tst.l (-$0110,A5)
	bge.b LAB_0022076e
	pea (-$01fc,A5)
	pea (s___C__directory_wasn_t_found_at___00220b15,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
	clr.l (-$0010,A5)
LAB_0022076e:
	bra.b LAB_0022078c
LAB_00220770:
	pea (-$01fc,A5)
	pea (s___C__directory_wasn_t_found_at___00220b3b,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
LAB_0022078c:
	tst.l (-$0010,A5)
	beq.w LAB_00220696
	pea (DAT_00220b61,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_TIP__Please_take_care_that_the_d_00220b82,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (s_has_switched_off_before_you_chan_00220bae,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000001
	pea (s_Ambermoon_boot_disk_00220bdd,PC)
	jsr (FUN_00221092,PC)
	addq.w #$00000008,SP
	tst.w D0
	beq.w LAB_00220920
	pea -1
	pea (s_Ambermoon_boot_disk__00220bf1,PC)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$000c,A5)
	move.l (-$000c,A5),-(SP)
	jsr thunk_FUN_0022384c
	addq.w #$00000004,SP
	move.l D0,(-$0008,A5)
	pea (s_Startup_sequence_is_being_genera_00220c06,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea (DAT_00220c2c,PC)
	jsr (FUN_002215d2,PC)
	addq.w #$00000004,SP
	pea $000003ee
	pea (s_S_startup_sequence_00220c2e,PC)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	pea (-$01fc,A5)
	pea (-$01fc,A5)
	pea (s__sC_Assign_SYS___s_00220c41,PC)
	pea (-$01dc,A5)
	jsr FUN_00222b2a
	lea ($0010,SP),SP
	pea (-$01dc,A5)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea (s_SYS_C_Assign_C__SYS_C_00220c54,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea (s_C_Path_C__SYS_System_add_00220c6a,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea (s_Assign_DEVS__SYS_Devs_00220c83,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea (s_Assign_L__SYS_L_00220c99,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea (s_Assign_LIBS__SYS_Libs_00220ca9,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea DAT_00223ce0
	pea (s_Cd__s_00220cbf,PC)
	pea (-$01dc,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea (-$01dc,A5)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	tst.w DAT_00223e46
	beq.b LAB_002208c6
	pea (s_Ambermoon_BOOT2_00220cc5,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	bra.b LAB_002208f0
LAB_002208c6:
	pea (s_SetMap_gb_00220cd5,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea (s_Ambermoon_BOOT2_00220cdf,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
	pea (s_EndCLI_00220cef,PC)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_0022104a,PC)
	addq.w #$00000008,SP
LAB_002208f0:
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_0022384c
	addq.w #$00000004,SP
	move.l (-$000c,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	pea (s__Boot_disk_has_been_created__00220cf6,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
LAB_00220920:
	pea (s__Please_press__RETURN___00220d14,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	bra.w LAB_0022056c
s_Have_you_installed_AMBERMOON_on_y_00220934:
	dc.b "Have you installed AMBERMOON on your hard-disk yet? (Y/N):",0
DAT_0022096f:
; Unknown data at address 0022096f.
	dc.b $0c
	dc.b $a,"Please install AMBERMOON on your hard-disk",$a,0
s_before_creating_a_boot_disk__0022099d:
	dc.b "before creating a boot-disk.",$a,0
s__Please_press__RETURN___002209bb:
	dc.b $a,"Please press >RETURN<.",$a,0
DAT_002209d4:
; Unknown data at address 002209d4.
	dc.b $0c
	dc.b $a,"Please enter the path where you installed AMBERMOON.",$a,$a,0
s_Enter_path__00220a0d:
	dc.b "Enter path: ",0
DAT_00220a1a:
; Unknown data at address 00220a1a.
	dc.b $2f
; Unknown data at address 00220a1b.
	dc.b $00
s__sAmbermoon_00220a1c:
	dc.b "%sAmbermoon",0
s__The_AMBERMOON_directory_wasn_t_f_00220a28:
	dc.b $a,"The AMBERMOON-directory wasn't found at ",'"',"%s",'"',"!",$a,0
s__The_AMBERMOON_directory_wasn_t_f_00220a58:
	dc.b $a,"The AMBERMOON-directory wasn't found at ",'"',"%s",'"',"!",$a,0
s_Ambermoon__00220a88:
	dc.b "Ambermoon/",0
DAT_00220a93:
; Unknown data at address 00220a93.
	dc.b $0c
	dc.b $a,"Please enter the name of your boot-partition",$a,0
s__the_partition_which_contains_yo_00220ac3:
	dc.b "(the partition which contains your >C<-directory).",$a,$a,0
s_Enter_partition_name__00220af8:
	dc.b "Enter partition name: ",0
DAT_00220b0f:
; Unknown data at address 00220b0f.
	dc.b $3a
; Unknown data at address 00220b10.
	dc.b $00
DAT_00220b11:
; Unknown data at address 00220b11.
	dc.b $25
; Unknown data at address 00220b12.
	dc.b $73
; Unknown data at address 00220b13.
	dc.b $43
; Unknown data at address 00220b14.
	dc.b $00
s___C__directory_wasn_t_found_at___00220b15:
	dc.b $a,">C<-directory wasn't found at '%s'!",$a,0
s___C__directory_wasn_t_found_at___00220b3b:
	dc.b $a,">C<-directory wasn't found at '%s'!",$a,0
DAT_00220b61:
; Unknown data at address 00220b61.
	dc.b $0c
	dc.b "Boot-disk is being created...",$a,$a,0
s_TIP__Please_take_care_that_the_d_00220b82:
	dc.b "TIP: Please take care that the drive light",$a,0
s_has_switched_off_before_you_chan_00220bae:
	dc.b "has switched off before you change the disk.",$a,$a,0
s_Ambermoon_boot_disk_00220bdd:
	dc.b "Ambermoon boot disk",0
s_Ambermoon_boot_disk__00220bf1:
	dc.b "Ambermoon boot disk:",0
s_Startup_sequence_is_being_genera_00220c06:
	dc.b "Startup-sequence is being generated.",$a,0
DAT_00220c2c:
; Unknown data at address 00220c2c.
	dc.b $53
; Unknown data at address 00220c2d.
	dc.b $00
s_S_startup_sequence_00220c2e:
	dc.b "S/startup-sequence",0
s__sC_Assign_SYS___s_00220c41:
	dc.b "%sC/Assign SYS: %s",0
s_SYS_C_Assign_C__SYS_C_00220c54:
	dc.b "SYS:C/Assign C: SYS:C",0
s_C_Path_C__SYS_System_add_00220c6a:
	dc.b "C:Path C: SYS:System add",0
s_Assign_DEVS__SYS_Devs_00220c83:
	dc.b "Assign DEVS: SYS:Devs",0
s_Assign_L__SYS_L_00220c99:
	dc.b "Assign L: SYS:L",0
s_Assign_LIBS__SYS_Libs_00220ca9:
	dc.b "Assign LIBS: SYS:Libs",0
s_Cd__s_00220cbf:
	dc.b "Cd %s",0
s_Ambermoon_BOOT2_00220cc5:
	dc.b "Ambermoon BOOT2",0
s_SetMap_gb_00220cd5:
	dc.b "SetMap gb",0
s_Ambermoon_BOOT2_00220cdf:
	dc.b "Ambermoon BOOT2",0
s_EndCLI_00220cef:
	dc.b "EndCLI",0
s__Boot_disk_has_been_created__00220cf6:
	dc.b $a,"Boot-disk has been created.",$a,0
s__Please_press__RETURN___00220d14:
	dc.b $a,"Please press >RETURN<.",$a,0
; Unknown data at address 00220d2d.
	dc.b $00
FUN_00220d2e:
	link.w A5,#-$000000c8
	movem.l A6/D3/D2,-(SP)
	tst.w DAT_00223e46
	beq.b LAB_00220d9c
	tst.w DAT_00223e48
	beq.b LAB_00220d72
	tst.w DAT_00223e4a
	beq.b LAB_00220d60
	pea (s_SYS_System_More_Amberfiles_Troub_00220e86,PC)
	pea (-$00c8,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
	bra.b LAB_00220d70
LAB_00220d60:
	pea (s_SYS_Utilities_More_Amberfiles_Tr_00220ead,PC)
	pea (-$00c8,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
LAB_00220d70:
	bra.b LAB_00220d82
LAB_00220d72:
	pea (s_RAM_AM2_C_More_AMBER_A_Trouble_d_00220ed7,PC)
	pea (-$00c8,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
LAB_00220d82:
	move.l DAT_00223cdc,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
	bra.w LAB_00220e76
LAB_00220d9c:
	tst.w DAT_00223e48
	beq.w LAB_00220e50
	pea DAT_00223d46
	pea (s_Assign_X___s_Amberfiles__00220efa,PC)
	pea (-$00c8,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	move.l DAT_00223cdc,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
	tst.w D0
	bne.b LAB_00220df8
	pea (s_The_Assign_command_couldn_t_be_e_00220f13,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
LAB_00220df0:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00220df8:
	tst.w DAT_00223e4a
	beq.b LAB_00220e12
	pea (s_SYS_System_More_X_Trouble_doc_00220f3d,PC)
	pea (-$00c8,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
	bra.b LAB_00220e22
LAB_00220e12:
	pea (s_SYS_Utilities_More_X_Trouble_doc_00220f5b,PC)
	pea (-$00c8,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
LAB_00220e22:
	move.l DAT_00223cdc,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
	move.l DAT_00223cdc,-(SP)
	clr.l -(SP)
	pea (s_Assign_X__remove_00220f7c,PC)
	jsr FUN_00223892
	lea ($000c,SP),SP
	bra.b LAB_00220e76
LAB_00220e50:
	pea (s_RAM_AM2_C_More_AMBER_A_Trouble_d_00220f8d,PC)
	pea (-$00c8,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
	move.l DAT_00223cdc,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
LAB_00220e76:
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
	bra.w LAB_00220df0
s_SYS_System_More_Amberfiles_Troub_00220e86:
	dc.b "SYS:System/More Amberfiles/Trouble.doc",0
s_SYS_Utilities_More_Amberfiles_Tr_00220ead:
	dc.b "SYS:Utilities/More Amberfiles/Trouble.doc",0
s_RAM_AM2_C_More_AMBER_A_Trouble_d_00220ed7:
	dc.b "RAM:AM2_C/More AMBER_A:Trouble.doc",0
s_Assign_X___s_Amberfiles__00220efa:
	dc.b "Assign X: %s/Amberfiles/",0
s_The_Assign_command_couldn_t_be_e_00220f13:
	dc.b "The Assign-command couldn't be executed.",$a,0
s_SYS_System_More_X_Trouble_doc_00220f3d:
	dc.b "SYS:System/More X:Trouble.doc",0
s_SYS_Utilities_More_X_Trouble_doc_00220f5b:
	dc.b "SYS:Utilities/More X:Trouble.doc",0
s_Assign_X__remove_00220f7c:
	dc.b "Assign X: remove",0
s_RAM_AM2_C_More_AMBER_A_Trouble_d_00220f8d:
	dc.b "RAM:AM2_C/More AMBER_A:Trouble.doc",0
FUN_00220fb0:
	link.w A5,#-$0000000a
	movem.l A6/D3/D2,-(SP)
	pea $00000001
	pea (-$000a,A5)
	move.l DAT_00223cdc,-(SP)
	jsr thunk_FUN_00223914
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00220fd8:
	link.w A5,#-$00000068
	movem.l A6/D3/D2,-(SP)
	pea (-$0068,A5)
	pea (DAT_00221046,PC)
	jsr FUN_00221e64
	addq.w #$00000008,SP
	pea (-$0068,A5)
	jsr FUN_00221e22
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	move.l (-$0004,A5),D0
	cmp.l ($000c,A5),D0
	bcs.b LAB_0022102e
	move.l ($000c,A5),-(SP)
	pea (-$0068,A5)
	move.l ($0008,A5),-(SP)
	jsr FUN_00222a3e
	lea ($000c,SP),SP
	move.l ($000c,A5),D0
	movea.l ($0008,A5),A0
	clr.b ($00,A0,D0.l)
	bra.b LAB_0022103e
LAB_0022102e:
	pea (-$0068,A5)
	move.l ($0008,A5),-(SP)
	jsr FUN_00221e12
	addq.w #$00000008,SP
LAB_0022103e:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_00221046:
; Unknown data at address 00221046.
	dc.b $25
; Unknown data at address 00221047.
	dc.b $73
; Unknown data at address 00221048.
	dc.b $00
; Unknown data at address 00221049.
	dc.b $00
FUN_0022104a:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	move.l ($000c,A5),-(SP)
	jsr FUN_00221e22
	addq.w #$00000004,SP
	move.l D0,-(SP)
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	jsr thunk_FUN_0022393e
	lea ($000c,SP),SP
	pea $00000001
	pea (DAT_00221090,PC)
	move.l ($0008,A5),-(SP)
	jsr thunk_FUN_0022393e
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_00221090:
; Unknown data at address 00221090.
	dc.b $0a
; Unknown data at address 00221091.
	dc.b $00
FUN_00221092:
	link.w A5,#-$000000d6
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0008,A5)
	lea (s_Please_insert_a_diskette_in_DF0__002212dc,PC),A0
	move.l A0,(-$00d4,A5)
	move.l ($0008,A5),-(SP)
	pea (s_CON_0_100_640_100__Formatting_____00221311,PC)
	pea (-$00d0,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea $000003ed
	pea (-$00d0,A5)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.w DAT_00223e48
	beq.b LAB_00221144
	move.l (-$00d4,A5),-(SP)
	jsr FUN_00221e22
	addq.w #$00000004,SP
	move.l D0,-(SP)
	move.l (-$00d4,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022393e
	lea ($000c,SP),SP
	pea $00000001
	pea (-$00d0,A5)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_00223914
	lea ($000c,SP),SP
	move.l ($0008,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_SYS_System_Format_DRIVE_df0__NAM_00221337,PC)
	pea (-$00d0,A5)
	jsr FUN_00222b2a
	lea ($0010,SP),SP
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (-$00d0,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
	move.w D0,(-$00d6,A5)
	bra.w LAB_002211fa
LAB_00221144:
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (s_RAM_AM2_C_Assign_C__RAM_AM2_C__00221366,PC)
	jsr FUN_00223892
	lea ($000c,SP),SP
	tst.w D0
	bne.b LAB_0022117e
	pea (s_The_Assign_command_couldn_t_be_e_00221385,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
	moveq #$00000000,D0
LAB_00221176:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_0022117e:
	move.l (-$00d4,A5),-(SP)
	jsr FUN_00221e22
	addq.w #$00000004,SP
	move.l D0,-(SP)
	move.l (-$00d4,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022393e
	lea ($000c,SP),SP
	pea $00000001
	pea (-$00d0,A5)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_00223914
	lea ($000c,SP),SP
	move.l ($0008,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_RAM_AM2_C_Format_DRIVE_df0__NAME_002213af,PC)
	pea (-$00d0,A5)
	jsr FUN_00222b2a
	lea ($0010,SP),SP
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (-$00d0,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
	move.w D0,(-$00d6,A5)
	move.l (-$0004,A5),-(SP)
	clr.l -(SP)
	pea (s_RAM_AM2_C_Assign_C__SYS_C__002213dd,PC)
	jsr FUN_00223892
	lea ($000c,SP),SP
LAB_002211fa:
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	tst.w (-$00d6,A5)
	bne.b LAB_0022122a
	pea (s_The_Format_command_couldn_t_be_e_002213f8,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
	moveq #$00000000,D0
	bra.w LAB_00221176
LAB_0022122a:
	move.l ($0008,A5),-(SP)
	pea (DAT_00221422,PC)
	pea (-$00d0,A5)
	jsr FUN_00222b2a
	lea ($000c,SP),SP
	pea -2
	pea (-$00d0,A5)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	cmpi.w #$00000001,($000e,A5)
	bne.b LAB_002212ca
	tst.w DAT_00223e48
	beq.b LAB_00221282
	pea (s_Install_df0__00221426,PC)
	pea (-$00d0,A5)
	jsr FUN_00222b2a
	addq.w #$00000008,SP
	bra.b LAB_00221292
LAB_00221282:
	pea (s_RAM_AM2_C_Install_df0__00221433,PC)
	pea (-$00d0,A5)
	jsr FUN_00222b2a
	addq.w #$00000008,SP
LAB_00221292:
	move.l DAT_00223cdc,-(SP)
	clr.l -(SP)
	pea (-$00d0,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
	tst.w D0
	bne.b LAB_002212ca
	pea (s_The_Install_command_couldn_t_be_e_0022144a,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
	moveq #$00000000,D0
	bra.w LAB_00221176
LAB_002212ca:
	pea (s__The_disk_was_formatted_successf_00221475,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	moveq #$00000001,D0
	bra.w LAB_00221176
s_Please_insert_a_diskette_in_DF0__002212dc:
	dc.b "Please insert a diskette in DF0: and press >RETURN<.",0
s_CON_0_100_640_100__Formatting_____00221311:
	dc.b "CON:0/100/640/100/ Formatting [ %s ] ",0
s_SYS_System_Format_DRIVE_df0__NAM_00221337:
	dc.b "SYS:System/Format DRIVE df0: NAME ",'"',"%s",'"'," NOICONS",0
s_RAM_AM2_C_Assign_C__RAM_AM2_C__00221366:
	dc.b "RAM:AM2_C/Assign C: RAM:AM2_C/",0
s_The_Assign_command_couldn_t_be_e_00221385:
	dc.b "The Assign-command couldn't be executed.",$a,0
s_RAM_AM2_C_Format_DRIVE_df0__NAME_002213af:
	dc.b "RAM:AM2_C/Format DRIVE df0: NAME ",'"',"%s",'"'," NOICONS",0
s_RAM_AM2_C_Assign_C__SYS_C__002213dd:
	dc.b "RAM:AM2_C/Assign C: SYS:C/",0
s_The_Format_command_couldn_t_be_e_002213f8:
	dc.b "The Format-command couldn't be executed.",$a,0
DAT_00221422:
; Unknown data at address 00221422.
	dc.b $25
; Unknown data at address 00221423.
	dc.b $73
; Unknown data at address 00221424.
	dc.b $3a
; Unknown data at address 00221425.
	dc.b $00
s_Install_df0__00221426:
	dc.b "Install df0:",0
s_RAM_AM2_C_Install_df0__00221433:
	dc.b "RAM:AM2_C/Install df0:",0
s_The_Install_command_couldn_t_be_e_0022144a:
	dc.b "The Install-command couldn't be executed.",$a,0
s__The_disk_was_formatted_successf_00221475:
	dc.b $a,"The disk was formatted successfully.",$a,0
FUN_0022149c:
	link.w A5,#-$000000ca
	movem.l A6/D3/D2,-(SP)
	tst.w DAT_00223e48
	beq.b LAB_002214c8
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_Copy__s__s_00221528,PC)
	pea (-$00c8,A5)
	jsr FUN_00222b2a
	lea ($0010,SP),SP
	bra.b LAB_002214e2
LAB_002214c8:
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	pea (s_RAM_AM2_C_Copy__s__s_00221533,PC)
	pea (-$00c8,A5)
	jsr FUN_00222b2a
	lea ($0010,SP),SP
LAB_002214e2:
	move.l DAT_00223cdc,-(SP)
	clr.l -(SP)
	pea (-$00c8,A5)
	jsr FUN_00223892
	lea ($000c,SP),SP
	move.w D0,(-$00ca,A5)
	tst.w (-$00ca,A5)
	bne.b LAB_0022151a
	pea (s_The_Copy_command_couldn_t_be_exe_00221548,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00000064
	jsr FUN_0022385a
	addq.w #$00000004,SP
LAB_0022151a:
	move.w (-$00ca,A5),D0
	ext.l D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_Copy__s__s_00221528:
	dc.b "Copy %s %s",0
s_RAM_AM2_C_Copy__s__s_00221533:
	dc.b "RAM:AM2_C/Copy %s %s",0
s_The_Copy_command_couldn_t_be_exe_00221548:
	dc.b "The Copy-command couldn't be executed.",$a,0
FUN_00221570:
	link.w A5,#-$00000006
	movem.l A6/D3/D2,-(SP)
LAB_00221578:
	move.l ($0008,A5),-(SP)
	pea (DAT_002215cc,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea $00000004
	pea (-$0005,A5)
	jsr (FUN_00220fd8,PC)
	addq.w #$00000008,SP
	move.b (-$0005,A5),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_00221e34
	addq.w #$00000004,SP
	move.b D0,(-$0006,A5)
	cmpi.b #$00000059,(-$0006,A5)
	beq.b LAB_002215bc
	cmpi.b #$0000004e,(-$0006,A5)
	bne.b LAB_00221578
LAB_002215bc:
	move.b (-$0006,A5),D0
	ext.w D0
	ext.l D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_002215cc:
; Unknown data at address 002215cc.
	dc.b $0c
; Unknown data at address 002215cd.
	dc.b $0a
; Unknown data at address 002215ce.
	dc.b $25
; Unknown data at address 002215cf.
	dc.b $73
; Unknown data at address 002215d0.
	dc.b $00
; Unknown data at address 002215d1.
	dc.b $00
FUN_002215d2:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0004,A5)
	move.l ($0008,A5),-(SP)
	jsr FUN_00223838
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	beq.b LAB_00221600
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
LAB_00221600:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00221608:
	link.w A5,#-$000000ce
	movem.l A6/D3/D2,-(SP)
	pea (s_Save_game_directories_are_being_c_00221690,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	clr.w (-$0002,A5)
	bra.b LAB_00221680
LAB_00221622:
	moveq #$00000000,D0
	move.w (-$0002,A5),D0
	moveq #$0000000a,D1
	jsr FUN_00222ff2
	move.l D0,-(SP)
	moveq #$00000000,D0
	move.w (-$0002,A5),D0
	moveq #$00000064,D1
	jsr FUN_00222ff2
	moveq #$0000000a,D1
	jsr FUN_00222ffe
	move.l D0,-(SP)
	move.l ($0008,A5),-(SP)
	pea (s__sSave__1u_1u_002216ba,PC)
	pea (-$00ce,A5)
	jsr FUN_00222b2a
	lea ($0014,SP),SP
	pea (-$00ce,A5)
	jsr FUN_00223838
	addq.w #$00000004,SP
	move.l D0,(-$0006,A5)
	move.l (-$0006,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	addq.w #$00000001,(-$0002,A5)
LAB_00221680:
	cmpi.w #$0000000b,(-$0002,A5)
	bcs.b LAB_00221622
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_Save_game_directories_are_being_c_00221690:
	dc.b "Save-game directories are being created.",$a,0
s__sSave__1u_1u_002216ba:
	dc.b "%sSave.%1u%1u",0
FUN_002216c8:
	link.w A5,#-$000000d0
	movem.l A6/D3/D2,-(SP)
	pea (s_Saves_file_is_being_created__002217aa,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	pea $00010000
	pea $00000188
	jsr thunk_FUN_00223982
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	tst.l (-$0008,A5)
	bne.b LAB_00221700
LAB_002216f8:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00221700:
	move.l ($0008,A5),-(SP)
	pea (-$00d0,A5)
	jsr FUN_00221e12
	addq.w #$00000008,SP
	pea (s_Saves_002217c8,PC)
	pea (-$00d0,A5)
	jsr FUN_00222a14
	addq.w #$00000008,SP
	pea $000003ee
	pea (-$00d0,A5)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	bne.b LAB_0022174c
	pea $00000188
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	bra.b LAB_002216f8
LAB_0022174c:
	pea $00000188
	move.l (-$0008,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022393e
	lea ($000c,SP),SP
	cmp.l #$00000188,D0
	beq.b LAB_0022178a
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	pea $00000188
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	bra.w LAB_002216f8
LAB_0022178a:
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	pea $00000188
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	bra.w LAB_002216f8
s_Saves_file_is_being_created__002217aa:
	dc.b "Saves-file is being created.",$a,0
s_Saves_002217c8:
	dc.b "Saves",0
FUN_002217ce:
	link.w A5,#-$0000000c
	movem.l A6/D3/D2,-(SP)
	clr.l (-$000c,A5)
	clr.l -(SP)
	pea $00000104
	jsr thunk_FUN_00223982
	addq.w #$00000008,SP
	move.l D0,(-$0008,A5)
	beq.b LAB_00221844
	pea -2
	move.l ($0008,A5),-(SP)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	beq.b LAB_00221822
	move.l (-$0008,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_00223882
	addq.w #$00000008,SP
	tst.w D0
	beq.b LAB_00221822
	movea.l (-$0008,A5),A0
	move.l ($007c,A0),(-$000c,A5)
LAB_00221822:
	tst.l (-$0004,A5)
	beq.b LAB_00221834
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
LAB_00221834:
	pea $00000104
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
LAB_00221844:
	move.l (-$000c,A5),D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00221850:
	link.w A5,#-$0000000c
	movem.l A6/D3/D2,-(SP)
	move.l ($0008,A5),-(SP)
	jsr (FUN_002217ce,PC)
	addq.w #$00000004,SP
	move.l D0,(-$0008,A5)
	bne.b LAB_00221890
	move.l ($0008,A5),-(SP)
	pea (s_File__s_wasn_t_found__00221a3e,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea (s_Please_press__RETURN___00221a55,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
LAB_00221888:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00221890:
	clr.l -(SP)
	move.l (-$0008,A5),-(SP)
	jsr thunk_FUN_00223982
	addq.w #$00000008,SP
	move.l D0,(-$000c,A5)
	bne.b LAB_002218c6
	move.l ($0008,A5),-(SP)
	pea (s_Not_enough_memory_for_file__s__00221a6d,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea (s_Please_press__RETURN___00221a8d,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	bra.b LAB_00221888
LAB_002218c6:
	pea $000003ed
	move.l ($0008,A5),-(SP)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	bne.b LAB_00221910
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	move.l ($0008,A5),-(SP)
	pea (s_File__s_couldn_t_be_opened__00221aa5,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea (s_Please_press__RETURN___00221ac2,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	bra.w LAB_00221888
LAB_00221910:
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_00223914
	lea ($000c,SP),SP
	cmp.l (-$0008,A5),D0
	beq.b LAB_0022196c
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	move.l ($0008,A5),-(SP)
	pea (s_File__s_couldn_t_be_read__00221ada,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea (s_Please_press__RETURN___00221af5,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	bra.w LAB_00221888
LAB_0022196c:
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	pea $000003ee
	move.l ($000c,A5),-(SP)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	bne.b LAB_002219c2
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	move.l ($000c,A5),-(SP)
	pea (s_File__s_couldn_t_be_opened__00221b0d,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea (s_Please_press__RETURN___00221b2a,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	bra.w LAB_00221888
LAB_002219c2:
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022393e
	lea ($000c,SP),SP
	cmp.l (-$0008,A5),D0
	beq.b LAB_00221a1e
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	move.l ($000c,A5),-(SP)
	pea (s_File__s_couldn_t_be_written__00221b42,PC)
	jsr FUN_00222b90
	addq.w #$00000008,SP
	pea (s_Please_press__RETURN___00221b60,PC)
	jsr FUN_00222b90
	addq.w #$00000004,SP
	jsr (FUN_00220fb0,PC)
	bra.w LAB_00221888
LAB_00221a1e:
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
	move.l (-$0008,A5),-(SP)
	move.l (-$000c,A5),-(SP)
	jsr thunk_FUN_002239b6
	addq.w #$00000008,SP
	bra.w LAB_00221888
s_File__s_wasn_t_found__00221a3e:
	dc.b "File %s wasn't found.",$a,0
s_Please_press__RETURN___00221a55:
	dc.b "Please press >RETURN<.",$a,0
s_Not_enough_memory_for_file__s__00221a6d:
	dc.b "Not enough memory for file %s.",$a,0
s_Please_press__RETURN___00221a8d:
	dc.b "Please press >RETURN<.",$a,0
s_File__s_couldn_t_be_opened__00221aa5:
	dc.b "File %s couldn't be opened.",$a,0
s_Please_press__RETURN___00221ac2:
	dc.b "Please press >RETURN<.",$a,0
s_File__s_couldn_t_be_read__00221ada:
	dc.b "File %s couldn't be read.",$a,0
s_Please_press__RETURN___00221af5:
	dc.b "Please press >RETURN<.",$a,0
s_File__s_couldn_t_be_opened__00221b0d:
	dc.b "File %s couldn't be opened.",$a,0
s_Please_press__RETURN___00221b2a:
	dc.b "Please press >RETURN<.",$a,0
s_File__s_couldn_t_be_written__00221b42:
	dc.b "File %s couldn't be written.",$a,0
s_Please_press__RETURN___00221b60:
	dc.b "Please press >RETURN<.",$a,0
FUN_00221b78:
	link.w A5,#-$0000001a
	movem.l A6/D3/D2,-(SP)
	clr.l (-$0010,A5)
	tst.w DAT_00223e46
	beq.w LAB_00221c3e
	move.w #$0001,DAT_00223e48
	pea $000003ed
	pea (s_Ambermoon_install_00221c8a,PC)
	jsr thunk_FUN_002238e6
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	beq.w LAB_00221c3c
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
	bne.b LAB_00221c30
	movea.l (-$0008,A5),A0
	move.l ($0010,A0),(-$000c,A5)
	movea.l (-$000c,A5),A0
	move.l ($000a,A0),(-$0014,A5)
	movea.l (-$0014,A5),A0
	cmpi.b #$00000044,(A0)
	bne.b LAB_00221c30
	movea.l (-$0014,A5),A0
	cmpi.b #$00000046,($0001,A0)
	bne.b LAB_00221c30
	movea.l (-$0014,A5),A0
	move.b ($0002,A0),D0
	ext.w D0
	moveq #$00000000,D1
	move.w D0,D1
	sub.l #$00000030,D1
	move.w D1,(-$001a,A5)
	tst.w (-$001a,A5)
	bcs.b LAB_00221c30
	cmpi.w #$00000003,(-$001a,A5)
	bhi.b LAB_00221c30
	clr.w DAT_00223e48
LAB_00221c30:
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022382a
	addq.w #$00000004,SP
LAB_00221c3c:
	bra.b LAB_00221c82
LAB_00221c3e:
	clr.w DAT_00223e48
	pea -1
	pea (s_Folder_info_00221c9c,PC)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0010,A5)
	tst.l (-$0010,A5)
	beq.b LAB_00221c6c
	move.l (-$0010,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	bra.b LAB_00221c82
LAB_00221c6c:
	jsr thunk_FUN_002238b2
	cmp.l #$000000cd,D0
	bne.b LAB_00221c82
	move.w #$0001,DAT_00223e48
LAB_00221c82:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
s_Ambermoon_install_00221c8a:
	dc.b "Ambermoon_install",0
s_Folder_info_00221c9c:
	dc.b "Folder_info",0
FUN_00221ca8:
	link.w A5,#-$0000000a
	movem.l A6/D3/D2,-(SP)
	move.l #$00000004,(-$0004,A5)
	movea.l (-$0004,A5),A0
	move.l (A0),(-$0008,A5)
	movea.l (-$0008,A5),A0
	move.w ($0014,A0),(-$000a,A5)
	cmpi.w #$00000024,(-$000a,A5)
	bcs.b LAB_00221cd6
	moveq #$00000001,D0
	bra.b LAB_00221cd8
LAB_00221cd6:
	moveq #$00000000,D0
LAB_00221cd8:
	move.w D0,DAT_00223e46
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00221ce6:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	pea -2
	move.l ($0008,A5),-(SP)
	jsr thunk_FUN_002238d0
	addq.w #$00000008,SP
	move.l D0,(-$0004,A5)
	tst.l (-$0004,A5)
	beq.b LAB_00221d1e
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
	moveq #$00000001,D0
LAB_00221d16:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00221d1e:
	moveq #$00000000,D0
	bra.b LAB_00221d16
FUN_00221d22:
	link.w A5,#-$0000011c
	movem.l A6/D3/D2,-(SP)
	move.l #$000000fe,(-$0118,A5)
	clr.l -(SP)
	jsr thunk_FUN_00223998
	addq.w #$00000004,SP
	movea.l D0,A0
	move.l ($0098,A0),(-$0004,A5)
	clr.b DAT_00223e44
	clr.b DAT_00223e45
LAB_00221d50:
	move.l (-$0118,A5),(-$0114,A5)
	pea (-$0108,A5)
	move.l (-$0004,A5),-(SP)
	jsr thunk_FUN_00223882
	addq.w #$00000008,SP
	lea (-$0100,A5),A0
	move.l A0,(-$011c,A5)
	move.l (-$011c,A5),-(SP)
	jsr FUN_00221e22
	addq.w #$00000004,SP
	move.l D0,(-$010c,A5)
	move.l (-$010c,A5),D0
	sub.l D0,(-$0118,A5)
	clr.l (-$0110,A5)
	bra.b LAB_00221dac
LAB_00221d8c:
	move.l (-$0110,A5),D0
	movea.l (-$011c,A5),A0
	move.l (-$0110,A5),D1
	add.l (-$0118,A5),D1
	lea DAT_00223d46,A1
	move.b ($00,A0,D0.l),($00,A1,D1.l)
	addq.l #$00000001,(-$0110,A5)
LAB_00221dac:
	move.l (-$0110,A5),D0
	cmp.l (-$010c,A5),D0
	blt.b LAB_00221d8c
	subq.l #$00000001,(-$0118,A5)
	move.l (-$0118,A5),D0
	lea DAT_00223d46,A0
	move.b #$2f,($00,A0,D0.l)
	move.l (-$0004,A5),-(SP)
	jsr FUN_00223900
	addq.w #$00000004,SP
	move.l D0,(-$0004,A5)
	bne.w LAB_00221d50
	move.l (-$0114,A5),D0
	lea DAT_00223d46,A0
	move.b #$3a,($00,A0,D0.l)
	lea DAT_00223d47,A0
	movea.l (-$0118,A5),A1
	adda.l A0,A1
	move.l A1,-(SP)
	pea DAT_00223d46
	jsr FUN_00221e12
	addq.w #$00000008,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00221e12:
	movea.l ($0004,SP),A0
	move.l A0,D0
	movea.l ($0008,SP),A1
LAB_00221e1c:
	move.b (A1)+,(A0)+
	bne.b LAB_00221e1c
	rts
FUN_00221e22:
	movea.l ($0004,SP),A0
	move.l A0,D0
LAB_00221e28:
	tst.b (A0)+
	bne.b LAB_00221e28
	suba.l D0,A0
	move.l A0,D0
	subq.l #$00000001,D0
	rts
FUN_00221e34:
	moveq #$00000000,D0
	move.b ($0007,SP),D0
	cmp.b #$60,D0
	bls.b LAB_00221e4a
	cmp.b #$7a,D0
	bhi.b LAB_00221e4a
	sub.b #$20,D0
LAB_00221e4a:
	rts
; Unknown data at address 00221e4c.
	dc.b $70
; Unknown data at address 00221e4d.
	dc.b $00
; Unknown data at address 00221e4e.
	dc.b $10
; Unknown data at address 00221e4f.
	dc.b $2f
; Unknown data at address 00221e50.
	dc.b $00
; Unknown data at address 00221e51.
	dc.b $07
; Unknown data at address 00221e52.
	dc.b $b0
; Unknown data at address 00221e53.
	dc.b $3c
; Unknown data at address 00221e54.
	dc.b $00
; Unknown data at address 00221e55.
	dc.b $40
; Unknown data at address 00221e56.
	dc.b $63
; Unknown data at address 00221e57.
	dc.b $0a
; Unknown data at address 00221e58.
	dc.b $b0
; Unknown data at address 00221e59.
	dc.b $3c
; Unknown data at address 00221e5a.
	dc.b $00
; Unknown data at address 00221e5b.
	dc.b $5a
; Unknown data at address 00221e5c.
	dc.b $62
; Unknown data at address 00221e5d.
	dc.b $04
; Unknown data at address 00221e5e.
	dc.b $d0
; Unknown data at address 00221e5f.
	dc.b $3c
; Unknown data at address 00221e60.
	dc.b $00
; Unknown data at address 00221e61.
	dc.b $20
; Unknown data at address 00221e62.
	dc.b $4e
; Unknown data at address 00221e63.
	dc.b $75
FUN_00221e64:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	clr.l DAT_00223cc8
	pea ($000c,A5)
	move.l ($0008,A5),-(SP)
	pea (LAB_00221e90,PC)
	jsr FUN_00221ef2
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_00221e90:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	tst.l ($0008,A5)
	bne.b LAB_00221eca
	btst.b #$00000003,DAT_00223b10
	beq.b LAB_00221eb4
	move.l #-$00000001,DAT_00223cc8
	bra.b LAB_00221ec8
LAB_00221eb4:
	pea DAT_00223b04
	jsr FUN_002223be
	move.l D0,DAT_00223cc8
	addq.w #$00000004,SP
LAB_00221ec8:
	bra.b LAB_00221ee4
LAB_00221eca:
	pea DAT_00223b04
	move.l DAT_00223cc8,-(SP)
	jsr FUN_00222512
	move.l D0,DAT_00223cc8
	addq.w #$00000008,SP
LAB_00221ee4:
	move.l DAT_00223cc8,D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00221ef2:
	link.w A5,#-$0000008e
	movem.l A6/A3/A2/D7/D6/D5/D4/D3/D2,-(SP)
	movea.l ($000c,A5),A2
	movea.l ($0010,A5),A3
	moveq #$00000000,D5
	move.l ($0008,A5),DAT_00223cd0
LAB_00221f0c:
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	beq.w LAB_00222238
	cmp.l #$00000025,D4
	bne.w LAB_002221fe
	clr.b (-$0005,A5)
	clr.b (-$0006,A5)
	clr.b (-$0007,A5)
	move.l #$0000007f,DAT_00223ccc
	cmpi.b #$0000002a,(A2)
	bne.b LAB_00221f4a
	addq.l #$00000001,A2
	move.b #$01,(-$0005,A5)
LAB_00221f4a:
	move.b (A2),D0
	ext.w D0
	ext.l D0
	lea DAT_00223a83,A0
	btst.b #$00000002,($00,A0,D0.l)
	beq.b LAB_00221fa6
	clr.l DAT_00223ccc
LAB_00221f64:
	move.b (A2),D0
	ext.w D0
	ext.l D0
	moveq #$0000000a,D1
	move.l D0,-(SP)
	move.l DAT_00223ccc,D0
	jsr FUN_00223800
	move.l (SP)+,D1
	add.l D0,D1
	sub.l #$00000030,D1
	move.l D1,DAT_00223ccc
	addq.l #$00000001,A2
	move.b (A2),D0
	ext.w D0
	ext.l D0
	lea DAT_00223a83,A0
	btst.b #$00000002,($00,A0,D0.l)
	bne.b LAB_00221f64
	move.b #$01,(-$0007,A5)
LAB_00221fa6:
	cmpi.b #$0000006c,(A2)
	bne.b LAB_00221fb4
	move.b #$01,(-$0006,A5)
	addq.l #$00000001,A2
LAB_00221fb4:
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D7
	bra.w LAB_002221ac
LAB_00221fc4:
	moveq #$00000025,D4
	bra.w LAB_00222214
LAB_00221fca:
	move.b #-$01,(-$0006,A5)
	bra.b LAB_00221fd8
LAB_00221fd2:
	move.b #$01,(-$0006,A5)
LAB_00221fd8:
	moveq #$0000000c,D4
	moveq #$0000000a,D6
	bra.b LAB_00221ff4
LAB_00221fde:
	move.b #$01,(-$0006,A5)
LAB_00221fe4:
	moveq #$00000000,D4
	moveq #$00000010,D6
	bra.b LAB_00221ff4
LAB_00221fea:
	move.b #$01,(-$0006,A5)
LAB_00221ff0:
	moveq #$0000000e,D4
	moveq #$00000008,D6
LAB_00221ff4:
	jsr (FUN_0022226c,PC)
	tst.l D0
	bne.w LAB_00222238
	pea (-$0004,A5)
	move.l D6,-(SP)
	lea DAT_00223a59,A0
	movea.l D4,A1
	adda.l A0,A1
	move.l A1,-(SP)
	lea s_ABCDEFabcdef9876543210_00223a42,A0
	movea.l D4,A1
	adda.l A0,A1
	move.l A1,-(SP)
	jsr (FUN_002222b4,PC)
	tst.l D0
	lea ($0010,SP),SP
	beq.w LAB_00222238
	tst.b (-$0005,A5)
	bne.b LAB_00222060
	tst.b (-$0006,A5)
	bge.b LAB_00222042
	movea.l A3,A0
	addq.l #$00000004,A3
	movea.l (A0),A1
	move.w (-$0002,A5),(A1)
	bra.b LAB_0022205e
LAB_00222042:
	tst.b (-$0006,A5)
	ble.b LAB_00222054
	movea.l A3,A0
	addq.l #$00000004,A3
	movea.l (A0),A1
	move.l (-$0004,A5),(A1)
	bra.b LAB_0022205e
LAB_00222054:
	movea.l A3,A0
	addq.l #$00000004,A3
	movea.l (A0),A1
	move.l (-$0004,A5),(A1)
LAB_0022205e:
	addq.l #$00000001,D5
LAB_00222060:
	bra.w LAB_002221fc
LAB_00222064:
	clr.b (-$0006,A5)
	cmpi.b #$0000005e,(A2)
	beq.b LAB_00222074
	cmpi.b #$0000007e,(A2)
	bne.b LAB_0022207c
LAB_00222074:
	addq.l #$00000001,A2
	move.b #$01,(-$0006,A5)
LAB_0022207c:
	lea (-$008e,A5),A0
	move.l A0,(-$000c,A5)
	bra.b LAB_00222090
LAB_00222086:
	movea.l (-$000c,A5),A0
	addq.l #$00000001,(-$000c,A5)
	move.b D4,(A0)
LAB_00222090:
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	cmp.l #$0000005d,D0
	bne.b LAB_00222086
	movea.l (-$000c,A5),A0
	clr.b (A0)
	bra.b LAB_002220c8
LAB_002220ac:
	move.b #$01,(-$0006,A5)
	move.b #$20,(-$008e,A5)
	move.b #$09,(-$008d,A5)
	move.b #$0a,(-$008c,A5)
	clr.b (-$008b,A5)
LAB_002220c8:
	jsr (FUN_0022226c,PC)
	tst.l D0
	bne.w LAB_00222238
LAB_002220d2:
	tst.b (-$0005,A5)
	bne.b LAB_002220e0
	movea.l A3,A0
	addq.l #$00000004,A3
	move.l (A0),(-$000c,A5)
LAB_002220e0:
	clr.b (-$0007,A5)
LAB_002220e4:
	move.l DAT_00223ccc,D0
	subq.l #$00000001,DAT_00223ccc
	tst.l D0
	beq.b LAB_0022216e
	clr.l -(SP)
	movea.l DAT_00223cd0,A0
	jsr (A0)
	move.l D0,D4
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	beq.b LAB_0022216e
	tst.b (-$0006,A5)
	beq.b LAB_0022212a
	move.l D4,-(SP)
	pea (-$008e,A5)
	jsr FUN_00222548
	tst.l D0
	addq.w #$00000008,SP
	beq.b LAB_00222126
	moveq #$00000001,D0
	bra.b LAB_00222128
LAB_00222126:
	moveq #$00000000,D0
LAB_00222128:
	bra.b LAB_00222142
LAB_0022212a:
	move.l D4,-(SP)
	pea (-$008e,A5)
	jsr FUN_00222548
	tst.l D0
	addq.w #$00000008,SP
	bne.b LAB_00222140
	moveq #$00000001,D0
	bra.b LAB_00222142
LAB_00222140:
	moveq #$00000000,D0
LAB_00222142:
	beq.b LAB_00222154
	pea $00000001
	movea.l DAT_00223cd0,A0
	jsr (A0)
	addq.w #$00000004,SP
	bra.b LAB_0022216e
LAB_00222154:
	tst.b (-$0005,A5)
	bne.b LAB_00222164
	movea.l (-$000c,A5),A0
	addq.l #$00000001,(-$000c,A5)
	move.b D4,(A0)
LAB_00222164:
	move.b #$01,(-$0007,A5)
	bra.w LAB_002220e4
LAB_0022216e:
	tst.b (-$0007,A5)
	beq.w LAB_00222238
	tst.b (-$0005,A5)
	bne.b LAB_0022218c
	cmp.l #$00000063,D7
	beq.b LAB_0022218a
	movea.l (-$000c,A5),A0
	clr.b (A0)
LAB_0022218a:
	addq.l #$00000001,D5
LAB_0022218c:
	bra.b LAB_002221fc
LAB_0022218e:
	tst.b (-$0007,A5)
	bne.b LAB_0022219e
	move.l #$00000001,DAT_00223ccc
LAB_0022219e:
	clr.b (-$008e,A5)
	move.b #$01,(-$0006,A5)
	bra.w LAB_002220d2
LAB_002221ac:
	sub.l #$00000025,D0
	beq.w LAB_00221fc4
	sub.l #$0000001f,D0
	beq.w LAB_00221fd2
	sub.l #$0000000b,D0
	beq.w LAB_00221fea
	sub.l #$00000009,D0
	beq.w LAB_00221fde
	subq.l #$00000003,D0
	beq.w LAB_00222064
	subq.l #$00000008,D0
	beq.b LAB_0022218e
	subq.l #$00000001,D0
	beq.w LAB_00221fd8
	subq.l #$00000004,D0
	beq.w LAB_00221fca
	subq.l #$00000007,D0
	beq.w LAB_00221ff0
	subq.l #$00000004,D0
	beq.w LAB_002220ac
	subq.l #$00000005,D0
	beq.w LAB_00221fe4
LAB_002221fc:
	bra.b LAB_00222234
LAB_002221fe:
	lea DAT_00223a83,A0
	btst.b #$00000004,($00,A0,D4.l)
	beq.b LAB_00222214
	bsr.b FUN_0022226c
	tst.l D0
	bne.b LAB_00222238
	bra.b LAB_00222234
LAB_00222214:
	clr.l -(SP)
	movea.l DAT_00223cd0,A0
	jsr (A0)
	cmp.l D4,D0
	addq.w #$00000004,SP
	beq.b LAB_00222234
	pea $00000001
	movea.l DAT_00223cd0,A0
	jsr (A0)
	addq.w #$00000004,SP
	bra.b LAB_00222238
LAB_00222234:
	bra.w LAB_00221f0c
LAB_00222238:
	tst.l D5
	bne.b LAB_00222268
	clr.l -(SP)
	movea.l DAT_00223cd0,A0
	jsr (A0)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_0022225a
	moveq #-$00000001,D0
LAB_00222252:
	movem.l (SP)+,D2/D3/D4/D5/D6/D7/A2/A3/A6
	unlk A5
	rts
LAB_0022225a:
	pea $00000001
	movea.l DAT_00223cd0,A0
	jsr (A0)
	addq.w #$00000004,SP
LAB_00222268:
	move.l D5,D0
	bra.b LAB_00222252
FUN_0022226c:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
LAB_00222274:
	clr.l -(SP)
	movea.l DAT_00223cd0,A0
	jsr (A0)
	lea DAT_00223a83,A0
	btst.b #$00000004,($00,A0,D0.l)
	addq.w #$00000004,SP
	beq.b LAB_00222290
	bra.b LAB_00222274
LAB_00222290:
	pea $00000001
	movea.l DAT_00223cd0,A0
	jsr (A0)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_002222b0
	moveq #-$00000001,D0
LAB_002222a8:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_002222b0:
	moveq #$00000000,D0
	bra.b LAB_002222a8
FUN_002222b4:
	link.w A5,#-$00000008
	movem.l A6/A2/D5/D4/D3/D2,-(SP)
	tst.l DAT_00223ccc
	bgt.b LAB_002222ce
	moveq #$00000000,D0
LAB_002222c6:
	movem.l (SP)+,D2/D3/D4/D5/A2/A6
	unlk A5
	rts
LAB_002222ce:
	clr.l (-$0008,A5)
	moveq #$00000000,D5
	move.l D5,(-$0004,A5)
	clr.l -(SP)
	movea.l DAT_00223cd0,A0
	jsr (A0)
	move.l D0,D4
	cmp.l #$0000002d,D0
	addq.w #$00000004,SP
	bne.b LAB_002222fa
	move.l #$00000001,(-$0008,A5)
	addq.l #$00000001,D5
	bra.b LAB_00222314
LAB_002222fa:
	cmp.l #$0000002b,D4
	bne.b LAB_00222306
	addq.l #$00000001,D5
	bra.b LAB_00222314
LAB_00222306:
	pea $00000001
	movea.l DAT_00223cd0,A0
	jsr (A0)
	addq.w #$00000004,SP
LAB_00222314:
	bra.b LAB_00222392
LAB_00222316:
	clr.l -(SP)
	movea.l DAT_00223cd0,A0
	jsr (A0)
	addq.w #$00000004,SP
	move.l D0,D4
	move.l D0,-(SP)
	move.l ($0008,A5),-(SP)
	jsr FUN_00222548
	movea.l D0,A2
	tst.l D0
	addq.w #$00000008,SP
	bne.b LAB_00222368
	cmpi.l #$00000010,($0010,A5)
	bne.b LAB_00222358
	tst.l (-$0004,A5)
	bne.b LAB_00222358
	cmp.l #$00000078,D4
	beq.b LAB_00222390
	cmp.l #$00000058,D4
	beq.b LAB_00222390
LAB_00222358:
	pea $00000001
	movea.l DAT_00223cd0,A0
	jsr (A0)
	addq.w #$00000004,SP
	bra.b LAB_0022239c
LAB_00222368:
	move.l ($0010,A5),D1
	move.l (-$0004,A5),D0
	jsr FUN_00223800
	move.l D0,(-$0004,A5)
	move.l A2,D0
	sub.l ($0008,A5),D0
	movea.l ($000c,A5),A0
	move.b ($00,A0,D0.l),D1
	ext.w D1
	ext.l D1
	add.l D1,(-$0004,A5)
LAB_00222390:
	addq.l #$00000001,D5
LAB_00222392:
	cmp.l DAT_00223ccc,D5
	blt.w LAB_00222316
LAB_0022239c:
	tst.l (-$0008,A5)
	beq.b LAB_002223b0
	movea.l ($0014,A5),A0
	move.l (-$0004,A5),D0
	neg.l D0
	move.l D0,(A0)
	bra.b LAB_002223b8
LAB_002223b0:
	movea.l ($0014,A5),A0
	move.l (-$0004,A5),(A0)
LAB_002223b8:
	move.l D5,D0
	bra.w LAB_002222c6
FUN_002223be:
	link.w A5,#$00000000
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
LAB_002223ca:
	move.l A2,-(SP)
	jsr FUN_00222402
	move.l D0,D4
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	beq.b LAB_002223fe
	move.l D4,D0
	bra.b LAB_002223f6
LAB_002223e2:
	subq.l #$00000001,(A2)
	bset.b #$00000003,($000c,A2)
	moveq #-$00000001,D0
LAB_002223ec:
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
LAB_002223f4:
	bra.b LAB_002223ca
LAB_002223f6:
	tst.l D0
	beq.b LAB_002223f4
	subq.l #$00000004,D0
	beq.b LAB_002223e2
LAB_002223fe:
	move.l D4,D0
	bra.b LAB_002223ec
FUN_00222402:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	movea.l (A2),A0
	cmpa.l ($0004,A2),A0
	bcs.b LAB_00222424
	move.l A2,-(SP)
	bsr.b FUN_00222436
	addq.w #$00000004,SP
LAB_0022241c:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_00222424:
	movea.l (A2),A0
	addq.l #$00000001,(A2)
	move.b (A0),D0
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	bra.b LAB_0022241c
FUN_00222436:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	move.b ($000c,A2),D0
	and.b #$18,D0
	beq.b LAB_00222456
	moveq #-$00000001,D0
LAB_0022244e:
	movem.l (SP)+,D2/D3/D4/A2/A3/A6
	unlk A5
	rts
LAB_00222456:
	bclr.b #$00000002,($000c,A2)
	tst.l ($0008,A2)
	bne.b LAB_0022246c
	move.l A2,-(SP)
	jsr FUN_00223306
	addq.w #$00000004,SP
LAB_0022246c:
	move.b ($000c,A2),D0
	ext.w D0
	ext.l D0
	btst.l #$00000007,D0
	beq.b LAB_002224b6
	lea DAT_00223b04,A0
	movea.l A0,A3
LAB_00222482:
	move.b ($000c,A3),D0
	ext.w D0
	ext.l D0
	and.l #$00000084,D0
	cmp.l #$00000084,D0
	bne.b LAB_002224a6
	pea -1
	move.l A3,-(SP)
	jsr FUN_002231cc
	addq.w #$00000008,SP
LAB_002224a6:
	adda.l #$00000016,A3
	lea DAT_00223cbc,A0
	cmpa.l A0,A3
	bcs.b LAB_00222482
LAB_002224b6:
	move.w ($0010,A2),D0
	ext.l D0
	move.l D0,-(SP)
	move.l ($0008,A2),-(SP)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_00222562
	move.l D0,D4
	tst.l D0
	lea ($000c,SP),SP
	bgt.b LAB_002224f0
	tst.l D4
	bne.b LAB_002224e4
	moveq #$00000008,D0
	bra.b LAB_002224e6
LAB_002224e4:
	moveq #$00000010,D0
LAB_002224e6:
	or.b D0,($000c,A2)
	moveq #-$00000001,D0
	bra.w LAB_0022244e
LAB_002224f0:
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
	bra.w LAB_0022244e
FUN_00222512:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($000c,A5),A2
	cmpi.l #-$00000001,($0008,A5)
	beq.b LAB_00222530
	movea.l (A2),A0
	cmpa.l ($0008,A2),A0
	bhi.b LAB_0022253a
LAB_00222530:
	moveq #-$00000001,D0
LAB_00222532:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_0022253a:
	subq.l #$00000001,(A2)
	movea.l (A2),A0
	move.b ($000b,A5),(A0)
	move.l ($0008,A5),D0
	bra.b LAB_00222532
FUN_00222548:
	movea.l ($0004,SP),A0
	move.l ($0008,SP),D0
LAB_00222550:
	move.b (A0)+,D1
	beq.b LAB_0022255e
	cmp.b D0,D1
	bne.b LAB_00222550
	move.l A0,D0
	subq.l #$00000001,D0
	rts
LAB_0022255e:
	moveq #$00000000,D0
	rts
FUN_00222562:
	link.w A5,#$00000000
	movem.l A6/A2/D5/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	jsr FUN_00223598
	moveq #$00000006,D1
	move.l D4,D0
	jsr FUN_00223800
	movea.l D0,A2
	adda.l DAT_00223e4c,A2
	tst.l D4
	blt.b LAB_0022259a
	move.w DAT_00223cbc,D0
	ext.l D0
	cmp.l D0,D4
	bge.b LAB_0022259a
	tst.l (A2)
	bne.b LAB_002225ae
LAB_0022259a:
	move.l #$00000002,DAT_00223e50
	moveq #-$00000001,D0
LAB_002225a6:
	movem.l (SP)+,D2/D3/D4/D5/A2/A6
	unlk A5
	rts
LAB_002225ae:
	move.w ($0004,A2),D0
	ext.l D0
	and.l #$00000003,D0
	cmp.l #$00000001,D0
	bne.b LAB_002225d0
	move.l #$00000005,DAT_00223e50
	moveq #-$00000001,D0
	bra.b LAB_002225a6
LAB_002225d0:
	move.l ($0010,A5),-(SP)
	move.l ($000c,A5),-(SP)
	move.l (A2),-(SP)
	jsr FUN_00223914
	move.l D0,D5
	cmp.l #-$00000001,D0
	lea ($000c,SP),SP
	bne.b LAB_002225fe
	jsr FUN_002238b2
	move.l D0,DAT_00223e50
	moveq #-$00000001,D0
	bra.b LAB_002225a6
LAB_002225fe:
	move.l D5,D0
	bra.b LAB_002225a6
FUN_00222602:
	bsr.b FUN_00222680
	lea DAT_00223cc8,A1
	lea DAT_00223cc8,A2
	cmpa.l A1,A2
	bne.b LAB_00222622
	move.w #$0075,D1
	bmi.b LAB_00222622
	moveq #$00000000,D2
LAB_0022261c:
	move.l D2,(A1)+
	dbf D1,LAB_0022261c
LAB_00222622:
	move.l SP,DAT_00223e54
	movea.l $4,A6
	move.l A6,DAT_00223e58
	movem.l A0/D0,-(SP)
	btst.b #$00000004,($0129,A6)
	beq.b LAB_0022264e
	lea (LAB_00222648,PC),A5
	jsr (-$001e,A6)
	bra.b LAB_0022264e
LAB_00222648:
	clr.l -(SP)
	frestore (SP)+
	rte
LAB_0022264e:
	lea (s_dos_library_00222674,PC),A1
	jsr (-$0198,A6)
	move.l D0,DAT_00223e5c
	bne.b LAB_0022266a
	move.l #$00038007,D7
	jsr (-$006c,A6)
	bra.b LAB_00222670
LAB_0022266a:
	jsr FUN_00222688
LAB_00222670:
	addq.w #$00000008,SP
	rts
s_dos_library_00222674:
	dc.b "dos.library",0
FUN_00222680:
	lea FUN_00222680,A4
	rts
FUN_00222688:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	pea $00010000
	move.w DAT_00223cbc,D0
	muls.w #$0006,D0
	move.l D0,-(SP)
	jsr FUN_00223982
	move.l D0,DAT_00223e4c
	addq.w #$00000008,SP
	bne.b LAB_002226ca
	clr.l -(SP)
	pea $00010000
	jsr FUN_0022394e
	addq.w #$00000008,SP
	movea.l DAT_00223e54,SP
	rts
LAB_002226ca:
	movea.l DAT_00223e4c,A0
	clr.w ($0004,A0)
	movea.l DAT_00223e4c,A0
	move.w #$0001,($0010,A0)
	movea.l DAT_00223e4c,A0
	move.w #$0001,($000a,A0)
	movea.l DAT_00223e54,A0
	move.l DAT_00223e54,D0
	sub.l ($0004,A0),D0
	addq.l #$00000008,D0
	move.l D0,DAT_00223e60
	movea.l DAT_00223e60,A0
	move.l #$4d414e58,(A0)
	clr.l -(SP)
	jsr FUN_00223998
	movea.l D0,A2
	tst.l ($00ac,A2)
	addq.w #$00000004,SP
	beq.b LAB_0022275a
	move.l ($000c,A5),-(SP)
	move.l ($0008,A5),-(SP)
	move.l A2,-(SP)
	jsr FUN_00222812
	move.l #$00000001,DAT_00223e64
	movea.l DAT_00223e4c,A0
	ori.w #-$00008000,($0004,A0)
	movea.l DAT_00223e4c,A0
	ori.w #-$00008000,($000a,A0)
	lea ($000c,SP),SP
	bra.b LAB_002227b0
LAB_0022275a:
	pea ($005c,A2)
	jsr FUN_00223a06
	pea ($005c,A2)
	jsr FUN_002239c8
	move.l D0,DAT_00223e68
	movea.l DAT_00223e68,A0
	tst.l ($0024,A0)
	addq.w #$00000008,SP
	beq.b LAB_00222796
	movea.l DAT_00223e68,A0
	movea.l ($0024,A0),A1
	move.l (A1),-(SP)
	jsr FUN_0022384c
	addq.w #$00000004,SP
LAB_00222796:
	move.l DAT_00223e68,-(SP)
	move.l A2,-(SP)
	jsr FUN_00222a60
	move.l DAT_00223e68,DAT_00223e6c
	addq.w #$00000008,SP
LAB_002227b0:
	jsr FUN_002238a2
	movea.l DAT_00223e4c,A0
	move.l D0,(A0)
	jsr FUN_002238f6
	movea.l DAT_00223e4c,A0
	move.l D0,($0006,A0)
	beq.b LAB_002227ea
	pea $000003ed
	pea (DAT_00222810,PC)
	jsr FUN_002238e6
	movea.l DAT_00223e4c,A0
	move.l D0,($000c,A0)
	addq.w #$00000008,SP
LAB_002227ea:
	move.l DAT_00223e6c,-(SP)
	move.l DAT_00223e70,-(SP)
	jsr FUN_0021f004
	clr.l -(SP)
	jsr FUN_0022360e
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
DAT_00222810:
; Unknown data at address 00222810.
	dc.b $2a
; Unknown data at address 00222811.
	dc.b $00
FUN_00222812:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D5/D4/D3/D2,-(SP)
	movea.l ($0010,A5),A2
	movea.l ($0008,A5),A0
	tst.l ($00ac,A0)
	beq.b LAB_00222840
	movea.l ($0008,A5),A0
	move.l ($00ac,A0),D0
	asl.l #$00000002,D0
	move.l D0,D4
	movea.l D4,A0
	move.l ($0010,A0),D0
	asl.l #$00000002,D0
	movea.l D0,A3
	bra.b LAB_00222846
LAB_00222840:
	movea.l DAT_00223cbe,A3
LAB_00222846:
	move.b (A3),D0
	ext.w D0
	ext.l D0
	add.l ($000c,A5),D0
	addq.l #$00000002,D0
	move.l D0,DAT_00223e74
	clr.l -(SP)
	move.l DAT_00223e74,-(SP)
	jsr FUN_00223982
	move.l D0,DAT_00223e78
	addq.w #$00000008,SP
	bne.b LAB_00222878
LAB_00222870:
	movem.l (SP)+,D2/D3/D4/D5/A2/A3/A6
	unlk A5
	rts
LAB_00222878:
	move.b (A3),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	move.l D5,-(SP)
	movea.l A3,A0
	addq.l #$00000001,A0
	move.l A0,-(SP)
	move.l DAT_00223e78,-(SP)
	jsr FUN_00222a3e
	movea.l DAT_00223e78,A0
	adda.l D5,A0
	lea (DAT_00222a12,PC),A1
LAB_002228a0:
	move.b (A1)+,(A0)+
	bne.b LAB_002228a0
	move.l ($000c,A5),-(SP)
	move.l A2,-(SP)
	move.l DAT_00223e78,-(SP)
	jsr FUN_00222a1a
	movea.l DAT_00223e78,A0
	clr.b ($00,A0,D5.l)
	move.l #$00000001,DAT_00223e70
	movea.l DAT_00223e78,A0
	adda.l D5,A0
	movea.l A0,A3
	addq.l #$00000001,A3
	movea.l A3,A2
	lea ($0018,SP),SP
LAB_002228dc:
	move.b (A3),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	cmp.l #$00000020,D0
	beq.b LAB_0022290c
	cmp.l #$00000009,D5
	beq.b LAB_0022290c
	cmp.l #$0000000c,D5
	beq.b LAB_0022290c
	cmp.l #$0000000d,D5
	beq.b LAB_0022290c
	cmp.l #$0000000a,D5
	bne.b LAB_00222910
LAB_0022290c:
	addq.l #$00000001,A3
	bra.b LAB_002228dc
LAB_00222910:
	cmpi.b #$00000020,(A3)
	blt.w LAB_002229a4
	cmpi.b #$00000022,(A3)
	bne.b LAB_00222950
	addq.l #$00000001,A3
LAB_00222920:
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	beq.b LAB_0022294e
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b D5,(A0)
	cmp.l #$00000022,D5
	bne.b LAB_0022294c
	cmpi.b #$00000022,(A3)
	bne.b LAB_00222946
	addq.l #$00000001,A3
	bra.b LAB_0022294c
LAB_00222946:
	clr.b (-$0001,A2)
	bra.b LAB_0022294e
LAB_0022294c:
	bra.b LAB_00222920
LAB_0022294e:
	bra.b LAB_00222994
LAB_00222950:
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D5
	beq.b LAB_0022298e
	cmp.l #$00000020,D5
	beq.b LAB_0022298e
	cmp.l #$00000009,D5
	beq.b LAB_0022298e
	cmp.l #$0000000c,D5
	beq.b LAB_0022298e
	cmp.l #$0000000d,D5
	beq.b LAB_0022298e
	cmp.l #$0000000a,D5
	beq.b LAB_0022298e
	movea.l A2,A0
	addq.l #$00000001,A2
	move.b D5,(A0)
	bra.b LAB_00222950
LAB_0022298e:
	movea.l A2,A0
	addq.l #$00000001,A2
	clr.b (A0)
LAB_00222994:
	tst.l D5
	bne.b LAB_0022299a
	subq.l #$00000001,A3
LAB_0022299a:
	addq.l #$00000001,DAT_00223e70
	bra.w LAB_002228dc
LAB_002229a4:
	clr.b (A2)
	clr.l -(SP)
	move.l DAT_00223e70,D0
	addq.l #$00000001,D0
	asl.l #$00000002,D0
	move.l D0,-(SP)
	jsr FUN_00223982
	move.l D0,DAT_00223e6c
	addq.w #$00000008,SP
	bne.b LAB_002229ce
	clr.l DAT_00223e70
	bra.w LAB_00222870
LAB_002229ce:
	moveq #$00000000,D5
	movea.l DAT_00223e78,A3
	bra.b LAB_002229f8
LAB_002229d8:
	move.l D5,D0
	asl.l #$00000002,D0
	movea.l DAT_00223e6c,A0
	move.l A3,($00,A0,D0.l)
	movea.l A3,A0
	move.l A0,D0
LAB_002229ea:
	tst.b (A0)+
	bne.b LAB_002229ea
	suba.l D0,A0
	subq.l #$00000001,A0
	addq.l #$00000001,A0
	adda.l A0,A3
	addq.l #$00000001,D5
LAB_002229f8:
	cmp.l DAT_00223e70,D5
	blt.b LAB_002229d8
	move.l D5,D0
	asl.l #$00000002,D0
	movea.l DAT_00223e6c,A0
	clr.l ($00,A0,D0.l)
	bra.w LAB_00222870
DAT_00222a12:
	; undefined1
	dc.b $20
DAT_00222a13:
	; undefined1
	dc.b $00
FUN_00222a14:
	move.w #$7fff,D0
	bra.b LAB_00222a1e
FUN_00222a1a:
	move.w ($000e,SP),D0
LAB_00222a1e:
	movea.l ($0004,SP),A0
LAB_00222a22:
	tst.b (A0)+
	bne.b LAB_00222a22
	subq.w #$00000001,A0
	movea.l ($0008,SP),A1
	subq.w #$00000001,D0
LAB_00222a2e:
	move.b (A1)+,(A0)+
	dbeq D0,LAB_00222a2e
	beq.b LAB_00222a38
	clr.b (A0)
LAB_00222a38:
	move.l ($0004,SP),D0
	rts
FUN_00222a3e:
	movem.l ($0004,SP),A0/A1
	move.l A0,D0
	move.l ($000c,SP),D1
	bra.b LAB_00222a4e
LAB_00222a4c:
	move.b (A1)+,(A0)+
LAB_00222a4e:
	dbeq D1,LAB_00222a4c
	beq.b LAB_00222a5a
	addq.w #$00000001,D1
	bra.b LAB_00222a5a
LAB_00222a58:
	clr.b (A0)+
LAB_00222a5a:
	dbf D1,LAB_00222a58
	rts
FUN_00222a60:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D6/D5/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	clr.l -(SP)
	pea (s_icon_library_00222b14,PC)
	jsr FUN_002239d6
	move.l D0,DAT_00223e7c
	addq.w #$00000008,SP
	bne.b LAB_00222a8a
LAB_00222a82:
	movem.l (SP)+,D2/D3/D4/D5/D6/A2/A3/A6
	unlk A5
	rts
LAB_00222a8a:
	movea.l ($000c,A5),A0
	movea.l ($0024,A0),A1
	move.l ($0004,A1),-(SP)
	jsr FUN_00223a32
	move.l D0,D4
	addq.w #$00000004,SP
	beq.b LAB_00222afc
	pea (s_WINDOW_00222b21,PC)
	movea.l D4,A0
	move.l ($0036,A0),-(SP)
	jsr FUN_00223a14
	movea.l D0,A3
	tst.l D0
	addq.w #$00000008,SP
	beq.b LAB_00222af2
	pea $000003ed
	move.l A3,-(SP)
	jsr FUN_002238e6
	move.l D0,D6
	addq.w #$00000008,SP
	beq.b LAB_00222af2
	move.l D6,D0
	asl.l #$00000002,D0
	move.l D0,D5
	movea.l D5,A0
	move.l ($0008,A0),($00a4,A2)
	move.l D6,($009c,A2)
	pea $000003ed
	pea (DAT_00222b28,PC)
	jsr FUN_002238e6
	move.l D0,($00a0,A2)
	addq.w #$00000008,SP
LAB_00222af2:
	move.l D4,-(SP)
	jsr FUN_00223a24
	addq.w #$00000004,SP
LAB_00222afc:
	move.l DAT_00223e7c,-(SP)
	jsr thunk_FUN_0022396e
	clr.l DAT_00223e7c
	addq.w #$00000004,SP
	bra.w LAB_00222a82
s_icon_library_00222b14:
	dc.b "icon.library",0
s_WINDOW_00222b21:
	dc.b "WINDOW",0
DAT_00222b28:
; Unknown data at address 00222b28.
	dc.b $2a
; Unknown data at address 00222b29.
	dc.b $00
FUN_00222b2a:
	link.w A5,#$00000000
	movem.l A6/D4/D3/D2,-(SP)
	move.l ($0008,A5),DAT_00223cd4
	pea ($0010,A5)
	move.l ($000c,A5),-(SP)
	pea (LAB_00222b64,PC)
	jsr FUN_00222c44
	move.l D0,D4
	movea.l DAT_00223cd4,A0
	clr.b (A0)
	move.l D4,D0
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/D4/A6
	unlk A5
	rts
LAB_00222b64:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	movea.l DAT_00223cd4,A0
	addq.l #$00000001,DAT_00223cd4
	move.b ($000b,A5),D0
	move.b D0,(A0)
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00222b90:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	pea ($000c,A5)
	move.l ($0008,A5),-(SP)
	pea LAB_00223058
	jsr FUN_00222c44
	lea ($000c,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_00222bb8:
	link.w A5,#$00000000
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0010,A5),A2
	cmpi.l #$00000004,($0014,A5)
	bne.b LAB_00222bd6
	movea.l ($0008,A5),A0
	move.l (A0),D4
	bra.b LAB_00222bea
LAB_00222bd6:
	tst.l ($000c,A5)
	ble.b LAB_00222be4
	movea.l ($0008,A5),A0
	move.l (A0),D4
	bra.b LAB_00222bea
LAB_00222be4:
	movea.l ($0008,A5),A0
	move.l (A0),D4
LAB_00222bea:
	clr.l ($0014,A5)
	tst.l ($000c,A5)
	bge.b LAB_00222c06
	neg.l ($000c,A5)
	tst.l D4
	bge.b LAB_00222c06
	neg.l D4
	move.l #$00000001,($0014,A5)
LAB_00222c06:
	move.l ($000c,A5),D1
	move.l D4,D0
	jsr FUN_00222ff2
	lea s_0123456789abcdef_00223a70,A0
	subq.l #$00000001,A2
	move.b ($00,A0,D0.l),(A2)
	move.l ($000c,A5),D1
	move.l D4,D0
	jsr FUN_00222ffe
	move.l D0,D4
	bne.b LAB_00222c06
	tst.l ($0014,A5)
	beq.b LAB_00222c3a
	subq.l #$00000001,A2
	move.b #$2d,(A2)
LAB_00222c3a:
	move.l A2,D0
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
FUN_00222c44:
	link.w A5,#-$000000ec
	movem.l A6/A3/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	movea.l ($000c,A5),A3
	clr.l (-$0008,A5)
	move.l ($0010,A5),(-$0004,A5)
LAB_00222c5e:
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	beq.w LAB_00222fa8
	cmp.l #$00000025,D4
	bne.w LAB_00222f8c
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
	bne.b LAB_00222cb8
	clr.l (-$000c,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00222cb8:
	cmp.l #$00000030,D4
	bne.b LAB_00222cd4
	move.l #$00000030,(-$0010,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00222cd4:
	cmp.l #$0000002a,D4
	bne.b LAB_00222cf6
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	move.l (A0),(-$0018,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	bra.b LAB_00222d2e
LAB_00222cf6:
	clr.l (-$0018,A5)
	bra.b LAB_00222d20
LAB_00222cfc:
	moveq #$0000000a,D1
	move.l (-$0018,A5),D0
	jsr FUN_00223800
	add.l D4,D0
	sub.l #$00000030,D0
	move.l D0,(-$0018,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00222d20:
	lea DAT_00223a83,A0
	btst.b #$00000002,($00,A0,D4.l)
	bne.b LAB_00222cfc
LAB_00222d2e:
	cmp.l #$0000002e,D4
	bne.b LAB_00222d9c
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	cmp.l #$0000002a,D0
	bne.b LAB_00222d64
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	move.l (A0),(-$0014,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	bra.b LAB_00222d9c
LAB_00222d64:
	clr.l (-$0014,A5)
	bra.b LAB_00222d8e
LAB_00222d6a:
	moveq #$0000000a,D1
	move.l (-$0014,A5),D0
	jsr FUN_00223800
	add.l D4,D0
	sub.l #$00000030,D0
	move.l D0,(-$0014,A5)
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00222d8e:
	lea DAT_00223a83,A0
	btst.b #$00000002,($00,A0,D4.l)
	bne.b LAB_00222d6a
LAB_00222d9c:
	move.l #$00000004,(-$001c,A5)
	cmp.l #$0000006c,D4
	bne.b LAB_00222dc2
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
	move.l #$00000004,(-$001c,A5)
	bra.b LAB_00222dd6
LAB_00222dc2:
	cmp.l #$00000068,D4
	bne.b LAB_00222dd6
	movea.l A3,A0
	addq.l #$00000001,A3
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,D4
LAB_00222dd6:
	move.l D4,D0
	bra.w LAB_00222e5c
LAB_00222ddc:
	move.l #$00000008,(-$0020,A5)
	bra.b LAB_00222e02
LAB_00222de6:
	move.l #$0000000a,(-$0020,A5)
	bra.b LAB_00222e02
LAB_00222df0:
	move.l #$00000010,(-$0020,A5)
	bra.b LAB_00222e02
LAB_00222dfa:
	move.l #-$0000000a,(-$0020,A5)
LAB_00222e02:
	move.l (-$001c,A5),-(SP)
	pea (-$00de,A5)
	move.l (-$0020,A5),-(SP)
	move.l (-$0004,A5),-(SP)
	jsr (FUN_00222bb8,PC)
	move.l D0,(-$0024,A5)
	move.l (-$001c,A5),D0
	add.l D0,(-$0004,A5)
	lea ($0010,SP),SP
	bra.b LAB_00222e84
LAB_00222e28:
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	movea.l (A0),A1
	move.l A1,(-$0024,A5)
	move.l A1,D0
LAB_00222e38:
	tst.b (A1)+
	bne.b LAB_00222e38
	suba.l D0,A1
	subq.l #$00000001,A1
	move.l A1,(-$001c,A5)
	bra.b LAB_00222e90
LAB_00222e46:
	movea.l (-$0004,A5),A0
	addq.l #$00000004,(-$0004,A5)
	move.l (A0),D4
LAB_00222e50:
	lea (-$00df,A5),A0
	move.l A0,(-$0024,A5)
	move.b D4,(A0)
	bra.b LAB_00222e84
LAB_00222e5c:
	sub.l #$00000063,D0
	beq.b LAB_00222e46
	subq.l #$00000001,D0
	beq.b LAB_00222dfa
	sub.l #$0000000b,D0
	beq.w LAB_00222ddc
	subq.l #$00000004,D0
	beq.b LAB_00222e28
	subq.l #$00000002,D0
	beq.w LAB_00222de6
	subq.l #$00000003,D0
	beq.w LAB_00222df0
	bra.b LAB_00222e50
LAB_00222e84:
	lea (-$00de,A5),A0
	suba.l (-$0024,A5),A0
	move.l A0,(-$001c,A5)
LAB_00222e90:
	move.l (-$001c,A5),D0
	cmp.l (-$0014,A5),D0
	ble.b LAB_00222ea0
	move.l (-$0014,A5),(-$001c,A5)
LAB_00222ea0:
	tst.l (-$000c,A5)
	beq.b LAB_00222f16
	movea.l (-$0024,A5),A0
	cmpi.b #$0000002d,(A0)
	beq.b LAB_00222eba
	movea.l (-$0024,A5),A0
	cmpi.b #$0000002b,(A0)
	bne.b LAB_00222eee
LAB_00222eba:
	cmpi.l #$00000030,(-$0010,A5)
	bne.b LAB_00222eee
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
	bne.b LAB_00222eee
	moveq #-$00000001,D0
LAB_00222ee6:
	movem.l (SP)+,D2/D3/D4/A2/A3/A6
	unlk A5
	rts
LAB_00222eee:
	bra.b LAB_00222f08
LAB_00222ef0:
	move.l (-$0010,A5),-(SP)
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_00222f04
	moveq #-$00000001,D0
	bra.b LAB_00222ee6
LAB_00222f04:
	addq.l #$00000001,(-$0008,A5)
LAB_00222f08:
	move.l (-$0018,A5),D0
	subq.l #$00000001,(-$0018,A5)
	cmp.l (-$001c,A5),D0
	bgt.b LAB_00222ef0
LAB_00222f16:
	clr.l (-$0020,A5)
	bra.b LAB_00222f40
LAB_00222f1c:
	movea.l (-$0024,A5),A0
	addq.l #$00000001,(-$0024,A5)
	move.b (A0),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_00222f3c
	moveq #-$00000001,D0
	bra.b LAB_00222ee6
LAB_00222f3c:
	addq.l #$00000001,(-$0020,A5)
LAB_00222f40:
	movea.l (-$0024,A5),A0
	tst.b (A0)
	beq.b LAB_00222f52
	move.l (-$0020,A5),D0
	cmp.l (-$0014,A5),D0
	blt.b LAB_00222f1c
LAB_00222f52:
	move.l (-$0020,A5),D0
	add.l D0,(-$0008,A5)
	tst.l (-$000c,A5)
	bne.b LAB_00222f8a
	bra.b LAB_00222f7c
LAB_00222f62:
	pea $00000020
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_00222f78
	moveq #-$00000001,D0
	bra.w LAB_00222ee6
LAB_00222f78:
	addq.l #$00000001,(-$0008,A5)
LAB_00222f7c:
	move.l (-$0018,A5),D0
	subq.l #$00000001,(-$0018,A5)
	cmp.l (-$001c,A5),D0
	bgt.b LAB_00222f62
LAB_00222f8a:
	bra.b LAB_00222fa4
LAB_00222f8c:
	move.l D4,-(SP)
	jsr (A2)
	cmp.l #-$00000001,D0
	addq.w #$00000004,SP
	bne.b LAB_00222fa0
	moveq #-$00000001,D0
	bra.w LAB_00222ee6
LAB_00222fa0:
	addq.l #$00000001,(-$0008,A5)
LAB_00222fa4:
	bra.w LAB_00222c5e
LAB_00222fa8:
	move.l (-$0008,A5),D0
	bra.w LAB_00222ee6
; Unknown data at address 00222fb0.
	dc.b $48
; Unknown data at address 00222fb1.
	dc.b $e7
; Unknown data at address 00222fb2.
	dc.b $48
; Unknown data at address 00222fb3.
	dc.b $00
; Unknown data at address 00222fb4.
	dc.b $42
; Unknown data at address 00222fb5.
	dc.b $84
; Unknown data at address 00222fb6.
	dc.b $4a
; Unknown data at address 00222fb7.
	dc.b $80
; Unknown data at address 00222fb8.
	dc.b $6a
; Unknown data at address 00222fb9.
	dc.b $04
; Unknown data at address 00222fba.
	dc.b $44
; Unknown data at address 00222fbb.
	dc.b $80
; Unknown data at address 00222fbc.
	dc.b $52
; Unknown data at address 00222fbd.
	dc.b $44
; Unknown data at address 00222fbe.
	dc.b $4a
; Unknown data at address 00222fbf.
	dc.b $81
; Unknown data at address 00222fc0.
	dc.b $6a
; Unknown data at address 00222fc1.
	dc.b $06
; Unknown data at address 00222fc2.
	dc.b $44
; Unknown data at address 00222fc3.
	dc.b $81
; Unknown data at address 00222fc4.
	dc.b $0a
; Unknown data at address 00222fc5.
	dc.b $44
; Unknown data at address 00222fc6.
	dc.b $00
; Unknown data at address 00222fc7.
	dc.b $01
; Unknown data at address 00222fc8.
	dc.b $61
; Unknown data at address 00222fc9.
	dc.b $3e
; Unknown data at address 00222fca.
	dc.b $4a
; Unknown data at address 00222fcb.
	dc.b $44
; Unknown data at address 00222fcc.
	dc.b $67
; Unknown data at address 00222fcd.
	dc.b $02
; Unknown data at address 00222fce.
	dc.b $44
; Unknown data at address 00222fcf.
	dc.b $80
; Unknown data at address 00222fd0.
	dc.b $4c
; Unknown data at address 00222fd1.
	dc.b $df
; Unknown data at address 00222fd2.
	dc.b $00
; Unknown data at address 00222fd3.
	dc.b $12
; Unknown data at address 00222fd4.
	dc.b $4a
; Unknown data at address 00222fd5.
	dc.b $80
; Unknown data at address 00222fd6.
	dc.b $4e
; Unknown data at address 00222fd7.
	dc.b $75
; Unknown data at address 00222fd8.
	dc.b $48
; Unknown data at address 00222fd9.
	dc.b $e7
; Unknown data at address 00222fda.
	dc.b $48
; Unknown data at address 00222fdb.
	dc.b $00
; Unknown data at address 00222fdc.
	dc.b $42
; Unknown data at address 00222fdd.
	dc.b $84
; Unknown data at address 00222fde.
	dc.b $4a
; Unknown data at address 00222fdf.
	dc.b $80
; Unknown data at address 00222fe0.
	dc.b $6a
; Unknown data at address 00222fe1.
	dc.b $04
; Unknown data at address 00222fe2.
	dc.b $44
; Unknown data at address 00222fe3.
	dc.b $80
; Unknown data at address 00222fe4.
	dc.b $52
; Unknown data at address 00222fe5.
	dc.b $44
; Unknown data at address 00222fe6.
	dc.b $4a
; Unknown data at address 00222fe7.
	dc.b $81
; Unknown data at address 00222fe8.
	dc.b $6a
; Unknown data at address 00222fe9.
	dc.b $02
; Unknown data at address 00222fea.
	dc.b $44
; Unknown data at address 00222feb.
	dc.b $81
; Unknown data at address 00222fec.
	dc.b $61
; Unknown data at address 00222fed.
	dc.b $1a
; Unknown data at address 00222fee.
	dc.b $20
; Unknown data at address 00222fef.
	dc.b $01
; Unknown data at address 00222ff0.
	dc.b $60
; Unknown data at address 00222ff1.
	dc.b $d8
FUN_00222ff2:
	move.l D1,-(SP)
	bsr.b FUN_00223008
	move.l D1,D0
	move.l (SP)+,D1
	tst.l D0
	rts
FUN_00222ffe:
	move.l D1,-(SP)
	bsr.b FUN_00223008
	move.l (SP)+,D1
	tst.l D0
	rts
FUN_00223008:
	movem.l D3/D2,-(SP)
	swap D1
	tst.w D1
	bne.b LAB_00223032
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
LAB_00223032:
	swap D1
	move.l D1,D3
	move.l D0,D1
	clr.w D1
	swap D1
	swap D0
	clr.w D0
	moveq #$0000000f,D2
LAB_00223042:
	add.l D0,D0
	addx.l D1,D1
	cmp.l D1,D3
	bhi.b LAB_0022304e
	sub.l D3,D1
	addq.w #$00000001,D0
LAB_0022304e:
	dbf D2,LAB_00223042
	movem.l (SP)+,D2/D3
	rts
LAB_00223058:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	pea DAT_00223b1a
	move.l ($0008,A5),-(SP)
	jsr FUN_0022307a
	addq.w #$00000008,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_0022307a:
	link.w A5,#$00000000
	movem.l A6/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	move.l ($000c,A5),-(SP)
	move.l D4,-(SP)
	jsr FUN_002230c8
	cmp.l #$0000000a,D4
	addq.w #$00000008,SP
	bne.b LAB_002230c6
	movea.l ($000c,A5),A0
	move.b ($000c,A0),D0
	ext.w D0
	ext.l D0
	btst.l #$00000007,D0
	beq.b LAB_002230c6
	pea -1
	move.l ($000c,A5),-(SP)
	jsr FUN_002231cc
	addq.w #$00000008,SP
LAB_002230be:
	movem.l (SP)+,D2/D3/D4/A6
	unlk A5
	rts
LAB_002230c6:
	bra.b LAB_002230be
FUN_002230c8:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($000c,A5),A2
	movea.l (A2),A0
	cmpa.l ($0004,A2),A0
	bcs.b LAB_002230f8
	move.l ($0008,A5),D0
	and.l #$000000ff,D0
	move.l D0,-(SP)
	move.l A2,-(SP)
	jsr (FUN_002231cc,PC)
	addq.w #$00000008,SP
LAB_002230f0:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_002230f8:
	movea.l (A2),A0
	addq.l #$00000001,(A2)
	move.b ($000b,A5),D0
	move.b D0,(A0)
	ext.w D0
	ext.l D0
	and.l #$000000ff,D0
	bra.b LAB_002230f0
LAB_0022310e:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	lea DAT_00223b04,A0
	movea.l A0,A2
LAB_0022311e:
	movea.l A2,A0
	adda.l #$00000016,A2
	move.l A0,-(SP)
	bsr.b FUN_0022313e
	addq.w #$00000004,SP
	lea DAT_00223cbc,A0
	cmpa.l A0,A2
	bcs.b LAB_0022311e
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
FUN_0022313e:
	link.w A5,#$00000000
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	moveq #$00000000,D4
	move.l A2,D0
	bne.b LAB_0022315a
	moveq #-$00000001,D0
LAB_00223152:
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
LAB_0022315a:
	tst.b ($000c,A2)
	beq.b LAB_002231ba
	btst.b #$00000002,($000c,A2)
	beq.b LAB_00223174
	pea -1
	move.l A2,-(SP)
	bsr.b FUN_002231cc
	move.l D0,D4
	addq.w #$00000008,SP
LAB_00223174:
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_002237a0
	or.l D0,D4
	btst.b #$00000001,($000c,A2)
	addq.w #$00000004,SP
	beq.b LAB_0022319c
	move.l ($0008,A2),-(SP)
	jsr FUN_0022340a
	addq.w #$00000004,SP
LAB_0022319c:
	btst.b #$00000005,($000c,A2)
	beq.b LAB_002231ba
	move.l ($0012,A2),-(SP)
	jsr FUN_002234d0
	move.l ($0012,A2),-(SP)
	jsr FUN_0022340a
	addq.w #$00000008,SP
LAB_002231ba:
	clr.l (A2)
	clr.l ($0004,A2)
	clr.l ($0008,A2)
	clr.b ($000c,A2)
	move.l D4,D0
	bra.b LAB_00223152
FUN_002231cc:
	link.w A5,#-$00000002
	movem.l A6/A2/D4/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	lea (LAB_0022310e,PC),A0
	move.l A0,DAT_00223e80
	btst.b #$00000004,($000c,A2)
	beq.b LAB_002231f4
	moveq #-$00000001,D0
LAB_002231ec:
	movem.l (SP)+,D2/D3/D4/A2/A6
	unlk A5
	rts
LAB_002231f4:
	btst.b #$00000002,($000c,A2)
	beq.b LAB_00223232
	movea.l (A2),A0
	suba.l ($0008,A2),A0
	move.l A0,D4
	move.l D4,-(SP)
	move.l ($0008,A2),-(SP)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_00223502
	cmp.l D4,D0
	lea ($000c,SP),SP
	beq.b LAB_00223232
LAB_00223222:
	bset.b #$00000004,($000c,A2)
	clr.l (A2)
	clr.l ($0004,A2)
	moveq #-$00000001,D0
	bra.b LAB_002231ec
LAB_00223232:
	cmpi.l #-$00000001,($000c,A5)
	bne.b LAB_0022324c
	bclr.b #$00000002,($000c,A2)
	clr.l (A2)
	clr.l ($0004,A2)
	moveq #$00000000,D0
	bra.b LAB_002231ec
LAB_0022324c:
	tst.l ($0008,A2)
	bne.b LAB_0022325c
	move.l A2,-(SP)
	jsr FUN_00223306
	addq.w #$00000004,SP
LAB_0022325c:
	cmpi.w #$00000001,($0010,A2)
	bne.b LAB_00223296
	move.b ($000f,A5),(-$0001,A5)
	pea $00000001
	pea (-$0001,A5)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_00223502
	cmp.l #$00000001,D0
	lea ($000c,SP),SP
	bne.b LAB_00223222
	move.l ($000c,A5),D0
	bra.w LAB_002231ec
LAB_00223296:
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
	bra.w LAB_002231ec
; Unknown data at address 002232c6.
	dc.b $4e
; Unknown data at address 002232c7.
	dc.b $55
; Unknown data at address 002232c8.
	dc.b $00
; Unknown data at address 002232c9.
	dc.b $00
; Unknown data at address 002232ca.
	dc.b $48
; Unknown data at address 002232cb.
	dc.b $e7
; Unknown data at address 002232cc.
	dc.b $30
; Unknown data at address 002232cd.
	dc.b $22
; Unknown data at address 002232ce.
	dc.b $41
; Unknown data at address 002232cf.
	dc.b $f9
; Unknown data at address 002232d0.
	dc.b $00
; Unknown data at address 002232d1.
	dc.b $22
; Unknown data at address 002232d2.
	dc.b $3b
; Unknown data at address 002232d3.
	dc.b $04
; Unknown data at address 002232d4.
	dc.b $24
; Unknown data at address 002232d5.
	dc.b $48
; Unknown data at address 002232d6.
	dc.b $4a
; Unknown data at address 002232d7.
	dc.b $2a
; Unknown data at address 002232d8.
	dc.b $00
; Unknown data at address 002232d9.
	dc.b $0c
; Unknown data at address 002232da.
	dc.b $67
; Unknown data at address 002232db.
	dc.b $1c
; Unknown data at address 002232dc.
	dc.b $d5
; Unknown data at address 002232dd.
	dc.b $fc
; Unknown data at address 002232de.
	dc.b $00
; Unknown data at address 002232df.
	dc.b $00
; Unknown data at address 002232e0.
	dc.b $00
; Unknown data at address 002232e1.
	dc.b $16
; Unknown data at address 002232e2.
	dc.b $41
; Unknown data at address 002232e3.
	dc.b $f9
; Unknown data at address 002232e4.
	dc.b $00
; Unknown data at address 002232e5.
	dc.b $22
; Unknown data at address 002232e6.
	dc.b $3c
; Unknown data at address 002232e7.
	dc.b $bc
; Unknown data at address 002232e8.
	dc.b $b5
; Unknown data at address 002232e9.
	dc.b $c8
; Unknown data at address 002232ea.
	dc.b $65
; Unknown data at address 002232eb.
	dc.b $0a
; Unknown data at address 002232ec.
	dc.b $70
; Unknown data at address 002232ed.
	dc.b $00
; Unknown data at address 002232ee.
	dc.b $4c
; Unknown data at address 002232ef.
	dc.b $df
; Unknown data at address 002232f0.
	dc.b $44
; Unknown data at address 002232f1.
	dc.b $0c
; Unknown data at address 002232f2.
	dc.b $4e
; Unknown data at address 002232f3.
	dc.b $5d
; Unknown data at address 002232f4.
	dc.b $4e
; Unknown data at address 002232f5.
	dc.b $75
; Unknown data at address 002232f6.
	dc.b $60
; Unknown data at address 002232f7.
	dc.b $de
; Unknown data at address 002232f8.
	dc.b $42
; Unknown data at address 002232f9.
	dc.b $92
; Unknown data at address 002232fa.
	dc.b $42
; Unknown data at address 002232fb.
	dc.b $aa
; Unknown data at address 002232fc.
	dc.b $00
; Unknown data at address 002232fd.
	dc.b $04
; Unknown data at address 002232fe.
	dc.b $42
; Unknown data at address 002232ff.
	dc.b $aa
; Unknown data at address 00223300.
	dc.b $00
; Unknown data at address 00223301.
	dc.b $08
; Unknown data at address 00223302.
	dc.b $20
; Unknown data at address 00223303.
	dc.b $0a
; Unknown data at address 00223304.
	dc.b $60
; Unknown data at address 00223305.
	dc.b $e8
FUN_00223306:
	link.w A5,#-$0004
	movem.l A6/A2/D3/D2,-(SP)
	movea.l ($0008,A5),A2
	pea $00000400
	jsr FUN_002233f2
	move.l D0,(-$0004,A5)
	addq.w #$00000004,SP
	bne.b LAB_0022333e
	move.w #$0001,($0010,A2)
	movea.l A2,A0
	adda.l #$0000000e,A0
	move.l A0,($0008,A2)
LAB_00223336:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_0022333e:
	move.w #$0400,($0010,A2)
	bset.b #$00000001,($000c,A2)
	move.l (-$0004,A5),($0008,A2)
	move.b ($000d,A2),D0
	ext.w D0
	ext.l D0
	move.l D0,-(SP)
	jsr FUN_0022345c
	tst.l D0
	addq.w #$00000004,SP
	beq.b LAB_0022336c
	ori.b #-$00000080,($000c,A2)
LAB_0022336c:
	bra.b LAB_00223336
LAB_0022336e:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D3/D2,-(SP)
	movea.l DAT_00223cd8,A2
	bra.b LAB_00223394
LAB_0022337e:
	movea.l (A2),A3
	move.l ($0004,A2),D0
	addq.l #$00000008,D0
	move.l D0,-(SP)
	move.l A2,-(SP)
	jsr FUN_002239b6
	addq.w #$00000008,SP
	movea.l A3,A2
LAB_00223394:
	move.l A2,D0
	bne.b LAB_0022337e
	clr.l DAT_00223cd8
	movem.l (SP)+,D2/D3/A2/A3/A6
	unlk A5
	rts
FUN_002233a6:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	lea (LAB_0022336e,PC),A0
	move.l A0,DAT_00223e84
	clr.l -(SP)
	move.l ($0008,A5),D0
	addq.l #$00000008,D0
	move.l D0,-(SP)
	jsr FUN_00223982
	movea.l D0,A2
	tst.l D0
	addq.w #$00000008,SP
	bne.b LAB_002233da
	moveq #$00000000,D0
LAB_002233d2:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_002233da:
	move.l DAT_00223cd8,(A2)
	move.l ($0008,A5),($0004,A2)
	move.l A2,DAT_00223cd8
	move.l A2,D0
	addq.l #$00000008,D0
	bra.b LAB_002233d2
FUN_002233f2:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	move.l ($0008,A5),-(SP)
	bsr.b FUN_002233a6
	addq.w #$00000004,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_0022340a:
	link.w A5,#$00000000
	movem.l A6/A3/A2/D3/D2,-(SP)
	suba.l A3,A3
	movea.l DAT_00223cd8,A2
	bra.b LAB_0022342a
LAB_0022341c:
	movea.l ($0008,A5),A0
	subq.l #$00000008,A0
	cmpa.l A2,A0
	beq.b LAB_00223438
	movea.l A2,A3
	movea.l (A2),A2
LAB_0022342a:
	move.l A2,D0
	bne.b LAB_0022341c
	moveq #-$00000001,D0
LAB_00223430:
	movem.l (SP)+,D2/D3/A2/A3/A6
	unlk A5
	rts
LAB_00223438:
	move.l A3,D0
	beq.b LAB_00223440
	move.l (A2),(A3)
	bra.b LAB_00223446
LAB_00223440:
	move.l (A2),DAT_00223cd8
LAB_00223446:
	move.l ($0004,A2),D0
	addq.l #$00000008,D0
	move.l D0,-(SP)
	move.l A2,-(SP)
	jsr FUN_002239b6
	moveq #$00000000,D0
	addq.w #$00000008,SP
	bra.b LAB_00223430
FUN_0022345c:
	link.w A5,#$00000000
	movem.l A6/A2/D3/D2,-(SP)
	moveq #$00000006,D1
	move.l ($0008,A5),D0
	jsr FUN_00223800
	movea.l D0,A2
	adda.l DAT_00223e4c,A2
	tst.l ($0008,A5)
	blt.b LAB_00223492
	move.w DAT_00223cbc,D0
	ext.l D0
	move.l ($0008,A5),D1
	cmp.l D0,D1
	bge.b LAB_00223492
	tst.l (A2)
	bne.b LAB_002234a6
LAB_00223492:
	move.l #$00000002,DAT_00223e50
	moveq #-$00000001,D0
LAB_0022349e:
	movem.l (SP)+,D2/D3/A2/A6
	unlk A5
	rts
LAB_002234a6:
	moveq #$00000006,D1
	move.l ($0008,A5),D0
	jsr FUN_00223800
	movea.l DAT_00223e4c,A0
	move.l ($00,A0,D0.l),-(SP)
	jsr FUN_002238bc
	tst.l D0
	addq.w #$00000004,SP
	beq.b LAB_002234cc
	moveq #$00000001,D0
	bra.b LAB_002234ce
LAB_002234cc:
	moveq #$00000000,D0
LAB_002234ce:
	bra.b LAB_0022349e
FUN_002234d0:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	move.l ($0008,A5),-(SP)
	jsr FUN_0022386e
	tst.l D0
	addq.w #$00000004,SP
	bne.b LAB_002234fe
	jsr FUN_002238b2
	move.l D0,DAT_00223e50
	moveq #-$00000001,D0
LAB_002234f6:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_002234fe:
	moveq #$00000000,D0
	bra.b LAB_002234f6
FUN_00223502:
	link.w A5,#$00000000
	movem.l A6/A2/D5/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	jsr FUN_00223598
	moveq #$00000006,D1
	move.l D4,D0
	jsr FUN_00223800
	movea.l D0,A2
	adda.l DAT_00223e4c,A2
	tst.l D4
	blt.b LAB_0022353a
	move.w DAT_00223cbc,D0
	ext.l D0
	cmp.l D0,D4
	bge.b LAB_0022353a
	tst.l (A2)
	bne.b LAB_0022354e
LAB_0022353a:
	move.l #$00000002,DAT_00223e50
	moveq #-$00000001,D0
LAB_00223546:
	movem.l (SP)+,D2/D3/D4/D5/A2/A6
	unlk A5
	rts
LAB_0022354e:
	move.w ($0004,A2),D0
	and.w #$0003,D0
	bne.b LAB_00223566
	move.l #$00000005,DAT_00223e50
	moveq #-$00000001,D0
	bra.b LAB_00223546
LAB_00223566:
	move.l ($0010,A5),-(SP)
	move.l ($000c,A5),-(SP)
	move.l (A2),-(SP)
	jsr FUN_0022393e
	move.l D0,D5
	cmp.l #-$00000001,D0
	lea ($000c,SP),SP
	bne.b LAB_00223594
	jsr FUN_002238b2
	move.l D0,DAT_00223e50
	moveq #-$00000001,D0
	bra.b LAB_00223546
LAB_00223594:
	move.l D5,D0
	bra.b LAB_00223546
FUN_00223598:
	link.w A5,#-$0004
	movem.l A6/D3/D2,-(SP)
	pea $00001000
	clr.l -(SP)
	jsr FUN_002239f6
	move.l D0,(-$0004,A5)
	btst.l #$0000000c,D0
	addq.w #$00000008,SP
	beq.b LAB_002235d2
	tst.l DAT_00223e64
	bne.b LAB_002235cc
	move.l (-$0004,A5),D0
LAB_002235c4:
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
LAB_002235cc:
	jsr FUN_002235d6
LAB_002235d2:
	moveq #$00000000,D0
	bra.b LAB_002235c4
FUN_002235d6:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	pea $00000004
	pea (DAT_0022360a,PC)
	jsr FUN_002238f6
	move.l D0,-(SP)
	jsr FUN_0022393e
	pea $00000001
	jsr FUN_0022360e
	lea ($0010,SP),SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
DAT_0022360a:
; Unknown data at address 0022360a.
	dc.b $5e
; Unknown data at address 0022360b.
	dc.b $43
; Unknown data at address 0022360c.
	dc.b $0a
; Unknown data at address 0022360d.
	dc.b $00
FUN_0022360e:
	link.w A5,#$00000000
	movem.l A6/D3/D2,-(SP)
	tst.l DAT_00223e80
	beq.b LAB_00223626
	movea.l DAT_00223e80,A0
	jsr (A0)
LAB_00223626:
	move.l ($0008,A5),-(SP)
	jsr FUN_0022363a
	addq.w #$00000004,SP
	movem.l (SP)+,D2/D3/A6
	unlk A5
	rts
FUN_0022363a:
	link.w A5,#-$0004
	movem.l A6/D4/D3/D2,-(SP)
	move.l ($0008,A5),(-$0004,A5)
	tst.l DAT_00223e4c
	beq.b LAB_00223686
	moveq #$00000000,D4
	bra.b LAB_00223660
LAB_00223654:
	move.l D4,-(SP)
	jsr FUN_002237a0
	addq.w #$00000004,SP
	addq.l #$00000001,D4
LAB_00223660:
	move.w DAT_00223cbc,D0
	ext.l D0
	cmp.l D0,D4
	blt.b LAB_00223654
	move.w DAT_00223cbc,D0
	muls.w #$0006,D0
	move.l D0,-(SP)
	move.l DAT_00223e4c,-(SP)
	jsr FUN_002239b6
	addq.w #$00000008,SP
LAB_00223686:
	tst.l DAT_00223e84
	beq.b LAB_00223696
	movea.l DAT_00223e84,A0
	jsr (A0)
LAB_00223696:
	tst.l DAT_00223cc2
	beq.b LAB_002236ac
	move.l DAT_00223cc2,-(SP)
	jsr thunk_FUN_0022392a
	addq.w #$00000004,SP
LAB_002236ac:
	tst.l DAT_00223e88
	beq.b LAB_002236c0
	movea.l DAT_00223e88,A0
	move.l DAT_00223e8c,(A0)
LAB_002236c0:
	tst.l DAT_00223e90
	beq.b LAB_002236d6
	move.l DAT_00223e90,-(SP)
	jsr FUN_0022396e
	addq.w #$00000004,SP
LAB_002236d6:
	tst.l DAT_00223e94
	beq.b LAB_002236ec
	move.l DAT_00223e94,-(SP)
	jsr FUN_0022396e
	addq.w #$00000004,SP
LAB_002236ec:
	tst.l DAT_00223e98
	beq.b LAB_00223702
	move.l DAT_00223e98,-(SP)
	jsr FUN_0022396e
	addq.w #$00000004,SP
LAB_00223702:
	tst.l DAT_00223e9c
	beq.b LAB_00223718
	move.l DAT_00223e9c,-(SP)
	jsr FUN_0022396e
	addq.w #$00000004,SP
LAB_00223718:
	movea.l $4,A6
	btst.b #$00000004,($0129,A6)
	beq.b LAB_00223738
	move.l A5,-(SP)
	lea (LAB_00223732,PC),A5
	jsr (-$001e,A6)
	movea.l (SP)+,A5
	bra.b LAB_00223738
LAB_00223732:
	clr.l -(SP)
	frestore (SP)+
	rte
LAB_00223738:
	tst.l DAT_00223e68
	bne.b LAB_00223778
	tst.l DAT_00223e78
	beq.b LAB_00223776
	move.l DAT_00223e74,-(SP)
	move.l DAT_00223e78,-(SP)
	jsr FUN_002239b6
	move.l DAT_00223e70,D0
	addq.l #$00000001,D0
	asl.l #$00000002,D0
	move.l D0,-(SP)
	move.l DAT_00223e6c,-(SP)
	jsr FUN_002239b6
	lea ($0010,SP),SP
LAB_00223776:
	bra.b LAB_0022378c
LAB_00223778:
	jsr FUN_002239a6
	move.l DAT_00223e68,-(SP)
	jsr FUN_002239e8
	addq.w #$00000004,SP
LAB_0022378c:
	move.l (-$0004,A5),D0
	movea.l DAT_00223e54,SP
	rts
; Unknown data at address 00223798.
	dc.b $4c
; Unknown data at address 00223799.
	dc.b $df
; Unknown data at address 0022379a.
	dc.b $40
; Unknown data at address 0022379b.
	dc.b $1c
; Unknown data at address 0022379c.
	dc.b $4e
; Unknown data at address 0022379d.
	dc.b $5d
; Unknown data at address 0022379e.
	dc.b $4e
; Unknown data at address 0022379f.
	dc.b $75
FUN_002237a0:
	link.w A5,#$00000000
	movem.l A6/A2/D6/D5/D4/D3/D2,-(SP)
	move.l ($0008,A5),D4
	moveq #$00000006,D1
	move.l D4,D0
	jsr FUN_00223800
	movea.l D0,A2
	adda.l DAT_00223e4c,A2
	tst.l D4
	blt.b LAB_002237d2
	move.w DAT_00223cbc,D0
	ext.l D0
	cmp.l D0,D4
	bge.b LAB_002237d2
	tst.l (A2)
	bne.b LAB_002237e6
LAB_002237d2:
	move.l #$00000002,DAT_00223e50
	moveq #-$00000001,D0
LAB_002237de:
	movem.l (SP)+,D2/D3/D4/D5/D6/A2/A6
	unlk A5
	rts
LAB_002237e6:
	move.w ($0004,A2),D0
	and.w #-$8000,D0
	bne.b LAB_002237fa
	move.l (A2),-(SP)
	jsr FUN_0022382a
	addq.w #$00000004,SP
LAB_002237fa:
	clr.l (A2)
	moveq #$00000000,D0
	bra.b LAB_002237de
FUN_00223800:
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
thunk_FUN_0022382a:
	jmp FUN_0022382a
FUN_0022382a:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$0024,A6)
FUN_00223838:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$0078,A6)
thunk_FUN_0022384c:
	jmp FUN_0022384c
FUN_0022384c:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$007e,A6)
FUN_0022385a:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$00c6,A6)
thunk_FUN_0022386e:
	jmp FUN_0022386e
FUN_0022386e:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$0048,A6)
thunk_FUN_00223882:
	jmp FUN_00223882
FUN_00223882:
	movem.l ($0004,SP),D1/D2
	movea.l DAT_00223e5c,A6
	jmp (-$0066,A6)
FUN_00223892:
	movem.l ($0004,SP),D1/D2/D3
	movea.l DAT_00223e5c,A6
	jmp (-$00de,A6)
FUN_002238a2:
	movea.l DAT_00223e5c,A6
	jmp (-$0036,A6)
thunk_FUN_002238b2:
	jmp FUN_002238b2
FUN_002238b2:
	movea.l DAT_00223e5c,A6
	jmp (-$0084,A6)
FUN_002238bc:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$00d8,A6)
thunk_FUN_002238d0:
	jmp FUN_002238d0
FUN_002238d0:
	movem.l ($0004,SP),D1/D2
	movea.l DAT_00223e5c,A6
	jmp (-$0054,A6)
thunk_FUN_002238e6:
	jmp FUN_002238e6
FUN_002238e6:
	movem.l ($0004,SP),D1/D2
	movea.l DAT_00223e5c,A6
	jmp (-$001e,A6)
FUN_002238f6:
	movea.l DAT_00223e5c,A6
	jmp (-$003c,A6)
FUN_00223900:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$00d2,A6)
thunk_FUN_00223914:
	jmp FUN_00223914
FUN_00223914:
	movem.l ($0004,SP),D1/D2/D3
	movea.l DAT_00223e5c,A6
	jmp (-$002a,A6)
thunk_FUN_0022392a:
	jmp FUN_0022392a
FUN_0022392a:
	move.l ($0004,SP),D1
	movea.l DAT_00223e5c,A6
	jmp (-$005a,A6)
thunk_FUN_0022393e:
	jmp FUN_0022393e
FUN_0022393e:
	movem.l ($0004,SP),D1/D2/D3
	movea.l DAT_00223e5c,A6
	jmp (-$0030,A6)
FUN_0022394e:
	movem.l A5/D7,-(SP)
	movem.l ($000c,SP),D7/A5
	movea.l DAT_00223e58,A6
	jsr (-$006c,A6)
	movem.l (SP)+,D7/A5
	rts
thunk_FUN_0022396e:
	jmp FUN_0022396e
FUN_0022396e:
	movea.l ($0004,SP),A1
	movea.l DAT_00223e58,A6
	jmp (-$019e,A6)
thunk_FUN_00223982:
	jmp FUN_00223982
FUN_00223982:
	movem.l ($0004,SP),D0/D1
	movea.l DAT_00223e58,A6
	jmp (-$00c6,A6)
thunk_FUN_00223998:
	jmp FUN_00223998
FUN_00223998:
	movea.l ($0004,SP),A1
	movea.l DAT_00223e58,A6
	jmp (-$0126,A6)
FUN_002239a6:
	movea.l DAT_00223e58,A6
	jmp (-$0084,A6)
thunk_FUN_002239b6:
	jmp FUN_002239b6
FUN_002239b6:
	movea.l ($0004,SP),A1
	move.l ($0008,SP),D0
	movea.l DAT_00223e58,A6
	jmp (-$00d2,A6)
FUN_002239c8:
	movea.l ($0004,SP),A0
	movea.l DAT_00223e58,A6
	jmp (-$0174,A6)
FUN_002239d6:
	movea.l DAT_00223e58,A6
	movea.l ($0004,SP),A1
	move.l ($0008,SP),D0
	jmp (-$0228,A6)
FUN_002239e8:
	movea.l ($0004,SP),A1
	movea.l DAT_00223e58,A6
	jmp (-$017a,A6)
FUN_002239f6:
	movem.l ($0004,SP),D0/D1
	movea.l DAT_00223e58,A6
	jmp (-$0132,A6)
FUN_00223a06:
	movea.l ($0004,SP),A0
	movea.l DAT_00223e58,A6
	jmp (-$0180,A6)
FUN_00223a14:
	movem.l ($0004,SP),A0/A1
	movea.l DAT_00223e7c,A6
	jmp (-$0060,A6)
FUN_00223a24:
	movea.l ($0004,SP),A0
	movea.l DAT_00223e7c,A6
	jmp (-$005a,A6)
FUN_00223a32:
	movea.l ($0004,SP),A0
	movea.l DAT_00223e7c,A6
	jmp (-$004e,A6)
;   }

; #######################
; # HUNK01 - DATA       #
; #######################
	section	hunk01,DATA
;   {
DAT_00223a40:
; Unknown data at address 00223a40.
	dc.b $00
; Unknown data at address 00223a41.
	dc.b $00
s_ABCDEFabcdef9876543210_00223a42:
	dc.b "ABCDEFabcdef9876543210",0
DAT_00223a59:
; Unknown data at address 00223a59.
	dc.b $0a
; Unknown data at address 00223a5a.
	dc.b $0b
; Unknown data at address 00223a5b.
	dc.b $0c
; Unknown data at address 00223a5c.
	dc.b $0d
; Unknown data at address 00223a5d.
	dc.b $0e
; Unknown data at address 00223a5e.
	dc.b $0f
; Unknown data at address 00223a5f.
	dc.b $0a
; Unknown data at address 00223a60.
	dc.b $0b
; Unknown data at address 00223a61.
	dc.b $0c
; Unknown data at address 00223a62.
	dc.b $0d
; Unknown data at address 00223a63.
	dc.b $0e
; Unknown data at address 00223a64.
	dc.b $0f
; Unknown data at address 00223a65.
	dc.b $09
; Unknown data at address 00223a66.
	dc.b $08
; Unknown data at address 00223a67.
	dc.b $07
; Unknown data at address 00223a68.
	dc.b $06
; Unknown data at address 00223a69.
	dc.b $05
; Unknown data at address 00223a6a.
	dc.b $04
; Unknown data at address 00223a6b.
	dc.b $03
; Unknown data at address 00223a6c.
	dc.b $02
; Unknown data at address 00223a6d.
	dc.b $01
; Unknown data at address 00223a6e.
	dc.b $00
; Unknown data at address 00223a6f.
	dc.b $00
s_0123456789abcdef_00223a70:
	dc.b "0123456789abcdef",0
; Unknown data at address 00223a81.
	dc.b $00
; Unknown data at address 00223a82.
	dc.b $00
DAT_00223a83:
; Unknown data at address 00223a83.
	dc.b $20
; Unknown data at address 00223a84.
	dc.b $20
; Unknown data at address 00223a85.
	dc.b $20
; Unknown data at address 00223a86.
	dc.b $20
; Unknown data at address 00223a87.
	dc.b $20
; Unknown data at address 00223a88.
	dc.b $20
; Unknown data at address 00223a89.
	dc.b $20
; Unknown data at address 00223a8a.
	dc.b $20
; Unknown data at address 00223a8b.
	dc.b $20
; Unknown data at address 00223a8c.
	dc.b $30
; Unknown data at address 00223a8d.
	dc.b $30
; Unknown data at address 00223a8e.
	dc.b $30
; Unknown data at address 00223a8f.
	dc.b $30
; Unknown data at address 00223a90.
	dc.b $30
; Unknown data at address 00223a91.
	dc.b $20
; Unknown data at address 00223a92.
	dc.b $20
; Unknown data at address 00223a93.
	dc.b $20
; Unknown data at address 00223a94.
	dc.b $20
; Unknown data at address 00223a95.
	dc.b $20
; Unknown data at address 00223a96.
	dc.b $20
; Unknown data at address 00223a97.
	dc.b $20
; Unknown data at address 00223a98.
	dc.b $20
; Unknown data at address 00223a99.
	dc.b $20
; Unknown data at address 00223a9a.
	dc.b $20
; Unknown data at address 00223a9b.
	dc.b $20
; Unknown data at address 00223a9c.
	dc.b $20
; Unknown data at address 00223a9d.
	dc.b $20
; Unknown data at address 00223a9e.
	dc.b $20
; Unknown data at address 00223a9f.
	dc.b $20
; Unknown data at address 00223aa0.
	dc.b $20
; Unknown data at address 00223aa1.
	dc.b $20
; Unknown data at address 00223aa2.
	dc.b $20
; Unknown data at address 00223aa3.
	dc.b $90
; Unknown data at address 00223aa4.
	dc.b $40
; Unknown data at address 00223aa5.
	dc.b $40
; Unknown data at address 00223aa6.
	dc.b $40
; Unknown data at address 00223aa7.
	dc.b $40
; Unknown data at address 00223aa8.
	dc.b $40
; Unknown data at address 00223aa9.
	dc.b $40
; Unknown data at address 00223aaa.
	dc.b $40
; Unknown data at address 00223aab.
	dc.b $40
; Unknown data at address 00223aac.
	dc.b $40
; Unknown data at address 00223aad.
	dc.b $40
; Unknown data at address 00223aae.
	dc.b $40
; Unknown data at address 00223aaf.
	dc.b $40
; Unknown data at address 00223ab0.
	dc.b $40
; Unknown data at address 00223ab1.
	dc.b $40
; Unknown data at address 00223ab2.
	dc.b $40
; Unknown data at address 00223ab3.
	dc.b $0c
; Unknown data at address 00223ab4.
	dc.b $0c
; Unknown data at address 00223ab5.
	dc.b $0c
; Unknown data at address 00223ab6.
	dc.b $0c
; Unknown data at address 00223ab7.
	dc.b $0c
; Unknown data at address 00223ab8.
	dc.b $0c
; Unknown data at address 00223ab9.
	dc.b $0c
; Unknown data at address 00223aba.
	dc.b $0c
; Unknown data at address 00223abb.
	dc.b $0c
; Unknown data at address 00223abc.
	dc.b $0c
; Unknown data at address 00223abd.
	dc.b $40
; Unknown data at address 00223abe.
	dc.b $40
; Unknown data at address 00223abf.
	dc.b $40
; Unknown data at address 00223ac0.
	dc.b $40
; Unknown data at address 00223ac1.
	dc.b $40
; Unknown data at address 00223ac2.
	dc.b $40
; Unknown data at address 00223ac3.
	dc.b $40
; Unknown data at address 00223ac4.
	dc.b $09
; Unknown data at address 00223ac5.
	dc.b $09
; Unknown data at address 00223ac6.
	dc.b $09
; Unknown data at address 00223ac7.
	dc.b $09
; Unknown data at address 00223ac8.
	dc.b $09
; Unknown data at address 00223ac9.
	dc.b $09
; Unknown data at address 00223aca.
	dc.b $01
; Unknown data at address 00223acb.
	dc.b $01
; Unknown data at address 00223acc.
	dc.b $01
; Unknown data at address 00223acd.
	dc.b $01
; Unknown data at address 00223ace.
	dc.b $01
; Unknown data at address 00223acf.
	dc.b $01
; Unknown data at address 00223ad0.
	dc.b $01
; Unknown data at address 00223ad1.
	dc.b $01
; Unknown data at address 00223ad2.
	dc.b $01
; Unknown data at address 00223ad3.
	dc.b $01
; Unknown data at address 00223ad4.
	dc.b $01
; Unknown data at address 00223ad5.
	dc.b $01
; Unknown data at address 00223ad6.
	dc.b $01
; Unknown data at address 00223ad7.
	dc.b $01
; Unknown data at address 00223ad8.
	dc.b $01
; Unknown data at address 00223ad9.
	dc.b $01
; Unknown data at address 00223ada.
	dc.b $01
; Unknown data at address 00223adb.
	dc.b $01
; Unknown data at address 00223adc.
	dc.b $01
; Unknown data at address 00223add.
	dc.b $01
; Unknown data at address 00223ade.
	dc.b $40
; Unknown data at address 00223adf.
	dc.b $40
; Unknown data at address 00223ae0.
	dc.b $40
; Unknown data at address 00223ae1.
	dc.b $40
; Unknown data at address 00223ae2.
	dc.b $40
; Unknown data at address 00223ae3.
	dc.b $40
; Unknown data at address 00223ae4.
	dc.b $0a
; Unknown data at address 00223ae5.
	dc.b $0a
; Unknown data at address 00223ae6.
	dc.b $0a
; Unknown data at address 00223ae7.
	dc.b $0a
; Unknown data at address 00223ae8.
	dc.b $0a
; Unknown data at address 00223ae9.
	dc.b $0a
; Unknown data at address 00223aea.
	dc.b $02
; Unknown data at address 00223aeb.
	dc.b $02
; Unknown data at address 00223aec.
	dc.b $02
; Unknown data at address 00223aed.
	dc.b $02
; Unknown data at address 00223aee.
	dc.b $02
; Unknown data at address 00223aef.
	dc.b $02
; Unknown data at address 00223af0.
	dc.b $02
; Unknown data at address 00223af1.
	dc.b $02
; Unknown data at address 00223af2.
	dc.b $02
; Unknown data at address 00223af3.
	dc.b $02
; Unknown data at address 00223af4.
	dc.b $02
; Unknown data at address 00223af5.
	dc.b $02
; Unknown data at address 00223af6.
	dc.b $02
; Unknown data at address 00223af7.
	dc.b $02
; Unknown data at address 00223af8.
	dc.b $02
; Unknown data at address 00223af9.
	dc.b $02
; Unknown data at address 00223afa.
	dc.b $02
; Unknown data at address 00223afb.
	dc.b $02
; Unknown data at address 00223afc.
	dc.b $02
; Unknown data at address 00223afd.
	dc.b $02
; Unknown data at address 00223afe.
	dc.b $40
; Unknown data at address 00223aff.
	dc.b $40
; Unknown data at address 00223b00.
	dc.b $40
; Unknown data at address 00223b01.
	dc.b $40
; Unknown data at address 00223b02.
	dc.b $20
; Unknown data at address 00223b03.
	dc.b $00
DAT_00223b04:
; Unknown data at address 00223b04.
	dc.b $00
; Unknown data at address 00223b05.
	dc.b $00
; Unknown data at address 00223b06.
	dc.b $00
; Unknown data at address 00223b07.
	dc.b $00
; Unknown data at address 00223b08.
	dc.b $00
; Unknown data at address 00223b09.
	dc.b $00
; Unknown data at address 00223b0a.
	dc.b $00
; Unknown data at address 00223b0b.
	dc.b $00
; Unknown data at address 00223b0c.
	dc.b $00
; Unknown data at address 00223b0d.
	dc.b $00
; Unknown data at address 00223b0e.
	dc.b $00
; Unknown data at address 00223b0f.
	dc.b $00
DAT_00223b10:
	; undefined1
	dc.b $01
; Unknown data at address 00223b11.
	dc.b $00
; Unknown data at address 00223b12.
	dc.b $00
; Unknown data at address 00223b13.
	dc.b $00
; Unknown data at address 00223b14.
	dc.b $00
; Unknown data at address 00223b15.
	dc.b $01
; Unknown data at address 00223b16.
	dc.b $00
; Unknown data at address 00223b17.
	dc.b $00
; Unknown data at address 00223b18.
	dc.b $00
; Unknown data at address 00223b19.
	dc.b $00
DAT_00223b1a:
; Unknown data at address 00223b1a.
	dc.b $00
; Unknown data at address 00223b1b.
	dc.b $00
; Unknown data at address 00223b1c.
	dc.b $00
; Unknown data at address 00223b1d.
	dc.b $00
; Unknown data at address 00223b1e.
	dc.b $00
; Unknown data at address 00223b1f.
	dc.b $00
; Unknown data at address 00223b20.
	dc.b $00
; Unknown data at address 00223b21.
	dc.b $00
; Unknown data at address 00223b22.
	dc.b $00
; Unknown data at address 00223b23.
	dc.b $00
; Unknown data at address 00223b24.
	dc.b $00
; Unknown data at address 00223b25.
	dc.b $00
DAT_00223b26:
	; undefined1
	dc.b $01
; Unknown data at address 00223b27.
	dc.b $01
; Unknown data at address 00223b28.
	dc.b $00
; Unknown data at address 00223b29.
	dc.b $00
; Unknown data at address 00223b2a.
	dc.b $00
; Unknown data at address 00223b2b.
	dc.b $01
; Unknown data at address 00223b2c.
	dc.b $00
; Unknown data at address 00223b2d.
	dc.b $00
; Unknown data at address 00223b2e.
	dc.b $00
; Unknown data at address 00223b2f.
	dc.b $00
; Unknown data at address 00223b30.
	dc.b $00
; Unknown data at address 00223b31.
	dc.b $00
; Unknown data at address 00223b32.
	dc.b $00
; Unknown data at address 00223b33.
	dc.b $00
; Unknown data at address 00223b34.
	dc.b $00
; Unknown data at address 00223b35.
	dc.b $00
; Unknown data at address 00223b36.
	dc.b $00
; Unknown data at address 00223b37.
	dc.b $00
; Unknown data at address 00223b38.
	dc.b $00
; Unknown data at address 00223b39.
	dc.b $00
; Unknown data at address 00223b3a.
	dc.b $00
; Unknown data at address 00223b3b.
	dc.b $00
; Unknown data at address 00223b3c.
	dc.b $01
; Unknown data at address 00223b3d.
	dc.b $02
; Unknown data at address 00223b3e.
	dc.b $00
; Unknown data at address 00223b3f.
	dc.b $00
; Unknown data at address 00223b40.
	dc.b $00
; Unknown data at address 00223b41.
	dc.b $01
; Unknown data at address 00223b42.
	dc.b $00
; Unknown data at address 00223b43.
	dc.b $00
; Unknown data at address 00223b44.
	dc.b $00
; Unknown data at address 00223b45.
	dc.b $00
; Unknown data at address 00223b46.
	dc.b $00
; Unknown data at address 00223b47.
	dc.b $00
; Unknown data at address 00223b48.
	dc.b $00
; Unknown data at address 00223b49.
	dc.b $00
; Unknown data at address 00223b4a.
	dc.b $00
; Unknown data at address 00223b4b.
	dc.b $00
; Unknown data at address 00223b4c.
	dc.b $00
; Unknown data at address 00223b4d.
	dc.b $00
; Unknown data at address 00223b4e.
	dc.b $00
; Unknown data at address 00223b4f.
	dc.b $00
; Unknown data at address 00223b50.
	dc.b $00
; Unknown data at address 00223b51.
	dc.b $00
; Unknown data at address 00223b52.
	dc.b $00
; Unknown data at address 00223b53.
	dc.b $00
; Unknown data at address 00223b54.
	dc.b $00
; Unknown data at address 00223b55.
	dc.b $00
; Unknown data at address 00223b56.
	dc.b $00
; Unknown data at address 00223b57.
	dc.b $00
; Unknown data at address 00223b58.
	dc.b $00
; Unknown data at address 00223b59.
	dc.b $00
; Unknown data at address 00223b5a.
	dc.b $00
; Unknown data at address 00223b5b.
	dc.b $00
; Unknown data at address 00223b5c.
	dc.b $00
; Unknown data at address 00223b5d.
	dc.b $00
; Unknown data at address 00223b5e.
	dc.b $00
; Unknown data at address 00223b5f.
	dc.b $00
; Unknown data at address 00223b60.
	dc.b $00
; Unknown data at address 00223b61.
	dc.b $00
; Unknown data at address 00223b62.
	dc.b $00
; Unknown data at address 00223b63.
	dc.b $00
; Unknown data at address 00223b64.
	dc.b $00
; Unknown data at address 00223b65.
	dc.b $00
; Unknown data at address 00223b66.
	dc.b $00
; Unknown data at address 00223b67.
	dc.b $00
; Unknown data at address 00223b68.
	dc.b $00
; Unknown data at address 00223b69.
	dc.b $00
; Unknown data at address 00223b6a.
	dc.b $00
; Unknown data at address 00223b6b.
	dc.b $00
; Unknown data at address 00223b6c.
	dc.b $00
; Unknown data at address 00223b6d.
	dc.b $00
; Unknown data at address 00223b6e.
	dc.b $00
; Unknown data at address 00223b6f.
	dc.b $00
; Unknown data at address 00223b70.
	dc.b $00
; Unknown data at address 00223b71.
	dc.b $00
; Unknown data at address 00223b72.
	dc.b $00
; Unknown data at address 00223b73.
	dc.b $00
; Unknown data at address 00223b74.
	dc.b $00
; Unknown data at address 00223b75.
	dc.b $00
; Unknown data at address 00223b76.
	dc.b $00
; Unknown data at address 00223b77.
	dc.b $00
; Unknown data at address 00223b78.
	dc.b $00
; Unknown data at address 00223b79.
	dc.b $00
; Unknown data at address 00223b7a.
	dc.b $00
; Unknown data at address 00223b7b.
	dc.b $00
; Unknown data at address 00223b7c.
	dc.b $00
; Unknown data at address 00223b7d.
	dc.b $00
; Unknown data at address 00223b7e.
	dc.b $00
; Unknown data at address 00223b7f.
	dc.b $00
; Unknown data at address 00223b80.
	dc.b $00
; Unknown data at address 00223b81.
	dc.b $00
; Unknown data at address 00223b82.
	dc.b $00
; Unknown data at address 00223b83.
	dc.b $00
; Unknown data at address 00223b84.
	dc.b $00
; Unknown data at address 00223b85.
	dc.b $00
; Unknown data at address 00223b86.
	dc.b $00
; Unknown data at address 00223b87.
	dc.b $00
; Unknown data at address 00223b88.
	dc.b $00
; Unknown data at address 00223b89.
	dc.b $00
; Unknown data at address 00223b8a.
	dc.b $00
; Unknown data at address 00223b8b.
	dc.b $00
; Unknown data at address 00223b8c.
	dc.b $00
; Unknown data at address 00223b8d.
	dc.b $00
; Unknown data at address 00223b8e.
	dc.b $00
; Unknown data at address 00223b8f.
	dc.b $00
; Unknown data at address 00223b90.
	dc.b $00
; Unknown data at address 00223b91.
	dc.b $00
; Unknown data at address 00223b92.
	dc.b $00
; Unknown data at address 00223b93.
	dc.b $00
; Unknown data at address 00223b94.
	dc.b $00
; Unknown data at address 00223b95.
	dc.b $00
; Unknown data at address 00223b96.
	dc.b $00
; Unknown data at address 00223b97.
	dc.b $00
; Unknown data at address 00223b98.
	dc.b $00
; Unknown data at address 00223b99.
	dc.b $00
; Unknown data at address 00223b9a.
	dc.b $00
; Unknown data at address 00223b9b.
	dc.b $00
; Unknown data at address 00223b9c.
	dc.b $00
; Unknown data at address 00223b9d.
	dc.b $00
; Unknown data at address 00223b9e.
	dc.b $00
; Unknown data at address 00223b9f.
	dc.b $00
; Unknown data at address 00223ba0.
	dc.b $00
; Unknown data at address 00223ba1.
	dc.b $00
; Unknown data at address 00223ba2.
	dc.b $00
; Unknown data at address 00223ba3.
	dc.b $00
; Unknown data at address 00223ba4.
	dc.b $00
; Unknown data at address 00223ba5.
	dc.b $00
; Unknown data at address 00223ba6.
	dc.b $00
; Unknown data at address 00223ba7.
	dc.b $00
; Unknown data at address 00223ba8.
	dc.b $00
; Unknown data at address 00223ba9.
	dc.b $00
; Unknown data at address 00223baa.
	dc.b $00
; Unknown data at address 00223bab.
	dc.b $00
; Unknown data at address 00223bac.
	dc.b $00
; Unknown data at address 00223bad.
	dc.b $00
; Unknown data at address 00223bae.
	dc.b $00
; Unknown data at address 00223baf.
	dc.b $00
; Unknown data at address 00223bb0.
	dc.b $00
; Unknown data at address 00223bb1.
	dc.b $00
; Unknown data at address 00223bb2.
	dc.b $00
; Unknown data at address 00223bb3.
	dc.b $00
; Unknown data at address 00223bb4.
	dc.b $00
; Unknown data at address 00223bb5.
	dc.b $00
; Unknown data at address 00223bb6.
	dc.b $00
; Unknown data at address 00223bb7.
	dc.b $00
; Unknown data at address 00223bb8.
	dc.b $00
; Unknown data at address 00223bb9.
	dc.b $00
; Unknown data at address 00223bba.
	dc.b $00
; Unknown data at address 00223bbb.
	dc.b $00
; Unknown data at address 00223bbc.
	dc.b $00
; Unknown data at address 00223bbd.
	dc.b $00
; Unknown data at address 00223bbe.
	dc.b $00
; Unknown data at address 00223bbf.
	dc.b $00
; Unknown data at address 00223bc0.
	dc.b $00
; Unknown data at address 00223bc1.
	dc.b $00
; Unknown data at address 00223bc2.
	dc.b $00
; Unknown data at address 00223bc3.
	dc.b $00
; Unknown data at address 00223bc4.
	dc.b $00
; Unknown data at address 00223bc5.
	dc.b $00
; Unknown data at address 00223bc6.
	dc.b $00
; Unknown data at address 00223bc7.
	dc.b $00
; Unknown data at address 00223bc8.
	dc.b $00
; Unknown data at address 00223bc9.
	dc.b $00
; Unknown data at address 00223bca.
	dc.b $00
; Unknown data at address 00223bcb.
	dc.b $00
; Unknown data at address 00223bcc.
	dc.b $00
; Unknown data at address 00223bcd.
	dc.b $00
; Unknown data at address 00223bce.
	dc.b $00
; Unknown data at address 00223bcf.
	dc.b $00
; Unknown data at address 00223bd0.
	dc.b $00
; Unknown data at address 00223bd1.
	dc.b $00
; Unknown data at address 00223bd2.
	dc.b $00
; Unknown data at address 00223bd3.
	dc.b $00
; Unknown data at address 00223bd4.
	dc.b $00
; Unknown data at address 00223bd5.
	dc.b $00
; Unknown data at address 00223bd6.
	dc.b $00
; Unknown data at address 00223bd7.
	dc.b $00
; Unknown data at address 00223bd8.
	dc.b $00
; Unknown data at address 00223bd9.
	dc.b $00
; Unknown data at address 00223bda.
	dc.b $00
; Unknown data at address 00223bdb.
	dc.b $00
; Unknown data at address 00223bdc.
	dc.b $00
; Unknown data at address 00223bdd.
	dc.b $00
; Unknown data at address 00223bde.
	dc.b $00
; Unknown data at address 00223bdf.
	dc.b $00
; Unknown data at address 00223be0.
	dc.b $00
; Unknown data at address 00223be1.
	dc.b $00
; Unknown data at address 00223be2.
	dc.b $00
; Unknown data at address 00223be3.
	dc.b $00
; Unknown data at address 00223be4.
	dc.b $00
; Unknown data at address 00223be5.
	dc.b $00
; Unknown data at address 00223be6.
	dc.b $00
; Unknown data at address 00223be7.
	dc.b $00
; Unknown data at address 00223be8.
	dc.b $00
; Unknown data at address 00223be9.
	dc.b $00
; Unknown data at address 00223bea.
	dc.b $00
; Unknown data at address 00223beb.
	dc.b $00
; Unknown data at address 00223bec.
	dc.b $00
; Unknown data at address 00223bed.
	dc.b $00
; Unknown data at address 00223bee.
	dc.b $00
; Unknown data at address 00223bef.
	dc.b $00
; Unknown data at address 00223bf0.
	dc.b $00
; Unknown data at address 00223bf1.
	dc.b $00
; Unknown data at address 00223bf2.
	dc.b $00
; Unknown data at address 00223bf3.
	dc.b $00
; Unknown data at address 00223bf4.
	dc.b $00
; Unknown data at address 00223bf5.
	dc.b $00
; Unknown data at address 00223bf6.
	dc.b $00
; Unknown data at address 00223bf7.
	dc.b $00
; Unknown data at address 00223bf8.
	dc.b $00
; Unknown data at address 00223bf9.
	dc.b $00
; Unknown data at address 00223bfa.
	dc.b $00
; Unknown data at address 00223bfb.
	dc.b $00
; Unknown data at address 00223bfc.
	dc.b $00
; Unknown data at address 00223bfd.
	dc.b $00
; Unknown data at address 00223bfe.
	dc.b $00
; Unknown data at address 00223bff.
	dc.b $00
; Unknown data at address 00223c00.
	dc.b $00
; Unknown data at address 00223c01.
	dc.b $00
; Unknown data at address 00223c02.
	dc.b $00
; Unknown data at address 00223c03.
	dc.b $00
; Unknown data at address 00223c04.
	dc.b $00
; Unknown data at address 00223c05.
	dc.b $00
; Unknown data at address 00223c06.
	dc.b $00
; Unknown data at address 00223c07.
	dc.b $00
; Unknown data at address 00223c08.
	dc.b $00
; Unknown data at address 00223c09.
	dc.b $00
; Unknown data at address 00223c0a.
	dc.b $00
; Unknown data at address 00223c0b.
	dc.b $00
; Unknown data at address 00223c0c.
	dc.b $00
; Unknown data at address 00223c0d.
	dc.b $00
; Unknown data at address 00223c0e.
	dc.b $00
; Unknown data at address 00223c0f.
	dc.b $00
; Unknown data at address 00223c10.
	dc.b $00
; Unknown data at address 00223c11.
	dc.b $00
; Unknown data at address 00223c12.
	dc.b $00
; Unknown data at address 00223c13.
	dc.b $00
; Unknown data at address 00223c14.
	dc.b $00
; Unknown data at address 00223c15.
	dc.b $00
; Unknown data at address 00223c16.
	dc.b $00
; Unknown data at address 00223c17.
	dc.b $00
; Unknown data at address 00223c18.
	dc.b $00
; Unknown data at address 00223c19.
	dc.b $00
; Unknown data at address 00223c1a.
	dc.b $00
; Unknown data at address 00223c1b.
	dc.b $00
; Unknown data at address 00223c1c.
	dc.b $00
; Unknown data at address 00223c1d.
	dc.b $00
; Unknown data at address 00223c1e.
	dc.b $00
; Unknown data at address 00223c1f.
	dc.b $00
; Unknown data at address 00223c20.
	dc.b $00
; Unknown data at address 00223c21.
	dc.b $00
; Unknown data at address 00223c22.
	dc.b $00
; Unknown data at address 00223c23.
	dc.b $00
; Unknown data at address 00223c24.
	dc.b $00
; Unknown data at address 00223c25.
	dc.b $00
; Unknown data at address 00223c26.
	dc.b $00
; Unknown data at address 00223c27.
	dc.b $00
; Unknown data at address 00223c28.
	dc.b $00
; Unknown data at address 00223c29.
	dc.b $00
; Unknown data at address 00223c2a.
	dc.b $00
; Unknown data at address 00223c2b.
	dc.b $00
; Unknown data at address 00223c2c.
	dc.b $00
; Unknown data at address 00223c2d.
	dc.b $00
; Unknown data at address 00223c2e.
	dc.b $00
; Unknown data at address 00223c2f.
	dc.b $00
; Unknown data at address 00223c30.
	dc.b $00
; Unknown data at address 00223c31.
	dc.b $00
; Unknown data at address 00223c32.
	dc.b $00
; Unknown data at address 00223c33.
	dc.b $00
; Unknown data at address 00223c34.
	dc.b $00
; Unknown data at address 00223c35.
	dc.b $00
; Unknown data at address 00223c36.
	dc.b $00
; Unknown data at address 00223c37.
	dc.b $00
; Unknown data at address 00223c38.
	dc.b $00
; Unknown data at address 00223c39.
	dc.b $00
; Unknown data at address 00223c3a.
	dc.b $00
; Unknown data at address 00223c3b.
	dc.b $00
; Unknown data at address 00223c3c.
	dc.b $00
; Unknown data at address 00223c3d.
	dc.b $00
; Unknown data at address 00223c3e.
	dc.b $00
; Unknown data at address 00223c3f.
	dc.b $00
; Unknown data at address 00223c40.
	dc.b $00
; Unknown data at address 00223c41.
	dc.b $00
; Unknown data at address 00223c42.
	dc.b $00
; Unknown data at address 00223c43.
	dc.b $00
; Unknown data at address 00223c44.
	dc.b $00
; Unknown data at address 00223c45.
	dc.b $00
; Unknown data at address 00223c46.
	dc.b $00
; Unknown data at address 00223c47.
	dc.b $00
; Unknown data at address 00223c48.
	dc.b $00
; Unknown data at address 00223c49.
	dc.b $00
; Unknown data at address 00223c4a.
	dc.b $00
; Unknown data at address 00223c4b.
	dc.b $00
; Unknown data at address 00223c4c.
	dc.b $00
; Unknown data at address 00223c4d.
	dc.b $00
; Unknown data at address 00223c4e.
	dc.b $00
; Unknown data at address 00223c4f.
	dc.b $00
; Unknown data at address 00223c50.
	dc.b $00
; Unknown data at address 00223c51.
	dc.b $00
; Unknown data at address 00223c52.
	dc.b $00
; Unknown data at address 00223c53.
	dc.b $00
; Unknown data at address 00223c54.
	dc.b $00
; Unknown data at address 00223c55.
	dc.b $00
; Unknown data at address 00223c56.
	dc.b $00
; Unknown data at address 00223c57.
	dc.b $00
; Unknown data at address 00223c58.
	dc.b $00
; Unknown data at address 00223c59.
	dc.b $00
; Unknown data at address 00223c5a.
	dc.b $00
; Unknown data at address 00223c5b.
	dc.b $00
; Unknown data at address 00223c5c.
	dc.b $00
; Unknown data at address 00223c5d.
	dc.b $00
; Unknown data at address 00223c5e.
	dc.b $00
; Unknown data at address 00223c5f.
	dc.b $00
; Unknown data at address 00223c60.
	dc.b $00
; Unknown data at address 00223c61.
	dc.b $00
; Unknown data at address 00223c62.
	dc.b $00
; Unknown data at address 00223c63.
	dc.b $00
; Unknown data at address 00223c64.
	dc.b $00
; Unknown data at address 00223c65.
	dc.b $00
; Unknown data at address 00223c66.
	dc.b $00
; Unknown data at address 00223c67.
	dc.b $00
; Unknown data at address 00223c68.
	dc.b $00
; Unknown data at address 00223c69.
	dc.b $00
; Unknown data at address 00223c6a.
	dc.b $00
; Unknown data at address 00223c6b.
	dc.b $00
; Unknown data at address 00223c6c.
	dc.b $00
; Unknown data at address 00223c6d.
	dc.b $00
; Unknown data at address 00223c6e.
	dc.b $00
; Unknown data at address 00223c6f.
	dc.b $00
; Unknown data at address 00223c70.
	dc.b $00
; Unknown data at address 00223c71.
	dc.b $00
; Unknown data at address 00223c72.
	dc.b $00
; Unknown data at address 00223c73.
	dc.b $00
; Unknown data at address 00223c74.
	dc.b $00
; Unknown data at address 00223c75.
	dc.b $00
; Unknown data at address 00223c76.
	dc.b $00
; Unknown data at address 00223c77.
	dc.b $00
; Unknown data at address 00223c78.
	dc.b $00
; Unknown data at address 00223c79.
	dc.b $00
; Unknown data at address 00223c7a.
	dc.b $00
; Unknown data at address 00223c7b.
	dc.b $00
; Unknown data at address 00223c7c.
	dc.b $00
; Unknown data at address 00223c7d.
	dc.b $00
; Unknown data at address 00223c7e.
	dc.b $00
; Unknown data at address 00223c7f.
	dc.b $00
; Unknown data at address 00223c80.
	dc.b $00
; Unknown data at address 00223c81.
	dc.b $00
; Unknown data at address 00223c82.
	dc.b $00
; Unknown data at address 00223c83.
	dc.b $00
; Unknown data at address 00223c84.
	dc.b $00
; Unknown data at address 00223c85.
	dc.b $00
; Unknown data at address 00223c86.
	dc.b $00
; Unknown data at address 00223c87.
	dc.b $00
; Unknown data at address 00223c88.
	dc.b $00
; Unknown data at address 00223c89.
	dc.b $00
; Unknown data at address 00223c8a.
	dc.b $00
; Unknown data at address 00223c8b.
	dc.b $00
; Unknown data at address 00223c8c.
	dc.b $00
; Unknown data at address 00223c8d.
	dc.b $00
; Unknown data at address 00223c8e.
	dc.b $00
; Unknown data at address 00223c8f.
	dc.b $00
; Unknown data at address 00223c90.
	dc.b $00
; Unknown data at address 00223c91.
	dc.b $00
; Unknown data at address 00223c92.
	dc.b $00
; Unknown data at address 00223c93.
	dc.b $00
; Unknown data at address 00223c94.
	dc.b $00
; Unknown data at address 00223c95.
	dc.b $00
; Unknown data at address 00223c96.
	dc.b $00
; Unknown data at address 00223c97.
	dc.b $00
; Unknown data at address 00223c98.
	dc.b $00
; Unknown data at address 00223c99.
	dc.b $00
; Unknown data at address 00223c9a.
	dc.b $00
; Unknown data at address 00223c9b.
	dc.b $00
; Unknown data at address 00223c9c.
	dc.b $00
; Unknown data at address 00223c9d.
	dc.b $00
; Unknown data at address 00223c9e.
	dc.b $00
; Unknown data at address 00223c9f.
	dc.b $00
; Unknown data at address 00223ca0.
	dc.b $00
; Unknown data at address 00223ca1.
	dc.b $00
; Unknown data at address 00223ca2.
	dc.b $00
; Unknown data at address 00223ca3.
	dc.b $00
; Unknown data at address 00223ca4.
	dc.b $00
; Unknown data at address 00223ca5.
	dc.b $00
; Unknown data at address 00223ca6.
	dc.b $00
; Unknown data at address 00223ca7.
	dc.b $00
; Unknown data at address 00223ca8.
	dc.b $00
; Unknown data at address 00223ca9.
	dc.b $00
; Unknown data at address 00223caa.
	dc.b $00
; Unknown data at address 00223cab.
	dc.b $00
; Unknown data at address 00223cac.
	dc.b $00
; Unknown data at address 00223cad.
	dc.b $00
; Unknown data at address 00223cae.
	dc.b $00
; Unknown data at address 00223caf.
	dc.b $00
; Unknown data at address 00223cb0.
	dc.b $00
; Unknown data at address 00223cb1.
	dc.b $00
; Unknown data at address 00223cb2.
	dc.b $00
; Unknown data at address 00223cb3.
	dc.b $00
; Unknown data at address 00223cb4.
	dc.b $00
; Unknown data at address 00223cb5.
	dc.b $00
; Unknown data at address 00223cb6.
	dc.b $00
; Unknown data at address 00223cb7.
	dc.b $00
; Unknown data at address 00223cb8.
	dc.b $00
; Unknown data at address 00223cb9.
	dc.b $00
; Unknown data at address 00223cba.
	dc.b $00
; Unknown data at address 00223cbb.
	dc.b $00
DAT_00223cbc:
	; undefined2
	dc.w $0014
DAT_00223cbe:
	; undefined4
	dc.l $00000000
DAT_00223cc2:
	; undefined4
	dc.l $00000000
; Unknown data at address 00223cc6.
	dc.b $00
; Unknown data at address 00223cc7.
	dc.b $00
;   }

; #######################
; # HUNK02 - BSS        #
; #######################
	section	hunk02,BSS
;   {
DAT_00223cc8:
	; undefined4
	dx.l 1
DAT_00223ccc:
	; undefined4
	dx.l 1
DAT_00223cd0:
	; undefined4
	dx.l 1
DAT_00223cd4:
	; undefined4
	dx.l 1
DAT_00223cd8:
	; undefined4
	dx.l 1
DAT_00223cdc:
	; undefined4
	dx.l 1
DAT_00223ce0:
; Unknown data at address 00223ce0.
	dx.b 1
; Unknown data at address 00223ce1.
	dx.b 1
; Unknown data at address 00223ce2.
	dx.b 1
; Unknown data at address 00223ce3.
	dx.b 1
; Unknown data at address 00223ce4.
	dx.b 1
; Unknown data at address 00223ce5.
	dx.b 1
; Unknown data at address 00223ce6.
	dx.b 1
; Unknown data at address 00223ce7.
	dx.b 1
; Unknown data at address 00223ce8.
	dx.b 1
; Unknown data at address 00223ce9.
	dx.b 1
; Unknown data at address 00223cea.
	dx.b 1
; Unknown data at address 00223ceb.
	dx.b 1
; Unknown data at address 00223cec.
	dx.b 1
; Unknown data at address 00223ced.
	dx.b 1
; Unknown data at address 00223cee.
	dx.b 1
; Unknown data at address 00223cef.
	dx.b 1
; Unknown data at address 00223cf0.
	dx.b 1
; Unknown data at address 00223cf1.
	dx.b 1
; Unknown data at address 00223cf2.
	dx.b 1
; Unknown data at address 00223cf3.
	dx.b 1
; Unknown data at address 00223cf4.
	dx.b 1
; Unknown data at address 00223cf5.
	dx.b 1
; Unknown data at address 00223cf6.
	dx.b 1
; Unknown data at address 00223cf7.
	dx.b 1
; Unknown data at address 00223cf8.
	dx.b 1
; Unknown data at address 00223cf9.
	dx.b 1
; Unknown data at address 00223cfa.
	dx.b 1
; Unknown data at address 00223cfb.
	dx.b 1
; Unknown data at address 00223cfc.
	dx.b 1
; Unknown data at address 00223cfd.
	dx.b 1
; Unknown data at address 00223cfe.
	dx.b 1
; Unknown data at address 00223cff.
	dx.b 1
; Unknown data at address 00223d00.
	dx.b 1
; Unknown data at address 00223d01.
	dx.b 1
; Unknown data at address 00223d02.
	dx.b 1
; Unknown data at address 00223d03.
	dx.b 1
; Unknown data at address 00223d04.
	dx.b 1
; Unknown data at address 00223d05.
	dx.b 1
; Unknown data at address 00223d06.
	dx.b 1
; Unknown data at address 00223d07.
	dx.b 1
; Unknown data at address 00223d08.
	dx.b 1
; Unknown data at address 00223d09.
	dx.b 1
; Unknown data at address 00223d0a.
	dx.b 1
; Unknown data at address 00223d0b.
	dx.b 1
; Unknown data at address 00223d0c.
	dx.b 1
; Unknown data at address 00223d0d.
	dx.b 1
; Unknown data at address 00223d0e.
	dx.b 1
; Unknown data at address 00223d0f.
	dx.b 1
; Unknown data at address 00223d10.
	dx.b 1
; Unknown data at address 00223d11.
	dx.b 1
; Unknown data at address 00223d12.
	dx.b 1
; Unknown data at address 00223d13.
	dx.b 1
; Unknown data at address 00223d14.
	dx.b 1
; Unknown data at address 00223d15.
	dx.b 1
; Unknown data at address 00223d16.
	dx.b 1
; Unknown data at address 00223d17.
	dx.b 1
; Unknown data at address 00223d18.
	dx.b 1
; Unknown data at address 00223d19.
	dx.b 1
; Unknown data at address 00223d1a.
	dx.b 1
; Unknown data at address 00223d1b.
	dx.b 1
; Unknown data at address 00223d1c.
	dx.b 1
; Unknown data at address 00223d1d.
	dx.b 1
; Unknown data at address 00223d1e.
	dx.b 1
; Unknown data at address 00223d1f.
	dx.b 1
; Unknown data at address 00223d20.
	dx.b 1
; Unknown data at address 00223d21.
	dx.b 1
; Unknown data at address 00223d22.
	dx.b 1
; Unknown data at address 00223d23.
	dx.b 1
; Unknown data at address 00223d24.
	dx.b 1
; Unknown data at address 00223d25.
	dx.b 1
; Unknown data at address 00223d26.
	dx.b 1
; Unknown data at address 00223d27.
	dx.b 1
; Unknown data at address 00223d28.
	dx.b 1
; Unknown data at address 00223d29.
	dx.b 1
; Unknown data at address 00223d2a.
	dx.b 1
; Unknown data at address 00223d2b.
	dx.b 1
; Unknown data at address 00223d2c.
	dx.b 1
; Unknown data at address 00223d2d.
	dx.b 1
; Unknown data at address 00223d2e.
	dx.b 1
; Unknown data at address 00223d2f.
	dx.b 1
; Unknown data at address 00223d30.
	dx.b 1
; Unknown data at address 00223d31.
	dx.b 1
; Unknown data at address 00223d32.
	dx.b 1
; Unknown data at address 00223d33.
	dx.b 1
; Unknown data at address 00223d34.
	dx.b 1
; Unknown data at address 00223d35.
	dx.b 1
; Unknown data at address 00223d36.
	dx.b 1
; Unknown data at address 00223d37.
	dx.b 1
; Unknown data at address 00223d38.
	dx.b 1
; Unknown data at address 00223d39.
	dx.b 1
; Unknown data at address 00223d3a.
	dx.b 1
; Unknown data at address 00223d3b.
	dx.b 1
; Unknown data at address 00223d3c.
	dx.b 1
; Unknown data at address 00223d3d.
	dx.b 1
; Unknown data at address 00223d3e.
	dx.b 1
; Unknown data at address 00223d3f.
	dx.b 1
; Unknown data at address 00223d40.
	dx.b 1
; Unknown data at address 00223d41.
	dx.b 1
; Unknown data at address 00223d42.
	dx.b 1
; Unknown data at address 00223d43.
	dx.b 1
DAT_00223d44:
	; undefined1
	dx.b 1
; Unknown data at address 00223d45.
	dx.b 1
DAT_00223d46:
; Unknown data at address 00223d46.
	dx.b 1
DAT_00223d47:
; Unknown data at address 00223d47.
	dx.b 1
; Unknown data at address 00223d48.
	dx.b 1
; Unknown data at address 00223d49.
	dx.b 1
; Unknown data at address 00223d4a.
	dx.b 1
; Unknown data at address 00223d4b.
	dx.b 1
; Unknown data at address 00223d4c.
	dx.b 1
; Unknown data at address 00223d4d.
	dx.b 1
; Unknown data at address 00223d4e.
	dx.b 1
; Unknown data at address 00223d4f.
	dx.b 1
; Unknown data at address 00223d50.
	dx.b 1
; Unknown data at address 00223d51.
	dx.b 1
; Unknown data at address 00223d52.
	dx.b 1
; Unknown data at address 00223d53.
	dx.b 1
; Unknown data at address 00223d54.
	dx.b 1
; Unknown data at address 00223d55.
	dx.b 1
; Unknown data at address 00223d56.
	dx.b 1
; Unknown data at address 00223d57.
	dx.b 1
; Unknown data at address 00223d58.
	dx.b 1
; Unknown data at address 00223d59.
	dx.b 1
; Unknown data at address 00223d5a.
	dx.b 1
; Unknown data at address 00223d5b.
	dx.b 1
; Unknown data at address 00223d5c.
	dx.b 1
; Unknown data at address 00223d5d.
	dx.b 1
; Unknown data at address 00223d5e.
	dx.b 1
; Unknown data at address 00223d5f.
	dx.b 1
; Unknown data at address 00223d60.
	dx.b 1
; Unknown data at address 00223d61.
	dx.b 1
; Unknown data at address 00223d62.
	dx.b 1
; Unknown data at address 00223d63.
	dx.b 1
; Unknown data at address 00223d64.
	dx.b 1
; Unknown data at address 00223d65.
	dx.b 1
; Unknown data at address 00223d66.
	dx.b 1
; Unknown data at address 00223d67.
	dx.b 1
; Unknown data at address 00223d68.
	dx.b 1
; Unknown data at address 00223d69.
	dx.b 1
; Unknown data at address 00223d6a.
	dx.b 1
; Unknown data at address 00223d6b.
	dx.b 1
; Unknown data at address 00223d6c.
	dx.b 1
; Unknown data at address 00223d6d.
	dx.b 1
; Unknown data at address 00223d6e.
	dx.b 1
; Unknown data at address 00223d6f.
	dx.b 1
; Unknown data at address 00223d70.
	dx.b 1
; Unknown data at address 00223d71.
	dx.b 1
; Unknown data at address 00223d72.
	dx.b 1
; Unknown data at address 00223d73.
	dx.b 1
; Unknown data at address 00223d74.
	dx.b 1
; Unknown data at address 00223d75.
	dx.b 1
; Unknown data at address 00223d76.
	dx.b 1
; Unknown data at address 00223d77.
	dx.b 1
; Unknown data at address 00223d78.
	dx.b 1
; Unknown data at address 00223d79.
	dx.b 1
; Unknown data at address 00223d7a.
	dx.b 1
; Unknown data at address 00223d7b.
	dx.b 1
; Unknown data at address 00223d7c.
	dx.b 1
; Unknown data at address 00223d7d.
	dx.b 1
; Unknown data at address 00223d7e.
	dx.b 1
; Unknown data at address 00223d7f.
	dx.b 1
; Unknown data at address 00223d80.
	dx.b 1
; Unknown data at address 00223d81.
	dx.b 1
; Unknown data at address 00223d82.
	dx.b 1
; Unknown data at address 00223d83.
	dx.b 1
; Unknown data at address 00223d84.
	dx.b 1
; Unknown data at address 00223d85.
	dx.b 1
; Unknown data at address 00223d86.
	dx.b 1
; Unknown data at address 00223d87.
	dx.b 1
; Unknown data at address 00223d88.
	dx.b 1
; Unknown data at address 00223d89.
	dx.b 1
; Unknown data at address 00223d8a.
	dx.b 1
; Unknown data at address 00223d8b.
	dx.b 1
; Unknown data at address 00223d8c.
	dx.b 1
; Unknown data at address 00223d8d.
	dx.b 1
; Unknown data at address 00223d8e.
	dx.b 1
; Unknown data at address 00223d8f.
	dx.b 1
; Unknown data at address 00223d90.
	dx.b 1
; Unknown data at address 00223d91.
	dx.b 1
; Unknown data at address 00223d92.
	dx.b 1
; Unknown data at address 00223d93.
	dx.b 1
; Unknown data at address 00223d94.
	dx.b 1
; Unknown data at address 00223d95.
	dx.b 1
; Unknown data at address 00223d96.
	dx.b 1
; Unknown data at address 00223d97.
	dx.b 1
; Unknown data at address 00223d98.
	dx.b 1
; Unknown data at address 00223d99.
	dx.b 1
; Unknown data at address 00223d9a.
	dx.b 1
; Unknown data at address 00223d9b.
	dx.b 1
; Unknown data at address 00223d9c.
	dx.b 1
; Unknown data at address 00223d9d.
	dx.b 1
; Unknown data at address 00223d9e.
	dx.b 1
; Unknown data at address 00223d9f.
	dx.b 1
; Unknown data at address 00223da0.
	dx.b 1
; Unknown data at address 00223da1.
	dx.b 1
; Unknown data at address 00223da2.
	dx.b 1
; Unknown data at address 00223da3.
	dx.b 1
; Unknown data at address 00223da4.
	dx.b 1
; Unknown data at address 00223da5.
	dx.b 1
; Unknown data at address 00223da6.
	dx.b 1
; Unknown data at address 00223da7.
	dx.b 1
; Unknown data at address 00223da8.
	dx.b 1
; Unknown data at address 00223da9.
	dx.b 1
; Unknown data at address 00223daa.
	dx.b 1
; Unknown data at address 00223dab.
	dx.b 1
; Unknown data at address 00223dac.
	dx.b 1
; Unknown data at address 00223dad.
	dx.b 1
; Unknown data at address 00223dae.
	dx.b 1
; Unknown data at address 00223daf.
	dx.b 1
; Unknown data at address 00223db0.
	dx.b 1
; Unknown data at address 00223db1.
	dx.b 1
; Unknown data at address 00223db2.
	dx.b 1
; Unknown data at address 00223db3.
	dx.b 1
; Unknown data at address 00223db4.
	dx.b 1
; Unknown data at address 00223db5.
	dx.b 1
; Unknown data at address 00223db6.
	dx.b 1
; Unknown data at address 00223db7.
	dx.b 1
; Unknown data at address 00223db8.
	dx.b 1
; Unknown data at address 00223db9.
	dx.b 1
; Unknown data at address 00223dba.
	dx.b 1
; Unknown data at address 00223dbb.
	dx.b 1
; Unknown data at address 00223dbc.
	dx.b 1
; Unknown data at address 00223dbd.
	dx.b 1
; Unknown data at address 00223dbe.
	dx.b 1
; Unknown data at address 00223dbf.
	dx.b 1
; Unknown data at address 00223dc0.
	dx.b 1
; Unknown data at address 00223dc1.
	dx.b 1
; Unknown data at address 00223dc2.
	dx.b 1
; Unknown data at address 00223dc3.
	dx.b 1
; Unknown data at address 00223dc4.
	dx.b 1
; Unknown data at address 00223dc5.
	dx.b 1
; Unknown data at address 00223dc6.
	dx.b 1
; Unknown data at address 00223dc7.
	dx.b 1
; Unknown data at address 00223dc8.
	dx.b 1
; Unknown data at address 00223dc9.
	dx.b 1
; Unknown data at address 00223dca.
	dx.b 1
; Unknown data at address 00223dcb.
	dx.b 1
; Unknown data at address 00223dcc.
	dx.b 1
; Unknown data at address 00223dcd.
	dx.b 1
; Unknown data at address 00223dce.
	dx.b 1
; Unknown data at address 00223dcf.
	dx.b 1
; Unknown data at address 00223dd0.
	dx.b 1
; Unknown data at address 00223dd1.
	dx.b 1
; Unknown data at address 00223dd2.
	dx.b 1
; Unknown data at address 00223dd3.
	dx.b 1
; Unknown data at address 00223dd4.
	dx.b 1
; Unknown data at address 00223dd5.
	dx.b 1
; Unknown data at address 00223dd6.
	dx.b 1
; Unknown data at address 00223dd7.
	dx.b 1
; Unknown data at address 00223dd8.
	dx.b 1
; Unknown data at address 00223dd9.
	dx.b 1
; Unknown data at address 00223dda.
	dx.b 1
; Unknown data at address 00223ddb.
	dx.b 1
; Unknown data at address 00223ddc.
	dx.b 1
; Unknown data at address 00223ddd.
	dx.b 1
; Unknown data at address 00223dde.
	dx.b 1
; Unknown data at address 00223ddf.
	dx.b 1
; Unknown data at address 00223de0.
	dx.b 1
; Unknown data at address 00223de1.
	dx.b 1
; Unknown data at address 00223de2.
	dx.b 1
; Unknown data at address 00223de3.
	dx.b 1
; Unknown data at address 00223de4.
	dx.b 1
; Unknown data at address 00223de5.
	dx.b 1
; Unknown data at address 00223de6.
	dx.b 1
; Unknown data at address 00223de7.
	dx.b 1
; Unknown data at address 00223de8.
	dx.b 1
; Unknown data at address 00223de9.
	dx.b 1
; Unknown data at address 00223dea.
	dx.b 1
; Unknown data at address 00223deb.
	dx.b 1
; Unknown data at address 00223dec.
	dx.b 1
; Unknown data at address 00223ded.
	dx.b 1
; Unknown data at address 00223dee.
	dx.b 1
; Unknown data at address 00223def.
	dx.b 1
; Unknown data at address 00223df0.
	dx.b 1
; Unknown data at address 00223df1.
	dx.b 1
; Unknown data at address 00223df2.
	dx.b 1
; Unknown data at address 00223df3.
	dx.b 1
; Unknown data at address 00223df4.
	dx.b 1
; Unknown data at address 00223df5.
	dx.b 1
; Unknown data at address 00223df6.
	dx.b 1
; Unknown data at address 00223df7.
	dx.b 1
; Unknown data at address 00223df8.
	dx.b 1
; Unknown data at address 00223df9.
	dx.b 1
; Unknown data at address 00223dfa.
	dx.b 1
; Unknown data at address 00223dfb.
	dx.b 1
; Unknown data at address 00223dfc.
	dx.b 1
; Unknown data at address 00223dfd.
	dx.b 1
; Unknown data at address 00223dfe.
	dx.b 1
; Unknown data at address 00223dff.
	dx.b 1
; Unknown data at address 00223e00.
	dx.b 1
; Unknown data at address 00223e01.
	dx.b 1
; Unknown data at address 00223e02.
	dx.b 1
; Unknown data at address 00223e03.
	dx.b 1
; Unknown data at address 00223e04.
	dx.b 1
; Unknown data at address 00223e05.
	dx.b 1
; Unknown data at address 00223e06.
	dx.b 1
; Unknown data at address 00223e07.
	dx.b 1
; Unknown data at address 00223e08.
	dx.b 1
; Unknown data at address 00223e09.
	dx.b 1
; Unknown data at address 00223e0a.
	dx.b 1
; Unknown data at address 00223e0b.
	dx.b 1
; Unknown data at address 00223e0c.
	dx.b 1
; Unknown data at address 00223e0d.
	dx.b 1
; Unknown data at address 00223e0e.
	dx.b 1
; Unknown data at address 00223e0f.
	dx.b 1
; Unknown data at address 00223e10.
	dx.b 1
; Unknown data at address 00223e11.
	dx.b 1
; Unknown data at address 00223e12.
	dx.b 1
; Unknown data at address 00223e13.
	dx.b 1
; Unknown data at address 00223e14.
	dx.b 1
; Unknown data at address 00223e15.
	dx.b 1
; Unknown data at address 00223e16.
	dx.b 1
; Unknown data at address 00223e17.
	dx.b 1
; Unknown data at address 00223e18.
	dx.b 1
; Unknown data at address 00223e19.
	dx.b 1
; Unknown data at address 00223e1a.
	dx.b 1
; Unknown data at address 00223e1b.
	dx.b 1
; Unknown data at address 00223e1c.
	dx.b 1
; Unknown data at address 00223e1d.
	dx.b 1
; Unknown data at address 00223e1e.
	dx.b 1
; Unknown data at address 00223e1f.
	dx.b 1
; Unknown data at address 00223e20.
	dx.b 1
; Unknown data at address 00223e21.
	dx.b 1
; Unknown data at address 00223e22.
	dx.b 1
; Unknown data at address 00223e23.
	dx.b 1
; Unknown data at address 00223e24.
	dx.b 1
; Unknown data at address 00223e25.
	dx.b 1
; Unknown data at address 00223e26.
	dx.b 1
; Unknown data at address 00223e27.
	dx.b 1
; Unknown data at address 00223e28.
	dx.b 1
; Unknown data at address 00223e29.
	dx.b 1
; Unknown data at address 00223e2a.
	dx.b 1
; Unknown data at address 00223e2b.
	dx.b 1
; Unknown data at address 00223e2c.
	dx.b 1
; Unknown data at address 00223e2d.
	dx.b 1
; Unknown data at address 00223e2e.
	dx.b 1
; Unknown data at address 00223e2f.
	dx.b 1
; Unknown data at address 00223e30.
	dx.b 1
; Unknown data at address 00223e31.
	dx.b 1
; Unknown data at address 00223e32.
	dx.b 1
; Unknown data at address 00223e33.
	dx.b 1
; Unknown data at address 00223e34.
	dx.b 1
; Unknown data at address 00223e35.
	dx.b 1
; Unknown data at address 00223e36.
	dx.b 1
; Unknown data at address 00223e37.
	dx.b 1
; Unknown data at address 00223e38.
	dx.b 1
; Unknown data at address 00223e39.
	dx.b 1
; Unknown data at address 00223e3a.
	dx.b 1
; Unknown data at address 00223e3b.
	dx.b 1
; Unknown data at address 00223e3c.
	dx.b 1
; Unknown data at address 00223e3d.
	dx.b 1
; Unknown data at address 00223e3e.
	dx.b 1
; Unknown data at address 00223e3f.
	dx.b 1
; Unknown data at address 00223e40.
	dx.b 1
; Unknown data at address 00223e41.
	dx.b 1
; Unknown data at address 00223e42.
	dx.b 1
; Unknown data at address 00223e43.
	dx.b 1
DAT_00223e44:
	; undefined1
	dx.b 1
DAT_00223e45:
; Unknown data at address 00223e45.
	dx.b 1
DAT_00223e46:
; Unknown data at address 00223e46.
	dx.b 1
; Unknown data at address 00223e47.
	dx.b 1
DAT_00223e48:
; Unknown data at address 00223e48.
	dx.b 1
; Unknown data at address 00223e49.
	dx.b 1
DAT_00223e4a:
; Unknown data at address 00223e4a.
	dx.b 1
; Unknown data at address 00223e4b.
	dx.b 1
DAT_00223e4c:
	; undefined4
	dx.l 1
DAT_00223e50:
; Unknown data at address 00223e50.
	dx.b 1
; Unknown data at address 00223e51.
	dx.b 1
; Unknown data at address 00223e52.
	dx.b 1
; Unknown data at address 00223e53.
	dx.b 1
DAT_00223e54:
	; undefined4
	dx.l 1
DAT_00223e58:
	; undefined4
	dx.l 1
DAT_00223e5c:
	; undefined4
	dx.l 1
DAT_00223e60:
	; undefined4
	dx.l 1
DAT_00223e64:
; Unknown data at address 00223e64.
	dx.b 1
; Unknown data at address 00223e65.
	dx.b 1
; Unknown data at address 00223e66.
	dx.b 1
; Unknown data at address 00223e67.
	dx.b 1
DAT_00223e68:
	; undefined4
	dx.l 1
DAT_00223e6c:
	; undefined4
	dx.l 1
DAT_00223e70:
	; undefined4
	dx.l 1
DAT_00223e74:
	; undefined4
	dx.l 1
DAT_00223e78:
	; undefined4
	dx.l 1
DAT_00223e7c:
	; undefined4
	dx.l 1
DAT_00223e80:
	; undefined4
	dx.l 1
DAT_00223e84:
	; undefined4
	dx.l 1
DAT_00223e88:
	; undefined4
	dx.l 1
DAT_00223e8c:
	; undefined4
	dx.l 1
DAT_00223e90:
	; undefined4
	dx.l 1
DAT_00223e94:
	; undefined4
	dx.l 1
DAT_00223e98:
	; undefined4
	dx.l 1
DAT_00223e9c:
	; undefined4
	dx.l 1
;   }
