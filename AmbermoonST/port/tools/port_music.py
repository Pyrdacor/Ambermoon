#!/usr/bin/env python3
"""The music of the ST version (AmbermoonST/ORIGINAL/AMBR/AMBER<n>.BIN, packed with Pack-Ice).

    port_music.py <player include>
    port_music.py --extract

Every file is the same player (8294 bytes of code, then a table of 5 offsets) followed by the data of one song;
the player finds the data behind itself (lea table(pc), plus the offsets). So the player is stored once in the
kernel (the include written here, see KERNEL/MUSIC.S) and Music.amb gets only the data of the songs (songs()),
which the kernel copies behind the player. port/MUSIC holds both unpacked (made from the original files by
--extract) : PLAYER.BIN (the original player) and AMBER<n>.BIN (the data of the songs). The numbers of the files
are not the numbers of the Amiga songs (ST_FILES, found by listening). The Amiga songs without ST version are
taken from SONG<nn>.BIN (converted from the Amiga version by sa_to_st.py) when there is one, else they are empty
(size 0 : no music). AMBER19 is AMBER11 and AMBER20 is AMBER15 with another order of the patterns (they start at
another place) : not used.

The player uses Timer A and Timer B of the MFP for its effects, but the kernel needs Timer B for the raster
(event count mode). Its Timer B is moved to Timer D (same prescalers, not used by the kernel) : the addresses
are changed, and the accesses to the control register, which Timer D shares with Timer C (needed by the disk
drivers), call routines of the kernel which change only the bits of Timer D.
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.dont_write_bytecode = True
sys.path.insert(0, HERE)
import ice                                 # noqa: E402

ORIGINAL = os.path.normpath(os.path.join(HERE, '..', '..', 'ORIGINAL', 'AMBR'))
FOLDER = os.path.normpath(os.path.join(HERE, '..', 'MUSIC'))
PLAYER = 8294 + 20                         # code + table of the offsets (the same in all files)
SONGS = 32                                 # (Music.amb of the Amiga version, Max_songs)
ST_FILES = {                               # Amiga song : number of the ST file
    2: 15,                                 # Mellow Camel Funk
    4: 10,                                 # Voice of the Bagpipe
    5: 5,                                  # Downtown
    6: 1,                                  # Ship
    7: 18,                                 # Whole Lotta Dove
    8: 12,                                 # Horse is no Disgrace
    9: 4,                                  # Don't look Bach
    11: 16,                                # Sapphire Fireballs of Pure Love
    14: 14,                                # Plodding Along
    15: 2,                                 # Compact Disc
    16: 13,                                # Riverside Travelling Blues
    17: 11,                                # Nobody's Vault but Mine
    18: 17,                                # La Crypta Strangiato
}

# offset : (original bytes, new bytes) - Timer B -> Timer D
BYTES = {
    0x0020: ('20b80120', '20b80110'),      # save the vector
    0x005a: ('08f80000fa07', '08f80004fa09'),  # interrupt enable
    0x0066: ('08f80000fa13', '08f80004fa15'),  # interrupt mask
    0x00ea: ('21c80120', '21c80110'),      # set the vector
    0x0114: ('21faffe20120', '21faffe20110'),  # restore the vector
    0x05cc: ('b638fa21', 'b638fa25'),      # data register
    0x05d2: ('11c3fa21', '11c3fa25'),
    0x0706: ('b638fa21', 'b638fa25'),
    0x070c: ('11c3fa21', '11c3fa25'),
}
for o in (0x0996, 0x09ae, 0x09c6, 0x09de):     # the interrupt routines : next one, end of interrupt
    BYTES[o + 8] = ('21fc000000000120', '21fc000000000110')
    BYTES[o + 16] = ('08b80000fa0f', '08b80004fa11')
# offset : (original bytes, instruction) - the control register (4 bytes -> bsr.w)
CALLS = {o: ('4238fa1b', 'bsr.w\tMusic_timer_D_off') for o in (0x004c, 0x01e6, 0x0580, 0x059e, 0x06ba, 0x06d8)}
CALLS.update({o: ('1038fa1b', 'bsr.w\tMusic_timer_D_get') for o in (0x05d6, 0x0710)})
CALLS.update({o: ('11c1fa1b', 'bsr.w\tMusic_timer_D_set') for o in (0x05de, 0x0718)})


def unpacked():
    """{file number: unpacked original file}"""
    out = {}
    for f in os.listdir(ORIGINAL):
        if f.upper().startswith('AMBER') and f.upper().endswith('.BIN'):
            out[int(f[5:-4])] = ice.unpack(open(os.path.join(ORIGINAL, f), 'rb').read())[0]
    return out


def extract():
    """The original files -> port/MUSIC (the player once, the data of the songs)"""
    files = unpacked()
    player = files[min(files)][:PLAYER]
    os.makedirs(FOLDER, exist_ok=True)
    open(os.path.join(FOLDER, 'PLAYER.BIN'), 'wb').write(player)
    for n, d in files.items():
        if d[:PLAYER] != player:
            raise ValueError(f'AMBER{n}.BIN : another player')
        open(os.path.join(FOLDER, f'AMBER{n}.BIN'), 'wb').write(d[PLAYER:])


def songs():
    """{Amiga song number: data for Music.amb} : the size (.l), then the data behind the player"""
    out = {}
    for n in range(1, SONGS + 1):
        converted = os.path.join(FOLDER, f'SONG{n:02}.BIN')          # (sa_to_st.py)
        if n in ST_FILES:
            d = open(os.path.join(FOLDER, f'AMBER{ST_FILES[n]}.BIN'), 'rb').read()
        elif os.path.exists(converted):
            d = open(converted, 'rb').read()
        else:
            d = b''
        out[n] = struct.pack('>I', len(d)) + d
    return out


def player_source():
    code = bytearray(open(os.path.join(FOLDER, 'PLAYER.BIN'), 'rb').read())
    for o, (old, new) in BYTES.items():
        old, new = bytes.fromhex(old), bytes.fromhex(new)
        if code[o:o + len(old)] != old:
            raise ValueError(f'player ${o:04x} : not {old.hex()}')
        code[o:o + len(new)] = new
    for o, (old, _) in CALLS.items():
        if code[o:o + 4] != bytes.fromhex(old):
            raise ValueError(f'player ${o:04x} : not {old}')
    lines = ['; Made by port/tools/port_music.py : the music player of the ST version, Timer B -> Timer D',
             'Music_player:']
    o = 0
    while o < PLAYER:
        if o in CALLS:
            lines.append('\t' + CALLS[o][1])
            o += 4
            continue
        end = min([PLAYER, o + 16] + [c for c in CALLS if c > o])
        lines.append('\tdc.w\t' + ','.join('$%04x' % struct.unpack('>H', code[i:i + 2])[0]
                                             for i in range(o, end, 2)))
        o = end
    return '\n'.join(lines) + '\n'


def main():
    if sys.argv[1] == '--extract':
        extract()
        return
    open(sys.argv[1], 'w', newline='\n').write(player_source())
    data = songs()
    print(f'music : {sum(1 for d in data.values() if len(d) > 4)} songs, the largest '
          f'{max(len(d) for d in data.values()) - 4} bytes')


if __name__ == '__main__':
    main()
