# Automated provisioning and deprovisioning of Tricentis Tosca DEX Agents

This project serves as a proof-of-concept that it is possible to provision [DEX Agents](https://documentation.tricentis.com/tosca/2320/en/content/distributed_execution/dex_setup_intro.htm) that point to the relevant Tosca server on demand. The project uses [Packer](https://github.com/hashicorp/packer) to mint the base image of the DEX agents with the correct configurations (such as firewall settings, installation of crucial software, etc...) then subsequently uses [Terraform](https://github.com/hashicorp/terraform) to provision the infrastructure required to run tests. This project also uses Azure as its cloud provider.

## How to use
### Prerequisites 
 - Microsoft Azure Account
 - Packer and Terraform installed
 - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and [Powershell Core](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.4)
 - Tosca Server
 - Tosca License Server
### Steps to use this project
1. Set up the Environment Required
     1) Create a [Service Principal](https://learn.microsoft.com/en-us/cli/azure/azure-cli-sp-tutorial-1?tabs=bash). This Service Principal is for both Terraform and Packer to use in order to create images and provision infrastructure. Take note of the credentials provided for the Service Principal (i.e **client_id, tenant_id, subscription_id and client_secret**).
     2) Set the credentials as environment variables for Packer and Terraform to use.
     3) Create a [resource group](https://learn.microsoft.com/en-us/powershell/module/az.resources/new-azresourcegroup?view=azps-12.1.0)
     4) Change any variables as needed in [azure_ToscaCommanderSetup.pkr.hcl](ToscaDEX-Packer-Terraform/Packer/azure_ToscaCommanderSetup.pkr.hcl) under the variables block.
2.  Create the image
     1) Change any variables needs in .azure_ToscaCommanderSetup.pkr.hcl (This includes ServerUri of the Tosca Server and License Server, Service Principal Creds, resource group names, etc...)
     3) Run ```packer init .azure_ToscaCommanderSetup.pkr.hcl``` in the working directory of choice
     4) Run ```packer fmt .azure_ToscaCommanderSetup.pkr.hcl``` to format the file and check for errors (use ```packer inspect``` if needed)
     5) Run ```packer build .azure_ToscaCommanderSetup.pkr.hcl``` to build the image
3. Provision the image created
     1) Edit [main.tf](ToscaDEX-Packer-Terraform/Terraform/main.tf). Add more Dex Agent modules if needed. Remember to change the image name, resource group as well.
     2) Run ```terraform plan``` and check if the plan is as expected
     3) Run ```terraform apply``` if plan is as expected

### Further steps needed
1. Changing RDP Config during the creation of DEX Agent image such that unattended execution is enabled by default without the need of manual intervention

## Acknowledgements
  - Adapted from [Tosca.CloudTemplates](https://github.com/Tricentis/Tosca.CloudTemplates/tree/main)
