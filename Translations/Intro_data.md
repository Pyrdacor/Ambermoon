# Intro data

## First data hunk - Palettes and texts

The hunk starts with 8 palettes (each 64 bytes).
Then another 64 bytes which are used for palette fading.

Then some 2-byte end marker $ffff.

Then 3 words follow, each give the offset from the word itself to the townnames
Gemstone, Illien and Snakesign. In english the values are 6, 14 and 20.

So if you read the word, you add the read value minus 2 afterwards to get to the name.

Then the texts follow starting with the town names. The town names are prefixed by
a byte which gives the display X. In english it is $5c, $78 abd $5b.

All texts are null-terminated. The texts after the town names have no X value prefix.

Texts:

- Gemstone
- Illien
- Snakesign
- Presents
- Twinlake
- Lyramion
- 70 years
- later...

The last 5 texts are directly referenced from code, so this has to be adjusted after translation.

The the main menu texts follow. First there is a byte giving the amount of text (= 4).

For each entry there are 2 bytes (x and y offset) and then the null-terminated text.

All of the above makes the "non-command texts". After that the text commands follow.


Text commands:

Each command starts with a byte:

- 00: Clear screen
- 01: Add text (byte x, byte y (add 200), string text)
- 02: Render (make texts visible, fade in color)
- 03: Wait (byte ticks)
- 04: Set text color (word color)
- 05: Activate palette fading (meteor glowing)
- ff: End marker


Only the Add text commands are interesting for translations. The x has to be adjusted based on text length. The Render command basically groups texts, while the Add command sets texts for a group.

The translation texts are organized in files like 012.000.txt where 012 is the group and 000 is the index.




Make life easier:

We only translate the following specific texts.

- PRESENTS
- 70 Years
- Later ...
- Continue
- Start new quest
- View intro
- Quit
- game design
- programming
- co-programming
- artwork (2 times)
- soundtrack
- 20 years after the events of Amberstar...
- The red eye of Tarbos glints again...
- ...and descends towards Lyramion.