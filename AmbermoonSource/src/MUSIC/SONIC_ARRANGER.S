; Sonic Arranger replay routine
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code

;*****************************************************************************
; [ _SA_Hardcalc ]
;*****************************************************************************
_SA_Hardcalc:
	jmp	SA_Hardcalc(pc)

;*****************************************************************************
; [ _SA_SetIrq ]
;*****************************************************************************
_SA_SetIrq:
	jmp	SA_SetIrq(pc)

;*****************************************************************************
; [ _SA_ClrIrq ]
;*****************************************************************************
_SA_ClrIrq:
	jmp	SA_ClrIrq(pc)

;*****************************************************************************
; [ _SA_StartSong ]
;*****************************************************************************
_SA_StartSong:
	jmp	SA_StartSong(pc)

;*****************************************************************************
; [ _SA_StopSong ]
;*****************************************************************************
_SA_StopSong:
	jmp	SA_StopSong(pc)

;*****************************************************************************
; [ _SA_Insert ]
;*****************************************************************************
_SA_Insert:
	jmp	SA_Insert(pc)

;*****************************************************************************
; [ _SA_IrqLowLevel ]
;*****************************************************************************
_SA_IrqLowLevel:
	jmp	SA_IrqLowLevel(pc)

_SA_VolLevels:
	dc.b	0
	dc.b	0		; SapcByteWord.value
	dc.b	0
	dc.b	0		; SapcByteWord.value
	dc.b	0
	dc.b	0		; SapcByteWord.value
	dc.b	0
	dc.b	0		; SapcByteWord.value

_SA_VoiceCons:
	dc.w	$2c

_SA_ReplayerVer:
	dc.w	$75

_SA_SyncValue:
	dc.w	0

_SA_MasterVolume:
	dc.w	$34

sa_voiceCons:
	dc.w	1,1,1,1

sa_masterVolume:
	dc.w	$3f

;*****************************************************************************
; [ SA_Hardcalc ]
;*****************************************************************************
SA_Hardcalc:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	sa_songTable,a1
	move.l	(a0),d0
	lea.l	0(a0,d0.l),a2
	move.l	a2,(a1)
	lea.l	sa_overTable,a1
	move.l	4(a0),d0
	lea.l	0(a0,d0.l),a2
	move.l	a2,(a1)
	lea.l	sa_noteTable,a1
	move.l	8(a0),d0
	lea.l	0(a0,d0.l),a2
	move.l	a2,(a1)
	lea.l	sa_instTab,a1
	move.l	12(a0),d0
	lea.l	0(a0,d0.l),a2
	move.l	a2,(a1)
	lea.l	sa_synthTable,a1
	move.l	16(a0),d0
	lea.l	0(a0,d0.l),a2
	move.l	a2,(a1)
	lea.l	sa_adsrTable,a1
	move.l	20(a0),d0
	lea.l	0(a0,d0.l),a2
	move.l	a2,(a1)
	lea.l	sa_amfTable,a1
	move.l	24(a0),d0
	lea.l	0(a0,d0.l),a2
	move.l	a2,(a1)
	lea.l	sa_sampleTable,a1
	move.l	28(a0),d0
	lea.l	0(a0,d0.l),a0
	move.l	(a0)+,d0
	beq.s	.Exit
	move.l	d0,d1
	asl.l	#2,d1
	lea.l	0(a0,d1.l),a2
.Loop:
	move.l	a2,(a1)+
	add.l	(a0)+,a2
	subq.l	#1,d0
	bne.s	.Loop
.Exit:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ SA_LoadSong ]
;*****************************************************************************
SA_LoadSong:
	lea.l	$dff000,a0
	move.w	#15,150(a0)
	move.w	#255,158(a0)
	move.w	#1920,154(a0)
	move.w	#1920,156(a0)
	bsr.w	SA_SilenceAllTracks
	move.l	sa_songTable,a0
	mulu.w	#12,d0
	add.l	d0,a0
	lea.l	sa_song,a1
	moveq.l	#11,d1
.Loop:
	move.b	(a0)+,(a1)+
	dbra	d1,.Loop
	lea.l	sa_overLinePos,a0
	move.w	sa_song+4,d0
	subq.w	#1,d0
	move.w	d0,(a0)
	lea.l	sa_songSpeedPos,a0
	move.w	sa_song,(a0)
	lea.l	sa_overPatternPos,a0
	move.w	sa_song+2,(a0)
	lea.l	sa_masterVolume,a0
	move.w	#63,(a0)
	bsr.w	SA_SetTimerCounter
	rts

sa_ciabInterruptAdded:
	dc.w	0

sa_ciabResource:
	; Library *
	dc.l	0

sa_ciabInterrupt:
	dc.l	0		; null pointer address ; Node.ln_Succ
	dc.l	0		; null pointer address ; Node.ln_Pred
	dc.b	0		; Node.ln_Type
	dc.b	0		; Node.ln_Pri
	dc.l	0		; null pointer address ; Node.ln_Name ; Interrupt.is_Node
	dc.l	0		; null pointer address ; Interrupt.is_Data
	dc.l	0		; null pointer address ; Interrupt.is_Code

sa_ciabInterruptName:
	dc.b	"musicirq",0

sa_ciabResourceName:
	dc.b	"ciab.resource",0
	dc.b	0

;*****************************************************************************
; [ SA_SetIrq ]
;*****************************************************************************
SA_SetIrq:
	move.l	a6,-(sp)
	lea.l	sa_ciabResourceName,a1
	move.l	4,a6		; Exec base
	jsr	-498(a6)
	lea.l	sa_ciabResource,a1
	move.l	d0,(a1)
	bne.s	.Skip
	moveq.l	#0,d0
	bra.s	.Skip3
.Skip:
	lea.l	sa_ciabInterrupt,a1
	move.b	#2,8(a1)
	clr.b	9(a1)
	lea.l	sa_ciabInterruptName,a0
	move.l	a0,10(a1)
	clr.l	14(a1)
	lea.l	SA_CiabInterruptCode,a0
	move.l	a0,18(a1)
	move.l	sa_ciabResource,a6
	moveq.l	#1,d0
	lea.l	sa_ciabInterrupt,a1
	jsr	-6(a6)
	tst.l	d0
	beq.s	.Skip2
	moveq.l	#0,d0
	bra.s	.Skip3
.Skip2:
	moveq.l	#1,d0
.Skip3:
	lea.l	sa_ciabInterruptAdded,a0
	move.w	d0,(a0)
	tst.w	d0
	beq.s	.Exit
	moveq.l	#0,d0
	bsr.w	SA_LoadSong
	lea.l	sa_overLinePos,a0
	addq.w	#1,(a0)
	lea.l	$bfd000,a0
	move.b	#17,3840(a0)
	move.b	#-126,3328(a0)
.Exit:
	move.w	sa_ciabInterruptAdded,d0
	move.l	(sp)+,a6
	rts

;*****************************************************************************
; [ SA_ClrIrq ]
;*****************************************************************************
SA_ClrIrq:
	move.l	a6,-(sp)
	lea.l	sa_ciabInterruptAdded,a0
	tst.w	(a0)
	beq.s	.Exit
	move.l	4,a6		; Exec base
	jsr	_LVODisable(a6)
	move.l	sa_ciabResource,a6
	moveq.l	#1,d0
	lea.l	sa_ciabInterrupt,a1
	jsr	-12(a6)
	move.l	4,a6		; Exec base
	jsr	_LVOEnable(a6)
	bsr.s	SA_SilenceAllTracks
	move.w	#$f,Custom+dmacon
.Exit:
	move.l	(sp)+,a6
	rts

;*****************************************************************************
; [ SA_GetTimerCounter ]
;*****************************************************************************
SA_GetTimerCounter:
	lea.l	$bfd000,a0
	move.b	1792(a0),d0
	move.b	1536(a0),d1
	cmp.b	1792(a0),d0
	bne.s	SA_GetTimerCounter
	lsl.w	#8,d0
	move.b	d1,d0
	rts

;*****************************************************************************
; [ SA_SetTimerCounter ]
;*****************************************************************************
SA_SetTimerCounter:
	move.l	d1,-(sp)
	move.l	#709379,d0
	move.w	sa_songState-2,d1
	beq.s	.Skip
	divu.w	d1,d0
	lea.l	$bfd000,a0
.Skip:
	clr.b	3840(a0)
	move.b	d0,1536(a0)
	lsr.w	#8,d0
	move.b	d0,1792(a0)
	move.b	#17,3840(a0)
	move.l	(sp)+,d1
	rts

;*****************************************************************************
; [ SA_SilenceAllTracks ]
;*****************************************************************************
SA_SilenceAllTracks:
	lea.l	sa_track,a0
	bset.b	#0,181(a0)
	bset.b	#0,387(a0)
	bset.b	#0,593(a0)
	bset.b	#0,799(a0)
	rts

;*****************************************************************************
; [ SA_StartSong ]
;*****************************************************************************
SA_StartSong:
	bset.b	#1,$bfe001
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	sa_songState,a6
	clr.w	(a6)
	bsr.w	SA_LoadSong
	move.w	#-1,(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ SA_SetOverLine ]
;*****************************************************************************
SA_SetOverLine:
	lea.l	sa_songState,a1
	clr.w	(a1)
	lea.l	sa_overPatternPos,a0
	move.w	sa_song+2,(a0)
	lea.l	sa_overLinePos,a0
	move.w	d0,(a0)
	move.w	#1,(a1)
	rts

;*****************************************************************************
; [ SA_StopSong ]
;*****************************************************************************
SA_StopSong:
	bclr.b	#1,$bfe001
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	sa_songState,a0
	clr.w	(a0)
	lea.l	sa_sampleRepeat,a0
	clr.l	(a0)
	bsr.w	SA_SilenceAllTracks
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ SA_RepTrackSample ]
;*****************************************************************************
SA_RepTrackSample:
	move.l	138(a4),a5
	tst.w	6(a5)
	bne.s	.Skip
	rts
.Skip:
	cmpi.w	#1,6(a5)
	bne.s	.Skip2
.Loop:
	lea.l	sa_silence,a0
	move.l	a0,(a3)
	move.w	#1,4(a3)
	rts
.Skip2:
	move.l	188(a4),d2
	beq.s	.Loop
	moveq.l	#0,d0
	movem.w	4(a5),d0/d1
	lsl.l	#1,d0
	add.l	d0,d2
	move.l	d2,(a3)
	move.w	d1,4(a3)
	rts

sa_softInterrupt:
	dc.l	0		; null pointer address ; Node.ln_Succ
	dc.l	0		; null pointer address ; Node.ln_Pred
	dc.b	0		; Node.ln_Type
	dc.b	0		; Node.ln_Pri
	dc.l	0		; null pointer address ; Node.ln_Name ; Interrupt.is_Node
	dc.l	0		; null pointer address ; Interrupt.is_Data
	dc.l	0		; null pointer address ; Interrupt.is_Code

sa_softInterruptName:
	dc.b	"music_soft_irq",0
	dc.b	0

;*****************************************************************************
; [ SA_CiabInterruptCode ]
;*****************************************************************************
SA_CiabInterruptCode:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	sa_softInterrupt,a1
	move.b	#2,8(a1)
	clr.b	9(a1)
	lea.l	sa_softInterruptName,a0
	move.l	a0,10(a1)
	clr.l	14(a1)
	lea.l	SA_IrqLowLevel,a0
	move.l	a0,18(a1)
	move.l	4,a6		; Exec base
	jsr	-180(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	moveq.l	#0,d0
	rts

;*****************************************************************************
; [ SA_IrqLowLevel ]
;*****************************************************************************
SA_IrqLowLevel:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	sa_sampleRepeat,a6
	move.l	(a6),d0
	beq.s	.Skip5
	tst.b	(a6)
	beq.s	.Skip
	lea.l	Custom+aud0+ac_ptr,a3
	lea.l	sa_track,a4
	bsr.w	SA_RepTrackSample
.Skip:
	tst.b	1(a6)
	beq.s	.Skip2
	lea.l	Custom+aud1+ac_ptr,a3
	lea.l	sa_track+206,a4
	bsr.w	SA_RepTrackSample
.Skip2:
	tst.b	2(a6)
	beq.s	.Skip3
	lea.l	Custom+aud2+ac_ptr,a3
	lea.l	sa_track+412,a4
	bsr.w	SA_RepTrackSample
.Skip3:
	tst.b	3(a6)
	beq.s	.Skip4
	lea.l	Custom+aud3+ac_ptr,a3
	lea.l	sa_track+618,a4
	bsr.w	SA_RepTrackSample
.Skip4:
	clr.l	(a6)
.Skip5:
	lea.l	sa_songSpeedPos,a0
	addq.w	#1,(a0)
	move.w	(a0),d0
	cmp.w	sa_song,d0
	blt.s	.Skip6
	clr.w	(a0)
	move.w	sa_songState,d0
	beq.s	.Skip6
	bsr.s	SA_AdvanceSong
.Skip6:
	bsr.w	SA_ProcessSong
	lea.l	sa_dmaConValue,a0
	tst.w	(a0)
	beq.s	.Exit
	move.w	(a0),Custom+dmacon
	clr.w	(a0)
.Exit:
	movem.l	(sp)+,d0-d7/a0-a6
	moveq.l	#0,d0
	rts

;*****************************************************************************
; [ SA_AdvanceSong ]
;*****************************************************************************
SA_AdvanceSong:
	lea.l	sa_overPatternPos,a0
	addq.w	#1,(a0)
	move.w	sa_song+2,d0
	cmp.w	(a0),d0
	bgt.w	.Skip2
	clr.w	(a0)
	lea.l	sa_songState,a1
	tst.w	(a1)
	bgt.s	.Skip
	lea.l	sa_overLinePos,a0
	addq.w	#1,(a0)
	move.w	sa_song+6,d0
	cmp.w	(a0),d0
	bge.s	.Skip
	move.w	sa_songState-4,(a0)
.Skip:
	moveq.l	#0,d0
	move.w	sa_overLinePos,d0
	lsl.l	#4,d0
	move.l	sa_overTable,a0
	lea.l	0(a0,d0.l),a0
	move.l	sa_noteTable,a1
	lea.l	sa_overNotePtr,a2
	lea.l	sa_overTranspose,a3
	lea.l	sa_overNoteVal,a4
	moveq.l	#0,d0
	move.w	(a0)+,d0
	asl.l	#2,d0
	lea.l	0(a1,d0.l),a6
	move.l	a6,(a2)+
	move.l	(a6),(a4)+
	move.w	(a0)+,(a3)+
	moveq.l	#0,d0
	move.w	(a0)+,d0
	asl.l	#2,d0
	lea.l	0(a1,d0.l),a6
	move.l	a6,(a2)+
	move.l	(a6),(a4)+
	move.w	(a0)+,(a3)+
	moveq.l	#0,d0
	move.w	(a0)+,d0
	asl.l	#2,d0
	lea.l	0(a1,d0.l),a6
	move.l	a6,(a2)+
	move.l	(a6),(a4)+
	move.w	(a0)+,(a3)+
	moveq.l	#0,d0
	move.w	(a0)+,d0
	asl.l	#2,d0
	lea.l	0(a1,d0.l),a6
	move.l	a6,(a2)+
	move.l	(a6),(a4)+
	move.w	(a0)+,(a3)+
	bra.s	.Skip3
.Skip2:
	lea.l	sa_overNotePtr,a0
	lea.l	sa_overNoteVal,a1
	addq.l	#4,(a0)
	addq.l	#4,4(a0)
	addq.l	#4,8(a0)
	addq.l	#4,12(a0)
	move.l	(a0)+,a2
	move.l	(a2)+,(a1)+
	move.l	(a0)+,a2
	move.l	(a2)+,(a1)+
	move.l	(a0)+,a2
	move.l	(a2)+,(a1)+
	move.l	(a0)+,a2
	move.l	(a2)+,(a1)+
.Skip3:
	lea.l	sa_overNoteVal,a0
	move.l	a0,-(sp)
	moveq.l	#0,d5
	move.w	sa_voiceCons,d0
	beq.s	.Skip5
	lea.l	sa_insertLockTime,a0
	tst.w	(a0)
	beq.s	.Skip4
	subq.w	#1,(a0)
	bra.s	.Skip5
.Skip4:
	move.l	(sp),a0
	move.l	(a0),d7
	move.w	sa_overTranspose,d6
	moveq.l	#1,d2
	lea.l	sa_sampleRepeat,a2
	lea.l	Custom+aud0+ac_ptr,a3
	lea.l	sa_track,a4
	bsr.w	SA_AdvanceTrack
.Skip5:
	move.w	sa_voiceCons+2,d0
	beq.s	.Skip7
	lea.l	sa_insertLockTime+2,a0
	tst.w	(a0)
	beq.s	.Skip6
	subq.w	#1,(a0)
	bra.s	.Skip7
.Skip6:
	move.l	(sp),a0
	move.l	4(a0),d7
	move.w	sa_overTranspose+2,d6
	moveq.l	#2,d2
	lea.l	sa_insertLockTime-3,a2
	lea.l	Custom+aud1+ac_ptr,a3
	lea.l	sa_track+206,a4
	bsr.w	SA_AdvanceTrack
.Skip7:
	move.w	sa_masterVolume-4,d0
	beq.s	.Skip9
	lea.l	sa_songSpeedPos-4,a0
	tst.w	(a0)
	beq.s	.Skip8
	subq.w	#1,(a0)
	bra.s	.Skip9
.Skip8:
	move.l	(sp),a0
	move.l	8(a0),d7
	move.w	sa_overNotePtr-4,d6
	moveq.l	#4,d2
	lea.l	sa_insertLockTime-2,a2
	lea.l	Custom+aud2+ac_ptr,a3
	lea.l	sa_track+412,a4
	bsr.w	SA_AdvanceTrack
.Skip9:
	move.w	sa_masterVolume-2,d0
	beq.s	.Skip11
	lea.l	sa_songSpeedPos-2,a0
	tst.w	(a0)
	beq.s	.Skip10
	subq.w	#1,(a0)
	bra.s	.Skip11
.Skip10:
	move.l	(sp),a0
	move.l	12(a0),d7
	move.w	sa_overNotePtr-2,d6
	moveq.l	#8,d2
	lea.l	sa_insertLockTime-1,a2
	lea.l	Custom+aud3+ac_ptr,a3
	lea.l	sa_track+618,a4
	bsr.w	SA_AdvanceTrack
.Skip11:
	lea.l	4(sp),sp
	ori.w	#-$8000,d5
	lea.l	sa_dmaConValue,a6
	move.w	d5,(a6)
	lea.l	sa_track,a4
	lea.l	_SA_VolLevels,a1
	move.b	179(a4),1(a1)
	move.b	385(a4),3(a1)
	move.b	591(a4),5(a1)
	move.b	797(a4),7(a1)
	rts

sa_noteEffectTable:
	dc.w	2,4,$a,2,$10,$38,$42,$50
	dc.w	$56,$5c,$70,$76,$8e,$ae,$bc,$d4

;*****************************************************************************
; [ SA_ApplyNoteEffect ]
;*****************************************************************************
SA_ApplyNoteEffect:
	clr.w	134(a4)
	clr.w	144(a4)
	move.w	d7,d0
	andi.l	#$f00,d0
	lsr.l	#7,d0
	lea.l	sa_noteEffectTable,a0
	move.w	0(a0,d0.w),d0
	lea.l	Switch_note_command(pc,d0.w),a0
	moveq.l	#0,d1
	move.b	d7,d0
	move.b	d7,d1
	ext.w	d0

;*****************************************************************************
; [ Switch_note_command ]
;*****************************************************************************
Switch_note_command:
	jmp	(a0)

;*****************************************************************************
; [ SA_ApplyNoteEffect_None ]
;*****************************************************************************
SA_ApplyNoteEffect_None:
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_PitchBend ]
;*****************************************************************************
SA_ApplyNoteEffect_PitchBend:
	move.w	d0,134(a4)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_RestartAdsr ]
;*****************************************************************************
SA_ApplyNoteEffect_RestartAdsr:
	move.w	d1,158(a4)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_Vibrato ]
;*****************************************************************************
SA_ApplyNoteEffect_Vibrato:
	clr.w	148(a4)
	move.w	d1,d0
	andi.w	#$f0,d0
	asr.w	#3,d0
	move.w	d0,150(a4)
	move.b	d1,d0
	andi.l	#$f,d0
	asl.l	#4,d0
	neg.l	d0
	addi.l	#160,d0
	move.w	d0,152(a4)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_SetSyncValue ]
;*****************************************************************************
SA_ApplyNoteEffect_SetSyncValue:
	lea.l	_SA_SyncValue,a0
	move.w	d1,(a0)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_SetMasterVolume ]
;*****************************************************************************
SA_ApplyNoteEffect_SetMasterVolume:
	lea.l	sa_masterVolume,a0
	andi.w	#$3f,d1
	move.w	d1,(a0)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_SetPortamento ]
;*****************************************************************************
SA_ApplyNoteEffect_SetPortamento:
	move.w	d1,154(a4)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_SkipPortamento ]
;*****************************************************************************
SA_ApplyNoteEffect_SkipPortamento:
	clr.w	154(a4)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_SetPatternLength ]
;*****************************************************************************
SA_ApplyNoteEffect_SetPatternLength:
	tst.w	d1
	ble.s	SA_ApplyNoteEffect_None
	cmp.w	#64,d1
	bhi.s	SA_ApplyNoteEffect_None
	lea.l	sa_song+2,a6
	move.w	d1,(a6)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_VolumeSlide ]
;*****************************************************************************
SA_ApplyNoteEffect_VolumeSlide:
	move.w	d0,144(a4)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_PatternJump ]
;*****************************************************************************
SA_ApplyNoteEffect_PatternJump:
	lea.l	sa_overLinePos,a6
	subq.w	#1,d1
	move.w	d1,(a6)
	lea.l	sa_overPatternPos,a6
	move.w	sa_song+2,(a6)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_SetVolume ]
;*****************************************************************************
SA_ApplyNoteEffect_SetVolume:
	cmp.w	#64,d1
	bls.s	.Skip
	move.w	#64,d1
.Skip:
	move.w	d1,142(a4)
	move.w	sa_masterVolume,d0
	mulu.w	d0,d1
	asr.l	#6,d1
	asl.w	#2,d1
	move.w	d1,178(a4)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_BreakPattern ]
;*****************************************************************************
SA_ApplyNoteEffect_BreakPattern:
	lea.l	sa_overPatternPos,a6
	move.w	sa_song+2,(a6)
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_LowPassFilter ]
;*****************************************************************************
SA_ApplyNoteEffect_LowPassFilter:
	tst.b	d0
	bne.s	.Exit
	bclr.b	#1,$bfe001
	rts
.Exit:
	bset.b	#1,$bfe001
	rts

;*****************************************************************************
; [ SA_ApplyNoteEffect_SetSongSpeed ]
;*****************************************************************************
SA_ApplyNoteEffect_SetSongSpeed:
	tst.b	d1
	ble.w	SA_ApplyNoteEffect_None
	cmp.b	#16,d1
	bgt.w	SA_ApplyNoteEffect_None
	lea.l	sa_song,a6
	move.w	d1,(a6)
	rts

;*****************************************************************************
; [ SA_AdvanceTrack ]
;*****************************************************************************
SA_AdvanceTrack:
	move.l	d7,d3
	rol.l	#8,d3
	andi.l	#$ff,d3
	move.l	d7,d4
	swap	d4
	andi.l	#$ff,d4
	tst.b	d3
	bne.s	.Skip
	tst.b	d4
	beq.w	.Skip10
	bsr.w	SA_LoadTrackInst
	bra.w	.Skip10
.Skip:
	cmp.b	#-128,d3
	beq.w	.Skip10
	cmp.b	#127,d3
	bne.s	.Skip2
	bsr.w	SA_ClrTrackInst
	bra.s	.Skip10
.Skip2:
	move.w	d7,d0
	moveq.l	#12,d1
	lsr.l	d1,d0
	moveq.l	#12,d1
	and.l	d1,d0
	btst.l	#2,d0
	bne.s	.Skip3
	move.b	d6,d1
	ext.w	d1
	add.w	d1,d3
.Skip3:
	tst.w	d4
	beq.s	.Skip4
	btst.l	#3,d0
	bne.s	.Skip4
	move.w	d6,d1
	ror.w	#8,d1
	ext.w	d1
	add.w	d1,d4
.Skip4:
	andi.w	#$ff,d4
	move.w	128(a4),130(a4)
	move.w	d3,128(a4)
	tst.w	130(a4)
	bne.s	.Skip5
	move.w	d3,130(a4)
.Skip5:
	tst.w	186(a4)
	bne.s	.Skip6
	move.w	d2,Custom+dmacon
	move.w	#1,4(a3)
	move.w	#114,6(a3)
.Skip6:
	tst.w	d4
	bne.s	.Skip7
	move.l	138(a4),d4
	beq.w	SA_ClrTrackInst
	move.l	d4,a5
	bsr.w	SA_SetTrackInst
	bra.s	.Skip8
.Skip7:
	bsr.w	SA_LoadTrackInst
.Skip8:
	move.w	(a5),186(a4)
	bne.s	.Skip9
	bsr.s	SA_LoadTrackSample
	bra.s	.Skip10
.Skip9:
	bsr.s	SA_LoadTrackSynth
.Skip10:
	bsr.w	SA_ApplyNoteEffect
	rts

;*****************************************************************************
; [ SA_LoadTrackSample ]
;*****************************************************************************
SA_LoadTrackSample:
	lea.l	sa_sampleTable,a0
	moveq.l	#0,d0
	move.w	2(a5),d0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),d0
	bne.s	.Skip
	bset.b	#0,181(a4)
	bsr.w	SA_ClrTrackInst
	sf	(a2)
	rts
.Skip:
	move.l	d0,(a3)
	move.l	d0,188(a4)
	moveq.l	#0,d1
	move.w	4(a5),d1
	moveq.l	#0,d0
	cmpi.w	#1,6(a5)
	beq.s	.Skip2
	move.w	6(a5),d0
.Skip2:
	add.l	d1,d0
	move.w	d0,4(a3)
	move.w	d0,184(a4)
	or.w	d2,d5
	move.w	d2,182(a4)
	st	(a2)
	rts

;*****************************************************************************
; [ SA_LoadTrackSynth ]
;*****************************************************************************
SA_LoadTrackSynth:
	move.l	sa_synthTable,a0
	moveq.l	#0,d0
	move.w	2(a5),d0
	asl.l	#7,d0
	lea.l	0(a0,d0.l),a0
	move.l	a0,188(a4)
	clr.l	192(a4)
	lea.l	(a4),a1
	move.l	a1,(a3)
	move.w	4(a5),d0
	move.w	d0,4(a3)
	move.w	d0,184(a4)
	subq.w	#1,d0
	asr.w	#3,d0
.Loop:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.Loop
	or.w	d2,d5
	move.w	d2,182(a4)
	sf	(a2)
	rts

;*****************************************************************************
; [ SA_LoadTrackInst ]
;*****************************************************************************
SA_LoadTrackInst:
	move.l	sa_instTab,a5
	andi.l	#$ff,d4
	move.w	d4,136(a4)
	subq.l	#1,d4
	mulu.w	#152,d4
	lea.l	0(a5,d4.l),a5
	move.l	a5,138(a4)
	move.w	16(a5),142(a4)
	move.w	20(a5),154(a4)
	clr.w	156(a4)
	clr.w	146(a4)
	move.w	22(a5),148(a4)
	move.w	24(a5),150(a4)
	move.w	26(a5),152(a4)

;*****************************************************************************
; [ SA_SetTrackInst ]
;*****************************************************************************
SA_SetTrackInst:
	move.w	18(a5),d0
	ext.w	d0
	move.w	d0,132(a4)
	move.w	38(a5),162(a4)
	clr.l	158(a4)
	move.w	30(a5),166(a4)
	clr.w	164(a4)
	move.w	68(a5),168(a4)
	clr.w	170(a4)
	move.w	72(a5),172(a4)
	clr.l	174(a4)
	move.w	142(a4),d0
	move.w	sa_masterVolume,d1
	mulu.w	d1,d0
	asr.l	#6,d0
	asl.w	#2,d0
	move.w	d0,178(a4)
	clr.w	180(a4)
	rts

;*****************************************************************************
; [ SA_ClrTrackInst ]
;*****************************************************************************
SA_ClrTrackInst:
	moveq.l	#0,d0
	move.w	d0,8(a3)
	lea.l	sa_silence,a0
	move.w	a0,(a3)
	move.w	#1,4(a3)
	move.w	d0,142(a4)
	move.w	d0,178(a4)
	move.w	d0,136(a4)
	move.w	d0,138(a4)
	sf	(a2)
	rts

;*****************************************************************************
; [ SA_ProcessSong ]
;*****************************************************************************
SA_ProcessSong:
	lea.l	sa_overNoteVal,a0
	move.l	a0,-(sp)
	move.l	(a0),d7
	lea.l	sa_track,a4
	lea.l	Custom+aud0+ac_ptr,a3
	bsr.s	SA_ProcessTrack
	move.l	(sp),a0
	move.l	4(a0),d7
	lea.l	sa_track+206,a4
	lea.l	Custom+aud1+ac_ptr,a3
	bsr.s	SA_ProcessTrack
	move.l	(sp),a0
	move.l	8(a0),d7
	lea.l	sa_track+412,a4
	lea.l	Custom+aud2+ac_ptr,a3
	bsr.s	SA_ProcessTrack
	move.l	(sp),a0
	move.l	12(a0),d7
	lea.l	sa_track+618,a4
	lea.l	Custom+aud3+ac_ptr,a3
	bsr.s	SA_ProcessTrack
	lea.l	4(sp),sp
	rts

;*****************************************************************************
; [ SA_ProcessTrack ]
;*****************************************************************************
SA_ProcessTrack:
	btst.b	#0,181(a4)
	bne.s	.Skip
	tst.l	138(a4)
	bne.s	.Skip2
.Skip:
	moveq.l	#0,d0
	move.w	d0,8(a3)
	move.w	#1,4(a3)
	lea.l	sa_silence,a0
	move.l	a0,(a3)
	tst.w	178(a4)
	beq.s	.Exit
	subq.w	#4,178(a4)
.Exit:
	rts
.Skip2:
	moveq.l	#0,d3
	move.w	128(a4),d3
	moveq.l	#0,d4
	move.w	130(a4),d4
	move.l	138(a4),a5
	move.w	d7,d0
	moveq.l	#12,d1
	lsr.w	d1,d0
	andi.w	#3,d0
	tst.w	d0
	beq.s	.Skip3
	subq.w	#1,d0
	asl.l	#4,d0
	lea.l	74(a5,d0.w),a0
	move.w	174(a4),d0
	move.b	2(a0,d0.w),d1
	add.b	d1,d3
	add.b	d1,d4
	addq.w	#1,174(a4)
	moveq.l	#0,d0
	move.b	(a0),d0
	add.b	1(a0),d0
	cmp.w	174(a4),d0
	bgt.s	.Skip7
	moveq.l	#0,d0
	move.b	(a0),d0
	move.w	d0,174(a4)
	bra.s	.Skip7
.Skip3:
	move.w	d7,d0
	andi.w	#$f00,d0
	bne.s	.Skip7
	move.b	d7,d0
	beq.s	.Skip7
	move.w	176(a4),d1
	tst.w	d1
	bne.s	.Skip4
	addq.w	#1,176(a4)
	bra.s	.Skip7
.Skip4:
	cmp.w	#1,d1
	bne.s	.Skip5
	addq.w	#1,176(a4)
	asr.w	#4,d0
	bra.s	.Skip6
.Skip5:
	clr.w	176(a4)
.Skip6:
	andi.w	#$f,d0
	add.w	d0,d3
	add.w	d0,d4
.Skip7:
	lea.l	sa_notePeriod,a0
	lsl.l	#1,d3
	lsl.l	#1,d4
	move.w	0(a0,d3.w),d3
	move.w	0(a0,d4.w),d4
	tst.w	154(a4)
	beq.s	.Skip13
	tst.w	156(a4)
	bne.s	.Skip8
	move.w	d4,156(a4)
.Skip8:
	move.w	156(a4),d4
	move.l	d3,d0
	sub.l	d4,d0
	bpl.s	.Skip9
	neg.l	d0
.Skip9:
	sub.w	154(a4),d0
	bpl.s	.Skip10
	clr.w	154(a4)
	bra.s	.Skip13
.Skip10:
	cmp.l	d3,d4
	bge.s	.Skip11
	add.w	154(a4),d4
	bra.s	.Skip12
.Skip11:
	sub.w	154(a4),d4
.Skip12:
	move.w	d4,156(a4)
	move.w	d4,d3
.Skip13:
	cmpi.b	#-1,149(a4)
	beq.s	.Skip16
	tst.w	148(a4)
	beq.s	.Skip14
	subq.w	#1,148(a4)
	bra.s	.Skip16
.Skip14:
	move.w	146(a4),d0
	lea.l	sa_Vibrato,a6
	lea.l	0(a6,d0.w),a6
	moveq.l	#0,d1
	move.b	(a6),d1
	ext.w	d1
	ext.l	d1
	moveq.l	#0,d0
	move.w	26(a5),d0
	tst.w	d0
	beq.s	.Skip15
	add.l	d1,d1
	add.l	d1,d1
	divs.w	d0,d1
	add.w	d1,d3
.Skip15:
	move.w	24(a5),d0
	add.w	d0,146(a4)
	andi.w	#$ff,146(a4)
.Skip16:
	moveq.l	#0,d0
	move.w	32(a5),d0
	add.w	34(a5),d0
	move.w	d0,d2
	beq.s	.Skip18
	move.l	sa_amfTable,a0
	moveq.l	#0,d0
	move.w	28(a5),d0
	asl.l	#7,d0
	lea.l	0(a0,d0.l),a0
	move.w	164(a4),d0
	move.b	0(a0,d0.w),d0
	ext.w	d0
	sub.w	d0,d3
	subq.w	#1,166(a4)
	bne.s	.Skip18
	move.w	30(a5),166(a4)
	addq.w	#1,164(a4)
	cmp.w	164(a4),d2
	bgt.s	.Skip18
	move.w	32(a5),d0
	tst.w	34(a5)
	bne.s	.Skip17
	subq.w	#1,d0
.Skip17:
	move.w	d0,164(a4)
.Skip18:
	sub.w	132(a4),d3
	cmp.w	#113,d3
	bge.s	.Skip19
	move.w	#113,d3
.Skip19:
	lea.l	sa_songSpeedPos,a6
	tst.w	(a6)
	beq.s	.Skip20
	move.w	134(a4),d0
	add.w	d0,132(a4)
.Skip20:
	move.w	d3,6(a3)
	tst.w	(a5)
	beq.s	.Skip21
	bsr.w	SA_ApplySynthEffect
.Skip21:
	moveq.l	#0,d0
	move.w	40(a5),d0
	add.w	42(a5),d0
	move.w	d0,d2
	bne.s	.Skip23
	move.w	142(a4),d0
	move.w	sa_masterVolume,d1
	mulu.w	d1,d0
	asr.l	#6,d0
	move.w	d0,8(a3)
	tst.w	178(a4)
	beq.s	.Skip22
	subq.w	#4,178(a4)
.Skip22:
	bra.w	.Skip27
.Skip23:
	move.l	sa_adsrTable,a0
	move.w	36(a5),d0
	asl.w	#7,d0
	lea.l	0(a0,d0.w),a0
	move.w	158(a4),d0
	moveq.l	#0,d1
	move.b	0(a0,d0.w),d1
	move.w	sa_masterVolume,d0
	mulu.w	d0,d1
	asr.l	#6,d1
	moveq.l	#0,d0
	move.w	142(a4),d0
	mulu.w	d1,d0
	asr.l	#6,d0
	move.w	d0,8(a3)
	asl.w	#2,d0
	move.w	d0,178(a4)
	move.l	d7,d0
	rol.l	#8,d0
	andi.w	#$ff,d0
	cmp.w	#128,d0
	bne.s	.Skip25
	move.w	158(a4),d0
	cmp.w	44(a5),d0
	blt.s	.Skip25
	tst.w	46(a5)
	beq.s	.Skip27
	tst.w	160(a4)
	beq.s	.Skip24
	subq.w	#1,160(a4)
	bra.s	.Skip27
.Skip24:
	move.w	46(a5),160(a4)
.Skip25:
	subq.w	#1,162(a4)
	bne.s	.Skip27
	move.w	38(a5),162(a4)
	addq.w	#1,158(a4)
	cmp.w	158(a4),d2
	bgt.s	.Skip27
	move.w	40(a5),d0
	tst.w	42(a5)
	bne.s	.Skip26
	subq.w	#1,d0
.Skip26:
	move.w	d0,158(a4)
	tst.w	42(a5)
	bne.s	.Skip27
	tst.b	d1
	bne.s	.Skip27
	bset.b	#0,181(a4)
.Skip27:
	move.w	144(a4),d0
	move.w	142(a4),d1
	add.w	d0,d1
	tst.w	d1
	bge.s	.Skip28
	moveq.l	#0,d1
	bra.s	.Exit2
.Skip28:
	cmp.w	#64,d1
	bls.s	.Exit2
	move.w	#64,d1
.Exit2:
	move.w	d1,142(a4)
	rts

Switch_instrument_effect_jump_offsets:
	dc.w	$57e

sa_synthEffectTable:
	; unsigned short
	dc.w	2
	; unsigned short
	dc.w	$12
	; unsigned short
	dc.w	$da
	; unsigned short
	dc.w	$128
	; unsigned short
	dc.w	$14a
	; unsigned short
	dc.w	$1b6
	; unsigned short
	dc.w	$1ec
	; unsigned short
	dc.w	$256
	; unsigned short
	dc.w	$2b4
	; unsigned short
	dc.w	$3b6
	; unsigned short
	dc.w	$3d2
	; unsigned short
	dc.w	$474
	; unsigned short
	dc.w	$4b4
	; unsigned short
	dc.w	$506
	; unsigned short
	dc.w	$282
	; unsigned short
	dc.w	$488
	; unsigned short
	dc.w	$388

;*****************************************************************************
; [ SA_ApplySynthEffect ]
;*****************************************************************************
SA_ApplySynthEffect:
	subq.w	#1,172(a4)
	bne.w	SA_ApplySynthEffect_None
	move.w	72(a5),172(a4)
	moveq.l	#0,d0
	move.w	66(a5),d0
	tst.w	d0
	ble.w	SA_ApplySynthEffect_None
	cmp.w	#17,d0
	bgt.w	SA_ApplySynthEffect_None
	asl.w	#1,d0
	lea.l	Switch_instrument_effect_jump_offsets,a0
	move.w	0(a0,d0.w),d0
	lea.l	Switch_instrument_effect(pc,d0.w),a0

;*****************************************************************************
; [ Switch_instrument_effect ]
;*****************************************************************************
Switch_instrument_effect:
	jmp	(a0)

;*****************************************************************************
; [ SA_ApplySynthEffect_WaveNegator ]
;*****************************************************************************
SA_ApplySynthEffect_WaveNegator:
	lea.l	(a4),a0
	moveq.l	#0,d0
	move.w	168(a4),d0
	neg.b	0(a0,d0.w)
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_FreeNegator ]
;*****************************************************************************
SA_ApplySynthEffect_FreeNegator:
	move.l	d4,-(sp)
	btst.b	#2,181(a4)
	bne.w	.Skip5
	lea.l	(a4),a0
	move.l	sa_synthTable,a1
	moveq.l	#0,d0
	move.w	64(a5),d0
	asl.w	#7,d0
	lea.l	0(a1,d0.l),a1
	move.w	170(a4),d0
	move.b	0(a1,d0.w),d0
	andi.w	#$7f,d0
	move.w	d0,d4
	move.l	sa_synthTable,a1
	moveq.l	#0,d1
	move.w	2(a5),d1
	asl.w	#7,d1
	lea.l	0(a1,d1.w),a1
	move.w	4(a5),d1
	asl.w	#1,d1
	lea.l	0(a0,d1.w),a0
	lea.l	0(a1,d1.w),a1
	tst.w	d1
	bra.s	.Skip
.Loop:
	cmp.w	d1,d0
	bgt.s	.Skip2
	move.l	-(a1),-(a0)
	subq.w	#4,d1
.Skip:
	bgt.s	.Loop
.Skip2:
	sub.w	d1,d0
	add.w	d0,d1
	lea.l	0(a1,d0.w),a1
	lea.l	0(a0,d0.w),a0
	tst.w	d1
	ble.s	.Skip4
	btst.l	#0,d0
	beq.s	.Loop2
	move.b	-(a1),d0
	neg.b	d0
	move.b	d0,-(a0)
	subq.w	#1,d1
	bra.s	.Skip3
.Loop2:
	move.l	-(a1),d0
	neg.b	d0
	move.b	d0,-(a0)
	ror.l	#8,d0
	neg.b	d0
	move.b	d0,-(a0)
	ror.l	#8,d0
	neg.b	d0
	move.b	d0,-(a0)
	ror.l	#8,d0
	neg.b	d0
	move.b	d0,-(a0)
	subq.w	#4,d1
.Skip3:
	bgt.s	.Loop2
.Skip4:
	addq.w	#1,170(a4)
	move.w	68(a5),d0
	add.w	70(a5),d0
	move.w	170(a4),d1
	cmp.w	d0,d1
	bls.s	.Skip5
	move.w	68(a5),170(a4)
	tst.w	70(a5)
	bne.s	.Skip5
	tst.b	d4
	bne.s	.Skip5
	bset.b	#2,181(a4)
.Skip5:
	move.l	(sp)+,d4
	bra.w	SA_ApplySynthEffect_None

;*****************************************************************************
; [ SA_ApplySynthEffect_RotateVert ]
;*****************************************************************************
SA_ApplySynthEffect_RotateVert:
	lea.l	(a4),a0
	moveq.l	#0,d0
	move.w	70(a5),d0
	move.w	64(a5),d1
	move.w	68(a5),d2
	sub.w	d2,d0
	lea.l	0(a0,d2.w),a0
	btst.l	#0,d2
	beq.s	.Skip
	add.b	d1,(a0)+
	subq.w	#1,d0
	bmi.s	.Skip3
	bra.s	.Skip
.Loop:
	move.l	(a0),d2
	rol.l	#8,d2
	add.b	d1,d2
	rol.l	#8,d2
	add.b	d1,d2
	rol.l	#8,d2
	add.b	d1,d2
	rol.l	#8,d2
	add.b	d1,d2
	move.l	d2,(a0)+
	subq.w	#4,d0
.Skip:
	cmp.w	#3,d0
	bpl.s	.Loop
	tst.w	d0
	bra.s	.Skip2
.Loop2:
	add.b	d1,(a0)+
	subq.w	#1,d0
.Skip2:
	bpl.s	.Loop2
.Skip3:
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_RotateHori ]
;*****************************************************************************
SA_ApplySynthEffect_RotateHori:
	lea.l	(a4),a0
	moveq.l	#0,d0
	move.w	70(a5),d0
	move.w	68(a5),d1
	lea.l	0(a0,d1.w),a0
	sub.w	d1,d0
	move.b	(a0),d1
.Loop:
	move.b	1(a0),(a0)+
	subq.w	#1,d0
	bpl.s	.Loop
	move.b	d1,(a0)
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_AlienVoice ]
;*****************************************************************************
SA_ApplySynthEffect_AlienVoice:
	lea.l	(a4),a0
	move.l	sa_synthTable,a1
	moveq.l	#0,d0
	move.w	64(a5),d0
	asl.w	#7,d0
	lea.l	0(a1,d0.w),a1
	move.w	70(a5),d1
	move.w	68(a5),d0
	lea.l	0(a0,d0.w),a0
	lea.l	0(a1,d0.w),a1
	sub.w	d0,d1
	btst.l	#0,d0
	beq.s	.Skip
	move.b	(a1)+,d2
	add.b	d2,(a0)+
	dbra	d1,.Skip
	bra.s	.Skip3
.Loop:
	move.l	(a0),d2
	move.l	(a1)+,d0
	rol.l	#8,d0
	rol.l	#8,d2
	add.b	d0,d2
	rol.l	#8,d0
	rol.l	#8,d2
	add.b	d0,d2
	rol.l	#8,d0
	rol.l	#8,d2
	add.b	d0,d2
	rol.l	#8,d0
	rol.l	#8,d2
	add.b	d0,d2
	move.l	d2,(a0)+
	subq.w	#4,d1
.Skip:
	cmp.w	#3,d1
	bpl.s	.Loop
	tst.w	d1
	bra.s	.Skip2
.Loop2:
	move.b	(a1)+,d2
	add.b	d2,(a0)+
	subq.w	#1,d1
.Skip2:
	bpl.s	.Loop2
.Skip3:
	bra.w	SA_ApplySynthEffect_None

;*****************************************************************************
; [ SA_ApplySynthEffect_PolyNegato ]
;*****************************************************************************
SA_ApplySynthEffect_PolyNegato:
	lea.l	(a4),a0
	move.l	sa_synthTable,a1
	moveq.l	#0,d0
	move.w	2(a5),d0
	asl.w	#7,d0
	lea.l	0(a1,d0.w),a1
	moveq.l	#0,d0
	move.w	168(a4),d0
	move.b	0(a1,d0.w),0(a0,d0.w)
	move.w	70(a5),d1
	cmp.w	d1,d0
	blt.s	.Skip
	move.w	68(a5),d0
	subq.w	#1,d0
.Skip:
	neg.b	1(a0,d0.w)
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_ShackWave1 ]
;*****************************************************************************
SA_ApplySynthEffect_ShackWave1:
	bsr.s	SA_ApplySynthEffect_ShackWave
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_ShackWave ]
;*****************************************************************************
SA_ApplySynthEffect_ShackWave:
	lea.l	(a4),a0
	move.l	sa_synthTable,a1
	moveq.l	#0,d0
	move.w	64(a5),d0
	asl.w	#7,d0
	lea.l	0(a1,d0.w),a1
	add.w	68(a5),a1
	move.w	168(a4),d0
	move.b	0(a1,d0.w),d2
	move.w	70(a5),d1
	move.w	68(a5),d0
	lea.l	0(a0,d0.w),a0
	sub.w	d0,d1
	btst.l	#0,d0
	beq.s	.Skip
	add.b	d2,(a0)+
	dbra	d1,.Skip
	bra.s	.Exit
.Loop:
	move.l	(a0),d0
	rol.l	#8,d0
	add.b	d2,d0
	rol.l	#8,d0
	add.b	d2,d0
	rol.l	#8,d0
	add.b	d2,d0
	rol.l	#8,d0
	add.b	d2,d0
	move.l	d0,(a0)+
	subq.w	#4,d1
.Skip:
	cmp.w	#3,d1
	bpl.s	.Loop
	tst.w	d1
	bra.s	.Skip2
.Loop2:
	add.b	d2,(a0)+
	subq.w	#1,d1
.Skip2:
	bpl.s	.Loop2
.Exit:
	rts

;*****************************************************************************
; [ SA_ApplySynthEffect_ShackWave2 ]
;*****************************************************************************
SA_ApplySynthEffect_ShackWave2:
	bsr.s	SA_ApplySynthEffect_ShackWave
	lea.l	(a4),a0
	move.w	68(a5),d1
	lea.l	0(a0,d1.w),a0
	move.w	170(a4),d0
	neg.b	0(a0,d0.w)
	addq.w	#1,170(a4)
	move.w	70(a5),d0
	sub.w	d1,d0
	cmp.w	170(a4),d0
	bpl.s	.Skip
	clr.w	170(a4)
.Skip:
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_Oszilator1 ]
;*****************************************************************************
SA_ApplySynthEffect_Oszilator1:
	move.l	d4,-(sp)
	btst.b	#1,181(a4)
	beq.s	.Skip
	bchg.b	#3,181(a4)
	bclr.b	#1,181(a4)
.Skip:
	btst.b	#3,181(a4)
	beq.s	SA_oszilator_skip
	move.l	sa_synthTable,a1
	moveq.l	#0,d0
	move.w	2(a5),d0
	asl.w	#7,d0
	lea.l	0(a1,d0.w),a1
	bra.s	SA_oszilator_next

;*****************************************************************************
; [ SA_ApplySynthEffect_Metamorph ]
;*****************************************************************************
SA_ApplySynthEffect_Metamorph:
	move.l	d4,-(sp)
	btst.b	#1,181(a4)
	bne.w	SA_synth_effect_end
SA_oszilator_skip:
	move.l	sa_synthTable,a1
	moveq.l	#0,d0
	move.w	64(a5),d0
	asl.w	#7,d0
	lea.l	0(a1,d0.w),a1
SA_oszilator_next:
	moveq.l	#0,d4
	lea.l	(a4),a0
	move.w	70(a5),d1
	move.w	68(a5),d0
	lea.l	0(a0,d0.w),a0
	lea.l	0(a1,d0.w),a1
	sub.w	d0,d1
	btst.l	#0,d0
	beq.s	.Skip13
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	beq.s	.Skip3
	st	d4
	blt.s	.Skip
	subq.b	#1,d0
	bra.s	.Skip2
.Skip:
	addq.b	#1,d0
.Skip2:
	move.b	d0,-1(a0)
.Skip3:
	dbra	d1,.Skip13
	bra.s	.Skip18
.Loop:
	move.l	(a0)+,d0
	move.l	(a1)+,d2
	cmp.l	d0,d2
	beq.s	.Skip12
	st	d4
	cmp.b	d2,d0
	beq.s	.Skip5
	blt.s	.Skip4
	subq.b	#1,d0
	bra.s	.Skip5
.Skip4:
	addq.b	#1,d0
.Skip5:
	ror.l	#8,d0
	ror.l	#8,d2
	cmp.b	d2,d0
	beq.s	.Skip7
	blt.s	.Skip6
	subq.b	#1,d0
	bra.s	.Skip7
.Skip6:
	addq.b	#1,d0
.Skip7:
	ror.l	#8,d0
	ror.l	#8,d2
	cmp.b	d2,d0
	beq.s	.Skip9
	blt.s	.Skip8
	subq.b	#1,d0
	bra.s	.Skip9
.Skip8:
	addq.b	#1,d0
.Skip9:
	ror.l	#8,d0
	ror.l	#8,d2
	cmp.b	d2,d0
	beq.s	.Skip11
	blt.s	.Skip10
	subq.b	#1,d0
	bra.s	.Skip11
.Skip10:
	addq.b	#1,d0
.Skip11:
	ror.l	#8,d0
	move.l	d0,-4(a0)
.Skip12:
	subq.w	#4,d1
.Skip13:
	cmp.w	#3,d1
	bpl.s	.Loop
	tst.w	d1
	bra.s	.Skip17
.Loop2:
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	beq.s	.Skip16
	st	d4
	blt.s	.Skip14
	subq.b	#1,d0
	bra.s	.Skip15
.Skip14:
	addq.b	#1,d0
.Skip15:
	move.b	d0,-1(a0)
.Skip16:
	subq.w	#1,d1
.Skip17:
	bpl.s	.Loop2
.Skip18:
	tst.b	d4
	bne.s	SA_synth_effect_end
	bset.b	#1,181(a4)
SA_synth_effect_end:
	move.l	(sp)+,d4
	bra.w	SA_ApplySynthEffect_None

;*****************************************************************************
; [ SA_ApplySynthEffect_FmDrum ]
;*****************************************************************************
SA_ApplySynthEffect_FmDrum:
	move.w	70(a5),d0
	cmp.w	170(a4),d0
	bls.s	SA_ApplySynthEffect_Case280
SA_effect_exit:
	move.w	68(a5),d0
	move.w	64(a5),d1
	mulu.w	d0,d1
	sub.w	d1,132(a4)
	addq.w	#1,170(a4)
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_Case280 ]
;*****************************************************************************
SA_ApplySynthEffect_Case280:
	move.w	18(a5),132(a4)
	moveq.l	#0,d0
	move.w	d0,170(a4)
	bra.s	SA_effect_exit

;*****************************************************************************
; [ SA_ApplySynthEffect_LaserAmf ]
;*****************************************************************************
SA_ApplySynthEffect_LaserAmf:
	move.w	70(a5),d0
	cmp.w	170(a4),d0
	bls.s	.Skip
	move.w	68(a5),d1
	ext.w	d1
	add.w	d1,132(a4)
	addq.w	#1,170(a4)
.Skip:
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_WaveAlias ]
;*****************************************************************************
SA_ApplySynthEffect_WaveAlias:
	movem.l	d4,-(sp)
	lea.l	(a4),a0
	moveq.l	#0,d0
	move.w	64(a5),d2
	move.w	70(a5),d1
	move.w	68(a5),d0
	lea.l	0(a0,d0.w),a0
	sub.w	d0,d1
	btst.l	#0,d0
	beq.s	.Skip11
	move.b	(a0),d0
	cmp.b	1(a0),d0
	bgt.s	.Skip
	add.b	d2,d0
	bra.s	.Skip2
.Skip:
	sub.w	d2,d0
.Skip2:
	move.b	d0,(a0)+
	dbra	d1,.Skip11
	bra.s	.Skip15
.Loop:
	move.l	(a0),d0
	move.l	d0,d4
	rol.l	#8,d4
	move.b	4(a0),d4
	rol.l	#8,d0
	rol.l	#8,d4
	cmp.b	d4,d0
	bgt.s	.Skip3
	add.w	d2,d0
	bra.s	.Skip4
.Skip3:
	sub.w	d2,d0
.Skip4:
	rol.l	#8,d0
	rol.l	#8,d4
	cmp.b	d4,d0
	bgt.s	.Skip5
	add.w	d2,d0
	bra.s	.Skip6
.Skip5:
	sub.w	d2,d0
.Skip6:
	rol.l	#8,d0
	rol.l	#8,d4
	cmp.b	d4,d0
	bgt.s	.Skip7
	add.w	d2,d0
	bra.s	.Skip8
.Skip7:
	sub.w	d2,d0
.Skip8:
	rol.l	#8,d0
	rol.l	#8,d4
	cmp.b	d4,d0
	bgt.s	.Skip9
	add.w	d2,d0
	bra.s	.Skip10
.Skip9:
	sub.w	d2,d0
.Skip10:
	move.l	d0,(a0)+
	subq.w	#4,d1
.Skip11:
	cmp.w	#3,d1
	bpl.s	.Loop
	tst.w	d1
	bra.s	.Skip14
.Loop2:
	move.b	(a0),d0
	cmp.b	1(a0),d0
	bgt.s	.Skip12
	add.w	d2,d0
	bra.s	.Skip13
.Skip12:
	sub.w	d2,d0
.Skip13:
	move.b	d0,(a0)+
	subq.w	#1,d1
.Skip14:
	bpl.s	.Loop2
.Skip15:
	movem.l	(sp)+,d4
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_NoiseGen1 ]
;*****************************************************************************
SA_ApplySynthEffect_NoiseGen1:
	lea.l	(a4),a0
	move.w	168(a4),d1
	move.b	$dff007,d0
	eor.b	d0,0(a0,d1.w)
	bra.w	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_NoiseGen2 ]
;*****************************************************************************
SA_ApplySynthEffect_NoiseGen2:
	lea.l	(a4),a0
	move.w	70(a5),d1
	move.w	68(a5),d0
	lea.l	0(a0,d0.w),a0
	sub.w	d0,d1
.Loop:
	move.b	0(a0,d1.w),d0
	eori.b	#5,d0
	rol.b	#2,d0
	add.b	$dff007,d0
	move.b	d0,0(a0,d1.w)
	subq.w	#1,d1
	bpl.s	.Loop
	bra.w	SA_ApplySynthEffect_None

;*****************************************************************************
; [ SA_ApplySynthEffect_LowPassF1 ]
;*****************************************************************************
SA_ApplySynthEffect_LowPassF1:
	move.l	d4,-(sp)
	lea.l	(a4),a0
	moveq.l	#0,d0
	move.w	64(a5),d4
	move.w	70(a5),d1
	move.w	68(a5),d0
	lea.l	0(a0,d1.w),a1
	lea.l	0(a0,d0.w),a0
	move.l	a0,a2
.Loop:
	sf	d2
	move.b	(a0),d0
	cmp.l	a1,a0
	bne.s	.Skip
	move.b	(a2),d1
	bra.s	.Skip2
.Skip:
	move.b	1(a0),d1
.Skip2:
	cmp.b	d1,d0
	bgt.s	.Skip3
	st	d2
.Skip3:
	sub.b	d1,d0
	bpl.s	.Skip4
	neg.b	d0
.Skip4:
	move.w	d4,d1
	cmp.w	d1,d0
	ble.s	.Skip6
	tst.b	d2
	bne.s	.Skip5
	subq.b	#2,(a0)
	bra.s	.Skip6
.Skip5:
	addq.b	#2,(a0)
.Skip6:
	addq.l	#1,a0
	cmp.l	a0,a1
	bge.s	.Loop
	move.l	(sp)+,d4
	bra.s	SA_AdvanceSynthEffectPos

;*****************************************************************************
; [ SA_ApplySynthEffect_LowPassF2 ]
;*****************************************************************************
SA_ApplySynthEffect_LowPassF2:
	move.l	sa_synthTable,a6
	moveq.l	#0,d0
	move.w	64(a5),d0
	asl.l	#7,d0
	lea.l	0(a6,d0.l),a6
	lea.l	(a4),a0
	moveq.l	#0,d0
	move.w	70(a5),d0
	lea.l	0(a0,d0.w),a1
	lea.l	0(a6,d0.w),a6
	move.w	68(a5),d0
	lea.l	0(a0,d0.w),a0
	move.l	a0,a2
.Loop:
	sf	d2
	move.b	(a0),d0
	cmp.l	a1,a0
	bne.s	.Skip
	move.b	(a2),d1
	bra.s	.Skip2
.Skip:
	move.b	1(a0),d1
.Skip2:
	cmp.b	d1,d0
	bgt.s	.Skip3
	st	d2
.Skip3:
	sub.b	d1,d0
	bpl.s	.Skip4
	neg.b	d0
.Skip4:
	moveq.l	#0,d1
	move.b	(a6)+,d1
	andi.w	#$7f,d1
	cmp.w	d1,d0
	ble.s	.Skip6
	tst.b	d2
	bne.s	.Skip5
	subq.b	#2,(a0)
	bra.s	.Skip6
.Skip5:
	addq.b	#2,(a0)
.Skip6:
	addq.l	#1,a0
	cmp.l	a0,a1
	bge.s	.Loop

;*****************************************************************************
; [ SA_AdvanceSynthEffectPos ]
;*****************************************************************************
SA_AdvanceSynthEffectPos:
	addq.w	#1,168(a4)
	move.w	168(a4),d0
	cmp.w	70(a5),d0
	bls.s	SA_ApplySynthEffect_None
	move.w	68(a5),168(a4)

;*****************************************************************************
; [ SA_ApplySynthEffect_None ]
;*****************************************************************************
SA_ApplySynthEffect_None:
	rts

;*****************************************************************************
; [ SA_Insert ]
;*****************************************************************************
SA_Insert:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	d0,d7
	lea.l	sa_insertLockTime,a0
	lea.l	0(a0,d1.w),a0
	lea.l	0(a0,d1.w),a0
	move.l	d2,(a0)
	moveq.l	#1,d2
	lsl.l	d1,d2
	move.l	d1,d0
	asl.l	#2,d0
	lea.l	sa_overNoteVal,a0
	clr.l	0(a0,d0.l)
	move.l	d1,d0
	add.l	d0,d0
	lea.l	sa_overTranspose,a0
	clr.w	0(a0,d0.l)
	lea.l	sa_voiceCons,a0
	lea.l	0(a0,d1.w),a0
	lea.l	0(a0,d1.w),a0
	lea.l	sa_sampleRepeat,a2
	lea.l	0(a2,d1.w),a2
	lea.l	sa_track,a4
	move.l	d1,d0
	mulu.w	#206,d0
	lea.l	0(a4,d0.w),a4
	lea.l	Custom+aud0+ac_ptr,a3
	move.l	d1,d0
	lsl.l	#4,d0
	lea.l	0(a3,d0.w),a3
	move.l	4,a6		; Exec base
	jsr	_LVODisable(a6)
	bsr.w	SA_AdvanceTrack
	bsr.w	SA_ProcessSong
	ori.w	#-$8000,d5
	move.w	d5,Custom+dmacon
	move.l	4,a6		; Exec base
	jsr	_LVOEnable(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts


	SECTION	Chip_DATA,data_c
sa_notePeriod:
	dc.w	0,$3580,$3280,$2fa0,$2d00,$2a60,$2800,$25c0
	dc.w	$23a0,$21a0,$1fc0,$1e00,$1c50,$1ac0,$1940,$17d0
	dc.w	$1680,$1530,$1400,$12e0,$11d0,$10d0,$fe0,$f00
	dc.w	$e28,$d60,$ca0,$be8,$b40,$a98,$a00,$970
	dc.w	$8e8,$868,$7f0,$780,$714,$6b0,$650,$5f4
	dc.w	$5a0,$54c,$500,$4b8,$474,$434,$3f8,$3c0
	dc.w	$38a,$358,$328,$2fa,$2d0,$2a6,$280,$25c
	dc.w	$23a,$21a,$1fc,$1e0,$1c5,$1ac,$194,$17d
	dc.w	$168,$153,$140,$12e,$11d,$10d,$fe,$f0
	dc.w	$e2,$d6,$ca,$be,$b4,$aa,$a0,$97
	dc.w	$8f,$87,$7f,$78,$71,$6b,$65,$5f
	dc.w	$5a,$55,$50,$4b,$47,$43,$3f,$3c
	dc.w	$38,$35,$32,$2f,$2d,$2a,$28,$25
	dc.w	$23,$21,$1f,$1e,$1c,-$1
sa_Vibrato:
	dc.b	0,3,6,9,$c,$10,$13,$16,$19,$1c,$1f,$22,$25,$28,$2b,$2e
	dc.b	$31,$34,$36,$39,$3c,$3f,$42,$44,$47,$49,$4c,$4e,$51,$53,$56,$58
	dc.b	$5a,$5c,$5e,$60,$62,$64,$66,$68,$6a,$6c,$6d,$6f,$70,$72,$73,$74
	dc.b	$76,$77,$78,$79,$7a,$7b,$7b,$7c,$7d,$7d,$7e,$7e,$7e,$7f,$7f,$7f
	dc.b	$7f,$7f,$7f,$7f,$7e,$7e,$7d,$7d,$7c,$7c,$7b,$7a,$79,$78,$77,$76
	dc.b	$75,$74,$72,$71,$70,$6e,$6c,$6b,$69,$67,$65,$63,$61,$5f,$5d,$5b
	dc.b	$59,$57,$54,$52,$50,$4d,$4b,$48,$45,$43,$40,$3d,$3b,$38,$35,$32
	dc.b	$2f,$2c,$29,$27,$24,$20,$1d,$1a,$17,$14,$11,$e,$b,8,5,2
	dc.b	-$1,-$4,-$7,-$a,-$e,-$11,-$14,-$17,-$1a,-$1d,-$20,-$23,-$26,-$29,-$2c,-$2f
	dc.b	-$32,-$35,-$37,-$3a,-$3d,-$40,-$42,-$45,-$48,-$4a,-$4d,-$4f,-$52,-$54,-$56,-$58
	dc.b	-$5b,-$5d,-$5f,-$61,-$63,-$65,-$67,-$68,-$6a,-$6c,-$6d,-$6f,-$70,-$72,-$73,-$74
	dc.b	-$76,-$77,-$78,-$79,-$7a,-$7a,-$7b,-$7c,-$7c,-$7d,-$7d,-$7e,-$7e,-$7e,-$7e,-$7e
	dc.b	-$7e,-$7e,-$7e,-$7e,-$7e,-$7d,-$7d,-$7c,-$7c,-$7b,-$7a,-$79,-$78,-$77,-$76,-$75
	dc.b	-$74,-$73,-$71,-$70,-$6e,-$6d,-$6b,-$69,-$68,-$66,-$64,-$62,-$60,-$5e,-$5c,-$5a
	dc.b	-$57,-$55,-$53,-$50,-$4e,-$4b,-$49,-$46,-$44,-$41,-$3e,-$3c,-$39,-$36,-$33,-$30
	dc.b	-$2d,-$2a,-$27,-$25,-$22,-$1e,-$1b,-$18,-$15,-$12,-$f,-$c,-$9,-$6,-$3,0
	dc.b	0,0
sa_track:
	dcb.b	127,0
	dc.b	0		; SapcSynthWave.data ; SarpTrack.SynthWave
	dc.w	0		; SarpTrack.CurrNote
	dc.w	0		; SarpTrack.PrevNote
	dc.w	0		; SarpTrack.FineTuning
	dc.w	0		; SarpTrack.PitchBend
	dc.w	0		; SarpTrack.InstNum
	dc.l	0		; SarpTrack.InstPtr
	dc.w	0		; SarpTrack.Volume
	dc.w	0		; SarpTrack.VolumeSlide
	dc.w	0		; SarpTrack.VibratoPos
	dc.w	0		; SarpTrack.VibratoDelay
	dc.w	0		; SarpTrack.VibratoSpeed
	dc.w	0		; SarpTrack.VibratoLevel
	dc.w	0		; SarpTrack.PortamentoValue
	dc.w	0		; SarpTrack.Portamento
	dc.w	0		; SarpTrack.AdsrPos
	dc.w	0		; SarpTrack.SustainPos
	dc.w	0		; SarpTrack.AdsrDelay
	dc.w	0		; SarpTrack.AmfPos
	dc.w	0		; SarpTrack.AmfDelay
	dc.w	0		; SarpTrack.SynthEffectPos
	dc.w	0		; SarpTrack.SynthPos
	dc.w	0		; SarpTrack.SynthDelay
	dc.w	0		; SarpTrack.ArpeggioPos
	dc.w	0		; SarpTrack.SimpleArpeggioPos
	dc.w	0		; SarpTrack.VolumeLevel
	dc.b	0
	dc.b	0		; SapcByteWord.value ; SarpTrack.Flags
	dc.w	0		; SarpTrack.DmaCon
	dc.w	0		; SarpTrack.SampleLength
	dc.w	0		; SarpTrack.SyntheticMode
	dc.l	0		; SarpTrack.SampleData
	dc.w	0,0,0,0,0,0,0
	dcb.b	127,0
	dc.b	0		; SapcSynthWave.data ; SarpTrack.SynthWave
	dc.w	0		; SarpTrack.CurrNote
	dc.w	0		; SarpTrack.PrevNote
	dc.w	0		; SarpTrack.FineTuning
	dc.w	0		; SarpTrack.PitchBend
	dc.w	0		; SarpTrack.InstNum
	dc.l	0		; SarpTrack.InstPtr
	dc.w	0		; SarpTrack.Volume
	dc.w	0		; SarpTrack.VolumeSlide
	dc.w	0		; SarpTrack.VibratoPos
	dc.w	0		; SarpTrack.VibratoDelay
	dc.w	0		; SarpTrack.VibratoSpeed
	dc.w	0		; SarpTrack.VibratoLevel
	dc.w	0		; SarpTrack.PortamentoValue
	dc.w	0		; SarpTrack.Portamento
	dc.w	0		; SarpTrack.AdsrPos
	dc.w	0		; SarpTrack.SustainPos
	dc.w	0		; SarpTrack.AdsrDelay
	dc.w	0		; SarpTrack.AmfPos
	dc.w	0		; SarpTrack.AmfDelay
	dc.w	0		; SarpTrack.SynthEffectPos
	dc.w	0		; SarpTrack.SynthPos
	dc.w	0		; SarpTrack.SynthDelay
	dc.w	0		; SarpTrack.ArpeggioPos
	dc.w	0		; SarpTrack.SimpleArpeggioPos
	dc.w	0		; SarpTrack.VolumeLevel
	dc.b	0
	dc.b	0		; SapcByteWord.value ; SarpTrack.Flags
	dc.w	0		; SarpTrack.DmaCon
	dc.w	0		; SarpTrack.SampleLength
	dc.w	0		; SarpTrack.SyntheticMode
	dc.l	0		; SarpTrack.SampleData
	dc.w	0,0,0,0,0,0,0
	dcb.b	127,0
	dc.b	0		; SapcSynthWave.data ; SarpTrack.SynthWave
	dc.w	0		; SarpTrack.CurrNote
	dc.w	0		; SarpTrack.PrevNote
	dc.w	0		; SarpTrack.FineTuning
	dc.w	0		; SarpTrack.PitchBend
	dc.w	0		; SarpTrack.InstNum
	dc.l	0		; SarpTrack.InstPtr
	dc.w	0		; SarpTrack.Volume
	dc.w	0		; SarpTrack.VolumeSlide
	dc.w	0		; SarpTrack.VibratoPos
	dc.w	0		; SarpTrack.VibratoDelay
	dc.w	0		; SarpTrack.VibratoSpeed
	dc.w	0		; SarpTrack.VibratoLevel
	dc.w	0		; SarpTrack.PortamentoValue
	dc.w	0		; SarpTrack.Portamento
	dc.w	0		; SarpTrack.AdsrPos
	dc.w	0		; SarpTrack.SustainPos
	dc.w	0		; SarpTrack.AdsrDelay
	dc.w	0		; SarpTrack.AmfPos
	dc.w	0		; SarpTrack.AmfDelay
	dc.w	0		; SarpTrack.SynthEffectPos
	dc.w	0		; SarpTrack.SynthPos
	dc.w	0		; SarpTrack.SynthDelay
	dc.w	0		; SarpTrack.ArpeggioPos
	dc.w	0		; SarpTrack.SimpleArpeggioPos
	dc.w	0		; SarpTrack.VolumeLevel
	dc.b	0
	dc.b	0		; SapcByteWord.value ; SarpTrack.Flags
	dc.w	0		; SarpTrack.DmaCon
	dc.w	0		; SarpTrack.SampleLength
	dc.w	0		; SarpTrack.SyntheticMode
	dc.l	0		; SarpTrack.SampleData
	dc.w	0,0,0,0,0,0,0
	dcb.b	127,0
	dc.b	0		; SapcSynthWave.data ; SarpTrack.SynthWave
	dc.w	0		; SarpTrack.CurrNote
	dc.w	0		; SarpTrack.PrevNote
	dc.w	0		; SarpTrack.FineTuning
	dc.w	0		; SarpTrack.PitchBend
	dc.w	0		; SarpTrack.InstNum
	dc.l	0		; SarpTrack.InstPtr
	dc.w	0		; SarpTrack.Volume
	dc.w	0		; SarpTrack.VolumeSlide
	dc.w	0		; SarpTrack.VibratoPos
	dc.w	0		; SarpTrack.VibratoDelay
	dc.w	0		; SarpTrack.VibratoSpeed
	dc.w	0		; SarpTrack.VibratoLevel
	dc.w	0		; SarpTrack.PortamentoValue
	dc.w	0		; SarpTrack.Portamento
	dc.w	0		; SarpTrack.AdsrPos
	dc.w	0		; SarpTrack.SustainPos
	dc.w	0		; SarpTrack.AdsrDelay
	dc.w	0		; SarpTrack.AmfPos
	dc.w	0		; SarpTrack.AmfDelay
	dc.w	0		; SarpTrack.SynthEffectPos
	dc.w	0		; SarpTrack.SynthPos
	dc.w	0		; SarpTrack.SynthDelay
	dc.w	0		; SarpTrack.ArpeggioPos
	dc.w	0		; SarpTrack.SimpleArpeggioPos
	dc.w	0		; SarpTrack.VolumeLevel
	dc.b	0
	dc.b	0		; SapcByteWord.value ; SarpTrack.Flags
	dc.w	0		; SarpTrack.DmaCon
	dc.w	0		; SarpTrack.SampleLength
	dc.w	0		; SarpTrack.SyntheticMode
	dc.l	0		; SarpTrack.SampleData
	dc.w	0,0,0,0,0,0,0
sa_silence:
	dc.w	0,0,0,0
sa_songTable:
	dc.l	0
sa_overTable:
	dc.l	0
sa_noteTable:
	dc.l	0
sa_instTab:
	dc.l	0
sa_synthTable:
	dc.l	0
sa_amfTable:
	dc.l	0
sa_adsrTable:
	dc.l	0
sa_sampleTable:
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
sa_song:
	dc.w	0		; SapcSong.song_speed
	dc.w	0		; SapcSong.pattern_length
	dc.w	0		; SapcSong.start_position
	dc.w	0		; SapcSong.stop_position
	dc.w	0		; SapcSong.repeat_position
	dc.w	0		; SapcSong.irq_per_second
sa_songState:
	dc.w	0
sa_sampleRepeat:
	dc.b	0,0,0,0
sa_insertLockTime:
	dc.w	0,0,0,0
sa_songSpeedPos:
	dc.w	0
sa_overPatternPos:
	dc.w	0
sa_overLinePos:
	dc.w	0
sa_overTranspose:
	dc.b	0		; SapcTranspose.inst
	dc.b	0		; SapcTranspose.note
	dc.b	0		; SapcTranspose.inst
	dc.b	0		; SapcTranspose.note
	dc.b	0		; SapcTranspose.inst
	dc.b	0		; SapcTranspose.note
	dc.b	0		; SapcTranspose.inst
	dc.b	0		; SapcTranspose.note
sa_overNotePtr:
	dc.l	0,0,0,0
sa_overNoteVal:
	dc.l	0,0,0,0
sa_dmaConValue:
	dc.w	0
