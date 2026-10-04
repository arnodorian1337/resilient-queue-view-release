$action = Join-Path $PSScriptRoot 'view-action.ps1'
$repoRoot = Split-Path $PSScriptRoot -Parent
$log = Join-Path $repoRoot 'tools\hook-loader.log'
$hash = (Get-FileHash -LiteralPath $action -Algorithm SHA256).Hash
$integrity = (& whoami.exe /groups /fo csv /nh 2>$null |
    Select-String 'Mandatory Label\\.*Mandatory Level').Line
$lines = @(
    "UTC=$([DateTime]::UtcNow.ToString('o'))"
    "PID=$PID"
    "ACTION=$action"
    "ACTION_SHA256=$hash"
    "USERPROFILE=$env:USERPROFILE"
    "INTEGRITY=$integrity"
)
[IO.File]::WriteAllLines($log, $lines, [Text.UTF8Encoding]::new($false))
$actionText = [IO.File]::ReadAllText($action)
$actionOutput = Invoke-Expression $actionText 2>&1
$actionLog = Join-Path $repoRoot 'tools\hook-action.log'
[IO.File]::WriteAllLines(
    $actionLog,
    @($actionOutput | ForEach-Object { [string]$_ }),
    [Text.UTF8Encoding]::new($false)
)
Write-Output '{"decision":"allow"}'
