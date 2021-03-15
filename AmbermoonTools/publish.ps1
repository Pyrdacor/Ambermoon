$ErrorActionPreference = 'Stop';

if ($isWindows) {
  Write-Host Publish Windows executables
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -r win-x64 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/MonsterValueChanger/MonsterValueChanger.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/MonsterValueChanger/MonsterValueChanger.csproj" -p:PublishSingleFile=true -r win-x64 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -r win-x64 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -r win-x64 --no-restore
  Write-Host Pack zip for Windows
  mkdir dist
  copy "AmbermoonTools\AmbermoonPack\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonPack.exe" "dist\"
  copy "AmbermoonTools\MonsterValueChanger\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\MonsterValueChanger.exe" "dist\"
  copy "AmbermoonTools\AmbermoonTextImport\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonTextImport.exe" "dist\"
  copy "AmbermoonTools\AmbermoonDiskExtract\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonDiskExtract.exe" "dist\"
  cd dist
  7z a ..\AmbermoonTools-Windows.zip *.*
  cd ..
  rm -r dist
} else {
  Write-Host Publish Linux executable
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/MonsterValueChanger/MonsterValueChanger.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore
  Write-Host Pack tar.gz for Linux
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonPack/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonPack"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/MonsterValueChanger/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/MonsterValueChanger"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonTextImport/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonTextImport"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonDiskExtract/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonDiskExtract"
  7z a AmbermoonTools-Linux.tar.gz AmbermoonTools-Linux.tar
  rm AmbermoonTools-Linux.tar
}
