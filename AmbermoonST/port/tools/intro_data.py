#!/usr/bin/env python3
"""The data of the intro, the fairy and the extro (port_data.py, KERNEL/INTRO_COMMON.S) : the first data hunks of
Ambermoon_intro and Ambermoon_extro as includes (they have pointers), INTRO.I (the sizes of the data), the music of
the intro (INTRO_MU.BIN) and the data files which the program loads (Intro_data : the data hunks 2-4 of
Ambermoon_intro, Fantasy_data : the data hunk of Fantasy_intro).

The Falcon gets the Sonic Arranger module of Intro_music, the extro (EXTRO_H1.I, EXTRO_H2.BIN and the module of
Extro_music) and the data as they are. The ST gets the two songs of the intro module for the YM2149 (port/MUSIC,
sa_to_st.py : INTRO0.BIN the intro, INTRO1.BIN the main menu), each its size (.l) and the data, and the data of the
fairy with 16 colours (fantasy_st.py)."""
import os
import struct
import tempfile

import fantasy_st
import intro_st
from hunks import deplode, hunks

MODULE = 0x197c    # in Intro_music and Extro_music : the replay of the Amiga, then the module
SONGS = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'MUSIC')


def loaded(data):
    with tempfile.NamedTemporaryFile(delete=False) as f:
        f.write(data)
    H = hunks(f.name)
    os.unlink(f.name)
    return H


def include(h, name):
    """A data hunk with pointers as an include."""
    b, p, out = h['data'], 0, []
    while p < len(b):
        if p in h['relocs']:
            hh, off = h['relocs'][p]
            out.append('\tdc.l\t%s_h%d+$%x' % (name, hh, off))
            p += 4
        else:
            out.append('\tdc.b\t$%02x' % b[p])
            p += 1
    return '\n'.join(out) + '\n'


def module(music, name):
    assert struct.unpack_from('>I', music, MODULE)[0] == 0x28, name + ' : no module'
    return music[MODULE:]


def st_songs():
    out = b''
    for s in (0, 1):
        d = open(os.path.join(SONGS, 'INTRO%d.BIN' % s), 'rb').read()
        out += struct.pack('>I', len(d)) + d + b'\0' * (len(d) & 1)
    return out


def write(folder, files, falcon):
    """The includes into folder; returns the data files for DATA {name : content}"""
    os.makedirs(folder, exist_ok=True)
    H = loaded(files['Ambermoon_intro'])
    for i in (2, 3, 4):
        assert not H[i]['relocs'] and len(H[i]['data']) == 4 * H[i]['mem'], 'Ambermoon_intro : hunk %d' % i
    open(os.path.join(folder, 'INTRO_H1.I'), 'w').write(include(H[1], 'Intro'))
    fantasy = deplode(loaded(files['Fantasy_intro']))[1]['data']
    size, offsets = len(fantasy), {}
    if not falcon:
        fantasy, size, offsets = fantasy_st.convert(fantasy)
    with open(os.path.join(folder, 'INTRO.I'), 'w') as f:
        f.write('; Made by port/tools/intro_data.py : the sizes of the data files\n')
        for i in (2, 3, 4):
            f.write('Intro_h%d_size\tEQU\t%d\n' % (i, len(H[i]['data'])))
        f.write('Fant_h1_size\tEQU\t%d\n' % size)
        f.write('Fantasy_data_size\tEQU\t%d\n' % len(fantasy))
        for name, offset in offsets.items():         # (the ST : the data in the format of its screen)
            f.write('%s\tEQU\tFant_h1+%d\n' % (name, offset))
    if falcon:
        open(os.path.join(folder, 'INTRO_MU.BIN'), 'wb').write(module(files['Intro_music'], 'Intro_music'))
        E = deplode(loaded(files['Ambermoon_extro']))      # (hunk 3 : the end of a copper list, then BSS)
        open(os.path.join(folder, 'EXTRO_H1.I'), 'w').write(include(E[1], 'Extro'))
        open(os.path.join(folder, 'EXTRO_H2.BIN'), 'wb').write(E[2]['data'])
        open(os.path.join(folder, 'EXTRO_MU.BIN'), 'wb').write(module(files['Extro_music'], 'Extro_music'))
    else:
        open(os.path.join(folder, 'INTRO_MU.BIN'), 'wb').write(st_songs())
    out = {'Intro_data': H[2]['data'] + H[3]['data'] + H[4]['data'], 'Fantasy_data': fantasy}
    if falcon:
        open(os.path.join(folder, 'INTRO_ST.I'), 'w').write('Intro_st_size\tEQU\t0\n')
    else:                                       # (the intro made anew for the ST)
        with tempfile.NamedTemporaryFile(delete=False) as f:
            f.write(files['Ambermoon_intro'])
        data, inc = intro_st.build(f.name)
        os.unlink(f.name)
        open(os.path.join(folder, 'INTRO_ST.I'), 'w').write(inc)
        out['Intro_st'] = data
    return out
