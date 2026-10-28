# Music of the Atari ST version

These files are the music of the original Atari ST version of Ambermoon, unpacked and split for the port.

## Where they come from

The ST version stores every song as `AMBR/AMBER<n>.BIN` (in `AmbermoonST/ORIGINAL`), packed with Pack-Ice 2.x
(`ICE!`). Every unpacked file is the same music player followed by the data of one song. The player finds the
song directly behind itself.

`port/tools/port_music.py --extract` unpacks the original files (with `port/tools/ice.py`), checks that the
player is identical in all of them and writes:

| File | Contents |
| --- | --- |
| `PLAYER.BIN` | The player, unchanged: 8294 bytes of 68000 code and tables, then a table of 5 offsets (20 bytes, the same in every file). 8314 bytes. |
| `AMBER<n>.BIN` | The data of one song: what follows the player in the original file `AMBER<n>.BIN`. |
| `SONG<nn>.BIN` | An Amiga song without ST version, converted by `port/tools/sa_to_st.py` (`<nn>` is the number of the Amiga song). Only the converted songs which were accepted by listening are here; the tool doesn't replace them without `-f`. |

The build doesn't need `ORIGINAL`. `port_music.py` makes `MUSPLAY.I` for the kernel from `PLAYER.BIN`: the player
once, with its Timer B moved to Timer D (see the notes in `port_music.py` and `KERNEL/MUSIC.S`). `Music.amb` gets
the song files: the ST version of the song, else the converted one, else nothing (silence).

## The songs

The numbers of the ST files are not the numbers of the Amiga songs. They were matched by listening
(`ST_FILES` in `port_music.py`):

| ST file | Song | Amiga song |
| --- | --- | --- |
| `AMBER1.BIN` | Ship | 6 |
| `AMBER2.BIN` | Compact Disc | 15 |
| `AMBER4.BIN` | Don't Look Bach | 9 |
| `AMBER5.BIN` | Downtown | 5 |
| `AMBER10.BIN` | Voice of the Bagpipe | 4 |
| `AMBER11.BIN` | Nobody's Vault but Mine | 17 |
| `AMBER12.BIN` | Horse Is No Disgrace | 8 |
| `AMBER13.BIN` | Riverside Travelling Blues | 16 |
| `AMBER14.BIN` | Plodding Along | 14 |
| `AMBER15.BIN` | Mellow Camel Funk | 2 |
| `AMBER16.BIN` | Sapphire Fireballs of Pure Love | 11 |
| `AMBER17.BIN` | La Crypta Strangiato | 18 |
| `AMBER18.BIN` | Whole Lotta Dove | 7 |
| `AMBER19.BIN` | Variant of `AMBER11` (other order of the patterns) | - |
| `AMBER20.BIN` | Variant of `AMBER15` (starts at the end of the song) | - |

`AMBER3` and `AMBER6`-`AMBER9` don't exist on the ST disks. The other Amiga songs have no ST version; they are
converted from the Amiga version (`SONG<nn>.BIN`).

## Song data format

The last 20 bytes of `PLAYER.BIN` are a table of 5 offsets (long words, relative to the table): instruments,
arpeggio tables, noise tables, order list, patterns. The table is the same in every file, so every song has the
same layout. Offsets below are relative to the start of the song data (the table + 20):

| Offset | Size | Contents |
| --- | --- | --- |
| `$000` | byte | Song length (entries in the order list) |
| `$001` | byte | Restart position |
| `$002` | `$800` | Instruments |
| `$802` | `$240` | Arpeggio tables |
| `$A42` | `$140` | Noise tables |
| `$B82` | `$100` | Order list |
| `$C82` | `$300` per pattern | Patterns |

**Instruments, arpeggio and noise tables** each start with a table of word offsets (relative to that
table). An instrument or table number in the song uses only its lower 5 bits.

**Instrument:**

| Byte | Contents |
| --- | --- |
| 0 | Type: 0 tone, 1/2 envelope (buzzer), 3/4 envelope + tone, 5/8 tone + timer effect (SID), 6/7 other envelope + tone combinations |
| 1 | Arpeggio table |
| 2 | Noise table |
| 3 | Volume reduction |
| 4 | Speed of the volume sequence |
| 5… | Volume sequence: bits 0-4 volume (bit 4 is the envelope mode of the YM2149), bit 5 turns the tone off; a negative byte holds the last value |

**Arpeggio table:** speed, then note offsets. `$ff` holds the last value, another negative byte restarts the
table.

**Noise table:** speed, then values. Bit 5 turns the noise off, otherwise the value is the noise period. A
negative byte holds the last value.

**Order list:** one pattern number per position.

**Pattern:** `$300` bytes, 64 rows × 3 channels × 4 bytes:

| Byte | Contents |
| --- | --- |
| 0 | Note (0 none, 1 = C of the lowest octave) |
| 1 | Instrument (0 none) |
| 2 | Effect |
| 3 | Effect parameter |

**Effects:**

| Effect | Meaning |
| --- | --- |
| `1` | Slide up |
| `2` | Slide down |
| `3` | Tone portamento |
| `4` | Vibrato |
| `5` | Timer detune |
| `C` | Volume reduction |
| `D` | Pattern break |
| `F` | Speed (ticks per row − 1) |

The player is called 50 times per second.
