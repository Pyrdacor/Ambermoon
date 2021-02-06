# Labdata

Labdata (labyrinth data) contains information about objects, walls, floor and ceiling in 3D labyrinths.

## Lab data header

Offset | Type | Description
----|----|----
0x0000 | uword | Wall height (mostly near the range 300~400).
0x0002 | ubyte | **Unknown**
0x0003 | ubyte | Combat background index (only in the lower 4 bits), not sure if the upper 4 bits have some meaning.
0x0004 | ubyte[2] | **Unknown**
0x0006 | ubyte | Ceiling texture index (taken from Floors.amb)
0x0007 | ubyte | Floor texture index (taken from Floors.amb)

## Objects

After the header there are the objects. Objects are really object groups. So they can be created out of 1 to 8 single objects.

The section starts with an uword which is the number of object groups. Object groups are referenced from [3D map blocks](Maps3D.md).

Each object group consists of a header (uword) which is **unknown** yet and 8 object entries. As stated before, object groups consists of 1 to 8 objects. For example the meat and sausages in grandfather's cellar are two textures/billboards (objects) which form one real map object.

Each object entry inside the group consists of 4 uwords.

Offset | Type | Description
----|----|----
0x0000 | uword | Relative X
0x0002 | uword | Relative Y
0x0004 | uword | Relative Z
0x0006 | uword | Object data index (see below)

The relative positions are relative to the map block from the 3D map.

A block's dimension seems to be 512x512x512 so values of 255 are used to center objects. Note that the given position is the center of the object.

The object group section contains 66 bytes per object group.

Note that the object data index is 1-based and 0 means "no object". The latter is used to mark unused/empty object entries. When you load the object data below they might be 0-based so you have to subtract 1 to get the right object data for non-empty objects.

## Object data

After the object groups the object data entries follow which contain the real information of objects like texture information.

This section again starts with an uword which is the number of object data entries.

Each object data consists of 14 bytes:

Offset | Type | Description
----|----|----
0x0000 | ubyte[3] | Header/Collision info? (**Unknown** yet)
0x0003 | ubyte | Object flags (see below)
0x0004 | uword | Texture index (taken from XObject3D.amb)
0x0006 | ubyte | Number of animation frames
0x0007 | ubyte | **Unknown**
0x0008 | ubyte | Texture width (as the texture file uses)
0x0009 | ubyte | Texture height (as the texture file uses)
0x000A | uword | Mapped texture width (used in rendering)
0x000C | uword | Mapped texture height (used in rendering)

The mapped texture dimensions are used to resize the texture (stretch or shrink). For example if the mapped texture width is twice the normal texture size, the object appears wider.

### Object flags

Bit | Property
----|----
3 | Floor object? (e.g. used by the hole in grandfather's cellar)
7 | Block movement (e.g. solid barrels)
Rest | **Unknown**

## Walls

After object groups and object data, the wall data is located. It again starts with an uword that gives the amount of wall data entries.

Each wall data entry consists of a header and optional overlay data.

### Wall data header

The header is 8 bytes in size.

Offset | Type | Description
----|----|----
0x0000 | ubyte[3] | **Unknown**
0x0003 | ubyte | Flags (see below)
0x0004 | ubyte | Texture index (taken from XWall3D.amb)
0x0005 | ubyte | Automap type (see [Maps3D](Maps3D.md))
0x0006 | ubyte | **Unknown**
0x0007 | ubyte | Number of overlays

If the number of overlays is greater than zero then there will be this amount of overlay data entries for this wall.

### Wall flags

Bit | Property
----|----
1 | Block sight (not 100% sure but beside walls this is used by doors or exits)
3 | Texture transparency (e.g. spider webs)
7 | Block movement (e.g. normal solid walls)
Rest | **Unknown**

### Overlay data entry

Each overlay is a decal/subtexture drawn on the wall texture. Like a button, sign or riddlemouth.

An overlay data entry consists of 6 bytes:

Offset | Type | Description
----|----|----
0x0000 | ubyte | Blending (0: off, 1: on)
0x0001 | ubyte | Texture index (taken from XOverlay3D.amb)
0x0002 | ubyte | Relative X offset in pixels
0x0003 | ubyte | Relative Y offset in pixels
0x0004 | ubyte | Texture width (as the texture file uses)
0x0005 | ubyte | Texture height (as the texture file uses)

If blending is off the overlay will just override the wall data. This means that even transparent pixels are integrated into the wall. If blending is on, transparent pixels will be discarded from the overlay or more precisely the overlay pixels are blended over the wall.


## Notes

As the texture dimensions are given by the labdata it is best to read object and overlay graphics through labdata loading. Wall textures on the other hand are always 128x80 pixels and floor textures are always 64x64 pixels in size.
