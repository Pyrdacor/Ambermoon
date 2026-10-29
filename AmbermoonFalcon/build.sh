#!/bin/sh
# Builds the Falcon version into AmbermoonFalcon/build/hd/AMBERFAL.PRG (+ DATA).
#
# Everything comes from the ST port (AmbermoonST/port : the original source, its patches, the kernel, the
# tools and the music), built by its build script; the files of KERNEL/ here replace the files of the ST
# kernel which depend on the video hardware (see PLAN.md).
#
# Needs vasmm68k_mot (set VASM to its path if it is not in PATH) and Python 3 with Pillow.
set -e
cd "$(dirname "$0")/../AmbermoonST"
TARGET=falcon OUT=../AmbermoonFalcon/build OVERLAY=../AmbermoonFalcon/KERNEL exec sh port/build.sh
