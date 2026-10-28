#!/usr/bin/env python3
"""Makes the static ST palettes of the port (see PORT.md, port/KERNEL/COLOURS.S).

    port_palettes.py <include file>

Every Amiga palette of the game (32 colours) gets a 16 colour ST palette, made in advance : ST colour 0 is
black, the UI colours (Amiga 25-31, also the colours of the mouse pointer) get 5 fixed ST colours, the other 10
(1-8, 13, 15) are chosen by a weighted k-means. The weights are the colour counts of the graphics which are
shown with the palette (tiles of the maps, portraits, items), or equal.

UI colours (the 6 shades of the window frames are merged to 4, see port/GRAPHICS.md) :
    Amiga 25 -> ST 9, 26 -> 10, 27 -> 11, 28 and 29 -> 12, 30 and 31 -> 14
With this layout the 3 planes a0-a2 of a UI graphic (base colour 24) become the ST planes p0 = a0 & ~a2,
p1 = a1, p2 = a2, p3 = a0 | a1 | a2 (the kernel draws them without a lookup table).

The include file contains per palette : the 32 Amiga colours (dc.w), the 16 STE colours (dc.w) and the lookup
table Amiga colour -> ST colour (32 bytes); the end is marked with -1. The ST kernel finds the ST palette by
the colours of the Amiga palette ([ Find_ST_palette ]).
"""
import math
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(HERE, '..', '..', 'tools'))
import st_convert as sc                   # noqa: E402
from st_convert import planar, amiga_rgb, st_word, source_words  # noqa: E402
from st_convert import kmeans, snap, to_lab, dist  # noqa: E402

UI_SLOTS = {25: 9, 26: 10, 27: 11, 28: 12, 29: 12, 30: 14, 31: 14}   # Amiga UI colour -> ST colour
CONTENT_SLOTS = [1, 2, 3, 4, 5, 6, 7, 8, 13, 15]                     # chosen per palette


def make_port_palette(palette, weights, fixed=()):
    """16 colour ST palette with the slot layout above. palette: 32 rgb, weights: 32 values; fixed: colours
    which get the first content slots (e.g. white for the texts). Returns (16 rgb, lookup table of 32 slots)."""
    def mean(colours):
        return tuple(sum(palette[c][i] for c in colours) / len(colours) for i in range(3))
    ui = {slot: snap(mean([c for c in UI_SLOTS if UI_SLOTS[c] == slot]), 4) for slot in sorted(set(UI_SLOTS.values()))}
    fix = [snap(palette[c], 4) for c in fixed]
    points = [palette[i] for i in range(1, 25) if i not in fixed]
    w = [math.sqrt(weights[i]) for i in range(1, 25) if i not in fixed]
    result = kmeans(points, w, fix + list(ui.values()), 15, 4)
    content = fix + result[len(fix) + len(ui):]
    pal16 = [snap(palette[0], 4)] * 16
    for slot, colour in zip(CONTENT_SLOTS, content):
        pal16[slot] = colour
    for slot, colour in ui.items():
        pal16[slot] = colour
    labs = [to_lab(c) for c in pal16]
    lut = []
    for i in range(32):
        if i == 0:
            lut.append(0)
        elif i in UI_SLOTS:
            lut.append(UI_SLOTS[i])
        elif i in fixed:
            lut.append(CONTENT_SLOTS[fixed.index(i)])
        else:            # never slot 0: it is transparent
            li = to_lab(palette[i])
            lut.append(min(range(1, 16), key=lambda j: dist(li, labs[j])))
    return pal16, lut


def words(raw):
    return [struct.unpack('>H', raw[i * 2:i * 2 + 2])[0] & 0xfff for i in range(32)]


def main():
    out = sys.argv[1]
    data = sc.Data(os.path.join(sc.ROOT, 'ExtractedGameFiles.zip'))
    palettes = []                         # (32 Amiga words, weights, fixed colours)

    def add(colours, weights=None, fixed=()):
        """Adds a palette, or the weights to a palette which is there already."""
        weights = weights or [1] * 32
        for p in palettes:
            if p[0] == colours:
                for i in range(32):
                    p[1][i] += weights[i]
                return
        palettes.append((colours, list(weights), fixed))

    # ---------- UI palettes ----------
    main_pal = sc.source_words('KERNEL/DATA.S', 'Main_pal', 32)
    weights = [0] * 32
    portraits = [planar(data.read(n), 32, 34, 5) for n in sorted(data.names)
                 if n.startswith('Portraits.amb/') and n[-1] != '/']
    for p in portraits:
        for v in p:
            weights[v] += 6 / len(portraits)
    raw = data.read('Object_icons/001')
    for i in range(len(raw) // 160):
        for v in planar(raw, 16, 16, 5, i * 160):
            weights[v] += 1
    for c in (2, 16, 6, 7, 22, 23, 24):       # white, yellow, the bars
        weights[c] += 2000
    add(main_pal, weights, fixed=(2,))     # white : the texts
    tactic_pal = sc.source_words('KERNEL/DATA.S', 'Tactic_pal', 32)
    add(sc.source_words('KERNEL/DATA.S', 'Automap_pal', 32))
    add(tactic_pal)
    # ---------- palettes of Palettes.amb (maps, pictures, combat backgrounds) ----------
    maps = []
    for name in sorted(data.names):
        if name[1:13] == 'Map_data.amb' and name[-1] != '/':
            maps.append(data.read(name))
    pal_names = sorted(n for n in data.names if n.startswith('Palettes.amb/') and n[-1] != '/')
    for n in pal_names:
        index = int(n[-3:])
        colours = words(data.read(n))
        weights = [1] * 32
        for md in maps:                   # tiles of the 2D maps with this palette
            if md[2] == 2 and md[9] == index:
                try:
                    gfx = data.find('Icon_gfx.amb', md[6])
                except SystemExit:
                    continue
                for i in range(len(gfx) // 160):
                    for v in planar(gfx, 16, 16, 5, i * 160):
                        weights[v] += 0.05
        add(colours, weights)
        # in the combat screen the last 6 colours come from the tactic palette (Set_layout_colours)
        add(colours[:26] + tactic_pal[26:], weights)
    # ---------- event pictures (Event_pix_palette_table, the 9th picture uses the palette of the others) ----------
    pal_table = list(sc.source_data('KERNEL/DATA.S', 'Event_pix_palette_table')) + [0x21]
    for i in range(9):
        name = f'Event_pix.amb/{i + 1:03}'
        if name not in data.names:
            continue
        weights = [0] * 32
        for v in planar(data.read(name), 320, 92, 5):
            weights[v] += 1
        add(words(data.read(f'Palettes.amb/{pal_table[i]:03}')), weights)
    # ---------- combat backgrounds : weighted into all palettes with the tactic colours (which background is
    # shown with which palette is a table in the code) ----------
    for n in sorted(x for x in data.names if x.startswith('Combat_background.amb/') and x[-1] != '/'):
        raw = data.read(n)
        pix = planar(raw[-320 * 95 * 5 // 8:], 320, 95, 5)   # (background 16 has 4 more bytes)
        weights = [0] * 32
        for v in pix:
            weights[v] += 1
        for p in palettes:
            if p[0][26:] == tactic_pal[26:] and p[0] != tactic_pal:
                for i in range(32):
                    p[1][i] += weights[i] / 20
    with open(out, 'w') as f:
        f.write('; Made by port/tools/port_palettes.py : Amiga palette (32 colours), ST palette (16 STE colours),\n')
        f.write('; lookup table Amiga colour -> ST colour, representative Amiga colour of every ST colour\n')
        f.write('ST_palettes:\n')
        for colours, weights, fixed in palettes:
            rgb = [amiga_rgb(c) for c in colours]
            pal16, lut = make_port_palette(rgb, weights, fixed=fixed)
            f.write('\tdc.w\t' + ','.join(f'${c:03x}' for c in colours) + '\n')
            f.write('\tdc.w\t' + ','.join(f'${st_word(c, 4):03x}' for c in pal16) + '\n')
            f.write('\tdc.b\t' + ','.join(str(v) for v in lut) + '\n')
            # representative Amiga colour of every ST colour (the fade of the Amiga colour is applied to it)
            labs = [sc.to_lab(c) for c in pal16]
            rep = []
            for j in range(16):
                members = [i for i in range(32) if lut[i] == j] or list(range(32))
                rep.append(min(members, key=lambda i: sc.dist(sc.to_lab(rgb[i]), labs[j])))
            f.write('\tdc.b\t' + ','.join(str(v) for v in rep) + '\n')
        f.write('\tdc.w\t-1\n')
    print(f'{len(palettes)} ST palettes')


if __name__ == '__main__':
    main()
