$base = "$Env:USERPROFILE\.gradle\caches\8.10.2\transforms"
if (-not (Test-Path $base)) { Write-Output "Transforms directory not found: $base"; exit 0 }
$dirs = Get-ChildItem -Path $base -Directory
foreach ($d in $dirs) {
  $count = (Get-ChildItem -Path $d.FullName -File -Recurse -ErrorAction SilentlyContinue).Count
  if ($count -eq 0) {
    try {
      Remove-Item -Path $d.FullName -Recurse -Force -ErrorAction Stop
      Write-Output "Removed empty transform dir: $($d.FullName)"
    } catch {
      Write-Output "Failed to remove: $($d.FullName) - $($_.Exception.Message)"
    }
  }
}
Write-Output "Cleanup finished."