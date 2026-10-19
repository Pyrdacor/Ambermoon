#!/usr/bin/env bash
# publish-web.sh [output folder]: the tools with a window as web pages (GitHub Pages, see .github/workflows/web.yml):
# AmbermoonMapEditor2D and AmbermoonImageEditor, each one HTML file made by `cshiftc publish`, and the start page
# web/index.html. The compiler is CSHIFTC, else the latest release of CShift (get-cshift.sh).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-$HERE/bin/web}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

COMPILER="${CSHIFTC:-}"
if [ -z "$COMPILER" ]; then
    COMPILER="$(bash "$HERE/get-cshift.sh")"
fi

for tool in AmbermoonMapEditor2D AmbermoonImageEditor; do
    echo "publishing $tool"
    "$COMPILER" publish "$HERE/$tool" -o "$OUT/$tool.html"
    if [ ! -f "$OUT/$tool.html" ]; then
        echo "error: $tool was not published" >&2
        exit 1
    fi
done
cp "$HERE/web/index.html" "$OUT/index.html"
echo "$OUT"
