<#
.SYNOPSIS
	A script to import profile pictures from Active Directory to SharePoint User Profile Service.

.PARAMETER DomainDN
	Distinguished domain name e.g. DC=contoso,DC=com.

.PARAMETER DomainController
    Domain Controller machine name.

.PARAMETER MySite
    My site host.

.PARAMETER EveryUser
    If set, every user profile photo will be updated.

.PARAMETER CreateUserProfile
    If set, a user profile will be created for the AD user if one does not exist.

.EXAMPLE
    ./ADSPPictureImport.ps1 -DomainDN "domaindistinguishedname" -DomainController "domaincontrollername" -MySite "http://mysitehost" -EveryUser -CreateUserProfile.

-----------------------------------------------------------------------------------------------------------------------------------
Script name : ADSPPictureImport.ps1
Authors : Gavin Davies
Version : V1.0
Dependencies : Microsoft.SharePoint.PowerShell
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
Version Changes:
Date:       Version:    Changed By:     Info:
            V1.0
20/06/2020  V1.1        Gavin Davies    Added ability to create User profiles
-----------------------------------------------------------------------------------------------------------------------------------
DISCLAIMER
   THIS CODE IS SAMPLE CODE. THESE SAMPLES ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
   MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES
   OF MERCHANTABILITY OR OF FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK ARISING OUT OF THE USE OR
   PERFORMANCE OF THE SAMPLES REMAINS WITH YOU. IN NO EVENT SHALL MICROSOFT OR ITS SUPPLIERS BE LIABLE FOR
   ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS
   INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
   INABILITY TO USE THE SAMPLES, EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
   BECAUSE SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR
   INCIDENTAL DAMAGES, THE ABOVE LIMITATION MAY NOT APPLY TO YOU.
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory = $true)]
	[string]$DomainDN,
	[string]$DomainController,
    [string]$MySite,
    [switch]$EveryUser,
    [switch]$CreateUserProfile
)

Function DoesUserProfileExist ($User) {
    return $ProfileManager.UserExists($User.Properties.userprincipalname)
}

Function CreateUserProfile ($User) {
    Try {
        $ProfileManager.CreateUserProfile($User.Properties.userprincipalname) | Out-Null
        Start-Sleep -Seconds 5
        Write-Output "User profile created."
    } Catch { Write-Output "An error occured during profile creation for $($User.Properties.userprincipalname)." $_ }
}

Function ADUserHasChanged ($User) {
    return $User.Properties.whenchanged -gt $(Get-Date).AddHours(-1)
}

#Obtain the User Profile Manager and Photo Store.
Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction Stop
$ProfileManager = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($(Get-SPServiceContext($MySite)), $true)
$PhotoStore = $($(Get-SPSite $MySite).RootWeb.GetFolder("User Photos/Profile Pictures")).Files
$UpdatePhotoStore = $False

#Return all the Users in AD that have a thumbnail photo.
$Selector = New-Object DirectoryServices.DirectorySearcher
$Selector.SearchRoot = $(New-Object DirectoryServices.DirectoryEntry "LDAP://$DomainController/CN=Users,$DomainDN")
$Users = $Selector.FindAll() | Where-Object { $_.Properties.thumbnailphoto -ne $null }

Foreach ($User in $Users) {

    Write-Output $User.Properties.samaccountname

    #Does the AD user have a SharePoint profile? If not, depending on $CreateUserProfile, a profile will be created for the user.
    If(!$(DoesUserProfileExist($User)) -and $CreateUserProfile) { CreateUserProfile($User) }

    $UserProfile = $ProfileManager.GetUserProfile([string]$User.Properties.userprincipalname)
    $ProfileHasPicture = $($UserProfile.PictureUrl -eq "$($MySite)/User Photos/Profile Pictures/$($User.Properties.samaccountname)_LThumb.jpg")

    #If the user profile doesn't contain a photo store URL, update PictureUrl property.
    If(!$ProfileHasPicture) {

        $UserProfile["PictureUrl"].Value = "$($MySite)/User Photos/Profile Pictures/$($User.Properties.samaccountname)_LThumb.jpg"
        $UserProfile.Commit()

    }

    #If the AD user has changed in the last hour, add AD user thumbnail to the photo store.
    If($(ADUserHasChanged($User)) -or $EveryUser) {
        Try {

            $PhotoStore.Add("User Photos/Profile Pictures/$($User.Properties.samaccountname)_LThumb.jpg", $User.Properties.thumbnailphoto[0], $true) | Out-Null
            $UpdatePhotoStore = $true
            Write-Output "User profile photo updated."

        }
        Catch { Write-Output "An error occurred while adding photo to the Photo Store for $($User.Properties.userprincipalname)." $_ }
    } Else { Write-Output "No changes made." }

    Write-Output "##############################"
}

Start-Sleep -Seconds 5

If($UpdatePhotoStore) {

    Write-Output "Updating the photostore..."
    Update-SPProfilePhotoStore -MySiteHostLocation $MySite

}

Write-Output "Complete."