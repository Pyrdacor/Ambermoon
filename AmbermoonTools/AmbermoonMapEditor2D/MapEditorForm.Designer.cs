
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MapEditorForm));
            this.panelMap = new System.Windows.Forms.MapDrawPanel();
            this.menuStrip = new System.Windows.Forms.MenuStrip();
            this.toolStripMenuItemMap = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemMapNew = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemMapSave = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemMapSaveAs = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparatorMap1 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemMapQuit = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEdit = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEditUndo = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEditRedo = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparatorEdit1 = new System.Windows.Forms.ToolStripSeparator();
            this.groupBoxTileset = new System.Windows.Forms.GroupBox();
            this.buttonExportTileset = new System.Windows.Forms.Button();
            this.buttonEditTile = new System.Windows.Forms.Button();
            this.comboBoxPalettes = new System.Windows.Forms.ComboBox();
            this.comboBoxTilesets = new System.Windows.Forms.ComboBox();
            this.buttonDuplicateTile = new System.Windows.Forms.Button();
            this.panelTileset = new System.Windows.Forms.ScrollDrawPanel();
            this.groupBoxProperties = new System.Windows.Forms.GroupBox();
            this.comboBoxWorld = new System.Windows.Forms.ComboBox();
            this.labelSizeCross = new System.Windows.Forms.Label();
            this.numericUpDownHeight = new System.Windows.Forms.NumericUpDown();
            this.labelSize = new System.Windows.Forms.Label();
            this.numericUpDownWidth = new System.Windows.Forms.NumericUpDown();
            this.buttonResize = new System.Windows.Forms.Button();
            this.buttonToggleMusic = new System.Windows.Forms.Button();
            this.comboBoxMusic = new System.Windows.Forms.ComboBox();
            this.labelMusic = new System.Windows.Forms.Label();
            this.checkBoxWorldSurface = new System.Windows.Forms.CheckBox();
            this.checkBoxMagic = new System.Windows.Forms.CheckBox();
            this.buttonIndoorDefaults = new System.Windows.Forms.Button();
            this.buttonWorldMapDefaults = new System.Windows.Forms.Button();
            this.checkBoxTravelGraphics = new System.Windows.Forms.CheckBox();
            this.checkBoxNoSleepUntilDawn = new System.Windows.Forms.CheckBox();
            this.checkBoxUnknown1 = new System.Windows.Forms.CheckBox();
            this.checkBoxResting = new System.Windows.Forms.CheckBox();
            this.radioButtonDungeon = new System.Windows.Forms.RadioButton();
            this.radioButtonOutdoor = new System.Windows.Forms.RadioButton();
            this.radioButtonIndoor = new System.Windows.Forms.RadioButton();
            this.toolTipIndoor = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipOutdoor = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipDungeon = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipResting = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipNoSleepUntilDawn = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipMagic = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipWorldSurface = new System.Windows.Forms.ToolTip(this.components);
            this.groupBoxCharacters = new System.Windows.Forms.GroupBox();
            this.buttonPositions = new System.Windows.Forms.Button();
            this.mapCharEditorControl = new AmbermoonMapCharEditor.MapCharEditorControl();
            this.buttonPlaceCharacterOnMap = new System.Windows.Forms.Button();
            this.labelCharacterPosition = new System.Windows.Forms.Label();
            this.buttonToolBrush = new System.Windows.Forms.Button();
            this.buttonToolColorPicker = new System.Windows.Forms.Button();
            this.buttonToolLayers = new System.Windows.Forms.Button();
            this.contextMenuStripLayers = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.toolStripMenuItemBackLayer = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemFrontLayer = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparatorLayers1 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemShowBackLayer = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemShowFrontLayer = new System.Windows.Forms.ToolStripMenuItem();
            this.statusStrip = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabelTool = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelLayer = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelCurrentTile = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelCurrentTilesetTile = new System.Windows.Forms.ToolStripStatusLabel();
            this.buttonToolBlocks = new System.Windows.Forms.Button();
            this.contextMenuStripBlockModes = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.toolStripMenuItemBlocks2x2 = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemBlocks3x2 = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemBlocks3x3 = new System.Windows.Forms.ToolStripMenuItem();
            this.buttonToolFill = new System.Windows.Forms.Button();
            this.buttonToggleGrid = new System.Windows.Forms.Button();
            this.toolTipBrush = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipBlocks = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipFill = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipColorPicker = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipLayers = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipGrid = new System.Windows.Forms.ToolTip(this.components);
            this.buttonToggleTileMarker = new System.Windows.Forms.Button();
            this.toolTipTileMarker = new System.Windows.Forms.ToolTip(this.components);
            this.labelDivider = new System.Windows.Forms.Label();
            this.buttonToolRemoveFrontLayer = new System.Windows.Forms.Button();
            this.toolTipRemoveFrontLayer = new System.Windows.Forms.ToolTip(this.components);
            this.groupBoxEvents = new System.Windows.Forms.GroupBox();
            this.listViewEvents = new System.Windows.Forms.ListView();
            this.columnHeaderEventId = new System.Windows.Forms.ColumnHeader();
            this.columnHeaderEventDescription = new System.Windows.Forms.ColumnHeader();
            this.buttonToggleEvents = new System.Windows.Forms.Button();
            this.timerAnimation = new System.Windows.Forms.Timer(this.components);
            this.trackBarZoom = new System.Windows.Forms.TrackBar();
            this.buttonToolEventChanger = new System.Windows.Forms.Button();
            this.menuStrip.SuspendLayout();
            this.groupBoxTileset.SuspendLayout();
            this.groupBoxProperties.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownHeight)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownWidth)).BeginInit();
            this.groupBoxCharacters.SuspendLayout();
            this.contextMenuStripLayers.SuspendLayout();
            this.statusStrip.SuspendLayout();
            this.contextMenuStripBlockModes.SuspendLayout();
            this.groupBoxEvents.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarZoom)).BeginInit();
            this.SuspendLayout();
            // 
            // panelMap
            // 
            this.panelMap.BackColor = System.Drawing.Color.Black;
            this.panelMap.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panelMap.Location = new System.Drawing.Point(0, 27);
            this.panelMap.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.panelMap.Name = "panelMap";
            this.panelMap.Size = new System.Drawing.Size(772, 484);
            this.panelMap.TabIndex = 0;
            this.panelMap.Scroll += new System.Windows.Forms.ScrollEventHandler(this.panelMap_Scroll);
            this.panelMap.Paint += new System.Windows.Forms.PaintEventHandler(this.panelMap_Paint);
            this.panelMap.MouseDown += new System.Windows.Forms.MouseEventHandler(this.panelMap_MouseDown);
            this.panelMap.MouseLeave += new System.EventHandler(this.panelMap_MouseLeave);
            this.panelMap.MouseMove += new System.Windows.Forms.MouseEventHandler(this.panelMap_MouseMove);
            // 
            // menuStrip
            // 
            this.menuStrip.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.menuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemMap,
            this.toolStripMenuItemEdit});
            this.menuStrip.Location = new System.Drawing.Point(0, 0);
            this.menuStrip.Name = "menuStrip";
            this.menuStrip.Size = new System.Drawing.Size(1153, 24);
            this.menuStrip.TabIndex = 1;
            this.menuStrip.Text = "menuStrip1";
            // 
            // toolStripMenuItemMap
            // 
            this.toolStripMenuItemMap.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemMapNew,
            this.toolStripMenuItemMapSave,
            this.toolStripMenuItemMapSaveAs,
            this.toolStripSeparatorMap1,
            this.toolStripMenuItemMapQuit});
            this.toolStripMenuItemMap.Name = "toolStripMenuItemMap";
            this.toolStripMenuItemMap.Size = new System.Drawing.Size(43, 20);
            this.toolStripMenuItemMap.Text = "&Map";
            // 
            // toolStripMenuItemMapNew
            // 
            this.toolStripMenuItemMapNew.Name = "toolStripMenuItemMapNew";
            this.toolStripMenuItemMapNew.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
            this.toolStripMenuItemMapNew.Size = new System.Drawing.Size(249, 22);
            this.toolStripMenuItemMapNew.Text = "New/Load ...";
            this.toolStripMenuItemMapNew.Click += new System.EventHandler(this.toolStripMenuItemMapNew_Click);
            // 
            // toolStripMenuItemMapSave
            // 
            this.toolStripMenuItemMapSave.Enabled = false;
            this.toolStripMenuItemMapSave.Name = "toolStripMenuItemMapSave";
            this.toolStripMenuItemMapSave.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.toolStripMenuItemMapSave.Size = new System.Drawing.Size(249, 22);
            this.toolStripMenuItemMapSave.Text = "Save";
            this.toolStripMenuItemMapSave.Click += new System.EventHandler(this.toolStripMenuItemMapSave_Click);
            // 
            // toolStripMenuItemMapSaveAs
            // 
            this.toolStripMenuItemMapSaveAs.Name = "toolStripMenuItemMapSaveAs";
            this.toolStripMenuItemMapSaveAs.ShortcutKeys = ((System.Windows.Forms.Keys)(((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Shift) 
            | System.Windows.Forms.Keys.S)));
            this.toolStripMenuItemMapSaveAs.Size = new System.Drawing.Size(249, 22);
            this.toolStripMenuItemMapSaveAs.Text = "Save as ...";
            this.toolStripMenuItemMapSaveAs.Click += new System.EventHandler(this.toolStripMenuItemMapSaveAs_Click);
            // 
            // toolStripSeparatorMap1
            // 
            this.toolStripSeparatorMap1.Name = "toolStripSeparatorMap1";
            this.toolStripSeparatorMap1.Size = new System.Drawing.Size(246, 6);
            // 
            // toolStripMenuItemMapQuit
            // 
            this.toolStripMenuItemMapQuit.Name = "toolStripMenuItemMapQuit";
            this.toolStripMenuItemMapQuit.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.F4)));
            this.toolStripMenuItemMapQuit.Size = new System.Drawing.Size(249, 22);
            this.toolStripMenuItemMapQuit.Text = "Quit";
            this.toolStripMenuItemMapQuit.Click += new System.EventHandler(this.toolStripMenuItemMapQuit_Click);
            // 
            // toolStripMenuItemEdit
            // 
            this.toolStripMenuItemEdit.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemEditUndo,
            this.toolStripMenuItemEditRedo,
            this.toolStripSeparatorEdit1});
            this.toolStripMenuItemEdit.Name = "toolStripMenuItemEdit";
            this.toolStripMenuItemEdit.Size = new System.Drawing.Size(39, 20);
            this.toolStripMenuItemEdit.Text = "&Edit";
            // 
            // toolStripMenuItemEditUndo
            // 
            this.toolStripMenuItemEditUndo.Enabled = false;
            this.toolStripMenuItemEditUndo.Name = "toolStripMenuItemEditUndo";
            this.toolStripMenuItemEditUndo.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Z)));
            this.toolStripMenuItemEditUndo.Size = new System.Drawing.Size(146, 22);
            this.toolStripMenuItemEditUndo.Text = "Undo";
            this.toolStripMenuItemEditUndo.Click += new System.EventHandler(this.toolStripMenuItemEditUndo_Click);
            // 
            // toolStripMenuItemEditRedo
            // 
            this.toolStripMenuItemEditRedo.Enabled = false;
            this.toolStripMenuItemEditRedo.Name = "toolStripMenuItemEditRedo";
            this.toolStripMenuItemEditRedo.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Y)));
            this.toolStripMenuItemEditRedo.Size = new System.Drawing.Size(146, 22);
            this.toolStripMenuItemEditRedo.Text = "Redo";
            this.toolStripMenuItemEditRedo.Click += new System.EventHandler(this.toolStripMenuItemEditRedo_Click);
            // 
            // toolStripSeparatorEdit1
            // 
            this.toolStripSeparatorEdit1.Name = "toolStripSeparatorEdit1";
            this.toolStripSeparatorEdit1.Size = new System.Drawing.Size(143, 6);
            // 
            // groupBoxTileset
            // 
            this.groupBoxTileset.Controls.Add(this.buttonExportTileset);
            this.groupBoxTileset.Controls.Add(this.buttonEditTile);
            this.groupBoxTileset.Controls.Add(this.comboBoxPalettes);
            this.groupBoxTileset.Controls.Add(this.comboBoxTilesets);
            this.groupBoxTileset.Controls.Add(this.buttonDuplicateTile);
            this.groupBoxTileset.Controls.Add(this.panelTileset);
            this.groupBoxTileset.Location = new System.Drawing.Point(2, 510);
            this.groupBoxTileset.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxTileset.Name = "groupBoxTileset";
            this.groupBoxTileset.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxTileset.Size = new System.Drawing.Size(803, 177);
            this.groupBoxTileset.TabIndex = 2;
            this.groupBoxTileset.TabStop = false;
            this.groupBoxTileset.Text = "Tileset";
            // 
            // buttonExportTileset
            // 
            this.buttonExportTileset.Location = new System.Drawing.Point(707, 148);
            this.buttonExportTileset.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonExportTileset.Name = "buttonExportTileset";
            this.buttonExportTileset.Size = new System.Drawing.Size(89, 24);
            this.buttonExportTileset.TabIndex = 5;
            this.buttonExportTileset.Text = "Export tileset ...";
            this.buttonExportTileset.UseVisualStyleBackColor = true;
            this.buttonExportTileset.Click += new System.EventHandler(this.buttonExportTileset_Click);
            // 
            // buttonEditTile
            // 
            this.buttonEditTile.Location = new System.Drawing.Point(707, 93);
            this.buttonEditTile.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonEditTile.Name = "buttonEditTile";
            this.buttonEditTile.Size = new System.Drawing.Size(89, 24);
            this.buttonEditTile.TabIndex = 4;
            this.buttonEditTile.Text = "Edit tile ...";
            this.buttonEditTile.UseVisualStyleBackColor = true;
            this.buttonEditTile.Click += new System.EventHandler(this.buttonEditTile_Click);
            // 
            // comboBoxPalettes
            // 
            this.comboBoxPalettes.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxPalettes.FormattingEnabled = true;
            this.comboBoxPalettes.Location = new System.Drawing.Point(707, 51);
            this.comboBoxPalettes.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.comboBoxPalettes.Name = "comboBoxPalettes";
            this.comboBoxPalettes.Size = new System.Drawing.Size(89, 23);
            this.comboBoxPalettes.TabIndex = 3;
            this.comboBoxPalettes.SelectedIndexChanged += new System.EventHandler(this.comboBoxPalettes_SelectedIndexChanged);
            // 
            // comboBoxTilesets
            // 
            this.comboBoxTilesets.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxTilesets.FormattingEnabled = true;
            this.comboBoxTilesets.Location = new System.Drawing.Point(707, 21);
            this.comboBoxTilesets.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.comboBoxTilesets.Name = "comboBoxTilesets";
            this.comboBoxTilesets.Size = new System.Drawing.Size(89, 23);
            this.comboBoxTilesets.TabIndex = 2;
            this.comboBoxTilesets.SelectedIndexChanged += new System.EventHandler(this.comboBoxTilesets_SelectedIndexChanged);
            // 
            // buttonDuplicateTile
            // 
            this.buttonDuplicateTile.Location = new System.Drawing.Point(707, 120);
            this.buttonDuplicateTile.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonDuplicateTile.Name = "buttonDuplicateTile";
            this.buttonDuplicateTile.Size = new System.Drawing.Size(89, 24);
            this.buttonDuplicateTile.TabIndex = 1;
            this.buttonDuplicateTile.Text = "Duplicate tile";
            this.buttonDuplicateTile.UseVisualStyleBackColor = true;
            this.buttonDuplicateTile.Click += new System.EventHandler(this.buttonDuplicateTile_Click);
            // 
            // panelTileset
            // 
            this.panelTileset.AutoScroll = true;
            this.panelTileset.BackColor = System.Drawing.Color.Black;
            this.panelTileset.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panelTileset.Location = new System.Drawing.Point(9, 21);
            this.panelTileset.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.panelTileset.Name = "panelTileset";
            this.panelTileset.Size = new System.Drawing.Size(695, 149);
            this.panelTileset.TabIndex = 0;
            this.panelTileset.Paint += new System.Windows.Forms.PaintEventHandler(this.panelTileset_Paint);
            this.panelTileset.MouseDown += new System.Windows.Forms.MouseEventHandler(this.panelTileset_MouseDown);
            this.panelTileset.MouseLeave += new System.EventHandler(this.panelTileset_MouseLeave);
            this.panelTileset.MouseMove += new System.Windows.Forms.MouseEventHandler(this.panelTileset_MouseMove);
            // 
            // groupBoxProperties
            // 
            this.groupBoxProperties.Controls.Add(this.comboBoxWorld);
            this.groupBoxProperties.Controls.Add(this.labelSizeCross);
            this.groupBoxProperties.Controls.Add(this.numericUpDownHeight);
            this.groupBoxProperties.Controls.Add(this.labelSize);
            this.groupBoxProperties.Controls.Add(this.numericUpDownWidth);
            this.groupBoxProperties.Controls.Add(this.buttonResize);
            this.groupBoxProperties.Controls.Add(this.buttonToggleMusic);
            this.groupBoxProperties.Controls.Add(this.comboBoxMusic);
            this.groupBoxProperties.Controls.Add(this.labelMusic);
            this.groupBoxProperties.Controls.Add(this.checkBoxWorldSurface);
            this.groupBoxProperties.Controls.Add(this.checkBoxMagic);
            this.groupBoxProperties.Controls.Add(this.buttonIndoorDefaults);
            this.groupBoxProperties.Controls.Add(this.buttonWorldMapDefaults);
            this.groupBoxProperties.Controls.Add(this.checkBoxTravelGraphics);
            this.groupBoxProperties.Controls.Add(this.checkBoxNoSleepUntilDawn);
            this.groupBoxProperties.Controls.Add(this.checkBoxUnknown1);
            this.groupBoxProperties.Controls.Add(this.checkBoxResting);
            this.groupBoxProperties.Controls.Add(this.radioButtonDungeon);
            this.groupBoxProperties.Controls.Add(this.radioButtonOutdoor);
            this.groupBoxProperties.Controls.Add(this.radioButtonIndoor);
            this.groupBoxProperties.Location = new System.Drawing.Point(807, 26);
            this.groupBoxProperties.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxProperties.Name = "groupBoxProperties";
            this.groupBoxProperties.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxProperties.Size = new System.Drawing.Size(338, 224);
            this.groupBoxProperties.TabIndex = 3;
            this.groupBoxProperties.TabStop = false;
            this.groupBoxProperties.Text = "Properties";
            // 
            // comboBoxWorld
            // 
            this.comboBoxWorld.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxWorld.FormattingEnabled = true;
            this.comboBoxWorld.Items.AddRange(new object[] {
            "Lyramion",
            "Forest Moon",
            "Morag"});
            this.comboBoxWorld.Location = new System.Drawing.Point(229, 45);
            this.comboBoxWorld.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.comboBoxWorld.Name = "comboBoxWorld";
            this.comboBoxWorld.Size = new System.Drawing.Size(104, 23);
            this.comboBoxWorld.TabIndex = 21;
            this.comboBoxWorld.SelectedIndexChanged += new System.EventHandler(this.comboBoxWorld_SelectedIndexChanged);
            // 
            // labelSizeCross
            // 
            this.labelSizeCross.AutoSize = true;
            this.labelSizeCross.Location = new System.Drawing.Point(90, 24);
            this.labelSizeCross.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelSizeCross.Name = "labelSizeCross";
            this.labelSizeCross.Size = new System.Drawing.Size(12, 15);
            this.labelSizeCross.TabIndex = 20;
            this.labelSizeCross.Text = "x";
            // 
            // numericUpDownHeight
            // 
            this.numericUpDownHeight.Enabled = false;
            this.numericUpDownHeight.Location = new System.Drawing.Point(104, 21);
            this.numericUpDownHeight.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.numericUpDownHeight.Maximum = new decimal(new int[] {
            200,
            0,
            0,
            0});
            this.numericUpDownHeight.Minimum = new decimal(new int[] {
            9,
            0,
            0,
            0});
            this.numericUpDownHeight.Name = "numericUpDownHeight";
            this.numericUpDownHeight.Size = new System.Drawing.Size(44, 23);
            this.numericUpDownHeight.TabIndex = 19;
            this.numericUpDownHeight.Value = new decimal(new int[] {
            50,
            0,
            0,
            0});
            this.numericUpDownHeight.ValueChanged += new System.EventHandler(this.numericUpDownHeight_ValueChanged);
            // 
            // labelSize
            // 
            this.labelSize.AutoSize = true;
            this.labelSize.Location = new System.Drawing.Point(7, 24);
            this.labelSize.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelSize.Name = "labelSize";
            this.labelSize.Size = new System.Drawing.Size(30, 15);
            this.labelSize.TabIndex = 18;
            this.labelSize.Text = "Size:";
            // 
            // numericUpDownWidth
            // 
            this.numericUpDownWidth.Enabled = false;
            this.numericUpDownWidth.Location = new System.Drawing.Point(43, 20);
            this.numericUpDownWidth.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.numericUpDownWidth.Maximum = new decimal(new int[] {
            200,
            0,
            0,
            0});
            this.numericUpDownWidth.Minimum = new decimal(new int[] {
            11,
            0,
            0,
            0});
            this.numericUpDownWidth.Name = "numericUpDownWidth";
            this.numericUpDownWidth.Size = new System.Drawing.Size(44, 23);
            this.numericUpDownWidth.TabIndex = 17;
            this.numericUpDownWidth.Value = new decimal(new int[] {
            50,
            0,
            0,
            0});
            this.numericUpDownWidth.ValueChanged += new System.EventHandler(this.numericUpDownWidth_ValueChanged);
            // 
            // buttonResize
            // 
            this.buttonResize.Location = new System.Drawing.Point(154, 21);
            this.buttonResize.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonResize.Name = "buttonResize";
            this.buttonResize.Size = new System.Drawing.Size(104, 24);
            this.buttonResize.TabIndex = 16;
            this.buttonResize.Text = "Enable resizing";
            this.buttonResize.UseVisualStyleBackColor = true;
            this.buttonResize.Click += new System.EventHandler(this.buttonResize_Click);
            // 
            // buttonToggleMusic
            // 
            this.buttonToggleMusic.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_play_arrow_black_24;
            this.buttonToggleMusic.Location = new System.Drawing.Point(308, 186);
            this.buttonToggleMusic.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToggleMusic.Name = "buttonToggleMusic";
            this.buttonToggleMusic.Size = new System.Drawing.Size(23, 24);
            this.buttonToggleMusic.TabIndex = 15;
            this.buttonToggleMusic.UseVisualStyleBackColor = true;
            this.buttonToggleMusic.Click += new System.EventHandler(this.buttonToggleMusic_Click);
            // 
            // comboBoxMusic
            // 
            this.comboBoxMusic.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxMusic.FormattingEnabled = true;
            this.comboBoxMusic.Location = new System.Drawing.Point(55, 186);
            this.comboBoxMusic.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.comboBoxMusic.Name = "comboBoxMusic";
            this.comboBoxMusic.Size = new System.Drawing.Size(250, 23);
            this.comboBoxMusic.TabIndex = 14;
            this.comboBoxMusic.SelectedIndexChanged += new System.EventHandler(this.comboBoxMusic_SelectedIndexChanged);
            // 
            // labelMusic
            // 
            this.labelMusic.AutoSize = true;
            this.labelMusic.Location = new System.Drawing.Point(7, 190);
            this.labelMusic.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelMusic.Name = "labelMusic";
            this.labelMusic.Size = new System.Drawing.Size(42, 15);
            this.labelMusic.TabIndex = 13;
            this.labelMusic.Text = "Music:";
            // 
            // checkBoxWorldSurface
            // 
            this.checkBoxWorldSurface.AutoSize = true;
            this.checkBoxWorldSurface.Enabled = false;
            this.checkBoxWorldSurface.Location = new System.Drawing.Point(7, 71);
            this.checkBoxWorldSurface.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.checkBoxWorldSurface.Name = "checkBoxWorldSurface";
            this.checkBoxWorldSurface.Size = new System.Drawing.Size(85, 19);
            this.checkBoxWorldSurface.TabIndex = 12;
            this.checkBoxWorldSurface.Text = "World Map";
            this.checkBoxWorldSurface.UseVisualStyleBackColor = true;
            this.checkBoxWorldSurface.CheckedChanged += new System.EventHandler(this.checkBoxWorldSurface_CheckedChanged);
            // 
            // checkBoxMagic
            // 
            this.checkBoxMagic.AutoSize = true;
            this.checkBoxMagic.Checked = true;
            this.checkBoxMagic.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBoxMagic.Location = new System.Drawing.Point(7, 121);
            this.checkBoxMagic.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.checkBoxMagic.Name = "checkBoxMagic";
            this.checkBoxMagic.Size = new System.Drawing.Size(92, 19);
            this.checkBoxMagic.TabIndex = 11;
            this.checkBoxMagic.Text = "Allow Magic";
            this.checkBoxMagic.UseVisualStyleBackColor = true;
            this.checkBoxMagic.CheckedChanged += new System.EventHandler(this.checkBoxMagic_CheckedChanged);
            // 
            // buttonIndoorDefaults
            // 
            this.buttonIndoorDefaults.Location = new System.Drawing.Point(173, 145);
            this.buttonIndoorDefaults.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonIndoorDefaults.Name = "buttonIndoorDefaults";
            this.buttonIndoorDefaults.Size = new System.Drawing.Size(160, 24);
            this.buttonIndoorDefaults.TabIndex = 9;
            this.buttonIndoorDefaults.Text = "Use Indoor Defaults";
            this.buttonIndoorDefaults.UseVisualStyleBackColor = true;
            this.buttonIndoorDefaults.Click += new System.EventHandler(this.buttonIndoorDefaults_Click);
            // 
            // buttonWorldMapDefaults
            // 
            this.buttonWorldMapDefaults.Location = new System.Drawing.Point(6, 145);
            this.buttonWorldMapDefaults.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonWorldMapDefaults.Name = "buttonWorldMapDefaults";
            this.buttonWorldMapDefaults.Size = new System.Drawing.Size(160, 24);
            this.buttonWorldMapDefaults.TabIndex = 8;
            this.buttonWorldMapDefaults.Text = "Use World Map Defaults";
            this.buttonWorldMapDefaults.UseVisualStyleBackColor = true;
            this.buttonWorldMapDefaults.Click += new System.EventHandler(this.buttonWorldMapDefaults_Click);
            // 
            // checkBoxTravelGraphics
            // 
            this.checkBoxTravelGraphics.AutoSize = true;
            this.checkBoxTravelGraphics.Enabled = false;
            this.checkBoxTravelGraphics.Location = new System.Drawing.Point(111, 71);
            this.checkBoxTravelGraphics.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.checkBoxTravelGraphics.Name = "checkBoxTravelGraphics";
            this.checkBoxTravelGraphics.Size = new System.Drawing.Size(107, 19);
            this.checkBoxTravelGraphics.TabIndex = 7;
            this.checkBoxTravelGraphics.Text = "Travel Graphics";
            this.checkBoxTravelGraphics.UseVisualStyleBackColor = true;
            this.checkBoxTravelGraphics.CheckedChanged += new System.EventHandler(this.checkBoxTravelGraphics_CheckedChanged);
            // 
            // checkBoxNoSleepUntilDawn
            // 
            this.checkBoxNoSleepUntilDawn.AutoSize = true;
            this.checkBoxNoSleepUntilDawn.Location = new System.Drawing.Point(111, 96);
            this.checkBoxNoSleepUntilDawn.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.checkBoxNoSleepUntilDawn.Name = "checkBoxNoSleepUntilDawn";
            this.checkBoxNoSleepUntilDawn.Size = new System.Drawing.Size(134, 19);
            this.checkBoxNoSleepUntilDawn.TabIndex = 6;
            this.checkBoxNoSleepUntilDawn.Text = "No Sleep Until Dawn";
            this.checkBoxNoSleepUntilDawn.UseVisualStyleBackColor = true;
            this.checkBoxNoSleepUntilDawn.CheckedChanged += new System.EventHandler(this.checkBoxNoSleepUntilDawn_CheckedChanged);
            // 
            // checkBoxUnknown1
            // 
            this.checkBoxUnknown1.AutoSize = true;
            this.checkBoxUnknown1.Enabled = false;
            this.checkBoxUnknown1.Location = new System.Drawing.Point(111, 121);
            this.checkBoxUnknown1.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.checkBoxUnknown1.Name = "checkBoxUnknown1";
            this.checkBoxUnknown1.Size = new System.Drawing.Size(77, 19);
            this.checkBoxUnknown1.TabIndex = 5;
            this.checkBoxUnknown1.Text = "Unknown";
            this.checkBoxUnknown1.UseVisualStyleBackColor = true;
            this.checkBoxUnknown1.CheckedChanged += new System.EventHandler(this.checkBoxUnknown1_CheckedChanged);
            // 
            // checkBoxResting
            // 
            this.checkBoxResting.AutoSize = true;
            this.checkBoxResting.Checked = true;
            this.checkBoxResting.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBoxResting.Location = new System.Drawing.Point(7, 96);
            this.checkBoxResting.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.checkBoxResting.Name = "checkBoxResting";
            this.checkBoxResting.Size = new System.Drawing.Size(98, 19);
            this.checkBoxResting.TabIndex = 4;
            this.checkBoxResting.Text = "Allow Resting";
            this.checkBoxResting.UseVisualStyleBackColor = true;
            this.checkBoxResting.CheckedChanged += new System.EventHandler(this.checkBoxResting_CheckedChanged);
            // 
            // radioButtonDungeon
            // 
            this.radioButtonDungeon.AutoSize = true;
            this.radioButtonDungeon.Location = new System.Drawing.Point(148, 46);
            this.radioButtonDungeon.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.radioButtonDungeon.Name = "radioButtonDungeon";
            this.radioButtonDungeon.Size = new System.Drawing.Size(74, 19);
            this.radioButtonDungeon.TabIndex = 2;
            this.radioButtonDungeon.Text = "Dungeon";
            this.radioButtonDungeon.UseVisualStyleBackColor = true;
            this.radioButtonDungeon.CheckedChanged += new System.EventHandler(this.radioButtonDungeon_CheckedChanged);
            // 
            // radioButtonOutdoor
            // 
            this.radioButtonOutdoor.AutoSize = true;
            this.radioButtonOutdoor.Location = new System.Drawing.Point(72, 46);
            this.radioButtonOutdoor.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.radioButtonOutdoor.Name = "radioButtonOutdoor";
            this.radioButtonOutdoor.Size = new System.Drawing.Size(70, 19);
            this.radioButtonOutdoor.TabIndex = 1;
            this.radioButtonOutdoor.Text = "Outdoor";
            this.radioButtonOutdoor.UseVisualStyleBackColor = true;
            this.radioButtonOutdoor.CheckedChanged += new System.EventHandler(this.radioButtonOutdoor_CheckedChanged);
            // 
            // radioButtonIndoor
            // 
            this.radioButtonIndoor.AutoSize = true;
            this.radioButtonIndoor.Checked = true;
            this.radioButtonIndoor.Location = new System.Drawing.Point(6, 46);
            this.radioButtonIndoor.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.radioButtonIndoor.Name = "radioButtonIndoor";
            this.radioButtonIndoor.Size = new System.Drawing.Size(60, 19);
            this.radioButtonIndoor.TabIndex = 0;
            this.radioButtonIndoor.TabStop = true;
            this.radioButtonIndoor.Text = "Indoor";
            this.radioButtonIndoor.UseVisualStyleBackColor = true;
            this.radioButtonIndoor.CheckedChanged += new System.EventHandler(this.radioButtonIndoor_CheckedChanged);
            // 
            // groupBoxCharacters
            // 
            this.groupBoxCharacters.Controls.Add(this.buttonPositions);
            this.groupBoxCharacters.Controls.Add(this.mapCharEditorControl);
            this.groupBoxCharacters.Controls.Add(this.buttonPlaceCharacterOnMap);
            this.groupBoxCharacters.Controls.Add(this.labelCharacterPosition);
            this.groupBoxCharacters.Location = new System.Drawing.Point(807, 256);
            this.groupBoxCharacters.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxCharacters.Name = "groupBoxCharacters";
            this.groupBoxCharacters.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxCharacters.Size = new System.Drawing.Size(338, 291);
            this.groupBoxCharacters.TabIndex = 4;
            this.groupBoxCharacters.TabStop = false;
            this.groupBoxCharacters.Text = "Monsters && NPCs";
            // 
            // buttonPositions
            // 
            this.buttonPositions.Location = new System.Drawing.Point(124, 261);
            this.buttonPositions.Name = "buttonPositions";
            this.buttonPositions.Size = new System.Drawing.Size(86, 24);
            this.buttonPositions.TabIndex = 17;
            this.buttonPositions.Text = "Positions ...";
            this.buttonPositions.UseVisualStyleBackColor = true;
            this.buttonPositions.Click += new System.EventHandler(this.buttonPositions_Click);
            // 
            // mapCharEditorControl
            // 
            this.mapCharEditorControl.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.mapCharEditorControl.Location = new System.Drawing.Point(7, 21);
            this.mapCharEditorControl.Margin = new System.Windows.Forms.Padding(2, 4, 2, 4);
            this.mapCharEditorControl.Name = "mapCharEditorControl";
            this.mapCharEditorControl.Size = new System.Drawing.Size(322, 234);
            this.mapCharEditorControl.TabIndex = 0;
            this.mapCharEditorControl.Visible = false;
            this.mapCharEditorControl.Load += new System.EventHandler(this.mapCharEditorControl_Load);
            // 
            // buttonPlaceCharacterOnMap
            // 
            this.buttonPlaceCharacterOnMap.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonPlaceCharacterOnMap.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_control_camera_black_24;
            this.buttonPlaceCharacterOnMap.Location = new System.Drawing.Point(215, 261);
            this.buttonPlaceCharacterOnMap.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonPlaceCharacterOnMap.Name = "buttonPlaceCharacterOnMap";
            this.buttonPlaceCharacterOnMap.Size = new System.Drawing.Size(23, 24);
            this.buttonPlaceCharacterOnMap.TabIndex = 16;
            this.buttonPlaceCharacterOnMap.UseVisualStyleBackColor = true;
            this.buttonPlaceCharacterOnMap.EnabledChanged += new System.EventHandler(this.buttonPlaceCharacterOnMap_EnabledChanged);
            this.buttonPlaceCharacterOnMap.Click += new System.EventHandler(this.buttonPlaceCharacterOnMap_Click);
            // 
            // labelCharacterPosition
            // 
            this.labelCharacterPosition.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.labelCharacterPosition.AutoSize = true;
            this.labelCharacterPosition.Location = new System.Drawing.Point(240, 267);
            this.labelCharacterPosition.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelCharacterPosition.Name = "labelCharacterPosition";
            this.labelCharacterPosition.Size = new System.Drawing.Size(89, 15);
            this.labelCharacterPosition.TabIndex = 4;
            this.labelCharacterPosition.Text = "Location: 50, 50";
            // 
            // buttonToolBrush
            // 
            this.buttonToolBrush.ForeColor = System.Drawing.SystemColors.ControlText;
            this.buttonToolBrush.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_brush_black_24;
            this.buttonToolBrush.Location = new System.Drawing.Point(772, 27);
            this.buttonToolBrush.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToolBrush.Name = "buttonToolBrush";
            this.buttonToolBrush.Size = new System.Drawing.Size(33, 32);
            this.buttonToolBrush.TabIndex = 5;
            this.buttonToolBrush.UseVisualStyleBackColor = true;
            this.buttonToolBrush.Click += new System.EventHandler(this.buttonToolBrush_Click);
            // 
            // buttonToolColorPicker
            // 
            this.buttonToolColorPicker.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_colorize_black_24;
            this.buttonToolColorPicker.Location = new System.Drawing.Point(772, 179);
            this.buttonToolColorPicker.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToolColorPicker.Name = "buttonToolColorPicker";
            this.buttonToolColorPicker.Size = new System.Drawing.Size(33, 32);
            this.buttonToolColorPicker.TabIndex = 6;
            this.buttonToolColorPicker.UseVisualStyleBackColor = true;
            this.buttonToolColorPicker.Click += new System.EventHandler(this.buttonToolColorPicker_Click);
            // 
            // buttonToolLayers
            // 
            this.buttonToolLayers.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_layers_black_24;
            this.buttonToolLayers.Location = new System.Drawing.Point(772, 264);
            this.buttonToolLayers.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToolLayers.Name = "buttonToolLayers";
            this.buttonToolLayers.Size = new System.Drawing.Size(33, 32);
            this.buttonToolLayers.TabIndex = 7;
            this.buttonToolLayers.UseVisualStyleBackColor = true;
            this.buttonToolLayers.Click += new System.EventHandler(this.buttonToolLayers_Click);
            // 
            // contextMenuStripLayers
            // 
            this.contextMenuStripLayers.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.contextMenuStripLayers.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemBackLayer,
            this.toolStripMenuItemFrontLayer,
            this.toolStripSeparatorLayers1,
            this.toolStripMenuItemShowBackLayer,
            this.toolStripMenuItemShowFrontLayer});
            this.contextMenuStripLayers.Name = "contextMenuStripLayers";
            this.contextMenuStripLayers.Size = new System.Drawing.Size(166, 98);
            // 
            // toolStripMenuItemBackLayer
            // 
            this.toolStripMenuItemBackLayer.Checked = true;
            this.toolStripMenuItemBackLayer.CheckOnClick = true;
            this.toolStripMenuItemBackLayer.CheckState = System.Windows.Forms.CheckState.Checked;
            this.toolStripMenuItemBackLayer.Name = "toolStripMenuItemBackLayer";
            this.toolStripMenuItemBackLayer.Size = new System.Drawing.Size(165, 22);
            this.toolStripMenuItemBackLayer.Text = "Back Layer";
            this.toolStripMenuItemBackLayer.Click += new System.EventHandler(this.toolStripMenuItemBackLayer_Click);
            // 
            // toolStripMenuItemFrontLayer
            // 
            this.toolStripMenuItemFrontLayer.CheckOnClick = true;
            this.toolStripMenuItemFrontLayer.Name = "toolStripMenuItemFrontLayer";
            this.toolStripMenuItemFrontLayer.Size = new System.Drawing.Size(165, 22);
            this.toolStripMenuItemFrontLayer.Text = "Front Layer";
            this.toolStripMenuItemFrontLayer.Click += new System.EventHandler(this.toolStripMenuItemFrontLayer_Click);
            // 
            // toolStripSeparatorLayers1
            // 
            this.toolStripSeparatorLayers1.Name = "toolStripSeparatorLayers1";
            this.toolStripSeparatorLayers1.Size = new System.Drawing.Size(162, 6);
            // 
            // toolStripMenuItemShowBackLayer
            // 
            this.toolStripMenuItemShowBackLayer.Checked = true;
            this.toolStripMenuItemShowBackLayer.CheckOnClick = true;
            this.toolStripMenuItemShowBackLayer.CheckState = System.Windows.Forms.CheckState.Checked;
            this.toolStripMenuItemShowBackLayer.Name = "toolStripMenuItemShowBackLayer";
            this.toolStripMenuItemShowBackLayer.Size = new System.Drawing.Size(165, 22);
            this.toolStripMenuItemShowBackLayer.Text = "Show Back Layer";
            this.toolStripMenuItemShowBackLayer.Click += new System.EventHandler(this.toolStripMenuItemShowBackLayer_Click);
            // 
            // toolStripMenuItemShowFrontLayer
            // 
            this.toolStripMenuItemShowFrontLayer.Checked = true;
            this.toolStripMenuItemShowFrontLayer.CheckOnClick = true;
            this.toolStripMenuItemShowFrontLayer.CheckState = System.Windows.Forms.CheckState.Checked;
            this.toolStripMenuItemShowFrontLayer.Name = "toolStripMenuItemShowFrontLayer";
            this.toolStripMenuItemShowFrontLayer.Size = new System.Drawing.Size(165, 22);
            this.toolStripMenuItemShowFrontLayer.Text = "Show Front Layer";
            this.toolStripMenuItemShowFrontLayer.Click += new System.EventHandler(this.toolStripMenuItemShowFrontLayer_Click);
            // 
            // statusStrip
            // 
            this.statusStrip.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabelTool,
            this.toolStripStatusLabelLayer,
            this.toolStripStatusLabelCurrentTile,
            this.toolStripStatusLabelCurrentTilesetTile});
            this.statusStrip.Location = new System.Drawing.Point(0, 686);
            this.statusStrip.Name = "statusStrip";
            this.statusStrip.Size = new System.Drawing.Size(1153, 25);
            this.statusStrip.SizingGrip = false;
            this.statusStrip.TabIndex = 8;
            this.statusStrip.Text = "statusStrip1";
            // 
            // toolStripStatusLabelTool
            // 
            this.toolStripStatusLabelTool.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_brush_black_24;
            this.toolStripStatusLabelTool.Name = "toolStripStatusLabelTool";
            this.toolStripStatusLabelTool.Size = new System.Drawing.Size(20, 20);
            // 
            // toolStripStatusLabelLayer
            // 
            this.toolStripStatusLabelLayer.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
            this.toolStripStatusLabelLayer.BorderStyle = System.Windows.Forms.Border3DStyle.Etched;
            this.toolStripStatusLabelLayer.Name = "toolStripStatusLabelLayer";
            this.toolStripStatusLabelLayer.Size = new System.Drawing.Size(67, 20);
            this.toolStripStatusLabelLayer.Text = "Back Layer";
            // 
            // toolStripStatusLabelCurrentTile
            // 
            this.toolStripStatusLabelCurrentTile.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
            this.toolStripStatusLabelCurrentTile.BorderStyle = System.Windows.Forms.Border3DStyle.Etched;
            this.toolStripStatusLabelCurrentTile.Name = "toolStripStatusLabelCurrentTile";
            this.toolStripStatusLabelCurrentTile.Size = new System.Drawing.Size(29, 20);
            this.toolStripStatusLabelCurrentTile.Text = "0, 0";
            this.toolStripStatusLabelCurrentTile.Visible = false;
            // 
            // toolStripStatusLabelCurrentTilesetTile
            // 
            this.toolStripStatusLabelCurrentTilesetTile.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
            this.toolStripStatusLabelCurrentTilesetTile.BorderStyle = System.Windows.Forms.Border3DStyle.Etched;
            this.toolStripStatusLabelCurrentTilesetTile.Name = "toolStripStatusLabelCurrentTilesetTile";
            this.toolStripStatusLabelCurrentTilesetTile.Size = new System.Drawing.Size(29, 20);
            this.toolStripStatusLabelCurrentTilesetTile.Text = "0, 0";
            this.toolStripStatusLabelCurrentTilesetTile.Visible = false;
            // 
            // buttonToolBlocks
            // 
            this.buttonToolBlocks.ContextMenuStrip = this.contextMenuStripBlockModes;
            this.buttonToolBlocks.ForeColor = System.Drawing.SystemColors.ControlText;
            this.buttonToolBlocks.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_grid_view_black_24_with_arrow;
            this.buttonToolBlocks.Location = new System.Drawing.Point(772, 65);
            this.buttonToolBlocks.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToolBlocks.Name = "buttonToolBlocks";
            this.buttonToolBlocks.Size = new System.Drawing.Size(33, 32);
            this.buttonToolBlocks.TabIndex = 9;
            this.buttonToolBlocks.UseVisualStyleBackColor = true;
            this.buttonToolBlocks.Click += new System.EventHandler(this.buttonToolBlocks_Click);
            // 
            // contextMenuStripBlockModes
            // 
            this.contextMenuStripBlockModes.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.contextMenuStripBlockModes.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemBlocks2x2,
            this.toolStripMenuItemBlocks3x2,
            this.toolStripMenuItemBlocks3x3});
            this.contextMenuStripBlockModes.Name = "contextMenuStripBlockModes";
            this.contextMenuStripBlockModes.Size = new System.Drawing.Size(96, 82);
            // 
            // toolStripMenuItemBlocks2x2
            // 
            this.toolStripMenuItemBlocks2x2.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_grid_view_black_24;
            this.toolStripMenuItemBlocks2x2.Name = "toolStripMenuItemBlocks2x2";
            this.toolStripMenuItemBlocks2x2.Size = new System.Drawing.Size(95, 26);
            this.toolStripMenuItemBlocks2x2.Text = "2x2";
            this.toolStripMenuItemBlocks2x2.Click += new System.EventHandler(this.toolStripMenuItemBlocks2x2_Click);
            // 
            // toolStripMenuItemBlocks3x2
            // 
            this.toolStripMenuItemBlocks3x2.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_view_module_black_24;
            this.toolStripMenuItemBlocks3x2.Name = "toolStripMenuItemBlocks3x2";
            this.toolStripMenuItemBlocks3x2.Size = new System.Drawing.Size(95, 26);
            this.toolStripMenuItemBlocks3x2.Text = "3x2";
            this.toolStripMenuItemBlocks3x2.Click += new System.EventHandler(this.toolStripMenuItemBlocks3x2_Click);
            // 
            // toolStripMenuItemBlocks3x3
            // 
            this.toolStripMenuItemBlocks3x3.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_apps_black_24;
            this.toolStripMenuItemBlocks3x3.Name = "toolStripMenuItemBlocks3x3";
            this.toolStripMenuItemBlocks3x3.Size = new System.Drawing.Size(95, 26);
            this.toolStripMenuItemBlocks3x3.Text = "3x3";
            this.toolStripMenuItemBlocks3x3.Click += new System.EventHandler(this.toolStripMenuItemBlocks3x3_Click);
            // 
            // buttonToolFill
            // 
            this.buttonToolFill.ForeColor = System.Drawing.SystemColors.ControlText;
            this.buttonToolFill.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_format_color_fill_black_24;
            this.buttonToolFill.Location = new System.Drawing.Point(772, 103);
            this.buttonToolFill.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToolFill.Name = "buttonToolFill";
            this.buttonToolFill.Size = new System.Drawing.Size(33, 32);
            this.buttonToolFill.TabIndex = 10;
            this.buttonToolFill.UseVisualStyleBackColor = true;
            this.buttonToolFill.Click += new System.EventHandler(this.buttonToolFill_Click);
            // 
            // buttonToggleGrid
            // 
            this.buttonToggleGrid.ForeColor = System.Drawing.SystemColors.ControlText;
            this.buttonToggleGrid.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_grid_off_black_24;
            this.buttonToggleGrid.Location = new System.Drawing.Point(772, 302);
            this.buttonToggleGrid.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToggleGrid.Name = "buttonToggleGrid";
            this.buttonToggleGrid.Size = new System.Drawing.Size(33, 32);
            this.buttonToggleGrid.TabIndex = 11;
            this.buttonToggleGrid.UseVisualStyleBackColor = true;
            this.buttonToggleGrid.Click += new System.EventHandler(this.buttonToggleGrid_Click);
            // 
            // buttonToggleTileMarker
            // 
            this.buttonToggleTileMarker.ForeColor = System.Drawing.SystemColors.ControlText;
            this.buttonToggleTileMarker.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_select_all_black_24;
            this.buttonToggleTileMarker.Location = new System.Drawing.Point(772, 340);
            this.buttonToggleTileMarker.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToggleTileMarker.Name = "buttonToggleTileMarker";
            this.buttonToggleTileMarker.Size = new System.Drawing.Size(33, 32);
            this.buttonToggleTileMarker.TabIndex = 12;
            this.buttonToggleTileMarker.UseVisualStyleBackColor = true;
            this.buttonToggleTileMarker.Click += new System.EventHandler(this.buttonToggleTileMarker_Click);
            // 
            // labelDivider
            // 
            this.labelDivider.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.labelDivider.Location = new System.Drawing.Point(772, 255);
            this.labelDivider.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelDivider.Name = "labelDivider";
            this.labelDivider.Size = new System.Drawing.Size(33, 2);
            this.labelDivider.TabIndex = 13;
            // 
            // buttonToolRemoveFrontLayer
            // 
            this.buttonToolRemoveFrontLayer.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_layers_clear_black_24;
            this.buttonToolRemoveFrontLayer.Location = new System.Drawing.Point(772, 141);
            this.buttonToolRemoveFrontLayer.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToolRemoveFrontLayer.Name = "buttonToolRemoveFrontLayer";
            this.buttonToolRemoveFrontLayer.Size = new System.Drawing.Size(33, 32);
            this.buttonToolRemoveFrontLayer.TabIndex = 14;
            this.buttonToolRemoveFrontLayer.UseVisualStyleBackColor = true;
            this.buttonToolRemoveFrontLayer.Click += new System.EventHandler(this.buttonToolRemoveFrontLayer_Click);
            // 
            // groupBoxEvents
            // 
            this.groupBoxEvents.Controls.Add(this.listViewEvents);
            this.groupBoxEvents.Location = new System.Drawing.Point(807, 553);
            this.groupBoxEvents.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxEvents.Name = "groupBoxEvents";
            this.groupBoxEvents.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.groupBoxEvents.Size = new System.Drawing.Size(338, 129);
            this.groupBoxEvents.TabIndex = 15;
            this.groupBoxEvents.TabStop = false;
            this.groupBoxEvents.Text = "Events";
            // 
            // listViewEvents
            // 
            this.listViewEvents.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeaderEventId,
            this.columnHeaderEventDescription});
            this.listViewEvents.FullRowSelect = true;
            this.listViewEvents.GridLines = true;
            this.listViewEvents.HeaderStyle = System.Windows.Forms.ColumnHeaderStyle.Nonclickable;
            this.listViewEvents.Location = new System.Drawing.Point(6, 21);
            this.listViewEvents.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.listViewEvents.Name = "listViewEvents";
            this.listViewEvents.Size = new System.Drawing.Size(326, 125);
            this.listViewEvents.TabIndex = 0;
            this.listViewEvents.UseCompatibleStateImageBehavior = false;
            this.listViewEvents.View = System.Windows.Forms.View.Details;
            // 
            // columnHeaderEventId
            // 
            this.columnHeaderEventId.Text = "ID";
            this.columnHeaderEventId.Width = 30;
            // 
            // columnHeaderEventDescription
            // 
            this.columnHeaderEventDescription.Text = "Description";
            this.columnHeaderEventDescription.Width = 292;
            // 
            // buttonToggleEvents
            // 
            this.buttonToggleEvents.ForeColor = System.Drawing.SystemColors.ControlText;
            this.buttonToggleEvents.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_vpn_key_black_24_off;
            this.buttonToggleEvents.Location = new System.Drawing.Point(772, 378);
            this.buttonToggleEvents.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToggleEvents.Name = "buttonToggleEvents";
            this.buttonToggleEvents.Size = new System.Drawing.Size(33, 32);
            this.buttonToggleEvents.TabIndex = 16;
            this.buttonToggleEvents.UseVisualStyleBackColor = true;
            this.buttonToggleEvents.Click += new System.EventHandler(this.buttonToggleEvents_Click);
            // 
            // timerAnimation
            // 
            this.timerAnimation.Interval = 166;
            this.timerAnimation.Tick += new System.EventHandler(this.timerAnimation_Tick);
            // 
            // trackBarZoom
            // 
            this.trackBarZoom.AutoSize = false;
            this.trackBarZoom.LargeChange = 1;
            this.trackBarZoom.Location = new System.Drawing.Point(779, 411);
            this.trackBarZoom.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.trackBarZoom.Maximum = 4;
            this.trackBarZoom.Minimum = 1;
            this.trackBarZoom.Name = "trackBarZoom";
            this.trackBarZoom.Orientation = System.Windows.Forms.Orientation.Vertical;
            this.trackBarZoom.Size = new System.Drawing.Size(26, 84);
            this.trackBarZoom.TabIndex = 17;
            this.trackBarZoom.TickStyle = System.Windows.Forms.TickStyle.None;
            this.trackBarZoom.Value = 4;
            this.trackBarZoom.Scroll += new System.EventHandler(this.trackBarZoom_Scroll);
            // 
            // buttonToolEventChanger
            // 
            this.buttonToolEventChanger.Image = global::AmbermoonMapEditor2D.Properties.Resources.baseline_grade_black_24dp;
            this.buttonToolEventChanger.Location = new System.Drawing.Point(772, 216);
            this.buttonToolEventChanger.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.buttonToolEventChanger.Name = "buttonToolEventChanger";
            this.buttonToolEventChanger.Size = new System.Drawing.Size(33, 32);
            this.buttonToolEventChanger.TabIndex = 18;
            this.buttonToolEventChanger.UseVisualStyleBackColor = true;
            this.buttonToolEventChanger.Click += new System.EventHandler(this.buttonToolEventChanger_Click);
            // 
            // MapEditorForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1153, 711);
            this.Controls.Add(this.buttonToolEventChanger);
            this.Controls.Add(this.buttonToggleEvents);
            this.Controls.Add(this.groupBoxEvents);
            this.Controls.Add(this.buttonToolRemoveFrontLayer);
            this.Controls.Add(this.labelDivider);
            this.Controls.Add(this.buttonToggleTileMarker);
            this.Controls.Add(this.buttonToggleGrid);
            this.Controls.Add(this.buttonToolFill);
            this.Controls.Add(this.buttonToolBlocks);
            this.Controls.Add(this.statusStrip);
            this.Controls.Add(this.buttonToolLayers);
            this.Controls.Add(this.buttonToolColorPicker);
            this.Controls.Add(this.buttonToolBrush);
            this.Controls.Add(this.groupBoxCharacters);
            this.Controls.Add(this.groupBoxProperties);
            this.Controls.Add(this.groupBoxTileset);
            this.Controls.Add(this.panelMap);
            this.Controls.Add(this.menuStrip);
            this.Controls.Add(this.trackBarZoom);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MainMenuStrip = this.menuStrip;
            this.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.MaximizeBox = false;
            this.Name = "MapEditorForm";
            this.Text = "Ambermoon Map Editor 2D";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.MapEditorForm_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.MapEditorForm_FormClosed);
            this.Load += new System.EventHandler(this.MapEditorForm_Load);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.MapEditorForm_KeyDown);
            this.menuStrip.ResumeLayout(false);
            this.menuStrip.PerformLayout();
            this.groupBoxTileset.ResumeLayout(false);
            this.groupBoxProperties.ResumeLayout(false);
            this.groupBoxProperties.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownHeight)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownWidth)).EndInit();
            this.groupBoxCharacters.ResumeLayout(false);
            this.groupBoxCharacters.PerformLayout();
            this.contextMenuStripLayers.ResumeLayout(false);
            this.statusStrip.ResumeLayout(false);
            this.statusStrip.PerformLayout();
            this.contextMenuStripBlockModes.ResumeLayout(false);
            this.groupBoxEvents.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.trackBarZoom)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

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
    }
}

