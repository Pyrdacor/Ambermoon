#!/usr/bin/env python3
# releasecreator.py <work folder> <language:version> ...: compares AmbermoonReleaseCreator with the original (built by
# FRAMEWORK=net9.0 build.sh AmbermoonReleaseCreator, against the sources of Amiga.FileFormats in which DateTime.Now
# reads SOURCE_DATE_EPOCH, see README.md) for each language: the exit codes, the console output (normalized: the
# temporary folder, the separators, the output of `dotnet publish`) and the six archives (the entries, their order and
# contents; the times are ignored, the ADF images inside are compared byte for byte). REF (default ~/ref) is the folder
# of setup.sh. The work folder gets two copies of the parts of the Ambermoon repository the release creator reads
# (ws_orig with the tool sources the original publishes, ws_port) and the ported tools (tools/, AMBERMOON_TOOLS).
# On Windows: NoDefaultCurrentDirectoryInExePath must not be set for the original (it starts the tools from its
# temporary folder), the script removes it.
import os, sys
REF = os.environ.get('REF', os.path.expanduser('~/ref'))
HERE = os.path.abspath(sys.argv[1])
os.makedirs(HERE, exist_ok=True)
CSHIFT_AMBERMOON = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
import shutil, subprocess, zipfile, tarfile, gzip, io, re

# --- the workspaces

REPO = os.path.join(REF, 'src', 'ambermoon')
CSHIFT = CSHIFT_AMBERMOON

def copy(src, dst):
    if os.path.isdir(src):
        shutil.copytree(src, dst, copy_function=shutil.copy2, dirs_exist_ok=True)
    else:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)

for ws in ('ws_orig', 'ws_port'):
    root = os.path.join(HERE, ws)
    shutil.rmtree(root, ignore_errors=True)
    for name in ('ambermoon_german_1.19_extracted.zip', 'ambermoon_german_1.20_extracted.zip'):
        copy(os.path.join(REPO, 'Disks', 'German', name), os.path.join(root, 'Disks', 'German', name))
    for part in ('German', 'English', 'Czech', 'Polish', 'French', 'Changelog'):
        copy(os.path.join(REPO, 'Disks', 'Bugfixing', part), os.path.join(root, 'Disks', 'Bugfixing', part))
    copy(os.path.join(REPO, 'Disks', 'BootDisk'), os.path.join(root, 'Disks', 'BootDisk'))
    for part in ('Czech', 'Polish', 'Ambermoon_intro_translation_base', 'Ambermoon_extro_translation_base'):
        copy(os.path.join(REPO, 'Translations', part), os.path.join(root, 'Translations', part))
    if ws == 'ws_orig':
        for part in ('AmbermoonTextManager', 'AmbermoonIntroPatcher', 'AmbermoonExtroPatcher', 'AmbermoonFontCreator',
                     'Ambermoon.Data.Text.Patching', 'Ambermoon.Data.Descriptions', 'NuGet.Config'):
            src = os.path.join(REPO, 'AmbermoonTools', part)
            if os.path.exists(src):
                copy(src, os.path.join(root, 'AmbermoonTools', part))
        for d in ('bin', 'obj'):
            for dirpath, dirnames, _ in os.walk(os.path.join(root, 'AmbermoonTools')):
                if d in dirnames:
                    shutil.rmtree(os.path.join(dirpath, d), ignore_errors=True)

tools = os.path.join(HERE, 'tools')
shutil.rmtree(tools, ignore_errors=True)
os.makedirs(tools)
for tool in ('AmbermoonTextManager', 'AmbermoonIntroPatcher', 'AmbermoonExtroPatcher', 'AmbermoonFontCreator'):
    shutil.copy2(os.path.join(CSHIFT, tool, 'bin', tool + ('.exe' if os.name == 'nt' else '')), tools)


# --- the comparison

ORIG = ['dotnet', os.path.join(REF, 'tools', 'AmbermoonReleaseCreator', 'out', 'AmbermoonReleaseCreator.dll')]
PORT = [os.path.join(CSHIFT_AMBERMOON, 'AmbermoonReleaseCreator', 'bin', 'AmbermoonReleaseCreator' + ('.exe' if os.name == 'nt' else ''))]
ENV = dict(os.environ, SOURCE_DATE_EPOCH=str(int(__import__('time').time())), AMBERMOON_TOOLS=os.path.join(HERE, 'tools'))
ENV = {k: v for k, v in ENV.items() if k.upper() != 'NODEFAULTCURRENTDIRECTORYINEXEPATH'}

def normalize(text, workspace):
    temp = re.search(r'Using temporary directory: (.*)', text)
    lines = []
    skip_publish = False
    for line in text.replace('\r', '').split('\n'):
        if temp:
            line = line.replace(temp.group(1).strip(), 'TEMP')
        line = line.replace('\\', '/').replace(workspace.replace('\\', '/'), 'WS')
        line = re.sub(r'C:/Users/[^ ]*/Temp/[0-9a-f-]{36}', 'TEMP', line)
        if line.startswith('Executing: dotnet publish'):
            skip_publish = True
            continue
        if skip_publish:
            if line.startswith('Executing:') or line.startswith('Copying') or line.startswith('Looking') or line.startswith('Reading'):
                skip_publish = False
            else:
                continue
        lines.append(line)
    return '\n'.join(lines)

def lha_entries(data):
    entries, pos = [], 0
    while pos < len(data):
        size = data[pos]
        if size == 0:
            break
        skip = int.from_bytes(data[pos + 7:pos + 11], 'little')
        header = bytearray(data[pos:pos + 2 + size])
        header[1] = 0                   # the checksum (it covers the time)
        header[15:19] = b'\0\0\0\0'     # the time
        ext_start = pos + 2 + size
        packed = int.from_bytes(data[pos + 7:pos + 11], 'little')
        # the skip size counts the extended headers and the data
        rest = data[ext_start:ext_start + skip]
        entries.append((bytes(header), rest))
        pos = ext_start + skip
    return entries

def archives(folder):
    result = {}
    if not os.path.isdir(folder):
        return result
    for name in sorted(os.listdir(folder)):
        path = os.path.join(folder, name)
        if not name.startswith('ambermoon_%s_%s_' % (language_now.lower(), version_now)):
            continue
        raw = open(path, 'rb').read()
        if name.endswith('.zip'):
            z = zipfile.ZipFile(path)
            result[name] = [(i.filename, i.compress_type, i.flag_bits, i.create_version, i.external_attr, i.CRC, i.file_size, z.read(i))
                            for i in z.infolist()]
        elif name.endswith('.tar.gz'):
            t = tarfile.open(fileobj=io.BytesIO(gzip.decompress(raw)))
            result[name] = [(m.name, m.mode, m.uid, m.gid, m.uname, m.gname, m.size, m.type, t.extractfile(m).read() if m.isfile() else b'')
                            for m in t.getmembers()]
        elif name.endswith('.lha'):
            result[name] = lha_entries(raw)
    return result

def run(prog, language, version, workspace):
    folder = os.path.join(workspace, 'Disks', language)
    if os.path.isdir(folder):
        for name in os.listdir(folder):
            if name.startswith('ambermoon_%s_%s_' % (language.lower(), version)):
                os.remove(os.path.join(folder, name))
    p = subprocess.run(prog + [language, version], capture_output=True, cwd=workspace, env=ENV)
    out = p.stdout.decode('utf-8', 'replace')
    err = p.stderr.decode('utf-8', 'replace')
    return p.returncode, normalize(out, workspace), normalize(err, workspace), archives(os.path.join(workspace, 'Disks', language))

for arg in sys.argv[2:]:
    language, version = arg.split(':')
    language_now, version_now = language, version
    o = run(ORIG, language, version, os.path.join(HERE, 'ws_orig'))
    p = run(PORT, language, version, os.path.join(HERE, 'ws_port'))
    open(os.path.join(HERE, 'out_%s_orig.txt' % language), 'w', encoding='utf-8').write(o[1] + '\n--- stderr\n' + o[2])
    open(os.path.join(HERE, 'out_%s_port.txt' % language), 'w', encoding='utf-8').write(p[1] + '\n--- stderr\n' + p[2])
    print('==', language, version, '| exit', o[0], p[0], '| stdout', 'same' if o[1] == p[1] else 'DIFFERENT',
          '| stderr', 'same' if o[2] == p[2] else 'DIFFERENT', '| archives', sorted(o[3]), sorted(p[3]) == sorted(o[3]))
    for name in sorted(set(o[3]) | set(p[3])):
        a, b = o[3].get(name), p[3].get(name)
        if a == b:
            print('   ', name, 'same', len(a), 'entries')
            continue
        if a is None or b is None:
            print('   ', name, 'only in', 'port' if a is None else 'original')
            continue
        print('   ', name, 'DIFFERENT', len(a), len(b), 'entries')
        names_a = [e[0] for e in a]
        names_b = [e[0] for e in b]
        if names_a != names_b:
            print('      only original:', [n for n in names_a if n not in names_b][:8])
            print('      only port:', [n for n in names_b if n not in names_a][:8])
        for x, y in zip(a, b):
            if x != y:
                print('      first difference:', [str(v)[:60] for v in x[:-1]], '|', [str(v)[:60] for v in y[:-1]], '| data same:', x[-1] == y[-1])
                break
