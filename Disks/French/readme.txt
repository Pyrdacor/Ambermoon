Ambermoon French 1.19 by Pyrdacor (12-06-2023)
Translations by Dlfrsilver
Supported by CFOU!
===============================================

Changes in 1.19
===============

- Fixed wrong magic weapon level for Mando.
- Fixed invalid look-at text indices for Gryban and Chris.
- Fixed some wrong savegame character values and aligned with the german savegame.
- Fixed wrong Lyramion world map data file.

Changes in 1.18
===============

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
- Truncated too long text appearing in level up window
- Replaced attribute shortname "SPE" with "VIT" (Vitesse)

Changes in 1.17
===============

- Fixed some broken map events introduced in 1.16 (bandit's house)
- Improved a text in the temple of S'Trog
- Fixed a text in the S'Angrila prison
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

Changes in 1.16
===============

- Fixed crash when closing the game (introduce in 1.14)
- Fixed second eagle memory handle crash (when releasing the eagle)
- Fixed several tiles which allowed moving into walls (bandit's house, spannenberg and illien inn)
- Greatly improved Sansri's temple
  - Unused levers are marked on the map
  - Unused hourglasses are marked on the map
  - Missing texts when destroying hourglasses were added
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


Changes in 1.15
===============

- Fixed the eagle crash again (fix got lost in 1.14)
- Fixed text when using the elf harp at the crystal wall to work for females too
- Fixed wrong translation of Pelanis' farewell text
- Fixed NPC Brog (events and texts)
- Nera's Ring is now marked as "important"


Changes in 1.14
===============

- Merged AM2_BLIT into AM2_CPU
- Extracted all in-game texts to Text.amb
- Extracted all item data to Objects.amb
- Extracted all button graphics to Button_graphics
- Renamed Monster_char_data.amb to Monster_char.amb
- Renamed Dictionary.english to Dict.amb
- Added loader for the extracted files
- Renamed spell "Escape" to "Flight" to match the scroll item name
- Fixed "CELLAR" to "CELL" in Clementine's text about the madman
- Fixed a glitch where it was possible to enter the upper part of the shipyard, also adjusted some tiles there


Changes in 1.13
===============

- Fixed "out of memory handles" crash which often occured when using the eagle multiple times.
- Cleaned up the data of NPC Father Anthony which still included some unused stuff which is
  only not noticable by coincidence in game.
- Fixed text in last will: "GRANDSON" -> "GRANDCHILD"


Changes in 1.12
===============

- A spider in the bandit's cellar did not move previously. This is fixed now.
- Fixed automap wall display glitch in hill caves and beast cave.
- Changed "FISHERMEN" to "FISHERMAN" when observing Sally.
- The monsters in Gadlon cellar 1 now are active on the map (previously due to a bug they were   behind the outside walls).
- Chris' boots are no longer broken but instead identified at start.
- Flying disc is not broken anymore in the chest in the Thalion office.
- Wrong tiles on Morag surface fixed around coordinates 0,0.
- Female Tornak now grants 650 Exp instead of 0.


Changes in 1.11
===============

- Fixed "remove curse" spell.
- Windshrine door can not be skipped via broom or eagle anymore.
- Fixed wrong spawn location when leaving the windshrine.
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
- Fixed Whip parry penalty. It now correctly reduces parry by 10.
- Fixed Banded Armour attack penalty. It now correctly reduces attack by 4.
- Fixed Plate Armour attack penalty. It now correctly reduces attack by 6.
- Fixed Knight's Armour attack penalty. It now correctly reduces attack by 8.
- Fixed skill penalty code for items
- Fixed automap wall display glitch in palace of baron in Newlake
- Fixed a bug with NPC Matthias when you give him the 10000 gold for the harp
- Added an additional anti-smuggler protection to Morag :)
- Adjusted previous anti-smuggler protection (text color, item removal)


Changes in 1.10
===============

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


Changes in 1.09
===============

- Renamed Sansrie to Sansri (item names, monster, texts)
- In Sansri's temple a stair was visually corrected.
- When you return to Dor Kiredon with Dorina the text states that you travelled
  to Dor Grestin. That was corrected.
- All forest moon plants now have 1 charge so you can use them.
- Changed "WIND CALLS" to "WIND SHRINE".
- Changed "ORKS" to "ORCS".
- Improved the riddlemouth text in grandfather's cellar and Illien.
- There are two map versions of the Morag Hangar. Now they both use the same
  texts/translations.
- The spell scroll "Anti-Magic Sphere" has now the correct weight.
- The items "Murder Blade" and "Dagger Sling" now show the correct number
  of hands.
- The crystal harp quest was fixed:
  - You now need the elf harp to get the crystal harp.
  - You can now also show/give the elf harp to get a reaction.
- When you enter Dor Kiredon for the first time, the whole party automatically
  learns the dwarf language. This avoids getting stuck on the forest moon
  if you have no character in the party that can speak dwarf. It is also
  reasonable that the dwarfs will teach you their language.
- The lava pool in Luminor's torture chamber is now blocking movement. So
  you can no longer happily walk through the lava and it also avoids some
  visual glitches.
- If you kill Tornaks and come back with a Tornak egg the Tornaks will no
  longer reappear. This affects Mine - 2. Level and the Tornak Cave below
  Ferrin's forge.
- Moreover the walls you removed with the pickaxe will not reappear when
  you come back with or without the egg.
- And in the Tornak Cave when you have the egg you could trigger text
  popups by using the pickaxe multiple times at the same spot. This is no
  longer possible as well.



Changes in 1.08
===============

- Sansrie's key will work now in Sansrie's tunnel.
- The mysterious party member golem which appeared at 0:00 inside the temple
  of gala is now fixed and will appear as a regular monster group (4 golems)
  on the map.
- Reg the hill giant is now flagged as 'Boss' so he is now immune to spells
  like Fear or Petrified.
- Two parts of the Lyramion world map are fixed so that there is no longer
  a strange changing in fog of war.
- Gryban will now spawn in godsbane when you dismiss him from the party.
- Fixed two corrupted wind gates where the graphics were messed up after
  repairing.
- It is now possible to teleport back to the first floor in Gadlon.
- Fixed a button in the bandits' house cellar.
- Fixed all plants on the surface of Kire's moon. They will now all be
  collectable after you talked about plants with Asrub.
- Fixed a text popup in Nalven's magical school in Burnville when you
  approach the door to right.
- Added two missing text popups in the secret Thalion Office.
- The windgate at 271, 564 is no longer usable when it is broken.
- Added floor texture to the town of S'Angrila on Morag.
- Fixed wrong spawn direction when going from Luminor's tower level 4 to 3.
- Changed all wrong occurences of the fixed words "HE" and "HIS" to the
  placeholders. This way the correct sex is used for female main characters.
- Renamed monster "ENERGIEGLOBE" to "ENERGY GLOBE".
- Changed Gryban start exp to 114250 (which is the minimum exp for his level).
- Changed text in Pelanis' palace so that it mentions the word "CONCERNS"
  which is a keyword for Pelanis.
- Improved text of a crystal sphere in Gala's temple.
- Fixed wrongly stated closing hour in Alkem's tower.
- Fixed a crash in the conversation with Ketnar.
- Fixed a crash when approaching Randor's general store in Dor Grestin while
  it's closed.
- Fixed some more typos and names.
- This version also includes the Meynaf patch.


About the author
================

All fixes were done by Pyrdacor (trobt@web.de).
You can also visit my github site at https://github.com/Pyrdacor.
