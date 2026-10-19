// The frames of a picture (graphics of the same size side by side): how many, which one is edited, adding, copying,
// removing and moving them, and a preview of the animation.

using System;
using System.Image;
using System.Ui;

/// The numbers of frames the width of the picture can be divided into (up to 64 of them).
List<int> FrameCounts(int width)
{
    var counts = List<int>.Create();
    for (var n = 1; n <= width && counts.Count() < 64; n += 1)
    {
        if (width % n == 0)
            counts.Add(n);
    }
    return counts;
}

/// Divides the picture into another number of frames (the pixels stay).
void SetFrameCount(ref Editor editor, int frames)
{
    if (frames < 1 || editor.Picture.Width % frames != 0 || frames == editor.Picture.Frames)
        return;
    Deselect(ref editor);
    editor.BeginChange();
    editor.Picture.Frames = frames;
    editor.CurrentFrame = Math.Min(editor.CurrentFrame, frames - 1);
}

/// Inserts a frame after the current one: a copy of it, or an empty (transparent) one.
void AddFrame(ref Editor editor, bool copy)
{
    Deselect(ref editor);
    var picture = editor.Picture;
    int fw = picture.FrameWidth();
    uint32 transparent = TransparentOf(ref picture);
    var parts = List<Picture>.Create();
    for (var f = 0; f < picture.Frames; f += 1)
    {
        var frame = picture.Extract(f * fw, 0, fw, picture.Height, transparent);
        parts.Add(frame);
        if (f == editor.CurrentFrame)
            parts.Add(copy ? frame.Clone() : frame.Blank(fw, picture.Height, transparent));
    }
    editor.BeginChange();
    editor.Picture = JoinFrames(picture, parts);
    editor.CurrentFrame += 1;
    editor.AfterResize();
}

/// Removes the current frame (not the last one).
void RemoveFrame(ref Editor editor)
{
    var picture = editor.Picture;
    if (picture.Frames < 2)
        return;
    Deselect(ref editor);
    int fw = picture.FrameWidth();
    var parts = List<Picture>.Create();
    for (var f = 0; f < picture.Frames; f += 1)
    {
        if (f != editor.CurrentFrame)
            parts.Add(picture.Extract(f * fw, 0, fw, picture.Height, 0));
    }
    editor.BeginChange();
    editor.Picture = JoinFrames(picture, parts);
    editor.CurrentFrame = Math.Min(editor.CurrentFrame, parts.Count() - 1);
    editor.AfterResize();
}

/// Moves the current frame one place to the left (-1) or right (1).
void MoveFrame(ref Editor editor, int direction)
{
    var picture = editor.Picture;
    int other = editor.CurrentFrame + direction;
    if (other < 0 || other >= picture.Frames)
        return;
    Deselect(ref editor);
    int fw = picture.FrameWidth();
    editor.BeginChange();
    var current = picture.Extract(editor.CurrentFrame * fw, 0, fw, picture.Height, 0);
    var neighbour = picture.Extract(other * fw, 0, fw, picture.Height, 0);
    editor.Picture.Stamp(neighbour, editor.CurrentFrame * fw, 0, false, 0);
    editor.Picture.Stamp(current, other * fw, 0, false, 0);
    editor.CurrentFrame = other;
    editor.ViewChanged = true;
}

/// The frame of the animation at a time (back and forth: 0 1 2 3 2 1 0 ...).
int AnimationFrame(int frames, double seconds, int milliseconds, bool pingPong)
{
    if (frames < 2)
        return 0;
    int step = (int)(seconds * 1000.0 / (double)Math.Max(1, milliseconds));
    if (!pingPong)
        return step % frames;
    int period = 2 * frames - 2;
    int at = step % period;
    return at < frames ? at : period - at;
}

/// The panel of the frames: their number, the current one, the frame operations and the animation.
void DrawFramesPanel(Ui ui, ref Editor editor)
{
    var picture = editor.Picture;
    int frames = picture.Frames;
    int fw = picture.FrameWidth();
    using (ui.Panel($"Frames ({frames} of {fw} x {picture.Height})"))
    {
        var counts = FrameCounts(picture.Width);
        var names = List<string>.Create();
        int selected = 0;
        for (var i = 0; i < counts.Count(); i += 1)
        {
            names.Add($"{counts[i]} ({picture.Width / counts[i]} wide)");
            if (counts[i] == frames)
                selected = i;
        }
        using (ui.Row())
        {
            ui.Label("Frames");
            if (ui.ComboBox("framecount", ref selected, names))
                SetFrameCount(ref editor, counts[selected]);
        }
        ui.Tooltip("Into how many frames the width of the picture is divided");
        if (frames > 1)
        {
            using (ui.Row())
            {
                if (ui.Button("<##prevframe"))
                    editor.CurrentFrame = (editor.CurrentFrame + frames - 1) % frames;
                ui.Label($"Frame {editor.CurrentFrame + 1} of {frames}");
                if (ui.Button(">##nextframe"))
                    editor.CurrentFrame = (editor.CurrentFrame + 1) % frames;
            }
            ui.Tooltip("The current frame (keys , and .)");
            if (ui.Checkbox("Show only this frame", ref editor.SingleFrame))
                Deselect(ref editor);
        }
        using (ui.Row())
        {
            if (ui.Button("Add"))
                AddFrame(ref editor, false);
            ui.Tooltip("An empty frame after the current one");
            if (ui.Button("Copy"))
                AddFrame(ref editor, true);
            ui.Tooltip("A copy of the current frame after it");
            if (frames > 1 && ui.Button("Remove"))
                RemoveFrame(ref editor);
        }
        if (frames > 1)
        {
            using (ui.Row())
            {
                ui.Label("Move");
                if (ui.Button("<##moveleft"))
                    MoveFrame(ref editor, -1);
                ui.Tooltip("Moves the current frame one place to the left");
                if (ui.Button(">##moveright"))
                    MoveFrame(ref editor, 1);
                ui.Tooltip("Moves the current frame one place to the right");
            }
            _DrawAnimation(ui, ref editor);
        }
    }
}

// the preview of the animation: the frames one after the other at the chosen speed
void _DrawAnimation(Ui ui, ref Editor editor)
{
    var picture = editor.Picture;
    int frames = picture.Frames;
    int fw = picture.FrameWidth();
    ui.Note("Animation");
    // as large as fits (at most 4 times), whole pixels if possible
    int maxWidth = 220;
    int maxHeight = 160;
    int scale = Math.Max(1, Math.Min(4, Math.Min(maxWidth / Math.Max(1, fw), maxHeight / Math.Max(1, picture.Height))));
    int w = fw * scale;
    int h = picture.Height * scale;
    if (w > maxWidth || h > maxHeight)
    {
        double fit = Math.Min((double)maxWidth / (double)fw, (double)maxHeight / (double)picture.Height);
        w = Math.Max(1, (int)((double)fw * fit));
        h = Math.Max(1, (int)((double)picture.Height * fit));
    }
    var area = ui.Area(w, h);
    int frame = editor.Playing ? AnimationFrame(frames, editor.Time - editor.PlayStart, editor.FrameMs, editor.PingPong) : editor.CurrentFrame;
    ui.DrawImage(editor.CurrentView(), Rect.Create(frame * fw, 0, fw, picture.Height), area);
    using (ui.Row())
    {
        if (ui.Button(editor.Playing ? "Pause" : "Play"))
        {
            editor.Playing = !editor.Playing;
            editor.PlayStart = editor.Time;
        }
        ui.Label($"Frame {frame + 1}");
    }
    using (ui.Row())
    {
        ui.Label($"{editor.FrameMs} ms");
        if (ui.Slider("framems", ref editor.FrameMs, 20, 1000))
            editor.PlayStart = editor.Time;
    }
    ui.Tooltip("How long each frame is shown");
    ui.Checkbox("Back and forth", ref editor.PingPong);
    ui.Tooltip("Plays the frames forwards and then backwards (like the wave animation of the game)");
}
