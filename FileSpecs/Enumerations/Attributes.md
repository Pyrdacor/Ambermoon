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

The attribute values are stored as 4 uwords:

- uword[0]: Current value
- uword[1]: Max value
- uword[2]: Bonus from equipment etc
- uword[3]: Unknown

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