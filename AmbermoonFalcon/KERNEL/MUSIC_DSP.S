; Falcon kernel : the music player on the DSP (see MUSIC.S, DSP_MIX.ASM)
;
; The replay of Sonic Arranger runs on the CPU as usual and writes the emulated
; Paula. Here :
;   - [ Paula_new_song ] loads the samples of a song into the memory of the DSP.
;   - [ Dsp_VBL ] sends the registers of the 4 channels in every vertical blank,
;     and the waves of the synthetic instruments when they have changed.
;   - The DSP mixes and sends the sound directly to the DAC : no sound buffer.
;
; The bytes in the DSP (3 in a word) : silence, 4 waves, the samples.

Dsp_ISR		EQU	$ffffa202		; Bit 0 : a word from the DSP, bit 1 : free
Dsp_data		EQU	$ffffa204		; (.l : the low 3 bytes are the word)
Dsp_RXDF		EQU	0
Dsp_TXDE		EQU	1

Dsp_silence_words	EQU	4
Dsp_wave_words	EQU	43			; (129 bytes : a wave has 128)
Dsp_first_sample	EQU	Dsp_silence_words+4*Dsp_wave_words
Dsp_bank_words	EQU	$3e00			; Y:$200-$3fff, then X:$200-$3fff
Dsp_bytes		EQU	2*Dsp_bank_words*3
Sa_track_size	EQU	206			; (the wave at the start of a track)
Sa_wave_size	EQU	128

	SECTION	Program,code

;*****************************************************************************
; [ Start the DSP ]
;  OUT : Z set if there is a DSP which answers
; Changed registers : d0, d1, d2, a0
; NOTE :
;   - The reset is bit 4 of port A of the sound chip, then the DSP loads 512
;     words from the host (its bootstrap).
;*****************************************************************************
Dsp_start:
	move.w	sr,-(sp)
	ori.w	#$0700,sr
	move.b	#14,$ffff8800.w		; Port A
	move.b	$ffff8800.w,d0
	bset	#4,d0			; Reset
	move.b	d0,$ffff8802.w
	moveq.l	#100,d1
.Wait:	nop
	dbra	d1,.Wait
	bclr	#4,d0
	move.b	#14,$ffff8800.w
	move.b	d0,$ffff8802.w
	move.w	(sp)+,sr
	moveq.l	#100,d1
.Wait2:	nop
	dbra	d1,.Wait2
	lea.l	Dsp_program,a0		; The program
	move.w	#512-1,d2
.Boot:	jsr	Dsp_wait_free
	bne.s	.Exit
	moveq.l	#0,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	move.l	d0,Dsp_data.w
	dbra	d2,.Boot
	jsr	Dsp_wait_free		; Does it answer ?
	bne.s	.Exit
	moveq.l	#2,d0
	move.l	d0,Dsp_data.w
	move.l	#200000,d1
.Answer:	btst	#Dsp_RXDF,Dsp_ISR.w
	bne.s	.Got
	subq.l	#1,d1
	bne.s	.Answer
	moveq.l	#1,d0			; No
	bra.s	.Exit
.Got:	move.l	Dsp_data.w,d0
	andi.l	#$ffffff,d0
	cmp.l	#$a5a5a5,d0
.Exit:	rts

;*****************************************************************************
; [ Wait until the host port is free ]
;  OUT : Z set if it is free
; Changed registers : d1
;*****************************************************************************
Dsp_wait_free:
	move.l	#200000,d1
.Loop:	btst	#Dsp_TXDE,Dsp_ISR.w
	bne.s	.Ok
	subq.l	#1,d1
	bne.s	.Loop
	moveq.l	#1,d1
	rts
.Ok:	moveq.l	#0,d1
	rts

;*****************************************************************************
; [ Send a word to the DSP ]
;   IN : d0 - The word (.l)
; All registers are restored
;*****************************************************************************
Dsp_send:
.Wait:	btst	#Dsp_TXDE,Dsp_ISR.w
	beq.s	.Wait
	move.l	d0,Dsp_data.w
	rts

;*****************************************************************************
; [ Load bytes into the DSP ]
;   IN : d2 - Word index in the DSP (.l)
;        d3 - Number of words (.l)
;        a0 - Pointer to the bytes, 0 : zeros (.l)
; Changed registers : d0-d4, a0
;*****************************************************************************
Dsp_load:
.Part:	tst.l	d3
	ble.s	.Exit
	move.l	d3,d4			; The words in this bank
	move.l	#Dsp_bank_words,d0
	moveq.l	#1,d1			; (command : Y)
	cmp.l	d0,d2
	bcs.s	.Bank
	sub.l	d0,d2
	add.l	d0,d0			; (the rest of X)
	moveq.l	#-1,d1
.Bank:	sub.l	d2,d0
	ble.s	.Exit			; (not more than there is)
	cmp.l	d0,d4
	bls.s	.Count
	move.l	d0,d4
.Count:	move.l	d1,d0			; Command
	jsr	Dsp_send
	move.l	d2,d0			; Address
	add.l	#$200,d0
	jsr	Dsp_send
	move.l	d4,d0			; Count
	jsr	Dsp_send
	tst.b	d1			; (for the rest : on behind this bank)
	bmi.s	.In_X
	add.l	d4,d2
	bra.s	.Words
.In_X:	add.l	d4,d2
	add.l	#Dsp_bank_words,d2
.Words:	sub.l	d4,d3
	subq.l	#1,d4
.Word:	moveq.l	#0,d0
	move.l	a0,d1
	beq.s	.Zero
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
.Zero:	jsr	Dsp_send
	subq.l	#1,d4
	bpl.s	.Word
	bra.s	.Part
.Exit:	rts

;*****************************************************************************
; [ Start the player on the DSP ]
;  OUT : Z set if it runs
; All registers are restored, but d0
; NOTE :
;   - Called by [ Init_sound ] while the TOS is active (XBIOS).
;*****************************************************************************
Dsp_init_sound:
	movem.l	d1-d4/a0-a2,-(sp)
	jsr	Dsp_start
	bne	.Exit
	moveq.l	#0,d2			; Silence and waves : zeros
	move.l	#Dsp_first_sample,d3
	suba.l	a0,a0
	jsr	Dsp_load
	lea.l	Dsp_old_waves,a0
	move.w	#4*Sa_wave_size/4-1,d0
.Clear:	clr.l	(a0)+
	dbra	d0,.Clear
	clr.l	Dsp_samples
	clr.l	Dsp_samples_end
	sf	Dsp_busy
	move.w	#1,-(sp)			; Dsptristate(on, on)
	move.w	#1,-(sp)
	move.w	#Dsptristate,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	move.w	#1,-(sp)			; Devconnect(DSP out, DAC, 25 MHz,
	move.w	#Sound_prescale,-(sp)	;  prescale, no handshake)
	clr.w	-(sp)
	move.w	#8,-(sp)
	move.w	#1,-(sp)
	move.w	#Devconnect,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	moveq.l	#0,d0
.Exit:	movem.l	(sp)+,d1-d4/a0-a2
	rts

;*****************************************************************************
; [ Stop the player on the DSP ]
; All registers are restored
; NOTE :
;   - Called by [ Exit_sound ] while the TOS is active again (XBIOS).
;*****************************************************************************
Dsp_exit_sound:
	movem.l	d0-d2/a0-a2,-(sp)
	st	Dsp_busy
	move.w	#1,-(sp)			; Devconnect(DMA, DAC, ...) : as usual
	move.w	#Sound_prescale,-(sp)
	clr.w	-(sp)
	move.w	#8,-(sp)
	clr.w	-(sp)
	move.w	#Devconnect,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	clr.w	-(sp)			; Dsptristate(off, off)
	clr.w	-(sp)
	move.w	#Dsptristate,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;*****************************************************************************
; [ A song was taken by the replay ] (at the end of SA_Hardcalc)
;   IN : a0 - Pointer to the module (.l)
; All registers are restored
;*****************************************************************************
Paula_new_song:
	tst.b	Music_player
	beq	.Exit
	movem.l	d0-d7/a0-a6,-(sp)
	st	Dsp_busy			; (no registers while it loads)
	moveq.l	#0,d0			; All channels off
	jsr	Dsp_send
	moveq.l	#4*11-1,d7
	moveq.l	#0,d6
.Off:	moveq.l	#0,d0
	tst.w	d6
	bne.s	.Word
	moveq.l	#2,d0			; (flags : off)
.Word:	jsr	Dsp_send
	addq.w	#1,d6
	cmp.w	#11,d6
	bne.s	.Next
	moveq.l	#0,d6
.Next:	dbra	d7,.Off
	lea.l	Mix_channels,a1
	moveq.l	#4-1,d7
.State:	sf	Ch_on(a1)
	sf	Ch_cmd(a1)
	lea.l	Ch_size(a1),a1
	dbra	d7,.State
	move.l	28(a0),d0			; The samples
	lea.l	0(a0,d0.l),a1
	move.l	(a1)+,d1
	moveq.l	#0,d3
	move.l	d1,d0
	lsl.l	#2,d0
	lea.l	0(a1,d0.l),a2		; (behind the sizes)
	tst.l	d1
	beq.s	.Sum_done
	subq.l	#1,d1
.Sum:	add.l	(a1)+,d3
	dbra	d1,.Sum
.Sum_done:	move.l	d3,d0			; Not more than fits
	move.l	#Dsp_bytes-Dsp_first_sample*3,d1
	cmp.l	d1,d0
	bls.s	.Fits
	move.l	d1,d3
.Fits:	move.l	a2,Dsp_samples
	lea.l	0(a2,d3.l),a3
	move.l	a3,Dsp_samples_end
	move.l	a2,a0
	addq.l	#2,d3			; Words
	divu.l	#3,d3
	move.l	#Dsp_first_sample,d2
	jsr	Dsp_load
	sf	Dsp_busy
	movem.l	(sp)+,d0-d7/a0-a6
.Exit:	rts

;*****************************************************************************
; [ Send the channels to the DSP ] (vertical blank, 50 Hz)
; All registers are restored
;*****************************************************************************
Dsp_VBL:
	tst.b	Dsp_busy
	bne	.Exit
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Dsp_send_waves
	moveq.l	#0,d0			; The channels
	jsr	Dsp_send
	lea.l	Paula+aud0,a0
	lea.l	Mix_channels,a1
	moveq.l	#4-1,d7
.Channel:	jsr	Dsp_send_channel
	lea.l	16(a0),a0
	lea.l	Ch_size(a1),a1
	dbra	d7,.Channel
	movem.l	(sp)+,d0-d7/a0-a6
.Exit:	rts

;*****************************************************************************
; [ Send the waves which have changed ]
; Changed registers : d0-d7, a0-a4
; NOTE :
;   - The waves of the synthetic instruments are the first 128 bytes of the
;     track of the replay, which changes them while they play.
;*****************************************************************************
Dsp_send_waves:
	lea.l	sa_track,a2
	lea.l	Dsp_old_waves,a3
	moveq.l	#Dsp_silence_words,d6	; Word in the DSP
	moveq.l	#4-1,d7
.Wave:	move.l	a2,a0
	move.l	a3,a1
	moveq.l	#Sa_wave_size/4-1,d0
.Same:	cmpm.l	(a0)+,(a1)+
	dbne	d0,.Same
	beq.s	.Next
	move.l	a2,a0			; Changed
	move.l	a3,a1
	moveq.l	#Sa_wave_size/4-1,d0
.Copy:	move.l	(a0)+,(a1)+
	dbra	d0,.Copy
	move.l	a2,a0
	move.l	d6,d2
	moveq.l	#Dsp_wave_words,d3
	jsr	Dsp_load
.Next:	lea.l	Sa_track_size(a2),a2
	lea.l	Sa_wave_size(a3),a3
	add.l	#Dsp_wave_words,d6
	dbra	d7,.Wave
	rts

;*****************************************************************************
; [ Send a channel ]
;   IN : a0 - Pointer to the registers (Paula+audX) (.l)
;        a1 - Pointer to the mixer state (.l)
; Changed registers : d0-d5, a2
;*****************************************************************************
Dsp_send_channel:
	moveq.l	#0,d0			; Flags
	move.b	Ch_cmd(a1),d0
	clr.b	Ch_cmd(a1)
	jsr	Dsp_send
	move.l	Ch_base(a1),d2		; Start
	move.l	Ch_end(a1),d3
	jsr	Dsp_send_sample
	move.l	ac_ptr(a0),d2		; The next one
	moveq.l	#0,d3
	move.w	ac_len(a0),d3
	bne.s	.Length
	move.l	#$10000,d3
.Length:	add.l	d3,d3
	jsr	Dsp_send_sample
	moveq.l	#0,d4			; Step, volume
	moveq.l	#0,d5
	tst.b	Ch_on(a1)
	ble.s	.Send
	moveq.l	#0,d1
	move.w	ac_per(a0),d1
	beq.s	.Send
	cmp.w	#Min_period,d1
	bcc.s	.Period
	moveq.l	#Min_period,d1
.Period:	move.l	#Step_const,d4		; (16.16, bytes)
	divu.l	d1,d4
	lsl.l	#8,d4			; (.24, words)
	divu.l	#3,d4
	move.w	ac_vol(a0),d5
	andi.w	#$7f,d5
	cmp.w	#64,d5
	bls.s	.Volume
	moveq.l	#64,d5
.Volume:	swap	d5			; (64 : 0.5)
.Send:	move.l	d4,d0
	jsr	Dsp_send
	move.l	d5,d0
	jmp	Dsp_send

;*****************************************************************************
; [ Send a sample : position, end ]
;   IN : d2 - Address (.l)
;        d3 - Length in bytes (.l)
; Changed registers : d0-d3
;*****************************************************************************
Dsp_send_sample:
	sub.l	#sa_track,d2		; A wave ?
	bmi.s	.Sample
	cmp.l	#4*Sa_track_size,d2
	bcc.s	.Sample
	move.l	d2,d0
	divu.w	#Sa_track_size,d0
	moveq.l	#0,d1			; (the rest : in the track)
	move.w	d0,d1
	swap	d0
	cmp.w	#Sa_wave_size,d0
	bcc.s	.Silence
	mulu.w	#Dsp_wave_words*3,d1
	add.l	#Dsp_silence_words*3,d1
	andi.l	#$ffff,d0
	add.l	d0,d1
	move.l	d1,d2
	bra.s	.Send
.Sample:	add.l	#sa_track,d2		; The samples ?
	cmp.l	Dsp_samples,d2
	bcs.s	.Silence
	move.l	d2,d0
	add.l	d3,d0
	cmp.l	Dsp_samples_end,d0
	bhi.s	.Silence
	sub.l	Dsp_samples,d2
	add.l	#Dsp_first_sample*3,d2
	bra.s	.Send
.Silence:	moveq.l	#0,d2			; (also sa_silence)
	moveq.l	#2,d3
.Send:	move.l	d2,d0
	add.l	d3,d2			; (the end)
	jsr	Dsp_send_position
	move.l	d2,d0
; (on into [ Dsp_send_position ])

;*****************************************************************************
; [ Send a position : word, fraction ]
;   IN : d0 - Byte in the DSP (.l)
; Changed registers : d0, d1
;*****************************************************************************
Dsp_send_position:
	divul.l	#3,d1:d0
	jsr	Dsp_send
	move.l	.Fraction(pc,d1.w*4),d0
	jmp	Dsp_send
.Fraction:	dc.l	0,$555556,$aaaaac,0

	SECTION	Fast_DATA,data
	even
Dsp_program:
	incbin	"ST_KERNEL/DSP_MIX.BIN"
	even

	SECTION	Fast_BSS,bss
Dsp_samples:	ds.l 1			; The samples of the song in the memory
Dsp_samples_end:	ds.l 1
Dsp_old_waves:	ds.b 4*Sa_wave_size
Dsp_busy:	ds.b 1
	even

	SECTION	Program,code
