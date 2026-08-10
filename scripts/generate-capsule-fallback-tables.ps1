param(
    [string]$AncientRoot = "..\BG3_Mods\work\ancient_current\Public\REL_Full_Ancient_c6c0d2bd-6198-de9e-30ad-e8cda1793025",
    [string]$Output = "Public\PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e\Stats\Generated\TreasureTable.txt",
    [string]$UniqueOutput = "Public\PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e\Stats\Generated\Data\Capsule_Unique_Fix.txt"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$ancientPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $AncientRoot))
$outputPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $Output))
$uniqueOutputPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $UniqueOutput))
$source = Join-Path $ancientPath "Stats\Generated\TreasureTable.txt"

if (-not (Test-Path -LiteralPath $source)) {
    throw "Не найден TreasureTable.txt Ancient Mega Pack: $source"
}

$stats = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$insideCapsuleTable = $false
foreach ($line in Get-Content -LiteralPath $source) {
    if ($line -match '^new treasuretable "REL_(?:Uncommon|Rare|Epic|Legendary)_[^"]+"') {
        $insideCapsuleTable = $true
        continue
    }
    if ($line -match '^new treasuretable ') {
        $insideCapsuleTable = $false
    }
    if ($insideCapsuleTable -and $line -match '^object category "I_(.+?)",') {
        [void]$stats.Add($Matches[1])
    }
}

$lines = [Collections.Generic.List[string]]::new()
$lines.Add("// Generated from Ancient Mega Pack capsule pools.")
$lines.Add("// Each static table preserves the original TreasureCategory tier processing.")
$lines.Add("")
foreach ($stat in ($stats | Sort-Object)) {
    if ($stat -notmatch '^[A-Za-z0-9_]+$') {
        throw "Недопустимое имя stats в капсульном пуле: $stat"
    }
    $lines.Add("new treasuretable `"PRC_$stat`"")
    $lines.Add('new subtable "-1"')
    $lines.Add("object category `"I_$stat`",1,0,0,0,0,0,0,0")
    $lines.Add("")
}

$parent = Split-Path -Parent $outputPath
New-Item -ItemType Directory -Force -Path $parent | Out-Null
[IO.File]::WriteAllLines($outputPath, $lines, [Text.UTF8Encoding]::new($false))

$blocks = [Collections.Generic.Dictionary[string,string[]]]::new([StringComparer]::Ordinal)
Get-ChildItem -LiteralPath (Join-Path $ancientPath "Stats\Generated\Data") -Filter "*.txt" |
    Sort-Object Name | ForEach-Object {
        $sourceLines = @(Get-Content -LiteralPath $_.FullName)
        for ($index = 0; $index -lt $sourceLines.Count; $index++) {
            if ($sourceLines[$index] -notmatch '^new entry "(.+)"') {
                continue
            }

            $entry = $Matches[1]
            $end = $index + 1
            while ($end -lt $sourceLines.Count -and $sourceLines[$end] -notmatch '^new entry ".+"') {
                $end++
            }

            $lastContent = $end - 1
            while ($lastContent -gt $index -and [string]::IsNullOrWhiteSpace($sourceLines[$lastContent])) {
                $lastContent--
            }
            $blocks[$entry] = [string[]]$sourceLines[$index..$lastContent]
            $index = $end - 1
        }
    }

$uniqueLines = [Collections.Generic.List[string]]::new()
$uniqueLines.Add("// Generated from every stats entry referenced by Ancient Mega Pack capsule pools.")
$uniqueLines.Add("// Preserve Ancient's complete final override and only repair its invalid empty Unique integer.")
$uniqueLines.Add("")
foreach ($stat in ($stats | Sort-Object)) {
    if (-not $blocks.ContainsKey($stat)) {
        throw "Не найдена точная stats-запись для капсульного кандидата: $stat"
    }

    $hasUnique = $false
    foreach ($line in $blocks[$stat]) {
        if ($line -match '^\s*data "Unique" ') {
            if (-not $hasUnique) {
                $uniqueLines.Add('data "Unique" "0"')
            }
            $hasUnique = $true
        }
        else {
            $uniqueLines.Add($line)
        }
    }
    if (-not $hasUnique) {
        $uniqueLines.Add('data "Unique" "0"')
    }
    $uniqueLines.Add("")
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $uniqueOutputPath) | Out-Null
[IO.File]::WriteAllLines($uniqueOutputPath, $uniqueLines, [Text.UTF8Encoding]::new($false))
Write-Output "Создано статических fallback-таблиц: $($stats.Count)"
Write-Output "Файл: $outputPath"
Write-Output "Создано статических Unique-переопределений: $($stats.Count)"
Write-Output "Файл: $uniqueOutputPath"
