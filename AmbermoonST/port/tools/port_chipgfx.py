#!/usr/bin/env python3
"""Converts the 5-plane graphics of the program (KERNEL/CHIP_DATA.S) to the ST format (see port_gfx.py).

    port_chipgfx.py <CHIP_DATA.S of the build> <ST palettes json>

The data (dc.w lines) of these labels in the copy of the source in the build is replaced by the ST chunks; the
kernel draws all 5-plane graphics without conversion. Every block must have the size of its 5-plane graphics
(else it is not changed, with a message).
"""
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.dont_write_bytecode = True
sys.path.insert(0, HERE)
import port_gfx                            # noqa: E402
sc = port_gfx.sc

# label, frames, width, height, palette ('main' : Main_pal, n : Palettes.amb n)
GRAPHICS = [
    ('Status_icons', 23, 16, 16, 'main'),
    ('Damage_star', 1, 32, 26, 'main'),
    ('Magic_stars', 4, 16, 9, 'main'),
    ('Ankh_symbol', 1, 32, 29, 'main'),
    ('Giant_eagle_shape', 1, 32, 29, 1),     # (on the world maps : Lyramion)
]


def main():
    path, pals = sys.argv[1], port_gfx.Palettes(sys.argv[2])
    lines = open(path, encoding='latin-1').read().split('\n')
    import zipfile
    z = zipfile.ZipFile(os.path.join(sc.ROOT, 'Disks', 'German', 'ambermoon_german_1.20_extracted.zip'))
    palettes = {k: port_gfx.words(v) for k, v in
                port_gfx.read_container(z.read('Amberfiles/Palettes.amb')).items()}
    for label, frames, w, h, pal in GRAPHICS:
        start = next(i for i, l in enumerate(lines) if l.startswith(label + ':'))
        end = start + 1
        while end < len(lines) and not re.match(r'^[A-Za-z_][A-Za-z0-9_]*:', lines[end]):
            end += 1
        data = bytearray()
        for l in lines[start + 1:end]:
            m = re.match(r'\s+dcb\.([bwl])\s+([^,;]+),([^;]*)', l)
            if m:                         # dcb.x count,value
                size = {'b': 1, 'w': 2, 'l': 4}[m.group(1)]
                v = m.group(3).strip()
                data += (int(v[1:], 16) if v.startswith('$') else int(v)).to_bytes(size, 'big') * int(m.group(2))
                continue
            m = re.match(r'\s+dc\.([bwl])\s+([^;]*)', l)
            if not m:
                continue
            size = {'b': 1, 'w': 2, 'l': 4}[m.group(1)]
            for v in m.group(2).split(','):
                v = v.strip()
                data += (int(v[1:], 16) if v.startswith('$') else int(v)).to_bytes(size, 'big')
        if len(data) != frames * (w // 16) * 10 * h:
            print(f'{label}: {len(data)} bytes, not {frames} x {w}x{h} with 5 planes: not converted')
            continue
        lut = pals.lut(sc.source_words('KERNEL/DATA.S', 'Main_pal', 32) if pal == 'main' else palettes[pal])
        st = port_gfx.st_chunks(bytes(data), w, h, lut, frames)
        out = [lines[start]] + ['\tdc.w\t' + ','.join('$%04x' % struct.unpack('>H', st[i + j:i + j + 2])[0]
                                                       for j in range(0, min(16, len(st) - i), 2))
                                for i in range(0, len(st), 16)]
        lines[start:end] = out
    open(path, 'w', encoding='latin-1', newline='\n').write('\n'.join(lines))


if __name__ == '__main__':
    main()
