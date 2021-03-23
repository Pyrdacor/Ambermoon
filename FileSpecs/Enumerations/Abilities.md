# Abilities

There are 10 abilities:
- Attack (ATT)
- Parry (PAR)
- Swim (SWI)
- Critical hit (CRI)
- Find traps (F-T)
- Disarm traps (D-T)
- Lockpicking (L-P)
- Searching (SRC)
- Read magic (R-M)
- Use magic (U-M)

The ability values are stored as 4 uwords:

- uword[0]: Current value
- uword[1]: Max value
- uword[2]: Bonus from equipment etc
- uword[3]: Backup value (same as for [Attributes](Attributes.md))

## On items

Value | Name
----|----
0 | Attack
1 | Parry
2 | Swim
3 | Critical hit
4 | Find traps
5 | Disarm traps
6 | Lockpicking
7 | Searching
8 | Read magic
9 | Use magic

## Effects

- Attack: Chance in percent to hit the target.
- Parry: Chance in percent to parry a physical attack (parry must be chosen as the round action in battle!).
- Swim: Reduces swim damage by this value in percent (99 = no damage).
- Critical hit: Chance to kill a non-boss enemy instantly with a physical attack.
- Find traps: Chance to detect a trap on a lock.
- Disarm traps: Chance to disarm a found lock trap. If this fails, the trap is triggered.
- Lockpicking: Chance to open a lock. If this fails, any existing trap is triggered.
- Searching: Some treasures need a minimum value for this to be detected. Actually in Ambermoon there is a single one in the Antique Area level 3 which needs a value of 50.
- Read magic: Chance to learn a spell from a spellscroll. If this fails the spellscroll is destroyed.
- Use magic: Chance to cast a spell successfully. Some spells will have negative effects if the cast fails. Mostly item-targeted spells.
