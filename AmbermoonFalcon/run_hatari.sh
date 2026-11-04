#!/bin/sh
# Starts the Falcon version (build/hd, see build.sh) in Hatari: Falcon, 14 MB, RGB monitor (50 Hz), EmuTOS.
#
#   ./run_hatari.sh [further Hatari options]
#
# Hatari is taken from PATH, else from %LOCALAPPDATA%/Programs/Hatari (Windows); TOS is the EmuTOS image of
# the Hatari folder unless TOS is set (it must support the Falcon : the 512 KB or 1 MB image). The mouse stays
# in the window (--grab; AltGr+M releases it).
cd "$(dirname "$0")"
HD=build/hd
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
exec "$HATARI" --machine falcon --memsize 14336 --monitor rgb --tos "$TOS" --harddrive "$HD" \
	--auto 'C:\AMBERFAL.PRG' --grab "$@"
