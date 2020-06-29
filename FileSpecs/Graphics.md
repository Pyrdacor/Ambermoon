# Graphics

There are 4 graphic formats in Ambermoon.

- 3 bit palette graphics
- 4 bit palette graphics
- 5 bit palette graphics
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


## Other graphics

All other graphics use colors from a palette. So they only store the palette indices. There are 3 versions that use 3, 4 or 5 bits to store the indices. Fewer bits mean less amount of colors.

- 3 bit: 8 possible colors (e.g. used by the user interface)
- 4 bit: 16 possible colors (e.g. used by 3D textures)
- 5 bit: 32 possible colors (e.g. used by map tile graphics)

But the bits are not packed together for each pixel of the graphic. They are stored in so called "planes".

Each plane contains a specific bit (e.g. the first) of each pixel. So a 3 bit graphic has 3 planes, a 4 bit graphic 4 planes and so on.

But it's a bit more complicated. The graphic is divided into pixel lines. For each pixel line there are the mentioned 3 to 5 planes containing bits 0 to 4 of each pixel in the pixel line.

A very easy example would be a graphic with the size of 8x8. There would be 8 pixel lines. Each of them 8 pixels wide. Each plane contains 1 bit for each pixel in the line. So in this example each plane is 8 bits in size (which equals 1 byte).

If we had a 4 bit graphic we would have 4 planes. So for each pixel line there would be 4 bytes. The first byte would contain all the first bits (bit 0) of the 8 pixel values, the second byte would contain all the second bits (bit 1) of the 8 pixel values and so on. Then for each of the 8 rows the same is done (32 bytes in total).


### Example data

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