#!/bin/bash
# Runs the port in Hatari and plays a scenario (see HANDOVER.md).
#
#   run.sh <scenario> <out.avi> <vbls> [log]
#
# Environment : MACHINE (ste), MEM (4096 KB), TMO (timeout in s, 300), TOS (EmuTOS image),
#               HD (build/port/hd), PRG (HD/AMBERST.PRG)
# Scenario lines :
#   sleep <s>                 wait (real time; Hatari loses commands which come too fast)
#   click left|right          press the button for 0.3 s
#   move <x> <y>              set the mouse position (Mouse_X/Mouse_Y)
#   <hatari debugger command> e.g. "w {Mouse_X} $00 $10", "b pc = {Raster_VBL} && HBL > 2 :trace";
#                             {Name} is replaced by the address of the symbol
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$HERE/../..
SCEN=$1; OUT=$2; VBLS=$3; LOG=${4:-${OUT%.*}.log}
HD=${HD:-$ROOT/build/port/hd}
PRG=${PRG:-$HD/AMBERST.PRG}
TOS=${TOS:-/opt/tools/emutos/emutos-256k-1.4/etos256us.img}
FIFO=$(mktemp -u /tmp/hatari-fifo.XXXXXX)
sym() { python3 "$HERE/sym.py" "$PRG" "$1" | cut -d' ' -f2 | sed 's/^0x/$/'; }
resolve() {
  local l=$1
  while [[ $l =~ \{([A-Za-z0-9_]+)\} ]]; do
    l=${l//\{${BASH_REMATCH[1]}\}/$(sym "${BASH_REMATCH[1]}")}
  done
  echo "$l"
}
BUTTONS=$(sym ST_mouse_buttons)
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy timeout ${TMO:-300} hatari --machine ${MACHINE:-ste} --tos "$TOS" \
  --memsize ${MEM:-4096} --harddrive "$HD" --auto 'C:\AMBERST.PRG' --sound off --run-vbls "$VBLS" \
  --avirecord --avi-vcodec png --avi-file "$OUT" --confirm-quit off --statusbar off --drive-led off \
  --borders off --log-level error --cmd-fifo "$FIFO" >"$LOG" 2>&1 &
PID=$!
sleep 1
while read -r line; do
  case "$line" in
    ''|'#'*) ;;
    sleep*) sleep ${line#sleep } ;;
    click\ left|click\ right)
      [ "${line#click }" = left ] && b='$02' || b='$01'
      echo "hatari-debug w $BUTTONS $b" > "$FIFO"; sleep 0.3
      echo "hatari-debug w $BUTTONS \$00" > "$FIFO"; sleep 0.3 ;;
    move\ *)
      set -- $line
      echo "hatari-debug w $(sym Mouse_X) $(printf '$%02x $%02x $%02x $%02x' $(($2>>8)) $(($2&255)) $(($3>>8)) $(($3&255)))" > "$FIFO"
      sleep 0.3 ;;
    *) echo "hatari-debug $(resolve "$line")" > "$FIFO" ;;
  esac
done < "$SCEN"
wait $PID
rm -f "$FIFO"
