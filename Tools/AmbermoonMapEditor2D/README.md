# AmbermoonMapEditor2D

An editor for the 2D maps of Ambermoon (indoor maps, towns, dungeons and the world maps): a port of
`AmbermoonTools/AmbermoonMapEditor2D` (WinForms), with the character editor of `AmbermoonMapCharEditor` that it
embedded, to CShift with `System.Ui` (CShift 0.36 or later). It is made for Windows and Linux (X11). It is built for
the Amiga too (AmigaOS 3.0 and later), but not made for it yet: the window is laid out for 1280 x 800, the images
take a lot of memory (an image of each tile set and palette in 32 bits), the colors are those of the Workbench screen
and a frame full of tiles takes about a second on an A1200.

```
AmbermoonMapEditor2D [game data folder [map index]]
```

The game data is the folder with the files of the game (`Amberfiles` of an installation, or the extracted files).
The last folder is remembered (`.AmbermoonMapEditor2D.cfg` in the home folder, `%APPDATA%` on Windows).

## The window

- **Map** menu: open game data, open a map (a list of all 2D maps), a new map (index, indoor/world map/dungeon,
  world, size), save (into the game data), save the map data to a file of its own, quit. Quitting, closing the window
  and opening another map ask first when there are unsaved changes.
- **Toolbar**: the tools (below). **Map view**: the map, zoom 1-4 (Ctrl+wheel, Ctrl++ / Ctrl+-, the slider).
  **Status line**: the tool, the layer, the selected tile and the tile under the mouse (position, index, back and front
  tile, event).
- **Tileset** (below the map): the tiles to paint with (the back layer can only use the first 256). A right click on
  a tile: edit the tile (graphic, animation frames, minimap color, flags, movement, draw mode, sit/sleep, combat
  background), copy it, paste a copied tile over it.
- **Side bar**: the layer to paint on (Tab switches), what is shown (back and front layer, grid, events, characters,
  animation, unused tiles, tiles that block walking, horses, rafts, ships, the disc or the eagle), the properties of
  the map (size, type, world, tileset, palette, music, NPC graphics, flags), its events (a click chooses an event for
  the event repeater) and its characters (below).

## Characters

The side bar lists the characters of the map (up to 32: party members, NPCs, monster groups and map objects) with
their names from the game data. **Add** makes a new NPC (the next click on the map places it), **Remove** removes the
selected one (the ones after it move up: the game stops at the first empty one), **Place on map** sets its position
with clicks on the map. For the selected character:

- the type and who it is: the party member, the NPC, the map text (an NPC with a short text), the monster group (named
  after its monsters, the boss first) or the event of a map object;
- random movement (monsters and map objects: chase the party), the graphic of the tileset instead of an NPC graphic,
  the short text of NPCs, the travel type it moves with;
- the graphic (with a preview: the NPC graphics of the map's NPC graphics file, or a tile of the tileset), the combat
  background of monsters, and its tile flags (how it is drawn, which travel types can pass it);
- its position. Monsters and characters with random movement have one; the others have a path with a position for
  every 5 minutes of the day (0, 0: not on the map at that time). **Time of day** chooses the time: the map shows all
  characters where they are then, and the path of the selected one as a line. A click with "Place on map" sets the
  position at that time and, if wanted, at all later times, so a path is made by placing the character at the times
  it moves.

The characters are drawn with their graphics (NPC graphics are 16x32 and stand on their tile) and a frame: red for
monsters, blue for NPCs, yellow for the others.

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
characters.

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
- The character editor is in the side bar instead of a window of its own, positions are set on the map (the original
  had a table of the 288 positions), and the flags of Ambermoon Advanced (stationary, move only when the player is
  seen) are not offered: the game of this repository does not know them (characters that have them keep them).
- No music is played (the original played the song of the map) and the tiles are drawn with the system font of
  `System.Ui`.
- There are no custom mouse pointers (a cross over the map).

## Testing without a window

`AmbermoonMapEditor2D --screenshot out.png <game data> <map> [x y]` draws the window without showing it (1280 x 800,
with events and characters shown) and saves it as an image; with x and y the left button is clicked there.
