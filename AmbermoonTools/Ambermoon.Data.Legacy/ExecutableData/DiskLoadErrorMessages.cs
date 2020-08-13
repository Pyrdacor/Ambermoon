namespace Ambermoon.Data.Legacy.ExecutableData
{
    /// <summary>
    /// Directly after the <see cref="WorldNames"/> there
    /// are the messages for disk loading errors.
    /// 
    /// It starts with 6 longwords from which every odd gives the
    /// absolute offset inside the second data hunk. Each of the names
    /// is null-terminated. Each even longword seems to be 0.
    /// </summary>
    public class DiskLoadErrorMessages : MessageList
    {
        /// <summary>
        /// The position of the data reader should be at
        /// the start of the disk load error messages just behind the
        /// world maps.
        /// 
        /// It will be behind the disk load error messages after this.
        /// </summary>
        public DiskLoadErrorMessages(IDataReader dataReader)
            : base(dataReader, 3)
        {

        }
    }
}
