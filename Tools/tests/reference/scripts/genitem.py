# genitem.py <seed> <exe 0/1>: a random session of the item editor (commands with random answers), saved at the end
import random, sys
r = random.Random(int(sys.argv[1])); exe = sys.argv[2] == '1'
out = []
def num(lo=-5, hi=420):
    k = r.random()
    if k < 0.12: return ''
    if k < 0.17: return r.choice(['x', 'abc', ' 7 ', '+3', '-0', '99999999999', '0x10'])
    if k < 0.25: return str(r.randint(-300, 70000))
    return str(r.randint(lo, hi))
def value():
    k = r.random()
    if k < 0.35: return ''
    if k < 0.45: return r.choice(['x', '-1', '-5', '-128', '-129', '256', '65535', '65536', ' 12', 'ff'])
    if k < 0.75: return str(r.randint(0, 25))
    return str(r.randint(0, 300))
def hexvalue():
    k = r.random()
    if k < 0.3: return ''
    if k < 0.4: return r.choice(['zz', 'ffffffff', '100', '-1', ' 1'])
    return '%x' % r.randint(0, 0x7ff)
def name():
    k = r.random()
    if k < 0.15: return ''
    if k < 0.2: return '   '
    return r.choice(['Sword', 'NEW ITEM', 'a very long item name beyond', 'Ölkanne', 'x', 'Schwert der Macht', ' lead', 'trail  '])
# the values of an item: (kind) b = number, e = enum index, f = flags hex
VALUES = 'b e e b e b b b b e b e b b b e e e e b b b b e b b b b b b b b f f f b b'.split()
def edit_values():
    for kind in VALUES:
        if r.random() < 0.03:  # stop early (the input of an aborted edit is read as commands)
            return
        out.append(hexvalue() if kind == 'f' else value())
    out.append(name())
for _ in range(r.randint(3, 14)):
    c = r.choice(['a', 'a', 'e', 'e', 'e', 'r', 'i', 'p', 'p', 'f', 'h', 'x', 'ADD', 'Edit Item', ''])
    out.append(c)
    lc = c.lower()
    if lc in ('a', 'add'):
        edit_values()
    elif lc in ('e', 'edit item'):
        out.append(num())
        edit_values()
    elif lc == 'r':
        out.append(num())
    elif lc == 'p':
        out.append(num())
    elif lc == 'f':
        out.append(r.choice(['sword', 'POTION', 'key', '', '  ', 'ö', 'zzz', 'new']))
out.append('s')
if exe:
    out.append(r.choice(['', '0', '1', '5', 'x']))
out.append('i')
out.extend(['q'] * 40)
print('\n'.join(out))
