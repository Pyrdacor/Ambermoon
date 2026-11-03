AMBERMOON for the Atari Falcon030 - version @VERSION@
===================================================

This is a test version of Ambermoon for the Atari Falcon030. It is built from
the original source code of the Amiga version, with the original graphics in
32 colours, the intros, the ending and the music of the Amiga. The game is the
German version 1.20.

It is a beta version: everything is there, but it was only tested in the
emulator Hatari so far, not on a real Falcon. Expect bugs. Please report them at
https://github.com/Pyrdacor/Ambermoon/issues (with what you did, and if
possible a screenshot).


Requirements
------------

- Atari Falcon030 (or Hatari with --machine falcon)
- 4 MB RAM (1 MB is not enough)
- RGB monitor, TV or VGA monitor (not the SM124 mono monitor)
- a hard disk (or a folder of the GEMDOS drive in Hatari): about 6 MB


Installation
------------

1. Copy the folder AMBERMOO with everything in it to the hard disk.
2. Start AMBERFAL.PRG in that folder.

The savegames are written into AMBERMOO\DATA.


What is different from the Amiga version
----------------------------------------

- The music is mixed by the DSP (by the CPU if the DSP does not answer).
- The parts of the intro with big zooms run slower (the Amiga does them with
  its blitter).
- After the ending the program ends; the Amiga asks whether to see it again.
- On a VGA monitor the picture runs at 60 Hz with black bars above and below,
  the game itself runs at 50 Hz like on the Amiga.
- The wobbling screen when the party is drugged is missing.
