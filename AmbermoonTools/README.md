# Ambermoon Tools

Pyrdacor's suite of tools for editing Ambermoon data files.

## Use it

The most recent version can be found here:

Version | Release date | Windows 64bit | Linux 64bit | Windows 32bit
--- | --- | --- | --- | ---
1.17 | 14-06-2023 | [Download](https://github.com/Pyrdacor/Ambermoon/releases/download/v1.17/AmbermoonTools-Windows.zip) | [Download](https://github.com/Pyrdacor/Ambermoon/releases/download/v1.17/AmbermoonTools-Linux.tar.gz) | [Download](https://github.com/Pyrdacor/Ambermoon/releases/download/v1.17/AmbermoonTools-Windows32Bit.zip)

Most tools have a help. Try to run with command line argument `--help` for further information.

If you have problems, try to install the .NET6 runtime (see link below).


## Build yourself

Ensure to install .NET7. You can download it from here: https://dotnet.microsoft.com/en-us/download/dotnet/7.0

If you just want to use the tools, the runtime is enough. But if you want to build and/or modify the code, you'll need the SDK.

On Linux you may also use `snap install dotnet-sdk`.

- After the SDK is installed, navigate to the directory of the desired tool (e.g., `cd AmbermoonTextImport`).
- Run a command such as `dotnet publish -c release -r ubuntu.20.04-x64 --self-contained -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true` (replacing `ubuntu.20.04` with whatever is appropriate for your system). You can find general runtime IDs here: https://docs.microsoft.com/en-us/dotnet/core/rid-catalog.
- The compiled executable will be located inside a folder something like `./bin/release/net6.0/ubuntu.20.04-x64/publish/`
