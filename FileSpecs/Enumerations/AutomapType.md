# Automap types

Value | Name | Additional info | Frames of animation (1 = no animation)
--- | --- | --- | ---
0 | None | Not in legend / no text, empty blocks | -
1 | Wall | Not in legend / no text, used by walls | -
2 | Riddlemouth | Used by walls | 4
3 | Teleporter | | 4
4 | Spinner | | 4
5 | Trap | Skull symbol | 4
6 | Trapdoor | Holes etc | 4
7 | Special | Exclamation mark symbol | 4
8 | Monster | Red sphere symbol | 4
9 | Door | Closed | 1
10 | DoorOpen | Uses same symbol as Door, no own text in data | 1
11 | Merchant | | 1
12 | Tavern | | 1
13 | Chest | | 1
14 | Exit | X symbol | 1
15 | ChestOpen | Not in legend / no text | 1
16 | Pile | | 1
17 | Person | Green sphere symbol | 1
18 | GotoPoint | White blinking point you can return to | 7
0xffff | Fallback | See below | -

The special automap type 0xffff is used for some 3D map character objects. If this is given, the automap type is determined by the character type. Consider an object that uses the sprite of a magician. In theory it can be used for a NPC or for a monster as well. So the automap type could be "Person" or "Monster" dependent on the usage. A real example from Ambermoon is the Necromancer at the graveyard of Spannenberg. It uses the sprite of an old man but is a monster that attacks you. There are also other old men in Spannenberg with the same sprite but these are normal NPCs. Technically they use the same 3D map object and this object therefore uses the automap type 0xffff to be usable by both.
