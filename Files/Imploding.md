# Imploding

The imploder takes a [hunk](Hunks.md) file, compresses the hunks and create a new hunk file which restores the original hunks on execution.

Basically the imploder does the following steps:

- Create a small CODE hunk at the beginning which starts the decompression.
- Create a BSS hunk for each of the hunks of the source file (no RELOC32 or END hunks). These have the same size as the uncompressed hunks in the source file of course.
- Create 3 hunks for decompression. Those were freed after decompression on the Amiga so they came last.
  - A CODE hunk which performs the actual decompression
  - A DATA hunk which contains the compressed data of all the source hunks
  - A BSS hunk which serves as a decompression buffer

So for example if you have 6 major hunks like in AM2_CPU the imploder will generate an output with following structure:

Hunk type | Description
--- | ---
CODE | Small start code
BSS | Allocation of source hunk 1
BSS | Allocation of source hunk 2
BSS | Allocation of source hunk 3
BSS | Allocation of source hunk 4
BSS | Allocation of source hunk 5
BSS | Allocation of source hunk 6
CODE | Decompression algorithm
DATA | Compressed data of all 6 source hunks
BSS | Allocation of decompression buffer

## Decompression

The imploder uses a variant of the [LZ77](https://en.wikipedia.org/wiki/LZ77_and_LZ78) algorithm. A deploder is able to decompress the DATA hunk mentioned above.

Deploding uses a **bit buffer** which contains bits that the deploder reads to determine what to do next. The **bit buffer** is a single 8-bit value and it's initial value has to be given beforehand. You can find it at offset 0x1E8 in the decompression CODE hunk (I am not sure if this is always the case but it is for AM2_CPU).

Another thing the deploder needs is a so called **explosion table**. It contains 8 16-bit values which represent match offset base values and 12 8-bit values which represent number of bits which are read to add to the offset. They can be found at offset 0x188 in the decompression CODE hunk (again I am not sure if this is always the case but it is for AM2_CPU).

Moreover the deploder needs another such table for literals. It contains 4 base values (for the next literal length) and 12 values which represent the number of extra bits to read for adding to the length. This table is fixed and has the following values:

```
literalLengthBase = { 6, 10, 10, 18 };
literalLengthExtraBits = { 1, 1, 1, 1, 2, 3, 3, 4, 4, 5, 7, 14 };
```

The last thing the deploder needs is the **first literal length** which you can find at offset 0x1E6 inside the decompression CODE hunk as a big-endian 16-bit value.

### Details

Basically the imploder encodes data as either raw literals (uncompressed bytes) or matches.

A match is encoded as an offset and a length. The offset is relative to the current output position inside the output stream. The length is the number of bytes the match is long.

The general process is a loop which runs until all data is decompressed. And it does basically the following 5 things:

1. Copy n raw literals from input to output where n is the last read literal length (or the **first literal length** if first iteration).
2. Read the next match length.
3. Read the next literal length.
4. Read the next match offset.
5. Copy the match inside the output.

Note that the imploder stores the compressed data in reverse order so the first byte comes last. So to read the input correctly you have to read from the end of the stream to the beginning. Moreover there seem to be 3 extra bytes at the end (at the beginning of the input) that have to be skipped. Not sure if this is always true but I hope so.

#### 1. Copy the literals

This is basically a simple copy byte operation. Initialize the literal length with the **first literal length** and then use the literal length for the copy amount in each iteration of the decompression. The literal length will be updated to the next literal length in step 3.

If the output pointer has reached the full size you should stop decompressing right after this step.

#### 2. Read the next match length

You have to read the next bits from the **bit buffer** (see below) as a huffman value (see below). The huffman tree is static:

Bits | Selector | Match length
--- | --- | ---
0 | 0 | 2
10 | 1 | 3
110 | 2 | 4
1110 | 3 | 5
11110 | 3 | 6 + next 3 bits (length range is 6 to 13)
11111 | 3 | next input byte (length range is 1 to 255, 0 is invalid)

So in the last 2 cases you have to read additional bits from the **bit buffer** to get the real match length. The selector is needed in steps 3 and 4.

#### 3. Read the next literal length

Again you have to read static huffman values from the **bit buffer**.

Bits | Base length | Extra bits
--- | --- | ---
0 | 0 | literalLengthExtraBits[0 + selector]
10 | 2 | literalLengthExtraBits[4 + selector]
11 | literalLengthBase[selector] | literalLengthExtraBits[8 + selector]

So here you need the static literal length tables mentioned at the beginning. The selector given in step 2 is used as an index inside these tables.

Example:

Selector was 2 and you read the static huffman value 11 (binary).
So the next literal length would be:

```
nextLiteralLength = literalLengthBase[2] + readBits(literalLengthExtraBits[8 + 2]);
```

Which is equivalent to:

```
nextLiteralLength = 10 + readBits(7);
```

An much more easier example would be with huffman code 0 where the base length value is fixed at 0 and the extra bits are always 1 regardless of the selector. So in this case the next literal length is either 0 or 1:

```
nextLiteralLength = 0 + readBits(1);
```

In the next decompression loop in step 1 you will have to copy this number as raw literals.

#### 4. Read the next match offset

This is very similar to step 3 but with the following meanings:

Bits | Base offset | Extra bits
--- | --- | ---
0 | 1 | explosionTableExtraBits[0 + selector]
10 | 1 + explosionTableBaseOffsets[0 + selector] | explosionTableExtraBits[4 + selector]
11 | 1 + explosionTableBaseOffsets[4 + selector] | explosionTableExtraBits[8 + selector]

So we use the **explosion table** here which was mentioned in the beginning. This table is provided in the decompression CODE hunk. explosionTableBaseOffsets is the array of 16-bit base offsets and explosionTableExtraBits is the part with the 8-bit extra bit values.

The algorithm to calculate the real match offset as similar to this of step 3. You take the base offset and add the value of `readBits(extraBits)`;

But there is one specialty here. The extra bits value can have a special encoding where the most significant bit is set. For example you get the value 0x80 or 0x81 here. Such a value means that you will read a full byte first and then add n bits to the right where n is the value & 0x7f. What this basically means is that bit amounts >= 8 are read in a way where the first 8 bits are read as a full byte from the input stream and then continue with the rest bits from the **bit buffer** as usual.

*Side note: It took me quiet some time to reverse-engineer this undocumented specialty. :) But it is used in AM2_CPU.*

#### 5. Copy the match

Basically you read n bytes at the output pointer - the match offset where n is the match length and write each byte to the output pointer. If you decode in reverse order the minus becomes a plus of course. ;)

### Bit buffer

The **bit buffer** is a byte that is used by all readBits operations either for huffman values or just additional values. It is initialized by the **initial bit buffer** value from the decompress CODE hunk.

When reading from the **bit buffer** the most significant bit is read first. So you literally read the bits from left to right from most significant to least significant.

But the reading is special. After each reading the content is bit-shifted left by 1. If the **bit buffer** becomes 0 after this, the **bit buffer** is immediately replaced by the next input byte and the read bit value is the first bit of the new **bit buffer**. If the previously read bit was 1 (which is always the case if the initial bit buffer wasn't 0) the new **bit buffer** is increased by 1. This last thing ensures that every new **bit buffer** ends with a 1.

The mentioned algorithm is equivalent to reading each bit for every bit buffer but the initial bit buffer. The initial bit buffer is only read until the last 1 is found.

**Example:**

Initial bit buffer = 0xa2 (binary: ‭10100010‬) \
Next input byte = 0x00 (binary: 00000000)

Read | Bit value | New bit buffer after left-shift
--- | --- | ---
1st | 1 | 01000100
2nd | 0 | 10001000
3rd | 1 | 00010000
4th | 0 | 00100000
5th | 0 | 01000000
6rd | 0 | 10000000
7th | 0 | 00000000 <- next byte is read, new bit buffer is 00000001

You see that on the 7th read (bit 6) the content becomes 0 and so the buffer is immediately replaced by the next input byte (which is 0x00). The resulting bit value is the most significant bit of the new byte (which is 0). So the 7th read does not return 1 but 0 and what is more important: the last 3 bits of the initial bit buffer are not read at all. The last 1-bit of the initial bit buffer is a marker and no real data.

Note that in the example the next byte (0x00) is left-shifted immediately too after reading the first bit and then the 1 from the previous read is added. So the new bit buffer content becomes `(0x00 << 1) + 1` which is 00000001 in binary.

Then the last 1 which was added is again a marker and no data. But on each bit buffer swap the marker 1 is moved over to the next buffer and as the marker is at the 8th position (7th but it was shifted before), all 8 bits of each following bit buffer are used.

### Read multiple bits

If you need to read multiple bits as a value (like with extra bits) you have to know that these bits are stored with most-significant bit first.

**Example:**

Read the 3 bits 1 1 0 in this order.

The result should be 6 (binary: 110) and not 3 (binary: 011). You can do this with the following pseudo-code:

```
int value = 0;
for (i = 0; i < numBits; ++i)
{
    value <<= 1; // bit-shift left by 1
    value |= readBits(1);
}
```

### Huffman trees

I won't go into details about huffman trees here. If you are interested you might look [here](https://en.wikipedia.org/wiki/Huffman_coding).

Basically speaking the huffman tree encodes data with fewer bits. A static huffman tree provides static bit sequences with an associated meaning. In our context it is basically a dictionary of bit sequences like the tables above.

When you read a huffman value you have to read bit by bit. After each read it is clear if the read bit sequence represents a huffman code or more bits are needed.

If you have for example the possible binary huffman codes 0, 10 and 11 you will read like this:

Read the first bit. If it is 0 you immediately know it is code 0. If it is 1 you have to read more bits. So in this case read the second bit. If it is 0 you have code 10, if it is 1 you have code 11. All huffman codes above work like this.

You can represent this by consecutive if-statement like:

```
if (readBits(1) == 1) // code 1X need more bits
{
    if (readBits(1) == 1) // code 11
    {

    }
    else // code 10
    {

    }
}
else // code 0
{

}
```

## Closing

The algorithm described above can be used to decompress the DATA hunk of the imploded file. The deploded data will contain the data of all hunks in the resulting file.

The hunk sizes can be taken from the BSS hunks in the imploded file. I don't know how to distribute the decompressed data to the destination hunks correctly as I didn't bother with it yet. I only needed this to read the item data and other stuff from AM2_CPU and I can also read it from the undistributed decompressed data. So if you have any input, feel free to add this info.

Another point is the size of the uncompressed data. There is a 24-bit big-endian value at offset 0x1D in the decompress CODE hunk which seem to be about right. But I am not sure if this is 100% correct as my testing revealed that a bunch of bytes (around 50) remain in the input untouched. Counting together the sizes of the BSS hunk sizes seem to be wrong as well (maybe there is some stuff in-between that is not decoded?). I don't know but you can add this information if you want.