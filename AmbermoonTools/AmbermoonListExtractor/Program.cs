using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Characters;
using Ambermoon.Data.Legacy.Serialization;

namespace AmbermoonListExtractor
{
    internal class Program
    {
        static void Main(string[] args)
        {
            bool advanced = args.Length > 2 && args[2] == "1";
            var gameData = new GameData();
            gameData.Load(args[0]);

            IFileContainer container;
            string text = "";
            string filename = "";
            int columnCount = 0;

            void Put(string line = "", bool newline = true)
            {
                text += line;

                if (newline)
                    text += "\n";
            }

            void Start(string inFile, string file, string header)
            {
                container = gameData.Files[inFile];
                filename = file;
                text = "";
                Put($"# {header}");
            }

            void StartTable(params string[] columns)
            {
                columnCount = columns.Length;
                Put(string.Join(" | ", columns));
                Put(string.Join(" | ", Enumerable.Repeat("---", columnCount)));
            }

            static string GetFlagsText<TEnum>(TEnum flags, int bytes) where TEnum : Enum
            {
                int bits = bytes * 8;
                var values = Enum.GetValues(typeof(TEnum)).Cast<TEnum>().ToArray();
                var names = Enum.GetNames(typeof(TEnum)).Select((n, i) => new { n, i }).ToDictionary(x => values[x.i], x => x.n);
                string format = $"x{bytes * 2}";
                uint flagValue;
                if (bytes == 1)
                    flagValue = (byte)Convert.ChangeType(flags, typeof(byte));
                else if (bytes == 2)
                    flagValue = (ushort)Convert.ChangeType(flags, typeof(ushort));
                else if (bytes == 4)
                    flagValue = (uint)Convert.ChangeType(flags, typeof(uint));
                else
                    throw new NotSupportedException("Unsupported flag enum size.");
                string text = "";

                void Add(string name)
                {
                    if (text.Length == 0)
                        text = name;
                    else
                        text += " <br />" + name;
                }

                for (int i = 0; i < bits; ++i)
                {
                    uint mask = 1u << i;

                    if ((flagValue & mask) == 0)
                        continue;

                    TEnum value = default(TEnum)!;

                     if (bytes == 1)
                        value = (TEnum)Enum.ToObject(typeof(TEnum), (byte)mask);
                    else if (bytes == 2)
                        value = (TEnum)Enum.ToObject(typeof(TEnum), (ushort)mask);
                    else if (bytes == 4)
                        value = (TEnum)Enum.ToObject(typeof(TEnum), mask);

                    if (names.TryGetValue(value, out var name))
                        Add(name);
                    else if (!char.IsDigit(value.ToString()[0]))
                        Add(value.ToString());
                    else
                        Add($"UnknownFlag{value.ToString(format)}");
                }

                if (text.Length == 0)
                    text = "None";

                return text;

            }

            void End()
            {
                Put();
                File.WriteAllText(Path.Combine(args[1], filename), text);
            }

            const int GoldWeight = 5;
            int FootWeight = advanced ? 25 : 250;

            Start("Save.00/Party_char.amb", "PartyMembers.md", "Party members");
            var partyMemberReader = new PartyMemberReader();
            var dummyPartyTextReader = new DataReader(new byte[2]);
            int index = 0;
            foreach (var file in container.Files)
            {
                var partyMember = new PartyMember();
                dummyPartyTextReader.Position = 0;
                partyMemberReader.ReadPartyMember(partyMember, file.Value, dummyPartyTextReader);

                Put();
                Put($"## {partyMember.Name}");
                Put();
                Put($"![{partyMember.Name} Portrait](../Graphics/Portraits/{partyMember.PortraitIndex:000}.png)");
                Put();

                StartTable("Property", "Value", "Property", "Value");

                void AddColumn(string name, object value)
                {
                    if (index % 2 == 1)
                        Put(" | ", false);
                    Put($"{name} | {value}", index % 2 == 1);
                    ++index;
                }

                AddColumn("Race", partyMember.Race);
                AddColumn("Gender", partyMember.Gender);
                
                AddColumn("Class", partyMember.Class);
                AddColumn("Level", partyMember.Level);

                AddColumn("Spell Types", GetFlagsText(partyMember.SpellMastery, 1));
                AddColumn("Languages", GetFlagsText(partyMember.SpokenLanguages, 1));

                AddColumn("Occupied hands", partyMember.NumberOfFreeHands);
                AddColumn("Occupied fingers", partyMember.NumberOfFreeFingers);

                AddColumn("APR", partyMember.AttacksPerRound);
                AddColumn("Increase Levels", partyMember.AttacksPerRoundIncreaseLevels);

                AddColumn("HP", $"{partyMember.HitPoints.CurrentValue}/{partyMember.HitPoints.MaxValue} (+{partyMember.HitPoints.BonusValue})");
                AddColumn("Per Level", partyMember.HitPointsPerLevel);

                AddColumn("SP", $"{partyMember.SpellPoints.CurrentValue}/{partyMember.SpellPoints.MaxValue} (+{partyMember.SpellPoints.BonusValue})");
                AddColumn("Per Level", partyMember.SpellPointsPerLevel);

                AddColumn("SLP", partyMember.SpellLearningPoints);
                AddColumn("Per Level", partyMember.SpellLearningPointsPerLevel);

                AddColumn("TP", partyMember.TrainingPoints);
                AddColumn("Per Level", partyMember.TrainingPointsPerLevel);

                for (byte i = 0; i < 10; ++i)
                {
                    var attr = partyMember.Attributes[(Ambermoon.Data.Attribute)i];
                    var skill = partyMember.Skills[(Skill)i];

                    string attrName = i < 9 || advanced ? $"{(Ambermoon.Data.Attribute)i}" : "Unused";

                    AddColumn(attrName, $"{attr.CurrentValue:000}/{attr.MaxValue:000} (+{attr.BonusValue:000})");
                    AddColumn($"{(Skill)i}", $"{skill.CurrentValue:00}%/{skill.MaxValue:00}% (+{skill.BonusValue:00}%)");
                }

                AddColumn("Gold", partyMember.Gold);
                AddColumn("Food", partyMember.Food);

                string spells = "";
                if (partyMember.SpellMastery != SpellTypeMastery.None && partyMember.LearnedSpells.Count != 0)
                {
                    var mask = SpellTypeMastery.Healing | SpellTypeMastery.Alchemistic | SpellTypeMastery.Mystic | SpellTypeMastery.Destruction;
                    int offset = (partyMember.SpellMastery & mask) switch
                    {
                        SpellTypeMastery.Healing => 0,
                        SpellTypeMastery.Alchemistic => 30,
                        SpellTypeMastery.Mystic => 60,
                        SpellTypeMastery.Destruction => 90,
                        _ => throw new NotSupportedException("Spell type not supported")
                    };

                    int spellIndex = 0;

                    void AddSpell(Spell spell)
                    {
                        spells += $"{spell},";

                        if (spellIndex % 2 == 1)
                            spells += " <br />";
                        else
                            spells += " ";

                        ++spellIndex;
                    }

                    for (int i = 1; i <= 30; ++i)
                    {
                        var spell = (Spell)(offset + i);
                        if (partyMember.LearnedSpells.Contains(spell))
                            AddSpell(spell);
                    }
                }
                if (spells.Length == 0)
                    spells = "-";
                else if (spells.EndsWith(", "))
                    spells = spells[0..^2];
                else
                    spells = spells[0..^8];
                AddColumn("Learned Spells", spells);
                string equip = "";
                for (int i = 1; i <= 9; ++i)
                {
                    var slotId = (EquipmentSlot)i;
                    var slot = partyMember.Equipment.Slots[slotId];

                    if (slot != null && slot.Amount != 0 && slot.ItemIndex != 0)
                    {
                        equip += $"{slotId}: {gameData.ItemManager.GetItem(slot.ItemIndex).Name} <br />";
                    }
                }
                if (equip.Length == 0)
                    equip = "-";
                else
                    equip = equip[0..^6];
                AddColumn("Equipment", equip);

                var calculatedWeight = partyMember.Equipment.Slots.Sum(s => s.Value.ItemIndex == 0 || s.Value.Amount == 0 ? 0u : gameData.ItemManager.GetItem(s.Value.ItemIndex).Weight);
                calculatedWeight += partyMember.Inventory.Slots.Sum(s => s.ItemIndex == 0 || s.Amount == 0 ? 0u : s.Amount * gameData.ItemManager.GetItem(s.ItemIndex).Weight);
                calculatedWeight += partyMember.Gold * GoldWeight;
                calculatedWeight += partyMember.Food * FootWeight;
                AddColumn("Total Weight", partyMember.TotalWeight);
                AddColumn("Calc Weight", calculatedWeight);

                if (partyMember.TotalWeight != calculatedWeight)
                    throw new Exception("Wrong weight value for party member " + partyMember.Name);

                if (partyMember.CharacterBitIndex != 0xffff)
                {
                    var map = gameData.MapManager.GetMap(1u + partyMember.CharacterBitIndex / 32u);
                    AddColumn("Spawns at map", map.Name);
                    var pos = map.CharacterReferences[partyMember.CharacterBitIndex % 32].Positions[0];
                    AddColumn($"X: {pos.X}", $"Y: {pos.Y}");
                }
            }
            End();
        }
    }
}