#!/bin/sh
# Builds the debug version AM2_CPU_DEBUG from the source code in AmbermoonSource/src
# and writes it to this folder, together with the listing AM2_CPU_DEBUG.lst.
# On a plain 68000 the debug version shows the location of an address error
# (Guru 8000 0003) instead of the Guru (see AmbermoonSource/src/KERNEL/DEBUG_AE.S).
# To test it, rename it to AM2_CPU on the game disk / hard drive.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/../../../AmbermoonSource/src"
"$HERE/vasmm68k_mot.exe" -m68030 -Fhunkexe -o "$HERE/AM2_CPU_DEBUG" -nosym -kick1hunks -keepempty -no-opt -align -DDEBUG=1 -L "$HERE/AM2_CPU_DEBUG.lst" AMBERMOON.S
