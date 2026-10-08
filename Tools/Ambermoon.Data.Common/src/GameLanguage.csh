namespace Ambermoon.Data;

using System;
using Ambermoon;

/// Where game data was loaded from.
enum GameDataSource : int32
{
    Unknown,
    Memory,
    ADF,
    LegacyFiles,
    ADFAndLegacyFiles
}

/// The languages of the game.
enum GameLanguage : int32
{
    English,
    German,
    French,
    Polish,
    Czech
}

/// The language of a name like the original (`Enum.TryParse`, then names of the languages in English, in the
/// language itself and their codes, in any case); English for anything else.
GameLanguage ToGameLanguage(StringSlice languageString)
{
    // Enum.TryParse: a name (white space around it allowed) or a number
    var trimmed = TrimNet(languageString);
    for (var i = 0; i < Enum<GameLanguage>.Count; i += 1)
    {
        if (trimmed == Enum<GameLanguage>.Names[i])
            return Enum<GameLanguage>.Values[i];
    }
    if (ParseInt(trimmed) is int number)
        return (GameLanguage)number;

    var name = ToLowerNet(TrimNet(languageString));

    if (name == "german" || name == "deutsch" || name == "ger" || name == "de")
        return GameLanguage.German;
    if (name == "french" || name == "français" || name == "fre" || name == "fr")
        return GameLanguage.French;
    if (name == "polish" || name == "polski" || name == "pol" || name == "pl")
        return GameLanguage.Polish;
    if (name == "czech" || name == "český" || name == "česky" || name == "ces" || name == "cze" || name == "cs")
        return GameLanguage.Czech;

    return GameLanguage.English;
}
