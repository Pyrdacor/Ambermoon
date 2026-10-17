// The characters of a map (party members, NPCs, monster groups and map objects): their names from the game data, the
// panel to edit them (a port of AmbermoonMapCharEditor) and their positions over the day.
//
// The game stores for each character either one position (monsters and characters with random movement) or a path of
// 288 positions, one for each 5 minutes of the day; 0, 0 means "not on the map" at that time.

using System;
using System.Image;
using System.Ui;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

const int PathSteps = 288;

/// Numbers with names for a choice box ("12: Gryban").
struct NameList
{
    List<int> Keys;
    List<string> Labels;

    static NameList Create()
    {
        return NameList { Keys = List<int>.Create(), Labels = List<string>.Create() };
    }

    void Add(int key, string name)
    {
        Keys.Add(key);
        Labels.Add($"{key}: {name}");
    }

    /// The position of a number in the list (-1: not in it).
    int Find(int key)
    {
        for (var i = 0; i < Keys.Count(); i += 1)
        {
            if (Keys[i] == key)
                return i;
        }
        return -1;
    }
}

/// The names of the characters a map can refer to.
struct CharacterNames
{
    NameList Party;
    NameList NPCs;
    NameList MonsterGroups;

    static CharacterNames Load(GameData gameData)
    {
        var names = CharacterNames
        {
            Party = NameList.Create(),
            NPCs = NameList.Create(),
            MonsterGroups = NameList.Create()
        };
        // the hero (party member 1) is never on a map
        _LoadNames(gameData, "Save.00/Party_char.amb", ref names.Party, 2);
        _LoadNames(gameData, "NPC_char.amb", ref names.NPCs, 1);

        var monsters = NameList.Create();
        _LoadNames(gameData, gameData.Files.ContainsKey("Monster_char.amb") ? "Monster_char.amb" : "Monster_char_data.amb", ref monsters, 1);
        var bosses = List<int>.Create();
        if (gameData.Files.TryGet("Monster_char.amb") is FileContainer monsterFile)
        {
            foreach (var number in monsterFile.Numbers())
            {
                var reader = monsterFile.Files[number];
                if (reader.Size() > 0x12 && ((int)reader.Get(0x12) & 0x04) != 0)
                    bosses.Add(number);
            }
        }

        // a group: the boss first, then the others with their count ("Boss, 2x Orc, Goblin")
        if (gameData.Files.TryGet("Monster_groups.amb") is FileContainer groups)
        {
            foreach (var number in groups.Numbers())
            {
                var reader = groups.Files[number];
                if (reader.Size() < 36)
                    continue;
                reader.Position = 0;
                var members = List<int>.Create();
                var counts = List<int>.Create();
                string boss = "";
                for (var i = 0; i < 18; i += 1)
                {
                    int monster = (int)reader.ReadWord();
                    if (monster == 0)
                        continue;
                    if (boss.Length == 0 && bosses.Contains(monster))
                    {
                        boss = _MonsterName(ref monsters, monster);
                        continue;
                    }
                    int at = members.IndexOf(monster);
                    if (at < 0)
                    {
                        members.Add(monster);
                        counts.Add(1);
                    }
                    else
                        counts[at] = counts[at] + 1;
                }
                string name = boss;
                for (var i = 0; i < members.Count(); i += 1)
                {
                    if (name.Length > 0)
                        name += ", ";
                    if (counts[i] > 1)
                        name += $"{counts[i]}x ";
                    name += _MonsterName(ref monsters, members[i]);
                }
                names.MonsterGroups.Add(number, name);
            }
        }
        return names;
    }

    static string _MonsterName(ref NameList monsters, int monster)
    {
        int at = monsters.Find(monster);
        if (at < 0)
            return $"Monster {monster}";
        string label = monsters.Labels[at];
        return label[(label.IndexOf(": ") + 2)..].ToString();
    }

    // the names of a file of characters (at offset 0x112, 16 characters)
    static void _LoadNames(GameData gameData, string file, ref NameList list, int first)
    {
        if (gameData.Files.TryGet(file) is not FileContainer container)
            return;
        foreach (var number in container.Numbers())
        {
            var reader = container.Files[number];
            if (number < first || reader.Size() < 0x112 + 16)
                continue;
            reader.Position = 0x112;
            list.Add(number, _TrimName(reader.ReadString(16)));
        }
    }

    static string _TrimName(string text)
    {
        int end = 0;
        while (end < text.Length && text[end] != 0)
            end += 1;
        while (end > 0 && text[end - 1] == ' ')
            end -= 1;
        return text[0..end].ToString();
    }
}

string CharacterTypeName(CharacterType type)
{
    switch (type)
    {
        case CharacterType.PartyMember: return "Party member";
        case CharacterType.NPC: return "NPC";
        case CharacterType.Monster: return "Monster group";
        default: return "Map object";
    }
}

bool HasFlag(CharacterReference reference, CharacterReferenceFlags flag)
{
    return (reference.CharacterFlags & flag) != CharacterReferenceFlags.None;
}

/// How many positions the game stores for a character: 1, 12 (Ambermoon.net: one for every two hours) or 288.
int PositionCount(CharacterReference reference)
{
    if (reference.Type == CharacterType.Monster ||
        HasFlag(reference, CharacterReferenceFlags.RandomMovement) || HasFlag(reference, CharacterReferenceFlags.Stationary))
        return 1;
    if (HasFlag(reference, CharacterReferenceFlags.HourMovement))
        return 12;
    return PathSteps;
}

/// The position of a character that is used at a time of the day (0 to 287: 5 minutes each).
int PositionIndex(CharacterReference reference, int step)
{
    int count = PositionCount(reference);
    if (count == 1)
        return 0;
    if (count == 12)
        return Math.Min(11, step / 24);
    return step;
}

/// Gives a character as many positions as the game reads for it (a new path starts where the character stood).
void FitPositions(ref CharacterReference reference)
{
    if (reference.Positions.Count() == 0)
        reference.Positions.Add(Position { X = 0, Y = 0 });
    var first = reference.Positions[0];
    while (reference.Positions.Count() < PositionCount(reference))
        reference.Positions.Add(first);
}

/// The name of the character a reference stands for.
string CharacterName(ref Editor editor, CharacterReference reference)
{
    int index = (int)reference.Index;
    switch (reference.Type)
    {
        case CharacterType.PartyMember:
            return _Name(ref editor.Names.Party, index);
        case CharacterType.NPC:
            if (HasFlag(reference, CharacterReferenceFlags.TextPopup))
                return $"text {index}";
            return _Name(ref editor.Names.NPCs, index);
        case CharacterType.Monster:
            return _Name(ref editor.Names.MonsterGroups, index);
        default:
            return $"event {reference.EventIndex:X2}";
    }
}

string _Name(ref NameList list, int key)
{
    int at = list.Find(key);
    return at < 0 ? key.ToString() : list.Labels[at];
}

/// The time of a step of the day ("13:05").
string StepTime(int step)
{
    int minutes = step * 5;
    return $"{minutes / 60:D2}:{minutes % 60:D2}";
}

/// Adds a character (an NPC that is not on the map yet; the next click on the map places it).
void AddCharacter(ref Editor editor)
{
    int slot = -1;
    for (var i = 0; i < editor.Map.CharacterReferences.Length && slot < 0; i += 1)
    {
        if (editor.Map.CharacterReferences[i] is not CharacterReference)
            slot = i;
    }
    if (slot < 0)
        return;
    editor.BeginChange();
    var reference = CharacterReference
    {
        Type = CharacterType.NPC,
        Index = editor.Names.NPCs.Keys.Count() > 0 ? (uint32)editor.Names.NPCs.Keys[0] : (uint32)1,
        Positions = List<Position>.Create()
    };
    FitPositions(ref reference);
    editor.Map.CharacterReferences[slot] = reference;
    editor.CharactersChanged = true;
    editor.SelectedCharacter = slot;
    editor.PathStep = 0;
    editor.PlaceFollowing = true;
    editor.Tool = Tool.PositionPicker;
    editor.ShowCharacters = true;
}

/// Removes a character; the ones after it move up (the game stops at the first empty one).
void RemoveCharacter(ref Editor editor, int index)
{
    var characters = editor.Map.CharacterReferences;
    if (index < 0 || index >= characters.Length || characters[index] is not CharacterReference)
        return;
    editor.BeginChange();
    for (var i = index; i < characters.Length - 1; i += 1)
        characters[i] = characters[i + 1];
    characters[characters.Length - 1] = null;
    editor.CharactersChanged = true;
    editor.SelectedCharacter = -1;
    if (editor.Tool == Tool.PositionPicker)
        editor.Tool = Tool.Brush;
}

/// Places the selected character at a tile: its position, or on a path the position at the time of the day (and the
/// following ones if wanted).
void PlaceCharacter(ref Editor editor, int x, int y)
{
    if (editor.SelectedCharacter < 0)
        return;
    if (editor.Map.CharacterReferences[editor.SelectedCharacter] is not CharacterReference reference)
        return;
    editor.BeginChange();
    FitPositions(ref reference);
    int first = PositionIndex(reference, editor.PathStep);
    int last = editor.PlaceFollowing ? PositionCount(reference) - 1 : first;
    for (var i = first; i <= last; i += 1)
        reference.Positions[i] = Position { X = x + 1, Y = y + 1 };
    editor.Map.CharacterReferences[editor.SelectedCharacter] = reference;
    editor.CharactersChanged = true;
}

// changes the selected character (an undo step)
void _Change(ref Editor editor, CharacterReference reference)
{
    FitPositions(ref reference);
    editor.Map.CharacterReferences[editor.SelectedCharacter] = reference;
    editor.CharactersChanged = true;
}

bool _CharacterFlag(Ui ui, ref Editor editor, ref CharacterReference reference, string label, CharacterReferenceFlags flag)
{
    bool value = HasFlag(reference, flag);
    if (!ui.Checkbox(label, ref value))
        return false;
    editor.BeginChange();
    reference.CharacterFlags = value ? reference.CharacterFlags | flag : reference.CharacterFlags & ~flag;
    return true;
}

/// The characters of the map: the list, adding and removing, and the properties of the selected one.
void DrawCharacterPanel(Ui ui, ref Editor editor)
{
    var characters = editor.Map.CharacterReferences;
    int count = 0;
    foreach (var entry in characters)
    {
        if (entry is CharacterReference)
            count += 1;
    }
    using (ui.Panel($"Characters ({count})"))
    {
        using (ui.Scroll("characters", 140))
        {
            for (var i = 0; i < characters.Length; i += 1)
            {
                if (characters[i] is not CharacterReference reference)
                    continue;
                using (ui.Id(i))
                {
                    if (ui.ListItem($"{i + 1}: {CharacterTypeName(reference.Type)} {CharacterName(ref editor, reference)}", editor.SelectedCharacter == i))
                    {
                        editor.SelectedCharacter = i;
                        editor.ShowCharacters = true;
                    }
                }
            }
            if (count == 0)
                ui.Note("none");
        }
        using (ui.Row())
        {
            if (count < characters.Length && ui.Button("Add"))
                AddCharacter(ref editor);
            ui.Tooltip("A new NPC; the next click on the map places it");
            if (editor.SelectedCharacter >= 0 && ui.Button("Remove"))
                RemoveCharacter(ref editor, editor.SelectedCharacter);
            if (editor.SelectedCharacter >= 0 && ui.Button(editor.Tool == Tool.PositionPicker ? "[Place on map]" : "Place on map"))
            {
                editor.Tool = Tool.PositionPicker;
                editor.ShowCharacters = true;
            }
            ui.Tooltip("Clicks on the map set the position of the character (on a path: at the time below)");
        }
        using (ui.Row())
        {
            ui.Label("Time of day");
            ui.Slider("pathstep", ref editor.PathStep, 0, PathSteps - 1);
            ui.Label(StepTime(editor.PathStep));
        }
        ui.Tooltip("The characters on the map are shown where they are at this time");
        if (editor.SelectedCharacter >= 0 && characters[editor.SelectedCharacter] is CharacterReference selected)
            _DrawCharacterProperties(ui, ref editor, selected);
    }
}

void _DrawCharacterProperties(Ui ui, ref Editor editor, CharacterReference reference)
{
    var map = editor.Map;
    ui.Note($"Character {editor.SelectedCharacter + 1}");

    // the type: a new type starts with its first character
    var types = List<string>.Create();
    for (var t = 0; t < 4; t += 1)
        types.Add(CharacterTypeName((CharacterType)(uint8)t));
    int type = (int)reference.Type;
    using (ui.Row())
    {
        ui.Label("Type");
        if (ui.ComboBox("chartype", ref type, types))
        {
            editor.BeginChange();
            reference.Type = (CharacterType)(uint8)type;
            reference.CharacterFlags = reference.CharacterFlags & ~CharacterReferenceFlags.TextPopup;
            reference.EventIndex = 0;
            reference.Index = 1;
            if (reference.Type == CharacterType.PartyMember && editor.Names.Party.Keys.Count() > 0)
                reference.Index = (uint32)editor.Names.Party.Keys[0];
            else if (reference.Type == CharacterType.NPC && editor.Names.NPCs.Keys.Count() > 0)
                reference.Index = (uint32)editor.Names.NPCs.Keys[0];
            else if (reference.Type == CharacterType.Monster && editor.Names.MonsterGroups.Keys.Count() > 0)
                reference.Index = (uint32)editor.Names.MonsterGroups.Keys[0];
            else if (reference.Type == CharacterType.MapObject)
                reference.EventIndex = 1;
            _Change(ref editor, reference);
        }
    }

    // who it is: a party member, an NPC, a map text (NPCs with a short text), a monster group or the event of an object
    bool textPopup = reference.Type == CharacterType.NPC && HasFlag(reference, CharacterReferenceFlags.TextPopup);
    using (ui.Row())
    {
        if (reference.Type == CharacterType.MapObject)
        {
            ui.Label("Event");
            var events = List<string>.Create();
            for (var i = 0; i < map.EventList.Count(); i += 1)
                events.Add($"{i + 1:X2}: {map.Events.Get(map.EventList[i]).ToString()}");
            int chosen = (int)reference.EventIndex - 1;
            if (events.Count() > 0 && ui.ComboBox("charevent", ref chosen, events))
            {
                editor.BeginChange();
                reference.EventIndex = (uint32)(chosen + 1);
                reference.Index = 1;
                _Change(ref editor, reference);
            }
            if (events.Count() == 0)
                ui.Note("The map has no events.");
        }
        else if (textPopup)
        {
            // map text 0 is not possible: a character with the number 0 is no character
            ui.Label("Text");
            var texts = List<string>.Create();
            for (var i = 1; i < map.Texts.Count(); i += 1)
                texts.Add($"{i}: {map.Texts[i]}");
            int chosen = (int)reference.Index - 1;
            if (texts.Count() > 0 && ui.ComboBox("chartext", ref chosen, texts))
            {
                editor.BeginChange();
                reference.Index = (uint32)(chosen + 1);
                _Change(ref editor, reference);
            }
            if (texts.Count() == 0)
                ui.Note("The map has no texts.");
        }
        else
        {
            ui.Label(reference.Type == CharacterType.Monster ? "Group" : "Character");
            var names = reference.Type == CharacterType.PartyMember ? editor.Names.Party
                      : reference.Type == CharacterType.NPC ? editor.Names.NPCs : editor.Names.MonsterGroups;
            int chosen = names.Find((int)reference.Index);
            if (ui.ComboBox("charindex", ref chosen, names.Labels) && chosen >= 0)
            {
                editor.BeginChange();
                reference.Index = (uint32)names.Keys[chosen];
                _Change(ref editor, reference);
            }
        }
    }

    using (ui.Columns(2))
    {
        bool monsterLike = reference.Type == CharacterType.Monster || reference.Type == CharacterType.MapObject;
        if (_CharacterFlag(ui, ref editor, ref reference, monsterLike ? "Chases the party" : "Random movement", CharacterReferenceFlags.RandomMovement))
            _Change(ref editor, reference);
        ui.Tooltip(reference.Type == CharacterType.Monster ? "Monsters have one position; this makes them follow the party"
                   : "Characters that move at random have one position, the others a path over the day");
        if (_CharacterFlag(ui, ref editor, ref reference, "Tileset graphic", CharacterReferenceFlags.UseTileset))
            _Change(ref editor, reference);
        ui.Tooltip("The graphic is a tile of the tileset instead of an NPC graphic");
        if (reference.Type == CharacterType.NPC)
        {
            if (_CharacterFlag(ui, ref editor, ref reference, "Short text", CharacterReferenceFlags.TextPopup))
            {
                // the number changes its meaning: an NPC or a map text
                bool text = HasFlag(reference, CharacterReferenceFlags.TextPopup);
                reference.Index = !text && editor.Names.NPCs.Keys.Count() > 0 ? (uint32)editor.Names.NPCs.Keys[0] : (uint32)1;
                _Change(ref editor, reference);
            }
            ui.Tooltip("Shows a text of the map instead of a conversation");
        }
    }

    var travelTypes = List<string>.Create();
    foreach (var name in ["Walk", "Horse", "Raft", "Ship", "Magical disc", "Eagle", "Fly", "Swim", "Witch broom", "Sand lizard", "Sand ship", "Wasp"])
        travelTypes.Add(name);
    int travel = Math.Min(reference.CollisionClass, travelTypes.Count() - 1);
    using (ui.Row())
    {
        ui.Label("Moves like");
        if (ui.ComboBox("chartravel", ref travel, travelTypes))
        {
            editor.BeginChange();
            reference.CollisionClass = travel;
            _Change(ref editor, reference);
        }
    }
    ui.Tooltip("The travel type that decides on which tiles the character can move");

    // the graphic with a preview
    bool tileGraphic = HasFlag(reference, CharacterReferenceFlags.UseTileset);
    int graphicCount = tileGraphic ? editor.CurrentTileset().Tiles.Length : editor.Graphics.NPCGraphicCount(map.NPCGfxIndex);
    using (ui.Row())
    {
        var preview = ui.Area(32, 64);
        ui.FillRect(preview, Color.Black());
        int graphic = (int)reference.GraphicIndex;
        if (tileGraphic && graphic >= 1 && graphic <= graphicCount)
        {
            var tile = Rect.Create(preview.X, preview.Y + preview.Height / 2, preview.Width, preview.Height / 2);
            var tileset = editor.CurrentTileset();
            int animated = AnimatedGraphic(tileset.Tiles[graphic - 1], AnimationFrame(ref editor));
            if (animated >= 0 && animated < editor.Graphics.GraphicCount(map.TilesetOrLabdataIndex))
                ui.DrawImage(editor.Graphics.Atlas(map.TilesetOrLabdataIndex, map.PaletteIndex), GraphicRect(animated), tile);
        }
        else if (!tileGraphic && graphic < graphicCount)
            ui.DrawImage(editor.Graphics.NPCAtlas(map.NPCGfxIndex, map.PaletteIndex), NPCGraphicRect(graphic), preview);
        using (ui.Column(0))
        {
            using (ui.Row())
            {
                ui.Label(tileGraphic ? "Tile" : "Graphic");
                using (ui.Column(90))
                {
                    if (ui.IntBox("chargraphic", ref graphic, tileGraphic ? 1 : 0, Math.Max(tileGraphic ? 1 : 0, graphicCount - (tileGraphic ? 0 : 1))))
                    {
                        editor.BeginChange();
                        reference.GraphicIndex = (uint32)graphic;
                        _Change(ref editor, reference);
                    }
                }
            }
            if (!tileGraphic && graphicCount == 0)
                ui.Note("The map has no NPC graphics.");
            if (reference.Type == CharacterType.Monster)
            {
                int combat = (int)((uint32)reference.TileFlags >> 28);
                using (ui.Row())
                {
                    ui.Label("Combat background");
                    using (ui.Column(70))
                    {
                        if (ui.IntBox("charcombat", ref combat, 0, 15))
                        {
                            editor.BeginChange();
                            reference.TileFlags = (TileFlags)(((uint32)reference.TileFlags & 0x0fffffff) | ((uint32)combat << 28));
                            reference.CombatBackgroundIndex = (uint32)combat;
                            _Change(ref editor, reference);
                        }
                    }
                }
            }
            if (ui.Button("Tile flags..."))
            {
                editor.EditTile = TilesetTile { Flags = reference.TileFlags };
                editor.ShowCharacterFlags = true;
            }
            ui.Tooltip("How the character is drawn and which travel types can pass it");
        }
    }

    // the position, or the position on the path at the time of the day
    int positions = PositionCount(reference);
    int at = PositionIndex(reference, editor.PathStep);
    var position = at < reference.Positions.Count() ? reference.Positions[at] : Position { X = 0, Y = 0 };
    int x = position.X;
    int y = position.Y;
    using (ui.Row())
    {
        ui.Label(positions == 1 ? "X, Y" : $"X, Y at {StepTime(positions == 12 ? at * 24 : at)}");
        bool changed = false;
        using (ui.Column(80)) { changed = ui.IntBox("charx", ref x, 0, map.Width); }
        using (ui.Column(80)) { changed = ui.IntBox("chary", ref y, 0, map.Height) || changed; }
        if (changed)
        {
            editor.BeginChange();
            FitPositions(ref reference);
            reference.Positions[at] = Position { X = x, Y = y };
            _Change(ref editor, reference);
        }
    }
    if (positions > 1)
    {
        ui.Checkbox("Placing sets the following times too", ref editor.PlaceFollowing);
        ui.Note("Path: a position for every 5 minutes (0, 0: away)");
    }
}

/// The tile flags of a character: how it is drawn and which travel types can pass it.
void CharacterFlagsDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("charflags", $"Tile flags of character {editor.SelectedCharacter + 1}"))
    {
        var tile = editor.EditTile;
        TileFlagsEditor(ui, ref tile.Flags);
        using (ui.Row())
        {
            if (ui.Button("Apply") && editor.SelectedCharacter >= 0 &&
                editor.Map.CharacterReferences[editor.SelectedCharacter] is CharacterReference reference)
            {
                editor.BeginChange();
                reference.TileFlags = tile.Flags;
                reference.CombatBackgroundIndex = (uint32)tile.Flags >> 28;
                _Change(ref editor, reference);
                editor.ShowCharacterFlags = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowCharacterFlags = false;
        }
        editor.EditTile = tile;
    }
}
