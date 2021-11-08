# Place data

The file Place_data.amb contains only 1 sub-file which contains the data for all the places in the game (trainer, healer, inns, etc).

The file starts with an uword which gives the amount of places. There are 65 places in Ambermoon so the file should start with 00 41.

Then for each place there are 32 bytes (16 words). Their meaning differs for each place type (see below).

After the place data, for each place there will be the display name (30 bytes). So the total file size is 2 + placeCount * 62.


## Data

Note that all places use only words as data so the data type is always uword in the following tables.

### Trainer

Offset | Meaning
--- | ---
0 | [Ability](Enumerations/Abilities.md) to train
2 | Cost per training

### Healer

Offset | Meaning
--- | ---
0 | Cost to heal the Lamed condition
2 | Cost to heal the Poisoned condition
4 | Cost to heal the Petrified condition
6 | Cost to heal the Diseased condition
8 | Cost to heal the Aging condition
10 | Cost to revive a dead body
12 | Cost to revive someone from his ashes
14 | Cost to revive someone from dust
16 | Cost to heal the Mad condition
18 | Cost to heal the Blind condition
20 | Cost to heal the Drugged condition
22 | Cost to heal 1 LP
24 | Cost to remove a curse from an item

### Sage

Offset | Meaning
--- | ---
0 | Cost to identify an item

### Enchanter

Offset | Meaning
--- | ---
0 | Cost to fill 1 charge

### Inn

Offset | Meaning
--- | ---
0 | Cost to rest
2 | Bedroom X
4 | Bedroom Y
6 | Bedroom map index
8 | LP healing in percent

### Merchant

No data. It is provided by Merchant_data.amb.

### Food dealer

Offset | Meaning
--- | ---
0 | Price per food unit

### Library

No data. It is provided by Merchant_data.amb.

### Raft dealer

Offset | Meaning
--- | ---
0 | Price of a raft
2 | Spawn location X (1-based)
4 | Spawn location Y (1-based)
6 | Spawn location map index
8 | [Travel type](Enumerations/TravelType.md) (= 2)

### Ship dealer

Offset | Meaning
--- | ---
0 | Price of a ship
2 | Spawn location X (1-based)
4 | Spawn location Y (1-based)
6 | Spawn location map index
8 | [Travel type](Enumerations/TravelType.md) (= 3)

### Horse dealer

Offset | Meaning
--- | ---
0 | Price for a horse
2 | Spawn location X (1-based)
4 | Spawn location Y (1-based)
6 | Spawn location map index
8 | [Travel type](Enumerations/TravelType.md) (= 1)

### Blacksmith

Offset | Meaning
--- | ---
0 | Cost to repair an item
