using Ambermoon.Data;

namespace AmbermoonMapCharEditor
{
    public partial class CharacterList : UserControl
    {
        readonly List<CharacterRow> characterRows = new List<CharacterRow>();
        readonly List<Map.CharacterReference> characters= new List<Map.CharacterReference>();
        readonly Func<CharacterType, bool, ICollection<string>> descriptionProvider;

        public int Count => characterRows.Count;

        public int SelectedIndex
        {
            get;
            set;
        } = -1;

        public event Action? RowCountChanged;
        public event Action<CharacterRow>? CharacterChanged;
        public event Action<int>? SelectedIndexChanged;

        public CharacterList(Func<CharacterType, bool, ICollection<string>> descriptionProvider, Map map)
        {
            InitializeComponent();

            this.descriptionProvider = descriptionProvider;

            characters = map.CharacterReferences.ToList();

            int index = 0;

            foreach (var character in characters)
            {
                bool textPopup = character.Type == CharacterType.NPC && character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.TextPopup);
                var characterRow = new CharacterRow(index, descriptionProvider, character.Type, character.Index, textPopup);
                characterRow.Location = new Point(0, characterRow.Height * index);
                panel1.Controls.Add(characterRow);
                characterRows.Add(characterRow);
                characterRow.CharacterChanged += CharacterRow_CharacterChanged;
                characterRow.Selected += CharacterRow_Selected;
                ++index;
            }

            if (characterRows.Count != 0)
            {
                SelectedIndex = 0;
                SelectedIndexChanged?.Invoke(0);
            }
        }

        private void CharacterRow_Selected(int index)
        {
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
            var characterRow = new CharacterRow(index, descriptionProvider);
            characterRow.Location = new Point(0, characterRow.Height * index);
            panel1.Controls.Add(characterRow);
            characterRows.Add(characterRow);
            characterRow.CharacterChanged += CharacterRow_CharacterChanged;
            characterRow.Selected += CharacterRow_Selected;

            panel1.ScrollControlIntoView(characterRow);

            RowCountChanged?.Invoke();

            SelectedIndex = index;
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
