"""Section tests of the speedrun script: each section starts from its savegame and must reach the log tag at its end
within a time limit. The sections end right after the savegame the next one starts from, so a test pass in order also
renews all savegames.

Usage: python tests.py [<script.txt>] [--from <section>] [--only <section>]

Sections (name: savegame / start label -> log tag (hex), time limit in seconds of game time):
"""
import argparse
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

# name, savegame slot (None: new game), start label, end log tag (hex), limit (seconds)
SECTIONS = [
    ('house',       None, None,          '09', 150),   # new game -> Spannenberg, battle order (savegame 1)
    ('spannenberg', 1,    'spannenberg', '0b', 120),   # alley, sign, staff -> Thalion office (savegame 2)
    ('office',      2,    'office',      '10', 120),   # Chris and Netsrak join (savegame 3)
    ('recruited',   3,    'recruited',   '11', 150),   # options, chests, lantern (savegame 8)
    ('chests_done', 8,    'chests_done', '13', 90),    # to the sign, goto point city gates (savegame 4)
    ('healer',      8,    'chests_done', '42', 240),   # TAR: house of healers, bandit, cellar, spiders, Tar (savegame 9)
    ('tar',         9,    'tar',         '13', 90),    # TAR: out of the cellar and the house, city gates (savegame 4)
    ('gate',        4,    'gate',        '17', 90),    # flute, eagle, temple entrance (savegame 5)
    ('temple',      5,    'temple',      '1b', 90),    # lantern, harp, machine room (savegame 6)
    ('machine',     6,    'machine',     '34', 300),   # machine battle, exit (outro)
]


TAR_ONLY = ('healer', 'tar')     # with --tar instead of chests_done


def run_section(script, name, slot, label, tag, limit, defines=()):
    cmd = [sys.executable, os.path.join(HERE, 'run.py'), script, '--success', tag, '--limit', str(limit),
           '--attempts', '1', '--seconds', str(limit + 60), '--tail', '3', '--fail', 'ab']
    cmd += ['--define=' + d for d in defines]
    if slot is not None:
        cmd += ['--load', str(slot), '--start', label]
    out = subprocess.run(cmd, cwd=HERE, capture_output=True, text=True, errors='replace').stdout
    m = re.search(r'complete after (\d+):(\d+)', out)
    seconds = int(m.group(1)) * 60 + int(m.group(2)) if m else None
    # the last log lines (without heartbeats) show where a failed section stopped
    lines = [l for l in out.splitlines() if re.match(r'^[0-9a-f]{4} ', l) and not l.startswith('00ff')]
    return seconds, lines[-3:]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('script', nargs='?', default=os.path.join(HERE, 'speedrun.txt'))
    ap.add_argument('--from', dest='start')
    ap.add_argument('--only')
    ap.add_argument('--tar', action='store_true', help='the route with Tar (house of healers)')
    args = ap.parse_args()
    sections = [s for s in SECTIONS if (s[0] in TAR_ONLY) == args.tar or s[0] not in TAR_ONLY + ('chests_done',)]
    names = [s[0] for s in sections]
    todo = sections
    if args.only:
        todo = [s for s in sections if s[0] == args.only]
    elif args.start:
        todo = sections[names.index(args.start):]
    for name, slot, label, tag, limit in todo:
        seconds, last = run_section(args.script, name, slot, label, tag, limit, ['TAR'] if args.tar else [])
        if seconds is None:
            print('%-12s FAILED (tag %s not reached within %d s)' % (name, tag, limit))
            for line in last:
                print('             ' + line)
            break       # the later sections need the savegame of this one
        print('%-12s ok   (tag %s after %d:%02d)' % (name, tag, seconds // 60, seconds % 60), flush=True)


if __name__ == '__main__':
    main()
