<#
    .DESCRIPTION
        This script builds an organizational SharePoint site template using the 2025FloodDamage site as a reference.
        This script checks for required modules and installs them if necessary, connects to PnP, and extracts the
        necessary information and uses it to provision a template based on the source site's settings and files. 
        Enables quick-deployment of necessary information to MMSD staff. 

        This script requires the user to have SPO Admin permissions.

    .INPUTS
        $Url: The URL of the source site you would like to connect to and create the template from.

    .OUTPUTS
        None

    .NOTES
        Version:        1.0
        Author:         KSTOLTZ
        Created Date:   1/20/2026
        Purpose/Change: Initial script development
#>

#-----Install PnP.PowerShell Module if not already installed--------------------------------
$requiredModules = @("PnP.PowerShell")

$runInstalls = $Host.UI.PromptForChoice( `
  "Required Module Check and Install", `
  "Do you want to check for modules and install if needed?", `
  @("&Yes", "&No"), `
  -1 
)

If ($runInstalls -eq 0) {
  foreach ($module in $requiredModules) {
    Write-Host ("`nChecking {0}..." -f $module)
    If (-not(Get-Module -ListAvailable -Name $module)) {
      Write-Host ("`nInstalling {0}..." -f $module)
      Install-Module -Name $module
      Import-Module -Name $module
    }
    Write-Host ("{0} already installed" -f $module)
  }
}

#-----Connect to PnP--------------------------------------------------------------------------
$Url  = "https://mmsd365.sharepoint.com/sites/2025FloodDamage/" # <- CHANGE TO SOURCE URL
Connect-PnPOnline -Url $Url -Interactive -ClientId 65268e97-a454-4c8f-9e85-92c3f68819b4 # use MMSD PnP application to authenticate

#-----Get Hub URL for hub-join and retrieve necessary IDs-------------------------------------
$HubUrl    = "https://mmsd365.sharepoint.com/sites/FinanceEvents" # URL OF HUB SITE
$hub       = Get-PnPHubSite -Identity $HubUrl # returns hub metadata - includes Id (GUID)
$hubGuid   = $hub.Id
if (-not $hubGuid) { $hubGuid = $hub.SiteId }
Write-Host "FinanceEvents hub GUID: $hubGuid" -ForegroundColor Cyan

#-----Extract site script from the source site (lists + settings but no homepage formatting)--
$baseScriptJSON = Get-PnPSiteScriptFromWeb -Url $Url -IncludeAll

#-----Append the hub-join action to the script------------------------------------------------
# Convert JSON -> PS object, append verb, then back to JSON
$scriptObj = $baseScriptJSON | ConvertFrom-Json -AsHashtable
if (-not $scriptObj.actions) {
  $scriptObj | Add-Member -MemberType NoteProperty -Name actions -Value @()
}

$joinAction = [PSCustomObject]@{
  verb = "joinHubSite"
  hubSiteId = "$hubGuid"
}

# Append the join action at the end of the other actions
$scriptObj.actions += $joinAction

# Convert back to JSON with sufficient depth
$finalScriptJSON = $scriptObj | ConvertTo-Json -Depth 20

#-----Register the site script in the organization's SharePoint-------------------------------
$siteScriptTitle = "MMSD Major Financial Event Script + HubJoin v1"
$mainScript = Add-PnPSiteScript -Title $siteScriptTitle -Content $finalScriptJSON
Write-Host "Registered Site Script ID: $($mainScript.Id)" -ForegroundColor Green

#-----Create the organizational site design (seen in "templates" section)---------------------
$designTitle = "MMSD Major Financial Crisis Site Template v1"
$designDescription = "Major event baseline + auto-join to FinanceEvents hub"

$siteDesign = Add-PnPSiteDesign `
  -Title          $designTitle `
  -WebTemplate    68 ` # specify communication site
  -SiteScriptIds  $mainScript.Id `
  -Description    $designDescription

Write-Host "Created Site Design Id: $($siteDesign.Id)" -ForegroundColor Green

#-----Scope who can use/apply this design------------------------------------------------------
Grant-PnPSiteDesignRights -Identity $siteDesign.Id -Principals @(
  "its.sharepoint.admins"
) -Rights View

Write-Host "Scoped design rights to ITS SharePoint Admins" -ForegroundColor Green

Write-Host "`nAll done. Template is available under 'From your organization' for Communication sites." -ForegroundColor Cyan

#-----Clean up----------------------------------------------------------------------------------
Disconnect-PnPOnline