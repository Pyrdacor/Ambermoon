// Image editing: the rectangle of the selection, the clipboard (cut, copy, paste), a floating part that is moved with
// the mouse until it is placed, and the transformations (mirror, rotate, crop, scale, canvas size).
//
// A floating part is a picture of its own above the picture. It comes from Paste (the change begins when it is placed)
// or from lifting the selection (moving it, mirroring or rotating it: the change begins with the lift, and the place it
// came from becomes transparent).

using System;
using System.Image;

/// The value of a transparent pixel of a picture (for an indexed picture without room for one: color 0).
uint32 TransparentOf(ref Picture picture)
{
    int64 value = picture.TransparentValue();
    return value < 0 ? (uint32)0 : (uint32)value;
}

/// Whether a value of a picture is shown transparent.
bool IsTransparent(Picture picture, uint32 value)
{
    uint32 color = picture.Indexed ? picture.IndexColor((int)value) : value;
    return (color >> 24) < 128;
}

/// The palette index whose color is nearest to an ARGB color (color 0 of an Amiga graphic is left out: it is
/// transparent).
int NearestIndex(Picture picture, uint32 argb)
{
    int best = picture.TransparentZero && picture.Palette.Count() > 1 ? 1 : 0;
    int bestDistance = int.MaxValue;
    for (var i = picture.TransparentZero ? 1 : 0; i < picture.Palette.Count(); i += 1)
    {
        uint32 color = picture.Palette[i];
        if ((color >> 24) < 128)
            continue;
        int distance = _Distance(argb, color);
        if (distance < bestDistance)
        {
            best = i;
            bestDistance = distance;
        }
    }
    return best;
}

/// A part (of any picture) in the values of a target picture: the same palette keeps its indices, other colors get
/// the nearest color of the target, transparent pixels its transparent value.
Picture ConvertFor(Picture part, ref Picture target)
{
    bool samePalette = part.Indexed && target.Indexed && part.Palette.Count() <= target.Palette.Count() && part.TransparentZero == target.TransparentZero;
    for (var i = 0; samePalette && i < part.Palette.Count(); i += 1)
        samePalette = part.Palette[i] == target.Palette[i];
    if (samePalette)
        return part;
    uint32 transparent = TransparentOf(ref target);
    var result = target.Blank(part.Width, part.Height, transparent);
    var nearest = Dictionary<uint32, int>.Create();
    for (var y = 0; y < part.Height; y += 1)
    {
        for (var x = 0; x < part.Width; x += 1)
        {
            uint32 value = part.Get(x, y);
            uint32 color = part.Indexed ? part.IndexColor((int)value) : value;
            if ((color >> 24) < 128)
                continue;
            if (!target.Indexed)
            {
                result.SetRaw(x, y, color | 0xff000000u);
                continue;
            }
            if (nearest.TryGet(color) is int known)
            {
                result.SetRaw(x, y, (uint32)known);
                continue;
            }
            int index = NearestIndex(target, color);
            nearest[color] = index;
            result.SetRaw(x, y, (uint32)index);
        }
    }
    return result;
}

// ---- the selection ----

/// Places a floating part (one undo step, unless the change began when it was lifted).
void CommitFloat(ref Editor editor)
{
    if (!editor.Floating)
        return;
    if (!editor.FloatOwnsChange)
        editor.BeginChange();
    editor.Picture.Stamp(editor.FloatPic, editor.FloatX, editor.FloatY, editor.PasteTransparent, TransparentOf(ref editor.Picture));
    editor.SelX = editor.FloatX;
    editor.SelY = editor.FloatY;
    editor.SelW = editor.FloatPic.Width;
    editor.SelH = editor.FloatPic.Height;
    editor.Floating = false;
    editor.ViewChanged = true;
}

/// Places a floating part and forgets the selection.
void Deselect(ref Editor editor)
{
    CommitFloat(ref editor);
    editor.HasSelection = false;
}

/// Selects the whole picture, or the current frame when only it is shown.
void SelectAll(ref Editor editor)
{
    CommitFloat(ref editor);
    int fw = editor.Picture.FrameWidth();
    editor.HasSelection = true;
    editor.SelX = editor.SingleFrame ? editor.CurrentFrame * fw : 0;
    editor.SelY = 0;
    editor.SelW = editor.SingleFrame ? fw : editor.Picture.Width;
    editor.SelH = editor.Picture.Height;
    editor.Tool = Tool.Select;
}

/// Lifts the selected pixels into a floating part; the place they came from becomes transparent.
void LiftSelection(ref Editor editor)
{
    if (!editor.HasSelection || editor.Floating)
        return;
    editor.BeginChange();
    uint32 transparent = TransparentOf(ref editor.Picture);
    editor.FloatPic = editor.Picture.Extract(editor.SelX, editor.SelY, editor.SelW, editor.SelH, transparent);
    editor.Picture.FillRect(editor.SelX, editor.SelY, editor.SelW, editor.SelH, transparent);
    editor.FloatX = editor.SelX;
    editor.FloatY = editor.SelY;
    editor.Floating = true;
    editor.FloatOwnsChange = true;
    editor.FloatChanged = true;
    editor.ViewChanged = true;
}

/// The selected pixels (the floating part, the selection, or the current frame without a selection).
Picture SelectedPart(ref Editor editor)
{
    if (editor.Floating)
        return editor.FloatPic.Clone();
    uint32 transparent = TransparentOf(ref editor.Picture);
    if (editor.HasSelection)
        return editor.Picture.Extract(editor.SelX, editor.SelY, editor.SelW, editor.SelH, transparent);
    int fw = editor.Picture.FrameWidth();
    return editor.Picture.Extract(editor.CurrentFrame * fw, 0, fw, editor.Picture.Height, transparent);
}

void Copy(ref Editor editor)
{
    editor.Clipboard = SelectedPart(ref editor);
    editor.HasClipboard = true;
    editor.Status = $"Copied {editor.Clipboard.Width} x {editor.Clipboard.Height} pixels";
}

void Cut(ref Editor editor)
{
    Copy(ref editor);
    DeleteSelection(ref editor);
}

/// Makes the selected pixels transparent (a floating part is dropped).
void DeleteSelection(ref Editor editor)
{
    if (editor.Floating)
    {
        editor.Floating = false;
        editor.HasSelection = false;
        editor.ViewChanged = true;
        return;
    }
    if (!editor.HasSelection)
        return;
    editor.BeginChange();
    editor.Picture.FillRect(editor.SelX, editor.SelY, editor.SelW, editor.SelH, TransparentOf(ref editor.Picture));
    editor.ViewChanged = true;
}

/// Pastes the clipboard as a floating part: at the selection, or at the top left of what is shown.
void Paste(ref Editor editor)
{
    if (!editor.HasClipboard)
        return;
    CommitFloat(ref editor);
    int x = editor.HasSelection ? editor.SelX : editor.SingleFrame ? editor.CurrentFrame * editor.Picture.FrameWidth() : 0;
    int y = editor.HasSelection ? editor.SelY : 0;
    editor.FloatPic = ConvertFor(editor.Clipboard, ref editor.Picture);
    editor.FloatX = x;
    editor.FloatY = y;
    editor.Floating = true;
    editor.FloatOwnsChange = false;
    editor.FloatChanged = true;
    editor.HasSelection = true;
    editor.SelX = x;
    editor.SelY = y;
    editor.SelW = editor.FloatPic.Width;
    editor.SelH = editor.FloatPic.Height;
    editor.Tool = Tool.Select;
}

// ---- transformations ----

enum Transform : int32
{
    FlipHorizontal,
    FlipVertical,
    RotateClockwise,
    RotateCounterclockwise
}

Picture _Transformed(Picture picture, Transform transform)
{
    switch (transform)
    {
        case Transform.FlipHorizontal: return picture.Flipped(true);
        case Transform.FlipVertical: return picture.Flipped(false);
        case Transform.RotateClockwise: return picture.Rotated(true);
        default: return picture.Rotated(false);
    }
}

/// Mirrors or rotates the selection (lifted into a floating part), or else each frame of the picture.
/// @error a rotation of frames that are not square (with more than one frame).
Error<void> TransformPicture(ref Editor editor, Transform transform)
{
    bool rotate = transform == Transform.RotateClockwise || transform == Transform.RotateCounterclockwise;
    if (editor.HasSelection)
    {
        LiftSelection(ref editor);
        editor.FloatPic = _Transformed(editor.FloatPic, transform);
        editor.SelW = editor.FloatPic.Width;
        editor.SelH = editor.FloatPic.Height;
        editor.FloatChanged = true;
        editor.ViewChanged = true;
        return;
    }
    var picture = editor.Picture;
    int frames = picture.Frames;
    int fw = picture.FrameWidth();
    if (rotate && frames > 1 && fw != picture.Height)
        return error($"The frames are {fw} x {picture.Height} pixels: only square frames can be rotated (or select a part).");
    editor.BeginChange();
    var parts = List<Picture>.Create();
    for (var f = 0; f < frames; f += 1)
        parts.Add(_Transformed(picture.Extract(f * fw, 0, fw, picture.Height, 0), transform));
    editor.Picture = JoinFrames(picture, parts);
    editor.AfterResize();
    return;
}

/// Frames side by side as one picture (of the kind of `like`).
Picture JoinFrames(Picture like, List<Picture> frames)
{
    int fw = frames[0].Width;
    var result = like.Blank(fw * frames.Count(), frames[0].Height, 0);
    for (var f = 0; f < frames.Count(); f += 1)
        result.Stamp(frames[f], f * fw, 0, false, 0);
    result.Frames = frames.Count();
    return result;
}

/// Cuts the picture down to the selection (one frame).
void CropToSelection(ref Editor editor)
{
    if (!editor.HasSelection)
        return;
    CommitFloat(ref editor);
    editor.BeginChange();
    editor.Picture = editor.Picture.Extract(editor.SelX, editor.SelY, editor.SelW, editor.SelH, TransparentOf(ref editor.Picture));
    editor.HasSelection = false;
    editor.AfterResize();
}

/// Gives each frame another size: its pixels scaled, or the canvas cut or extended (new pixels transparent; the old
/// picture at the top left or in the middle).
void ResizeFrames(ref Editor editor, int width, int height, bool scale, bool center)
{
    Deselect(ref editor);
    var picture = editor.Picture;
    int fw = picture.FrameWidth();
    if (width == fw && height == picture.Height)
        return;
    editor.BeginChange();
    uint32 transparent = TransparentOf(ref picture);
    var parts = List<Picture>.Create();
    for (var f = 0; f < picture.Frames; f += 1)
    {
        var frame = picture.Extract(f * fw, 0, fw, picture.Height, transparent);
        if (scale)
            parts.Add(frame.Scaled(width, height));
        else
        {
            var canvas = frame.Blank(width, height, transparent);
            canvas.Stamp(frame, center ? (width - fw) / 2 : 0, center ? (height - picture.Height) / 2 : 0, false, 0);
            parts.Add(canvas);
        }
    }
    editor.Picture = JoinFrames(picture, parts);
    editor.AfterResize();
}
