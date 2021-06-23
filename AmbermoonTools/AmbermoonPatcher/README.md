# Ambermoon Patcher

The Ambermoon patcher can patch the original game data files.

For patching there is a configuration file which defines the data patches.

The patcher will decompress and decode all data files first and will
then perform the fixes on the data. At the end the data is encoded and
compressed again.

Note that if you patch the same file or subfile, previous operations
may change the offsets by inserting or deleting data. Therefore if you not
only use replacing you should work from bottom to top of the file.

The order of patch execution is from top of the script to the bottom.


## Example

```
# Fix 123: Gryban waiting location
- Replace Party_char.amb[15]:0x1C 'ff ff'
```

Every fix starts with a description line which starts with a #.
This way multiple fixes can be added to one patch file and will also have some
kind of documentation with these description lines.

There are the following actions which all affect sequences of bytes.

- Replace \<destination\> \<replacement\>
- Insert \<destination\> \<insertion\>
- Delete \<destination\> \<size\>

Each fix can contain any number and combination of those actions.

You can also use the shortcuts r, i and d as well as rep, ins and del.
The case does not matter so you can also use R, I, D or replace, etc.


### Imports

Scripts can import other scripts so that parts can be loaded dynamically.
This might be especially useful for multi-language patches where the
language independent parts can be imported by each language dependent
patch script.

There are 2 kinds of imports. Fix lists and patch scripts.

Fix lists must only contain 1 enumeration of fixes. They can only be imported
inside a fix (after a fix description) and will then become part of a fix.
Fix lists are imported or run by the command `Run`.

Patch scripts are full script files. They can't be imported inside a fix
enumeration but can be imported between fix descriptions. They need to
start with a fix description. Importing complete patch scripts is done
by using the ampersand prefix.

```
# MyFix
- Replace ...
- Run OtherScript.afl // Run some additional fixes from a fix list

& MyOtherPatchFile.amp // Import fixes from other patch file
```

```
// This is MyOtherPatchFile.amp
# MyOtherFix
- Replace ...
```

```
// This is OtherScript.afl
- Delete ...
// We could also run another fix list here
```

Import loops will be detected and an error is generated. For example if
a patch file is included which itself imports the current patch script,
this will generate an error and won't execute anything.

Fix lists can also produce such loops and therefore are also checked.
Note that fix lists can only import other fix lists.

### Comments

You can use line-comments by using `//`. Everything after this in the same
line is treated as a comment and won't be considered by the interpreter.

If you want to comment multiple lines you can use `/*` and `*/`. Everything
between will be treated as a comment. But note that in contrast to languages
like C, a block comment must start at the beginning of a line and end at the
end of a line. You can't comment parts of a line with it!

Line comments can still comment parts of lines though.

#### Examples

```
// This is a line comment
/*
This is a block comment
*/
This /*is not*/ allowed
```


### Destinations

Destinations have 3 parts:
- Filename
- Subfile index
- Offset

The format is: `Filename[SubfileIndex]:Offset`. The offset can be given in decimal or hex.
If given in hex it must be prefixed by either $ or 0x so both of the following are valid:

- `Party_char.amb[15]:0x1C`
- `Party_char.amb[15]:$1C`

The sub file index can be given in decimal and hex as well:

- `Party_char.amb[15]:0x1C`
- `Party_char.amb[0xf]:0x1C`
- `Party_char.amb[$f]:0x1C`

Note that sub-file indices start at 1. So the index 0 is not valid!

If the sub file index is omitted it always defaults to 1. This may be
useful when working with non-container files which have no real sub files.
In this case specifying the sub file index explicitely with 1 is valid too.


### Replacements / Insertions

The data to insert can be specified in 2 different ways:
- As a constant expression
- As a source expression (basically a destination with a length)

#### Constant expressions

The easiest way to specify data is a constant expression. You can just specify the byte values
to insert. Those can be given as hex values or hex byte sequences:

- 0x1234
- $1234
- '12 34'

Note that hex values are always in the big-endian format so the more significant bytes
come first. So the bytes you write first in the patch file will also be written first.

The length in bytes of the constant expression is determined by the number of digits:

Expression | Length (bytes) | Data bytes (hex)
--- | --- | ---
0x1 | 1 | 01
0x12 | 1 | 12
0x123 | 2 | 01 23
0x1234 | 2 | 12 34
0x12345 | 3 | 01 23 45
... | ... | ...

So 0x1 is the same as 0x01. You can't specify half-bytes etc.
But you can specify more bytes like 0x0001 (2 bytes -> 00 01).
This will only work with hex numbers though. Decimal integers will only
occupy 1, 2 or 4 bytes dependent on the smallest number of bytes
they fit into. So in general try to avoid decimal integers at all.

If you want, you can specify the length explicitely: `0x1,4`.
This means that the value is 4 bytes in size and would produce
the following byte sequence: `00 00 00 01`. To avoid mistakes
the following will generate an error: `0x1234,1` as the length
is smaller than the given value.

When you used decimal integers you should always
explicitly add the length like `5,2` which is 00 05.

Byte sequences must be enclosed in single quotes and must always
be 2-digit hex values.

#### Source expressions

Source expressions are useful to copy data from somewhere else.
A source expression is basically a destination with a length.
So the format is: `Filename[SubFileIndex]:Offset,Length`.

The length can be given in decimal or hex (with prefix).

The sub file index can again be omitted and would default to 1.

##### Example

`Replace Place_data:0x20 Place_data:0x10,16`

This would replace 16 bytes at offset 0x20 with 16 bytes from offset 0x10.
And this is just copy data over to a new offset and overwrite the data there.
