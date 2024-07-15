<#
.Synopsis
   Installs Tricentis Tosca
#>

function Get-FileFromURL {
   # https://stackoverflow.com/questions/46830703
   [CmdletBinding()]
   param(
       [Parameter(Mandatory, Position = 0)]
       [System.Uri]$URL,
       [Parameter(Mandatory, Position = 1)]
       [string]$Filename
   )

   process {
       try {
           $request = [System.Net.HttpWebRequest]::Create($URL)
           $request.set_Timeout(5000) # 5 second timeout
           $response = $request.GetResponse()
           $total_bytes = $response.ContentLength
           $response_stream = $response.GetResponseStream()

           try {
               # 256KB works better on my machine for 1GB and 10GB files
               # See https://www.microsoft.com/en-us/research/wp-content/uploads/2004/12/tr-2004-136.pdf
               # Cf. https://stackoverflow.com/a/3034155/10504393
               $buffer = New-Object -TypeName byte[] -ArgumentList 256KB
               $target_stream = [System.IO.File]::Create($Filename)

               $timer = New-Object -TypeName timers.timer
               $timer.Interval = 1000 # Update progress every second
               $timer_event = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
                   $Global:update_progress = $true
               }
               $timer.Start()

               do {
                   $count = $response_stream.Read($buffer, 0, $buffer.length)
                   $target_stream.Write($buffer, 0, $count)
                   $downloaded_bytes = $downloaded_bytes + $count

                   if ($Global:update_progress) {
                       $percent = $downloaded_bytes / $total_bytes
                       $status = @{
                           completed  = "{0,6:p2} Completed" -f $percent
                           downloaded = "{0:n0} MB of {1:n0} MB" -f ($downloaded_bytes / 1MB), ($total_bytes / 1MB)
                           speed      = "{0,7:n0} KB/s" -f (($downloaded_bytes - $prev_downloaded_bytes) / 1KB)
                           eta        = "eta {0:hh\:mm\:ss}" -f (New-TimeSpan -Seconds (($total_bytes - $downloaded_bytes) / ($downloaded_bytes - $prev_downloaded_bytes)))
                       }
                       $progress_args = @{
                           Activity        = "Downloading $URL"
                           Status          = "$($status.completed) ($($status.downloaded)) $($status.speed) $($status.eta)"
                           PercentComplete = $percent * 100
                       }
                       Write-Progress @progress_args

                       $prev_downloaded_bytes = $downloaded_bytes
                       $Global:update_progress = $false
                   }
               } while ($count -gt 0)
           }
           finally {
               if ($timer) { $timer.Stop() }
               if ($timer_event) { Unregister-Event -SubscriptionId $timer_event.Id }
               if ($target_stream) { $target_stream.Dispose() }
               # If file exists and $count is not zero or $null, than script was interrupted by user
               if ((Test-Path $Filename) -and $count) { Remove-Item -Path $Filename }
           }
       }
       finally {
           if ($response) { $response.Dispose() }
           if ($response_stream) { $response_stream.Dispose() }
       }
   }
}

Write-Output "Installing Tricentis Tosca."
Write-Output "Using setup type $($env:tosca_setup_type)."

try {
   Set-Location $env:Temp
   Write-Output "Downloading setup from from $(($env:tosca_setup_path).split('?')[0]) to path $($env:Temp)"
   $destination = Join-Path -Path $env:TEMP -ChildPath "toscasetup.zip"
   Get-FileFromURL -URL $env:tosca_setup_path -Filename $destination   
}
catch {
   throw "An Error occurred while downloading the file: $($_.Exception)"
}

try {
	$extractPath = Join-Path -Path $env:Temp -ChildPath 'toscasetup'
	Expand-Archive -Path $destination -DestinationPath $extractPath	
}
catch {
   throw "An Error occurred while extracting the file: $($_.Exception)"
}

# Validate file downloaded is correct
$refHashPath = Join-Path -Path $extractPath -ChildPath '\*.exe.sha256'
$refHash = Get-Content -Path $refHashPath
$fileHashPath = Join-Path -Path $extractPath -ChildPath '\*.exe'
$fileHash = Get-FileHash -Path $fileHashPath -Algorithm SHA256
$fileHashPath = $fileHash.Path
Write-Output "$($fileHashPath)"
if(!$refHash -eq $fileHash.Hash) {
	throw "File is invalid!"
}
else {
	Write-Output "Reference Hash: $refHash"
	Write-Output "File Hash: $($fileHash.Hash)"
}
Write-Output "CHROME_INSTALL $($env:chrome_install) EDGE_INSTALL $($env:edge_install)"
if($env:chrome_install) {
	Write-Output "Disabling Chrome First Run Experience..."
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Google'
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome'
	# Disabling First Run Experience, ensuring extension is installed and enabled and disabling enhanced ad privacy user flow block
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -PropertyType 'String' -Name 'PromotionalTabsEnabled' -Value 0
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -PropertyType 'String' -Name 'ExtensionSettings' -Value '{ "njjjlolnnicemgigahffncnddbioccpo": { "update_url" : "https://clients2.google.com/service/update2/crx", "installation_mode" : "normal_installed", "toolbar_pin" : "force_pinned" } }'
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -PropertyType 'String' -Name 'PrivacySandboxPromptEnabled' -Value 0
}
if($env:edge_install) {
	Write-Output "Disabling Edge First Run Experience..."
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' | New-ItemProperty -PropertyType 'string' -Name 'HideFirstRunExperience' -Value 1
}

switch ($env:tosca_setup_type) {
   { $_ -in "ToscaCommander", "ToscaServer" } { 
      Write-Output "Installing Tricentis Tosca with installation type Tosca Commander."
      Start-Process -FilePath $fileHashPath -ArgumentList "/s DIAGNOSTICS=1 ENABLE_TOSCA_DATAINTEGRITY=1 EXAMPLE_WORKSPACES=1 MOBILE_TESTING=1 START_SERVICES=0 NETDRIVE=0 INSTALLDIR=`"C:\Program Files (x86)\TRICENTIS\Tosca Testsuite`" TOSCA_PROJECTS=`"C:\Tosca_Projects`" TRICENTIS_ALLUSERS_APPDATA=`"C:\ProgramData\TRICENTIS\Tosca Testsuite\7.0.0`" CHROME_INSTALL=$($env:Chrome_Install) EDGE_INSTALL=$($env:Edge_Install) /qn" -Wait | Out-Default 
   }
   "DexAgent" { 
      Write-Output "Installing Tricentis Tosca with installation type Dex Agent."
      Start-Process -FilePath $fileHashPath -ArgumentList "/s DIAGNOSTICS=1 ENABLE_TOSCA_DATAINTEGRITY=0 EXAMPLE_WORKSPACES=0 MOBILE_TESTING=0 START_SERVICES=0 NETDRIVE=0 ADDLOCAL=TricentisTBox,DexAgent INSTALLDIR=`"C:\Program Files (x86)\TRICENTIS\Tosca Testsuite`" TOSCA_PROJECTS=`"C:\Tosca_Projects`" TRICENTIS_ALLUSERS_APPDATA=`"C:\ProgramData\TRICENTIS\Tosca Testsuite\7.0.0`" CHROME_INSTALL=$($env:Chrome_Install) EDGE_INSTALL=$($env:Edge_Install) /qn" -Wait | Out-Default
   }
   Default {
      throw 'Unknown tosca_setup_type $($env:tosca_setup_type) was provided.'
   }
}

# Remove-Item -Path .\toscasetup -Force -ErrorAction Ignore -Verbose -Recurse