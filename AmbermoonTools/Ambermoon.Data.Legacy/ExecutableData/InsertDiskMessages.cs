namespace Ambermoon.Data.Legacy.ExecutableData
{
    /// <summary>
    /// Directly after the <see cref="DiskLoadErrorMessages"/> there
    /// are the messages for disk inserting.
    /// 
    /// It starts with 4 longwords from which every odd gives the
    /// absolute offset inside the second data hunk. Each of the names
    /// is null-terminated. Each even longword seems to be 0.
    /// 
    /// Another 2 longwords (1 text entry) follows with the insert
    /// message for the save disk. This is handled here as well.
    /// </summary>
    public class InsertDiskMessages : MessageList
    {
        /// <summary>
        /// The position of the data reader should be at
        /// the start of the disk insert messages just behind the
        /// dist load errors.
        /// 
        /// It will be behind all the disk insert messages after this.
        /// </summary>
        public InsertDiskMessages(IDataReader dataReader)
            : base(dataReader, 2)
        {
            // Here follows insert message for save disk.
            // Add it to the existing messages.
            Entries.Add(new MessageList(dataReader, 1).Entries[0]);
        }
    }
}
