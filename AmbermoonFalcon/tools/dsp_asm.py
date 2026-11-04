#!/usr/bin/env python3
"""A small assembler for the DSP 56001 (vasm has no 56k CPU) : the instructions of KERNEL/DSP_MIX.ASM, one operation in
a line, no parallel moves, a nop behind a move into an address register. The result : the 512 words of the bootstrap of the DSP, 3 bytes each.

    dsp_asm.py <source> <out.bin>
"""
import re
import sys

COND = dict(hs=0, cc=0, ge=1, ne=2, pl=3, nn=4, ec=5, lc=6, gt=7, cs=8, lo=8, lt=9, eq=10, mi=11, nr=12, es=13, ls=14,
            le=15)
REG = dict(x0=4, x1=5, y0=6, y1=7, a0=8, b0=9, a2=10, b2=11, a1=12, b1=13, a=14, b=15)
REG.update({'r%d' % i: 16 + i for i in range(8)})
REG.update({'n%d' % i: 24 + i for i in range(8)})
ALU1 = dict(clr=0x13, tst=0x03, lsl=0x33, lsr=0x23, asl=0x32, asr=0x22, neg=0x36, rnd=0x11)
JJJ = dict(x0=4, y0=5, x1=6, y1=7)
JJ = dict(x0=0, y0=1, x1=2, y1=3)
QQQ = {('x0', 'x0'): 0, ('y0', 'y0'): 1, ('x1', 'x0'): 2, ('y1', 'y0'): 3, ('x0', 'y1'): 4, ('y0', 'x0'): 5,
       ('x1', 'y0'): 6, ('y1', 'x1'): 7}


def alu2(m, s, d):
    """add, sub, cmp, tfr, and, or : the byte of the operation"""
    dbit = {'a': 0, 'b': 1}[d]
    other = (s == ('b' if d == 'a' else 'a'))
    last = dict(add=0, sub=4, cmp=5, tfr=1)
    if m in ('add', 'sub'):
        j = 1 if other else {'x': 2, 'y': 3}.get(s, JJJ.get(s))
    elif m in ('cmp', 'tfr'):
        j = 0 if other else JJJ[s]
    elif m == 'and':
        return 0x40 | JJ[s] << 4 | dbit << 3 | 6
    elif m == 'or':
        return 0x40 | JJ[s] << 4 | dbit << 3 | 2
    return j << 4 | dbit << 3 | last[m]


def ea(text):
    """The addressing : MMMRRR, and a word behind the instruction"""
    m = re.fullmatch(r'\(r(\d)\)\+', text)
    if m:
        return 0b011000 | int(m[1]), None
    m = re.fullmatch(r'\(r(\d)\)', text)
    if m:
        return 0b100000 | int(m[1]), None
    m = re.fullmatch(r'\(r(\d)\+n(\d)\)', text)
    if m:
        assert m[1] == m[2], text
        return 0b101000 | int(m[1]), None
    return 0b110000, text


class Asm:
    def __init__(self, path):
        self.lines = []
        self.sym = {}
        for line in open(path):
            line = line.split(';')[0].strip()
            if not line:
                continue
            m = re.match(r'^([A-Za-z_]\w*)\s*=\s*(.+)$', line)
            if m:
                self.sym[m[1]] = self.value(m[2], {})
                continue
            m = re.match(r'^([A-Za-z_]\w*):\s*(.*)$', line)
            if m:
                self.lines.append(('label', m[1]))
                line = m[2]
                if not line:
                    continue
            self.lines.append(('op', line))

    def value(self, text, labels=None):
        text = text.strip().lstrip('#>')
        text = text.replace('$', '0x')
        names = dict(self.sym)
        names.update(labels if labels is not None else {})
        return eval(text, {'__builtins__': {}}, names)

    def operands(self, text):
        return [x.strip() for x in text.split(',')]

    def one(self, op, labels, pc):
        """The words of an instruction (with labels None : only the number of them)"""
        v = (lambda t: self.value(t, labels)) if labels is not None else (lambda t: 0)
        parts = op.split(None, 1)
        m = parts[0].lower()
        o = self.operands(parts[1]) if len(parts) > 1 else []
        if m == 'nop':
            return [0]
        if m == 'rts':
            return [0x00000c]
        if m == 'rti':
            return [0x000004]
        if m in ('ori', 'andi'):
            assert o[1] == 'mr', op
            return [v(o[0]) << 8 | (0xf8 if m == 'ori' else 0xb8)]
        if m == 'jmp':
            return [0x0c0000 | v(o[0])]
        if m == 'jsr':
            return [0x0d0000 | v(o[0])]
        if m in ('jclr', 'jset'):
            pp = v(o[1][2:]) & 0x3f
            return [0x0a8000 | pp << 8 | (0x80 if m == 'jclr' else 0xa0) | v(o[0]), v(o[2])]
        if m == 'do':
            return [0x06c000 | REG[o[0]] << 8, (v(o[1]) - 1) & 0xffff]
        if m[0] == 'j' and m[1:] in COND:
            return [0x0e0000 | COND[m[1:]] << 12 | v(o[0])]
        if m == 'rep':
            if o[0][0] == '#':
                n = v(o[0])
                return [0x060000 | (n & 0xff) << 8 | 0xa0 | n >> 8]
            return [0x06c020 | REG[o[0]] << 8]
        if m == 'movep':
            assert o[0].startswith('#>') and o[1].startswith('x:'), op
            return [0x08f480 | v(o[1][2:]) & 0x3f, v(o[0]) & 0xffffff]
        if m in ALU1:
            return [0x200000 | ALU1[m] | {'a': 0, 'b': 8}[o[0]]]
        if m in ('add', 'sub', 'cmp', 'tfr', 'and', 'or'):
            return [0x200000 | alu2(m, o[0], o[1])]
        if m == 'mpy':
            q = QQQ.get((o[0], o[1]), QQQ.get((o[1], o[0])))
            return [0x200000 | 0x80 | q << 4 | {'a': 0, 'b': 8}[o[2]]]
        if m == 'move':
            out = self.move(o, v)
            if re.fullmatch(r'[rn]\d', o[-1]):      # (the 56001 : a new address register counts one instruction later)
                out.append(0)
            return out
        raise SystemExit('unknown : ' + op)

    def move(self, o, v):
        if len(o) == 1:                                     # move (r4)+ ; move (r5)+n5
            t = re.fullmatch(r'\(r(\d)\)\+(n\d)?', o[0])
            return [0x204000 | (0b011 if not t[2] else 0b001) << 11 | int(t[1]) << 8]
        s, d = o
        if s.startswith('#>'):
            r = REG[d]
            return [0x400000 | (r >> 3) << 20 | (r & 7) << 16 | 0xc000 | 0b110100 << 8, v(s) & 0xffffff]
        for mem, reg, write in ((s, d, 1), (d, s, 0)):
            if mem[:2] in ('x:', 'y:'):
                r = REG[reg]
                code, word = ea(mem[2:])
                out = [0x400000 | (r >> 3) << 20 | (1 if mem[0] == 'y' else 0) << 19 | (r & 7) << 16 | write << 15 |
                       0x4000 | code << 8]
                if word is not None:
                    out.append(v(word) & 0xffff)
                return out
        return [0x200000 | REG[s] << 5 << 8 | REG[d] << 8]

    def build(self):
        labels = {}
        for final in (False, True):
            pc = 0
            words = {}
            for kind, x in self.lines:
                if kind == 'label':
                    labels[x] = pc
                elif x.split()[0] == 'org':
                    pc = self.value(x.split(None, 1)[1])
                else:
                    w = self.one(x, labels if final else None, pc)
                    for i, y in enumerate(w):
                        words[pc + i] = y
                    pc += len(w)
        if max(words) >= 512:
            raise SystemExit('too long : %d words' % (max(words) + 1))
        return [words.get(i, 0) for i in range(512)], max(words) + 1


def assemble(src, out):
    words, used = Asm(src).build()
    with open(out, 'wb') as f:
        for w in words:
            f.write(bytes(((w >> 16) & 255, (w >> 8) & 255, w & 255)))
    return used


if __name__ == '__main__':
    print(assemble(sys.argv[1], sys.argv[2]), 'words')
