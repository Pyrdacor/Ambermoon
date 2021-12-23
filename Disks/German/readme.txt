Ambermoon German 1.11 by Pyrdacor (23-12-2021)
==============================================

Changes in 1.11
===============

- When saying "Tochter" to Sandra you will now also get the chest key and not only the tunnel key.
- Fixed "ENKEL" to "ENKELKIND" in testament to work for female chars as well.
- A spider in the bandit's cellar did not move previously. This is fixed now.
- Fixed automap wall display glitch in hill caves and beast cave.
- The monsters in Gadlon cellar 1 now are active on the map (previously due to a bug they were behind the outside walls).
- Chris' boots are no longer broken but instead identified at start.
- Flying disc is not broken anymore in the chest in the Thalion office.
- Wrong tiles on Morag surface fixed around coordinate 0,0.
- Female Tornak now grants 650 Exp instead of 0.
- Fixed "IST SIND" to "SIND" for a text of Baron Karsten in Newlake.
- The item Topaz was renamed to Topas as it's the correct german name and it is also referenced this way in Kire's message.


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
