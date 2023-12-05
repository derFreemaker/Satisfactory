using System.Diagnostics.CodeAnalysis;
using System.Numerics;
using System.Text.RegularExpressions;

namespace DocUpdater
{
    internal static partial class ParseFunctions
    {
        [GeneratedRegex("^---? ?(.*)")]
        private static partial Regex GetCommentRegex();

        internal static bool IsComment(string line, [MaybeNullWhen(false)] out string comment)
        {
            comment = string.Empty;
            var regex = GetCommentRegex();

            var match = regex.Match(line);
            if (!match.Success)
                return false;

            comment = match.Groups[1].Value;
            return true;
        }


        [GeneratedRegex("^@param (\\S+) (.*?) ?(?:--? ?(.*))?$")]
        private static partial Regex GetParameterRegex();

        internal static bool IsParameter(string line, [MaybeNullWhen(false)] out FuncParameter data)
        {
            data = default;
            var regex = GetParameterRegex();

            var match = regex.Match(line);
            if (!match.Success)
                return false;

            var name = match.Groups[1].Value;
            var type = match.Groups[2].Value.Replace("|", "/");
            var description = match.Groups.Count > 3 ? match.Groups[3].Value : string.Empty;

            data = new() { Name = name, Type = type, Description = description };
            return true;
        }


        [GeneratedRegex("^@return (.+?)(?: ([^|,<> ]+?))? ?(?:--? ?(.*))?$")]
        private static partial Regex GetReturnRegex();

        internal static bool IsReturn(string line, [MaybeNullWhen(false)] out FuncParameter data)
        {
            data = default;
            var regex = GetReturnRegex();

            var match = regex.Match(line);
            if (!match.Success)
                return false;

            var matchGroupsCount = match.Groups.Count;

            var type = match.Groups[1].Value.Replace("|", "/");
            var name = matchGroupsCount > 2 ? match.Groups[2].Value : type;
            var description = matchGroupsCount > 3 ? match.Groups[3].Value : string.Empty;

            data = new() { Name = name, Type = type, Description = description };
            return true;
        }

        
        [GeneratedRegex("(?:local )?function ([^(]+)\\((.*)\\)")]
        private static partial Regex GetFunctionRegex();

        internal static bool IsFunction(string line, [MaybeNullWhen(false)] out (string Name, string[] argNames) data)
        {
            data = default;
            var regex = GetFunctionRegex();

            var match = regex.Match(line);
            if (!match.Success)
                return false;

            var name = match.Groups[1].Value;
            var argNamesStr = match.Groups.Count > 2 ? match.Groups[2].Value : string.Empty;

            var argNames = argNamesStr.Split(", ");
            data = (name, argNames);
            return true;
        }


        [GeneratedRegex("^@class (?<! : )(.+?)(?: : (.*))?$")]
        private static partial Regex GetClassRegex();

        internal static bool IsClass(string line, out string name)
        {
            name = string.Empty;
            var regex = GetClassRegex();

            var match = regex.Match(line);
            if (!match.Success)
                return false;

            name = match.Groups[1].Value;
            return true;
        }
    }
}
