; System take-over, screens & vertical blank
; Reconstructed from the disassembly of AM2_CPU (Ambermoon 1.21).
; This part is missing in the original source code.

	SECTION	Program,code
	dc.b	0,0

;*****************************************************************************
; [ Initialize the system ]
; Opens dos.library, graphics.library, the console and input device,
; installs the input handler and the copper interrupt, and takes over
; the display.
; All registers are restored
; NOTE (disassembly) :
;   It uses current save files
;   which are located directly
;   inside the "Amberfiles" folder
;*****************************************************************************
Init_system:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Check_OS_version
	moveq.l	#0,d0
	lea.l	Dos_library,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOOpenLibrary(a6)
	move.l	(sp)+,a6
	move.l	d0,Library_dos
	moveq.l	#0,d0
	lea.l	Graphics_library,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOOpenLibrary(a6)
	move.l	(sp)+,a6
	move.l	d0,Library_graphics
	move.l	4,a0
	btst.b	#1,297(a0)		; Check if the CPU is a 68020 or above
	sne	CPU_68020_plus
	sub.l	a1,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOFindTask(a6)
	move.l	(sp)+,a6
	move.l	d0,Own_task
	move.l	Own_task,a0
	move.l	184(a0),Old_window_ptr
	move.l	#-1,184(a0)
	tst.b	Kickstart_2_flag
	beq.w	.Skip2
	lea.l	Data_path,a0
	moveq.l	#0,d0
	jsr	Get_file_path_by_index
	addq.l	#1,a0
	move.l	a0,d1
	move.l	#1005,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.s	.Skip2
	move.l	d0,-(sp)
	lsl.l	#2,d0
	move.l	d0,a0
	move.l	8(a0),a0
	moveq.l	#0,d0
	move.b	14(a0),d0
	andi.l	#3,d0
	cmp.l	#0,d0
	bne.s	.Skip
	move.l	16(a0),a0
	cmpi.b	#13,8(a0)
	bne.s	.Skip
	move.l	184(a0),Old_window_ptr2
	move.l	#-1,184(a0)
.Skip:
	move.l	(sp)+,d1
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOClose(a6)
	move.l	(sp)+,a6
.Skip2:
	lea.l	Console_device,a0		; Device name
	lea.l	IO_request_console,a1		; IORequest*
	moveq.l	#-1,d0		; Unit number
	moveq.l	#0,d1		; Flags
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOOpenDevice(a6)
	move.l	(sp)+,a6
	move.l	IO_request_console+20,Console_device_pointer
	lea.l	IO_request_console,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOCloseDevice(a6)
	move.l	(sp)+,a6
	lea.l	Input_reply_port,a2
	moveq.l	#-1,d0
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOAllocSignal(a6)
	move.l	(sp)+,a6
	move.b	d0,15(a2)
	move.l	Own_task,16(a2)
	lea.l	Input_device,a0
	lea.l	IO_request_input,a1
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOOpenDevice(a6)
	move.l	(sp)+,a6
	lea.l	IO_request_input,a1
	move.w	#9,28(a1)
	move.l	#Interrupt_input_handler,40(a1)
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVODoIO(a6)
	move.l	(sp)+,a6
	move.l	Library_graphics,a0
	move.l	34(a0),Gfx_base_acti_view_ptr
	move.l	38(a0),Gfx_base_copper_start_up_list_ptr
	sub.l	a1,a1
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOLoadView(a6)
	move.l	(sp)+,a6
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOWaitTOF(a6)
	move.l	(sp)+,a6
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOWaitTOF(a6)
	move.l	(sp)+,a6
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOWaitTOF(a6)
	move.l	(sp)+,a6
	move.w	#4,d0
	lea.l	Interrupt_copper_server,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOAddIntServer(a6)
	move.l	(sp)+,a6
	jsr	Init_display_registers
	jsr	Init_copper
	jsr	Init_screens
	lea.l	Custom,a6
	move.w	#0,joytest(a6)
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOOwnBlitter(a6)
	move.l	(sp)+,a6
	move.w	2(a6),Old_DMACON
	move.w	#32767,150(a6)
	move.w	#-30736,150(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Restore the system ]
; Undoes everything [ Init_system ] did.
; All registers are restored
;*****************************************************************************
Exit_system:
	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	Custom,a6
	jsr	My_vsync
.Wait:
	btst.b	#6,dmaconr(a6)		; Wait for blitter
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	tst.b	Blitter_is_not_owned
	bne.s	.Skip
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVODisownBlitter(a6)		; DisownBlitter
	move.l	(sp)+,a6
.Skip:
	move.w	Old_DMACON,d0
	andi.w	#-$10,d0
	ori.w	#-$8000,d0
	move.w	#32767,150(a6)
	move.w	d0,150(a6)
	move.w	#4,d0
	lea.l	Interrupt_copper_server,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVORemIntServer(a6)
	move.l	(sp)+,a6
	move.l	Gfx_base_acti_view_ptr,a1
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOLoadView(a6)
	move.l	(sp)+,a6
	lea.l	Custom,a6
	move.l	Gfx_base_copper_start_up_list_ptr,cop1lc(a6)		; Restore copper to previous list
	tst.w	copjmp1(a6)
	lea.l	IO_request_input,a1
	move.w	#10,28(a1)		; IND_REMHANDLER
	move.l	#Interrupt_input_handler,40(a1)
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVODoIO(a6)		; Remove input handler
	move.l	(sp)+,a6
	lea.l	IO_request_input,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOCloseDevice(a6)		; Close input device
	move.l	(sp)+,a6
	moveq.l	#0,d0
	move.b	Input_signal,d0
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOFreeSignal(a6)
	move.l	(sp)+,a6
	move.l	Own_task,a0
	move.l	Old_window_ptr,184(a0)
	tst.b	Kickstart_2_flag
	beq.w	.Skip3
	lea.l	Data_path,a0
	moveq.l	#0,d0
	jsr	Get_file_path_by_index
	addq.l	#1,a0
	move.l	a0,d1
	move.l	#1005,d2
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.s	.Skip3
	move.l	d0,-(sp)
	lsl.l	#2,d0
	move.l	d0,a0
	move.l	8(a0),a0
	moveq.l	#0,d0
	move.b	14(a0),d0
	andi.l	#3,d0
	cmp.l	#0,d0
	bne.s	.Skip2
	move.l	16(a0),a0
	cmpi.b	#13,8(a0)
	bne.s	.Skip2
	move.l	Old_window_ptr2,184(a0)
.Skip2:
	move.l	(sp)+,d1
	move.l	a6,-(sp)
	move.l	Library_dos,a6
	jsr	_LVOClose(a6)
	move.l	(sp)+,a6
.Skip3:
	move.l	Library_graphics,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOCloseLibrary(a6)
	move.l	(sp)+,a6
	move.l	Library_dos,a1
	move.l	a6,-(sp)
	move.l	4,a6		; Exec base
	jsr	_LVOCloseLibrary(a6)
	move.l	(sp)+,a6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************************************
; [ Get vector base register (supervisor mode) ]
; NOTE :
;   - Called via exec Supervisor(). Must end with rte.
;*****************************************************************************
Get_VBR:
	move.l	a0,-(sp)
	tst.b	CPU_68020_plus
	bne.s	.Skip
	sub.l	a0,a0		; On 68000 the VBR can't
					; be relocated so it is
					; always at address 0.
	bra.s	.Skip2
.Skip:
	movec	VBR,a0		; Otherwise we can move the address
					; (e.g. to fast ram for faster interrupts).
.Skip2:
	move.l	a0,VBR_location
	move.l	(sp)+,a0
	rte

;*****************************************************************************
; [ Vertical blank handler ]
; Called every frame by the copper interrupt server.
;*****************************************************************************
Vbl_handler:
	addq.w	#1,VBL_counter
	jsr	Update_mouse
	jsr	Update_mouse_sprite
	jsr	Random
	jsr	VblQ_handler
	tst.b	Music_flag
	beq.s	.Exit
	jsr	_SA_IrqLowLevel
.Exit:
	rts

;*****************************************************************************
; [ Write display window & bitplane pointers into the copper list ]
; All registers are restored
;*****************************************************************************
Update_copper_list:
	movem.l	d0/d1/d7/a0,-(sp)
	lea.l	Copper_diwstrt,a0
	move.w	Vertical_screen_offset,d0
	addi.w	#48,d0
	lsl.w	#8,d0
	ori.w	#$81,d0
	move.w	d0,(a0)
	addq.l	#4,a0
	move.w	Vertical_screen_offset,d0
	addi.w	#248,d0
	lsl.w	#8,d0
	ori.w	#$c1,d0
	move.w	d0,(a0)
	lea.l	Copper_bplpt,a0
	move.l	Shown_screen,d0
	moveq.l	#4,d7
.Loop:
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	addi.l	#40,d0
	dbra	d7,.Loop
	move.l	Sprite0_ptr,d0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	move.l	Sprite1_ptr,d0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	move.l	#Empty_sprite,d0
	moveq.l	#5,d7
.Loop2:
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	dbra	d7,.Loop2
	move.l	Copper_list2_ptr,d0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	movem.l	(sp)+,d0/d1/d7/a0
	rts

;*****************************************************************************
; [ Check if Kickstart 2.0 (V36) or higher is present ]
; All registers are restored
;*****************************************************************************
Check_OS_version:
	movem.l	d0/a0,-(sp)
	move.l	4,a0
	move.w	20(a0),d0
	cmp.w	#36,d0
	spl	Kickstart_2_flag
	movem.l	(sp)+,d0/a0
	rts

;*****************************************************************************
; [ Initialize the screen buffers ]
; All registers are restored
;*****************************************************************************
Init_screens:
	movem.l	a0/a1,-(sp)
	move.l	#Screen_buffers,a0
	move.l	a0,a1
	add.l	#40000,a1
	move.l	a0,On_screen
	move.l	a1,Off_screen
	move.l	a1,Work_screen
	jsr	Show_screen
	clr.w	Vertical_screen_offset
	movem.l	(sp)+,a0/a1
	rts

;*****************************************************************************
; [ Show the work screen ]
; The HDOBs are drawn, the screens are switched and the new work screen is
; updated with the contents of the shown screen.
; All registers are restored
;*****************************************************************************
Update_screen:
	move.l	a0,-(sp)
	jsr	Draw_HDOBs
	move.l	Off_screen,a0
	move.l	On_screen,Off_screen
	move.l	a0,On_screen
	jsr	Show_screen
	move.l	Off_screen,Work_screen
	not.b	Screen_flag
	jsr	Erase_HDOBs
	jsr	Copy_screen
	jsr	ScrQ_handler
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Switch screens ]
; Like [ Update_screen ], but the new work screen is not updated.
; The blitter is released and owned again so other tasks can use it.
; All registers are restored
;*****************************************************************************
Switch_screens:
	move.l	a0,-(sp)
	jsr	Draw_HDOBs
	move.l	Off_screen,a0
	move.l	On_screen,Off_screen
	move.l	a0,On_screen
	jsr	Show_screen
	move.l	Off_screen,Work_screen
	not.b	Screen_flag
	jsr	Erase_HDOBs
	jsr	ScrQ_handler
.Wait:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	.Wait
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVODisownBlitter(a6)
	move.l	(sp)+,a6
	move.l	a6,-(sp)
	move.l	Library_graphics,a6
	jsr	_LVOOwnBlitter(a6)
	move.l	(sp)+,a6
	move.l	(sp)+,a0
	rts

;*****************************************************************************
; [ Show a screen buffer ]
;   IN : a0 - Pointer to screen (.l)
; NOTE :
;   - Waits for the blitter and the next vertical blank.
;*****************************************************************************
Show_screen:
	btst.b	#6,Custom+dmaconr
	btst.b	#6,Custom+dmaconr
	bne.s	Show_screen
	move.l	a0,Shown_screen
	jsr	My_vsync
	rts

;*****************************************************************************
; [ Copy the shown screen to the work screen (blitter) ]
; All registers are restored
;*****************************************************************************
Copy_screen:
	move.l	a6,-(sp)
	lea.l	Custom,a6
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	On_screen,bltapt(a6)
	move.l	Off_screen,bltdpt(a6)
	move.l	#-$1,bltafwm(a6)
	move.w	#0,bltamod(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$9f00000,bltcon0(a6)
	move.w	#-$5ec,bltsize(a6)
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	move.l	(sp)+,a6
	not.b	Screen_flag
	jsr	Erase_HDOBs
	not.b	Screen_flag
	rts

;*****************************************************************************
; [ Clear a screen ]
;   IN : a0 - Pointer to screen (.l)
; All registers are restored
; NOTE :
;   - The first half is cleared by the blitter, the second half by the CPU.
;*****************************************************************************
Clear_screen:
	movem.l	d0-d7/a0/a1/a6,-(sp)
	lea.l	Custom,a6
.Wait:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait
	move.l	a0,bltdpt(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)
	move.w	#$7d14,bltsize(a6)
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	d0,a1
	add.l	#40000,a0
	move.w	#624,d7
.Loop:
	movem.l	d0-d6/a1,-(a0)
	dbra	d7,.Loop
.Wait2:
	btst.b	#6,dmaconr(a6)
	btst.b	#6,dmaconr(a6)
	bne.s	.Wait2
	movem.l	(sp)+,d0-d7/a0/a1/a6
	rts

;*****************************************************************************
; [ Wait for the next vertical blank ]
; All registers are restored
;*****************************************************************************
My_vsync:
	move.l	d0,-(sp)
	move.w	VBL_counter,d0
.Loop:
	cmp.w	VBL_counter,d0
	beq.s	.Loop
	move.l	(sp)+,d0
	rts

;*****************************************************************************
; [ Initialize the display registers in the copper list ]
; All registers are restored
;*****************************************************************************
Init_display_registers:
	movem.l	d0/a0,-(sp)
	lea.l	Copper_diwstrt,a0
	move.w	#12417,(a0)
	addq.l	#4,a0
	move.w	#200,d0
	addi.b	#48,d0
	lsl.w	#8,d0
	ori.w	#$c1,d0
	move.w	d0,(a0)
	addq.l	#4,a0
	clr.w	(a0)
	addq.l	#4,a0
	move.w	#56,(a0)
	addq.l	#4,a0
	move.w	#208,(a0)
	addq.l	#4,a0
	move.w	#5,d0
	ror.w	#4,d0
	ori.w	#$200,d0
	move.w	d0,(a0)
	addq.l	#4,a0
	move.w	#5,d0
	subq.w	#1,d0
	mulu.w	#40,d0
	move.w	d0,(a0)
	addq.l	#4,a0
	move.w	d0,(a0)
	movem.l	(sp)+,d0/a0
	rts


	SECTION	Chip_BSS,bss_c
	cnop	0,4				; (start of a separately linked object)
Screen_buffers:
	ds.b	7536

	SECTION	Fast_DATA,data
Interrupt_copper_server:
	dc.l	0		; Node.ln_Succ
	dc.l	0		; Node.ln_Pred
	dc.b	2		; Node.ln_Type
	dc.b	$7f		; Node.ln_Pri
	dc.l	AM2_copper_server		; Node.ln_Name ; Interrupt.is_Node
	dc.l	0		; Interrupt.is_Data
	dc.l	Run_copper		; Interrupt.is_Code ; struct Interrupt {
AM2_copper_server:
	dc.b	"AM2 - Copper server",0
Interrupt_input_handler:
	dc.l	0		; Node.ln_Succ
	dc.l	0		; Node.ln_Pred
	dc.b	2		; Node.ln_Type
	dc.b	$7f		; Node.ln_Pri
	dc.l	AM2_input_handler		; Node.ln_Name ; Interrupt.is_Node
	dc.l	IO_request_input		; Interrupt.is_Data
	dc.l	Run_input_handler		; Interrupt.is_Code ; struct Interrupt {
AM2_input_handler:
	dc.b	"AM2 - Input handler",0
Input_reply_port:
	dc.b	0,0,0,0,0,0,0,0,4,0,0,0,0,0,0
Input_signal:
	dc.b	0
	dc.l	0
Input_port_list_head:
	dc.l	Input_port_list_tail
Input_port_list_tail:
	dc.l	0,Input_port_list_head
	dc.b	0,0
IO_request_input:
	dc.l	0		; Node.ln_Succ
	dc.l	0		; Node.ln_Pred
	dc.b	7		; Node.ln_Type
	dc.b	0		; Node.ln_Pri
	dc.l	0		; Node.ln_Name ; Message.mn_Node
	dc.l	Input_reply_port		; Message.mn_ReplyPort
	dc.w	$30		; Message.mn_Length ; IOStdReq.io_Message
	dc.l	0		; IOStdReq.io_Device
	dc.l	0		; IOStdReq.io_Unit
	dc.w	0		; IOStdReq.io_Command
	dc.b	0		; IOStdReq.io_Flags
	dc.b	0		; IOStdReq.io_Error
	dc.l	0		; IOStdReq.io_Actual
	dc.l	0		; IOStdReq.io_Length
	dc.l	0		; IOStdReq.io_Data
	dc.l	0		; IOStdReq.io_Offset
IO_request_console:
	dc.l	0		; Node.ln_Succ
	dc.l	0		; Node.ln_Pred
	dc.b	7		; Node.ln_Type
	dc.b	0		; Node.ln_Pri
	dc.l	0		; Node.ln_Name ; Message.mn_Node
	dc.l	0		; Message.mn_ReplyPort
	dc.w	$30		; Message.mn_Length ; IOStdReq.io_Message
	dc.l	0		; IOStdReq.io_Device
	dc.l	0		; IOStdReq.io_Unit
	dc.w	0		; IOStdReq.io_Command
	dc.b	0		; IOStdReq.io_Flags
	dc.b	0		; IOStdReq.io_Error
	dc.l	0		; IOStdReq.io_Actual
	dc.l	0		; IOStdReq.io_Length
	dc.l	0		; IOStdReq.io_Data
	dc.l	0		; IOStdReq.io_Offset
Input_device:
	dc.b	"input.device",0
Console_device:
	dc.b	"console.device",0
Dos_library:
	dc.b	"dos.library",0
Graphics_library:
	dc.b	"graphics.library",0
	dc.b	0

	SECTION	Fast_BSS,bss
	ds.b	4092
	ds.l	1
Return_value:
	ds.l	1
Return_address:
	ds.l	1
Stack_pointer:
	ds.l	1
CPU_68020_plus:
	ds.b	1
Kickstart_2_flag:
	ds.b	1
VBR_location:
	ds.b	4
VBL_counter:
	ds.w	1
Library_dos:
	ds.l	1
Library_graphics:
	ds.l	1
Console_device_pointer:
	ds.l	1
Old_DMACON:
	ds.w	1
Gfx_base_acti_view_ptr:
	ds.l	1
Gfx_base_copper_start_up_list_ptr:
	ds.l	1
Own_task:
	ds.l	1
Old_window_ptr:
	ds.l	1
Old_window_ptr2:
	ds.l	1
Screen_flag:
	ds.b	2
Vertical_screen_offset:
	ds.w	1
Last_screen_offset:
	ds.w	1
On_screen:
	ds.l	1
Off_screen:
	ds.l	1
