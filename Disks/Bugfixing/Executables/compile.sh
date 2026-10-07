#!/bin/sh
# Builds AM2_CPU from the source code in AmbermoonSource/src and writes it to this folder.
# AM2_CPU.s (disassembly) is no longer used, see README.md.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/../../../AmbermoonSource/src"
"$HERE/vasmm68k_mot.exe" -m68030 -Fhunkexe -o "$HERE/AM2_CPU" -nosym -kick1hunks -keepempty -no-opt -align AMBERMOON.S
