using System.Drawing;
using System.Windows.Forms;

namespace AmbermoonEditor.Extensions;

internal static class ControlExtensions
{
    public static void AdjustUpLeft(this Control control, Point upperLeftPosition)
    {
        var bounds = control.Bounds;
        var lowerRight = new Point(bounds.Right, bounds.Bottom);

        control.Location = upperLeftPosition;
        control.Size = new Size(
            lowerRight.X - upperLeftPosition.X,
            lowerRight.Y - upperLeftPosition.Y
        );
    }

    public static ToolTip SetTooltip(this Control control, string tooltipText)
    {
        var tooltip = new ToolTip();

        tooltip.SetToolTip(control, tooltipText);

        return tooltip;
    }
}
