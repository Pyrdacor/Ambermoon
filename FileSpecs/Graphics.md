# Graphics

There are 5 graphic formats in Ambermoon.

- 3 bit palette graphics
- 4 bit palette graphics
- 5 bit palette graphics
- 4 bit packed texture graphics
- and palettes themselves

For special graphic formats see the end of this topic.

## Palettes

These are the most simple graphics as they only store 16 bit for each color entry. A palette has always 32 color entries. So in total that makes 64 bytes per palette (32 * 16bit).

The order is as follows (values in hex):

Byte 0 | Byte 1
---- | ----
0R | GB

So red is stored in the lower 4 bits of the first byte, green in the upper 4 bits of the second byte and blue in the lower 4 bits of the second byte. Note that 4 bits can store a value from 0 to 15 but it is interpreted as 0 to 255 so you have to multiply each value by 16 (or bit shift left by 4).

### Example

Value in byte stream (hex): 08 21

- R = 8 * 16 = 128
- G = 2 * 16 = 32
- B = 1 * 16 = 16

To get better results you can add the value itself to the shifted result. So that color components become 0x11, 0x22, 0xff,etc instead of 0x10, 0x20, 0xf0,etc. This reflects the original colors even better.

## Other graphics

All other graphics use colors from a palette. So they only store the palette indices. There are 4 versions that use 3, 4 or 5 bits to store the indices. Fewer bits mean less amount of colors.

- 3 bit: 8 possible colors (e.g. used by the user interface)
- 4 bit: 16 possible colors (e.g. used by 3D textures)
- 5 bit: 32 possible colors (e.g. used by map tile graphics or items)

But the bits are not packed together for each pixel of the graphic. They are stored in so called "bit planes".

Each plane contains a specific bit (e.g. the first) of each pixel. So a 3 bit graphic has 3 planes, a 4 bit graphic 4 planes and so on.

But it's a bit more complicated. The graphic is divided into pixel rows (or scan lines). For each pixel row there are the mentioned 3 to 5 planes containing bits 0 to 4 of each pixel in the row.

So if you have a 4-bit 16x32 pixel graphic you would have 4 planes for every 16 pixel row. As each plane has 1 bit per pixel you would have 16 bits per plane and row:

```
Row0Plane0 Row0Plane1 Row0Plane2 Row0Plane3
Row1Plane0 Row1Plane1 Row1Plane2 Row1Plane3
Row2Plane0 Row2Plane1 Row2Plane2 Row2Plane3
...
Row31Plane0 Row31Plane1 Row31Plane2 Row31Plane3
```

In the 16 pixel wide example each plane has 16 bits (= 2 bytes). The most significant bit of the first byte is always for the first pixel and the least significant bit of the last byte is for the last pixel.

Note: If the graphic width is not a multiple of 8 there are additional unused bits per scan line that must be skipped on loading.

### Textures

There is a special format for wall, object and overlay textures mentioned above as **4 bit packed texture graphics**. Instead of having planes for each pixel row it has planes for every 8 pixels (I call these a chunk below). So if for example you have a 16x32 pixel texture like mentioned above you would have two plane iterations per pixel row:

```
Chunk0Plane0 Chunk0Plane1 Chunk0Plane2 Chunk0Plane3 Chunk1Plane0 Chunk1Plane1 Chunk1Plane2 Chunk1Plane3
Chunk2Plane0 Chunk2Plane1 Chunk2Plane2 Chunk2Plane3 Chunk3Plane0 Chunk3Plane1 Chunk3Plane2 Chunk3Plane3
...
Chunk62Plane0 Chunk62Plane1 Chunk62Plane2 Chunk62Plane3 Chunk63Plane0 Chunk63Plane1 Chunk63Plane2 Chunk63Plane3
```

I guess this was done because walls and objects are drawn in slices (raycast rendering) and so they used pieces of 8x1 pixels and stored them this way. This would also explain why ceiling and floors don't use this format. They use the normal 4-bit format instead.

Note: If the graphic width is not a multiple of 8 there are additional unused bits per scan line that must be skipped on loading. There is at least one object graphic where this is true in Ambermoon (texture index 90 has a width of 47 and therefore 1 additional unused bit per row).

### Example data (not packed)

The first pixel row (4 bytes, each digit/letter is a bit):

01234567 ABCDEFGH IJKLMNOP QRSTUVWX

So this would represent the first 8 pixels (each 4 bits) like:

QIA0 RJB1 SKC2 TLD3 UME4 VNF5 WOG6 XPH7

So when we use real values like:

Format | Value
--- | ---
Hex | 8F 12 01 00
Bin | 10001111 00010010 00000001 00000000

This will give us the following palette indices for the first 8 pixels:

Pixel | Palette index (bin) | Palette index (dec)
--- | --- | ---
0 | 0001 | 1
1 | 0000 | 0
2 | 0000 | 0
3 | 0010 | 2
4 | 0001 | 1
5 | 0001 | 1
6 | 0011 | 3
7 | 0101 | 5


## Palette assignment

Graphics do not specify which palette they are using. So this must be stored elsewhere or be known by the game.

For instance the map tiles use specific palettes based on the tileset index.

Textures for floors, walls, objects and overlays can just use palette 18 but the palette index is given by the map which uses these textures as well.

Portraits and items use a special palette which is not part of Palette.amb. A guy called Iceblizz managed to reconstruct this palette. It is given here as RGB and RGBA bytes (in that order):

```
// Special palette in RGB
0x00, 0x00, 0x00, 0xed, 0xdc, 0xcb, 0xfe, 0xfe, 0xed, 0xba, 0xba, 0xcb,
0x87, 0x98, 0xa9, 0x54, 0x76, 0x87, 0x21, 0x54, 0x65, 0x00, 0x32, 0x43,
0xfe, 0xcb, 0x98, 0xed, 0xa9, 0x76, 0xcb, 0x87, 0x54, 0xa9, 0x65, 0x32,
0x87, 0x43, 0x21, 0x54, 0x21, 0x10, 0xba, 0x87, 0x00, 0xdc, 0xa9, 0x00,
0xfe, 0xcb, 0x00, 0xfe, 0x98, 0x00, 0xcb, 0x65, 0x00, 0x87, 0x10, 0x21,
0xcb, 0x43, 0x32, 0xed, 0x65, 0x32, 0xa9, 0xa9, 0x43, 0x54, 0x76, 0x32,
0x21, 0x54, 0x43, 0x00, 0x10, 0x00, 0x21, 0x21, 0x21, 0x43, 0x43, 0x32,
0x65, 0x65, 0x54, 0x87, 0x87, 0x76, 0xa9, 0xa9, 0x98, 0xcb, 0xcb, 0xba

// The same palette in RGBA
0x00, 0x00, 0x00, 0xff, 0xed, 0xdc, 0xcb, 0xff, 0xfe, 0xfe, 0xed, 0xff, 0xba, 0xba, 0xcb, 0xff,
0x87, 0x98, 0xa9, 0xff, 0x54, 0x76, 0x87, 0xff, 0x21, 0x54, 0x65, 0xff, 0x00, 0x32, 0x43, 0xff,
0xfe, 0xcb, 0x98, 0xff, 0xed, 0xa9, 0x76, 0xff, 0xcb, 0x87, 0x54, 0xff, 0xa9, 0x65, 0x32, 0xff,
0x87, 0x43, 0x21, 0xff, 0x54, 0x21, 0x10, 0xff, 0xba, 0x87, 0x00, 0xff, 0xdc, 0xa9, 0x00, 0xff,
0xfe, 0xcb, 0x00, 0xff, 0xfe, 0x98, 0x00, 0xff, 0xcb, 0x65, 0x00, 0xff, 0x87, 0x10, 0x21, 0xff,
0xcb, 0x43, 0x32, 0xff, 0xed, 0x65, 0x32, 0xff, 0xa9, 0xa9, 0x43, 0xff, 0x54, 0x76, 0x32, 0xff,
0x21, 0x54, 0x43, 0xff, 0x00, 0x10, 0x00, 0xff, 0x21, 0x21, 0x21, 0xff, 0x43, 0x43, 0x32, 0xff,
0x65, 0x65, 0x54, 0xff, 0x87, 0x87, 0x76, 0xff, 0xa9, 0xa9, 0x98, 0xff, 0xcb, 0xcb, 0xba, 0xff
```


## Special graphic formats

### Combat graphics

This file contains all kind of graphics used in the battle window.

This includes:
- Spell and other animations
- An UI element
- Battle field character icons

Each of the graphics can have 1 or more frames (animation) and different sizes and bit depth.

The following list shows the graphic info in the correct order:

Frames | Width | Height | Bit depth | Description
--- | --- | --- | --- | ---
8 | 16 | 16 | 5 | Fire ball
8 | 16 | 32 | 5 | Big fire pillar flame
6 | 16 | 16 | 5 | Small flame (I guess when monsters get burned after spell use)
24 | 32 | 32 | 5 | Magic projectile human
12 | 32 | 32 | 5 | Magic projectile monster
8 | 32 | 32 | 5 | Whirlwind
4 | 32 | 32 | 5 | Blood (LP stealer?)
5 | 16 | 16 | 5 | Snow flake (ice spells)
5 | 16 | 16 | 5 | Green star (mystic spell like monster knowledge)
2 | 32 | 32 | 5 | Lightning
1 | 16 | 1 | 5 | Seems like a beam (destroy undead) but only 1 pixel line of it
1 | 16 | 19 | 5 | Arrow (red) human
1 | 16 | 19 | 5 | Arrow (red) monster
1 | 16 | 20 | 5 | Arrow (green) human
1 | 16 | 20 | 5 | Arrow (green) monster
1 | 16 | 16 | 5 | Stone (slingshot)
1 | 16 | 15 | 5 | Slingdagger
1 | 16 | 16 | 5 | Ice ball
1 | 32 | 16 | 5 | Large stone (falling stone)
1 | 64 | 32 | 5 | Landslide
1 | 64 | 32 | 5 | Large waterdrop (landing waterball)
1 | 16 | 16 | 5 | Blue beam (shooting magic)
1 | 16 | 16 | 5 | Green beam (shooting magic)
1 | 32 | 32 | 5 | Red ring
1 | 16 | 16 | 5 | Paralyze icon
1 | 16 | 16 | 5 | Poison icon
1 | 16 | 16 | 5 | Petrify icon
1 | 16 | 16 | 5 | Disease icon
1 | 16 | 16 | 5 | Aging icon
1 | 16 | 16 | 5 | Irritation icon
1 | 16 | 16 | 5 | Madness icon
1 | 16 | 16 | 5 | Sleep icon
1 | 16 | 16 | 5 | Fear icon
1 | 16 | 16 | 5 | Blind icon
1 | 16 | 16 | 5 | Drugs icon
14 | 48 | 59 | 5 | Death pillar (like a fire pillar which is displayed after monster defeat)
4 | 32 | 32 | 5 | Bloody claw (clawed monster attacks)
2 | 16 | 32 | 5 | Ice block
3 | 16 | 43 | 5 | Sword attack
4 | 32 | 32 | 5 | Blue circle (spell block)
4 | 16 | 13 | 5 | Throwing crescent
1 | 32 | 36 | 3 | Sword and mace stylistic UI element
35 | 16 | 14 | 5 | 35 battle fields character icons (this aren't really 35 animation frames but 35 static character icons for party and monsters)

Note: Only the UI element uses 3 bits per pixel and has a palette offset of 24. All others use 5 bits per pixel.

The UI element can use the current UI palette, the character icons use the same palette as the player graphics or items and the rest uses palette 18.


### 2D NPC graphics

Those are stored inside NPC_gfx.amb. There are two sub-files which can be referenced by the header value "NPC gfx index" inside a map. The first file is used for all Lyramion and Morag NPCs and the second file is used for all forest moon NPCs. The NPCs include the 2D monsters as well. In the original game there are only two 2D monsters: thieves and knights.

Each of the sub-files contain all NPC graphics. The total amount is not given directly so have to read the graphics one by one.

Each graphic begins with a byte which gives the number of frames. This should be 1 or above. If it is 0, it is most likely some fill byte so you reached the end. Then another byte follows which seems to be always 0. I guess this is just a fill byte to ensure a word boundary. Then the given amount of frames follow as 5-bit planar data. Each frame has a size of 16x32.

The original has 18 NPCs in the first sub-file and 16 NPCs in the second sub-file.
