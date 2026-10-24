# Atari ST colour test

`st_map_preview.py` checks how a 2D map of Ambermoon would look with 16 colours on the Atari ST/STE
(the Amiga version uses 32 colours).

It renders the map with its original palette, computes a 16 colour palette for it and maps every original
palette index to one of the 16 colours. Because the result is a lookup table 32 → 16, the tile graphics
keep their shape and only lose their 5th bitplane.

* The palette is computed with a weighted k-means in Lab colour space. By default each colour is weighted
  with the square root of its pixel count (`--weight sqrt`), so rare accent colours like fire and torches
  keep their own colour.
* `--bits 3` (default) rounds to the ST colour grid (3 bits per channel, 512 colours). `--bits 4` rounds to
  the STE grid (4096 colours, like the Amiga).
* `--reserve 0,24-31` keeps colours unchanged, for example the UI colours, which on the ST would have to be
  in the same 16 colours as the map, because the map window and the UI panel share the same lines.
* `--scope tileset` computes one palette for all maps with the same tileset and palette, as the tile
  graphics would be converted once per tileset in a real port.
* The third image adds a 4×4 Bayer dither for indices which have no good match. The pattern is aligned
  to the tiles, so it stays stable while scrolling.

```
python3 st_map_preview.py 257 --bits 4 --crop 4,4,16,12 -o map257_ste.png
```

The output is a PNG (original | 16 colours | 16 colours dithered, palettes below) and a report with the
new palette as ST/STE colour register values, the lookup table and the mean colour error. Needs Python 3
and Pillow. The game data is read from `ExtractedGameFiles.zip` in the repository root.

## Results

| Example | |
|---|---|
| `examples/map257_ste.png` | Map 257, STE: hardly any visible difference (mean error 1.5). |
| `examples/map257_ste_ui.png` | Map 257, STE, with colour 0 and the UI colours 24–31 reserved: still very close (2.7). |
| `examples/map257_st.png` | Map 257, ST: the 3 bit grid itself is the problem. Even with 32 colours the error is about 11. The warm grey stone walls become pinkish. |
| `examples/map287_ste.png` | Map 287, the worst 2D map (without the world maps) on the STE (5.4): still close to the original. |

Over all 101 2D maps without the world maps (tileset 1), the median error on the STE is 2.5.
