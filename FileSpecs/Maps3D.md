# 3D Map file format specs

3D Maps use multiple files:
- The actual map data (2Map_data.amb and 3Map_data.amb)
- Wall texture data (2Wall3D.amb, 3Wall3D.amb)
- Floor/ceiling texture data (Floors.amb)
- Overlay texture data (2Overlay3D.amb, 3Overlay3D.amb)
- Object texture data (2Object3D.amb, 3Object3D.amb)
- [Labyrinth data](Labdata.md) (2Lab_data_.amb, 3Lab_data_.amb)

Each of those contains multiple files which represent a specific map, texture or labyrinth structure.

## Map data

Offset | Type | Description
----|----|----
0x0000 | ubyte[12] | Header (see [Maps](Maps.md))
0x000C | ubyte[320] | Character references (see [Maps](Maps.md))
0x014C | BlockData[Width*Height] | Map block data
... | ? | Map events etc

A block data entry (BlockData) consists of 2 ubytes.

```
if (block_data[0] == 0)
{
    // empty block
    object_index = 0;
    wall_index = 0;
}
else if (block_data[0] <= 100)
{
    // it's an object
    object_index = block_data[0];
    wall_index = 0;
}
else if (block_data[0] < 255)
{
    // it's a wall
    object_index = 0;
    wall_index = block_data[0] - 100;
}
else // block_data[0] == 255
{
    // it's the map border (no wall nor object)
    object_index = 0;
    wall_index = 0;
}

map_event_index = block_data[1];
```

So a block can mark an empty block, a wall, an object or the map border (which isn't drawn at all). The map border will always block all movement.

A wall uses the wall index to access wall data from the [Labdata](Labdata.md). An object uses the object index to access object group data from the [Labdata](Labdata.md). Note that an index might be greater than the amount of walls/objects so always use the module operator. For example the Morag airship uses wall index 14 while there are only 9 wall entries inside the labdata (0-8). So you have to use wall index 14 mod 9 (which is 5) instead (module = rest after division).

Note that those indices are 1-based while 0 means "no wall" or "no object". But inside the labdata they might be 0-based so you might have to subtract 1 to get the right data.

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

### Automap types

On the automap there are symbols for specific objects on the map like doors, riddlemouths, levers, teleporters, etc.

The following list only contains those that are used for walls in the Ambermoon data files. For a complete list see [AutomapTypes](AutomapType.md).

Value | Name
----|----
0 | None
1 | Wall (not shown as symbol but used by wall data)
2 | Riddlemouth
9 | Closed door
10 | Open door
14 | Exit
