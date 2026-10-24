#!/usr/bin/env python3
# Converts the game data of Ambermoon for the Atari ST proof of concept.
#
#   python3 st_convert.py <output folder> [--map 257] [--data ExtractedGameFiles.zip]
#
# The ST shows 16 colours. The screen is split like on the Amiga (see the raster lists in MODULES.S):
#   lines 0..36   : status block (portraits) with the UI palette (Main_pal)
#   lines 37..199 : layout and map window with the map palette
# Both palettes use the same slot layout:
#   slot 0        : colour 0 (black, transparent for masked graphics)
#   slots 1..7    : 7 colours chosen by a weighted k-means for the graphics of the area (map tiles, portraits)
#   slots 8..15   : colours 24..31 (the UI colours: layouts, status block and all 3 bit graphics use them)
# So 3 bit graphics with base colour 24 look the same in both areas, and every Amiga colour of an area is
# translated with a lookup table of 32 bytes (written to the palette files, used by the kernel for Draw_box
# and the text colours).
#
# All graphics are converted to the ST format: per line and per 16 pixels 4 words (planes 0..3).
#
# Output files (all big endian):
#   UIPAL.BIN   16 STE colour words + 32 byte lookup table (Amiga colour -> slot), status block area
#   MAPPAL.BIN  the same for the map area
#   LAYOUT.BIN  layout 1 (2D map), 320x163
#   UIGFX.BIN   UI graphics of KERNEL/CHIP_DATA.S: Status_L, Status_M, Status_R (16x36 each),
#               Status_TB (32x1), Empty_portrait (32x34), Button_up, Button_down (32x17 each)
#   BUTTONS.BIN control icons of Button_graphics (78 x 32x13, colour 0 transparent)
#   MPTR.BIN    default mouse pointer (Default_Mptr of KERNEL/DATA.S): hotspot X, Y (words), 16x16
#   MAPNAME.BIN map name (0-terminated)
#   START.BIN   start position X, Y, view direction (words)
#   PORTR.BIN   6 portraits (32x34) of the party used by the proof of concept
#   NAMES.BIN   6 names (16 bytes each)
#   FONT.BIN    Glyph_mapping (224 bytes) + Glyph_data (5 bytes per glyph), unchanged
#   ICONS.BIN   all icon graphics of the tileset of the map (16x16 each)
#   ICONDAT.BIN icon data of the tileset (unchanged)
#   MAP.BIN     map data (unchanged)
#   PARTY.BIN   17 frames 16x32 of the party graphics of the world of the map
import argparse, math, os, re, struct, sys, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'Tools', 'AtariST'))
from st_map_preview import planar, amiga_rgb, kmeans, snap, st_word, to_lab, dist  # noqa: E402

SRC = os.path.join(ROOT, 'AmbermoonSource', 'src')
PARTY = (1, 8, 9, 10, 11, 12)               # Party_char.amb: hero, Egil, Selena, Nelvin, Sabine, Valdyn
AMBERFILES = os.path.join(ROOT, 'Disks', 'Bugfixing', 'German', 'Amberfiles')


class Data:
    def __init__(self, path):
        self.zip = zipfile.ZipFile(path)
        self.names = set(self.zip.namelist())

    def read(self, name):
        return self.zip.read(name)

    def find(self, container, index):
        for c in ('', '1', '2', '3'):
            name = f'{c}{container}/{index:03}'
            if name in self.names:
                return self.read(name)
        raise SystemExit(f'{container} {index} not found')

    def maps(self):
        for name in sorted(self.names):
            if name[1:13] == 'Map_data.amb' and name[-1] != '/':
                yield self.read(name)


def source_data(filename, label):
    """Bytes of a dc.b block of the original source, from the label to the next label."""
    out = bytearray()
    active = False
    for line in open(os.path.join(SRC, filename), encoding='latin-1'):
        if re.match(r'^[A-Za-z_][A-Za-z0-9_]*:', line):
            if active:
                break
            active = line.startswith(label + ':')
            continue
        if active:
            m = re.match(r'\s+dc\.b\s+([^;]*)', line)
            if m:
                for v in m.group(1).split(','):
                    v = v.strip()
                    out.append(int(v[1:], 16) if v.startswith('$') else int(v))
    return bytes(out)


def source_words(filename, label, count):
    words = []
    active = False
    for line in open(os.path.join(SRC, filename), encoding='latin-1'):
        if line.startswith(label + ':'):
            active = True
            continue
        if active:
            m = re.match(r'\s+dc\.w\s+([^;]*)', line)
            if m:
                for v in m.group(1).split(','):
                    v = v.strip()
                    words.append(int(v[1:], 16) if v.startswith('$') else int(v))
            if len(words) >= count:
                return words[:count]
    raise SystemExit(f'{label} not found')


def jh_decode(data, key):
    out = bytearray(data)
    for i in range(0, len(out) - 1, 2):
        w = (out[i] << 8 | out[i + 1]) ^ key
        out[i], out[i + 1] = w >> 8, w & 0xff
        key = ((key << 4) + key + 87) & 0xffff
    return bytes(out)


def lob_decode(data):
    size = int.from_bytes(data[4:8], 'big') & 0xffffff
    src = data[12:]
    out = bytearray()
    i = 0
    while len(out) < size:
        header = src[i]
        i += 1
        for _ in range(8):
            if header & 0x80 == 0:            # match
                length = (src[i] & 0x0f) + 3
                offset = ((src[i] << 4) & 0xff00) | src[i + 1]
                i += 2
                for _ in range(length):
                    out.append(out[-offset])
            else:
                out.append(src[i])
                i += 1
            if len(out) >= size:
                break
            header = (header << 1) & 0xff
    return bytes(out[:size])


def decode_file(data):
    if data[:2] == b'JH':
        data = jh_decode(data[4:], int.from_bytes(data[2:4], 'big') ^ 0x4a48)   # key is stored XOR 'JH'
    if data[1:4] == b'LOB' or data[:4] == b'VOL1':
        data = lob_decode(data)
    return data


def st_graphic(pix, w, h):
    """Pixel values (slots 0..15) -> ST format: per line, per 16 pixels 4 plane words."""
    out = bytearray()
    for y in range(h):
        for tx in range(0, w, 16):
            for p in range(4):
                v = 0
                for x in range(16):
                    if (pix[y * w + tx + x] >> p) & 1:
                        v |= 0x8000 >> x
                out += struct.pack('>H', v)
    return bytes(out)


def make_palette(palette, weights):
    """16 colour palette with the slot layout described above. palette: 32 rgb, weights: 32 values.
    Returns (16 rgb, lookup table of 32 slots)."""
    ui = palette[24:32]
    points = palette[1:24]
    w = [math.sqrt(x) for x in weights[1:24]]
    # k-means with the UI colours fixed: result = 8 UI colours + 7 free colours
    result = kmeans(points, w, ui, 15, 4)
    free = result[8:]
    pal16 = [snap(palette[0], 4)] + free + [snap(c, 4) for c in ui]
    labs = [to_lab(c) for c in pal16]
    lut = []
    for i in range(32):
        if i == 0:
            lut.append(0)
        elif i >= 24:
            lut.append(8 + i - 24)
        else:            # never slot 0: it is transparent
            li = to_lab(palette[i])
            lut.append(min(range(1, 16), key=lambda j: dist(li, labs[j])))
    return pal16, lut


def palette_file(pal16, lut):
    return b''.join(struct.pack('>H', st_word(c, 4)) for c in pal16) + bytes(lut)


def main():
    ap = argparse.ArgumentParser(description='Converts the game data for the Atari ST proof of concept.')
    ap.add_argument('out')
    ap.add_argument('--map', type=int, default=258)
    ap.add_argument('--pos', default='2,15,1', help='start position x,y,direction (default: start of the game)')
    ap.add_argument('--data', default=os.path.join(ROOT, 'ExtractedGameFiles.zip'))
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    data = Data(args.data)

    def write(name, content):
        with open(os.path.join(args.out, name), 'wb') as f:
            f.write(content)
        print(f'{name:12} {len(content):7} bytes')

    # ---------- map area ----------
    m = data.find('Map_data.amb', args.map)
    if m[2] != 2:
        raise SystemExit('Only 2D maps are supported')
    tileset, pal_index, world = m[6], m[9], m[10]
    pd = data.read(f'Palettes.amb/{pal_index:03}')
    map_pal = [amiga_rgb(struct.unpack('>H', pd[i * 2:i * 2 + 2])[0] & 0xfff) for i in range(32)]
    gfx = data.find('Icon_gfx.amb', tileset)
    tiles = [planar(gfx, 16, 16, 5, i * 160) for i in range(len(gfx) // 160)]
    idata = data.read(f'Icon_data.amb/{tileset:03}')
    icons = [struct.unpack('>IHBB', idata[2 + i * 8:10 + i * 8]) for i in range(struct.unpack('>H', idata[:2])[0])]
    party_gfx = data.read(f'Party_gfx.amb/{world + 1:03}')
    party = [planar(party_gfx, 16, 32, 5, i * 320) for i in range(len(party_gfx) // 320)]

    # weights: pixels of all maps with this tileset and palette (all animation frames) + party graphics
    weights = [0] * 32
    for md in data.maps():
        if md[2] != 2 or md[6] != tileset or md[9] != pal_index:
            continue
        for i in range(md[4] * md[5]):
            o = 0x14c + i * 4
            for ti in (md[o], md[o + 2] << 8 | md[o + 3]):
                if 0 < ti <= len(icons):
                    _, g, n, _ = icons[ti - 1]
                    for k in range(max(n, 1)):
                        if g - 1 + k < len(tiles):
                            for v in tiles[g - 1 + k]:
                                weights[v] += 1
    for frame in party:
        for v in frame:
            weights[v] += 16       # small but important
    map16, map_lut = make_palette(map_pal, weights)
    write('MAPPAL.BIN', palette_file(map16, map_lut))
    write('ICONS.BIN', b''.join(st_graphic([map_lut[v] for v in t], 16, 16) for t in tiles))
    write('ICONDAT.BIN', idata)
    write('MAP.BIN', m)
    write('PARTY.BIN', b''.join(st_graphic([map_lut[v] for v in f], 16, 32) for f in party))

    layout = planar(data.read('Layouts.amb/001'), 320, 163, 3)
    # Value 0 is colour 24 of the map palette, which is red in palette 7 (the background around the frames).
    # It is drawn black (ST colour 0) instead.
    write('LAYOUT.BIN', st_graphic([v and 8 + v for v in layout], 320, 163))

    # ---------- status block area ----------
    main_pal = [amiga_rgb(c) for c in source_words('KERNEL/DATA.S', 'Main_pal', 32)]
    portraits = []
    names = b''
    for c in PARTY:
        ch = data.read(f'Party_char.amb/{c:03}')
        portraits.append(planar(data.read(f'Portraits.amb/{ch[0x0a]:03}'), 32, 34, 5))
        names += ch[0x112:0x112 + 15].split(b'\0')[0][:15].ljust(16, b'\0')
    weights = [0] * 32
    for p in portraits:
        for v in p:
            weights[v] += 1
    for c in (2, 4, 16, 19, 20, 21, 22):   # text colours (White, Lighter_blue, Yellow, reds, Light_green)
        weights[c] += 2000
    ui16, ui_lut = make_palette(main_pal, weights)
    write('UIPAL.BIN', palette_file(ui16, ui_lut))
    write('PORTR.BIN', b''.join(st_graphic([ui_lut[v] for v in p], 32, 34) for p in portraits))
    write('NAMES.BIN', names)

    status = b''
    for label, w, h in (('Status_L', 16, 36), ('Status_M', 16, 36), ('Status_R', 16, 36),
                        ('Status_TB', 32, 1), ('Empty_portrait', 32, 34), ('Button_up', 32, 17),
                        ('Button_down', 32, 17)):
        raw = source_data('KERNEL/CHIP_DATA.S', label)
        if label == 'Status_M':  # the 16x36 graphic continues behind the next two labels
            raw += source_data('KERNEL/CHIP_DATA.S', 'GFX_char_status_icon_frame')
            raw += source_data('KERNEL/CHIP_DATA.S', 'GFX_char_value_bar_frames')
        if len(raw) < w * h * 3 // 8:
            raise SystemExit(f'{label}: only {len(raw)} bytes')
        if label.startswith('Button'):   # map area: value 0 (colour 24, red in palette 7) is drawn black
            status += st_graphic([v and 8 + v for v in planar(raw, w, h, 3)], w, h)
        else:
            status += st_graphic([8 + v for v in planar(raw, w, h, 3)], w, h)
    write('UIGFX.BIN', status)

    buttons = decode_file(open(os.path.join(AMBERFILES, 'Button_graphics'), 'rb').read())
    write('BUTTONS.BIN', b''.join(st_graphic([v and 8 + v for v in planar(buttons, 32, 13, 3, i * 156)], 32, 13)
                                  for i in range(len(buttons) // 156)))
    mptr = source_data('KERNEL/DATA.S', 'Default_Mptr')   # the hotspot words are dc.w, not part of it
    write('MPTR.BIN', struct.pack('>HH', 1, 1) + st_graphic([v and 8 + v for v in planar(mptr, 16, 16, 3)], 16, 16))

    texts = data.find('Map_texts.amb', args.map)
    name = b''
    if len(texts) >= 4:
        count = struct.unpack('>H', texts[:2])[0]
        size = struct.unpack('>H', texts[2:4])[0]
        name = texts[2 + 2 * count:2 + 2 * count + size].split(b'\0')[0].strip()
    write('MAPNAME.BIN', name + b'\0')
    write('START.BIN', struct.pack('>3H', *map(int, args.pos.split(','))))

    font = source_data('KERNEL/TEXTS.S', 'Glyph_mapping')
    glyphs = source_data('KERNEL/TEXTS.S', 'Glyph_data')
    write('FONT.BIN', font[:224] + glyphs)

    print(f'Map {args.map}: tileset {tileset}, palette {pal_index}, world {world}')
    print('Map palette:', ' '.join(f'${st_word(c, 4):03x}' for c in map16))
    print('UI palette: ', ' '.join(f'${st_word(c, 4):03x}' for c in ui16))


if __name__ == '__main__':
    main()
