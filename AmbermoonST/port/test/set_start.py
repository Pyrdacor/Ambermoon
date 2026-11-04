#!/usr/bin/env python3
"""Sets the start of a new game in a copy of the hd folder (for tests, e.g. of a 3D map).

    set_start.py <hd folder> <map> <x> <y> [direction] [hour]

A new game starts with the position of Save.00/Party_data.sav (the work copy of the savegame), so the
position is written into every Party_data.sav of DATA (Initial and Save.*): map, x and y in tiles (1-based),
direction (0 up, 1 right, 2 down, 3 left; default 0) and the hour (default 12, the minute is set to 0).
Use a copy of the hd folder, the build writes the original files again.
"""
import glob
import os
import struct
import sys


def main():
    hd, mp, x, y = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
    direction = int(sys.argv[5]) if len(sys.argv) > 5 else 0
    hour = int(sys.argv[6]) if len(sys.argv) > 6 else 12
    files = glob.glob(os.path.join(hd, 'DATA', '*', 'PARTYDAT.SAV'))
    for p in files:
        d = bytearray(open(p, 'rb').read())
        struct.pack_into('>HHHHHH', d, 6, hour, 0, mp, x, y, direction)
        open(p, 'wb').write(d)
    print('%d files' % len(files))


if __name__ == '__main__':
    main()
