#!/usr/bin/env python3
# A random session for the event editor (commands with random answers, saved to @OUT@ at the end), for the tests that
# compare the editor with the original.
#
#   python3 genfuzz.py <seed> <output file>
import random, sys
seed = int(sys.argv[1]); out = sys.argv[2]
r = random.Random(seed)
cmds = ['list', 'events', 'short', 'summary', 'chain', 'add', 'edit', 'remove', 'copy', 'copychain', 'copyrange',
        'connect', 'disconnect', 'connections', 'reorder', 'graph', 'help', 'usage', '']
weights = [2, 2, 1, 1, 3, 4, 5, 4, 3, 3, 2, 4, 3, 3, 1, 3, 1, 1, 1]
lines = []
def answer():
    k = r.random()
    if k < 0.35: return str(r.randint(0, 3))
    if k < 0.55: return '%x' % r.randint(0, 0x20)
    if k < 0.65: return str(r.randint(0, 40))
    if k < 0.72: return ''
    if k < 0.78: return '0x%x' % r.randint(0, 0x30)
    if k < 0.82: return '$%x' % r.randint(0, 0x30)
    if k < 0.86: return str(r.randint(0, 65535))
    if k < 0.9: return 'ffff'
    return str(r.randint(0, 255))
for i in range(r.randint(5, 25)):
    c = r.choices(cmds, weights)[0]
    if c in ('chain', 'edit', 'remove', 'copy', 'copychain', 'copyrange', 'connect', 'disconnect', 'connections', 'graph') and r.random() < 0.6:
        c += ' %x' % r.randint(0, 0x30)
    if c == 'help' and r.random() < 0.7:
        c += ' ' + r.choice(cmds)
    lines.append(c)
    for j in range(r.randint(0, 12)):
        lines.append(answer())
lines += [''] * 12 + ['save', '1', '@OUT@', 'exit']
open(out, 'w').write('\n'.join(lines) + '\n')
