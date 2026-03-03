using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using LoadedEvents = (System.Collections.Generic.List<Ambermoon.Data.Event> Events, System.Collections.Generic.List<Ambermoon.Data.Event> EventList);

namespace AmbermoonScriptEditor;

public partial class LoadFromGameDataForm : Form
{
    private readonly GameData gameData;
    private readonly Action[] initActions;
    private readonly Func<int, LoadedEvents>[] loadActions;

    public LoadedEvents LoadedEvents { get; private set; }

    private record ListItem(uint Index, string Name)
    {
        public override string ToString() => Name;
    }

    public LoadFromGameDataForm(GameData gameData)
    {
        this.gameData = gameData;
        initActions = [InitMaps, InitNPCs, InitPartyMembers];
        loadActions = [LoadMap, LoadNPC, LoadPlayer];

        InitializeComponent();
    }

    private void ComboBoxType_SelectedIndexChanged(object sender, EventArgs e)
    {
        initActions[comboBoxType.SelectedIndex]();
    }

    private void InitMaps()
    {
        labelItem.Text = "Map:";

        comboBoxItems.Items.Clear();
        comboBoxItems.Items.AddRange(gameData.MapManager.Maps.Select(map => new ListItem(map.Index, $"{map.Index:000}: {map.Name}")).ToArray());

        comboBoxItems.SelectedIndex = 0;
    }

    private void InitNPCs()
    {
        labelItem.Text = "NPC:";

        comboBoxItems.Items.Clear();
        comboBoxItems.Items.AddRange(gameData.CharacterManager.NPCs.Select(npc => new ListItem(npc.Index, $"{npc.Index:000}: {npc.Name}")).ToArray());

        comboBoxItems.SelectedIndex = 0;
    }

    private void InitPartyMembers()
    {
        labelItem.Text = "Player:";

        comboBoxItems.Items.Clear();
        comboBoxItems.Items.AddRange(gameData.CharacterManager.InitialPartyMembers.Where(partyMember => partyMember.Index != 1).Select(partyMember => new ListItem(partyMember.Index, $"{partyMember.Index:000}: {partyMember.Name}")).ToArray());

        comboBoxItems.SelectedIndex = 0;
    }

    private LoadedEvents LoadMap(int index)
    {
        var item = (comboBoxItems.Items[index] as ListItem)!;
        var map = gameData.MapManager.GetMap(item.Index);

        return (map.Events, map.EventList);
    }

    private LoadedEvents LoadNPC(int index)
    {
        var item = (comboBoxItems.Items[index] as ListItem)!;
        var npc = gameData.CharacterManager.GetNPC(item.Index);

        return LoadCharacter(npc);
    }

    private LoadedEvents LoadPlayer(int index)
    {
        var item = (comboBoxItems.Items[index] as ListItem)!;
        var player = gameData.CharacterManager.GetInitialPartyMember(item.Index);

        return LoadCharacter(player);
    }

    private static LoadedEvents LoadCharacter(IConversationPartner character)
    {
        return (character.Events, character.EventList);
    }

    private void ButtonLoad_Click(object sender, EventArgs e)
    {
        LoadedEvents = loadActions[comboBoxType.SelectedIndex](comboBoxItems.SelectedIndex);

        this.DialogResult = DialogResult.OK;
    }

    private void LoadFromGameDataForm_Load(object sender, EventArgs e)
    {
        comboBoxType.SelectedIndex = 0;
    }
}
