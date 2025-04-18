## Version 1.19

- Fixed wrong magic weapon level for Mando.
- Fixed invalid look-at text indices for Gryban and Chris.
- Fixed wrong max values for Netsrak's skills UseMagic and ReadMagic.
- Fixed wrong Lyramion world map data file.


## Version 1.18

- Fixed 2 buttons in Antique Area 2 which were not changed back after pressing them again (inside the circle with lightnings)
- Cleaned up unused map event data from Antique Area 4 (those are copies from Antique Area 2, so I guess they copied the map before editing)
- Fixed an event in Dor Kiredon so that random encounters with Gizzeks can happen near the town walls
- Fixed an event in Dorina's cave so that a specific flame not only show a message but also actually hurts like the others
- Pelanis will now correctly react to several words after you gave him Sansri's blood
- The character of Monika Krawinkel finally got a female sprite on the map
- Fixed some issues in Kire's residence
  - There were many tile issues where front layers were missing etc
  - Improved the treasure chamber door
  - Adjusted the south entrance position to fit the corridore
  - Fixed wrong key index for door on map 337
- Fixed a wrong event chain in Morag hangar (wasn't noticable in game though)
- Adjusted some weapon levels (M-B-W value)
  - Zweihander: 0 -> 1
  - Holy Sword: 0 -> 1
  - Trident: 0 -> 1
  - Crossbow: 0 -> 1
  - Mando's Sword: 0 -> 2
  - Murderer's Blade: 0 -> 1
  - Firebrand: 2 -> 1
  - Valdyn's Sword: 3 -> 1
  - Gala's Club: 2 -> 1
  - Scimitar: 1 -> 2
- The item Target Brooch is now correctly classified as Brooch and no longer as Amulet
- Fixed some issues in the cellar of the house of bandits
  - Text about two buttons is no longer displayed when missing the first teleport (there is only 1 button there)
  - Text about two buttons is no longer displayed multiple times when moving through the rooms
  - Text about two buttons is no longer displayed when you already made peace with Nagier
  - Fixed a bug where you could enter Nagier's bedroom by activating a button through the wall
- Fixed swim damage bug near alchemist tower

## Version 1.17

- Fixed some broken map events introduced in 1.16 (bandit's house)
- Fixed a text bug for NPC Bellard
- Fixed a text bug when approaching S'Kat
- Improved a text in the temple of S'Trog
- Fixed a text in the S'Angrila prison
- Fixed a typo in Ketnar's texts
- Fixed a typo in Dor Kiredon welcome message
- Fixed tile issues at the stairs in the Thalion office
- Fixed tiles on the forest moon (around 150,80)
- You can no longer walk and land on lava
- Dramatic music won't play forever after S'Arin anymore
- Dorina no longer stays in here hideout when you took her to Dor Kiredon
- Fixed Luminor:
  - You can't leave the room or remove his flame until he is dead.
  - You can't pour any more ice water onto the flame (which has gone) after Luminor is dead.
  - You can't re-spawn the flame in any way or cause invisible hurt events anymore.
  - If you skipped the basement, there will be no text about the flame after Luminor and the flame have gone.
- Fixed non-moving electric spark in Antique Area 2
- The number door in Antique Area 2 is no longer clickable after it was opened
- The door to Kire's treasure chamber is now also locked if you not already opened it
- The door to Kire's treasure chamber is no longer locked after opening and the key is consumed directly
- Fixed the installer

## Version 1.16

- Fixed crash when closing the game (introduce in 1.13)
- Fixed second eagle memory handle crash (when releasing the eagle)
- Fixed several tiles which allowed moving into walls (bandit's house, spannenberg and illien inn)
- Fixed wrong case in the text when entering the hangar
- Greatly improved Sansri's temple
  - Unused levers are marked on the map
  - Unused hourglasses are marked on the map
  - Missing text when destroying hourglasses were added
  - Improved the events that happen when the special walls come down
  - Improved which levers open which walls
  - Moved one hourglass to the end of the first level (feels much better)
  - Minor adjustments which improve the feel of the dungeon
- Fixed several NPCs (unused texts etc)
  - Sandra
  - Ketnar
  - Drongeb
- You can now talk to the two patients in the house of healers in Burnville
- The race name for animal NPCs is now correctly displayed
- Fixed name in last will

## Version 1.15

- Fixed memory handle crash when using eagle (fix got lost in previous patch)
- Renamed condition "Veralterung" to "Alterung"
- Fixed option name "MMusik" to "Musik"
- Fixed endboss defeat message: replaced "BEGABEN" with "BEGRABEN"
- Renamed "PELANI" to "PELANIS" (is the correct name in Amberstar and english version)
- Fixed NPC Brog (events and texts)
- Nera's Ring is now marked as "important"

## Version 1.14

- Added fixed Fantasy_intro which should also run on 060 CPUs
- Added missing skill names for read and use magic

## Version 1.13

- Merged AM2_BLIT into AM2_CPU
- Extracted all in-game texts to Text.amb
- Extracted all item data to Objects.amb
- Extracted all button graphics to Button_graphics
- Renamed Monster_char_data.amb to Monster_char.amb
- Renamed Dictionary.german to Dict.amb
- Added loader for the extracted files
- Fixed a typo in Kire's texts ("KONTAKE" -> "KONTAKTE", NPC_texts.amb file 055 sub-file 005)
- Fixed a glitch where it was possible to enter the upper part of the shipyard, also adjusted some tiles there

## Version 1.12

- Fixed "out of memory handles" crash when using the eagle multiple times.
- Remove "create item" event from Father Anthony as the cupboard key can be found on your table.
- Fixed text of NPC Theresa: "NEHMMT" -> "NEHMT"
- Fixed text in Nalven's magical school: "IN IN" -> "IN"
- Fixed dictionary entry "REPERATUR" to "REPARATUR" (you get this from Theresa)

## Version 1.11

- When saying "Tochter" to Sandra you now will also get the chest key and not the tunnel key.
- Fixed "ENKEL" to "ENKELKIND" in object text 001.002 (testament).
- A spider in the bandit's cellar did not move previously. This is fixed now.
- Fixed automap wall display glitch in hill caves and beast cave (change byte 0x0641 in sub-file 026 in 2Lab_data.amb from 0x80 to 0x82)
- The monsters in Gadlon cellar 1 now are active on the map (previously due to a bug they were behind the outside walls)
- Chris' boots are no longer broken but instead identified (change byte 0x014F in sub-file 005 in Party_char.amb from 0x02 to 0x01)
- Flying disc is not broken in the chest in the Thalion office (change byte 0x33 in sub-file 125 in Chest_data.amb from 0x02 to 0x00)
- Wrong tiles on Morag surface fixed by editing map 516 
- Female Tornak now grants 650 Exp instead of 0 (change bytes 0x20 and 0x21 in sub-file 055 of Monster_char_data from 0x0000 to 0x028A)
- Fixed "IST SIND" to "SIND" in NPC_texts.amb sub-file 030 (0x1E), text 010 (0x0A). This is Baron Karsten of Newlake.
- The item Topaz was renamed to Topas at it's the correct german name and it is also referenced this way in Kire's message.

## Version 1.10

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