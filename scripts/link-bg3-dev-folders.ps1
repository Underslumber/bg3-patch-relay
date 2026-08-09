#Requires -Version 7
<#
    Подключает репозиторий к игре симлинками, чтобы Larian Toolkit видел мод как свой проект.
    Каталоги игры при этом остаются пустыми обёртками — правится всё в репозитории.

    Требуются права на создание симлинков: режим разработчика Windows либо запуск от админа.
    Снять подключение — unlink-bg3-dev-folders.ps1.
#>
[CmdletBinding()]
param(
    [string]$GamePath,
    [string]$Workspace
)

$ErrorActionPreference = 'Stop'
$modFolder = 'PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e'

function Resolve-Workspace {
    param([string]$Explicit)
    $path = if ($Explicit) { $Explicit } else { Join-Path $PSScriptRoot '..' }
    return [System.IO.Path]::GetFullPath($path)
}

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

    # Игра может лежать в любой библиотеке Steam, не только в корневой.
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

function Get-LinkTarget {
    param([System.IO.FileSystemInfo]$Item)

    $target = $Item.LinkTarget
    if (-not $target) { return $null }
    if ([System.IO.Path]::IsPathRooted($target)) { return [System.IO.Path]::GetFullPath($target) }
    return [System.IO.Path]::GetFullPath((Join-Path $Item.Parent.FullName $target))
}

function Set-DirectoryLink {
    param([string]$LinkPath, [string]$TargetPath, [string]$Label)

    if (Test-Path -LiteralPath $LinkPath) {
        $existing = Get-Item -LiteralPath $LinkPath -Force
        if (($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) {
            throw "$Label : по пути лежит настоящий каталог, а не ссылка — разберитесь вручную: $LinkPath"
        }
        if ((Get-LinkTarget -Item $existing) -ieq $TargetPath) {
            Write-Host "$Label : уже подключён"
            return
        }
        # Directory.Delete снимает саму точку перехода и не трогает содержимое цели;
        # Remove-Item на каталожном симлинке в Windows PowerShell 5.1 падает NullReferenceException.
        [System.IO.Directory]::Delete($LinkPath)
    }

    $parent = Split-Path $LinkPath -Parent
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory $parent -Force | Out-Null }

    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
    } catch [System.UnauthorizedAccessException] {
        throw "$Label : нет прав на создание симлинка. Включите режим разработчика Windows или запустите от администратора."
    }
    Write-Host "$Label : подключён"
}

$workspace = Resolve-Workspace -Explicit $Workspace
$gamePath = Find-GamePath -Explicit $GamePath
$dataPath = Join-Path $gamePath 'Data'

Write-Host "Репозиторий: $workspace"
Write-Host "Игра: $gamePath"
Write-Host ''

# Editor и Projects появляются, только когда мод заведён в тулките; до этого их просто нет.
$links = @(
    @{ Label = 'Mods'; Source = "Mods\$modFolder"; Link = "Data\Mods\$modFolder"; Required = $true }
    @{ Label = 'Public'; Source = "Public\$modFolder"; Link = "Data\Public\$modFolder"; Required = $true }
    @{ Label = 'Editor'; Source = "Editor\Mods\$modFolder"; Link = "Data\Editor\Mods\$modFolder"; Required = $false }
    @{ Label = 'Projects'; Source = "Projects\$modFolder"; Link = "Data\Projects\$modFolder"; Required = $false }
)

foreach ($link in $links) {
    $source = Join-Path $workspace $link.Source
    if (-not (Test-Path -LiteralPath $source)) {
        if ($link.Required) { throw "$($link.Label) : нет каталога $($link.Source) в репозитории" }
        Write-Host "$($link.Label) : пропущен, в репозитории нет $($link.Source)"
        continue
    }
    Set-DirectoryLink -LinkPath (Join-Path $gamePath $link.Link) -TargetPath $source -Label $link.Label
}

Write-Host ''
Write-Host 'Готово. Тулкит увидит проект после перезапуска.'
