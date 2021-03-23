# Attributes

There are 8 attributes:
- Strength (STR)
- Intelligence (INT)
- Dexterity (DEX)
- Speed (SPD)
- Stamina (STA)
- Charisma (CHA)
- Luck (LUK)
- Anti-Magic (A-M)

In the character data there are actually 10. The character's age is also stored as an attribute and there is one unused attribute.

The attribute values are stored as 4 uwords:

- uword[0]: Current value
- uword[1]: Max value
- uword[2]: Bonus from equipment etc
- uword[3]: Backup value

The backup value is used when the player is exhausted. In that case all attributes are halved (CurrentValue). The previous CurrentValue is stored as the backup value.

If your previous value was not exactly dividable by 2 this way it can be restored safely to the correct value.

## On items

On items the attributes include the character's age.

Value | Name
----|----
0 | Strength
1 | Intelligence
2 | Dexterity
3 | Speed
4 | Stamina
5 | Charisma
6 | Luck
7 | Anti-Magic
8 | Age


## Effects

- Strength: Increases the max weight by 1kg per point. Actually the max weight formula seems to be 999 + STR * 1000 in grams.
- Intelligence: Adds INT/25 (rounded down) SP and SLP on level up.
- Dexterity: Chance in percent to not trigger lock traps.
- Speed: Characters with higher values can act earlier in battle.
- Stamina: Increases Def by 1 every 25 points.
- Charisma: Increases the sell price by 1% every full 10 points.
- Luck: Chance in percent to avoid the effect of a triggered trap.
- Anti-Magic: Chance in percent to block enemy spells.

Note: While the alchemistic Anti-Magic barrier spells won't increase A-M, they still add a hidden percentage bonus.

The chance to avoid a fight is DEX+LUK out of 150.
