using System.Text;
using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;
using AmbermoonScript;

namespace AmbermoonScriptEditor;

public partial class Form1 : Form
{
    public Form1()
    {
        InitializeComponent();
    }

    private void Form1_Load(object sender, EventArgs e)
    {

    }

    private void button1_Click(object sender, EventArgs e)
    {
        var parser = new ScriptParser();

        if (!parser.TryParseFile(textBoxScript.Text, out var file))
        {
            MessageBox.Show(string.Join(Environment.NewLine, parser.GetWarnings()), "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        MessageBox.Show($"Version: {file!.Header.Version}, Type: {file.Header.Type}, Index: {file.Header.Index}");

        foreach (var seq in file.Sequences)
        {
            MessageBox.Show("Sequence " + seq.Index);

            foreach (var ev in seq.Events)
            {
                var ee = ev.ToEvent();
                using var writer = new StreamWriter(new MemoryStream());
                ev.Print(ee, writer);

                writer.Flush();
                writer.BaseStream.Position = 0;

                MessageBox.Show(Encoding.UTF8.GetString(new DataReader(writer.BaseStream).ReadToEnd()));
            }
        }
    }

    private void button2_Click(object sender, EventArgs e)
    {
        var reader = new DataReader(File.ReadAllBytes(textBoxMap.Text));
        var map = new Map();
        MapReader.ReadMapHeader(map, reader);
        reader.Position += 320;
        reader.Position += map.Width * map.Height * (map.Type == MapType.Map3D ? 2 : 4);
        var eventList = new List<Event>();
        var events = new List<Event>();
        EventReader.ReadEvents(reader, events, eventList);

        var scriptEvent = ScriptEventSequence.GetScriptEvent(events[1]);

        using var writer = new StreamWriter(new MemoryStream());
        scriptEvent.Print(events[1], writer);

        writer.Flush();
        writer.BaseStream.Position = 0;

        MessageBox.Show(Encoding.UTF8.GetString(new DataReader(writer.BaseStream).ReadToEnd()));
    }
}
