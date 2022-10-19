using System;
using System.IO;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    internal class SaveDialog
    {
        private readonly Configuration configuration;
        private readonly string configPathName;
        private readonly string title;
        private readonly string defaultExtension;

        public SaveDialog(Configuration configuration, string configPathName, string title, string defaultExtension = null)
        {
            this.configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            this.configPathName = configPathName ?? throw new ArgumentNullException(nameof(configPathName));
            this.title = title ?? "Save file";
            this.defaultExtension = defaultExtension;
        }

        public string Filter { get; set; } = "";
        public string FileName { get; set; } = "";

        public DialogResult ShowDialog()
        {
            return Show(dialog => dialog.ShowDialog());
        }

        public DialogResult ShowDialog(IWin32Window owner)
        {
            return Show(dialog => dialog.ShowDialog(owner));
        }

        private DialogResult Show(Func<SaveFileDialog, DialogResult> showMethod)
        {
            string savePath = null;

            if (configuration.SavePaths == null)
                configuration.SavePaths = new();
            else if (!configuration.SavePaths.TryGetValue(configPathName, out savePath))
                savePath = null;

            string saveDirectory = "";
            string saveFileName = "";

            if (!string.IsNullOrWhiteSpace(FileName))
            {
                if (Path.IsPathRooted(FileName))
                    saveDirectory = Path.GetDirectoryName(FileName);
                else if (savePath != null && Path.IsPathRooted(savePath))
                    saveDirectory = Path.GetDirectoryName(savePath);

                saveFileName = Path.GetFileName(FileName);
            }
            else if (savePath != null)
            {
                if (Path.IsPathRooted(savePath))
                    saveDirectory = Path.GetDirectoryName(savePath);

                saveFileName = Path.GetFileName(savePath);
            }

            var dialog = new SaveFileDialog();
            dialog.DefaultExt = defaultExtension;
            dialog.AddExtension = defaultExtension != null;
            dialog.CheckFileExists = false;
            dialog.CheckPathExists = false;
            dialog.CreatePrompt = false;
            dialog.Filter = Filter;
            dialog.FilterIndex = 0;
            dialog.OverwritePrompt = true;
            dialog.RestoreDirectory = false;
            dialog.Title = title;
            dialog.InitialDirectory = saveDirectory;
            dialog.FileName = saveFileName;

            var result = showMethod(dialog);

            if (result == DialogResult.OK)
                configuration.SavePaths[configPathName] = FileName = dialog.FileName;

            return result;
        }
    }
}
