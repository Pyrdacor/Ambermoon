# Monster flags

Each monster has special flags that are stored in a 8 bit big endian value. Each bit represents a specific property of the monster.

The following table is not complete yet.

Bit | Property
----|----
0 | Undead, can be killed by holy spells (it is not set for zombie master though, **bug?**)
1 | **Unknown** (used by Reg, Luminor, Guard demon and gargoyle type monsters)
2 | Boss type (immune to fear, won't flee, etc)
3 | Spider/lizard (is set for all of the mentioned kind except for Gigantula). Moranians don't count as lizards though. :P
4..7 | Unused

Note: It is a known bug that Reg is not marked as boss so you could cast Fear on him and he will flee with all the items. So I guess he should have bit 3 set as well. Possibly bit 1 was set for him by mistake.

If Reg is fixed, bit 2 above is only set for gargoyles and demons. Exceptions are the beast and Thornahuun.