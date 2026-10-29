#!/usr/bin/env python3
"""Rewrites an LHA archive with level 2 headers (as lha / jlha-utils makes it) with level 0 headers.

    lzh_level0.py <in.lzh> <out.lzh> [expected number of files]

The unpackers of the Atari (LHarc, LZH) know the level 0 header best: the path is part of the name, the folders are
separated by "\\" (like MS-DOS and TOS), the time is a DOS time. The packed data and its CRC are taken as they are,
the folder entries (-lhd-) are left out (the unpackers make the folders of the paths). Only the methods -lh0- and
-lh5- are accepted. With the expected number of files the count is checked.
"""
import struct
import sys
import time


def entries(d):
    """(method, packed data, original size, unix time, CRC16, path parts) of every entry of a level 2 archive."""
    pos = 0
    while pos + 2 <= len(d):
        size = struct.unpack_from('<H', d, pos)[0]
        if size == 0:
            break
        if d[pos + 20] != 2:
            sys.exit('level %d header at %d: only level 2 is read' % (d[pos + 20], pos))
        method = bytes(d[pos + 2:pos + 7])
        packed, original, stamp = struct.unpack_from('<III', d, pos + 7)
        crc = struct.unpack_from('<H', d, pos + 21)[0]
        name, folder = b'', b''
        ext = struct.unpack_from('<H', d, pos + 24)[0]
        p = pos + 26
        while ext:
            kind, data = d[p], bytes(d[p + 1:p + ext - 2])
            if kind == 1:
                name = data
            elif kind == 2:
                folder = data
            p += ext
            ext = struct.unpack_from('<H', d, p - 2)[0]
        parts = [x for x in folder.split(b'\xff') if x] + ([name] if name else [])
        yield method, bytes(d[pos + size:pos + size + packed]), original, stamp, crc, parts
        pos += size + packed


def dos_time(stamp):
    t = time.gmtime(stamp)
    return ((t.tm_year - 1980) << 25 | t.tm_mon << 21 | t.tm_mday << 16 | t.tm_hour << 11 | t.tm_min << 5 |
            t.tm_sec // 2)


def main():
    src, dst = sys.argv[1], sys.argv[2]
    expected = int(sys.argv[3]) if len(sys.argv) > 3 else None
    out = bytearray()
    files = 0
    for method, data, original, stamp, crc, parts in entries(open(src, 'rb').read()):
        if method == b'-lhd-':
            continue
        if method not in (b'-lh0-', b'-lh5-'):
            sys.exit('%s: method %s' % (b'/'.join(parts), method))
        name = b'\\'.join(parts)
        body = method + struct.pack('<IIIBB', len(data), original, dos_time(stamp), 0x20, 0) + \
            bytes([len(name)]) + name + struct.pack('<H', crc)
        if len(body) > 255:
            sys.exit('%s: the name is too long for a level 0 header' % name)
        out += bytes([len(body), sum(body) & 0xff]) + body + data
        files += 1
    out += b'\x00'
    if expected is not None and files != expected:
        sys.exit('%s: %d files, expected %d' % (src, files, expected))
    open(dst, 'wb').write(out)
    print('%s: %d files, header level 0' % (dst, files))


if __name__ == '__main__':
    main()
