# Executables

AM2_CPU and AM2_BLIT are the two main executables of Ambermoon. They use the [hunk](Hunks.md) file format.

The same is true for the files Ambermoon_intro, Ambermoon_extro, Fantasy_intro and Keymap.

All of them might be compressed by the Imploder. I managed to reverse-engineer the algorithm so the deploding is possible even on PCs now. See [here](Imploding.md).

## Additional information

AM2_CPU/AM2_BLIT contain the item data, as well as some builtin-palettes and graphics (like the cursor, UI graphics or text glyphs). So decoding and reading it is necessary to edit/fix those things.

AM2_BLIT is basically the same as AM2_CPU but allows for faster rendering on better hardware.

Fantasy_intro contains the Thalion intro with the fairy.
Ambermoon_intro contains the intro sequence and the main menu.
Ambermoon_extro contains the ending sequence.
