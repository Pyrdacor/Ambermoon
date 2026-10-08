# get-cshift.ps1 [-Folder <folder>]: downloads the latest release of the CShift compiler
# (https://github.com/Robert-Schneckenhaus/CShift) into a folder (default: .cshift next to this script) and returns
# the path of its cshiftc.exe. A release that is there already is not downloaded again.
#
# Windows x64 (cshift-<version>-windows-x64.zip, with its own clang and linker). Works with Windows PowerShell 5.1
# and PowerShell 7.
param(
    [string]$Folder = (Join-Path $PSScriptRoot ".cshift")
)
$ErrorActionPreference = "Stop"
$repo = "Robert-Schneckenhaus/CShift"

if (-not [Environment]::Is64BitOperatingSystem) {
    throw "there is no release of CShift for 32-bit Windows"
}
# Windows PowerShell 5.1 does not use TLS 1.2 by default
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# with a token (GITHUB_TOKEN or GH_TOKEN, e.g. in GitHub Actions) the API has a much higher rate limit: without one,
# it allows 60 requests per hour and IP, which the shared runners of GitHub Actions use up easily (error 403)
$headers = @{}
$token = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } else { $env:GH_TOKEN }
if ($token) {
    $headers["Authorization"] = "Bearer $token"
}
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers $headers -UseBasicParsing
$tag = $release.tag_name
if (-not $tag) {
    throw "the latest release of CShift cannot be found"
}
$version = $tag.TrimStart("v")
$name = "cshift-$version-windows-x64"
$compiler = Join-Path (Join-Path $Folder $name) "cshiftc.exe"

if (-not (Test-Path $compiler)) {
    New-Item -ItemType Directory -Force -Path $Folder | Out-Null
    $archive = Join-Path $Folder "$name.zip"
    Write-Host "downloading CShift $version ($name.zip)"
    $progress = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"   # the progress bar makes Invoke-WebRequest very slow in 5.1
    try {
        Invoke-WebRequest -Uri "https://github.com/$repo/releases/download/$tag/$name.zip" -OutFile $archive -UseBasicParsing
    }
    finally {
        $ProgressPreference = $progress
    }
    Expand-Archive -Path $archive -DestinationPath $Folder -Force
    Remove-Item $archive
}
& $compiler --version | Out-Host
return $compiler
