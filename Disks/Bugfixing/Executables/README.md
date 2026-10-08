# Executables

## AM2_CPU

**`AM2_CPU.s` should no longer be used.** It is the old disassembly of AM2_CPU 1.21 and is only kept
for reference.

The source code of AM2_CPU is now in [`AmbermoonSource`](../../../AmbermoonSource) (project root).
Fixes and changes should be made there.

To build `AM2_CPU`, run `compile.sh` in this folder. It assembles `AmbermoonSource/src/AMBERMOON.S`
with `vasmm68k_mot.exe` and writes (overwrites) `AM2_CPU` in this folder.

## Debug build

`compile_debug.sh` builds `AM2_CPU_DEBUG` (and the listing `AM2_CPU_DEBUG.lst`) with the symbol `DEBUG`
defined. On a plain 68000 this version shows the location of an address error (Guru 8000 0003) on the
diagnostic screen instead of the Guru: the offset in the code hunk, the accessed address, the PC and
the instruction word. Look the offset up in the listing. To test it, rename it to `AM2_CPU` on the
game disk / hard drive. Both files are ignored by git.
