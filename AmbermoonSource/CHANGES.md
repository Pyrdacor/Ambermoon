# Changes compared to the original source code

This list is generated from the comments in the source files.

* **FIX** – bugfix of a later version (1.0x – 1.21)
* **CHANGE** – other change of a later version
* **NOTE** – remark about the behaviour of 1.21
* **BUILD** – change needed to assemble the source with vasm (no change of the program)

Besides these, all original modules were changed in the same way:

* Texts and the item data are no longer part of the executable. They are loaded from files
  (see `KERNEL/TEXTS.S`). Instead of `lea.l <text>,an` the code uses `move.l <text>_ptr,an`.
* Some encodings chosen by the original assembler were made explicit (e.g. `addi` instead of `add`
  with an immediate, `addq.w #x,an` instead of `lea.l x(an),an`, short backward branches). This
  does not change the program.

## MAIN.S

* 18 text/item data references use pointers now.
* Line 24 – **NOTE**: In 1.21 the size was not adapted when Charge_price was added, so the last word of the game data (Casting_participant+2) is not cleared. This is harmless. Use Game_data_size/2-1 to fix it.
* Line 2496 – **FIX**: Enchanter price per charge (#125)  
  `Charge_price:	ds.w 1`
* Line 2542 – **BUILD**: Renamed (was Control_list_ptr). Unused, the one in HULL/CONTROLS.S is used.  
  `Control_list_ptr_MAIN:	ds.l 1`

## DISPLAY.S

* 9 text/item data references use pointers now.

## INVENTOR.S

* 83 text/item data references use pointers now.
* Line 460 – **FIX**: Removed "add.w Time_data_year,d0". The age is already increased every year (see [ Every_year ]) so it was counted twice.
* Line 1907 – **FIX**: Was "btst #Cursed,Item_bits_STATIC(a2)". A curse is only shown when the item was identified (Magic_check bit of the packet).
* Line 1970 – **CHANGE**: Was "Sex_use_strings-4". The gender names are taken from the text pointers (Male_txt_ptr, Female_txt_ptr, Both_txt_ptr follow).
* Line 2022 – **FIX**: Was 3 digits (too wide for the window)  
  `moveq.l	#2,d7`
* Line 2031 – **FIX**: Was 3 digits (too wide for the window)  
  `moveq.l	#2,d7`
* Line 2876 – **FIX**: Was "mulu.w #6,d0" (skills are 8 bytes)  
  `mulu.w	#Skill_data_size,d0`
* Line 2884 – **FIX**: Was "mulu.w #6,d0" (skills are 8 bytes)  
  `mulu.w	#Skill_data_size,d0`
* Line 3510 – **CHANGE**: The table Sex_use_strings is no longer needed. Its space is

## ACTIONS.S

* 10 text/item data references use pointers now.
* Line 136 – **BUILD**: "&$ff" added. BTST with an immediate operand only tests bits 0-7 (bit number modulo 8); the original assembler truncated the mask silently.
* Line 1160 – **FIX**: Removed "add.w Time_data_year,d0" (age counted twice)

## DIALOGUE.S

* 7 text/item data references use pointers now.
* Line 734 – **FIX**: Removed "add.w Time_data_year,d0" (age counted twice)

## AUTOMAPP.S

* 3 text/item data references use pointers now.

## MAGIC.S

* 11 text/item data references use pointers now.
* Line 920 – **FIX**: Was "Char_inventory(a0)", but a0 points to the window data. a1 points to the character data.
* Line 973 – **FIX**: Also checks for locked doors, places and riddlemouths, which could be jumped over (#98).

## CHARACTE.S

* 1 text/item data references use pointers now.

## MAP/3D_MAP.S

* Line 2507 – **FIX**: Was "mulu.w Map_width,d0" which read absolute address 4 instead of the map width (#127)  
  `mulu.w	Width_of_map,d0`

## TIME.S

* Line 224 – **FIX**: Was "mulu.w #6,d0" (attributes are 8 bytes)  
  `mulu.w	#Attr_data_size,d0`
* Line 260 – **FIX**: Removed "add.w Time_data_year,d0" (age counted twice)

## EVENTS.S

* 15 text/item data references use pointers now.
* Line 2403 – **FIX**: Random value 0...max-1 -> 1...max  
  `addq.w	#1,d2`
* Line 2422 – **FIX**: Random value 0...max-1 -> 1...max  
  `addq.w	#1,d2`
* Line 2440 – **FIX**: Random value 0...max-1 -> 1...max  
  `addq.w	#1,d2`
* Line 2462 – **FIX**: Random value 0...max-1 -> 1...max  
  `addq.w	#1,d2`

## PLACES.S

* 12 text/item data references use pointers now.
* Line 234 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Ok1`
* Line 353 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Ok`
* Line 404 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Ok`
* Line 522 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Ok`
* Line 737 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Ok`
* Line 774 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Ok`
* Line 861 – **FIX**: The gold check was moved behind the item selection,
* Line 906 – **FIX**: Item specific price per charge (#125)  
  `.Ok3:	moveq.l	#0,d0`
* Line 922 – **FIX**: Was Total_price (#125)  
  `divu.w	Charge_price,d0`
* Line 936 – **FIX**: Was Total_price (#125)  
  `mulu.w	Charge_price,d1`
* Line 993 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Ok`
* Line 1115 – **FIX**: Was bpl (gold is unsigned)  
  `bcc.s	.Yes`

## DIAGNOST.S

* 1 text/item data references use pointers now.

## COMBAT/COMBAT.S

* 10 text/item data references use pointers now.

## COMBAT/APRES.S

* 1 text/item data references use pointers now.

## COMBAT/MONSTER_.S

* 5 text/item data references use pointers now.
* Line 429 – **FIX**: Was 24 (wrong end of last row)  
  `cmp.w	#30,d7`

## COMBAT/COMBAT_M.S

* 13 text/item data references use pointers now.
* Line 831 – **FIX**: Was "sub.w d0,..." (d0 = caster's new PP)
* Line 865 – **FIX**: d5 -> d4 here and below. d4 holds the stolen PP (code was copied from the LP stealer).

## HULL/MODULE_C.S

* Line 591 – **BUILD**: Renamed (was Number, which is also defined in MAIN.S). The hull was assembled separately.  
  `Hull_number:	ds.b 11`

## HULL/CONTROLS.S

* 9 text/item data references use pointers now.
* Line 1415 – **BUILD**: Hull_number (see HULL/MODULE_C.S)  
  `lea.l	Hull_number,a0`
* Line 1786 – **BUILD**: "rs.w" did not reserve any memory here. In the executable this variable is located at the end of the CHIP BSS (see KERNEL/CHIP_BSS.S).

