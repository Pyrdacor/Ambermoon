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
- uword[3]: Unknown

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