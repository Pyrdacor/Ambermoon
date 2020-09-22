# Character file format spec

This format is used for the following files:
- Monster_char_data.amb
- NPC_char.amb
- Party_char.amb

Offsets are given in hex. Sizes/lengths in dec. 16 and 32 bit values are stored in big endian format. So the most significant bytes come first. Example: The value 0x1234 is stored as 0x12 0x34 and the value 0x12345678 is stored as 0x12 0x34 0x56 0x78.

Offset | Type | Description
----|----|----
0x0000 | ubyte | [Character type](Enumerations/CharacterTypes.md)
0x0001 | ubyte | [Gender](Enumerations/Gender.md)
0x0002 | ubyte | [Race](Enumerations/Races.md)
0x0003 | ubyte | [Class](Enumerations/Classes.md)
0x0004 | ubyte | [Usable spell types](Enumerations/SpellTypes.md)
0x0005 | ubyte | Level (1-99)
0x0006 | ubyte | **Unknown** (Mostly 0, a few have 1 or 2, Alkem has 255)
0x0007 | ubyte | **Unknown** (Nera, Netsrak, Mando have 1, Chris and Targor 2, all others 0)
0x0008 | ubyte | [Spoken languages](Enumerations/Languages.md)
0x0009 | uword | Portrait index
0x000B | ushort | **Unknown** (only used for monsters)
0x000D | ubyte | **Unknown** (only used for monsters, looks likes percent values like 70, 90, 100, etc. -> max value is 100), most likely a kind of parry/dodge chance as low monsters have 0. but many have 100 (maybe it's reduced by party member ATT ability?)
0x000E | ubyte | **Unknown** (only used for monsters, 0-5, maybe critical strike chance for monsters?)
0x000F | ubyte | Monster attack hit chance (monsters only)
0x0010 | ubyte | **Unknown** (always 0 except for guard demon which has 158/0x9E so this might be some immunity bit flag)
0x0011 | ubyte | Attacks per round (APR)
0x0012 | ubyte | [Monster flags](Enumerations/MonsterFlags.md) (monsters only)
0x0013 | ubyte | [Monster elements?](Enumerations/MonsterElements.md) (only used for monsters)
0x0014 | uword | Spell learning points (SLP)
0x0016 | uword | Training points (TP)
0x0018 | uword | Gold
0x001A | uword | Food
0x001C | uword | **Unknown** (0xffff for all monsters, NPCs and most party members except for Selena (0x22c2), Sabine (0x23a0), Valdyn (0x2400) and Gryban (0x0000)). The values do not make sense as they are so I guess those are bit flags.
0x001E | uword | [Ailments](Enumerations/Ailments.md)
0x0020 | uword | Monster experience (gained when defeating it)
0x0022 | ubyte[2] | **Unknown** (always 0?)
0x0024 | uword | Mark of return x-coordinate (1-based, party member only)
0x0026 | uword | Mark of return y-coordinate (1-based, party member only)
0x0028 | uword | Mark of return map index (party member only)
0x002A | uword[4] | STR (see [Attributes](Enumerations/Attributes.md))
0x0032 | uword[4] | INT (see [Attributes](Enumerations/Attributes.md))
0x003A | uword[4] | DEX (see [Attributes](Enumerations/Attributes.md))
0x0042 | uword[4] | SPD (see [Attributes](Enumerations/Attributes.md))
0x004A | uword[4] | STA (see [Attributes](Enumerations/Attributes.md))
0x0052 | uword[4] | CHA (see [Attributes](Enumerations/Attributes.md))
0x005A | uword[4] | LUK (see [Attributes](Enumerations/Attributes.md))
0x0062 | uword[4] | A-M (see [Attributes](Enumerations/Attributes.md))
0x006A | uword | Current age
0x006C | uword | Max age
0x006E | uword[2] | Looks like age has a bonus and 4th value as well but they are always 0.
0x0072 | uword[4] | **Unknown**. This looks like a hidden attribute/ability cause it uses most likely 4 uwords as well. The current and max value is always 0. The bonus is 25 for Chris and 5 for Gryban. The last value is 0 as well. With this there are 10 attributes. I guess this was a reserve and matches the amount of abilities.
0x007A | uword[4] | ATT (see [Abilities](Enumerations/Abilities.md))
0x0082 | uword[4] | PAR (see [Abilities](Enumerations/Abilities.md))
0x008A | uword[4] | SWI (see [Abilities](Enumerations/Abilities.md))
0x0092 | uword[4] | CRI (see [Abilities](Enumerations/Abilities.md))
0x009A | uword[4] | F-T (see [Abilities](Enumerations/Abilities.md))
0x00A2 | uword[4] | D-T (see [Abilities](Enumerations/Abilities.md))
0x00AA | uword[4] | L-P (see [Abilities](Enumerations/Abilities.md))
0x00B2 | uword[4] | SRC (see [Abilities](Enumerations/Abilities.md))
0x00BA | uword[4] | R-M (see [Abilities](Enumerations/Abilities.md))
0x00C2 | uword[4] | U-M (see [Abilities](Enumerations/Abilities.md))
0x00CA | uword | Current hit points
0x00CC | uword | Max hit points
0x00CE | uword | Bonus hit points
0x00D0 | uword | Current spell points
0x00D2 | uword | Max spell points
0x00D4 | uword | Bonus spell points
0x00D6 | uword | **Unknown**
0x00D8 | uword | Defense
0x00DA | uword | **Unknown**
0x00DC | uword | Attack damage
0x00DE | uword | Magic attack damage
0x00E0 | uword | Magic defense
0x00E2 | uword | APR per level
0x00E4 | uword | HP per level
0x00E6 | uword | SP per level
0x00E8 | uword | SLP per level
0x00EA | uword | TP per level
0x00EC | uword | **Unknown** (0xffff for all monsters, Thalion, Chris and Gryban, 0x0007 for the NPC Dönner, 0x0000 for all others)
0x00EE | ulong | Experience (EXP)
0x00F2 | ulong | Learned healing [spells](Enumerations/Spells.md)
0x00F6 | ulong | Learned alchemistic [spells](Enumerations/Spells.md)
0x00FA | ulong | Learned mystic [spells](Enumerations/Spells.md)
0x00FE | ulong | Learned destruction [spells](Enumerations/Spells.md)
0x0102 | ubyte[12] | **Unknown** (always 0)
0x010E | ulong | Weight
0x0112 | byte[16] | Name (encoding DOS-Latin-1, codepage 850 or 437)
0x0122 | [ItemSlot](Items.md)[9] | Equipment
0x0158 | [ItemSlot](Items.md)[24] | Inventory items
... | ... | ...

To be continued ...

## Monster groups

Monsters are grouped for fights. The file Monster_groups.amb contains all monster formations in the game. Each file consists of 18 uwords which represent the 18 tiles in combat where a monster can be placed starting at the upper-left and going line by line from left to right.

Each uword can contain a monster index starting at 1 (0 = no monster).