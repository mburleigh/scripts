#!/bin/bash

# NOTE: special characters here will cause problems with the storage acct name
deploymentName=$1
#echo "deployment name " $deploymentName

# this is the Azure region where the resource group will live
resourceGroupLocation=$2

armTemplate=$3

resourceGroupName="$deploymentName-rg"
#echo "resource group name " $resourceGroupName
echo "##vso[task.setvariable variable=serviceResourceGroupName]$resourceGroupName"

# check for existing resource group
az group show --name $resourceGroupName 1> /dev/null
if [ $? != 0 ]; then
	echo "Resource group with name" $resourceGroupName "could not be found. Creating new resource group..."
	(
		az group create -n $resourceGroupName --location $resourceGroupLocation 1> /dev/null
	)
else
	echo "Using existing resource group..."
fi

###
# base the rest of the parameters on the deploymentName
###
serviceName=$deploymentName'-svc'
#echo "service name " $serviceName

# storage account names are 3-24 chars (lowercase & no special characters)
storageAccountName=${deploymentName,,}'sa' # TODO: remove special characters
echo "storage account name " $storageAccountName
templateFilePath=$PWD'/$armTemplate'
echo "template file path " $templateFilePath

echo "Starting deployment..."
(
    # these parameters match the ones in the ARM template
	params="{
		\"functionName\": { \"value\": \"$serviceName\" },
		\"appServicePlanName\": { \"value\": \"$deploymentName-plan\" },
		\"applicationInsightsName\": { \"value\": \"$deploymentName-ai\" },
		\"storageAccountName\": { \"value\": \"$storageAccountName\" },
		\"location\": { \"value\": \"$resourceGroupLocation\" }
	}"
	#echo $params

	# call the Azure CLI
	az group deployment create -n "$deploymentName" -g "$resourceGroupName" --template-file "$templateFilePath" --parameters "$params"
)

if [ $? == 0 ]; then
	echo "Template has been successfully deployed to $deploymentName"
fi

#this value is needed in the service deployment task
echo "##vso[task.setvariable variable=serviceName]$serviceName"