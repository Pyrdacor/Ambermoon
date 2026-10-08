# Ambermoon – source code of the main program (AM2), version 1.21

This folder contains the source code of the Ambermoon main program `AM2_CPU` in the
version 1.21. It was created by merging

* the **original source code** of Ambermoon by Jurie Horneman
  ([github.com/jhorneman/ambermoon](https://github.com/jhorneman/ambermoon), folder `src`), which is an
  older and incomplete snapshot (about version 1.0x), and
* the **disassembly of AM2_CPU 1.21** (`Disks/Bugfixing/Executables/AM2_CPU.s`).

The original modules keep their names, comments and structure. The bugfixes and changes of the later
versions were merged into them, and the parts which are missing in the original snapshot (the
"kernel": system, graphics, memory and file management, 3D renderer, music player, …) were
reconstructed from the disassembly, using the names the original code uses wherever possible.

**The source assembled to an executable which was byte-identical to `AM2_CPU` (1.21).** Since then,
new bugfixes were added (see the findings below), so the current build differs from 1.21.

## Building

```
cd src
vasmm68k_mot -m68030 -Fhunkexe -o AM2_CPU -nosym -kick1hunks -keepempty -no-opt -align AMBERMOON.S
```

(`vasmm68k_mot` is in `Disks/Bugfixing/Executables`, i.e. `../../Disks/Bugfixing/Executables/vasmm68k_mot.exe`
from inside `AmbermoonSource/src`.)

* `-no-opt` – no optimizations by vasm. The optimizations the original assembler did for the original
  modules are switched on in `AMBERMOON.S` with `opt o2+,o4+,o5+,o11+` (and off for the reconstructed
  code, which uses explicit encodings).
* `-align` – like the original assembler, `DC`/`DS`/`RS` with size `.w`/`.l` are aligned to even addresses.

vasm prints some warnings ("data has been auto-aligned", "deprecated instruction alias" for `divsl.l`
in the 68020 code of the CPU renderer). They are expected.

## Layout

| Path | Contents |
|------|----------|
| `src/AMBERMOON.S` | Build file: includes all modules in link order, fixes the order of the hunks. |
| `src/INCLUDES/` | Reconstructed include files: `MACROS.I` (Get, Free, Push, Pop, LOCAL, R_palette, …), `CONSTANTS.I` (constants the original uses but does not define), `HARDWARE.I` (custom chip registers, library offsets). |
| `src/*.S`, `src/COMBAT/`, `src/MAP/`, `src/HULL/` | The **original modules**, merged with the changes up to 1.21. |
| `src/GAME_OFF.S` | Original structure definitions (unchanged). |
| `src/KERNEL/` | **Reconstructed** kernel (missing in the original). |
| `src/MAP/3D_RENDER.S` | **Reconstructed** 3D renderer: walls, objects, floor & ceiling (CPU version). |
| `src/MAP/3D_BLIT.S`, `3D_BLIT2.S` | **Reconstructed** blitter versions of the 3D renderer (merged from AM2_BLIT in 1.21). |
| `src/MUSIC/SONIC_ARRANGER.S` | **Reconstructed** Sonic Arranger replay routine (original names of the replayer). |
| `src/LOADER/Ambermoon.s` | Loader `Ambermoon` (disassembly with names and bugfixes, separate executable). Build in `src/LOADER` with `vasmm68k_mot -m68030 -Fhunkexe -o Ambermoon -nosym -kick1hunks -keepempty -no-opt Ambermoon.s`. |
| `src/FAIRY.S`, `src/DIAGNOST.S` | Original files. `FAIRY.S` is not part of AM2. `DIAGNOST.S` is only partly assembled (cheat code is switched off). |
| `CHANGES.md` | List of all changes compared to the original source (generated from the comments). |
| `SYMBOLS.txt` | Label of the disassembly (`AM2_CPU.s`) → name in this source → file. |

### The kernel files

| File | Contents |
|------|----------|
| `KERNEL/START.S` | Program start, main loop, exit |
| `KERNEL/SYSTEM.S` | Taking over and restoring the system, screens, vertical blank |
| `KERNEL/GRAPHICS.S` | Blocks, icons, lines, boxes, pixels, masks, clip areas |
| `KERNEL/COLOURS.S` | Copper list, raster lists, fading, drug effect |
| `KERNEL/MOUSE.S` | Mouse pointer, mouse areas, mouse events |
| `KERNEL/TEXT.S` | Printing text (font, runes, text commands) |
| `KERNEL/MEMORY.S` | Memory manager (memory areas, blocks, handles, `Claim_pointer`, …) |
| `KERNEL/FILES.S`, `FILES2.S` | Loading/saving, AMBR/AMPC/AMNC/AMNP containers, decompression, file names, saved games |
| `KERNEL/INPUT.S` | Input handler, keyboard events, fatal errors |
| `KERNEL/DI_SCREEN.S` | Diagnostic screen |
| `KERNEL/ZOOM.S` | Zoomed graphics for combat |
| `KERNEL/TEXTS.S` | Loading of the texts, item data and button graphics (1.1x+) |
| `KERNEL/DATA.S` | Shared data tables (mouse pointers, palettes, spell data, file infos, …) |
| `KERNEL/CHIP_DATA.S`, `CHIP_BSS.S`, `BUFFERS.S` | Chip memory data, chip memory variables, large buffers |

## Names and comments in the reconstructed code

* Routines and variables which are used by the original code have the **original names** (e.g.
  `Claim_pointer`, `Load_subfile`, `Put_masked_block`, `Push_Module`, `put_dpoly`, `draw_zoomshape`).
* All other names were chosen in the style of the original. Constants and structure offsets are used
  where they are known (`CA_X2(a1)`, `Raster_list_ptr(a0)`, `bltcon0(a6)`, `_LVOOpenLibrary(a6)`, …).
* The comments of the disassembly were kept. Comments in a routine header below
  `NOTE (disassembly)` were also taken from it.
* Every routine has a header in the style of the original (`[ Title ]`, `IN`, `OUT`, `NOTE`).

## Changes compared to the original source

See `CHANGES.md`. The comments in the source use these markers:

* `FIX:` – a bugfix of a later version,
* `CHANGE:` – another change of a later version,
* `NOTE:` – a remark about the behaviour of 1.21,
* `BUILD:` – a change which was needed to assemble the source with vasm (no change of the program).

Besides that, two changes were applied to all original modules:

* Texts and the item data are no longer part of the executable (they are loaded from files, see
  `KERNEL/TEXTS.S`). The code accesses them through pointers: `move.l Prompts_ptr,a0` instead of
  `lea.l Prompts,a0`, `move.l Object_data_ptr,a1` instead of `lea.l Object_data+4,a1`.
* Encodings which the original assembler chose automatically were made explicit where vasm would
  choose differently (`addi.w` instead of `add.w` with an immediate, `addq.w #x,a0` instead of
  `lea.l x(a0),a0`, short backward branches `.s`, `opt` around lines the original assembler did not
  optimize). The program is not changed by this.

## Findings

* **AM2_CPU / AM2_BLIT merge** – The blitter versions in `MAP/3D_BLIT.S` contain three routines which
  are byte-identical to the CPU versions in `MAP/3D_RENDER.S` (only the comments differ):
  `Blit_project_wall` = `CPU_project_wall` (174 bytes), `Blit_clip_wall` = `CPU_clip_wall` (92 bytes),
  `Blit_make_zoom_mask` = `CPU_make_zoom_mask` (56 bytes). They use the same variables, so the blitter
  version could call the CPU routines (`jsr` instead of `bsr.w`, as they are in different hunks) and
  322 bytes could be saved. `Blit_zoomshape_tables` differs from `CPU_zoomshape_tables` on purpose.
  Everything else (`put_dpoly`, `draw_zoomshape`, `Insert_horizon` and the variables) is shared or
  selected via `Blitter_or_CPU` as it should be. This was left unchanged to keep the build identical.
* **Guru 8100 0005 on exit (fixed)** – `Copy_data` (`KERNEL/TEXTS.S`) used `btst d7,#1` instead of
  `btst #1,d7`, so for sizes which are a multiple of 8 one word too much was copied.
  `Load_button_graphics` copies 12168 bytes into `Control_icons`, which fills its hunk completely, so 2
  bytes behind the hunk were overwritten. This corrupted the memory list and the system crashed when
  the loader unloaded AM2.
* **Memory block table overflow (fixed)** – `Allocate_system_memory` (`KERNEL/MEMORY.S`) checked the limit of
  10 memory blocks only after allocating. The counter covers CHIP and FAST blocks together, so with 10
  CHIP blocks one FAST block was stored behind `File_info_pointers` (in `Sub_file_pointers`), was
  overwritten during the game, and `Free_all_memory` then freed a wrong block.
* **Game data size** – When `Charge_price` was added in 1.21, the size of the game data which is cleared
  at the start (`Init_program`) was not adapted. The last word (`Casting_participant+2`) is not cleared.
  This is harmless (see `MAIN.S`).
* **`Scroll_bar_result`** (`HULL/CONTROLS.S`) was defined with `rs.w` instead of `ds.w` in the original
  source. In the executable it is a variable at the end of the chip BSS.
* **`btst d0,#Stationary_mask`** (`ACTIONS.S`) only tests the low byte of the mask (the bit number is
  taken modulo 8), so for travel modes ≥ 8 bit `mode & 7` is tested. The original assembler truncated
  the mask silently; 1.21 behaves the same.
* The original was linked from several object files. Where the linker aligned sections to longwords,
  this is reproduced with `cnop 0,4`.
* Ghidra exported `Swap_COMOBs` and `Time_combat` (`COMBAT/COMOBS.S`) as data. They are unchanged.
