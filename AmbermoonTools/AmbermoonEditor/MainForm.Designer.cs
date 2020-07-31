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
            this.tabControlMain = new System.Windows.Forms.TabControl();
            this.TabPageOverview = new System.Windows.Forms.TabPage();
            this.TabPageItems = new System.Windows.Forms.TabPage();
            this.TabPageMapTexts = new System.Windows.Forms.TabPage();
            this.TabPageCharacters = new System.Windows.Forms.TabPage();
            this.TabPageMonsters = new System.Windows.Forms.TabPage();
            this.TabPageNPCs = new System.Windows.Forms.TabPage();
            this.button1 = new System.Windows.Forms.Button();
            this.tabControlMain.SuspendLayout();
            this.TabPageOverview.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabControlMain
            // 
            this.tabControlMain.Controls.Add(this.TabPageOverview);
            this.tabControlMain.Controls.Add(this.TabPageItems);
            this.tabControlMain.Controls.Add(this.TabPageMapTexts);
            this.tabControlMain.Controls.Add(this.TabPageCharacters);
            this.tabControlMain.Controls.Add(this.TabPageMonsters);
            this.tabControlMain.Controls.Add(this.TabPageNPCs);
            this.tabControlMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControlMain.Location = new System.Drawing.Point(0, 0);
            this.tabControlMain.Name = "tabControlMain";
            this.tabControlMain.SelectedIndex = 2;
            this.tabControlMain.Size = new System.Drawing.Size(1263, 740);
            this.tabControlMain.TabIndex = 0;
            // 
            // TabPageOverview
            // 
            this.TabPageOverview.Controls.Add(this.button1);
            this.TabPageOverview.Location = new System.Drawing.Point(4, 29);
            this.TabPageOverview.Name = "TabPageOverview";
            this.TabPageOverview.Padding = new System.Windows.Forms.Padding(3);
            this.TabPageOverview.Size = new System.Drawing.Size(1255, 707);
            this.TabPageOverview.TabIndex = 0;
            this.TabPageOverview.Text = "Overview";
            this.TabPageOverview.UseVisualStyleBackColor = true;
            // 
            // TabPageItems
            // 
            this.TabPageItems.Location = new System.Drawing.Point(4, 29);
            this.TabPageItems.Name = "TabPageItems";
            this.TabPageItems.Padding = new System.Windows.Forms.Padding(3);
            this.TabPageItems.Size = new System.Drawing.Size(1255, 707);
            this.TabPageItems.TabIndex = 1;
            this.TabPageItems.Text = "Items";
            this.TabPageItems.UseVisualStyleBackColor = true;
            // 
            // TabPageMapTexts
            // 
            this.TabPageMapTexts.Location = new System.Drawing.Point(4, 29);
            this.TabPageMapTexts.Name = "TabPageMapTexts";
            this.TabPageMapTexts.Padding = new System.Windows.Forms.Padding(3);
            this.TabPageMapTexts.Size = new System.Drawing.Size(1255, 707);
            this.TabPageMapTexts.TabIndex = 2;
            this.TabPageMapTexts.Text = "Map texts";
            this.TabPageMapTexts.UseVisualStyleBackColor = true;
            // 
            // TabPageCharacters
            // 
            this.TabPageCharacters.Location = new System.Drawing.Point(4, 29);
            this.TabPageCharacters.Name = "TabPageCharacters";
            this.TabPageCharacters.Size = new System.Drawing.Size(1255, 707);
            this.TabPageCharacters.TabIndex = 4;
            this.TabPageCharacters.Text = "Characters";
            // 
            // TabPageMonsters
            // 
            this.TabPageMonsters.Location = new System.Drawing.Point(4, 29);
            this.TabPageMonsters.Name = "TabPageMonsters";
            this.TabPageMonsters.Size = new System.Drawing.Size(1255, 707);
            this.TabPageMonsters.TabIndex = 3;
            this.TabPageMonsters.Text = "Monsters";
            // 
            // TabPageNPCs
            // 
            this.TabPageNPCs.Location = new System.Drawing.Point(4, 29);
            this.TabPageNPCs.Name = "TabPageNPCs";
            this.TabPageNPCs.Size = new System.Drawing.Size(1255, 707);
            this.TabPageNPCs.TabIndex = 5;
            this.TabPageNPCs.Text = "NPCs";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(502, 139);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(94, 29);
            this.button1.TabIndex = 0;
            this.button1.Text = "button1";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1263, 740);
            this.Controls.Add(this.tabControlMain);
            this.Name = "MainForm";
            this.Text = "Ambermoon Editor";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.tabControlMain.ResumeLayout(false);
            this.TabPageOverview.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tabControlMain;
        private System.Windows.Forms.TabPage TabPageOverview;
        private System.Windows.Forms.TabPage TabPageItems;
        private System.Windows.Forms.TabPage TabPageMapTexts;
        private System.Windows.Forms.TabPage TabPageCharacters;
        private System.Windows.Forms.TabPage TabPageMonsters;
        private System.Windows.Forms.TabPage TabPageNPCs;
        private System.Windows.Forms.Button button1;
    }
}

