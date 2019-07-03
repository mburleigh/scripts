call az webapp identity assign -g %resourceGroup% -n %siteName%

call az webapp identity show --name %siteName% --resource-group %resourceGroup% --query principalId --output tsv > tmpFile

set /p objIdVar= < tmpFile

call az keyvault set-policy --name "%keyVault%" --object-id %objIdVar% --secret-permissions get 