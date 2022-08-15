## Version 1.17

- Fixed some broken map events introduced in 1.16 (bandit's house)
- Kire's treasure room is not open on first visit anymore
- Improved a text in the temple of S'Trog
- Fixed a text in the S'Angrila prison

## Version 1.16

- Fixed crash when closing the game (introduce in 1.14)
- Fixed second eagle memory handle crash (when releasing the eagle)
- Fixed several tiles which allowed moving into walls (bandit's house, spannenberg and illien inn)
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
- Mando's sword now grants Ghost Weapon instead of Fire Pillar (like in the german version)

## Version 1.15

- Fixed memory handle crash when using eagle (fix got lost in previous patch)
- Fixed text when using the elf harp at the crystal wall to work for females as well
- Fixed wrong translation of Pelanis' farewell text
- Fixed NPC Brog (events and texts)
- Nera's Ring is now marked as "important"

## Version 1.14

- Merged AM2_BLIT into AM2_CPU
- Extracted all in-game texts to Text.amb
- Extracted all item data to Objects.amb
- Extracted all button graphics to Button_graphics
- Renamed Monster_char_data.amb to Monster_char.amb
- Renamed Dictionary.english to Dict.amb
- Added loader for the extracted files
- Renamed spell "Escape" to "Flight" to match the scroll item name
- Fixed "CELLAR" to "CELL" in Clementine's text about the madman (NPC_texts.amb file 006, sub-file 006)
- Fixed a glitch where it was possible to enter the upper part of the shipyard, also adjusted some tiles there

## Version 1.13

- Fixed "out of memory handles" crash when using the eagle multiple times.
- Remove "create item" event from Father Anthony as the cupboard key can be found on your table.
- Fixed "GRANDSON" to "GRANDCHILD" in last will.

## Version 1.12

- A spider in the bandit's cellar did not move previously. This is fixed now.
- Fixed automap wall display glitch in hill caves and beast cave (change byte 0x0641 in sub-file 026 in 2Lab_data.amb from 0x80 to 0x82)
- Changed "FISHERMEN" to "FISHERMAN" when observing Sally.
- The monsters in Gadlon cellar 1 now are active on the map (previously due to a bug they were behind the outside walls)
- Chris' boots are no longer broken but instead identified (change byte 0x014F in sub-file 005 in Party_char.amb from 0x02 to 0x01)
- Flying disc is not broken in the chest in the Thalion office (change byte 0x33 in sub-file 125 in Chest_data.amb from 0x02 to 0x00)
- Wrong tiles on Morag surface fixed by editing map 516
- Female Tornak now grants 650 Exp instead of 0 (change bytes 0x20 and 0x21 in sub-file 055 of Monster_char_data from 0x0000 to 0x028A)

## Version 1.11

- Fixed "remove curse" spell. (Replace 3C 1F 41 E8 01 22 with 3C 1F 41 E9 01 22 in unimploded AM2_CPU and AM2_BLIT)
- Windshrine door can not be skipped via broom or eagle anymore.
- Fixed wrong spawn location when leaving the windshrine. (Change teleport event X from 17 to 16)
- Adjusted Selena's max crit from 2 to 5 (Mando also has 5 so this is most likely the correct value)
- Adjusted Netsrak's initial magic attack level from 0 to 1 (Scimitar grants this)
- Fixed Netsrak's max R-M and U-M skill to 99
- Adjusted Erik's initial magic attack level from 0 to 1 (Scimitar grants this)
- Adjusted Chris' strength bonus value from 0 to 5 (he starts with Morag Dart which grants 5 strength)
- Adjusted Chris' dexterity bonus value from 30 to 0 (he has no equip which grants dexterity bonus, twisted with speed)
- Adjusted Chris' speed bonus value from 0 to 30 (magician boots grant 25 speed, Mitrhil Mail grants 5 speed)
- Adjusted Chris' luck bonus value from 10 to 0 (he has no equip which grants luck bonus, twister with anti-magic)
- Adjusted Chris' anti-magic bonus value from 0 to 10 (his anti-magic ring grants that bonus)
- Adjusted Chris' attack skill bonus value from 30 to 25 (only the Morag Dart grants 25 attack)
- Adjusted Chris' parry skill bonus value from 0 to 30 (Parry Ring grants 25 and Mitrhil Mail grants another 5)
- Swapped Chris' bonus values of R-M and U-M which were twisted before. Now 0 R-M and 25 U-M. The latter given by the Magician Boots.
- Adjusted Chris' SP bonus from 30 to 25 (Magician Boots only grant 25)
- Adjusted Valdyn's speed bonus from 15 to 25 (his shoes grant 15, armor another 10)
- Adjusted Targor's attack skill bonus from 0 to 10 (throwing sickle grants this bonus)
- Adjusted Leonaria's intelligence bonus value from 5 to 0 (there is no equip which grants INT, most likely confused with anti-magic)
- Adjusted Leonaria's anti-magic bonus value from 0 to 5 (Robe of the Mage grants this bonus)
- Adjusted Gryban's strength bonus value from 0 to 5 (the holy sword grant this)
- Adjusted Gryban's luck and anti-magic bonus values, which were twisted. Now luck +0 and anti-magic +5, knight's armour grants the 5 anti-magic)
- Adjusted Gryban's attack skill bonus value from 0 to 5 (holy sword bonus)
- Adjusted Gryban's R-M bonus value from 25 to 0 (no equip grants that)
- Adjusted Gryban's U-M bonus value from 0 to 25 (most likely twisted with R-M, knight's armour bonus)
- Adjusted Gryban's SP bonus value from 10 to 5 (knight's armour grants only 5)
- Changed item name "NACRE CHAIN" to "PEARL CHAIN"
- Fixed Whip parry penalty (change relative item data byte 0x11 from 01 to 02). It now correctly reduces parry by 10.
- Fixed Banded Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 4.
- Fixed Plate Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 6.
- Fixed Knight's Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 8.
- Fixed skill penalty code for items (now uses correct offset of 8 instead of 6)
- Fixed automap wall display glitch in palace of baron in Newlake (change byte 0x0AA1 in sub-file 005 in 2Lab_data from 0x80 to 0x82)
- Fixed a bug with NPC Matthias when you give him the 10000 gold for the harp
- Added an additional anti-smuggler protection to Morag :)
- Adjusted previous anti-smuggler protection (text color, item removal)

## Version 1.10

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

## Version 1.09

- Fixed stair texture in Sansri's temple 1.
  - Map 422 (x=14, y=11)
  - Changed byte 0x3D2 from 0x72 to 0x73
- When returning with Dorina to Dor Kiredon the text
  popup said that you returned to Dor Grestin. This was
  fixed in 3Map_texts.amb (subfile 0x161, text index 0x9)
- Changed "WIND CALLS" to "WIND SHRINE".
- Improved riddlemouth texts in grandfather's cellar and Illien
- Set initial charges of several chest items (forest moon plants) from 0 to 1
- Both map versions of the Morag hangar and prison of S'Angrila now use the same translations
- Anti-Magic Sphere spell scroll now has the correct weight value
- Murder Blade and Dagger Sling now correctly use 1 hand
- Fixed harp quest
  - You need the elf harp to get the crystal harp
  - You can now also show/give the elf harp instead of the strings
- Replaced "ORKS" with "ORCS"
- When entering Dor Kiredon for the first time all party members will learn the dwarf language.
- The lava pool in Luminor's torture chamber now blocks movement
- Killed Tornaks in dwarf mine will no longer re-appear when you have the egg
- Killed Tornaks in the Tornak cave (below Ferrin's forge) will no longer re-appear when you have the egg
- Sansrie is renamed to Sansri to be conform with the printed map and Amberstar
  - 4 items
  - Monster name
  - Many map and NPC texts
- Improved riddlemouth in Illien (sub text file 0x009 in map 0x01A)
- Fixed the text of magic spring 4 in Illien
- Destroyed walls in the Tornak cave will not re-appear when you enter the map again with or without egg
- Pick-axe text popup in the Tornak cave will not trigger when the wall is gone anymore (while you have the egg)

## Version 1.08

Fixed in relation to the excel sheet from Alex Holland.
Based on the Meynaf patch.

- Fixed text about Pelani's concerns in his palace. Fixed in subfile 004 of texts for map 1A1.
- Fixed bad text translation at the statue in the temple of Gala. Fixed in subfile 006 of texts for map 115.
- Sansri's key now opens the door in her tunnel. Fixed in map 424 in 2Map_data.amb.
- Fixed SANSRIE'S to SANSRI'S. Fixed in subfile 008. (Change is reversed in 1.09 as SANSRI is used there entirely.)
- Replaced "STEIN" by "STONE" in Illien riddlemouth text. Fixed in subfile 010 of texts for map 1A0.
- Replaced "STEIN" by "STONE" in Dor Kiredon text. Fixed in subfile 005 of texts for map 157.
- Replaced "SPELL" by "SMELL" in Dor Kiredon text. Fixed in subfile 014 of texts for map 157.
- Fixed wrong displayed open times of Alchemistic Accessories in Alkem's tower. Fixed in subfile 007 of texts for map 119.
- Fix character flags of Reg the hill giant. He now is markes as boss.
- Fixed map flags of two world maps (00D and 094).
- Gryban will no longer disappear when he is dismissed from the party.
- Fixed windgate graphic corruption (near Gemstone and Illien)
- Added a new teleport event form map 362 to map 361 (9,11) facing north. You can now reach first Gadlon map again.
- Fixed button target coordinates in cellar of the bandit house. The button will no appear pressed and not spawn another one.
- Fixed forest moon plant looting. Lot of fixes in many maps in the range 300 to 335.
- Ketnar conversation text fix. Removed " |END.." in NPC_texts.amb (subfile 03A, text 007).
- Fixed Randor's General Store closed message in Dor Grestin. Removed " |END..".
- Changed type of golem from partymember to monster in gala's temple
- Removed unused character data from map 258
- Changed all wrong occurences of HE and HIS
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 109 (subfile 00F)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 109 (subfile 013)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 115 (subfile 010)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 11D (subfile 00C)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 128 (subfile 005)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 128 (subfile 006)
    - Changed HE to ~SEX1~ and HIS to ~SEX2~ in 2Map_texts.amb file 197 (subfile 003)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 1AF (subfile 001)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 169 (subfile 003)
    - Changed HIS to ~SEX2~ in 2Map_texts.amb file 16F (subfile 003)
    - Changed HE to ~SEX1~ in 2Map_texts.amb file 109 (subfile 012)
    - Changed HE to ~SEX1~ in 2Map_texts.amb file 112 (subfile 007)
    - Changed HE to ~SEX1~ in 2Map_texts.amb file 115 (subfile 00F)
    - Changed HE to ~SEX1~ in 2Map_texts.amb file 115 (subfile 012)
    - Changed HE to ~SEX1~ in 2Map_texts.amb file 16A (subfile 001)
    - Changed HE to ~SEX1~ in 2Map_texts.amb file 170 (subfile 002)
- Renamed monster "ENERGIEGLOBE" to "ENERGY GLOBE"
- Fixed wrong text index in Nalven's magical school
- Added 2 text popups to Thalion office map (see german file for details)
- Fixed wind gate at around x=271 y=564 (no longer usable when broken)
- Added floor texture to S'Angrila
- Fixed wrong direction when teleporting from Luminor's tower 4 to 3
- Changed Gryban start Exp from 114250 (previous fixed value) to 113400 (like in german fix) as this is exactly the exp needed for level 35.