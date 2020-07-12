# 2D Map file format specs

2D Maps use 3 kinds of files:
- The actual map data (1Map_data.amb, 2Map_data.amb and 3Map_data.amb)
- Icon data used for tiles (Icon_data.amb)
- Icon graphic data (1Icon_gfx.amb, 2Icon_gfx.amb and 3Icon_gfx.amb)

Each of those contains multiple files which represent a specific map, icon data (tileset) or icon graphic.

## Icon graphics

Icon graphics are 5 bit images with a size of 16x16. They use a 32 color palette from Palettes.amb as follows:

Tilesets | Palette
---- | ----
1,2 | 1
3 | 3
4,5,6,7 | 7
8 | 10

## Icon data

Icon data files represent tilesets. There are 8 icon data files (tilesets).

Offsets are given in hex. Sizes/lengths in dec. 16 and 32 bit values are stored in big endian format. So the most significant bytes come first. Example: The value 0x1234 is stored as 0x12 0x34 and the value 0x12345678 is stored as 0x12 0x34 0x56 0x78.

Offset | Type | Description
----|----|----
0x0000 | uword | Number of data entries
0x0002 | IconData[NumEntries] | Data entries

A data entry (IconData) looks like this:

Offset | Type | Description
----|----|----
0x0000 | ulong | **Unknown**
0x0004 | uword | Icon graphic index
0x0006 | ubyte | Number of animation tiles
0x0007 | ubyte | **Unknown**

The icon graphic index refers to an icon graphic. The index starts with 1 (index 1 is the first icon graphic). The number of animation tiles specifies the number of icon graphics belonging to the tile's animation (e.g. water uses multiple tiles for animation). Non-animated tiles have a value of 1.

So if you have icon graphic index 1 and 3 animation tiles the icons 1, 2 and 3 are used for the animation.

## Map data

Offset | Type | Description
----|----|----
0x0000 | uword | Flags
0x0002 | ubyte | Type (1: 3D map, 2: 2D map)
0x0003 | ubyte | Music index
0x0004 | ubyte | Width in tiles
0x0005 | ubyte | Height in tiles
0x0006 | ubyte | Tileset (1-8)
0x0007 | ubyte | NPC gfx index
0x0008 | ubyte | Lab back index
0x0009 | ubyte | Palette index
0x000A | ubyte | World (0: Lyramion, 1: Forest moon, 2: Morag)
0x000B | ubyte | End of map header (always 0)
0x000C | ubyte[320] | **Unknown**
0x014C | TileData[Width*Height] | Map tile data
... | ? | Map events etc

A tile data entry (TileData) consist of 4 ubytes.

```
underlay_tile_index = ((tile_data[1] & 0xe0) << 3) | tile_data[0];
overlay_tile_index = ((tile_data[2] & 0x07) << 8) | tile_data[3];
map_event_index = tile_data[1] & 0x1f;
```

Underlay is the background tile graphic and overlay an optional graphic on top of the background.

The indices refer to an IconData from the given tileset. Index 0 means 'nothing' or 'empty'.

### Map flags

Stored as 16 bits. 1 means true/active, 0 means false/inactive. Most significant bit is bit 15 and least significant is bit 0.

Bit | Meaning
--- | ---
1 | Indoor
2 | Outdoor
3 | Dungeon
4 | Automapper (if active the map has to be explored)
5 | Unknown1
6 | WorldSurface
7 | SecondaryUI3D
8 | NoSleepUntilDawn (if active sleep time is always 8 hours)
9 | StationaryGraphics
10 | Unknown2
11 | SecondaryUI2D
12 | Unknown3 (only 0 in map 269 which is the house of the baron of Spannenberg, also in map 148 but this is a bug)
13-15 | Unknown / unused

## Automap

The automap is used to track the exploration of 3D maps. Each tile is represented by a bit. The file Automap.amb contains a sub-file for each 3D map with the same index/name as the map. The size of the automap is `ceil(MAP_WIDTH * MAP_HEIGHT / 8)`.

Example: The map 259 has a size of 19x19 tiles. So in total this are 361 tiles. The automap contains 1 bit for each tile -> 361 bits. 361 bits are 45 full bytes and 1 additional bit so 46 bytes are needed to store all exploration bits.

If a bit is set to 0 it is not explored, if set to 1 it is explored.

Note that the initial maps seem to be fully explored but if a map is entered and the map should not be explored at this state, the automap is adjusted to represent an unexplored map.

### Bit order

Each byte is read as 8 bits. Then the lowest bit comes first.

Example: Automap starts with F0 03 70 01

The first byte F0 is 1111_0000 in binary. The lowest bit is the right-most 0. So the first 4 tiles are unexplored (0) and the next 4 tiles are explored (1). Then the second byte 03 is considered which is 0000_0011 in binary. We again start on the right with the 1. So the next 2 tiles are explored (1) and the following 6 are not (0).

Order:

    7654 3210 FEDC BA98 ...

The correctly ordered bit sequence for the exploration example above would look like: 00001111110000000000111010000000.
