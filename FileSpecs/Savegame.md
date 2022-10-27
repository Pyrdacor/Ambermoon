# Savegame

## Names

The names of the 10 savegames are stored in the file
"Saves". This file starts with an unsigned big-endian
16-bit value which gives the index of the last played
savegame (0 to 10).

Then for each of the 10 savegames there are 39 bytes.
38 bytes can be used for the name and the last byte
is reserved for a terminating 0-byte which ends the
name. If the name is shorter than 38 characters the
rest should be filled with 0-bytes as well.

Note: Some original versions used the wrong file size.
It should be 392 bytes (2 byte header word + 10 * 39 bytes).
But some versions had 382 bytes (only 38 bytes per
savegame). I guess they forgot to count the terminating
0-bytes. Anyway saving in slot 10 will not increase the
filesize so with the 382 byte file the savegame name for
slot 10 might be truncated if it is longer than 28 characters.


## Content

A savegame basically consists of 5 files:
- Automap.amb: Stores exploration of 3D maps
- Chest_data.amb: Contents of all chests (including piles, etc)
- Merchant_data.amb: Goods of all merchants
- Party_char.amb: Values of all potential party members
- Party_data.sav: Additional values

We will focus on the Party_data.sav here which has some very important stuff in it.

### Savegame data

The Party_data.sav contains things like:
- Current ingame time and date
- Current location (map, position, direction, etc)
- Current party members
- Active spells and items like clock or compass
- Location of transports like boats or horses
- Global variables (quest states, game progress, etc)
- Flags if monsters or characters are on a map or not
- Information if chests or doors are locked
- Learned dictionary words for conversations
- Activated go-to points
- Information about map tile changes (like pressed buttons, moved walls, etc)
- Even the game options are part of the savegame and therefore distinct to other savegames

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
0x003A | uword | Years passed (since 978)
0x003C | uword | Current [travel type](Enumerations/TravelType.md)
0x003E | uword | Currently active [special items](Enumerations/SpecialItemPurpose.md)
0x0040 | uword | Current game options (see below)
0x0042 | uword | Hours without sleep (when reaching 24 you get messages about party getting tired every hour, when reaching 36 you got totally exhausted)
0x0044 | TransportLocation[32] | Location of transports (see below)
0x0104 | ubyte[1024] | Global variables (8192 bits). At 0x112 the wind gate active states seem to be located (1 bit for each gate, 1 = active, 0 = broken). Order is 76543210 FEDCBA98 ...
0x0504 | EventBits[1024] | Event active state bits. This provides 64 event bits for maps 1 to 1024. But used are only maps 1 to 528. For event bit structure see below.
0x2504 | CharacterBits[1024] | Controls if map characters are present on the map.
0x3504 | ubyte[128] | Dictionary words (see below). This allows 1024 dictionary words in theory. In the original game there are only 115 possible dictionary entries. 15 bytes are enough for those 115 entries so only these 15 bytes are used.
0x3584 | ubyte[32] | Activated go-to points (256 bits, each go-to point has an index in the range 0-255). If a bit is set, the point is active. Order of bits is like for chests etc.
0x35A4 | ubyte[32] | Chest locked states (256 bits for chest 0-255). See below.
0x35C4 | ubyte[32] | Door locked states (256 bits for door 0-255). See below.
0x35E4 | ubyte[6] | Battle positions for all 6 party members (each can be 0 to 11)
0x35EB | \* | Tile change events (see below).

### Active spells

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
0x02 | uword | Value of the spell (e.g. for light: 1 = magic torch, 2 = magic lantern, 3 = magic sun, etc otherwise it is the percentage value of the buff or not used for Clairvoyance and Mystic Map)

If the duration is 0, the spell is not active at the moment, otherwise it is.

### Transport locations

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

### Event bits

For each map (1 to 1024) there are 64 event bits (8 bytes per map). Each bit represents a map event from the [event list](Maps.md) of that map.
If a bit is 0, the event is active which means the player is able to trigger it. If a bit is 1, the event is inactive and the player can't trigger it.

For example this is used for one-time text popups. After triggering it, a map event will set the event bit and therefore the event can not be triggered again.

The order of the bits is this

Byte | 0 | 1 | ...
--- | --- | --- | ---
&nbsp; | 76543210 | FEDCBA98 | ...

- So map event 0 (first one) would be deactivated by the following 8 bytes (in hex): 01 00 00 00 00 00 00 00
- And map event 63 (last possible one) would be deactivated by the following 8 bytes (in hex): 00 00 00 00 00 00 00 80

Also have a look at the [action event](EventData.md) to change those bits.

### Character bits

For each map (1 to 1024) there are 32 character bits (4 bytes per map). Each bit represents a character on the map.
If a bit is 0 the monster is on the map, if 1 it is not.

The order of the bits is this

Byte | 0 | 1 | ...
--- | --- | --- | ---
&nbsp; | 76543210 | FEDCBA98 | ...


### Dictionary words

There are 115 possible dictionary words in Ambermoon (texts can be found in the Dictionary.* files). The unlock state of these words is stored
by a bit sequence of at least 15 bytes (15 * 8 bits = 120 bits, large enough to store all the 115 bits).

The order is like for the event bits: 76543210 FEDCBA98 ...

The first word in Ambermoon is "Hello". It is unlocked right from the start. Therefore the initial byte sequence is 01 00 00 00 ... (in hex).

To unlock for example the word "Ruins" which is the last word, the last byte has to be set to 04 cause 4 in binary is 00000100 so the 3rd bit of the last byte is set (14 bytes * 8 bits = 112 bits, 112 + 3 = text index 115).

A set bit means "unlocked" and an unset one means "not unlocked yet".

**NOTE:** There seems to be a bug in original. When unlocking more than 113 words, the game crashes when opening the dictionary. So if you set the first 14 bytes to 0xff (all bits set) and the last byte has more than 1 bit set, the game crashes. So you can't unlock all words without the crash.


### Chest locked states

There are only 185 chests (1-131 and 203-256). In total there can be 256 chests.
Chests in events are 1-based. But chest 1 uses bit1 and not bit0. So either this is a bug or chest index 0 is also valid in theory.

Each bit has the following meaning:
- 0: Chest is locked
- 1: Chest is unlocked

The order of the bits is this (where each digit is a chest index in hex). \
76543210 FEDCBA98 ...

Note: There is a chest sub-file with index 256 inside Chest_data.amb. It is completely empty and is not used at all in the game.
It can't be used because the chest index is stored as a byte and a byte can only store values up to 255.

Note: In **Ambermoon Advanced** there are 128 additional chests. As the savegame's should stay compatible, the last 16 bytes of the door locked states are used. This way the existing door locked states stay untouched. [Chest events](EventData.md) have a new flag to distinguish between normal and extended chests.


### Door locked states

There can be up to 256 doors. Each one has a bit similar to the chest ones. Door index 0 uses the first bit (lsb of the first byte) and so on.
The door events specify a door index from 0 to 38.

Note: The door to Kire's treasure room uses the same door index as one of the doors in Crook's cellar. I guess this is a bug as
doors on the forest moon have higher door indices in general and this is chest index 0. So opening one of them should open the other one as well.
The one in Crook's cellar can be opened by a lockpick or using the ability lockpicking. But in some tests the door in Kire's residence was
still locked even when the other door was opened. So maybe it is reset by some event? Would be interesting if the door in Crook's cellar is
locked again after returning from forest moon without opening the door to Kire's treasure room.

Note: In **Ambermoon Advanced** the door limit is reduced to 128, so only the first 16 bytes are used. This is more than enough as the original only uses around 40 doors in total. The other 16 bytes are used to allow 128 more chests.


### Game options

0 means default value. Therefore music is on if 0 and off if 1!

Value | Name
----|----
0x0001 | Music (0 = on, 1 = off)
0x0002 | Fast battle mode
0x0004 | Justified text
0x0008 | 3D floor texture
0x0010 | 3D ceiling texture
0x8000 | Found the yellow sphere

The last option is not changeable by the user but will be set via an NPC event. If the Moranian gives you the yellow sphere this option is set.
It is then used to decide which outro will be shown at the end of the game.


### Time and date

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


### Tile change events

There can be up to 750 tile change events. Each is encoded as 6 bytes. The end of the events is encoded as a 0-uword (end marker).

Offset | Type | Description
--- | --- | ---
0x00 | uword | Map index
0x02 | ubyte | X in tiles
0x03 | ubyte | Y in tiles
0x04 | uword | New front tile index (for 3D it is the new block index)

These events store changes in the world (e.g. moved walls or destroyed cobwebs).

Note: While normal map events have 12 bytes, here are only 6 bytes stored.

Note: While normal tile change events can use map index 0 as "same map", this is of course not possible in the savegame. So if such event occurs in game the real map index has to be stored instead of 0.
