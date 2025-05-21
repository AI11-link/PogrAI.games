Param(
    [string] $FilePath
)

# Config
$cfg = Join-Path $PSScriptRoot '..\.runconfig.json'
if (!(Test-Path $cfg)) { Write-Error "Not found $cfg"; exit 1 }
$json = Get-Content $cfg | ConvertFrom-Json

# Prepare path
$workspace = Resolve-Path (Join-Path $PSScriptRoot '..')
$file = Resolve-Path $FilePath
$rel = $file.Path.Substring($workspace.Path.Length + 1)
$UUID = $rel.Split('\')[0]
$dest = Join-Path $json.destination $UUID
$app = $json.appPath
$appFolder = Split-Path -Path $app -Parent
$appFile   = Split-Path -Path $app -Leaf

Write-Host "→ Clean: $dest"
Remove-Item "$dest\*" -Recurse -Force -ErrorAction Ignore

Write-Host "→ Copy: $workspace\$UUID → $dest"
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item "$workspace\$UUID\*" -Destination $dest -Recurse -Force

Write-Host "→ Launch: cmd /k $appFile -uuid $UUID | more"
Start-Process -FilePath "cmd.exe" -ArgumentList @(
  "/u /k",
  "mode con:cols=120 lines=200",
  "&& title PogrAI output",
  "&& cd $appFolder",
  "&& $appFile -uuid $UUID",
  "| more"
)
exit 0
