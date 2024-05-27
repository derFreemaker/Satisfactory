using System.Text.RegularExpressions;

namespace Lua_Bundler
{
    internal partial class Utils
    {
        internal static Int32 Generated;

        private const String CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        
        internal static String GenerateId()
        {
            var stringChars = new Char[8];
            var random = new Random(Generated);

            for (Int32 i = 0; i < stringChars.Length; i++)
                stringChars[i] = CHARS[random.Next(CHARS.Length)];

            Generated++;
            return new String(stringChars);
        }

        [GeneratedRegex(@"(?:([\n]+?))")]
        private static partial Regex GetRegexNewLine();

        internal static (Int32 Line, Int32 Column, Int32 EndColumn) GetLine(String content, Int32 index, Int32 length)
        {
            var newLineRegex = GetRegexNewLine();
            var newLineMatches = newLineRegex.Matches(content);
            Int32 line = 1;
            Int32 lastLineEnd = 0;

            foreach (var newLineMatch in newLineMatches.Cast<Match>())
            {
                var newLineGroup = newLineMatch.Groups[1];

                if (newLineGroup.Index > index) {
                    break;
                }

                line++;
                lastLineEnd = newLineGroup.Index + newLineGroup.Length;
            }

            var column = index - lastLineEnd + 1;
            return (line, column, column + length);
        }
    }
}
