; Falcon kernel : the music mixer on the DSP 56001 (assembled at build time by
; tools/dsp_asm.py, loaded by KERNEL/MUSIC_DSP.S)
;
; The 4 channels of Paula, mixed in the transmit interrupt of the SSI, which
; sends the stereo frames through the crossbar to the DAC (24585 Hz).
;
; The samples : 3 bytes in a word, first in Y:$200-$3fff, then X:$200-$3fff.
; A position is a word index (.1) and the fraction of a word (.0), so that the
; byte in the word is fraction * 3 and a step is below one word.
;
; The commands of the host (one word, then its data) :
;    0 : 4 channels, each with 11 words (see the channel below) : flags (1 start,
;        2 off), start position, end, next position, next end, step, volume
;    1 : load words into Y : address, count, words
;   -1 : load words into X : address, count, words
;    2 : answer with a word (the host looks if there is a DSP)

; A channel in X
c_pos	= 0			; Position (2 words)
c_end	= 2			; End of the sample (2 words)
c_step	= 4
c_vol	= 5			; (volume 64 : 0.5, two channels fit into 16 bits)
c_on	= 6
c_next	= 7			; The sample after the end : position (2 words)
c_nend	= 9			;  and its end (2 words)
c_size	= 12

ch0	= $40
ch1	= $4c
ch2	= $58
ch3	= $64
v_other	= $90			; The left side of the next frame
v_a1	= $91			; (the main loop uses a and x0)
v_a0	= $92
v_a2	= $93
v_x0	= $94
v_shift	= $95			; 3 words : the shift of a byte in a word
v_right	= $98			; The right side of the next frame
cmd_buf	= $a0			; The 4 * 11 words of the channels from the host

	org	0
	jmp	start

	org	$10
	jsr	ssi			; SSI transmit
	nop
	jsr	ssi			; SSI transmit with underrun
	nop

	org	$40
start:
	movep	#>0,x:$fffe		; BCR : no wait states
	movep	#>1,x:$ffe0		; Host port
	move	#>ch0,r0
	clr	a
	rep	#48
	move	a,x:(r0)+
	move	a,x:v_other
	move	a,x:v_right
	move	#>v_shift,r0
	move	#>0,x0
	move	x0,x:(r0)+
	move	#>8,x0
	move	x0,x:(r0)+
	move	#>16,x0
	move	x0,x:(r0)+
	movep	#>$4100,x:$ffec		; CRA : 16 bits, 2 words in a frame
	movep	#>$5800,x:$ffed		; CRB : transmit interrupt, network mode
	movep	#>$1f8,x:$ffe1		; PCC : the pins of the SSI
	movep	#>$3000,x:$ffff		; IPR : SSI at level 2
	andi	#$fc,mr

; ---------- The commands ---------------------------
main:
	jclr	#0,x:$ffe9,main
	move	x:$ffeb,a
	tst	a
	jeq	channels
	jmi	load_x
	move	#>2,x0
	cmp	x0,a
	jeq	ping
; Load words into Y
	jsr	wait
	move	a1,r4
	jsr	wait
	move	a1,r5
	do	r5,ly_end
ly_w:	jclr	#0,x:$ffe9,ly_w
	move	x:$ffeb,a
	move	a1,y:(r4)+
ly_end:
	jmp	main
; Load words into X
load_x:
	jsr	wait
	move	a1,r4
	jsr	wait
	move	a1,r5
	do	r5,lx_end
lx_w:	jclr	#0,x:$ffe9,lx_w
	move	x:$ffeb,a
	move	a1,x:(r4)+
lx_end:
	jmp	main
ping:
	jclr	#1,x:$ffe9,ping
	move	#>$a5a5a5,x0
	move	x0,x:$ffeb
	jmp	main

; ---------- The registers of the channels -----------
; The words of all 4 channels first, then the next samples, steps and volumes,
; then the starts and stops together : the channels which are started at the
; same time start in the same frame, like with DMACON on the Amiga.
; (The interrupt uses r0-r2 and n0-n2, x1, y and b : not here.)
channels:
	move	#>cmd_buf,r4		; The words from the host
	move	#>44,x0
	do	x0,ch_end
ch_w:	jclr	#0,x:$ffe9,ch_w
	move	x:$ffeb,a
	move	a1,x:(r4)+
ch_end:
	move	#>cmd_buf,r4
	move	#>ch0,r6
	jsr	ch_regs
	move	#>cmd_buf+11,r4
	move	#>ch1,r6
	jsr	ch_regs
	move	#>cmd_buf+22,r4
	move	#>ch2,r6
	jsr	ch_regs
	move	#>cmd_buf+33,r4
	move	#>ch3,r6
	jsr	ch_regs
	ori	#3,mr			; (the interrupt must not see half of it)
	move	#>cmd_buf,r4
	move	#>ch0,r6
	jsr	ch_flags
	move	#>cmd_buf+11,r4
	move	#>ch1,r6
	jsr	ch_flags
	move	#>cmd_buf+22,r4
	move	#>ch2,r6
	jsr	ch_flags
	move	#>cmd_buf+33,r4
	move	#>ch3,r6
	jsr	ch_flags
	andi	#$fc,mr
	jmp	main

; The next sample, the step and the volume of the channel r6 (words at r4)
ch_regs:
	move	r4,r5			; (behind flags, position and end)
	move	#>5,n5
	move	(r5)+n5
	move	r6,r3			; The next sample
	move	#>c_next,n3
	move	(r3)+n3
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	#>c_step,n6		; Step, volume
	move	x:(r5)+,a
	move	a1,x:(r6+n6)
	move	#>c_vol,n6
	move	x:(r5)+,a
	move	a1,x:(r6+n6)
	rts

; Start or stop the channel r6 (words at r4)
ch_flags:
	move	x:(r4),a		; Flags
	move	#>1,x0
	cmp	x0,a
	jeq	ch_start
	move	#>2,x0
	cmp	x0,a
	jne	ch_done
	move	#>c_on,n6		; Off
	clr	a
	move	a,x:(r6+n6)
	rts
ch_start:
	move	r4,r5			; Start : position, end
	move	(r5)+
	move	r6,r3
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	x:(r5)+,a
	move	a1,x:(r3)+
	move	#>c_on,n6
	move	#>1,x0
	move	x0,x:(r6+n6)
ch_done:
	rts

; The next word from the host in a
wait:	jclr	#0,x:$ffe9,wait
	move	x:$ffeb,a
	rts

; ---------- The SSI interrupt ------------------------
ssi:
	move	a1,x:v_a1
	move	a0,x:v_a0
	move	a2,x:v_a2
	move	x0,x:v_x0
	jclr	#2,x:$ffee,second
	move	x:v_right,x0		; (the frame sync came with the word before :
	move	x0,x:$ffef		;  this is the right side)
; The next frame, behind the word : mixing takes longer than a word is sent
	move	#>ch0,r0		; The frame : channels 0 and 3 left, 1 and 2
	move	#>0,x1			;  right
	jsr	mix
	move	#>ch3,r0
	jsr	mix
	move	x1,x:v_other
	move	#>ch1,r0
	move	#>0,x1
	jsr	mix
	move	#>ch2,r0
	jsr	mix
	move	x1,x:v_right
	jmp	ssi_end
second:
	move	x:v_other,x0		; The left side
	move	x0,x:$ffef
ssi_end:
	move	x:v_a1,a
	move	x:v_a0,a0
	move	x:v_a2,a2
	move	x:v_x0,x0
	rti

; ---------- Mix one channel --------------------------
;   IN : r0 - The channel, x1 - The sum of the side
;  OUT : x1 - The new sum
; Changed : a, b, x0, y0, y1, r1, r2, n0, n1, n2
mix:
	move	#>c_on,n0
	move	x:(r0+n0),b
	tst	b
	jne	mix_on
	rts
mix_on:
	move	x:(r0),a		; Position
	move	#>1,n0
	move	x:(r0+n0),a0
; The byte in the word : the shift
	move	a0,b			; (the fraction, unsigned)
	lsr	b
	move	b1,x0
	move	#>3,y0
	mpy	x0,y0,b
	move	b1,n2
	move	#>v_shift,r2
	move	x:(r2+n2),y1
; The word
	move	a1,n1
	move	#>$3e00,x0
	cmp	x0,a
	jge	mix_x
	move	#>$200,r1
	move	y:(r1+n1),b
	jmp	mix_word
mix_x:
	move	#>$c400,r1		; ($200 - $3e00)
	move	x:(r1+n1),b
mix_word:
	move	b1,x0
	tfr	y1,b
	tst	b
	move	x0,b
	jeq	mix_byte
	rep	y1
	lsl	b
mix_byte:
	move	#>$ff0000,x0
	and	x0,b
; Sample * volume, into the sum
	move	b1,x0
	move	#>c_vol,n0
	move	x:(r0+n0),y0
	mpy	x0,y0,b
	add	x1,b
	move	b1,x1
; Next position
	move	#>c_step,n0
	move	x:(r0+n0),y0
	move	#>0,y1
	add	y,a
	move	#>c_end,n0
	move	x:(r0+n0),b
	move	#>c_end+1,n0
	move	x:(r0+n0),b0
	cmp	b,a
	jlt	mix_store
; The end of the sample : the rest of the step in the next one
	sub	b,a
	move	#>c_next,n0
	move	x:(r0+n0),b
	move	#>c_next+1,n0
	move	x:(r0+n0),b0
	add	b,a
	move	#>c_nend,n0
	move	x:(r0+n0),b
	move	#>c_nend+1,n0
	move	x:(r0+n0),b0
	move	#>c_end,n0
	move	b1,x:(r0+n0)
	move	#>c_end+1,n0
	move	b0,x:(r0+n0)
	cmp	b,a
	jlt	mix_store
	move	#>c_next,n0		; (a very short sample)
	move	x:(r0+n0),a
	move	#>c_next+1,n0
	move	x:(r0+n0),a0
mix_store:
	move	a1,x:(r0)
	move	#>1,n0
	move	a0,x:(r0+n0)
	rts
