using System.Linq;
using System.Text;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using AmbermoonScript;

namespace AmbermoonScriptEditor;

public partial class MainForm : Form
{
    private GameData? gameData;

    public MainForm()
    {
        InitializeComponent();
    }

    private void MainForm_Load(object sender, EventArgs e)
    {

    }

    private void ButtonCompile_Click(object sender, EventArgs e)
    {
        var parser = new ScriptParser();

        if (!parser.TryParseFile(textBoxScriptFile.Text, out var file))
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

    private void NewToolStripMenuItem_Click(object sender, EventArgs e)
    {
        if (textBoxScript.Text.Trim().Length != 0)
        {
            // TODO: unsaved confirmation
        }

        textBoxScript.Clear();
        textBoxScript.Enabled = true;
    }

    private void LoadFromGameDataToolStripMenuItem_Click(object sender, EventArgs e)
    {
        void Load()
        {
            var loadForm = new LoadFromGameDataForm(gameData);

            if (loadForm.ShowDialog() == DialogResult.OK)
            {
                LoadGameEvents(loadForm.LoadedEvents.Events, loadForm.LoadedEvents.EventList);
            }
        }

        if (gameData != null)
        {
            var answer = MessageBox.Show("Use previously loaded game data?", "Reuse game data", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question);

            if (answer == DialogResult.Cancel)
                return;

            if (answer == DialogResult.Yes)
            {
                Load();
                return;
            }
        }

        var fb = new FolderBrowserDialog
        {
            Description = "Select game data folder (Amberfiles)",
            Multiselect = false,
            ShowNewFolderButton = false,
            UseDescriptionForTitle = true
        };

        if (fb.ShowDialog() == DialogResult.OK)
        {
            gameData = new GameData();

            try
            {
                gameData.Load(fb.SelectedPath);
            }
            catch (Exception ex)
            {
                gameData = null;
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            Load();
        }
    }

    private record EventWrapper(Event Event, bool SequenceStart);

    private void LoadGameEvents(List<Event> events, List<Event> eventList)
    {
        using var writer = new StreamWriter(new MemoryStream());
        uint seq = 1;
        var streamIndexForEvent = new Dictionary<uint, long>();
        var branchTargetEventIds = new HashSet<uint>();
        var branchHasLabel = new HashSet<uint>();

        var eventQueue = new Queue<EventWrapper>(eventList.Select(ev => new EventWrapper(ev, true)));

        while (eventQueue.Count != 0)
        {
            var ev = eventQueue.Dequeue();

            if (ev.SequenceStart)
                writer.WriteLine($"# Sequence {seq++}");
            else
            {
                writer.WriteLine($"event{ev.Event.Index}:");
                branchHasLabel.Add(ev.Event.Index);
            }

            var next = ev.Event;

            while (next != null && !streamIndexForEvent.ContainsKey(next.Index))
            {
                writer.Flush();

                streamIndexForEvent.Add(next.Index, writer.BaseStream.Position);

                try
                {
                    var scriptEvent = ScriptEventSequence.GetScriptEvent(next);

                    writer.Write("- ");
                    scriptEvent.Print(next, writer);

                    if (scriptEvent is IBranchScriptEvent branchScriptEvent && branchScriptEvent.AlternativeBranchIndex != null)
                    {
                        branchTargetEventIds.Add(branchScriptEvent.AlternativeBranchIndex.Value);
                        eventQueue.Enqueue(new(events[(int)branchScriptEvent.AlternativeBranchIndex.Value], false));
                        writer.WriteLine($"-> {branchScriptEvent.BranchExpressionString}: JumpTo(event{branchScriptEvent.AlternativeBranchIndex})");
                    }
                }
                catch
                {
                    writer.WriteLine($"- Invalid event type: {next.Type}");
                }

                next = next.Next;
            }

            writer.WriteLine();
        }

        // It is possible that a normal event was printed and later some branch event
        // branches to it. In this case the first event has no branch label, so we
        // have to add it here.
        var branchTargetEventsByStreamPosition = new List<uint>();
        foreach (var branchTargetEventId in branchTargetEventIds)
        {
            if (!branchHasLabel.Contains(branchTargetEventId))
            {
                branchTargetEventsByStreamPosition.Add(branchTargetEventId);
            }
        }
        // Higher indices first so we don't mess up earlier stream positions!
        branchTargetEventsByStreamPosition.Sort((a, b) => streamIndexForEvent[b].CompareTo(streamIndexForEvent[a]));
        foreach (var branchTargetEventId in branchTargetEventsByStreamPosition)
        {
            writer.BaseStream.Position = streamIndexForEvent[branchTargetEventId];
            writer.WriteLine($"event{branchTargetEventId}:");
        }

        writer.BaseStream.Position = 0;

        textBoxScript.Text = Encoding.UTF8.GetString(new DataReader(writer.BaseStream).ReadToEnd());
        textBoxScript.Enabled = true;
    }

    private void QuitToolStripMenuItem_Click(object sender, EventArgs e)
    {
        Close();
    }
}
