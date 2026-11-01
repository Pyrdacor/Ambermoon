#!/usr/bin/env python3
"""Writes the data of the intro for the Falcon version (port_data.py --falcon): the data hunks of Ambermoon_intro
as binary files, its first data hunk as an include (it has pointers), and the Sonic Arranger module of Intro_music."""
import os
import struct
import tempfile

from hunks import hunks

MODULE = 0x197c    # in Intro_music : the replay of the Amiga, then the module


def write(folder, intro, music):
    os.makedirs(folder, exist_ok=True)
    with tempfile.NamedTemporaryFile(delete=False) as f:
        f.write(intro)
    H = hunks(f.name)
    os.unlink(f.name)
    for i in (2, 3, 4):
        open(os.path.join(folder, 'INTRO_H%d.BIN' % i), 'wb').write(H[i]['data'])
    h = H[1]
    b, p, out = h['data'], 0, []
    while p < len(b):
        if p in h['relocs']:
            hh, off = h['relocs'][p]
            out.append('\tdc.l\tIntro_h%d+$%x' % (hh, off))
            p += 4
        else:
            out.append('\tdc.b\t$%02x' % b[p])
            p += 1
    open(os.path.join(folder, 'INTRO_H1.I'), 'w').write('\n'.join(out) + '\n')
    assert struct.unpack_from('>I', music, MODULE)[0] == 0x28, 'Intro_music : no module'
    open(os.path.join(folder, 'INTRO_MU.BIN'), 'wb').write(music[MODULE:])
