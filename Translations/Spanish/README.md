# Spanish translation

A complete Spanish translation of Ambermoon: all game texts, the intro and extro, and the
remake's own texts.

The texts are in [../PO/es.po](../PO/es.po) (see [../README.md](../README.md) for the PO workflow).
`python3 Translations/po.py import es` writes them to `Disks/Bugfixing/Spanish`, the input of the release creator.

| Path | Content |
|---|---|
| [../PO/es.po](../PO/es.po) | All texts: game, intro, extro and remake |
| [Glossary.md](Glossary.md) | Terminology |
| [Names.tsv](Names.tsv) | The translated names (items, spells, monsters, NPCs, places, keywords): German / English / Spanish |
| [TranslatorBrief.md](TranslatorBrief.md) | Rules that were used for translating |
| [tools/make_font.py](tools/make_font.py) | Builds the intro/extro font (`font.json`, `SmallGlyphs.png`, `LargeGlyphs.png`) |
| `encoding.txt`, `font.json`, `*Glyphs.png`, `click-text.txt`, `translators.txt` | Configuration of the release creator for the intro and extro |

## Status

- **Complete:** all 3741 texts of the template are translated.
- **Check:** `python3 Translations/po.py check es` reports 0 errors and 0 warnings.
- **Not done yet:** review by a native speaker, and testing in game (on the Amiga or in the
  remake).
- **Translator:** Claude (Anthropic). Most texts were translated from the German original and
  cross-checked against the English. The intro and extro were translated from the English,
  because there is no German version of these files in the repository.

## Conventions

- **Variety.** European (Castilian) Spanish. The player character is addressed with *tú*, the
  party with *vosotros*.
- **Orthography.** Full Spanish spelling with accented capitals (Á É Í Ó Ú Ü Ñ) and the opening
  marks ¿ ¡.
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

## Amiga release

The release creator (`Tools/AmbermoonReleaseCreator`, run by `.github/workflows/release.yml`) reads
`Disks/Bugfixing/Spanish` and `Translations/Spanish`:

- **Game texts.** `po.py import es` removes ¿ ¡ from the game texts (`AllTexts`), because the in-game font has no
  glyphs for them. The release creator removes the accents itself (`-u`, which also turns Ñ into N).
- **Intro and extro** keep all Spanish characters. They use their own font (ISO-8859-1, 92 glyphs, built from the
  Czech font by `tools/make_font.py`; Ñ ñ Ü ü ¿ ¡ and " were added).
- **Button graphics** are the English ones; there are no Spanish button graphics yet.
- **Date and language.** The release creator writes `DateAndLanguageString` and `VersionString` itself
  ("dd-MM-yyyy / Spanish", "Ambermoon vX.XX"). The files here hold "21-11-2026 / Español" and "Ambermoon v1.22".

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
4. **Accents in game.** On the Amiga, the game texts are shown without accents and Ñ (see *Amiga release*).
   Only the intro and extro show them.
5. **Translator credit.** It is in `ExtroTexts/005/032` (`$_Claude (Anthropic)`).
6. **Places worth checking in game:**
   - The riddles and verses in 2Map_texts 259, 265, 412 and 416.
   - The puns: 285/005 "CARL ACTUS", 411/003 "(PELOTA, PELOTA)", 353/003, and the drunk dwarf in 336/004.
   - The half-faded words in the spider book (`Object_texts.amb/002/000`).
   - Places where German and English contradict each other. The German was followed in, for
     example, 3Map_texts 369/016, NPC_texts 058/007 and NPC_texts 008/009–010.
