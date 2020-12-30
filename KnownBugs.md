Ambermoon had some bugs. Beside bad translations or typos we will show real bugs here which lead to crashes or caused things to malfunction.

Note: This is list is not complete and will be updated from time to time.

## Disease reduces wrong values

The disease status should reduce a random attribute by 1 every day. Each attribute uses 4 values which all are 2 bytes in size. So to get from the current value from one attribute to the current value of the next attribute you have to increase the data address by 8 (=4*2bytes). Unfortunately Ambermoon increases the address by only 6. I guess the 4th value was added later. Therefore instead of deceasing current intelligence, the backup value of strength is reduced. Instead of dexterity the max intelligence value is reduced and so on.

## Parry logic inversed

Parry is an active action during battles. The success depends only on the character's Parry ability. But Ambermoon accidentally used the inverse logic. So if parrying fails due to dice roll, it actually succeeds and vice versa. Therefore characters with high parry values will fail to parry very often.


*To be continued ...*
