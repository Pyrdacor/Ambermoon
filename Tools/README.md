# Ambermoon Tools

Pyrdacor's suite of command line tools for the data files of Ambermoon, written in
[CShift](https://github.com/Robert-Schneckenhaus/CShift): they are the tools of [AmbermoonTools](../AmbermoonTools)
(which are deprecated now) as native programs, without .NET, with the parts of the libraries of
[Ambermoon.net](https://github.com/Pyrdacor/Ambermoon.net) that they need. Their results are those of the original
tools (see *How the port was checked* below), the bugs of the originals are fixed (see *Different from the original*),
and many of them are much faster.

The tools with a user interface (Ambermoon3DMapEditor, AmbermoonButtonGraphicsDesigner, AmbermoonCharEditor,
AmbermoonEditor, AmbermoonImageEditor, AmbermoonMapCharEditor, AmbermoonMapEditor2D, AmbermoonMapEditor3D,
AmbermoonUIEventEditor) are not part of it, nor are AmbermoonPatcher (the original does not compile) and
AmbermoonMonsterBattleImageGenerator.

## Build it

The build scripts download the latest release of the CShift compiler (it brings its own clang and linker) and build
all tools into `bin/`:

```
./build.sh          # Linux (and Git Bash on Windows): needs curl or wget, tar and xz; and build-essential
.\build.ps1         # Windows (PowerShell 5.1 or 7)
```

If the compiler cannot be downloaded (no network, ...), they use one that is there already: the newest one in
`.cshift/`, else `cshiftc` on the `PATH`. A compiler can also be given (`./build.sh path/to/cshiftc`,
`.\build.ps1 -Compiler path\to\cshiftc.exe`, or the environment variable `CSHIFTC`). `get-cshift.sh` and
`get-cshift.ps1` only download the compiler (into `.cshift/`) and print its path.

The release creators need CShift 0.29 or newer (`File.SetLastWriteTime`); with 0.28 all other tools build.

A single tool: `cshiftc build AmbermoonPack` (the program is then `AmbermoonPack/bin/AmbermoonPack`).

`bash tests/run.sh [path/to/cshiftc]` builds all tools and compares their results for synthetic data with those of
the original tools (`tests/expected.txt`); `tests/reference/` has the scripts that compared the ports with the
originals on the data of the game.

## Releases of the game (GitHub Actions)

A push to a branch named `release/vX.XX` (e.g. `release/v1.21`) builds the releases of version X.XX in all languages
([.github/workflows/release.yml](../.github/workflows/release.yml)), on Windows like the original release creator:
the tools are built with the latest release of CShift, then AmbermoonReleaseCreator makes the German release (of the
previous German release in `Disks/German` and the files in `Disks/Bugfixing/German`) and with it the releases of the
other languages that have texts in `Disks/Bugfixing` (Czech, English, French, Polish). The archives are the artifacts
of the run and are attached to a draft release *Ambermoon X.XX* (tag `game-vX.XX`; the tags `vX.XX` belong to the
releases of the tools), which is published by hand; they are not committed. The workflow can also be started by hand
(*Actions* → *release* → *Run workflow*) with a version, once it is on the default branch. The times in the releases
are the time of the commit (`SOURCE_DATE_EPOCH`), so the same commit gives the same release.

## Use it

Most tools have a help: run them with `--help`. The command lines are those of the originals (see *Usage* below).

## The tools

| Folder | What it is | Port of |
|---|---|---|
| `Ambermoon.Common/` | library: directions, the texts of enums and floats as .NET writes them, numbers, files and texts read as .NET reads them | `Ambermoon.Common` (parts) |
| `Ambermoon.Data.Common/` | library: events, maps, labyrinths, tilesets, characters, monsters, items, graphics, texts and the enumerations they use | `Ambermoon.Data.Common` (parts) |
| `Ambermoon.Data.Legacy/` | library: big-endian readers and writers, the file formats (JH, LOB, VOL1, AMNC, AMNP, AMBR, AMPC), the LOB compressions, loading the game data from folders and ADF disk images, Amiga executables (also imploded), the data of the executable (names, messages, items, ...), Text.amb, maps, labyrinths and their textures, characters, monsters, events | `Ambermoon.Data.Legacy` (parts) |
| `Ambermoon.Data.Descriptions/` | library: descriptions of the values of all event types (for editors) | `AmbermoonTools/Ambermoon.Data.Descriptions` |
| `AmbermoonTextPacks/` | library: the intro and extro text packs of the remake (shared by the three text pack tools) | the packing code of the text packers |
| `AmbermoonPack/` | packs files into the formats of the game and unpacks them | `AmbermoonTools/AmbermoonPack` |
| `AmbermoonEventEditor/` | edits the events of maps, NPCs and party members | `AmbermoonTools/AmbermoonEventEditor` |
| `HexValueChanger/` | changes bytes at an offset in one or many files | `AmbermoonTools/HexValueChanger` |
| `AmbermoonDiskExtract/` | extracts the files of the game from its ADF disk images | `AmbermoonTools/AmbermoonDiskExtract` |
| `AmbermoonListExtractor/` | writes the party members of the game as a Markdown table | `AmbermoonTools/AmbermoonListExtractor` |
| `AmbermoonLabdataEditor/` | shows and edits the walls, objects and object data of a labyrinth (a file of `2Lab_data.amb`) | `AmbermoonTools/AmbermoonLabdataEditor` |
| `AmbermoonLabdataExtractor/` | writes a labyrinth with only the walls and objects that a 3D map uses | `AmbermoonTools/AmbermoonLabdataExtractor` |
| `AmbermoonUsedColorsDetector/` | shows the colors that the textures of a 3D map use | `AmbermoonTools/AmbermoonUsedColorsDetector` |
| `Ambermoon3DMapViewer/` | shows a 3D map as text and the walls and objects of its blocks | `AmbermoonTools/Ambermoon3DMapViewer` |
| `AmbermoonMonsterEditor/` | shows and changes values of the monsters (`Monster_char.amb`, before 1.14 `Monster_char_data.amb`) | `AmbermoonTools/AmbermoonMonsterEditor` |
| `AmbermoonItemEditor/` | shows, adds, edits and removes items (`Objects.amb/001`, before 1.14 in `AM2_CPU` and `AM2_BLIT`) | `AmbermoonTools/AmbermoonItemEditor` |
| `Ambermoon.Data.Text.Patching/` | library: the fonts of the intro and the extro, patching them into executables, the code pages of .NET for the texts of translations | `AmbermoonTools/Ambermoon.Data.Text.Patching` |
| `AmbermoonIntroPatcher/` | writes the texts and fonts of a translation into the intro | `AmbermoonTools/AmbermoonIntroPatcher` |
| `AmbermoonExtroPatcher/` | writes the texts, translators and fonts of a translation into the extro (re-flows the lines to fit) | `AmbermoonTools/AmbermoonExtroPatcher` |
| `AmbermoonTextImport/` | exports the texts of a text file (map texts, `Text.amb`, ...) into text files and imports them | `AmbermoonTools/AmbermoonTextImport` |
| `AmbermoonTextManager/` | exports all texts and names of the game into text files and imports them | `AmbermoonTools/AmbermoonTextManager` |
| `AmbermoonNameExtract/` | exports the names of characters, places, goto points, the dictionary and items into text files and imports them | `AmbermoonTools/AmbermoonNameExtract` |
| `AmbermoonIntroTextPacker/` | packs the intro texts of a translation into `Intro_texts.amb` | `AmbermoonTools/AmbermoonIntroTextPacker` |
| `AmbermoonExtroTextPacker/` | packs the extro texts of a translation into `Extro_texts.amb` | `AmbermoonTools/AmbermoonExtroTextPacker` |
| `AmbermoonExtroIntroTextPackCreator/` | makes both text packs of a language from the texts in the Ambermoon repository | `AmbermoonTools/AmbermoonExtroIntroTextPackCreator` |
| `AmbermoonBitmaps/` | library: graphics of the game as images, palettes as colors, and how GDI+ loads image files (its pixel formats) | `AmbermoonTools/AmbermoonBitmaps` |
| `AmbermoonPaletteChanger/` | replaces each color of an image by the nearest color of a palette of the game | `AmbermoonTools/AmbermoonPaletteChanger` |
| `AmbermoonImageConverter/` | converts an image into the bit planes of a graphic of the game (3, 4, 5 bit planes, textures, multi-tile graphics) | `AmbermoonTools/AmbermoonImageConverter` |
| `AmbermoonFontCreator/` | makes a font file of the extro from a JSON specification and two glyph atlases | `AmbermoonTools/AmbermoonFontCreator` |
| `AmbermoonFontProcessor/` | copies glyphs of a glyph atlas into free slots (adds rows) and saves it | `AmbermoonTools/AmbermoonFontProcessor` (its GlyphTool) |
| `Amiga.FileFormats/` | library: ADF disk images (OFS/FFS, bootable) and LHA archives (LH5 to LH7) as the packages Amiga.FileFormats.ADF and .LHA write them | `Amiga.FileFormats.ADF`, `Amiga.FileFormats.LHA` (the writing parts) |
| `Ambermoon.Release/` | library: zip files (reading, and writing like .NET's `ZipFile`), tar.gz files like SharpZipLib, the archives of a release | `Package` of the release creators |
| `AmbermoonReleaseCreator/` | makes a release of a language (texts, intro, extro, fonts and boot disk patched): the ADF images and the archives | `AmbermoonTools/AmbermoonReleaseCreator` |
| `AmbermoonAdvancedReleaseCreator/` | makes the archives of prepared folders of Ambermoon Advanced | `AmbermoonTools/AmbermoonAdvancedReleaseCreator` |
| `tests/` | tests with expected results of the original tools; `tests/reference/`: building the originals and comparing them with the ports | |

[HANDOVER.md](HANDOVER.md) has the state of the work: what is left to port, how the ports were checked and the bugs
found in the original tools.

## Usage

The command lines are the ones of the originals:

```
AmbermoonPack UNPACK 2Map_data.amb maps              # the files of a container as maps/001, maps/002, ...
AmbermoonPack AMPC maps 2Map_data.amb -c3 -v         # packs them again (best of three LOB compressions)
AmbermoonPack REPACK Monster_char.amb out.amb -c2    # a container in another compression
AmbermoonPack JH+LOB Dict Dict.amb 0xd2e7           # JH-encrypted LOB with the key 0xd2e7

AmbermoonEventEditor maps/258 0                      # the events of map 258 (0: map, 1: NPC, 2: party member)

HexValueChanger -r saves '*.sav'                     # the same bytes changed in all files *.sav below saves/
AmbermoonIntroTextPacker Czech                       # Czech/IntroTexts/*.txt -> Czech/Intro_texts.amb
AmbermoonExtroTextPacker Czech "<KLIK>" "DANIEL ZIMA"  # Czech/ExtroTextGroups/ -> Czech/Extro_texts.amb
AmbermoonExtroIntroTextPackCreator czech 1.00 out    # in the Ambermoon repository: out/Intro_texts.amb, out/Extro_texts.amb
AmbermoonDiskExtract adfs extracted                 # the files of the ADF images in adfs/ (-u: decompressed)
AmbermoonListExtractor Amberfiles lists              # lists/PartyMembers.md
AmbermoonLabdataEditor labdata/001 Amberfiles      # edits labdata/001 (an unpacked file of 2Lab_data.amb)
AmbermoonLabdataExtractor labdata/001 maps/258 new  # new: labyrinth 001 with only what map 258 uses
AmbermoonUsedColorsDetector 258 Amberfiles           # the colors of the textures of map 258
Ambermoon3DMapViewer maps/258 Amberfiles            # map 258 as text, then the walls and objects of blocks
AmbermoonMonsterEditor "big spider" 0x18 2 1000    # in the game data folder: the word at 0x18 of the monster
AmbermoonItemEditor Objects/001                     # the items of an unpacked Objects.amb (or a 1.07 game data folder)
AmbermoonTextImport -e Amberfiles 1Map_texts.amb texts   # texts/1Map_texts.amb/001/000.txt, ...
AmbermoonTextImport -i Amberfiles 1Map_texts.amb texts   # and back (-c: the best compression)
AmbermoonIntroPatcher base Czech/IntroTexts out/Ambermoon_intro fonts 852   # the intro of a translation
AmbermoonExtroPatcher base Czech/ExtroTexts out fonts 852 "<KLIK>" "DANIEL ZIMA"   # the extro of a translation
AmbermoonExtroPatcher config.json                   # the same with a config file (see example-config.json)
AmbermoonTextManager -e Amberfiles texts            # all texts and names of the game
AmbermoonTextManager -i Amberfiles texts -f Text.amb   # Text.amb back into the game data
AmbermoonNameExtract e Amberfiles names              # all names as names/NPC_char/001.txt, ...
AmbermoonNameExtract i Amberfiles names              # and back into the game data (backups: *.backup)
AmbermoonPaletteChanger image.png Palettes/001 32 out.png   # the colors of palette 001
AmbermoonImageConverter item.png Palettes/001 item.bin 5    # 5 bit planes (0: textures, 1: multi-tile, 3, 4)
AmbermoonFontCreator font.json SmallGlyphs.png LargeGlyphs.png Extro_fonts
AmbermoonFontProcessor SmallGlyphs.png [commands.txt]   # copy <index> | save [path] | exit
AmbermoonReleaseCreator Czech 1.20                  # in the Ambermoon repository: Disks/Czech/ambermoon_czech_1.20_*
AmbermoonAdvancedReleaseCreator D:\rel 1.20         # D:\rel\<lang>\ambermoon_advanced_<lang>_1.20_extracted.zip, ...
```

AmbermoonReleaseCreator runs the tools AmbermoonTextManager, AmbermoonFontCreator, AmbermoonIntroPatcher and
AmbermoonExtroPatcher (the ports, or the originals) from the folder of the environment variable `AMBERMOON_TOOLS`, or
from the `PATH` (the original builds them with `dotnet publish` from the sources in the repository). With
`SOURCE_DATE_EPOCH` (seconds since 1970) set, its date and times are that time instead of the current one (the texts,
the ADF images, the times of the empty folders in the zip files), so that a release can be made again the same way.

The image tools read and write PNG, BMP and PPM with `System.Image` of the standard library (the originals use
`System.Drawing`, which reads more formats - GIF, JPEG, TIFF - but works on Windows only).

## How the port was checked

* **AmbermoonPack**: UNPACK of all files of the game, and packing of all 65 unpacked containers and files with combinations of the
  compressions (`-c0` to `-c5`), the dictionary compressions (`-d1` to `-d4`) and all types: 491 runs, the files and
  the console output (`-v` included) are the same byte for byte as those of the original (built from the sources of
  Ambermoon.net).
* **AmbermoonEventEditor**: the listings of all maps, NPCs and party members, and 1200 random editing sessions (all
  commands, random answers, saved at the end): the output and the saved files are the same as those of the original
  (with the crashes of the original that are fixed here fixed the same way in it, see below).
* **The text pack tools**: the packs of all translations in the Ambermoon repository (Czech, English, Polish; with
  their translators and click texts), and texts in all encodings that .NET reads (byte order marks of UTF-8, UTF-16
  and UTF-32, invalid UTF-8): the same files and output as the originals.
* **HexValueChanger**: sessions with all commands on one file and on file patterns, also recursive.
* **The game data** (loading, ADF images, imploded executables, the data of the executable, Text.amb): everything
  that is read (files, names, messages, texts, glyphs, cursors, palettes, user interface graphics, buttons, items)
  is the same as in the original for English 1.07 (the old executable) and 1.20 and German 1.20, extracted and as ADF
  images. Loading is about 20 times faster.
* **AmbermoonDiskExtract**: the files of the ADF images of English 1.07 and 1.20 and German 1.20, encoded and
  decompressed (see below for the three files that differ); 300 times faster (the original recompresses with its slow
  LOB compression).
* **AmbermoonListExtractor**: the party members of English and German 1.20 (extracted and ADF).
* **The labyrinth tools**: `AmbermoonLabdataExtractor` for 441 maps of 1.20 with their labyrinths,
  `AmbermoonUsedColorsDetector` for all 84 3D maps, `Ambermoon3DMapViewer` for all 3D maps with the info of their
  blocks, `AmbermoonLabdataEditor` in 400 random editing sessions (all commands, random answers, saved at the end):
  the output and the files are the same as those of the original (where the original does not end with an exception,
  see below).
* **AmbermoonItemEditor**: more than 600 random editing sessions (all commands, random answers, saved at the end) on
  the item files of English and German 1.20 and the executables of English 1.07: the same output and files (also
  `AM2_CPU` and `AM2_BLIT`) as the original, with its bugs fixed in it the same way (see below).
* **AmbermoonTextImport**: the export of all text files of English and German 1.20 (also `Text.amb`) with all options,
  and the import of the exported texts and of changed ones (umlauts, spaces and zeros at the ends, soft hyphens, gaps
  in the numbering, missing and empty folders with the questions answered), also with the extended compression: the
  same output and files as the original.
* **AmbermoonIntroPatcher**: the intro of the Czech translation (made into a base: its font hunk a placeholder) with
  the Czech and English intro texts, both extro fonts, the code pages and encoding names, and all errors: the same
  output and files as the original.
* **AmbermoonExtroPatcher**: the Czech extro base with the extro texts of the Czech, English and Polish translations
  and the English text groups, both fonts, code pages and encoding names, one or more translators, config files, and
  the errors: the same output and files as the original.
* **AmbermoonTextManager**: the export of English 1.20 and 1.07 (whose `Text.amb` it makes of the executable), the
  import of the exported texts (which gives the files of 1.20 byte for byte) and of changed ones (long names with
  warnings, umlauts and other letters with and without `-u`, line breaks, single files with `-f`, `-x`, `-c`): the
  same output and files as the original. The import is more than 100 times faster (0.3 s instead of 40 s).
* **AmbermoonNameExtract**: the export and import of all kinds of names, of containers and of the game data (English
  and German 1.20, also ADF images), with missing names (asked for), changed and too long ones: the same output and
  files as the original, with its bugs fixed in it the same way (see below). The export is 20 times faster.
* **AmbermoonMonsterEditor**: 82 command lines (all options, invalid numbers and ranges, ids and names, changes with
  backups) in the data of English 1.07 and 1.20, German 1.20 (names with umlauts), an empty folder and ADF images: the
  same output, exit codes and files as the original (with the patches that make it work at all, see below).

* **The image tools** (on Windows, where `System.Drawing` of the originals works): the pixels that `System.Image`
  decodes are the ones GDI+ gives for 70 test images (all PNG color types and bit depths, interlaced, with
  transparency; BMP with 1 to 32 bits, RLE, bit fields, OS/2 headers, written by GDI+ too), and GDI+ reads every file
  that `System.Image` writes with the same pixels. `AmbermoonPaletteChanger`: 200 runs (those images, four palettes of
  the game and their color counts): the same pixels and file formats as the original. `AmbermoonImageConverter`: 195
  command lines (images with exact, transparent and other colors, all formats, frames, offsets, transparent and
  forbidden indices, palettes from images, the errors): the same output and files. `AmbermoonFontCreator`: the fonts
  of the Czech and Polish translations with all glyph atlases of the repository and 14 changed specifications (case
  of the names, defaults, errors, output folders): the same output, exit codes and files. `AmbermoonFontProcessor`:
  120 random sessions on the glyph atlases of the repository (copies that add rows, saves, invalid commands, command
  files): the same output and pixels as the original (with the call of its GlyphTool, see below).

* **The release creators** (on Windows, like the originals, which run there in the pipeline of the repository):
  `AmbermoonReleaseCreator` for English, Czech, Polish, French (each of 1.20 German) and German (1.19 with the
  bugfixes): the same exit codes and output, and the same six archives: the same entries in the same order with the
  same contents (all files of the game, the patched intro and extro, the fonts, the boot disk), the ADF images in them
  byte for byte (also with dates, with `SOURCE_DATE_EPOCH` set for both), the LHA archives byte for byte except the
  times; the error cases too (`tests/reference/scripts/releasecreator.py`; the original built with
  `FRAMEWORK=net9.0` and against the sources of the Amiga.FileFormats packages in which `DateTime.Now` reads
  `SOURCE_DATE_EPOCH`). The ADF writer gives the same images as the package for the ten disks of a release, the LHA
  writer the same archives (with the same file times); the size sort of the ADF writer is .NET's introsort (the same
  order of equal sizes, checked for 300 lists). `AmbermoonAdvancedReleaseCreator`: folders and versions, errors: the
  same output, the same tar.gz and LHA files, the same zip entries.

## Different from the original

The output is the same (the texts of .NET included: enum names, `[Flags]` combinations, the rounding of `0.00`
formats). What is different:

**Faster.** The match trie of the LOB compressions is the same algorithm, but stored in arrays and a hash table
instead of objects and sorted dictionaries, and without the copy of all nodes at every byte that the original makes
when it removes old matches. Packing is 60 to 300 times faster:

| | original | CShift |
|---|---|---|
| `AMNP 1Map_data.amb -c0` | 134 s | 0.44 s |
| `AMNP Monster_gfx.amb -c0` | 55 s | 0.16 s |
| `AMNP Music.amb -c2` | 11.7 s | 0.19 s |
| `AMNP 2Wall3D.amb -c1` | 11.1 s | 0.13 s |
| `UNPACK 1Map_data.amb` | 0.11 s | 0.02 s |

**Fixed failures of the original** (it ends with an exception in these cases):

* AmbermoonPack: `JH+AMBR` packs (with a key like `JH`), and `REPACK` of JH+AMBR files works; the original fails with
  "File type 'JHPlusAMBR' is no valid container format". Extended LOB (`-c1`) of exactly 256 literals at the start.
  `UNITEM` of a file without file 1, `PKITEM` of a folder without numbered files, empty arguments. Damaged files give
  an error message (in the original some cases end with an exception). UNITEM unpacks in memory (the original leaves a
  temporary folder behind).
* AmbermoonEventEditor: maps with a ChangeBuffs event for all buffs (maps 296 and 403: the original cannot list them;
  this shows "All"); `connect` with an index outside of the events; `edit` with a new event type that is aborted;
  `reorder`, `copychain` and `graph` with branches to indices outside of the events; chains that are loops (`chain`,
  `remove`); "Make the successor the new chain start" for an event without a successor (only offered when there is
  one); files that are too short; the end of the input (ends the program).
* HexValueChanger: the documented inputs that did nothing work: Enter keeps a byte, `~` inverts it (the original
  rejects both as invalid), and an invalid length is 1 as the message says (the original then asks for no byte). A
  mask that is out of range is asked again without applying the operation to the next value. Bytes behind the end of
  a file (or before its start) are left out with a message (the original ends with an exception, also when only one
  of several files is too short). A file or folder that does not exist gives an error message; the end of the input
  ends the program (the original asks for the offset again forever).
* The text packers: file and folder names without a number give an error message (the original ends with an
  exception).
* AmbermoonExtroIntroTextPackCreator: an output folder given as a relative path is written (the original changes the
  current folder to its temporary folder first, so the files end up there and are deleted with it). The usage line
  names the tool (the original says "AmbermoonReleaseCreator"). Missing source folders or files give an error message.

* AmbermoonDiskExtract writes the files that are on the disks. The original writes `2Wall3D.amb`, `2Object3D.amb`
  and `3Object3D.amb` changed: when it loads the game data, it loads the labyrinths, which merges the textures of
  `3Wall3D.amb` and `3Object3D.amb` into the containers of `2Wall3D.amb` and `2Object3D.amb` and moves the positions
  of readers that it then writes from. Without a destination folder the files are written into the current folder (the
  original writes them into the folder of the program).
* AmbermoonListExtractor: game data without a party member's map character gives an error message (English 1.07: the
  original ends with an exception). The original does not compile with the current library (it uses
  `NumberOfFreeHands`, now `NumberOfOccupiedHands`).
* The labyrinth tools: an empty labyrinth file (1.20 has six: `2Lab_data.amb` 20 to 25) or one that is too short
  gives "The labyrinth data is incomplete." (the original ends with an exception). Numbers in the input of
  `Ambermoon3DMapViewer` that are not numbers are asked again, and the end of the input ends the program in it and
  in `AmbermoonLabdataEditor` (the original ends with an exception). `AmbermoonLabdataEditor` reads the graphics of
  the labyrinth as the original does, but without merging the textures of `3Wall3D.amb` and `3Object3D.amb` into
  those of `2Wall3D.amb` and `2Object3D.amb` (it uses a merged copy); its backup of a file with an extension is
  `<name>_backup<extension>` (the original writes `<name>_backup/<extension>` and fails because the folder does not
  exist).
* AmbermoonMonsterEditor works with the data of the game. The original ends with an exception before it does anything:
  it makes a graphic provider that it does not use, which fails with the current library (for 1.14 and newer it runs
  out of memory reading the messages of the executable the old way), it reads only `Monster_char_data.amb` (since 1.14
  `Monster_char.amb`: this reads and writes that one when the other is missing) and it fails at the empty files in it
  ("Invalid Monster_char_data.amb file."; this skips them, as the library does). The id of an empty file gives "No
  monster exists with id" (the original ends with an exception). `--all` and `--all-not-0` without an offset and a
  size show the usage, and their range messages show the given offset and size (the original shows other parameters or
  ends with an exception). The game data is read from the current folder (the original looks into the folder of the
  program first), without the battle graphics of the monsters (which the tool does not use).
* AmbermoonItemEditor: editing an item that exists works. The original reads each value at one position and writes
  it at the next: it shows wrong current values and ends with an exception halfway (for an item file it then says
  "Unable to load item data." and ends). Saving the executables keeps `AM2_BLIT` whole (the original cuts its second
  code hunk to a quarter: it takes the size in dwords for bytes), and saving twice works (the original keeps the old
  number of items and breaks the data the second time). Negative values of signed bytes (hit points, damage, ...) can
  be entered (the original takes no negative numbers, so Enter on a negative current value sets the default). Finding
  items while an added item has no name yet, removing a negative number and starting without an argument work (the
  original ends with an exception); the end of the input ends the program (the original ends with an exception or, for
  an item file, says "Unable to load item data.").
* AmbermoonTextImport: the end of the input when it asks whether to continue is "no" (the original ends with an
  exception), and texts that do not fit `Text.amb` (a wrong number of texts) give an error message. The folders of
  texts are read in the order of their names (the original takes the order of the file system, which only decides
  which error is shown first).
* AmbermoonIntroPatcher: the text files are taken in the order of their names (the original takes the order of the
  file system, which is that order on Windows but not on Linux). An output file without a folder works (the original
  ends with an exception). Texts with characters that the font does not have and damaged executables give an error
  message (the original ends with an exception). The encodings are those of the code pages 437, 850, 852, 866, 1250,
  1251, 1252, 28591, 28592, 28605, 20127 and 65001 (UTF-8) and their names (the original takes all of .NET).
* AmbermoonExtroPatcher: errors give a message where the original ends with an exception or shows one with its stack
  trace (unknown encodings, characters that the font does not have, invalid config files, folder names shorter than 3
  characters, more than 6 click groups). An output file without a folder works. Folders and files with the same number
  are taken in the order of their names (the original takes the order of the file system for them). The encodings are
  those of AmbermoonIntroPatcher.
* AmbermoonTextManager: the text files are listed in a fixed order (the original takes them from an
  `ImmutableDictionary`, whose order changes from run to run). Missing folders, numbers of places, items and goto
  points that do not match the data, and damaged data give an error message (the original ends with an exception or
  shows one with its stack trace). With `-c` the dictionary falls back to the LOB of the original game where the text
  LOB cannot compress it (the original fails). Goto points are found also on maps with characters that move by the
  hour (the original takes 288 positions instead of 12 for them). `-u` removes the marks of Latin, Greek and Cyrillic
  letters (the original decomposes all characters of Unicode).
* AmbermoonNameExtract: importing goto points keeps the maps intact (the original drops the first two bytes of each
  map with goto points and the automap types of 3D maps behind them: the maps can no longer be read). With the game
  data, the places, the dictionary and the items are read from their start (the original reads them where loading the
  game data left the readers, at their end, and ends with an exception). Place names of 30 characters are kept (the
  original keeps 29, which cuts two place names of the English game). Missing files, folders and names of the game data
  and names of text files that are no numbers give an error message (the original ends with an exception); so does the
  end of the input when a name is asked for (nothing is written then). The backup is a copy (the original moves the
  file).
* Damaged ADF images and data give error messages where the original ends with an exception (the French 1.17 images
  in the Ambermoon repository have a damaged `2Object3D.amb`: both fail).
* AmbermoonPaletteChanger works with images that GDI+ loads with a palette (PNG and BMP with 1, 4 or 8 bits without
  transparency; the original ends with an exception in `SetPixel`); missing or invalid arguments, a palette file
  shorter than the number of colors and files that are no images give an error message (the original ends with an
  exception).
* AmbermoonImageConverter: an image that does not fit the format and the frames (the frames reach past the image or
  the output) and texts as optional numbers give an error message, as does a palette image with fewer than 32 pixels
  (the original ends with an exception, or reads behind the pixels of the palette image).
* AmbermoonFontCreator: invalid JSON (and numbers that are no integers of the right size) gives the message for a
  specification that cannot be read, and images that cannot be read give an error message (the original ends with
  an exception).
* AmbermoonReleaseCreator: the tools are not built with `dotnet publish` (their output is not there); they are taken
  from `AMBERMOON_TOOLS` or the `PATH` and started by their full path (the original starts them from its temporary
  folder, which Windows does not do when `NoDefaultCurrentDirectoryInExePath` is set). The German release does not
  contain `AmbermoonTextManager.exe` (the original publishes it into the files of the release and does not delete it
  again: the German archives of the repository contain it). Missing files and folders, a language whose boot disk
  texts are missing (only German, French, Czech and Polish have them) and files that do not fit on a disk give an error
  message (the original ends with an exception, or writes an empty ADF image for a full disk); the temporary folder is
  always deleted. The zip files are deflated by System.Compression (not zlib-ng): the same entries and header fields,
  other compressed bytes; the gzip data likewise. The first line of `readme.txt` and `liesmich.txt` (version and date)
  is replaced byte-wise: the rest of the file keeps its encoding and line endings (the original reads and writes them as
  UTF-8 text with CRLF, which turns the ISO-8859-1 umlauts of `liesmich.txt` into replacement characters). The German
  disk A contains `liesmich.txt` as well, as the German hard disk installer copies it (#137, also in the original).
* AmbermoonAdvancedReleaseCreator: without arguments it shows the usage (the original's check of the number of
  arguments is never true: it ends with an exception); a relative folder works (the LHA writer of the original ends with
  an exception for it). The names in the tar.gz files are relative to the current folder also when the path is written
  with `/` (the original compares the paths with the current folder character by character, so on Windows a path with
  `/` stores the full path as a GNU long name).
* AmbermoonFontProcessor: the original does nothing as it is: its program only declares functions, the call of
  `GlyphTool.Main(args)` is commented out. The port is that GlyphTool. `exit` ends it (in the original it does
  nothing), and so does the end of the input (the original asks again forever); `tests/reference/patches/` has these
  changes for the original.

**Faster and simpler.** AmbermoonExtroIntroTextPackCreator packs the texts itself (with `AmbermoonTextPacks`): the
original copies them into a temporary folder in the layout of the packers, builds both packers with `dotnet publish`
and runs them. The texts and the packs are the same; translator names are passed as they are (the original quotes
them for a command line, which breaks names with quotes).

The game data is loaded when it is needed: `GameData` loads the files (from the folder or the ADF images), and the
parts are made from them on demand (`ExecutableData.FromGameData`, `MapManager.Create`, maps by `GetMap`). The
original makes all parts when it loads the data (graphics, all maps and labyrinths, songs, the intro and extro, ...).

**Small differences.**

* The image tools read PNG, BMP and PPM (the originals: what GDI+ reads, also GIF, JPEG, TIFF and icons, but no PPM).
  Writing a PNG gives the same pixels as GDI+ in another (usually smaller) file; a BMP with transparent pixels keeps
  its alpha channel (GDI+ writes 32-bit BMPs whose alpha it ignores when it reads them). The messages of failed file
  operations are those of CShift, not of .NET.

* AmbermoonPack sorts file names byte by byte; the original uses the sort order of the current culture (this only
  matters for names that are not numbers, in different case). A type is a name in capitals or a number (the original
  also takes lists like "LOB,AMBR").
* The library: characters that the encoding of the game does not have become the best fit of .NET's ISO-8859-1 as in
  the original (— is "-", “ is '"', Ā is "A"; else "?"). `DataReader` and `DataWriter` are values (passed as `ref`);
  reading past the end gives zeros and sets `Overrun()` instead of throwing. `FileWriter.WriteJH` does not encrypt the
  caller's array in place. Events are a union of the event kinds in an `EventStore` with ids instead of objects with
  references.

Kept as in the original (it is what the original does, not a failure): the descriptions use a display mapping only the
first time a value is shown (the original sets it to null "to avoid recursive loops" and never back), display names
that the editor changes stay changed, and JH+LOB always uses the LOB of the original game. The text tools compare the
ends of texts like .NET's culture-aware `StartsWith` and `EndsWith`, which ignore zeros, soft hyphens and other
characters (so a map text that ends with two spaces counts as one that ends with " \0 " and gets no " \0 ").
