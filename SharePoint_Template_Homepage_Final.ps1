<#
    .DESCRIPTION
        This script works off of the template creation script and should be ran afterward. It builds
        off of the foundation (site settings and file directory) the previous script created and applies
        the formatting of a desired SharePoint site's homepage onto the site created with the template. 
        This allows for quick provisioning and customization of the site which will resolve the previous
        issue of not having a site ready in time.

        This script requires the user to have SPO Admin permissions.

    .INPUTS
        $TargetSiteUrl: The URL of the target site you would like the source site's homepage applied to.

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

#-----Variable definitions--------------------------------------------------------------------------
$SourceSiteUrl = "https://mmsd365.sharepoint.com/sites/TESTINGTEMPLATE"
$TargetSiteUrl = "newly created SharePoint site URL" # <- NEEDS TO BE UPDATED WITH NEW SITE
$HomePageFileName = "Home.aspx"

# Use app's temp folder to store the script until it's used
$TempFilePath = "$env:TEMP\Testing\"

#-----Connect to source site using MMSD PnP application---------------------------------------------
Write-Host "Connecting to SOURCE site..." -ForegroundColor Cyan
Connect-PnPOnline -Url $SourceSiteUrl -Interactive -ClientId 65268e97-a454-4c8f-9e85-92c3f68819b4

#-----Download the homepage to temp folder----------------------------------------------------------
Write-Host "Downloading homepage from source site..." -ForegroundColor Cyan
Get-PnPFile `
    -Url "SitePages/$HomePageFileName" `
    -Path $TempFilePath `
    -FileName $HomePageFileName `
    -AsFile `
    -Force

#-----Disconnect from the current site to enable a reconnection-------------------------------------
Disconnect-PnPOnline

#-----Connect to the target site using the same method----------------------------------------------
Write-Host "Connecting to TARGET site..." -ForegroundColor Cyan
Connect-PnPOnline -Url $TargetSiteUrl -Interactive -ClientId 65268e97-a454-4c8f-9e85-92c3f68819b4

#-----Upload homepage to SitePages, overwrite if it already exists----------------------------------
Write-Host "Uploading homepage to target site..." -ForegroundColor Cyan
Add-PnPFile `
    -Path "C:\Users\KStoltz\AppData\Local\Temp\Testing\Home.aspx" `
    -Folder "SitePages" 

#-----Set uploaded page as the site homepage--------------------------------------------------------
Write-Host "Setting uploaded page as the site homepage..." -ForegroundColor Cyan
Set-PnPHomePage -RootFolderRelativeUrl "SitePages/$HomePageFileName"

#-----Clean up--------------------------------------------------------------------------------------
Disconnect-PnPOnline


<#
REFERENCES FOR LATER

https://pnp.github.io/powershell/cmdlets/Add-PnPFile.html
https://pnp.github.io/powershell/cmdlets/Get-PnPFile.html
https://pnp.github.io/powershell/cmdlets/Set-PnPHomePage.html
https://pnp.github.io/powershell/cmdlets/Invoke-PnPSiteTemplate.html

#>