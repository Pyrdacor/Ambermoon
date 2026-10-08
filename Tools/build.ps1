# build.ps1 [-Compiler <path\to\cshiftc.exe>]: builds all tools; the programs are put into bin\ (next to this script).
#
# The compiler: the one given, else $env:CSHIFTC, else the latest release of CShift (get-cshift.ps1 downloads it into
# .cshift\). If that fails (no network, ...), a compiler that is there already is used: the newest one in .cshift\,
# else cshiftc on the PATH.
param(
    [string]$Compiler = $env:CSHIFTC
)
$ErrorActionPreference = "Stop"

if (-not $Compiler) {
    try {
        $Compiler = & (Join-Path $PSScriptRoot "get-cshift.ps1") | Select-Object -Last 1
    }
    catch {
        Write-Warning "the latest CShift compiler could not be downloaded ($($_.Exception.Message)); looking for one that is there already"
        $local = Get-ChildItem -Path (Join-Path $PSScriptRoot ".cshift") -Directory -Filter "cshift-*" -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path $_.FullName "cshiftc.exe") } |
            Sort-Object { [version](($_.Name -replace '^cshift-', '') -replace '-windows-x64$', '') } |
            Select-Object -Last 1
        if ($local) {
            $Compiler = Join-Path $local.FullName "cshiftc.exe"
        }
        elseif (Get-Command cshiftc -ErrorAction SilentlyContinue) {
            $Compiler = (Get-Command cshiftc).Source
        }
    }
}
if (-not $Compiler -or -not (Test-Path $Compiler)) {
    Write-Error "no CShift compiler (pass -Compiler, set CSHIFTC or put cshiftc on the PATH)"
    exit 1
}
Write-Host "compiler: $Compiler ($(& $Compiler --version 2>&1 | Select-Object -First 1))"

$bin = Join-Path $PSScriptRoot "bin"
New-Item -ItemType Directory -Force -Path $bin | Out-Null
$built = 0
$failed = @()
foreach ($project in Get-ChildItem -Path $PSScriptRoot -Directory) {
    $json = Join-Path $project.FullName "cshift.json"
    if (-not (Test-Path $json)) { continue }
    if ((Get-Content $json -Raw) -match '"type"\s*:\s*"library"') { continue }
    $name = $project.Name
    $log = Join-Path $bin "$name.log"
    # the compiler writes its messages to stderr: collected in the log without stopping the script
    $ErrorActionPreference = "Continue"
    & $Compiler build $project.FullName 2>&1 | ForEach-Object { "$_" } | Out-File -FilePath $log -Encoding utf8
    $code = $LASTEXITCODE
    $ErrorActionPreference = "Stop"
    if ($code -eq 0) {
        Copy-Item (Join-Path $project.FullName "bin\$name.exe") $bin -Force
        Remove-Item $log
        $built++
        Write-Host "built  $name"
    }
    else {
        $failed += $name
        Write-Host "FAILED $name (see bin\$name.log)"
    }
}
Write-Host "$built tools built into $bin"
if ($failed.Count -gt 0) {
    Write-Host "failed: $($failed -join ', ')"
    exit 1
}
