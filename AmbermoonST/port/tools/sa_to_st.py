#!/usr/bin/env python3
"""Converts songs of the Amiga version (Sonic Arranger modules, Music/SONIC.<name>.sa) for the music player of the
ST version (port/MUSIC/README.md has its format).

    sa_to_st.py <Amiga song number>... [-o <folder>] [-v] [-f]

Writes <folder>/SONG<nn>.BIN (default port/MUSIC), the data of the song for the ST player. Songs in the folder
are accepted ones (by listening) : they are only replaced with -f.

The Amiga version has 4 tracks with samples and synth waves, the ST player 3 channels of the YM2149 with square
waves, noise and volume sequences. The conversion :
  - The rows : the song is played through like the Amiga player does it (pattern break, speed) and cut into
    patterns of 64 rows (shorter ones end with a pattern break). The ST player waits speed + 1 ticks per row.
  - The instruments : the volume of every Amiga instrument is simulated tick by tick (ADSR wave, or the amplitude
    of the sample) and converted to the levels of the YM2149 (3 dB per step). The pitch comes from the length of
    the synth wave or from the period of the sample (autocorrelation); samples without a period (drums) play
    noise. A change of the pitch by the AMF wave becomes an arpeggio. The volume of the notes is part of the
    instrument (one ST instrument per instrument and volume) : the volume effect of the ST player subtracts from
    the whole byte and would destroy the noise flag.
  - 4 tracks -> 3 channels, in every pattern : one track is put into the channel of another one, where it plays
    only while the other one is (nearly) silent. The pair which loses the least sound is taken; notes doubled by
    another track count less.
  - The effects : slide (Amiga command 1), portamento and vibrato of the instruments, speed, pattern break.
"""
import math
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, '..', '..', '..'))
SONGS = os.path.join(REPO, 'Music')
MUSIC = os.path.normpath(os.path.join(HERE, '..', 'MUSIC'))
NAMES = {1: 'WhoSaidHiHo', 2: 'MellowCamelFunk', 3: 'CloseTheHedge', 4: 'VoiceOfTheBagpipe', 5: 'Downtown',
         6: 'Ship', 7: 'WholeLottaDove', 8: 'HorseIsNoDisgrace', 9: 'DontLookBach', 10: 'RoughWaterfrontTavern',
         11: 'SapphireFireballsOfPureLove', 12: 'TheAumRemainsTheSame', 13: 'Capital', 14: 'PloddingAlong',
         15: 'CompactDisc', 16: 'RiversideTravellingBlues', 17: 'NobodysVaultButMine', 18: 'LaCryptaStrangiato',
         19: 'MistyDungeonHop', 20: 'BurnBabyBurn!', 21: 'BarBrawlin', 22: 'PsychedelicDuneGroove',
         23: 'Stairway_to_level_50', 24: 'ThatHunchIsBack', 25: 'ChickenSoup', 26: 'DragonChaseInCreepyDungeon',
         27: 'HisMastersVoice', 28: 'NoName-Secret', 29: 'OhNoNotAnotherMagEvent', 30: 'TheUhOhSong',
         31: 'OwnerOfALonelySword', 32: 'GameOver'}

PAULA = 3546895                            # clock of the Amiga (PAL)
SA_PERIODS = [0,
    0x3580, 0x3280, 0x2fa0, 0x2d00, 0x2a60, 0x2800, 0x25c0, 0x23a0, 0x21a0, 0x1fc0, 0x1e00, 0x1c50,
    0x1ac0, 0x1940, 0x17d0, 0x1680, 0x1530, 0x1400, 0x12e0, 0x11d0, 0x10d0, 0x0fe0, 0x0f00, 0x0e28,
    0x0d60, 0x0ca0, 0x0be8, 0x0b40, 0x0a98, 0x0a00, 0x0970, 0x08e8, 0x0868, 0x07f0, 0x0780, 0x0714,
    0x06b0, 0x0650, 0x05f4, 0x05a0, 0x054c, 0x0500, 0x04b8, 0x0474, 0x0434, 0x03f8, 0x03c0, 0x038a,
    0x0358, 0x0328, 0x02fa, 0x02d0, 0x02a6, 0x0280, 0x025c, 0x023a, 0x021a, 0x01fc, 0x01e0, 0x01c5,
    0x01ac, 0x0194, 0x017d, 0x0168, 0x0153, 0x0140, 0x012e, 0x011d, 0x010d, 0x00fe, 0x00f0, 0x00e2,
    0x00d6, 0x00ca, 0x00be, 0x00b4, 0x00aa, 0x00a0, 0x0097, 0x008f, 0x0087, 0x007f, 0x0078, 0x0071,
    0x006b, 0x0065, 0x005f, 0x005a, 0x0055, 0x0050, 0x004b, 0x0047, 0x0043, 0x003f, 0x003c, 0x0038,
    0x0035, 0x0032, 0x002f, 0x002d, 0x002a, 0x0028, 0x0025, 0x0023, 0x0021, 0x001f, 0x001e, 0x001c]
YM_CLOCK = 2000000
ST_C1 = YM_CLOCK / 16 / 3822               # note 1 of the ST player (its period table, PLAYER.BIN $ade)
TICKS = 50                                 # ticks per second (both players)
ROWS = 64                                  # rows of an ST pattern
MAX_INSTRUMENTS = 31
# the parts of the song data (the table of the player points to them) : offset, size, name
LAYOUT = ((0x002, 0x800, 'instruments'), (0x802, 0x240, 'arpeggios'), (0xa42, 0x140, 'noise'),
          (0xb82, 0x100, 'order'), (0xc82, 0, 'patterns'))
NOISE_LIMIT = 0.3                         # autocorrelation below : the sample is noise
HARMONICS = {round(12 * math.log2(h)) for h in range(2, 12)}   # semitones above the fundamental
LOWEST = 25                                # lowest (median) note of an instrument : C3
QUIET = 4                                 # YM level : a track can play in the channel of another one
ECHO = 8                                   # volume (0..64) of a repeated note : an echo, left out
CUT = 1.5                                  # a note cuts another one when it brings more sound than this * the rest


def st_periods():
    p = open(os.path.join(MUSIC, 'PLAYER.BIN'), 'rb').read()
    per = struct.unpack('>129H', p[0xade:0xbe0])
    return per[:max(i for i, x in enumerate(per) if x) + 1]


ST_PERIODS = st_periods()


def ym_level(amp):
    """linear amplitude (0..1) -> level of the YM2149 (0..15)"""
    if amp <= 0:
        return 0
    return max(0, min(15, round(15 + 20 * math.log10(amp) / 3)))


def amplitude(level):
    return 0 if level <= 0 else 10 ** ((level - 15) * 3 / 20)


def signed(b):
    return b - 256 if b > 127 else b


# ---------------------------------------------------------------------------------------------------------------
# The Sonic Arranger module

class Instrument:
    FIELDS = ('synth wave length repeat volume fine porta vibdelay vibspeed viblevel amfwave amfdelay amflength '
              'amfrepeat adsrwave adsrdelay adsrlength adsrrepeat sustainpt sustainval effect1 effect effect2 '
              'effect3 effectdelay').split()

    def __init__(self, data):
        values = struct.unpack('>4H8x16H16x5H', data[:74])
        for k, v in zip(self.FIELDS, values):
            setattr(self, k, v)
        self.name = data[122:152].split(b'\0')[0].decode('latin1').strip()


class Module:
    def __init__(self, path):
        d = open(path, 'rb').read()
        if d[:4] != b'SOAR':
            raise ValueError(f'{path} : no Sonic Arranger module')
        p = 8

        def count():
            nonlocal p
            p += 4
            return struct.unpack('>I', d[p - 4:p])[0]
        self.songs, self.voices, self.notes, self.instruments, self.samples = [], [], [], [], []
        self.waves = self.adsr = self.amf = b''
        while p < len(d):
            tag = d[p:p + 4]
            p += 4
            if tag == b'STBL':
                for _ in range(count()):
                    self.songs.append(struct.unpack('>6H', d[p:p + 12]))
                    p += 12
            elif tag == b'OVTB':
                for _ in range(count() * 4):
                    self.voices.append(struct.unpack('>Hbb', d[p:p + 4]))
                    p += 4
            elif tag == b'NTBL':
                for _ in range(count()):
                    self.notes.append(tuple(d[p:p + 4]))
                    p += 4
            elif tag == b'INST':
                for _ in range(count()):
                    self.instruments.append(Instrument(d[p:p + 152]))
                    p += 152
            elif tag == b'SD8B':
                n = count()
                p += n * (4 + 4 + 30)                  # lengths, repeats, names
                sizes = struct.unpack(f'>{n}I', d[p:p + 4 * n])
                p += 4 * n
                for s in sizes:
                    self.samples.append(d[p:p + s])
                    p += s
            elif tag in (b'SYWT', b'SYAR', b'SYAF'):
                n = count()
                data = d[p:p + n * 128]
                p += n * 128
                if tag == b'SYWT':
                    self.waves = data
                elif tag == b'SYAR':
                    self.adsr = data
                else:
                    self.amf = data
            else:
                break                                   # EDAT : only for the editor

    def rows(self):
        """The rows of the song as played : [[(note, instrument, command, parameter) x 4]], the position where
        the song repeats (row) and the speed at the start"""
        speed, length, start, stop, repeat, _ = self.songs[0]
        out = []
        restart = 0
        for pos in range(start, stop + 1):
            if pos == repeat:
                restart = len(out)
            voices = self.voices[pos * 4:pos * 4 + 4]
            for r in range(length):
                row = []
                for address, sound_transpose, note_transpose in voices:
                    note, ins, flags, param = self.notes[address + r]
                    if 0 < note < 0x7f:
                        if not flags & 0x40:
                            note += note_transpose
                        if ins and not flags & 0x80:
                            ins = (ins + sound_transpose) & 0xff
                    row.append((note, ins, flags & 0x0f, param))
                out.append(row)
                if any(c[2] == 0xd for c in row):
                    break
        return out, restart, speed


# ---------------------------------------------------------------------------------------------------------------
# The instruments

def wave_byte(data, wave, pos):
    i = wave * 128 + pos
    return data[i] if 0 <= i < len(data) else 0


def adsr_volumes(ins, adsr, volume, ticks):
    """The volume (0..64) of a note in every tick, like the Amiga player"""
    total = ins.adsrlength + ins.adsrrepeat
    if total == 0:
        return [volume] * ticks
    out = []
    pos, delay, off = 0, ins.adsrdelay, False
    for _ in range(ticks):
        if off:
            out.append(0)
            continue
        a = wave_byte(adsr, ins.adsrwave, pos)
        out.append(min(64, volume * a / 64))
        delay = (delay - 1) & 0xffff
        if delay == 0:
            delay = ins.adsrdelay
            pos += 1
            if pos >= total:
                pos = ins.adsrlength - (1 if ins.adsrrepeat == 0 else 0)
                if ins.adsrrepeat == 0 and a == 0:
                    off = True
    return out


def sample_parts(ins, data):
    """(the part played first, the part repeated (b'' : silence afterwards))"""
    words = ins.length + (0 if ins.repeat == 1 else ins.repeat)
    first = data[:words * 2]
    if ins.repeat == 1:
        return first, b''
    if ins.repeat == 0:
        return first, first
    return first, data[ins.length * 2:(ins.length + ins.repeat) * 2]


def autocorrelation(x, lags, circular):
    """normalized autocorrelation for the lags : [(lag, r)]"""
    n = len(x)
    energy = sum(v * v for v in x) or 1
    out = []
    for lag in lags:
        if circular:
            s = sum(x[i] * x[(i + lag) % n] for i in range(n))
            out.append((lag, s / energy))
        else:
            a, b = x[:n - lag], x[lag:]
            s = sum(u * v for u, v in zip(a, b))
            e = math.sqrt(sum(u * u for u in a) * sum(v * v for v in b)) or 1
            out.append((lag, s / e))
    return out


def find_period(x, circular, min_lag=2, max_lag=None):
    """samples per cycle and how periodic the signal is (0..1)"""
    n = len(x)
    if n < 16 and not circular:
        return None, 0
    max_lag = min(max_lag or n, n if circular else n // 2)
    if circular:
        # a wave which repeats : does it consist of 2 or 3 equal parts ? (without its offset, the effects of
        # the synth instruments often change waves which are only positive)
        mean = sum(x) / n
        x = [v - mean for v in x]
        period = n
        while True:
            for k in (2, 3):
                if period % k == 0 and period // k >= min_lag and \
                        autocorrelation(x[:period], [period // k], True)[0][1] >= 0.97:
                    period //= k
                    break
            else:
                return period, 1.0
    r = autocorrelation(x, range(min_lag, max_lag), False)
    peaks = [(lag, v) for i, (lag, v) in enumerate(r[1:-1], 1) if v >= r[i - 1][1] and v >= r[i + 1][1] and v > 0]
    if not peaks:
        return None, 0
    best = max(v for _, v in peaks)
    for lag, v in peaks:
        if v >= 0.85 * best:
            return lag, best
    return None, 0


class Sound:
    """An Amiga instrument as the ST will play it"""

    def __init__(self, module, number, notes):
        self.number = number
        ins = self.ins = module.instruments[number - 1] if 0 < number <= len(module.instruments) else None
        self.ref = sorted(notes)[len(notes) // 2] if notes else 49
        self.noise = None
        self.chord = None
        self.shape = None                         # amplitude of the sample in every tick (None : synth)
        if ins is None:
            self.period = 32
        elif ins.synth:
            size = min(128, ins.length * 2) or 2
            wave = [signed(wave_byte(module.waves, ins.wave, i)) for i in range(size)]
            self.period, _ = find_period(wave, True)
        else:
            data = module.samples[ins.wave] if ins.wave < len(module.samples) else b''
            first, loop = sample_parts(ins, data)
            rate = PAULA / SA_PERIODS[self.ref]
            self.shape = self.sample_shape(first, loop, rate)
            if len(loop) >= 256:
                part = loop
            else:
                part = first[len(first) // 8:]
            x = [signed(b) for b in part[:2048]]
            period, quality = find_period(x, False, 8, 1024)
            if len(loop) >= 16 and len(loop) < 256 and loop:
                period, quality = find_period([signed(b) for b in loop], True)
            if period is not None and quality >= NOISE_LIMIT:
                self.period, self.chord = self.harmony([signed(b) for b in first[:8192]], period)
                if self.chord and min(b - a for a, b in zip(self.chord, self.chord[1:])) <= 2:
                    period = None                 # tones a second apart : no chord, noise
            if period is None or quality < NOISE_LIMIT:
                self.chord = None
                crossings = sum(1 for a, b in zip(x, x[1:]) if (a < 0) != (b < 0))
                zcr = crossings / max(1, len(x)) * rate
                self.noise = max(1, min(31, round(YM_CLOCK / 32 / max(zcr, 1))))
                self.period = 32
        # the ST note of an Amiga note : the same frequency, octaves moved into the range of the ST player
        f = PAULA / (SA_PERIODS[self.ref] * self.period)
        self.shift = round(1 + 12 * math.log2(f / ST_C1)) - self.ref
        lo, hi = min(notes, default=self.ref) + self.shift, max(notes, default=self.ref) + self.shift
        # square waves below C3 drone : such instruments an octave higher (like the ST arranger did)
        while self.noise is None and self.ref + self.shift < LOWEST and hi + 12 < len(ST_PERIODS):
            self.shift += 12
            lo, hi = lo + 12, hi + 12
        while lo < 1 and hi + 12 < len(ST_PERIODS):
            self.shift += 12
            lo, hi = lo + 12, hi + 12
        while hi >= len(ST_PERIODS):
            self.shift -= 12
            lo, hi = lo - 12, hi - 12
        self.arp = (tuple(self.chord), True) if self.chord else self.amf_arpeggio(module)
        if self.arp and min(self.arp[0]) < 0:
            # the ST player adds only positive values (negative ones end the table) : a lower note
            low = min(self.arp[0])
            self.shift += low
            self.arp = (tuple(v - low for v in self.arp[0]), self.arp[1])

    @staticmethod
    def harmony(x, period):
        """The tones of a sample in the semitones above the period (autocorrelation) : the period of the lowest
        strong tone and, if there are other strong tones in the octave above it, the chord (semitones above
        the lowest tone, played as an arpeggio)"""
        n = len(x)
        window = [0.5 - 0.5 * math.cos(2 * math.pi * i / (n - 1)) for i in range(n)]
        x = [v * w for v, w in zip(x, window)]

        def power(cycles):                       # Goertzel : cycles per sample
            k = 2 * math.cos(2 * math.pi * cycles)
            s1 = s2 = 0.0
            for v in x:
                s1, s2 = v + k * s1 - s2, s1
            return s1 * s1 + s2 * s2 - k * s1 * s2
        base = 1 / period
        tones = []
        for semi in range(49):
            c = base * 2 ** (semi / 12)
            if c >= 0.5:
                break
            tones.append(max(power(c * 2 ** (d / 48)) for d in (-1, 0, 1)))
        top = max(tones)
        strong = [s for s, p in enumerate(tones) if p >= top * 0.2 and
                  (s == 0 or p >= tones[s - 1]) and (s + 1 == len(tones) or p >= tones[s + 1])]
        # the tones which are no harmonics of lower ones (a harmonic is not louder than its tone)
        own = []
        for s in strong:
            if not any(s - o in HARMONICS and tones[s] <= tones[o] for o in own):
                own.append(s)
        classes = {}
        for s in own:
            classes[s % 12] = max(classes.get(s % 12, 0), tones[s])
        loudest = max(classes.values())
        kept = sorted((c for c in classes if classes[c] >= 0.2 * loudest), key=lambda c: -classes[c])[:3]
        low = min(s for s in own if s % 12 in kept) % 12      # (not above the octave of the period)
        chord = sorted((c - low) % 12 for c in kept)
        # 2 tones are mostly a harmonic (the fifth) : a chord has 3
        return period / 2 ** (low / 12), chord if len(chord) > 2 else None

    @staticmethod
    def sample_shape(first, loop, rate):
        """The amplitude of the sample (0..1) in every tick : the RMS (a square wave of the same level sounds
        louder than the peak of the sample), smoothed (changes from tick to tick
        would be a tremolo of 50 Hz : rough), after its peak only falling, the repeated part a constant level"""
        per_tick = max(1, int(rate / TICKS))

        def rms(chunk):
            return math.sqrt(sum(signed(b) ** 2 for b in chunk) / len(chunk)) / 128 if chunk else 0
        out = [rms(first[p:p + per_tick]) for p in range(0, len(first), per_tick)][:256]
        out = [sum(out[max(0, i - 2):i + 3]) / len(out[max(0, i - 2):i + 3]) for i in range(len(out))]
        if out:
            peak = out.index(max(out))
            for i in range(peak + 1, len(out)):
                out[i] = min(out[i], out[i - 1])
        if loop:
            level = min(rms(loop), out[-1] if out else 1)
            out += [level] * max(0, 256 - len(out))
        return [min(1.0, v) for v in out]

    def amf_arpeggio(self, module):
        """the change of the pitch by the AMF wave in semitones, per tick (None : none)"""
        ins = self.ins
        if ins is None or not ins.amflength + ins.amfrepeat:
            return None
        period = SA_PERIODS[self.ref]
        total = ins.amflength + ins.amfrepeat
        out, pos, delay = [], 0, ins.amfdelay
        for _ in range(64):
            p = period - signed(wave_byte(module.amf, ins.amfwave, pos))
            out.append(round(12 * math.log2(period / max(113, p))))
            delay = (delay - 1) & 0xffff
            if delay == 0:
                delay = ins.amfdelay
                pos += 1
                if pos >= total:
                    pos = ins.amflength - (1 if ins.amfrepeat == 0 else 0)
        if not any(out):
            return None
        while len(out) > 1 and out[-1] == out[-2]:
            out.pop()
        return tuple(out[:48]), ins.amfrepeat != 0 and ins.amflength == 0

    def levels(self, module, volume, ticks=128):
        """the YM levels of a note with the volume (0..64), in every tick"""
        if self.ins is None:
            return [0]
        vols = adsr_volumes(self.ins, module.adsr, volume, ticks)
        if self.shape is not None:
            vols = [v * (self.shape[t] if t < len(self.shape) else 0) for t, v in enumerate(vols)]
        return [ym_level(v / 64) for v in vols]

    def vibrato(self, st_note):
        """the parameter of the vibrato effect of the ST player and the delay in ticks (None : no vibrato)"""
        ins = self.ins
        if ins is None or (ins.vibdelay & 0xff) == 0xff or not ins.viblevel or not ins.vibspeed:
            return None
        level = ins.viblevel - 65536 if ins.viblevel > 32767 else ins.viblevel
        depth = abs(127 * 4 / level) / SA_PERIODS[self.ref]
        param = round(depth * ST_PERIODS[max(1, min(len(ST_PERIODS) - 1, st_note))] / 2)
        return (param, ins.vibdelay) if param >= 1 else None


# ---------------------------------------------------------------------------------------------------------------
# The song

class Cell:
    """a row of a track : the note (ST, 0 : none), the ST instrument, effect and parameter"""
    __slots__ = ('note', 'ins', 'effect', 'param', 'levels', 'pitch')

    def __init__(self, note, ins, levels, pitch):
        self.note, self.ins, self.levels, self.pitch = note, ins, levels, pitch
        self.effect = self.param = 0


class Converter:
    def __init__(self, module, verbose=False):
        self.module = module
        self.verbose = verbose
        rows, self.restart, self.speed = module.rows()
        self.rows = rows
        used = {}
        current = [0] * 4
        for row in rows:
            for t, (note, ins, _, _) in enumerate(row):
                if ins:
                    current[t] = ins
                if 0 < note < 0x7f and current[t]:
                    used.setdefault(current[t], []).append(note)
        self.sounds = {n: Sound(module, n, notes) for n, notes in used.items()}
        self.variants = {}                         # (sound, volume step) -> ST instrument number
        self.boost = 0
        self.tracks = self.play()
        # the loudest note gets the highest level (on the YM2149 quiet songs sound far away)
        peak = max((max(c.levels) for t in self.tracks for c in t if c is not None and c.levels), default=15)
        if 0 < peak < 15:
            self.boost = 15 - peak
            self.variants = {}
            self.tracks = self.play()

    def variant(self, number, volume):
        step = 0 if volume >= 64 else 99 if volume <= 0 else round(-20 * math.log10(volume / 64) / 3)
        key = (number, min(step, 15))
        if key not in self.variants:
            self.variants[key] = len(self.variants) + 1
        return self.variants[key], key

    def levels_of(self, key):
        number, step = key
        sound = self.sounds.get(number)
        if sound is None or step >= 15:
            return [0]
        return [min(15, v + self.boost) if v else 0
                for v in sound.levels(self.module, 64 * 10 ** (-step * 3 / 20))]

    def play(self):
        """[track][row] -> Cell or None, like the Amiga player plays it; the speed of every row"""
        tracks = [[None] * len(self.rows) for _ in range(4)]
        self.speeds = []
        speed = self.speed
        state = [{'ins': 0, 'volume': 0, 'note': 0, 'porta': 0} for _ in range(4)]
        for r, row in enumerate(self.rows):
            for note, ins, cmd, param in row:
                if cmd == 0xf and 0 < param <= 16:
                    speed = param
            self.speeds.append(speed)
            for t, (note, ins, cmd, param) in enumerate(row):
                s = state[t]
                start = False
                if ins and (note == 0 or 0 < note < 0x7f):
                    if 0 < ins <= len(self.module.instruments):
                        s['ins'] = ins
                        s['volume'] = self.module.instruments[ins - 1].volume
                        s['porta'] = self.module.instruments[ins - 1].porta
                    start = True
                if note == 0x7f:
                    s['ins'] = 0
                    start = True
                if 0 < note < 0x7f:
                    s['last'] = s['note'] or note
                    s['note'] = note
                    start = True
                if cmd == 0xc:
                    s['volume'] = min(64, param)
                    if not start and s['ins']:
                        start = 'volume'
                elif cmd == 0x7:
                    s['porta'] = param
                elif cmd == 0x8:
                    s['porta'] = 0
                if not start:
                    if cmd == 0x1 and s['ins'] and s['note']:
                        cell = Cell(0, 0, None, None)
                        self.slide(cell, s, signed(param), speed)
                        tracks[t][r] = cell
                    continue
                if 0 < note < 0x7f and note == s.get('last') and s['volume'] <= ECHO and cmd == 0xc:
                    continue                      # an echo of the last note (quiet) : the YM is too loud
                sound = self.sounds.get(s['ins'])
                if sound is None:
                    tracks[t][r] = Cell(0, self.variant(0, 0)[0], [0], None)
                    continue
                number, key = self.variant(s['ins'], s['volume'])
                st_note = max(1, min(len(ST_PERIODS) - 1, s['note'] + sound.shift)) if s['note'] else 0
                if start == 'volume':
                    # the volume changes during a note : the note is started again with the new volume
                    tracks[t][r] = Cell(0, number, self.levels_of(key), st_note)
                    continue
                cell = Cell(st_note if 0 < note < 0x7f else 0, number, self.levels_of(key), st_note)
                if cmd == 0x1:
                    self.slide(cell, s, signed(param), speed)
                elif s['porta'] and 0 < note < 0x7f and s.get('last') and s['last'] != note:
                    ratio = ST_PERIODS[st_note] / SA_PERIODS[note]
                    cell.effect, cell.param = 3, max(1, min(255, round(s['porta'] * ratio)))
                    cell.pitch = ('porta', s['last'], note, s['porta'])
                tracks[t][r] = cell
        return tracks

    def slide(self, cell, s, param, speed):
        """Amiga command 1 : the period changes by param in every tick but the first one"""
        sound = self.sounds.get(s['ins'])
        st_note = max(1, min(len(ST_PERIODS) - 1, s['note'] + (sound.shift if sound else 0)))
        ratio = ST_PERIODS[st_note] / SA_PERIODS[s['note']]
        value = round(abs(param) * ratio * (speed - 1) / speed)
        if value:
            cell.effect = 1 if param > 0 else 2
            cell.param = min(127, value)

    # -----------------------------------------------------------------------------------------------------------

    def sounding(self, track, first, last):
        """the YM level of the track at the start of every row first..last-1"""
        out = []
        cell, since = None, 0
        for r in range(first, last):
            c = track[r]
            if c is not None and c.levels is not None:
                cell, since = c, 0
            lv = 0
            if cell is not None:
                lv = cell.levels[min(since, len(cell.levels) - 1)]
            out.append(lv)
            since += self.speeds[r]
        # a note from before the pattern
        if first > 0 and track[first] is None:
            for r in range(first - 1, -1, -1):
                if track[r] is not None and track[r].levels is not None:
                    t = sum(self.speeds[r:first])
                    c, since = track[r], t
                    for i in range(last - first):
                        if track[first + i] is not None and track[first + i].levels is not None:
                            break
                        out[i] = c.levels[min(since, len(c.levels) - 1)]
                        since += self.speeds[first + i]
                    break
        return out

    def energy(self, track, r, level_rows):
        """the sound of the note in row r (until the next note of the track)"""
        cell = track[r]
        if cell is None or cell.levels is None:
            return 0
        e, since = 0, 0
        i = r
        while True:
            e += amplitude(cell.levels[min(since, len(cell.levels) - 1)]) * self.speeds[i]
            since += self.speeds[i]
            i += 1
            if i >= level_rows or (track[i] is not None and track[i].levels is not None):
                break
        return e

    def merge(self, first, last, previous):
        """the 3 channels of the pattern (rows first..last-1) : [[cells]], and the order of the tracks"""
        tracks = [t[first:last] for t in self.tracks]
        sounding = [self.sounding(t, first, last) for t in self.tracks]
        n = last - first
        best = None
        for p in range(4):
            for s in range(4):
                if p == s:
                    continue
                # the channel plays p; a note of s replaces the note of p when it brings more sound than the
                # rest of the note of p (until the next note of p), which is lost then
                merged = list(tracks[p])
                lost = 0.0
                current = p
                for r in range(n):
                    c = tracks[s][r]
                    own = tracks[p][r]
                    if own is not None and own.levels is not None:
                        current = p
                    elif own is not None and current == s:
                        merged[r] = None                  # (an effect of p for its note, which is cut)
                    if c is None:
                        continue
                    if c.levels is None:                  # an effect of s for its note
                        if current == s and merged[r] is None:
                            merged[r] = c
                        else:
                            lost += 0.1
                        continue
                    e = self.energy(self.tracks[s], first + r, last)
                    doubled = any(tracks[k][r] is not None and tracks[k][r].note and c.note and
                                  (tracks[k][r].note - c.note) % 12 == 0 for k in range(4) if k != s)
                    gain = e * (0.2 if doubled else 1)
                    tail = 0.0
                    if current == p and own is None:
                        i = r
                        while i < n and (i == r or tracks[p][i] is None or tracks[p][i].levels is None):
                            tail += amplitude(sounding[p][i]) * self.speeds[first + i]
                            i += 1
                    if own is None and (sounding[p][r] <= QUIET or gain > tail * CUT):
                        merged[r] = c
                        lost += tail if current == p else 0
                        current = s
                    else:
                        lost += gain
                if best is None or lost < best[0] - 1e-9:
                    best = (lost, p, s, merged)
        lost, p, s, merged = best
        kept = [k for k in range(4) if k != s]
        channels = {k: (merged if k == p else tracks[k]) for k in kept}
        # the tracks stay in their channels when possible
        order = [None] * 3
        if previous:
            for c, k in enumerate(previous):
                if k in kept and k not in order:
                    order[c] = k
        for k in kept:
            if k not in order:
                order[order.index(None)] = k
        if self.verbose:
            print(f'  rows {first}-{last - 1}: track {s + 1} into track {p + 1}, lost {lost:.1f}, channels '
                  f'{[k + 1 for k in order]}')
        return [channels[k] for k in order], order

    def vibratos(self, channel, first):
        """the vibrato of the instruments : effect 4 when its delay is over"""
        for r, c in enumerate(channel):
            if c is None or not c.note:
                continue
            sound = self.sounds.get(self.instrument_of(c.ins))
            v = sound.vibrato(c.note) if sound else None
            if not v:
                continue
            param, delay = v
            ticks = 0
            i = r
            while i < len(channel) and ticks < delay:
                ticks += self.speeds[first + i]
                i += 1
                if i < len(channel) and channel[i] is not None and channel[i].levels is not None:
                    i = None
                    break
            if i is None:
                continue
            while i < len(channel):
                if channel[i] is None:
                    channel[i] = Cell(0, 0, None, None)
                if channel[i].levels is not None and i != r:
                    break
                if not channel[i].effect:
                    channel[i].effect, channel[i].param = 4, min(255, param)
                    break
                i += 1

    def instrument_of(self, st):
        for (number, _), n in self.variants.items():
            if n == st:
                return number
        return 0

    def portamentos(self, channel, first):
        """the portamento of the ST player works only in rows with the effect : it goes on until the note is
        reached"""
        for r, c in enumerate(channel):
            if c is None or c.effect != 3 or not isinstance(c.pitch, tuple):
                continue
            _, old, new, speed = c.pitch
            ticks = abs(SA_PERIODS[old] - SA_PERIODS[new]) / max(1, speed)
            done = self.speeds[first + r]
            i = r + 1
            while done < ticks and i < len(channel):
                if channel[i] is not None and (channel[i].levels is not None or channel[i].effect):
                    break
                channel[i] = Cell(0, 0, None, None)
                channel[i].effect, channel[i].param = 3, c.param
                done += self.speeds[first + i]
                i += 1

    def place(self, channels, r, effect, param):
        """a global effect (speed, pattern break) in a free effect of the row"""
        for prio in (0, 4, 3, 1, 2):
            for ch in channels:
                c = ch[r]
                if c is None:
                    ch[r] = c = Cell(0, 0, None, None)
                if c.effect == prio:
                    c.effect, c.param = effect, param
                    return
        raise ValueError(f'row {r} : no place for effect {effect:x}')

    def patterns(self):
        """the ST patterns : [[3 x 64 cells]]"""
        cuts = list(range(0, len(self.rows), ROWS))
        if self.restart and self.restart % ROWS:
            cuts = sorted(set(cuts) | {self.restart})
            # the patterns after the restart begin at the restart
            cuts = [c for c in cuts if c < self.restart] + list(range(self.restart, len(self.rows), ROWS))
        cuts.append(len(self.rows))
        out = []
        previous = None
        for a, b in zip(cuts, cuts[1:]):
            channels, previous = self.merge(a, b, previous)
            for ch in channels:
                self.portamentos(ch, a)
                self.vibratos(ch, a)
            if a == 0 or a == self.restart or self.speeds[a] != self.speeds[a - 1]:
                self.place(channels, 0, 0xf, self.speeds[a] - 1)
            for r in range(1, b - a):
                if self.speeds[a + r] != self.speeds[a + r - 1]:
                    self.place(channels, r, 0xf, self.speeds[a + r] - 1)
            if b - a < ROWS:
                self.place(channels, b - a - 1, 0xd, 0)
            out.append((a, channels))
        return out

    # -----------------------------------------------------------------------------------------------------------

    def instrument_data(self, key, arps, noises):
        number, step = key
        sound = self.sounds.get(number)
        levels = self.levels_of(key)
        while len(levels) > 1 and levels[-1] == levels[-2]:
            levels.pop()
        speed = 0
        while len(levels[::speed + 1]) > 100:
            speed += 1
        levels = levels[::speed + 1]
        noise = 0
        if sound is not None and sound.noise:
            noise = noises.setdefault(sound.noise, len(noises))
            levels = [lv | 0x20 for lv in levels]
        arp = 0
        if sound is not None and sound.arp:
            arp = arps.setdefault(sound.arp, len(arps))
        return bytes([0, arp, noise, 0, speed] + levels + [0xff])

    def song(self):
        pats = self.patterns()
        if len(self.variants) > MAX_INSTRUMENTS:
            raise ValueError(f'{len(self.variants)} instruments (at most {MAX_INSTRUMENTS})')
        arps = {None: 0}
        noises = {None: 0}
        instruments = [b'\0\0\0\0\0\0\xff']
        for key, n in sorted(self.variants.items(), key=lambda x: x[1]):
            instruments.append(self.instrument_data(key, arps, noises))
        arp_data = [bytes([0, 0, 0xff])] * len(arps)
        for a, i in arps.items():
            if a:
                values, loop = a
                low = min(values)
                if low < 0:
                    raise ValueError('negative arpeggio')
                arp_data[i] = bytes([0] + list(values) + [0xfe if loop else 0xff])
        noise_data = [bytes([0, 0x20, 0xff])] * len(noises)
        for v, i in noises.items():
            if v:
                noise_data[i] = bytes([0, v, 0xff])
        # the patterns, the same ones once
        unique, order = [], []
        for _, channels in pats:
            data = bytearray()
            for r in range(ROWS):
                for ch in channels:
                    c = ch[r] if r < len(ch) else None
                    if c is None:
                        data += b'\0\0\0\0'
                    else:
                        data += bytes([c.note, c.ins if c.levels is not None else 0, c.effect, c.param & 0xff])
            if bytes(data) not in unique:
                unique.append(bytes(data))
            order.append(unique.index(bytes(data)))
        restart = next(i for i, (a, _) in enumerate(pats) if a >= self.restart)

        def table(records):
            offs, body = [], b''
            for rec in records:
                offs.append(2 * len(records) + len(body))
                body += rec
            return struct.pack(f'>{len(records)}H', *offs) + body
        out = bytearray(LAYOUT[-1][0] + len(unique) * 0x300)
        out[0], out[1] = len(order), restart
        for (pos, size, name), part in zip(LAYOUT, (table(instruments), table(arp_data), table(noise_data),
                                                    bytes(order), b''.join(unique))):
            if size and len(part) > size:
                raise ValueError(f'{name} : {len(part)} bytes (at most {size})')
            out[pos:pos + len(part)] = part
        if self.verbose:
            print(f'  {len(order)} positions, {len(unique)} patterns, {len(self.variants)} instruments, '
                  f'{len(out)} bytes')
        return bytes(out)


def describe(conv):
    for n, s in sorted(conv.sounds.items()):
        ins = s.ins
        kind = 'noise %d' % s.noise if s.noise else ('synth' if ins and ins.synth else 'sample')
        print(f'  instrument {n:2} {ins.name if ins else "?":20} {kind:9} period {s.period:6.1f} '
              f'shift {s.shift:+d}{" chord %s" % s.chord if s.chord else " amf" if s.arp else ""}')


def main():
    args = sys.argv[1:]
    out = MUSIC
    verbose = '-v' in args
    if verbose:
        args.remove('-v')
    force = '-f' in args
    if force:
        args.remove('-f')
    if '-o' in args:
        i = args.index('-o')
        out = args[i + 1]
        del args[i:i + 2]
    for a in args:
        n = int(a)
        print(f'{n} {NAMES[n]}')
        conv = Converter(Module(os.path.join(SONGS, f'SONIC.{NAMES[n]}.sa')), verbose)
        if verbose:
            describe(conv)
        data = conv.song()
        path = os.path.join(out, f'SONG{n:02}.BIN')
        if os.path.exists(path) and not force:
            print(f'  {path} exists (accepted), not replaced (-f)')
            continue
        open(path, 'wb').write(data)


if __name__ == '__main__':
    main()
