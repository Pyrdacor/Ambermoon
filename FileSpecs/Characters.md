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
0x0006 | ubyte | **Unknown**
0x0007 | ubyte | **Unknown**
0x0008 | ubyte | [Spoken languages](Enumerations/Languages.md)
0x0009 | ubyte | **Unknown**
0x000A | ubyte | Portrait index
0x000B | ubyte[6] | **Unknown**
0x0011 | ubyte | Attacks per round (APR)
0x0012 | ubyte[2] | **Unknown**
0x0014 | uword | Spell learning points (SLP)
0x0016 | uword | Training points (TP)
0x0018 | uword | Gold
0x001A | uword | Food
0x001C | ubyte[2] | **Unknown** (often 0xffff)
0x001E | uword | [Ailments](Enumerations/Ailments.md)
0x0020 | ubyte[10] | **Unknown**
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
0x006E | ubyte[12] | **Unknown**
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
0x00EC | uword | **Unknown** (only seen 0x0000 or 0xffff)
0x00EE | ulong | Experience (EXP)
0x00F2 | ubyte[12] | **Unknown**
0x00FE | ulong | Learned [spells](Enumerations/Spells.md)
0x0102 | ubyte[12] | **Unknown**
0x010E | ulong | Weight
0x0112 | Char[20] | Name (not sure about the length)
... | ... | ...

To be continued ...