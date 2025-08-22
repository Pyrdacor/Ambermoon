namespace AmbermoonEditor
{
    partial class MainForm
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
            tabControlMain = new System.Windows.Forms.TabControl();
            TabPageOverview = new System.Windows.Forms.TabPage();
            TabPageItems = new System.Windows.Forms.TabPage();
            TabPageMapTexts = new System.Windows.Forms.TabPage();
            TabPagePartyMembers = new System.Windows.Forms.TabPage();
            TabPageMonsters = new System.Windows.Forms.TabPage();
            TabPageNPCs = new System.Windows.Forms.TabPage();
            tabControlMain.SuspendLayout();
            SuspendLayout();
            // 
            // tabControlMain
            // 
            tabControlMain.Controls.Add(TabPageOverview);
            tabControlMain.Controls.Add(TabPageItems);
            tabControlMain.Controls.Add(TabPageMapTexts);
            tabControlMain.Controls.Add(TabPagePartyMembers);
            tabControlMain.Controls.Add(TabPageMonsters);
            tabControlMain.Controls.Add(TabPageNPCs);
            tabControlMain.Dock = System.Windows.Forms.DockStyle.Fill;
            tabControlMain.Location = new System.Drawing.Point(0, 0);
            tabControlMain.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            tabControlMain.Name = "tabControlMain";
            tabControlMain.SelectedIndex = 2;
            tabControlMain.Size = new System.Drawing.Size(1105, 555);
            tabControlMain.TabIndex = 0;
            tabControlMain.SelectedIndexChanged += TabControlMain_SelectedIndexChanged;
            // 
            // TabPageOverview
            // 
            TabPageOverview.Font = new System.Drawing.Font("Consolas", 9F);
            TabPageOverview.Location = new System.Drawing.Point(4, 24);
            TabPageOverview.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageOverview.Name = "TabPageOverview";
            TabPageOverview.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageOverview.Size = new System.Drawing.Size(1097, 527);
            TabPageOverview.TabIndex = 0;
            TabPageOverview.Text = "Overview";
            TabPageOverview.UseVisualStyleBackColor = true;
            // 
            // TabPageItems
            // 
            TabPageItems.Location = new System.Drawing.Point(4, 24);
            TabPageItems.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageItems.Name = "TabPageItems";
            TabPageItems.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageItems.Size = new System.Drawing.Size(1097, 527);
            TabPageItems.TabIndex = 1;
            TabPageItems.Text = "Items";
            TabPageItems.UseVisualStyleBackColor = true;
            // 
            // TabPageMapTexts
            // 
            TabPageMapTexts.Location = new System.Drawing.Point(4, 24);
            TabPageMapTexts.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageMapTexts.Name = "TabPageMapTexts";
            TabPageMapTexts.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageMapTexts.Size = new System.Drawing.Size(1097, 527);
            TabPageMapTexts.TabIndex = 2;
            TabPageMapTexts.Text = "Map texts";
            TabPageMapTexts.UseVisualStyleBackColor = true;
            // 
            // TabPagePartyMembers
            // 
            TabPagePartyMembers.Location = new System.Drawing.Point(4, 24);
            TabPagePartyMembers.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPagePartyMembers.Name = "TabPagePartyMembers";
            TabPagePartyMembers.Size = new System.Drawing.Size(1097, 527);
            TabPagePartyMembers.TabIndex = 4;
            TabPagePartyMembers.Text = "Party";
            // 
            // TabPageMonsters
            // 
            TabPageMonsters.Location = new System.Drawing.Point(4, 24);
            TabPageMonsters.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageMonsters.Name = "TabPageMonsters";
            TabPageMonsters.Size = new System.Drawing.Size(1097, 527);
            TabPageMonsters.TabIndex = 3;
            TabPageMonsters.Text = "Monsters";
            // 
            // TabPageNPCs
            // 
            TabPageNPCs.Location = new System.Drawing.Point(4, 24);
            TabPageNPCs.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            TabPageNPCs.Name = "TabPageNPCs";
            TabPageNPCs.Size = new System.Drawing.Size(1097, 527);
            TabPageNPCs.TabIndex = 5;
            TabPageNPCs.Text = "NPCs";
            // 
            // MainForm
            // 
            AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            ClientSize = new System.Drawing.Size(1105, 555);
            Controls.Add(tabControlMain);
            Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            MinimumSize = new System.Drawing.Size(780, 440);
            Name = "MainForm";
            Text = "Ambermoon Editor";
            Load += MainForm_Load;
            tabControlMain.ResumeLayout(false);
            ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tabControlMain;
        private System.Windows.Forms.TabPage TabPageOverview;
        private System.Windows.Forms.TabPage TabPageItems;
        private System.Windows.Forms.TabPage TabPageMapTexts;
        private System.Windows.Forms.TabPage TabPagePartyMembers;
        private System.Windows.Forms.TabPage TabPageMonsters;
        private System.Windows.Forms.TabPage TabPageNPCs;
    }
}

