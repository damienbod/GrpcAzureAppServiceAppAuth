
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
.\app-reg-application-cc.ps1 -tenantId 5698af84-5720-4ff0-bdc3-9d9195314244 -appName AppRegTest
```

```
.\app-reg-graph.ps1 -tenantId 5698af84-5720-4ff0-bdc3-9d9195314244 -appName AppGraphTest
```

# Login Azure CLI 

```
az login --tenant 5698af84-5720-4ff0-bdc3-9d9195314244
```

You can read the id from the manufest (ObjectId) "id": "ba62783f-fb6b-48a9-ba51-f56355e84926",

```
.\update-access-token-version2.ps1 -TenantId 5698af84-5720-4ff0-bdc3-9d9195314244 -appRegObjectId ba62783f-fb6b-48a9-ba51-f56355e84926
```


# Create new secret

You can read the id from the manufest (ObjectId) "id": "ba62783f-fb6b-48a9-ba51-f56355e84926",

```
.\app-new-secrets.ps1 -TenantId 5698af84-5720-4ff0-bdc3-9d9195314244 -appRegObjectId ba62783f-fb6b-48a9-ba51-f56355e84926
```
