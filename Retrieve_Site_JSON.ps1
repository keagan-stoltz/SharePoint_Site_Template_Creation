
<#

NOT A PART OF THE TEMPLATE CREATION WORKFLOW - KEPT TO USE IN CASE .JSON FILE IS NEEDED IN THE FUTURE

#>

# 0) Ensure PnP.PowerShell is available
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force
}
Import-Module PnP.PowerShell

# 1) Define the source site
$SourceSiteUrl = "https://mmsd365.sharepoint.com/sites/2025FloodDamage/"

# Use a specific Entra App registration
$ClientId = "65268e97-a454-4c8f-9e85-92c3f68819b4"
Connect-PnPOnline -Url $SourceSiteUrl -Interactive -ClientId $ClientId

# 2) Retrieve the site script JSON from the source site
# Exports lists, content types, settings, etc.
$siteScriptJson = Get-PnPSiteScriptFromWeb -Url $SourceSiteUrl -IncludeAll

# 3) Build an output file name and path from current directory
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$fileName  = "2025FloodDamage_site_script_$timestamp.json"
$outPath   = Join-Path -Path (Get-Location).Path -ChildPath $fileName

# 4) Save the JSON
  # Update: use UTF8 (without BOM) so it’s friendly for editors and later import
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outPath, $siteScriptJson, $utf8NoBom)

Write-Host "`nSite script exported:" -ForegroundColor Cyan
Write-Host $outPath -ForegroundColor Green

# 5) Disconnect
Disconnect-PnPOnline