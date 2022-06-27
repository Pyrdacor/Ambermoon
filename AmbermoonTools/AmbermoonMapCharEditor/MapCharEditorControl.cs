using Ambermoon.Data;
using Ambermoon.Data.Legacy.Characters;

namespace AmbermoonMapCharEditor
{
    // TODO: tile flags, combat background index, gfx index, positions
    // TODO: map load

    public partial class MapCharEditorControl : UserControl
    {
        static readonly List<string> CharTypes = new List<string>
        {
            "Partymember",
            "NPC",
            "Monster",
            "Mapobject"
        };

        public MapCharEditorControl()
        {
            InitializeComponent();

            Visible = false;       
        }

        public void Init(Map map, IGameData gameData)
        {
            this.map = map;
            eventNames = map.EventList.Select(e => TruncString(e.ToString()!, 60)).ToList();
            mapTexts = map.Texts.Select(t => TruncString(t, 60)).ToList();
            var bossMonsters = new List<int>();

            void LoadCharacters(string filename, Dictionary<int, string> targetList, int skipAmount = 0, bool checkBoss = false)
            {
                foreach (var file in gameData.Files[filename].Files.Skip(skipAmount))
                {
                    if (file.Value.Size != 0)
                    {
                        if (checkBoss)
                        {
                            file.Value.Position = 0x12;

                            if ((file.Value.ReadByte() & 0x04) != 0)
                                bossMonsters.Add(file.Key);
                        }

                        file.Value.Position = 0x112;
                        string name = file.Value.ReadString(16).TrimEnd(' ', '\0');
                        targetList.Add(file.Key, name);
                    }
                }
            }

            try
            {
                LoadCharacters("Monster_char.amb", monsters, 0, true);
            }
            catch
            {
                LoadCharacters("Monster_char_data.amb", monsters, 0, true);
            }
            LoadCharacters("Save.00/Party_char.amb", partyMembers, 1);
            LoadCharacters("NPC_char.amb", npcs);

            static string TruncString(string str, int maxLength)
            {
                if (str.Length <= maxLength)
                    return str;

                return str.Substring(0, maxLength - 3) + "...";
            }

            foreach (var monsterGroupFile in gameData.Files["Monster_groups.amb"].Files)
            {
                if (monsterGroupFile.Value.Size != 0)
                {
                    var indices = Enumerable.Range(0, 18).Select(_ => monsterGroupFile.Value.ReadWord()).Where(i => i != 0).ToList();
                    var group = indices.Select(i => monsters[i]).ToList();

                    if (group.Count == 1)
                        monsterGroups.Add(monsterGroupFile.Key, group[0]);
                    else
                    {
                        string name = "";
                        var bosses = indices.Where(i => bossMonsters.Contains(i));

                        if (bosses.Count() == 1)
                        {
                            var boss = bosses.FirstOrDefault();

                            if (boss != 0)
                            {
                                name = monsters[boss];
                                group.Remove(name);
                                name += ",";
                            }
                        }

                        name += string.Join(",", group.GroupBy(g => g).Select(g => new { c = g.Count(), n = g.Key }).Select(g => g.c == 1 ? g.n : $"{g.c}x {g.n}"));
                        monsterGroups.Add(monsterGroupFile.Key, TruncString(name, 60));
                    }
                }
            }

            Visible = true;

            comboBoxCollisionClasses.SelectedIndex = 0;

            var characterList = new CharacterList((type, textPopup) => type switch
            {
                CharacterType.PartyMember => partyMembers.Values,
                CharacterType.NPC => textPopup ? mapTexts : npcs.Values,
                CharacterType.Monster => monsterGroups.Values,
                CharacterType.MapObject => eventNames,
                _ => throw new ArgumentException("Invalid character type")
            }, map);

            characterList.Location = new Point(1, 1);
            characterList.Size = new Size(Width - 2, buttonAdd.Location.Y - 2);
            characterList.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right | AnchorStyles.Bottom;
            characterList.CharacterChanged += CharacterList_CharacterChanged;
            characterList.SelectedIndexChanged += CharacterList_SelectedIndexChanged;
            characterList.RowCountChanged += CharacterList_RowCountChanged;
            this.Controls.Add(characterList);
            this.characterList = characterList;

            if (characterList.Count != 0)
                UpdateCurrentCharacter();

            buttonAdd.Enabled = characterList!.Count < 32;
            buttonRemove.Enabled = characterList.SelectedIndex != -1 && characterList.Count != 0;
            groupBoxCharProperties.Enabled = characterList.Count != 0;
        }

        private void CharacterList_RowCountChanged()
        {
            buttonAdd.Enabled = characterList!.Count < 32;
            buttonRemove.Enabled = characterList.SelectedIndex != -1 && characterList.Count != 0;
            groupBoxCharProperties.Enabled = characterList.Count != 0;
        }

        private void CharacterList_SelectedIndexChanged(int index)
        {
            UpdateCurrentCharacter();
            SelectionChanged?.Invoke(index);
            buttonRemove.Enabled = characterList!.SelectedIndex != -1 && characterList.Count != 0;
        }

        private void CharacterList_CharacterChanged(CharacterRow row)
        {
            var character = map!.CharacterReferences[characterList!.SelectedIndex];

            character.Type = row.CharacterType;
            character.Index = row.CharacterIndex;

            if (character.Type == CharacterType.PartyMember)
                ++character.Index;
            else if (character.Type == CharacterType.MapObject)
            {
                character.EventIndex = character.Index;
                character.Index = 1;
            }
        }

        CharacterList? characterList;
        Map? map;
        readonly Dictionary<int, string> monsters = new();
        readonly Dictionary<int, string> monsterGroups = new();
        readonly Dictionary<int, string> partyMembers = new();
        readonly Dictionary<int, string> npcs = new();
        List<string> eventNames = new List<string>();
        List<string> mapTexts = new List<string>();

        public event Action<int>? SelectionChanged;

        void UpdateCurrentCharacter(Map.CharacterReference? character = null)
        {
            character ??= map!.CharacterReferences[characterList!.SelectedIndex];

            checkBoxRandomMovement.Checked = character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.RandomMovement);
            checkBoxUseTileset.Checked = character.Type != CharacterType.Monster &&
                character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.UseTileset);
            checkBoxTextPopup.Checked = character.Type == CharacterType.NPC &&
                character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.TextPopup);
            checkBoxStationary.Checked = character.Type != CharacterType.Monster &&
                character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.Stationary);
            checkBoxOnlyMoveWhenSeePlayer.Checked = character.Type == CharacterType.Monster &&
                character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.MoveOnlyWhenSeePlayer);

            checkBoxUseTileset.Enabled = character.Type != CharacterType.Monster;
            checkBoxTextPopup.Enabled = character.Type == CharacterType.NPC;
            checkBoxStationary.Enabled = character.Type != CharacterType.Monster;
            checkBoxOnlyMoveWhenSeePlayer.Enabled = character.Type == CharacterType.Monster;
            ignoreCollisionClassComboBoxChange = true;
            comboBoxCollisionClasses.SelectedIndex = character.CollisionClass;
            ignoreCollisionClassComboBoxChange = false;
        }

        private void checkBoxStationary_CheckedChanged(object sender, EventArgs e)
        {
            if (checkBoxStationary.Checked)
                checkBoxRandomMovement.Checked = false;

            var character = map!.CharacterReferences[characterList!.SelectedIndex];

            SetCharacterFlag(character, Map.CharacterReference.Flags.Stationary, checkBoxStationary.Checked);
        }

        private void checkBoxRandomMovement_CheckedChanged(object sender, EventArgs e)
        {
            if (checkBoxRandomMovement.Checked)
                checkBoxStationary.Checked = false;

            var character = map!.CharacterReferences[characterList!.SelectedIndex];

            SetCharacterFlag(character, Map.CharacterReference.Flags.RandomMovement, checkBoxRandomMovement.Checked);
        }

        bool ignoreCollisionClassComboBoxChange = false;

        private void comboBoxCollisionClasses_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (characterList == null || ignoreCollisionClassComboBoxChange)
                return;

            var character = map!.CharacterReferences[characterList!.SelectedIndex];

            character.CollisionClass = comboBoxCollisionClasses.SelectedIndex;
        }

        void SetCharacterFlag(Map.CharacterReference character, Map.CharacterReference.Flags flag, bool value)
        {
            if (value)
                character.CharacterFlags |= flag;
            else
                character.CharacterFlags &= ~flag;
        }

        private void checkBoxUseTileset_CheckedChanged(object sender, EventArgs e)
        {
            var character = map!.CharacterReferences[characterList!.SelectedIndex];

            SetCharacterFlag(character, Map.CharacterReference.Flags.UseTileset, checkBoxUseTileset.Checked);
        }

        private void checkBoxTextPopup_CheckedChanged(object sender, EventArgs e)
        {
            var character = map!.CharacterReferences[characterList!.SelectedIndex];

            SetCharacterFlag(character, Map.CharacterReference.Flags.TextPopup, checkBoxTextPopup.Checked);

            characterList.ChangeTextPopupFlag(checkBoxTextPopup.Checked);
        }

        private void checkBoxOnlyMoveWhenSeePlayer_CheckedChanged(object sender, EventArgs e)
        {
            var character = map!.CharacterReferences[characterList!.SelectedIndex];

            SetCharacterFlag(character, Map.CharacterReference.Flags.MoveOnlyWhenSeePlayer, checkBoxOnlyMoveWhenSeePlayer.Checked);
        }

        private void buttonAdd_Click(object sender, EventArgs e)
        {
            map!.CharacterReferences[characterList!.Count] ??= new Map.CharacterReference
            {
                Index = (uint)characterList.Count,
                Type = CharacterType.PartyMember,
                // Positions = new ...
            };
            characterList.Add();
        }

        private void buttonRemove_Click(object sender, EventArgs e)
        {
            if (characterList!.SelectedIndex != -1 && characterList.Count != 0)
                characterList.Remove(characterList.SelectedIndex);
        }
    }
}