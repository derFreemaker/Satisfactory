using System.Diagnostics.Contracts;

namespace Lua_Bundler
{
    internal class FileLineInfo
    {
        public String FilePath { get; }
        public Int32 Line { get; }
        public Int32 Start { get; }
        public Int32 End { get; }

        public FileLineInfo(String filePath, Int32 line, Int32 start, Int32 end)
        {
            FilePath = filePath;
            Line = line;
            Start = start;
            End = end;
        }
        public FileLineInfo(String filePath, (Int32 line, Int32 start, Int32 end) data)
            : this(filePath, data.line, data.start, data.end) { }

        [Pure]
        public static implicit operator FileLineInfo((String filePath, Int32 line, Int32 start, Int32 end) data)
        {
            return new FileLineInfo(data.filePath, data.line, data.start, data.end);
        }

        [Pure]
        public static implicit operator FileLineInfo((String filePath, (Int32 line, Int32 start, Int32 end)? data) data)
        {
            data.data ??= (0, 0, 0);
            return new FileLineInfo(data.filePath, data.data.Value.line, data.data.Value.start, data.data.Value.end);
        }
    }
}
