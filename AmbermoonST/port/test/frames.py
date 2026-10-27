#!/usr/bin/env python3
"""Frames of a Hatari AVI recording (--avi-vcodec png, one frame per VBL).

    frames.py <avi> get <frame> <out.png>          one frame (negative : from the end)
    frames.py <avi> scan <step> [x1,y1,x2,y2]      mean brightness every <step> frames (finds changes)
    frames.py <avi> sheet <out.png> <f1,f2,...>    contact sheet (4 columns, 320x200 each)
"""
import io
import sys

from PIL import Image


def pngs(path):
    d = open(path, 'rb').read()
    sig = b'\x89PNG\r\n\x1a\n'
    starts = []
    i = d.find(sig)
    while i >= 0:
        starts.append(i)
        i = d.find(sig, i + 8)
    return d, starts


def frame(d, starts, n):
    s = starts[n]
    return Image.open(io.BytesIO(d[s:d.find(b'IEND', s) + 8])).convert('RGB')


def main():
    d, starts = pngs(sys.argv[1])
    cmd = sys.argv[2]
    if cmd == 'get':
        frame(d, starts, int(sys.argv[3])).save(sys.argv[4])
        print(len(starts), 'frames')
    elif cmd == 'scan':
        box = tuple(map(int, sys.argv[4].split(','))) if len(sys.argv) > 4 else None
        last = None
        for n in range(0, len(starts), int(sys.argv[3])):
            im = frame(d, starts, n).convert('L')
            if box:
                im = im.crop(box)
            b = sum(im.tobytes()) // (im.width * im.height)
            print(n, b, '*' if last is not None and abs(b - last) > 3 else '')
            last = b
    elif cmd == 'sheet':
        ims = [frame(d, starts, int(n)).resize((320, 200)) for n in sys.argv[4].split(',')]
        sh = Image.new('RGB', (320 * 4, 200 * ((len(ims) + 3) // 4)))
        for k, im in enumerate(ims):
            sh.paste(im, ((k % 4) * 320, (k // 4) * 200))
        sh.save(sys.argv[3])


if __name__ == '__main__':
    main()
