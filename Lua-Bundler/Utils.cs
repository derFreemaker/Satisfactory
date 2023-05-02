namespace Lua_Bundler
{
    internal static class Utils
    {
        private static int Generated = 0;

        public static string GenerateStringId()
        {
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
            var stringChars = new char[8];
            var random = new Random(Generated);

            for (int i = 0; i < stringChars.Length; i++)
                stringChars[i] = chars[random.Next(chars.Length)];

            Generated++;
            return new String(stringChars);
        }
    }
}
