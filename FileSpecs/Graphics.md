# Graphics

There are 5 graphic formats in Ambermoon.

- 3 bit palette graphics
- 4 bit palette graphics
- 5 bit palette graphics
- 4 bit packed texture graphics
- and palettes themselves

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

To get better results you can add the value itself to the shifted result. So that color components become 0x11,0x22,0xff,etc instead of 0x10,0x20,0xf0,etc. This reflects the original colors better.

## Other graphics

All other graphics use colors from a palette. So they only store the palette indices. There are 4 versions that use 3, 4 or 5 bits to store the indices. Fewer bits mean less amount of colors.

- 3 bit: 8 possible colors (e.g. used by the user interface)
- 4 bit: 16 possible colors (e.g. used by 3D textures)
- 5 bit: 32 possible colors (e.g. used by map tile graphics)

But the bits are not packed together for each pixel of the graphic. They are stored in so called "planes".

Each plane contains a specific bit (e.g. the first) of each pixel. So a 3 bit graphic has 3 planes, a 4 bit graphic 4 planes and so on.

But it's a bit more complicated. The graphic is divided into pixel lines. For each pixel line there are the mentioned 3 to 5 planes containing bits 0 to 4 of each pixel in the pixel line.

So if you have an 4bit 16x32 pixel graphic you would have 4 planes for every 16 pixel row. As each plane has 1 bit per pixel you would have 16 bits per plane and row:

```
Row0Plane0 Row0Plane1 Row0Plane2 Row0Plane3
Row1Plane0 Row1Plane1 Row1Plane2 Row1Plane3
Row2Plane0 Row2Plane1 Row2Plane2 Row2Plane3
...
Row31Plane0 Row31Plane1 Row31Plane2 Row31Plane3
```

In the 16 pixel wide example each plane has 16 bits (= 2 bytes). The most significant bit of the first byte is always for the first pixel and the least significant bit of the last byte is for the last pixel.

### Textures

There is a special format for wall, object and overlay textures mentioned above as **4 bit packed texture graphics**. Instead of having planes for each pixel row it has planes for every 8 pixels (I call these a chunk below). So if for example you have a 16x32 pixel texture like mentioned above you would have two plane iterations per pixel row:

```
Chunk0Plane0 Chunk0Plane1 Chunk0Plane2 Chunk0Plane3 Chunk1Plane0 Chunk1Plane1 Chunk1Plane2 Chunk1Plane3
Chunk2Plane0 Chunk2Plane1 Chunk2Plane2 Chunk2Plane3 Chunk3Plane0 Chunk3Plane1 Chunk3Plane2 Chunk3Plane3
...
Chunk62Plane0 Chunk62Plane1 Chunk62Plane2 Chunk62Plane3 Chunk63Plane0 Chunk63Plane1 Chunk63Plane2 Chunk63Plane3
```

I guess this was done to achieve better compression for large textures. The 4 planes always form a dword (32 bit value).

To make it a bit more complicated there are textures which are 4 bytes larger then the expected data size. In this case you have to skip the first 4 bytes. I am not sure yet what the purpose of this was or if I just decompressed the data wrong but it works if you do so.

Note: Floor textures don't use this format. They use the normal 4 bit palette format without the 8 pixel packing.

### Example data (not packed)

The first pixel line (4 bytes, each digit/letter is a bit):

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