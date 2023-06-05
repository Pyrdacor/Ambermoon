using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using Ambermoon.Data;
using static Ambermoon.Data.Tileset;

namespace AmbermoonMapCharEditor
{
    public partial class MapCharSettingsForm : Form
    {
        readonly Func<uint, Bitmap> combatBackgroundProvider;
        readonly Func<uint, Bitmap> graphicProvider;
        readonly Action<IWin32Window, Action<string>> imageSaveHandler;
        readonly bool mapIs3D;
        public TileFlags TileFlags
        {
            get;
            set;
        }
        public uint GraphicIndex => (uint)numericUpDownGraphic.Value;

        public MapCharSettingsForm(bool mapIs3D, Map.CharacterReference character, Func<uint, Bitmap> combatBackgroundProvider,
            Func<uint, Bitmap> graphicProvider, Func<int> graphicCountProvider, Action<IWin32Window, Action<string>> imageSaveHandler)
        {
            this.mapIs3D = mapIs3D;
            this.combatBackgroundProvider = combatBackgroundProvider;
            this.graphicProvider = graphicProvider;
            this.imageSaveHandler = imageSaveHandler;
            var tileFlags = TileFlags = character.TileFlags;

            InitializeComponent();

            bool monster = character.Type == CharacterType.Monster;

            labelCombatBackground.Enabled = monster;
            numericUpDownCombatBackground.Enabled = monster;
            pictureBoxCombatBackground.Enabled = monster;

            if (numericUpDownCombatBackground.Enabled)
            {
                numericUpDownCombatBackground.Value = character.CombatBackgroundIndex & 0xf;

                if ((character.CombatBackgroundIndex & 0xf) == 0) // in this case the image wasn't updated
                    UpdateCombatBackground();
            }

            radioButtonNormal.Enabled = !mapIs3D;
            radioButtonBackground.Enabled = !mapIs3D;
            radioButtonForeground.Enabled = !mapIs3D;
            checkBoxBackgroundFlags.Enabled = !mapIs3D;
            checkBoxHidePlayer.Enabled = !mapIs3D;

            if (mapIs3D)
                radioButtonNormal.Checked = true;
            else
            {
                checkBoxBackgroundFlags.Checked = tileFlags.HasFlag(TileFlags.UseBackgroundTileFlags);
                checkBoxHidePlayer.Checked = tileFlags.HasFlag(TileFlags.PlayerInvisible);

                if (tileFlags.HasFlag(TileFlags.Background))
                {
                    if (tileFlags.HasFlag(TileFlags.BringToFront))
                        radioButtonForeground.Checked = true;
                    else
                        radioButtonBackground.Checked = true;
                }
                else
                    radioButtonNormal.Checked = true;
            }

            if (mapIs3D || character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.UseTileset))
            {
                numericUpDownGraphic.Minimum = 1;
                numericUpDownGraphic.Maximum = graphicCountProvider();
            }
            else
            {
                numericUpDownGraphic.Minimum = 0;
                numericUpDownGraphic.Maximum = graphicCountProvider() - 1;
            }
            character.GraphicIndex = Ambermoon.Util.Limit((uint)numericUpDownGraphic.Minimum, character.GraphicIndex, (uint)numericUpDownGraphic.Maximum);
            numericUpDownGraphic.Value = character.GraphicIndex;

            if (character.GraphicIndex == 0) // in this case the image wasn't updated
                UpdateGraphic();

            checkBoxAllowBroom.Checked = tileFlags.HasFlag(TileFlags.AllowMovementWitchBroom);
            checkBoxAllowEagle.Checked = tileFlags.HasFlag(TileFlags.AllowMovementEagle);
            checkBoxAllowFly.Checked = tileFlags.HasFlag(TileFlags.AllowMovementFly);
            checkBoxAllowHorse.Checked |= tileFlags.HasFlag(TileFlags.AllowMovementHorse);
            checkBoxAllowMagicDisc.Checked = tileFlags.HasFlag(TileFlags.AllowMovementMagicalDisc);
            checkBoxAllowRaft.Checked = tileFlags.HasFlag(TileFlags.AllowMovementRaft);
            checkBoxAllowSandLizard.Checked = tileFlags.HasFlag(TileFlags.AllowMovementSandLizard);
            checkBoxAllowSandShip.Checked = tileFlags.HasFlag(TileFlags.AllowMovementSandShip);
            checkBoxAllowShip.Checked = tileFlags.HasFlag(TileFlags.AllowMovementShip);
            checkBoxAllowSwim.Checked = tileFlags.HasFlag(TileFlags.AllowMovementSwim);
            checkBoxAllowUnused1.Checked = tileFlags.HasFlag(TileFlags.AllowMovementWasp);
            checkBoxAllowUnused2.Checked = tileFlags.HasFlag(TileFlags.AllowMovementUnused13);
            checkBoxAllowUnused3.Checked = tileFlags.HasFlag(TileFlags.AllowMovementUnused14);
            checkBoxAllowUnused4.Checked = tileFlags.HasFlag(TileFlags.AllowMovementUnused15);
            checkBoxAllowWalk.Checked = tileFlags.HasFlag(TileFlags.AllowMovementWalk);

            checkBoxBlockAllMovement.Checked = tileFlags.HasFlag(TileFlags.BlockAllMovement);
            checkBoxAlternateAnimation.Checked = tileFlags.HasFlag(TileFlags.AlternateAnimation);
            checkBoxBlockSight.Checked = tileFlags.HasFlag(TileFlags.BlockSight);
            checkBoxFloor.Checked = tileFlags.HasFlag(TileFlags.Floor);
        }

        private void numericUpDownCombatBackground_ValueChanged(object sender, EventArgs e)
        {
            UpdateCombatBackground();
        }

        private void numericUpDownGraphic_ValueChanged(object sender, EventArgs e)
        {
            UpdateGraphic();
        }

        private void checkBoxBlockAllMovement_CheckedChanged(object sender, EventArgs e)
        {
            groupBoxAllowMovement.Enabled = !checkBoxBlockAllMovement.Checked;
        }

        void UpdateCombatBackground()
        {
            pictureBoxCombatBackground.Image = combatBackgroundProvider((uint)numericUpDownCombatBackground.Value);
        }

        void UpdateGraphic()
        {
            pictureBoxGraphic.Image = graphicProvider((uint)numericUpDownGraphic.Value);
        }

        private void buttonApply_Click(object sender, EventArgs e)
        {
            TileFlags = TileFlags.None;

            if (checkBoxAllowBroom.Checked)
                TileFlags |= TileFlags.AllowMovementWitchBroom;
            if (checkBoxAllowEagle.Checked)
                TileFlags |= TileFlags.AllowMovementEagle;
            if (checkBoxAllowFly.Checked)
                TileFlags |= TileFlags.AllowMovementFly;
            if (checkBoxAllowHorse.Checked)
                TileFlags |= TileFlags.AllowMovementHorse;
            if (checkBoxAllowMagicDisc.Checked)
                TileFlags |= TileFlags.AllowMovementMagicalDisc;
            if (checkBoxAllowRaft.Checked)
                TileFlags |= TileFlags.AllowMovementRaft;
            if (checkBoxAllowSandLizard.Checked)
                TileFlags |= TileFlags.AllowMovementSandLizard;
            if (checkBoxAllowSandShip.Checked)
                TileFlags |= TileFlags.AllowMovementSandShip;
            if (checkBoxAllowShip.Checked)
                TileFlags |= TileFlags.AllowMovementShip;
            if (checkBoxAllowSwim.Checked)
                TileFlags |= TileFlags.AllowMovementSwim;
            if (checkBoxAllowUnused1.Checked)
                TileFlags |= TileFlags.AllowMovementWasp;
            if (checkBoxAllowUnused2.Checked)
                TileFlags |= TileFlags.AllowMovementUnused13;
            if (checkBoxAllowUnused3.Checked)
                TileFlags |= TileFlags.AllowMovementUnused14;
            if (checkBoxAllowUnused4.Checked)
                TileFlags |= TileFlags.AllowMovementUnused15;
            if (checkBoxAllowWalk.Checked)
                TileFlags |= TileFlags.AllowMovementWalk;
            if (checkBoxAlternateAnimation.Checked)
                TileFlags |= TileFlags.AlternateAnimation;
            if (!mapIs3D && checkBoxBackgroundFlags.Checked)
                TileFlags |= TileFlags.UseBackgroundTileFlags;
            if (checkBoxBlockAllMovement.Checked)
                TileFlags |= TileFlags.BlockAllMovement;
            if (checkBoxBlockSight.Checked)
                TileFlags |= TileFlags.BlockSight;
            if (checkBoxFloor.Checked)
                TileFlags |= TileFlags.Floor;
            if (!mapIs3D && checkBoxHidePlayer.Checked)
                TileFlags |= TileFlags.PlayerInvisible;

            if (!mapIs3D)
            {
                if (radioButtonBackground.Checked)
                    TileFlags |= TileFlags.Background;
                else if (radioButtonForeground.Checked)
                {
                    TileFlags |= TileFlags.Background;
                    TileFlags |= TileFlags.BringToFront;
                }
            }

            TileFlags |= (TileFlags)((uint)numericUpDownCombatBackground.Value << 28);

            DialogResult = DialogResult.OK;
        }

        private void toolStripMenuItemExportImage_Click(object sender, EventArgs e)
        {
            imageSaveHandler?.Invoke(this, filename => pictureBoxGraphic.Image.Save(filename, ImageFormat.Png));
        }       
    }
}
