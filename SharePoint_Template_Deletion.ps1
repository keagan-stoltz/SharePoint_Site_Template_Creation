<#
    .DESCRIPTION
        This script retrieves a list of all MMSD site templates and deletes the select ID. 
        Used to clean up test/trial templates created during template creation work.
        
        This script requires the user to have SPO Admin permissions.

    .INPUTS
        $idToDelete: Run the script to get a list of all the current site templates - with the proper ID
        identified, rerun or use terminal to run the deletion command with the ID specified

    .OUTPUTS
        List of site template information

    .NOTES
        Version:        1.0
        Author:         KSTOLTZ
        Created Date:   1/20/2026
        Purpose/Change: Initial script development
#>

#-----Connect to SharePoint admin--------------------------------------------------
$Url = "https://mmsd365-admin.sharepoint.com"
Connect-SPOService -Url $Url

#-----List current site templates--------------------------------------------------
$currentSiteDesigns = Get-SPOSiteDesign

foreach ($script in $currentSiteDesigns) {
    Write-Host "`nScript Name    $($script.Title)"
    Write-Host "Script ID      $($script.Id)"
}

#-----Delete site templates-------------------------------------------------------
<# $idToDelete = "xxx-xx-xxx..."
Remove-SPOSiteDesign -Identity $idToDelete
#>