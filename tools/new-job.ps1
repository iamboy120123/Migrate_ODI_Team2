# new-job.ps1 — เปิดงานใหม่ (ดับเบิลคลิก / รันใน PowerShell ที่ไหนก็ได้ใน workspace)
# = python tools\workspace.py new-job  (ส่งตัวเลือกต่อได้ เช่น .\tools\new-job.ps1 --wave W1)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$py = $null
foreach ($c in @(@('py', '-3'), @('python'), @('python3'))) {
    if (Get-Command $c[0] -ErrorAction SilentlyContinue) { $py = $c; break }
}
if (-not $py) { Write-Host 'ไม่พบ Python — ติดตั้ง Python 3.10+ (winget install Python.Python.3.12) แล้วเปิด PowerShell ใหม่' -ForegroundColor Red; exit 1 }
$env:PYTHONIOENCODING = 'utf-8'
Push-Location $root
try {
    $pre = @(); if ($py.Count -gt 1) { $pre = @($py[1..($py.Count - 1)]) }
    & $py[0] @pre 'tools/workspace.py' 'new-job' @args
    exit $LASTEXITCODE
} finally { Pop-Location }
