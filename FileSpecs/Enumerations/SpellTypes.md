# Spell types

These are bit flags. So in theory a character could have multiple spell types. But in Ambermoon only one spell type is used.

The value 0x80 (which is equal to set the highest bit to 1) is used for classes which have mastered the spells: Healer, Mystic and Alchemist. The highest bit is zero for other classes like Adventurer, Paladin or Ranger. As there is only one class with destruction magic, the mages always use the value 0x08 without the highest bit set.

Value | Name
----|----
0x00 | None (no spells)
0x01 | Healing (white spells)
0x02 | Alchemistic (blue spells)
0x04 | Mystic (green spells)
0x08 | Destruction (black spells)
0x80 | All spells of a given kind


## Values for specific classes

Class | Value
----|----
Adventurer | 0x02
Warrior | 0x00
Paladin | 0x01
Thief | 0x00
Ranger | 0x04
Healer | 0x81
Alchemist | 0x82
Mystic | 0x84
Mage | 0x08


## On items

Items that provide a spell on usage (e.g. scrolls or magical items) also define a spell type as follows:

Value | Name
----|----
0 | Healing (white spells)
1 | Alchemistic (blue spells)
2 | Mystic (green spells)
3 | Destruction (black spells)
6 | Special

You can determine if an item provides a spell by checking the spell index or usage count.

The special spell type is used with the following spell indices (this might not be complete yet):

Value | Name
----|----
1 | Lockpicking (used by lockpick)
2 | Call eagle (used by flute)
4 | Play elf harp (used by elf harp)
11 | Magical map (use by magical map)
