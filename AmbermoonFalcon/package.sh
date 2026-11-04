#!/bin/sh
# Builds the Falcon version (build.sh) and packs it for a release.
#
#   ./package.sh <version> [out folder]
#
# The archives <out folder>/ambermoon_falcon_<version>.zip and .lzh (default out folder: build/release) have one
# folder AMBERMOO with AMBERFAL.PRG, DATA\ (the game files) and README.TXT (README.TXT of this folder, CRLF, with the
# version). Needs what build.sh needs (vasm in VASM or PATH, Python 3 with Pillow); the .lzh needs lha (e.g.
# jlha-utils on Linux), without it only the zip is made.
# The .lzh is for the unpackers of the Atari (LHarc, LZH): method -lh5- (-lh0- for files which do not get smaller),
# header level 0 with the path in the name and "\" between the folders, like MS-DOS and TOS (older Atari versions do
# not know the folder headers of level 1 and 2): lha writes level 2, lzh_level0.py rewrites the headers (the packed
# data stay), 7-Zip tests the result if it is there.
set -e
cd "$(dirname "$0")"
VERSION=$1
OUT=${2:-build/release}
[ -n "$VERSION" ] || { echo "usage: ./package.sh <version> [out folder]"; exit 1; }
rm -rf build/hd			# (no files the game wrote while testing)
sh build.sh
PKG=build/package/AMBERMOO
rm -rf build/package
mkdir -p "$PKG" "$OUT"
OUT=$(cd "$OUT" && pwd)
cp build/hd/AMBERFAL.PRG "$PKG/"
cp -r build/hd/DATA "$PKG/"
sed -e "s/@VERSION@/$VERSION/" -e 's/$/\r/' README.TXT > "$PKG/README.TXT"
ZIP="$OUT/ambermoon_falcon_$VERSION.zip"
rm -f "$ZIP"
python3 - "$ZIP" build/package <<'PY'
import os, sys, zipfile
zip_path, root = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
    for folder, dirs, files in os.walk(root):
        dirs.sort()
        for f in sorted(files):
            p = os.path.join(folder, f)
            z.write(p, os.path.relpath(p, root))
PY
echo "Packed $ZIP"
if ! command -v lha >/dev/null; then
	echo "No lha: no .lzh"
	exit 0
fi
LZH="$OUT/ambermoon_falcon_$VERSION.lzh"
TMP="$OUT/level2.lzh"
rm -f "$LZH" "$TMP"
(cd build/package && lha a "$TMP" AMBERMOO >/dev/null)	# (level 2 headers)
python3 lzh_level0.py "$TMP" "$LZH" "$(find build/package -type f | wc -l)"
rm -f "$TMP"
if command -v 7z >/dev/null; then
	7z t "$LZH" >/dev/null			# (the CRCs)
	echo "7-Zip: $LZH is ok"
fi
echo "Packed $LZH"
