#!/bin/sh
# Builds the port of the original source (see PORT.md) into build/port/AMBERST.PRG.
#
# The original sources (AmbermoonSource/src) are copied to build/port/src : the memory attributes of the
# sections are removed (bss_c / data_c / code_c -> bss / data / code, TOS has no CHIP memory), and the
# patches in port/PATCHES are applied (small changes for the ST, marked "; ST:" in the code).
#
# Needs vasmm68k_mot (set VASM to its path if it is not in PATH).
#
# The Falcon version (AmbermoonFalcon/build.sh) is built by this script too : TARGET=falcon, OUT (the build
# folder), OVERLAY (its kernel files, they replace the hardware files of the ST kernel). Its graphics stay the
# original ones (32 colours), the CPU is a 68030.
set -e
cd "$(dirname "$0")/.."
VASM=${VASM:-vasmm68k_mot}
TARGET=${TARGET:-st}
OUT=${OUT:-build/port}
if [ "$TARGET" = falcon ]; then
	PRG=AMBERFAL.PRG
	CPU=-m68030
else
	PRG=AMBERST.PRG
	CPU=-m68000
fi
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
if [ -n "$OVERLAY" ]; then			# (the hardware files of another machine)
	cp -r "$OVERLAY"/. $OUT/src/ST_KERNEL/
fi
cp port/AMBERST.S $OUT/src/
if [ "$TARGET" = falcon ]; then
	# the game data with the original graphics
	python3 port/tools/port_data.py $OUT/hd $OUT/src/ST_KERNEL/FILEMAP.I --falcon
else
	# the ST palettes take a while : made again only when the script changed (also the lookup tables in json
	# for the conversion of the graphics)
	if [ ! -f $OUT/STPALS.I ] || [ ! -f $OUT/STPALS.json ] || [ port/tools/port_palettes.py -nt $OUT/STPALS.I ]; then
		python3 port/tools/port_palettes.py $OUT/STPALS.I $OUT/STPALS.json
	fi
	# the game data, the graphics converted to the ST format (port_gfx.py)
	python3 port/tools/port_data.py $OUT/hd $OUT/src/ST_KERNEL/FILEMAP.I $OUT/STPALS.json
	python3 port/tools/port_chipgfx.py $OUT/src/KERNEL/CHIP_DATA.S $OUT/STPALS.json	# (5-plane program graphics)
	cp $OUT/STPALS.I $OUT/src/ST_KERNEL/
fi
python3 port/tools/port_music.py $OUT/src/ST_KERNEL/MUSPLAY.I	# (the player of the ST music)
cd $OUT/src
# (older vasm versions do not know warning 86)
NOWARN86=-nowarn=86
echo ' nop' > ../nowarn86.s
$VASM -quiet $NOWARN86 -Fbin -o ../nowarn86.bin ../nowarn86.s >/dev/null 2>&1 || NOWARN86=
rm -f ../nowarn86.s ../nowarn86.bin
$VASM -quiet -nowarn=53 -nowarn=62 $NOWARN86 -nowarn=40 -maxerrors=5000 $CPU -Ftos -align -o ../$PRG AMBERST.S
cd - >/dev/null
python3 port/tools/fix_prg.py $OUT/$PRG		# (older vasm: data length 2 bytes too short)
cp $OUT/$PRG $OUT/hd/
echo "Built $OUT/hd/$PRG"
