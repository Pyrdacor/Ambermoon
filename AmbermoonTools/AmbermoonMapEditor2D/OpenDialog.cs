using System;
using System.IO;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    internal class OpenDialog
    {
        private readonly Configuration configuration;
        private readonly string configPathName;
        private readonly string title;
        private readonly string defaultExtension;

        public OpenDialog(Configuration configuration, string configPathName, string title, string defaultExtension = null)
        {
            this.configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            this.configPathName = configPathName ?? throw new ArgumentNullException(nameof(configPathName));
            this.title = title ?? "Open file";
            this.defaultExtension = defaultExtension;
        }

        public string Filter { get; set; } = "";
        public string FileName { get; set; } = "";
        public bool CheckFileExists { get; set; } = true;

        public DialogResult ShowDialog()
        {
            return Show(dialog => dialog.ShowDialog());
        }

        public DialogResult ShowDialog(IWin32Window owner)
        {
            return Show(dialog => dialog.ShowDialog(owner));
        }

        private DialogResult Show(Func<OpenFileDialog, DialogResult> showMethod)
        {
            string savePath = null;

            if (configuration.SavePaths == null)
                configuration.SavePaths = new();
            else if (!configuration.SavePaths.TryGetValue(configPathName, out savePath))
                savePath = null;

            string openDirectory = "";
            string openFileName = "";

            if (!string.IsNullOrWhiteSpace(FileName))
            {
                if (Path.IsPathRooted(FileName))
                    openDirectory = Path.GetDirectoryName(FileName);
                else if (savePath != null && Path.IsPathRooted(savePath))
                    openDirectory = Path.GetDirectoryName(savePath);

                openFileName = Path.GetFileName(FileName);
            }
            else if (savePath != null)
            {
                if (Path.IsPathRooted(savePath))
                    openDirectory = Path.GetDirectoryName(savePath);

                openFileName = Path.GetFileName(savePath);
            }

            var dialog = new OpenFileDialog();
            dialog.DefaultExt = defaultExtension;
            dialog.AddExtension = defaultExtension != null;
            dialog.CheckFileExists = CheckFileExists;
            dialog.CheckPathExists = CheckFileExists;
            dialog.Filter = Filter;
            dialog.FilterIndex = 0;
            dialog.RestoreDirectory = false;
            dialog.Title = title;
            dialog.InitialDirectory = openDirectory;
            dialog.FileName = openFileName;
            dialog.Multiselect = false;
            dialog.ShowReadOnly = false;

            var result = showMethod(dialog);

            if (result == DialogResult.OK)
                configuration.SavePaths[configPathName] = FileName = dialog.FileName;

            return result;
        }
    }
}
