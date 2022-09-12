Param( [string]$tenantId = "" )
$appName = "DamienTestCC1"
$allowPassthroughUsers = false
##################################
### testParams
##################################

function testParams {

	if (!$tenantId) 
	{ 
		Write-Host "tenantId is null"
		exit 1
	}
}

testParams

Write-Host "Begin API Azure App Registration CC application with role application"

##################################
### Create Azure App Registration for Graph
### https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureadapplication?view=azureadps-2.0
### https://stackoverflow.com/questions/42164581/how-to-configure-a-new-azure-ad-application-through-powershell
##################################

$Guid = New-Guid
$startDate = Get-Date

$PasswordCredential = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordCredential
$PasswordCredential.StartDate = $startDate
$PasswordCredential.EndDate = $startDate.AddYears(10)
$PasswordCredential.KeyId = $Guid
$PasswordCredential.Value = ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($Guid))))

if(!($myApp = Get-AzureADApplication -Filter "DisplayName eq '$($appName)'"  -ErrorAction SilentlyContinue))
{
    $myApp = New-AzureADApplication -DisplayName $appName -PasswordCredentials $PasswordCredential -AllowPassthroughUsers $allowPassthroughUsers

	Write-Host $myApp | Out-String | ConvertFrom-Json	
}

# TODO create role
$appRoleId = "62a82d76-70ea-41e2-9197-370581804d09"

$req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$acc1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $appRoleId,"Role"
$req.ResourceAccess = $acc1
$req.ResourceAppId = $myApp.AppId
Set-AzureADApplication -ObjectId $myApp.ObjectId -RequiredResourceAccess $req

# Disable the App Registration scope.
$Scopes = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.OAuth2Permission]
$Scope = $myApp.Oauth2Permissions | Where-Object { $_.Value -eq "user_impersonation" }
$Scope.IsEnabled = $false
$Scopes.Add($Scope)
Set-AzureADApplication -ObjectId $myApp.ObjectID -Oauth2Permissions $Scopes

Write-Host 'client secret:'
Write-Host $PasswordCredential.Value
 
