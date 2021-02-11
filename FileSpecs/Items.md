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
0x0003 | ubyte | Break chance (0-100, used for some equip types like weapons or armor)
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
0x000F | ubyte | [Ammunition type](Enumerations/AmmunitionTypes.md) if this is ammunition
0x0010 | ubyte | [Ammunition type](Enumerations/AmmunitionTypes.md) if this is a long-ranged weapon
0x0011 | ubyte[4] | **Unknown**
0x0015 | ubyte | Index for either [special item purpose](Enumerations/SpecialItemPurpose.md), [transportation](Enumerations/Transportation.md) or text of a text scroll
0x0016 | ubyte | Text sub-index (used only for text scrolls)
0x0017 | ubyte | [Spell type](Enumerations/SpellTypes.md)
0x0018 | ubyte | [Spell index](Enumerations/Spells.md)
0x0019 | ubyte | Spell usage count (255 means unlimited)
0x001A | ubyte[4] | **Unknown**
0x001E | sbyte | M-B-R value (magic armor level)
0x001F | sbyte | M-B-W value (magic attack level)
0x0020 | ubyte | Item flags (see below)
0x0021 | ubyte | Item slot flags (see below)
0x0022 | uword | [Classes](Enumerations/Classes.md)
0x0024 | uword | Price (see price formula below)
0x0026 | uword | Weight
0x0028 | byte[20] | Item name (There is a null byte after the name. Rest can be filled with 0x00 or 0x20 bytes.)


### Item flags

Bit | Description
----|----
0 | Cursed
1 | Sellable
2 | Stackable
3 | **Unknown**
4 | Destroy after usage
5 | Readable
6 | **Unknown**
7 | Unused

### Price formula

Each item has a fixed cost that is used when you buy items. This is independent of your charisma.

But the sell price is charisma dependent. Every 10 charisma points you get a bonus of 1% the item cost.

The total sell price is calculated like this:

    bonus = floor(floor(charisma / 10) * (cost / 100))
    price = floor(cost / 3) + bonus
    
#### Examples

Item cost: 500, Charisma 35 (e.g. a spell scroll)

    bonus = floor(floor(35 / 10) * (500 / 100)) = floor(3 * 5) = floor(15) = 15
    price = floor(500 / 3) + 15 = 166 + 15 = 181
    
Item cost: 25, Charisma 99 (e.g. a hat)

    bonus = floor(floor(99 / 10) * (25 / 100)) = floor(9 * 0.25) = floor(2.25) = 2
    price = floor(25 / 3) + 2 = 8 + 2 = 10


### Signed bytes

Positive values range from 0x00 (0) to 0x7F (127). Negative values range from 0x80 (-128) to 0xFF (-1).


### Item slots

Equipment, inventory, chest, merchants, etc all store items as item slots. They all use the same format:

Offset | Type | Description
----|----|----
0x00 | ubyte | Amount of items (only stackable items can have a value greater than 1)
0x01 | ubyte | Number of remaining charges
0x02 | ubyte | **Unknown**. Maybe flags have 16 bits?
0x03 | ubyte | Flags (see below)
0x04 | uword | Item index

Note: The shield slot for two-handed weapons will have item index 0 but an amount of 1. The object image index 0 also contains the red cross which is used in that slot. So empty slots are determined only by the item amount and not the item index. 

#### Item slot flags

Value | Name
----|----
0x00 | None
0x01 | Identified
0x02 | Broken

Note: Items also store an item slot flags value. I guess it overrides the one from the chest/merchant etc. or is kind of a default value. Maybe useful if the item is given to the party by events (like NPCs).
