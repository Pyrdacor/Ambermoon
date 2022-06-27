using Ambermoon.Data;

namespace AmbermoonMapCharEditor
{
    public partial class CharacterRow : UserControl
    {
        public int Index { get; set; }

        public CharacterType CharacterType { get; set; }

        public bool TextPopup { get; set; }

        public uint CharacterIndex
        {
            get => (uint)comboBoxCharacter.SelectedIndex;
            set => comboBoxCharacter.SelectedIndex = (int)value;
        }

        readonly Func<CharacterType, bool, ICollection<string>> descriptionProvider;

        public event Action<CharacterRow>? CharacterChanged;
        public event Action<int>? Selected;

        public CharacterRow(int index, Func<CharacterType, bool, ICollection<string>> descriptionProvider, CharacterType characterType = CharacterType.PartyMember,
            uint? characterIndex = null, bool textPopup = false)
        {
            InitializeComponent();

            Index = index;
            CharacterType = characterType;
            TextPopup = textPopup;
            this.descriptionProvider = descriptionProvider;

            InitCharacterType();

            CharacterIndex = characterIndex ?? 0;
        }

        private void comboBoxType_SelectedIndexChanged(object sender, EventArgs e)
        {
            CharacterType = (CharacterType)comboBoxType.SelectedIndex;

            InitCharacterType();

            CharacterChanged?.Invoke(this);
        }

        void InitCharacterType()
        {
            var descriptions = descriptionProvider(CharacterType, TextPopup);
            comboBoxCharacter.Items.Clear();

            foreach (var description in descriptions)
                comboBoxCharacter.Items.Add(description);

            comboBoxCharacter.SelectedIndex = 0;
        }

        private void comboBoxCharacter_SelectedIndexChanged(object sender, EventArgs e)
        {
            CharacterChanged?.Invoke(this);
        }

        private void CharacterRow_Click(object sender, EventArgs e)
        {
            Selected?.Invoke(Index);
        }

        private void comboBoxType_Click(object sender, EventArgs e)
        {
            Selected?.Invoke(Index);
        }

        private void comboBoxCharacter_Click(object sender, EventArgs e)
        {
            Selected?.Invoke(Index);
        }

        public void ChangeTextPopupFlag(bool textPopup)
        {
            bool oldValue = TextPopup;
            TextPopup = textPopup && CharacterType == CharacterType.NPC;

            if (oldValue != TextPopup)
            {
                InitCharacterType();
            }
        }
    }
}
