# LOB compression

The LOB compression was created by Lothar Beck who was related to Ambermoon. It is a proprietary algorithm so not much is known.

There was a piece of C code in the Amberworld project which could decompress LOB data (see the below C code example). Oliver Gantert from the Amberworld project mentioned recently that he can now also compress with LOB.

After looking at this code for a while I understood how LOB works and that the algorithm for decompression is actually much simpler. See my C# code example below.

Nico Bendlin researched this even better. Have a look here: https://gitlab.com/ambermoon/research/-/wikis/compression.

## Header

LOB compressed files usually start with the header $014c4f42. The last 3 bytes are "LOB" in ASCII. The first byte specifies the number of iterations or stated differently: how often the data was LOB compressed. A value of 1 means just once, a value of 2 means after compressing once, the resulting data was LOB compressed again, and so on.

## LOB decompression

LOB data consists of chunks. Each chunk starts with an 8 bit header. Each bit of the header gives information about the following data. A 0 means "match data" and a 1 means a normal byte.

Matches are encoded as 2 bytes. A normal byte (also called literal or octet) is of course 1 byte in size. So a chunk can be 8 to 16 bytes without the header.

The most significant bit of the header is processed first.

Example header: $19 (hex) -> in binary `00011001`

This means the first 3 following byte-pairs encode matches (2 bytes per match). Then two normal bytes follow, then two matches again and at last there is another normal byte.

### Match encoding

A match is encoded in two bytes: `AB CD`

The length of the match is encoded in the least significant 4 bits of the first byte (`B` in the example). The value of 3 is added to that. So a match can have a length between 3 and 18.

The match offset is encoded as 12 bits (hex: `ACD` in the example above). Theoretically a match offset can range from 0 to 4095 but match offsets of 0 make no sense at all. A match offset of 1 can be used to express run-length encoded bytes.

Example match data (hex): 1**4** 03

- Match Length = **04**hex + 3 = 7dec
- Match offset = 103hex = 259

So while decoding the decoder looks 259 bytes back into the previous decoded data and takes 7 bytes from there. Those bytes are added to the end of the decoded data. Then the next header bit is processed.

## C# optimized code

This code was created by me and works for all Ambermoon files which use LOB compression.

```cs
var decodedData = new byte[decodedSize];
uint decodeIndex = 0;
uint matchOffset;
uint matchLength;
uint matchIndex;

while (decodeIndex < decodedSize)
{
	byte header = reader.ReadByte();

	for (int i = 0; i < 8; ++i)
	{
		if ((header & 0x80) == 0) // match
		{
			matchOffset = reader.ReadByte();
			matchLength = (matchOffset & 0x000f) + 3;
			matchOffset <<= 4;
			matchOffset &= 0xff00;
			matchOffset |= reader.ReadByte();
			matchIndex = decodeIndex - matchOffset;

			while (matchLength-- != 0)
			{
				decodedData[decodeIndex++] = decodedData[matchIndex++];
			}
		}
		else // normal byte
		{
			decodedData[decodeIndex++] = reader.ReadByte();
		}

		if (decodeIndex == decodedSize)
			break;

		header <<= 1;
	}
}
```

## C code

The following code was written by Oliver Gantert (Project Amberworld). It is able to decompress LOB data as well.

```c
void AMB_UnLOB(void *src, void *dst, ulong dstsize)
{
	uchar	*a0 = (uchar *)src,
			*a1 = (uchar *)dst,
			*a2;
	ulong	d0 = dstsize;
	ushort	d1 = 0x80,
			d3;
	uchar	d2,
			xflag,
			carry;

	while (d0)
	{
		d1 += d1;
		xflag = (d1 > 0xff);
		carry = xflag;
		d1 &= 0x00ff;
		if (!d1)
		{
			d1 = *(a0++);
			d1 += d1;
			if (xflag) ++d1;
			carry = (d1 > 0xff);
			d1 &= 0x00ff;
		}

		if (!carry)
		{
			d3 = *(a0++);
			d2 = (d3 & 0x000f) + 3;
			d3 <<= 4;
			d3 &= 0xff00;
			d3 |= *(a0++);
			a2 = a1 - d3;
			while (d2--)
			{
				*(a1++) = *(a2++);
				--d0;
			}
		}
		else
		{
			*(a1++) = *(a0++);
			--d0;
		}
	}
}
```
