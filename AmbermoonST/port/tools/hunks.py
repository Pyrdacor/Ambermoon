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


LITERAL_BASE = [6, 10, 10, 18]
LITERAL_BITS = [1, 1, 1, 1, 2, 3, 3, 4, 4, 5, 7, 14]


def deplode_data(src, table, literals, bits):
    """The data of the Imploder (read backwards), see Files/Imploding.md."""
    base = [struct.unpack_from('>H', table, i * 2)[0] for i in range(8)]
    extra = table[16:]
    pos = len(src)
    buf = bits
    out = bytearray()

    def byte():
        nonlocal pos
        pos -= 1
        return src[pos] if pos >= 0 else 0

    def read(n):
        nonlocal buf
        r = 0
        if n & 0x80:
            r = byte()
            n &= 0x7f
        for _ in range(n):
            bit = buf >> 7
            buf = buf << 1 & 255
            if not buf:
                last = bit
                buf = byte()
                bit = buf >> 7
                buf = (buf << 1 & 255) + last
            r = r << 1 | bit
        return r

    while True:
        for _ in range(literals):
            out.append(byte())
        if pos <= 0:
            break
        if not read(1):
            sel, length = 0, 1
        elif not read(1):
            sel, length = 1, 2
        elif not read(1):
            sel, length = 2, 3
        elif not read(1):
            sel, length = 3, 4
        elif not read(1):
            sel, length = 3, 5 + read(3)
        else:
            sel, length = 3, byte() - 1
        y, x = 0, sel
        if read(1):
            if read(1):
                y, x = LITERAL_BASE[sel], sel + 8
            else:
                y, x = 2, sel + 4
        literals = y + read(LITERAL_BITS[x])
        match = len(out) - 1
        x = sel
        if read(1):
            if read(1):
                match -= base[sel + 4]
                x += 8
            else:
                match -= base[sel]
                x += 4
        match -= read(extra[x])
        for i in range(length + 1):
            out.append(out[match + i])
    return bytes(out)


def deplode(H):
    """The hunks of an imploded executable (the list of hunks() : start code, BSS hunks, code, data, buffer)."""
    code, data = H[-3]['data'], H[-2]['data']
    size = struct.unpack_from('>I', code, 8)[0]         # (adda.l #size,a1 of the decruncher)
    d = deplode_data(data[:size], code[0x188:0x188 + 28], struct.unpack_from('>H', code, 0x1e6)[0], code[0x1e8])
    sizes = H[1:-3]
    out, p, u = [], 0, lambda q: struct.unpack_from('>I', d, q)[0]
    while p < len(d) and len(out) <= len(sizes):
        head = u(p)
        p += 4
        flags, n = head >> 30, head & 0x3fffffff
        if flags == 1:                      # RELOC32 : the offsets are deltas
            cur = out[-1]
            while True:
                c = u(p)
                p += 4
                if not c:
                    break
                h = u(p)
                p += 4
                o = 0
                for _ in range(c):
                    o += u(p)
                    p += 4
                    cur['relocs'][o] = (h, struct.unpack_from('>I', cur['data'], o)[0])
            continue
        if len(out) == len(sizes):
            break
        s = sizes[len(out)]
        if flags == 0:
            out.append(dict(kind='code', data=d[p:p + n * 4], relocs={}, mem=s['mem'], chip=s['chip']))
            p += n * 4
        elif p + 4 <= len(d) and u(p) & 0x3fffffff:
            n = u(p) & 0x3fffffff
            p += 4
            out.append(dict(kind='data', data=d[p:p + n * 4], relocs={}, mem=s['mem'], chip=s['chip']))
            p += n * 4
        else:
            out.append(dict(kind='bss', data=b'', relocs={}, mem=s['mem'], chip=s['chip']))
    return out
