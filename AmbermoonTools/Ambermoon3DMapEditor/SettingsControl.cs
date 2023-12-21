namespace Ambermoon3DMapEditor
{
    public partial class SettingsControl : UserControl
    {
        internal Settings Settings { get; } = new();
        private bool ignoreNoClipChange = false;
        private bool lastNoClipChecked = false;

        public SettingsControl()
        {
            InitializeComponent();

            // 3D View
            MapCheckbox(settings => settings.Settings3DView.ShowFloorTexture, checkBoxShowFloorTexture);
            MapCheckbox(settings => settings.Settings3DView.ShowCeilingTexture, checkBoxShowCeilingTexture);
            MapCheckbox(settings => settings.Settings3DView.ShowFloor, checkBoxShowFloor);
            MapCheckbox(settings => settings.Settings3DView.ShowCeiling, checkBoxShowCeiling);
            MapCheckbox(settings => settings.Settings3DView.ShowWalls, checkBoxShowWalls);
            MapCheckbox(settings => settings.Settings3DView.ShowObjects, checkBoxShowObjects);
            MapCheckbox(settings => settings.Settings3DView.ShowWallTextures, checkBoxShowWallTextures);
            MapCheckbox(settings => settings.Settings3DView.ShowObjectTextures, checkBoxShowObjectTextures);
            MapCheckbox(settings => settings.Settings3DView.SpeedBoost, checkBoxSpeedBoost);
            MapCheckbox(settings => settings.Settings3DView.NoWallClip, checkBoxNoWallClip);
            MapCheckbox(settings => settings.Settings3DView.NoObjectClip, checkBoxNoObjectClip);

            // 2D View
            MapRadioGroup(settings => settings.Settings2DView.ShowAsAutomap, radioButtonMiniatureMap, radioButtonDungeonMap);
            MapSlider(setting => Settings.Settings2DView.ZoomLevel, sliderZoomLevel);
            MapCheckbox(settings => settings.Settings2DView.ShowBlockingModes, checkBoxShowBlockingModes);
            MapComboBox(settings => settings.Settings2DView.ShowBlockingModesClass, comboBoxShowBlockingModesClass);
            MapCheckbox(settings => settings.Settings2DView.ShowPlayer, checkBoxShowPlayer);

            // Misc
        }

        public void EnableCeilingTexture(bool enable)
        {
            checkBoxShowCeilingTexture.Enabled = enable;
        }

        private void MapCheckbox(Func<Settings, Settings.Value<bool>> selector, CheckBox checkBox)
        {
            var setting = selector(Settings);
            checkBox.Checked = setting.CurrentValue;
            checkBox.CheckedChanged += (object? sender, EventArgs e) => setting.CurrentValue = (sender as CheckBox)!.Checked;
        }

        private void MapSlider(Func<Settings, Settings.Value<int>> selector, Slider slider)
        {
            var setting = selector(Settings);
            slider.Value = setting.CurrentValue;
            slider.ValueChanged += value => setting.CurrentValue = value;
        }

        private void MapComboBox(Func<Settings, Settings.Value<int>> selector, ComboBox comboBox)
        {
            var setting = selector(Settings);
            comboBox.SelectedIndex = setting.CurrentValue;
            comboBox.SelectedIndexChanged += (object? sender, EventArgs e) => setting.CurrentValue = (sender as ComboBox)!.SelectedIndex;
        }

        private void MapRadioGroup<T>(Func<Settings, Settings.Value<T>> selector, params RadioButton[] radioButtons) where T : struct, IEquatable<T>
        {
            if (radioButtons.Length == 0)
                throw new InvalidOperationException("No radio buttons given for radio group mapping.");

            var setting = selector(Settings);

            if (typeof(T) == typeof(bool))
            {
                if (radioButtons.Length != 2)
                    throw new InvalidOperationException("Mapping a radio group to a boolean requires 2 radio buttons.");

                radioButtons[0].CheckedChanged += (object? sender, EventArgs e) =>
                {
                    bool @checked = (sender as RadioButton)!.Checked;
                    if (@checked)
                        setting.CurrentValue = (T)Convert.ChangeType(false, typeof(T));
                };
                radioButtons[1].CheckedChanged += (object? sender, EventArgs e) =>
                {
                    bool @checked = (sender as RadioButton)!.Checked;
                    if (@checked)
                        setting.CurrentValue = (T)Convert.ChangeType(true, typeof(T));
                };
            }
            else if (typeof(T) == typeof(int))
            {
                for (int i = 0; i < radioButtons.Length; i++)
                {
                    int index = i;
                    radioButtons[i].CheckedChanged += (object? sender, EventArgs e) =>
                    {
                        bool @checked = (sender as RadioButton)!.Checked;
                        if (@checked)
                            setting.CurrentValue = (T)Convert.ChangeType(index, typeof(T));
                    };
                }
            }
            else
            {
                // TODO: support enums?
                throw new NotSupportedException("Only type bool and int are supported for radio groups.");
            }
        }

        private void checkBoxNoClip_CheckedChanged(object sender, EventArgs e)
        {
            if (ignoreNoClipChange)
                return;

            ignoreNoClipChange = true;

            checkBoxNoWallClip.Checked = checkBoxNoClip.Checked;
            checkBoxNoObjectClip.Checked = checkBoxNoClip.Checked;

            ignoreNoClipChange = false;
        }

        private void checkBoxNoClip_CheckStateChanged(object sender, EventArgs e)
        {
            if (checkBoxNoClip.CheckState == CheckState.Indeterminate)
            {
                if (!ignoreNoClipChange)
                    checkBoxNoClip.CheckState = lastNoClipChecked ? CheckState.Unchecked : CheckState.Checked;
            }
            else
            {
                lastNoClipChecked = checkBoxNoClip.CheckState == CheckState.Checked;
            }
        }

        private void checkBoxNoWallClip_CheckedChanged(object sender, EventArgs e)
        {
            if (ignoreNoClipChange)
                return;

            ignoreNoClipChange = true;

            if (checkBoxNoWallClip.Checked != checkBoxNoObjectClip.Checked)
                checkBoxNoClip.CheckState = CheckState.Indeterminate;
            else
                checkBoxNoClip.CheckState = checkBoxNoWallClip.Checked ? CheckState.Checked : CheckState.Unchecked;

            ignoreNoClipChange = false;
        }

        private void checkBoxNoObjectClip_CheckedChanged(object sender, EventArgs e)
        {
            if (ignoreNoClipChange)
                return;

            ignoreNoClipChange = true;

            if (checkBoxNoWallClip.Checked != checkBoxNoObjectClip.Checked)
                checkBoxNoClip.CheckState = CheckState.Indeterminate;
            else
                checkBoxNoClip.CheckState = checkBoxNoObjectClip.Checked ? CheckState.Checked : CheckState.Unchecked;

            ignoreNoClipChange = false;
        }

        private void SettingsControl_Load(object sender, EventArgs e)
        {

        }
    }
}
