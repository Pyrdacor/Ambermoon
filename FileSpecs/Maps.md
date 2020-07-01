# Maps

2D and 3D maps use the same file format (XMap_data.amb).

## Map data

Offset | Type | Description
----|----|----
0x0000 | uword | **Unknown**
0x0002 | ubyte | Type (1: 3D map, 2: 2D map)
0x0003 | ubyte | **Unknown**
0x0004 | ubyte | Width in tiles
0x0005 | ubyte | Height in tiles
0x0006 | ubyte | Tileset (1-8 for 2D maps, for 3D maps unknown yet)
0x0007 | ubyte | **Unknown**
0x0008 | ulong | **Unknown**
0x000C | ubyte[320] | Event data (content **unknown**)
0x014C | ... | Tile data (see [2D Maps](Maps2D.md) / [3D Maps](Maps3D.md) for more about this)


## Maps

The first 256 maps (1 to 256) build the Lyramion world map. Each is 50x50 tiles in size.

Maps 300 to 335 (36 maps) build the Forest Moon world map. Each is 50x50 tiles in size.

The last 16 maps (513 to 528) build the Morag world map. Each is 50x50 tiles in size.

Map 259 is the first 3D map (grandfather's cellar).