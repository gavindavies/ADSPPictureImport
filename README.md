# ADSPPictureImport
A script to import profile pictures from Active Directory to SharePoint User Profile Service.
If AD user has no SharePoint profile, adding '-CreateUserProfile' will create one and update the PictureUrl.

 DomainDN - Distinguished domain name e.g. DC=contoso,DC=com.
 
DomainController - Domain Controller machine name.

MySite - My site host.

EveryUser - If set, every user profile photo will be updated.

CreateUserProfile - If set, a user profile will be created for the AD user if one does not exist.

Example - ./ADSPPictureImport.ps1 -DomainDN "domaindistinguishedname" -DomainController "domaincontrollername" -MySite "http://mysitehost" -EveryUser -CreateUserProfile.
