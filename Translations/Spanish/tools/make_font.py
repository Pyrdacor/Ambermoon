#!/usr/bin/env python3
"""Builds the Spanish intro/extro font (font.json, SmallGlyphs.png, LargeGlyphs.png) for ISO-8859-1.

The glyphs come from the Czech font (Translations/Czech). Ñ ñ Ü ü ¿ ¡ are derived from existing glyphs:
a tilde or diaeresis replaces the caron/ring of Ň ň Ů ů, and ¿ ¡ are ? ! turned upside down."""
import json, os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
CZ = os.path.normpath(os.path.join(HERE, '..', '..', 'Czech'))
OUT = os.path.normpath(os.path.join(HERE, '..'))

src = json.load(open(os.path.join(CZ, 'font.json')))
cz_glyph = {}
for i, g in enumerate(src['glyphMapping']):
    if g != 255:
        ch = bytes([i + 32]).decode('cp852')
        cz_glyph.setdefault(ch, g)

sheets = {'small': (Image.open(os.path.join(CZ, 'SmallGlyphs.png')).convert('RGBA'), 16, src['smallGlyphHeight']),
          'large': (Image.open(os.path.join(CZ, 'LargeGlyphs.png')).convert('RGBA'), 32, src['largeGlyphHeight'])}


def cut(kind, g):
    im, w, h = sheets[kind]
    x, y = (g % 16) * w, (g // 16) * h
    return im.crop((x, y, x + w, y + h))


def clear_rows(img, rows):
    for r in rows:
        for c in range(img.width):
            img.putpixel((c, r), (0, 0, 0, 0))


def draw(img, pattern, top, left, sx, sy=None):
    sy = sx if sy is None else sy
    for r, line in enumerate(pattern):
        for c, ch in enumerate(line):
            if ch == '#':
                for dy in range(sy):
                    for dx in range(sx):
                        img.putpixel((left + c * sx + dx, top + r * sy + dy), (255, 255, 255, 255))


def bbox_rows(img):
    rows = [r for r in range(img.height) if any(img.getpixel((c, r))[3] for c in range(img.width))]
    return rows[0], rows[-1]


def upside_down(img):
    top, bottom = bbox_rows(img)
    cols = [c for c in range(img.width) if any(img.getpixel((c, r))[3] for r in range(img.height))]
    left, right = cols[0], cols[-1]
    part = img.crop((left, top, right + 1, bottom + 1)).rotate(180)
    out = Image.new('RGBA', img.size, (0, 0, 0, 0))
    out.paste(part, (left, top))
    return out


TILDE = ['.##.#', '#.##.']
DIAER = ['#..#']


def derived(kind):
    small = kind == 'small'
    s = 1 if small else 2
    res = {}
    # ñ: ň with a tilde instead of the caron
    g = cut(kind, cz_glyph['ň']); clear_rows(g, range(0, 4 if small else 7))
    draw(g, TILDE, 1 if small else 4, 0 if small else 1, s, 1); res['ñ'] = g
    # Ñ: Ň with a tilde instead of the caron (the letter starts in row 2)
    g = cut(kind, cz_glyph['Ň']); clear_rows(g, range(0, 2))
    draw(g, TILDE, 0, 2 if small else 4, s, 1); res['Ñ'] = g
    # ü: ů with a diaeresis instead of the ring
    g = cut(kind, cz_glyph['ů']); clear_rows(g, range(0, 4 if small else 7))
    draw(g, DIAER, 2 if small else 4, 1 if small else 2, s); res['ü'] = g
    # Ü: Ů with a diaeresis; the first row of the letter comes from U (the ring overlaps it in Ů)
    first = 2 if small else 3
    g = cut(kind, cz_glyph['Ů']); u = cut(kind, cz_glyph['U'])
    clear_rows(g, range(0, first + 1))
    for c in range(g.width):
        g.putpixel((c, first), u.getpixel((c, 0)))
    draw(g, DIAER, 0, 2 if small else 4, s, 1); res['Ü'] = g
    # ": the Czech font has none; two apostrophes
    a = cut(kind, cz_glyph["'"])
    cols = [c for c in range(a.width) if any(a.getpixel((c, r))[3] for r in range(a.height))]
    w = cols[-1] - cols[0] + 1
    g = Image.new('RGBA', a.size, (0, 0, 0, 0))
    part = a.crop((cols[0], 0, cols[-1] + 1, a.height))
    g.paste(part, (cols[0], 0)); g.paste(part, (cols[0] + w + s, 0), part); res['"'] = g
    res['¿'] = upside_down(cut(kind, cz_glyph['?']))
    res['¡'] = upside_down(cut(kind, cz_glyph['!']))
    return res


chars = [chr(c) for c in range(0x21, 0x7F)] + list('ÁÉÍÓÚáéíóú') + list('ÑñÜü¿¡')
NEW = 'ÑñÜü¿¡"'
reserved = set('$~<>^')
glyph_chars = [c for c in chars if c not in reserved and (c in cz_glyph or c in NEW)]

new = {k: derived(k) for k in sheets}
order = []
images = {k: [] for k in sheets}
for c in glyph_chars:
    order.append(c)
    for k in sheets:
        images[k].append(new[k][c] if c in new[k] else cut(k, cz_glyph[c]))

# the Czech font draws ` and ´ with the apostrophe glyph
mapping = []
for b in range(0x20, 0x100):
    ch = bytes([b]).decode('latin-1')
    if ch in order:
        mapping.append(order.index(ch))
    elif ch in ('`', '´') and "'" in order:
        mapping.append(order.index("'"))
    else:
        mapping.append(255)

for k, (im, w, h) in sheets.items():
    rows = (len(order) + 15) // 16
    sheet = Image.new('RGBA', (16 * w, rows * h), (0, 0, 0, 0))
    for i, g in enumerate(images[k]):
        sheet.paste(g, ((i % 16) * w, (i // 16) * h))
    sheet.save(os.path.join(OUT, ('SmallGlyphs.png' if k == 'small' else 'LargeGlyphs.png')))

spec = dict(src)
spec['numGlyphs'] = len(order)
spec['glyphMapping'] = mapping
with open(os.path.join(OUT, 'font.json'), 'w') as f:
    json.dump(spec, f, indent=2)
print(len(order), 'glyphs')
