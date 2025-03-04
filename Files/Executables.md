# Executables

AM2_BLIT is the executable mainly for the Amiga 500, which uses the blitter.

AM2_CPU is the executable for every Amiga where the CPU renders faster than the blitter.

At the start of the program the main executable 'Ambermoon' will perform a speed test and dependent on it picks one of the two mentioned executables.

They all use the [hunk](Hunks.md) file format.

The same is true for the files Ambermoon_intro, Ambermoon_extro, Fantasy_intro and Keymap.

All of them might be compressed by the Imploder. I managed to reverse-engineer the algorithm so the deploding is possible even on PCs now. See [here](Imploding.md).

## Additional information

AM2_CPU/AM2_BLIT contain the item data, as well as some builtin-palettes and graphics (like the cursor, UI graphics or text glyphs). So decoding and reading it is necessary to edit/fix those things.

Fantasy_intro contains the Thalion intro with the fairy.
Ambermoon_intro contains the intro sequence and the main menu.
Ambermoon_extro contains the ending sequence.

There are 2 data hunks which are identical in both AM2_CPU and AM2_BLIT.

The first data hunk contains basically 3 things:
- First there are 160 bytes which store copper commands that can be used to fill Amiga hardware registers dynamically. There are data words which can be filled by code and then are transferred by the copper automatically.
- After that there are many UI graphics like window and button frames, damage splash and so on.
- At the end there are all kind of tables and values for the Sonic Arranger music playback like period and vibrato tables, space for the song pattern indices etc.

The second hunk contains a lot more stuff:
- It starts with 8 signed bytes which give the X and Y offsets for adjacent 2D tiles based on the direction values. So 2 bytes for each direction. Basically they contain only the values -1, 0 or 1 of course. Directions are Up, Right, Down and Left in that order.
- Then the same follows for 3D tiles. Here you can have 8 directions, so you'll find 16 bytes here. Directions are Up, UpRight, Right, DownRight, Down, DownLeft, Left and UpLeft in that order.
- After that the text "schnism" is stored as a null-terminated string (8 bytes in total).
- Then a pointer to that schnism test is stored as a relocatable absolute long address (so it is inside the reloc32 table).


## Texts and messages

Inside the second data hunk in all languages (german and english) and in AM2_CPU as well as AM2_BLIT the texts start at offset 0x7D46. As only text lengths differ and not code or other data, this offset can be relied on.

### Filenames

The section starts with 44 addresses which point to a filename entry. Those addresses are 32 bit ones, so you'll have a RELOC32 with these offsets. But they should start directly after the section. However they are not necessarily in the same order.

The following table gives the order in the filename address dictionary:

Index | File | Disk Ids | Disk Letters
--- | --- | --- | ---
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
15 | Chest_data.amb | 10 | J
16 | Monster_groups.amb | 8 | H
17 | Merchant_data.amb | 10 | J
18 | Combat_background.amb | 8 | H
19 | Monster_gfx.amb | 8 | H
20 | Automap.amb | 10 | J
21 | Object_texts.amb | 7 | G
22 | Event_pix.amb | 7 | G
23 | Layouts.amb | 7 | G
24 | Music.amb | 9 | I
25 | Palettes.amb | 7 | G
26 | Riddlemouth_graphics | 7 | G
27 | Dictionary.english (or .german) | 7 | G
28 | XObjects3D.amb | 4, 6 | D, F
29 | XOverlay3D.amb | 5, 6 | E, F
30 | XWall3D.amb | 5, 6 | E, F
31 | - | - | -
32 | XObjects3D.amb | 4, 6 | D, F
33 | Saves | 10 | J
34 | Party_texts.amb | 7 | G
35 | NPC_texts.amb | 7 | G
36 | Automap_graphics | 7 | G
37 | Place_data | 7 | G
38 | Combat_graphics | 7 | G
39 | Floors.amb | 7 | G
40 | Save.00/Party_char.amb (initial char values) | 10 | J
41 | Stationary | 7 | G
43 | Party_gfx.amb | 7 | G
43 | Object_icons | 7 | G

Each file entry starts with one or more bytes. For normal files without a number prefix, there is only a single byte which gives the disk id (1 to 10) which corresponds to disks A to J. For files with number prefix like 1Map_data.amb, 2Map_data.amb etc, there are multiple disk ids. One for each used number prefix.

For example the filename is given as 0Map_data.amb where 0 is a placeholder. There are 3 of these files in Ambermoon: 1Map_data.amb, 2Map_data.amb and 3Map_data.amb. So you will find 3 disk ids. After that there is another 0 byte, most likely to mark the end of the disk id list.

There are also files with only 2 number prefixes like 2Wall3D.amb and 3Wall3D.amb. They will still have 3 disk ids and the end marker 0 byte but the unused disk id is just set to 0. So the XWall3D.amb example has a header of 00 05 06 00.

After the disk id(s), there is the filename as shown in the table above. Only the XMap_data.amb names and other similar files are actually stored as 0Map_data.amb and so on as mentioned.

As filenames start with characters/bytes greater than 0x20 you can check how many disk ids are prepended as they all will be lower than 0x0B of course.

Every string ends with a terminating null (0 byte). This is true for all texts in the whole file!

### World names

After the filename there are the world names. Note that they always start on a word boundary so you might have to skip a byte after the last section to get there.

The world name section also starts with a address dictionary. It has 3 entries, one for each world: Lyramion, Kire's Moon and Morag. So the section starts with 3 long-words (32 bit each) which's offset again can be found in the following RELOC32 hunk.
  
Then the 3 world names follow which are used as the map name for world maps. At the end of the section again a zero byte is needed for word boundary.
  
### Messages
  
After the world name section there are messages that are created out of multiple texts and placeholders. Each entry starts with a few long-words which are addresses to fixed texts. Iterate over the long-words until you find one which doesn't start with a zero byte. This is the first text. The long-words before are addresses or placeholders (given by the invalid address 0x00000000). There is also one zero long-word at the end so don't count it as a placeholder. This marks the end of the format string addresses.

Then the strings follow. In general the addresses are in the same order as the texts but don't count on it!
  
The program will print the texts and will insert values or dynamic texts into the placeholder addresses at runtime. So you can interpret them as some kind of format string placeholder if you want to use them.
  
If you encounter a non-zero high byte of the first long-word, the text is a normal text and is directly used without placeholders. There is one exception and this is the byte 0xff. It seems like it serves the special purpose of "wait for a click". So don't interpret it as a text character or part of an address! The 0xff is mostly located after a null-terminated string.

As the long-words are word-aligned ensure to add/read a zero byte before each new text section.

At some point (after the string "That" in english), there starts a different section which also contains texts. It starts on a word boundary with a word which gives the total amount of texts that follow. This should be 300 (0x012c).
  
And then 300 null-terminated texts follow. Those will never have placeholders like above beside the integrated ones like ~LEAD~, ~SELF~, ~SEX1~ and so on. But those are inside the text and no text parts or addresses are needed.
  
Note that the texts don't need to start at word boundaries. So if you encounter a double zero, this means that there is an empty string in-between!
 
The whole section is finished by a zero word which has to start on a word boundary. Maybe it is even a zero long-word. Best skip all zero bytes at the end until you reach a non-zero byte.

### Automap names
  
Then the names for the automap types follow which can be seen in the legend of the dungeon map. There is no name for type "None" or "Wall" so it starts with type "Riddlemouth". All the names are null-terminated strings so if you just find a single zero byte, it is really an empty string. Some automap types have no in-game legend name like open doors or chests.

### Game option names

Then the five texts for the in-game options follow.

### Music titles

Then the 32 song titles follow. They do not include the Intro, MainMenu and Outro music but only those which are available ingame through the harp (from music.amb).

### Spell school names

Then the names of the seven spell schools follow. The 5th and 6th spell school are unused and have no name.

### Spell names

Then the 210 spell names follow. 30 spells for each of the 7 schools.

### Language names

Then the 8 language names follow.

### Class names

Then the 11 class names follow. The last two are "Animal" and "Monster" but they have no name (empty string).

### Race names

Then there are 16 race names. Race 13 is animal and 14 is monster. But there seems to be a bug as the animal text is in slot 14. So if you talk to the only animal NPC Necros he has no race name.

### To be continued ...
