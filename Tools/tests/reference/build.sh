#!/usr/bin/env bash
# build.sh <Tool> [REF]: builds an original tool of AmbermoonTools against the library sources of Ambermoon.net (see
# setup.sh) into REF/tools/<Tool>/out/<Tool>.dll (run it with `dotnet`).
#
# The tool (and the projects it references: Ambermoon.Data.Descriptions, Ambermoon.Data.Text.Patching) is copied to
# REF/tools, its package references to Ambermoon.Common, Ambermoon.Data.Common and Ambermoon.Data.Legacy become project
# references to REF/lib, the target framework becomes net8.0, and patches/<Tool>.diff is applied if there is one: the
# fixes of the port made in the original too, so that the rest can be compared (NOPATCH=1: the original as it is).
# FRAMEWORK=net9.0 builds for another framework (AmbermoonReleaseCreator needs C# 13 of net9.0).
set -eu
T="$1"
REF="${2:-$HOME/ref}"
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$REF/src/ambermoon/AmbermoonTools"
mkdir -p "$REF/tools"

prepare() { # <project folder name>
    local D="$REF/tools/$1"
    rm -rf "$D"; mkdir -p "$D"; cp -r "$SRC/$1/." "$D/"; rm -rf "$D/bin" "$D/obj"
    python3 - "$(ls "$D"/*.csproj)" "$REF/lib" "${FRAMEWORK:-net8.0}" <<'PY'
import re, sys
p, lib, framework = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(p).read()
s = re.sub(r'<PackageReference Include="(Ambermoon\.(?:Common|Data\.Common|Data\.Legacy))" Version="[^"]*" */>',
           lambda m: '<ProjectReference Include="%s/%s/%s.csproj" />' % (lib, m.group(1), m.group(1)), s)
s = re.sub(r'<TargetFramework>net[0-9.]+</TargetFramework>', '<TargetFramework>%s</TargetFramework>' % framework, s)
open(p, 'w').write(s)
PY
}

prepare "$T"
for dep in Ambermoon.Data.Descriptions Ambermoon.Data.Text.Patching; do
    if grep -q "$dep" "$REF/tools/$T"/*.csproj; then
        prepare "$dep"
        [ -n "${NOPATCH:-}" ] || [ ! -f "$HERE/patches/$dep.diff" ] || (cd "$REF/tools" && patch -s -p0 < "$HERE/patches/$dep.diff")
    fi
done
[ -n "${NOPATCH:-}" ] || [ ! -f "$HERE/patches/$T.diff" ] || (cd "$REF/tools" && patch -s -p0 < "$HERE/patches/$T.diff")
cd "$REF/tools/$T" && dotnet build -c Release -o out 2>&1 | grep -E " error |rror\(s\)" | head -20
ls "$REF/tools/$T/out/$T.dll"
