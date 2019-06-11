$nic = Get-NetAdapter
Set-DnsClientServerAddress -InterfaceIndex $nic.IfIndex -ServerAddresses ('1.1.1.1','8.8.8.8')