"""Prints a 2D map as text: walkable tiles, event chains, characters, events and goto points.

Usage: python mapdump.py <unpacked data folder> <map number>

The data folder contains the containers unpacked with AmbermoonPack UNPACK (1Map_data.amb/, 2Map_data.amb/,
3Map_data.amb/, Icon_data.amb/, ...). Legend: '#' blocked, '.' walkable, '0'-'9'/'a'-'z' event chain (1-based),
'@' character start position.
"""
import os
import struct
import sys

EVENT_TYPES = {1: 'Teleport', 2: 'Door', 3: 'Chest', 4: 'PopupText', 5: 'Spinner', 6: 'Trap', 7: 'ChangeBuffs',
               8: 'Riddlemouth', 9: 'Reward', 10: 'ChangeTile', 11: 'StartBattle', 12: 'EnterPlace',
               13: 'Condition', 14: 'Action', 15: 'Dice100', 16: 'Conversation', 17: 'PrintText', 18: 'Create',
               19: 'Decision', 20: 'ChangeMusic', 21: 'Exit', 22: 'Spawn', 23: 'Nop', 24: 'RemovePartyMember'}
WALK = 0x100
BLOCK = 0x80
USE_BACK = 0x20


def read_tileset(folder, index):
    data = open(os.path.join(folder, 'Icon_data.amb', '%03d' % index), 'rb').read()
    count = struct.unpack('>H', data[:2])[0]
    flags = [struct.unpack('>I', data[2 + 8 * i:6 + 8 * i])[0] for i in range(count)]
    return flags


def read_labdata(folder, index):
    """(object blocks, wall blocks): for each object/wall of the labdata whether it blocks walking."""
    for name in ('2Lab_data.amb', '3Lab_data.amb'):
        path = os.path.join(folder, name, '%03d' % index)
        if os.path.exists(path) and os.path.getsize(path) > 0:
            d = open(path, 'rb').read()
            break
    else:
        raise SystemExit('labdata %d not found' % index)
    pos = 8
    n_objects = struct.unpack('>H', d[pos:pos + 2])[0]
    pos += 2
    objects = []
    for i in range(n_objects):
        pos += 2
        subs = [struct.unpack('>hhhH', d[pos + 8 * k:pos + 8 * k + 8])[3] for k in range(8)]
        pos += 64
        objects.append([s for s in subs if s])
    n_infos = struct.unpack('>H', d[pos:pos + 2])[0]
    pos += 2
    infos = []
    for i in range(n_infos):
        infos.append(struct.unpack('>I', d[pos:pos + 4])[0])
        pos += 14
    object_blocks = [any(infos[s - 1] & BLOCK for s in subs) for subs in objects]
    n_walls = struct.unpack('>H', d[pos:pos + 2])[0]
    pos += 2
    wall_blocks = []
    for i in range(n_walls):
        flags = struct.unpack('>I', d[pos:pos + 4])[0]
        n_overlays = d[pos + 7]
        pos += 8 + 6 * n_overlays
        wall_blocks.append(bool(flags & BLOCK) or not (flags & WALK))
    return object_blocks, wall_blocks


def map_file(folder, number):
    for name in ('1Map_data.amb', '2Map_data.amb', '3Map_data.amb'):
        path = os.path.join(folder, name, '%03d' % number)
        if os.path.exists(path) and os.path.getsize(path) > 0:
            return open(path, 'rb').read()
    raise SystemExit('map %d not found' % number)


def tile_char(flags, back, front):
    """Walkable (on foot), like Tileset.AllowMovement of the remake."""
    def flag(index):
        return flags[index - 1] if 0 < index <= len(flags) else 0
    if front == 0:
        f = flag(back)
    elif back == 0:
        f = flag(front)
    else:
        f = flag(back) if flag(front) & USE_BACK else flag(front)
    return not (f & BLOCK) and bool(f & WALK)


def load_map(folder, number):
    """The map as a dict: width, height, walk[y][x] (bool), event[y][x] (chain, 0 = none), starts, gotos, ..."""
    d = map_file(folder, number)
    flags_word, mtype, music, width, height, tileset = struct.unpack('>HBBBBB', d[:7])
    chars = []
    pos = 12
    for i in range(32):
        idx, coll, tf, ev, gfx, tflags = struct.unpack('>BBBBHI', d[pos:pos + 10])
        pos += 10
        if idx == 0:
            break
        chars.append((idx, tf, ev, gfx))
    pos = 332
    tiles = []
    if mtype == 2:      # 2D: back tile, event, front tile
        flags = read_tileset(folder, tileset)
        for y in range(height):
            row = []
            for x in range(width):
                back, ev, front = struct.unpack('>BBH', d[pos:pos + 4])
                pos += 4
                row.append((back, ev, front))
            tiles.append(row)
        walk = [[tile_char(flags, tiles[y][x][0], tiles[y][x][2]) for x in range(width)] for y in range(height)]
    else:               # 3D: block (1-100 object, 101-254 wall, 255 border), event
        object_blocks, wall_blocks = read_labdata(folder, tileset)
        walk = []
        for y in range(height):
            row, wrow = [], []
            for x in range(width):
                block, ev = d[pos], d[pos + 1]
                pos += 2
                row.append((block, ev, 0))
                if block == 0:
                    wrow.append(True)
                elif block <= 100:
                    wrow.append(not (block <= len(object_blocks) and object_blocks[block - 1]))
                elif block < 255:
                    wrow.append(not (block - 100 <= len(wall_blocks) and wall_blocks[block - 101]))
                else:
                    wrow.append(False)
            tiles.append(row)
            walk.append(wrow)
    n_chains = struct.unpack('>H', d[pos:pos + 2])[0]
    pos += 2
    chains = list(struct.unpack('>%dH' % n_chains, d[pos:pos + 2 * n_chains]))
    pos += 2 * n_chains
    n_events = struct.unpack('>H', d[pos:pos + 2])[0]
    pos += 2
    events = [d[pos + 12 * i:pos + 12 * (i + 1)] for i in range(n_events)]
    pos += 12 * n_events
    # character positions (simplified: the first position of each)
    starts = []
    for idx, tf, ev, gfx in chars:
        ctype = tf & 3
        cflags = tf >> 2
        if ctype == 2 or cflags & 0x01:      # monster or random movement: only the start position
            starts.append((d[pos], d[pos + 1]))
            pos += 2
        elif cflags & 0x10:                  # hour movement: 12 positions
            starts.append((d[pos], d[pos + 1]))
            pos += 2 * 12
        else:                                # a position every 5 minutes
            starts.append((d[pos], d[pos + 1]))
            pos += 2 * 288
    try:
        n_goto = struct.unpack('>H', d[pos:pos + 2])[0]
        pos += 2
        gotos = []
        for i in range(n_goto):
            gx, gy, gdir, gbit = d[pos], d[pos + 1], d[pos + 2], d[pos + 3]
            name = d[pos + 4:pos + 20].split(b'\0')[0].decode('latin-1')
            gotos.append((gx, gy, gdir, gbit, name))
            pos += 20
    except (struct.error, IndexError):
        gotos = []

    event = [[tiles[y][x][1] for x in range(width)] for y in range(height)]
    return dict(number=number, type=mtype, width=width, height=height, tileset=tileset, music=music, palette=d[9],
                world=d[10], walk=walk, event=event, chains=chains, events=events, chars=chars, starts=starts,
                gotos=gotos)


def main():
    folder, number = sys.argv[1], int(sys.argv[2])
    m = load_map(folder, number)
    width, height, chains, events, chars, starts, gotos = (m['width'], m['height'], m['chains'], m['events'],
                                                          m['chars'], m['starts'], m['gotos'])
    print('map %d: type %d, %dx%d, tileset %d, music %d, palette %d, world %d' % (number, m['type'], width, height,
                                                                              m['tileset'], m['music'], m['palette'],
                                                                              m['world']))

    def chain_char(c):
        return '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'[c] if c < 62 else '*'

    start_set = {(x, y): i for i, (x, y) in enumerate(starts)}
    print('    ' + ''.join(str((x + 1) // 10 % 10) for x in range(width)))
    print('    ' + ''.join(str((x + 1) % 10) for x in range(width)))
    for y in range(height):
        line = ''
        for x in range(width):
            ev = m['event'][y][x]
            if (x + 1, y + 1) in start_set:
                line += '@'
            elif ev:
                line += chain_char(ev)
            else:
                line += '.' if m['walk'][y][x] else '#'
        print('%3d %s' % (y + 1, line))
    print('event chains (1-based): ' + ', '.join('%d->%d' % (i + 1, c) for i, c in enumerate(chains)))
    for i, e in enumerate(events):
        nxt = struct.unpack('>H', e[10:12])[0]
        print('event %d: %-14s %s next %s' % (i, EVENT_TYPES.get(e[0], e[0]), ' '.join('%02x' % b for b in e[1:10]),
                                              nxt if nxt != 0xffff else '-'))
    for i, (idx, tf, ev, gfx) in enumerate(chars):
        print('character %d: index %d, type %d, flags %02x, event %d, start %s' % (i + 1, idx, tf & 3, tf >> 2, ev,
                                                                                   starts[i]))
    for g in gotos:
        print('goto point: %d,%d dir %d bit %d %s' % g)


if __name__ == '__main__':
    main()
