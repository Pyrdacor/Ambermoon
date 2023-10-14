# Conditions

These are bit flags. So combininig them with bitwise OR will allow multiple ailments on a character.

For example the value 0x11 (which is 0x01 OR 0x10) would mean that the character is both irritated and blind.

Value | Name | Effect
--- | --- | ---
0x0000 | No ailment | None
0x0001 | Irritated | Not able to cast spells (battle-only status)
0x0002 | Crazy | Not able to access inventory or give orders, will pick random battle actions
0x0004 | Sleep | Not able to give orders, status ends when receiving damage (battle-only status)
0x0008 | Panic | Not able to access inventory or give orders, will retreat and flee automatically (battle-only status)
0x0010 | Blind | Map view is black if selected, reduced hit chance
0x0020 | Stoned (drugs) | Fancy colors and moving mouse cursor if selected
0x0040 | Exhausted | All values (attributes and abilities) are halved (the STR reduction will also decrease the max weight and may cause Overweight status as well). Moreover the party member is damaged every ingame hour but not in battles. Can not parry in battles.
0x0080 | Fleeing | The character is about to flee
0x0100 | Paralyzed | Not able to move or attack.
0x0200 | Poisoned | Receives damage every battle round or ingame hour when outside battles.
0x0400 | Petrified | Not able to give orders or do anything at all. Inventory not accessible. Can't be damaged by attacks or damage spells.
0x0800 | Diseased | Every day a random attribute is decreased by 1. Bugged in Ambermoon as it uses the wrong data offset and decreases wrong values.
0x1000 | Artificial aging | Age is increased every day.
0x2000 | Dead (corpse) | Not able to give orders. Won't receive Exp.
0x4000 | Dead (ashes) | Not able to give orders. Won't receive Exp. Can only be revived by transforming the ashes first.
0x8000 | Dead (dust) | Not able to give orders. Won't receive Exp. Can only be revived by transforming the dust first.

There is also an Overweight status which is active if the carried weight exceeds the max weight (which is Strength in kilogram). It has no own ailment flag as it can be determined by the weight.

Every character ages each year (with artificial aging every day). Dependent on race there are max values for the age (e.g. 80 for humans). If reaching the max age, a character dies. Some ailments will prevent aging: dead (all types), petrify and the unknown ailment 0x80. One of these ailments must be active on the year (or day) transition to prevent the age increase.


## Masks

The Amiga game code defines the following masks where the lowest (rightmost) digit is the first condition and the highest (leftmost) digit is the last condition.

```
Fight_mask	    	EQU %1110000010000000
Control_mask    	EQU %1110010010001110
Damage_mask     	EQU %1110010000000000	; Can NOT be damaged
Parade_mask     	EQU %1110010101001110	; Combat actions
Attack_mask     	EQU %1110010110001100
Move_mask 	    	EQU %1110010110000100
Blink_mask	    	EQU %1110010010000000
Flee_mask 	    	EQU %1110010110000100
Magic_mask	    	EQU %1110010010101101
Use_item_mask   	EQU %1110010110101110
Reset_mask	    	EQU %1111111101110010	; To reset combat conditions
Animate_mask    	EQU %1110010110000100
End_monster_mask	EQU %0000010100101011 ; Impossible conditions for bosses
```
