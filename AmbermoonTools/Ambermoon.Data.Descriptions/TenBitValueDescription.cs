using System;
using System.IO;

namespace Ambermoon.Data.Descriptions
{
    public record TenBitValueDescription : ValueDescription
    {
        private readonly int bitOffset;
        private readonly int byteOffset;

        public TenBitValueDescription(string name, int byteOffset, int bitOffset, bool required, bool hidden, ushort defaultValue, ushort minValue = 0, ushort maxValue = 1023, bool showAsHex = false)
        {
            if (minValue > 1023)
                throw new ArgumentOutOfRangeException(nameof(minValue));
            if (maxValue > 1023)
                throw new ArgumentOutOfRangeException(nameof(maxValue));
            if (defaultValue > 1023)
                throw new ArgumentOutOfRangeException(nameof(defaultValue));

            Type = ValueType.TenBits;
            Name = name;
            Required = required;
            Hidden = !required && hidden;
            MinValue = minValue;
            MaxValue = maxValue;
            DefaultValue = defaultValue;
            ShowAsHex = showAsHex;

            this.byteOffset = byteOffset;
            this.bitOffset = bitOffset;
		}

        public override string GetPossibleValues()
        {
            if(ShowAsHex)
                return $"0x{MinValue:x4} ~ 0x{MaxValue:x4}";
            else
                return $"{MinValue} ~ {MaxValue}";
        }

        public int Read(byte[] data)
        {
            int dataIndex = byteOffset;

            return Read(data, ref dataIndex);
        }

        public void Write(byte[] data, ushort value)
        {
            int dataIndex = byteOffset;

            Write(data, ref dataIndex, value);
        }

        public override int Read(byte[] data, ref int dataIndex)
        {
            if (dataIndex != byteOffset)
                throw new InvalidDataException($"Expected read offset {byteOffset} but was {dataIndex}");

            int readBitOffset = bitOffset;

            int bitsInByte = 8 - readBitOffset;
            int mask = (1 << bitsInByte) - 1;

            int result = data[dataIndex++] & mask;
            readBitOffset = 10 - bitsInByte;

            result <<= readBitOffset;
            result |= (data[dataIndex] >> (8 - readBitOffset));

            if (readBitOffset == 8)
                dataIndex++;

            return result;
        }

        public override void Write(byte[] data, ref int dataIndex, ushort value)
        {
            if (dataIndex != byteOffset)
                throw new InvalidDataException($"Expected write offset {byteOffset} but was {dataIndex}");

            value &= 0x3ff;

            int writeBitOffset = bitOffset;
            int bitsInByte = 8 - writeBitOffset;
            writeBitOffset = 10 - bitsInByte;

            byte mask = (byte)((1 << bitsInByte) - 1);

            data[dataIndex] &= (byte)~mask;
            data[dataIndex++] |= (byte)(value >> writeBitOffset);

            mask = (byte)(0xff >> writeBitOffset);

            data[dataIndex] &= mask;
            data[dataIndex] |= (byte)(value << (8 - writeBitOffset));

            if (writeBitOffset == 8)
            {
                writeBitOffset = 0;
                dataIndex++;
            }
        }

        public override bool Check(ushort input)
        {
            return input < 1024;
        }
    }
}
