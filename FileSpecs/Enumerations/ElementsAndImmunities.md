# Elements and immunities

Each character has special flags that are stored in an 8 bit value. They grant some immunity and hence some are used in a way that matches elements of specific monsters, I guess it can also denote some monster element.

Bit | Property
----|----
0 | **Unknown**. Only used by the guard demon who is immune to all kind of damage and spells, no effect found.
1 | Psychic element, immune to MonsterKnowledge, Fear, Sleep, Irritation and Madness
2 | Ghost element, immune to DissolveVictim, Blindness, GhostWeapon, MagicProjectile and MagicArrows.
3 | Undead element (all undead), immune to LP-Stealer.
4 | Stone/earth element (golems), immune to Poison, Paralyze, Disease and LP-Stealer.
5 | Wind element (Gargoyle and imp but not minor demon), no effect found.
6 | Fire element (Demons and fire monsters), no effect found.
7 | Water element (only the pond lizard), no effect found.

First I thought that the elements would give several immunities against element spells but this doesn't seem to be the case at all.


## Findings

Guard demon has a value of 0xff so he has all 8 elements and their immunities. He is the only character which uses the first 3 elemens.

Dark mage (Tar the dark) has a value of 0xf0. So this means he has all the 4 major elements besides undead.

A petrified enemy gains total immunity against all damage. You cannot attack and damage dealing spells won't do anything. But I guess you can use DissolveVictim on them.

Ironically petrify works on golems which have earth element.

The pond lizard is the only pure water element monster but I didn't found any effect or immunity.
