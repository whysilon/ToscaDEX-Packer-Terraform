<#
.Synopsis
   Configures Firewall rules needed to integrate with tosca products
.NOTES
   See https://documentation.tricentis.com/tosca/2320/en/content/installation_tosca/ports.htm
#>
 
Write-Host "Setting Firewall for Tosca Components"
New-NetFirewallRule -DisplayName "TricentisGatewayService" -Description "Tricentis Gateway Service" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisGatewayService" -Description "Tricentis Gateway Service" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisLicenseServer" -Description "Tricentis License Server" -Direction Inbound -LocalPort 7070 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisLicenseServer" -Description "Tricentis License Server" -Direction Outbound -LocalPort 7070 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisMSSQLConnection" -Description "Tricentis MS SQL Connection" -Direction Outbound -LocalPort 1433 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisMobileEngineAppium" -Description "Tricentis Mobile EngineAppium" -Direction Outbound -LocalPort 4723 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisActiveDirectoryIntegration" -Description "Tricentis Active Directory Integration" -Direction Outbound -LocalPort 389 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisActiveDirectoryIntegration" -Description "Tricentis Active Directory Integration" -Direction Outbound -LocalPort 389 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "TricentisContinuousIntegration" -Description "Tricentis Continuous Integration" -Direction Inbound -LocalPort 8732 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisSAPIntegrationSolman" -Description "Tricentis SAP Integration Solman" -Direction Outbound -LocalPort 8000 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisSAPIntegrationSolmanSLD" -Description "Tricentis SAP Integration Solman SLD" -Direction Outbound -LocalPort 50000 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisDB2Connection" -Description "Tricentis DB2 Connection" -Direction Inbound -LocalPort 50000 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisDB2Connection" -Description "Tricentis DB2 Connection" -Direction Outbound -LocalPort 50000 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisOracleConnection" -Description "Tricentis Oracle Connection" -Direction Outbound -LocalPort 1521 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "TricentisOracleConnection" -Description "Tricentis Oracle Connection" -Direction Inbound -LocalPort 1521 -Protocol TCP -Action Allow
