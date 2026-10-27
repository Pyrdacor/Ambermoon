#!/usr/bin/env python3
"""Runs the port in Hatari and plays a scenario frame by frame (also on Windows: no command FIFO).

    run.py <scenario> <out.avi> <vbls> [log]

The scenario lines are turned into Hatari debugger breakpoints on the frame counter (VBL) which run the
commands of the line when the frame is reached: the timing is exact, a run plays the same every time (run.sh
sends the commands through the command FIFO in real time instead, which Hatari for Windows does not have).

Environment : HATARI (hatari program), MACHINE (ste), MEM (4096 KB), TMO (timeout in s, 300), TOS (TOS image,
              default: the EmuTOS of the Hatari folder), HD (build/port/hd), PRG (HD/AMBERST.PRG),
              TEXT_BASE (start of the text segment, hex; 1b018 with the EmuTOS 1.4 of Hatari 2.6 and a GEMDOS
              drive, see "info basepage" in the debugger)
Scenario lines :
  wait <vbls>               the next lines come so many frames later
  vbl <n>                   the next lines come at frame n
  click left|right          press the button (ST_mouse_buttons) for 15 frames; the next line 20 frames later
  move <x> <y>              set the mouse position (Mouse_X/Mouse_Y, screen coordinates)
  <hatari debugger command> at the current frame, e.g. "w {Mouse_X} $00 $10"; before the first wait / vbl it
                            is set at the start (e.g. "b pc = {Raster_VBL} && HBL > 2 :trace");
                            {Name} is replaced by the address of the symbol
  sleep <s>                 (run.sh scenarios) 50 frames per second
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
os.environ.setdefault('TEXT_BASE', '1b018')
import sym  # noqa: E402  (reads TEXT_BASE)


def hatari():
    h = os.environ.get('HATARI') or shutil.which('hatari')
    if not h:
        local = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'Programs', 'Hatari', 'hatari.exe')
        h = local if os.path.exists(local) else 'hatari'
    return h


def main():
    scen, out, vbls = sys.argv[1], sys.argv[2], int(sys.argv[3])
    log = sys.argv[4] if len(sys.argv) > 4 else os.path.splitext(out)[0] + '.log'
    hd = os.environ.get('HD', os.path.join(ROOT, 'build', 'port', 'hd'))
    prg = os.environ.get('PRG', os.path.join(hd, 'AMBERST.PRG'))
    exe = hatari()
    tos = os.environ.get('TOS', os.path.join(os.path.dirname(exe), 'tos.img'))
    symbols = sym.symbols(prg)

    def resolve(line):
        return re.sub(r'\{([A-Za-z0-9_]+)\}', lambda m: '$%x' % symbols[m.group(1)], line)

    def word_bytes(v):
        return '$%02x $%02x' % ((v >> 8) & 255, v & 255)

    start, actions, frame, timed = [], {}, 0, False
    for line in open(scen, encoding='utf-8'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        cmd = line.split()
        if cmd[0] == 'wait':
            frame += int(cmd[1])
            timed = True
        elif cmd[0] == 'vbl':
            frame = int(cmd[1])
            timed = True
        elif cmd[0] == 'sleep':
            frame += round(float(cmd[1]) * 50)
            timed = True
        elif cmd[0] == 'click':
            b = '$02' if cmd[1] == 'left' else '$01'
            actions.setdefault(frame, []).append('w $%x %s' % (symbols['ST_mouse_buttons'], b))
            actions.setdefault(frame + 15, []).append('w $%x $00' % symbols['ST_mouse_buttons'])
            frame += 20
        elif cmd[0] == 'move':
            x, y = int(cmd[1]), int(cmd[2])
            actions.setdefault(frame, []).append('w $%x %s %s' % (symbols['Mouse_X'], word_bytes(x), word_bytes(y)))
            frame += 2
        elif not timed:
            start.append(resolve(line))
        else:
            actions.setdefault(frame, []).append(resolve(line))

    tmp = tempfile.mkdtemp(prefix='hatari_')
    parse = os.path.join(tmp, 'parse.ini')
    with open(parse, 'w') as f:
        for line in start:
            f.write(line + '\n')
        for n, (v, cmds) in enumerate(sorted(actions.items())):
            name = os.path.join(tmp, 'act%d.ini' % n)
            with open(name, 'w') as a:
                a.write('\n'.join(cmds) + '\n')
            f.write('b VBL = %d :once :quiet :trace :file %s\n' % (v, name))
    env = dict(os.environ, SDL_VIDEODRIVER='dummy', SDL_AUDIODRIVER='dummy')
    args = [exe, '--machine', os.environ.get('MACHINE', 'ste'), '--tos', tos, '--memsize',
            os.environ.get('MEM', '4096'), '--harddrive', hd, '--auto', 'C:\\AMBERST.PRG', '--sound', 'off',
            '--run-vbls', str(vbls), '--avirecord', '--avi-vcodec', 'png', '--avi-file', out, '--confirm-quit',
            'off', '--statusbar', 'off', '--drive-led', 'off', '--borders', 'off', '--log-level', 'error',
            '--parse', parse]
    with open(log, 'w') as f:
        try:
            subprocess.run(args, env=env, stdout=f, stderr=subprocess.STDOUT,
                           timeout=int(os.environ.get('TMO', '300')))
        except subprocess.TimeoutExpired:
            print('timeout')
    shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    main()
