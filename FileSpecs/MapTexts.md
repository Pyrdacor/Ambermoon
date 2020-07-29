# Map texts

For most map files there is an associated map text file inside the XMap_texts.amb containers. The file number matches the map data file number. To be more specific there is a map text file for every map but many of them may have a size of 0.

The map text files contain all texts that are used on the map and the map title (if this is not a world map). The map title is always the first entry if it exists.

### Map text header

Offset | Type | Description
--- | --- | ---
0x00 | uword | Number of map texts (n)
0x04 | uword[n] | Sizes of all the map texts
\* | ubyte[] | Map texts

Each map text consists of x bytes where x is the associated size from the header. Texts may contain leading and trailing spaces and may contain a null-byte at the end. It is best to trim spaces and null-bytes for the read string at both sizes. The encoding is codepage 850.