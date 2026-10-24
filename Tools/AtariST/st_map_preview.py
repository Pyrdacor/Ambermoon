#!/usr/bin/env python3
# Preview of a 2D map of Ambermoon converted to 16 colours (Atari ST/STE).
#
# The map is rendered with its original 32 colour palette. Then a 16 colour palette is computed (weighted k-means
# over the 32 palette entries in Lab, weighted by how many pixels of the map use each entry) and every original palette
# index is mapped to one of the 16 colours (a lookup table 32 -> 16, so the tile graphics only lose their 5th
# bitplane after remapping). Optionally indices which have no good match are dithered with a 4x4 Bayer matrix
# (tile aligned, so it stays stable while scrolling).
#
#   python3 st_map_preview.py <map index> [options]
#
# Output: a PNG with original | 16 colours | 16 colours dithered and the palettes below, and a short report
# (palette in ST format, lookup table, error) on stdout.
#
# The game data is read from ExtractedGameFiles.zip in the repository root (or --data <zip or folder>).
import argparse, math, os, struct, zipfile
from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

class Data:
    def __init__(self, path):
        self.zip = zipfile.ZipFile(path) if os.path.isfile(path) else None
        self.path = path
        names = self.zip.namelist() if self.zip else [
            os.path.relpath(os.path.join(d, f), path).replace(os.sep, '/')
            for d, _, fs in os.walk(path) for f in fs]
        self.names = set(names)

    def read(self, name):
        if self.zip:
            return self.zip.read(name)
        with open(os.path.join(self.path, name), 'rb') as f:
            return f.read()

    def find_map(self, index):
        for c in '123':
            name = f'{c}Map_data.amb/{index:03}'
            if name in self.names:
                return self.read(name)
        raise SystemExit(f'Map {index} not found')

    def all_maps(self):
        for name in sorted(self.names):
            if len(name) > 13 and name[1:13] == 'Map_data.amb' and name[-1] != '/':
                yield int(name[-3:]), self.read(name)

    def tileset_gfx(self, tileset):
        for c in '123':
            name = f'{c}Icon_gfx.amb/{tileset:03}'
            if name in self.names:
                return self.read(name)
        raise SystemExit(f'Icon graphics {tileset} not found')

def planar(data, w, h, bpp, off=0):
    """Planar graphic (per row: bpp planes with w bits each) -> list of palette indices."""
    rb = w // 8
    pix = []
    for y in range(h):
        base = off + y * rb * bpp
        planes = [int.from_bytes(data[base + p * rb:base + (p + 1) * rb], 'big') for p in range(bpp)]
        for x in range(w - 1, -1, -1):
            v = 0
            for p in range(bpp):
                v |= ((planes[p] >> x) & 1) << p
            pix.append(v)
    return pix

def amiga_rgb(c):
    return tuple(((c >> s) & 0xf) * 17 for s in (8, 4, 0))

# ---- colour metric: CIE Lab (D65), so the clustering follows perceived differences ----
def to_lab(rgb):
    def lin(v):
        v /= 255
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = map(lin, rgb)
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    f = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(x), f(y), f(z)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))

def dist(a, b):
    return math.sqrt(sum((p - q) ** 2 for p, q in zip(a, b)))

def snap(rgb, bits):
    """Nearest colour (in Lab) on the colour grid of the target (3 bits per channel = ST, 4 bits = STE).
    Rounding each channel on its own is clearly worse for dark colours on the coarse ST grid."""
    m = (1 << bits) - 1
    lab = to_lab(rgb)
    options = [sorted({math.floor(v * m / 255), math.ceil(v * m / 255)}) for v in rgb]
    best = min(((r, g, b) for r in options[0] for g in options[1] for b in options[2]),
               key=lambda q: dist(lab, to_lab(tuple(round(v * 255 / m) for v in q))))
    return tuple(round(v * 255 / m) for v in best)

def st_word(rgb, bits):
    """Colour register value. STE: the 4th bit is the LSB stored in bit 3 of each nibble."""
    m = (1 << bits) - 1
    out = 0
    for v in rgb:
        q = round(v * m / 255)
        n = ((q >> 1) | ((q & 1) << 3)) if bits == 4 else q
        out = (out << 4) | n
    return out

def kmeans(points, weights, fixed, k, bits):
    """Weighted k-means in Lab. points: list of rgb; fixed: rgb colours which are part of the result.
    Returns k rgb colours on the target grid."""
    labs = [to_lab(p) for p in points]
    free = k - len(fixed)
    best = None
    # deterministic seeds: k-means++ style, starting from each of the most used colours
    order = sorted(range(len(points)), key=lambda i: -weights[i])
    for start in order[:8]:
        centres = [to_lab(c) for c in fixed]
        seeds = [labs[start]] if free > 0 else []
        while len(seeds) < free:
            cand = max(range(len(points)), key=lambda i: weights[i] * min(
                dist(labs[i], c) for c in centres + seeds) ** 2)
            seeds.append(labs[cand])
        for _ in range(50):
            allc = centres + seeds
            groups = [[] for _ in allc]
            for i, l in enumerate(labs):
                if weights[i]:
                    groups[min(range(len(allc)), key=lambda j: dist(l, allc[j]))].append(i)
            new = []
            for j, g in enumerate(groups[len(centres):]):
                tw = sum(weights[i] for i in g)
                if tw == 0:
                    new.append(seeds[j])
                else:
                    new.append(tuple(sum(labs[i][d] * weights[i] for i in g) / tw for d in range(3)))
            if new == seeds:
                break
            seeds = new
        # back to rgb: use the weighted mean in rgb of each group, snapped to the target grid
        allc = centres + seeds
        groups = [[] for _ in allc]
        for i, l in enumerate(labs):
            groups[min(range(len(allc)), key=lambda j: dist(l, allc[j]))].append(i)
        result = [snap(c, bits) for c in fixed]
        for j, g in enumerate(groups[len(fixed):]):
            tw = sum(weights[i] for i in g)
            if tw == 0:
                result.append(result[0])
                continue
            mean = tuple(sum(points[i][d] * weights[i] for i in g) / tw for d in range(3))
            result.append(snap(mean, bits))
        err = sum(weights[i] * min(dist(labs[i], to_lab(c)) for c in result) for i in range(len(points)))
        if best is None or err < best[0]:
            best = (err, result)
    return best[1]

def main():
    ap = argparse.ArgumentParser(description='Preview of a 2D map of Ambermoon converted to 16 colours (Atari ST/STE).')
    ap.add_argument('map', type=int, help='map index (e.g. 258)')
    ap.add_argument('--data', default=os.path.join(ROOT, 'ExtractedGameFiles.zip'),
                    help='ExtractedGameFiles.zip or a folder with its contents (default: the zip in the repository root)')
    ap.add_argument('--bits', type=int, choices=(3, 4), default=3,
                    help='bits per colour channel: 3 = ST (512 colours, default), 4 = STE (4096 colours)')
    ap.add_argument('--colours', type=int, default=16, help='number of colours (default 16)')
    ap.add_argument('--reserve', default='0',
                    help='palette indices whose colour is kept unchanged, e.g. "0,24-31" to keep colour 0 and the '
                         'UI colours (default "0")')
    ap.add_argument('--scope', choices=('map', 'tileset'), default='map',
                    help='optimize the palette for this map only or for all maps with the same tileset and palette')
    ap.add_argument('--weight', choices=('pixels', 'sqrt'), default='sqrt',
                    help='weight of a colour for the palette: its pixel count, or the square root of it (default) '
                         'which keeps rare accent colours like fire better')
    ap.add_argument('--scale', type=int, default=2, help='zoom factor of the PNG (default 2)')
    ap.add_argument('--crop', help='only show a part of the map: x,y,w,h in tiles')
    ap.add_argument('-o', '--output', help='PNG file (default st_map_<index>.png)')
    args = ap.parse_args()

    data = Data(args.data)
    m = data.find_map(args.map)
    if m[2] != 2:
        raise SystemExit(f'Map {args.map} is a 3D map')
    W, H, tileset, pal_index = m[4], m[5], m[6], m[9]

    pd = data.read(f'Palettes.amb/{pal_index:03}')
    palette = [amiga_rgb(struct.unpack('>H', pd[i * 2:i * 2 + 2])[0] & 0xfff) for i in range(32)]

    gfx = data.tileset_gfx(tileset)
    tiles = [planar(gfx, 16, 16, 5, i * 160) for i in range(len(gfx) // 160)]
    idata = data.read(f'Icon_data.amb/{tileset:03}')
    icons = [struct.unpack('>IHBB', idata[2 + i * 8:10 + i * 8])
             for i in range(struct.unpack('>H', idata[:2])[0])]

    def render(mapdata, w, h):
        """Map -> list of palette indices (w*16 x h*16), first animation frame, overlay over underlay."""
        out = [0] * (w * 16 * h * 16)
        for ty in range(h):
            for tx in range(w):
                o = 0x14c + (ty * w + tx) * 4
                for layer, ti in enumerate((mapdata[o], mapdata[o + 2] << 8 | mapdata[o + 3])):
                    if ti == 0 or ti > len(icons) or icons[ti - 1][1] - 1 >= len(tiles):
                        continue
                    tile = tiles[icons[ti - 1][1] - 1]
                    for y in range(16):
                        row = (ty * 16 + y) * w * 16 + tx * 16
                        for x in range(16):
                            v = tile[y * 16 + x]
                            if layer == 0 or v:
                                out[row + x] = v
        return out

    pix = render(m, W, H)

    # pixel weights per palette index
    weights = [0] * 32
    if args.scope == 'map':
        for v in pix:
            weights[v] += 1
    else:
        n = 0
        for _, md in data.all_maps():
            if md[2] == 2 and md[6] == tileset and md[9] == pal_index:
                for v in render(md, md[4], md[5]):
                    weights[v] += 1
                n += 1
        print(f'Palette optimized for {n} maps with tileset {tileset} and palette {pal_index}')

    reserved = []
    for part in args.reserve.split(','):
        if part:
            a, _, b = part.partition('-')
            reserved += range(int(a), int(b or a) + 1)
    fixed = []
    for i in reserved:
        c = snap(palette[i], args.bits)
        if c not in fixed:
            fixed.append(c)
    if len(fixed) > args.colours:
        raise SystemExit('More reserved colours than colours')

    kweights = weights if args.weight == 'pixels' else [math.sqrt(w) for w in weights]
    new_pal = kmeans(palette, kweights, fixed, args.colours, args.bits)
    new_labs = [to_lab(c) for c in new_pal]
    labs = [to_lab(c) for c in palette]

    # lookup table: original index -> new index (nearest colour); reserved indices keep their own colour
    lut = []
    for i in range(32):
        if i in reserved:
            lut.append(new_pal.index(snap(palette[i], args.bits)))
        else:
            lut.append(min(range(len(new_pal)), key=lambda j: dist(labs[i], new_labs[j])))

    # dither table: original index -> (a, b, threshold 0..16); b is used where bayer < threshold
    bayer = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
    dith = []
    for i in range(32):
        a = lut[i]
        best = (dist(labs[i], new_labs[a]), a, a, 0)
        if i not in reserved and best[0] > 4:
            for p in range(len(new_pal)):
                for q in range(len(new_pal)):
                    # only mix similar colours, otherwise the pattern becomes noise
                    if p == q or dist(new_labs[p], new_labs[q]) > 30:
                        continue
                    for t in range(1, 16):
                        mix = tuple((new_pal[p][d] * (16 - t) + new_pal[q][d] * t) / 16 for d in range(3))
                        e = dist(labs[i], to_lab(mix))
                        if e < best[0] * 0.7:
                            best = (e, p, q, t)
        dith.append(best[1:])

    # ---- output image ----
    x0, y0, cw, ch = 0, 0, W, H
    if args.crop:
        x0, y0, cw, ch = map(int, args.crop.split(','))
    pw, ph = cw * 16, ch * 16

    def image(colour_of):
        img = Image.new('RGB', (pw, ph))
        px = img.load()
        for y in range(ph):
            for x in range(pw):
                X, Y = x0 * 16 + x, y0 * 16 + y
                px[x, y] = colour_of(pix[Y * W * 16 + X], X, Y)
        return img

    def dithered(v, x, y):
        a, b, t = dith[v]
        return new_pal[b] if bayer[y & 3][x & 3] < t else new_pal[a]

    imgs = [image(lambda v, x, y: palette[v]),
            image(lambda v, x, y: new_pal[lut[v]]),
            image(dithered)]
    titles = ['Original (32 colours, Amiga)', f'{args.colours} colours ({"ST" if args.bits == 3 else "STE"})',
              f'{args.colours} colours, dithered']
    s = args.scale
    gap, sw, label = 8, 12, 14
    out = Image.new('RGB', (3 * pw * s + 2 * gap, label + ph * s + gap + 2 * sw + 4), (40, 40, 40))
    d = ImageDraw.Draw(out)
    for n, img in enumerate(imgs):
        x = n * (pw * s + gap)
        d.text((x + 2, 1), titles[n], fill=(230, 230, 230))
        out.paste(img.resize((pw * s, ph * s), Image.NEAREST), (x, label))
    y = label + ph * s + gap
    for i, c in enumerate(palette):
        d.rectangle([i * sw, y, i * sw + sw - 2, y + sw - 2], fill=c)
    for i, c in enumerate(new_pal):
        d.rectangle([pw * s + gap + i * sw, y, pw * s + gap + i * sw + sw - 2, y + sw - 2], fill=c)
    for i in range(32):  # which new colour each original index became
        d.rectangle([i * sw, y + sw + 2, i * sw + sw - 2, y + 2 * sw], fill=new_pal[lut[i]])
    path = args.output or f'st_map_{args.map}.png'
    out.save(path)

    # ---- report ----
    total = sum(weights)
    err = sum(weights[i] * dist(labs[i], new_labs[lut[i]]) for i in range(32)) / total
    used = sum(1 for w in weights if w)
    where = 'this map' if args.scope == 'map' else 'all maps of the tileset'
    print(f'Map {args.map}: {W}x{H} tiles, tileset {tileset}, palette {pal_index}, {used} of 32 indices used in {where}')
    print(f'Mean colour error in {where} (Lab, weighted by pixels): {err:.1f}   (< 2.3 is hardly visible, > 10 clearly)')
    print('New palette (' + ('ST' if args.bits == 3 else 'STE') + ' colour registers):')
    print('  ' + ' '.join(f'${st_word(c, args.bits):03x}' for c in new_pal))
    print('Lookup table original index -> new index (pixel share, error):')
    for i in range(32):
        if weights[i]:
            a, b, t = dith[i]
            dt = f'  dither {a}/{b} {t}/16' if t else ''
            print(f'  {i:2} -> {lut[i]:2}  {100 * weights[i] / total:5.1f}%  {dist(labs[i], new_labs[lut[i]]):5.1f}{dt}')
    print(f'Written {path}')

if __name__ == '__main__':
    main()
