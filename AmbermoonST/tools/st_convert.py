#!/usr/bin/env python3
# Converts the game data of Ambermoon for the Atari ST proof of concept.
#
#   python3 st_convert.py <output folder> [--map 258] [--pos 2,15,1] [--time 22:30] [--data <zip>]
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
#   P<t>.BIN    the same for the map area of the maps with tileset t
#   I<t>.BIN    icon graphics of tileset t (16x16 each), D<t>.BIN its icon data (unchanged)
#   G<w>_<t>.BIN  party graphics of world w (17 frames of 16x32) for tileset t
#   N<n>_<t>.BIN  NPC graphics file n for tileset t (number of frames (byte), 0 (byte), frames of 16x32)
#   M<nnn>.BIN  data of 2D map nnn, X<nnn>.BIN its map texts (both unchanged)
#   SAVE.BIN    the initial savegame (Party_data.sav: event bits, map characters, ...)
#   START.BIN   start map, X, Y, view direction, hour, minute (words)
#   WORLDS.BIN  the names of the 3 worlds (32 bytes each)
#   LAYOUT.BIN  layout 1 (2D map), 320x163
#   UIGFX.BIN   UI graphics of KERNEL/CHIP_DATA.S: Status_L, Status_M, Status_R (16x36 each),
#               Status_TB (32x1), Empty_portrait (32x34), Button_up, Button_down (32x17 each)
#   WINICONS.BIN  the 9 parts of a window border (Window_icons of KERNEL/CHIP_DATA.S, 16x16 each)
#   BUTTONS.BIN control icons of Button_graphics (78 x 32x13, colour 0 transparent)
#   MPTR.BIN    default mouse pointer (Default_Mptr of KERNEL/DATA.S): hotspot X, Y (words), 16x16
#   PORTR.BIN   6 portraits (32x34) of the party used by the proof of concept
#   NAMES.BIN   6 names (16 bytes each)
#   CHARS.BIN   character data of the 6 party members (Party_char.amb, first 512 bytes each)
#   FONT.BIN    Glyph_mapping (224 bytes) + Glyph_data (5 bytes per glyph), unchanged
import argparse, math, os, re, struct, sys, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.dont_write_bytecode = True            # no __pycache__ in Tools/AtariST
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
    ap.add_argument('--map', type=int, help='start map (default: from the initial savegame)')
    ap.add_argument('--pos', help='start position x,y,direction (default: from the initial savegame)')
    ap.add_argument('--time', help='time of day hh:mm (default: from the initial savegame)')
    ap.add_argument('--data', default=os.path.join(ROOT, 'ExtractedGameFiles.zip'))
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    data = Data(args.data)

    def write(name, content, quiet=False):
        with open(os.path.join(args.out, name), 'wb') as f:
            f.write(content)
        if not quiet:
            print(f'{name:12} {len(content):7} bytes')

    # ---------- map area : all 2D maps ----------
    maps = {}
    for name in sorted(data.names):
        if name[1:13] == 'Map_data.amb' and name[-1] != '/':
            md = data.read(name)
            if md[2] == 2:
                maps[int(name[-3:])] = md
    for nr, md in maps.items():
        write(f'M{nr:03}.BIN', md, quiet=True)
        texts = b''
        for c in '123':
            tn = f'{c}Map_texts.amb/{nr:03}'
            if tn in data.names:
                texts = data.read(tn)
        write(f'X{nr:03}.BIN', texts, quiet=True)
    print(f'{len(maps)} maps (M*.BIN) and map texts (X*.BIN)')

    party_raw = {w: data.read(f'Party_gfx.amb/{w + 1:03}') for w in range(3)}
    npc_files = {}
    for n in set(md[7] for md in maps.values() if md[7]):
        raw = data.read(f'NPC_gfx.amb/{n:03}')
        npcs = []                            # list of lists of frames
        i = 0
        while i + 2 <= len(raw) and raw[i]:
            k = raw[i]
            npcs.append([planar(raw, 16, 32, 5, i + 2 + j * 320) for j in range(k)])
            i += 2 + k * 320
        npc_files[n] = npcs

    for tileset in sorted(set(md[6] for md in maps.values())):
        tmaps = [md for md in maps.values() if md[6] == tileset]
        pal_index = tmaps[0][9]
        pd = data.read(f'Palettes.amb/{pal_index:03}')
        map_pal = [amiga_rgb(struct.unpack('>H', pd[i * 2:i * 2 + 2])[0] & 0xfff) for i in range(32)]
        gfx = data.find('Icon_gfx.amb', tileset)
        tiles = [planar(gfx, 16, 16, 5, i * 160) for i in range(len(gfx) // 160)]
        idata = data.read(f'Icon_data.amb/{tileset:03}')
        icons = [struct.unpack('>IHBB', idata[2 + i * 8:10 + i * 8])
                 for i in range(struct.unpack('>H', idata[:2])[0])]
        worlds = sorted(set(md[10] for md in tmaps))
        npcs_used = sorted(set(md[7] for md in tmaps if md[7]))
        party = {w: [planar(party_raw[w], 16, 32, 5, i * 320) for i in range(len(party_raw[w]) // 320)]
                 for w in worlds}
        # weights: pixels of all maps with this tileset (all animation frames) + party & NPC graphics
        weights = [0] * 32
        for md in tmaps:
            for i in range(md[4] * md[5]):
                o = 0x14c + i * 4
                for ti in (md[o], md[o + 2] << 8 | md[o + 3]):
                    if 0 < ti <= len(icons):
                        _, g, n, _ = icons[ti - 1]
                        for k in range(max(n, 1)):
                            if g - 1 + k < len(tiles):
                                for v in tiles[g - 1 + k]:
                                    weights[v] += 1
        sprites = [f for w in worlds for f in party[w]] + [f for n in npcs_used for g in npc_files[n] for f in g]
        for frame in sprites:
            for v in frame:
                weights[v] += 16       # small but important
        map16, map_lut = make_palette(map_pal, weights)
        write(f'P{tileset}.BIN', palette_file(map16, map_lut))
        write(f'I{tileset}.BIN', b''.join(st_graphic([map_lut[v] for v in t], 16, 16) for t in tiles))
        write(f'D{tileset}.BIN', idata)
        for w in worlds:
            write(f'G{w}_{tileset}.BIN', b''.join(st_graphic([map_lut[v] for v in f], 16, 32) for f in party[w]))
        for n in npcs_used:
            write(f'N{n}_{tileset}.BIN', b''.join(
                bytes([len(g), 0]) + b''.join(st_graphic([map_lut[v] for v in f], 16, 32) for f in g)
                for g in npc_files[n]) + b'\0\0')
        print(f'Tileset {tileset}: palette {pal_index}', ' '.join(f'${st_word(c, 4):03x}' for c in map16))

    layout = planar(data.read('Layouts.amb/001'), 320, 163, 3)
    # Value 0 is colour 24 of the map palette, which is red in palette 7 (the background around the frames).
    # It is drawn black (ST colour 0) instead.
    write('LAYOUT.BIN', st_graphic([v and 8 + v for v in layout], 320, 163))

    # ---------- status block area ----------
    main_pal = [amiga_rgb(c) for c in source_words('KERNEL/DATA.S', 'Main_pal', 32)]
    portraits = []
    names = b''
    chars = b''
    for c in PARTY:
        ch = data.read(f'Party_char.amb/{c:03}')
        portraits.append(planar(data.read(f'Portraits.amb/{ch[0x0a]:03}'), 32, 34, 5))
        names += ch[0x112:0x112 + 15].split(b'\0')[0][:15].ljust(16, b'\0')
        chars += ch[:512].ljust(512, b'\0')
    weights = [0] * 32
    for p in portraits:
        for v in p:
            weights[v] += 1
    for c in (2, 4, 16, 19, 20, 21, 22):   # text colours (White, Lighter_blue, Yellow, reds, Light_green)
        weights[c] += 2000
    for c in (6,):                         # LP bar (7, 6) must differ from the SP bar (24, 23)
        weights[c] += 4000
    ui16, ui_lut = make_palette(main_pal, weights)
    write('UIPAL.BIN', palette_file(ui16, ui_lut))
    write('PORTR.BIN', b''.join(st_graphic([ui_lut[v] for v in p], 32, 34) for p in portraits))
    write('NAMES.BIN', names)
    write('CHARS.BIN', chars)
    print('UI colours of the bars: LP', ui_lut[7], ui_lut[6], ' SP', ui_lut[24], ui_lut[23])

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
    winicons = source_data('KERNEL/CHIP_DATA.S', 'Window_icons')   # 9 parts 16x16, 3 bit, colour 0 transparent
    write('WINICONS.BIN', b''.join(st_graphic([v and 8 + v for v in planar(winicons, 16, 16, 3, i * 96)], 16, 16)
                                   for i in range(9)))

    buttons = decode_file(open(os.path.join(AMBERFILES, 'Button_graphics'), 'rb').read())
    write('BUTTONS.BIN', b''.join(st_graphic([v and 8 + v for v in planar(buttons, 32, 13, 3, i * 156)], 32, 13)
                                  for i in range(len(buttons) // 156)))
    mptr = source_data('KERNEL/DATA.S', 'Default_Mptr')   # the hotspot words are dc.w, not part of it
    write('MPTR.BIN', struct.pack('>HH', 1, 1) + st_graphic([v and 8 + v for v in planar(mptr, 16, 16, 3)], 16, 16))

    save = open(os.path.join(AMBERFILES, 'Save.00', 'Party_data.sav'), 'rb').read()
    write('SAVE.BIN', save)
    x, y, d = struct.unpack('>3H', save[0x0c:0x12])
    hour, minute = struct.unpack('>2H', save[6:10])
    map_nr = struct.unpack('>H', save[0x0a:0x0c])[0]
    if args.map:
        map_nr = args.map
    if args.pos:
        x, y, d = map(int, args.pos.split(','))
    if args.time:
        hour, minute = map(int, args.time.split(':'))
    write('START.BIN', struct.pack('>6H', map_nr, x, y, d, hour, minute))
    names = b''
    for i in range(3):
        with open(os.path.join(ROOT, 'Disks', 'Bugfixing', 'German', 'AllTexts', 'Text.amb', 'WorldNames',
                               f'{i:03}.txt'), encoding='utf-8-sig') as f:
            names += f.read().strip().encode('cp850')[:31].ljust(32, b'\0')
    write('WORLDS.BIN', names)

    font = source_data('KERNEL/TEXTS.S', 'Glyph_mapping')
    glyphs = source_data('KERNEL/TEXTS.S', 'Glyph_data')
    write('FONT.BIN', font[:224] + glyphs)

    print('UI palette: ', ' '.join(f'${st_word(c, 4):03x}' for c in ui16))


if __name__ == '__main__':
    main()
