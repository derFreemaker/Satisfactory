using System.Text.RegularExpressions;

namespace Lua_Bundler
{
    internal partial class Utils
    {
        internal static int Generated = 0;

        private const string CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        
        internal static string GenerateId()
        {
            char[] stringChars = new char[8];
            var random = new Random(Generated);

            for (int i = 0; i < stringChars.Length; i++)
                stringChars[i] = CHARS[random.Next(CHARS.Length)];

            Generated++;
            return new string(stringChars);
        }

        [GeneratedRegex(@"(?:([\n]+?))")]
        private static partial Regex GetRegexNewLine();

        internal static (int Line, int Colomn, int EndColomn) GetLine(string content, Group group)
        {
            var newLineRegex = GetRegexNewLine();
            var newLineMatches = newLineRegex.Matches(content);
            int line = 1;
            int lastLineEnd = 0;

            foreach (var newLineMatch in newLineMatches.Cast<Match>())
            {
                var newLineGroup = newLineMatch.Groups[1];

                if (newLineGroup.Index > group.Index)
                    break;

                line++;
                lastLineEnd = newLineGroup.Index + newLineGroup.Length;
            }

            var index = group.Index - lastLineEnd + 1;

            return (line, index, index + group.Length);
        }
    }
}
