namespace Lua_Bundler;

internal struct CheckResult {
    public bool HasError { get; private set; } = false;

    public CheckResult() { }

    public void Error() {
        HasError = true;
    }
}