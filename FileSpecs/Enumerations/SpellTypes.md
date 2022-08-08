# Spell types

These are bit flags. So in theory a character could have multiple spell types. But in Ambermoon only one spell type is used.

The value 0x80 (which is equal to set the highest bit to 1) is used for classes which have mastered the spells: Healer, Mystic and Alchemist. The highest bit is zero for other classes like Adventurer, Paladin or Ranger. As there is only one class with destruction magic, the mages always use the value 0x08 without the highest bit set.

In **Ambermoon Advanced** the values 0x10, 0x20 and 0x40 are also used for magicians to state that earth (0x10), wind (0x20) or fire (0x40) spells have increased damage. Basically the damage is adjusted to match the damage of the water/ice spells then. For example the spell Fire Pillar cast by a monster or magician with 0x48 would deal the same base damage as the spell Ice Shower.

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
Mage with strong earth spells | 0x18
Mage with strong wind spells | 0x28
Mage with strong fire spells | 0x48
Mage with strong earth and wind spells | 0x38
Mage with strong earth and fire spells | 0x58
Mage with strong wind and fire spells | 0x68
Mage with strong earth, wind and fire spells | 0x78


## Immunity

Characters can have immunities against spell types. The only one which used than in original game is the guard demon which is immune to alchemistic, mystic and destruction spells.

The immunity flags are as follows:

Value | Name
----|----
0x00 | Not immune
0x01 | Immune to healing spells (white spells)
0x02 | Immune to alchemistic spells (blue spells)
0x04 | Immune to mystic (green spells)
0x08 | Immune to destruction spells (black spells)
0x10 | Immune to spells of type 5 (unused)
0x20 | Immune to spells of type 6 (unused)
0x40 | Immune to spells of type 7 (functional spells, unused)
0x80 | Immune to spells of type 8 (unused)

Note: The guard demon uses a value of 0x9e which means:
- Immune to alchemistic spells
- Immune to mystic spells
- Immune to destruction spells
- Immune to type 5 spells
- Immune to type 8 spells


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
3 | Decrease age (used by youth potion)
4 | Play elf harp (used by elf harp)
5 | Add spell points I (used by spell potion I)
6 | Add spell points II (used by spell potion II)
7 | Add spell points III (used by spell potion III)
8 | Add spell points IV (used by spell potion IV)
9 | Add spell points V (used by spell potion V)
10 | All healing (used by all healing potion)
11 | Magical map (used by magical map)
12 | Add strength (used by strength potion)
13 | Add intelligence (used by intelligence potion)
14 | Add dexterity (used by dexterity potion)
15 | Add speed (used by speed potion)
16 | Add stamina (used by stamina potion)
17 | Add charisma (used by charisma potion)
18 | Add luck (not used by any item)
19 | Add anti-magic (used by anti-magic potion)
20 | Rope (used by rope)
21 | Drugs (used by stinking mushroom)
