#!/usr/bin/env bash
# get-cshift.sh [folder]: downloads the latest release of the CShift compiler
# (https://github.com/Robert-Schneckenhaus/CShift) into a folder (default: .cshift next to this script) and prints
# the path of its cshiftc. A release that is there already is not downloaded again.
#
# Linux x64 (cshift-<version>-linux-x64.tar.xz, needs curl or wget, tar and xz) and Windows x64 in Git Bash or MSYS2
# (cshift-<version>-windows-x64.zip, needs unzip). The compiler brings its own clang; on Linux it needs the C library
# and the linker of the system (build-essential).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-$HERE/.cshift}"
REPO="Robert-Schneckenhaus/CShift"

case "$(uname -s)" in
    Linux*)               platform="linux-x64"; ext="tar.xz"; exe="cshiftc" ;;
    MINGW*|MSYS*|CYGWIN*) platform="windows-x64"; ext="zip"; exe="cshiftc.exe" ;;
    *) echo "error: there is no release of CShift for $(uname -s) (Linux and Windows only)" >&2; exit 1 ;;
esac

fetch() { # <url> <output file or ->
    if command -v curl > /dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    elif command -v wget > /dev/null 2>&1; then
        wget -q "$1" -O "$2"
    else
        echo "error: curl or wget is needed" >&2
        return 1
    fi
}

tag="$(fetch "https://api.github.com/repos/$REPO/releases/latest" - | grep -o '"tag_name": *"[^"]*"' | head -n 1 | sed 's/.*"\([^"]*\)"$/\1/')"
if [ -z "$tag" ]; then
    echo "error: the latest release of CShift cannot be found" >&2
    exit 1
fi
version="${tag#v}"
name="cshift-$version-$platform"
compiler="$OUT/$name/$exe"

if [ ! -x "$compiler" ]; then
    mkdir -p "$OUT"
    archive="$OUT/$name.$ext"
    echo "downloading CShift $version ($name.$ext)" >&2
    fetch "https://github.com/$REPO/releases/download/$tag/$name.$ext" "$archive"
    case "$ext" in
        zip)    (cd "$OUT" && unzip -q -o "$name.$ext") ;;
        tar.xz) tar -xJf "$archive" -C "$OUT" ;;
    esac
    rm -f "$archive"
fi
"$compiler" --version >&2
echo "$compiler"
