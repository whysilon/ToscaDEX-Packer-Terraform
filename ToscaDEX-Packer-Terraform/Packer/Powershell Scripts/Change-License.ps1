#######################
## Configure License ##
####################### 

Start-Process -FilePath "$($env:TRICENTIS_LICENSING_HOME)/ToscaLicenseConfiguration" -ArgumentList "connect-on-premise -a '$($env:ServerUri)' -o '$($env:ServerPort)'" -Wait