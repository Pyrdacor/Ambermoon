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
            get => (uint)comboBoxCharacter.SelectedIndex + 1;
            set => comboBoxCharacter.SelectedIndex = (int)value - 1;
        }

        readonly Func<CharacterType, bool, ICollection<string>> descriptionProvider;

        public event Action<CharacterRow>? CharacterChanged;
        public event Action<int>? Selected;

        bool ignoreTypeComboBoxEvent = false;

        public void Unselect()
        {
            BackColor = SystemColors.Control;
        }

        public CharacterRow(int index, Func<CharacterType, bool, ICollection<string>> descriptionProvider, CharacterType characterType = CharacterType.PartyMember,
            uint? characterIndex = null, bool textPopup = false)
        {
            InitializeComponent();

            Index = index;
            CharacterType = characterType;
            TextPopup = textPopup;
            this.descriptionProvider = descriptionProvider;

            InitCharacterType();

            CharacterIndex = characterIndex ?? 1;

            ignoreTypeComboBoxEvent = true;
            comboBoxType.SelectedIndex = (int)CharacterType;
            ignoreTypeComboBoxEvent = false;
        }

        private void comboBoxType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ignoreTypeComboBoxEvent)
                return;

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
            SelectRow();
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

        public void SelectRow()
        {
            BackColor = Color.FromArgb(224, 255, 208);
            Selected?.Invoke(Index);
        }

        const int WM_PARENTNOTIFY = 0x0210;
        const int WM_LBUTTONDOWN = 0x0201;

        protected override void WndProc(ref Message m)
        {
            if (m.Msg == WM_PARENTNOTIFY && m.WParam.ToInt32() == WM_LBUTTONDOWN)
            {
                SelectRow();
            }

            base.WndProc(ref m);
        }
    }
}
