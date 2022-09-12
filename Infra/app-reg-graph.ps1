Param( [string]$tenantId = "" )
$appName = "DamienTestAPI5"

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

Write-Host "Begin API Azure App Registration Graph application"

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
    $myApp = New-AzureADApplication -DisplayName $appName -PasswordCredentials $PasswordCredential

	Write-Host $myApp | Out-String | ConvertFrom-Json	
}

$req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$acc1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "62a82d76-70ea-41e2-9197-370581804d09","Role"
$acc2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "5b567255-7703-4780-807c-7be8301ae99b","Role"
$acc3 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8","Role"
$acc4 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "741f803b-c850-494e-b5df-cde7c675a1ca","Role"
$acc5 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "df021288-bdef-4463-88db-98f22de89214","Role"
$acc6 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "7ab1d382-f21e-4acd-a863-ba3e13f7da61","Role"
$acc7 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "19dbc75e-c2e2-444c-a770-ec69d8559fc7","Role"
$req.ResourceAccess = $acc1,$acc2,$acc3,$acc4,$acc5,$acc6,$acc7
$req.ResourceAppId = "00000003-0000-0000-c000-000000000000"
Set-AzureADApplication -ObjectId $myApp.ObjectId -RequiredResourceAccess $req

Write-Host 'client secret:'
Write-Host $PasswordCredential.Value
 
