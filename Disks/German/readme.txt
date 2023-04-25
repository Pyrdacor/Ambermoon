Ambermoon German 1.18 by Pyrdacor (25-04-2023)
==============================================

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

Changes in 1.17
===============

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

Changes in 1.16
===============

- Fixed crash when closing the game (introduce in 1.13)
- Fixed second eagle memory handle crash (when releasing the eagle)
- Fixed several tiles which allowed moving into walls (bandit's house, spannenberg and illien inn)
- Fixed wrong case in the text when entering the hangar
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
- Fixed name in last will

Changes in 1.15
===============

- Fixed memory handle crash when using eagle (fix got lost in previous patch)
- Renamed condition "Veralterung" to "Alterung"
- Fixed option name "MMusik" to "Musik"
- Fixed endboss defeat message: replaced "BEGABEN" with "BEGRABEN"
- Renamed "PELANI" to "PELANIS" (is the correct name in Amberstar and english version)
- Fixed NPC Brog (events and texts)
- Nera's Ring is now marked as "important"


Changes in 1.14
===============

- Added missing skill names for read and use magic so they are now shown
  in item details
- Added a fixed version of Fantasy_intro so that it will also work on 060 CPUs


Changes in 1.13
===============

- Merged AM2_BLIT into AM2_CPU
- Extracted all in-game texts to Text.amb
- Extracted all item data to Objects.amb
- Extracted all button graphics to Button_graphics
- Renamed Monster_char_data.amb to Monster_char.amb
- Renamed Dictionary.german to Dict.amb
- Added loader for the extracted files
- Fixed a typo in Kire's texts ("KONTAKE" -> "KONTAKTE")
- Fixed a glitch where it was possible to enter the upper part of the shipyard, also adjusted some tiles there


Changes in 1.12
===============

- Fixed "out of memory handles" crash which often occured when using the eagle multiple times.
- Cleaned up the data of NPC Father Anthony which still included some unused stuff which is
  only not noticable by coincidence in game.
- Fixed text of NPC Theresa: "NEHMMT" -> "NEHMT"
- Fixed text in Nalven's magical school: "IN IN" -> "IN"
- Fixed dictionary entry "REPERATUR" to "REPARATUR" (you get this from Theresa)


Changes in 1.11
===============

- When saying "Tochter" to Sandra you will now also get the chest key and not only the tunnel key.
- Fixed "ENKEL" to "ENKELKIND" in testament to work for female chars as well.
- A spider in the bandit's cellar did not move previously. This is fixed now.
- Fixed automap wall display glitch in hill caves and beast cave.
- The monsters in Gadlon cellar 1 now are active on the map (previously due to a bug they were   behind the outside walls).
- Chris' boots are no longer broken but instead identified at start.
- Flying disc is not broken anymore in the chest in the Thalion office.
- Wrong tiles on Morag surface fixed around coordinate 0,0.
- Female Tornak now grants 650 Exp instead of 0.
- Fixed "IST SIND" to "SIND" for a text of Baron Karsten in Newlake.
- The item Topaz was renamed to Topas at it's the correct german name and it is also referenced   this way in Kire's message.


Changes in 1.10
===============

- Fixed "remove curse" spell.
- Windshrine door can not be skipped via broom or eagle anymore.
- Fixed wrong spawn location when leaving the windshrine.
- Reverted max swim values from 99 to 95
- Reverted current swim value of Tar from 99 back to 90
- Reverted Nelvin's and Tar's max U-M and R-M skills from 99 back to 95
- Reverted item name "Krummsäbel" in AM2_BLIT to "SCIMITAR"
- Fixed Whip parry penalty (change relative item data byte 0x11 from 01 to 02). It now correctly reduces parry by 10.
- Fixed Banded Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 4.
- Fixed Plate Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 6.
- Fixed Knight's Armour attack penalty (change relative item data byte 0x11 from 00 to 01). It now correctly reduces attack by 8.
- Fixed skill penalty code for items
- Fixed Erik's initial attack skill value from 0 to -6 (his worn Plate Mail has a attack penalty of 6 and penalties now work)
- Fixed automap wall display glitch in palace of baron in Newlake
- Fixed a bug with NPC Matthias when you give him the 10000 gold for the harp
- Added an additional anti-smuggler protection to Morag :)
- Adjusted previous anti-smuggler protection (text color, item removal)


Changes in 1.09
===============

- Many text fixes.
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


Changes in 1.08
===============

- Renamed Sansrie to Sansri (item names, monster, texts)
- In Sansri's temple a stair was visually corrected.
- When you return to Dor Kiredon with Dorina the text states that you travelled
  to Dor Grestin. That was corrected.
- All forest moon plants now have 1 charge so you can use them.
- The spell scroll "Anti-Magic Sphere" has now the correct weight.
- The items "Murder Blade" and "Dagger Sling" now show the correct number
  of hands.
- Many gender-specific german texts were changed so that they fit also
  for female heros.
- Some item names were corrected.
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



Changes in 1.07
===============

- Sansri's key will work now in Sansri's tunnel.
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
- Moreover this version contains all patches release before.


About the author
================

Nearly all fixes were done by Pyrdacor (trobt@web.de).
You can also visit my github site at https://github.com/Pyrdacor.

Some improvements of the german texts were performed by skdubg.