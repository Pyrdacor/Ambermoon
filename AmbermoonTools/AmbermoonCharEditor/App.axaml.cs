using AmbermoonCharEditor.ViewModels;
using AmbermoonCharEditor.Views;
using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using Avalonia.Media;
using Material.Styles.Themes;
using Material.Styles.Themes.Base;

namespace AmbermoonCharEditor
{
    public partial class App : Application
    {
        public override void Initialize()
        {
            AvaloniaXamlLoader.Load(this);
        }

        public override void OnFrameworkInitializationCompleted()
        {
            if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
            {
                var mainWindow = new MainWindow();
                desktop.MainWindow = mainWindow;
                desktop.MainWindow.DataContext = new MainWindowViewModel(mainWindow);
            }

            base.OnFrameworkInitializationCompleted();
        }
    }
}
