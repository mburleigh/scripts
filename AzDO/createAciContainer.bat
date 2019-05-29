set containerRegistry=%1
REM echo "container registry:" %containerRegistry%
REM echo "parameter 2:" %2

call az acr update -n %containerRegistry% --admin-enabled true

call az acr show --name %containerRegistry% --query loginServer --output tsv > tmp
set /p loginserver= < tmp
REM echo "login server:" %loginserver%

call az acr credential show --name %containerRegistry% --query "username" --output tsv > tmp
set /p username= < tmp
REM echo "user name:" %username%

call az acr credential show --name %containerRegistry% --query "passwords[0].value" --output tsv > tmp
set /p password= < tmp
REM echo "password:" %password%

call az acr show --name %containerRegistry% --query "resourceGroup" --output tsv > tmp
set /p resourcegroup= < tmp
REM echo "resource group:" %resourcegroup%

set imagerepository=%4
set image=%loginserver%/%imagerepository%:%2
echo "image:" %image%

call az container create -g %resourcegroup% -n %2 --image %image% --cpu 1 --memory 1 --registry-login-server %loginserver% --registry-username %username% --registry-password %password% --dns-name-label %2-%3 --ports 80 --os-type Windows

call az container exec -g %resourcegroup% -n %2 --exec-command powershell 

$nic = Get-NetAdapter ; Set-DnsClientServerAddress -InterfaceIndex $nic.IfIndex -ServerAddresses ('1.1.1.1','8.8.8.8');
exit

call az container restart -g %resourcegroup% -n %2 --no-wait

call az container show --resource-group %resourcegroup% --name %2 --query ipAddress.fqdn --output tsv > tmp
set /p url= < tmp
echo "url:" %url%

echo ##vso[task.setvariable variable=containerUrl]%url%

echo "Done!!!"