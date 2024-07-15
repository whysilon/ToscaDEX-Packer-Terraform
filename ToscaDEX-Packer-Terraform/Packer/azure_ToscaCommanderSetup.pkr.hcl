packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
    windows-update = {
      source  = "github.com/rgl/windows-update"
      version = "0.15.0"
    }
  }
}

variable "azure_cred" {
  default = {
    azure_subscription_id : "x",
    azure_client_id : "x",
    azure_client_secret : "x",
    azure_tenant_id : "x"
  }
  sensitive = true
}

variables {
  rg_name            = "ToscaWin10"
  managed_image_name = "ToscaWin10_DEXv4_OnPrem"
  script_directory   = "C:/Users/valta/Downloads/Hashicorp/Packer/PackerTosca/Powershell Scripts"
  # 1 to install browser extension in chrome/edge, 0 to not install
  chrome_install = 1
  edge_install   = 1
}

source "azure-arm" "tosca_win10" {
  azure_tags = {
    task = "Deploy Tosca"
  }
  build_resource_group_name         = var.rg_name
  managed_image_resource_group_name = var.rg_name
  managed_image_name                = var.managed_image_name

  # Azure credentials (Best to use PKR_VAR env values) (Can replace the mapping above)
  subscription_id = var.azure_cred.azure_subscription_id
  client_id       = var.azure_cred.azure_client_id
  client_secret   = var.azure_cred.azure_client_secret
  tenant_id       = var.azure_cred.azure_tenant_id

  # VM Specifications & Image Specifications
  image_offer     = "Windows-10"
  image_publisher = "MicrosoftWindowsDesktop"
  image_sku       = "win10-22h2-pro-g2"
  os_type         = "Windows"
  vm_size         = "Standard_DS2_v2"

  # Winrm configurations
  communicator   = "winrm"
  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_use_ssl  = true
  winrm_username = "packer"
  winrm_password = "P@ssw0rd!@1234!"
}

build {
  sources = ["source.azure-arm.tosca_win10"]
  # Disables Windows Welcome & Privacy Screen
  # Sets execution policy & long-path behaviour
  provisioner "powershell" {
    scripts = [
      "${var.script_directory}/InitVM.ps1",
      "${var.script_directory}/DisableWindowsWelcome&Privacy.ps1",
      "${var.script_directory}/SetFirewall.ps1",
      "${var.script_directory}/Install-PowershellCore.ps1"
    ]
  }
  provisioner "windows-restart" {
    restart_timeout = "10m"
  }
  provisioner "windows-update" {
  }
  provisioner "windows-restart" {
    restart_timeout = "10m"
  }
  # Install Chrome
  provisioner "powershell" {
    environment_vars = [
      "Chrome_Install=${var.chrome_install}",
      "Chrome_URL=https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BD1A60675-C588-372C-BF6C-6F02D7E5A297%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-statsdef_1%26installdataindex%3Dempty/chrome/install/ChromeStandaloneSetup64.exe",
    ]
    scripts = [
      "${var.script_directory}/Install-Chrome.ps1"
    ]
  }
  # Install Tosca
  provisioner "powershell" {
    # setup_path is the URL to the download for Tosca
    environment_vars = [
      "chrome_install=${var.chrome_install}",
      "edge_install=${var.edge_install}",
      "tosca_setup_path=https://files.tricentis.com/public.php?service=files&t=LqEP0CCAIfew2D9&download",
      "tosca_setup_type=DEXAgent",
    ]
    scripts = [
      "${var.script_directory}/Install-Tosca.ps1"
    ]
  }
  # Verify all required software are installed
  provisioner "powershell" {
    scripts = [
      "${var.script_directory}/List-InstalledSoftware.ps1"
    ]
  }
  # Configure DEX Agent to point to the Tosca Server
  provisioner "powershell" {
    environment_vars = [
      "serveruri=pilotstesting.southeastasia.cloudapp.azure.com"
    ]
    use_pwsh = true
    scripts = [
      "${var.script_directory}/PostDeploy-ToscaDEX.ps1"
    ]
  }
  # Clears any Sysprep entries prior to running the actual sysprep command in our inline code
  provisioner "powershell" {
    inline = [
      "Remove-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\SysPrepExternal\\Generalize' -Name '*'"
    ]
  }
  provisioner "windows-restart" {
    restart_timeout = "10m"
  }
  provisioner "file" {
    source      = "./License.xml"
    destination = "C:\\ProgramData\\TRICENTIS\\Tosca Testsuite\\7.0.0\\License\\License.XML"
  }
  # Runs sysprep to prepare image
  provisioner "powershell" {
    inline = [
      "# If Guest Agent services are installed, make sure that they have started.",
      "foreach ($service in Get-Service -Name RdAgent, WindowsAzureTelemetryService, WindowsAzureGuestAgent -ErrorAction SilentlyContinue) { while ((Get-Service $service.Name).Status -ne 'Running') { Start-Sleep -s 5 } }",

      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
