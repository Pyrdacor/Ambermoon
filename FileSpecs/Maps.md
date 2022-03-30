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
0x0006 | ubyte | Tileset (1-8) in 2D or labdata index in 3D
0x0007 | ubyte | NPC gfx index
0x0008 | ubyte | Labyrinth background index
0x0009 | ubyte | Palette index
0x000A | ubyte | World (0: Lyramion, 1: Forest moon, 2: Morag)
0x000B | ubyte | End of map header (always 0)

### Map flags

Stored as 16 bits. 1 means true/active, 0 means false/inactive. Most significant bit is bit 15 and least significant is bit 0.

Bit | Meaning
--- | ---
0 | Indoor (always full light)
1 | Outdoor (light depends on daytime and own light sources)
2 | Dungeon (light depends only on own light sources)
3 | Automapper (if active the dungeon map is available and the map has to be explored)
4 | CanRest
5 | **Unknown** (all world maps have this set)
6 | Sky (3D maps only)
7 | NoSleepUntilDawn (if active sleep time is always 8 hours)
8 | StationaryGraphics (transport graphics like horse or ship)
9 | **Unknown** (never set in Ambermoon)
10 | WorldSurface
11 | CanUseSpells
12-15 | Unknown / unused

### Map data

After the header there are 320 ubytes which represent references to party members, NPCs or monsters on the map. See below.

Following these bytes there is the tile data at offset 0x014C. For 2D maps each tile is represented by 4 bytes, for 3D maps there are 2 bytes per tile.

The tile graphic indices are encoded in these bytes as well as the map event index.

### Character references

There are 32 possible references with 10 bytes each (in total 320 ubytes).

Each entry looks like this:

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Index (of party member, NPC, monster group or map text)
0x01 | ubyte | Travel type bit(s) used by the character (mostly 1 for walk/human or 2 for horse/monster)
0x02 | ubyte | Type and flags
0x03 | ubyte | Event index
0x04 | uword | Graphic index
0x06 | udword | Tile flags (will override the map tile flags if the character is on the tile, 3D only). Upper 4 bits are the combat background index for monsters.

The graphic index is:
- an object index inside the labdata for 3D maps
- a tile index inside the tileset for 2D maps if flag "Use tileset" is set
- an NPC graphic index for 2D maps if flag "Use tileset" is not set and it's an NPC

#### Type and flags

The lower 2 bits represent the character type:
- 0: Party member
- 1: NPC
- 2: Monster
- 3: Map object (like non-interactive small spiders, etc)

The upper 6 bits contain the flags:
- Bit 2: Random movement
- Bit 3: Use tileset
- Bit 4: Text popup
- Bit 5: **Unknown**
- Bit 6: **Unknown**
- Bit 7: **Unknown**

For NPCs if flag "Text popup" is set, the index is a map text index and only a text popup is shown on interaction.

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
2 | Door
3 | Chest
4 | Text popup
5 | Spinner
6 | Damage / trap
7 | **Unknown**
8 | Riddlemouth
9 | Award
10 | Change tile appearance
11 | Start battle
12 | Enter place (like merchants)
13 | Condition
14 | Action
15 | Dice 100 roll (Random)
16 | Conversation
17 | Print text
18 | Create
19 | Question popup
20 | Change music
21 | Exit
22 | Spawn
23 | Nop (empty operation)

The data for those events is described in a separate file [EventData](EventData.md).

### Character movement

After the map events there is the movement data of all character references.

If the character has the flag "random movement" set, there are 2 bytes for the character.
One for x and one for y. This is the start position on map entering. The monster will
move randomly every 5 ingame minutes starting at that location.

For monsters, there is also only one position if the random movement flag is not set.
In that case the monster will stay on that position and will only walk to the
player when he is near enough to attack.

If the non-monster character has no random movement there are 288 positions (each 2 bytes).
Each position is for a 5 minute ingame duration starting at 00:00. So there is a position
for every timeslot of a day. This is also used for static characters. They will have
288 identical positions.

### 3D map related data

After the character positions the go-to points follow which are only useful in 3D but
are also present in 2D maps (but with a amount of 0). After the go-to points there
are automap types for all the map events. These are only present for 3D maps though.
See [Maps3D](Maps3D.md) for more about this.

## Maps

The first 256 maps (1 to 256) build the Lyramion world map. Each is 50x50 tiles in size.

Maps 300 to 335 (36 maps) build the Forest Moon world map. Each is 50x50 tiles in size.

The last 16 maps (513 to 528) build the Morag world map. Each is 50x50 tiles in size.

Map 259 is the first 3D map (grandfather's cellar).
