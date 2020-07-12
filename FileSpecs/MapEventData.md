# Map event data

Data for map events is stored in the map data files. See [Maps](Maps.md) for more details.

Here the data format for specific map events is shown. Each map event can use up to 9 bytes for the event data.


## Change map event

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | New x coordinate (1-based)
0x01 | ubyte | New y coordinate (1-based)
0x02 | ubyte | New direction (0: up, 1: right, 2: down, 3: left)
0x03 | ubyte[2] | **Unknown**
0x05 | uword | New map index
0x07 | ubyte[2] | **Unknown**

## Treasure event

Used for chests, piles, lootable map objects etc.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Lock flags (0: open, 1: locked, can be opened by lockpick, many values, not sure yet)
0x01 | ubyte | **Unknown** (always 0 except for one chest with 20 blue discs which has 0x32 and lock flags of 0x00)
0x02 | ubyte | **Unknown** (0xff for unlocked chests)
0x03 | ubyte | Chest data index
0x04 | ubyte | Remove if empty (0 or 1)
0x05 | uword | Key index if locked
0x07 | uword | **Unknown** (seems to be 0xffff for unlocked, and some id otherwise, trap index maybe?)

