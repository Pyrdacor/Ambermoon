#!/bin/sh
# Builds the port of the original source (see PORT.md) into build/port/AMBERST.PRG.
#
# The original sources (AmbermoonSource/src) are copied to build/port/src, with two mechanical changes :
# the memory attributes of the sections are removed (bss_c / data_c / code_c -> bss / data / code, TOS has no
# CHIP memory), and the files in port/PATCHED replace the originals (changes marked "; ST:").
#
# Needs vasmm68k_mot (set VASM to its path if it is not in PATH).
set -e
cd "$(dirname "$0")/.."
VASM=${VASM:-vasmm68k_mot}
OUT=build/port
rm -rf $OUT/src
mkdir -p $OUT/src
cp -r ../AmbermoonSource/src/. $OUT/src/
find $OUT/src -name '*.S' -o -name '*.I' -o -name '*.s' | while read -r f; do
	sed -i -e 's/\(SECTION[[:space:]]\+[A-Za-z0-9_]\+,[[:space:]]*\)\(bss\|data\|code\)_c/\1\2/I' "$f"
done
cp -r port/PATCHED/. $OUT/src/
cp -r port/KERNEL $OUT/src/ST_KERNEL
cp port/AMBERST.S $OUT/src/
cd $OUT/src
$VASM -quiet -nowarn=53 -nowarn=62 -nowarn=86 -nowarn=40 -maxerrors=5000 -m68000 -Ftos -align -o ../AMBERST.PRG AMBERST.S
echo "Built build/port/AMBERST.PRG"
