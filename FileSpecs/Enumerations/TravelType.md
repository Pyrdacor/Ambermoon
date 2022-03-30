# Travel types

The types match the 0-based file indices in [Travel_gfx.amb](../../Graphics/TravelGfx).

Value | Name
----|----
0 | Walk
1 | Horse
2 | Raft
3 | Ship
4 | Magical disc
5 | Eagle
6 | Flying (with a cape; was a cheat mode in Ambermoon)
7 | Swim
8 | Witch's Broom
9 | Sand lizard
10 | Sand ship

They often are used as bit flags in code:

Value | Name
----|----
0x0001 | Walk
0x0002 | Horse
0x0004 | Raft
0x0008 | Ship
0x0010 | Magical disc
0x0020 | Eagle
0x0040 | Flying
0x0080 | Swim
0x0100 | Witch's Broom
0x0200 | Sand lizard
0x0400 | Sand ship
