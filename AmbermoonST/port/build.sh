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
# ST: no sound DMA of the Amiga (HULL/VARIOUS.S switches the channels off)
sed -i -e 's/^\(\s*\)move\.w\t#\$000f,Custom+dmacon/\1nop\t\t\t; ST: (Amiga sound DMA off)/' $OUT/src/HULL/VARIOUS.S
[ -d port/PATCHED ] && cp -r port/PATCHED/. $OUT/src/
cp -r port/KERNEL $OUT/src/ST_KERNEL
cp port/AMBERST.S $OUT/src/
python3 port/tools/port_data.py $OUT/hd $OUT/src/ST_KERNEL/FILEMAP.I
# the ST palettes take a while : made again only when the script changed
if [ ! -f $OUT/STPALS.I ] || [ port/tools/port_palettes.py -nt $OUT/STPALS.I ]; then
	python3 port/tools/port_palettes.py $OUT/STPALS.I
fi
cp $OUT/STPALS.I $OUT/src/ST_KERNEL/
cd $OUT/src
$VASM -quiet -nowarn=53 -nowarn=62 -nowarn=86 -nowarn=40 -maxerrors=5000 -m68000 -Ftos -align -o ../AMBERST.PRG AMBERST.S
cp ../AMBERST.PRG ../hd/
echo "Built build/port/hd/AMBERST.PRG"
