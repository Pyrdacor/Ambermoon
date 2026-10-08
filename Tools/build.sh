#!/usr/bin/env bash
# build.sh [path/to/cshiftc]: builds all tools; the programs are put into bin/ (next to this script).
#
# The compiler: the one given, else $CSHIFTC, else the latest release of CShift (get-cshift.sh downloads it into
# .cshift/). If that fails (no network, ...), a compiler that is there already is used: the newest one in .cshift/,
# else cshiftc on the PATH.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
EXE=""
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) EXE=".exe" ;; esac

compiler="${1:-${CSHIFTC:-}}"
if [ -z "$compiler" ]; then
    if latest="$(bash "$HERE/get-cshift.sh")"; then
        compiler="$latest"
    else
        echo "warning: the latest CShift compiler could not be downloaded; looking for one that is there already" >&2
        local_compiler="$(ls -d "$HERE"/.cshift/cshift-*/ 2>/dev/null | sort -V | tail -n 1)"
        if [ -n "$local_compiler" ] && [ -x "${local_compiler}cshiftc$EXE" ]; then
            compiler="${local_compiler}cshiftc$EXE"
        elif command -v cshiftc > /dev/null 2>&1; then
            compiler="$(command -v cshiftc)"
        fi
    fi
fi
if [ -z "$compiler" ] || [ ! -x "$compiler" ]; then
    echo "error: no CShift compiler (pass its path, set CSHIFTC or put cshiftc on the PATH)" >&2
    exit 1
fi
echo "compiler: $compiler ($("$compiler" --version 2>&1 | head -n 1))"

mkdir -p "$HERE/bin"
built=0
failed=()
for project in "$HERE"/*/cshift.json; do
    grep -q '"type": *"library"' "$project" && continue
    dir="$(dirname "$project")"
    name="$(basename "$dir")"
    if "$compiler" build "$dir" > "$HERE/bin/$name.log" 2>&1; then
        cp "$dir/bin/$name$EXE" "$HERE/bin/"
        rm -f "$HERE/bin/$name.log"
        built=$((built + 1))
        echo "built  $name"
    else
        failed+=("$name")
        echo "FAILED $name (see bin/$name.log)"
    fi
done
echo "$built tools built into $HERE/bin"
if [ ${#failed[@]} -gt 0 ]; then
    echo "failed: ${failed[*]}" >&2
    exit 1
fi
