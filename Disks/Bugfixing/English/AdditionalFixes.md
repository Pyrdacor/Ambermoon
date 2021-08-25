## Version 1.09

Based on 1.08.

### Sheet 2

- 24b: Fixed stair texture in Sansrie's temple 1.
  - Map 422 (x=14, y=11)
  - Changed byte 0x3D2 from 0x72 to 0x73
- When returning with Dorina to Dor Kiredon the text
  popup said that you returned to Dor Grestin. This was
  fixed in 3Map_texts.amb (subfile 0x161, text index 0x9)
- 44: Changed "WIND CALLS" to "WIND SHRINE".
- 45: Improved riddlemouth texts in grandfather's cellar
- 46: Set initial charges of several chest items (forest moon plants) from 0 to 1
- 55b: Both map versions (of both maps) now use the same translation
- 59: Anti-Magic Sphere spell scroll now has the correct weight value
- 60: Murder Blade and Dagger Sling now correctly use 1 hand
- 58: Fixed harp quest
  - You need the elf harp to get the crystal harp
  - You can now also show/give the elf harp instead of the strings

### Misc

- Improved riddlemouth in Illien (sub text file 0x009 in map 0x01A)
- Fixed the text of magic spring 4 in Illien

## Version 1.08

Fixed in relation to the excel sheet from Alex Holland.
Based on the Meynaf patch.

### Sheet 1

- 6: Fixed in subfile 004
- 8: Fixed in subfile 006
- 13: Fixed in map 424 in 2Map_data.amb
- 49: Fixed in subfile 008
- 51: Fixed in subfile 010
- 55: Fixed in subfile 005
- 56: Fixed in subfile 014
- 57: Fixed in subfile 007
- 58
- 59
- 60

### Sheet 2

- 6 and 7
- 24: added a new teleport event form map 362 to map 361 (9,11) facing north
- 26: fixed button target coordinates
- 39: lot of fixes in many maps in the range 300 to 335
- 50: Removed " |END.." in NPC_texts.amb (subfile 03A, text 007)
- 52: removed " |END.."

### Misc

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