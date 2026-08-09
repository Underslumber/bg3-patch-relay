#Requires -Version 7
<#
    Собирает мод в .pak через Divine.exe (LSLib).
    Пакуются только Mods/ и Public/ — остальное в репозитории для людей, а не для игры.
#>
[CmdletBinding()]
param(
    [switch]$Install,
    [string]$Divine = $env:BG3_DIVINE,
    [string]$GameModsDir = "$env:LOCALAPPDATA\Larian Studios\Baldur's Gate 3\Mods"
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$modFolder = 'PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e'

if (-not $Divine) {
    $Divine = Join-Path (Split-Path $repo -Parent) 'bg3-dnd55e-russian-localization\.tools\lslib\Packed\Tools\Divine.exe'
}
if (-not (Test-Path $Divine)) {
    throw "Divine.exe не найден: $Divine. Укажите путь в `$env:BG3_DIVINE или параметром -Divine."
}

$staging = Join-Path ([System.IO.Path]::GetTempPath()) "patchrelay-build"
if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory $staging | Out-Null

foreach ($branch in 'Mods', 'Public') {
    $src = Join-Path $repo "$branch\$modFolder"
    if (-not (Test-Path $src)) { throw "Нет ветки $branch\$modFolder" }
    $dstBranch = Join-Path $staging $branch
    New-Item -ItemType Directory $dstBranch | Out-Null
    Copy-Item $src $dstBranch -Recurse
}

$pak = Join-Path $repo 'PatchRelay.pak'
& $Divine -g bg3 -a create-package -s $staging -d $pak
if ($LASTEXITCODE -ne 0) { throw "Divine вернул $LASTEXITCODE" }
Remove-Item $staging -Recurse -Force
Write-Host "Собрано: $pak"

if ($Install) {
    if (Get-Process -Name 'bg3', 'bg3_dx11' -ErrorAction SilentlyContinue) {
        throw 'Игра запущена — закройте её перед установкой.'
    }
    $target = Join-Path $GameModsDir 'PatchRelay.pak'
    if (Test-Path $target) {
        $backup = "$target.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Move-Item $target $backup
        Write-Host "Прежний .pak сохранён: $backup"
    }
    Copy-Item $pak $target
    Write-Host "Установлено: $target"
    Write-Host 'Проверьте порядок загрузки: мод должен стоять ниже всех патчируемых.'
}
