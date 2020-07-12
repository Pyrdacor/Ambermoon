# Maps

2D and 3D maps use the same file format (XMap_data.amb).

## Map data header

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

### Map flags

Stored as 16 bits. 1 means true/active, 0 means false/inactive. Most significant bit is bit 15 and least significant is bit 0.

Bit | Meaning
--- | ---
0 | Indoor
1 | Outdoor
2 | Dungeon
3 | Automapper (if active the map has to be explored)
4 | Unknown1
5 | WorldSurface
6 | SecondaryUI3D
7 | NoSleepUntilDawn (if active sleep time is always 8 hours)
8 | StationaryGraphics
9 | Unknown2
10 | SecondaryUI2D
11 | Unknown3 (only 0 in map 269 which is the house of the baron of Spannenberg, also in map 148 but this is a bug)
12-15 | Unknown / unused

### Map data

After the header there are 320 ubytes. The purpose is not decoded yet.

Following these bytes there is the tile data at offset 0x014C. For 2D maps each tile is represented by 4 bytes, for 3D maps there are 2 bytes per tile.

The tile graphic indices are encoded in these bytes as well as the map event index.

### Map events

After the tile data the map events are encoded. Map events are organized as linked lists. A tile can reference such a map event list. Index 0 is reserved and means 'no map event'.

The map event data consists of two sections. The map event list dictionary and the map event data.

The dictionary follows directly the tile data above. It looks like this (offsets relative to the map events section):

Offset | Type | Description
--- | --- | ---
0x0000 | uword | Number of map event lists (referenced by tiles through index 1 to n where n is this value)
0x0002 | uword[n] | Indices of the first map event of the list

So the dictionary stores n map event indices. Each is the first event of an event list. Events contain the index to the next map event and so they build lists.

Note that lists are referenced with a 1-based index but the events themselves are referenced with a 0-based index. So the first index is 0.

After the dictionary the map event data follows:

Offset | Type | Description
--- | --- | ---
0x0000 | uword | Number of map events (n)
0x0002 | ubyte[12][n]

Each map event is encoded with 12 bytes.

Offset | Type | Description
--- | --- | ---
0x0000 | ubyte | Event type
0x0001 | ubyte[9] | Event data
0x000A | uword | Next event (in the list) or 0xffff if none

#### Event types

Value | Type
--- | ---
1 | Map change
3 | Treasure
4 | Text popup
6 | Damage
8 | Riddlemouth
10 | Change tile
13 | Condition
14 | Action
* | Rest is not decoded yet

The data for those events is described in a separate file [MapEventData](MapEventData.md).

## Maps

The first 256 maps (1 to 256) build the Lyramion world map. Each is 50x50 tiles in size.

Maps 300 to 335 (36 maps) build the Forest Moon world map. Each is 50x50 tiles in size.

The last 16 maps (513 to 528) build the Morag world map. Each is 50x50 tiles in size.

Map 259 is the first 3D map (grandfather's cellar).
