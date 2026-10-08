namespace AmbermoonItemEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.ExecutableData;
using Ambermoon.Data.Legacy.Serialization;

/// The size of the data of an item.
const int ItemDataSize = 60;
/// The size of the data behind the items in the data hunk of an executable.
const int TrailingDataSize = 68;

/// An item in the editor and whether it has a name: an added item has none until it is edited (the null of the
/// original, which is shown like an empty name but is not the name of the item when it is edited).
struct EditorItem
{
    Item Item;
    bool HasName;
}

/// The items of an item file (Objects.amb/001) or of an executable (AM2_CPU, AM2_BLIT).
struct ItemList
{
    List<EditorItem> Items;
    bool IsExecutable;
    /// The hunks of the executable.
    List<Hunk> Hunks;
    /// The number of items in the data hunk of the executable.
    int LastItemAmount;

    /// The items of an item file: their number and the items.
    /// @error the file is no item file.
    static Error<ItemList> FromItemFile(uint8[] fileData)
    {
        var container = try FileReader.ReadFile("", DataReader.FromData(fileData));
        if (container.Files.TryGet(1) is not DataReader reader)
            return error("The given key '1' was not present in the dictionary.");
        reader.Position = 0;
        int itemCount = reader.ReadWord();
        var items = List<EditorItem>.Create(itemCount);
        for (var i = 0; i < itemCount; i += 1)
            items.Add(EditorItem { Item = try ItemReader.ReadItem((uint32)(i + 1), ref reader), HasName = true });
        return ItemList { Items = items, Hunks = List<Hunk>.Create() };
    }

    /// The items of an executable of the game (before version 1.14).
    /// @error it is no executable of the game.
    static Error<ItemList> FromExecutable(DataReader file)
    {
        file.Position = 0;
        var hunks = try AmigaExecutable.Read(file);

        // There is an issue with the deploder and AM2_BLIT where the second code hunk is treated as a data hunk
        // instead. Fix this here automatically.
        if (hunks.Count() < 6)
            return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
        if (hunks[5].Type == HunkType.Data)
            hunks[5] = try Hunk.Create(HunkType.Code, hunks[5].MemoryFlags, hunks[5].Data);

        var data = try ExecutableData.Create(hunks);
        var items = List<EditorItem>.Create();
        if (data.ItemManager is ItemManager itemManager)
        {
            foreach (var item in itemManager.Items.Values())
                items.Add(EditorItem { Item = item, HasName = true });
        }
        return ItemList { Items = items, IsExecutable = true, Hunks = hunks, LastItemAmount = items.Count() };
    }

    int ItemCount()
    {
        return Items.Count();
    }

    void AddItem()
    {
        Items.Add(EditorItem { Item = Item { Index = (uint32)Items.Count(), Name = "" }, HasName = false });
    }

    /// Removes the item with the number `index` (from 1 on; other numbers do nothing).
    void RemoveItem(int index)
    {
        // (the original ends with an exception for negative numbers)
        if (index <= 0 || index > Items.Count())
            return;

        index -= 1;
        Items.RemoveAt(index);

        for (var i = index; i < Items.Count(); i += 1)
        {
            var item = Items[i];
            item.Item.Index = (uint32)(i + 1);
            Items[i] = item;
        }
    }

    /// Replaces the item at `index` (from 0 on) and gives it its number.
    void SetItem(int index, EditorItem item)
    {
        item.Item.Index = (uint32)(index + 1);
        Items[index] = item;
    }

    /// The items in three columns.
    void PrintItems()
    {
        int numRows = (Items.Count() + 2) / 3;
        var rows = new string[numRows];
        for (var r = 0; r < numRows; r += 1)
            rows[r] = "";
        const ReadOnlySlice<int> trim = [0, 26, 52];

        for (var index = 0; index < Items.Count(); index += 1)
        {
            var item = Items[index].Item;
            int row = index % numRows;
            rows[row] = PadRightNet(rows[row], trim[index / numRows]) + $"{FormatIndex(item.Index)}: {item.Name}";
        }

        foreach (var row in rows)
            Console.WriteLine(row);
    }

    /// The items whose names contain the text (without regard to case).
    List<EditorItem> FindItems(string partialName)
    {
        var found = List<EditorItem>.Create();

        if (IsWhiteSpaceOnlyNet(partialName))
            return found;

        var lowerName = ToLowerNet(partialName);
        // (the original ends with an exception at an added item that has no name yet)
        foreach (var item in Items)
        {
            if (ToLowerNet(item.Item.Name).Contains(lowerName))
                found.Add(item);
        }
        return found;
    }

    /// The data of the item file or of the executable with the items.
    /// @error the executable has no data hunk for the items.
    Error<uint8[]> Save()
    {
        if (!IsExecutable)
        {
            var writer = new DataWriter();
            writer.WriteWord((uint16)ItemCount());
            foreach (var item in Items)
                ItemWriter.WriteItem(item.Item, ref writer);
            return writer.ToArray();
        }

        return _SaveExecutable();
    }

    // Writes the items into the data hunk of the executable, which moves the data behind them. There are 5 references
    // to that data in the code; they are relocated, so the relocations of the code hunk into the data hunk that point
    // behind the items are adjusted.
    Error<uint8[]> _SaveExecutable()
    {
        int itemDataHunkIndex = -1;
        for (var i = 0; i < Hunks.Count() - 1; i += 1)
        {
            if (Hunks[i].Type == HunkType.Data)
                itemDataHunkIndex = i;
        }
        if (itemDataHunkIndex < 0)
            return error("Object reference not set to an instance of an object.");
        var itemDataHunk = Hunks[itemDataHunkIndex];
        var oldData = itemDataHunk.Data;

        int newDataSize = oldData.Length - LastItemAmount * ItemDataSize + ItemCount() * ItemDataSize;
        while (newDataSize % 4 != 0)
            newDataSize += 1;
        var newData = new uint8[newDataSize];
        int itemOffset = oldData.Length - TrailingDataSize - LastItemAmount * ItemDataSize;
        if (itemOffset < 4)
            return error("[Data] Invalid item data.");
        Array.Copy(oldData, 0, newData, 0, itemOffset);

        // the item count (twice)
        newData[itemOffset - 4] = (uint8)((ItemCount() >> 8) & 0xff);
        newData[itemOffset - 3] = (uint8)(ItemCount() & 0xff);
        newData[itemOffset - 2] = newData[itemOffset - 4];
        newData[itemOffset - 1] = newData[itemOffset - 3];

        int codeHunkIndex = -1;
        int relocHunkIndex = -1;
        // the number of the data hunk among the code, data and BSS hunks (the hunk number of the relocations)
        int hunkNumber = 0;
        int itemDataHunkNumber = -1;
        for (var i = 0; i < Hunks.Count(); i += 1)
        {
            var type = Hunks[i].Type;
            if (type == HunkType.Code && codeHunkIndex < 0)
                codeHunkIndex = i;
            if (type == HunkType.RELOC32 && relocHunkIndex < 0)
                relocHunkIndex = i;
            if (type == HunkType.Code || type == HunkType.Data || type == HunkType.BSS)
            {
                if (i == itemDataHunkIndex)
                    itemDataHunkNumber = hunkNumber;
                hunkNumber += 1;
            }
        }
        if (codeHunkIndex < 0 || relocHunkIndex < 0)
            return error("Object reference not set to an instance of an object.");
        if (Hunks[relocHunkIndex].Entries.TryGet((uint32)itemDataHunkNumber) is not List<uint32> relocations)
            return error($"The given key '{itemDataHunkNumber}' was not present in the dictionary.");

        // (changed in place as in the original: the code hunk keeps the adjusted relocations)
        var codeHunkData = Hunks[codeHunkIndex].Data;
        int64 offsetChange = (int64)(ItemCount() - LastItemAmount) * ItemDataSize;
        foreach (var relocation in relocations)
        {
            int at = (int)relocation;
            if (at < 0 || at + 4 > codeHunkData.Length)
                return error("Index was outside the bounds of the array.");
            uint32 offset = _ReadDword(codeHunkData, at);
            if ((int64)offset > itemOffset)
                _WriteDword(codeHunkData, at, unchecked((uint32)((int64)offset + offsetChange)));
        }

        var writer = new DataWriter();
        foreach (var item in Items)
            ItemWriter.WriteItem(item.Item, ref writer);
        var itemData = writer.ToArray();
        Array.Copy(itemData, 0, newData, itemOffset, itemData.Length);
        Array.Copy(oldData, oldData.Length - TrailingDataSize, newData, itemOffset + itemData.Length, TrailingDataSize);

        Hunks[itemDataHunkIndex] = try Hunk.Create(HunkType.Data, itemDataHunk.MemoryFlags, newData);
        // the data hunk has the items now (the original keeps the old number, so that a second save breaks it)
        LastItemAmount = ItemCount();

        var executableWriter = new DataWriter();
        try AmigaExecutable.Write(ref executableWriter, Hunks);
        return executableWriter.ToArray();
    }

    static uint32 _ReadDword(uint8[] data, int index)
    {
        return ((uint32)data[index] << 24) | ((uint32)data[index + 1] << 16) | ((uint32)data[index + 2] << 8) |
               (uint32)data[index + 3];
    }

    static void _WriteDword(uint8[] data, int index, uint32 value)
    {
        data[index] = (uint8)(value >> 24);
        data[index + 1] = (uint8)((value >> 16) & 0xff);
        data[index + 2] = (uint8)((value >> 8) & 0xff);
        data[index + 3] = (uint8)(value & 0xff);
    }
}

/// The number of an item with at least 3 digits.
string FormatIndex(uint32 index)
{
    return index.ToString().PadLeft(3, '0');
}

/// `text.PadRight(width)` of .NET: spaces up to `width` UTF-16 characters.
string PadRightNet(string text, int width)
{
    int length = 0;
    int i = 0;
    while (i < text.Length)
    {
        uint8 b = text[i];
        int bytes = b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
        length += bytes == 4 ? 2 : 1;
        i += bytes;
    }
    if (length >= width)
        return text;
    return text + "".PadLeft(width - length, ' ');
}
