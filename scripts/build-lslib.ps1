#Requires -Version 7
<#
    Сборка .pak через Divine.exe из LSLib — сторонний упаковщик, работает без установки игры.
    Второй способ, официальный Toolkit от Larian, будет жить в scripts/build-toolkit.ps1:
    имя скрипта = тип сборки, поэтому оба лежат рядом и не заменяют друг друга.

    Скрипт лежит в scripts/, поэтому корень репозитория — родитель $PSScriptRoot.
    Пакуются только Mods/ и Public/ — остальное в репозитории для людей, а не для игры.

    -VersionTag подставляет версию в meta.lsx сборки; сам репозиторий при этом не меняется,
    пока не указан -WriteMeta. Так сборка из тега воспроизводима, а версия в git не уезжает
    незаметно для человека.
#>
[CmdletBinding()]
param(
    [switch]$Install,
    [string]$VersionTag,
    [switch]$WriteMeta,
    [string]$Divine = $env:BG3_DIVINE,
    [string]$GameModsDir = "$env:LOCALAPPDATA\Larian Studios\Baldur's Gate 3\Mods"
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$modFolder = 'PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e'

# Version64 — упакованный int64: major<<55 | minor<<47 | revision<<31 | build.
function ConvertTo-Version64 {
    param([string]$Tag)

    $normalized = $Tag -replace '^v', ''
    if ($normalized -notmatch '^(?<base>\d+\.\d+\.\d+)(?:-(?<suffix>[0-9A-Za-z][0-9A-Za-z.-]*))?$') {
        throw "Тег '$Tag' не разобран. Ожидается vX.Y.Z или vX.Y.Z-суффикс."
    }

    $parts = $Matches.base.Split('.')
    $build = 0
    if ($Matches.suffix) {
        # У предрелизных тегов build — порядковый номер среди уже существующих vX.Y.Z-*.
        $siblings = @(git -C $repo tag --list "v$($Matches.base)-*" 2>$null | Where-Object { $_ -and $_ -ne $Tag })
        $build = $siblings.Count + 1
    }

    return ([int64]$parts[0] -shl 55) -bor ([int64]$parts[1] -shl 47) -bor ([int64]$parts[2] -shl 31) -bor [int64]$build
}

function ConvertFrom-Version64 {
    param([int64]$Value)
    return '{0}.{1}.{2}.{3}' -f (($Value -shr 55) -band 0xFF), (($Value -shr 47) -band 0xFF), (($Value -shr 31) -band 0xFFFF), ($Value -band 0x7FFFFFFF)
}

# Version64 лежит и в ModuleInfo, и в PublishVersion — трогаем только первый.
$moduleInfoVersionPattern = '(?s)(<node id="ModuleInfo">.*?<attribute id="Version64" type="int64" value=")(\d+)("/>)'

function Set-ModuleInfoVersion64 {
    param([string]$MetaPath, [int64]$Version64)

    $utf8 = [System.Text.UTF8Encoding]::new($false)
    $meta = [System.IO.File]::ReadAllText($MetaPath, $utf8)
    if ($meta -notmatch $moduleInfoVersionPattern) {
        throw "ModuleInfo/Version64 не найден в $MetaPath"
    }
    $meta = [regex]::Replace($meta, $moduleInfoVersionPattern, "`${1}$Version64`${3}", 1)
    [System.IO.File]::WriteAllText($MetaPath, $meta, $utf8)
}

if (-not $Divine) {
    $Divine = Join-Path (Split-Path $repo -Parent) 'bg3-dnd55e-russian-localization\.tools\lslib\Packed\Tools\Divine.exe'
}
if (-not (Test-Path $Divine)) {
    throw "Divine.exe не найден: $Divine. Укажите путь в `$env:BG3_DIVINE или параметром -Divine."
}
if ($WriteMeta -and -not $VersionTag) {
    throw '-WriteMeta работает только вместе с -VersionTag.'
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

$metaPath = Join-Path $repo "Mods\$modFolder\meta.lsx"
if ($VersionTag) {
    $version64 = ConvertTo-Version64 -Tag $VersionTag
    Set-ModuleInfoVersion64 -MetaPath (Join-Path $staging "Mods\$modFolder\meta.lsx") -Version64 $version64
    if ($WriteMeta) { Set-ModuleInfoVersion64 -MetaPath $metaPath -Version64 $version64 }
    Write-Host "Версия: $VersionTag → $(ConvertFrom-Version64 $version64) (Version64 $version64)"
} else {
    if ((Get-Content $metaPath -Raw) -match $moduleInfoVersionPattern) {
        Write-Host "Версия из meta.lsx: $(ConvertFrom-Version64 ([int64]$Matches[2]))"
    }
}

# Divine иногда выдаёт обрубок в полсотни байт вместо пакета — молча, с нулевым кодом возврата.
# Лечится повтором с другим корнем; результат принимаем только если он похож на настоящий .pak.
# Имя пакета — как у Toolkit (<Folder>.pak): под разными именами обе сборки
# лежали бы в папке модов одновременно, и игра грузила бы мод дважды.
$pak = Join-Path $repo "$modFolder.pak"
$tempPak = Join-Path ([System.IO.Path]::GetTempPath()) "$modFolder.pak"
$packed = $false

foreach ($source in $staging, $repo) {
    if (Test-Path $tempPak) { Remove-Item $tempPak -Force }

    & $Divine -g bg3 -a create-package -s $source -d $tempPak
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Divine вернул $LASTEXITCODE на корне $source"
        continue
    }
    if (-not (Test-Path $tempPak)) {
        Write-Host "Пакет не создан на корне $source"
        continue
    }

    $size = (Get-Item $tempPak).Length
    if ($size -lt 1024) {
        Write-Host "Пакет на корне $source подозрительно мал ($size Б) — повтор с другим корнем"
        continue
    }

    $packed = $true
    break
}

if (-not $packed) { throw 'Divine не собрал годный пакет ни с одного корня.' }

Move-Item $tempPak $pak -Force
Remove-Item $staging -Recurse -Force
Write-Host "Собрано (LSLib): $pak ($((Get-Item $pak).Length) Б)"

if ($Install) {
    if (Get-Process -Name 'bg3', 'bg3_dx11' -ErrorAction SilentlyContinue) {
        throw 'Игра запущена — закройте её перед установкой.'
    }
    $target = Join-Path $GameModsDir "$modFolder.pak"
    if (Test-Path $target) {
        $backup = "$target.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Move-Item $target $backup
        Write-Host "Прежний .pak сохранён: $backup"
    }
    Copy-Item $pak $target
    Write-Host "Установлено: $target"
    Write-Host 'Проверьте порядок загрузки: мод должен стоять ниже всех патчируемых.'
}
