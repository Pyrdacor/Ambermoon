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

## Go-to points

After the character positions the go-to points follow.

The section starts with an uword which gives the number of go-to points.

Then for each of them there are 20 bytes:

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | X (1-based)
0x01 | ubyte | Y (1-based)
0x02 | ubyte | [Direction](Enumerations/Directions.md)
0x03 | ubyte | Index (see [Savegame](Savegame.md))
0x04 | ubyte[16] | Name / tooltip text

## Automap types for events

For 3D maps after the go-to points there will be n bytes where n is the amount of map event list entries (not the total amout of events!). See [AutomapType](Enumerations/AutomapType.md) for possible values. If this is not 0 (None) and the event is available, the automap will show this automap icon on the map. Otherwise the automap type of the wall or object on that tile is used. If no wall or object is on that tile, no automap icon is shown.

## Automap / map exploration

The automap is used to track the exploration of 3D maps. Each tile is represented by a bit. The file Automap.amb contains a sub-file for each 3D map with the same index/name as the map. The size of the automap is `ceil(MAP_WIDTH * MAP_HEIGHT / 8)`.

Example: The map 259 has a size of 19x19 tiles. So in total this are 361 tiles. The automap contains 1 bit for each tile -> 361 bits. 361 bits are 45 full bytes and 1 additional bit so 46 bytes are needed to store all exploration bits.

If a bit is set to 0 it is not explored, if set to 1 it is explored.

Note that the initial maps seem to be fully explored but if a map is entered and the map should not be explored at this state, the automap is adjusted to represent an unexplored map. Maybe there is some bit in the savegame which states if a map was already entered or not or all maps are marked as fully unexplored when starting a new game.

### Bit order

Each byte is read as 8 bits. Then the lowest bit comes first.

Example: Automap starts with F0 03 70 01

The first byte F0 is 1111_0000 in binary. The lowest bit is the right-most 0. So the first 4 tiles are unexplored (0) and the next 4 tiles are explored (1). Then the second byte 03 is considered which is 0000_0011 in binary. We again start on the right with the 1. So the next 2 tiles are explored (1) and the following 6 are not (0).

Order:

    7654 3210 FEDC BA98 ...

The correctly ordered bit sequence for the exploration example above would look like: 00001111110000000000111010000000.

### Automap types

On the automap there are symbols for specific objects on the map like doors, riddlemouths, levers, teleporters, etc.

The following list only contains those that are used for walls in the Ambermoon data files. For a complete list see [AutomapTypes](Enumerations/AutomapType.md).

Value | Name
----|----
0 | None
1 | Wall (not shown as symbol but used by wall data)
2 | Riddlemouth
9 | Closed door
10 | Open door
14 | Exit

As mentioned above the events can only provide some automap type which will have higher priority if not set to None. Objects can also provide automap types of course.


## Collision detection

In 3D the center of the player (= current location) is always on a specific tile. This tile is checked first. If your movement target is on that tile and the tile is blocking, you won't move. If it's not blocking 1 of the 8 surrounding tiles may also be checked.

If your x position inside the block is < 120 then the left column is checked, if x is < 392 the middle column is checked and the right column otherwise. Same is done with y.

```
[0] [1] [2]
[3] [4] [5]
[6] [7] [8]
```

So based on the relative x and y inside block 4, another adjacent block might be checked for collision.

120 is 128-8 while 128 is 512/4 (1/4 the block size). \
392 is 384+8 while 384 is 3*512/4 (3/4 the block size).

So basically the collision body radius of the player is 120/512 of block size which is about 0.234 * block size.

Walls have a collision radius of 0.5 * block size of course. Objects use their mapped texture width as the diameter and therefore half that value as radius.

If an object has a mapped texture width of 320, the collision radius would be 160. Expressed in block sizes this are 160/512 block sizes which is 0.3125 * block size.


## Limits

The original code can render 200 map objects (including walls) at a time at max.
