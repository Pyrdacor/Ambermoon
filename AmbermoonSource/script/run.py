"""Runs a script of the script player in FS-UAE (Windows), optionally records a video.

Usage: python run.py <script.txt> [--record <video.mp4>] [--seconds <n>] [--frames <folder>] [--every <s>] [--fast-cpu]
                     [--setup] [--release <zip>] [--boot <drive>] [--load <slot> --start <label>]

- builds the script variants of AM2_CPU and the loader (vasm, symbol Script),
- compiles the script to Script.bin (amscript.py),
- prepares the FS-UAE hard drive "AmbermoonEN_Script" (with --setup or if it is missing: boot files of an
  existing Ambermoon drive and the extracted english release),
- writes the configuration AmbermoonEN_Script.fs-uae and starts FS-UAE,
- --load/--start: continues the game saved in the slot (script command savegame), the script starts at the label,
- --record: records the window with ffmpeg (no sound), --frames: saves a screenshot every --every seconds.
FS-UAE is closed after --seconds (default: 60).
"""
import argparse
import ctypes
import ctypes.wintypes
import os
import shutil
import struct
import subprocess
import sys
import time
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, '..', '..'))
SRC = os.path.join(REPO, 'AmbermoonSource', 'src')
VASM = os.path.join(REPO, 'Disks', 'Bugfixing', 'Executables', 'vasmm68k_mot.exe')
DOCS = os.path.join(os.path.expanduser('~'), 'Documents', 'FS-UAE')
DRIVE = os.path.join(DOCS, 'Hard Drives', 'AmbermoonEN_Script')
CONFIG = os.path.join(DOCS, 'Configurations', 'AmbermoonEN_Script.fs-uae')
FSUAE = os.path.join(os.path.expanduser('~'), 'AppData', 'Local', 'Programs', 'FS-UAE', 'FS-UAE', 'Windows',
                     'x86-64', 'fs-uae.exe')
KICKSTART = os.path.join(DOCS, 'Kickstarts', 'Kickstart-v3.1-rev-40.68-1993-Commodore-A1200.rom')
BUILD = os.path.join(HERE, 'build')
BOOT_DIRS = ['C', 'Devs', 'L', 'S', 'System']


def ffmpeg():
    found = shutil.which('ffmpeg')
    if found:
        return found
    base = os.path.join(os.path.expanduser('~'), 'AppData', 'Local', 'Microsoft', 'WinGet', 'Packages')
    for root, _, files in os.walk(base):
        if 'ffmpeg.exe' in files:
            return os.path.join(root, 'ffmpeg.exe')
    raise SystemExit('ffmpeg not found')


def build(resume=False):
    os.makedirs(BUILD, exist_ok=True)
    am2 = os.path.join(BUILD, 'AM2_CPU')
    loader = os.path.join(BUILD, 'Ambermoon')
    subprocess.run([VASM, '-m68030', '-Fhunkexe', '-o', am2, '-nosym', '-kick1hunks', '-keepempty', '-no-opt', '-align',
                    '-DScript=1', 'AMBERMOON.S'], cwd=SRC, check=True, stdout=subprocess.DEVNULL)
    subprocess.run([VASM, '-m68030', '-Fhunkexe', '-o', loader, '-nosym', '-kick1hunks', '-keepempty', '-no-opt',
                    '-DScript=1'] + (['-DScriptContinue=1'] if resume else []) + ['Ambermoon.s'], cwd=os.path.join(SRC, 'LOADER'), check=True,
                   stdout=subprocess.DEVNULL)
    return am2, loader


def setup_drive(release, boot):
    if os.path.exists(DRIVE):
        shutil.rmtree(DRIVE)
    os.makedirs(DRIVE)
    for name in BOOT_DIRS:
        shutil.copytree(os.path.join(boot, name), os.path.join(DRIVE, name))
    with zipfile.ZipFile(release) as z:
        z.extractall(DRIVE)
    for name in ('Startup-Sequence', 'startup-sequence'):
        path = os.path.join(DRIVE, 'S', name)
        if os.path.exists(path):
            os.remove(path)
    with open(os.path.join(DRIVE, 'S', 'Startup-Sequence'), 'w', newline='\n') as f:
        f.write('Ambermoon\n')


def write_config(fast_cpu=False):
    FAST_CPU = 'uae_cpu_speed = max\nuae_cpu_cycle_exact = false\n' if fast_cpu else ''
    with open(CONFIG, 'w', newline='\n') as f:
        f.write('[fs-uae]\n'
                'amiga_model = A1200\n'
                'kickstart_file = %s\n'
                'hard_drive_0 = %s\n'
                'hard_drive_0_label = Ambermoon\n'
                'fast_memory = 8192\n'
                'floppy_drive_volume = 0\n'
                'fullscreen = 0\n'
                'window_width = 960\n'
                'window_height = 600\n'
                'automatic_input_grab = 0\n'
                'initial_input_grab = 0\n'
                '%s' % (KICKSTART.replace('\\', '/'), DRIVE.replace('\\', '/'), FAST_CPU))


PACK = os.path.join(REPO, 'Tools', 'bin', 'AmbermoonPack.exe')
DATA = os.path.join(BUILD, 'data')


def unpack_data():
    """The map data for walkto (amscript.py): the containers of the drive, unpacked with AmbermoonPack."""
    for name in ('1Map_data.amb', '2Map_data.amb', '3Map_data.amb', 'Icon_data.amb', '2Lab_data.amb', '3Lab_data.amb'):
        target = os.path.join(DATA, name)
        if not os.path.exists(target):
            os.makedirs(DATA, exist_ok=True)
            subprocess.run([PACK, 'UNPACK', os.path.join(DRIVE, 'Amberfiles', name), target], check=True,
                           stdout=subprocess.DEVNULL)


def window_rect(pid, timeout=20):
    user32 = ctypes.windll.user32
    user32.SetProcessDPIAware()
    found = []

    @ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)
    def callback(hwnd, _):
        p = ctypes.wintypes.DWORD()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(p))
        if p.value == pid and user32.IsWindowVisible(hwnd):
            # on top of all windows, so that the recording of the screen area only shows the emulator
            user32.SetWindowPos(hwnd, -1, 0, 0, 0, 0, 0x0001 | 0x0002 | 0x0010)
            r = ctypes.wintypes.RECT()
            pt = ctypes.wintypes.POINT(0, 0)
            user32.GetClientRect(hwnd, ctypes.byref(r))
            user32.ClientToScreen(hwnd, ctypes.byref(pt))
            if r.right > 200:
                title = ctypes.create_unicode_buffer(256)
                user32.GetWindowTextW(hwnd, title, 256)
                found.append((pt.x, pt.y, r.right, r.bottom, title.value))
        return True

    end = time.time() + timeout
    while time.time() < end:
        found.clear()
        user32.EnumWindows(callback, 0)
        if found:
            return found[0]
        time.sleep(0.5)
    raise SystemExit('the FS-UAE window was not found')


def tag_frame(log, tag):
    """The frame (VBL counter) of the first log line with the tag, else None."""
    try:
        for line in open(log, encoding='latin-1'):
            f = line.split()
            if len(f) > 1 and f[0] == '%04x' % int(tag, 16):
                return int(f[1], 16)
    except OSError:
        pass
    return None


def expected(log, tag):
    return tag_frame(log, tag) is not None


def run_once(args, log, attempt):
    """One emulator run. True: restart (the expected tag did not come in time, or the limit was reached)."""
    emu = subprocess.Popen([FSUAE, CONFIG])
    recorder = None
    retry = False
    try:
        x, y, w, h, title = window_rect(emu.pid)
        grab = ['-f', 'gdigrab', '-i', 'title=' + title]
        target = None
        if args.record:
            target = args.record if attempt == 0 else '%s_%d%s' % (os.path.splitext(args.record)[0], attempt,
                                                                    os.path.splitext(args.record)[1])
            recorder = subprocess.Popen([ffmpeg(), '-y', '-loglevel', 'error', '-framerate', '50'] + grab +
                                        ['-t', str(args.seconds), '-c:v', 'libx264', '-preset', 'veryfast',
                                         '-pix_fmt', 'yuv420p', target], stdin=subprocess.PIPE)
        start = time.time()
        game_start = None
        shot = 0
        if args.frames:
            os.makedirs(args.frames, exist_ok=True)
        while time.time() - start < args.seconds:
            if emu.poll() is not None:
                break
            # the time counts from the first log line (the game runs), not from the emulator start
            if args.expect and game_start is None and os.path.exists(log):
                game_start = time.time()
            if args.expect and game_start and time.time() - game_start > args.within and                     not expected(log, args.expect):
                retry = True
                break
            if args.success:
                if game_start is None and os.path.exists(log):
                    game_start = time.time()
                frame = tag_frame(log, args.success)
                if frame is not None:
                    seconds = frame / 50.0
                    print('attempt %d: complete after %d:%02d game time%s' % (
                        attempt + 1, seconds // 60, seconds % 60,
                        (' (video: %s)' % target) if args.record else ''))
                    time.sleep(15)              # a little of the outro
                    retry = seconds > args.limit
                    break
                if game_start and time.time() - game_start > args.limit + 30:
                    print('attempt %d: no outro after %d seconds, aborted' % (attempt + 1, args.limit))
                    retry = True
                    break
            if args.frames:
                path = os.path.join(args.frames, '%d_%04d.png' % (attempt, shot))
                subprocess.run([ffmpeg(), '-y', '-loglevel', 'error'] + grab + ['-frames:v', '1', path])
                shot += 1
                time.sleep(max(0, start + shot * args.every - time.time()))
            else:
                time.sleep(0.5)
    finally:
        if recorder:
            if retry:
                recorder.terminate()
            recorder.wait()
        emu.terminate()
        emu.wait()
    return retry


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('script')
    ap.add_argument('--record')
    ap.add_argument('--frames')
    ap.add_argument('--every', type=float, default=2.0)
    ap.add_argument('--seconds', type=float, default=60)
    ap.add_argument('--setup', action='store_true')
    ap.add_argument('--fast-cpu', action='store_true', help='CPU as fast as possible (not like a real A1200)')
    ap.add_argument('--release', default=None)
    ap.add_argument('--load', type=int, help='continue the game saved in this slot (1-10)')
    ap.add_argument('--start', help='the script starts at this label (with --load)')
    ap.add_argument('--expect', help='log tag (hex) that must appear within --within seconds, else restart')
    ap.add_argument('--within', type=float, default=45)
    ap.add_argument('--attempts', type=int, default=5)
    ap.add_argument('--success', help='log tag (hex): the run is complete (e.g. the outro begins)')
    ap.add_argument('--limit', type=float, default=420, help='with --success: at most this many seconds of game time')
    ap.add_argument('--boot', default=os.path.join(DOCS, 'Hard Drives', 'AmbermoonDE'))
    args = ap.parse_args()

    if bool(args.load) != bool(args.start):
        raise SystemExit('--load and --start belong together')
    am2, loader = build(bool(args.load))
    if args.setup or not os.path.exists(DRIVE):
        if not args.release:
            raise SystemExit('--release <ambermoon_english_X.XX_extracted.zip> is needed for the setup')
        setup_drive(args.release, args.boot)
        shutil.rmtree(DATA, ignore_errors=True)
    unpack_data()
    script_bin = os.path.join(BUILD, 'Script.bin')
    subprocess.run([sys.executable, os.path.join(HERE, 'amscript.py'), args.script, script_bin, '--data=' + DATA] +
                   (['--start=' + args.start] if args.start else []), check=True)
    saves = os.path.join(DRIVE, 'Amberfiles', 'Saves')
    with open(saves, 'r+b') as f:
        # the game continues the "current" save (first word); 0 for a new game
        f.write(struct.pack('>H', args.load or 0))
    log = os.path.join(DRIVE, 'Amberfiles', 'Script.log')
    if os.path.exists(log):
        os.remove(log)
    # a fresh start: the saves of the release (the game must not continue an old run)
    shutil.copyfile(am2, os.path.join(DRIVE, 'Amberfiles', 'AM2_CPU'))
    shutil.copyfile(loader, os.path.join(DRIVE, 'Ambermoon'))
    shutil.copyfile(script_bin, os.path.join(DRIVE, 'Amberfiles', 'Script.bin'))
    write_config(args.fast_cpu)

    for attempt in range(args.attempts if args.expect or args.success else 1):
        if os.path.exists(log):
            os.remove(log)
        if not run_once(args, log, attempt):
            break
        if args.expect:
            print('attempt %d: tag %s not reached within %d seconds, restarting' % (attempt + 1, args.expect,
                                                                                      args.within))
    if os.path.exists(log):
        print(open(log, encoding='latin-1').read())


if __name__ == '__main__':
    main()
