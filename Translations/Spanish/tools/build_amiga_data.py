#!/usr/bin/env python3
"""Fills Disks/Bugfixing/Spanish, the input of AmbermoonReleaseCreator for the Amiga release.

- AllTexts: the texts of Translations/Spanish/AllTexts without accents and without ¿ ¡. The in-game font
  has no glyphs for them; the release creator removes the accents itself (-u, also Ñ -> N), but not ¿ ¡.
- IntroTexts, ExtroTexts: unchanged (the intro and extro use the font of Translations/Spanish, which has
  all Spanish characters).
- Amberfiles/Button_graphics: the English button graphics (there are no Spanish ones yet).
Run it after every change of the texts."""
import os, shutil, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.normpath(os.path.join(HERE, '..'))
ROOT = os.path.normpath(os.path.join(SRC, '..', '..'))
DST = os.path.join(ROOT, 'Disks', 'Bugfixing', 'Spanish')

for d in ('AllTexts', 'IntroTexts', 'ExtroTexts'):
    shutil.rmtree(os.path.join(DST, d), ignore_errors=True)
r = subprocess.run([sys.executable, os.path.join(HERE, 'check_translation.py'), os.path.join(SRC, 'AllTexts'),
                    '--fallback-out', os.path.join(DST, 'AllTexts')], capture_output=True, text=True)
print(r.stdout.strip().splitlines()[-1])
if r.returncode:
    print(r.stdout); sys.exit(1)
for root, _, files in os.walk(os.path.join(SRC, 'AllTexts')):
    for f in files:
        if not f.endswith('.txt'):
            rel = os.path.relpath(os.path.join(root, f), os.path.join(SRC, 'AllTexts'))
            os.makedirs(os.path.dirname(os.path.join(DST, 'AllTexts', rel)), exist_ok=True)
            shutil.copy2(os.path.join(root, f), os.path.join(DST, 'AllTexts', rel))
for d in ('IntroTexts', 'ExtroTexts'):
    shutil.copytree(os.path.join(SRC, d), os.path.join(DST, d))
os.makedirs(os.path.join(DST, 'Amberfiles'), exist_ok=True)
shutil.copy2(os.path.join(ROOT, 'Disks', 'Bugfixing', 'English', 'Amberfiles', 'Button_graphics'),
             os.path.join(DST, 'Amberfiles', 'Button_graphics'))
print('Disks/Bugfixing/Spanish updated')
