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
* **Music:** the music of the ST version (YM2149, MFP timers: the Falcon has both). Later maybe the Amiga
  music with samples on the DMA sound of the Falcon.
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
