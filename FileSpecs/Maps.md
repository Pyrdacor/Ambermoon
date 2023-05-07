# Maps

2D and 3D maps use the same file format (XMap_data.amb).

## Map data header

Offset | Type | Description
----|----|----
0x0000 | uword | Flags
0x0002 | ubyte | Type (1: 3D map, 2: 2D map, the docs say there was also 0 for an old 2D map format but it is not used nor supported in Ambermoon)
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
5 | Map is wilderness (all world maps have this set)
6 | Map is city (in Ambermoon 3D maps only, enables a sky)
7 | Map is dungeon (if active sleep time is always 8 hours)
8 | Travel (enable transport graphics like horse or ship, play music dependent on your travel type, this is set for all world maps only)
9 | Secret submarine bit (never set in Ambermoon)
10 | WorldSurface
11 | CanUseSpells (**Note** in original you can still use spell scrolls or use spells in battles on that map. It only disables the spell book button on the map screen. In **Ambermoon Advanced** however you won't be able to use spell scrolls but still can use other items with spells like potions or equipment.)
12 | No travel music (if the Travel bit is set, this will avoid playing music dependent on travel type but will play the map's music instead) (**Ambermoon Advanced** only)
13 | No marking/returning (won't allow using the spells "Word of marking" or "Word of returning" on the map) (**Ambermoon Advanced** only)
14 | Disallow eagle and broom (**Ambermoon Advanced** only)
15 | This is only used by Ambermoon.net and a special data storage mechanism. If the bit is set, an additional word follows the header which gives the index of another map. All tile data is then taken from that map. This way many world maps (all water) can be stored with much less size. It saves almost 10000 uncompress bytes per such map.

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
0x01 | ubyte | [Travel type](Enumerations/TravelType.md) used by the character (basically the collision class)
0x02 | ubyte | Type and flags
0x03 | ubyte | Event index
0x04 | uword | Graphic index
0x06 | udword | [Tile flags](Enumerations/TileFlags.md) (will override the map tile flags if the character is on the tile, 3D only). Upper 4 bits are the combat background index for monsters.

If the index is 0, the map character slot is not used. Map objects don't have a meaningful index in general. In this case the index should be set to 1. For monsters the index is always the monster group index. For party members it is always the party member index. For NPCs it is the NPC index if the flag "Text popup" is not set. Otherwise it is the index of the map text.

The graphic index is:
- an object index inside the labdata for 3D maps
- a tile index inside the tileset for 2D maps if flag "Use tileset" is set
- an NPC graphic index for 2D maps if flag "Use tileset" is not set and it's an NPC or party member

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
- Bit 5: Unused
- Bit 6: Unused
- Bit 7: Stationary / Only move when see player (**Ambermoon Advanced** only)

For NPCs if flag "Text popup" is set, the index is a map text index and only a text popup is shown on interaction.

Map objects are used to trigger some map event on interaction. The index should be 1, the event index should point to a valid map event chain.

Note: In theory any of the travel types can be used by monsters. They are used for collision detection. Even flying monsters are possible which can move through anything (travel type 6). But in Ambermoon only 2 types are used: 1 and 2. In 3D you can't interpret those as travel types like horse, raft, etc. They are more like "collision classes". Each wall or object in 3D has a bit associated for collision and the "travel type" of the character is basically the bit index for collision detection. The only exception is travel type 6, which is always some kind of "cheat type". If a character has this travel type set, it won't collide with anything.

Often collision class 1 is used. It is different from the player collision class 0 and objects like doors often only let class 0 pass. So those characters couldn't leave rooms through doors etc.

The stationary flag specifies that the NPC or party member stays at one position. In the original this was also possible (i.e. grandfather in bed) but required to store 288 identical positions (one for each 5 minute slot of the day). This flag allows only storing a single position. The same bit is used for monsters but has a different meaning there. The monster will only move if it can see the player. Otherwise it won't move at all.

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
7 | Remove buffs
8 | Riddlemouth
9 | Reward
10 | Change tile appearance
11 | Start battle
12 | Enter place (like merchants, inns, etc)
13 | Condition
14 | Action
15 | Dice 100 roll (random)
16 | Conversation
17 | Print text (in conversation)
18 | Create (items/gold/food in conversation)
19 | Question popup (yes/no decision box)
20 | Change music
21 | Exit (conversations)
22 | Spawn (horse, raft, ship)
23 | Interact (adds/removes party members, remove items, etc in conversations)

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
