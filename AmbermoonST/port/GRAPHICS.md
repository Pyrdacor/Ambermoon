# Graphics inventory (plan: pre-converted ST graphics)

Goal: every graphic is stored in ST format in the data files of the port; the game converts nothing at run
time. This is the inventory of all graphics of the German version 1.20, with the palette each one is drawn
with, as the basis of the converter (`port/tools/port_gfx.py`, to do) and the changes of the kernel.

## Palettes on the screen

The screen is split by raster lists (`MODULES.S:170-198`):

* lines 0-36 (status bar, portraits): always `Main_pal` (`KERNEL/DATA.S:284`, the special item/portrait
  palette; its colours 24-31 are the UI colours). Colour 25 changes on every line from line 1 for 35 lines
  (portrait gradient, `DISPLAY.S:1834`), also on the inventory, dialogue and character editor screens.
* from line 37 (`Middle_Y+1`) the palette of the module:

| Module | Palette |
| --- | --- |
| 2D/3D maps | `Current_pal` = map header byte 9 (`Colourpal_filenr`, `MAP/MAP.S:1103`) |
| Inventory, chest, door, places, camp, riddlemouth, battle order, dialogue, after combat | `Main_pal` |
| Automap | `Automap_pal` (fixed, `DATA.S:290`) |
| Combat | `Combat_pal` lines 37-132, `Tactic_pal` from line 133 (= `Main_pal` 0-23, other 24-30) |
| Event picture, game over | the event palette (`Batch`) |

3D maps: colours 0-15 are also kept in `Backup_pal` for the light level; city skies are a raster effect on
colour 9; the stars use colours 28-31.

Base colour: it only fills the planes above the depth of a graphic (`GRAPHICS.S:1936-1970`), so a 3-plane
graphic with base 24 or 28 uses colours 24-31. Masks are made from colour 0 at every masked draw (never stored).

## Map graphics

| Graphic | File | Format | Palette |
| --- | --- | --- | --- |
| 2D tiles | 1/2/3Icon_gfx (tilesets 1-8) | 16x16, 5 planes, base 0 | one palette per tileset (below) |
| Icon data | Icon_data.amb (8 x 2500 entries) | — | — |
| NPCs | NPC_gfx 1 (Lyramion/Morag), 2 (Forest Moon) | 16x32, 5 planes, frames | map palette |
| Party | Party_gfx 1-3 (per world), 17 frames | 16x32, 5 planes | map palette (world and towns) |
| Travel | Travel_gfx 1-11 (per travel mode) | variable, 5 planes | world map palettes 1-3 |
| Stationary transports | Stationary | 5 planes | map palette |
| 3D walls | 2/3Wall3D | 128x80, 4 planes, 8-pixel chunks | colours 0-15 of the map palette |
| 3D objects, overlays | 2/3Object3D, 2/3Overlay3D | size from the lab data, chunks | colours 0-15 |
| Floors, ceilings | Floors.amb (17) | 64x64, 4 planes | colours 0-15 |
| Horizon | Lab_background (3) | 144x20, 4 planes | colours 0-15 |
| Automap | Automap_graphics | walls 1 plane, corners/edges 3 planes base 0, 55 icons 16x16 5 planes | `Automap_pal` |

Tileset → palette (all 441 maps decoded): 1→1 (world), 2→2, 3→3, 4→7, 5→8, 6→9, 7→9, 8→10. Every tileset
uses exactly one palette; palettes 7, 8 and 9 are identical. NPC_gfx 1 is drawn with palettes 7-9, NPC_gfx 2
with 10; the party graphics of a world with the world palette and the town palettes of that world.

3D labs → palettes: 6 (labs 1, 2, 4-7, 9, 26, 27, 29, 30, 33, 35), 5 (cities 3, 8, 28, 31, 34), 4 and 6 (32),
11 (15), 12 (14, 17), 13 (16), 14 (11, 13), 15 (10, 12, 19), 16 (18). Many textures are used with several
palettes (walls 32 of 157, objects about 140 of 350, overlays 25 of 71, floors 8 of 18), but the 3D graphics
have 4 planes and base 0: **they need no colour reduction**, only the change from 8-pixel chunks to the ST
format; their colours are the colours 0-15 of the map palette.

## Other graphics

| Graphic | File | Format | Palette |
| --- | --- | --- | --- |
| Event pictures | Event_pix (9) | 320x92, 5 planes | own palette (`Event_pix_palette_table`, only 3 different: $1b, $20, $21) |
| Combat backgrounds | Combat_background (16) | 320x95, 5 planes | day/twilight/night palette per background (`Combat_bg_2D/3D_table`, `DATA.S:1756/1821`) |
| Monsters | Monster_gfx (25) | size from the monster data, 5 planes, frames | `Combat_pal` (of the background), recoloured at run time |
| Combat effects | Combat_graphics | 5 planes; sword/mace 32x36 3 planes base 24; tactic icons 16x14 5 planes | effects `Combat_pal`, icons `Tactic_pal` |
| Portraits | Portraits (102) | 32x34, 5 planes | `Main_pal` (+ colour 25 gradient) |
| Item icons | Object_icons | 16x16, 5 planes, masked | `Main_pal` |
| 80x80 pictures | Pics_80x80 (22) | 80x80, 5 planes | `Main_pal` |
| Layouts | Layouts (11) | 320x163, 3 planes, base 24, packed | UI colours of the active palette |
| Control icons | Button_graphics | 78 x 32x13, 3 planes, base 24 | UI colours |
| Riddlemouth | Riddlemouth_graphics | eyes 4 x 48x9, mouth 7 x 48x15, 3 planes, base 24 | `Main_pal` |
| Program graphics | `KERNEL/CHIP_DATA.S`, `DATA.S` | mostly 3 planes base 24 (window parts, status frame, spell icons, buttons, compass, ...); 5 planes: status icons, damage star, ankh, eagle, magic stars; 1 plane: font (8x5), patterns, small numbers; 29 mouse pointers 16x16 3 planes | UI colours, `Main_pal` |

## What this means for the converter

1. **3-plane graphics with base 24** (layouts, buttons, riddlemouth, most program graphics) use only the UI
   colours 24-31, which are fixed ST colours (9-15): one conversion, independent of the palette.
2. **1-plane graphics** (font, patterns, automap walls) are drawn as silhouettes in a colour: stay 1 plane.
3. **3D textures, floors, horizon** (4 planes, base 0): only the format changes (chunks → ST), no colour
   reduction; the ST palette of a 3D map is colours 0-15 of its Amiga palette (+ UI colours).
4. **2D tiles, NPCs, party, travel** (5 planes, 32 colours): one ST palette per map palette; the colour indices
   are built so that they have the same purpose in all palettes which share graphics (tilesets 4-7 with
   palettes 7-9 are one case anyway, the party graphics of a world are the other).
5. **Event pictures** (3 palettes) and **combat backgrounds** (day/twilight/night palettes of the same
   picture): one index assignment per picture, an ST palette per Amiga palette.
6. **Monsters** are drawn with the palette of the combat background and recoloured per monster
   (`Recolour_monsters`, `COMBAT.S:3024-3305`, table `Amiga_recol`). The monster data also has a 16-byte
   `Atari_recol` table (`GAME_OFF.S:704`): the original was planned for 16 colours. Combat needs combat
   palettes with indices of the same purpose for all backgrounds, so that monsters can be converted once.
7. **Portraits, items, 80x80 pictures** (5 planes, `Main_pal`): one conversion with the ST version of
   `Main_pal` (9 colours besides the 7 UI colours).
8. **Mouse pointers**: converted into ST pointer data by the tool.

## Changes in the game which follow

* The ST format of a block is 4 planes + mask per 16 pixels (10 bytes per 16 pixels and line). The mask is
  stored with the graphic (no mask made from colour 0 at run time).
* Original code which computes offsets from Amiga sizes must be patched (`; ST:`): `Screen_depth*2` frame sizes
  (`COMOBS.S:297`, `COMBAT.S:3262/3297`), the `rsgfx` offsets of Combat_graphics (`GAME_OFF.S:1758-1820`),
  `14*2*Screen_depth` (tactic icons), `Icon_size`=160 (items), `(n-1)*13*12` (control icons), `RM_*_size`,
  `32*12`, `9*5*2`, `10*3*2`, `3*2*16`, `Status_M+6/+19*6`, the frame sizes of animated tiles and NPCs, and the
  clipping in the blit routines (`GRAPHICS.S:1811-1815`).
* Run-time work which goes away or moves into the tool: decompression and decryption (the tool writes AMBR
  containers), layout decompression, mask making, colour conversion; monster recolouring works on ST indices
  (`Atari_recol` or a table made by the tool).

## Open questions

* The portrait gradient (colour 25 changes on every line for 35 lines) needs a raster interrupt per line on
  the ST, or is dropped.
* Combat: one set of combat palettes for all 16 backgrounds (each with day/twilight/night), so that monsters
  and effects are converted once.
* `Event_pix_palette_table` has only 8 entries for 9 pictures (picture 9 reads the next table).
