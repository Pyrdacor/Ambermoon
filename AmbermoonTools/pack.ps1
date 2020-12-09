$ErrorActionPreference = 'Stop';

if ($isWindows) {
  Write-Host Pack zip for Windows
  7z a AmbermoonTools-Windows.zip "AmbermoonTools\AmbermoonPack\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonPack.exe"
  7z a AmbermoonTools-Windows.zip "AmbermoonTools\MonsterValueChanger\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\MonsterValueChanger.exe"
  7z a AmbermoonTools-Windows.zip "AmbermoonTools\AmbermoonTextImport\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonTextImport.exe"
} else {
  Write-Host Pack tar.gz for Linux
  7z a Ambermoon.net-Linux.tar "./AmbermoonTools/AmbermoonPack/bin/Any CPU/Release/netcoreapp3.1/linux-x64/publish/AmbermoonPack"
  7z a Ambermoon.net-Linux.tar "./AmbermoonTools/MonsterValueChanger/bin/Any CPU/Release/netcoreapp3.1/linux-x64/publish/MonsterValueChanger"
  7z a Ambermoon.net-Linux.tar "./AmbermoonTools/AmbermoonTextImport/bin/Any CPU/Release/netcoreapp3.1/linux-x64/publish/AmbermoonTextImport"
  7z a Ambermoon.net-Linux.tar.gz Ambermoon.net-Linux.tar
  rm Ambermoon.net-Linux.tar
}
