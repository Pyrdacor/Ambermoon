#!/bin/sh
# Builds the Falcon version (build.sh) and packs it for a release.
#
#   ./package.sh <version> [out folder]
#
# The archive <out folder>/ambermoon_falcon_<version>.zip (default out folder: build/release) has one folder
# AMBERMOO with AMBERFAL.PRG, DATA\ (the game files) and README.TXT (README.TXT of this folder, CRLF, with the
# version). Needs what build.sh needs (vasm in VASM or PATH, Python 3 with Pillow).
set -e
cd "$(dirname "$0")"
VERSION=$1
OUT=${2:-build/release}
[ -n "$VERSION" ] || { echo "usage: ./package.sh <version> [out folder]"; exit 1; }
sh build.sh
PKG=build/package/AMBERMOO
rm -rf build/package
mkdir -p "$PKG" "$OUT"
cp build/hd/AMBERFAL.PRG "$PKG/"
cp -r build/hd/DATA "$PKG/"
sed -e "s/@VERSION@/$VERSION/" -e 's/$/\r/' README.TXT > "$PKG/README.TXT"
ZIP="$OUT/ambermoon_falcon_$VERSION.zip"
rm -f "$ZIP"
python3 - "$ZIP" build/package <<'EOF'
import os, sys, zipfile
zip_path, root = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
    for folder, dirs, files in os.walk(root):
        dirs.sort()
        for f in sorted(files):
            p = os.path.join(folder, f)
            z.write(p, os.path.relpath(p, root))
EOF
echo "Packed $ZIP"
