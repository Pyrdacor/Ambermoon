#!/usr/bin/env python3
"""Builds the AmigaOS keymaps e (Spanish), cz (Czech) and pl (Polish, programmer layout) for the boot disk
(Disks/BootDisk/Devs/Keymaps) from the British keymap gb that is there already.

A keymap is a LoadSeg()able file: one data hunk with a KeyMapNode (Node + KeyMap: 8 pointers to the key types,
key maps, capsable and repeatable bits of the low keys 0x00-0x3F and the high keys 0x40-0x77), the tables, the
descriptors of dead keys and strings, and the name. The script reads gb into this structure, changes the keys of
the main block and writes the new files. The letters keep the dead key tables of gb (´ ` ^ ~ ¨ = dead keys 1-5).

Only ISO-8859-1 characters exist in AmigaOS keymaps: Czech and Polish letters that are not in it (ě š č ř ž ů,
ą ć ę ł ń ś ź ż) give their base letter (the game removes the marks of the letters of these languages anyway).

  python3 Translations/make_keymaps.py           # writes e, cz and pl
  python3 Translations/make_keymaps.py --check   # only checks that gb is written back byte for byte"""
import os, struct, sys

HERE = os.path.dirname(os.path.abspath(__file__))
KEYMAPS = os.path.normpath(os.path.join(HERE, '..', 'Disks', 'BootDisk', 'Devs', 'Keymaps'))

KCF_SHIFT, KCF_ALT, KCF_CONTROL, KCF_DEAD, KCF_STRING, KCF_NOP = 1, 2, 4, 0x20, 0x40, 0x80
DPF_MOD, DPF_DEAD = 1, 8


def u32(b, o):
    return struct.unpack('>I', b[o:o + 4])[0]


class Keymap:
    @staticmethod
    def read(path):
        d = open(path, 'rb').read()
        assert u32(d, 0) == 0x3F3
        o = 4
        while u32(d, o):
            o += 4 + 4 * u32(d, o)
        o += 4
        first, last = u32(d, o + 4), u32(d, o + 8)
        o += 12 + 4 * (last - first + 1)
        assert u32(d, o) == 0x3E9
        n = u32(d, o + 4)
        code = d[o + 8:o + 8 + 4 * n]
        k = Keymap()
        p = [u32(code, 0xE + 4 * i) for i in range(8)]
        name_ptr = u32(code, 0xA)
        k.name = code[name_ptr:code.index(b'\0', name_ptr)].decode()
        k.lotypes, k.lomap, k.locaps, k.lorep, k.hitypes, k.himap, k.hicaps, k.hirep = p
        k.types = list(code[p[0]:p[0] + 64]) + list(code[p[4]:p[4] + 56])
        k.caps = list(code[p[2]:p[2] + 8]) + list(code[p[6]:p[6] + 7])
        k.rep = list(code[p[3]:p[3] + 8]) + list(code[p[7]:p[7] + 7])
        entries = [code[p[1] + 4 * i:p[1] + 4 * i + 4] for i in range(64)] + \
                  [code[p[5] + 4 * i:p[5] + 4 * i + 4] for i in range(56)]
        ptrs = sorted({u32(e, 0) for t, e in zip(k.types, entries) if t & (KCF_DEAD | KCF_STRING) and not t & KCF_NOP})
        bounds = ptrs + [name_ptr]
        k.values = []
        for t, e in zip(k.types, entries):
            if t & (KCF_DEAD | KCF_STRING) and not t & KCF_NOP:
                s = u32(e, 0)
                k.values.append(bytearray(code[s:bounds[bounds.index(s) + 1]]))
            else:
                k.values.append(bytes(e))
        k.raw = d
        return k

    def write(self, path=None):
        code = bytearray(0xE + 32)
        relocs = []

        def add(b):
            off = len(code); code.extend(b); return off
        o_lc = add(bytes(self.caps[:8])); o_hc = add(bytes(self.caps[8:]))
        o_lr = add(bytes(self.rep[:8])); o_hr = add(bytes(self.rep[8:]))
        o_lt = add(bytes(self.types[:64])); o_ht = add(bytes(self.types[64:]))
        o_lm = add(bytes(256)); o_hm = add(bytes(224))
        for i, (t, v) in enumerate(zip(self.types, self.values)):
            entry = (o_lm + 4 * i) if i < 64 else (o_hm + 4 * (i - 64))
            if t & (KCF_DEAD | KCF_STRING) and not t & KCF_NOP:
                code[entry:entry + 4] = struct.pack('>I', len(code)) if False else b'\0\0\0\0'
        # blobs in the order of the keys whose pointers come first in gb: by key number keeps gb's order
        order = sorted((i for i, t in enumerate(self.types) if t & (KCF_DEAD | KCF_STRING) and not t & KCF_NOP),
                       key=lambda i: self.blob_order.get(i, 1000 + i))
        for i in order:
            entry = (o_lm + 4 * i) if i < 64 else (o_hm + 4 * (i - 64))
            code[entry:entry + 4] = struct.pack('>I', add(self.values[i]))
            relocs.append(entry)
        for i, (t, v) in enumerate(zip(self.types, self.values)):
            if not (t & (KCF_DEAD | KCF_STRING)) or t & KCF_NOP:
                entry = (o_lm + 4 * i) if i < 64 else (o_hm + 4 * (i - 64))
                code[entry:entry + 4] = v
        o_name = add(self.name.encode() + b'\0')
        while len(code) % 4:
            code.append(0)
        code[0xA:0xE] = struct.pack('>I', o_name)
        for j, ptr in enumerate([o_lt, o_lm, o_lc, o_lr, o_ht, o_hm, o_hc, o_hr]):
            code[0xE + 4 * j:0x12 + 4 * j] = struct.pack('>I', ptr)
        relocs += [0xA] + [0xE + 4 * j for j in range(8)]
        relocs.sort(reverse=True)  # (gb lists them from the highest offset)
        n = len(code) // 4
        out = struct.pack('>7I', 0x3F3, 0, 1, 0, 0, n, 0x3E9) + struct.pack('>I', n) + bytes(code)
        out += struct.pack('>III', 0x3EC, len(relocs), 0) + b''.join(struct.pack('>I', r) for r in relocs)
        out += struct.pack('>II', 0, 0x3F2)
        if path:
            open(path, 'wb').write(out)
        return out

    # ---- editing ----

    def plain(self, key, none, shift, alt=None, shift_alt=None, caps=False):
        """A key with 4 characters (type SHIFT|ALT): unshifted, shifted, with Alt, with Shift+Alt."""
        alt = none if alt is None else alt
        shift_alt = shift if shift_alt is None else shift_alt
        self.types[key] = KCF_SHIFT | KCF_ALT
        self.values[key] = bytes(ord(c) for c in (shift_alt, alt, shift, none))
        self._bit(self.caps, key, caps)
        self._bit(self.rep, key, True)

    def dead_prefix(self, key, none, shift, alt, shift_alt):
        """A key that is a dead key: the arguments are a dead key number (int) or a character (str)."""
        self.types[key] = KCF_DEAD | KCF_SHIFT | KCF_ALT
        pairs = b''
        for v in (none, shift, alt, shift_alt):
            pairs += bytes([DPF_DEAD, v]) if isinstance(v, int) else bytes([0, ord(v)])
        self.values[key] = bytearray(pairs)
        self._bit(self.caps, key, False)
        self._bit(self.rep, key, False)

    def move(self, to, frm):
        self.types[to], self.values[to] = self.types[frm], self.values[frm]
        self._bit(self.caps, to, self._get(self.caps, frm))
        self._bit(self.rep, to, self._get(self.rep, frm))

    def set_alt(self, key, alt, shift_alt):
        """Alt and Shift+Alt of a letter with a dead key descriptor (type DEAD|SHIFT|ALT|CONTROL)."""
        v = self.values[key]
        assert self.types[key] & KCF_DEAD
        v[4:8] = bytes([0, ord(alt), 0, ord(shift_alt)])

    @staticmethod
    def _bit(arr, key, on):
        i, b = key // 8, 1 << (key % 8)
        arr[i] = (arr[i] | b) if on else (arr[i] & ~b)

    @staticmethod
    def _get(arr, key):
        return bool(arr[key // 8] & (1 << (key % 8)))


def load_gb():
    k = Keymap.read(os.path.join(KEYMAPS, 'gb'))
    code_ptrs = {}
    # remember gb's order of the descriptors, so that gb is written back byte for byte
    d = k.raw
    k.blob_order = {}
    km = Keymap.read(os.path.join(KEYMAPS, 'gb'))
    # order of the blobs by address in gb
    o = 32
    lom, him = km.lomap, km.himap
    code = d[32:]
    addr = {}
    for i, t in enumerate(km.types):
        if t & (KCF_DEAD | KCF_STRING) and not t & KCF_NOP:
            e = (lom + 4 * i) if i < 64 else (him + 4 * (i - 64))
            addr[i] = u32(code, e)
    for rank, i in enumerate(sorted(addr, key=addr.get)):
        k.blob_order[i] = rank
    return k


def spanish():
    k = load_gb(); k.name = 'e'
    k.plain(0x00, 'º', 'ª', '\\', '\\')
    for key, (n, s, a) in zip(range(0x01, 0x0B), ['1!|', '2"@', '3·#', '4$~', '5%½', '6&¬', '7/{', '8([', '9)]', '0=}']):
        k.plain(key, n, s, a, s)
    k.plain(0x0B, "'", '?', '\\', '?')
    k.plain(0x0C, '¡', '¿')
    k.dead_prefix(0x1A, 2, 3, '[', '{')          # ` and ^
    k.plain(0x1B, '+', '*', ']', '}')
    k.plain(0x29, 'ñ', 'Ñ', 'ñ', 'Ñ', caps=True)
    k.dead_prefix(0x2A, 1, 5, '{', '{')          # ´ and ¨
    k.plain(0x2B, 'ç', 'Ç', '}', '}', caps=True)
    k.plain(0x30, '<', '>')
    k.plain(0x38, ',', ';'); k.plain(0x39, '.', ':'); k.plain(0x3A, '-', '_')
    return k


def czech():
    k = load_gb(); k.name = 'cz'
    y, z = 0x15, 0x31                            # QWERTZ
    yt, yv, zt, zv = k.types[y], k.values[y], k.types[z], k.values[z]
    yc, zc, yr, zr = Keymap._get(k.caps, y), Keymap._get(k.caps, z), Keymap._get(k.rep, y), Keymap._get(k.rep, z)
    k.types[y], k.values[y], k.types[z], k.values[z] = zt, zv, yt, yv
    Keymap._bit(k.caps, y, zc); Keymap._bit(k.caps, z, yc); Keymap._bit(k.rep, y, zr); Keymap._bit(k.rep, z, yr)
    k.plain(0x00, ';', '°', '`', '~')
    # ě š č ř ž are not in ISO-8859-1: e s c r z
    for key, (n, s, a) in zip(range(0x01, 0x0B), ['+1!', 'e2@', 's3#', 'c4$', 'r5%', 'z6^', 'ý7&', 'á8*', 'í9{', 'é0}']):
        k.plain(key, n, s, a, s)
    k.plain(0x0B, '=', '%', '\\', '%')
    k.dead_prefix(0x0C, 1, 3, '|', '|')          # ´ and (instead of ˇ, which is not in ISO-8859-1) ^
    k.plain(0x1A, 'ú', '/', '[', '{')
    k.plain(0x1B, ')', '(', ']', '}')
    k.plain(0x29, 'u', '"', '$', '"')  # ů
    k.plain(0x2A, '§', '!', "'", '!')
    k.dead_prefix(0x2B, 5, "'", '\\', '|')       # ¨
    k.plain(0x30, '\\', '|')
    k.plain(0x38, ',', '?', '<', '?'); k.plain(0x39, '.', ':', '>', ':'); k.plain(0x3A, '-', '_', '*', '_')
    return k


def polish():
    k = load_gb(); k.name = 'pl'                 # programmer layout: US keys, AltGr for the Polish letters
    k.plain(0x00, '`', '~')
    for key, (n, s) in zip(range(0x01, 0x0B), ['1!', '2@', '3#', '4$', '5%', '6^', '7&', '8*', '9(', '0)']):
        k.plain(key, n, s, n, s)
    k.plain(0x0B, '-', '_'); k.plain(0x0C, '=', '+'); k.plain(0x0D, '\\', '|')
    k.plain(0x1A, '[', '{'); k.plain(0x1B, ']', '}')
    k.plain(0x29, ';', ':'); k.plain(0x2A, "'", '"'); k.plain(0x2B, '\\', '|'); k.plain(0x30, '\\', '|')
    k.plain(0x38, ',', '<'); k.plain(0x39, '.', '>'); k.plain(0x3A, '/', '?')
    k.set_alt(0x18, 'ó', 'Ó')                    # o
    # ą ć ę ł ń ś ź ż are not in ISO-8859-1: AltGr gives the base letter
    for key, ch in [(0x20, 'a'), (0x33, 'c'), (0x12, 'e'), (0x28, 'l'), (0x36, 'n'), (0x21, 's'), (0x32, 'z'), (0x31, 'z')]:
        if k.types[key] & KCF_DEAD:
            k.set_alt(key, ch, ch.upper())
        else:
            v = bytearray(k.values[key]); v[0] = ord(ch.upper()); v[1] = ord(ch); k.values[key] = bytes(v)
    return k


if __name__ == '__main__':
    gb = load_gb()
    assert gb.write() == gb.raw, 'gb is not written back byte for byte'
    if '--check' in sys.argv:
        print('gb: ok'); sys.exit(0)
    for build in (spanish, czech, polish):
        k = build()
        path = os.path.join(KEYMAPS, k.name)
        data = k.write(path)
        assert Keymap.read(path).name == k.name
        print(f'{k.name}: {len(data)} bytes')
