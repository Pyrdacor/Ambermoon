> **Note:** this brief was written for translating into the text folders. The texts are now in `Translations/PO/es.po`; the rules for the texts are the same.

# Brief for translating Ambermoon text files into Spanish

Read this whole brief before you translate anything. Also read `README.md` (conventions),
`Glossary.md` (terminology) and `Names.tsv` (every name already translated: items, spells,
monsters, NPCs, places, dictionary keywords) in this folder.

## Files

- German original (primary source): `Disks/Bugfixing/German/AllTexts/<path>`
- English version (layout reference and second opinion): `Disks/Bugfixing/English/AllTexts/<path>`
- Spanish output: `Translations/Spanish/AllTexts/<same path>`

Write one Spanish file for every **English** file in your assigned folders, with the same
relative path and file name. Use UTF-8 **with BOM** (the source files have one) and do not add a
trailing newline. Skip files that already exist in the Spanish output; they are finished.
If an English file exists but there is no German one, translate the English one.
Where German and English contents differ (e.g. English merged two texts into one file), the
**English file content/structure decides what goes into the file**, but translate the wording
from the German wherever the German has it. German is the original and usually better.

The most reliable way to write the files is a small Python script per batch, for example:
`open(path, 'w', encoding='utf-8-sig', newline='').write(text)`.
Make sure the directories exist first.

## Style

- European Spanish. Narration addresses the player character as **tú** and the party as
  **vosotros** ("oís", "veis", "tenéis"). NPCs talking to the party use **vosotros**. A noble or
  servant speaking very formally may use **vos/vuestra merced** sparingly where the German is
  noticeably archaic. Otherwise use *vosotros*.
- Keep the tone of the original: slightly old-fashioned fantasy, humorous where the German is.
  Write natural, idiomatic Spanish, not a word-for-word copy of the German sentence structure.
- **Case:** keep the case of the source. Most game texts are ALL CAPS, and Spanish ALL CAPS keeps
  its accents: Á É Í Ó Ú Ü Ñ, and opening ¿ ¡. Mixed-case source → mixed-case Spanish.
- **Allowed characters:** printable ASCII plus Á É Í Ó Ú Ü Ñ á é í ó ú ü ñ ¿ ¡. Nothing else: no
  curly quotes, no dashes other than '-', no "…". Use the same quote characters as the source.
- **Gender:** `~SELF~` (the protagonist), `~LEAD~` (active character), `~CAST~`, `~INVN~`,
  `~SUBJ~` can be male or female. Never use gendered adjectives or participles for them. Rephrase
  neutrally instead: "~LEAD~ SIENTE UN GRAN CANSANCIO", not "~LEAD~ ESTÁ CANSADO". The same goes
  for "you" (tú) and the party (vosotros): "OS SENTÍS CON MÁS FUERZAS", not "OS SENTÍS FUERTES".
  `~SEX1~` = ÉL/ELLA, `~SEX2~` = SU (his/her). German sometimes glues an ending to them
  (e.g. `~SEX2~N`): in Spanish write just `~SEX2~` with no glued letters.
  Known male or female NPCs get their correct gender, of course.

## Placeholders and markup (critical: the game breaks if these are wrong)

- Keep every `~XXXX~` placeholder exactly, in the same number:
  `~LEAD~ ~SELF~ ~CAST~ ~INVN~ ~SUBJ~ ~SEX1~ ~SEX2~ ~INK 30~ ~INK17~ ~RUN1~ ~NORM~` etc.,
  and keep `{0}`, `{1}`, … in format strings. Move them only where Spanish word order requires it.
- `^` is a line break, `^^` an empty line. Keep the same number of `^`, in the corresponding
  places (paragraph structure, verse lines, signs). Never put real newlines into a file.
- `$` is a non-breaking space; keep it. Keep a leading `_` or `$` marker in extro texts.
- Text between `~RUN1~` and `~NORM~` is shown in a rune font: write it in plain A–Z only
  (no accents, no Ñ). If the runes spell a word that matters for a puzzle (often written
  backwards), make the Spanish runes spell the Spanish answer the same way.
- Numbers, prices and times stay. Write times in 24-hour format ("DE 8 A 20 H").

## Names and keywords

- Use the Spanish forms in `Names.tsv` and `Glossary.md` **exactly** whenever a text mentions an
  item, spell, monster, NPC, place or class. Proper names not listed stay as in the German
  original (most are invented: Newlake, Burnville, Spannenberg, Gemstone, Godsbane, ...).
  Spanish forms of common names: Antonius → Antonio, Georg → Jorge.
- **Dictionary keywords (`Dict.amb`) are fixed.** When an NPC mentions a topic the player can
  then ask about, or a text names a password or riddle answer, use exactly the Spanish keyword
  from `Names.tsv` (Dict.amb rows), e.g. VINO, SÓTANO, HERMANDAD, MANO DE PLATA, PALABRA DE
  APERTURA. The keyword text in `>...<` or quotes must match the dictionary entry letter for letter.
- **Riddles and verse** (stone heads, inscriptions, songs): re-create them as Spanish verse with
  rhyme or assonance, keeping the meaning and the riddle's solution. If a riddle's solution is a
  dictionary keyword and you cannot make the riddle work with the existing Spanish keyword, do
  NOT change the keyword. Write the best version you can and mention it in your final report.
- Do not touch files outside your assignment, and do not edit `Names.tsv`, `Glossary.md`
  or files under `tools/`. If you think a glossary term is wrong, say so in your report.

## Length

Long texts have no hard limit, but signs, short labels and one-liners should stay roughly as
long as the German. Avoid making texts much longer than the German.

## Check before you finish

Run:

    python3 Translations/Spanish/tools/check_translation.py Translations/Spanish/AllTexts

Fix every ERROR in your files. A line-break WARNING in your files is usually a mistake: compare
with the English file and fix it, or explain in your report why it is intentional. Ignore
messages about files outside your assignment. Other agents are working on other folders at
the same time.

Also make sure that no English file in your folders is missing a Spanish counterpart.

## Final report

Keep it short:
1. Folders done and file count.
2. Riddles, puns or keywords that need a second look (path + one line each).
3. Any glossary or name problems you noticed.
Do not commit or push; the coordinator does that.
