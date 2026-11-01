# Atari Falcon port – plan

The Falcon version is built from the same parts as the ST port (`AmbermoonST/port`, see its `PORT.md` and
`HANDOVER.md`): the original source (`AmbermoonSource/src`) with the patches of the ST port, and the ST kernel.
Only the parts which depend on the video hardware are different. Nothing is copied: the build of the Falcon
version takes everything from `AmbermoonST` and puts the files of this folder on top, so a fix in a common part
is a fix for both versions.

## Decisions

* **Screen:** 320x200 with 256 colours (8 bitplanes, VIDEL). The Amiga screen is split into areas with
  their own palette of 32 colours (status bar and portraits, map, combat, ...). On the ST every area gets a
  reduced palette of 16 colours, switched by raster interrupts. On the Falcon every palette of the raster list
  gets its own **bank** of 32 colours: colour number = bank * 32 + Amiga colour, the planes 5-7 of a pixel are
  the bank. No raster interrupts, no colour reduction, the palettes are the original ones.
* **Graphics:** the original Amiga graphics (32 colours), unpacked by the tool (no decompression at run time,
  like the ST data), drawn without any conversion of colours: planes 0-4 from the graphic (with its base
  colour), planes 5-7 the bank of the line. The in-memory format stays the Amiga one, so the original code
  (offsets, recolouring of the monsters) needs no changes.
* **Code:** one kernel. The ST kernel is split into common files and files for the hardware (video, colours,
  graphics, mouse pointer, text output). `AmbermoonFalcon/KERNEL` has only the Falcon versions of the hardware
  files; the build copies the ST kernel and replaces those.
* **Music:** the Amiga music with the original Sonic Arranger replay (`KERNEL/MUSIC.S`, patch
  `PATCHES/SONIC_ARRANGER.diff`): the replay writes an emulated Paula, a mixer plays the 4 channels on the DMA sound
  (16 bit stereo, 24585 Hz).
* **CPU:** 68030. The 68020 code of the original (3D) can stay.

## Stages

1. Split the ST kernel: common parts and hardware parts (the ST port must stay the same: test runs before and
   after).
2. Build of the Falcon version (`build.sh`): sources, patches and kernel of the ST port, the Falcon files on
   top, 68030.
3. Falcon kernel: video (VIDEL 320x200x256, 50 Hz), palettes in banks and fading, graphics, text, mouse
   pointer. Goal: character editor, event, 2D map like on the ST, with 32 colours.
4. Data: the game files with the graphics unpacked for the Falcon (shared tool code with the ST port).
5. Everything which the ST port gets later (combat, 3D maps) for both.

## Testing

Hatari as Falcon (`--machine falcon`), EmuTOS of the Hatari folder (the 1 MB image supports the Falcon), the
test runner of the ST port (`AmbermoonST/port/test/run.py`, `MACHINE=falcon`).

## State

* Stages 1-3 are done for the parts which the ST port has: in Hatari (Falcon, 14 MB, RGB monitor) the
  character editor, the first event and the 2D map of grandfather's house run with the original colours.
* Build: `./build.sh` (needs vasm and Python 3 with Pillow) → `build/hd/AMBERFAL.PRG`; start: `./run_hatari.sh`.
* Test: `AmbermoonST/port/test/run.py` with `TEXT_BASE=20018 MACHINE=falcon MEM=14336 HATARI_ARGS="--monitor rgb"`,
  `HD` and `PRG` of this build (the text segment starts at `$20018` with the EmuTOS of Hatari 2.6 on a Falcon).
* Colour ranges (one colour in every line : the gradient behind the portraits, the sky of the cities) : every
  line gets its own colour from the end of the 256 colours downwards (RASTER.S), the graphics routines draw the
  pixels of the colour of the range in the colour of the line.
* 3D maps (dungeons, cities with sky, horizon and stars) : the CPU renderer of the original
  (`MAP/3D_RENDER.S`) runs on the 68030 as it is (`KERNEL/3D.S`, the ST kernel has stubs in its `3D.S`), it
  draws the 3D view into the MOVEP screen (4 planes), `Show_MOVEP_screen` (GRAPHICS.S) puts it on the screen
  with the bank of the line and the sky range. Tested by starting a test copy of the data in a 3D map (the
  position in the `Party_data.sav` files, `AmbermoonST/port/test/set_start.py`, e.g. map 416 at 28,11).
* Combat : the zoom of the monsters (`KERNEL/ZOOM.S`, the blitter in the Amiga version) zooms the visible part
  into a buffer as an Amiga graphic, `Put_masked_block` / `Put_masked_silhouette` draw it.
* VGA monitors : 320 x 200 (the middle 200 lines of the 240 of the VGA mode, VDB / VDE) at 60 Hz. The game
  runs at 50 Hz with Timer C (200 Hz, every 4th interrupt : fades, vertical blank handler, music), the vertical
  blank only shows the colours; while a file is accessed the TOS gets Timer C too (SYSTEM.S, LIBS.S). Test :
  `HATARI_ARGS="--monitor vga"` (the frames of a scenario times 1.2 : Hatari counts 60 frames per second).
* Memory : 4 MB (the usual Falcon) are enough, tested with a 3D map with floor and ceiling and a combat with
  zoomed monsters; even 2 MB work. With 1 MB the TOS does not start the program (not enough memory).
* Intro and main menu : `KERNEL/INTRO.S` is the code of `Ambermoon_intro`, made by `tools/intro_source.py` (byte
  identical without changes) and `tools/intro_patch.py`; the hardware in `KERNEL/INTRO_HW.S` : a blitter in software,
  the Amiga screens are converted to the Falcon screen, the sprite is the kernel pointer. The data comes from
  `tools/intro_data.py` at build time. The ST has an empty `Run_intro`.
* The fairy : `KERNEL/FANTASY.S` is the code of `Fantasy_intro` (imploded, `deplode` in `tools/hunks.py`), made by
  `tools/intro_source.py ... fantasy` and `tools/fantasy_patch.py`; `KERNEL/FANTASY_HW.S` : the sprites are drawn into
  the screen, only the lines which change are converted.
* Music : two players of the 4 channels. The DSP (`KERNEL/MUSIC_DSP.S`, `KERNEL/DSP_MIX.ASM`, assembled by `tools/dsp_asm.py`) mixes in the
  SSI interrupt and sends to the DAC directly, the samples of a song go to its memory at `SA_Hardcalc`, the channels
  in every vertical blank. The CPU (`KERNEL/MUSIC.S`) mixes into the DMA buffer. `Music_use_dsp` in `MUSIC.S` chooses (now the
  DSP); if the DSP does not answer at the start the CPU plays. Only in Hatari so far, not on a real Falcon.
* CPU load (Hatari profiler, `profile on` / `profile save`, 16 MHz; the cycles of Hatari are an estimate, a real Falcon can
  differ) : music 26 % with the CPU player, 1.5 % with the DSP player. 3D map 16.7 frames per second without music, 12.4 with the
  CPU player, 13.6 with the DSP player. Intro with big zooms 6 frames per second with the CPU player, 7.9 with the DSP player (74 %
  software blitter, 9 % conversion). Unpacking pictures below 0.1 %.
* Open: `Ambermoon_extro` (a separate Amiga program), the graphics unpacked in advance (the data are the original files, the game unpacks them
  itself), the zoom and the 3D maps on the ST (68000 replacements of the 68020 code).
