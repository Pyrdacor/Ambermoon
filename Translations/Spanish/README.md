# Spanish translation (work in progress)

This folder contains the groundwork for a Spanish translation of Ambermoon.

| File | Content |
|---|---|
| [Glossary.md](Glossary.md) | Terminology: classes, races, skills, spells, items, places, keywords |
| [Sample/AllTexts](Sample/AllTexts) | Sample translation, same layout as `AllTexts.zip` |
| [tools/check_translation.py](tools/check_translation.py) | Validator for placeholders, line breaks, characters and length limits |

## Status

**Draft / sample.** No native speaker has reviewed it yet, and it has not been tested in game.

The sample covers the game's opening:

- `2Map_texts.amb/258`: Grandfather's house
- `2Map_texts.amb/259`: Grandfather's cellar, including the stone-head riddle (keyword *VINO*)
- `NPC_texts.amb/001`: Grandfather's dialogue
- matching entries in `Dict.amb`, `Objects.amb`, `NPC_char.amb`, `Monster_char.amb` and the
  he/she/his/her texts in `Text.amb/UITexts`

## Conventions

- **Source text.** Translated from the German original and cross-checked against the English
  version. Where the English file layout differs from the German one, the English layout is
  used, because the English data is the base for new languages. Example: `NPC_texts.amb/001/005`
  contains the full text in English, but German splits it across 005 and 007.
- **Variety.** European (Castilian) Spanish. The player character is addressed with *tú*, the
  party with *vosotros* (e.g. "OÍS", "CONSEGUÍS"). Switching to neutral Latin American Spanish
  (*ustedes*) would be a global search-and-review task, so it should be decided early.
- **Orthography.** Full Spanish spelling, including accents on capitals (Á É Í Ó Ú Ü Ñ) and the
  opening marks ¿ and ¡. If the font cannot get these glyphs,
  `check_translation.py --fallback-out <dir>` produces a copy with accents and opening marks
  removed. **Ñ is always kept**, because dropping it changes meaning (AÑO → ANO).
- **Gender.** The original only offers `~SEX1~` (he/she) and `~SEX2~` (his/her) for the subject.
  Spanish also inflects adjectives and participles (*cansado/cansada*), and the protagonist
  (`~SELF~`) may be female. Texts that refer to the player or the active character are therefore
  phrased gender-neutrally. Example: the grandfather calls the hero *"sangre de mi sangre"*
  instead of *"mi querido nieto"*, and the narration says *"en tu infancia"* instead of
  *"de pequeño"*.
- **Riddles and rhymes.** These are re-written as Spanish verse, not translated word for word. The
  stone head speaks in octosyllables with assonance (*pasarás / tendrás*, *vino / camino*). The
  keyword the riddle expects must match the `Dict.amb` entry exactly.
- **Placeholders.** `~LEAD~`, `~SELF~`, `~SEX1~`, `~INK17~`, `{0}` and the line-break
  character `^` are kept as they are. The validator checks this.

## Length limits

These limits are based on the longest existing German, English and French entries and on the
game's data structures. `check_translation.py` enforces them.

| Data | Limit |
|---|---|
| Item names (`Objects.amb`) | 19 |
| NPC / monster names | 15 |
| Dictionary words | 21 |
| Place names (`Place_data`) | 30 |
| Class names | 7 |
| Race names | 10 |
| Attribute / skill short names | 3 |
| Spell names (`Text.amb`) | 21 (19 recommended, so scrolls can use the same name) |

## Validation

```
python3 tools/check_translation.py Sample/AllTexts
python3 tools/check_translation.py Sample/AllTexts --fallback-out /tmp/es_ascii
```

By default the reference is `Disks/Bugfixing/English/AllTexts`.

## Open questions (for the maintainer)

1. **Font.** Which glyphs can be added? Minimum: Ñ/ñ. Desirable: Á É Í Ó Ú Ü, ¿ ¡ and lower case
   with accents (the remake and some UI texts use mixed case). This also determines the
   `encoding.txt` code page. All Spanish characters are in ISO-8859-1 (the Amiga's native
   character set) and in CP850.
2. **Typed words.** Can the player type Ñ or accented letters when answering riddles or asking
   about keywords? If not, keywords that are typed should avoid them, or the input should be
   normalised (e.g. ÁMBAR ⇄ AMBAR).
3. **Gender-dependent endings.** Optionally, a new placeholder for the ending *-o/-a* of the
   subject would allow more natural texts than neutral phrasing. This would need a change in
   the code and the remake.
4. **Variety.** European Spanish (*vosotros*) or Latin American (*ustedes*)?
