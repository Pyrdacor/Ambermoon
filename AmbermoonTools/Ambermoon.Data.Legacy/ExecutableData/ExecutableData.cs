namespace Ambermoon.Data.Legacy.ExecutableData
{
    /// <summary>
    /// This contains all relevant data from the executable.
    /// 
    /// TODO: This is work in progress!
    /// </summary>
    public class ExecutableData
    {
        public FileList FileList { get; }
        public WorldNames WorldNames { get; }
        public DiskLoadErrorMessages DiskLoadErrorMessages { get; }
        public InsertDiskMessages InsertDiskMessages { get; }
        public Messages Messages { get; }

        /// <summary>
        /// Loads all data. Should be positioned on the start
        /// if the second data hunk.
        /// </summary>
        /// <param name="dataReader"></param>
        public ExecutableData(IDataReader dataReader)
        {
            // TODO ...
            FileList = new FileList(dataReader);
            WorldNames = new WorldNames(dataReader);
            DiskLoadErrorMessages = new DiskLoadErrorMessages(dataReader);
            InsertDiskMessages = new InsertDiskMessages(dataReader);
            Messages = new Messages(dataReader);
            // TODO: Here follow 2 0-dwords, then the automap legend names
            // TODO: Then the option names
            // TODO: Then the song names
            // TODO: Then the text "GAME OVER" or is it a song name as well?
            // TODO: Then the names of the 4 spell types / magic schools
            // TODO: Then the text "Function"?
            // TODO: Then the spell names (also special spells like call eagle etc, fill each up to 30 spell names, there are null bytes)
            // TODO: Then the language names
            // TODO: Then class names
            // TODO: Race names
            // TODO: Ability names
            // TODO: Attribute names
            // TODO: Ability short names
            // TODO: Attribute short names
            // TODO: Item type names
            // TODO: Status names
            // TODO: Text "APR"?
            // TODO: Texts for he, she, his, her replacement
            // TODO: Some UI header texts like "Abilities", "Languages", etc
            // TODO: Texts for male/female
            // TODO: Texts for compass (N, E, S, W, N-E, etc)
            // TODO: Some more UI texts (with placeholders)

            // TODO: Then there is a bunch of binary data (gfx maybe?)

            // TODO: Then finally the item data comes ...


            // TODO ...
        }
    }
}
