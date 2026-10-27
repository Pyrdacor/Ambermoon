"""Burns a run timer into a speedrun video (an overlay, not from the game).

Usage: python timer.py <video.mp4> [<video.json>] [--start <s>] [--end <s>]

The timer starts with the click on 'OK' in the character editor and stops when the outro begins (the machine room
is left). run.py --record writes <video>.json with the times (seconds of the video, about) when the log tags $30
(the click) and the success tag appeared; here they are found exactly in the frames:
- start: the requester "Are you happy?" pops up with the click (the brightness jumps up),
- end: the fade to black of the outro begins (the brightness drops).
--start / --end give the times directly (seconds of the video). The result replaces the video (the original is kept
as <video>_raw.mp4).
"""
import argparse
import json
import os
import re
import subprocess
import sys

import run

FONT = "'C\\:/Windows/Fonts/consola.ttf'"


def brightness(video, start, duration):
    """The average brightness (Y) of each frame from start on: [(time, y), ...]."""
    out = subprocess.run([run.ffmpeg(), '-hide_banner', '-ss', '%.2f' % max(0, start), '-i', video,
                          '-t', '%.2f' % duration, '-vf', 'signalstats,metadata=print:key=lavfi.signalstats.YAVG',
                          '-an', '-f', 'null', '-'], capture_output=True, text=True, errors='replace').stderr
    times = [float(t) for t in re.findall(r'pts_time:([\d.]+)', out)]
    values = [float(v) for v in re.findall(r'YAVG=([\d.]+)', out)]
    return [(max(0, start) + t, y) for t, y in zip(times, values)]


def find_start(video, near):
    """The click on 'OK': the first frame (from 3 s before the tag on) that is brighter by 5 or more than the
    character editor (brightness about 22; its fade-in starts darker)."""
    frames = brightness(video, near - 3, 6)
    for i in range(1, len(frames) - 10):
        (t0, y0), (t1, y1) = frames[i - 1], frames[i]
        # (the requester: within 10 frames to about 50; not the white flash at the boot)
        peak = max(y for _, y in frames[i:i + 10])
        if 19 < y0 < 35 and 5 <= y1 - y0 and y1 < 60 and 40 <= peak <= 70:
            return t1
    raise SystemExit('the click on OK was not found near %.2f s' % near)


def find_end(video, near):
    """The outro: the first frame (from 1 s before the tag on) where the fade to black begins (darker, and 3
    frames later below 60 percent; the fade takes several frames)."""
    frames = brightness(video, near - 1, 10)
    for i in range(1, len(frames) - 3):
        y0, y1, y3 = frames[i - 1][1], frames[i][1], frames[i + 3][1]
        if y0 > 20 and y1 < 0.95 * y0 and y3 < 0.6 * y0:
            return frames[i][0]
    raise SystemExit('the outro was not found near %.2f s' % near)


def clock(seconds):
    return '%d\\:%05.2f' % (seconds // 60, seconds % 60)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('video')
    ap.add_argument('json', nargs='?')
    ap.add_argument('--start', type=float)
    ap.add_argument('--end', type=float)
    args = ap.parse_args()
    tags = {}
    path = args.json or os.path.splitext(args.video)[0] + '.json'
    if os.path.exists(path):
        tags = json.load(open(path))
    start = args.start if args.start is not None else find_start(args.video, tags['start_tag'])
    end = args.end if args.end is not None else find_end(args.video, tags['end_tag'])
    total = end - start
    print('start %.2f s, end %.2f s: %d:%05.2f' % (start, end, total // 60, total % 60))
    # m:ss.cc while it runs (expressions: minutes, seconds, hundredths), the final time after the end
    box = ':fontfile=%s:fontsize=40:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=8:x=w-tw-20:y=20' % FONT
    running = ("drawtext=text='%%{eif\\:trunc((t-%.3f)/60)\\:d}\\:%%{eif\\:trunc(mod(t-%.3f\\,60))\\:d\\:2}"
               ".%%{eif\\:trunc(mod((t-%.3f)*100\\,100))\\:d\\:2}'%s:enable='between(t\\,%.3f\\,%.3f)'"
               % (start, start, start, box, start, end))
    before = "drawtext=text='0\\:00.00'%s:enable='lt(t\\,%.3f)'" % (box, start)
    after = "drawtext=text='%s'%s:enable='gt(t\\,%.3f)'" % (clock(total), box, end)
    script = os.path.splitext(args.video)[0] + '_timer.txt'
    with open(script, 'w') as f:
        f.write(','.join((before, running, after)))
    raw = os.path.splitext(args.video)[0] + '_raw.mp4'
    if not os.path.exists(raw):
        os.replace(args.video, raw)
    subprocess.run([run.ffmpeg(), '-y', '-hide_banner', '-loglevel', 'error', '-i', raw, '-/vf', script,
                    '-c:v', 'libx264', '-preset', 'veryfast', '-pix_fmt', 'yuv420p', args.video], check=True)
    os.remove(script)


if __name__ == '__main__':
    main()
