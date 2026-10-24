#!/bin/sh
# Starts the proof of concept in Hatari (STE, 1 MB, EmuTOS or the TOS image given in TOS).
#
#   TOS=/path/to/tos.img ./run_hatari.sh [further Hatari options]
cd "$(dirname "$0")"
exec hatari --machine ste --memsize 1024 ${TOS:+--tos "$TOS"} --harddrive build/hd --auto 'C:\AMBERST.PRG' "$@"
