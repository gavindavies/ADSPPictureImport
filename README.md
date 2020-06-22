# ADSPPictureImport
A PowerShell script to import profile pictures from Active Directory to the SharePoint User Profile Service.
If AD user has no SharePoint profile, adding '-CreateUserProfile' will create one and update the PictureUrl.

Example - ./ADSPPictureImport.ps1 -DomainDN "domaindistinguishedname" -DomainController "domaincontrollername" -MySite "mysitehost" -EveryUser -CreateUserProfile
