#Requires -PSEdition Core
#Adapted from https://github.com/Tricentis/Tosca.CloudTemplates/tree/main
#########################################
## Post Deploy DEX Agent Configuration ##
#########################################
<#
.SYNOPSIS
    This script will configure Tosca Distribution Agent,
    setting security to Transport for SSL/TLS and updates
    the Tosca Server name from a command line argument
  
.DESCRIPTION
    This script will run during DeployVM.ps1 to set initial 
    configuration and local policies. On first run, the DEX
    Agent will be pointed to the local computername. A second
    run WILL be required once the DNS name of the Tosca Server
    is known


.EXAMPLE
    PS>./PostDeploy-ToscaDEX.ps1
#>

#########################
## Configure DEX Agent ##
######################### 
# Backup DEX Agent Configuration File
$DEXAgent='C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\DistributedExecution\ToscaDistributionAgent.exe.config'
#Test-Path $DEXAgent
Copy-Item -Path "$DEXAgent" -Destination "$DEXAgent.ORIG"

# Configure DEX Agent 
Write-Output "Configuring DEXAgent settings"
$DEXML = [xml](Get-Content $DEXAgent)
$ENDPOINTS = $DEXML.SelectNodes("//client/endpoint")
$ENDPOINTS[0].SetAttribute("address","http://$($env:ServerUri):5007/DistributionServerService/CommunicationService.svc")
$ENDPOINTS[1].SetAttribute("address","http://$($env:ServerUri):5007/DistributionServerService/ArtifactService.svc")
$DEXML.Save($DEXAgent)

###########################
## Configure Environment ##
###########################
# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Disable Hibernate
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Power' -name "HibernateEnabled" -value 0

# Disable Screensaver
#Set-ItemProperty -Path ‘HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop\’ -Name "ScreenSaveActive" -Value 0

# Set Time Limit for Disconnected Sessions = DISABLED
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' -Name "RemoteAppLogoffTimeLimit" -Value 0

# Always Prompt for Password Upon Connection = DISABLED
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' -Name "fPromptForPassword" -Value 0

# Interactive Logon: Do Not Require CTRL+ALT+DEL = ENABLED
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\' -Name "DisableCAD" -value 1
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' -Name "DisableCAD" -value 1

# Start DEX Agent on Login
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\' -Name 'DEX Agent' -value "C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\DistributedExecution\ToscaDistributionAgent.exe"

###############
## Start DEX ##
###############

# Run ToscaDistributionAgent.exe
Start-Process -FilePath "C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\DistributedExecution\ToscaDistributionAgent.exe"
Write-Output "Sleeping for 10 minutes"
Start-Sleep -Seconds 600