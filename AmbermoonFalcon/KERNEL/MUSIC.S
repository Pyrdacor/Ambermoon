; Falcon kernel : music
; (Replaces MUSIC.S of the ST kernel, which plays the YM2149 songs of the ST
; version.)
;
; The Falcon plays the music of the Amiga version with the original Sonic
; Arranger replay (MUSIC/SONIC_ARRANGER.S, see PATCHES/SONIC_ARRANGER.diff).
; It writes the registers of an emulated Paula ([ Paula ] : the 4 sound
; channels of the Amiga with sample pointer, length, period and volume, at
; the offsets of the custom chips) and starts / stops the channels with
; [ Paula_dmacon ]. Like Paula, a channel takes the pointer and the length
; of its registers when it is started, and again when its sample has ended
; (the replay writes the loop of a sample after the start).
; [ Music_VBL ] (vertical blank handler, 50 Hz, after the replay) mixes the
; 4 channels into the sound buffer of the DMA sound, which plays in a loop
; (16 bit stereo, 24585 Hz), up to [ Ring_ahead ] frames after the play
; position : the channels 0 and 3 left, 1 and 2 right, like the Amiga. The
; volume (0-64) comes from tables : a sample * volume * 2, two channels fit
; into 16 bits.
;
; There are two players of the channels :
;   - The DSP (MUSIC_DSP.S, DSP_MIX.ASM) : it mixes on its own, the CPU is free.
;   - The CPU (below) : for a Falcon whose DSP does not answer.
; [ Music_use_dsp ] chooses, [ Music_player ] is the one which runs.

	include	MUSIC/SONIC_ARRANGER.S

Music_use_dsp	EQU	1		; 1 : DSP, 0 : CPU

Sound_prescale	EQU	3		; 25.175 MHz / 256 / (3 + 1) = 24585 Hz
Sound_rate	EQU	24585
Paula_clock	EQU	3546895		; (PAL)
Step_const	EQU	9454111		; Paula_clock * 65536 / Sound_rate
Min_period	EQU	113
Ring_frames	EQU	4096		; (a power of 2; a frame : 2 words)
Ring_ahead	EQU	1536		; (62 ms)

; Mixer state of a channel
	rsreset
Ch_on:	rs.b 1			; 0 : off, 1 : on, -1 : on, without a sample
	rs.b 1
Ch_base:	rs.l 1			; The sample (taken from the registers)
Ch_end:	rs.l 1			; Its length in bytes
Ch_offset:	rs.l 1			; Position in the sample ...
Ch_frac:	rs.w 1			;  ... and the fraction
Ch_cmd:	rs.b 1			; For the DSP : 1 started, 2 stopped
	rs.b 1
Ch_size:	rs.b 0

; XBIOS (Falcon sound)
Locksnd	EQU	128
Unlocksnd	EQU	129
Soundcmd	EQU	130
Setbuffer	EQU	131
Setmode	EQU	132
Settracks	EQU	133
Buffoper	EQU	136
Dsptristate	EQU	137
Devconnect	EQU	139
Sndstatus	EQU	140

; The sound DMA counter (the play position)
Sound_count_high	EQU	$ffff8909
Sound_count_mid	EQU	$ffff890b
Sound_count_low	EQU	$ffff890d

; The random numbers of the noise generators of the replay (VHPOSR on the
; Amiga) : the low byte of the video address counter
Paula_random	EQU	$ffff8209

	SECTION	Program,code

;*****************************************************************************
; [ Start / stop channels ] (DMACON of the Amiga)
;   IN : [ Paula_dmacon_value ] - Bit 15 : on / off, bits 0-3 : channels
; All registers are restored
;*****************************************************************************
Paula_dmacon:
	movem.l	d0-d3/a0/a1,-(sp)
	move.w	sr,-(sp)
	ori.w	#$0700,sr			; (the mixer runs in the VBL)
	move.w	Paula_dmacon_value,d0
	lea.l	Paula+aud0,a0
	lea.l	Mix_channels,a1
	moveq.l	#0,d1
.Loop:	btst	d1,d0			; This channel ?
	beq.s	.Next
	btst	#15,d0			; Yes : on ?
	bne.s	.On
	sf	Ch_on(a1)			; No -> off
	move.b	#2,Ch_cmd(a1)
	bra.s	.Next
.On:	tst.b	Ch_on(a1)			; Yes : started now ?
	bne.s	.Next
	jsr	Paula_take		; Yes -> the registers
	move.b	#1,Ch_cmd(a1)
	clr.l	Ch_offset(a1)
	clr.w	Ch_frac(a1)
.Next:	lea.l	16(a0),a0
	lea.l	Ch_size(a1),a1
	addq.w	#1,d1
	cmp.w	#4,d1
	bne.s	.Loop
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-d3/a0/a1
	rts

;*****************************************************************************
; [ A channel takes the sample of its registers ]
;   IN : a0 - Pointer to the registers (Paula+audX) (.l)
;        a1 - Pointer to the mixer state (.l)
; Changed registers : d2, d3
; NOTE :
;   - Length 0 is 65536 words, like Paula. A sample outside the memory is
;     not read (the channel stays on, silent).
;*****************************************************************************
Paula_take:
	move.l	ac_ptr(a0),d2
	moveq.l	#0,d3
	move.w	ac_len(a0),d3
	bne.s	.Length
	move.l	#$10000,d3
.Length:	add.l	d3,d3			; (bytes)
	move.l	d2,Ch_base(a1)
	move.l	d3,Ch_end(a1)
	move.b	#1,Ch_on(a1)
	cmp.l	#$800,d2			; In the memory ?
	bcs.s	.Outside
	add.l	d3,d2
	cmp.l	Memory_top,d2
	bls.s	.Exit
.Outside:	st	Ch_on(a1)			; No -> silent
.Exit:	rts

;*****************************************************************************
; [ Mix the channels into the sound buffer ] (vertical blank, 50 Hz)
; All registers are restored
;*****************************************************************************
Music_VBL:
	tst.b	Sound_on
	beq	.Exit
	tst.b	Music_player		; On the DSP ?
	bne	Dsp_VBL
	movem.l	d0-d7/a0-a6,-(sp)
.Count:	jsr	Sound_count		; Play position (frame)
	move.l	d0,d1
	jsr	Sound_count		; (the same twice)
	cmp.l	d0,d1
	bne.s	.Count
	sub.l	#Ring,d0
	lsr.l	#2,d0
	move.w	Mix_write,d1		; Frames up to the play position
	move.w	d0,d2			;  + Ring_ahead
	addi.w	#Ring_ahead,d2
	sub.w	d1,d2
	andi.w	#Ring_frames-1,d2
	cmp.w	#Ring_frames/2,d2		; (written ahead already)
	bhi.s	.Done
	tst.w	d2
	beq.s	.Done
	move.w	#Ring_frames,d3		; Up to the end of the buffer
	sub.w	d1,d3
	cmp.w	d2,d3
	bcs.s	.Two
	jsr	Mix_frames
	bra.s	.Moved
.Two:	move.w	d2,-(sp)			; Two parts
	move.w	d3,d2
	jsr	Mix_frames
	move.w	(sp)+,d2
	sub.w	d3,d2
	moveq.l	#0,d1
	jsr	Mix_frames
.Moved:	move.w	d1,d0			; (d1 + d2 : the new write position)
	add.w	d2,d0
	andi.w	#Ring_frames-1,d0
	move.w	d0,Mix_write
.Done:	movem.l	(sp)+,d0-d7/a0-a6
.Exit:	rts

;*****************************************************************************
; [ Read the sound DMA counter ]
;  OUT : d0 - Address (.l)
; Changed registers : d0
;*****************************************************************************
Sound_count:
	moveq.l	#0,d0
	move.b	Sound_count_high,d0
	lsl.l	#8,d0
	move.b	Sound_count_mid,d0
	lsl.l	#8,d0
	move.b	Sound_count_low,d0
	rts

;*****************************************************************************
; [ Mix frames ]
;   IN : d1 - First frame (.w)
;        d2 - Number of frames (> 0) (.w)
; All registers are restored
;*****************************************************************************
Mix_frames:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Ring,a6			; Clear
	moveq.l	#0,d0
	move.w	d1,d0
	lsl.l	#2,d0
	add.l	d0,a6
	move.l	a6,a4
	move.w	d2,Mix_count
	move.w	d2,d7
	subq.w	#1,d7
.Clear:	clr.l	(a4)+
	dbra	d7,.Clear
	lea.l	Paula+aud0,a0		; The channels (0 and 3 left,
	lea.l	Mix_channels,a1		;  1 and 2 right)
	move.l	a6,a4
	jsr	Mix_channel
	lea.l	16(a0),a0
	lea.l	Ch_size(a1),a1
	lea.l	2(a6),a4
	jsr	Mix_channel
	lea.l	16(a0),a0
	lea.l	Ch_size(a1),a1
	lea.l	2(a6),a4
	jsr	Mix_channel
	lea.l	16(a0),a0
	lea.l	Ch_size(a1),a1
	move.l	a6,a4
	jsr	Mix_channel
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Mix one channel ]
;   IN : a0 - Pointer to the registers (Paula+audX) (.l)
;        a1 - Pointer to the mixer state (.l)
;        a4 - Pointer to the first word of the side in the buffer (.l)
;        [ Mix_count ] - Number of frames (> 0) (.w)
; Changed registers : d0-d7, a2-a5
;*****************************************************************************
Mix_channel:
	tst.b	Ch_on(a1)			; Playing a sample ?
	ble	.Exit
	moveq.l	#0,d1			; Period -> step (16.16)
	move.w	ac_per(a0),d1
	beq	.Exit
	cmp.w	#Min_period,d1
	bcc.s	.Period
	moveq.l	#Min_period,d1
.Period:	move.l	#Step_const,d4
	divu.l	d1,d4
	move.w	d4,d5			; (d5 : fraction, d4 : integer)
	clr.w	d4
	swap	d4
	move.w	ac_vol(a0),d0		; Volume -> table
	andi.w	#$7f,d0
	cmp.w	#64,d0
	bls.s	.Volume
	moveq.l	#64,d0
.Volume:	lsl.w	#8,d0
	add.w	d0,d0
	lea.l	Volume_tables,a3
	add.w	d0,a3
	move.l	Ch_base(a1),a2		; Sample, end, position
	move.l	Ch_end(a1),a5
	move.l	Ch_offset(a1),d3
	move.w	Ch_frac(a1),d6
	move.w	Mix_count,d7
	subq.w	#1,d7
	moveq.l	#0,d0
.Loop:	move.b	0(a2,d3.l),d0		; Sample * volume
	move.w	0(a3,d0.w*2),d1
	add.w	d1,(a4)
	addq.l	#4,a4
	add.w	d5,d6			; Next position
	addx.l	d4,d3
	cmp.l	a5,d3
	bcc.s	.End
.Next:	dbra	d7,.Loop
	move.l	d3,Ch_offset(a1)
	move.w	d6,Ch_frac(a1)
.Exit:	rts
.End:	sub.l	a5,d3			; End of the sample : the rest of the
	move.l	d3,-(sp)			;  step in the sample of the registers
	jsr	Paula_take		;  (the loop)
	move.l	(sp)+,d3
	tst.b	Ch_on(a1)
	bmi.s	.Exit
	move.l	Ch_base(a1),a2
	move.l	Ch_end(a1),a5
.Wrap:	cmp.l	a5,d3
	bcs.s	.Next
	sub.l	a5,d3
	bra.s	.Wrap

;*****************************************************************************
; [ Start the DMA sound ]
; All registers are restored
; NOTE :
;   - Called by [ Init_system ] while the TOS is active (XBIOS).
;*****************************************************************************
Init_sound:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	$42e.w,Memory_top		; (phystop)
	sf	Music_player
	IFNE	Music_use_dsp
	move.w	#Locksnd,-(sp)		; The DSP ?
	trap	#XBIOS
	addq.l	#2,sp
	move.w	#2,-(sp)			; Soundcmd(ADDERIN, matrix)
	move.w	#4,-(sp)
	move.w	#Soundcmd,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	clr.w	-(sp)			; Soundcmd(LTATTEN / RTATTEN, 0)
	clr.w	-(sp)
	move.w	#Soundcmd,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	clr.w	-(sp)
	move.w	#1,-(sp)
	move.w	#Soundcmd,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	jsr	Dsp_init_sound
	bne.s	.No_dsp
	st	Music_player
	st	Sound_on
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.No_dsp:
	ENDC
	lea.l	Volume_tables,a0		; Volume tables : sample * volume * 2
	moveq.l	#0,d1			; Volume
.Volume:	moveq.l	#0,d2			; Byte of the sample
.Byte:	move.b	d2,d0
	ext.w	d0
	muls.w	d1,d0
	add.w	d0,d0
	move.w	d0,(a0)+
	addq.w	#1,d2
	cmp.w	#256,d2
	bne.s	.Byte
	addq.w	#1,d1
	cmp.w	#65,d1
	bne.s	.Volume
	lea.l	Ring,a0			; Silence
	move.w	#Ring_frames-1,d7
.Clear:	clr.l	(a0)+
	dbra	d7,.Clear
	clr.w	Mix_write
	move.w	#Locksnd,-(sp)		; (also when locked : the game has
	trap	#XBIOS			;  taken over the machine)
	addq.l	#2,sp
	move.w	#1,-(sp)			; Setmode(1) : 16 bit stereo
	move.w	#Setmode,-(sp)
	trap	#XBIOS
	addq.l	#4,sp
	clr.l	-(sp)			; Settracks(0, 0)
	move.w	#Settracks,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	move.w	#1,-(sp)			; Devconnect(DMA play, DAC, 25 MHz,
	move.w	#Sound_prescale,-(sp)	;  prescale, no handshake)
	clr.w	-(sp)
	move.w	#8,-(sp)
	clr.w	-(sp)
	move.w	#Devconnect,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	move.w	#2,-(sp)			; Soundcmd(ADDERIN, matrix)
	move.w	#4,-(sp)
	move.w	#Soundcmd,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	clr.w	-(sp)			; Soundcmd(LTATTEN / RTATTEN, 0)
	clr.w	-(sp)
	move.w	#Soundcmd,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	clr.w	-(sp)
	move.w	#1,-(sp)
	move.w	#Soundcmd,-(sp)
	trap	#XBIOS
	addq.l	#6,sp
	pea	Ring+Ring_frames*4		; Setbuffer(play, start, end)
	pea	Ring
	clr.w	-(sp)
	move.w	#Setbuffer,-(sp)
	trap	#XBIOS
	lea.l	12(sp),sp
	move.w	#3,-(sp)			; Buffoper(play, repeat)
	move.w	#Buffoper,-(sp)
	trap	#XBIOS
	addq.l	#4,sp
	st	Sound_on
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Stop the DMA sound ]
; All registers are restored
; NOTE :
;   - Called by [ Exit_system ] while the TOS is active again (XBIOS).
;*****************************************************************************
Exit_sound:
	movem.l	d0-d2/a0-a2,-(sp)
	tst.b	Sound_on
	beq.s	.Exit
	sf	Sound_on
	tst.b	Music_player
	beq.s	.Cpu
	jsr	Dsp_exit_sound
	bra.s	.Unlock
.Cpu:	clr.w	-(sp)			; Buffoper(0)
	move.w	#Buffoper,-(sp)
	trap	#XBIOS
	addq.l	#4,sp
.Unlock:	move.w	#Unlocksnd,-(sp)
	trap	#XBIOS
	addq.l	#2,sp
.Exit:	movem.l	(sp)+,d0-d2/a0-a2
	rts

	SECTION	Fast_BSS,bss
Paula:	ds.b $100			; (the registers of the custom chips)
Paula_dmacon_value:	ds.w 1
Paula_filter:	ds.b 1			; (the filter of the Amiga : not used)
Sound_on:	ds.b 1
Music_player:	ds.b 1			; 0 : CPU, else DSP
Mix_write:	ds.w 1			; Frame where the mixer goes on
Mix_count:	ds.w 1
Memory_top:	ds.l 1
Mix_channels:	ds.b 4*Ch_size
Cia_b_dummy:	ds.b 4096			; (the CIA timer : not used)
Volume_tables:	ds.w 65*256
Ring:	ds.l Ring_frames			; (frames : left word, right word)

	include	ST_KERNEL/MUSIC_DSP.S
