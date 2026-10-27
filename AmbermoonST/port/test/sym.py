#!/usr/bin/env python3
"""Symbols of the port program (DRI/GST symbol table of a TOS program).

    sym.py <prg> <name>...        address of every name
    sym.py <prg> -w <address>...  symbol + offset of every address (e.g. a crash PC)

The text segment starts at TEXT_BASE (environment, hex, default 15bf0 : EmuTOS 1.4 with a GEMDOS drive,
other TOS versions load the program elsewhere : see the basepage in the Hatari debugger, "info basepage").
"""
import os
import struct
import sys

BASE = int(os.environ.get('TEXT_BASE', '15bf0'), 16)


def symbols(prg):
    d = open(prg, 'rb').read()
    _, t, da, b, s = struct.unpack('>HIIII', d[:18])
    o = 28 + t + da
    r = {}
    i = 0
    n = s // 14
    while i < n:
        e = d[o + i * 14:o + i * 14 + 14]
        typ = struct.unpack('>H', e[8:10])[0]
        v = struct.unpack('>I', e[10:14])[0]
        name = e[:8]
        if typ & 0x0048 == 0x0048 and i + 1 < n:     # GST long name
            i += 1
            name += d[o + i * 14:o + i * 14 + 14]
        name = name.rstrip(b'\0').decode('latin1')
        if typ & 0x0100:                             # BSS
            v += t + da
        elif typ & 0x0400:                           # data
            v += t
        r.setdefault(name, BASE + v)
        i += 1
    return r


def main():
    s = symbols(sys.argv[1])
    if sys.argv[2] == '-w':
        items = sorted((a, n) for n, a in s.items())
        for x in sys.argv[3:]:
            a = int(x.lstrip('$'), 16)
            best = max((i for i in items if i[0] <= a), default=(0, '?'))
            print(f'{a:#x} {best[1]} + {a - best[0]:#x}')
    else:
        for n in sys.argv[2:]:
            print(n, hex(s[n]))


if __name__ == '__main__':
    main()
