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

## Texts and messages

Inside the second data hunk in all languages (german and english) and in AM2_CPU as well as AM2_BLIT the texts start at offset 0x7D46. As only text lengths differ and not code or other data, this offset can be relied on.

### Filenames

The section starts with 44 addresses which point to a filename entry. Those addresses are 32 bit ones, so you'll have a RELOC32 with these offsets. But they should start directly after the section. However they are not necessarily in the same order.

The following table gives the order in the filename address dictionary:

Index | File | Disk Ids | Disk Letters
--- | --- | ---
0 | Party_data.sav | 10 | J
1 | Party_char.amb | 10 | J
2 | NPC_char.amb | 7 | G
3 | Monster_char_data.amb | 8 | H
4 | Portraits.amb | 7 | G
5 | XMap_data.amb | 3, 4, 6 | C, D, F
6 | Icon_data.amb | 7 | G
7 | XIcon_gfx.amb | 3, 4, 6 | C, D, F
8 | Travel_gfx.amb | 7 | G
9 | NPC_gfx.amb | 7 | G
10 | XLab_data.amb | 4, 6 | D, F
11 | XWall3D.amb | 5, 6 | E, F
12 | Lab_background.amb | 7 | G
13 | Pics_80x80.amb | 7 | G
14 | XMap_texts.amb | 3, 4, 6 | C, D, F

Each file entry starts with one or more bytes. For normal files without a number prefix, there is only a single byte which gives the disk id (1 to 10) which corresponds to disks A to J. For files with number prefix like 1Map_data.amb, 2Map_data.amb etc, there are multiple disk ids. One for each used number prefix.

For example the filename is given as 0Map_data.amb where 0 is a placeholder. There are 3 of these files in Ambermoon: 1Map_data.amb, 2Map_data.amb and 3Map_data.amb. So you will find 3 disk ids. After that there is another 0 byte, most likely to mark the end of the disk id list.

There are also files with only 2 number prefixes like 2Wall3D.amb and 3Wall3D.amb. They will only have 2 disk ids and the end marker 0 byte.

After the disk id(s), there is the filename as shown in the table above. Only the XMap_data.amb names and other similar files are actually stored as 0Map_data.amb and so on as mentioned.

As filenames start with characters/bytes greater than 0x20 you can check how many disk ids are prepended as they all will be lower than 0x0B of course.

Every string ends with a terminating null (0 byte). This is true for all texts in the whole file!

### World names

After the filename there are the world names. Note that they always start on a word boundary so you might have to skip a byte after the last section to get there.

The world name section also starts with a address dictionary. It has 3 entries, one for each world: Lyramion, Kire's Moon and Morag. So the section
