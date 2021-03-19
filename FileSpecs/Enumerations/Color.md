# Colors

Every tile or wall specifies a color that is used to render the minimap (MapView spell). Dependent on the map type the color index has some different meaning.

For example for world maps the following color indices are used:

Index | Color
--- | ---
0 | Transparent / black
1 | White
2 | Light grey
3 | Beige
4 | Grey
5 | Brown
6 | Dark brown
7 | Green
8 | Darker green
9 | Darkest green
10 | Bright green
11 | Brightest green
12 | Blue
13 | Dark blue
14 | Light brown
15 | Yellow

The actual color mapping is hard-encoded inside the AM2_CPU. In the german 1.01 (1.05) version it can be found in the second data hunk at relative offset 0x12BE.

There are 3 mapping tables (16 bytes each):

```
00 1F 1E 1D 1C 1B 1A 12 13 14 11 10 09 0A 18 17
00 01 1F 12 1C 14 15 06 08 0A 04 02 0E 0C 13 10
00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
```

Each row represents the mapping for a specific map type:
1. 2D maps which are no world map
2. 2D world maps
3. 3D maps

The values represent indices into the map's palette. The column is the color index.

For example on a world map a grass tile might use color index 10. Then you have to use the second mapping with index 10:

<code>00 01 1F 12 1C 14 15 06 08 0A **04** 02 0E 0C 13 10</code>

So you will get index 4. As the world map uses palette 1 you now have to look in this palette and get the 5th color (index is 0-based) which is a green tone.
