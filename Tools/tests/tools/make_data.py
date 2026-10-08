#!/usr/bin/env python3
# Writes the synthetic test data of Tools/tests (no data of the game): files to pack, a 2D map with events and an
# NPC with events, files for HexValueChanger, texts for the text packers and a folder in the layout of the Ambermoon
# repository for AmbermoonExtroIntroTextPackCreator. Deterministic: the same files every time.
#
#   python3 make_data.py <tests folder>
import os, random, sys

root = sys.argv[1]
r = random.Random(4711)

def write(path, data):
    path = os.path.join(root, path)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(data)

words = ('the a dragon amber moon sword shield of to and is in tower castle magic potion gold riddle mouth '
         'door chest key dungeon spell thief knight forest river ship horse').split()
def text(n):
    out = []
    while sum(len(w) + 1 for w in out) < n:
        out.append(r.choice(words))
    return ' '.join(out).encode()[:n]

# files to pack (002 has runs and repeats, 003 is random, 005 has an odd size, 006 is empty)
write('pack/files/001', text(3000))
runs = bytearray()
while len(runs) < 2500:
    k = r.random()
    if k < 0.3:
        runs += bytes([r.choice([0, 0, 0x55, 0xff])]) * r.randint(3, 300)
    elif k < 0.6 and len(runs) > 20:
        start = r.randint(0, len(runs) - 10)
        runs += runs[start:start + r.randint(3, 140)]
    else:
        runs += bytes(r.randint(0, 255) for _ in range(r.randint(1, 40)))
write('pack/files/002', bytes(runs[:2500]))
write('pack/files/003', bytes(r.randint(0, 255) for _ in range(777)))
write('pack/files/005', b'\x42')
write('pack/files/006', b'')
write('pack/textfiles/001', text(1500))
write('pack/textfiles/002', b'\x01\x02' + text(900))
for i in range(1, 4):
    write('pack/items/%03d' % i, bytes(r.randint(0, 255) for _ in range(60)))

# events: random data of all kinds, chains and branches
def events_block(count, chains):
    data = bytearray()
    starts = r.sample(range(count), chains)
    data += chains.to_bytes(2, 'big')
    for s in starts:
        data += s.to_bytes(2, 'big')
    data += count.to_bytes(2, 'big')
    for i in range(count):
        t = r.choice(list(range(1, 33)) + [1, 4, 12, 13, 14, 15, 19, 9, 2, 3])
        d = bytearray(r.randint(0, 255) if r.random() < 0.5 else r.randint(0, 6) for _ in range(9))
        if t in (2, 3, 13, 15, 19, 26):   # door, chest, condition, dice, decision, party member condition: a branch
            target = 0xffff if r.random() < 0.4 else r.randint(0, count - 1)
            d[7:9] = target.to_bytes(2, 'big')
        if t == 13:
            d[0] = r.randint(0, 0x1e)
        if t == 9:
            d[0] = r.randint(0, 0x16); d[1] = r.randint(0, 7); d[3] = r.choice([0, 1, 2, 3, 100, 105, 200, 203])
        if t == 7:
            d[0] = r.randint(0, 7)
        nxt = 0xffff if r.random() < 0.35 else r.randint(0, count - 1)
        data += bytes([t]) + bytes(d) + nxt.to_bytes(2, 'big')
    return bytes(data)

width, height = 8, 6
head = bytearray(r.randint(0, 255) for _ in range(0x14C))
head[2] = 2 # 2D map
head[4] = width
head[5] = height
tiles = bytearray()
for i in range(width * height):
    tiles += bytes([r.randint(0, 255), r.randint(0, 12), r.randint(0, 255), r.randint(0, 255)])
write('events/map/300', bytes(head) + bytes(tiles) + events_block(48, 12) + bytes(r.randint(0, 255) for _ in range(40)))
write('events/npc', bytes(r.randint(0, 255) for _ in range(0x122)) + events_block(30, 6))

# HexValueChanger: files of different sizes, one in a folder below
write('hex/files/a.bin', bytes(r.randint(0, 255) for _ in range(64)))
write('hex/files/b.bin', bytes(r.randint(0, 255) for _ in range(32)))
write('hex/files/c.txt', text(16))
write('hex/files/sub/d.bin', bytes(r.randint(0, 255) for _ in range(40)))

# text packers: texts in all the encodings that File.ReadAllText of .NET reads (byte order marks of UTF-8, UTF-16 and
# UTF-32), invalid UTF-8, line breaks, commands with and without a first text, folders that are left out
I = 'texts/IntroTexts/'
write(I + '000.txt', b'\xef\xbb\xbfBOM ' + text(20))
write(I + '001.txt', b'\xff\xfe' + 'UTF-16 LE: \u00e4\u00f6\u00fc \u20ac'.encode('utf-16-le'))
write(I + '002.txt', b'\xfe\xff' + 'BE \U0001F600 \ud800'.encode('utf-16-be', 'surrogatepass'))
write(I + '003.txt', b'bad \x80 \xc3 \xe2\x82 \xf0\x9f\x98 \xed\xa0\x80 \xc0\xaf \xf5 end\xe2')
write(I + '004.txt', b'line1\r\nline2\rline3\n')
write(I + '005.txt', b'')
write(I + '009.000.txt', text(30))
write(I + '010.000.txt', b'cmd a')
write(I + '010.001.txt', b'cmd b')
write(I + '011.002.txt', b'a command without .000')
write(I + '011.003.txt', text(12))
write(I + '012.000.txt', b'\xff\xfe\x00\x00' + 'UTF-32 \u00df'.encode('utf-32-le'))
write(I + '012.001.txt', b'\xff\xfe\x41')
E = 'texts/ExtroTextGroups/'
write(E + '000/000/000.txt', text(40))
write(E + '000/000/001.txt', b'e2 \xe4')
write(E + '000/001/000.txt', b'odd')
write(E + '002/000/000.txt', 'Gr\u00fc\u00dfe'.encode())
write(E + '002/003/010.txt', text(25))
write(E + '002/003/002.txt', text(7))
write(E + 'xyz/000.txt', b'left out')
write(E + 'end_texts/000.txt', b'left out')

# AmbermoonExtroIntroTextPackCreator: the language "Testish" in the layout of the Ambermoon repository
B = 'creator/Disks/Bugfixing/Testish/'
for i in range(15):
    write(B + 'IntroTexts/%03d.txt' % i, (b'\xef\xbb\xbf' if i == 3 else b'') + text(r.randint(5, 60)))
for c in range(6):
    for g in range(r.randint(1, 3)):
        for t in range(r.randint(1, 4)):
            write(B + 'ExtroTexts/%03d/%03d/%03d.txt' % (c, g, t), text(r.randint(3, 50)))
write(B + 'ExtroTexts/end_texts/000.txt', b'left out')
T = 'creator/Translations/Testish/'
write(T + 'click-text.txt', b'\xef\xbb\xbf \t<KLICK>\xc2\xa0\r\n')
write(T + 'translators.txt', '# translators\r\n  ANNA \u0160T\u011aP\u00c1NKOV\u00c1  \r\n\r\n   \n#X\nBOB B\rCARL'.encode())

# AmbermoonDiskExtract: ADF disk images (an OFS image for disk A, an international FFS image for disk C) with raw
# files, AMBR containers, a directory and files that need extension blocks.
def amiga_hash(name, international):
    h = len(name)
    for ch in name:
        c = ord(ch)
        if 'a' <= ch <= 'z' or (international and 224 <= c <= 254 and c != 247):
            c -= 32
        h = (h * 13 + c) & 0x7ff
    return h % 72

def ambr(files):
    data = b'AMBR' + len(files).to_bytes(2, 'big')
    for f in files:
        data += len(f).to_bytes(4, 'big')
    return data + b''.join(files)

class Adf:
    def __init__(self, ffs, international):
        self.data = bytearray(1760 * 512)
        self.ffs = ffs
        self.international = international
        self.data[0:4] = b'DOS' + bytes([(1 if ffs else 0) | (2 if international else 0)])
        self.next = 2
        self.dirs = {}
        self.make_header(880, 'ROOT', 1, 0)
        self.put(880, 4, 0)
        self.put(880, 12, 0x48)
        self.put(880, 312, 0xffffffff)
        self.dirs[''] = 880
    def put(self, block, offset, value):
        self.data[block * 512 + offset:block * 512 + offset + 4] = (value & 0xffffffff).to_bytes(4, 'big')
    def get(self, block, offset):
        return int.from_bytes(self.data[block * 512 + offset:block * 512 + offset + 4], 'big')
    def alloc(self):
        b = self.next
        self.next += 1
        if self.next == 880:
            self.next = 882
        return b
    def make_header(self, block, name, sec_type, parent):
        self.put(block, 0, 2)
        self.put(block, 4, block if block != 880 else 0)
        n = name.encode('latin-1')
        self.data[block * 512 + 512 - 80] = len(n)
        self.data[block * 512 + 512 - 79:block * 512 + 512 - 79 + len(n)] = n
        self.put(block, 512 - 12, parent)
        self.put(block, 512 - 4, sec_type)
    def link(self, directory, name, block):
        # appended to the hash chain of the directory
        h = amiga_hash(name, self.international)
        first = self.get(directory, 24 + h * 4)
        if first == 0:
            self.put(directory, 24 + h * 4, block)
        else:
            b = first
            while self.get(b, 512 - 16):
                b = self.get(b, 512 - 16)
            self.put(b, 512 - 16, block)
    def directory(self, path):
        if path in self.dirs:
            return self.dirs[path]
        parent_path, _, name = path.rpartition('/')
        parent = self.directory(parent_path)
        block = self.alloc()
        self.make_header(block, name, 2, parent)
        self.link(parent, name, block)
        self.dirs[path] = block
        return block
    def add(self, path, content):
        parent_path, _, name = path.rpartition('/')
        parent = self.directory(parent_path)
        header = self.alloc()
        self.make_header(header, name, (-3) & 0xffffffff, parent)
        self.put(header, 512 - 188, len(content))
        self.link(parent, name, header)
        size = 512 if self.ffs else 488
        chunks = [content[i:i + size] for i in range(0, len(content), size)] or []
        table_block = header
        seq = 0
        for start in range(0, max(len(chunks), 1), 72):
            part = chunks[start:start + 72]
            if start > 0:
                ext = self.alloc()
                self.put(ext, 0, 16)
                self.put(ext, 4, ext)
                self.put(ext, 512 - 12, header)
                self.put(ext, 512 - 4, (-3) & 0xffffffff)
                self.put(table_block, 512 - 8, ext)
                table_block = ext
            self.put(table_block, 8, len(part))
            for i, chunk in enumerate(part):
                b = self.alloc()
                seq += 1
                if self.ffs:
                    self.data[b * 512:b * 512 + len(chunk)] = chunk
                else:
                    self.put(b, 0, 8)
                    self.put(b, 4, header)
                    self.put(b, 8, seq)
                    self.put(b, 12, len(chunk))
                    self.data[b * 512 + 24:b * 512 + 24 + len(chunk)] = chunk
                self.put(table_block, 24 + (71 - i) * 4, b)

disk_a = Adf(False, False)
disk_a.add('Keymap', bytes(r.randint(0, 255) for _ in range(300)))
disk_a.add('AM2_BLIT', text(40000))
disk_a.add('Initial/Chest_data.amb', ambr([text(100), b'', bytes(r.randint(0, 255) for _ in range(50))]))
disk_a.add('Initial/Party_data.sav', text(77))
disk_a.add('Readme', text(40))
write('adf/AMBER_A.adf', bytes(disk_a.data))
disk_c = Adf(True, True)
disk_c.add('1Map_texts.amb', ambr([text(200), text(10), text(1)]))
disk_c.add('1Icon_gfx.amb', ambr([text(80000)]))
disk_c.add('Save.00/Party_char.amb', ambr([text(30)]))
write('adf/amber_c.adf', bytes(disk_c.data))
