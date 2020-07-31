using System;
using System.Collections.Generic;
using System.IO;

namespace Ambermoon.Data.Legacy
{
    public static class FileWriter
    {
        public static void WriteJH(Stream stream, byte[] fileData)
        {
            // TODO
            throw new NotImplementedException();
        }

        public static void WriteLob(Stream stream, byte[] fileData)
        {
            WriteLob(stream, fileData, (uint)FileType.LOB);
        }

        public static void WriteVol1(Stream stream, byte[] fileData)
        {
            WriteLob(stream, fileData, (uint)FileType.VOL1);
        }

        static void WriteLob(Stream stream, byte[] fileData, uint header)
        {
            var compressedData = Compression.Lob.CompressData(fileData);

            var writer = new DataWriter();

            writer.Write(header);
            writer.Write((uint)fileData.Length);
            writer.Write((uint)compressedData.Length);
            writer.Write(compressedData);

            writer.CopyTo(stream);
        }

        public static void WriteContainer(Stream stream, List<byte[]> filesData, FileType fileType)
        {
            // TODO
            throw new NotImplementedException();
        }
    }
}
