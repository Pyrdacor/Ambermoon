#!/usr/bin/env python3
"""Translations of Ambermoon as gettext PO files (Translations/PO).

The PO files are the source of the translations. The text folders that the release creator reads
(Disks/Bugfixing/<Language>/AllTexts, IntroTexts, ExtroTexts and RemakeTranslatableTexts.txt) are made from them
with `import`. Each entry is one text of the game:

    #. Dialogue of NPC 001 (GRANDFATHER).
    #. German: "HALLO ~SELF~, KOMM BITTE NÄHER ..."
    #: AllTexts/NPC_texts.amb/001/001.txt
    msgctxt "AllTexts/NPC_texts.amb/001/001"
    msgid "\"HELLO ~SELF~, PLEASE COME CLOSER ..."
    msgstr "\"HOLA, ~SELF~. ACÉRCATE ..."

msgid is the English text, msgctxt the file of the text. The markup of the game stays as it is in the texts
(^ line break, $ hard space, ~LEAD~ etc. placeholders). An empty msgstr means "not translated": no file is written
for it and the game keeps the text of the German base data.

Commands (python3 Translations/po.py <command> ...):

  extract                 writes the template Translations/PO/ambermoon.pot from the English texts
  export <lang>... [--from <folder>]
                          writes <lang>.po from the text folders (to start a PO file from existing texts)
  import <lang>...|--all  writes the text folders from <lang>.po (existing files keep their BOM and line end)
  update <lang>...|--all  brings <lang>.po up to date with the template (changed English texts become fuzzy)
  check <lang>...|--all   checks placeholders, line breaks, lengths and the glyphs of the intro/extro font
  verify                  checks that the template and all text folders are up to date with the PO files

Languages: de (German), fr (French), cs (Czech), pl (Polish), es (Spanish).
"""
import collections
import json
import os
import re
import shutil
import sys
import tempfile

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
PO_DIR = os.path.join(ROOT, 'Translations', 'PO')
POT = os.path.join(PO_DIR, 'ambermoon.pot')
BUGFIXING = os.path.join(ROOT, 'Disks', 'Bugfixing')
REMAKE_TEMPLATE = os.path.join(ROOT, 'Translations', 'RemakeTranslatableTexts.txt')

LANGUAGES = {
    'de': 'German',
    'fr': 'French',
    'cs': 'Czech',
    'pl': 'Polish',
    'es': 'Spanish',
}

# characters that are removed when the game texts (AllTexts) of a language are written: the in-game font has no
# glyphs for them (the release creator removes the accents itself with -u, but not these)
REMOVE_IN_GAME_TEXTS = {
    'es': '¿¡',
}

FOLDERS = ('AllTexts', 'IntroTexts', 'ExtroTexts')
REMAKE = 'RemakeTranslatableTexts.txt'

# lengths of the short texts (characters); keys are path prefixes below AllTexts
LIMITS = {
    'Objects.amb': 19,
    'NPC_char.amb': 15,
    'Monster_char.amb': 15,
    'Save.00/Party_char.amb': 15,
    'Dict.amb': 21,
    'Place_data': 30,
    'Text.amb/ClassNames': 7,
    'Text.amb/RaceNames': 10,
    'Text.amb/AttributeShortNames': 3,
    'Text.amb/SkillShortNames': 3,
    'Text.amb/SkillNames': 18,
    'Text.amb/AttributeNames': 16,
    'Text.amb/ConditionNames': 14,
    'Text.amb/ItemTypeNames': 18,
    'Text.amb/SpellNames': 21,
    'Text.amb/WorldNames': 20,
}

PLACEHOLDER = re.compile(r'~[A-Z]+ ?\d*~|\{\d+\}')
PLACEHOLDER_HINTS = {
    '~LEAD~': 'the active party member',
    '~SELF~': 'the hero (the player character)',
    '~CAST~': 'the caster of a spell',
    '~INVN~': 'the party member whose inventory is open',
    '~SUBJ~': 'the party member the text is about',
    '~SEX1~': 'he/she of ~SUBJ~',
    '~SEX2~': 'his/her of ~SUBJ~',
}
ONLY_HERE = 'Only in this translation, not in the English texts.'


# ----------------------------------------------------------------------------------------------------------------
# PO files

class Entry:
    def __init__(self, ctxt='', msgid='', msgstr=''):
        self.ctxt, self.msgid, self.msgstr = ctxt, msgid, msgstr
        self.translator = []    # "# " comments
        self.extracted = []     # "#." comments
        self.references = []    # "#:" lines
        self.flags = []         # "#," flags
        self.previous = None    # "#| msgid" of a fuzzy entry
        self.obsolete = False

    @property
    def fuzzy(self):
        return 'fuzzy' in self.flags

    def set_fuzzy(self, on):
        if on and not self.fuzzy:
            self.flags.append('fuzzy')
        if not on and self.fuzzy:
            self.flags.remove('fuzzy')

    @property
    def only_here(self):
        return ONLY_HERE in self.extracted


def _unquote(s):
    s = s.strip()
    assert s.startswith('"') and s.endswith('"'), s
    out, i, s = [], 0, s[1:-1]
    while i < len(s):
        c = s[i]
        if c == '\\':
            n = s[i + 1]
            out.append({'n': '\n', 't': '\t', '"': '"', '\\': '\\', 'r': '\r'}.get(n, n))
            i += 2
        else:
            out.append(c)
            i += 1
    return ''.join(out)


def _quote(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"').replace('\t', '\\t').replace('\r', '\\r').replace('\n', '\\n') + '"'


def read_po(path):
    header, entries = None, []
    cur, field = Entry(), None

    def finish():
        nonlocal cur, header
        if cur.msgid == '' and cur.ctxt == '' and header is None and not cur.obsolete:
            header = cur
        elif cur.msgid or cur.ctxt:
            entries.append(cur)
        cur = Entry()

    with open(path, encoding='utf-8') as f:
        lines = f.read().split('\n')
    for raw in lines + ['']:
        line = raw.rstrip('\r')
        obsolete = line.startswith('#~')
        if obsolete:
            line = line[2:].lstrip()
            cur.obsolete = True
        if not line.strip():
            if field is not None:
                finish()
                field = None
            continue
        if line.startswith('#'):
            if field is not None and field != 'comment':
                finish()
            field = 'comment'
            kind, text = line[:2], line[2:].strip() if len(line) > 2 else ''
            if kind == '#.':
                cur.extracted.append(text)
            elif kind == '#:':
                cur.references.append(text)
            elif kind == '#,':
                cur.flags += [f.strip() for f in text.split(',') if f.strip()]
            elif kind == '#|':
                if text.startswith('msgid '):
                    cur.previous = _unquote(text[6:])
                elif text.startswith('"') and cur.previous is not None:
                    cur.previous += _unquote(text)
            else:
                cur.translator.append(line[1:].strip())
            continue
        m = re.match(r'(msgctxt|msgid|msgstr)\s+(".*")$', line)
        if m:
            key, value = m.group(1), _unquote(m.group(2))
            if key == 'msgctxt' and field in ('msgid', 'msgstr'):
                finish()
            if key == 'msgid' and field == 'msgstr':
                finish()
            field = key
            setattr(cur, {'msgctxt': 'ctxt'}.get(key, key), value)
        elif line.startswith('"'):
            attr = {'msgctxt': 'ctxt'}.get(field, field)
            setattr(cur, attr, getattr(cur, attr) + _unquote(line))
        else:
            raise ValueError(f'{path}: cannot read line {raw!r}')
    if field is not None:
        finish()
    return header, entries


def _field(name, value, prefix=''):
    if '\n' in value[:-1]:
        parts = value.split('\n')
        chunks = [p + '\n' for p in parts[:-1]] + ([parts[-1]] if parts[-1] else [])
        return [f'{prefix}{name} ""'] + [prefix + _quote(c) for c in chunks]
    return [f'{prefix}{name} {_quote(value)}']


def write_po(path, header_lines, entries):
    out = ['msgid ""', 'msgstr ""'] + [_quote(h + '\n') for h in header_lines] + ['']
    for e in entries:
        p = '#~ ' if e.obsolete else ''
        out += ['# ' + t if t else '#' for t in e.translator]
        out += ['#. ' + t for t in e.extracted]
        out += ['#: ' + r for r in e.references]
        if e.flags:
            out.append('#, ' + ', '.join(e.flags))
        if e.previous is not None:
            out += ['#| ' + x for x in _field('msgid', e.previous)]
        out += _field('msgctxt', e.ctxt, p) + _field('msgid', e.msgid, p) + _field('msgstr', e.msgstr, p) + ['']
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out))


def header(language=None):
    lines = ['Project-Id-Version: Ambermoon']
    if language:
        lines.append(f'Language: {language}')
    return lines + ['MIME-Version: 1.0', 'Content-Type: text/plain; charset=UTF-8', 'Content-Transfer-Encoding: 8bit',
                    'X-Source-Language: English']


# ----------------------------------------------------------------------------------------------------------------
# Texts of the game

def _key(path):
    # natural order: AllTexts/2Map_texts.amb/259/010.txt
    return [int(p) if p.isdigit() else p for p in re.split(r'(\d+)', path)]


def read_text(path):
    with open(path, encoding='utf-8-sig') as f:
        return f.read().rstrip('\r\n')


def text_files(base):
    """{'AllTexts/Dict.amb/000': path, ...} of the numbered .txt files of a language folder."""
    result = {}
    for folder in FOLDERS:
        top = os.path.join(base, folder)
        for root, _, files in os.walk(top):
            for name in files:
                if name.endswith('.txt') and name[:-4].isdigit():
                    full = os.path.join(root, name)
                    rel = os.path.relpath(full, base).replace(os.sep, '/')
                    result[rel[:-4]] = full
    return result


# Remake texts: a C# like list of strings in sections ("## ..."). The strings are found per line (the text between
# the first and the last quote of a line, outside of // comments) and keyed by the section and the line in it.

def remake_lines(path):
    """[(key, line index, start, end, text)]"""
    with open(path, encoding='utf-8-sig') as f:
        lines = f.read().split('\n')
    result, section, n = [], 'Start', 0
    for i, line in enumerate(lines):
        if line.startswith('## '):
            section, n = line[3:].split(';')[0].strip(), 0
            continue
        if re.match(r'^\s*//', line) or '"' not in line:
            continue
        start = line.index('"') + 1
        end = line.rindex('"')
        if end < start:
            end = len(line.rstrip('\r'))   # string without closing quote
        result.append((f'Remake/{section}/{n:03d}', i, start, end, line[start:end]))
        n += 1
    return result


def describe(rel, names):
    parts = rel.split('/')
    folder = parts[0]
    if folder == 'IntroTexts':
        return ['Intro text. Lines must not be much longer than the English ones.']
    if folder == 'ExtroTexts':
        return ['Extro text. Lines must not be much longer than the English ones. A leading _ is the large font, $ and $$ mark the translator lines.']
    if folder == 'Remake':
        return [f'Remake text ({parts[1]}). Translate only the text; keep {{0}} placeholders and ^ line breaks.']
    kind, rest = parts[1], parts[2:]
    if kind in ('1Map_texts.amb', '2Map_texts.amb', '3Map_texts.amb'):
        d = f'Text {rest[1]} of map {rest[0]}.' + (' The name of the map.' if rest[1] == '000' and kind != '1Map_texts.amb' else '')
    elif kind == 'NPC_texts.amb':
        d = f'Dialogue of NPC {rest[0]}' + (f' ({names["npc"][rest[0]]})' if rest[0] in names['npc'] else '') + '.'
    elif kind == 'Party_texts.amb':
        d = f'Dialogue of party member {rest[0]}' + (f' ({names["party"][rest[0]]})' if rest[0] in names['party'] else '') + '.'
    elif kind == 'Object_texts.amb':
        d = 'Text of a readable item (book, letter, scroll).'
    elif kind == 'Objects.amb':
        d = 'Item name.'
    elif kind == 'Dict.amb':
        d = 'Dictionary word: a conversation keyword or an answer that the player types. The texts that mention it must use exactly this word.'
    elif kind == 'Monster_char.amb':
        d = 'Monster name.'
    elif kind == 'NPC_char.amb':
        d = 'NPC name.'
    elif kind == 'Place_data':
        d = 'Name of a place (shop, inn, trainer, ...).'
    elif kind in ('2Map_data.amb', '3Map_data.amb'):
        d = f'Automap label of map {rest[0]}.'
    elif kind == 'Save.00':
        d = 'Name of a party member.'
    elif kind == 'Text.amb':
        d = f'User interface: {rest[0]}.'
        if rest[0] == 'UITexts':
            d += ' Keep the length and the spaces of the layout.'
    else:
        d = kind + '.'
    return [d]


def limit_for(rel):
    sub = rel.split('/', 1)[1] if rel.startswith('AllTexts/') else None
    if sub is None:
        return None
    best = None
    for prefix, lim in LIMITS.items():
        if sub.startswith(prefix + '/') and (best is None or len(prefix) > len(best[0])):
            best = (prefix, lim)
    return best[1] if best else None


def _names():
    en = os.path.join(BUGFIXING, 'English', 'AllTexts')
    names = {'npc': {}, 'party': {}}
    for key, folder in (('npc', 'NPC_char.amb'), ('party', os.path.join('Save.00', 'Party_char.amb'))):
        d = os.path.join(en, folder)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith('.txt'):
                    names[key][f[:-4]] = read_text(os.path.join(d, f))
    return names


def language_texts(code, base=None):
    """{key: text} of a language from its text folders (and its remake file)."""
    if base is None:
        base = os.path.join(BUGFIXING, LANGUAGES[code]) if code != 'en' else os.path.join(BUGFIXING, 'English')
    texts = {k: read_text(p) for k, p in text_files(base).items()}
    remake = os.path.join(base, REMAKE) if code != 'en' else REMAKE_TEMPLATE
    if os.path.exists(remake):
        for key, _, _, _, text in remake_lines(remake):
            texts[key] = text
    return texts


def extract():
    en = language_texts('en')
    de = language_texts('de')
    names = _names()
    entries = []
    for key in sorted(en, key=lambda k: (k.startswith('Remake/'), _key(k))):
        msgid = en[key]
        if not msgid:
            continue
        e = Entry(key, msgid, '')
        e.extracted = describe(key, names)
        lim = limit_for(key)
        if lim:
            e.extracted.append(f'Length: the existing texts of this kind have at most {lim} characters.')
        hints = [f'{p} = {PLACEHOLDER_HINTS[p]}' for p in dict.fromkeys(PLACEHOLDER.findall(msgid)) if p in PLACEHOLDER_HINTS]
        if hints:
            e.extracted.append('Placeholders: ' + '; '.join(hints) + '. The gender of these persons is unknown.')
        if key in de and de[key] and de[key] != msgid:
            e.extracted.append('German: ' + _quote(de[key]))
        e.references = [key + ('' if key.startswith('Remake/') else '.txt')]
        entries.append(e)
    write_po(POT, header(), entries)
    print(f'{os.path.relpath(POT, ROOT)}: {len(entries)} texts')
    return entries


def merge(template, old_entries, translations=None):
    """The entries of the template with the translations of old_entries (or translations: {key: text})."""
    old = {e.ctxt: e for e in old_entries if not e.obsolete}
    result = []
    for t in template:
        e = Entry(t.ctxt, t.msgid, '')
        e.extracted, e.references = list(t.extracted), list(t.references)
        if translations is not None:
            e.msgstr = translations.get(t.ctxt, '')
        elif t.ctxt in old:
            o = old[t.ctxt]
            e.msgstr, e.translator, e.flags, e.previous = o.msgstr, list(o.translator), list(o.flags), o.previous
            if o.msgid != t.msgid and o.msgstr:
                e.set_fuzzy(True)
                e.previous = o.msgid
            if not e.fuzzy:
                e.previous = None
        result.append(e)
    keys = {t.ctxt for t in template}
    extra = []
    if translations is not None:
        for k in sorted(translations, key=_key):
            if k not in keys and translations[k]:
                e = Entry(k, translations[k], translations[k])
                e.extracted = [ONLY_HERE]
                e.references = [k + ('' if k.startswith('Remake/') else '.txt')]
                extra.append(e)
    else:
        for o in old_entries:
            if o.ctxt not in keys:
                if o.only_here:
                    extra.append(o)
                elif not o.obsolete and o.msgstr:
                    o.obsolete = True
                    extra.append(o)
                elif o.obsolete:
                    extra.append(o)
    return result + extra


def template_entries():
    if not os.path.exists(POT):
        return extract()
    return read_po(POT)[1]


def po_path(code):
    return os.path.join(PO_DIR, f'{code}.po')


def export(code, base=None):
    entries = merge(template_entries(), [], language_texts(code, base))
    write_po(po_path(code), header(code), entries)
    report(code, entries)


def update(code):
    _, old = read_po(po_path(code))
    entries = merge(template_entries(), old)
    write_po(po_path(code), header(code), entries)
    report(code, entries)


def report(code, entries):
    live = [e for e in entries if not e.obsolete and not e.only_here]
    done = sum(1 for e in live if e.msgstr and not e.fuzzy)
    fuzzy = sum(1 for e in live if e.msgstr and e.fuzzy)
    print(f'{code}.po: {done}/{len(live)} translated, {fuzzy} fuzzy, {len(live) - done - fuzzy} untranslated'
          + (f', {sum(1 for e in entries if e.only_here)} only in this translation' if any(e.only_here for e in entries) else ''))


# ----------------------------------------------------------------------------------------------------------------
# Writing the text folders

def _write_text(path, text, default_bom):
    bom, newline = default_bom, ''
    if os.path.exists(path):
        raw = open(path, 'rb').read()
        bom = raw.startswith(b'\xef\xbb\xbf')
        body = raw[3:] if bom else raw
        m = re.search(rb'(\r?\n)+$', body)
        newline = m.group(0).decode() if m else ''
        current = body.decode('utf-8', errors='replace').rstrip('\r\n')
        if current == text:
            return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write((b'\xef\xbb\xbf' if bom else b'') + (text + newline).encode('utf-8'))
    return True


def import_po(code, base=None):
    """Writes the text folders of a language from its PO file. Returns the number of changed files."""
    base = base or os.path.join(BUGFIXING, LANGUAGES[code])
    _, entries = read_po(po_path(code))
    remove = REMOVE_IN_GAME_TEXTS.get(code, '')
    changed = 0
    remake = {}
    for e in entries:
        if e.obsolete or not e.msgstr:
            continue
        if e.ctxt.startswith('Remake/'):
            remake[e.ctxt] = e.msgstr
            continue
        text = e.msgstr
        if e.ctxt.startswith('AllTexts/') and remove:
            text = text.translate({ord(c): None for c in remove})
        path = os.path.join(base, *e.ctxt.split('/')) + '.txt'
        changed += _write_text(path, text, default_bom=not e.ctxt.startswith('IntroTexts/'))
    # the empty texts of the English data exist in every language that has the folder
    en = os.path.join(BUGFIXING, 'English')
    for key, path in text_files(en).items():
        folder = key.split('/')[0]
        target = os.path.join(base, *key.split('/')) + '.txt'
        if not os.path.exists(target) and os.path.isdir(os.path.join(base, folder)) and read_text(path) == '':
            changed += _write_text(target, '', default_bom=folder != 'IntroTexts')
    if remake:
        target = os.path.join(base, REMAKE)
        source = target if os.path.exists(target) else REMAKE_TEMPLATE
        with open(source, encoding='utf-8-sig') as f:
            content = f.read()
        lines = content.split('\n')
        for key, i, start, end, text in remake_lines(source):
            if key in remake and remake[key] != text:
                lines[i] = lines[i][:start] + remake[key] + lines[i][end:]
        new = '\n'.join(lines)
        if new != content or not os.path.exists(target):
            raw_bom = open(source, 'rb').read().startswith(b'\xef\xbb\xbf')
            with open(target, 'wb') as f:
                f.write((b'\xef\xbb\xbf' if raw_bom else b'') + new.encode('utf-8'))
            changed += 1
    return changed


# ----------------------------------------------------------------------------------------------------------------
# Checks

def font_glyphs(code):
    folder = os.path.join(ROOT, 'Translations', LANGUAGES[code])
    font, enc = os.path.join(folder, 'font.json'), os.path.join(folder, 'encoding.txt')
    if not os.path.exists(font):
        return None
    encoding = open(enc, encoding='utf-8').read().strip() if os.path.exists(enc) else 'latin-1'
    encoding = {'852': 'cp852', '850': 'cp850', '1250': 'cp1250', '1252': 'cp1252'}.get(encoding, encoding)
    mapping = json.load(open(font, encoding='utf-8'))['glyphMapping']
    chars = set(' ')
    for i, g in enumerate(mapping):
        if g != 255:
            chars.add(bytes([i + 32]).decode(encoding, errors='ignore'))
    return chars


def check(code):
    _, entries = read_po(po_path(code))
    glyphs = font_glyphs(code)
    errors, warnings = [], []
    for e in entries:
        if e.obsolete or not e.msgstr or e.only_here:
            continue
        where = e.ctxt
        a, b = collections.Counter(PLACEHOLDER.findall(e.msgid)), collections.Counter(PLACEHOLDER.findall(e.msgstr))
        if a != b:
            warnings.append(f'{where}: placeholders differ from the English text: {dict(a)} / {dict(b)}')
        if e.msgid.count('^') != e.msgstr.count('^'):
            warnings.append(f'{where}: line breaks (^): English {e.msgid.count("^")}, translation {e.msgstr.count("^")}')
        lim = limit_for(where)
        if lim and len(e.msgstr) > lim:
            warnings.append(f'{where}: {len(e.msgstr)} characters, the existing texts have at most {lim}: {e.msgstr!r}')
        if where.startswith('ExtroTexts/'):
            for marker in ('_', '$'):
                if e.msgid.startswith(marker) != e.msgstr.startswith(marker):
                    errors.append(f"{where}: the leading '{marker}' of the English text is missing or added")
        if glyphs is not None and where.split('/')[0] in ('IntroTexts', 'ExtroTexts'):
            missing = sorted(set(c for c in e.msgstr if c not in glyphs and c not in '$_<>'))
            if missing:
                errors.append(f'{where}: no glyph in the font for {" ".join(missing)}')
        if e.fuzzy:
            warnings.append(f'{where}: fuzzy (the English text changed, check the translation)')
    for w in warnings:
        print(f'WARNING {code}: {w}')
    for x in errors:
        print(f'ERROR   {code}: {x}')
    report(code, entries)
    print(f'{code}.po: {len(errors)} errors, {len(warnings)} warnings')
    return not errors


def verify():
    ok = True
    current = open(POT, encoding='utf-8').read() if os.path.exists(POT) else ''
    with tempfile.TemporaryDirectory() as tmp:
        global POT_BACKUP
        saved = POT
        try:
            globals()['POT'] = os.path.join(tmp, 'ambermoon.pot')
            extract()
            fresh = open(globals()['POT'], encoding='utf-8').read()
        finally:
            globals()['POT'] = saved
        if fresh != current:
            print('ERROR: Translations/PO/ambermoon.pot is not up to date with the English texts (run extract and update)')
            ok = False
        for code, language in LANGUAGES.items():
            if not os.path.exists(po_path(code)):
                continue
            src = os.path.join(BUGFIXING, language)
            dst = os.path.join(tmp, language)
            if os.path.isdir(src):
                shutil.copytree(src, dst)
            n = import_po(code, dst)
            if n:
                print(f'ERROR: Disks/Bugfixing/{language} is not up to date with {code}.po ({n} files; run import {code})')
                ok = False
            else:
                print(f'{code}: up to date')
    return ok


def main(argv):
    if not argv or argv[0] in ('-h', '--help'):
        print(__doc__)
        return 0
    cmd, args = argv[0], argv[1:]
    if '--from' in args:
        i = args.index('--from')
        args = args[:i] + args[i + 2:]
    codes = list(LANGUAGES) if '--all' in args else [a for a in args if not a.startswith('-')]
    for c in codes:
        if c not in LANGUAGES:
            print(f'unknown language {c!r} (known: {", ".join(LANGUAGES)})')
            return 1
    if cmd == 'extract':
        extract()
    elif cmd == 'export':
        base = argv[argv.index('--from') + 1] if '--from' in argv else None
        for c in codes:
            export(c, base)
    elif cmd == 'import':
        for c in codes:
            n = import_po(c)
            print(f'{c}: {n} files written to Disks/Bugfixing/{LANGUAGES[c]}')
    elif cmd == 'update':
        for c in codes:
            update(c)
    elif cmd == 'check':
        return 0 if all([check(c) for c in codes]) else 1
    elif cmd == 'verify':
        return 0 if verify() else 1
    else:
        print(f'unknown command {cmd!r}')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
