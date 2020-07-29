# File types

There are 7 file types used in Ambermoon:

Name | Description | Header
---- | ---- | ----
JH | [JH encoded](JH.md) file | 0x4a48 ('JH')
LOB | [LOB encoded](LOB.md) file | 0x014c4f42 ('1LOB')
VOL1 | Another [LOB encoded](LOB.md) file | 0x564f4c31 ('VOL1')
AMNC | Multiple file container (data uses [JH](JH.md) encoding). The C stands for "crypted". | 0x414d4e43 ('AMNC')
AMNP | Multiple file container (data uses [JH](JH.md) encoding and the files are often [LOB](LOB.md) encoded in addition). The P stands for "packed". | 0x414d4e50 ('AMNP')
AMBR | Multiple file container (no encryption). The R stands for "raw". | 0x414d4252 ('AMNR')
AMPC | Another multiple file container (only compressed, not JH encrypted) | 0x414d5043 ('AMPC')

The music is stored in another format which can be loaded by the tool [Sonic Arranger](https://www.exotica.org.uk/wiki/Sonic_Arranger).

Note: The headers are stored in big endian format. So 'JH' is stored as 'J' (0x4a) 'H' (0x48).

Note: The JH encoding is just an encryption while the LOB encoding is a compression.

If you want to know how to decode a whole file look [here](FileDecoding.md).

## Usage

File | Size (<a name="U"></a>[U](#U "Uncompressed")/<a name="C"></a>[C](#C "Compressed")) | Format
---- | ---- | ----
Extro_music | 128356 | Sonic Arranger (?)
Intro_music | 87570 | Sonic Arranger (?)
Saves | 382 | raw
Party_data.sav | 13804 | raw
Dictionary.german | 933 | JH
Combat_graphics | 50124 (82942) | JH/LOB
Object_icons | 18276 (30080) | JH/LOB
Place_data | 1342 (4032) | JH/LOB
Automap_graphics | 6840 (13664) | LOB
Riddlemouth_graphics | 1768 (2538) | LOB
Stationary | 1892 (3480) | LOB
1Icon_gfx.amb | 162066 | AMNP
1Map_data.amb | 536980 | AMNP
1Map_texts.amb | 5290 | AMNP
2Icon_gfx.amb | 359044 | AMNP
2Lab_data.amb | 22922 | AMNP
2Map_data.amb | 123512 | AMNP
2Map_texts.amb | 74060 | AMNP
2Object3D.amb | 257474 | AMNP
2Overlay3D.amb | 87884 | AMNP
2Wall3D.amb | 608812 | AMNP
3Icon_gfx.amb | 157900 | AMNP
3Lab_data.amb | 22922 | AMNP
3Map_data.amb | 192410 | AMNP
3Map_texts.amb | 55464 | AMNP
3Object3D.amb | 163934 | AMNP
3Overlay3D.amb | 87884 | AMNP
3Wall3D.amb | 127834 | AMNP
Combat_background.amb | 269868 | AMNP
Event_pix.amb | 127214 | AMNP
Floors.amb | 28970 | AMNP
Icon_data.amb | 35390 | AMNP
Lab_background.amb | 2670 | AMNP
Monster_char_data.amb | 17248 | AMNP
Monster_gfx.amb | 507082 | AMNP
Monster_groups.amb | 2914 | AMNP
Music.amb | 536830 | AMNP
NPC_char.amb | 16686 | AMNP
NPC_gfx.amb | 18502 | AMNP
NPC_texts.amb | 70810 | AMNP
Object_texts.amb | 9730 | AMNP
Party_gfx.amb | 11264 | AMNP
Party_texts.amb | 9152 | AMNP
Travel_gfx.amb | 14796 | AMNP
Automap.amb | 7112 | AMBR
Chest_data.amb | 28410 | AMBR
Merchant_data.amb | 3162 | AMBR
Party_char.amb | 10824 | AMBR
Layouts.amb | 64622 | AMNC
Palettes.amb | 3338 | AMNC
Pics_80x80.amb | 88094 | AMNC
Portraits.amb | 69774 | AMNC