using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;

namespace AmbermoonEditor;

public partial class MapTextControl : DataControl
{
    class TextEntry
    {
        public string Text { get; set; }
    }

    readonly Dictionary<int, List<TextEntry>> mapTexts = [];
    bool isWorldMap = false;
    int currentTextIndex = 0;

    static bool IsWorldMap(int mapIndex)
    {
        return mapIndex <= 256 ||
            (mapIndex >= 300 && mapIndex <= 336) ||
            (mapIndex >= 513 && mapIndex <= 528);
    }

    private void MapTextControl_Load(object sender, System.EventArgs e)
    {
        bool[] mapTextsAvailable = [false, false, false];

        for (int i = 1; i <= 3; ++i)
        {
            string containerName = $"{i}Map_texts.amb";

            if (!GameData.Files.ContainsKey(containerName))
                continue;

            mapTextsAvailable[i - 1] = true;

            var container = GameData.Files[containerName];

            foreach (var file in container.Files)
            {
                if (file.Value.Size > 0)
                    mapTexts.Add(file.Key, TextReader.ReadTexts(file.Value).Select(t => new TextEntry { Text = t }).ToList());
            }
        }

        if (mapTextsAvailable[0])
        {
            for (int i = 1; i <= 256; ++i)
                comboBoxMaps.Items.Add(i);
            if (!mapTextsAvailable[1])
                comboBoxMaps.SelectedIndex = 0;
        }
        if (mapTextsAvailable[1])
        {
            for (int i = 257; i <= 299; ++i)
                comboBoxMaps.Items.Add(i);
            for (int i = 400; i <= 528; ++i)
                comboBoxMaps.Items.Add(i);
            comboBoxMaps.SelectedIndex = mapTextsAvailable[0] ? 256 : 0;
        }
        if (mapTextsAvailable[2])
        {
            for (int i = 300; i <= 369; ++i)
                comboBoxMaps.Items.Add(i);
            if (!mapTextsAvailable[0] && !mapTextsAvailable[1])
                comboBoxMaps.SelectedIndex = 0;
        }
    }

    int MapIndex => (int)comboBoxMaps.SelectedItem;

    private void ComboBoxMaps_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        if (!mapTexts.TryGetValue(MapIndex, out var texts))
            texts = [];

        isWorldMap = IsWorldMap(MapIndex);

        labelName.Enabled = !isWorldMap;
        textBoxName.Enabled = !isWorldMap;
        textBoxName.Text = isWorldMap || texts.Count == 0 ? "" : texts[0].Text;

        int offset = isWorldMap ? 0 : 1;
        comboBoxTexts.Items.Clear();

        for (int i = offset; i < texts.Count; ++i)
        {
            comboBoxTexts.Items.Add(i.ToString("000"));
        }

        textBoxText.Text = comboBoxTexts.Items.Count == 0 ? "" : texts[offset].Text;
        buttonAdd.Enabled = comboBoxTexts.Items.Count < 0xffff - offset;
        buttonRemove.Enabled = comboBoxTexts.Items.Count != 0;

        if (comboBoxTexts.Items.Count != 0)
        {
            comboBoxTexts.SelectedIndex = 0;
            textBoxText.Enabled = true;
        }
        else
        {
            textBoxText.Text = "";
            textBoxText.Enabled = false;
        }
    }

    private void ComboBoxTexts_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        int offset = isWorldMap ? 0 : 1;

        if (!mapTexts.TryGetValue(MapIndex, out List<TextEntry> value))
            mapTexts.Add(MapIndex, []);
        else
            value[offset + currentTextIndex].Text = textBoxText.Text;

        currentTextIndex = comboBoxTexts.SelectedIndex;

        if (mapTexts[MapIndex].Count == offset + currentTextIndex)
            mapTexts[MapIndex].Add(new TextEntry { Text = "<enter text>" });
        textBoxText.Text = mapTexts[MapIndex][offset + currentTextIndex].Text;
    }

    private void ButtonAdd_Click(object sender, System.EventArgs e)
    {
        int offset = isWorldMap ? 0 : 1;
        comboBoxTexts.Items.Add((offset + comboBoxTexts.Items.Count).ToString("000"));
        comboBoxTexts.SelectedIndex = comboBoxTexts.Items.Count - 1;

        if (comboBoxTexts.Items.Count == 0xffff - offset)
            buttonAdd.Enabled = false;

        textBoxText.Enabled = true;
        buttonRemove.Enabled = true;
    }

    private void ButtonRemove_Click(object sender, System.EventArgs e)
    {
        if (comboBoxTexts.Items.Count != 0)
        {
            int last = Math.Max(0, comboBoxTexts.SelectedIndex - 1);
            comboBoxTexts.Items.RemoveAt(comboBoxTexts.SelectedIndex);
            buttonAdd.Enabled = true;

            if (comboBoxTexts.Items.Count == 0)
                buttonRemove.Enabled = false;

            if (comboBoxTexts.Items.Count == 0)
            {
                textBoxText.Text = "";
                textBoxText.Enabled = false;
            }
            else
            {
                int offset = isWorldMap ? 0 : 1;

                for (int i = last + 1; i < comboBoxTexts.Items.Count; ++i)
                    comboBoxTexts.Items[i] = (offset + i).ToString("000");

                comboBoxTexts.SelectedIndex = last;
            }
        }
    }
}
