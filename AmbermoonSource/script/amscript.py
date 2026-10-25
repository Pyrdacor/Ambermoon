"""Compiles a text script for the script player of AM2 (KERNEL/SCRIPT.S, script build) into Script.bin.

Usage: python amscript.py <script.txt> [<Script.bin>] [--data=<folder of unpacked map data>] [--start=<label>]

The script (one command per line, '#' starts a comment, 'name:' defines a label):

  wait <frames>                       wait (50 frames = 1 second)
  key <key> [<key> ...]               key presses, e.g. 'key up', 'key space', 'key shift+a', 'key kp5'
  type <text>                         key presses for a text (letters, digits, space)
  mouse <x> <y>                       the mouse pointer goes to x, y (screen pixels, 320x200)
  press [left|right|both]             hold mouse buttons
  release                             release the mouse buttons
  click <x> <y> [right]               move, press, release (with short waits)
  mousetile <dx> <dy>                 the mouse pointer goes to the tile dx, dy relative to the party (2D maps)
  clicktile <dx> <dy> [right]         click on that tile (e.g. after the hand icon)
  rclick [<x> <y>]                    right click (at the current scripted position if none is given)
  flyto <map> <x> <y>                 world map: straight line (diagonal first) to the square of a part
  castspell <nr>                      spell selection window: scrolls to the spell <nr> (of the class), clicks
  clickitem <item> [inv] [member <n>] click on the item (name with _ for spaces, or number) in the backpack of the
                                      active member (or member n): item area of chests / conversations / doors,
                                      'inv': the inventory; rclickitem: right click
  glide <x> <y> [through|via ..] [fight] 3D without turning (forward/back/sideways by the view direction)
  strafe left|right <x> <y>           3D: sideways without turning until the square x, y
  ready [<frames>]                    waits until the module stack did not change for <frames> (default 8)
  keyuntil <key> <var> <op> <value>   presses the key (again every 50 frames) until the condition is true
  gotopoint <x> <y>                   travels to the (known) goto point x, y of the map with the automap
  waitclick <depth> [<timeout>]       waits for a text that waits for a click (one level deeper than <depth>,
                                      at most <timeout> frames, default 150) and closes it
  talkto <slot>                       2D: walks to the map character <slot> (0-based, it may move) and talks
                                      to it (mouth), closes the greeting; continues in the conversation (depth 2)
  cil 1|2                             the control icons of the map: 1 movement, 2 eye, hand, mouth, ...
  savegame <slot>                     saves the game into slot 1-10 (run.py --load <slot> --start <label>
                                      continues it: a label right behind savegame)
  settle <frames>                     handles popups and battles (flee) until nothing happens for <frames>
  dismiss <depth>                     right clicks until the module stack depth is <depth> again (closes text
                                      windows: pages and the free scrolling at the end only react to clicks)
  rclickuntil <var> <op> <value>      right clicks until the condition is true (texts that wait for a click)
  free                                the real mouse is used again
  goto <label>
  if <var> <op> <value> goto <label>  op: = <> < >= > <=
  waituntil <var> <op> <value> [timeout <frames> goto <label>]
  set <reg> <value> / add <reg> <value>   registers r0-r7
  log <tag>                           a line in Amberfiles/Script.log (tag, frame, map, x, y, module, depth, r0, r1)
  onmap <map> <x> <y> [N|E|S|W]       waits for the map and position; walkto plans on this map from here (3D maps:
                                      with the facing, it is kept up to date by walkto and enter)
  walkto <x> <y> [through | via <chain> ...] [lane left] [nostop] [fight]
                                      ('fight': a battle ends the walk instead of a flight)
                                      (3D: 'lane left' walks on the left side of the squares, 'nostop' does not
                                      stop for monsters ahead)
                                      walks to x, y on the current map with the mouse (also diagonally: the left
                                      button is held next to the party in the direction of each straight piece of
                                      the path); tiles with events are avoided unless 'through' is given,
                                      the chain is listed after 'via' or it is the target. Needs the map data (--data).
  steerinto <x> <y>                   3D maps: walks onto the square until the position or the map changed
  enter <dir>                         one step with the mouse (up, downleft, ...) until the position or the map
                                      changed (e.g. onto a teleport)
  at <x> <y>                          waits for the position (after events that move the party)
  steppedback                         waits until the party is on the tile before the last step of walkto again
                                      (events like chests move the party back when they are closed)
  step <dir> [<n>]                    n steps up/down/left/right (also with the position check)
  end

Variables: map, x, y, module, depth (number of pushed modules), frame, mousex, mousey, travel, maptype,
members, active, r0-r7. Values are numbers or module names like Combat, Dialogue, C2Map, W2Map, M3Map, Inv1
(the module IDs of GAME_OFF.S).
"""
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GAME_OFF = os.path.join(HERE, '..', 'src', 'GAME_OFF.S')

OPS = {'end': 0, 'wait': 1, 'key': 2, 'mouse': 3, 'buttons': 4, 'free': 5, 'jumpif': 6, 'jump': 7, 'set': 8, 'add': 9,
       'log': 10, 'mousetile': 11, 'steer3d': 12, 'get': 13, 'jumpifv': 14, 'align3d': 15, 'steermouse': 16, 'save': 17,
       'mousenpc': 18, 'flow': 19, 'mouseauto': 20, 'mousespell': 21, 'worlddir': 22,
       'call': 23, 'ret': 24, 'mouseitem': 25, 'move3d': 26}
CMP = {'=': 0, '==': 0, '<>': 1, '!=': 1, '<': 2, '>=': 3, '>': 4, '<=': 5}
NEGATE = {0: 1, 1: 0, 2: 3, 3: 2, 4: 5, 5: 4}
VARS = {'map': 0, 'x': 1, 'y': 2, 'module': 3, 'depth': 4, 'frame': 5, 'mousex': 6, 'mousey': 7, 'travel': 8,
        'maptype': 9, 'members': 10, 'active': 11, 'mapbufx': 12, 'mapbufy': 13, 'view': 14, 'angle': 15, 'stable': 0x1e, 'cil': 0x1f, 'scroll': 0x40, 'alive1': 0x41, 'alive2': 0x42, 'alive3': 0x43, 'alive4': 0x44, 'alive5': 0x45,
        'alive6': 0x46, 'aliveactive': 0x47,
        'angle1024': 0x18, 'px': 0x19, 'py': 0x1a, 'mousemoving': 0x1b, 'monsterahead': 0x1c, 'mousetop': 0x1d}
VARS.update({'r%d' % i: 0x10 + i for i in range(8)})

# Amiga raw key codes
RAW = {'esc': 0x45, 'escape': 0x45, 'space': 0x40, 'return': 0x44, 'enter': 0x43, 'backspace': 0x41, 'tab': 0x42,
       'del': 0x46, 'help': 0x5f, 'up': 0x4c, 'down': 0x4d, 'right': 0x4e, 'left': 0x4f}
for i in range(10):
    RAW['f%d' % (i + 1)] = 0x50 + i
for i, c in enumerate('1234567890'):
    RAW[c] = 0x01 + i
for i, c in enumerate('qwertyuiop'):
    RAW[c] = 0x10 + i
for i, c in enumerate('asdfghjkl'):
    RAW[c] = 0x20 + i
for i, c in enumerate('zxcvbnm'):
    RAW[c] = 0x31 + i
# numeric keypad
KEYPAD = {'kp0': 0x0f, 'kp1': 0x1d, 'kp2': 0x1e, 'kp3': 0x1f, 'kp4': 0x2d, 'kp5': 0x2e, 'kp6': 0x2f, 'kp7': 0x3d,
          'kp8': 0x3e, 'kp9': 0x3f}
RAW.update(KEYPAD)
ASCII = {'space': 0x20, 'return': 0x0d, 'enter': 0x0d, 'backspace': 0x08, 'tab': 0x09, 'esc': 0x1b, 'escape': 0x1b,
         'del': 0x7f}
# the qualifier bits of the key events (see Run_input_handler)
QUAL = {'shift': 24, 'ctrl': 25, 'alt': 26, 'caps': 27, 'amiga': 28}


def module_ids():
    ids = {}
    lines = open(GAME_OFF, encoding='latin-1').read().split('\n')
    start = next(i for i, l in enumerate(lines) if 'These are the module IDs' in l)
    value = 0
    for l in lines[start + 2:]:
        m = re.match(r'(?:(\w+):)?\s+rs\.b\s+1', l)
        if not m:
            break
        if m.group(1):
            ids[m.group(1)[:-3]] = value
        value += 1
    return ids


MODULES = module_ids()


class ScriptError(Exception):
    pass


def key_code(name):
    parts = name.lower().split('+')
    key = parts[-1]
    code = 0
    for q in parts[:-1]:
        if q not in QUAL:
            raise ScriptError('unknown qualifier ' + q)
        code |= 1 << QUAL[q]
    if key in RAW:
        raw = RAW[key]
        if key in ASCII:
            asc = ASCII[key]
        elif len(key) == 1 and key not in KEYPAD:
            asc = ord(key.upper() if 'shift' in parts[:-1] else key)
        elif key in KEYPAD:
            asc = ord(key[2])
        else:
            asc = 0
    else:
        raise ScriptError('unknown key ' + name)
    return (raw << 16) | code | asc


def value(token):
    if token in MODULES:
        return MODULES[token]
    try:
        return int(token, 0) & 0xffff
    except ValueError:
        raise ScriptError('not a number or module name: ' + token)


def var(token):
    if token.lower() not in VARS:
        raise ScriptError('unknown variable ' + token)
    return VARS[token.lower()]


class Walker:
    """Plans paths on the 2D maps (map data of mapdump.py)."""

    def __init__(self, folder):
        self.folder = folder
        self.maps = {}
        self.map = None
        self.pos = None
        self.prev = None
        self.facing = 0     # 3D: 0 north, 1 east, 2 south, 3 west

    def load(self, number):
        if self.folder is None:
            raise ScriptError('walkto needs the map data (--data <folder>)')
        if number not in self.maps:
            sys.path.insert(0, HERE)
            import mapdump
            self.maps[number] = mapdump.load_map(self.folder, number)
        return self.maps[number]

    def path_3d(self, target, through, allowed=()):
        """3D: straight moves only, a turn costs like 2 squares. Returns a list of [facing, count]."""
        import heapq
        m = self.load(self.map)
        w, h = m['width'], m['height']
        if not m['walk'][target[1] - 1][target[0] - 1] and not through:
            raise ScriptError('walkto %d %d: the square is not walkable on map %d' % (target[0], target[1], self.map))

        def free(x, y):
            if not (1 <= x <= w and 1 <= y <= h):
                return False
            if (x, y) == target:
                return True
            if not m['walk'][y - 1][x - 1]:
                return False
            e = m['event'][y - 1][x - 1]
            return through or e == 0 or e in allowed

        vec = [(0, -1), (1, 0), (0, 1), (-1, 0)]
        start = (self.pos, self.facing)
        dist = {start: 0}
        prev = {start: None}
        heap = [(0, self.pos, self.facing)]
        goal = None
        while heap:
            d, p, f = heapq.heappop(heap)
            if d > dist[(p, f)]:
                continue
            if p == target:
                goal = (p, f)
                break
            for nf in range(4):
                turn = 0 if nf == f else (2 if (nf - f) % 4 in (1, 3) else 3)
                q = (p[0] + vec[nf][0], p[1] + vec[nf][1])
                if not free(*q):
                    continue
                nd = d + 1 + turn
                if nd < dist.get((q, nf), 1 << 30):
                    dist[(q, nf)] = nd
                    prev[(q, nf)] = (p, f)
                    heapq.heappush(heap, (nd, q, nf))
        if goal is None:
            raise ScriptError('no path from %s to %s on map %d' % (self.pos, target, self.map))
        dirs = []
        state = goal
        while prev[state]:
            dirs.append(state[1])
            state = prev[state]
        dirs.reverse()
        pieces = []
        for f in dirs:
            if pieces and pieces[-1][0] == f:
                pieces[-1][1] += 1
            else:
                pieces.append([f, 1])
        return pieces

    def flow(self, target, through, allowed=()):
        """2D: the direction table for FLOW: for each square the direction (1-8 = up, up right, right, ... up left)
        of the next step of a shortest way to the target, 0 at the target, 255 without a way. Diagonal steps cost the
        same as straight ones (one move each); straight ones are preferred."""
        from collections import deque
        m = self.load(self.map)
        w, h = m['width'], m['height']
        if not m['walk'][target[1] - 1][target[0] - 1] and not through:
            raise ScriptError('walkto %d %d: the square is not walkable on map %d' % (target[0], target[1], self.map))

        def free(x, y):
            if not (1 <= x <= w and 1 <= y <= h):
                return False
            if (x, y) == target:
                return True
            if not m['walk'][y - 1][x - 1]:
                return False
            e = m['event'][y - 1][x - 1]
            return through or e == 0 or e in allowed

        dist = {target: 0}
        queue = deque([target])
        while queue:
            q = queue.popleft()
            for dx, dy, _ in DIRECTIONS:
                p = (q[0] - dx, q[1] - dy)        # a step from p in direction (dx, dy) reaches q
                if p not in dist and free(*p):
                    dist[p] = dist[q] + 1
                    queue.append(p)
        table = []
        for y in range(1, h + 1):
            for x in range(1, w + 1):
                if (x, y) == target:
                    table.append(0)
                    continue
                best = None
                # also squares that are not free themselves (e.g. an event square the party stands on)
                for dx, dy, name in DIRECTIONS:
                    q = (x + dx, y + dy)
                    if q in dist and (best is None or dist[q] < best[0]):
                        best = (dist[q], FLOW_DIR[name])
                table.append(best[1] if best else 255)
        if self.pos and self.pos not in dist and table[(self.pos[1] - 1) * w + self.pos[0] - 1] == 255:
            raise ScriptError('no way from %s to %s on map %d' % (self.pos, target, self.map))
        return w, h, table

    def path(self, target, through, allowed=(), diagonal=True):
        from collections import deque
        if self.map is None or self.pos is None:
            raise ScriptError('walkto needs onmap before')
        m = self.load(self.map)
        w, h = m['width'], m['height']
        if not m['walk'][target[1] - 1][target[0] - 1] and not through:
            raise ScriptError('walkto %d %d: the square is not walkable on map %d' % (target[0], target[1], self.map))

        def free(x, y):
            if not (1 <= x <= w and 1 <= y <= h):
                return False
            if (x, y) == target:
                return True
            if not m['walk'][y - 1][x - 1]:
                return False
            e = m['event'][y - 1][x - 1]
            return through or e == 0 or e in allowed

        prev = {self.pos: None}
        queue = deque([self.pos])
        while queue:
            p = queue.popleft()
            if p == target:
                break
            for dx, dy, name in DIRECTIONS:
                if diagonal is False and dx and dy:
                    continue
                if dx and dy and m['type'] == 1 and not (free(p[0] + dx, p[1]) and free(p[0], p[1] + dy)):
                    continue    # 3D: no diagonal steps past corners
                q = (p[0] + dx, p[1] + dy)
                if q not in prev and free(*q):
                    prev[q] = (p, name)
                    queue.append(q)
        if target not in prev:
            raise ScriptError('no path from %s to %s on map %d' % (self.pos, target, self.map))
        steps = []
        p = target
        while prev[p]:
            p, name = prev[p][0], prev[p][1]
            steps.append(name)
        return list(reversed(steps))


DELTA = {'up': (0, -1), 'down': (0, 1), 'left': (-1, 0), 'right': (1, 0), 'upleft': (-1, -1), 'upright': (1, -1),
         'downleft': (-1, 1), 'downright': (1, 1)}
# straight directions first: with the same number of steps a straight path is preferred
FLOW_DIR = {'up': 1, 'upright': 2, 'right': 3, 'downright': 4, 'down': 5, 'downleft': 6, 'left': 7, 'upleft': 8}
DIRECTIONS = [(0, -1, 'up'), (0, 1, 'down'), (-1, 0, 'left'), (1, 0, 'right'), (-1, -1, 'upleft'), (1, -1, 'upright'),
              (-1, 1, 'downleft'), (1, 1, 'downright')]


ITEMS = {}


def item_number(token):
    # an item number or its name (with _ for spaces), from Objects.amb of the data folder
    if token.isdigit():
        return int(token)
    name = token.replace('_', ' ').upper()
    if name not in ITEMS:
        raise ScriptError('unknown item ' + token)
    return ITEMS[name]


def load_items(folder):
    import glob
    files = sorted(glob.glob(os.path.join(folder, 'Objects.amb', '*')))
    if not files:
        return
    d = open(files[0], 'rb').read()
    for n in range(1, (len(d) - 2) // 60 + 1):
        ITEMS.setdefault(d[2 + (n - 1) * 60 + 40:2 + (n - 1) * 60 + 59].split(b'\0')[0].decode('latin-1'), n)


def compile_script(text, data=None, start=None):
    code = []          # words; label references as ('label', name)
    labels = {}
    unique = [0]
    if start:
        # continue a saved game (savegame): the script starts at this label
        code.extend([OPS['jump'], ('label', start)])

    def emit(*words):
        code.extend(words)

    def new_label():
        unique[0] += 1
        return '__%d' % unique[0]

    def here(name):
        labels[name] = len(code)

    walker = Walker(data)
    if data:
        load_items(data)
    fight_exit = [None, None]
    handler_used = [False]

    def ready(frames=8):
        # every push/pop of a module clears the key and mouse buffers: inputs only after the module stack did not
        # change for a moment (e.g. a text window that opens a little after a conversation)
        loop = new_label()
        here(loop)
        emit(OPS['jumpif'], VARS['stable'], CMP['<'], frames, ('label', '__w' + loop))
        emit(OPS['jump'], ('label', '__d' + loop))
        here('__w' + loop)
        emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
        here('__d' + loop)

    def walk_flow(target, through, allowed):
        # 2D: walking with the mouse along a direction table (from any square: also after slides, events or
        # chasing a character)
        w, h, table = walker.flow(target, through, allowed)
        if walker.pos:
            try:
                steps = walker.path(target, through, allowed)
                if steps:
                    dx, dy = DELTA[steps[-1]]
                    walker.prev = (target[0] - dx, target[1] - dy)
            except ScriptError:
                pass
        data, skip = new_label(), new_label()
        emit(OPS['jump'], ('label', skip))
        here(data)
        nib = [min(v, 15) for v in table]       # 4 bits per square (255 = no way -> 15)
        nib += [15] * (-len(nib) % 4)
        emit(w, h, *[nib[i] << 12 | nib[i + 1] << 8 | nib[i + 2] << 4 | nib[i + 3] for i in range(0, len(nib), 4)])
        here(skip)
        loop, done, lost = new_label(), new_label(), new_label()
        here(loop)
        emit(OPS['flow'], ('label', data),
             OPS['jumpif'], VARS['r5'], CMP['='], 1, ('label', done),
             OPS['jumpif'], VARS['r5'], CMP['='], 2, ('label', lost))
        interrupt(loop, True)
        emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
        here(lost)
        emit(OPS['log'], 0x4c, OPS['buttons'], 0, OPS['wait'], 25, OPS['jump'], ('label', loop))
        here(done)
        emit(OPS['buttons'], 0)
        walker.pos = target

    def walk_mouse(steps):
        # the path in straight pieces; for each piece the mouse pointer is held next to the party in its direction
        # (recalculated each frame, the map scrolls) until the end of the piece is reached
        pieces = []
        for name in steps:
            if pieces and pieces[-1][0] == name:
                pieces[-1][1] += 1
            else:
                pieces.append([name, 1])
        for i, (name, count) in enumerate(pieces):
            dx, dy = DELTA[name]
            nx, ny = walker.pos[0] + dx * count, walker.pos[1] + dy * count
            walker.prev = (nx - dx, ny - dy)
            loop, done = new_label(), new_label()
            if i == 0:
                emit(OPS['mousetile'], dx & 0xffff, dy & 0xffff, OPS['wait'], 1, OPS['buttons'], 1)
            here(loop)
            emit(OPS['mousetile'], dx & 0xffff, dy & 0xffff,
                 OPS['jumpif'], VARS['x'], CMP['<>'], nx, ('label', '__w' + loop),
                 OPS['jumpif'], VARS['y'], CMP['='], ny, ('label', done))
            here('__w' + loop)
            interrupt(loop, True)
            emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
            here(done)
            walker.pos = (nx, ny)
        emit(OPS['buttons'], 0)

    def interrupt(resume, mouse, before_resume=None):
        # while walking: a popup or a battle (module stack deeper than 1) -> release the mouse and handle it, then
        # continue at resume. Popups: 'y' (answers requesters like "Do you want to fight?" with yes) and right
        # clicks. Battles: flee and start the round until the battle is over.
        # (on 3D maps walking with the mouse pushes the module Mousemove_3D_Mod: one level more)
        handler, cont, moving = new_label(), new_label(), new_label()
        if fight_exit[0]:
            # walkto / glide ... fight: a battle on the target square ends the walk (no flight); others: flight
            nf = new_label()
            fx, fy = fight_exit[1]
            emit(OPS['jumpif'], VARS['module'], CMP['<>'], MODULES['Combat'], ('label', nf),
                 OPS['jumpif'], VARS['x'], CMP['<>'], fx, ('label', nf),
                 OPS['jumpif'], VARS['y'], CMP['='], fy, ('label', fight_exit[0]))
            here(nf)
        emit(OPS['jumpif'], VARS['module'], CMP['='], MODULES['Combat'], ('label', handler),
             OPS['jumpif'], VARS['mousetop'], CMP['<>'], 0, ('label', cont),
             OPS['jumpif'], VARS['depth'], CMP['>'], 1, ('label', handler), OPS['jump'], ('label', cont))
        here(moving)
        here(handler)
        # the popup / battle handling itself is a subroutine (emitted once at the end, see handler_code)
        handler_used[0] = True
        emit(OPS['call'], ('label', '__handler'))
        done = new_label()
        here(done)
        emit(OPS['wait'], 10)
        if before_resume:
            before_resume()
        if mouse:
            emit(OPS['buttons'], 1)
        emit(OPS['jump'], ('label', resume))
        here(cont)

    # 3D: right click zones of the 3D view (32-175 x 49-192): top left/right = 90 degrees, bottom left = 180
    TURN_CLICK = {1: (152, 60), 3: (56, 60), 2: (56, 170)}
    ANGLE = {0: 0, 3: 256, 2: 512, 1: 768}     # facing -> angle (0 north, left turns increase the angle)
    VEC = [(0, -1), (1, 0), (0, 1), (-1, 0)]

    def handler_code():
        # subroutine: handle popups and battles until the module stack depth is 1 again
        here('__handler')
        emit(OPS['log'], 0xc1, OPS['buttons'], 0, OPS['wait'], 10)
        loop, done, combat = new_label(), new_label(), new_label()
        y = key_code('y')
        here(loop)
        emit(OPS['jumpif'], VARS['module'], CMP['='], MODULES['Combat'], ('label', combat),
             OPS['jumpif'], VARS['depth'], CMP['<='], 1, ('label', done))
        # "Select a new leader." (the active member died / fled): click on the first living member (only then: a
        # click on the portrait of the active member would open its inventory)
        pd = new_label()
        emit(OPS['jumpif'], VARS['aliveactive'], CMP['='], 1, ('label', pd))
        for n in range(1, 7):
            nx_ = new_label()
            emit(OPS['jumpif'], VARS['alive%d' % n], CMP['='], 0, ('label', nx_),
                 OPS['mouse'], 32 + 48 * (n - 1), 16, OPS['wait'], 2, OPS['buttons'], 1, OPS['wait'], 3,
                 OPS['buttons'], 0, OPS['wait'], 4, OPS['jump'], ('label', pd))
            here(nx_)
        here(pd)
        # 'y' (requesters like "Do you want to fight?"), then a right click only if still a popup and no battle
        emit(OPS['jumpif'], VARS['depth'], CMP['<='], 1, ('label', done),
             OPS['key'], y >> 16, y & 0xffff, OPS['wait'], 15,
             OPS['jumpif'], VARS['module'], CMP['='], MODULES['Combat'], ('label', combat),
             OPS['jumpif'], VARS['depth'], CMP['<='], 1, ('label', done),
             OPS['buttons'], 2, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 6, OPS['jump'], ('label', loop))
        here(combat)
        # flee at once: the clicks only after the module stack is stable for a moment (each push/pop clears the
        # buffers, then only the OK would arrive and a whole round would be fought)
        emit(OPS['jumpif'], VARS['stable'], CMP['>='], 15, ('label', '__f' + combat),
             OPS['wait'], 1, OPS['jump'], ('label', loop))
        here('__f' + combat)
        # every living member flees (each one for itself): key 1-6 selects the member, keypad 7 = flee, then
        # keypad 9 = OK (the round starts)
        # (the combat screen fades in without a module change: keys before that are lost)
        emit(OPS['log'], 0xc0, OPS['wait'], 40)
        k7, k9 = key_code('kp7'), key_code('kp9')
        for n in range(1, 7):
            skip = new_label()
            kn = key_code(str(n))
            # (the icon feedback of a key takes a moment: keys right after it are lost)
            emit(OPS['jumpif'], VARS['alive%d' % n], CMP['='], 0, ('label', skip))
            ready(10)
            emit(OPS['key'], kn >> 16, kn & 0xffff, OPS['wait'], 15)
            ready(10)
            emit(OPS['key'], k7 >> 16, k7 & 0xffff, OPS['wait'], 15)
            here(skip)
        ready(10)
        emit(OPS['key'], k9 >> 16, k9 & 0xffff, OPS['wait'], 50, OPS['jump'], ('label', loop))
        here(done)
        emit(OPS['ret'])

    def turn_3d(f):
        diff = (f - walker.facing) % 4
        if diff == 0:
            return
        x, y = TURN_CLICK[diff]
        loop, done = new_label(), new_label()
        emit(OPS['mouse'], x, y, OPS['wait'], 2, OPS['buttons'], 2, OPS['wait'], 3, OPS['buttons'], 0)
        here(loop)
        emit(OPS['jumpif'], VARS['angle1024'], CMP['='], ANGLE[f], ('label', done),
             OPS['wait'], 1, OPS['jump'], ('label', loop))
        here(done)
        walker.facing = f

    def realign_3d():
        # after a battle the party may face another direction: 90 degree clicks for big differences, then turn keys
        # (ALIGN3D) until the angle of the planned facing is reached again
        target = ANGLE[walker.facing]
        loop, done, right, left = new_label(), new_label(), new_label(), new_label()
        emit(OPS['buttons'], 0)
        here(loop)
        emit(OPS['align3d'], target, OPS['jumpif'], VARS['r5'], CMP['='], 1, ('label', done),
             OPS['jumpif'], VARS['r6'], CMP['>'], 160, ('label', right),
             OPS['jumpif'], VARS['r6'], CMP['<'], -160 & 0xffff, ('label', left),
             OPS['jump'], ('label', loop))
        here(right)
        x, y = TURN_CLICK[1]
        emit(OPS['mouse'], x, y, OPS['wait'], 2, OPS['buttons'], 2, OPS['wait'], 3, OPS['buttons'], 0, OPS['wait'], 40,
             OPS['jump'], ('label', loop))
        here(left)
        x, y = TURN_CLICK[3]
        emit(OPS['mouse'], x, y, OPS['wait'], 2, OPS['buttons'], 2, OPS['wait'], 3, OPS['buttons'], 0, OPS['wait'], 40,
             OPS['jump'], ('label', loop))
        here(done)
        emit(OPS['log'], 0xa1, OPS['mouse'], 104, 50, OPS['wait'], 2)

    def forward_3d(nx, ny, lane=0, stop=True):
        # Grid aligned: 1. align to the exact angle of the facing (90 degree right clicks for big differences, cursor
        # keys for small ones, only while the mouse movement module is not active), 2. hold the mouse at the top of
        # the middle zone (straight forward at full speed) until the middle of the square. Battles may turn the
        # party: then align again. A monster ahead (2 squares or less): stop and let it come (no turn by the battle).
        # r1 = last x, r4 = last y, r3 = frames without progress, r2 = frames waiting for a monster
        m = walker.load(walker.map)
        cx, cy = (nx - 1) * 512 + 256, (m['height'] - ny) * 512 + 256
        cond = {0: ('py', '>=', cy - 40), 2: ('py', '<=', cy + 40), 1: ('px', '>=', cx - 40),
                3: ('px', '<=', cx + 40)}[walker.facing]
        target = ANGLE[walker.facing]
        align, aligned, right, left, mm = new_label(), new_label(), new_label(), new_label(), new_label()
        loop, done, moved, stuck, monster, mwait, mgo, check = (new_label(), new_label(), new_label(), new_label(),
                                                                new_label(), new_label(), new_label(), new_label())
        after = new_label()
        # ---- align (not needed when the square is reached already, e.g. after a battle)
        here(align)
        emit(OPS['log'], 0xa0, OPS['buttons'], 0,
             OPS['jumpif'], VARS['x'], CMP['<>'], nx, ('label', '__n' + align),
             OPS['jumpif'], VARS['y'], CMP['='], ny, ('label', done))
        here('__n' + align)
        here(mm)
        emit(OPS['jumpif'], VARS['mousetop'], CMP['='], 0, ('label', '__a' + mm), OPS['wait'], 1,
             OPS['jump'], ('label', mm))
        here('__a' + mm)
        # popups first: the turn clicks would not close a requester
        interrupt(align, False)
        emit(OPS['align3d'], target, OPS['jumpif'], VARS['r5'], CMP['='], 1, ('label', aligned),
             OPS['jumpif'], VARS['r6'], CMP['>'], 160, ('label', right),
             OPS['jumpif'], VARS['r6'], CMP['<'], -160 & 0xffff, ('label', left),
             OPS['jump'], ('label', '__a' + mm))
        # 90 degree turns: right click, then wait until the turn animation is over (the angle does not change)
        settle = new_label()
        here(right)
        x, y = TURN_CLICK[1]
        emit(OPS['mouse'], x, y, OPS['wait'], 2, OPS['buttons'], 2, OPS['wait'], 3, OPS['buttons'], 0,
             OPS['jump'], ('label', settle))
        here(left)
        x, y = TURN_CLICK[3]
        emit(OPS['mouse'], x, y, OPS['wait'], 2, OPS['buttons'], 2, OPS['wait'], 3, OPS['buttons'], 0)
        here(settle)
        emit(OPS['wait'], 3)
        here('__s' + settle)
        emit(OPS['get'], 1, VARS['angle'], OPS['wait'], 3,
             OPS['jumpifv'], VARS['angle'], CMP['<>'], VARS['r1'], ('label', '__s' + settle),
             OPS['jump'], ('label', align))
        # ---- lane: strafe sideways (middle left/right zone) until the lateral offset is reached
        here(aligned)
        if lane:
            # left of the walking direction: N -> -x, E -> +y (dungeon y is up), S -> +x, W -> -y
            side = {0: ('px', '<=', cx - lane), 1: ('py', '>=', cy + lane), 2: ('px', '>=', cx + lane),
                    3: ('py', '<=', cy - lane)}[walker.facing]
            sl, sd = new_label(), new_label()
            emit(OPS['mouse'], 32, 120, OPS['wait'], 2, OPS['buttons'], 1, OPS['set'], 2, 0)
            here(sl)
            emit(OPS['jumpif'], VARS[side[0]], CMP[side[1]], side[2], ('label', sd),
                 OPS['add'], 2, 1, OPS['jumpif'], VARS['r2'], CMP['>='], 60, ('label', sd),
                 OPS['wait'], 1, OPS['jump'], ('label', sl))
            here(sd)
            emit(OPS['buttons'], 0, OPS['wait'], 2)
        # ---- forward
        emit(OPS['mouse'], 104, 50, OPS['wait'], 2, OPS['buttons'], 1,
             OPS['get'], 1, VARS['px'], OPS['get'], 4, VARS['py'], OPS['set'], 3, 0)
        here(loop)
        emit(OPS['jumpif'], VARS[cond[0]], CMP[cond[1]], cond[2], ('label', done))
        interrupt(after, False)
        emit(OPS['align3d'], target, OPS['jumpif'], VARS['r5'], CMP['='], 0, ('label', align))
        if stop:
            emit(OPS['jumpif'], VARS['monsterahead'], CMP['<='], 2, ('label', monster))
        emit(
             OPS['jumpifv'], VARS['px'], CMP['<>'], VARS['r1'], ('label', moved),
             OPS['jumpifv'], VARS['py'], CMP['<>'], VARS['r4'], ('label', moved),
             OPS['add'], 3, 1, OPS['jumpif'], VARS['r3'], CMP['>='], 50, ('label', stuck),
             OPS['wait'], 1, OPS['jump'], ('label', loop))
        here(moved)
        emit(OPS['get'], 1, VARS['px'], OPS['get'], 4, VARS['py'], OPS['set'], 3, 0, OPS['wait'], 1,
             OPS['jump'], ('label', loop))
        here(stuck)
        # no progress: a monster right ahead blocks the way -> the eye (second control icons, keypad 7) at it, which
        # starts the battle (then: flight); else wait a moment and align again
        eye, c2 = new_label(), new_label()
        emit(OPS['log'], 0x57, OPS['buttons'], 0,
             OPS['jumpif'], VARS['monsterahead'], CMP['<='], 1, ('label', eye),
             OPS['wait'], 25, OPS['jump'], ('label', align))
        here(eye)
        ke, k7 = key_code('enter'), key_code('kp7')
        emit(OPS['wait'], 5, OPS['jumpif'], VARS['cil'], CMP['='], 1, ('label', c2),
             OPS['key'], ke >> 16, ke & 0xffff, OPS['wait'], 10)
        here(c2)
        emit(OPS['key'], k7 >> 16, k7 & 0xffff, OPS['wait'], 30)
        interrupt(align, False)
        emit(OPS['jump'], ('label', align))
        # ---- monster ahead: wait for it
        here(monster)
        emit(OPS['log'], 0x4d, OPS['buttons'], 0, OPS['set'], 2, 0)
        here(mwait)
        emit(OPS['jumpif'], VARS['depth'], CMP['>'], 1, ('label', mgo),
             OPS['jumpif'], VARS['module'], CMP['='], MODULES['Combat'], ('label', mgo),
             OPS['jumpif'], VARS['monsterahead'], CMP['>'], 2, ('label', mgo),
             OPS['add'], 2, 1, OPS['jumpif'], VARS['r2'], CMP['>='], 250, ('label', check),
             OPS['wait'], 1, OPS['jump'], ('label', mwait))
        # ---- after a battle: forward at once (the monster waits a moment, then attacks again), if the party
        # faces roughly the right direction (45 degrees); aligning only after 100 frames or at the target
        here(after)
        emit(OPS['align3d'], target, OPS['jumpif'], VARS['r6'], CMP['>'], 128, ('label', align),
             OPS['jumpif'], VARS['r6'], CMP['<'], -128 & 0xffff, ('label', align),
             OPS['log'], 0xaf, OPS['jump'], ('label', check))
        here(mgo)
        yk = key_code('y')
        emit(OPS['jumpif'], VARS['module'], CMP['='], MODULES['Combat'], ('label', '__f' + mgo),
             OPS['key'], yk >> 16, yk & 0xffff, OPS['wait'], 10)      # "Do you want to fight?" -> yes
        here('__f' + mgo)
        interrupt('__f' + mgo, False)
        emit(OPS['jump'], ('label', align))
        # timeout while waiting: walk on without stopping for this monster for 100 frames
        here(check)
        emit(OPS['mouse'], 104, 50, OPS['wait'], 2, OPS['buttons'], 1, OPS['set'], 2, 0)
        here('__c' + check)
        emit(OPS['jumpif'], VARS[cond[0]], CMP[cond[1]], cond[2], ('label', done))
        interrupt(align, False)
        emit(OPS['add'], 2, 1, OPS['jumpif'], VARS['r2'], CMP['<'], 100, ('label', '__w' + check),
             OPS['jump'], ('label', aligned))
        here('__w' + check)
        emit(OPS['wait'], 1, OPS['jump'], ('label', '__c' + check))
        here(done)
        emit(OPS['buttons'], 0, OPS['log'], 0xd0)

    def walk_3d(pieces, lane=0, stop=True):
        for f, count in pieces:
            walker.facing = f
            nx, ny = walker.pos[0] + VEC[f][0] * count, walker.pos[1] + VEC[f][1] * count
            forward_3d(nx, ny, lane if count > 2 else 0, stop)
            walker.prev = (nx - VEC[f][0], ny - VEC[f][1])
            walker.pos = (nx, ny)

    def walk_steps(steps):
        # each step: press the key, wait until the position is the next one; repeat the key after 30 frames
        for name in steps:
            nx, ny = walker.pos[0] + DELTA[name][0], walker.pos[1] + DELTA[name][1]
            again, check, done = new_label(), new_label(), new_label()
            c = key_code(name)
            here(again)
            emit(OPS['key'], c >> 16, c & 0xffff, OPS['set'], 6, 0)
            here(check)
            emit(OPS['jumpif'], VARS['x'], CMP['<>'], nx, ('label', '__wait' + check),
                 OPS['jumpif'], VARS['y'], CMP['='], ny, ('label', done))
            here('__wait' + check)
            emit(OPS['add'], 6, 1, OPS['jumpif'], VARS['r6'], CMP['>='], 30, ('label', again),
                 OPS['wait'], 1, OPS['jump'], ('label', check))
            here(done)
            walker.pos = (nx, ny)

    lines_at = []
    for number, line in enumerate(text.split('\n'), 1):
        lines_at.append((len(code), number))
        line = line.split('#')[0].strip()
        if not line:
            continue
        try:
            if line.endswith(':') and ' ' not in line:
                here(line[:-1])
                continue
            t = line.split()
            cmd = t[0].lower()
            if cmd == 'wait':
                emit(OPS['wait'], int(t[1]))
            elif cmd == 'key':
                for k in t[1:]:
                    c = key_code(k)
                    ready()
                    emit(OPS['key'], c >> 16, c & 0xffff, OPS['wait'], 2)
            elif cmd == 'type':
                for ch in line[len(t[0]):].strip():
                    k = 'space' if ch == ' ' else ('shift+' + ch.lower() if ch.isupper() else ch)
                    c = key_code(k)
                    emit(OPS['key'], c >> 16, c & 0xffff, OPS['wait'], 2)
            elif cmd == 'mouse':
                emit(OPS['mouse'], int(t[1]), int(t[2]))
            elif cmd == 'press':
                which = t[1].lower() if len(t) > 1 else 'left'
                emit(OPS['buttons'], {'left': 1, 'right': 2, 'both': 3}[which])
            elif cmd == 'release':
                emit(OPS['buttons'], 0)
            elif cmd == 'click':
                mask = 2 if len(t) > 3 and t[3].lower() == 'right' else 1
                ready()
                emit(OPS['mouse'], int(t[1]), int(t[2]), OPS['wait'], 3, OPS['buttons'], mask, OPS['wait'], 4,
                     OPS['buttons'], 0, OPS['wait'], 4)
            elif cmd == 'mousetile':
                emit(OPS['mousetile'], int(t[1]) & 0xffff, int(t[2]) & 0xffff)
            elif cmd == 'clicktile':
                mask = 2 if len(t) > 3 and t[3].lower() == 'right' else 1
                emit(OPS['mousetile'], int(t[1]) & 0xffff, int(t[2]) & 0xffff, OPS['wait'], 3, OPS['buttons'], mask,
                     OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 4)
            elif cmd == 'rclick':
                ready()
                if len(t) > 2:
                    emit(OPS['mouse'], int(t[1]), int(t[2]), OPS['wait'], 3)
                emit(OPS['buttons'], 2, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 4)
            elif cmd == 'rclickuntil':
                loop, done = new_label(), new_label()
                here(loop)
                emit(OPS['jumpif'], var(t[1]), CMP[t[2]], value(t[3]), ('label', done),
                     OPS['buttons'], 2, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 12, OPS['jump'], ('label', loop))
                here(done)
            elif cmd == 'dismiss':
                loop, done = new_label(), new_label()
                here(loop)
                emit(OPS['jumpif'], VARS['depth'], CMP['<='], value(t[1]), ('label', done),
                     OPS['buttons'], 2, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 12, OPS['jump'], ('label', loop))
                here(done)
            elif cmd == 'cil':
                # the control icons of the map: 1 = movement, 2 = eye, hand, mouth, ... (keypad enter switches)
                # (keypad enter again every 50 frames: a key can get lost, e.g. right after loading)
                want = int(t[1]) - 1
                loop, skip = new_label(), new_label()
                here(loop)
                emit(OPS['jumpif'], VARS['cil'], CMP['='], want, ('label', skip))
                ready()
                k = key_code('enter')
                emit(OPS['key'], k >> 16, k & 0xffff, OPS['set'], 7, 0)
                here('__w' + loop)
                emit(OPS['jumpif'], VARS['cil'], CMP['='], want, ('label', skip),
                     OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['>='], 50, ('label', loop),
                     OPS['wait'], 1, OPS['jump'], ('label', '__w' + loop))
                here(skip)
                emit(OPS['wait'], 5)
            elif cmd == 'flyto':
                # flyto <map> <x> <y>: world map, straight line (diagonal first) to the square of a world map part
                # (16 x 16 parts of 50 x 50), e.g. with the eagle
                n, x, y = int(t[1]), int(t[2]), int(t[3])
                gx, gy = (n - 1) % 16 * 50 + x, (n - 1) // 16 * 50 + y
                loop, done = new_label(), new_label()
                here(loop)
                emit(OPS['worlddir'], gx, gy, OPS['jumpif'], VARS['r5'], CMP['='], 1, ('label', done))
                interrupt(loop, True)
                emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
                emit(OPS['buttons'], 0)
                walker.map, walker.pos = n, (x, y)
            elif cmd == 'castspell':
                # castspell <nr>: in the open spell selection window: scroll until the spell (number of the class)
                # is visible, click on it
                loop, found, fail, op = new_label(), new_label(), new_label(), new_label()
                # combat: open the spell window with the magic icon (bottom right) until it is really open
                emit(OPS['set'], 4, 0)
                here(op)
                emit(OPS['jumpif'], VARS['depth'], CMP['>='], 3, ('label', '__o' + op),
                     OPS['add'], 4, 1, OPS['jumpif'], VARS['r4'], CMP['>='], 6, ('label', fail))
                ready()
                k3 = key_code('kp3')       # magic
                emit(OPS['key'], k3 >> 16, k3 & 0xffff, OPS['wait'], 30, OPS['jump'], ('label', op))
                here('__o' + op)
                emit(OPS['log'], 0x5e)
                ready(15)
                emit(OPS['set'], 4, 0)
                here(loop)
                emit(OPS['mousespell'], int(t[1]), OPS['jumpif'], VARS['r5'], CMP['='], 1, ('label', found),
                     OPS['add'], 4, 1, OPS['jumpif'], VARS['r4'], CMP['>='], 8, ('label', fail))
                k = key_code('down')
                emit(OPS['key'], k >> 16, k & 0xffff, OPS['wait'], 8, OPS['jump'], ('label', loop))
                here(fail)
                emit(OPS['log'], 0x5f, OPS['end'])        # not found (window not open, or the spell is unknown)
                here(found)
                emit(OPS['wait'], 3, OPS['buttons'], 1, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 4)
            elif cmd in ('clickitem', 'rclickitem'):
                # clickitem <item name or number> [inv] [member <n>]: click on the item in the backpack of the active
                # member (or member n), in the item area (chests, conversations, doors) or the inventory ('inv')
                opts = [o.lower() for o in t[2:]]
                mode = (1 if 'inv' in opts else 0) | (int(opts[opts.index('member') + 1]) << 8 if 'member' in opts else 0)
                item = item_number(t[1])
                ready()
                loop, found = new_label(), new_label()
                emit(OPS['set'], 7, 0)
                here(loop)
                emit(OPS['mouseitem'], item, mode, OPS['jumpif'], VARS['r5'], CMP['='], 1, ('label', found),
                     OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['<'], 25, ('label', '__w' + loop),
                     OPS['log'], 0x1e1, OPS['end'])
                here('__w' + loop)
                emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(found)
                b = 2 if cmd == 'rclickitem' else 1
                emit(OPS['wait'], 3, OPS['buttons'], b, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 4)
            elif cmd == 'glide':
                # glide <x> <y> [through | via <chain> ...] [fight]: 3D without turning: each piece of the way is
                # walked forward, backward or sideways, depending on the current view direction (battles turn the
                # party: no problem). No progress for 60 frames (a monster blocks the way): the eye at it.
                opts = [o.lower() for o in t[3:]]
                through = 'through' in opts
                allowed = [int(o) for o in opts[opts.index('via') + 1:] if o.isdigit()] if 'via' in opts else []
                if 'fight' in opts:
                    fight_exit[0], fight_exit[1] = new_label(), (int(t[1]), int(t[2]))
                m = walker.load(walker.map)
                for f, count in walker.path_3d((int(t[1]), int(t[2])), through, allowed):
                    nx, ny = walker.pos[0] + VEC[f][0] * count, walker.pos[1] + VEC[f][1] * count
                    cx, cy = (nx - 1) * 512 + 256, (m['height'] - ny) * 512 + 256
                    cond = {0: ('py', '>=', cy - 40), 2: ('py', '<=', cy + 40), 1: ('px', '>=', cx - 40),
                            3: ('px', '<=', cx + 40)}[f]
                    loop, done, moved, eye, c2 = (new_label(), new_label(), new_label(), new_label(),
                                                  new_label())
                    emit(OPS['get'], 1, VARS['px'], OPS['get'], 4, VARS['py'], OPS['set'], 3, 0)
                    here(loop)
                    emit(OPS['jumpif'], VARS[cond[0]], CMP[cond[1]], cond[2] & 0xffff, ('label', done),
                         OPS['move3d'], f)
                    interrupt(loop, False)
                    emit(OPS['wait'], 1,
                         OPS['jumpifv'], VARS['px'], CMP['<>'], VARS['r1'], ('label', moved),
                         OPS['jumpifv'], VARS['py'], CMP['<>'], VARS['r4'], ('label', moved),
                         OPS['add'], 3, 1, OPS['jumpif'], VARS['r3'], CMP['<'], 60, ('label', loop))
                    # blocked: the eye (second control icons, keypad 7) at what is ahead
                    ke, k7 = key_code('enter'), key_code('kp7')
                    emit(OPS['log'], 0x57, OPS['buttons'], 0, OPS['wait'], 5, OPS['set'], 3, 0,
                         OPS['jumpif'], VARS['cil'], CMP['='], 1, ('label', c2),
                         OPS['key'], ke >> 16, ke & 0xffff, OPS['wait'], 10)
                    here(c2)
                    emit(OPS['key'], k7 >> 16, k7 & 0xffff, OPS['wait'], 30, OPS['jump'], ('label', loop))
                    here(moved)
                    emit(OPS['get'], 1, VARS['px'], OPS['get'], 4, VARS['py'], OPS['set'], 3, 0,
                         OPS['jump'], ('label', loop))
                    here(done)
                    walker.prev, walker.pos = walker.pos, (nx, ny)
                emit(OPS['buttons'], 0, OPS['log'], 0xd1)
                if fight_exit[0]:
                    here(fight_exit[0])
                    emit(OPS['buttons'], 0)
                    fight_exit[0] = None
            elif cmd == 'strafe':
                # strafe left|right <x> <y>: 3D, sideways (mouse held in the middle left / right zone of the 3D view)
                # without turning until the square x, y; after a battle (flight) at once on
                zone = (40, 120) if t[1].lower() == 'left' else (168, 120)
                tx, ty = int(t[2]), int(t[3])
                loop, done, start = new_label(), new_label(), new_label()
                here(start)
                realign_3d()        # (a battle turns the party towards the monster)
                emit(OPS['mouse'], zone[0], zone[1], OPS['wait'], 2, OPS['buttons'], 1)
                here(loop)
                emit(OPS['jumpif'], VARS['x'], CMP['<>'], tx, ('label', '__w' + loop),
                     OPS['jumpif'], VARS['y'], CMP['='], ty, ('label', done))
                here('__w' + loop)
                interrupt(start, False)
                emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
                emit(OPS['buttons'], 0, OPS['wait'], 2)
                walker.pos = (tx, ty)
            elif cmd == 'ready':
                ready(int(t[1]) if len(t) > 1 else 8)
            elif cmd == 'keyuntil':
                # keyuntil <key> <var> <op> <value>: key press, repeated every 50 frames until the condition is true
                # (a key can get lost, e.g. while the game is still busy after loading)
                c = key_code(t[1])
                loop, done = new_label(), new_label()
                here(loop)
                ready()
                emit(OPS['key'], c >> 16, c & 0xffff, OPS['set'], 7, 0)
                here('__w' + loop)
                emit(OPS['jumpif'], var(t[2]), CMP[t[3]], value(t[4]), ('label', done),
                     OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['>='], 50, ('label', loop),
                     OPS['wait'], 1, OPS['jump'], ('label', '__w' + loop))
                here(done)
            elif cmd == 'gotopoint':
                # travel to a known goto point of the map: automap (second control icons, keypad 1), click on the
                # point, "Are you sure?" -> yes. Attacks before: flee first.
                gx, gy = int(t[1]), int(t[2])
                skip, start = new_label(), new_label()
                here(start)
                ready()
                interrupt(start, False)
                emit(OPS['jumpif'], VARS['cil'], CMP['='], 1, ('label', skip))
                k = key_code('enter')
                emit(OPS['key'], k >> 16, k & 0xffff, OPS['wait'], 10)
                here(skip)
                k = key_code('kp1')
                emit(OPS['key'], k >> 16, k & 0xffff)
                wl = new_label()
                here(wl)
                emit(OPS['jumpif'], VARS['module'], CMP['<>'], MODULES['Automap'], ('label', '__w' + wl),
                     OPS['jump'], ('label', '__d' + wl))
                here('__w' + wl)
                emit(OPS['wait'], 1, OPS['jump'], ('label', wl))
                here('__d' + wl)
                ready(15)
                # scroll (cursor keys) until the point is visible
                sl, sv = new_label(), new_label()
                here(sl)
                emit(OPS['mouseauto'], gx, gy, OPS['jumpif'], VARS['r5'], CMP['='], 1, ('label', sv))
                for reg, neg, pos in (('r6', 'up', 'down'), ('r2', 'left', 'right')):
                    for cmpop, key in (('<', neg), ('>', pos)):
                        nk = new_label()
                        emit(OPS['jumpif'], VARS[reg], CMP['>=' if cmpop == '<' else '<='], 0, ('label', nk))
                        k = key_code(key)
                        emit(OPS['key'], k >> 16, k & 0xffff, OPS['wait'], 6)
                        here(nk)
                emit(OPS['jump'], ('label', sl))
                here(sv)
                emit(OPS['wait'], 3, OPS['buttons'], 1, OPS['wait'], 4, OPS['buttons'], 0)
                yl = new_label()
                emit(OPS['wait'], 10)
                here(yl)
                ready()
                k = key_code('y')
                emit(OPS['key'], k >> 16, k & 0xffff, OPS['wait'], 10,
                     OPS['jumpif'], VARS['module'], CMP['='], MODULES['Automap'], ('label', yl))
                walker.pos = (gx, gy)
            elif cmd == 'waitclick':
                # a text that waits for a click (module Wait_4_user: one level deeper): wait until it opens (at
                # most <timeout> frames, default 150), then right clicks until the depth is <depth> again
                d = int(t[1])
                limit = int(t[2]) if len(t) > 2 else 150
                gl, gc, gd = new_label(), new_label(), new_label()
                emit(OPS['set'], 7, 0)
                here(gl)
                emit(OPS['jumpif'], VARS['depth'], CMP['>'], d, ('label', gc),
                     OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['>='], limit, ('label', gd),
                     OPS['wait'], 1, OPS['jump'], ('label', gl))
                here(gc)
                emit(OPS['wait'], 5)
                here('__c' + gc)
                emit(OPS['jumpif'], VARS['depth'], CMP['<='], d, ('label', gd),
                     OPS['buttons'], 2, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 12,
                     OPS['jump'], ('label', '__c' + gc))
                here(gd)
            elif cmd == 'talkto':
                # 2D: talk to the map character in slot <n> (0-based): walk towards it until it is next to the
                # party (characters may walk around), then mouth and click on it
                slot = int(t[1])
                dv = 0x20 + slot
                # around obstacles: after 20 frames without a move the pointer goes 45 degrees left, then right of
                # the character (r2 = mode 0-2, r3 = frames without a move, r6 = moves in the mode, r1/r4 = x/y)
                loop, near, skip = new_label(), new_label(), new_label()
                m1, m2, go, moved, stuck = new_label(), new_label(), new_label(), new_label(), new_label()
                emit(OPS['set'], 2, 0, OPS['set'], 3, 0, OPS['set'], 6, 0,
                     OPS['get'], 1, VARS['x'], OPS['get'], 4, VARS['y'])
                here(loop)
                emit(OPS['jumpif'], dv, CMP['<='], 1, ('label', near),
                     OPS['jumpif'], VARS['r2'], CMP['='], 1, ('label', m1),
                     OPS['jumpif'], VARS['r2'], CMP['='], 2, ('label', m2),
                     OPS['mousenpc'], slot, OPS['jump'], ('label', go))
                here(m1)
                emit(OPS['mousenpc'], slot | 0x100, OPS['jump'], ('label', go))
                here(m2)
                emit(OPS['mousenpc'], slot | 0x200)
                here(go)
                emit(OPS['buttons'], 1)
                interrupt(loop, True)
                emit(OPS['wait'], 1,
                     OPS['jumpifv'], VARS['x'], CMP['<>'], VARS['r1'], ('label', moved),
                     OPS['jumpifv'], VARS['y'], CMP['<>'], VARS['r4'], ('label', moved),
                     OPS['add'], 3, 1, OPS['jumpif'], VARS['r3'], CMP['<'], 20, ('label', loop),
                     OPS['set'], 3, 0, OPS['set'], 6, 0, OPS['add'], 2, 1,
                     OPS['jumpif'], VARS['r2'], CMP['<='], 2, ('label', loop),
                     OPS['set'], 2, 0, OPS['jump'], ('label', loop))
                here(moved)
                emit(OPS['get'], 1, VARS['x'], OPS['get'], 4, VARS['y'], OPS['set'], 3, 0,
                     OPS['add'], 6, 1, OPS['jumpif'], VARS['r6'], CMP['<'], 3, ('label', loop),
                     OPS['set'], 2, 0, OPS['set'], 6, 0, OPS['jump'], ('label', loop))
                here(near)
                emit(OPS['buttons'], 0, OPS['wait'], 4,
                     OPS['jumpif'], VARS['cil'], CMP['='], 1, ('label', skip))
                k = key_code('enter')
                emit(OPS['key'], k >> 16, k & 0xffff, OPS['wait'], 10)
                here(skip)
                k = key_code('kp9')
                emit(OPS['key'], k >> 16, k & 0xffff, OPS['wait'], 10,
                     OPS['mousenpc'], slot, OPS['wait'], 2, OPS['buttons'], 1, OPS['wait'], 3, OPS['buttons'], 0,
                     OPS['set'], 7, 0)
                wl = new_label()
                here(wl)
                emit(OPS['jumpif'], VARS['depth'], CMP['>='], 2, ('label', '__d' + wl),
                     OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['>='], 40, ('label', loop),
                     OPS['wait'], 1, OPS['jump'], ('label', wl))
                here('__d' + wl)
                # the greeting: a text window that waits for a click, opened after the screen faded in; inputs
                # before it would only close it
                gl, gd, gc = new_label(), new_label(), new_label()
                emit(OPS['set'], 7, 0)
                here(gl)
                emit(OPS['jumpif'], VARS['depth'], CMP['>='], 3, ('label', gc),
                     OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['>='], 400, ('label', gd),
                     OPS['wait'], 1, OPS['jump'], ('label', gl))
                here(gc)
                emit(OPS['wait'], 5)
                here('__c' + gc)
                emit(OPS['jumpif'], VARS['depth'], CMP['<='], 2, ('label', gd),
                     OPS['buttons'], 2, OPS['wait'], 4, OPS['buttons'], 0, OPS['wait'], 12,
                     OPS['jump'], ('label', '__c' + gc))
                here(gd)
                ready(10)
                walker.pos = None
            elif cmd == 'savegame':
                emit(OPS['save'], int(t[1]))
            elif cmd == 'settle':
                # handle popups and battles until nothing happened for <n> frames
                start, loop, done = new_label(), new_label(), new_label()
                here(start)
                emit(OPS['set'], 7, 0)
                here(loop)
                interrupt(start, False)
                emit(OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['>='], int(t[1]), ('label', done),
                     OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
            elif cmd == 'free':
                emit(OPS['free'])
            elif cmd == 'goto':
                emit(OPS['jump'], ('label', t[1]))
            elif cmd == 'if':
                # if <var> <op> <value> goto <label>
                if len(t) != 6 or t[4].lower() != 'goto':
                    raise ScriptError('expected: if <var> <op> <value> goto <label>')
                emit(OPS['jumpif'], var(t[1]), CMP[t[2]], value(t[3]), ('label', t[5]))
            elif cmd == 'waituntil':
                # loop: if cond goto done; [timeout check]; wait 1; goto loop
                v, op, val = var(t[1]), CMP[t[2]], value(t[3])
                loop, done = new_label(), new_label()
                timeout = None
                if len(t) > 4:
                    if len(t) != 8 or t[4].lower() != 'timeout' or t[6].lower() != 'goto':
                        raise ScriptError('expected: waituntil <var> <op> <value> [timeout <frames> goto <label>]')
                    timeout = (int(t[5]), t[7])
                    emit(OPS['set'], 7, 0)  # r7 counts the frames
                here(loop)
                emit(OPS['jumpif'], v, op, val, ('label', done))
                if timeout:
                    emit(OPS['add'], 7, 1, OPS['jumpif'], VARS['r7'], CMP['>='], timeout[0], ('label', timeout[1]))
                emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
            elif cmd == 'set':
                emit(OPS['set'], var(t[1]) - 0x10, value(t[2]))
            elif cmd == 'add':
                emit(OPS['add'], var(t[1]) - 0x10, value(t[2]))
            elif cmd == 'log':
                emit(OPS['log'], value(t[1]))
            elif cmd == 'onmap':
                walker.map, walker.pos = int(t[1]), (int(t[2]), int(t[3]))
                if len(t) > 4:
                    walker.facing = 'NESW'.index(t[4].upper())
                loop, done = new_label(), new_label()
                here(loop)
                emit(OPS['jumpif'], VARS['map'], CMP['<>'], walker.map, ('label', '__w' + loop),
                     OPS['jumpif'], VARS['x'], CMP['<>'], walker.pos[0], ('label', '__w' + loop),
                     OPS['jumpif'], VARS['y'], CMP['='], walker.pos[1], ('label', done))
                here('__w' + loop)
                emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
            elif cmd == 'walkto':
                opts = [o.lower() for o in t[3:]]
                through = 'through' in opts
                allowed = []
                if 'via' in opts:
                    for o in opts[opts.index('via') + 1:]:
                        if not o.isdigit():
                            break
                        allowed.append(int(o))
                lane = {'left': 90, 'center': 0}.get(opts[opts.index('lane') + 1], 0) if 'lane' in opts else 0
                if 'fight' in opts:
                    fight_exit[0], fight_exit[1] = new_label(), (int(t[1]), int(t[2]))
                if walker.load(walker.map)['type'] == 1:
                    walk_3d(walker.path_3d((int(t[1]), int(t[2])), through, allowed), lane, 'nostop' not in opts)
                else:
                    walk_flow((int(t[1]), int(t[2])), through, allowed)
                if fight_exit[0]:
                    emit(OPS['buttons'], 0)
                    here(fight_exit[0])
                    emit(OPS['buttons'], 0)
                    fight_exit[0] = None
            elif cmd in ('at', 'steppedback'):
                walker.pos = (int(t[1]), int(t[2])) if cmd == 'at' else walker.prev
                loop, done = new_label(), new_label()
                here(loop)
                emit(OPS['jumpif'], VARS['x'], CMP['<>'], walker.pos[0], ('label', '__w' + loop),
                     OPS['jumpif'], VARS['y'], CMP['='], walker.pos[1], ('label', done))
                here('__w' + loop)
                emit(OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
            elif cmd == 'enter' and walker.map and walker.load(walker.map)['type'] == 1:
                # 3D: turn to the direction (n, e, s, w / up, right, down, left), forward until the square or the
                # map changes
                f = {'n': 0, 'up': 0, 'e': 1, 'right': 1, 's': 2, 'down': 2, 'w': 3, 'left': 3}[t[1].lower()]
                turn_3d(f)
                sx, sy = walker.pos
                loop, done = new_label(), new_label()
                emit(OPS['mouse'], 104, 50, OPS['wait'], 2, OPS['buttons'], 1)
                here(loop)
                emit(OPS['jumpif'], VARS['x'], CMP['<>'], sx, ('label', done),
                     OPS['jumpif'], VARS['y'], CMP['<>'], sy, ('label', done),
                     OPS['jumpif'], VARS['map'], CMP['<>'], walker.map, ('label', done),
                     OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
                emit(OPS['buttons'], 0)
                walker.prev = walker.pos
                walker.pos = (sx + VEC[f][0], sy + VEC[f][1])
            elif cmd == 'enter':
                # hold the mouse in the direction until the position or the map changes (teleports, doors)
                dx, dy = DELTA[t[1].lower()]
                sx, sy = walker.pos
                loop, done = new_label(), new_label()
                emit(OPS['mousetile'], dx & 0xffff, dy & 0xffff, OPS['wait'], 1, OPS['buttons'], 1)
                here(loop)
                emit(OPS['mousetile'], dx & 0xffff, dy & 0xffff,
                     OPS['jumpif'], VARS['x'], CMP['<>'], sx, ('label', done),
                     OPS['jumpif'], VARS['y'], CMP['<>'], sy, ('label', done),
                     OPS['jumpif'], VARS['map'], CMP['<>'], walker.map, ('label', done),
                     OPS['wait'], 1, OPS['jump'], ('label', loop))
                here(done)
                emit(OPS['buttons'], 0)
                walker.prev = walker.pos
                walker.pos = (sx + dx, sy + dy)
            elif cmd == 'steerinto':
                # 3D: steer to the square until the position or the map changes (events, teleports)
                tx, ty = int(t[1]), int(t[2])
                sx, sy = walker.pos
                loop, done = new_label(), new_label()
                here(loop)
                emit(OPS['steer3d'], tx, ty,
                     OPS['jumpif'], VARS['map'], CMP['<>'], walker.map, ('label', done),
                     OPS['jumpif'], VARS['x'], CMP['<>'], sx, ('label', done),
                     OPS['jumpif'], VARS['y'], CMP['<>'], sy, ('label', done),
                     OPS['jump'], ('label', loop))
                here(done)
                walker.prev = walker.pos
                walker.pos = (tx, ty)
            elif cmd == 'step':
                walk_steps([t[1].lower()] * (int(t[2]) if len(t) > 2 else 1))
            elif cmd == 'end':
                emit(OPS['end'])
            else:
                raise ScriptError('unknown command ' + cmd)
        except (ScriptError, IndexError, KeyError, ValueError) as e:
            raise ScriptError('line %d: %s (%s)' % (number, e, line))
    emit(OPS['end'])
    if handler_used[0]:
        handler_code()

    header = 6  # "AMSC" + version
    words = []
    for w in code:
        if isinstance(w, tuple):
            if w[1] not in labels:
                raise ScriptError('unknown label ' + w[1])
            w = header + 2 * labels[w[1]]
        words.append(w & 0xffff)
    if header + 2 * len(words) > 65536:
        raise ScriptError('the script is too large')
    compile_script.line_map = [(header + 2 * at, number) for at, number in lines_at]
    return b'AMSC' + struct.pack('>H', 1) + struct.pack('>%dH' % len(words), *words)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    start = next((a[8:] for a in sys.argv[1:] if a.startswith('--start=')), None)
    folder = next((a[7:] for a in sys.argv[1:] if a.startswith('--data=')), os.environ.get('AMSCRIPT_DATA'))
    source = args[0]
    target = args[1] if len(args) > 1 else os.path.splitext(source)[0] + '.bin'
    try:
        data = compile_script(open(source, encoding='utf-8').read(), folder, start)
    except ScriptError as e:
        print('error:', e)
        sys.exit(1)
    open(target, 'wb').write(data)
    # the position of each line in Script.bin (the log shows the script position)
    with open(os.path.splitext(target)[0] + '.map', 'w') as f:
        for offset, number in compile_script.line_map:
            f.write('%04x %d\n' % (offset, number))
    print('%s: %d bytes' % (target, len(data)))


if __name__ == '__main__':
    main()
