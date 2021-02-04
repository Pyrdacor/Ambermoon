# Place data

The file Place_data.amb contains only 1 sub-file which contains the data for all the places in the game (trainer, healer, inns, etc).

The file starts with an uword which gives the amount of places. There are 65 places in Ambermoon so the file should start with 00 41.

Then for each place there are 32 bytes (16 words). Their meaning differs for each place type.

## Trainer

Offset | Meaning
--- | ---
0 | [Ability](Enumerations/Abilites.md) to train
2 | Cost per training

## Healer

**TODO**

Most likely the first 11 words are the prices to heal all non-combat-only ailments.
Then 1 word for the price to heal 1 LP.
Then 1 word for the price to remove a curse.

## Sage

Offset | Meaning
--- | ---
0 | Cost to identify an item

## Enchanter

Offset | Meaning
--- | ---
0 | Cost to fill 1 (?) charge

## Inn

Offset | Meaning
--- | ---
0 | Cost to rest
2 | **Unknown**
4 | **Unknown**
6 | **Unknown**
8 | LP healing in percent

## Merchant

No data. It is provided by Merchant_data.amb.

## Food dealer

Offset | Meaning
--- | ---
0 | Price per food unit

## Library

No data. It is provided by Merchant_data.amb.

## Ship dealer

Offset | Meaning
--- | ---
0 | Price of a ship
2 | Spawn location X (1-based)
4 | Spawn location Y (1-based)
6 | Spawn location map index
8 | Stationary image bit value (= 4 -> bit 2 set)

## Horse dealer

Offset | Meaning
--- | ---
0 | Price for a horse
2 | Spawn location X (1-based)
4 | Spawn location Y (1-based)
6 | Spawn location map index
8 | Stationary image bit value (= 1 -> bit 0 set)

## Blacksmith

Offset | Meaning
--- | ---
0 | Cost to repair an item
