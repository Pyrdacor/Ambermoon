#!/usr/bin/env python3
"""Writes the data of the intro and the extro for the Falcon version (port_data.py --falcon): the data hunks of
Ambermoon_intro, Fantasy_intro and Ambermoon_extro as binary files, their first data hunks as includes (they have
pointers), and the Sonic Arranger modules of Intro_music and Extro_music."""
import os
import struct
import tempfile

from dsp_asm import assemble
from hunks import deplode, hunks

MODULE = 0x197c    # in Intro_music and Extro_music : the replay of the Amiga, then the module


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


def write(folder, intro, music, fantasy, extro, extro_music):
    os.makedirs(folder, exist_ok=True)
    assemble(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'KERNEL', 'DSP_MIX.ASM'),
             os.path.join(folder, 'DSP_MIX.BIN'))
    H = loaded(intro)
    for i in (2, 3, 4):
        open(os.path.join(folder, 'INTRO_H%d.BIN' % i), 'wb').write(H[i]['data'])
    open(os.path.join(folder, 'INTRO_H1.I'), 'w').write(include(H[1], 'Intro'))
    F = deplode(loaded(fantasy))
    open(os.path.join(folder, 'FANT_H1.BIN'), 'wb').write(F[1]['data'])
    open(os.path.join(folder, 'INTRO_MU.BIN'), 'wb').write(module(music, 'Intro_music'))
    E = deplode(loaded(extro))      # (hunk 3 : the end of a copper list, then BSS)
    open(os.path.join(folder, 'EXTRO_H1.I'), 'w').write(include(E[1], 'Extro'))
    open(os.path.join(folder, 'EXTRO_H2.BIN'), 'wb').write(E[2]['data'])
    open(os.path.join(folder, 'EXTRO_MU.BIN'), 'wb').write(module(extro_music, 'Extro_music'))
