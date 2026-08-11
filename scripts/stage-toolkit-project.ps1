[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Workspace,

    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3'
)

$ErrorActionPreference = 'Stop'
$modFolder = 'PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e'
$workspacePath = [System.IO.Path]::GetFullPath($Workspace)
$gamePathResolved = [System.IO.Path]::GetFullPath($GamePath)

if (-not (Test-Path -LiteralPath $workspacePath -PathType Container)) {
    throw "Workspace не найден: $workspacePath"
}
if (-not (Test-Path -LiteralPath (Join-Path $gamePathResolved 'Data') -PathType Container)) {
    throw "Каталог Data игры не найден: $gamePathResolved"
}

$links = @(
    @{ Label = 'Mods'; Source = "Mods\$modFolder"; Target = "Data\Mods\$modFolder"; Marker = 'meta.lsx'; Required = $true }
    @{ Label = 'Public'; Source = "Public\$modFolder"; Target = "Data\Public\$modFolder"; Marker = 'Stats'; Required = $true }
    @{ Label = 'Editor'; Source = "Editor\Mods\$modFolder"; Target = "Data\Editor\Mods\$modFolder"; Marker = $null; Required = $false }
    @{ Label = 'Projects'; Source = "Projects\$modFolder"; Target = "Data\Projects\$modFolder"; Marker = 'meta.lsx'; Required = $true }
)

foreach ($link in $links) {
    $source = [System.IO.Path]::GetFullPath((Join-Path $workspacePath $link.Source))
    $target = [System.IO.Path]::GetFullPath((Join-Path $gamePathResolved $link.Target))

    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        if ($link.Required) {
            throw "$($link.Label): обязательный каталог отсутствует: $source"
        }
        Write-Output "$($link.Label): пропущен"
        continue
    }

    if (Test-Path -LiteralPath $target) {
        $existing = Get-Item -LiteralPath $target -Force
        if (($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) {
            throw "$($link.Label): целевой путь занят настоящим каталогом: $target"
        }
        [System.IO.Directory]::Delete($target)
    }

    $parent = Split-Path $target -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null

    if ($link.Marker -and -not (Test-Path -LiteralPath (Join-Path $target $link.Marker))) {
        throw "$($link.Label): ссылка создана, но контрольный путь не читается: $($link.Marker)"
    }
    Write-Output "$($link.Label): $target -> $source"
}
