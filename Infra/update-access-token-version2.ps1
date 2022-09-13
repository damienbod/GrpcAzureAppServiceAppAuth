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

function testSubscription {
    $account = az account show | ConvertFrom-Json
	$accountTenantId = $account.tenantId
    if ($accountTenantId -ne $tenantId) 
	{ 
		Write-Host "$accountTenantId not possible, change account"
		exit 1
	}
	$accountName = $account.name
    Write-Host "tenant: $accountName can update"
}
testSubscription

##################################
### Set signInAudience to AzureADMyOrg
### Set accessTokenAcceptedVersion to version 2
##################################
$bodyApi = '{
	"signInAudience" : "AzureADMyOrg", 
	"accessTokenAcceptedVersion": 2
}' | ConvertTo-Json | ConvertFrom-Json

# https://docs.microsoft.com/en-us/graph/api/application-update
$idAppForGraphApi = $appRegObjectId
$tokenResponseApi = az account get-access-token --resource https://graph.microsoft.com
$tokenApi = ($tokenResponseApi | ConvertFrom-Json).accessToken
#Write-Host "$token"
$uriApi = 'https://graph.microsoft.com/beta/applications/' + $idAppForGraphApi
Write-Host " - $uriApi"
$headersApi = @{
    "Authorization" = "Bearer $tokenApi"
}

Invoke-RestMethod  `
	-ContentType application/json `
	-Uri $uriApi `
	-Method Patch `
	-Headers $headersApi `
	-Body $bodyApi

Write-Host " - Updated signInAudience to AzureADMyOrg"
Write-Host " - Updated accessTokenAcceptedVersion to 2"