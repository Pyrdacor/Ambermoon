# Items

In contrast to other game data the item data is stored inside the code/executable (the file AM2_CPU). To read it you first have to deplode it. You can do so with the [imploder-4.0](http://aminet.net/package/util/pack/imploder-4.0).

Each item uses 60 bytes. There are a total of 402 items. In total that makes 24120 bytes.

As executables differ in each version of the game the correct offset for the item data is different in each version too. The first item is the lamed ailment (yes even ailment symbols are treated as items). So maybe it can be helpful to search for the text "LAMED" (english version) or "GELÄHMT" (german version, note that the letter Ä is special and is encoded as 8E hex). The name of the item is at offset 40 (decimal) in relation to the item. So if you found the mentioned text you have to subtract 40 from that offset to find the offset of the first item inside the data.

Some known offsets are 0x4CAD4 (english version) and 0x4D144 or 0x4D348 (german version) but that also may depent on the game version or patch.

## Item data

Offsets are given in hex. Sizes/lengths in dec. 16 and 32 bit values are stored in big endian format. So the most significant bytes come first. Example: The value 0x1234 is stored as 0x12 0x34 and the value 0x12345678 is stored as 0x12 0x34 0x56 0x78.

Offset | Type | Description
----|----|----
0x0000 | ubyte | Item graphic index
0x0001 | ubyte | [Item type](Enumerations/ItemTypes.md)
0x0002 | ubyte | [Equipment slot](Enumerations/EquipmentSlots.md)
0x0003 | ubyte | **Unknown**
0x0004 | ubyte | [Gender](Enumerations/Gender.md)
0x0005 | ubyte | Number of hands
0x0006 | ubyte | Number of fingers
0x0007 | sbyte | HP Max
0x0008 | sbyte | SP Max
0x0009 | ubyte | [Attribute](Enumerations/Attributes.md) type
0x000A | sbyte | Attribute value
0x000B | ubyte | [Ability](Enumerations/Abilities.md) type
0x000C | sbyte | Ability value
0x000D | sbyte | Protection / defense
0x000E | sbyte | Damage
0x000F | ubyte[6] | **Unknown**
0x0015 | ubyte | Index for either [special item purpose](Enumerations/SpecialItemPurpose.md), [transportation](Enumerations/Transportation.md) or text of a text scroll
0x0016 | ubyte | **Unknown**
0x0017 | ubyte | [Spell type](Enumerations/SpellTypes.md)
0x0018 | ubyte | [Spell index](Enumerations/Spells.md)
0x0019 | ubyte | Spell usage count (255 means unlimited)
0x001A | ubyte[4] | **Unknown**
0x001E | sbyte | M-B-R value (magic armor level)
0x001F | sbyte | M-B-W value (magic attack level)
0x0020 | ubyte | Bit 0: Accursed, Bit 1: Purchasable
0x0021 | ubyte | **Unknown**
0x0022 | uword | [Classes](Enumerations/Classes.md)
0x0024 | uword | Price (see price formula below)
0x0026 | uword | Weight
0x0028 | byte[19] | Item name (filled with spaces (0x20) if shorter than 18 characters). There is a null byte after the name. This byte comes before the spaces.
0x003B | byte | End of item (= 0)


### Price formula

Each item has a fixed price value. But the charisma of the character can influence the real price.

The general price formula is:

    real price = item price / a value between 2.92 and 3.08


### Signed bytes

Positive values range from 0x00 to 0x7F. Negative values range from 0x80 to 0xFF.


### Item slots

Equipment, inventory, chest, merchants, etc all store items as item slots. They all use the same format:

Offset | Type | Description
----|----|----
0x00 | ubyte | Amount of items (only stackable items can have a value greater than 1)
0x01 | ubyte[2] | **Unknown**
0x03 | ubyte | Flags (see below)
0x04 | uword | Item index

#### Item slot flags

Value | Name
----|----
0x00 | None
0x01 | Identified
0x02 | Broken
