namespace Ambermoon3DMapEditor
{
    internal class Settings
    {
        internal class Value<T> where T : struct, IEquatable<T>
        {
            private T currentValue;

            public T CurrentValue
            {
                get => currentValue;
                set
                {
                    if (!currentValue.Equals(value))
                    {
                        currentValue = value;
                        Changed?.Invoke(currentValue);
                    }
                }
            }

            public event Action<T>? Changed;

            private Value(T initialValue)
            {
                currentValue = initialValue;
            }

            public static implicit operator Value<T>(T value)
            {
                return new Value<T>(value);
            }
        }

        internal class _Settings3DView
        {
            public Value<bool> SpeedBoost { get; } = false;
            public Value<bool> ShowFloorTexture { get; } = true;
            public Value<bool> ShowCeilingTexture { get; } = true;
            public Value<bool> ShowFloor { get; } = true;
            public Value<bool> ShowCeiling { get; } = true;
            public Value<bool> ShowWalls { get; } = true;
            public Value<bool> ShowObjects { get; } = true;
            public Value<bool> ShowWallColors { get; } = false;
            public Value<bool> ShowObjectColors { get; } = false;
            public Value<bool> NoClip { get; } = false;
        }

        internal class _Settings2DView
        {
            public Value<bool> ShowAsAutomap { get; } = false;
        }

        internal class _SettingsMisc
        {

        }

        public _Settings3DView Settings3DView { get; } = new();

        public _Settings2DView Settings2DView { get; } = new();

        public _SettingsMisc SettingsMisc { get; } = new();
    }
}
