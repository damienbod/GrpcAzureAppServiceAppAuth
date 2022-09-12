Param( [string]$tenantId = "" )
$appName = "DamienTestCC4"
$appRoleName = "application-role-test"
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

# Create an Azure AD role of given name and description
function CreateApplicationAppRole([string] $Name, [string] $Description)
{
    $appRole = New-Object Microsoft.Open.AzureAD.Model.AppRole
    $appRole.AllowedMemberTypes = New-Object System.Collections.Generic.List[string]
    $appRole.AllowedMemberTypes.Add("Application");
    $appRole.DisplayName = $Name
    $appRole.Id = New-Guid
    $appRole.IsEnabled = $true
    $appRole.Description = $Description
    $appRole.Value = $Name;
    return $appRole
}

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

$appRoles = $myApp.AppRoles
Write-Host "App Roles before addition of new role.."
Write-Host $appRoles

$newRole = CreateApplicationAppRole -Name $appRoleName -Description $appRoleName
$appRoles.Add($newRole)

Set-AzureADApplication -ObjectId $myApp.ObjectId -AppRoles $appRoles 

$appRoleId = $newRole.Id

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

$apiUrl = "api://" + $myApp.AppId
$IdentifierUris = New-Object System.Collections.Generic.List[string]
$IdentifierUris.Add($apiUrl)

Set-AzureADApplication -ObjectId $myApp.ObjectID -IdentifierUris $IdentifierUris

Write-Host 'client secret:'
Write-Host $PasswordCredential.Value

# ServicePrincipal needs to be validated if this is required

$createdServicePrincipal = New-AzureADServicePrincipal -AccountEnabled $true -AppId $myApp.AppId -DisplayName $appName

Write-Host 'service principal:'
Write-Host $createdServicePrincipal.ObjectID

 
