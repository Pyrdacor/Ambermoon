# AmbermoonMapEditor2D

An editor for the 2D maps of Ambermoon (indoor maps, towns, dungeons and the world maps): a port of
`AmbermoonTools/AmbermoonMapEditor2D` (WinForms) to CShift with `System.Ui` (CShift 0.34 or later). It runs on
Windows, Linux (X11) and the Amiga (AmigaOS 3.0 and later).

```
AmbermoonMapEditor2D [game data folder [map index]]
```

The game data is the folder with the files of the game (`Amberfiles` of an installation, or the extracted files).
The last folder is remembered (`.AmbermoonMapEditor2D.cfg` in the home folder, `%APPDATA%` on Windows).

## The window

- **Map** menu: open game data, open a map (a list of all 2D maps), a new map (index, indoor/world map/dungeon,
  world, size), save (into the game data), save the map data to a file of its own, quit.
- **Toolbar**: the tools (below). **Map view**: the map, zoom 1-4 (Ctrl+wheel, Ctrl++ / Ctrl+-, the slider).
  **Status line**: the tool, the layer, the selected tile and the tile under the mouse (position, index, back and front
  tile, event).
- **Tileset** (below the map): the tiles to paint with (the back layer can only use the first 256). A right click on
  a tile: edit the tile (graphic, animation frames, minimap color, flags, movement, draw mode, sit/sleep, combat
  background), copy it, paste a copied tile over it.
- **Side bar**: the layer to paint on (Tab switches), what is shown (back and front layer, grid, events, characters,
  animation, unused tiles, tiles that block walking, horses, rafts, ships, the disc or the eagle), the properties of
  the map (size, type, world, tileset, palette, music, NPC graphics, flags), its events (a click chooses an event for
  the event repeater), its monsters and NPCs (with "Place on map" for their position).

## Tools

| Tool | Left button | Right button |
|---|---|---|
| Brush (B) | paints the selected tile on the layer (also while dragging) | paints the other layer |
| Block 2x2, 3x2, 3x3 | the selected tile and the ones after it | the selected tile in every cell |
| Fill (F) | replaces the tile everywhere on the map | fills the connected area |
| Eraser (E) | removes the front tile | the same |
| Picker (P) | takes the tile of the layer and switches to the brush | takes the tile of the other layer |
| Event | chooses the event of the tile from the list of events | removes the event |
| Event repeater | gives the tile the last chosen event | removes the event |

Undo (Ctrl+Z) and redo (Ctrl+Y) cover all changes of the map (128 steps): tiles, events, size, properties and
positions of characters.

## Saving

Save (Ctrl+S) writes the map into `1Map_data.amb` (maps 1-256), `3Map_data.amb` (300-399) or `2Map_data.amb` (the
others), and the edited tilesets into `Icon_data.amb`. Only the changed subfiles are encoded again; all others keep
their bytes. For a new map the container of the map texts gets an (empty) file for it as well, because the game loads
the texts of every map it enters. The data of a map that was not changed is written byte for byte as it was read
(unused character references, which the reader drops, are taken from the original data).

## Different from the original

- Tileset changes are saved to `Icon_data.amb` (the original only exported them to a file).
- All changes can be undone, not only the painting; resizing changes the tiles of the map (the original changed only
  the initial tiles, see its source).
- The tool for character positions only sets the first position. The original embedded the character editor of
  AmbermoonMapCharEditor; it is not ported.
- No music is played (the original played the song of the map) and the tiles are drawn with the system font of
  `System.Ui`.
- There are no custom mouse pointers (a cross over the map).
- Closing the window does not ask about unsaved changes (Quit in the menu and Ctrl+Q do).

## Testing without a window

`AmbermoonMapEditor2D --screenshot out.png <game data> <map> [x y]` draws the window without showing it (1280 x 800,
with events and characters shown) and saves it as an image; with x and y the left button is clicked there.
