using System.Diagnostics.Contracts;

namespace Lua_Bundler
{
    internal class FileLineInfo
    {
        public string FilePath { get; }
        public int Line { get; }
        public int Start { get; }
        public int End { get; }

        public FileLineInfo(string filePath, int line, int start, int end)
        {
            FilePath = filePath;
            Line = line;
            Start = start;
            End = end;
        }
        public FileLineInfo(string filePath, (int line, int start, int end) data)
            : this(filePath, data.line, data.start, data.end) { }

        [Pure]
        public static implicit operator FileLineInfo((string filePath, int line, int start, int end) data)
        {
            return new FileLineInfo(data.filePath, data.line, data.start, data.end);
        }

        [Pure]
        public static implicit operator FileLineInfo((string filePath, (int line, int start, int end)? data) data)
        {
            data.data ??= (0, 0, 0);
            return new FileLineInfo(data.filePath, data.data.Value.line, data.data.Value.start, data.data.Value.end);
        }
    }
}
