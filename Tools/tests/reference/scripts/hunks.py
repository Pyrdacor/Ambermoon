# hunks.py <exe>: the hunk structure of a (not imploded) Amiga executable
import struct, sys
d = open(sys.argv[1], 'rb').read(); p = 0
def dw():
    global p
    v = struct.unpack('>I', d[p:p+4])[0]; p += 4; return v
assert dw() == 0x3f3
dw(); n = dw(); first = dw(); last = dw()
sizes = [dw() for _ in range(last - first + 1)]
print('header', n, first, last, ['%x' % s for s in sizes])
while p + 4 <= len(d):
    t = dw()
    if t in (0x3e9, 0x3ea):
        cnt = dw(); print('%x' % t, cnt, 'bytes', cnt * 4); p += cnt * 4
    elif t == 0x3eb:
        print('bss', dw())
    elif t == 0x3ec:
        ents = []
        while True:
            c = dw()
            if c == 0: break
            h = dw(); offs = [dw() for _ in range(c)]; ents.append((h, c))
        print('reloc32', ents)
    elif t == 0x3f2:
        print('end')
    else:
        print('?? %x at %d' % (t, p - 4)); break
