#!/usr/bin/env python3
"""Unpacks files packed with Pack-Ice 2.x ("ICE!"), like the 68000 depacker (the data is read from the end).

    ice.py <packed file> <unpacked file>
"""
import struct
import sys


def unpack(data):
    magic, packed, size = struct.unpack('>4sII', data[:12])
    if magic != b'ICE!':
        raise ValueError('no ICE! file')
    pos = packed                          # read backwards from the end of the packed data
    out = bytearray(size)
    dst = size
    state = {'d7': 0}

    def byte():
        nonlocal pos
        pos -= 1
        return data[pos]

    def bit():
        c = state['d7'] >> 7
        state['d7'] = (state['d7'] << 1) & 0xff
        if state['d7'] == 0:              # empty : next byte, the old carry is shifted in
            b = byte()
            state['d7'] = ((b << 1) | c) & 0xff
            return b >> 7
        return c

    def bits(n):                          # n + 1 bits (dbf)
        v = 0
        for _ in range(n + 1):
            v = ((v << 1) | bit()) & 0xffff
        return v

    direct = [(0x0001, 0x0003, 1), (0x0001, 0x0003, 4), (0x0002, 0x0007, 7), (0x0007, 0x00ff, 14),
              (0x000e, 0x7fff, 269)]
    length_bits = [9, 1, 0, -1, -1]
    length_add = [8, 4, 2, 1, 0]
    offset_bits = [11, 4, 7, 0]
    offset_add = [0x11f, -1, 0x1f]

    state['d7'] = byte()
    while True:
        # ---------- literal bytes ----------
        if bit():
            count = 0
            if bit():
                for n, top, add in direct:
                    count = bits(n)
                    if count != top:
                        break
                count += add
            for _ in range(count + 1):
                dst -= 1
                out[dst] = byte()
        if dst <= 0:
            break
        # ---------- a string ----------
        d2 = 3                            # (dbcc : up to 4 one bits)
        while d2 >= 0 and bit():
            d2 -= 1
        n = length_bits[d2 + 1]
        length = length_add[d2 + 1]
        if n >= 0:
            length += bits(n)
        if length == 0:                   # 2 bytes : short offsets
            if bit():
                offset = bits(8) + 0x3f
            else:
                offset = bits(5) - 1
        else:
            d2 = 1
            while d2 >= 0 and bit():
                d2 -= 1
            offset = bits(offset_bits[d2 + 1]) + offset_add[d2 + 1]
            if offset < 0 or offset >= 0x8000:
                offset = (offset - length) & 0xffff
        src = dst + 2 + length + (offset if offset < 0x8000 else offset - 0x10000)
        for _ in range(length + 2):
            src -= 1
            dst -= 1
            out[dst] = out[src]
    return bytes(out), pos


def main():
    data = open(sys.argv[1], 'rb').read()
    out, pos = unpack(data)
    open(sys.argv[2], 'wb').write(out)
    print(f'{len(out)} bytes (packed data used down to {pos}, the header ends at 12)')


if __name__ == '__main__':
    main()
