using System;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    internal class SelectFolderDialog
    {
        private readonly Configuration configuration;
        private readonly string configPathName;
        private readonly string title;

        public SelectFolderDialog(Configuration configuration, string configPathName, string title)
        {
            this.configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            this.configPathName = configPathName ?? throw new ArgumentNullException(nameof(configPathName));
            this.title = title ?? "Select folder";
        }

        public bool ShowNewFolderButton { get; set; } = false;
        public string Folder { get; private set; } = "";

        public DialogResult ShowDialog()
        {
            return Show(dialog => dialog.ShowDialog());
        }

        public DialogResult ShowDialog(IWin32Window owner)
        {
            return Show(dialog => dialog.ShowDialog(owner));
        }

        private DialogResult Show(Func<FolderBrowserDialog, DialogResult> showMethod)
        {
            string savePath = null;

            if (configuration.SavePaths == null)
                configuration.SavePaths = new();
            else if (!configuration.SavePaths.TryGetValue(configPathName, out savePath))
                savePath = null;

            var dialog = new FolderBrowserDialog();

            dialog.Description = title;
            dialog.ShowNewFolderButton = ShowNewFolderButton;
            dialog.UseDescriptionForTitle = true;
            dialog.InitialDirectory = savePath ?? "";
            dialog.SelectedPath = savePath ?? "";

            var result = showMethod(dialog);

            if (result == DialogResult.OK)
                configuration.SavePaths[configPathName] = Folder = dialog.SelectedPath;

            return result;
        }
    }
}
