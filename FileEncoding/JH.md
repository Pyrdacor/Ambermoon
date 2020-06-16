# JH encoding

The JH encoding was created by Jurie Horneman who was a programmer of Ambermoon. It is basically an XOR encoding. Therefore
it can be used for encoding and decoding.

## C code

The following code was written by Oliver Gantert (Project Amberworld).

```c
void AMB_JHCodec(void *pBuffer, ulong ulSize, ushort usKey)
{
	ushort *a0 = (ushort *)pBuffer;
	ushort d0 = usKey, d1;
	ulong d7 = (ulSize + 1) >> 1;

	while (d7--)
	{
		AMB_PokeW(a0, AMB_PeekW(a0) ^ d0);
		++a0;
		d1 = d0;
		d0 <<= 4;
		d0 += (d1 + 87);
	}
}
```

`AMB_PeekW` reads an unsigned 16-bit value in big endian order from the given pointer address. `AMB_PokeW` writes it to the address in the same manner.

On little endian platforms (like Windows) you have to reverse the order of the bytes.