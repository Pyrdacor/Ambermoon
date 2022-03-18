# Character file format spec

This format is used for the following files:
- Monster_char_data.amb
- NPC_char.amb
- Party_char.amb

Offsets are given in hex. Sizes/lengths in dec. 16 and 32 bit values are stored in big endian format. So the most significant bytes come first. Example: The value 0x1234 is stored as 0x12 0x34 and the value 0x12345678 is stored as 0x12 0x34 0x56 0x78.

ubyte means unsigned 8-bit value, uword means unsigned 16-bit value and ulong means unsigned 32-bit value.

Offset | Type | Description
----|----|----
0x0000 | ubyte | [Character type](Enumerations/CharacterTypes.md)
0x0001 | ubyte | [Gender](Enumerations/Gender.md)
0x0002 | ubyte | [Race](Enumerations/Races.md)
0x0003 | ubyte | [Class](Enumerations/Classes.md)
0x0004 | ubyte | [Usable spell types](Enumerations/SpellTypes.md)
0x0005 | ubyte | Level (1-50)
0x0006 | ubyte | Number of free hands (0-2, Alkem has 255 which might be a bug)
0x0007 | ubyte | Number of free fingers (0-2)
0x0008 | ubyte | [Spoken languages](Enumerations/Languages.md)
0x0009 | uword | Portrait index
0x000B | uword | Combat graphic index (only used for monsters)
0x000D | ubyte | **Unknown** (only used for monsters, looks likes percent values like 70, 90, 100, etc. -> max value is 100), most likely a kind of parry/dodge chance as low monsters have 0. but many have 100 (maybe it's reduced by party member ATT ability?)
0x000E | ubyte | **Unknown** (only used for monsters, 0-5, maybe critical strike chance for monsters?)
0x000F | ubyte | Monster morale (0-100)
0x0010 | ubyte | Immunity to [spell types](Enumerations/SpellTypes.md)
0x0011 | ubyte | Attacks per round (APR)
0x0012 | ubyte | [Monster flags](Enumerations/MonsterFlags.md) (monsters only)
0x0013 | ubyte | [Elements and immunities](Enumerations/ElementsAndImmunities.md) (in original only used for monsters)
0x0014 | uword | Spell learning points (SLP)
0x0016 | uword | Training points (TP)
0x0018 | uword | Gold
0x001A | uword | Food
0x001C | uword | Character bit index. This bit is changed when a party member leaves the party or a conversation is left without taking the person with you. Initial this is set for Selena, Sabine and Valdyn. They will wait for you at different locations than when you first met them. Selena goes to the Sylph cave, Sabine and Valdyn go to Burnville. Gryban has an initial value of 0x0000. This is a bug. Gryban will vanish forever when he leaves the party or you won't take him with you. The correct value would be 0x35c0 or 0xffff. The value 0xffff means "not used" or "use initial location/use initial map character".
0x001E | uword | [Ailments](Enumerations/Ailments.md)
0x0020 | uword | Monster experience (gained when defeating it)
0x0022 | ubyte[2] | **Unknown** (always 0?)
0x0024 | uword | Mark of return x-coordinate (1-based, party member only)
0x0026 | uword | Mark of return y-coordinate (1-based, party member only)
0x0028 | uword | Mark of return map index (party member only)
0x002A | uword[4] | STR (see [Attributes](Enumerations/Attributes.md))
0x0032 | uword[4] | INT (see [Attributes](Enumerations/Attributes.md))
0x003A | uword[4] | DEX (see [Attributes](Enumerations/Attributes.md))
0x0042 | uword[4] | SPD (see [Attributes](Enumerations/Attributes.md))
0x004A | uword[4] | STA (see [Attributes](Enumerations/Attributes.md))
0x0052 | uword[4] | CHA (see [Attributes](Enumerations/Attributes.md))
0x005A | uword[4] | LUK (see [Attributes](Enumerations/Attributes.md))
0x0062 | uword[4] | A-M (see [Attributes](Enumerations/Attributes.md))
0x006A | uword | Current age
0x006C | uword | Max age
0x006E | uword[2] | Looks like age has a bonus and 4th value as well but they are always 0.
0x0072 | uword[4] | **Unknown**. This looks like a hidden or unused attribute/ability cause it uses most likely 4 uwords as well. The current and max value is always 0. The bonus is 25 for Chris and 5 for Gryban. The last value is 0 as well. With this there are 10 attributes. I guess this was a reserve and matches the amount of abilities.
0x007A | uword[4] | ATT (see [Abilities](Enumerations/Abilities.md))
0x0082 | uword[4] | PAR (see [Abilities](Enumerations/Abilities.md))
0x008A | uword[4] | SWI (see [Abilities](Enumerations/Abilities.md))
0x0092 | uword[4] | CRI (see [Abilities](Enumerations/Abilities.md))
0x009A | uword[4] | F-T (see [Abilities](Enumerations/Abilities.md))
0x00A2 | uword[4] | D-T (see [Abilities](Enumerations/Abilities.md))
0x00AA | uword[4] | L-P (see [Abilities](Enumerations/Abilities.md))
0x00B2 | uword[4] | SRC (see [Abilities](Enumerations/Abilities.md))
0x00BA | uword[4] | R-M (see [Abilities](Enumerations/Abilities.md))
0x00C2 | uword[4] | U-M (see [Abilities](Enumerations/Abilities.md))
0x00CA | uword | Current hit points
0x00CC | uword | Max hit points
0x00CE | uword | Bonus hit points
0x00D0 | uword | Current spell points
0x00D2 | uword | Max spell points
0x00D4 | uword | Bonus spell points
0x00D6 | word | Variable defense
0x00D8 | word | Base defense (party members only use this, monsters use base defense + rand(0, variable defense))
0x00DA | word | Variable attack damage
0x00DC | word | Base attack damage (party members only use this, monsters use base attack damage + rand(0, variable attack damage))
0x00DE | uword | Magic attack damage
0x00E0 | uword | Magic defense
0x00E2 | uword | APR increase levels (see below)
0x00E4 | uword | HP per level
0x00E6 | uword | SP per level
0x00E8 | uword | SLP per level
0x00EA | uword | TP per level
0x00EC | uword | **Unknown** (0xffff for all monsters, Thalion, Chris and Gryban, 0x0007 for the NPC Dönner, 0x0000 for all others)
0x00EE | ulong | Experience (EXP)
0x00F2 | ulong | Learned healing [spells](Enumerations/Spells.md)
0x00F6 | ulong | Learned alchemistic [spells](Enumerations/Spells.md)
0x00FA | ulong | Learned mystic [spells](Enumerations/Spells.md)
0x00FE | ulong | Learned destruction [spells](Enumerations/Spells.md)
0x0102 | ulong[3] | Learned spells of type 5-7 (always 0, 5 and 6 unused, 7 are functional spells)
0x010E | ulong | Weight
0x0112 | byte[16] | Name (encoding DOS-Latin-1, codepage 850 or 437)
0x0122 | [ItemSlot](Items.md)[9] | Equipment
0x0158 | [ItemSlot](Items.md)[24] | Inventory items

## Attributes and abilities

Each attribute (including the character's age) and ability stores 4 values:
- Current value (without bonus)
- Max value (can be exceeded by current value + bonus and only limits the current value)
- Bonus value (granted by equipment etc)
- Backup value

The actual effective and also displayed value is the current value plus the bonus value.

The backup value stores the current value if a temporary effect is active which affects the current value. A good example is the exhaustion ailment. It cuts all attributes' current values in half. So the backup value will then store the current value before reduction and the new current value is cut in half. When the effect ends the backup value is assigned to the current value and therefore restores the old value.

## Level up

There is a value which determines when the number of attacks per round increases. It's called APRIncreaseLevels here.

The number of attacks per round is 1 if APRIncreaseLevels is 0. Otherwise it is `1 + floor(Level / APRIncreaseLevels)`.

Hit points and training points are increased on each level up by the given "per level" value. Spell points and spell learning points are increased by their "per level" value plus `floor(INT/25)`. Note that Ambermoon only uses the base INT value without bonus. This might be a bug. Spell points and spell learning points are only increased for magical classes which can have SP. So not for warriors, thieves or animals.

## Additional monster data

Monsters have additional data at offset 0x01E8.

Offset | Type | Description
----|----|----
0x01E8 | AnimationInfo[8] | Monster battle animations
0x02E8 | byte[8] | Used number of frames for each of the 8 animations (0-32)
0x02F0 | byte[16] | **Unknown** (looks like the values 0-15 in a sequence)
0x0300 | byte[32] | Palette index mapping
0x0320 | ubyte | 1 bit for each animation (if set, the animation is played backwards after it has finished)
0x0321 | ubyte | **Unknown** (most likely unused and only for word alignment)
0x0322 | uword | Frame width (for graphic loading)
0x0324 | uword | Frame height (for graphic loading)
0x0326 | uword | Mapped frame width (for displaying)
0x0328 | uword | Mapped frame height (for displaying)

### Animation info

Each contains 32 bytes. Each byte gives a frame index (inside the monster graphic).

There is an animation info for 8 different actions:
- 0: Move (also used for the random idle animation, frame 0 of this is the monster idle frame!)
- 1: Attack
- 2: Prepare spell
- 3: Execute spell (often similar to the attack animation)
- 4: Hurt (receive damage)
- 5: Unknown2
- 6: Start animation (like transformation of Nera, are played once at start)
- 7: Unknown3

## Monster groups

Monsters are grouped for fights. The file Monster_groups.amb contains all monster formations in the game. Each file consists of 18 uwords which represent the 18 tiles in combat where a monster can be placed starting at the upper-left and going line by line from left to right.

Each uword can contain a monster index starting at 1 (0 = no monster).

## Monster morale

A value of 100 will ensure that the monster will never flee. Therefore all bosses have a value of 100. The lower the value the higher the propability that the monster will flee.

Note that even with a morale lower than 100 the boss flag would avoid fleeing in any case.

There are 3 values in addition to the morale that influence the flee chance.

- RDE (relative damage efficiency)
- LLP (lost own LP)
- AC (ally count)

The RDE is a relation between average party damage and average monster group damage. It's influence can range from -12 to +12.

The LLP influence can range from 0 to +75 and therefore has the biggest impact.

The AC influence can range from -15 to +25.

If a random value from 0 to the sum of these 3 values is greater than the morale, the monster will try to flee.

## NPCs and party members

NPCs have no equipment nor inventory items (no data for it). After the name there is an event section (same format as map events).
Party members have a similar event section but behind inventory and equipment data. The hero has no events of course as you can't talk to him.

NPC conversations are implemented in the following way:

- There is an event list usually starting with a Conversation event.
- A conservation event just opens the conversation window without text.
- The text is added by the PrintText event.

There might be condition events which force jumps to different PrintText or Conversation events based on global variables and such things.

## Learned spells

Note that learned spells are stored a bit strange (with 1 bit offset). The lowest bit is always 0 (not used). Bit 1 is then used for spell 1, bit 2 for spell 2, etc. I guess the spell index 0 was also a valid value in the original (namely "no spell") and could theoretically be stored as bit 0.
