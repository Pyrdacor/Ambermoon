#!/usr/bin/env python3
"""The data of the fairy of Thalion (the first data hunk of Fantasy_intro) with 16 colours for the ST (see
port/KERNEL/FANTASY_HW.S). Used by intro_data.py.

The Amiga shows the picture with 32 colours, from line 134 on the copper changes 7 of them (20-23, 29-31 : the
lettering is there), the fairy is made of sprites with the colours 16-31. The ST shows the lines above 134 and the
lines from there on with their own 16 colours (a raster interrupt). The graphics get the ST colour numbers in their
planes 0-3 (plane 4 is empty), so the code of the Amiga draws them as before :
  - the picture ($d38c, 256 lines, 5 planes, 40 bytes per plane) : the upper colours above line 134, the lower ones
    from there on,
  - the lower part of the picture with the lettering ($13c3c, 122 lines, copied into the screen in every frame),
    the lettering ($1a3fc, 83 lines, 26 bytes per plane), the 12 sparkles ($19b8c, 45 rows of a data word and a
    mask word : 9 lines of 5 planes) : the lower colours,
  - the fairy (23 frames of 8 sprites from $1ac, 71 lines) : the pairs of sprites get the ST colour of the upper
    colours; a copy with the lower ones follows the data ([ Fairy_lower ]). Her ST colours are never 0 (transparent).
  - the palettes ($40 the upper one, $0 the lower one) : the 16 ST colours, the code fades them as before.
  - the dust of the fairy is drawn by the code, a routine for each colour : a table colour -> ST colour follows
    the copy of the fairy ([ Fairy_dust ], 32 bytes). The Amiga colours 0-19 are the same in both palettes : they
    get ST colours which are the same in both (the dust is in both parts).
The ST colours : 0 is black; the colours 0-19 (both parts) get the shared slots, the colours 20-31 of each part
their own slots, each by a weighted k-means over the counts of the pixels (the fairy counts more : she is small;
the colours of the dust are not in the graphics, they get a weight of their own).
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'Tools', 'AtariST'))
from st_map_preview import amiga_rgb, kmeans, to_lab, dist  # noqa: E402

PICTURE, LOWER, LETTERS, SPARKLES, FAIRY = 0xd38c, 0x13c3c, 0x1a3fc, 0x19b8c, 0x1ac
UPPER_PAL, LOWER_PAL = 0x40, 0x0
SPLIT = 134
FRAMES, SPRITE, FRAME, FAIRY_LINES = 23, 0x124, 0x920, 71
SHARED = 9                  # slots for the colours 0-19 (with black), the rest for each part
FAIRY_WEIGHT = 8
DUST, DUST_WEIGHT = range(9, 15), 1200   # the colours of the dust of the fairy (F0074e)


def planar(d, off, bpl, planes, lines):
    """Line interleaved planes -> rows of colour numbers"""
    rows = []
    for y in range(lines):
        p = [int.from_bytes(d[off + (y * planes + i) * bpl:off + (y * planes + i + 1) * bpl], 'big')
             for i in range(planes)]
        n = bpl * 8
        rows.append([sum(((p[i] >> (n - 1 - x)) & 1) << i for i in range(planes)) for x in range(n)])
    return rows


def put_planar(d, off, bpl, planes, rows):
    for y, row in enumerate(rows):
        n = bpl * 8
        for i in range(planes):
            v = 0
            for x, c in enumerate(row):
                v |= ((c >> i) & 1) << (n - 1 - x)
            d[off + (y * planes + i) * bpl:off + (y * planes + i + 1) * bpl] = v.to_bytes(bpl, 'big')


def sparkles(d):
    """The 12 sparkles : [(rows of the data words, rows of the mask words)], a row is a line of 5 planes"""
    out = []
    for s in range(12):
        o = SPARKLES + s * 180
        data = [[struct.unpack_from('>H', d, o + (y * 5 + p) * 4)[0] for p in range(5)] for y in range(9)]
        out.append(data)
    return out


def sparkle_pixels(words):
    return [[sum(((words[y][p] >> (15 - x)) & 1) << p for p in range(5)) for x in range(16)] for y in range(9)]


def fairy(d, base):
    """The frames : [[rows of 64 values 0-15]]"""
    frames = []
    for f in range(FRAMES):
        rows = [[0] * 64 for _ in range(FAIRY_LINES)]
        for pair in range(4):
            a = base + f * FRAME + 2 * pair * SPRITE + 4
            b = a + SPRITE
            for y in range(FAIRY_LINES):
                w = struct.unpack_from('>4H', d, a + 4 * y)[:2] + struct.unpack_from('>2H', d, b + 4 * y)
                for x in range(16):
                    rows[y][pair * 16 + x] = sum(((w[i] >> (15 - x)) & 1) << i for i in range(4))
        frames.append(rows)
    return frames


def put_fairy(d, base, frames):
    for f, rows in enumerate(frames):
        for pair in range(4):
            a = base + f * FRAME + 2 * pair * SPRITE + 4
            b = a + SPRITE
            for y in range(FAIRY_LINES):
                w = [0, 0, 0, 0]
                for x in range(16):
                    for i in range(4):
                        w[i] |= ((rows[y][pair * 16 + x] >> i) & 1) << (15 - x)
                struct.pack_into('>2H', d, a + 4 * y, w[0], w[1])
                struct.pack_into('>2H', d, b + 4 * y, w[2], w[3])


def palette(d, off):
    return [amiga_rgb(w) for w in struct.unpack_from('>32H', d, off)]


def nearest(rgb, pal, slots):
    lab = to_lab(rgb)
    return min(slots, key=lambda j: dist(lab, to_lab(pal[j])))


def convert(data):
    """The data with the ST colours (bytes), the size of the original data (the copy of the fairy and the table of
    the dust follow it)"""
    d = bytearray(data)
    up, lo = palette(d, UPPER_PAL), palette(d, LOWER_PAL)
    pic = planar(d, PICTURE, 40, 5, 256)
    low = planar(d, LOWER, 40, 5, 122)
    let = planar(d, LETTERS, 26, 5, 83)
    spk = [sparkle_pixels(s) for s in sparkles(d)]
    spk_masks = sparkle_masks(d)
    fai = fairy(d, FAIRY)
    # the counts : colours 0-19 (both parts), 20-31 of each part
    cu, cl = [0] * 32, [0] * 32
    for y, row in enumerate(pic):
        for c in row:
            (cu if y < SPLIT else cl)[c] += 1
    for rows in (low, let) + tuple(spk):
        for row in rows:
            for c in row:
                cl[c] += 1
    for rows in fai:
        for row in rows:
            for v in row:
                if v:
                    cu[16 + v] += FAIRY_WEIGHT / FRAMES
                    cl[16 + v] += FAIRY_WEIGHT / FRAMES
    for c in DUST:                  # (drawn by the code : in no graphic)
        cu[c] += DUST_WEIGHT
        cl[c] += DUST_WEIGHT
    shared = [up[c] for c in range(1, 20)]
    ws = [cu[c] + cl[c] for c in range(1, 20)]
    st_shared = kmeans(shared, ws, [(0, 0, 0)], SHARED, 4)
    pals = []
    for pal, counts in ((up, cu), (lo, cl)):
        own = [pal[c] for c in range(20, 32)]
        st = kmeans(own, [counts[c] for c in range(20, 32)], [], 16 - SHARED, 4)
        pals.append(st_shared + st)
    luts = []
    for pal, st in zip((up, lo), pals):
        lut = [0] * 32
        for c in range(1, 32):
            lut[c] = nearest(pal[c], st, range(SHARED) if c < 20 else range(16))
        luts.append(lut)
    lu, ll = luts
    # the fairy : never ST colour 0
    fairy_luts = []
    for pal, st in zip((up, lo), pals):
        fairy_luts.append([0] + [nearest(pal[16 + v], st, range(1, 16)) for v in range(1, 16)])
    # the graphics
    put_planar(d, PICTURE, 40, 5, [[(lu if y < SPLIT else ll)[c] for c in row] for y, row in enumerate(pic)])
    put_planar(d, LOWER, 40, 5, [[ll[c] for c in row] for row in low])
    put_planar(d, LETTERS, 26, 5, [[ll[c] for c in row] for row in let])
    for s, rows in enumerate(spk):
        o = SPARKLES + s * 180
        for y, row in enumerate(rows):
            for p in range(5):
                v = 0
                for x, c in enumerate(row):
                    v |= ((ll[c] >> p) & 1) << (15 - x)
                struct.pack_into('>H', d, o + (y * 5 + p) * 4, v)
    # the palettes
    for off, st in ((UPPER_PAL, pals[0]), (LOWER_PAL, pals[1])):
        words = [(r // 17) << 8 | (g // 17) << 4 | (b // 17) for r, g, b in st] + [0] * 16
        struct.pack_into('>32H', d, off, *words)
    # the data in the format of the ST screen (FANTASY_HW.S draws them as they are)
    dust = [lu[c] if c < 20 else 0 for c in range(32)]
    size = len(d)
    out, offsets = bytearray(d), {}

    def part(name, data):
        while len(out) & 3:
            out.append(0)
        offsets[name] = len(out)
        out.extend(data)
    part('Fst_picture', st_rows([[(lu if y < SPLIT else ll)[c] for c in row] for y, row in enumerate(pic)][TOP:TOP + 200]))
    part('Fst_lower', st_rows([[ll[c] for c in row] for row in low][:TOP + 200 - SPLIT]))
    part('Fst_letters', st_rows([[ll[c] for c in row] for row in let]))
    part('Fst_sparkles', b''.join(shifted([[ll[c] for c in row] for row in rows], [[c != 0 or m for c, m in zip(row, mrow)]
                                  for row, mrow in zip(rows, masks)]) for rows, masks in zip(spk, spk_masks)))
    small = [[[dust[c] for c in row] for row in sparkle_pixels_or(d, o)] for o in SMALL]
    part('Fst_small', b''.join(shifted(rows, [[c != 0 for c in row] for row in rows]) for rows in small))
    part('Fst_fairy', b''.join(st_sprite([[fairy_luts[v][c] for c in row] for row in rows]) for rows in fai for v in (0, 1)))
    part('Fairy_dust', bytes(dust))
    return bytes(out), size, offsets


TOP = 21                    # the first line which the ST shows (FANTASY_HW.S, Fantasy_top)
SMALL = (0x80, 0xe4, 0x148)  # the small sparkles at the end of the dust (5 lines of 5 planes, data and mask)


def st_rows(rows):
    """Rows of ST colours (320 pixels) -> ST screen lines"""
    out = bytearray()
    for row in rows:
        for x0 in range(0, len(row), 16):
            for p in range(4):
                v = 0
                for x in range(16):
                    v |= ((row[x0 + x] >> p) & 1) << (15 - x)
                out += struct.pack('>H', v)
    return bytes(out)


def st_sprite(rows):
    """Rows of ST colours (0 transparent), 16 pixels per chunk -> per chunk the mask and the 4 planes"""
    out = bytearray()
    for row in rows:
        for x0 in range(0, len(row), 16):
            words = [0] * 5
            for x in range(16):
                c = row[x0 + x]
                if c:
                    words[0] |= 1 << (15 - x)
                for p in range(4):
                    words[1 + p] |= ((c >> p) & 1) << (15 - x)
            out += struct.pack('>5H', *words)
    return bytes(out)


def shifted(rows, masks):
    """16 pixels wide graphic : for each shift 0-15 the lines of two chunks, each the inverted mask twice and the 4
    planes (long words : two planes at once)"""
    out = bytearray()
    for sh in range(16):
        for row, mrow in zip(rows, masks):
            words = [0] * 10
            for x in range(16):
                b = 31 - x - sh
                if mrow[x]:
                    words[0 if b >= 16 else 5] |= 1 << (b & 15)
                for p in range(4):
                    if (row[x] >> p) & 1:
                        words[(0 if b >= 16 else 5) + 1 + p] |= 1 << (b & 15)
            for c in (0, 5):
                m = words[c] ^ 0xffff
                out += struct.pack('>6H', m, m, *words[c + 1:c + 5])
    return bytes(out)


def sparkle_masks(d):
    """The masks of the 12 sparkles (the same in all planes) : rows of 16 flags"""
    out = []
    for s in range(12):
        o = SPARKLES + s * 180
        out.append([[bool((struct.unpack_from('>H', d, o + (y * 5) * 4 + 2)[0] >> (15 - x)) & 1) for x in range(16)]
                    for y in range(9)])
    return out


def sparkle_pixels_or(d, o):
    """A small sparkle : 5 lines, the data words of the 5 planes"""
    return [[sum(((struct.unpack_from('>H', d, o + (y * 5 + p) * 4)[0] >> (15 - x)) & 1) << p for p in range(5))
             for x in range(16)] for y in range(5)]


if __name__ == '__main__':          # a preview : fantasy_st.py <Fantasy_intro> <out.png>
    from PIL import Image
    sys.path.insert(0, HERE)
    from hunks import deplode, hunks
    data = deplode(hunks(sys.argv[1]))[1]['data']
    st, size, offsets = convert(data)
    img = Image.new('RGB', (640, 256))
    for half, (d, off) in enumerate(((data, 0), (st, 0))):
        pic = planar(d, PICTURE, 40, 5, 256)
        up, lo = palette(d, UPPER_PAL), palette(d, LOWER_PAL)
        for y, row in enumerate(pic):
            for x, c in enumerate(row):
                img.putpixel((half * 320 + x, y), (up if y < SPLIT else lo)[c])
    img.save(sys.argv[2])
