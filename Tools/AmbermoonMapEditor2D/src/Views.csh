// The map view and the tileset: drawn with the canvas of the ui into areas of scroll areas.

using System;
using System.Image;
using System.Ui;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

const double FrameSeconds = 0.166;

/// The graphic (0-based, in the atlas) of a tile of a tileset in the current animation frame; -1 for none.
int AnimatedGraphic(TilesetTile tile, int frame)
{
    if (tile.GraphicIndex == 0)
        return -1;
    int frames = Math.Max(1, tile.NumAnimationFrames);
    int f = 0;
    if (frames > 1)
    {
        if ((tile.Flags & TileFlags.WaveAnimation) != TileFlags.None)
        {
            int period = 2 * frames - 2;
            f = frame % period;
            if (f >= frames)
                f = period - f;
        }
        else
            f = frame % frames;
    }
    return (int)tile.GraphicIndex - 1 + f;
}

void DrawTile(Canvas canvas, Image atlas, Tileset tileset, uint32 index, int frame, Rect target)
{
    if (index == 0 || (int)index > tileset.Tiles.Length)
        return;
    int graphic = AnimatedGraphic(tileset.Tiles[(int)index - 1], frame);
    if (graphic < 0)
        return;
    int count = atlas.Width / TileSize * (atlas.Height / TileSize);
    if (graphic >= count)
    {
        // a graphic that does not exist: a white box with a red cross
        canvas.FillRect(target, Color.White());
        canvas.Line((double)target.X, (double)target.Y, (double)target.Right(), (double)target.Bottom(), 2.0, Color.FromRgb(220, 0, 0));
        canvas.Line((double)target.Right(), (double)target.Y, (double)target.X, (double)target.Bottom(), 2.0, Color.FromRgb(220, 0, 0));
        return;
    }
    canvas.DrawImage(atlas, GraphicRect(graphic), target);
}

int AnimationFrame(ref Editor editor)
{
    return editor.Animate ? (int)(editor.Time / FrameSeconds) : 0;
}

// the rectangle of a tile in an area of `columns` x `rows` tiles
Rect CellRect(Rect area, int columns, int rows, int x, int y)
{
    int x0 = area.X + (int)((int64)area.Width * x / columns);
    int x1 = area.X + (int)((int64)area.Width * (x + 1) / columns);
    int y0 = area.Y + (int)((int64)area.Height * y / rows);
    int y1 = area.Y + (int)((int64)area.Height * (y + 1) / rows);
    return Rect.Create(x0, y0, x1 - x0, y1 - y0);
}

/// The map: painting with the tools (left and right button), the hovered tile, the layers and overlays.
void DrawMapView(Ui ui, ref Editor editor, int height)
{
    var map = editor.Map;
    int tileSize = TileSize * editor.Zoom;
    using (ui.ScrollArea("map", 0, height))
    {
        var area = ui.Area("mapview", map.Width * tileSize, map.Height * tileSize);
        var input = ui.Input();
        bool hovered = ui.Hovered();
        bool held = ui.Held();
        bool rightHeld = ui.RightHeld();
        bool clicked = ui.Clicked();
        bool rightClicked = ui.RightClicked();

        // the tile under the mouse
        editor.HoverX = -1;
        editor.HoverY = -1;
        if (hovered || held || rightHeld || clicked || rightClicked)
        {
            int tx = (int)((int64)(input.MouseX - area.X) * map.Width / Math.Max(1, area.Width));
            int ty = (int)((int64)(input.MouseY - area.Y) * map.Height / Math.Max(1, area.Height));
            if (input.MouseX >= area.X && input.MouseY >= area.Y && editor.InMap(tx, ty))
            {
                editor.HoverX = tx;
                editor.HoverY = ty;
            }
        }
        if (hovered)
            ui.SetCursor(Cursor.Crosshair);

        // zoom with Ctrl and the wheel
        if (hovered && input.Ctrl && input.Wheel != 0)
            editor.Zoom = Math.Max(1, Math.Min(4, editor.Zoom + (input.Wheel > 0 ? 1 : -1)));

        _UseTool(ui, ref editor, input, held, rightHeld, clicked, rightClicked);
        _RenderMap(ui, ref editor, area);
    }
}

void _UseTool(Ui ui, ref Editor editor, UiInput input, bool held, bool rightHeld, bool clicked, bool rightClicked)
{
    int x = editor.HoverX;
    int y = editor.HoverY;
    // a press, also one that is released in the same frame (a quick click while frames are slow)
    bool left = input.MousePressed && (held || clicked);
    bool right = input.RightPressed && (rightHeld || rightClicked);
    bool pressed = left || right;
    switch (editor.Tool)
    {
        case Tool.Brush:
        case Tool.Blocks2x2:
        case Tool.Blocks3x2:
        case Tool.Blocks3x3:
        case Tool.Eraser:
        case Tool.EventRepeater:
            if (pressed && x >= 0)
            {
                editor.BeginChange();
                editor.Painting = true;
                editor.Paint(x, y, right && !left);
            }
            else if (editor.Painting && (held || rightHeld) && x >= 0)
                editor.Paint(x, y, rightHeld && !held);
            if (!held && !rightHeld)
                editor.Painting = false;
            break;
        case Tool.Fill:
            if ((clicked || rightClicked) && x >= 0)
            {
                editor.BeginChange();
                editor.Fill(x, y, rightClicked);
            }
            break;
        case Tool.ColorPicker:
            if ((clicked || rightClicked) && x >= 0)
                editor.Pick(x, y, rightClicked);
            break;
        case Tool.EventChanger:
            if (clicked && x >= 0)
            {
                editor.EventTileX = x;
                editor.EventTileY = y;
                editor.DialogSelection = (int)editor.Map.Tiles[x + y * editor.Map.Width].MapEventId;
                editor.ShowEventSelect = true;
            }
            if (rightClicked && x >= 0)
            {
                editor.BeginChange();
                editor.SetEvent(x, y, 0);
            }
            break;
        case Tool.PositionPicker:
            if (clicked && x >= 0)
                PlaceCharacter(ref editor, x, y);
            break;
        default:
            break;
    }
}

void _RenderMap(Ui ui, ref Editor editor, Rect area)
{
    var canvas = ui.Canvas();
    var map = editor.Map;
    var tileset = editor.CurrentTileset();
    var atlas = editor.Graphics.Atlas(map.TilesetOrLabdataIndex, map.PaletteIndex);
    int frame = AnimationFrame(ref editor);
    var font = ui.Font();
    var clip = canvas.Clip.Intersect(area);
    if (clip.IsEmpty())
        return;
    canvas.FillRect(clip, Color.Black());

    int x0 = Math.Max(0, (int)((int64)(clip.X - area.X) * map.Width / area.Width));
    int y0 = Math.Max(0, (int)((int64)(clip.Y - area.Y) * map.Height / area.Height));
    int x1 = Math.Min(map.Width - 1, (int)((int64)(clip.Right() - area.X) * map.Width / area.Width));
    int y1 = Math.Min(map.Height - 1, (int)((int64)(clip.Bottom() - area.Y) * map.Height / area.Height));

    bool anyCollision = false;
    foreach (var show in editor.ShowCollision)
        anyCollision = anyCollision || show;
    var collisionColor = Color.FromArgb(0x80, 0x20, 0xff, 0x40);
    var gridColor = Color.FromArgb(0x80, 0, 0, 0);

    for (var y = y0; y <= y1; y += 1)
    {
        for (var x = x0; x <= x1; x += 1)
        {
            var cell = CellRect(area, map.Width, map.Height, x, y);
            var tile = map.Tiles[x + y * map.Width];
            if (editor.ShowBack)
                DrawTile(canvas, atlas, tileset, tile.BackTileIndex, frame, cell);
            if (editor.ShowFront)
                DrawTile(canvas, atlas, tileset, tile.FrontTileIndex, frame, cell);
            if (anyCollision)
            {
                bool blocked = false;
                for (var t = 0; t < editor.ShowCollision.Length && !blocked; t += 1)
                {
                    if (editor.ShowCollision[t] && editor.Blocks(x, y, (TravelType)(uint8)t))
                        blocked = true;
                }
                if (blocked)
                    canvas.FillRect(cell, collisionColor);
            }
            if (editor.ShowGrid)
                canvas.StrokeRect(cell, 1, gridColor);
            if (editor.ShowEvents && tile.MapEventId != 0)
            {
                string text = $"{tile.MapEventId:X2}";
                int w = font.Measure(text) + 4;
                int h = font.LineHeight() + 2;
                var box = Rect.Create(cell.X + (cell.Width - w) / 2, cell.Y + (cell.Height - h) / 2, w, h);
                canvas.FillRect(box, Color.FromArgb(0xa0, 0, 0, 0));
                canvas.Text(font, box.X + 2, box.Y + 1, text, Color.White());
            }
        }
    }

    // the characters where they are at the time of day, and the path of the selected one
    if (editor.ShowCharacters)
    {
        if (editor.SelectedCharacter >= 0 && map.CharacterReferences[editor.SelectedCharacter] is CharacterReference selected)
            _DrawPath(canvas, area, map, selected);
        var npcAtlas = editor.Graphics.NPCAtlas(map.NPCGfxIndex, map.PaletteIndex);
        int npcGraphics = editor.Graphics.NPCGraphicCount(map.NPCGfxIndex);
        for (var i = 0; i < map.CharacterReferences.Length; i += 1)
        {
            if (map.CharacterReferences[i] is not CharacterReference reference)
                continue;
            int at = PositionIndex(reference, editor.PathStep);
            if (at >= reference.Positions.Count())
                continue;
            var position = reference.Positions[at];
            if (position.X < 1 || position.Y < 1 || position.X > map.Width || position.Y > map.Height)
                continue;
            var cell = CellRect(area, map.Width, map.Height, position.X - 1, position.Y - 1);
            // the graphic: a tile of the tileset, or an NPC graphic (16x32, standing on the tile)
            if (HasFlag(reference, CharacterReferenceFlags.UseTileset))
                DrawTile(canvas, atlas, tileset, reference.GraphicIndex, frame, cell);
            else if ((int)reference.GraphicIndex < npcGraphics)
                canvas.DrawImage(npcAtlas, NPCGraphicRect((int)reference.GraphicIndex), Rect.Create(cell.X, cell.Y - cell.Height, cell.Width, 2 * cell.Height));
            var color = reference.Type == CharacterType.Monster ? Color.FromRgb(230, 40, 40)
                      : reference.Type == CharacterType.NPC ? Color.FromRgb(60, 140, 255) : Color.FromRgb(240, 200, 40);
            canvas.StrokeRect(cell, i == editor.SelectedCharacter ? 3 : 2, color);
            canvas.Text(font, cell.X + 2, cell.Y + 1, (i + 1).ToString(), color);
        }
    }

    // the tiles the tool would change
    if (editor.HoverX >= 0 && editor.FootprintWidth() > 0)
    {
        var first = CellRect(area, map.Width, map.Height, editor.HoverX, editor.HoverY);
        int w = Math.Min(editor.FootprintWidth(), map.Width - editor.HoverX);
        int h = Math.Min(editor.FootprintHeight(), map.Height - editor.HoverY);
        var last = CellRect(area, map.Width, map.Height, editor.HoverX + w - 1, editor.HoverY + h - 1);
        var marker = Rect.Create(first.X, first.Y, last.Right() - first.X, last.Bottom() - first.Y);
        canvas.FillRect(marker, Color.FromArgb(0x50, 0x40, 0xff, 0x40));
        canvas.StrokeRect(marker, 2, Color.FromRgb(255, 230, 0));
    }
}

// the path of a character over the day: a line from position to position (positions 0, 0 are left out)
void _DrawPath(Canvas canvas, Rect area, Map map, CharacterReference reference)
{
    int count = Math.Min(PositionCount(reference), reference.Positions.Count());
    if (count < 2)
        return;
    var color = Color.FromArgb(0xc0, 0xff, 0xff, 0xff);
    bool hasLast = false;
    var last = Rect.Create(0, 0, 0, 0);
    for (var i = 0; i < count; i += 1)
    {
        var position = reference.Positions[i];
        if (position.X < 1 || position.Y < 1 || position.X > map.Width || position.Y > map.Height)
        {
            hasLast = false;
            continue;
        }
        var cell = CellRect(area, map.Width, map.Height, position.X - 1, position.Y - 1);
        int size = Math.Max(2, cell.Width / 6);
        canvas.FillRect(Rect.Create(cell.X + (cell.Width - size) / 2, cell.Y + (cell.Height - size) / 2, size, size), color);
        if (hasLast && (last.X != cell.X || last.Y != cell.Y))
        {
            canvas.Line((double)(last.X + last.Width / 2), (double)(last.Y + last.Height / 2),
                        (double)(cell.X + cell.Width / 2), (double)(cell.Y + cell.Height / 2), 2.0, color);
        }
        last = cell;
        hasLast = true;
    }
}

/// The tiles of the tileset to choose from (the back layer can only use the first 256 tiles).
void DrawTilesetView(Ui ui, ref Editor editor, int columns)
{
    var tileset = editor.CurrentTileset();
    int count = editor.Layer == Layer.Back ? Math.Min(256, tileset.Tiles.Length) : tileset.Tiles.Length;
    int rows = Math.Max(1, (count + columns - 1) / columns);
    int tileSize = TileSize * editor.TilesetZoom;
    using (ui.ScrollArea("tileset", 0, 0))
    {
        var area = ui.Area("tilesetview", columns * tileSize, rows * tileSize);
        var input = ui.Input();
        editor.HoverTile = 0;
        if (ui.Hovered() && input.MouseX >= area.X && input.MouseY >= area.Y)
        {
            int tx = (int)((int64)(input.MouseX - area.X) * columns / Math.Max(1, area.Width));
            int ty = (int)((int64)(input.MouseY - area.Y) * rows / Math.Max(1, area.Height));
            int index = 1 + tx + ty * columns;
            if (tx < columns && index <= count)
                editor.HoverTile = index;
        }
        if (ui.Clicked() && editor.HoverTile > 0)
        {
            editor.SelectedTile = editor.HoverTile;
            if (editor.Tool == Tool.Eraser || editor.Tool == Tool.ColorPicker || editor.Tool == Tool.EventChanger ||
                editor.Tool == Tool.EventRepeater || editor.Tool == Tool.PositionPicker)
                editor.Tool = Tool.Brush;
        }
        if (ui.RightClicked() && editor.HoverTile > 0)
        {
            editor.SelectedTile = editor.HoverTile;
            ui.OpenPopup("tilemenu");
        }

        var canvas = ui.Canvas();
        var clip = canvas.Clip.Intersect(area);
        if (!clip.IsEmpty())
        {
            canvas.FillRect(clip, Color.FromRgb(40, 40, 40));
            var atlas = editor.Graphics.Atlas(editor.Map.TilesetOrLabdataIndex, editor.Map.PaletteIndex);
            int frame = AnimationFrame(ref editor);
            HashSet<uint32> used = editor.MarkUnused ? editor.UsedTiles() : HashSet<uint32>.Create();
            int r0 = Math.Max(0, (int)((int64)(clip.Y - area.Y) * rows / area.Height));
            int r1 = Math.Min(rows - 1, (int)((int64)(clip.Bottom() - area.Y) * rows / area.Height));
            for (var row = r0; row <= r1; row += 1)
            {
                for (var column = 0; column < columns; column += 1)
                {
                    int index = 1 + column + row * columns;
                    if (index > count)
                        break;
                    var cell = CellRect(area, columns, rows, column, row);
                    DrawTile(canvas, atlas, tileset, (uint32)index, frame, cell);
                    if (editor.MarkUnused && !used.Contains((uint32)index))
                        canvas.FillRect(cell, Color.FromArgb(0x70, 0xff, 0x80, 0x00));
                    if (index == editor.SelectedTile)
                        canvas.StrokeRect(cell, 2, Color.FromRgb(255, 230, 0));
                }
            }
        }
    }
}
