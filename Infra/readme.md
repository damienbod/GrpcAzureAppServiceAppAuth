
Install the required Azure AD powershell module:

```
Install-Module AzureAD -AllowClobber
```

Connect to the correct tenant using an account which has the privileges to create App registrations:

```
Connect-AzureAD -TenantId 5698af84-5720-4ff0-bdc3-9d9195314244
```

Run the script replacing the tenantId and your Azure App Registration name:

```
.\app-reg-application-cc.ps1 -TenantId 5698af84-5720-4ff0-bdc3-9d9195314244 AppRegTest
```


If using the Az powershell modules with the beta APIs.

Connect to the correct tenant using an account which has the privileges to create App registrations:

```
Connect-AzAccount -Tenant '5698af84-5720-4ff0-bdc3-9d9195314244'
```
Replace the ObjectId with the ID of the App registration:

```
Get-AzADApplication -ObjectId ba62783f-fb6b-48a9-ba51-f56355e84926 | Update-AzADApplication -requestedAccessTokenVersion 2
```