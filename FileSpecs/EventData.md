# Event data

Data for map events is stored in the map data files. See [Maps](Maps.md) for more details. Moreover NPCs and party members also store events of the same format for conversations.

Here the data format for specific events is shown. Each event can use up to 9 bytes for the event data.

Note that actually 12 bytes are stored for each event. The first byte is the event type you see in parentheses below and the last 2 bytes always store the index of the following event or 0xffff if none follows. So here only the middle 9 bytes are listed which differ for each event type.

## Teleport event (0x01 / 1)

Used for map transitions, teleporters, holes in the ground and so on.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | New x coordinate (1-based)
0x01 | ubyte | New y coordinate (1-based)
0x02 | ubyte | New direction (0: up, 1: right, 2: down, 3: left)
0x03 | ubyte | **Unknown**
0x04 | ubyte | Transition type
0x05 | uword | New map index
0x07 | ubyte[2] | **Unknown**

### Transition types

- 0: Normal (black fading)
- 1: Teleporter (no black fading)
- 2: Wind gate (only teleports if the wind chain is active otherwise a message is displayed)
- 3: Climbing up/levitating (plays a levitation animation while transitioning)
- 4: Outro (after the endboss a map change event will 'teleport' you to the outro sequence)
- 5: Climbing down/falling (plays a falling animation while transitioning)

## Door event (0x02 / 2)

Used for locked doors.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Lockpicking chance reduction (0-100, see chest event data)
0x01 | ubyte | Door index (used in savegame to determine if a door was unlocked)
0x02 | ubyte | Optional index of a map text to display when showing door window (0xff means no text)
0x03 | ubyte | Optional index of a map text to display when unlocked (0xff means no text)
0x04 | ubyte | **Unknown** (always 0)
0x05 | uword | Key index if locked
0x07 | uword | Unlock fail event index (0-based, 0xffff means none, this is basically the trap event chain)

## Chest event (0x03 / 3)

Used for chests, piles, lootable map objects etc.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Lockpicking chance reduction (0-100)
0x01 | ubyte | Minimum search ability value to detect/open it (only 1 chest has a value above 0)
0x02 | ubyte | Optional index of a map text to display when showing the opened chest (0xff means no text)
0x03 | ubyte | Chest data index (also used for locked state in savegame)
0x04 | ubyte | Remove if empty (0 or 1)
0x05 | uword | Key index if locked
0x07 | uword | Unlock fail event index (0-based, 0xffff means none, this is basically the trap event chain)

If the lockpicking chance reduction is 0, the chest is always open. A value of 100 means that the chest can't be lockpicked at all. Many chests have a value of 1 which is a chest that is locked and lockpicking it succeeds nearly with the lockpicking ability in percent as chance.
If the key index is not 0, the chest can't be opened with a lockpick.

## Text popup event (0x04 / 4)

Show a text popup with an optional image. Note that the following map events in the list are only executed after the popup is closed. This is important e.g. for music change events before and after this event.

Assumption of data inside the unknown data:
- Border style / appearance
- Popup size

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Event picture index (0-based) or 0xff if no image
0x01 | ubyte | Popup trigger (0: none, 1: move, 2: hand/eye cursor, 3: both)
0x02 | ubyte | **Unknown**
0x03 | uword | Map text index
0x05 | ubyte[4] | **Unknown**

## Spinner event (0x05 / 5)

Only used in 3D maps. Rotates the player to a specific or random direction if he steps onto it.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Post-spin [direction](Enumerations/Directions.md)
0x01 | ubyte[8] | Unused

## Trap event (0x06 / 6)

Damages the player and/or add ailments (fireplaces, traps, etc).

This is used for normal map traps and also for traps on doors and chests.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Ailment
0x01 | ubyte | Trap target (0 = active player, 1 = all party members)
0x02 | ubyte | Affected genders (0 or 3: both, 1: male only, 2: female only)
0x03 | ubyte | Base damage
0x04 | ubyte[5] | Unused

The real damage is `BaseDmg + rand(0, (BaseDmg / 2) - 1)`.
Base damage can be 0 in which case only the ailment is inflicted.

### Trap ailments

- 0: none
- 1: crazy
- 2: blind
- 3: stoned
- 4: paralyzed
- 5: poisoned
- 6: petrified
- 7: diseased
- 8: artificial aging
- 9: dead (corpse)

## Remove buffs event (0x07 / 7)

Removes/stops active buffs.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Buff to stop
0x01 | ubyte[8] | Unused

### Buffs

- 0: All
- 1: Light
- 2: Magic attack
- 3: Magic protection
- 4: Anti-magic barrier
- 5: Clairvoyance
- 6: Mystic map

## Riddlemouth event (0x08 / 8)

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Riddle text index
0x01 | ubyte | Solution text index (used when riddle was solved)
0x02 | ubyte[5] | **Unknown**
0x07 | uword | Correct answer index in word dictionary

## Award (0x09 / 9)

This gives some award to the party.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Award type
0x01 | ubyte | Award operation
0x02 | ubyte | Random (0 or 1)
0x03 | ubyte | Award target
0x04 | ubyte | **Unknown**
0x05 | uword | Award type value (e.g. which attribute)
0x07 | uword | Value

If "Random" is set, the real value is a random value between 0 and "Value".

The operation "Fill" will ignore the Value and fully fill. This is used for LP/SP filling.

### Award type

Value | Meaning
--- | ---
0 | Attribute
1 | Ability
2 | LP
3 | SP
4 | SLP
5 | TP
6 | **Unknown**
7 | Language
8 | EP

### Award operation

Value | Meaning
--- | ---
0 | Increase
1 | Decrease
2 | Increase by percentage
3 | Decrease by percentage
4 | Fill
5 | Clear bit/remove (e.g. language)
6 | Set bit/add (e.g. language)
7 | Toggle bit (e.g. language)

### Award target

Value | Meaning
--- | ---
0 | Active player
1 | Whole party

## Change tile event (0x0A / 10)

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Tile's x coordinate (1-based)
0x01 | ubyte | Tile's y coordinate (1-based)
0x02 | ubyte | **Unknown**
0x03 | ubyte[4] | Tile data
0x07 | uword | Map index (0 means same map)

The tile data is in the same format as for 2D maps. It is compatible to 3D maps as well (object/wall index). So you can use this:

```cs
underlay_tile_index = tile_data[0];
overlay_tile_index = (tile_data[2] << 8) | tile_data[3];
map_event_index = tile_data[1];
// overlay_tile_index is used for 3D as object index (1..100), wall index (101..254) or empty (0).
```

In 2D mostly the overlay index is used. If it is not 0 and the underlay index is 0, this means that the back tile is removed. If both
values are 0, only the front tile is removed. There must be always at least one tile (front or back) of course.

## Start battle event (0x0B / 11)

Offset | Type | Description
--- | --- | ---
0x00 | ubyte[6] | **Unknown**
0x06 | ubyte | Monster group index
0x07 | ubyte[2] | **Unknown**

## Enter place event (0x0C / 12)

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Text index if place is closed (text taken from map texts, 0xff = no message (used for places that never close like inns))
0x01 | ubyte | Place type (see below)
0x02 | ubyte | Opening hour (0-23)
0x03 | ubyte | Closing hour (0-23)
0x04 | ubyte | Text index when you use the place (text taken from map texts, 0xff = no message). Using a place means buy a horse/ship, buy goods, heal, train, etc.
0x05 | uword | Place data index (1-based index inside the Place_data file)
0x07 | uword | Index (merchant data index)

### Place types

Value | Type
--- | ---
0 | Trainer (all kinds)
1 | Healer
2 | Sage (identify items)
3 | Enchanter
4 | Inn / Sleeping room
5 | Merchant (goods)
6 | Food dealer
7 | Library (spell scroll dealer)
8 | Raft dealer (not used in Ambermoon)
9 | Ship dealer
10 | Horse dealer
11 | Blacksmith (item repair)

## Condition event (0x0D / 13)

Condition events represent conditions that control if following events (in the list) are executed or not. Multiple conditions can be chained which equals a logical AND conjunction.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Condition type
0x01 | ubyte | Condition value (e.g. variable value, always a boolean 0 or 1, can invert the meaning like 1="has"/0="has not")
0x02 | ubyte | Count (item count, etc)
0x03 | ubyte[2] | **Unknown**
0x05 | uword | Object index (depends on condition's type, e.g. variable or item index)
0x07 | uword | Map event index to continue with if condition was not fulfilled or 0xffff to stop the event list in this case.

### Condition types

Value | Type
--- | ---
0 | Global variable (game variable, 0-1023)
1 | Event bit (64 bits per map, 0-32767)
2 | Door open
3 | Chest open
4 | Character bit (32 bits per map, 0-16383)
5 | Party member present
6 | Item owned (item in inventory)
7 | Use item (from inventory)
8 | Keyword known
9 | Success (is chained after other events like battles, riddlemouths or treasures and is something like "battle won", "riddle solved" or "treasure fully looted")
10 | Game option set
11 | Can see (not blind etc)
12 | Player direction
13 | Has ailment
14 | Hand cursor interaction
15 | Say word (mouth + enter keyword)
16 | Enter number
17 | Levitating
18 | Has gold amount
19 | Has food amount
20 | Eye cursor interaction

Research: There might be the following condition types:
- Has item equipped
- Has level
- Has ailment (possibly 13)
- Buff active (possibly 12)

Note: In conversations the global variable 0 is checked to be value 0 before executing a PrintText event that
should be executed in any case. I guess PrintText events always need a preceding Condition event and the global
variable 0 is always 0. So this is like a "always true condition".

## Action event (0x0E / 14)

Actions are related to conditions. For example they can change variable values which are used in conditions.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Action type
0x01 | ubyte | Action value (e.g. variable value to set, always a boolean 0 or 1, can invert the meaning like 0="remove"/1="add")
0x02 | ubyte | Count (item count, etc)
0x03 | ubyte[2] | **Unknown**
0x05 | uword | Object index (depends on action's type, e.g. variable index)
0x07 | ubyte[2] | **Unknown**

### Action types

Value | Type
--- | ---
0 | Set global variable (game variable)
1 | Change event bit
2 | Change open door flag
3 | Change open chest flag
4 | Change character bit
5 | Unused
6 | Add/remove items
7 | Unused
8 | Add keyword
9 | Unused
10 | Set game option
11 | Unused
12 | Set direction
13 | Add/remove ailment
14-17 | Unused
18 | Add/remove gold
19 | Add/remove food
20 | Unused

## Dice 100 event (0x0F / 15)

Rolls a dice and triggers the following event by a chance.
Optionally an event can be triggered in case the fortune wasn't on your side.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Chance (0..100)
0x01 | ubyte[6] | Unused
0x07 | uword | Map event index if failed

## Conversation event (0x10 / 16)

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Interaction type
0x01 | ubyte[4] | Unused?
0x05 | uword | Value
0x07 | ubyte[2] | Unused?

The value's meaning depends on the interaction type.

For show or give item it is the item index.
For keyword it is the dictionary index.

### Interaction types

Value | Type
--- | ---
0 | Keyword
1 | Show item
2 | Give item
5 | Join party
6 | Leave party
7 | Talk (mouth cursor), initial text
8 | Leave (exit conversation)

Most likely there is "ask to join" and "ask to leave" somewhere between 3 and 6.
As well as "give gold" and "give food".

Note: When examining someone, always the first text of the NPC
or party member is used (text index 0). This is not done through
events. Characters which won't open a conversation window can't be examined.

## Print text event (0x11 / 17)

This is used to define the text to display in conversations.
Therefore it must follow in an event chain which has a previous
conversation event.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | NPC message index
0x01 | ubyte[8] | Unused

Note: In conversations the global variable 0 is checked to be value 0 before executing a PrintText event that
should be executed in any case. I guess PrintText events always need a preceding Condition event and the global
variable 0 is always 0.

## Create event (0x12 / 18)

Create items etc. It is stored in the item view of conversation window for example.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte[6] | **Unknown**
0x06 | ubyte | Amount
0x07 | uword | Item index

## Question popup event (0x13 / 19)

Text popup as question with buttons 'Yes' and 'No'.
The next map event is only executed if answered with 'Yes'.

Assumption of data inside the unknown data:
- Optional image index
- Popup size
- Button texts
- Border style / appearance

Offset | Type | Description
--- | --- | ---
0x00 | ubyte | Map text index
0x05 | ubyte[6] | **Unknown**
0x07 | uword | Index (0-based) of map event to continue with when 'No' is chosen

## Change music event (0x14 / 20)

Changes the currently played music. If the music index 0xff is given,
the default music of the current map is used (= music reset to normal).

There is a byte that is always 0xff. I guessed that this might be the volume. But as it is always 0xff in Ambermoon this could be anything. This could only be tested if the original data is manipulated and then in Ambermoon the volume is checked.

Offset | Type | Description
--- | --- | ---
0x00 | word | Music index (0x00ff = default map music)
0x02 | byte | Volume (always 0xff -> 100%, not sure about this)
0x03 | ubyte[6] | Unused

## Exit event (0x15 / 21)

Used to exit a conversation or other window immediately.
It is used if a conversation should not be continued
and the window should close after the first text is
displayed.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte[9] | Unused

## Spawn event (0x16 / 22)

Spawn monsters etc.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte[9] | **Unknown**

## Interact event (0x17 / 23)

This event is only used in conversations. It performs the associated action to a chosen interaction type.

This means it will do the following things:
- If player had chosen "Give Item" it will remove that item.
- If player had chosen "Give Gold" it will remove that gold.
- If player had chosen "Give Food" it will remove that food.
- If player had chosen "Ask To Join" it will add the person to the party.
- If player had chosen "Ask To Leave" it will remove the person from the party.
- For all other interaction types (Keyword, Show Item, Talk, Leave) this has no effect at all.

The event has no data. It uses the chosen interaction type from the previous conversation event.

Offset | Type | Description
--- | --- | ---
0x00 | ubyte[9] | Unused

### Example usage

This event is necessary for quests where you need to bring more than 1 item. If the conversation event that is triggered by the "Give Item" button would immediately remove the item you have given, this would be fatal if you don't have the other required item. Therefore the associated action like removing the item is only performed with this extra event. This event can then be chained after some condition events so that it only removes the item if some conditions are met.
