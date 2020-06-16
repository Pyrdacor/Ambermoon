# LOB compression

The LOB compression was created by Lothar Beck who was related to Ambermoon. It is a proprietary algorithm so not much is known.

## C code

The following code was written by Oliver Gantert (Project Amberworld). It is able to decompress LOB data.

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

Don't ask me how this works and why.