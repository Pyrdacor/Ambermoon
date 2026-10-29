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
# not know the folder headers of level 1 and 2). The separators are set and everything is checked after packing.
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
rm -f "$LZH"
(cd build/package && lha aq0 "$LZH" AMBERMOO)
python3 - "$LZH" "$(find build/package -type f | wc -l)" <<'PY'
import struct, sys
lzh, expected = sys.argv[1], int(sys.argv[2])
d = bytearray(open(lzh, 'rb').read())
pos, files = 0, 0
while pos < len(d) and d[pos] != 0:
    size, method, level = d[pos], bytes(d[pos + 2:pos + 7]), d[pos + 20]
    packed = struct.unpack_from('<I', d, pos + 7)[0]
    if level != 0 or method not in (b'-lh5-', b'-lh0-', b'-lhd-'):
        sys.exit('%s: header level %d, method %s (expected level 0, -lh5- or -lh0-)' % (lzh, level, method))
    n = d[pos + 21]
    name = bytes(d[pos + 22:pos + 22 + n]).replace(b'/', b'\\')    # (TOS paths)
    d[pos + 22:pos + 22 + n] = name
    d[pos + 1] = sum(d[pos + 2:pos + 2 + size]) & 0xff               # (header checksum)
    if method != b'-lhd-':
        if not name.startswith(b'AMBERMOO\\'):
            sys.exit('%s: %r is not in AMBERMOO' % (lzh, name))
        files += 1
    pos += 2 + size + packed
if files != expected:
    sys.exit('%s: %d files, expected %d' % (lzh, files, expected))
open(lzh, 'wb').write(d)
print('%s: %d files, -lh5- / -lh0-, header level 0, paths with \\' % (lzh, files))
PY
lha tq "$LZH"			# (the CRCs and the header checksums)
echo "Packed $LZH"
