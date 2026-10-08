# genlab.py <seed>: a random session of the labdata editor
import random, sys
r = random.Random(int(sys.argv[1]))
out = []
def value():
    k = r.random()
    if k < 0.45: return str(r.randint(0, 20))
    if k < 0.55: return str(r.randint(-40000, 70000))
    if k < 0.65: return r.choice(['1', '0', 'y', 'yes', 'no', 'true', 'Y'])
    if k < 0.75: return '0x%08x' % (r.choice([0, 1, 2, 8, 0x10, 0x80, 0x100, 0x200, 0x400]) | r.choice([0, 0x80, 0x100, 0x1000, 0x10000000]))
    if k < 0.8: return r.choice(['', ' ', 'abc', '$12', '0X10', '19', '255', '256', '65535'])
    if k < 0.85: return '%x' % r.choice([0x82, 0x300, 0x7, 0x10])
    return str(r.randint(1, 8))
for _ in range(r.randint(3, 14)):
    c = r.choice(['h', 'w', 'o', 'd', 'i', 'a', 'a', 'e', 'e', 'e', 'x', 'x', 'HELP', '', 'foo', 's', 'help', 'Walls'])
    out.append(c)
    if c in ('a', 'e', 'x'):
        out.append(r.choice(['0', '1', '2', '2', '1', '0', '9']))
    for _ in range(r.randint(0, 40) if c in ('a', 'e', 'x', 's') else r.randint(0, 3)):
        out.append(value())
out += ['s', '1'] + ['q'] * 60
print('\n'.join(out))
