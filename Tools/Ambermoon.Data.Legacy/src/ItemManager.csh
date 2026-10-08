namespace Ambermoon.Data.Legacy;

using System;
using Ambermoon.Data;

/// The items of the game by their index (from 1 on) and the texts of the text scrolls.
struct ItemManager
{
    Dictionary<uint32, Item> Items;
    Dictionary<uint32, List<string>> ItemTexts;

    static ItemManager Create(Dictionary<uint32, Item> items)
    {
        return ItemManager { Items = items, ItemTexts = Dictionary<uint32, List<string>>.Create() };
    }

    void AddTexts(uint32 index, List<string> texts)
    {
        ItemTexts[index] = texts;
    }

    /// The item of an index.
    /// @panics there is no such item (the original ends with a KeyNotFoundException).
    Item GetItem(uint32 index)
    {
        return Items[index];
    }

    /// A text of a text scroll; null if there is none.
    Optional<string> GetText(uint32 index, uint32 subIndex)
    {
        if (ItemTexts.TryGet(index) is List<string> texts && subIndex < (uint32)texts.Count())
            return texts[(int)subIndex];
        return null;
    }
}
