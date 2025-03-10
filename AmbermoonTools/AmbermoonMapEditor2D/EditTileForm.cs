﻿using Ambermoon;
using Ambermoon.Data;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using static Ambermoon.Data.Tileset;
using Random = Ambermoon.Random;

namespace AmbermoonMapEditor2D
{
    partial class EditTileForm : Form
    {
        readonly Configuration configuration;
        internal Tile Tile { get; }
        readonly Tileset tileset;
        readonly ImageCache imageCache;
        readonly uint paletteIndex;
        readonly Dictionary<uint, Bitmap> combatGraphics;
        bool initialize = true;
        uint frame = 0;
        bool animateForward = true;
        ImageDisplayForm combatBackgroundPreview = null;
        readonly Random random = new Random();

        public EditTileForm(Configuration configuration, Tile tile, Tileset tileset, ImageCache imageCache,
            uint paletteIndex, Dictionary<uint, Bitmap> combatGraphics)
        {
            this.configuration = configuration;
            Tile = new Tile();
            Tile.Fill(tile);
            this.tileset = tileset;
            this.imageCache = imageCache;
            this.paletteIndex = paletteIndex;
            this.combatGraphics = combatGraphics;

            InitializeComponent();

            numericUpDownImageIndex.Value = tile.GraphicIndex;
            trackBarFrames.Value = Math.Max(1, tile.NumAnimationFrames);

            checkBoxAllowBroom.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementWitchBroom);
            checkBoxAllowEagle.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementEagle);
            checkBoxAllowFly.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementFly);
            checkBoxAllowHorse.Checked |= tile.Flags.HasFlag(TileFlags.AllowMovementHorse);
            checkBoxAllowMagicDisc.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementMagicalDisc);
            checkBoxAllowRaft.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementRaft);
            checkBoxAllowSandLizard.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementSandLizard);
            checkBoxAllowSandShip.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementSandShip);
            checkBoxAllowShip.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementShip);
            checkBoxAllowSwim.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementSwim);
            checkBoxAllowUnused1.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementWasp);
            checkBoxAllowUnused2.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementUnused13);
            checkBoxAllowUnused3.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementUnused14);
            checkBoxAllowUnused4.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementUnused15);
            checkBoxAllowWalk.Checked = tile.Flags.HasFlag(TileFlags.AllowMovementWalk);

            checkBoxBlockAllMovement.Checked = tile.Flags.HasFlag(TileFlags.BlockAllMovement);
            checkBoxAlternate.Checked = tile.Flags.HasFlag(TileFlags.WaveAnimation);
            checkBoxBackgroundFlags.Checked = tile.Flags.HasFlag(TileFlags.UseBackgroundTileFlags);
            checkBoxBlockSight.Checked = tile.Flags.HasFlag(TileFlags.BlockSight);
            checkBoxFloor.Checked = tile.Flags.HasFlag(TileFlags.Floor);
            checkBoxHidePlayer.Checked = tile.Flags.HasFlag(TileFlags.PlayerInvisible);
            checkBoxRandomAnimationStart.Checked = tile.Flags.HasFlag(TileFlags.RandomAnimationStart);
            checkBoxAutoPoison.Checked = tile.Flags.HasFlag(TileFlags.AutoPoison);

            if (tile.Flags.HasFlag(TileFlags.Background))
            {
                if (tile.Flags.HasFlag(TileFlags.BringToFront))
                    radioButtonForeground.Checked = true;
                else
                    radioButtonBackground.Checked = true;            
            }
            else
                radioButtonNormal.Checked = true;

            if (tile.Sleep)
                comboBoxSitSleep.SelectedIndex = 5;
            else if (tile.SitDirection != null)
                comboBoxSitSleep.SelectedIndex = 1 + (int)tile.SitDirection.Value;
            else
                comboBoxSitSleep.SelectedIndex = 0;

            numericUpDownCombatBackground.Value = tile.CombatBackgroundIndex;

            UpdateColor();

            timerAnimation.Interval = Globals.TimePerFrame;
            timerAnimation.Start();

            initialize = false;
        }

        private void trackBarFrames_ValueChanged(object sender, EventArgs e)
        {
            Tile.NumAnimationFrames = trackBarFrames.Value;
            labelFrames.Text = $"Frames: {trackBarFrames.Value}";

            if (!initialize)
                panelImage.Refresh();
        }

        private void timerAnimation_Tick(object sender, EventArgs e)
        {
            if (Tile.NumAnimationFrames <= 1)
                frame = 0;
            else
            {
                bool alternate = checkBoxAlternate.Checked;
                if (!alternate)
                    animateForward = true;
                if (animateForward)
                {
                    if (++frame == Tile.NumAnimationFrames)
                    {
                        if (alternate)
                        {
                            animateForward = false;
                            --frame;
                        }
                        else
                        {
                            frame = 0;
                        }
                    }
                }
                else
                {
                    if (--frame == 0)
                    {
                        animateForward = true;
                        frame = 1;
                    }
                }
            }

            panelImage.Refresh();
        }

        private void panelImage_Paint(object sender, PaintEventArgs e)
        {
            var rect = new Rectangle(0, 0, 32, 32);

            try
            {
                var image = imageCache.GetImage(tileset.Index, Tile.GraphicIndex + frame - 1, paletteIndex);
                e.Graphics.DrawImage(image, rect);
            }
            catch
            {
                using var errorBrush = new SolidBrush(Color.White);
                using var errorFont = new Font(FontFamily.GenericMonospace, 8.0f);
                using var errorFontBrush = new SolidBrush(Color.Red);
                e.Graphics.FillRectangle(errorBrush, rect);
                e.Graphics.DrawString("X", errorFont, errorFontBrush, rect.X + 3, rect.Y);
            }
        }

        private void checkBoxBlockAllMovement_CheckedChanged(object sender, EventArgs e)
        {
            groupBoxAllowMovement.Enabled = !checkBoxBlockAllMovement.Checked;
        }

        private void buttonApply_Click(object sender, EventArgs e)
        {
            Tile.Flags = TileFlags.None;

            if (checkBoxAllowBroom.Checked)
                Tile.Flags |= TileFlags.AllowMovementWitchBroom;
            if (checkBoxAllowEagle.Checked)
                Tile.Flags |= TileFlags.AllowMovementEagle;
            if (checkBoxAllowFly.Checked)
                Tile.Flags |= TileFlags.AllowMovementFly;
            if (checkBoxAllowHorse.Checked)
                Tile.Flags |= TileFlags.AllowMovementHorse;
            if (checkBoxAllowMagicDisc.Checked)
                Tile.Flags |= TileFlags.AllowMovementMagicalDisc;
            if (checkBoxAllowRaft.Checked)
                Tile.Flags |= TileFlags.AllowMovementRaft;
            if (checkBoxAllowSandLizard.Checked)
                Tile.Flags |= TileFlags.AllowMovementSandLizard;
            if (checkBoxAllowSandShip.Checked)
                Tile.Flags |= TileFlags.AllowMovementSandShip;
            if (checkBoxAllowShip.Checked)
                Tile.Flags |= TileFlags.AllowMovementShip;
            if (checkBoxAllowSwim.Checked)
                Tile.Flags |= TileFlags.AllowMovementSwim;
            if (checkBoxAllowUnused1.Checked)
                Tile.Flags |= TileFlags.AllowMovementWasp;
            if (checkBoxAllowUnused2.Checked)
                Tile.Flags |= TileFlags.AllowMovementUnused13;
            if (checkBoxAllowUnused3.Checked)
                Tile.Flags |= TileFlags.AllowMovementUnused14;
            if (checkBoxAllowUnused4.Checked)
                Tile.Flags |= TileFlags.AllowMovementUnused15;
            if (checkBoxAllowWalk.Checked)
                Tile.Flags |= TileFlags.AllowMovementWalk;
            if (checkBoxAlternate.Checked)
                Tile.Flags |= TileFlags.WaveAnimation;
            if (checkBoxBackgroundFlags.Checked)
                Tile.Flags |= TileFlags.UseBackgroundTileFlags;
            if (checkBoxBlockAllMovement.Checked)
                Tile.Flags |= TileFlags.BlockAllMovement;
            if (checkBoxBlockSight.Checked)
                Tile.Flags |= TileFlags.BlockSight;
            if (checkBoxFloor.Checked)
                Tile.Flags |= TileFlags.Floor;
            if (checkBoxHidePlayer.Checked)
                Tile.Flags |= TileFlags.PlayerInvisible;
            if (checkBoxRandomAnimationStart.Checked)
                Tile.Flags |= TileFlags.RandomAnimationStart;
            if (checkBoxAutoPoison.Checked)
                Tile.Flags |= TileFlags.AutoPoison;

            if (radioButtonBackground.Checked)
                Tile.Flags |= TileFlags.Background;
            else if (radioButtonForeground.Checked)
            {
                Tile.Flags |= TileFlags.Background;
                Tile.Flags |= TileFlags.BringToFront;
            }

            Tile.SitDirection = comboBoxSitSleep.SelectedIndex == 0 || comboBoxSitSleep.SelectedIndex > 4
                ? null : (CharacterDirection?)(comboBoxSitSleep.SelectedIndex - 1);
            Tile.Sleep = comboBoxSitSleep.SelectedIndex == 5;
            Tile.CombatBackgroundIndex = (uint)numericUpDownCombatBackground.Value;

            DialogResult = DialogResult.OK;
        }

        private void numericUpDownCombatBackground_ValueChanged(object sender, EventArgs e)
        {
            if (!initialize)
                combatBackgroundPreview?.SetImage(combatGraphics[(uint)numericUpDownCombatBackground.Value], new System.Drawing.Size(320, 95));
        }

        private void buttonShowCombatBackground_Click(object sender, EventArgs e)
        {
            if (combatBackgroundPreview == null)
            {
                combatBackgroundPreview = new ImageDisplayForm();
                combatBackgroundPreview.FormClosed += (f, _) => combatBackgroundPreview = null;
                combatBackgroundPreview.Show();
            }

            combatBackgroundPreview.SetImage(combatGraphics[(uint)numericUpDownCombatBackground.Value], new System.Drawing.Size(320, 95));
            combatBackgroundPreview.BringToFront();
        }

        private void EditTileForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            combatBackgroundPreview?.Close();
        }

        private void drawPanelColor_Click(object sender, EventArgs e)
        {
            Tile.ColorIndex = (byte)((Tile.ColorIndex + 1) % 32);
            UpdateColor();
        }

        void UpdateColor()
        {
            drawPanelColor.BackColor = imageCache.GetPaletteColor(paletteIndex, Tile.ColorIndex);
        }

        private void numericUpDownImageIndex_ValueChanged(object sender, EventArgs e)
        {
            Tile.GraphicIndex = (uint)numericUpDownImageIndex.Value;
            panelImage.Refresh();
        }

        private void toolStripMenuItemExportImage_Click(object sender, EventArgs e)
        {
            var dialog = new SaveDialog(configuration, Configuration.ImagePathName, "Export tile graphic", "png");
            dialog.Filter = "Portable Network Graphics (*.png)|*.png|Amiga Bit Planes (*.abp)|*.abp|All Files (*.*)|*.*";
            dialog.FileName = $"{Tile.GraphicIndex:000}";
            
            if (dialog.ShowDialog(this) == DialogResult.OK)
            {
                try
                {
                    if (dialog.FileName.ToLower().EndsWith(".png"))
                    {
                        // PNG
                        var image = imageCache.GetImage(tileset.Index, Tile.GraphicIndex - 1, paletteIndex);
                        image.Save(dialog.FileName, System.Drawing.Imaging.ImageFormat.Png);
                    }
                    else
                    {
                        // Amiga Bitplanes
                        System.IO.File.WriteAllBytes(dialog.FileName, imageCache.GetBitplaneData(tileset.Index, Tile.GraphicIndex - 1));
                    }

                    MessageBox.Show(this, "Tile graphic was saved.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(this, "Error saving file." + Environment.NewLine + "Error: " + ex.Message,
                        "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void buttonFreeIn_Click(object sender, EventArgs e)
        {
            checkBoxBlockAllMovement.Checked = false;
            checkBoxAllowWalk.Checked = true;
            checkBoxAllowHorse.Checked = false;
            checkBoxAllowRaft.Checked = false;
            checkBoxAllowShip.Checked = false;
            checkBoxAllowMagicDisc.Checked = false;
            checkBoxAllowEagle.Checked = false;
            checkBoxAllowFly.Checked = true;
            checkBoxAllowSwim.Checked = false;
            checkBoxAllowBroom.Checked = false;
            checkBoxAllowSandLizard.Checked = false;
            checkBoxAllowSandShip.Checked = false;
            checkBoxAllowUnused1.Checked = false;
            checkBoxAllowUnused2.Checked = false;
            checkBoxAllowUnused3.Checked = false;
            checkBoxAllowUnused4.Checked = false;
        }

        private void buttonFreeOut_Click(object sender, EventArgs e)
        {
            checkBoxBlockAllMovement.Checked = false;
            checkBoxAllowWalk.Checked = true;
            checkBoxAllowHorse.Checked = true;
            checkBoxAllowRaft.Checked = false;
            checkBoxAllowShip.Checked = false;
            checkBoxAllowMagicDisc.Checked = true;
            checkBoxAllowEagle.Checked = true;
            checkBoxAllowFly.Checked = true;
            checkBoxAllowSwim.Checked = false;
            checkBoxAllowBroom.Checked = true;
            checkBoxAllowSandLizard.Checked = false;
            checkBoxAllowSandShip.Checked = false;
            checkBoxAllowUnused1.Checked = false;
            checkBoxAllowUnused2.Checked = false;
            checkBoxAllowUnused3.Checked = false;
            checkBoxAllowUnused4.Checked = false;
        }

        private void buttonSwim_Click(object sender, EventArgs e)
        {
            checkBoxBlockAllMovement.Checked = false;
            checkBoxAllowWalk.Checked = true;
            checkBoxAllowHorse.Checked = false;
            checkBoxAllowRaft.Checked = true;
            checkBoxAllowShip.Checked = true;
            checkBoxAllowMagicDisc.Checked = true;
            checkBoxAllowEagle.Checked = true;
            checkBoxAllowFly.Checked = true;
            checkBoxAllowSwim.Checked = true;
            checkBoxAllowBroom.Checked = true;
            checkBoxAllowSandLizard.Checked = false;
            checkBoxAllowSandShip.Checked = false;
            checkBoxAllowUnused1.Checked = false;
            checkBoxAllowUnused2.Checked = false;
            checkBoxAllowUnused3.Checked = false;
            checkBoxAllowUnused4.Checked = false;
        }

        private void buttonBlockIndoor_Click(object sender, EventArgs e)
        {
            checkBoxBlockAllMovement.Checked = false;
            checkBoxAllowWalk.Checked = false;
            checkBoxAllowHorse.Checked = false;
            checkBoxAllowRaft.Checked = false;
            checkBoxAllowShip.Checked = false;
            checkBoxAllowMagicDisc.Checked = false;
            checkBoxAllowEagle.Checked = false;
            checkBoxAllowFly.Checked = true;
            checkBoxAllowSwim.Checked = false;
            checkBoxAllowBroom.Checked = false;
            checkBoxAllowSandLizard.Checked = false;
            checkBoxAllowSandShip.Checked = false;
            checkBoxAllowUnused1.Checked = false;
            checkBoxAllowUnused2.Checked = false;
            checkBoxAllowUnused3.Checked = false;
            checkBoxAllowUnused4.Checked = false;
        }

        private void buttonBlockOutdoor_Click(object sender, EventArgs e)
        {
            checkBoxBlockAllMovement.Checked = false;
            checkBoxAllowWalk.Checked = false;
            checkBoxAllowHorse.Checked = false;
            checkBoxAllowRaft.Checked = false;
            checkBoxAllowShip.Checked = false;
            checkBoxAllowMagicDisc.Checked = false;
            checkBoxAllowEagle.Checked = true;
            checkBoxAllowFly.Checked = true;
            checkBoxAllowSwim.Checked = false;
            checkBoxAllowBroom.Checked = true;
            checkBoxAllowSandLizard.Checked = false;
            checkBoxAllowSandShip.Checked = false;
            checkBoxAllowUnused1.Checked = false;
            checkBoxAllowUnused2.Checked = false;
            checkBoxAllowUnused3.Checked = false;
            checkBoxAllowUnused4.Checked = false;
        }

        private void checkBoxAlternate_CheckedChanged(object sender, EventArgs e)
        {
            this.timerAnimation.Stop();
            frame = 0;
            animateForward = true;
            panelImage.Refresh();
            this.timerAnimation.Start();
        }

        private void checkBoxRandomAnimationStart_CheckedChanged(object sender, EventArgs e)
        {
            this.timerAnimation.Stop();
            frame = checkBoxRandomAnimationStart.Checked && Tile.NumAnimationFrames > 1 ? random.Next() % (uint)Tile.NumAnimationFrames : 0u;
            animateForward = true;
            panelImage.Refresh();
            this.timerAnimation.Start();
        }
    }
}
