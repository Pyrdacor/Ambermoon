$ErrorActionPreference = 'Stop';

if ($isWindows) {
  Write-Host Publish Windows executables
  $env:RID = 'win-x64'
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMonsterValueChanger/AmbermoonMonsterValueChanger.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore --nologo  
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore --nologo  
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonEventEditor/AmbermoonEventEditor.csproj" -p:PublishSingleFile=true -r win-x86 --no-restore --nologo
  $env:RID = 'win-x86'
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -r win-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMonsterValueChanger/AmbermoonMonsterValueChanger.csproj" -p:PublishSingleFile=true -r win-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -r win-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true  -r win-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonEventEditor/AmbermoonEventEditor.csproj" -p:PublishSingleFile=true  -r win-x64 --no-restore --nologo
  Write-Host Pack zip for Windows
  mkdir dist
  copy "AmbermoonTools\AmbermoonPack\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonPack.exe" "dist\"
  copy "AmbermoonTools\AmbermoonMonsterValueChanger\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonMonsterValueChanger.exe" "dist\"
  copy "AmbermoonTools\AmbermoonTextImport\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonTextImport.exe" "dist\"
  copy "AmbermoonTools\AmbermoonDiskExtract\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonDiskExtract.exe" "dist\"
  copy "AmbermoonTools\AmbermoonEventEditor\bin\Any CPU\Release\netcoreapp3.1\win-x64\publish\AmbermoonEventEditor.exe" "dist\"
  cd dist
  7z a ..\AmbermoonTools-Windows.zip *.*
  cd ..
  rm -r dist\*.*
  copy "AmbermoonTools\AmbermoonPack\bin\Any CPU\Release\netcoreapp3.1\win-x86\publish\AmbermoonPack.exe" "dist\"
  copy "AmbermoonTools\AmbermoonMonsterValueChanger\bin\Any CPU\Release\netcoreapp3.1\win-x86\publish\AmbermoonMonsterValueChanger.exe" "dist\"
  copy "AmbermoonTools\AmbermoonTextImport\bin\Any CPU\Release\netcoreapp3.1\win-x86\publish\AmbermoonTextImport.exe" "dist\"
  copy "AmbermoonTools\AmbermoonDiskExtract\bin\Any CPU\Release\netcoreapp3.1\win-x86\publish\AmbermoonDiskExtract.exe" "dist\"
  copy "AmbermoonTools\AmbermoonEventEditor\bin\Any CPU\Release\netcoreapp3.1\win-x86\publish\AmbermoonEventEditor.exe" "dist\"
  cd dist
  7z a ..\AmbermoonTools-Windows32Bit.zip *.*
  cd ..
  rm -r dist
} else {
  Write-Host Publish Linux executable
  $env:RID = 'linux-x64'
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMonsterValueChanger/AmbermoonMonsterValueChanger.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonEventEditor/AmbermoonEventEditor.csproj" -p:PublishSingleFile=true -r linux-x64 --no-restore --nologo
  Write-Host Pack tar.gz for Linux
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonPack/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonPack"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonMonsterValueChanger/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonMonsterValueChanger"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonTextImport/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonTextImport"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonDiskExtract/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonDiskExtract"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonEventEditor/bin/Any CPU/ReleaseLinux/netcoreapp3.1/linux-x64/publish/AmbermoonEventEditor"
  7z a AmbermoonTools-Linux.tar.gz AmbermoonTools-Linux.tar
  rm AmbermoonTools-Linux.tar
}
