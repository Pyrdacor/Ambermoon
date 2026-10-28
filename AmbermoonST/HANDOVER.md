# Handover: Atari ST port

State of the work and what is needed to continue it. The plan, the design and the stages are in
[PORT.md](PORT.md); this file has the working knowledge which is not in the code.

## Conventions (wishes of the project owner)

* Answers to the project owner in **German**.
* As close to the original as possible ("wie im Original"): when in doubt, look up what the original code
  does (`AmbermoonSource/src`) instead of guessing. The game logic is not re-implemented any more: the
  original files are assembled unchanged, only the hardware kernel is new.
* Static, precomputed ST palettes (`port/tools/port_palettes.py`), no palettes computed at run time.
* Work on the branch `ccr-9a694101-ljput5`, no pull request unless asked.
* Changes of original files only as patches in `port/PATCHES/*.diff`, every changed line marked `; ST:`.
* No model names in commits or code.

## Parts

| Path | What |
| --- | --- |
| `src/`, `build.sh`, `run_hatari.sh` | Proof of concept: the game re-implemented routine by routine (no longer extended). |
| `tools/st_convert.py` | Data and palette conversion of the proof of concept; `make_palette` is also used by the port. |
| `port/AMBERST.S` | Include list of the port: `AMBERMOON.S` of the original with the Amiga kernel replaced (`; ST: replaced`). |
| `port/KERNEL/` | ST kernel with the interface of the Amiga kernel (the 99 missing symbols). |
| `port/PATCHES/` | Patches of original files: `MEMORY` (memory, blitter), `VARIOUS` (sound DMA), `EVENTS` (palette before picture). |
| `port/tools/port_data.py` | Game files (German 1.20 + `Disks/Bugfixing/German/Amberfiles`) with 8.3 names → `build/port/hd/DATA`, `FILEMAP.I`. |
| `port/tools/port_music.py`, `ice.py` | Music of the ST version (`ORIGINAL/AMBR`, Pack-Ice): the player once → `MUSPLAY.I`, the songs → `Music.amb`. |
| `port/tools/port_palettes.py` | ST palettes of all Amiga palettes → `build/port/STPALS.I` (made again only when the script changed). |
| `port/test/` | Hatari test runner, scenarios, symbol and frame tools (below). |

## Build

    VASM=/path/to/vasmm68k_mot ./port/build.sh      # → build/port/hd/AMBERST.PRG + DATA

Needs vasm (Motorola syntax, here `/opt/tools/vasm/vasmm68k_mot`), Python 3 with Pillow, and the data in
the repository (`Disks/German/ambermoon_german_1.20_extracted.zip`, `ExtractedGameFiles.zip` for the
palettes). `build/` is not in git. The warnings of vasm (auto-aligned data, overflow in `NUMERIC.S`)
are normal.

## Testing in Hatari

Hatari as STE (a plain ST works too), **at least 2 MB** (with 1 MB the program ends at once), the folder
`build/port/hd` as GEMDOS drive, EmuTOS (here `/opt/tools/emutos/emutos-256k-1.4/etos256us.img`).

    TMO=120 port/test/run.sh port/test/scenarios/editor_event_map.txt out.avi 3000
    python3 port/test/run.py port/test/scenarios/editor_event_map_vbl.txt out.avi 2700   # Windows too
    python3 port/test/frames.py out.avi scan 30                       # where the screen changes
    python3 port/test/frames.py out.avi sheet sheet.png 400,1500,2316,2999
    python3 port/test/frames.py out.avi get -1 last.png
    python3 port/test/sym.py build/port/hd/AMBERST.PRG Raster_VBL      # address of a symbol
    python3 port/test/sym.py build/port/hd/AMBERST.PRG -w 3d9fe        # symbol of an address (crash PC)

* `run.sh` starts Hatari without a window, records an AVI (one PNG frame per VBL) and sends the
  scenario lines through the command FIFO. `{Name}` in a line is replaced by the address of the symbol,
  so scenarios survive new builds (the addresses change with every build).
* Hatari loses FIFO commands which come too fast: always put a `sleep` between two commands. The sleeps
  are real time, the emulation runs faster than real time, so frame numbers of a scenario differ a little
  from run to run.
* Mouse clicks: `click left|right` writes `ST_mouse_buttons` (IKBD state, bit 1 left, bit 0 right), the
  kernel makes the original `Button_state` from it (a set bit means pressed, like the original).
  `move x y` writes `Mouse_X`/`Mouse_Y` (screen coordinates 0-319, 0-199).
* The free scrolling text at the end of an event text ends with the **right** button (like the original).
* Breakpoints: `b pc = {Raster_VBL} && HBL > 2 :trace` reports every vertical blank which comes late
  (then the palette changes are on the wrong lines); `matched` in the log counts the hits.
  `b pc = $x :trace :file cmds.ini` runs debugger commands on a hit (`r` registers, `m addr` memory).
* EmuTOS writes crash information to `$380` (magic, d0-d7, a0-a7; at `$3c4` the exception number and the
  PC). Read it with `m $380` after a crash and give the PC to `sym.py -w`.
* The text segment starts at `$15bf0` with EmuTOS 1.4 and a GEMDOS drive; with another TOS set
  `TEXT_BASE` for `sym.py`.

## Technical notes

* **Colours:** the Amiga screen keeps colour numbers, the ST converts while drawing. The lookup table comes
  from the raster list of the current module (`Get_ST_LUT`), else from the current fade. Where the original
  draws first and loads the palette afterwards, the colours are wrong and a small patch is needed (example:
  `EVENTS.diff`).
* **Palettes:** an entry of `STPALS.I` is 32 Amiga colours, 16 STE colours, the lookup table (32 bytes)
  and the representative Amiga colour of every ST colour (16 bytes); `Find_ST_palette` takes the exact
  match, else the nearest one. The UI colours have fixed ST colours in every palette: Amiga 25 → 9, 26 → 10,
  27 → 11, 28/29 → 12, 30/31 → 14 (the 6 frame shades merged to 4); the other 10 ST colours (1-8, 13, 15) are
  chosen per palette. A 3-plane UI graphic becomes p0 = a0 & ~a2, p1 = a1, p2 = a2, p3 = mask.
* **Fading** is the original `Current_RL` logic. `Store_RL_source` keeps the target colours of every
  palette (index = offset in `Current_RL` / 66) and finds its ST palette once; `Render_raster` makes the
  raster events (Timer B) from it, `Fade_ST_palette` fades every ST colour like its representative.
  Nothing slow may run per frame in the VBL: a VBL longer than a frame moves the colours on the screen.
* **Libraries:** `LIBS.S` emulates exec/dos/graphics with jump tables at the LVO offsets (6 bytes per
  entry) on top of GEMDOS. Timer C runs only during file access.
* **Graphics:** Amiga planar data (1-5 planes, line interleaved, base colour); value 0 is transparent in
  masked blocks and black in unmasked ones. Converted blocks are cached (`Convert_block`).
* **Music:** the ST version (`ORIGINAL/AMBR/AMBER<n>.BIN`, n = Amiga song number; 1, 2, 4, 5, 10-20) has
  one player (8294 bytes + offset table) in front of every song; the player finds the song directly behind
  itself. `port_music.py` stores the player once (`MUSIC.S`, `Music_player`, followed by `Music_data`),
  `Music.amb` gets size + data of every song (32 entries, the missing ones size 0 = silence).
  `_SA_Hardcalc` copies the song behind the player, init/stop is offset 0 (d0 = 1/0), play is offset 8
  (VBL). The player uses Timer A and Timer B for effects; its Timer B is moved to **Timer D** (Timer B is
  the raster), the accesses to the shared C/D control register call `Music_timer_D_*`. The kernel switches
  to 50 Hz (`Video_sync`), like the PAL Amiga. `SOUND=44100` puts the music into the AVI of `run.py`
  (Hatari writes 60 fps into the AVI header : convert with `-r 50`, video and audio separately).
* **Pitfalls:** the original sources are Latin-1 (`encoding='latin-1'` in Python). With `-align` vasm can
  put a label which stands alone before `ds.w` on an odd address: use `even`. The program needs the
  `jmp Start` at the start of the text segment (TOS starts there).

## Open points

* **Crash reported by the owner:** after the first event picture, a click which should return to the map
  crashed Hatari. Not reproduced (STE and ST, 2 and 4 MB, many fast clicks). A probable cause is fixed
  (a pending Timer B interrupt continued the old raster list while it was made anew, commit `64a176cf`).
  If it comes again: ask for the PC of the crash, the TOS version and the Hatari settings.
* After the character editor the screen stays black for about 9 seconds before the first event picture:
  not examined (loading, conversion of graphics?).
* With 1 MB the program ends without a message.
* Next stages (PORT.md): play through the 2D map (movement, events, dialogues, inventory, places, chests),
  combat (zoom of the monsters, `STUBS.S`), 3D maps (68000 replacement of `divsl.l` in `MAP/3D_RENDER.S`,
  drawing of walls, floor and ceiling), music of the songs without ST version (3, 6-9, 21-32, e.g. 31 in the
  character editor), diagnostic screen, speed and memory.
