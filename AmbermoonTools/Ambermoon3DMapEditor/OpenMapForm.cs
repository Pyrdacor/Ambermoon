using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using System.Data;

namespace Ambermoon3DMapEditor
{
    public partial class OpenMapForm : Form
    {
        public OpenMapForm(GameData gameData)
        {
            InitializeComponent();

            unfilteredMaps = gameData.MapManager.Maps.Where(map => map.Type == MapType.Map3D).ToList();
            listViewMaps.Items.AddRange(unfilteredMaps.Select(map => new MapListItem(map)).ToArray());
            listViewMaps.AutoResizeColumns(ColumnHeaderAutoResizeStyle.HeaderSize);
        }

        private class MapListItem : ListViewItem
        {
            public MapListItem(Map map)
            {
                Map = map;
                Text = map.Index.ToString();
                SubItems.Add(map.Name);
            }

            public Map Map { get; set; }
        }

        private readonly List<Map> unfilteredMaps;
        public Map? SelectedMap { get; private set; }

        private void textBoxFilter_TextChanged(object sender, EventArgs e)
        {
            var filteredMaps = textBoxFilter.Text.Length == 0
                ? unfilteredMaps
                : unfilteredMaps.Where(map => map.Index.ToString().Contains(textBoxFilter.Text) || map.Name.Contains(textBoxFilter.Text, StringComparison.InvariantCultureIgnoreCase));

            listViewMaps.Items.Clear();
            listViewMaps.Items.AddRange(filteredMaps.Select(map => new MapListItem(map)).ToArray());
            listViewMaps.AutoResizeColumns(ColumnHeaderAutoResizeStyle.HeaderSize);
        }

        private void listViewMaps_ItemActivate(object sender, EventArgs e)
        {
            SelectedMap = (listViewMaps.FocusedItem as MapListItem)!.Map;
            DialogResult = DialogResult.OK;
        }
    }
}
