#!/bin/sh
# Starts the port (build/port/hd, see port/build.sh) in Hatari: STE, 4 MB, EmuTOS.
#
#   port/run_hatari.sh [hd folder] [further Hatari options]
#
# Hatari is taken from PATH, else from %LOCALAPPDATA%/Programs/Hatari (Windows); TOS is the EmuTOS image of
# the Hatari folder unless TOS is set. The mouse stays in the window (--grab; AltGr+M releases it).
cd "$(dirname "$0")/.."
HD=${1:-build/port/hd}
[ $# -gt 0 ] && shift
HATARI=$(command -v hatari)
if [ -z "$HATARI" ] && [ -n "$LOCALAPPDATA" ]; then
	HATARI="$(cygpath -u "$LOCALAPPDATA" 2>/dev/null || echo "$LOCALAPPDATA")/Programs/Hatari/hatari.exe"
fi
[ -x "$HATARI" ] || { echo "Hatari not found (PATH or %LOCALAPPDATA%/Programs/Hatari)"; exit 1; }
TOS=${TOS:-$(dirname "$HATARI")/tos.img}
if command -v cygpath >/dev/null; then		# (Windows: Hatari wants Windows paths)
	HD=$(cygpath -w "$HD")
	TOS=$(cygpath -w "$TOS")
fi
exec "$HATARI" --machine ste --memsize 4096 --tos "$TOS" --harddrive "$HD" --auto 'C:\AMBERST.PRG' --grab "$@"
