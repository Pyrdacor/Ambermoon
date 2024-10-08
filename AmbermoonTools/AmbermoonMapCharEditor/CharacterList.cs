﻿using Ambermoon.Data;

namespace AmbermoonMapCharEditor
{
    public partial class CharacterList : UserControl
    {
        readonly List<CharacterRow> characterRows = new List<CharacterRow>();
        readonly List<Map.CharacterReference> characters = new List<Map.CharacterReference>();
        Func<CharacterType, bool, Dictionary<int, string>>? descriptionProvider;

        public int Count => characterRows.Count;

        public int SelectedIndex
        {
            get;
            set;
        } = -1;

        public event Action? RowCountChanged;
        public event Action<CharacterRow>? CharacterChanged;
        public event Action<int>? SelectedIndexChanged;

        public CharacterList(Func<CharacterType, bool, Dictionary<int, string>> descriptionProvider, Map map)
        {
            InitializeComponent();

            SetMap(descriptionProvider, map);
        }

        public void SetMap(Func<CharacterType, bool, Dictionary<int, string>> descriptionProvider, Map map)
        {
            this.descriptionProvider = descriptionProvider;

            panel1.Controls.Clear();
            characterRows.Clear();
            characters.Clear();
            characters.AddRange(map.CharacterReferences.ToList());
            SelectedIndex = -1;

            int index = 0;

            foreach (var character in characters)
            {
                if (character == null)
                    continue;

                bool textPopup = character.Type == CharacterType.NPC && character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.TextPopup);
                var characterRow = new CharacterRow(index, descriptionProvider, character.Type, character.Index, textPopup);
                panel1.Controls.Add(characterRow);
                characterRows.Add(characterRow);
                characterRow.Location = new Point(panel1.AutoScrollPosition.X, panel1.AutoScrollPosition.Y + characterRow.Height * index);
                characterRow.CharacterChanged += CharacterRow_CharacterChanged;
                characterRow.Selected += CharacterRow_Selected;
                ++index;
            }

            if (characterRows.Count != 0)
            {
                characterRows[0].SelectRow();
            }
            else
            {
                SelectedIndexChanged?.Invoke(-1);
            }
        }

        private void CharacterRow_Selected(int index)
        {
            if (SelectedIndex != -1 && SelectedIndex != index)
                characterRows[SelectedIndex].Unselect();
            SelectedIndex = index;
            SelectedIndexChanged?.Invoke(index);
        }

        private void CharacterRow_CharacterChanged(CharacterRow row)
        {
            CharacterChanged?.Invoke(row);
        }

        public void Add()
        {
            int index = characterRows.Count;
            var characterRow = new CharacterRow(index, descriptionProvider!);
            panel1.Controls.Add(characterRow);
            characterRows.Add(characterRow);
            characterRow.Location = new Point(panel1.AutoScrollPosition.X, panel1.AutoScrollPosition.Y + characterRow.Height * index);
            characterRow.CharacterChanged += CharacterRow_CharacterChanged;
            characterRow.Selected += CharacterRow_Selected;

            panel1.ScrollControlIntoView(characterRow);

            RowCountChanged?.Invoke();

            if (SelectedIndex != -1)
                characterRows[SelectedIndex].Unselect();

            SelectedIndex = index;
            characterRows[SelectedIndex].SelectRow();
            SelectedIndexChanged?.Invoke(index);
        }

        public void Remove(int index)
        {
            int height = characterRows[0].Height;

            for (int i = index + 1; i < characterRows.Count; ++i)
            {
                --characterRows[i].Index;
                characterRows[i].Location = new Point(characterRows[i].Location.X, characterRows[i].Location.Y - height);
            }

            var row = characterRows[index];
            row.CharacterChanged -= CharacterRow_CharacterChanged;
            row.Selected -= CharacterRow_Selected;
            characterRows.Remove(row);
            panel1.Controls.Remove(row);

            RowCountChanged?.Invoke();

            if (index == SelectedIndex && characterRows.Count != 0)
            {
                SelectedIndex = Math.Max(0, index - 1);
                characterRows[SelectedIndex].SelectRow();
                SelectedIndexChanged?.Invoke(SelectedIndex);
            }
        }

        public void ChangeTextPopupFlag(bool textPopup)
        {
            if (SelectedIndex != -1 && characterRows.Count != 0)
                characterRows[SelectedIndex].ChangeTextPopupFlag(textPopup);
        }
    }
}
