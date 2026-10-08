#!/usr/bin/env bash
# package-tools.sh <version> <platform> [output folder]: builds the tools of the tool release and packs them into one
# archive (default output folder: release/ next to this script).
#
#   windows  AmbermoonTools-<version>-Windows.zip   (on Windows in Git Bash or MSYS2, with 7z or PowerShell)
#   linux    AmbermoonTools-<version>-Linux.tar.gz  (on Linux)
#   amiga    AmbermoonTools-<version>-Amiga.lha     (any host, needs lha, e.g. jlha-utils on Linux)
#
# The compiler: $CSHIFTC, else the latest release of CShift (get-cshift.sh).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ $# -lt 2 ]; then
    echo "usage: package-tools.sh <version> <windows|linux|amiga> [output folder]" >&2
    exit 1
fi
VERSION="$1"
PLATFORM="$2"
OUT="${3:-$HERE/release}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

# the tools of the release
TOOLS=(Ambermoon3DMapViewer AmbermoonDiskExtract AmbermoonEventEditor AmbermoonImageConverter AmbermoonItemEditor
       AmbermoonLabdataEditor AmbermoonPack AmbermoonTextManager)

case "$PLATFORM" in
    windows) EXE=".exe"; TARGET=(); ARCHIVE="AmbermoonTools-$VERSION-Windows.zip" ;;
    linux)   EXE="";     TARGET=(); ARCHIVE="AmbermoonTools-$VERSION-Linux.tar.gz" ;;
    amiga)   EXE="";     TARGET=(--target m68k-amigaos); ARCHIVE="AmbermoonTools-$VERSION-Amiga.lha" ;;
    *) echo "error: unknown platform '$PLATFORM' (windows, linux or amiga)" >&2; exit 1 ;;
esac

COMPILER="${CSHIFTC:-}"
if [ -z "$COMPILER" ]; then
    COMPILER="$(bash "$HERE/get-cshift.sh")"
fi

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
DIR="$STAGE/AmbermoonTools"
mkdir -p "$DIR"

for tool in "${TOOLS[@]}"; do
    echo "building $tool ($PLATFORM)"
    "$COMPILER" build "$HERE/$tool" "${TARGET[@]}" -o "$DIR/$tool$EXE"
    if [ ! -f "$DIR/$tool$EXE" ]; then
        echo "error: $tool was not built" >&2
        exit 1
    fi
done

rm -f "$OUT/$ARCHIVE"
case "$PLATFORM" in
    windows)
        if command -v 7z > /dev/null 2>&1; then
            (cd "$STAGE" && 7z a -tzip -mx=9 -bd "$OUT/$ARCHIVE" AmbermoonTools > /dev/null)
        else
            powershell -NoProfile -Command "Compress-Archive -Path '$(cygpath -w "$DIR")' -DestinationPath '$(cygpath -w "$OUT/$ARCHIVE")'"
        fi ;;
    linux)   chmod +x "$DIR"/*; tar -czf "$OUT/$ARCHIVE" -C "$STAGE" AmbermoonTools ;;
    amiga)   (cd "$STAGE" && lha aq "$OUT/$ARCHIVE" AmbermoonTools) ;;
esac
echo "$OUT/$ARCHIVE"
