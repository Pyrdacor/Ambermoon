#!/usr/bin/env bash
# Tests of the Ambermoon tools: their results for synthetic data (made by tools/make_data.py) must be the ones of the
# original tools (expected.txt: MD5 sums of the console output and of the files written).
#
#   Tools/tests/run.sh [path/to/cshiftc]           builds the tools and compares (default compiler: $CSHIFTC, the
#                                                   newest one in Tools/.cshift (get-cshift.sh), cshiftc on the PATH)
#   Tools/tests/run.sh --record <Tool>=<command> ...
#                                                   writes the results of the original tools into expected.txt (only
#                                                   those of the tools given), e.g.
#                                                   AmbermoonPack="dotnet AmbermoonPack.dll"
#
# The tools: AmbermoonPack, AmbermoonEventEditor, HexValueChanger, AmbermoonIntroTextPacker, AmbermoonExtroTextPacker,
# AmbermoonExtroIntroTextPackCreator, AmbermoonDiskExtract. The console output is compared without carriage returns
# (Windows writes them for line breaks). The tools that need the data of the game (BUILD_ONLY) are only built.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

TOOLS=(AmbermoonPack AmbermoonEventEditor HexValueChanger AmbermoonIntroTextPacker AmbermoonExtroTextPacker
       AmbermoonExtroIntroTextPackCreator AmbermoonDiskExtract)
BUILD_ONLY=(AmbermoonListExtractor AmbermoonLabdataEditor AmbermoonLabdataExtractor AmbermoonUsedColorsDetector
            Ambermoon3DMapViewer AmbermoonMonsterEditor AmbermoonItemEditor AmbermoonNameExtract
            AmbermoonTextImport AmbermoonTextManager AmbermoonIntroPatcher AmbermoonExtroPatcher
            AmbermoonPaletteChanger AmbermoonImageConverter AmbermoonFontCreator AmbermoonFontProcessor
            AmbermoonReleaseCreator AmbermoonAdvancedReleaseCreator)
declare -A COMMAND

RECORD=0
if [ "${1:-}" = "--record" ]; then
    RECORD=1
    shift
    for arg in "$@"; do
        tool="${arg%%=*}"
        case " ${TOOLS[*]} " in *" $tool "*) ;; *) echo "unknown tool '$tool'"; exit 2 ;; esac
        COMMAND[$tool]="${arg#*=}"
    done
    if [ ${#COMMAND[@]} -eq 0 ]; then echo "no tool given"; exit 2; fi
else
    COMPILER="${1:-${CSHIFTC:-}}"
    if [ -z "$COMPILER" ]; then
        local_compiler="$(ls -d "$ROOT"/.cshift/cshift-*/ 2>/dev/null | sort -V | tail -n 1)"
        for c in "${local_compiler}cshiftc" "${local_compiler}cshiftc.exe"; do
            if [ -n "$local_compiler" ] && [ -x "$c" ]; then COMPILER="$c"; break; fi
        done
        if [ -z "$COMPILER" ] && command -v cshiftc > /dev/null 2>&1; then COMPILER="$(command -v cshiftc)"; fi
    fi
    if [ -z "$COMPILER" ]; then echo "cshiftc not found (get-cshift.sh downloads it)"; exit 2; fi
    CC_ARGS=()
    if [ -n "${CSHIFT_CC:-}" ]; then CC_ARGS=(--cc "$CSHIFT_CC"); fi
    for tool in "${TOOLS[@]}" "${BUILD_ONLY[@]}"; do
        if ! "$COMPILER" build "$ROOT/$tool" "${CC_ARGS[@]}" -o "$TMP/$tool" > "$TMP/build.log" 2>&1; then
            echo "FAIL  Ambermoon: building $tool failed:"
            head -n 20 "$TMP/build.log"
            exit 1
        fi
        COMMAND[$tool]="$TMP/$tool"
    done
fi

hash_text() { tr -d '\r' < "$1" | md5sum | cut -c1-32; }
hash_file() { if [ -f "$1" ]; then md5sum < "$1" | cut -c1-32; else echo "-"; fi; }
# all files of a folder and the folders below it: names and contents
hash_dir() {
    if [ -d "$1" ]; then (cd "$1" && find . -type f | LC_ALL=C sort | while read -r f; do echo "$f $(md5sum < "$f" | cut -c1-32)"; done) | md5sum | cut -c1-32; else echo "-"; fi
}
# the lines of a cases file without comments and empty lines
cases() { grep -v '^[[:space:]]*\(#\|$\)' "$1"; }

RESULTS="$TMP/results.txt"
: > "$RESULTS"

# AmbermoonPack: pack, then unpack what was packed
test_pack() {
    local PACK="$1" name args work
    while read -r name args; do
        work="$TMP/p_$name"
        mkdir -p "$work"
        cp -r "$DIR/pack/files" "$DIR/pack/textfiles" "$DIR/pack/items" "$work/"
        # shellcheck disable=SC2086
        (cd "$work" && $PACK $args > stdout 2>&1 < /dev/null; echo "exit $?" >> stdout)
        echo "pack $name $(hash_text "$work/stdout") $(hash_file "$work/out")" >> "$RESULTS"
        if [ -f "$work/out" ]; then
            local unpack=UNPACK
            [ "$name" = "pkitem" ] && unpack=UNITEM
            (cd "$work" && $PACK $unpack out unpacked > stdout2 2>&1 < /dev/null; echo "exit $?" >> stdout2)
            # the folder of the unpacked files has no folders below it: names and contents in the order of ls
            echo "unpack $name $(hash_text "$work/stdout2") $(hash_flat "$work/unpacked")" >> "$RESULTS"
        fi
    done < <(cases "$DIR/pack/cases.txt")
}
hash_flat() {
    if [ -d "$1" ]; then (cd "$1" && for f in $(ls); do echo "$f $(md5sum < "$f" | cut -c1-32)"; done) | md5sum | cut -c1-32; else echo "-"; fi
}

# AmbermoonEventEditor: sessions of commands
test_events() {
    local EDITOR="$1" session file type n=0 work input
    while read -r session file type; do
        n=$((n + 1))
        work="$TMP/e_$n"
        mkdir -p "$work"
        input="$(basename "$file")"
        cp "$DIR/events/$file" "$work/$input"
        sed 's#@OUT@#saved#g' "$DIR/events/sessions/$session" > "$work/session"
        (cd "$work" && $EDITOR "$input" "$type" < session > stdout 2>&1; echo "exit $?" >> stdout)
        echo "events $session:$file $(hash_text "$work/stdout") $(hash_file "$work/saved") $(hash_file "$work/$input")" >> "$RESULTS"
    done < <(cases "$DIR/events/cases.txt")
}

# HexValueChanger: sessions on copies of the files
test_hex() {
    local HEX="$1" session args n=0 work
    while read -r session args; do
        n=$((n + 1))
        work="$TMP/h_$n"
        mkdir -p "$work"
        cp -r "$DIR/hex/files" "$work/files"
        # shellcheck disable=SC2086
        (cd "$work/files" && set -f && $HEX $args < "$DIR/hex/sessions/$session" > ../stdout 2>&1; echo "exit $?" >> ../stdout)
        echo "hex $n:$session $(hash_text "$work/stdout") $(hash_dir "$work/files")" >> "$RESULTS"
    done < <(cases "$DIR/hex/cases.txt")
}

# AmbermoonIntroTextPacker, AmbermoonExtroTextPacker: in a copy of texts/
test_texts() {
    local kind="$1" PACKER="$2" name packer args work output
    while read -r name packer args; do
        [ "$packer" = "$kind" ] || continue
        # Windows passes the arguments of a program in the ANSI code page, not as UTF-8 (see Todo.md): the cases with
        # other characters than ASCII in their arguments are left out there
        case "$(uname -s)" in
            MINGW*|MSYS*|CYGWIN*)
                if LC_ALL=C grep -q '[^ -~]' <<< "$args"; then
                    echo "skip  Ambermoon $kind $name (arguments that are not ASCII, on Windows)"
                    continue
                fi ;;
        esac
        work="$TMP/t_$name"
        cp -r "$DIR/texts" "$work"
        local argv=()
        for a in $args; do a="${a//_/ }"; argv+=("${a//@DIR@/$work}"); done
        (cd "$work" && $PACKER "${argv[@]}" > "$TMP/t_$name.out" 2>&1 < /dev/null; echo "exit $?" >> "$TMP/t_$name.out")
        sed -i "s#$work#WORK#g" "$TMP/t_$name.out"
        output="$work/Intro_texts.amb"
        [ "$kind" = extro ] && output="$work/Extro_texts.amb"
        echo "$kind $name $(hash_text "$TMP/t_$name.out") $(hash_file "$output")" >> "$RESULTS"
    done < <(cases "$DIR/texts/cases.txt")
}

# AmbermoonExtroIntroTextPackCreator: in a copy of creator/ (the layout of the Ambermoon repository); only the files
# are compared (the port packs the texts itself instead of building and running the packers, its output is shorter)
test_creator() {
    local CREATOR="$1" work="$TMP/creator"
    cp -r "$DIR/creator" "$work"
    (cd "$work" && $CREATOR TESTISH 1.00 "$work/out" > /dev/null 2>&1 < /dev/null)
    echo "creator testish $(hash_file "$work/out/Intro_texts.amb") $(hash_file "$work/out/Extro_texts.amb")" >> "$RESULTS"
}

# AmbermoonDiskExtract: the files of the ADF images in adf/
test_diskextract() {
    local EXTRACT="$1" name args work
    while read -r name args; do
        work="$TMP/d_$name"
        mkdir -p "$work"
        args="${args//@ADF@/$DIR/adf}"
        args="${args//@OUT@/$work/out}"
        # shellcheck disable=SC2086
        (cd "$work" && $EXTRACT $args > stdout 2>&1 < /dev/null; echo "exit $?" >> stdout)
        sed -i "s#$DIR/adf#ADF#g; s#$work#WORK#g" "$work/stdout"
        echo "adf $name $(hash_text "$work/stdout") $(hash_dir "$work/out")" >> "$RESULTS"
    done < <(cases "$DIR/adf/cases.txt")
}

# the kinds of results of each tool
declare -A KINDS=(
    [AmbermoonPack]="pack unpack" [AmbermoonEventEditor]="events" [HexValueChanger]="hex"
    [AmbermoonIntroTextPacker]="intro" [AmbermoonExtroTextPacker]="extro" [AmbermoonExtroIntroTextPackCreator]="creator"
    [AmbermoonDiskExtract]="adf"
)
for tool in "${TOOLS[@]}"; do
    [ -n "${COMMAND[$tool]:-}" ] || continue
    case "$tool" in
        AmbermoonPack) test_pack "${COMMAND[$tool]}" ;;
        AmbermoonEventEditor) test_events "${COMMAND[$tool]}" ;;
        HexValueChanger) test_hex "${COMMAND[$tool]}" ;;
        AmbermoonIntroTextPacker) test_texts intro "${COMMAND[$tool]}" ;;
        AmbermoonExtroTextPacker) test_texts extro "${COMMAND[$tool]}" ;;
        AmbermoonExtroIntroTextPackCreator) test_creator "${COMMAND[$tool]}" ;;
        AmbermoonDiskExtract) test_diskextract "${COMMAND[$tool]}" ;;
    esac
done

if [ $RECORD -eq 1 ]; then
    # keep the results of the other tools
    kinds=""
    for tool in "${!COMMAND[@]}"; do kinds="$kinds ${KINDS[$tool]}"; done
    {
        echo "# MD5 sums of the results of the original tools (Tools/tests/run.sh --record): kind, case, console output"
        echo "# and the files written (for the editor also the edited file; for the creator only the two files)."
        if [ -f "$DIR/expected.txt" ]; then
            grep -v '^#' "$DIR/expected.txt" | while read -r kind rest; do
                case " $kinds " in *" $kind "*) ;; *) echo "$kind $rest" ;; esac
            done
        fi
        cat "$RESULTS"
    } > "$TMP/expected.txt"
    cp "$TMP/expected.txt" "$DIR/expected.txt"
    echo "wrote $DIR/expected.txt ($(wc -l < "$RESULTS") results of $kinds)"
    exit 0
fi

pass=0
fail=0
while read -r kind name rest; do
    want="$(grep -F "$kind $name " "$DIR/expected.txt" | head -n 1)"
    if [ "$want" = "$kind $name $rest" ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        echo "FAIL  Ambermoon $kind $name"
        echo "      expected: ${want:-(none)}"
        echo "      got:      $kind $name $rest"
    fi
done < "$RESULTS"
echo "ok    Ambermoon tools ($pass of $((pass + fail)) results like the original)"
[ $fail -eq 0 ]
