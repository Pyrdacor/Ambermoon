//! AmbermoonListExtractor: writes the party members of the game as a Markdown table (PartyMembers.md) (a port of
//! AmbermoonTools/AmbermoonListExtractor).
//!
//!   AmbermoonListExtractor <game data folder> <output folder> [1 for Ambermoon Advanced]
namespace AmbermoonListExtractor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Characters;
using Ambermoon.Data.Legacy.ExecutableData;
using Ambermoon.Data.Legacy.Serialization;

// the text of the file being written
StringBuilder Text = StringBuilder.Create();
// the columns written so far (two pairs of property and value per row)
int ColumnIndex = 0;

void Put(string line, bool newline)
{
    Text.Append(line);
    if (newline)
        Text.Append("\n");
}

void Put(string line)
{
    Put(line, true);
}

void Put()
{
    Put("", true);
}

void StartTable(ReadOnlySlice<string> columns)
{
    var header = StringBuilder.Create();
    var separator = StringBuilder.Create();
    for (var i = 0; i < columns.Length; i += 1)
    {
        if (i > 0)
        {
            header.Append(" | ");
            separator.Append(" | ");
        }
        header.Append(columns[i]);
        separator.Append("---");
    }
    Put(header.ToString());
    Put(separator.ToString());
}

void AddColumn(string name, string value)
{
    if (ColumnIndex % 2 == 1)
        Put(" | ", false);
    Put($"{name} | {value}", ColumnIndex % 2 == 1);
    ColumnIndex += 1;
}

// the names of the flags that are set, separated by " <br />" ("None" if none is)
string GetFlagsText<T>(T flags, int bytes)
{
    var info = EnumInfo.Of<T>(true);
    uint64 value = EnumInfo.ToUnsigned((int64)flags, sizeof(T));
    var text = StringBuilder.Create();

    for (var i = 0; i < bytes * 8; i += 1)
    {
        uint64 mask = (uint64)1 << i;
        if ((value & mask) == 0)
            continue;
        if (text.Length() != 0)
            text.Append(" <br />");
        if (info.GetName(mask) is string name)
            text.Append(name);
        else
            text.Append("UnknownFlag" + mask.ToString("x" + (bytes * 2).ToString()));
    }

    return text.Length() == 0 ? "None" : text.ToString();
}

int Fail(string message)
{
    Console.WriteLine(message);
    return 1;
}

int Main(string[] args)
{
    if (args.Length < 2)
        return Fail("Usage: AmbermoonListExtractor <game data folder> <output folder> [1 for Ambermoon Advanced]");

    bool advanced = args.Length > 2 && args[2] == "1";
    var gameData = GameData.Create();
    if (gameData.Load(args[0]) is error loadError)
        return Fail(loadError.Message);

    var executableData = ExecutableData.FromGameData(gameData);
    if (executableData is error exeError)
        return Fail(exeError.Message);
    if (executableData is not ExecutableData exe)
        return 1;
    if (exe.ItemManager is not ItemManager itemManager)
        return Fail("[Data] Incomplete game data. AM2_CPU is missing.");
    var maps = MapManager.Create(gameData);
    if (maps is error mapError)
        return Fail(mapError.Message);
    if (maps is not MapManager mapManager)
        return 1;

    uint32 foodWeight = advanced ? (uint32)25 : 250;

    if (gameData.Files.TryGet("Save.00/Party_char.amb") is not FileContainer container)
        return Fail("The given key 'Save.00/Party_char.amb' was not present in the dictionary.");
    Put("# Party members");

    foreach (var number in container.Numbers())
    {
        var reader = container.Files[number];
        var read = CharacterReader.ReadPartyMember((uint32)number, ref reader, DataReader.FromData(new uint8[2]));
        if (read is error readError)
            return Fail(readError.Message);
        if (read is not Character member)
            return 1;

        Put();
        Put($"## {member.Name}");
        Put();
        Put($"![{member.Name} Portrait](../Graphics/Portraits/{member.PortraitIndex.ToString("D3")}.png)");
        Put();

        StartTable(["Property", "Value", "Property", "Value"]);

        AddColumn("Race", EnumText(member.Race, false));
        AddColumn("Gender", EnumText(member.Gender, false));

        AddColumn("Class", EnumText(member.Class, false));
        AddColumn("Level", member.Level.ToString());

        AddColumn("Spell Types", GetFlagsText(member.SpellMastery, 1));
        AddColumn("Languages", GetFlagsText(member.SpokenLanguages, 1));

        AddColumn("Occupied hands", member.NumberOfOccupiedHands.ToString());
        AddColumn("Occupied fingers", member.NumberOfOccupiedFingers.ToString());

        AddColumn("APR", member.AttacksPerRound.ToString());
        AddColumn("Increase Levels", member.AttacksPerRoundIncreaseLevels.ToString());

        var hp = member.HitPoints;
        AddColumn("HP", $"{hp.CurrentValue}/{hp.MaxValue} (+{hp.BonusValue})");
        AddColumn("Per Level", member.HitPointsPerLevel.ToString());

        var sp = member.SpellPoints;
        AddColumn("SP", $"{sp.CurrentValue}/{sp.MaxValue} (+{sp.BonusValue})");
        AddColumn("Per Level", member.SpellPointsPerLevel.ToString());

        AddColumn("SLP", member.SpellLearningPoints.ToString());
        AddColumn("Per Level", member.SpellLearningPointsPerLevel.ToString());

        AddColumn("TP", member.TrainingPoints.ToString());
        AddColumn("Per Level", member.TrainingPointsPerLevel.ToString());

        for (var i = 0; i < 10; i += 1)
        {
            var attribute = member.Attributes[i];
            var skill = member.Skills[i];
            string attributeName = i < 9 || advanced ? EnumText((Ambermoon.Data.Attribute)i, false) : "Unused";

            AddColumn(attributeName, $"{_Number(attribute.CurrentValue, 3)}/{_Number(attribute.MaxValue, 3)} (+{_Number(attribute.BonusValue, 3)})");
            AddColumn(EnumText((Skill)i, false), $"{_Number(skill.CurrentValue, 2)}%/{_Number(skill.MaxValue, 2)}% (+{_Number(skill.BonusValue, 2)}%)");
        }

        AddColumn("Gold", member.Gold.ToString());
        AddColumn("Food", member.Food.ToString());

        var spells = StringBuilder.Create();
        var learned = member.LearnedSpells();
        if (member.SpellMastery != SpellTypeMastery.None && learned.Count() != 0)
        {
            var mask = SpellTypeMastery.Healing | SpellTypeMastery.Alchemistic | SpellTypeMastery.Mystic | SpellTypeMastery.Destruction;
            int offset;
            switch (member.SpellMastery & mask)
            {
                case SpellTypeMastery.Healing: offset = 0; break;
                case SpellTypeMastery.Alchemistic: offset = 30; break;
                case SpellTypeMastery.Mystic: offset = 60; break;
                case SpellTypeMastery.Destruction: offset = 90; break;
                default: return Fail("Spell type not supported");
            }

            int spellIndex = 0;
            for (var i = 1; i <= 30; i += 1)
            {
                var spell = (Spell)(offset + i);
                if (!learned.Contains(spell))
                    continue;
                spells.Append(EnumText(spell, false) + ",");
                spells.Append(spellIndex % 2 == 1 ? " <br />" : " ");
                spellIndex += 1;
            }
        }
        string spellText = spells.ToString();
        if (spellText.Length == 0)
            spellText = "-";
        else if (spellText.EndsWith(", "))
            spellText = spellText[0..spellText.Length - 2].ToString();
        else
            spellText = spellText[0..spellText.Length - 8].ToString();
        AddColumn("Learned Spells", spellText);

        var equip = StringBuilder.Create();
        for (var i = 1; i <= 9; i += 1)
        {
            var slot = member.Equipment[i];
            if (slot.Amount != 0 && slot.ItemIndex != 0)
                equip.Append($"{EnumText((EquipmentSlot)i, false)}: {itemManager.GetItem(slot.ItemIndex).Name} <br />");
        }
        string equipText = equip.ToString();
        equipText = equipText.Length == 0 ? "-" : equipText[0..equipText.Length - 6].ToString();
        AddColumn("Equipment", equipText);

        uint32 calculatedWeight = 0;
        for (var i = 1; i <= 9; i += 1)
        {
            var slot = member.Equipment[i];
            if (slot.ItemIndex != 0 && slot.Amount != 0)
                calculatedWeight += itemManager.GetItem(slot.ItemIndex).Weight;
        }
        foreach (var slot in member.Inventory)
        {
            if (slot.ItemIndex != 0 && slot.Amount != 0)
                calculatedWeight += (uint32)slot.Amount * itemManager.GetItem(slot.ItemIndex).Weight;
        }
        calculatedWeight += member.Gold * GoldWeight;
        calculatedWeight += member.Food * foodWeight;
        AddColumn("Total Weight", member.TotalWeight.ToString());
        AddColumn("Calc Weight", calculatedWeight.ToString());

        if (member.TotalWeight != calculatedWeight)
            return Fail("Wrong weight value for party member " + member.Name);

        if (member.CharacterBitIndex != 0xffff)
        {
            var found = mapManager.GetMap(1 + (uint32)member.CharacterBitIndex / 32);
            if (found is error e)
                return Fail(e.Message);
            if (found is not Optional<Map> optional)
                return 1;
            if (optional is not Map map)
                return Fail($"There is no map {1 + member.CharacterBitIndex / 32}.");
            AddColumn("Spawns at map", map.Name());
            if (map.CharacterReferences[member.CharacterBitIndex % 32] is not CharacterReference reference)
                return Fail($"There is no character {member.CharacterBitIndex % 32} on map {map.Index}.");
            var position = reference.Positions[0];
            AddColumn($"X: {position.X}", $"Y: {position.Y}");
        }
    }

    Put();
    var path = Path.Combine(args[1], "PartyMembers.md");
    if (File.WriteAllBytes(path, Text.ToString().AsBytes()) is error)
        return Fail($"Could not write file '{path}'.");
    return 0;
}

// a number with at least 'digits' digits (the format "000"; negative numbers with '-' in front)
string _Number(int64 value, int digits)
{
    if (value < 0)
        return "-" + (-value).ToString("D" + digits.ToString());
    return value.ToString("D" + digits.ToString());
}
