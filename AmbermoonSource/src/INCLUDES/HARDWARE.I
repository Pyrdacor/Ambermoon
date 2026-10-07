; Hardware & operating system definitions
; (Subset of hardware/custom.i and the library offsets used by the kernel.)

Custom	EQU	$dff000

dmaconr	EQU	$002
vposr	EQU	$004
vhposr	EQU	$006
joy0dat	EQU	$00a
joy1dat	EQU	$00c
adkconr	EQU	$010
potinp	EQU	$016
serdatr	EQU	$018
intenar	EQU	$01c
intreqr	EQU	$01e
dsklen	EQU	$024
vposw	EQU	$02a
copcon	EQU	$02e
potgo	EQU	$034
joytest	EQU	$036
bltcon0	EQU	$040
bltcon1	EQU	$042
bltafwm	EQU	$044
bltalwm	EQU	$046
bltcpt	EQU	$048
bltbpt	EQU	$04c
bltapt	EQU	$050
bltdpt	EQU	$054
bltsize	EQU	$058
bltcmod	EQU	$060
bltbmod	EQU	$062
bltamod	EQU	$064
bltdmod	EQU	$066
bltcdat	EQU	$070
bltbdat	EQU	$072
bltadat	EQU	$074
cop1lc	EQU	$080
cop2lc	EQU	$084
copjmp1	EQU	$088
copjmp2	EQU	$08a
diwstrt	EQU	$08e
diwstop	EQU	$090
ddfstrt	EQU	$092
ddfstop	EQU	$094
dmacon	EQU	$096
clxcon	EQU	$098
intena	EQU	$09a
intreq	EQU	$09c
adkcon	EQU	$09e
bplpt	EQU	$0e0
bplcon0	EQU	$100
bplcon1	EQU	$102
bplcon2	EQU	$104
bpl1mod	EQU	$108
bpl2mod	EQU	$10a
sprpt	EQU	$120
spr	EQU	$140
color00	EQU	$180

; Audio channel registers
aud0	EQU	$0a0
aud1	EQU	$0b0
aud2	EQU	$0c0
aud3	EQU	$0d0
ac_ptr	EQU	$00
ac_len	EQU	$04
ac_per	EQU	$06
ac_vol	EQU	$08

; exec.library
_LVOSupervisor	EQU	-30
_LVODisable	EQU	-120
_LVOEnable	EQU	-126
_LVOForbid	EQU	-132
_LVOPermit	EQU	-138
_LVOAddIntServer	EQU	-168
_LVORemIntServer	EQU	-174
_LVOAllocMem	EQU	-198
_LVOFreeMem	EQU	-210
_LVOAvailMem	EQU	-216
_LVOFindTask	EQU	-294
_LVOSetTaskPri	EQU	-306
_LVOWait	EQU	-318
_LVOSignal	EQU	-324
_LVOAllocSignal	EQU	-330
_LVOFreeSignal	EQU	-336
_LVOPutMsg	EQU	-366
_LVOGetMsg	EQU	-372
_LVOReplyMsg	EQU	-378
_LVOWaitPort	EQU	-384
_LVOOldOpenLibrary	EQU	-408
_LVOCloseLibrary	EQU	-414
_LVOOpenDevice	EQU	-444
_LVOCloseDevice	EQU	-450
_LVODoIO	EQU	-456
_LVOSendIO	EQU	-462
_LVOCheckIO	EQU	-468
_LVOWaitIO	EQU	-474
_LVOAbortIO	EQU	-480
_LVOOpenLibrary	EQU	-552
_LVOCacheClearU	EQU	-636
_LVOAllocVec	EQU	-666
_LVOFreeVec	EQU	-690

; dos.library
_LVOOpen	EQU	-30
_LVOClose	EQU	-36
_LVORead	EQU	-42
_LVOWrite	EQU	-48
_LVOSeek	EQU	-66
_LVODeleteFile	EQU	-72
_LVORename	EQU	-78
_LVOLock	EQU	-84
_LVOUnLock	EQU	-90
_LVOExamine	EQU	-102
_LVOExNext	EQU	-108
_LVOInfo	EQU	-114
_LVOCreateDir	EQU	-120
_LVOCurrentDir	EQU	-126
_LVOIoErr	EQU	-132
_LVODelay	EQU	-198

; graphics.library
_LVOLoadView	EQU	-222
_LVOWaitBlit	EQU	-228
_LVOWaitTOF	EQU	-270
_LVOOwnBlitter	EQU	-456
_LVODisownBlitter	EQU	-462

