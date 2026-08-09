#Requires -Version 7
<#
    Снимает симлинки, поставленные link-bg3-dev-folders.ps1.
    Удаляются только сами ссылки; содержимое репозитория не трогается.
#>
[CmdletBinding()]
param(
    [string]$GamePath
)

$ErrorActionPreference = 'Stop'
$modFolder = 'PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e'

function Find-GamePath {
    param([string]$Explicit)

    if ($Explicit) { return [System.IO.Path]::GetFullPath($Explicit) }

    $steamRoot = $null
    foreach ($key in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
        if (-not (Test-Path -LiteralPath $key)) { continue }
        $props = Get-ItemProperty -LiteralPath $key
        foreach ($name in 'SteamPath', 'InstallPath') {
            if ($props.$name -and (Test-Path -LiteralPath $props.$name)) {
                $steamRoot = [System.IO.Path]::GetFullPath($props.$name)
                break
            }
        }
        if ($steamRoot) { break }
    }
    if (-not $steamRoot) { throw 'Steam не найден в реестре. Укажите путь к игре параметром -GamePath.' }

    $libraries = [System.Collections.Generic.List[string]]::new()
    $libraries.Add($steamRoot)
    $vdf = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'
    if (Test-Path -LiteralPath $vdf) {
        foreach ($line in Get-Content -LiteralPath $vdf) {
            if ($line -match '^\s*"path"\s*"(?<path>.+)"\s*$') {
                $candidate = [System.IO.Path]::GetFullPath($Matches.path.Replace('\\', '\'))
                if (-not $libraries.Contains($candidate)) { $libraries.Add($candidate) }
            }
        }
    }

    foreach ($library in $libraries) {
        $candidate = Join-Path $library 'steamapps\common\Baldurs Gate 3'
        if (Test-Path -LiteralPath (Join-Path $candidate 'Data\Mods')) { return $candidate }
    }

    throw "Baldur's Gate 3 не найдена в библиотеках Steam. Укажите путь параметром -GamePath."
}

$gamePath = Find-GamePath -Explicit $GamePath
Write-Host "Игра: $gamePath"

$links = @(
    @{ Label = 'Mods'; Link = "Data\Mods\$modFolder" }
    @{ Label = 'Public'; Link = "Data\Public\$modFolder" }
    @{ Label = 'Editor'; Link = "Data\Editor\Mods\$modFolder" }
    @{ Label = 'Projects'; Link = "Data\Projects\$modFolder" }
)

foreach ($link in $links) {
    $path = Join-Path $gamePath $link.Link
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host "$($link.Label) : ссылки нет"
        continue
    }

    $item = Get-Item -LiteralPath $path -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) {
        Write-Host "$($link.Label) : это настоящий каталог, а не ссылка — оставлен как есть: $path"
        continue
    }

    # Снимаем точку перехода, содержимое репозитория при этом остаётся на месте.
    [System.IO.Directory]::Delete($path)
    Write-Host "$($link.Label) : отключён"
}
