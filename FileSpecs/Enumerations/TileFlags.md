Tile flags are used in 2D and 3D. They provide 32 bits (4 bytes) and are stored at the beginning of each [IconData entry](../Maps2D.md), [Wall entry](../Labdata.md) and [ObjectInfo entry](../Labdata.md).

Moreover each [character reference](../Maps.md) stored tile flags in the last 4 bytes. If a character is on a tile, it may override the flags of that tile. For example the upper 4 bits of the flags can store the combat background index for monsters. The character itself could provide another one instead.

Note: Bits are numbered from least significant bit to most significant bit. As the flags are stored in big-endian, bit 0 means the least significant bit of the 4th byte and bit 31 means the most significant bit of the first byte:
`[bit31..bit24] [bit23..bit16] [bit15..bit8] [bit7..bit0]`

Bits | As hex value | Meaning
--- | --- | ---
0 | 0x01 | **Unknown**
1 | 0x02 | **Unknown**
2 | 0x04 | Floor
3 | 0x08 | **Unknown**
4 | 0x10 | **Unknown**
5 | 0x20 | Use background tile flags (only used in 2D?)
6 | 0x40 | Bring to front
7 | 0x80 | Block all movement
8..23 | 0x0100..0x8000 | Allowed travel types


## Floor

- In 3D such objects are drawn on the floor like a hole in the ground. It is only used for 3D objects.
- In 2D this is used for foreground tiles that should appear in the background (behind the player). An example are border parts of a carpet where the background tile is also visible and so the foreground tile must be used as a second layer but in the background.


## Use background tile flags

If this is set for a 2D foreground tile, the collision detection is based on the background tile's flags.


## Bring to front

Not 100% sure about this, but it seems to override the "floor" bit and forces drawing above the player in 2D. It is used by tree tops, etc.


## Block all movement

If this bit is set, all movement is blocked by the tile. In 3D this is often used as there are no different travel types in 3D. But it may also be used in 2D as well.

In 3D the "allow movement for walking" bit is also considered. So if bit 8 is 0, the player is also blocked by the tile in 3D.

## Allowed travel types

Allows movement for each [travel type](TravelType.md). These are 16 bits (but Ambermoon has only 11 travel types). First bit (bit 8 of the tile flags) allows normal walking if set. Second bit (bit 1 of the tile flags) allows traveling by horse, and so on.
