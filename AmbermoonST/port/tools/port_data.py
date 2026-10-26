#!/usr/bin/env python3
"""Prepares the game data for the port (see PORT.md).

    port_data.py <hd folder> <filemap include>

The original files of the German version 1.20 (Disks/German/ambermoon_german_1.20_extracted.zip) with the
fixed files of Disks/Bugfixing/German/Amberfiles on top are copied unchanged into <hd folder>/DATA. The ST has
8.3 file names, so every file gets a short name; the table long name -> short name is written as an include
file for the ST kernel (File_map in port/KERNEL/LIBS.S), which translates the names the original code uses.
"""
import os
import sys
import zipfile

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
ZIP = os.path.join(ROOT, 'Disks', 'German', 'ambermoon_german_1.20_extracted.zip')
FIXED = os.path.join(ROOT, 'Disks', 'Bugfixing', 'German', 'Amberfiles')
SKIP = {'AM2_CPU', 'Ambermoon_intro', 'Ambermoon_extro', 'Fantasy_intro', 'Intro_music', 'Extro_music', 'Keymap'}


def short_names(names):
    """8.3 names, unique per folder : the first 8 characters of the name (without '_'), on a collision the
    first 6 and a number."""
    result = {}
    used = set()
    for name in sorted(names):
        parts = name.split('/')
        out = []
        for i, p in enumerate(parts):
            base, _, ext = p.partition('.')
            base = base.replace('_', '').upper()
            ext = ext.replace('_', '').upper()[:3]
            folder = '\\'.join(out)
            cand = base[:8] + ('.' + ext if ext else '')
            n = 1
            last = i == len(parts) - 1
            while last and (folder, cand) in used:
                cand = f'{base[:6]}{n:02}'[:8] + ('.' + ext if ext else '')
                n += 1
            if last:
                used.add((folder, cand))
            out.append(cand)
        result[name] = '\\'.join(out)
    return result


def main():
    hd, inc = sys.argv[1], sys.argv[2]
    files = {}
    with zipfile.ZipFile(ZIP) as z:
        for n in z.namelist():
            if n.endswith('/') or not n.startswith('Amberfiles/'):
                continue
            files[n[len('Amberfiles/'):]] = z.read(n)
    for dp, _, fn in os.walk(FIXED):
        for f in fn:
            p = os.path.join(dp, f)
            files[os.path.relpath(p, FIXED).replace(os.sep, '/')] = open(p, 'rb').read()
    files = {k: v for k, v in files.items() if k.split('/')[-1] not in SKIP}
    short = short_names(files)
    data = os.path.join(hd, 'DATA')
    for name, content in files.items():
        p = os.path.join(data, *short[name].split('\\'))
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, 'wb').write(content)
    with open(inc, 'w') as f:
        f.write('; Made by port/tools/port_data.py : Amiga file name, ST file name (in DATA\\)\n')
        f.write('File_map:\n')
        for name in sorted(files):
            st = short[name].replace('\\', '",92,"')         # (no escapes in the strings)
            f.write(f'\tdc.b\t"{name}",0,"{st}",0\n')
        f.write('\tdc.b\t0\n\teven\n')
    print(f'{len(files)} files in {data}')


if __name__ == '__main__':
    main()
