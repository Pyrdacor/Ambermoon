# Executables

AM2_CPU and AM2_BLIT are the two main executables of Ambermoon. They use the [hunk](Hunks.md) file format.

AM2_CPU is compressed by the Imploder. I managed to reverse-engineer the algorithm so the deploding is possible even on PCs now. See [here](Imploding.md).

## Additional information

AM2_CPU contains the item data, as well as some builtin-palettes and graphics (like the cursor). So decoding and reading it is necessary to edit/fix those things.