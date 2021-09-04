# Executables

AM2_BLIT is the executable for Amiga 500, using the blitter.

AM2_CPU is the executable for Amiga 1200, using the CPU.

The Ambermoon main loader 'Ambermoon' (10kb) is performing a check at launch to determine which machine the game will run on.

They all use the [hunk](Hunks.md) file format.

The same is true for the files Ambermoon_intro, Ambermoon_extro, Fantasy_intro and Keymap.

All of them might be compressed by the Imploder. I managed to reverse-engineer the algorithm so the deploding is possible even on PCs now. See [here](Imploding.md).

## Additional information

AM2_CPU/AM2_BLIT contain the item data, as well as some builtin-palettes and graphics (like the cursor, UI graphics or text glyphs). So decoding and reading it is necessary to edit/fix those things.

Fantasy_intro contains the Thalion intro with the fairy.
Ambermoon_intro contains the intro sequence and the main menu.
Ambermoon_extro contains the ending sequence.
