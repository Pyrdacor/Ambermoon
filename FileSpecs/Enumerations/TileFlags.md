Tile flags are used in 2D and 3D. They provide 32 bits (4 bytes) and are stored at the beginning of each [IconData entry](../Maps2D.md), [Wall entry](../Labdata.md) and [ObjectInfo entry](../Labdata.md).

Moreover each [character reference](../Maps.md) stores tile flags in the last 4 bytes. If a character is on a tile, it may override the flags of that tile. For example the upper 4 bits of the flags can store the combat background index for monsters. The character itself could provide another one instead.

Note: Bits are numbered from least significant bit to most significant bit. As the flags are stored in big-endian, bit 0 means the least significant bit of the 4th byte and bit 31 means the most significant bit of the first byte:
`[bit31..bit24] [bit23..bit16] [bit15..bit8] [bit7..bit0]`

Bits | As hex value | Meaning
--- | --- | ---
0 | 0x00000001 | Alternate animation (animations go back and forth)
1 | 0x00000002 | Block sight?
2 | 0x00000004 | Render order
3 | 0x00000008 | Floor (3D object) / Transparency (3D wall)
4 | 0x00000010 | Random animation start (random frame offset)
5 | 0x00000020 | Use background tile flags
6 | 0x00000040 | Custom render order
7 | 0x00000080 | Block all movement
8..22 | 0x000000100..0x00400000 | Allowed travel types
23..25| 0x00800000 | Sit/sleep value
26 | 0x04000000 | Player invisible
27 | 0x08000000 | Auto poison (deals
28..31 | 0x10000000..0x80000000 | Combat background index


## Block sight

Blocks the sight. Monsters can't see you through this. Is set for walls, doors and secret doors (fake walls).


## Render order

In 2D this is used to switch between normal render order (0) and custom render order (1). See bit 6 for more details.

Normal rendering draws the player's upper half above tiles and his lower part is drawn behind foreground tiles but above background tiles. Custom render order can change that.


## Floor / Transparency

- In 3D objects are drawn on the floor like a hole in the ground.
- In 3D walls use transparency (e.g. spider webs).


## Use background tile flags

If this is set for a 2D foreground tile, the collision detection is based on the background tile's flags.


## Custom render order

This bit is only considered if bit 2 is set to 1 (custom render order).

If the bit is 0, the foreground tile is drawn behind the player. It's a "bring to back". Usage example: carpet.

If the bit is 1, the foreground tile is drawn above the player (even above the top half). It's a "bring to front". Usage example: large tree tops.


## Block all movement

If this bit is set, all movement is blocked by the tile. In 3D this is often used as there are no different travel types in 3D. But it may also be used in 2D as well.

In 3D the "allow movement for walking" bit is also considered. So if bit 8 is 0, the player is also blocked by the tile in 3D.


## Allowed travel types

Allows movement for each [travel type](TravelType.md). These are 15 bits (but Ambermoon has only 11 travel types). First bit (bit 8 of the tile flags) allows normal walking if set. Second bit (bit 9 of the tile flags) allows traveling by horse, and so on.

**Note:** In 3D the second bit (horse) is used as "allow monsters to pass".

I think Ambermoon uses the travel type "None" as index 0 and walking as index 1. Therefore there are really 16 travel allow bits and bit 7 means "allow travel type None". If this is set None is allowed and hence this means that no movement is allowed.


## Sit/sleep value

  - 0: no sitting nor sleeping
  - 1: sit and look up
  - 2: sit and look right
  - 3: sit and look down
  - 4: sit and look left
  - 5: sleep (always face down)


## Player invisible

In 2D the player is not drawn if on this tile. This is used by doors in 2D indoor maps. The player is invisible so that it looks like he is behind the door.


## Combat background index

When an event on that tile triggers a battle event, this combat background will be used.
