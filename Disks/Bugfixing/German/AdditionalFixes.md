## Fixes on top of the AMINET and Slothsoft patches

- Fixed Sansrie's key usage (map file 424 in 2Map_data.amb, changed word at offset 0x0346 from 0000 to 0165).
- Removed unused character data from map 258 (set the following bytes to 0: 0x4A to 0x51).
- Fixed golem that was flagged as partymember in temple of gala (map file 277 in 2Map_data.amb, change byte at 0x9A from 0 to 2).
- Fixed Reg hill giant boss flag
- Fixed two world maps (00D and 094) with wrong flags
- Fixed Gryban spawn location
- Fixed two corrupted wind gates