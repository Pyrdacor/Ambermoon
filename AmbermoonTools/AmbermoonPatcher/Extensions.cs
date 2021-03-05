namespace AmbermoonPatcher
{
    public static class Extensions
    {
        public static int IndexOfAny(this string input, params string[] searchStrings)
        {
            int first = int.MaxValue;

            foreach (var searchString in searchStrings)
            {
                int index = input.IndexOf(searchString);

                if (index != -1 && index < first)
                    first = index;
            }

            return first == int.MaxValue ? -1 : first;
        }
    }
}
