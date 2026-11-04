"""The changes of a generated source (intro_source.py) : the lines of the code offsets."""
import re


class Source:
    def __init__(self, path):
        self.L = open(path).read().split('\n')[2:]

    @staticmethod
    def off(line):
        return int(line.rsplit('; ', 1)[1], 16) if re.search(r'; [0-9a-f]{5}$', line) else None

    def index(self, a):
        for i, line in enumerate(self.L):
            if self.off(line) == a:
                return i
        raise SystemExit('no line at %x' % a)

    def replace(self, a, b, new):
        """The lines of the offsets a up to b (not including b) become new. The labels there stay."""
        L = self.L
        i, j = self.index(a), self.index(b)
        while L[j - 1].endswith(':'):       # (the labels of the line b stay in front of it)
            j -= 1
        keep = [line for line in L[i:j] if line.endswith(':')]
        L[i:j] = keep + ['\t' + x for x in new]

    def after(self, a, new):
        i = self.index(a)
        self.L[i + 1:i + 1] = ['\t' + x for x in new]

    def text(self):
        """The whole source : the custom chips and the CIA are memory, a blit starts with BLTSIZE."""
        text = '\n'.join(self.L)
        text = text.replace('$dff000.l', 'Intro_custom')
        text = re.sub(r'\$dff([0-9a-f]{3})\.l', lambda m: '(Intro_custom+$%s).l' % m.group(1), text)
        text = text.replace('$bfe001.l', '(Intro_ciaa).l')
        out = []
        for line in text.split('\n'):
            out.append(line)
            if re.search(r',\$58\(a6\)', line) or re.search(r'^\tmove\.w\td6,\(a5\)\t', line):
                out.append('\tjsr\tIntro_blit')
        return '\n'.join(out)
