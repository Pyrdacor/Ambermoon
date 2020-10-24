# Monster flags

Each monster has special flags that are stored in a 8 bit value. Each bit represents a specific property of the monster.

The following table is not complete yet.

Bit | Property
----|----
0 | Undead, can be killed by holy spells
1 | **Unknown** (used by Luminor, Guard demon and gargoyle type monsters)
2 | Boss type (immune to fear, won't flee, etc)
3 | Spider/lizard (is set for all of the mentioned kind except for Gigantula). Moranians don't count as lizards though. :P
4..7 | Unused

Note: It is a known bug that Reg is not marked as boss so you could cast Fear on him and he will flee with all the items. So I guess he should have bit 3 set as well. Possibly bit 1 was set for him by mistake.

I think spiders/lizards are the only monsters which can move more than one field per round. So bit 3 may be multi-field-move.
