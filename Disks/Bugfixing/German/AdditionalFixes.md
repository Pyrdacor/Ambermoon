## Version 1.10

Based on 1.09.

- Fixed "remove curse" spell. (Replace 3C 1F 41 E8 01 22 with 3C 1F 41 E9 01 22 in unimploded AM2_CPU and AM2_BLIT)
- Windshrine door can not be skipped via broom or eagle anymore.
- Fixed wrong spawn location when leaving the windshrine. (Change teleport event X from 17 to 16)
- Reverted max swim values from 99 to 95
- Reverted current swim value of Tar from 99 back to 90
- Reverted Nelvin's and Tar's max U-M and R-M skills from 99 back to 95
- Reverted item name "Krummsäbel" in AM2_BLIT to "SCIMITAR"
- Fixed Whip parry penalty (change relative item data byte 0x11 from 01 to 02). It now correctly reduces parry by 10.
- Fixed Banded Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 4.
- Fixed Plate Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 6.
- Fixed Knight's Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 8.
- Fixed skill penalty code for items (now uses correct offset of 8 instead of 6)
- Fixed Erik's initial attack skill value from 0 to -6 (his worn Plate Mail has a attack penalty of 6 and penalties now work)
- Fixed automap wall display glitch in palace of baron in Newlake (change byte 0x0AA1 in sub-file 005 in 2Lab_data from 0x80 to 0x82)
- Fixed a bug with NPC Matthias when you give him the 10000 gold for the harp
- Added an additional anti-smuggler protection to Morag :)
- Adjusted previous anti-smuggler protection (text color, item removal)

## Version 1.09

Based on 1.08.

- Temple of gala door can not be skipped via broom or eagle anymore.
- Crypt door can not be skipped via broom or eagle anymore.
- Lebab's tower door can not be skipped via broom or eagle anymore.
  Moreover you can't skip the gargoyle fight at the door by fleeing.
- Fixed double text-popup in Burnville when you look at the healer's sign.
- Fixed chest opening when you got hit by the spikes in the palace of S'Endar.
- The blacksmith in Newlake has now the correct name and repair cost.
- Fixed ship dealer in Spannenberg. Ships will now correctly be spawned.
- Spawn location of Gryban was again wrong. Now it is really fixed!
- When you try to bring the broom or magical disc to Morag it will
  be burned. This was done when you first entered the Morag hangar but
  not when you come back later. This is now fixed.
- When you come back to the S'Angrila prison after S'Riel has died you
  will now also see his bones and not only a popup on an empty floor.
- When you try really hard to smuggle the broom or magical disc onto
  Morag you will experience a surprise. Make sure to save beforehand!
- You can no longer pass Lebab's tower with the broom.
- Fixed a display bug in the S'Angrila prison.
- You will no longer get stucked inside the wall in Nera's cellar.
- You will no longer get stucked inside the wall in the mines of Dor Kiredon.
- Fixed disease attribute crippling.
- Fixed SP stealer amount.
- Fixed merchant issue with more than 32767 gold.

## Version 1.08

Based on 1.07.

- Fixed stair texture in Sansri's temple 1.
  - Map 422 (x=14, y=11)
  - Changed byte 0x3D2 from 0x72 to 0x73
- When returning with Dorina to Dor Kiredon the text
  popup said that you returned to Dor Grestin. This was
  fixed in 3Map_texts.amb (subfile 0x161, text index 0x9)
- Set initial charges of several chest items (forest moon plants) from 0 to 1
- Anti-Magic Sphere spell scroll now has the correct weight value
- Murder Blade and Dagger Sling now correctly use 1 hand
- Changed many occures of "ER" or "SEINE" to "~SEX1~" and "~SEX2~"
- Changed item names:
  - "MYSTISCHER GLOBE" -> "MYSTISCHER GLOBUS"
  - "ALCHEMIST. GLOBE" -> "ALCHEMIST. GLOBUS"
  - "VALDYNS LEDERSCHUHE" -> "VALDYN'S SCHUHE" (consistent with english version)
  - "MAGISCHE FLUGSCHEIB" -> "MAG. FLUGSCHEIBE"
  - "SANSRIES HALSBAND" -> "SANSRI'S HALSBAND"
- Changed Nelvin text "... EDLER <held>" to "... <held>" to fit for female heros
- A lot of party char, NPC and map text fixes
- Fixed harp quest
  - You need the elf harp to get the crystal harp
  - You can now also show/give the elf harp instead of the strings
- When entering Dor Kiredon for the first time all party members will learn the dwarf language.
- The lava pool in Luminor's torture chamber now blocks movement
- Killed Tornaks in dwarf mine will no longer re-appear when you have the egg
- Small text fix when finding Ferrin's daughter. Changed "ES" to "SIE".
- Killed Tornaks in the Tornak cave (below Ferrin's forge) will no longer re-appear when you have the egg
- Destroyed walls in the Tornak cave will not re-appear when you enter the map again with or without egg
- Pick-axe text popup in the Tornak cave will not trigger when the wall is gone anymore (while you have the egg)
- Sansrie is renamed to Sansri to be conform with the printed map and Amberstar
  - 4 items
  - Monster name
  - Many map and NPC texts

## Version 1.07

Fixes on top of the AMINET and Slothsoft patches

- Fixed Sansrie's key usage (map file 424 in 2Map_data.amb, changed word at offset 0x0346 from 0000 to 0165).
- Removed unused character data from map 258 (set the following bytes to 0: 0x4A to 0x51).
- Fixed golem that was flagged as partymember in temple of gala (map file 277 in 2Map_data.amb, change byte at 0x9A from 0 to 6 and remove 574 bytes at 0x154a).
- Fixed Reg hill giant boss flag
- Fixed two world maps (00D and 094) with wrong flags
- Fixed Gryban spawn location
- Fixed two corrupted wind gates
- Added a new teleport event form map 362 to map 361 (9,11) facing north. So the stairs to the lowest level in gadlon work now.
- Fixed button in bandit's cellar
- Fixed every single plant on Kire's moon (values are in decimal)
    - Map 308: Event 012
    - Map 309: Event 012
    - Map 310: Event 012
    - Map 312: Event 012
    - Map 313: Event 012 and 017
    - Map 315: Event 012 and 017
    - Map 316: Event 012 and 017
    - Map 317: Event 017
    - Map 318: Event 012 and 017
    - Map 319: Event 012 and 017
    - Map 320: Event 012 and 017
    - Map 321: Event 012 and 017
    - Map 323: Event 012, 017, 022 and 027
    - Map 324: Event 012, 017, 022 and 027
    - Map 325: Event 014, 019, 024 and 029
    - Map 326: Event 014, 019, 024 and 029
    - Map 327: Event 014, 019, 024 and 029
    - Map 328: Event 014, 019, 024 and 029
    - Map 329: Event 014, 019, 024 and 029
    - Map 330: Event 014, 019, 024 and 029
    - Map 331: Event 014, 019, 024 and 029
    - Map 332: Event 014, 019, 024 and 029
    - Map 333: Event 014, 019, 024 and 029
    - Map 334: Event 014, 019, 024 and 029
    - Map 335: Event 014, 019, 024 and 029
- Fixed wrong text index in Nalven's magical school
- Added 2 text popups to Thalion office map
- Fixed wind gate at around x=271 y=564 (no longer usable when broken)
- Added floor texture to S'Angrila (change byte 0x07 from 00 to 09 in labdata file 034 (0x22) in 2Lab_data.amb).
- Fixed wrong direction when teleporting from Luminor's tower 4 to 3 (change byte 0x32F from 01 to 03 in map file 297 (0x129) in 2Map_data.amb).


### Thalion office

This is map 257 (hex 101). I added two text popup events:
- Lift event should be triggered at 23,17 and 24,17 (text index 2)
- Stair event should be triggered at 14,16 and 15,17 (text index 3)

Tile data inside the map file starts at 0x14C. The map width is 40.

So for example to get to the event index for tile 23,17 you have to do the following:
1. Tiles are 1-based in game but 0-based in data so use x=22,y=16 for calculations.
2. The tile data is organized as rows so to get the tile index do y\*map_width+x. TileIndex = 16\*40+22 = 662.
3. Each tile on a 2D map uses 4 bytes of data so the byte offset inside the tile data is 662\*4 = 2648 (hex A58).
4. As mentioned tile data starts at 0x14C inside the map file so add this and get the total offset as 14C+A58=BA4.
5. Inside the 4 bytes of tile data the second byte contains the event index that should be triggered. So add 1 to the offset and get BA5.
6. Set this byte (should be 0 before) to the associated event index (see below).

At 0x14AC the event section starts. It started with 00 07 which is the amount of event chains on the map that can be reference through event index 1 to 7
in the tile data. As we want to add 2 new text popup event chains we have to change this to 00 09.

After this there are n event indices (2 bytes each) where n is the amount of event chains we just changed.
To make it short each of them represent the starting event index of an event chain.
So as the amount changed we have to add 2 new words (4 bytes in total) at 0x14BC.

Currently the map has 8 events (7 event chains but 8 single events). We will add 4 events.

Event index | Description
--- | ---
8 | Popup text at lift
9 | Action which disables the previous popup once triggered
10 (0xA) | Popup text at stairs
11 (0XB) | Action which disables the previous popup once triggered

We will make 2 event chains out of it as mentioned:

Event chain index | Description
--- | ---
7 | Popup lift -> Disable this popup
8 | Popup stairs -> Disable this popup

So coming back to the 2 new words we added they have to represent the first event index of each chain.
The first word is therefore 00 08 and the second word is 00 0A.

After that there is the total amount of events (not chains now!) which should be 00 08 before changing.
This should now become 00 0C (decimal 12) as we added 4 events.

With all data changes now it's time to add the real events. The last existing event ends now at 0x1522.
So there we will add the data for the 4 events. As each event has always 12 bytes we add 4\*12=48 bytes there.

Now we fill those bytes with life. Use the following bytes:

04 FF 03 00 00 02 00 00 00 00 00 09
0E 01 01 00 00 00 40 07 00 00 FF FF
04 FF 01 00 00 03 00 00 00 00 00 0B
0E 01 01 00 00 00 40 08 00 00 FF FF

Each row is one event. The first byte is the type (4 = text popup, E = action). I won't go much into each
value now but for the text events the text index is located at the 6th byte (here 2 and 3).
The action bits use values 400X to disable specific events. The last digit corresponds to the event chain
index you want to disable (7 and 8).

The last two bytes of each event gives a follow-up event (next event in the event chain). So the text
popups reference the action events there while the actions use FFFF which means (no more event).

Now let's finish the map by reference the event chains from tiles. You can calculate the tile data offsets
as shown above. Here the summary:

- Set byte at offset 0x0BA5 from 00 to 08 (left lift door)
- Set byte at offset 0x0BA9 from 00 to 08 (right lift door)
- Set byte at offset 0x0AE5 from 00 to 09 (upper stair tile)
- Set byte at offset 0x0B89 from 00 to 09 (lower stair tile)

Note that the event chain indices are 1-based inside the tile data. This is the case because 0 would mean
no event on the tile at all. So 9 means event chain 8 (0-based).