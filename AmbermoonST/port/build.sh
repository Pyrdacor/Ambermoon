#!/bin/sh
# Builds the port of the original source (see PORT.md) into build/port/AMBERST.PRG.
#
# The original sources (AmbermoonSource/src) are copied to build/port/src : the memory attributes of the
# sections are removed (bss_c / data_c / code_c -> bss / data / code, TOS has no CHIP memory), and the
# patches in port/PATCHES are applied (small changes for the ST, marked "; ST:" in the code).
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
for p in port/PATCHES/*.diff; do		# changes of the original files (marked "; ST:")
	patch -s -p1 -d $OUT/src < "$p"
done
cp -r port/KERNEL $OUT/src/ST_KERNEL
cp port/AMBERST.S $OUT/src/
# the ST palettes take a while : made again only when the script changed (also the lookup tables in json for
# the conversion of the graphics)
if [ ! -f $OUT/STPALS.I ] || [ ! -f $OUT/STPALS.json ] || [ port/tools/port_palettes.py -nt $OUT/STPALS.I ]; then
	python3 port/tools/port_palettes.py $OUT/STPALS.I $OUT/STPALS.json
fi
# the game data, the graphics converted to the ST format (port_gfx.py)
python3 port/tools/port_data.py $OUT/hd $OUT/src/ST_KERNEL/FILEMAP.I $OUT/STPALS.json
python3 port/tools/port_chipgfx.py $OUT/src/KERNEL/CHIP_DATA.S $OUT/STPALS.json	# (5-plane program graphics)
cp $OUT/STPALS.I $OUT/src/ST_KERNEL/
cd $OUT/src
# (older vasm versions do not know warning 86)
NOWARN86=-nowarn=86
echo ' nop' > ../nowarn86.s
$VASM -quiet $NOWARN86 -Fbin -o ../nowarn86.bin ../nowarn86.s >/dev/null 2>&1 || NOWARN86=
rm -f ../nowarn86.s ../nowarn86.bin
$VASM -quiet -nowarn=53 -nowarn=62 $NOWARN86 -nowarn=40 -maxerrors=5000 -m68000 -Ftos -align -o ../AMBERST.PRG AMBERST.S
cd ../../..
python3 port/tools/fix_prg.py $OUT/AMBERST.PRG		# (older vasm: data length 2 bytes too short)
cp $OUT/AMBERST.PRG $OUT/hd/
echo "Built build/port/hd/AMBERST.PRG"
