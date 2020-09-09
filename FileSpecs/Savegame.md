# Savegame

A savegame basically consists of 5 files:
- Automap.amb: Stores exploration of 3D maps
- Chest_data.amb: Contents of all chests (including piles, etc)
- Merchant_data.amb: Goods of all merchants
- Party_char.amb: Values of all potential party members
- Party_data.sav: Additional values

We will focus on the Party_data.sav here which has some very important stuff in it.

## Savegame data

The Party_data.sav contains things like:
- Current location (map, position, direction, etc)
- Current party member indices
- Information if chests are locked
- Information about map changes (like pressed buttons, move walls, etc)

Note: Not all of the data is decoded yet.

Offset | Type | Description
--- | --- | ---
0x0000 | ubyte[10] | **Unknown**
0x000A | uword | Current map index
0x000C | uword | X in tiles on the map
0x000E | uword | Y in tiles on the map
0x0010 | uword | [Character direction](Enumerations/Directions.md)
0x0012 | ... | **Unknown**
0x002A | uword | Number of party members (1-6)
0x002C | uword | Active party member index (1-based -> 1-6)
0x002E | uword[6] | Character index of all the 6 party member slots
0x003A | ... | **Unknown**
0x35A4 | ubyte[64] | Chest locked states (512 bits for chest 0-511). See below.
0x35E4 | \* | Events (see below).


## Chest locked states

There are only 185 chests (1-131 and 203-256). But it seems possible that there can be up to 512 chests (including chest index 0).

Each bit has the following meaning:
- 0: Chest is locked
- 1: Chest is unlocked

The order of the bits is this (where each digit is a chest index in hex). \
76543210 FEDCBA98 ...


## Events

There can be an arbitrary amount of events. Each is encoded as 6 bytes. The end of events is encoded as a 0-uword.

Not every event is decoded yet.

The only 100% decoded event is the change tile event:

Offset | Type | Description
--- | --- | ---
0x00 | uword | Map index
0x02 | ubyte | X in tiles
0x03 | ubyte | Y in tiles
0x04 | uword | New front tile index (for 3D it is the new block index)

As all map-related events seem to start with the map index other events must start with a word that is greater than the highest map index (I guess >= 0x0300, maybe even >= 0x0800).

There are map-related events that use a new front tile index >= 0x0800. But they can be 0x07ff (11 bits) at max. I guess this is used to decode some other map-related event.