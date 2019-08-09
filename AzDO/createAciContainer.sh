imageRegistry=$1
#echo "image registry:" $imageRegistry
imageRepository=$2
#echo "image repository:" $imageRepository
imageName=$3
#echo "image name:" $imageName
id=$4
#echo "id:" $id

az acr update -n $imageRegistry --admin-enabled true

loginserver=$(az acr show -n $imageRegistry --query loginServer --output tsv)
#echo "login server:" $loginserver

username=$(az acr credential show -n $imageRegistry --query "username" --output tsv)
#echo "user name:" $username

password=$(az acr credential show -n $imageRegistry --query "passwords[0].value" --output tsv)
#echo "password:" $password

resourcegroup=$(az acr show -n $imageRegistry --query "resourceGroup" --output tsv)
#echo "resource group:" $resourcegroup

image=$loginserver/$imageRepository:$imageName
#echo "image:" $image

az container create -g $resourcegroup -n $imageName --image $image --cpu 1 --memory 1 --registry-login-server \
  $loginserver --registry-username $username --registry-password $password --dns-name-label $imageName-$id --ports 80

az container restart -g $resourcegroup -n $imageName --no-wait

url=$(az container show -g $resourcegroup -n $imageNane --query ipAddress.fqdn)
echo "url:" $url
echo "##vso[task.setvariable variable=containerUrl]$url"

echo "Done!!!"