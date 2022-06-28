using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace AmbermoonMapCharEditor
{
    [EditorBrowsable(EditorBrowsableState.Advanced)]
    public static class ComboBoxExtensions
    {
        public static Rectangle GetItemBounds(this ComboBox comboBox, int index)
        {
            const int SB_VERT = 0x1;
            const int SIF_RANGE = 0x1;
            const int SIF_POS = 0x4;
            const uint GETCOMBOBOXINFO = 0x0164;

            var info = new Interop.COMBOBOXINFO();
            info.cbSize = Marshal.SizeOf(info);
            Interop.SendMessageW(
                comboBox.Handle,
                GETCOMBOBOXINFO,
                IntPtr.Zero,
                ref info);
            Interop.GetWindowRect(info.hwndList, out Interop.RECT rc);
            var dropdownArea = new Rectangle(comboBox.PointToClient(rc.Location), rc.Size);
            int yDiff = index * comboBox.ItemHeight;
            var scrollInfo = new Interop.SCROLLINFO();
            scrollInfo.cbSize = (uint)Marshal.SizeOf(scrollInfo);
            scrollInfo.fMask = SIF_RANGE | SIF_POS;
            Interop.GetScrollInfo(info.hwndList, SB_VERT, ref scrollInfo);
            int scrollY = scrollInfo.nPos * comboBox.ItemHeight;
            return new Rectangle(dropdownArea.X, dropdownArea.Y - scrollY + yDiff, rc.Width, comboBox.ItemHeight);
        }
    }
}
