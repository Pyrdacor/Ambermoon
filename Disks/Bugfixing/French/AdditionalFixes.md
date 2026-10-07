## Unreleased

- Added the missing text in Luminor's tower 5 which is shown when pressing the button while the fire demons are still alive.
- Fixed collision of two beds and a log in the corridor map (267), you could walk onto them (fixes #146).
- Fixed walkable curtains in the wall of the trainer house in Spannenberg (fixes #123).
- The pieces of amber in the mine of Dor Kiredon (level 1 and 2) and in Ferrin's storage cellar are no longer empty after the first one was taken. This was broken since german 1.08 / english 1.09 (fixes #103).
- Fixed many more places where you could walk into walls (windows, curtains, wall decorations and stairs in several houses and taverns, #123).

## Version 1.19

- Fixed wrong magic weapon level for Mando.
- Fixed invalid look-at text indices for Gryban and Chris.
- Fixed some wrong savegame character values and aligned with the german savegame.
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
- Truncated too long text appearing in level up window
- Replaced attribute shortname "SPE" with "VIT" (Vitesse)

## Version 1.17

First release based on english 1.17.
