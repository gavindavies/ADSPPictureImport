# ADSPPictureImport
A script to import profile pictures from Active Directory to SharePoint User Profile Service.
If AD user has no SharePoint profile, adding '-CreateUserProfile' will create one and update the PictureUrl.

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
