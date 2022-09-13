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
		Write-Host "$accountTenantId not possible please change the change account"
		exit 1
	}
	$accountName = $account.name
    Write-Host "tenant: $accountName can update"
}
testSubscription

##################################
### Set accessTokenAcceptedVersion to version 2
##################################

$params = @{
	RequestedAccessTokenVersion = 2
}

Update-MgApplication -ApplicationId $appRegObjectId -BodyParameter $params

Write-Host " - Updated accessTokenAcceptedVersion to 2"