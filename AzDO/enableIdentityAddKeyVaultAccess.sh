echo "resource group =" $SERVICERESOURCEGROUPNAME
echo "service name =" $SERVICENAME
echo "key vault =" $KEYVAULTNAME

az webapp identity assign -g $SERVICERESOURCEGROUPNAME -n $SERVICENAME

id=$(az webapp identity show -n $SERVICENAME -g $SERVICERESOURCEGROUPNAME --query principalId --output tsv)
echo "id" $id

az keyvault set-policy --name $KEYVAULTNAME --object-id $id --secret-permissions get 