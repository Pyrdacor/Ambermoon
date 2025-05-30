﻿
namespace AmbermoonMapEditor2D
{
    partial class MapEditorForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

		#region Windows Form Designer generated code

		/// <summary>
		///  Required method for Designer support - do not modify
		///  the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			components = new System.ComponentModel.Container();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MapEditorForm));
			panelMap = new System.Windows.Forms.MapDrawPanel();
			menuStrip = new System.Windows.Forms.MenuStrip();
			toolStripMenuItemMap = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemMapNew = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemMapSave = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemMapSaveAs = new System.Windows.Forms.ToolStripMenuItem();
			toolStripSeparatorMap1 = new System.Windows.Forms.ToolStripSeparator();
			toolStripMenuItemMapQuit = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemEdit = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemEditUndo = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemEditRedo = new System.Windows.Forms.ToolStripMenuItem();
			toolStripSeparatorEdit1 = new System.Windows.Forms.ToolStripSeparator();
			groupBoxTileset = new System.Windows.Forms.GroupBox();
			checkBoxMarkUnusedTiles = new System.Windows.Forms.CheckBox();
			buttonExportTileset = new System.Windows.Forms.Button();
			buttonEditTile = new System.Windows.Forms.Button();
			comboBoxPalettes = new System.Windows.Forms.ComboBox();
			comboBoxTilesets = new System.Windows.Forms.ComboBox();
			buttonDuplicateTile = new System.Windows.Forms.Button();
			panelTileset = new System.Windows.Forms.ScrollDrawPanel();
			groupBoxProperties = new System.Windows.Forms.GroupBox();
			comboBoxWorld = new System.Windows.Forms.ComboBox();
			labelSizeCross = new System.Windows.Forms.Label();
			numericUpDownHeight = new System.Windows.Forms.NumericUpDown();
			labelSize = new System.Windows.Forms.Label();
			numericUpDownWidth = new System.Windows.Forms.NumericUpDown();
			buttonResize = new System.Windows.Forms.Button();
			buttonToggleMusic = new System.Windows.Forms.Button();
			comboBoxMusic = new System.Windows.Forms.ComboBox();
			labelMusic = new System.Windows.Forms.Label();
			checkBoxWorldSurface = new System.Windows.Forms.CheckBox();
			checkBoxMagic = new System.Windows.Forms.CheckBox();
			buttonIndoorDefaults = new System.Windows.Forms.Button();
			buttonWorldMapDefaults = new System.Windows.Forms.Button();
			checkBoxTravelGraphics = new System.Windows.Forms.CheckBox();
			checkBoxNoSleepUntilDawn = new System.Windows.Forms.CheckBox();
			checkBoxUnknown1 = new System.Windows.Forms.CheckBox();
			checkBoxResting = new System.Windows.Forms.CheckBox();
			radioButtonDungeon = new System.Windows.Forms.RadioButton();
			radioButtonOutdoor = new System.Windows.Forms.RadioButton();
			radioButtonIndoor = new System.Windows.Forms.RadioButton();
			toolTipIndoor = new System.Windows.Forms.ToolTip(components);
			toolTipOutdoor = new System.Windows.Forms.ToolTip(components);
			toolTipDungeon = new System.Windows.Forms.ToolTip(components);
			toolTipResting = new System.Windows.Forms.ToolTip(components);
			toolTipNoSleepUntilDawn = new System.Windows.Forms.ToolTip(components);
			toolTipMagic = new System.Windows.Forms.ToolTip(components);
			toolTipWorldSurface = new System.Windows.Forms.ToolTip(components);
			groupBoxCharacters = new System.Windows.Forms.GroupBox();
			buttonPositions = new System.Windows.Forms.Button();
			mapCharEditorControl = new AmbermoonMapCharEditor.MapCharEditorControl();
			buttonPlaceCharacterOnMap = new System.Windows.Forms.Button();
			labelCharacterPosition = new System.Windows.Forms.Label();
			buttonToolBrush = new System.Windows.Forms.Button();
			buttonToolColorPicker = new System.Windows.Forms.Button();
			buttonToolLayers = new System.Windows.Forms.Button();
			contextMenuStripLayers = new System.Windows.Forms.ContextMenuStrip(components);
			toolStripMenuItemBackLayer = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemFrontLayer = new System.Windows.Forms.ToolStripMenuItem();
			toolStripSeparatorLayers1 = new System.Windows.Forms.ToolStripSeparator();
			toolStripMenuItemShowBackLayer = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemShowFrontLayer = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuShowAllowWalk = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuShowAllowHorse = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuShowAllowDisc = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuShowAllowRaft = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuShowAllowShip = new System.Windows.Forms.ToolStripMenuItem();
			statusStrip = new System.Windows.Forms.StatusStrip();
			toolStripStatusLabelTool = new System.Windows.Forms.ToolStripStatusLabel();
			toolStripStatusLabelLayer = new System.Windows.Forms.ToolStripStatusLabel();
			toolStripStatusLabelCurrentTile = new System.Windows.Forms.ToolStripStatusLabel();
			toolStripStatusLabelCurrentTilesetTile = new System.Windows.Forms.ToolStripStatusLabel();
			buttonToolBlocks = new System.Windows.Forms.Button();
			contextMenuStripBlockModes = new System.Windows.Forms.ContextMenuStrip(components);
			toolStripMenuItemBlocks2x2 = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemBlocks3x2 = new System.Windows.Forms.ToolStripMenuItem();
			toolStripMenuItemBlocks3x3 = new System.Windows.Forms.ToolStripMenuItem();
			buttonToolFill = new System.Windows.Forms.Button();
			buttonToggleGrid = new System.Windows.Forms.Button();
			toolTipBrush = new System.Windows.Forms.ToolTip(components);
			toolTipBlocks = new System.Windows.Forms.ToolTip(components);
			toolTipFill = new System.Windows.Forms.ToolTip(components);
			toolTipColorPicker = new System.Windows.Forms.ToolTip(components);
			toolTipLayers = new System.Windows.Forms.ToolTip(components);
			toolTipGrid = new System.Windows.Forms.ToolTip(components);
			buttonToggleTileMarker = new System.Windows.Forms.Button();
			toolTipTileMarker = new System.Windows.Forms.ToolTip(components);
			labelDivider = new System.Windows.Forms.Label();
			buttonToolRemoveFrontLayer = new System.Windows.Forms.Button();
			toolTipRemoveFrontLayer = new System.Windows.Forms.ToolTip(components);
			groupBoxEvents = new System.Windows.Forms.GroupBox();
			listViewEvents = new System.Windows.Forms.ListView();
			columnHeaderEventId = new System.Windows.Forms.ColumnHeader();
			columnHeaderEventDescription = new System.Windows.Forms.ColumnHeader();
			buttonToggleEvents = new System.Windows.Forms.Button();
			timerAnimation = new System.Windows.Forms.Timer(components);
			trackBarZoom = new System.Windows.Forms.TrackBar();
			buttonToolEventChanger = new System.Windows.Forms.Button();
			buttonToolEventRepeater = new System.Windows.Forms.Button();
			menuStrip.SuspendLayout();
			groupBoxTileset.SuspendLayout();
			groupBoxProperties.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)numericUpDownHeight).BeginInit();
			((System.ComponentModel.ISupportInitialize)numericUpDownWidth).BeginInit();
			groupBoxCharacters.SuspendLayout();
			contextMenuStripLayers.SuspendLayout();
			statusStrip.SuspendLayout();
			contextMenuStripBlockModes.SuspendLayout();
			groupBoxEvents.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)trackBarZoom).BeginInit();
			SuspendLayout();
			// 
			// panelMap
			// 
			panelMap.BackColor = System.Drawing.Color.Black;
			panelMap.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			panelMap.Location = new System.Drawing.Point(0, 27);
			panelMap.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			panelMap.Name = "panelMap";
			panelMap.Size = new System.Drawing.Size(772, 484);
			panelMap.TabIndex = 0;
			panelMap.Scroll += panelMap_Scroll;
			panelMap.Paint += panelMap_Paint;
			panelMap.MouseDown += panelMap_MouseDown;
			panelMap.MouseLeave += panelMap_MouseLeave;
			panelMap.MouseMove += panelMap_MouseMove;
			// 
			// menuStrip
			// 
			menuStrip.ImageScalingSize = new System.Drawing.Size(20, 20);
			menuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] { toolStripMenuItemMap, toolStripMenuItemEdit });
			menuStrip.Location = new System.Drawing.Point(0, 0);
			menuStrip.Name = "menuStrip";
			menuStrip.Size = new System.Drawing.Size(1153, 24);
			menuStrip.TabIndex = 1;
			menuStrip.Text = "menuStrip1";
			// 
			// toolStripMenuItemMap
			// 
			toolStripMenuItemMap.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] { toolStripMenuItemMapNew, toolStripMenuItemMapSave, toolStripMenuItemMapSaveAs, toolStripSeparatorMap1, toolStripMenuItemMapQuit });
			toolStripMenuItemMap.Name = "toolStripMenuItemMap";
			toolStripMenuItemMap.Size = new System.Drawing.Size(43, 20);
			toolStripMenuItemMap.Text = "&Map";
			// 
			// toolStripMenuItemMapNew
			// 
			toolStripMenuItemMapNew.Name = "toolStripMenuItemMapNew";
			toolStripMenuItemMapNew.ShortcutKeys = System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O;
			toolStripMenuItemMapNew.Size = new System.Drawing.Size(196, 22);
			toolStripMenuItemMapNew.Text = "New/Load ...";
			toolStripMenuItemMapNew.Click += toolStripMenuItemMapNew_Click;
			// 
			// toolStripMenuItemMapSave
			// 
			toolStripMenuItemMapSave.Enabled = false;
			toolStripMenuItemMapSave.Name = "toolStripMenuItemMapSave";
			toolStripMenuItemMapSave.ShortcutKeys = System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S;
			toolStripMenuItemMapSave.Size = new System.Drawing.Size(196, 22);
			toolStripMenuItemMapSave.Text = "Save";
			toolStripMenuItemMapSave.Click += toolStripMenuItemMapSave_Click;
			// 
			// toolStripMenuItemMapSaveAs
			// 
			toolStripMenuItemMapSaveAs.Name = "toolStripMenuItemMapSaveAs";
			toolStripMenuItemMapSaveAs.ShortcutKeys = System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Shift | System.Windows.Forms.Keys.S;
			toolStripMenuItemMapSaveAs.Size = new System.Drawing.Size(196, 22);
			toolStripMenuItemMapSaveAs.Text = "Save as ...";
			toolStripMenuItemMapSaveAs.Click += toolStripMenuItemMapSaveAs_Click;
			// 
			// toolStripSeparatorMap1
			// 
			toolStripSeparatorMap1.Name = "toolStripSeparatorMap1";
			toolStripSeparatorMap1.Size = new System.Drawing.Size(193, 6);
			// 
			// toolStripMenuItemMapQuit
			// 
			toolStripMenuItemMapQuit.Name = "toolStripMenuItemMapQuit";
			toolStripMenuItemMapQuit.ShortcutKeys = System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.F4;
			toolStripMenuItemMapQuit.Size = new System.Drawing.Size(196, 22);
			toolStripMenuItemMapQuit.Text = "Quit";
			toolStripMenuItemMapQuit.Click += toolStripMenuItemMapQuit_Click;
			// 
			// toolStripMenuItemEdit
			// 
			toolStripMenuItemEdit.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] { toolStripMenuItemEditUndo, toolStripMenuItemEditRedo, toolStripSeparatorEdit1 });
			toolStripMenuItemEdit.Name = "toolStripMenuItemEdit";
			toolStripMenuItemEdit.Size = new System.Drawing.Size(39, 20);
			toolStripMenuItemEdit.Text = "&Edit";
			// 
			// toolStripMenuItemEditUndo
			// 
			toolStripMenuItemEditUndo.Enabled = false;
			toolStripMenuItemEditUndo.Name = "toolStripMenuItemEditUndo";
			toolStripMenuItemEditUndo.ShortcutKeys = System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Z;
			toolStripMenuItemEditUndo.Size = new System.Drawing.Size(144, 22);
			toolStripMenuItemEditUndo.Text = "Undo";
			toolStripMenuItemEditUndo.Click += toolStripMenuItemEditUndo_Click;
			// 
			// toolStripMenuItemEditRedo
			// 
			toolStripMenuItemEditRedo.Enabled = false;
			toolStripMenuItemEditRedo.Name = "toolStripMenuItemEditRedo";
			toolStripMenuItemEditRedo.ShortcutKeys = System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Y;
			toolStripMenuItemEditRedo.Size = new System.Drawing.Size(144, 22);
			toolStripMenuItemEditRedo.Text = "Redo";
			toolStripMenuItemEditRedo.Click += toolStripMenuItemEditRedo_Click;
			// 
			// toolStripSeparatorEdit1
			// 
			toolStripSeparatorEdit1.Name = "toolStripSeparatorEdit1";
			toolStripSeparatorEdit1.Size = new System.Drawing.Size(141, 6);
			// 
			// groupBoxTileset
			// 
			groupBoxTileset.Controls.Add(checkBoxMarkUnusedTiles);
			groupBoxTileset.Controls.Add(buttonExportTileset);
			groupBoxTileset.Controls.Add(buttonEditTile);
			groupBoxTileset.Controls.Add(comboBoxPalettes);
			groupBoxTileset.Controls.Add(comboBoxTilesets);
			groupBoxTileset.Controls.Add(buttonDuplicateTile);
			groupBoxTileset.Controls.Add(panelTileset);
			groupBoxTileset.Location = new System.Drawing.Point(2, 510);
			groupBoxTileset.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxTileset.Name = "groupBoxTileset";
			groupBoxTileset.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxTileset.Size = new System.Drawing.Size(803, 177);
			groupBoxTileset.TabIndex = 2;
			groupBoxTileset.TabStop = false;
			groupBoxTileset.Text = "Tileset";
			// 
			// checkBoxMarkUnusedTiles
			// 
			checkBoxMarkUnusedTiles.AutoSize = true;
			checkBoxMarkUnusedTiles.Location = new System.Drawing.Point(707, 73);
			checkBoxMarkUnusedTiles.Name = "checkBoxMarkUnusedTiles";
			checkBoxMarkUnusedTiles.Size = new System.Drawing.Size(95, 19);
			checkBoxMarkUnusedTiles.TabIndex = 6;
			checkBoxMarkUnusedTiles.Text = "Mark unused";
			checkBoxMarkUnusedTiles.UseVisualStyleBackColor = true;
			checkBoxMarkUnusedTiles.CheckedChanged += checkBoxMarkUnusedTiles_CheckedChanged;
			// 
			// buttonExportTileset
			// 
			buttonExportTileset.Location = new System.Drawing.Point(707, 148);
			buttonExportTileset.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonExportTileset.Name = "buttonExportTileset";
			buttonExportTileset.Size = new System.Drawing.Size(89, 24);
			buttonExportTileset.TabIndex = 5;
			buttonExportTileset.Text = "Export tileset ...";
			buttonExportTileset.UseVisualStyleBackColor = true;
			buttonExportTileset.Click += buttonExportTileset_Click;
			// 
			// buttonEditTile
			// 
			buttonEditTile.Location = new System.Drawing.Point(707, 94);
			buttonEditTile.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonEditTile.Name = "buttonEditTile";
			buttonEditTile.Size = new System.Drawing.Size(89, 24);
			buttonEditTile.TabIndex = 4;
			buttonEditTile.Text = "Edit tile ...";
			buttonEditTile.UseVisualStyleBackColor = true;
			buttonEditTile.Click += buttonEditTile_Click;
			// 
			// comboBoxPalettes
			// 
			comboBoxPalettes.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			comboBoxPalettes.FormattingEnabled = true;
			comboBoxPalettes.Location = new System.Drawing.Point(707, 47);
			comboBoxPalettes.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			comboBoxPalettes.Name = "comboBoxPalettes";
			comboBoxPalettes.Size = new System.Drawing.Size(89, 23);
			comboBoxPalettes.TabIndex = 3;
			comboBoxPalettes.SelectedIndexChanged += comboBoxPalettes_SelectedIndexChanged;
			// 
			// comboBoxTilesets
			// 
			comboBoxTilesets.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			comboBoxTilesets.FormattingEnabled = true;
			comboBoxTilesets.Location = new System.Drawing.Point(707, 21);
			comboBoxTilesets.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			comboBoxTilesets.Name = "comboBoxTilesets";
			comboBoxTilesets.Size = new System.Drawing.Size(89, 23);
			comboBoxTilesets.TabIndex = 2;
			comboBoxTilesets.SelectedIndexChanged += comboBoxTilesets_SelectedIndexChanged;
			// 
			// buttonDuplicateTile
			// 
			buttonDuplicateTile.Location = new System.Drawing.Point(707, 121);
			buttonDuplicateTile.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonDuplicateTile.Name = "buttonDuplicateTile";
			buttonDuplicateTile.Size = new System.Drawing.Size(89, 24);
			buttonDuplicateTile.TabIndex = 1;
			buttonDuplicateTile.Text = "Duplicate tile";
			buttonDuplicateTile.UseVisualStyleBackColor = true;
			buttonDuplicateTile.Click += buttonDuplicateTile_Click;
			// 
			// panelTileset
			// 
			panelTileset.AutoScroll = true;
			panelTileset.BackColor = System.Drawing.Color.Black;
			panelTileset.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			panelTileset.Location = new System.Drawing.Point(9, 21);
			panelTileset.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			panelTileset.Name = "panelTileset";
			panelTileset.Size = new System.Drawing.Size(695, 149);
			panelTileset.TabIndex = 0;
			panelTileset.Paint += panelTileset_Paint;
			panelTileset.MouseDown += panelTileset_MouseDown;
			panelTileset.MouseLeave += panelTileset_MouseLeave;
			panelTileset.MouseMove += panelTileset_MouseMove;
			// 
			// groupBoxProperties
			// 
			groupBoxProperties.Controls.Add(comboBoxWorld);
			groupBoxProperties.Controls.Add(labelSizeCross);
			groupBoxProperties.Controls.Add(numericUpDownHeight);
			groupBoxProperties.Controls.Add(labelSize);
			groupBoxProperties.Controls.Add(numericUpDownWidth);
			groupBoxProperties.Controls.Add(buttonResize);
			groupBoxProperties.Controls.Add(buttonToggleMusic);
			groupBoxProperties.Controls.Add(comboBoxMusic);
			groupBoxProperties.Controls.Add(labelMusic);
			groupBoxProperties.Controls.Add(checkBoxWorldSurface);
			groupBoxProperties.Controls.Add(checkBoxMagic);
			groupBoxProperties.Controls.Add(buttonIndoorDefaults);
			groupBoxProperties.Controls.Add(buttonWorldMapDefaults);
			groupBoxProperties.Controls.Add(checkBoxTravelGraphics);
			groupBoxProperties.Controls.Add(checkBoxNoSleepUntilDawn);
			groupBoxProperties.Controls.Add(checkBoxUnknown1);
			groupBoxProperties.Controls.Add(checkBoxResting);
			groupBoxProperties.Controls.Add(radioButtonDungeon);
			groupBoxProperties.Controls.Add(radioButtonOutdoor);
			groupBoxProperties.Controls.Add(radioButtonIndoor);
			groupBoxProperties.Location = new System.Drawing.Point(807, 26);
			groupBoxProperties.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxProperties.Name = "groupBoxProperties";
			groupBoxProperties.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxProperties.Size = new System.Drawing.Size(338, 224);
			groupBoxProperties.TabIndex = 3;
			groupBoxProperties.TabStop = false;
			groupBoxProperties.Text = "Properties";
			// 
			// comboBoxWorld
			// 
			comboBoxWorld.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			comboBoxWorld.FormattingEnabled = true;
			comboBoxWorld.Items.AddRange(new object[] { "Lyramion", "Forest Moon", "Morag" });
			comboBoxWorld.Location = new System.Drawing.Point(229, 45);
			comboBoxWorld.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			comboBoxWorld.Name = "comboBoxWorld";
			comboBoxWorld.Size = new System.Drawing.Size(104, 23);
			comboBoxWorld.TabIndex = 21;
			comboBoxWorld.SelectedIndexChanged += comboBoxWorld_SelectedIndexChanged;
			// 
			// labelSizeCross
			// 
			labelSizeCross.AutoSize = true;
			labelSizeCross.Location = new System.Drawing.Point(90, 24);
			labelSizeCross.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
			labelSizeCross.Name = "labelSizeCross";
			labelSizeCross.Size = new System.Drawing.Size(13, 15);
			labelSizeCross.TabIndex = 20;
			labelSizeCross.Text = "x";
			// 
			// numericUpDownHeight
			// 
			numericUpDownHeight.Enabled = false;
			numericUpDownHeight.Location = new System.Drawing.Point(104, 21);
			numericUpDownHeight.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			numericUpDownHeight.Maximum = new decimal(new int[] { 200, 0, 0, 0 });
			numericUpDownHeight.Minimum = new decimal(new int[] { 9, 0, 0, 0 });
			numericUpDownHeight.Name = "numericUpDownHeight";
			numericUpDownHeight.Size = new System.Drawing.Size(44, 23);
			numericUpDownHeight.TabIndex = 19;
			numericUpDownHeight.Value = new decimal(new int[] { 50, 0, 0, 0 });
			numericUpDownHeight.ValueChanged += numericUpDownHeight_ValueChanged;
			// 
			// labelSize
			// 
			labelSize.AutoSize = true;
			labelSize.Location = new System.Drawing.Point(7, 24);
			labelSize.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
			labelSize.Name = "labelSize";
			labelSize.Size = new System.Drawing.Size(30, 15);
			labelSize.TabIndex = 18;
			labelSize.Text = "Size:";
			// 
			// numericUpDownWidth
			// 
			numericUpDownWidth.Enabled = false;
			numericUpDownWidth.Location = new System.Drawing.Point(43, 20);
			numericUpDownWidth.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			numericUpDownWidth.Maximum = new decimal(new int[] { 200, 0, 0, 0 });
			numericUpDownWidth.Minimum = new decimal(new int[] { 11, 0, 0, 0 });
			numericUpDownWidth.Name = "numericUpDownWidth";
			numericUpDownWidth.Size = new System.Drawing.Size(44, 23);
			numericUpDownWidth.TabIndex = 17;
			numericUpDownWidth.Value = new decimal(new int[] { 50, 0, 0, 0 });
			numericUpDownWidth.ValueChanged += numericUpDownWidth_ValueChanged;
			// 
			// buttonResize
			// 
			buttonResize.Location = new System.Drawing.Point(154, 21);
			buttonResize.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonResize.Name = "buttonResize";
			buttonResize.Size = new System.Drawing.Size(104, 24);
			buttonResize.TabIndex = 16;
			buttonResize.Text = "Enable resizing";
			buttonResize.UseVisualStyleBackColor = true;
			buttonResize.Click += buttonResize_Click;
			// 
			// buttonToggleMusic
			// 
			buttonToggleMusic.Image = Properties.Resources.round_play_arrow_black_24;
			buttonToggleMusic.Location = new System.Drawing.Point(308, 186);
			buttonToggleMusic.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToggleMusic.Name = "buttonToggleMusic";
			buttonToggleMusic.Size = new System.Drawing.Size(23, 24);
			buttonToggleMusic.TabIndex = 15;
			buttonToggleMusic.UseVisualStyleBackColor = true;
			buttonToggleMusic.Click += buttonToggleMusic_Click;
			// 
			// comboBoxMusic
			// 
			comboBoxMusic.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			comboBoxMusic.FormattingEnabled = true;
			comboBoxMusic.Location = new System.Drawing.Point(55, 186);
			comboBoxMusic.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			comboBoxMusic.Name = "comboBoxMusic";
			comboBoxMusic.Size = new System.Drawing.Size(250, 23);
			comboBoxMusic.TabIndex = 14;
			comboBoxMusic.SelectedIndexChanged += comboBoxMusic_SelectedIndexChanged;
			// 
			// labelMusic
			// 
			labelMusic.AutoSize = true;
			labelMusic.Location = new System.Drawing.Point(7, 190);
			labelMusic.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
			labelMusic.Name = "labelMusic";
			labelMusic.Size = new System.Drawing.Size(42, 15);
			labelMusic.TabIndex = 13;
			labelMusic.Text = "Music:";
			// 
			// checkBoxWorldSurface
			// 
			checkBoxWorldSurface.AutoSize = true;
			checkBoxWorldSurface.Enabled = false;
			checkBoxWorldSurface.Location = new System.Drawing.Point(7, 71);
			checkBoxWorldSurface.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			checkBoxWorldSurface.Name = "checkBoxWorldSurface";
			checkBoxWorldSurface.Size = new System.Drawing.Size(85, 19);
			checkBoxWorldSurface.TabIndex = 12;
			checkBoxWorldSurface.Text = "World Map";
			checkBoxWorldSurface.UseVisualStyleBackColor = true;
			checkBoxWorldSurface.CheckedChanged += checkBoxWorldSurface_CheckedChanged;
			// 
			// checkBoxMagic
			// 
			checkBoxMagic.AutoSize = true;
			checkBoxMagic.Checked = true;
			checkBoxMagic.CheckState = System.Windows.Forms.CheckState.Checked;
			checkBoxMagic.Location = new System.Drawing.Point(7, 121);
			checkBoxMagic.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			checkBoxMagic.Name = "checkBoxMagic";
			checkBoxMagic.Size = new System.Drawing.Size(92, 19);
			checkBoxMagic.TabIndex = 11;
			checkBoxMagic.Text = "Allow Magic";
			checkBoxMagic.UseVisualStyleBackColor = true;
			checkBoxMagic.CheckedChanged += checkBoxMagic_CheckedChanged;
			// 
			// buttonIndoorDefaults
			// 
			buttonIndoorDefaults.Location = new System.Drawing.Point(173, 145);
			buttonIndoorDefaults.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonIndoorDefaults.Name = "buttonIndoorDefaults";
			buttonIndoorDefaults.Size = new System.Drawing.Size(160, 24);
			buttonIndoorDefaults.TabIndex = 9;
			buttonIndoorDefaults.Text = "Use Indoor Defaults";
			buttonIndoorDefaults.UseVisualStyleBackColor = true;
			buttonIndoorDefaults.Click += buttonIndoorDefaults_Click;
			// 
			// buttonWorldMapDefaults
			// 
			buttonWorldMapDefaults.Location = new System.Drawing.Point(6, 145);
			buttonWorldMapDefaults.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonWorldMapDefaults.Name = "buttonWorldMapDefaults";
			buttonWorldMapDefaults.Size = new System.Drawing.Size(160, 24);
			buttonWorldMapDefaults.TabIndex = 8;
			buttonWorldMapDefaults.Text = "Use World Map Defaults";
			buttonWorldMapDefaults.UseVisualStyleBackColor = true;
			buttonWorldMapDefaults.Click += buttonWorldMapDefaults_Click;
			// 
			// checkBoxTravelGraphics
			// 
			checkBoxTravelGraphics.AutoSize = true;
			checkBoxTravelGraphics.Enabled = false;
			checkBoxTravelGraphics.Location = new System.Drawing.Point(111, 71);
			checkBoxTravelGraphics.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			checkBoxTravelGraphics.Name = "checkBoxTravelGraphics";
			checkBoxTravelGraphics.Size = new System.Drawing.Size(105, 19);
			checkBoxTravelGraphics.TabIndex = 7;
			checkBoxTravelGraphics.Text = "Travel Graphics";
			checkBoxTravelGraphics.UseVisualStyleBackColor = true;
			checkBoxTravelGraphics.CheckedChanged += checkBoxTravelGraphics_CheckedChanged;
			// 
			// checkBoxNoSleepUntilDawn
			// 
			checkBoxNoSleepUntilDawn.AutoSize = true;
			checkBoxNoSleepUntilDawn.Location = new System.Drawing.Point(111, 96);
			checkBoxNoSleepUntilDawn.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			checkBoxNoSleepUntilDawn.Name = "checkBoxNoSleepUntilDawn";
			checkBoxNoSleepUntilDawn.Size = new System.Drawing.Size(134, 19);
			checkBoxNoSleepUntilDawn.TabIndex = 6;
			checkBoxNoSleepUntilDawn.Text = "No Sleep Until Dawn";
			checkBoxNoSleepUntilDawn.UseVisualStyleBackColor = true;
			checkBoxNoSleepUntilDawn.CheckedChanged += checkBoxNoSleepUntilDawn_CheckedChanged;
			// 
			// checkBoxUnknown1
			// 
			checkBoxUnknown1.AutoSize = true;
			checkBoxUnknown1.Enabled = false;
			checkBoxUnknown1.Location = new System.Drawing.Point(111, 121);
			checkBoxUnknown1.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			checkBoxUnknown1.Name = "checkBoxUnknown1";
			checkBoxUnknown1.Size = new System.Drawing.Size(77, 19);
			checkBoxUnknown1.TabIndex = 5;
			checkBoxUnknown1.Text = "Unknown";
			checkBoxUnknown1.UseVisualStyleBackColor = true;
			checkBoxUnknown1.CheckedChanged += checkBoxUnknown1_CheckedChanged;
			// 
			// checkBoxResting
			// 
			checkBoxResting.AutoSize = true;
			checkBoxResting.Checked = true;
			checkBoxResting.CheckState = System.Windows.Forms.CheckState.Checked;
			checkBoxResting.Location = new System.Drawing.Point(7, 96);
			checkBoxResting.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			checkBoxResting.Name = "checkBoxResting";
			checkBoxResting.Size = new System.Drawing.Size(98, 19);
			checkBoxResting.TabIndex = 4;
			checkBoxResting.Text = "Allow Resting";
			checkBoxResting.UseVisualStyleBackColor = true;
			checkBoxResting.CheckedChanged += checkBoxResting_CheckedChanged;
			// 
			// radioButtonDungeon
			// 
			radioButtonDungeon.AutoSize = true;
			radioButtonDungeon.Location = new System.Drawing.Point(148, 46);
			radioButtonDungeon.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			radioButtonDungeon.Name = "radioButtonDungeon";
			radioButtonDungeon.Size = new System.Drawing.Size(74, 19);
			radioButtonDungeon.TabIndex = 2;
			radioButtonDungeon.Text = "Dungeon";
			radioButtonDungeon.UseVisualStyleBackColor = true;
			radioButtonDungeon.CheckedChanged += radioButtonDungeon_CheckedChanged;
			// 
			// radioButtonOutdoor
			// 
			radioButtonOutdoor.AutoSize = true;
			radioButtonOutdoor.Location = new System.Drawing.Point(72, 46);
			radioButtonOutdoor.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			radioButtonOutdoor.Name = "radioButtonOutdoor";
			radioButtonOutdoor.Size = new System.Drawing.Size(70, 19);
			radioButtonOutdoor.TabIndex = 1;
			radioButtonOutdoor.Text = "Outdoor";
			radioButtonOutdoor.UseVisualStyleBackColor = true;
			radioButtonOutdoor.CheckedChanged += radioButtonOutdoor_CheckedChanged;
			// 
			// radioButtonIndoor
			// 
			radioButtonIndoor.AutoSize = true;
			radioButtonIndoor.Checked = true;
			radioButtonIndoor.Location = new System.Drawing.Point(6, 46);
			radioButtonIndoor.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			radioButtonIndoor.Name = "radioButtonIndoor";
			radioButtonIndoor.Size = new System.Drawing.Size(60, 19);
			radioButtonIndoor.TabIndex = 0;
			radioButtonIndoor.TabStop = true;
			radioButtonIndoor.Text = "Indoor";
			radioButtonIndoor.UseVisualStyleBackColor = true;
			radioButtonIndoor.CheckedChanged += radioButtonIndoor_CheckedChanged;
			// 
			// groupBoxCharacters
			// 
			groupBoxCharacters.Controls.Add(buttonPositions);
			groupBoxCharacters.Controls.Add(mapCharEditorControl);
			groupBoxCharacters.Controls.Add(buttonPlaceCharacterOnMap);
			groupBoxCharacters.Controls.Add(labelCharacterPosition);
			groupBoxCharacters.Location = new System.Drawing.Point(807, 256);
			groupBoxCharacters.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxCharacters.Name = "groupBoxCharacters";
			groupBoxCharacters.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxCharacters.Size = new System.Drawing.Size(338, 291);
			groupBoxCharacters.TabIndex = 4;
			groupBoxCharacters.TabStop = false;
			groupBoxCharacters.Text = "Monsters && NPCs";
			// 
			// buttonPositions
			// 
			buttonPositions.Location = new System.Drawing.Point(124, 261);
			buttonPositions.Name = "buttonPositions";
			buttonPositions.Size = new System.Drawing.Size(86, 24);
			buttonPositions.TabIndex = 17;
			buttonPositions.Text = "Positions ...";
			buttonPositions.UseVisualStyleBackColor = true;
			buttonPositions.Click += buttonPositions_Click;
			// 
			// mapCharEditorControl
			// 
			mapCharEditorControl.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
			mapCharEditorControl.AutoSize = true;
			mapCharEditorControl.Location = new System.Drawing.Point(7, 21);
			mapCharEditorControl.Margin = new System.Windows.Forms.Padding(2, 4, 2, 4);
			mapCharEditorControl.Name = "mapCharEditorControl";
			mapCharEditorControl.Size = new System.Drawing.Size(326, 234);
			mapCharEditorControl.TabIndex = 0;
			mapCharEditorControl.Visible = false;
			mapCharEditorControl.Load += mapCharEditorControl_Load;
			// 
			// buttonPlaceCharacterOnMap
			// 
			buttonPlaceCharacterOnMap.Anchor = System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right;
			buttonPlaceCharacterOnMap.Image = Properties.Resources.round_control_camera_black_24;
			buttonPlaceCharacterOnMap.Location = new System.Drawing.Point(215, 261);
			buttonPlaceCharacterOnMap.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonPlaceCharacterOnMap.Name = "buttonPlaceCharacterOnMap";
			buttonPlaceCharacterOnMap.Size = new System.Drawing.Size(23, 24);
			buttonPlaceCharacterOnMap.TabIndex = 16;
			buttonPlaceCharacterOnMap.UseVisualStyleBackColor = true;
			buttonPlaceCharacterOnMap.EnabledChanged += buttonPlaceCharacterOnMap_EnabledChanged;
			buttonPlaceCharacterOnMap.Click += buttonPlaceCharacterOnMap_Click;
			// 
			// labelCharacterPosition
			// 
			labelCharacterPosition.Anchor = System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right;
			labelCharacterPosition.AutoSize = true;
			labelCharacterPosition.Location = new System.Drawing.Point(240, 267);
			labelCharacterPosition.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
			labelCharacterPosition.Name = "labelCharacterPosition";
			labelCharacterPosition.Size = new System.Drawing.Size(89, 15);
			labelCharacterPosition.TabIndex = 4;
			labelCharacterPosition.Text = "Location: 50, 50";
			// 
			// buttonToolBrush
			// 
			buttonToolBrush.ForeColor = System.Drawing.SystemColors.ControlText;
			buttonToolBrush.Image = Properties.Resources.round_brush_black_24;
			buttonToolBrush.Location = new System.Drawing.Point(772, 27);
			buttonToolBrush.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolBrush.Name = "buttonToolBrush";
			buttonToolBrush.Size = new System.Drawing.Size(33, 32);
			buttonToolBrush.TabIndex = 5;
			buttonToolBrush.UseVisualStyleBackColor = true;
			buttonToolBrush.Click += buttonToolBrush_Click;
			// 
			// buttonToolColorPicker
			// 
			buttonToolColorPicker.Image = Properties.Resources.round_colorize_black_24;
			buttonToolColorPicker.Location = new System.Drawing.Point(772, 167);
			buttonToolColorPicker.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolColorPicker.Name = "buttonToolColorPicker";
			buttonToolColorPicker.Size = new System.Drawing.Size(33, 32);
			buttonToolColorPicker.TabIndex = 6;
			buttonToolColorPicker.UseVisualStyleBackColor = true;
			buttonToolColorPicker.Click += buttonToolColorPicker_Click;
			// 
			// buttonToolLayers
			// 
			buttonToolLayers.Image = Properties.Resources.round_layers_black_24;
			buttonToolLayers.Location = new System.Drawing.Point(772, 287);
			buttonToolLayers.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolLayers.Name = "buttonToolLayers";
			buttonToolLayers.Size = new System.Drawing.Size(33, 32);
			buttonToolLayers.TabIndex = 7;
			buttonToolLayers.UseVisualStyleBackColor = true;
			buttonToolLayers.Click += buttonToolLayers_Click;
			// 
			// contextMenuStripLayers
			// 
			contextMenuStripLayers.ImageScalingSize = new System.Drawing.Size(20, 20);
			contextMenuStripLayers.Items.AddRange(new System.Windows.Forms.ToolStripItem[] { toolStripMenuItemBackLayer, toolStripMenuItemFrontLayer, toolStripSeparatorLayers1, toolStripMenuItemShowBackLayer, toolStripMenuItemShowFrontLayer, toolStripMenuShowAllowWalk, toolStripMenuShowAllowHorse, toolStripMenuShowAllowDisc, toolStripMenuShowAllowRaft, toolStripMenuShowAllowShip });
			contextMenuStripLayers.Name = "contextMenuStripLayers";
			contextMenuStripLayers.Size = new System.Drawing.Size(171, 208);
			// 
			// toolStripMenuItemBackLayer
			// 
			toolStripMenuItemBackLayer.Checked = true;
			toolStripMenuItemBackLayer.CheckOnClick = true;
			toolStripMenuItemBackLayer.CheckState = System.Windows.Forms.CheckState.Checked;
			toolStripMenuItemBackLayer.Name = "toolStripMenuItemBackLayer";
			toolStripMenuItemBackLayer.Size = new System.Drawing.Size(170, 22);
			toolStripMenuItemBackLayer.Text = "Back Layer";
			toolStripMenuItemBackLayer.Click += toolStripMenuItemBackLayer_Click;
			// 
			// toolStripMenuItemFrontLayer
			// 
			toolStripMenuItemFrontLayer.CheckOnClick = true;
			toolStripMenuItemFrontLayer.Name = "toolStripMenuItemFrontLayer";
			toolStripMenuItemFrontLayer.Size = new System.Drawing.Size(170, 22);
			toolStripMenuItemFrontLayer.Text = "Front Layer";
			toolStripMenuItemFrontLayer.Click += toolStripMenuItemFrontLayer_Click;
			// 
			// toolStripSeparatorLayers1
			// 
			toolStripSeparatorLayers1.Name = "toolStripSeparatorLayers1";
			toolStripSeparatorLayers1.Size = new System.Drawing.Size(167, 6);
			// 
			// toolStripMenuItemShowBackLayer
			// 
			toolStripMenuItemShowBackLayer.Checked = true;
			toolStripMenuItemShowBackLayer.CheckOnClick = true;
			toolStripMenuItemShowBackLayer.CheckState = System.Windows.Forms.CheckState.Checked;
			toolStripMenuItemShowBackLayer.Name = "toolStripMenuItemShowBackLayer";
			toolStripMenuItemShowBackLayer.Size = new System.Drawing.Size(170, 22);
			toolStripMenuItemShowBackLayer.Text = "Show Back Layer";
			toolStripMenuItemShowBackLayer.Click += toolStripMenuItemShowBackLayer_Click;
			// 
			// toolStripMenuItemShowFrontLayer
			// 
			toolStripMenuItemShowFrontLayer.Checked = true;
			toolStripMenuItemShowFrontLayer.CheckOnClick = true;
			toolStripMenuItemShowFrontLayer.CheckState = System.Windows.Forms.CheckState.Checked;
			toolStripMenuItemShowFrontLayer.Name = "toolStripMenuItemShowFrontLayer";
			toolStripMenuItemShowFrontLayer.Size = new System.Drawing.Size(170, 22);
			toolStripMenuItemShowFrontLayer.Text = "Show Front Layer";
			toolStripMenuItemShowFrontLayer.Click += toolStripMenuItemShowFrontLayer_Click;
			// 
			// toolStripMenuShowAllowWalk
			// 
			toolStripMenuShowAllowWalk.CheckOnClick = true;
			toolStripMenuShowAllowWalk.Name = "toolStripMenuShowAllowWalk";
			toolStripMenuShowAllowWalk.Size = new System.Drawing.Size(170, 22);
			toolStripMenuShowAllowWalk.Text = "Show Allow Walk";
			toolStripMenuShowAllowWalk.Click += toolStripMenuShowAllowWalk_Click;
			// 
			// toolStripMenuShowAllowHorse
			// 
			toolStripMenuShowAllowHorse.CheckOnClick = true;
			toolStripMenuShowAllowHorse.Name = "toolStripMenuShowAllowHorse";
			toolStripMenuShowAllowHorse.Size = new System.Drawing.Size(170, 22);
			toolStripMenuShowAllowHorse.Text = "Show Allow Horse";
			toolStripMenuShowAllowHorse.Click += toolStripMenuShowAllowHorse_Click;
			// 
			// toolStripMenuShowAllowDisc
			// 
			toolStripMenuShowAllowDisc.CheckOnClick = true;
			toolStripMenuShowAllowDisc.Name = "toolStripMenuShowAllowDisc";
			toolStripMenuShowAllowDisc.Size = new System.Drawing.Size(170, 22);
			toolStripMenuShowAllowDisc.Text = "Show Allow Disc";
			toolStripMenuShowAllowDisc.Click += toolStripMenuShowAllowDisc_Click;
			// 
			// toolStripMenuShowAllowRaft
			// 
			toolStripMenuShowAllowRaft.CheckOnClick = true;
			toolStripMenuShowAllowRaft.Name = "toolStripMenuShowAllowRaft";
			toolStripMenuShowAllowRaft.Size = new System.Drawing.Size(170, 22);
			toolStripMenuShowAllowRaft.Text = "Show Allow Raft";
			toolStripMenuShowAllowRaft.Click += toolStripMenuShowAllowRaft_Click;
			// 
			// toolStripMenuShowAllowShip
			// 
			toolStripMenuShowAllowShip.CheckOnClick = true;
			toolStripMenuShowAllowShip.Name = "toolStripMenuShowAllowShip";
			toolStripMenuShowAllowShip.Size = new System.Drawing.Size(170, 22);
			toolStripMenuShowAllowShip.Text = "Show Allow Ship";
			toolStripMenuShowAllowShip.Click += toolStripMenuShowAllowShip_Click;
			// 
			// statusStrip
			// 
			statusStrip.ImageScalingSize = new System.Drawing.Size(20, 20);
			statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] { toolStripStatusLabelTool, toolStripStatusLabelLayer, toolStripStatusLabelCurrentTile, toolStripStatusLabelCurrentTilesetTile });
			statusStrip.Location = new System.Drawing.Point(0, 686);
			statusStrip.Name = "statusStrip";
			statusStrip.Size = new System.Drawing.Size(1153, 25);
			statusStrip.SizingGrip = false;
			statusStrip.TabIndex = 8;
			statusStrip.Text = "statusStrip1";
			// 
			// toolStripStatusLabelTool
			// 
			toolStripStatusLabelTool.Image = Properties.Resources.round_brush_black_24;
			toolStripStatusLabelTool.Name = "toolStripStatusLabelTool";
			toolStripStatusLabelTool.Size = new System.Drawing.Size(20, 20);
			// 
			// toolStripStatusLabelLayer
			// 
			toolStripStatusLabelLayer.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
			toolStripStatusLabelLayer.BorderStyle = System.Windows.Forms.Border3DStyle.Etched;
			toolStripStatusLabelLayer.Name = "toolStripStatusLabelLayer";
			toolStripStatusLabelLayer.Size = new System.Drawing.Size(67, 20);
			toolStripStatusLabelLayer.Text = "Back Layer";
			// 
			// toolStripStatusLabelCurrentTile
			// 
			toolStripStatusLabelCurrentTile.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
			toolStripStatusLabelCurrentTile.BorderStyle = System.Windows.Forms.Border3DStyle.Etched;
			toolStripStatusLabelCurrentTile.Name = "toolStripStatusLabelCurrentTile";
			toolStripStatusLabelCurrentTile.Size = new System.Drawing.Size(29, 20);
			toolStripStatusLabelCurrentTile.Text = "0, 0";
			toolStripStatusLabelCurrentTile.Visible = false;
			// 
			// toolStripStatusLabelCurrentTilesetTile
			// 
			toolStripStatusLabelCurrentTilesetTile.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
			toolStripStatusLabelCurrentTilesetTile.BorderStyle = System.Windows.Forms.Border3DStyle.Etched;
			toolStripStatusLabelCurrentTilesetTile.Name = "toolStripStatusLabelCurrentTilesetTile";
			toolStripStatusLabelCurrentTilesetTile.Size = new System.Drawing.Size(29, 20);
			toolStripStatusLabelCurrentTilesetTile.Text = "0, 0";
			toolStripStatusLabelCurrentTilesetTile.Visible = false;
			// 
			// buttonToolBlocks
			// 
			buttonToolBlocks.ContextMenuStrip = contextMenuStripBlockModes;
			buttonToolBlocks.ForeColor = System.Drawing.SystemColors.ControlText;
			buttonToolBlocks.Image = Properties.Resources.round_grid_view_black_24_with_arrow;
			buttonToolBlocks.Location = new System.Drawing.Point(772, 62);
			buttonToolBlocks.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolBlocks.Name = "buttonToolBlocks";
			buttonToolBlocks.Size = new System.Drawing.Size(33, 32);
			buttonToolBlocks.TabIndex = 9;
			buttonToolBlocks.UseVisualStyleBackColor = true;
			buttonToolBlocks.Click += buttonToolBlocks_Click;
			// 
			// contextMenuStripBlockModes
			// 
			contextMenuStripBlockModes.ImageScalingSize = new System.Drawing.Size(20, 20);
			contextMenuStripBlockModes.Items.AddRange(new System.Windows.Forms.ToolStripItem[] { toolStripMenuItemBlocks2x2, toolStripMenuItemBlocks3x2, toolStripMenuItemBlocks3x3 });
			contextMenuStripBlockModes.Name = "contextMenuStripBlockModes";
			contextMenuStripBlockModes.Size = new System.Drawing.Size(97, 82);
			// 
			// toolStripMenuItemBlocks2x2
			// 
			toolStripMenuItemBlocks2x2.Image = Properties.Resources.round_grid_view_black_24;
			toolStripMenuItemBlocks2x2.Name = "toolStripMenuItemBlocks2x2";
			toolStripMenuItemBlocks2x2.Size = new System.Drawing.Size(96, 26);
			toolStripMenuItemBlocks2x2.Text = "2x2";
			toolStripMenuItemBlocks2x2.Click += toolStripMenuItemBlocks2x2_Click;
			// 
			// toolStripMenuItemBlocks3x2
			// 
			toolStripMenuItemBlocks3x2.Image = Properties.Resources.round_view_module_black_24;
			toolStripMenuItemBlocks3x2.Name = "toolStripMenuItemBlocks3x2";
			toolStripMenuItemBlocks3x2.Size = new System.Drawing.Size(96, 26);
			toolStripMenuItemBlocks3x2.Text = "3x2";
			toolStripMenuItemBlocks3x2.Click += toolStripMenuItemBlocks3x2_Click;
			// 
			// toolStripMenuItemBlocks3x3
			// 
			toolStripMenuItemBlocks3x3.Image = Properties.Resources.round_apps_black_24;
			toolStripMenuItemBlocks3x3.Name = "toolStripMenuItemBlocks3x3";
			toolStripMenuItemBlocks3x3.Size = new System.Drawing.Size(96, 26);
			toolStripMenuItemBlocks3x3.Text = "3x3";
			toolStripMenuItemBlocks3x3.Click += toolStripMenuItemBlocks3x3_Click;
			// 
			// buttonToolFill
			// 
			buttonToolFill.ForeColor = System.Drawing.SystemColors.ControlText;
			buttonToolFill.Image = Properties.Resources.round_format_color_fill_black_24;
			buttonToolFill.Location = new System.Drawing.Point(772, 97);
			buttonToolFill.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolFill.Name = "buttonToolFill";
			buttonToolFill.Size = new System.Drawing.Size(33, 32);
			buttonToolFill.TabIndex = 10;
			buttonToolFill.UseVisualStyleBackColor = true;
			buttonToolFill.Click += buttonToolFill_Click;
			// 
			// buttonToggleGrid
			// 
			buttonToggleGrid.ForeColor = System.Drawing.SystemColors.ControlText;
			buttonToggleGrid.Image = Properties.Resources.round_grid_off_black_24;
			buttonToggleGrid.Location = new System.Drawing.Point(772, 322);
			buttonToggleGrid.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToggleGrid.Name = "buttonToggleGrid";
			buttonToggleGrid.Size = new System.Drawing.Size(33, 32);
			buttonToggleGrid.TabIndex = 11;
			buttonToggleGrid.UseVisualStyleBackColor = true;
			buttonToggleGrid.Click += buttonToggleGrid_Click;
			// 
			// buttonToggleTileMarker
			// 
			buttonToggleTileMarker.ForeColor = System.Drawing.SystemColors.ControlText;
			buttonToggleTileMarker.Image = Properties.Resources.round_select_all_black_24;
			buttonToggleTileMarker.Location = new System.Drawing.Point(772, 357);
			buttonToggleTileMarker.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToggleTileMarker.Name = "buttonToggleTileMarker";
			buttonToggleTileMarker.Size = new System.Drawing.Size(33, 32);
			buttonToggleTileMarker.TabIndex = 12;
			buttonToggleTileMarker.UseVisualStyleBackColor = true;
			buttonToggleTileMarker.Click += buttonToggleTileMarker_Click;
			// 
			// labelDivider
			// 
			labelDivider.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			labelDivider.Location = new System.Drawing.Point(773, 278);
			labelDivider.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
			labelDivider.Name = "labelDivider";
			labelDivider.Size = new System.Drawing.Size(33, 2);
			labelDivider.TabIndex = 13;
			// 
			// buttonToolRemoveFrontLayer
			// 
			buttonToolRemoveFrontLayer.Image = Properties.Resources.round_layers_clear_black_24;
			buttonToolRemoveFrontLayer.Location = new System.Drawing.Point(772, 132);
			buttonToolRemoveFrontLayer.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolRemoveFrontLayer.Name = "buttonToolRemoveFrontLayer";
			buttonToolRemoveFrontLayer.Size = new System.Drawing.Size(33, 32);
			buttonToolRemoveFrontLayer.TabIndex = 14;
			buttonToolRemoveFrontLayer.UseVisualStyleBackColor = true;
			buttonToolRemoveFrontLayer.Click += buttonToolRemoveFrontLayer_Click;
			// 
			// groupBoxEvents
			// 
			groupBoxEvents.Controls.Add(listViewEvents);
			groupBoxEvents.Location = new System.Drawing.Point(807, 553);
			groupBoxEvents.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxEvents.Name = "groupBoxEvents";
			groupBoxEvents.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
			groupBoxEvents.Size = new System.Drawing.Size(338, 129);
			groupBoxEvents.TabIndex = 15;
			groupBoxEvents.TabStop = false;
			groupBoxEvents.Text = "Events";
			// 
			// listViewEvents
			// 
			listViewEvents.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] { columnHeaderEventId, columnHeaderEventDescription });
			listViewEvents.FullRowSelect = true;
			listViewEvents.GridLines = true;
			listViewEvents.HeaderStyle = System.Windows.Forms.ColumnHeaderStyle.Nonclickable;
			listViewEvents.Location = new System.Drawing.Point(6, 21);
			listViewEvents.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			listViewEvents.Name = "listViewEvents";
			listViewEvents.Size = new System.Drawing.Size(326, 125);
			listViewEvents.TabIndex = 0;
			listViewEvents.UseCompatibleStateImageBehavior = false;
			listViewEvents.View = System.Windows.Forms.View.Details;
			// 
			// columnHeaderEventId
			// 
			columnHeaderEventId.Text = "ID";
			columnHeaderEventId.Width = 30;
			// 
			// columnHeaderEventDescription
			// 
			columnHeaderEventDescription.Text = "Description";
			columnHeaderEventDescription.Width = 292;
			// 
			// buttonToggleEvents
			// 
			buttonToggleEvents.ForeColor = System.Drawing.SystemColors.ControlText;
			buttonToggleEvents.Image = Properties.Resources.round_vpn_key_black_24_off;
			buttonToggleEvents.Location = new System.Drawing.Point(772, 392);
			buttonToggleEvents.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToggleEvents.Name = "buttonToggleEvents";
			buttonToggleEvents.Size = new System.Drawing.Size(33, 32);
			buttonToggleEvents.TabIndex = 16;
			buttonToggleEvents.UseVisualStyleBackColor = true;
			buttonToggleEvents.Click += buttonToggleEvents_Click;
			// 
			// timerAnimation
			// 
			timerAnimation.Interval = 166;
			timerAnimation.Tick += timerAnimation_Tick;
			// 
			// trackBarZoom
			// 
			trackBarZoom.AutoSize = false;
			trackBarZoom.LargeChange = 1;
			trackBarZoom.Location = new System.Drawing.Point(779, 424);
			trackBarZoom.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			trackBarZoom.Maximum = 4;
			trackBarZoom.Minimum = 1;
			trackBarZoom.Name = "trackBarZoom";
			trackBarZoom.Orientation = System.Windows.Forms.Orientation.Vertical;
			trackBarZoom.Size = new System.Drawing.Size(26, 84);
			trackBarZoom.TabIndex = 17;
			trackBarZoom.TickStyle = System.Windows.Forms.TickStyle.None;
			trackBarZoom.Value = 4;
			trackBarZoom.Scroll += trackBarZoom_Scroll;
			// 
			// buttonToolEventChanger
			// 
			buttonToolEventChanger.Image = Properties.Resources.baseline_grade_black_24dp;
			buttonToolEventChanger.Location = new System.Drawing.Point(772, 202);
			buttonToolEventChanger.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolEventChanger.Name = "buttonToolEventChanger";
			buttonToolEventChanger.Size = new System.Drawing.Size(33, 32);
			buttonToolEventChanger.TabIndex = 18;
			buttonToolEventChanger.UseVisualStyleBackColor = true;
			buttonToolEventChanger.Click += buttonToolEventChanger_Click;
			// 
			// buttonToolEventRepeater
			// 
			buttonToolEventRepeater.Image = Properties.Resources.repeat_event;
			buttonToolEventRepeater.Location = new System.Drawing.Point(773, 237);
			buttonToolEventRepeater.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			buttonToolEventRepeater.Name = "buttonToolEventRepeater";
			buttonToolEventRepeater.Size = new System.Drawing.Size(33, 32);
			buttonToolEventRepeater.TabIndex = 19;
			buttonToolEventRepeater.UseVisualStyleBackColor = true;
			buttonToolEventRepeater.Click += buttonToolEventRepeater_Click;
			// 
			// MapEditorForm
			// 
			AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
			AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			ClientSize = new System.Drawing.Size(1153, 711);
			Controls.Add(buttonToolEventRepeater);
			Controls.Add(buttonToolEventChanger);
			Controls.Add(buttonToggleEvents);
			Controls.Add(groupBoxEvents);
			Controls.Add(buttonToolRemoveFrontLayer);
			Controls.Add(labelDivider);
			Controls.Add(buttonToggleTileMarker);
			Controls.Add(buttonToggleGrid);
			Controls.Add(buttonToolFill);
			Controls.Add(buttonToolBlocks);
			Controls.Add(statusStrip);
			Controls.Add(buttonToolLayers);
			Controls.Add(buttonToolColorPicker);
			Controls.Add(buttonToolBrush);
			Controls.Add(groupBoxCharacters);
			Controls.Add(groupBoxProperties);
			Controls.Add(groupBoxTileset);
			Controls.Add(panelMap);
			Controls.Add(menuStrip);
			Controls.Add(trackBarZoom);
			FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
			Icon = (System.Drawing.Icon)resources.GetObject("$this.Icon");
			MainMenuStrip = menuStrip;
			Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
			MaximizeBox = false;
			Name = "MapEditorForm";
			Text = "Ambermoon Map Editor 2D";
			FormClosing += MapEditorForm_FormClosing;
			FormClosed += MapEditorForm_FormClosed;
			Load += MapEditorForm_Load;
			KeyDown += MapEditorForm_KeyDown;
			menuStrip.ResumeLayout(false);
			menuStrip.PerformLayout();
			groupBoxTileset.ResumeLayout(false);
			groupBoxTileset.PerformLayout();
			groupBoxProperties.ResumeLayout(false);
			groupBoxProperties.PerformLayout();
			((System.ComponentModel.ISupportInitialize)numericUpDownHeight).EndInit();
			((System.ComponentModel.ISupportInitialize)numericUpDownWidth).EndInit();
			groupBoxCharacters.ResumeLayout(false);
			groupBoxCharacters.PerformLayout();
			contextMenuStripLayers.ResumeLayout(false);
			statusStrip.ResumeLayout(false);
			statusStrip.PerformLayout();
			contextMenuStripBlockModes.ResumeLayout(false);
			groupBoxEvents.ResumeLayout(false);
			((System.ComponentModel.ISupportInitialize)trackBarZoom).EndInit();
			ResumeLayout(false);
			PerformLayout();
		}

		#endregion

		private System.Windows.Forms.MapDrawPanel panelMap;
        private System.Windows.Forms.MenuStrip menuStrip;
        private System.Windows.Forms.GroupBox groupBoxTileset;
        private System.Windows.Forms.Button buttonDuplicateTile;
        private System.Windows.Forms.ScrollDrawPanel panelTileset;
        private System.Windows.Forms.ComboBox comboBoxTilesets;
        private System.Windows.Forms.GroupBox groupBoxProperties;
        private System.Windows.Forms.RadioButton radioButtonOutdoor;
        private System.Windows.Forms.RadioButton radioButtonIndoor;
        private System.Windows.Forms.RadioButton radioButtonDungeon;
        private System.Windows.Forms.ToolTip toolTipIndoor;
        private System.Windows.Forms.ToolTip toolTipOutdoor;
        private System.Windows.Forms.ToolTip toolTipDungeon;
        private System.Windows.Forms.CheckBox checkBoxResting;
        private System.Windows.Forms.CheckBox checkBoxNoSleepUntilDawn;
        private System.Windows.Forms.CheckBox checkBoxUnknown1;
        private System.Windows.Forms.ToolTip toolTipResting;
        private System.Windows.Forms.CheckBox checkBoxTravelGraphics;
        private System.Windows.Forms.ToolTip toolTipNoSleepUntilDawn;
        private System.Windows.Forms.Button buttonIndoorDefaults;
        private System.Windows.Forms.Button buttonWorldMapDefaults;
        private System.Windows.Forms.CheckBox checkBoxMagic;
        private System.Windows.Forms.CheckBox checkBoxWorldSurface;
        private System.Windows.Forms.ToolTip toolTipMagic;
        private System.Windows.Forms.ToolTip toolTipWorldSurface;
        private System.Windows.Forms.ComboBox comboBoxMusic;
        private System.Windows.Forms.Label labelMusic;
        private System.Windows.Forms.Button buttonResize;
        private System.Windows.Forms.Button buttonToggleMusic;
        private System.Windows.Forms.NumericUpDown numericUpDownHeight;
        private System.Windows.Forms.Label labelSize;
        private System.Windows.Forms.NumericUpDown numericUpDownWidth;
        private System.Windows.Forms.Label labelSizeCross;
        private System.Windows.Forms.GroupBox groupBoxCharacters;
        private System.Windows.Forms.Label labelCharacterPosition;
        private System.Windows.Forms.Button buttonPlaceCharacterOnMap;
        private System.Windows.Forms.ComboBox comboBoxWorld;
        private System.Windows.Forms.Button buttonToolBrush;
        private System.Windows.Forms.Button buttonToolColorPicker;
        private System.Windows.Forms.Button buttonToolLayers;
        private System.Windows.Forms.ContextMenuStrip contextMenuStripLayers;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemBackLayer;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemFrontLayer;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparatorLayers1;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemShowBackLayer;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemShowFrontLayer;
        private System.Windows.Forms.StatusStrip statusStrip;
        private System.Windows.Forms.Button buttonToolBlocks;
        private System.Windows.Forms.Button buttonToolFill;
        private System.Windows.Forms.Button buttonToggleGrid;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelTool;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelLayer;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelCurrentTile;
        private System.Windows.Forms.ContextMenuStrip contextMenuStripBlockModes;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemBlocks2x2;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemBlocks3x2;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemBlocks3x3;
        private System.Windows.Forms.ToolTip toolTipBrush;
        private System.Windows.Forms.ToolTip toolTipBlocks;
        private System.Windows.Forms.ToolTip toolTipFill;
        private System.Windows.Forms.ToolTip toolTipColorPicker;
        private System.Windows.Forms.ToolTip toolTipLayers;
        private System.Windows.Forms.ToolTip toolTipGrid;
        private System.Windows.Forms.Button buttonToggleTileMarker;
        private System.Windows.Forms.ToolTip toolTipTileMarker;
        private System.Windows.Forms.Label labelDivider;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelCurrentTilesetTile;
        private System.Windows.Forms.Button buttonEditTile;
        private System.Windows.Forms.ComboBox comboBoxPalettes;
        private System.Windows.Forms.Button buttonToolRemoveFrontLayer;
        private System.Windows.Forms.ToolTip toolTipRemoveFrontLayer;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemMap;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEdit;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEditUndo;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEditRedo;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparatorEdit1;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemMapNew;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemMapSave;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemMapSaveAs;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparatorMap1;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemMapQuit;
        private System.Windows.Forms.GroupBox groupBoxEvents;
        private System.Windows.Forms.Button buttonToggleEvents;
        private System.Windows.Forms.ListView listViewEvents;
        private System.Windows.Forms.ColumnHeader columnHeaderEventId;
        private System.Windows.Forms.ColumnHeader columnHeaderEventDescription;
        private System.Windows.Forms.Timer timerAnimation;
        private System.Windows.Forms.Button buttonExportTileset;
        private System.Windows.Forms.TrackBar trackBarZoom;
        private System.Windows.Forms.Button buttonToolEventChanger;
        private AmbermoonMapCharEditor.MapCharEditorControl mapCharEditorControl;
        private System.Windows.Forms.Button buttonPositions;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuShowAllowWalk;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuShowAllowHorse;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuShowAllowRaft;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuShowAllowShip;
        private System.Windows.Forms.CheckBox checkBoxMarkUnusedTiles;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuShowAllowDisc;
		private System.Windows.Forms.Button buttonToolEventRepeater;
	}
}

