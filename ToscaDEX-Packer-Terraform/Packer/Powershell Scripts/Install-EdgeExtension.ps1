<#
.Synopsis
   Checks if Edge Browser Extension is enabled (1, 0 = Disabled) and installs it
#>

Write-Output "Checking if EDGE_INSTALL is true"

if($env:Edge_Install -eq 0){
	Write-Output "EDGE_INSTALL == $($env:Edge_Install)... Not installing Edge Browser Extension"
}
else {
	New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\$($env:edge_ext_id)" | New-ItemProperty -Name "update_url" -Value $env:update_url
	Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\$($env:edge_ext_id)"
}