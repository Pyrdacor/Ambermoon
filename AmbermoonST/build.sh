#!/bin/sh
# Builds the Atari ST proof of concept into build/hd (a folder which can be used as GEMDOS drive in Hatari or
# copied to a real ST): AMBERST.PRG and the converted data in DATA\.
#
#   ./build.sh [--map 258] [--pos 2,15,1]
#
# Needs Python 3 with Pillow and vasmm68k_mot (set VASM to its path if it is not in PATH).
set -e
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")"
VASM=${VASM:-vasmm68k_mot}
mkdir -p build/hd/DATA
python3 tools/st_convert.py build/hd/DATA "$@"
cd src
$VASM -quiet -nowarn=53 -nowarn=62 -Ftos -m68000 -nosym -o ../build/hd/AMBERST.PRG AMBERST.S
echo "Built build/hd/AMBERST.PRG"
