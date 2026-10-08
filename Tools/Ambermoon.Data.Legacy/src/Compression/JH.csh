namespace Ambermoon.Data.Legacy.Compression;

using Ambermoon.Data.Legacy.Serialization;

/// The JH encryption (Jurie Horneman's): every word is xor'ed with a key that changes from word to word. Encrypting
/// and decrypting are the same operation.
struct JH
{
    /// En- or decrypts `data` in place from `offset` on (a last single byte is handled as the upper byte of a word).
    static void Crypt(uint8[] data, uint16 key, int offset)
    {
        int length = data.Length;
        int numWords = (length - offset + 1) >> 1;
        int d0 = key;
        int index = offset;
        for (var i = 0; i < numWords; i += 1)
        {
            if (index == length - 1)
            {
                data[index] = (uint8)(data[index] ^ (d0 >> 8));
            }
            else
            {
                data[index] = (uint8)(data[index] ^ (d0 >> 8));
                data[index + 1] = (uint8)(data[index + 1] ^ d0);
            }
            int d1 = d0;
            d0 = ((d0 << 4) + d1 + 87) & 0xffff;
            index += 2;
        }
    }

    /// En- or decrypts `data` in place.
    static void Crypt(uint8[] data, uint16 key)
    {
        Crypt(data, key, 0);
    }

    /// The rest of the reader (from its position to the end) en- or decrypted, as a new array. The reader is at its end
    /// afterwards.
    static uint8[] Crypt(ref DataReader reader, uint16 key)
    {
        var data = reader.ReadToEnd();
        Crypt(data, key, 0);
        return data;
    }
}
