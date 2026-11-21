# Spanish translation

A complete Spanish translation of Ambermoon: all game texts, the intro and extro, and the
remake's own texts.

| Path | Content |
|---|---|
| [AllTexts](AllTexts) | All game texts, same layout as `Disks/Bugfixing/English/AllTexts` (3448 files) |
| [IntroTexts](IntroTexts), [ExtroTexts](ExtroTexts) | Intro and extro, same layout as `Disks/Bugfixing/English/` |
| [RemakeTranslatableTexts.txt](RemakeTranslatableTexts.txt) | Remake messages, outro and tutorial texts |
| [Glossary.md](Glossary.md) | Terminology |
| [Names.tsv](Names.tsv) | Every translated name (items, spells, monsters, NPCs, places, keywords): German / English / Spanish |
| [TranslatorBrief.md](TranslatorBrief.md) | Rules that were used for translating |
| [tools/check_translation.py](tools/check_translation.py) | Validator for placeholders, line breaks, characters and length limits |
| [tools/missing_files.py](tools/missing_files.py) | Lists reference files without a Spanish counterpart |
| [tools/short_names.py](tools/short_names.py) | Source of all name lists. It regenerates Dict, Objects, monsters, NPCs, places, automap labels and the Text.amb name lists |

## Status

- **Complete:** every reference file has a Spanish counterpart.
- **Validator:** 0 errors and 0 warnings. It checks placeholders, `^` line breaks, the
  character set and the length limits.
- **Not done yet:** review by a native speaker, and testing in game (on the Amiga or in the
  remake).
- **Translator:** Claude (Anthropic). Most texts were translated from the German original and
  cross-checked against the English. The intro and extro were translated from the English,
  because there is no German version of these files in the repository.

## Conventions

- **Variety.** European (Castilian) Spanish. The player character is addressed with *tú*, the
  party with *vosotros*.
- **Orthography.** Full Spanish spelling with accented capitals (Á É Í Ó Ú Ü Ñ) and the opening
  marks ¿ ¡. If the font cannot get these glyphs,
  `check_translation.py --fallback-out <dir>` writes a copy without accents and opening marks.
  **Ñ is always kept.**
- **Rune texts** (`~RUN1~…~NORM~`) use plain A–Z only.
- **Gender.** The player character and the active party member can be male or female, so texts
  that refer to them avoid gendered adjectives and participles. The grandfather, for example,
  calls the hero *"sangre de mi sangre"*. `~SEX1~` = ÉL/ELLA, `~SEX2~` = SU.
- **Riddles and verse** are rewritten as Spanish verse. The Illien stone-head riddles (map 416)
  were adapted so that the answers match the dictionary entries NARIZ, AGUJA, ESPEJO and ARO.
  The rune statues show the answers reversed (ZIRAN, AJUGA, OJEPSE, ORA).
- **Layout.** Where German and English differ in file structure, placeholders or line breaks,
  the English layout is used, because the English data is the base for new languages.
- **Junk bytes.** Junk bytes at the end of some source files (`\0`, `STOP.`) were dropped.

## Length limits

| Data | Limit |
|---|---|
| Item names (`Objects.amb`) | 19 |
| NPC / monster names | 15 |
| Dictionary words | 21 |
| Place names (`Place_data`) | 30 |
| Class names | 7 |
| Race names | 10 |
| Attribute / skill short names | 3 |
| Spell names (`Text.amb`) | 21 |

## Validation

```
python3 tools/check_translation.py AllTexts
python3 tools/check_translation.py IntroTexts --ref ../../Disks/Bugfixing/English/IntroTexts
python3 tools/check_translation.py ExtroTexts --ref ../../Disks/Bugfixing/English/ExtroTexts
python3 tools/missing_files.py
```

## Open points for review

1. **Font.** The game font (and the intro font) needs at least Ñ/ñ. Á É Í Ó Ú Ü ¿ ¡ are wanted
   too. The code page for `encoding.txt` could be ISO-8859-1 or CP850; both contain every
   Spanish character.
2. **Typing keywords.** Whether Ñ and accented letters can be typed on the Amiga depends on the
   keymap. In the remake it should work. Keywords affected: SÓTANO, ÁMBAR, ANTÍDOTO, ÁRBOL,
   SÍLFIDE, ALMACÉN, CARTOGRAFÍA, MALDICIÓN, HABITACIÓN, LÍOS, PALABRAS MÁGICAS, SALAS DE PRÁCTICAS.
   The riddle answers (NARIZ, AGUJA, ESPEJO, ARO, VINO) contain no special characters.
3. **UI abbreviations.** LP → PV, SP → PM, SLP → PAM, APR → A/R, G: → O: (oro). EP stays "EP"
   because the field width is fixed. ON/OFF → SÍ/NO.
4. **Version string.** `Text.amb/DateAndLanguageString` and `VersionString` use the English
   date and version. Adjust them at release time.
5. **Translator credit.** It is in `ExtroTexts/005/032` (`$_Claude (Anthropic)`).
6. **Places worth checking in game:**
   - The riddles and verses in 2Map_texts 259, 265, 412 and 416.
   - The puns: 285/005 "CARL ACTUS", 411/003 "(PELOTA, PELOTA)", 353/003, and the drunk dwarf in 336/004.
   - The half-faded words in the spider book (`Object_texts.amb/002/000`).
   - Places where German and English contradict each other. The German was followed in, for
     example, 3Map_texts 369/016, NPC_texts 058/007 and NPC_texts 008/009–010.
