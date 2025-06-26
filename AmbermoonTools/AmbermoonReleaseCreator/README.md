# Release Creator

This project allows creating new releases for Ambermoon.

For non-german languages it will also patch all texts in the game, intro and extro but requires a german game version as a basis.

This tool is meant to run locally from the solution folder. If you want to run it from within Visual Studio, open up the
project settings, open up the debug launch profile, set the working directory to the solution path (e.g. C:\MyProjects\Ambermoon)
and provide the command line arguments for language and version (see below). Set the project as the start project and run it.

You can also create a `launch.Settings.json` manually inside the folder `Properties` inside the project folder like so:

*(This is only an example.)*
```json
{
  "profiles": {
    "AmbermoonReleaseCreator": {
      "commandName": "Project",
      "commandLineArgs": "Czech 1.19",
      "workingDirectory": "C:\MyProjects\Ambermoon"
    }
  }
}
```


## Requirements

You will need a recent version of .NET (dotnet CLI) installed to run the tool.

For the german release just make sure you update all files inside the folder `Disks\Bugfixing\German`.
Then run `AmbermoonReleaseCreator.exe German X.X` where X.X is the version number of the release.
The current files from `Disks\Bugfixing\German` will be used and as a base the most recent previous
version in `Disks\German`. For example if you release german version 1.20, the tool will check for
`Disks\German\ambermoon_german_1.19_extracted.zip`, extract it and copies over all relevant files from
`Disks\Bugfixing\German`. Then it creates the new release archives in `Disks\German`:
- ambermoon_german_1.20_extracted.zip
- ambermoon_german_1.20_extracted.tar.gz
- ambermoon_german_1.20_extracted.lha
- ambermoon_german_1.20_adf.zip
- ambermoon_german_1.20_adf.tar.gz
- ambermoon_german_1.20_adf.lha

For all other languages you need to have german data with the same version as a base. For example
if you want to release English 1.20 you will need `Disks\German\ambermoon_german_1.20_extracted.zip`.
In the following I will use `<language>` as a placeholder for the language you want to release.
This can be English, French, Czech, etc.

Moreover you need to prepare some things:
- The `Disks\Bugfixing\<language>` folder must contain the following directories:
  - AllTexts
	- 1Map_texts.amb
	  - 022
		- 000.txt
		- ...
	  - ...
	- 2Map_texts.amb
	  - ...
    - ...
  - IntroTexts
	- 000.txt
	- ...
  - ExtroTexts
	- 000
	  - 000
		- 000.txt
		- ...
	  - 001
		- ...
	  - ...
	- 001
	  - ...
	- ...
- The `Translations` folder needs the following two files:
  - Ambermoon_extro_translation_base
  - Ambermoon_intro_translation_base
- The `Translations\<language>` folder needs the following files:
  - encoding.txt
  - font.json
  - translators.txt
  - click-text.txt
  - LargeGlyphs.png
  - SmallGlyphs.png

Then you can run `AmbermoonReleaseCreator.exe <language> X.X` where X.X is the version number of the release.

`AllTexts` contains all the ingame texts. You can view the english version for a reference. You don't need to
update the files `AllTexts\Text.amb\VersionString\000.txt` and `AllTexts\Text.amb\DateAndLanguageString\000.txt`.
Those are updated to the given version, language and current date automatically by the tool.

`IntroTexts` contains the texts for the intro. You can view the english version for a reference.
Basically all translatable texts of the intro (not city or developer names).

`ExtroTexts` contains the texts for the extro. You can view the english version for a reference.
Extro texts are bit trickier than intro texts. They are organized in a tree structure based on
groups inside the extro sequence. But basically all texts just have to be translated normally.

**Note that all text files must be encoded in UTF-8!** The tool reads them as UTF-8. English texts can also
use ASCII encoding (which is a subset of UTF-8), but for all other languages you must use UTF-8 encoding.

The `encoding.txt` file contains the encoding used for the language. It is used to store the text
characters inside the intro and extro. The encoding must be a 1-byte encoding, so no UTF-8 or unicode!
You can also specify a codepage like 852 etc. So the content of the file is just a single line with
an encoding name or codepage number. For example `852` or `ISO-8859-2` for Czech.

The `font.json` file contains the font used for the language. It is used to render the texts in the intro and extro.
Here you can use the Czech font in `Translations\Czech\font.json` as a reference. It usually looks like this:

```json
{
  "numChars": 224,
  "numGlyphs": 108,
  "smallGlyphHeight": 11,
  "largeGlyphHeight": 22,
  "smallUsedGlyphHeight": 10,
  "largeUsedGlyphHeight": 21,
  "smallLineHeight": 12,
  "largeLineHeight": 23,
  "smallSpaceAdvance": 6,
  "largeSpaceAdvance": 10,
  "glyphMapping": [
    255,
    66,
    255,
    255,
    255,
    255,
	...
```

- `numChars` is the total amount of supported characters. Note that you can't have gaps. So if in your encoding the last character is the 256th character, then you need to allow 256 characters. You can later omit some of the characters by assigning no glyph. The first 32 characters (control characters) are always excluded, so the maximum value should be 256-32 which is 224.
- `numGlyphs` is the total amount of printable glyphs. Not every character must have a glyph. Some characters are reserved by the game like `$` (hard space), `~` (placeholder), `<` (dictionary ref start), `>` (dictionary ref end), `^` (newline). And of course the space character should have no glyph. So `numGlyphs` is always smaller than `numChars`.
- `smallGlyphHeight` and `largeGlyphHeight` are the heights of the small and large glyphs in pixels. This must match the size inside the `SmallGlyphs.png` and `LargeGlyphs.png` images. Note that small glyphs always have a width of 16 pixels and large glyphs a width of 32 pixels. This can't be change, but the height is changeable.
- `smallUsedGlyphHeight` and `largeUsedGlyphHeight` are the used heights of the small and large glyphs in pixels. The intro and extro will only read this amount of pixel rows for each glyph. This must be smaller or equal to the `smallGlyphHeight` and `largeGlyphHeight`.
- `smallLineHeight` and `largeLineHeight` are the line heights of the small and large glyphs in pixels. This is used to calculate the line spacing in the intro and extro. Usually this 1 pixel bigger than the `smallGlyphHeight` and `largeGlyphHeight`.
- `smallSpaceAdvance` and `largeSpaceAdvance` are the advance widths of the space character in pixels. This is used to calculate the spacing between words in the intro and extro. The small space is usually 6 pixels and the large space 10 pixels.
- `glyphMapping` is an array of `numChars` entries. Each entry is the index of the glyph in the `SmallGlyphs.png` or `LargeGlyphs.png` image. If the character has no glyph, then the value is 255. The first 32 characters (control characters) are always excluded, so the first entry is for the space character which is always 255 as it has no glyph.

The `translators.txt` file contains the names of the translators. It is used to display the translators in the extro. The file should contain one name per line. This file is optional.

In the extro after some texts a message like `<CLICK>` appears so that the user has to click to see the next image and extro sequence. The `click-text.txt` file contains the text to use instead of `<CLICK>`. This file is optional.

The `LargeGlyphs.png` and `SmallGlyphs.png` files contain the glyphs for the language. The images must be PNG images with a transparent background. The visible parts should be full white. The large glyphs should have a size of `32xLH` pixels and the small glyphs `16xSH` pixels, where `LH` is the `largeGlyphHeight` and `SH` is the `smallGlyphHeight`. There must be 16 glyphs per row for both, the small and large glyph image! Therefore `LargeGlyphs.png` is always 512 pixels wide and `SmallGlyphs.png` 256 pixels.

The `Translations\Ambermoon_extro_translation_base` and `Translations\Ambermoon_intro_translation_base` files are used to patch the intro and extro texts. They are special intro and extro versions with some preparations for patching font and texts.


If everything was prepared well and the tool ran successfully, the following files should be created in `Disks\<language>`:
- ambermoon_<language>_1.20_extracted.zip
- ambermoon_<language>_1.20_extracted.tar.gz
- ambermoon_<language>_1.20_extracted.lha
- ambermoon_<language>_1.20_adf.zip
- ambermoon_<language>_1.20_adf.tar.gz
- ambermoon_<language>_1.20_adf.lha