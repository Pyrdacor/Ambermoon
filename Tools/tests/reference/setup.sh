#!/usr/bin/env bash
# setup.sh [REF]: prepares the comparison of the ports with the original tools (not needed for Tools/tests/run.sh).
#
# REF (default ~/ref) gets:
#   src/ambermoon       clone of github.com/Pyrdacor/Ambermoon (the tools, translations and game data disks)
#   src/ambermoon.net   clone of github.com/Pyrdacor/Ambermoon.net (the libraries)
#   lib/                copies of Ambermoon.Common, Ambermoon.Data.Common, Ambermoon.Data.Legacy of Ambermoon.net
#   data/english_1.20   the files of English 1.20 (Disks/English/ambermoon_english_1.20_extracted.tar.gz)
#   games/<name>        English 1.07 (ADF, extracted), English 1.20 (ADF), German 1.20 (ADF, extracted), French 1.17
#                       (ADF, damaged) from Disks/<language>/*.zip
#
# The ports were checked with the Ambermoon repository at aa291929 and Ambermoon.net at ce0cfca, with the .NET 8 SDK
# (the tools target net9.0; build.sh switches them to net8.0).
set -eu
REF="${1:-$HOME/ref}"
mkdir -p "$REF/src" "$REF/lib" "$REF/data" "$REF/games"
cd "$REF/src"
[ -d ambermoon ] || git clone --depth 1 https://github.com/Pyrdacor/Ambermoon ambermoon
[ -d ambermoon.net ] || git clone --depth 1 https://github.com/Pyrdacor/Ambermoon.net ambermoon.net
for p in Ambermoon.Common Ambermoon.Data.Common Ambermoon.Data.Legacy; do
    rm -rf "$REF/lib/$p"; cp -r "ambermoon.net/$p" "$REF/lib/"
done
D="$REF/src/ambermoon/Disks"
mkdir -p "$REF/data/english_1.20" && tar xzf "$D/English/ambermoon_english_1.20_extracted.tar.gz" -C "$REF/data/english_1.20"
cd "$REF/games"
for z in English/ambermoon_english_1.07_adf.zip English/ambermoon_english_1.07_extracted.zip \
         English/ambermoon_english_1.20_adf.zip German/ambermoon_german_1.20_adf.zip \
         German/ambermoon_german_1.20_extracted.zip French/ambermoon_french_1.17_adf.zip; do
    n=$(basename "$z" .zip); mkdir -p "$n" && (cd "$n" && unzip -q -o "$D/$z")
done
echo "prepared $REF"
