# 3D Map file format specs

3D Maps use multiple files:
- The actual map data (2Map_data.amb and 3Map_data.amb)
- Texture data (2Wall3D.amb, 3Wall3D.amb)
- Overlay texture data (2Overlay3D.amb, 3Overlay3D.amb)
- Labyrinth data (2Lab_data_.amb, 3Lab_data_.amb)

Each of those contains multiple files which represent a specific map, texture or labyrinth structure.

Todo... 

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
