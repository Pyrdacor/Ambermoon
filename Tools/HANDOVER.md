# Ambermoon ports: state of the work and how to continue

The task: port all command line tools of [Ambermoon](https://github.com/Pyrdacor/Ambermoon) (`AmbermoonTools`, not the
tools with a user interface) to CShift, with the parts of the libraries of
[Ambermoon.net](https://github.com/Pyrdacor/Ambermoon.net) that they need, and optimize them where it makes sense. The
ports live in this folder (`Tools/` of the Ambermoon repository; they were made in the CShift repository, folder
`Ambermoon/`, and moved here when they were done); [README.md](README.md) describes each library and tool, how it was checked and
everything that is different from the original. This file is the handover: what is done, what is left, how the ports
were checked and what was found in the originals.

The command line tools are done: the release creators were the last ones (AmbermoonPatcher is skipped, as asked). The standard library
has `System.Image` (PNG, BMP, PPM) and `System.Compression` (deflate, zlib, gzip, CRC-32) for them now.


## Done

Libraries: `Ambermoon.Common`, `Ambermoon.Data.Common`, `Ambermoon.Data.Legacy`, `Ambermoon.Data.Descriptions`,
`Ambermoon.Data.Text.Patching`, `AmbermoonTextPacks`, `AmbermoonBitmaps`, `Amiga.FileFormats`, `Ambermoon.Release`
(the parts that the tools need).

| Tool | Checked against the original (details in README.md) |
|---|---|
| AmbermoonPack | all files of the game, 491 packing runs, byte for byte; 60-300x faster |
| AmbermoonEventEditor | all listings, 1200 random editing sessions |
| HexValueChanger | sessions with all commands |
| AmbermoonIntroTextPacker, AmbermoonExtroTextPacker, AmbermoonExtroIntroTextPackCreator | all translations, all text encodings |
| AmbermoonDiskExtract | the ADF images of English 1.07/1.20, German 1.20 |
| AmbermoonListExtractor | English and German 1.20 |
| AmbermoonLabdataEditor, AmbermoonLabdataExtractor, AmbermoonUsedColorsDetector, Ambermoon3DMapViewer | all 3D maps and labyrinths of 1.20, 400 random editing sessions |
| AmbermoonMonsterEditor | 82 command lines on English 1.07/1.20, German 1.20 |
| AmbermoonItemEditor | more than 600 random sessions (item files of 1.20, executables of 1.07) |
| AmbermoonNameExtract | export and import of all kinds of names |
| AmbermoonTextImport | export and import of all text files with all options |
| AmbermoonTextManager | export of 1.20 and 1.07, import (gives the files of 1.20 byte for byte, 100x faster) |
| AmbermoonIntroPatcher | the Czech intro base with Czech and English texts, all encodings |
| AmbermoonExtroPatcher | the Czech extro base with the Czech, English and Polish extro texts, translators, config files |
| AmbermoonPaletteChanger | 200 runs: 50 images (all PNG and BMP variants) with four palettes, pixels compared through GDI+ |
| AmbermoonImageConverter | 195 command lines: all formats, frames, offsets, transparent/forbidden indices, errors |
| AmbermoonFontCreator | the Czech and Polish fonts, all glyph atlases of the repository, 14 changed specifications |
| AmbermoonFontProcessor | 120 random sessions on the glyph atlases (the original patched to run its GlyphTool) |
| AmbermoonReleaseCreator | the releases of English, Czech, Polish, French and German: the same archives (entries, contents, ADF images byte for byte) |
| AmbermoonAdvancedReleaseCreator | folders and versions, errors: the same output and archives |

`Tools/tests/run.sh` (in the CShift repository it was part of `tests/run_tests.sh`) checks the tools that need no game data with synthetic data
against recorded results of the originals (`tests/expected.txt`, `tests/tools/make_data.py`), and builds the others
(`BUILD_ONLY`). The checks of the tools that need the game data were done by hand with the scripts in
`tests/reference/` (see below); their game data cannot be in the repository.

Also fixed on the way: a bug of the compiler (temporaries of a conversion in a branch of a conditional expression,
`selfhost/src/CodeGen/Expr.csh` of the CShift repository, test `tests/cases/arc_conditional_conversion_temps.csh`).


## Left to do

The remaining command line projects of `AmbermoonTools` (the others have a user interface and are not ported:
Ambermoon3DMapEditor, AmbermoonButtonGraphicsDesigner, AmbermoonCharEditor, AmbermoonEditor, AmbermoonImageEditor,
AmbermoonMapCharEditor, AmbermoonMapEditor2D, AmbermoonMapEditor3D, AmbermoonUIEventEditor):

1. ~~AmbermoonPatcher~~: skipped (as asked; the original does not compile: `FileManager.GetTexts` is unfinished,
   `Parser` uses an undefined `rValue` and has type errors).
2. ~~The release creators~~: done. `Amiga.FileFormats` is a port of the writing parts of the packages
   Amiga.FileFormats.ADF 1.0.5 and .LHA 1.0.1 (sources: github.com/Pyrdacor/Amiga, the commits are in the nuspec files
   of the packages), `Ambermoon.Release` has zip and tar.gz. The release creator runs the tools as programs like the
   original (`AMBERMOON_TOOLS` or the `PATH`); calling them in the same process would need TextManager without its
   globals and its `Environment.Exit`. Compared on Windows with `tests/reference/scripts/releasecreator.py` (see
   README.md for how the original is built for it).
3. ~~The image tools~~: done (see above). They were checked on Windows, where `System.Drawing` of the originals
   works; the pixels were compared by a small .NET program that dumps what GDI+ decodes (the decoders of
   `System.Image` give the same pixels as GDI+, also its rounding: see `docs/stdlib.md`). The library
   `AmbermoonBitmaps/src/GdiBitmap.csh` knows which pixel format GDI+ gives a file (indexed, RGB without alpha, ARGB),
   which decides what `SetPixel` does in the originals. AmbermoonMonsterBattleImageGenerator was skipped (as asked).
4. Skip the rest
5. Optional: golden tests with synthetic game data for the tools that need game data (they are only built by
   `tests/run.sh` now), e.g. labyrinths and maps for LabdataExtractor, monster and item files for the editors.

The task list of the work (in the order it was done): libraries and AmbermoonPack, the event editor, the small tools,
the game data (ADF, executables), the labyrinth tools, the characters and items (monster, item and name tools), the
texts (TextImport, TextManager, IntroPatcher, ExtroPatcher), the image tools (with System.Image and
System.Compression in the standard library), the release creators (with File.SetLastWriteTime in the standard
library). Left: the optional golden tests (5.).


## How the ports were checked (tests/reference/)

The originals are built from the sources of the Ambermoon repository against the library sources of Ambermoon.net
(not the NuGet packages), then the port and the original run the same inputs in copies of the same folder, and the
console output, the exit code and all files are compared.

- `tests/reference/setup.sh [REF]` clones both repositories and unpacks the game data of their `Disks` folder
  (English 1.20 files, English 1.07, German 1.20, French 1.17 ADF images and files). Checked with Ambermoon at aa291929
  and Ambermoon.net at ce0cfca, with the .NET 8 SDK.
- `tests/reference/build.sh <Tool> [REF]` builds an original into `REF/tools/<Tool>/out/<Tool>.dll` and applies
  `tests/reference/patches/<Tool>.diff` (`NOPATCH=1` builds it unchanged). The patches make the original do what the
  port does where the original fails (they are the fixes listed in README.md, made in the original), so that everything
  else can be compared exactly. Patched: AmbermoonEventEditor (+ Ambermoon.Data.Descriptions), AmbermoonListExtractor,
  AmbermoonExtroIntroTextPackCreator, AmbermoonMonsterEditor, AmbermoonItemEditor, AmbermoonNameExtract,
  AmbermoonIntroPatcher.
- `tests/reference/scripts/compare.sh <original dll> <port binary> <cases file>`: runs each case (`arguments|stdin`)
  in fresh copies of a folder `in/` and compares. The output lines are sorted before the comparison (the order of
  some lines of the originals is random, see below).
- `tests/reference/scripts/genlab.py` and `genitem.py` make random sessions for the labyrinth and the item editor;
  `hunks.py` shows the hunks of an Amiga executable.
- `tests/reference/helper/` (copy it to `REF/helper`, it references `../lib`): makes a "translation base" of an intro
  or extro (the last data hunk replaced by a 12-byte placeholder for the fonts, which IntroPatcher expects; the repository
  has no intro base: it was made from `Translations/Czech/Intro/Ambermoon_intro_eng`), dumps the code pages of .NET
  (`--cp 852`, the source of `Ambermoon.Data.Text.Patching/src/CodePageTables.csh`) and resolves encoding names
  (`--names`).

Test data used: the Czech, English and Polish texts in `Disks/Bugfixing/<language>/` (IntroTexts, ExtroTexts) and
`Translations/` of the Ambermoon repository, the fonts `Translations/Czech/Extro/Extro_fonts` and
`AmbermoonTools/AmbermoonExtroPatcher/Extro_fonts`, the extro base `Translations/Czech/Extro/Ambermoon_extro_translation_base`.


## Bugs found in the originals

All are listed with the behavior of the port in README.md ("Different from the original"); the most important ones:

- **AmbermoonMonsterEditor** does not work at all with the current library: it builds an unused `GraphicProvider`
  that ends with a NullReferenceException (null palette list) and, for 1.14 and newer, runs out of memory reading the
  messages of the new executable the old way; it reads only `Monster_char_data.amb` (1.14+: `Monster_char.amb`), and it
  fails at the empty files in the monster container. Its range messages show the wrong parameters for `--all`.
- **AmbermoonItemEditor**: editing an existing item cannot work (each value is read at one position and written at the
  next: wrong values shown, then an exception); saving the executables cuts the second code hunk of AM2_BLIT to a quarter
  (`Size / 4` where Size is in dwords) and so breaks AM2_BLIT; a second save breaks the item data (old item count kept);
  negative signed values cannot be entered; searching with an added item without a name and removing a negative number
  end with an exception.
- **AmbermoonNameExtract**: importing goto points breaks every map that has goto points (drops its first two bytes and
  the automap types of 3D maps); exporting and importing with game data ends with an exception for places, the
  dictionary and the items (it reads where loading the game data left the readers); 30-character place names lose their
  last character; it does not compile with the current library (`TextDictionary.Load` signature).
- **AmbermoonTextManager**: the order of its output changes from run to run (`ImmutableDictionary` with randomized
  string hashes); `-c` fails for the dictionary ("Data can't be compressed with text lob"); the goto point import assumes
  288 positions for characters that move by the hour (12 are stored).
- **AmbermoonIntroPatcher / AmbermoonExtroPatcher**: they take the text files in the order of the file system
  (`Directory.GetFiles` is sorted on Windows only); an output file without a folder ends with an exception; the intro
  patcher needs a prepared intro whose font hunk is a 12-byte placeholder.
- **AmbermoonLabdataEditor**: the backup of a file with an extension goes to `<name>_backup/<extension>` (a folder that
  does not exist); empty labyrinth files end with an exception.
- **AmbermoonDiskExtract**: writes `2Wall3D.amb`, `2Object3D.amb` and `3Object3D.amb` changed (loading the game data
  merges textures into the containers and moves reader positions).
- **AmbermoonListExtractor**: does not compile with the current library (`NumberOfFreeHands`); English 1.07 ends with an
  exception.
- **AmbermoonPack**: `JH+AMBR` and REPACK of JH+AMBR fail; extended LOB with exactly 256 literals at the start fails.
- **AmbermoonEventEditor**: maps 296 and 403 (ChangeBuffs for all buffs) cannot be listed; several commands end with
  exceptions or endless loops on branches outside of the events and chains that are loops.
- **HexValueChanger**: the documented inputs Enter (keep) and `~` (invert) are rejected; bytes outside a file end with
  an exception.
- **AmbermoonExtroIntroTextPackCreator**: a relative output folder is lost (written into its temporary folder); the usage
  names AmbermoonReleaseCreator.
- **AmbermoonPatcher**: does not compile (see above).
- .NET behavior that the ports reproduce on purpose: culture-aware `StartsWith`/`EndsWith` with ICU ignore `\0`, soft
  hyphens and similar characters (a text ending with two spaces "ends with" `" \0 "`); `Encoding.GetEncoding("iso-8859-1")`
  uses best-fit replacements (— becomes `-`); `File.WriteAllText(path, text, Encoding.UTF8)` writes a byte order mark.


## Notes for porting to CShift

What came up again and again (see also the existing ports):

- Strings are UTF-8: `text.Length` is bytes. Where the original uses lengths or indices of UTF-16 characters use
  `LengthNet`, `FirstCharactersNet` (Ambermoon.Common) or convert to UTF-16 units (see `Utf16Units` in the extro patcher).
- .NET emulation in `Ambermoon.Common`: `ParseInt`/`ParseUInt`/`ParseLong`/`ParseHex`/`ParseHexLong` (int.TryParse and
  friends), `TrimNet`/`TrimStartNet`/`TrimEndNet`, `ToLowerNet`/`ToUpperNet`, `IsWhiteSpaceOnlyNet`,
  `StartsWithNet`/`EndsWithNet`/`EqualsNet` (culture-aware), `ReadAllTextNet` (BOM detection, invalid UTF-8 like .NET),
  `FindFiles`/`GetFiles`/`GetDirectories` (sorted), `EnumInfo`/`EnumText` (Enum.ToString, [Flags]).
- No `out` parameters (return a struct), `x is not T y` binds only as the whole condition of an `if`, avoid lambdas that
  capture (use explicit loops), `List<T>.Create()`, arithmetic is checked (cast or `unchecked(...)`), `Error<T>` with
  `try` and `is error e`. CShift has no API for the path of the program (tools read from the current folder instead).
- Build with `build.sh` / `build.ps1` (the latest release of CShift), or `cshiftc build <Tool>` in this folder.
