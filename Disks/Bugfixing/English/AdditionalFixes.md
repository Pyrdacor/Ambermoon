## Version 1.10

Based on 1.09.

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

Based on 1.08.

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