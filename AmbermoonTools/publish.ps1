$ErrorActionPreference = 'Stop';

if ($isWindows) {
  Write-Host Publish Windows executables
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMonsterEditor/AmbermoonMonsterEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMonsterEditor/AmbermoonMonsterEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextManager/AmbermoonTextManager.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextManager/AmbermoonTextManager.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonEventEditor/AmbermoonEventEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonEventEditor/AmbermoonEventEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonLabdataEditor/AmbermoonLabdataEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonLabdataEditor/AmbermoonLabdataEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonItemEditor/AmbermoonItemEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonItemEditor/AmbermoonItemEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/Ambermoon3DMapViewer/Ambermoon3DMapViewer.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/Ambermoon3DMapViewer/Ambermoon3DMapViewer.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonImageConverter/AmbermoonImageConverter.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonImageConverter/AmbermoonImageConverter.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMapEditor2D/AmbermoonMapEditor2D.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x86 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMapEditor2D/AmbermoonMapEditor2D.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r win-x64 --no-restore --no-self-contained --nologo
  Write-Host Pack zip for Windows
  mkdir dist
  copy "AmbermoonTools\AmbermoonPack\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonPack.exe" "dist\"
  copy "AmbermoonTools\AmbermoonMonsterEditor\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonMonsterEditor.exe" "dist\"
  copy "AmbermoonTools\AmbermoonTextImport\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonTextImport.exe" "dist\"
  copy "AmbermoonTools\AmbermoonTextManager\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonTextManager.exe" "dist\"
  copy "AmbermoonTools\AmbermoonDiskExtract\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonDiskExtract.exe" "dist\"
  copy "AmbermoonTools\AmbermoonEventEditor\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonEventEditor.exe" "dist\"
  copy "AmbermoonTools\AmbermoonLabdataEditor\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonLabdataEditor.exe" "dist\"
  copy "AmbermoonTools\AmbermoonItemEditor\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonItemEditor.exe" "dist\"
  copy "AmbermoonTools\Ambermoon3DMapViewer\bin\Any CPU\Release\net7.0\win-x64\publish\Ambermoon3DMapViewer.exe" "dist\"
  copy "AmbermoonTools\AmbermoonImageConverter\bin\Any CPU\Release\net7.0\win-x64\publish\AmbermoonImageConverter.exe" "dist\"
  copy "AmbermoonTools\AmbermoonMapEditor2D\bin\Any CPU\Release\net7.0-windows\win-x64\publish\AmbermoonMapEditor2D.exe" "dist\"
  copy "AmbermoonTools\x64\api-ms-win-core-winrt-l1-1-0.dll" "dist\"
  cd dist
  7z a ..\AmbermoonTools-Windows.zip *.*
  cd ..
  rm -r dist\*.*
  copy "AmbermoonTools\AmbermoonPack\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonPack.exe" "dist\"
  copy "AmbermoonTools\AmbermoonMonsterEditor\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonMonsterEditor.exe" "dist\"
  copy "AmbermoonTools\AmbermoonTextImport\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonTextImport.exe" "dist\"
  copy "AmbermoonTools\AmbermoonTextManager\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonTextManager.exe" "dist\"
  copy "AmbermoonTools\AmbermoonDiskExtract\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonDiskExtract.exe" "dist\"
  copy "AmbermoonTools\AmbermoonEventEditor\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonEventEditor.exe" "dist\"
  copy "AmbermoonTools\AmbermoonLabdataEditor\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonLabdataEditor.exe" "dist\"
  copy "AmbermoonTools\AmbermoonItemEditor\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonItemEditor.exe" "dist\"
  copy "AmbermoonTools\Ambermoon3DMapViewer\bin\Any CPU\Release\net7.0\win-x86\publish\Ambermoon3DMapViewer.exe" "dist\"
  copy "AmbermoonTools\AmbermoonImageConverter\bin\Any CPU\Release\net7.0\win-x86\publish\AmbermoonImageConverter.exe" "dist\"
  copy "AmbermoonTools\AmbermoonMapEditor2D\bin\Any CPU\Release\net7.0-windows\win-x86\publish\AmbermoonMapEditor2D.exe" "dist\"
  copy "AmbermoonTools\x86\api-ms-win-core-winrt-l1-1-0.dll" "dist\"
  cd dist
  7z a ..\AmbermoonTools-Windows32Bit.zip *.*
  cd ..
  rm -r dist
} else {
  Write-Host Publish Linux executable
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonPack/AmbermoonPack.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonMonsterEditor/AmbermoonMonsterEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextImport/AmbermoonTextImport.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonTextManager/AmbermoonTextManager.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonDiskExtract/AmbermoonDiskExtract.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonEventEditor/AmbermoonEventEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonLabdataEditor/AmbermoonLabdataEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonItemEditor/AmbermoonItemEditor.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/Ambermoon3DMapViewer/Ambermoon3DMapViewer.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  dotnet publish -c $env:CONFIGURATION "./AmbermoonTools/AmbermoonImageConverter/AmbermoonImageConverter.csproj" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -r linux-x64 --no-restore --no-self-contained --nologo
  Write-Host Pack tar.gz for Linux
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonPack/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonPack"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonMonsterEditor/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonMonsterEditor"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonTextImport/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonTextImport"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonTextManager/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonTextManager"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonDiskExtract/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonDiskExtract"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonEventEditor/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonEventEditor"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonLabdataEditor/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonLabdataEditor"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonItemEditor/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonItemEditor"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/Ambermoon3DMapViewer/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/Ambermoon3DMapViewer"
  7z a AmbermoonTools-Linux.tar "./AmbermoonTools/AmbermoonImageConverter/bin/Any CPU/ReleaseLinux/net7.0/linux-x64/publish/AmbermoonImageConverter"
  7z a AmbermoonTools-Linux.tar.gz AmbermoonTools-Linux.tar
  rm AmbermoonTools-Linux.tar
}
