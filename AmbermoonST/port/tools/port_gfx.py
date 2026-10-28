#!/usr/bin/env python3
"""Converts the graphics of the game into the ST format of the port (see port/GRAPHICS.md), for port_data.py.

All 5-plane graphics (32 colours) are stored as ST chunks: per line and 16 pixels the mask and the 4 ST planes
(5 words, the same size as 5 Amiga planes, so all offsets of the original code stay right). The colours go
through the lookup table of the ST palette the graphic is shown with (port_palettes.py, PALETTES json). The
kernel draws 5-plane graphics without any conversion.

Containers are written as AMBR (raw subfiles): nothing is decompressed or decrypted at run time any more.
Graphics shown with several map palettes (party, NPCs, transports) get a copy per palette: "<name>#<palette>"
(the kernel opens the copy of the palette of the current map, KERNEL/LIBS.S).
"""
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(HERE, '..', '..', 'tools'))
import st_convert as sc                   # noqa: E402

CONTAINERS = (b'AMBR', b'AMPC', b'AMNC', b'AMNP')


# ---------- files and containers ----------
def lob(d):
    """Unpacks LOB data (header: 1 byte, "LOB", 4 bytes packed size, 4 bytes unpacked size)."""
    return sc.lob_decode(d)


def decode_subfile(kind, number, d):
    """The data of a subfile of a container as the loader of the game has it in memory (KERNEL/FILES.S): AMBR
    raw, AMNC decrypted (packed data inside stays packed: the game unpacks it itself, e.g. the layouts),
    AMPC unpacked, AMNP decrypted and unpacked (its LOB header is not encrypted)."""
    if kind == b'AMNC':
        return sc.jh_decode(d, number)
    if kind in (b'AMPC', b'AMNP') and d[:4] == b'\x01LOB':
        size = int.from_bytes(d[4:8], 'big') & 0xffffff
        body = sc.jh_decode(d[8:], number) if kind == b'AMNP' else d[8:]
        return lob_raw(size, body[4:])
    if kind == b'AMNP':
        return sc.jh_decode(d[4:], number)
    return d


def lob_raw(size, src):
    out = bytearray()
    i = 0
    while len(out) < size:
        header = src[i]
        i += 1
        for _ in range(8):
            if header & 0x80 == 0:
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


def read_container(raw):
    """{subfile number: data} of a container, or None if raw is not a container."""
    kind = raw[:4]
    if kind not in CONTAINERS:
        return None
    n = struct.unpack('>H', raw[4:6])[0]
    sizes = struct.unpack('>%dI' % n, raw[6:6 + 4 * n])
    out, o = {}, 6 + 4 * n
    for i, s in enumerate(sizes):
        out[i + 1] = decode_subfile(kind, i + 1, raw[o:o + s]) if s else b''
        o += s
    return out


def read_file(raw):
    """A single file, unpacked (LOB, encrypted "JH" files)."""
    return sc.decode_file(raw)


def ambr(subfiles):
    """AMBR container of {number: data} (numbers 1..n, missing ones are empty)."""
    n = max(subfiles) if subfiles else 0
    datas = [subfiles.get(i + 1, b'') for i in range(n)]
    datas = [d + (b'\0' if len(d) & 1 else b'') for d in datas]        # (even sizes)
    return b'AMBR' + struct.pack('>H', n) + struct.pack('>%dI' % n, *[len(d) for d in datas]) + b''.join(datas)


# ---------- conversion ----------
def st_chunks(data, width, height, lut, frames=1, offset=0):
    """5-plane Amiga graphics (line interleaved) -> ST chunks (mask + 4 planes per 16 pixels, the same size).
    frames graphics of width x height one after the other from offset; the rest of data is kept."""
    out = bytearray(data)
    wpr = (width + 15) // 16
    size = wpr * 10 * height
    for f in range(frames):
        base = offset + f * size
        if base + size > len(data):
            break
        for y in range(height):
            row = base + y * wpr * 10
            planes = [[struct.unpack('>H', data[row + p * wpr * 2 + c * 2:row + p * wpr * 2 + c * 2 + 2])[0]
                       for c in range(wpr)] for p in range(5)]
            for c in range(wpr):
                mask, st = 0, [0, 0, 0, 0]
                for b in range(16):
                    v = 0
                    for p in range(5):
                        v |= ((planes[p][c] >> (15 - b)) & 1) << p
                    if v:
                        mask |= 1 << (15 - b)
                        s = lut[v]
                        for p in range(4):
                            if s >> p & 1:
                                st[p] |= 1 << (15 - b)
                struct.pack_into('>5H', out, row + c * 10, mask, *st)
    return bytes(out)


class Palettes:
    """The lookup tables of the ST palettes (port_palettes.py writes them as json)."""

    def __init__(self, path):
        self.items = json.load(open(path))

    def lut(self, colours):
        for p in self.items:
            if p['amiga'] == list(colours):
                return p['lut']
        raise SystemExit('no ST palette for the Amiga palette %s' % ' '.join('%03x' % c for c in colours))


def words(raw):
    return [struct.unpack('>H', raw[i * 2:i * 2 + 2])[0] & 0xfff for i in range(32)]


# ---------- the graphics of the game ----------
UI_FIRST_TABLES = ('Combat_bg_2D_table', 'Combat_bg_3D_table')


def stationary_sizes():
    """Width, height of the stationary transports (Stationary_dimensions, KERNEL/DATA.S)."""
    raw = sc.source_data('KERNEL/DATA.S', 'Stationary_dimensions')
    words = list(sc.source_words('KERNEL/DATA.S', 'Stationary_dimensions', 2)) + \
        [raw[i] << 8 | raw[i + 1] for i in range(0, len(raw) - 1, 2)]
    return [(words[i], words[i + 1]) for i in range(0, len(words) - 1, 2)]


def fx_layout():
    """(offset, width, height, frames, palette kind) of the parts of Combat_graphics (rsgfx in GAME_OFF.S)."""
    import re
    parts, offset = [], 0
    lines = open(os.path.join(sc.SRC, 'GAME_OFF.S'), encoding='latin-1').read().split('\n')
    i = next(k for k, l in enumerate(lines) if l.startswith('Fireball_fro_FXGFX'))
    for l in lines[i:]:
        if l.startswith('Fighting_FXGFX'):
            break
        m = re.match(r'\s+rsgfx\s+(\d+),(\d+),(\d+)', l)
        if m:
            w, h, n = map(int, m.groups())
            parts.append((offset, w, h, n))
            offset += w // 16 * 10 * h * n
    return parts, offset


def convert_all(files, pals):
    """Converts the graphics in files ({name: data} as on the Amiga) for the port; returns the new files (the
    containers as AMBR, the 5-plane graphics as ST chunks, the copies per map palette)."""
    out = dict(files)
    palettes = {k: words(v) for k, v in read_container(files['Palettes.amb']).items()}
    main_lut = pals.lut(sc.source_words('KERNEL/DATA.S', 'Main_pal', 32))
    tactic = sc.source_words('KERNEL/DATA.S', 'Tactic_pal', 32)
    tactic_lut = pals.lut(tactic)
    automap_lut = pals.lut(sc.source_words('KERNEL/DATA.S', 'Automap_pal', 32))
    combat = []
    for table in UI_FIRST_TABLES:
        t = sc.source_data('KERNEL/DATA.S', table)
        combat += [(t[j], t[j + 1]) for j in range(0, len(t) - 3, 4)]      # (background, day palette)
    combat_lut = pals.lut(palettes[combat[0][1]][:26] + tactic[26:])       # (one table for all : a group)

    # maps : tileset -> palette, the palettes of the 2D maps
    tileset_pal, map_pals = {}, set()
    for f in ('1Map_data.amb', '2Map_data.amb', '3Map_data.amb'):
        for md in read_container(files[f]).values():
            if md and md[2] == 2:
                tileset_pal[md[6]] = md[9]
                map_pals.add(md[9])

    def container(name, convert):
        """Converts every subfile of a container with convert(number, data) and stores it as AMBR."""
        subs = read_container(files[name])
        out[name] = ambr({k: (convert(k, v) if v else v) for k, v in subs.items()})

    # ---------- tiles : the palette of their tileset ----------
    for name, first in (('1Icon_gfx.amb', 1), ('2Icon_gfx.amb', 1), ('3Icon_gfx.amb', 1)):
        def tiles(k, d):
            lut = pals.lut(palettes[tileset_pal.get(k, 1)])
            return st_chunks(d, 16, 16, lut, len(d) // 160)
        container(name, tiles)
    # ---------- event pictures, portraits, 80x80 pictures, combat backgrounds, monsters ----------
    event_pal = list(sc.source_data('KERNEL/DATA.S', 'Event_pix_palette_table')) + [0x21]
    container('Event_pix.amb', lambda k, d: st_chunks(d, 320, 92, pals.lut(palettes[event_pal[k - 1]])))
    container('Portraits.amb', lambda k, d: st_chunks(d, 32, 34, main_lut))
    container('Pics_80x80.amb', lambda k, d: st_chunks(d, 80, 80, main_lut))
    container('Combat_background.amb', lambda k, d: st_chunks(d, 320, 95, combat_lut, 1, len(d) - 19000))
    sizes = {}
    for md in filter(None, read_container(files['Monster_char.amb']).values()):
        sizes[md[12]] = struct.unpack('>HH', md[len(md) - 8:len(md) - 4])
    container('Monster_gfx.amb', lambda k, d: st_chunks(d, sizes[k][0], sizes[k][1], combat_lut,
                                                        len(d) // ((sizes[k][0] + 15) // 16 * 10 * sizes[k][1])))
    # ---------- single files ----------
    icons = read_file(files['Object_icons'])
    out['Object_icons'] = st_chunks(icons, 16, 16, main_lut, len(icons) // 160)
    automap = read_file(files['Automap_graphics'])
    out['Automap_graphics'] = st_chunks(automap, 16, 16, automap_lut, 55, 16 * 16 + 4 * 384 + 16 * 192)
    fx = read_file(files['Combat_graphics'])
    parts, end = fx_layout()
    for offset, w, h, n in parts:
        fx = st_chunks(fx, w, h, combat_lut, n, offset)
    out['Combat_graphics'] = st_chunks(fx, 16, 14, tactic_lut, 35, end + 2 * 6 * 36)      # tactic icons
    # ---------- party, NPCs, transports : a copy per map palette ----------
    party = read_container(files['Party_gfx.amb'])
    npcs = read_container(files['NPC_gfx.amb'])
    travel = read_container(files['Travel_gfx.amb'])
    stationary = read_file(files['Stationary'])

    def npc_file(d, lut):
        d, o = bytearray(d), 0
        while o + 2 <= len(d) and d[o]:
            n = d[o]
            d[o + 2:o + 2 + n * 320] = st_chunks(bytes(d[o + 2:o + 2 + n * 320]), 16, 32, lut, n)
            o += 2 + n * 320
        return bytes(d)

    def travel_file(d, lut):
        d, o = bytearray(d), 0
        while o + 8 <= len(d):
            w, h = struct.unpack('>HH', d[o:o + 4])          # (width in units of 16 pixels)
            if not w or not h:
                break
            size = w * 10 * h
            d[o + 8:o + 8 + size] = st_chunks(bytes(d[o + 8:o + 8 + size]), w * 16, h, lut)
            o += 8 + size
        return bytes(d)

    def stationary_file(d, lut):
        o = 0
        for w, h in stationary_sizes():
            d = st_chunks(d, w, h, lut, 1, o)
            o += (w + 15) // 16 * 10 * h
        return d

    for pal in sorted(map_pals) + [None]:
        lut = pals.lut(palettes[pal or 1])
        suffix = '#%d' % pal if pal else ''
        out['Party_gfx.amb' + suffix] = ambr({k: st_chunks(v, 16, 32, lut, len(v) // 320) for k, v in party.items()})
        out['NPC_gfx.amb' + suffix] = ambr({k: npc_file(v, lut) for k, v in npcs.items()})
        out['Travel_gfx.amb' + suffix] = ambr({k: travel_file(v, lut) for k, v in travel.items()})
        out['Stationary' + suffix] = stationary_file(stationary, lut)
    # ---------- all other containers : raw (nothing to unpack or decrypt at run time) ----------
    for name, data in files.items():
        if out[name] is data and read_container(data) is not None and data[:4] != b'AMBR':
            out[name] = ambr(read_container(data))
    return out
