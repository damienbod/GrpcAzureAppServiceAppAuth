Param( [string]$tenantId = "", [string]$appRegObjectId = "" )
##################################
### testParams
##################################
function testParams {
	if (!$tenantId) { 
		Write-Host "tenantId is null"
		exit 1
	}
	if (!$appRegObjectId) { 
		Write-Host "appRegObjectId is null"
		exit 1
	}
}
testParams

Write-Host "Begin create new secret"

##################################
### Creat new secret
##################################
$Guid = New-Guid
$startDate = Get-Date

$PasswordCredential = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordCredential
$PasswordCredential.StartDate = $startDate
$PasswordCredential.EndDate = $startDate.AddYears(20)
$PasswordCredential.KeyId = $Guid
$PasswordCredential.Value = ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($Guid))))

Set-AzureADApplication -ObjectId $appRegObjectId -PasswordCredentials $PasswordCredential


Write-Host 'client secret:'
Write-Host $PasswordCredential.Value

 
