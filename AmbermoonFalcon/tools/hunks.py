"""Amiga hunk executable reader: hunks(path) -> list of dict(kind, mem, data, relocs={offset: (hunk, target)}, chip)."""
import struct
def hunks(path):
    d = open(path, 'rb').read()
    u = lambda p: struct.unpack_from('>I', d, p)[0]
    assert u(0) == 0x3f3
    p = 4
    while u(p):
        p += 4 + u(p) * 4
    p += 4
    n, first, last = u(p), u(p + 4), u(p + 8)
    p += 12
    table = []
    for i in range(last - first + 1):
        table.append(u(p)); p += 4
    out = []
    cur = None
    while p < len(d):
        t = u(p) & 0x3fffffff; p += 4
        if t in (0x3e9, 0x3ea):
            size = u(p) & 0x3fffffff; p += 4
            cur = dict(kind='code' if t == 0x3e9 else 'data', data=d[p:p + size * 4], relocs={})
            p += size * 4
        elif t == 0x3eb:
            size = u(p); p += 4
            cur = dict(kind='bss', data=b'', relocs={})
        elif t == 0x3ec:
            while True:
                c = u(p); p += 4
                if not c: break
                h = u(p); p += 4
                for _ in range(c):
                    o = u(p); p += 4
                    cur['relocs'][o] = (h, struct.unpack_from('>I', cur['data'], o)[0])
        elif t == 0x3f0:
            while u(p):
                p += 4 + (u(p) & 0xffffff) * 4 + 4
            p += 4
        elif t == 0x3f2:
            cur['mem'] = table[len(out)] & 0x3fffffff
            cur['chip'] = bool(table[len(out)] & 0x40000000)
            out.append(cur); cur = None
        else:
            raise ValueError('hunk %x at %x' % (t, p))
    return out
