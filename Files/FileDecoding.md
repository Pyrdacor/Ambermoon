# File decoding

Every file starts with a 32-bit header. You can find the header values [here](FileTypes.md). As the value for JH is only 16-bit you have to check only the first two bytes of the header in that case. But the other 2 bytes are part of the header too. They will contain the encoding key for the JH algorithm.

## Decoding file containers

If the file is a multi-file container (like AMNC, AMNP, AMBR or AMPC) there will be another unsigned word after the header which contains the number of files in the container. And then for each file there will be an unsigned dword containing the size of that file in bytes.

The file data of each file follows one after another starting with the first file after the mentioned header and file sizes.

## Decoding single files

If the whole file is a single file provider (JH, LOB or VOL1) the file is directly decoded. In multi-file containers, each sub-file is encoded accordingly. Therefore each sub-file will contain its own header again.

So you can use a general decode file routing in both cases but for single file providers you must not skip the header of the whole file.

### Details

First read the header of the file. It can't be a multi-file container anymore at this point of course. So only JH, LOB and VOL1 can be given.

If it is a JH file the data has to be decoded with the [JH algorithm](JH.md). Note that only the data behind the header is decoded and that the **decode key** is the second word in the header (in big-endian terms it is the lower word).

If it is not a JH file but the file is part of an AMNC container, the data also must be [JH decoded](JH.md). But this time the index of the file is used as the **decode key** (file numbers start at 1!).

When the data was JH decoded you have to re-check the header (first 4 bytes of the decoded data). Otherwise use the header you got before. For example you can have a file which is LOB compressed and JH encoded. It will start with a JH header and after decoding there will be a LOB header.

If the header is now LOB or VOL1 (they use the same logic), you have to decompress the data with the [LOB algorithm](LOB.md). After the header there will be the **decoded size** (or uncompressed size) as an unsigned dword. But only the lower 24 bits are considered so use: `decodedSize = readBigEndianDword() & 0x00ffffff`.

After this the **encoded size** (or compressed size) follows as another unsigned dword. **But** if the file is part of an AMNP container you have to [JH decode](JH.md) the data first. And that means every data after the **decoded size** until the file data end. So the **encoded size** is part of the JH encoded data! Which means you have to first decode with JH and then read the encoded size. As mentioned this is only true for AMNP files.

Note: You rarely need the **encoded size** as it should be clear from the given stream data or file data sizes from the header.

Ok the last case is if the file is neither LOB nor VOL1. Note that the file could still be JH decoded before (JH header or AMNC container).

There are 2 possibilites here:
1. The file was just a normal JH file or AMNC sub-file.
2. The file is part of an AMNP container and was not LOB compressed.

In the first case we are done. The file data is completely decoded.

In the second case we need to JH decode. This basically means that AMNP containers JH encode the files if they are not LOB compressed. Note that AMNP sub-files always have a header. So if we are here, it wasn't LOB nor VOL1. In this case the header is 0 (0x00000000). You have to include it into JH decoding though but have to skip it after decoding to get the correct file data.

Note that JH decoding for AMNP files also use the file number (starting at 1) as the **decoding key**.

### Additional info

The above explanations might be a bit complicated. So here is the short version.

**JH files**: This is a single JH encoded file. When decoded it may contain LOB compressed data which starts with the header LOB or VOL1.

**LOB and VOL1 files**: This is a single LOB compressed file. No JH encoding.

**AMNC files**: This is a multi-file container. Each sub-file is encoded with the JH encoding (but there is no JH header on a sub-file). Each of the sub-files may contain LOB compressed data after JH decoding. If so they will start with a LOB or VOL1 header. Otherwise they are not compressed.

**AMNP files**: This is a multi-file container. Each sub-file is either LOB compressed or JH encoded (but never both). They have the header LOB or VOL1 if compressed or 0 if not compressed (JH encoding is used then).

**AMPC files**: This is a multi-file container. Each sub-file can be compressed when it has a LOB or VOL1 header. Otherwise it is raw data. No JH encoding is possible.

**AMBR files**: This is a multi-file container. Each sub-file is uncompressed and not JH encoded. There are no headers on sub-files at all.