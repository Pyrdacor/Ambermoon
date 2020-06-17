# Ailments

These are bit flags. So combininig them with bitwise OR will allow multiple ailments on a character.

For example the value 0x11 (which is 0x01 OR 0x10) would mean that the character is both irritated and blind.

Value | Name
----|----
0x0000 | No ailment
0x0001 | Irritated
0x0002 | Crazy
0x0004 | Sleep
0x0008 | Panic
0x0010 | Blind
0x0020 | Stoned (drugs)
0x0040 | Exhausted
0x0080 | - (unused?)
0x0100 | Paralyzed
0x0200 | Poisoned
0x0400 | Petrified
0x0800 | Diseased
0x1000 | Artificial aging
0x2000 | Dead (corpse)
0x4000 | Dead (ashes)
0x8000 | Dead (dust)