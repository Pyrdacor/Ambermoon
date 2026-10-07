# Executables

## AM2_CPU

**`AM2_CPU.s` should no longer be used.** It is the old disassembly of AM2_CPU 1.21 and is only kept
for reference.

The source code of AM2_CPU is now in [`AmbermoonSource`](../../../AmbermoonSource) (project root).
Fixes and changes should be made there.

To build `AM2_CPU`, run `compile.sh` in this folder. It assembles `AmbermoonSource/src/AMBERMOON.S`
with `vasmm68k_mot.exe` and writes (overwrites) `AM2_CPU` in this folder.
