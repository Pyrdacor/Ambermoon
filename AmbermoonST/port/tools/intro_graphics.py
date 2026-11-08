#!/usr/bin/env python3
"""The graphics, palettes, fonts and texts of the Amiga program Ambermoon_intro (like IntroData.cs of Ambermoon.net),
for the intro of the ST (intro_st.py).

    intro_graphics.py <Ambermoon_intro> <folder>      previews (png)

A graphic is a list of rows of colour numbers (0-31, None : transparent).
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from hunks import deplode_data, hunks  # noqa: E402

# the characters of the fonts : character - 0x20 -> glyph (0xff : none)
GLYPHS = [0xff, 0x42, 0xff, 0xff, 0xff, 0xff, 0x47, 0x4b, 0x44, 0x45, 0xff, 0x46, 0x3e, 0x48, 0x3f, 0x43,
          0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x40, 0xff, 0x49, 0xff, 0x4a, 0x41,
          0xff, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
          0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0xff, 0xff, 0xff, 0xff, 0xff,
          0x4b, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,
          0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0xff, 0xff, 0xff, 0xff, 0xff]


class Reader:
    def __init__(self, data, pos=0):
        self.d, self.p = data, pos

    def byte(self):
        self.p += 1
        return self.d[self.p - 1]

    def word(self):
        self.p += 2
        return struct.unpack_from('>H', self.d, self.p - 2)[0]

    def long(self):
        self.p += 4
        return struct.unpack_from('>I', self.d, self.p - 4)[0]

    def bytes(self, n):
        self.p += n
        return self.d[self.p - n:self.p]

    def string(self):
        e = self.d.index(0, self.p)
        s = self.d[self.p:e].decode('latin-1')
        self.p = e + 1
        return s


def deplode_fimp(r):
    """An "IMP!" block at the position of the reader (the reader goes on behind it)"""
    d, start = r.d, r.p
    u = lambda o: struct.unpack_from('>I', d, start + o)[0]
    size, packed = u(4) & 0x7fffffff, u(8) & 0x7fffffff
    first = d[start + packed:start + packed + 12]
    literals = u(packed + 12)
    even = d[start + packed + 16] & 0x80
    bits = d[start + packed + 17]
    table = d[start + packed + 18:start + packed + 18 + 28]
    footer = 12 + 4 + 2 + 28 + 4
    if not even:
        footer += 1
        packed -= 1
    src = bytearray(packed)
    for i in range(3):
        src[(2 - i) * 4:(2 - i) * 4 + 4] = first[i * 4:i * 4 + 4]
    src[12:packed] = d[start + 12:start + packed]
    r.p = start + packed + footer
    out = deplode_data(bytes(src), table, literals, bits)[::-1]
    assert len(out) == size, 'IMP! : %d bytes, not %d' % (len(out), size)
    return out


def planar(r, w, h, planes):
    """Line interleaved planes (a plane line : (w + 7) // 8 bytes, rounded up to 8 pixels)"""
    bpl = (w + 7) // 8
    data = r.bytes(bpl * planes * h)
    rows = []
    for y in range(h):
        row = []
        for x in range(w):
            c = 0
            for p in range(planes):
                if data[(y * planes + p) * bpl + x // 8] & (0x80 >> (x % 8)):
                    c |= 1 << p
            row.append(c)
        rows.append(row)
    return rows


class Intro:
    def __init__(self, path):
        H = hunks(path)
        self.code = H[0]['data']
        h1, h2, h3, h4 = (Reader(H[i]['data']) for i in (1, 2, 3, 4))
        # hunk 1 : palettes, texts, the commands of the credits, zoom infos
        self.palettes = [list(struct.unpack_from('>32H', h1.d, p * 64)) for p in range(8)]
        self.cycle = list(struct.unpack_from('>32H', h1.d, 8 * 64))      # (the colour of the chosen menu entry)
        h1.p = 9 * 64 + 8
        self.texts = []
        for i in range(8):
            if i < 3:                       # (Gemstone, Illien, Snakesign : an x byte first)
                h1.p += 1
            self.texts.append(h1.string())
        assert h1.byte() == 4
        self.menu = []
        for i in range(4):
            x, y = h1.byte(), h1.byte()
            self.menu.append((x, y, h1.string()))
        self.commands = []                  # (type, args)
        while True:
            t = h1.byte()
            if t == 255:
                break
            if t == 1:                      # add : x, y, text
                x, y = h1.byte(), h1.byte()
                self.commands.append((t, (x, y, h1.string())))
            elif t == 3:                    # wait : ticks
                self.commands.append((t, (h1.byte(),)))
            elif t == 4:                    # text colour
                self.commands.append((t, (h1.word(),)))
            else:                           # clear, render, palette fading
                self.commands.append((t, ()))
        # hunk 2 : the frame, the main menu, the towns
        self.frame = self.picture(h2, 288, 200)
        self.menu_picture = self.picture(h2, 320, 256)
        self.towns = [self.picture(h2, 160, 128) for _ in range(6)]
        # hunk 4 : logos, planets, meteor, sparks, clouds
        sizes = [(128, 82, 1), (272, 87, 1), (64, 64, 12), (128, 128, 1), (64, 64, 1), (64, 64, 1), (96, 88, 1),
                 (64, 47, 30), (112, 128, 1), (112, 128, 1)]
        names = ['thalion', 'ambermoon', 'sun', 'lyramion', 'morag', 'forest_moon', 'meteor', 'sparks',
                 'cloud_left', 'cloud_right']
        for (w, h, frames), name in zip(sizes, names):
            out = []
            for _ in range(frames):
                if name == 'sparks':        # the mask first (bit 0), then 4 planes
                    g = planar(h4, w, h, 5)
                    g = [[c >> 1 if c & 1 else None for c in row] for row in g]
                elif name.startswith('cloud'):   # 4 planes, then the mask (bit 4)
                    g = planar(h4, w, h, 5)
                    g = [[c & 15 if c & 16 else None for c in row] for row in g]
                else:
                    g = planar(h4, w, h, 4)
                out.append(g)
            setattr(self, name, out if frames > 1 else out[0])
        self.twinlake, self.twinlake_parts = self.twinlake_frames(h3)
        self.font = self.load_font(False)
        self.font_large = self.load_font(True)

    @staticmethod
    def picture(r, w, h):
        if r.d[r.p:r.p + 4] == b'IMP!':
            return planar(Reader(deplode_fimp(r)), w, h, 4)
        return planar(r, w, h, 4)

    @staticmethod
    def twinlake_frames(r):
        """The picture of Twinlake (256 x 177, colour 0 is black) and the 94 changes of its animation (x, y, rows)"""
        blocks = []
        while r.p < len(r.d):
            size = r.word()
            data = bytearray()
            while len(data) < size:
                head = r.byte()
                if head < 128:
                    data += r.bytes(head + 1)
                else:
                    data += bytes([r.byte()]) * (256 - head)
            if size:
                blocks.append(bytes(data))
                if r.p & 1:
                    r.p += 1
        assert len(blocks) == 95
        screen = bytearray(177 * 128)        # 4 planes of 32 bytes per line
        pictures = []
        for b in blocks:
            br = Reader(b)
            box = [256, 177, 0, 0]
            for y in range(177):
                head = br.long()
                if not head:
                    continue
                for n in range(32):
                    if head & (0x80000000 >> n):
                        box = [min(box[0], n * 8), min(box[1], y), max(box[2], n * 8 + 8), max(box[3], y + 1)]
                        for p in range(4):
                            screen[y * 128 + p * 32 + n] ^= br.byte()
            rows = planar(Reader(bytes(screen)), 256, 177, 4)
            pictures.append((box, rows))
        twinlake = pictures[0][1]
        parts = [(x0, y0, [row[x0:x1] for row in rows[y0:y1]]) for (x0, y0, x1, y1), rows in pictures[1:]]
        return twinlake, parts

    def load_font(self, large):
        w, h = (32, 22) if large else (16, 11)
        start = self.code.index(bytes([0x15, 0x11, 0x10, 0x13]) if large else bytes([0x0b, 0x09, 0x09, 0x0a]),
                                10000 if large else 17000)
        advance = self.code[start:start + 76]
        size = w * h // 8
        data = self.code[start + 76:start + 76 + 76 * size]
        glyphs = {}
        for i, g in enumerate(GLYPHS):
            if g == 0xff or i == 0:
                continue
            rows = []
            for y in range(h):
                v = int.from_bytes(data[g * size + y * w // 8:g * size + (y + 1) * w // 8], 'big')
                rows.append([bool(v >> (w - 1 - x) & 1) for x in range(w)])
            glyphs[chr(0x20 + i)] = (advance[g], rows)
        return glyphs


def rgb(c):
    return tuple(((c >> s) & 15) * 17 for s in (8, 4, 0))


def preview(rows, palette, path, offset=0):
    from PIL import Image
    img = Image.new('RGB', (len(rows[0]), len(rows)), (255, 0, 255))
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c is not None:
                img.putpixel((x, y), rgb(palette[c + offset]))
    img.save(path)


if __name__ == '__main__':
    I = Intro(sys.argv[1])
    out = sys.argv[2]
    os.makedirs(out, exist_ok=True)
    P = I.palettes
    preview(I.frame, P[4], os.path.join(out, 'frame.png'), 16)
    preview(I.menu_picture, P[6], os.path.join(out, 'menu.png'))
    for i, t in enumerate(I.towns):
        preview(t, P[4], os.path.join(out, 'town%d.png' % i))
    for name, p in (('thalion', 0), ('ambermoon', 1), ('lyramion', 3), ('morag', 3), ('forest_moon', 3), ('meteor', 3),
                    ('cloud_left', 4), ('cloud_right', 4)):
        preview(getattr(I, name), P[p], os.path.join(out, name + '.png'))
    preview(I.sun[0], P[3], os.path.join(out, 'sun0.png'))
    preview(I.sparks[10], P[3], os.path.join(out, 'sparks10.png'))
    preview(I.twinlake, P[4], os.path.join(out, 'twinlake.png'), 16)
    print(I.texts, I.menu)
    for c in I.commands[:30]:
        print(c)
    print(len(I.commands), 'commands', len(I.twinlake_parts), 'parts', sorted(I.font)[:10])
