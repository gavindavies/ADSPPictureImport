# ADSPPictureImport
A PowerShell script to import profile pictures from Active Directory to the SharePoint User Profile Service.
If the AD user doesn't have a SharePoint profile, adding '-CreateUserProfile', will create one and update the PictureUrl.

# Example
.\ADSPPictureImport.ps1 -DomainDN "domaindistinguishedname" -DomainController "domaincontrollername" -MySite "mysitehost" -EveryUser -CreateUserProfile
