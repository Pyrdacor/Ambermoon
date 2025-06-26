namespace AmbermoonReleaseCreator;

internal class Defer(Action disposeAction) : IDisposable
{
    public void Dispose() => disposeAction();
}
