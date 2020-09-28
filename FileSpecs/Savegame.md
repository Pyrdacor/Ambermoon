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
0x0000 | uword | Current year (starting with 978)
0x0002 | uword | Current month (1-12 starting at 1)
0x0004 | uword | Current day of month (1-31 starting at 15)
0x0006 | uword | Current hour
0x0008 | uword | Current minute (always a multiple of 5)
0x000A | uword | Current map index
0x000C | uword | X in tiles on the map
0x000E | uword | Y in tiles on the map
0x0010 | uword | [Character direction](Enumerations/Directions.md)
0x0012 | ActiveSpell[6] | Active spells (see below)
0x002A | uword | Number of party members (1-6)
0x002C | uword | Active party member index (1-based -> 1-6)
0x002E | uword[6] | Character index of all the 6 party member slots
0x003A | uword | **Unknown**
0x003C | uword | Current [travel type](Enumerations/TravelType.md)
0x003E | uword | Currently active [special items](Enumerations/SpecialItemPurpose.md)
0x0040 | uword | Current game options (see below)
0x0042 | uword | Hours without sleep (when reaching 24 you get messages about party getting tired every hour, when reaching 36 you got totally exhausted)
0x0044 | TransportLocation[32] | Location of transports (see below)
0x0104 | ... | **Unknown**
0x0112 | uword | Wind gate active status (1 bit for each gate, 1 = active, 0 = broken)
0x0116 | ... | **Unknown**
0x35A4 | ubyte[64] | Chest locked states (512 bits for chest 0-511). See below.
0x35E4 | ubyte[6] | Battle positions for all 6 party members (each can be 0 to 11)
0x35EB | \* | Events (see below).

## Active spells

There are 6 possible active spells:

- Light
- Magic barrier
- Magic attack
- Anti-magic barrier
- Clairvoyance
- Mystic map

Each of the 6 spells are stored as 2 uwords:

Offset | Type | Description
--- | --- | ---
0x00 | uword | Duration in 5 minute chunks (e.g. 120 = 120 * 5 minutes = 600 minutes = 10 ingame hours)
0x02 | uword | Level of the spell (e.g. for light: 1 = magic torch, 2 = magic lantern, 3 = magic sun, etc)

If the duration is 0, the spell is not active at the moment, otherwise it is.

## Transport locations

Locations of horses, rafts, ships, etc are stored here. There are 32 possible locations.
On game start there are already 2 ships and 1 raft.

Each transport location is stored as 6 bytes:

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | [Travel type](Enumerations/TravelType.md)
0x01 | ubyte | X coordinate
0x02 | ubyte | Y coordinate
0x03 | ubyte | Unknown
0x04 | uword | Map index

Note: The direction of the transport is not stored.
There isn't even an image for each transport direction
but only one static image. The transport images are stored
inside the Stationary file.

## Chest locked states

There are only 185 chests (1-131 and 203-256). But it seems possible that there can be up to 512 chests (including chest index 0).

Each bit has the following meaning:
- 0: Chest is locked
- 1: Chest is unlocked

The order of the bits is this (where each digit is a chest index in hex). \
76543210 FEDCBA98 ...


## Events

There can be an arbitrary amount of events. Each is encoded as 6 bytes. The end of events is encoded as a 0-uword (end marker).

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


## Game options

0 means default value. Therefore music is on if 0 and off if 1!

Value | Name
----|----
0x01 | Music (0 = on, 1 = off)
0x02 | Fast battle mode
0x04 | Justified text
0x08 | 3D floor texture
0x10 | 3D ceiling texture


## Time and date

The date (day, month and year) is stored and also manipulated through the game but not actually used in any way to my knowledge.

The time is always increased by 5 minutes. This happens

- every 10 seconds of real time
- every 5 steps on indoor 2D maps
- every 5 steps (block changes) on 3D maps
- every x steps on world maps (see following table)

Travel type | Possible steps per 5 minutes
----|----
Walk | 2
Horse | 3
Raft | 2
Ship | 4
Magical disc | 2
Eagle | 6
Flying | 256
Swim | 2
Witch's broom | 4
Sand lizard | 3
Sand ship | 4

Flying is not really used in the game but seeing those values assumes that it is either an unknown cheat or was used by the developers to explore the map quickly.