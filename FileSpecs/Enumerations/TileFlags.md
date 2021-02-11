Tile flags are used in 2D and 3D. They provide 32 bits (4 bytes) and are stored at the beginning of each [IconData entry](../Maps2D.md), [Wall entry](../Labdata.md) and [ObjectInfo entry](../Labdata.md).

Moreover each [character reference](../Maps.md) stored tile flags in the last 4 bytes. If a character is on a tile, it may override the flags of that tile. For example the upper 4 bits of the flags can store the combat background index for monsters. The character itself could provide another one instead.

Note: Bits are numbered from least significant bit to most significant bit. As the flags are stored in big-endian, bit 0 means the least significant bit of the 4th byte and bit 31 means the most significant bit of the first byte:
`[bit31..bit24] [bit23..bit16] [bit15..bit8] [bit7..bit0]`

Bits | As hex value | Meaning
--- | --- | ---
0 | 0x00000001 | **Unknown**
1 | 0x00000002 | Block sight?
2 | 0x00000004 | Background
3 | 0x00000008 | Floor / Transparency
4 | 0x00000010 | **Unknown**
5 | 0x00000020 | Use background tile flags (only used in 2D?)
6 | 0x00000040 | Bring to front
7 | 0x00000080 | Block all movement
8..23 | 0x000000100..0x00800000 | Allowed travel types
24 | 0x01000000 | **Unknown**
25 | 0x02000000 | **Unknown**
26 | 0x04000000 | Player invisible
27 | 0x08000000 | **Unknown**
28 | 0x10000000 | **Unknown**
29 | 0x20000000 | **Unknown**
30 | 0x40000000 | **Unknown**
31 | 0x80000000 | **Unknown**


## Block sight

Not 100% sure about this, but this is set for normal walls and non-blocking walls which block sight (e.g. doors, fake walls, etc).


## Background

In 2D this is used for foreground tiles that should appear in the background (behind the player). An example are border parts of a carpet where the background tile is also visible and so the foreground tile must be used as a second layer but in the background.


## Floor / Transparency

- In 3D objects are drawn on the floor like a hole in the ground.
- In 3D walls use transparency (e.g. spider webs).


## Use background tile flags

If this is set for a 2D foreground tile, the collision detection is based on the background tile's flags.


## Bring to front

Not 100% sure about this, but it seems to override the "floor" bit and forces drawing above the player in 2D. It is used by tree tops, etc.


## Block all movement

If this bit is set, all movement is blocked by the tile. In 3D this is often used as there are no different travel types in 3D. But it may also be used in 2D as well.

In 3D the "allow movement for walking" bit is also considered. So if bit 8 is 0, the player is also blocked by the tile in 3D.

## Allowed travel types

Allows movement for each [travel type](TravelType.md). These are 16 bits (but Ambermoon has only 11 travel types). First bit (bit 8 of the tile flags) allows normal walking if set. Second bit (bit 1 of the tile flags) allows traveling by horse, and so on.

## Player invisible

In 2D the player is not drawn if on this tile. This is used by doors in 2D indoor maps. The player is invisible so that it looks like he is behind the door.
