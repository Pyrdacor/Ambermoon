# Classes

Value | Name
----|----
0 | Adventurer
1 | Warrior
2 | Paladin
3 | Thief
4 | Ranger
5 | Healer
6 | Alchemist
7 | Mystic
8 | Mage
9 | Animal (only Necros the cat NPC)
10 | Monster (monsters who aren't mages, thiefs, etc)

## On items

Each item can specify which classes can use/wear it.

In this case the classes are given by bit flags in a big endian 16 bit value. They can be combined with bitwise OR operator. For example 0x0104 (0x0100 OR 0x0004) means the item can be used by Paladins and Mages.

Value | Name
----|----
0x0001 | Adventurer
0x0002 | Warrior
0x0004 | Paladin
0x0008 | Thief
0x0010 | Ranger
0x0020 | Healer
0x0040 | Alchemist
0x0080 | Mystic
0x0100 | Mage
0x0200 | Animal
0x0400 | Monster

### Findings

The game data (e.g. items) seems to use 0x7fff (15 bits) for "usable by all classes". So there seem to be 4 more possible but unused classes.