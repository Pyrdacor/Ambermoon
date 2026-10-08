namespace Ambermoon.Data.Legacy;

using System;
using Ambermoon.Data.Legacy.Serialization;

// The files of the game (Files of Ambermoon.Data.Legacy): their names and the letters of the disks they are on.

/// The files that are not containers.
const ReadOnlySlice<string> RawFiles =
[
    "AM2_BLIT", "AM2_CPU", "Ambermoon_extro", "Ambermoon_intro",
    "Extro_music", "Intro_music", "Saves", "Party_data.sav",
    "Fantasy_intro", "Keymap"
];

/// The files of the game, in the order of the original list.
const ReadOnlySlice<string> AmigaFileNames =
[
    "AM2_BLIT", "AM2_CPU", "Keymap", "Initial/Automap.amb",
    "Initial/Chest_data.amb", "Initial/Merchant_data.amb", "Initial/Party_char.amb", "Initial/Party_data.sav",
    "Ambermoon_intro", "Fantasy_intro", "Intro_music", "1Icon_gfx.amb",
    "1Map_data.amb", "1Map_texts.amb", "2Icon_gfx.amb", "2Lab_data.amb",
    "2Map_data.amb", "2Map_texts.amb", "2Object3D.amb", "2Overlay3D.amb",
    "2Wall3D.amb", "3Icon_gfx.amb", "3Lab_data.amb", "3Map_data.amb",
    "3Map_texts.amb", "3Object3D.amb", "3Overlay3D.amb", "3Wall3D.amb",
    "Automap_graphics", "Combat_graphics", "Dictionary.english", "Dictionary.german",
    "Event_pix.amb", "Floors.amb", "Icon_data.amb", "Lab_background.amb",
    "Layouts.amb", "NPC_char.amb", "NPC_gfx.amb", "NPC_texts.amb",
    "Object_icons", "Object_texts.amb", "Palettes.amb", "Party_gfx.amb",
    "Party_texts.amb", "Pics_80x80.amb", "Place_data", "Portraits.amb",
    "Riddlemouth_graphics", "Stationary", "Travel_gfx.amb", "Combat_background.amb",
    "Monster_char_data.amb", "Monster_gfx.amb", "Monster_groups.amb", "Ambermoon_extro",
    "Extro_music", "Music.amb", "Automap.amb", "Chest_data.amb",
    "Merchant_data.amb", "Party_char.amb", "Party_data.sav", "Saves",
    "Save.00/Automap.amb", "Save.00/Chest_data.amb", "Save.00/Merchant_data.amb", "Save.00/Party_char.amb",
    "Save.00/Party_data.sav", "Save.01/Automap.amb", "Save.01/Chest_data.amb", "Save.01/Merchant_data.amb",
    "Save.01/Party_char.amb", "Save.01/Party_data.sav", "Save.02/Automap.amb", "Save.02/Chest_data.amb",
    "Save.02/Merchant_data.amb", "Save.02/Party_char.amb", "Save.02/Party_data.sav", "Save.03/Automap.amb",
    "Save.03/Chest_data.amb", "Save.03/Merchant_data.amb", "Save.03/Party_char.amb", "Save.03/Party_data.sav",
    "Save.04/Automap.amb", "Save.04/Chest_data.amb", "Save.04/Merchant_data.amb", "Save.04/Party_char.amb",
    "Save.04/Party_data.sav", "Save.05/Automap.amb", "Save.05/Chest_data.amb", "Save.05/Merchant_data.amb",
    "Save.05/Party_char.amb", "Save.05/Party_data.sav", "Save.06/Automap.amb", "Save.06/Chest_data.amb",
    "Save.06/Merchant_data.amb", "Save.06/Party_char.amb", "Save.06/Party_data.sav", "Save.07/Automap.amb",
    "Save.07/Chest_data.amb", "Save.07/Merchant_data.amb", "Save.07/Party_char.amb", "Save.07/Party_data.sav",
    "Save.08/Automap.amb", "Save.08/Chest_data.amb", "Save.08/Merchant_data.amb", "Save.08/Party_char.amb",
    "Save.08/Party_data.sav", "Save.09/Automap.amb", "Save.09/Chest_data.amb", "Save.09/Merchant_data.amb",
    "Save.09/Party_char.amb", "Save.09/Party_data.sav", "Save.10/Automap.amb", "Save.10/Chest_data.amb",
    "Save.10/Merchant_data.amb", "Save.10/Party_char.amb", "Save.10/Party_data.sav"
];

/// The disks of [AmigaFileNames].
const string AmigaFileDisks = "AAAAAAAABBBCCCDDDDDEEFFFFFFFGGGGGGGGGGGGGGGGGGGGGGGHHHHIIIJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ";

/// The files of the saved games.
const ReadOnlySlice<string> AmigaSaveFileNames =
[
    "Initial/Automap.amb", "Initial/Chest_data.amb", "Initial/Merchant_data.amb", "Initial/Party_char.amb",
    "Initial/Party_data.sav", "Automap.amb", "Chest_data.amb", "Merchant_data.amb",
    "Party_char.amb", "Party_data.sav", "Saves", "Save.00/Automap.amb",
    "Save.00/Chest_data.amb", "Save.00/Merchant_data.amb", "Save.00/Party_char.amb", "Save.00/Party_data.sav",
    "Save.01/Automap.amb", "Save.01/Chest_data.amb", "Save.01/Merchant_data.amb", "Save.01/Party_char.amb",
    "Save.01/Party_data.sav", "Save.02/Automap.amb", "Save.02/Chest_data.amb", "Save.02/Merchant_data.amb",
    "Save.02/Party_char.amb", "Save.02/Party_data.sav", "Save.03/Automap.amb", "Save.03/Chest_data.amb",
    "Save.03/Merchant_data.amb", "Save.03/Party_char.amb", "Save.03/Party_data.sav", "Save.04/Automap.amb",
    "Save.04/Chest_data.amb", "Save.04/Merchant_data.amb", "Save.04/Party_char.amb", "Save.04/Party_data.sav",
    "Save.05/Automap.amb", "Save.05/Chest_data.amb", "Save.05/Merchant_data.amb", "Save.05/Party_char.amb",
    "Save.05/Party_data.sav", "Save.06/Automap.amb", "Save.06/Chest_data.amb", "Save.06/Merchant_data.amb",
    "Save.06/Party_char.amb", "Save.06/Party_data.sav", "Save.07/Automap.amb", "Save.07/Chest_data.amb",
    "Save.07/Merchant_data.amb", "Save.07/Party_char.amb", "Save.07/Party_data.sav", "Save.08/Automap.amb",
    "Save.08/Chest_data.amb", "Save.08/Merchant_data.amb", "Save.08/Party_char.amb", "Save.08/Party_data.sav",
    "Save.09/Automap.amb", "Save.09/Chest_data.amb", "Save.09/Merchant_data.amb", "Save.09/Party_char.amb",
    "Save.09/Party_data.sav", "Save.10/Automap.amb", "Save.10/Chest_data.amb", "Save.10/Merchant_data.amb",
    "Save.10/Party_char.amb", "Save.10/Party_data.sav"
];

/// The disks of [AmigaSaveFileNames].
const string AmigaSaveFileDisks = "AAAAAJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ";

/// The files that version 1.14 added.
const ReadOnlySlice<string> New114FileNames =
[
    "Button_graphics", "Objects.amb", "Text.amb", "Dict.amb",
    "Monster_char.amb"
];

/// The disks of [New114FileNames].
const string New114FileDisks = "AAAGH";

/// The files that version 1.14 renamed: the old names.
const ReadOnlySlice<string> Renamed114FileNames = ["Monster_char_data.amb"];
/// The new names of [Renamed114FileNames].
const ReadOnlySlice<string> Renamed114FileNewNames = ["Monster_char.amb"];

/// The files that version 1.14 removed.
const ReadOnlySlice<string> Removed114FileNames =
[
    "Dictionary.english", "Dictionary.german", "Monster_char_data.amb", "AM2_BLIT"
];

/// The new name of a file that version 1.14 renamed.
Optional<string> Renamed114File(StringSlice name)
{
    for (var i = 0; i < Renamed114FileNames.Length; i += 1)
    {
        if (Renamed114FileNames[i] == name)
            return Renamed114FileNewNames[i];
    }
    return null;
}

/// Whether version 1.14 added the file.
bool IsNew114File(StringSlice name)
{
    foreach (var file in New114FileNames)
    {
        if (file == name)
            return true;
    }
    return false;
}

/// The files of the game (or of the saved games) and their disks for a version preference: without the files that
/// 1.14 removed for Post114, with the files that 1.14 added unless Pre114.
Dictionary<string, char> GameFiles(bool savesOnly, VersionPreference versionPreference)
{
    var files = Dictionary<string, char>.Create();
    var names = savesOnly ? AmigaSaveFileNames : AmigaFileNames;
    var disks = savesOnly ? AmigaSaveFileDisks : AmigaFileDisks;
    for (var i = 0; i < names.Length; i += 1)
        files[names[i]] = disks[i];

    if (versionPreference == VersionPreference.Post114)
    {
        foreach (var file in Removed114FileNames)
            files.Remove(file);
    }

    if (versionPreference != VersionPreference.Pre114)
    {
        for (var i = 0; i < New114FileNames.Length; i += 1)
            files[New114FileNames[i]] = New114FileDisks[i];
    }

    return files;
}
