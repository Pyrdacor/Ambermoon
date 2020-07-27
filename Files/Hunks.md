# Hunk file format

The hunk file format consists of multiple blocks of data called "hunks". Each hunk has a type and a size and of course some data.

Ambermoon and the imploder use the following hunk types:

Type | Identifier | Description
--- | --- | ---
CODE | 0x000003E9 | Contains executable code instructions
DATA | 0x000003EA | Contains data (these are the things of interest)
BSS | 0x000003EB | Used to allocate a given amount of zero bytes
RELOC32 | 0x000003EC | Relocation table (not this important for us)
END | 0x000003F2 | End marker

## Notes

Each values given here are in big-endian format. So more significant bytes come first.

I got my knowledge from [here](http://amiga-dev.wikidot.com/file-format:hunk). So if you have questions you can look there.

## Header

Offset | Type | Description
----|----|----
0x0000 | udword | Magic -> 0x000003F3
0x0004 | udword | Number of library strings (should be 0)
0x0008 | udword | Number of hunks (note that neither RELOC32 nor END chunks are counted in here)
0x000C | udword | First hunk index (should be 0)
0x0010 | udword | Last hunk index (should be number of chunks minus 1)

Note: If the number of library strings is not 0 you would have to do some more reading but we take 0 for granted here as the Ambermoon files don't use this.

## Hunk sizes

After the header there are n hunk sizes where n is the number of hunks given in the header. As mentioned only CODE, DATA and BSS chunks are considered here. When loading you should skip RELOC32 and END hunks if you don't need them. The imploded file should not contain RELOC32 hunks at all.

Each hunk size is an unsigned dword again. But it is encoded.

The most significant 2 bits specify the memory flags (e.g. to put the hunk into fast RAM etc). The lower 30 bits are the real hunk size. But the size is not in bytes but in dwords.

If the memory flags have the value 3, there will be an additional dword containing the real memory flags with bit 30 zerod out. This is important when reading the hunk sizes.

Here is how you would read the hunk size in bytes (pseudo code):

```
uint32 hunkHeader = readUint32();
uint32 hunkMemFlags = hunkHeader >> 29;

if (hunkMemFlags == 3) // skip extended mem flags byte
    seek(4); // skip another dword

uint32 hunkSizeInBytes = (hunkHeader & 0x3FFFFFFF) * 4; // 4 bytes per dword
```

This code has to be executed n times of course.

## Hunk data

After the hunk sizes there are the real hunks with their data.

Each hunk starts with a dword header which must be the identifier from the first table above. You can use it to identify the hunk types.

### Code and data hunks

These hunks have another dword following the header which gives the number of dwords that will follow. Multiply this value by 4 and you will get the number of code or data bytes.

### BSS hunks

These hunks don't have any data. They only contain a single dword which specifies the number of dword to allocate.

Note that the size given in the hunk size section is exactly this value and not the real hunk data size which would be 4 as there is only this one dword.

Again you have to multiply by 4 to get the number of bytes. This hunk type is important when dealing with the imploded files.

### RELOC32 hunks

These hunks can consist of multiple of the following blocks.

Each block starts with a number of offsets. If this value is 0 the hunk is finished. If not there are 4 + 4 * [number of offsets] bytes following. I won't go into details about there usage here. If you are interested you may look [here](http://amiga-dev.wikidot.com/file-format:hunk).

### END hunks

I only saw them in the imploded version. These hunks are empty so after the header the next hunk starts or the file ends. It's kind of a marker hunk imho.

## Which hunks are important?

The deploded AM2_CPU contains a DATA hunk with many text strings and the item data. So this hunk should be the most important one.

If you plan to reverse-engineer the original code the CODE hunk would be interesting too.

When trying do deplode the imploded AM2_CPU there are several BSS hunks, the last CODE hunk and the DATA hunk which are important to deplode the file.