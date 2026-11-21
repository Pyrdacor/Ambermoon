#!/usr/bin/env python3
"""List reference files that have no Spanish counterpart yet (per top-level folder)."""
import collections, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..'))
PAIRS = [
    ('Disks/Bugfixing/English/AllTexts', 'Translations/Spanish/AllTexts'),
    ('Disks/Bugfixing/English/IntroTexts', 'Translations/Spanish/IntroTexts'),
    ('Disks/Bugfixing/English/ExtroTexts', 'Translations/Spanish/ExtroTexts'),
]
total = 0
for ref, out in PAIRS:
    missing = collections.Counter()
    for r, _, fs in os.walk(os.path.join(ROOT, ref)):
        for f in fs:
            rel = os.path.relpath(os.path.join(r, f), os.path.join(ROOT, ref))
            if not os.path.exists(os.path.join(ROOT, out, rel)):
                missing[rel.split(os.sep)[0]] += 1
    for k, v in sorted(missing.items()):
        print(f'{out}/{k}: {v} missing')
    total += sum(missing.values())
print(f'{total} files missing')
sys.exit(1 if total else 0)
