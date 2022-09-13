# Items

In contrast to other game data the item data is stored inside the code/executable (the file AM2_CPU). To read it you first have to deplode it. You can do so with the [imploder-4.0](http://aminet.net/package/util/pack/imploder-4.0).

Each item uses 60 bytes. There are a total of 402 items. In total that makes 24120 bytes.

As executables differ in each version of the game the correct offset for the item data is different in each version too. The first item is the lamed ailment (yes even ailment symbols are treated as items as they are displayed in an item grid at healers). So maybe it can be helpful to search for the text "LAMED" (english version) or "GELÄHMT" (german version, note that the letter Ä is special and is encoded as 8E hex). The name of the item is at offset 40 (decimal) in relation to the item. So if you found the mentioned text you have to subtract 40 from that offset to find the offset of the first item inside the data.

Some known offsets are 0x4CAD4 (english version) and 0x4D144 or 0x4D348 (german version) but that also may depent on the game version or patch.

## Item data

Offsets are given in hex. Sizes/lengths in dec. 16 and 32 bit values are stored in big endian format. So the most significant bytes come first. Example: The value 0x1234 is stored as 0x12 0x34 and the value 0x12345678 is stored as 0x12 0x34 0x56 0x78.

Offset | Type | Description
----|----|----
0x0000 | ubyte | Item graphic index
0x0001 | ubyte | [Item type](Enumerations/ItemTypes.md)
0x0002 | ubyte | [Equipment slot](Enumerations/EquipmentSlots.md)
0x0003 | ubyte | Break chance in 0.1% (0 to 255 -> 0.0% to 25.5%, used for weapons, shields, tools and normal items)
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
0x0011 | ubyte | First reduced ability (see below)
0x0012 | ubyte | Second reduced ability (see below)
0x0013 | ubyte | First reduced ability amount (see below)
0x0014 | ubyte | Second reduced ability amount (see below)
0x0015 | ubyte | Index for either [special item purpose](Enumerations/SpecialItemPurpose.md), [transportation](Enumerations/TravelType.md) or text of a text scroll
0x0016 | ubyte | Text sub-index (used only for text scrolls)
0x0017 | ubyte | [Spell type](Enumerations/SpellTypes.md)
0x0018 | ubyte | [Spell index](Enumerations/Spells.md)
0x0019 | ubyte | Initial spell usage count (255 means unlimited, used when creating items through events)
0x001A | ubyte | Initial recharge count (used when creating items through events)
0x001B | ubyte | Max amount of recharging (number of times the enchanter can recharge the item in total)
0x001C | ubyte | Max spell usage count (can only be recharged to this amount)
0x001D | ubyte | Unused (never used in code, often same as 0x001B, maybe was planned to use as max recharge counter for spell ChargeItem?)
0x001E | sbyte | M-B-R value (magic armor level)
0x001F | sbyte | M-B-W value (magic attack level)
0x0020 | ubyte | Item flags (see below)
0x0021 | ubyte | Item slot flags (see below, used when creating items through events)
0x0022 | uword | [Classes](Enumerations/Classes.md)
0x0024 | uword | Price (see price formula below)
0x0026 | uword | Weight
0x0028 | byte[20] | Item name (There is a null byte after the name. Rest can be filled with 0x00 or 0x20 bytes.)

### Durability

In battles equipment might break.

Every attack checks for the weapon break of the attacker.

If the attacker deals damage, the target armor is also checked.

If the attack is parried instead of the armor check the defenders weapon and shield are checked.

### Ability reductions

There can be two ability reductions associated with an item. Each is given by 2 bytes.

The first in bytes 0x11 and 0x13, the second in bytes 0x12 and 0x14.

The first byte of each gives the ability to reduce (0 = none, 1 to 10 are abilities ATT to U-M).

If this byte is not 0 the second byte gives the amount to reduce that ability when the item is equipped.

Note: In contrast to bytes 0x0b/0x0c this is a hidden stat. So you can't see it in-game like in the item view. It is used to reflect difficulties to hit or parry with a specific item. In Ambermoon it is only used for the Whip which will decrease the ATT ability by 10 and thus makes it harder to hit with it by 10%. This reflects the difficulty to attack someone with a whip I guess. :)

This feature can theoretically be used with any ability but I guess it is only meant to be used with ATT and PAR. The original code uses wrong offsets so that only the ATT ability will work correctly. As it is the only one used, this will not lead to strange behavior.

Besides the original implementation I would suggest to interpret these 4 bytes like this:

Byte | Meaning
--- | ---
0x11 | Attack reduction active (boolean, 0/1)
0x12 | Parry reduction active (boolean, 0/1)
0x13 | Attack reduction in percent
0x14 | Parry reduction in percent

### Item flags

Bit | Description
----|----
0 | Cursed
1 | NotImportant
2 | Stackable
3 | Can be equipped during battle
4 | Destroy after usage
5 | Indestructable
6 | Clonable
7 | Unused

Item stacks can hold up to 99 items. Merchant item slots can stack all items even without that flag
and they can provide unlimited amounts if the item amount is set to 255.

Trivia: Note that the item grid which stores your bought items can't stack all items in contrast to
the merchant itself. So the merchant can offer more items than you can store in your shopping basket.
If you do so and store more than the 24 possible items in the basket the original game will crash.

The flag to control equipping during battles works in both directions. So you can't equip nor unequip
the item during battle.

Items which are flagged with NotImportant can be dropped, sold and left at merchants.
Without this flag items are considered important and therefore can't be dropped, sold
or left at merchants or in conversations.

Trivia: In original there is a bug which still can destroy important items. If an item-targeted
spell (Repair, Duplicate, Charge) fails, it destroys the targeted item. The fail-check is done first
so this can also happen to items that couldn't be targeted by the spell (i.e. repair non-broken items).
This way you can cast Repair on an important item and if it fails due to a low magic ability the
important item can be destroyed.

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
0x02 | ubyte | Recharge times
0x03 | ubyte | Flags (see below)
0x04 | uword | Item index

Note: The shield slot for two-handed weapons will have item index 0 but an amount of 1. The object image index 0 also contains the red cross which is used in that slot. So empty slots are determined only by the item amount and not the item index. 

#### Item slot flags

Value | Name
----|----
0x00 | None
0x01 | Identified
0x02 | Broken
0x04 | Cursed

Note: Items also store an item slot flags value. I guess it overrides the one from the chest/merchant etc. or is kind of a default value. Maybe useful if the item is given to the party by events (like NPCs).
