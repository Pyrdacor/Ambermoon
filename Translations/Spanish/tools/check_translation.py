#!/usr/bin/env python3
"""Validate Spanish Ambermoon text files against the English reference.

Checks for every translated .txt file:
  - the reference file exists (same relative path)
  - placeholders (~LEAD~, ~SELF~, ~INK17~, {0}, ...) are identical in number and kind
  - the number of '^' (line breaks) matches the reference (warning only)
  - only characters from the allowed character set are used
  - length limits for short texts (names, dictionary words, ...)

Usage:
  check_translation.py <translated AllTexts dir> [--ref <reference AllTexts dir>]
                       [--fallback-out <dir>]

--fallback-out writes a copy of all files with accents removed (Ñ is kept),
for builds whose font does not provide accented capitals.
"""
import argparse
import collections
import os
import re
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_REF = os.path.normpath(os.path.join(HERE, '..', '..', '..', 'Disks', 'Bugfixing', 'English', 'AllTexts'))

PLACEHOLDER = re.compile(r'~[A-Z]+ ?\d*~|\{\d+\}')

# Hard/observed length limits (characters). Keys are path prefixes relative to AllTexts.
LIMITS = {
    'Objects.amb': 19,
    'NPC_char.amb': 15,
    'Monster_char.amb': 15,
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

ASCII = set(chr(c) for c in range(0x20, 0x7f))
SPANISH = set('ÁÉÍÓÚÜÑáéíóúüñ¿¡«»')
ALLOWED = ASCII | SPANISH | {'\n'}

FALLBACK_MAP = str.maketrans({
    'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U', 'Ü': 'U',
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u',
    '¿': '', '¡': '', '«': '"', '»': '"',
})


def read(path):
    with open(path, encoding='utf-8-sig') as f:
        return f.read()


def limit_for(rel):
    rel = rel.replace(os.sep, '/')
    best = None
    for prefix, lim in LIMITS.items():
        if rel.startswith(prefix + '/') and (best is None or len(prefix) > len(best[0])):
            best = (prefix, lim)
    return best[1] if best else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('translated')
    ap.add_argument('--ref', default=DEFAULT_REF)
    ap.add_argument('--fallback-out')
    args = ap.parse_args()

    errors = warnings = files = 0
    for root, _, names in os.walk(args.translated):
        for name in sorted(names):
            if not name.endswith('.txt'):
                continue
            path = os.path.join(root, name)
            rel = os.path.relpath(path, args.translated)
            files += 1
            text = read(path).strip('\n')
            ref_path = os.path.join(args.ref, rel)

            def err(msg):
                nonlocal errors
                errors += 1
                print(f'ERROR   {rel}: {msg}')

            def warn(msg):
                nonlocal warnings
                warnings += 1
                print(f'WARNING {rel}: {msg}')

            if not os.path.exists(ref_path):
                err('no reference file')
                ref = None
            else:
                ref = read(ref_path).strip('\n')

            if ref is not None:
                a = collections.Counter(PLACEHOLDER.findall(ref))
                b = collections.Counter(PLACEHOLDER.findall(text))
                if a != b:
                    err(f'placeholders differ: reference {dict(a)} vs translation {dict(b)}')
                if ref.count('^') != text.count('^'):
                    warn(f"line breaks '^': reference {ref.count('^')} vs translation {text.count('^')}")
                for marker in ('_', '$'):
                    if ref.startswith(marker) != text.startswith(marker):
                        err(f"leading marker '{marker}' differs")

            bad = sorted(set(c for c in text if c not in ALLOWED))
            if bad:
                err('characters outside the allowed set: ' + ' '.join(f'{c!r}(U+{ord(c):04X})' for c in bad))

            lim = limit_for(rel)
            if lim is not None and len(text) > lim:
                err(f'{len(text)} characters, limit is {lim}: {text!r}')

            if args.fallback_out:
                out = os.path.join(args.fallback_out, rel)
                os.makedirs(os.path.dirname(out), exist_ok=True)
                with open(out, 'w', encoding='utf-8-sig', newline='') as f:
                    f.write(unicodedata.normalize('NFC', text).translate(FALLBACK_MAP))

    print(f'\n{files} files checked, {errors} errors, {warnings} warnings')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
