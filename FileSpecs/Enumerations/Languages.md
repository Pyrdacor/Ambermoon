# Languages

These are bit flags. So combininig them with bitwise OR will allow multiple languages for a character.

For example the value 0x03 (which is 0x01 OR 0x02) would mean that the character speaks the human language and the elfish language.

Value | Name
----|----
0x00 | No language
0x01 | Human
0x02 | Elfish
0x04 | Dwarfish
0x08 | Gnomish
0x10 | Sylphic
0x20 | Felinic
0x40 | Morag
0x80 | Animal

In **Ambermoon Advanced** there are additional languages in character byte 0x22.

Value | Name
----|----
0x01 | Old language
