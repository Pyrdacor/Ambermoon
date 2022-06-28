using Ambermoon.Data;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows.Forms.VisualStyles;

namespace AmbermoonMapCharEditor
{
    public partial class CharacterRow : UserControl
    {
        static string TruncString(string str, int maxLength)
        {
            if (str.Length <= maxLength)
                return str;

            return str.Substring(0, maxLength - 3) + "...";
        }

        record IndexedItem(int Index, string Name)
        {
            public override string ToString()
            {
                return TruncString(Name, 28);
            }
        }

        public int Index { get; set; }

        public CharacterType CharacterType { get; set; }

        public bool TextPopup { get; set; }

        public uint CharacterIndex
        {
            get => comboBoxCharacter.Items.Count == 0 ? 0u : (uint)((IndexedItem)comboBoxCharacter.SelectedItem).Index;
            set
            {
                if (comboBoxCharacter.Items.Count != 0) // map texts might be empty
                    comboBoxCharacter.SelectedIndex = comboBoxCharacter.Items.IndexOf(comboBoxCharacter.Items.OfType<IndexedItem>().FirstOrDefault(i => i.Index == value));
            }
        }

        readonly Func<CharacterType, bool, Dictionary<int, string>> descriptionProvider;

        public event Action<CharacterRow>? CharacterChanged;
        public event Action<int>? Selected;

        bool ignoreTypeComboBoxEvent = false;

        public void Unselect()
        {
            BackColor = SystemColors.Control;
        }

        public CharacterRow(int index, Func<CharacterType, bool, Dictionary<int, string>> descriptionProvider, CharacterType characterType = CharacterType.NPC,
            uint? characterIndex = null, bool textPopup = false)
        {
            InitializeComponent();

            Index = index;
            CharacterType = characterType;
            TextPopup = textPopup;
            this.descriptionProvider = descriptionProvider;

            InitCharacterType();

            CharacterIndex = characterIndex ?? (characterType switch
            {
                CharacterType.PartyMember => 2u,
                CharacterType.NPC => TextPopup ? 0u : 1u,
                _ => 1u
            });

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
                comboBoxCharacter.Items.Add(new IndexedItem(description.Key, description.Value));

            if (comboBoxCharacter.Items.Count != 0) // map texts might be empty
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
            BackColor = Color.FromArgb(255, 224, 128);
            Selected?.Invoke(Index);
        }

        private void label1_Click(object sender, EventArgs e)
        {
            SelectRow();
        }

        const int WM_PARENTNOTIFY = 0x0210;
        const int WM_LBUTTONDOWN = 0x0201;

        private void comboBoxCharacter_DropDownClosed(object sender, EventArgs e)
        {
            toolTipCharacter.Hide(comboBoxCharacter);
        }

        private void CharacterRow_Load(object sender, EventArgs e)
        {
            comboBoxCharacter.DrawMode = DrawMode.OwnerDrawFixed;
        }

        private void comboBoxCharacter_DrawItem(object sender, DrawItemEventArgs e)
        {
            if (e.Index < 0)
                return;

            string text = comboBoxCharacter.GetItemText(comboBoxCharacter.Items[e.Index]);
            e.DrawBackground();
            using var brush = new SolidBrush(e.ForeColor);
            e.Graphics.DrawString(text, e.Font!, brush, e.Bounds);
            if (comboBoxCharacter.DroppedDown && (e.State & DrawItemState.Selected) == DrawItemState.Selected)
            {
                var item = (IndexedItem)comboBoxCharacter.Items[e.Index];

#pragma warning disable CS0252 
                if (!string.IsNullOrWhiteSpace(item.Name) && toolTipCharacter.Tag != item)
                {
                    var bounds = comboBoxCharacter.GetItemBounds(e.Index);
                    toolTipCharacter.Show(item.Name, comboBoxCharacter, bounds.Right, bounds.Bottom);
                    toolTipCharacter.Tag = item;
                }
#pragma warning restore CS0252
            }                
            e.DrawFocusRectangle();
        }

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
