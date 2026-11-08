#!/usr/bin/env python3
"""The data of the intro of the ST (port/KERNEL/INTRO_ST.S) : the intro is made anew for the ST (like Intro.cs of
Ambermoon.net), with the graphics of Ambermoon_intro (intro_graphics.py) in the format of the ST screen, made here.

    intro_st.py <Ambermoon_intro> <out data> <out include>

The include has the offsets of the parts (Ist_* EQU Intro_st_data+offset).

The screen of the ST shows 200 lines; the lines of the Amiga screen from TOP on (the scenes have 256 lines : the
texts under the pictures). The colours are the colours 0-15 of the palettes of the intro (the graphics have 4 bits),
so the graphics keep their colour numbers. The stars are white : in the scenes of the logos the colour STAR_COLOUR of
the palette of the logo (not in the logo) is white.
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import intro_graphics  # noqa: E402

TOP = 36                    # the first Amiga line on the ST (the stars, the logos, the planets, the credits)
STAR_COLOUR = {0: 1, 1: 13}  # (the logos : a colour which is white for the stars)
STARS = 150
START_SCALE, SCALE_STEP = 0x7630, 250


class Rng:
    """The random numbers of the intro (seed $0011)"""
    def __init__(self):
        self.seed = 0x0011

    def __call__(self):
        n = self.seed * 0xd117
        self.seed = n & 0xffff
        v = (n >> 8) & 0x7fff
        return v - 0x10000 if v & 0x8000 else v


def cdiv(a, b):
    """The division of the 68000 (towards 0)"""
    q = abs(a) // abs(b)
    return q if (a < 0) == (b < 0) else -q


def st_rows(rows, x0, chunks):
    """Rows of colours (None : 0) from the pixel x0 on -> ST screen lines of chunks (16 pixels, 4 planes)"""
    out = bytearray()
    for row in rows:
        for c in range(chunks):
            words = [0, 0, 0, 0]
            for x in range(16):
                px = c * 16 + x - x0
                v = row[px] if 0 <= px < len(row) else None
                if v:
                    for p in range(4):
                        if (v >> p) & 1:
                            words[p] |= 1 << (15 - x)
            out += struct.pack('>4H', *words)
    return bytes(out)


def st_masked(rows, x0, chunks):
    """The same with a mask (None : transparent) : per chunk the mask and the 4 planes"""
    out = bytearray()
    for row in rows:
        for c in range(chunks):
            words = [0] * 5
            for x in range(16):
                px = c * 16 + x - x0
                v = row[px] if 0 <= px < len(row) else None
                if v is not None:
                    words[0] |= 1 << (15 - x)
                    for p in range(4):
                        if (v >> p) & 1:
                            words[1 + p] |= 1 << (15 - x)
            out += struct.pack('>5H', *words)
    return bytes(out)


def block(rows, x, y, top=TOP):
    """A picture at x, y (Amiga line) : the chunks which it touches, from the line of the ST on"""
    w = len(rows[0])
    c0, c1 = x // 16, (x + w + 15) // 16
    return struct.pack('>4h', c0, c1 - c0, y - top, len(rows)) + st_rows(rows, x - c0 * 16, c1 - c0)


def scaled(rows, w, h):
    """The picture scaled to w x h (like the zoom of the Amiga : the pixel of the source at x * width / w)"""
    sw, sh = len(rows[0]), len(rows)
    return [[rows[y * sh // h][x * sw // w] for x in range(w)] for y in range(h)]


def logo_frames(rows, per_tick):
    """The frames of a logo which flies in : the factor goes from $900 down to $100 (per_tick each tick), the logo
    in the middle (160, 100). Per frame : x chunk, chunks, y, lines, the lines"""
    frames = []
    factor = 256 + 2048
    while factor >= 256:
        w = max(1, len(rows[0]) * 256 // factor)
        h = max(1, len(rows) * 256 // factor)
        frames.append(block(scaled(rows, w, h), 160 - w // 2, 100 - h // 2))
        factor -= per_tick
    return frames


def text_rows(font, text, colour):
    """A text in a font : rows of colours (None : nothing)"""
    width = sum(font[ch][0] if ch in font else 6 for ch in text)
    h = len(next(iter(font.values()))[1])
    rows = [[None] * (width + 32) for _ in range(h)]
    x = 0
    for ch in text:
        if ch not in font:
            x += 6
            continue
        adv, glyph = font[ch]
        for y, g in enumerate(glyph):
            for gx, on in enumerate(g):
                if on:
                    rows[y][x + gx] = colour
        x += adv
    return [row[:width + 1] for row in rows], width


def stars():
    """The stars : for each its positions in the screen of the ST (offset of the byte of plane 0, bit; $ffff : not in
    the screen of the ST) and the position at the start. Like the original : every star goes from the scale
    START_SCALE down in steps; the positions outside the Amiga screen (320 x 200) are skipped."""
    rng = Rng()
    out = []
    for _ in range(STARS):
        r1 = rng() % 0x3e80 - 0x1f40
        r2 = rng() % 0x6400 - 0x3200
        bx, by = r2 * 256, r1 * 256
        positions = []
        scale = START_SCALE
        while scale > 0:
            x = 160 + cdiv(bx, scale)
            y = 100 + cdiv(by, scale)
            if 0 <= x < 320 and 0 <= y < 200:
                positions.append((x, 4 + y))
            scale -= SCALE_STEP
        start = rng() % len(positions)
        out.append((positions, start))
    return out


def cdiv_mod(a, b):
    """% of C# (the sign of a)"""
    r = abs(a) % abs(b)
    return -r if a < 0 else r


def star_data(st):
    head, body = bytearray(), bytearray()
    base = STARS * 8
    for positions, start in st:
        head += struct.pack('>HHI', len(positions), start, base + len(body))
        for x, y in positions:
            yy = y - TOP
            if 0 <= yy < 200 - TOP:             # (not in the lines of the credits)
                body += struct.pack('>HBB', yy * 160 + (x // 16) * 8 + ((x >> 3) & 1), 7 - (x & 7), 0)
            else:
                body += struct.pack('>HBB', 0xffff, 0, 0)
    return bytes(head + body)


def blocks(items):
    """Blocks : a table of their offsets (.l), then the blocks"""
    body, offs = bytearray(), []
    for b in items:
        offs.append(4 * len(items) + len(body))
        body += b
    return struct.pack('>%dI' % len(items), *offs) + bytes(body)


# The scene of the planets (IntroActionDisplayObjects and IntroActionTextCommands of Intro.cs)
ZOOM = [(-136, -24, 22000, 512, 512), (-256, 70, 21700, 256, 256), (200, -150, 21500, 100, 100),
        (-18, -210, 19000, 288, 264), (-300, -32, 8000, 512, 512)]     # Lyramion, Morag, Forest moon, meteor, sun
TRANSITIONS = [(0x10, 0x4268), (0x0c, 0x42cc), (0x0a, 0x4330), (0x08, 0x4394), (0x07, 0x43f8), (0x06, 0x445c),
               (0x05, 0x44c0), (0x04, 0x4524), (0x03, 0x4588), (0x02, 0x45ec), (0x01, 0x4650), (0x00, 0x4742),
               (0x01, 0x477c), (0x02, 0x47e0), (0x03, 0x4a38), (0x04, 0x4a9c)]
TOWNS = [(0x52f0 - 100, 190), (0x54c4 - 50, 155), (0x5654, 90)]       # zoom, duration
TOWN_X = [92, 120, 91]
MAX_ZOOM, FADE_ZOOM, METEOR_END, SPARK_ZOOM = 22248, 22184, 18868, 21000
CREDIT_LINES = 36                                                    # (the Amiga lines 200-235)


def ste(c):
    """Amiga colour -> STE colour"""
    n = lambda v: (v >> 1) | ((v & 1) << 3)
    return n(c >> 8 & 15) << 8 | n(c >> 4 & 15) << 4 | n(c & 15)


def blend(c0, c1, a, black):
    """c0 to c1 by a / 255, then to black by black / 255"""
    out = 0
    for s in (8, 4, 0):
        v0, v1 = c0 >> s & 15, c1 >> s & 15
        v = (v0 * 255 + (v1 - v0) * a + 127) // 255
        out |= (v * (255 - black) + 127) // 255 << s
    return out


def credit_page(I, adds):
    """The texts of a page of the credits (small font, colour 1) : plane 0 of the ST lines from 200 - TOP on"""
    rows = [[None] * 320 for _ in range(CREDIT_LINES)]
    for x, y, text in adds:
        t, _ = text_rows(I.font, text, 1)
        for ty, row in enumerate(t):
            for tx, c in enumerate(row):
                if c and 0 <= x + tx < 320 and 0 <= y + ty < CREDIT_LINES:
                    rows[y + ty][x + tx] = 1
    data = st_rows(rows, 0, 20)
    return b''.join(data[i:i + 2] for i in range(0, len(data), 8))


def objects_timeline(I):
    """Per tick of the scene (from tick 915 on, Intro.cs) : zoom.w, colour of the credits (ST, .w), palette of the
    upper part, page of the credits, frame of the sparks, town (.b, $ff : none). The scene ends when all is black."""
    pal3, pal4 = I.palettes[3], I.palettes[4]
    glow_step = 255 // max(max(abs((pal3[i] >> s & 15) - (pal3[16 + i] >> s & 15)) for s in (8, 4, 0))
                           for i in range(16))
    commands = list(I.commands)
    # text commands
    wait_end, adds, page, cur, target, fade_last = -1, [], None, 0, 0, 0
    # display objects
    zoom, zoom_wait, trans, spark, town, town_start, town_vis = -7000, -1, 0, -1, -1, -1, False
    glow_target, glow, last_glow, fade_start, black = -1, 0, 0, -1, 0
    palettes, pal_index, pages, page_index = [], {}, [], {}
    meteor_zoom = zoom
    out = []
    t = 0
    while True:
        spark_shown = None
        if t:
            # IntroActionTextCommands
            if t % 4 != 3:
                if wait_end == -1:
                    wait_end = t + 50
                if cur != target and (t - fade_last) >= 4:       # (a step of every component every 4 ticks)
                    for _ in range((t - fade_last) // 4):
                        new = 0
                        for s in (8, 4, 0):
                            cv, tv = cur >> s & 15, target >> s & 15
                            new |= (cv + (tv > cv) - (tv < cv)) << s
                        cur = new
                    fade_last += (t - fade_last) // 4 * 4
                if wait_end <= t and commands:
                    c, args = commands.pop(0)
                    if c == 0:
                        adds, page = [], None
                    elif c == 1:
                        adds.append(args)
                    elif c == 2:
                        page = tuple(adds)
                    elif c == 3:
                        wait_end = t + args[0]
                    elif c == 4:
                        target, fade_last = args[0], t
                    elif c == 5:
                        glow_target, glow, last_glow = 255, 0, t
            # IntroActionDisplayObjects : CheckTownDisplay
            if town != 3:
                nxt = town + 1
                if nxt < 3 and zoom >= TOWNS[nxt][0]:
                    town, town_start, town_vis = nxt, t, True
                elif town >= 0:
                    town_vis = TOWNS[town][1] + 1 > t - town_start
                    if nxt == 3 and not town_vis:
                        town = 3
            if not town_vis:
                if spark == -1 and zoom >= SPARK_ZOOM:
                    spark = 0
                if spark != -1:
                    spark_shown = spark // 4
                if zoom_wait:                                    # ProcessTicks
                    if zoom_wait < 0:
                        while zoom >= TRANSITIONS[trans][1] and trans < 15:
                            trans += 1
                        if TRANSITIONS[trans][0] == 0:
                            zoom_wait = 150
                            trans += 1
                        else:
                            zoom = min(zoom + TRANSITIONS[trans][0], MAX_ZOOM)
                    else:
                        zoom_wait -= 1
                        if not zoom_wait:
                            zoom_wait = -1
                if spark != -1:
                    spark += 1
                    if spark == 60:
                        spark = 28
                if zoom < METEOR_END:
                    meteor_zoom = zoom
                if zoom >= FADE_ZOOM:
                    if fade_start == -1:
                        fade_start = t
                    if t - fade_start >= 1:
                        black = min(255, (t - fade_start + 1) * 15 // 2)
                    glow_target = -1
                    if black >= 210:
                        zoom_wait = 0
                if glow_target != -1:
                    n = (t - last_glow) // 4
                    last_glow += n * 4
                    for _ in range(n):
                        if glow < glow_target:
                            if glow + glow_step >= glow_target:
                                glow, glow_target = glow_target, 0
                            else:
                                glow += glow_step
                        elif glow > glow_target:
                            if glow - glow_step <= glow_target:
                                glow, glow_target = glow_target, 255
                            else:
                                glow -= glow_step
        if town_vis:
            pal = tuple(ste(c) for c in pal4[:16])
        else:
            pal = tuple(ste(blend(pal3[i], pal3[16 + i], glow, black)) for i in range(16))
        if pal not in pal_index:
            pal_index[pal] = len(palettes)
            palettes.append(pal)
        p = 0xff
        if page is not None:
            if page not in page_index:
                page_index[page] = len(pages)
                pages.append(credit_page(I, page))
            p = page_index[page]
        low = ste(blend(cur if page is not None else 0, 0, 0, black))
        out.append(struct.pack('>hHBBBB', zoom, low, pal_index[pal], p,
                               0xff if spark_shown is None else spark_shown, town if town_vis else 0xff))
        if black == 255:
            break
        t += 1
    assert len(palettes) < 255 and len(pages) < 255
    return out, palettes, pages, meteor_zoom


TW_TOP = 24                 # Twinlake : the first Amiga line on the ST


def faded(pal, black):
    """16 Amiga colours to black by black / 255 -> ST colours"""
    return tuple(ste(blend(c, 0, 0, black)) for c in pal)


def twinlake(I, palettes, pal_index):
    """Twinlake (IntroActionTwinlake) : the picture (the frame, Twinlake, its name; ST screen from the Amiga line
    TW_TOP on), the 94 changes of the animation (blocks, each the whole state of its box), per tick the palette
    and the change (.b, $ff : none). The scene ends when all is black."""
    canvas = [[0] * 320 for _ in range(256)]
    for x0, y0, rows in ((16, 0, I.frame), (32, 7, I.twinlake),
                         (90, 203, text_rows(I.font_large, I.texts[4], 1)[0])):
        for y, row in enumerate(rows):
            for x, c in enumerate(row):
                if c is not None and 0 <= y0 + y < 256 and 0 <= x0 + x < 320:
                    canvas[y0 + y][x0 + x] = c
    picture = st_rows(canvas[TW_TOP:TW_TOP + 200], 0, 20)
    # the changes : per change the number of chunks (.w), per chunk its offset in the screen (.w), 4 planes
    changes, before = [], picture
    for x0, y0, rows in I.twinlake_parts:
        for y, row in enumerate(rows):
            canvas[7 + y0 + y][32 + x0:32 + x0 + len(row)] = row
        now = st_rows(canvas[TW_TOP:TW_TOP + 200], 0, 20)
        diff = [o for o in range(0, len(now), 8) if now[o:o + 8] != before[o:o + 8]]
        changes.append(struct.pack('>H', len(diff)) + b''.join(struct.pack('>H', o) + now[o:o + 8] for o in diff))
        before = now
    parts = blocks(changes)
    pal = I.palettes[4][16:]
    out = bytearray()
    e = 0
    while True:
        black, part = max(0, 255 - e * 8), 0xff
        if e >= 250:
            part = min(93, (e - 250) // 4)
            if e - 250 >= 94 * 4:
                black = min(255, (e - 250 - 94 * 4) * 15 // 4)
        p = faded(pal, black)
        if p not in pal_index:
            pal_index[p] = len(palettes)
            palettes.append(p)
        out += bytes([pal_index[p], part])
        if black == 255 and e >= 250:
            break
        e += 1
    return picture, parts, struct.pack('>H', len(out) // 2) + bytes(out)


def nearest(colour, pal):
    """The index of the colour of pal which is nearest to colour"""
    rgb = lambda c: (c >> 8 & 15, c >> 4 & 15, c & 15)
    a = rgb(colour)
    return min(range(1, 16), key=lambda i: sum((u - v) ** 2 for u, v in zip(a, rgb(pal[i]))))


def destruction(I, palettes, pal_index):
    """The destruction of the towns (IntroActionTownDestruction) : the meteor in the colours of the towns (pixels
    * 16), per tick : town (.b), palette (.b), x, y, width, height of the meteor (.w, width 0 : none). The scene
    ends with the third town."""
    pal3, pal4 = I.palettes[3], I.palettes[4]
    remap = [0] + [nearest(pal3[c], pal4) for c in range(1, 16)]
    meteor = bytes(16 * remap[c] for row in I.meteor for c in row)
    flash = I.palettes[5][1]
    zoom, mx, my, town, offset = 14000, 9700, 5700, 0, 0
    next_town, fade_in, fade_out, flash_alpha = 414, 0, 414 - 64, 0
    rect = (0, 0, 0, 0)
    out = bytearray()
    last, t = 0, 0
    while True:
        if t != last:
            if t - last >= 2:
                elapsed, last = t - last, t
                if offset == 3 and flash_alpha > 0:
                    flash_alpha = max(0, flash_alpha - 16)
                if zoom <= -512:
                    if t >= next_town and fade_out == -1:
                        town += 1
                        if town == 3:
                            break
                        zoom, mx, my, offset = 14000, -9700 if town == 1 else 9700, 5700, 0
                        next_town, fade_out, fade_in = t + 414, t + 414 - 64, t
                else:
                    dx = -208 if town == 1 else 208
                    for _ in range(elapsed // 2):
                        mx, my, zoom = mx - dx, my - 124, zoom - 256
                        if zoom < 0x7b0 and offset != 3:
                            offset, flash_alpha = 3, 192
                        f = zoom + 256
                        w = 0x60000 // f if f > 0 else 0
                        x = 160 + int(mx * 256 / f) - w // 2 if f > 0 else 0
                        y = 100 - int(my * 256 / f) - w // 2 if f > 0 else 0
                        rect = (x, y, w, w) if f > 0 and w >= 1 else (0, 0, 0, 0)
        black = 0
        if fade_in != -1:
            black = max(0, 255 - (t - fade_in) * 4)
            if black == 0:
                fade_in = -1
        elif fade_out != -1 and t >= fade_out:
            black = min(255, (t - fade_out) * 4)
            if black == 255:
                fade_out = -1
        elif fade_out == -1 and zoom <= -512:
            black = 255
        if flash_alpha and offset == 3 and not black:
            p = tuple(ste(blend(c, flash, flash_alpha, 0)) for c in pal4[:16])
        else:
            p = faded(pal4[:16], black)
        if p not in pal_index:
            pal_index[p] = len(palettes)
            palettes.append(p)
        out += struct.pack('>BB4h', town + offset, pal_index[p], *rect)
        t += 1
    return meteor, struct.pack('>H', len(out) // 10) + bytes(out)


ES_TOP = 28                 # the end screen : the first Amiga line on the ST (like the main menu)


def end_screen(I, palettes, pal_index):
    """The end screen (like the code of Ambermoon_intro, the times of IntroActionEndScreen) : one palette, the
    colours 16-31 of palette 5 (the black : colour 15), from black at the start; when the clouds are nearly gone it
    fades to palette 6 (the main menu). The clouds (at y 0 and 128) go to the sides, between them the main menu
    comes, in columns of 16 pixels : from 16 * ((x + 50) / 16) to 16 * ((206 - x) / 16) + 80.
    Returns : the first picture (black, clouds, texts), the main menu, the clouds of the left and of the right
    (sprites : 7 chunks, 200 lines), per tick : palette (.w), phase (.b : 0 the first picture, 1 the clouds),
    0 (.b), x of the clouds (.w), first and end chunk of the main menu (.w)."""
    pal5, pal6 = I.palettes[5][16:], I.palettes[6][:16]
    menu = I.menu_picture[ES_TOP:ES_TOP + 200]

    def cloud_sprite(g):
        return g[ES_TOP:128] + g[:200 - (128 - ES_TOP)]          # (the clouds at y 0 and 128)

    left, right = cloud_sprite(I.cloud_left), cloud_sprite(I.cloud_right)
    first = [[15] * 320 for _ in range(200)]                      # black, the clouds at x 80 and 128, the texts
    for x0, rows in ((80, left), (128, right)):
        for y, row in enumerate(rows):
            for x, c in enumerate(row):
                if c is not None:
                    first[y][x0 + x] = c
    for i, (x0, y) in enumerate(((90, 85), (100, 114), (104, 136))):
        rows, w = text_rows(I.font_large, I.texts[5 + i], 1)
        for ty, row in enumerate(rows):
            for tx, c in enumerate(row):
                if c is not None and 0 <= y - ES_TOP + ty < 200 and x0 + tx < 320:
                    first[y - ES_TOP + ty][x0 + tx] = 1
    out = bytearray()
    e, fade_start = 0, -1
    while True:
        xo, phase = 80, 0
        if e >= 300:
            xo, phase = 80 - (1 + (e - 300) // 2), 1
            if xo <= -27 and fade_start == -1:
                fade_start = e
        factor = 0.0 if fade_start == -1 else min(1.0, (e - fade_start) / 200)
        lerp = lambda a, b: sum(round((a >> s & 15) + ((b >> s & 15) - (a >> s & 15)) * factor) << s
                                for s in (8, 4, 0))
        p = faded([lerp(a, b) for a, b in zip(pal5, pal6)], max(0, 255 - e * 4))
        if p not in pal_index:
            pal_index[p] = len(palettes)
            palettes.append(p)
        xc = max(xo, -170)
        first_chunk = max(0, xc + 50) >> 4
        end_chunk = min(20, (min(240, 206 - xc) >> 4) + 5)
        out += struct.pack('>HBxhhh', pal_index[p], phase, xc, first_chunk, end_chunk)
        if xo <= -170 and factor == 1.0:
            break
        e += 1
    masked = lambda rows: st_masked(rows, 0, 7)
    return (st_rows(first, 0, 20), st_rows(menu, 0, 20), masked(left), masked(right),
            struct.pack('>H', len(out) // 10) + bytes(out))


def build(path):
    """The data and the include"""
    I = intro_graphics.Intro(path)
    parts = []

    def part(name, data):
        parts.append((name, data))

    pal = bytearray()
    for p in I.palettes:
        pal += struct.pack('>32H', *p)
    part('Ist_palettes', bytes(pal))
    part('Ist_stars', star_data(stars()))
    for name, rows, per in (('Ist_thalion', I.thalion, 32), ('Ist_ambermoon', I.ambermoon, 64)):
        frames = logo_frames(rows, per)
        table = bytearray(struct.pack('>H', len(frames)))
        off = 2 + 4 * len(frames)
        body = bytearray()
        for f in frames:
            table += struct.pack('>I', off + len(body))
            body += f
            if len(body) & 1:
                body += b'\0'
        part(name, bytes(table + body))
    # "PRESENTS" : large font, in the middle of the lines 160-181, in the white of the logo
    rows, w = text_rows(I.font_large, I.texts[3], STAR_COLOUR[0])
    part('Ist_presents', block(rows, 160 - w // 2, 160))
    # the scene of the planets : per tick the state, the palettes, the pages of the credits
    timeline, palettes, pages, meteor_zoom = objects_timeline(I)
    part('Ist_timeline', struct.pack('>H', len(timeline)) + b''.join(timeline))
    pal_index = {p: i for i, p in enumerate(palettes)}
    tw_picture, tw_parts, tw_timeline = twinlake(I, palettes, pal_index)
    meteor, de_timeline = destruction(I, palettes, pal_index)
    assert len(palettes) <= 256, len(palettes)       # (the scenes before : the palette .b)
    es_first, es_menu, es_left, es_right, es_timeline = end_screen(I, palettes, pal_index)
    part('Ist_upper', b''.join(struct.pack('>16H', *p) for p in palettes))
    part('Ist_tw_picture', tw_picture)
    part('Ist_tw_parts', tw_parts)
    part('Ist_tw_timeline', tw_timeline)
    part('Ist_de_meteor', meteor)
    part('Ist_de_timeline', de_timeline)
    part('Ist_es_first', es_first)
    part('Ist_es_menu', es_menu)
    part('Ist_es_left', es_left)
    part('Ist_es_right', es_right)
    part('Ist_es_timeline', es_timeline)
    part('Ist_pages', b''.join(pages))
    # the planets, the meteor, the sun (12 frames) : per object its zoom info (end x, end y, distance, zoomed
    # width, height, width, height of the picture, 0 (.w), offset of the pixels (.l)); the pixels : colour * 16
    # (0 : transparent)
    table, body = bytearray(), bytearray()
    for (ex, ey, dist, zw, zh), rows in zip(ZOOM, [I.lyramion, I.morag, I.forest_moon, I.meteor, I.sun[0]]):
        table += struct.pack('>8hI', ex, ey, dist, zw, zh, len(rows[0]), len(rows), 0, 20 * len(ZOOM) + len(body))
        for frame in ([rows] if rows is not I.sun[0] else I.sun):
            body += bytes(16 * (c or 0) for row in frame for c in row)
    part('Ist_objects', bytes(table + body))
    # the sparks of the meteor (30 frames, 64 x 47 at x 48 and 192 : chunks), with masks (colour 0 : transparent)
    part('Ist_sparks', b''.join(st_masked([[c or None for c in row] for row in f], 0, 4) for f in I.sparks))
    # the towns (160 x 128 at x 80, y 36), and the destroyed towns : blocks (offsets .l)
    part('Ist_towns', blocks([block(t, 80, 36) for t in I.towns]))
    # the names of the towns (large font, y 170)
    part('Ist_town_names', blocks([block(text_rows(I.font_large, I.texts[i], 1)[0], TOWN_X[i], 170)
                                   for i in range(3)]))
    data = bytearray()
    out = []
    for name, d in parts:
        while len(data) & 3:
            data.append(0)
        out.append('%s\tEQU\tIntro_st_data+%d' % (name, len(data)))
        data += d
    inc = ['; Made by port/tools/intro_st.py : the parts of the data of the intro of the ST'] + out + [
        'Intro_st_size\tEQU\t%d' % len(data), 'Ist_top\tEQU\t%d' % TOP,
        'Ist_star_thalion\tEQU\t%d' % STAR_COLOUR[0], 'Ist_star_ambermoon\tEQU\t%d' % STAR_COLOUR[1],
        'Ist_meteor_zoom\tEQU\t%d' % meteor_zoom, 'Ist_meteor_end\tEQU\t%d' % METEOR_END,
        'Ist_credits_line\tEQU\t%d' % (200 - TOP)]
    return bytes(data), '\n'.join(inc) + '\n'


def main():
    data, inc = build(sys.argv[1])
    open(sys.argv[2], 'wb').write(data)
    open(sys.argv[3], 'w').write(inc)
    print('intro of the ST :', len(data), 'bytes')


if __name__ == '__main__':
    main()
