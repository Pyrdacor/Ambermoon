Ambermoon had some bugs. Beside bad translations or typos we will show real bugs here which lead to crashes or caused things to malfunction.

Note: This list is not complete and will be updated from time to time.

## Disease reduces wrong values

The disease status should reduce a random attribute by 1 every day. Each attribute uses 4 values which all are 2 bytes in size. So to get from the current value of one attribute to the current value of the next attribute you have to increase the data address by 8 (=4*2bytes). Unfortunately Ambermoon increases the address by only 6. I guess the 4th value was added later. Therefore instead of deceasing current intelligence, the backup value of strength is reduced. Instead of dexterity the max intelligence value is reduced and so on.

## Parry logic inversed

Parry is an active action during battles. The success depends only on the character's Parry ability. But Ambermoon accidentally used the inverse logic. So if parrying fails due to dice roll, it actually succeeds and vice versa. Therefore characters with high parry values will fail to parry very often.

## Aging is broken

Each year the character's age is increased by 2 instead of 1. So a character also dies twice as fast of age. This does not happen with artificial aging though. Moreover when a character dies of age the screen drawing is messed up. In general dying of age shouldn't have happened much as even one year is very long in Ambermoon and artificial aging isn't applied too often or not for long.

*To be continued ...*
