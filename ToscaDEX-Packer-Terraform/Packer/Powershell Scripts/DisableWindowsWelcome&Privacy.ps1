<#
.Synopsis
   Disable Internet Explorer welcome screen on windows 10 and Disable the mandatory privacy settings startup screen on windows 10.
#>

#Disable Internet Explorer welcome screen
Write-Output "Disable Internet Explorer welcome screen"
$AdminKey = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
New-Item -Path $AdminKey -Value 1 -Force
Set-ItemProperty -Path $AdminKey -Name "DisableFirstRunCustomize" -Value 1 -Force

# Disable privacy settings
Write-Output "Disable Privacy Settings Startup Screen"
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\" -Name "OOBE" -ErrorAction SilentlyContinue
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE\" -Name "DisablePrivacyExperience" -Value 1 -Force   
Write-Output "Choose privacy settings for your device startup screen has been disabled."