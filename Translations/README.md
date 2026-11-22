## Translation

The translations of Ambermoon are [gettext PO files](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html)
in [PO](PO), one per language:

| File | Language |
|---|---|
| [PO/ambermoon.pot](PO/ambermoon.pot) | Template with all texts (English), for new languages |
| [PO/de.po](PO/de.po) | German (the original) |
| [PO/fr.po](PO/fr.po) | French |
| [PO/cs.po](PO/cs.po) | Czech |
| [PO/pl.po](PO/pl.po) | Polish |
| [PO/es.po](PO/es.po) | Spanish |

They can be edited with any PO editor ([Poedit](https://poedit.net), Lokalize, ...), with a translation platform
(Weblate, Crowdin, ...) or with a text editor. The PO files are the source of the translations. The text folders
that the release creator reads (`Disks/Bugfixing/<Language>/AllTexts`, `IntroTexts`, `ExtroTexts` and
`RemakeTranslatableTexts.txt`) are written from them by [po.py](po.py).

### The entries

Each entry is one text of the game:

```
#. Dialogue of NPC 001 (GRANDFATHER).
#. Placeholders: ~SELF~ = the hero (the player character). The gender of these persons is unknown.
#. German: "\"HALLO ~SELF~, KOMM BITTE NÄHER ANS BETT, MEIN GELIEBTES ENKELKIND! ...\""
#: AllTexts/NPC_texts.amb/001/001.txt
msgctxt "AllTexts/NPC_texts.amb/001/001"
msgid "\"HELLO ~SELF~, PLEASE COME CLOSER TO THE BED, MY BELOVED GRANDCHILD! ...\""
msgstr "\"HOLA, ~SELF~. ACÉRCATE A LA CAMA, SANGRE DE MI SANGRE. ...\""
```

- `msgctxt` is the file of the text (`AllTexts/...`, `IntroTexts/...`, `ExtroTexts/...`) or the section and line of
  the remake texts (`Remake/...`).
- `msgid` is the English text, `msgstr` the translation. The comments say what the text is, the usual length of
  this kind of text, what the placeholders mean, and give the German original.
- An empty `msgstr` means "not translated": no file is written for it, and the game keeps the text of the German
  base data. Entries marked `fuzzy` were translated before the English text changed: check them and remove the flag.
  They are still written, because the old translation is usually better than none.
- Entries with the comment *Only in this translation* exist only in this language. Their text has no English
  counterpart, for example extra extro lines.

### Rules for the texts

Always keep things like \~HERO~, \~SELF~, \~INK17~ and so on as they are. Those are placeholders. The same is true for
the character '^', which is a line break, and '$', which is a non-breaking space. Things like {0} are also
placeholders. Don't add real line breaks.

The extro texts may start with '\_' or '$'. Keep those markers. '\_' means that the text uses the large font, and '$'
and '$$' mark the translator lines.

The remake texts are the strings of RemakeTranslatableTexts.txt, one entry per line of that file. Long tutorial
texts are split across several entries, one per line.

### Workflow (python3 Translations/po.py ...)

1. **New language:** copy `PO/ambermoon.pot` to `PO/<code>.po`, add the language to `LANGUAGES` in `po.py` and
   translate.
2. **Check a translation:** `check <code>` reports:
   - changed placeholders and line breaks;
   - texts that are longer than all existing texts of their kind;
   - characters without a glyph in the intro/extro font of `Translations/<Language>`;
   - fuzzy entries.
3. **Write the text folders for the release:** `import <code>` (or `import --all`). Existing files keep their BOM and
   line end, so unchanged texts give no diff.
4. **English texts changed:** run `extract` (writes the template), then `update --all`. Changed texts become fuzzy;
   texts that no longer exist become obsolete (`#~`).
5. **Before a commit:** `verify` checks that the template and all text folders are up to date with the PO files.
   The workflow [translations](../.github/workflows/translations.yml) runs it for every pull request, and the release
   workflow imports all PO files before it builds the releases.

`export <code>` was used once to create the PO files from the existing text folders. Importing them again gives the
existing files byte for byte.

### Intro and extro font

Languages with their own intro/extro font have a folder `Translations/<Language>` with `encoding.txt`, `font.json`,
`SmallGlyphs.png`, `LargeGlyphs.png`, `click-text.txt` and `translators.txt` (see
[the release creator](../AmbermoonTools/AmbermoonReleaseCreator/README.md)).

### Old files

[AllTexts.zip](AllTexts.zip), [EnglishExtroTextGroups.zip](EnglishExtroTextGroups.zip),
[IntroTexts.zip](IntroTexts.zip) and [RemakeTranslatableTexts.txt](RemakeTranslatableTexts.txt) are the text packages
of the old workflow, before PO files. RemakeTranslatableTexts.txt is still the English template of the remake texts.
