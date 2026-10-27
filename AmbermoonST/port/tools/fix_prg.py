#!/usr/bin/env python3
"""Checks (and corrects) the header of a TOS program made by vasm.

    fix_prg.py <AMBERST.PRG>

Older vasm versions (1.9) write a data length which is 2 bytes too short when the program is assembled with
-align: the last word of the data segment is then not loaded, and TOS reads the start of the relocation table at
the wrong place (it starts with 0 there, which means "no relocations": the program crashes at once). The real data
length is the one with which the relocation table (after text, data and symbols) ends exactly at the end of the
file.
"""
import struct
import sys


def relocations_fit(d, start):
    """True if a relocation table starting at start ends exactly at the end of the file."""
    if start + 4 > len(d):
        return False
    first = struct.unpack('>I', d[start:start + 4])[0]
    if first == 0:
        return start + 4 == len(d)
    if first & 1:
        return False
    i = start + 4
    while i < len(d):
        b = d[i]
        i += 1
        if b == 0:
            return i == len(d)
        if b & 1 and b != 1:
            return False
    return False


def main():
    path = sys.argv[1]
    d = bytearray(open(path, 'rb').read())
    text, data, bss, syms = struct.unpack('>IIII', d[2:18])
    if relocations_fit(d, 28 + text + data + syms):
        return
    for extra in (2, 4, 6):
        if relocations_fit(d, 28 + text + data + extra + syms):
            d[6:10] = struct.pack('>I', data + extra)
            open(path, 'wb').write(d)
            print('%s: data length corrected (+%d bytes)' % (path, extra))
            return
    raise SystemExit('%s: the relocation table does not fit, the header is wrong' % path)


if __name__ == '__main__':
    main()
