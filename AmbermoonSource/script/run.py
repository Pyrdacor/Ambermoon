"""Runs a script of the script player in FS-UAE (Windows), optionally records a video.

Usage: python run.py <script.txt> [--record <video.mp4>] [--seconds <n>] [--frames <folder>] [--every <s>] [--fast-cpu]
                     [--setup] [--release <zip>] [--boot <drive>] [--load <slot> --start <label>]

- builds the script variants of AM2_CPU and the loader (vasm, symbol Script),
- compiles the script to Script.bin (amscript.py),
- prepares the FS-UAE hard drive "AmbermoonEN_Script" (with --setup or if it is missing: boot files of an
  existing Ambermoon drive and the extracted english release),
- writes the configurations AmbermoonEN_Script.fs-uae (FS-UAE) and build/AmbermoonEN_Script.uae (WinUAE) and starts
  the emulator (--emu: WinUAE minimized, the default without a recording; FS-UAE with a window),
- --load/--start: continues the game saved in the slot (script command savegame), the script starts at the label,
- --record: records the window with ffmpeg (no sound), --frames: saves a screenshot every --every seconds.
FS-UAE is closed after --seconds (default: 60).
"""
import argparse
import json
import ctypes
import glob
import ctypes.wintypes
import os
import re
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
WINUAE = os.path.join(os.environ.get('ProgramFiles', 'C:/Program Files'), 'WinUAE', 'winuae64.exe')
BUILD = os.path.join(HERE, 'build')
UAE_CONFIG = os.path.join(BUILD, 'AmbermoonEN_Script.uae')
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
                'floppy_drive_volume = 0\n'
                'fullscreen = 0\n'
                'window_width = 960\n'
                'window_height = 600\n'
                'automatic_input_grab = 0\n'
                'initial_input_grab = 0\n'
                '%s' % (KICKSTART.replace('\\', '/'), DRIVE.replace('\\', '/'), FAST_CPU))


def write_uae_config(fast_cpu=False, record=False):
    """WinUAE: A1200 like the FS-UAE configuration; started minimized and running on while minimized (no window
    in the way). record: started as a window (minimized nothing is drawn, so nothing recorded; it is moved off the
    screen instead) and F11 starts / stops WinUAE's own video recording (its codec and file in the WinUAE settings,
    Output panel)."""
    # (WinUAE's A1200 model: cycle exact like a real A1200)
    cpu = ('cpu_speed=max\ncpu_cycle_exact=false\ncpu_memory_cycle_exact=false\n' if fast_cpu else
           'cycle_exact=true\ncpu_cycle_exact=true\ncpu_memory_cycle_exact=true\nblitter_cycle_exact=true\n')
    with open(UAE_CONFIG, 'w') as f:
        f.write('config_description=Ambermoon script player\n'
                'use_gui=no\n'
                'quickstart=a1200,0\n'
                'kickstart_rom_file=%s\n'
                '%s'
                'filesystem2=rw,DH0:Ambermoon:%s,0\n'
                'uaehf0=dir,rw,DH0:Ambermoon:%s,0\n'
                'sound_output=none\n'
                'floppy0type=-1\n'
                'win32.start_iconified=%s\n'
                'win32.iconified_pause=false\n'
                'win32.iconified_nosound=true\n'
                'win32.inactive_pause=false\n'
                'win32.inactive_nosound=true\n'
                'win32.inactive_input=0\n'
                'win32.iconified_input=0\n'
                % (KICKSTART, cpu, DRIVE, DRIVE, 'false' if record else 'true'))
        if record:
            f.write('input.config=1\n'
                    'input.1.keyboard.0.friendlyname=WinUAE keyboard\n'
                    'input.1.keyboard.0.name=NULLKEYBOARD\n'
                    'input.1.keyboard.0.empty=false\n'
                    'input.1.keyboard.0.disabled=false\n'
                    'input.1.keyboard.0.button.87.F11=SPC_VIDEORECORD.0\n')


def winuae_video_folder():
    """The folder of WinUAE's video recordings (output.avi, output_1.avi, ...), from its settings."""
    import winreg
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r'Software\Arabuusimiehet\WinUAE\AVConfiguration') as k:
            return os.path.dirname(winreg.QueryValueEx(k, 'FileName')[0])
    except OSError:
        return os.path.join(os.environ.get('PUBLIC', 'C:/Users/Public'), 'Documents', 'Amiga Files', 'WinUAE')


def winuae_window(pid, timeout=20):
    user32 = ctypes.windll.user32
    found = []

    @ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)
    def callback(hwnd, _):
        p = ctypes.wintypes.DWORD()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(p))
        if p.value == pid and user32.IsWindowVisible(hwnd):
            found.append(hwnd)
        return True

    end = time.time() + timeout
    while time.time() < end:
        found.clear()
        user32.EnumWindows(callback, 0)
        if found:
            return found[0]
        time.sleep(0.25)
    raise SystemExit('the WinUAE window was not found')


class _KeyInput(ctypes.Structure):
    _fields_ = [('wVk', ctypes.c_ushort), ('wScan', ctypes.c_ushort), ('dwFlags', ctypes.c_ulong),
                ('time', ctypes.c_ulong), ('extra', ctypes.c_size_t)]


class _Input(ctypes.Structure):
    _fields_ = [('type', ctypes.c_ulong), ('ki', _KeyInput), ('pad', ctypes.c_ubyte * 8)]


def send_scancode(scan):
    """A key press (scan code: WinUAE reads raw input) to the window in the foreground."""
    for flags in (0x0008, 0x0008 | 0x0002):
        i = _Input(1, _KeyInput(0, scan, flags, 0, 0))
        ctypes.windll.user32.SendInput(1, ctypes.byref(i), ctypes.sizeof(i))
        time.sleep(0.1)


def winuae_start_recording(pid):
    """F11 (the recording) to the WinUAE window, until its video file appears; then the window is moved off the
    screen (still drawn, so recorded, but not in the way). Returns the window and the video file."""
    user32 = ctypes.windll.user32
    hwnd = winuae_window(pid)
    folder = winuae_video_folder()
    before = set(glob.glob(os.path.join(folder, '*.avi')))
    time.sleep(1.0)
    video = None
    for _ in range(3):
        # (the Alt key allows taking the foreground from another program)
        user32.keybd_event(0x12, 0, 0, 0)
        user32.SetForegroundWindow(hwnd)
        user32.keybd_event(0x12, 0, 2, 0)
        time.sleep(0.3)
        send_scancode(0x57)     # F11
        end = time.time() + 3
        while time.time() < end and not video:
            new = set(glob.glob(os.path.join(folder, '*.avi'))) - before
            video = max(new, key=os.path.getmtime) if new else None
            time.sleep(0.2)
        if video:
            break
    user32.SetWindowPos(hwnd, 0, -4000, 100, 0, 0, 0x0001 | 0x0004 | 0x0010)
    if not video:
        raise SystemExit('the WinUAE recording did not start (video codec and file set in its Output settings?)')
    return hwnd, video


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
    if args.emu == 'winuae':
        write_uae_config(args.fast_cpu, bool(args.record))
        emu = subprocess.Popen([WINUAE, '-f', UAE_CONFIG])
    else:
        emu = subprocess.Popen([FSUAE, CONFIG])
    recorder = None
    retry = False
    hwnd = avi = None
    try:
        target = None
        if args.record and args.emu == 'winuae':
            target = args.record if attempt == 0 else '%s_%d%s' % (os.path.splitext(args.record)[0], attempt,
                                                                    os.path.splitext(args.record)[1])
            hwnd, avi = winuae_start_recording(emu.pid)
        if args.emu == 'fsuae':
            x, y, w, h, title = window_rect(emu.pid)
            grab = ['-f', 'gdigrab', '-i', 'title=' + title]
        if args.record and args.emu == 'fsuae':
            target = args.record if attempt == 0 else '%s_%d%s' % (os.path.splitext(args.record)[0], attempt,
                                                                    os.path.splitext(args.record)[1])
            recorder = subprocess.Popen([ffmpeg(), '-y', '-loglevel', 'error', '-framerate', '50'] + grab +
                                        ['-t', str(args.seconds), '-c:v', 'libx264', '-preset', 'veryfast',
                                         '-pix_fmt', 'yuv420p', target], stdin=subprocess.PIPE)
        start = time.time()
        game_start = None
        shot = 0
        seen = {}                   # wall clock when the timer tags appeared in the log (for timer.py)
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
            if args.fail and expected(log, args.fail):
                print('attempt %d: failed (tag %s), restarting' % (attempt + 1, args.fail))
                retry = True
                break
            if args.record:
                for tag in ('30', args.success):
                    if tag and tag not in seen and tag_frame(log, tag) is not None:
                        seen[tag] = time.time()
            if args.success:
                if game_start is None and os.path.exists(log):
                    game_start = time.time()
                frame = tag_frame(log, args.success)
                if frame is not None:
                    seconds = frame / 50.0
                    print('attempt %d: complete after %d:%02d game time%s' % (
                        attempt + 1, seconds // 60, seconds % 60,
                        (' (video: %s)' % target) if args.record else ''))
                    time.sleep(args.tail)       # a little more (e.g. of the outro)
                    if args.record:
                        # the tags for the timer overlay (timer.py): the timer starts at the click on 'OK' in the
                        # character editor ($30) and stops when the outro begins (shortly after the success tag)
                        with open(os.path.splitext(target)[0] + '.json', 'w') as f:
                            json.dump({'start_tag': seen.get('30', 0) - start,
                                       'end_tag': seen.get(args.success, 0) - start}, f)
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
            else:
                # stop the recording now ('q': ffmpeg finishes the file properly), not after --seconds
                try:
                    recorder.communicate(b'q', timeout=30)
                except (subprocess.TimeoutExpired, OSError, ValueError):
                    recorder.terminate()
            recorder.wait()
        if hwnd:
            # WinUAE closes the video file properly when its window is closed
            ctypes.windll.user32.PostMessageW(hwnd, 0x0010, 0, 0)     # WM_CLOSE
            try:
                emu.wait(60)
            except subprocess.TimeoutExpired:
                pass
        emu.terminate()
        emu.wait()
        if avi:
            # the uncompressed recording of WinUAE -> mp4 (no sound), then away with it; WinUAE splits it into parts
            # of 2 GB (output_1.avi, output_1_1.avi, output_1_2.avi, ...): all of them, in order
            base = os.path.splitext(avi)[0]
            parts = [avi] + sorted(glob.glob(base + '_*.avi'),
                                   key=lambda f: int(re.search(r'_(\d+)\.avi$', f).group(1)))
            if not retry:
                concat = base + '_parts.txt'
                with open(concat, 'w') as f:
                    f.write(''.join("file '%s'\n" % part.replace('\\', '/') for part in parts))
                subprocess.run([ffmpeg(), '-y', '-loglevel', 'error', '-f', 'concat', '-safe', '0', '-i', concat,
                                '-an', '-c:v', 'libx264', '-preset', 'veryfast', '-pix_fmt', 'yuv420p', target],
                               check=True)
                os.remove(concat)
            for part in parts:
                os.remove(part)
    return retry


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('script')
    ap.add_argument('--record')
    ap.add_argument('--frames')
    ap.add_argument('--every', type=float, default=2.0)
    ap.add_argument('--seconds', type=float, default=60)
    ap.add_argument('--setup', action='store_true')
    ap.add_argument('--emu', choices=('winuae', 'fsuae'),
                    help='WinUAE (minimized or off the screen: no window in the way, records itself) or FS-UAE (a '
                         'window, recorded from the screen); default: FS-UAE with --frames, else WinUAE')
    ap.add_argument('--fast-cpu', action='store_true', help='CPU as fast as possible (not like a real A1200)')
    ap.add_argument('--release', default=None)
    ap.add_argument('--load', type=int, help='continue the game saved in this slot (1-10)')
    ap.add_argument('--start', help='the script starts at this label (with --load)')
    ap.add_argument('--expect', help='log tag (hex) that must appear within --within seconds, else restart')
    ap.add_argument('--within', type=float, default=45)
    ap.add_argument('--attempts', type=int, default=5)
    ap.add_argument('--tail', type=float, default=3, help='with --success: seconds to go on after the tag')
    ap.add_argument('--success', help='log tag (hex): the run is complete (e.g. the outro begins)')
    ap.add_argument('--define', action='append', default=[], help='script define (ifdef), e.g. TAR')
    ap.add_argument('--fail', help='log tag (hex): the run failed (e.g. a bad battle), restart')
    ap.add_argument('--limit', type=float, default=420, help='with --success: at most this many seconds of game time')
    ap.add_argument('--boot', default=os.path.join(DOCS, 'Hard Drives', 'AmbermoonDE'))
    args = ap.parse_args()

    if args.emu is None:
        args.emu = 'fsuae' if args.frames else 'winuae'
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
                   (['--start=' + args.start] if args.start else []) + ['--define=' + d for d in args.define],
                   check=True)
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
    write_uae_config(args.fast_cpu)

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
