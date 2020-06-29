# File content description

## Program code

File | Disk | Format
---- | ---- | ----
AM2_BLIT | A | ?
AM2_CPU | A | ?

## Graphics

File | Disk | Format
---- | ---- | ----
[1Icon_gfx.amb](../FileSpecs/Maps.md) | C | GFX width 16, 5 planes
[2Icon_gfx.amb](../FileSpecs/Maps.md) | D | GFX width 16, 5 planes
2Wall3D.amb | E | GFX 128x80, 4 bit textures
[3Icon_gfx.amb](../FileSpecs/Maps.md) | F | GFX width 16, 5 planes
3Wall3D.amb | F | GFX 128x80, 4 bit textures
Automap_graphics | G | GFX
Combat_background.amb | H | GFX width 320, 5 planes
Combat_graphics | G | GFX
Event_pix.amb | G | GFX width 320, 5 planes
Floors.amb | G | GFX width 64, 4 planes
Lab_background.amb | G | GFX
Layouts.amb | G | GFX width 320, 3 planes
Monster_gfx.amb | H | GFX width 96, 5 planes
NPC_gfx.amb | G | GFX
Object_icons | G | GFX
Palettes.amb | G | PAL
Party_gfx.amb | G | GFX width 16, 5 planes
Pics_80x80.amb | G | GFX width 80, 5 planes
Portraits.amb | G | GFX width 32, 5 planes
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
2Lab_data.amb | D | Labyrinth data?
[2Map_data.amb](../FileSpecs/Maps.md) | D | Map data
2Object3D.amb | D | 3D object data (floats?)
2Overlay3D.amb | E | 3D object data (floats?)
3Lab_data.amb | F | Labyrinth data?
[3Map_data.amb](../FileSpecs/Maps.md) | F | Map data
3Object3D.amb | F | 3D object data (floats?)
3Overlay3D.amb | F | 3D object data (floats?)
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

## Video

File | Disk | Content
---- | ---- | ----
Ambermoon_intro | B | ?
Ambermoon_extro | I | ?

## Savegames

File | Disk | Content
---- | ---- | ----
Saves | J | Savegame catalog
Save.00/... | A | Initial savegame

The initial savegame and other savegames contain 5 files. 4 of them were mentioned above and have the same format: Automap.amb, Chest_data.amb, Merchant_data.amb and Party_char.amb.

The 5th file is Party_data.sav which contains additional data for party members like active buffs.

As the sav file is very large and there is no other place where the death of monsters are tracked I assume that this file also contains data of quest progress, defeated monsters, NPC talk states, etc.