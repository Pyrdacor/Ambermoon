# AmbermoonImageEditor

A paint program for the graphics of Ambermoon, in CShift with `System.Ui` (CShift 0.37 or later). It opens PNG and
BMP files and the palette graphics of the Amiga (bit planes with 1, 3, 4 or 5 bits per pixel), and it reads and writes
the palette files of the game. It is made for Windows and Linux (X11) and runs in the browser too (see below); it is
built for the Amiga too, but not made for it yet.

```
AmbermoonImageEditor [file]
```

## Files

- **Open** (Ctrl+O): a PNG or BMP file is opened at once. Any other file is read as an Amiga graphic, and a dialog asks
  for its format. After the start of the program it has 16 x 16 pixels, 5 bits per pixel, 1 frame and no preset;
  after that it keeps the values it was last used with.
  - **Format**: a preset of the game, or "None" to choose freely. A preset fixes what it knows: it shows
    those values and they cannot be changed.
  - **Width** and **height** (of one frame).
  - **Bits per pixel**: 1, 3, 4 or 5 (default 5).
  - **Frames** (default 1): graphics of the same size one after the other in the file; they are shown side by side,
    with a line between them.
  - **1 byte per row** (8 pixel slices): for 4 bits per pixel, and for 1 bit with a width up to 8.
  - **Palette offset** (default 0): which colors of the default palette the graphic uses: 0 or 16 for 4 bits per
    pixel, 0, 16 or 24 for 3 bits; fixed to 0 otherwise.

  The dialog says how many bytes the format needs and how many the file has, and shows a preview of the graphic in
  that format, so wrong values are seen at once. If the file is too short for the format, it shows why instead of the
  preview (and the graphic cannot be opened).
- **Files of the game**: a container (AMNC, AMNP, AMBR, AMPC, e.g. `2Wall3D.amb`) first asks which of its files to
  open (Up/Down choose, Enter opens). A single file that is encrypted or compressed (JH, LOB, e.g. `Object_icons`) is
  decoded. Then comes the format dialog. If the name of the file (or of the folder of an extracted file) belongs to a
  preset, that preset is chosen, with as many frames as the data holds; otherwise the dialog keeps its last values.

  | Name | Preset |
  |---|---|
  | `*Wall3D.amb`, `*Object3D.amb`, `*Overlay3D.amb` | wall, object, overlay texture |
  | `Floors.amb` | floor/ceiling |
  | `Object_icons` | item graphic |
  | `*Icon_gfx.amb` | tile graphic |
  | `Portraits.amb`, `Pics_80x80.amb`, `Monster_gfx.amb` | portrait, picture 80x80, monster |

- **Monsters**: `Monster_char.amb` lists the monsters by name. The chosen monster is opened with its graphic of
  `Monster_gfx.amb` (in the same folder), and a dialog asks for the palette (from `Palettes.amb` in the same folder). The
  monster data gives the rest:
  - 5 bits per pixel, and the width and height of a frame; the number of frames comes from the size of the graphic;
  - every color goes through the palette mapping of the monster;
  - each frame is scaled to the size the monster is shown with.

  The picture has no file of its own; Save asks where to save it.
- **New** (Ctrl+N): width, height and bits per pixel. A new picture is always an Amiga graphic; it has 1 << bpp colors
  (palette 1 of the game; black and white for 1 bit).
- **Save** (Ctrl+S) writes the file in the format it was opened or last saved in (a new picture, a file of a container
  or a monster asks where, like Save as). **Save as** (Ctrl+Shift+S) chooses
  PNG, BMP or Amiga graphic. Its default is the format the picture was opened in. For an Amiga graphic it has the same
  fields as the open dialog. The size comes from the picture: the frames divide its width. The dialog says what is
  wrong if the picture does not fit, e.g. colors above what the bits per pixel can store.

| Preset | Size | Bits per pixel |
|---|---|---|
| Wall texture (3D) | 128 x 80 | 4, 8 pixel slices |
| Object texture (3D), Overlay texture (3D) | free | 4, 8 pixel slices |
| Floor/ceiling (3D) | 64 x 64 | 4 |
| Item graphic, Tile graphic (2D) | 16 x 16 | 5 |
| NPC graphic (2D) | 16 x 32 | 5 |
| Portrait | 32 x 34 | 5 |
| Picture 80x80 | 80 x 80 | 5 |
| Monster (combat) | free | 5 |

The format of an Amiga graphic:
- A row is stored as a multiple of 8 pixels.
- Normally the planes of a row come one after the other: row 0 plane 0, row 0 plane 1, and so on.
- In 8 pixel slices, the planes come one after the other for each 8 pixels of a row. The 3D textures of Ambermoon are
  stored that way.

## Painting

The left mouse button paints with the left color and the right button with the right color.

| Tool | |
|---|---|
| Pencil (D) | pixels; dragging draws a line of pixels |
| Brush (B) | a square of 2x2 to 16x16 pixels (the size in the toolbar) |
| Fill (F) | fills the area of the color (connected horizontally and vertically), or with "Replace the color everywhere" every pixel of that color |
| Eraser (E) | makes pixels transparent (color 0 of an Amiga graphic), 1x1 to 16x16 (the size in the toolbar); dragging erases a line |
| Picker (I) | takes the color of a pixel |
| Select (S) | draws a rectangle; dragging inside it moves its pixels (their place becomes transparent) |

Other controls:
- Zoom 1x, 2x, 4x, 8x, 16x or 32x: the toolbar, the menu Image, Ctrl and the wheel, or the keys 1, 2, 4 and 8.
- G shows a grid from 4x zoom on.
- Undo (Ctrl+Z) and redo (Ctrl+Y) cover 64 steps.
- Closing the window asks about unsaved changes (in the browser the browser asks before the tab is closed).

## Editing

The menu Edit and the keys work with the selection of the Select tool:
- **Cut** (Ctrl+X), **Copy** (Ctrl+C): the selected pixels, or the current frame without a selection, go to the
  clipboard of the editor (it stays when another picture is opened).
- **Paste** (Ctrl+V): the clipboard floats above the picture at the selection (or at the top left) and is moved with
  the mouse. Enter, a click outside of it, another tool or Esc places it. Its colors are those of the picture:
  - the same palette keeps its color numbers;
  - other colors get the nearest color of the palette;
  - transparent pixels stay transparent.
- **Transparent** (in the toolbar with the Select tool): transparent pixels of a pasted or moved part leave the
  picture below as it is.
- **Delete** (Del) makes the selection transparent. **Select all** (Ctrl+A) selects the picture, or the frame that
  is shown. **Esc** places a floating part and selects nothing.

The menu Image changes the selection, or else each frame:
- **Mirror** left/right (H) and top/bottom (V).
- **Rotate** right (R) and left (Shift+R). Frames must be square for this; a selection can be any size.
- **Crop to the selection**.
- **Resize...**: the size of each frame, either with the pixels scaled, or with the canvas cut off or extended (new
  pixels transparent, the picture at the top left or in the middle).

Each of these is one undo step.

## Frames

Any picture can be divided into frames of the same width: the panel Frames chooses how many (the numbers that divide
the width). An Amiga graphic is opened and saved with its frames, and the save dialog starts with them.
- **<** and **>** (the keys , and .) choose the current frame.
- **Show only this frame**: only the current frame is shown and edited, and the tools cannot paint into the
  neighbouring frames.
- **Add** inserts an empty frame after the current one, **Copy** a copy of it, **Remove** removes it, and **Move <**
  and **>** move it.
- **Animation**: the frames one after the other in a preview. **Play** and **Pause**, the time of each frame (20 to
  1000 ms), and **Back and forth** (the frames forwards and then backwards, like the wave animation of the game).

## Colors and palettes

The side bar shows the palette of the picture:
- A click chooses the left color, a right click the right color.
- The sliders change the left color. Amiga graphics use 4 bits per channel (0 to 15), as the game stores them; other
  pictures use 8 bits and alpha.
- Changing a color changes every pixel that has it.

Color 0 of an Amiga graphic is transparent (it is shown over a checkerboard).

A PNG or BMP with up to 256 colors gets a palette of its colors, in the order they appear. With more colors there is
no palette ("Too many colors"), and the colors are ARGB.

**Image > Normalize colors** makes any picture an Amiga graphic of 1, 3, 4 or 5 bits per pixel:
1. Transparent pixels get color 0.
2. The other colors are reduced to 12 bits and to at most (1 << bpp) - 1 colors (median cut).
3. Every pixel gets the nearest of them.

Pictures that have few enough colors keep them exactly.

**Palette > Load palette / Save palette**: a palette file of the game has 32 colors of 16 bits (X4R4G4B4, big endian:
64 bytes). `Palettes.amb` (or another container of palettes) can be loaded too: a dialog shows its palettes with
their colors to choose one. The **palette offset** (in the side bar; default 0) is where the colors
of the picture are in those 32: 0 or 16 for an Amiga graphic of 4 bits per pixel, 0, 16 or 24 for 3 bits, else 0.
Loading takes the colors from the offset on (as many as the picture has); saving always writes 32 colors, those of the
picture from the offset on and black for the others.

## In the browser

`cshiftc publish Tools/AmbermoonImageEditor` makes one HTML page with the whole program (open it in a browser, also on
a phone: touch works like the mouse). The browser lets the program see only the files the user chooses:
- **Open** shows "Choose files...": the browser's file chooser, where several files can be chosen at once. The files a
  container needs must be chosen together with it: `Monster_char.amb` with `Monster_gfx.amb` and `Palettes.amb`. The
  picture is the chosen file that is not only such a neighbour.
- **Save as** asks only for a name, and the file is downloaded. Ctrl+S of a file that was opened in the browser does the
  same (the opened file is only a copy in the page).
- **Save palette** downloads the palette.

## Testing without a window

`AmbermoonImageEditor --screenshot out.png [file [width height bpp [frames [slices]]]]` draws the window without showing
it (1100 x 700) and saves it as an image. A file without a PNG or BMP header is read in the given format; the word
`slices` stands for 8 pixel slices.
