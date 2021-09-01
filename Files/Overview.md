# File content description

## Program code

File | Disk | Format
---- | ---- | ----
AM2_BLIT | A | [Hunk file](Hunks.md) (might be [imploded](Imploding.md))
AM2_CPU | A | [Hunk file](Hunks.md) (might be [imploded](Imploding.md))
Ambermoon_intro | B | [Hunk file](Hunks.md) (might be [imploded](Imploding.md))
Ambermoon_extro | I | [Hunk file](Hunks.md) (might be [imploded](Imploding.md))

## Graphics

For further details about the formats look [here](../FileSpecs/Graphics.md).

File | Disk | Format
---- | ---- | ----
[1Icon_gfx.amb](../FileSpecs/Maps2D.md) | C | GFX (16x16, 5 planes)
[2Icon_gfx.amb](../FileSpecs/Maps2D.md) | D | GFX (16x16, 5 planes)
2Object3D.amb | D | 3D object billboard graphics
2Overlay3D.amb | E | Wall overlay graphics
2Wall3D.amb | E | GFX 128x80, 4 bit texture)
[3Icon_gfx.amb](../FileSpecs/Maps2D.md) | F | GFX (16x16, 5 planes)
3Object3D.amb | D | 3D object billboard graphics
3Overlay3D.amb | E | Wall overlay graphics
3Wall3D.amb | F | GFX (128x80, 4 bit texture)
Automap_graphics | G | GFX
Combat_background.amb | H | GFX (320x95, 5 planes)
Combat_graphics | G | GFX
Event_pix.amb | G | GFX width 320, 5 planes
Floors.amb | G | GFX (64x64, 4 planes)
Lab_background.amb | G | GFX (144x20, 4 planes)
Layouts.amb | G | GFX (320x163, 3 planes)
Monster_gfx.amb | H | GFX width 96, 5 planes
NPC_gfx.amb | G | GFX
Object_icons | G | Item GFX (16x16, 5 planes, [Special palette](../FileSpecs/Graphics.md))
Palettes.amb | G | GFX (32 colors, 16bit big-endian X4R4G4B4 each, see [here](../FileSpecs/Graphics.md))
Party_gfx.amb | G | GFX (16x16, 5 planes)
Pics_80x80.amb | G | GFX width 80, 5 planes
Portraits.amb | G | GFX width (32x32, 5 planes, [Special palette](../FileSpecs/Graphics.md))
Riddlemouth_graphics | G | GFX
Stationary | G | GFX width 32, 5 planes
Travel_gfx.amb | G | GFX width 16, 4 planes

## Texts

File | Disk | Content
---- | ---- | ----
1Map_texts.amb | C | TXT (mostly strings, header unknown)
2Map_texts.amb | D | TXT (mostly strings, header unknown)
3Map_texts.amb | F | TXT (mostly strings, header unknown)
Dictionary.german | G | TXT array of strings (all texts you can use in conversations or riddlemouths)
NPC_texts.amb | G | TXT (mostly strings, header unknown)
Object_texts.amb | G | TXT (mostly strings, header unknown)
Party_texts.amb | G | TXT (mostly strings, header unknown)

## Game data

File | Disk | Content
---- | ---- | ----
[1Map_data.amb](../FileSpecs/Maps.md) | C | Map data
2Lab_data.amb | D | Labyrinth data
[2Map_data.amb](../FileSpecs/Maps.md) | D | Map data
3Lab_data.amb | F | Labyrinth data
[3Map_data.amb](../FileSpecs/Maps.md) | F | Map data
[Icon_data.amb](../FileSpecs/Maps.md) | G | Tilesets / Animation information
[Automap.amb](../FileSpecs/Maps.md) | J | Exploration state of 3D dungeons
Chest_data.amb | J | Data of all chests
Merchant_data.amb | J | Data of all merchants
[Monster_char_data.amb](../FileSpecs/Characters.md) | H | Monster data
[Monster_groups.amb](../FileSpecs/Characters.md) | H | Monster formation info
[NPC_char.amb](../FileSpecs/Characters.md) | G | NPC data
[Party_char.amb](../FileSpecs/Characters.md) | J | Party character data
Place_data.amb | G | Data for locations like merchants

## Music

File | Disk | Content
---- | ---- | ----
Extro_music | I | Sonic Arranger with code
Intro_music | B | Sonic Arranger with code
Music.amb | I | Sonic Arranger without code

## Savegames

File | Disk | Content
---- | ---- | ----
Saves | J | Savegame catalog
Save.00/... | A | Initial savegame

The initial savegame and other savegames contain 5 files. 4 of them were mentioned above and have the same format: Automap.amb, Chest_data.amb, Merchant_data.amb and Party_char.amb.

The 5th file is Party_data.sav which contains additional data
about the game's progress. See the [savegame file description ](../FileSpecs/Savegame.md) for more details.

There is also a file called "Saves" in the main directory
which contains the names of the 10 savegames and the information
which of them is the last played savegame for the continue
game option.
