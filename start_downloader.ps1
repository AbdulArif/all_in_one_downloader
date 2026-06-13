$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$logPath = Join-Path $projectRoot '.facebook-resolver.log'
$errorLogPath = Join-Path $projectRoot '.facebook-resolver.err.log'

$listener = Get-NetTCPConnection -LocalPort 9000 -State Listen -ErrorAction SilentlyContinue
if ($listener) {
    Write-Output 'Facebook downloader is already running on http://localhost:9000/'
    exit 0
}

python -c "import yt_dlp" 2>$null
if ($LASTEXITCODE -ne 0) {
    python -m pip install --user yt-dlp
}

Start-Process -FilePath 'python' `
    -ArgumentList @((Join-Path $projectRoot 'tools\facebook_resolver.py')) `
    -WorkingDirectory $projectRoot `
    -RedirectStandardOutput $logPath `
    -RedirectStandardError $errorLogPath `
    -WindowStyle Hidden

Start-Sleep -Seconds 2
$listener = Get-NetTCPConnection -LocalPort 9000 -State Listen -ErrorAction SilentlyContinue
if (-not $listener) {
    throw "Downloader failed to start. Check $errorLogPath"
}

Write-Output 'Facebook downloader started on http://localhost:9000/'
