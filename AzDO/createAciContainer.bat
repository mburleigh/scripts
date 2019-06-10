set imageRegistry=%1
REM echo "image registry:" %imageRegistry%
set imageRepository=%2
REM echo "image repository:" %imageRepository%
set imageName=%3
REM echo "image name:" %imageName%
set id=%4
REM echo "id:" %id%

call az acr update -n %imageRegistry% --admin-enabled true

call az acr show --name %imageRegistry% --query loginServer --output tsv > tmp
set /p loginserver= < tmp
REM echo "login server:" %loginserver%

call az acr credential show --name %imageRegistry% --query "username" --output tsv > tmp
set /p username= < tmp
REM echo "user name:" %username%

call az acr credential show --name %imageRegistry% --query "passwords[0].value" --output tsv > tmp
set /p password= < tmp
REM echo "password:" %password%

call az acr show --name %imageRegistry% --query "resourceGroup" --output tsv > tmp
set /p resourcegroup= < tmp
REM echo "resource group:" %resourcegroup%

set image=%loginserver%/%imagerepository%:%imageName%
echo "image:" %image%

call az container create -g %resourcegroup% -n %imageName% --image %image% --cpu 1 --memory 1^
  --registry-login-server %loginserver% --registry-username %username% --registry-password %password%^
  --dns-name-label %imageName%-%id% --ports 443 --os-type Windows

rem call az container exec -g %resourcegroup% -n %imageName% --exec-command powershell 
rem $nic = Get-NetAdapter; Set-DnsClientServerAddress -InterfaceIndex $nic.IfIndex -ServerAddresses ('1.1.1.1','8.8.8.8');
rem exit

call az container restart -g %resourcegroup% -n %imageName% --no-wait

call az container show --resource-group %resourcegroup% --name %imageName% --query ipAddress.fqdn --output tsv > tmp
set /p url= < tmp
echo "url:" %url%

echo ##vso[task.setvariable variable=containerUrl]%url%

echo "Done!!!"